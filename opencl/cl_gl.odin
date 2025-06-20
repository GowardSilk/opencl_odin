package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_gl.h
* ========================================= */

KHR_GL_Sharing :: 1
KHR_GL_SHARING_EXTENSION_NAME :: "cl_khr_gl_sharing"
KHR_GL_SHARING_EXTENSION_VERSION := MAKE_VERSION(1, 0, 0)
INVALID_GL_SHAREGROUP_REFERENCE_KHR :: -1000
CURRENT_DEVICE_FOR_GL_CONTEXT_KHR :: 0x2006
DEVICES_FOR_GL_CONTEXT_KHR :: 0x2007
GL_CONTEXT_KHR :: 0x2008
EGL_DISPLAY_KHR :: 0x2009
GLX_DISPLAY_KHR :: 0x200A
WGL_HDC_KHR :: 0x200B
CGL_SHAREGROUP_KHR :: 0x200C
GL_OBJECT_BUFFER :: 0x2000
GL_OBJECT_TEXTURE2D :: 0x2001
GL_OBJECT_TEXTURE3D :: 0x2002
GL_OBJECT_RENDERBUFFER :: 0x2003
GL_OBJECT_TEXTURE2D_ARRAY :: 0x200E
GL_OBJECT_TEXTURE1D :: 0x200F
GL_OBJECT_TEXTURE1D_ARRAY :: 0x2010
GL_OBJECT_TEXTURE_BUFFER :: 0x2011
GL_TEXTURE_TARGET :: 0x2004
GL_MIPMAP_LEVEL :: 0x2005
KHR_GL_Event :: 1
KHR_GL_EVENT_EXTENSION_NAME :: "cl_khr_gl_event"
KHR_GL_EVENT_EXTENSION_VERSION := MAKE_VERSION(1, 0, 0)
COMMAND_GL_FENCE_SYNC_OBJECT_KHR :: 0x200D
KHR_GL_Depth_Images :: 1
KHR_GL_DEPTH_IMAGES_EXTENSION_NAME :: "cl_khr_gl_depth_images"
KHR_GL_DEPTH_IMAGES_EXTENSION_VERSION := MAKE_VERSION(1, 0, 0)
DEPTH_STENCIL :: 0x10BE
UNORM_INT24 :: 0x10DF
KHR_GL_Msaa_Sharing :: 1
KHR_GL_MSAA_SHARING_EXTENSION_NAME :: "cl_khr_gl_msaa_sharing"
KHR_GL_MSAA_SHARING_EXTENSION_VERSION := MAKE_VERSION(1, 0, 0)
GL_NUM_SAMPLES :: 0x2012
INTEL_Sharing_Format_Query_GL :: 1
INTEL_SHARING_FORMAT_QUERY_GL_EXTENSION_NAME :: "cl_intel_sharing_format_query_gl"
INTEL_SHARING_FORMAT_QUERY_GL_EXTENSION_VERSION := MAKE_VERSION(0, 0, 0)

G_Lint :: c.int
G_Lenum :: c.uint
G_Luint :: c.uint
GL_Context_Info :: Uint
GL_Object_Type :: Uint
GL_Texture_Info :: Uint
GL_Platform_Info :: Uint
Get_GL_Context_Info_KHR_T :: #type proc  (
             properties: ^Context_Properties,
             param_name: GL_Context_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_GL_Context_Info_KHR_Fn :: ^Get_GL_Context_Info_KHR_T
Create_From_GL_Buffer_T :: #type proc  (_context: Context, flags: Mem_Flags, bufobj: G_Luint, errcode_ret: ^Int) -> Mem
Create_From_GL_Buffer_Fn :: ^Create_From_GL_Buffer_T
Create_From_GL_Texture_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             target: G_Lenum,
             miplevel: G_Lint,
             texture: G_Luint,
             errcode_ret: ^Int) -> Mem
Create_From_GL_Texture_Fn :: ^Create_From_GL_Texture_T
Create_From_GL_Renderbuffer_T :: #type proc  (_context: Context, flags: Mem_Flags, renderbuffer: G_Luint, errcode_ret: ^Int) -> Mem
Create_From_GL_Renderbuffer_Fn :: ^Create_From_GL_Renderbuffer_T
Get_GL_Object_Info_T :: #type proc  (memobj: Mem, gl_object_type: ^GL_Object_Type, gl_object_name: ^G_Luint) -> Int
Get_GL_Object_Info_Fn :: ^Get_GL_Object_Info_T
Get_GL_Texture_Info_T :: #type proc  (
             memobj: Mem,
             param_name: GL_Texture_Info,
             param_value_size: c.size_t,
             param_value: rawptr,
             param_value_size_ret: ^c.size_t) -> Int
