package ka;

import "core:c"
import "core:mem"
import "core:fmt"
import "core:time"
import "core:strings"
import "core:strconv"
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

opencl_qualifier_to_storage_class :: #force_inline proc(qual: OpenCL_Qualifier) -> Spirv_Storage_Class {
	switch qual {
		case OpenCL_Qualifier_Invalid: unreachable();
		case OpenCL_Qualifier_Const:
			return .Uniform_Constant;
		case OpenCL_Qualifier_Global:
			// .Storage_Buffer would require spir-v extension ???
			return .Uniform;
		case OpenCL_Qualifier_Local:
			return .Workgroup;
	}
	unreachable();
}

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
		$mode: Translation_Type,
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
					kernels_res = assemble_kernels(&compiler, mode) or_return;
				}
				fmt.eprintfln("Kernel assembly in total took: %v", diff);
			} else {
				kernels_res = assemble_kernels(&compiler, mode) or_return;
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

assemble_kernels :: proc(compiler: ^Compiler, $mode: Translation_Type) -> (out: Assemble_Kernels_Result, err: mem.Allocator_Error) {
	assemble_kernels_partial(compiler, &out);

	when mode == .SPIR_V {
		out.kernel_sizes = mem.make([^]c.size_t, 1) or_return;
		out.kernel_strings = mem.make([^]cstring, 1) or_return;
	} else {
		out.kernel_sizes = mem.make([^]c.size_t, out.nof_kernels) or_return;
		out.kernel_strings = mem.make([^]cstring, out.nof_kernels) or_return;
	}

	// timed assembly
	when SHOW_TIMINGS {
		diff: time.Duration;
		{
			time.SCOPED_TICK_DURATION(&diff);
			assemble_kernels_translate_helper(compiler, mode, &out) or_return;
		}
		fmt.eprintfln("\"Assembly\" translation took: %v", diff);
	} else {
		assemble_kernels_translate_helper(compiler, mode, &out) or_return;
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

@(private="file")
assemble_kernels_translate_helper :: #force_inline proc(compiler: ^Compiler, $mode: Translation_Type, out: ^Assemble_Kernels_Result) -> mem.Allocator_Error {
	switch mode {
		case .OpenCL_Lang:
			return assemble_kernels_translate_to_opencl_helper(compiler, out);
		case .SPIR_V:
			return assemble_kernels_translate_to_spirv_helper(compiler, out);
	}

	unreachable();
}

/**
 * @brief generates SPIR-V code from procedure nodes (located in the compiler's procedure table)
 * @note function assumes valid parameters (non-nil) and valid compiler's procedure table; `out' has to be preallocated by the caller
 */
@(private="file")
assemble_kernels_translate_to_spirv_helper :: proc(compiler: ^Compiler, out: ^Assemble_Kernels_Result) -> mem.Allocator_Error {
	sp_in := init_spirv_in(compiler, {}) or_return;

	decl_loop: for _, &proc_desc in compiler.proc_table do if proc_desc.kind == .Kernel {
		update_active_node(&sp_in, proc_desc.lit);
		sp_in.active_proc = &proc_desc;
		to_spirv(&sp_in);
	}

	spirv_ops_to_binary(&sp_in);

	when ODIN_DEBUG {
		fmt.eprintfln("Spirv Debug Out:\n%s", strings.to_string(sp_in._debug.builder));
	}

	return nil;
}

/**
 * @brief generates OpenCL code from procedure nodes (located in the compiler's procedure table)
 * @note function assumes valid parameters (non-nil) and valid compiler's procedure table; `out' has to be preallocated by the caller
 */
@(private="file")
assemble_kernels_translate_to_opencl_helper :: proc(compiler: ^Compiler, out: ^Assemble_Kernels_Result) -> mem.Allocator_Error {
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

			cl_in := To_Opencl_Lang_In {
				compiler,
				&kernel_string_builder,
				param.node,
				0,
				true,
			};
			if !to_opencl_lang(&cl_in) do continue decl_loop;

			if index < len(lit.type.params.list) - 1 {
				strings.write_string(&kernel_string_builder, ", ");
			}
		}
		parameters = strings.clone(strings.to_string(kernel_string_builder));
		strings.builder_reset(&kernel_string_builder);

		// assemble kernel body
		body_block := lit.body.derived.(^ast.Block_Stmt);
		cl_in := To_Opencl_Lang_In {
			compiler,
			&kernel_string_builder,
			body_block.stmt_base,
			0,
			true,
		};
		if !to_opencl_lang(&cl_in) do continue decl_loop;
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

Translation_Type :: enum {
	OpenCL_Lang = 0, // default
	SPIR_V,
}

To_Opencl_Lang_In :: struct {
	compiler: ^Compiler,	/**< pointer to a valid compiler instance (this is required only for occasional type searches) */
	builder: ^strings.Builder, /**< pointer to a valid string concatenator */
	node: ast.Node,		/**< active node (being translated) */
	tab_offset: int,	/**< recursive depth (handled internally) */
	full: bool,		/**< indicates that next statement is to be properly terminated (aka "full") */
}

when ODIN_DEBUG {
	To_Spirv_In_Debug :: struct {
		builder: strings.Builder, /**< debug string builder for quasi disassembled SPIR-V code representation */
	}
} else {
	To_Spirv_In_Debug :: struct {}
}

To_Spirv_In :: struct {
	compiler: ^Compiler, /**< pointer to a valid compiler instance (this is required only for occasional type searches) */
	builder: [dynamic]Spirv_Word,
	ops: [dynamic]Spirv_Op,
	node: ast.Node, /**< active node (being translated) */
	type_node: ^ast.Any_Node, /**< node that may indicate the type of active `node' */
	active_proc: ^Proc_Desc,
	next_id: Spirv_SSA_Index,

	type_table:  map[string]Spirv_Meta_Op,
	const_table: map[string]Spirv_Op,

	_debug: To_Spirv_In_Debug,
}

/**
 * @brief used for operations which are "pre-loaded", meaning they do not really have to contain valid Spirv_SSA_Index result id
 */
Spirv_Meta_Op :: distinct Spirv_Op;

new_spirv_id :: #force_inline proc(using m: ^To_Spirv_In) -> Spirv_SSA_Index {
	next_id += 1;
	return next_id;
}

push_spirv_op :: #force_inline proc(using m: ^To_Spirv_In, op: _Spirv_Op) -> Spirv_SSA_Index {
	id := new_spirv_id(m);
	append(&ops, Spirv_Op {
		base = Spirv_Op_Base {
			id = id,
		},
		op = op
	});
	return id;
}

