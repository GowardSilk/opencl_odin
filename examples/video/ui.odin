/**
 * @file ui.odin
 *
 * @brief contains basic UI facilities for displaying images/picking from options etc. in OpenGL/glfw.
 *  Rendering techniques is inspired by Dear ImGui
 *
 * @defgroup video
 *
 * @author GowardSilk
 */
package video;

import "base:runtime"

import "core:c"
import "core:log"
import "core:mem"
import "core:image"

import "vendor:glfw"
import gl "vendor:OpenGL"

Draw_Proc :: #type proc "odin" (w: Window);
Draw_Cursor :: struct {
    pos: [2]c.int, /**< current active position*/
    button_size: [2]c.int, /**< default button size*/
    button_color: [4]c.int, /**< default button color */
    font_size: i32,
}
WHITE :: [4]c.int { 255, 255, 255, 255 };
RED :: [4]c.int { 255, 0, 0, 255 };
GREEN :: [4]c.int { 0, 255, 0, 255 };
BLUE :: [4]c.int { 0, 0, 255, 255 };
DRAW_CURSOR_DEFAULT :: #force_inline proc() -> Draw_Cursor {
    return Draw_Cursor { {0, 0}, {20, 20}, WHITE, 10 };
}
Window_Signal :: enum {
    NONE = 0,
    SHOULD_CLOSE,
}
Window :: struct {
    size: [2]c.int,
    name: cstring,
    handle: glfw.WindowHandle,
    draw_proc: Draw_Proc,
    cursor: Draw_Cursor,
    signal: Window_Signal,
}

Window_Index :: distinct u32;

Draw_Command_Text :: struct {
    text: string,
    pos: [2]i32, /**< top left corner*/
    size: i32,
}
Draw_Command_Button :: struct {
    text: Draw_Command_Text,
    rect: Rect,
    color: [4]c.int,
}
Draw_Command :: union {
    Draw_Command_Button,
    Draw_Command_Text,
}
Draw_Command_Queue :: struct {
    active_window: Window_Index,
    commands: [dynamic]Draw_Command,
    windows: [dynamic]Window,
}

Draw_Context :: struct {
    queue: Draw_Command_Queue,
    ren: Batch_Renderer,
}

Rect32 :: struct { x1, y1: f32, x2, y2: f32 }
Rect :: Rect32;
Rect64 :: struct { x1, y1: c.double, x2, y2: c.double }

@(private="file")
get_context :: #force_inline proc() -> ^Draw_Context {
    return cast(^Draw_Context)context.user_ptr;
}

@(private="file")
debug_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, userParam: rawptr) {
    context = runtime.default_context();
    log.errorf("GL DEBUG: %s\n", message);
}

@(private="file")
ui_prepare_window :: proc(size: [2]c.int, name: cstring) -> Window {
    glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE);
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, glfw.TRUE);
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4);
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6);
    when ODIN_DEBUG do glfw.WindowHint(glfw.OPENGL_DEBUG_CONTEXT, glfw.TRUE);
	
    ctx := get_context();
    window_share: glfw.WindowHandle = nil;
    if len(ctx.queue.windows) > 0 do window_share = ctx.queue.windows[0].handle;
	window_handle := glfw.CreateWindow(size.x, size.y, name, nil, window_share);

	if window_handle == nil {
        log.error("Error: failed to initialize window!");
		return Window {};
	}
	
	glfw.MakeContextCurrent(window_handle);
	glfw.SwapInterval(1);
	// ?? glfw.SetKeyCallback(window_handle, key_callback);
	// ?? glfw.SetFramebufferSizeCallback(window_handle, size_callback);

    when ODIN_DEBUG {
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

    return Window {
        size,
        name,
        window_handle,
        nil,
        DRAW_CURSOR_DEFAULT(),
        .NONE,
    };
}

@(private="file")
ui_destroy_window :: #force_inline proc(w: Window) {
    glfw.DestroyWindow(w.handle);
}

