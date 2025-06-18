package video;

import "core:math"

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
    Convolution_Filter_Gauss_Op,
    Convolution_Filter_Sobel_Op,
    Convolution_Filter_Unsharp_Op,
}

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
        frac := 1.0/(math.sqrt(2.0*math.PI)*sigma);
        xf := cast(f64)x;
        return frac * math.pow(math.E, -(xf*xf)/(2*sigma*sigma));
    }

    // gaussian kernel (for 2D) is basically size*size matrix
    // but since that is always symmetric, we can just produce
    // size*1 matrix and multiply it by its transposition (1*size matrix)
    // to get the same result
    size := math.ceil(2 * sigma + 1);
    gauss = make([]f64, size, allocator);

    for i in size do gauss[i] = gauss_function(i, sigma);

    return gauss;
}

CF_GAUSSIAN_BLUR: cstring: `
    
`;
CF_GAUSSIAN_BLUR_SIZE: uint: len(CF_GAUSSIAN_BLUR);
CF_GAUSSIAN_BLUR_KERNEL_NAME: cstring: "";

CF_SOBEL_FILTER: cstring: ``;
CF_SOBEL_FILTER_SIZE: uint: len(CF_SOBEL_FILTER);
CF_SOBEL_FILTER_KERNEL_NAME: cstring: "";

CF_UNSHARP_MASK: cstring: ``;
CF_UNSHARP_MASK_SIZE: uint: len(CF_UNSHARP_MASK);
CF_UNSHARP_MASK_KERNEL_NAME: cstring: "";