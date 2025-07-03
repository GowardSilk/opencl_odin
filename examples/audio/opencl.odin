package audio;

import "base:runtime"

import "core:c"
import "core:fmt"
import "core:log"
import "core:strings"

import cl "shared:opencl"

OpenCL_Error :: enum {
    None = 0,

    Platform_Query_Fail,
    Device_Query_Fail,
    Context_Creation_Fail,

    Program_Allocation_Fail,
    Program_Compilation_Fail,

    Buffer_Allocation_Fail,
    Command_Queue_Allocation_Fail,
    Kernel_Creation_Fail,
}

/** @brief contains the data for a whole OpenCL pipeline */
OpenCL_Context :: struct {
    platform:   cl.Platform_ID,
    device:     cl.Device_ID,
    _context:   cl.Context,
    program:    cl.Program,
    queue:      cl.Command_Queue,

    audio_buffer_in: cl.Mem,
    audio_buffer_out: cl.Mem,
    audio_buffer_out_host: []c.short, /**< array of latest processed frames */
    eat_pos: u64, /**< how much data has already been read from audio_buffer_out_host by device_data_proc */

    kernels: map[cstring]cl.Kernel,
}

init_cl_context :: proc() -> (c: OpenCL_Context, err: Error) {
    pick_platform(&c) or_return;
    pick_device(&c) or_return;
    create_context(&c) or_return;
    assemble_program(&c, AOK[:], AOK_SIZES[:]) or_return;
    create_command_queue(&c) or_return;
    c.kernels = make(map[cstring]cl.Kernel);
    c.eat_pos = 0;

    return c, nil;
}

delete_cl_context :: proc(c: ^OpenCL_Context) {
    delete_context(c^._context);
    delete_program(c^.program);
    delete_command_queue(c^.queue);
    if c^.audio_buffer_in  != nil do delete_buffer(c^.audio_buffer_in);
    if c^.audio_buffer_out != nil do delete_buffer(c^.audio_buffer_out);
    if c^.audio_buffer_out_host != nil do delete(c^.audio_buffer_out_host);
    for _, kernel in c^.kernels do delete_kernel(kernel);
    delete(c^.kernels);
    c^.eat_pos = 0;
}

pick_platform :: proc(c: ^OpenCL_Context) -> (err: Error) {
	if ret := cl.GetPlatformIDs(1, &c^.platform, nil); ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to query platform id!", ret);
		return .Platform_Query_Fail;
	}

    return nil;
}

pick_device :: proc(c: ^OpenCL_Context) -> (err: Error) {
    if ret := cl.GetDeviceIDs(c^.platform, cl.DEVICE_TYPE_GPU, 1, &c^.device, nil); ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to query device id!", ret);
        return .Device_Query_Fail;
    }

    return nil;
}

create_context :: proc(c: ^OpenCL_Context) -> (err: Error) {
    when ODIN_DEBUG {
        ctx_error_callback :: proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr) {
            context = runtime.default_context();
            log.error(errinfo);
        }
    } else {
        ctx_error_callback: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr) = nil;
    }

	ret: cl.Int;
	c^._context = cl.CreateContext(nil, 1, &c^.device, ctx_error_callback, nil, &ret);
	if ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to create Context!", ret);
		return .Context_Creation_Fail;
	}

	return nil;
}

delete_context :: #force_inline proc(_context: cl.Context) {
    cl.ReleaseContext(_context);
}

assemble_program :: proc(c: ^OpenCL_Context, sources: []cstring, source_sizes: []uint) -> (err: Error) {
    if len(sources) == 0 do return nil;

    ret: cl.Int;
	c^.program = cl.CreateProgramWithSource(c^._context, cast(u32)len(sources), &sources[0], &source_sizes[0], &ret);
	if ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to create program!", ret);
		return .Program_Allocation_Fail;
	}

	if ret = cl.BuildProgram(c^.program, 1, &c^.device, nil, nil, nil); ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to compile program!", ret);
		return .Program_Compilation_Fail;
	}

	return nil;
}

delete_program :: #force_inline proc(program: cl.Program) {
    cl.ReleaseProgram(program);
}

