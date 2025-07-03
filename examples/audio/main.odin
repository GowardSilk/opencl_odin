package audio;

import "base:runtime"

import "core:c"
import "core:os"
import "core:log"
import "core:mem"
import "core:sync"
import "core:strings"
import "core:reflect"

import cl "shared:opencl"
import mu "vendor:microui"
import ma "vendor:miniaudio"

Error :: union #shared_nil {
    OpenCL_Error,
    UI_Error,
    ma.result
}

notify_error :: proc($err_msg: string, err: Error) {
    log.errorf("%s; Error: %v", err_msg, err);
    os.exit(-1);
}

Common :: struct {
    am: ^Audio_Manager,
    uim: UI_Manager,
    curr_dir_handle: os.Handle,
}

init_common :: proc() -> (co: Common) {
    am: ^Audio_Manager;
    uim: UI_Manager;
    err: Error;
    os_err: os.Error;

    /// AUDIO MANAGER
    co.am, err = init_audio_manager();
    if err != nil do notify_error("Failed to initialize Audio manager", err);


    /// UI MANAGER
    co.uim, err = init_ui_manager();
    if err != nil do notify_error("Failed to initialize UI manager", err);


    /// SOUND LIST DIRECTORY HANDLE
    {
        curr_dir_base := os.get_current_directory();
        defer delete(curr_dir_base);

        curr_dir := make([]byte, len(curr_dir_base) + size_of("/audio"));
        defer delete(curr_dir);
        copy(curr_dir, curr_dir_base[:]);
        copy_from_string(curr_dir[len(curr_dir_base):], "/audio");

        co.curr_dir_handle, os_err = os.open(cast(string)curr_dir);
        if os_err != nil do notify_error("Failed to open current directory handle", err);
    }

    return co;
}

delete_common :: proc(co: ^Common) {
    delete_audio_manager(co^.am);
    delete_ui_manager(&co^.uim);
    os.close(co^.curr_dir_handle);
}

main :: proc() {
    context.logger = log.create_console_logger();

    co := init_common();
    defer delete_common(&co);

    for !co.uim.should_close {
        ui_register_events(&co.uim);

        mu.begin(co.uim.ctx);
        show_windows(&co);
        mu.end(co.uim.ctx);

        ui_render(&co.uim);
    }
}

show_windows :: #force_inline proc(co: ^Common) {
    show_sound_list_window(co);
    show_aok_settings_window(co);
}

show_sound_list_window :: proc(using co: ^Common) {
    if mu.window(uim.ctx, "Sound List", {0, 0, 512, 512}, {.NO_CLOSE}) {
        err: Error;

        // query all files and play sound files
        infos, read_err := os.read_dir(curr_dir_handle, -1);
        if read_err != nil do notify_error("Failed to query files in `audio` directory", err);
        defer os.file_info_slice_delete(infos);

        for info in infos do if is_sound_file(info) {
            if .SUBMIT in mu.button(uim.ctx, info.name) {
                info_cname := make([]byte, len(info.name) + size_of("audio/") + 1);
                defer delete(info_cname);
                copy_from_string(info_cname[copy_from_string(info_cname, "audio/"):], info.name);

                frames_config: ma.decoder_config;

                // check if any sounds are still playing
                // if so, delete them
                sync.mutex_lock(&am.guarded_decoder.guard);
                {
                    if am.guarded_decoder.decoder.frames != nil {
                        ma.free(am.guarded_decoder.decoder.frames, nil);
                        am.guarded_decoder.decoder.frames_count = 0;
                        am.guarded_decoder.decoder.frames = nil;
                    }
                    frames_config = am.guarded_decoder.decoder.config;
                }
                sync.mutex_unlock(&am.guarded_decoder.guard);

                // decode the file
                // note: this actually need not be locked, `frames_out' is just an out ptr
                // the pPCMframes is handled internally and allocated anew, so this is "thread-safe"
                frames_out: rawptr;
                frames_count: u64;
                res := ma.decode_file(cast(cstring)&info_cname[0],
                    &frames_config,
                    &frames_count,
                    &frames_out,
                );
                if res != .SUCCESS do notify_error("Failed to decode selected file", res);
                assert(frames_out != nil);

                // play the new sound
                sync.mutex_lock(&am.guarded_decoder.guard);
                {
                    am.guarded_decoder.decoder.frames = cast([^]c.short)frames_out;
                    am.guarded_decoder.decoder.frames_count = frames_count;
                    am.guarded_decoder.decoder.index = 0;
                }
                sync.mutex_unlock(&am.guarded_decoder.guard);
            }
        }

        sync.lock(&am.guarded_decoder.guard);
        if am.guarded_decoder.decoder.frames != nil && .SUBMIT in mu.button(uim.ctx, "Submit") {
            am.guarded_decoder.decoder.launch_kernel = true;
        }
        sync.unlock(&am.guarded_decoder.guard);

        if am.guarded_decoder.decoder.launch_kernel && .SUBMIT in mu.button(uim.ctx, "Clear") {
            am.guarded_decoder.decoder.launch_kernel = false;
            am.operations.distortion.base.enabled = false;
        }

        sync.lock(&am.guarded_decoder.guard);
        if am.guarded_decoder.decoder.frames != nil && .SUBMIT in mu.button(uim.ctx, "Stop") {
            delete_wavebuffer(&am.guarded_decoder.decoder.wb);
        }
        sync.unlock(&am.guarded_decoder.guard);
    }
}

