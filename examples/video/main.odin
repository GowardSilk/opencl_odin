package video;

import "base:runtime"

import "core:c"
import "core:log"
import "core:strings"
import win "core:sys/windows"

import cl "shared:opencl"

import "ui"

App_Context :: struct {
    c: OpenCL_Context,
    selected_image: string,
    options_window_opened: bool,
    backend: ui.Backend_Kind,
}

get_app_context :: proc() -> ^App_Context {
    return ui.get_data(App_Context);
}

/**
 * @brief tries to query platform that either supports khr_d3d11 or khr_gl (OpenGL favored)
 */
try_and_pick_backend :: proc() -> (cl.Platform_ID, cl.Device_ID, ui.Backend_Kind) {
    nof_platforms: cl.Uint;
    ret := cl.GetPlatformIDs(0, nil, &nof_platforms);
    assert(ret == cl.SUCCESS);

    platforms := make([]cl.Platform_ID, nof_platforms);
    defer delete(platforms);
    ret = cl.GetPlatformIDs(nof_platforms, raw_data(platforms), nil);
    assert(ret == cl.SUCCESS);

    // also need a similar loop for making sure that the device itself supports the same extension on that platform!
    scan_devices_for_selected_backend :: proc(platform: cl.Platform_ID, backend: ui.Backend_Kind) -> cl.Device_ID {
        nof_devices: cl.Uint;
        ret := cl.GetDeviceIDs(platform, cl.DEVICE_TYPE_GPU, 0, nil, &nof_devices);
        assert(ret == cl.SUCCESS);

        devices := make([]cl.Device_ID, nof_devices);
        ret  = cl.GetDeviceIDs(platform, cl.DEVICE_TYPE_GPU, nof_devices, raw_data(devices), nil);
        assert(ret == cl.SUCCESS);
        defer delete(devices);

        for device in devices {
            log_sz: c.size_t;
            cl.GetDeviceInfo(
                device,
                cl.DEVICE_EXTENSIONS,
                0, nil, &log_sz
            );
            log.assertf(ret == cl.SUCCESS && log_sz != 0, "Failed to query device info! Reason: %d; %s | %s", ret, err_to_name(ret));

            log_msg := make([]byte, log_sz);
            defer delete(log_msg);
            cl.GetDeviceInfo(device, cl.DEVICE_EXTENSIONS, log_sz, &log_msg[0], nil);

            exts := strings.split(cast(string)log_msg, " ");
            assert(exts != nil);
            defer delete(exts);

            for ext in exts {
                if len(ext) == len(cl.KHR_GL_SHARING_EXTENSION_NAME) && ext == cl.KHR_GL_SHARING_EXTENSION_NAME {
                    return device;
                } else if len(ext) == len(cl.KHR_D3D11_SHARING_EXTENSION_NAME) && ext == cl.KHR_D3D11_SHARING_EXTENSION_NAME {
                    return device;
                }
            }
        }

        return nil;
    }

    for platform in platforms {
        log_sz: c.size_t;
        ret := cl.GetPlatformInfo(
            platform,
            cl.PLATFORM_EXTENSIONS,
            0, nil, &log_sz
        );
        log.assertf(ret == cl.SUCCESS && log_sz != 0, "Failed to query platform info! Reason: %d; %s | %s", ret, err_to_name(ret));

        log_msg := make([]byte, log_sz);
        defer delete(log_msg);
        cl.GetPlatformInfo(platform, cl.PLATFORM_EXTENSIONS, log_sz, &log_msg[0], nil);

        exts := strings.split(cast(string)log_msg, " ");
        assert(exts != nil);
        defer delete(exts);

        for ext in exts {
            if len(ext) == len(cl.KHR_GL_SHARING_EXTENSION_NAME) && ext == cl.KHR_GL_SHARING_EXTENSION_NAME {
                device := scan_devices_for_selected_backend(platform, .GL);
                if device != nil do return platform, device, .GL;
            } else if len(ext) == len(cl.KHR_D3D11_SHARING_EXTENSION_NAME) && ext == cl.KHR_D3D11_SHARING_EXTENSION_NAME {
                device := scan_devices_for_selected_backend(platform, .D3D11);
                if device != nil do return platform, device, .D3D11;
            }
        }
    }

    assert(false, "Failed to find device supporting the required extensions");
    return nil, nil, .GL;
}

