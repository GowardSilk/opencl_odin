package cl;

import "core:c"
import "vendor:directx/d3d11"
import "vendor:directx/dxgi"
import win32 "core:sys/windows"

foreign import opencl "OpenCL.lib"

/* =========================================
*               cl.h
* ========================================= */

NAME_VERSION_MAX_NAME_SIZE :: 64
SUCCESS :: 0
DEVICE_NOT_FOUND :: -1
DEVICE_NOT_AVAILABLE :: -2
COMPILER_NOT_AVAILABLE :: -3
MEM_OBJECT_ALLOCATION_FAILURE :: -4
OUT_OF_RESOURCES :: -5
OUT_OF_HOST_MEMORY :: -6
PROFILING_INFO_NOT_AVAILABLE :: -7
MEM_COPY_OVERLAP :: -8
IMAGE_FORMAT_MISMATCH :: -9
IMAGE_FORMAT_NOT_SUPPORTED :: -10
BUILD_PROGRAM_FAILURE :: -11
MAP_FAILURE :: -12
MISALIGNED_SUB_BUFFER_OFFSET :: -13
EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST :: -14
COMPILE_PROGRAM_FAILURE :: -15
LINKER_NOT_AVAILABLE :: -16
LINK_PROGRAM_FAILURE :: -17
DEVICE_PARTITION_FAILED :: -18
KERNEL_ARG_INFO_NOT_AVAILABLE :: -19
INVALID_VALUE :: -30
INVALID_DEVICE_TYPE :: -31
INVALID_PLATFORM :: -32
INVALID_DEVICE :: -33
INVALID_CONTEXT :: -34
INVALID_QUEUE_PROPERTIES :: -35
INVALID_COMMAND_QUEUE :: -36
INVALID_HOST_PTR :: -37
INVALID_MEM_OBJECT :: -38
INVALID_IMAGE_FORMAT_DESCRIPTOR :: -39
INVALID_IMAGE_SIZE :: -40
INVALID_SAMPLER :: -41
INVALID_BINARY :: -42
INVALID_BUILD_OPTIONS :: -43
INVALID_PROGRAM :: -44
INVALID_PROGRAM_EXECUTABLE :: -45
INVALID_KERNEL_NAME :: -46
INVALID_KERNEL_DEFINITION :: -47
INVALID_KERNEL :: -48
INVALID_ARG_INDEX :: -49
INVALID_ARG_VALUE :: -50
INVALID_ARG_SIZE :: -51
INVALID_KERNEL_ARGS :: -52
INVALID_WORK_DIMENSION :: -53
INVALID_WORK_GROUP_SIZE :: -54
INVALID_WORK_ITEM_SIZE :: -55
INVALID_GLOBAL_OFFSET :: -56
INVALID_EVENT_WAIT_LIST :: -57
INVALID_EVENT :: -58
INVALID_OPERATION :: -59
INVALID_GL_OBJECT :: -60
INVALID_BUFFER_SIZE :: -61
INVALID_MIP_LEVEL :: -62
INVALID_GLOBAL_WORK_SIZE :: -63
INVALID_PROPERTY :: -64
INVALID_IMAGE_DESCRIPTOR :: -65
INVALID_COMPILER_OPTIONS :: -66
INVALID_LINKER_OPTIONS :: -67
INVALID_DEVICE_PARTITION_COUNT :: -68
INVALID_PIPE_SIZE :: -69
INVALID_DEVICE_QUEUE :: -70
INVALID_SPEC_ID :: -71
MAX_SIZE_RESTRICTION_EXCEEDED :: -72
FALSE :: 0
TRUE :: 1
BLOCKING :: TRUE
NON_BLOCKING :: FALSE
PLATFORM_PROFILE :: 0x0900
PLATFORM_VERSION :: 0x0901
PLATFORM_NAME :: 0x0902
PLATFORM_VENDOR :: 0x0903
PLATFORM_EXTENSIONS :: 0x0904
PLATFORM_HOST_TIMER_RESOLUTION :: 0x0905
PLATFORM_NUMERIC_VERSION :: 0x0906
PLATFORM_EXTENSIONS_WITH_VERSION :: 0x0907
DEVICE_TYPE_DEFAULT :: (1 << 0)
DEVICE_TYPE_CPU :: (1 << 1)
DEVICE_TYPE_GPU :: (1 << 2)
DEVICE_TYPE_ACCELERATOR :: (1 << 3)
DEVICE_TYPE_CUSTOM :: (1 << 4)
DEVICE_TYPE_ALL :: 0xFFFFFFFF
DEVICE_TYPE :: 0x1000
DEVICE_VENDOR_ID :: 0x1001
DEVICE_MAX_COMPUTE_UNITS :: 0x1002
DEVICE_MAX_WORK_ITEM_DIMENSIONS :: 0x1003
DEVICE_MAX_WORK_GROUP_SIZE :: 0x1004
DEVICE_MAX_WORK_ITEM_SIZES :: 0x1005
DEVICE_PREFERRED_VECTOR_WIDTH_CHAR :: 0x1006
DEVICE_PREFERRED_VECTOR_WIDTH_SHORT :: 0x1007
DEVICE_PREFERRED_VECTOR_WIDTH_INT :: 0x1008
DEVICE_PREFERRED_VECTOR_WIDTH_LONG :: 0x1009
DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT :: 0x100A
DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE :: 0x100B
DEVICE_MAX_CLOCK_FREQUENCY :: 0x100C
DEVICE_ADDRESS_BITS :: 0x100D
DEVICE_MAX_READ_IMAGE_ARGS :: 0x100E
DEVICE_MAX_WRITE_IMAGE_ARGS :: 0x100F
DEVICE_MAX_MEM_ALLOC_SIZE :: 0x1010
DEVICE_IMAGE2D_MAX_WIDTH :: 0x1011
DEVICE_IMAGE2D_MAX_HEIGHT :: 0x1012
DEVICE_IMAGE3D_MAX_WIDTH :: 0x1013
DEVICE_IMAGE3D_MAX_HEIGHT :: 0x1014
DEVICE_IMAGE3D_MAX_DEPTH :: 0x1015
DEVICE_IMAGE_SUPPORT :: 0x1016
DEVICE_MAX_PARAMETER_SIZE :: 0x1017
DEVICE_MAX_SAMPLERS :: 0x1018
DEVICE_MEM_BASE_ADDR_ALIGN :: 0x1019
DEVICE_MIN_DATA_TYPE_ALIGN_SIZE :: 0x101A
DEVICE_SINGLE_FP_CONFIG :: 0x101B
DEVICE_GLOBAL_MEM_CACHE_TYPE :: 0x101C
DEVICE_GLOBAL_MEM_CACHELINE_SIZE :: 0x101D
DEVICE_GLOBAL_MEM_CACHE_SIZE :: 0x101E
DEVICE_GLOBAL_MEM_SIZE :: 0x101F
DEVICE_MAX_CONSTANT_BUFFER_SIZE :: 0x1020
DEVICE_MAX_CONSTANT_ARGS :: 0x1021
DEVICE_LOCAL_MEM_TYPE :: 0x1022
DEVICE_LOCAL_MEM_SIZE :: 0x1023
DEVICE_ERROR_CORRECTION_SUPPORT :: 0x1024
DEVICE_PROFILING_TIMER_RESOLUTION :: 0x1025
DEVICE_ENDIAN_LITTLE :: 0x1026
DEVICE_AVAILABLE :: 0x1027
DEVICE_COMPILER_AVAILABLE :: 0x1028
DEVICE_EXECUTION_CAPABILITIES :: 0x1029
DEVICE_QUEUE_PROPERTIES :: 0x102A
DEVICE_QUEUE_ON_HOST_PROPERTIES :: 0x102A
DEVICE_NAME :: 0x102B
DEVICE_VENDOR :: 0x102C
DRIVER_VERSION :: 0x102D
DEVICE_PROFILE :: 0x102E
DEVICE_VERSION :: 0x102F
DEVICE_EXTENSIONS :: 0x1030
DEVICE_PLATFORM :: 0x1031
DEVICE_DOUBLE_FP_CONFIG :: 0x1032
DEVICE_PREFERRED_VECTOR_WIDTH_HALF :: 0x1034
DEVICE_HOST_UNIFIED_MEMORY :: 0x1035
DEVICE_NATIVE_VECTOR_WIDTH_CHAR :: 0x1036
DEVICE_NATIVE_VECTOR_WIDTH_SHORT :: 0x1037
DEVICE_NATIVE_VECTOR_WIDTH_INT :: 0x1038
DEVICE_NATIVE_VECTOR_WIDTH_LONG :: 0x1039
DEVICE_NATIVE_VECTOR_WIDTH_FLOAT :: 0x103A
DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE :: 0x103B
DEVICE_NATIVE_VECTOR_WIDTH_HALF :: 0x103C
DEVICE_OPENCL_C_VERSION :: 0x103D
DEVICE_LINKER_AVAILABLE :: 0x103E
DEVICE_BUILT_IN_KERNELS :: 0x103F
DEVICE_IMAGE_MAX_BUFFER_SIZE :: 0x1040
DEVICE_IMAGE_MAX_ARRAY_SIZE :: 0x1041
DEVICE_PARENT_DEVICE :: 0x1042
DEVICE_PARTITION_MAX_SUB_DEVICES :: 0x1043
DEVICE_PARTITION_PROPERTIES :: 0x1044
DEVICE_PARTITION_AFFINITY_DOMAIN :: 0x1045
DEVICE_PARTITION_TYPE :: 0x1046
DEVICE_REFERENCE_COUNT :: 0x1047
DEVICE_PREFERRED_INTEROP_USER_SYNC :: 0x1048
DEVICE_PRINTF_BUFFER_SIZE :: 0x1049
DEVICE_IMAGE_PITCH_ALIGNMENT :: 0x104A
DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT :: 0x104B
DEVICE_MAX_READ_WRITE_IMAGE_ARGS :: 0x104C
DEVICE_MAX_GLOBAL_VARIABLE_SIZE :: 0x104D
DEVICE_QUEUE_ON_DEVICE_PROPERTIES :: 0x104E
DEVICE_QUEUE_ON_DEVICE_PREFERRED_SIZE :: 0x104F
DEVICE_QUEUE_ON_DEVICE_MAX_SIZE :: 0x1050
DEVICE_MAX_ON_DEVICE_QUEUES :: 0x1051
DEVICE_MAX_ON_DEVICE_EVENTS :: 0x1052
DEVICE_SVM_CAPABILITIES :: 0x1053
DEVICE_GLOBAL_VARIABLE_PREFERRED_TOTAL_SIZE :: 0x1054
DEVICE_MAX_PIPE_ARGS :: 0x1055
DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS :: 0x1056
DEVICE_PIPE_MAX_PACKET_SIZE :: 0x1057
DEVICE_PREFERRED_PLATFORM_ATOMIC_ALIGNMENT :: 0x1058
DEVICE_PREFERRED_GLOBAL_ATOMIC_ALIGNMENT :: 0x1059
DEVICE_PREFERRED_LOCAL_ATOMIC_ALIGNMENT :: 0x105A
DEVICE_IL_VERSION :: 0x105B
DEVICE_MAX_NUM_SUB_GROUPS :: 0x105C
DEVICE_SUB_GROUP_INDEPENDENT_FORWARD_PROGRESS :: 0x105D
DEVICE_NUMERIC_VERSION :: 0x105E
DEVICE_EXTENSIONS_WITH_VERSION :: 0x1060
DEVICE_ILS_WITH_VERSION :: 0x1061
DEVICE_BUILT_IN_KERNELS_WITH_VERSION :: 0x1062
DEVICE_ATOMIC_MEMORY_CAPABILITIES :: 0x1063
DEVICE_ATOMIC_FENCE_CAPABILITIES :: 0x1064
DEVICE_NON_UNIFORM_WORK_GROUP_SUPPORT :: 0x1065
DEVICE_OPENCL_C_ALL_VERSIONS :: 0x1066
DEVICE_PREFERRED_WORK_GROUP_SIZE_MULTIPLE :: 0x1067
DEVICE_WORK_GROUP_COLLECTIVE_FUNCTIONS_SUPPORT :: 0x1068
DEVICE_GENERIC_ADDRESS_SPACE_SUPPORT :: 0x1069
DEVICE_OPENCL_C_FEATURES :: 0x106F
DEVICE_DEVICE_ENQUEUE_CAPABILITIES :: 0x1070
DEVICE_PIPE_SUPPORT :: 0x1071
DEVICE_LATEST_CONFORMANCE_VERSION_PASSED :: 0x1072
FP_DENORM :: (1 << 0)
FP_INF_NAN :: (1 << 1)
FP_ROUND_TO_NEAREST :: (1 << 2)
FP_ROUND_TO_ZERO :: (1 << 3)
FP_ROUND_TO_INF :: (1 << 4)
FP_FMA :: (1 << 5)
FP_SOFT_FLOAT :: (1 << 6)
FP_CORRECTLY_ROUNDED_DIVIDE_SQRT :: (1 << 7)
NONE :: 0x0
READ_ONLY_CACHE :: 0x1
READ_WRITE_CACHE :: 0x2
LOCAL :: 0x1
GLOBAL :: 0x2
EXEC_KERNEL :: (1 << 0)
EXEC_NATIVE_KERNEL :: (1 << 1)
QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE :: (1 << 0)
QUEUE_PROFILING_ENABLE :: (1 << 1)
QUEUE_ON_DEVICE :: (1 << 2)
QUEUE_ON_DEVICE_DEFAULT :: (1 << 3)
CONTEXT_REFERENCE_COUNT :: 0x1080
CONTEXT_DEVICES :: 0x1081
CONTEXT_PROPERTIES :: 0x1082
CONTEXT_NUM_DEVICES :: 0x1083
CONTEXT_PLATFORM :: 0x1084
CONTEXT_INTEROP_USER_SYNC :: 0x1085
DEVICE_PARTITION_EQUALLY :: 0x1086
DEVICE_PARTITION_BY_COUNTS :: 0x1087
DEVICE_PARTITION_BY_COUNTS_LIST_END :: 0x0
DEVICE_PARTITION_BY_AFFINITY_DOMAIN :: 0x1088
DEVICE_AFFINITY_DOMAIN_NUMA :: (1 << 0)
DEVICE_AFFINITY_DOMAIN_L4_CACHE :: (1 << 1)
DEVICE_AFFINITY_DOMAIN_L3_CACHE :: (1 << 2)
DEVICE_AFFINITY_DOMAIN_L2_CACHE :: (1 << 3)
DEVICE_AFFINITY_DOMAIN_L1_CACHE :: (1 << 4)
DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE :: (1 << 5)
DEVICE_SVM_COARSE_GRAIN_BUFFER :: (1 << 0)
DEVICE_SVM_FINE_GRAIN_BUFFER :: (1 << 1)
DEVICE_SVM_FINE_GRAIN_SYSTEM :: (1 << 2)
DEVICE_SVM_ATOMICS :: (1 << 3)
QUEUE_CONTEXT :: 0x1090
QUEUE_DEVICE :: 0x1091
QUEUE_REFERENCE_COUNT :: 0x1092
QUEUE_PROPERTIES :: 0x1093
QUEUE_SIZE :: 0x1094
QUEUE_DEVICE_DEFAULT :: 0x1095
QUEUE_PROPERTIES_ARRAY :: 0x1098
MEM_READ_WRITE :: (1 << 0)
MEM_WRITE_ONLY :: (1 << 1)
MEM_READ_ONLY :: (1 << 2)
MEM_USE_HOST_PTR :: (1 << 3)
MEM_ALLOC_HOST_PTR :: (1 << 4)
MEM_COPY_HOST_PTR :: (1 << 5)
MEM_HOST_WRITE_ONLY :: (1 << 7)
MEM_HOST_READ_ONLY :: (1 << 8)
MEM_HOST_NO_ACCESS :: (1 << 9)
MEM_SVM_FINE_GRAIN_BUFFER :: (1 << 10)
MEM_SVM_ATOMICS :: (1 << 11)
MEM_KERNEL_READ_AND_WRITE :: (1 << 12)
MIGRATE_MEM_OBJECT_HOST :: (1 << 0)
MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED :: (1 << 1)
R :: 0x10B0
A :: 0x10B1
RG :: 0x10B2
RA :: 0x10B3
RGB :: 0x10B4
RGBA :: 0x10B5
BGRA :: 0x10B6
ARGB :: 0x10B7
INTENSITY :: 0x10B8
LUMINANCE :: 0x10B9
Rx :: 0x10BA
R_Gx :: 0x10BB
R_G_Bx :: 0x10BC
DEPTH :: 0x10BD
S_R_G_B :: 0x10BF
S_R_G_Bx :: 0x10C0
S_R_G_B_A :: 0x10C1
S_B_G_R_A :: 0x10C2
ABGR :: 0x10C3
SNORM_INT8 :: 0x10D0
SNORM_INT16 :: 0x10D1
UNORM_INT8 :: 0x10D2
UNORM_INT16 :: 0x10D3
UNORM_SHORT_565 :: 0x10D4
UNORM_SHORT_555 :: 0x10D5
UNORM_INT_101010 :: 0x10D6
SIGNED_INT8 :: 0x10D7
SIGNED_INT16 :: 0x10D8
SIGNED_INT32 :: 0x10D9
UNSIGNED_INT8 :: 0x10DA
UNSIGNED_INT16 :: 0x10DB
UNSIGNED_INT32 :: 0x10DC
HALF_FLOAT :: 0x10DD
FLOAT :: 0x10DE
UNORM_INT_101010_2 :: 0x10E0
MEM_OBJECT_BUFFER :: 0x10F0
MEM_OBJECT_IMAGE2D :: 0x10F1
MEM_OBJECT_IMAGE3D :: 0x10F2
MEM_OBJECT_IMAGE2D_ARRAY :: 0x10F3
MEM_OBJECT_IMAGE1D :: 0x10F4
MEM_OBJECT_IMAGE1D_ARRAY :: 0x10F5
MEM_OBJECT_IMAGE1D_BUFFER :: 0x10F6
MEM_OBJECT_PIPE :: 0x10F7
MEM_TYPE :: 0x1100
MEM_FLAGS :: 0x1101
MEM_SIZE :: 0x1102
MEM_HOST_PTR :: 0x1103
MEM_MAP_COUNT :: 0x1104
MEM_REFERENCE_COUNT :: 0x1105
MEM_CONTEXT :: 0x1106
MEM_ASSOCIATED_MEMOBJECT :: 0x1107
MEM_OFFSET :: 0x1108
MEM_USES_SVM_POINTER :: 0x1109
MEM_PROPERTIES :: 0x110A
IMAGE_FORMAT :: 0x1110
IMAGE_ELEMENT_SIZE :: 0x1111
IMAGE_ROW_PITCH :: 0x1112
IMAGE_SLICE_PITCH :: 0x1113
IMAGE_WIDTH :: 0x1114
IMAGE_HEIGHT :: 0x1115
IMAGE_DEPTH :: 0x1116
IMAGE_ARRAY_SIZE :: 0x1117
IMAGE_BUFFER :: 0x1118
IMAGE_NUM_MIP_LEVELS :: 0x1119
IMAGE_NUM_SAMPLES :: 0x111A
PIPE_PACKET_SIZE :: 0x1120
PIPE_MAX_PACKETS :: 0x1121
PIPE_PROPERTIES :: 0x1122
ADDRESS_NONE :: 0x1130
ADDRESS_CLAMP_TO_EDGE :: 0x1131
ADDRESS_CLAMP :: 0x1132
ADDRESS_REPEAT :: 0x1133
ADDRESS_MIRRORED_REPEAT :: 0x1134
FILTER_NEAREST :: 0x1140
FILTER_LINEAR :: 0x1141
SAMPLER_REFERENCE_COUNT :: 0x1150
SAMPLER_CONTEXT :: 0x1151
SAMPLER_NORMALIZED_COORDS :: 0x1152
SAMPLER_ADDRESSING_MODE :: 0x1153
SAMPLER_FILTER_MODE :: 0x1154
SAMPLER_MIP_FILTER_MODE :: 0x1155
SAMPLER_LOD_MIN :: 0x1156
SAMPLER_LOD_MAX :: 0x1157
SAMPLER_PROPERTIES :: 0x1158
MAP_READ :: (1 << 0)
MAP_WRITE :: (1 << 1)
MAP_WRITE_INVALIDATE_REGION :: (1 << 2)
PROGRAM_REFERENCE_COUNT :: 0x1160
PROGRAM_CONTEXT :: 0x1161
PROGRAM_NUM_DEVICES :: 0x1162
PROGRAM_DEVICES :: 0x1163
PROGRAM_SOURCE :: 0x1164
PROGRAM_BINARY_SIZES :: 0x1165
PROGRAM_BINARIES :: 0x1166
PROGRAM_NUM_KERNELS :: 0x1167
PROGRAM_KERNEL_NAMES :: 0x1168
PROGRAM_IL :: 0x1169
PROGRAM_SCOPE_GLOBAL_CTORS_PRESENT :: 0x116A
PROGRAM_SCOPE_GLOBAL_DTORS_PRESENT :: 0x116B
PROGRAM_BUILD_STATUS :: 0x1181
PROGRAM_BUILD_OPTIONS :: 0x1182
PROGRAM_BUILD_LOG :: 0x1183
PROGRAM_BINARY_TYPE :: 0x1184
PROGRAM_BUILD_GLOBAL_VARIABLE_TOTAL_SIZE :: 0x1185
PROGRAM_BINARY_TYPE_NONE :: 0x0
PROGRAM_BINARY_TYPE_COMPILED_OBJECT :: 0x1
PROGRAM_BINARY_TYPE_LIBRARY :: 0x2
PROGRAM_BINARY_TYPE_EXECUTABLE :: 0x4
BUILD_SUCCESS :: 0
BUILD_NONE :: -1
BUILD_ERROR :: -2
BUILD_IN_PROGRESS :: -3
KERNEL_FUNCTION_NAME :: 0x1190
KERNEL_NUM_ARGS :: 0x1191
KERNEL_REFERENCE_COUNT :: 0x1192
KERNEL_CONTEXT :: 0x1193
KERNEL_PROGRAM :: 0x1194
KERNEL_ATTRIBUTES :: 0x1195
KERNEL_ARG_ADDRESS_QUALIFIER :: 0x1196
KERNEL_ARG_ACCESS_QUALIFIER :: 0x1197
KERNEL_ARG_TYPE_NAME :: 0x1198
KERNEL_ARG_TYPE_QUALIFIER :: 0x1199
KERNEL_ARG_NAME :: 0x119A
KERNEL_ARG_ADDRESS_GLOBAL :: 0x119B
KERNEL_ARG_ADDRESS_LOCAL :: 0x119C
KERNEL_ARG_ADDRESS_CONSTANT :: 0x119D
KERNEL_ARG_ADDRESS_PRIVATE :: 0x119E
KERNEL_ARG_ACCESS_READ_ONLY :: 0x11A0
KERNEL_ARG_ACCESS_WRITE_ONLY :: 0x11A1
KERNEL_ARG_ACCESS_READ_WRITE :: 0x11A2
KERNEL_ARG_ACCESS_NONE :: 0x11A3
KERNEL_ARG_TYPE_NONE :: 0
KERNEL_ARG_TYPE_CONST :: (1 << 0)
KERNEL_ARG_TYPE_RESTRICT :: (1 << 1)
KERNEL_ARG_TYPE_VOLATILE :: (1 << 2)
KERNEL_ARG_TYPE_PIPE :: (1 << 3)
KERNEL_WORK_GROUP_SIZE :: 0x11B0
KERNEL_COMPILE_WORK_GROUP_SIZE :: 0x11B1
KERNEL_LOCAL_MEM_SIZE :: 0x11B2
KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE :: 0x11B3
KERNEL_PRIVATE_MEM_SIZE :: 0x11B4
KERNEL_GLOBAL_WORK_SIZE :: 0x11B5
KERNEL_MAX_SUB_GROUP_SIZE_FOR_NDRANGE :: 0x2033
KERNEL_SUB_GROUP_COUNT_FOR_NDRANGE :: 0x2034
KERNEL_LOCAL_SIZE_FOR_SUB_GROUP_COUNT :: 0x11B8
KERNEL_MAX_NUM_SUB_GROUPS :: 0x11B9
KERNEL_COMPILE_NUM_SUB_GROUPS :: 0x11BA
KERNEL_EXEC_INFO_SVM_PTRS :: 0x11B6
KERNEL_EXEC_INFO_SVM_FINE_GRAIN_SYSTEM :: 0x11B7
EVENT_COMMAND_QUEUE :: 0x11D0
EVENT_COMMAND_TYPE :: 0x11D1
EVENT_REFERENCE_COUNT :: 0x11D2
EVENT_COMMAND_EXECUTION_STATUS :: 0x11D3
EVENT_CONTEXT :: 0x11D4
COMMAND_NDRANGE_KERNEL :: 0x11F0
COMMAND_TASK :: 0x11F1
COMMAND_NATIVE_KERNEL :: 0x11F2
COMMAND_READ_BUFFER :: 0x11F3
COMMAND_WRITE_BUFFER :: 0x11F4
COMMAND_COPY_BUFFER :: 0x11F5
COMMAND_READ_IMAGE :: 0x11F6
COMMAND_WRITE_IMAGE :: 0x11F7
COMMAND_COPY_IMAGE :: 0x11F8
COMMAND_COPY_IMAGE_TO_BUFFER :: 0x11F9
COMMAND_COPY_BUFFER_TO_IMAGE :: 0x11FA
COMMAND_MAP_BUFFER :: 0x11FB
COMMAND_MAP_IMAGE :: 0x11FC
COMMAND_UNMAP_MEM_OBJECT :: 0x11FD
COMMAND_MARKER :: 0x11FE
COMMAND_ACQUIRE_GL_OBJECTS :: 0x11FF
COMMAND_RELEASE_GL_OBJECTS :: 0x1200
COMMAND_READ_BUFFER_RECT :: 0x1201
COMMAND_WRITE_BUFFER_RECT :: 0x1202
COMMAND_COPY_BUFFER_RECT :: 0x1203
COMMAND_USER :: 0x1204
COMMAND_BARRIER :: 0x1205
COMMAND_MIGRATE_MEM_OBJECTS :: 0x1206
COMMAND_FILL_BUFFER :: 0x1207
COMMAND_FILL_IMAGE :: 0x1208
COMMAND_SVM_FREE :: 0x1209
COMMAND_SVM_MEMCPY :: 0x120A
COMMAND_SVM_MEMFILL :: 0x120B
COMMAND_SVM_MAP :: 0x120C
COMMAND_SVM_UNMAP :: 0x120D
COMMAND_SVM_MIGRATE_MEM :: 0x120E
COMPLETE :: 0x0
RUNNING :: 0x1
SUBMITTED :: 0x2
QUEUED :: 0x3
BUFFER_CREATE_TYPE_REGION :: 0x1220
PROFILING_COMMAND_QUEUED :: 0x1280
PROFILING_COMMAND_SUBMIT :: 0x1281
PROFILING_COMMAND_START :: 0x1282
PROFILING_COMMAND_END :: 0x1283
PROFILING_COMMAND_COMPLETE :: 0x1284
DEVICE_ATOMIC_ORDER_RELAXED :: (1 << 0)
DEVICE_ATOMIC_ORDER_ACQ_REL :: (1 << 1)
DEVICE_ATOMIC_ORDER_SEQ_CST :: (1 << 2)
DEVICE_ATOMIC_SCOPE_WORK_ITEM :: (1 << 3)
DEVICE_ATOMIC_SCOPE_WORK_GROUP :: (1 << 4)
DEVICE_ATOMIC_SCOPE_DEVICE :: (1 << 5)
DEVICE_ATOMIC_SCOPE_ALL_DEVICES :: (1 << 6)
DEVICE_QUEUE_SUPPORTED :: (1 << 0)
DEVICE_QUEUE_REPLACEABLE_DEFAULT :: (1 << 1)
KHRONOS_VENDOR_ID_CODEPLAY :: 0x10004
VERSION_MAJOR_BITS :: 10
VERSION_MINOR_BITS :: 10
VERSION_PATCH_BITS :: 12
VERSION_MAJOR_MASK :: ((1 << VERSION_MAJOR_BITS) - 1)
VERSION_MINOR_MASK :: ((1 << VERSION_MINOR_BITS) - 1)
VERSION_PATCH_MASK :: ((1 << VERSION_PATCH_BITS) - 1)
VERSION_MAJOR :: #force_inline proc(version: $A) -> c.int { return ((version) >> (VERSION_MINOR_BITS + VERSION_PATCH_BITS)); }
VERSION_MINOR :: #force_inline proc(version: $A) -> c.int { return (((version) >> VERSION_PATCH_BITS) & VERSION_MINOR_MASK); }
VERSION_PATCH :: #force_inline proc(version: $A) -> c.int { return ((version) & VERSION_PATCH_MASK); }
MAKE_VERSION :: #force_inline proc(major: $A, minor: $B, patch: $C) -> int { return ((((major) & VERSION_MAJOR_MASK) << (VERSION_MINOR_BITS + VERSION_PATCH_BITS)) | (((minor) & VERSION_MINOR_MASK) << VERSION_PATCH_BITS) | ((patch) & VERSION_PATCH_MASK)); }

