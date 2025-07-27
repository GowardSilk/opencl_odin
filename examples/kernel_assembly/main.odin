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
	parser: parser.Parser,
	kernels: map[string]cl.Kernel
}

init_compiler :: proc(allocator := context.allocator) -> Compiler {
	p := parser.default_parser({.Optional_Semicolons});
	k := mem.make(map[string]cl.Kernel, allocator);
	return Compiler { p, k };
}

delete_compiler :: proc(using compiler: ^Compiler) {
	if kernels != nil {
		for _, kernel in kernels do cl.ReleaseKernel(kernel);
		delete(kernels);
	}
}

OpenCL_Attribute :: distinct string; 
OpenCL_Attribute_Invalid :: "";
OpenCL_Attribute_Const 	 :: "__const";
OpenCL_Attribute_Global	 :: "__global";
OpenCL_Attribute_Local	 :: "__local";

Proc_Desc_Param :: struct {
	name: string,
	attr: OpenCL_Attribute,
}

Proc_Desc :: struct {
	attributes: []^ast.Attribute,
	proc_lit:   ^ast.Proc_Lit,
	proc_name:  string,
	params: 	map[string]Proc_Desc_Param,
}
PROC_DESC_INVALID := Proc_Desc { nil, nil, "", nil }

compile_kernels :: proc(compiler: ^Compiler, cl_context: ^OpenCL_Context, file_name := "kernel_assembly/my_kernels/kernel.odin") {
	data, ok := os.read_entire_file_from_filename(file_name);
	if !ok {
		fmt.eprintln("Failed to read file!");
		return;
	}
	defer delete(data);

	ast_file: ast.File;
	ast_file.src = cast(string)data;

	if !parser.parse_file(&compiler.parser, &ast_file) {
		fmt.eprintln("Grammatical parsing error(s)!");
		return;
	}

	is_proc_lit :: #force_inline proc(any_stmt: ^ast.Any_Stmt) -> Proc_Desc {
		val_decl, is_val_decl := any_stmt.(^ast.Value_Decl);
		if is_val_decl {
			if len(val_decl.values) > 0 {
				proc_lit, is_proc_lit := val_decl.values[0].derived_expr.(^ast.Proc_Lit);
				if is_proc_lit {
					return Proc_Desc {
						val_decl.attributes[:],
						proc_lit,
						val_decl.names[0].derived_expr.(^ast.Ident).name,
						nil,
					};
				}
			}
		}
		return PROC_DESC_INVALID;
	}

	is_kernel_proc :: #force_inline proc(any_stmt: ^ast.Any_Stmt) -> Proc_Desc {
		proc_desc := is_proc_lit(any_stmt);
		if proc_desc.proc_lit != nil {
			// check if function is "__kernel"
			contains_kernel_attr := false;
			for attr in proc_desc.attributes {
				attr_expr := attr.elems[0];
				if _, ok := attr_expr.derived.(^ast.Field_Value); ok do continue;
				attr_name := attr_expr.derived.(^ast.Ident).name;
				if attr_name == "kernel" {
					contains_kernel_attr = true;
					break;
				}
			}
			if !contains_kernel_attr {
				parser.default_warning_handler(proc_desc.proc_lit.pos, "Did not find @(kernel) attribute!");
				return PROC_DESC_INVALID;
			}

			proc_desc.params = make(map[string]Proc_Desc_Param);
			for param in proc_desc.proc_lit.type.params.list {
				for param_name_expr in param.names {
					param_name := param_name_expr.derived_expr.(^ast.Ident).name;
					// const by default
					map_insert(
						&proc_desc.params,
						param_name,
						Proc_Desc_Param {param_name, OpenCL_Attribute_Const}
					);
				}
			}
			contains_param_attr := false;
			for attr in proc_desc.attributes {
				attr_expr, is_attr_expr := attr.elems[0].derived.(^ast.Field_Value);
				if !is_attr_expr {
					delete(proc_desc.params);
					return PROC_DESC_INVALID;
				}
				attr_name := attr_expr.field.derived_expr.(^ast.Ident).name;
				if attr_name == "params" {
					params_val := attr_expr.derived.(^ast.Field_Value).value.derived_expr;
					if !extract_kernel_proc_param_attributes(&proc_desc.params, params_val) {
						delete(proc_desc.params);
						return PROC_DESC_INVALID;
					}
					contains_param_attr = true;
				}
			}
			// other attributes (Odin's) are ignored since they have no real use in cl
			if !contains_param_attr && len(proc_desc.attributes) > 2 {
				parser.default_warning_handler(proc_desc.proc_lit.pos, "Odin's attributes ignored!");
			}
			return proc_desc;
		}
		return PROC_DESC_INVALID;
	}

	kernel_string_builder: strings.Builder;
	assert(strings.builder_init(&kernel_string_builder) != nil);
	defer strings.builder_destroy(&kernel_string_builder);
	decl_loop: for stmt in ast_file.decls do if proc_desc := is_kernel_proc(&stmt.derived_stmt); proc_desc.proc_lit != nil {
		defer strings.builder_reset(&kernel_string_builder);
		using proc_desc;

		parameters, body: string;

		if proc_lit.type.results != nil {
			parser.default_error_handler(proc_lit.type.results.list[0].pos, "OpenCL prohibits __kernel functions to have non-void return type! Skipping this kernel...");
			continue;
		}

		for param, index in proc_lit.type.params.list {
			strings.write_string(&kernel_string_builder, auto_cast params[param.names[0].derived_expr.(^ast.Ident).name].attr);
			if !to_opencl_lang(&compiler.parser, &kernel_string_builder, &param.node) do continue decl_loop;
			if index < len(proc_lit.type.params.list) - 1 {
				strings.write_string(&kernel_string_builder, ", ");
			}
		}
		parameters = strings.clone(strings.to_string(kernel_string_builder));
		strings.builder_reset(&kernel_string_builder);

		body_block := proc_lit.body.derived.(^ast.Block_Stmt);
		for stmt in body_block.stmts {
			if !to_opencl_lang(&compiler.parser, &kernel_string_builder, &stmt.stmt_base) do continue decl_loop;
		}
		body = strings.clone(strings.to_string(kernel_string_builder));
		strings.builder_reset(&kernel_string_builder);

		fmt.eprintln(fmt.sbprintf(&kernel_string_builder, "__kernel void %s(%s) {{\n%s}}", proc_name, parameters, body));
	}
	
	return;
}

