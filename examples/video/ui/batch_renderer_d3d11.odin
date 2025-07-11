/**
 * @file batch_renderer_d3d11.odin
 *
 * @brief
 *
 * @ingroup ui
 *
 * @author GowardSilk
 */
package ui;

import "core:log"
import "core:fmt"
import "core:mem"
import "core:strings"
import "core:c/libc"
import win "core:sys/windows"

import d3dc  "vendor:directx/d3d_compiler"
import d3d11 "vendor:directx/d3d11"
import dxgi  "vendor:directx/dxgi"

import stbi "vendor:stb/image"

Image_Vertex_Buffer_D3D11 :: struct {
    vb:      ^d3d11.IBuffer,
    texture: ^d3d11.ITexture2D,
    width: f32, height: f32,
    srv:     ^d3d11.IShaderResourceView,
}

Font_Atlas_Vertex_Buffer_D3D11 :: struct {
    vb:         ^d3d11.IBuffer,
    vertices:   [dynamic]Image_Vertex,
    ib:         ^d3d11.IBuffer,
    indexes:    [dynamic]u32,
}

Font_Atlas_Texture_Buffer_D3D11 :: struct {
    texture: ^d3d11.ITexture2D,
    srv:     ^d3d11.IShaderResourceView,
}

Rect_Vertex_Buffer_D3D11 :: struct {
    vb:       ^d3d11.IBuffer,
    vertices: [dynamic]Rect_Vertex,
    ib:       ^d3d11.IBuffer,
    indexes:  [dynamic]u32,
}

PerWindow_Memory_D3D11 :: struct {
    swapchain:          ^dxgi.ISwapChain1,
    framebuffer:        ^d3d11.ITexture2D,
    framebuffer_view:   ^d3d11.IRenderTargetView,
}

Shader_D3D11 :: struct {
    vertex:       ^d3d11.IVertexShader,
    pixel:        ^d3d11.IPixelShader,
    input_layout: ^d3d11.IInputLayout,
}

Shader_Desc_D3D11 :: struct {
    src:            cstring,
    file_name:      cstring,
    func_name:      cstring,
    version:        cstring,
    len:            d3d11.SIZE_T,
    input_layout:   []d3d11.INPUT_ELEMENT_DESC, // this param is 'nil' for pix shader
}

Image_Request_Result_D3D11 :: ^d3d11.ITexture2D;

Persistent_Memory_D3D11 :: struct {
    device: ^d3d11.IDevice,
    device_context: ^d3d11.IDeviceContext,

    dxgi: #type struct {
        // device:  ^dxgi.IDevice,
        // adapter: ^dxgi.IAdapter,
        factory: ^dxgi.IFactory2,
    },

    sampler: ^d3d11.ISamplerState,
    using depth: #type struct {
        state: ^d3d11.IDepthStencilState,
        buffer: ^d3d11.IDepthStencilView,
        buffer_texture: ^d3d11.ITexture2D,
    },
    rasterizer: ^d3d11.IRasterizerState,

    font_program:   Shader_D3D11,
    image_program:  Shader_D3D11,
    rect_program:   Shader_D3D11,
}

@(private="file")
shader_load_common :: proc(device: ^d3d11.IDevice, shader_desc: Shader_Desc_D3D11) -> (blob: ^d3d11.IBlob, err: General_Error) {
    error_message: ^d3d11.IBlob;
    shader_desc_src := transmute([^]byte)shader_desc.src;
    res := d3dc.Compile(
        shader_desc_src,
        shader_desc.len,
        shader_desc.file_name,
        nil,
        nil,
        shader_desc.func_name,
        shader_desc.version,
        0,
        0,
        &blob,
        &error_message
    );
    if res != 0 {
        if error_message != nil {
            msg_ptr := error_message->GetBufferPointer();
            msg_len := error_message->GetBufferSize();
            msg := transmute(string)mem.Raw_String{cast([^]u8)msg_ptr, int(msg_len)};
            fmt.eprintfln("D3D11 shader compile error: %s", msg);
        }
        fmt.eprintfln(
            "Error during D3D11 shader (%s) compilation: %v",
            shader_desc.file_name,
            res
        );
        blob->Release();
        error_message->Release();
        return nil, .Shader_Compile;
    }
    return blob, nil;
}

