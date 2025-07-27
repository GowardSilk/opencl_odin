package ka;

import "core:os"
import "core:fmt"
import "core:mem"
import "core:strings"
import "core:odin/parser"
import "core:odin/ast"

import cl "shared:opencl"

OpenCL_Context :: struct {
    platform:   cl.Platform_ID,
    device:     cl.Device_ID,
    _context:   cl.Context,
    program:    cl.Program,
    queue:      cl.Command_Queue,
}

Compiler :: struct {
	/**
	 * table of all procedures (key <=> proc_name)
	 * only for Proc_Kind.Builtin, Proc_Desc.params != nil
	 */
	proc_table:	map[string]Proc_Desc,
	kernels:	map[string]cl.Kernel, /**< compiled kernels */
}

init_compiler :: proc(allocator := context.allocator) -> Compiler {
	k  := mem.make(map[string]cl.Kernel, allocator);
	ki := mem.make(map[string]Proc_Desc, allocator);
	return Compiler { ki, k };
}

delete_compiler :: proc(using compiler: ^Compiler) {
	if proc_table != nil do mem.delete(proc_table);
	if kernels != nil {
		for _, kernel in kernels do cl.ReleaseKernel(kernel);
		mem.delete(kernels);
	}
}

OpenCL_Qualifier :: distinct string; 
OpenCL_Qualifier_Invalid :: "";
OpenCL_Qualifier_Const 	 :: "__const";
OpenCL_Qualifier_Global	 :: "__global";
OpenCL_Qualifier_Local	 :: "__local";

Proc_Desc_Param :: struct {
	name: string,
	qual: OpenCL_Qualifier,
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
}
PROC_DESC_INVALID := Proc_Desc { nil, nil, "", nil, .Default };

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
					val_decl.attributes[:],
					proc_lit,
					val_decl.names[0].derived_expr.(^ast.Ident).name,
					nil,
					.Default,
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
	proc_desc.params = make(map[string]Proc_Desc_Param);
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

compile_kernels :: proc(compiler: ^Compiler, cl_context: ^OpenCL_Context, package_path := "kernel_assembly/my_kernels") {
	pckg, ok := parser.parse_package_from_path(package_path);
	assert(ok);

	// register all the functions into a table
	for _, file in pckg.files {
		proc_desc: Proc_Desc;
		for stmt in file.decls do if is_valid_proc(&stmt.derived_stmt, &proc_desc) {
			map_insert(&compiler.proc_table, proc_desc.name, proc_desc);
		}
	}
	
	kernel_string_builder: strings.Builder;
	assert(strings.builder_init(&kernel_string_builder) != nil);
	defer strings.builder_destroy(&kernel_string_builder);

	decl_loop: for _, proc_desc in compiler.proc_table do if proc_desc.kind == .Kernel {
		defer strings.builder_reset(&kernel_string_builder);
		using proc_desc;

		parameters, body: string;

		// assemble parameter list
		for param, index in lit.type.params.list {
			qual := params[param.names[0].derived_expr.(^ast.Ident).name].qual;
			strings.write_string(&kernel_string_builder, cast(string)qual);
			strings.write_byte(&kernel_string_builder, ' ');

			if !to_opencl_lang(compiler, &kernel_string_builder, &param.node) do continue decl_loop;

			if index < len(lit.type.params.list) - 1 {
				strings.write_string(&kernel_string_builder, ", ");
			}
		}
		parameters = strings.clone(strings.to_string(kernel_string_builder));
		defer delete(parameters);
		strings.builder_reset(&kernel_string_builder);

		// assemble kernel body
		body_block := lit.body.derived.(^ast.Block_Stmt);
		for stmt in body_block.stmts {
			if !to_opencl_lang(compiler, &kernel_string_builder, &stmt.stmt_base) do continue decl_loop;
		}
		body = strings.clone(strings.to_string(kernel_string_builder));
		defer delete(body);
		strings.builder_reset(&kernel_string_builder);

		fmt.eprintln(fmt.sbprintf(&kernel_string_builder, "__kernel void %s(%s) {{\n%s}}", name, parameters, body));
	}
	
	return;
}

err_return :: #force_inline proc(node: ^ast.Node, msg: string, args: ..any) -> bool {
	parser.default_error_handler(node.pos, msg, ..args);
	return false;
}

