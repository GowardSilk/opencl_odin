package ka;

import "core:c"
import "core:mem"
import "core:fmt"
import "core:math/rand"

import "emulator"
import "my_kernels"
import cl "shared:opencl"

copy_kernel_test :: proc(ocl: ^OpenCL_Context, work_size: c.size_t) {
	em := ocl.emulator_base;
	work_size := work_size;

	inputs, outputs: []cl.Float;
	merr: mem.Allocator_Error;

	inputs, merr = mem.make([]cl.Float, cast(int)work_size);
	assert(merr == .None);
	defer mem.delete(inputs);
	for i in 0..<work_size do inputs[i] = rand.float32();
	inputs_mem := emulator.CreateBufferEx(em, ocl._context, cl.MEM_READ_ONLY | cl.MEM_USE_HOST_PTR, &inputs).?;
	defer em->ReleaseMemObject(inputs_mem);

	outputs, merr = mem.make([]cl.Float, cast(int)work_size);
	assert(merr == .None);
	defer mem.delete(outputs);
	outputs_mem := emulator.CreateBufferEx(em, ocl._context, cl.MEM_WRITE_ONLY | cl.MEM_USE_HOST_PTR, &outputs).?;
	defer em->ReleaseMemObject(outputs_mem);

	copy_kernel, ok := ocl.kernels["copy_kernel"];
	assert(ok);
	ret := em->SetKernelArg(copy_kernel, 0, size_of(inputs_mem), &inputs_mem);
	ret |= em->SetKernelArg(copy_kernel, 1, size_of(outputs_mem), &outputs_mem);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	ret = em->EnqueueNDRangeKernel(ocl.queue, copy_kernel, 1, nil, &work_size, nil, 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	ret = em->FinishCommandQueue(ocl.queue);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->EnqueueReadBuffer(ocl.queue, outputs_mem, cl.TRUE, 0, work_size * size_of(cl.Float), &outputs[0], 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	for i in 0..<work_size {
		fmt.assertf(
			inputs[i] == outputs[i],
			"%f = %f expected but received %f",
			inputs[i], inputs[i], outputs[i],
		);
	}
}

scale_kernel_test :: proc(ocl: ^OpenCL_Context, work_size: c.size_t) {
	em := ocl.emulator_base;

	outputs, inputs: []cl.Float;
	merr: mem.Allocator_Error;

	inputs, merr  = mem.make([]cl.Float, cast(int)work_size);
	assert(merr == .None);
	defer mem.delete(inputs);
	for i in 0..<work_size do inputs[i] = cast(cl.Float)i + 1;
	inputs_mem := emulator.CreateBufferEx(em, ocl._context, cl.MEM_READ_ONLY | cl.MEM_USE_HOST_PTR, &inputs).?;
	defer em->ReleaseMemObject(inputs_mem);

	outputs, merr = mem.make([]cl.Float, cast(int)work_size);
	assert(merr == .None);
	defer mem.delete(outputs);
	outputs_mem := emulator.CreateBufferEx(em, ocl._context, cl.MEM_WRITE_ONLY | cl.MEM_USE_HOST_PTR, &outputs).?;
	defer em->ReleaseMemObject(outputs_mem);

	coeff: cl.Float = 2;

	scale_kernel, ok := ocl.kernels["scale_kernel"];
	assert(ok);
	ret := em->SetKernelArg(scale_kernel, 0, size_of(inputs_mem), &inputs_mem);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->SetKernelArg(scale_kernel, 1, size_of(outputs_mem), &outputs_mem);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->SetKernelArg(scale_kernel, 2, size_of(coeff), &coeff);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	work_size := work_size;
	ret = em->EnqueueNDRangeKernel(ocl.queue, scale_kernel, 1, nil, &work_size, nil, 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->FinishCommandQueue(ocl.queue);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->EnqueueReadBuffer(ocl.queue, outputs_mem, cl.TRUE, 0, work_size * size_of(cl.Float), &outputs[0], 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	for i in 0..<work_size {
		fmt.assertf(
			inputs[i] * coeff == outputs[i],
			"%f * %f = %f expected but received %f",
			inputs[i], coeff, inputs[i] * coeff, outputs[i],
		);
	}
}

local_mem_test :: proc(ocl: ^OpenCL_Context, global_size: c.size_t) {
	em := ocl.emulator_base;

	data, merr := mem.make([]cl.Float, cast(int)global_size);
	assert(merr == .None);
	defer mem.delete(data);
	for i in 0..<global_size do data[i] = rand.float32();
	data_mem := emulator.CreateBufferEx(em, ocl._context, cl.MEM_READ_WRITE | cl.MEM_USE_HOST_PTR, &data).?;
	defer em->ReleaseMemObject(data_mem);

	data_backup: []cl.Float;
	data_backup, merr = mem.make([]cl.Float, cast(int)global_size);
	assert(merr == .None);
	defer mem.delete(data_backup);
	mem.copy(raw_data(data_backup), raw_data(data), len(data) * size_of(data[0]));

	kernel, ok := ocl.kernels["local_mem_kernel"];
	assert(ok);
	nof_steps, nof_units, local_size: c.size_t;
	ret := em->GetKernelWorkGroupInfo(kernel, ocl.device, cl.KERNEL_WORK_GROUP_SIZE, size_of(nof_units), &nof_units, nil);
	if global_size >= nof_units {
		local_size = nof_units;
		nof_steps  = global_size / local_size;
	} else {
		local_size = global_size;
		nof_steps  = 1;
	}

	ret  = em->SetKernelArg(kernel, 0, size_of(data_mem), &data_mem);
	ret |= em->SetKernelArg(kernel, 1, size_of(cl.Float) * local_size, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	global_size := global_size;
	ret = em->EnqueueNDRangeKernel(ocl.queue, kernel, 1, nil, &global_size, &local_size, 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	ret = em->EnqueueReadBuffer(ocl.queue, data_mem, cl.TRUE, 0, global_size * size_of(cl.Float), &data[0], 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	check_local_shift :: proc(input: []cl.Float, output: []cl.Float, local_size: c.size_t) -> bool {
		num_groups := cast(c.size_t)len(input) / local_size;
		for g in 0..<num_groups {
			base := g * local_size;
			for lid in 0..<local_size {
				expected := input[base + ((lid + 1) % local_size)];
				if output[base + lid] != expected {
					fmt.eprintfln("Mismatch at gid=%v: got=%v, expected=%v", base+lid, output[base+lid], expected);
					return false;
				}
			}
		}
		return true;
	}
	//assert(check_local_shift(data_backup, data, local_size));
}

pi_test :: proc(ocl: ^OpenCL_Context, $vector_size: int) {
	em := ocl.emulator_base;
	NOF_STEPS :: 512 * 512 * 512;

	when vector_size == 1 {
		kernel, ok := ocl.kernels["pi"];
		assert(ok);
		NOF_ITERS :: 262144;
		WGS       :: 8; // [W]ork[G]roup[S]ize;
	} else when vector_size == 4 {
		NOF_ITERS :: 262144 / 4;
		WGS       :: 8 * 4;
	} else when vector_size == 8 {
		NOF_ITERS :: 262144 / 8;
		WGS       :: 8 * 8;
	} else do #assert(false, "vector_size can be only 1, 4 or 8!");

	work_group_size: c.size_t = WGS;
	nof_work_groups: c.size_t = NOF_STEPS / (WGS * NOF_ITERS);

	max_size: c.size_t;
	ret := em->GetKernelWorkGroupInfo(kernel, ocl.device, cl.KERNEL_WORK_GROUP_SIZE, size_of(c.size_t), &max_size, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	if max_size > WGS {
		work_group_size = max_size;
		nof_work_groups = NOF_STEPS / (work_group_size * NOF_ITERS);
	}

	if nof_work_groups < 1 {
		ret = em->GetDeviceInfo(ocl.device, cl.DEVICE_MAX_COMPUTE_UNITS, size_of(nof_work_groups), &nof_work_groups, nil);
		fmt.assertf(ret == cl.SUCCESS, "%v", ret);
		work_group_size = NOF_STEPS / (nof_work_groups * NOF_ITERS);
	}
	fmt.eprintfln("WGS: %d; max_size: %d", work_group_size, max_size);
	fmt.eprintfln("nof_work_groups: %d", nof_work_groups);

	nof_steps := work_group_size * NOF_ITERS * nof_work_groups;
	step_size: cl.Float = 1.0 / NOF_STEPS;
	fmt.eprintfln("nof_steps: %d; NOF_STEPS: %d\nstep_size: %.10f", nof_steps, NOF_STEPS, step_size);

	partial_sums, merr := mem.make([^]cl.Float, cast(int)nof_work_groups);
	assert(merr == .None);
	defer mem.free(partial_sums);
	partial_sums_mem := em->CreateBuffer(ocl._context, cl.MEM_WRITE_ONLY | cl.MEM_USE_HOST_PTR, nof_work_groups * size_of(cl.Float), partial_sums, &ret);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	defer em->ReleaseMemObject(partial_sums_mem);

	nof_iters: cl.Int = 262144;
	ret  = em->SetKernelArg(kernel, 0, size_of(cl.Int), &nof_iters);
	ret |= em->SetKernelArg(kernel, 1, size_of(cl.Float), &step_size);
	ret |= em->SetKernelArg(kernel, 2, size_of(cl.Float) * work_group_size, nil);
	ret |= em->SetKernelArg(kernel, 3, size_of(cl.Mem), &partial_sums_mem);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	ret = em->EnqueueNDRangeKernel(ocl.queue, kernel, 1, nil, &nof_steps, &work_group_size, 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	ret = em->EnqueueReadBuffer(ocl.queue, partial_sums_mem, cl.TRUE, 0, nof_work_groups * size_of(cl.Float), &partial_sums[0], 0, nil, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	final_sum: cl.Float = 0;
	for i in 0..<nof_work_groups {
		final_sum += partial_sums[i];
	}
	final_sum *= step_size;

	fmt.eprintfln("Result: %f", final_sum);
}

query_proc :: proc(proc_desc: ^Proc_Desc) {
	switch proc_desc.name {
	case "copy_kernel":  proc_desc.addr = my_kernels.copy_kernel_nullcl_wrapper;
	case "scale_kernel": proc_desc.addr = my_kernels.scale_kernel_nullcl_wrapper;
	case "pi":	     proc_desc.addr = my_kernels.pi_kernel_nullcl_wrapper;
	case "local_mem_kernel":
		proc_desc.addr = my_kernels.local_mem_kernel_nullcl_wrapper;
	case: unreachable();
	}
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator;
		mem.tracking_allocator_init(&track, context.allocator);
		allocator := context.allocator;
		context.allocator = mem.tracking_allocator(&track);
	}

	ocl: OpenCL_Context;
	merr := compile(&ocl, .Full, .OpenCL_Lang, query_proc);
	assert(merr == .None);

	{
		/// LOCAL MEM KERNEL TEST

		fmt.eprintfln("\nlocal mem kernel 1:\n");
		local_mem_test(&ocl, 1);
		fmt.eprintfln("\nlocal mem kernel 5:\n");
		local_mem_test(&ocl, 5);
		fmt.eprintfln("\nlocal mem kernel 10:\n");
		//local_mem_test(&ocl, 10);
		fmt.eprintfln("\nlocal mem kernel 20:\n");
		//local_mem_test(&ocl, 20);
		fmt.eprintfln("\nlocal mem kernel 256:\n");
		//local_mem_test(&ocl, 256);

		/// COPY KERNEL TEST

		fmt.eprintfln("\ncopy_kernel:\n");
		copy_kernel_test(&ocl, 1);
		copy_kernel_test(&ocl, 10);
		copy_kernel_test(&ocl, 20);
		copy_kernel_test(&ocl, 1000);

		/// SCALE KERNEL TEST

		fmt.eprintfln("\nscale_kernel:\n");
		max_size: c.size_t;
		{
			scale_kernel := ocl.kernels["scale_kernel"];
			ret := ocl.emulator_base->GetKernelWorkGroupInfo(scale_kernel, ocl.device, cl.KERNEL_WORK_GROUP_SIZE, size_of(c.size_t), &max_size, nil)
			fmt.assertf(ret == cl.SUCCESS, "cl.GetKernelWorkGroupInfo failed: %v", ret);
		}
		scale_kernel_test(&ocl, 1);
		scale_kernel_test(&ocl, max_size - 1);
		scale_kernel_test(&ocl, max_size + 1);
		scale_kernel_test(&ocl, 2 * max_size);

		/// PI KERNEL TEST

		fmt.eprintfln("\npi:\n");
		//pi_test(&ocl, 1);
	}
	delete_cl_context(&ocl);

	when ODIN_DEBUG {
		if len(track.allocation_map) <= 0 do fmt.println("\x1b[32mNo leaks\x1b[0m");
		else {
			for _, leak in track.allocation_map {
				fmt.printf("%v leaked %m\n", leak.location, leak.size)
			}
		}

		mem.tracking_allocator_destroy(&track);
		context.allocator = allocator;
	}
}