@(private="file")
shader_load_pix_d3d11 :: proc(device: ^d3d11.IDevice, shader_desc: Shader_Desc_D3D11) -> (pix: ^d3d11.IPixelShader, err: General_Error) {
    blob := shader_load_common(device, shader_desc) or_return;
    // construct shader object
    res := device->CreatePixelShader(
        blob->GetBufferPointer(),
        blob->GetBufferSize(),
        nil,
        &pix
    );
    if res != 0 {
        pix->Release();
        blob->Release();
        return nil, .Shader_Compile;
    }
    return pix, nil;
}

@(private="file")
shader_load_vert_d3d11 :: proc(device: ^d3d11.IDevice, shader_desc: Shader_Desc_D3D11) -> (vert: ^d3d11.IVertexShader, il: ^d3d11.IInputLayout, err: General_Error) {
    blob := shader_load_common(device, shader_desc) or_return;
    // construct shader object
    res := device->CreateVertexShader(
        blob->GetBufferPointer(),
        blob->GetBufferSize(),
        nil,
        &vert
    );
    if res != 0 {
        vert->Release();
        blob->Release();
        return nil, nil, .Shader_Compile;
    }

    res = device->CreateInputLayout(
        &shader_desc.input_layout[0], u32(len(shader_desc.input_layout)),
        blob->GetBufferPointer(), blob->GetBufferSize(),
        &il,
    );
    if res != 0 {
        fmt.printf("\x1b[31mErr: %v;\nDesc: %v;\n\x1b[0m", res, shader_desc.input_layout);
        vert->Release();
        blob->Release();
        return nil, nil, .Shader_Compile;
    }

    return vert, il, nil;
}

@(private="file")
shader_assemble_d3d11 :: #force_inline proc(device: ^d3d11.IDevice, vertex_desc: Shader_Desc_D3D11, pixel_desc: Shader_Desc_D3D11) -> (shader: Shader_D3D11, err: General_Error) {
    shader.pixel  = shader_load_pix_d3d11(device, pixel_desc) or_return;
    shader.vertex, shader.input_layout = shader_load_vert_d3d11(device, vertex_desc) or_return;
    return shader, nil;
}

@(private="file")
FONT_SHADER_SRC_D3D11 :: #load("../resources/shaders/font.hlsl", cstring);

@(private="file")
FONT_VERTEX_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = FONT_SHADER_SRC_D3D11,
    file_name     = "font.hlsl",
    func_name     = "vs_main",
    version       = "vs_5_0",
    len           = len(FONT_SHADER_SRC_D3D11),
    input_layout  = nil,
}

@(private="file")
FONT_PIXEL_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = FONT_SHADER_SRC_D3D11,
    file_name     = "font.hlsl",
    func_name     = "ps_main",
    version       = "ps_5_0",
    len           = len(FONT_SHADER_SRC_D3D11),
    input_layout  = nil,
}

@(private="file")
IMG_SHADER_SRC_D3D11 :: #load("../resources/shaders/img.hlsl", cstring);

@(private="file")
IMG_VERTEX_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = IMG_SHADER_SRC_D3D11,
    file_name     = "img.hlsl",
    func_name     = "vs_main",
    version       = "vs_5_0",
    len           = len(IMG_SHADER_SRC_D3D11),
    input_layout  = nil,
}

@(private="file")
IMG_PIXEL_SRC_D3D11 :: #load("../resources/shaders/img.hlsl", cstring);

@(private="file")
IMG_PIXEL_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = IMG_SHADER_SRC_D3D11,
    file_name     = "img.hlsl",
    func_name     = "ps_main",
    version       = "ps_5_0",
    len           = len(IMG_SHADER_SRC_D3D11),
    input_layout  = nil,
}

@(private="file")
RECT_SHADER_SRC_D3D11 :: #load("../resources/shaders/rect.hlsl", cstring);

@(private="file")
RECT_VERTEX_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = RECT_SHADER_SRC_D3D11,
    file_name     = "rect.hlsl",
    func_name     = "vs_main",
    version       = "vs_5_0",
    len           = len(RECT_SHADER_SRC_D3D11),
    input_layout  = nil,
}

