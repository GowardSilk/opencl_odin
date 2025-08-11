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

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator;
		mem.tracking_allocator_init(&track, context.allocator);
		allocator := context.allocator;
		context.allocator = mem.tracking_allocator(&track);
	}

	em := init_emulator_full();
	my_kernel_test(&em);
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
