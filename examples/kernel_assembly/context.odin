package ka;

import "core:c"
import "core:mem"
import "core:fmt"
import "core:time"
import "core:strings"
import "core:odin/ast"

import "emulator"
import cl "shared:opencl"

Platform_ID   :: emulator.Platform_ID;
Device_ID     :: emulator.Device_ID;
Context       :: emulator.Context;
Program       :: emulator.Program;
Command_Queue :: emulator.Command_Queue;
Kernel        :: emulator.Kernel;

Emulator_Wrapper :: struct #raw_union {
	null: emulator.Null_CL,
	full: emulator.Full_CL,
}

OpenCL_Context :: struct #no_copy {
	platform:   Platform_ID,
	device:     Device_ID,
	_context:   Context,
	program:    Program,
	queue:      Command_Queue,
	kernels:    map[string]Kernel, /**< compiled kernels */

	emulator_base: ^emulator.Emulator,
	/**
	 * @brief contains all possible emulator types
	 * @note as an "outsider" we do not care about the specific type, only the subtype (aka emulator.Emulator) but we need a way to properly store both in case they contain additional data
	 */
	emulator: Emulator_Wrapper,
}

when SHOW_TIMINGS {
	init_cl_context :: proc(ocl: ^OpenCL_Context, ekind: emulator.Emulator_Kind, compiler: ^Compiler, kernels: Assemble_Kernels_Result, allocator: mem.Allocator) {
		context.allocator = allocator;
		diff: time.Duration;
		{
			time.SCOPED_TICK_DURATION(&diff);
			_init_cl_context(ocl, ekind, compiler, kernels);
		}
		fmt.eprintfln("OpenCL context initialization took: %v", diff);
	}
} else {
	init_cl_context :: #force_inline proc(ocl: ^OpenCL_Context, ekind: emulator.Emulator_Kind, compiler: ^Compiler, kernels: Assemble_Kernels_Result, allocator: mem.Allocator) {
		context.allocator = allocator;
		_init_cl_context(ocl, ekind, compiler, kernels);
	}
}

@(private="file")
_init_cl_context :: proc(ocl: ^OpenCL_Context, ekind: emulator.Emulator_Kind, compiler: ^Compiler, kernels: Assemble_Kernels_Result) {
	switch ekind {
		case .Null:
			ocl.emulator.null = emulator.init_null();
			ocl.emulator_base = &ocl.emulator.null.base;
		case .Full:
			ocl.emulator.full = emulator.init_full();
			ocl.emulator_base = &ocl.emulator.full.base;
	}
	em: ^emulator.Emulator = ocl.emulator_base;

	ret: cl.Int;
	// query platform
	nof_platforms: cl.Uint;
	ret = em->GetPlatformIDs(0, nil, &nof_platforms);
	fmt.assertf(ret == cl.SUCCESS, "em->GetPlatformIDs(0, nil, &nof_platforms) returned %v", ret);
	assert(nof_platforms > 0, "em->GetPlatformIDs(0, nil, &nof_platforms) gave 0 platforms");
	ret = em->GetPlatformIDs(1, &ocl.platform, nil);
	fmt.assertf(ret == cl.SUCCESS, "em->GetPlatformIDs(1, &ocl.platform, nil) returned %v", ret);

	// query device
	nof_devices: cl.Uint;
	ret = em->GetDeviceIDs(
		ocl.platform,
		cl.DEVICE_TYPE_DEFAULT,
		0,
		nil,
		&nof_devices
	);
	fmt.assertf(ret == cl.SUCCESS, "em->GetDeviceIDs(...) returned %v", ret);
	assert(nof_devices > 0, "em->GetDeviceIDs(...) gave 0 devices");
	ret = em->GetDeviceIDs(
		ocl.platform,
		cl.DEVICE_TYPE_DEFAULT,
		1,
		&ocl.device,
		nil
	);
	fmt.assertf(ret == cl.SUCCESS, "em->GetDeviceIDs(...) returned %v", ret);

	// context
	ocl._context = em->CreateContext(nil, 1, &ocl.device, nil, nil, &ret);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateContext with exit code: %v", ret);

	// program
	ocl.program = em->CreateProgramWithSource(
		ocl._context,
		kernels.nof_kernels,
		kernels.kernel_strings,
		kernels.kernel_sizes,
		&ret
	);
	fmt.assertf(ret == cl.SUCCESS, "Failed calling cl.CreateProgramWithSource with exit code: %v", ret);

	ret = em->BuildProgram(ocl.program, 1, &ocl.device, nil, nil, nil);
	if ret != cl.SUCCESS {
		fmt.eprintfln("Failed calling cl.BuildProgram with exit code: %v.\nLog:", ret);
		log_len: c.size_t;
		assert(em->GetProgramBuildInfo(
			ocl.program,
			ocl.device,
			cl.PROGRAM_BUILD_LOG,
			0,
			nil,
			&log_len
		) == cl.SUCCESS);
		log := make([]byte, cast(int)log_len);
		defer delete(log);
		assert(em->GetProgramBuildInfo(
			ocl.program,
			ocl.device,
			cl.PROGRAM_BUILD_LOG,
			log_len,
			&log[0],
			nil
		) == cl.SUCCESS);
		assert(false, cast(string)log);
	}

	// kernels
	ocl.kernels = mem.make(map[string]Kernel);
	for name, desc in compiler.proc_table do if desc.kind == .Kernel {
		cname := strings.clone_to_cstring(name);
		defer delete(cname);

		switch em.kind {
			case .Full:
				map_insert(
					&ocl.kernels,
					strings.clone(name),
					em->CreateKernel(ocl.program, cname, &ret)
				);
			case .Null:
				nof_params := len(desc.lit.type.params.list);
				params, merr := mem.make([]Proc_Desc_Param, nof_params);
				{
					assert(merr == .None);
					index := 0;
					for param in desc.lit.type.params.list {
						for name in param.names {
							params[index] = desc.params[name.derived_expr.(^ast.Ident).name];
							index += 1;
						}
					}
				}

				map_insert(
					&ocl.kernels,
					strings.clone(name),
					emulator.CreateKernel_Null(em, ocl.program, desc.addr, params, &ret)
				);
		}
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
}

delete_cl_context :: #force_inline proc(ocl: ^OpenCL_Context) {
	ocl.emulator_base->ReleaseContext(ocl._context);
	ocl.emulator_base->ReleaseProgram(ocl.program);
	switch ocl.emulator_base.kind {
		case .Null: emulator.delete_null(&ocl.emulator.null);
		case .Full: emulator.delete_full(&ocl.emulator.full);
	}
	for k in ocl.kernels {
		delete_key(&ocl.kernels, k);
		mem.delete(k);
	}
	mem.delete(ocl.kernels);
}