spirv_ops_to_binary :: proc(using m: ^To_Spirv_In) {
	// first plug in all the types and constants
	for _, type in type_table do if type.base.id != SPIRV_SSA_INDEX_INVALID {
		#partial switch v in type.op {
			case Spirv_Op_Type_Void:	spirv_op_type_void_to_binary(m, type.base, v);
			case Spirv_Op_Type_Float:	spirv_op_type_float_to_binary(m, type.base, v);
			case Spirv_Op_Type_Int:		spirv_op_type_int_to_binary(m, type.base, v);
			case Spirv_Op_Type_Pointer:	spirv_op_type_pointer_to_binary(m, type.base, v);
			case Spirv_Op_Type_Function:	spirv_op_type_function_to_binary(m, type.base, v);
			case Spirv_Op_Type_Array:	spirv_op_type_array_to_binary(m, type.base, v);
			case: unreachable();
		}
	}

	for o in ops {
		#partial switch v in o.op {
			case Spirv_Op_Constant:	spirv_op_constant_to_binary(m, o.base, v);
			case Spirv_Op_Variable:	spirv_op_variable_to_binary(m, o.base, v);
			case Spirv_Op_Function:	spirv_op_function_to_binary(m, o.base, v);
			case:
				fmt.eprintfln("%v", v);
				unreachable();
		}
	}
}

