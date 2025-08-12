package ka;

import "core:c"
import "core:mem"
import "core:fmt"
import "core:time"
import "core:strings"

import cl "shared:opencl"

OpenCL_Context :: struct {
	platform:   Platform_ID,
	device:     Device_ID,
	_context:   Context,
	program:    Program,
	queue:      Command_Queue,
	kernels:    map[string]Kernel, /**< compiled kernels */
}

when SHOW_TIMINGS {
	init_cl_context :: proc(em: ^Emulator, compiler: ^Compiler, kernels: Assemble_Kernels_Result, allocator: mem.Allocator) -> (ocl: OpenCL_Context) {
		diff: time.Duration;
		{
			time.SCOPED_TICK_DURATION(&diff);
			ocl = _init_cl_context(em, compiler, kernels, allocator);
		}
		fmt.eprintfln("OpenCL context initialization took: %v", diff);
		return ocl;
	}
} else {
	init_cl_context :: #force_inline proc(em: ^Emulator, compiler: ^Compiler, kernels: Assemble_Kernels_Result, allocator: mem.Allocator) -> OpenCL_Context {
		return _init_cl_context(em, compiler, kernels, allocator);
	}
}

@(private="file")
_init_cl_context :: proc(em: ^Emulator, compiler: ^Compiler, kernels: Assemble_Kernels_Result, allocator: mem.Allocator) -> (ocl: OpenCL_Context) {
	// query platform
	nof_platforms: cl.Uint;
	em->GetPlatformIDs(0, nil, &nof_platforms);
	assert(nof_platforms > 0);
	assert(em->GetPlatformIDs(1, &ocl.platform, nil) == cl.SUCCESS);

	// query device
	nof_devices: cl.Uint;
	em->GetDeviceIDs(
		ocl.platform,
		cl.DEVICE_TYPE_GPU,
		0,
		nil,
		&nof_devices
	);
	assert(nof_devices > 0);
	assert(
		em->GetDeviceIDs(
			ocl.platform,
			cl.DEVICE_TYPE_GPU,
			1,
			&ocl.device,
			nil
		) == cl.SUCCESS
	);

	// context
	ret: cl.Int;
	ocl._context = em->CreateContext(nil, 1, &ocl.device, nil, nil, &ret);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateContext with exit code: %v", ret);

	// program
	ocl.program = em->CreateProgramWithSource(
		ocl._context,
		kernels.nof_kernels,
		&kernels.kernel_strings[0],
		&kernels.kernel_sizes[0],
		&ret
	);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateProgramWithSource with exit code: %v", ret);

	ret = em->BuildProgram(ocl.program, 1, &ocl.device, nil, nil, nil);
	if ret != cl.SUCCESS {
		fmt.eprintfln("Failed calling cl.BuildProgram with exit code: %v.\nLog:", ret);
		log_len: c.size_t;
		assert(em->GetProgramBuildInfo(
			cl.PROGRAM_BUILD_LOG,
			0,
			nil,
			&log_len
		) == cl.SUCCESS);
		log := make([]byte, cast(int)log_len);
		defer delete(log);
		assert(em->GetProgramBuildInfo(
			cl.PROGRAM_BUILD_LOG,
			log_len,
			&log[0],
			nil
		) == cl.SUCCESS);
		assert(false, cast(string)log);
	}

	// kernels
	ocl.kernels = mem.make(map[string]Kernel, allocator);
	for name, desc in compiler.proc_table do if desc.kind == .Kernel {
		cname := strings.clone_to_cstring(name);
		defer delete(cname);

		map_insert(
			&ocl.kernels,
			strings.clone(name),
			em->CreateKernel(ocl.program, cname, &ret)
		);
		fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateKernel with exit code: %v", ret);
	}
	when ODIN_DEBUG do fmt.eprintfln("\x1b[32mAll kernels compiled\x1b[0m");

	// queue
	ocl.queue = em->CreateCommandQueue(
		ocl._context,
		ocl.device,
		0,
		&ret
	);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateCommandQueue with exit code: %v", ret);

	return ocl;
}

delete_cl_context :: proc(em: ^Emulator) {
	em->ReleaseContext();
	em->ReleaseCommandQueue();
	for kernel_name, kernel in em.ocl.kernels {
		em->ReleaseKernel(kernel);
	}
	mem.delete(em.ocl.kernels);
}

