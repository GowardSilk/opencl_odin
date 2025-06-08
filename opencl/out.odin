package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"


foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_platform.h
* ========================================= */

CL_CHAR_BIT :: 8
CL_SCHAR_MAX :: 127
CL_SCHAR_MIN :: (-127 - 1)
CL_CHAR_MAX :: CL_SCHAR_MAX
CL_CHAR_MIN :: CL_SCHAR_MIN
CL_UCHAR_MAX :: 255
CL_SHRT_MAX :: 32767
CL_SHRT_MIN :: (-32767 - 1)
CL_USHRT_MAX :: 65535
CL_INT_MAX :: 2147483647
CL_INT_MIN :: (-2147483647 - 1)
CL_UINT_MAX :: 0xffffffff
CL_LONG_MAX :: (cast(cl_long)0x7FFFFFFFFFFFFFFF)
CL_LONG_MIN :: (cast(cl_long)(- 0x7FFFFFFFFFFFFFFF - 1))
CL_ULONG_MAX :: (cast(cl_ulong)0xFFFFFFFFFFFFFFFF)
CL_FLT_DIG :: 6
CL_FLT_MANT_DIG :: 24
CL_FLT_MAX_10_EXP :: +38
CL_FLT_MAX_EXP :: +128
CL_FLT_MIN_10_EXP :: -37
CL_FLT_MIN_EXP :: -125
CL_FLT_RADIX :: 2
CL_FLT_MAX :: 340282346638528859811704183484516925440.0
CL_FLT_MIN :: 1.175494350822287507969e-38
CL_FLT_EPSILON :: 1.1920928955078125e-7
CL_HALF_DIG :: 3
CL_HALF_MANT_DIG :: 11
CL_HALF_MAX_10_EXP :: +4
CL_HALF_MAX_EXP :: +16
CL_HALF_MIN_10_EXP :: -4
CL_HALF_MIN_EXP :: -13
CL_HALF_RADIX :: 2
CL_HALF_MAX :: 65504.0
CL_HALF_MIN :: 6.103515625e-05
CL_HALF_EPSILON :: 9.765625e-04
CL_DBL_DIG :: 15
CL_DBL_MANT_DIG :: 53
CL_DBL_MAX_10_EXP :: +308
CL_DBL_MAX_EXP :: +1024
CL_DBL_MIN_10_EXP :: -307
CL_DBL_MIN_EXP :: -1021
CL_DBL_RADIX :: 2
CL_DBL_MAX :: 1.7976931348623158e+308
CL_DBL_MIN :: 2.225073858507201383090e-308
CL_DBL_EPSILON :: 2.220446049250313080847e-16
CL_M_E :: 2.7182818284590452354
CL_M_LOG2E :: 1.4426950408889634074
CL_M_LOG10E :: 0.43429448190325182765
CL_M_LN2 :: 0.69314718055994530942
CL_M_LN10 :: 2.30258509299404568402
CL_M_PI :: 3.14159265358979323846
CL_M_PI_2 :: 1.57079632679489661923
CL_M_PI_4 :: 0.78539816339744830962
CL_M_1_PI :: 0.31830988618379067154
CL_M_2_PI :: 0.63661977236758134308
CL_M_2_SQRTPI :: 1.12837916709551257390
CL_M_SQRT2 :: 1.41421356237309504880
CL_M_SQRT1_2 :: 0.70710678118654752440
CL_M_E_F :: 2.718281828
CL_M_LOG2E_F :: 1.442695041
CL_M_LOG10E_F :: 0.434294482
CL_M_LN2_F :: 0.693147181
CL_M_LN10_F :: 2.302585093
CL_M_PI_F :: 3.141592654
CL_M_PI_2_F :: 1.570796327
CL_M_PI_4_F :: 0.785398163
CL_M_1_PI_F :: 0.318309886
CL_M_2_PI_F :: 0.636619772
CL_M_2_SQRTPI_F :: 1.128379167
CL_M_SQRT2_F :: 1.414213562
CL_M_SQRT1_2_F :: 0.707106781
CL_NAN :: (CL_INFINITY - CL_INFINITY)
CL_HUGE_VALF :: (cast(cl_float)1e50)
CL_HUGE_VAL :: (cast(cl_double)1e500)
CL_MAXFLOAT :: CL_FLT_MAX
CL_INFINITY :: CL_HUGE_VALF
__CL_FLOAT4__ :: 1
__CL_UCHAR16__ :: 1
__CL_CHAR16__ :: 1
__CL_USHORT8__ :: 1
__CL_SHORT8__ :: 1
__CL_INT4__ :: 1
__CL_UINT4__ :: 1
__CL_ULONG2__ :: 1
__CL_LONG2__ :: 1
__CL_DOUBLE2__ :: 1
__CL_UCHAR8__ :: 1
__CL_CHAR8__ :: 1
__CL_USHORT4__ :: 1
__CL_SHORT4__ :: 1
__CL_INT2__ :: 1
__CL_UINT2__ :: 1
__CL_ULONG1__ :: 1
__CL_LONG1__ :: 1
__CL_FLOAT2__ :: 1
__CL_HAS_ANON_STRUCT__ :: 1
CL_HAS_NAMED_VECTOR_FIELDS :: 1
CL_HAS_HI_LO_VECTOR_FIELDS :: 1

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

/* =========================================
*               cl_version.h
* ========================================= */

CL_TARGET_OPENCL_VERSION :: 300
CL_VERSION_3_0 :: 1
CL_VERSION_2_2 :: 1
CL_VERSION_2_1 :: 1
CL_VERSION_2_0 :: 1
CL_VERSION_1_2 :: 1
CL_VERSION_1_1 :: 1
CL_VERSION_1_0 :: 1


/* =========================================
*               cl.h
* ========================================= */

