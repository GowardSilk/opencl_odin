package ka;

import "core:c"
import "core:mem"
import "core:fmt"
import "core:time"
import "core:strings"
import "core:odin/parser"
import "core:odin/ast"

import "emulator"
import cl "shared:opencl"

Compiler :: struct {
	/**
	 * table of all procedures (key <=> proc_name)
	 * only for Proc_Kind.Builtin, Proc_Desc.params != nil
	 */
	proc_table:	map[string]Proc_Desc,
	types:		map[string]string,
	builtin_path:	string, /**< path to @(builtin) kernel procs */
	package_path:	string, /**< path to @(kernel) procs */
	query_addr:	#type proc(^Proc_Desc), /**< procedure to query an address from Proc_Desc */
}

init_compiler :: proc(query_addr_proc: #type proc(^Proc_Desc), builtin_path, package_path: string, allocator := context.allocator) -> Compiler {
	p := mem.make(map[string]Proc_Desc, allocator);
	t := generate_opencl_type_map(allocator);
	return Compiler { p, t, builtin_path, package_path, query_addr_proc, };
}

delete_compiler :: proc(using compiler: ^Compiler) {
	// NOTE(GowardSilk): the contents of proc_table should be freed successfully outside this function, from the appropriate allocator
	if proc_table != nil do mem.delete(proc_table);
	if types != nil {
		for k, v in types {
			delete_key(&types, k);
			mem.delete(k);
			mem.delete(v);
		}
		mem.delete(types);
	}
}

OpenCL_Qualifier :: emulator.OpenCL_Qualifier;
OpenCL_Qualifier_Invalid :: emulator.OpenCL_Qualifier_Invalid;
OpenCL_Qualifier_Const 	 :: emulator.OpenCL_Qualifier_Const;
OpenCL_Qualifier_Global	 :: emulator.OpenCL_Qualifier_Global;
OpenCL_Qualifier_Local	 :: emulator.OpenCL_Qualifier_Local;

Proc_Desc_Param :: emulator.Proc_Desc_Param;

Proc_Kind :: enum {
	Default = 0, /**< "odin" proc */
	Kernel,  /**< __kernel function */
	Builtin, /**< OpenCL C builtin function */
}

Proc_Desc :: struct {
	attributes: []^ast.Attribute,
	lit:        ^ast.Proc_Lit,
	name:        string,
	params:      map[string]Proc_Desc_Param,
	kind:        Proc_Kind,
	addr:        emulator.Kernel_Null_Proc_Wrapper,
}
PROC_DESC_INVALID := Proc_Desc { nil, nil, "", nil, .Default, nil };

Is_Proc_Ret :: enum {
	OK = 0,
	Not_Proc,
	Invalid,
}

is_proc_lit :: #force_inline proc(any_stmt: ^ast.Any_Stmt, proc_desc: ^Proc_Desc) -> Is_Proc_Ret {
	val_decl, is_val_decl := any_stmt.(^ast.Value_Decl);
	if is_val_decl {
		if len(val_decl.values) > 0 {
			proc_lit, is_proc_lit := val_decl.values[0].derived_expr.(^ast.Proc_Lit);
			if is_proc_lit {
				proc_desc^ = Proc_Desc {
					attributes = val_decl.attributes[:],
					lit = proc_lit,
					name = val_decl.names[0].derived_expr.(^ast.Ident).name,
					params = nil,
					kind = .Default,
					addr = nil,
				};
				return .OK;
			}
		}
	}
	return .Not_Proc;
}

is_proc_query_attr_helper :: #force_inline proc(attrs: []^ast.Attribute, key: string) -> ^ast.Attribute {
	for attr in attrs {
		attr_expr := attr.elems[0];
		field_value, ok := attr_expr.derived.(^ast.Field_Value);
		if ok {
			if field_value.field.derived_expr.(^ast.Ident).name == key {
				return attr;
			}
		}
		ident: ^ast.Ident;
		ident, ok = attr_expr.derived_expr.(^ast.Ident);
		if ok {
			if ident.name == key {
				return attr;
			}
		}
	}

	return nil;
}

is_builtin_proc :: #force_inline proc(proc_desc: ^Proc_Desc) -> Is_Proc_Ret {
	if is_proc_query_attr_helper(proc_desc.attributes, "kernel_builtin") != nil {
		proc_desc.kind = .Builtin;
		return .OK;
	}
	return .Not_Proc;
}

