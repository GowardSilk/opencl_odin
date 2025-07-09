package video;

import "core:c"
import "core:log"

import "vendor:directx/d3d11"
import cl "shared:opencl"

import "ui"

execute_operation_gauss_d3d11 :: proc(app_context: ^App_Context) {
    original_texture := ui.get_image_id(app_context^.selected_image).d3d11;
    assert(original_texture != nil);
    tex_desc: d3d11.TEXTURE2D_DESC;
    original_texture->GetDesc(&tex_desc);

    new_texture: ^d3d11.ITexture2D;
    persistent := (cast(^ui.Draw_Context)context.user_ptr)^.ren.persistent;
    assert(persistent != nil);

    tex_desc.BindFlags = {.RENDER_TARGET, .SHADER_RESOURCE};
    tex_desc.MiscFlags = {.SHARED};
    device := persistent.device;
    device_context := persistent.device_context;
    assert(device->CreateTexture2D(&tex_desc, nil, &new_texture) == 0);

    gauss_kernel := generate_gauss_kernel(3.0);
    defer delete(gauss_kernel);

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
    cl.EnqueueAcquireD3D11ObjectsKHR(app_context^.c.queue, 2, &textures[0], 0, nil, nil);
    {
        cl.SetKernelArg(app_context^.c.kernels[0].kernel, 0, size_of(cl.Mem), original_texture_mem);
        cl.SetKernelArg(app_context^.c.kernels[0].kernel, 1, size_of(cl.Mem), new_texture_mem);
        cl.SetKernelArg(app_context^.c.kernels[0].kernel, 2, size_of(gauss_kernel) * len(gauss_kernel), raw_data(gauss_kernel));
        gauss_kernel_len := cl.Int(len(gauss_kernel));
        cl.SetKernelArg(app_context^.c.kernels[0].kernel, 3, size_of(gauss_kernel_len), &gauss_kernel_len);
        //cl.SetKernelArg(app_context^.c.kernels[0].kernel, 4, size_of(), );

        //cl.EnqueueNDRangeKernel();
    }
    cl.EnqueueReleaseD3D11ObjectsKHR(app_context^.c.queue, 2, &textures[0], 0, nil, nil);

    original_texture->Release();
    ui.reset_image_id(app_context^.selected_image, ui.Image_Request_Result{d3d11=new_texture});
}

execute_operation_sobel_d3d11 :: proc(app_context: ^App_Context) {
}

execute_operation_unsharp_d3d11 :: proc(app_context: ^App_Context) {
    original_texture := ui.get_image_id(app_context^.selected_image).d3d11;
    assert(original_texture != nil);
    tex_desc: d3d11.TEXTURE2D_DESC;
    original_texture->GetDesc(&tex_desc);

    tex_desc.Usage     = .DEFAULT;
    tex_desc.BindFlags = {.RENDER_TARGET, .SHADER_RESOURCE};
    tex_desc.MiscFlags = {.SHARED};
    new_texture: ^d3d11.ITexture2D;
    persistent := (cast(^ui.Draw_Context)context.user_ptr)^.ren.persistent;
    assert(persistent != nil);

    device := persistent.device;
    assert(device->CreateTexture2D(&tex_desc, nil, &new_texture) == 0);

    gauss_kernel := generate_gauss_kernel(3.0);
    defer delete(gauss_kernel);

    ret: cl.Int;
    original_texture_mem := cl.CreateFromD3D11Texture2DKHR(
        app_context^.c._context,
        cl.MEM_READ_ONLY,
        original_texture,
        0,
        &ret
    );
    log.assertf(ret == cl.SUCCESS, "Failed to create OpenCL Texture buffer. Reason: %d; %s | %s", ret, err_to_name(ret));
    defer delete_buffer(original_texture_mem);
    new_texture_mem := cl.CreateFromD3D11Texture2DKHR(
        app_context^.c._context,
        cl.MEM_WRITE_ONLY,
        new_texture,
        0,
        &ret
    );
    log.assertf(ret == cl.SUCCESS, "Failed to create OpenCL Texture buffer. Reason: %d; %s | %s", ret, err_to_name(ret));
    defer delete_buffer(new_texture_mem);

    textures := [?]cl.Mem { original_texture_mem, new_texture_mem };
    assert(cl.EnqueueAcquireD3D11ObjectsKHR(app_context^.c.queue, 2, &textures[0], 0, nil, nil) == cl.SUCCESS);
    {
        unsharp_kernel: cl.Kernel;
        for kernel in app_context^.c.kernels do if kernel.type == .Convolution_Filter_Unsharp {
            unsharp_kernel = kernel.kernel;
            break;
        }
        assert(unsharp_kernel != nil);

        gauss_kernel_buf := cl.CreateBuffer(app_context^.c._context, cl.MEM_READ_ONLY | cl.MEM_COPY_HOST_PTR, size_of(f64) * len(gauss_kernel), raw_data(gauss_kernel), &ret);
        assert(ret == cl.SUCCESS);
        defer cl.ReleaseMemObject(gauss_kernel_buf);
        gauss_kernel_len := cl.Int(len(gauss_kernel));
        threshold: c.float;

        err := cl.SetKernelArg(unsharp_kernel, 0, size_of(cl.Mem), original_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 0 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(unsharp_kernel, 1, size_of(cl.Mem), gauss_kernel_buf);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 1 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(unsharp_kernel, 2, size_of(gauss_kernel_len), &gauss_kernel_len);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 2 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(unsharp_kernel, 3, size_of(threshold), &threshold);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 3 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(unsharp_kernel, 4, size_of(cl.Mem), new_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 4 failed: %d; %s | %s", err, err_to_name(err));

        global_work_size := c.size_t(tex_desc.Width * tex_desc.Height);
        local_work_size := 3;
        cl.EnqueueNDRangeKernel(
            app_context^.c.queue,
            unsharp_kernel,
            2,
            nil,
            &global_work_size,
            nil,
            0, nil, nil
        );
    }
    cl.EnqueueReleaseD3D11ObjectsKHR(app_context^.c.queue, 2, &textures[0], 0, nil, nil);

    original_texture->Release();
    ui.reset_image_id(app_context^.selected_image, ui.Image_Request_Result{d3d11=new_texture});
}