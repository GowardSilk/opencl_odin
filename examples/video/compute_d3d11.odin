package video;

import "core:c"
import "core:log"

import "vendor:directx/d3d11"
import cl "shared:opencl"

import "ui"

texture_desc_d3d11 :: #force_inline proc(texture: ^d3d11.ITexture2D) -> (tex_desc: d3d11.TEXTURE2D_DESC) {
    texture->GetDesc(&tex_desc);
    return tex_desc;
}

texture_size_d3d11 :: #force_inline proc(texture: ^d3d11.ITexture2D) -> [2]c.size_t {
    tex_desc := texture_desc_d3d11(texture);
    return [2]c.size_t {
        cast(c.size_t)tex_desc.Width,
        cast(c.size_t)tex_desc.Height,
    };
}

@(private="file")
query_kernel :: proc(target: Compute_Operation) -> cl.Kernel {
    kernels := get_app_context()^.c.kernels;
    for k in kernels do if k.type == target {
        return k.kernel;
    }
    unreachable();
}

@(private="file")
get_textures :: proc(img: string) -> (old: ^d3d11.ITexture2D, new: ^d3d11.ITexture2D) {
    old = ui.get_image_id(img).d3d11;
    assert(old != nil);
    tex_desc: d3d11.TEXTURE2D_DESC;
    old->GetDesc(&tex_desc);

    persistent := (cast(^ui.Draw_Context)context.user_ptr)^.ren.persistent;
    assert(persistent != nil);

    tex_desc.BindFlags = {.RENDER_TARGET, .SHADER_RESOURCE};
    tex_desc.MiscFlags = {.SHARED};
    device := persistent.device;
    device_context := persistent.device_context;
    assert(device->CreateTexture2D(&tex_desc, nil, &new) == 0);

    return old, new;
}

@(private="file")
bind_textures_to_opencl :: proc(app_context: ^App_Context, old: ^d3d11.ITexture2D, new: ^d3d11.ITexture2D) -> (old_mem: cl.Mem, new_mem: cl.Mem) {
    err: cl.Int;
    old_mem = cl.CreateFromD3D11Texture2DKHR(
        app_context^.c._context,
        cl.MEM_READ_ONLY,
        old,
        0,
        &err
    );
    log.assertf(err == cl.SUCCESS, "CreateFromD3D11Texture2DKHR(old) failed: %d; %s | %s", err, err_to_name(err));
    new_mem = cl.CreateFromD3D11Texture2DKHR(
        app_context^.c._context,
        cl.MEM_WRITE_ONLY,
        new,
        0,
        &err
    );
    log.assertf(err == cl.SUCCESS, "CreateFromD3D11Texture2DKHR(new) failed: %d; %s | %s", err, err_to_name(err));

    return old_mem, new_mem;
}

