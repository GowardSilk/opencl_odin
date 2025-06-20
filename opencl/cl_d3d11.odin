package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_d3d11.h
* ========================================= */

KHR_D3D11_Sharing :: 1
KHR_D3D11_SHARING_EXTENSION_NAME :: "cl_khr_d3d11_sharing"
KHR_D3D11_SHARING_EXTENSION_VERSION := MAKE_VERSION(1, 0, 0)
INVALID_D3D11_DEVICE_KHR :: -1006
INVALID_D3D11_RESOURCE_KHR :: -1007
D3D11_RESOURCE_ALREADY_ACQUIRED_KHR :: -1008
D3D11_RESOURCE_NOT_ACQUIRED_KHR :: -1009
D3D11_DEVICE_KHR :: 0x4019
D3D11_DXGI_ADAPTER_KHR :: 0x401A
PREFERRED_DEVICES_FOR_D3D11_KHR :: 0x401B
ALL_DEVICES_FOR_D3D11_KHR :: 0x401C
CONTEXT_D3D11_DEVICE_KHR :: 0x401D
CONTEXT_D3D11_PREFER_SHARED_RESOURCES_KHR :: 0x402D
MEM_D3D11_RESOURCE_KHR :: 0x401E
IMAGE_D3D11_SUBRESOURCE_KHR :: 0x401F
COMMAND_ACQUIRE_D3D11_OBJECTS_KHR :: 0x4020
COMMAND_RELEASE_D3D11_OBJECTS_KHR :: 0x4021
INTEL_Sharing_Format_Query_D3D11_ :: 1
INTEL_SHARING_FORMAT_QUERY_D3D11_EXTENSION_NAME :: "cl_intel_sharing_format_query_d3d11"
INTEL_SHARING_FORMAT_QUERY_D3D11_EXTENSION_VERSION := MAKE_VERSION(0, 0, 0)

D3D11_Device_Source_KHR :: Uint
D3D11_Device_Set_KHR :: Uint
Get_Device_I_Ds_From_D3D11_KHR_T :: #type proc  (
             platform: Platform_ID,
             d3d_device_source: D3D11_Device_Source_KHR,
             d3d_object: rawptr,
             d3d_device_set: D3D11_Device_Set_KHR,
             num_entries: Uint,
             devices: ^Device_ID,
             num_devices: ^Uint) -> Int
Get_Device_I_Ds_From_D3D11_KHR_Fn :: ^Get_Device_I_Ds_From_D3D11_KHR_T
Create_From_D3D11_Buffer_KHR_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             resource: ^d3d11.IBuffer,
             errcode_ret: ^Int) -> Mem
Create_From_D3D11_Buffer_KHR_Fn :: ^Create_From_D3D11_Buffer_KHR_T
Create_From_D3D11_Texture2D_KHR_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             resource: ^d3d11.ITexture2D,
             subresource: win32.UINT,
             errcode_ret: ^Int) -> Mem
Create_From_D3D11_Texture2D_KHR_Fn :: ^Create_From_D3D11_Texture2D_KHR_T
Create_From_D3D11_Texture3D_KHR_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             resource: ^d3d11.ITexture3D,
             subresource: win32.UINT,
             errcode_ret: ^Int) -> Mem
Create_From_D3D11_Texture3D_KHR_Fn :: ^Create_From_D3D11_Texture3D_KHR_T
Enqueue_Acquire_D3D11_Objects_KHR_T :: #type proc  (
             command_queue: Command_Queue,
             num_objects: Uint,
             mem_objects: ^Mem,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Acquire_D3D11_Objects_KHR_Fn :: ^Enqueue_Acquire_D3D11_Objects_KHR_T
Enqueue_Release_D3D11_Objects_KHR_T :: #type proc  (
             command_queue: Command_Queue,
             num_objects: Uint,
             mem_objects: ^Mem,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Release_D3D11_Objects_KHR_Fn :: ^Enqueue_Release_D3D11_Objects_KHR_T
Get_Supported_D3D11_Texture_Formats_INTEL_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             image_type: Mem_Object_Type,
             plane: Uint,
             num_entries: Uint,
             d3d11_formats: ^dxgi.FORMAT,
             num_texture_formats: ^Uint) -> Int
Get_Supported_D3D11_Texture_Formats_INTEL_Fn :: ^Get_Supported_D3D11_Texture_Formats_INTEL_T

@(link_prefix="cl")
foreign opencl {
	GetDeviceIDsFromD3D11KHR :: proc  (
                                   platform: Platform_ID,
                                   d3d_device_source: D3D11_Device_Source_KHR,
                                   d3d_object: rawptr,
                                   d3d_device_set: D3D11_Device_Set_KHR,
                                   num_entries: Uint,
                                   devices: ^Device_ID,
                                   num_devices: ^Uint) -> Int ---
	CreateFromD3D11BufferKHR :: proc  (
                                   _context: Context,
                                   flags: Mem_Flags,
                                   resource: ^d3d11.IBuffer,
                                   errcode_ret: ^Int) -> Mem ---
	CreateFromD3D11Texture2DKHR :: proc  (
                                      _context: Context,
                                      flags: Mem_Flags,
                                      resource: ^d3d11.ITexture2D,
                                      subresource: win32.UINT,
                                      errcode_ret: ^Int) -> Mem ---
	CreateFromD3D11Texture3DKHR :: proc  (
                                      _context: Context,
                                      flags: Mem_Flags,
                                      resource: ^d3d11.ITexture3D,
                                      subresource: win32.UINT,
                                      errcode_ret: ^Int) -> Mem ---
	EnqueueAcquireD3D11ObjectsKHR :: proc  (
                                        command_queue: Command_Queue,
                                        num_objects: Uint,
                                        mem_objects: ^Mem,
                                        num_events_in_wait_list: Uint,
                                        event_wait_list: ^Event,
                                        event: ^Event) -> Int ---
	EnqueueReleaseD3D11ObjectsKHR :: proc  (
                                        command_queue: Command_Queue,
                                        num_objects: Uint,
                                        mem_objects: ^Mem,
                                        num_events_in_wait_list: Uint,
                                        event_wait_list: ^Event,
                                        event: ^Event) -> Int ---
	GetSupportedD3D11TextureFormatsINTEL :: proc  (
                                               _context: Context,
                                               flags: Mem_Flags,
                                               image_type: Mem_Object_Type,
                                               plane: Uint,
                                               num_entries: Uint,
                                               d3d11_formats: ^dxgi.FORMAT,
                                               num_texture_formats: ^Uint) -> Int ---
}
