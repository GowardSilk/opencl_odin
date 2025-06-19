package video;

import "base:runtime"

import "core:c"
import "core:log"

import cl "shared:opencl"

/** @brief contains the data for a whole OpenCL pipeline */
OpenCL_Context :: struct {
    platform:   cl.Platform_Id,
    device:     cl.Device_Id,
    _context:   cl.Context,
    program:    cl.Program,
    queue:      cl.Command_Queue,
    buffers:    [dynamic]cl.Mem,
    // kernels will be compiled and saved, and then shared across contexts
    // in case of operation fusing, the kernels will fuse accordingly with
    // some intermediate buffers for results across operations
    // TODO(GowardSilk): We should build "dynamic kernel fusion" in the future so we achieve highest performance (at the cost of compiling it but that will not be measured anyway)
    kernels:    [Compute_Operation]cl.Kernel,
}

cl_context_init :: proc() -> (c: OpenCL_Context, err: Error) {
    @(static)
    kernels      := [?]cstring { CF_GAUSSIAN_BLUR, };
    @(static)
    kernel_sizes := [?]uint { CF_GAUSSIAN_BLUR_SIZE };
    @(static)
    kernel_names := [?]#type struct {name:cstring,type:Compute_Operation} {
        {name=CF_GAUSSIAN_BLUR_KERNEL1_NAME, type=.Convolution_Filter_Gauss_Horizontal_Op},
        {name=CF_GAUSSIAN_BLUR_KERNEL2_NAME, type=.Convolution_Filter_Gauss_Vertical_Op},
    };

    pick_platform(&c) or_return;
    pick_device(&c) or_return;
    create_context(&c) or_return;
    assemble_program(&c, kernels[:], kernel_sizes[:]) or_return;
    create_command_queue(&c) or_return;
    c.buffers   = make([dynamic]cl.Mem);
    for kernel in kernel_names {
        c.kernels[kernel.type] = compile_kernel(&c, kernel.name) or_return;
    }

    return c, .None;
}

cl_context_delete :: proc(c: ^OpenCL_Context) {
    delete_context(c^._context);
    delete_program(c^.program);
    delete_command_queue(c^.queue);
    for buffer in c^.buffers do delete_buffer(buffer);
    delete(c^.buffers);
    for kernel in c^.kernels do delete_kernel(kernel);
}

pick_platform :: proc(c: ^OpenCL_Context) -> (err: Error) {
	if ret := cl.GetPlatformIDs(1, &c^.platform, nil); ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to query platform id!", ret);
		return .Platform_Query_Fail;
	}

    return .None;
}

pick_device :: proc(c: ^OpenCL_Context) -> (err: Error) {
    if ret := cl.GetDeviceIDs(c^.platform, cl.DEVICE_TYPE_GPU, 1, &c^.device, nil); ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to query device id!", ret);
        return .Device_Query_Fail;
    }

    return .None;
}

create_context :: proc(c: ^OpenCL_Context) -> (err: Error) {
    when ODIN_DEBUG {
        ctx_error_callback :: proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr) {
            context = runtime.default_context()
            log.error(errinfo);
        }
    } else {
        ctx_error_callback: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr): nil;
    }

	ret: cl.Int;
	c^._context = cl.CreateContext(nil, 1, &c^.device, ctx_error_callback, nil, &ret);
	if ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to create Context!", ret);
		return .Context_Creation_Fail;
	}

	return .None;
}

delete_context :: #force_inline proc(_context: cl.Context) {
    cl.ReleaseContext(_context);
}

assemble_program :: proc(c: ^OpenCL_Context, sources: []cstring, source_sizes: []uint) -> (err: Error) {
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

	return .None;
}

delete_program :: #force_inline proc(program: cl.Program) {
    cl.ReleaseProgram(program);
}

create_buffer :: proc(c: ^OpenCL_Context, mem: $T, mem_sz: uint) -> (err: Error) {
    ret: cl.Int;
    buf := cl.CreateBuffer(c^._context, cl.MEM_COPY_HOST_PTR, cast(rawptr)&mem_sz, mem, &ret);
    if ret != cl.SUCCESS {
		cl_context_errlog(c, "Failed to create output buffer!", ret);
        return .Buffer_Allocation_Fail;
    }

    append(&c^.buffers, buf);

    return nil;
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

    return .None;
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

	return kernel, .None;
}

delete_kernel :: #force_inline proc(kernel: cl.Kernel) {
    cl.ReleaseKernel(kernel);
}

