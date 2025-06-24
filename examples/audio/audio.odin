package audio;

Audio_Operation :: enum {
    Distortion,
    Echo,
    FFT,
}

// [A]udio_[O]peration_[K]ernel
AOK_DISTORTION: cstring: `
    __kernel void distortion(
        __global read_only short* input,
        __global write_only short* output)
    {
        int idx = get_global_id(0);
        output[idx] = tanh(input[idx]);
    }
`;
AOK_DISTORTION_SIZE: uint: len(AOK_DISTORTION);
AOK_DISTORTION_NAME: cstring: "distortion";