package emulator;

import "base:runtime"
import "base:intrinsics"

import "core:c"
import "core:fmt"
import "core:mem"
import "core:sync"
import "core:thread"
import "core:sys/windows"
import "core:container/intrusive/list"

import cl "shared:opencl"

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
		num_devices^ = len(Device_ID_Null_Impl);
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
			return cl.SUCCESS;
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
	assert(this.kind == .Null);
	if cast(Device_ID_Null_Impl)device != .Dummy do return cl.INVALID_VALUE;
	null := cast(^Null_CL)this;

	if param_name == cl.KERNEL_WORK_GROUP_SIZE {
		assert(param_value != nil);
		p := cast(^c.size_t)param_value;
		p^ = auto_cast ndrange_len(&null._context.queue.ndrange);
		return cl.SUCCESS;
	}

	unimplemented();
}

CreateContext_FullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	return cast(Context)cl.CreateContext(properties, num_devices, cast(^Device_ID_Full)devices, pfn_notify, user_data, errcode_ret);
}
CreateContext_NullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	if properties != nil || pfn_notify != nil || user_data != nil || num_devices > 1 do unimplemented();

	if num_devices == 0 || devices == nil {
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}
	if cast(Device_ID_Null_Impl)cast(uintptr)(devices^) != .Dummy {
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_DEVICE;
		return nil;
	}

	assert(this.kind == .Null);
	null := (cast(^Null_CL)this);
	if null._context != nil {
		// NOTE(GowardSilk): Recreating an object multiple times
		// is supported by OpenCL but not by US!!!
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	// TODO(GowardSilk): Consider adding custom allocator ?
	_context, merr := mem.new(Context_Null_Impl);
	if merr != .None {
		if errcode_ret != nil do errcode_ret^ = cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
	_context^ = {
		device = .Dummy,
		queue = nil,
		rc = 1,
	};
	null._context = _context;
	return cast(Context)_context;
}

ReleaseContext_FullCL :: proc(this: ^Emulator, _context: Context) -> cl.Int {
	return cl.ReleaseContext(cast(Context_Full)_context);
}
ReleaseContext_NullCL :: proc(this: ^Emulator, _context: Context) -> cl.Int {
	assert(this.kind == .Null);
	if _context == nil do return cl.INVALID_VALUE;

	c := cast(^Context_Null_Impl)_context;
	c.rc -= 1;

	if c.rc == 0 {
		this->ReleaseCommandQueue(cast(Command_Queue)c.queue);
		mem.free(c);
		null := (cast(^Null_CL)this);
		null._context = nil;
	}

	return cl.SUCCESS;
}

CreateCommandQueue_FullCL :: proc(this: ^Emulator, _context: Context, device: Device_ID, properties: cl.Command_Queue_Properties, errcode_ret: ^cl.Int) -> Command_Queue {
	return auto_cast cl.CreateCommandQueue(cast(cl.Context)_context, cast(cl.Device_ID)device, properties, errcode_ret);
}
CreateCommandQueue_NullCL :: proc(this: ^Emulator, _context: Context, device: Device_ID, properties: cl.Command_Queue_Properties, errcode_ret: ^cl.Int) -> Command_Queue {
	if cast(Device_ID_Null_Impl)cast(uintptr)device != .Dummy {
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_DEVICE;
		return nil;
	}
	if properties != 0 {
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	assert(this.kind == .Null);
	null := (cast(^Null_CL)this);
	if null._context.queue != nil {
		// NOTE(GowardSilk): Recreating an object multiple times
		// is supported by OpenCL but not by US!!!
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	merr: mem.Allocator_Error;
	null._context.queue, merr = mem.new(Command_Queue_Null_Impl);
	if merr != .None {
		if errcode_ret != nil do errcode_ret^ = cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
	null._context.queue.rc = 1;

	when ODIN_OS == .Windows {
		sys_info: windows.SYSTEM_INFO;
		windows.GetSystemInfo(&sys_info);
		null._context.queue.ndrange = ndrange_init(cast(int)sys_info.dwNumberOfProcessors).?;
		fmt.eprintfln("Number of \"processors\": %d", sys_info.dwNumberOfProcessors);
	} else do unimplemented("Unsupported OS!");

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
		ndrange_destroy(&null._context.queue.ndrange);
		mem.free(q);
		null._context.queue = nil;
	}

	return cl.SUCCESS;
}

FinishCommandQueue_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	return cl.Finish(cast(Command_Queue_Full)command_queue);
}
FinishCommandQueue_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	// unused
	return cl.SUCCESS;
}

CreateBuffer_FullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	return cast(Mem)cl.CreateBuffer(cast(Context_Full)_context, flags, size, host_ptr, errcode_ret);
}
CREATE_BUFFER_SUPPORTED_FLAGS: cl.Mem_Flags : cl.MEM_USE_HOST_PTR | cl.MEM_WRITE_ONLY | cl.MEM_READ_ONLY | cl.MEM_READ_WRITE;
CreateBuffer_NullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	// check if `flags' contain unsupported flags
	// this is inverted implication in bitwise: ~(~flags | SUPPORTED_FLAGS)
	if (flags & ~CREATE_BUFFER_SUPPORTED_FLAGS) != 0 {
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}

	if (flags & cl.MEM_USE_HOST_PTR) != 0 {
		memobj, merr := mem.new(Mem_Null_Impl);
		if merr != .None {
			if errcode_ret != nil do errcode_ret^ = cl.OUT_OF_RESOURCES;
			return nil;
		}
		memobj^ = {
			rc = 1,
			size = size,
			data = host_ptr,
			flags = flags,
		};

		c := cast(^Context_Null_Impl)_context;
		list.push_back(&c.memobjs, &memobj.node);

		return cast(Mem)memobj;
	}

	unreachable();
}

