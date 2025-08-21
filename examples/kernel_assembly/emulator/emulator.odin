package emulator;

import "base:intrinsics"

import "core:c"
import "core:mem"
import "core:fmt"
import "core:sync"
import "core:thread"
import "core:container/intrusive/list"

import cl "shared:opencl"

Emulator_Kind :: enum {
	Full = 0,
	Null,
}

Emulator :: struct {
	kind: Emulator_Kind,
	using _: Emulator_VTable,
}

Emulator_VTable :: struct {
    // Platform & Device
    GetPlatformIDs             : Get_Platform_IDs_Type,
    GetDeviceIDs               : Get_Device_IDs_Type,
    GetDeviceInfo              : Get_Device_Info_Type,
    GetProgramBuildInfo        : Get_Program_Build_Info_Type,
    GetKernelWorkGroupInfo     : Get_Kernel_Work_Group_Info_Type,

    // Context
    CreateContext              : Create_Context_Type,
    ReleaseContext             : Release_Context_Type,

    // Command Queue
    CreateCommandQueue         : Create_Command_Queue_Type,
    ReleaseCommandQueue        : Release_Command_Queue_Type,
    FinishCommandQueue         : Finish_Command_Queue_Type,

    // Memory
    CreateBuffer               : Create_Buffer_Type,
    ReleaseMemObject           : Release_Mem_Object_Type,

    // Program
    CreateProgramWithSource    : Create_Program_With_Source_Type,
    BuildProgram               : Build_Program_Type,
    ReleaseProgram             : Release_Program_Type,

    // Kernel
    CreateKernel               : Create_Kernel_Type,
    SetKernelArg               : Set_Kernel_Arg_Type,
    ReleaseKernel              : Release_Kernel_Type,

    // Execution
    EnqueueNDRangeKernel       : Enqueue_NDRange_Kernel_Type,
    EnqueueReadBuffer          : Enqueue_Read_Buffer_Type,
}

Null_CL :: struct {
	#subtype base: Emulator,

	_context: ^Context_Null_Impl,
	program: ^Program_Null_Impl,
}

Full_CL :: struct {
	#subtype base: Emulator
}

/** @brief */
init_null :: proc() -> (em: Null_CL) {
	em.base.kind = .Null;

	em.base.GetPlatformIDs = GetPlatformIDs_NullCL;
	em.base.GetDeviceIDs = GetDeviceIDs_NullCL;
	em.base.GetDeviceInfo = GetDeviceInfo_NullCL;
	em.base.GetProgramBuildInfo = GetProgramBuildInfo_NullCL;
	em.base.GetKernelWorkGroupInfo = GetKernelWorkGroupInfo_NullCL;
	em.base.CreateContext = CreateContext_NullCL;
	em.base.ReleaseContext = ReleaseContext_NullCL;
	em.base.CreateCommandQueue = CreateCommandQueue_NullCL;
	em.base.ReleaseCommandQueue = ReleaseCommandQueue_NullCL;
	em.base.FinishCommandQueue = FinishCommandQueue_NullCL;
	em.base.CreateBuffer = CreateBuffer_NullCL;
	em.base.ReleaseMemObject = ReleaseMemObject_NullCL;
	em.base.CreateProgramWithSource = CreateProgramWithSource_NullCL;
	em.base.BuildProgram = BuildProgram_NullCL;
	em.base.ReleaseProgram = ReleaseProgram_NullCL;
	em.base.CreateKernel = CreateKernel_NullCL;
	em.base.SetKernelArg = SetKernelArg_NullCL;
	em.base.ReleaseKernel = ReleaseKernel_NullCL;
	em.base.EnqueueNDRangeKernel = EnqueueNDRangeKernel_NullCL;
	em.base.EnqueueReadBuffer = EnqueueReadBuffer_NullCL;

	return em;
}

/** @brief */
init_full :: proc() -> (em: Full_CL) {
	em.base.kind = .Full;

	em.base.GetPlatformIDs = GetPlatformIDs_FullCL;
	em.base.GetDeviceIDs = GetDeviceIDs_FullCL;
	em.base.GetDeviceInfo = GetDeviceInfo_FullCL;
	em.base.GetProgramBuildInfo = GetProgramBuildInfo_FullCL;
	em.base.GetKernelWorkGroupInfo = GetKernelWorkGroupInfo_FullCL;
	em.base.CreateContext = CreateContext_FullCL;
	em.base.ReleaseContext = ReleaseContext_FullCL;
	em.base.CreateCommandQueue = CreateCommandQueue_FullCL;
	em.base.ReleaseCommandQueue = ReleaseCommandQueue_FullCL;
	em.base.FinishCommandQueue = FinishCommandQueue_FullCL;
	em.base.CreateBuffer = CreateBuffer_FullCL;
	em.base.ReleaseMemObject = ReleaseMemObject_FullCL;
	em.base.CreateProgramWithSource = CreateProgramWithSource_FullCL;
	em.base.BuildProgram = BuildProgram_FullCL;
	em.base.ReleaseProgram = ReleaseProgram_FullCL;
	em.base.CreateKernel = CreateKernel_FullCL;
	em.base.SetKernelArg = SetKernelArg_FullCL;
	em.base.ReleaseKernel = ReleaseKernel_FullCL;
	em.base.EnqueueNDRangeKernel = EnqueueNDRangeKernel_FullCL;
	em.base.EnqueueReadBuffer = EnqueueReadBuffer_FullCL;

	return em;
}

