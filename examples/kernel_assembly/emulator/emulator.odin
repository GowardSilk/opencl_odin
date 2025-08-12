package emulator;

import "base:intrinsics"

import "core:c"
import "core:mem"

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
init_emulator_null :: proc() -> (em: Null_CL) {
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
init_emulator_full :: proc() -> (em: Full_CL) {
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
Enqueue_NDRange_Kernel_Type       :: #type proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int;
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
}

Program :: distinct rawptr;
Program_Full :: cl.Program;
Program_Null :: Program; // == ptr to Program_Null_Impl
Program_Null_Impl :: struct {
	rc: int,
	kernels: []Kernel_Null,
}

Kernel :: distinct rawptr;
Kernel_Full :: cl.Kernel;
Kernel_Null :: Kernel; // == ptr to Kernel_Null_Impl
Kernel_Null_Impl :: struct {
	addr: #type proc(_: []rawptr), /**< pointer to the kernel wrapper */
	args: []Kernel_Null_Arg, /**< kernel arguments */
}
Kernel_Null_Arg :: struct {
	size: c.size_t,
	value: rawptr,
}

Command_Queue :: distinct rawptr;
Command_Queue_Full :: cl.Command_Queue;
Command_Queue_Null :: Command_Queue; // == ptr to Command_Queue_Null_Impl
Command_Queue_Null_Impl :: struct {
	rc: int,
	commands: [dynamic]#type struct {},
	flags: Command_Queue_Properties_Null,
}
Command_Queue_Properties_Null :: enum {
	QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE = 1,
	QUEUE_PROFILING_ENABLE = 2,
	QUEUE_ON_DEVICE = 5, // needs QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE
	CL_QUEUE_ON_DEVICE_DEFAULT = 13, // needs QUEUE_ON_DEVICE_DEFAULT
}

Mem :: distinct rawptr;
Mem_Full :: cl.Mem;
Mem_Null :: Mem; // == ptr to Mem_Null_Impl
Mem_Null_Impl :: struct {
	rc: int,
	size: c.size_t,
	data: rawptr,
	flags: cl.Mem_Flags,
}

/**
 * @brief Create_Buffer_(Null|Full)CL [Ex]tended version aided by Odin's parapoly
 * @note this function cannot be part of the Emulator_VTable because of the parapoly itself
 */
CreateBufferEx :: proc "system" (this: ^Emulator, _context: Context, flags: cl.Mem_Flags, host_ptr: ^$T) -> Maybe(Mem) {
	switch this.kind {
		case .Full: return CreateBufferEx_FullCL(this, auto_cast _context, flags, host_ptr);
		case .Null: return CreateBufferEx_NullCL(this, auto_cast _context, flags, host_ptr);
	}
	unreachable();
}
