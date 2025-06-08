package main;

import "base:runtime"
import "core:c"
import "core:log"

import cl "opencl"

/**
 * @brief picks platform and device IDs based on max compute unit count
 * @return nil pair if any query failed, other the most "performant" device and platform
 */
pick_platform_and_device :: proc() -> (cl.cl_platform_id, cl.cl_device_id) {
	// query all available platforms
	all_platforms: []cl.cl_platform_id;
	num_all_platforms: cl.cl_uint = 0;
	if ret := cl.clGetPlatformIDs(0, nil, &num_all_platforms); ret != cl.CL_SUCCESS {
		log.errorf("Failed to query platform ids! Error value: %d", ret);
		return nil, nil;
	}
	all_platforms = make([]cl.cl_platform_id, num_all_platforms);
	defer delete(all_platforms);
	if ret := cl.clGetPlatformIDs(num_all_platforms, &all_platforms[0], nil); ret != cl.CL_SUCCESS {
		log.errorf("Failed to query platform ids! Error value: %d", ret);
		return nil, nil;
	}

	// try to pick the most "performant" one
	// this is technically an overkill but it should demonstrate the "filtering"
	// and device query
	best_platform: cl.cl_platform_id;
	best_device: cl.cl_device_id;
    max_compute_units: cl.cl_uint = 0;

    for i: cl.cl_uint = 0; i < num_all_platforms; i += 1 {
        devices: [10]cl.cl_device_id;
        num_devices: cl.cl_uint;
        cl.clGetDeviceIDs(all_platforms[i], cl.CL_DEVICE_TYPE_ALL, 10, &devices[0], &num_devices);

        for j: cl.cl_uint = 0; j < num_devices; j += 1 {
            compute_units: cl.cl_uint;

            cl.clGetDeviceInfo(devices[j], cl.CL_DEVICE_MAX_COMPUTE_UNITS, size_of(compute_units), &compute_units, nil);

            if (compute_units > max_compute_units) {
                max_compute_units = compute_units;
                best_platform = all_platforms[i];
                best_device = devices[j];
            }
        }
    }

	if best_platform != nil {
		platform_name: [128]cl.cl_uchar;
		cl.clGetPlatformInfo(best_platform, cl.CL_PLATFORM_NAME, size_of(platform_name), cast(rawptr)&platform_name[0], nil);
		log.infof("Best Platform: %s", platform_name);
	}
	if best_device != nil {
		device_name: [128]cl.cl_uchar;
		cl.clGetDeviceInfo(best_device, cl.CL_DEVICE_NAME, size_of(device_name), cast(rawptr)&device_name[0], nil);

		log.infof("Best Device: %s", device_name);
		log.infof("Clock Compute units: %d", max_compute_units);
	}

	return best_platform, best_device;
}

ctx_error_callback :: proc "stdcall" (errinfo: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr) {
	context = runtime.default_context()
	log.error(cast(cstring)cast(^u8)errinfo);
}

/**
 * @brief creates device context for the picked device id
 * @note function does not validate `device` parameter! assumes to be valid
 * @return `nil` when clCreateContext failed to initialize, otherwise valid handle to cl_context
 */
