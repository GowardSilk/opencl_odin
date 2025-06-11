/**
 * @file ui.odin
 *
 * @brief contains basic UI facilities for displaying images/picking from options etc. in OpenGL/glfw.
 *  Rendering techniques is inspired by Dear ImGui
 *
 * @ingroup video
 *
 * @author GowardSilk
 */
package video;

import "base:runtime"

import "core:c"
import "core:log"

import "vendor:glfw"
import gl "vendor:OpenGL"

Draw_Proc :: #type proc "odin" (w: Window);
Draw_Cursor :: struct {
    pos: [2]c.int, /**< current active position*/
    button_size: [2]c.int, /**< default button size*/
    font_size: c.double,
}
DRAW_CURSOR_DEFAULT :: #force_inline proc() -> Draw_Cursor {
    return Draw_Cursor { {0, 0}, {20, 20}, 10 };
}
Window :: struct {
    size: [2]c.int,
    name: cstring,
    handle: glfw.WindowHandle,
    draw_proc: Draw_Proc,
    cursor: Draw_Cursor,
}

@(private="file")
Window_Index :: distinct uint;

Draw_Command_Text :: struct {
    text: string,
    size: c.double,
    idx: Window_Index,
}
Draw_Command_Button :: struct {
    text: Draw_Command_Text,
    size: [2]c.int,
    idx: Window_Index,
}
Draw_Command :: union {
    Draw_Command_Button,
    Draw_Command_Text,
}
Draw_Command_Queue :: struct {
    commands: [dynamic]Draw_Command,
    windows: [dynamic]Window,
    active_window: Window_Index,
}

/** @brief contains all batched buffers for one Window render */
Batch_Renderer :: struct { /* TODO */ }

@(private="file")
ui_prepare_window :: proc(size: [2]c.int, name: cstring) -> Window {
    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE);
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE);
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6);
	
	window_handle := glfw.CreateWindow(size.x, size.y, name, nil, nil);
	defer glfw.DestroyWindow(window_handle);

	if window_handle == nil {
        log.error("Error: failed to initialize window!");
		return Window {};
	}
	
	glfw.MakeContextCurrent(window_handle);
	glfw.SwapInterval(1);
	// ?? glfw.SetKeyCallback(window_handle, key_callback);
	// ?? glfw.SetFramebufferSizeCallback(window_handle, size_callback);

	gl.load_up_to(int(4), 6, glfw.gl_set_proc_address);

    return Window {
        size,
        name,
        window_handle,
        nil,
        DRAW_CURSOR_DEFAULT(),
    };
}

@(private="file")
ui_destroy_window :: proc(w: Window) {
    glfw.DestroyWindow(w.handle);
}

ui_register_window :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> bool {
    w := ui_prepare_window(size, name);
    if w.handle == nil do return false;
    return true;
}

ui_init :: proc() -> (queue: ^Draw_Command_Queue, err: runtime.Allocator_Error) {
	if(glfw.Init() != glfw.TRUE){
        log.error("Error: failed to initialize glfw!");
		return nil, .None;
	}
    queue = new(Draw_Command_Queue) or_return;
    queue^.windows = make_dynamic_array([dynamic]Window) or_return;
    queue^.commands = make_dynamic_array([dynamic]Draw_Command) or_return;
    return queue, .None;
}

@(private="file")
ui_draw_cursor_current :: #force_inline proc() -> [2]c.int {
    queue := cast(^Draw_Command_Queue)context.user_ptr;
    return queue^.windows[queue^.active_window].cursor.pos.xy;
}

@(private="file")
ui_draw_cursor_button_next :: #force_inline proc() {
    queue := cast(^Draw_Command_Queue)context.user_ptr;
    active_window := &queue^.windows[queue^.active_window];
    active_window^.cursor.pos.xy += active_window^.cursor.button_size.xy;
}

ui_set_button_size :: #force_inline proc(size: [2]c.int) {
    queue := cast(^Draw_Command_Queue)context.user_ptr;
    active_window := &queue^.windows[queue^.active_window];
    active_window^.cursor.button_size = size;
}

@(private="file")
Rect :: struct { x1, y1: c.double, x2, y2: c.double }
@(private="file")
ui_is_inside_widget :: #force_inline proc(r: Rect, point: [2]c.double) -> bool{
    return point.x >= r.x1 && point.y >= r.y1 && point.x <= r.x2 && point.y <= r.y2;
}

ui_draw_button :: proc(name: string) -> bool {
    queue := cast(^Draw_Command_Queue)context.user_ptr;
    active_window := queue^.windows[queue^.active_window];

    ui_register_draw_command(Draw_Command_Button {
        Draw_Command_Text { name, active_window.cursor.font_size, 0 },
        active_window.cursor.button_size,
        0, // TODO: DO WE REALLY NEED PER-WINDOW BATCHER ?
    });

    button_pos := ui_draw_cursor_current();
    button_size := [2]c.double{ cast(c.double)active_window.cursor.button_size.x, cast(c.double)active_window.cursor.button_size.y };
    state := glfw.GetMouseButton(active_window.handle, glfw.MOUSE_BUTTON_LEFT);
    if (state == glfw.PRESS) {
        mouse_xpos, mouse_ypos := glfw.GetCursorPos(active_window.handle);
        if ui_is_inside_widget(
            Rect{cast(c.double)button_pos.x, cast(c.double)button_pos.y, cast(c.double)button_pos.x + button_size.x, cast(c.double)button_pos.y + button_size.y},
            {mouse_xpos, mouse_ypos}
        ) {
            return true;
        }
    }
    return false;
}

@(private="file")
ui_register_draw_command :: proc(cmd: Draw_Command) {
    queue := cast(^Draw_Command_Queue)context.user_ptr;
    append(&queue^.commands, cmd);
}

@(private="file")
ui_execute_draw_commands :: proc() {
    queue := cast(^Draw_Command_Queue)context.user_ptr;
    for cmd in queue^.commands {
        switch c in cmd {
            case Draw_Command_Button: assert(false, "TODO");
            case Draw_Command_Text:   assert(false, "TODO");
        }
    }
}

ui_draw :: proc() {
    queue := cast(^Draw_Command_Queue)context.user_ptr;

    for w in queue^.windows {
        glfw.PollEvents();
        if (!glfw.WindowShouldClose(w.handle)) {
            glfw.MakeContextCurrent(w.handle);
            w->draw_proc();
            glfw.SwapBuffers(w.handle);
        }
        ui_execute_draw_commands();
    }
}

ui_destroy :: proc() {
	glfw.Terminate();
    queue := cast(^Draw_Command_Queue)context.user_ptr;
    for w in queue^.windows {
        ui_destroy_window(w);
    }
    delete_dynamic_array(queue^.windows);
    delete_dynamic_array(queue^.commands);
    free(queue);
}