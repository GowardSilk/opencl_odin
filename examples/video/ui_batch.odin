/**
 * @file ui_batch.odin
 *
 * @brief contains Batch renderer facilities for enqueuing draw calls and then their subsequent construction (aka batched render)
 *
 * @ingroup video
 *
 * @author GowardSilk
 */
package video;

import "base:runtime"

import "core:log"

import gl "vendor:OpenGL"

Vertex_Buffer_Constructor :: struct {
    vao: u32,
    vbo: u32,
    vertices: [dynamic]f32,

    ibo: u32,
    indexes: [dynamic]u32,
}

Image_Buffer_Constructor :: struct {
    images: [dynamic]u32,
}

Shader_Program_Constructor :: struct {
    vs: u32,
    ps: u32,
    program: u32,
}

Font_Atlas_Constructor :: struct {
    font_buf: ^u32, /**< view to the (first) image in the Image_Buffer_Constructor */
}

/** @brief contains all batched buffers for one Window render */
Batch_Renderer :: struct {
    using vertex_ctor: Vertex_Buffer_Constructor,
    using shader_ctor: Shader_Program_Constructor,
    using image_ctor:  Image_Buffer_Constructor,
    using font_ctor:   Font_Atlas_Constructor,
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
}

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
    // img, imgerr := load_image("font.png");
    // if imgerr != nil do return ren, .Invalid_Argument;
    // gl.GenTextures(1, &ren.images[0]);
    // gl.BindTexture(gl.TEXTURE_2D, ren.images[0]);
    // gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,
    //     cast(i32)img.width, cast(i32)img.height, 0,
    //     gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));
    // ren.font_buf = &ren.images[0];

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

batch_renderer_add :: proc { batch_renderer_add_button, batch_renderer_add_text, batch_renderer_add_image }

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

batch_renderer_clear :: proc(ren: ^Batch_Renderer) {
    clear(&ren^.vertices);
    clear(&ren^.indexes);
}

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
