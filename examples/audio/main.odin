package audio;

import "core:c"
import "core:os"
import "core:log"
import "core:mem"
import "core:strings"

import cl "shared:opencl"
import mu "vendor:microui"

Error :: union #shared_nil {
    OpenCL_Error,
    UI_Error
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

    wave_cache := make(map[string]rawptr);
    defer {
        // for wave_name in wave_cache do delete_wave
        delete(wave_cache);
    }

    for !uim.should_close {
        ui_register_events(&uim);

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

                        map_insert(&wave_cache, info.name, nil);
                    }
                }
            }

            mu.checkbox(uim.ctx, "Distortion", &opencl.operations[.Distortion]);
            mu.checkbox(uim.ctx, "Echo", &opencl.operations[.Echo]);
            mu.checkbox(uim.ctx, "FFT", &opencl.operations[.FFT]);

            if .SUBMIT in mu.button(uim.ctx, "Submit") {
                // do OpenCL work here ?
                // and update audio stream
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