CL_NAME_VERSION_MAX_NAME_SIZE :: 64
CL_SUCCESS :: 0
CL_DEVICE_NOT_FOUND :: -1
CL_DEVICE_NOT_AVAILABLE :: -2
CL_COMPILER_NOT_AVAILABLE :: -3
CL_MEM_OBJECT_ALLOCATION_FAILURE :: -4
CL_OUT_OF_RESOURCES :: -5
CL_OUT_OF_HOST_MEMORY :: -6
CL_PROFILING_INFO_NOT_AVAILABLE :: -7
CL_MEM_COPY_OVERLAP :: -8
CL_IMAGE_FORMAT_MISMATCH :: -9
CL_IMAGE_FORMAT_NOT_SUPPORTED :: -10
CL_BUILD_PROGRAM_FAILURE :: -11
CL_MAP_FAILURE :: -12
CL_MISALIGNED_SUB_BUFFER_OFFSET :: -13
CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST :: -14
CL_COMPILE_PROGRAM_FAILURE :: -15
CL_LINKER_NOT_AVAILABLE :: -16
CL_LINK_PROGRAM_FAILURE :: -17
CL_DEVICE_PARTITION_FAILED :: -18
CL_KERNEL_ARG_INFO_NOT_AVAILABLE :: -19
CL_INVALID_VALUE :: -30
CL_INVALID_DEVICE_TYPE :: -31
CL_INVALID_PLATFORM :: -32
CL_INVALID_DEVICE :: -33
CL_INVALID_CONTEXT :: -34
CL_INVALID_QUEUE_PROPERTIES :: -35
CL_INVALID_COMMAND_QUEUE :: -36
CL_INVALID_HOST_PTR :: -37
CL_INVALID_MEM_OBJECT :: -38
CL_INVALID_IMAGE_FORMAT_DESCRIPTOR :: -39
CL_INVALID_IMAGE_SIZE :: -40
CL_INVALID_SAMPLER :: -41
CL_INVALID_BINARY :: -42
CL_INVALID_BUILD_OPTIONS :: -43
CL_INVALID_PROGRAM :: -44
CL_INVALID_PROGRAM_EXECUTABLE :: -45
CL_INVALID_KERNEL_NAME :: -46
CL_INVALID_KERNEL_DEFINITION :: -47
CL_INVALID_KERNEL :: -48
CL_INVALID_ARG_INDEX :: -49
CL_INVALID_ARG_VALUE :: -50
CL_INVALID_ARG_SIZE :: -51
CL_INVALID_KERNEL_ARGS :: -52
CL_INVALID_WORK_DIMENSION :: -53
CL_INVALID_WORK_GROUP_SIZE :: -54
CL_INVALID_WORK_ITEM_SIZE :: -55
CL_INVALID_GLOBAL_OFFSET :: -56
CL_INVALID_EVENT_WAIT_LIST :: -57
CL_INVALID_EVENT :: -58
CL_INVALID_OPERATION :: -59
CL_INVALID_GL_OBJECT :: -60
CL_INVALID_BUFFER_SIZE :: -61
CL_INVALID_MIP_LEVEL :: -62
CL_INVALID_GLOBAL_WORK_SIZE :: -63
CL_INVALID_PROPERTY :: -64
CL_INVALID_IMAGE_DESCRIPTOR :: -65
CL_INVALID_COMPILER_OPTIONS :: -66
CL_INVALID_LINKER_OPTIONS :: -67
CL_INVALID_DEVICE_PARTITION_COUNT :: -68
CL_INVALID_PIPE_SIZE :: -69
CL_INVALID_DEVICE_QUEUE :: -70
CL_INVALID_SPEC_ID :: -71
CL_MAX_SIZE_RESTRICTION_EXCEEDED :: -72
CL_FALSE :: 0
CL_TRUE :: 1
CL_BLOCKING :: CL_TRUE
CL_NON_BLOCKING :: CL_FALSE
CL_PLATFORM_PROFILE :: 0x0900
CL_PLATFORM_VERSION :: 0x0901
CL_PLATFORM_NAME :: 0x0902
CL_PLATFORM_VENDOR :: 0x0903
CL_PLATFORM_EXTENSIONS :: 0x0904
CL_PLATFORM_HOST_TIMER_RESOLUTION :: 0x0905
CL_PLATFORM_NUMERIC_VERSION :: 0x0906
CL_PLATFORM_EXTENSIONS_WITH_VERSION :: 0x0907
CL_DEVICE_TYPE_DEFAULT :: (1 << 0)
CL_DEVICE_TYPE_CPU :: (1 << 1)
CL_DEVICE_TYPE_GPU :: (1 << 2)
CL_DEVICE_TYPE_ACCELERATOR :: (1 << 3)
CL_DEVICE_TYPE_CUSTOM :: (1 << 4)
CL_DEVICE_TYPE_ALL :: 0xFFFFFFFF
CL_DEVICE_TYPE :: 0x1000
CL_DEVICE_VENDOR_ID :: 0x1001
CL_DEVICE_MAX_COMPUTE_UNITS :: 0x1002
CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS :: 0x1003
CL_DEVICE_MAX_WORK_GROUP_SIZE :: 0x1004
CL_DEVICE_MAX_WORK_ITEM_SIZES :: 0x1005
CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR :: 0x1006
CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT :: 0x1007
CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT :: 0x1008
CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG :: 0x1009
CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT :: 0x100A
CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE :: 0x100B
CL_DEVICE_MAX_CLOCK_FREQUENCY :: 0x100C
CL_DEVICE_ADDRESS_BITS :: 0x100D
CL_DEVICE_MAX_READ_IMAGE_ARGS :: 0x100E
CL_DEVICE_MAX_WRITE_IMAGE_ARGS :: 0x100F
CL_DEVICE_MAX_MEM_ALLOC_SIZE :: 0x1010
CL_DEVICE_IMAGE2D_MAX_WIDTH :: 0x1011
CL_DEVICE_IMAGE2D_MAX_HEIGHT :: 0x1012
CL_DEVICE_IMAGE3D_MAX_WIDTH :: 0x1013
CL_DEVICE_IMAGE3D_MAX_HEIGHT :: 0x1014
CL_DEVICE_IMAGE3D_MAX_DEPTH :: 0x1015
CL_DEVICE_IMAGE_SUPPORT :: 0x1016
CL_DEVICE_MAX_PARAMETER_SIZE :: 0x1017
CL_DEVICE_MAX_SAMPLERS :: 0x1018
CL_DEVICE_MEM_BASE_ADDR_ALIGN :: 0x1019
CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE :: 0x101A
CL_DEVICE_SINGLE_FP_CONFIG :: 0x101B
CL_DEVICE_GLOBAL_MEM_CACHE_TYPE :: 0x101C
CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE :: 0x101D
CL_DEVICE_GLOBAL_MEM_CACHE_SIZE :: 0x101E
CL_DEVICE_GLOBAL_MEM_SIZE :: 0x101F
CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE :: 0x1020
CL_DEVICE_MAX_CONSTANT_ARGS :: 0x1021
CL_DEVICE_LOCAL_MEM_TYPE :: 0x1022
CL_DEVICE_LOCAL_MEM_SIZE :: 0x1023
CL_DEVICE_ERROR_CORRECTION_SUPPORT :: 0x1024
CL_DEVICE_PROFILING_TIMER_RESOLUTION :: 0x1025
CL_DEVICE_ENDIAN_LITTLE :: 0x1026
CL_DEVICE_AVAILABLE :: 0x1027
CL_DEVICE_COMPILER_AVAILABLE :: 0x1028
CL_DEVICE_EXECUTION_CAPABILITIES :: 0x1029
CL_DEVICE_QUEUE_PROPERTIES :: 0x102A
CL_DEVICE_QUEUE_ON_HOST_PROPERTIES :: 0x102A
CL_DEVICE_NAME :: 0x102B
CL_DEVICE_VENDOR :: 0x102C
CL_DRIVER_VERSION :: 0x102D
CL_DEVICE_PROFILE :: 0x102E
CL_DEVICE_VERSION :: 0x102F
CL_DEVICE_EXTENSIONS :: 0x1030
CL_DEVICE_PLATFORM :: 0x1031
CL_DEVICE_DOUBLE_FP_CONFIG :: 0x1032
CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF :: 0x1034
CL_DEVICE_HOST_UNIFIED_MEMORY :: 0x1035
CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR :: 0x1036
CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT :: 0x1037
CL_DEVICE_NATIVE_VECTOR_WIDTH_INT :: 0x1038
CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG :: 0x1039
CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT :: 0x103A
CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE :: 0x103B
CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF :: 0x103C
CL_DEVICE_OPENCL_C_VERSION :: 0x103D
CL_DEVICE_LINKER_AVAILABLE :: 0x103E
CL_DEVICE_BUILT_IN_KERNELS :: 0x103F
CL_DEVICE_IMAGE_MAX_BUFFER_SIZE :: 0x1040
CL_DEVICE_IMAGE_MAX_ARRAY_SIZE :: 0x1041
CL_DEVICE_PARENT_DEVICE :: 0x1042
CL_DEVICE_PARTITION_MAX_SUB_DEVICES :: 0x1043
CL_DEVICE_PARTITION_PROPERTIES :: 0x1044
CL_DEVICE_PARTITION_AFFINITY_DOMAIN :: 0x1045
CL_DEVICE_PARTITION_TYPE :: 0x1046
CL_DEVICE_REFERENCE_COUNT :: 0x1047
CL_DEVICE_PREFERRED_INTEROP_USER_SYNC :: 0x1048
CL_DEVICE_PRINTF_BUFFER_SIZE :: 0x1049
CL_DEVICE_IMAGE_PITCH_ALIGNMENT :: 0x104A
CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT :: 0x104B
CL_DEVICE_MAX_READ_WRITE_IMAGE_ARGS :: 0x104C
CL_DEVICE_MAX_GLOBAL_VARIABLE_SIZE :: 0x104D
CL_DEVICE_QUEUE_ON_DEVICE_PROPERTIES :: 0x104E
CL_DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE :: 0x104F
CL_DEVICE_QUEUE_ON_DEVICE_MAX_SIZE :: 0x1050
CL_DEVICE_MAX_ON_DEVICE_QUEUES :: 0x1051
CL_DEVICE_MAX_ON_DEVICE_EVENTS :: 0x1052
CL_DEVICE_SVM_CAPABILITIES :: 0x1053
CL_DEVICE_GLOBAL_VARIABLE_PREFERRED_TOTAL_SIZE :: 0x1054
CL_DEVICE_MAX_PIPE_ARGS :: 0x1055
CL_DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS :: 0x1056
CL_DEVICE_PIPE_MAX_PACKET_SIZE :: 0x1057
CL_DEVICE_PREFERRED_PLATFORM_ATOMIC_ALIGNMENT :: 0x1058
CL_DEVICE_PREFERRED_GLOBAL_ATOMIC_ALIGNMENT :: 0x1059
CL_DEVICE_PREFERRED_LOCAL_ATOMIC_ALIGNMENT :: 0x105A
CL_DEVICE_IL_VERSION :: 0x105B
CL_DEVICE_MAX_NUM_SUB_GROUPS :: 0x105C
CL_DEVICE_SUB_GROUP_INDEPENDENT_FORWARD_PROGRESS :: 0x105D
CL_DEVICE_NUMERIC_VERSION :: 0x105E
CL_DEVICE_EXTENSIONS_WITH_VERSION :: 0x1060
CL_DEVICE_ILS_WITH_VERSION :: 0x1061
CL_DEVICE_BUILT_IN_KERNELS_WITH_VERSION :: 0x1062
CL_DEVICE_ATOMIC_MEMORY_CAPABILITIES :: 0x1063
CL_DEVICE_ATOMIC_FENCE_CAPABILITIES :: 0x1064
CL_DEVICE_NON_UNIFORM_WORK_GROUP_SUPPORT :: 0x1065
CL_DEVICE_OPENCL_C_ALL_VERSIONS :: 0x1066
CL_DEVICE_PREFERRED_WORK_GROUP_SIZE_MULTIPLE :: 0x1067
CL_DEVICE_WORK_GROUP_COLLECTIVE_FUNCTIONS_SUPPORT :: 0x1068
CL_DEVICE_GENERIC_ADDRESS_SPACE_SUPPORT :: 0x1069
CL_DEVICE_OPENCL_C_FEATURES :: 0x106F
CL_DEVICE_DEVICE_ENQUEUE_CAPABILITIES :: 0x1070
CL_DEVICE_PIPE_SUPPORT :: 0x1071
CL_DEVICE_LATEST_CONFORMANCE_VERSION_PASSED :: 0x1072
CL_FP_DENORM :: (1 << 0)
CL_FP_INF_NAN :: (1 << 1)
CL_FP_ROUND_TO_NEAREST :: (1 << 2)
CL_FP_ROUND_TO_ZERO :: (1 << 3)
CL_FP_ROUND_TO_INF :: (1 << 4)
CL_FP_FMA :: (1 << 5)
CL_FP_SOFT_FLOAT :: (1 << 6)
CL_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT :: (1 << 7)
CL_NONE :: 0x0
CL_READ_ONLY_CACHE :: 0x1
CL_READ_WRITE_CACHE :: 0x2
CL_LOCAL :: 0x1
CL_GLOBAL :: 0x2
CL_EXEC_KERNEL :: (1 << 0)
CL_EXEC_NATIVE_KERNEL :: (1 << 1)
CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE :: (1 << 0)
CL_QUEUE_PROFILING_ENABLE :: (1 << 1)
CL_QUEUE_ON_DEVICE :: (1 << 2)
CL_QUEUE_ON_DEVICE_DEFAULT :: (1 << 3)
CL_CONTEXT_REFERENCE_COUNT :: 0x1080
CL_CONTEXT_DEVICES :: 0x1081
CL_CONTEXT_PROPERTIES :: 0x1082
CL_CONTEXT_NUM_DEVICES :: 0x1083
CL_CONTEXT_PLATFORM :: 0x1084
CL_CONTEXT_INTEROP_USER_SYNC :: 0x1085
CL_DEVICE_PARTITION_EQUALLY :: 0x1086
CL_DEVICE_PARTITION_BY_COUNTS :: 0x1087
CL_DEVICE_PARTITION_BY_COUNTS_LIST_END :: 0x0
CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN :: 0x1088
CL_DEVICE_AFFINITY_DOMAIN_NUMA :: (1 << 0)
CL_DEVICE_AFFINITY_DOMAIN_L4_CACHE :: (1 << 1)
CL_DEVICE_AFFINITY_DOMAIN_L3_CACHE :: (1 << 2)
CL_DEVICE_AFFINITY_DOMAIN_L2_CACHE :: (1 << 3)
CL_DEVICE_AFFINITY_DOMAIN_L1_CACHE :: (1 << 4)
CL_DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE :: (1 << 5)
CL_DEVICE_SVM_COARSE_GRAIN_BUFFER :: (1 << 0)
CL_DEVICE_SVM_FINE_GRAIN_BUFFER :: (1 << 1)
CL_DEVICE_SVM_FINE_GRAIN_SYSTEM :: (1 << 2)
CL_DEVICE_SVM_ATOMICS :: (1 << 3)
CL_QUEUE_CONTEXT :: 0x1090
CL_QUEUE_DEVICE :: 0x1091
CL_QUEUE_REFERENCE_COUNT :: 0x1092
CL_QUEUE_PROPERTIES :: 0x1093
CL_QUEUE_SIZE :: 0x1094
CL_QUEUE_DEVICE_DEFAULT :: 0x1095
CL_QUEUE_PROPERTIES_ARRAY :: 0x1098
CL_MEM_READ_WRITE :: (1 << 0)
CL_MEM_WRITE_ONLY :: (1 << 1)
CL_MEM_READ_ONLY :: (1 << 2)
CL_MEM_USE_HOST_PTR :: (1 << 3)
CL_MEM_ALLOC_HOST_PTR :: (1 << 4)
CL_MEM_COPY_HOST_PTR :: (1 << 5)
CL_MEM_HOST_WRITE_ONLY :: (1 << 7)
CL_MEM_HOST_READ_ONLY :: (1 << 8)
CL_MEM_HOST_NO_ACCESS :: (1 << 9)
CL_MEM_SVM_FINE_GRAIN_BUFFER :: (1 << 10)
CL_MEM_SVM_ATOMICS :: (1 << 11)
CL_MEM_KERNEL_READ_AND_WRITE :: (1 << 12)
CL_MIGRATE_MEM_OBJECT_HOST :: (1 << 0)
CL_MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED :: (1 << 1)
CL_R :: 0x10B0
CL_A :: 0x10B1
CL_RG :: 0x10B2
CL_RA :: 0x10B3
CL_RGB :: 0x10B4
CL_RGBA :: 0x10B5
CL_BGRA :: 0x10B6
CL_ARGB :: 0x10B7
CL_INTENSITY :: 0x10B8
CL_LUMINANCE :: 0x10B9
CL_Rx :: 0x10BA
CL_RGx :: 0x10BB
CL_RGBx :: 0x10BC
CL_DEPTH :: 0x10BD
CL_sRGB :: 0x10BF
CL_sRGBx :: 0x10C0
CL_sRGBA :: 0x10C1
CL_sBGRA :: 0x10C2
CL_ABGR :: 0x10C3
CL_SNORM_INT8 :: 0x10D0
CL_SNORM_INT16 :: 0x10D1
CL_UNORM_INT8 :: 0x10D2
CL_UNORM_INT16 :: 0x10D3
CL_UNORM_SHORT_565 :: 0x10D4
CL_UNORM_SHORT_555 :: 0x10D5
CL_UNORM_INT_101010 :: 0x10D6
CL_SIGNED_INT8 :: 0x10D7
CL_SIGNED_INT16 :: 0x10D8
CL_SIGNED_INT32 :: 0x10D9
CL_UNSIGNED_INT8 :: 0x10DA
CL_UNSIGNED_INT16 :: 0x10DB
CL_UNSIGNED_INT32 :: 0x10DC
CL_HALF_FLOAT :: 0x10DD
CL_FLOAT :: 0x10DE
CL_UNORM_INT_101010_2 :: 0x10E0
CL_MEM_OBJECT_BUFFER :: 0x10F0
CL_MEM_OBJECT_IMAGE2D :: 0x10F1
CL_MEM_OBJECT_IMAGE3D :: 0x10F2
CL_MEM_OBJECT_IMAGE2D_ARRAY :: 0x10F3
CL_MEM_OBJECT_IMAGE1D :: 0x10F4
CL_MEM_OBJECT_IMAGE1D_ARRAY :: 0x10F5
CL_MEM_OBJECT_IMAGE1D_BUFFER :: 0x10F6
CL_MEM_OBJECT_PIPE :: 0x10F7
CL_MEM_TYPE :: 0x1100
CL_MEM_FLAGS :: 0x1101
CL_MEM_SIZE :: 0x1102
CL_MEM_HOST_PTR :: 0x1103
CL_MEM_MAP_COUNT :: 0x1104
CL_MEM_REFERENCE_COUNT :: 0x1105
CL_MEM_CONTEXT :: 0x1106
CL_MEM_ASSOCIATED_MEMOBJECT :: 0x1107
CL_MEM_OFFSET :: 0x1108
CL_MEM_USES_SVM_POINTER :: 0x1109
CL_MEM_PROPERTIES :: 0x110A
CL_IMAGE_FORMAT :: 0x1110
CL_IMAGE_ELEMENT_SIZE :: 0x1111
CL_IMAGE_ROW_PITCH :: 0x1112
CL_IMAGE_SLICE_PITCH :: 0x1113
CL_IMAGE_WIDTH :: 0x1114
CL_IMAGE_HEIGHT :: 0x1115
CL_IMAGE_DEPTH :: 0x1116
CL_IMAGE_ARRAY_SIZE :: 0x1117
CL_IMAGE_BUFFER :: 0x1118
CL_IMAGE_NUM_MIP_LEVELS :: 0x1119
CL_IMAGE_NUM_SAMPLES :: 0x111A
CL_PIPE_PACKET_SIZE :: 0x1120
CL_PIPE_MAX_PACKETS :: 0x1121
CL_PIPE_PROPERTIES :: 0x1122
CL_ADDRESS_NONE :: 0x1130
CL_ADDRESS_CLAMP_TO_EDGE :: 0x1131
CL_ADDRESS_CLAMP :: 0x1132
CL_ADDRESS_REPEAT :: 0x1133
CL_ADDRESS_MIRRORED_REPEAT :: 0x1134
CL_FILTER_NEAREST :: 0x1140
CL_FILTER_LINEAR :: 0x1141
CL_SAMPLER_REFERENCE_COUNT :: 0x1150
CL_SAMPLER_CONTEXT :: 0x1151
CL_SAMPLER_NORMALIZED_COORDS :: 0x1152
CL_SAMPLER_ADDRESSING_MODE :: 0x1153
CL_SAMPLER_FILTER_MODE :: 0x1154
CL_SAMPLER_MIP_FILTER_MODE :: 0x1155
CL_SAMPLER_LOD_MIN :: 0x1156
CL_SAMPLER_LOD_MAX :: 0x1157
CL_SAMPLER_PROPERTIES :: 0x1158
CL_MAP_READ :: (1 << 0)
CL_MAP_WRITE :: (1 << 1)
CL_MAP_WRITE_INVALIDATE_REGION :: (1 << 2)
CL_PROGRAM_REFERENCE_COUNT :: 0x1160
CL_PROGRAM_CONTEXT :: 0x1161
CL_PROGRAM_NUM_DEVICES :: 0x1162
CL_PROGRAM_DEVICES :: 0x1163
CL_PROGRAM_SOURCE :: 0x1164
CL_PROGRAM_BINARY_SIZES :: 0x1165
CL_PROGRAM_BINARIES :: 0x1166
CL_PROGRAM_NUM_KERNELS :: 0x1167
CL_PROGRAM_KERNEL_NAMES :: 0x1168
CL_PROGRAM_IL :: 0x1169
CL_PROGRAM_SCOPE_GLOBAL_CTORS_PRESENT :: 0x116A
CL_PROGRAM_SCOPE_GLOBAL_DTORS_PRESENT :: 0x116B
CL_PROGRAM_BUILD_STATUS :: 0x1181
CL_PROGRAM_BUILD_OPTIONS :: 0x1182
CL_PROGRAM_BUILD_LOG :: 0x1183
CL_PROGRAM_BINARY_TYPE :: 0x1184
CL_PROGRAM_BUILD_GLOBAL_VARIABLE_TOTAL_SIZE :: 0x1185
CL_PROGRAM_BINARY_TYPE_NONE :: 0x0
CL_PROGRAM_BINARY_TYPE_COMPILED_OBJECT :: 0x1
CL_PROGRAM_BINARY_TYPE_LIBRARY :: 0x2
CL_PROGRAM_BINARY_TYPE_EXECUTABLE :: 0x4
CL_BUILD_SUCCESS :: 0
CL_BUILD_NONE :: -1
CL_BUILD_ERROR :: -2
CL_BUILD_IN_PROGRESS :: -3
CL_KERNEL_FUNCTION_NAME :: 0x1190
CL_KERNEL_NUM_ARGS :: 0x1191
CL_KERNEL_REFERENCE_COUNT :: 0x1192
CL_KERNEL_CONTEXT :: 0x1193
CL_KERNEL_PROGRAM :: 0x1194
CL_KERNEL_ATTRIBUTES :: 0x1195
CL_KERNEL_ARG_ADDRESS_QUALIFIER :: 0x1196
CL_KERNEL_ARG_ACCESS_QUALIFIER :: 0x1197
CL_KERNEL_ARG_TYPE_NAME :: 0x1198
CL_KERNEL_ARG_TYPE_QUALIFIER :: 0x1199
CL_KERNEL_ARG_NAME :: 0x119A
CL_KERNEL_ARG_ADDRESS_GLOBAL :: 0x119B
CL_KERNEL_ARG_ADDRESS_LOCAL :: 0x119C
CL_KERNEL_ARG_ADDRESS_CONSTANT :: 0x119D
CL_KERNEL_ARG_ADDRESS_PRIVATE :: 0x119E
CL_KERNEL_ARG_ACCESS_READ_ONLY :: 0x11A0
CL_KERNEL_ARG_ACCESS_WRITE_ONLY :: 0x11A1
CL_KERNEL_ARG_ACCESS_READ_WRITE :: 0x11A2
CL_KERNEL_ARG_ACCESS_NONE :: 0x11A3
CL_KERNEL_ARG_TYPE_NONE :: 0
CL_KERNEL_ARG_TYPE_CONST :: (1 << 0)
CL_KERNEL_ARG_TYPE_RESTRICT :: (1 << 1)
CL_KERNEL_ARG_TYPE_VOLATILE :: (1 << 2)
CL_KERNEL_ARG_TYPE_PIPE :: (1 << 3)
CL_KERNEL_WORK_GROUP_SIZE :: 0x11B0
CL_KERNEL_COMPILE_WORK_GROUP_SIZE :: 0x11B1
CL_KERNEL_LOCAL_MEM_SIZE :: 0x11B2
CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE :: 0x11B3
CL_KERNEL_PRIVATE_MEM_SIZE :: 0x11B4
CL_KERNEL_GLOBAL_WORK_SIZE :: 0x11B5
CL_KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE :: 0x2033
CL_KERNEL_SUB_GROUP_COUNT_FOR_NDRANGE :: 0x2034
CL_KERNEL_LOCAL_SIZE_FOR_SUB_GROUP_COUNT :: 0x11B8
CL_KERNEL_MAX_NUM_SUB_GROUPS :: 0x11B9
CL_KERNEL_COMPILE_NUM_SUB_GROUPS :: 0x11BA
CL_KERNEL_EXEC_INFO_SVM_PTRS :: 0x11B6
CL_KERNEL_EXEC_INFO_SVM_FINE_GRAIN_SYSTEM :: 0x11B7
CL_EVENT_COMMAND_QUEUE :: 0x11D0
CL_EVENT_COMMAND_TYPE :: 0x11D1
CL_EVENT_REFERENCE_COUNT :: 0x11D2
CL_EVENT_COMMAND_EXECUTION_STATUS :: 0x11D3
CL_EVENT_CONTEXT :: 0x11D4
CL_COMMAND_NDRANGE_KERNEL :: 0x11F0
CL_COMMAND_TASK :: 0x11F1
CL_COMMAND_NATIVE_KERNEL :: 0x11F2
CL_COMMAND_READ_BUFFER :: 0x11F3
CL_COMMAND_WRITE_BUFFER :: 0x11F4
CL_COMMAND_COPY_BUFFER :: 0x11F5
CL_COMMAND_READ_IMAGE :: 0x11F6
CL_COMMAND_WRITE_IMAGE :: 0x11F7
CL_COMMAND_COPY_IMAGE :: 0x11F8
CL_COMMAND_COPY_IMAGE_TO_BUFFER :: 0x11F9
CL_COMMAND_COPY_BUFFER_TO_IMAGE :: 0x11FA
CL_COMMAND_MAP_BUFFER :: 0x11FB
CL_COMMAND_MAP_IMAGE :: 0x11FC
CL_COMMAND_UNMAP_MEM_OBJECT :: 0x11FD
CL_COMMAND_MARKER :: 0x11FE
CL_COMMAND_ACQUIRE_GL_OBJECTS :: 0x11FF
CL_COMMAND_RELEASE_GL_OBJECTS :: 0x1200
CL_COMMAND_READ_BUFFER_RECT :: 0x1201
CL_COMMAND_WRITE_BUFFER_RECT :: 0x1202
CL_COMMAND_COPY_BUFFER_RECT :: 0x1203
CL_COMMAND_USER :: 0x1204
CL_COMMAND_BARRIER :: 0x1205
CL_COMMAND_MIGRATE_MEM_OBJECTS :: 0x1206
CL_COMMAND_FILL_BUFFER :: 0x1207
CL_COMMAND_FILL_IMAGE :: 0x1208
CL_COMMAND_SVM_FREE :: 0x1209
CL_COMMAND_SVM_MEMCPY :: 0x120A
CL_COMMAND_SVM_MEMFILL :: 0x120B
CL_COMMAND_SVM_MAP :: 0x120C
CL_COMMAND_SVM_UNMAP :: 0x120D
CL_COMMAND_SVM_MIGRATE_MEM :: 0x120E
CL_COMPLETE :: 0x0
CL_RUNNING :: 0x1
CL_SUBMITTED :: 0x2
CL_QUEUED :: 0x3
CL_BUFFER_CREATE_TYPE_REGION :: 0x1220
CL_PROFILING_COMMAND_QUEUED :: 0x1280
CL_PROFILING_COMMAND_SUBMIT :: 0x1281
CL_PROFILING_COMMAND_START :: 0x1282
CL_PROFILING_COMMAND_END :: 0x1283
CL_PROFILING_COMMAND_COMPLETE :: 0x1284
CL_DEVICE_ATOMIC_ORDER_RELAXED :: (1 << 0)
CL_DEVICE_ATOMIC_ORDER_ACQ_REL :: (1 << 1)
CL_DEVICE_ATOMIC_ORDER_SEQ_CST :: (1 << 2)
CL_DEVICE_ATOMIC_SCOPE_WORK_ITEM :: (1 << 3)
CL_DEVICE_ATOMIC_SCOPE_WORK_GROUP :: (1 << 4)
CL_DEVICE_ATOMIC_SCOPE_DEVICE :: (1 << 5)
CL_DEVICE_ATOMIC_SCOPE_ALL_DEVICES :: (1 << 6)
CL_DEVICE_QUEUE_SUPPORTED :: (1 << 0)
CL_DEVICE_QUEUE_REPLACEABLE_DEFAULT :: (1 << 1)
CL_KHRONOS_VENDOR_ID_CODEPLAY :: 0x10004
CL_VERSION_MAJOR_BITS :: (10)
CL_VERSION_MINOR_BITS :: (10)
CL_VERSION_PATCH_BITS :: (12)
CL_VERSION_MAJOR_MASK :: ((1 << CL_VERSION_MAJOR_BITS) - 1)
CL_VERSION_MINOR_MASK :: ((1 << CL_VERSION_MINOR_BITS) - 1)
CL_VERSION_PATCH_MASK :: ((1 << CL_VERSION_PATCH_BITS) - 1)
CL_VERSION_MAJOR :: #force_inline proc(#any_int version: u64) -> u64 { return ((version) >> (CL_VERSION_MINOR_BITS + CL_VERSION_PATCH_BITS)); }
CL_VERSION_MINOR :: #force_inline proc(#any_int version: u64) -> u64 { return (((version) >> CL_VERSION_PATCH_BITS) & CL_VERSION_MINOR_MASK); }
CL_VERSION_PATCH :: #force_inline proc(#any_int version: u64) -> u64 { return ((version) & CL_VERSION_PATCH_MASK); }
CL_MAKE_VERSION :: #force_inline proc(#any_int major, minor, patch: u64) -> u64 {
    return ((((major) & CL_VERSION_MAJOR_MASK) << (CL_VERSION_MINOR_BITS + CL_VERSION_PATCH_BITS)) | (((minor) & CL_VERSION_MINOR_MASK) << CL_VERSION_PATCH_BITS) | ((patch) & CL_VERSION_PATCH_MASK));
}

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
                                    platforms: ^cl_platform_id,
                                    num_platforms: ^cl_uint) -> cl_int ---
	clGetPlatformInfo :: proc "stdcall" (
                                     platform: cl_platform_id,
                                     param_name: cl_platform_info,
                                     param_value_size: c.size_t,
                                     param_value: rawptr,
                                     param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetDeviceIDs :: proc "stdcall" (
                                  platform: cl_platform_id,
                                  device_type: cl_device_type,
                                  num_entries: cl_uint,
                                  devices: ^cl_device_id,
                                  num_devices: ^cl_uint) -> cl_int ---
	clGetDeviceInfo :: proc "stdcall" (
                                   device: cl_device_id,
                                   param_name: cl_device_info,
                                   param_value_size: c.size_t,
                                   param_value: rawptr,
                                   param_value_size_ret: ^c.size_t) -> cl_int ---
	clCreateSubDevices :: proc "stdcall" (
                                      in_device: cl_device_id,
                                      properties: ^cl_device_partition_property,
                                      num_devices: cl_uint,
                                      out_devices: ^cl_device_id,
                                      num_devices_ret: ^cl_uint) -> cl_int ---
	clRetainDevice :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clReleaseDevice :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clSetDefaultDeviceCommandQueue :: proc "stdcall" (
                                                  _context: cl_context,
                                                  device: cl_device_id,
                                                  command_queue: cl_command_queue) -> cl_int ---
	clGetDeviceAndHostTimer :: proc "stdcall" (
                                           device: cl_device_id,
                                           device_timestamp: ^cl_ulong,
                                           host_timestamp: ^cl_ulong) -> cl_int ---
	clGetHostTimer :: proc "stdcall" (device: cl_device_id, host_timestamp: ^cl_ulong) -> cl_int ---
	clCreateContext :: proc "stdcall" (
                                   properties: ^cl_context_properties,
                                   num_devices: cl_uint,
                                   devices: ^cl_device_id,
                                   pfn_notify: #type proc "stdcall" (errinfo: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr),
                                   user_data: rawptr,
                                   errcode_ret: ^cl_int) -> cl_context ---
	clCreateContextFromType :: proc "stdcall" (
                                           properties: ^cl_context_properties,
                                           device_type: cl_device_type,
                                           pfn_notify: #type proc "stdcall" (errinfo: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr),
                                           user_data: rawptr,
                                           errcode_ret: ^cl_int) -> cl_context ---
	clRetainContext :: proc "stdcall" (_context: cl_context) -> cl_int ---
	clReleaseContext :: proc "stdcall" (_context: cl_context) -> cl_int ---
	clGetContextInfo :: proc "stdcall" (
                                    _context: cl_context,
                                    param_name: cl_context_info,
                                    param_value_size: c.size_t,
                                    param_value: rawptr,
                                    param_value_size_ret: ^c.size_t) -> cl_int ---
	clSetContextDestructorCallback :: proc "stdcall" (
                                                  _context: cl_context,
                                                  pfn_notify: #type proc "stdcall" (_context: cl_context, user_data: rawptr),
                                                  user_data: rawptr) -> cl_int ---
	clCreateCommandQueueWithProperties :: proc "stdcall" (
                                                      _context: cl_context,
                                                      device: cl_device_id,
                                                      properties: ^cl_queue_properties,
                                                      errcode_ret: ^cl_int) -> cl_command_queue ---
	clRetainCommandQueue :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clReleaseCommandQueue :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clGetCommandQueueInfo :: proc "stdcall" (
                                         command_queue: cl_command_queue,
                                         param_name: cl_command_queue_info,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: ^c.size_t) -> cl_int ---
	clCreateBuffer :: proc "stdcall" (
                                  _context: cl_context,
                                  flags: cl_mem_flags,
                                  size: c.size_t,
                                  host_ptr: rawptr,
                                  errcode_ret: ^cl_int) -> cl_mem ---
	clCreateSubBuffer :: proc "stdcall" (
                                     buffer: cl_mem,
                                     flags: cl_mem_flags,
                                     buffer_create_type: cl_buffer_create_type,
                                     buffer_create_info: rawptr,
                                     errcode_ret: ^cl_int) -> cl_mem ---
	clCreateImage :: proc "stdcall" (
                                 _context: cl_context,
                                 flags: cl_mem_flags,
                                 image_format: ^cl_image_format,
                                 image_desc: ^cl_image_desc,
                                 host_ptr: rawptr,
                                 errcode_ret: ^cl_int) -> cl_mem ---
	clCreatePipe :: proc "stdcall" (
                                _context: cl_context,
                                flags: cl_mem_flags,
                                pipe_packet_size: cl_uint,
                                pipe_max_packets: cl_uint,
                                properties: ^cl_pipe_properties,
                                errcode_ret: ^cl_int) -> cl_mem ---
	clCreateBufferWithProperties :: proc "stdcall" (
                                                _context: cl_context,
                                                properties: ^cl_mem_properties,
                                                flags: cl_mem_flags,
                                                size: c.size_t,
                                                host_ptr: rawptr,
                                                errcode_ret: ^cl_int) -> cl_mem ---
	clCreateImageWithProperties :: proc "stdcall" (
                                               _context: cl_context,
                                               properties: ^cl_mem_properties,
                                               flags: cl_mem_flags,
                                               image_format: ^cl_image_format,
                                               image_desc: ^cl_image_desc,
                                               host_ptr: rawptr,
                                               errcode_ret: ^cl_int) -> cl_mem ---
	clRetainMemObject :: proc "stdcall" (memobj: cl_mem) -> cl_int ---
	clReleaseMemObject :: proc "stdcall" (memobj: cl_mem) -> cl_int ---
	clGetSupportedImageFormats :: proc "stdcall" (
                                              _context: cl_context,
                                              flags: cl_mem_flags,
                                              image_type: cl_mem_object_type,
                                              num_entries: cl_uint,
                                              image_formats: ^cl_image_format,
                                              num_image_formats: ^cl_uint) -> cl_int ---
	clGetMemObjectInfo :: proc "stdcall" (
                                      memobj: cl_mem,
                                      param_name: cl_mem_info,
                                      param_value_size: c.size_t,
                                      param_value: rawptr,
                                      param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetImageInfo :: proc "stdcall" (
                                  image: cl_mem,
                                  param_name: cl_image_info,
                                  param_value_size: c.size_t,
                                  param_value: rawptr,
                                  param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetPipeInfo :: proc "stdcall" (
                                 pipe: cl_mem,
                                 param_name: cl_pipe_info,
                                 param_value_size: c.size_t,
                                 param_value: rawptr,
                                 param_value_size_ret: ^c.size_t) -> cl_int ---
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
                                                 sampler_properties: ^cl_sampler_properties,
                                                 errcode_ret: ^cl_int) -> cl_sampler ---
	clRetainSampler :: proc "stdcall" (sampler: cl_sampler) -> cl_int ---
	clReleaseSampler :: proc "stdcall" (sampler: cl_sampler) -> cl_int ---
	clGetSamplerInfo :: proc "stdcall" (
                                    sampler: cl_sampler,
                                    param_name: cl_sampler_info,
                                    param_value_size: c.size_t,
                                    param_value: rawptr,
                                    param_value_size_ret: ^c.size_t) -> cl_int ---
	clCreateProgramWithSource :: proc "stdcall" (
                                             _context: cl_context,
                                             count: cl_uint,
                                             strings: ^^c.schar,
                                             lengths: ^c.size_t,
                                             errcode_ret: ^cl_int) -> cl_program ---
	clCreateProgramWithBinary :: proc "stdcall" (
                                             _context: cl_context,
                                             num_devices: cl_uint,
                                             device_list: ^cl_device_id,
                                             lengths: ^c.size_t,
                                             binaries: ^^c.char,
                                             binary_status: ^cl_int,
                                             errcode_ret: ^cl_int) -> cl_program ---
	clCreateProgramWithBuiltInKernels :: proc "stdcall" (
                                                     _context: cl_context,
                                                     num_devices: cl_uint,
                                                     device_list: ^cl_device_id,
                                                     kernel_names: ^c.schar,
                                                     errcode_ret: ^cl_int) -> cl_program ---
	clCreateProgramWithIL :: proc "stdcall" (
                                         _context: cl_context,
                                         il: rawptr,
                                         length: c.size_t,
                                         errcode_ret: ^cl_int) -> cl_program ---
	clRetainProgram :: proc "stdcall" (program: cl_program) -> cl_int ---
	clReleaseProgram :: proc "stdcall" (program: cl_program) -> cl_int ---
	clBuildProgram :: proc "stdcall" (
                                  program: cl_program,
                                  num_devices: cl_uint,
                                  device_list: ^cl_device_id,
                                  options: ^c.schar,
                                  pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr),
                                  user_data: rawptr) -> cl_int ---
	clCompileProgram :: proc "stdcall" (
                                    program: cl_program,
                                    num_devices: cl_uint,
                                    device_list: ^cl_device_id,
                                    options: ^c.schar,
                                    num_input_headers: cl_uint,
                                    input_headers: ^cl_program,
                                    header_include_names: ^^c.schar,
                                    pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr),
                                    user_data: rawptr) -> cl_int ---
	clLinkProgram :: proc "stdcall" (
                                 _context: cl_context,
                                 num_devices: cl_uint,
                                 device_list: ^cl_device_id,
                                 options: ^c.schar,
                                 num_input_programs: cl_uint,
                                 input_programs: ^cl_program,
                                 pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr),
                                 user_data: rawptr,
                                 errcode_ret: ^cl_int) -> cl_program ---
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
                                    param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetProgramBuildInfo :: proc "stdcall" (
                                         program: cl_program,
                                         device: cl_device_id,
                                         param_name: cl_program_build_info,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: ^c.size_t) -> cl_int ---
	clCreateKernel :: proc "stdcall" (
                                  program: cl_program,
                                  kernel_name: ^c.schar,
                                  errcode_ret: ^cl_int) -> cl_kernel ---
	clCreateKernelsInProgram :: proc "stdcall" (
                                            program: cl_program,
                                            num_kernels: cl_uint,
                                            kernels: ^cl_kernel,
                                            num_kernels_ret: ^cl_uint) -> cl_int ---
	clCloneKernel :: proc "stdcall" (source_kernel: cl_kernel, errcode_ret: ^cl_int) -> cl_kernel ---
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
                                   param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetKernelArgInfo :: proc "stdcall" (
                                      kernel: cl_kernel,
                                      arg_indx: cl_uint,
                                      param_name: cl_kernel_arg_info,
                                      param_value_size: c.size_t,
                                      param_value: rawptr,
                                      param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetKernelWorkGroupInfo :: proc "stdcall" (
                                            kernel: cl_kernel,
                                            device: cl_device_id,
                                            param_name: cl_kernel_work_group_info,
                                            param_value_size: c.size_t,
                                            param_value: rawptr,
                                            param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetKernelSubGroupInfo :: proc "stdcall" (
                                           kernel: cl_kernel,
                                           device: cl_device_id,
                                           param_name: cl_kernel_sub_group_info,
                                           input_value_size: c.size_t,
                                           input_value: rawptr,
                                           param_value_size: c.size_t,
                                           param_value: rawptr,
                                           param_value_size_ret: ^c.size_t) -> cl_int ---
	clWaitForEvents :: proc "stdcall" (num_events: cl_uint, event_list: ^cl_event) -> cl_int ---
	clGetEventInfo :: proc "stdcall" (
                                  event: cl_event,
                                  param_name: cl_event_info,
                                  param_value_size: c.size_t,
                                  param_value: rawptr,
                                  param_value_size_ret: ^c.size_t) -> cl_int ---
	clCreateUserEvent :: proc "stdcall" (_context: cl_context, errcode_ret: ^cl_int) -> cl_event ---
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
                                           param_value_size_ret: ^c.size_t) -> cl_int ---
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
                                       event_wait_list: ^cl_event,
                                       event: ^cl_event) -> cl_int ---
	clEnqueueReadBufferRect :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           buffer: cl_mem,
                                           blocking_read: cl_bool,
                                           buffer_origin: ^c.size_t,
                                           host_origin: ^c.size_t,
                                           region: ^c.size_t,
                                           buffer_row_pitch: c.size_t,
                                           buffer_slice_pitch: c.size_t,
                                           host_row_pitch: c.size_t,
                                           host_slice_pitch: c.size_t,
                                           ptr: rawptr,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: ^cl_event,
                                           event: ^cl_event) -> cl_int ---
	clEnqueueWriteBuffer :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        buffer: cl_mem,
                                        blocking_write: cl_bool,
                                        offset: c.size_t,
                                        size: c.size_t,
                                        ptr: rawptr,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: ^cl_event,
                                        event: ^cl_event) -> cl_int ---
	clEnqueueWriteBufferRect :: proc "stdcall" (
                                            command_queue: cl_command_queue,
                                            buffer: cl_mem,
                                            blocking_write: cl_bool,
                                            buffer_origin: ^c.size_t,
                                            host_origin: ^c.size_t,
                                            region: ^c.size_t,
                                            buffer_row_pitch: c.size_t,
                                            buffer_slice_pitch: c.size_t,
                                            host_row_pitch: c.size_t,
                                            host_slice_pitch: c.size_t,
                                            ptr: rawptr,
                                            num_events_in_wait_list: cl_uint,
                                            event_wait_list: ^cl_event,
                                            event: ^cl_event) -> cl_int ---
	clEnqueueFillBuffer :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       buffer: cl_mem,
                                       pattern: rawptr,
                                       pattern_size: c.size_t,
                                       offset: c.size_t,
                                       size: c.size_t,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: ^cl_event,
                                       event: ^cl_event) -> cl_int ---
	clEnqueueCopyBuffer :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       src_buffer: cl_mem,
                                       dst_buffer: cl_mem,
                                       src_offset: c.size_t,
                                       dst_offset: c.size_t,
                                       size: c.size_t,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: ^cl_event,
                                       event: ^cl_event) -> cl_int ---
	clEnqueueCopyBufferRect :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           src_buffer: cl_mem,
                                           dst_buffer: cl_mem,
                                           src_origin: ^c.size_t,
                                           dst_origin: ^c.size_t,
                                           region: ^c.size_t,
                                           src_row_pitch: c.size_t,
                                           src_slice_pitch: c.size_t,
                                           dst_row_pitch: c.size_t,
                                           dst_slice_pitch: c.size_t,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: ^cl_event,
                                           event: ^cl_event) -> cl_int ---
	clEnqueueReadImage :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      image: cl_mem,
                                      blocking_read: cl_bool,
                                      origin: ^c.size_t,
                                      region: ^c.size_t,
                                      row_pitch: c.size_t,
                                      slice_pitch: c.size_t,
                                      ptr: rawptr,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: ^cl_event,
                                      event: ^cl_event) -> cl_int ---
	clEnqueueWriteImage :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       image: cl_mem,
                                       blocking_write: cl_bool,
                                       origin: ^c.size_t,
                                       region: ^c.size_t,
                                       input_row_pitch: c.size_t,
                                       input_slice_pitch: c.size_t,
                                       ptr: rawptr,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: ^cl_event,
                                       event: ^cl_event) -> cl_int ---
	clEnqueueFillImage :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      image: cl_mem,
                                      fill_color: rawptr,
                                      origin: ^c.size_t,
                                      region: ^c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: ^cl_event,
                                      event: ^cl_event) -> cl_int ---
	clEnqueueCopyImage :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      src_image: cl_mem,
                                      dst_image: cl_mem,
                                      src_origin: ^c.size_t,
                                      dst_origin: ^c.size_t,
                                      region: ^c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: ^cl_event,
                                      event: ^cl_event) -> cl_int ---
	clEnqueueCopyImageToBuffer :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              src_image: cl_mem,
                                              dst_buffer: cl_mem,
                                              src_origin: ^c.size_t,
                                              region: ^c.size_t,
                                              dst_offset: c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: ^cl_event,
                                              event: ^cl_event) -> cl_int ---
	clEnqueueCopyBufferToImage :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              src_buffer: cl_mem,
                                              dst_image: cl_mem,
                                              src_offset: c.size_t,
                                              dst_origin: ^c.size_t,
                                              region: ^c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: ^cl_event,
                                              event: ^cl_event) -> cl_int ---
	clEnqueueMapBuffer :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      buffer: cl_mem,
                                      blocking_map: cl_bool,
                                      map_flags: cl_map_flags,
                                      offset: c.size_t,
                                      size: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: ^cl_event,
                                      event: ^cl_event,
                                      errcode_ret: ^cl_int) -> rawptr ---
	clEnqueueMapImage :: proc "stdcall" (
                                     command_queue: cl_command_queue,
                                     image: cl_mem,
                                     blocking_map: cl_bool,
                                     map_flags: cl_map_flags,
                                     origin: ^c.size_t,
                                     region: ^c.size_t,
                                     image_row_pitch: ^c.size_t,
                                     image_slice_pitch: ^c.size_t,
                                     num_events_in_wait_list: cl_uint,
                                     event_wait_list: ^cl_event,
                                     event: ^cl_event,
                                     errcode_ret: ^cl_int) -> rawptr ---
	clEnqueueUnmapMemObject :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           memobj: cl_mem,
                                           mapped_ptr: rawptr,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: ^cl_event,
                                           event: ^cl_event) -> cl_int ---
	clEnqueueMigrateMemObjects :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              num_mem_objects: cl_uint,
                                              mem_objects: ^cl_mem,
                                              flags: cl_mem_migration_flags,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: ^cl_event,
                                              event: ^cl_event) -> cl_int ---
	clEnqueueNDRangeKernel :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          kernel: cl_kernel,
                                          work_dim: cl_uint,
                                          global_work_offset: ^c.size_t,
                                          global_work_size: ^c.size_t,
                                          local_work_size: ^c.size_t,
                                          num_events_in_wait_list: cl_uint,
                                          event_wait_list: ^cl_event,
                                          event: ^cl_event) -> cl_int ---
	clEnqueueNativeKernel :: proc "stdcall" (
                                         command_queue: cl_command_queue,
                                         user_func: #type proc "stdcall" (_1: rawptr),
                                         args: rawptr,
                                         cb_args: c.size_t,
                                         num_mem_objects: cl_uint,
                                         mem_list: ^cl_mem,
                                         args_mem_loc: ^rawptr,
                                         num_events_in_wait_list: cl_uint,
                                         event_wait_list: ^cl_event,
                                         event: ^cl_event) -> cl_int ---
	clEnqueueMarkerWithWaitList :: proc "stdcall" (
                                               command_queue: cl_command_queue,
                                               num_events_in_wait_list: cl_uint,
                                               event_wait_list: ^cl_event,
                                               event: ^cl_event) -> cl_int ---
	clEnqueueBarrierWithWaitList :: proc "stdcall" (
                                                command_queue: cl_command_queue,
                                                num_events_in_wait_list: cl_uint,
                                                event_wait_list: ^cl_event,
                                                event: ^cl_event) -> cl_int ---
	clEnqueueSVMFree :: proc "stdcall" (
                                    command_queue: cl_command_queue,
                                    num_svm_pointers: cl_uint,
                                    svm_pointers: []rawptr,
                                    pfn_free_func: #type proc "stdcall" (queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, user_data: rawptr),
                                    user_data: rawptr,
                                    num_events_in_wait_list: cl_uint,
                                    event_wait_list: ^cl_event,
                                    event: ^cl_event) -> cl_int ---
	clEnqueueSVMMemcpy :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      blocking_copy: cl_bool,
                                      dst_ptr: rawptr,
                                      src_ptr: rawptr,
                                      size: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: ^cl_event,
                                      event: ^cl_event) -> cl_int ---
	clEnqueueSVMMemFill :: proc "stdcall" (
                                       command_queue: cl_command_queue,
                                       svm_ptr: rawptr,
                                       pattern: rawptr,
                                       pattern_size: c.size_t,
                                       size: c.size_t,
                                       num_events_in_wait_list: cl_uint,
                                       event_wait_list: ^cl_event,
                                       event: ^cl_event) -> cl_int ---
	clEnqueueSVMMap :: proc "stdcall" (
                                   command_queue: cl_command_queue,
                                   blocking_map: cl_bool,
                                   flags: cl_map_flags,
                                   svm_ptr: rawptr,
                                   size: c.size_t,
                                   num_events_in_wait_list: cl_uint,
                                   event_wait_list: ^cl_event,
                                   event: ^cl_event) -> cl_int ---
	clEnqueueSVMUnmap :: proc "stdcall" (
                                     command_queue: cl_command_queue,
                                     svm_ptr: rawptr,
                                     num_events_in_wait_list: cl_uint,
                                     event_wait_list: ^cl_event,
                                     event: ^cl_event) -> cl_int ---
	clEnqueueSVMMigrateMem :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          num_svm_pointers: cl_uint,
                                          svm_pointers: ^rawptr,
                                          sizes: ^c.size_t,
                                          flags: cl_mem_migration_flags,
                                          num_events_in_wait_list: cl_uint,
                                          event_wait_list: ^cl_event,
                                          event: ^cl_event) -> cl_int ---
	clGetExtensionFunctionAddressForPlatform :: proc "stdcall" (
                                                            platform: cl_platform_id,
                                                            func_name: ^c.schar) -> rawptr ---
	clCreateImage2D :: proc "stdcall" (
                                   _context: cl_context,
                                   flags: cl_mem_flags,
                                   image_format: ^cl_image_format,
                                   image_width: c.size_t,
                                   image_height: c.size_t,
                                   image_row_pitch: c.size_t,
                                   host_ptr: rawptr,
                                   errcode_ret: ^cl_int) -> cl_mem ---
	clCreateImage3D :: proc "stdcall" (
                                   _context: cl_context,
                                   flags: cl_mem_flags,
                                   image_format: ^cl_image_format,
                                   image_width: c.size_t,
                                   image_height: c.size_t,
                                   image_depth: c.size_t,
                                   image_row_pitch: c.size_t,
                                   image_slice_pitch: c.size_t,
                                   host_ptr: rawptr,
                                   errcode_ret: ^cl_int) -> cl_mem ---
	clEnqueueMarker :: proc "stdcall" (command_queue: cl_command_queue, event: ^cl_event) -> cl_int ---
	clEnqueueWaitForEvents :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          num_events: cl_uint,
                                          event_list: ^cl_event) -> cl_int ---
	clEnqueueBarrier :: proc "stdcall" (command_queue: cl_command_queue) -> cl_int ---
	clUnloadCompiler :: proc "stdcall" () -> cl_int ---
	clGetExtensionFunctionAddress :: proc "stdcall" (func_name: ^c.schar) -> rawptr ---
	clCreateCommandQueue :: proc "stdcall" (
                                        _context: cl_context,
                                        device: cl_device_id,
                                        properties: cl_command_queue_properties,
                                        errcode_ret: ^cl_int) -> cl_command_queue ---
	clCreateSampler :: proc "stdcall" (
                                   _context: cl_context,
                                   normalized_coords: cl_bool,
                                   addressing_mode: cl_addressing_mode,
                                   filter_mode: cl_filter_mode,
                                   errcode_ret: ^cl_int) -> cl_sampler ---
	clEnqueueTask :: proc "stdcall" (
                                 command_queue: cl_command_queue,
                                 kernel: cl_kernel,
                                 num_events_in_wait_list: cl_uint,
                                 event_wait_list: ^cl_event,
                                 event: ^cl_event) -> cl_int ---
}
/* =========================================
*               cl_function_types.h
* ========================================= */