is_kernel_proc :: #force_inline proc(proc_desc: ^Proc_Desc) -> Is_Proc_Ret {
	// check if function is "__kernel"
	if is_proc_query_attr_helper(proc_desc.attributes, "kernel") == nil {
		return .Not_Proc;
	}
	// __kernel(s) cannot have non-void return type
	if proc_desc.lit.type.results != nil {
		parser.default_error_handler(
			proc_desc.lit.type.results.list[0].pos,
			"OpenCL prohibits __kernel functions to have non-void return type! Skipping this kernel..."
		);
		return .Invalid;
	}

	// generate default data for procedure params
	proc_desc.params = mem.make(map[string]Proc_Desc_Param);
	for param in proc_desc.lit.type.params.list {
		for param_name_expr in param.names {
			param_name := param_name_expr.derived_expr.(^ast.Ident).name;
			// const by default
			map_insert(
				&proc_desc.params,
				param_name,
				Proc_Desc_Param {param_name, OpenCL_Qualifier_Const}
			);
		}
	}
	// if "params" attribute explicitly specified,
	// query its contents and assign special values to proc_desc.params
	params_attr := is_proc_query_attr_helper(proc_desc.attributes, "params");
	if params_attr != nil {
		params_val  := params_attr.elems[0].derived.(^ast.Field_Value).value.derived_expr;
		if !extract_kernel_proc_param_qualifiers(&proc_desc.params, params_val) {
			delete(proc_desc.params);
			return .Invalid;
		}
	}
	// other attributes (Odin's) are ignored since they have no real use in cl
	if params_attr == nil && len(proc_desc.attributes) > 2 {
		parser.default_warning_handler(proc_desc.lit.pos, "Odin's attributes ignored!");
	}

	proc_desc.kind = .Kernel;

	return .OK;
}

extract_kernel_proc_param_qualifiers :: proc(params: ^map[string]Proc_Desc_Param, param_val_expr: ast.Any_Expr) -> bool {
	comp_lit, is_comp_lit := param_val_expr.(^ast.Comp_Lit);
	if !is_comp_lit do return false;

	to_opencl_qual_from_string :: #force_inline proc(qual: string) -> OpenCL_Qualifier {
		switch qual {
			case "\"global\"", "\"__global\"":
				return OpenCL_Qualifier_Global;
			case "\"local\"", "\"__local\"":
				return OpenCL_Qualifier_Local;
			case "\"const\"", "\"__const\"":
				return OpenCL_Qualifier_Const;
			case:
				return OpenCL_Qualifier_Invalid;
		}
	}
	
	for e in comp_lit.elems {
		field_val, is_field_val := e.derived_expr.(^ast.Field_Value);
		if !is_field_val {
			parser.default_error_handler(e.pos, "Expected field value!");
			return false;
		}

		param, ok := &params[field_val.field.derived_expr.(^ast.Ident).name];
		if !ok {
			parser.default_error_handler(
				e.pos,
				"Identifier (%s) does not match any param name!",
				field_val.field.derived_expr.(^ast.Ident).name
			);
			return false;
		}

		attr_val, is_attr_val := field_val.value.derived_expr.(^ast.Basic_Lit);
		if !is_attr_val {
			parser.default_error_handler(e.pos, "Expected identifier!");
			return false;
		}
		if attr_val.tok.kind != .String {
			parser.default_error_handler(e.pos, "Expected string literal!");
			return false;
		}
		param^.qual = to_opencl_qual_from_string(attr_val.tok.text);
	}

	return true;
}

is_valid_proc :: #force_inline proc(any_stmt: ^ast.Any_Stmt, proc_desc: ^Proc_Desc) -> bool {
	if is_proc_lit(any_stmt, proc_desc) != .OK do return false;

	#partial switch is_builtin_proc(proc_desc) {
		case .OK:	return true;
		case .Invalid:	return false;
	}
	#partial switch is_kernel_proc(proc_desc) {
		case .OK:	return true;
		case .Invalid:	return false;
	}

	return true; // .Default proc
}

Assemble_Kernels_Result :: struct {
	kernel_strings: [^]cstring,
	kernel_sizes: [^]c.size_t,
	nof_kernels: cl.Uint,
}

delete_assemble_kernels_res :: proc(akr: Assemble_Kernels_Result) {
	for i in 0..<akr.nof_kernels do delete(akr.kernel_strings[i]);
	free(akr.kernel_sizes);
	free(akr.kernel_strings);
}

SHOW_TIMINGS :: #config(SHOW_TIMINGS, ODIN_DEBUG);

/**
 * @brief "compiles" kernel procedures into OpenCL kernels and initializes OpenCL_Context with a program containing them
 * @param query_addr_proc to query procedure addresses from Proc_Desc (can be 'nil' when `ekind' parameter is not .Null)
 * @return Allocation_Error if any occured
 */
compile :: proc(
		ocl: ^OpenCL_Context,
		ekind: emulator.Emulator_Kind,
		query_addr_proc: #type proc(^Proc_Desc),
		builtin_path := "kernel_assembly/emulator",
		package_path := "kernel_assembly/my_kernels"
	) -> mem.Allocator_Error {
	compiler := init_compiler(query_addr_proc, builtin_path, package_path);
	defer delete_compiler(&compiler);

	// store the allocator which is used in scope of the function caller (for return value allocation)
	backup_allocator := context.allocator;
	ca: Compiler_Allocator;
	assert(compiler_allocator_init(&ca, context.allocator) == .None);
	context.allocator = compiler_allocator(&ca);
	// everything allocated from this function will be freed upon leave
	defer compiler_allocator_destroy(&ca);

	kernels_res: Assemble_Kernels_Result;
	switch ekind {
		case .Full:
			when SHOW_TIMINGS {
				diff: time.Duration;
				{
					time.SCOPED_TICK_DURATION(&diff)
					kernels_res = assemble_kernels(&compiler) or_return;
				}
				fmt.eprintfln("Kernel assembly in total took: %v", diff);
			} else {
				kernels_res = assemble_kernels(&compiler) or_return;
			}
			init_cl_context(ocl, ekind, &compiler, kernels_res, backup_allocator);
			delete_assemble_kernels_res(kernels_res);

		case .Null:
			when SHOW_TIMINGS {
				diff: time.Duration;
				{
					time.SCOPED_TICK_DURATION(&diff)
					assemble_kernels_partial(&compiler, &kernels_res);
				}
				fmt.eprintfln("(Partial) Kernel assembly in total took: %v", diff);
			} else {
				assemble_kernels_partial(&compiler, &kernels_res);
			}

			init_cl_context(ocl, ekind, &compiler, kernels_res, backup_allocator);
	}
	return .None;
}

