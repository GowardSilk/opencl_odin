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

Window_Signal :: enum {
    None = 0,
    Should_Close,
}
Window :: struct {
    size: [2]c.int,
    name: cstring,
    handle: glfw.WindowHandle,
    draw_proc: Draw_Proc,
    cursor: Draw_Cursor,
    signal: Window_Signal,
}

Draw_Command_Text :: struct {
    text: string,
    pos: [2]i32, /**< top left corner*/
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
    queue: Draw_Command_Queue,
    ren: Batch_Renderer,
    usr_data: rawptr,
}

Draw_Proc :: #type proc "odin" (w: Window);
register_window :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> General_Error {
    w := prepare_window(size, name, draw) or_return;
    if w.handle == nil do return .Window_Creation;
    
    // deferred batch renderer initialization
    ctx := get_context();
    if ctx^.ren.perwindow == nil {
        ctx^.ren = batch_renderer_new(cast(Batch_Renderer_Window_ID)w.handle) or_return;
    } else {
        batch_renderer_clone(&ctx^.ren, cast(Batch_Renderer_Window_ID)w.handle) or_return;
    }

    append(&ctx^.queue.windows, w);

    return nil;
}

init :: proc(usr_data: rawptr = nil) -> (ctx: ^Draw_Context, err: runtime.Allocator_Error) {
    glfw_error_callback :: proc "cdecl" (error: c.int, description: cstring) {
        context = runtime.default_context();
        log.errorf("Error encountered (%d): %s", error, description);
    }
    glfw.SetErrorCallback(glfw_error_callback);

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
    queue := get_context()^.queue;
    active_window := queue.active_window;

    button_pos  := draw_cursor_current();
    button_size := active_window.cursor.button_size;
    defer draw_cursor_button_next(); // move to the next "slot"

    window_width, _ := glfw.GetWindowSize(active_window^.handle);
    if button_pos.x + button_size.x > window_width {
        button_pos = draw_cursor_descend();
    }

    r_ndc := pos_to_ndc(
        create_rect(
            [2]f32 { cast(f32)button_pos.x, cast(f32)button_pos.y },
            [2]f32 { cast(f32)button_size.x, cast(f32)button_size.y },
        ),
    );
    register_draw_command(Draw_Command_Button {
        Draw_Command_Text {
            name,
            button_pos,
            active_window.cursor.font_size,
        },
        r_ndc,
    });

    button_pos64  := [2]c.double { cast(c.double)button_pos.x, cast(c.double)button_pos.y };
    button_size64 := [2]c.double { cast(c.double)button_size.x, cast(c.double)button_size.y };

    state := glfw.GetMouseButton(active_window.handle, glfw.MOUSE_BUTTON_LEFT);
    if (state == glfw.PRESS) {
        mouse_xpos, mouse_ypos := glfw.GetCursorPos(active_window.handle);
        if is_inside_widget(
            create_rect64(button_pos64, button_size64),
            {mouse_xpos, mouse_ypos}
        ) {
            return true;
        }
    }
    return false;
}

draw_image :: proc(size_hint: [2]c.int, img_path: string) -> (err: General_Error) {
    img_pos  := draw_cursor_current();
    window_width, _ := glfw.GetWindowSize(get_context()^.queue.active_window^.handle);
    if img_pos.x + size_hint.x > window_width {
        img_pos = draw_cursor_descend();
    }
    
    defer draw_cursor_next(size_hint); // move to the next "slot"

    ctx := get_context();
    // we cannot batch images properly, so they are loaded "in-place"
    return batch_renderer_register_image(
        &ctx^.ren,
        cast(Batch_Renderer_Window_ID)ctx^.queue.active_window^.handle,
        img_pos,
        {1, 1, 0, 0},
        img_path
    );
}

draw :: proc() {
    ctx := get_context();
    queue := &ctx^.queue;

    for len(queue^.windows) > 0 {
        l := len(queue^.windows);
        for i := 0; i < l; i += 1 {
            w := queue^.windows[i];
            glfw.MakeContextCurrent(w.handle);
            glfw.PollEvents();

            if (!glfw.WindowShouldClose(w.handle)) {
                queue^.active_window = &w;

                gl.ClearColor(0.1, 0.1, 0.1, 1.0);
                gl.Clear(gl.COLOR_BUFFER_BIT);

                w->draw_proc();
                execute_draw_commands();
                reset_state();
                glfw.SwapBuffers(w.handle);
            } else {
                // signal to the draw function that the window is being closed
                w.signal = .Should_Close;
                w->draw_proc();
                batch_renderer_unload(&ctx^.ren, cast(Batch_Renderer_Window_ID)w.handle);
                glfw.DestroyWindow(w.handle);
                ordered_remove(&queue^.windows, i);
                l -= 1;
            }
        }
        batch_renderer_reset(&ctx^.ren);
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
get_image_id :: #force_inline proc(img_path: string) -> u32 {
    return batch_renderer_handle_image_request(&get_context()^.ren, img_path);
}

/**
 * @brief resets registered renderer's texture ID to new location
 * @param img_path path to the original img
 * @param new_img_id new OpenGL texture2D id
 */
reset_image_id :: #force_inline proc(img_path: string, new_img_id: u32) {
    batch_renderer_invalidate_image_and_reset(&get_context()^.ren, img_path, new_img_id);
}

destroy :: proc() {
    ctx := get_context();

	glfw.Terminate();
    batch_renderer_delete(&ctx^.ren);
    for w in ctx^.queue.windows {
        destroy_window(w);
    }
    delete_dynamic_array(ctx^.queue.windows);
    delete_dynamic_array(ctx^.queue.commands);
    free(ctx);
}