ui_register_window :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> General_Error {
    w := ui_prepare_window(size, name);
    if w.handle == nil do return .Window_Creation;
    w.draw_proc = draw;
    
    // deferred batch renderer initialization
    ctx := get_context();
    if ctx^.ren.rects.shaders == nil {
        ctx^.ren = batch_renderer_new() or_return;
    } else {
        batch_renderer_clone(&ctx^.ren) or_return;
    }

    append(&ctx^.queue.windows, w);

    return nil;
}

@(private="file")
ui_glfw_error_callback :: proc "cdecl" (error: c.int, description: cstring) {
    context = runtime.default_context();
    log.errorf("Error encountered (%d): %s", error, description);
}

ui_init :: proc() -> (ctx: ^Draw_Context, err: runtime.Allocator_Error) {
    glfw.SetErrorCallback(ui_glfw_error_callback);

	if(glfw.Init() != glfw.TRUE){
        log.error("Error: failed to initialize glfw!");
		return nil, .None;
	}

    ctx = new(Draw_Context) or_return;

    // batch renderer
    // NOTE: since we do not have any active window, we cannot create and compile shaders...
    ctx^.ren = Batch_Renderer{};

    // render queue
    ctx^.queue.windows = make_dynamic_array([dynamic]Window) or_return;
    ctx^.queue.commands = make_dynamic_array([dynamic]Draw_Command) or_return;

    return ctx, .None;
}

@(private="file")
ui_draw_cursor_reset :: #force_inline proc() {
    queue := get_context()^.queue;
    queue.windows[queue.active_window].cursor = DRAW_CURSOR_DEFAULT();
}

@(private="file")
ui_draw_cursor_current :: #force_inline proc() -> [2]c.int {
    queue := get_context()^.queue;
    return queue.windows[queue.active_window].cursor.pos.xy;
}

@(private="file")
ui_draw_cursor_button_next :: #force_inline proc() {
    queue := get_context()^.queue;
    active_window := &queue.windows[queue.active_window];
    active_window^.cursor.pos.x += active_window^.cursor.button_size.x;
    width, _ := glfw.GetWindowSize(active_window^.handle);
    if active_window^.cursor.pos.x >= width {
        active_window^.cursor.pos.x = 0;
        active_window^.cursor.pos.y += active_window^.cursor.button_size.y;
    }
}

ui_set_button_size :: #force_inline proc(size: [2]c.int) {
    queue := get_context()^.queue;
    active_window := &queue.windows[queue.active_window];
    active_window^.cursor.button_size = size;
}

ui_set_button_color :: #force_inline proc(color: [4]c.int) {
    queue := get_context()^.queue;
    active_window := &queue.windows[queue.active_window];
    active_window^.cursor.button_color = color;
}

ui_pos_to_ndc :: proc(r: Rect) -> Rect {
    queue := get_context()^.queue;
    active_window := queue.windows[queue.active_window];
    
    width, height := glfw.GetWindowSize(active_window.handle);
    x1_ndc := (2.0 * r.x1 / cast(f32)width) - 1.0;
    y1_ndc := 1.0 - (2.0 * r.y1 / cast(f32)height);
    x2_ndc := (2.0 * r.x2 / cast(f32)width) - 1.0;
    y2_ndc := 1.0 - (2.0 * r.y2 / cast(f32)height);
    return Rect { x1_ndc, y1_ndc, x2_ndc, y2_ndc };
}

ui_create_rect :: #force_inline proc(pos: [2]f32, sz: [2]f32) -> Rect {
    return Rect {
        pos.x, pos.y,
        pos.x + sz.x, pos.y + sz.y,
    };
}

ui_create_rect64 :: proc(pos: [2]c.double, sz: [2]c.double) -> Rect64 {
    return Rect64 {
        pos.x, pos.y,
        pos.x + sz.x, pos.y + sz.y,
    };
}

@(private="file")
ui_is_inside_widget :: #force_inline proc(r: Rect64, point: [2]c.double) -> bool{
    return point.x >= r.x1 && point.y >= r.y1 && point.x <= r.x2 && point.y <= r.y2;
}

