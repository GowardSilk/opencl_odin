package audio;

import "base:runtime"

import "core:c"
import "core:fmt"
import "core:mem"
import "core:math"
import "core:sync"

import cl "shared:opencl"
import ma "vendor:miniaudio"

Wave_Buffer :: struct {
    frames:         [^]c.short,
    frames_count:   u64,
    index:          u64,
    max_amplitude:  c.short, /**< index of the frame with the peak amplitude (note: when eq to ~0, amplitutde has not been calculate yet) */
    max_amplitude_valid:  bool, /**< indicates whether the max amplitude has to be recalculated again */
}

Audio_Decorder :: struct {
    config: ma.decoder_config,

    // decoded data
    using wb: Wave_Buffer,

    // temporarily couple it here...
    launch_kernel: bool,
    pause: bool,
}
Audio_Decoder_Guard :: struct {
    guard: sync.Mutex,
    decoder: Audio_Decorder,
}

Audio_Manager :: struct {
    device: ma.device,
    guarded_decoder: ^Audio_Decoder_Guard,
    opencl: ^OpenCL_Context,
    operations: AOK_Operations,
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
    am^.guarded_decoder.decoder.max_amplitude_valid = true;
    return .SUCCESS;
}

delete_decoder :: proc(am: ^Audio_Manager) {
    sync.lock(&am^.guarded_decoder.guard);
    delete_wavebuffer(&am^.guarded_decoder.decoder.wb);
    sync.unlock(&am^.guarded_decoder.guard);
    free(am^.guarded_decoder);
}

MAX_DEVICE_DATA_FRAME_COUNT :: 4096;
MAX_OUT_HOST_FRAME_COUNT :: 64 * MAX_DEVICE_DATA_FRAME_COUNT;

@(private="file")
increment_decoder_index :: #force_inline proc(guarded_decoder: ^Audio_Decoder_Guard, incr: u64) {
    sync.lock(&guarded_decoder^.guard);
    guarded_decoder^.decoder.index += incr;
    sync.unlock(&guarded_decoder^.guard);
}