assemble_kernels :: proc(compiler: ^Compiler) -> (out: Assemble_Kernels_Result, err: mem.Allocator_Error) {
	assemble_kernels_partial(compiler, &out);

	out.kernel_sizes = mem.make([^]c.size_t, out.nof_kernels) or_return;
	out.kernel_strings = mem.make([^]cstring, out.nof_kernels) or_return;

	// timed assembly
	when SHOW_TIMINGS {
		diff: time.Duration;
		{
			time.SCOPED_TICK_DURATION(&diff);
			assemble_kernels_translate_helper(compiler, &out) or_return;
		}
		fmt.eprintfln("\"Assembly\" translation took: %v", diff);
	} else {
		assemble_kernels_translate_helper(compiler, &out) or_return;
	}
	return out, .None;
}

/**
 * @brief parses package files and registers valid kernels (aka @builtin/@kernel) into the compiler table
 * @note function assumes valid parameters (non-nil) and valid package paths inside compiler!
 */
@(private="file")
assemble_kernels_partial :: #force_inline proc(compiler: ^Compiler, out: ^Assemble_Kernels_Result) {
	// parse builtin and "target" package
	pckg, builtin_pckg: ^ast.Package;
	ok: bool;
	builtin_pckg, ok = assemble_kernels_parse_helper(compiler.builtin_path);
	assert(ok);
	pckg, ok         = assemble_kernels_parse_helper(compiler.package_path);
	assert(ok);

	// register all the functions into a (common) compiler table
	assemble_kernels_register_helper(compiler, builtin_pckg, &out.nof_kernels);
	assemble_kernels_register_helper(compiler, pckg, &out.nof_kernels);
}

/**
 * @brief helper function for assemble_kernels proc, launches parsing of a package from path (with optional timing if SHOW_TIMINGS is defined)
 * @note function assumes valid package path
 */
@(private="file")
assemble_kernels_parse_helper :: #force_inline proc(path: string) -> (pckg: ^ast.Package, ok: bool) {
	when SHOW_TIMINGS {
		// timed parsing
		diff: time.Duration;
		{
			time.SCOPED_TICK_DURATION(&diff)
			pckg, ok = parser.parse_package_from_path(path);
		}
		fmt.eprintfln("Parsing of \"%s\" took: %v", path, diff);
	} else {
		parser.parse_package_from_path(path);
	}
	return pckg, ok;
}

/**
 * @brief registers all valid procedures into the compiler's procedure table (here "valid" means whenever `is_valid_proc' returns true for a given procedure node)
 * @note function assumes valid parameters (non-nil)
 */
@(private="file")
assemble_kernels_register_helper :: #force_inline proc(compiler: ^Compiler, pckg: ^ast.Package, nof_kernels: ^cl.Uint) {
	for _, file in pckg.files {
		proc_desc: Proc_Desc;
		for stmt in file.decls do if is_valid_proc(&stmt.derived_stmt, &proc_desc) {
			if proc_desc.kind == .Kernel {
				if compiler.query_addr != nil {
					compiler.query_addr(&proc_desc);
				}
				nof_kernels^ += 1;
			}
			map_insert(&compiler.proc_table, proc_desc.name, proc_desc);
		}
	}
}

/**
 * @brief generates OpenCL code from procedure nodes (located in the compiler's procedure table)
 * @note function assumes valid parameters (non-nil) and valid compiler's procedure table; `out' has to be preallocated by the caller
 */
