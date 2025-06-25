package audio;

import "base:runtime"

import "core:c"
import "core:mem"

import ma "vendor:miniaudio"

Wave_Buffer :: struct {
    frames: [^]c.short,
    frames_count: u64,
    index: u64,
}

Audio_Decorder :: struct {
    config: ma.decoder_config,

    // decoded data
    using _: Wave_Buffer,
}

Audio_Manager :: struct {
    device: ma.device,
    decoder: Audio_Decorder,
    opencl: ^OpenCL_Context,
}

init_decoder :: #force_inline proc(am: ^Audio_Manager) -> ma.result {
    // now we just use the config, perhaps will the whole ma.decorder in the future
    am^.decoder.config = ma.decoder_config_init(.s16, am.device.playback.channels, am.device.sampleRate);
    
    return .SUCCESS;
}
delete_decoder :: #force_inline proc(am: ^Audio_Manager) {}

device_data_proc :: proc "cdecl" (device: ^ma.device, output, input: rawptr, frame_count_u32: u32) {
    context = runtime.default_context();

    frame_count := u64(frame_count_u32);
    channels := u64(device.playback.channels);

    mem.zero(output, int(frame_count * cast(u64)ma.get_bytes_per_sample(device.playback.playback_format) * channels));

    am := cast(^Audio_Manager)(device.pUserData);
    if am == nil || am^.decoder.frames == nil || am^.decoder.frames_count == 0 {
        return;
    }

    assert(frame_count != 0);
    frames_left := am^.decoder.frames_count - am^.decoder.index;
    frames_to_copy := min(frame_count, frames_left);

    src := &am^.decoder.frames[am^.decoder.index * channels];
    dst := cast([^]c.short)output;
    mem.copy(dst, src, int(frames_to_copy * size_of(c.short) * channels));

    am^.decoder.index += frames_to_copy;

    if frames_to_copy < frame_count {
        silence_start := mem.ptr_offset(dst, frames_to_copy * channels);
        silence_count := (frame_count - frames_to_copy) * channels;
        mem.zero(silence_start, int(silence_count * size_of(c.short)));
    }
}

init_audio_device :: proc(am: ^Audio_Manager) -> ma.result {
    device_config := ma.device_config_init(.playback);
    device_config.playback.format   = .s16;
    device_config.playback.channels = 0;
    device_config.sampleRate        = 0;
    device_config.dataCallback      = device_data_proc;
    device_config.pUserData         = am;

    ma.device_init(nil, &device_config, &am.device) or_return;
    ma.device_start(&am.device) or_return;
    return nil;
}

delete_audio_device :: proc(am: ^Audio_Manager) {
    ma.device_uninit(&am^.device);
}

init_audio_manager :: proc(opencl: ^OpenCL_Context) -> (am: ^Audio_Manager, err: Error) {
    am = new(Audio_Manager);
    am.opencl = opencl;
    init_audio_device(am) or_return;
    init_decoder(am) or_return;
    return am, nil;
}

delete_audio_manager :: proc(am: ^Audio_Manager) {
    delete_audio_device(am);
    if am^.decoder.frames != nil do ma.free(am^.decoder.frames, nil);
    free(am);
}

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