/** @brief converts cl error values into string representation */
err_to_name :: proc(err: cl.Int) -> string {
    switch err {
        case cl.DEVICE_NOT_FOUND: return "Device Not Found";
        case cl.DEVICE_NOT_AVAILABLE: return "Device Not Available";
        case cl.COMPILER_NOT_AVAILABLE: return "Compiler Not Available";
        case cl.MEM_OBJECT_ALLOCATION_FAILURE: return "Memory Object Allocation Failure";
        case cl.OUT_OF_RESOURCES: return "Out of Resources";
        case cl.OUT_OF_HOST_MEMORY: return "Out of Host Memory";
        case cl.PROFILING_INFO_NOT_AVAILABLE: return "Profiling Info Not Available";
        case cl.MEM_COPY_OVERLAP: return "Memory Copy Overlap";
        case cl.IMAGE_FORMAT_MISMATCH: return "Image Format Mismatch";
        case cl.IMAGE_FORMAT_NOT_SUPPORTED: return "Image Format Not Supported";
        case cl.BUILD_PROGRAM_FAILURE: return "Build Program Failure";
        case cl.MAP_FAILURE: return "Map Failure";
        case cl.MISALIGNED_SUB_BUFFER_OFFSET: return "Misaligned Sub-Buffer Offset";
        case cl.EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST: return "Execution Status Error for Events in Wait List";
        case cl.COMPILE_PROGRAM_FAILURE: return "Compile Program Failure";
        case cl.LINKER_NOT_AVAILABLE: return "Linker Not Available";
        case cl.LINK_PROGRAM_FAILURE: return "Link Program Failure";
        case cl.DEVICE_PARTITION_FAILED: return "Device Partition Failed";
        case cl.KERNEL_ARG_INFO_NOT_AVAILABLE: return "Kernel Arg Info Not Available";
        case cl.INVALID_VALUE: return "Invalid Value";
        case cl.INVALID_DEVICE_TYPE: return "Invalid Device Type";
        case cl.INVALID_PLATFORM: return "Invalid Platform";
        case cl.INVALID_DEVICE: return "Invalid Device";
        case cl.INVALID_CONTEXT: return "Invalid Context";
        case cl.INVALID_QUEUE_PROPERTIES: return "Invalid Queue Properties";
        case cl.INVALID_COMMAND_QUEUE: return "Invalid Command Queue";
        case cl.INVALID_HOST_PTR: return "Invalid Host Pointer";
        case cl.INVALID_MEM_OBJECT: return "Invalid Memory Object";
        case cl.INVALID_IMAGE_FORMAT_DESCRIPTOR: return "Invalid Image Format Descriptor";
        case cl.INVALID_IMAGE_SIZE: return "Invalid Image Size";
        case cl.INVALID_SAMPLER: return "Invalid Sampler";
        case cl.INVALID_BINARY: return "Invalid Binary";
        case cl.INVALID_BUILD_OPTIONS: return "Invalid Build Options";
        case cl.INVALID_PROGRAM: return "Invalid Program";
        case cl.INVALID_PROGRAM_EXECUTABLE: return "Invalid Program Executable";
        case cl.INVALID_KERNEL_NAME: return "Invalid Kernel Name";
        case cl.INVALID_KERNEL_DEFINITION: return "Invalid Kernel Definition";
        case cl.INVALID_KERNEL: return "Invalid Kernel";
        case cl.INVALID_ARG_INDEX: return "Invalid Argument Index";
        case cl.INVALID_ARG_VALUE: return "Invalid Argument Value";
        case cl.INVALID_ARG_SIZE: return "Invalid Argument Size";
        case cl.INVALID_KERNEL_ARGS: return "Invalid Kernel Arguments";
        case cl.INVALID_WORK_DIMENSION: return "Invalid Work Dimension";
        case cl.INVALID_WORK_GROUP_SIZE: return "Invalid Work Group Size";
        case cl.INVALID_WORK_ITEM_SIZE: return "Invalid Work Item Size";
        case cl.INVALID_GLOBAL_OFFSET: return "Invalid Global Offset";
        case cl.INVALID_EVENT_WAIT_LIST: return "Invalid Event Wait List";
        case cl.INVALID_EVENT: return "Invalid Event";
        case cl.INVALID_OPERATION: return "Invalid Operation";
        case cl.INVALID_GL_OBJECT: return "Invalid GL Object";
        case cl.INVALID_BUFFER_SIZE: return "Invalid Buffer Size";
        case cl.INVALID_MIP_LEVEL: return "Invalid Mip Level";
        case cl.INVALID_GLOBAL_WORK_SIZE: return "Invalid Global Work Size";
        case cl.INVALID_PROPERTY: return "Invalid Property";
        case cl.INVALID_IMAGE_DESCRIPTOR: return "Invalid Image Descriptor";
        case cl.INVALID_COMPILER_OPTIONS: return "Invalid Compiler Options";
        case cl.INVALID_LINKER_OPTIONS: return "Invalid Linker Options";
        case cl.INVALID_DEVICE_PARTITION_COUNT: return "Invalid Device Partition Count";
        case cl.INVALID_PIPE_SIZE: return "Invalid Pipe Size";
        case cl.INVALID_DEVICE_QUEUE: return "Invalid Device Queue";
        case cl.INVALID_SPEC_ID: return "Invalid Spec ID";
        case cl.MAX_SIZE_RESTRICTION_EXCEEDED: return "Max Size Restriction Exceeded";
    }
    log.assertf(false, "Unknown OpenCL error (%d)", err);
    return "";
}