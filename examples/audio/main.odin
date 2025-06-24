package audio;

import "core:c"
import "core:os"
import "core:log"
import "core:mem"
import "core:strings"

import cl "shared:opencl"
import mu "vendor:microui"
import rl "vendor:raylib"

Error :: union #shared_nil {
    OpenCL_Error,
}

main :: proc() {
    context.logger = log.create_console_logger();

    opencl: OpenCL_Context;
    uim: UI_Manager;
    err: Error;

    opencl, err = init_cl_context();
    if err != nil {
        log.errorf("Failed to initialize OpenCL Context! Error: %v", err);
        return;
    }
    defer delete_cl_context(&opencl);

    uim, err = init_ui_manager();
    if err != nil {
        log.errorf("Failed to initialize ui manager! Error: %v", err);
        return;
    }
    defer delete_ui_manager(&uim);

    curr_dir_handle: os.Handle;
    os_err: os.Error;
    {
        curr_dir_base := os.get_current_directory();
        defer delete(curr_dir_base);

        curr_dir := make([]byte, len(curr_dir_base) + size_of("/audio"));
        defer delete(curr_dir);
        copy(curr_dir, curr_dir_base[:]);
        copy_from_string(curr_dir[len(curr_dir_base):], "/audio");

        curr_dir_handle, os_err = os.open(cast(string)curr_dir);
        if os_err != nil {
            log.errorf("Failed to open current directory handle! Error: %v", os_err);
            return;
        }
    }
    defer os.close(curr_dir_handle);

    wave_cache := make(map[string]rl.Wave);
    active_wave: ^rl.Wave = nil;
    wave_index: c.int = 0;
    wave_playing := false;
    defer {
        for wave_name in wave_cache do rl.UnloadWave(wave_cache[wave_name]);
        delete(wave_cache);
    }

    rl.SetTargetFPS(60);
    for !rl.WindowShouldClose() {
        ui_register_mouse_events(&uim);

        mu.begin(uim.ctx);
        if mu.window(uim.ctx, "Demo", {0, 0, 512, 512}, {.NO_CLOSE}) {
            // query all files and play sound files
            infos, read_err := os.read_dir(curr_dir_handle, -1);
            if read_err != nil {
                log.errorf("Failed to query files in `audio` directory! Error: %v", read_err);
                return;
            }
            defer os.file_info_slice_delete(infos);

            for info in infos do if is_sound_file(info) {
                if .SUBMIT in mu.button(uim.ctx, info.name) {
                    wave, ok := &wave_cache[info.name]; 
                    if !ok {
                        info_cname := make([]byte, len(info.name) + size_of("audio/") + 1);
                        defer delete(info_cname);
                        copy_from_string(info_cname[copy_from_string(info_cname, "audio/"):], info.name);

                        active_wave = map_insert(&wave_cache, info.name, rl.LoadWave(cast(cstring)&info_cname[0]));
                    } else do active_wave = wave;

                    rl.PlayAudioStream(uim.audio_stream);
                    wave_playing = true;

                    //for i := 0; i < 40; i += 1 do log.errorf("Data: %d/%f", (cast([^]c.short)active_wave.data)[44100+i], (cast([^]c.float)active_wave.data)[44100+i]);
                    //unreachable();
                    if active_wave != nil {
                        log.infof("Wave info - Sample rate: %d, Sample size: %d, Channels: %d, Frame count: %d",
                            active_wave.sampleRate,
                            active_wave.sampleSize,
                            active_wave.channels,
                            active_wave.frameCount);
                    }
                }
            }

            if active_wave != nil && rl.IsAudioStreamProcessed(uim.audio_stream) {
                samples_offset := u32(wave_index * uim.audio_buffer_size);
                if cast(f32)uim.audio_stream.sampleRate/60.0 > cast(f32)uim.audio_buffer_size {
                    // increase the number of updates per frame
                    // max_i := cast(c.int)(44100.0/(uim.audio_buffer_size*60.0));
                    // for i := c.int(0); i < max_i; i += 1 {
                    //     if samples_offset > active_wave.frameCount {
                    //         rl.StopAudioStream(uim.audio_stream);
                    //         wave_index = 0;
                    //         wave_playing = false;
                    //         active_wave = nil;
                    //         break;
                    //     }
                    //     rl.UpdateAudioStream(uim.audio_stream, &(cast([^]c.short)active_wave.data)[samples_offset], uim.audio_buffer_size);
                    //     samples_offset += cast(u32)uim.audio_buffer_size;
                    // }
                    // wave_index += max_i;
                    unreachable();
                } else {
                    // decrease the number of frame times
                    @static frame_skip: i32;
                    frame_skip = max(0, i32((cast(f32)uim.audio_buffer_size*60.0)/44100.0)-3);
                    @static frames_skipped: i32;
                    if frames_skipped >= frame_skip {
                        if samples_offset > active_wave.frameCount {
                            rl.StopAudioStream(uim.audio_stream);
                            wave_index = 0;
                            wave_playing = false;
                            active_wave = nil;
                        } else {
                            rl.UpdateAudioStream(uim.audio_stream, &(cast([^]c.short)active_wave.data)[samples_offset], uim.audio_buffer_size);
                            samples_offset += cast(u32)uim.audio_buffer_size;
                            wave_index += 1;
                        }
                        frames_skipped = 0;
                    } else do frames_skipped += 1;
                }
            }

            mu.checkbox(uim.ctx, "Distortion", &opencl.operations[.Distortion]);
            mu.checkbox(uim.ctx, "Echo", &opencl.operations[.Echo]);
            mu.checkbox(uim.ctx, "FFT", &opencl.operations[.FFT]);

            if .SUBMIT in mu.button(uim.ctx, "Submit") {
                // do OpenCL work here ?
                // and update audio stream
                // rl.UpdateAudioStream(uim.audio_stream, &wave_samples[0], wave_framecount);
            }
        }
        mu.end(uim.ctx);

        ui_render(&uim);
    }
}

is_sound_file :: proc(fi: os.File_Info) -> bool {
    if fi.is_dir do return false;

    if fi.name[len(fi.name)-4:] == ".wav" do return true;
    return false;
}