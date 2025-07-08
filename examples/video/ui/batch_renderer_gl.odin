/**
 * @file batch_renderer_gl.odin
 *
 * @brief
 *
 * @ingroup ui
 *
 * @author GowardSilk
 */
package ui;

import "core:c"
import "core:log"
import "core:c/libc"
import "core:strings"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

Image_Vertex_Buffer_GL :: struct {
    vbo: u32, /**< ID of buffer of vertices */
    texture: u32, /**< OpenGL texture ID */

    // NOTE(GowardSilk): this will be convenient to store because we will 
    // not hold the whole CPU image for the entire runtime
    width: f32,               /**< width of the (whole) texture (in pixels) */
    height: f32,              /**< height of the (whole) texture (in pixels) */
}

Font_Atlas_Vertex_Buffer_GL :: struct {
    // shared across windows
    vbo:        u32,
    vertices:   [dynamic]Image_Vertex,
    ibo:        u32,
    indexes:    [dynamic]u32,
}

Font_Atlas_Texture_Buffer_GL :: struct {
    texture:    u32, /**< OpenGL texture ID */

    width:      f32, /**< width of the (whole) texture (in pixels) */
    height:     f32, /**< height of the (whole) texture (in pixels) */
}

Rect_Vertex_Buffer_GL :: struct {
    // shared across windows:
    vbo: u32,
    vertices: [dynamic]Rect_Vertex,
    ibo: u32,
    indexes: [dynamic]u32,
}

PERWINDOW_VAO_RECT_IDX       :: 0;
PERWINDOW_VAO_IMAGE_IDX      :: 1;
PERWINDOW_VAO_FONT_ATLAS_IDX :: 2;
PerWindow_Memory_GL :: struct {
    vaos: [3]u32,

    font_program: u32,
    image_program: u32,
    rect_program: u32,
}

Image_Request_Result_GL :: u32;

@(private="file")
shader_load_gl :: proc(src: []c.uint32_t, kind: u32) -> (id: u32, err: General_Error) {
    shader := gl.CreateShader(kind);
    gl.ShaderBinary(1, &shader, gl.SHADER_BINARY_FORMAT_SPIR_V, 
                raw_data(src), cast(i32)len(src) * size_of(c.uint32_t));
    gl.SpecializeShader(shader, "main", 0, nil, nil);

    success: i32;
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, cast([^]i32)&success);
    if success == 0 {
        length: i32;
        gl.GetShaderiv(shader, gl.INFO_LOG_LENGTH, &length);
        info_log := make([]byte, length + 1);
        defer delete(info_log);
        gl.GetShaderInfoLog(shader, length, nil, &info_log[0]);
        log.errorf("Failed to compile shader! Log: %s", cast(string)info_log);
        gl.DeleteShader(shader);
        return 0, .Shader_Compile;
    }
    return shader, nil; 
}

@(private="file")
shader_link_gl :: proc(vs: u32, fs: u32) -> (program: u32, err: General_Error) {
    program = gl.CreateProgram();
    gl.AttachShader(program, vs);
    gl.AttachShader(program, fs);
    gl.LinkProgram(program);
    if program == 0 {
        info: [512]u8;
        gl.GetProgramInfoLog(program, 512, nil, &info[0]);
        log.errorf("Linker error: %s", info);
        return 0, .Shader_Program_Link;
    }
    gl.DeleteShader(vs);
    gl.DeleteShader(fs);
    return program, nil;
}

@(private="file")
shader_assemble_gl :: #force_inline proc(vertex_src: []c.uint32_t, pixel_src: []c.uint32_t) -> (prg: u32, err: General_Error) {
    vs := shader_load_gl(vertex_src, gl.VERTEX_SHADER) or_return;
    fs := shader_load_gl(pixel_src, gl.FRAGMENT_SHADER) or_return;
    return shader_link_gl(vs, fs);
}

