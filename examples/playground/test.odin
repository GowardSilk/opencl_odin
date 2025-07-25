package playground;

import "base:runtime"

import "core:c"
import "core:fmt"
import "core:mem"
import "core:c/libc"
import "core:time"
import "core:thread"

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

LOAD_FILE :: "skuska.jpg"

custom_load :: proc(options: ^time.Benchmark_Options, allocator: runtime.Allocator) -> time.Benchmark_Error {
    engine, e := load_video(LOAD_FILE, allocator);
    assert(e == .None);
    for !thread.is_done(engine^.worker) {}
    unload_video(engine);
    return nil;
}

stbi_load :: proc(options: ^time.Benchmark_Options, allocator: runtime.Allocator) -> time.Benchmark_Error {
    width, height, channels: c.int;
    image := stbi.load(LOAD_FILE, &width, &height, &channels, 4);
    libc.free(image);
    return nil;
}
