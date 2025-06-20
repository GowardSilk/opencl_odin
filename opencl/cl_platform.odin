package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               cl_platform.h
* ========================================= */

CHAR_BIT :: 8
SCHAR_MAX :: 127
SCHAR_MIN :: (-127 - 1)
CHAR_MAX :: SCHAR_MAX
CHAR_MIN :: SCHAR_MIN
UCHAR_MAX :: 255
SHRT_MAX :: 32767
SHRT_MIN :: (-32767 - 1)
USHRT_MAX :: 65535
INT_MAX :: 2147483647
INT_MIN :: (-2147483647 - 1)
UINT_MAX :: 0xffffffff
LONG_MAX :: (cast(Long)0x7FFFFFFFFFFFFFFF)
LONG_MIN :: (cast(Long)- 0x7FFFFFFFFFFFFFFF - 1)
ULONG_MAX :: (cast(Ulong)0xFFFFFFFFFFFFFFFF)
FLT_DIG :: 6
FLT_MANT_DIG :: 24
FLT_MAX_10_EXP :: +38
FLT_MAX_EXP :: +128
FLT_MIN_10_EXP :: -37
FLT_MIN_EXP :: -125
FLT_RADIX :: 2
FLT_MAX :: 340282346638528859811704183484516925440.0
FLT_MIN :: 1.175494350822287507969e-38
FLT_EPSILON :: 1.1920928955078125e-7
HALF_DIG :: 3
HALF_MANT_DIG :: 11
HALF_MAX_10_EXP :: +4
HALF_MAX_EXP :: +16
HALF_MIN_10_EXP :: -4
HALF_MIN_EXP :: -13
HALF_RADIX :: 2
HALF_MAX :: 65504.0
HALF_MIN :: 6.103515625e-05
HALF_EPSILON :: 9.765625e-04
DBL_DIG :: 15
DBL_MANT_DIG :: 53
DBL_MAX_10_EXP :: +308
DBL_MAX_EXP :: +1024
DBL_MIN_10_EXP :: -307
DBL_MIN_EXP :: -1021
DBL_RADIX :: 2
DBL_MAX :: 1.7976931348623158e+308
DBL_MIN :: 2.225073858507201383090e-308
DBL_EPSILON :: 2.220446049250313080847e-16
M_E :: 2.7182818284590452354
M_LOG2E :: 1.4426950408889634074
M_LOG10E :: 0.43429448190325182765
M_LN2 :: 0.69314718055994530942
M_LN10 :: 2.30258509299404568402
M_PI :: 3.14159265358979323846
M_PI_2 :: 1.57079632679489661923
M_PI_4 :: 0.78539816339744830962
M_1_PI :: 0.31830988618379067154
M_2_PI :: 0.63661977236758134308
M_2_SQRTPI :: 1.12837916709551257390
M_SQRT2 :: 1.41421356237309504880
M_SQRT1_2 :: 0.70710678118654752440
M_E_F :: 2.718281828
M_LOG2E_F :: 1.442695041
M_LOG10E_F :: 0.434294482
M_LN2_F :: 0.693147181
M_LN10_F :: 2.302585093
M_PI_F :: 3.141592654
M_PI_2_F :: 1.570796327
M_PI_4_F :: 0.785398163
M_1_PI_F :: 0.318309886
M_2_PI_F :: 0.636619772
M_2_SQRTPI_F :: 1.128379167
M_SQRT2_F :: 1.414213562
M_SQRT1_2_F :: 0.707106781
NAN :: (INFINITY - INFINITY)
HUGE_VALF :: (cast(Float)1e50)
HUGE_VAL :: (cast(Double)1e500)
MAXFLOAT :: FLT_MAX
INFINITY :: HUGE_VALF
HAS_NAMED_VECTOR_FIELDS :: 1
HAS_HI_LO_VECTOR_FIELDS :: 1

