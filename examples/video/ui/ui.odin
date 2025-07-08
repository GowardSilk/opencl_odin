/**
 * @file ui.odin
 *
 * @brief contains basic UI facilities for displaying images/picking from options etc. in OpenGL/glfw.
 *  Rendering techniques is inspired by Dear ImGui
 *
 * @defgroup ui
 *
 * @author GowardSilk
 */
package ui;

import "base:runtime"

import "core:c"
import "core:log"
import "core:image"

import "vendor:glfw"
import gl "vendor:OpenGL"

/**
 * @brief signals to front end about the state of window
 * @note not to confuse with window event's like mouse move and others, these are handled internally (at least for now)
 */
Window_State_Signal :: enum {
    None = 0,
    Should_Close,
}

Window_Handle :: distinct uintptr;
Window_Ops_Table :: struct {
    get_mouse_pos:   #type proc "cdecl" (handle: Window_Handle) -> ([2]f64),
    get_mouse_state: #type proc "cdecl" (handle: Window_Handle, button: Mouse_ID) -> Mouse_State,
}

Window :: struct {
    size:       [2]c.int,       /**< size of the window at the time of creation (note: we do not handle window resize events, therefore this value is permanently valid) */
    handle:     Window_Handle,  /**< pointer address to either _Window (when backend == .D3D11) or glfw.WindowHandle (when backend == .GL) */
    draw_proc:  Draw_Proc,      /**< user defined draw procedure */
    cursor:     Draw_Cursor,    /**< stores information about widgets' layouts */
    signal:     Window_State_Signal,

    using vtable: Window_Ops_Table,
}

Draw_Command_Text :: struct {
    text: string,
    pos:  [2]i32, /**< top left corner*/
    size: [2]f32,
}
Draw_Command_Button :: struct {
    text: Draw_Command_Text,
    rect: Rect,
}
Draw_Command :: union {
    // note: images are not batched but rendered "in-place" so enqueuing it here makes no sense
    Draw_Command_Button,
    Draw_Command_Text,
}
Draw_Command_Queue :: struct {
    active_window: ^Window,
    commands: [dynamic]Draw_Command,
    windows: [dynamic]Window,
}

Draw_Context :: struct {
    queue:    Draw_Command_Queue,
    ren:      Batch_Renderer,
    usr_data: rawptr,
}

Draw_Proc :: #type proc "odin" (w: Window);
register_window :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> General_Error {
    ctx := get_context();
    w := prepare_window(size, name, draw, ctx^.ren.backend) or_return;
    if cast(uintptr)w.handle == 0 do return .Window_Creation;

    // deferred batch renderer initialization
    hwnd: Window_ID;
    switch ctx^.ren.backend {
        case .GL: hwnd = cast(Window_ID)w.handle;
        case .D3D11: hwnd = cast(Window_ID)(cast(^_Window)w.handle)^.hwnd;
    }
    if ctx^.ren.perwindow == nil {
        ctx^.ren = batch_renderer_new(hwnd, ctx^.ren.backend) or_return;
    } else {
        batch_renderer_clone(&ctx^.ren, hwnd) or_return;
    }

    append(&ctx^.queue.windows, w);

    return nil;
}

init :: proc(backend: Backend_Kind, usr_data: rawptr = nil) -> (ctx: ^Draw_Context, err: runtime.Allocator_Error) {
    #partial switch backend {
        case .GL:    init_glfw();
    }

    ctx = new(Draw_Context) or_return;

    // batch renderer
    // NOTE(GowardSilk): since we do not have any active window, we cannot create and compile shaders...
    ctx^.ren = Batch_Renderer{};
    ctx^.ren.backend = backend; // store it preemptively here...

    // render queue
    ctx^.queue.windows  = make_dynamic_array([dynamic]Window) or_return;
    ctx^.queue.commands = make_dynamic_array([dynamic]Draw_Command) or_return;

    ctx^.usr_data = usr_data;

    return ctx, .None;
}

set_font_size :: #force_inline proc(size: f32) {
    get_context()^.queue.active_window^.cursor.font_size = size;
}

set_button_size :: #force_inline proc(size: [2]c.int) {
    get_context()^.queue.active_window^.cursor.button_size = size;
}