ReleaseMemObject_FullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	return cl.ReleaseMemObject(cast(Mem_Full)memobj);
}
ReleaseMemObject_NullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	assert(this.kind == .Null);
	null := cast(^Null_CL)this;
	if null._context == nil {
		return cl.INVALID_VALUE;
	}

	m := cast(^Mem_Null_Impl)memobj;
	list.remove(&null._context.memobjs, &(cast(^Mem_Null_Impl)memobj)^.node);
	mem.free(memobj);
	return cl.SUCCESS;
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
		if errcode_ret != nil do errcode_ret^ = cl.INVALID_VALUE;
		return nil;
	}
	
	when ODIN_DEBUG {
		if strings != nil || lengths != nil {
			fmt.eprintfln("warning: in Null_CL, `count' and `strings' and `lengths' parameters are being ignored!");
		}
	}

	merr: mem.Allocator_Error;
	null.program, merr = mem.new(Program_Null_Impl);
	if merr != .None {
		if errcode_ret != nil do errcode_ret^ = cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
	null.program.rc = 1;
	null.program.kernels, merr = mem.make([]Kernel_Null_Impl, cast(int)count);
	if merr != .None {
		if errcode_ret != nil do errcode_ret^ = cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
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
		for &kernel in null.program.kernels {
			this->ReleaseKernel(cast(Kernel)&kernel);
		}
		mem.delete(null.program.kernels);
		mem.free(null.program);
		null.program = nil;
	}

	return cl.SUCCESS;
}

CreateKernel_FullCL :: proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel {
	return cast(Kernel)cl.CreateKernel(cast(Program_Full)program, kernel_name, errcode_ret);
}
CreateKernel_NullCL :: proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel {
	unimplemented("This function is unsupported (because it has no meaning) for Null_CL emulator! Use emulator.CreateKernel_Null instead!");
}