@(private="file")
device_data_proc_request_outbuffer :: proc(device: ^ma.device, expected_buffer_size: c.size_t, frame_count: u64, out: [^]c.short) {
    am := cast(^Audio_Manager)(device.pUserData);
    assert(am != nil);

    opencl := am^.opencl;
    sample_size := cast(u64)ma.get_bytes_per_sample(device.playback.playback_format);
    channels    := cast(u64)device.playback.channels;

    host_out_chunk_size := MAX_OUT_HOST_FRAME_COUNT * cast(c.size_t)channels;
    eat_sample_pos := opencl^.eat_pos * channels;
    frame_byte_count := frame_count * channels;

    // Initialize input/output audio buffers when needed
    init_opencl_audio_buffers :: proc(using am: ^Audio_Manager, expected_buffer_size: c.size_t) {
        // AUDIO INPUT BUFFER
        ret: cl.Int;
        opencl^.audio_buffer_in.mem = cl.CreateBuffer(
            opencl^._context,
            cl.MEM_ALLOC_HOST_PTR | cl.MEM_READ_ONLY,
            expected_buffer_size,
            nil,
            &ret
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to create buffer: %v; (aka %s | %s)", ret, err_to_name(ret));
        assert(opencl^.audio_buffer_in.mem != nil);
        opencl^.audio_buffer_in.size = expected_buffer_size;

        // MAP AUDIO INPUT BUFFER
        sync.mutex_lock(&guarded_decoder.guard);
        {
            src := &guarded_decoder.decoder.frames[0];

            buf_map := cl.EnqueueMapBuffer(
                opencl^.queue,
                opencl^.audio_buffer_in.mem,
                cl.TRUE,
                cl.MAP_WRITE,
                0,
                expected_buffer_size,
                0,
                nil,
                nil,
                &ret
            );
            fmt.assertf(ret == cl.SUCCESS, "Failed to map buffer: %v; (aka %s | %s)", ret, err_to_name(ret));

            mem.copy(buf_map, src, int(expected_buffer_size));

            ret = cl.EnqueueUnmapMemObject(opencl^.queue, opencl^.audio_buffer_in.mem, buf_map, 0, nil, nil);
            fmt.assertf(ret == cl.SUCCESS, "Failed to unmap buffer: %v; (aka %s | %s)", ret, err_to_name(ret));
        }
        sync.mutex_unlock(&am^.guarded_decoder.guard);

        // AUDIO OUTPUT BUFFER
        opencl^.audio_buffer_out.mem = cl.CreateBuffer(
            opencl^._context,
            cl.MEM_ALLOC_HOST_PTR | cl.MEM_WRITE_ONLY,
            expected_buffer_size,
            nil,
            &ret
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to create buffer: %v; (aka %s | %s)", ret, err_to_name(ret));
        assert(opencl^.audio_buffer_out.mem != nil);
        opencl^.audio_buffer_out.size = expected_buffer_size;
    }

    @static last_ops := AOK_Operations{};

    if opencl^.audio_buffer_in.mem == nil {
        init_opencl_audio_buffers(am, expected_buffer_size);

        // allocate the CPU (aka host) output buffer
        assert(opencl^.audio_buffer_out_host == nil);
        opencl^.audio_buffer_out_host = make([]c.short, host_out_chunk_size);
        assert(opencl^.audio_buffer_out_host != nil);

        // process the first frames
        device_data_proc_process_buffer(device, 0);

        mem.copy(out, &opencl^.audio_buffer_out_host[eat_sample_pos], cast(int)frame_byte_count);
        opencl^.eat_pos += frame_count;
        increment_decoder_index(am^.guarded_decoder, frame_count);

        mem.copy(&last_ops, &am^.operations, size_of(AOK_Operations));

        return;
    } else if mem.compare_ptrs(&last_ops, &am^.operations, size_of(AOK_Operations)) != 0 {
        if opencl^.audio_buffer_in.size < expected_buffer_size {
            // "reallocate"
            delete_buffer(&opencl^.audio_buffer_in);
            delete_buffer(&opencl^.audio_buffer_out);
            mem.zero_slice(opencl^.audio_buffer_out_host);
            opencl^.eat_pos = 0;

            init_opencl_audio_buffers(am, expected_buffer_size);
        }

        // process frames
        sync.mutex_lock(&am^.guarded_decoder.guard);
        index := am^.guarded_decoder.decoder.index;
        sync.mutex_unlock(&am^.guarded_decoder.guard);
        device_data_proc_process_buffer(
            device,
            cast(c.size_t)(index * channels * sample_size)
        );

        // copy to out
        mem.copy(out, &opencl^.audio_buffer_out_host[opencl^.eat_pos], cast(int)frame_byte_count);
        opencl^.eat_pos += frame_count;
        increment_decoder_index(am^.guarded_decoder, frame_count);

        // reset last_ops
        mem.copy(&last_ops, &am^.operations, size_of(AOK_Operations));

        return;
    }

    if opencl^.eat_pos + frame_count >= MAX_OUT_HOST_FRAME_COUNT {
        fmt.eprintfln("Eat pos: %d; Frame count: %d; Len/Sum: %d/%d",
            opencl^.eat_pos, frame_count, len(opencl^.audio_buffer_out_host), opencl^.eat_pos + frame_count)
        delta := MAX_OUT_HOST_FRAME_COUNT - opencl^.eat_pos;
        fmt.eprintfln("Delta: %d", delta);
        if delta != 0 {
            mem.copy(out, &opencl^.audio_buffer_out_host[eat_sample_pos], cast(int)(delta * sample_size * channels));
        }
        opencl^.eat_pos = 0;

        // read new chunk
        sync.mutex_lock(&am^.guarded_decoder.guard);
        index := am^.guarded_decoder.decoder.index;
        sync.mutex_unlock(&am^.guarded_decoder.guard);
        host_len := cast(c.size_t)(u64(len(opencl^.audio_buffer_out_host)) * sample_size);
        device_data_proc_copy_to_host(
            am,
            min(host_len, opencl^.audio_buffer_out.size - cast(c.size_t)(index * sample_size * channels)),
            cast(c.size_t)(index * channels * sample_size)
        );

        rest := frame_count - delta;
        if rest != 0 {
            fmt.assertf(
                rest > 0 && rest < MAX_OUT_HOST_FRAME_COUNT,
                "The frame count (%d) is %dx larger than the maximal buffer size (%d)!",
                frame_count,
                frame_count / MAX_OUT_HOST_FRAME_COUNT,
                len(opencl^.audio_buffer_out_host)
            );
            mem.copy(&out[delta * channels], &opencl^.audio_buffer_out_host[0], cast(int)(rest * sample_size * channels));
            opencl^.eat_pos = rest;
        }

        increment_decoder_index(am^.guarded_decoder, frame_count);

        return;
    }

    mem.copy(out, &opencl^.audio_buffer_out_host[eat_sample_pos], cast(int)(frame_byte_count * sample_size));
    opencl^.eat_pos += frame_count;
    increment_decoder_index(am^.guarded_decoder, frame_count);
    //fmt.eprintfln("Eat: %d; Index: %d; Added: %d; Len: %d", opencl^.eat_pos, am^.guarded_decoder.decoder.index, frame_count, len(opencl^.audio_buffer_out_host));
}

/**
 * @param host_len length of to be copied from OpenCL outbuffer to host (in bytes)
 * @param offset how many bytes should be skipped from the beginning of the copy of the OpenCL outbuffer
 *
 * @note host_len has to be lower or equal as the byte length of the host buffer! host_len param is not to be offsetted in any way externally
 */
@(private="file")
device_data_proc_copy_to_host :: proc(using am: ^Audio_Manager, host_len, offset: c.size_t) {
    assert(host_len <= len(opencl^.audio_buffer_out_host) * size_of(c.short));

    ret: cl.Int;
    buf_map := cl.EnqueueMapBuffer(
        opencl^.queue,
        opencl^.audio_buffer_out.mem,
        cl.TRUE,
        cl.MAP_READ,
        offset,
        host_len,
        0,
        nil,
        nil,
        &ret
    );
    fmt.eprintfln("Host len: %d; Offset: %d; Bufsize: %d", host_len, offset, opencl^.audio_buffer_out.size);
    fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue map buffer for read! Reason: %d | %s; %s", ret, err_to_name(ret));

    device_data_proc_mapped_copy_to_host(am, buf_map, host_len);

    ret = cl.EnqueueUnmapMemObject(opencl^.queue, opencl^.audio_buffer_out.mem, buf_map, 0, nil, nil);
    fmt.assertf(ret == cl.SUCCESS, "Failed to unmap buffer: %v; (aka %s | %s)", ret, err_to_name(ret));
}

@(private="file")
device_data_proc_mapped_copy_to_host :: proc(using am: ^Audio_Manager, buf_map: rawptr, host_len: c.size_t) {
    channels := guarded_decoder.decoder.config.channels;
    eat_sample_pos := opencl^.eat_pos * u64(channels);
    mem.copy(&opencl^.audio_buffer_out_host[eat_sample_pos], buf_map, cast(int)host_len);
}

@(private="file")
device_data_proc_process_buffer :: proc(device: ^ma.device, process_offset: c.size_t) {
    am := cast(^Audio_Manager)(device.pUserData);
    assert(am != nil);

    opencl := am^.opencl;
    sample_size := cast(u64)ma.get_bytes_per_sample(device.playback.playback_format);
    channels := cast(u64)device.playback.channels;

    input_buffer  := opencl^.audio_buffer_in;
    output_buffer := opencl^.audio_buffer_out;
    assert(opencl^.audio_buffer_in.size == opencl^.audio_buffer_out.size);
    buffer_size   := cast(c.size_t)opencl^.audio_buffer_in.size - process_offset;
    first_kernel  := true;
    recalc_amplt  := &am.guarded_decoder.decoder.max_amplitude_valid;

    deferred_compile_kernel :: #force_inline proc(opencl: ^OpenCL_Context, name: cstring) -> cl.Kernel {
        /* deferred kernel initialization */
        if name not_in opencl.kernels {
            kernel, err := compile_kernel(opencl, name);
            fmt.assertf(err == nil, "Failed to compile %s kernel!", name);
            map_insert(&opencl.kernels, name, kernel);

            return kernel;
        }

        return opencl.kernels[name];
    }

    set_input_output_args :: #force_inline proc(kernel: cl.Kernel, input_buffer: ^cl.Mem, output_buffer: ^cl.Mem) {
        ret := cl.SetKernelArg(kernel, 0, size_of(cl.Mem), input_buffer);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret  = cl.SetKernelArg(kernel, 1, size_of(cl.Mem), output_buffer);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));
    }

    copy_out_to_in :: #force_inline proc(
        opencl: ^OpenCL_Context,
        input_buffer, output_buffer: OpenCL_Audio_Buffer,
        buffer_size, offset: c.size_t)
    {
        // NOTE(GowardSilk): we want to copy the result (aka output_buffer) into input again
        ret := cl.EnqueueCopyBuffer(
            opencl^.queue,
            output_buffer.mem,
            input_buffer.mem,
            0,
            offset,
            buffer_size,
            0,
            nil,
            nil,
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue copy buffer! Reason: %d | %s; %s", ret, err_to_name(ret));
    }

    enqueue_basic :: proc(opencl: ^OpenCL_Context, kernel: cl.Kernel, buffer_size: ^c.size_t) {
        ret := cl.EnqueueNDRangeKernel(
            opencl^.queue,
            kernel,
            1,
            nil,
            buffer_size,
            nil,
            0,
            nil,
            nil
        );
        fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue kernel! Reason: %d | %s; %s", ret, err_to_name(ret));
    }

    reset_ampltitude_recalc :: #force_inline proc(v: ^bool, resets: bool) {
        if resets do v^ = true;
    }

    if am^.operations.distortion.base.enabled {
        using am^.operations.distortion;

        kernel := deferred_compile_kernel(opencl, base.kernel_name);

        if first_kernel == true do first_kernel = false;
        else { unreachable(/* copy output_buffer -> input_buffer */); }

        set_input_output_args(kernel, &input_buffer.mem, &output_buffer.mem);
        enqueue_basic(opencl, kernel, &buffer_size);

        reset_ampltitude_recalc(recalc_amplt, base.amplitude_recalc);
    }

    if am^.operations.clip.base.enabled {
        using am^.operations.clip;

        kernel := deferred_compile_kernel(opencl, base.kernel_name);

        if first_kernel == true do first_kernel = false;
        else do copy_out_to_in(opencl, input_buffer, output_buffer, buffer_size, process_offset);

        set_input_output_args(kernel, &input_buffer.mem, &output_buffer.mem);

        ret := cl.SetKernelArg(kernel, 2, size_of(cl.Float), &threshold);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        enqueue_basic(opencl, kernel, &buffer_size);

        reset_ampltitude_recalc(recalc_amlt, base.amplitude_recalc);
    }

    if am^.operations.gain.base.enabled {
        using am^.operations.gain;

        kernel := deferred_compile_kernel(opencl, base.kernel_name);

        if first_kernel == true do first_kernel = false;
        else do copy_out_to_in(opencl, input_buffer, output_buffer, buffer_size, process_offset);

        set_input_output_args(kernel, &input_buffer.mem, &output_buffer.mem);

        ret := cl.SetKernelArg(kernel, 2, size_of(cl.Float), &gain);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        enqueue_basic(opencl, kernel, &buffer_size);

        reset_ampltitude_recalc(recalc_amlt, base.amplitude_recalc);
    }

    if am^.operations.pan.base.enabled {
        using am^.operations.pan;

        kernel := deferred_compile_kernel(opencl, base.kernel_name);

        if first_kernel == true do first_kernel = false;
        else do copy_out_to_in(opencl, input_buffer, output_buffer, buffer_size, process_offset);

        set_input_output_args(kernel, &input_buffer.mem, &output_buffer.mem);

        ret := cl.SetKernelArg(kernel, 2, size_of(cl.Float), &pan.actual);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        mono_buffer_size := buffer_size >> 1;
        enqueue_basic(opencl, kernel, &mono_buffer_size);

        reset_ampltitude_recalc(recalc_amlt, base.amplitude_recalc);
    }

    if am^.operations.lowpass_iir.base.enabled {
        using am^.operations.lowpass_iir;

        kernel := deferred_compile_kernel(opencl, base.kernel_name);

        if first_kernel == true do first_kernel = false;
        else do copy_out_to_in(opencl, input_buffer, output_buffer, buffer_size, process_offset);

        set_input_output_args(kernel, &input_buffer.mem, &output_buffer.mem);

        x := math.exp(-2.0 * math.PI * cutoff / cast(cl.Float)device.sampleRate);
        ret := cl.SetKernelArg(kernel, 2, size_of(cl.Float), &x);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        enqueue_basic(opencl, kernel, &buffer_size);

        reset_ampltitude_recalc(recalc_amlt, base.amplitude_recalc);
    }

    if am^.operations.envelope_follow.base.enabled {
        using am^.operations.envelope_follow;

        kernel := deferred_compile_kernel(opencl, base.kernel_name);

        if first_kernel == true do first_kernel = false;
        else do copy_out_to_in(opencl, input_buffer, output_buffer, buffer_size, process_offset);

        set_input_output_args(kernel, &input_buffer.mem, &output_buffer.mem);

        ret := cl.SetKernelArg(kernel, 2, size_of(cl.Float), &attack);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret  = cl.SetKernelArg(kernel, 3, size_of(cl.Float), &release);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        enqueue_basic(opencl, kernel, &buffer_size);

        reset_ampltitude_recalc(recalc_amlt, base.amplitude_recalc);

        unimplemented("Envelope follow AOK requires max_amplitude to be up-to-date!");

    }

    if am^.operations.normalize.base.enabled {
        using am^.operations.normalize;

        kernel := deferred_compile_kernel(opencl, base.kernel_name);

        if first_kernel == true do first_kernel = false;
        else do copy_out_to_in(opencl, input_buffer, output_buffer, buffer_size, process_offset);

        cl.SetKernelArg(kernel, 2, size_of(cl.Float), &target_level);
        cl.SetKernelArg(kernel, 3, size_of(c.short), &am.guarded_decoder.decoder.max_amplitude);

        enqueue_basic(opencl, kernel, &buffer_size);

        reset_ampltitude_recalc(recalc_amlt, base.amplitude_recalc);

        unimplemented("Normalize AOK requires max_amplitude to be up-to-date!");
    }

    if am^.operations.compress.base.enabled {
        unimplemented("Compress AOK requires max_amplitude to be up-to-date!");
    }

    if am^.operations.apply_adsr.base.enabled {
        unimplemented("Apply ADSR AOK requires max_amplitude to be up-to-date!");
    }

    if am^.operations.rms .base.enabled {
        unimplemented("RMS AOK requires max_amplitude to be up-to-date!");
    }

    eat_byte_pos := opencl^.eat_pos * sample_size * channels;
    host_len := cast(c.size_t)(u64(len(opencl^.audio_buffer_out_host)) * sample_size - eat_byte_pos);

    if first_kernel {
        // no kernel was really launched, therefore
        // the audio_buffer_out_host will be empty
        am := cast(^Audio_Manager)device.pUserData;

        channels := am.guarded_decoder.decoder.config.channels; // no guard really needed?
        eat_sample_pos := opencl^.eat_pos * u64(channels);
        sync.mutex_lock(&am.guarded_decoder.guard);
        mem.copy(
            &opencl^.audio_buffer_out_host[eat_sample_pos],
            &am.guarded_decoder.decoder.frames[am.guarded_decoder.decoder.index],
            cast(int)host_len
        );
        sync.mutex_unlock(&am.guarded_decoder.guard);
    } else {
        // copy from audio_buffer_out to audio_buffer_out_host
        // device_data_proc_copy_to_host(am, min(host_len, buffer_size), process_offset);
        host_len = min(host_len, buffer_size);

        orig_ptr, buf_map: [^]c.short;
        ret: cl.Int;
        if recalc_amplt {
            // TODO(GowardSilk): EVEN THOUGH THIS COULD TECHNICALLY WORK
            // IT CREATES A LOT OF POTENTIAL ISSUES IF MAPPING WOULD TAKE A LONG TIME TO PROCESS
            orig_ptr = cast([^]c.short)cl.EnqueueMapBuffer(
                opencl^.queue,
                opencl^.audio_buffer_out.mem,
                cl.TRUE,
                cl.MAP_READ,
                0,
                opencl^.audio_buffer_out.size,
                0,
                nil,
                nil,
                &ret
            );
            fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue map buffer for read! Reason: %d | %s; %s", ret, err_to_name(ret));

            max_value: c.short = -0x8000;
            for i in 0..<am.guarded_decoder.decoder.frames_count {
                if max_value < orig_ptr[i] {
                    max_value = orig_ptr[i];
                }
            }
            fmt.eprintfln("[PEAK]: new peak changed from value: %d; to: %d",
                am.guarded_decoder.decoder.max_amplitude, max_value);
            am.guarded_decoder.decoder.max_amplitude = max_value;

            // move buf_map base ptr by process_offset so we can read
            // the latest chunk needed
            buf_map = &orig_ptr[process_offset];

        } else {
            orig_ptr = cast([^]c.short)cl.EnqueueMapBuffer(
                opencl^.queue,
                opencl^.audio_buffer_out.mem,
                cl.TRUE,
                cl.MAP_READ,
                process_offset,
                host_len,
                0,
                nil,
                nil,
                &ret
            );
            fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue map buffer for read! Reason: %d | %s; %s", ret, err_to_name(ret));
            buf_map = orig_ptr;
        }

        device_data_proc_mapped_copy_to_host(am, buf_map, host_len);

        ret = cl.EnqueueUnmapMemObject(opencl^.queue, opencl^.audio_buffer_out.mem, orig_ptr, 0, nil, nil);
        fmt.assertf(ret == cl.SUCCESS, "Failed to unmap buffer: %v; (aka %s | %s)", ret, err_to_name(ret));

        /*
        if recalc_amplt {
            // NOTE(GowardSilk): The fact that we do not copy the whole buffer to the CPU
            // upon exchange is proving to be rather very unuseful. Since we cannot capture
            // the peak across the whole CPU buffer, we need to launch a kernel to do it instead.
            kernel := deferred_compile_kernel(opencl, AOK_FIND_PEAK_HELPER_NAME);

            nof_units: c.size_t;
            ret := cl.GetKernelWorkGroupInfo(kernel, opencl.device, cl.KERNEL_WORK_GROUP_SIZE, size_of(nof_units), &nof_units, nil);
            fmt.assertf(ret == cl.SUCCESS, "Failed to load kernel work group info: %v; (aka %s | %s)", ret, err_to_name(ret));

            nof_samples := am.guarded_decoder.decoder.frames_count;
            nof_work_groups := nof_samples / nof_units / nof_units;
            global_size := nof_work_groups * nof_units;
            assert(nof_work_groups > 0); // nof_samples >= nof_units ^ 2
            remained := nof_samples - global_size * nof_units;

            copy_out_to_in(opencl, input_buffer, output_buffer, buffer_size, process_offset);

            max_values_mem := cl.CreateBuffer(opencl._context, cl.MEM_WRITE_ONLY | cl.MEM_ALLOC_HOST_PTR, nof_work_groups * size_of(c.short), nil, &ret);
            fmt.assertf(ret == cl.SUCCESS, "Failed to create max_values buffer: %v; (aka %s | %s)", ret, err_to_name(ret));
            defer cl.ReleaseMemObject(max_values_mem);

            ret |= cl.SetKernelArg(kernel, 0, size_of(cl.Mem), opencl.audio_buffer_in);
            ret |= cl.SetKernelArg(kernel, 1, size_of(c.size_t), &nof_units);
            ret |= cl.SetKernelArg(kernel, 2, size_of(c.short) * nof_units, nil);
            ret |= cl.SetKernelArg(kernel, 3, size_of(cl.Mem), max_values_mem);
            fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel args: %v; (aka %s | %s)", ret, err_to_name(ret));

            ret = cl.EnqueueNDRangeKernel(
                opencl.queue, kernel, 1,
                nil, &global_size, &nof_units,
                0, nil, nil
            );
            fmt.assertf(ret == cl.SUCCESS, "Failed to enqueue ndrange: %v; (aka %s | %s)", ret, err_to_name(ret));

            buf_map := cl.EnqueueMapBuffer(
                opencl^.queue,
                max_values_mem,
                cl.TRUE,
                cl.MAP_READ,
                0,
                nof_work_groups * size_of(c.short),
                0,
                nil,
                nil,
                &ret
            );
            fmt.assertf(ret == cl.SUCCESS, "Failed to map buffer: %v; (aka %s | %s)", ret, err_to_name(ret));

            max_value := ~c.short(0);
            for i in 0..<nof_work_groups {
                curr_value := buf_map[i];
                if max_value < curr_value {
                    max_value = curr_value;
                }
            }

            ret = cl.EnqueueUnmapMemObject(opencl^.queue, max_values_mem, buf_map, 0, nil, nil);
            fmt.assertf(ret == cl.SUCCESS, "Failed to unmap buffer: %v; (aka %s | %s)", ret, err_to_name(ret));

            if remained > 0 {
                fmt.eprintf("Max amplitude calculation; Remaining: %d samples.", remained);
            }

            am.guarded_decoder.decoder.max_amplitude = max_value;
        }
        */
    }
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
    if decoder.frames == nil || decoder.frames_count == 0 || decoder.pause {
        return;
    }

    // copy frames to the output
    // launch audio kernel operations if any submitted
    assert(frame_count != 0);
    frames_left := decoder.frames_count - decoder.index;
    frames_to_copy := min(frame_count, frames_left);
    dst := cast([^]c.short)output;

    if decoder.launch_kernel {
        device_data_proc_request_outbuffer(device, cast(c.size_t)(decoder.frames_count * channels * sample_size), frames_to_copy, dst);
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
    device_config.playback.channels  = 2;
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
    init_all_aok_settings(&am^.operations);
    return am, nil;
}