@(private="file")
assemble_kernels_translate_helper :: #force_inline proc(compiler: ^Compiler, out: ^Assemble_Kernels_Result) -> mem.Allocator_Error {
	kernel_string_builder: strings.Builder;
	assert(strings.builder_init(&kernel_string_builder) != nil);

	index := 0;
	decl_loop: for _, proc_desc in compiler.proc_table do if proc_desc.kind == .Kernel {
		defer strings.builder_reset(&kernel_string_builder);
		using proc_desc;

		parameters, body: string;

		// assemble parameter list
		for param, index in lit.type.params.list {
			qual := params[param.names[0].derived_expr.(^ast.Ident).name].qual;
			strings.write_string(&kernel_string_builder, cast(string)qual);
			strings.write_byte(&kernel_string_builder, ' ');

			_in: To_Opencl_Lang_In = {
				compiler,
				&kernel_string_builder,
				param.node,
				0,
				true,
			};
			if !to_opencl_lang(&_in) do continue decl_loop;

			if index < len(lit.type.params.list) - 1 {
				strings.write_string(&kernel_string_builder, ", ");
			}
		}
		parameters = strings.clone(strings.to_string(kernel_string_builder));
		strings.builder_reset(&kernel_string_builder);

		// assemble kernel body
		body_block := lit.body.derived.(^ast.Block_Stmt);
		_in: To_Opencl_Lang_In = {
			compiler,
			&kernel_string_builder,
			body_block.stmt_base,
			0,
			true,
		};
		if !to_opencl_lang(&_in) do continue decl_loop;
		body = strings.clone(strings.to_string(kernel_string_builder));
		strings.builder_reset(&kernel_string_builder);

		fmt.sbprintf(&kernel_string_builder, "__kernel void %s(%s) %s", name, parameters, body);

		kernel_size := strings.builder_len(kernel_string_builder);
		kernel_cstr := mem.make([]byte, kernel_size) or_return;
		mem.copy(&kernel_cstr[0], &kernel_string_builder.buf[0], kernel_size * size_of(byte));
		out.kernel_strings[index] = cast(cstring)&kernel_cstr[0];
		out.kernel_sizes[index] = cast(c.size_t)kernel_size;

		index += 1;
	}

	return .None;
}

err_return :: #force_inline proc(node: ast.Node, msg: string, args: ..any) -> bool {
	parser.default_error_handler(node.pos, msg, ..args);
	return false;
}

To_Opencl_Lang_In :: struct {
	compiler: ^Compiler,	/**< pointer to a valid compiler instance (this is required only for occasional type searches) */
	builder: ^strings.Builder, /**< pointer to a valid string concatenator */
	node: ast.Node,		/**< active node (being translated) */
	tab_offset: int,	/**< recursive depth (handled internally) */
	full: bool,		/**< indicates that next statement is to be properly terminated (aka "full") */
}

update_active_node :: #force_inline proc(_in: ^To_Opencl_Lang_In, node: ast.Node) -> ^To_Opencl_Lang_In {
	_in.node = node;
	return _in;
}

/**
 * @brief converts odin statement (`node') into open computing language
 */
