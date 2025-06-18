package video;

import "base:runtime"

import "core:c"
import "core:log"

import cl "shared:opencl"

/** @brief specifies to which *kind* of device (aka computation unit) is the OpenCL_Context bounded to */
OpenCL_Context_Kind :: enum {
    GPU = cl.DEVICE_TYPE_GPU,
    CPU = cl.DEVICE_TYPE_CPU,
}

/** @brief contains the data for a whole OpenCL pipeline */
OpenCL_Context :: struct {
    kind:       OpenCL_Context_Kind,
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

OpenCL_Context_Manager :: struct {
    contexts: #sparse [OpenCL_Context_Kind]OpenCL_Context,
}

cl_context_manager_init :: proc() -> (m: OpenCL_Context_Manager, err: Error) {
    for kind in OpenCL_Context_Kind do m.contexts[kind] = cl_context_init(kind) or_return;
    return m, .None;
}

cl_context_manager_delete :: proc(m: ^OpenCL_Context_Manager) {
    for &ctx in m.contexts do cl_context_delete(&ctx);
}

cl_context_init :: proc(kind: OpenCL_Context_Kind) -> (c: OpenCL_Context, err: Error) {
    @(static)
    kernels      := [?]cstring { CF_GAUSSIAN_BLUR, };
    @(static)
    kernel_sizes := [?]uint { CF_GAUSSIAN_BLUR_SIZE };
    @(static)
    kernel_names := [?]#type struct {name:cstring,type:Compute_Operation} {
        {name=CF_GAUSSIAN_BLUR_KERNEL_NAME, type=.Convolution_Filter_Gauss_Op},
    };

    c.kind      = kind;
    c.platform  = pick_platform() or_return;
    c.device    = pick_device(kind, c.platform) or_return;
    c._context  = create_context(&c.device) or_return;
    c.program   = assemble_program(c._context, &c.device, kernels[:], kernel_sizes[:]) or_return;
    c.queue     = create_command_queue(c._context, c.device) or_return;
    c.buffers   = make([dynamic]cl.Mem);
    for kernel in kernel_names {
        c.kernels[kernel.type] = compile_kernel(c.program, kernel.name) or_return;
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

pick_platform :: proc() -> (platform: cl.Platform_Id, err: Error) {
	if ret := cl.GetPlatformIDs(1, &platform, nil); ret != cl.SUCCESS {
		log.errorf("Failed to query platform id! Error value: %d (aka %s)", ret, err_to_name(ret));
		return nil, .Platform_Query_Fail;
	}

    return platform, .None;
}

pick_device :: proc(kind: OpenCL_Context_Kind, platform: cl.Platform_Id) -> (device: cl.Device_Id, err: Error) {
    if ret := cl.GetDeviceIDs(platform, auto_cast kind, 1, &device, nil); ret != cl.SUCCESS {
		log.errorf("Failed to query device id! Error value: %d (aka %s)", ret, err_to_name(ret));
        return nil, .Device_Query_Fail;
    }

    return device, .None;
}

create_context :: proc(device: ^cl.Device_Id) -> (ctx: cl.Context, err: Error) {
    when ODIN_DEBUG {
        ctx_error_callback :: proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr) {
            context = runtime.default_context()
            log.error(errinfo);
        }
    } else {
        ctx_error_callback: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr): nil;
    }

	ret: cl.Int;
	ctx = cl.CreateContext(nil, 1, device, ctx_error_callback, nil, &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create Context! Error value: %d (aka %s)", ret, err_to_name(ret));
		return nil, .Context_Creation_Fail;
	}

	return ctx, .None;
}

delete_context :: #force_inline proc(_context: cl.Context) {
    cl.ReleaseContext(_context);
}

assemble_program :: proc(_context: cl.Context, device: ^cl.Device_Id, sources: []cstring, source_sizes: []uint) -> (program: cl.Program, err: Error) {
    ret: cl.Int;
	program = cl.CreateProgramWithSource(_context, cast(u32)len(sources), &sources[0], &source_sizes[0], &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create program! Error value: %d (aka %s)", ret, err_to_name(ret));
		return program, .Program_Allocation_Fail;
	}

	if ret = cl.BuildProgram(program, 1, device, nil, nil, nil); ret != cl.SUCCESS {
		log.errorf("Failed to compile program! Error value: %d (aka %s)", ret, err_to_name(ret));
		return program, .Program_Compilation_Fail;
	}

	return program, .None;
}

delete_program :: #force_inline proc(program: cl.Program) {
    cl.ReleaseProgram(program);
}

create_buffer :: proc(_context: cl.Context, mem: $T, mem_sz: uint) -> (buf: cl.Mem, err: Error) {
    ret: cl.Int;
    buf = cl.CreateBuffer(_context, cl.MEM_COPY_HOST_PTR, cast(rawptr)&mem_sz, mem, &ret);
    if ret != cl.SUCCESS {
		log.errorf("Failed to create output buffer! Error value: %d (aka %s)", ret, err_to_name(ret));
        return buf, .Buffer_Allocation_Fail;
    }

    return buf, nil;
}

delete_buffer :: #force_inline proc(buf: cl.Mem) {
    cl.ReleaseMemObject(buf);
}

create_command_queue :: proc(_context: cl.Context, device: cl.Device_Id) -> (queue: cl.Command_Queue, err: Error) {
	ret: cl.Int;
	queue = cl.CreateCommandQueue(_context, device, 0, &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create Command Queue! Error value: %d (aka %s)", ret, err_to_name(ret));
		return queue, .Command_Queue_Allocation_Fail;
	}

    return queue, .None;
}

delete_command_queue :: #force_inline proc(queue: cl.Command_Queue) {
    cl.ReleaseCommandQueue(queue);
}

compile_kernel :: proc(program: cl.Program, name: cstring) -> (kernel: cl.Kernel, err: Error) {
	ret: cl.Int;
	kernel = cl.CreateKernel(program, name, &ret);
	if ret != cl.SUCCESS {
		log.errorf("Failed to create kernel! Error value: %d (aka %s)", ret, err_to_name(ret));
		return kernel, .Kernel_Creation_Fail;
	}

	return kernel, .None;
}

delete_kernel :: #force_inline proc(kernel: cl.Kernel) {
    cl.ReleaseKernel(kernel);
}

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