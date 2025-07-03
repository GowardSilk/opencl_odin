package audio;

import "base:runtime"

import "core:c"
import "core:log"
import "core:strings"

import mu "vendor:microui"
import sdl3 "vendor:sdl3"

Text_Buf :: struct {
    buf: [16]byte,
    len: int,
}

UI_Manager :: struct {
    should_close: bool,

    window:   ^sdl3.Window,
    renderer: ^sdl3.Renderer,
    atlas_texture: #type struct {
        surface: ^sdl3.Surface,
        texture: ^sdl3.Texture,
    },

    ctx: ^mu.Context,
    text_bufs: map[mu.Id]Text_Buf,
}

UI_Error :: enum {
    None = 0,

    Init_Fail,
    Window_Creation_Fail,
    Renderer_Creation_Fail,
    Surface_Creation_Fail,
    Texture_Creation_Fail,
}

FONT_WIDTH_SCALE_FACTOR  :: 1;
FONT_HEIGHT_SCALE_FACTOR :: 1;
ATLAS_WIDTH :: mu.DEFAULT_ATLAS_WIDTH * FONT_WIDTH_SCALE_FACTOR;
ATLAS_HEIGHT :: mu.DEFAULT_ATLAS_HEIGHT * FONT_HEIGHT_SCALE_FACTOR;
SCALED_STYLE := mu.Style{
    font = nil,

    size = mu.Vec2{
        i32(68 * FONT_WIDTH_SCALE_FACTOR),
        i32(10 * FONT_HEIGHT_SCALE_FACTOR),
    },
    padding         = i32(5 * FONT_WIDTH_SCALE_FACTOR),
    spacing         = i32(4 * FONT_WIDTH_SCALE_FACTOR),
    indent          = i32(24 * FONT_WIDTH_SCALE_FACTOR),
    title_height    = i32(24 * FONT_HEIGHT_SCALE_FACTOR),
    footer_height   = i32(20 * FONT_HEIGHT_SCALE_FACTOR),
    scrollbar_size  = i32(12 * FONT_WIDTH_SCALE_FACTOR),
    thumb_size      = i32(8  * FONT_WIDTH_SCALE_FACTOR),
    colors = mu.default_style.colors,
};

relative_window_size :: #force_inline proc($base: i32, $scale: i32) -> i32 {
    return base + i32((scale - 1.0) * base / 8);
}
WINDOW_WIDTH  := relative_window_size(1024, FONT_WIDTH_SCALE_FACTOR); 
WINDOW_HEIGHT := relative_window_size(1024, FONT_HEIGHT_SCALE_FACTOR);

atlas_text_width_proc :: proc(font: mu.Font, text: string) -> (width: i32) {
    return mu.default_atlas_text_width(font, text) * FONT_WIDTH_SCALE_FACTOR;
}
atlas_text_height_proc :: proc(font: mu.Font) -> i32 {
    return mu.default_atlas_text_height(font) * FONT_HEIGHT_SCALE_FACTOR;
}