@(private="file")
RECT_PIXEL_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = RECT_SHADER_SRC_D3D11,
    file_name     = "rect.hlsl",
    func_name     = "ps_main",
    version       = "ps_5_0",
    len           = len(RECT_SHADER_SRC_D3D11),
    input_layout  = nil,
}

batch_renderer_new_d3d11 :: proc(id: Window_ID) -> (ren: Batch_Renderer, err: General_Error) {
    ren.backend = .D3D11;

    // init D3D11 pipeline
    ren.persistent = new(Persistent_Memory_D3D11);

    // D3D11 pipeline: devices
    device_flags := d3d11.CREATE_DEVICE_FLAGS{.SINGLETHREADED};
    when ODIN_DEBUG do device_flags |= {.DEBUG};
    feature_levels := [?]d3d11.FEATURE_LEVEL { ._11_1, };
    res := d3d11.CreateDevice(
        nil, .HARDWARE, nil, device_flags,
        &feature_levels[0], u32(len(feature_levels)), d3d11.SDK_VERSION,
        &ren.persistent.device, nil, &ren.persistent.device_context);
    fmt.assertf(res == 0, "Failed to create device; Reason: %d", res);
    dxgi_device: ^dxgi.IDevice;
    dxgi_adapter: ^dxgi.IAdapter;
    res = ren.persistent.device->QueryInterface(dxgi.IDevice_UUID, cast(^rawptr)(&dxgi_device));
    fmt.assertf(res == 0, "Failed to query dxgi_device interface; Reason: %d", res);
    res = dxgi_device->GetAdapter(&dxgi_adapter);
    fmt.assertf(res == 0, "Failed to get dxgi_adapter adapter; Reason: %d", res);
    res = dxgi_adapter->GetParent(dxgi.IFactory2_UUID, cast(^rawptr)(&ren.persistent.dxgi.factory));
    fmt.assertf(res == 0, "Failed to get dxgi_factory; Reason: %d", res);

    // D3D11 pipeline: shaders
    input_layout := [2]d3d11.INPUT_ELEMENT_DESC {
        d3d11.INPUT_ELEMENT_DESC {
            SemanticName      = "POSITION",
            SemanticIndex     = 0,
            Format            = .R32G32_FLOAT,
            InputSlot         = 0,
            AlignedByteOffset = 0,
            InputSlotClass    = .VERTEX_DATA,
        },
        d3d11.INPUT_ELEMENT_DESC {
            SemanticName      = "TEXCOORD",
            SemanticIndex     = 0,
            Format            = .R32G32_FLOAT,
            InputSlot         = 0,
            AlignedByteOffset = size_of([2]f32),
            InputSlotClass    = .VERTEX_DATA,
        },
    };
    FONT_VERTEX_SHADER_DESC_D3D11.input_layout = input_layout[:];
    ren.persistent.font_program  = shader_assemble_d3d11(ren.persistent.device, FONT_VERTEX_SHADER_DESC_D3D11, FONT_PIXEL_SHADER_DESC_D3D11) or_return;

    // same input layout
    IMG_VERTEX_SHADER_DESC_D3D11.input_layout = input_layout[:];
    ren.persistent.image_program = shader_assemble_d3d11(ren.persistent.device, IMG_VERTEX_SHADER_DESC_D3D11, IMG_PIXEL_SHADER_DESC_D3D11)  or_return;

    RECT_VERTEX_SHADER_DESC_D3D11.input_layout = input_layout[:1];
    ren.persistent.rect_program  = shader_assemble_d3d11(ren.persistent.device, RECT_VERTEX_SHADER_DESC_D3D11, RECT_PIXEL_SHADER_DESC_D3D11) or_return

    ren.perwindow = make(map[Window_ID]PerWindow_Memory);

    // D3D11 pipeline: sampler
    {
        sampler_desc := d3d11.SAMPLER_DESC{
            Filter         = .MIN_MAG_MIP_LINEAR,
            AddressU       = .CLAMP,
            AddressV       = .CLAMP,
            AddressW       = .CLAMP,
            ComparisonFunc = .NEVER,
            MinLOD         = 0,
            MaxLOD         = d3d11.FLOAT32_MAX,
        };
        ren.persistent.device->CreateSamplerState(&sampler_desc, &ren.persistent.sampler);
    }

    // D3D11 pipeline: depth stencil
    {
        ds_desc := d3d11.DEPTH_STENCIL_DESC {
            DepthEnable    = true,
            DepthWriteMask = .ZERO,
            DepthFunc      = .ALWAYS,
            StencilEnable  = true,

            StencilReadMask  = 0xFF,
            StencilWriteMask = 0xFF,

            FrontFace = d3d11.DEPTH_STENCILOP_DESC{
                StencilFailOp      = .KEEP,
                StencilDepthFailOp = .KEEP,
                StencilPassOp      = .REPLACE,
                StencilFunc        = .ALWAYS,
            },

            BackFace = d3d11.DEPTH_STENCILOP_DESC{
                StencilFailOp      = .KEEP,
                StencilDepthFailOp = .KEEP,
                StencilPassOp      = .REPLACE,
                StencilFunc        = .ALWAYS,
            },
        };
        assert(ren.persistent.device->CreateDepthStencilState(&ds_desc, &ren.persistent.depth.state) == 0);

        // NOTE(GowardSilk): this is potentially volatile ???
        hwnd := cast(dxgi.HWND)id;
        rect: win.RECT;
        assert(win.GetWindowRect(hwnd, &rect) == win.TRUE);
        texture_desc: d3d11.TEXTURE2D_DESC;
        texture_desc.Width              = u32(rect.right - rect.left);
        texture_desc.Height             = u32(rect.bottom - rect.top);
        texture_desc.MipLevels          = 1;
        texture_desc.ArraySize          = 1;
        texture_desc.Format             = .D24_UNORM_S8_UINT;
        texture_desc.SampleDesc.Count   = 1;
        texture_desc.SampleDesc.Quality = 0;
        texture_desc.Usage              = .DEFAULT;
        texture_desc.BindFlags          = {.DEPTH_STENCIL};

        assert(ren.persistent.device->CreateTexture2D(&texture_desc, nil, &ren.persistent.depth.buffer_texture) == 0);

        dsv_desc: d3d11.DEPTH_STENCIL_VIEW_DESC;
        dsv_desc.Format             = texture_desc.Format;
        dsv_desc.ViewDimension      = .TEXTURE2D;
        dsv_desc.Texture2D.MipSlice = 0;

        assert(
            ren.persistent.device->CreateDepthStencilView(
                ren.persistent.depth.buffer_texture,
                &dsv_desc,
                &ren.persistent.depth.buffer) == 0
        );
    }

    rast_desc := d3d11.RASTERIZER_DESC {
        FillMode = .SOLID,
        CullMode = .NONE,
        FrontCounterClockwise = true,
    };
    assert(ren.persistent.device->CreateRasterizerState(&rast_desc, &ren.persistent.rasterizer) == 0);

    // D3D11 pipeline: swapchain
    batch_renderer_clone_d3d11(&ren, id);

    // Font atlas texture initialization (D3D11)
    {
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
        x, y: i32;
        img := stbi.load(strings.clone_to_cstring(cast(string)img_path, context.temp_allocator), &x, &y, nil, 4);
        assert(img != nil);
        delete(img_path);
        defer libc.free(img);

        create_texture_and_srv(
            ren.persistent.device,
            cast(u32)x, cast(u32)y,
            img,
            &ren.images.font_atlas.base.d3d11.texture,
            &ren.images.font_atlas.base.d3d11.srv
        );
    }

    return ren, nil;
}

