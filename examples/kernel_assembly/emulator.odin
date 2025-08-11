package ka;

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
	ocl: OpenCL_Context,
	proc_table: map[string]Proc_Desc,

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
    GetProgramInfo             : Get_Program_Info_Type,
    ReleaseProgram             : Release_Program_Type,

    // Kernel
    CreateKernel               : Create_Kernel_Type,
    CreateNullKernel           : Create_Null_Kernel_Type,
    SetKernelArg               : Set_Kernel_Arg_Type,
    ReleaseKernel              : Release_Kernel_Type,

    // Execution
    EnqueueNDRangeKernel       : Enqueue_NDRange_Kernel_Type,
    EnqueueNDRangeKernelEx     : Enqueue_NDRange_Kernel_Ex_Type,
    EnqueueReadBuffer          : Enqueue_Read_Buffer_Type,
    EnqueueReadBufferEx        : Enqueue_Read_Buffer_Ex_Type,
}

Null_CL :: struct {
	#subtype base: Emulator
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
	em.base.GetProgramInfo = GetProgramInfo_NullCL;
	em.base.ReleaseProgram = ReleaseProgram_NullCL;
	em.base.CreateKernel = CreateKernel_NullCL;
	em.base.CreateNullKernel = CreateNullKernel_NullCL; // unsupported in Full mode
	em.base.SetKernelArg = SetKernelArg_NullCL;
	em.base.ReleaseKernel = ReleaseKernel_NullCL;
	em.base.EnqueueNDRangeKernel = EnqueueNDRangeKernel_NullCL;
	em.base.EnqueueNDRangeKernelEx = EnqueueNDRangeKernelEx_NullCL;
	em.base.EnqueueReadBuffer = EnqueueReadBuffer_NullCL;
	em.base.EnqueueReadBufferEx = EnqueueReadBufferEx_NullCL;

	init_emulator_base(&em);

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
	em.base.GetProgramInfo = GetProgramInfo_FullCL;
	em.base.ReleaseProgram = ReleaseProgram_FullCL;
	em.base.CreateKernel = CreateKernel_FullCL;
	em.base.CreateNullKernel = nil; // unsupported in Full mode
	em.base.SetKernelArg = SetKernelArg_FullCL;
	em.base.ReleaseKernel = ReleaseKernel_FullCL;
	em.base.EnqueueNDRangeKernel = EnqueueNDRangeKernel_FullCL;
	em.base.EnqueueNDRangeKernelEx = EnqueueNDRangeKernelEx_FullCL;
	em.base.EnqueueReadBuffer = EnqueueReadBuffer_FullCL;
	em.base.EnqueueReadBufferEx = EnqueueReadBufferEx_FullCL;

	init_emulator_base(&em);

	return em;
}

@(private="file")
init_emulator_base :: #force_inline proc(em: ^Emulator) {
	merr: mem.Allocator_Error;
	em.ocl, merr = compile(em);
	assert(merr == .None);
}

delete_emulator :: #force_inline proc(em: ^Emulator) {
	delete_cl_context(em);
}

// OpenCL API
Get_Platform_IDs_Type             :: #type proc(this: ^Emulator, num_entries: cl.Uint, platforms: [^]Platform_ID, num_platforms: ^cl.Uint) -> cl.Int;
Get_Device_IDs_Type               :: #type proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int;
Get_Device_Info_Type              :: #type proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int;
Get_Program_Build_Info_Type       :: #type proc(this: ^Emulator, program: Program, device: Device_ID, param_name: cl.Program_Build_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int;
Get_Kernel_Work_Group_Info_Type   :: #type proc(this: ^Emulator, kernel: Kernel, device: Device_ID, param_name: cl.Kernel_Work_Group_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int;
Create_Context_Type               :: #type proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context;
Release_Context_Type              :: #type proc(this: ^Emulator) -> cl.Int;
Create_Command_Queue_Type         :: #type proc(this: ^Emulator, _context: Context, device: Device_ID, properties: cl.Command_Queue_Properties, errcode_ret: ^cl.Int) -> Command_Queue;
Release_Command_Queue_Type        :: #type proc(this: ^Emulator) -> cl.Int;
Finish_Command_Queue_Type         :: #type proc(this: ^Emulator) -> cl.Int;
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
Enqueue_Read_Buffer_Type          :: #type proc(this: ^Emulator, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int;
// Custom types
// TODO(GowardSilk): IT IS REALLY QUESTIONABLE WHETHER WE SHOULD 'ABSTRACT' ALL FUNCTIONS THIS WAY BY REMOVING REDUNDANT PARAMETERS ALREADY IMPLICITLY SUPPLIED BY ^Emulator
// OR SHOULD WE TRY TO BE THE MOST "ICD-RELATABLE" ???
Create_Null_Kernel_Type           :: #type proc(this: ^Emulator, kernel_wrapper_name: string, kernel_wrapper_addr: rawptr, errcode_ret: ^cl.Int) -> Kernel;
Enqueue_NDRange_Kernel_Ex_Type    :: #type proc(this: ^Emulator, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t = nil, global_work_size: ^c.size_t = nil, local_work_size: ^c.size_t = nil) -> cl.Int;
Enqueue_Read_Buffer_Ex_Type       :: #type proc(this: ^Emulator, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr) -> cl.Int;

