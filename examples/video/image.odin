package video;

import "vendor:glfw"

import cl "shared:opencl"

Image :: cl.GLuint;

/**
 * @brief loads image from `img_path` 
 */
load_image :: proc(img_path: string) -> Image {
    return 0;
}

/**
 * @brief releases `img_buffer` resource
 */
delete_image :: proc(img_buffer: Image) {
}