batch_renderer_clone_d3d11 :: proc(ren: ^Batch_Renderer, id: Window_ID) -> (err: General_Error) {
    assert(id not_in ren^.perwindow);

    perwindow: PerWindow_Memory_D3D11;
    // D3D11 pipeline: swapchain
    {
        tex_desc := d3d11.TEXTURE2D_DESC{};
        ren^.persistent.depth.buffer_texture->GetDesc(&tex_desc);
        swapchain_desc := dxgi.SWAP_CHAIN_DESC1{
            Width  = tex_desc.Width,
            Height = tex_desc.Height,
            Format = .R8G8B8A8_UNORM,
            Stereo = false,
            SampleDesc = {
                Count   = 1,
                Quality = 0,
            },
            BufferUsage = {.RENDER_TARGET_OUTPUT},
            BufferCount = 1, // MAX_FRAMES_IN_FLIGHT,
            Scaling     = .STRETCH,
            SwapEffect  = .DISCARD,
            AlphaMode   = .UNSPECIFIED,
            Flags       = {}, // dxgi.SWAP_CHAIN_FLAG.ALLOW_MODE_SWITCH = 0x2
        };
        res := ren.persistent.dxgi.factory->CreateSwapChainForHwnd(ren.persistent.device, cast(dxgi.HWND)id,
            &swapchain_desc, nil, nil, &perwindow.swapchain);
        fmt.assertf(res == 0, "Could not create swap chain for window handle; Reason: %d", res);
    }

    // D3D11 pipeline: framebuffer/_view
    {
        res := perwindow.swapchain->GetBuffer(0, d3d11.ITexture2D_UUID, cast(^rawptr)&perwindow.framebuffer);
        fmt.assertf(res == 0, "Failed to get framebuffer from swap chain; Reason: %d", res);
        rtv_desc := d3d11.RENDER_TARGET_VIEW_DESC {
            Format = .R8G8B8A8_UNORM,
            ViewDimension = .TEXTURE2D,
            Texture2D = { MipSlice = 0 },
        };
        res = ren.persistent.device->CreateRenderTargetView(perwindow.framebuffer, &rtv_desc, &perwindow.framebuffer_view);
        fmt.assertf(res == 0, "Failed to create RTV; Reason: %d", res);
    }

    map_insert(&ren.perwindow, id, PerWindow_Memory{d3d11=perwindow});

    return nil;
}