delete_audio_manager :: proc(am: ^Audio_Manager) {
    delete_audio_device(am);
    delete_opencl(am);
    delete_decoder(am);

    free(am);
}

// [A]udio_[O]peration_[K]ernel

decibel :: distinct cl.Float;

AOK_Operation_Base :: struct #no_copy {
    enabled: bool,
    amplitude_recalc: bool, /**< readonly; specifies whether given operation changes the amplitude */
    kernel_name: cstring, /**< key for OpenCL_Context.kernels; specifies which Kernel object to use for this operation */
}

//AOK_Find_Peak_Helper :: struct #no_copy {
//    #subtype base: AOK_Operation_Base,
//}
//
//init_find_peak_helper :: proc(peak_helper: ^AOK_Find_Peak_Helper) {
//    peak_helper.base.kernel_name = AOK_FIND_PEAK_HELPER;
//}
//
//AOK_FIND_PEAK_HELPER: cstring: `
//    short find_max(short* buffer, size_t len) {
//        short max_value = SHRT_MIN;
//        for (size_t i = 0; i < len; i++) {
//            short curr_value = buffer[i];
//            if (max_value < curr_value) {
//                max_value = curr_value;
//            }
//        }
//        return max_value;
//    }
//
//    __kernel void find_peak_helper(
//        __global short* input,
//        __const size_t  nof_locals,
//        __local short*  local_max_values,
//        __global short* max_values)
//    {
//        int gid = get_global_id(0);
//        int lid = get_local_id(0);
//
//        short max_value = find_max(&input[gid * nof_locals], nof_locals);
//        local_max_values[lid] = max_value;
//
//        barrier(CLK_LOCAL_MEM_FENCE);
//
//        // only one worker item per group will filter
//        // the results and plug in the final max_value
//        // for nof_locals * nof_locals values from 'input'
//        if (lid == 0) {
//            max_value = find_max(local_max_values, nof_locals);
//            max_values[gid/nof_locals] = max_value;
//        }
//    }
//`;
//AOK_FIND_PEAK_HELPER_SIZE: uint: len(AOK_FIND_PEAK_HELPER);
//AOK_FIND_PEAK_HELPER_NAME: cstring: "find_peak_helper";