Platform_ID :: distinct rawptr
Device_ID :: distinct rawptr
Context :: distinct rawptr
Command_Queue :: distinct rawptr
Mem :: distinct rawptr
Program :: distinct rawptr
Kernel :: distinct rawptr
Event :: distinct rawptr
Sampler :: distinct rawptr
Bool :: Uint
Bitfield :: Ulong
Properties :: Ulong
Device_Type :: Bitfield
Platform_Info :: Uint
Device_Info :: Uint
Device_Fp_Config :: Bitfield
Device_Mem_Cache_Type :: Uint
Device_Local_Mem_Type :: Uint
Device_Exec_Capabilities :: Bitfield
Device_SVM_Capabilities :: Bitfield
Command_Queue_Properties :: Bitfield
Device_Partition_Property :: c.intptr_t
Device_Affinity_Domain :: Bitfield
Context_Properties :: c.intptr_t
Context_Info :: Uint
Queue_Properties :: Properties
Command_Queue_Info :: Uint
Channel_Order :: Uint
Channel_Type :: Uint
Mem_Flags :: Bitfield
SVM_Mem_Flags :: Bitfield
Mem_Object_Type :: Uint
Mem_Info :: Uint
Mem_Migration_Flags :: Bitfield
Image_Info :: Uint
Buffer_Create_Type :: Uint
Addressing_Mode :: Uint
Filter_Mode :: Uint
Sampler_Info :: Uint
Map_Flags :: Bitfield
Pipe_Properties :: c.intptr_t
Pipe_Info :: Uint
Program_Info :: Uint
Program_Build_Info :: Uint
Program_Binary_Type :: Uint
Build_Status :: Int
Kernel_Info :: Uint
Kernel_Arg_Info :: Uint
Kernel_Arg_Address_Qualifier :: Uint
Kernel_Arg_Access_Qualifier :: Uint
Kernel_Arg_Type_Qualifier :: Bitfield
Kernel_Work_Group_Info :: Uint
Kernel_Sub_Group_Info :: Uint
Event_Info :: Uint
Command_Type :: Uint
Profiling_Info :: Uint
Sampler_Properties :: Properties
Kernel_Exec_Info :: Uint
Device_Atomic_Capabilities :: Bitfield
Device_Device_Enqueue_Capabilities :: Bitfield
Khronos_Vendor_ID :: Uint
Mem_Properties :: Properties
Version :: Uint
Image_Format :: struct{
	image_channel_order: Channel_Order,
	image_channel_data_type: Channel_Type,
}
Image_Desc :: struct{
	image_type: Mem_Object_Type,
	image_width: c.size_t,
	image_height: c.size_t,
	image_depth: c.size_t,
	image_array_size: c.size_t,
	image_row_pitch: c.size_t,
	image_slice_pitch: c.size_t,
	num_mip_levels: Uint,
	num_samples: Uint,
	using _: struct #raw_union {
		buffer: Mem,
		mem_object: Mem,
	},
}
Buffer_Region :: struct{
	origin: c.size_t,
	size: c.size_t,
}
Name_Version :: struct{
	version: Version,
	name: [64]c.schar,
}