batch_renderer_unload_d3d11 :: proc(ren: ^Batch_Renderer, id: Window_ID) {
    e, ok := ren^.perwindow[id];
    log.assertf(ok, "Trying to unload resource with window id: %d; which does not exist!", id);

    e.d3d11.swapchain->Release();
    e.d3d11.framebuffer->Release();
    e.d3d11.framebuffer_view->Release();

    delete_key(&ren^.perwindow, id);
}

batch_renderer_register_image_d3d11 :: proc(ren: ^Batch_Renderer, id: Window_ID, img_pos: [2]i32, uv_rect: Rect, img_path: string) -> (err: General_Error) {
    e, ok := &ren^.images.image_vertices[img_path];
    if !ok {
        img := load_image(img_path) or_return;
        defer delete_image(img);

        e = map_insert(&ren^.images.image_vertices, img_path, Image_Vertex_Buffer {});
        if img.channels == 3 {
            rgba_buf := make([]u8, img.width * img.height * 4);
            defer delete(rgba_buf);
            for i in 0..<img.width * img.height {
                rgba_buf[4 * i + 0] = img.pixels.buf[3 * i + 0];
                rgba_buf[4 * i + 1] = img.pixels.buf[3 * i + 1];
                rgba_buf[4 * i + 2] = img.pixels.buf[3 * i + 2];
                rgba_buf[4 * i + 3] = 255;
            }
            create_texture_and_srv(
                ren.persistent.device,
                cast(u32)img.width,
                cast(u32)img.height,
                raw_data(rgba_buf),
                &e^.base.d3d11.texture,
                &e^.base.d3d11.srv
            );
        } else if img.channels == 4 {
            create_texture_and_srv(
                ren.persistent.device,
                cast(u32)img.width,
                cast(u32)img.height,
                raw_data(img.pixels.buf),
                &e^.base.d3d11.texture,
                &e^.base.d3d11.srv
            );
        } else do unreachable();

        e^.base.d3d11.width = cast(f32)img.width;
        e^.base.d3d11.height = cast(f32)img.height;
        e^.window_id = id;
    }
    e^.dirty_flag = true;

    // add image rectangle
    log.assertf(e^.window_id == id, "Image was created in a window: %d; but is updated through: %d. TODO: Do we consider this an issue?", e^.window_id, id);
    {
        // flip coordinates
        uv_rect := uv_rect;
        vertices := batch_renderer_register_image_rectangle_base(e^.base.d3d11.width, e^.base.d3d11.height, img_pos, uv_rect);
        create_or_update_vertex_buffer(
            ren^.persistent.device,
            ren^.persistent.device_context,
            &vertices[0],
            len(vertices) * size_of(Image_Vertex),
            &e^.base.d3d11.vb
        );
    }
    return nil;
}