to_opencl_lang :: proc(using _in: ^To_Opencl_Lang_In) -> bool {
	if node.derived == nil do return true;

	#partial switch v in node.derived {
		case ^ast.Basic_Lit:
			#partial switch v.tok.kind {
				case .Imag:
					return err_return(node, "Imaginary numbers are not supported in OpenCL! Note: this could be though supported in the future via some kind of explicit unwrap into some Imaginary data type...");
				case .Ident, .Integer, .Float, .Rune, .String:
					fmt.sbprint(builder, v.tok.text);
				case:
					unreachable();
			}
		case ^ast.Ident:
			fmt.sbprint(builder, v.name);
		case ^ast.Unary_Expr:
			fmt.sbprint(builder, v.op.text);
			return to_opencl_lang(update_active_node(_in, v.expr_base));
		case ^ast.Binary_Expr:
			to_opencl_lang(update_active_node(_in, v.left.expr_base)) or_return;
			fmt.sbprintf(builder, " %s ", v.op.text);
			return to_opencl_lang(update_active_node(_in, v.right.expr_base));
		case ^ast.Paren_Expr:
			strings.write_byte(builder, '(');
			to_opencl_lang(update_active_node(_in, v.expr.expr_base)) or_return;
			strings.write_byte(builder, ')');
		case ^ast.Index_Expr:
			to_opencl_lang(update_active_node(_in, v.expr.expr_base)) or_return;
			strings.write_byte(builder, '[');
			to_opencl_lang(update_active_node(_in, v.index.expr_base)) or_return;
			strings.write_byte(builder, ']');
		case ^ast.Call_Expr:
			selector, ok := v.expr.derived_expr.(^ast.Selector_Expr);
			ident: ^ast.Ident;
			if ok do ident = selector.field;
			else do ident, _ = v.expr.derived_expr.(^ast.Ident);
			strings.write_string(builder, ident.name);
			strings.write_byte(builder, '(');

			tmp := full;
			for arg in v.args {
				full = false;
				to_opencl_lang(update_active_node(_in, arg.expr_base)) or_return;
			}
			full = tmp;

			strings.write_byte(builder, ')');
			if full do strings.write_string(builder, ";\n");
		case ^ast.Deref_Expr:
			strings.write_byte(builder, '*');
			return to_opencl_lang(update_active_node(_in, v.expr.expr_base));
		case ^ast.Slice_Expr:
			// slice is "just" a pointer
			strings.write_byte(builder, '[');
			to_opencl_lang(update_active_node(_in, v.low.expr_base)) or_return;
			if v.high != nil {
				parser.default_warning_handler(
					v.high.pos,
					"Slicing cannot be emulated to OpenCL 1:1, so the upper boundary will be ignored!"
				);
			}
		case ^ast.Type_Cast:
			ident, ok := v.type.derived_expr.(^ast.Ident);
			if ok {
				fmt.sbprintfln(builder, "(%s)", ident.name);
			} else {
				strings.write_byte(builder, '(');
				to_opencl_lang_selector(_in, v.type.derived_expr.(^ast.Selector_Expr)) or_return;
				strings.write_byte(builder, ')');
			}
			return to_opencl_lang(update_active_node(_in, v.expr.expr_base));
		case ^ast.Ternary_If_Expr:
			return err_return(v.expr_base, "TODO ternary: Not yet implemented");
		case ^ast.Selector_Expr:
			return to_opencl_lang_selector(_in, v);
		case ^ast.Tag_Expr:
			return err_return(v.expr_base, "TODO tag: Not yet implemented");

		// Statements
		case ^ast.Assign_Stmt:
			return to_opencl_lang_assign_stmt(_in, v);
		case ^ast.Expr_Stmt:
			return to_opencl_lang(update_active_node(_in, v.expr.expr_base));
		case ^ast.Block_Stmt:
			strings.write_string(builder, "{\n");

			tab_offset += 1;
			for stmt in v.stmts {
				for i in 0..<tab_offset do strings.write_byte(builder, '\t');
				_in.full = true;
				to_opencl_lang(update_active_node(_in, stmt.stmt_base)) or_return;
			}
			tab_offset -= 1;

			if tab_offset > 0 do for i in 0..<tab_offset do strings.write_byte(builder, '\t');
			strings.write_string(builder, "}\n");
		case ^ast.If_Stmt:
			strings.write_string(builder, "if (");
			if v.label != nil {
				return err_return(v.stmt_base, "Label unsupported for if statements");
			}
			to_opencl_lang(update_active_node(_in, v.cond.expr_base)) or_return;
			strings.write_byte(builder, ')');
			to_opencl_lang(update_active_node(_in, v.body.stmt_base)) or_return;
			if v.else_stmt != nil {
				for _ in 0..<tab_offset do strings.write_byte(builder, '\t');
				strings.write_string(builder, "else");
				to_opencl_lang(update_active_node(_in, v.else_stmt.stmt_base)) or_return;
			}
		case ^ast.For_Stmt:
			if v.label != nil do return err_return(v.label.expr_base, "For loop labels not supported");
			strings.write_string(builder, "for (");
			if v.init != nil {
				_in.full = false;
				to_opencl_lang_value_decl(
					_in,
					v.init.derived_stmt.(^ast.Value_Decl),
				) or_return;
				_in.full = true;
			}
			strings.write_byte(builder, ';');
			to_opencl_lang(update_active_node(_in, v.cond.expr_base)) or_return;
			strings.write_byte(builder, ';');
			if v.post != nil {
				_in.full = false;
				to_opencl_lang_assign_stmt(
					_in,
					v.post.derived_stmt.(^ast.Assign_Stmt)
				) or_return;
				_in.full = true;
			}
			strings.write_byte(builder, ')');
			to_opencl_lang(update_active_node(_in, v.body.stmt_base)) or_return;
			strings.write_byte(builder, '\n');
		case ^ast.Range_Stmt:
			return err_return(v.stmt_base, "TODO range: Not yet implemented");
		case ^ast.Unroll_Range_Stmt:
			return err_return(v.stmt_base, "TODO unroll: Not yet implemented");
		case ^ast.Return_Stmt:
			return err_return(v.stmt_base, "TODO return: Not yet implemented");
		case ^ast.Switch_Stmt:
			return err_return(v.stmt_base, "TODO switch: Not yet implemented");
		case ^ast.Case_Clause:
			return err_return(v.stmt_base, "TODO case: Not yet implemented");
		case ^ast.Branch_Stmt:
			return err_return(v.stmt_base, "TODO branch: Not yet implemented");

		// Types
		case ^ast.Pointer_Type:
			return to_opencl_lang_ptr(_in, v);
		case ^ast.Multi_Pointer_Type:
			return to_opencl_lang_multi_ptr(_in, v);
		case ^ast.Array_Type:
			ident_type, is_ident_type := v.elem.derived_expr.(^ast.Ident);
			if !is_ident_type do return false;
			if v.len != nil {
				lit_len, is_lit_len := v.len.derived_expr.(^ast.Basic_Lit);
				if !is_lit_len {
					parser.default_warning_handler(v.pos, "Expected literal with appropriate array len! (2, 4, 8, 16)");
					return false;
				}
				b: strings.Builder;
				strings.builder_init(&b, context.temp_allocator);
				fmt.sbprintf(&b, "[%s]%s", lit_len.tok.text, ident_type.name);
				type, is_type := compiler.types[strings.to_string(b)];
				if !is_type {
					parser.default_warning_handler(v.pos, "Could not find appropriate OpenCL vector type. (Trying to match: %v)", strings.to_string(b));
					return false;
				}
				strings.write_string(builder, type);
				strings.builder_destroy(&b);
				return true;
			}

			parser.default_warning_handler(v.pos, "Using slice instead of array, use multi pointer instead or specify the valid range!");
			return false;
		case ^ast.Struct_Type:
			_in.tab_offset += 1;
			for field in v.fields.list {
				for _ in 0..<_in.tab_offset do strings.write_byte(builder, '\t');
				to_opencl_lang(update_active_node(_in, field.node)) or_return;
			}
			_in.tab_offset -= 1;
		case ^ast.Union_Type:
			fmt.sbprintfln(builder, "union { ... }");
			return err_return(v.expr_base, "TODO union: Not yet implemented");
		case ^ast.Enum_Type:
			fmt.sbprintfln(builder, "enum { ... }");
			return err_return(v.expr_base, "TODO enum: Not yet implemented");
		case ^ast.Matrix_Type:
			fmt.sbprintfln(builder, "type[row][col]");
			return err_return(v.expr_base, "TODO matrix: Not yet implemented");
		case ^ast.Helper_Type:
			return to_opencl_lang(update_active_node(_in, v.type.expr_base));

		// Declarations
		case ^ast.Value_Decl:
			return to_opencl_lang_value_decl(_in, v);
		case ^ast.Field:
			for name, index in v.names {
				to_opencl_lang(update_active_node(_in, v.type.expr_base)) or_return;
				strings.write_byte(builder, ' ');
				to_opencl_lang(update_active_node(_in, name.expr_base)) or_return;
				if index < len(v.names) - 1 {
					strings.write_string(builder, ", ");
				}
			}
		case ^ast.Field_List:
			for field, index in v.list {
				to_opencl_lang(update_active_node(_in, field.node)) or_return;
				if index < len(v.list) - 1 {
					strings.write_string(builder, ", ");
				}
			}

		// UNSUPPORTED
		case ^ast.Comment_Group:
			return true; // this can be ignored

		case ^ast.Package:
			return err_return(node, "Packages are a compile-time organization unit and cannot be represented in OpenCL C.");
		case ^ast.File:
			return err_return(node, "Files are top-level containers and irrelevant in OpenCL kernels.");
		case ^ast.Bad_Expr:
			return err_return(node, "This expression is malformed and cannot be translated.");
		case ^ast.Implicit:
			return err_return(node, "Implicit nodes are contextual placeholders and need to be resolved before conversion.");
		case ^ast.Undef:
			return err_return(node, "Undefined value has no OpenCL equivalent. Consider zero-initialization.");
		case ^ast.Basic_Directive:
			return err_return(node, "Odin directives are compile-time and cannot be mapped to OpenCL C.");
		case ^ast.Ellipsis:
			return err_return(node, "Ellipsis are Odin varargs/array shorthand; OpenCL has no equivalent.");
		case ^ast.Proc_Lit:
			return err_return(node, "Anonymous procedures (lambdas); are not supported in OpenCL C. Note: this one can be technically supported in the future via default forced inlining...")
		case ^ast.Comp_Lit:
			return err_return(node, "Composite literals are not directly supported; consider struct assignment.");
		case ^ast.Implicit_Selector_Expr:
			return err_return(node, "Implicit selectors are contextual and must be resolved first.");
		case ^ast.Selector_Call_Expr:
			return err_return(node, "Selector call expressions (e.g., method values); are not OpenCL compatible.")
		case ^ast.Matrix_Index_Expr:
			return err_return(node, "Matrix indexing must be translated to 2D array access manually.");
		case ^ast.Field_Value:
			return err_return(node, "Field-value syntax in struct literals is not valid in OpenCL.");
		case ^ast.Ternary_When_Expr:
			return err_return(node, "`when` expressions are compile-time conditionals and must be eliminated beforehand.");
		case ^ast.Or_Else_Expr, ^ast.Or_Return_Expr, ^ast.Or_Branch_Expr:
			return err_return(node, "Error-handling expressions (`or_else`, `or_return`, `or_branch`); are not supported.")
		case ^ast.Type_Assertion:
			return err_return(node, "Type assertions are runtime checks and are not available in OpenCL.");
		case ^ast.Inline_Asm_Expr:
			return err_return(node, "Inline assembly is not valid inside OpenCL kernels.");
		case ^ast.Proc_Group:
			return err_return(node, "Procedure groups are compile-time conveniences and have no OpenCL equivalent.");
		case ^ast.Typeid_Type:
			return err_return(node, "`typeid` is for reflection and metadata, which OpenCL does not support.");
		case ^ast.Distinct_Type:
			return err_return(node, "Distinct types must be resolved to base types before codegen.");
		case ^ast.Poly_Type:
			return err_return(node, "Polymorphic types must be monomorphized before OpenCL translation.");
		case ^ast.Bit_Set_Type:
			return err_return(node, "Bit sets are not a native C/OpenCL feature. Consider using bitfields manually.");
		case ^ast.Map_Type:
			return err_return(node, "Maps are high-level containers and are not usable in OpenCL C.");
		case ^ast.Relative_Type:
			return err_return(node, "Relative types depend on context and must be resolved before codegen.");
		case ^ast.Bit_Field_Type:
			return err_return(node, "Bitfields are not directly supported; consider using integer masking.");
		case ^ast.Bad_Stmt:
			return err_return(node, "This statement is invalid and cannot be converted.");
		case ^ast.Empty_Stmt:
			return err_return(node, "Empty statements are ignored and do not emit code.");
		case ^ast.Tag_Stmt:
			return err_return(node, "Tag statements are for control flow and have no OpenCL equivalent.");
		case ^ast.When_Stmt:
			return err_return(node, "`when` is a compile-time conditional and must be resolved before codegen.");
		case ^ast.Defer_Stmt:
			return err_return(node, "`defer` is not available in OpenCL; perform explicit cleanup. Note: This could be supported in the future...");
		case ^ast.Type_Switch_Stmt:
			return err_return(node, "Type switches rely on runtime type info, which OpenCL does not support.");
		case ^ast.Using_Stmt:
			return err_return(node, "`using` is scope flattening at compile-time and must be resolved.");
		case ^ast.Bad_Decl:
			return err_return(node, "This declaration is invalid and must be removed or fixed.");
		case ^ast.Package_Decl:
			return err_return(node, "Package declarations are not relevant to OpenCL kernel output.");
		case ^ast.Import_Decl:
			return err_return(node, "Imports are resolved during Odin compilation and not emitted to OpenCL.");
		case ^ast.Foreign_Block_Decl, ^ast.Foreign_Import_Decl:
			return err_return(node, "Foreign declarations reference external symbols and cannot appear in OpenCL kernels.");
		case ^ast.Attribute:
			return err_return(node, "Attributes are compile-time and not preserved in OpenCL.");
		case ^ast.Bit_Field_Field:
			return err_return(node, "Bitfield fields are not directly supported in OpenCL. Use manual bit packing. Note: This could be supported in the future...");
	}

	return true;
}