show_aok_settings_window :: proc(using co: ^Common) {
    if mu.window(uim.ctx, "Operations", {512, 0, 512, 512}, {.NO_CLOSE}) {
        window_pos := [?]i32 {0, 512};
        window_max_height: i32 = 0;

        struct_info_named := type_info_of(AOK_Operations).variant.(runtime.Type_Info_Named);
        struct_info := struct_info_named.base.variant.(runtime.Type_Info_Struct);
        for i in 0..<struct_info.field_count {
            name := struct_info.names[i];

            // set the checkbox's name by the struct field
            field := reflect.struct_field_by_name(type_of(am^.operations), name);
            base_enabled_offset := reflect.struct_field_by_name(field.type.id, "enabled").offset;
            base_enabled_field := cast(^bool)(cast(uintptr)&am^.operations + field.offset + base_enabled_offset);
            mu.checkbox(uim.ctx, name, base_enabled_field);

            // also append new window with additional settings
            // if it was set
            // this can be set iff there are other members besides "base"
            field_info_named := field.type.variant.(runtime.Type_Info_Named);
            field_info := field_info_named.base.variant.(runtime.Type_Info_Struct);
            if base_enabled_field^ == true && field_info.field_count > 1 {
                if mu.window(uim.ctx, name, {window_pos.x, window_pos.y, 0, 0}, {.AUTO_SIZE, .NO_CLOSE}) {
                    for i in 0..<field_info.field_count {
                        if (reflect.is_float(field_info.types[i])) {
                            mu.label(uim.ctx, field_info.names[i]);
                            textbox_id := mu.get_id_string(uim.ctx, field_info.names[i]);
                            text_buf, ok := &uim.text_bufs[textbox_id];
                            if !ok do text_buf = map_insert(&uim.text_bufs, textbox_id, Text_Buf{});
                            mu.textbox_raw(uim.ctx, text_buf.buf[:], &text_buf.len, textbox_id, mu.layout_next(uim.ctx), {});
                        }
                    }

                    rect := mu.get_current_container(uim.ctx).rect;
                    if rect.h > window_max_height do window_max_height = rect.h;
                    if window_pos.x + rect.w > 1024 {
                        window_pos.x = 0;
                        window_pos.y += window_max_height;
                        window_max_height = 0;
                    } else do window_pos.x += rect.w;
                }
            }
        }
    }
}

is_sound_file :: proc(fi: os.File_Info) -> bool {
    if fi.is_dir do return false;

    if fi.name[len(fi.name)-4:] == ".wav" do return true;
    return false;
}