ui_draw_button :: proc(name: string) -> bool {
    queue := get_context()^.queue;
    active_window := queue.windows[queue.active_window];

    button_pos  := ui_draw_cursor_current();
    button_size := active_window.cursor.button_size;
    defer ui_draw_cursor_button_next(); // move to the next "slot"

    r_ndc := ui_pos_to_ndc(
        ui_create_rect(
            [2]f32 { cast(f32)button_pos.x, cast(f32)button_pos.y },
            [2]f32 { cast(f32)button_size.x, cast(f32)button_size.y },
        ),
    );
    ui_register_draw_command(Draw_Command_Button {
        Draw_Command_Text { name, button_pos, active_window.cursor.font_size, },
        r_ndc, active_window.cursor.button_color,
    });

    button_pos64  := [2]c.double { cast(c.double)button_pos.x, cast(c.double)button_pos.y };
    button_size64 := [2]c.double { cast(c.double)button_size.x, cast(c.double)button_size.y };

    state := glfw.GetMouseButton(active_window.handle, glfw.MOUSE_BUTTON_LEFT);
    if (state == glfw.PRESS) {
        mouse_xpos, mouse_ypos := glfw.GetCursorPos(active_window.handle);
        if ui_is_inside_widget(
            ui_create_rect64(button_pos64, button_size64),
            {mouse_xpos, mouse_ypos}
        ) {
            return true;
        }
    }
    return false;
}

ui_draw_image :: #force_inline proc(img_path: string) -> (err: General_Error) {
    img_pos  := ui_draw_cursor_current();
    defer ui_draw_cursor_button_next(); // move to the next "slot"

    ctx := get_context();
    // we cannot batch images properly, so they are loaded "in-place"
    return batch_renderer_register_image(&ctx^.ren,ctx^. queue.active_window, img_pos, {1, 1, 0, 0}, img_path);
}

@(private="file")
ui_register_draw_command :: #force_inline proc(cmd: Draw_Command) {
    append(&get_context()^.queue.commands, cmd)
}

@(private="file")
ui_execute_draw_commands :: proc() {
    ctx := get_context();
    ren := &ctx^.ren;
    batch_renderer_clear(ren);

    for cmd in ctx^.queue.commands {
        switch c in cmd {
            case Draw_Command_Button:  batch_renderer_add_button(ren, c);
            case Draw_Command_Text:    batch_renderer_add_text(ren, c);
        }
    }

    batch_renderer_construct(ren, ctx^.queue.active_window);
}

ui_draw :: proc() {
    ctx := get_context();
    queue := &ctx^.queue;

    for len(queue^.windows) > 0 {
        l := len(queue^.windows);
        for index := 0; index < l; index += 1 {
            w := queue^.windows[index];
            glfw.PollEvents();

            if (!glfw.WindowShouldClose(w.handle)) {
                queue^.active_window = cast(Window_Index)index;
                glfw.MakeContextCurrent(w.handle);

                gl.ClearColor(0.1, 0.1, 0.1, 1.0);
                gl.Clear(gl.COLOR_BUFFER_BIT);

                w->draw_proc();
                ui_execute_draw_commands();
                ui_reset_state();
                glfw.SwapBuffers(w.handle);
            } else {
                // signal to the draw function that the window is being closed
                w.signal = .SHOULD_CLOSE;
                w->draw_proc();
                glfw.DestroyWindow(w.handle);
                ordered_remove(&queue^.windows, index);
                batch_renderer_unload_index(&ctx^.ren, cast(int)index);
                l -= 1;
            }
        }
        batch_renderer_reset(&ctx^.ren);
    }
}

ui_reset_state :: proc() {
    ctx := get_context();

    ui_draw_cursor_reset();
    clear(&ctx^.queue.commands);

    batch_renderer_clear(&ctx^.ren);
}

ui_destroy :: proc() {
    ctx := get_context();

	glfw.Terminate();
    batch_renderer_delete(&ctx^.ren);
    for w in ctx^.queue.windows {
        ui_destroy_window(w);
    }
    delete_dynamic_array(ctx^.queue.windows);
    delete_dynamic_array(ctx^.queue.commands);
    free(ctx);
}