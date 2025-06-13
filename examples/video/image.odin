package video;

import "core:os"
import "core:io"
import "core:log"
import "core:image"

import "vendor:glfw"

import cl "shared:opencl"

Image :: ^image.Image;

/**
 * @brief loads image from `img_path` 
 */
load_image :: proc(img_path: string) -> (img: Image, err: image.Error) {
    return image.load_from_file(img_path);
}

/**
 * @brief releases `img_buffer` resource
 */
delete_image :: proc(img_buffer: Image) {
    image.destroy(img_buffer);
}