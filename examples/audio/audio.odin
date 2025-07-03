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

    deferred_compile_kernel :: #force_inline proc(opencl: ^OpenCL_Context, kernel: ^cl.Kernel, name: cstring) {
        /* deferred kernel initialization */
        if kernel^ == nil {
            err: Error;
            kernel^, err = compile_kernel(opencl, AOK_DISTORTION_NAME);
            fmt.assertf(err == nil, "Failed to compile %s kernel!", AOK_DISTORTION_NAME);
        }
    }

    if am^.operations.distortion.base.enabled {
        deferred_compile_kernel(opencl, &am^.operations.distortion.base.kernel, AOK_DISTORTION_NAME);

        if first_kernel == true do first_kernel = false;
        else { unreachable(/* copy output_buffer -> input_buffer */); }

        ret := cl.SetKernelArg(am^.operations.distortion.base.kernel, 0, size_of(cl.Mem), input_buffer);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret  = cl.SetKernelArg(am^.operations.distortion.base.kernel, 1, size_of(cl.Mem), output_buffer);
        fmt.assertf(ret == cl.SUCCESS, "Failed to set kernel arg! Reason: %d | %s; %s", ret, err_to_name(ret));

        ret = cl.EnqueueNDRangeKernel(
            opencl^.queue,
            am^.operations.distortion.base.kernel,
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

    // TODO(GowardSilk): perhaps it would be better to manage the kernels via a separate tracker (like a hash map inside OpenCL_Context with keys being the names of the kernels?)
    // rather than doing it manually here...
    if am^.operations.distortion.base.kernel != nil do delete_kernel(am^.operations.distortion.base.kernel);

    free(am);
}

// [A]udio_[O]peration_[K]ernel

AOK_Operation_Base :: struct #no_copy {
    enabled: bool,
    kernel: cl.Kernel,
}

AOK_Distortion_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,
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

    threshold: c.short,
}

AOK_CLIP: cstring: `
    __kernel void clip(
        __global short* input,
        __global short* output,
        const short threshold)
    {
        int idx = get_global_id(0);
        output[idx] = min(threshold, input[idx]);
    }
`;
AOK_CLIP_SIZE: uint: len(AOK_CLIP);
AOK_CLIP_NAME: cstring: "clip";

AOK_Gain_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    gain:    cl.Float, /**< gain multiplier */
}

AOK_GAIN: cstring: `
    __kernel void gain(
        __global short* input,
        __global short* output,
        const float gain)
    {
        int idx = get_global_id(0);
        output[idx] = short((float)input[idx] * gain);
    }
`;
AOK_GAIN_SIZE: uint: len(AOK_GAIN);
AOK_GAIN_NAME: cstring: "gain";

AOK_Pan_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    pan:     cl.Float, /**< -1.0 (left) to 1.0 (right) */
}

AOK_PAN: cstring: `
    __kernel void pan(
        __global short* inputL,
        __global short* inputR,
        __global short* outputL,
        __global short* outputR)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_PAN_SIZE: uint: len(AOK_PAN);
AOK_PAN_NAME: cstring: "pan";

AOK_Lowpass_IIR_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    cutoff:     cl.Float,
    resonance:  cl.Float,
}

AOK_LOWPASS_IIR: cstring: `
    __kernel void lowpass_iir(
        __global short* input,
        __global short* output,
        __global float* state)
    {
        int idx = get_global_id(0);

    }
`;
AOK_LOWPASS_IIR_SIZE: uint: len(AOK_LOWPASS_IIR);
AOK_LOWPASS_IIR_NAME: cstring: "lowpass_iir";

AOK_Compress_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    threshold: cl.Float,
    ratio:     cl.Float,
    attack:    cl.Float,
    release:   cl.Float,
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
}

AOK_ENVELOPE_FOLLOW: cstring: `
    __kernel void envelope_follow(
        __global short* input,
        __global short* output,
        __global float* state)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_ENVELOPE_FOLLOW_SIZE: uint: len(AOK_ENVELOPE_FOLLOW);
AOK_ENVELOPE_FOLLOW_NAME: cstring: "envelope_follow";

AOK_RMS_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,
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

AOK_NORMALIZE: cstring: `
    __kernel void normalize(
        __global short* input,
        __global short* output,
        float gain)
    {
        int idx = get_global_id(0);
        
    }
`;
AOK_NORMALIZE_SIZE: uint: len(AOK_NORMALIZE);
AOK_NORMALIZE_NAME: cstring: "normalize";

AOK_Resample_Settings :: struct #no_copy {
    #subtype base:  AOK_Operation_Base,

    target_rate: cl.Float,
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

AOK := [?]cstring {
	AOK_DISTORTION,
	// AOK_CLIP,
	// AOK_GAIN,
	// AOK_PAN,
	// AOK_LOWPASS_IIR,
	// AOK_COMPRESS,
	// AOK_DELAY,
	// AOK_FLANGER,
	// AOK_CHORUS,
	// AOK_COMB_FILTER,
	// AOK_REVERB,
	// AOK_ENVELOPE_FOLLOW,
	// AOK_RMS,
	// AOK_NORMALIZE,
	// AOK_RESAMPLE,
	// AOK_CONVOLVE,
	// AOK_GENERATE_LFO,
	// AOK_APPLY_ADSR,
}

AOK_NAMES := [?]cstring{
	AOK_DISTORTION_NAME,
	// AOK_CLIP_NAME,
	// AOK_GAIN_NAME,
	// AOK_PAN_NAME,
	// AOK_LOWPASS_IIR_NAME,
	// AOK_COMPRESS_NAME,
	// AOK_DELAY_NAME,
	// AOK_FLANGER_NAME,
	// AOK_CHORUS_NAME,
	// AOK_COMB_FILTER_NAME,
	// AOK_REVERB_NAME,
	// AOK_ENVELOPE_FOLLOW_NAME,
	// AOK_RMS_NAME,
	// AOK_NORMALIZE_NAME,
	// AOK_RESAMPLE_NAME,
	// AOK_CONVOLVE_NAME,
	// AOK_GENERATE_LFO_NAME,
	// AOK_APPLY_ADSR_NAME,
};

AOK_SIZES := [?]uint{
	AOK_DISTORTION_SIZE,
	// AOK_CLIP_SIZE,
	// AOK_GAIN_SIZE,
	// AOK_PAN_SIZE,
	// AOK_LOWPASS_IIR_SIZE,
	// AOK_COMPRESS_SIZE,
	// AOK_DELAY_SIZE,
	// AOK_FLANGER_SIZE,
	// AOK_CHORUS_SIZE,
	// AOK_COMB_FILTER_SIZE,
	// AOK_REVERB_SIZE,
	// AOK_ENVELOPE_FOLLOW_SIZE,
	// AOK_RMS_SIZE,
	// AOK_NORMALIZE_SIZE,
	// AOK_RESAMPLE_SIZE,
	// AOK_CONVOLVE_SIZE,
	// AOK_GENERATE_LFO_SIZE,
	// AOK_APPLY_ADSR_SIZE,
};