extract_kernel_proc_param_attributes :: proc(params: ^map[string]Proc_Desc_Param, param_val_expr: ast.Any_Expr) -> bool {
	comp_lit, is_comp_lit := param_val_expr.(^ast.Comp_Lit);
	if !is_comp_lit do return false;

	to_opencl_attr_from_string :: #force_inline proc(attr: string) -> OpenCL_Attribute {
		switch attr {
			case "\"global\"", "\"__global\"":
				return OpenCL_Attribute_Global;
			case "\"local\"", "\"__local\"":
				return OpenCL_Attribute_Local;
			case "\"const\"", "\"__const\"":
				return OpenCL_Attribute_Const;
			case:
				return OpenCL_Attribute_Invalid;
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
		param^.attr = to_opencl_attr_from_string(attr_val.tok.text);
	}

	return true;
}

err_return :: #force_inline proc(node: ^ast.Node, msg: string, args: ..any) -> bool {
	parser.default_error_handler(node.pos, msg, ..args);
	return false;
}

to_opencl_lang :: proc(p: ^parser.Parser, builder: ^strings.Builder, node: ^ast.Node) -> bool {
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
			return to_opencl_lang(p, builder, &v.expr_base);
		case ^ast.Binary_Expr:
			to_opencl_lang(p, builder, &v.left.expr_base) or_return;
			fmt.sbprintf(builder, " %s ", v.op.text);
			return to_opencl_lang(p, builder, &v.right.expr_base);
		case ^ast.Paren_Expr:
			assert(false, "TODO");
			fmt.sbprintfln(builder, "(");
		case ^ast.Index_Expr:
			to_opencl_lang(p, builder, &v.expr.expr_base) or_return;
			strings.write_byte(builder, '[');
			to_opencl_lang(p, builder, &v.index.expr_base) or_return;
			strings.write_byte(builder, ']');
		case ^ast.Call_Expr:
			selector, ok := v.expr.derived_expr.(^ast.Selector_Expr);
			ident: ^ast.Ident;
			if ok do ident = selector.field;
			else do ident, _ = v.expr.derived_expr.(^ast.Ident);
			strings.write_string(builder, ident.name);
			strings.write_byte(builder, '(');
			for arg in v.args do to_opencl_lang(p, builder, arg) or_return;
			strings.write_byte(builder, ')');
		case ^ast.Deref_Expr:
			strings.write_byte(builder, '*');
			return to_opencl_lang(p, builder, &v.expr.expr_base);
		case ^ast.Slice_Expr:
			// slice is "just" a pointer
			strings.write_byte(builder, '[');
			to_opencl_lang(p, builder, &v.low.expr_base) or_return;
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
			return to_opencl_lang_selector(p, builder, v);
		case ^ast.Tag_Expr:
			return err_return(&v.expr_base, "TODO tag: Not yet implemented");

		// Statements
		case ^ast.Assign_Stmt:
			strings.write_byte(builder, '\t');
			to_opencl_lang(p, builder, &v.lhs[0].expr_base) or_return;
			fmt.sbprintf(builder, " %s ", v.op.text);
			to_opencl_lang(p, builder, &v.rhs[0].expr_base) or_return;
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
			return to_opencl_lang_ptr(p, builder, v);
		case ^ast.Multi_Pointer_Type:
			return to_opencl_lang_multi_ptr(p, builder, v);
		case ^ast.Array_Type:
			fmt.sbprintfln(builder, "type[size]");
			return err_return(&v.expr_base, "TODO arr: Not yet implemented");
		case ^ast.Struct_Type:
			for field in v.fields.list {
				to_opencl_lang(p, builder, &field.node) or_return;
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
			return to_opencl_lang(p, builder, &v.type.expr_base);

		// Declarations
		case ^ast.Value_Decl:
			type: string;
			if v.type == nil {
				type = query_type_from_value_decl(p, v);
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
				if v.type != nil {
					fmt.sbprintf(builder, "\t%s %s = ", v.type.derived_expr.(^ast.Ident).name, val_ident.name);
				} else do return err_return(&v.names[index].expr_base, "Failed to infer type for %v value declaration", v);
				to_opencl_lang(p, builder, &val.expr_base) or_return;
				strings.write_string(builder, ";\n");
			}
		case ^ast.Field:
			for name, index in v.names {
				to_opencl_lang(p, builder, &v.type.expr_base) or_return;
				strings.write_byte(builder, ' ');
				to_opencl_lang(p, builder, &name.expr_base) or_return;
				if index < len(v.names) - 1 {
					strings.write_string(builder, ", ");
				}
			}
		case ^ast.Field_List:
			for field, index in v.list {
				to_opencl_lang(p, builder, &field.node) or_return;
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

Visit_Input :: struct {
	name: string,
	type: string,
}
query_type_from_value_decl_grab_proc_ret_type :: #force_inline proc(visitor: ^ast.Visitor, v: ^ast.Value_Decl, proc_type: ^ast.Proc_Type) -> ^ast.Visitor {
	visit_input := cast(^Visit_Input)visitor.data;
	if visit_input.name == v.names[0].derived_expr.(^ast.Ident).name {
		if len(proc_type.results.list) != 1 {
			parser.default_error_handler(
				proc_type.pos,
				"Multiple return types not supported, use struct",
			);
		} else {
			visit_input.type = proc_type.results.list[0].type.derived_expr.(^ast.Ident).name;
		}
		return nil;
	}
	return visitor;
}

query_type_from_value_decl_visit_proc :: proc(visitor: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
	// check for Value_Decl declaring/defining functions
	#partial switch v in node.derived {
		case ^ast.Value_Decl:
			#partial switch vv in v.type.derived_expr {
				case ^ast.Proc_Lit:
					return query_type_from_value_decl_grab_proc_ret_type(visitor, v, vv.type);
				case ^ast.Helper_Type:
					proc_type, is_proc_type := vv.type.derived_expr.(^ast.Proc_Type);
					if is_proc_type {
						return query_type_from_value_decl_grab_proc_ret_type(visitor, v, proc_type);
					}
				case ^ast.Proc_Type:
					return query_type_from_value_decl_grab_proc_ret_type(visitor, v, vv);
			}
		case: return visitor;
	}
	unreachable();
}

