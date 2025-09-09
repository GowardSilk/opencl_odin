// file contents generated from kernel_assembly/compiler.odin

__kernel void pi(__const int niters, __const float step_size, __local float* local_sums, __global float* partial_sums) {
        int num_wrk_items = get_local_size(0);
        int local_id = get_local_id(0);
        int group_id = get_group_id(0);
        float x = 0.0;
	float sum = 0.0;
	float accum = 0.0;
        int istart;
	int iend;
        istart = (group_id * num_wrk_items + local_id) * niters;
        iend = istart + niters;
        for (int i = istart;i < iend;i += 1){
                x = ((float)i + 0.5) * step_size;
                accum += 4.0 / (1.0 + x * x);
        }

        local_sums[local_id] = accum;
        barrier(CLK_LOCAL_MEM_FENCE);
        if (local_id == 0){
                float sum = 0.0;
                for (int i = 0;i < num_wrk_items;i += 1){
                        sum += local_sums[i];
                }

                partial_sums[group_id] = sum;
        }
}

__kernel void scale_kernel(__global float* input, __global float* output, __const float scale) {
        int id = get_global_id(0);
        output[id] = input[id] * scale;
}

__kernel void local_mem_kernel(__global float* data, __local float* scratch) {
        int lid = get_local_id(0);
        int gid = get_global_id(0);
        scratch[lid] = data[gid];
        barrier(CLK_LOCAL_MEM_FENCE);
        int next = (lid + 1) % get_local_size(0);
        data[gid] = scratch[next];
}

__kernel void copy_kernel(__global float* input, __global float* output) {
        int id = get_global_id(0);
        output[id] = input[id];
}