main :: proc() {
    context.logger = log.create_console_logger();

    app_context: App_Context;
    app_context.selected_image = "video/resources/images/lena_color_512.png";

    engine, _ := load_video("white.jpg");
    {
        request_frame(engine);
    }
    unload_video(engine);

    platform, device, backend := try_and_pick_backend();

    ok: runtime.Allocator_Error;
    context.user_ptr, ok = ui.init(backend, &app_context);
    assert(ok == .None && context.user_ptr != nil);
    defer ui.destroy();

    err := ui.register_window({1024, 1024}, "OpenCL Video", draw_main_screen);
    log.assertf(err == nil, "Failed to register window (\"OpenCL Video\"): %v", err);

    // cl.Context creation needs to happend AFTER OpenGL's Context is initialized
    // in case of D3D11, d3d11 device has to be present (and because of our UI abstract, the window already registered...)
    cerr: Error;
    switch backend {
        case .GL:
            context_properties := [?]cl.Context_Properties {
                cl.CONTEXT_PLATFORM, cast(cl.Context_Properties)cast(uintptr)platform,
                cl.GL_CONTEXT_KHR, cast(cl.Context_Properties)cast(uintptr)win.wglGetCurrentContext(),
                0
            };
            app_context.c, cerr = cl_context_init(platform, device, context_properties[:]);
            // load necessary KHR function pointers
            cl.LoadGLKHRFunctions(platform);
        case .D3D11:
            // TODO(GowardSilk): this is awful.... xD
            p := (cast(^ui.Draw_Context)context.user_ptr)^.ren.persistent;
            assert(p != nil);
            d3d11_device := p.device;
            context_properties := [?]cl.Context_Properties {
                cl.CONTEXT_PLATFORM, cast(cl.Context_Properties)cast(uintptr)platform,
                cl.CONTEXT_D3D11_DEVICE_KHR, cast(cl.Context_Properties)cast(uintptr)d3d11_device,
                cl.CONTEXT_INTEROP_USER_SYNC, cast(cl.Context_Properties)cl.FALSE,
                0
            };
            app_context.c, cerr = cl_context_init(platform, device, context_properties[:]);
            cl.LoadD3D11KHRFunctions(platform);
    }
    log.assertf(cerr == nil, "Fatal error: %v", cerr);
    app_context.backend = backend;
    defer cl_context_delete(&app_context.c);
    when ODIN_DEBUG {
        log_str := cl_context_log(&app_context.c);
        log.info(log_str);
        delete(log_str);
    }

    ui.draw();
}

draw_main_screen :: proc(w: ui.Window) {
    app_context := get_app_context();

    if w.signal == .Should_Close do return;

    Image_Descriptor :: struct { path, display_name: string };
    images :: [?]Image_Descriptor {
        { "video/resources/images/lena_color_512.png", "Lena" },
        { "video/resources/images/mandril_color.png",  "Mandril" },
        { "video/resources/images/peppers_color.png",  "Peppers" },
    };

    ui.set_font_size(40);
    ui.set_button_size({200, 50});
    for img in images {
        if ui.draw_button(img.display_name) do app_context^.selected_image = img.path;
    }

    if ui.draw_button("options") {
        if !app_context^.options_window_opened {
            if err := ui.register_window({512, 512}, "Image Settings", draw_options); err != nil {
                log.errorf("Failed to open auxiliary option window! (err: %v)", err);
                ui.close(w);
            } else do app_context^.options_window_opened = true;
        }
    }

    if err := ui.draw_image({512, 512}, app_context^.selected_image); err != nil {
        log.errorf("Failed to open image with path: %s; (err: %v)", app_context^.selected_image, err);
        ui.close(w);
    }
}

draw_options :: proc(w: ui.Window) {
    app_context := get_app_context();

    if w.signal == .Should_Close {
        app_context^.options_window_opened = false;
        return;
    }

    ui.set_button_size({300, 50});
    if ui.draw_button("Gauss Blur")   do app_context^.c.operations |= CF_GAUSS;
    if ui.draw_button("Sobel Filter") do app_context^.c.operations |= CF_SOBEL;
    if ui.draw_button("Unsharp mask") do app_context^.c.operations |= CF_UNSHARP;

    if ui.draw_button("Execute") do execute_operations(app_context);
}
