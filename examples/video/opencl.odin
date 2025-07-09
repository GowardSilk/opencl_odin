package video;

import "base:runtime"

import "core:c"
import "core:log"
import "core:strings"

import cl "shared:opencl"

OpenCL_Context_Kernel :: struct {
    kernel: cl.Kernel,
    type: Compute_Operation,
}

/** @brief contains the data for a whole OpenCL pipeline */
OpenCL_Context :: struct {
    platform:   cl.Platform_ID,
    device:     cl.Device_ID,
    _context:   cl.Context,
    program:    cl.Program,
    queue:      cl.Command_Queue,
    buffers:    [dynamic]cl.Mem,
    // kernels will be compiled and saved, and then shared across contexts
    // in case of operation fusing, the kernels will fuse accordingly with
    // some intermediate buffers for results across operations
    // TODO(GowardSilk): We should build "dynamic kernel fusion" in the future so we achieve highest performance (at the cost of compiling it but that will not be measured anyway)
    kernels:    []OpenCL_Context_Kernel,
    operations: Compute_Operations,
}

cl_context_init :: proc(platform: cl.Platform_ID, device: cl.Device_ID, context_properties: []cl.Context_Properties) -> (c: OpenCL_Context, err: Error) {
    @(static)
    kernels      := [?]cstring { CF_GAUSSIAN_BLUR, CF_SOBEL_FILTER, CF_UNSHARP_MASK };
    @(static)
    kernel_sizes := [?]uint { CF_GAUSSIAN_BLUR_SIZE, CF_SOBEL_FILTER_SIZE, CF_UNSHARP_MASK_SIZE, };
    @(static)
    kernel_names := [?]#type struct {name:cstring,type:Compute_Operation} {
        {name=CF_GAUSSIAN_BLUR_KERNEL1_NAME, type=.Convolution_Filter_Gauss_Horizontal},
        {name=CF_GAUSSIAN_BLUR_KERNEL2_NAME, type=.Convolution_Filter_Gauss_Vertical},
        {name=CF_SOBEL_FILTER_KERNEL_NAME, type=.Convolution_Filter_Sobel},
        {name=CF_UNSHARP_MASK_KERNEL_NAME, type=.Convolution_Filter_Unsharp},
    };

    c.platform = platform;
    c.device = device;
    create_context(&c, context_properties) or_return;
    assemble_program(&c, kernels[:], kernel_sizes[:]) or_return;
    create_command_queue(&c) or_return;
    c.buffers = make([dynamic]cl.Mem);
    c.kernels = make([]OpenCL_Context_Kernel, len(kernel_names));
    for kernel, index in kernel_names {
        c.kernels[index].kernel = compile_kernel(&c, kernel.name) or_return; 
        c.kernels[index].type = kernel.type;
    }

    return c, .None;
}

cl_context_delete :: proc(c: ^OpenCL_Context) {
    delete_context(c^._context);
    delete_program(c^.program);
    delete_command_queue(c^.queue);
    for buffer in c^.buffers do delete_buffer(buffer);
    delete(c^.buffers);
    for kernel in c^.kernels do delete_kernel(kernel.kernel);
    delete(c^.kernels);
}

pick_device :: proc(c: ^OpenCL_Context) -> (err: Error) {
    if ret := cl.GetDeviceIDs(c^.platform, cl.DEVICE_TYPE_GPU, 1, &c^.device, nil); ret != cl.SUCCESS {
	cl_context_errlog(c, "Failed to query device id!", ret);
        return .Device_Query_Fail;
    }

    return .None;
}

create_context :: proc(c: ^OpenCL_Context, context_properties: []cl.Context_Properties) -> (err: Error) {
    when ODIN_DEBUG {
        ctx_error_callback :: proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr) {
            context = runtime.default_context()
            log.error(errinfo);
        }
    } else {
        ctx_error_callback: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr): nil;
    }

    ret: cl.Int;
    c^._context = cl.CreateContext(&context_properties[0], 1, &c^.device, ctx_error_callback, nil, &ret);
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
    mem := mem;

    ret: cl.Int;
    buf := cl.CreateBuffer(c^._context, cl.MEM_COPY_HOST_PTR, mem_sz, cast(rawptr)&mem, &ret);
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
