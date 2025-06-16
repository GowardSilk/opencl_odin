/**
 * @file ui_batch.odin
 *
 * @brief contains Batch renderer facilities for enqueuing draw calls and then their subsequent construction (aka batched render)
 *
 * @todo consider "concatenating" `shaders' and `vaos' members with one allocator with views bound to the respective structures so that we avoid this incremental need for multiple dynarrays
 *
 * @ingroup ui
 *
 * @author GowardSilk
 */
package ui;

import "core:c"
import "core:c/libc"
import "core:log"
import "core:strings"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

FONT_DIR :: "video/resources/fonts";

Batch_Renderer_Window_ID :: distinct uintptr;

@(private="file")
Image_Vertex :: struct {
    pos: [2]f32,
    uv: [2]f32,
}
Image_Vertex_Buffer :: struct {
    vbo: u32,
    texture: u32,              /**< OpenGL texture ID */
    // note: this will be convenient to store because we will not
    // hold the whole CPU image for the entire runtime
    width: f32,               /**< width of the (whole) texture (in pixels) */
    height: f32,              /**< height of the (whole) texture (in pixels) */
    window_id: Batch_Renderer_Window_ID, /**< index at which the image was registered (since images are rendered per-frame and not per window, we need to remember its origin) */
    dirty_flag: bool,         /**< marks this image to be rendered */
}
Image_Buffer :: struct {
    image_vertices: map[string]Image_Vertex_Buffer,
}
Image_Batch :: struct {
    using image: Image_Buffer,
    using font: Font_Atlas,
}

Font_Atlas_Vertex_Buffer :: struct {
    // shared across windows
    vbo: u32,
    vertices: [dynamic]Image_Vertex,
    ibo: u32,
    indexes: [dynamic]u32,
}
Font_Atlas_Buffer :: struct {
    batch: Font_Atlas_Vertex_Buffer, /**< batch of all `vertices' */
    texture: u32,         /**< OpenGL texture ID */
    width: f32,           /**< width of the (whole) texture (in pixels) */
    height: f32,          /**< height of the (whole) texture (in pixels) */
}
Font_Atlas :: struct {
    angel_spec: AngelFNT_File,
    font_atlas: Font_Atlas_Buffer,
}

Rect_Vertex :: f32;
Rect_Vertex_Buffer :: struct {
    // shared across windows:
    vbo: u32,
    vertices: [dynamic]Rect_Vertex,
    ibo: u32,
    indexes: [dynamic]u32,
}
Rect_Batch :: struct {
    using vertex: Rect_Vertex_Buffer,
}

PERWINDOW_VAO_RECT_IDX       :: 0;
PERWINDOW_VAO_IMAGE_IDX      :: 1;
PERWINDOW_VAO_FONT_ATLAS_IDX :: 2;
Batch_Renderer_PerWindow_Memory :: struct {
    vaos: [3]u32,

    font_program: u32,
    image_program: u32,
    rect_program: u32,
}

/** @brief contains all batched buffers for one Window render */
Batch_Renderer :: struct {
    rects: Rect_Batch, /**< batch for rectangular objects (aka Quads) */
    images: Image_Batch, /**< batch for image objects (+ fonts since we use texture fonts) */
    perwindow: map[Batch_Renderer_Window_ID]Batch_Renderer_PerWindow_Memory, /**< perwindow data that cannot be shared among OpenGL contexts */
}

