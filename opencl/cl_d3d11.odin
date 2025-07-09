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

GetDeviceIDsFromD3D11KHR: Get_Device_I_Ds_From_D3D11_KHR_T
CreateFromD3D11BufferKHR: Create_From_D3D11_Buffer_KHR_T
CreateFromD3D11Texture2DKHR: Create_From_D3D11_Texture2D_KHR_T
CreateFromD3D11Texture3DKHR: Create_From_D3D11_Texture3D_KHR_T
EnqueueAcquireD3D11ObjectsKHR: Enqueue_Acquire_D3D11_Objects_KHR_T
EnqueueReleaseD3D11ObjectsKHR: Enqueue_Release_D3D11_Objects_KHR_T
GetSupportedD3D11TextureFormatsINTEL: Get_Supported_D3D11_Texture_Formats_INTEL_T
LoadD3D11KHRFunctions :: proc(platform: Platform_ID) {
	GetDeviceIDsFromD3D11KHR = auto_cast GetExtensionFunctionAddressForPlatform(platform, "clGetDeviceIDsFromD3D11KHR");
	CreateFromD3D11BufferKHR = auto_cast GetExtensionFunctionAddressForPlatform(platform, "clCreateFromD3D11BufferKHR");
	CreateFromD3D11Texture2DKHR = auto_cast GetExtensionFunctionAddressForPlatform(platform, "clCreateFromD3D11Texture2DKHR");
	CreateFromD3D11Texture3DKHR = auto_cast GetExtensionFunctionAddressForPlatform(platform, "clCreateFromD3D11Texture3DKHR");
	EnqueueAcquireD3D11ObjectsKHR = auto_cast GetExtensionFunctionAddressForPlatform(platform, "clEnqueueAcquireD3D11ObjectsKHR");
	EnqueueReleaseD3D11ObjectsKHR = auto_cast GetExtensionFunctionAddressForPlatform(platform, "clEnqueueReleaseD3D11ObjectsKHR");
	GetSupportedD3D11TextureFormatsINTEL = auto_cast GetExtensionFunctionAddressForPlatform(platform, "clGetSupportedD3D11TextureFormatsINTEL");
}
