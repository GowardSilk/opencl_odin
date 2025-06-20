package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_function_types.h
* ========================================= */

Get_Platform_I_Ds_T :: #type proc  (num_entries: Uint, platforms: ^Platform_ID, num_platforms: ^Uint) -> Int
Get_Platform_I_Ds_Fn :: ^Get_Platform_I_Ds_T
Get_Platform_Info_T :: #type proc  (
             platform: Platform_ID,
             param_name: Platform_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Platform_Info_Fn :: ^Get_Platform_Info_T
Get_Device_I_Ds_T :: #type proc  (
             platform: Platform_ID,
             device_type: Device_Type,
             num_entries: Uint,
             devices: ^Device_ID,
             num_devices: ^Uint) -> Int
Get_Device_I_Ds_Fn :: ^Get_Device_I_Ds_T
Get_Device_Info_T :: #type proc  (
             device: Device_ID,
             param_name: Device_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Device_Info_Fn :: ^Get_Device_Info_T
Create_Context_T :: #type proc  (
             properties: ^Context_Properties,
             num_devices: Uint,
             devices: ^Device_ID,
             pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr),
             user_data: rawptr,
             errcode_ret: ^Int) -> Context
Create_Context_Fn :: ^Create_Context_T
Create_Context_From_Type_T :: #type proc  (
             properties: ^Context_Properties,
             device_type: Device_Type,
             pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr),
             user_data: rawptr,
             errcode_ret: ^Int) -> Context
Create_Context_From_Type_Fn :: ^Create_Context_From_Type_T
Retain_Context_T :: #type proc  (_context: Context) -> Int
Retain_Context_Fn :: ^Retain_Context_T
Release_Context_T :: #type proc  (_context: Context) -> Int
Release_Context_Fn :: ^Release_Context_T
Get_Context_Info_T :: #type proc  (
             _context: Context,
             param_name: Context_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Context_Info_Fn :: ^Get_Context_Info_T
Retain_Command_Queue_T :: #type proc  (command_queue: Command_Queue) -> Int
Retain_Command_Queue_Fn :: ^Retain_Command_Queue_T
Release_Command_Queue_T :: #type proc  (command_queue: Command_Queue) -> Int
Release_Command_Queue_Fn :: ^Release_Command_Queue_T
Get_Command_Queue_Info_T :: #type proc  (
             command_queue: Command_Queue,
             param_name: Command_Queue_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Command_Queue_Info_Fn :: ^Get_Command_Queue_Info_T
Create_Buffer_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             size: c.size_t,
             host_ptr: rawptr,
             errcode_ret: ^Int) -> Mem
Create_Buffer_Fn :: ^Create_Buffer_T
Retain_Mem_Object_T :: #type proc  (memobj: Mem) -> Int
Retain_Mem_Object_Fn :: ^Retain_Mem_Object_T
Release_Mem_Object_T :: #type proc  (memobj: Mem) -> Int
Release_Mem_Object_Fn :: ^Release_Mem_Object_T
Get_Supported_Image_Formats_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             image_type: Mem_Object_Type,
             num_entries: Uint,
             image_formats: ^Image_Format,
             num_image_formats: ^Uint) -> Int
Get_Supported_Image_Formats_Fn :: ^Get_Supported_Image_Formats_T
Get_Mem_Object_Info_T :: #type proc  (
             memobj: Mem,
             param_name: Mem_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Mem_Object_Info_Fn :: ^Get_Mem_Object_Info_T
Get_Image_Info_T :: #type proc  (
             image: Mem,
             param_name: Image_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Image_Info_Fn :: ^Get_Image_Info_T
Retain_Sampler_T :: #type proc  (sampler: Sampler) -> Int
Retain_Sampler_Fn :: ^Retain_Sampler_T
Release_Sampler_T :: #type proc  (sampler: Sampler) -> Int
Release_Sampler_Fn :: ^Release_Sampler_T
Get_Sampler_Info_T :: #type proc  (
             sampler: Sampler,
             param_name: Sampler_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Sampler_Info_Fn :: ^Get_Sampler_Info_T
