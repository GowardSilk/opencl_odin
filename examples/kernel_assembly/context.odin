package ka;

import "core:c"
import "core:mem"
import "core:fmt"
import "core:strings"

import cl "shared:opencl"

OpenCL_Context :: struct {
	platform:   cl.Platform_ID,
	device:     cl.Device_ID,
	_context:   cl.Context,
	program:    cl.Program,
	queue:      cl.Command_Queue,
	kernels:    map[string]cl.Kernel, /**< compiled kernels */
}

init_cl_context :: proc(compiler: ^Compiler, kernels: Assemble_Kernels_Result, allocator: mem.Allocator) -> (ocl: OpenCL_Context) {
	// query platform
	nof_platforms: cl.Uint;
	cl.GetPlatformIDs(0, nil, &nof_platforms);
	assert(nof_platforms > 0);
	assert(cl.GetPlatformIDs(1, &ocl.platform, nil) == cl.SUCCESS);

	// query device
	nof_devices: cl.Uint;
	cl.GetDeviceIDs(
		ocl.platform,
		cl.DEVICE_TYPE_GPU,
		0,
		nil,
		&nof_devices
	);
	assert(nof_devices > 0);
	assert(
		cl.GetDeviceIDs(
			ocl.platform,
			cl.DEVICE_TYPE_GPU,
			1,
			&ocl.device,
			nil
		) == cl.SUCCESS
	);

	// context
	ret: cl.Int;
	ocl._context = cl.CreateContext(nil, 1, &ocl.device, nil, nil, &ret);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateContext with exit code: %v", ret);

	// program
	ocl.program = cl.CreateProgramWithSource(
		ocl._context,
		kernels.nof_kernels,
		&kernels.kernel_strings[0],
		&kernels.kernel_sizes[0],
		&ret
	);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateProgramWithSource with exit code: %v", ret);

	ret = cl.BuildProgram(ocl.program, 1, &ocl.device, nil, nil, nil);
	if ret != cl.SUCCESS {
		fmt.eprintfln("Failed calling cl.BuildProgram with exit code: %v.\nLog:", ret);
		log_len: c.size_t;
		assert(cl.GetProgramBuildInfo(
			ocl.program,
			ocl.device,
			cl.PROGRAM_BUILD_LOG,
			0,
			nil,
			&log_len
		) == cl.SUCCESS);
		log := make([]byte, cast(int)log_len);
		assert(cl.GetProgramBuildInfo(
			ocl.program,
			ocl.device,
			cl.PROGRAM_BUILD_LOG,
			log_len,
			&log[0],
			nil
		) == cl.SUCCESS);
		fmt.eprintfln("%s", cast(string)log);
		delete(log);
	}

	// kernels
	ocl.kernels = mem.make(map[string]cl.Kernel, allocator);
	for name, desc in compiler.proc_table do if desc.kind == .Kernel {
		cname := strings.clone_to_cstring(name);
		defer delete(cname);

		map_insert(
			&ocl.kernels,
			strings.clone(name),
			cl.CreateKernel(ocl.program, cname, &ret)
		);
		fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateKernel with exit code: %v", ret);
	}
	when ODIN_DEBUG do fmt.eprintfln("\x1b[32mAll kernels compiled\x1b[0m");

	// queue
	ocl.queue = cl.CreateCommandQueue(
		ocl._context,
		ocl.device,
		0,
		&ret
	);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateCommandQueue with exit code: %v", ret);

	return ocl;
}

delete_cl_context :: proc(cl_context: ^OpenCL_Context) {
	assert(cl_context != nil);
	cl.ReleaseContext(cl_context._context);
	cl.ReleaseCommandQueue(cl_context.queue);
	for kernel_name, kernel in cl_context.kernels {
		cl.ReleaseKernel(kernel);
	}
	mem.delete(cl_context.kernels);
}