spirv_op_variable_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Variable) {
	/* %result_id = OpVariable %type_id <storage_class> [%initializer_id] */
	word_count: Spirv_Word = 4;
	if op.initializer != SPIRV_SSA_INDEX_INVALID {
		word_count = 5;
	}
	_spirv_op_to_binary(_in, word_count, SPIRV_OPCODE_OP_VARIABLE);
	append(&builder, cast(Spirv_Word)op.type_id, cast(Spirv_Word)base.id, cast(Spirv_Word)op.class);
	if op.initializer != SPIRV_SSA_INDEX_INVALID {
		append(&builder, cast(Spirv_Word)op.initializer);
	}
	when ODIN_DEBUG {
		if op.initializer != SPIRV_SSA_INDEX_INVALID {
			fmt.sbprintfln(&_debug.builder, "%%%d = OpVariable %%%d %d %%%d", base.id, op.type_id, op.class, op.initializer);
		} else {
			fmt.sbprintfln(&_debug.builder, "%%%d = OpVariable %%%d %d", base.id, op.type_id, op.class);
		}
	}
}

spirv_op_function_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Function) {
	/* %result_id = OpFunction %return_type_id %function_control %function_type_id */
	_spirv_op_to_binary(_in, 5, SPIRV_OPCODE_OP_FUNCTION);
	append(&builder, cast(Spirv_Word)op.return_type_id, cast(Spirv_Word)base.id, cast(Spirv_Word)op.control, cast(Spirv_Word)op.function_type_id);
	when ODIN_DEBUG {
		fmt.sbprintfln(&_debug.builder, "%%%d = OpFunction %%%d %d %%%d", base.id, op.return_type_id, op.control, op.function_type_id);
	}
}

spirv_op_type_void_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Type_Void) {
	/* %result_id = OpTypeVoid */
	_spirv_op_to_binary(_in, 2, SPIRV_OPCODE_OP_TYPE_VOID);
	append(&builder, cast(Spirv_Word)base.id);
	when ODIN_DEBUG {
		fmt.sbprintfln(&_debug.builder, "%%%d = OpTypeVoid", base.id);
	}
}

spirv_op_type_float_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Type_Float) {
	/* %result_id = OpTypeFloat <width> */
	_spirv_op_to_binary(_in, 3, SPIRV_OPCODE_OP_TYPE_FLOAT);
	append(&builder, cast(Spirv_Word)base.id, op.width);
	when ODIN_DEBUG {
		fmt.sbprintfln(&_debug.builder, "%%%d = OpTypeFloat %d", base.id, op.width);
	}
}

spirv_op_type_int_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Type_Int) {
	/* %result_id = OpTypeInt <width> <sign> */
	_spirv_op_to_binary(_in, 4, SPIRV_OPCODE_OP_TYPE_INT);
	append(&builder, cast(Spirv_Word)base.id, op.width, cast(Spirv_Word)op.sign);
	when ODIN_DEBUG {
		fmt.sbprintfln(&_debug.builder, "%%%d = OpTypeInt %d %d", base.id, op.width, op.sign);
	}
}

spirv_op_type_pointer_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Type_Pointer) {
	/* %result_id = OpTypePointer <storage_class> %type_id */
	_spirv_op_to_binary(_in, 4, SPIRV_OPCODE_OP_TYPE_POINTER);
	append(&builder, cast(Spirv_Word)base.id, cast(Spirv_Word)op.class, cast(Spirv_Word)op.type_idx);
	when ODIN_DEBUG {
		fmt.sbprintfln(&_debug.builder, "%%%d = OpTypePointer %d %%%d", base.id, op.class, op.type_idx);
	}
}

spirv_op_type_function_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Type_Function) {
	/* %result_id = OpTypeFunction %return_type_id %param1_type_id %param2_type_id ... */
	_spirv_op_to_binary(_in, 3 + cast(Spirv_Word)len(op.params), SPIRV_OPCODE_OP_TYPE_FUNCTION);
	append(&builder, cast(Spirv_Word)base.id, cast(Spirv_Word)op.return_type_id);
	when ODIN_DEBUG {
		fmt.sbprintf(&_debug.builder, "%%%d = OpTypeFunction %%%d", base.id, op.return_type_id);
	}
	for param in op.params {
		append(&builder, cast(Spirv_Word)param.base.id);
		when ODIN_DEBUG {
			fmt.sbprintf(&_debug.builder, " %%%d", param.base.id);
		}
	}
	when ODIN_DEBUG {
		fmt.sbprintln(&_debug.builder);
	}
}

