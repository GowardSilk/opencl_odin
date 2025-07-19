package playground;

import "core:c"
import "core:c/libc"
import "core:os"
import "core:mem"
import "core:fmt"

import ma "vendor:miniaudio"
import sdl3 "vendor:sdl3"

import stbi "vendor:stb/image"

main :: proc() {
    assert(sdl3.Init({.VIDEO}));
    window := sdl3.CreateWindow("Window", 1000, 500, {});
    defer sdl3.DestroyWindow(window);
    assert(window != nil);
    renderer := sdl3.CreateRenderer(window, nil);
    assert(renderer != nil);
    defer sdl3.DestroyRenderer(renderer);
    defer sdl3.Quit();

    surface2: ^sdl3.Surface;
    texture2: ^sdl3.Texture;
    fname :: "skuska.jpg";
    {
        width, height, channels: c.int;
        pixels := stbi.load(fname, &width, &height, &channels, 4);
        assert(pixels != nil && channels == 3);
        defer libc.free(pixels);
        fmt.eprintfln("Color: {{ %v, %v, %v, %v }}", pixels[0], pixels[1], pixels[2], pixels[3]);

        surface2 = sdl3.CreateSurfaceFrom(width, height, .RGBA8888, pixels, width * 4);
        assert(surface2 != nil);
        sdl3.SetSurfaceBlendMode(surface2, {});
        texture2 = sdl3.CreateTextureFromSurface(renderer, surface2);
        assert(texture2 != nil);
    }
    defer sdl3.DestroySurface(surface2);
    defer sdl3.DestroyTexture(texture2);

    // blue     { 0, 0, 254, 255 } -> { 0, 0, 254, 255 }
    // red      { 254, 0, 0, 255 } -> { 254, 0, 0, 255 }
    // green    { 0, 128, 1, 255 } -> { 0, 128, 0, 255 }
    // cyan     { 0, 255, 255, 255 } -> { 0, 255, 255, 255 }
    // purple   { 129, 0, 127, 255 } -> { 128, 0, 127, 255 }
    // violet   { 238, 130, 239, 255 } -> { 238, 130, 238, 255 }
    // white    { 255, 255, 255, 255 } -> { 255, 255, 255, 255 }
    engine, e := load_video(fname);
    assert(e == .None);
    defer unload_video(engine);
    pixels_size := engine.meta.width * engine.meta.height * 4;
    pixels := make([]byte, pixels_size);
    defer mem.delete(pixels);
    {
        frame := request_frame(engine);
        mem.copy(raw_data(pixels), frame.buffer^, pixels_size);
        fmt.eprintfln("Color custom: {{ %v, %v, %v, %v }}", pixels[0], pixels[1], pixels[2], pixels[3]);
    }

    // surface := sdl3.CreateSurfaceFrom(width, height, .RGBA8888, pixels, width * 4);
    surface := sdl3.CreateSurfaceFrom(cast(c.int)engine.meta.width, cast(c.int)engine.meta.height, .RGBA8888, raw_data(pixels), cast(c.int)engine.meta.width * 4);
    assert(surface != nil);
    defer sdl3.DestroySurface(surface);
    sdl3.SetSurfaceBlendMode(surface, {});
    texture := sdl3.CreateTextureFromSurface(renderer, surface);
    assert(texture != nil);
    defer sdl3.DestroyTexture(texture);

    main_loop: for {
        event: sdl3.Event;
        for sdl3.PollEvent(&event) {
            if event.type == .QUIT do break main_loop;
            if event.type == .KEY_DOWN {
                if event.key.key == sdl3.K_ESCAPE do break main_loop;
            }
        }
        sdl3.SetTextureBlendMode(texture, {});
        sdl3.SetRenderDrawBlendMode(renderer, {});

        sdl3.RenderTexture(
            renderer,
            texture,
            nil,
            &sdl3.FRect {
                0, 0, 500, 500
            }
        );
        sdl3.RenderTexture(
            renderer,
            texture2,
            nil,
            &sdl3.FRect {
                500, 0, 500, 500
            }
        );
        sdl3.RenderPresent(renderer);
    }
}
