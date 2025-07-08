/**
 * @file batch_renderer.odin
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
import "core:fmt"
import "core:strings"

import gl "vendor:OpenGL"
import d3d11 "vendor:directx/d3d11"
import stbi "vendor:stb/image"

FONT_DIR :: "video/resources/fonts";

Window_ID :: distinct uintptr;

@(private)
Image_Vertex :: struct {
    pos: [2]f32,
    uv: [2]f32,
}
@(private="file")
Image_Vertex_Buffer_Base :: struct #raw_union {
    gl:     Image_Vertex_Buffer_GL,
    d3d11:  Image_Vertex_Buffer_D3D11,
}
Image_Vertex_Buffer :: struct {
    base:       Image_Vertex_Buffer_Base,
    window_id:  Window_ID, /**< index at which the image was registered (since images are rendered per-frame and not per window, we need to remember its origin) */
    dirty_flag: bool, /**< marks this image to be preserved for rendering on the next frame */
}
Image_Buffer :: struct {
    image_vertices: map[string]Image_Vertex_Buffer,
}
Image_Batch :: struct {
    using image: Image_Buffer,
    using font:  Font_Atlas,
}

Font_Atlas_Vertex_Buffer :: struct #raw_union {
    gl:     Font_Atlas_Vertex_Buffer_GL,
    d3d11:  Font_Atlas_Vertex_Buffer_D3D11,
}
Font_Atlas_Texture_Buffer :: struct #raw_union {
    gl:     Font_Atlas_Texture_Buffer_GL,
    d3d11:  Font_Atlas_Texture_Buffer_D3D11,
}
Font_Atlas_Buffer :: struct {
    base:   Font_Atlas_Texture_Buffer,
    batch:  Font_Atlas_Vertex_Buffer, /**< batch of all `vertices' */
}
Font_Atlas :: struct {
    angel_spec: AngelFNT_File,
    font_atlas: Font_Atlas_Buffer,
}

Rect_Vertex :: f32;
Rect_Vertex_Buffer :: struct #raw_union {
    gl: Rect_Vertex_Buffer_GL,
    d3d11: Rect_Vertex_Buffer_D3D11,
}
Rect_Batch :: struct {
    using vertex: Rect_Vertex_Buffer,
}

PerWindow_Memory :: struct #raw_union {
    gl:     PerWindow_Memory_GL,
    d3d11:  PerWindow_Memory_D3D11,
}

Backend_Kind :: enum {
    D3D11 = 0,
    GL,
}
/** @brief contains all batched buffers for one Window render */
Batch_Renderer :: struct {
    rects:          Rect_Batch, /**< batch for rectangular objects (aka Quads) */
    images:         Image_Batch, /**< batch for image objects (+ fonts since we use texture fonts) */
    perwindow:      map[Window_ID]PerWindow_Memory, /**< perwindow data that cannot be shared among OpenGL contexts */
    persistent:     ^Persistent_Memory_D3D11, /**< D3D11 pipeline (nil if backend==.GL) */
    backend:        Backend_Kind, /**< what type of Graphics API renderer uses */
}

batch_renderer_new :: proc(id: Window_ID, backend: Backend_Kind) -> (ren: Batch_Renderer, err: General_Error) {
    switch backend {
        case .D3D11: return batch_renderer_new_d3d11(id);
        case .GL:    return batch_renderer_new_gl(id);
    }

    unreachable();
}

/** @brief generates new pipeline for a new window, but keeps all other objects intact (shared) across them */
batch_renderer_clone :: proc(ren: ^Batch_Renderer, id: Window_ID) -> (err: General_Error) {
    switch ren^.backend {
        case .D3D11: return batch_renderer_clone_d3d11(ren, id);
        case .GL:    return batch_renderer_clone_gl(ren, id);
    }

    unreachable();
}

/** @brief destroys cloned resources bound to `id' */
batch_renderer_unload :: proc(ren: ^Batch_Renderer, id: Window_ID) {
    switch ren^.backend {
        case .D3D11:
            batch_renderer_unload_d3d11(ren, id);
            return;
        case .GL:
            batch_renderer_unload_gl(ren, id);
            return;
    }

    unreachable();
}