create_buffer :: proc(c: ^OpenCL_Context, mem: ^$T, mem_sz: uint, mem_flags: cl.Mem_Flags = cl.MEM_COPY_HOST_PTR) -> (buf: cl.Mem, err: Error) {
    ret: cl.Int;
    buf = cl.CreateBuffer(c^._context, mem_flags, mem_sz, cast(rawptr)mem, &ret);
    fmt.assertf(ret == cl.SUCCESS, "Failed to create output buffer(%v; %v)! %v; %s; %s", mem, (cast([^]i16)mem)[0], ret, err_to_name(ret));
    if ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to create output buffer!", ret);
        return nil, .Buffer_Allocation_Fail;
    }

    return buf, nil;
}

delete_buffer :: #force_inline proc(buf: cl.Mem) {
    cl.ReleaseMemObject(buf);
}

create_command_queue :: proc(c: ^OpenCL_Context) -> (err: Error) {
	ret: cl.Int;
	c^.queue = cl.CreateCommandQueue(c^._context, c^.device, 0, &ret);
	if ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to create Command Queue!", ret);
		return .Command_Queue_Allocation_Fail;
	}

    return nil;
}

delete_command_queue :: #force_inline proc(queue: cl.Command_Queue) {
    cl.ReleaseCommandQueue(queue);
}

compile_kernel :: proc(c: ^OpenCL_Context, name: cstring) -> (kernel: cl.Kernel, err: Error) {
	ret: cl.Int;
	kernel = cl.CreateKernel(c^.program, name, &ret);
	if ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to create kernel!", ret);
		return nil, .Kernel_Creation_Fail;
	}

	return kernel, nil;
}

delete_kernel :: #force_inline proc(kernel: cl.Kernel) {
    cl.ReleaseKernel(kernel);
}