Create_Program_With_Source_T :: #type proc  (
             _context: Context,
             count: Uint,
             strings: ^cstring,
             lengths: ^c.size_t,
             errcode_ret: ^Int) -> Program
Create_Program_With_Source_Fn :: ^Create_Program_With_Source_T
Create_Program_With_Binary_T :: #type proc  (
             _context: Context,
             num_devices: Uint,
             device_list: ^Device_ID,
             lengths: ^c.size_t,
             binaries: ^^c.char,
             binary_status: ^Int,
             errcode_ret: ^Int) -> Program
Create_Program_With_Binary_Fn :: ^Create_Program_With_Binary_T
Retain_Program_T :: #type proc  (program: Program) -> Int
Retain_Program_Fn :: ^Retain_Program_T
Release_Program_T :: #type proc  (program: Program) -> Int
Release_Program_Fn :: ^Release_Program_T
Build_Program_T :: #type proc  (
             program: Program,
             num_devices: Uint,
             device_list: ^Device_ID,
             options: cstring,
             pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
             user_data: rawptr) -> Int
Build_Program_Fn :: ^Build_Program_T
Get_Program_Info_T :: #type proc  (
             program: Program,
             param_name: Program_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Program_Info_Fn :: ^Get_Program_Info_T
Get_Program_Build_Info_T :: #type proc  (
             program: Program,
             device: Device_ID,
             param_name: Program_Build_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Program_Build_Info_Fn :: ^Get_Program_Build_Info_T
Create_Kernel_T :: #type proc  (program: Program, kernel_name: cstring, errcode_ret: ^Int) -> Kernel
Create_Kernel_Fn :: ^Create_Kernel_T
Create_Kernels_In_Program_T :: #type proc  (program: Program, num_kernels: Uint, kernels: ^Kernel, num_kernels_ret: ^Uint) -> Int
Create_Kernels_In_Program_Fn :: ^Create_Kernels_In_Program_T
Retain_Kernel_T :: #type proc  (kernel: Kernel) -> Int
Retain_Kernel_Fn :: ^Retain_Kernel_T
Release_Kernel_T :: #type proc  (kernel: Kernel) -> Int
Release_Kernel_Fn :: ^Release_Kernel_T
Set_Kernel_Arg_T :: #type proc  (kernel: Kernel, arg_index: Uint, arg_size: c.size_t, arg_value: rawptr) -> Int
Set_Kernel_Arg_Fn :: ^Set_Kernel_Arg_T
Get_Kernel_Info_T :: #type proc  (
             kernel: Kernel,
             param_name: Kernel_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Kernel_Info_Fn :: ^Get_Kernel_Info_T
Get_Kernel_Work_Group_Info_T :: #type proc  (
             kernel: Kernel,
             device: Device_ID,
             param_name: Kernel_Work_Group_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Kernel_Work_Group_Info_Fn :: ^Get_Kernel_Work_Group_Info_T
Wait_For_Events_T :: #type proc  (num_events: Uint, event_list: ^Event) -> Int
Wait_For_Events_Fn :: ^Wait_For_Events_T
Get_Event_Info_T :: #type proc  (
             event: Event,
             param_name: Event_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Event_Info_Fn :: ^Get_Event_Info_T
Retain_Event_T :: #type proc  (event: Event) -> Int
Retain_Event_Fn :: ^Retain_Event_T
Release_Event_T :: #type proc  (event: Event) -> Int
Release_Event_Fn :: ^Release_Event_T
Get_Event_Profiling_Info_T :: #type proc  (
             event: Event,
             param_name: Profiling_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Event_Profiling_Info_Fn :: ^Get_Event_Profiling_Info_T
Flush_T :: #type proc  (command_queue: Command_Queue) -> Int
Flush_Fn :: ^Flush_T
Finish_T :: #type proc  (command_queue: Command_Queue) -> Int
Finish_Fn :: ^Finish_T
Enqueue_Read_Buffer_T :: #type proc  (
             command_queue: Command_Queue,
             buffer: Mem,
             blocking_read: Bool,
             offset: c.size_t,
             size: c.size_t,
             ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Read_Buffer_Fn :: ^Enqueue_Read_Buffer_T