clGetPlatformIDs_t                                        :: #type proc "stdcall" (num_entries: cl_uint, platforms: ^cl_platform_id, num_platforms: ^cl_uint) -> cl_int
clGetPlatformIDs_fn                                       :: ^clGetPlatformIDs_t
clGetPlatformInfo_t                                       :: #type proc "stdcall" (platform: cl_platform_id, param_name: cl_platform_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetPlatformInfo_fn                                      :: ^clGetPlatformInfo_t
clGetDeviceIDs_t                                          :: #type proc "stdcall" (platform: cl_platform_id, device_type: cl_device_type, num_entries: cl_uint, devices: ^cl_device_id, num_devices: ^cl_uint) -> cl_int
clGetDeviceIDs_fn                                         :: ^clGetDeviceIDs_t
clGetDeviceInfo_t                                         :: #type proc "stdcall" (device: cl_device_id, param_name: cl_device_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetDeviceInfo_fn                                        :: ^clGetDeviceInfo_t
clCreateContext_t                                         :: #type proc "stdcall" (properties: ^cl_context_properties, num_devices: cl_uint, devices: ^cl_device_id, pfn_notify: #type proc "stdcall" (errinfo: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl_int) -> cl_context
clCreateContext_fn                                        :: ^clCreateContext_t
clCreateContextFromType_t                                 :: #type proc "stdcall" (properties: ^cl_context_properties, device_type: cl_device_type, pfn_notify: #type proc "stdcall" (errinfo: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl_int) -> cl_context
clCreateContextFromType_fn                                :: ^clCreateContextFromType_t
clRetainContext_t                                         :: #type proc "stdcall" (_context: cl_context) -> cl_int
clRetainContext_fn                                        :: ^clRetainContext_t
clReleaseContext_t                                        :: #type proc "stdcall" (_context: cl_context) -> cl_int
clReleaseContext_fn                                       :: ^clReleaseContext_t
clGetContextInfo_t                                        :: #type proc "stdcall" (_context: cl_context, param_name: cl_context_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetContextInfo_fn                                       :: ^clGetContextInfo_t
clRetainCommandQueue_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clRetainCommandQueue_fn                                   :: ^clRetainCommandQueue_t
clReleaseCommandQueue_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clReleaseCommandQueue_fn                                  :: ^clReleaseCommandQueue_t
clGetCommandQueueInfo_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, param_name: cl_command_queue_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetCommandQueueInfo_fn                                  :: ^clGetCommandQueueInfo_t
clCreateBuffer_t                                          :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateBuffer_fn                                         :: ^clCreateBuffer_t
clRetainMemObject_t                                       :: #type proc "stdcall" (memobj: cl_mem) -> cl_int
clRetainMemObject_fn                                      :: ^clRetainMemObject_t
clReleaseMemObject_t                                      :: #type proc "stdcall" (memobj: cl_mem) -> cl_int
clReleaseMemObject_fn                                     :: ^clReleaseMemObject_t
clGetSupportedImageFormats_t                              :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_type: cl_mem_object_type, num_entries: cl_uint, image_formats: ^cl_image_format, num_image_formats: ^cl_uint) -> cl_int
clGetSupportedImageFormats_fn                             :: ^clGetSupportedImageFormats_t
clGetMemObjectInfo_t                                      :: #type proc "stdcall" (memobj: cl_mem, param_name: cl_mem_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetMemObjectInfo_fn                                     :: ^clGetMemObjectInfo_t
clGetImageInfo_t                                          :: #type proc "stdcall" (image: cl_mem, param_name: cl_image_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetImageInfo_fn                                         :: ^clGetImageInfo_t
clRetainSampler_t                                         :: #type proc "stdcall" (sampler: cl_sampler) -> cl_int
clRetainSampler_fn                                        :: ^clRetainSampler_t
clReleaseSampler_t                                        :: #type proc "stdcall" (sampler: cl_sampler) -> cl_int
clReleaseSampler_fn                                       :: ^clReleaseSampler_t
clGetSamplerInfo_t                                        :: #type proc "stdcall" (sampler: cl_sampler, param_name: cl_sampler_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetSamplerInfo_fn                                       :: ^clGetSamplerInfo_t
clCreateProgramWithSource_t                               :: #type proc "stdcall" (_context: cl_context, count: cl_uint, strings: ^^c.schar, lengths: ^c.size_t, errcode_ret: ^cl_int) -> cl_program
clCreateProgramWithSource_fn                              :: ^clCreateProgramWithSource_t
clCreateProgramWithBinary_t                               :: #type proc "stdcall" (_context: cl_context, num_devices: cl_uint, device_list: ^cl_device_id, lengths: ^c.size_t, binaries: ^^c.char, binary_status: ^cl_int, errcode_ret: ^cl_int) -> cl_program
clCreateProgramWithBinary_fn                              :: ^clCreateProgramWithBinary_t
clRetainProgram_t                                         :: #type proc "stdcall" (program: cl_program) -> cl_int
clRetainProgram_fn                                        :: ^clRetainProgram_t
clReleaseProgram_t                                        :: #type proc "stdcall" (program: cl_program) -> cl_int
clReleaseProgram_fn                                       :: ^clReleaseProgram_t
clBuildProgram_t                                          :: #type proc "stdcall" (program: cl_program, num_devices: cl_uint, device_list: ^cl_device_id, options: ^c.schar, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr) -> cl_int
clBuildProgram_fn                                         :: ^clBuildProgram_t
clGetProgramInfo_t                                        :: #type proc "stdcall" (program: cl_program, param_name: cl_program_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetProgramInfo_fn                                       :: ^clGetProgramInfo_t
clGetProgramBuildInfo_t                                   :: #type proc "stdcall" (program: cl_program, device: cl_device_id, param_name: cl_program_build_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetProgramBuildInfo_fn                                  :: ^clGetProgramBuildInfo_t
clCreateKernel_t                                          :: #type proc "stdcall" (program: cl_program, kernel_name: ^c.schar, errcode_ret: ^cl_int) -> cl_kernel
clCreateKernel_fn                                         :: ^clCreateKernel_t
clCreateKernelsInProgram_t                                :: #type proc "stdcall" (program: cl_program, num_kernels: cl_uint, kernels: ^cl_kernel, num_kernels_ret: ^cl_uint) -> cl_int
clCreateKernelsInProgram_fn                               :: ^clCreateKernelsInProgram_t
clRetainKernel_t                                          :: #type proc "stdcall" (kernel: cl_kernel) -> cl_int
clRetainKernel_fn                                         :: ^clRetainKernel_t
clReleaseKernel_t                                         :: #type proc "stdcall" (kernel: cl_kernel) -> cl_int
clReleaseKernel_fn                                        :: ^clReleaseKernel_t
clSetKernelArg_t                                          :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_size: c.size_t, arg_value: rawptr) -> cl_int
clSetKernelArg_fn                                         :: ^clSetKernelArg_t
clGetKernelInfo_t                                         :: #type proc "stdcall" (kernel: cl_kernel, param_name: cl_kernel_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetKernelInfo_fn                                        :: ^clGetKernelInfo_t
clGetKernelWorkGroupInfo_t                                :: #type proc "stdcall" (kernel: cl_kernel, device: cl_device_id, param_name: cl_kernel_work_group_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetKernelWorkGroupInfo_fn                               :: ^clGetKernelWorkGroupInfo_t
clWaitForEvents_t                                         :: #type proc "stdcall" (num_events: cl_uint, event_list: ^cl_event) -> cl_int
clWaitForEvents_fn                                        :: ^clWaitForEvents_t
clGetEventInfo_t                                          :: #type proc "stdcall" (event: cl_event, param_name: cl_event_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetEventInfo_fn                                         :: ^clGetEventInfo_t
clRetainEvent_t                                           :: #type proc "stdcall" (event: cl_event) -> cl_int
clRetainEvent_fn                                          :: ^clRetainEvent_t
clReleaseEvent_t                                          :: #type proc "stdcall" (event: cl_event) -> cl_int
clReleaseEvent_fn                                         :: ^clReleaseEvent_t
clGetEventProfilingInfo_t                                 :: #type proc "stdcall" (event: cl_event, param_name: cl_profiling_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetEventProfilingInfo_fn                                :: ^clGetEventProfilingInfo_t
clFlush_t                                                 :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clFlush_fn                                                :: ^clFlush_t
clFinish_t                                                :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clFinish_fn                                               :: ^clFinish_t
clEnqueueReadBuffer_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_read: cl_bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReadBuffer_fn                                    :: ^clEnqueueReadBuffer_t
clEnqueueWriteBuffer_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_write: cl_bool, offset: c.size_t, size: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueWriteBuffer_fn                                   :: ^clEnqueueWriteBuffer_t
clEnqueueCopyBuffer_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, src_buffer: cl_mem, dst_buffer: cl_mem, src_offset: c.size_t, dst_offset: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueCopyBuffer_fn                                    :: ^clEnqueueCopyBuffer_t
clEnqueueReadImage_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, blocking_read: cl_bool, origin: ^c.size_t, region: ^c.size_t, row_pitch: c.size_t, slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReadImage_fn                                     :: ^clEnqueueReadImage_t
clEnqueueWriteImage_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, blocking_write: cl_bool, origin: ^c.size_t, region: ^c.size_t, input_row_pitch: c.size_t, input_slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueWriteImage_fn                                    :: ^clEnqueueWriteImage_t
clEnqueueCopyImage_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, src_image: cl_mem, dst_image: cl_mem, src_origin: ^c.size_t, dst_origin: ^c.size_t, region: ^c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueCopyImage_fn                                     :: ^clEnqueueCopyImage_t
clEnqueueCopyImageToBuffer_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, src_image: cl_mem, dst_buffer: cl_mem, src_origin: ^c.size_t, region: ^c.size_t, dst_offset: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueCopyImageToBuffer_fn                             :: ^clEnqueueCopyImageToBuffer_t
clEnqueueCopyBufferToImage_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, src_buffer: cl_mem, dst_image: cl_mem, src_offset: c.size_t, dst_origin: ^c.size_t, region: ^c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueCopyBufferToImage_fn                             :: ^clEnqueueCopyBufferToImage_t
clEnqueueMapBuffer_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_map: cl_bool, map_flags: cl_map_flags, offset: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event, errcode_ret: ^cl_int) -> rawptr
clEnqueueMapBuffer_fn                                     :: ^clEnqueueMapBuffer_t
clEnqueueMapImage_t                                       :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, blocking_map: cl_bool, map_flags: cl_map_flags, origin: ^c.size_t, region: ^c.size_t, image_row_pitch: ^c.size_t, image_slice_pitch: ^c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event, errcode_ret: ^cl_int) -> rawptr
clEnqueueMapImage_fn                                      :: ^clEnqueueMapImage_t
clEnqueueUnmapMemObject_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, memobj: cl_mem, mapped_ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueUnmapMemObject_fn                                :: ^clEnqueueUnmapMemObject_t
clEnqueueNDRangeKernel_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, kernel: cl_kernel, work_dim: cl_uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueNDRangeKernel_fn                                 :: ^clEnqueueNDRangeKernel_t
clEnqueueNativeKernel_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, user_func: #type proc "stdcall" (_1: rawptr), args: rawptr, cb_args: c.size_t, num_mem_objects: cl_uint, mem_list: ^cl_mem, args_mem_loc: ^rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueNativeKernel_fn                                  :: ^clEnqueueNativeKernel_t
clSetCommandQueueProperty_t                               :: #type proc "stdcall" (command_queue: cl_command_queue, properties: cl_command_queue_properties, enable: cl_bool, old_properties: ^cl_command_queue_properties) -> cl_int
clSetCommandQueueProperty_fn                              :: ^clSetCommandQueueProperty_t
clCreateImage2D_t                                         :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_format: ^cl_image_format, image_width: c.size_t, image_height: c.size_t, image_row_pitch: c.size_t, host_ptr: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateImage2D_fn                                        :: ^clCreateImage2D_t
clCreateImage3D_t                                         :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_format: ^cl_image_format, image_width: c.size_t, image_height: c.size_t, image_depth: c.size_t, image_row_pitch: c.size_t, image_slice_pitch: c.size_t, host_ptr: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateImage3D_fn                                        :: ^clCreateImage3D_t
clEnqueueMarker_t                                         :: #type proc "stdcall" (command_queue: cl_command_queue, event: ^cl_event) -> cl_int
clEnqueueMarker_fn                                        :: ^clEnqueueMarker_t
clEnqueueWaitForEvents_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, num_events: cl_uint, event_list: ^cl_event) -> cl_int
clEnqueueWaitForEvents_fn                                 :: ^clEnqueueWaitForEvents_t
clEnqueueBarrier_t                                        :: #type proc "stdcall" (command_queue: cl_command_queue) -> cl_int
clEnqueueBarrier_fn                                       :: ^clEnqueueBarrier_t
clUnloadCompiler_t                                        :: #type proc "stdcall" () -> cl_int
clUnloadCompiler_fn                                       :: ^clUnloadCompiler_t
clGetExtensionFunctionAddress_t                           :: #type proc "stdcall" (func_name: ^c.schar) -> rawptr
clGetExtensionFunctionAddress_fn                          :: ^clGetExtensionFunctionAddress_t
clCreateCommandQueue_t                                    :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: cl_command_queue_properties, errcode_ret: ^cl_int) -> cl_command_queue
clCreateCommandQueue_fn                                   :: ^clCreateCommandQueue_t
clCreateSampler_t                                         :: #type proc "stdcall" (_context: cl_context, normalized_coords: cl_bool, addressing_mode: cl_addressing_mode, filter_mode: cl_filter_mode, errcode_ret: ^cl_int) -> cl_sampler
clCreateSampler_fn                                        :: ^clCreateSampler_t
clEnqueueTask_t                                           :: #type proc "stdcall" (command_queue: cl_command_queue, kernel: cl_kernel, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueTask_fn                                          :: ^clEnqueueTask_t
clCreateSubBuffer_t                                       :: #type proc "stdcall" (buffer: cl_mem, flags: cl_mem_flags, buffer_create_type: cl_buffer_create_type, buffer_create_info: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateSubBuffer_fn                                      :: ^clCreateSubBuffer_t
clSetMemObjectDestructorCallback_t                        :: #type proc "stdcall" (memobj: cl_mem, pfn_notify: #type proc "stdcall" (memobj: cl_mem, user_data: rawptr), user_data: rawptr) -> cl_int
clSetMemObjectDestructorCallback_fn                       :: ^clSetMemObjectDestructorCallback_t
clCreateUserEvent_t                                       :: #type proc "stdcall" (_context: cl_context, errcode_ret: ^cl_int) -> cl_event
clCreateUserEvent_fn                                      :: ^clCreateUserEvent_t
clSetUserEventStatus_t                                    :: #type proc "stdcall" (event: cl_event, execution_status: cl_int) -> cl_int
clSetUserEventStatus_fn                                   :: ^clSetUserEventStatus_t
clSetEventCallback_t                                      :: #type proc "stdcall" (event: cl_event, command_exec_callback_type: cl_int, pfn_notify: #type proc "stdcall" (event: cl_event, event_command_status: cl_int, user_data: rawptr), user_data: rawptr) -> cl_int
clSetEventCallback_fn                                     :: ^clSetEventCallback_t
clEnqueueReadBufferRect_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_read: cl_bool, buffer_origin: ^c.size_t, host_origin: ^c.size_t, region: ^c.size_t, buffer_row_pitch: c.size_t, buffer_slice_pitch: c.size_t, host_row_pitch: c.size_t, host_slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReadBufferRect_fn                                :: ^clEnqueueReadBufferRect_t
clEnqueueWriteBufferRect_t                                :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, blocking_write: cl_bool, buffer_origin: ^c.size_t, host_origin: ^c.size_t, region: ^c.size_t, buffer_row_pitch: c.size_t, buffer_slice_pitch: c.size_t, host_row_pitch: c.size_t, host_slice_pitch: c.size_t, ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueWriteBufferRect_fn                               :: ^clEnqueueWriteBufferRect_t
clEnqueueCopyBufferRect_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, src_buffer: cl_mem, dst_buffer: cl_mem, src_origin: ^c.size_t, dst_origin: ^c.size_t, region: ^c.size_t, src_row_pitch: c.size_t, src_slice_pitch: c.size_t, dst_row_pitch: c.size_t, dst_slice_pitch: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueCopyBufferRect_fn                                :: ^clEnqueueCopyBufferRect_t
clCreateSubDevices_t                                      :: #type proc "stdcall" (in_device: cl_device_id, properties: ^cl_device_partition_property, num_devices: cl_uint, out_devices: ^cl_device_id, num_devices_ret: ^cl_uint) -> cl_int
clCreateSubDevices_fn                                     :: ^clCreateSubDevices_t
clRetainDevice_t                                          :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clRetainDevice_fn                                         :: ^clRetainDevice_t
clReleaseDevice_t                                         :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clReleaseDevice_fn                                        :: ^clReleaseDevice_t
clCreateImage_t                                           :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_format: ^cl_image_format, image_desc: ^cl_image_desc, host_ptr: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateImage_fn                                          :: ^clCreateImage_t
clCreateProgramWithBuiltInKernels_t                       :: #type proc "stdcall" (_context: cl_context, num_devices: cl_uint, device_list: ^cl_device_id, kernel_names: ^c.schar, errcode_ret: ^cl_int) -> cl_program
clCreateProgramWithBuiltInKernels_fn                      :: ^clCreateProgramWithBuiltInKernels_t
clCompileProgram_t                                        :: #type proc "stdcall" (program: cl_program, num_devices: cl_uint, device_list: ^cl_device_id, options: ^c.schar, num_input_headers: cl_uint, input_headers: ^cl_program, header_include_names: ^^c.schar, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr) -> cl_int
clCompileProgram_fn                                       :: ^clCompileProgram_t
clLinkProgram_t                                           :: #type proc "stdcall" (_context: cl_context, num_devices: cl_uint, device_list: ^cl_device_id, options: ^c.schar, num_input_programs: cl_uint, input_programs: ^cl_program, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr, errcode_ret: ^cl_int) -> cl_program
clLinkProgram_fn                                          :: ^clLinkProgram_t
clUnloadPlatformCompiler_t                                :: #type proc "stdcall" (platform: cl_platform_id) -> cl_int
clUnloadPlatformCompiler_fn                               :: ^clUnloadPlatformCompiler_t
clGetKernelArgInfo_t                                      :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, param_name: cl_kernel_arg_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetKernelArgInfo_fn                                     :: ^clGetKernelArgInfo_t
clEnqueueFillBuffer_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, buffer: cl_mem, pattern: rawptr, pattern_size: c.size_t, offset: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueFillBuffer_fn                                    :: ^clEnqueueFillBuffer_t
clEnqueueFillImage_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, image: cl_mem, fill_color: rawptr, origin: ^c.size_t, region: ^c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueFillImage_fn                                     :: ^clEnqueueFillImage_t
clEnqueueMigrateMemObjects_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: ^cl_mem, flags: cl_mem_migration_flags, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMigrateMemObjects_fn                             :: ^clEnqueueMigrateMemObjects_t
clEnqueueMarkerWithWaitList_t                             :: #type proc "stdcall" (command_queue: cl_command_queue, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMarkerWithWaitList_fn                            :: ^clEnqueueMarkerWithWaitList_t
clEnqueueBarrierWithWaitList_t                            :: #type proc "stdcall" (command_queue: cl_command_queue, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueBarrierWithWaitList_fn                           :: ^clEnqueueBarrierWithWaitList_t
clGetExtensionFunctionAddressForPlatform_t                :: #type proc "stdcall" (platform: cl_platform_id, func_name: ^c.schar) -> rawptr
clGetExtensionFunctionAddressForPlatform_fn               :: ^clGetExtensionFunctionAddressForPlatform_t
clCreateCommandQueueWithProperties_t                      :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: ^cl_queue_properties, errcode_ret: ^cl_int) -> cl_command_queue
clCreateCommandQueueWithProperties_fn                     :: ^clCreateCommandQueueWithProperties_t
clCreatePipe_t                                            :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, pipe_packet_size: cl_uint, pipe_max_packets: cl_uint, properties: ^cl_pipe_properties, errcode_ret: ^cl_int) -> cl_mem
clCreatePipe_fn                                           :: ^clCreatePipe_t
clGetPipeInfo_t                                           :: #type proc "stdcall" (pipe: cl_mem, param_name: cl_pipe_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetPipeInfo_fn                                          :: ^clGetPipeInfo_t
clSVMAlloc_t                                              :: #type proc "stdcall" (_context: cl_context, flags: cl_svm_mem_flags, size: c.size_t, alignment: cl_uint) -> rawptr
clSVMAlloc_fn                                             :: ^clSVMAlloc_t
clSVMFree_t                                               :: #type proc "stdcall" (_context: cl_context, svm_pointer: rawptr)
clSVMFree_fn                                              :: ^clSVMFree_t
clCreateSamplerWithProperties_t                           :: #type proc "stdcall" (_context: cl_context, sampler_properties: ^cl_sampler_properties, errcode_ret: ^cl_int) -> cl_sampler
clCreateSamplerWithProperties_fn                          :: ^clCreateSamplerWithProperties_t
clSetKernelArgSVMPointer_t                                :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_value: rawptr) -> cl_int
clSetKernelArgSVMPointer_fn                               :: ^clSetKernelArgSVMPointer_t
clSetKernelExecInfo_t                                     :: #type proc "stdcall" (kernel: cl_kernel, param_name: cl_kernel_exec_info, param_value_size: c.size_t, param_value: rawptr) -> cl_int
clSetKernelExecInfo_fn                                    :: ^clSetKernelExecInfo_t
clEnqueueSVMFree_t                                        :: #type proc "stdcall" (command_queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, pfn_free_func: #type proc "stdcall" (queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, user_data: rawptr), user_data: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMFree_fn                                       :: ^clEnqueueSVMFree_t
clEnqueueSVMMemcpy_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_copy: cl_bool, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMMemcpy_fn                                     :: ^clEnqueueSVMMemcpy_t
clEnqueueSVMMemFill_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMMemFill_fn                                    :: ^clEnqueueSVMMemFill_t
clEnqueueSVMMap_t                                         :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_map: cl_bool, flags: cl_map_flags, svm_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMMap_fn                                        :: ^clEnqueueSVMMap_t
clEnqueueSVMUnmap_t                                       :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMUnmap_fn                                      :: ^clEnqueueSVMUnmap_t
clSetDefaultDeviceCommandQueue_t                          :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, command_queue: cl_command_queue) -> cl_int
clSetDefaultDeviceCommandQueue_fn                         :: ^clSetDefaultDeviceCommandQueue_t
clGetDeviceAndHostTimer_t                                 :: #type proc "stdcall" (device: cl_device_id, device_timestamp: ^cl_ulong, host_timestamp: ^cl_ulong) -> cl_int
clGetDeviceAndHostTimer_fn                                :: ^clGetDeviceAndHostTimer_t
clGetHostTimer_t                                          :: #type proc "stdcall" (device: cl_device_id, host_timestamp: ^cl_ulong) -> cl_int
clGetHostTimer_fn                                         :: ^clGetHostTimer_t
clCreateProgramWithIL_t                                   :: #type proc "stdcall" (_context: cl_context, il: rawptr, length: c.size_t, errcode_ret: ^cl_int) -> cl_program
clCreateProgramWithIL_fn                                  :: ^clCreateProgramWithIL_t
clCloneKernel_t                                           :: #type proc "stdcall" (source_kernel: cl_kernel, errcode_ret: ^cl_int) -> cl_kernel
clCloneKernel_fn                                          :: ^clCloneKernel_t
clGetKernelSubGroupInfo_t                                 :: #type proc "stdcall" (kernel: cl_kernel, device: cl_device_id, param_name: cl_kernel_sub_group_info, input_value_size: c.size_t, input_value: rawptr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetKernelSubGroupInfo_fn                                :: ^clGetKernelSubGroupInfo_t
clEnqueueSVMMigrateMem_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: ^rawptr, sizes: ^c.size_t, flags: cl_mem_migration_flags, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMMigrateMem_fn                                 :: ^clEnqueueSVMMigrateMem_t
clSetProgramSpecializationConstant_t                      :: #type proc "stdcall" (program: cl_program, spec_id: cl_uint, spec_size: c.size_t, spec_value: rawptr) -> cl_int
clSetProgramSpecializationConstant_fn                     :: ^clSetProgramSpecializationConstant_t
clSetProgramReleaseCallback_t                             :: #type proc "stdcall" (program: cl_program, pfn_notify: #type proc "stdcall" (program: cl_program, user_data: rawptr), user_data: rawptr) -> cl_int
clSetProgramReleaseCallback_fn                            :: ^clSetProgramReleaseCallback_t
clSetContextDestructorCallback_t                          :: #type proc "stdcall" (_context: cl_context, pfn_notify: #type proc "stdcall" (_context: cl_context, user_data: rawptr), user_data: rawptr) -> cl_int
clSetContextDestructorCallback_fn                         :: ^clSetContextDestructorCallback_t
clCreateBufferWithProperties_t                            :: #type proc "stdcall" (_context: cl_context, properties: ^cl_mem_properties, flags: cl_mem_flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateBufferWithProperties_fn                           :: ^clCreateBufferWithProperties_t
clCreateImageWithProperties_t                             :: #type proc "stdcall" (_context: cl_context, properties: ^cl_mem_properties, flags: cl_mem_flags, image_format: ^cl_image_format, image_desc: ^cl_image_desc, host_ptr: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateImageWithProperties_fn                            :: ^clCreateImageWithProperties_t
/* =========================================
*               cl_d3d11.h
* ========================================= */

cl_khr_d3d11_sharing :: 1
CL_KHR_D3D11_SHARING_EXTENSION_NAME :: "cl_khr_d3d11_sharing"
CL_KHR_D3D11_SHARING_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_INVALID_D3D11_DEVICE_KHR :: -1006
CL_INVALID_D3D11_RESOURCE_KHR :: -1007
CL_D3D11_RESOURCE_ALREADY_ACQUIRED_KHR :: -1008
CL_D3D11_RESOURCE_NOT_ACQUIRED_KHR :: -1009
CL_D3D11_DEVICE_KHR :: 0x4019
CL_D3D11_DXGI_ADAPTER_KHR :: 0x401A
CL_PREFERRED_DEVICES_FOR_D3D11_KHR :: 0x401B
CL_ALL_DEVICES_FOR_D3D11_KHR :: 0x401C
CL_CONTEXT_D3D11_DEVICE_KHR :: 0x401D
CL_CONTEXT_D3D11_PREFER_SHARED_RESOURCES_KHR :: 0x402D
CL_MEM_D3D11_RESOURCE_KHR :: 0x401E
CL_IMAGE_D3D11_SUBRESOURCE_KHR :: 0x401F
CL_COMMAND_ACQUIRE_D3D11_OBJECTS_KHR :: 0x4020
CL_COMMAND_RELEASE_D3D11_OBJECTS_KHR :: 0x4021
cl_intel_sharing_format_query_d3d11 :: 1
CL_INTEL_SHARING_FORMAT_QUERY_D3D11_EXTENSION_NAME :: "cl_intel_sharing_format_query_d3d11"
CL_INTEL_SHARING_FORMAT_QUERY_D3D11_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)

