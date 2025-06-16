#+private
/**
 * @file ui_private.odin
 *
 * @brief private part of ui.odin
 *
 * @ingroup ui
 *
 * @author GowardSilk
 */
package ui;

import "base:runtime"

import "core:c"
import "core:log"

import "vendor:glfw"
import gl "vendor:OpenGL"

/* =========================================
 *                Draw_Cursor
 * ========================================= */

Draw_Cursor :: struct {
    pos: [2]c.int, /**< current active position*/
    last_line_max_height: c.int,
    button_size: [2]c.int, /**< default button size*/
    font_size: f32, /**< default font size*/
}

DRAW_CURSOR_DEFAULT :: #force_inline proc() -> Draw_Cursor {
    return Draw_Cursor { {0, 0}, 0, {20, 20}, 30 };
}

draw_cursor_reset :: #force_inline proc() {
    queue := get_context()^.queue;
    queue.active_window.cursor = DRAW_CURSOR_DEFAULT();
}

draw_cursor_current :: #force_inline proc() -> [2]c.int {
    queue := get_context()^.queue;
    return queue.active_window.cursor.pos.xy;
}

draw_cursor_descend :: proc() -> [2]c.int {
    active_window := get_context()^.queue.active_window;
    height := active_window^.cursor.last_line_max_height;
    active_window^.cursor.pos.y += height;
    active_window^.cursor.pos.x = 0;
    active_window^.cursor.last_line_max_height = 0;
    return active_window^.cursor.pos;
}

draw_cursor_next :: proc(size: [2]c.int) {
    queue := get_context()^.queue;
    active_window := queue.active_window;
    active_window^.cursor.pos.x += size.x;
    width, _ := glfw.GetWindowSize(active_window^.handle);
    if active_window^.cursor.last_line_max_height < size.y {
        active_window^.cursor.last_line_max_height = size.y;
    }
}

draw_cursor_button_next :: #force_inline proc() {
    draw_cursor_next(get_context()^.queue.active_window^.cursor.button_size);
}

/* =========================================
 *                 Rectangle
 * ========================================= */

Rect32  :: struct { x1, y1: f32, x2, y2: f32 }
Rect    :: Rect32;
Rect64  :: struct { x1, y1: c.double, x2, y2: c.double }

create_rect :: #force_inline proc(pos: [2]f32, sz: [2]f32) -> Rect {
    return Rect {
        pos.x, pos.y,
        pos.x + sz.x, pos.y + sz.y,
    };
}

create_rect64 :: proc(pos: [2]c.double, sz: [2]c.double) -> Rect64 {
    return Rect64 {
        pos.x, pos.y,
        pos.x + sz.x, pos.y + sz.y,
    };
}

pos_to_ndc :: proc(r: Rect) -> Rect {
    queue := get_context()^.queue;
    active_window := queue.active_window;
    
    width, height := glfw.GetWindowSize(active_window.handle);
    x1_ndc := (2.0 * r.x1 / cast(f32)width) - 1.0;
    y1_ndc := 1.0 - (2.0 * r.y1 / cast(f32)height);
    x2_ndc := (2.0 * r.x2 / cast(f32)width) - 1.0;
    y2_ndc := 1.0 - (2.0 * r.y2 / cast(f32)height);
    return Rect { x1_ndc, y1_ndc, x2_ndc, y2_ndc };
}

/* =========================================
 *                  Window
 * ========================================= */

prepare_window :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> (win: Window, err: General_Error) {
    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE);
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE);
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6);
    when ODIN_DEBUG do glfw.WindowHint(glfw.OPENGL_DEBUG_CONTEXT, glfw.TRUE);
	
    ctx := get_context();
    window_share: glfw.WindowHandle = nil;
    if len(ctx.queue.windows) > 0 do window_share = ctx.queue.windows[0].handle;
	win.handle = glfw.CreateWindow(size.x, size.y, name, nil, window_share);

	if win.handle == nil {
        log.error("Error: failed to initialize window!");
		return win, .Window_Creation;
	}
	
	glfw.MakeContextCurrent(win.handle);
	glfw.SwapInterval(1);
	// ?? glfw.SetKeyCallback(window_handle, key_callback);
	// ?? glfw.SetFramebufferSizeCallback(window_handle, size_callback);

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
    win.name = name;
    win.draw_proc = draw;
    win.cursor = DRAW_CURSOR_DEFAULT();

    return win, nil;
}

destroy_window :: #force_inline proc(w: Window) {
    glfw.DestroyWindow(w.handle);
}

/* =========================================
 *          General helper functions
 * ========================================= */

get_context :: #force_inline proc() -> ^Draw_Context {
    return cast(^Draw_Context)context.user_ptr;
}

is_inside_widget :: #force_inline proc(r: Rect64, point: [2]c.double) -> bool{
    return point.x >= r.x1 && point.y >= r.y1 && point.x <= r.x2 && point.y <= r.y2;
}

register_draw_command :: #force_inline proc(cmd: Draw_Command) {
    append(&get_context()^.queue.commands, cmd)
}

execute_draw_commands :: proc() {
    ctx := get_context();
    ren := &ctx^.ren;
    batch_renderer_clear(ren);

    for cmd in ctx^.queue.commands {
        switch c in cmd {
            case Draw_Command_Button:  batch_renderer_add_button(ren, c);
            case Draw_Command_Text:    batch_renderer_add_text(ren, c);
        }
    }

    batch_renderer_construct(ren, cast(Batch_Renderer_Window_ID)ctx^.queue.active_window^.handle);
}
