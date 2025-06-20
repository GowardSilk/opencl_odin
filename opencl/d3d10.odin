package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               d3d10.h
* ========================================= */

D3D10_16BIT_INDEX_STRIP_CUT_VALUE :: 0xffff
D3D10_32BIT_INDEX_STRIP_CUT_VALUE :: 0xffffffff
D3D10_8BIT_INDEX_STRIP_CUT_VALUE :: 0xff
D3D10_ARRAY_AXIS_ADDRESS_RANGE_BIT_COUNT :: 9
D3D10_CLIP_OR_CULL_DISTANCE_COUNT :: 8
D3D10_CLIP_OR_CULL_DISTANCE_ELEMENT_COUNT :: 2
D3D10_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT :: 14
D3D10_COMMONSHADER_CONSTANT_BUFFER_COMPONENTS :: 4
D3D10_COMMONSHADER_CONSTANT_BUFFER_COMPONENT_BIT_COUNT :: 32
D3D10_COMMONSHADER_CONSTANT_BUFFER_HW_SLOT_COUNT :: 15
D3D10_COMMONSHADER_CONSTANT_BUFFER_REGISTER_COMPONENTS :: 4
D3D10_COMMONSHADER_CONSTANT_BUFFER_REGISTER_COUNT :: 15
D3D10_COMMONSHADER_CONSTANT_BUFFER_REGISTER_READS_PER_INST :: 1
D3D10_COMMONSHADER_CONSTANT_BUFFER_REGISTER_READ_PORTS :: 1
D3D10_COMMONSHADER_FLOWCONTROL_NESTING_LIMIT :: 64
D3D10_COMMONSHADER_IMMEDIATE_CONSTANT_BUFFER_REGISTER_COMPONENTS :: 4
D3D10_COMMONSHADER_IMMEDIATE_CONSTANT_BUFFER_REGISTER_COUNT :: 1
D3D10_COMMONSHADER_IMMEDIATE_CONSTANT_BUFFER_REGISTER_READS_PER_INST :: 1
D3D10_COMMONSHADER_IMMEDIATE_CONSTANT_BUFFER_REGISTER_READ_PORTS :: 1
D3D10_COMMONSHADER_IMMEDIATE_VALUE_COMPONENT_BIT_COUNT :: 32
D3D10_COMMONSHADER_INPUT_RESOURCE_REGISTER_COMPONENTS :: 1
D3D10_COMMONSHADER_INPUT_RESOURCE_REGISTER_COUNT :: 128
D3D10_COMMONSHADER_INPUT_RESOURCE_REGISTER_READS_PER_INST :: 1
D3D10_COMMONSHADER_INPUT_RESOURCE_REGISTER_READ_PORTS :: 1
D3D10_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT :: 128
D3D10_COMMONSHADER_SAMPLER_REGISTER_COMPONENTS :: 1
D3D10_COMMONSHADER_SAMPLER_REGISTER_COUNT :: 16
D3D10_COMMONSHADER_SAMPLER_REGISTER_READS_PER_INST :: 1
D3D10_COMMONSHADER_SAMPLER_REGISTER_READ_PORTS :: 1
D3D10_COMMONSHADER_SAMPLER_SLOT_COUNT :: 16
D3D10_COMMONSHADER_SUBROUTINE_NESTING_LIMIT :: 32
D3D10_COMMONSHADER_TEMP_REGISTER_COMPONENTS :: 4
D3D10_COMMONSHADER_TEMP_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_COMMONSHADER_TEMP_REGISTER_COUNT :: 4096
D3D10_COMMONSHADER_TEMP_REGISTER_READS_PER_INST :: 3
D3D10_COMMONSHADER_TEMP_REGISTER_READ_PORTS :: 3
D3D10_COMMONSHADER_TEXCOORD_RANGE_REDUCTION_MAX :: 10
D3D10_COMMONSHADER_TEXCOORD_RANGE_REDUCTION_MIN :: -10
D3D10_COMMONSHADER_TEXEL_OFFSET_MAX_NEGATIVE :: -8
D3D10_COMMONSHADER_TEXEL_OFFSET_MAX_POSITIVE :: 7
D3D10_DEFAULT_BLEND_FACTOR_ALPHA :: 1.0
D3D10_DEFAULT_BLEND_FACTOR_BLUE :: 1.0
D3D10_DEFAULT_BLEND_FACTOR_GREEN :: 1.0
D3D10_DEFAULT_BLEND_FACTOR_RED :: 1.0
D3D10_DEFAULT_BORDER_COLOR_COMPONENT :: 0.0
D3D10_DEFAULT_DEPTH_BIAS :: 0
D3D10_DEFAULT_DEPTH_BIAS_CLAMP :: 0.0
D3D10_DEFAULT_MAX_ANISOTROPY :: 16.0
D3D10_DEFAULT_MIP_LOD_BIAS :: 0.0
D3D10_DEFAULT_RENDER_TARGET_ARRAY_INDEX :: 0
D3D10_DEFAULT_SAMPLE_MASK :: 0xffffffff
D3D10_DEFAULT_SCISSOR_ENDX :: 0
D3D10_DEFAULT_SCISSOR_ENDY :: 0
D3D10_DEFAULT_SCISSOR_STARTX :: 0
D3D10_DEFAULT_SCISSOR_STARTY :: 0
D3D10_DEFAULT_SLOPE_SCALED_DEPTH_BIAS :: 0.0
D3D10_DEFAULT_STENCIL_READ_MASK :: 0xff
D3D10_DEFAULT_STENCIL_REFERENCE :: 0
D3D10_DEFAULT_STENCIL_WRITE_MASK :: 0xff
D3D10_DEFAULT_VIEWPORT_AND_SCISSORRECT_INDEX :: 0
D3D10_DEFAULT_VIEWPORT_HEIGHT :: 0
D3D10_DEFAULT_VIEWPORT_MAX_DEPTH :: 0.0
D3D10_DEFAULT_VIEWPORT_MIN_DEPTH :: 0.0
D3D10_DEFAULT_VIEWPORT_TOPLEFTX :: 0
D3D10_DEFAULT_VIEWPORT_TOPLEFTY :: 0
D3D10_DEFAULT_VIEWPORT_WIDTH :: 0
D3D10_FLOAT16_FUSED_TOLERANCE_IN_ULP :: 0.6
D3D10_FLOAT32_MAX :: 3.402823466e+38
D3D10_FLOAT32_TO_INTEGER_TOLERANCE_IN_ULP :: 0.6
D3D10_FLOAT_TO_SRGB_EXPONENT_DENOMINATOR :: 2.4
D3D10_FLOAT_TO_SRGB_EXPONENT_NUMERATOR :: 1.0
D3D10_FLOAT_TO_SRGB_OFFSET :: 0.055
D3D10_FLOAT_TO_SRGB_SCALE_1 :: 12.92
D3D10_FLOAT_TO_SRGB_SCALE_2 :: 1.055
D3D10_FLOAT_TO_SRGB_THRESHOLD :: 0.0031308
D3D10_FTOI_INSTRUCTION_MAX_INPUT :: 2147483647.999
D3D10_FTOI_INSTRUCTION_MIN_INPUT :: -2147483648.999
D3D10_FTOU_INSTRUCTION_MAX_INPUT :: 4294967295.999
D3D10_FTOU_INSTRUCTION_MIN_INPUT :: 0.0
D3D10_GS_INPUT_PRIM_CONST_REGISTER_COMPONENTS :: 1
D3D10_GS_INPUT_PRIM_CONST_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_GS_INPUT_PRIM_CONST_REGISTER_COUNT :: 1
D3D10_GS_INPUT_PRIM_CONST_REGISTER_READS_PER_INST :: 2
D3D10_GS_INPUT_PRIM_CONST_REGISTER_READ_PORTS :: 1
D3D10_GS_INPUT_REGISTER_COMPONENTS :: 4
D3D10_GS_INPUT_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_GS_INPUT_REGISTER_COUNT :: 16
D3D10_GS_INPUT_REGISTER_READS_PER_INST :: 2
D3D10_GS_INPUT_REGISTER_READ_PORTS :: 1
D3D10_GS_INPUT_REGISTER_VERTICES :: 6
D3D10_GS_OUTPUT_ELEMENTS :: 32
D3D10_GS_OUTPUT_REGISTER_COMPONENTS :: 4
D3D10_GS_OUTPUT_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_GS_OUTPUT_REGISTER_COUNT :: 32
D3D10_IA_DEFAULT_INDEX_BUFFER_OFFSET_IN_BYTES :: 0
D3D10_IA_DEFAULT_PRIMITIVE_TOPOLOGY :: 0
D3D10_IA_DEFAULT_VERTEX_BUFFER_OFFSET_IN_BYTES :: 0
D3D10_IA_INDEX_INPUT_RESOURCE_SLOT_COUNT :: 1
D3D10_IA_INSTANCE_ID_BIT_COUNT :: 32
D3D10_IA_INTEGER_ARITHMETIC_BIT_COUNT :: 32
D3D10_IA_PRIMITIVE_ID_BIT_COUNT :: 32
D3D10_IA_VERTEX_ID_BIT_COUNT :: 32
D3D10_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT :: 16
D3D10_IA_VERTEX_INPUT_STRUCTURE_ELEMENTS_COMPONENTS :: 64
D3D10_IA_VERTEX_INPUT_STRUCTURE_ELEMENT_COUNT :: 16
D3D10_INTEGER_DIVIDE_BY_ZERO_QUOTIENT :: 0xffffffff
D3D10_INTEGER_DIVIDE_BY_ZERO_REMAINDER :: 0xffffffff
D3D10_LINEAR_GAMMA :: 1.0
D3D10_MAX_BORDER_COLOR_COMPONENT :: 1.0
D3D10_MAX_DEPTH :: 1.0
D3D10_MAX_MAXANISOTROPY :: 16
D3D10_MAX_MULTISAMPLE_SAMPLE_COUNT :: 32
D3D10_MAX_POSITION_VALUE :: 3.402823466e+34
D3D10_MAX_TEXTURE_DIMENSION_2_TO_EXP :: 17
D3D10_MIN_BORDER_COLOR_COMPONENT :: 0.0
D3D10_MIN_DEPTH :: 0.0
D3D10_MIN_MAXANISOTROPY :: 0
D3D10_MIP_LOD_BIAS_MAX :: 15.99
D3D10_MIP_LOD_BIAS_MIN :: -16.0
D3D10_MIP_LOD_FRACTIONAL_BIT_COUNT :: 6
D3D10_MIP_LOD_RANGE_BIT_COUNT :: 8
D3D10_MULTISAMPLE_ANTIALIAS_LINE_WIDTH :: 1.4
D3D10_NONSAMPLE_FETCH_OUT_OF_RANGE_ACCESS_RESULT :: 0
D3D10_PIXEL_ADDRESS_RANGE_BIT_COUNT :: 13
D3D10_PRE_SCISSOR_PIXEL_ADDRESS_RANGE_BIT_COUNT :: 15
D3D10_PS_FRONTFACING_DEFAULT_VALUE :: 0xffffffff
D3D10_PS_FRONTFACING_FALSE_VALUE :: 0
D3D10_PS_FRONTFACING_TRUE_VALUE :: 0xffffffff
D3D10_PS_INPUT_REGISTER_COMPONENTS :: 4
D3D10_PS_INPUT_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_PS_INPUT_REGISTER_COUNT :: 32
D3D10_PS_INPUT_REGISTER_READS_PER_INST :: 2
D3D10_PS_INPUT_REGISTER_READ_PORTS :: 1
D3D10_PS_LEGACY_PIXEL_CENTER_FRACTIONAL_COMPONENT :: 0.0
D3D10_PS_OUTPUT_DEPTH_REGISTER_COMPONENTS :: 1
D3D10_PS_OUTPUT_DEPTH_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_PS_OUTPUT_DEPTH_REGISTER_COUNT :: 1
D3D10_PS_OUTPUT_REGISTER_COMPONENTS :: 4
D3D10_PS_OUTPUT_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_PS_OUTPUT_REGISTER_COUNT :: 8
D3D10_PS_PIXEL_CENTER_FRACTIONAL_COMPONENT :: 0.5
D3D10_REQ_BLEND_OBJECT_COUNT_PER_CONTEXT :: 4096
D3D10_REQ_BUFFER_RESOURCE_TEXEL_COUNT_2_TO_EXP :: 27
D3D10_REQ_CONSTANT_BUFFER_ELEMENT_COUNT :: 4096
D3D10_REQ_DEPTH_STENCIL_OBJECT_COUNT_PER_CONTEXT :: 4096
D3D10_REQ_DRAWINDEXED_INDEX_COUNT_2_TO_EXP :: 32
D3D10_REQ_DRAW_VERTEX_COUNT_2_TO_EXP :: 32
D3D10_REQ_FILTERING_HW_ADDRESSABLE_RESOURCE_DIMENSION :: 8192
D3D10_REQ_GS_INVOCATION_32BIT_OUTPUT_COMPONENT_LIMIT :: 1024
D3D10_REQ_IMMEDIATE_CONSTANT_BUFFER_ELEMENT_COUNT :: 4096
D3D10_REQ_MAXANISOTROPY :: 16
D3D10_REQ_MIP_LEVELS :: 14
D3D10_REQ_MULTI_ELEMENT_STRUCTURE_SIZE_IN_BYTES :: 2048
D3D10_REQ_RASTERIZER_OBJECT_COUNT_PER_CONTEXT :: 4096
D3D10_REQ_RENDER_TO_BUFFER_WINDOW_WIDTH :: 8192
D3D10_REQ_RESOURCE_SIZE_IN_MEGABYTES :: 128
D3D10_REQ_RESOURCE_VIEW_COUNT_PER_CONTEXT_2_TO_EXP :: 20
D3D10_REQ_SAMPLER_OBJECT_COUNT_PER_CONTEXT :: 4096
D3D10_REQ_TEXTURE1D_ARRAY_AXIS_DIMENSION :: 512
D3D10_REQ_TEXTURE1D_U_DIMENSION :: 8192
D3D10_REQ_TEXTURE2D_ARRAY_AXIS_DIMENSION :: 512
D3D10_REQ_TEXTURE2D_U_OR_V_DIMENSION :: 8192
D3D10_REQ_TEXTURE3D_U_V_OR_W_DIMENSION :: 2048
D3D10_REQ_TEXTURECUBE_DIMENSION :: 8192
D3D10_RESINFO_INSTRUCTION_MISSING_COMPONENT_RETVAL :: 0
D3D10_SHADER_MAJOR_VERSION :: 4
D3D10_SHADER_MINOR_VERSION :: 0
D3D10_SHIFT_INSTRUCTION_PAD_VALUE :: 0
D3D10_SHIFT_INSTRUCTION_SHIFT_VALUE_BIT_COUNT :: 5
D3D10_SIMULTANEOUS_RENDER_TARGET_COUNT :: 8
D3D10_SO_BUFFER_MAX_STRIDE_IN_BYTES :: 2048
D3D10_SO_BUFFER_MAX_WRITE_WINDOW_IN_BYTES :: 256
D3D10_SO_BUFFER_SLOT_COUNT :: 4
D3D10_SO_DDI_REGISTER_INDEX_DENOTING_GAP :: 0xffffffff
D3D10_SO_MULTIPLE_BUFFER_ELEMENTS_PER_BUFFER :: 1
D3D10_SO_SINGLE_BUFFER_COMPONENT_LIMIT :: 64
D3D10_SRGB_GAMMA :: 2.2
D3D10_SRGB_TO_FLOAT_DENOMINATOR_1 :: 12.92
D3D10_SRGB_TO_FLOAT_DENOMINATOR_2 :: 1.055
D3D10_SRGB_TO_FLOAT_EXPONENT :: 2.4
D3D10_SRGB_TO_FLOAT_OFFSET :: 0.055
D3D10_SRGB_TO_FLOAT_THRESHOLD :: 0.04045
D3D10_SRGB_TO_FLOAT_TOLERANCE_IN_ULP :: 0.5
D3D10_STANDARD_COMPONENT_BIT_COUNT :: 32
D3D10_STANDARD_COMPONENT_BIT_COUNT_DOUBLED :: 64
D3D10_STANDARD_MAXIMUM_ELEMENT_ALIGNMENT_BYTE_MULTIPLE :: 4
D3D10_STANDARD_PIXEL_COMPONENT_COUNT :: 128
D3D10_STANDARD_PIXEL_ELEMENT_COUNT :: 32
D3D10_STANDARD_VECTOR_SIZE :: 4
D3D10_STANDARD_VERTEX_ELEMENT_COUNT :: 16
D3D10_STANDARD_VERTEX_TOTAL_COMPONENT_COUNT :: 64
D3D10_SUBPIXEL_FRACTIONAL_BIT_COUNT :: 8
D3D10_SUBTEXEL_FRACTIONAL_BIT_COUNT :: 6
D3D10_TEXEL_ADDRESS_RANGE_BIT_COUNT :: 18
D3D10_UNBOUND_MEMORY_ACCESS_RESULT :: 0
D3D10_VIEWPORT_AND_SCISSORRECT_MAX_INDEX :: 15
D3D10_VIEWPORT_AND_SCISSORRECT_OBJECT_COUNT_PER_PIPELINE :: 16
D3D10_VIEWPORT_BOUNDS_MAX :: 16383
D3D10_VIEWPORT_BOUNDS_MIN :: -16384
D3D10_VS_INPUT_REGISTER_COMPONENTS :: 4
D3D10_VS_INPUT_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_VS_INPUT_REGISTER_COUNT :: 16
D3D10_VS_INPUT_REGISTER_READS_PER_INST :: 2
D3D10_VS_INPUT_REGISTER_READ_PORTS :: 1
D3D10_VS_OUTPUT_REGISTER_COMPONENTS :: 4
D3D10_VS_OUTPUT_REGISTER_COMPONENT_BIT_COUNT :: 32
D3D10_VS_OUTPUT_REGISTER_COUNT :: 16
D3D10_WHQL_CONTEXT_COUNT_FOR_RESOURCE_LIMIT :: 10
D3D10_WHQL_DRAWINDEXED_INDEX_COUNT_2_TO_EXP :: 25
D3D10_WHQL_DRAW_VERTEX_COUNT_2_TO_EXP :: 25
D3D_MAJOR_VERSION :: 10
D3D_MINOR_VERSION :: 0
D3D_SPEC_DATE_DAY :: 8
D3D_SPEC_DATE_MONTH :: 8
D3D_SPEC_DATE_YEAR :: 2006
D3D_SPEC_VERSION :: 1.050005
D3D10_1_IA_VERTEX_INPUT_STRUCTURE_ELEMENT_COUNT :: D3D10_IA_VERTEX_INPUT_STRUCTURE_ELEMENT_COUNT
D3D10_1_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT :: D3D10_IA_VERTEX_INPUT_STRUCTURE_ELEMENT_COUNT
_FACD3D10 :: 0x879
_FACD3D10DEBUG :: ((_FACD3D10 + 1))
MAKE_D3D10_HRESULT :: #force_inline proc(code: $A) -> c.int { return MAKE_HRESULT(1, _FACD3D10, code); }
MAKE_D3D10_STATUS :: #force_inline proc(code: $A) -> c.int { return MAKE_HRESULT(0, _FACD3D10, code); }
D3D10_APPEND_ALIGNED_ELEMENT :: 0xffffffff
D3D10_FILTER_TYPE_MASK :: 0x3
D3D10_MIN_FILTER_SHIFT :: 4
D3D10_MAG_FILTER_SHIFT :: 2
D3D10_MIP_FILTER_SHIFT :: 0
D3D10_COMPARISON_FILTERING_BIT :: 0x80
D3D10_ANISOTROPIC_FILTERING_BIT :: 0x40
D3D10_TEXT_1BIT_BIT :: 0x80000000
D3D10_ENCODE_BASIC_FILTER :: #force_inline proc(min: $A, mag: $B, mip: $C, bComparison: $D) -> c.int { return ((D3D10_FILTER)(((bComparison) ? D3D10_COMPARISON_FILTERING_BIT : 0) | (((min) & D3D10_FILTER_TYPE_MASK) << D3D10_MIN_FILTER_SHIFT) | (((mag) & D3D10_FILTER_TYPE_MASK) << D3D10_MAG_FILTER_SHIFT) | (((mip) & D3D10_FILTER_TYPE_MASK) << D3D10_MIP_FILTER_SHIFT))); }
D3D10_ENCODE_ANISOTROPIC_FILTER :: #force_inline proc(bComparison: $A) -> c.int { return ((D3D10_FILTER)(D3D10_ANISOTROPIC_FILTERING_BIT | D3D10_ENCODE_BASIC_FILTER( D3D10_FILTER_TYPE_LINEAR, D3D10_FILTER_TYPE_LINEAR, D3D10_FILTER_TYPE_LINEAR, bComparison))); }
D3D10_DECODE_MIN_FILTER :: #force_inline proc(d3d10Filter: $A) -> c.int { return ((D3D10_FILTER_TYPE)(((d3d10Filter) >> D3D10_MIN_FILTER_SHIFT) & D3D10_FILTER_TYPE_MASK)); }
D3D10_DECODE_MAG_FILTER :: #force_inline proc(d3d10Filter: $A) -> c.int { return ((D3D10_FILTER_TYPE)(((d3d10Filter) >> D3D10_MAG_FILTER_SHIFT) & D3D10_FILTER_TYPE_MASK)); }
D3D10_DECODE_MIP_FILTER :: #force_inline proc(d3d10Filter: $A) -> c.int { return ((D3D10_FILTER_TYPE)(((d3d10Filter) >> D3D10_MIP_FILTER_SHIFT) & D3D10_FILTER_TYPE_MASK)); }
D3D10_DECODE_IS_COMPARISON_FILTER :: #force_inline proc(d3d10Filter: $A) -> c.int { return ((d3d10Filter) & D3D10_COMPARISON_FILTERING_BIT); }
D3D10_DECODE_IS_ANISOTROPIC_FILTER :: #force_inline proc(d3d10Filter: $A) -> c.int { return (((d3d10Filter) & D3D10_ANISOTROPIC_FILTERING_BIT) && (D3D10_FILTER_TYPE_LINEAR == D3D10_DECODE_MIN_FILTER(d3d10Filter)) && (D3D10_FILTER_TYPE_LINEAR == D3D10_DECODE_MAG_FILTER(d3d10Filter)) && (D3D10_FILTER_TYPE_LINEAR == D3D10_DECODE_MIP_FILTER(d3d10Filter))); }
D3D10_DECODE_IS_TEXT_1BIT_FILTER :: #force_inline proc(d3d10Filter: $A) -> c.int { return ((d3d10Filter) == D3D10_TEXT_1BIT_BIT); }
D3D10_SDK_VERSION :: 29