@(private="file")
FONT_VERTEX_SRC_GL  :: #load("../resources/shaders/font.vert.spv", []c.uint32_t);
@(private="file")
FONT_PIXEL_SRC_GL   :: #load("../resources/shaders/font.frag.spv", []c.uint32_t);
@(private="file")
IMG_VERTEX_SRC_GL  :: #load("../resources/shaders/img.vert.spv", []c.uint32_t);
@(private="file")
IMG_PIXEL_SRC_GL   :: #load("../resources/shaders/img.frag.spv", []c.uint32_t);
@(private="file")
RECT_VERTEX_SRC_GL :: #load("../resources/shaders/rect.vert.spv", []c.uint32_t);
@(private="file")
RECT_PIXEL_SRC_GL  :: #load("../resources/shaders/rect.frag.spv", []c.uint32_t);

batch_renderer_new_gl :: proc(id: Window_ID) -> (ren: Batch_Renderer, err: General_Error) {
    ren.backend = .GL;

    // rects
    gl.GenBuffers(1, &ren.rects.gl.vbo);
    ren.rects.gl.vertices = make([dynamic]Rect_Vertex) or_return;

    gl.GenBuffers(1, &ren.rects.gl.ibo);
    ren.rects.gl.indexes = make([dynamic]u32) or_return;

    // perwindow mem
    ren.perwindow = make(map[Window_ID]PerWindow_Memory);
    batch_renderer_clone_gl(&ren, id);

    // images
    ren.images.image_vertices = make(map[string]Image_Vertex_Buffer);

    // font atlas
    ok: bool;
    ren.images.angel_spec, ok = angel_read("video/resources/fonts/font.fnt");
    if !ok do return ren, .Angel_Read;
    if len(ren.images.angel_spec.pages) > 1 {
        log.error("Angel fnt contains MORE than ONE page (now not supported)!");
        return ren, .Angel_Read;
    }
    // TODO cleanup: either STBI or core:image/png
    img_path := make([]byte, len(FONT_DIR) + 1 + len(ren.images.angel_spec.pages[0].file_name));
    copy_from_string(img_path, FONT_DIR);
    img_path[len(FONT_DIR)] = '/';
    copy_from_string(img_path[len(FONT_DIR) + 1:], ren.images.angel_spec.pages[0].file_name);
    x, y: libc.int;
    img := stbi.load(strings.clone_to_cstring(cast(string)img_path, context.temp_allocator), &x, &y, nil, 4);
    delete(img_path);
    defer libc.free(img);

    gl.GenTextures(1, &ren.images.font_atlas.base.gl.texture);
    gl.BindTexture(gl.TEXTURE_2D, ren.images.font_atlas.base.gl.texture);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,
        x, y, 0,
        gl.RGBA, gl.UNSIGNED_BYTE, img);

    gl.GenBuffers(1, &ren.images.font_atlas.batch.gl.vbo);
    gl.GenBuffers(1, &ren.images.font_atlas.batch.gl.ibo);
    ren.images.font_atlas.batch.gl.vertices = make([dynamic]Image_Vertex);
    ren.images.font_atlas.batch.gl.indexes = make([dynamic]u32);
    ren.images.font_atlas.base.gl.width = cast(f32)x;
    ren.images.font_atlas.base.gl.height = cast(f32)y;

    return ren, err;
}

batch_renderer_clone_gl :: proc(ren: ^Batch_Renderer, id: Window_ID) -> (err: General_Error) {
    assert(id not_in ren^.perwindow);

    perwindow: PerWindow_Memory_GL;

    // VAOs
    gl.GenVertexArrays(len(perwindow.vaos), &perwindow.vaos[0]);

    // shaders
    perwindow.font_program = shader_assemble_gl(FONT_VERTEX_SRC_GL, FONT_PIXEL_SRC_GL) or_return;
    perwindow.image_program = shader_assemble_gl(IMG_VERTEX_SRC_GL, IMG_PIXEL_SRC_GL) or_return;
    perwindow.rect_program = shader_assemble_gl(RECT_VERTEX_SRC_GL, RECT_PIXEL_SRC_GL) or_return;

    map_insert(&ren^.perwindow, id, PerWindow_Memory{gl=perwindow});

    return nil;
}

