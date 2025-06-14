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

import "core:log"
import "core:strings"
import "core:c/libc"

import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

FONT_DIR :: "video/resources/fonts";

Vertex_Buffer_Constructor :: struct {
    vao: u32,
    vbo: u32,
    vertices: [dynamic]f32,

    ibo: u32,
    indexes: [dynamic]u32,
}

@(private="file")
Image_Vertex :: struct {
    pos: [2]f32,
    uv: [2]f32,
}
Image_Vertex_Buffer_Constructor :: struct {
    vbo: u32,
    texture: u32,              /**< OpenGL texture ID */
    // note: this will be convenient to store because we will not
    // hold the whole CPU image for the entire runtime
    width: f32,               /**< width of the font atlas (in pixels) */
    height: f32,              /**< height of the font atlas (in pixels) */
    dirty_flag: bool,         /**< marks this image to be rendered */
}
Image_Buffer_Constructor :: struct {
    vao: u32,
    image_vertices: map[string]Image_Vertex_Buffer_Constructor,
}

Shader_Program_Constructor :: struct {
    vs: u32,
    ps: u32,
    program: u32,
}

Font_Atlas_Constructor :: struct {
    angel_spec: AngelFNT_File,
}

Vertex_Batch :: struct {
    using vertex_ctor: Vertex_Buffer_Constructor,
    using shader_ctor: Shader_Program_Constructor,
}

Image_Batch :: struct {
    using image_ctor: Image_Buffer_Constructor,
    using font_ctor: Font_Atlas_Constructor,
    using shader_ctor: Shader_Program_Constructor,
}

/** @brief contains all batched buffers for one Window render */
Batch_Renderer :: struct {
    rects: Vertex_Batch,
    images: Image_Batch,
}

@(private="file")
shader_compile :: proc(src: ^cstring, kind: u32) -> (id: u32, err: General_Error) {
    shader := gl.CreateShader(kind);
    gl.ShaderSource(shader, 1, src, nil);
    gl.CompileShader(shader);

    success: i32;
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, cast([^]i32)&success);
    if success == 0 {
        log.error("Failed to compile shader!");
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
shader_assemble :: #force_inline proc(vertex_src: ^cstring, pixel_src: ^cstring) -> (prg: Shader_Program_Constructor, err: General_Error) {
    prg.vs = shader_compile(vertex_src, gl.VERTEX_SHADER) or_return;
    prg.ps = shader_compile(pixel_src, gl.FRAGMENT_SHADER) or_return;
    prg.program = shader_link(prg.vs, prg.ps) or_return;
    return prg, nil;
}

batch_renderer_new :: proc() -> (ren: Batch_Renderer, err: General_Error) {
    // rect vertices/indexes
    gl.GenVertexArrays(1, &ren.rects.vao);

    gl.GenBuffers(1, &ren.rects.vbo);
    ren.rects.vertices = make([dynamic]f32) or_return;

    gl.GenBuffers(1, &ren.rects.ibo);
    ren.rects.indexes = make([dynamic]u32) or_return;

    // shaders
    img_vertex_src := #load("resources/shaders/img_vert.glsl", cstring);
    img_pixel_src  := #load("resources/shaders/img_pix.glsl", cstring);
    ren.images.shader_ctor = shader_assemble(&img_vertex_src, &img_pixel_src) or_return;
    rect_vertex_src := #load("resources/shaders/rect_vert.glsl", cstring);
    rect_pixel_src  := #load("resources/shaders/rect_pix.glsl", cstring);
    ren.rects.shader_ctor = shader_assemble(&rect_vertex_src, &rect_pixel_src) or_return;

    // images
    gl.GenVertexArrays(1, &ren.images.vao);
    ren.images.image_vertices = make(map[string]Image_Vertex_Buffer_Constructor) or_return;

    // font atlas
    ok: bool;
    ren.images.angel_spec, ok = angel_read("video/resources/fonts/font.fnt");
    if !ok do return ren, .Angel_Read;
    if len(ren.images.angel_spec.pages) > 1 {
        log.error("Angel fnt contains MORE than ONE page (now not supported)!");
        return ren, .Angel_Read;
    }
    img_path := make([]byte, len(FONT_DIR) + 1 + len(ren.images.angel_spec.pages[0].file_name));
    copy_from_string(img_path, FONT_DIR);
    img_path[len(FONT_DIR)] = '/';
    copy_from_string(img_path[len(FONT_DIR) + 1:], ren.images.angel_spec.pages[0].file_name);
    x, y: libc.int;
    img := stbi.load(strings.clone_to_cstring(cast(string)img_path, context.temp_allocator), &x, &y, nil, 4);
    // log.warnf("File: %s", img_path);
    // img := load_image(string(img_path)) or_return;
    delete(img_path);
    // defer delete_image(img);
    defer libc.free(img);

    e := map_insert(
        &ren.images.image_vertices,
        ren.images.angel_spec.pages[0].file_name,
        Image_Vertex_Buffer_Constructor{});
    e^.width  = cast(f32)x//img.width;
    e^.height = cast(f32)y//img.height;

    gl.GenTextures(1, &e^.texture);
    gl.BindTexture(gl.TEXTURE_2D, e^.texture);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,
        // cast(i32)img.width, cast(i32)img.height, 0,
        x, y, 0,
        // gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));
        gl.RGBA, gl.UNSIGNED_BYTE, img);

    return ren, err;
}