SetKernelArg_FullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	return cl.SetKernelArg(cast(Kernel_Full)kernel, arg_index, arg_size, arg_value);
}
SetKernelArg_NullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	assert(this.kind == .Null);

	k := cast(^Kernel_Null_Impl)kernel;
	p := (cast(^Null_CL)this).program;

	kernel_in := false;
	for &ker in p.kernels do if auto_cast &ker == kernel {
		kernel_in = true;
		break;
	}
	if !kernel_in || cast(int)arg_index >= len(k.args) do return cl.INVALID_VALUE;

	#no_bounds_check arg := &k.args[arg_index];

	if arg.local {
		if arg_value != nil do return cl.INVALID_VALUE;
		return cl.SUCCESS; // have to allocate when enqueueing this kernel
	}

	if arg.value != nil {
		mem.free(arg.value);
		arg.value = nil;
	}

	new_value, merr := mem.alloc_bytes_non_zeroed(cast(int)arg_size);
	if merr != .None do return cl.OUT_OF_HOST_MEMORY;

	arg.value = raw_data(new_value);
	mem.copy(arg.value, arg_value, cast(int)arg_size);
	arg.size  = arg_size;

	return cl.SUCCESS;
}

ReleaseKernel_FullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	return cl.ReleaseKernel(cast(Kernel_Full)kernel);
}
ReleaseKernel_NullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	assert(this.kind == .Null);

	k := cast(^Kernel_Null_Impl)kernel;
	p := (cast(^Null_CL)this).program;
	kernel_in := false;
	for &ker in p.kernels do if auto_cast &ker == kernel {
		kernel_in = true;
		break;
	}
	if !kernel_in do return cl.INVALID_VALUE;

	// do not delete the element from kernel program registry
	// just invalidate the existing object
	for &arg in k.args do if arg.value != nil {
		mem.free(arg.value);
		arg.value = nil;
	}
	mem.delete(k.args);
	mem.zero_item(k);

	return cl.SUCCESS;
}

MAX_DIMS :: 3;

