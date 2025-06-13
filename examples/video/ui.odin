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
import "core:mem"
import "core:image"

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

@(private="file")
Window_Index :: distinct uint;

Draw_Command_Text :: struct {
    text: string,
    size: c.double,
}
Draw_Command_Button :: struct {
    text: Draw_Command_Text,
    rect: Rect,
}
Draw_Command_Image :: struct {
    img: u32,
    rect: Rect,
}
Draw_Command :: union {
    Draw_Command_Button,
    Draw_Command_Text,
    Draw_Command_Image,
}
Draw_Command_Queue :: struct {
    commands: [dynamic]Draw_Command,
    windows: [dynamic]Window,
    active_window: Window_Index,
}

@(private="file")
Vertex_Buffer_Constructor :: struct {
    vao: u32,
    vbo: u32,
    vertices: [dynamic]f32,

    ibo: u32,
    indexes: [dynamic]u32,
}
@(private="file")
Image_Buffer_Constructor :: struct {
    images: [dynamic]u32,
}
@(private="file")
Shader_Program_Constructor :: struct {
    vs: u32,
    ps: u32,
    program: u32,
}
@(private="file")
Font_Atlas_Constructor :: struct {
    font_buf: ^u32, /**< view to the (first) image in the Image_Buffer_Constructor */
}
/** @brief contains all batched buffers for one Window render */
@(private="file")
Batch_Renderer :: struct {
    using vertex_ctor: Vertex_Buffer_Constructor,
    using shader_ctor: Shader_Program_Constructor,
    using image_ctor:  Image_Buffer_Constructor,
    using font_ctor:   Font_Atlas_Constructor,
}

Draw_Context :: struct {
    queue: Draw_Command_Queue,
    ren: Batch_Renderer,
}

@(private="file")
get_context :: #force_inline proc() -> ^Draw_Context {
    return cast(^Draw_Context)context.user_ptr;
}

@(private="file")
batch_renderer_new :: proc() -> (ren: Batch_Renderer, err: runtime.Allocator_Error) {
    // vertices/indexes
    gl.GenVertexArrays(1, &ren.vao);

    gl.GenBuffers(1, &ren.vbo);
    ren.vertices = make([dynamic]f32) or_return;

    gl.GenBuffers(1, &ren.ibo);
    ren.indexes = make([dynamic]u32) or_return;

    vertex_src := #load("vert.glsl", cstring);
    pixel_src  := #load("pix.glsl", cstring);

    // shaders
    ok: bool;
    ren.vs, ok = shader_compile(&vertex_src, gl.VERTEX_SHADER);
    if !ok do return ren, .Invalid_Argument;
    ren.ps, ok = shader_compile(&pixel_src, gl.FRAGMENT_SHADER);
    if !ok do return ren, .Invalid_Argument;
    ren.program, ok = shader_link(ren.vs, ren.ps);
    if !ok do return ren, .Invalid_Argument;

    // images
    ren.images = make([dynamic]u32) or_return;

    // font atlas
    /*
    img, imgerr := load_image("font.bmp");
    if imgerr != nil do return ren, .Invalid_Argument;
    gl.GenTextures(1, &ren.images[0]);
    gl.BindTexture(gl.TEXTURE_2D, ren.images[0]);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,
        cast(i32)img.width, cast(i32)img.height, 0,
        gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));
    ren.font_buf = &ren.images[0];
    */

    return ren, err;
}

@(private="file")
_batch_renderer_add_rect :: proc(ren: ^Batch_Renderer, r: Rect) {
    base_index := cast(u32)len(ren^.vertices) / 2;

    // CCW
    append(&ren^.vertices,
        r.x1, r.y1, // Bottom-left
        r.x2, r.y1, // Bottom-right
        r.x2, r.y2, // Top-right
        r.x1, r.y2, // Top-left
    );
    append(&ren^.indexes,
        base_index + 0, base_index + 1, base_index + 2,
        base_index + 2, base_index + 3, base_index + 0,
    );
}

@(private="file")
batch_renderer_add_button :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Button) {
    _batch_renderer_add_rect(ren, cmd.rect);
    batch_renderer_add_text(ren, cmd.text);
}

@(private="file")
batch_renderer_add_text :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Text) {
    // todo: we need to grab for each character its appropriate offset
    // then load it sequentially (via glTexSubImage2D??)
    // for c in cmd.text {
    // }
}

@(private="file")
batch_renderer_add_image :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Image) {
    _batch_renderer_add_rect(ren, cmd.rect);
    // note: image data must have been passed preemptively
}

@(private="file")
batch_renderer_add :: proc { batch_renderer_add_button, batch_renderer_add_text, batch_renderer_add_image }

@(private="file")
batch_renderer_construct :: proc(ren: ^Batch_Renderer) {
    gl.UseProgram(ren^.program);

    gl.BindVertexArray(ren^.vao);

    gl.BindBuffer(gl.ARRAY_BUFFER, ren^.vbo);
    gl.BufferData(gl.ARRAY_BUFFER, len(ren^.vertices) * size_of(f32), raw_data(ren^.vertices), gl.DYNAMIC_DRAW);

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ren^.ibo);
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(ren^.indexes) * size_of(u32), raw_data(ren^.indexes), gl.DYNAMIC_DRAW);

    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * size_of(f32), 0);

    gl.DrawElements(gl.TRIANGLES, cast(i32)len(ren^.indexes), gl.UNSIGNED_INT, nil);
}