@(private="file")
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

@(private="file")
batch_renderer_add_text :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Text) {
    pos := cmd.pos;

    e, ok := ren.images.image_vertices[ren.images.angel_spec.pages[0].file_name]; // assuming ONE PAGE!!
    assert(ok);
    for c in cmd.text {
        angel_char: ^AngelBlock_Char = nil;
        for &ac in ren^.images.angel_spec.chars {
            if ac.id == cast(u32)c {
                angel_char = &ac;
                break;
            }
        }
        assert(angel_char != nil);

        r := Rect {
            x1 = cast(f32)angel_char.x_offset / e.width,
            y1 = cast(f32)angel_char.y_offset / e.height,
            x2 = (cast(f32)angel_char.x_offset + cast(f32)angel_char.width) / e.width,
            y2 = (cast(f32)angel_char.y_offset + cast(f32)angel_char.height) / e.height,
        };
        assert(false, "TODO: We cannot do this since font atlas does not really have an active VBO. Also we should not bind copies of the font atlas for every char instance. There should only be one atlas instance and multiple vertex buffer clippings!")
        batch_renderer_register_image(
            ren,
            pos,
            r,
            ren.images.angel_spec.pages[angel_char^.page-1].file_name);

        pos.x += cmd.size;
    }
}

batch_renderer_add :: proc { batch_renderer_add_button, batch_renderer_add_text }

/**
 * @brief images registered via file path (cached) such that every already registered image is going to be re-rendered
 *      and every new one is going to be loaded, cropped, and GPU-registered
 * @param img_pos is a position of the top left corner where the image should be located (window coords)
 * @param clip_rect is a UV rectangle, marking area which is going to be displayed on the screen
 * @param img_path is path to the image desired to (re)load
 * @note if the function finds already existing image with the img_path, it will still update vertices and crop the image anew
 */