draw_button :: proc(name: string) -> bool {
    ctx := get_context();
    queue := ctx^.queue;
    active_window := queue.active_window;

    button_pos  := draw_cursor_current();
    button_size := active_window.cursor.button_size;
    defer draw_cursor_button_next(); // move to the next "slot"

    window_width := active_window^.size.x;
    if button_pos.x + button_size.x > window_width {
        button_pos = draw_cursor_descend();
    }

    r_ndc := pos_to_ndc(
        create_rect(
            [2]f32 { cast(f32)button_pos.x, cast(f32)button_pos.y },
            [2]f32 { cast(f32)button_size.x, cast(f32)button_size.y },
        )
    );
    register_draw_command(Draw_Command_Button {
        Draw_Command_Text {
            name,
            button_pos,
            active_window.cursor.font_size,
        },
        r_ndc,
    });

    if (active_window^.get_mouse_state(active_window^.handle, .Left) == .Down) {
        mouse_pos     := active_window^.get_mouse_pos(active_window^.handle);
        button_pos64  := [2]c.double { cast(c.double)button_pos.x, cast(c.double)button_pos.y };
        button_size64 := [2]c.double { cast(c.double)button_size.x, cast(c.double)button_size.y };
        button_rect   := create_rect64(button_pos64, button_size64);
        if is_inside_widget(button_rect, mouse_pos) {
            return true;
        }
    }
    return false;
}

draw_image :: proc(size_hint: [2]c.int, img_path: string) -> (err: General_Error) {
    img_pos  := draw_cursor_current();
    window_width := get_context()^.queue.active_window^.size.x;
    if img_pos.x + size_hint.x > window_width {
        img_pos = draw_cursor_descend();
    }

    defer draw_cursor_next(size_hint); // move to the next "slot"

    ctx := get_context();
    // we cannot batch images properly, so they are loaded "in-place"
    handle: Window_ID;
    switch ctx^.ren.backend {
        case .D3D11: handle = cast(Window_ID)(cast(^_Window)ctx^.queue.active_window^.handle)^.hwnd;
        case .GL: handle = cast(Window_ID)ctx^.queue.active_window^.handle;
    }
    return batch_renderer_register_image(
        &ctx^.ren,
        handle,
        img_pos,
        {1, 1, 0, 0},
        img_path
    );
}

draw :: #force_inline proc() {
    ctx := get_context();
    switch ctx^.ren.backend {
        case .GL:    draw_glfw();
        case .D3D11: draw_win();
    }
}

reset_state :: proc() {
    ctx := get_context();

    draw_cursor_reset();
    clear(&ctx^.queue.commands);

    batch_renderer_clear(&ctx^.ren);
}

get_data :: #force_inline proc($T: typeid) -> ^T {
    return cast(^T)get_context()^.usr_data;
}

/**
 * @brief retrieves OpenGL texture2D id which contains img data from `img_path'
 * @note cannot query when Image from `img_path' was not loaded with `draw_image'
 * @param img_path path to the original img
 * @return OpenGL texture2D id
 */
get_image_id :: #force_inline proc(img_path: string) -> Image_Request_Result {
    return batch_renderer_handle_image_request(&get_context()^.ren, img_path);
}

/**
 * @brief resets registered renderer's texture ID to new location
 * @param img_path path to the original img
 * @param new_img_id new OpenGL texture2D id
 */
reset_image_id :: #force_inline proc(img_path: string, new_img_id: Image_Request_Result) {
    batch_renderer_invalidate_image_and_reset(&get_context()^.ren, img_path, new_img_id);
}

destroy :: proc() {
    ctx := get_context();

    switch ctx^.ren.backend {
        case .GL:    glfw.Terminate();
        case .D3D11:
    }

    // renderer
    batch_renderer_delete(&ctx^.ren);

    // windows
    switch ctx^.ren.backend {
        case .GL:
            for w in ctx^.queue.windows do destroy_window_glfw(w);
        case .D3D11:
            for w in ctx^.queue.windows do destroy_window_win(w);
    }

    // queue
    delete_dynamic_array(ctx^.queue.windows);
    delete_dynamic_array(ctx^.queue.commands);

    free(ctx);
}

close :: proc(w: Window) {
    ctx := get_context();
    switch ctx^.ren.backend {
        case .GL:
            glfw.SetWindowShouldClose(cast(glfw.WindowHandle)w.handle, glfw.TRUE);
            return;
        case .D3D11:
            (cast(^_Window)w.handle)^.should_close = true;
            return;
    }

    unreachable();
}