execute_operation_gauss_d3d11 :: proc(app_context: ^App_Context) {
    original_texture, new_texture := get_textures(app_context^.selected_image);
    original_texture_mem, new_texture_mem := bind_textures_to_opencl(app_context, original_texture, new_texture);
    defer {
        cl.ReleaseMemObject(original_texture_mem);
        cl.ReleaseMemObject(new_texture_mem);
    }

    gauss_kernel := generate_gauss_kernel(3.0);
    defer delete(gauss_kernel);
    gauss_kernel_len := cl.Int(len(gauss_kernel));

    err := cl.EnqueueAcquireD3D11ObjectsKHR(app_context^.c.queue, 1, &original_texture_mem, 0, nil, nil);
    log.assertf(err == cl.SUCCESS, "EnqueueAcquireD3D11ObjectsKHR failed: %d; %s | %s", err, err_to_name(err));
    {
        gauss_hkernel := query_kernel(.Convolution_Filter_Gauss_Horizontal);
        gauss_vkernel := query_kernel(.Convolution_Filter_Gauss_Vertical);

        /* VERTICAL */

        gauss_kernel_buf := cl.CreateBuffer(
            app_context^.c._context,
            cl.MEM_READ_ONLY | cl.MEM_USE_HOST_PTR,
            size_of(f64) * len(gauss_kernel),
            raw_data(gauss_kernel),
            &err
        );
        log.assertf(err == cl.SUCCESS, "CreateBuffer failed: %d; %s | %s", err, err_to_name(err));
        defer cl.ReleaseMemObject(gauss_kernel_buf);

        err = cl.SetKernelArg(gauss_vkernel, 0, size_of(cl.Mem), &original_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 0 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(gauss_vkernel, 1, size_of(cl.Mem), &new_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 1 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(gauss_vkernel, 2, size_of(cl.Mem), &gauss_kernel_buf);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 2 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(gauss_vkernel, 3, size_of(gauss_kernel_len), &gauss_kernel_len);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 3 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(gauss_vkernel, 4, size_of(c.float) * cast(c.size_t)gauss_kernel_len, nil);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 4 failed: %d; %s | %s", err, err_to_name(err));

        global_work_size := texture_size_d3d11(original_texture);
        local_work_size := [2]c.size_t {
            16, 16
            //cast(c.size_t)len(gauss_kernel),
            //cast(c.size_t)len(gauss_kernel),
        };
        err = cl.EnqueueNDRangeKernel(
            app_context^.c.queue,
            gauss_vkernel,
            2,
            nil,
            &global_work_size[0],
            &local_work_size[0],
            0,
            nil,
            nil
        );
        log.assertf(err == cl.SUCCESS, "EnqueueNDRangeKernel for Gauss Vertical Kernel failed: %d; %s | %s", err, err_to_name(err));

        /* HORIZONTAL */

        // first we need to recopy the result from previous op into original_texture_mem
        size := texture_size_d3d11(original_texture);
        src_origin := [3]c.size_t { 0, 0, 0, };
        region := [3]c.size_t {
            size.x, size.y, 1
        };
        err = cl.EnqueueCopyImage(
            app_context^.c.queue,
            new_texture_mem,
            original_texture_mem,
            &src_origin[0],
            &src_origin[0],
            &region[0],
            0,
            nil,
            nil,
        );
        log.assertf(err == cl.SUCCESS, "EnqueueCopyImage failed: %d; %s | %s", err, err_to_name(err));

        err  = cl.SetKernelArg(gauss_hkernel, 0, size_of(cl.Mem), &original_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 0 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(gauss_hkernel, 1, size_of(cl.Mem), &new_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 1 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(gauss_hkernel, 2, size_of(cl.Mem), &gauss_kernel_buf);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 2 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(gauss_hkernel, 3, size_of(gauss_kernel_len), &gauss_kernel_len);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 3 failed: %d; %s | %s", err, err_to_name(err));
        err  = cl.SetKernelArg(gauss_vkernel, 4, size_of(c.float) * cast(c.size_t)gauss_kernel_len, nil);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 4 failed: %d; %s | %s", err, err_to_name(err));

        err = cl.EnqueueNDRangeKernel(
            app_context^.c.queue,
            gauss_hkernel,
            2,
            nil,
            &global_work_size[0],
            &local_work_size[0],
            0,
            nil,
            nil
        );
        log.assertf(err == cl.SUCCESS, "EnqueueNDRangeKernel for Gauss Horizontal Kernel failed: %d; %s | %s", err, err_to_name(err));
    }
    err = cl.EnqueueReleaseD3D11ObjectsKHR(app_context^.c.queue, 2, &original_texture_mem, 0, nil, nil);
    log.assertf(err == cl.SUCCESS, "EnqueueReleaseD3D11ObjectsKHR failed: %d; %s | %s", err, err_to_name(err));

    original_texture->Release();
    ui.reset_image_id(app_context^.selected_image, ui.Image_Request_Result{d3d11=new_texture});
}

execute_operation_sobel_d3d11 :: proc(app_context: ^App_Context) {
    original_texture, new_texture := get_textures(app_context^.selected_image);
    original_texture_mem, new_texture_mem := bind_textures_to_opencl(app_context, original_texture, new_texture);
    defer {
        cl.ReleaseMemObject(original_texture_mem);
        cl.ReleaseMemObject(new_texture_mem);
    }

    err := cl.EnqueueAcquireD3D11ObjectsKHR(app_context^.c.queue, 1, &original_texture_mem, 0, nil, nil);
    log.assertf(err == cl.SUCCESS, "cl.EnqueueAcquireD3D11ObjectsKHR failed: %d; %s | %s", err, err_to_name(err));
    {
        sobel_kernel := query_kernel(.Convolution_Filter_Sobel);

        err = cl.SetKernelArg(sobel_kernel, 0, size_of(cl.Mem), &original_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 0 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(sobel_kernel, 1, size_of(cl.Mem), &new_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 1 failed: %d; %s | %s", err, err_to_name(err));

        global_work_size := texture_size_d3d11(original_texture);
        cl.EnqueueNDRangeKernel(
            app_context^.c.queue,
            sobel_kernel,
            2,
            nil,
            &global_work_size[0],
            nil,
            0,
            nil,
            nil
        );
    }
    err = cl.EnqueueReleaseD3D11ObjectsKHR(app_context^.c.queue, 1, &original_texture_mem, 0, nil, nil);
    log.assertf(err == cl.SUCCESS, "EnqueueReleaseD3D11ObjectsKHR failed: %d; %s | %s", err, err_to_name(err));

    original_texture->Release();
    ui.reset_image_id(app_context^.selected_image, ui.Image_Request_Result{d3d11=new_texture});
}

execute_operation_unsharp_d3d11 :: proc(app_context: ^App_Context) {
    original_texture, new_texture := get_textures(app_context^.selected_image);
    original_texture_mem, new_texture_mem := bind_textures_to_opencl(app_context, original_texture, new_texture);
    defer {
        cl.ReleaseMemObject(original_texture_mem);
        cl.ReleaseMemObject(new_texture_mem);
    }

    gauss_kernel_7x7 := [49]f64{
        0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
        0.00002292, 0.00078634, 0.00655603, 0.01330373, 0.00655603, 0.00078634, 0.00002292,
        0.00019117, 0.00655603, 0.05472157, 0.11116501, 0.05472157, 0.00655603, 0.00019117,
        0.00038771, 0.01330373, 0.11116501, 0.22508352, 0.11116501, 0.01330373, 0.00038771,
        0.00019117, 0.00655603, 0.05472157, 0.11116501, 0.05472157, 0.00655603, 0.00019117,
        0.00002292, 0.00078634, 0.00655603, 0.01330373, 0.00655603, 0.00078634, 0.00002292,
        0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
    };
    gauss_kernel := gauss_kernel_7x7[:];

    // NOTE(GowardSilk): we do not have to lock the new_texture_mem since this will left untouched by any other API code
    // (ours or D3D11's) until we reset the texture ptr at the end of this function!
    err := cl.EnqueueAcquireD3D11ObjectsKHR(app_context^.c.queue, 1, &original_texture_mem, 0, nil, nil);
    log.assertf(err == cl.SUCCESS, "cl.EnqueueAcquireD3D11ObjectsKHR failed: %d; %s | %s", err, err_to_name(err));
    {
        unsharp_kernel := query_kernel(.Convolution_Filter_Unsharp);

        gauss_kernel_buf := cl.CreateBuffer(app_context^.c._context, cl.MEM_READ_ONLY | cl.MEM_COPY_HOST_PTR, size_of(f64) * len(gauss_kernel), raw_data(gauss_kernel), &err);
        log.assertf(err == cl.SUCCESS, "CreateBuffer failed: %d; %s | %s", err, err_to_name(err));
        defer cl.ReleaseMemObject(gauss_kernel_buf);

        gauss_kernel_len := cl.Int(len(gauss_kernel));
        threshold: c.float;

        err = cl.SetKernelArg(unsharp_kernel, 0, size_of(cl.Mem), &original_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 0 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(unsharp_kernel, 1, size_of(cl.Mem), &gauss_kernel_buf);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 1 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(unsharp_kernel, 2, size_of(gauss_kernel_len), &gauss_kernel_len);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 2 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(unsharp_kernel, 3, size_of(threshold), &threshold);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 3 failed: %d; %s | %s", err, err_to_name(err));
        err = cl.SetKernelArg(unsharp_kernel, 4, size_of(cl.Mem), &new_texture_mem);
        log.assertf(err == cl.SUCCESS, "SetKernelArg 4 failed: %d; %s | %s", err, err_to_name(err));

        global_work_size := texture_size_d3d11(original_texture);
        err = cl.EnqueueNDRangeKernel(
            app_context^.c.queue,
            unsharp_kernel,
            2,
            nil,
            &global_work_size[0],
            nil,
            0,
            nil,
            nil
        );
        log.assertf(err == cl.SUCCESS, "EnqueueNDRangeKernel failed: %d; %s | %s", err, err_to_name(err));
    }
    err = cl.EnqueueReleaseD3D11ObjectsKHR(app_context^.c.queue, 1, &original_texture_mem, 0, nil, nil);
    log.assertf(err == cl.SUCCESS, "EnqueueReleaseD3D11ObjectsKHR failed: %d; %s | %s", err, err_to_name(err));

    original_texture->Release();
    ui.reset_image_id(app_context^.selected_image, ui.Image_Request_Result{d3d11=new_texture});
}