batch_renderer_register_image :: proc(ren: ^Batch_Renderer, img_pos: [2]i32, clip_rect: Rect, img_path: string) -> (err: General_Error) {
    e, ok := &ren^.images.image_vertices[img_path];
    if !ok {
        img := load_image(img_path) or_return;
        defer delete_image(img);

        // add texture
        texture: u32;
        gl.GenTextures(1, &texture);
        e^.texture = texture;
        gl.BindTexture(gl.TEXTURE_2D, texture);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGBA,
            cast(i32)img.width, cast(i32)img.height, 0,
            gl.RGBA, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf));

        e = map_insert(&ren^.images.image_vertices, img_path, Image_Vertex_Buffer_Constructor {});

        e^.width = cast(f32)img.width;
        e^.height = cast(f32)img.height;
    }
    e^.dirty_flag = true;

    // add image rectangle
    {
        img_size := [2]f32 { cast(f32)e^.width, cast(f32)e^.height, };
        img_fpos := [2]f32 { cast(f32)img_pos.x, cast(f32)img_pos.y, };
        r := ui_pos_to_ndc(ui_create_rect(img_fpos, img_size));
        // x_delta := r.x2 - r.x1;
        // y_delta := r.y2 - r.y1;
        // r.x1 += clip_rect.x1 * x_delta;
        // r.x2 -= (1 - clip_rect.x2) * x_delta;
        // r.y1 -= (1 - clip_rect.y1) * y_delta;
        // r.y2 += clip_rect.y2 * y_delta;

        // CCW
        vertices: [6]Image_Vertex;
        vertices[0] = { { r.x1, r.y1 }, { clip_rect.x1, clip_rect.y1 }, }; // Bottom-left
        vertices[1] = { { r.x2, r.y1 }, { clip_rect.x2, clip_rect.y2 }, }; // Bottom-right
        vertices[2] = { { r.x1, r.y2 }, { clip_rect.x1, clip_rect.y1 }, }; // Top-left

        vertices[3] = { { r.x1, r.y2 }, { clip_rect.x1, clip_rect.y1 }, }; // Top-left
        vertices[4] = { { r.x2, r.y1 }, { clip_rect.x2, clip_rect.y2 }, }; // Bottom-right
        vertices[5] = { { r.x2, r.y2 }, { clip_rect.x2, clip_rect.y1 }, }; // Top-right

        if !ok do gl.GenBuffers(1, &e^.vbo); // only generate buffer if entry does not yet exist
        gl.BindBuffer(gl.ARRAY_BUFFER, e^.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(vertices) * size_of(Image_Vertex), raw_data(vertices[:]), gl.STATIC_DRAW);
    }

    return nil;
}

batch_renderer_construct :: proc(ren: ^Batch_Renderer) {
    // render button(s)
    {
        gl.UseProgram(ren^.rects.program);

        gl.BindVertexArray(ren^.rects.vao);

        gl.BindBuffer(gl.ARRAY_BUFFER, ren^.rects.vbo);
        gl.BufferData(gl.ARRAY_BUFFER, len(ren^.rects.vertices) * size_of(f32), raw_data(ren^.rects.vertices), gl.DYNAMIC_DRAW);

        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ren^.rects.ibo);
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(ren^.rects.indexes) * size_of(u32), raw_data(ren^.rects.indexes), gl.DYNAMIC_DRAW);

        gl.EnableVertexAttribArray(0);
        gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 2 * size_of(f32), 0);

        gl.DrawElements(gl.TRIANGLES, cast(i32)len(ren^.rects.indexes), gl.UNSIGNED_INT, nil);
    }

    // render image(s)
    {
        gl.UseProgram(ren^.images.program);

        gl.BindVertexArray(ren^.images.vao);
        gl.EnableVertexAttribArray(0);

        gl.VertexAttribPointer(0, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, pos));
        gl.EnableVertexAttribArray(0);

        gl.VertexAttribPointer(1, 2, gl.FLOAT, false, size_of(Image_Vertex), offset_of(Image_Vertex, uv));
        gl.EnableVertexAttribArray(1);

        for k, v in ren^.images.image_vertices {
            if k == ren^.images.angel_spec.pages[0].file_name do continue; // skip the font atlas
            gl.BindBuffer(gl.ARRAY_BUFFER, v.texture);
            gl.DrawArrays(gl.TRIANGLES, 0, 6); // quad
        }
    }
}

/** @brief clear called every WINDOW DRAW (multiple times per frame) */
batch_renderer_clear :: proc(ren: ^Batch_Renderer) {
    clear(&ren^.rects.vertices);
    clear(&ren^.rects.indexes);
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
    // vertex buffer constructor
    delete(ren^.rects.vertices);
    delete(ren^.rects.indexes);
    buffers := [2]u32 { ren^.rects.vbo, ren^.rects.ibo };
    gl.DeleteBuffers(2, &buffers[0]);
    gl.DeleteVertexArrays(1, &ren^.rects.vao);
    gl.DeleteProgram(ren^.rects.program);

    // image buffer constructor + font atlas constructor
    for k in ren^.images.image_vertices do batch_renderer_delete_texture(ren, k);
    angel_delete(&ren^.images.angel_spec);
    gl.DeleteVertexArrays(1, &ren^.images.vao);
    gl.DeleteProgram(ren^.images.program);
    delete(ren^.images.image_vertices);
}