AOK_Distortion_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,
}

init_distortion_settings :: proc(settings: ^AOK_Distortion_Settings) {
    settings.base.kernel_name = AOK_DISTORTION_NAME;
    settings.base.amplitude_recalc = true;
}

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

AOK_Clip_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    threshold: decibel, /**< from -100.0 to 0.0 dBFS; clip is symmetric */
}

init_clip_settings :: proc(settings: ^AOK_Clip_Settings) {
    settings.base.kernel_name = AOK_CLIP_NAME;
    settings.threshold = -6.0;
    settings.base.amplitude_recalc = true;
}

AOK_CLIP: cstring: `
    __kernel void clip(
        __global short* input,
        __global short* output,
        const float threshold)
    {
        int idx = get_global_id(0);
        // TODO(GowardSilk): When the operations will fuse together
        // we should make a function for dBFS -> c.short sample value
        const short th = (short)((float)SHRT_MAX * pow(10, threshold / 10.f));
        output[idx] = clamp((short)input[idx], (short)-th, (short)+th);
    }
`;
AOK_CLIP_SIZE: uint: len(AOK_CLIP);
AOK_CLIP_NAME: cstring: "clip";

AOK_Gain_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    gain:    decibel, /**< gain multiplier */
}

init_gain_settings :: proc(settings: ^AOK_Gain_Settings) {
    settings.base.kernel_name = AOK_GAIN_NAME;
    settings.gain = 3.2;
    settings.base.amplitude_recalc = true;
}

