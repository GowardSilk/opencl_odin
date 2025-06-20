package main;

import "base:runtime"
import "core:c"
import "core:log"

import cl "shared:opencl"

/**
 * @brief picks platform and device IDs based on max compute unit count
 * @return nil pair if any query failed, other the most "performant" device and platform
 */
pick_platform_and_device :: proc() -> (cl.Platform_ID, cl.Device_ID) {
	// query all available platforms
	all_platforms: []cl.Platform_ID;
	num_all_platforms: cl.Uint = 0;
	if ret := cl.GetPlatformIDs(0, nil, &num_all_platforms); ret != cl.SUCCESS {
		log.errorf("Failed to query platform ids! Error value: %d", ret);
		return nil, nil;
	}
	all_platforms = make([]cl.Platform_ID, num_all_platforms);
	defer delete(all_platforms);
	if ret := cl.GetPlatformIDs(num_all_platforms, &all_platforms[0], nil); ret != cl.SUCCESS {
		log.errorf("Failed to query platform ids! Error value: %d", ret);
		return nil, nil;
	}

	// try to pick the most "performant" one
	// this is technically an overkill but it should demonstrate the "filtering"
	// and device query
	best_platform: cl.Platform_ID;
	best_device: cl.Device_ID;
    max_compute_units: cl.Uint = 0;

    for i: cl.Uint = 0; i < num_all_platforms; i += 1 {
        devices: [10]cl.Device_ID;
        num_devices: cl.Uint;
        cl.GetDeviceIDs(all_platforms[i], cl.DEVICE_TYPE_ALL, 10, &devices[0], &num_devices);

        for j: cl.Uint = 0; j < num_devices; j += 1 {
            compute_units: cl.Uint;

            cl.GetDeviceInfo(devices[j], cl.DEVICE_MAX_COMPUTE_UNITS, size_of(compute_units), &compute_units, nil);

            if (compute_units > max_compute_units) {
                max_compute_units = compute_units;
                best_platform = all_platforms[i];
                best_device = devices[j];
            }
        }
    }

	if best_platform != nil {
		platform_name: [128]cl.Uchar;
		cl.GetPlatformInfo(best_platform, cl.PLATFORM_NAME, size_of(platform_name), cast(rawptr)&platform_name[0], nil);
		log.infof("Best Platform: %s", platform_name);
	}
	if best_device != nil {
		device_name: [128]cl.Uchar;
		cl.GetDeviceInfo(best_device, cl.DEVICE_NAME, size_of(device_name), cast(rawptr)&device_name[0], nil);

		log.infof("Best Device: %s", device_name);
		log.infof("Clock Compute units: %d", max_compute_units);
	}

	return best_platform, best_device;
}

ctx_error_callback :: proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr) {
	context = runtime.default_context()
	log.error(errinfo);
}

/**
 * @brief creates device context for the picked device id
 * @note function does not validate `device` parameter! assumes to be valid
 * @return `nil` when clCreateContext failed to initialize, otherwise valid handle to context
 */
create_context :: proc(device: cl.Device_ID) -> cl.Context {
	device := device

	ret: cl.Int;
	ctx := cl.CreateContext(nil, 1, &device, ctx_error_callback, nil, &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create Context! Error value: %d", ret);
		return nil;
	}
	return ctx;
}

/**
 * @brief creates and compiles program from "./test_program.cl"
 * @note function does not validate `device` nor `ctx` parameter! assumes to be valid
 * @return `nil` when failed to compile program
 */
create_program :: proc(ctx: cl.Context, device: cl.Device_ID) -> cl.Program {
	device := device;

	ret: cl.Int;

	program_source := #load("test_Program.cl");
	program_source_ptr := cast(cstring)&program_source[0];
	program_source_size := cast(uint)len(program_source);

	program := cl.CreateProgramWithSource(ctx, 1, &program_source_ptr, &program_source_size, &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create program! Error value: %d", ret);
		return nil;
	}

	ret = cl.BuildProgram(program, 1, &device, nil, nil, nil);
	if ret != cl.SUCCESS {
		log.errorf("Failed to compile program! Error value: %d", ret);
		return nil;
	}

	return program;
}