@(private="file")
shader_load :: proc(src: []c.uint32_t, kind: u32) -> (id: u32, err: General_Error) {
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
shader_link :: proc(vs: u32, fs: u32) -> (program: u32, err: General_Error) {
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
shader_assemble :: #force_inline proc(vertex_src: []c.uint32_t, pixel_src: []c.uint32_t) -> (prg: u32, err: General_Error) {
    vs := shader_load(vertex_src, gl.VERTEX_SHADER) or_return;
    fs := shader_load(pixel_src, gl.FRAGMENT_SHADER) or_return;
    return shader_link(vs, fs);
}

@(private="file")
FONT_VERTEX_SRC  :: #load("../resources/shaders/font.vert.spv", []c.uint32_t);
@(private="file")
FONT_PIXEL_SRC   :: #load("../resources/shaders/font.frag.spv", []c.uint32_t);
@(private="file")
IMG_VERTEX_SRC  :: #load("../resources/shaders/img.vert.spv", []c.uint32_t);
@(private="file")
IMG_PIXEL_SRC   :: #load("../resources/shaders/img.frag.spv", []c.uint32_t);
@(private="file")
RECT_VERTEX_SRC :: #load("../resources/shaders/rect.vert.spv", []c.uint32_t);
@(private="file")
RECT_PIXEL_SRC  :: #load("../resources/shaders/rect.frag.spv", []c.uint32_t);

batch_renderer_new :: proc(id: Batch_Renderer_Window_ID) -> (ren: Batch_Renderer, err: General_Error) {
    // rects
    gl.GenBuffers(1, &ren.rects.vbo);
    ren.rects.vertices = make([dynamic]Rect_Vertex) or_return;

    gl.GenBuffers(1, &ren.rects.ibo);
    ren.rects.indexes = make([dynamic]u32) or_return;

    // perwindow mem
    ren.perwindow = make(map[Batch_Renderer_Window_ID]Batch_Renderer_PerWindow_Memory);
    perwindow: Batch_Renderer_PerWindow_Memory;
    perwindow.font_program = shader_assemble(FONT_VERTEX_SRC, FONT_PIXEL_SRC) or_return;
    perwindow.image_program = shader_assemble(IMG_VERTEX_SRC, IMG_PIXEL_SRC) or_return;
    perwindow.rect_program = shader_assemble(RECT_VERTEX_SRC, RECT_PIXEL_SRC) or_return;
    gl.GenVertexArrays(len(perwindow.vaos), &perwindow.vaos[0]);
    map_insert(&ren.perwindow, id, perwindow);

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
    stbi.set_flip_vertically_on_load(1);
    img := stbi.load(strings.clone_to_cstring(cast(string)img_path, context.temp_allocator), &x, &y, nil, 4);
    delete(img_path);
    defer libc.free(img);

    gl.GenTextures(1, &ren.images.font_atlas.texture);
    gl.BindTexture(gl.TEXTURE_2D, ren.images.font_atlas.texture);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,
        x, y, 0,
        gl.RGBA, gl.UNSIGNED_BYTE, img);
    
    gl.GenBuffers(1, &ren.images.font_atlas.batch.vbo);
    gl.GenBuffers(1, &ren.images.font_atlas.batch.ibo);
    ren.images.font_atlas.batch.vertices = make([dynamic]Image_Vertex);
    ren.images.font_atlas.batch.indexes = make([dynamic]u32);
    ren.images.font_atlas.width = cast(f32)x;
    ren.images.font_atlas.height = cast(f32)y;

    return ren, err;
}

/** @brief generates new pipeline for a new window, but keeps all other objects intact (shared) across them */
batch_renderer_clone :: proc(ren: ^Batch_Renderer, id: Batch_Renderer_Window_ID) -> (err: General_Error) {
    assert(!(id in ren^.perwindow));

    perwindow: Batch_Renderer_PerWindow_Memory;

    // VAOs
    gl.GenVertexArrays(len(perwindow.vaos), &perwindow.vaos[0]);

    // shaders
    perwindow.font_program = shader_assemble(FONT_VERTEX_SRC, FONT_PIXEL_SRC) or_return;
    perwindow.image_program = shader_assemble(IMG_VERTEX_SRC, IMG_PIXEL_SRC) or_return;
    perwindow.rect_program = shader_assemble(RECT_VERTEX_SRC, RECT_PIXEL_SRC) or_return;

    map_insert(&ren^.perwindow, id, perwindow);

    return nil;
}

batch_renderer_unload :: proc(ren: ^Batch_Renderer, id: Batch_Renderer_Window_ID) {
    e, ok := ren^.perwindow[id];
    log.assertf(ok, "Trying to unload resource with window id: %d; which does not exist!", id);

    gl.DeleteVertexArrays(len(e.vaos), &e.vaos[0]);

    gl.DeleteProgram(e.image_program);
    gl.DeleteProgram(e.rect_program);
    gl.DeleteProgram(e.font_program);
}

batch_renderer_add_button :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Button) {
    // add rect
    {
        base_index := cast(u32)len(ren^.rects.vertices) / 2;

        // CCW
        append(&ren^.rects.vertices,
            cmd.rect.x1, cmd.rect.y1, // Bottom-left
            cmd.rect.x2, cmd.rect.y1, // Bottom-right
            cmd.rect.x2, cmd.rect.y2, // Top-right
            cmd.rect.x1, cmd.rect.y2, // Top-left
        );
        append(&ren^.rects.indexes,
            base_index + 0, base_index + 1, base_index + 2,
            base_index + 2, base_index + 3, base_index + 0,
        );
    }
    batch_renderer_add_text(ren, cmd.text);
}