to_opencl_lang :: proc(using compiler: ^Compiler, builder: ^strings.Builder, node: ^ast.Node) -> bool {
	if node == nil do return true;

	#partial switch v in node^.derived {
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
			return to_opencl_lang(compiler, builder, &v.expr_base);
		case ^ast.Binary_Expr:
			to_opencl_lang(compiler, builder, &v.left.expr_base) or_return;
			fmt.sbprintf(builder, " %s ", v.op.text);
			return to_opencl_lang(compiler, builder, &v.right.expr_base);
		case ^ast.Paren_Expr:
			strings.write_byte(builder, '(');
			to_opencl_lang(compiler, builder, &v.expr.expr_base) or_return;
			strings.write_byte(builder, ')');
		case ^ast.Index_Expr:
			to_opencl_lang(compiler, builder, &v.expr.expr_base) or_return;
			strings.write_byte(builder, '[');
			to_opencl_lang(compiler, builder, &v.index.expr_base) or_return;
			strings.write_byte(builder, ']');
		case ^ast.Call_Expr:
			selector, ok := v.expr.derived_expr.(^ast.Selector_Expr);
			ident: ^ast.Ident;
			if ok do ident = selector.field;
			else do ident, _ = v.expr.derived_expr.(^ast.Ident);
			strings.write_string(builder, ident.name);
			strings.write_byte(builder, '(');
			for arg in v.args do to_opencl_lang(compiler, builder, arg) or_return;
			strings.write_byte(builder, ')');
		case ^ast.Deref_Expr:
			strings.write_byte(builder, '*');
			return to_opencl_lang(compiler, builder, &v.expr.expr_base);
		case ^ast.Slice_Expr:
			// slice is "just" a pointer
			strings.write_byte(builder, '[');
			to_opencl_lang(compiler, builder, &v.low.expr_base) or_return;
			if v.high != nil {
				parser.default_warning_handler(
					v.high.pos,
					"Slicing cannot be emulated to OpenCL 1:1, so the upper boundary will be ignored!"
				);
			}
		case ^ast.Type_Cast:
			fmt.sbprintfln(builder, "(%s)", v.tok.text);
		case ^ast.Ternary_If_Expr:
			return err_return(&v.expr_base, "TODO ternary: Not yet implemented");
		case ^ast.Selector_Expr:
			return to_opencl_lang_selector(compiler, builder, v);
		case ^ast.Tag_Expr:
			return err_return(&v.expr_base, "TODO tag: Not yet implemented");

		// Statements
		case ^ast.Assign_Stmt:
			strings.write_byte(builder, '\t');
			to_opencl_lang(compiler, builder, &v.lhs[0].expr_base) or_return;
			fmt.sbprintf(builder, " %s ", v.op.text);
			to_opencl_lang(compiler, builder, &v.rhs[0].expr_base) or_return;
			strings.write_string(builder, ";\n");
		case ^ast.Expr_Stmt:
			fmt.eprintfln("Expr Stmt: %v", v);
			return err_return(&v.stmt_base, "TODO expr: Not yet implemented");
		case ^ast.Block_Stmt:
			return err_return(&v.stmt_base, "TODO block: Not yet implemented");
		case ^ast.If_Stmt:
			return err_return(&v.stmt_base, "TODO if: Not yet implemented");
		case ^ast.For_Stmt:
			return err_return(&v.stmt_base, "TODO for: Not yet implemented");
		case ^ast.Range_Stmt:
			return err_return(&v.stmt_base, "TODO range: Not yet implemented");
		case ^ast.Unroll_Range_Stmt:
			return err_return(&v.stmt_base, "TODO unroll: Not yet implemented");
		case ^ast.Return_Stmt:
			return err_return(&v.stmt_base, "TODO return: Not yet implemented");
		case ^ast.Switch_Stmt:
			return err_return(&v.stmt_base, "TODO switch: Not yet implemented");
		case ^ast.Case_Clause:
			return err_return(&v.stmt_base, "TODO case: Not yet implemented");
		case ^ast.Branch_Stmt:
			return err_return(&v.stmt_base, "TODO branch: Not yet implemented");

		// Types
		case ^ast.Pointer_Type:
			return to_opencl_lang_ptr(compiler, builder, v);
		case ^ast.Multi_Pointer_Type:
			return to_opencl_lang_multi_ptr(compiler, builder, v);
		case ^ast.Array_Type:
			fmt.sbprintfln(builder, "type[size]");
			return err_return(&v.expr_base, "TODO arr: Not yet implemented");
		case ^ast.Struct_Type:
			for field in v.fields.list {
				to_opencl_lang(compiler, builder, &field.node) or_return;
			}
		case ^ast.Union_Type:
			fmt.sbprintfln(builder, "union { ... }");
			return err_return(&v.expr_base, "TODO union: Not yet implemented");
		case ^ast.Enum_Type:
			fmt.sbprintfln(builder, "enum { ... }");
			return err_return(&v.expr_base, "TODO enum: Not yet implemented");
		case ^ast.Matrix_Type:
			fmt.sbprintfln(builder, "type[row][col]");
			return err_return(&v.expr_base, "TODO matrix: Not yet implemented");
		case ^ast.Helper_Type:
			return to_opencl_lang(compiler, builder, &v.type.expr_base);

		// Declarations
		case ^ast.Value_Decl:
			type: string;
			if v.type == nil {
				type = query_type_from_value_decl(compiler, v);
				if type == "" {
					return err_return(
						&v.names[0].expr_base,
						"Failed to infer type for %v value declaration",
						v
					);
				}
			} else {
				type = v.type.derived_expr.(^ast.Ident).name;
			}
			for val, index in v.values {
				val_ident, is_val_ident := v.names[index].derived.(^ast.Ident);
				if !is_val_ident do return err_return(&v.names[index].expr_base, "Expected identifier, got: %v", v.names[index].expr_base);
				fmt.sbprintf(builder, "\t%s %s = ", type, val_ident.name);
				to_opencl_lang(compiler, builder, &val.expr_base) or_return;
				strings.write_string(builder, ";\n");
			}
		case ^ast.Field:
			for name, index in v.names {
				to_opencl_lang(compiler, builder, &v.type.expr_base) or_return;
				strings.write_byte(builder, ' ');
				to_opencl_lang(compiler, builder, &name.expr_base) or_return;
				if index < len(v.names) - 1 {
					strings.write_string(builder, ", ");
				}
			}
		case ^ast.Field_List:
			for field, index in v.list {
				to_opencl_lang(compiler, builder, &field.node) or_return;
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

query_type_from_value_decl_grab_proc_ret_type :: #force_inline proc(proc_type: ^ast.Proc_Type) -> string {
	if len(proc_type.results.list) != 1 {
		parser.default_error_handler(
			proc_type.pos,
			"Multiple return types not supported, use struct",
		);
		return "";
	}

	selector, is_selector := proc_type.results.list[0].type.derived_expr.(^ast.Selector_Expr);
	if is_selector {
		return selector.field.name;
	}
	ident, is_ident := proc_type.results.list[0].type.derived_expr.(^ast.Ident);
	if is_ident {
		return ident.name;
	}

	return "";
}

query_type_from_value_decl :: #force_inline proc(compiler: ^Compiler, val: ^ast.Value_Decl) -> string {
	if len(val.values) <= 0 do return "";
	#partial switch v in val.values[0].derived_expr {
		case ^ast.Call_Expr:
			name := v.expr.derived_expr.(^ast.Ident).name;
			_proc, ok := compiler.proc_table[name];
			if ok {
				return query_type_from_value_decl_grab_proc_ret_type(_proc.lit.type);
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
		case:
			parser.default_error_handler(
				val.pos,
				"Unsupported stmt type in valeu declaration! %v",
				v
			);
			return "";
	}

	unreachable();
}