Enqueue_Write_Buffer_T :: #type proc  (
             command_queue: Command_Queue,
             buffer: Mem,
             blocking_write: Bool,
             offset: c.size_t,
             size: c.size_t,
             ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Write_Buffer_Fn :: ^Enqueue_Write_Buffer_T
Enqueue_Copy_Buffer_T :: #type proc  (
             command_queue: Command_Queue,
             src_buffer: Mem,
             dst_buffer: Mem,
             src_offset: c.size_t,
             dst_offset: c.size_t,
             size: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Copy_Buffer_Fn :: ^Enqueue_Copy_Buffer_T
Enqueue_Read_Image_T :: #type proc  (
             command_queue: Command_Queue,
             image: Mem,
             blocking_read: Bool,
             origin: ^c.size_t,
             region: ^c.size_t,
             row_pitch: c.size_t,
             slice_pitch: c.size_t,
             ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Read_Image_Fn :: ^Enqueue_Read_Image_T
Enqueue_Write_Image_T :: #type proc  (
             command_queue: Command_Queue,
             image: Mem,
             blocking_write: Bool,
             origin: ^c.size_t,
             region: ^c.size_t,
             input_row_pitch: c.size_t,
             input_slice_pitch: c.size_t,
             ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Write_Image_Fn :: ^Enqueue_Write_Image_T
Enqueue_Copy_Image_T :: #type proc  (
             command_queue: Command_Queue,
             src_image: Mem,
             dst_image: Mem,
             src_origin: ^c.size_t,
             dst_origin: ^c.size_t,
             region: ^c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Copy_Image_Fn :: ^Enqueue_Copy_Image_T
Enqueue_Copy_Image_To_Buffer_T :: #type proc  (
             command_queue: Command_Queue,
             src_image: Mem,
             dst_buffer: Mem,
             src_origin: ^c.size_t,
             region: ^c.size_t,
             dst_offset: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Copy_Image_To_Buffer_Fn :: ^Enqueue_Copy_Image_To_Buffer_T
Enqueue_Copy_Buffer_To_Image_T :: #type proc  (
             command_queue: Command_Queue,
             src_buffer: Mem,
             dst_image: Mem,
             src_offset: c.size_t,
             dst_origin: ^c.size_t,
             region: ^c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Copy_Buffer_To_Image_Fn :: ^Enqueue_Copy_Buffer_To_Image_T
Enqueue_Map_Buffer_T :: #type proc  (
             command_queue: Command_Queue,
             buffer: Mem,
             blocking_map: Bool,
             map_flags: Map_Flags,
             offset: c.size_t,
             size: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event,
             errcode_ret: ^Int) -> rawptr
Enqueue_Map_Buffer_Fn :: ^Enqueue_Map_Buffer_T
Enqueue_Map_Image_T :: #type proc  (
             command_queue: Command_Queue,
             image: Mem,
             blocking_map: Bool,
             map_flags: Map_Flags,
             origin: ^c.size_t,
             region: ^c.size_t,
             image_row_pitch: ^c.size_t,
             image_slice_pitch: ^c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event,
             errcode_ret: ^Int) -> rawptr
Enqueue_Map_Image_Fn :: ^Enqueue_Map_Image_T
Enqueue_Unmap_Mem_Object_T :: #type proc  (
             command_queue: Command_Queue,
             memobj: Mem,
             mapped_ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Unmap_Mem_Object_Fn :: ^Enqueue_Unmap_Mem_Object_T
Enqueue_ND_Range_Kernel_T :: #type proc  (
             command_queue: Command_Queue,
             kernel: Kernel,
             work_dim: Uint,
             global_work_offset: ^c.size_t,
             global_work_size: ^c.size_t,
             local_work_size: ^c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_ND_Range_Kernel_Fn :: ^Enqueue_ND_Range_Kernel_T
Enqueue_Native_Kernel_T :: #type proc  (
             command_queue: Command_Queue,
             user_func: #type proc "stdcall" (_1: rawptr),
             args: rawptr,
             cb_args: c.size_t,
             num_mem_objects: Uint,
             mem_list: ^Mem,
             args_mem_loc: ^rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Native_Kernel_Fn :: ^Enqueue_Native_Kernel_T
