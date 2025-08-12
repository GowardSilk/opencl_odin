package emulator;

import "core:c"
import "core:mem"

import cl "shared:opencl"

CreateBufferEx_NullCL :: proc "system" (this: ^Emulator, _context: Context_Null, flags: cl.Mem_Flags, host_ptr: ^$T) -> Maybe(Mem) {
	unimplemented();
}
CreateBufferEx_FullCL :: proc "system" (this: ^Emulator, _context: Context_Full, flags: cl.Mem_Flags, host_ptr: ^$T) -> Maybe(Mem) {
	ret: cl.Int;
	buf: Mem_Full;
	when intrinsics.type_is_slice(T) || intrinsics.type_is_dynamic_array(T) {
		buf = cl.CreateBuffer(_context, flags, size_of(host_ptr[0]) * len(host_ptr^), raw_data(host_ptr^), &ret);
	} else do unimplemented();

	if ret == cl.SUCCESS do return cast(Mem)buf;
	return nil;
}

GetPlatformIDs_FullCL :: proc(this: ^Emulator, num_entries: cl.Uint, platforms: [^]Platform_ID, num_platforms: ^cl.Uint) -> cl.Int {
	return cl.GetPlatformIDs(num_entries, cast([^]cl.Platform_ID)platforms, num_platforms);
}
GetPlatformIDs_NullCL :: proc(this: ^Emulator, num_entries: cl.Uint, platforms: [^]Platform_ID, num_platforms: ^cl.Uint) -> cl.Int {
	if platforms == nil {
		// return nof platforms
		if num_platforms == nil do return cl.INVALID_VALUE;
		num_platforms^ = cast(cl.Uint)len(Platform_ID_Null_Impl);
		return cl.SUCCESS;
	}

	if num_entries == 0 do return cl.INVALID_VALUE;

	platforms[0] = cast(Platform_ID)cast(uintptr)Platform_ID_Null_Impl.Dummy;
	return cl.SUCCESS;
}

GetDeviceIDs_FullCL :: proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int {
	return cl.GetDeviceIDs(cast(Platform_ID_Full)platform, device_type, num_entries, cast([^]Device_ID_Full)devices, num_devices);
}
GetDeviceIDs_NullCL :: proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int {
	if cast(Platform_ID_Null_Impl)cast(uintptr)platform != .Dummy {
		return cl.INVALID_PLATFORM;
	}

	if devices == nil {
		if num_devices == nil do return cl.INVALID_VALUE;
		num_devices^ = 1;
		return cl.SUCCESS;
	}

	// 1.2 or higher can support cl.DEVICE_TYPE_CUSTOM
	when #defined(cl.VERSION_1_2) {
		SUPPORTED_TYPES :: [?]cl.Device_Type { cl.DEVICE_TYPE_CUSTOM, cl.DEVICE_TYPE_DEFAULT, cl.DEVICE_TYPE_ALL };
	} else {
		SUPPORTED_TYPES :: [?]cl.Device_Type { cl.DEVICE_TYPE_DEFAULT, cl.DEVICE_TYPE_ALL };
	}

	if num_entries == 0 do return cl.INVALID_VALUE;

	for type in SUPPORTED_TYPES {
		if type == device_type {
			devices[0] = cast(Device_ID)cast(uintptr)Device_ID_Null_Impl.Dummy;
		}
	}

	return cl.INVALID_DEVICE_TYPE;
}

GetDeviceInfo_FullCL :: proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	return cl.GetDeviceInfo(cast(Device_ID_Full)device, param_name, param_value_size, param_value, param_value_size_ret);
}
GetDeviceInfo_NullCL :: proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	unimplemented();
}

GetProgramBuildInfo_FullCL :: proc(this: ^Emulator, program: Program, device: Device_ID, param_name: cl.Program_Build_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	return cl.GetProgramBuildInfo(cast(Program_Full)program, cast(Device_ID_Full)device, param_name, param_value_size, param_value, param_value_size_ret);
}
GetProgramBuildInfo_NullCL :: proc(this: ^Emulator, program: Program, device: Device_ID, param_name: cl.Program_Build_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	unimplemented();
}

