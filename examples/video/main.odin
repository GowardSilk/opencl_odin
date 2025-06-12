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
    assert(ok == .None && context.user_ptr != nil);

    _ = ui_register_window({1024, 1024}, "OpenCL Video", draw_main_screen);
    ui_draw();

    ui_destroy();
}

draw_main_screen :: proc(w: Window) {
    ui_set_button_size({100, 50});
    if      ui_draw_button("img1") do load_image("img1.png");
    else if ui_draw_button("img2") do load_image("img2.png");
    else if ui_draw_button("img3") do load_image("img3.png");
    else if ui_draw_button("options") {
        if !ui_register_window({512, 512}, "Image Settings", draw_options) {
            glfw.SetWindowShouldClose(w.handle, glfw.TRUE);
        }
    }
}

draw_options :: proc(_: Window) {
    ui_set_button_size({200, 50});
    if      ui_draw_button("Do something #1") do nothing();
    else if ui_draw_button("Do something #2") do nothing();
    else if ui_draw_button("Do something #3") do nothing();
}

nothing :: proc() {}