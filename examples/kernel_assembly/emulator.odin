package ka;

import "core:c"

import cl "shared:opencl"

Emulator :: struct {
	ocl: OpenCL_Context,

	using _: Emulator_VTable,
}

Emulator_VTable :: struct {
    // Platform & Device
    GetPlatformIDs             : Get_Platform_IDs_Type,
    GetDeviceIDs               : Get_Device_IDs_Type,
    GetDeviceInfo              : Get_Device_Info_Type,

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
    GetProgramInfo             : Get_Program_Info_Type,
    ReleaseProgram             : Release_Program_Type,

    // Kernel
    CreateKernel               : Create_Kernel_Type,
    SetKernelArg               : Set_Kernel_Arg_Type,
    ReleaseKernel              : Release_Kernel_Type,

    // Execution
    EnqueueNDRangeKernel       : Enqueue_NDRange_Kernel_Type,
}

Null_CL :: struct {
	#subtype base: Emulator
}

Full_CL :: struct {
	#subtype base: Emulator
}

/** @brief */
init_emulator_null :: proc() -> (em: Null_CL) {
	em.base.GetPlatformIDs = GetPlatformIDs_NullCL;
	em.base.GetDeviceIDs = GetDeviceIDs_NullCL;
	em.base.GetDeviceInfo = GetDeviceInfo_NullCL;
	em.base.CreateContext = CreateContext_NullCL;
	em.base.ReleaseContext = ReleaseContext_NullCL;
	em.base.CreateCommandQueue = CreateCommandQueue_NullCL;
	em.base.ReleaseCommandQueue = ReleaseCommandQueue_NullCL;
	em.base.FinishCommandQueue = FinishCommandQueue_NullCL;
	em.base.CreateBuffer = CreateBuffer_NullCL;
	em.base.ReleaseMemObject = ReleaseMemObject_NullCL;
	em.base.CreateProgramWithSource = CreateProgramWithSource_NullCL;
	em.base.BuildProgram = BuildProgram_NullCL;
	em.base.GetProgramInfo = GetProgramInfo_NullCL;
	em.base.ReleaseProgram = ReleaseProgram_NullCL;
	em.base.CreateKernel = CreateKernel_NullCL;
	em.base.SetKernelArg = SetKernelArg_NullCL;
	em.base.ReleaseKernel = ReleaseKernel_NullCL;
	em.base.EnqueueNDRangeKernel = EnqueueNDRangeKernel_NullCL;
	return em;
}

/** @brief */
init_emulator_full :: proc() -> (em: Full_CL) {
	em.base.GetPlatformIDs = GetPlatformIDs_FullCL;
	em.base.GetDeviceIDs = GetDeviceIDs_FullCL;
	em.base.GetDeviceInfo = GetDeviceInfo_FullCL;
	em.base.CreateContext = CreateContext_FullCL;
	em.base.ReleaseContext = ReleaseContext_FullCL;
	em.base.CreateCommandQueue = CreateCommandQueue_FullCL;
	em.base.ReleaseCommandQueue = ReleaseCommandQueue_FullCL;
	em.base.FinishCommandQueue = FinishCommandQueue_FullCL;
	em.base.CreateBuffer = CreateBuffer_FullCL;
	em.base.ReleaseMemObject = ReleaseMemObject_FullCL;
	em.base.CreateProgramWithSource = CreateProgramWithSource_FullCL;
	em.base.BuildProgram = BuildProgram_FullCL;
	em.base.GetProgramInfo = GetProgramInfo_FullCL;
	em.base.ReleaseProgram = ReleaseProgram_FullCL;
	em.base.CreateKernel = CreateKernel_FullCL;
	em.base.SetKernelArg = SetKernelArg_FullCL;
	em.base.ReleaseKernel = ReleaseKernel_FullCL;
	em.base.EnqueueNDRangeKernel = EnqueueNDRangeKernel_FullCL;
	return em;
}

Get_Platform_IDs_Type             :: #type proc(this: ^Emulator, num_entries: cl.Uint, platforms: [^]Platform_ID, num_platforms: ^cl.Uint) -> cl.Int;
Get_Device_IDs_Type               :: #type proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int;
Get_Device_Info_Type              :: #type proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t);
Create_Context_Type               :: #type proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context;
Release_Context_Type              :: #type proc(this: ^Emulator, _context: Context) -> cl.Int;
Create_Command_Queue_Type         :: #type proc(this: ^Emulator, _context: Context, device: Device_ID, properties: cl.Command_Queue_Properties, errcode_ret: ^cl.Int) -> Command_Queue;
Release_Command_Queue_Type        :: #type proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int;
Finish_Command_Queue_Type         :: #type proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int;
Create_Buffer_Type                :: #type proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem;
Release_Mem_Object_Type           :: #type proc(this: ^Emulator, memobj: Mem) -> cl.Int;
Create_Program_With_Source_Type   :: #type proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program;
Build_Program_Type                :: #type proc(this: ^Emulator, program: Program, num_devices: cl.Uint, device_list: ^Device_ID, options: cstring, pfn_notify: rawptr, user_data: rawptr) -> cl.Int;
Get_Program_Info_Type             :: #type proc(this: ^Emulator, program: Program, param_name: cl.Program_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t);
Release_Program_Type              :: #type proc(this: ^Emulator, program: Program) -> cl.Int;
Create_Kernel_Type                :: #type proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel;
Set_Kernel_Arg_Type               :: #type proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int;
Release_Kernel_Type               :: #type proc(this: ^Emulator, kernel: Kernel) -> cl.Int;
Enqueue_NDRange_Kernel_Type       :: #type proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int;

