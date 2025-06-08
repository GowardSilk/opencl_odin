package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"


foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_platform.h
* ========================================= */
    cl_char                                                   :: c.int8_t
cl_uchar                                                  :: c.uint8_t
cl_short                                                  :: c.int16_t
cl_ushort                                                 :: c.uint16_t
cl_int                                                    :: c.int32_t
cl_uint                                                   :: c.uint32_t
cl_long                                                   :: c.int64_t
cl_ulong                                                  :: c.uint64_t
cl_half                                                   :: c.uint16_t
cl_float                                                  :: c.float
cl_double                                                 :: c.double
__cl_float4                                               :: #simd[4]c.float
__cl_uchar16                                              :: #simd[4]c.int32_t
__cl_char16                                               :: #simd[4]c.int32_t
__cl_ushort8                                              :: #simd[4]c.int32_t
__cl_short8                                               :: #simd[4]c.int32_t
__cl_uint4                                                :: #simd[4]c.int32_t
__cl_int4                                                 :: #simd[4]c.int32_t
__cl_ulong2                                               :: #simd[4]c.int32_t
__cl_long2                                                :: #simd[4]c.int32_t
__cl_double2                                              :: #simd[2]c.double
__cl_uchar8                                               :: #simd[2]c.int32_t
__cl_char8                                                :: #simd[2]c.int32_t
__cl_ushort4                                              :: #simd[2]c.int32_t
__cl_short4                                               :: #simd[2]c.int32_t
__cl_uint2                                                :: #simd[2]c.int32_t
__cl_int2                                                 :: #simd[2]c.int32_t
__cl_ulong1                                               :: #simd[2]c.int32_t
__cl_long1                                                :: #simd[2]c.int32_t
__cl_float2                                               :: #simd[2]c.int32_t
cl_char2                                                  :: struct #raw_union {
	using _: struct{
		x,y: cl_char,
	},
	using _: struct{
		s0,s1: cl_char,
	},
	using _: struct{
		lo,hi: cl_char,
	},
	s: [2]cl_char,
}
cl_char4                                                  :: struct #raw_union {
	s: [4]cl_char,
	using _: struct{
		x,y,z,w: cl_char,
	},
	using _: struct{
		s0,s1,s2,s3: cl_char,
	},
	using _: struct{
		lo,hi: cl_char2,
	},
}
cl_char3                                                  :: cl_char4
cl_char8                                                  :: struct #raw_union {
	s: [8]cl_char,
	using _: struct{
		x,y,z,w: cl_char,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_char,
	},
	using _: struct{
		lo,hi: cl_char4,
	},
	v8: __cl_char8,
}
cl_char16                                                 :: struct #raw_union {
	s: [16]cl_char,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_char,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_char,
	},
	using _: struct{
		lo,hi: cl_char8,
	},
	v8: [2]__cl_char8,
	v16: __cl_char16,
}
cl_uchar2                                                 :: struct #raw_union {
	s: [2]cl_uchar,
	using _: struct{
		x,y: cl_uchar,
	},
	using _: struct{
		s0,s1: cl_uchar,
	},
	using _: struct{
		lo,hi: cl_uchar,
	},
}
cl_uchar4                                                 :: struct #raw_union {
	s: [4]cl_uchar,
	using _: struct{
		x,y,z,w: cl_uchar,
	},
	using _: struct{
		s0,s1,s2,s3: cl_uchar,
	},
	using _: struct{
		lo,hi: cl_uchar2,
	},
}
cl_uchar3                                                 :: cl_uchar4
cl_uchar8                                                 :: struct #raw_union {
	s: [8]cl_uchar,
	using _: struct{
		x,y,z,w: cl_uchar,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_uchar,
	},
	using _: struct{
		lo,hi: cl_uchar4,
	},
	v8: __cl_uchar8,
}
cl_uchar16                                                :: struct #raw_union {
	s: [16]cl_uchar,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_uchar,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_uchar,
	},
	using _: struct{
		lo,hi: cl_uchar8,
	},
	v8: [2]__cl_uchar8,
	v16: __cl_uchar16,
}
cl_short2                                                 :: struct #raw_union {
	s: [2]cl_short,
	using _: struct{
		x,y: cl_short,
	},
	using _: struct{
		s0,s1: cl_short,
	},
	using _: struct{
		lo,hi: cl_short,
	},
}
cl_short4                                                 :: struct #raw_union {
	s: [4]cl_short,
	using _: struct{
		x,y,z,w: cl_short,
	},
	using _: struct{
		s0,s1,s2,s3: cl_short,
	},
	using _: struct{
		lo,hi: cl_short2,
	},
	v4: __cl_short4,
}
cl_short3                                                 :: cl_short4
cl_short8                                                 :: struct #raw_union {
	s: [8]cl_short,
	using _: struct{
		x,y,z,w: cl_short,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_short,
	},
	using _: struct{
		lo,hi: cl_short4,
	},
	v4: [2]__cl_short4,
	v8: __cl_short8,
}
cl_short16                                                :: struct #raw_union {
	s: [16]cl_short,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_short,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_short,
	},
	using _: struct{
		lo,hi: cl_short8,
	},
	v4: [4]__cl_short4,
	v8: [2]__cl_short8,
}
cl_ushort2                                                :: struct #raw_union {
	s: [2]cl_ushort,
	using _: struct{
		x,y: cl_ushort,
	},
	using _: struct{
		s0,s1: cl_ushort,
	},
	using _: struct{
		lo,hi: cl_ushort,
	},
}
cl_ushort4                                                :: struct #raw_union {
	s: [4]cl_ushort,
	using _: struct{
		x,y,z,w: cl_ushort,
	},
	using _: struct{
		s0,s1,s2,s3: cl_ushort,
	},
	using _: struct{
		lo,hi: cl_ushort2,
	},
	v4: __cl_ushort4,
}
cl_ushort3                                                :: cl_ushort4
cl_ushort8                                                :: struct #raw_union {
	s: [8]cl_ushort,
	using _: struct{
		x,y,z,w: cl_ushort,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_ushort,
	},
	using _: struct{
		lo,hi: cl_ushort4,
	},
	v4: [2]__cl_ushort4,
	v8: __cl_ushort8,
}
cl_ushort16                                               :: struct #raw_union {
	s: [16]cl_ushort,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_ushort,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_ushort,
	},
	using _: struct{
		lo,hi: cl_ushort8,
	},
	v4: [4]__cl_ushort4,
	v8: [2]__cl_ushort8,
}
cl_half2                                                  :: struct #raw_union {
	s: [2]cl_half,
	using _: struct{
		x,y: cl_half,
	},
	using _: struct{
		s0,s1: cl_half,
	},
	using _: struct{
		lo,hi: cl_half,
	},
}
cl_half4                                                  :: struct #raw_union {
	s: [4]cl_half,
	using _: struct{
		x,y,z,w: cl_half,
	},
	using _: struct{
		s0,s1,s2,s3: cl_half,
	},
	using _: struct{
		lo,hi: cl_half2,
	},
}
cl_half3                                                  :: cl_half4
cl_half8                                                  :: struct #raw_union {
	s: [8]cl_half,
	using _: struct{
		x,y,z,w: cl_half,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_half,
	},
	using _: struct{
		lo,hi: cl_half4,
	},
}
cl_half16                                                 :: struct #raw_union {
	s: [16]cl_half,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_half,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_half,
	},
	using _: struct{
		lo,hi: cl_half8,
	},
}
cl_int2                                                   :: struct #raw_union {
	s: [2]cl_int,
	using _: struct{
		x,y: cl_int,
	},
	using _: struct{
		s0,s1: cl_int,
	},
	using _: struct{
		lo,hi: cl_int,
	},
	v2: __cl_int2,
}
cl_int4                                                   :: struct #raw_union {
	s: [4]cl_int,
	using _: struct{
		x,y,z,w: cl_int,
	},
	using _: struct{
		s0,s1,s2,s3: cl_int,
	},
	using _: struct{
		lo,hi: cl_int2,
	},
	v2: [2]__cl_int2,
	v4: __cl_int4,
}
cl_int3                                                   :: cl_int4
cl_int8                                                   :: struct #raw_union {
	s: [8]cl_int,
	using _: struct{
		x,y,z,w: cl_int,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_int,
	},
	using _: struct{
		lo,hi: cl_int4,
	},
	v2: [4]__cl_int2,
	v4: [2]__cl_int4,
}
cl_int16                                                  :: struct #raw_union {
	s: [16]cl_int,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_int,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_int,
	},
	using _: struct{
		lo,hi: cl_int8,
	},
	v2: [8]__cl_int2,
	v4: [4]__cl_int4,
}
cl_uint2                                                  :: struct #raw_union {
	s: [2]cl_uint,
	using _: struct{
		x,y: cl_uint,
	},
	using _: struct{
		s0,s1: cl_uint,
	},
	using _: struct{
		lo,hi: cl_uint,
	},
	v2: __cl_uint2,
}
cl_uint4                                                  :: struct #raw_union {
	s: [4]cl_uint,
	using _: struct{
		x,y,z,w: cl_uint,
	},
	using _: struct{
		s0,s1,s2,s3: cl_uint,
	},
	using _: struct{
		lo,hi: cl_uint2,
	},
	v2: [2]__cl_uint2,
	v4: __cl_uint4,
}
cl_uint3                                                  :: cl_uint4
cl_uint8                                                  :: struct #raw_union {
	s: [8]cl_uint,
	using _: struct{
		x,y,z,w: cl_uint,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_uint,
	},
	using _: struct{
		lo,hi: cl_uint4,
	},
	v2: [4]__cl_uint2,
	v4: [2]__cl_uint4,
}
cl_uint16                                                 :: struct #raw_union {
	s: [16]cl_uint,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_uint,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_uint,
	},
	using _: struct{
		lo,hi: cl_uint8,
	},
	v2: [8]__cl_uint2,
	v4: [4]__cl_uint4,
}
cl_long2                                                  :: struct #raw_union {
	s: [2]cl_long,
	using _: struct{
		x,y: cl_long,
	},
	using _: struct{
		s0,s1: cl_long,
	},
	using _: struct{
		lo,hi: cl_long,
	},
	v2: __cl_long2,
}
cl_long4                                                  :: struct #raw_union {
	s: [4]cl_long,
	using _: struct{
		x,y,z,w: cl_long,
	},
	using _: struct{
		s0,s1,s2,s3: cl_long,
	},
	using _: struct{
		lo,hi: cl_long2,
	},
	v2: [2]__cl_long2,
}
cl_long3                                                  :: cl_long4
cl_long8                                                  :: struct #raw_union {
	s: [8]cl_long,
	using _: struct{
		x,y,z,w: cl_long,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_long,
	},
	using _: struct{
		lo,hi: cl_long4,
	},
	v2: [4]__cl_long2,
}
cl_long16                                                 :: struct #raw_union {
	s: [16]cl_long,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_long,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_long,
	},
	using _: struct{
		lo,hi: cl_long8,
	},
	v2: [8]__cl_long2,
}
cl_ulong2                                                 :: struct #raw_union {
	s: [2]cl_ulong,
	using _: struct{
		x,y: cl_ulong,
	},
	using _: struct{
		s0,s1: cl_ulong,
	},
	using _: struct{
		lo,hi: cl_ulong,
	},
	v2: __cl_ulong2,
}
cl_ulong4                                                 :: struct #raw_union {
	s: [4]cl_ulong,
	using _: struct{
		x,y,z,w: cl_ulong,
	},
	using _: struct{
		s0,s1,s2,s3: cl_ulong,
	},
	using _: struct{
		lo,hi: cl_ulong2,
	},
	v2: [2]__cl_ulong2,
}
cl_ulong3                                                 :: cl_ulong4
cl_ulong8                                                 :: struct #raw_union {
	s: [8]cl_ulong,
	using _: struct{
		x,y,z,w: cl_ulong,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_ulong,
	},
	using _: struct{
		lo,hi: cl_ulong4,
	},
	v2: [4]__cl_ulong2,
}
cl_ulong16                                                :: struct #raw_union {
	s: [16]cl_ulong,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_ulong,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_ulong,
	},
	using _: struct{
		lo,hi: cl_ulong8,
	},
	v2: [8]__cl_ulong2,
}
cl_float2                                                 :: struct #raw_union {
	s: [2]cl_float,
	using _: struct{
		x,y: cl_float,
	},
	using _: struct{
		s0,s1: cl_float,
	},
	using _: struct{
		lo,hi: cl_float,
	},
	v2: __cl_float2,
}
cl_float4                                                 :: struct #raw_union {
	s: [4]cl_float,
	using _: struct{
		x,y,z,w: cl_float,
	},
	using _: struct{
		s0,s1,s2,s3: cl_float,
	},
	using _: struct{
		lo,hi: cl_float2,
	},
	v2: [2]__cl_float2,
	v4: __cl_float4,
}
cl_float3                                                 :: cl_float4
cl_float8                                                 :: struct #raw_union {
	s: [8]cl_float,
	using _: struct{
		x,y,z,w: cl_float,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_float,
	},
	using _: struct{
		lo,hi: cl_float4,
	},
	v2: [4]__cl_float2,
	v4: [2]__cl_float4,
}
cl_float16                                                :: struct #raw_union {
	s: [16]cl_float,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_float,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_float,
	},
	using _: struct{
		lo,hi: cl_float8,
	},
	v2: [8]__cl_float2,
	v4: [4]__cl_float4,
}
cl_double2                                                :: struct #raw_union {
	s: [2]cl_double,
	using _: struct{
		x,y: cl_double,
	},
	using _: struct{
		s0,s1: cl_double,
	},
	using _: struct{
		lo,hi: cl_double,
	},
	v2: __cl_double2,
}
cl_double4                                                :: struct #raw_union {
	s: [4]cl_double,
	using _: struct{
		x,y,z,w: cl_double,
	},
	using _: struct{
		s0,s1,s2,s3: cl_double,
	},
	using _: struct{
		lo,hi: cl_double2,
	},
	v2: [2]__cl_double2,
}
cl_double3                                                :: cl_double4
cl_double8                                                :: struct #raw_union {
	s: [8]cl_double,
	using _: struct{
		x,y,z,w: cl_double,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: cl_double,
	},
	using _: struct{
		lo,hi: cl_double4,
	},
	v2: [4]__cl_double2,
}
cl_double16                                               :: struct #raw_union {
	s: [16]cl_double,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: cl_double,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: cl_double,
	},
	using _: struct{
		lo,hi: cl_double8,
	},
	v2: [8]__cl_double2,
}
foreign opencl {
}

        /* =========================================
        *               cl.h
        * ========================================= */
            cl_platform_id                                            :: distinct rawptr
