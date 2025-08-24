package audio;

import "base:runtime"

import "core:c"
import "core:os"
import "core:log"
import "core:fmt"
import "core:mem"
import "core:sync"
import "core:strings"
import "core:strconv"
import "core:reflect"
import "core:container/intrusive/list"

import cl "shared:opencl"
import ma "vendor:miniaudio"
import "vendor:sdl3"

import mu "microui"

Error :: union #shared_nil {
    OpenCL_Error,
    UI_Error,
    ma.result
}

notify_error :: proc($err_msg: string, err: Error) {
    log.errorf("%s; Error: %v", err_msg, err);
    os.exit(-1);
}

Waveform_Channel_Box :: struct {
    minimized: bool,
    index: int,
    vtexture: ^sdl3.Texture,

    node: list.Node,
}

Waveform_Channel_Box_List :: struct {
    /**
     * We know the size of the whole list beforehand, it would be just easier to represent pushing up/down each Channel_Box with a list,
     * so make an preallocated array of size 'max_channels * size_of(Waveform_Channel_Box)'
     */
    memory: []byte,
    list: list.List,
    srect: sdl3.FRect,
}

AUDIO_TRACK_WINDOW_WIDTH := relative_window_size(WINDOW_WIDTH_BASE, FONT_WIDTH_SCALE_FACTOR);
AUDIO_TRACK_WINDOW_HEIGHT := relative_window_size(3 * WAVEFORM_TEX_HEIGHT/2, FONT_HEIGHT_SCALE_FACTOR);
WAVEFORM_TEX_HEIGHT    :: 250;
WAVEFORM_BUTTON_HEIGHT :: WAVEFORM_TEX_HEIGHT / 2;
WAVEFORM_BUTTON_WIDTH  :: WAVEFORM_BUTTON_HEIGHT / 3;
PLAYHEAD_TRIANGLE_LEN  :: 12;
WAVEFORM_COLORS : [8][4]byte = {
    {255,  64,  64, 255}, // Front Left   - bright red
    { 64, 128, 255, 255}, // Front Right  - bright blue
    {255, 200,   0, 255}, // Center       - golden yellow
    {128,  64, 128, 255}, // LFE          - deep purple (subwoofer)
    { 64, 200,  64, 255}, // Surround L   - green
    { 64, 255, 200, 255}, // Surround R   - aqua/cyan
    {255, 128, 255, 255}, // Rear L       - magenta/pink
    {255, 255, 255, 255}, // Rear R       - white (ambient/high)
};
WAVEFORM_CHANNEL_NAMES := [?]string {
    "Front Left",
    "Front Right",
    "Center",
    "LFE",
    "Surround L",
    "Surround R",
    "Rear L",
    "Rear R",
};
Audio_Track_Style :: struct {
    window_body: mu.Rect,

    cnt_body: mu.Rect,
    cnt_fbody: sdl3.FRect,

    spacing: i32,

    scale: [2]f32,
    waveform_tex_size: [2]f32, /**< size of one waveform (per-channel) */
    move_button_size: [2]f32,  /**< size of "move up"/"move down" button */
    playhead_triangle_size: [2]f32,
}

Common :: struct {
    am: ^Audio_Manager,
    uim: UI_Manager,
    curr_dir_handle: os.Handle,
    popup: #type struct {
        enabled: bool,
        name: string,
    },

    // audio track state
    track_style: Audio_Track_Style,
    waveform_texs: ^sdl3.Texture, /**< texture of a rendered waveform of currently playing audio (contains multiple smaller textures, per sound channel) */
    waveform_boxes: Waveform_Channel_Box_List,
    bin_size: u64, /**< nof frames interpolated for one line rendered */
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
    delete_audio_manager(co.am);
    delete_ui_manager(&co.uim);
    os.close(co.curr_dir_handle);
    if co.waveform_texs != nil do sdl3.DestroyTexture(co.waveform_texs);
    if len(co.waveform_boxes.memory) > 0 do mem.delete(co.waveform_boxes.memory);
}