cl_context_errlog :: #force_inline proc(c: ^OpenCL_Context, $msg: string, ret: cl.Int, loc := #caller_location) {
    log_str := cl_context_log(c, loc);
    err_name, err_desc := err_to_name(ret);
    log.errorf("%s Error value: %d (aka %s; \"%s\")\n%s\n", msg, ret, err_name, err_desc, log_str, location=loc);
    delete(log_str);
}
/** @brief logs the current context state */
cl_context_log :: proc(c: ^OpenCL_Context, loc := #caller_location) -> string {
    cl_context_log_platform :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        log_sz: uint;
        log_msg: []byte;

        platform_fields := [?]cl.Platform_Info {
            cl.PLATFORM_PROFILE,
            cl.PLATFORM_VERSION,
            cl.PLATFORM_NAME,
            cl.PLATFORM_VENDOR,
        };

        field_names := [?]string {
            "Profile",
            "Version",
            "Name",
            "Vendor",
        };
        assert(len(field_names) == len(platform_fields))

        strings.write_string(b, "\tPlatform:\n");

        for i in 0..<len(platform_fields) {
            cl.GetPlatformInfo(c^.platform, platform_fields[i], 0, nil, &log_sz);
            if log_sz != 0 {
                log_msg = make([]byte, log_sz);
                defer delete(log_msg);
                cl.GetPlatformInfo(c^.platform, platform_fields[i], log_sz, &log_msg[0], nil);
                fmt.sbprintfln(b, "\t\t%s: %s", field_names[i], cast(string)log_msg);
                log_sz = 0;
            }
        }

        // extensions
        count: uint;
        if ret := cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS_WITH_VERSION, 0, nil, &count); ret == cl.SUCCESS {
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS_WITH_VERSION, 0, nil, &count);
            exts := make([]cl.Name_Version, count);
            defer delete(exts);
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS_WITH_VERSION, count, &exts[0], nil);
            fmt.sbprintln(b, "\t\tExtensions:");
            for &ext in exts do fmt.sbprintfln(b, "\t\t\t%s: %d", cast(cstring)cast(^byte)&ext.name[0], ext.version);
        } else {
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS, 0, nil, &log_sz);
            log_msg := make([]byte, log_sz);
            defer delete(log_msg);
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS, log_sz, &log_msg[0], nil);
            fmt.sbprintln(b, "\t\tExtensions:");
            exts, err := strings.split(cast(string)log_msg, " ");
            defer delete(exts);
            assert(err == nil);
            for ext in exts do fmt.sbprintfln(b, "\t\t\t%s", ext);
        }
    }

    cl_context_log_device :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        strings.write_string(b, "\tDevice:\n");

        log_str :: proc(c: ^OpenCL_Context, info: cl.Device_Info, label: string, b: ^strings.Builder) {
            log_sz: uint;
            cl.GetDeviceInfo(c^.device, info, 0, nil, &log_sz);
            if log_sz > 0 {
                data := make([]byte, log_sz);
                defer delete(data);
                cl.GetDeviceInfo(c^.device, info, log_sz, &data[0], nil);
                fmt.sbprintfln(b, "\t\t%s: %s", label, cast(string)data);
            }
        }

        log_uint :: proc(c: ^OpenCL_Context, info: cl.Device_Info, label: string, b: ^strings.Builder) {
            val: uint;
            if cl.GetDeviceInfo(c^.device, info, size_of(val), &val, nil) == cl.SUCCESS {
                fmt.sbprintfln(b, "\t\t%s: %d", label, val);
            }
        }

        log_ulong :: proc(c: ^OpenCL_Context, info: cl.Device_Info, label: string, b: ^strings.Builder, use_units := true) {
            val: u64;
            if cl.GetDeviceInfo(c^.device, info, size_of(val), &val, nil) == cl.SUCCESS {
                if !use_units do fmt.sbprintfln(b, "\t\t%s: %d B", label, val);
                else do fmt.sbprintfln(b, "\t\t%s: %f MB", label, cast(f32)val/1_000_000);
            }
        }

        log_str(c, cl.DEVICE_NAME, "Name", b);
        log_str(c, cl.DEVICE_VENDOR, "Vendor", b);
        log_str(c, cl.DRIVER_VERSION, "Driver Version", b);
        log_str(c, cl.DEVICE_VERSION, "Device Version", b);
        // todo: WHY IS NOT THIS PRESENT in `cl` ?
        // log_str(c, cl.DEVICE_OPENCL_C_VERSION, "OpenCL C Version", b);

        log_uint(c, cl.DEVICE_MAX_COMPUTE_UNITS, "Max Compute Units", b);
        log_ulong(c, cl.DEVICE_GLOBAL_MEM_SIZE, "Global Memory Size", b);
        log_ulong(c, cl.DEVICE_LOCAL_MEM_SIZE, "Local Memory Size", b, false);
        log_ulong(c, cl.DEVICE_MAX_MEM_ALLOC_SIZE, "Max Allocation Size", b);
    }

    cl_context_log_context :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        ref_count: cl.Uint;
        strings.write_string(b, "\tContext:\n");
        if cl.GetContextInfo(c^._context, cl.CONTEXT_REFERENCE_COUNT, size_of(ref_count), &ref_count, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tReference Count: %d", ref_count);
        }
    }

    cl_context_log_program :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        log_sz: uint;
        strings.write_string(b, "\tProgram:\n");
        if cl.GetProgramBuildInfo(c^.program, c^.device, cl.PROGRAM_BUILD_LOG, 0, nil, &log_sz) == cl.SUCCESS && log_sz > 1 {
            log := make([]byte, log_sz);
            defer delete(log);
            cl.GetProgramBuildInfo(c^.program, c^.device, cl.PROGRAM_BUILD_LOG, log_sz, &log[0], nil);
            strings.write_string(b, "\t\tProgram Build Log:\n");
            fmt.sbprintfln(b, "\t\t%s", cast(string)log);
        }

        ref_count: cl.Uint;
        if cl.GetProgramInfo(c^.program, cl.PROGRAM_REFERENCE_COUNT, size_of(ref_count), &ref_count, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tReference Count: %d", ref_count);
        }
    }

    cl_context_log_queue :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        ref_count: cl.Uint;
        strings.write_string(b, "\tCommand Queue:\n");
        if cl.GetCommandQueueInfo(c^.queue, cl.QUEUE_REFERENCE_COUNT, size_of(ref_count), &ref_count, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tReference Count: %d", ref_count);
        }

        dev: cl.Device_ID;
        if cl.GetCommandQueueInfo(c^.queue, cl.QUEUE_DEVICE, size_of(dev), &dev, nil) == cl.SUCCESS {
            if dev == c^.device {
                fmt.sbprintln(b, "\t\tAssociated with primary device.");
            }
        }

        props: cl.Command_Queue_Properties;
        if cl.GetCommandQueueInfo(c^.queue, cl.QUEUE_PROPERTIES, size_of(props), &props, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tProperties: 0x%x", props);
        }
    }

    //cl_context_log_buffers :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
    //    strings.write_string(b, "\tBuffers:\n");
    //    for buffer in c^.buffers {
    //        size: uint;
    //        if cl.GetMemObjectInfo(buffer, cl.MEM_SIZE, size_of(size), &size, nil) == cl.SUCCESS {
    //            flags: cl.Mem_Flags;
    //            cl.GetMemObjectInfo(buffer, cl.MEM_FLAGS, size_of(flags), &flags, nil);
    //            fmt.sbprintfln(b, "\t\t- Size: %d B, Flags: 0x%x", size, flags);
    //        }
    //    }
    //}

    builder: strings.Builder;
    strings.builder_init(&builder);

    strings.write_string(&builder, "\n========== OpenCL Context [GPU] ==========\n");

    if c^.platform != nil     do cl_context_log_platform(c, &builder);
    if c^.device != nil       do cl_context_log_device(c, &builder);
    if c^._context != nil     do cl_context_log_context(c, &builder);
    if c^.program != nil      do cl_context_log_program(c, &builder);
    if c^.queue != nil        do cl_context_log_queue(c, &builder);
    //if len(c^.buffers) != 0   do cl_context_log_buffers(c, &builder);

    return strings.to_string(builder);
}