cl_device_id                                              :: distinct rawptr
cl_context                                                :: distinct rawptr
cl_command_queue                                          :: distinct rawptr
cl_mem                                                    :: distinct rawptr
cl_program                                                :: distinct rawptr
cl_kernel                                                 :: distinct rawptr
cl_event                                                  :: distinct rawptr
cl_sampler                                                :: distinct rawptr
cl_bool                                                   :: cl_uint
cl_bitfield                                               :: cl_ulong
cl_properties                                             :: cl_ulong
cl_device_type                                            :: cl_bitfield
cl_platform_info                                          :: cl_uint
cl_device_info                                            :: cl_uint
cl_device_fp_config                                       :: cl_bitfield
cl_device_mem_cache_type                                  :: cl_uint
cl_device_local_mem_type                                  :: cl_uint
cl_device_exec_capabilities                               :: cl_bitfield
cl_device_svm_capabilities                                :: cl_bitfield
cl_command_queue_properties                               :: cl_bitfield
cl_device_partition_property                              :: c.intptr_t
cl_device_affinity_domain                                 :: cl_bitfield
cl_context_properties                                     :: c.intptr_t
cl_context_info                                           :: cl_uint
cl_queue_properties                                       :: cl_properties
cl_command_queue_info                                     :: cl_uint
cl_channel_order                                          :: cl_uint
cl_channel_type                                           :: cl_uint
cl_mem_flags                                              :: cl_bitfield
cl_svm_mem_flags                                          :: cl_bitfield
cl_mem_object_type                                        :: cl_uint
cl_mem_info                                               :: cl_uint
cl_mem_migration_flags                                    :: cl_bitfield
cl_image_info                                             :: cl_uint
cl_buffer_create_type                                     :: cl_uint
cl_addressing_mode                                        :: cl_uint
cl_filter_mode                                            :: cl_uint
cl_sampler_info                                           :: cl_uint
cl_map_flags                                              :: cl_bitfield
cl_pipe_properties                                        :: c.intptr_t
cl_pipe_info                                              :: cl_uint
cl_program_info                                           :: cl_uint
cl_program_build_info                                     :: cl_uint
cl_program_binary_type                                    :: cl_uint
cl_build_status                                           :: cl_int
cl_kernel_info                                            :: cl_uint
cl_kernel_arg_info                                        :: cl_uint
cl_kernel_arg_address_qualifier                           :: cl_uint
cl_kernel_arg_access_qualifier                            :: cl_uint
cl_kernel_arg_type_qualifier                              :: cl_bitfield
cl_kernel_work_group_info                                 :: cl_uint
cl_kernel_sub_group_info                                  :: cl_uint
cl_event_info                                             :: cl_uint
cl_command_type                                           :: cl_uint
cl_profiling_info                                         :: cl_uint
cl_sampler_properties                                     :: cl_properties
cl_kernel_exec_info                                       :: cl_uint
cl_device_atomic_capabilities                             :: cl_bitfield
cl_device_device_enqueue_capabilities                     :: cl_bitfield
cl_khronos_vendor_id                                      :: cl_uint
cl_mem_properties                                         :: cl_properties
cl_version                                                :: cl_uint
cl_image_format                                           :: struct{
	image_channel_order: cl_channel_order,
	image_channel_data_type: cl_channel_type,
}
cl_image_desc                                             :: struct{
	image_type: cl_mem_object_type,
	image_width: c.size_t,
	image_height: c.size_t,
	image_depth: c.size_t,
	image_array_size: c.size_t,
	image_row_pitch: c.size_t,
	image_slice_pitch: c.size_t,
	num_mip_levels: cl_uint,
	num_samples: cl_uint,
	using _: struct #raw_union {
		buffer: cl_mem,
		mem_object: cl_mem,
	},
}
cl_buffer_region                                          :: struct{
	origin: c.size_t,
	size: c.size_t,
}
cl_name_version                                           :: struct{
	version: cl_version,
	name: [64]c.schar,
}
foreign opencl {
	clGetPlatformIDs :: proc "stdcall" (
                                    num_entries: cl_uint,
                                    platforms: cl_platform_id,
                                    num_platforms: cl_uint) -> cl_int ---
	clGetPlatformInfo :: proc "stdcall" (
                                     platform: cl_platform_id,
                                     param_name: cl_platform_info,
                                     param_value_size: c.size_t,
                                     param_value: rawptr,
                                     param_value_size_ret: c.size_t) -> cl_int ---
	clGetDeviceIDs :: proc "stdcall" (
                                  platform: cl_platform_id,
                                  device_type: cl_device_type,
                                  num_entries: cl_uint,
                                  devices: cl_device_id,
                                  num_devices: cl_uint) -> cl_int ---
	clGetDeviceInfo :: proc "stdcall" (
                                   device: cl_device_id,
                                   param_name: cl_device_info,
                                   param_value_size: c.size_t,
                                   param_value: rawptr,
                                   param_value_size_ret: c.size_t) -> cl_int ---
	clCreateSubDevices :: proc "stdcall" (
                                      in_device: cl_device_id,
                                      properties: cl_device_partition_property,
                                      num_devices: cl_uint,
                                      out_devices: cl_device_id,
                                      num_devices_ret: cl_uint) -> cl_int ---
	clRetainDevice :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clReleaseDevice :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clSetDefaultDeviceCommandQueue :: proc "stdcall" (
                                                  _context: cl_context,
                                                  device: cl_device_id,
                                                  command_queue: cl_command_queue) -> cl_int ---
	clGetDeviceAndHostTimer :: proc "stdcall" (
                                           device: cl_device_id,
                                           device_timestamp: cl_ulong,
                                           host_timestamp: cl_ulong) -> cl_int ---
	clGetHostTimer :: proc "stdcall" (device: cl_device_id, host_timestamp: cl_ulong) -> cl_int ---
	clCreateContext :: proc "stdcall" (
                                   properties: cl_context_properties,
                                   num_devices: cl_uint,
                                   devices: cl_device_id,
                                   pfn_notify: #type proc "stdcall" (errinfo: c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr),
                                   user_data: rawptr,
                                   errcode_ret: cl_int) -> cl_context ---
	clCreateContextFromType :: proc "stdcall" (
                                           properties: cl_context_properties,
                                           device_type: cl_device_type,
                                           pfn_notify: #type proc "stdcall" (errinfo: c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr),
                                           user_data: rawptr,
                                           errcode_ret: cl_int) -> cl_context ---
	clRetainContext :: proc "stdcall" (_context: cl_context) -> cl_int ---
	clReleaseContext :: proc "stdcall" (_context: cl_context) -> cl_int ---
	clGetContextInfo :: proc "stdcall" (
                                    _context: cl_context,
                                    param_name: cl_context_info,
                                    param_value_size: c.size_t,
                                    param_value: rawptr,
                                    param_value_size_ret: c.size_t) -> cl_int ---
	clSetContextDestructorCallback :: proc "stdcall" (
                                                  _context: cl_context,
                                                  pfn_notify: #type proc "stdcall" (_context: cl_context, user_data: rawptr),
                                                  user_data: rawptr) -> cl_int ---
	clCreateCommandQueueWithProperties :: proc "stdcall" (
                                                      _context: cl_context,
                                                      device: cl_device_id,
                                                      properties: cl_queue_properties,
                                                      errcode_ret: cl_int) -> cl_command_queue ---
	clRetainCommandQueue :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clReleaseCommandQueue :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clGetCommandQueueInfo :: proc "stdcall" (
                                         command_queue: cl_command_queue,
                                         param_name: cl_command_queue_info,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: c.size_t) -> cl_int ---
	clCreateBuffer :: proc "stdcall" (
                                  _context: cl_context,
                                  flags: cl_mem_flags,
                                  size: c.size_t,
                                  host_ptr: rawptr,
                                  errcode_ret: cl_int) -> cl_mem ---
	clCreateSubBuffer :: proc "stdcall" (
                                     buffer: cl_mem,
                                     flags: cl_mem_flags,
                                     buffer_create_type: cl_buffer_create_type,
                                     buffer_create_info: rawptr,
                                     errcode_ret: cl_int) -> cl_mem ---
	clCreateImage :: proc "stdcall" (
                                 _context: cl_context,
                                 flags: cl_mem_flags,
                                 image_format: cl_image_format,
                                 image_desc: cl_image_desc,
                                 host_ptr: rawptr,
                                 errcode_ret: cl_int) -> cl_mem ---
	clCreatePipe :: proc "stdcall" (
                                _context: cl_context,
                                flags: cl_mem_flags,
                                pipe_packet_size: cl_uint,
                                pipe_max_packets: cl_uint,
                                properties: cl_pipe_properties,
                                errcode_ret: cl_int) -> cl_mem ---
	clCreateBufferWithProperties :: proc "stdcall" (
                                                _context: cl_context,
                                                properties: cl_mem_properties,
                                                flags: cl_mem_flags,
                                                size: c.size_t,
                                                host_ptr: rawptr,
                                                errcode_ret: cl_int) -> cl_mem ---
	clCreateImageWithProperties :: proc "stdcall" (
                                               _context: cl_context,
                                               properties: cl_mem_properties,
                                               flags: cl_mem_flags,
                                               image_format: cl_image_format,
                                               image_desc: cl_image_desc,
                                               host_ptr: rawptr,
                                               errcode_ret: cl_int) -> cl_mem ---
	clRetainMemObject :: proc "stdcall" (memobj: cl_mem) -> cl_int ---
	clReleaseMemObject :: proc "stdcall" (memobj: cl_mem) -> cl_int ---
	clGetSupportedImageFormats :: proc "stdcall" (
                                              _context: cl_context,
                                              flags: cl_mem_flags,
                                              image_type: cl_mem_object_type,
                                              num_entries: cl_uint,
                                              image_formats: cl_image_format,
                                              num_image_formats: cl_uint) -> cl_int ---
	clGetMemObjectInfo :: proc "stdcall" (
                                      memobj: cl_mem,
                                      param_name: cl_mem_info,
                                      param_value_size: c.size_t,
                                      param_value: rawptr,
                                      param_value_size_ret: c.size_t) -> cl_int ---
	clGetImageInfo :: proc "stdcall" (
                                  image: cl_mem,
                                  param_name: cl_image_info,
                                  param_value_size: c.size_t,
                                  param_value: rawptr,
                                  param_value_size_ret: c.size_t) -> cl_int ---
	clGetPipeInfo :: proc "stdcall" (
                                 pipe: cl_mem,
                                 param_name: cl_pipe_info,
                                 param_value_size: c.size_t,
                                 param_value: rawptr,
                                 param_value_size_ret: c.size_t) -> cl_int ---
	clSetMemObjectDestructorCallback :: proc "stdcall" (
                                                    memobj: cl_mem,
                                                    pfn_notify: #type proc "stdcall" (memobj: cl_mem, user_data: rawptr),
                                                    user_data: rawptr) -> cl_int ---
	clSVMAlloc :: proc "stdcall" (
                              _context: cl_context,
                              flags: cl_svm_mem_flags,
                              size: c.size_t,
                              alignment: cl_uint) -> rawptr ---
	clSVMFree :: proc "stdcall" (_context: cl_context, svm_pointer: rawptr) ---
	clCreateSamplerWithProperties :: proc "stdcall" (
                                                 _context: cl_context,
                                                 sampler_properties: cl_sampler_properties,
                                                 errcode_ret: cl_int) -> cl_sampler ---
	clRetainSampler :: proc "stdcall" (sampler: cl_sampler) -> cl_int ---
	clReleaseSampler :: proc "stdcall" (sampler: cl_sampler) -> cl_int ---
	clGetSamplerInfo :: proc "stdcall" (
                                    sampler: cl_sampler,
                                    param_name: cl_sampler_info,
                                    param_value_size: c.size_t,
                                    param_value: rawptr,
                                    param_value_size_ret: c.size_t) -> cl_int ---
	clCreateProgramWithSource :: proc "stdcall" (
                                             _context: cl_context,
                                             count: cl_uint,
                                             strings: ^c.schar,
                                             lengths: c.size_t,
                                             errcode_ret: cl_int) -> cl_program ---
	clCreateProgramWithBinary :: proc "stdcall" (
                                             _context: cl_context,
                                             num_devices: cl_uint,
                                             device_list: cl_device_id,
                                             lengths: c.size_t,
                                             binaries: ^c.char,
                                             binary_status: cl_int,
                                             errcode_ret: cl_int) -> cl_program ---
	clCreateProgramWithBuiltInKernels :: proc "stdcall" (
                                                     _context: cl_context,
                                                     num_devices: cl_uint,
                                                     device_list: cl_device_id,
                                                     kernel_names: c.schar,
                                                     errcode_ret: cl_int) -> cl_program ---
	clCreateProgramWithIL :: proc "stdcall" (
                                         _context: cl_context,
                                         il: rawptr,
                                         length: c.size_t,
                                         errcode_ret: cl_int) -> cl_program ---
	clRetainProgram :: proc "stdcall" (program: cl_program) -> cl_int ---
	clReleaseProgram :: proc "stdcall" (program: cl_program) -> cl_int ---
	clBuildProgram :: proc "stdcall" (
                                  program: cl_program,
                                  num_devices: cl_uint,
                                  device_list: cl_device_id,
                                  options: c.schar,
                                  pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr),
                                  user_data: rawptr) -> cl_int ---
	clCompileProgram :: proc "stdcall" (
                                    program: cl_program,
                                    num_devices: cl_uint,
                                    device_list: cl_device_id,
                                    options: c.schar,
                                    num_input_headers: cl_uint,
                                    input_headers: cl_program,
                                    header_include_names: ^c.schar,
                                    pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr),
                                    user_data: rawptr) -> cl_int ---
	clLinkProgram :: proc "stdcall" (
                                 _context: cl_context,
                                 num_devices: cl_uint,
                                 device_list: cl_device_id,
                                 options: c.schar,
                                 num_input_programs: cl_uint,
                                 input_programs: cl_program,
                                 pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr),
                                 user_data: rawptr,
                                 errcode_ret: cl_int) -> cl_program ---
	clSetProgramReleaseCallback :: proc "stdcall" (
                                               program: cl_program,
                                               pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr),
                                               user_data: rawptr) -> cl_int ---
	clSetProgramSpecializationConstant :: proc "stdcall" (
                                                      program: cl_program,
                                                      spec_id: cl_uint,
                                                      spec_size: c.size_t,
                                                      spec_value: rawptr) -> cl_int ---
	clUnloadPlatformCompiler :: proc "stdcall" (platform: cl_platform_id) -> cl_int ---
	clGetProgramInfo :: proc "stdcall" (
                                    program: cl_program,
                                    param_name: cl_program_info,
                                    param_value_size: c.size_t,
                                    param_value: rawptr,
                                    param_value_size_ret: c.size_t) -> cl_int ---
	clGetProgramBuildInfo :: proc "stdcall" (
                                         program: cl_program,
                                         device: cl_device_id,
                                         param_name: cl_program_build_info,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: c.size_t) -> cl_int ---
	clCreateKernel :: proc "stdcall" (
                                  program: cl_program,
                                  kernel_name: c.schar,
                                  errcode_ret: cl_int) -> cl_kernel ---
	clCreateKernelsInProgram :: proc "stdcall" (
                                            program: cl_program,
                                            num_kernels: cl_uint,
                                            kernels: cl_kernel,
                                            num_kernels_ret: cl_uint) -> cl_int ---
	clCloneKernel :: proc "stdcall" (source_kernel: cl_kernel, errcode_ret: cl_int) -> cl_kernel ---
	clRetainKernel :: proc "stdcall" (kernel: cl_kernel) -> cl_int ---
	clReleaseKernel :: proc "stdcall" (kernel: cl_kernel) -> cl_int ---
	clSetKernelArg :: proc "stdcall" (
                                  kernel: cl_kernel,
                                  arg_index: cl_uint,
                                  arg_size: c.size_t,
                                  arg_value: rawptr) -> cl_int ---
	clSetKernelArgSVMPointer :: proc "stdcall" (
                                            kernel: cl_kernel,
                                            arg_index: cl_uint,
                                            arg_value: rawptr) -> cl_int ---
	clSetKernelExecInfo :: proc "stdcall" (
                                       kernel: cl_kernel,
                                       param_name: cl_kernel_exec_info,
                                       param_value_size: c.size_t,
                                       param_value: rawptr) -> cl_int ---
	clGetKernelInfo :: proc "stdcall" (
                                   kernel: cl_kernel,
                                   param_name: cl_kernel_info,
                                   param_value_size: c.size_t,
                                   param_value: rawptr,
                                   param_value_size_ret: c.size_t) -> cl_int ---
	clGetKernelArgInfo :: proc "stdcall" (
                                      kernel: cl_kernel,
                                      arg_indx: cl_uint,
                                      param_name: cl_kernel_arg_info,
                                      param_value_size: c.size_t,
                                      param_value: rawptr,
                                      param_value_size_ret: c.size_t) -> cl_int ---
	clGetKernelWorkGroupInfo :: proc "stdcall" (
                                            kernel: cl_kernel,
                                            device: cl_device_id,
                                            param_name: cl_kernel_work_group_info,
                                            param_value_size: c.size_t,
                                            param_value: rawptr,
                                            param_value_size_ret: c.size_t) -> cl_int ---
	clGetKernelSubGroupInfo :: proc "stdcall" (
                                           kernel: cl_kernel,
                                           device: cl_device_id,
                                           param_name: cl_kernel_sub_group_info,
                                           input_value_size: c.size_t,
                                           input_value: rawptr,
                                           param_value_size: c.size_t,
                                           param_value: rawptr,
                                           param_value_size_ret: c.size_t) -> cl_int ---
	clWaitForEvents :: proc "stdcall" (num_events: cl_uint, event_list: cl_event) -> cl_int ---
	clGetEventInfo :: proc "stdcall" (
                                  event: cl_event,
                                  param_name: cl_event_info,
                                  param_value_size: c.size_t,
                                  param_value: rawptr,
                                  param_value_size_ret: c.size_t) -> cl_int ---
	clCreateUserEvent :: proc "stdcall" (_context: cl_context, errcode_ret: cl_int) -> cl_event ---
	clRetainEvent :: proc "stdcall" (event: cl_event) -> cl_int ---
	clReleaseEvent :: proc "stdcall" (event: cl_event) -> cl_int ---
	clSetUserEventStatus :: proc "stdcall" (event: cl_event, execution_status: cl_int) -> cl_int ---
	clSetEventCallback :: proc "stdcall" (
                                      event: cl_event,
                                      command_exec_callback_type: cl_int,
                                      pfn_notify: #type proc "stdcall" (event: cl_event, event_command_status: cl_int, user_data: rawptr),
                                      user_data: rawptr) -> cl_int ---
	clGetEventProfilingInfo :: proc "stdcall" (
                                           event: cl_event,
                                           param_name: cl_profiling_info,
                                           param_value_size: c.size_t,
                                           param_value: rawptr,
                                           param_value_size_ret: c.size_t) -> cl_int ---
	clFlush :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clFinish :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clEnqueueReadBuffer :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       buffer: cl_mem,
                                       blocking_read: cl_bool,
                                       offset: c.size_t,
                                       size: c.size_t,
                                       ptr: rawptr,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: cl_event,
                                       event: cl_event) -> cl_int ---
	clEnqueueReadBufferRect :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           buffer: cl_mem,
                                           blocking_read: cl_bool,
                                           buffer_origin: c.size_t,
                                           host_origin: c.size_t,
                                           region: c.size_t,
                                           buffer_row_pitch: c.size_t,
                                           buffer_slice_pitch: c.size_t,
                                           host_row_pitch: c.size_t,
                                           host_slice_pitch: c.size_t,
                                           ptr: rawptr,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: cl_event,
                                           event: cl_event) -> cl_int ---
	clEnqueueWriteBuffer :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        buffer: cl_mem,
                                        blocking_write: cl_bool,
                                        offset: c.size_t,
                                        size: c.size_t,
                                        ptr: rawptr,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: cl_event,
                                        event: cl_event) -> cl_int ---
	clEnqueueWriteBufferRect :: proc "stdcall" (
                                            command_queue: cl_command_queue,
                                            buffer: cl_mem,
                                            blocking_write: cl_bool,
                                            buffer_origin: c.size_t,
                                            host_origin: c.size_t,
                                            region: c.size_t,
                                            buffer_row_pitch: c.size_t,
                                            buffer_slice_pitch: c.size_t,
                                            host_row_pitch: c.size_t,
                                            host_slice_pitch: c.size_t,
                                            ptr: rawptr,
                                            num_events_in_wait_list: cl_uint,
                                            event_wait_list: cl_event,
                                            event: cl_event) -> cl_int ---
	clEnqueueFillBuffer :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       buffer: cl_mem,
                                       pattern: rawptr,
                                       pattern_size: c.size_t,
                                       offset: c.size_t,
                                       size: c.size_t,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: cl_event,
                                       event: cl_event) -> cl_int ---
	clEnqueueCopyBuffer :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       src_buffer: cl_mem,
                                       dst_buffer: cl_mem,
                                       src_offset: c.size_t,
                                       dst_offset: c.size_t,
                                       size: c.size_t,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: cl_event,
                                       event: cl_event) -> cl_int ---
	clEnqueueCopyBufferRect :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           src_buffer: cl_mem,
                                           dst_buffer: cl_mem,
                                           src_origin: c.size_t,
                                           dst_origin: c.size_t,
                                           region: c.size_t,
                                           src_row_pitch: c.size_t,
                                           src_slice_pitch: c.size_t,
                                           dst_row_pitch: c.size_t,
                                           dst_slice_pitch: c.size_t,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: cl_event,
                                           event: cl_event) -> cl_int ---
	clEnqueueReadImage :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      image: cl_mem,
                                      blocking_read: cl_bool,
                                      origin: c.size_t,
                                      region: c.size_t,
                                      row_pitch: c.size_t,
                                      slice_pitch: c.size_t,
                                      ptr: rawptr,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: cl_event,
                                      event: cl_event) -> cl_int ---
	clEnqueueWriteImage :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       image: cl_mem,
                                       blocking_write: cl_bool,
                                       origin: c.size_t,
                                       region: c.size_t,
                                       input_row_pitch: c.size_t,
                                       input_slice_pitch: c.size_t,
                                       ptr: rawptr,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: cl_event,
                                       event: cl_event) -> cl_int ---
	clEnqueueFillImage :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      image: cl_mem,
                                      fill_color: rawptr,
                                      origin: c.size_t,
                                      region: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: cl_event,
                                      event: cl_event) -> cl_int ---
	clEnqueueCopyImage :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      src_image: cl_mem,
                                      dst_image: cl_mem,
                                      src_origin: c.size_t,
                                      dst_origin: c.size_t,
                                      region: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: cl_event,
                                      event: cl_event) -> cl_int ---
	clEnqueueCopyImageToBuffer :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              src_image: cl_mem,
                                              dst_buffer: cl_mem,
                                              src_origin: c.size_t,
                                              region: c.size_t,
                                              dst_offset: c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: cl_event,
                                              event: cl_event) -> cl_int ---
	clEnqueueCopyBufferToImage :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              src_buffer: cl_mem,
                                              dst_image: cl_mem,
                                              src_offset: c.size_t,
                                              dst_origin: c.size_t,
                                              region: c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: cl_event,
                                              event: cl_event) -> cl_int ---
	clEnqueueMapBuffer :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      buffer: cl_mem,
                                      blocking_map: cl_bool,
                                      map_flags: cl_map_flags,
                                      offset: c.size_t,
                                      size: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: cl_event,
                                      event: cl_event,
                                      errcode_ret: cl_int) -> rawptr ---
	clEnqueueMapImage :: proc "stdcall" (
                                     command_queue: cl_command_queue,
                                     image: cl_mem,
                                     blocking_map: cl_bool,
                                     map_flags: cl_map_flags,
                                     origin: c.size_t,
                                     region: c.size_t,
                                     image_row_pitch: c.size_t,
                                     image_slice_pitch: c.size_t,
                                     num_events_in_wait_list: cl_uint,
                                     event_wait_list: cl_event,
                                     event: cl_event,
                                     errcode_ret: cl_int) -> rawptr ---
	clEnqueueUnmapMemObject :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           memobj: cl_mem,
                                           mapped_ptr: rawptr,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: cl_event,
                                           event: cl_event) -> cl_int ---
	clEnqueueMigrateMemObjects :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              num_mem_objects: cl_uint,
                                              mem_objects: cl_mem,
                                              flags: cl_mem_migration_flags,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: cl_event,
                                              event: cl_event) -> cl_int ---
	clEnqueueNDRangeKernel :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          kernel: cl_kernel,
                                          work_dim: cl_uint,
                                          global_work_offset: c.size_t,
                                          global_work_size: c.size_t,
                                          local_work_size: c.size_t,
                                          num_events_in_wait_list: cl_uint,
                                          event_wait_list: cl_event,
                                          event: cl_event) -> cl_int ---
	clEnqueueNativeKernel :: proc "stdcall" (
                                         command_queue: cl_command_queue,
                                         user_func: #type proc "stdcall" (_1: rawptr),
                                         args: rawptr,
                                         cb_args: c.size_t,
                                         num_mem_objects: cl_uint,
                                         mem_list: cl_mem,
                                         args_mem_loc: ^rawptr,
                                         num_events_in_wait_list: cl_uint,
                                         event_wait_list: cl_event,
                                         event: cl_event) -> cl_int ---
	clEnqueueMarkerWithWaitList :: proc "stdcall" (
                                               command_queue: cl_command_queue,
                                               num_events_in_wait_list: cl_uint,
                                               event_wait_list: cl_event,
                                               event: cl_event) -> cl_int ---
	clEnqueueBarrierWithWaitList :: proc "stdcall" (
                                                command_queue: cl_command_queue,
                                                num_events_in_wait_list: cl_uint,
                                                event_wait_list: cl_event,
                                                event: cl_event) -> cl_int ---
	clEnqueueSVMFree :: proc "stdcall" (
                                    command_queue: cl_command_queue,
                                    num_svm_pointers: cl_uint,
                                    svm_pointers: []rawptr,
                                    pfn_free_func: #type proc "stdcall" (queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, user_data: rawptr),
                                    user_data: rawptr,
                                    num_events_in_wait_list: cl_uint,
                                    event_wait_list: cl_event,
                                    event: cl_event) -> cl_int ---
	clEnqueueSVMMemcpy :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      blocking_copy: cl_bool,
                                      dst_ptr: rawptr,
                                      src_ptr: rawptr,
                                      size: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: cl_event,
                                      event: cl_event) -> cl_int ---
	clEnqueueSVMMemFill :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       svm_ptr: rawptr,
                                       pattern: rawptr,
                                       pattern_size: c.size_t,
                                       size: c.size_t,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: cl_event,
                                       event: cl_event) -> cl_int ---
	clEnqueueSVMMap :: proc "stdcall" (
                                   command_queue: cl_command_queue,
                                   blocking_map: cl_bool,
                                   flags: cl_map_flags,
                                   svm_ptr: rawptr,
                                   size: c.size_t,
                                   num_events_in_wait_list: cl_uint,
                                   event_wait_list: cl_event,
                                   event: cl_event) -> cl_int ---
	clEnqueueSVMUnmap :: proc "stdcall" (
                                     command_queue: cl_command_queue,
                                     svm_ptr: rawptr,
                                     num_events_in_wait_list: cl_uint,
                                     event_wait_list: cl_event,
                                     event: cl_event) -> cl_int ---
	clEnqueueSVMMigrateMem :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          num_svm_pointers: cl_uint,
                                          svm_pointers: ^rawptr,
                                          sizes: c.size_t,
                                          flags: cl_mem_migration_flags,
                                          num_events_in_wait_list: cl_uint,
                                          event_wait_list: cl_event,
                                          event: cl_event) -> cl_int ---
	clGetExtensionFunctionAddressForPlatform :: proc "stdcall" (
                                                            platform: cl_platform_id,
                                                            func_name: c.schar) -> rawptr ---
	clCreateImage2D :: proc "stdcall" (
                                   _context: cl_context,
                                   flags: cl_mem_flags,
                                   image_format: cl_image_format,
                                   image_width: c.size_t,
                                   image_height: c.size_t,
                                   image_row_pitch: c.size_t,
                                   host_ptr: rawptr,
                                   errcode_ret: cl_int) -> cl_mem ---
	clCreateImage3D :: proc "stdcall" (
                                   _context: cl_context,
                                   flags: cl_mem_flags,
                                   image_format: cl_image_format,
                                   image_width: c.size_t,
                                   image_height: c.size_t,
                                   image_depth: c.size_t,
                                   image_row_pitch: c.size_t,
                                   image_slice_pitch: c.size_t,
                                   host_ptr: rawptr,
                                   errcode_ret: cl_int) -> cl_mem ---
	clEnqueueMarker :: proc "stdcall" (command_queue: cl_command_queue, event: cl_event) -> cl_int ---
	clEnqueueWaitForEvents :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          num_events: cl_uint,
                                          event_list: cl_event) -> cl_int ---
	clEnqueueBarrier :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clUnloadCompiler :: proc "stdcall" () -> cl_int ---
	clGetExtensionFunctionAddress :: proc "stdcall" (func_name: c.schar) -> rawptr ---
	clCreateCommandQueue :: proc "stdcall" (
                                        _context: cl_context,
                                        device: cl_device_id,
                                        properties: cl_command_queue_properties,
                                        errcode_ret: cl_int) -> cl_command_queue ---
	clCreateSampler :: proc "stdcall" (
                                   _context: cl_context,
                                   normalized_coords: cl_bool,
                                   addressing_mode: cl_addressing_mode,
                                   filter_mode: cl_filter_mode,
                                   errcode_ret: cl_int) -> cl_sampler ---
	clEnqueueTask :: proc "stdcall" (
                                 command_queue: cl_command_queue,
                                 kernel: cl_kernel,
                                 num_events_in_wait_list: cl_uint,
                                 event_wait_list: cl_event,
                                 event: cl_event) -> cl_int ---
}

        /* =========================================
        *               cl_function_types.h
        * ========================================= */
            clGetPlatformIDs_t                                        :: #type proc "stdcall" (num_entries: cl_uint, platforms: cl_platform_id, num_platforms: cl_uint) -> cl_int