to_opencl_lang_assign_stmt :: #force_inline proc(using _in: ^To_Opencl_Lang_In, v: ^ast.Assign_Stmt) -> bool {
	to_opencl_lang(update_active_node(_in, v.lhs[0].expr_base)) or_return;
	fmt.sbprintf(builder, " %s ", v.op.text);
	to_opencl_lang(update_active_node(_in, v.rhs[0].expr_base)) or_return;
	if full do strings.write_string(builder, ";\n");
	return true;
}

to_opencl_lang_value_decl :: #force_inline proc(using _in: ^To_Opencl_Lang_In, v: ^ast.Value_Decl) -> bool {
	type: string;
	if v.type == nil {
		type = query_type_from_value_decl(_in, v);
		if type == "" {
			return err_return(
				v.names[0].expr_base,
				"Failed to infer type for %v value declaration",
				v
			);
		}
	} else {
		ident, ok := v.type.derived_expr.(^ast.Ident);
		if ok {
			type = ident.name;
		} else {
			backup_builder := _in.builder;
			selector_builder: strings.Builder;
			strings.builder_init(&selector_builder);
			_in.builder = &selector_builder;
			to_opencl_lang_selector(_in, v.type.derived_expr.(^ast.Selector_Expr));
			_in.builder = backup_builder;
			type = strings.to_string(selector_builder);
		}
	}
	for name, index in v.names {
		val_ident, is_val_ident := name.derived.(^ast.Ident);
		if !is_val_ident do return err_return(name.expr_base, "Expected identifier, got: %v", name.expr_base);

		if index < len(v.values) {
			// definition
			fmt.sbprintf(builder, "%s %s = ", type, val_ident.name);

			tmp := full;
			full = false;
			to_opencl_lang(update_active_node(_in, v.values[index].expr_base)) or_return;
			full = tmp;
		} else {
			// declaration
			fmt.sbprintf(builder, "%s %s", type, val_ident.name);
		}
		if full do strings.write_string(builder, ";\n");
	}

	return true;
}