AOK_GAIN: cstring: `
    __kernel void gain(
        __global short* input,
        __global short* output,
        const float gain)
    {
        int idx = get_global_id(0);
        const float g = pow(10, gain / 20.f);
        output[idx] = (short)((float)input[idx] * g);
    }
`;
AOK_GAIN_SIZE: uint: len(AOK_GAIN);
AOK_GAIN_NAME: cstring: "gain";

/** @brief type used to signify min/max range of some float value (its representation in UI is altered from textbox to slider) */
Range :: struct {
    min: cl.Float,
    max: cl.Float,
    actual: cl.Float,
}

AOK_Pan_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    pan:     Range, /**< -1.0 (left) to 1.0 (right) */
}

init_pan_settings :: proc(settings: ^AOK_Pan_Settings) {
    settings.base.kernel_name = AOK_PAN_NAME;
    settings.pan = Range {min=-1.0, max=1.0, actual=0.0};
}

AOK_PAN: cstring: `
    __kernel void pan(
        __global short* input,
        __global short* output,
        const float pan)
    {
        int idx = get_global_id(0);
        int iL = 2 * idx;
        int iR = iL + 1;

        float panL = 1.0f - (pan + 1.0f) * 0.5f;
        float panR = (pan + 1.0f) * 0.5f;

        output[iL] = (short)(panL * (float)input[iL]);
        output[iR] = (short)(panR * (float)input[iR]);
    }
`;
AOK_PAN_SIZE: uint: len(AOK_PAN);
AOK_PAN_NAME: cstring: "pan";