Char :: c.int8_t
Uchar :: c.uint8_t
Short :: c.int16_t
Ushort :: c.uint16_t
Int :: c.int32_t
Uint :: c.uint32_t
Long :: c.int64_t
Ulong :: c.uint64_t
Half :: c.uint16_t
Float :: c.float
Double :: c.double
__cl_float4 :: #simd[4]c.float
__cl_uchar16 :: #simd[4]c.int32_t
__cl_char16 :: #simd[4]c.int32_t
__cl_ushort8 :: #simd[4]c.int32_t
__cl_short8 :: #simd[4]c.int32_t
__cl_uint4 :: #simd[4]c.int32_t
__cl_int4 :: #simd[4]c.int32_t
__cl_ulong2 :: #simd[4]c.int32_t
__cl_long2 :: #simd[4]c.int32_t
__cl_double2 :: #simd[2]c.double
__cl_uchar8 :: #simd[2]c.int32_t
__cl_char8 :: #simd[2]c.int32_t
__cl_ushort4 :: #simd[2]c.int32_t
__cl_short4 :: #simd[2]c.int32_t
__cl_uint2 :: #simd[2]c.int32_t
__cl_int2 :: #simd[2]c.int32_t
__cl_ulong1 :: #simd[2]c.int32_t
__cl_long1 :: #simd[2]c.int32_t
__cl_float2 :: #simd[2]c.int32_t
Char_2 :: struct #raw_union {
	using _: struct{
		x,y: Char,
	},
	using _: struct{
		s0,s1: Char,
	},
	using _: struct{
		lo,hi: Char,
	},
	s: [2]Char,
}
Char_4 :: struct #raw_union {
	s: [4]Char,
	using _: struct{
		x,y,z,w: Char,
	},
	using _: struct{
		s0,s1,s2,s3: Char,
	},
	using _: struct{
		lo,hi: Char_2,
	},
}
Char_3 :: Char_4
Char_8 :: struct #raw_union {
	s: [8]Char,
	using _: struct{
		x,y,z,w: Char,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Char,
	},
	using _: struct{
		lo,hi: Char_4,
	},
	v8: __cl_char8,
}
Char_1_6 :: struct #raw_union {
	s: [16]Char,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Char,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Char,
	},
	using _: struct{
		lo,hi: Char_8,
	},
	v8: [2]__cl_char8,
	v16: __cl_char16,
}
Uchar_2 :: struct #raw_union {
	s: [2]Uchar,
	using _: struct{
		x,y: Uchar,
	},
	using _: struct{
		s0,s1: Uchar,
	},
	using _: struct{
		lo,hi: Uchar,
	},
}
Uchar_4 :: struct #raw_union {
	s: [4]Uchar,
	using _: struct{
		x,y,z,w: Uchar,
	},
	using _: struct{
		s0,s1,s2,s3: Uchar,
	},
	using _: struct{
		lo,hi: Uchar_2,
	},
}
Uchar_3 :: Uchar_4
Uchar_8 :: struct #raw_union {
	s: [8]Uchar,
	using _: struct{
		x,y,z,w: Uchar,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Uchar,
	},
	using _: struct{
		lo,hi: Uchar_4,
	},
	v8: __cl_uchar8,
}
Uchar_1_6 :: struct #raw_union {
	s: [16]Uchar,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Uchar,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Uchar,
	},
	using _: struct{
		lo,hi: Uchar_8,
	},
	v8: [2]__cl_uchar8,
	v16: __cl_uchar16,
}
Short_2 :: struct #raw_union {
	s: [2]Short,
	using _: struct{
		x,y: Short,
	},
	using _: struct{
		s0,s1: Short,
	},
	using _: struct{
		lo,hi: Short,
	},
}
Short_4 :: struct #raw_union {
	s: [4]Short,
	using _: struct{
		x,y,z,w: Short,
	},
	using _: struct{
		s0,s1,s2,s3: Short,
	},
	using _: struct{
		lo,hi: Short_2,
	},
	v4: __cl_short4,
}
Short_3 :: Short_4
Short_8 :: struct #raw_union {
	s: [8]Short,
	using _: struct{
		x,y,z,w: Short,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Short,
	},
	using _: struct{
		lo,hi: Short_4,
	},
	v4: [2]__cl_short4,
	v8: __cl_short8,
}
Short_1_6 :: struct #raw_union {
	s: [16]Short,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Short,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Short,
	},
	using _: struct{
		lo,hi: Short_8,
	},
	v4: [4]__cl_short4,
	v8: [2]__cl_short8,
}
Ushort_2 :: struct #raw_union {
	s: [2]Ushort,
	using _: struct{
		x,y: Ushort,
	},
	using _: struct{
		s0,s1: Ushort,
	},
	using _: struct{
		lo,hi: Ushort,
	},
}
Ushort_4 :: struct #raw_union {
	s: [4]Ushort,
	using _: struct{
		x,y,z,w: Ushort,
	},
	using _: struct{
		s0,s1,s2,s3: Ushort,
	},
	using _: struct{
		lo,hi: Ushort_2,
	},
	v4: __cl_ushort4,
}
Ushort_3 :: Ushort_4
Ushort_8 :: struct #raw_union {
	s: [8]Ushort,
	using _: struct{
		x,y,z,w: Ushort,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Ushort,
	},
	using _: struct{
		lo,hi: Ushort_4,
	},
	v4: [2]__cl_ushort4,
	v8: __cl_ushort8,
}
Ushort_1_6 :: struct #raw_union {
	s: [16]Ushort,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Ushort,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Ushort,
	},
	using _: struct{
		lo,hi: Ushort_8,
	},
	v4: [4]__cl_ushort4,
	v8: [2]__cl_ushort8,
}
Half_2 :: struct #raw_union {
	s: [2]Half,
	using _: struct{
		x,y: Half,
	},
	using _: struct{
		s0,s1: Half,
	},
	using _: struct{
		lo,hi: Half,
	},
}
Half_4 :: struct #raw_union {
	s: [4]Half,
	using _: struct{
		x,y,z,w: Half,
	},
	using _: struct{
		s0,s1,s2,s3: Half,
	},
	using _: struct{
		lo,hi: Half_2,
	},
}
Half_3 :: Half_4
Half_8 :: struct #raw_union {
	s: [8]Half,
	using _: struct{
		x,y,z,w: Half,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Half,
	},
	using _: struct{
		lo,hi: Half_4,
	},
}
Half_1_6 :: struct #raw_union {
	s: [16]Half,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Half,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Half,
	},
	using _: struct{
		lo,hi: Half_8,
	},
}
Int_2 :: struct #raw_union {
	s: [2]Int,
	using _: struct{
		x,y: Int,
	},
	using _: struct{
		s0,s1: Int,
	},
	using _: struct{
		lo,hi: Int,
	},
	v2: __cl_int2,
}
Int_4 :: struct #raw_union {
	s: [4]Int,
	using _: struct{
		x,y,z,w: Int,
	},
	using _: struct{
		s0,s1,s2,s3: Int,
	},
	using _: struct{
		lo,hi: Int_2,
	},
	v2: [2]__cl_int2,
	v4: __cl_int4,
}
Int_3 :: Int_4
Int_8 :: struct #raw_union {
	s: [8]Int,
	using _: struct{
		x,y,z,w: Int,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Int,
	},
	using _: struct{
		lo,hi: Int_4,
	},
	v2: [4]__cl_int2,
	v4: [2]__cl_int4,
}
Int_1_6 :: struct #raw_union {
	s: [16]Int,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Int,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Int,
	},
	using _: struct{
		lo,hi: Int_8,
	},
	v2: [8]__cl_int2,
	v4: [4]__cl_int4,
}
Uint_2 :: struct #raw_union {
	s: [2]Uint,
	using _: struct{
		x,y: Uint,
	},
	using _: struct{
		s0,s1: Uint,
	},
	using _: struct{
		lo,hi: Uint,
	},
	v2: __cl_uint2,
}
Uint_4 :: struct #raw_union {
	s: [4]Uint,
	using _: struct{
		x,y,z,w: Uint,
	},
	using _: struct{
		s0,s1,s2,s3: Uint,
	},
	using _: struct{
		lo,hi: Uint_2,
	},
	v2: [2]__cl_uint2,
	v4: __cl_uint4,
}
Uint_3 :: Uint_4
Uint_8 :: struct #raw_union {
	s: [8]Uint,
	using _: struct{
		x,y,z,w: Uint,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Uint,
	},
	using _: struct{
		lo,hi: Uint_4,
	},
	v2: [4]__cl_uint2,
	v4: [2]__cl_uint4,
}
Uint_1_6 :: struct #raw_union {
	s: [16]Uint,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Uint,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Uint,
	},
	using _: struct{
		lo,hi: Uint_8,
	},
	v2: [8]__cl_uint2,
	v4: [4]__cl_uint4,
}
Long_2 :: struct #raw_union {
	s: [2]Long,
	using _: struct{
		x,y: Long,
	},
	using _: struct{
		s0,s1: Long,
	},
	using _: struct{
		lo,hi: Long,
	},
	v2: __cl_long2,
}
Long_4 :: struct #raw_union {
	s: [4]Long,
	using _: struct{
		x,y,z,w: Long,
	},
	using _: struct{
		s0,s1,s2,s3: Long,
	},
	using _: struct{
		lo,hi: Long_2,
	},
	v2: [2]__cl_long2,
}
Long_3 :: Long_4
Long_8 :: struct #raw_union {
	s: [8]Long,
	using _: struct{
		x,y,z,w: Long,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Long,
	},
	using _: struct{
		lo,hi: Long_4,
	},
	v2: [4]__cl_long2,
}
Long_1_6 :: struct #raw_union {
	s: [16]Long,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Long,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Long,
	},
	using _: struct{
		lo,hi: Long_8,
	},
	v2: [8]__cl_long2,
}
Ulong_2 :: struct #raw_union {
	s: [2]Ulong,
	using _: struct{
		x,y: Ulong,
	},
	using _: struct{
		s0,s1: Ulong,
	},
	using _: struct{
		lo,hi: Ulong,
	},
	v2: __cl_ulong2,
}
Ulong_4 :: struct #raw_union {
	s: [4]Ulong,
	using _: struct{
		x,y,z,w: Ulong,
	},
	using _: struct{
		s0,s1,s2,s3: Ulong,
	},
	using _: struct{
		lo,hi: Ulong_2,
	},
	v2: [2]__cl_ulong2,
}
Ulong_3 :: Ulong_4
Ulong_8 :: struct #raw_union {
	s: [8]Ulong,
	using _: struct{
		x,y,z,w: Ulong,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Ulong,
	},
	using _: struct{
		lo,hi: Ulong_4,
	},
	v2: [4]__cl_ulong2,
}
Ulong_1_6 :: struct #raw_union {
	s: [16]Ulong,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Ulong,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Ulong,
	},
	using _: struct{
		lo,hi: Ulong_8,
	},
	v2: [8]__cl_ulong2,
}
Float_2 :: struct #raw_union {
	s: [2]Float,
	using _: struct{
		x,y: Float,
	},
	using _: struct{
		s0,s1: Float,
	},
	using _: struct{
		lo,hi: Float,
	},
	v2: __cl_float2,
}
Float_4 :: struct #raw_union {
	s: [4]Float,
	using _: struct{
		x,y,z,w: Float,
	},
	using _: struct{
		s0,s1,s2,s3: Float,
	},
	using _: struct{
		lo,hi: Float_2,
	},
	v2: [2]__cl_float2,
	v4: __cl_float4,
}
Float_3 :: Float_4
Float_8 :: struct #raw_union {
	s: [8]Float,
	using _: struct{
		x,y,z,w: Float,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Float,
	},
	using _: struct{
		lo,hi: Float_4,
	},
	v2: [4]__cl_float2,
	v4: [2]__cl_float4,
}
Float_1_6 :: struct #raw_union {
	s: [16]Float,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Float,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Float,
	},
	using _: struct{
		lo,hi: Float_8,
	},
	v2: [8]__cl_float2,
	v4: [4]__cl_float4,
}
Double_2 :: struct #raw_union {
	s: [2]Double,
	using _: struct{
		x,y: Double,
	},
	using _: struct{
		s0,s1: Double,
	},
	using _: struct{
		lo,hi: Double,
	},
	v2: __cl_double2,
}
Double_4 :: struct #raw_union {
	s: [4]Double,
	using _: struct{
		x,y,z,w: Double,
	},
	using _: struct{
		s0,s1,s2,s3: Double,
	},
	using _: struct{
		lo,hi: Double_2,
	},
	v2: [2]__cl_double2,
}
Double_3 :: Double_4
Double_8 :: struct #raw_union {
	s: [8]Double,
	using _: struct{
		x,y,z,w: Double,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7: Double,
	},
	using _: struct{
		lo,hi: Double_4,
	},
	v2: [4]__cl_double2,
}
Double_1_6 :: struct #raw_union {
	s: [16]Double,
	using _: struct{
		x,y,z,w,__spacer4,__spacer5,__spacer6,__spacer7,__spacer8,__spacer9,sa,sb,sc,sd,se,sf: Double,
	},
	using _: struct{
		s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,sA,sB,sC,sD,sE,sF: Double,
	},
	using _: struct{
		lo,hi: Double_8,
	},
	v2: [8]__cl_double2,
}

