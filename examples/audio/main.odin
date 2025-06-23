package audio;

import "core:log"

import ma "vendor:miniaudio"

Audio_Manager :: struct {
    engine: ma.engine,
    sounds: [dynamic]ma.sound,
}

main :: proc() {
    context.logger = log.create_console_logger();

    manager: Audio_Manager;

    if ret := ma.engine_init(nil, &manager.engine); ret != .SUCCESS {
        log.errorf("Failed to initialize engine (err: %v)", ret);
        return;
    }
    defer ma.engine_uninit(&manager.engine);

    ma.engine_start(&manager.engine);

    sound: ma.sound;
    if ret := ma.sound_init_from_file(&manager.engine, "audio/sound1.flac", {}, nil, nil, &sound); ret != .SUCCESS {
        log.errorf("Failed to load \"%s\" sound (err: %v)", "audio/sound1.flac", ret);
        return;
    }
    defer ma.sound_uninit(&sound);

    fence: ma.fence;
    ma.fence_init(&fence);
    sound.endCallback = proc "cdecl" (data: rawptr, sound: ^ma.sound) {
        ma.fence_release(cast(^ma.fence)data);
    };
    sound.pEndCallbackUserData = &fence;
    ma.sound_start(&sound);

    ma.fence_acquire(&fence);
    ma.fence_wait(&fence);

    ma.engine_stop(&manager.engine);
}