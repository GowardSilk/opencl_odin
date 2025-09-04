package emulator;

import "core:fmt"
import "core:sync"

import cl "shared:opencl"

@(kernel_builtin)
get_global_id :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
	payload := cast(^Kernel_Builtin_Context_Payload)context.user_ptr;
	when ODIN_DEBUG {
		assert(cast(cl.Uint)dim_index < payload.work_dim, "`dim_index' exceeds specified work dimension");
	}
	return cast(cl.Int)payload.global_pos[dim_index];
}

@(kernel_builtin)
get_local_id :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
	payload := cast(^Kernel_Builtin_Context_Payload)context.user_ptr;
	when ODIN_DEBUG {
		assert(cast(cl.Uint)dim_index < payload.work_dim, "`dim_index' exceeds specified work dimension");
	}
	return cast(cl.Int)payload.local_pos[dim_index];
}

@(kernel_builtin)
get_group_id :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
	payload := cast(^Kernel_Builtin_Context_Payload)context.user_ptr;
	if dim_index != 0 do unimplemented();
	return cast(cl.Int)payload.wg_idx;
}

@(kernel_builtin)
get_num_groups :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_local_size :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
	payload := cast(^Kernel_Builtin_Context_Payload)context.user_ptr;
	when ODIN_DEBUG {
		assert(cast(cl.Uint)dim_index < payload.work_dim, "`dim_index' exceeds specified work dimension");
	}
	return cast(cl.Int)payload.local_work_size[dim_index];
}

@(kernel_builtin)
get_global_size :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
	payload := cast(^Kernel_Builtin_Context_Payload)context.user_ptr;
	when ODIN_DEBUG {
		assert(cast(cl.Uint)dim_index < payload.work_dim, "`dim_index' exceeds specified work dimension");
	}
	return cast(cl.Int)payload.global_work_size[dim_index];
}

@(kernel_builtin)
get_global_offset :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_enqueued_local_size :: #force_inline proc(#any_int dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_work_dim :: #force_inline proc() -> cl.Int {
	payload := cast(^Kernel_Builtin_Context_Payload)context.user_ptr;
	return cast(cl.Int)payload.work_dim;
}

CLK_LOCAL_MEM_FENCE  :: 0x01;
CLK_GLOBAL_MEM_FENCE :: 0x02;

@(kernel_builtin)
barrier :: #force_inline proc(#any_int flags: cl.Int) {
	if flags == CLK_LOCAL_MEM_FENCE {
		payload := cast(^Kernel_Builtin_Context_Payload)context.user_ptr;
		// NOTE(GowardSilk): This barrier is reusable, therefore we do not have to re-initialize
		// it upon returning 'true' (aka when the thread_count == index, see impl)
		sync.barrier_wait(payload.barrier);
		return;
	}

	unimplemented("Right now we do not support global memory barriers.");
}

@(kernel_builtin)
mem_fence :: #force_inline proc(#any_int flags: cl.Int) {
  unimplemented();
}