batch_renderer_handle_image_request_d3d11 :: #force_inline proc(ren: ^Batch_Renderer, img_path: string) -> Image_Request_Result_D3D11 {
    e, ok := ren^.images.image_vertices[img_path];
    log.assertf(ok, "Image with path: \"%s\" is not registered!", img_path);
    return e.base.d3d11.texture;
}

batch_renderer_invalidate_image_and_reset_d3d11 :: #force_inline proc(ren: ^Batch_Renderer, img_path: string, new_texture_id: Image_Request_Result_D3D11) {
    e, ok := &ren^.images.image_vertices[img_path];
    log.assertf(ok, "Image with path: \"%s\" is not registered! Cannot invalidate an image which does not exist!", img_path);
    e^.base.d3d11.texture = new_texture_id;

    tex_desc: d3d11.TEXTURE2D_DESC;
    new_texture_id->GetDesc(&tex_desc);
    // create new SRV
    assert(tex_desc.MipLevels == 1);
    srv_desc := d3d11.SHADER_RESOURCE_VIEW_DESC {
        Format = tex_desc.Format,
        ViewDimension = .TEXTURE2D,
        Texture2D = { MipLevels = 1, MostDetailedMip = 0 },
    };
    assert(ren^.persistent.device->CreateShaderResourceView(new_texture_id, &srv_desc, &e^.base.d3d11.srv) == 0);
}

batch_renderer_construct_d3d11 :: proc(ren: ^Batch_Renderer, id: Window_ID) {
    perwindow, ok := ren^.perwindow[id];
    log.assertf(ok, "Window of ID: %d is not registered!", id);
    device := ren.persistent.device;
    device_context := ren.persistent.device_context;

    device_context->OMSetRenderTargets(1, &perwindow.d3d11.framebuffer_view, nil);
    framebuffer_desc := d3d11.TEXTURE2D_DESC{};
    perwindow.d3d11.framebuffer->GetDesc(&framebuffer_desc);
    vp := d3d11.VIEWPORT{ TopLeftX=0, TopLeftY=0, Width=cast(f32)framebuffer_desc.Width, Height=cast(f32)framebuffer_desc.Height, MinDepth=0, MaxDepth=1 };
    device_context->RSSetState(ren.persistent.rasterizer);
    device_context->RSSetViewports(1, &vp);

    device_context->OMSetBlendState(nil, nil, 0xffffffff);
    device_context->OMSetDepthStencilState(ren.persistent.depth.state, 1);
    device_context->OMSetRenderTargets(1, &perwindow.d3d11.framebuffer_view, ren.persistent.depth.buffer);

    // --- Draw rects ---
    if len(ren.rects.d3d11.vertices) > 0 && len(ren.rects.d3d11.indexes) > 0 {
        create_or_update_vertex_buffer(
            device,
            device_context,
            raw_data(ren.rects.d3d11.vertices),
            u32(len(ren.rects.d3d11.vertices) * size_of(Rect_Vertex)),
            &ren.rects.d3d11.vb
        );
        create_or_update_index_buffer(
            device,
            device_context,
            raw_data(ren.rects.d3d11.indexes),
            u32(len(ren.rects.d3d11.indexes) * size_of(u32)),
            &ren.rects.d3d11.ib
        );
        stride := u32(2 * size_of(Rect_Vertex));
        offset := u32(0);
    
        device_context->IASetPrimitiveTopology(.TRIANGLELIST);
        device_context->IASetInputLayout(ren.persistent.rect_program.input_layout);
        device_context->IASetVertexBuffers(0, 1, &ren.rects.d3d11.vb, &stride, &offset);
        device_context->IASetIndexBuffer(ren.rects.d3d11.ib, .R32_UINT, 0);
        device_context->VSSetShader(ren.persistent.rect_program.vertex, nil, 0);
        device_context->PSSetShader(ren.persistent.rect_program.pixel, nil, 0);
        device_context->DrawIndexed(u32(len(ren.rects.d3d11.indexes)), 0, 0);
    }

    // --- Draw images ---
    if len(ren.images.image_vertices) > 0 {
        device_context->IASetPrimitiveTopology(.TRIANGLELIST);
        device_context->IASetInputLayout(ren.persistent.image_program.input_layout);
        device_context->VSSetShader(ren.persistent.image_program.vertex, nil, 0);
        device_context->PSSetShader(ren.persistent.image_program.pixel, nil, 0);
        device_context->PSSetSamplers(0, 1, &ren.persistent.sampler);

        for k, &v in ren.images.image_vertices do if v.window_id == id {
            stride := u32(size_of(Image_Vertex));
            offset := u32(0);
            device_context->PSSetShaderResources(0, 1, &v.base.d3d11.srv);
            device_context->IASetVertexBuffers(0, 1, &v.base.d3d11.vb, &stride, &offset);
            device_context->Draw(6, 0);
        }
    }

    // --- Draw font atlas/text ---
    if len(ren^.images.font_atlas.batch.d3d11.vertices) > 0 {
        device_context->IASetPrimitiveTopology(.TRIANGLELIST);
        device_context->IASetInputLayout(ren.persistent.font_program.input_layout);

        base  := ren.images.font_atlas.base;
        batch := &ren^.images.font_atlas.batch.d3d11;
        create_or_update_vertex_buffer(
            device,
            device_context,
            raw_data(batch.vertices),
            u32(len(batch.vertices) * size_of(Image_Vertex)),
            &batch.vb
        );
        create_or_update_index_buffer(
            device,
            device_context,
            raw_data(batch.indexes),
            u32(len(batch.indexes) * size_of(u32)),
            &batch.ib,
        );
        stride := u32(size_of(Image_Vertex));
        offset := u32(0);
        device_context->PSSetShaderResources(0, 1, &base.d3d11.srv);
        device_context->IASetVertexBuffers(0, 1, &batch.vb, &stride, &offset);
        device_context->IASetIndexBuffer(batch.ib, .R32_UINT, 0);
        device_context->VSSetShader(ren.persistent.font_program.vertex, nil, 0);
        device_context->PSSetShader(ren.persistent.font_program.pixel, nil, 0);
        device_context->PSSetSamplers(0, 1, &ren.persistent.sampler);
        device_context->DrawIndexed(u32(len(batch.indexes)), 0, 0);
    }
}