/** @brief registers button's rect and text for rendering */
batch_renderer_add_button :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Button) {
    // add rect
    {
        base_index: u32;
        vertices: ^[dynamic]Rect_Vertex;
        indexes: ^[dynamic]u32;
        switch ren^.backend {
            case .D3D11:
                base_index = cast(u32)len(ren^.rects.d3d11.vertices) / 2;
                vertices = &ren^.rects.d3d11.vertices;
                indexes = &ren^.rects.d3d11.indexes;
            case .GL:
                base_index = cast(u32)len(ren^.rects.gl.vertices) / 2;
                vertices = &ren^.rects.gl.vertices;
                indexes = &ren^.rects.gl.indexes;
        }

        append(vertices,
            cmd.rect.x1, cmd.rect.y1, // Bottom-left
            cmd.rect.x2, cmd.rect.y1, // Bottom-right
            cmd.rect.x2, cmd.rect.y2, // Top-right
            cmd.rect.x1, cmd.rect.y2, // Top-left
        );
        append(indexes,
            base_index + 0, base_index + 1, base_index + 2,
            base_index + 2, base_index + 3, base_index + 0,
        );
    }
    batch_renderer_add_text(ren, cmd.text);
}

/** @brief registers text clippings of font atlas for rendering */
batch_renderer_add_text :: proc(ren: ^Batch_Renderer, cmd: Draw_Command_Text) {
    pos := cmd.pos;
    scale := cmd.size.y / cast(f32)ren^.images.angel_spec.common.line_height;
    atlas_width, atlas_height: f32;
    switch ren^.backend {
        case .D3D11:
            tex_desc := d3d11.TEXTURE2D_DESC{};
            ren^.images.font_atlas.base.d3d11.texture->GetDesc(&tex_desc);
            atlas_width = cast(f32)tex_desc.Width;
            atlas_height = cast(f32)tex_desc.Height;
        case .GL:
            atlas_width = ren^.images.font_atlas.base.gl.width;
            atlas_height = ren^.images.font_atlas.base.gl.height;
    }

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
            y1 = cast(f32)angel_char.y / atlas_height,
            x2 = (cast(f32)angel_char.x + cast(f32)angel_char.width) / atlas_width,
            y2 = (cast(f32)angel_char.y + cast(f32)angel_char.height) / atlas_height,
        };

        r_ndc := pos_to_ndc(create_rect({xpos, ypos}, {glyph_w, glyph_h}));

        base_index: u32;
        vertices: ^[dynamic]Image_Vertex;
        indexes: ^[dynamic]u32;
        switch ren^.backend {
            case .D3D11:
                using ren^.images.font_atlas.batch;
                base_index = cast(u32)len(d3d11.vertices);
                vertices = &d3d11.vertices;
                indexes = &d3d11.indexes;
            case .GL:
                using ren^.images.font_atlas.batch;
                base_index = cast(u32)len(gl.vertices);
                vertices = &gl.vertices;
                indexes = &gl.indexes;
        }
        append(vertices,
            Image_Vertex { { r_ndc.x1, r_ndc.y2 }, { uv_rect.x1, uv_rect.y2 }, }, // Bottom-left
            Image_Vertex { { r_ndc.x2, r_ndc.y2 }, { uv_rect.x2, uv_rect.y2 }, }, // Bottom-right
            Image_Vertex { { r_ndc.x2, r_ndc.y1 }, { uv_rect.x2, uv_rect.y1 }, }, // Top-right
            Image_Vertex { { r_ndc.x1, r_ndc.y1 }, { uv_rect.x1, uv_rect.y1 }, }, // Top-left
        );
        append(indexes,
            base_index + 0, base_index + 1, base_index + 2,
            base_index + 2, base_index + 3, base_index + 0,
        );

        pos.x += cast(i32)(angel_char.x_advance * scale);
    }
}

