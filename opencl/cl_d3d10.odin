package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_d3d10.h
* ========================================= */

KHR_D3D10_Sharing :: 1
KHR_D3D10_SHARING_EXTENSION_NAME :: "cl_khr_d3d10_sharing"
KHR_D3D10_SHARING_EXTENSION_VERSION := MAKE_VERSION(1, 0, 0)
INVALID_D3D10_DEVICE_KHR :: -1002
INVALID_D3D10_RESOURCE_KHR :: -1003
D3D10_RESOURCE_ALREADY_ACQUIRED_KHR :: -1004
D3D10_RESOURCE_NOT_ACQUIRED_KHR :: -1005
D3D10_DEVICE_KHR :: 0x4010
D3D10_DXGI_ADAPTER_KHR :: 0x4011
PREFERRED_DEVICES_FOR_D3D10_KHR :: 0x4012
ALL_DEVICES_FOR_D3D10_KHR :: 0x4013
CONTEXT_D3D10_DEVICE_KHR :: 0x4014
CONTEXT_D3D10_PREFER_SHARED_RESOURCES_KHR :: 0x402C
MEM_D3D10_RESOURCE_KHR :: 0x4015
IMAGE_D3D10_SUBRESOURCE_KHR :: 0x4016
COMMAND_ACQUIRE_D3D10_OBJECTS_KHR :: 0x4017
COMMAND_RELEASE_D3D10_OBJECTS_KHR :: 0x4018
INTEL_Sharing_Format_Query_D3D10_ :: 1
INTEL_SHARING_FORMAT_QUERY_D3D10_EXTENSION_NAME :: "cl_intel_sharing_format_query_d3d10"
INTEL_SHARING_FORMAT_QUERY_D3D10_EXTENSION_VERSION := MAKE_VERSION(0, 0, 0)

D3D10_Device_Source_KHR :: Uint
D3D10_Device_Set_KHR :: Uint
Get_Device_I_Ds_From_D3D10_KHR_T :: #type proc  (
             platform: Platform_ID,
             d3d_device_source: D3D10_Device_Source_KHR,
             d3d_object: rawptr,
             d3d_device_set: D3D10_Device_Set_KHR,
             num_entries: Uint,
             devices: ^Device_ID,
             num_devices: ^Uint) -> Int
Get_Device_I_Ds_From_D3D10_KHR_Fn :: ^Get_Device_I_Ds_From_D3D10_KHR_T
Create_From_D3D10_Buffer_KHR_T :: #type proc  (_context: Context, flags: Mem_Flags, resource: ^rawptr, errcode_ret: ^Int) -> Mem
Create_From_D3D10_Buffer_KHR_Fn :: ^Create_From_D3D10_Buffer_KHR_T
Create_From_D3D10_Texture2D_KHR_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             resource: ^rawptr,
             subresource: win32.UINT,
             errcode_ret: ^Int) -> Mem
Create_From_D3D10_Texture2D_KHR_Fn :: ^Create_From_D3D10_Texture2D_KHR_T
Create_From_D3D10_Texture3D_KHR_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             resource: ^rawptr,
             subresource: win32.UINT,
             errcode_ret: ^Int) -> Mem
Create_From_D3D10_Texture3D_KHR_Fn :: ^Create_From_D3D10_Texture3D_KHR_T
Enqueue_Acquire_D3D10_Objects_KHR_T :: #type proc  (
             command_queue: Command_Queue,
             num_objects: Uint,
             mem_objects: ^Mem,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Acquire_D3D10_Objects_KHR_Fn :: ^Enqueue_Acquire_D3D10_Objects_KHR_T
Enqueue_Release_D3D10_Objects_KHR_T :: #type proc  (
             command_queue: Command_Queue,
             num_objects: Uint,
             mem_objects: ^Mem,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Release_D3D10_Objects_KHR_Fn :: ^Enqueue_Release_D3D10_Objects_KHR_T
Get_Supported_D3D10_Texture_Formats_INTEL_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             image_type: Mem_Object_Type,
             num_entries: Uint,
             d3d10_formats: ^dxgi.FORMAT,
             num_texture_formats: ^Uint) -> Int
Get_Supported_D3D10_Texture_Formats_INTEL_Fn :: ^Get_Supported_D3D10_Texture_Formats_INTEL_T

@(link_prefix="cl")
foreign opencl {
	GetDeviceIDsFromD3D10KHR :: proc  (
                                   platform: Platform_ID,
                                   d3d_device_source: D3D10_Device_Source_KHR,
                                   d3d_object: rawptr,
                                   d3d_device_set: D3D10_Device_Set_KHR,
                                   num_entries: Uint,
                                   devices: ^Device_ID,
                                   num_devices: ^Uint) -> Int ---
	CreateFromD3D10BufferKHR :: proc  (
                                   _context: Context,
                                   flags: Mem_Flags,
                                   resource: ^rawptr,
                                   errcode_ret: ^Int) -> Mem ---
	CreateFromD3D10Texture2DKHR :: proc  (
                                      _context: Context,
                                      flags: Mem_Flags,
                                      resource: ^rawptr,
                                      subresource: win32.UINT,
                                      errcode_ret: ^Int) -> Mem ---
	CreateFromD3D10Texture3DKHR :: proc  (
                                      _context: Context,
                                      flags: Mem_Flags,
                                      resource: ^rawptr,
                                      subresource: win32.UINT,
                                      errcode_ret: ^Int) -> Mem ---
	EnqueueAcquireD3D10ObjectsKHR :: proc  (
                                        command_queue: Command_Queue,
                                        num_objects: Uint,
                                        mem_objects: ^Mem,
                                        num_events_in_wait_list: Uint,
                                        event_wait_list: ^Event,
                                        event: ^Event) -> Int ---
	EnqueueReleaseD3D10ObjectsKHR :: proc  (
                                        command_queue: Command_Queue,
                                        num_objects: Uint,
                                        mem_objects: ^Mem,
                                        num_events_in_wait_list: Uint,
                                        event_wait_list: ^Event,
                                        event: ^Event) -> Int ---
	GetSupportedD3D10TextureFormatsINTEL :: proc  (
                                               _context: Context,
                                               flags: Mem_Flags,
                                               image_type: Mem_Object_Type,
                                               num_entries: Uint,
                                               d3d10_formats: ^dxgi.FORMAT,
                                               num_texture_formats: ^Uint) -> Int ---
}
