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

import d3dc  "vendor:directx/d3d_compiler"
import d3d11 "vendor:directx/d3d11"
import dxgi  "vendor:directx/dxgi"

Image_Vertex_Buffer_D3D11 :: struct {
    texture: ^d3d11.ITexture2D,
}

Font_Atlas_Vertex_Buffer_D3D11 :: struct {
    vertices:   [dynamic]Image_Vertex,
    indexes:    [dynamic]u32,
}

Font_Atlas_Texture_Buffer_D3D11 :: struct {
    texture: ^d3d11.ITexture2D,
    texture_resource: ^d3d11.IShaderResourceView,
}

Rect_Vertex_Buffer_D3D11 :: struct {
    vertices: [dynamic]Rect_Vertex,
    indexes:  [dynamic]u32,
}

PerWindow_Memory_D3D11 :: struct {
    swapchain:          ^dxgi.ISwapChain1,
    framebuffer:        ^d3d11.ITexture2D,
    framebuffer_view:   ^d3d11.IRenderTargetView,
}

Shader_D3D11 :: struct {
    vertex: ^d3d11.IVertexShader,
    pixel:  ^d3d11.IPixelShader,
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

    dxgi_device:  ^dxgi.IDevice,
    dxgi_adapter: ^dxgi.IAdapter,
    dxgi_factory: ^dxgi.IFactory2,

    sampler: ^d3d11.ISamplerState,

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
shader_load_vert_d3d11 :: proc(device: ^d3d11.IDevice, shader_desc: Shader_Desc_D3D11) -> (vert: ^d3d11.IVertexShader, err: General_Error) {
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
        return nil, .Shader_Compile;
    }

    assert(false, "TODO: D3D11.IInputLayout");
    res = device->CreateInputLayout(
        &shader_desc.input_layout[0], u32(len(shader_desc.input_layout)),
        blob->GetBufferPointer(), blob->GetBufferSize(),
        /* TODO: HERE */ nil,
    );
    if res != 0 {
        fmt.printf("\x1b[31mErr: %v;\nDesc: %v;\n\x1b[0m", res, shader_desc.input_layout);
        vert->Release();
        blob->Release();
        return nil, .Shader_Compile;
    }

    return vert, nil;
}

@(private="file")
shader_assemble_d3d11 :: #force_inline proc(device: ^d3d11.IDevice, vertex_desc: Shader_Desc_D3D11, pixel_desc: Shader_Desc_D3D11) -> (shader: Shader_D3D11, err: General_Error) {
    shader.pixel  = shader_load_pix_d3d11(device, pixel_desc) or_return;
    shader.vertex = shader_load_vert_d3d11(device, vertex_desc) or_return;
    return shader, nil;
}

@(private="file")
FONT_SHADER_SRC_D3D11 :: #load("../resources/shaders/font.hlsl", cstring);

@(private="file")
FONT_VERTEX_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = FONT_SHADER_SRC_D3D11,
    file_name     = "font.hlsl",
    func_name     = "main",
    version       = "vs_5_0",
    len           = len(FONT_SHADER_SRC_D3D11),
    input_layout  = nil,
}

@(private="file")
FONT_PIXEL_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = FONT_SHADER_SRC_D3D11,
    file_name     = "font.hlsl",
    func_name     = "main",
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
    func_name     = "main",
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
    func_name     = "main",
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
    func_name     = "main",
    version       = "vs_5_0",
    len           = len(RECT_SHADER_SRC_D3D11),
    input_layout  = nil,
}

