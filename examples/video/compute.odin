package video;

import "core:c"
import "core:log"
import "core:math"

import gl "vendor:OpenGL"
import cl "shared:opencl"

import "ui"

// 1. Convolution Filters (Blurs, Sharpening, Edge Detection)
//      Gaussian Blur (separable and non-separable)
//      Sobel Filter (edge detection)
//      Unsharp Mask (sharpening)
// 2. Histogram Equalization
//      Compute histogram (atomic ops / reduction).
//      Remap image with CDF
// 3. Mandelbrot / Julia Fractal Rendering
// 4. Bilateral Filtering
// 5. Image Morphological Operations
//      Dilation
//      Erosion
//      Opening / Closing

Compute_Operation :: enum {
    Convolution_Filter_Gauss_Horizontal = 1,
    Convolution_Filter_Gauss_Vertical   = 2,

    Convolution_Filter_Sobel            = 4,

    Convolution_Filter_Unsharp          = 8,
}
Compute_Operations :: bit_set[Compute_Operation];

CF_GAUSS_BIT   : Compute_Operation : .Convolution_Filter_Gauss_Horizontal | .Convolution_Filter_Gauss_Vertical;
CF_SOBEL_BIT   : Compute_Operation : .Convolution_Filter_Sobel;
CF_UNSHARP_BIT : Compute_Operation : .Convolution_Filter_Unsharp;

CF_GAUSS   : Compute_Operations : {.Convolution_Filter_Gauss_Horizontal, .Convolution_Filter_Gauss_Vertical};
CF_SOBEL   : Compute_Operations : {.Convolution_Filter_Sobel};
CF_UNSHARP : Compute_Operations : {.Convolution_Filter_Unsharp};

/* =========================================
 *                CF_GAUSSIAN
 * ========================================= */

/**
 * @brief generates a map (Gaussian kernel) that will be used as the filtering matrix for the image
 * @param sigma larger sigma results in a wider filter, allowing more smoothing, while a smaller sigma
 * keeps the response tighter, preserving more details
 * @return slice (Guassian kernel) for one axis
 */
generate_gauss_kernel :: proc(sigma: f64, allocator := context.allocator) -> []f64 {
    gauss_function :: proc(x: int, sigma: f64) -> f64 {
        frac := 1.0/(math.sqrt_f64(2.0*math.PI)*sigma);
        xf := cast(f64)x;
        return frac * math.pow(math.E, -(xf*xf)/(2*sigma*sigma));
    }

    // gaussian kernel (for 2D) is basically size*size matrix
    // but since that is always symmetric, we can just produce
    // size*1 matrix and multiply it by its transposition (1*size matrix)
    // to get the same result
    size := cast(int)math.ceil(2 * sigma + 1);
    gauss := make([]f64, size, allocator);

    for i in 0..<size do gauss[i] = gauss_function(i, sigma);

    return gauss;
}

