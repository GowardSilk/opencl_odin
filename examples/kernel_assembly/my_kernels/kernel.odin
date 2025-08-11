/**
 * NOTE(GowardSilk): This should be technically compileable by Odin's compiler but it is sort of redundant to place it
 * along with the rest of the project since we need to parse this in runtime anyway via our own "Compiler".
 *
 * Each function called inside the kernel should be either known (OpenCL language builtin)
 * or another normal function from this file which will be automatically inlined (as clc does).
 *
 * global/local function param type qualifiers can be specified via compound literal consisting of a key (aka field name)
 * being procedure parameter and field value being the qualifier.
 */
package my_kernels;

import c  "core:c"
import cl "shared:opencl"

@(kernel)
@(params={input="global", output="global"})
my_kernel :: proc(input: [^]cl.Float, output: [^]cl.Float, scale: /* __const */ cl.Float) {
	id := get_global_id(0);
	output[id] = input[id] * scale;
}

my_kernel_nullcl_wrapper :: proc(params: []rawptr) {
      my_kernel(
	 cast([^]cl.Float)params[0],
	 cast([^]cl.Float)params[1],
	 (cast(^cl.Float)params[2])^
      );
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
   x, sum, accum  := 0.0, 0.0, 0.0;
   istart, iend: int;
   istart = (group_id * num_wrk_items + local_id) * niters;
   iend   = istart + niters;
   for i: int = istart; i < iend ; i += 1 {
       x = (i + 0.5) * step_size;
       accum += 4.0 / (1.0 + x * x);
   }
   local_sums[local_id] = accum;
   barrier(CLK_LOCAL_MEM_FENCE);
   if local_id == 0 {
      sum = 0.0;
      for i: int = 0; i < num_wrk_items; i += 1 {
         sum += local_sums[i];
      }
      partial_sums[group_id] = sum;
   }
}

pi_nullcl_wrapper :: proc(params: []rawptr) {
      pi(
	 (cast(^c.int)params[0])^,
	 (cast(^cl.Float)params[1])^,
	 cast([^]cl.Float)params[2],
	 cast([^]cl.Float)params[3]
      );
}