/** @brief settings for basic (1-pole) Lowpass IIR */
AOK_Lowpass_IIR_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    cutoff: cl.Float,
}

init_lowpass_iir_settings :: proc(settings: ^AOK_Lowpass_IIR_Settings) {
    settings.base.kernel_name = AOK_LOWPASS_IIR_NAME;
    settings.cutoff = 1000.0;
    settings.base.amplitude_recalc = true;
}

AOK_LOWPASS_IIR: cstring: `
    __kernel void lowpass_iir(
        __global short* input,
        __global short* output,
        const float resonance)
    {
        int idx = get_global_id(0);
        output[idx] = (short)((1 - resonance) * (float)input[idx] + resonance * (float)output[max(idx - 1, 0)]);
    }
`;
AOK_LOWPASS_IIR_SIZE: uint: len(AOK_LOWPASS_IIR);
AOK_LOWPASS_IIR_NAME: cstring: "lowpass_iir";

AOK_Lowpass_Biquad_IIR_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    cutoff:     cl.Float,
    resonance:  cl.Float,
}

init_lowpass_biquad_iir_settings :: proc(settings: ^AOK_Lowpass_Biquad_IIR_Settings) {
    settings.base.kernel_name = AOK_LOWPASS_BIQUAD_IIR_NAME;
    settings.cutoff = 1000.0;
    settings.resonance = 0.7;
    settings.base.amplitude_recalc = true;
}

AOK_LOWPASS_BIQUAD_IIR: cstring: `
    __kernel void lowpass_iir(
        __global short* input,
        __global short* output)
    {
        int idx = get_global_id(0);
    }
`;
AOK_LOWPASS_BIQUAD_IIR_SIZE: uint: len(AOK_LOWPASS_BIQUAD_IIR);
AOK_LOWPASS_BIQUAD_IIR_NAME: cstring: "lowpass_iir";

AOK_Compress_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    threshold: decibel,
    ratio:     cl.Float,
    attack:    cl.Float,
    release:   cl.Float,
}

init_compress_settings :: proc(settings: ^AOK_Compress_Settings) {
    settings.base.kernel_name = AOK_COMPRESS_NAME;
	settings.threshold = 0.5;
	settings.ratio = 2.0;
	settings.attack = 0.01;
	settings.release = 0.1;
    settings.base.amplitude_recalc = true;
}

AOK_COMPRESS: cstring: `
    __kernel void compress(
        __global short* input,
        __global short* output,
        __global float* env_state)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_COMPRESS_SIZE: uint: len(AOK_COMPRESS);
AOK_COMPRESS_NAME: cstring: "compress";

AOK_Delay_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    time:     cl.Float, /**< seconds */
    feedback: cl.Float, /**< 0.0 to 1.0 */
    mix:      cl.Float, /**< dry/wet mix 0.0 to 1.0 */
}

init_delay_settings :: proc(settings: ^AOK_Delay_Settings) {
    settings.base.kernel_name = AOK_DELAY_NAME;
	settings.time = 0.3;
	settings.feedback = 0.4;
	settings.mix = 0.5;
    settings.base.amplitude_recalc = true;
}

AOK_DELAY: cstring: `
    __kernel void delay(
        __global short* input,
        __global short* output,
        __global short* delay_line)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_DELAY_SIZE: uint: len(AOK_DELAY);
AOK_DELAY_NAME: cstring: "delay";


AOK_Flanger_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    rate:     cl.Float, /**< Hz */
    depth:    cl.Float, /**< seconds */
    feedback: cl.Float, /**< -1.0 to 1.0 */
    mix:      cl.Float, /**< 0.0 to 1.0 */
}