clGetPlatformIDs_fn                                       :: clGetPlatformIDs_t
clGetPlatformInfo_t                                       :: #type proc "stdcall" (platform: cl_platform_id, param_name: cl_platform_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetPlatformInfo_fn                                      :: clGetPlatformInfo_t
clGetDeviceIDs_t                                          :: #type proc "stdcall" (platform: cl_platform_id, device_type: cl_device_type, num_entries: cl_uint, devices: cl_device_id, num_devices: cl_uint) -> cl_int
clGetDeviceIDs_fn                                         :: clGetDeviceIDs_t
clGetDeviceInfo_t                                         :: #type proc "stdcall" (device: cl_device_id, param_name: cl_device_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetDeviceInfo_fn                                        :: clGetDeviceInfo_t
clCreateContext_t                                         :: #type proc "stdcall" (properties: cl_context_properties, num_devices: cl_uint, devices: cl_device_id, pfn_notify: #type proc "stdcall" (errinfo: c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: cl_int) -> cl_context
clCreateContext_fn                                        :: clCreateContext_t
clCreateContextFromType_t                                 :: #type proc "stdcall" (properties: cl_context_properties, device_type: cl_device_type, pfn_notify: #type proc "stdcall" (errinfo: c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: cl_int) -> cl_context
clCreateContextFromType_fn                                :: clCreateContextFromType_t
clRetainContext_t                                         :: #type proc "stdcall" (_context: cl_context) -> cl_int
clRetainContext_fn                                        :: clRetainContext_t
clReleaseContext_t                                        :: #type proc "stdcall" (_context: cl_context) -> cl_int
clReleaseContext_fn                                       :: clReleaseContext_t
clGetContextInfo_t                                        :: #type proc "stdcall" (_context: cl_context, param_name: cl_context_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetContextInfo_fn                                       :: clGetContextInfo_t
clRetainCommandQueue_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clRetainCommandQueue_fn                                   :: clRetainCommandQueue_t
clReleaseCommandQueue_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clReleaseCommandQueue_fn                                  :: clReleaseCommandQueue_t
clGetCommandQueueInfo_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, param_name: cl_command_queue_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetCommandQueueInfo_fn                                  :: clGetCommandQueueInfo_t
clCreateBuffer_t                                          :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, size: c.size_t, host_ptr: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateBuffer_fn                                         :: clCreateBuffer_t
clRetainMemObject_t                                       :: #type proc "stdcall" (memobj: cl_mem) -> cl_int
clRetainMemObject_fn                                      :: clRetainMemObject_t
clReleaseMemObject_t                                      :: #type proc "stdcall" (memobj: cl_mem) -> cl_int
clReleaseMemObject_fn                                     :: clReleaseMemObject_t
clGetSupportedImageFormats_t                              :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_type: cl_mem_object_type, num_entries: cl_uint, image_formats: cl_image_format, num_image_formats: cl_uint) -> cl_int
clGetSupportedImageFormats_fn                             :: clGetSupportedImageFormats_t
clGetMemObjectInfo_t                                      :: #type proc "stdcall" (memobj: cl_mem, param_name: cl_mem_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetMemObjectInfo_fn                                     :: clGetMemObjectInfo_t
clGetImageInfo_t                                          :: #type proc "stdcall" (image: cl_mem, param_name: cl_image_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetImageInfo_fn                                         :: clGetImageInfo_t
clRetainSampler_t                                         :: #type proc "stdcall" (sampler: cl_sampler) -> cl_int
clRetainSampler_fn                                        :: clRetainSampler_t
clReleaseSampler_t                                        :: #type proc "stdcall" (sampler: cl_sampler) -> cl_int
clReleaseSampler_fn                                       :: clReleaseSampler_t
clGetSamplerInfo_t                                        :: #type proc "stdcall" (sampler: cl_sampler, param_name: cl_sampler_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetSamplerInfo_fn                                       :: clGetSamplerInfo_t
clCreateProgramWithSource_t                               :: #type proc "stdcall" (_context: cl_context, count: cl_uint, strings: ^c.schar, lengths: c.size_t, errcode_ret: cl_int) -> cl_program
clCreateProgramWithSource_fn                              :: clCreateProgramWithSource_t
clCreateProgramWithBinary_t                               :: #type proc "stdcall" (_context: cl_context, num_devices: cl_uint, device_list: cl_device_id, lengths: c.size_t, binaries: ^c.char, binary_status: cl_int, errcode_ret: cl_int) -> cl_program
clCreateProgramWithBinary_fn                              :: clCreateProgramWithBinary_t
clRetainProgram_t                                         :: #type proc "stdcall" (program: cl_program) -> cl_int
clRetainProgram_fn                                        :: clRetainProgram_t
clReleaseProgram_t                                        :: #type proc "stdcall" (program: cl_program) -> cl_int
clReleaseProgram_fn                                       :: clReleaseProgram_t
clBuildProgram_t                                          :: #type proc "stdcall" (program: cl_program, num_devices: cl_uint, device_list: cl_device_id, options: c.schar, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr) -> cl_int
clBuildProgram_fn                                         :: clBuildProgram_t
clGetProgramInfo_t                                        :: #type proc "stdcall" (program: cl_program, param_name: cl_program_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetProgramInfo_fn                                       :: clGetProgramInfo_t
clGetProgramBuildInfo_t                                   :: #type proc "stdcall" (program: cl_program, device: cl_device_id, param_name: cl_program_build_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetProgramBuildInfo_fn                                  :: clGetProgramBuildInfo_t
clCreateKernel_t                                          :: #type proc "stdcall" (program: cl_program, kernel_name: c.schar, errcode_ret: cl_int) -> cl_kernel
clCreateKernel_fn                                         :: clCreateKernel_t
clCreateKernelsInProgram_t                                :: #type proc "stdcall" (program: cl_program, num_kernels: cl_uint, kernels: cl_kernel, num_kernels_ret: cl_uint) -> cl_int
clCreateKernelsInProgram_fn                               :: clCreateKernelsInProgram_t
clRetainKernel_t                                          :: #type proc "stdcall" (kernel: cl_kernel) -> cl_int
clRetainKernel_fn                                         :: clRetainKernel_t
clReleaseKernel_t                                         :: #type proc "stdcall" (kernel: cl_kernel) -> cl_int
clReleaseKernel_fn                                        :: clReleaseKernel_t
clSetKernelArg_t                                          :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_size: c.size_t, arg_value: rawptr) -> cl_int
clSetKernelArg_fn                                         :: clSetKernelArg_t
clGetKernelInfo_t                                         :: #type proc "stdcall" (kernel: cl_kernel, param_name: cl_kernel_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetKernelInfo_fn                                        :: clGetKernelInfo_t
clGetKernelWorkGroupInfo_t                                :: #type proc "stdcall" (kernel: cl_kernel, device: cl_device_id, param_name: cl_kernel_work_group_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetKernelWorkGroupInfo_fn                               :: clGetKernelWorkGroupInfo_t
clWaitForEvents_t                                         :: #type proc "stdcall" (num_events: cl_uint, event_list: cl_event) -> cl_int
clWaitForEvents_fn                                        :: clWaitForEvents_t
clGetEventInfo_t                                          :: #type proc "stdcall" (event: cl_event, param_name: cl_event_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetEventInfo_fn                                         :: clGetEventInfo_t
clRetainEvent_t                                           :: #type proc "stdcall" (event: cl_event) -> cl_int
clRetainEvent_fn                                          :: clRetainEvent_t
clReleaseEvent_t                                          :: #type proc "stdcall" (event: cl_event) -> cl_int
clReleaseEvent_fn                                         :: clReleaseEvent_t
clGetEventProfilingInfo_t                                 :: #type proc "stdcall" (event: cl_event, param_name: cl_profiling_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetEventProfilingInfo_fn                                :: clGetEventProfilingInfo_t
clFlush_t                                                 :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clFlush_fn                                                :: clFlush_t
clFinish_t                                                :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clFinish_fn                                               :: clFinish_t
clEnqueueReadBuffer_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_read: cl_bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReadBuffer_fn                                    :: clEnqueueReadBuffer_t
clEnqueueWriteBuffer_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_write: cl_bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueWriteBuffer_fn                                   :: clEnqueueWriteBuffer_t
clEnqueueCopyBuffer_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, src_buffer: cl_mem, dst_buffer: cl_mem, src_offset: c.size_t, dst_offset: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueCopyBuffer_fn                                    :: clEnqueueCopyBuffer_t
clEnqueueReadImage_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, blocking_read: cl_bool, origin: c.size_t, region: c.size_t, row_pitch: c.size_t, slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReadImage_fn                                     :: clEnqueueReadImage_t
clEnqueueWriteImage_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, blocking_write: cl_bool, origin: c.size_t, region: c.size_t, input_row_pitch: c.size_t, input_slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueWriteImage_fn                                    :: clEnqueueWriteImage_t
clEnqueueCopyImage_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, src_image: cl_mem, dst_image: cl_mem, src_origin: c.size_t, dst_origin: c.size_t, region: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueCopyImage_fn                                     :: clEnqueueCopyImage_t
clEnqueueCopyImageToBuffer_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, src_image: cl_mem, dst_buffer: cl_mem, src_origin: c.size_t, region: c.size_t, dst_offset: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueCopyImageToBuffer_fn                             :: clEnqueueCopyImageToBuffer_t
clEnqueueCopyBufferToImage_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, src_buffer: cl_mem, dst_image: cl_mem, src_offset: c.size_t, dst_origin: c.size_t, region: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueCopyBufferToImage_fn                             :: clEnqueueCopyBufferToImage_t
clEnqueueMapBuffer_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_map: cl_bool, map_flags: cl_map_flags, offset: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event, errcode_ret: cl_int) -> rawptr
clEnqueueMapBuffer_fn                                     :: clEnqueueMapBuffer_t
clEnqueueMapImage_t                                       :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, blocking_map: cl_bool, map_flags: cl_map_flags, origin: c.size_t, region: c.size_t, image_row_pitch: c.size_t, image_slice_pitch: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event, errcode_ret: cl_int) -> rawptr
clEnqueueMapImage_fn                                      :: clEnqueueMapImage_t
clEnqueueUnmapMemObject_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, memobj: cl_mem, mapped_ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueUnmapMemObject_fn                                :: clEnqueueUnmapMemObject_t
clEnqueueNDRangeKernel_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, kernel: cl_kernel, work_dim: cl_uint, global_work_offset: c.size_t, global_work_size: c.size_t, local_work_size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueNDRangeKernel_fn                                 :: clEnqueueNDRangeKernel_t
clEnqueueNativeKernel_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, user_func: #type proc "stdcall" (_1: rawptr), args: rawptr, cb_args: c.size_t, num_mem_objects: cl_uint, mem_list: cl_mem, args_mem_loc: ^rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueNativeKernel_fn                                  :: clEnqueueNativeKernel_t
clSetCommandQueueProperty_t                               :: #type proc "stdcall" (command_queue: cl_command_queue, properties: cl_command_queue_properties, enable: cl_bool, old_properties: cl_command_queue_properties) -> cl_int
clSetCommandQueueProperty_fn                              :: clSetCommandQueueProperty_t
clCreateImage2D_t                                         :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_format: cl_image_format, image_width: c.size_t, image_height: c.size_t, image_row_pitch: c.size_t, host_ptr: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateImage2D_fn                                        :: clCreateImage2D_t
clCreateImage3D_t                                         :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_format: cl_image_format, image_width: c.size_t, image_height: c.size_t, image_depth: c.size_t, image_row_pitch: c.size_t, image_slice_pitch: c.size_t, host_ptr: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateImage3D_fn                                        :: clCreateImage3D_t
clEnqueueMarker_t                                         :: #type proc "stdcall" (command_queue: cl_command_queue, event: cl_event) -> cl_int
clEnqueueMarker_fn                                        :: clEnqueueMarker_t
clEnqueueWaitForEvents_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, num_events: cl_uint, event_list: cl_event) -> cl_int
clEnqueueWaitForEvents_fn                                 :: clEnqueueWaitForEvents_t
clEnqueueBarrier_t                                        :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clEnqueueBarrier_fn                                       :: clEnqueueBarrier_t
clUnloadCompiler_t                                        :: #type proc "stdcall" () -> cl_int
clUnloadCompiler_fn                                       :: clUnloadCompiler_t
clGetExtensionFunctionAddress_t                           :: #type proc "stdcall" (func_name: c.schar) -> rawptr
clGetExtensionFunctionAddress_fn                          :: clGetExtensionFunctionAddress_t
clCreateCommandQueue_t                                    :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: cl_command_queue_properties, errcode_ret: cl_int) -> cl_command_queue
clCreateCommandQueue_fn                                   :: clCreateCommandQueue_t
clCreateSampler_t                                         :: #type proc "stdcall" (_context: cl_context, normalized_coords: cl_bool, addressing_mode: cl_addressing_mode, filter_mode: cl_filter_mode, errcode_ret: cl_int) -> cl_sampler
clCreateSampler_fn                                        :: clCreateSampler_t
clEnqueueTask_t                                           :: #type proc "stdcall" (command_queue: cl_command_queue, kernel: cl_kernel, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueTask_fn                                          :: clEnqueueTask_t
clCreateSubBuffer_t                                       :: #type proc "stdcall" (buffer: cl_mem, flags: cl_mem_flags, buffer_create_type: cl_buffer_create_type, buffer_create_info: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateSubBuffer_fn                                      :: clCreateSubBuffer_t
clSetMemObjectDestructorCallback_t                        :: #type proc "stdcall" (memobj: cl_mem, pfn_notify: #type proc "stdcall" (memobj: cl_mem, user_data: rawptr), user_data: rawptr) -> cl_int
clSetMemObjectDestructorCallback_fn                       :: clSetMemObjectDestructorCallback_t
clCreateUserEvent_t                                       :: #type proc "stdcall" (_context: cl_context, errcode_ret: cl_int) -> cl_event
clCreateUserEvent_fn                                      :: clCreateUserEvent_t
clSetUserEventStatus_t                                    :: #type proc "stdcall" (event: cl_event, execution_status: cl_int) -> cl_int
clSetUserEventStatus_fn                                   :: clSetUserEventStatus_t
clSetEventCallback_t                                      :: #type proc "stdcall" (event: cl_event, command_exec_callback_type: cl_int, pfn_notify: #type proc "stdcall" (event: cl_event, event_command_status: cl_int, user_data: rawptr), user_data: rawptr) -> cl_int
clSetEventCallback_fn                                     :: clSetEventCallback_t
clEnqueueReadBufferRect_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_read: cl_bool, buffer_origin: c.size_t, host_origin: c.size_t, region: c.size_t, buffer_row_pitch: c.size_t, buffer_slice_pitch: c.size_t, host_row_pitch: c.size_t, host_slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReadBufferRect_fn                                :: clEnqueueReadBufferRect_t
clEnqueueWriteBufferRect_t                                :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_write: cl_bool, buffer_origin: c.size_t, host_origin: c.size_t, region: c.size_t, buffer_row_pitch: c.size_t, buffer_slice_pitch: c.size_t, host_row_pitch: c.size_t, host_slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueWriteBufferRect_fn                               :: clEnqueueWriteBufferRect_t
clEnqueueCopyBufferRect_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, src_buffer: cl_mem, dst_buffer: cl_mem, src_origin: c.size_t, dst_origin: c.size_t, region: c.size_t, src_row_pitch: c.size_t, src_slice_pitch: c.size_t, dst_row_pitch: c.size_t, dst_slice_pitch: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueCopyBufferRect_fn                                :: clEnqueueCopyBufferRect_t
clCreateSubDevices_t                                      :: #type proc "stdcall" (in_device: cl_device_id, properties: cl_device_partition_property, num_devices: cl_uint, out_devices: cl_device_id, num_devices_ret: cl_uint) -> cl_int
clCreateSubDevices_fn                                     :: clCreateSubDevices_t
clRetainDevice_t                                          :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clRetainDevice_fn                                         :: clRetainDevice_t
clReleaseDevice_t                                         :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clReleaseDevice_fn                                        :: clReleaseDevice_t
clCreateImage_t                                           :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_format: cl_image_format, image_desc: cl_image_desc, host_ptr: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateImage_fn                                          :: clCreateImage_t
clCreateProgramWithBuiltInKernels_t                       :: #type proc "stdcall" (_context: cl_context, num_devices: cl_uint, device_list: cl_device_id, kernel_names: c.schar, errcode_ret: cl_int) -> cl_program
clCreateProgramWithBuiltInKernels_fn                      :: clCreateProgramWithBuiltInKernels_t
clCompileProgram_t                                        :: #type proc "stdcall" (program: cl_program, num_devices: cl_uint, device_list: cl_device_id, options: c.schar, num_input_headers: cl_uint, input_headers: cl_program, header_include_names: ^c.schar, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr) -> cl_int
clCompileProgram_fn                                       :: clCompileProgram_t
clLinkProgram_t                                           :: #type proc "stdcall" (_context: cl_context, num_devices: cl_uint, device_list: cl_device_id, options: c.schar, num_input_programs: cl_uint, input_programs: cl_program, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr, errcode_ret: cl_int) -> cl_program
clLinkProgram_fn                                          :: clLinkProgram_t
clUnloadPlatformCompiler_t                                :: #type proc "stdcall" (platform: cl_platform_id) -> cl_int
clUnloadPlatformCompiler_fn                               :: clUnloadPlatformCompiler_t
clGetKernelArgInfo_t                                      :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, param_name: cl_kernel_arg_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetKernelArgInfo_fn                                     :: clGetKernelArgInfo_t
clEnqueueFillBuffer_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, pattern: rawptr, pattern_size: c.size_t, offset: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueFillBuffer_fn                                    :: clEnqueueFillBuffer_t
clEnqueueFillImage_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, fill_color: rawptr, origin: c.size_t, region: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueFillImage_fn                                     :: clEnqueueFillImage_t
clEnqueueMigrateMemObjects_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: cl_mem, flags: cl_mem_migration_flags, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMigrateMemObjects_fn                             :: clEnqueueMigrateMemObjects_t
clEnqueueMarkerWithWaitList_t                             :: #type proc "stdcall" (command_queue: cl_command_queue, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMarkerWithWaitList_fn                            :: clEnqueueMarkerWithWaitList_t
clEnqueueBarrierWithWaitList_t                            :: #type proc "stdcall" (command_queue: cl_command_queue, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueBarrierWithWaitList_fn                           :: clEnqueueBarrierWithWaitList_t
clGetExtensionFunctionAddressForPlatform_t                :: #type proc "stdcall" (platform: cl_platform_id, func_name: c.schar) -> rawptr
clGetExtensionFunctionAddressForPlatform_fn               :: clGetExtensionFunctionAddressForPlatform_t
clCreateCommandQueueWithProperties_t                      :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: cl_queue_properties, errcode_ret: cl_int) -> cl_command_queue
clCreateCommandQueueWithProperties_fn                     :: clCreateCommandQueueWithProperties_t
clCreatePipe_t                                            :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, pipe_packet_size: cl_uint, pipe_max_packets: cl_uint, properties: cl_pipe_properties, errcode_ret: cl_int) -> cl_mem
clCreatePipe_fn                                           :: clCreatePipe_t
clGetPipeInfo_t                                           :: #type proc "stdcall" (pipe: cl_mem, param_name: cl_pipe_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetPipeInfo_fn                                          :: clGetPipeInfo_t
clSVMAlloc_t                                              :: #type proc "stdcall" (_context: cl_context, flags: cl_svm_mem_flags, size: c.size_t, alignment: cl_uint) -> rawptr
clSVMAlloc_fn                                             :: clSVMAlloc_t
clSVMFree_t                                               :: #type proc "stdcall" (_context: cl_context, svm_pointer: rawptr)
clSVMFree_fn                                              :: clSVMFree_t
clCreateSamplerWithProperties_t                           :: #type proc "stdcall" (_context: cl_context, sampler_properties: cl_sampler_properties, errcode_ret: cl_int) -> cl_sampler
clCreateSamplerWithProperties_fn                          :: clCreateSamplerWithProperties_t
clSetKernelArgSVMPointer_t                                :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_value: rawptr) -> cl_int
clSetKernelArgSVMPointer_fn                               :: clSetKernelArgSVMPointer_t
clSetKernelExecInfo_t                                     :: #type proc "stdcall" (kernel: cl_kernel, param_name: cl_kernel_exec_info, param_value_size: c.size_t, param_value: rawptr) -> cl_int
clSetKernelExecInfo_fn                                    :: clSetKernelExecInfo_t
clEnqueueSVMFree_t                                        :: #type proc "stdcall" (command_queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, pfn_free_func: #type proc "stdcall" (queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, user_data: rawptr), user_data: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMFree_fn                                       :: clEnqueueSVMFree_t
clEnqueueSVMMemcpy_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_copy: cl_bool, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMMemcpy_fn                                     :: clEnqueueSVMMemcpy_t
clEnqueueSVMMemFill_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMMemFill_fn                                    :: clEnqueueSVMMemFill_t
clEnqueueSVMMap_t                                         :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_map: cl_bool, flags: cl_map_flags, svm_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMMap_fn                                        :: clEnqueueSVMMap_t
clEnqueueSVMUnmap_t                                       :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMUnmap_fn                                      :: clEnqueueSVMUnmap_t
clSetDefaultDeviceCommandQueue_t                          :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, command_queue: cl_command_queue) -> cl_int
clSetDefaultDeviceCommandQueue_fn                         :: clSetDefaultDeviceCommandQueue_t
clGetDeviceAndHostTimer_t                                 :: #type proc "stdcall" (device: cl_device_id, device_timestamp: cl_ulong, host_timestamp: cl_ulong) -> cl_int
clGetDeviceAndHostTimer_fn                                :: clGetDeviceAndHostTimer_t
clGetHostTimer_t                                          :: #type proc "stdcall" (device: cl_device_id, host_timestamp: cl_ulong) -> cl_int
clGetHostTimer_fn                                         :: clGetHostTimer_t
clCreateProgramWithIL_t                                   :: #type proc "stdcall" (_context: cl_context, il: rawptr, length: c.size_t, errcode_ret: cl_int) -> cl_program
clCreateProgramWithIL_fn                                  :: clCreateProgramWithIL_t
clCloneKernel_t                                           :: #type proc "stdcall" (source_kernel: cl_kernel, errcode_ret: cl_int) -> cl_kernel
clCloneKernel_fn                                          :: clCloneKernel_t
clGetKernelSubGroupInfo_t                                 :: #type proc "stdcall" (kernel: cl_kernel, device: cl_device_id, param_name: cl_kernel_sub_group_info, input_value_size: c.size_t, input_value: rawptr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetKernelSubGroupInfo_fn                                :: clGetKernelSubGroupInfo_t
clEnqueueSVMMigrateMem_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: ^rawptr, sizes: c.size_t, flags: cl_mem_migration_flags, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMMigrateMem_fn                                 :: clEnqueueSVMMigrateMem_t
clSetProgramSpecializationConstant_t                      :: #type proc "stdcall" (program: cl_program, spec_id: cl_uint, spec_size: c.size_t, spec_value: rawptr) -> cl_int
clSetProgramSpecializationConstant_fn                     :: clSetProgramSpecializationConstant_t
clSetProgramReleaseCallback_t                             :: #type proc "stdcall" (program: cl_program, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr) -> cl_int
clSetProgramReleaseCallback_fn                            :: clSetProgramReleaseCallback_t
clSetContextDestructorCallback_t                          :: #type proc "stdcall" (_context: cl_context, pfn_notify: #type proc "stdcall" (_context: cl_context, user_data: rawptr), user_data: rawptr) -> cl_int
clSetContextDestructorCallback_fn                         :: clSetContextDestructorCallback_t
clCreateBufferWithProperties_t                            :: #type proc "stdcall" (_context: cl_context, properties: cl_mem_properties, flags: cl_mem_flags, size: c.size_t, host_ptr: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateBufferWithProperties_fn                           :: clCreateBufferWithProperties_t
clCreateImageWithProperties_t                             :: #type proc "stdcall" (_context: cl_context, properties: cl_mem_properties, flags: cl_mem_flags, image_format: cl_image_format, image_desc: cl_image_desc, host_ptr: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateImageWithProperties_fn                            :: clCreateImageWithProperties_t
foreign opencl {
}

        /* =========================================
        *               cl_d3d11.h
        * ========================================= */
            cl_d3d11_device_source_khr                                :: cl_uint