delete :: proc { delete_null, delete_full }
@(disabled=true)
delete_full :: proc(em: ^Full_CL) {}
delete_null :: proc(em: ^Null_CL) {
	if em._context != nil {
		fmt.eprintfln("Context was not properly deinitialized!");
		assert(em.base->ReleaseContext(cast(Context)em._context) == cl.SUCCESS);
	}
	if em.program != nil {
		fmt.eprintfln("Program was not properly deinitialized!");
		assert(em.base->ReleaseProgram(cast(Program)em.program) == cl.SUCCESS);
	}
}

// OpenCL API
Get_Platform_IDs_Type             :: #type proc(this: ^Emulator, num_entries: cl.Uint, platforms: [^]Platform_ID, num_platforms: ^cl.Uint) -> cl.Int;
Get_Device_IDs_Type               :: #type proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int;
Get_Device_Info_Type              :: #type proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int;
Get_Program_Build_Info_Type       :: #type proc(this: ^Emulator, program: Program, device: Device_ID, param_name: cl.Program_Build_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int;
Get_Kernel_Work_Group_Info_Type   :: #type proc(this: ^Emulator, kernel: Kernel, device: Device_ID, param_name: cl.Kernel_Work_Group_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int;
Create_Context_Type               :: #type proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context;
Release_Context_Type              :: #type proc(this: ^Emulator, _context: Context) -> cl.Int;
Create_Command_Queue_Type         :: #type proc(this: ^Emulator, _context: Context, device: Device_ID, properties: cl.Command_Queue_Properties, errcode_ret: ^cl.Int) -> Command_Queue;
Release_Command_Queue_Type        :: #type proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int;
Finish_Command_Queue_Type         :: #type proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int;
Create_Buffer_Type                :: #type proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem;
Release_Mem_Object_Type           :: #type proc(this: ^Emulator, memobj: Mem) -> cl.Int;
Create_Program_With_Source_Type   :: #type proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program;
Build_Program_Type                :: #type proc(this: ^Emulator, program: Program, num_devices: cl.Uint, device_list: ^Device_ID, options: cstring, pfn_notify: rawptr, user_data: rawptr) -> cl.Int;
Get_Program_Info_Type             :: #type proc(this: ^Emulator, param_name: cl.Program_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t);
Release_Program_Type              :: #type proc(this: ^Emulator, program: Program) -> cl.Int;
Create_Kernel_Type                :: #type proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel;
Set_Kernel_Arg_Type               :: #type proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int;
Release_Kernel_Type               :: #type proc(this: ^Emulator, kernel: Kernel) -> cl.Int;
Enqueue_NDRange_Kernel_Type       :: #type proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: [^]c.size_t, global_work_size: [^]c.size_t, local_work_size: [^]c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: [^]cl.Event, event: ^cl.Event) -> cl.Int;
Enqueue_Read_Buffer_Type          :: #type proc(this: ^Emulator, command_queue: Command_Queue, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int;

Platform_ID :: distinct rawptr;
Platform_ID_Full :: cl.Platform_ID;
Platform_ID_Null :: Platform_ID;
Platform_ID_Null_Impl :: enum uintptr {
	Dummy = 0xB16B00B5,
}

Device_ID :: distinct rawptr;
Device_ID_Full :: cl.Device_ID;
Device_ID_Null :: Device_ID;
Device_ID_Null_Impl :: enum uintptr {
	Dummy = 0xCAFEBABE,
}

Context :: distinct rawptr;
Context_Full :: cl.Context;
Context_Null :: Context;
Context_Null_Impl :: struct {
	/** NOTE(GowardSilk): This API does not emulate "OpenCL retain modes of operation (aka cl.RetainKernel, cl.RetainContext etc.) but we still have to hold rc counter for properly simulating the behaviour that when rc == 0, all of the members are released as well */
	rc:       int,
	device:   Device_ID_Null_Impl,
	queue:    ^Command_Queue_Null_Impl,
	memobjs:  list.List,
}

Program :: distinct rawptr;
Program_Full :: cl.Program;
Program_Null :: Program; // == ptr to Program_Null_Impl
Program_Null_Impl :: struct {
	rc: int,
	kernels: []Kernel_Null_Impl,
}