batch_renderer_clear_d3d11 :: proc(ren: ^Batch_Renderer) {
    clear(&ren^.rects.d3d11.vertices);
    clear(&ren^.rects.d3d11.indexes);

    clear(&ren^.images.font_atlas.batch.d3d11.vertices);
    clear(&ren^.images.font_atlas.batch.d3d11.indexes);

    ren^.persistent.device_context->ClearDepthStencilView(
        ren^.persistent.depth.buffer,
        {.DEPTH},
        1.0,
        0
    );
}

batch_renderer_reset_d3d11 :: #force_inline proc(ren: ^Batch_Renderer) {
    batch_renderer_reset_base(ren, batch_renderer_delete_texture_d3d11);
}

batch_renderer_delete_texture_d3d11 :: proc(ren: ^Batch_Renderer, img_path: string) {
    v, ok := ren^.images.image_vertices[img_path];
    assert(ok);
    v.base.d3d11.texture->Release();
    v.base.d3d11.srv->Release();
    delete_key(&ren^.images.image_vertices, img_path);
}

batch_renderer_delete_d3d11 :: proc(ren: ^Batch_Renderer) {
    // perwindow memory
    for _, &perwindow in ren^.perwindow {
        perwindow.d3d11.swapchain->Release();
        perwindow.d3d11.framebuffer->Release();
        perwindow.d3d11.framebuffer_view->Release();
    }
    delete(ren^.perwindow);

    // vertex buffer
    delete(ren^.rects.d3d11.vertices);
    delete(ren^.rects.d3d11.indexes);
    ren^.rects.d3d11.vb->Release();
    ren^.rects.d3d11.ib->Release();

    // image buffer(s)
    for k in ren^.images.image_vertices do batch_renderer_delete_texture_d3d11(ren, k);
    delete(ren^.images.image_vertices);

    // font atlas
    base  := ren^.images.font_atlas.base.d3d11;
    batch := ren^.images.font_atlas.batch.d3d11;
    batch.vb->Release();
    batch.ib->Release();
    delete(ren^.images.font_atlas.batch.gl.vertices);
    delete(ren^.images.font_atlas.batch.gl.indexes);
    base.texture->Release();
    base.srv->Release();
    angel_delete(&ren^.images.angel_spec);
}