@(link_prefix="cl")
foreign opencl {
	GetPlatformIDs :: proc  (num_entries: Uint, platforms: ^Platform_ID, num_platforms: ^Uint) -> Int ---
	GetPlatformInfo :: proc  (
                          platform: Platform_ID,
                          param_name: Platform_Info,
                          param_value_size: c.size_t,
                          param_value: rawptr,
                          param_value_size_ret: ^c.size_t) -> Int ---
	GetDeviceIDs :: proc  (
                       platform: Platform_ID,
                       device_type: Device_Type,
                       num_entries: Uint,
                       devices: ^Device_ID,
                       num_devices: ^Uint) -> Int ---
	GetDeviceInfo :: proc  (
                        device: Device_ID,
                        param_name: Device_Info,
                        param_value_size: c.size_t,
                        param_value: rawptr,
                        param_value_size_ret: ^c.size_t) -> Int ---
	CreateSubDevices :: proc  (
                           in_device: Device_ID,
                           properties: ^Device_Partition_Property,
                           num_devices: Uint,
                           out_devices: ^Device_ID,
                           num_devices_ret: ^Uint) -> Int ---
	RetainDevice :: proc  (device: Device_ID) -> Int ---
	ReleaseDevice :: proc  (device: Device_ID) -> Int ---
	SetDefaultDeviceCommandQueue :: proc  (
                                       _context: Context,
                                       device: Device_ID,
                                       command_queue: Command_Queue) -> Int ---
	GetDeviceAndHostTimer :: proc  (
                                device: Device_ID,
                                device_timestamp: ^Ulong,
                                host_timestamp: ^Ulong) -> Int ---
	GetHostTimer :: proc  (device: Device_ID, host_timestamp: ^Ulong) -> Int ---
	CreateContext :: proc  (
                        properties: ^Context_Properties,
                        num_devices: Uint,
                        devices: ^Device_ID,
                        pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr),
                        user_data: rawptr,
                        errcode_ret: ^Int) -> Context ---
	CreateContextFromType :: proc  (
                                properties: ^Context_Properties,
                                device_type: Device_Type,
                                pfn_notify: #type proc "stdcall" (errinfo: cstring, private_info: rawptr, cb: c.size_t, user_data: rawptr),
                                user_data: rawptr,
                                errcode_ret: ^Int) -> Context ---
	RetainContext :: proc  (_context: Context) -> Int ---
	ReleaseContext :: proc  (_context: Context) -> Int ---
	GetContextInfo :: proc  (
                         _context: Context,
                         param_name: Context_Info,
                         param_value_size: c.size_t,
                         param_value: rawptr,
                         param_value_size_ret: ^c.size_t) -> Int ---
	SetContextDestructorCallback :: proc  (
                                       _context: Context,
                                       pfn_notify: #type proc "stdcall" (_context: Context, user_data: rawptr),
                                       user_data: rawptr) -> Int ---
	CreateCommandQueueWithProperties :: proc  (
                                           _context: Context,
                                           device: Device_ID,
                                           properties: ^Queue_Properties,
                                           errcode_ret: ^Int) -> Command_Queue ---
	RetainCommandQueue :: proc  (command_queue: Command_Queue) -> Int ---
	ReleaseCommandQueue :: proc  (command_queue: Command_Queue) -> Int ---
	GetCommandQueueInfo :: proc  (
                              command_queue: Command_Queue,
                              param_name: Command_Queue_Info,
                              param_value_size: c.size_t,
                              param_value: rawptr,
                              param_value_size_ret: ^c.size_t) -> Int ---
	CreateBuffer :: proc  (
                       _context: Context,
                       flags: Mem_Flags,
                       size: c.size_t,
                       host_ptr: rawptr,
                       errcode_ret: ^Int) -> Mem ---
	CreateSubBuffer :: proc  (
                          buffer: Mem,
                          flags: Mem_Flags,
                          buffer_create_type: Buffer_Create_Type,
                          buffer_create_info: rawptr,
                          errcode_ret: ^Int) -> Mem ---
	CreateImage :: proc  (
                      _context: Context,
                      flags: Mem_Flags,
                      image_format: ^Image_Format,
                      image_desc: ^Image_Desc,
                      host_ptr: rawptr,
                      errcode_ret: ^Int) -> Mem ---
	CreatePipe :: proc  (
                     _context: Context,
                     flags: Mem_Flags,
                     pipe_packet_size: Uint,
                     pipe_max_packets: Uint,
                     properties: ^Pipe_Properties,
                     errcode_ret: ^Int) -> Mem ---
	CreateBufferWithProperties :: proc  (
                                     _context: Context,
                                     properties: ^Mem_Properties,
                                     flags: Mem_Flags,
                                     size: c.size_t,
                                     host_ptr: rawptr,
                                     errcode_ret: ^Int) -> Mem ---
	CreateImageWithProperties :: proc  (
                                    _context: Context,
                                    properties: ^Mem_Properties,
                                    flags: Mem_Flags,
                                    image_format: ^Image_Format,
                                    image_desc: ^Image_Desc,
                                    host_ptr: rawptr,
                                    errcode_ret: ^Int) -> Mem ---
	RetainMemObject :: proc  (memobj: Mem) -> Int ---
	ReleaseMemObject :: proc  (memobj: Mem) -> Int ---
	GetSupportedImageFormats :: proc  (
                                   _context: Context,
                                   flags: Mem_Flags,
                                   image_type: Mem_Object_Type,
                                   num_entries: Uint,
                                   image_formats: ^Image_Format,
                                   num_image_formats: ^Uint) -> Int ---
	GetMemObjectInfo :: proc  (
                           memobj: Mem,
                           param_name: Mem_Info,
                           param_value_size: c.size_t,
                           param_value: rawptr,
                           param_value_size_ret: ^c.size_t) -> Int ---
	GetImageInfo :: proc  (
                       image: Mem,
                       param_name: Image_Info,
                       param_value_size: c.size_t,
                       param_value: rawptr,
                       param_value_size_ret: ^c.size_t) -> Int ---
	GetPipeInfo :: proc  (
                      pipe: Mem,
                      param_name: Pipe_Info,
                      param_value_size: c.size_t,
                      param_value: rawptr,
                      param_value_size_ret: ^c.size_t) -> Int ---
	SetMemObjectDestructorCallback :: proc  (
                                         memobj: Mem,
                                         pfn_notify: #type proc "stdcall" (memobj: Mem, user_data: rawptr),
                                         user_data: rawptr) -> Int ---
	SVMAlloc :: proc  (
                   _context: Context,
                   flags: SVM_Mem_Flags,
                   size: c.size_t,
                   alignment: Uint) -> rawptr ---
	SVMFree :: proc  (_context: Context, svm_pointer: rawptr) ---
	CreateSamplerWithProperties :: proc  (
                                      _context: Context,
                                      sampler_properties: ^Sampler_Properties,
                                      errcode_ret: ^Int) -> Sampler ---
	RetainSampler :: proc  (sampler: Sampler) -> Int ---
	ReleaseSampler :: proc  (sampler: Sampler) -> Int ---
	GetSamplerInfo :: proc  (
                         sampler: Sampler,
                         param_name: Sampler_Info,
                         param_value_size: c.size_t,
                         param_value: rawptr,
                         param_value_size_ret: ^c.size_t) -> Int ---
	CreateProgramWithSource :: proc  (
                                  _context: Context,
                                  count: Uint,
                                  strings: ^cstring,
                                  lengths: ^c.size_t,
                                  errcode_ret: ^Int) -> Program ---
	CreateProgramWithBinary :: proc  (
                                  _context: Context,
                                  num_devices: Uint,
                                  device_list: ^Device_ID,
                                  lengths: ^c.size_t,
                                  binaries: ^^c.char,
                                  binary_status: ^Int,
                                  errcode_ret: ^Int) -> Program ---
	CreateProgramWithBuiltInKernels :: proc  (
                                          _context: Context,
                                          num_devices: Uint,
                                          device_list: ^Device_ID,
                                          kernel_names: cstring,
                                          errcode_ret: ^Int) -> Program ---
	CreateProgramWithIL :: proc  (
                              _context: Context,
                              il: rawptr,
                              length: c.size_t,
                              errcode_ret: ^Int) -> Program ---
	RetainProgram :: proc  (program: Program) -> Int ---
	ReleaseProgram :: proc  (program: Program) -> Int ---
	BuildProgram :: proc  (
                       program: Program,
                       num_devices: Uint,
                       device_list: ^Device_ID,
                       options: cstring,
                       pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
                       user_data: rawptr) -> Int ---
	CompileProgram :: proc  (
                         program: Program,
                         num_devices: Uint,
                         device_list: ^Device_ID,
                         options: cstring,
                         num_input_headers: Uint,
                         input_headers: ^Program,
                         header_include_names: ^cstring,
                         pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
                         user_data: rawptr) -> Int ---
	LinkProgram :: proc  (
                      _context: Context,
                      num_devices: Uint,
                      device_list: ^Device_ID,
                      options: cstring,
                      num_input_programs: Uint,
                      input_programs: ^Program,
                      pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
                      user_data: rawptr,
                      errcode_ret: ^Int) -> Program ---
	SetProgramReleaseCallback :: proc  (
                                    program: Program,
                                    pfn_notify: #type proc "stdcall" (program: Program, user_data: rawptr),
                                    user_data: rawptr) -> Int ---
	SetProgramSpecializationConstant :: proc  (
                                           program: Program,
                                           spec_id: Uint,
                                           spec_size: c.size_t,
                                           spec_value: rawptr) -> Int ---
	UnloadPlatformCompiler :: proc  (platform: Platform_ID) -> Int ---
	GetProgramInfo :: proc  (
                         program: Program,
                         param_name: Program_Info,
                         param_value_size: c.size_t,
                         param_value: rawptr,
                         param_value_size_ret: ^c.size_t) -> Int ---
	GetProgramBuildInfo :: proc  (
                              program: Program,
                              device: Device_ID,
                              param_name: Program_Build_Info,
                              param_value_size: c.size_t,
                              param_value: rawptr,
                              param_value_size_ret: ^c.size_t) -> Int ---
	CreateKernel :: proc  (program: Program, kernel_name: cstring, errcode_ret: ^Int) -> Kernel ---
	CreateKernelsInProgram :: proc  (
                                 program: Program,
                                 num_kernels: Uint,
                                 kernels: ^Kernel,
                                 num_kernels_ret: ^Uint) -> Int ---
	CloneKernel :: proc  (source_kernel: Kernel, errcode_ret: ^Int) -> Kernel ---
	RetainKernel :: proc  (kernel: Kernel) -> Int ---
	ReleaseKernel :: proc  (kernel: Kernel) -> Int ---
	SetKernelArg :: proc  (
                       kernel: Kernel,
                       arg_index: Uint,
                       arg_size: c.size_t,
                       arg_value: rawptr) -> Int ---
	SetKernelArgSVMPointer :: proc  (kernel: Kernel, arg_index: Uint, arg_value: rawptr) -> Int ---
	SetKernelExecInfo :: proc  (
                            kernel: Kernel,
                            param_name: Kernel_Exec_Info,
                            param_value_size: c.size_t,
                            param_value: rawptr) -> Int ---
	GetKernelInfo :: proc  (
                        kernel: Kernel,
                        param_name: Kernel_Info,
                        param_value_size: c.size_t,
                        param_value: rawptr,
                        param_value_size_ret: ^c.size_t) -> Int ---
	GetKernelArgInfo :: proc  (
                           kernel: Kernel,
                           arg_indx: Uint,
                           param_name: Kernel_Arg_Info,
                           param_value_size: c.size_t,
                           param_value: rawptr,
                           param_value_size_ret: ^c.size_t) -> Int ---
	GetKernelWorkGroupInfo :: proc  (
                                 kernel: Kernel,
                                 device: Device_ID,
                                 param_name: Kernel_Work_Group_Info,
                                 param_value_size: c.size_t,
                                 param_value: rawptr,
                                 param_value_size_ret: ^c.size_t) -> Int ---
	GetKernelSubGroupInfo :: proc  (
                                kernel: Kernel,
                                device: Device_ID,
                                param_name: Kernel_Sub_Group_Info,
                                input_value_size: c.size_t,
                                input_value: rawptr,
                                param_value_size: c.size_t,
                                param_value: rawptr,
                                param_value_size_ret: ^c.size_t) -> Int ---
	WaitForEvents :: proc  (num_events: Uint, event_list: ^Event) -> Int ---
	GetEventInfo :: proc  (
                       event: Event,
                       param_name: Event_Info,
                       param_value_size: c.size_t,
                       param_value: rawptr,
                       param_value_size_ret: ^c.size_t) -> Int ---
	CreateUserEvent :: proc  (_context: Context, errcode_ret: ^Int) -> Event ---
	RetainEvent :: proc  (event: Event) -> Int ---
	ReleaseEvent :: proc  (event: Event) -> Int ---
	SetUserEventStatus :: proc  (event: Event, execution_status: Int) -> Int ---
	SetEventCallback :: proc  (
                           event: Event,
                           command_exec_callback_type: Int,
                           pfn_notify: #type proc "stdcall" (event: Event, event_command_status: Int, user_data: rawptr),
                           user_data: rawptr) -> Int ---
	GetEventProfilingInfo :: proc  (
                                event: Event,
                                param_name: Profiling_Info,
                                param_value_size: c.size_t,
                                param_value: rawptr,
                                param_value_size_ret: ^c.size_t) -> Int ---
	Flush :: proc  (command_queue: Command_Queue) -> Int ---
	Finish :: proc  (command_queue: Command_Queue) -> Int ---
	EnqueueReadBuffer :: proc  (
                            command_queue: Command_Queue,
                            buffer: Mem,
                            blocking_read: Bool,
                            offset: c.size_t,
                            size: c.size_t,
                            ptr: rawptr,
                            num_events_in_wait_list: Uint,
                            event_wait_list: ^Event,
                            event: ^Event) -> Int ---
	EnqueueReadBufferRect :: proc  (
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
                                event: ^Event) -> Int ---
	EnqueueWriteBuffer :: proc  (
                             command_queue: Command_Queue,
                             buffer: Mem,
                             blocking_write: Bool,
                             offset: c.size_t,
                             size: c.size_t,
                             ptr: rawptr,
                             num_events_in_wait_list: Uint,
                             event_wait_list: ^Event,
                             event: ^Event) -> Int ---
	EnqueueWriteBufferRect :: proc  (
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
                                 event: ^Event) -> Int ---
	EnqueueFillBuffer :: proc  (
                            command_queue: Command_Queue,
                            buffer: Mem,
                            pattern: rawptr,
                            pattern_size: c.size_t,
                            offset: c.size_t,
                            size: c.size_t,
                            num_events_in_wait_list: Uint,
                            event_wait_list: ^Event,
                            event: ^Event) -> Int ---
	EnqueueCopyBuffer :: proc  (
                            command_queue: Command_Queue,
                            src_buffer: Mem,
                            dst_buffer: Mem,
                            src_offset: c.size_t,
                            dst_offset: c.size_t,
                            size: c.size_t,
                            num_events_in_wait_list: Uint,
                            event_wait_list: ^Event,
                            event: ^Event) -> Int ---
	EnqueueCopyBufferRect :: proc  (
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
                                event: ^Event) -> Int ---
	EnqueueReadImage :: proc  (
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
                           event: ^Event) -> Int ---
	EnqueueWriteImage :: proc  (
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
                            event: ^Event) -> Int ---
	EnqueueFillImage :: proc  (
                           command_queue: Command_Queue,
                           image: Mem,
                           fill_color: rawptr,
                           origin: ^c.size_t,
                           region: ^c.size_t,
                           num_events_in_wait_list: Uint,
                           event_wait_list: ^Event,
                           event: ^Event) -> Int ---
	EnqueueCopyImage :: proc  (
                           command_queue: Command_Queue,
                           src_image: Mem,
                           dst_image: Mem,
                           src_origin: ^c.size_t,
                           dst_origin: ^c.size_t,
                           region: ^c.size_t,
                           num_events_in_wait_list: Uint,
                           event_wait_list: ^Event,
                           event: ^Event) -> Int ---
	EnqueueCopyImageToBuffer :: proc  (
                                   command_queue: Command_Queue,
                                   src_image: Mem,
                                   dst_buffer: Mem,
                                   src_origin: ^c.size_t,
                                   region: ^c.size_t,
                                   dst_offset: c.size_t,
                                   num_events_in_wait_list: Uint,
                                   event_wait_list: ^Event,
                                   event: ^Event) -> Int ---
	EnqueueCopyBufferToImage :: proc  (
                                   command_queue: Command_Queue,
                                   src_buffer: Mem,
                                   dst_image: Mem,
                                   src_offset: c.size_t,
                                   dst_origin: ^c.size_t,
                                   region: ^c.size_t,
                                   num_events_in_wait_list: Uint,
                                   event_wait_list: ^Event,
                                   event: ^Event) -> Int ---
	EnqueueMapBuffer :: proc  (
                           command_queue: Command_Queue,
                           buffer: Mem,
                           blocking_map: Bool,
                           map_flags: Map_Flags,
                           offset: c.size_t,
                           size: c.size_t,
                           num_events_in_wait_list: Uint,
                           event_wait_list: ^Event,
                           event: ^Event,
                           errcode_ret: ^Int) -> rawptr ---
	EnqueueMapImage :: proc  (
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
                          errcode_ret: ^Int) -> rawptr ---
	EnqueueUnmapMemObject :: proc  (
                                command_queue: Command_Queue,
                                memobj: Mem,
                                mapped_ptr: rawptr,
                                num_events_in_wait_list: Uint,
                                event_wait_list: ^Event,
                                event: ^Event) -> Int ---
	EnqueueMigrateMemObjects :: proc  (
                                   command_queue: Command_Queue,
                                   num_mem_objects: Uint,
                                   mem_objects: ^Mem,
                                   flags: Mem_Migration_Flags,
                                   num_events_in_wait_list: Uint,
                                   event_wait_list: ^Event,
                                   event: ^Event) -> Int ---
	EnqueueNDRangeKernel :: proc  (
                               command_queue: Command_Queue,
                               kernel: Kernel,
                               work_dim: Uint,
                               global_work_offset: ^c.size_t,
                               global_work_size: ^c.size_t,
                               local_work_size: ^c.size_t,
                               num_events_in_wait_list: Uint,
                               event_wait_list: ^Event,
                               event: ^Event) -> Int ---
	EnqueueNativeKernel :: proc  (
                              command_queue: Command_Queue,
                              user_func: #type proc "stdcall" (_1: rawptr),
                              args: rawptr,
                              cb_args: c.size_t,
                              num_mem_objects: Uint,
                              mem_list: ^Mem,
                              args_mem_loc: ^rawptr,
                              num_events_in_wait_list: Uint,
                              event_wait_list: ^Event,
                              event: ^Event) -> Int ---
	EnqueueMarkerWithWaitList :: proc  (
                                    command_queue: Command_Queue,
                                    num_events_in_wait_list: Uint,
                                    event_wait_list: ^Event,
                                    event: ^Event) -> Int ---
	EnqueueBarrierWithWaitList :: proc  (
                                     command_queue: Command_Queue,
                                     num_events_in_wait_list: Uint,
                                     event_wait_list: ^Event,
                                     event: ^Event) -> Int ---
	EnqueueSVMFree :: proc  (
                         command_queue: Command_Queue,
                         num_svm_pointers: Uint,
                         svm_pointers: []rawptr,
                         pfn_free_func: #type proc "stdcall" (queue: Command_Queue, num_svm_pointers: Uint, svm_pointers: []rawptr, user_data: rawptr),
                         user_data: rawptr,
                         num_events_in_wait_list: Uint,
                         event_wait_list: ^Event,
                         event: ^Event) -> Int ---
	EnqueueSVMMemcpy :: proc  (
                           command_queue: Command_Queue,
                           blocking_copy: Bool,
                           dst_ptr: rawptr,
                           src_ptr: rawptr,
                           size: c.size_t,
                           num_events_in_wait_list: Uint,
                           event_wait_list: ^Event,
                           event: ^Event) -> Int ---
	EnqueueSVMMemFill :: proc  (
                            command_queue: Command_Queue,
                            svm_ptr: rawptr,
                            pattern: rawptr,
                            pattern_size: c.size_t,
                            size: c.size_t,
                            num_events_in_wait_list: Uint,
                            event_wait_list: ^Event,
                            event: ^Event) -> Int ---
	EnqueueSVMMap :: proc  (
                        command_queue: Command_Queue,
                        blocking_map: Bool,
                        flags: Map_Flags,
                        svm_ptr: rawptr,
                        size: c.size_t,
                        num_events_in_wait_list: Uint,
                        event_wait_list: ^Event,
                        event: ^Event) -> Int ---
	EnqueueSVMUnmap :: proc  (
                          command_queue: Command_Queue,
                          svm_ptr: rawptr,
                          num_events_in_wait_list: Uint,
                          event_wait_list: ^Event,
                          event: ^Event) -> Int ---
	EnqueueSVMMigrateMem :: proc  (
                               command_queue: Command_Queue,
                               num_svm_pointers: Uint,
                               svm_pointers: ^rawptr,
                               sizes: ^c.size_t,
                               flags: Mem_Migration_Flags,
                               num_events_in_wait_list: Uint,
                               event_wait_list: ^Event,
                               event: ^Event) -> Int ---
	GetExtensionFunctionAddressForPlatform :: proc  (
                                                 platform: Platform_ID,
                                                 func_name: cstring) -> rawptr ---
	CreateImage2D :: proc  (
                        _context: Context,
                        flags: Mem_Flags,
                        image_format: ^Image_Format,
                        image_width: c.size_t,
                        image_height: c.size_t,
                        image_row_pitch: c.size_t,
                        host_ptr: rawptr,
                        errcode_ret: ^Int) -> Mem ---
	CreateImage3D :: proc  (
                        _context: Context,
                        flags: Mem_Flags,
                        image_format: ^Image_Format,
                        image_width: c.size_t,
                        image_height: c.size_t,
                        image_depth: c.size_t,
                        image_row_pitch: c.size_t,
                        image_slice_pitch: c.size_t,
                        host_ptr: rawptr,
                        errcode_ret: ^Int) -> Mem ---
	EnqueueMarker :: proc  (command_queue: Command_Queue, event: ^Event) -> Int ---
	EnqueueWaitForEvents :: proc  (
                               command_queue: Command_Queue,
                               num_events: Uint,
                               event_list: ^Event) -> Int ---
	EnqueueBarrier :: proc  (command_queue: Command_Queue) -> Int ---
	UnloadCompiler :: proc  () -> Int ---
	GetExtensionFunctionAddress :: proc  (func_name: cstring) -> rawptr ---
	CreateCommandQueue :: proc  (
                             _context: Context,
                             device: Device_ID,
                             properties: Command_Queue_Properties,
                             errcode_ret: ^Int) -> Command_Queue ---
	CreateSampler :: proc  (
                        _context: Context,
                        normalized_coords: Bool,
                        addressing_mode: Addressing_Mode,
                        filter_mode: Filter_Mode,
                        errcode_ret: ^Int) -> Sampler ---
	EnqueueTask :: proc  (
                      command_queue: Command_Queue,
                      kernel: Kernel,
                      num_events_in_wait_list: Uint,
                      event_wait_list: ^Event,
                      event: ^Event) -> Int ---
}