create_context :: proc(device: cl.cl_device_id) -> cl.cl_context {
	device := device

	ret: cl.cl_int;
	ctx := cl.clCreateContext(nil, 1, &device, ctx_error_callback, nil, &ret);
	if ret != cl.CL_SUCCESS {
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
create_program :: proc(ctx: cl.cl_context, device: cl.cl_device_id) -> cl.cl_program {
	device := device;

	ret: cl.cl_int;

	program_source := #load("test_program.cl");
	program_source_ptr := cast(^c.schar)&program_source[0];
	program_source_size := cast(uint)len(program_source);

	program := cl.clCreateProgramWithSource(ctx, 1, &program_source_ptr, &program_source_size, &ret);
	if ret != cl.CL_SUCCESS {
		log.errorf("Failed to create Program! Error value: %d", ret);
		return nil;
	}

	ret = cl.clBuildProgram(program, 1, &device, nil, nil, nil);
	if ret != cl.CL_SUCCESS {
		log.errorf("Failed to compile Program! Error value: %d", ret);
		return nil;
	}

	return program;
}

create_command_queue :: proc(ctx: cl.cl_context, device: cl.cl_device_id) -> cl.cl_command_queue {
	ret: cl.cl_int;
	queue := cl.clCreateCommandQueue(ctx, device, 0, &ret);
	if ret != cl.CL_SUCCESS {
		log.errorf("Failed to create Command Queue! Error value: %d", ret);
		return nil;
	}
	return queue;
}

create_buffers :: proc(ctx: cl.cl_context) -> (cl.cl_mem, cl.cl_mem) {
	data: [10]f32 = {1,2,3,4,5,6,7,8,9,10};
	size := cast(uint)len(data) * size_of(f32);

	ret: cl.cl_int;
	buffer_in := cl.clCreateBuffer(ctx, cl.CL_MEM_READ_ONLY | cl.CL_MEM_COPY_HOST_PTR, size, &data[0], &ret);
	if ret != cl.CL_SUCCESS {
		log.errorf("Failed to create input buffer! Error value: %d", ret);
		return nil, nil;
	}

	buffer_out := cl.clCreateBuffer(ctx, cl.CL_MEM_WRITE_ONLY, size, nil, &ret);
	if ret != cl.CL_SUCCESS {
		log.errorf("Failed to create output buffer! Error value: %d", ret);
		cl.clReleaseMemObject(buffer_in);
		return nil, nil;
	}

	return buffer_in, buffer_out;
}

create_kernel :: proc(program: cl.cl_program) -> cl.cl_kernel {
	ret: cl.cl_int;
	kernel := cl.clCreateKernel(program, "vector_scale", &ret);
	if ret != cl.CL_SUCCESS {
		log.errorf("Failed to create kernel! Error value: %d", ret);
		return nil;
	}
	return kernel;
}

set_kernel_args :: proc(kernel: cl.cl_kernel, buffer_in: ^cl.cl_mem, buffer_out: ^cl.cl_mem, scale: ^f32) -> bool {
	if ret := cl.clSetKernelArg(kernel, 0, size_of(cl.cl_mem), buffer_in); ret != cl.CL_SUCCESS {
		log.errorf("Failed to set arg 0! Error value: %d", ret);
		return false;
	}
	if ret := cl.clSetKernelArg(kernel, 1, size_of(cl.cl_mem), buffer_out); ret != cl.CL_SUCCESS {
		log.errorf("Failed to set arg 1! Error value: %d", ret);
		return false;
	}
	if ret := cl.clSetKernelArg(kernel, 2, size_of(f32), scale); ret != cl.CL_SUCCESS {
		log.errorf("Failed to set arg 2! Error value: %d", ret);
		return false;
	}
	return true;
}

enqueue_kernel :: proc(queue: cl.cl_command_queue, kernel: cl.cl_kernel) -> bool {
	global_size: c.size_t = 10;
	if ret := cl.clEnqueueNDRangeKernel(queue, kernel, 1, nil, &global_size, nil, 0, nil, nil); ret != cl.CL_SUCCESS {
		log.errorf("Failed to enqueue kernel! Error value: %d", ret);
		return false;
	}
	cl.clFinish(queue);
	return true;
}

read_results :: proc(queue: cl.cl_command_queue, buffer: cl.cl_mem) {
	output: [10]f32;
	size := cast(uint)len(output) * size_of(f32);
	if ret := cl.clEnqueueReadBuffer(queue, buffer, cl.CL_TRUE, 0, size, &output[0], 0, nil, nil); ret != cl.CL_SUCCESS {
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
	platform_id, device_id := pick_platform_and_device();
	if platform_id == nil || device_id == nil do return;

	// create runtime context
	ctx := create_context(device_id);
	if ctx == nil do return;
	defer cl.clReleaseContext(ctx);
	
	// create program to be run on the device
	program := create_program(ctx, device_id);
	if program == nil do return;
	defer cl.clReleaseProgram(program);

	// create command queue
	queue := create_command_queue(ctx, device_id);
	if queue == nil do return;
	defer cl.clReleaseCommandQueue(queue);

	// make input and output arrays
	buffer_in, buffer_out := create_buffers(ctx);
	if buffer_in == nil || buffer_out == nil do return;
	defer cl.clReleaseMemObject(buffer_in);
	defer cl.clReleaseMemObject(buffer_out);

	// create executable
	kernel := create_kernel(program);
	if kernel == nil do return;
	defer cl.clReleaseKernel(kernel);

	scale: f32 = 2.0;
	if !set_kernel_args(kernel, &buffer_in, &buffer_out, &scale) do return;

	if !enqueue_kernel(queue, kernel) do return;

	read_results(queue, buffer_out);
}