@(private="file")
batch_renderer_clear :: proc(ren: ^Batch_Renderer) {
    clear(&ren^.vertices);
    clear(&ren^.indexes);
}

@(private="file")
batch_renderer_delete :: proc(ren: ^Batch_Renderer) {
    // vertex buffer constructor
    delete(ren^.vertices);
    delete(ren^.indexes);
    buffers := [2]u32 { ren^.vbo, ren^.ibo };
    gl.DeleteBuffers(2, &buffers[0]);
    gl.DeleteVertexArrays(1, &ren^.vao);

    // image buffer constructor + font atlas constructor
    gl.DeleteTextures(cast(i32)len(ren^.images), raw_data(ren^.images));
    delete(ren^.images);
    ren^.font_buf = nil;

    // shader program constructor
    gl.DeleteProgram(ren^.program);
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
	
	window_handle := glfw.CreateWindow(size.x, size.y, name, nil, nil);

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

ui_register_window :: proc(size: [2]c.int, name: cstring, draw: Draw_Proc) -> bool {
    w := ui_prepare_window(size, name);
    if w.handle == nil do return false;
    w.draw_proc = draw;
    
    // deferred batch renderer initialization
    ctx := get_context();
    if ctx^.ren.ps == 0 && ctx^.ren.vs == 0 {
        err: runtime.Allocator_Error;
        ctx^.ren, err = batch_renderer_new();
        if err != .None do return false;
    }

    append(&ctx^.queue.windows, w);

    return true;
}

@(private="file")
shader_compile :: proc(src: ^cstring, kind: u32) -> (id: u32, ok: bool) {
    shader := gl.CreateShader(kind);
    gl.ShaderSource(shader, 1, src, nil);
    gl.CompileShader(shader);

    success: i32;
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, cast([^]i32)&success);
    if success == 0 {
        log.error("Failed to compile shader!");
        return 0, false;
    }
    return shader, true;
};

@(private="file")
shader_link :: proc(vs: u32, fs: u32) -> (program: u32, ok: bool) {
    program = gl.CreateProgram();
    gl.AttachShader(program, vs);
    gl.AttachShader(program, fs);
    gl.LinkProgram(program);
    if program == 0 {
        info: [512]u8;
        gl.GetProgramInfoLog(program, 512, nil, &info[0]);
        log.errorf("Linker error: %s", info);
        return 0, false;
    }
    gl.DeleteShader(vs);
    gl.DeleteShader(fs);
    return program, true;
};

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

@(private="file")
Rect32 :: struct { x1, y1: f32, x2, y2: f32 }
@(private="file")
Rect :: Rect32;
@(private="file")
Rect64 :: struct { x1, y1: c.double, x2, y2: c.double }
@(private="file")
ui_is_inside_widget :: #force_inline proc(r: Rect64, point: [2]c.double) -> bool{
    return point.x >= r.x1 && point.y >= r.y1 && point.x <= r.x2 && point.y <= r.y2;
}

@(private="file")
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

@(private="file")
ui_create_rect :: #force_inline proc(pos: [2]f32, sz: [2]f32) -> Rect {
    return Rect {
        pos.x, pos.y,
        pos.x + sz.x, pos.y + sz.y,
    };
}

@(private="file")
ui_create_rect64 :: proc(pos: [2]c.double, sz: [2]c.double) -> Rect64 {
    return Rect64 {
        pos.x, pos.y,
        pos.x + sz.x, pos.y + sz.y,
    };
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
        Draw_Command_Text { name, active_window.cursor.font_size },
        r_ndc,
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

ui_draw_image :: #force_inline proc(img: Image) {
    draw_cmd := Draw_Command_Image {};

    img_pos  := ui_draw_cursor_current();
    img_size := [2]f32 { cast(f32)img.width, cast(f32)img.height };
    draw_cmd.rect = ui_create_rect(
        [2]f32 { cast(f32)img_pos.x, cast(f32)img_pos.y },
        img_size,
    );
    defer ui_draw_cursor_button_next(); // move to the next "slot"

    gl.GenTextures(1, &draw_cmd.img);
    gl.BindTexture(gl.TEXTURE_2D, draw_cmd.img);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,
        cast(i32)img.width, cast(i32)img.height, 0,
        gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));

    ui_register_draw_command(draw_cmd);
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
            case Draw_Command_Button:  batch_renderer_add(ren, c);
            case Draw_Command_Text:    batch_renderer_add(ren, c);
            case Draw_Command_Image:   batch_renderer_add(ren, c);
        }
    }

    batch_renderer_construct(ren);
}

ui_draw :: proc() {
    queue := &get_context()^.queue;

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
                ordered_remove(&queue^.windows, index);
                l -= 1;
            }
        }
    }
}

ui_reset_state :: proc() {
    ctx := get_context();

    ui_draw_cursor_reset();
    clear(&ctx^.queue.commands);
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