Set_Command_Queue_Property_T :: #type proc  (
             command_queue: Command_Queue,
             properties: Command_Queue_Properties,
             enable: Bool,
             old_properties: ^Command_Queue_Properties) -> Int
Set_Command_Queue_Property_Fn :: ^Set_Command_Queue_Property_T
Create_Image2D_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             image_format: ^Image_Format,
             image_width: c.size_t,
             image_height: c.size_t,
             image_row_pitch: c.size_t,
             host_ptr: rawptr,
             errcode_ret: ^Int) -> Mem
Create_Image2D_Fn :: ^Create_Image2D_T
Create_Image3D_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             image_format: ^Image_Format,
             image_width: c.size_t,
             image_height: c.size_t,
             image_depth: c.size_t,
             image_row_pitch: c.size_t,
             image_slice_pitch: c.size_t,
             host_ptr: rawptr,
             errcode_ret: ^Int) -> Mem
Create_Image3D_Fn :: ^Create_Image3D_T
Enqueue_Marker_T :: #type proc  (command_queue: Command_Queue, event: ^Event) -> Int
Enqueue_Marker_Fn :: ^Enqueue_Marker_T
Enqueue_Wait_For_Events_T :: #type proc  (command_queue: Command_Queue, num_events: Uint, event_list: ^Event) -> Int
Enqueue_Wait_For_Events_Fn :: ^Enqueue_Wait_For_Events_T
Enqueue_Barrier_T :: #type proc  (command_queue: Command_Queue) -> Int
Enqueue_Barrier_Fn :: ^Enqueue_Barrier_T
Unload_Compiler_T :: #type proc  () -> Int
Unload_Compiler_Fn :: ^Unload_Compiler_T
Get_Extension_Function_Address_T :: #type proc  (func_name: cstring) -> rawptr
Get_Extension_Function_Address_Fn :: ^Get_Extension_Function_Address_T
Create_Command_Queue_T :: #type proc  (
             _context: Context,
             device: Device_ID,
             properties: Command_Queue_Properties,
             errcode_ret: ^Int) -> Command_Queue
Create_Command_Queue_Fn :: ^Create_Command_Queue_T
Create_Sampler_T :: #type proc  (
             _context: Context,
             normalized_coords: Bool,
             addressing_mode: Addressing_Mode,
             filter_mode: Filter_Mode,
             errcode_ret: ^Int) -> Sampler
Create_Sampler_Fn :: ^Create_Sampler_T
Enqueue_Task_T :: #type proc  (
             command_queue: Command_Queue,
             kernel: Kernel,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Task_Fn :: ^Enqueue_Task_T
Create_Sub_Buffer_T :: #type proc  (
             buffer: Mem,
             flags: Mem_Flags,
             buffer_create_type: Buffer_Create_Type,
             buffer_create_info: rawptr,
             errcode_ret: ^Int) -> Mem
Create_Sub_Buffer_Fn :: ^Create_Sub_Buffer_T
Set_Mem_Object_Destructor_Callback_T :: #type proc  (
             memobj: Mem,
             pfn_notify: #type proc "stdcall" (memobj: Mem, user_data: rawptr),
             user_data: rawptr) -> Int
Set_Mem_Object_Destructor_Callback_Fn :: ^Set_Mem_Object_Destructor_Callback_T
Create_User_Event_T :: #type proc  (_context: Context, errcode_ret: ^Int) -> Event
Create_User_Event_Fn :: ^Create_User_Event_T
Set_User_Event_Status_T :: #type proc  (event: Event, execution_status: Int) -> Int
Set_User_Event_Status_Fn :: ^Set_User_Event_Status_T
Set_Event_Callback_T :: #type proc  (
             event: Event,
             command_exec_callback_type: Int,
             pfn_notify: #type proc "stdcall" (event: Event, event_command_status: Int, user_data: rawptr),
             user_data: rawptr) -> Int