batch_renderer_unload_gl :: proc(ren: ^Batch_Renderer, id: Window_ID) {
    e, ok := ren^.perwindow[id];
    log.assertf(ok, "Trying to unload resource with window id: %d; which does not exist!", id);

    gl.DeleteVertexArrays(len(e.gl.vaos), &e.gl.vaos[0]);

    gl.DeleteProgram(e.gl.image_program);
    gl.DeleteProgram(e.gl.rect_program);
    gl.DeleteProgram(e.gl.font_program);

    delete_key(&ren^.perwindow, id);
}

batch_renderer_register_image_gl :: proc(ren: ^Batch_Renderer, id: Window_ID, img_pos: [2]i32, uv_rect: Rect, img_path: string) -> (err: General_Error) {
    e, ok := &ren^.images.image_vertices[img_path];
    if !ok {
        img := load_image(img_path) or_return;
        defer delete_image(img);

        // add texture
        texture: u32;
        gl.GenTextures(1, &texture);
        e = map_insert(&ren^.images.image_vertices, img_path, Image_Vertex_Buffer {});
        gl.BindTexture(gl.TEXTURE_2D, texture);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        assert(img.channels >= 3);
        format: i32;
        if img.channels == 3 do format = gl.RGB;
        else if img.channels == 4 do format = gl.RGBA;
        gl.TexImage2D(gl.TEXTURE_2D, 0, format,
            cast(i32)img.width, cast(i32)img.height, 0,
            cast(u32)format, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));

        e^.base.gl.width = cast(f32)img.width;
        e^.base.gl.height = cast(f32)img.height;
        e^.base.gl.texture = texture;
        e^.window_id = id;
    }
    e^.dirty_flag = true;

    // add image rectangle
    log.assertf(e^.window_id == id, "Image was created in a window: %d; but is updated through: %d. TODO: Do we consider this an issue?", e^.window_id, id);
    {
        vertices := batch_renderer_register_image_rectangle_base(e^.base.gl.width, e^.base.gl.height, img_pos, uv_rect);

        if !ok do gl.GenBuffers(1, &e^.base.gl.vbo); // only generate buffer if entry does not yet exist
        gl.BindBuffer(gl.ARRAY_BUFFER, e^.base.gl.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(Image_Vertex), &vertices[0], gl.DYNAMIC_DRAW);
    }

    return nil;
}

batch_renderer_handle_image_request_gl :: proc(ren: ^Batch_Renderer, img_path: string) -> Image_Request_Result_GL {
    e, ok := ren^.images.image_vertices[img_path];
    log.assertf(ok, "Image with path: \"%s\" is not registered!", img_path);
    return e.base.gl.texture;
}

batch_renderer_invalidate_image_and_reset_gl :: #force_inline proc(ren: ^Batch_Renderer, img_path: string, new_texture_id: Image_Request_Result_GL) {
    e, ok := &ren^.images.image_vertices[img_path];
    log.assertf(ok, "Image with path: \"%s\" is not registered! Cannot invalidate an image which does not exist!", img_path);
    e^.base.gl.texture = new_texture_id;
}