Kernel :: distinct rawptr;
Kernel_Full :: cl.Kernel;
Kernel_Null :: Kernel; // == ptr to Kernel_Null_Impl
Kernel_Null_Impl :: struct {
	addr: Kernel_Null_Proc_Wrapper, /**< pointer to the kernel wrapper */
	args: []Kernel_Null_Arg, /**< kernel arguments */
}
Kernel_Null_Proc_Wrapper :: #type proc([]rawptr);
Kernel_Null_Arg :: struct {
	local: bool,
	size:  c.size_t,
	value: rawptr,
}
/**
 * @brief present as a value in Kernel_Null_Arg.value iff Kernel_Null_Arg.local == true
 */
Kernel_Null_Arg_Local :: struct {
	size:   c.size_t, /**< size of one chunk of the `buffer' (aka should be eq to Kernel_Null_Arg.size) */

	// this is incorrect in terms of Odin's type(s), can be handled as flexible array member such that this is just accessed
	// via manual ptr_offset(local_arg_heap_ptr, offset_of(Kernel_Null_Arg_Local, buffer))
	buffer: rawptr,  /**< backing buffer, containing all the local instances for each workgroup */
}

Command_Queue :: distinct rawptr;
Command_Queue_Full :: cl.Command_Queue;
Command_Queue_Null :: Command_Queue; // == ptr to Command_Queue_Null_Impl
Command_Queue_Null_Impl :: struct {
	rc: int,
	commands: [dynamic]#type struct {},
	flags: Command_Queue_Properties_Null,
	ndrange: NDRange, /**< contains the maximum number of physical threads (aka Work_Item(s)) */
}
Command_Queue_Properties_Null :: enum cl.Command_Queue_Properties {
	QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE = cl.QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE,
	QUEUE_PROFILING_ENABLE = cl.QUEUE_PROFILING_ENABLE,
	QUEUE_ON_DEVICE = cl.QUEUE_ON_DEVICE, // needs QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE
	QUEUE_ON_DEVICE_DEFAULT = cl.QUEUE_ON_DEVICE_DEFAULT, // needs QUEUE_ON_DEVICE_DEFAULT
}

Mem :: distinct rawptr;
Mem_Full :: cl.Mem;
Mem_Null :: Mem; // == ptr to Mem_Null_Impl
Mem_Null_Impl :: struct {
	node: list.Node, /*< node of Context_Null_Impl.memobjs */

	rc: int,
	size: c.size_t,
	data: rawptr,
	flags: cl.Mem_Flags,
	/* TODO(GowardSilk): FIX guard: sync.Barrier, */
}

/**
 * @brief Create_Buffer_(Null|Full)CL [Ex]tended version aided by Odin's parapoly
 * @note this function cannot be part of the Emulator_VTable because of the parapoly itself
 */
CreateBufferEx :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, host_ptr: ^$T) -> Maybe(Mem) {
	ret: cl.Int;
	buf: Mem;
	when intrinsics.type_is_slice(T) || intrinsics.type_is_dynamic_array(T) {
		buf = this->CreateBuffer(_context, flags, size_of(host_ptr[0]) * len(host_ptr^), raw_data(host_ptr^), &ret);
	} else do unimplemented();

	if ret == cl.SUCCESS do return cast(Mem)buf;
	return nil;
}

OpenCL_Qualifier :: distinct string;
OpenCL_Qualifier_Invalid :: "";
OpenCL_Qualifier_Const 	 :: "__const";
OpenCL_Qualifier_Global	 :: "__global";
OpenCL_Qualifier_Local	 :: "__local";

Proc_Desc_Param :: struct {
	name: string,
	qual: OpenCL_Qualifier,
}

/**
 * @brief utility function for Null_CL emulator type when creating Kernel(s)
 */
CreateKernel_Null :: proc(this: ^Emulator, program: Program, kernel_addr: Kernel_Null_Proc_Wrapper, params: []Proc_Desc_Param, errcode_ret: ^cl.Int) -> Kernel {
	assert(this.kind == .Null);
	null := cast(^Null_CL)this;
	p := null.program;

	@(static)
	kernel_idx := 0; // index of the last created Kernel in program.kernels

	if p != auto_cast program || kernel_addr == nil || kernel_idx >= len(p.kernels) {
		if errcode_ret != nil do errcode_ret ^= cl.INVALID_VALUE;
		return nil;
	}

	merr: mem.Allocator_Error;
	k := &p.kernels[kernel_idx];
	k.addr = kernel_addr;
	k.args, merr = mem.make([]Kernel_Null_Arg, len(params));
	if merr != .None {
		if errcode_ret != nil do errcode_ret ^= cl.OUT_OF_HOST_MEMORY;
		return nil;
	}
	for param, index in params {
		if param.qual == OpenCL_Qualifier_Local {
			k.args[index].local = true;
		}
	}

	kernel_idx += 1;
	return cast(Kernel)k;
}