batch_renderer_add_text :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Text) {
    pos := cmd.pos;
    scale := cmd.size.y / cast(f32)ren^.images.angel_spec.common.line_height;
    atlas_width, atlas_height := ren^.images.font_atlas.width, ren^.images.font_atlas.height;

    for c in cmd.text {
        angel_char: ^AngelBlock_Char = nil;
        for &ac in ren^.images.angel_spec.chars {
            if ac.id == cast(u32)c {
                angel_char = &ac;
                break;
            }
        }
        assert(angel_char != nil);

        glyph_w := cast(f32)angel_char.width * scale;
        glyph_h := cast(f32)angel_char.height * scale;

        xpos := cast(f32)pos.x + angel_char.x_offset * scale;
        ypos := cast(f32)pos.y + (ren^.images.angel_spec.common.base - angel_char.y_offset) * scale;

        uv_rect := Rect {
            x1 = cast(f32)angel_char.x / atlas_width,
            y1 = 1 - cast(f32)angel_char.y / atlas_height,
            x2 = (cast(f32)angel_char.x + cast(f32)angel_char.width) / atlas_width,
            y2 = 1 - (cast(f32)angel_char.y + cast(f32)angel_char.height) / atlas_height,
        };

        r_ndc := pos_to_ndc(create_rect({xpos, ypos}, {glyph_w, glyph_h}));

        base_index := cast(u32)len(ren^.images.font_atlas.batch.vertices);
        append(&ren^.images.font_atlas.batch.vertices,
            Image_Vertex { { r_ndc.x1, r_ndc.y1 }, { uv_rect.x1, uv_rect.y1 }, }, // Bottom-left
            Image_Vertex { { r_ndc.x2, r_ndc.y1 }, { uv_rect.x2, uv_rect.y1 }, }, // Bottom-right
            Image_Vertex { { r_ndc.x2, r_ndc.y2 }, { uv_rect.x2, uv_rect.y2 }, }, // Top-right
            Image_Vertex { { r_ndc.x1, r_ndc.y2 }, { uv_rect.x1, uv_rect.y2 }, }, // Top-left
        );
        append(&ren^.images.font_atlas.batch.indexes,
            base_index + 0, base_index + 1, base_index + 2,
            base_index + 2, base_index + 3, base_index + 0,
        );

        pos.x += cast(i32)(angel_char.x_advance * scale);
    }
}

/**
 * @brief images registered via file path (cached) such that every already registered image is going to be re-rendered
 *      and every new one is going to be loaded, cropped, and GPU-registered
 * @param img_pos is a position of the top left corner where the image should be located (window coords)
 * @param active_index is a unique index of the active window at which the image registration was called
 * @param uv_rect is a UV rectangle, marking area which is going to be displayed on the screen
 * @param img_path is path to the image desired to (re)load
 * @note if the function finds already existing image with the img_path, it will still update vertices and crop the image anew
 */
batch_renderer_register_image :: proc(ren: ^Batch_Renderer, id: Batch_Renderer_Window_ID, img_pos: [2]i32, uv_rect: Rect, img_path: string) -> (err: General_Error) {
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

        e^.width = cast(f32)img.width;
        e^.height = cast(f32)img.height;
        e^.texture = texture;
        e^.window_id = id;
    }
    e^.dirty_flag = true;

    // add image rectangle
    log.assertf(e^.window_id == id, "Image was created in a window: %d; but is updated through: %d. TODO: Do we consider this an issue?", e^.window_id, id);
    {
        img_size := [2]f32 { cast(f32)e^.width, cast(f32)e^.height, };
        img_fpos := [2]f32 { cast(f32)img_pos.x, cast(f32)img_pos.y, };
        r_ndc := pos_to_ndc(create_rect(img_fpos, img_size));

        vertices: [6]Image_Vertex;
        vertices[0] = { { r_ndc.x1, r_ndc.y1 }, { uv_rect.x1, uv_rect.y2 }, }; // Bottom-left
        vertices[1] = { { r_ndc.x2, r_ndc.y1 }, { uv_rect.x2, uv_rect.y2 }, }; // Bottom-right
        vertices[2] = { { r_ndc.x2, r_ndc.y2 }, { uv_rect.x2, uv_rect.y1 }, }; // Top-right

        vertices[3] = { { r_ndc.x2, r_ndc.y2 }, { uv_rect.x2, uv_rect.y1 }, }; // Top-right
        vertices[4] = { { r_ndc.x1, r_ndc.y2 }, { uv_rect.x1, uv_rect.y1 }, }; // Top-left
        vertices[5] = { { r_ndc.x1, r_ndc.y1 }, { uv_rect.x1, uv_rect.y2 }, }; // Bottom-left

        if !ok do gl.GenBuffers(1, &e^.vbo); // only generate buffer if entry does not yet exist
        gl.BindBuffer(gl.ARRAY_BUFFER, e^.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(Image_Vertex), &vertices[0], gl.DYNAMIC_DRAW);
    }

    return nil;
}