cl_d3d11_device_source_khr                                :: cl_uint
cl_d3d11_device_set_khr                                   :: cl_uint
clGetDeviceIDsFromD3D11KHR_t                              :: #type proc "stdcall" (platform: cl_platform_id, d3d_device_source: cl_d3d11_device_source_khr, d3d_object: rawptr, d3d_device_set: cl_d3d11_device_set_khr, num_entries: cl_uint, devices: ^cl_device_id, num_devices: ^cl_uint) -> cl_int
clGetDeviceIDsFromD3D11KHR_fn                             :: ^clGetDeviceIDsFromD3D11KHR_t
clCreateFromD3D11BufferKHR_t                              :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, resource: ^d3d11.IBuffer, errcode_ret: ^cl_int) -> cl_mem
clCreateFromD3D11BufferKHR_fn                             :: ^clCreateFromD3D11BufferKHR_t
clCreateFromD3D11Texture2DKHR_t                           :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, resource: ^d3d11.ITexture2D, subresource: dxgi.UINT, errcode_ret: ^cl_int) -> cl_mem
clCreateFromD3D11Texture2DKHR_fn                          :: ^clCreateFromD3D11Texture2DKHR_t
clCreateFromD3D11Texture3DKHR_t                           :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, resource: ^d3d11.ITexture3D, subresource: dxgi.UINT, errcode_ret: ^cl_int) -> cl_mem
clCreateFromD3D11Texture3DKHR_fn                          :: ^clCreateFromD3D11Texture3DKHR_t
clEnqueueAcquireD3D11ObjectsKHR_t                         :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueAcquireD3D11ObjectsKHR_fn                        :: ^clEnqueueAcquireD3D11ObjectsKHR_t
clEnqueueReleaseD3D11ObjectsKHR_t                         :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReleaseD3D11ObjectsKHR_fn                        :: ^clEnqueueReleaseD3D11ObjectsKHR_t
clGetSupportedD3D11TextureFormatsINTEL_t                  :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_type: cl_mem_object_type, plane: cl_uint, num_entries: cl_uint, d3d11_formats: ^dxgi.FORMAT, num_texture_formats: ^cl_uint) -> cl_int
clGetSupportedD3D11TextureFormatsINTEL_fn                 :: ^clGetSupportedD3D11TextureFormatsINTEL_t

foreign opencl {
	clGetDeviceIDsFromD3D11KHR :: proc "stdcall" (
                                              platform: cl_platform_id,
                                              d3d_device_source: cl_d3d11_device_source_khr,
                                              d3d_object: rawptr,
                                              d3d_device_set: cl_d3d11_device_set_khr,
                                              num_entries: cl_uint,
                                              devices: ^cl_device_id,
                                              num_devices: ^cl_uint) -> cl_int ---
	clCreateFromD3D11BufferKHR :: proc "stdcall" (
                                              _context: cl_context,
                                              flags: cl_mem_flags,
                                              resource: ^d3d11.IBuffer,
                                              errcode_ret: ^cl_int) -> cl_mem ---
	clCreateFromD3D11Texture2DKHR :: proc "stdcall" (
                                                 _context: cl_context,
                                                 flags: cl_mem_flags,
                                                 resource: ^d3d11.ITexture2D,
                                                 subresource: dxgi.UINT,
                                                 errcode_ret: ^cl_int) -> cl_mem ---
	clCreateFromD3D11Texture3DKHR :: proc "stdcall" (
                                                 _context: cl_context,
                                                 flags: cl_mem_flags,
                                                 resource: ^d3d11.ITexture3D,
                                                 subresource: dxgi.UINT,
                                                 errcode_ret: ^cl_int) -> cl_mem ---
	clEnqueueAcquireD3D11ObjectsKHR :: proc "stdcall" (
                                                   command_queue: cl_command_queue,
                                                   num_objects: cl_uint,
                                                   mem_objects: ^cl_mem,
                                                   num_events_in_wait_list: cl_uint,
                                                   event_wait_list: ^cl_event,
                                                   event: ^cl_event) -> cl_int ---
	clEnqueueReleaseD3D11ObjectsKHR :: proc "stdcall" (
                                                   command_queue: cl_command_queue,
                                                   num_objects: cl_uint,
                                                   mem_objects: ^cl_mem,
                                                   num_events_in_wait_list: cl_uint,
                                                   event_wait_list: ^cl_event,
                                                   event: ^cl_event) -> cl_int ---
	clGetSupportedD3D11TextureFormatsINTEL :: proc "stdcall" (
                                                          _context: cl_context,
                                                          flags: cl_mem_flags,
                                                          image_type: cl_mem_object_type,
                                                          plane: cl_uint,
                                                          num_entries: cl_uint,
                                                          d3d11_formats: ^dxgi.FORMAT,
                                                          num_texture_formats: ^cl_uint) -> cl_int ---
}
/* =========================================
*               cl_ext.h
* ========================================= */

