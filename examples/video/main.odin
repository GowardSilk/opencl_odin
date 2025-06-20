package video;

import "base:runtime"

import "core:c"
import "core:log"

import cl "shared:opencl"
import "vendor:glfw"

import "ui"

App_Context :: struct {
    c: OpenCL_Context,
    selected_image: string,
    options_window_opened: bool,
}

get_app_context :: proc() -> ^App_Context {
    return ui.get_data(App_Context);
}

main :: proc() {
    context.logger = log.create_console_logger();

    app_context: App_Context;
    app_context.selected_image = "video/resources/images/lena_color_512.png";

    ok: runtime.Allocator_Error;
    context.user_ptr, ok = ui.init(&app_context);
    defer ui.destroy();
    assert(ok == .None && context.user_ptr != nil);

    // cl.Context creation needs to happend AFTER OpenGL's Context is initialized
    cerr: Error;
    app_context.c, cerr = cl_context_init();
    log.assertf(cerr == nil, "Fatal error: %v", cerr);
    defer cl_context_delete(&app_context.c);
    when ODIN_DEBUG {
        log_str := cl_context_log(&app_context.c);
        log.info(log_str);
        delete(log_str);
    }

    err := ui.register_window({1024, 1024}, "OpenCL Video", draw_main_screen);
    log.assertf(err == nil, "Failed to register window (\"OpenCL Video\"): %v", err);

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
                glfw.SetWindowShouldClose(w.handle, glfw.TRUE);
            } else do app_context^.options_window_opened = true;
        }
    }

    if err := ui.draw_image({512, 512}, app_context^.selected_image); err != nil {
        log.errorf("Failed to open image with path: %s; (err: %v)", app_context^.selected_image, err);
        glfw.SetWindowShouldClose(w.handle, glfw.TRUE);
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