cl_d3d11_device_set_khr                                   :: cl_uint
clGetDeviceIDsFromD3D11KHR_t                              :: #type proc "stdcall" (platform: cl_platform_id, d3d_device_source: cl_d3d11_device_source_khr, d3d_object: rawptr, d3d_device_set: cl_d3d11_device_set_khr, num_entries: cl_uint, devices: cl_device_id, num_devices: cl_uint) -> cl_int
clGetDeviceIDsFromD3D11KHR_fn                             :: clGetDeviceIDsFromD3D11KHR_t
clCreateFromD3D11BufferKHR_t                              :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, resource: d3d11.ID3D11Buffer, errcode_ret: cl_int) -> cl_mem
clCreateFromD3D11BufferKHR_fn                             :: clCreateFromD3D11BufferKHR_t
clCreateFromD3D11Texture2DKHR_t                           :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, resource: d3d11.ID3D11Texture2D, subresource: dxgi.UINT, errcode_ret: cl_int) -> cl_mem
clCreateFromD3D11Texture2DKHR_fn                          :: clCreateFromD3D11Texture2DKHR_t
clCreateFromD3D11Texture3DKHR_t                           :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, resource: d3d11.ID3D11Texture3D, subresource: dxgi.UINT, errcode_ret: cl_int) -> cl_mem
clCreateFromD3D11Texture3DKHR_fn                          :: clCreateFromD3D11Texture3DKHR_t
clEnqueueAcquireD3D11ObjectsKHR_t                         :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueAcquireD3D11ObjectsKHR_fn                        :: clEnqueueAcquireD3D11ObjectsKHR_t
clEnqueueReleaseD3D11ObjectsKHR_t                         :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReleaseD3D11ObjectsKHR_fn                        :: clEnqueueReleaseD3D11ObjectsKHR_t
clGetSupportedD3D11TextureFormatsINTEL_t                  :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_type: cl_mem_object_type, plane: cl_uint, num_entries: cl_uint, d3d11_formats: dxgi.DXGI_FORMAT, num_texture_formats: cl_uint) -> cl_int
clGetSupportedD3D11TextureFormatsINTEL_fn                 :: clGetSupportedD3D11TextureFormatsINTEL_t
foreign opencl {
	clGetDeviceIDsFromD3D11KHR :: proc "stdcall" (
                                              platform: cl_platform_id,
                                              d3d_device_source: cl_d3d11_device_source_khr,
                                              d3d_object: rawptr,
                                              d3d_device_set: cl_d3d11_device_set_khr,
                                              num_entries: cl_uint,
                                              devices: cl_device_id,
                                              num_devices: cl_uint) -> cl_int ---
	clCreateFromD3D11BufferKHR :: proc "stdcall" (
                                              _context: cl_context,
                                              flags: cl_mem_flags,
                                              resource: d3d11.ID3D11Buffer,
                                              errcode_ret: cl_int) -> cl_mem ---
	clCreateFromD3D11Texture2DKHR :: proc "stdcall" (
                                                 _context: cl_context,
                                                 flags: cl_mem_flags,
                                                 resource: d3d11.ID3D11Texture2D,
                                                 subresource: dxgi.UINT,
                                                 errcode_ret: cl_int) -> cl_mem ---
	clCreateFromD3D11Texture3DKHR :: proc "stdcall" (
                                                 _context: cl_context,
                                                 flags: cl_mem_flags,
                                                 resource: d3d11.ID3D11Texture3D,
                                                 subresource: dxgi.UINT,
                                                 errcode_ret: cl_int) -> cl_mem ---
	clEnqueueAcquireD3D11ObjectsKHR :: proc "stdcall" (
                                                   command_queue: cl_command_queue,
                                                   num_objects: cl_uint,
                                                   mem_objects: cl_mem,
                                                   num_events_in_wait_list: cl_uint,
                                                   event_wait_list: cl_event,
                                                   event: cl_event) -> cl_int ---
	clEnqueueReleaseD3D11ObjectsKHR :: proc "stdcall" (
                                                   command_queue: cl_command_queue,
                                                   num_objects: cl_uint,
                                                   mem_objects: cl_mem,
                                                   num_events_in_wait_list: cl_uint,
                                                   event_wait_list: cl_event,
                                                   event: cl_event) -> cl_int ---
	clGetSupportedD3D11TextureFormatsINTEL :: proc "stdcall" (
                                                          _context: cl_context,
                                                          flags: cl_mem_flags,
                                                          image_type: cl_mem_object_type,
                                                          plane: cl_uint,
                                                          num_entries: cl_uint,
                                                          d3d11_formats: dxgi.DXGI_FORMAT,
                                                          num_texture_formats: cl_uint) -> cl_int ---
}

        /* =========================================
        *               cl_ext.h
        * ========================================= */
            cl_device_command_buffer_capabilities_khr                 :: cl_bitfield