query_type_from_value_decl_grab_proc_ret_type :: #force_inline proc(using _in: ^To_Opencl_Lang_In, proc_type: ^ast.Proc_Type) -> string {
	if len(proc_type.results.list) != 1 {
		parser.default_error_handler(
			proc_type.pos,
			"Multiple return types not supported, use struct",
		);
		return "";
	}

	selector, is_selector := proc_type.results.list[0].type.derived_expr.(^ast.Selector_Expr);
	if is_selector {
		b: strings.Builder;
		strings.builder_init(&b);

		temp := _in.builder;
		_in.builder = &b;
		defer _in.builder = temp;

		if to_opencl_lang_selector(_in, selector) {
			// NOTE(GowardSilk): This function should be called only from to_opencl_lang
			// and that should be covered by Compiler_Allocator anyway...
			return strings.to_string(b);
		}
	}
	ident, is_ident := proc_type.results.list[0].type.derived_expr.(^ast.Ident);
	if is_ident {
		return compiler.types[ident.name];
	}

	return "";
}

query_type_from_value_decl :: #force_inline proc(using _in: ^To_Opencl_Lang_In, val: ^ast.Value_Decl) -> string {
	if len(val.values) <= 0 do return "";
	#partial switch v in val.values[0].derived_expr {
		case ^ast.Call_Expr:
			name: string;
			ident, ok := v.expr.derived_expr.(^ast.Ident);
			if ok {
				name = ident.name;
			} else {
				selector := v.expr.derived_expr.(^ast.Selector_Expr);
				name = selector.field.name;
			}
			_proc, found := compiler.proc_table[name];
			if found {
				return query_type_from_value_decl_grab_proc_ret_type(_in, _proc.lit.type);
			}
			return "";
		case ^ast.Basic_Lit:
			#partial switch v.tok.kind {
				case .Ident:   return v.tok.text;
				case .Integer: return "int";
				case .Float:   return "float";
				case .Imag:    return ""; // unsupported
				case .Rune:    return "char";
				case .String:  return "const char*";
			}
		case ^ast.Ident:
			parser.default_error_handler(
				val.pos,
				"Ident (%s) as type of a value declaration indicates type inference, which we do not yet support!",
				v.name
			);
			return "";
		case:
			parser.default_error_handler(
				val.pos,
				"Unsupported stmt type in value declaration! %v",
				v
			);
			return "";
	}

	unreachable();
}