/**
 * @brief Create_Buffer_(Null|Full)CL [Ex]tended version aided by Odin's parapoly
 * @note this function cannot be part of the Emulator_VTable because of the parapoly itself
 */
CreateBufferEx :: proc(this: ^Emulator, flags: cl.Mem_Flags, host_ptr: ^$T) -> Maybe(Mem) {
	switch this.kind {
		case .Full: return CreateBufferEx_FullCL(this, flags, host_ptr);
		case .Null: return CreateBufferEx_NullCL(this, flags, host_ptr);
	}
	unreachable();
}
CreateBufferEx_NullCL :: proc(this: ^Emulator, flags: cl.Mem_Flags, host_ptr: ^$T) -> Maybe(Mem) {
	unimplemented();
}
CreateBufferEx_FullCL :: proc(this: ^Emulator, flags: cl.Mem_Flags, host_ptr: ^$T) -> Maybe(Mem) {
	ret: cl.Int;
	buf: Mem_Full;
	when intrinsics.type_is_slice(T) || intrinsics.type_is_dynamic_array(T) {
		buf = cl.CreateBuffer(cast(Context_Full)this.ocl._context, flags, size_of(host_ptr[0]) * len(host_ptr^), raw_data(host_ptr^), &ret);
	} else do unimplemented();

	if ret == cl.SUCCESS do return cast(Mem)buf;
	return nil;
}

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
	return cl.GetDeviceIDs(cast(Platform_ID_Full)platform, device_type, num_entries, cast([^]Device_ID_Full)devices, num_devices);
}
@(private="file")
GetDeviceIDs_NullCL :: proc(this: ^Emulator, platform: Platform_ID, device_type: cl.Device_Type, num_entries: cl.Uint, devices: [^]Device_ID, num_devices: ^cl.Uint) -> cl.Int {
	unimplemented();
}

@(private="file")
GetDeviceInfo_FullCL :: proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	return cl.GetDeviceInfo(cast(Device_ID_Full)device, param_name, param_value_size, param_value, param_value_size_ret);
}
@(private="file")
GetDeviceInfo_NullCL :: proc(this: ^Emulator, device: Device_ID, param_name: cl.Device_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	unimplemented();
}

@(private="file")
GetProgramBuildInfo_FullCL :: proc(this: ^Emulator, program: Program, device: Device_ID, param_name: cl.Program_Build_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	unimplemented();
}
@(private="file")
GetProgramBuildInfo_NullCL :: proc(this: ^Emulator, program: Program, device: Device_ID, param_name: cl.Program_Build_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	unimplemented();
}

@(private="file")
GetKernelWorkGroupInfo_FullCL :: proc(this: ^Emulator, kernel: Kernel, device: Device_ID, param_name: cl.Kernel_Work_Group_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	return cl.GetKernelWorkGroupInfo(cast(Kernel_Full)kernel, cast(Device_ID_Full)device, param_name, param_value_size, param_value, param_value_size_ret);
}
@(private="file")
GetKernelWorkGroupInfo_NullCL :: proc(this: ^Emulator, kernel: Kernel, device: Device_ID, param_name: cl.Kernel_Work_Group_Info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl.Int {
	unimplemented();
}

@(private="file")
CreateContext_FullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	return cast(Context)cl.CreateContext(properties, num_devices, cast(^Device_ID_Full)devices, pfn_notify, user_data, errcode_ret);
}
@(private="file")
CreateContext_NullCL :: proc(this: ^Emulator, properties: ^cl.Context_Properties, num_devices: cl.Uint, devices: ^Device_ID, pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl.Int) -> Context {
	unimplemented();
}

@(private="file")
ReleaseContext_FullCL :: proc(this: ^Emulator) -> cl.Int {
	return cl.ReleaseContext(cast(Context_Full)this.ocl._context);
}
@(private="file")
ReleaseContext_NullCL :: proc(this: ^Emulator) -> cl.Int {
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
ReleaseCommandQueue_FullCL :: proc(this: ^Emulator) -> cl.Int {
	return cl.ReleaseCommandQueue(cast(Command_Queue_Full)this.ocl.queue);
}
@(private="file")
ReleaseCommandQueue_NullCL :: proc(this: ^Emulator) -> cl.Int {
	unimplemented();
}

@(private="file")
FinishCommandQueue_FullCL :: proc(this: ^Emulator) -> cl.Int {
	return cl.Finish(cast(Command_Queue_Full)this.ocl.queue);
}
@(private="file")
FinishCommandQueue_NullCL :: proc(this: ^Emulator) -> cl.Int {
	unimplemented();
}

@(private="file")
CreateBuffer_FullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	return cast(Mem)cl.CreateBuffer(cast(Context_Full)_context, flags, size, host_ptr, errcode_ret);
}
@(private="file")
CreateBuffer_NullCL :: proc(this: ^Emulator, _context: Context, flags: cl.Mem_Flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl.Int) -> Mem {
	unimplemented();
}

