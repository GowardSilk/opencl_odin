package audio;

import "base:runtime"

import "core:c"
import "core:fmt"
import "core:mem"

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
    using wb: Wave_Buffer,

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
    settings: Audio_Operation_Settings,
}

delete_wavebuffer :: #force_inline proc(wb: ^Wave_Buffer) {
    if wb^.frames != nil do ma.free(wb^.frames, nil);
    wb^.frames = nil;
    wb^.frames_count = 0;
    wb^.index = 0;
}

init_decoder :: proc(am: ^Audio_Manager) -> ma.result {
    // NOTE(GowardSilk): Even if this decoder would not be initialized during the moment
    // of actual iteration of device_data_proc, we should have no worry, since the frames
    // are nil anyway

    am^.guarded_decoder                 = new(Audio_Decoder_Guard);
    am^.guarded_decoder.decoder.config  = ma.decoder_config_init(.s16, am.device.playback.channels, am.device.sampleRate);
    return .SUCCESS;
}

delete_decoder :: proc(am: ^Audio_Manager) {
    sync.lock(&am^.guarded_decoder.guard);
    delete_wavebuffer(&am^.guarded_decoder.decoder.wb);
    sync.unlock(&am^.guarded_decoder.guard);
    free(am^.guarded_decoder);
}

MAX_DEVICE_DATA_FRAME_COUNT :: 4096;
MAX_OPENCL_BUFFER_FRAME_COUNT :: 10 * MAX_DEVICE_DATA_FRAME_COUNT;

@(private="file")
increment_decoder_index :: #force_inline proc(guarded_decoder: ^Audio_Decoder_Guard, incr: u64) {
    sync.lock(&guarded_decoder^.guard);
    guarded_decoder^.decoder.index += incr;
    sync.unlock(&guarded_decoder^.guard);
}