/** @brief converts cl error values into string representation */
err_to_name :: proc(err: cl.Int) -> (string, string) {
    // messages/values taken from https://streamhpc.com/blog/2013-04-28/opencl-error-codes/

    switch err {
        // Core Errors (1.x & 2.x)
        case cl.SUCCESS:                        return "CL_SUCCESS", "The sweet spot.";
        case cl.DEVICE_NOT_FOUND:              return "CL_DEVICE_NOT_FOUND", "clGetDeviceIDs if no OpenCL devices that matched device_type were found.";
        case cl.DEVICE_NOT_AVAILABLE:          return "CL_DEVICE_NOT_AVAILABLE", "clCreateContext if a device in devices is currently not available even though the device was returned by clGetDeviceIDs.";
        case cl.COMPILER_NOT_AVAILABLE:        return "CL_COMPILER_NOT_AVAILABLE", "clBuildProgram if a compiler is not available (CL_DEVICE_COMPILER_AVAILABLE is FALSE).";
        case cl.MEM_OBJECT_ALLOCATION_FAILURE: return "CL_MEM_OBJECT_ALLOCATION_FAILURE", "if there is a failure to allocate memory for buffer object.";
        case cl.OUT_OF_RESOURCES:              return "CL_OUT_OF_RESOURCES", "if there is a failure to allocate resources required by the OpenCL implementation on the device.";
        case cl.OUT_OF_HOST_MEMORY:            return "CL_OUT_OF_HOST_MEMORY", "if there is a failure to allocate resources required by the OpenCL implementation on the host.";
        case cl.PROFILING_INFO_NOT_AVAILABLE:  return "CL_PROFILING_INFO_NOT_AVAILABLE", "clGetEventProfilingInfo if profiling info is not available for the event.";
        case cl.MEM_COPY_OVERLAP:             return "CL_MEM_COPY_OVERLAP", "clEnqueueCopyBuffer/Image if regions overlap.";
        case cl.IMAGE_FORMAT_MISMATCH:        return "CL_IMAGE_FORMAT_MISMATCH", "clEnqueueCopyImage if src and dst do not use the same image format.";
        case cl.IMAGE_FORMAT_NOT_SUPPORTED:   return "CL_IMAGE_FORMAT_NOT_SUPPORTED", "clCreateImage if the image_format is not supported.";
        case cl.BUILD_PROGRAM_FAILURE:        return "CL_BUILD_PROGRAM_FAILURE", "clBuildProgram if there is a failure to build the program executable.";
        case cl.MAP_FAILURE:                  return "CL_MAP_FAILURE", "clEnqueueMapBuffer/Image if there is a failure to map the requested region.";
        case cl.MISALIGNED_SUB_BUFFER_OFFSET: return "CL_MISALIGNED_SUB_BUFFER_OFFSET", "if sub-buffer offset is not aligned.";
        case cl.EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST:
            return "CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST",
                "if the execution status of any event in wait-list is a negative integer.";
        case cl.COMPILE_PROGRAM_FAILURE:      return "CL_COMPILE_PROGRAM_FAILURE", "clCompileProgram if there is a failure to compile the program source.";
        case cl.LINKER_NOT_AVAILABLE:         return "CL_LINKER_NOT_AVAILABLE", "clLinkProgram if a linker is not available (CL_DEVICE_LINKER_AVAILABLE is FALSE).";
        case cl.LINK_PROGRAM_FAILURE:         return "CL_LINK_PROGRAM_FAILURE", "clLinkProgram if there is a failure to link the compiled binaries.";
        case cl.DEVICE_PARTITION_FAILED:      return "CL_DEVICE_PARTITION_FAILED", "clCreateSubDevices if the device could not be partitioned.";
        case cl.KERNEL_ARG_INFO_NOT_AVAILABLE:return "CL_KERNEL_ARG_INFO_NOT_AVAILABLE", "clGetKernelArgInfo if the argument information is not available.";

        // Compile-time / parameter errors
        case cl.INVALID_VALUE:                return "CL_INVALID_VALUE", "if value is not valid or parameters in a set of values are not appropriate.";
        case cl.INVALID_DEVICE_TYPE:          return "CL_INVALID_DEVICE_TYPE", "if an invalid device_type is given.";
        case cl.INVALID_PLATFORM:             return "CL_INVALID_PLATFORM", "if an invalid platform was given.";
        case cl.INVALID_DEVICE:               return "CL_INVALID_DEVICE", "if devices contains an invalid device.";
        case cl.INVALID_CONTEXT:              return "CL_INVALID_CONTEXT", "if context is not a valid context.";
        case cl.INVALID_QUEUE_PROPERTIES:     return "CL_INVALID_QUEUE_PROPERTIES", "if properties are not supported by the device.";
        case cl.INVALID_COMMAND_QUEUE:        return "CL_INVALID_COMMAND_QUEUE", "if command_queue is not a valid command-queue.";
        case cl.INVALID_HOST_PTR:             return "CL_INVALID_HOST_PTR", "if host_ptr is NULL and CL_MEM_USE_HOST_PTR or CL_MEM_COPY_HOST_PTR is specified.";
        case cl.INVALID_MEM_OBJECT:           return "CL_INVALID_MEM_OBJECT", "if memobj is not a valid memory object.";
        case cl.INVALID_IMAGE_FORMAT_DESCRIPTOR:
                                            return "CL_INVALID_IMAGE_FORMAT_DESCRIPTOR", "if image_format is not a valid descriptor.";
        case cl.INVALID_IMAGE_SIZE:           return "CL_INVALID_IMAGE_SIZE", "if image dimensions or row/array pitches are not valid.";
        case cl.INVALID_SAMPLER:              return "CL_INVALID_SAMPLER", "if sampler is not a valid sampler.";
        case cl.INVALID_BINARY:               return "CL_INVALID_BINARY", "if the program binary is not valid.";
        case cl.INVALID_BUILD_OPTIONS:        return "CL_INVALID_BUILD_OPTIONS", "if the build options are invalid.";
        case cl.INVALID_PROGRAM:              return "CL_INVALID_PROGRAM", "if program is not a valid program object.";
        case cl.INVALID_PROGRAM_EXECUTABLE:   return "CL_INVALID_PROGRAM_EXECUTABLE", "if program executable is not valid.";
        case cl.INVALID_KERNEL_NAME:          return "CL_INVALID_KERNEL_NAME", "if the kernel name is not found in program.";
        case cl.INVALID_KERNEL_DEFINITION:    return "CL_INVALID_KERNEL_DEFINITION", "if kernel definition is invalid.";
        case cl.INVALID_KERNEL:               return "CL_INVALID_KERNEL", "if kernel object is not valid.";
        case cl.INVALID_ARG_INDEX:            return "CL_INVALID_ARG_INDEX", "if argument index is invalid.";
        case cl.INVALID_ARG_VALUE:            return "CL_INVALID_ARG_VALUE", "if argument value is not valid.";
        case cl.INVALID_ARG_SIZE:             return "CL_INVALID_ARG_SIZE", "if argument size does not match the size of the data type.";
        case cl.INVALID_KERNEL_ARGS:          return "CL_INVALID_KERNEL_ARGS", "if kernel arguments have not been set or are invalid.";
        case cl.INVALID_WORK_DIMENSION:       return "CL_INVALID_WORK_DIMENSION", "if work_dim is invalid.";
        case cl.INVALID_WORK_GROUP_SIZE:      return "CL_INVALID_WORK_GROUP_SIZE", "if work-group size is invalid.";
        case cl.INVALID_WORK_ITEM_SIZE:       return "CL_INVALID_WORK_ITEM_SIZE", "if an individual work-item size is invalid.";
        case cl.INVALID_GLOBAL_OFFSET:        return "CL_INVALID_GLOBAL_OFFSET", "if global_offset is invalid.";
        case cl.INVALID_EVENT_WAIT_LIST:      return "CL_INVALID_EVENT_WAIT_LIST", "if event_wait_list is NULL but num_events_in_wait_list > 0, or vice versa.";
        case cl.INVALID_EVENT:                return "CL_INVALID_EVENT", "if event objects are not valid.";
        case cl.INVALID_OPERATION:            return "CL_INVALID_OPERATION", "if the operation is invalid for the current state of the object.";
        case cl.INVALID_GL_OBJECT:           return "CL_INVALID_GL_OBJECT", "if associated GL object is not valid.";
        case cl.INVALID_BUFFER_SIZE:          return "CL_INVALID_BUFFER_SIZE", "if buffer size is zero.";
        case cl.INVALID_MIP_LEVEL:            return "CL_INVALID_MIP_LEVEL", "if mip-level is invalid.";
        case cl.INVALID_GLOBAL_WORK_SIZE:     return "CL_INVALID_GLOBAL_WORK_SIZE", "if global work size is not a multiple of the work-group size.";
        case cl.INVALID_PROPERTY:             return "CL_INVALID_PROPERTY", "if property name is invalid.";
        case cl.INVALID_IMAGE_DESCRIPTOR:     return "CL_INVALID_IMAGE_DESCRIPTOR", "if image descriptor is invalid.";
        case cl.INVALID_COMPILER_OPTIONS:     return "CL_INVALID_COMPILER_OPTIONS", "if compiler options are invalid.";
        case cl.INVALID_LINKER_OPTIONS:       return "CL_INVALID_LINKER_OPTIONS", "if linker options are invalid.";
        case cl.INVALID_DEVICE_PARTITION_COUNT:
                                            return "CL_INVALID_DEVICE_PARTITION_COUNT", "if partition count is invalid.";
        case cl.INVALID_PIPE_SIZE:            return "CL_INVALID_PIPE_SIZE", "if pipe size is invalid.";
        case cl.INVALID_DEVICE_QUEUE:         return "CL_INVALID_DEVICE_QUEUE", "if device queue is invalid.";
        case cl.INVALID_SPEC_ID:              return "CL_INVALID_SPEC_ID", "if specialization constant ID is invalid.";
        case cl.MAX_SIZE_RESTRICTION_EXCEEDED:
                                            return "CL_MAX_SIZE_RESTRICTION_EXCEEDED", "if max size restriction exceeded.";

        // KHR / Extension Errors
        case cl.INVALID_GL_SHAREGROUP_REFERENCE_KHR:
                                            return "CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR", "if the GL sharegroup reference is invalid.";
        case cl.PLATFORM_NOT_FOUND_KHR:       return "CL_PLATFORM_NOT_FOUND_KHR", "if no OpenCL platforms found.";
        case cl.INVALID_D3D10_DEVICE_KHR:     return "CL_INVALID_D3D10_DEVICE_KHR", "if D3D10 device for interop is invalid.";

        // NVIDIA vendor-specific
        case -9999:
            return "CL_DEVICE_ILLEGAL_READ_WRITE_NV", "Illegal read or write to a buffer (NVIDIA).";

        case:
            return "UNKNOWN_ERROR", "Unknown OpenCL error code.";
    }
}