CF_GAUSSIAN_BLUR: cstring: `
// note: image2d_t are always __global
__kernel void cf_gaussian_blur_horizontal(
    read_only image2d_t input,
    write_only image2d_t output,
    __constant double* gauss_kernel,
    const int gauss_kernel_size,
    __local float* local_tile)
{
    const int radius = gauss_kernel_size / 2;

    const int gid_x = get_global_id(0);
    const int gid_y = get_global_id(1);
    const int lid_x = get_local_id(0);
    const int lid_y = get_local_id(1);
    const int lsize_x = get_local_size(0);
    const int lsize_y = get_local_size(1);

    const int tile_width = lsize_x + gauss_kernel_size;

    const int lx = lid_x + radius;
    const int ly = lid_y;

    int local_index = ly * tile_width + lx;

    int2 coord = (int2)(gid_x, gid_y);
    float4 pixel = read_imagef(input, CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST, coord);
    local_tile[local_index] = pixel.x;

    // left "halo"
    if (lid_x - radius < 0) {
        int2 left_coord = (int2)(clamp(gid_x - radius, 0, get_image_width(input)-1), gid_y);
        float4 left_pixel = read_imagef(input, CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST, left_coord);
        local_tile[local_index] = left_pixel.x;
    }

    // right "halo"
    if (lid_x >= lsize_x - radius) {
        int2 right_coord = (int2)(clamp(gid_x + radius, 0, get_image_width(input)-1), gid_y);
        float4 right_pixel = read_imagef(input, CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST, right_coord);
        local_tile[local_index] = right_pixel.x;
    }

    barrier(CLK_LOCAL_MEM_FENCE);

    // multiply one row by gauss_kernel
    float result = 0.0f;
    for (int k = -radius; k <= radius; k++) {
        result += gauss_kernel[k + radius] * local_tile[local_index + k];
    }

    write_imagef(output, (int2)(gid_x, gid_y), (float4)(result, result, result, 1.0f));
}

__kernel void cf_gaussian_blur_vertical(
    __read_only image2d_t input,
    __write_only image2d_t output,
    __constant double* gauss_kernel,
    const int gauss_kernel_size,
    __local float* local_tile)
{
    const int radius = gauss_kernel_size / 2;

    const int gid_x = get_global_id(0);
    const int gid_y = get_global_id(1);
    const int lid_x = get_local_id(0);
    const int lid_y = get_local_id(1);
    const int lsize_x = get_local_size(0);
    const int lsize_y = get_local_size(1);

    const int tile_height = lsize_y + gauss_kernel_size;

    const int lx = lid_x;
    const int ly = lid_y + radius;

    int local_index = ly * lsize_x + lx;

    int2 coord = (int2)(gid_x, gid_y);
    float4 pixel = read_imagef(input, CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST, coord);
    local_tile[local_index] = pixel.x;

    // top "halo"
    if (lid_y < radius) {
        int2 top_coord = (int2)(gid_x, clamp(gid_y - radius, 0, get_image_height(input)-1));
        float4 top_pixel = read_imagef(input, CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST, top_coord);
        local_tile[(lid_y) * lsize_x + lx] = top_pixel.x;
    }

    // bottom "halo"
    if (lid_y >= lsize_y - radius) {
        int2 bottom_coord = (int2)(gid_x, clamp(gid_y + radius, 0, get_image_height(input)-1));
        float4 bottom_pixel = read_imagef(input, CLK_NORMALIZED_COORDS_FALSE | CLK_ADDRESS_CLAMP | CLK_FILTER_NEAREST, bottom_coord);
        local_tile[(ly + radius) * lsize_x + lx] = bottom_pixel.x;
    }

    barrier(CLK_LOCAL_MEM_FENCE);

    // vertical convolution
    float result = 0.0f;
    for (int k = -radius; k <= radius; k++) {
        result += gauss_kernel[k + radius] * local_tile[(ly + k) * lsize_x + lx];
    }

    write_imagef(output, (int2)(gid_x, gid_y), (float4)(result, result, result, 1.0f));
}
`;
CF_GAUSSIAN_BLUR_SIZE: uint: len(CF_GAUSSIAN_BLUR);
CF_GAUSSIAN_BLUR_KERNEL1_NAME: cstring: "cf_gaussian_blur_horizontal";
CF_GAUSSIAN_BLUR_KERNEL2_NAME: cstring: "cf_gaussian_blur_vertical";

CF_SOBEL_FILTER: cstring: ``;
CF_SOBEL_FILTER_SIZE: uint: len(CF_SOBEL_FILTER);
CF_SOBEL_FILTER_KERNEL_NAME: cstring: "";

CF_UNSHARP_MASK: cstring: ``;
CF_UNSHARP_MASK_SIZE: uint: len(CF_UNSHARP_MASK);
CF_UNSHARP_MASK_KERNEL_NAME: cstring: "";

execute_operations :: proc(app_context: ^App_Context) {
    if CF_GAUSS_BIT in app_context^.c.operations {
        log.info("Gauss");
        execute_operation_gauss(app_context);
    }
    if CF_SOBEL_BIT in app_context^.c.operations {
        log.info("Sobel");
    }
    if CF_UNSHARP_BIT in app_context^.c.operations {
        log.info("Unsharp");
    }
}

execute_operation_gauss :: proc(app_context: ^App_Context) {
    switch app_context^.backend {
        case .D3D11:
            execute_operation_gauss_d3d11(app_context);
            return;
        case .GL:
            execute_operation_gauss_gl(app_context);
            return;
    }

    unreachable();
}

execute_operation_sobel :: proc(app_context: ^App_Context) {
    switch app_context^.backend {
        case .D3D11:
            execute_operation_sobel_d3d11(app_context);
            return;
        case .GL:
            execute_operation_sobel_gl(app_context);
            return;
    }

    unreachable();
}

execute_operation_unsharp :: proc(app_context: ^App_Context) {
    switch app_context^.backend {
        case .D3D11:
            execute_operation_unsharp_d3d11(app_context);
            return;
        case .GL:
            execute_operation_unsharp_gl(app_context);
            return;
    }

    unreachable();
}