cl_khr_command_buffer :: 1
CL_KHR_COMMAND_BUFFER_EXTENSION_NAME :: "cl_khr_command_buffer"
CL_KHR_COMMAND_BUFFER_EXTENSION_VERSION := CL_MAKE_VERSION(0, 9, 5)
CL_DEVICE_COMMAND_BUFFER_CAPABILITIES_KHR :: 0x12A9
CL_DEVICE_COMMAND_BUFFER_REQUIRED_QUEUE_PROPERTIES_KHR :: 0x12AA
CL_COMMAND_BUFFER_CAPABILITY_KERNEL_PRINTF_KHR :: (1 << 0)
CL_COMMAND_BUFFER_CAPABILITY_DEVICE_SIDE_ENQUEUE_KHR :: (1 << 1)
CL_COMMAND_BUFFER_CAPABILITY_SIMULTANEOUS_USE_KHR :: (1 << 2)
CL_COMMAND_BUFFER_CAPABILITY_OUT_OF_ORDER_KHR :: (1 << 3)
CL_COMMAND_BUFFER_FLAGS_KHR :: 0x1293
CL_COMMAND_BUFFER_SIMULTANEOUS_USE_KHR :: (1 << 0)
CL_INVALID_COMMAND_BUFFER_KHR :: -1138
CL_INVALID_SYNC_POINT_WAIT_LIST_KHR :: -1139
CL_INCOMPATIBLE_COMMAND_QUEUE_KHR :: -1140
CL_COMMAND_BUFFER_QUEUES_KHR :: 0x1294
CL_COMMAND_BUFFER_NUM_QUEUES_KHR :: 0x1295
CL_COMMAND_BUFFER_REFERENCE_COUNT_KHR :: 0x1296
CL_COMMAND_BUFFER_STATE_KHR :: 0x1297
CL_COMMAND_BUFFER_PROPERTIES_ARRAY_KHR :: 0x1298
CL_COMMAND_BUFFER_CONTEXT_KHR :: 0x1299
CL_COMMAND_BUFFER_STATE_RECORDING_KHR :: 0
CL_COMMAND_BUFFER_STATE_EXECUTABLE_KHR :: 1
CL_COMMAND_BUFFER_STATE_PENDING_KHR :: 2
CL_COMMAND_COMMAND_BUFFER_KHR :: 0x12A8
cl_khr_command_buffer_multi_device :: 1
CL_KHR_COMMAND_BUFFER_MULTI_DEVICE_EXTENSION_NAME :: "cl_khr_command_buffer_multi_device"
CL_KHR_COMMAND_BUFFER_MULTI_DEVICE_EXTENSION_VERSION := CL_MAKE_VERSION(0, 9, 1)
CL_PLATFORM_COMMAND_BUFFER_CAPABILITIES_KHR :: 0x0908
CL_COMMAND_BUFFER_PLATFORM_UNIVERSAL_SYNC_KHR :: (1 << 0)
CL_COMMAND_BUFFER_PLATFORM_REMAP_QUEUES_KHR :: (1 << 1)
CL_COMMAND_BUFFER_PLATFORM_AUTOMATIC_REMAP_KHR :: (1 << 2)
CL_DEVICE_COMMAND_BUFFER_NUM_SYNC_DEVICES_KHR :: 0x12AB
CL_DEVICE_COMMAND_BUFFER_SYNC_DEVICES_KHR :: 0x12AC
CL_COMMAND_BUFFER_CAPABILITY_MULTIPLE_QUEUE_KHR :: (1 << 4)
CL_COMMAND_BUFFER_DEVICE_SIDE_SYNC_KHR :: (1 << 2)
cl_khr_command_buffer_mutable_dispatch :: 1
CL_KHR_COMMAND_BUFFER_MUTABLE_DISPATCH_EXTENSION_NAME :: "cl_khr_command_buffer_mutable_dispatch"
CL_KHR_COMMAND_BUFFER_MUTABLE_DISPATCH_EXTENSION_VERSION := CL_MAKE_VERSION(0, 9, 3)
CL_COMMAND_BUFFER_MUTABLE_KHR :: (1 << 1)
CL_INVALID_MUTABLE_COMMAND_KHR :: -1141
CL_DEVICE_MUTABLE_DISPATCH_CAPABILITIES_KHR :: 0x12B0
CL_MUTABLE_DISPATCH_UPDATABLE_FIELDS_KHR :: 0x12B1
CL_MUTABLE_DISPATCH_GLOBAL_OFFSET_KHR :: (1 << 0)
CL_MUTABLE_DISPATCH_GLOBAL_SIZE_KHR :: (1 << 1)
CL_MUTABLE_DISPATCH_LOCAL_SIZE_KHR :: (1 << 2)
CL_MUTABLE_DISPATCH_ARGUMENTS_KHR :: (1 << 3)
CL_MUTABLE_DISPATCH_EXEC_INFO_KHR :: (1 << 4)
CL_MUTABLE_COMMAND_COMMAND_QUEUE_KHR :: 0x12A0
CL_MUTABLE_COMMAND_COMMAND_BUFFER_KHR :: 0x12A1
CL_MUTABLE_COMMAND_COMMAND_TYPE_KHR :: 0x12AD
CL_MUTABLE_COMMAND_PROPERTIES_ARRAY_KHR :: 0x12A2
CL_MUTABLE_DISPATCH_KERNEL_KHR :: 0x12A3
CL_MUTABLE_DISPATCH_DIMENSIONS_KHR :: 0x12A4
CL_MUTABLE_DISPATCH_GLOBAL_WORK_OFFSET_KHR :: 0x12A5
CL_MUTABLE_DISPATCH_GLOBAL_WORK_SIZE_KHR :: 0x12A6
CL_MUTABLE_DISPATCH_LOCAL_WORK_SIZE_KHR :: 0x12A7
CL_STRUCTURE_TYPE_MUTABLE_DISPATCH_CONFIG_KHR :: 0
CL_COMMAND_BUFFER_MUTABLE_DISPATCH_ASSERTS_KHR :: 0x12B7
CL_MUTABLE_DISPATCH_ASSERTS_KHR :: 0x12B8
CL_MUTABLE_DISPATCH_ASSERT_NO_ADDITIONAL_WORK_GROUPS_KHR :: (1 << 0)
cl_khr_fp64 :: 1
CL_KHR_FP64_EXTENSION_NAME :: "cl_khr_fp64"
CL_KHR_FP64_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_fp16 :: 1
CL_KHR_FP16_EXTENSION_NAME :: "cl_khr_fp16"
CL_KHR_FP16_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_HALF_FP_CONFIG :: 0x1033
cl_APPLE_SetMemObjectDestructor :: 1
CL_APPLE_SETMEMOBJECTDESTRUCTOR_EXTENSION_NAME :: "cl_APPLE_SetMemObjectDestructor"
CL_APPLE_SETMEMOBJECTDESTRUCTOR_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
cl_APPLE_ContextLoggingFunctions :: 1
CL_APPLE_CONTEXTLOGGINGFUNCTIONS_EXTENSION_NAME :: "cl_APPLE_ContextLoggingFunctions"
CL_APPLE_CONTEXTLOGGINGFUNCTIONS_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
cl_khr_icd :: 1
CL_KHR_ICD_EXTENSION_NAME :: "cl_khr_icd"
CL_KHR_ICD_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_PLATFORM_ICD_SUFFIX_KHR :: 0x0920
CL_PLATFORM_NOT_FOUND_KHR :: -1001
cl_khr_il_program :: 1
CL_KHR_IL_PROGRAM_EXTENSION_NAME :: "cl_khr_il_program"
CL_KHR_IL_PROGRAM_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_IL_VERSION_KHR :: 0x105B
CL_PROGRAM_IL_KHR :: 0x1169
cl_khr_image2d_from_buffer :: 1
CL_KHR_IMAGE2D_FROM_BUFFER_EXTENSION_NAME :: "cl_khr_image2d_from_buffer"
CL_KHR_IMAGE2D_FROM_BUFFER_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_IMAGE_PITCH_ALIGNMENT_KHR :: 0x104A
CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT_KHR :: 0x104B
cl_khr_initialize_memory :: 1
CL_KHR_INITIALIZE_MEMORY_EXTENSION_NAME :: "cl_khr_initialize_memory"
CL_KHR_INITIALIZE_MEMORY_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_CONTEXT_MEMORY_INITIALIZE_KHR :: 0x2030
CL_CONTEXT_MEMORY_INITIALIZE_LOCAL_KHR :: (1 << 0)
CL_CONTEXT_MEMORY_INITIALIZE_PRIVATE_KHR :: (1 << 1)
cl_khr_terminate_context :: 1
CL_KHR_TERMINATE_CONTEXT_EXTENSION_NAME :: "cl_khr_terminate_context"
CL_KHR_TERMINATE_CONTEXT_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_TERMINATE_CAPABILITY_KHR :: 0x2031
CL_CONTEXT_TERMINATE_KHR :: 0x2032
CL_DEVICE_TERMINATE_CAPABILITY_CONTEXT_KHR :: (1 << 0)
CL_CONTEXT_TERMINATED_KHR :: -1121
cl_khr_spir :: 1
CL_KHR_SPIR_EXTENSION_NAME :: "cl_khr_spir"
CL_KHR_SPIR_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_SPIR_VERSIONS :: 0x40E0
CL_PROGRAM_BINARY_TYPE_INTERMEDIATE :: 0x40E1
cl_khr_create_command_queue :: 1
CL_KHR_CREATE_COMMAND_QUEUE_EXTENSION_NAME :: "cl_khr_create_command_queue"
CL_KHR_CREATE_COMMAND_QUEUE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_nv_device_attribute_query :: 1
CL_NV_DEVICE_ATTRIBUTE_QUERY_EXTENSION_NAME :: "cl_nv_device_attribute_query"
CL_NV_DEVICE_ATTRIBUTE_QUERY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV :: 0x4000
CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV :: 0x4001
CL_DEVICE_REGISTERS_PER_BLOCK_NV :: 0x4002
CL_DEVICE_WARP_SIZE_NV :: 0x4003
CL_DEVICE_GPU_OVERLAP_NV :: 0x4004
CL_DEVICE_KERNEL_EXEC_TIMEOUT_NV :: 0x4005
CL_DEVICE_INTEGRATED_MEMORY_NV :: 0x4006
cl_amd_device_attribute_query :: 1
CL_AMD_DEVICE_ATTRIBUTE_QUERY_EXTENSION_NAME :: "cl_amd_device_attribute_query"
CL_AMD_DEVICE_ATTRIBUTE_QUERY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_PROFILING_TIMER_OFFSET_AMD :: 0x4036
CL_DEVICE_TOPOLOGY_AMD :: 0x4037
CL_DEVICE_BOARD_NAME_AMD :: 0x4038
CL_DEVICE_GLOBAL_FREE_MEMORY_AMD :: 0x4039
CL_DEVICE_SIMD_PER_COMPUTE_UNIT_AMD :: 0x4040
CL_DEVICE_SIMD_WIDTH_AMD :: 0x4041
CL_DEVICE_SIMD_INSTRUCTION_WIDTH_AMD :: 0x4042
CL_DEVICE_WAVEFRONT_WIDTH_AMD :: 0x4043
CL_DEVICE_GLOBAL_MEM_CHANNELS_AMD :: 0x4044
CL_DEVICE_GLOBAL_MEM_CHANNEL_BANKS_AMD :: 0x4045
CL_DEVICE_GLOBAL_MEM_CHANNEL_BANK_WIDTH_AMD :: 0x4046
CL_DEVICE_LOCAL_MEM_SIZE_PER_COMPUTE_UNIT_AMD :: 0x4047
CL_DEVICE_LOCAL_MEM_BANKS_AMD :: 0x4048
CL_DEVICE_THREAD_TRACE_SUPPORTED_AMD :: 0x4049
CL_DEVICE_GFXIP_MAJOR_AMD :: 0x404A
CL_DEVICE_GFXIP_MINOR_AMD :: 0x404B
CL_DEVICE_AVAILABLE_ASYNC_QUEUES_AMD :: 0x404C
CL_DEVICE_PREFERRED_WORK_GROUP_SIZE_AMD :: 0x4030
CL_DEVICE_MAX_WORK_GROUP_SIZE_AMD :: 0x4031
CL_DEVICE_PREFERRED_CONSTANT_BUFFER_SIZE_AMD :: 0x4033
CL_DEVICE_PCIE_ID_AMD :: 0x4034
cl_arm_printf :: 1
CL_ARM_PRINTF_EXTENSION_NAME :: "cl_arm_printf"
CL_ARM_PRINTF_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_PRINTF_CALLBACK_ARM :: 0x40B0
CL_PRINTF_BUFFERSIZE_ARM :: 0x40B1
cl_ext_device_fission :: 1
CL_EXT_DEVICE_FISSION_EXTENSION_NAME :: "cl_ext_device_fission"
CL_EXT_DEVICE_FISSION_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_PARTITION_FAILED_EXT :: -1057
CL_INVALID_PARTITION_COUNT_EXT :: -1058
CL_INVALID_PARTITION_NAME_EXT :: -1059
CL_DEVICE_PARENT_DEVICE_EXT :: 0x4054
CL_DEVICE_PARTITION_TYPES_EXT :: 0x4055
CL_DEVICE_AFFINITY_DOMAINS_EXT :: 0x4056
CL_DEVICE_REFERENCE_COUNT_EXT :: 0x4057
CL_DEVICE_PARTITION_STYLE_EXT :: 0x4058
CL_DEVICE_PARTITION_EQUALLY_EXT :: 0x4050
CL_DEVICE_PARTITION_BY_COUNTS_EXT :: 0x4051
CL_DEVICE_PARTITION_BY_NAMES_EXT :: 0x4052
CL_DEVICE_PARTITION_BY_AFFINITY_DOMAIN_EXT :: 0x4053
CL_AFFINITY_DOMAIN_L1_CACHE_EXT :: 0x1
CL_AFFINITY_DOMAIN_L2_CACHE_EXT :: 0x2
CL_AFFINITY_DOMAIN_L3_CACHE_EXT :: 0x3
CL_AFFINITY_DOMAIN_L4_CACHE_EXT :: 0x4
CL_AFFINITY_DOMAIN_NUMA_EXT :: 0x10
CL_AFFINITY_DOMAIN_NEXT_FISSIONABLE_EXT :: 0x100
CL_PROPERTIES_LIST_END_EXT :: (cast(cl_device_partition_property_ext)0)
CL_PARTITION_BY_COUNTS_LIST_END_EXT :: (cast(cl_device_partition_property_ext)0)
CL_PARTITION_BY_NAMES_LIST_END_EXT :: (0xffffffffffffffff)
cl_ext_migrate_memobject :: 1
CL_EXT_MIGRATE_MEMOBJECT_EXTENSION_NAME :: "cl_ext_migrate_memobject"
CL_EXT_MIGRATE_MEMOBJECT_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_MIGRATE_MEM_OBJECT_HOST_EXT :: (1 << 0)
CL_COMMAND_MIGRATE_MEM_OBJECT_EXT :: 0x4040
cl_ext_cxx_for_opencl :: 1
CL_EXT_CXX_FOR_OPENCL_EXTENSION_NAME :: "cl_ext_cxx_for_opencl"
CL_EXT_CXX_FOR_OPENCL_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_CXX_FOR_OPENCL_NUMERIC_VERSION_EXT :: 0x4230
cl_qcom_ext_host_ptr :: 1
CL_QCOM_EXT_HOST_PTR_EXTENSION_NAME :: "cl_qcom_ext_host_ptr"
CL_QCOM_EXT_HOST_PTR_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_EXT_HOST_PTR_QCOM :: (1 << 29)
CL_DEVICE_EXT_MEM_PADDING_IN_BYTES_QCOM :: 0x40A0
CL_DEVICE_PAGE_SIZE_QCOM :: 0x40A1
CL_IMAGE_ROW_ALIGNMENT_QCOM :: 0x40A2
CL_IMAGE_SLICE_ALIGNMENT_QCOM :: 0x40A3
CL_MEM_HOST_UNCACHED_QCOM :: 0x40A4
CL_MEM_HOST_WRITEBACK_QCOM :: 0x40A5
CL_MEM_HOST_WRITETHROUGH_QCOM :: 0x40A6
CL_MEM_HOST_WRITE_COMBINING_QCOM :: 0x40A7
cl_qcom_ext_host_ptr_iocoherent :: 1
CL_QCOM_EXT_HOST_PTR_IOCOHERENT_EXTENSION_NAME :: "cl_qcom_ext_host_ptr_iocoherent"
CL_QCOM_EXT_HOST_PTR_IOCOHERENT_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_HOST_IOCOHERENT_QCOM :: 0x40A9
cl_qcom_ion_host_ptr :: 1
CL_QCOM_ION_HOST_PTR_EXTENSION_NAME :: "cl_qcom_ion_host_ptr"
CL_QCOM_ION_HOST_PTR_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_ION_HOST_PTR_QCOM :: 0x40A8
cl_qcom_android_native_buffer_host_ptr :: 1
CL_QCOM_ANDROID_NATIVE_BUFFER_HOST_PTR_EXTENSION_NAME :: "cl_qcom_android_native_buffer_host_ptr"
CL_QCOM_ANDROID_NATIVE_BUFFER_HOST_PTR_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_ANDROID_NATIVE_BUFFER_HOST_PTR_QCOM :: 0x40C6
cl_img_yuv_image :: 1
CL_IMG_YUV_IMAGE_EXTENSION_NAME :: "cl_img_yuv_image"
CL_IMG_YUV_IMAGE_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_NV21_IMG :: 0x40D0
CL_YV12_IMG :: 0x40D1
cl_img_cached_allocations :: 1
CL_IMG_CACHED_ALLOCATIONS_EXTENSION_NAME :: "cl_img_cached_allocations"
CL_IMG_CACHED_ALLOCATIONS_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_USE_UNCACHED_CPU_MEMORY_IMG :: (1 << 26)
CL_MEM_USE_CACHED_CPU_MEMORY_IMG :: (1 << 27)
cl_img_use_gralloc_ptr :: 1
CL_IMG_USE_GRALLOC_PTR_EXTENSION_NAME :: "cl_img_use_gralloc_ptr"
CL_IMG_USE_GRALLOC_PTR_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_GRALLOC_RESOURCE_NOT_ACQUIRED_IMG :: 0x40D4
CL_INVALID_GRALLOC_OBJECT_IMG :: 0x40D5
CL_MEM_USE_GRALLOC_PTR_IMG :: (1 << 28)
CL_COMMAND_ACQUIRE_GRALLOC_OBJECTS_IMG :: 0x40D2
CL_COMMAND_RELEASE_GRALLOC_OBJECTS_IMG :: 0x40D3
cl_img_generate_mipmap :: 1
CL_IMG_GENERATE_MIPMAP_EXTENSION_NAME :: "cl_img_generate_mipmap"
CL_IMG_GENERATE_MIPMAP_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MIPMAP_FILTER_ANY_IMG :: 0x0
CL_MIPMAP_FILTER_BOX_IMG :: 0x1
CL_COMMAND_GENERATE_MIPMAP_IMG :: 0x40D6
cl_img_mem_properties :: 1
CL_IMG_MEM_PROPERTIES_EXTENSION_NAME :: "cl_img_mem_properties"
CL_IMG_MEM_PROPERTIES_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_ALLOC_FLAGS_IMG :: 0x40D7
CL_MEM_ALLOC_RELAX_REQUIREMENTS_IMG :: (1 << 0)
CL_MEM_ALLOC_GPU_WRITE_COMBINE_IMG :: (1 << 1)
CL_MEM_ALLOC_GPU_CACHED_IMG :: (1 << 2)
CL_MEM_ALLOC_CPU_LOCAL_IMG :: (1 << 3)
CL_MEM_ALLOC_GPU_LOCAL_IMG :: (1 << 4)
CL_MEM_ALLOC_GPU_PRIVATE_IMG :: (1 << 5)
CL_DEVICE_MEMORY_CAPABILITIES_IMG :: 0x40D8
cl_khr_subgroups :: 1
CL_KHR_SUBGROUPS_EXTENSION_NAME :: "cl_khr_subgroups"
CL_KHR_SUBGROUPS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE_KHR :: 0x2033
CL_KERNEL_SUB_GROUP_COUNT_FOR_NDRANGE_KHR :: 0x2034
cl_khr_mipmap_image :: 1
CL_KHR_MIPMAP_IMAGE_EXTENSION_NAME :: "cl_khr_mipmap_image"
CL_KHR_MIPMAP_IMAGE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_SAMPLER_MIP_FILTER_MODE_KHR :: 0x1155
CL_SAMPLER_LOD_MIN_KHR :: 0x1156
CL_SAMPLER_LOD_MAX_KHR :: 0x1157
cl_khr_priority_hints :: 1
CL_KHR_PRIORITY_HINTS_EXTENSION_NAME :: "cl_khr_priority_hints"
CL_KHR_PRIORITY_HINTS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_QUEUE_PRIORITY_KHR :: 0x1096
CL_QUEUE_PRIORITY_HIGH_KHR :: (1 << 0)
CL_QUEUE_PRIORITY_MED_KHR :: (1 << 1)
CL_QUEUE_PRIORITY_LOW_KHR :: (1 << 2)
cl_khr_throttle_hints :: 1
CL_KHR_THROTTLE_HINTS_EXTENSION_NAME :: "cl_khr_throttle_hints"
CL_KHR_THROTTLE_HINTS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_QUEUE_THROTTLE_KHR :: 0x1097
CL_QUEUE_THROTTLE_HIGH_KHR :: (1 << 0)
CL_QUEUE_THROTTLE_MED_KHR :: (1 << 1)
CL_QUEUE_THROTTLE_LOW_KHR :: (1 << 2)
cl_khr_subgroup_named_barrier :: 1
CL_KHR_SUBGROUP_NAMED_BARRIER_EXTENSION_NAME :: "cl_khr_subgroup_named_barrier"
CL_KHR_SUBGROUP_NAMED_BARRIER_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_MAX_NAMED_BARRIER_COUNT_KHR :: 0x2035
cl_khr_extended_versioning :: 1
CL_KHR_EXTENDED_VERSIONING_EXTENSION_NAME :: "cl_khr_extended_versioning"
CL_KHR_EXTENDED_VERSIONING_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_VERSION_MAJOR_BITS_KHR :: 10
CL_VERSION_MINOR_BITS_KHR :: 10
CL_VERSION_PATCH_BITS_KHR :: 12
CL_VERSION_MAJOR_MASK_KHR :: ((1 << CL_VERSION_MAJOR_BITS_KHR) - 1)
CL_VERSION_MINOR_MASK_KHR :: ((1 << CL_VERSION_MINOR_BITS_KHR) - 1)
CL_VERSION_PATCH_MASK_KHR :: ((1 << CL_VERSION_PATCH_BITS_KHR) - 1)
CL_VERSION_MAJOR_KHR :: #force_inline proc(#any_int version: u64) -> u64 { return ((version) >> (CL_VERSION_MINOR_BITS_KHR + CL_VERSION_PATCH_BITS_KHR)); }
CL_VERSION_MINOR_KHR :: #force_inline proc(#any_int version: u64) -> u64 { return (((version) >> CL_VERSION_PATCH_BITS_KHR) & CL_VERSION_MINOR_MASK_KHR); }
CL_VERSION_PATCH_KHR :: #force_inline proc(#any_int version: u64) -> u64 { return ((version) & CL_VERSION_PATCH_MASK_KHR); }
CL_MAKE_VERSION_KHR :: #force_inline proc(#any_int major,minor,patch: u64) -> u64 {
    return ((((major) & CL_VERSION_MAJOR_MASK_KHR) << (CL_VERSION_MINOR_BITS_KHR + CL_VERSION_PATCH_BITS_KHR)) | (((minor) & CL_VERSION_MINOR_MASK_KHR) << CL_VERSION_PATCH_BITS_KHR) | ((patch) & CL_VERSION_PATCH_MASK_KHR));
}
CL_NAME_VERSION_MAX_NAME_SIZE_KHR :: 64
CL_PLATFORM_NUMERIC_VERSION_KHR :: 0x0906
CL_PLATFORM_EXTENSIONS_WITH_VERSION_KHR :: 0x0907
CL_DEVICE_NUMERIC_VERSION_KHR :: 0x105E
CL_DEVICE_OPENCL_C_NUMERIC_VERSION_KHR :: 0x105F
CL_DEVICE_EXTENSIONS_WITH_VERSION_KHR :: 0x1060
CL_DEVICE_ILS_WITH_VERSION_KHR :: 0x1061
CL_DEVICE_BUILT_IN_KERNELS_WITH_VERSION_KHR :: 0x1062
cl_khr_device_uuid :: 1
CL_KHR_DEVICE_UUID_EXTENSION_NAME :: "cl_khr_device_uuid"
CL_KHR_DEVICE_UUID_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_UUID_SIZE_KHR :: 16
CL_LUID_SIZE_KHR :: 8
CL_DEVICE_UUID_KHR :: 0x106A
CL_DRIVER_UUID_KHR :: 0x106B
CL_DEVICE_LUID_VALID_KHR :: 0x106C
CL_DEVICE_LUID_KHR :: 0x106D
CL_DEVICE_NODE_MASK_KHR :: 0x106E
cl_khr_pci_bus_info :: 1
CL_KHR_PCI_BUS_INFO_EXTENSION_NAME :: "cl_khr_pci_bus_info"
CL_KHR_PCI_BUS_INFO_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_PCI_BUS_INFO_KHR :: 0x410F
cl_khr_suggested_local_work_size :: 1
CL_KHR_SUGGESTED_LOCAL_WORK_SIZE_EXTENSION_NAME :: "cl_khr_suggested_local_work_size"
CL_KHR_SUGGESTED_LOCAL_WORK_SIZE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_integer_dot_product :: 1
CL_KHR_INTEGER_DOT_PRODUCT_EXTENSION_NAME :: "cl_khr_integer_dot_product"
CL_KHR_INTEGER_DOT_PRODUCT_EXTENSION_VERSION := CL_MAKE_VERSION(2, 0, 0)
CL_DEVICE_INTEGER_DOT_PRODUCT_INPUT_4x8BIT_PACKED_KHR :: (1 << 0)
CL_DEVICE_INTEGER_DOT_PRODUCT_INPUT_4x8BIT_KHR :: (1 << 1)
CL_DEVICE_INTEGER_DOT_PRODUCT_CAPABILITIES_KHR :: 0x1073
CL_DEVICE_INTEGER_DOT_PRODUCT_ACCELERATION_PROPERTIES_8BIT_KHR :: 0x1074
CL_DEVICE_INTEGER_DOT_PRODUCT_ACCELERATION_PROPERTIES_4x8BIT_PACKED_KHR :: 0x1075
cl_khr_external_memory :: 1
CL_KHR_EXTERNAL_MEMORY_EXTENSION_NAME :: "cl_khr_external_memory"
CL_KHR_EXTERNAL_MEMORY_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 1)
CL_PLATFORM_EXTERNAL_MEMORY_IMPORT_HANDLE_TYPES_KHR :: 0x2044
CL_DEVICE_EXTERNAL_MEMORY_IMPORT_HANDLE_TYPES_KHR :: 0x204F
CL_DEVICE_EXTERNAL_MEMORY_IMPORT_ASSUME_LINEAR_IMAGES_HANDLE_TYPES_KHR :: 0x2052
CL_MEM_DEVICE_HANDLE_LIST_KHR :: 0x2051
CL_MEM_DEVICE_HANDLE_LIST_END_KHR :: 0
CL_COMMAND_ACQUIRE_EXTERNAL_MEM_OBJECTS_KHR :: 0x2047
CL_COMMAND_RELEASE_EXTERNAL_MEM_OBJECTS_KHR :: 0x2048
cl_khr_external_memory_dma_buf :: 1
CL_KHR_EXTERNAL_MEMORY_DMA_BUF_EXTENSION_NAME :: "cl_khr_external_memory_dma_buf"
CL_KHR_EXTERNAL_MEMORY_DMA_BUF_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_EXTERNAL_MEMORY_HANDLE_DMA_BUF_KHR :: 0x2067
cl_khr_external_memory_opaque_fd :: 1
CL_KHR_EXTERNAL_MEMORY_OPAQUE_FD_EXTENSION_NAME :: "cl_khr_external_memory_opaque_fd"
CL_KHR_EXTERNAL_MEMORY_OPAQUE_FD_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_EXTERNAL_MEMORY_HANDLE_OPAQUE_FD_KHR :: 0x2060
cl_khr_external_memory_win32 :: 1
CL_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME :: "cl_khr_external_memory_win32"
CL_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_VERSION := CL_MAKE_VERSION(1, 1, 0)
CL_EXTERNAL_MEMORY_HANDLE_OPAQUE_WIN32_KHR :: 0x2061
CL_EXTERNAL_MEMORY_HANDLE_OPAQUE_WIN32_KMT_KHR :: 0x2062
CL_EXTERNAL_MEMORY_HANDLE_OPAQUE_WIN32_NAME_KHR :: 0x2069
cl_khr_external_semaphore :: 1
CL_KHR_EXTERNAL_SEMAPHORE_EXTENSION_NAME :: "cl_khr_external_semaphore"
CL_KHR_EXTERNAL_SEMAPHORE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 1)
CL_PLATFORM_SEMAPHORE_IMPORT_HANDLE_TYPES_KHR :: 0x2037
CL_PLATFORM_SEMAPHORE_EXPORT_HANDLE_TYPES_KHR :: 0x2038
CL_DEVICE_SEMAPHORE_IMPORT_HANDLE_TYPES_KHR :: 0x204D
CL_DEVICE_SEMAPHORE_EXPORT_HANDLE_TYPES_KHR :: 0x204E
CL_SEMAPHORE_EXPORT_HANDLE_TYPES_KHR :: 0x203F
CL_SEMAPHORE_EXPORT_HANDLE_TYPES_LIST_END_KHR :: 0
CL_SEMAPHORE_EXPORTABLE_KHR :: 0x2054
cl_khr_external_semaphore_opaque_fd :: 1
CL_KHR_EXTERNAL_SEMAPHORE_OPAQUE_FD_EXTENSION_NAME :: "cl_khr_external_semaphore_opaque_fd"
CL_KHR_EXTERNAL_SEMAPHORE_OPAQUE_FD_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_SEMAPHORE_HANDLE_OPAQUE_FD_KHR :: 0x2055
cl_khr_external_semaphore_sync_fd :: 1
CL_KHR_EXTERNAL_SEMAPHORE_SYNC_FD_EXTENSION_NAME :: "cl_khr_external_semaphore_sync_fd"
CL_KHR_EXTERNAL_SEMAPHORE_SYNC_FD_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_SEMAPHORE_HANDLE_SYNC_FD_KHR :: 0x2058
cl_khr_external_semaphore_win32 :: 1
CL_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME :: "cl_khr_external_semaphore_win32"
CL_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_VERSION := CL_MAKE_VERSION(0, 9, 1)
CL_SEMAPHORE_HANDLE_OPAQUE_WIN32_KHR :: 0x2056
CL_SEMAPHORE_HANDLE_OPAQUE_WIN32_KMT_KHR :: 0x2057
CL_SEMAPHORE_HANDLE_OPAQUE_WIN32_NAME_KHR :: 0x2068
cl_khr_semaphore :: 1
CL_KHR_SEMAPHORE_EXTENSION_NAME :: "cl_khr_semaphore"
CL_KHR_SEMAPHORE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_SEMAPHORE_TYPE_BINARY_KHR :: 1
CL_PLATFORM_SEMAPHORE_TYPES_KHR :: 0x2036
CL_DEVICE_SEMAPHORE_TYPES_KHR :: 0x204C
CL_SEMAPHORE_CONTEXT_KHR :: 0x2039
CL_SEMAPHORE_REFERENCE_COUNT_KHR :: 0x203A
CL_SEMAPHORE_PROPERTIES_KHR :: 0x203B
CL_SEMAPHORE_PAYLOAD_KHR :: 0x203C
CL_SEMAPHORE_TYPE_KHR :: 0x203D
CL_SEMAPHORE_DEVICE_HANDLE_LIST_KHR :: 0x2053
CL_SEMAPHORE_DEVICE_HANDLE_LIST_END_KHR :: 0
CL_COMMAND_SEMAPHORE_WAIT_KHR :: 0x2042
CL_COMMAND_SEMAPHORE_SIGNAL_KHR :: 0x2043
CL_INVALID_SEMAPHORE_KHR :: -1142
cl_arm_import_memory :: 1
CL_ARM_IMPORT_MEMORY_EXTENSION_NAME :: "cl_arm_import_memory"
CL_ARM_IMPORT_MEMORY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_IMPORT_TYPE_ARM :: 0x40B2
CL_IMPORT_TYPE_HOST_ARM :: 0x40B3
CL_IMPORT_TYPE_DMA_BUF_ARM :: 0x40B4
CL_IMPORT_TYPE_PROTECTED_ARM :: 0x40B5
CL_IMPORT_TYPE_ANDROID_HARDWARE_BUFFER_ARM :: 0x41E2
CL_IMPORT_DMA_BUF_DATA_CONSISTENCY_WITH_HOST_ARM :: 0x41E3
CL_IMPORT_MEMORY_WHOLE_ALLOCATION_ARM :: c.SIZE_MAX
CL_IMPORT_ANDROID_HARDWARE_BUFFER_PLANE_INDEX_ARM :: 0x41EF
CL_IMPORT_ANDROID_HARDWARE_BUFFER_LAYER_INDEX_ARM :: 0x41F0
cl_arm_shared_virtual_memory :: 1
CL_ARM_SHARED_VIRTUAL_MEMORY_EXTENSION_NAME :: "cl_arm_shared_virtual_memory"
CL_ARM_SHARED_VIRTUAL_MEMORY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_SVM_CAPABILITIES_ARM :: 0x40B6
CL_MEM_USES_SVM_POINTER_ARM :: 0x40B7
CL_KERNEL_EXEC_INFO_SVM_PTRS_ARM :: 0x40B8
CL_KERNEL_EXEC_INFO_SVM_FINE_GRAIN_SYSTEM_ARM :: 0x40B9
CL_COMMAND_SVM_FREE_ARM :: 0x40BA
CL_COMMAND_SVM_MEMCPY_ARM :: 0x40BB
CL_COMMAND_SVM_MEMFILL_ARM :: 0x40BC
CL_COMMAND_SVM_MAP_ARM :: 0x40BD
CL_COMMAND_SVM_UNMAP_ARM :: 0x40BE
CL_DEVICE_SVM_COARSE_GRAIN_BUFFER_ARM :: (1 << 0)
CL_DEVICE_SVM_FINE_GRAIN_BUFFER_ARM :: (1 << 1)
CL_DEVICE_SVM_FINE_GRAIN_SYSTEM_ARM :: (1 << 2)
CL_DEVICE_SVM_ATOMICS_ARM :: (1 << 3)
CL_MEM_SVM_FINE_GRAIN_BUFFER_ARM :: (1 << 10)
CL_MEM_SVM_ATOMICS_ARM :: (1 << 11)
cl_arm_get_core_id :: 1
CL_ARM_GET_CORE_ID_EXTENSION_NAME :: "cl_arm_get_core_id"
CL_ARM_GET_CORE_ID_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_COMPUTE_UNITS_BITFIELD_ARM :: 0x40BF
cl_arm_job_slot_selection :: 1
CL_ARM_JOB_SLOT_SELECTION_EXTENSION_NAME :: "cl_arm_job_slot_selection"
CL_ARM_JOB_SLOT_SELECTION_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_JOB_SLOTS_ARM :: 0x41E0
CL_QUEUE_JOB_SLOT_ARM :: 0x41E1
cl_arm_scheduling_controls :: 1
CL_ARM_SCHEDULING_CONTROLS_EXTENSION_NAME :: "cl_arm_scheduling_controls"
CL_ARM_SCHEDULING_CONTROLS_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_SCHEDULING_KERNEL_BATCHING_ARM :: (1 << 0)
CL_DEVICE_SCHEDULING_WORKGROUP_BATCH_SIZE_ARM :: (1 << 1)
CL_DEVICE_SCHEDULING_WORKGROUP_BATCH_SIZE_MODIFIER_ARM :: (1 << 2)
CL_DEVICE_SCHEDULING_DEFERRED_FLUSH_ARM :: (1 << 3)
CL_DEVICE_SCHEDULING_REGISTER_ALLOCATION_ARM :: (1 << 4)
CL_DEVICE_SCHEDULING_WARP_THROTTLING_ARM :: (1 << 5)
CL_DEVICE_SCHEDULING_COMPUTE_UNIT_BATCH_QUEUE_SIZE_ARM :: (1 << 6)
CL_DEVICE_SCHEDULING_COMPUTE_UNIT_LIMIT_ARM :: (1 << 7)
CL_DEVICE_SCHEDULING_CONTROLS_CAPABILITIES_ARM :: 0x41E4
CL_DEVICE_SUPPORTED_REGISTER_ALLOCATIONS_ARM :: 0x41EB
CL_DEVICE_MAX_WARP_COUNT_ARM :: 0x41EA
CL_KERNEL_EXEC_INFO_WORKGROUP_BATCH_SIZE_ARM :: 0x41E5
CL_KERNEL_EXEC_INFO_WORKGROUP_BATCH_SIZE_MODIFIER_ARM :: 0x41E6
CL_KERNEL_EXEC_INFO_WARP_COUNT_LIMIT_ARM :: 0x41E8
CL_KERNEL_EXEC_INFO_COMPUTE_UNIT_MAX_QUEUED_BATCHES_ARM :: 0x41F1
CL_KERNEL_MAX_WARP_COUNT_ARM :: 0x41E9
CL_QUEUE_KERNEL_BATCHING_ARM :: 0x41E7
CL_QUEUE_DEFERRED_FLUSH_ARM :: 0x41EC
CL_QUEUE_COMPUTE_UNIT_LIMIT_ARM :: 0x41F3
cl_arm_controlled_kernel_termination :: 1
CL_ARM_CONTROLLED_KERNEL_TERMINATION_EXTENSION_NAME :: "cl_arm_controlled_kernel_termination"
CL_ARM_CONTROLLED_KERNEL_TERMINATION_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_COMMAND_TERMINATED_ITSELF_WITH_FAILURE_ARM :: -1108
CL_DEVICE_CONTROLLED_TERMINATION_SUCCESS_ARM :: (1 << 0)
CL_DEVICE_CONTROLLED_TERMINATION_FAILURE_ARM :: (1 << 1)
CL_DEVICE_CONTROLLED_TERMINATION_QUERY_ARM :: (1 << 2)
CL_DEVICE_CONTROLLED_TERMINATION_CAPABILITIES_ARM :: 0x41EE
CL_EVENT_COMMAND_TERMINATION_REASON_ARM :: 0x41ED
CL_COMMAND_TERMINATION_COMPLETION_ARM :: 0
CL_COMMAND_TERMINATION_CONTROLLED_SUCCESS_ARM :: 1
CL_COMMAND_TERMINATION_CONTROLLED_FAILURE_ARM :: 2
CL_COMMAND_TERMINATION_ERROR_ARM :: 3
cl_arm_protected_memory_allocation :: 1
CL_ARM_PROTECTED_MEMORY_ALLOCATION_EXTENSION_NAME :: "cl_arm_protected_memory_allocation"
CL_ARM_PROTECTED_MEMORY_ALLOCATION_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_PROTECTED_ALLOC_ARM :: (cast(cl_bitfield)1 << 36)
cl_intel_exec_by_local_thread :: 1
CL_INTEL_EXEC_BY_LOCAL_THREAD_EXTENSION_NAME :: "cl_intel_exec_by_local_thread"
CL_INTEL_EXEC_BY_LOCAL_THREAD_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_QUEUE_THREAD_LOCAL_EXEC_ENABLE_INTEL :: (cast(cl_bitfield)1 << 31)
cl_intel_device_attribute_query :: 1
CL_INTEL_DEVICE_ATTRIBUTE_QUERY_EXTENSION_NAME :: "cl_intel_device_attribute_query"
CL_INTEL_DEVICE_ATTRIBUTE_QUERY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_FEATURE_FLAG_DP4A_INTEL :: (1 << 0)
CL_DEVICE_FEATURE_FLAG_DPAS_INTEL :: (1 << 1)
CL_DEVICE_IP_VERSION_INTEL :: 0x4250
CL_DEVICE_ID_INTEL :: 0x4251
CL_DEVICE_NUM_SLICES_INTEL :: 0x4252
CL_DEVICE_NUM_SUB_SLICES_PER_SLICE_INTEL :: 0x4253
CL_DEVICE_NUM_EUS_PER_SUB_SLICE_INTEL :: 0x4254
CL_DEVICE_NUM_THREADS_PER_EU_INTEL :: 0x4255
CL_DEVICE_FEATURE_CAPABILITIES_INTEL :: 0x4256
cl_intel_device_partition_by_names :: 1
CL_INTEL_DEVICE_PARTITION_BY_NAMES_EXTENSION_NAME :: "cl_intel_device_partition_by_names"
CL_INTEL_DEVICE_PARTITION_BY_NAMES_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_PARTITION_BY_NAMES_INTEL :: 0x4052
CL_PARTITION_BY_NAMES_LIST_END_INTEL :: -1
cl_intel_accelerator :: 1
CL_INTEL_ACCELERATOR_EXTENSION_NAME :: "cl_intel_accelerator"
CL_INTEL_ACCELERATOR_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_ACCELERATOR_DESCRIPTOR_INTEL :: 0x4090
CL_ACCELERATOR_REFERENCE_COUNT_INTEL :: 0x4091
CL_ACCELERATOR_CONTEXT_INTEL :: 0x4092
CL_ACCELERATOR_TYPE_INTEL :: 0x4093
CL_INVALID_ACCELERATOR_INTEL :: -1094
CL_INVALID_ACCELERATOR_TYPE_INTEL :: -1095
CL_INVALID_ACCELERATOR_DESCRIPTOR_INTEL :: -1096
CL_ACCELERATOR_TYPE_NOT_SUPPORTED_INTEL :: -1097
cl_intel_motion_estimation :: 1
CL_INTEL_MOTION_ESTIMATION_EXTENSION_NAME :: "cl_intel_motion_estimation"
CL_INTEL_MOTION_ESTIMATION_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_ACCELERATOR_TYPE_MOTION_ESTIMATION_INTEL :: 0x0
CL_ME_MB_TYPE_16x16_INTEL :: 0x0
CL_ME_MB_TYPE_8x8_INTEL :: 0x1
CL_ME_MB_TYPE_4x4_INTEL :: 0x2
CL_ME_SUBPIXEL_MODE_INTEGER_INTEL :: 0x0
CL_ME_SUBPIXEL_MODE_HPEL_INTEL :: 0x1
CL_ME_SUBPIXEL_MODE_QPEL_INTEL :: 0x2
CL_ME_SAD_ADJUST_MODE_NONE_INTEL :: 0x0
CL_ME_SAD_ADJUST_MODE_HAAR_INTEL :: 0x1
CL_ME_SEARCH_PATH_RADIUS_2_2_INTEL :: 0x0
CL_ME_SEARCH_PATH_RADIUS_4_4_INTEL :: 0x1
CL_ME_SEARCH_PATH_RADIUS_16_12_INTEL :: 0x5
cl_intel_advanced_motion_estimation :: 1
CL_INTEL_ADVANCED_MOTION_ESTIMATION_EXTENSION_NAME :: "cl_intel_advanced_motion_estimation"
CL_INTEL_ADVANCED_MOTION_ESTIMATION_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_ME_VERSION_INTEL :: 0x407E
CL_ME_VERSION_LEGACY_INTEL :: 0x0
CL_ME_VERSION_ADVANCED_VER_1_INTEL :: 0x1
CL_ME_VERSION_ADVANCED_VER_2_INTEL :: 0x2
CL_ME_CHROMA_INTRA_PREDICT_ENABLED_INTEL :: 0x1
CL_ME_LUMA_INTRA_PREDICT_ENABLED_INTEL :: 0x2
CL_ME_SKIP_BLOCK_TYPE_16x16_INTEL :: 0x0
CL_ME_SKIP_BLOCK_TYPE_8x8_INTEL :: 0x4
CL_ME_COST_PENALTY_NONE_INTEL :: 0x0
CL_ME_COST_PENALTY_LOW_INTEL :: 0x1
CL_ME_COST_PENALTY_NORMAL_INTEL :: 0x2
CL_ME_COST_PENALTY_HIGH_INTEL :: 0x3
CL_ME_COST_PRECISION_QPEL_INTEL :: 0x0
CL_ME_COST_PRECISION_HPEL_INTEL :: 0x1
CL_ME_COST_PRECISION_PEL_INTEL :: 0x2
CL_ME_COST_PRECISION_DPEL_INTEL :: 0x3
CL_ME_LUMA_PREDICTOR_MODE_VERTICAL_INTEL :: 0x0
CL_ME_LUMA_PREDICTOR_MODE_HORIZONTAL_INTEL :: 0x1
CL_ME_LUMA_PREDICTOR_MODE_DC_INTEL :: 0x2
CL_ME_LUMA_PREDICTOR_MODE_DIAGONAL_DOWN_LEFT_INTEL :: 0x3
CL_ME_LUMA_PREDICTOR_MODE_DIAGONAL_DOWN_RIGHT_INTEL :: 0x4
CL_ME_LUMA_PREDICTOR_MODE_PLANE_INTEL :: 0x4
CL_ME_LUMA_PREDICTOR_MODE_VERTICAL_RIGHT_INTEL :: 0x5
CL_ME_LUMA_PREDICTOR_MODE_HORIZONTAL_DOWN_INTEL :: 0x6
CL_ME_LUMA_PREDICTOR_MODE_VERTICAL_LEFT_INTEL :: 0x7
CL_ME_LUMA_PREDICTOR_MODE_HORIZONTAL_UP_INTEL :: 0x8
CL_ME_CHROMA_PREDICTOR_MODE_DC_INTEL :: 0x0
CL_ME_CHROMA_PREDICTOR_MODE_HORIZONTAL_INTEL :: 0x1
CL_ME_CHROMA_PREDICTOR_MODE_VERTICAL_INTEL :: 0x2
CL_ME_CHROMA_PREDICTOR_MODE_PLANE_INTEL :: 0x3
CL_ME_FORWARD_INPUT_MODE_INTEL :: 0x1
CL_ME_BACKWARD_INPUT_MODE_INTEL :: 0x2
CL_ME_BIDIRECTION_INPUT_MODE_INTEL :: 0x3
CL_ME_BIDIR_WEIGHT_QUARTER_INTEL :: 16
CL_ME_BIDIR_WEIGHT_THIRD_INTEL :: 21
CL_ME_BIDIR_WEIGHT_HALF_INTEL :: 32
CL_ME_BIDIR_WEIGHT_TWO_THIRD_INTEL :: 43
CL_ME_BIDIR_WEIGHT_THREE_QUARTER_INTEL :: 48
cl_intel_simultaneous_sharing :: 1
CL_INTEL_SIMULTANEOUS_SHARING_EXTENSION_NAME :: "cl_intel_simultaneous_sharing"
CL_INTEL_SIMULTANEOUS_SHARING_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_SIMULTANEOUS_INTEROPS_INTEL :: 0x4104
CL_DEVICE_NUM_SIMULTANEOUS_INTEROPS_INTEL :: 0x4105
cl_intel_egl_image_yuv :: 1
CL_INTEL_EGL_IMAGE_YUV_EXTENSION_NAME :: "cl_intel_egl_image_yuv"
CL_INTEL_EGL_IMAGE_YUV_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_EGL_YUV_PLANE_INTEL :: 0x4107
cl_intel_packed_yuv :: 1
CL_INTEL_PACKED_YUV_EXTENSION_NAME :: "cl_intel_packed_yuv"
CL_INTEL_PACKED_YUV_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_YUYV_INTEL :: 0x4076
CL_UYVY_INTEL :: 0x4077
CL_YVYU_INTEL :: 0x4078
CL_VYUY_INTEL :: 0x4079
cl_intel_required_subgroup_size :: 1
CL_INTEL_REQUIRED_SUBGROUP_SIZE_EXTENSION_NAME :: "cl_intel_required_subgroup_size"
CL_INTEL_REQUIRED_SUBGROUP_SIZE_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_SUB_GROUP_SIZES_INTEL :: 0x4108
CL_KERNEL_SPILL_MEM_SIZE_INTEL :: 0x4109
CL_KERNEL_COMPILE_SUB_GROUP_SIZE_INTEL :: 0x410A
cl_intel_driver_diagnostics :: 1
CL_INTEL_DRIVER_DIAGNOSTICS_EXTENSION_NAME :: "cl_intel_driver_diagnostics"
CL_INTEL_DRIVER_DIAGNOSTICS_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_CONTEXT_SHOW_DIAGNOSTICS_INTEL :: 0x4106
CL_CONTEXT_DIAGNOSTICS_LEVEL_ALL_INTEL :: 0xff
CL_CONTEXT_DIAGNOSTICS_LEVEL_GOOD_INTEL :: (1 << 0)
CL_CONTEXT_DIAGNOSTICS_LEVEL_BAD_INTEL :: (1 << 1)
CL_CONTEXT_DIAGNOSTICS_LEVEL_NEUTRAL_INTEL :: (1 << 2)
cl_intel_planar_yuv :: 1
CL_INTEL_PLANAR_YUV_EXTENSION_NAME :: "cl_intel_planar_yuv"
CL_INTEL_PLANAR_YUV_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_NV12_INTEL :: 0x410E
CL_MEM_NO_ACCESS_INTEL :: (1 << 24)
CL_MEM_ACCESS_FLAGS_UNRESTRICTED_INTEL :: (1 << 25)
CL_DEVICE_PLANAR_YUV_MAX_WIDTH_INTEL :: 0x417E
CL_DEVICE_PLANAR_YUV_MAX_HEIGHT_INTEL :: 0x417F
cl_intel_device_side_avc_motion_estimation :: 1
CL_INTEL_DEVICE_SIDE_AVC_MOTION_ESTIMATION_EXTENSION_NAME :: "cl_intel_device_side_avc_motion_estimation"
CL_INTEL_DEVICE_SIDE_AVC_MOTION_ESTIMATION_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_AVC_ME_VERSION_INTEL :: 0x410B
CL_DEVICE_AVC_ME_SUPPORTS_TEXTURE_SAMPLER_USE_INTEL :: 0x410C
CL_DEVICE_AVC_ME_SUPPORTS_PREEMPTION_INTEL :: 0x410D
CL_AVC_ME_VERSION_0_INTEL :: 0x0
CL_AVC_ME_VERSION_1_INTEL :: 0x1
CL_AVC_ME_MAJOR_16x16_INTEL :: 0x0
CL_AVC_ME_MAJOR_16x8_INTEL :: 0x1
CL_AVC_ME_MAJOR_8x16_INTEL :: 0x2
CL_AVC_ME_MAJOR_8x8_INTEL :: 0x3
CL_AVC_ME_MINOR_8x8_INTEL :: 0x0
CL_AVC_ME_MINOR_8x4_INTEL :: 0x1
CL_AVC_ME_MINOR_4x8_INTEL :: 0x2
CL_AVC_ME_MINOR_4x4_INTEL :: 0x3
CL_AVC_ME_MAJOR_FORWARD_INTEL :: 0x0
CL_AVC_ME_MAJOR_BACKWARD_INTEL :: 0x1
CL_AVC_ME_MAJOR_BIDIRECTIONAL_INTEL :: 0x2
CL_AVC_ME_PARTITION_MASK_ALL_INTEL :: 0x0
CL_AVC_ME_PARTITION_MASK_16x16_INTEL :: 0x7E
CL_AVC_ME_PARTITION_MASK_16x8_INTEL :: 0x7D
CL_AVC_ME_PARTITION_MASK_8x16_INTEL :: 0x7B
CL_AVC_ME_PARTITION_MASK_8x8_INTEL :: 0x77
CL_AVC_ME_PARTITION_MASK_8x4_INTEL :: 0x6F
CL_AVC_ME_PARTITION_MASK_4x8_INTEL :: 0x5F
CL_AVC_ME_PARTITION_MASK_4x4_INTEL :: 0x3F
CL_AVC_ME_SEARCH_WINDOW_EXHAUSTIVE_INTEL :: 0x0
CL_AVC_ME_SEARCH_WINDOW_SMALL_INTEL :: 0x1
CL_AVC_ME_SEARCH_WINDOW_TINY_INTEL :: 0x2
CL_AVC_ME_SEARCH_WINDOW_EXTRA_TINY_INTEL :: 0x3
CL_AVC_ME_SEARCH_WINDOW_DIAMOND_INTEL :: 0x4
CL_AVC_ME_SEARCH_WINDOW_LARGE_DIAMOND_INTEL :: 0x5
CL_AVC_ME_SEARCH_WINDOW_RESERVED0_INTEL :: 0x6
CL_AVC_ME_SEARCH_WINDOW_RESERVED1_INTEL :: 0x7
CL_AVC_ME_SEARCH_WINDOW_CUSTOM_INTEL :: 0x8
CL_AVC_ME_SEARCH_WINDOW_16x12_RADIUS_INTEL :: 0x9
CL_AVC_ME_SEARCH_WINDOW_4x4_RADIUS_INTEL :: 0x2
CL_AVC_ME_SEARCH_WINDOW_2x2_RADIUS_INTEL :: 0xa
CL_AVC_ME_SAD_ADJUST_MODE_NONE_INTEL :: 0x0
CL_AVC_ME_SAD_ADJUST_MODE_HAAR_INTEL :: 0x2
CL_AVC_ME_SUBPIXEL_MODE_INTEGER_INTEL :: 0x0
CL_AVC_ME_SUBPIXEL_MODE_HPEL_INTEL :: 0x1
CL_AVC_ME_SUBPIXEL_MODE_QPEL_INTEL :: 0x3
CL_AVC_ME_COST_PRECISION_QPEL_INTEL :: 0x0
CL_AVC_ME_COST_PRECISION_HPEL_INTEL :: 0x1
CL_AVC_ME_COST_PRECISION_PEL_INTEL :: 0x2
CL_AVC_ME_COST_PRECISION_DPEL_INTEL :: 0x3
CL_AVC_ME_BIDIR_WEIGHT_QUARTER_INTEL :: 0x10
CL_AVC_ME_BIDIR_WEIGHT_THIRD_INTEL :: 0x15
CL_AVC_ME_BIDIR_WEIGHT_HALF_INTEL :: 0x20
CL_AVC_ME_BIDIR_WEIGHT_TWO_THIRD_INTEL :: 0x2B
CL_AVC_ME_BIDIR_WEIGHT_THREE_QUARTER_INTEL :: 0x30
CL_AVC_ME_BORDER_REACHED_LEFT_INTEL :: 0x0
CL_AVC_ME_BORDER_REACHED_RIGHT_INTEL :: 0x2
CL_AVC_ME_BORDER_REACHED_TOP_INTEL :: 0x4
CL_AVC_ME_BORDER_REACHED_BOTTOM_INTEL :: 0x8
CL_AVC_ME_SKIP_BLOCK_PARTITION_16x16_INTEL :: 0x0
CL_AVC_ME_SKIP_BLOCK_PARTITION_8x8_INTEL :: 0x4000
CL_AVC_ME_SKIP_BLOCK_16x16_FORWARD_ENABLE_INTEL :: (0x1 << 24)
CL_AVC_ME_SKIP_BLOCK_16x16_BACKWARD_ENABLE_INTEL :: (0x2 << 24)
CL_AVC_ME_SKIP_BLOCK_16x16_DUAL_ENABLE_INTEL :: (0x3 << 24)
CL_AVC_ME_SKIP_BLOCK_8x8_FORWARD_ENABLE_INTEL :: (0x55 << 24)
CL_AVC_ME_SKIP_BLOCK_8x8_BACKWARD_ENABLE_INTEL :: (0xAA << 24)
CL_AVC_ME_SKIP_BLOCK_8x8_DUAL_ENABLE_INTEL :: (0xFF << 24)
CL_AVC_ME_SKIP_BLOCK_8x8_0_FORWARD_ENABLE_INTEL :: (0x1 << 24)
CL_AVC_ME_SKIP_BLOCK_8x8_0_BACKWARD_ENABLE_INTEL :: (0x2 << 24)
CL_AVC_ME_SKIP_BLOCK_8x8_1_FORWARD_ENABLE_INTEL :: (0x1 << 26)
CL_AVC_ME_SKIP_BLOCK_8x8_1_BACKWARD_ENABLE_INTEL :: (0x2 << 26)
CL_AVC_ME_SKIP_BLOCK_8x8_2_FORWARD_ENABLE_INTEL :: (0x1 << 28)
CL_AVC_ME_SKIP_BLOCK_8x8_2_BACKWARD_ENABLE_INTEL :: (0x2 << 28)
CL_AVC_ME_SKIP_BLOCK_8x8_3_FORWARD_ENABLE_INTEL :: (0x1 << 30)
CL_AVC_ME_SKIP_BLOCK_8x8_3_BACKWARD_ENABLE_INTEL :: (0x2 << 30)
CL_AVC_ME_BLOCK_BASED_SKIP_4x4_INTEL :: 0x00
CL_AVC_ME_BLOCK_BASED_SKIP_8x8_INTEL :: 0x80
CL_AVC_ME_INTRA_16x16_INTEL :: 0x0
CL_AVC_ME_INTRA_8x8_INTEL :: 0x1
CL_AVC_ME_INTRA_4x4_INTEL :: 0x2
CL_AVC_ME_INTRA_LUMA_PARTITION_MASK_16x16_INTEL :: 0x6
CL_AVC_ME_INTRA_LUMA_PARTITION_MASK_8x8_INTEL :: 0x5
CL_AVC_ME_INTRA_LUMA_PARTITION_MASK_4x4_INTEL :: 0x3
CL_AVC_ME_INTRA_NEIGHBOR_LEFT_MASK_ENABLE_INTEL :: 0x60
CL_AVC_ME_INTRA_NEIGHBOR_UPPER_MASK_ENABLE_INTEL :: 0x10
CL_AVC_ME_INTRA_NEIGHBOR_UPPER_RIGHT_MASK_ENABLE_INTEL :: 0x8
CL_AVC_ME_INTRA_NEIGHBOR_UPPER_LEFT_MASK_ENABLE_INTEL :: 0x4
CL_AVC_ME_LUMA_PREDICTOR_MODE_VERTICAL_INTEL :: 0x0
CL_AVC_ME_LUMA_PREDICTOR_MODE_HORIZONTAL_INTEL :: 0x1
CL_AVC_ME_LUMA_PREDICTOR_MODE_DC_INTEL :: 0x2
CL_AVC_ME_LUMA_PREDICTOR_MODE_DIAGONAL_DOWN_LEFT_INTEL :: 0x3
CL_AVC_ME_LUMA_PREDICTOR_MODE_DIAGONAL_DOWN_RIGHT_INTEL :: 0x4
CL_AVC_ME_LUMA_PREDICTOR_MODE_PLANE_INTEL :: 0x4
CL_AVC_ME_LUMA_PREDICTOR_MODE_VERTICAL_RIGHT_INTEL :: 0x5
CL_AVC_ME_LUMA_PREDICTOR_MODE_HORIZONTAL_DOWN_INTEL :: 0x6
CL_AVC_ME_LUMA_PREDICTOR_MODE_VERTICAL_LEFT_INTEL :: 0x7
CL_AVC_ME_LUMA_PREDICTOR_MODE_HORIZONTAL_UP_INTEL :: 0x8
CL_AVC_ME_CHROMA_PREDICTOR_MODE_DC_INTEL :: 0x0
CL_AVC_ME_CHROMA_PREDICTOR_MODE_HORIZONTAL_INTEL :: 0x1
CL_AVC_ME_CHROMA_PREDICTOR_MODE_VERTICAL_INTEL :: 0x2
CL_AVC_ME_CHROMA_PREDICTOR_MODE_PLANE_INTEL :: 0x3
CL_AVC_ME_FRAME_FORWARD_INTEL :: 0x1
CL_AVC_ME_FRAME_BACKWARD_INTEL :: 0x2
CL_AVC_ME_FRAME_DUAL_INTEL :: 0x3
CL_AVC_ME_SLICE_TYPE_PRED_INTEL :: 0x0
CL_AVC_ME_SLICE_TYPE_BPRED_INTEL :: 0x1
CL_AVC_ME_SLICE_TYPE_INTRA_INTEL :: 0x2
CL_AVC_ME_INTERLACED_SCAN_TOP_FIELD_INTEL :: 0x0
CL_AVC_ME_INTERLACED_SCAN_BOTTOM_FIELD_INTEL :: 0x1
cl_intel_unified_shared_memory :: 1
CL_INTEL_UNIFIED_SHARED_MEMORY_EXTENSION_NAME :: "cl_intel_unified_shared_memory"
CL_INTEL_UNIFIED_SHARED_MEMORY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_DEVICE_HOST_MEM_CAPABILITIES_INTEL :: 0x4190
CL_DEVICE_DEVICE_MEM_CAPABILITIES_INTEL :: 0x4191
CL_DEVICE_SINGLE_DEVICE_SHARED_MEM_CAPABILITIES_INTEL :: 0x4192
CL_DEVICE_CROSS_DEVICE_SHARED_MEM_CAPABILITIES_INTEL :: 0x4193
CL_DEVICE_SHARED_SYSTEM_MEM_CAPABILITIES_INTEL :: 0x4194
CL_UNIFIED_SHARED_MEMORY_ACCESS_INTEL :: (1 << 0)
CL_UNIFIED_SHARED_MEMORY_ATOMIC_ACCESS_INTEL :: (1 << 1)
CL_UNIFIED_SHARED_MEMORY_CONCURRENT_ACCESS_INTEL :: (1 << 2)
CL_UNIFIED_SHARED_MEMORY_CONCURRENT_ATOMIC_ACCESS_INTEL :: (1 << 3)
CL_MEM_ALLOC_FLAGS_INTEL :: 0x4195
CL_MEM_ALLOC_WRITE_COMBINED_INTEL :: (1 << 0)
CL_MEM_ALLOC_INITIAL_PLACEMENT_DEVICE_INTEL :: (1 << 1)
CL_MEM_ALLOC_INITIAL_PLACEMENT_HOST_INTEL :: (1 << 2)
CL_MEM_ALLOC_TYPE_INTEL :: 0x419A
CL_MEM_ALLOC_BASE_PTR_INTEL :: 0x419B
CL_MEM_ALLOC_SIZE_INTEL :: 0x419C
CL_MEM_ALLOC_DEVICE_INTEL :: 0x419D
CL_MEM_TYPE_UNKNOWN_INTEL :: 0x4196
CL_MEM_TYPE_HOST_INTEL :: 0x4197
CL_MEM_TYPE_DEVICE_INTEL :: 0x4198
CL_MEM_TYPE_SHARED_INTEL :: 0x4199
CL_KERNEL_EXEC_INFO_INDIRECT_HOST_ACCESS_INTEL :: 0x4200
CL_KERNEL_EXEC_INFO_INDIRECT_DEVICE_ACCESS_INTEL :: 0x4201
CL_KERNEL_EXEC_INFO_INDIRECT_SHARED_ACCESS_INTEL :: 0x4202
CL_KERNEL_EXEC_INFO_USM_PTRS_INTEL :: 0x4203
CL_COMMAND_MEMFILL_INTEL :: 0x4204
CL_COMMAND_MEMCPY_INTEL :: 0x4205
CL_COMMAND_MIGRATEMEM_INTEL :: 0x4206
CL_COMMAND_MEMADVISE_INTEL :: 0x4207
cl_intel_mem_alloc_buffer_location :: 1
CL_INTEL_MEM_ALLOC_BUFFER_LOCATION_EXTENSION_NAME :: "cl_intel_mem_alloc_buffer_location"
CL_INTEL_MEM_ALLOC_BUFFER_LOCATION_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_ALLOC_BUFFER_LOCATION_INTEL :: 0x419E
cl_intel_create_buffer_with_properties :: 1
CL_INTEL_CREATE_BUFFER_WITH_PROPERTIES_EXTENSION_NAME :: "cl_intel_create_buffer_with_properties"
CL_INTEL_CREATE_BUFFER_WITH_PROPERTIES_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
cl_intel_program_scope_host_pipe :: 1
CL_INTEL_PROGRAM_SCOPE_HOST_PIPE_EXTENSION_NAME :: "cl_intel_program_scope_host_pipe"
CL_INTEL_PROGRAM_SCOPE_HOST_PIPE_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_COMMAND_READ_HOST_PIPE_INTEL :: 0x4214
CL_COMMAND_WRITE_HOST_PIPE_INTEL :: 0x4215
CL_PROGRAM_NUM_HOST_PIPES_INTEL :: 0x4216
CL_PROGRAM_HOST_PIPE_NAMES_INTEL :: 0x4217
cl_intel_mem_channel_property :: 1
CL_INTEL_MEM_CHANNEL_PROPERTY_EXTENSION_NAME :: "cl_intel_mem_channel_property"
CL_INTEL_MEM_CHANNEL_PROPERTY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_CHANNEL_INTEL :: 0x4213
cl_intel_mem_force_host_memory :: 1
CL_INTEL_MEM_FORCE_HOST_MEMORY_EXTENSION_NAME :: "cl_intel_mem_force_host_memory"
CL_INTEL_MEM_FORCE_HOST_MEMORY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_FORCE_HOST_MEMORY_INTEL :: (1 << 20)
cl_intel_command_queue_families :: 1
CL_INTEL_COMMAND_QUEUE_FAMILIES_EXTENSION_NAME :: "cl_intel_command_queue_families"
CL_INTEL_COMMAND_QUEUE_FAMILIES_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_QUEUE_FAMILY_MAX_NAME_SIZE_INTEL :: 64
CL_DEVICE_QUEUE_FAMILY_PROPERTIES_INTEL :: 0x418B
CL_QUEUE_FAMILY_INTEL :: 0x418C
CL_QUEUE_INDEX_INTEL :: 0x418D
CL_QUEUE_DEFAULT_CAPABILITIES_INTEL :: 0
CL_QUEUE_CAPABILITY_CREATE_SINGLE_QUEUE_EVENTS_INTEL :: (1 << 0)
CL_QUEUE_CAPABILITY_CREATE_CROSS_QUEUE_EVENTS_INTEL :: (1 << 1)
CL_QUEUE_CAPABILITY_SINGLE_QUEUE_EVENT_WAIT_LIST_INTEL :: (1 << 2)
CL_QUEUE_CAPABILITY_CROSS_QUEUE_EVENT_WAIT_LIST_INTEL :: (1 << 3)
CL_QUEUE_CAPABILITY_TRANSFER_BUFFER_INTEL :: (1 << 8)
CL_QUEUE_CAPABILITY_TRANSFER_BUFFER_RECT_INTEL :: (1 << 9)
CL_QUEUE_CAPABILITY_MAP_BUFFER_INTEL :: (1 << 10)
CL_QUEUE_CAPABILITY_FILL_BUFFER_INTEL :: (1 << 11)
CL_QUEUE_CAPABILITY_TRANSFER_IMAGE_INTEL :: (1 << 12)
CL_QUEUE_CAPABILITY_MAP_IMAGE_INTEL :: (1 << 13)
CL_QUEUE_CAPABILITY_FILL_IMAGE_INTEL :: (1 << 14)
CL_QUEUE_CAPABILITY_TRANSFER_BUFFER_IMAGE_INTEL :: (1 << 15)
CL_QUEUE_CAPABILITY_TRANSFER_IMAGE_BUFFER_INTEL :: (1 << 16)
CL_QUEUE_CAPABILITY_MARKER_INTEL :: (1 << 24)
CL_QUEUE_CAPABILITY_BARRIER_INTEL :: (1 << 25)
CL_QUEUE_CAPABILITY_KERNEL_INTEL :: (1 << 26)
cl_intel_queue_no_sync_operations :: 1
CL_INTEL_QUEUE_NO_SYNC_OPERATIONS_EXTENSION_NAME :: "cl_intel_queue_no_sync_operations"
CL_INTEL_QUEUE_NO_SYNC_OPERATIONS_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_QUEUE_NO_SYNC_OPERATIONS_INTEL :: (1 << 29)
cl_intel_sharing_format_query :: 1
CL_INTEL_SHARING_FORMAT_QUERY_EXTENSION_NAME :: "cl_intel_sharing_format_query"
CL_INTEL_SHARING_FORMAT_QUERY_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
cl_ext_image_requirements_info :: 1
CL_EXT_IMAGE_REQUIREMENTS_INFO_EXTENSION_NAME :: "cl_ext_image_requirements_info"
CL_EXT_IMAGE_REQUIREMENTS_INFO_EXTENSION_VERSION := CL_MAKE_VERSION(0, 5, 0)
CL_IMAGE_REQUIREMENTS_BASE_ADDRESS_ALIGNMENT_EXT :: 0x1292
CL_IMAGE_REQUIREMENTS_ROW_PITCH_ALIGNMENT_EXT :: 0x1290
CL_IMAGE_REQUIREMENTS_SIZE_EXT :: 0x12B2
CL_IMAGE_REQUIREMENTS_MAX_WIDTH_EXT :: 0x12B3
CL_IMAGE_REQUIREMENTS_MAX_HEIGHT_EXT :: 0x12B4
CL_IMAGE_REQUIREMENTS_MAX_DEPTH_EXT :: 0x12B5
CL_IMAGE_REQUIREMENTS_MAX_ARRAY_SIZE_EXT :: 0x12B6
cl_ext_image_from_buffer :: 1
CL_EXT_IMAGE_FROM_BUFFER_EXTENSION_NAME :: "cl_ext_image_from_buffer"
CL_EXT_IMAGE_FROM_BUFFER_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_IMAGE_REQUIREMENTS_SLICE_PITCH_ALIGNMENT_EXT :: 0x1291
cl_loader_info :: 1
CL_LOADER_INFO_EXTENSION_NAME :: "cl_loader_info"
CL_LOADER_INFO_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_ICDL_OCL_VERSION :: 1
CL_ICDL_VERSION :: 2
CL_ICDL_NAME :: 3
CL_ICDL_VENDOR :: 4
cl_khr_depth_images :: 1
CL_KHR_DEPTH_IMAGES_EXTENSION_NAME :: "cl_khr_depth_images"
CL_KHR_DEPTH_IMAGES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_ext_float_atomics :: 1
CL_EXT_FLOAT_ATOMICS_EXTENSION_NAME :: "cl_ext_float_atomics"
CL_EXT_FLOAT_ATOMICS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEVICE_GLOBAL_FP_ATOMIC_LOAD_STORE_EXT :: (1 << 0)
CL_DEVICE_GLOBAL_FP_ATOMIC_ADD_EXT :: (1 << 1)
CL_DEVICE_GLOBAL_FP_ATOMIC_MIN_MAX_EXT :: (1 << 2)
CL_DEVICE_LOCAL_FP_ATOMIC_LOAD_STORE_EXT :: (1 << 16)
CL_DEVICE_LOCAL_FP_ATOMIC_ADD_EXT :: (1 << 17)
CL_DEVICE_LOCAL_FP_ATOMIC_MIN_MAX_EXT :: (1 << 18)
CL_DEVICE_SINGLE_FP_ATOMIC_CAPABILITIES_EXT :: 0x4231
CL_DEVICE_DOUBLE_FP_ATOMIC_CAPABILITIES_EXT :: 0x4232
CL_DEVICE_HALF_FP_ATOMIC_CAPABILITIES_EXT :: 0x4233
cl_intel_create_mem_object_properties :: 1
CL_INTEL_CREATE_MEM_OBJECT_PROPERTIES_EXTENSION_NAME :: "cl_intel_create_mem_object_properties"
CL_INTEL_CREATE_MEM_OBJECT_PROPERTIES_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_MEM_LOCALLY_UNCACHED_RESOURCE_INTEL :: 0x4218
CL_MEM_DEVICE_ID_INTEL :: 0x4219
cl_pocl_content_size :: 1
CL_POCL_CONTENT_SIZE_EXTENSION_NAME :: "cl_pocl_content_size"
CL_POCL_CONTENT_SIZE_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
cl_ext_image_raw10_raw12 :: 1
CL_EXT_IMAGE_RAW10_RAW12_EXTENSION_NAME :: "cl_ext_image_raw10_raw12"
CL_EXT_IMAGE_RAW10_RAW12_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_UNSIGNED_INT_RAW10_EXT :: 0x10E3
CL_UNSIGNED_INT_RAW12_EXT :: 0x10E4
cl_khr_3d_image_writes :: 1
CL_KHR_3D_IMAGE_WRITES_EXTENSION_NAME :: "cl_khr_3d_image_writes"
CL_KHR_3D_IMAGE_WRITES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_async_work_group_copy_fence :: 1
CL_KHR_ASYNC_WORK_GROUP_COPY_FENCE_EXTENSION_NAME :: "cl_khr_async_work_group_copy_fence"
CL_KHR_ASYNC_WORK_GROUP_COPY_FENCE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_byte_addressable_store :: 1
CL_KHR_BYTE_ADDRESSABLE_STORE_EXTENSION_NAME :: "cl_khr_byte_addressable_store"
CL_KHR_BYTE_ADDRESSABLE_STORE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_device_enqueue_local_arg_types :: 1
CL_KHR_DEVICE_ENQUEUE_LOCAL_ARG_TYPES_EXTENSION_NAME :: "cl_khr_device_enqueue_local_arg_types"
CL_KHR_DEVICE_ENQUEUE_LOCAL_ARG_TYPES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_expect_assume :: 1
CL_KHR_EXPECT_ASSUME_EXTENSION_NAME :: "cl_khr_expect_assume"
CL_KHR_EXPECT_ASSUME_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_extended_async_copies :: 1
CL_KHR_EXTENDED_ASYNC_COPIES_EXTENSION_NAME :: "cl_khr_extended_async_copies"
CL_KHR_EXTENDED_ASYNC_COPIES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_extended_bit_ops :: 1
CL_KHR_EXTENDED_BIT_OPS_EXTENSION_NAME :: "cl_khr_extended_bit_ops"
CL_KHR_EXTENDED_BIT_OPS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_global_int32_base_atomics :: 1
CL_KHR_GLOBAL_INT32_BASE_ATOMICS_EXTENSION_NAME :: "cl_khr_global_int32_base_atomics"
CL_KHR_GLOBAL_INT32_BASE_ATOMICS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_global_int32_extended_atomics :: 1
CL_KHR_GLOBAL_INT32_EXTENDED_ATOMICS_EXTENSION_NAME :: "cl_khr_global_int32_extended_atomics"
CL_KHR_GLOBAL_INT32_EXTENDED_ATOMICS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_int64_base_atomics :: 1
CL_KHR_INT64_BASE_ATOMICS_EXTENSION_NAME :: "cl_khr_int64_base_atomics"
CL_KHR_INT64_BASE_ATOMICS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_int64_extended_atomics :: 1
CL_KHR_INT64_EXTENDED_ATOMICS_EXTENSION_NAME :: "cl_khr_int64_extended_atomics"
CL_KHR_INT64_EXTENDED_ATOMICS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_kernel_clock :: 1
CL_KHR_KERNEL_CLOCK_EXTENSION_NAME :: "cl_khr_kernel_clock"
CL_KHR_KERNEL_CLOCK_EXTENSION_VERSION := CL_MAKE_VERSION(0, 9, 0)
CL_DEVICE_KERNEL_CLOCK_CAPABILITIES_KHR :: 0x1076
CL_DEVICE_KERNEL_CLOCK_SCOPE_DEVICE_KHR :: (1 << 0)
CL_DEVICE_KERNEL_CLOCK_SCOPE_WORK_GROUP_KHR :: (1 << 1)
CL_DEVICE_KERNEL_CLOCK_SCOPE_SUB_GROUP_KHR :: (1 << 2)
cl_khr_local_int32_base_atomics :: 1
CL_KHR_LOCAL_INT32_BASE_ATOMICS_EXTENSION_NAME :: "cl_khr_local_int32_base_atomics"
CL_KHR_LOCAL_INT32_BASE_ATOMICS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_local_int32_extended_atomics :: 1
CL_KHR_LOCAL_INT32_EXTENDED_ATOMICS_EXTENSION_NAME :: "cl_khr_local_int32_extended_atomics"
CL_KHR_LOCAL_INT32_EXTENDED_ATOMICS_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_mipmap_image_writes :: 1
CL_KHR_MIPMAP_IMAGE_WRITES_EXTENSION_NAME :: "cl_khr_mipmap_image_writes"
CL_KHR_MIPMAP_IMAGE_WRITES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_select_fprounding_mode :: 1
CL_KHR_SELECT_FPROUNDING_MODE_EXTENSION_NAME :: "cl_khr_select_fprounding_mode"
CL_KHR_SELECT_FPROUNDING_MODE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_spirv_extended_debug_info :: 1
CL_KHR_SPIRV_EXTENDED_DEBUG_INFO_EXTENSION_NAME :: "cl_khr_spirv_extended_debug_info"
CL_KHR_SPIRV_EXTENDED_DEBUG_INFO_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_spirv_linkonce_odr :: 1
CL_KHR_SPIRV_LINKONCE_ODR_EXTENSION_NAME :: "cl_khr_spirv_linkonce_odr"
CL_KHR_SPIRV_LINKONCE_ODR_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_spirv_no_integer_wrap_decoration :: 1
CL_KHR_SPIRV_NO_INTEGER_WRAP_DECORATION_EXTENSION_NAME :: "cl_khr_spirv_no_integer_wrap_decoration"
CL_KHR_SPIRV_NO_INTEGER_WRAP_DECORATION_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_srgb_image_writes :: 1
CL_KHR_SRGB_IMAGE_WRITES_EXTENSION_NAME :: "cl_khr_srgb_image_writes"
CL_KHR_SRGB_IMAGE_WRITES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_ballot :: 1
CL_KHR_SUBGROUP_BALLOT_EXTENSION_NAME :: "cl_khr_subgroup_ballot"
CL_KHR_SUBGROUP_BALLOT_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_clustered_reduce :: 1
CL_KHR_SUBGROUP_CLUSTERED_REDUCE_EXTENSION_NAME :: "cl_khr_subgroup_clustered_reduce"
CL_KHR_SUBGROUP_CLUSTERED_REDUCE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_extended_types :: 1
CL_KHR_SUBGROUP_EXTENDED_TYPES_EXTENSION_NAME :: "cl_khr_subgroup_extended_types"
CL_KHR_SUBGROUP_EXTENDED_TYPES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_non_uniform_arithmetic :: 1
CL_KHR_SUBGROUP_NON_UNIFORM_ARITHMETIC_EXTENSION_NAME :: "cl_khr_subgroup_non_uniform_arithmetic"
CL_KHR_SUBGROUP_NON_UNIFORM_ARITHMETIC_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_non_uniform_vote :: 1
CL_KHR_SUBGROUP_NON_UNIFORM_VOTE_EXTENSION_NAME :: "cl_khr_subgroup_non_uniform_vote"
CL_KHR_SUBGROUP_NON_UNIFORM_VOTE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_rotate :: 1
CL_KHR_SUBGROUP_ROTATE_EXTENSION_NAME :: "cl_khr_subgroup_rotate"
CL_KHR_SUBGROUP_ROTATE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_shuffle :: 1
CL_KHR_SUBGROUP_SHUFFLE_EXTENSION_NAME :: "cl_khr_subgroup_shuffle"
CL_KHR_SUBGROUP_SHUFFLE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_subgroup_shuffle_relative :: 1
CL_KHR_SUBGROUP_SHUFFLE_RELATIVE_EXTENSION_NAME :: "cl_khr_subgroup_shuffle_relative"
CL_KHR_SUBGROUP_SHUFFLE_RELATIVE_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_khr_work_group_uniform_arithmetic :: 1
CL_KHR_WORK_GROUP_UNIFORM_ARITHMETIC_EXTENSION_NAME :: "cl_khr_work_group_uniform_arithmetic"
CL_KHR_WORK_GROUP_UNIFORM_ARITHMETIC_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
cl_ext_image_unorm_int_2_101010 :: 1
CL_EXT_IMAGE_UNORM_INT_2_101010_EXTENSION_NAME :: "cl_ext_image_unorm_int_2_101010"
CL_EXT_IMAGE_UNORM_INT_2_101010_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_UNORM_INT_2_101010_EXT :: 0x10E5
cl_img_cancel_command :: 1
CL_IMG_CANCEL_COMMAND_EXTENSION_NAME :: "cl_img_cancel_command"
CL_IMG_CANCEL_COMMAND_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)
CL_CANCELLED_IMG :: -1126