batch_renderer_construct :: proc(ren: ^Batch_Renderer, id: Batch_Renderer_Window_ID) {
    perwindow, ok := ren^.perwindow[id];
    log.assertf(ok, "Window of ID: %d is not registered!", id);

    // render rect(s)
    {
        gl.UseProgram(perwindow.rect_program);

        gl.BindVertexArray(perwindow.vaos[PERWINDOW_VAO_RECT_IDX]);

        gl.BindBuffer(gl.ARRAY_BUFFER, ren^.rects.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(ren^.rects.vertices) * size_of(Rect_Vertex), raw_data(ren^.rects.vertices), gl.DYNAMIC_DRAW);

        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ren^.rects.ibo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(ren^.rects.indexes) * size_of(u32), raw_data(ren^.rects.indexes), gl.DYNAMIC_DRAW);

        gl.EnableVertexAttribArray(0);
        gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * size_of(f32), 0);

        gl.DrawElements(gl.TRIANGLES, cast(i32)len(ren^.rects.indexes), gl.UNSIGNED_INT, nil);
    }

    // render image(s)
    {
        gl.UseProgram(perwindow.image_program);

        gl.BindVertexArray(perwindow.vaos[PERWINDOW_VAO_IMAGE_IDX]);

        for k, v in ren^.images.image_vertices {
            if v.window_id == id { // only render images originally created in the window
                gl.BindTexture(gl.TEXTURE_2D, v.texture);
                gl.BindBuffer(gl.ARRAY_BUFFER, v.vbo);

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
        gl.UseProgram(perwindow.font_program);

        font_atlas := ren^.images.font_atlas;
        gl.BindVertexArray(perwindow.vaos[PERWINDOW_VAO_FONT_ATLAS_IDX]);

        gl.BindTexture(gl.TEXTURE_2D, font_atlas.texture);

        gl.BindBuffer(gl.ARRAY_BUFFER, font_atlas.batch.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(font_atlas.batch.vertices) * size_of(Image_Vertex), raw_data(font_atlas.batch.vertices), gl.DYNAMIC_DRAW);

        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, font_atlas.batch.ibo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(font_atlas.batch.indexes) * size_of(u32), raw_data(font_atlas.batch.indexes), gl.DYNAMIC_DRAW);

        gl.VertexAttribPointer(0, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, pos));
        gl.EnableVertexAttribArray(0);

        gl.VertexAttribPointer(1, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, uv));
        gl.EnableVertexAttribArray(1);

        gl.DrawElements(gl.TRIANGLES, cast(i32)len(font_atlas.batch.indexes), gl.UNSIGNED_INT, nil);
    }
}

/** @brief clear called every WINDOW DRAW (multiple times per frame) */
batch_renderer_clear :: proc(ren: ^Batch_Renderer) {
    clear(&ren^.rects.vertices);
    clear(&ren^.rects.indexes);

    clear(&ren^.images.font_atlas.batch.vertices);
    clear(&ren^.images.font_atlas.batch.indexes);
}

/** @brief reset called every FRAME */
batch_renderer_reset :: proc(ren: ^Batch_Renderer) {
    // do a cycle, checking out all of the images which are not used
    for k, &v in ren^.images.image_vertices {
        if !v.dirty_flag do batch_renderer_delete_texture(ren, k);
        else do v.dirty_flag = false; // all images will be marked as unsused by default, that way we can checkout the ones which will be left untouched the next frame
    }
}

@(private="file")
batch_renderer_delete_texture :: proc(ren: ^Batch_Renderer, k: string) {
    v, ok := ren^.images.image_vertices[k];
    assert(ok);
    gl.DeleteTextures(1, &v.texture);
    gl.DeleteBuffers(1, &v.vbo);
    delete_key(&ren^.images.image_vertices, k);
}

batch_renderer_delete :: proc(ren: ^Batch_Renderer) {
    // perwindow memory
    for _, &perwindow in ren^.perwindow {
        gl.DeleteVertexArrays(len(perwindow.vaos), &perwindow.vaos[0]);
        gl.DeleteProgram(perwindow.font_program);
        gl.DeleteProgram(perwindow.image_program);
        gl.DeleteProgram(perwindow.rect_program);
    }
    delete(ren^.perwindow);

    // vertex buffer constructor
    delete(ren^.rects.vertices);
    delete(ren^.rects.indexes);
    buffers := [2]u32 { ren^.rects.vbo, ren^.rects.ibo };
    gl.DeleteBuffers(2, &buffers[0]);

    // image buffer(s)
    for k in ren^.images.image_vertices do batch_renderer_delete_texture(ren, k);
    delete(ren^.images.image_vertices);

    // font atlas
    buffers.xy = { ren^.images.font_atlas.batch.vbo, ren^.images.font_atlas.batch.ibo };
    gl.DeleteBuffers(2, &buffers[0]);
    delete(ren^.images.font_atlas.batch.vertices);
    delete(ren^.images.font_atlas.batch.indexes);
    gl.DeleteTextures(1, &ren^.images.font_atlas.texture);
    angel_delete(&ren^.images.angel_spec);
}