init_flanger_settings :: proc(settings: ^AOK_Flanger_Settings) {
    settings.base.kernel_name = AOK_FLANGER_NAME;
	settings.rate = 0.25;
	settings.depth = 0.002;
	settings.feedback = 0.2;
	settings.mix = 0.5;
    settings.base.amplitude_recalc = true;
}

AOK_FLANGER: cstring: `
    __kernel void flanger(
        __global short* input,
        __global short* output,
        __global short* delay_line,
        __global float* lfo_state)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_FLANGER_SIZE: uint: len(AOK_FLANGER);
AOK_FLANGER_NAME: cstring: "flanger";

AOK_Chorus_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    rate:    cl.Float, /**< Hz */
    depth:   cl.Float, /**< seconds */
    mix:     cl.Float, /**< 0.0 to 1.0 */
}

init_chorus_settings :: proc(settings: ^AOK_Chorus_Settings) {
    settings.base.kernel_name = AOK_CHORUS_NAME;
	settings.rate = 0.25;
	settings.depth = 0.005;
	settings.mix = 0.4;
    settings.base.amplitude_recalc = true;
}

AOK_CHORUS: cstring: `
    __kernel void chorus(
        __global short* input,
        __global short* output,
        __global short* delay_line,
        __global float* mod_state)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_CHORUS_SIZE: uint: len(AOK_CHORUS);
AOK_CHORUS_NAME: cstring: "chorus";

AOK_Comb_Filter_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    delay_time: cl.Float, /**< seconds */
    feedback:   cl.Float, /**< 0.0 to 1.0 */
}

init_comb_filter_settings :: proc(settings: ^AOK_Comb_Filter_Settings) {
    settings.base.kernel_name = AOK_COMB_FILTER_NAME;
	settings.delay_time = 0.05;
	settings.feedback = 0.6;
    settings.base.amplitude_recalc = true;
}

AOK_COMB_FILTER: cstring: `
    __kernel void comb_filter(
        __global short* input,
        __global short* output,
        __global short* delay_line)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_COMB_FILTER_SIZE: uint: len(AOK_COMB_FILTER);
AOK_COMB_FILTER_NAME: cstring: "comb_filter";

AOK_Reverb_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    room_size:  cl.Float, /**< 0.0 to 1.0 */
    damping:    cl.Float, /**< 0.0 to 1.0 */
    width:      cl.Float, /**< 0.0 to 1.0 */
    wet:        cl.Float, /**< 0.0 to 1.0 */
}

init_reverb_settings :: proc(settings: ^AOK_Reverb_Settings) {
    settings.base.kernel_name = AOK_REVERB_NAME;
	settings.room_size = 0.8;
	settings.damping = 0.5;
	settings.width = 1.0;
	settings.wet = 0.3;
    settings.base.amplitude_recalc = true;
}

AOK_REVERB: cstring: `
    __kernel void reverb(
        __global short* input,
        __global short* output,
        __global short* delay_lines,
        __global float* matrix)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_REVERB_SIZE: uint: len(AOK_REVERB);
AOK_REVERB_NAME: cstring: "reverb";

AOK_Envelope_Follow_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    attack: Range,
    release: Range,
}

init_envelope_follow_settings :: proc(settings: ^AOK_Envelope_Follow_Settings) {
    settings.base.kernel_name = AOK_ENVELOPE_FOLLOW_NAME;

    settings.attack  = Range{min=0.0, max=1.0, actual=1.0};
    settings.release = Range{min=0.0, max=1.0, actual=0.0};
}

AOK_ENVELOPE_FOLLOW: cstring: `
    __kernel void envelope_follow(
        __global short* input,
        __global short* output,
        const float attack,
        const float release)
    {
        int idx = get_global_id(0);
        int prev_idx = max(idx - 1, 0);
        int prev = output[prev_idx];
        int actual = abs(input[idx]);

        if (actual > prev) {
            output[idx] = actual * (1 - attack)  + prev * attack;
        } else {
            output[idx] = actual * (1 - release) + prev * release;
        }
    }
`;
AOK_ENVELOPE_FOLLOW_SIZE: uint: len(AOK_ENVELOPE_FOLLOW);
AOK_ENVELOPE_FOLLOW_NAME: cstring: "envelope_follow";

AOK_RMS_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,
}

init_rms_settings :: proc(settings: ^AOK_RMS_Settings) {
    settings.base.kernel_name = AOK_RMS_NAME;
}

AOK_RMS: cstring: `
    __kernel void rms(
        __global short* input,
        __global float* output)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_RMS_SIZE: uint: len(AOK_RMS);
AOK_RMS_NAME: cstring: "rms";

AOK_Normalize_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    target_level: cl.Float,
}

init_normalize_settings :: proc(settings: ^AOK_Normalize_Settings) {
    settings.base.kernel_name = AOK_NORMALIZE_NAME;
    settings.base.amplitude_recalc = true;
	settings.target_level = 0.9;
}

AOK_NORMALIZE: cstring: `
    __kernel void _normalize(
        __global short* input,
        __global short* output,
        float target,
        short peak)
    {
        int idx = get_global_id(0);
        float t = ((float)SHRT_MAX * pow(10, target / 10.f)) / (float)peak;
        output[idx] = clamp((short)((float)input[idx] * t), (short)SHRT_MIN, (short)SHRT_MAX);
    }
`;
AOK_NORMALIZE_SIZE: uint: len(AOK_NORMALIZE);
AOK_NORMALIZE_NAME: cstring: "_normalize";

AOK_Resample_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    target_rate: cl.Float,
}

init_resample_settings :: proc(settings: ^AOK_Resample_Settings) {
    settings.base.kernel_name = AOK_RESAMPLE_NAME;
	settings.target_rate = 44100.0;
}

AOK_RESAMPLE: cstring: `
    __kernel void resample(
        __global short* input,
        __global short* output,
        float ratio)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_RESAMPLE_SIZE: uint: len(AOK_RESAMPLE);