init_ui_manager :: proc() -> (uim: UI_Manager, err: Error) {
    if !sdl3.Init({.VIDEO}) {
        log.errorf("SDL3 Init error: %s", sdl3.GetError());
        return {}, .Init_Fail;
    }
    uim.window = sdl3.CreateWindow("OpenCL Audio Example", WINDOW_WIDTH, WINDOW_HEIGHT, {});
    if uim.window == nil {
        log.errorf("SDL3 Window Init error: %s", sdl3.GetError());
        return {}, .Window_Creation_Fail;
    }
    uim.renderer = sdl3.CreateRenderer(uim.window, nil);
    if uim.renderer == nil {
        log.errorf("SDL3 Renderer Init error: %s", sdl3.GetError());
        return {}, .Renderer_Creation_Fail;
    }

    // microui CONTEXT
    merr: runtime.Allocator_Error;
    uim.ctx, merr = new(mu.Context);
    assert(merr == .None);
    mu.init(uim.ctx);

    // microui FONT_ATLAS
    uim.ctx^._style = SCALED_STYLE;
    uim.ctx^.style = &uim.ctx^._style;
    uim.ctx^.text_width  = atlas_text_width_proc;
    uim.ctx^.text_height = atlas_text_height_proc;

    pixels: [][4]byte;
    pixels, merr = make([][4]byte, ATLAS_WIDTH * ATLAS_HEIGHT);
    assert(merr == .None);
	defer delete(pixels);
    for y in 0..<mu.DEFAULT_ATLAS_HEIGHT {
        for x in 0..<mu.DEFAULT_ATLAS_WIDTH {
            a := mu.default_atlas_alpha[y * mu.DEFAULT_ATLAS_WIDTH + x];
            color := [4]byte{a, a, a, a};

            base_x := x * FONT_WIDTH_SCALE_FACTOR;
            base_y := y * FONT_HEIGHT_SCALE_FACTOR;

            for j in 0..<FONT_HEIGHT_SCALE_FACTOR {
                for i in 0..<FONT_WIDTH_SCALE_FACTOR {
                    pixels[(base_y + j) * ATLAS_WIDTH + (base_x + i)] = color;
                }
            }
        }
    }

    // such scaled text looks like garbage, use SSAA 4x
    // what an irony that this is not GPU accelerated but it is not that slow
    when FONT_WIDTH_SCALE_FACTOR > 1 || FONT_HEIGHT_SCALE_FACTOR > 1 {
        gauss_kernel_7x7 := [49]f64{
            0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
            0.00002292, 0.00078634, 0.00655603, 0.01330373, 0.00655603, 0.00078634, 0.00002292,
            0.00019117, 0.00655603, 0.05472157, 0.11116501, 0.05472157, 0.00655603, 0.00019117,
            0.00038771, 0.01330373, 0.11116501, 0.22508352, 0.11116501, 0.01330373, 0.00038771,
            0.00019117, 0.00655603, 0.05472157, 0.11116501, 0.05472157, 0.00655603, 0.00019117,
            0.00002292, 0.00078634, 0.00655603, 0.01330373, 0.00655603, 0.00078634, 0.00002292,
            0.00000067, 0.00002292, 0.00019117, 0.00038771, 0.00019117, 0.00002292, 0.00000067,
        };

        for y in 0..<ATLAS_HEIGHT {
            for x in 0..<ATLAS_WIDTH {
                r, g, b, a: f64 = 0.0, 0.0, 0.0, 0.0;

                for ky in 0..<7 {
                    for kx in 0..<7 {
                        ix := clamp(x + kx - 3, 0, ATLAS_WIDTH-1);
                        iy := clamp(y + ky - 3, 0, ATLAS_HEIGHT-1);

                        sample := pixels[iy * ATLAS_WIDTH + ix];
                        weight := gauss_kernel_7x7[ky * 7 + kx];

                        r += f64(sample[0]) * weight;
                        g += f64(sample[1]) * weight;
                        b += f64(sample[2]) * weight;
                        a += f64(sample[3]) * weight;
                    }
                }

                pixels[y * ATLAS_WIDTH + x] = [4]byte{
                    byte(clamp(r, 0.0, 255.0)),
                    byte(clamp(g, 0.0, 255.0)),
                    byte(clamp(b, 0.0, 255.0)),
                    byte(clamp(a, 0.0, 255.0)),
                };
            }
        }
    }

    uim.atlas_texture.surface = sdl3.CreateSurfaceFrom(
        ATLAS_WIDTH,
        ATLAS_HEIGHT,
        .RGBA8888,
        raw_data(pixels),
        ATLAS_WIDTH * 4
    );
    if uim.atlas_texture.surface == nil {
        log.errorf("SDL3 Surface Init error: %s", sdl3.GetError());
        return {}, .Surface_Creation_Fail;
    }
    uim.atlas_texture.texture = sdl3.CreateTextureFromSurface(uim.renderer, uim.atlas_texture.surface);
    if uim.atlas_texture.texture == nil {
        log.errorf("SDL3 Texture Init error: %s", sdl3.GetError());
        return {}, .Texture_Creation_Fail;
    }
    sdl3.SetTextureBlendMode(uim.atlas_texture.texture, sdl3.BLENDMODE_BLEND_PREMULTIPLIED);

    /// microui TEXTBOX BUFFERS
    uim.text_bufs = make(map[mu.Id]Text_Buf);

    return uim, nil;
}

