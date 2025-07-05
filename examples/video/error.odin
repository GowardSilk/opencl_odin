package video;

Error :: enum {
    None = 0,

    Platform_Query_Fail,
    No_OpenCL_Interop_Support,
    Device_Query_Fail,
    Context_Creation_Fail,

    Program_Allocation_Fail,
    Program_Compilation_Fail,

    Buffer_Allocation_Fail,
    Command_Queue_Allocation_Fail,
    Kernel_Creation_Fail,
}