Get_GL_Texture_Info_Fn :: ^Get_GL_Texture_Info_T
Enqueue_Acquire_GL_Objects_T :: #type proc  (
             command_queue: Command_Queue,
             num_objects: Uint,
             mem_objects: ^Mem,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Acquire_GL_Objects_Fn :: ^Enqueue_Acquire_GL_Objects_T
Enqueue_Release_GL_Objects_T :: #type proc  (
             command_queue: Command_Queue,
             num_objects: Uint,
             mem_objects: ^Mem,
             num_events_in_wait_list: Uint,
             event_wait_list: ^Event,
             event: ^Event) -> Int
Enqueue_Release_GL_Objects_Fn :: ^Enqueue_Release_GL_Objects_T
Create_From_GL_Texture2D_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             target: G_Lenum,
             miplevel: G_Lint,
             texture: G_Luint,
             errcode_ret: ^Int) -> Mem
Create_From_GL_Texture2D_Fn :: ^Create_From_GL_Texture2D_T
Create_From_GL_Texture3D_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             target: G_Lenum,
             miplevel: G_Lint,
             texture: G_Luint,
             errcode_ret: ^Int) -> Mem
Create_From_GL_Texture3D_Fn :: ^Create_From_GL_Texture3D_T
G_Lsync :: distinct rawptr
Create_Event_From_G_Lsync_KHR_T :: #type proc  (_context: Context, sync: G_Lsync, errcode_ret: ^Int) -> Event
Create_Event_From_G_Lsync_KHR_Fn :: ^Create_Event_From_G_Lsync_KHR_T
Get_Supported_GL_Texture_Formats_INTEL_T :: #type proc  (
             _context: Context,
             flags: Mem_Flags,
             image_type: Mem_Object_Type,
             num_entries: Uint,
             gl_formats: ^G_Lenum,
             num_texture_formats: ^Uint) -> Int
Get_Supported_GL_Texture_Formats_INTEL_Fn :: ^Get_Supported_GL_Texture_Formats_INTEL_T

@(link_prefix="cl")
foreign opencl {
	GetGLContextInfoKHR :: proc  (
                              properties: ^Context_Properties,
                              param_name: GL_Context_Info,
                              param_value_size: c.size_t,
                              param_value: rawptr,
                              param_value_size_ret: ^c.size_t) -> Int ---
	CreateFromGLBuffer :: proc  (
                             _context: Context,
                             flags: Mem_Flags,
                             bufobj: G_Luint,
                             errcode_ret: ^Int) -> Mem ---
	CreateFromGLTexture :: proc  (
                              _context: Context,
                              flags: Mem_Flags,
                              target: G_Lenum,
                              miplevel: G_Lint,
                              texture: G_Luint,
                              errcode_ret: ^Int) -> Mem ---
	CreateFromGLRenderbuffer :: proc  (
                                   _context: Context,
                                   flags: Mem_Flags,
                                   renderbuffer: G_Luint,
                                   errcode_ret: ^Int) -> Mem ---
	GetGLObjectInfo :: proc  (
                          memobj: Mem,
                          gl_object_type: ^GL_Object_Type,
                          gl_object_name: ^G_Luint) -> Int ---
	GetGLTextureInfo :: proc  (
                           memobj: Mem,
                           param_name: GL_Texture_Info,
                           param_value_size: c.size_t,
                           param_value: rawptr,
                           param_value_size_ret: ^c.size_t) -> Int ---
	EnqueueAcquireGLObjects :: proc  (
                                  command_queue: Command_Queue,
                                  num_objects: Uint,
                                  mem_objects: ^Mem,
                                  num_events_in_wait_list: Uint,
                                  event_wait_list: ^Event,
                                  event: ^Event) -> Int ---
	EnqueueReleaseGLObjects :: proc  (
                                  command_queue: Command_Queue,
                                  num_objects: Uint,
                                  mem_objects: ^Mem,
                                  num_events_in_wait_list: Uint,
                                  event_wait_list: ^Event,
                                  event: ^Event) -> Int ---
	CreateFromGLTexture2D :: proc  (
                                _context: Context,
                                flags: Mem_Flags,
                                target: G_Lenum,
                                miplevel: G_Lint,
                                texture: G_Luint,
                                errcode_ret: ^Int) -> Mem ---
	CreateFromGLTexture3D :: proc  (
                                _context: Context,
                                flags: Mem_Flags,
                                target: G_Lenum,
                                miplevel: G_Lint,
                                texture: G_Luint,
                                errcode_ret: ^Int) -> Mem ---
	CreateEventFromGLsyncKHR :: proc  (_context: Context, sync: G_Lsync, errcode_ret: ^Int) -> Event ---
	GetSupportedGLTextureFormatsINTEL :: proc  (
                                            _context: Context,
                                            flags: Mem_Flags,
                                            image_type: Mem_Object_Type,
                                            num_entries: Uint,
                                            gl_formats: ^G_Lenum,
                                            num_texture_formats: ^Uint) -> Int ---
}