ui_register_events :: proc(uim: ^UI_Manager) {
    assert(sdl3.StartTextInput(uim.window));
    defer assert(sdl3.StopTextInput(uim.window));

    to_mui_mouse_key :: proc(key: sdl3.Uint8) -> mu.Mouse {
        if key == sdl3.BUTTON_LEFT do return .LEFT;
        if key == sdl3.BUTTON_RIGHT do return .RIGHT;
        if key == sdl3.BUTTON_MIDDLE do return .MIDDLE;

        unreachable();
    }

    translate_sdl_key :: proc(key: sdl3.Scancode) -> Maybe(mu.Key) {
        #partial switch key {
            case .RETURN:      return mu.Key.RETURN;
            case .BACKSPACE:   return mu.Key.BACKSPACE;
            case .DELETE:      return mu.Key.DELETE;
            case .LEFT:        return mu.Key.LEFT;
            case .RIGHT:       return mu.Key.RIGHT;
            case .HOME:        return mu.Key.HOME;
            case .END:         return mu.Key.END;
            case .LCTRL:       fallthrough;
            case .RCTRL:       return mu.Key.CTRL;
            case .LSHIFT:      fallthrough;
            case .RSHIFT:      return mu.Key.SHIFT;
            case .LALT:        fallthrough;
            case .RALT:        return mu.Key.ALT;
            case .A:           return mu.Key.A;
            case .C:           return mu.Key.C;
            case .V:           return mu.Key.V;
            case .X:           return mu.Key.X;
        };

        return nil;
    }

    event: sdl3.Event;
    for sdl3.PollEvent(&event) {
        #partial switch event.type {
            /// MOUSE
            case .MOUSE_WHEEL:
                mu.input_scroll(uim^.ctx, 0, cast(i32)event.wheel.y * -30);
            case .MOUSE_MOTION:
                mu.input_mouse_move(uim^.ctx, cast(i32)event.motion.x, cast(i32)event.motion.y);
            case .MOUSE_BUTTON_UP:
                mu.input_mouse_up(uim^.ctx, cast(i32)event.button.x, cast(i32)event.button.y, to_mui_mouse_key(event.button.button));
            case .MOUSE_BUTTON_DOWN:
                mu.input_mouse_down(uim^.ctx, cast(i32)event.button.x, cast(i32)event.button.y, to_mui_mouse_key(event.button.button));

            /// KEYBOARD
            case .KEY_DOWN:
                mu_key := translate_sdl_key(event.key.scancode);
                if mu_key != nil do mu.input_key_down(uim^.ctx, mu_key.?);
            case .KEY_UP:
                mu_key := translate_sdl_key(event.key.scancode);
                if mu_key != nil do mu.input_key_up(uim^.ctx, mu_key.?);
            case .TEXT_INPUT:
                text_input := strings.clone_from_cstring(event.text.text);
                defer delete(text_input);
                mu.input_text(uim^.ctx, text_input);

            case .QUIT:
                uim^.should_close = true;
        }
    }
}

ui_render :: proc(uim: ^UI_Manager) {
    sdl3.SetRenderDrawColor(uim.renderer, 51, 51, 51, 255);
    sdl3.RenderClear(uim.renderer);

    render_texture :: proc(uim: ^UI_Manager, src: mu.Rect, dst: mu.Rect) {
        src := sdl3.FRect{cast(f32)src.x, cast(f32)src.y, cast(f32)src.w, cast(f32)src.h};
        dst := sdl3.FRect{cast(f32)dst.x, cast(f32)dst.y, cast(f32)dst.w, cast(f32)dst.h};
        sdl3.RenderTexture(uim.renderer, uim.atlas_texture.texture, &src, &dst);
    }

    cmd: ^mu.Command;
    for variant in mu.next_command_iterator(uim^.ctx, &cmd) {
        switch v in variant {
            case ^mu.Command_Text:
                pos := [2]i32{v.pos.x, v.pos.y};
                for ch in v.str do if ch & 0xc0 != 0x80 {
                    r := min(cast(int)ch, 127);
                    rect := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + r];
                    rect.x *= FONT_WIDTH_SCALE_FACTOR;
                    rect.w *= FONT_WIDTH_SCALE_FACTOR;
                    rect.y *= FONT_HEIGHT_SCALE_FACTOR;
                    rect.h *= FONT_HEIGHT_SCALE_FACTOR;
                    render_texture(uim, rect, {pos.x, pos.y, rect.w, rect.h});
                    pos.x += rect.w;
                }
            case ^mu.Command_Rect:
                r := v.rect;
                c := v.color;
                sdl3.SetRenderDrawColor(uim.renderer, c.r, c.g, c.b, c.a);
                sdl3.RenderFillRect(uim.renderer,
                    &sdl3.FRect{cast(f32)r.x, cast(f32)r.y, cast(f32)r.w, cast(f32)r.h});
            case ^mu.Command_Clip:
                sdl3.SetRenderClipRect(uim.renderer, 
                    &sdl3.Rect{v.rect.x, v.rect.y, v.rect.w, v.rect.h});

            case ^mu.Command_Icon:
                rect := mu.default_atlas[v.id];
                rect.x *= FONT_WIDTH_SCALE_FACTOR;
                rect.y *= FONT_HEIGHT_SCALE_FACTOR;
                rect.w *= FONT_WIDTH_SCALE_FACTOR;
                rect.h *= FONT_HEIGHT_SCALE_FACTOR;
                render_texture(uim, rect, {v.rect.x + (v.rect.w-rect.w)/2, v.rect.y + (v.rect.h-rect.h)/2, rect.w, rect.h});
            case ^mu.Command_Jump: unreachable();
        }
    }

    sdl3.RenderPresent(uim.renderer);
}

delete_ui_manager :: proc(uim: ^UI_Manager) {
    sdl3.DestroyTexture(uim.atlas_texture.texture);
    sdl3.DestroySurface(uim.atlas_texture.surface);
    sdl3.DestroyRenderer(uim.renderer);
    sdl3.DestroyWindow(uim.window);
    sdl3.Quit();

    delete(uim^.text_bufs);
    free(uim^.ctx);
}