@(private="file")
device_data_proc_request_outbuffer :: proc(device: ^ma.device, frame_count: u64, out: [^]c.short) {
    am := cast(^Audio_Manager)(device.pUserData);
    assert(am != nil);

    opencl := am^.opencl;
    sample_size := cast(u64)ma.get_bytes_per_sample(device.playback.playback_format);
    channels    := cast(u64)device.playback.channels;

    // NOTE(GowardSilk): For the allocations to really make sense, it will be better to initialize the buffers to a larger
    // size than just MAX_DEVICE_DATA_FRAME_COUNT
    buffer_size: c.size_t = MAX_OPENCL_BUFFER_FRAME_COUNT * cast(c.size_t)(sample_size * channels);
    eat_byte_pos := opencl^.eat_pos * channels;
    frame_byte_count := frame_count * channels;

    // Initialize input/output audio buffers when needed
    if opencl^.audio_buffer_in == nil {
        ret: cl.Int;
        opencl^.audio_buffer_in = cl.CreateBuffer(
            opencl^._context,
            cl.MEM_ALLOC_HOST_PTR | cl.MEM_READ_ONLY,
            buffer_size,
            nil,
            &ret
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to create buffer: %v; (aka %s | %s)", ret, err_to_name(ret));
        assert(opencl^.audio_buffer_in != nil);

        opencl^.audio_buffer_out = cl.CreateBuffer(
            opencl^._context,
            cl.MEM_WRITE_ONLY,
            buffer_size,
            nil,
            &ret
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to create buffer: %v; (aka %s | %s)", ret, err_to_name(ret));
        assert(opencl^.audio_buffer_out != nil);

        opencl^.audio_buffer_out_host = make([]c.short, buffer_size);
        assert(opencl^.audio_buffer_out_host != nil);

        // process the first frames
        device_data_proc_process_buffer(device);

        mem.copy(out, &opencl^.audio_buffer_out_host[eat_byte_pos], cast(int)frame_byte_count);
        opencl^.eat_pos += frame_count;
        increment_decoder_index(am^.guarded_decoder, frame_count);
        fmt.eprintfln("Initial Index: %d; Added: %d; Len: %d", am^.guarded_decoder.decoder.index, frame_count, len(opencl^.audio_buffer_out_host));

        return;
    }

    if opencl^.eat_pos + frame_count >= MAX_OPENCL_BUFFER_FRAME_COUNT {
        fmt.eprintfln("Eat pos: %d; Frame count: %d; Len/Sum: %d/%d",
            opencl^.eat_pos, frame_count, len(opencl^.audio_buffer_out_host), opencl^.eat_pos + frame_count)
        // eat the rest of the buffer and read next chunk of which 
        // <<len_of_host_ptr - eat_pos - frame_count>> will
        // be copied again to the output
        delta := MAX_OPENCL_BUFFER_FRAME_COUNT - opencl^.eat_pos;
        fmt.eprintfln("Delta: %d", delta);
        mem.copy(out, &opencl^.audio_buffer_out_host[eat_byte_pos], cast(int)(delta * sample_size * channels));
        opencl^.eat_pos = 0;

        device_data_proc_process_buffer(device);
        rest := frame_count - delta;
        if rest != 0 {
            fmt.assertf(
                rest > 0 && rest < MAX_OPENCL_BUFFER_FRAME_COUNT,
                "The frame count (%d) is %dx larger than the maximal buffer size (%d)!",
                frame_count,
                frame_count / MAX_OPENCL_BUFFER_FRAME_COUNT,
                len(opencl^.audio_buffer_out_host)
            );
            mem.copy(&out[delta * channels], &opencl^.audio_buffer_out_host[0], cast(int)(rest * sample_size * channels));
            opencl^.eat_pos = rest;
        }

        increment_decoder_index(am^.guarded_decoder, frame_count);

        return;
    }

    mem.copy(out, &opencl^.audio_buffer_out_host[eat_byte_pos], cast(int)(frame_byte_count * sample_size));
    opencl^.eat_pos += frame_count;
    increment_decoder_index(am^.guarded_decoder, frame_count);
    fmt.eprintfln("Eat: %d; Index: %d; Added: %d; Len: %d", opencl^.eat_pos, am^.guarded_decoder.decoder.index, frame_count, len(opencl^.audio_buffer_out_host));
}

@(private="file")
device_data_proc_process_buffer :: proc(device: ^ma.device) {
    am := cast(^Audio_Manager)(device.pUserData);
    assert(am != nil);

    opencl := am^.opencl;
    sample_size := cast(u64)ma.get_bytes_per_sample(device.playback.playback_format);
    channels := cast(u64)device.playback.channels;
    buffer_size := cast(c.size_t)len(opencl^.audio_buffer_out_host);

    // TODO(GowardSilk): make sure we have some kind of Error pipeline established for the main thread!
    {
        sync.mutex_lock(&am^.guarded_decoder.guard);
        src := &am^.guarded_decoder.decoder.frames[am^.guarded_decoder.decoder.index * channels];

        assert(opencl^.audio_buffer_in != nil);

        ret: cl.Int;
        buf_map := cl.EnqueueMapBuffer(opencl^.queue, opencl^.audio_buffer_in, cl.TRUE, cl.MAP_WRITE, 0, buffer_size, 0, nil, nil, &ret);
        fmt.assertf(ret == cl.SUCCESS, "Failed to map buffer: %v; (aka %s | %s)", ret, err_to_name(ret));

        mem.copy(buf_map, src, auto_cast buffer_size);

        ret = cl.EnqueueUnmapMemObject(opencl^.queue, opencl^.audio_buffer_in, buf_map, 0, nil, nil);
        assert(ret == cl.SUCCESS);

        sync.mutex_unlock(&am^.guarded_decoder.guard);
    }

    input_buffer := &opencl^.audio_buffer_in;
    output_buffer := &opencl^.audio_buffer_out;
    first_kernel := true;

    if am^.settings.distortion {
        if first_kernel == true do first_kernel = false;
        else { unreachable(/* copy output_buffer -> input_buffer */); }

        ret := cl.SetKernelArg(opencl^.kernels[0].kernel, 0, size_of(cl.Mem), input_buffer);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret = cl.SetKernelArg(opencl^.kernels[0].kernel, 1, size_of(cl.Mem), output_buffer);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret = cl.EnqueueNDRangeKernel(
            opencl^.queue,
            opencl^.kernels[0].kernel,
            1,
            nil,
            &buffer_size,
            nil,
            0,
            nil,
            nil
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue kernel! Reason: %d | %s; %s", ret, err_to_name(ret));
    }

    if am^.settings.echo {
        if first_kernel == true do first_kernel = false;
        else {
            /* copy output_buffer -> input_buffer */
            ret := cl.EnqueueCopyBuffer(opencl^.queue, output_buffer^, input_buffer^, 0, 0, buffer_size, 0, nil, nil);
            fmt.assertf(ret == cl.SUCCESS, "Failed to copy output_buffer -> input_buffer! Reason: %d | %s; %s", ret, err_to_name(ret));
        }

        ret := cl.SetKernelArg(opencl^.kernels[1].kernel, 0, size_of(cl.Mem), input_buffer); // input
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret = cl.SetKernelArg(opencl^.kernels[1].kernel, 1, size_of(cl.Mem), output_buffer); // output
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        alpha: c.float = 0.3;
        ret = cl.SetKernelArg(opencl^.kernels[1].kernel, 2, size_of(c.float), &alpha); // alpha
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        dt: cl.Uint = device.sampleRate / 2;
        assert(cast(uint)dt <= buffer_size);
        ret = cl.SetKernelArg(opencl^.kernels[1].kernel, 3, size_of(cl.Uint), &dt); // dt
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret = cl.EnqueueNDRangeKernel(
            opencl^.queue,
            opencl^.kernels[1].kernel,
            1,
            nil,
            &buffer_size,
            nil,
            0,
            nil,
            nil
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue kernel! Reason: %d | %s; %s", ret, err_to_name(ret));
    }

    if am^.settings.fft do assert(false, "TODO(GowardSilk): Implement FFT!");

    assert(opencl^.eat_pos == 0);
    ret := cl.EnqueueReadBuffer(
        opencl^.queue,
        output_buffer^,
        cl.TRUE,
        0,
        buffer_size,
        &opencl^.audio_buffer_out_host[0],
        0,
        nil,
        nil
    );
    fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue read buffer! Reason: %d | %s; %s", ret, err_to_name(ret));
}

device_data_proc :: proc "cdecl" (device: ^ma.device, output, input: rawptr, frame_count_u32: u32) {
    context = runtime.default_context();
    frame_count := u64(frame_count_u32);
    channels    := u64(device.playback.channels);
    sample_size := cast(u64)ma.get_bytes_per_sample(device.playback.playback_format);

    mem.zero(output, int(frame_count * sample_size * channels));

    // retrieve the instance of audio decoder
    decoder: Audio_Decorder;
    opencl: ^OpenCL_Context; // NOTE(GowardSilk): this should be thread safe
    {
        am := cast(^Audio_Manager)(device.pUserData);
        assert(am != nil);

        sync.lock(&am^.guarded_decoder.guard);
        decoder = am^.guarded_decoder.decoder;
        sync.unlock(&am^.guarded_decoder.guard);

        opencl = am^.opencl;
    }

    // exit if there is no active sound playing
    if decoder.frames == nil || decoder.frames_count == 0 do return;

    // copy frames to the output
    // launch audio kernel operations if any submitted
    assert(frame_count != 0);
    frames_left := decoder.frames_count - decoder.index;
    frames_to_copy := min(frame_count, frames_left);
    dst := cast([^]c.short)output;

    if decoder.launch_kernel {
        device_data_proc_request_outbuffer(device, frames_to_copy, dst);
    } else {
        // increment the wave buffer's index
        // and copy the final contents from wave buffer
        // to the output
        am := cast(^Audio_Manager)(device.pUserData);
        sync.mutex_lock(&am^.guarded_decoder.guard);
        src := &am^.guarded_decoder.decoder.frames[am^.guarded_decoder.decoder.index * channels];
        mem.copy(dst, src, int(frames_to_copy * sample_size * channels));
        am^.guarded_decoder.decoder.index += frames_to_copy;
        sync.mutex_unlock(&am^.guarded_decoder.guard);
    }

    if frames_to_copy < frame_count {
        silence_start := mem.ptr_offset(dst, frames_to_copy * channels);
        silence_count := frame_count - frames_to_copy;
        mem.zero(silence_start, int(silence_count * sample_size * channels));

        // if this branch is executed
        // we know that we have are at the end of the playback
        am := cast(^Audio_Manager)(device.pUserData);
        sync.lock(&am^.guarded_decoder.guard);
        delete_wavebuffer(&am^.guarded_decoder.decoder.wb);
        sync.unlock(&am^.guarded_decoder.guard);
    }
}

init_audio_device :: proc(am: ^Audio_Manager) -> ma.result {
    device_config := ma.device_config_init(.playback);
    device_config.playback.format    = .s16;
    device_config.playback.channels  = 0;
    device_config.sampleRate         = 0;
    device_config.dataCallback       = device_data_proc;
    device_config.pUserData          = am;
    device_config.periodSizeInFrames = MAX_DEVICE_DATA_FRAME_COUNT;

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
    delete_audio_device(am);
    delete_opencl(am);
    delete_decoder(am);

    free(am);
}

Audio_Operation :: enum {
    Distortion,
    Echo,
    FFT,
}

Audio_Operation_Settings :: struct #no_copy {
    distortion: bool,
    echo: bool,
    fft: bool,
}

// [A]udio_[O]peration_[K]ernel

AOK_DISTORTION: cstring: `
    __kernel void distortion(
        __global short* input,
        __global short* output)
    {
        int idx = get_global_id(0);
        output[idx] = abs(input[idx]);
    }
`;
AOK_DISTORTION_SIZE: uint: len(AOK_DISTORTION);
AOK_DISTORTION_NAME: cstring: "distortion";

AOK_ECHO: cstring: `
    // I(x) + I(x - dt)*alpha; alpha is cca. <0.3; 0.7>
    __kernel void echo(
        __global short* input,
        __global short* output,
        const float alpha,
        const uint dt)
    {
        int idx = get_global_id(0);
        short current = input[idx];
        short echoed = 0;
        
        if (idx >= dt)
            echoed = (short)(alpha * (float)input[idx - dt]);

        // note: len(input) == len(output)
        current += echoed;
        output[idx] = clamp(current, (short)-32768, (short)32767);
    }
`;
AOK_ECHO_SIZE: uint: len(AOK_ECHO);
AOK_ECHO_NAME: cstring: "echo";

AOK_FFT: cstring: `
    __kernel void fft(
        __global short* input,
        __global short* output)
    {
        int idx = get_global_id(0);
        output[idx] = abs(input[idx]);
    }
`;
AOK_FFT_SIZE: uint: len(AOK_FFT);
AOK_FFT_NAME: cstring: "fft";