@(private="file")
create_or_update_vertex_buffer :: proc(device: ^d3d11.IDevice, ctx: ^d3d11.IDeviceContext, data: rawptr, size: u32, buffer: ^^d3d11.IBuffer) {
    @static sz: u32 = 0;
    assert(size > 0, "Vertex buffer size must be > 0");
    desc := d3d11.BUFFER_DESC {
        ByteWidth = size,
        Usage = .DYNAMIC,
        BindFlags = {.VERTEX_BUFFER},
        CPUAccessFlags = {.WRITE},
    };

    if buffer^ == nil {
        sub := d3d11.SUBRESOURCE_DATA{ pSysMem = data };
        assert(device->CreateBuffer(&desc, &sub, buffer) == 0, "Failed to create vertex buffer");
        sz = size;
    } else if sz != size {
        // buffer needs resize!
        (buffer^)->Release();
        sub := d3d11.SUBRESOURCE_DATA{ pSysMem = data };
        assert(device->CreateBuffer(&desc, &sub, buffer) == 0, "Failed to recreate vertex buffer");
        sz = size;
    } else {
        mapped: d3d11.MAPPED_SUBRESOURCE;
        assert(ctx->Map(buffer^, 0, .WRITE_DISCARD, {}, &mapped) == 0, "Failed to map vertex buffer");
        mem.copy(mapped.pData, data, cast(int)size);
        ctx->Unmap(buffer^, 0);
    }
}

@(private="file")
create_or_update_index_buffer :: proc(device: ^d3d11.IDevice, ctx: ^d3d11.IDeviceContext, data: rawptr, size: u32, buffer: ^^d3d11.IBuffer) {
    @static sz: u32 = 0;
    assert(size > 0, "Index buffer size must be > 0");
    desc := d3d11.BUFFER_DESC {
        ByteWidth = size,
        Usage = .DYNAMIC,
        BindFlags = {.INDEX_BUFFER},
        CPUAccessFlags = {.WRITE},
        MiscFlags = {},
        StructureByteStride = 0,
    };

    if buffer^ == nil {
        sub := d3d11.SUBRESOURCE_DATA{ pSysMem = data };
        assert(device->CreateBuffer(&desc, &sub, buffer) == 0, "Failed to create index buffer");
        sz = size;
    } else if sz != size {
        // buffer needs resize!
        (buffer^)->Release();
        sub := d3d11.SUBRESOURCE_DATA{ pSysMem = data };
        assert(device->CreateBuffer(&desc, &sub, buffer) == 0, "Failed to recreate index buffer");
        sz = size;
    } else {
        mapped: d3d11.MAPPED_SUBRESOURCE;
        assert(ctx->Map(buffer^, 0, .WRITE_DISCARD, {}, &mapped) == 0, "Failed to map index buffer");
        mem.copy(mapped.pData, data, cast(int)size);
        ctx->Unmap(buffer^, 0);
    }
}

@(private="file")
create_texture_and_srv :: proc(device: ^d3d11.IDevice, width, height: u32, data: rawptr, out_tex: ^^d3d11.ITexture2D, out_srv: ^^d3d11.IShaderResourceView) {
    desc := d3d11.TEXTURE2D_DESC {
        Width = width,
        Height = height,
        MipLevels = 1,
        ArraySize = 1,
        Format = .R8G8B8A8_UNORM,
        SampleDesc = { Count = 1, Quality = 0 },
        Usage = .DEFAULT,
        BindFlags = {.SHADER_RESOURCE},
        CPUAccessFlags = {},
        MiscFlags = {.SHARED},
    };

    sub := d3d11.SUBRESOURCE_DATA{ pSysMem = data, SysMemPitch = width * 4 };
    assert(device->CreateTexture2D(&desc, &sub, out_tex) == 0);
    srv_desc := d3d11.SHADER_RESOURCE_VIEW_DESC {
        Format = .R8G8B8A8_UNORM,
        ViewDimension = .TEXTURE2D,
        Texture2D = { MipLevels = 1, MostDetailedMip = 0 },
    };
    assert(device->CreateShaderResourceView(out_tex^, &srv_desc, out_srv) == 0);
}