EnqueueNDRangeKernel_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: [^]c.size_t, global_work_size: [^]c.size_t, local_work_size: [^]c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: [^]cl.Event, event: ^cl.Event) -> cl.Int {
	return cl.EnqueueNDRangeKernel(cast(Command_Queue_Full)command_queue, cast(Kernel_Full)kernel, work_dim, global_work_offset, global_work_size, local_work_size, num_events_in_wait_list, event_wait_list, event);
}
EnqueueNDRangeKernel_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: [^]c.size_t, global_work_size: [^]c.size_t, local_work_size: [^]c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: [^]cl.Event, event: ^cl.Event) -> cl.Int {
	assert(this.kind == .Null);

	// validate params
	if global_work_offset != nil || global_work_size == nil || work_dim > MAX_DIMS do return cl.INVALID_VALUE;
	p := (cast(^Null_CL)this).program;
	kernel_in := false;
	for &ker in p.kernels do if auto_cast &ker == kernel {
		kernel_in = true;
		break;
	}
	if !kernel_in do return cl.INVALID_VALUE;

	q := cast(^Command_Queue_Null_Impl)command_queue;
	ndrange: ^NDRange = &q.ndrange;

	nof_calls: c.size_t = 0; // how many times a kernel needs to be called
	switch work_dim {
		case 1: nof_calls = global_work_size[0];
		case 2: nof_calls = global_work_size[0] * global_work_size[1];
		case 3: nof_calls = global_work_size[0] * global_work_size[1] * global_work_size[2];
		case: unreachable();
	}

	@(static)local_work_size_buffer: [MAX_DIMS]c.size_t;

	local_work_size := local_work_size;
	nof_locals: c.size_t = 1; // number of kernel calls per local area
	nof_iters: c.size_t = 1; // how many times a work_item has to repeat one kernel
	if local_work_size == nil {
		#no_bounds_check local_work_size = &local_work_size_buffer[0];
		// NOTE(GowardSilk): the user should not expect to even call get_local_id @(builtin)
		// but it is still easier for us not to duplicate the whole task_proc because of
		// lacking local_work_size; better to just calculate everything and that way perhaps
		// enable execution for cases in which the global_pos is too large for real nof_threads

		gcd :: #force_inline proc(#any_int u, v: int) -> c.size_t {
			if u == 0 do return cast(c.size_t)v;
			if v == 0 do return cast(c.size_t)u;

			u := u;
			v := v;
			k: uint = 0;
			for (u & 0x1 == 0) && (v & 0x1 == 0) {
				u >>= 1;
				v >>= 1;
				k += 1;
			}
			t: int;
			if u & 0x1 == 1 {
				t = -v;
			}
			else do t = u;
			for t != 0 {
				for t & 0x1 == 0 {
					t >>= 1;
				}
				if t > 0 do u = t;
				else do v = -t;
				t = u - v;
			}
			return cast(c.size_t)(u * (1 << k));
		}

		if nof_calls < cast(uint)ndrange_len(ndrange) {
			nof_locals = nof_calls;
			nof_iters  = 1;
			local_work_size[0] = 1;
			local_work_size[1] = 1;
			local_work_size[2] = 1;
		} else {
			local_work_size[0] = gcd(nof_calls, ndrange_len(ndrange));
			local_work_size[1] = 1;
			local_work_size[2] = 1;
			fmt.eprintfln("local_work_size.x = %v = gcd(%v, %v)", local_work_size[0], nof_calls, ndrange_len(ndrange));
			nof_locals = local_work_size[0];
			nof_iters  = nof_calls / nof_locals;
		}
	} else {
		switch work_dim {
			case 1: nof_locals = local_work_size[0];
			case 2: nof_locals = local_work_size[0] * local_work_size[1];
			case 3: nof_locals = local_work_size[0] * local_work_size[1] * local_work_size[2];
			case: unreachable();
		}
		assert(cast(int)nof_locals <= ndrange_len(ndrange) && nof_calls % nof_locals == 0);
		nof_iters = nof_calls / nof_locals;
	}

	// copy kernel args into Task_In
	k := cast(^Kernel_Null_Impl)kernel;
	task_in_args: [10]rawptr;
	assert(len(task_in_args) >= len(k.args), "Too many function parameters!");
	for &arg, index in k.args {
		// additionally we have to check for __local params that need to be allocated properly
		if arg.local {
			if arg.value != nil do mem.free(arg.value);

			new_value, merr := mem.alloc_bytes_non_zeroed(cast(int)(arg.size * nof_iters) + size_of(c.size_t));
			if merr != .None do return cl.OUT_OF_HOST_MEMORY;
			arg.value = raw_data(new_value);
			#assert(size_of(arg.size) == size_of(c.size_t));
			mem.copy(arg.value, &arg.size, size_of(arg.size));
		}
		task_in_args[index] = arg.value;
	}

	payload_mutex: sync.Mutex;
	payload: Kernel_Builtin_Context_Payload = {
		_context = (cast(^Null_CL)this)._context,
		work_dim = work_dim,
		global_work_size = global_work_size,
		local_work_size = local_work_size,
		nof_calls = nof_calls,
		nof_locals = nof_locals,
		nof_iters = nof_iters,
		mutex = &payload_mutex,
	};

	task_in: Task_In = {
		args    = task_in_args[:len(k.args)],
		addr    = k.addr,
		payload = &payload,
	};

	ndrange_exec_task(ndrange, &task_in);

	return cl.SUCCESS;
}

EnqueueReadBuffer_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	return cl.EnqueueReadBuffer(cast(Command_Queue_Full)command_queue, cast(Mem_Full)buffer, blocking_read, offset, size, ptr, num_events_in_wait_list, event_wait_list, event);
}
EnqueueReadBuffer_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	when (cl.MEM_COPY_HOST_PTR & CREATE_BUFFER_SUPPORTED_FLAGS) != 0 {
		// Now the NullCL should pipe directly the memory buffer passed into the CreateBuffer as the buffer used inside kernels, making this call useless
		// but if MEM_COPY_HOST_PTR and others should be used, the situation would be different
		unimplemented();
	}
	return cl.SUCCESS;
}
