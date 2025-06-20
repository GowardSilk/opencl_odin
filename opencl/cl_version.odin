package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_version.h
* ========================================= */

TARGET_OPENCL_VERSION :: 300
VERSION_3_0 :: 1
VERSION_2_2 :: 1
VERSION_2_1 :: 1
VERSION_2_0 :: 1
VERSION_1_2 :: 1
VERSION_1_1 :: 1
VERSION_1_0 :: 1


