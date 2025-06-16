package video;

import "base:runtime"

import "core:c"
import "core:log"

import gl "vendor:OpenGL"
import "vendor:glfw"
import "shared:opencl"

main :: proc() {
    context.logger = log.create_console_logger();

    ok: runtime.Allocator_Error;
    context.user_ptr, ok = ui_init();
    defer ui_destroy();
    assert(ok == .None && context.user_ptr != nil);

    err := ui_register_window({1024, 1024}, "OpenCL Video", draw_main_screen);
    log.assertf(err == nil, "Failed to register window (\"OpenCL Video\"): %v", err)

    ui_draw();
}

OPTIONS_WINDOW_OPENED := false;

draw_main_screen :: proc(w: Window) {
    if w.signal == .SHOULD_CLOSE do return;

    Image_Descriptor :: struct { path, display_name: string };
    images :: [?]Image_Descriptor {
        { "video/resources/images/lena_color_512.png", "Lena" },
        { "video/resources/images/mandril_color.png",  "Mandril" },
        { "video/resources/images/peppers_color.png",  "Peppers" },
    };
    @(static)
    active_img := images[0].path;

    ui_set_button_size({100, 50});
    for img in images {
        if ui_draw_button(img.display_name) do active_img = img.path;
    }

    if ui_draw_button("options") {
        if !OPTIONS_WINDOW_OPENED {
            if err := ui_register_window({512, 512}, "Image Settings", draw_options); err != nil {
                log.errorf("Failed to open auxiliary option window! (err: %v)", err);
                glfw.SetWindowShouldClose(w.handle, glfw.TRUE);
            } else do OPTIONS_WINDOW_OPENED = true;
        }
    }

    if err := ui_draw_image(active_img); err != nil {
        log.errorf("Failed to open image with path: %s; (err: %v)", active_img, err);
        glfw.SetWindowShouldClose(w.handle, glfw.TRUE);
    }
}

draw_options :: proc(w: Window) {
    if w.signal == .SHOULD_CLOSE {
        OPTIONS_WINDOW_OPENED = false;
        return;
    }

    ui_set_button_size({200, 50});
    if      ui_draw_button("Do something #1") do nothing();
    else if ui_draw_button("Do something #2") do nothing();
    else if ui_draw_button("Do something #3") do nothing();
}

nothing :: proc() {}