create_command_queue :: proc(ctx: cl.Context, device: cl.Device_ID) -> cl.Command_Queue {
	ret: cl.Int;
	queue := cl.CreateCommandQueue(ctx, device, 0, &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create Command Queue! Error value: %d", ret);
		return nil;
	}
	return queue;
}

create_buffers :: proc(ctx: cl.Context) -> (cl.Mem, cl.Mem) {
	data: [10]f32 = {1,2,3,4,5,6,7,8,9,10};
	size := cast(uint)len(data) * size_of(f32);

	ret: cl.Int;
	buffer_in := cl.CreateBuffer(ctx, cl.MEM_READ_ONLY | cl.MEM_COPY_HOST_PTR, size, &data[0], &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create input buffer! Error value: %d", ret);
		return nil, nil;
	}

	buffer_out := cl.CreateBuffer(ctx, cl.MEM_WRITE_ONLY, size, nil, &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create output buffer! Error value: %d", ret);
		cl.ReleaseMemObject(buffer_in);
		return nil, nil;
	}

	return buffer_in, buffer_out;
}

create_kernel :: proc(Program: cl.Program) -> cl.Kernel {
	ret: cl.Int;
	kernel := cl.CreateKernel(Program, "vector_scale", &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create kernel! Error value: %d", ret);
		return nil;
	}
	return kernel;
}

set_kernel_args :: proc(kernel: cl.Kernel, buffer_in: ^cl.Mem, buffer_out: ^cl.Mem, scale: ^f32) -> bool {
	if ret := cl.SetKernelArg(kernel, 0, size_of(cl.Mem), buffer_in); ret != cl.SUCCESS {
		log.errorf("Failed to set arg 0! Error value: %d", ret);
		return false;
	}
	if ret := cl.SetKernelArg(kernel, 1, size_of(cl.Mem), buffer_out); ret != cl.SUCCESS {
		log.errorf("Failed to set arg 1! Error value: %d", ret);
		return false;
	}
	if ret := cl.SetKernelArg(kernel, 2, size_of(f32), scale); ret != cl.SUCCESS {
		log.errorf("Failed to set arg 2! Error value: %d", ret);
		return false;
	}
	return true;
}

enqueue_kernel :: proc(queue: cl.Command_Queue, kernel: cl.Kernel) -> bool {
	global_size: c.size_t = 10;
	if ret := cl.EnqueueNDRangeKernel(queue, kernel, 1, nil, &global_size, nil, 0, nil, nil); ret != cl.SUCCESS {
		log.errorf("Failed to enqueue kernel! Error value: %d", ret);
		return false;
	}
	cl.Finish(queue);
	return true;
}

read_results :: proc(queue: cl.Command_Queue, buffer: cl.Mem) {
	output: [10]f32;
	size := cast(uint)len(output) * size_of(f32);
	if ret := cl.EnqueueReadBuffer(queue, buffer, cl.TRUE, 0, size, &output[0], 0, nil, nil); ret != cl.SUCCESS {
		log.errorf("Failed to read buffer! Error value: %d", ret);
		return;
	}

	for val, index in output {
		log.infof("Result[%d] = %f", index, val);
	}
}

main :: proc() {
	context.logger = log.create_console_logger();

	// pick appropriate platform and device
	Platform_ID, Device_ID := pick_platform_and_device();
	if Platform_ID == nil || Device_ID == nil do return;

	// create runtime context
	ctx := create_context(Device_ID);
	if ctx == nil do return;
	defer cl.ReleaseContext(ctx);
	
	// create Program to be run on the device
	program := create_program(ctx, Device_ID);
	if program == nil do return;
	defer cl.ReleaseProgram(program);

	// create command queue
	queue := create_command_queue(ctx, Device_ID);
	if queue == nil do return;
	defer cl.ReleaseCommandQueue(queue);

	// make input and output arrays
	buffer_in, buffer_out := create_buffers(ctx);
	if buffer_in == nil || buffer_out == nil do return;
	defer cl.ReleaseMemObject(buffer_in);
	defer cl.ReleaseMemObject(buffer_out);

	// create executable
	kernel := create_kernel(program);
	if kernel == nil do return;
	defer cl.ReleaseKernel(kernel);

	scale: f32 = 2.0;
	if !set_kernel_args(kernel, &buffer_in, &buffer_out, &scale) do return;

	if !enqueue_kernel(queue, kernel) do return;

	read_results(queue, buffer_out);
}