Set_Event_Callback_Fn :: ^Set_Event_Callback_T
Enqueue_Read_Buffer_Rect_T :: #type proc  (
             command_queue: Command_Queue,
             buffer: Mem,
             blocking_read: Bool,
             buffer_origin: ^c.size_t,
             host_origin: ^c.size_t,
             region: ^c.size_t,
             buffer_row_pitch: c.size_t,
             buffer_slice_pitch: c.size_t,
             host_row_pitch: c.size_t,
             host_slice_pitch: c.size_t,
             ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Read_Buffer_Rect_Fn :: ^Enqueue_Read_Buffer_Rect_T
Enqueue_Write_Buffer_Rect_T :: #type proc  (
             command_queue: Command_Queue,
             buffer: Mem,
             blocking_write: Bool,
             buffer_origin: ^c.size_t,
             host_origin: ^c.size_t,
             region: ^c.size_t,
             buffer_row_pitch: c.size_t,
             buffer_slice_pitch: c.size_t,
             host_row_pitch: c.size_t,
             host_slice_pitch: c.size_t,
             ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Write_Buffer_Rect_Fn :: ^Enqueue_Write_Buffer_Rect_T
Enqueue_Copy_Buffer_Rect_T :: #type proc  (
             command_queue: Command_Queue,
             src_buffer: Mem,
             dst_buffer: Mem,
             src_origin: ^c.size_t,
             dst_origin: ^c.size_t,
             region: ^c.size_t,
             src_row_pitch: c.size_t,
             src_slice_pitch: c.size_t,
             dst_row_pitch: c.size_t,
             dst_slice_pitch: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Copy_Buffer_Rect_Fn :: ^Enqueue_Copy_Buffer_Rect_T
Create_Sub_Devices_T :: #type proc  (
             in_device: Device_ID,
             properties: ^Device_Partition_Property,
             num_devices: Uint,
             out_devices: ^Device_ID,
             num_devices_ret: ^Uint) -> Int
Create_Sub_Devices_Fn :: ^Create_Sub_Devices_T
Retain_Device_T :: #type proc  (device: Device_ID) -> Int
Retain_Device_Fn :: ^Retain_Device_T
Release_Device_T :: #type proc  (device: Device_ID) -> Int
Release_Device_Fn :: ^Release_Device_T
Create_Image_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             image_format: ^Image_Format,
             image_desc: ^Image_Desc,
             host_ptr: rawptr,
             errcode_ret: ^Int) -> Mem
Create_Image_Fn :: ^Create_Image_T
Create_Program_With_Built_In_Kernels_T :: #type proc  (
             _context: Context,
             num_devices: Uint,
             device_list: ^Device_ID,
             kernel_names: cstring,
             errcode_ret: ^Int) -> Program
Create_Program_With_Built_In_Kernels_Fn :: ^Create_Program_With_Built_In_Kernels_T
Compile_Program_T :: #type proc  (
             program: Program,
             num_devices: Uint,
             device_list: ^Device_ID,
             options: cstring,
             num_input_headers: Uint,
             input_headers: ^Program,
             header_include_names: ^cstring,
             pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
             user_data: rawptr) -> Int
Compile_Program_Fn :: ^Compile_Program_T
Link_Program_T :: #type proc  (
             _context: Context,
             num_devices: Uint,
             device_list: ^Device_ID,
             options: cstring,
             num_input_programs: Uint,
             input_programs: ^Program,
             pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
             user_data: rawptr,
             errcode_ret: ^Int) -> Program
Link_Program_Fn :: ^Link_Program_T
Unload_Platform_Compiler_T :: #type proc  (platform: Platform_ID) -> Int
Unload_Platform_Compiler_Fn :: ^Unload_Platform_Compiler_T
Get_Kernel_Arg_Info_T :: #type proc  (
             kernel: Kernel,
             arg_index: Uint,
             param_name: Kernel_Arg_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Kernel_Arg_Info_Fn :: ^Get_Kernel_Arg_Info_T
Enqueue_Fill_Buffer_T :: #type proc  (
             command_queue: Command_Queue,
             buffer: Mem,
             pattern: rawptr,
             pattern_size: c.size_t,
             offset: c.size_t,
             size: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Fill_Buffer_Fn :: ^Enqueue_Fill_Buffer_T