cl_device_command_buffer_capabilities_khr                 :: cl_bitfield
cl_command_buffer_khr                                     :: distinct rawptr
cl_sync_point_khr                                         :: cl_uint
cl_command_buffer_info_khr                                :: cl_uint
cl_command_buffer_state_khr                               :: cl_uint
cl_command_buffer_properties_khr                          :: cl_properties
cl_command_buffer_flags_khr                               :: cl_bitfield
cl_command_properties_khr                                 :: cl_properties
cl_mutable_command_khr                                    :: distinct rawptr
clCreateCommandBufferKHR_t                                :: #type proc "stdcall" (num_queues: cl_uint, queues: ^cl_command_queue, properties: ^cl_command_buffer_properties_khr, errcode_ret: ^cl_int) -> cl_command_buffer_khr
clCreateCommandBufferKHR_fn                               :: ^clCreateCommandBufferKHR_t
clFinalizeCommandBufferKHR_t                              :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int
clFinalizeCommandBufferKHR_fn                             :: ^clFinalizeCommandBufferKHR_t
clRetainCommandBufferKHR_t                                :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int
clRetainCommandBufferKHR_fn                               :: ^clRetainCommandBufferKHR_t
clReleaseCommandBufferKHR_t                               :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int
clReleaseCommandBufferKHR_fn                              :: ^clReleaseCommandBufferKHR_t
clEnqueueCommandBufferKHR_t                               :: #type proc "stdcall" (num_queues: cl_uint, queues: ^cl_command_queue, command_buffer: cl_command_buffer_khr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueCommandBufferKHR_fn                              :: ^clEnqueueCommandBufferKHR_t
clCommandBarrierWithWaitListKHR_t                         :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandBarrierWithWaitListKHR_fn                        :: ^clCommandBarrierWithWaitListKHR_t
clCommandCopyBufferKHR_t                                  :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, src_buffer: cl_mem, dst_buffer: cl_mem, src_offset: c.size_t, dst_offset: c.size_t, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandCopyBufferKHR_fn                                 :: ^clCommandCopyBufferKHR_t
clCommandCopyBufferRectKHR_t                              :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, src_buffer: cl_mem, dst_buffer: cl_mem, src_origin: ^c.size_t, dst_origin: ^c.size_t, region: ^c.size_t, src_row_pitch: c.size_t, src_slice_pitch: c.size_t, dst_row_pitch: c.size_t, dst_slice_pitch: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandCopyBufferRectKHR_fn                             :: ^clCommandCopyBufferRectKHR_t
clCommandCopyBufferToImageKHR_t                           :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, src_buffer: cl_mem, dst_image: cl_mem, src_offset: c.size_t, dst_origin: ^c.size_t, region: ^c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandCopyBufferToImageKHR_fn                          :: ^clCommandCopyBufferToImageKHR_t
clCommandCopyImageKHR_t                                   :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, src_image: cl_mem, dst_image: cl_mem, src_origin: ^c.size_t, dst_origin: ^c.size_t, region: ^c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandCopyImageKHR_fn                                  :: ^clCommandCopyImageKHR_t
clCommandCopyImageToBufferKHR_t                           :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, src_image: cl_mem, dst_buffer: cl_mem, src_origin: ^c.size_t, region: ^c.size_t, dst_offset: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandCopyImageToBufferKHR_fn                          :: ^clCommandCopyImageToBufferKHR_t
clCommandFillBufferKHR_t                                  :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, buffer: cl_mem, pattern: rawptr, pattern_size: c.size_t, offset: c.size_t, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandFillBufferKHR_fn                                 :: ^clCommandFillBufferKHR_t
clCommandFillImageKHR_t                                   :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, image: cl_mem, fill_color: rawptr, origin: ^c.size_t, region: ^c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandFillImageKHR_fn                                  :: ^clCommandFillImageKHR_t
clCommandNDRangeKernelKHR_t                               :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, kernel: cl_kernel, work_dim: cl_uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, local_work_size: ^c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandNDRangeKernelKHR_fn                              :: ^clCommandNDRangeKernelKHR_t
clGetCommandBufferInfoKHR_t                               :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, param_name: cl_command_buffer_info_khr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetCommandBufferInfoKHR_fn                              :: ^clGetCommandBufferInfoKHR_t
clCommandSVMMemcpyKHR_t                                   :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandSVMMemcpyKHR_fn                                  :: ^clCommandSVMMemcpyKHR_t
clCommandSVMMemFillKHR_t                                  :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, command_queue: cl_command_queue, properties: ^cl_command_properties_khr, svm_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_sync_points_in_wait_list: cl_uint, sync_point_wait_list: ^cl_sync_point_khr, sync_point: ^cl_sync_point_khr, mutable_handle: ^cl_mutable_command_khr) -> cl_int
clCommandSVMMemFillKHR_fn                                 :: ^clCommandSVMMemFillKHR_t
cl_platform_command_buffer_capabilities_khr               :: cl_bitfield
clRemapCommandBufferKHR_t                                 :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, automatic: cl_bool, num_queues: cl_uint, queues: ^cl_command_queue, num_handles: cl_uint, handles: ^cl_mutable_command_khr, handles_ret: ^cl_mutable_command_khr, errcode_ret: ^cl_int) -> cl_command_buffer_khr
clRemapCommandBufferKHR_fn                                :: ^clRemapCommandBufferKHR_t
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
	arg_list: ^cl_mutable_dispatch_arg_khr,
	arg_svm_list: ^cl_mutable_dispatch_arg_khr,
	exec_info_list: ^cl_mutable_dispatch_exec_info_khr,
	global_work_offset: ^c.size_t,
	global_work_size: ^c.size_t,
	local_work_size: ^c.size_t,
}
cl_mutable_dispatch_asserts_khr                           :: cl_bitfield
clUpdateMutableCommandsKHR_t                              :: #type proc "stdcall" (command_buffer: cl_command_buffer_khr, num_configs: cl_uint, config_types: ^cl_command_buffer_update_type_khr, configs: ^rawptr) -> cl_int
clUpdateMutableCommandsKHR_fn                             :: ^clUpdateMutableCommandsKHR_t
clGetMutableCommandInfoKHR_t                              :: #type proc "stdcall" (command: cl_mutable_command_khr, param_name: cl_mutable_command_info_khr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetMutableCommandInfoKHR_fn                             :: ^clGetMutableCommandInfoKHR_t
clSetMemObjectDestructorAPPLE_t                           :: #type proc "stdcall" (memobj: cl_mem, pfn_notify: #type proc "stdcall" (memobj: cl_mem, user_data: rawptr), user_data: rawptr) -> cl_int
clSetMemObjectDestructorAPPLE_fn                          :: ^clSetMemObjectDestructorAPPLE_t
clLogMessagesToSystemLogAPPLE_t                           :: #type proc "stdcall" (errstr: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr)
clLogMessagesToSystemLogAPPLE_fn                          :: ^clLogMessagesToSystemLogAPPLE_t
clLogMessagesToStdoutAPPLE_t                              :: #type proc "stdcall" (errstr: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr)
clLogMessagesToStdoutAPPLE_fn                             :: ^clLogMessagesToStdoutAPPLE_t
clLogMessagesToStderrAPPLE_t                              :: #type proc "stdcall" (errstr: ^c.schar, private_info: rawptr, cb: c.size_t, user_data: rawptr)
clLogMessagesToStderrAPPLE_fn                             :: ^clLogMessagesToStderrAPPLE_t
clIcdGetPlatformIDsKHR_t                                  :: #type proc "stdcall" (num_entries: cl_uint, platforms: ^cl_platform_id, num_platforms: ^cl_uint) -> cl_int
clIcdGetPlatformIDsKHR_fn                                 :: ^clIcdGetPlatformIDsKHR_t
clCreateProgramWithILKHR_t                                :: #type proc "stdcall" (_context: cl_context, il: rawptr, length: c.size_t, errcode_ret: ^cl_int) -> cl_program
clCreateProgramWithILKHR_fn                               :: ^clCreateProgramWithILKHR_t
cl_context_memory_initialize_khr                          :: cl_bitfield
cl_device_terminate_capability_khr                        :: cl_bitfield
clTerminateContextKHR_t                                   :: #type proc "stdcall" (_context: cl_context) -> cl_int
clTerminateContextKHR_fn                                  :: ^clTerminateContextKHR_t
cl_queue_properties_khr                                   :: cl_properties
clCreateCommandQueueWithPropertiesKHR_t                   :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: ^cl_queue_properties_khr, errcode_ret: ^cl_int) -> cl_command_queue
clCreateCommandQueueWithPropertiesKHR_fn                  :: ^clCreateCommandQueueWithPropertiesKHR_t
cl_device_partition_property_ext                          :: cl_ulong
clReleaseDeviceEXT_t                                      :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clReleaseDeviceEXT_fn                                     :: ^clReleaseDeviceEXT_t
clRetainDeviceEXT_t                                       :: #type proc "stdcall" (device: cl_device_id) -> cl_int
clRetainDeviceEXT_fn                                      :: ^clRetainDeviceEXT_t
clCreateSubDevicesEXT_t                                   :: #type proc "stdcall" (in_device: cl_device_id, properties: ^cl_device_partition_property_ext, num_entries: cl_uint, out_devices: ^cl_device_id, num_devices: ^cl_uint) -> cl_int
clCreateSubDevicesEXT_fn                                  :: ^clCreateSubDevicesEXT_t
cl_mem_migration_flags_ext                                :: cl_bitfield
clEnqueueMigrateMemObjectEXT_t                            :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: ^cl_mem, flags: cl_mem_migration_flags_ext, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMigrateMemObjectEXT_fn                           :: ^clEnqueueMigrateMemObjectEXT_t
cl_image_pitch_info_qcom                                  :: cl_uint
cl_mem_ext_host_ptr                                       :: struct{
	allocation_type: cl_uint,
	host_cache_policy: cl_uint,
}
clGetDeviceImageInfoQCOM_t                                :: #type proc "stdcall" (device: cl_device_id, image_width: c.size_t, image_height: c.size_t, image_format: ^cl_image_format, param_name: cl_image_pitch_info_qcom, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetDeviceImageInfoQCOM_fn                               :: ^clGetDeviceImageInfoQCOM_t
cl_mem_ion_host_ptr                                       :: struct{
	ext_host_ptr: cl_mem_ext_host_ptr,
	ion_filedesc: c.int,
	ion_hostptr: rawptr,
}
cl_mem_android_native_buffer_host_ptr                     :: struct{
	ext_host_ptr: cl_mem_ext_host_ptr,
	anb_ptr: rawptr,
}
clEnqueueAcquireGrallocObjectsIMG_t                       :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueAcquireGrallocObjectsIMG_fn                      :: ^clEnqueueAcquireGrallocObjectsIMG_t
clEnqueueReleaseGrallocObjectsIMG_t                       :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReleaseGrallocObjectsIMG_fn                      :: ^clEnqueueReleaseGrallocObjectsIMG_t
cl_mipmap_filter_mode_img                                 :: cl_uint
clEnqueueGenerateMipmapIMG_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, src_image: cl_mem, dst_image: cl_mem, mipmap_filter_mode: cl_mipmap_filter_mode_img, array_region: ^c.size_t, mip_region: ^c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueGenerateMipmapIMG_fn                             :: ^clEnqueueGenerateMipmapIMG_t
clGetKernelSubGroupInfoKHR_t                              :: #type proc "stdcall" (in_kernel: cl_kernel, in_device: cl_device_id, param_name: cl_kernel_sub_group_info, input_value_size: c.size_t, input_value: rawptr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetKernelSubGroupInfoKHR_fn                             :: ^clGetKernelSubGroupInfoKHR_t
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
clGetKernelSuggestedLocalWorkSizeKHR_t                    :: #type proc "stdcall" (command_queue: cl_command_queue, kernel: cl_kernel, work_dim: cl_uint, global_work_offset: ^c.size_t, global_work_size: ^c.size_t, suggested_local_work_size: ^c.size_t) -> cl_int
clGetKernelSuggestedLocalWorkSizeKHR_fn                   :: ^clGetKernelSuggestedLocalWorkSizeKHR_t
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
clEnqueueAcquireExternalMemObjectsKHR_t                   :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueAcquireExternalMemObjectsKHR_fn                  :: ^clEnqueueAcquireExternalMemObjectsKHR_t
clEnqueueReleaseExternalMemObjectsKHR_t                   :: #type proc "stdcall" (command_queue: cl_command_queue, num_mem_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReleaseExternalMemObjectsKHR_fn                  :: ^clEnqueueReleaseExternalMemObjectsKHR_t
cl_semaphore_khr                                          :: distinct rawptr
cl_external_semaphore_handle_type_khr                     :: cl_uint
clGetSemaphoreHandleForTypeKHR_t                          :: #type proc "stdcall" (sema_object: cl_semaphore_khr, device: cl_device_id, handle_type: cl_external_semaphore_handle_type_khr, handle_size: c.size_t, handle_ptr: rawptr, handle_size_ret: ^c.size_t) -> cl_int
clGetSemaphoreHandleForTypeKHR_fn                         :: ^clGetSemaphoreHandleForTypeKHR_t
cl_semaphore_reimport_properties_khr                      :: cl_properties
clReImportSemaphoreSyncFdKHR_t                            :: #type proc "stdcall" (sema_object: cl_semaphore_khr, reimport_props: ^cl_semaphore_reimport_properties_khr, fd: c.int) -> cl_int
clReImportSemaphoreSyncFdKHR_fn                           :: ^clReImportSemaphoreSyncFdKHR_t
cl_semaphore_properties_khr                               :: cl_properties
cl_semaphore_info_khr                                     :: cl_uint
cl_semaphore_type_khr                                     :: cl_uint
cl_semaphore_payload_khr                                  :: cl_ulong
clCreateSemaphoreWithPropertiesKHR_t                      :: #type proc "stdcall" (_context: cl_context, sema_props: ^cl_semaphore_properties_khr, errcode_ret: ^cl_int) -> cl_semaphore_khr
clCreateSemaphoreWithPropertiesKHR_fn                     :: ^clCreateSemaphoreWithPropertiesKHR_t
clEnqueueWaitSemaphoresKHR_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, num_sema_objects: cl_uint, sema_objects: ^cl_semaphore_khr, sema_payload_list: ^cl_semaphore_payload_khr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueWaitSemaphoresKHR_fn                             :: ^clEnqueueWaitSemaphoresKHR_t
clEnqueueSignalSemaphoresKHR_t                            :: #type proc "stdcall" (command_queue: cl_command_queue, num_sema_objects: cl_uint, sema_objects: ^cl_semaphore_khr, sema_payload_list: ^cl_semaphore_payload_khr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSignalSemaphoresKHR_fn                           :: ^clEnqueueSignalSemaphoresKHR_t
clGetSemaphoreInfoKHR_t                                   :: #type proc "stdcall" (sema_object: cl_semaphore_khr, param_name: cl_semaphore_info_khr, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetSemaphoreInfoKHR_fn                                  :: ^clGetSemaphoreInfoKHR_t
clReleaseSemaphoreKHR_t                                   :: #type proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int
clReleaseSemaphoreKHR_fn                                  :: ^clReleaseSemaphoreKHR_t
clRetainSemaphoreKHR_t                                    :: #type proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int
clRetainSemaphoreKHR_fn                                   :: ^clRetainSemaphoreKHR_t
cl_import_properties_arm                                  :: c.intptr_t
clImportMemoryARM_t                                       :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, properties: ^cl_import_properties_arm, memory: rawptr, size: c.size_t, errcode_ret: ^cl_int) -> cl_mem
clImportMemoryARM_fn                                      :: ^clImportMemoryARM_t
cl_svm_mem_flags_arm                                      :: cl_bitfield
cl_kernel_exec_info_arm                                   :: cl_uint
cl_device_svm_capabilities_arm                            :: cl_bitfield
clSVMAllocARM_t                                           :: #type proc "stdcall" (_context: cl_context, flags: cl_svm_mem_flags_arm, size: c.size_t, alignment: cl_uint) -> rawptr
clSVMAllocARM_fn                                          :: ^clSVMAllocARM_t
clSVMFreeARM_t                                            :: #type proc "stdcall" (_context: cl_context, svm_pointer: rawptr)
clSVMFreeARM_fn                                           :: ^clSVMFreeARM_t
clEnqueueSVMFreeARM_t                                     :: #type proc "stdcall" (command_queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, pfn_free_func: #type proc "stdcall" (queue: cl_command_queue, num_svm_pointers: cl_uint, svm_pointers: []rawptr, user_data: rawptr), user_data: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMFreeARM_fn                                    :: ^clEnqueueSVMFreeARM_t
clEnqueueSVMMemcpyARM_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_copy: cl_bool, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMMemcpyARM_fn                                  :: ^clEnqueueSVMMemcpyARM_t
clEnqueueSVMMemFillARM_t                                  :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMMemFillARM_fn                                 :: ^clEnqueueSVMMemFillARM_t
clEnqueueSVMMapARM_t                                      :: #type proc "stdcall" (command_queue: cl_command_queue, blocking_map: cl_bool, flags: cl_map_flags, svm_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMMapARM_fn                                     :: ^clEnqueueSVMMapARM_t
clEnqueueSVMUnmapARM_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, svm_ptr: rawptr, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueSVMUnmapARM_fn                                   :: ^clEnqueueSVMUnmapARM_t
clSetKernelArgSVMPointerARM_t                             :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_value: rawptr) -> cl_int
clSetKernelArgSVMPointerARM_fn                            :: ^clSetKernelArgSVMPointerARM_t
clSetKernelExecInfoARM_t                                  :: #type proc "stdcall" (kernel: cl_kernel, param_name: cl_kernel_exec_info_arm, param_value_size: c.size_t, param_value: rawptr) -> cl_int
clSetKernelExecInfoARM_fn                                 :: ^clSetKernelExecInfoARM_t
cl_device_scheduling_controls_capabilities_arm            :: cl_bitfield
cl_device_controlled_termination_capabilities_arm         :: cl_bitfield
cl_device_feature_capabilities_intel                      :: cl_bitfield
cl_accelerator_intel                                      :: distinct rawptr
cl_accelerator_type_intel                                 :: cl_uint
cl_accelerator_info_intel                                 :: cl_uint
clCreateAcceleratorINTEL_t                                :: #type proc "stdcall" (_context: cl_context, accelerator_type: cl_accelerator_type_intel, descriptor_size: c.size_t, descriptor: rawptr, errcode_ret: ^cl_int) -> cl_accelerator_intel
clCreateAcceleratorINTEL_fn                               :: ^clCreateAcceleratorINTEL_t
clGetAcceleratorInfoINTEL_t                               :: #type proc "stdcall" (accelerator: cl_accelerator_intel, param_name: cl_accelerator_info_intel, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetAcceleratorInfoINTEL_fn                              :: ^clGetAcceleratorInfoINTEL_t
clRetainAcceleratorINTEL_t                                :: #type proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int
clRetainAcceleratorINTEL_fn                               :: ^clRetainAcceleratorINTEL_t
clReleaseAcceleratorINTEL_t                               :: #type proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int
clReleaseAcceleratorINTEL_fn                              :: ^clReleaseAcceleratorINTEL_t
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
clHostMemAllocINTEL_t                                     :: #type proc "stdcall" (_context: cl_context, properties: ^cl_mem_properties_intel, size: c.size_t, alignment: cl_uint, errcode_ret: ^cl_int) -> rawptr
clHostMemAllocINTEL_fn                                    :: ^clHostMemAllocINTEL_t
clDeviceMemAllocINTEL_t                                   :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: ^cl_mem_properties_intel, size: c.size_t, alignment: cl_uint, errcode_ret: ^cl_int) -> rawptr
clDeviceMemAllocINTEL_fn                                  :: ^clDeviceMemAllocINTEL_t
clSharedMemAllocINTEL_t                                   :: #type proc "stdcall" (_context: cl_context, device: cl_device_id, properties: ^cl_mem_properties_intel, size: c.size_t, alignment: cl_uint, errcode_ret: ^cl_int) -> rawptr
clSharedMemAllocINTEL_fn                                  :: ^clSharedMemAllocINTEL_t
clMemFreeINTEL_t                                          :: #type proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int
clMemFreeINTEL_fn                                         :: ^clMemFreeINTEL_t
clMemBlockingFreeINTEL_t                                  :: #type proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int
clMemBlockingFreeINTEL_fn                                 :: ^clMemBlockingFreeINTEL_t
clGetMemAllocInfoINTEL_t                                  :: #type proc "stdcall" (_context: cl_context, ptr: rawptr, param_name: cl_mem_info_intel, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetMemAllocInfoINTEL_fn                                 :: ^clGetMemAllocInfoINTEL_t
clSetKernelArgMemPointerINTEL_t                           :: #type proc "stdcall" (kernel: cl_kernel, arg_index: cl_uint, arg_value: rawptr) -> cl_int
clSetKernelArgMemPointerINTEL_fn                          :: ^clSetKernelArgMemPointerINTEL_t
clEnqueueMemFillINTEL_t                                   :: #type proc "stdcall" (command_queue: cl_command_queue, dst_ptr: rawptr, pattern: rawptr, pattern_size: c.size_t, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMemFillINTEL_fn                                  :: ^clEnqueueMemFillINTEL_t
clEnqueueMemcpyINTEL_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, blocking: cl_bool, dst_ptr: rawptr, src_ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMemcpyINTEL_fn                                   :: ^clEnqueueMemcpyINTEL_t
clEnqueueMemAdviseINTEL_t                                 :: #type proc "stdcall" (command_queue: cl_command_queue, ptr: rawptr, size: c.size_t, advice: cl_mem_advice_intel, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMemAdviseINTEL_fn                                :: ^clEnqueueMemAdviseINTEL_t
clEnqueueMigrateMemINTEL_t                                :: #type proc "stdcall" (command_queue: cl_command_queue, ptr: rawptr, size: c.size_t, flags: cl_mem_migration_flags, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMigrateMemINTEL_fn                               :: ^clEnqueueMigrateMemINTEL_t
clEnqueueMemsetINTEL_t                                    :: #type proc "stdcall" (command_queue: cl_command_queue, dst_ptr: rawptr, value: cl_int, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueMemsetINTEL_fn                                   :: ^clEnqueueMemsetINTEL_t
clCreateBufferWithPropertiesINTEL_t                       :: #type proc "stdcall" (_context: cl_context, properties: ^cl_mem_properties_intel, flags: cl_mem_flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^cl_int) -> cl_mem
clCreateBufferWithPropertiesINTEL_fn                      :: ^clCreateBufferWithPropertiesINTEL_t
clEnqueueReadHostPipeINTEL_t                              :: #type proc "stdcall" (command_queue: cl_command_queue, program: cl_program, pipe_symbol: ^c.schar, blocking_read: cl_bool, ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReadHostPipeINTEL_fn                             :: ^clEnqueueReadHostPipeINTEL_t
clEnqueueWriteHostPipeINTEL_t                             :: #type proc "stdcall" (command_queue: cl_command_queue, program: cl_program, pipe_symbol: ^c.schar, blocking_write: cl_bool, ptr: rawptr, size: c.size_t, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueWriteHostPipeINTEL_fn                            :: ^clEnqueueWriteHostPipeINTEL_t
cl_command_queue_capabilities_intel                       :: cl_bitfield
cl_queue_family_properties_intel                          :: struct{
	properties: cl_command_queue_properties,
	capabilities: cl_command_queue_capabilities_intel,
	count: cl_uint,
	name: [64]c.schar,
}
cl_image_requirements_info_ext                            :: cl_uint
clGetImageRequirementsInfoEXT_t                           :: #type proc "stdcall" (_context: cl_context, properties: ^cl_mem_properties, flags: cl_mem_flags, image_format: ^cl_image_format, image_desc: ^cl_image_desc, param_name: cl_image_requirements_info_ext, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetImageRequirementsInfoEXT_fn                          :: ^clGetImageRequirementsInfoEXT_t
cl_icdl_info                                              :: cl_uint
clGetICDLoaderInfoOCLICD_t                                :: #type proc "stdcall" (param_name: cl_icdl_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetICDLoaderInfoOCLICD_fn                               :: ^clGetICDLoaderInfoOCLICD_t
cl_device_fp_atomic_capabilities_ext                      :: cl_bitfield
clSetContentSizeBufferPoCL_t                              :: #type proc "stdcall" (buffer: cl_mem, content_size_buffer: cl_mem) -> cl_int
clSetContentSizeBufferPoCL_fn                             :: ^clSetContentSizeBufferPoCL_t
cl_device_kernel_clock_capabilities_khr                   :: cl_bitfield
clCancelCommandsIMG_t                                     :: #type proc "stdcall" (event_list: ^cl_event, num_events_in_list: c.size_t) -> cl_int
clCancelCommandsIMG_fn                                    :: ^clCancelCommandsIMG_t

