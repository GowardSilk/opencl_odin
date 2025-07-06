//#+private

package ui;

import "base:runtime"

import "core:c"
import "core:log"

import gl "vendor:OpenGL"
import glfw "vendor:glfw"

init_glfw :: #force_inline proc() {
    assert(glfw.Init() == glfw.TRUE, "Error: failed to initialize glfw!");
}

prepare_window_glfw :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> (win: Window, err: General_Error) {
    // Window ops functions
    get_mouse_pos_glfw   :: proc "cdecl" (handle: Window_Handle) -> ([2]f64) {
        xpos, ypos := glfw.GetCursorPos(cast(glfw.WindowHandle)handle);
        return {xpos, ypos};
    }
    get_mouse_state_glfw :: proc "cdecl" (handle: Window_Handle, button: Mouse_ID) -> Mouse_State {
        b: c.int;
        switch button {
            case .Left:   b = glfw.MOUSE_BUTTON_LEFT;
            case .Right:  b = glfw.MOUSE_BUTTON_RIGHT;
            case .Middle: b = glfw.MOUSE_BUTTON_MIDDLE;
        }

        state := glfw.GetMouseButton(cast(glfw.WindowHandle)handle, b);
        switch state {
            case glfw.PRESS:    return .Down;
            case glfw.RELEASE:  return .Up;
        }

        return .Invalid;
    }

    // setup for OpenGL 4.6
    glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE);
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6);
    when ODIN_DEBUG do glfw.WindowHint(glfw.OPENGL_DEBUG_CONTEXT, glfw.TRUE);

    ctx := get_context();
    window_share: glfw.WindowHandle = nil;
    if len(ctx.queue.windows) > 0 do window_share = cast(glfw.WindowHandle)ctx.queue.windows[0].handle;
    glfw_handle := glfw.CreateWindow(size.x, size.y, name, nil, window_share);

    if glfw_handle == nil {
        log.error("Error: failed to initialize window!");
        return win, .Window_Creation;
    }
    win.handle = cast(Window_Handle)glfw_handle;

    glfw.MakeContextCurrent(glfw_handle);
    glfw.SwapInterval(1);

    when ODIN_DEBUG {
        debug_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, userParam: rawptr) {
            context = runtime.default_context();
            log.errorf("GL DEBUG: %s\n", message);
        }

        gl.load_up_to(int(4), 6, glfw.gl_set_proc_address);

        is_debug: i32;
        gl.GetIntegerv(gl.CONTEXT_FLAGS, &is_debug);
        if (is_debug & gl.CONTEXT_FLAG_DEBUG_BIT) != 0 {
            gl.Enable(gl.DEBUG_OUTPUT);
            gl.Enable(gl.DEBUG_OUTPUT_SYNCHRONOUS);
            gl.DebugMessageCallback(debug_callback, nil);
            log.info("Debug callback registered!");
        }
    }

    win.size = size;
    win.draw_proc = draw;
    win.cursor = DRAW_CURSOR_DEFAULT();
    win.vtable = Window_Ops_Table {
        get_mouse_pos_glfw,
        get_mouse_state_glfw,
    };

    return win, nil;
}

draw_glfw :: proc() {
    ctx := get_context();
    queue := &ctx^.queue;

    for len(queue^.windows) > 0 {
        l := len(queue^.windows);
        for i := 0; i < l; i += 1 {
            w := queue^.windows[i];
            glfw_handle := cast(glfw.WindowHandle)w.handle;
            glfw.MakeContextCurrent(glfw_handle);
            glfw.PollEvents();

            if (!glfw.WindowShouldClose(glfw_handle)) {
                queue^.active_window = &w;

                gl.ClearColor(0.1, 0.1, 0.1, 1.0);
                gl.Clear(gl.COLOR_BUFFER_BIT);

                w->draw_proc();
                execute_draw_commands();
                reset_state();
                glfw.SwapBuffers(glfw_handle);
            } else {
                // signal to the draw function that the window is being closed
                w.signal = .Should_Close;
                w->draw_proc();
                batch_renderer_unload(&ctx^.ren, cast(Window_ID)glfw_handle);
                glfw.DestroyWindow(glfw_handle);
                ordered_remove(&queue^.windows, i);
                l -= 1;
            }
        }
        batch_renderer_reset(&ctx^.ren);
    }
}

destroy_window_glfw :: proc(window: Window) {
    glfw.DestroyWindow(cast(glfw.WindowHandle)window.handle);
}