Platform_ID :: distinct rawptr;
Platform_ID_Full :: cl.Platform_ID;
Platform_ID_Null :: Platform_ID;

Device_ID :: distinct rawptr;
Device_ID_Full :: cl.Device_ID;
Device_ID_Null :: Device_ID;

Context :: distinct rawptr;
Context_Full :: cl.Context;
Context_Null :: Context;

Program :: distinct rawptr;
Program_Full :: cl.Program;
Program_Null :: Program;

Kernel :: distinct rawptr;
Kernel_Full :: cl.Kernel;
Kernel_Null :: Kernel;

Command_Queue :: distinct rawptr;
Command_Queue_Full :: cl.Command_Queue;
Command_Queue_Null :: Command_Queue;

Mem :: distinct rawptr;
Mem_Full :: cl.Mem;
Mem_Null :: Mem;

@(private="file")
GetPlatformIDs_FullCL :: proc(this: ^Emulator, num_entries: cl.Uint, platforms: [^]Platform_ID, num_platforms: ^cl.Uint) -> cl.Int {
	return cl.GetPlatformIDs(num_entries, cast([^]cl.Platform_ID)platforms, num_platforms);
}
@(private="file")
GetPlatformIDs_NullCL :: proc(this: ^Emulator, num_entries: cl.Uint, platforms: [^]Platform_ID, num_platforms: ^cl.Uint) -> cl.Int {
	unimplemented();
}

@(private="file")
GetDeviceIDs_FullCL :: proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int {
	unimplemented();
}
@(private="file")
GetDeviceIDs_NullCL :: proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int {
	unimplemented();
}

@(private="file")
GetDeviceInfo_FullCL :: proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) {
	unimplemented();
}
@(private="file")
GetDeviceInfo_NullCL :: proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) {
	unimplemented();
}

@(private="file")
CreateContext_FullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	unimplemented();
}
@(private="file")
CreateContext_NullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	unimplemented();
}

@(private="file")
ReleaseContext_FullCL :: proc(this: ^Emulator, _context: Context) -> cl.Int {
	unimplemented();
}
@(private="file")
ReleaseContext_NullCL :: proc(this: ^Emulator, _context: Context) -> cl.Int {
	unimplemented();
}

@(private="file")
CreateCommandQueue_FullCL :: proc(
	this: ^Emulator,
	_context: Context,
	device: Device_ID,
	properties: cl.Command_Queue_Properties,
	errcode_ret: ^cl.Int) -> Command_Queue {
	return auto_cast cl.CreateCommandQueue(cast(cl.Context)_context, cast(cl.Device_ID)device, properties, errcode_ret);
}

@(private="file")
CreateCommandQueue_NullCL :: proc(
	this: ^Emulator,
	_context: Context,
	device: Device_ID,
	properties: cl.Command_Queue_Properties,
	errcode_ret: ^cl.Int) -> Command_Queue {
	unimplemented();
}

@(private="file")
ReleaseCommandQueue_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	return cl.ReleaseCommandQueue(cast(cl.Command_Queue)command_queue);
}
@(private="file")
ReleaseCommandQueue_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	unimplemented();
}

@(private="file")
FinishCommandQueue_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	unimplemented();
}
@(private="file")
FinishCommandQueue_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue) -> cl.Int {
	unimplemented();
}

@(private="file")
CreateBuffer_FullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	unimplemented();
}
@(private="file")
CreateBuffer_NullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	unimplemented();
}

@(private="file")
ReleaseMemObject_FullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	unimplemented();
}
@(private="file")
ReleaseMemObject_NullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	unimplemented();
}

@(private="file")
CreateProgramWithSource_FullCL :: proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program {
	unimplemented();
}
@(private="file")
CreateProgramWithSource_NullCL :: proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program {
	unimplemented();
}

@(private="file")
BuildProgram_FullCL :: proc(this: ^Emulator, program: Program, num_devices: cl.Uint, device_list: ^Device_ID, options: cstring, pfn_notify: rawptr, user_data: rawptr) -> cl.Int {
	unimplemented();
}
@(private="file")
BuildProgram_NullCL :: proc(this: ^Emulator, program: Program, num_devices: cl.Uint, device_list: ^Device_ID, options: cstring, pfn_notify: rawptr, user_data: rawptr) -> cl.Int {
	unimplemented();
}

@(private="file")
GetProgramInfo_FullCL :: proc(this: ^Emulator, program: Program, param_name: cl.Program_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) {
	unimplemented();
}
@(private="file")
GetProgramInfo_NullCL :: proc(this: ^Emulator, program: Program, param_name: cl.Program_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) {
	unimplemented();
}

@(private="file")
ReleaseProgram_FullCL :: proc(this: ^Emulator, program: Program) -> cl.Int {
	unimplemented();
}
@(private="file")
ReleaseProgram_NullCL :: proc(this: ^Emulator, program: Program) -> cl.Int {
	unimplemented();
}

@(private="file")
CreateKernel_FullCL :: proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel {
	unimplemented();
}
@(private="file")
CreateKernel_NullCL :: proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel {
	unimplemented();
}

@(private="file")
SetKernelArg_FullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	unimplemented();
}
@(private="file")
SetKernelArg_NullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	unimplemented();
}

@(private="file")
ReleaseKernel_FullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	unimplemented();
}
@(private="file")
ReleaseKernel_NullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	unimplemented();
}

@(private="file")
EnqueueNDRangeKernel_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	unimplemented();
}
@(private="file")
EnqueueNDRangeKernel_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	unimplemented();
}