@(private="file")
RECT_PIXEL_SHADER_DESC_D3D11 := Shader_Desc_D3D11 {
    src           = RECT_SHADER_SRC_D3D11,
    file_name     = "rect.hlsl",
    func_name     = "main",
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
    res = ren.persistent.device->QueryInterface(dxgi.IDevice_UUID, cast(^rawptr)(&ren.persistent.dxgi_device));
    fmt.assertf(res == 0, "Failed to query dxgi_device interface; Reason: %d", res);
    res = ren.persistent.dxgi_device->GetAdapter(&ren.persistent.dxgi_adapter);
    fmt.assertf(res == 0, "Failed to get dxgi_adapter adapter; Reason: %d", res);
    res = ren.persistent.dxgi_adapter->GetParent(dxgi.IFactory2_UUID, cast(^rawptr)(&ren.persistent.dxgi_factory));
    fmt.assertf(res == 0, "Failed to get dxgi_factory; Reason: %d", res);

    // D3D11 pipeline: shaders
    input_layout := make([]d3d11.INPUT_ELEMENT_DESC, 2);
    defer delete(input_layout);
    FONT_VERTEX_SHADER_DESC_D3D11.input_layout = input_layout;
    ren.persistent.font_program  = shader_assemble_d3d11(ren.persistent.device, FONT_VERTEX_SHADER_DESC_D3D11, FONT_PIXEL_SHADER_DESC_D3D11) or_return;

    IMG_VERTEX_SHADER_DESC_D3D11.input_layout = input_layout;
    ren.persistent.image_program = shader_assemble_d3d11(ren.persistent.device, IMG_VERTEX_SHADER_DESC_D3D11, IMG_PIXEL_SHADER_DESC_D3D11)  or_return;

    RECT_VERTEX_SHADER_DESC_D3D11.input_layout = input_layout;
    ren.persistent.rect_program  = shader_assemble_d3d11(ren.persistent.device, RECT_VERTEX_SHADER_DESC_D3D11, RECT_PIXEL_SHADER_DESC_D3D11) or_return

    ren.perwindow = make(map[Window_ID]PerWindow_Memory);
    batch_renderer_clone_d3d11(&ren, id);

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

    return ren, nil;
}

batch_renderer_clone_d3d11 :: proc(ren: ^Batch_Renderer, id: Window_ID) -> (err: General_Error) {
    perwindow: PerWindow_Memory_D3D11;
    // D3D11 pipeline: swapchain
    {
        swapchain_desc := dxgi.SWAP_CHAIN_DESC1{
            Width  = 0,
            Height = 0,
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
        res := ren.persistent.dxgi_factory->CreateSwapChainForHwnd(ren.persistent.device, cast(dxgi.HWND)id,
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
}

batch_renderer_register_image_d3d11 :: proc(ren: ^Batch_Renderer, id: Window_ID, img_pos: [2]i32, uv_rect: Rect, img_path: string) -> (err: General_Error) {
    e, ok := &ren^.images.image_vertices[img_path];
    if !ok {
        img := load_image(img_path) or_return;
        defer delete_image(img);

        assert(false, "TODO: Copy `img' into image buffer!");
        e^.window_id = id;
    }
    e^.dirty_flag = true;

    // add image rectangle
    log.assertf(e^.window_id == id, "Image was created in a window: %d; but is updated through: %d. TODO: Do we consider this an issue?", e^.window_id, id);
    {
        width, height: f32 = 0, 0; // get these via texture->GetDesc(&TEXTURE_DESC{....});
        vertices := batch_renderer_register_image_rectangle_base(width, height, img_pos, uv_rect);

        assert(false, "TODO: Copy vertices into image vertex buffer!");
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
}

batch_renderer_construct_d3d11 :: proc(ren: ^Batch_Renderer, id: Window_ID) {
    assert(false, "TODO: Rendering");
}

batch_renderer_clear_d3d11 :: proc(ren: ^Batch_Renderer) {
    clear(&ren^.rects.d3d11.vertices);
    clear(&ren^.rects.d3d11.indexes);

    clear(&ren^.images.font_atlas.batch.d3d11.vertices);
    clear(&ren^.images.font_atlas.batch.d3d11.indexes);
}

batch_renderer_reset_d3d11 :: #force_inline proc(ren: ^Batch_Renderer) {
    batch_renderer_reset_base(ren, batch_renderer_delete_texture_d3d11);
}

batch_renderer_delete_texture_d3d11 :: proc(ren: ^Batch_Renderer, img_path: string) {
    v, ok := ren^.images.image_vertices[img_path];
    assert(ok);
    v.base.d3d11.texture->Release();
    assert(false, "TODO: Texture release!");
    delete_key(&ren^.images.image_vertices, img_path);
}

batch_renderer_delete_d3d11 :: proc(ren: ^Batch_Renderer) {
    assert(false, "TODO: Batch renderer delete!");
}
