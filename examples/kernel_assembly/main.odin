package ka;

import "core:c"
import "core:mem"
import "core:fmt"

import cl "shared:opencl"

my_kernel_test :: proc(em: ^Emulator) {
	outputs, inputs: []cl.Float;
	merr: mem.Allocator_Error;

	work_size: c.size_t = 10;
	inputs, merr  = mem.make([]cl.Float, cast(int)work_size);
	assert(merr == .None);
	defer mem.delete(inputs);
	for i in 0..<10 do inputs[i] = cast(cl.Float)i + 1;
	inputs_mem := CreateBufferEx(em, cl.MEM_READ_ONLY | cl.MEM_USE_HOST_PTR, &inputs).?;
	defer em->ReleaseMemObject(inputs_mem);

	outputs, merr = mem.make([]cl.Float, cast(int)work_size);
	assert(merr == .None);
	defer mem.delete(outputs);
	outputs_mem := CreateBufferEx(em, cl.MEM_WRITE_ONLY | cl.MEM_USE_HOST_PTR, &outputs).?;
	defer em->ReleaseMemObject(outputs_mem);

	coeff: cl.Float = 2;

	my_kernel := em.ocl.kernels["my_kernel"];
	ret := em->SetKernelArg(my_kernel, 0, size_of(inputs_mem), &inputs_mem);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->SetKernelArg(my_kernel, 1, size_of(outputs_mem), &outputs_mem);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->SetKernelArg(my_kernel, 2, size_of(coeff), &coeff);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->EnqueueNDRangeKernelEx(my_kernel, 1, nil, &work_size);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	ret = em->FinishCommandQueue();
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	fmt.eprintfln("%v\n* %f\n=========\n%v", inputs, coeff, outputs);
}

pi_test :: proc(em: ^Emulator, $vector_size: int) {
	NOF_STEPS :: 512 * 512 * 512;

	when vector_size == 1 {
		kernel := em.ocl.kernels["pi"];
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
	ret := em->GetKernelWorkGroupInfo(kernel, cl.KERNEL_WORK_GROUP_SIZE, size_of(c.size_t), &max_size, nil);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	fmt.eprintfln("WGS: %d; max_size: %d", WGS, max_size);
	if max_size > WGS {
		work_group_size = max_size;
		nof_work_groups = NOF_STEPS / (work_group_size * NOF_ITERS);
	}

	if nof_work_groups < 1 {
		ret = em->GetDeviceInfo(cl.DEVICE_MAX_COMPUTE_UNITS, size_of(nof_work_groups), &nof_work_groups, nil);
		fmt.assertf(ret == cl.SUCCESS, "%v", ret);
		work_group_size = NOF_STEPS / (nof_work_groups * NOF_ITERS);
	}
	fmt.eprintfln("nof_work_groups: %d", nof_work_groups);

	nof_steps := work_group_size * NOF_ITERS * nof_work_groups;
	step_size: cl.Float = 1.0 / NOF_STEPS;
	fmt.eprintfln("nof_steps: %d; NOF_STEPS: %d\nstep_size: %.10f", nof_steps, NOF_STEPS, step_size);

	partial_sums, merr := mem.make([^]cl.Float, cast(int)nof_work_groups);
	assert(merr == .None);
	defer mem.free(partial_sums);
	partial_sums_mem := em->CreateBuffer(cl.MEM_WRITE_ONLY | cl.MEM_USE_HOST_PTR, nof_work_groups, partial_sums, &ret);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);
	defer em->ReleaseMemObject(partial_sums_mem);

	nof_iters: cl.Int = 262144;
	ret  = em->SetKernelArg(kernel, 0, size_of(cl.Int), &nof_iters);
	ret |= em->SetKernelArg(kernel, 1, size_of(cl.Float), &step_size);
	ret |= em->SetKernelArg(kernel, 2, size_of(cl.Float) * work_group_size, nil);
	ret |= em->SetKernelArg(kernel, 3, size_of(cl.Mem), &partial_sums_mem);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	//ret = em->EnqueueNDRangeKernelEx(kernel, 1, nil, &nof_steps, &work_group_size);
	fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	assert(em->FinishCommandQueue() == cl.SUCCESS);

	//fmt.eprintfln("EnqueueReadBufferEx(mem: %v, blocking: %v, offset: %v, size: %v, host_ptr: %v)", partial_sums_mem, cl.TRUE, 0, nof_work_groups * size_of(cl.Float), partial_sums)
	//ret = em->EnqueueReadBufferEx(partial_sums_mem, cl.TRUE, 0, nof_work_groups * size_of(cl.Float), partial_sums);
	//fmt.assertf(ret == cl.SUCCESS, "%v", ret);

	final_sum: cl.Float = 0;
	for i in 0..<nof_work_groups {
		final_sum += partial_sums[i];
	}
	final_sum *= step_size;

	fmt.eprintfln("Result: %f", final_sum);
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator;
		mem.tracking_allocator_init(&track, context.allocator);
		allocator := context.allocator;
		context.allocator = mem.tracking_allocator(&track);
	}

	#assert(false, "TODO: WE NEED TO SOMEHOW SOLVE THE PROBLEM OF @(buildin_kernel) BEING INSIDE ANOTHER PACKAGE (aka `emulator`) WHILE ALL OF THE OTHER FUCNTIONS BEING SOMEWHERE ELSE... ALSO WE NEED TO TAKE INTO ACCOUNT THAT \"BUILDING\" HAS ALREADY BEEN DONE WHEN COMPILING ODIN, SO em[NullCL]->BuildProgram IS USELESS; MAKE SOMETHING ELSE (aka NEW METHOD WITH \"Ex\" OR \"Null\")");
	em := init_emulator_full();
	fmt.eprintfln("\nmy_kernel:\n");
	my_kernel_test(&em);
	fmt.eprintfln("\npi:\n");
	pi_test(&em, 1);
	delete_emulator(&em);

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