Odin_Opencl_Type_Mapping :: struct {
	odin, opencl: string
}
OPENCL_BASE_TYPES :: [?]Odin_Opencl_Type_Mapping {
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

generate_opencl_type_map :: proc() -> map[string]string {
	vector_sizes :: [?]int { 2, 4, 8 };

	builder: strings.Builder;
	strings.builder_init(&builder);
	defer strings.builder_destroy(&builder);

	types := make(map[string]string);

	for base_odin_type, cl_base in OPENCL_BASE_TYPES {
		for size in vector_sizes {
			//key := "[${size}]${base_odin_type}"
			//val := "${cl_base}${size}"
			fmt.sbprintf(&builder, "[%d]%s", size, base_odin_type);
			val := map_insert(&types, strings.to_string(builder), "");
			strings.builder_reset(&builder);
			fmt.sbprintf(&builder, "%d%s", cl_base, size);
			val^ = strings.to_string(builder);
			strings.builder_reset(&builder);
		}
	}

	return types;
}

to_opencl_lang_selector :: #force_inline proc(compiler: ^Compiler, builder: ^strings.Builder, selector: ^ast.Selector_Expr) -> bool {
	// NOTE(GowardSilk): For a type, selector expr means having a specific package being accessed
	name := selector.expr.derived_expr.(^ast.Ident).name;
	if name == "cl" {
		// NOTE(GowardSilk): Assuming cl and c are package names... not particularly great though???
		strings.write_byte(builder, selector.field.name[0] | 32);
		strings.write_string(builder, selector.field.name[1:]);
	} else if name == "c" {
		strings.write_string(builder, selector.field.name)
	} else {
		to_opencl_lang(compiler, builder, &selector.expr.expr_base) or_return;
		strings.write_string(builder, selector.op.text);
		strings.write_string(builder, selector.field.name);
	}
	return true;
}

to_opencl_lang_ptr :: #force_inline proc(compiler: ^Compiler, builder: ^strings.Builder, ptr: ^ast.Pointer_Type) -> bool {
	return to_opencl_lang_ptr_base(compiler, builder, ptr.elem);
}
to_opencl_lang_multi_ptr :: #force_inline proc(compiler: ^Compiler, builder: ^strings.Builder, ptr: ^ast.Multi_Pointer_Type) -> bool {
	return to_opencl_lang_ptr_base(compiler, builder, ptr.elem);
}
to_opencl_lang_ptr_base :: #force_inline proc(compiler: ^Compiler, builder: ^strings.Builder, base: ^ast.Expr) -> bool {
	#partial switch v in base.derived_expr {
		case ^ast.Selector_Expr:
			to_opencl_lang_selector(compiler, builder, v) or_return;
			strings.write_byte(builder, '*');
		case:
			return err_return(&base.expr_base, "Unsupported: %v", v);
	}
	return true;
}

init_cl_context :: proc() -> OpenCL_Context {
	return OpenCL_Context {};
}

delete_cl_context :: proc(cl_context: ^OpenCL_Context) {
}

main :: proc() {
	cl_context := init_cl_context();
	defer delete_cl_context(&cl_context);

	compiler := init_compiler();
	defer delete_compiler(&compiler);

	compile_kernels(&compiler, &cl_context);
}
