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
    ui_set_button_size({100, 50});

    @(static)
    active_img := "img1.png";

    if ui_draw_button("img1") {
        active_img = "img1.png";
    }
    if ui_draw_button("img2") {
        active_img = "img2.png";
    }
    if ui_draw_button("img3") {
        active_img = "img3.png";
    }
    if ui_draw_button("options") {
        if !OPTIONS_WINDOW_OPENED {
            err := ui_register_window({512, 512}, "Image Settings", draw_options);
            if err != nil {
                log.errorf("Failed to open auxiliary option window!");
                glfw.SetWindowShouldClose(w.handle, glfw.TRUE);
            } else do OPTIONS_WINDOW_OPENED = true;
        }
    }

    ui_draw_image(active_img);
}

draw_options :: proc(w: Window) {
    if w.signal == .SHOULD_CLOSE do OPTIONS_WINDOW_OPENED = false;

    ui_set_button_size({200, 50});
    if      ui_draw_button("Do something #1") do nothing();
    else if ui_draw_button("Do something #2") do nothing();
    else if ui_draw_button("Do something #3") do nothing();
}

nothing :: proc() {}