spirv_op_type_array_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Type_Array) {
	/* %result_id = OpTypeArray %element_type_id %length_id */
	_spirv_op_to_binary(_in, 4, SPIRV_OPCODE_OP_TYPE_ARRAY);
	append(&builder, cast(Spirv_Word)base.id, cast(Spirv_Word)op.element_type, cast(Spirv_Word)op.length_id);
	when ODIN_DEBUG {
		fmt.sbprintfln(&_debug.builder, "%%%d = OpTypeArray %%%d %%%d", base.id, op.element_type, op.length_id);
	}
}

_spirv_op_to_binary :: #force_inline proc(using m: ^To_Spirv_In, wc: Spirv_Word, opcode: Spirv_Word) {
	when ODIN_DEBUG {
		assert(transmute(u32)opcode & 0xFFFF0000 == 0 && transmute(u32)wc & 0x0000FFFF == transmute(u32)wc, "Invalid word count or opcode value!");
	}
	append(&builder, wc | opcode << 16);
}

spirv_op_constant_to_binary :: #force_inline proc(using _in: ^To_Spirv_In, base: Spirv_Op_Base, op: Spirv_Op_Constant) {
	/* %result_id = OpConstant %type_id %value */
	_spirv_op_to_binary(_in, 3 + op.value_width / size_of(Spirv_Word), SPIRV_OPCODE_OP_CONSTANT);
	append(&builder, cast(Spirv_Word)op.type, cast(Spirv_Word)base.id);
	if op.value_width > 4 {
		append(&builder, cast(Spirv_Word)(op.value.i >> 16), cast(Spirv_Word)op.value.i);
	} else {
		append(&builder, cast(Spirv_Word)op.value.i);
	}

	when ODIN_DEBUG {
		// NOTE(GowardSilk): this does not distinguish between float and int constants
		fmt.sbprintfln(&_debug.builder, "%%%d = OpConstant %%%d %d", base.id, op.type, op.value.i);
	}
}

Spirv_Op_Base :: struct {
	id: Spirv_SSA_Index,
}

/**
 * @brief general spirv op descriptor
 */
Spirv_Op :: struct {
	#subtype base: Spirv_Op_Base,
	op: _Spirv_Op,
}
_Spirv_Op :: union {
	Spirv_Op_Constant,
	Spirv_Op_Variable,
	Spirv_Op_Function,

	Spirv_Op_Type_Void,
	Spirv_Op_Type_Float,
	Spirv_Op_Type_Int,
	Spirv_Op_Type_Pointer,
	Spirv_Op_Type_Function,
	Spirv_Op_Type_Array,
}

Spirv_Word :: i32;
Spirv_SSA_Index :: distinct Spirv_Word;
SPIRV_SSA_INDEX_INVALID: Spirv_SSA_Index: -1;

SPIRV_OPCODE_OP_VARIABLE :: 59;
Spirv_Op_Variable :: struct {
	type_id: Spirv_SSA_Index, /**< res id of Spirv_Op_Type_Pointer */
	class: Spirv_Storage_Class,
	initializer: Spirv_SSA_Index, /**< optional, (if not used eq to SPIRV_SSA_INDEX_INVALID) */
}

SPIRV_OPCODE_OP_CONSTANT :: 43;
Spirv_Op_Constant :: struct {
	type: Spirv_SSA_Index, /**< res id of Spirv_Op_Type_* of the underlying literal type */
	value: #type struct #raw_union {
		i: i64,
		f: f64,
	},
	value_width: Spirv_Word, /**< actual width of `value' member (easier to store here than search dynamically via `type' SSA index) */
}

SPIRV_OPCODE_OP_TYPE_VOID :: 19;
Spirv_Op_Type_Void :: struct {}

Spirv_Float_Encoding :: enum {
	UNKNOWN = 0,

	IEEE754_BINARY16,  // half float
	IEEE754_BINARY32,  // single float
	IEEE754_BINARY64,  // double float
}
SPIRV_OPCODE_OP_TYPE_FLOAT :: 22;
Spirv_Op_Type_Float :: struct {
	width: Spirv_Word,
	encoding: Spirv_Float_Encoding,
}

