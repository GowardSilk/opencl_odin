package audio;

import "base:runtime"

import "core:c"
import "core:mem"
import "core:strings"

import cl "shared:opencl"
import ma "vendor:miniaudio"
import sync "core:sync"

Wave_Buffer :: struct {
    frames: [^]c.short,
    frames_count: u64,
    index: u64,
}

Audio_Decorder :: struct {
    config: ma.decoder_config,

    // decoded data
    using _: Wave_Buffer,

    // temporarily couple it here...
    launch_kernel: bool,
}
Audio_Decoder_Guard :: struct {
    guard: sync.Mutex,
    decoder: Audio_Decorder,
}

Audio_Manager :: struct {
    device: ma.device,
    guarded_decoder: ^Audio_Decoder_Guard,
    opencl: ^OpenCL_Context,
}

init_decoder :: #force_inline proc(am: ^Audio_Manager) -> ma.result {
    // NOTE(GowardSilk): Even if this decoder would not be initialized during the moment
    // of actual iteration of device_data_proc, we should have no worry, since the frames
    // are nil anyway

    am^.guarded_decoder                 = new(Audio_Decoder_Guard);
    am^.guarded_decoder.decoder.config  = ma.decoder_config_init(.s16, am.device.playback.channels, am.device.sampleRate);
    am^.guarded_decoder.decoder.frames  = nil;
    am^.guarded_decoder.decoder.frames_count = 0;
    am^.guarded_decoder.decoder.index   = 0;
    am^.guarded_decoder.decoder.launch_kernel = false;
    return .SUCCESS;
}

delete_decoder :: #force_inline proc(am: ^Audio_Manager) {
    sync.lock(&am^.guarded_decoder.guard);
    defer sync.unlock(&am^.guarded_decoder.guard);
    if am^.guarded_decoder.decoder.frames != nil do ma.free(am^.guarded_decoder.decoder.frames, nil);
    am^.guarded_decoder.decoder.frames = nil;
    am^.guarded_decoder.decoder.frames_count = 0;
    am^.guarded_decoder.decoder.index = 0;
    free(am^.guarded_decoder);
}

device_data_proc :: proc "cdecl" (device: ^ma.device, output, input: rawptr, frame_count_u32: u32) {
    frame_count := u64(frame_count_u32);
    channels := u64(device.playback.channels);

    // retrieve the instance of audio decoder
    decoder: Audio_Decorder;
    opencl: ^OpenCL_Context; // NOTE(GowardSilk): this should be thread safe; no other function should use this context
    {
        am := cast(^Audio_Manager)(device.pUserData);

        opencl = am^.opencl;

        sync.lock(&am^.guarded_decoder.guard);
        decoder = am^.guarded_decoder.decoder;
        sync.unlock(&am^.guarded_decoder.guard);
    }

    // output 0(s) if there is no active sound playing
    if decoder.frames == nil || decoder.frames_count == 0 {
        mem.zero(output, int(frame_count * cast(u64)ma.get_bytes_per_sample(device.playback.playback_format) * channels));
        return;
    }

    sample_size := cast(u64)ma.get_bytes_per_sample(device.playback.playback_format);

    // copy frames to the output
    // launch audio kernel operations if any submitted
    context = runtime.default_context();
    assert(frame_count != 0);
    frames_left := decoder.frames_count - decoder.index;
    frames_to_copy := min(frame_count, frames_left);
    dst := cast([^]c.short)output;

    if decoder.launch_kernel {
        // TODO(GowardSilk): make sure we have some kind of Error pipeline established
        // for the main thread!
        assert(cl.SetKernelArg(opencl^.kernels[0].kernel, 1, size_of(cl.Mem), opencl^.audio_buffer_out) == cl.SUCCESS);
        frames_to_copy_sz := cast(c.size_t)(frames_to_copy * sample_size);
        {
            am := cast(^Audio_Manager)(device.pUserData);
            sync.mutex_lock(&am^.guarded_decoder.guard);
            src := &am^.guarded_decoder.decoder.frames[decoder.index * channels];
            opencl^.audio_buffer_in,  _ = create_buffer(opencl, src, frames_to_copy_sz, cl.MEM_COPY_HOST_PTR | cl.MEM_READ_ONLY);
            sync.mutex_unlock(&am^.guarded_decoder.guard);
        }
        opencl^.audio_buffer_out, _ = create_buffer(opencl, dst, frames_to_copy_sz, cl.MEM_WRITE_ONLY);
        assert(len(opencl^.kernels) == 1); // distortion
        assert(cl.SetKernelArg(opencl^.kernels[0].kernel, 0, size_of(cl.Mem), opencl^.audio_buffer_in) == cl.SUCCESS);
        assert(cl.EnqueueNDRangeKernel(
            opencl^.queue,
            opencl^.kernels[0].kernel,
            1,
            nil,
            &frames_to_copy_sz,
            nil,
            0,
            nil,
            nil
        ) == cl.SUCCESS);
        assert(cl.EnqueueReadBuffer(
            opencl^.queue,
            opencl^.audio_buffer_out,
            cl.TRUE,
            0,
            frames_to_copy_sz,
            &dst[0],
            0,
            nil,
            nil
        ) == cl.SUCCESS);

        am := cast(^Audio_Manager)(device.pUserData);
        sync.mutex_lock(&am^.guarded_decoder.guard);
        am^.guarded_decoder.decoder.index += frames_to_copy;
        sync.mutex_unlock(&am^.guarded_decoder.guard);

    } else {
        // increment the wave buffer's index
        // and copy the final contents from wave buffer
        // to the output
        am := cast(^Audio_Manager)(device.pUserData);
        sync.mutex_lock(&am^.guarded_decoder.guard);
        src := &am^.guarded_decoder.decoder.frames[decoder.index * channels];
        mem.copy(dst, src, int(frames_to_copy * sample_size * channels));
        am^.guarded_decoder.decoder.index += frames_to_copy;
        sync.mutex_unlock(&am^.guarded_decoder.guard);
    }

    if frames_to_copy < frame_count {
        silence_start := mem.ptr_offset(dst, frames_to_copy * channels);
        silence_count := (frame_count - frames_to_copy) * channels;
        mem.zero(silence_start, int(silence_count * sample_size));
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

delete_audio_device :: #force_inline proc(am: ^Audio_Manager) {
    ma.device_uninit(&am^.device);
}

@(private="file")
init_opencl :: #force_inline proc(am: ^Audio_Manager) -> Error {
    am^.opencl  = new(OpenCL_Context);
    am^.opencl^ = init_cl_context() or_return;
    return nil;
}

@(private="file")
delete_opencl :: #force_inline proc(am: ^Audio_Manager) {
    delete_cl_context(am^.opencl);
    free(am^.opencl);
}

init_audio_manager :: proc() -> (am: ^Audio_Manager, err: Error) {
    am = new(Audio_Manager);

    init_opencl(am) or_return;
    init_audio_device(am) or_return;
    init_decoder(am) or_return;
    return am, nil;
}

delete_audio_manager :: proc(am: ^Audio_Manager) {
    delete_opencl(am);
    delete_decoder(am);
    delete_audio_device(am);

    free(am);
}

Audio_Operation :: enum {
    Distortion,
    Echo,
    FFT,
}

Audio_Operation_Queue :: struct #no_copy {
    /* TODO(GowardSilk): instead of saving an enum array of `Audio_Operation`, we should make a queue in which the kernels fuse themselves together upon read ????*/
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