AOK_RESAMPLE_NAME: cstring: "resample";

AOK_Convolve_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,
}

init_convolve_settings :: proc(settings: ^AOK_Convolve_Settings) {
    settings.base.kernel_name = AOK_CONVOLVE_NAME;
    settings.base.amplitude_recalc = true;
}

AOK_CONVOLVE: cstring: `
    __kernel void convolve(
        __global short* input,
        __global short* output,
        __global float* ir_fft)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_CONVOLVE_SIZE: uint: len(AOK_CONVOLVE);
AOK_CONVOLVE_NAME: cstring: "convolve";


AOK_Generate_LFO_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    rate:    cl.Float,
    shape:   int,
}

init_generate_lfo_settings :: proc(settings: ^AOK_Generate_LFO_Settings) {
    settings.base.kernel_name = AOK_GENERATE_LFO_NAME;
	settings.rate = 1.0;
	settings.shape = 0; // TODO(GowardSilk): enum
}

AOK_GENERATE_LFO: cstring: `
    __kernel void generate_lfo(
        __global float* output,
        __global float* lfo_state)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_GENERATE_LFO_SIZE: uint: len(AOK_GENERATE_LFO);
AOK_GENERATE_LFO_NAME: cstring: "generate_lfo";

AOK_Apply_ADSR_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    attack:  cl.Float,
    decay:   cl.Float,
    sustain: cl.Float,
    release: cl.Float,
}

init_apply_adsr_settings :: proc(settings: ^AOK_Apply_ADSR_Settings) {
    settings.base.kernel_name = AOK_APPLY_ADSR_NAME;
	settings.attack = 0.01;
	settings.decay = 0.1;
	settings.sustain = 0.7;
	settings.release = 0.3;
    settings.base.amplitude_recalc = true;
}

AOK_APPLY_ADSR: cstring: `
    __kernel void apply_adsr(
        __global short* input,
        __global short* output,
        __global float* adsr_state,
        __global int* gate)
    {
        int idx = get_global_id(0);
    }
`;
AOK_APPLY_ADSR_SIZE: uint: len(AOK_APPLY_ADSR);
AOK_APPLY_ADSR_NAME: cstring: "apply_adsr";

AOK_Operations :: struct #no_copy {
	distortion:      AOK_Distortion_Settings,
	clip:            AOK_Clip_Settings,
	gain:            AOK_Gain_Settings,
	pan:             AOK_Pan_Settings,
	lowpass_iir:     AOK_Lowpass_IIR_Settings,
	compress:        AOK_Compress_Settings,
	delay:           AOK_Delay_Settings,
	flanger:         AOK_Flanger_Settings,
	chorus:          AOK_Chorus_Settings,
	comb_filter:     AOK_Comb_Filter_Settings,
	reverb:          AOK_Reverb_Settings,
	envelope_follow: AOK_Envelope_Follow_Settings,
	rms:             AOK_RMS_Settings,
	normalize:       AOK_Normalize_Settings,
	resample:        AOK_Resample_Settings,
	convolve:        AOK_Convolve_Settings,
	generate_lfo:    AOK_Generate_LFO_Settings,
	apply_adsr:      AOK_Apply_ADSR_Settings,
}

init_all_aok_settings :: proc(all: ^AOK_Operations) {
    init_distortion_settings(&all.distortion);
    init_clip_settings(&all.clip);
    init_gain_settings(&all.gain);
    init_pan_settings(&all.pan);
    init_lowpass_iir_settings(&all.lowpass_iir);
    init_compress_settings(&all.compress);
    init_delay_settings(&all.delay);
    init_flanger_settings(&all.flanger);
    init_chorus_settings(&all.chorus);
    init_comb_filter_settings(&all.comb_filter);
    init_reverb_settings(&all.reverb);
    init_envelope_follow_settings(&all.envelope_follow);
    init_rms_settings(&all.rms);
    init_normalize_settings(&all.normalize);
    init_resample_settings(&all.resample);
    init_convolve_settings(&all.convolve);
    init_generate_lfo_settings(&all.generate_lfo);
    init_apply_adsr_settings(&all.apply_adsr);
}

AOK := [?]cstring {
	AOK_DISTORTION,
	AOK_CLIP,
	AOK_GAIN,
	AOK_PAN,
	AOK_LOWPASS_IIR,
	// AOK_COMPRESS,
	// AOK_DELAY,
	// AOK_FLANGER,
	// AOK_CHORUS,
	// AOK_COMB_FILTER,
	// AOK_REVERB,
	AOK_ENVELOPE_FOLLOW,
	// AOK_RMS,
	AOK_NORMALIZE,
	// AOK_RESAMPLE,
	// AOK_CONVOLVE,
	// AOK_GENERATE_LFO,
	// AOK_APPLY_ADSR,
}

AOK_SIZES := [?]uint{
        // operations
	AOK_DISTORTION_SIZE,
	AOK_CLIP_SIZE,
	AOK_GAIN_SIZE,
	AOK_PAN_SIZE,
	AOK_LOWPASS_IIR_SIZE,
	// AOK_COMPRESS_SIZE,
	// AOK_DELAY_SIZE,
	// AOK_FLANGER_SIZE,
	// AOK_CHORUS_SIZE,
	// AOK_COMB_FILTER_SIZE,
	// AOK_REVERB_SIZE,
	AOK_ENVELOPE_FOLLOW_SIZE,
	// AOK_RMS_SIZE,
	AOK_NORMALIZE_SIZE,
	// AOK_RESAMPLE_SIZE,
	// AOK_CONVOLVE_SIZE,
	// AOK_GENERATE_LFO_SIZE,
	// AOK_APPLY_ADSR_SIZE,
};