Spirv_Op_Type_Int_Sign :: enum u8 {
	No_Sign  = 0,
	Unsigned = No_Sign,
	Signed   = 1,
}
SPIRV_OPCODE_OP_TYPE_INT :: 21;
Spirv_Op_Type_Int :: struct {
	width: Spirv_Word,
	sign:  Spirv_Op_Type_Int_Sign,
}

Spirv_Storage_Class :: enum {
	Uniform_Constant = 0, // __const
	Uniform = 2, // __global
	Workgroup = 4, // __local
	Storage_Buffer = 12, // __global
}

SPIRV_OPCODE_OP_TYPE_FORWARD_POINTER :: 39;
Spirv_Op_Type_Forward_Pointer :: struct {
	ptr_type: Spirv_SSA_Index,  /**< forward reference to the result of an Spirv_Op_Type_Pointer */
	class: Spirv_Storage_Class, /** class of memory holding the object pointed to */
}

SPIRV_OPCODE_OP_TYPE_POINTER :: 32;
Spirv_Op_Type_Pointer :: struct {
	class: Spirv_Storage_Class,
	type_idx: Spirv_SSA_Index, /**< index of Spirv_Op_Type_* containing type id of the resource pointed to */
}

SPIRV_OPCODE_OP_TYPE_FUNCTION :: 33;
Spirv_Op_Type_Function :: struct {
	return_type_id: Spirv_SSA_Index,
	params: []Spirv_Op,
}

SPIRV_OPCODE_OP_TYPE_ARRAY :: 28;
Spirv_Op_Type_Array :: struct {
	element_type: Spirv_SSA_Index,
	length_id: Spirv_SSA_Index, /**< length id of Spirv_Op_Constant */
}

Spirv_Op_Function_Control :: enum Spirv_Word {
	None   = 0x0,
	Inline = 0x1,
	DontInline = 0x2,
	Pure = 0x4,
	Const = 0x8,

	// Reserved
	OptNoneEXT   = 0x10000,
	OptNoneINTEL = 0x10000,
}
SPIRV_OPCODE_OP_FUNCTION :: 54;
Spirv_Op_Function :: struct {
	control: Spirv_Op_Function_Control,
	return_type_id: Spirv_SSA_Index,
	function_type_id: Spirv_SSA_Index,
}

update_active_node_opencl :: #force_inline proc(_in: ^To_Opencl_Lang_In, node: ast.Node) -> ^To_Opencl_Lang_In {
	_in.node = node;
	return _in;
}

update_active_node_spirv :: #force_inline proc(_in: ^To_Spirv_In, node: ast.Node, type_node: ^ast.Any_Node = nil) -> ^To_Spirv_In {
	_in.type_node = type_node;
	_in.node = node;
	return _in;
}

update_active_node :: proc {
	update_active_node_opencl,
	update_active_node_spirv,
}

init_spirv_type_table :: proc(using _in: ^To_Spirv_In) {
	_in.type_table = mem.make(map[string]Spirv_Meta_Op);
	map_insert(&type_table, "Int", Spirv_Meta_Op {
		/*
		 * NOTE(GowardSilk): SPIRV_SSA_INDEX_INVALID is going to be set to the actual index
		 * inside `ops' on the first query (aka indicating that the type will have been used)
		 */
		base = Spirv_Op_Base { SPIRV_SSA_INDEX_INVALID },
		op   = Spirv_Op_Type_Int {
			width = size_of(cl.Int),
			sign = .Signed
		}
	});
	#assert(size_of(cl.Float) == 4)
	map_insert(&type_table, "Float", Spirv_Meta_Op {
		base = Spirv_Op_Base { SPIRV_SSA_INDEX_INVALID },
		op   = Spirv_Op_Type_Float {
			width = size_of(cl.Float),
			encoding = .IEEE754_BINARY32,
		}
	});
	map_insert(&type_table, "void", Spirv_Meta_Op {
		base = Spirv_Op_Base { SPIRV_SSA_INDEX_INVALID },
		op   = Spirv_Op_Type_Void {}
	});
}

