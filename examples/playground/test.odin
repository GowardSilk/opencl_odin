package playground;

import "base:runtime"

import "core:c"
import "core:fmt"
import "core:mem"
import "core:c/libc"
import "core:time"

import stbi "vendor:stb/image"

load :: proc() {
    options: time.Benchmark_Options;
    options.bench = custom_load;
    assert(time.benchmark(&options) == nil);
    fmt.eprintfln("Custom load took: %v", options.duration);
    options.bench = stbi_load;
    assert(time.benchmark(&options) == nil);
    fmt.eprintfln("STBI load took: %v", options.duration);
}

custom_load :: proc(options: ^time.Benchmark_Options, allocator: runtime.Allocator) -> time.Benchmark_Error {
    engine, e := load_video("skuska.jpg", allocator);
    assert(e == .None);
    {
        frame := request_frame(engine);
    }
    unload_video(engine);
    return nil;
}

stbi_load :: proc(options: ^time.Benchmark_Options, allocator: runtime.Allocator) -> time.Benchmark_Error {
    width, height, channels: c.int;
    image := stbi.load("skuska.jpg", &width, &height, &channels, 4);
    libc.free(image);
    return nil;
}