cl_command_buffer_khr                                     :: distinct rawptr
cl_sync_point_khr                                         :: cl_uint
cl_command_buffer_info_khr                                :: cl_uint
cl_command_buffer_state_khr                               :: cl_uint
cl_command_buffer_properties_khr                          :: cl_properties
cl_command_buffer_flags_khr                               :: cl_bitfield
cl_command_properties_khr                                 :: cl_properties
cl_mutable_command_khr                                    :: distinct rawptr
clCreateCommandBufferKHR_t                                :: #type proc "stdcall" (num_queues: cl_uint, queues: cl_command_queue, properties: cl_command_buffer_properties_khr, errcode_ret: cl_int) -> cl_command_buffer_khr
clCreateCommandBufferKHR_fn                               :: clCreateCommandBufferKHR_t
clFinalizeCommandBufferKHR_t                              :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int
clFinalizeCommandBufferKHR_fn                             :: clFinalizeCommandBufferKHR_t
clRetainCommandBufferKHR_t                                :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int
clRetainCommandBufferKHR_fn                               :: clRetainCommandBufferKHR_t
clReleaseCommandBufferKHR_t                               :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int
clReleaseCommandBufferKHR_fn                              :: clReleaseCommandBufferKHR_t
clEnqueueCommandBufferKHR_t                               :: #type proc "stdcall" (num_queues: cl_uint, queues: cl_command_queue, command_buffer: cl_command_buffer_khr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueCommandBufferKHR_fn                              :: clEnqueueCommandBufferKHR_t
clCommandBarrierWithWaitListKHR_t                         :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandBarrierWithWaitListKHR_fn                        :: clCommandBarrierWithWaitListKHR_t
clCommandCopyBufferKHR_t                                  :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, src_buffer: cl_mem, dst_buffer: cl_mem, src_offset: c.size_t, dst_offset: c.size_t, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandCopyBufferKHR_fn                                 :: clCommandCopyBufferKHR_t
clCommandCopyBufferRectKHR_t                              :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, src_buffer: cl_mem, dst_buffer: cl_mem, src_origin: c.size_t, dst_origin: c.size_t, region: c.size_t, src_row_pitch: c.size_t, src_slice_pitch: c.size_t, dst_row_pitch: c.size_t, dst_slice_pitch: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandCopyBufferRectKHR_fn                             :: clCommandCopyBufferRectKHR_t
clCommandCopyBufferToImageKHR_t                           :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, src_buffer: cl_mem, dst_image: cl_mem, src_offset: c.size_t, dst_origin: c.size_t, region: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandCopyBufferToImageKHR_fn                          :: clCommandCopyBufferToImageKHR_t
clCommandCopyImageKHR_t                                   :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, src_image: cl_mem, dst_image: cl_mem, src_origin: c.size_t, dst_origin: c.size_t, region: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandCopyImageKHR_fn                                  :: clCommandCopyImageKHR_t
clCommandCopyImageToBufferKHR_t                           :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, src_image: cl_mem, dst_buffer: cl_mem, src_origin: c.size_t, region: c.size_t, dst_offset: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandCopyImageToBufferKHR_fn                          :: clCommandCopyImageToBufferKHR_t
clCommandFillBufferKHR_t                                  :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, buffer: cl_mem, pattern: rawptr, pattern_size: c.size_t, offset: c.size_t, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandFillBufferKHR_fn                                 :: clCommandFillBufferKHR_t
clCommandFillImageKHR_t                                   :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, image: cl_mem, fill_color: rawptr, origin: c.size_t, region: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandFillImageKHR_fn                                  :: clCommandFillImageKHR_t
clCommandNDRangeKernelKHR_t                               :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, kernel: cl_kernel, work_dim: cl_uint, global_work_offset: c.size_t, global_work_size: c.size_t, local_work_size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandNDRangeKernelKHR_fn                              :: clCommandNDRangeKernelKHR_t
clGetCommandBufferInfoKHR_t                               :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, param_name: cl_command_buffer_info_khr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetCommandBufferInfoKHR_fn                              :: clGetCommandBufferInfoKHR_t
clCommandSVMMemcpyKHR_t                                   :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandSVMMemcpyKHR_fn                                  :: clCommandSVMMemcpyKHR_t
clCommandSVMMemFillKHR_t                                  :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: cl_command_properties_khr, svm_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: cl_sync_point_khr, sync_point: cl_sync_point_khr, mutable_handle: cl_mutable_command_khr) -> cl_int
clCommandSVMMemFillKHR_fn                                 :: clCommandSVMMemFillKHR_t
cl_platform_command_buffer_capabilities_khr               :: cl_bitfield
clRemapCommandBufferKHR_t                                 :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, automatic: cl_bool, num_queues: cl_uint, queues: cl_command_queue, num_handles: cl_uint, handles: cl_mutable_command_khr, handles_ret: cl_mutable_command_khr, errcode_ret: cl_int) -> cl_command_buffer_khr
clRemapCommandBufferKHR_fn                                :: clRemapCommandBufferKHR_t
cl_command_buffer_update_type_khr                         :: cl_uint
cl_mutable_dispatch_fields_khr                            :: cl_bitfield
cl_mutable_command_info_khr                               :: cl_uint
cl_mutable_dispatch_arg_khr                               :: struct{
	arg_index: cl_uint,
	arg_size: c.size_t,
	arg_value: rawptr,
}
cl_mutable_dispatch_exec_info_khr                         :: struct{
	param_name: cl_uint,
	param_value_size: c.size_t,
	param_value: rawptr,
}
cl_mutable_dispatch_config_khr                            :: struct{
	command: cl_mutable_command_khr,
	num_args: cl_uint,
	num_svm_args: cl_uint,
	num_exec_infos: cl_uint,
	work_dim: cl_uint,
	arg_list: cl_mutable_dispatch_arg_khr,
	arg_svm_list: cl_mutable_dispatch_arg_khr,
	exec_info_list: cl_mutable_dispatch_exec_info_khr,
	global_work_offset: c.size_t,
	global_work_size: c.size_t,
	local_work_size: c.size_t,
}
cl_mutable_dispatch_asserts_khr                           :: cl_bitfield
clUpdateMutableCommandsKHR_t                              :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, num_configs: cl_uint, config_types: cl_command_buffer_update_type_khr, configs: ^rawptr) -> cl_int
clUpdateMutableCommandsKHR_fn                             :: clUpdateMutableCommandsKHR_t
clGetMutableCommandInfoKHR_t                              :: #type proc "stdcall" (command: cl_mutable_command_khr, param_name: cl_mutable_command_info_khr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetMutableCommandInfoKHR_fn                             :: clGetMutableCommandInfoKHR_t
clSetMemObjectDestructorAPPLE_t                           :: #type proc "stdcall" (memobj: cl_mem, pfn_notify: #type proc "stdcall" (memobj: cl_mem, user_data: rawptr), user_data: rawptr) -> cl_int
clSetMemObjectDestructorAPPLE_fn                          :: clSetMemObjectDestructorAPPLE_t
clLogMessagesToSystemLogAPPLE_t                           :: #type proc "stdcall" (errstr: c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr)
clLogMessagesToSystemLogAPPLE_fn                          :: clLogMessagesToSystemLogAPPLE_t
clLogMessagesToStdoutAPPLE_t                              :: #type proc "stdcall" (errstr: c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr)
clLogMessagesToStdoutAPPLE_fn                             :: clLogMessagesToStdoutAPPLE_t
clLogMessagesToStderrAPPLE_t                              :: #type proc "stdcall" (errstr: c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr)
clLogMessagesToStderrAPPLE_fn                             :: clLogMessagesToStderrAPPLE_t
clIcdGetPlatformIDsKHR_t                                  :: #type proc "stdcall" (num_entries: cl_uint, platforms: cl_platform_id, num_platforms: cl_uint) -> cl_int
clIcdGetPlatformIDsKHR_fn                                 :: clIcdGetPlatformIDsKHR_t
clCreateProgramWithILKHR_t                                :: #type proc "stdcall" (_context: cl_context, il: rawptr, length: c.size_t, errcode_ret: cl_int) -> cl_program
clCreateProgramWithILKHR_fn                               :: clCreateProgramWithILKHR_t
cl_context_memory_initialize_khr                          :: cl_bitfield
cl_device_terminate_capability_khr                        :: cl_bitfield
clTerminateContextKHR_t                                   :: #type proc "stdcall" (_context: cl_context) -> cl_int
clTerminateContextKHR_fn                                  :: clTerminateContextKHR_t
cl_queue_properties_khr                                   :: cl_properties
clCreateCommandQueueWithPropertiesKHR_t                   :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: cl_queue_properties_khr, errcode_ret: cl_int) -> cl_command_queue
clCreateCommandQueueWithPropertiesKHR_fn                  :: clCreateCommandQueueWithPropertiesKHR_t
cl_device_partition_property_ext                          :: cl_ulong
clReleaseDeviceEXT_t                                      :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clReleaseDeviceEXT_fn                                     :: clReleaseDeviceEXT_t
clRetainDeviceEXT_t                                       :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clRetainDeviceEXT_fn                                      :: clRetainDeviceEXT_t
clCreateSubDevicesEXT_t                                   :: #type proc "stdcall" (in_device: cl_device_id, properties: cl_device_partition_property_ext, num_entries: cl_uint, out_devices: cl_device_id, num_devices: cl_uint) -> cl_int
clCreateSubDevicesEXT_fn                                  :: clCreateSubDevicesEXT_t
cl_mem_migration_flags_ext                                :: cl_bitfield
clEnqueueMigrateMemObjectEXT_t                            :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: cl_mem, flags: cl_mem_migration_flags_ext, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMigrateMemObjectEXT_fn                           :: clEnqueueMigrateMemObjectEXT_t
cl_image_pitch_info_qcom                                  :: cl_uint
cl_mem_ext_host_ptr                                       :: struct{
	allocation_type: cl_uint,
	host_cache_policy: cl_uint,
}
clGetDeviceImageInfoQCOM_t                                :: #type proc "stdcall" (device: cl_device_id, image_width: c.size_t, image_height: c.size_t, image_format: cl_image_format, param_name: cl_image_pitch_info_qcom, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetDeviceImageInfoQCOM_fn                               :: clGetDeviceImageInfoQCOM_t
cl_mem_ion_host_ptr                                       :: struct{
	ext_host_ptr: cl_mem_ext_host_ptr,
	ion_filedesc: c.int,
	ion_hostptr: rawptr,
}
cl_mem_android_native_buffer_host_ptr                     :: struct{
	ext_host_ptr: cl_mem_ext_host_ptr,
	anb_ptr: rawptr,
}
clEnqueueAcquireGrallocObjectsIMG_t                       :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueAcquireGrallocObjectsIMG_fn                      :: clEnqueueAcquireGrallocObjectsIMG_t
clEnqueueReleaseGrallocObjectsIMG_t                       :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReleaseGrallocObjectsIMG_fn                      :: clEnqueueReleaseGrallocObjectsIMG_t
cl_mipmap_filter_mode_img                                 :: cl_uint
clEnqueueGenerateMipmapIMG_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, src_image: cl_mem, dst_image: cl_mem, mipmap_filter_mode: cl_mipmap_filter_mode_img, array_region: c.size_t, mip_region: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueGenerateMipmapIMG_fn                             :: clEnqueueGenerateMipmapIMG_t
clGetKernelSubGroupInfoKHR_t                              :: #type proc "stdcall" (in_kernel: cl_kernel, in_device: cl_device_id, param_name: cl_kernel_sub_group_info, input_value_size: c.size_t, input_value: rawptr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetKernelSubGroupInfoKHR_fn                             :: clGetKernelSubGroupInfoKHR_t
cl_queue_priority_khr                                     :: cl_uint
cl_queue_throttle_khr                                     :: cl_uint
cl_version_khr                                            :: cl_uint
cl_name_version_khr                                       :: struct{
	version: cl_version_khr,
	name: [64]c.schar,
}
cl_device_pci_bus_info_khr                                :: struct{
	pci_domain: cl_uint,
	pci_bus: cl_uint,
	pci_device: cl_uint,
	pci_function: cl_uint,
}
clGetKernelSuggestedLocalWorkSizeKHR_t                    :: #type proc "stdcall" (command_queue: cl_command_queue, kernel: cl_kernel, work_dim: cl_uint, global_work_offset: c.size_t, global_work_size: c.size_t, suggested_local_work_size: c.size_t) -> cl_int
clGetKernelSuggestedLocalWorkSizeKHR_fn                   :: clGetKernelSuggestedLocalWorkSizeKHR_t
cl_device_integer_dot_product_capabilities_khr            :: cl_bitfield
cl_device_integer_dot_product_acceleration_properties_khr :: struct{
	signed_accelerated: cl_bool,
	unsigned_accelerated: cl_bool,
	mixed_signedness_accelerated: cl_bool,
	accumulating_saturating_signed_accelerated: cl_bool,
	accumulating_saturating_unsigned_accelerated: cl_bool,
	accumulating_saturating_mixed_signedness_accelerated: cl_bool,
}
cl_external_memory_handle_type_khr                        :: cl_uint
clEnqueueAcquireExternalMemObjectsKHR_t                   :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueAcquireExternalMemObjectsKHR_fn                  :: clEnqueueAcquireExternalMemObjectsKHR_t
clEnqueueReleaseExternalMemObjectsKHR_t                   :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReleaseExternalMemObjectsKHR_fn                  :: clEnqueueReleaseExternalMemObjectsKHR_t
cl_semaphore_khr                                          :: distinct rawptr
cl_external_semaphore_handle_type_khr                     :: cl_uint
clGetSemaphoreHandleForTypeKHR_t                          :: #type proc "stdcall" (sema_object: cl_semaphore_khr, device: cl_device_id, handle_type: cl_external_semaphore_handle_type_khr, handle_size: c.size_t, handle_ptr: rawptr, handle_size_ret: c.size_t) -> cl_int
clGetSemaphoreHandleForTypeKHR_fn                         :: clGetSemaphoreHandleForTypeKHR_t
cl_semaphore_reimport_properties_khr                      :: cl_properties
clReImportSemaphoreSyncFdKHR_t                            :: #type proc "stdcall" (sema_object: cl_semaphore_khr, reimport_props: cl_semaphore_reimport_properties_khr, fd: c.int) -> cl_int
clReImportSemaphoreSyncFdKHR_fn                           :: clReImportSemaphoreSyncFdKHR_t
cl_semaphore_properties_khr                               :: cl_properties
cl_semaphore_info_khr                                     :: cl_uint
cl_semaphore_type_khr                                     :: cl_uint
cl_semaphore_payload_khr                                  :: cl_ulong
clCreateSemaphoreWithPropertiesKHR_t                      :: #type proc "stdcall" (_context: cl_context, sema_props: cl_semaphore_properties_khr, errcode_ret: cl_int) -> cl_semaphore_khr
clCreateSemaphoreWithPropertiesKHR_fn                     :: clCreateSemaphoreWithPropertiesKHR_t
clEnqueueWaitSemaphoresKHR_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, num_sema_objects: cl_uint, sema_objects: cl_semaphore_khr, sema_payload_list: cl_semaphore_payload_khr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueWaitSemaphoresKHR_fn                             :: clEnqueueWaitSemaphoresKHR_t
clEnqueueSignalSemaphoresKHR_t                            :: #type proc "stdcall" (command_queue: cl_command_queue, num_sema_objects: cl_uint, sema_objects: cl_semaphore_khr, sema_payload_list: cl_semaphore_payload_khr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSignalSemaphoresKHR_fn                           :: clEnqueueSignalSemaphoresKHR_t
clGetSemaphoreInfoKHR_t                                   :: #type proc "stdcall" (sema_object: cl_semaphore_khr, param_name: cl_semaphore_info_khr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetSemaphoreInfoKHR_fn                                  :: clGetSemaphoreInfoKHR_t
clReleaseSemaphoreKHR_t                                   :: #type proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int
clReleaseSemaphoreKHR_fn                                  :: clReleaseSemaphoreKHR_t
clRetainSemaphoreKHR_t                                    :: #type proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int
clRetainSemaphoreKHR_fn                                   :: clRetainSemaphoreKHR_t
cl_import_properties_arm                                  :: c.intptr_t
clImportMemoryARM_t                                       :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, properties: cl_import_properties_arm, memory: rawptr, size: c.size_t, errcode_ret: cl_int) -> cl_mem
clImportMemoryARM_fn                                      :: clImportMemoryARM_t
cl_svm_mem_flags_arm                                      :: cl_bitfield
cl_kernel_exec_info_arm                                   :: cl_uint
cl_device_svm_capabilities_arm                            :: cl_bitfield
clSVMAllocARM_t                                           :: #type proc "stdcall" (_context: cl_context, flags: cl_svm_mem_flags_arm, size: c.size_t, alignment: cl_uint) -> rawptr
clSVMAllocARM_fn                                          :: clSVMAllocARM_t
clSVMFreeARM_t                                            :: #type proc "stdcall" (_context: cl_context, svm_pointer: rawptr)
clSVMFreeARM_fn                                           :: clSVMFreeARM_t
clEnqueueSVMFreeARM_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, pfn_free_func: #type proc "stdcall" (queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, user_data: rawptr), user_data: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMFreeARM_fn                                    :: clEnqueueSVMFreeARM_t
clEnqueueSVMMemcpyARM_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_copy: cl_bool, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMMemcpyARM_fn                                  :: clEnqueueSVMMemcpyARM_t
clEnqueueSVMMemFillARM_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMMemFillARM_fn                                 :: clEnqueueSVMMemFillARM_t
clEnqueueSVMMapARM_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_map: cl_bool, flags: cl_map_flags, svm_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMMapARM_fn                                     :: clEnqueueSVMMapARM_t
clEnqueueSVMUnmapARM_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueSVMUnmapARM_fn                                   :: clEnqueueSVMUnmapARM_t
clSetKernelArgSVMPointerARM_t                             :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_value: rawptr) -> cl_int
clSetKernelArgSVMPointerARM_fn                            :: clSetKernelArgSVMPointerARM_t
clSetKernelExecInfoARM_t                                  :: #type proc "stdcall" (kernel: cl_kernel, param_name: cl_kernel_exec_info_arm, param_value_size: c.size_t, param_value: rawptr) -> cl_int
clSetKernelExecInfoARM_fn                                 :: clSetKernelExecInfoARM_t
cl_device_scheduling_controls_capabilities_arm            :: cl_bitfield
cl_device_controlled_termination_capabilities_arm         :: cl_bitfield
cl_device_feature_capabilities_intel                      :: cl_bitfield
cl_accelerator_intel                                      :: distinct rawptr
cl_accelerator_type_intel                                 :: cl_uint
cl_accelerator_info_intel                                 :: cl_uint
clCreateAcceleratorINTEL_t                                :: #type proc "stdcall" (_context: cl_context, accelerator_type: cl_accelerator_type_intel, descriptor_size: c.size_t, descriptor: rawptr, errcode_ret: cl_int) -> cl_accelerator_intel
clCreateAcceleratorINTEL_fn                               :: clCreateAcceleratorINTEL_t
clGetAcceleratorInfoINTEL_t                               :: #type proc "stdcall" (accelerator: cl_accelerator_intel, param_name: cl_accelerator_info_intel, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetAcceleratorInfoINTEL_fn                              :: clGetAcceleratorInfoINTEL_t
clRetainAcceleratorINTEL_t                                :: #type proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int
clRetainAcceleratorINTEL_fn                               :: clRetainAcceleratorINTEL_t
clReleaseAcceleratorINTEL_t                               :: #type proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int
clReleaseAcceleratorINTEL_fn                              :: clReleaseAcceleratorINTEL_t
cl_motion_estimation_desc_intel                           :: struct{
	mb_block_type: cl_uint,
	subpixel_mode: cl_uint,
	sad_adjust_mode: cl_uint,
	search_path_type: cl_uint,
}
cl_diagnostic_verbose_level_intel                         :: cl_bitfield
cl_device_unified_shared_memory_capabilities_intel        :: cl_bitfield
cl_mem_properties_intel                                   :: cl_properties
cl_mem_alloc_flags_intel                                  :: cl_bitfield
cl_mem_info_intel                                         :: cl_uint
cl_unified_shared_memory_type_intel                       :: cl_uint
cl_mem_advice_intel                                       :: cl_uint
clHostMemAllocINTEL_t                                     :: #type proc "stdcall" (_context: cl_context, properties: cl_mem_properties_intel, size: c.size_t, alignment: cl_uint, errcode_ret: cl_int) -> rawptr
clHostMemAllocINTEL_fn                                    :: clHostMemAllocINTEL_t
clDeviceMemAllocINTEL_t                                   :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: cl_mem_properties_intel, size: c.size_t, alignment: cl_uint, errcode_ret: cl_int) -> rawptr
clDeviceMemAllocINTEL_fn                                  :: clDeviceMemAllocINTEL_t
clSharedMemAllocINTEL_t                                   :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: cl_mem_properties_intel, size: c.size_t, alignment: cl_uint, errcode_ret: cl_int) -> rawptr
clSharedMemAllocINTEL_fn                                  :: clSharedMemAllocINTEL_t
clMemFreeINTEL_t                                          :: #type proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int
clMemFreeINTEL_fn                                         :: clMemFreeINTEL_t
clMemBlockingFreeINTEL_t                                  :: #type proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int
clMemBlockingFreeINTEL_fn                                 :: clMemBlockingFreeINTEL_t
clGetMemAllocInfoINTEL_t                                  :: #type proc "stdcall" (_context: cl_context, ptr: rawptr, param_name: cl_mem_info_intel, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetMemAllocInfoINTEL_fn                                 :: clGetMemAllocInfoINTEL_t
clSetKernelArgMemPointerINTEL_t                           :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_value: rawptr) -> cl_int
clSetKernelArgMemPointerINTEL_fn                          :: clSetKernelArgMemPointerINTEL_t
clEnqueueMemFillINTEL_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, dst_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMemFillINTEL_fn                                  :: clEnqueueMemFillINTEL_t
clEnqueueMemcpyINTEL_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, blocking: cl_bool, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMemcpyINTEL_fn                                   :: clEnqueueMemcpyINTEL_t
clEnqueueMemAdviseINTEL_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, ptr: rawptr, size: c.size_t, advice: cl_mem_advice_intel, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMemAdviseINTEL_fn                                :: clEnqueueMemAdviseINTEL_t
clEnqueueMigrateMemINTEL_t                                :: #type proc "stdcall" (command_queue: cl_command_queue, ptr: rawptr, size: c.size_t, flags: cl_mem_migration_flags, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMigrateMemINTEL_fn                               :: clEnqueueMigrateMemINTEL_t
clEnqueueMemsetINTEL_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, dst_ptr: rawptr, value: cl_int, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueMemsetINTEL_fn                                   :: clEnqueueMemsetINTEL_t
clCreateBufferWithPropertiesINTEL_t                       :: #type proc "stdcall" (_context: cl_context, properties: cl_mem_properties_intel, flags: cl_mem_flags, size: c.size_t, host_ptr: rawptr, errcode_ret: cl_int) -> cl_mem
clCreateBufferWithPropertiesINTEL_fn                      :: clCreateBufferWithPropertiesINTEL_t
clEnqueueReadHostPipeINTEL_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, program: cl_program, pipe_symbol: c.schar, blocking_read: cl_bool, ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReadHostPipeINTEL_fn                             :: clEnqueueReadHostPipeINTEL_t
clEnqueueWriteHostPipeINTEL_t                             :: #type proc "stdcall" (command_queue: cl_command_queue, program: cl_program, pipe_symbol: c.schar, blocking_write: cl_bool, ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueWriteHostPipeINTEL_fn                            :: clEnqueueWriteHostPipeINTEL_t
cl_command_queue_capabilities_intel                       :: cl_bitfield
cl_queue_family_properties_intel                          :: struct{
	properties: cl_command_queue_properties,
	capabilities: cl_command_queue_capabilities_intel,
	count: cl_uint,
	name: [64]c.schar,
}
cl_image_requirements_info_ext                            :: cl_uint
clGetImageRequirementsInfoEXT_t                           :: #type proc "stdcall" (_context: cl_context, properties: cl_mem_properties, flags: cl_mem_flags, image_format: cl_image_format, image_desc: cl_image_desc, param_name: cl_image_requirements_info_ext, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetImageRequirementsInfoEXT_fn                          :: clGetImageRequirementsInfoEXT_t
cl_icdl_info                                              :: cl_uint
clGetICDLoaderInfoOCLICD_t                                :: #type proc "stdcall" (param_name: cl_icdl_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetICDLoaderInfoOCLICD_fn                               :: clGetICDLoaderInfoOCLICD_t
cl_device_fp_atomic_capabilities_ext                      :: cl_bitfield
clSetContentSizeBufferPoCL_t                              :: #type proc "stdcall" (buffer: cl_mem, content_size_buffer: cl_mem) -> cl_int
clSetContentSizeBufferPoCL_fn                             :: clSetContentSizeBufferPoCL_t
cl_device_kernel_clock_capabilities_khr                   :: cl_bitfield
clCancelCommandsIMG_t                                     :: #type proc "stdcall" (event_list: cl_event, num_events_in_list: c.size_t) -> cl_int
clCancelCommandsIMG_fn                                    :: clCancelCommandsIMG_t
foreign opencl {
	clCreateCommandBufferKHR :: proc "stdcall" (
                                            num_queues: cl_uint,
                                            queues: cl_command_queue,
                                            properties: cl_command_buffer_properties_khr,
                                            errcode_ret: cl_int) -> cl_command_buffer_khr ---
	clFinalizeCommandBufferKHR :: proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int ---
	clRetainCommandBufferKHR :: proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int ---
	clReleaseCommandBufferKHR :: proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int ---
	clEnqueueCommandBufferKHR :: proc "stdcall" (
                                             num_queues: cl_uint,
                                             queues: cl_command_queue,
                                             command_buffer: cl_command_buffer_khr,
                                             num_events_in_wait_list: cl_uint,
                                             event_wait_list: cl_event,
                                             event: cl_event) -> cl_int ---
	clCommandBarrierWithWaitListKHR :: proc "stdcall" (
                                                   command_buffer: cl_command_buffer_khr,
                                                   command_queue: cl_command_queue,
                                                   properties: cl_command_properties_khr,
                                                   num_sync_points_in_wait_list: cl_uint,
                                                   sync_point_wait_list: cl_sync_point_khr,
                                                   sync_point: cl_sync_point_khr,
                                                   mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandCopyBufferKHR :: proc "stdcall" (
                                          command_buffer: cl_command_buffer_khr,
                                          command_queue: cl_command_queue,
                                          properties: cl_command_properties_khr,
                                          src_buffer: cl_mem,
                                          dst_buffer: cl_mem,
                                          src_offset: c.size_t,
                                          dst_offset: c.size_t,
                                          size: c.size_t,
                                          num_sync_points_in_wait_list: cl_uint,
                                          sync_point_wait_list: cl_sync_point_khr,
                                          sync_point: cl_sync_point_khr,
                                          mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandCopyBufferRectKHR :: proc "stdcall" (
                                              command_buffer: cl_command_buffer_khr,
                                              command_queue: cl_command_queue,
                                              properties: cl_command_properties_khr,
                                              src_buffer: cl_mem,
                                              dst_buffer: cl_mem,
                                              src_origin: c.size_t,
                                              dst_origin: c.size_t,
                                              region: c.size_t,
                                              src_row_pitch: c.size_t,
                                              src_slice_pitch: c.size_t,
                                              dst_row_pitch: c.size_t,
                                              dst_slice_pitch: c.size_t,
                                              num_sync_points_in_wait_list: cl_uint,
                                              sync_point_wait_list: cl_sync_point_khr,
                                              sync_point: cl_sync_point_khr,
                                              mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandCopyBufferToImageKHR :: proc "stdcall" (
                                                 command_buffer: cl_command_buffer_khr,
                                                 command_queue: cl_command_queue,
                                                 properties: cl_command_properties_khr,
                                                 src_buffer: cl_mem,
                                                 dst_image: cl_mem,
                                                 src_offset: c.size_t,
                                                 dst_origin: c.size_t,
                                                 region: c.size_t,
                                                 num_sync_points_in_wait_list: cl_uint,
                                                 sync_point_wait_list: cl_sync_point_khr,
                                                 sync_point: cl_sync_point_khr,
                                                 mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandCopyImageKHR :: proc "stdcall" (
                                         command_buffer: cl_command_buffer_khr,
                                         command_queue: cl_command_queue,
                                         properties: cl_command_properties_khr,
                                         src_image: cl_mem,
                                         dst_image: cl_mem,
                                         src_origin: c.size_t,
                                         dst_origin: c.size_t,
                                         region: c.size_t,
                                         num_sync_points_in_wait_list: cl_uint,
                                         sync_point_wait_list: cl_sync_point_khr,
                                         sync_point: cl_sync_point_khr,
                                         mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandCopyImageToBufferKHR :: proc "stdcall" (
                                                 command_buffer: cl_command_buffer_khr,
                                                 command_queue: cl_command_queue,
                                                 properties: cl_command_properties_khr,
                                                 src_image: cl_mem,
                                                 dst_buffer: cl_mem,
                                                 src_origin: c.size_t,
                                                 region: c.size_t,
                                                 dst_offset: c.size_t,
                                                 num_sync_points_in_wait_list: cl_uint,
                                                 sync_point_wait_list: cl_sync_point_khr,
                                                 sync_point: cl_sync_point_khr,
                                                 mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandFillBufferKHR :: proc "stdcall" (
                                          command_buffer: cl_command_buffer_khr,
                                          command_queue: cl_command_queue,
                                          properties: cl_command_properties_khr,
                                          buffer: cl_mem,
                                          pattern: rawptr,
                                          pattern_size: c.size_t,
                                          offset: c.size_t,
                                          size: c.size_t,
                                          num_sync_points_in_wait_list: cl_uint,
                                          sync_point_wait_list: cl_sync_point_khr,
                                          sync_point: cl_sync_point_khr,
                                          mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandFillImageKHR :: proc "stdcall" (
                                         command_buffer: cl_command_buffer_khr,
                                         command_queue: cl_command_queue,
                                         properties: cl_command_properties_khr,
                                         image: cl_mem,
                                         fill_color: rawptr,
                                         origin: c.size_t,
                                         region: c.size_t,
                                         num_sync_points_in_wait_list: cl_uint,
                                         sync_point_wait_list: cl_sync_point_khr,
                                         sync_point: cl_sync_point_khr,
                                         mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandNDRangeKernelKHR :: proc "stdcall" (
                                             command_buffer: cl_command_buffer_khr,
                                             command_queue: cl_command_queue,
                                             properties: cl_command_properties_khr,
                                             kernel: cl_kernel,
                                             work_dim: cl_uint,
                                             global_work_offset: c.size_t,
                                             global_work_size: c.size_t,
                                             local_work_size: c.size_t,
                                             num_sync_points_in_wait_list: cl_uint,
                                             sync_point_wait_list: cl_sync_point_khr,
                                             sync_point: cl_sync_point_khr,
                                             mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clGetCommandBufferInfoKHR :: proc "stdcall" (
                                             command_buffer: cl_command_buffer_khr,
                                             param_name: cl_command_buffer_info_khr,
                                             param_value_size: c.size_t,
                                             param_value: rawptr,
                                             param_value_size_ret: c.size_t) -> cl_int ---
	clCommandSVMMemcpyKHR :: proc "stdcall" (
                                         command_buffer: cl_command_buffer_khr,
                                         command_queue: cl_command_queue,
                                         properties: cl_command_properties_khr,
                                         dst_ptr: rawptr,
                                         src_ptr: rawptr,
                                         size: c.size_t,
                                         num_sync_points_in_wait_list: cl_uint,
                                         sync_point_wait_list: cl_sync_point_khr,
                                         sync_point: cl_sync_point_khr,
                                         mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clCommandSVMMemFillKHR :: proc "stdcall" (
                                          command_buffer: cl_command_buffer_khr,
                                          command_queue: cl_command_queue,
                                          properties: cl_command_properties_khr,
                                          svm_ptr: rawptr,
                                          pattern: rawptr,
                                          pattern_size: c.size_t,
                                          size: c.size_t,
                                          num_sync_points_in_wait_list: cl_uint,
                                          sync_point_wait_list: cl_sync_point_khr,
                                          sync_point: cl_sync_point_khr,
                                          mutable_handle: cl_mutable_command_khr) -> cl_int ---
	clRemapCommandBufferKHR :: proc "stdcall" (
                                           command_buffer: cl_command_buffer_khr,
                                           automatic: cl_bool,
                                           num_queues: cl_uint,
                                           queues: cl_command_queue,
                                           num_handles: cl_uint,
                                           handles: cl_mutable_command_khr,
                                           handles_ret: cl_mutable_command_khr,
                                           errcode_ret: cl_int) -> cl_command_buffer_khr ---
	clUpdateMutableCommandsKHR :: proc "stdcall" (
                                              command_buffer: cl_command_buffer_khr,
                                              num_configs: cl_uint,
                                              config_types: cl_command_buffer_update_type_khr,
                                              configs: ^rawptr) -> cl_int ---
	clGetMutableCommandInfoKHR :: proc "stdcall" (
                                              command: cl_mutable_command_khr,
                                              param_name: cl_mutable_command_info_khr,
                                              param_value_size: c.size_t,
                                              param_value: rawptr,
                                              param_value_size_ret: c.size_t) -> cl_int ---
	clSetMemObjectDestructorAPPLE :: proc "stdcall" (
                                                 memobj: cl_mem,
                                                 pfn_notify: #type proc "stdcall" (memobj: cl_mem, user_data: rawptr),
                                                 user_data: rawptr) -> cl_int ---
	clLogMessagesToSystemLogAPPLE :: proc "stdcall" (
                                                 errstr: c.schar,
                                                 private_info: rawptr,
                                                 cb: c.size_t,
                                                 user_data: rawptr) ---
	clLogMessagesToStdoutAPPLE :: proc "stdcall" (
                                              errstr: c.schar,
                                              private_info: rawptr,
                                              cb: c.size_t,
                                              user_data: rawptr) ---
	clLogMessagesToStderrAPPLE :: proc "stdcall" (
                                              errstr: c.schar,
                                              private_info: rawptr,
                                              cb: c.size_t,
                                              user_data: rawptr) ---
	clIcdGetPlatformIDsKHR :: proc "stdcall" (
                                          num_entries: cl_uint,
                                          platforms: cl_platform_id,
                                          num_platforms: cl_uint) -> cl_int ---
	clCreateProgramWithILKHR :: proc "stdcall" (
                                            _context: cl_context,
                                            il: rawptr,
                                            length: c.size_t,
                                            errcode_ret: cl_int) -> cl_program ---
	clTerminateContextKHR :: proc "stdcall" (_context: cl_context) -> cl_int ---
	clCreateCommandQueueWithPropertiesKHR :: proc "stdcall" (
                                                         _context: cl_context,
                                                         device: cl_device_id,
                                                         properties: cl_queue_properties_khr,
                                                         errcode_ret: cl_int) -> cl_command_queue ---
	clReleaseDeviceEXT :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clRetainDeviceEXT :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clCreateSubDevicesEXT :: proc "stdcall" (
                                         in_device: cl_device_id,
                                         properties: cl_device_partition_property_ext,
                                         num_entries: cl_uint,
                                         out_devices: cl_device_id,
                                         num_devices: cl_uint) -> cl_int ---
	clEnqueueMigrateMemObjectEXT :: proc "stdcall" (
                                                command_queue: cl_command_queue,
                                                num_mem_objects: cl_uint,
                                                mem_objects: cl_mem,
                                                flags: cl_mem_migration_flags_ext,
                                                num_events_in_wait_list: cl_uint,
                                                event_wait_list: cl_event,
                                                event: cl_event) -> cl_int ---
	clGetDeviceImageInfoQCOM :: proc "stdcall" (
                                            device: cl_device_id,
                                            image_width: c.size_t,
                                            image_height: c.size_t,
                                            image_format: cl_image_format,
                                            param_name: cl_image_pitch_info_qcom,
                                            param_value_size: c.size_t,
                                            param_value: rawptr,
                                            param_value_size_ret: c.size_t) -> cl_int ---
	clEnqueueAcquireGrallocObjectsIMG :: proc "stdcall" (
                                                     command_queue: cl_command_queue,
                                                     num_objects: cl_uint,
                                                     mem_objects: cl_mem,
                                                     num_events_in_wait_list: cl_uint,
                                                     event_wait_list: cl_event,
                                                     event: cl_event) -> cl_int ---
	clEnqueueReleaseGrallocObjectsIMG :: proc "stdcall" (
                                                     command_queue: cl_command_queue,
                                                     num_objects: cl_uint,
                                                     mem_objects: cl_mem,
                                                     num_events_in_wait_list: cl_uint,
                                                     event_wait_list: cl_event,
                                                     event: cl_event) -> cl_int ---
	clEnqueueGenerateMipmapIMG :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              src_image: cl_mem,
                                              dst_image: cl_mem,
                                              mipmap_filter_mode: cl_mipmap_filter_mode_img,
                                              array_region: c.size_t,
                                              mip_region: c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: cl_event,
                                              event: cl_event) -> cl_int ---
	clGetKernelSubGroupInfoKHR :: proc "stdcall" (
                                              in_kernel: cl_kernel,
                                              in_device: cl_device_id,
                                              param_name: cl_kernel_sub_group_info,
                                              input_value_size: c.size_t,
                                              input_value: rawptr,
                                              param_value_size: c.size_t,
                                              param_value: rawptr,
                                              param_value_size_ret: c.size_t) -> cl_int ---
	clGetKernelSuggestedLocalWorkSizeKHR :: proc "stdcall" (
                                                        command_queue: cl_command_queue,
                                                        kernel: cl_kernel,
                                                        work_dim: cl_uint,
                                                        global_work_offset: c.size_t,
                                                        global_work_size: c.size_t,
                                                        suggested_local_work_size: c.size_t) -> cl_int ---
	clEnqueueAcquireExternalMemObjectsKHR :: proc "stdcall" (
                                                         command_queue: cl_command_queue,
                                                         num_mem_objects: cl_uint,
                                                         mem_objects: cl_mem,
                                                         num_events_in_wait_list: cl_uint,
                                                         event_wait_list: cl_event,
                                                         event: cl_event) -> cl_int ---
	clEnqueueReleaseExternalMemObjectsKHR :: proc "stdcall" (
                                                         command_queue: cl_command_queue,
                                                         num_mem_objects: cl_uint,
                                                         mem_objects: cl_mem,
                                                         num_events_in_wait_list: cl_uint,
                                                         event_wait_list: cl_event,
                                                         event: cl_event) -> cl_int ---
	clGetSemaphoreHandleForTypeKHR :: proc "stdcall" (
                                                  sema_object: cl_semaphore_khr,
                                                  device: cl_device_id,
                                                  handle_type: cl_external_semaphore_handle_type_khr,
                                                  handle_size: c.size_t,
                                                  handle_ptr: rawptr,
                                                  handle_size_ret: c.size_t) -> cl_int ---
	clReImportSemaphoreSyncFdKHR :: proc "stdcall" (
                                                sema_object: cl_semaphore_khr,
                                                reimport_props: cl_semaphore_reimport_properties_khr,
                                                fd: c.int) -> cl_int ---
	clCreateSemaphoreWithPropertiesKHR :: proc "stdcall" (
                                                      _context: cl_context,
                                                      sema_props: cl_semaphore_properties_khr,
                                                      errcode_ret: cl_int) -> cl_semaphore_khr ---
	clEnqueueWaitSemaphoresKHR :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              num_sema_objects: cl_uint,
                                              sema_objects: cl_semaphore_khr,
                                              sema_payload_list: cl_semaphore_payload_khr,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: cl_event,
                                              event: cl_event) -> cl_int ---
	clEnqueueSignalSemaphoresKHR :: proc "stdcall" (
                                                command_queue: cl_command_queue,
                                                num_sema_objects: cl_uint,
                                                sema_objects: cl_semaphore_khr,
                                                sema_payload_list: cl_semaphore_payload_khr,
                                                num_events_in_wait_list: cl_uint,
                                                event_wait_list: cl_event,
                                                event: cl_event) -> cl_int ---
	clGetSemaphoreInfoKHR :: proc "stdcall" (
                                         sema_object: cl_semaphore_khr,
                                         param_name: cl_semaphore_info_khr,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: c.size_t) -> cl_int ---
	clReleaseSemaphoreKHR :: proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int ---
	clRetainSemaphoreKHR :: proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int ---
	clImportMemoryARM :: proc "stdcall" (
                                     _context: cl_context,
                                     flags: cl_mem_flags,
                                     properties: cl_import_properties_arm,
                                     memory: rawptr,
                                     size: c.size_t,
                                     errcode_ret: cl_int) -> cl_mem ---
	clSVMAllocARM :: proc "stdcall" (
                                 _context: cl_context,
                                 flags: cl_svm_mem_flags_arm,
                                 size: c.size_t,
                                 alignment: cl_uint) -> rawptr ---
	clSVMFreeARM :: proc "stdcall" (_context: cl_context, svm_pointer: rawptr) ---
	clEnqueueSVMFreeARM :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       num_svm_pointers: cl_uint,
                                       svm_pointers: []rawptr,
                                       pfn_free_func: #type proc "stdcall" (queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, user_data: rawptr),
                                       user_data: rawptr,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: cl_event,
                                       event: cl_event) -> cl_int ---
	clEnqueueSVMMemcpyARM :: proc "stdcall" (
                                         command_queue: cl_command_queue,
                                         blocking_copy: cl_bool,
                                         dst_ptr: rawptr,
                                         src_ptr: rawptr,
                                         size: c.size_t,
                                         num_events_in_wait_list: cl_uint,
                                         event_wait_list: cl_event,
                                         event: cl_event) -> cl_int ---
	clEnqueueSVMMemFillARM :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          svm_ptr: rawptr,
                                          pattern: rawptr,
                                          pattern_size: c.size_t,
                                          size: c.size_t,
                                          num_events_in_wait_list: cl_uint,
                                          event_wait_list: cl_event,
                                          event: cl_event) -> cl_int ---
	clEnqueueSVMMapARM :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      blocking_map: cl_bool,
                                      flags: cl_map_flags,
                                      svm_ptr: rawptr,
                                      size: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: cl_event,
                                      event: cl_event) -> cl_int ---
	clEnqueueSVMUnmapARM :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        svm_ptr: rawptr,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: cl_event,
                                        event: cl_event) -> cl_int ---
	clSetKernelArgSVMPointerARM :: proc "stdcall" (
                                               kernel: cl_kernel,
                                               arg_index: cl_uint,
                                               arg_value: rawptr) -> cl_int ---
	clSetKernelExecInfoARM :: proc "stdcall" (
                                          kernel: cl_kernel,
                                          param_name: cl_kernel_exec_info_arm,
                                          param_value_size: c.size_t,
                                          param_value: rawptr) -> cl_int ---
	clCreateAcceleratorINTEL :: proc "stdcall" (
                                            _context: cl_context,
                                            accelerator_type: cl_accelerator_type_intel,
                                            descriptor_size: c.size_t,
                                            descriptor: rawptr,
                                            errcode_ret: cl_int) -> cl_accelerator_intel ---
	clGetAcceleratorInfoINTEL :: proc "stdcall" (
                                             accelerator: cl_accelerator_intel,
                                             param_name: cl_accelerator_info_intel,
                                             param_value_size: c.size_t,
                                             param_value: rawptr,
                                             param_value_size_ret: c.size_t) -> cl_int ---
	clRetainAcceleratorINTEL :: proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int ---
	clReleaseAcceleratorINTEL :: proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int ---
	clHostMemAllocINTEL :: proc "stdcall" (
                                       _context: cl_context,
                                       properties: cl_mem_properties_intel,
                                       size: c.size_t,
                                       alignment: cl_uint,
                                       errcode_ret: cl_int) -> rawptr ---
	clDeviceMemAllocINTEL :: proc "stdcall" (
                                         _context: cl_context,
                                         device: cl_device_id,
                                         properties: cl_mem_properties_intel,
                                         size: c.size_t,
                                         alignment: cl_uint,
                                         errcode_ret: cl_int) -> rawptr ---
	clSharedMemAllocINTEL :: proc "stdcall" (
                                         _context: cl_context,
                                         device: cl_device_id,
                                         properties: cl_mem_properties_intel,
                                         size: c.size_t,
                                         alignment: cl_uint,
                                         errcode_ret: cl_int) -> rawptr ---
	clMemFreeINTEL :: proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int ---
	clMemBlockingFreeINTEL :: proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int ---
	clGetMemAllocInfoINTEL :: proc "stdcall" (
                                          _context: cl_context,
                                          ptr: rawptr,
                                          param_name: cl_mem_info_intel,
                                          param_value_size: c.size_t,
                                          param_value: rawptr,
                                          param_value_size_ret: c.size_t) -> cl_int ---
	clSetKernelArgMemPointerINTEL :: proc "stdcall" (
                                                 kernel: cl_kernel,
                                                 arg_index: cl_uint,
                                                 arg_value: rawptr) -> cl_int ---
	clEnqueueMemFillINTEL :: proc "stdcall" (
                                         command_queue: cl_command_queue,
                                         dst_ptr: rawptr,
                                         pattern: rawptr,
                                         pattern_size: c.size_t,
                                         size: c.size_t,
                                         num_events_in_wait_list: cl_uint,
                                         event_wait_list: cl_event,
                                         event: cl_event) -> cl_int ---
	clEnqueueMemcpyINTEL :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        blocking: cl_bool,
                                        dst_ptr: rawptr,
                                        src_ptr: rawptr,
                                        size: c.size_t,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: cl_event,
                                        event: cl_event) -> cl_int ---
	clEnqueueMemAdviseINTEL :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           ptr: rawptr,
                                           size: c.size_t,
                                           advice: cl_mem_advice_intel,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: cl_event,
                                           event: cl_event) -> cl_int ---
	clEnqueueMigrateMemINTEL :: proc "stdcall" (
                                            command_queue: cl_command_queue,
                                            ptr: rawptr,
                                            size: c.size_t,
                                            flags: cl_mem_migration_flags,
                                            num_events_in_wait_list: cl_uint,
                                            event_wait_list: cl_event,
                                            event: cl_event) -> cl_int ---
	clEnqueueMemsetINTEL :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        dst_ptr: rawptr,
                                        value: cl_int,
                                        size: c.size_t,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: cl_event,
                                        event: cl_event) -> cl_int ---
	clCreateBufferWithPropertiesINTEL :: proc "stdcall" (
                                                     _context: cl_context,
                                                     properties: cl_mem_properties_intel,
                                                     flags: cl_mem_flags,
                                                     size: c.size_t,
                                                     host_ptr: rawptr,
                                                     errcode_ret: cl_int) -> cl_mem ---
	clEnqueueReadHostPipeINTEL :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              program: cl_program,
                                              pipe_symbol: c.schar,
                                              blocking_read: cl_bool,
                                              ptr: rawptr,
                                              size: c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: cl_event,
                                              event: cl_event) -> cl_int ---
	clEnqueueWriteHostPipeINTEL :: proc "stdcall" (
                                               command_queue: cl_command_queue,
                                               program: cl_program,
                                               pipe_symbol: c.schar,
                                               blocking_write: cl_bool,
                                               ptr: rawptr,
                                               size: c.size_t,
                                               num_events_in_wait_list: cl_uint,
                                               event_wait_list: cl_event,
                                               event: cl_event) -> cl_int ---
	clGetImageRequirementsInfoEXT :: proc "stdcall" (
                                                 _context: cl_context,
                                                 properties: cl_mem_properties,
                                                 flags: cl_mem_flags,
                                                 image_format: cl_image_format,
                                                 image_desc: cl_image_desc,
                                                 param_name: cl_image_requirements_info_ext,
                                                 param_value_size: c.size_t,
                                                 param_value: rawptr,
                                                 param_value_size_ret: c.size_t) -> cl_int ---
	clGetICDLoaderInfoOCLICD :: proc "stdcall" (
                                            param_name: cl_icdl_info,
                                            param_value_size: c.size_t,
                                            param_value: rawptr,
                                            param_value_size_ret: c.size_t) -> cl_int ---
	clSetContentSizeBufferPoCL :: proc "stdcall" (buffer: cl_mem, content_size_buffer: cl_mem) -> cl_int ---
	clCancelCommandsIMG :: proc "stdcall" (event_list: cl_event, num_events_in_list: c.size_t) -> cl_int ---
}

        /* =========================================
        *               cl_gl.h
        * ========================================= */
            cl_GLint                                                  :: c.int