foreign opencl {
	clCreateCommandBufferKHR :: proc "stdcall" (
                                            num_queues: cl_uint,
                                            queues: ^cl_command_queue,
                                            properties: ^cl_command_buffer_properties_khr,
                                            errcode_ret: ^cl_int) -> cl_command_buffer_khr ---
	clFinalizeCommandBufferKHR :: proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int ---
	clRetainCommandBufferKHR :: proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int ---
	clReleaseCommandBufferKHR :: proc "stdcall" (command_buffer: cl_command_buffer_khr) -> cl_int ---
	clEnqueueCommandBufferKHR :: proc "stdcall" (
                                             num_queues: cl_uint,
                                             queues: ^cl_command_queue,
                                             command_buffer: cl_command_buffer_khr,
                                             num_events_in_wait_list: cl_uint,
                                             event_wait_list: ^cl_event,
                                             event: ^cl_event) -> cl_int ---
	clCommandBarrierWithWaitListKHR :: proc "stdcall" (
                                                   command_buffer: cl_command_buffer_khr,
                                                   command_queue: cl_command_queue,
                                                   properties: ^cl_command_properties_khr,
                                                   num_sync_points_in_wait_list: cl_uint,
                                                   sync_point_wait_list: ^cl_sync_point_khr,
                                                   sync_point: ^cl_sync_point_khr,
                                                   mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandCopyBufferKHR :: proc "stdcall" (
                                          command_buffer: cl_command_buffer_khr,
                                          command_queue: cl_command_queue,
                                          properties: ^cl_command_properties_khr,
                                          src_buffer: cl_mem,
                                          dst_buffer: cl_mem,
                                          src_offset: c.size_t,
                                          dst_offset: c.size_t,
                                          size: c.size_t,
                                          num_sync_points_in_wait_list: cl_uint,
                                          sync_point_wait_list: ^cl_sync_point_khr,
                                          sync_point: ^cl_sync_point_khr,
                                          mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandCopyBufferRectKHR :: proc "stdcall" (
                                              command_buffer: cl_command_buffer_khr,
                                              command_queue: cl_command_queue,
                                              properties: ^cl_command_properties_khr,
                                              src_buffer: cl_mem,
                                              dst_buffer: cl_mem,
                                              src_origin: ^c.size_t,
                                              dst_origin: ^c.size_t,
                                              region: ^c.size_t,
                                              src_row_pitch: c.size_t,
                                              src_slice_pitch: c.size_t,
                                              dst_row_pitch: c.size_t,
                                              dst_slice_pitch: c.size_t,
                                              num_sync_points_in_wait_list: cl_uint,
                                              sync_point_wait_list: ^cl_sync_point_khr,
                                              sync_point: ^cl_sync_point_khr,
                                              mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandCopyBufferToImageKHR :: proc "stdcall" (
                                                 command_buffer: cl_command_buffer_khr,
                                                 command_queue: cl_command_queue,
                                                 properties: ^cl_command_properties_khr,
                                                 src_buffer: cl_mem,
                                                 dst_image: cl_mem,
                                                 src_offset: c.size_t,
                                                 dst_origin: ^c.size_t,
                                                 region: ^c.size_t,
                                                 num_sync_points_in_wait_list: cl_uint,
                                                 sync_point_wait_list: ^cl_sync_point_khr,
                                                 sync_point: ^cl_sync_point_khr,
                                                 mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandCopyImageKHR :: proc "stdcall" (
                                         command_buffer: cl_command_buffer_khr,
                                         command_queue: cl_command_queue,
                                         properties: ^cl_command_properties_khr,
                                         src_image: cl_mem,
                                         dst_image: cl_mem,
                                         src_origin: ^c.size_t,
                                         dst_origin: ^c.size_t,
                                         region: ^c.size_t,
                                         num_sync_points_in_wait_list: cl_uint,
                                         sync_point_wait_list: ^cl_sync_point_khr,
                                         sync_point: ^cl_sync_point_khr,
                                         mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandCopyImageToBufferKHR :: proc "stdcall" (
                                                 command_buffer: cl_command_buffer_khr,
                                                 command_queue: cl_command_queue,
                                                 properties: ^cl_command_properties_khr,
                                                 src_image: cl_mem,
                                                 dst_buffer: cl_mem,
                                                 src_origin: ^c.size_t,
                                                 region: ^c.size_t,
                                                 dst_offset: c.size_t,
                                                 num_sync_points_in_wait_list: cl_uint,
                                                 sync_point_wait_list: ^cl_sync_point_khr,
                                                 sync_point: ^cl_sync_point_khr,
                                                 mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandFillBufferKHR :: proc "stdcall" (
                                          command_buffer: cl_command_buffer_khr,
                                          command_queue: cl_command_queue,
                                          properties: ^cl_command_properties_khr,
                                          buffer: cl_mem,
                                          pattern: rawptr,
                                          pattern_size: c.size_t,
                                          offset: c.size_t,
                                          size: c.size_t,
                                          num_sync_points_in_wait_list: cl_uint,
                                          sync_point_wait_list: ^cl_sync_point_khr,
                                          sync_point: ^cl_sync_point_khr,
                                          mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandFillImageKHR :: proc "stdcall" (
                                         command_buffer: cl_command_buffer_khr,
                                         command_queue: cl_command_queue,
                                         properties: ^cl_command_properties_khr,
                                         image: cl_mem,
                                         fill_color: rawptr,
                                         origin: ^c.size_t,
                                         region: ^c.size_t,
                                         num_sync_points_in_wait_list: cl_uint,
                                         sync_point_wait_list: ^cl_sync_point_khr,
                                         sync_point: ^cl_sync_point_khr,
                                         mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandNDRangeKernelKHR :: proc "stdcall" (
                                             command_buffer: cl_command_buffer_khr,
                                             command_queue: cl_command_queue,
                                             properties: ^cl_command_properties_khr,
                                             kernel: cl_kernel,
                                             work_dim: cl_uint,
                                             global_work_offset: ^c.size_t,
                                             global_work_size: ^c.size_t,
                                             local_work_size: ^c.size_t,
                                             num_sync_points_in_wait_list: cl_uint,
                                             sync_point_wait_list: ^cl_sync_point_khr,
                                             sync_point: ^cl_sync_point_khr,
                                             mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clGetCommandBufferInfoKHR :: proc "stdcall" (
                                             command_buffer: cl_command_buffer_khr,
                                             param_name: cl_command_buffer_info_khr,
                                             param_value_size: c.size_t,
                                             param_value: rawptr,
                                             param_value_size_ret: ^c.size_t) -> cl_int ---
	clCommandSVMMemcpyKHR :: proc "stdcall" (
                                         command_buffer: cl_command_buffer_khr,
                                         command_queue: cl_command_queue,
                                         properties: ^cl_command_properties_khr,
                                         dst_ptr: rawptr,
                                         src_ptr: rawptr,
                                         size: c.size_t,
                                         num_sync_points_in_wait_list: cl_uint,
                                         sync_point_wait_list: ^cl_sync_point_khr,
                                         sync_point: ^cl_sync_point_khr,
                                         mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clCommandSVMMemFillKHR :: proc "stdcall" (
                                          command_buffer: cl_command_buffer_khr,
                                          command_queue: cl_command_queue,
                                          properties: ^cl_command_properties_khr,
                                          svm_ptr: rawptr,
                                          pattern: rawptr,
                                          pattern_size: c.size_t,
                                          size: c.size_t,
                                          num_sync_points_in_wait_list: cl_uint,
                                          sync_point_wait_list: ^cl_sync_point_khr,
                                          sync_point: ^cl_sync_point_khr,
                                          mutable_handle: ^cl_mutable_command_khr) -> cl_int ---
	clRemapCommandBufferKHR :: proc "stdcall" (
                                           command_buffer: cl_command_buffer_khr,
                                           automatic: cl_bool,
                                           num_queues: cl_uint,
                                           queues: ^cl_command_queue,
                                           num_handles: cl_uint,
                                           handles: ^cl_mutable_command_khr,
                                           handles_ret: ^cl_mutable_command_khr,
                                           errcode_ret: ^cl_int) -> cl_command_buffer_khr ---
	clUpdateMutableCommandsKHR :: proc "stdcall" (
                                              command_buffer: cl_command_buffer_khr,
                                              num_configs: cl_uint,
                                              config_types: ^cl_command_buffer_update_type_khr,
                                              configs: ^rawptr) -> cl_int ---
	clGetMutableCommandInfoKHR :: proc "stdcall" (
                                              command: cl_mutable_command_khr,
                                              param_name: cl_mutable_command_info_khr,
                                              param_value_size: c.size_t,
                                              param_value: rawptr,
                                              param_value_size_ret: ^c.size_t) -> cl_int ---
	clSetMemObjectDestructorAPPLE :: proc "stdcall" (
                                                 memobj: cl_mem,
                                                 pfn_notify: #type proc "stdcall" (memobj: cl_mem, user_data: rawptr),
                                                 user_data: rawptr) -> cl_int ---
	clLogMessagesToSystemLogAPPLE :: proc "stdcall" (
                                                 errstr: ^c.schar,
                                                 private_info: rawptr,
                                                 cb: c.size_t,
                                                 user_data: rawptr) ---
	clLogMessagesToStdoutAPPLE :: proc "stdcall" (
                                              errstr: ^c.schar,
                                              private_info: rawptr,
                                              cb: c.size_t,
                                              user_data: rawptr) ---
	clLogMessagesToStderrAPPLE :: proc "stdcall" (
                                              errstr: ^c.schar,
                                              private_info: rawptr,
                                              cb: c.size_t,
                                              user_data: rawptr) ---
	clIcdGetPlatformIDsKHR :: proc "stdcall" (
                                          num_entries: cl_uint,
                                          platforms: ^cl_platform_id,
                                          num_platforms: ^cl_uint) -> cl_int ---
	clCreateProgramWithILKHR :: proc "stdcall" (
                                            _context: cl_context,
                                            il: rawptr,
                                            length: c.size_t,
                                            errcode_ret: ^cl_int) -> cl_program ---
	clTerminateContextKHR :: proc "stdcall" (_context: cl_context) -> cl_int ---
	clCreateCommandQueueWithPropertiesKHR :: proc "stdcall" (
                                                         _context: cl_context,
                                                         device: cl_device_id,
                                                         properties: ^cl_queue_properties_khr,
                                                         errcode_ret: ^cl_int) -> cl_command_queue ---
	clReleaseDeviceEXT :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clRetainDeviceEXT :: proc "stdcall" (device: cl_device_id) -> cl_int ---
	clCreateSubDevicesEXT :: proc "stdcall" (
                                         in_device: cl_device_id,
                                         properties: ^cl_device_partition_property_ext,
                                         num_entries: cl_uint,
                                         out_devices: ^cl_device_id,
                                         num_devices: ^cl_uint) -> cl_int ---
	clEnqueueMigrateMemObjectEXT :: proc "stdcall" (
                                                command_queue: cl_command_queue,
                                                num_mem_objects: cl_uint,
                                                mem_objects: ^cl_mem,
                                                flags: cl_mem_migration_flags_ext,
                                                num_events_in_wait_list: cl_uint,
                                                event_wait_list: ^cl_event,
                                                event: ^cl_event) -> cl_int ---
	clGetDeviceImageInfoQCOM :: proc "stdcall" (
                                            device: cl_device_id,
                                            image_width: c.size_t,
                                            image_height: c.size_t,
                                            image_format: ^cl_image_format,
                                            param_name: cl_image_pitch_info_qcom,
                                            param_value_size: c.size_t,
                                            param_value: rawptr,
                                            param_value_size_ret: ^c.size_t) -> cl_int ---
	clEnqueueAcquireGrallocObjectsIMG :: proc "stdcall" (
                                                     command_queue: cl_command_queue,
                                                     num_objects: cl_uint,
                                                     mem_objects: ^cl_mem,
                                                     num_events_in_wait_list: cl_uint,
                                                     event_wait_list: ^cl_event,
                                                     event: ^cl_event) -> cl_int ---
	clEnqueueReleaseGrallocObjectsIMG :: proc "stdcall" (
                                                     command_queue: cl_command_queue,
                                                     num_objects: cl_uint,
                                                     mem_objects: ^cl_mem,
                                                     num_events_in_wait_list: cl_uint,
                                                     event_wait_list: ^cl_event,
                                                     event: ^cl_event) -> cl_int ---
	clEnqueueGenerateMipmapIMG :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              src_image: cl_mem,
                                              dst_image: cl_mem,
                                              mipmap_filter_mode: cl_mipmap_filter_mode_img,
                                              array_region: ^c.size_t,
                                              mip_region: ^c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: ^cl_event,
                                              event: ^cl_event) -> cl_int ---
	clGetKernelSubGroupInfoKHR :: proc "stdcall" (
                                              in_kernel: cl_kernel,
                                              in_device: cl_device_id,
                                              param_name: cl_kernel_sub_group_info,
                                              input_value_size: c.size_t,
                                              input_value: rawptr,
                                              param_value_size: c.size_t,
                                              param_value: rawptr,
                                              param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetKernelSuggestedLocalWorkSizeKHR :: proc "stdcall" (
                                                        command_queue: cl_command_queue,
                                                        kernel: cl_kernel,
                                                        work_dim: cl_uint,
                                                        global_work_offset: ^c.size_t,
                                                        global_work_size: ^c.size_t,
                                                        suggested_local_work_size: ^c.size_t) -> cl_int ---
	clEnqueueAcquireExternalMemObjectsKHR :: proc "stdcall" (
                                                         command_queue: cl_command_queue,
                                                         num_mem_objects: cl_uint,
                                                         mem_objects: ^cl_mem,
                                                         num_events_in_wait_list: cl_uint,
                                                         event_wait_list: ^cl_event,
                                                         event: ^cl_event) -> cl_int ---
	clEnqueueReleaseExternalMemObjectsKHR :: proc "stdcall" (
                                                         command_queue: cl_command_queue,
                                                         num_mem_objects: cl_uint,
                                                         mem_objects: ^cl_mem,
                                                         num_events_in_wait_list: cl_uint,
                                                         event_wait_list: ^cl_event,
                                                         event: ^cl_event) -> cl_int ---
	clGetSemaphoreHandleForTypeKHR :: proc "stdcall" (
                                                  sema_object: cl_semaphore_khr,
                                                  device: cl_device_id,
                                                  handle_type: cl_external_semaphore_handle_type_khr,
                                                  handle_size: c.size_t,
                                                  handle_ptr: rawptr,
                                                  handle_size_ret: ^c.size_t) -> cl_int ---
	clReImportSemaphoreSyncFdKHR :: proc "stdcall" (
                                                sema_object: cl_semaphore_khr,
                                                reimport_props: ^cl_semaphore_reimport_properties_khr,
                                                fd: c.int) -> cl_int ---
	clCreateSemaphoreWithPropertiesKHR :: proc "stdcall" (
                                                      _context: cl_context,
                                                      sema_props: ^cl_semaphore_properties_khr,
                                                      errcode_ret: ^cl_int) -> cl_semaphore_khr ---
	clEnqueueWaitSemaphoresKHR :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              num_sema_objects: cl_uint,
                                              sema_objects: ^cl_semaphore_khr,
                                              sema_payload_list: ^cl_semaphore_payload_khr,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: ^cl_event,
                                              event: ^cl_event) -> cl_int ---
	clEnqueueSignalSemaphoresKHR :: proc "stdcall" (
                                                command_queue: cl_command_queue,
                                                num_sema_objects: cl_uint,
                                                sema_objects: ^cl_semaphore_khr,
                                                sema_payload_list: ^cl_semaphore_payload_khr,
                                                num_events_in_wait_list: cl_uint,
                                                event_wait_list: ^cl_event,
                                                event: ^cl_event) -> cl_int ---
	clGetSemaphoreInfoKHR :: proc "stdcall" (
                                         sema_object: cl_semaphore_khr,
                                         param_name: cl_semaphore_info_khr,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: ^c.size_t) -> cl_int ---
	clReleaseSemaphoreKHR :: proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int ---
	clRetainSemaphoreKHR :: proc "stdcall" (sema_object: cl_semaphore_khr) -> cl_int ---
	clImportMemoryARM :: proc "stdcall" (
                                     _context: cl_context,
                                     flags: cl_mem_flags,
                                     properties: ^cl_import_properties_arm,
                                     memory: rawptr,
                                     size: c.size_t,
                                     errcode_ret: ^cl_int) -> cl_mem ---
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
                                       event_wait_list: ^cl_event,
                                       event: ^cl_event) -> cl_int ---
	clEnqueueSVMMemcpyARM :: proc "stdcall" (
                                         command_queue: cl_command_queue,
                                         blocking_copy: cl_bool,
                                         dst_ptr: rawptr,
                                         src_ptr: rawptr,
                                         size: c.size_t,
                                         num_events_in_wait_list: cl_uint,
                                         event_wait_list: ^cl_event,
                                         event: ^cl_event) -> cl_int ---
	clEnqueueSVMMemFillARM :: proc "stdcall" (
                                          command_queue: cl_command_queue,
                                          svm_ptr: rawptr,
                                          pattern: rawptr,
                                          pattern_size: c.size_t,
                                          size: c.size_t,
                                          num_events_in_wait_list: cl_uint,
                                          event_wait_list: ^cl_event,
                                          event: ^cl_event) -> cl_int ---
	clEnqueueSVMMapARM :: proc "stdcall" (
                                      command_queue: cl_command_queue,
                                      blocking_map: cl_bool,
                                      flags: cl_map_flags,
                                      svm_ptr: rawptr,
                                      size: c.size_t,
                                      num_events_in_wait_list: cl_uint,
                                      event_wait_list: ^cl_event,
                                      event: ^cl_event) -> cl_int ---
	clEnqueueSVMUnmapARM :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        svm_ptr: rawptr,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: ^cl_event,
                                        event: ^cl_event) -> cl_int ---
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
                                            errcode_ret: ^cl_int) -> cl_accelerator_intel ---
	clGetAcceleratorInfoINTEL :: proc "stdcall" (
                                             accelerator: cl_accelerator_intel,
                                             param_name: cl_accelerator_info_intel,
                                             param_value_size: c.size_t,
                                             param_value: rawptr,
                                             param_value_size_ret: ^c.size_t) -> cl_int ---
	clRetainAcceleratorINTEL :: proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int ---
	clReleaseAcceleratorINTEL :: proc "stdcall" (accelerator: cl_accelerator_intel) -> cl_int ---
	clHostMemAllocINTEL :: proc "stdcall" (
                                       _context: cl_context,
                                       properties: ^cl_mem_properties_intel,
                                       size: c.size_t,
                                       alignment: cl_uint,
                                       errcode_ret: ^cl_int) -> rawptr ---
	clDeviceMemAllocINTEL :: proc "stdcall" (
                                         _context: cl_context,
                                         device: cl_device_id,
                                         properties: ^cl_mem_properties_intel,
                                         size: c.size_t,
                                         alignment: cl_uint,
                                         errcode_ret: ^cl_int) -> rawptr ---
	clSharedMemAllocINTEL :: proc "stdcall" (
                                         _context: cl_context,
                                         device: cl_device_id,
                                         properties: ^cl_mem_properties_intel,
                                         size: c.size_t,
                                         alignment: cl_uint,
                                         errcode_ret: ^cl_int) -> rawptr ---
	clMemFreeINTEL :: proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int ---
	clMemBlockingFreeINTEL :: proc "stdcall" (_context: cl_context, ptr: rawptr) -> cl_int ---
	clGetMemAllocInfoINTEL :: proc "stdcall" (
                                          _context: cl_context,
                                          ptr: rawptr,
                                          param_name: cl_mem_info_intel,
                                          param_value_size: c.size_t,
                                          param_value: rawptr,
                                          param_value_size_ret: ^c.size_t) -> cl_int ---
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
                                         event_wait_list: ^cl_event,
                                         event: ^cl_event) -> cl_int ---
	clEnqueueMemcpyINTEL :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        blocking: cl_bool,
                                        dst_ptr: rawptr,
                                        src_ptr: rawptr,
                                        size: c.size_t,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: ^cl_event,
                                        event: ^cl_event) -> cl_int ---
	clEnqueueMemAdviseINTEL :: proc "stdcall" (
                                           command_queue: cl_command_queue,
                                           ptr: rawptr,
                                           size: c.size_t,
                                           advice: cl_mem_advice_intel,
                                           num_events_in_wait_list: cl_uint,
                                           event_wait_list: ^cl_event,
                                           event: ^cl_event) -> cl_int ---
	clEnqueueMigrateMemINTEL :: proc "stdcall" (
                                            command_queue: cl_command_queue,
                                            ptr: rawptr,
                                            size: c.size_t,
                                            flags: cl_mem_migration_flags,
                                            num_events_in_wait_list: cl_uint,
                                            event_wait_list: ^cl_event,
                                            event: ^cl_event) -> cl_int ---
	clEnqueueMemsetINTEL :: proc "stdcall" (
                                        command_queue: cl_command_queue,
                                        dst_ptr: rawptr,
                                        value: cl_int,
                                        size: c.size_t,
                                        num_events_in_wait_list: cl_uint,
                                        event_wait_list: ^cl_event,
                                        event: ^cl_event) -> cl_int ---
	clCreateBufferWithPropertiesINTEL :: proc "stdcall" (
                                                     _context: cl_context,
                                                     properties: ^cl_mem_properties_intel,
                                                     flags: cl_mem_flags,
                                                     size: c.size_t,
                                                     host_ptr: rawptr,
                                                     errcode_ret: ^cl_int) -> cl_mem ---
	clEnqueueReadHostPipeINTEL :: proc "stdcall" (
                                              command_queue: cl_command_queue,
                                              program: cl_program,
                                              pipe_symbol: ^c.schar,
                                              blocking_read: cl_bool,
                                              ptr: rawptr,
                                              size: c.size_t,
                                              num_events_in_wait_list: cl_uint,
                                              event_wait_list: ^cl_event,
                                              event: ^cl_event) -> cl_int ---
	clEnqueueWriteHostPipeINTEL :: proc "stdcall" (
                                               command_queue: cl_command_queue,
                                               program: cl_program,
                                               pipe_symbol: ^c.schar,
                                               blocking_write: cl_bool,
                                               ptr: rawptr,
                                               size: c.size_t,
                                               num_events_in_wait_list: cl_uint,
                                               event_wait_list: ^cl_event,
                                               event: ^cl_event) -> cl_int ---
	clGetImageRequirementsInfoEXT :: proc "stdcall" (
                                                 _context: cl_context,
                                                 properties: ^cl_mem_properties,
                                                 flags: cl_mem_flags,
                                                 image_format: ^cl_image_format,
                                                 image_desc: ^cl_image_desc,
                                                 param_name: cl_image_requirements_info_ext,
                                                 param_value_size: c.size_t,
                                                 param_value: rawptr,
                                                 param_value_size_ret: ^c.size_t) -> cl_int ---
	clGetICDLoaderInfoOCLICD :: proc "stdcall" (
                                            param_name: cl_icdl_info,
                                            param_value_size: c.size_t,
                                            param_value: rawptr,
                                            param_value_size_ret: ^c.size_t) -> cl_int ---
	clSetContentSizeBufferPoCL :: proc "stdcall" (buffer: cl_mem, content_size_buffer: cl_mem) -> cl_int ---
	clCancelCommandsIMG :: proc "stdcall" (
                                       event_list: ^cl_event,
                                       num_events_in_list: c.size_t) -> cl_int ---
}
/* =========================================
*               cl_gl.h
* ========================================= */

cl_khr_gl_sharing :: 1
CL_KHR_GL_SHARING_EXTENSION_NAME :: "cl_khr_gl_sharing"
CL_KHR_GL_SHARING_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_INVALID_GL_SHAREGROUP_REFERENCE_KHR :: -1000
CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR :: 0x2006
CL_DEVICES_FOR_GL_CONTEXT_KHR :: 0x2007
CL_GL_CONTEXT_KHR :: 0x2008
CL_EGL_DISPLAY_KHR :: 0x2009
CL_GLX_DISPLAY_KHR :: 0x200A
CL_WGL_HDC_KHR :: 0x200B
CL_CGL_SHAREGROUP_KHR :: 0x200C
CL_GL_OBJECT_BUFFER :: 0x2000
CL_GL_OBJECT_TEXTURE2D :: 0x2001
CL_GL_OBJECT_TEXTURE3D :: 0x2002
CL_GL_OBJECT_RENDERBUFFER :: 0x2003
CL_GL_OBJECT_TEXTURE2D_ARRAY :: 0x200E
CL_GL_OBJECT_TEXTURE1D :: 0x200F
CL_GL_OBJECT_TEXTURE1D_ARRAY :: 0x2010
CL_GL_OBJECT_TEXTURE_BUFFER :: 0x2011
CL_GL_TEXTURE_TARGET :: 0x2004
CL_GL_MIPMAP_LEVEL :: 0x2005
cl_khr_gl_event :: 1
CL_KHR_GL_EVENT_EXTENSION_NAME :: "cl_khr_gl_event"
CL_KHR_GL_EVENT_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_COMMAND_GL_FENCE_SYNC_OBJECT_KHR :: 0x200D
cl_khr_gl_depth_images :: 1
CL_KHR_GL_DEPTH_IMAGES_EXTENSION_NAME :: "cl_khr_gl_depth_images"
CL_KHR_GL_DEPTH_IMAGES_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_DEPTH_STENCIL :: 0x10BE
CL_UNORM_INT24 :: 0x10DF
cl_khr_gl_msaa_sharing :: 1
CL_KHR_GL_MSAA_SHARING_EXTENSION_NAME :: "cl_khr_gl_msaa_sharing"
CL_KHR_GL_MSAA_SHARING_EXTENSION_VERSION := CL_MAKE_VERSION(1, 0, 0)
CL_GL_NUM_SAMPLES :: 0x2012
cl_intel_sharing_format_query_gl :: 1
CL_INTEL_SHARING_FORMAT_QUERY_GL_EXTENSION_NAME :: "cl_intel_sharing_format_query_gl"
CL_INTEL_SHARING_FORMAT_QUERY_GL_EXTENSION_VERSION := CL_MAKE_VERSION(0, 0, 0)

cl_GLint                                                  :: c.int
cl_GLenum                                                 :: c.uint
cl_GLuint                                                 :: c.uint
cl_gl_context_info                                        :: cl_uint
cl_gl_object_type                                         :: cl_uint
cl_gl_texture_info                                        :: cl_uint
cl_gl_platform_info                                       :: cl_uint
clGetGLContextInfoKHR_t                                   :: #type proc "stdcall" (properties: ^cl_context_properties, param_name: cl_gl_context_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetGLContextInfoKHR_fn                                  :: ^clGetGLContextInfoKHR_t
clCreateFromGLBuffer_t                                    :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, bufobj: cl_GLuint, errcode_ret: ^cl_int) -> cl_mem
clCreateFromGLBuffer_fn                                   :: ^clCreateFromGLBuffer_t
clCreateFromGLTexture_t                                   :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, target: cl_GLenum, miplevel: cl_GLint, texture: cl_GLuint, errcode_ret: ^cl_int) -> cl_mem
clCreateFromGLTexture_fn                                  :: ^clCreateFromGLTexture_t
clCreateFromGLRenderbuffer_t                              :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, renderbuffer: cl_GLuint, errcode_ret: ^cl_int) -> cl_mem
clCreateFromGLRenderbuffer_fn                             :: ^clCreateFromGLRenderbuffer_t
clGetGLObjectInfo_t                                       :: #type proc "stdcall" (memobj: cl_mem, gl_object_type: ^cl_gl_object_type, gl_object_name: ^cl_GLuint) -> cl_int
clGetGLObjectInfo_fn                                      :: ^clGetGLObjectInfo_t
clGetGLTextureInfo_t                                      :: #type proc "stdcall" (memobj: cl_mem, param_name: cl_gl_texture_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> cl_int
clGetGLTextureInfo_fn                                     :: ^clGetGLTextureInfo_t
clEnqueueAcquireGLObjects_t                               :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueAcquireGLObjects_fn                              :: ^clEnqueueAcquireGLObjects_t
clEnqueueReleaseGLObjects_t                               :: #type proc "stdcall" (command_queue: cl_command_queue, num_objects: cl_uint, mem_objects: ^cl_mem, num_events_in_wait_list: cl_uint, event_wait_list: ^cl_event, event: ^cl_event) -> cl_int
clEnqueueReleaseGLObjects_fn                              :: ^clEnqueueReleaseGLObjects_t
clCreateFromGLTexture2D_t                                 :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, target: cl_GLenum, miplevel: cl_GLint, texture: cl_GLuint, errcode_ret: ^cl_int) -> cl_mem
clCreateFromGLTexture2D_fn                                :: ^clCreateFromGLTexture2D_t
clCreateFromGLTexture3D_t                                 :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, target: cl_GLenum, miplevel: cl_GLint, texture: cl_GLuint, errcode_ret: ^cl_int) -> cl_mem
clCreateFromGLTexture3D_fn                                :: ^clCreateFromGLTexture3D_t
cl_GLsync                                                 :: distinct rawptr
clCreateEventFromGLsyncKHR_t                              :: #type proc "stdcall" (_context: cl_context, sync: cl_GLsync, errcode_ret: ^cl_int) -> cl_event
clCreateEventFromGLsyncKHR_fn                             :: ^clCreateEventFromGLsyncKHR_t
clGetSupportedGLTextureFormatsINTEL_t                     :: #type proc "stdcall" (_context: cl_context, flags: cl_mem_flags, image_type: cl_mem_object_type, num_entries: cl_uint, gl_formats: ^cl_GLenum, num_texture_formats: ^cl_uint) -> cl_int
clGetSupportedGLTextureFormatsINTEL_fn                    :: ^clGetSupportedGLTextureFormatsINTEL_t