GetKernelWorkGroupInfo_FullCL :: proc(this: ^Emulator, kernel: Kernel, device: Device_ID, param_name: cl.Kernel_Work_Group_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	return cl.GetKernelWorkGroupInfo(cast(Kernel_Full)kernel, cast(Device_ID_Full)device, param_name, param_value_size, param_value, param_value_size_ret);
}
GetKernelWorkGroupInfo_NullCL :: proc(this: ^Emulator, kernel: Kernel, device: Device_ID, param_name: cl.Kernel_Work_Group_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	unimplemented();
}

CreateContext_FullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	return cast(Context)cl.CreateContext(properties, num_devices, cast(^Device_ID_Full)devices, pfn_notify, user_data, errcode_ret);
}
CreateContext_NullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	if properties != nil || pfn_notify != nil || user_data != nil || num_devices > 1 do unimplemented();

	if num_devices == 0 || devices == nil {
		errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}
	if cast(Device_ID_Null_Impl)cast(uintptr)(devices^) != .Dummy {
		errcode_ret^ = cl.INVALID_DEVICE;
		return nil;
	}

	assert(this.kind == .Null);
	null := (cast(^Null_CL)this);
	if null._context != nil {
		// NOTE(GowardSilk): Recreating an object multiple times
		// is supported by OpenCL but not by US!!!
		errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	// TODO(GowardSilk): Consider adding custom allocator ?
	_context, merr := mem.new(Context_Null_Impl);
	if merr != .None {
		errcode_ret^ = cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
	_context^ = {
		device = .Dummy,
		queue = nil,
	};
	null._context = _context;
	return cast(Context)_context;
}

ReleaseContext_FullCL :: proc(this: ^Emulator, _context: Context) -> cl.Int {
	return cl.ReleaseContext(cast(Context_Full)_context);
}
ReleaseContext_NullCL :: proc(this: ^Emulator, _context: Context) -> cl.Int {
	if _context == nil do return cl.INVALID_VALUE;

	c := cast(^Context_Null_Impl)_context;
	c.rc -= 1;

	if c.rc == 0 {
		this->ReleaseCommandQueue(cast(Command_Queue)c.queue);
		mem.free(c);
	}

	return cl.SUCCESS;
}

CreateCommandQueue_FullCL :: proc(this: ^Emulator, _context: Context, device: Device_ID, properties: cl.Command_Queue_Properties, errcode_ret: ^cl.Int) -> Command_Queue {
	return auto_cast cl.CreateCommandQueue(cast(cl.Context)_context, cast(cl.Device_ID)device, properties, errcode_ret);
}
CreateCommandQueue_NullCL :: proc(this: ^Emulator, _context: Context, device: Device_ID, properties: cl.Command_Queue_Properties, errcode_ret: ^cl.Int) -> Command_Queue {
	if cast(Device_ID_Null_Impl)cast(uintptr)device != .Dummy {
		errcode_ret^ = cl.INVALID_DEVICE;
		return nil;
	}
	if properties != 0 {
		errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	assert(this.kind == .Null);
	null := (cast(^Null_CL)this);
	if null._context.queue != nil {
		// NOTE(GowardSilk): Recreating an object multiple times
		// is supported by OpenCL but not by US!!!
		errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	merr: mem.Allocator_Error;
	null._context.queue, merr = mem.new(Command_Queue_Null_Impl);
	if merr != .None {
		errcode_ret^ = cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
	return cast(Command_Queue)null._context.queue;
}

ReleaseCommandQueue_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	return cl.ReleaseCommandQueue(cast(Command_Queue_Full)command_queue);
}
ReleaseCommandQueue_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	if command_queue == nil do return cl.INVALID_VALUE;

	assert(this.kind == .Null);
	null := (cast(^Null_CL)this);
	// queue already freed with context's rc == 0
	if null._context == nil do return cl.SUCCESS;
	if cast(rawptr)null._context.queue != command_queue do return cl.INVALID_VALUE;

	q := cast(^Command_Queue_Null_Impl)command_queue;
	q.rc -= 1;

	if q.rc <= 0 {
		mem.delete(q.commands);
	}

	return cl.SUCCESS;
}

FinishCommandQueue_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	return cl.Finish(cast(Command_Queue_Full)command_queue);
}
FinishCommandQueue_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	unimplemented();
}