main :: proc() {
    when ODIN_DEBUG {
        allocator := context.allocator;
        track: mem.Tracking_Allocator;
        mem.tracking_allocator_init(&track, allocator);
        context.allocator = mem.tracking_allocator(&track);

        defer {
                if len(track.allocation_map) > 0 {
                        fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map));
                        for _, entry in track.allocation_map {
                                fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location);
                        }
                }
                if len(track.bad_free_array) > 0 {
                        fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array));
                        for entry in track.bad_free_array {
                                fmt.eprintf("- %p @ %v\n", entry.memory, entry.location);
                        }
                }
                mem.tracking_allocator_destroy(&track);

            context.allocator = allocator;
        }
    }

    context.logger = log.create_console_logger();
    defer log.destroy_console_logger(context.logger);

    co := init_common();
    defer delete_common(&co);

    for !co.uim.should_close {
        ui_register_events(&co.uim);

        mu.begin(co.uim.ctx);
        show_windows(&co);
        mu.end(co.uim.ctx);

        ui_render(&co.uim);

        sdl3.RenderPresent(co.uim.renderer);
    }
}

show_windows :: #force_inline proc(co: ^Common) {
    // Menu bar at the top
    //ctx := co.uim.ctx;
    //if window(co.uim.ctx, "XXX", mu.Rect { 0, 0, 200, 200 }) {
    //    for i in 0..<10 {
    //        r := mu.layout_next(co.uim.ctx);
    //        r.x += 1;
    //        mu.layout_set_next(co.uim.ctx, r, false);
    //        button(&co.uim, fmt.tprintf("A%d", i), .Control);
    //    }
    //}
    show_sound_list_window(co);
    //show_aok_settings_window(co);
    //show_popup_window(co);
    show_audio_track(co);
}

label    :: mu.label;
window   :: mu.window;
slider   :: mu.slider;