D3D10_INPUT_CLASSIFICATION :: enum{
	D3D10_INPUT_PER_VERTEX_DATA = 0,
	D3D10_INPUT_PER_INSTANCE_DATA = 1
}
D3D10_INPUT_ELEMENT_DESC :: struct{
	SemanticName: win32.LPCSTR,
	SemanticIndex: win32.UINT,
	Format: dxgi.FORMAT,
	InputSlot: win32.UINT,
	AlignedByteOffset: win32.UINT,
	InputSlotClass: D3D10_INPUT_CLASSIFICATION,
	InstanceDataStepRate: win32.UINT,
}
D3D10_FILL_MODE :: enum{
	D3D10_FILL_WIREFRAME = 2,
	D3D10_FILL_SOLID = 3
}
D3D10_PRIMITIVE_TOPOLOGY :: d3d11.PRIMITIVE_TOPOLOGY
D3D10_PRIMITIVE :: d3d11.PRIMITIVE
D3D10_CULL_MODE :: enum{
	D3D10_CULL_NONE = 1,
	D3D10_CULL_FRONT = 2,
	D3D10_CULL_BACK = 3
}
D3D10_SO_DECLARATION_ENTRY :: struct{
	SemanticName: win32.LPCSTR,
	SemanticIndex: win32.UINT,
	StartComponent: win32.BYTE,
	ComponentCount: win32.BYTE,
	OutputSlot: win32.BYTE,
}
D3D10_VIEWPORT :: struct{
	TopLeftX: win32.INT,
	TopLeftY: win32.INT,
	Width: win32.UINT,
	Height: win32.UINT,
	MinDepth: f32,
	MaxDepth: f32,
}
D3D10_RESOURCE_DIMENSION :: enum{
	D3D10_RESOURCE_DIMENSION_UNKNOWN = 0,
	D3D10_RESOURCE_DIMENSION_BUFFER = 1,
	D3D10_RESOURCE_DIMENSION_TEXTURE1D = 2,
	D3D10_RESOURCE_DIMENSION_TEXTURE2D = 3,
	D3D10_RESOURCE_DIMENSION_TEXTURE3D = 4
}
D3D10_SRV_DIMENSION :: d3d11.SRV_DIMENSION
D3D10_DSV_DIMENSION :: enum{
	D3D10_DSV_DIMENSION_UNKNOWN = 0,
	D3D10_DSV_DIMENSION_TEXTURE1D = 1,
	D3D10_DSV_DIMENSION_TEXTURE1DARRAY = 2,
	D3D10_DSV_DIMENSION_TEXTURE2D = 3,
	D3D10_DSV_DIMENSION_TEXTURE2DARRAY = 4,
	D3D10_DSV_DIMENSION_TEXTURE2DMS = 5,
	D3D10_DSV_DIMENSION_TEXTURE2DMSARRAY = 6
}
D3D10_RTV_DIMENSION :: enum{
	D3D10_RTV_DIMENSION_UNKNOWN = 0,
	D3D10_RTV_DIMENSION_BUFFER = 1,
	D3D10_RTV_DIMENSION_TEXTURE1D = 2,
	D3D10_RTV_DIMENSION_TEXTURE1DARRAY = 3,
	D3D10_RTV_DIMENSION_TEXTURE2D = 4,
	D3D10_RTV_DIMENSION_TEXTURE2DARRAY = 5,
	D3D10_RTV_DIMENSION_TEXTURE2DMS = 6,
	D3D10_RTV_DIMENSION_TEXTURE2DMSARRAY = 7,
	D3D10_RTV_DIMENSION_TEXTURE3D = 8
}
D3D10_USAGE :: enum{
	D3D10_USAGE_DEFAULT = 0,
	D3D10_USAGE_IMMUTABLE = 1,
	D3D10_USAGE_DYNAMIC = 2,
	D3D10_USAGE_STAGING = 3
}
D3D10_BIND_FLAG :: enum{
	D3D10_BIND_VERTEX_BUFFER = 0x1,
	D3D10_BIND_INDEX_BUFFER = 0x2,
	D3D10_BIND_CONSTANT_BUFFER = 0x4,
	D3D10_BIND_SHADER_RESOURCE = 0x8,
	D3D10_BIND_STREAM_OUTPUT = 0x10,
	D3D10_BIND_RENDER_TARGET = 0x20,
	D3D10_BIND_DEPTH_STENCIL = 0x40
}
D3D10_CPU_ACCESS_FLAG :: enum{
	D3D10_CPU_ACCESS_WRITE = 0x10000,
	D3D10_CPU_ACCESS_READ = 0x20000
}
D3D10_RESOURCE_MISC_FLAG :: enum{
	D3D10_RESOURCE_MISC_GENERATE_MIPS = 0x1,
	D3D10_RESOURCE_MISC_SHARED = 0x2,
	D3D10_RESOURCE_MISC_TEXTURECUBE = 0x4,
	D3D10_RESOURCE_MISC_SHARED_KEYEDMUTEX = 0x10,
	D3D10_RESOURCE_MISC_GDI_COMPATIBLE = 0x20
}
D3D10_MAP :: enum{
	D3D10_MAP_READ = 1,
	D3D10_MAP_WRITE = 2,
	D3D10_MAP_READ_WRITE = 3,
	D3D10_MAP_WRITE_DISCARD = 4,
	D3D10_MAP_WRITE_NO_OVERWRITE = 5
}
D3D10_MAP_FLAG :: enum{
	D3D10_MAP_FLAG_DO_NOT_WAIT = 0x100000
}
D3D10_RAISE_FLAG :: enum{
	D3D10_RAISE_FLAG_DRIVER_INTERNAL_ERROR = 0x1
}
D3D10_CLEAR_FLAG :: enum{
	D3D10_CLEAR_DEPTH = 0x1,
	D3D10_CLEAR_STENCIL = 0x2
}
D3D10_RECT :: win32.RECT
D3D10_BOX :: struct{
	left: win32.UINT,
	top: win32.UINT,
	front: win32.UINT,
	right: win32.UINT,
	bottom: win32.UINT,
	back: win32.UINT,
}
ID3D10DeviceChildVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
}
D3D10_COMPARISON_FUNC :: enum{
	D3D10_COMPARISON_NEVER = 1,
	D3D10_COMPARISON_LESS = 2,
	D3D10_COMPARISON_EQUAL = 3,
	D3D10_COMPARISON_LESS_EQUAL = 4,
	D3D10_COMPARISON_GREATER = 5,
	D3D10_COMPARISON_NOT_EQUAL = 6,
	D3D10_COMPARISON_GREATER_EQUAL = 7,
	D3D10_COMPARISON_ALWAYS = 8
}
D3D10_DEPTH_WRITE_MASK :: enum{
	D3D10_DEPTH_WRITE_MASK_ZERO = 0,
	D3D10_DEPTH_WRITE_MASK_ALL = 1
}
D3D10_STENCIL_OP :: enum{
	D3D10_STENCIL_OP_KEEP = 1,
	D3D10_STENCIL_OP_ZERO = 2,
	D3D10_STENCIL_OP_REPLACE = 3,
	D3D10_STENCIL_OP_INCR_SAT = 4,
	D3D10_STENCIL_OP_DECR_SAT = 5,
	D3D10_STENCIL_OP_INVERT = 6,
	D3D10_STENCIL_OP_INCR = 7,
	D3D10_STENCIL_OP_DECR = 8
}
D3D10_DEPTH_STENCILOP_DESC :: struct{
	StencilFailOp: D3D10_STENCIL_OP,
	StencilDepthFailOp: D3D10_STENCIL_OP,
	StencilPassOp: D3D10_STENCIL_OP,
	StencilFunc: D3D10_COMPARISON_FUNC,
}
D3D10_DEPTH_STENCIL_DESC :: struct{
	DepthEnable: win32.BOOL,
	DepthWriteMask: D3D10_DEPTH_WRITE_MASK,
	DepthFunc: D3D10_COMPARISON_FUNC,
	StencilEnable: win32.BOOL,
	StencilReadMask: win32.UINT8,
	StencilWriteMask: win32.UINT8,
	FrontFace: D3D10_DEPTH_STENCILOP_DESC,
	BackFace: D3D10_DEPTH_STENCILOP_DESC,
}
ID3D10DepthStencilStateVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_DEPTH_STENCIL_DESC),
}
D3D10_BLEND :: enum{
	D3D10_BLEND_ZERO = 1,
	D3D10_BLEND_ONE = 2,
	D3D10_BLEND_SRC_COLOR = 3,
	D3D10_BLEND_INV_SRC_COLOR = 4,
	D3D10_BLEND_SRC_ALPHA = 5,
	D3D10_BLEND_INV_SRC_ALPHA = 6,
	D3D10_BLEND_DEST_ALPHA = 7,
	D3D10_BLEND_INV_DEST_ALPHA = 8,
	D3D10_BLEND_DEST_COLOR = 9,
	D3D10_BLEND_INV_DEST_COLOR = 10,
	D3D10_BLEND_SRC_ALPHA_SAT = 11,
	D3D10_BLEND_BLEND_FACTOR = 14,
	D3D10_BLEND_INV_BLEND_FACTOR = 15,
	D3D10_BLEND_SRC1_COLOR = 16,
	D3D10_BLEND_INV_SRC1_COLOR = 17,
	D3D10_BLEND_SRC1_ALPHA = 18,
	D3D10_BLEND_INV_SRC1_ALPHA = 19
}
D3D10_BLEND_OP :: enum{
	D3D10_BLEND_OP_ADD = 1,
	D3D10_BLEND_OP_SUBTRACT = 2,
	D3D10_BLEND_OP_REV_SUBTRACT = 3,
	D3D10_BLEND_OP_MIN = 4,
	D3D10_BLEND_OP_MAX = 5
}
D3D10_COLOR_WRITE_ENABLE :: enum{
	D3D10_COLOR_WRITE_ENABLE_RED = 1,
	D3D10_COLOR_WRITE_ENABLE_GREEN = 2,
	D3D10_COLOR_WRITE_ENABLE_BLUE = 4,
	D3D10_COLOR_WRITE_ENABLE_ALPHA = 8,
	D3D10_COLOR_WRITE_ENABLE_ALL = ((D3D10_COLOR_WRITE_ENABLE_RED|D3D10_COLOR_WRITE_ENABLE_GREEN)|D3D10_COLOR_WRITE_ENABLE_BLUE)|D3D10_COLOR_WRITE_ENABLE_ALPHA
}
D3D10_BLEND_DESC :: struct{
	AlphaToCoverageEnable: win32.BOOL,
	BlendEnable: [8]win32.BOOL,
	SrcBlend: D3D10_BLEND,
	DestBlend: D3D10_BLEND,
	BlendOp: D3D10_BLEND_OP,
	SrcBlendAlpha: D3D10_BLEND,
	DestBlendAlpha: D3D10_BLEND,
	BlendOpAlpha: D3D10_BLEND_OP,
	RenderTargetWriteMask: [8]win32.UINT8,
}
ID3D10BlendStateVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_BLEND_DESC),
}
D3D10_RASTERIZER_DESC :: struct{
	FillMode: D3D10_FILL_MODE,
	CullMode: D3D10_CULL_MODE,
	FrontCounterClockwise: win32.BOOL,
	DepthBias: win32.INT,
	DepthBiasClamp: f32,
	SlopeScaledDepthBias: f32,
	DepthClipEnable: win32.BOOL,
	ScissorEnable: win32.BOOL,
	MultisampleEnable: win32.BOOL,
	AntialiasedLineEnable: win32.BOOL,
}
ID3D10RasterizerStateVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_RASTERIZER_DESC),
}
D3D10_SUBRESOURCE_DATA :: struct{
	pSysMem: rawptr,
	SysMemPitch: win32.UINT,
	SysMemSlicePitch: win32.UINT,
}
ID3D10ResourceVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetType: #type proc "stdcall" (This: ^rawptr, rType: ^D3D10_RESOURCE_DIMENSION),
	SetEvictionPriority: #type proc "stdcall" (This: ^rawptr, EvictionPriority: win32.UINT),
	GetEvictionPriority: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
}
D3D10_BUFFER_DESC :: struct{
	ByteWidth: win32.UINT,
	Usage: D3D10_USAGE,
	BindFlags: win32.UINT,
	CPUAccessFlags: win32.UINT,
	MiscFlags: win32.UINT,
}
ID3D10BufferVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetType: #type proc "stdcall" (This: ^rawptr, rType: ^D3D10_RESOURCE_DIMENSION),
	SetEvictionPriority: #type proc "stdcall" (This: ^rawptr, EvictionPriority: win32.UINT),
	GetEvictionPriority: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	Map: #type proc "stdcall" (This: ^rawptr, MapType: D3D10_MAP, MapFlags: win32.UINT, ppData: ^rawptr) -> win32.HRESULT,
	Unmap: #type proc "stdcall" (This: ^rawptr),
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_BUFFER_DESC),
}
D3D10_TEXTURE1D_DESC :: struct{
	Width: win32.UINT,
	MipLevels: win32.UINT,
	ArraySize: win32.UINT,
	Format: dxgi.FORMAT,
	Usage: D3D10_USAGE,
	BindFlags: win32.UINT,
	CPUAccessFlags: win32.UINT,
	MiscFlags: win32.UINT,
}
ID3D10Texture1DVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetType: #type proc "stdcall" (This: ^rawptr, rType: ^D3D10_RESOURCE_DIMENSION),
	SetEvictionPriority: #type proc "stdcall" (This: ^rawptr, EvictionPriority: win32.UINT),
	GetEvictionPriority: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	Map: #type proc "stdcall" (This: ^rawptr, Subresource: win32.UINT, MapType: D3D10_MAP, MapFlags: win32.UINT, ppData: ^rawptr) -> win32.HRESULT,
	Unmap: #type proc "stdcall" (This: ^rawptr, Subresource: win32.UINT),
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_TEXTURE1D_DESC),
}
D3D10_TEXTURE2D_DESC :: struct{
	Width: win32.UINT,
	Height: win32.UINT,
	MipLevels: win32.UINT,
	ArraySize: win32.UINT,
	Format: dxgi.FORMAT,
	SampleDesc: dxgi.SAMPLE_DESC,
	Usage: D3D10_USAGE,
	BindFlags: win32.UINT,
	CPUAccessFlags: win32.UINT,
	MiscFlags: win32.UINT,
}
D3D10_MAPPED_TEXTURE2D :: struct{
	pData: rawptr,
	RowPitch: win32.UINT,
}
ID3D10Texture2DVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetType: #type proc "stdcall" (This: ^rawptr, rType: ^D3D10_RESOURCE_DIMENSION),
	SetEvictionPriority: #type proc "stdcall" (This: ^rawptr, EvictionPriority: win32.UINT),
	GetEvictionPriority: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	Map: #type proc "stdcall" (This: ^rawptr, Subresource: win32.UINT, MapType: D3D10_MAP, MapFlags: win32.UINT, pMappedTex2D: ^D3D10_MAPPED_TEXTURE2D) -> win32.HRESULT,
	Unmap: #type proc "stdcall" (This: ^rawptr, Subresource: win32.UINT),
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_TEXTURE2D_DESC),
}
D3D10_TEXTURE3D_DESC :: struct{
	Width: win32.UINT,
	Height: win32.UINT,
	Depth: win32.UINT,
	MipLevels: win32.UINT,
	Format: dxgi.FORMAT,
	Usage: D3D10_USAGE,
	BindFlags: win32.UINT,
	CPUAccessFlags: win32.UINT,
	MiscFlags: win32.UINT,
}
D3D10_MAPPED_TEXTURE3D :: struct{
	pData: rawptr,
	RowPitch: win32.UINT,
	DepthPitch: win32.UINT,
}
ID3D10Texture3DVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetType: #type proc "stdcall" (This: ^rawptr, rType: ^D3D10_RESOURCE_DIMENSION),
	SetEvictionPriority: #type proc "stdcall" (This: ^rawptr, EvictionPriority: win32.UINT),
	GetEvictionPriority: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	Map: #type proc "stdcall" (This: ^rawptr, Subresource: win32.UINT, MapType: D3D10_MAP, MapFlags: win32.UINT, pMappedTex3D: ^D3D10_MAPPED_TEXTURE3D) -> win32.HRESULT,
	Unmap: #type proc "stdcall" (This: ^rawptr, Subresource: win32.UINT),
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_TEXTURE3D_DESC),
}
D3D10_TEXTURECUBE_FACE :: enum{
	D3D10_TEXTURECUBE_FACE_POSITIVE_X = 0,
	D3D10_TEXTURECUBE_FACE_NEGATIVE_X = 1,
	D3D10_TEXTURECUBE_FACE_POSITIVE_Y = 2,
	D3D10_TEXTURECUBE_FACE_NEGATIVE_Y = 3,
	D3D10_TEXTURECUBE_FACE_POSITIVE_Z = 4,
	D3D10_TEXTURECUBE_FACE_NEGATIVE_Z = 5
}
ID3D10ViewVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetResource: #type proc "stdcall" (This: ^rawptr, ppResource: ^^rawptr),
}
D3D10_BUFFER_SRV :: struct{
	using _: struct #raw_union {
		FirstElement: win32.UINT,
		ElementOffset: win32.UINT,
	},
	using _: struct #raw_union {
		NumElements: win32.UINT,
		ElementWidth: win32.UINT,
	},
}
D3D10_TEX1D_SRV :: struct{
	MostDetailedMip: win32.UINT,
	MipLevels: win32.UINT,
}
D3D10_TEX1D_ARRAY_SRV :: struct{
	MostDetailedMip: win32.UINT,
	MipLevels: win32.UINT,
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_TEX2D_SRV :: struct{
	MostDetailedMip: win32.UINT,
	MipLevels: win32.UINT,
}
D3D10_TEX2D_ARRAY_SRV :: struct{
	MostDetailedMip: win32.UINT,
	MipLevels: win32.UINT,
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_TEX3D_SRV :: struct{
	MostDetailedMip: win32.UINT,
	MipLevels: win32.UINT,
}
D3D10_TEXCUBE_SRV :: struct{
	MostDetailedMip: win32.UINT,
	MipLevels: win32.UINT,
}
D3D10_TEX2DMS_SRV :: struct{
	UnusedField_NothingToDefine: win32.UINT,
}
D3D10_TEX2DMS_ARRAY_SRV :: struct{
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_SHADER_RESOURCE_VIEW_DESC :: struct{
	Format: dxgi.FORMAT,
	ViewDimension: D3D10_SRV_DIMENSION,
	using _: struct #raw_union {
		Buffer: D3D10_BUFFER_SRV,
		Texture1D: D3D10_TEX1D_SRV,
		Texture1DArray: D3D10_TEX1D_ARRAY_SRV,
		Texture2D: D3D10_TEX2D_SRV,
		Texture2DArray: D3D10_TEX2D_ARRAY_SRV,
		Texture2DMS: D3D10_TEX2DMS_SRV,
		Texture2DMSArray: D3D10_TEX2DMS_ARRAY_SRV,
		Texture3D: D3D10_TEX3D_SRV,
		TextureCube: D3D10_TEXCUBE_SRV,
	},
}
ID3D10ShaderResourceViewVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetResource: #type proc "stdcall" (This: ^rawptr, ppResource: ^^rawptr),
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_SHADER_RESOURCE_VIEW_DESC),
}
D3D10_BUFFER_RTV :: struct{
	using _: struct #raw_union {
		FirstElement: win32.UINT,
		ElementOffset: win32.UINT,
	},
	using _: struct #raw_union {
		NumElements: win32.UINT,
		ElementWidth: win32.UINT,
	},
}
D3D10_TEX1D_RTV :: struct{
	MipSlice: win32.UINT,
}
D3D10_TEX1D_ARRAY_RTV :: struct{
	MipSlice: win32.UINT,
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_TEX2D_RTV :: struct{
	MipSlice: win32.UINT,
}
D3D10_TEX2DMS_RTV :: struct{
	UnusedField_NothingToDefine: win32.UINT,
}
D3D10_TEX2D_ARRAY_RTV :: struct{
	MipSlice: win32.UINT,
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_TEX2DMS_ARRAY_RTV :: struct{
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_TEX3D_RTV :: struct{
	MipSlice: win32.UINT,
	FirstWSlice: win32.UINT,
	WSize: win32.UINT,
}
D3D10_RENDER_TARGET_VIEW_DESC :: struct{
	Format: dxgi.FORMAT,
	ViewDimension: D3D10_RTV_DIMENSION,
	using _: struct #raw_union {
		Buffer: D3D10_BUFFER_RTV,
		Texture1D: D3D10_TEX1D_RTV,
		Texture1DArray: D3D10_TEX1D_ARRAY_RTV,
		Texture2D: D3D10_TEX2D_RTV,
		Texture2DArray: D3D10_TEX2D_ARRAY_RTV,
		Texture2DMS: D3D10_TEX2DMS_RTV,
		Texture2DMSArray: D3D10_TEX2DMS_ARRAY_RTV,
		Texture3D: D3D10_TEX3D_RTV,
	},
}
ID3D10RenderTargetViewVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetResource: #type proc "stdcall" (This: ^rawptr, ppResource: ^^rawptr),
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_RENDER_TARGET_VIEW_DESC),
}
D3D10_TEX1D_DSV :: struct{
	MipSlice: win32.UINT,
}
D3D10_TEX1D_ARRAY_DSV :: struct{
	MipSlice: win32.UINT,
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_TEX2D_DSV :: struct{
	MipSlice: win32.UINT,
}
D3D10_TEX2D_ARRAY_DSV :: struct{
	MipSlice: win32.UINT,
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_TEX2DMS_DSV :: struct{
	UnusedField_NothingToDefine: win32.UINT,
}
D3D10_TEX2DMS_ARRAY_DSV :: struct{
	FirstArraySlice: win32.UINT,
	ArraySize: win32.UINT,
}
D3D10_DEPTH_STENCIL_VIEW_DESC :: struct{
	Format: dxgi.FORMAT,
	ViewDimension: D3D10_DSV_DIMENSION,
	using _: struct #raw_union {
		Texture1D: D3D10_TEX1D_DSV,
		Texture1DArray: D3D10_TEX1D_ARRAY_DSV,
		Texture2D: D3D10_TEX2D_DSV,
		Texture2DArray: D3D10_TEX2D_ARRAY_DSV,
		Texture2DMS: D3D10_TEX2DMS_DSV,
		Texture2DMSArray: D3D10_TEX2DMS_ARRAY_DSV,
	},
}
ID3D10DepthStencilViewVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetResource: #type proc "stdcall" (This: ^rawptr, ppResource: ^^rawptr),
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_DEPTH_STENCIL_VIEW_DESC),
}
ID3D10VertexShaderVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
}
ID3D10GeometryShaderVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
}
ID3D10PixelShaderVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
}
ID3D10InputLayoutVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
}
D3D10_FILTER :: enum{
	D3D10_FILTER_MIN_MAG_MIP_POINT = 0,
	D3D10_FILTER_MIN_MAG_POINT_MIP_LINEAR = 0x1,
	D3D10_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x4,
	D3D10_FILTER_MIN_POINT_MAG_MIP_LINEAR = 0x5,
	D3D10_FILTER_MIN_LINEAR_MAG_MIP_POINT = 0x10,
	D3D10_FILTER_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x11,
	D3D10_FILTER_MIN_MAG_LINEAR_MIP_POINT = 0x14,
	D3D10_FILTER_MIN_MAG_MIP_LINEAR = 0x15,
	D3D10_FILTER_ANISOTROPIC = 0x55,
	D3D10_FILTER_COMPARISON_MIN_MAG_MIP_POINT = 0x80,
	D3D10_FILTER_COMPARISON_MIN_MAG_POINT_MIP_LINEAR = 0x81,
	D3D10_FILTER_COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x84,
	D3D10_FILTER_COMPARISON_MIN_POINT_MAG_MIP_LINEAR = 0x85,
	D3D10_FILTER_COMPARISON_MIN_LINEAR_MAG_MIP_POINT = 0x90,
	D3D10_FILTER_COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x91,
	D3D10_FILTER_COMPARISON_MIN_MAG_LINEAR_MIP_POINT = 0x94,
	D3D10_FILTER_COMPARISON_MIN_MAG_MIP_LINEAR = 0x95,
	D3D10_FILTER_COMPARISON_ANISOTROPIC = 0xd5,
	D3D10_FILTER_TEXT_1BIT = 0x80000000
}
D3D10_FILTER_TYPE :: enum{
	D3D10_FILTER_TYPE_POINT = 0,
	D3D10_FILTER_TYPE_LINEAR = 1
}
D3D10_TEXTURE_ADDRESS_MODE :: enum{
	D3D10_TEXTURE_ADDRESS_WRAP = 1,
	D3D10_TEXTURE_ADDRESS_MIRROR = 2,
	D3D10_TEXTURE_ADDRESS_CLAMP = 3,
	D3D10_TEXTURE_ADDRESS_BORDER = 4,
	D3D10_TEXTURE_ADDRESS_MIRROR_ONCE = 5
}
D3D10_SAMPLER_DESC :: struct{
	Filter: D3D10_FILTER,
	AddressU: D3D10_TEXTURE_ADDRESS_MODE,
	AddressV: D3D10_TEXTURE_ADDRESS_MODE,
	AddressW: D3D10_TEXTURE_ADDRESS_MODE,
	MipLODBias: f32,
	MaxAnisotropy: win32.UINT,
	ComparisonFunc: D3D10_COMPARISON_FUNC,
	BorderColor: [4]f32,
	MinLOD: f32,
	MaxLOD: f32,
}
ID3D10SamplerStateVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_SAMPLER_DESC),
}
D3D10_FORMAT_SUPPORT :: enum{
	D3D10_FORMAT_SUPPORT_BUFFER = 0x1,
	D3D10_FORMAT_SUPPORT_IA_VERTEX_BUFFER = 0x2,
	D3D10_FORMAT_SUPPORT_IA_INDEX_BUFFER = 0x4,
	D3D10_FORMAT_SUPPORT_SO_BUFFER = 0x8,
	D3D10_FORMAT_SUPPORT_TEXTURE1D = 0x10,
	D3D10_FORMAT_SUPPORT_TEXTURE2D = 0x20,
	D3D10_FORMAT_SUPPORT_TEXTURE3D = 0x40,
	D3D10_FORMAT_SUPPORT_TEXTURECUBE = 0x80,
	D3D10_FORMAT_SUPPORT_SHADER_LOAD = 0x100,
	D3D10_FORMAT_SUPPORT_SHADER_SAMPLE = 0x200,
	D3D10_FORMAT_SUPPORT_SHADER_SAMPLE_COMPARISON = 0x400,
	D3D10_FORMAT_SUPPORT_SHADER_SAMPLE_MONO_TEXT = 0x800,
	D3D10_FORMAT_SUPPORT_MIP = 0x1000,
	D3D10_FORMAT_SUPPORT_MIP_AUTOGEN = 0x2000,
	D3D10_FORMAT_SUPPORT_RENDER_TARGET = 0x4000,
	D3D10_FORMAT_SUPPORT_BLENDABLE = 0x8000,
	D3D10_FORMAT_SUPPORT_DEPTH_STENCIL = 0x10000,
	D3D10_FORMAT_SUPPORT_CPU_LOCKABLE = 0x20000,
	D3D10_FORMAT_SUPPORT_MULTISAMPLE_RESOLVE = 0x40000,
	D3D10_FORMAT_SUPPORT_DISPLAY = 0x80000,
	D3D10_FORMAT_SUPPORT_CAST_WITHIN_BIT_LAYOUT = 0x100000,
	D3D10_FORMAT_SUPPORT_MULTISAMPLE_RENDERTARGET = 0x200000,
	D3D10_FORMAT_SUPPORT_MULTISAMPLE_LOAD = 0x400000,
	D3D10_FORMAT_SUPPORT_SHADER_GATHER = 0x800000,
	D3D10_FORMAT_SUPPORT_BACK_BUFFER_CAST = 0x1000000
}
ID3D10AsynchronousVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	Begin: #type proc "stdcall" (This: ^rawptr),
	End: #type proc "stdcall" (This: ^rawptr),
	GetData: #type proc "stdcall" (This: ^rawptr, pData: rawptr, DataSize: win32.UINT, GetDataFlags: win32.UINT) -> win32.HRESULT,
	GetDataSize: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
}
D3D10_ASYNC_GETDATA_FLAG :: enum{
	D3D10_ASYNC_GETDATA_DONOTFLUSH = 0x1
}
D3D10_QUERY :: enum{
	D3D10_QUERY_EVENT = 0,
	D3D10_QUERY_OCCLUSION = D3D10_QUERY_EVENT+1,
	D3D10_QUERY_TIMESTAMP = D3D10_QUERY_OCCLUSION+1,
	D3D10_QUERY_TIMESTAMP_DISJOINT = D3D10_QUERY_TIMESTAMP+1,
	D3D10_QUERY_PIPELINE_STATISTICS = D3D10_QUERY_TIMESTAMP_DISJOINT+1,
	D3D10_QUERY_OCCLUSION_PREDICATE = D3D10_QUERY_PIPELINE_STATISTICS+1,
	D3D10_QUERY_SO_STATISTICS = D3D10_QUERY_OCCLUSION_PREDICATE+1,
	D3D10_QUERY_SO_OVERFLOW_PREDICATE = D3D10_QUERY_SO_STATISTICS+1
}
D3D10_QUERY_MISC_FLAG :: enum{
	D3D10_QUERY_MISC_PREDICATEHINT = 0x1
}
D3D10_QUERY_DESC :: struct{
	Query: D3D10_QUERY,
	MiscFlags: win32.UINT,
}
ID3D10QueryVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	Begin: #type proc "stdcall" (This: ^rawptr),
	End: #type proc "stdcall" (This: ^rawptr),
	GetData: #type proc "stdcall" (This: ^rawptr, pData: rawptr, DataSize: win32.UINT, GetDataFlags: win32.UINT) -> win32.HRESULT,
	GetDataSize: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_QUERY_DESC),
}
ID3D10PredicateVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	Begin: #type proc "stdcall" (This: ^rawptr),
	End: #type proc "stdcall" (This: ^rawptr),
	GetData: #type proc "stdcall" (This: ^rawptr, pData: rawptr, DataSize: win32.UINT, GetDataFlags: win32.UINT) -> win32.HRESULT,
	GetDataSize: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_QUERY_DESC),
}
D3D10_QUERY_DATA_TIMESTAMP_DISJOINT :: struct{
	Frequency: win32.UINT8,
	Disjoint: win32.BOOL,
}
D3D10_QUERY_DATA_PIPELINE_STATISTICS :: struct{
	IAVertices: win32.UINT8,
	IAPrimitives: win32.UINT8,
	VSInvocations: win32.UINT8,
	GSInvocations: win32.UINT8,
	GSPrimitives: win32.UINT8,
	CInvocations: win32.UINT8,
	CPrimitives: win32.UINT8,
	PSInvocations: win32.UINT8,
}
D3D10_QUERY_DATA_SO_STATISTICS :: struct{
	NumPrimitivesWritten: win32.UINT8,
	PrimitivesStorageNeeded: win32.UINT8,
}
D3D10_COUNTER :: enum{
	D3D10_COUNTER_GPU_IDLE = 0,
	D3D10_COUNTER_VERTEX_PROCESSING = D3D10_COUNTER_GPU_IDLE+1,
	D3D10_COUNTER_GEOMETRY_PROCESSING = D3D10_COUNTER_VERTEX_PROCESSING+1,
	D3D10_COUNTER_PIXEL_PROCESSING = D3D10_COUNTER_GEOMETRY_PROCESSING+1,
	D3D10_COUNTER_OTHER_GPU_PROCESSING = D3D10_COUNTER_PIXEL_PROCESSING+1,
	D3D10_COUNTER_HOST_ADAPTER_BANDWIDTH_UTILIZATION = D3D10_COUNTER_OTHER_GPU_PROCESSING+1,
	D3D10_COUNTER_LOCAL_VIDMEM_BANDWIDTH_UTILIZATION = D3D10_COUNTER_HOST_ADAPTER_BANDWIDTH_UTILIZATION+1,
	D3D10_COUNTER_VERTEX_THROUGHPUT_UTILIZATION = D3D10_COUNTER_LOCAL_VIDMEM_BANDWIDTH_UTILIZATION+1,
	D3D10_COUNTER_TRIANGLE_SETUP_THROUGHPUT_UTILIZATION = D3D10_COUNTER_VERTEX_THROUGHPUT_UTILIZATION+1,
	D3D10_COUNTER_FILLRATE_THROUGHPUT_UTILIZATION = D3D10_COUNTER_TRIANGLE_SETUP_THROUGHPUT_UTILIZATION+1,
	D3D10_COUNTER_VS_MEMORY_LIMITED = D3D10_COUNTER_FILLRATE_THROUGHPUT_UTILIZATION+1,
	D3D10_COUNTER_VS_COMPUTATION_LIMITED = D3D10_COUNTER_VS_MEMORY_LIMITED+1,
	D3D10_COUNTER_GS_MEMORY_LIMITED = D3D10_COUNTER_VS_COMPUTATION_LIMITED+1,
	D3D10_COUNTER_GS_COMPUTATION_LIMITED = D3D10_COUNTER_GS_MEMORY_LIMITED+1,
	D3D10_COUNTER_PS_MEMORY_LIMITED = D3D10_COUNTER_GS_COMPUTATION_LIMITED+1,
	D3D10_COUNTER_PS_COMPUTATION_LIMITED = D3D10_COUNTER_PS_MEMORY_LIMITED+1,
	D3D10_COUNTER_POST_TRANSFORM_CACHE_HIT_RATE = D3D10_COUNTER_PS_COMPUTATION_LIMITED+1,
	D3D10_COUNTER_TEXTURE_CACHE_HIT_RATE = D3D10_COUNTER_POST_TRANSFORM_CACHE_HIT_RATE+1,
	D3D10_COUNTER_DEVICE_DEPENDENT_0 = 0x40000000
}
D3D10_COUNTER_TYPE :: enum{
	D3D10_COUNTER_TYPE_FLOAT32 = 0,
	D3D10_COUNTER_TYPE_UINT16 = D3D10_COUNTER_TYPE_FLOAT32+1,
	D3D10_COUNTER_TYPE_UINT32 = D3D10_COUNTER_TYPE_UINT16+1,
	D3D10_COUNTER_TYPE_UINT64 = D3D10_COUNTER_TYPE_UINT32+1
}
D3D10_COUNTER_DESC :: struct{
	Counter: D3D10_COUNTER,
	MiscFlags: win32.UINT,
}
D3D10_COUNTER_INFO :: struct{
	LastDeviceDependentCounter: D3D10_COUNTER,
	NumSimultaneousCounters: win32.UINT,
	NumDetectableParallelUnits: win32.UINT8,
}
ID3D10CounterVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	GetDevice: #type proc "stdcall" (This: ^rawptr, ppDevice: ^^rawptr),
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	Begin: #type proc "stdcall" (This: ^rawptr),
	End: #type proc "stdcall" (This: ^rawptr),
	GetData: #type proc "stdcall" (This: ^rawptr, pData: rawptr, DataSize: win32.UINT, GetDataFlags: win32.UINT) -> win32.HRESULT,
	GetDataSize: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	GetDesc: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_COUNTER_DESC),
}
ID3D10DeviceVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	VSSetConstantBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppConstantBuffers: ^^rawptr),
	PSSetShaderResources: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumViews: win32.UINT, ppShaderResourceViews: ^^rawptr),
	PSSetShader: #type proc "stdcall" (This: ^rawptr, pPixelShader: ^rawptr),
	PSSetSamplers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumSamplers: win32.UINT, ppSamplers: ^^rawptr),
	VSSetShader: #type proc "stdcall" (This: ^rawptr, pVertexShader: ^rawptr),
	DrawIndexed: #type proc "stdcall" (This: ^rawptr, IndexCount: win32.UINT, StartIndexLocation: win32.UINT, BaseVertexLocation: win32.INT),
	Draw: #type proc "stdcall" (This: ^rawptr, VertexCount: win32.UINT, StartVertexLocation: win32.UINT),
	PSSetConstantBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppConstantBuffers: ^^rawptr),
	IASetInputLayout: #type proc "stdcall" (This: ^rawptr, pInputLayout: ^rawptr),
	IASetVertexBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppVertexBuffers: ^^rawptr, pStrides: ^win32.UINT, pOffsets: ^win32.UINT),
	IASetIndexBuffer: #type proc "stdcall" (This: ^rawptr, pIndexBuffer: ^rawptr, Format: dxgi.FORMAT, Offset: win32.UINT),
	DrawIndexedInstanced: #type proc "stdcall" (This: ^rawptr, IndexCountPerInstance: win32.UINT, InstanceCount: win32.UINT, StartIndexLocation: win32.UINT, BaseVertexLocation: win32.INT, StartInstanceLocation: win32.UINT),
	DrawInstanced: #type proc "stdcall" (This: ^rawptr, VertexCountPerInstance: win32.UINT, InstanceCount: win32.UINT, StartVertexLocation: win32.UINT, StartInstanceLocation: win32.UINT),
	GSSetConstantBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppConstantBuffers: ^^rawptr),
	GSSetShader: #type proc "stdcall" (This: ^rawptr, pShader: ^rawptr),
	IASetPrimitiveTopology: #type proc "stdcall" (This: ^rawptr, Topology: D3D10_PRIMITIVE_TOPOLOGY),
	VSSetShaderResources: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumViews: win32.UINT, ppShaderResourceViews: ^^rawptr),
	VSSetSamplers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumSamplers: win32.UINT, ppSamplers: ^^rawptr),
	SetPredication: #type proc "stdcall" (This: ^rawptr, pPredicate: ^rawptr, PredicateValue: win32.BOOL),
	GSSetShaderResources: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumViews: win32.UINT, ppShaderResourceViews: ^^rawptr),
	GSSetSamplers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumSamplers: win32.UINT, ppSamplers: ^^rawptr),
	OMSetRenderTargets: #type proc "stdcall" (This: ^rawptr, NumViews: win32.UINT, ppRenderTargetViews: ^^rawptr, pDepthStencilView: ^rawptr),
	OMSetBlendState: #type proc "stdcall" (This: ^rawptr, pBlendState: ^rawptr, BlendFactor: [4]f32, SampleMask: win32.UINT),
	OMSetDepthStencilState: #type proc "stdcall" (This: ^rawptr, pDepthStencilState: ^rawptr, StencilRef: win32.UINT),
	SOSetTargets: #type proc "stdcall" (This: ^rawptr, NumBuffers: win32.UINT, ppSOTargets: ^^rawptr, pOffsets: ^win32.UINT),
	DrawAuto: #type proc "stdcall" (This: ^rawptr),
	RSSetState: #type proc "stdcall" (This: ^rawptr, pRasterizerState: ^rawptr),
	RSSetViewports: #type proc "stdcall" (This: ^rawptr, NumViewports: win32.UINT, pViewports: ^D3D10_VIEWPORT),
	RSSetScissorRects: #type proc "stdcall" (This: ^rawptr, NumRects: win32.UINT, pRects: ^D3D10_RECT),
	CopySubresourceRegion: #type proc "stdcall" (This: ^rawptr, pDstResource: ^rawptr, DstSubresource: win32.UINT, DstX: win32.UINT, DstY: win32.UINT, DstZ: win32.UINT, pSrcResource: ^rawptr, SrcSubresource: win32.UINT, pSrcBox: ^D3D10_BOX),
	CopyResource: #type proc "stdcall" (This: ^rawptr, pDstResource: ^rawptr, pSrcResource: ^rawptr),
	UpdateSubresource: #type proc "stdcall" (This: ^rawptr, pDstResource: ^rawptr, DstSubresource: win32.UINT, pDstBox: ^D3D10_BOX, pSrcData: rawptr, SrcRowPitch: win32.UINT, SrcDepthPitch: win32.UINT),
	ClearRenderTargetView: #type proc "stdcall" (This: ^rawptr, pRenderTargetView: ^rawptr, ColorRGBA: [4]f32),
	ClearDepthStencilView: #type proc "stdcall" (This: ^rawptr, pDepthStencilView: ^rawptr, ClearFlags: win32.UINT, Depth: f32, Stencil: win32.UINT8),
	GenerateMips: #type proc "stdcall" (This: ^rawptr, pShaderResourceView: ^rawptr),
	ResolveSubresource: #type proc "stdcall" (This: ^rawptr, pDstResource: ^rawptr, DstSubresource: win32.UINT, pSrcResource: ^rawptr, SrcSubresource: win32.UINT, Format: dxgi.FORMAT),
	VSGetConstantBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppConstantBuffers: ^^rawptr),
	PSGetShaderResources: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumViews: win32.UINT, ppShaderResourceViews: ^^rawptr),
	PSGetShader: #type proc "stdcall" (This: ^rawptr, ppPixelShader: ^^rawptr),
	PSGetSamplers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumSamplers: win32.UINT, ppSamplers: ^^rawptr),
	VSGetShader: #type proc "stdcall" (This: ^rawptr, ppVertexShader: ^^rawptr),
	PSGetConstantBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppConstantBuffers: ^^rawptr),
	IAGetInputLayout: #type proc "stdcall" (This: ^rawptr, ppInputLayout: ^^rawptr),
	IAGetVertexBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppVertexBuffers: ^^rawptr, pStrides: ^win32.UINT, pOffsets: ^win32.UINT),
	IAGetIndexBuffer: #type proc "stdcall" (This: ^rawptr, pIndexBuffer: ^^rawptr, Format: ^dxgi.FORMAT, Offset: ^win32.UINT),
	GSGetConstantBuffers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumBuffers: win32.UINT, ppConstantBuffers: ^^rawptr),
	GSGetShader: #type proc "stdcall" (This: ^rawptr, ppGeometryShader: ^^rawptr),
	IAGetPrimitiveTopology: #type proc "stdcall" (This: ^rawptr, pTopology: ^D3D10_PRIMITIVE_TOPOLOGY),
	VSGetShaderResources: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumViews: win32.UINT, ppShaderResourceViews: ^^rawptr),
	VSGetSamplers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumSamplers: win32.UINT, ppSamplers: ^^rawptr),
	GetPredication: #type proc "stdcall" (This: ^rawptr, ppPredicate: ^^rawptr, pPredicateValue: ^win32.BOOL),
	GSGetShaderResources: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumViews: win32.UINT, ppShaderResourceViews: ^^rawptr),
	GSGetSamplers: #type proc "stdcall" (This: ^rawptr, StartSlot: win32.UINT, NumSamplers: win32.UINT, ppSamplers: ^^rawptr),
	OMGetRenderTargets: #type proc "stdcall" (This: ^rawptr, NumViews: win32.UINT, ppRenderTargetViews: ^^rawptr, ppDepthStencilView: ^^rawptr),
	OMGetBlendState: #type proc "stdcall" (This: ^rawptr, ppBlendState: ^^rawptr, BlendFactor: [4]f32, pSampleMask: ^win32.UINT),
	OMGetDepthStencilState: #type proc "stdcall" (This: ^rawptr, ppDepthStencilState: ^^rawptr, pStencilRef: ^win32.UINT),
	SOGetTargets: #type proc "stdcall" (This: ^rawptr, NumBuffers: win32.UINT, ppSOTargets: ^^rawptr, pOffsets: ^win32.UINT),
	RSGetState: #type proc "stdcall" (This: ^rawptr, ppRasterizerState: ^^rawptr),
	RSGetViewports: #type proc "stdcall" (This: ^rawptr, NumViewports: ^win32.UINT, pViewports: ^D3D10_VIEWPORT),
	RSGetScissorRects: #type proc "stdcall" (This: ^rawptr, NumRects: ^win32.UINT, pRects: ^D3D10_RECT),
	GetDeviceRemovedReason: #type proc "stdcall" (This: ^rawptr) -> win32.HRESULT,
	SetExceptionMode: #type proc "stdcall" (This: ^rawptr, RaiseFlags: win32.UINT) -> win32.HRESULT,
	GetExceptionMode: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	GetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pDataSize: ^win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateData: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, DataSize: win32.UINT, pData: rawptr) -> win32.HRESULT,
	SetPrivateDataInterface: #type proc "stdcall" (This: ^rawptr, guid: ^win32.GUID, pData: ^rawptr) -> win32.HRESULT,
	ClearState: #type proc "stdcall" (This: ^rawptr),
	Flush: #type proc "stdcall" (This: ^rawptr),
	CreateBuffer: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_BUFFER_DESC, pInitialData: ^D3D10_SUBRESOURCE_DATA, ppBuffer: ^^rawptr) -> win32.HRESULT,
	CreateTexture1D: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_TEXTURE1D_DESC, pInitialData: ^D3D10_SUBRESOURCE_DATA, ppTexture1D: ^^rawptr) -> win32.HRESULT,
	CreateTexture2D: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_TEXTURE2D_DESC, pInitialData: ^D3D10_SUBRESOURCE_DATA, ppTexture2D: ^^rawptr) -> win32.HRESULT,
	CreateTexture3D: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_TEXTURE3D_DESC, pInitialData: ^D3D10_SUBRESOURCE_DATA, ppTexture3D: ^^rawptr) -> win32.HRESULT,
	CreateShaderResourceView: #type proc "stdcall" (This: ^rawptr, pResource: ^rawptr, pDesc: ^D3D10_SHADER_RESOURCE_VIEW_DESC, ppSRView: ^^rawptr) -> win32.HRESULT,
	CreateRenderTargetView: #type proc "stdcall" (This: ^rawptr, pResource: ^rawptr, pDesc: ^D3D10_RENDER_TARGET_VIEW_DESC, ppRTView: ^^rawptr) -> win32.HRESULT,
	CreateDepthStencilView: #type proc "stdcall" (This: ^rawptr, pResource: ^rawptr, pDesc: ^D3D10_DEPTH_STENCIL_VIEW_DESC, ppDepthStencilView: ^^rawptr) -> win32.HRESULT,
	CreateInputLayout: #type proc "stdcall" (This: ^rawptr, pInputElementDescs: ^D3D10_INPUT_ELEMENT_DESC, NumElements: win32.UINT, pShaderBytecodeWithInputSignature: rawptr, BytecodeLength: win32.SIZE_T, ppInputLayout: ^^rawptr) -> win32.HRESULT,
	CreateVertexShader: #type proc "stdcall" (This: ^rawptr, pShaderBytecode: rawptr, BytecodeLength: win32.SIZE_T, ppVertexShader: ^^rawptr) -> win32.HRESULT,
	CreateGeometryShader: #type proc "stdcall" (This: ^rawptr, pShaderBytecode: rawptr, BytecodeLength: win32.SIZE_T, ppGeometryShader: ^^rawptr) -> win32.HRESULT,
	CreateGeometryShaderWithStreamOutput: #type proc "stdcall" (This: ^rawptr, pShaderBytecode: rawptr, BytecodeLength: win32.SIZE_T, pSODeclaration: ^D3D10_SO_DECLARATION_ENTRY, NumEntries: win32.UINT, OutputStreamStride: win32.UINT, ppGeometryShader: ^^rawptr) -> win32.HRESULT,
	CreatePixelShader: #type proc "stdcall" (This: ^rawptr, pShaderBytecode: rawptr, BytecodeLength: win32.SIZE_T, ppPixelShader: ^^rawptr) -> win32.HRESULT,
	CreateBlendState: #type proc "stdcall" (This: ^rawptr, pBlendStateDesc: ^D3D10_BLEND_DESC, ppBlendState: ^^rawptr) -> win32.HRESULT,
	CreateDepthStencilState: #type proc "stdcall" (This: ^rawptr, pDepthStencilDesc: ^D3D10_DEPTH_STENCIL_DESC, ppDepthStencilState: ^^rawptr) -> win32.HRESULT,
	CreateRasterizerState: #type proc "stdcall" (This: ^rawptr, pRasterizerDesc: ^D3D10_RASTERIZER_DESC, ppRasterizerState: ^^rawptr) -> win32.HRESULT,
	CreateSamplerState: #type proc "stdcall" (This: ^rawptr, pSamplerDesc: ^D3D10_SAMPLER_DESC, ppSamplerState: ^^rawptr) -> win32.HRESULT,
	CreateQuery: #type proc "stdcall" (This: ^rawptr, pQueryDesc: ^D3D10_QUERY_DESC, ppQuery: ^^rawptr) -> win32.HRESULT,
	CreatePredicate: #type proc "stdcall" (This: ^rawptr, pPredicateDesc: ^D3D10_QUERY_DESC, ppPredicate: ^^rawptr) -> win32.HRESULT,
	CreateCounter: #type proc "stdcall" (This: ^rawptr, pCounterDesc: ^D3D10_COUNTER_DESC, ppCounter: ^^rawptr) -> win32.HRESULT,
	CheckFormatSupport: #type proc "stdcall" (This: ^rawptr, Format: dxgi.FORMAT, pFormatSupport: ^win32.UINT) -> win32.HRESULT,
	CheckMultisampleQualityLevels: #type proc "stdcall" (This: ^rawptr, Format: dxgi.FORMAT, SampleCount: win32.UINT, pNumQualityLevels: ^win32.UINT) -> win32.HRESULT,
	CheckCounterInfo: #type proc "stdcall" (This: ^rawptr, pCounterInfo: ^D3D10_COUNTER_INFO),
	CheckCounter: #type proc "stdcall" (This: ^rawptr, pDesc: ^D3D10_COUNTER_DESC, pType: ^D3D10_COUNTER_TYPE, pActiveCounters: ^win32.UINT, szName: win32.LPSTR, pNameLength: ^win32.UINT, szUnits: win32.LPSTR, pUnitsLength: ^win32.UINT, szDescription: win32.LPSTR, pDescriptionLength: ^win32.UINT) -> win32.HRESULT,
	GetCreationFlags: #type proc "stdcall" (This: ^rawptr) -> win32.UINT,
	OpenSharedResource: #type proc "stdcall" (This: ^rawptr, hResource: win32.HANDLE, ReturnedInterface: ^win32.IID, ppResource: ^rawptr) -> win32.HRESULT,
	SetTextFilterSize: #type proc "stdcall" (This: ^rawptr, Width: win32.UINT, Height: win32.UINT),
	GetTextFilterSize: #type proc "stdcall" (This: ^rawptr, pWidth: ^win32.UINT, pHeight: ^win32.UINT),
}
ID3D10MultithreadVtbl :: struct{
	QueryInterface: #type proc "stdcall" (This: ^rawptr, riid: ^win32.IID, ppvObject: ^rawptr) -> win32.HRESULT,
	AddRef: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Release: #type proc "stdcall" (This: ^rawptr) -> win32.ULONG,
	Enter: #type proc "stdcall" (This: ^rawptr),
	Leave: #type proc "stdcall" (This: ^rawptr),
	SetMultithreadProtected: #type proc "stdcall" (This: ^rawptr, bMTProtect: win32.BOOL) -> win32.BOOL,
	GetMultithreadProtected: #type proc "stdcall" (This: ^rawptr) -> win32.BOOL,
}
D3D10_CREATE_DEVICE_FLAG :: enum{
	D3D10_CREATE_DEVICE_SINGLETHREADED = 0x1,
	D3D10_CREATE_DEVICE_DEBUG = 0x2,
	D3D10_CREATE_DEVICE_SWITCH_TO_REF = 0x4,
	D3D10_CREATE_DEVICE_PREVENT_INTERNAL_THREADING_OPTIMIZATIONS = 0x8,
	D3D10_CREATE_DEVICE_ALLOW_NULL_FROM_MAP = 0x10,
	D3D10_CREATE_DEVICE_BGRA_SUPPORT = 0x20,
	D3D10_CREATE_DEVICE_PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY = 0x80,
	D3D10_CREATE_DEVICE_STRICT_VALIDATION = 0x200,
	D3D10_CREATE_DEVICE_DEBUGGABLE = 0x400
}