Enqueue_Fill_Image_T :: #type proc  (
             command_queue: Command_Queue,
             image: Mem,
             fill_color: rawptr,
             origin: ^c.size_t,
             region: ^c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Fill_Image_Fn :: ^Enqueue_Fill_Image_T
Enqueue_Migrate_Mem_Objects_T :: #type proc  (
             command_queue: Command_Queue,
             num_mem_objects: Uint,
             mem_objects: ^Mem,
             flags: Mem_Migration_Flags,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Migrate_Mem_Objects_Fn :: ^Enqueue_Migrate_Mem_Objects_T
Enqueue_Marker_With_Wait_List_T :: #type proc  (
             command_queue: Command_Queue,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Marker_With_Wait_List_Fn :: ^Enqueue_Marker_With_Wait_List_T
Enqueue_Barrier_With_Wait_List_T :: #type proc  (
             command_queue: Command_Queue,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Barrier_With_Wait_List_Fn :: ^Enqueue_Barrier_With_Wait_List_T
Get_Extension_Function_Address_For_Platform_T :: #type proc  (platform: Platform_ID, func_name: cstring) -> rawptr
Get_Extension_Function_Address_For_Platform_Fn :: ^Get_Extension_Function_Address_For_Platform_T
Create_Command_Queue_With_Properties_T :: #type proc  (
             _context: Context,
             device: Device_ID,
             properties: ^Queue_Properties,
             errcode_ret: ^Int) -> Command_Queue
Create_Command_Queue_With_Properties_Fn :: ^Create_Command_Queue_With_Properties_T
Create_Pipe_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             pipe_packet_size: Uint,
             pipe_max_packets: Uint,
             properties: ^Pipe_Properties,
             errcode_ret: ^Int) -> Mem
Create_Pipe_Fn :: ^Create_Pipe_T
Get_Pipe_Info_T :: #type proc  (
             pipe: Mem,
             param_name: Pipe_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Pipe_Info_Fn :: ^Get_Pipe_Info_T
SVM_Alloc_T :: #type proc  (_context: Context, flags: SVM_Mem_Flags, size: c.size_t, alignment: Uint) -> rawptr
SVM_Alloc_Fn :: ^SVM_Alloc_T
SVM_Free_T :: #type proc  (_context: Context, svm_pointer: rawptr)
SVM_Free_Fn :: ^SVM_Free_T
Create_Sampler_With_Properties_T :: #type proc  (
             _context: Context,
             sampler_properties: ^Sampler_Properties,
             errcode_ret: ^Int) -> Sampler
Create_Sampler_With_Properties_Fn :: ^Create_Sampler_With_Properties_T
Set_Kernel_Arg_SVM_Pointer_T :: #type proc  (kernel: Kernel, arg_index: Uint, arg_value: rawptr) -> Int
Set_Kernel_Arg_SVM_Pointer_Fn :: ^Set_Kernel_Arg_SVM_Pointer_T
Set_Kernel_Exec_Info_T :: #type proc  (
             kernel: Kernel,
             param_name: Kernel_Exec_Info,
             param_value_size: c.size_t,
             param_value: rawptr) -> Int
Set_Kernel_Exec_Info_Fn :: ^Set_Kernel_Exec_Info_T
Enqueue_SVM_Free_T :: #type proc  (
             command_queue: Command_Queue,
             num_svm_pointers: Uint,
             svm_pointers: []rawptr,
             pfn_free_func: #type proc "stdcall" (queue: Command_Queue, num_svm_pointers: Uint, svm_pointers: []rawptr, user_data: rawptr),
             user_data: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_SVM_Free_Fn :: ^Enqueue_SVM_Free_T
Enqueue_SVM_Memcpy_T :: #type proc  (
             command_queue: Command_Queue,
             blocking_copy: Bool,
             dst_ptr: rawptr,
             src_ptr: rawptr,
             size: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_SVM_Memcpy_Fn :: ^Enqueue_SVM_Memcpy_T
