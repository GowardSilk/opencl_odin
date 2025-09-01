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

import "core:c"
import "core:mem"

import "../emulator"
import cl "shared:opencl"

@(kernel)
@(params={input="global", output="global"})
copy_kernel :: proc(input: [^]cl.Float, output: [^]cl.Float) {
    id := emulator.get_global_id(0);
    output[id] = input[id];
}

@(kernel)
@(params={input="global", output="global"})
scale_kernel :: proc(input: [^]cl.Float, output: [^]cl.Float, scale: /* __const */ cl.Float) {
	id := emulator.get_global_id(0);
	output[id] = input[id] * scale;
}

@(kernel)
@(params={data="global", scratch="local"})
local_mem_kernel :: proc(data: [^]cl.Float, scratch: [^]cl.Float) {
    lid := emulator.get_local_id(0);
    gid := emulator.get_global_id(0);

    scratch[lid] = data[gid];
    emulator.barrier(emulator.CLK_LOCAL_MEM_FENCE);

    next := (lid + 1) % emulator.get_local_size(0);
    data[gid] = scratch[next];
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
   num_wrk_items  := emulator.get_local_size(0);
   local_id       := emulator.get_local_id(0);
   group_id       := emulator.get_group_id(0);
   x, sum, accum: cl.Float = 0.0, 0.0, 0.0;
   istart, iend: cl.Int;
   istart = (group_id * num_wrk_items + local_id) * niters;
   iend   = istart + niters;
   for i: cl.Int = istart; i < iend ; i += 1 {
       x = (cast(cl.Float)i + 0.5) * step_size;
       accum += 4.0 / (1.0 + x * x);
   }
   local_sums[local_id] = accum;
   emulator.barrier(emulator.CLK_LOCAL_MEM_FENCE);
   if local_id == 0 {
      sum: cl.Float = 0.0;
      for i: cl.Int = 0; i < num_wrk_items; i += 1 {
         sum += local_sums[i];
      }
      partial_sums[group_id] = sum;
   }
}

copy_kernel_nullcl_wrapper :: proc(params: []rawptr) {
      when ODIN_DEBUG do assert(len(params) == 2);

      p0 := cast(^^emulator.Mem_Null_Impl)params[0];
      p1 := cast(^^emulator.Mem_Null_Impl)params[1];
      copy_kernel(cast([^]cl.Float)p0^.data, cast([^]cl.Float)p1^.data);
}

scale_kernel_nullcl_wrapper :: proc(params: []rawptr) {
      when ODIN_DEBUG do assert(len(params) == 3);

      // TODO(GowardSilk): We should not use this 'casting' strategy here such that we assume the inner
      // workings of the emulator package... the emulator API should provide a suitable argument (aka the input
      // parameter of the @(kernel) functions
      p0 := cast(^^emulator.Mem_Null_Impl)params[0];
      p1 := cast(^^emulator.Mem_Null_Impl)params[1];
      p2 := cast(^cl.Float)params[2];
      scale_kernel(cast([^]cl.Float)p0^.data, cast([^]cl.Float)p1^.data, p2^);
}

local_mem_kernel_nullcl_wrapper :: proc(params: []rawptr) {
      when ODIN_DEBUG do assert(len(params) == 2);
      
      p0 := cast(^^emulator.Mem_Null_Impl)params[0];
      p1_arg_local_bytes := cast([^]byte)params[1];
      p1 := get_local_arg(p1_arg_local_bytes);
      local_mem_kernel(cast([^]cl.Float)p0^.data, cast([^]cl.Float)p1);
}

pi_kernel_nullcl_wrapper :: proc(params: []rawptr) {
      when ODIN_DEBUG do assert(len(params) == 4);

      p0 := cast(^c.int)params[0];
      p1 := cast(^cl.Float)params[1];

      // whole emulator.Kernel_Null_Arg_Local is stored as byte array
      p2_arg_local_bytes := cast([^]byte)params[2];
      p2 := get_local_arg(p2_arg_local_bytes);

      p3 := cast(^^emulator.Mem_Null_Impl)params[3];
      pi(p0^, p1^, cast([^]cl.Float)p2, cast([^]cl.Float)p3^.data);
}

/**
 * @brief helper function to extract __local kernel arg
 */
@(private="file")
get_local_arg :: #force_inline proc(local_bytes: [^]byte) -> rawptr {
      payload := cast(^emulator.Kernel_Builtin_Context_Payload)context.user_ptr;
      // get the emulator.Kernel_Null_Arg_Local.size (aka size of one __local param)
      chunk_size := cast(^c.size_t)&local_bytes[offset_of(emulator.Kernel_Null_Arg_Local, size)];
      // calculate offset of that chunk
      chunk_begin := payload.wg_idx / payload.nof_iters * chunk_size^;
      return &local_bytes[offset_of(emulator.Kernel_Null_Arg_Local, buffer) + cast(uintptr)chunk_begin];
}
