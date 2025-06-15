package video;

import "core:testing"
import "core:mem"
import "core:fmt"

@(test)
test_info :: proc(t: ^testing.T) {
    backing := context.allocator;
    track: mem.Tracking_Allocator;
    mem.tracking_allocator_init(&track, backing);
    context.allocator = mem.tracking_allocator(&track);

    file, ok := angel_read("video/resources/fonts/font.fnt");
    assert(ok, "Failed to load font!");
    defer {
        angel_delete(&file);

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
        context.allocator = backing;
    }

    // INFO
    testing.expect_value(t, file.info.font_name, "Mikado Medium");
    testing.expect_value(t, file.info.font_size, 32);
    testing.expect_value(t, file.info.info_bits, AngelBlock_InfoBits{.Unicode});
    testing.expect_value(t, file.info.char_set, "unic");
    testing.expect_value(t, file.info.padding, AngelBlock_InfoPadding{4, 4, 4, 4});
    testing.expect_value(t, file.info.spacing, AngelBlock_InfoSpacing{0, 0});
}

@(test)
test_common :: proc(t: ^testing.T) {
    file, ok := angel_read("video/resources/fonts/font.fnt");
    assert(ok, "Failed to load font!");
    defer angel_delete(&file);

    // COMMON
    testing.expect_value(t, file.common.line_height, 43.125);
    testing.expect_value(t, file.common.base, 32.25);
    testing.expect_value(t, file.common.scale_width, 256);
    testing.expect_value(t, file.common.scale_height, 512);
    testing.expect_value(t, file.common.pages, 1);
    testing.expect_value(t, file.common.common_bits, AngelBlock_CommonBits{});
}

@(test)
test_pages :: proc(t: ^testing.T) {
    file, ok := angel_read("video/resources/fonts/font.fnt");
    assert(ok, "Failed to load font!");
    defer angel_delete(&file);

    // PAGE
    testing.expect_value(t, len(file.pages), 1);
    testing.expect_value(t, file.pages[0], AngelBlock_Page{file_name="font.png"});
}

@(test)
test_characters :: proc(t: ^testing.T) {
    file, ok := angel_read("video/resources/fonts/font.fnt");
    assert(ok, "Failed to load font!");
    defer angel_delete(&file);

    // CHARACTERS
    testing.expect_value(t, len(file.chars), 95);

    // Character ID 32 (space)
    {
        char := file.chars[0];
        testing.expect_value(t, char.id, 32);
        testing.expect_value(t, char.x, 216);
        testing.expect_value(t, char.y, 260);
        testing.expect_value(t, char.width, 9);
        testing.expect_value(t, char.height, 9);
        testing.expect_value(t, char.x_offset, 0.0);
        testing.expect_value(t, char.y_offset, 32.25);
        testing.expect_value(t, char.x_advance, 6.912);
        testing.expect_value(t, char.page, 1);
        testing.expect_value(t, char.channel, 15);
    }

    // Character ID 33 (!)
    {
        char := file.chars[1];
        testing.expect_value(t, char.id, 33);
        testing.expect_value(t, char.x, 105);
        testing.expect_value(t, char.y, 204);
        testing.expect_value(t, char.width, 14);
        testing.expect_value(t, char.height, 31);
        testing.expect_value(t, char.x_offset, 1.6875);
        testing.expect_value(t, char.y_offset, 9.5);
        testing.expect_value(t, char.x_advance, 9.184);
        testing.expect_value(t, char.page, 1);
        testing.expect_value(t, char.channel, 15);
    }

    // Character ID 34 (")
    {
        char := file.chars[2];
        testing.expect_value(t, char.id, 34);
        testing.expect_value(t, char.x, 138);
        testing.expect_value(t, char.y, 260);
        testing.expect_value(t, char.width, 18);
        testing.expect_value(t, char.height, 18);
        testing.expect_value(t, char.x_offset, 1.5625);
        testing.expect_value(t, char.y_offset, 8.9375);
        testing.expect_value(t, char.x_advance, 12.8);
        testing.expect_value(t, char.page, 1);
        testing.expect_value(t, char.channel, 15);
    }
}

@(test)
test_kernings :: proc(t: ^testing.T) {
    file, ok := angel_read("video/resources/fonts/font.fnt");
    assert(ok, "Failed to load font!");
    defer angel_delete(&file);

    // KERNINGS
    testing.expect_value(t, len(file.kernings), 0);
}