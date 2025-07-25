package my_kernels;

import c  "core:c"
import cl "shared:opencl"

/**
 * Odin's version of basic/test_program.cl, this should be fed to the "custom" odin parser and from there generate a CL kernel
 * using @(kernel) for every kernel funciton.
 * NOTE(GowardSilk): This file is technically non-compileable by normal odin's compiler because of some tricks...
 *
 * Each function called inside the kernel should be either known (OpenCL language builtin)
 * or another normal function from this file which will be automatically inlined (as clc does).
 *
 * Using #global or #local as custom tags for indicating the type of the parameter for opencl (#global <=> __global ... )
 * in case of __const, every non-pointer parameter is automatically __const
 */

@(kernel)
my_kernel :: proc "cdecl" (y: c.int, input: [^]cl.Float, output: [^]cl.Float, scale: /* __const */ cl.Float) {
	id := get_global_id(0);
	output[id] = input[id] * scale;
}
