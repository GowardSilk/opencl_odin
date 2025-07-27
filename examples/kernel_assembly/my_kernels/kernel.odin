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
 */

get_global_id: #type proc(_: int) -> int;

@(kernel)
@(params={input="global", output="global"})
my_kernel :: proc(input: [^]cl.Float, output: [^]cl.Float, scale: /* __const */ cl.Float) {
	id := get_global_id(0);
	output[id] = input[id] * scale;
}

// Code replicated from https://github.com/HandsOnOpenCL/Exercises-Solutions/blob/master/Solutions/ExerciseA/pi_vocl.cl

@(kernel)
@(params={partial_sums="global", local_sums="local"})
pi :: proc(
	niters: c.int,
	step_size: cl.Float,
	local_sums: [^]cl.Float,
	partial_sums: [^]cl.Float)
{
   num_wrk_items  := get_local_size(0);
   local_id       := get_local_id(0);
   group_id       := get_group_id(0);
   x, sum, accum  := 0.0;
   istart, iend: int;
   istart = (group_id * num_wrk_items + local_id) * niters;
   iend   = istart + niters;
   for i in istart..<iend {
       x = (i + 0.5) * step_size;
       accum += 4.0 / (1.0 + x * x);
   }
   local_sums[local_id] = accum;
   barrier(CLK_LOCAL_MEM_FENCE);
   if local_id == 0 {
      sum = 0.0;
      for i in 0..<num_wrk_items do sum += local_sums[i];
      partial_sums[group_id] = sum;
   }
}