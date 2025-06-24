package audio;

import "base:runtime"

import "core:c"

import mu "vendor:microui"
import rl "vendor:raylib"

UI_Manager :: struct {
    ctx: ^mu.Context,
    atlas_texture: rl.Texture2D,
    audio_stream: rl.AudioStream,
    audio_buffer_size: c.int,
}

init_ui_manager :: proc() -> (uim: UI_Manager, err: Error) {
    rl.InitWindow(1024, 1024, "OpenCL Audio Example");
    rl.InitAudioDevice();

    // microui CONTEXT
    merr: runtime.Allocator_Error;
    uim.ctx, merr = new(mu.Context);
    assert(merr == .None);
    mu.init(uim.ctx);

    // microui FONT_ATLAS
    uim.ctx^.text_width = mu.default_atlas_text_width;
    uim.ctx^.text_height = mu.default_atlas_text_height;

    pixels: [][4]byte;
    pixels, merr = make([][4]byte, mu.DEFAULT_ATLAS_WIDTH * mu.DEFAULT_ATLAS_HEIGHT);
    assert(merr == .None);
	for alpha, i in mu.default_atlas_alpha {
		pixels[i] = {0xff, 0xff, 0xff, alpha};
	}
	defer delete(pixels);
		
	image := rl.Image{
		data = raw_data(pixels),
		width   = mu.DEFAULT_ATLAS_WIDTH,
		height  = mu.DEFAULT_ATLAS_HEIGHT,
		mipmaps = 1,
		format  = .UNCOMPRESSED_R8G8B8A8,
	};
	uim.atlas_texture = rl.LoadTextureFromImage(image);

    uim.audio_buffer_size = 4096;
    rl.SetAudioStreamBufferSizeDefault(uim.audio_buffer_size);
    uim.audio_stream = rl.LoadAudioStream(44100, 16, 1);

    return uim, nil;
}

ui_register_mouse_events :: proc(uim: ^UI_Manager) {
    // mouse coordinates
    mouse_pos := [2]i32{rl.GetMouseX(), rl.GetMouseY()};
    mu.input_mouse_move(uim^.ctx, mouse_pos.x, mouse_pos.y);
    mu.input_scroll(uim^.ctx, 0, i32(rl.GetMouseWheelMove() * -30));
    
    // mouse buttons
    @static buttons_to_key := [?]struct{
        rl_button: rl.MouseButton,
        mu_button: mu.Mouse,
    }{
        {.LEFT, .LEFT},
        {.RIGHT, .RIGHT},
        {.MIDDLE, .MIDDLE},
    }
    for button in buttons_to_key {
        if rl.IsMouseButtonPressed(button.rl_button) { 
            mu.input_mouse_down(uim^.ctx, mouse_pos.x, mouse_pos.y, button.mu_button)
        } else if rl.IsMouseButtonReleased(button.rl_button) { 
            mu.input_mouse_up(uim^.ctx, mouse_pos.x, mouse_pos.y, button.mu_button)
        }
    }
}

ui_render :: proc(uim: ^UI_Manager) {
	render_texture :: proc(uim: ^UI_Manager, rect: mu.Rect, pos: [2]i32, color: mu.Color) {
		source := rl.Rectangle{
			f32(rect.x),
			f32(rect.y),
			f32(rect.w),
			f32(rect.h),
		};
		position := rl.Vector2{f32(pos.x), f32(pos.y)};
		
		rl.DrawTextureRec(uim^.atlas_texture, source, position, transmute(rl.Color)color);
	}

    rl.ClearBackground({51, 51, 51, 255});

    rl.BeginDrawing();
    rl.BeginScissorMode(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight());
    cmd: ^mu.Command;
    for variant in mu.next_command_iterator(uim^.ctx, &cmd) {
        switch v in variant {
            case ^mu.Command_Text:
                pos := [2]i32{v.pos.x, v.pos.y};
                for ch in v.str do if ch & 0xc0 != 0x80 {
                    r := min(cast(int)ch, 127);
                    rect := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + r];
                    render_texture(uim, rect, pos, v.color);
                    pos.x += rect.w;
                }
            case ^mu.Command_Rect:
                rl.DrawRectangle(v.rect.x, v.rect.y, v.rect.w, v.rect.h, transmute(rl.Color)v.color);
            case ^mu.Command_Clip:
                rl.EndScissorMode();
                rl.BeginScissorMode(v.rect.x, v.rect.y, v.rect.w, v.rect.h);

            case ^mu.Command_Icon:
                rect := mu.default_atlas[v.id];
                x := v.rect.x + (v.rect.w - rect.w)/2;
                y := v.rect.y + (v.rect.h - rect.h)/2;
                render_texture(uim, rect, {x, y}, v.color);
            case ^mu.Command_Jump: unreachable();
        }
    }
    rl.EndScissorMode();
    rl.EndDrawing();
}

delete_ui_manager :: proc(uim: ^UI_Manager) {
    rl.UnloadTexture(uim.atlas_texture);
    rl.UnloadAudioStream(uim.audio_stream);
    rl.CloseAudioDevice();
    rl.CloseWindow();

    free(uim^.ctx);
}