show_sound_list_window :: proc(using co: ^Common) {
    w_opened := window(
        uim.ctx,
        "Sound List",
        {
            0,
            0,
            relative_window_size(512, FONT_WIDTH_SCALE_FACTOR),
            relative_window_size(512, FONT_HEIGHT_SCALE_FACTOR)
        },
        {.NO_CLOSE}
    );
    if w_opened {
        err: Error;

        // query all files and play sound files
        infos, read_err := os.read_dir(curr_dir_handle, -1);
        if read_err != nil do notify_error("Failed to query files in `audio` directory", err);
        defer os.file_info_slice_delete(infos);

        for info in infos do if is_sound_file(info) {
            if .SUBMIT in button(&uim, info.name) {
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
                frames_out: [^]c.short;
                frames_count: u64;
                res := ma.decode_file(cast(cstring)&info_cname[0],
                    &frames_config,
                    &frames_count,
                    cast(^rawptr)&frames_out,
                );
                if res != .SUCCESS do notify_error("Failed to decode selected file", res);
                assert(frames_out != nil);

                max_amplitude: c.short;
                for i in 0..<frames_count do if max_amplitude < frames_out[i] {
                    max_amplitude = frames_out[i];
                }

                // play the new sound
                sync.mutex_lock(&am.guarded_decoder.guard);
                {
                    am.guarded_decoder.decoder.frames = frames_out;
                    am.guarded_decoder.decoder.frames_count = frames_count;
                    am.guarded_decoder.decoder.index = 0;
                    am.guarded_decoder.decoder.max_amplitude = max_amplitude;
                }
                sync.mutex_unlock(&am.guarded_decoder.guard);

                // restore state of the waveform texture
                restore_waveform_tex(co);
                if !list.is_empty(&co.waveform_boxes.list) {
                    mem.zero_item(&co.waveform_boxes.list);
                    mem.zero_slice(co.waveform_boxes.memory);
                }
                channels := cast(int)am.device.playback.channels;
                if channels > len(co.waveform_boxes.memory) {
                    merr: mem.Allocator_Error;
                    co.waveform_boxes.memory, merr = mem.resize_bytes(co.waveform_boxes.memory, channels * size_of(Waveform_Channel_Box));
                    assert(merr == .None);
                }
                for i in 0..<channels {
                    waveform_box_bytes := cast(^Waveform_Channel_Box)&co.waveform_boxes.memory[i * size_of(Waveform_Channel_Box)];
                    waveform_box_bytes.minimized = false;
                    waveform_box_bytes.index = i;
                    // waveform_box_bytes.srect will be regenerated every time show_audio_track's waveform regen is triggered
                    list.push_back(&co.waveform_boxes.list, &waveform_box_bytes.node);
                }
            }
        }

        // draw a horizontal line
        {
            @static line_vertices: [2]sdl3.Vertex;
            next := mu.layout_next(uim.ctx);
            vpos := cast(f32)next.y + cast(f32)next.h/2;
            hpos := cast(f32)next.x;
            line_vertices[0].position = { 0   + hpos, vpos };
            line_vertices[1].position = { 100 + hpos, vpos };
            fcol := sdl3.FColor {
                cast(f32)uim.ctx.style.colors[.BORDER].r,
                cast(f32)uim.ctx.style.colors[.BORDER].g,
                cast(f32)uim.ctx.style.colors[.BORDER].b,
                cast(f32)uim.ctx.style.colors[.BORDER].a,
            }
            line_vertices[0].color = fcol;
            draw_geometry(&uim, line_vertices[:], runtime.nil_allocator(), .Line);
        }

        sync.lock(&am.guarded_decoder.guard);
        if am.guarded_decoder.decoder.frames != nil && .SUBMIT in button(&uim, "Submit", .Control) {
            am.guarded_decoder.decoder.launch_kernel = true;
            am.guarded_decoder.decoder.pause = false;

            restore_waveform_tex(co);
        }
        sync.unlock(&am.guarded_decoder.guard);

        sync.lock(&am.guarded_decoder.guard);
        if am.guarded_decoder.decoder.launch_kernel && .SUBMIT in button(&uim, "Clear", .Control) {
            am.guarded_decoder.decoder.launch_kernel = false;

            struct_info_named := type_info_of(AOK_Operations).variant.(runtime.Type_Info_Named);
            struct_info := struct_info_named.base.variant.(runtime.Type_Info_Struct);
            for i in 0..<struct_info.field_count {
                field := reflect.struct_field_by_name(type_of(am^.operations), struct_info.names[i]);
                base_enabled_offset := reflect.struct_field_by_name(field.type.id, "enabled").offset;
                base_enabled_field := cast(^bool)(cast(uintptr)&am^.operations + field.offset + base_enabled_offset);
                base_enabled_field^ = false;
            }

            restore_waveform_tex(co);
        }
        sync.unlock(&am.guarded_decoder.guard);

        sync.lock(&am.guarded_decoder.guard);
        pause := &am.guarded_decoder.decoder.pause;
        pause_msg := pause^ ? "Resume" : "Pause";
        if am.guarded_decoder.decoder.frames != nil && .SUBMIT in button(&uim, pause_msg, .Control) {
            pause^ = !pause^;
        }
        sync.unlock(&am.guarded_decoder.guard);

        sync.lock(&am.guarded_decoder.guard);
        if am.guarded_decoder.decoder.frames != nil && .SUBMIT in button(&uim, "Stop", .Control) {
            delete_wavebuffer(&am.guarded_decoder.decoder.wb);

            pause^ = false;
            restore_waveform_tex(co);
        }
        sync.unlock(&am.guarded_decoder.guard);
    }
}