Enqueue_SVM_Mem_Fill_T :: #type proc  (
             command_queue: Command_Queue,
             svm_ptr: rawptr,
             pattern: rawptr,
             pattern_size: c.size_t,
             size: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_SVM_Mem_Fill_Fn :: ^Enqueue_SVM_Mem_Fill_T
Enqueue_SVM_Map_T :: #type proc  (
             command_queue: Command_Queue,
             blocking_map: Bool,
             flags: Map_Flags,
             svm_ptr: rawptr,
             size: c.size_t,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_SVM_Map_Fn :: ^Enqueue_SVM_Map_T
Enqueue_SVM_Unmap_T :: #type proc  (
             command_queue: Command_Queue,
             svm_ptr: rawptr,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_SVM_Unmap_Fn :: ^Enqueue_SVM_Unmap_T
Set_Default_Device_Command_Queue_T :: #type proc  (_context: Context, device: Device_ID, command_queue: Command_Queue) -> Int
Set_Default_Device_Command_Queue_Fn :: ^Set_Default_Device_Command_Queue_T
Get_Device_And_Host_Timer_T :: #type proc  (device: Device_ID, device_timestamp: ^Ulong, host_timestamp: ^Ulong) -> Int
Get_Device_And_Host_Timer_Fn :: ^Get_Device_And_Host_Timer_T
Get_Host_Timer_T :: #type proc  (device: Device_ID, host_timestamp: ^Ulong) -> Int
Get_Host_Timer_Fn :: ^Get_Host_Timer_T
Create_Program_With_IL_T :: #type proc  (_context: Context, il: rawptr, length: c.size_t, errcode_ret: ^Int) -> Program
Create_Program_With_IL_Fn :: ^Create_Program_With_IL_T
Clone_Kernel_T :: #type proc  (source_kernel: Kernel, errcode_ret: ^Int) -> Kernel
Clone_Kernel_Fn :: ^Clone_Kernel_T
Get_Kernel_Sub_Group_Info_T :: #type proc  (
             kernel: Kernel,
             device: Device_ID,
             param_name: Kernel_Sub_Group_Info,
             input_value_size: c.size_t,
             input_value: rawptr,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_Kernel_Sub_Group_Info_Fn :: ^Get_Kernel_Sub_Group_Info_T
Enqueue_SVM_Migrate_Mem_T :: #type proc  (
             command_queue: Command_Queue,
             num_svm_pointers: Uint,
             svm_pointers: ^rawptr,
             sizes: ^c.size_t,
             flags: Mem_Migration_Flags,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_SVM_Migrate_Mem_Fn :: ^Enqueue_SVM_Migrate_Mem_T
Set_Program_Specialization_Constant_T :: #type proc  (program: Program, spec_id: Uint, spec_size: c.size_t, spec_value: rawptr) -> Int
Set_Program_Specialization_Constant_Fn :: ^Set_Program_Specialization_Constant_T
Set_Program_Release_Callback_T :: #type proc  (
             program: Program,
             pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
             user_data: rawptr) -> Int
Set_Program_Release_Callback_Fn :: ^Set_Program_Release_Callback_T
Set_Context_Destructor_Callback_T :: #type proc  (
             _context: Context,
             pfn_notify: #type proc "stdcall" (_context: Context, user_data: rawptr),
             user_data: rawptr) -> Int
Set_Context_Destructor_Callback_Fn :: ^Set_Context_Destructor_Callback_T
Create_Buffer_With_Properties_T :: #type proc  (
             _context: Context,
             properties: ^Mem_Properties,
             flags: Mem_Flags,
             size: c.size_t,
             host_ptr: rawptr,
             errcode_ret: ^Int) -> Mem
Create_Buffer_With_Properties_Fn :: ^Create_Buffer_With_Properties_T
Create_Image_With_Properties_T :: #type proc  (
             _context: Context,
             properties: ^Mem_Properties,
             flags: Mem_Flags,
             image_format: ^Image_Format,
             image_desc: ^Image_Desc,
             host_ptr: rawptr,
             errcode_ret: ^Int) -> Mem
Create_Image_With_Properties_Fn :: ^Create_Image_With_Properties_T
