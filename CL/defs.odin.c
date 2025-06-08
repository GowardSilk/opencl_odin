#if defined(_WIN32)
@d3d10_types@ // bind all d3d10 required types (since they cannot be pipelined from odin)
@win_imports@ // d3d11 & other win32 related headers
#endif
