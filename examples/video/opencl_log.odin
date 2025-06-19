package video;

import "core:mem"
import "core:log"
import "core:fmt"
import "core:strings"

import cl "shared:opencl"

cl_context_errlog :: #force_inline proc(c: ^OpenCL_Context, $msg: string, ret: cl.Int, loc := #caller_location) {
    log_str := cl_context_log(c, loc);
    log.errorf("%s Error value: %d (aka %s)\n%s\n", msg, ret, err_to_name(ret), log_str, location=loc);
    delete(log_str);
}
/** @brief logs the current context state */
cl_context_log :: proc(c: ^OpenCL_Context, loc := #caller_location) -> string {
    cl_context_log_platform :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        log_sz: uint;
        log_msg: []byte;

        platform_fields := [?]cl.Platform_Info {
            cl.PLATFORM_PROFILE,
            cl.PLATFORM_VERSION,
            cl.PLATFORM_NAME,
            cl.PLATFORM_VENDOR,
        };

        field_names := [?]string {
            "Profile",
            "Version",
            "Name",
            "Vendor",
        };
        assert(len(field_names) == len(platform_fields))

        strings.write_string(b, "\tPlatform:\n");

        for i in 0..<len(platform_fields) {
            cl.GetPlatformInfo(c^.platform, platform_fields[i], 0, nil, &log_sz);
            if log_sz != 0 {
                log_msg = make([]byte, log_sz);
                defer delete(log_msg);
                cl.GetPlatformInfo(c^.platform, platform_fields[i], log_sz, &log_msg[0], nil);
                fmt.sbprintfln(b, "\t\t%s: %s", field_names[i], cast(string)log_msg);
                log_sz = 0;
            }
        }

        // extensions
        count: uint;
        if ret := cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS_WITH_VERSION, 0, nil, &count); ret == cl.SUCCESS {
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS_WITH_VERSION, 0, nil, &count);
            exts := make([]cl.Name_Version, count);
            defer delete(exts);
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS_WITH_VERSION, count, &exts[0], nil);
            fmt.sbprintln(b, "\t\tExtensions:");
            for &ext in exts do fmt.sbprintfln(b, "\t\t\t%s: %d", cast(cstring)cast(^byte)&ext.name[0], ext.version);
        } else {
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS, 0, nil, &log_sz);
            log_msg := make([]byte, log_sz);
            defer delete(log_msg);
            cl.GetPlatformInfo(c^.platform, cl.PLATFORM_EXTENSIONS, log_sz, &log_msg[0], nil);
            fmt.sbprintln(b, "\t\tExtensions:");
            exts, err := strings.split(cast(string)log_msg, " ");
            defer delete(exts);
            assert(err == .None);
            for ext in exts do fmt.sbprintfln(b, "\t\t\t%s", ext);
        }
    }

    cl_context_log_device :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        strings.write_string(b, "\tDevice:\n");

        log_str :: proc(c: ^OpenCL_Context, info: cl.Device_Info, label: string, b: ^strings.Builder) {
            log_sz: uint;
            cl.GetDeviceInfo(c^.device, info, 0, nil, &log_sz);
            if log_sz > 0 {
                data := make([]byte, log_sz);
                defer delete(data);
                cl.GetDeviceInfo(c^.device, info, log_sz, &data[0], nil);
                fmt.sbprintfln(b, "\t\t%s: %s", label, cast(string)data);
            }
        }

        log_uint :: proc(c: ^OpenCL_Context, info: cl.Device_Info, label: string, b: ^strings.Builder) {
            val: uint;
            if cl.GetDeviceInfo(c^.device, info, size_of(val), &val, nil) == cl.SUCCESS {
                fmt.sbprintfln(b, "\t\t%s: %d", label, val);
            }
        }

        log_ulong :: proc(c: ^OpenCL_Context, info: cl.Device_Info, label: string, b: ^strings.Builder, use_units := true) {
            val: u64;
            if cl.GetDeviceInfo(c^.device, info, size_of(val), &val, nil) == cl.SUCCESS {
                if !use_units do fmt.sbprintfln(b, "\t\t%s: %d B", label, val);
                else do fmt.sbprintfln(b, "\t\t%s: %f MB", label, cast(f32)val/1_000_000);
            }
        }

        log_str(c, cl.DEVICE_NAME, "Name", b);
        log_str(c, cl.DEVICE_VENDOR, "Vendor", b);
        log_str(c, cl.DRIVER_VERSION, "Driver Version", b);
        log_str(c, cl.DEVICE_VERSION, "Device Version", b);
        // todo: WHY IS NOT THIS PRESENT in `cl` ?
        // log_str(c, cl.DEVICE_OPENCL_C_VERSION, "OpenCL C Version", b);

        log_uint(c, cl.DEVICE_MAX_COMPUTE_UNITS, "Max Compute Units", b);
        log_ulong(c, cl.DEVICE_GLOBAL_MEM_SIZE, "Global Memory Size", b);
        log_ulong(c, cl.DEVICE_LOCAL_MEM_SIZE, "Local Memory Size", b, false);
        log_ulong(c, cl.DEVICE_MAX_MEM_ALLOC_SIZE, "Max Allocation Size", b);
    }

    cl_context_log_context :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        ref_count: cl.Uint;
        strings.write_string(b, "\tContext:\n");
        if cl.GetContextInfo(c^._context, cl.CONTEXT_REFERENCE_COUNT, size_of(ref_count), &ref_count, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tReference Count: %d", ref_count);
        }
    }

    cl_context_log_program :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        log_sz: uint;
        strings.write_string(b, "\tProgram:\n");
        if cl.GetProgramBuildInfo(c^.program, c^.device, cl.PROGRAM_BUILD_LOG, 0, nil, &log_sz) == cl.SUCCESS && log_sz > 1 {
            log := make([]byte, log_sz);
            defer delete(log);
            cl.GetProgramBuildInfo(c^.program, c^.device, cl.PROGRAM_BUILD_LOG, log_sz, &log[0], nil);
            strings.write_string(b, "\t\tProgram Build Log:\n");
            fmt.sbprintfln(b, "\t\t%s", cast(string)log);
        }

        ref_count: cl.Uint;
        if cl.GetProgramInfo(c^.program, cl.PROGRAM_REFERENCE_COUNT, size_of(ref_count), &ref_count, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tReference Count: %d", ref_count);
        }
    }

    cl_context_log_queue :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        ref_count: cl.Uint;
        strings.write_string(b, "\tCommand Queue:\n");
        if cl.GetCommandQueueInfo(c^.queue, cl.QUEUE_REFERENCE_COUNT, size_of(ref_count), &ref_count, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tReference Count: %d", ref_count);
        }

        dev: cl.Device_Id;
        if cl.GetCommandQueueInfo(c^.queue, cl.QUEUE_DEVICE, size_of(dev), &dev, nil) == cl.SUCCESS {
            if dev == c^.device {
                fmt.sbprintln(b, "\t\tAssociated with primary device.");
            }
        }

        props: cl.Command_Queue_Properties;
        if cl.GetCommandQueueInfo(c^.queue, cl.QUEUE_PROPERTIES, size_of(props), &props, nil) == cl.SUCCESS {
            fmt.sbprintfln(b, "\t\tProperties: 0x%x", props);
        }
    }

    cl_context_log_buffers :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        strings.write_string(b, "\tBuffers:\n");
        for buffer in c^.buffers {
            size: uint;
            if cl.GetMemObjectInfo(buffer, cl.MEM_SIZE, size_of(size), &size, nil) == cl.SUCCESS {
                flags: cl.Mem_Flags;
                cl.GetMemObjectInfo(buffer, cl.MEM_FLAGS, size_of(flags), &flags, nil);
                fmt.sbprintfln(b, "\t\t- Size: %d B, Flags: 0x%x", size, flags);
            }
        }
    }

    cl_context_log_kernels :: proc(c: ^OpenCL_Context, b: ^strings.Builder) {
        strings.write_string(b, "\tKernels:\n");
        for kernel in c^.kernels {
            log_sz: uint;
            if ret := cl.GetKernelInfo(kernel, cl.KERNEL_FUNCTION_NAME, 0, nil, &log_sz); ret == cl.SUCCESS {
                name := make([]byte, log_sz);
                defer delete(name);
                cl.GetKernelInfo(kernel, cl.KERNEL_FUNCTION_NAME, log_sz, &name[0], nil);
                fmt.sbprintfln(b, "\t  - %s", cast(string)name);
            }
        }
    }

    builder: strings.Builder;
    strings.builder_init(&builder);

    strings.write_string(&builder, "\n========== OpenCL Context [GPU] ==========\n");

    if c^.platform != nil     do cl_context_log_platform(c, &builder);
    if c^.device != nil       do cl_context_log_device(c, &builder);
    if c^._context != nil     do cl_context_log_context(c, &builder);
    if c^.program != nil      do cl_context_log_program(c, &builder);
    if c^.queue != nil        do cl_context_log_queue(c, &builder);
    if len(c^.buffers) != 0   do cl_context_log_buffers(c, &builder);
    /* TODO: some way to determine kernel validity here ? */
    cl_context_log_kernels(c, &builder);

    return strings.to_string(builder);
}