@(private="file")
ReleaseMemObject_FullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	return cl.ReleaseMemObject(cast(Mem_Full)memobj);
}
@(private="file")
ReleaseMemObject_NullCL :: proc(this: ^Emulator, memobj: Mem) -> cl.Int {
	unimplemented();
}

@(private="file")
CreateProgramWithSource_FullCL :: proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program {
	return cast(Program)cl.CreateProgramWithSource(cast(Context_Full)_context, count, strings, lengths, errcode_ret);
}
@(private="file")
CreateProgramWithSource_NullCL :: proc(this: ^Emulator, _context: Context, count: cl.Uint, strings: [^]cstring, lengths: [^]c.size_t, errcode_ret: ^cl.Int) -> Program {
	unimplemented();
}

@(private="file")
BuildProgram_FullCL :: proc(this: ^Emulator, program: Program, num_devices: cl.Uint, device_list: ^Device_ID, options: cstring, pfn_notify: rawptr, user_data: rawptr) -> cl.Int {
	return cl.BuildProgram(cast(Program_Full)program, num_devices, cast(^Device_ID_Full)device_list, options, cast(proc "stdcall" (Program_Full, rawptr))pfn_notify, user_data);
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
	return cast(Kernel)cl.CreateKernel(cast(Program_Full)program, kernel_name, errcode_ret);
}
@(private="file")
CreateKernel_NullCL :: proc(this: ^Emulator, program: Program, kernel_name: cstring, errcode_ret: ^cl.Int) -> Kernel {
	unimplemented();
}

@(private="file")
CreateNullKernel_NullCL :: proc(this: ^Emulator, kernel_wrapper_name: string, kernel_wrapper_addr: rawptr, errcode_ret: ^cl.Int) -> Kernel {
	unimplemented();
}

@(private="file")
SetKernelArg_FullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	return cl.SetKernelArg(cast(Kernel_Full)kernel, arg_index, arg_size, arg_value);
}
@(private="file")
SetKernelArg_NullCL :: proc(this: ^Emulator, kernel: Kernel, arg_index: cl.Uint, arg_size: c.size_t, arg_value: rawptr) -> cl.Int {
	unimplemented();
}

@(private="file")
ReleaseKernel_FullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	return cl.ReleaseKernel(cast(Kernel_Full)kernel);
}
@(private="file")
ReleaseKernel_NullCL :: proc(this: ^Emulator, kernel: Kernel) -> cl.Int {
	unimplemented();
}

@(private="file")
EnqueueNDRangeKernel_FullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	return cl.EnqueueNDRangeKernel(cast(Command_Queue_Full)command_queue, cast(Kernel_Full)kernel, work_dim, global_work_offset, global_work_size, local_work_size, num_events_in_wait_list, event_wait_list, event);
}
@(private="file")
EnqueueNDRangeKernel_NullCL :: proc(this: ^Emulator, command_queue: Command_Queue, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	unimplemented();
}

@(private="file")
EnqueueNDRangeKernelEx_FullCL :: proc(this: ^Emulator, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t = nil, global_work_size: ^c.size_t = nil, local_work_size: ^c.size_t = nil) -> cl.Int {
	return EnqueueNDRangeKernel_FullCL(this, this.ocl.queue, kernel, work_dim, global_work_offset, global_work_size, local_work_size, 0, nil, nil);
}
@(private="file")
EnqueueNDRangeKernelEx_NullCL :: proc(this: ^Emulator, kernel: Kernel, work_dim: cl.Uint, global_work_offset: ^c.size_t = nil, global_work_size: ^c.size_t = nil, local_work_size: ^c.size_t = nil) -> cl.Int {
	return EnqueueNDRangeKernel_NullCL(this, this.ocl.queue, kernel, work_dim, global_work_offset, global_work_size, local_work_size, 0, nil, nil);
}

@(private="file")
EnqueueReadBuffer_FullCL :: proc(this: ^Emulator, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	return cl.EnqueueReadBuffer(cast(Command_Queue_Full)this.ocl.queue, cast(Mem_Full)buffer, blocking_read, offset, size, ptr, num_events_in_wait_list, event_wait_list, event);
}
@(private="file")
EnqueueReadBuffer_NullCL :: proc(this: ^Emulator, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl.Uint, event_wait_list: ^cl.Event, event: ^cl.Event) -> cl.Int {
	unimplemented();
}

@(private="file")
EnqueueReadBufferEx_FullCL :: proc(this: ^Emulator, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr) -> cl.Int {
	return this->EnqueueReadBuffer(buffer, blocking_read, offset, size, ptr, 0, nil, nil);
}
@(private="file")
EnqueueReadBufferEx_NullCL :: proc(this: ^Emulator, buffer: Mem, blocking_read: cl.Bool, offset: c.size_t, size: c.size_t, ptr: rawptr) -> cl.Int {
	unimplemented();
}