foreign opencl {
	clGetGLContextInfoKHR :: proc "stdcall" (
                                         properties: ^cl_context_properties,
                                         param_name: cl_gl_context_info,
                                         param_value_size: c.size_t,
                                         param_value: rawptr,
                                         param_value_size_ret: ^c.size_t) -> cl_int ---
	clCreateFromGLBuffer :: proc "stdcall" (
                                        _context: cl_context,
                                        flags: cl_mem_flags,
                                        bufobj: cl_GLuint,
                                        errcode_ret: ^cl_int) -> cl_mem ---
	clCreateFromGLTexture :: proc "stdcall" (
                                         _context: cl_context,
                                         flags: cl_mem_flags,
                                         target: cl_GLenum,
                                         miplevel: cl_GLint,
                                         texture: cl_GLuint,
                                         errcode_ret: ^cl_int) -> cl_mem ---
	clCreateFromGLRenderbuffer :: proc "stdcall" (
                                              _context: cl_context,
                                              flags: cl_mem_flags,
                                              renderbuffer: cl_GLuint,
                                              errcode_ret: ^cl_int) -> cl_mem ---
	clGetGLObjectInfo :: proc "stdcall" (
                                     memobj: cl_mem,
                                     gl_object_type: ^cl_gl_object_type,
                                     gl_object_name: ^cl_GLuint) -> cl_int ---
	clGetGLTextureInfo :: proc "stdcall" (
                                      memobj: cl_mem,
                                      param_name: cl_gl_texture_info,
                                      param_value_size: c.size_t,
                                      param_value: rawptr,
                                      param_value_size_ret: ^c.size_t) -> cl_int ---
	clEnqueueAcquireGLObjects :: proc "stdcall" (
                                             command_queue: cl_command_queue,
                                             num_objects: cl_uint,
                                             mem_objects: ^cl_mem,
                                             num_events_in_wait_list: cl_uint,
                                             event_wait_list: ^cl_event,
                                             event: ^cl_event) -> cl_int ---
	clEnqueueReleaseGLObjects :: proc "stdcall" (
                                             command_queue: cl_command_queue,
                                             num_objects: cl_uint,
                                             mem_objects: ^cl_mem,
                                             num_events_in_wait_list: cl_uint,
                                             event_wait_list: ^cl_event,
                                             event: ^cl_event) -> cl_int ---
	clCreateFromGLTexture2D :: proc "stdcall" (
                                           _context: cl_context,
                                           flags: cl_mem_flags,
                                           target: cl_GLenum,
                                           miplevel: cl_GLint,
                                           texture: cl_GLuint,
                                           errcode_ret: ^cl_int) -> cl_mem ---
	clCreateFromGLTexture3D :: proc "stdcall" (
                                           _context: cl_context,
                                           flags: cl_mem_flags,
                                           target: cl_GLenum,
                                           miplevel: cl_GLint,
                                           texture: cl_GLuint,
                                           errcode_ret: ^cl_int) -> cl_mem ---
	clCreateEventFromGLsyncKHR :: proc "stdcall" (
                                              _context: cl_context,
                                              sync: cl_GLsync,
                                              errcode_ret: ^cl_int) -> cl_event ---
	clGetSupportedGLTextureFormatsINTEL :: proc "stdcall" (
                                                       _context: cl_context,
                                                       flags: cl_mem_flags,
                                                       image_type: cl_mem_object_type,
                                                       num_entries: cl_uint,
                                                       gl_formats: ^cl_GLenum,
                                                       num_texture_formats: ^cl_uint) -> cl_int ---
}