@(private)
batch_renderer_register_image_rectangle_base :: #force_inline proc(width, height: f32, img_pos: [2]i32, uv_rect: Rect) -> [6]Image_Vertex {
    img_size := [2]f32 { width, height, };
    img_fpos := [2]f32 { cast(f32)img_pos.x, cast(f32)img_pos.y, };
    r_ndc := pos_to_ndc(create_rect(img_fpos, img_size));

    vertices: [6]Image_Vertex;
    vertices[0] = { { r_ndc.x2, r_ndc.y1 }, { uv_rect.x2, uv_rect.y2 }, }; // Bottom-right
    vertices[1] = { { r_ndc.x1, r_ndc.y1 }, { uv_rect.x1, uv_rect.y2 }, }; // Bottom-left
    vertices[2] = { { r_ndc.x1, r_ndc.y2 }, { uv_rect.x1, uv_rect.y1 }, }; // Top-left

    vertices[3] = { { r_ndc.x1, r_ndc.y2 }, { uv_rect.x1, uv_rect.y1 }, }; // Top-left
    vertices[4] = { { r_ndc.x2, r_ndc.y2 }, { uv_rect.x2, uv_rect.y1 }, }; // Top-right
    vertices[5] = { { r_ndc.x2, r_ndc.y1 }, { uv_rect.x2, uv_rect.y2 }, }; // Bottom-right

    return vertices;
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
batch_renderer_register_image :: proc(ren: ^Batch_Renderer, id: Window_ID, img_pos: [2]i32, uv_rect: Rect, img_path: string) -> (err: General_Error) {
    switch ren^.backend {
        case .D3D11: return batch_renderer_register_image_d3d11(ren, id, img_pos, uv_rect, img_path);
        case .GL:    return batch_renderer_register_image_gl(ren, id, img_pos, uv_rect, img_path);
    }

    unreachable();
}

Image_Request_Result :: struct #raw_union {
    d3d11:  Image_Request_Result_D3D11,
    gl:     Image_Request_Result_GL,
}
/** @brief returns an image buffer associated with the given `img_path' */
batch_renderer_handle_image_request :: #force_inline proc(ren: ^Batch_Renderer, img_path: string) -> Image_Request_Result {
    switch ren^.backend {
        case .D3D11: return Image_Request_Result{d3d11=batch_renderer_handle_image_request_d3d11(ren, img_path)};
        case .GL: return Image_Request_Result{gl=batch_renderer_handle_image_request_gl(ren, img_path)};
    }

    unreachable();
}

/**
 * @brief replaces the texture resource returned via batch_renderer_handle_image_request
 * @note that the texture previously occupying the slot should be destroyed is up to the callers decision
 */
batch_renderer_invalidate_image_and_reset :: #force_inline proc(ren: ^Batch_Renderer, img_path: string, new_texture_id: Image_Request_Result) {
    switch ren^.backend {
        case .D3D11:
            batch_renderer_invalidate_image_and_reset_d3d11(ren, img_path, new_texture_id.d3d11);
            return;
        case .GL:
            batch_renderer_invalidate_image_and_reset_gl(ren, img_path, new_texture_id.gl);
            return;
    }

    unreachable();
}

/** @brief bind all necessary buffers and draw them onto the screen (with `id') */
batch_renderer_construct :: proc(ren: ^Batch_Renderer, id: Window_ID) {
    switch ren^.backend {
        case .D3D11:
            batch_renderer_construct_d3d11(ren, id);
            return;
        case .GL:
            batch_renderer_construct_gl(ren, id);
            return;
    }

    unreachable();
}

/** @brief clear called every WINDOW DRAW (multiple times per frame in case of multiple windows) */
batch_renderer_clear :: proc(ren: ^Batch_Renderer) {
    switch ren^.backend {
        case .D3D11:
            batch_renderer_clear_d3d11(ren);
            return;
        case .GL:
            batch_renderer_clear_gl(ren);
            return;
    }

    unreachable();
}

@(private)
batch_renderer_reset_base :: #force_inline proc(ren: ^Batch_Renderer, texture_delete_proc: #type proc(ren: ^Batch_Renderer, key: string)) {
    // do a cycle, checking out all of the images which are not used
    for k, &v in ren^.images.image_vertices {
        if !v.dirty_flag do texture_delete_proc(ren, k);
        else do v.dirty_flag = false; // all images will be marked as unsused by default, that way we can checkout the ones which will be left untouched the next frame
    }
}
/** @brief reset called every FRAME */
batch_renderer_reset :: proc(ren: ^Batch_Renderer) {
    switch ren^.backend {
        case .GL:
            batch_renderer_reset_gl(ren);
            return;
        case .D3D11:
            batch_renderer_reset_d3d11(ren);
            return;
    }

    unreachable();
}

batch_renderer_delete :: proc(ren: ^Batch_Renderer) {
    switch ren^.backend {
        case .GL:
            batch_renderer_delete_gl(ren);
            return;
        case .D3D11:
            batch_renderer_delete_d3d11(ren);
            return;
    }

    unreachable();
}