Odin_Opencl_Type_Mapping :: struct {
	odin, opencl: string
}
when size_of(int) == 8 {
	OPENCL_BASE_TYPES :: [?]Odin_Opencl_Type_Mapping {
		{ "int"    , "long", },
		{ "uint"    , "ulong", },

		{ "i8"    , "char", },
		{ "u8"    , "uchar", },
		{ "byte"  , "uchar", },
		{ "i16"   , "short", },
		{ "u16"   , "ushort", },
		{ "i32"   , "int", },
		{ "u32"   , "uint", },
		{ "i64"   , "long", },
		{ "u64"   , "ulong", },
		{ "f32"   , "float", },
		{ "f64"   , "double", },
		{ "f16"   , "half", },
		{ "bool"  , "bool", },
		{ "uintptr" , "size_t", },
		{ "intptr"  , "ptrdiff_t", },
	};
} else when size_of(int) == 4 {
	OPENCL_BASE_TYPES :: [?]Odin_Opencl_Type_Mapping {
		{ "int"    , "int", },
		{ "uint"    , "uint", },

		{ "i8"    , "char", },
		{ "u8"    , "uchar", },
		{ "byte"  , "uchar", },
		{ "i16"   , "short", },
		{ "u16"   , "ushort", },
		{ "i32"   , "int", },
		{ "u32"   , "uint", },
		{ "i64"   , "long", },
		{ "u64"   , "ulong", },
		{ "f32"   , "float", },
		{ "f64"   , "double", },
		{ "f16"   , "half", },
		{ "bool"  , "bool", },
		{ "uintptr" , "size_t", },
		{ "intptr"  , "ptrdiff_t", },
	};
}

generate_opencl_type_map :: proc(allocator: mem.Allocator) -> map[string]string {
	vector_sizes :: [?]int { 2, 3, 4, 8, 16 };

	builder: strings.Builder;
	strings.builder_init(&builder, allocator);
	defer strings.builder_destroy(&builder);

	types := make(map[string]string, allocator);

	for type in OPENCL_BASE_TYPES {
		base_odin_type := type.odin;
		cl_base := type.opencl;

		// copy of basic types
		map_insert(
			&types,
			strings.clone(base_odin_type, allocator),
			strings.clone(cl_base, allocator)
		);

		// vector types
		for size in vector_sizes {
			fmt.sbprintf(&builder, "[%d]%s", size, base_odin_type);
			val := map_insert(&types, strings.clone(strings.to_string(builder), allocator), "");
			strings.builder_reset(&builder);

			fmt.sbprintf(&builder, "%s%d", cl_base, size);
			val^ = strings.clone(strings.to_string(builder), allocator);
			strings.builder_reset(&builder);
		}
	}

	return types;
}

to_opencl_lang_selector :: #force_inline proc(using _in: ^To_Opencl_Lang_In, selector: ^ast.Selector_Expr) -> bool {
	// NOTE(GowardSilk): For a type, selector expr means having a specific package being accessed
	name := selector.expr.derived_expr.(^ast.Ident).name;
	switch name {
		// NOTE(GowardSilk): Assuming cl and c are package names... not particularly great though???
		case "cl":
			strings.write_byte(builder, selector.field.name[0] | 32);
			strings.write_string(builder, selector.field.name[1:]);
		case "c":
			strings.write_string(builder, selector.field.name);
		case "emulator":
			strings.write_string(builder, selector.field.name);
		case:
			to_opencl_lang(update_active_node(_in, selector.expr.expr_base)) or_return;
			strings.write_string(builder, selector.op.text);
			strings.write_string(builder, selector.field.name);
	}
	return true;
}

to_opencl_lang_ptr :: #force_inline proc(_in: ^To_Opencl_Lang_In, ptr: ^ast.Pointer_Type) -> bool {
	return to_opencl_lang_ptr_base(_in, ptr.elem);
}
to_opencl_lang_multi_ptr :: #force_inline proc(_in: ^To_Opencl_Lang_In, ptr: ^ast.Multi_Pointer_Type) -> bool {
	return to_opencl_lang_ptr_base(_in, ptr.elem);
}
to_opencl_lang_ptr_base :: #force_inline proc(using _in: ^To_Opencl_Lang_In, base: ^ast.Expr) -> bool {
	#partial switch v in base.derived_expr {
		case ^ast.Selector_Expr:
			to_opencl_lang_selector(_in, v) or_return;
			strings.write_byte(builder, '*');
		case:
			return err_return(base.expr_base, "Unsupported: %v", v);
	}
	return true;
}