init_spirv_in :: proc(compiler: ^Compiler, active_node: ast.Node) -> (_in: To_Spirv_In, err: mem.Allocator_Error) {
	_in.compiler = compiler;
	_in.node = active_node;
	_in.builder = mem.make([dynamic]Spirv_Word) or_return;
	_in.ops = mem.make([dynamic]Spirv_Op) or_return;
	_in.next_id = SPIRV_SSA_INDEX_INVALID;
	_in.const_table = mem.make(map[string]Spirv_Op);
	init_spirv_type_table(&_in);
	when ODIN_DEBUG {
		strings.builder_init(&_in._debug.builder);
	}

	return _in, nil;
}

/** NOTE(GowardSilk): No need to delete To_Spirv_In, since we are batching the mem calls inside Compiler_Allocator */
@(disabled=true)
delete_spirv_in :: proc(_in: ^To_Spirv_In) {}

spirv_query_type :: #force_inline proc(using _in: ^To_Spirv_In, key: string) -> (Spirv_Op, bool) {
	meta_type, type_found := &type_table[key];
	if !type_found do return {}, false;
	if meta_type.base.id == SPIRV_SSA_INDEX_INVALID {
		// this meta type was not queried yet
		// assign it a new valid id
		meta_type.base.id = new_spirv_id(_in);
	}
	return cast(Spirv_Op)meta_type^, true;
}

spirv_infer_constant_type :: proc(using _in: ^To_Spirv_In) -> (Spirv_Op, bool) {
	if type_node == nil do return {}, false;

	#partial switch v in type_node {
		case ^ast.Field_Value:
			#partial switch vv in v.value.derived_expr {
				case ^ast.Ident:
					return spirv_query_type(_in, vv.name);
				case ^ast.Selector_Expr:
					assert(v.derived_expr.(^ast.Ident).name == "cl", "Types should be taken only from `cl' module!");
					return spirv_query_type(_in, vv.field.name);

				case: unimplemented();
			}
	}

	unreachable();
}

/**
 * @brief converts odin statement (`node') into SPIR-V
 */