batch_renderer_construct_gl :: proc(ren: ^Batch_Renderer, id: Window_ID) {
    perwindow, ok := ren^.perwindow[id];
    log.assertf(ok, "Window of ID: %d is not registered!", id);

    // render rect(s)
    {
        gl.UseProgram(perwindow.gl.rect_program);

        gl.BindVertexArray(perwindow.gl.vaos[PERWINDOW_VAO_RECT_IDX]);

        gl.BindBuffer(gl.ARRAY_BUFFER, ren^.rects.gl.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(ren^.rects.gl.vertices) * size_of(Rect_Vertex), raw_data(ren^.rects.gl.vertices), gl.DYNAMIC_DRAW);

        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ren^.rects.gl.ibo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(ren^.rects.gl.indexes) * size_of(u32), raw_data(ren^.rects.gl.indexes), gl.DYNAMIC_DRAW);

        gl.EnableVertexAttribArray(0);
        gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * size_of(Rect_Vertex), 0);

        gl.DrawElements(gl.TRIANGLES, cast(i32)len(ren^.rects.gl.indexes), gl.UNSIGNED_INT, nil);
    }

    // render image(s)
    {
        gl.UseProgram(perwindow.gl.image_program);

        gl.BindVertexArray(perwindow.gl.vaos[PERWINDOW_VAO_IMAGE_IDX]);

        for k, v in ren^.images.image_vertices {
            if v.window_id == id { // only render images originally created in the window
                gl.BindTexture(gl.TEXTURE_2D, v.base.gl.texture);
                gl.BindBuffer(gl.ARRAY_BUFFER, v.base.gl.vbo);

                gl.VertexAttribPointer(0, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, pos));
                gl.EnableVertexAttribArray(0);

                gl.VertexAttribPointer(1, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, uv));
                gl.EnableVertexAttribArray(1);

                gl.DrawArrays(gl.TRIANGLES, 0, 6); // quad
            }
        }
    }

    // render text
    {
        gl.UseProgram(perwindow.gl.font_program);

        font_atlas := ren^.images.font_atlas;
        gl.BindVertexArray(perwindow.gl.vaos[PERWINDOW_VAO_FONT_ATLAS_IDX]);

        gl.BindTexture(gl.TEXTURE_2D, font_atlas.base.gl.texture);

        gl.BindBuffer(gl.ARRAY_BUFFER, font_atlas.batch.gl.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(font_atlas.batch.gl.vertices) * size_of(Image_Vertex), raw_data(font_atlas.batch.gl.vertices), gl.DYNAMIC_DRAW);

        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, font_atlas.batch.gl.ibo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(font_atlas.batch.gl.indexes) * size_of(u32), raw_data(font_atlas.batch.gl.indexes), gl.DYNAMIC_DRAW);

        gl.VertexAttribPointer(0, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, pos));
        gl.EnableVertexAttribArray(0);

        gl.VertexAttribPointer(1, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, uv));
        gl.EnableVertexAttribArray(1);

        gl.DrawElements(gl.TRIANGLES, cast(i32)len(font_atlas.batch.gl.indexes), gl.UNSIGNED_INT, nil);
    }
}

batch_renderer_clear_gl :: proc(ren: ^Batch_Renderer) {
    clear(&ren^.rects.gl.vertices);
    clear(&ren^.rects.gl.indexes);

    clear(&ren^.images.font_atlas.batch.gl.vertices);
    clear(&ren^.images.font_atlas.batch.gl.indexes);
}

batch_renderer_reset_gl :: #force_inline proc(ren: ^Batch_Renderer) {
    batch_renderer_reset_base(ren, batch_renderer_delete_texture_gl);
}

batch_renderer_delete_texture_gl :: proc(ren: ^Batch_Renderer, img_path: string) {
    v, ok := ren^.images.image_vertices[img_path];
    assert(ok);
    gl.DeleteTextures(1, &v.base.gl.texture);
    gl.DeleteBuffers(1, &v.base.gl.vbo);
    delete_key(&ren^.images.image_vertices, img_path);
}

batch_renderer_delete_gl :: proc(ren: ^Batch_Renderer) {
    // perwindow memory
    for _, &perwindow in ren^.perwindow {
        gl.DeleteVertexArrays(len(perwindow.gl.vaos), &perwindow.gl.vaos[0]);
        gl.DeleteProgram(perwindow.gl.font_program);
        gl.DeleteProgram(perwindow.gl.image_program);
        gl.DeleteProgram(perwindow.gl.rect_program);
    }
    delete(ren^.perwindow);

    // vertex buffer constructor
    delete(ren^.rects.gl.vertices);
    delete(ren^.rects.gl.indexes);
    buffers := [2]u32 { ren^.rects.gl.vbo, ren^.rects.gl.ibo };
    gl.DeleteBuffers(2, &buffers[0]);

    // image buffer(s)
    for k in ren^.images.image_vertices do batch_renderer_delete_texture_gl(ren, k);
    delete(ren^.images.image_vertices);

    // font atlas
    buffers.xy = { ren^.images.font_atlas.batch.gl.vbo, ren^.images.font_atlas.batch.gl.ibo };
    gl.DeleteBuffers(2, &buffers[0]);
    delete(ren^.images.font_atlas.batch.gl.vertices);
    delete(ren^.images.font_atlas.batch.gl.indexes);
    gl.DeleteTextures(1, &ren^.images.font_atlas.base.gl.texture);
    angel_delete(&ren^.images.angel_spec);
}