cl_GLenum                                                 :: c.uint
cl_GLuint                                                 :: c.uint
cl_gl_context_info                                        :: cl_uint
cl_gl_object_type                                         :: cl_uint
cl_gl_texture_info                                        :: cl_uint
cl_gl_platform_info                                       :: cl_uint
clGetGLContextInfoKHR_t                                   :: #type proc "stdcall" (properties: cl_context_properties, param_name: cl_gl_context_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetGLContextInfoKHR_fn                                  :: clGetGLContextInfoKHR_t
clCreateFromGLBuffer_t                                    :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, bufobj: cl_GLuint, errcode_ret: cl_int) -> cl_mem
clCreateFromGLBuffer_fn                                   :: clCreateFromGLBuffer_t
clCreateFromGLTexture_t                                   :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, target: cl_GLenum, miplevel: cl_GLint, texture: cl_GLuint, errcode_ret: cl_int) -> cl_mem
clCreateFromGLTexture_fn                                  :: clCreateFromGLTexture_t
clCreateFromGLRenderbuffer_t                              :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, renderbuffer: cl_GLuint, errcode_ret: cl_int) -> cl_mem
clCreateFromGLRenderbuffer_fn                             :: clCreateFromGLRenderbuffer_t
clGetGLObjectInfo_t                                       :: #type proc "stdcall" (memobj: cl_mem, gl_object_type: cl_gl_object_type, gl_object_name: cl_GLuint) -> cl_int
clGetGLObjectInfo_fn                                      :: clGetGLObjectInfo_t
clGetGLTextureInfo_t                                      :: #type proc "stdcall" (memobj: cl_mem, param_name: cl_gl_texture_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: c.size_t) -> cl_int
clGetGLTextureInfo_fn                                     :: clGetGLTextureInfo_t
clEnqueueAcquireGLObjects_t                               :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueAcquireGLObjects_fn                              :: clEnqueueAcquireGLObjects_t
clEnqueueReleaseGLObjects_t                               :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: cl_event, event: cl_event) -> cl_int
clEnqueueReleaseGLObjects_fn                              :: clEnqueueReleaseGLObjects_t
clCreateFromGLTexture2D_t                                 :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, target: cl_GLenum, miplevel: cl_GLint, texture: cl_GLuint, errcode_ret: cl_int) -> cl_mem
clCreateFromGLTexture2D_fn                                :: clCreateFromGLTexture2D_t
clCreateFromGLTexture3D_t                                 :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, target: cl_GLenum, miplevel: cl_GLint, texture: cl_GLuint, errcode_ret: cl_int) -> cl_mem
clCreateFromGLTexture3D_fn                                :: clCreateFromGLTexture3D_t
cl_GLsync                                                 :: distinct rawptr
clCreateEventFromGLsyncKHR_t                              :: #type proc "stdcall" (_context: cl_context, sync: cl_GLsync, errcode_ret: cl_int) -> cl_event
clCreateEventFromGLsyncKHR_fn                             :: clCreateEventFromGLsyncKHR_t
clGetSupportedGLTextureFormatsINTEL_t                     :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_type: cl_mem_object_type, num_entries: cl_uint, gl_formats: cl_GLenum, num_texture_formats: cl_uint) -> cl_int
clGetSupportedGLTextureFormatsINTEL_fn                    :: clGetSupportedGLTextureFormatsINTEL_t
foreign opencl {
	clGetGLContextInfoKHR :: proc "stdcall" (
                                         properties: cl_context_properties,
                                         param_name: cl_gl_context_info,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: c.size_t) -> cl_int ---
	clCreateFromGLBuffer :: proc "stdcall" (
                                        _context: cl_context,
                                        flags: cl_mem_flags,
                                        bufobj: cl_GLuint,
                                        errcode_ret: cl_int) -> cl_mem ---
	clCreateFromGLTexture :: proc "stdcall" (
                                         _context: cl_context,
                                         flags: cl_mem_flags,
                                         target: cl_GLenum,
                                         miplevel: cl_GLint,
                                         texture: cl_GLuint,
                                         errcode_ret: cl_int) -> cl_mem ---
	clCreateFromGLRenderbuffer :: proc "stdcall" (
                                              _context: cl_context,
                                              flags: cl_mem_flags,
                                              renderbuffer: cl_GLuint,
                                              errcode_ret: cl_int) -> cl_mem ---
	clGetGLObjectInfo :: proc "stdcall" (
                                     memobj: cl_mem,
                                     gl_object_type: cl_gl_object_type,
                                     gl_object_name: cl_GLuint) -> cl_int ---
	clGetGLTextureInfo :: proc "stdcall" (
                                      memobj: cl_mem,
                                      param_name: cl_gl_texture_info,
                                      param_value_size: c.size_t,
                                      param_value: rawptr,
                                      param_value_size_ret: c.size_t) -> cl_int ---
	clEnqueueAcquireGLObjects :: proc "stdcall" (
                                             command_queue: cl_command_queue,
                                             num_objects: cl_uint,
                                             mem_objects: cl_mem,
                                             num_events_in_wait_list: cl_uint,
                                             event_wait_list: cl_event,
                                             event: cl_event) -> cl_int ---
	clEnqueueReleaseGLObjects :: proc "stdcall" (
                                             command_queue: cl_command_queue,
                                             num_objects: cl_uint,
                                             mem_objects: cl_mem,
                                             num_events_in_wait_list: cl_uint,
                                             event_wait_list: cl_event,
                                             event: cl_event) -> cl_int ---
	clCreateFromGLTexture2D :: proc "stdcall" (
                                           _context: cl_context,
                                           flags: cl_mem_flags,
                                           target: cl_GLenum,
                                           miplevel: cl_GLint,
                                           texture: cl_GLuint,
                                           errcode_ret: cl_int) -> cl_mem ---
	clCreateFromGLTexture3D :: proc "stdcall" (
                                           _context: cl_context,
                                           flags: cl_mem_flags,
                                           target: cl_GLenum,
                                           miplevel: cl_GLint,
                                           texture: cl_GLuint,
                                           errcode_ret: cl_int) -> cl_mem ---
	clCreateEventFromGLsyncKHR :: proc "stdcall" (
                                              _context: cl_context,
                                              sync: cl_GLsync,
                                              errcode_ret: cl_int) -> cl_event ---
	clGetSupportedGLTextureFormatsINTEL :: proc "stdcall" (
                                                       _context: cl_context,
                                                       flags: cl_mem_flags,
                                                       image_type: cl_mem_object_type,
                                                       num_entries: cl_uint,
                                                       gl_formats: cl_GLenum,
                                                       num_texture_formats: cl_uint) -> cl_int ---
}