CreateBuffer_FullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	return cast(Mem)cl.CreateBuffer(cast(Context_Full)_context, flags, size, host_ptr, errcode_ret);
}
CreateBuffer_NullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	unimplemented();
}

ReleaseMemObject_FullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	return cl.ReleaseMemObject(cast(Mem_Full)memobj);
}
ReleaseMemObject_NullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	unimplemented();
}

CreateProgramWithSource_FullCL :: proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program {
	return cast(Program)cl.CreateProgramWithSource(cast(Context_Full)_context, count, strings, lengths, errcode_ret);
}
CreateProgramWithSource_NullCL :: proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program {
	assert(this.kind == .Null);
	null := (cast(^Null_CL)this);
	if null.program != nil {
		// NOTE(GowardSilk): Recreating an object multiple times
		// is supported by OpenCL but not by US!!!
		errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	merr: mem.Allocator_Error;
	null.program, merr = mem.new(Program_Null_Impl);
	if merr != .None {
		errcode_ret^ = cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
	null.program.rc = 1;
	return cast(Program)null.program;
}

BuildProgram_FullCL :: proc(this: ^Emulator, program: Program, num_devices: cl.Uint, device_list: ^Device_ID, options: cstring, pfn_notify: rawptr, user_data: rawptr) -> cl.Int {
	return cl.BuildProgram(cast(Program_Full)program, num_devices, cast(^Device_ID_Full)device_list, options, cast(proc "stdcall" (Program_Full, rawptr))pfn_notify, user_data);
}
BuildProgram_NullCL :: proc(this: ^Emulator, program: Program, num_devices: cl.Uint, device_list: ^Device_ID, options: cstring, pfn_notify: rawptr, user_data: rawptr) -> cl.Int {
	if options != nil || num_devices != 1 || pfn_notify != nil || user_data != nil do unimplemented();

	if cast(Device_ID_Null_Impl)cast(uintptr)(device_list^) != .Dummy {
		return cl.INVALID_VALUE;
	}

	return cl.SUCCESS;
}

ReleaseProgram_FullCL :: proc(this: ^Emulator, program: Program) -> cl.Int {
	return cl.ReleaseProgram(cast(Program_Full)program);
}
ReleaseProgram_NullCL :: proc(this: ^Emulator, program: Program) -> cl.Int {
	if program == nil do return cl.INVALID_VALUE;

	assert(this.kind == .Null);
	null := (cast(^Null_CL)this);
	if null.program == nil {
		// already deleted
		return cl.SUCCESS;
	}
	if cast(rawptr)null.program != program do return cl.INVALID_VALUE;

	null.program.rc -= 1;
	if null.program.rc <= 0 {
		for kernel in null.program.kernels {
			this->ReleaseKernel(kernel);
		}
		mem.free(null.program);
	}

	return cl.SUCCESS;
}

CreateKernel_FullCL :: proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel {
	return cast(Kernel)cl.CreateKernel(cast(Program_Full)program, kernel_name, errcode_ret);
}
CreateKernel_NullCL :: proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel {
	unimplemented();
}

SetKernelArg_FullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	return cl.SetKernelArg(cast(Kernel_Full)kernel, arg_index, arg_size, arg_value);
}
SetKernelArg_NullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	unimplemented();
}

ReleaseKernel_FullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	return cl.ReleaseKernel(cast(Kernel_Full)kernel);
}
ReleaseKernel_NullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	unimplemented();
}

EnqueueNDRangeKernel_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	return cl.EnqueueNDRangeKernel(cast(Command_Queue_Full)command_queue, cast(Kernel_Full)kernel, work_dim, global_work_offset, global_work_size, local_work_size, num_events_in_wait_list, event_wait_list, event);
}
EnqueueNDRangeKernel_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	unimplemented();
}

EnqueueReadBuffer_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	return cl.EnqueueReadBuffer(cast(Command_Queue_Full)command_queue, cast(Mem_Full)buffer, blocking_read, offset, size, ptr, num_events_in_wait_list, event_wait_list, event);
}
EnqueueReadBuffer_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	unimplemented();
}
