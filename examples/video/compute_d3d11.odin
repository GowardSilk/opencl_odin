package video;

import "vendor:directx/d3d11"

import "vendor:vulkan"

import "ui"

execute_operation_gauss_gl :: proc(app_context: ^App_Context) {
    original_texture := ui.get_image_id(app_context^.selected_image).d3d11;
    assert(original_texture != nil);
    tex_desc: d3d11.TEXTURE2D_DESC;
    original_texture->GetDesc(&tex_desc);

    new_texture: ^d3d11.ITexture2D;
    persistent := (cast(^ui.Draw_Context)context.user_ptr)^.ren.persistent;
    assert(persistent != nil);

    device := persistent.device;
    device_context := persistent.device_context;
    assert(device->CreateTexture2D(&tex_desc, nil, &new_texture) == 0);

    gauss_kernel := generate_gauss_kernel(3.0);
    defer delete(gauss_kernel);

    base := len(app_context^.c.buffers);
    assert(
        create_buffer(
            &app_context^.c,
            gauss_kernel,
            len(gauss_kernel) * size_of(f64)
        ) == .None
    );
    assert(
        create_buffer(
            &app_context^.c,
            cast(c.int)len(gauss_kernel),
            size_of(c.int)
        ) == .None
    );

    ret: cl.Int;
    original_texture_mem := cl.CreateFromD3D11Texture2DKHR(
        app_context^.c._context,
        cl.MEM_READ_ONLY,
        original_texture,
        0,
        &ret
    );
    assert(ret == cl.SUCCESS);
    new_texture_mem := cl.CreateFromD3D11Texture2DKHR(
        app_context^.c._context,
        cl.MEM_WRITE_ONLY,
        original_texture,
        0,
        &ret
    );
    assert(ret == cl.SUCCESS);

    textures := [?]cl.Mem { original_texture_mem, new_texture_mem };
    cl.EnqueueAcquireD3D11ObjectsKHR(app_context^.c.command_queue, 2, &textures[0], 0, 0, 0);
    {
        cl.SetKernelArg(app_context^.c.kernels[0], 0, size_of(cl.Mem), original_texture_mem);
        cl.SetKernelArg(app_context^.c.kernels[0], 1, size_of(cl.Mem), new_texture_mem);
        cl.SetKernelArg(app_context^.c.kernels[0], 2, size_of(gauss_kernel) * len(gauss_kernel), gauss_kernel);
        gauss_kernel_len := cl.Int(len(gauss_kernel));
        cl.SetKernelArg(app_context^.c.kernels[0], 3, size_of(gauss_kernel_len), gauss_kernel_len);
        cl.SetKernelArg(app_context^.c.kernels[0], 4, size_of(), );

        cl.EnqueueNDRangeKernel();
    }
    cl.EnqueueReleaseD3D11ObjectsKHR(app_context^.c.command_queue, 2, &textures[0], 0, 0, 0);

    original_texture->Release();
    ui.reset_image_id(app_context^.selected_image, ui.Image_Request_Result{d3d11=new_texture});
}

execute_operation_sobel_gl :: proc(app_context: ^App_Context) {
}

execute_operation_unsharp_gl :: proc(app_context: ^App_Context) {
}