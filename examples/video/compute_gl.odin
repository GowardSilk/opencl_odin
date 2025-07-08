package video;

execute_operation_gauss_gl :: proc(app_context: ^App_Context) {
    original_texture := ui.get_image_id(app_context^.selected_image);
    // have to create new OpenGL texture (output texture)
    // note: it does not matter that we are not "in correct" window;
    // this data can be shared across all windows
    width, height, internal_format, levels: i32;
    gl.BindTexture(gl.TEXTURE_2D, original_texture);
    gl.GetTexLevelParameteriv(gl.TEXTURE_2D, 0, gl.TEXTURE_WIDTH, &width);
    gl.GetTexLevelParameteriv(gl.TEXTURE_2D, 0, gl.TEXTURE_HEIGHT, &height);
    gl.GetTexLevelParameteriv(gl.TEXTURE_2D, 0, gl.TEXTURE_INTERNAL_FORMAT, &internal_format);
    gl.GetTexParameteriv(gl.TEXTURE_2D, gl.TEXTURE_MAX_LEVEL, &levels);

    new_texture: u32;
    gl.GenTextures(1, &new_texture);
    gl.BindTexture(gl.TEXTURE_2D, new_texture);
    gl.TexImage2D(gl.TEXTURE_2D, 0, internal_format, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, nil);

    gauss_kernel := generate_gauss_kernel(3.0);
    defer delete(gauss_kernel);
    // todo: either "mark" the kernel arg with some 
    // kind of regions or just dont bother storing them
    // at all
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

    assert(false);
    cl.CreateFromGLTexture2D(
        app_context^.c._context,
        0,
        0,
        0,
        0,
        nil
    );
}

execute_operation_sobel_gl :: proc(app_context: ^App_Context) {
}

execute_operation_unsharp_gl :: proc(app_context: ^App_Context) {
}