query_type_from_value_decl :: #force_inline proc(p: ^parser.Parser, val: ^ast.Value_Decl) -> string {
	if len(val.values) <= 0 do return "";
	#partial switch v in val.values[0].derived_expr {
		case ^ast.Call_Expr:
			name := v.expr.derived_expr.(^ast.Ident).name;
			visit_input := Visit_Input {
				name, ""
			}
			visitor := ast.Visitor {
				query_type_from_value_decl_visit_proc,
				&visit_input,
			};
			ast.walk(&visitor, &p.file.decls[0].stmt_base);
			return visit_input.type;
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

to_opencl_lang_selector :: #force_inline proc(p: ^parser.Parser, builder: ^strings.Builder, selector: ^ast.Selector_Expr) -> bool {
	// NOTE(GowardSilk): For a type, selector expr means having a specific package being accessed
	name := selector.expr.derived_expr.(^ast.Ident).name;
	if name == "cl" {
		// NOTE(GowardSilk): Assuming cl and c are package names... not particularly great though???
		strings.write_byte(builder, selector.field.name[0] | 32);
		strings.write_string(builder, selector.field.name[1:]);
	} else if name == "c" {
		strings.write_string(builder, selector.field.name)
	} else {
		to_opencl_lang(p, builder, &selector.expr.expr_base) or_return;
		strings.write_string(builder, selector.op.text);
		strings.write_string(builder, selector.field.name);
	}
	return true;
}

to_opencl_lang_ptr :: #force_inline proc(p: ^parser.Parser, builder: ^strings.Builder, ptr: ^ast.Pointer_Type) -> bool {
	return to_opencl_lang_ptr_base(p, builder, ptr.elem);
}
to_opencl_lang_multi_ptr :: #force_inline proc(p: ^parser.Parser, builder: ^strings.Builder, ptr: ^ast.Multi_Pointer_Type) -> bool {
	return to_opencl_lang_ptr_base(p, builder, ptr.elem);
}
to_opencl_lang_ptr_base :: #force_inline proc(p: ^parser.Parser, builder: ^strings.Builder, base: ^ast.Expr) -> bool {
	#partial switch v in base.derived_expr {
		case ^ast.Selector_Expr:
			to_opencl_lang_selector(p, builder, v) or_return;
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