show_aok_settings_window :: proc(using co: ^Common) {
    w_opened := window(
        uim.ctx,
        "Operations",
        {
            relative_window_size(512, FONT_WIDTH_SCALE_FACTOR),
            0,
            relative_window_size(512, FONT_WIDTH_SCALE_FACTOR),
            relative_window_size(512, FONT_HEIGHT_SCALE_FACTOR),
        },
        {.NO_CLOSE}
    );
    if w_opened {
        window_pos := [?]i32 {0, relative_window_size(512, FONT_HEIGHT_SCALE_FACTOR)};
        window_max_height: i32 = 0;

        struct_info_named := type_info_of(AOK_Operations).variant.(runtime.Type_Info_Named);
        struct_info := struct_info_named.base.variant.(runtime.Type_Info_Struct);
        for i in 0..<struct_info.field_count {
            name := struct_info.names[i];

            // set the checkbox's name by the struct field
            field := reflect.struct_field_by_name(type_of(am^.operations), name);
            base_enabled_offset := reflect.struct_field_by_name(field.type.id, "enabled").offset;
            base_enabled_field := cast(^bool)(cast(uintptr)&am^.operations + field.offset + base_enabled_offset);
            checkbox(&uim, name, base_enabled_field);

            // also append new window with additional settings if any were set
            // this can be set iff there are other members besides "base"
            field_info_named := field.type.variant.(runtime.Type_Info_Named);
            field_info := field_info_named.base.variant.(runtime.Type_Info_Struct);
            if base_enabled_field^ == true && field_info.field_count > 1 {
                if window(uim.ctx, name, {window_pos.x, window_pos.y, 0, 0}, {.AUTO_SIZE, .NO_CLOSE}) {
                    for i in 0..<field_info.field_count {
                        if (is_float_type(field_info.types[i])) {
                            label(uim.ctx, field_info.names[i]);
                            textbox_id := mu.get_id_string(uim.ctx, field_info.names[i]);
                            text_buf, ok := &uim.text_bufs[textbox_id];
                            if !ok {
                                text_buf = map_insert(&uim.text_bufs, textbox_id, Text_Buf{});
                                log.infof("Querying key (%d); With value: %f", textbox_id, cast(f64)(reflect_get_generic_float(&am^.operations, field, field_info.offsets[i])^));
                                result := strconv.ftoa(
                                    text_buf.buf[:],
                                    cast(f64)(reflect_get_generic_float(&am^.operations, field, field_info.offsets[i])^),
                                    'f', 5, field_info.types[i].size * 8
                                );
                                text_buf.len = copy_from_string(text_buf.buf[:], result);
                            }
                            if .SUBMIT in mu.textbox_raw(uim.ctx, text_buf.buf[:], &text_buf.len, textbox_id, mu.layout_next(uim.ctx), {}) {
                                rwstr := mem.Raw_String { data=&text_buf.buf[0], len=text_buf.len };
                                val, ok := strconv.parse_f64(transmute(string)rwstr);
                                if !ok {
                                    popup.enabled = true;
                                    popup.name = "Invalid float value!";
                                    delete_key(&uim.text_bufs, textbox_id);
                                } else {
                                    reflect_set_generic_float(&am^.operations, field, field_info.offsets[i], cast(f32)val);
                                }
                            }
                        } else if (is_range_type(field_info.types[i])) {
                            label(uim.ctx, field_info.names[i]);
                            min     := reflect_get_generic_float(&am^.operations, field, field_info.offsets[i] + offset_of(Range, min))^;
                            max     := reflect_get_generic_float(&am^.operations, field, field_info.offsets[i] + offset_of(Range, max))^;
                            actual  := reflect_get_generic_float(&am^.operations, field, field_info.offsets[i] + offset_of(Range, actual));
                            slider(uim.ctx, actual, min, max);
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

is_range_type :: #force_inline proc(type: ^runtime.Type_Info) -> bool {
    return type.id == type_info_of(Range).id;
}

is_float_type :: reflect.is_float;

show_popup_window :: proc(using co: ^Common) {
    if popup.enabled {
        if window(uim.ctx, "Modal Window", {0, 0, 200, 200}, {.NO_SCROLL}) {
            label(uim.ctx, popup.name);
        } else do popup.enabled = false;
    }
}

restore_waveform_tex :: #force_inline proc(using co: ^Common) {
    if waveform_texs != nil {
        sdl3.DestroyTexture(waveform_texs);
        waveform_texs = nil;
        mem.zero_item(&track_style);
    }
}

audio_track_left_controls_size :: #force_inline proc(using style: ^Audio_Track_Style) -> [2]i32 {
    return {
        cast(i32)move_button_size.x + 2 * spacing,
        cast(i32)move_button_size.y + 2 * spacing,
    };
}

update_audio_track_style :: proc(using style: ^Audio_Track_Style, ctx: ^mu.Context, window: ^mu.Container) {
    // calculate the scale from the WHOLE window
    {
        scale.x = cast(f32)window.rect.w / cast(f32)AUDIO_TRACK_WINDOW_WIDTH;
        scale.y = cast(f32)window.rect.h / cast(f32)AUDIO_TRACK_WINDOW_HEIGHT;
    }

    // consider the real "window" to be the one which contents we can change
    cnt_body  = window.body;
    cnt_fbody = sdl3.FRect { cast(f32)cnt_body.x, cast(f32)cnt_body.y, cast(f32)cnt_body.w, cast(f32)cnt_body.h };

    waveform_tex_size.x = cnt_fbody.w;
    waveform_tex_size.y = scale.y * WAVEFORM_TEX_HEIGHT;

    move_button_size.x  = scale.x * WAVEFORM_BUTTON_WIDTH;
    move_button_size.y  = scale.y * WAVEFORM_BUTTON_HEIGHT;

    playhead_triangle_size.x = scale.x * PLAYHEAD_TRIANGLE_LEN;
    playhead_triangle_size.y = scale.y * PLAYHEAD_TRIANGLE_LEN;

    spacing = ctx.style.spacing;
}

create_new_waveform_tex :: #force_inline proc(using co: ^Common) {
    waveform_texs_height := i32(am.device.playback.channels) * i32(track_style.waveform_tex_size.y);
    waveform_texs_width  := i32(track_style.cnt_body.w - audio_track_left_controls_size(&track_style).x);
    waveform_texs = sdl3.CreateTexture(
        uim.renderer,
        .RGBA8888,
        .TARGET,
        waveform_texs_width,
        waveform_texs_height
    );
    if waveform_texs == nil {
        log.errorf("SDL3 Texture Init error: %s", sdl3.GetError());
        unreachable();
    }
}

update_layout :: proc(using co: ^Common, r: mu.Rect) {
    l := mu.get_layout(uim.ctx);
    l.position.x += r.w + track_style.spacing;
    l.next_row = max(l.next_row, r.y + r.h + track_style.spacing);
    l.max.x = max(l.max.x, r.x + r.w);
    l.max.y = max(l.max.y, r.y + r.h);
    mu.layout_set_next(uim.ctx, r, false);
}

show_audio_track :: proc(using co: ^Common) {
    w_opened := window(
        uim.ctx,
        "Waveform Track",
        {
            0,
            relative_window_size(512, FONT_WIDTH_SCALE_FACTOR),
            AUDIO_TRACK_WINDOW_WIDTH,
            AUDIO_TRACK_WINDOW_HEIGHT,
        },
        {.NO_CLOSE}
    );
    if w_opened {
        cnt := mu.get_current_container(uim.ctx);

        // if state of the window (size/pos) changed, trigger waveform gen
        #assert (size_of(track_style.window_body) == size_of(cnt.rect))
        no_waveform := waveform_texs == nil;
        if mem.compare_ptrs(&track_style.window_body, &cnt.rect, size_of(cnt.rect)) != 0 {
            update_audio_track_style(&track_style, uim.ctx, cnt);
            no_waveform = true; // trigger waveform regen
        }

        // waveform(s) gen
        channels := am.device.playback.channels;
        if no_waveform && am.guarded_decoder.decoder.frames_count > 0 {
            create_new_waveform_tex(co);

            sdl3.SetRenderTarget(uim.renderer, waveform_texs);
            sdl3.SetRenderViewport(uim.renderer, nil);
            sdl3.SetRenderClipRect(uim.renderer, nil);
            {
                decoder := am.guarded_decoder.decoder;
                points, merr := mem.make([]sdl3.FPoint, 2 * cast(int)waveform_texs.w);
                if merr != .None {
                    log.errorf("Failed to allocate waveform fpoint line buffer! Reason: %v", merr);
                    return;
                }
                defer mem.delete(points);

                channel_box_yoffset := track_style.waveform_tex_size.y;
                center_y := channel_box_yoffset / 2;
                x_step := 1 / track_style.cnt_fbody.w;
                samples_count := decoder.frames_count / cast(u64)channels;
                bin_size = samples_count / cast(u64)track_style.cnt_body.w;
                // generate waveform textures for each channel
                for i in 0..<channels {
                    wc := WAVEFORM_COLORS[i];
                    sdl3.SetRenderDrawColor(uim.renderer, wc.r, wc.g, wc.b, wc.a);

                    for x in 0..<cast(u64)waveform_texs.w {
                        min_val := decoder.frames[x * bin_size];
                        max_val := min_val;
                        for i in 1..<bin_size {
                            frame := decoder.frames[x * bin_size + i];
                            if frame < min_val do min_val = frame;
                            if frame > max_val do max_val = frame;
                        }

                        y_min := center_y + (cast(f32)min_val / cast(f32)decoder.max_amplitude) * track_style.waveform_tex_size.y/2;
                        y_max := center_y + (cast(f32)max_val / cast(f32)decoder.max_amplitude) * track_style.waveform_tex_size.y/2;

                        points[2 * x]     = sdl3.FPoint{cast(f32)x, y_min};
                        points[2 * x + 1] = sdl3.FPoint{cast(f32)x, y_max};
                    }

                    sdl3.RenderLines(uim.renderer, raw_data(points), auto_cast len(points));

                    center_y += channel_box_yoffset;
                }
            }
            sdl3.SetRenderTarget(uim.renderer, nil);
        }

        if waveform_texs != nil {
            box_idx := 0;
            r := mu.layout_next(uim.ctx);
            r.w = cast(i32)track_style.move_button_size.x;
            r.h = cast(i32)track_style.move_button_size.y;
            // waveform(s) render
            next_it := list.iterator_head(waveform_boxes.list, Waveform_Channel_Box, "node");
            it := next_it;
            for box in list.iterate_next(&next_it) {
                defer r.y += 2 * (cast(i32)track_style.move_button_size.y + track_style.spacing);
                update_layout(co, r);
                // "move up" button
                button_name := [16]byte { 0 = 'a', 1 = cast(byte)box_idx + '0', 2..<16=0 };
                button_id := mu.get_id_bytes(uim.ctx, button_name[:]);
                button_text, ok := uim.text_bufs[button_id];
                if !ok do map_insert(&uim.text_bufs, button_id, Text_Buf { button_name, 2 });
                if .SUBMIT in button(&uim, cast(string)button_text.buf[:2], .Control) { unimplemented(); }

                r2 := mu.Rect { r.x, r.y + cast(i32)track_style.move_button_size.y + track_style.spacing, r.w, r.h };
                update_layout(co, r2);
                // "move down" button
                button_name = [16]byte { 0 = 'b', 1 = cast(byte)box_idx + '0', 2..<16=0 };
                button_id = mu.get_id_bytes(uim.ctx, button_name[:]);
                button_text, ok = uim.text_bufs[button_id];
                if !ok do map_insert(&uim.text_bufs, button_id, Text_Buf { button_name, 2 });
                if .SUBMIT in button(&uim, cast(string)button_text.buf[:2], .Control) { unimplemented(); }

                // custom "icons" for moveup/movedown buttons
                vertices, merr := mem.make([]sdl3.Vertex, 6, context.temp_allocator);
                assert(merr == .None);
                button_width  := track_style.move_button_size.x;
                button_height := track_style.move_button_size.y;
                fr  := sdl3.FRect { cast(f32)r.x, cast(f32)r.y, button_width, button_height };
                fr2 := sdl3.FRect { cast(f32)r2.x, cast(f32)r2.y, fr.x, fr.y };
                {
                    MOVE_BUTTON_FCOLOR :: sdl3.FColor { 255, 255, 255, 255 };
                    vertices[0].position = { fr.x, fr.y + button_height };
                    vertices[1].position = { fr.x + button_width, fr.y + button_height };
                    vertices[2].position = { fr.x + button_width/2, fr.y };
                    vertices[3].position = { fr2.x, fr2.y };
                    vertices[4].position = { fr2.x + button_width, fr2.y };
                    vertices[5].position = { fr2.x + button_width/2, fr2.y + button_height };
                    for &v in vertices do v.color = MOVE_BUTTON_FCOLOR;
                }
                draw_geometry(&uim, vertices, context.temp_allocator);
                vtext(
                    &uim,
                    WAVEFORM_CHANNEL_NAMES[box_idx],
                    sdl3.FRect { fr.x, fr.y, track_style.scale.x, track_style.scale.y },
                    &box.vtexture
                );

                // waveform texture of the current channel
                srect := sdl3.FRect {
                    0, cast(f32)box.index * track_style.waveform_tex_size.y,
                    cast(f32)waveform_texs.w, track_style.waveform_tex_size.y,
                };
                scroll := mu.get_current_container(uim.ctx).scroll;
                drect := sdl3.FRect {
                    track_style.cnt_fbody.x + button_width - cast(f32)scroll.x,
                    track_style.cnt_fbody.y + cast(f32)box.index * track_style.waveform_tex_size.y - cast(f32)scroll.y,
                    cast(f32)waveform_texs.w,
                    track_style.waveform_tex_size.y,
                };
                update_layout(co, mu.Rect {
                    r.x + cast(i32)button_width, r.y,
                    waveform_texs.w, cast(i32)track_style.waveform_tex_size.y
                });
                mu.draw_texture(uim.ctx, cast(rawptr)waveform_texs, srect, drect);

                box_idx += 1;
                it = next_it;
            }

            // playhead
            PLAYHEAD_FCOLOR :: sdl3.FColor { 255, 0, 0, 255 };
            @static playhead_pos: [2]sdl3.Vertex;
            i := am.guarded_decoder.decoder.index;
            pheadx := track_style.cnt_fbody.x + track_style.move_button_size.x + cast(f32)i / cast(f32)(bin_size * u64(channels));
            top    := track_style.cnt_fbody.y;
            bottom := track_style.cnt_fbody.y + track_style.cnt_fbody.h;

            playhead_pos[0].position = sdl3.FPoint{ pheadx, top };
            playhead_pos[1].position = sdl3.FPoint{ pheadx, bottom };

            playhead_pos[0].color = PLAYHEAD_FCOLOR;
            playhead_pos[1].color = PLAYHEAD_FCOLOR;

            draw_geometry(&uim, playhead_pos[:], runtime.nil_allocator(), .Line);
            {
                // 2 triangles: 1 top, 1 bottom
                @static vertices: [6]sdl3.Vertex;
                TRIANGLE_SIDE_LEN := relative_window_size(8.0, track_style.cnt_fbody.w/track_style.cnt_fbody.h);
                vertices[0].position = { pheadx, track_style.cnt_fbody.y };
                vertices[1].position = { pheadx + track_style.playhead_triangle_size.x, track_style.cnt_fbody.y };
                vertices[2].position = { pheadx, track_style.cnt_fbody.y + track_style.playhead_triangle_size.y };
                vertices[3].position = { pheadx, track_style.cnt_fbody.y + track_style.cnt_fbody.h };
                vertices[4].position = { pheadx + track_style.playhead_triangle_size.x, track_style.cnt_fbody.y + track_style.cnt_fbody.h };
                vertices[5].position = { pheadx, track_style.cnt_fbody.y + track_style.cnt_fbody.h - track_style.playhead_triangle_size.y };
                for &v in vertices do v.color = PLAYHEAD_FCOLOR;

                draw_geometry(&uim, vertices[:], runtime.nil_allocator());
            }

            mu.draw_rect(
                uim.ctx,
                mu.Rect {
                    cast(i32)playhead_pos[0].position.x,
                    cast(i32)playhead_pos[0].position.y,
                    cnt.body.w - cast(i32)playhead_pos[0].position.x,
                    cnt.body.h,
                },
                mu.Color { 50, 50, 50, 50 }
            );
        }
    }
}

reflect_get_generic_float :: #force_inline proc(base: rawptr, setting: reflect.Struct_Field, field_offset: uintptr) -> ^f32 {
    return (cast(^f32)(cast(uintptr)base + setting.offset + field_offset));
}

reflect_set_generic_float :: #force_inline proc(base: rawptr, setting: reflect.Struct_Field, field_offset: uintptr, src: f32) {
    dst := reflect_get_generic_float(base, setting, field_offset);
    dst^ = src;
}

is_sound_file :: proc(fi: os.File_Info) -> bool {
    if fi.is_dir do return false;

    if fi.name[len(fi.name)-4:] == ".wav" do return true;
    return false;
}
