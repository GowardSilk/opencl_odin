package playground;

import "base:intrinsics"

import "core:c/libc"
import "core:math"

my_kernel :: proc "cdecl" (x_ptr: rawptr) -> rawptr {
	x := cast(^int)x_ptr;
	ret := cast(^int)libc.malloc(size_of(int));
	if ret == nil do return nil;
	ret^ = 10 * x^;
	return ret;
}

pi :: proc "cdecl" (y_ptr: rawptr) -> rawptr {
	y := cast(cstring)y_ptr;
	ret := cast(^f64)libc.malloc(size_of(int));
	if ret == nil do return nil;
	if y == "PI" {
		ret^ = math.PI;
		return ret;
	}
	ret^ = 0;
	return ret;
}

launcher :: proc($Proc: $Proc_T, _proc_arg: rawptr) -> rawptr
	where intrinsics.type_is_proc(Proc_T) {
	return Proc(_proc_arg);
}

launcher2 :: proc(mem: ^$T) -> rawptr {
	when intrinsics.type_is_slice(T) || intrinsics.type_is_dynamic_array(T) {
		return raw_data(^mem);
	} else {
		return mem;
	}
}

main :: proc() {
	my_kernel_arg := 5;
	pi_arg: cstring = "PI";

	my_kernel_res := launcher(my_kernel, &my_kernel_arg);
	pi_res := launcher(pi, cast(rawptr)pi_arg);

	assert((cast(^int)my_kernel_res)^ == 50);
	assert((cast(^f64)pi_res)^ == math.PI);

	libc.free(my_kernel_res);
	libc.free(pi_res);
}