to_spirv :: proc(using _in: ^To_Spirv_In) -> bool {
	if node.derived == nil do return true;

	switch v in node.derived {
		case ^ast.Package: unimplemented();
		case ^ast.File: unimplemented();
		case ^ast.Comment_Group: unimplemented();
		case ^ast.Bad_Expr: unimplemented();
		case ^ast.Ident: unimplemented();
		case ^ast.Implicit: unimplemented();
		case ^ast.Undef: unimplemented();
		case ^ast.Basic_Lit:
			constant: Spirv_Op_Constant;
			constant_type, found_constant_type := spirv_infer_constant_type(_in);
			if !found_constant_type {
				parser.default_error_handler(node.pos, "Failed to infer type for given basic literal (%s)!", v.tok.text);
				return false;
			}
			constant.type = constant_type.base.id;

			#partial switch v.tok.kind {
				case .Integer:
					constant.value.i = cast(i64)strconv.atoi(v.tok.text);

					when ODIN_DEBUG {
						fmt.sbprintfln(
							&_debug.builder,
							"%d = OpConstant %%%d %d",
							len(builder) + 1,
							constant.type,
							constant.value.i
						);
					}

					constant.value_width = constant_type.op.(Spirv_Op_Type_Int).width;

				case .Float:
					constant.value.f = strconv.atof(v.tok.text);

					when ODIN_DEBUG {
						fmt.sbprintfln(
							&_debug.builder,
							"%d = OpConstant %%%d %f",
							len(builder) + 1,
							constant.type,
							constant.value.f
						);
					}

					constant.value_width = constant_type.op.(Spirv_Op_Type_Float).width;

				case: unimplemented();
			}

			// NOTE(GowardSilk): since constants have to preceed all other declarations (along with type decls)
			// we plug them only inside the const_table with already valid id
			map_insert(&const_table, v.tok.text, Spirv_Op {
				base = { new_spirv_id(_in) },
				op = constant,
			});

		case ^ast.Basic_Directive: unimplemented();
		case ^ast.Ellipsis: unimplemented();
		case ^ast.Proc_Lit:
			// write procedure type
			proc_string_key: string;
			proc_string_key_builder: strings.Builder;
			strings.builder_init(&proc_string_key_builder, context.temp_allocator);
			defer strings.builder_destroy(&proc_string_key_builder);

			type_into_string :: proc(expr: ^ast.Expr) -> string {
				#partial switch v in expr.derived_expr {
					case ^ast.Ident:
						return v.name;
					case ^ast.Selector_Expr:
						return v.field.name;
					case ^ast.Multi_Pointer_Type:
						return fmt.tprintf("[^]%s", type_into_string(v.elem));
				}
				unreachable();
			}

			// insert an indentifier before the actual type (param list)
			// so that we can distinguish between <<theoretical>> cases like:
			// my_kernel :: proc() {}
			// aka
			// __kernel void my_kernel(void) {}
			// where parameters are "just" void
			strings.write_string(&proc_string_key_builder, "proc");
			arg_count := 0;
			if len(v.type.params.list) > 0 {
				/*
				 * NOTE(GowardSilk): kernels should always have return type void so we do not have to iterate over the results....
				 */
				for arg_group in v.type.params.list {
					type := type_into_string(arg_group.type);
					for arg in arg_group.names {
						strings.write_string(
							&proc_string_key_builder,
							type
						);
						arg_count += 1;
					}
				}
			} else {
				strings.write_string(&proc_string_key_builder, "void");
			}

			proc_type, proc_type_found := spirv_query_type(_in, proc_string_key);
			if !proc_type_found {
				proc_return_type, proc_return_type_found := spirv_query_type(_in, "void");
				when ODIN_DEBUG do assert(proc_return_type_found);

				proc_type_op := Spirv_Op_Type_Function {
					return_type_id = proc_return_type.base.id,
					params = make([]Spirv_Op, arg_count),
				};

				query_type :: proc(using _in: ^To_Spirv_In, e: ^ast.Expr, param: Proc_Desc_Param) -> (Spirv_Op, bool) {
					type_key: string;
					#partial switch v in e.derived_expr {
						case ^ast.Ident:
							type_key = v.name;
						case ^ast.Selector_Expr:
							type_key = v.field.name;
						case ^ast.Multi_Pointer_Type:
							type, found_type := query_type(_in, v.elem, param);
							if found_type {
								ptr_type := Spirv_Op_Type_Pointer {
									class = opencl_qualifier_to_storage_class(param.qual),
									type_idx = type.base.id,
								};
								type = auto_cast map_insert(
									&type_table,
									type_key,
									Spirv_Meta_Op {
										base = { new_spirv_id(_in) },
										op = ptr_type,
									}
								)^;
							}
							// if base type was not found, report error
						case ^ast.Pointer_Type: unimplemented();
						case ^ast.Struct_Type: unimplemented();
					}
					p_type, p_type_found := spirv_query_type(_in, type_key);
					if !p_type_found {
						parser.default_error_handler(
							e.pos, "Failed to query base type"
						);
						return {}, false;
					}
					return p_type, true;
				}

				arg_index := 0;
				for arg_group in v.type.params.list {
					param_name := arg_group.names[0].derived_expr.(^ast.Ident).name;
					type := query_type(_in, arg_group.type, active_proc.params[param_name]) or_return;
					for arg in arg_group.names {
						proc_type_op.params[arg_index] = type;
						arg_index += 1;
					}
				}

				proc_type_meta_op := Spirv_Meta_Op {
					base = {
						id = new_spirv_id(_in),
					},
					op = proc_type_op,
				};
				proc_type = auto_cast map_insert(
					&type_table,
					proc_string_key,
					proc_type_meta_op
				)^;
			}

			func_type_op := proc_type.op.(Spirv_Op_Type_Function);
			push_spirv_op(_in, Spirv_Op_Function {
				control = .None,
				return_type_id = func_type_op.return_type_id,
				function_type_id = proc_type.base.id,
			});

		case ^ast.Comp_Lit: unimplemented();
		case ^ast.Tag_Expr: unimplemented();
		case ^ast.Unary_Expr: unimplemented();
		case ^ast.Binary_Expr: unimplemented();
		case ^ast.Paren_Expr: unimplemented();
		case ^ast.Selector_Expr: unimplemented();
		case ^ast.Implicit_Selector_Expr: unimplemented();
		case ^ast.Selector_Call_Expr: unimplemented();
		case ^ast.Index_Expr: unimplemented();
		case ^ast.Deref_Expr: unimplemented();
		case ^ast.Slice_Expr: unimplemented();
		case ^ast.Matrix_Index_Expr: unimplemented();
		case ^ast.Call_Expr:
			selector, is_selector := v.expr.derived_expr.(^ast.Selector_Expr);
			ident: ^ast.Ident;
			if is_selector do ident = selector.field;
			else do ident, _ = v.expr.derived_expr.(^ast.Ident);

			//builtin_kernel := _in.compiler.proc_table[ident];

			for arg, arg_idx in v.args {
				to_spirv(update_active_node(_in, arg.expr_base, &arg.derived));
			}

			return true;

		case ^ast.Field_Value: unimplemented();
		case ^ast.Ternary_If_Expr: unimplemented();
		case ^ast.Ternary_When_Expr: unimplemented();
		case ^ast.Or_Else_Expr: unimplemented();
		case ^ast.Or_Return_Expr: unimplemented();
		case ^ast.Or_Branch_Expr: unimplemented();
		case ^ast.Type_Assertion: unimplemented();
		case ^ast.Type_Cast: unimplemented();
		case ^ast.Auto_Cast: unimplemented();
		case ^ast.Inline_Asm_Expr: unimplemented();
		case ^ast.Proc_Group: unimplemented();
		case ^ast.Typeid_Type: unimplemented();
		case ^ast.Helper_Type: unimplemented();
		case ^ast.Distinct_Type: unimplemented();
		case ^ast.Poly_Type: unimplemented();
		case ^ast.Proc_Type: unimplemented();
		case ^ast.Pointer_Type: unimplemented();
		case ^ast.Multi_Pointer_Type: unimplemented();
		case ^ast.Array_Type: unimplemented();
		case ^ast.Dynamic_Array_Type: unimplemented();
		case ^ast.Struct_Type: unimplemented();
		case ^ast.Union_Type: unimplemented();
		case ^ast.Enum_Type: unimplemented();
		case ^ast.Bit_Set_Type: unimplemented();
		case ^ast.Map_Type: unimplemented();
		case ^ast.Relative_Type: unimplemented();
		case ^ast.Matrix_Type: unimplemented();
		case ^ast.Bit_Field_Type: unimplemented();
		case ^ast.Bad_Stmt: unimplemented();
		case ^ast.Empty_Stmt: unimplemented();
		case ^ast.Expr_Stmt: unimplemented();
		case ^ast.Tag_Stmt: unimplemented();
		case ^ast.Assign_Stmt: unimplemented();
		case ^ast.Block_Stmt: unimplemented();
		case ^ast.If_Stmt: unimplemented();
		case ^ast.When_Stmt: unimplemented();
		case ^ast.Return_Stmt: unimplemented();
		case ^ast.Defer_Stmt: unimplemented();
		case ^ast.For_Stmt: unimplemented();
		case ^ast.Range_Stmt: unimplemented();
		case ^ast.Inline_Range_Stmt: unimplemented();
		case ^ast.Case_Clause: unimplemented();
		case ^ast.Switch_Stmt: unimplemented();
		case ^ast.Type_Switch_Stmt: unimplemented();
		case ^ast.Branch_Stmt: unimplemented();
		case ^ast.Using_Stmt: unimplemented();
		case ^ast.Bad_Decl: unimplemented();
		case ^ast.Value_Decl: unimplemented();
		case ^ast.Package_Decl: unimplemented();
		case ^ast.Import_Decl: unimplemented();
		case ^ast.Foreign_Block_Decl: unimplemented();
		case ^ast.Foreign_Import_Decl: unimplemented();
		case ^ast.Attribute: unimplemented();
		case ^ast.Field: unimplemented();
		case ^ast.Field_List: unimplemented();
		case ^ast.Bit_Field_Field: unimplemented();
	}
	return false;
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
