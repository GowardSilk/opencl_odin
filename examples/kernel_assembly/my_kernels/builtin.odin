package my_kernels;

import cl "shared:opencl"

@(kernel_builtin)
get_global_id :: proc(dim_index: cl.Int) -> cl.Int {
   unimplemented();
}

@(kernel_builtin)
get_local_id :: proc(dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_group_id :: proc(dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_num_groups :: proc(dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_local_size :: proc(dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_global_size :: proc(dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_global_offset :: proc(dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_enqueued_local_size :: proc(dim_index: cl.Int) -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
get_work_dim :: proc() -> cl.Int {
  unimplemented();
}

@(kernel_builtin)
barrier :: proc(flags: cl.Int) {
  unimplemented();
}

@(kernel_builtin)
mem_fence :: proc(flags: cl.Int) {
  unimplemented();
}
