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
    width := active_window^.size.x;
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

    size := active_window.size;
    x1_ndc := (2.0 * r.x1 / cast(f32)size.x) - 1.0;
    y1_ndc := 1.0 - (2.0 * r.y1 / cast(f32)size.y);
    x2_ndc := (2.0 * r.x2 / cast(f32)size.x) - 1.0;
    y2_ndc := 1.0 - (2.0 * r.y2 / cast(f32)size.y);
    return Rect { x1_ndc, y1_ndc, x2_ndc, y2_ndc };
}

/* =========================================
 *                  Window
 * ========================================= */

prepare_window :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc, backend: Backend_Kind) -> (win: Window, err: General_Error) {
    switch backend {
        case .GL:    return prepare_window_glfw(size, name, draw);
        case .D3D11: return prepare_window_win(size, name, draw);
    }

    unreachable();
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

    batch_renderer_construct(ren, cast(Window_ID)ctx^.queue.active_window^.handle);
}
