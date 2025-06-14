/**
 * @file ui.odin
 *
 * @brief contains Angel block reading facilities (text only)
 *
 * @todo we should refactor this for reflection: reading one line, registering all KV pairs and then matching the
 *  member name (of all AngelBlock_* structs) to that specific line; it would be definitely easier and perhaps more
 *  readable than this
 *
 * @defgroup video_fnt
 *
 * @author GowardSilk
 */
package video;

import "base:runtime"

import "core:io"
import "core:os"
import "core:fmt"
import "core:bytes"
import "core:strings"
import "core:strconv"

AngelBlock_InfoBit :: enum u8 {
    Smooth,      // bit 0
    Unicode,     // bit 1
    Italic,      // bit 2
    Bold,        // bit 3
    FixedHeight, // bit 4

    // bits 5-7
    Reserved5,
    Reserved6,
    Reserved7,
}
AngelBlock_InfoBits :: bit_set[AngelBlock_InfoBit];

AngelBlock_InfoPadding :: struct {
    up:     u8,
    right:  u8,
    down:   u8,
    left:   u8,
}

AngelBlock_InfoSpacing :: struct {
    horizontal: u8,
    vertical  : u8,
}

/**
 * This structure gives the layout of the fields.
 * Remember that there should be no padding between members.
 * Allocate the size of the block using the blockSize, as following the block comes the font name,
 *  including the terminating null char.
 * Most of the time this block can simply be ignored.
 */
AngelBlock_Info :: struct #packed {
    font_size: i16, /* size of the font */
    info_bits: AngelBlock_InfoBits,
    char_set : string,  /* the name of OEM charset used (when not unicode) */
    stretch  : u16, /* the font height stretch in percentage, 100% means no stretch */
    aa       : u8,  /* supersampling used, 1 means no supersampling */
    padding  : AngelBlock_InfoPadding, /* padding for each character */
    spacing  : AngelBlock_InfoSpacing, /* spacing for each character */
    outline  : u8, /* outline thickness for characters */
    font_name: string,
}

AngelBlock_CommonBit :: enum u8 {
    Reserved0,
    Reserved1,
    Reserved2,
    Reserved3,
    Reserved4,
    Reserved5,
    Reserved6,

    Packed,
}
AngelBlock_CommonBits :: bit_set[AngelBlock_CommonBit];

/**
 * Special value, will be used to determine the color of different parts of the characters
 * allowed values: 0, 1, 2, 3, 4
 * ------------------------------
 * channel holds glyph data: 0
 * channel holds the outline: 1
 * channel holds the glyph & outline: 2
 * channel does not hold anything: 3
 * channel set to one: 4
 */
AngelBlock_ColorChannel :: distinct u8;
/** @note this block does not support bitmap reads (i.e. `descent`, `ascent` keys are missing) */
AngelBlock_Common :: struct #packed {
    line_height: f32,   /**< distance in pixels between each line of text */
    base       : f32,   /**< the number of pixels from the absolute top of the line to the base of the characters */
    scale_width: f32,   /**< width of the texture */
    scale_height: f32,  /**< height of the texture */
    pages: u16,         /**< the number of texture pages included in the font */
    common_bits: AngelBlock_CommonBits,
    alpha: AngelBlock_ColorChannel,
    rgb: [3]AngelBlock_ColorChannel,
}

/**
 * The ID of a page is its index in the AngelBlock_Pages
 */
AngelBlock_PageID :: distinct u8;
AngelBlock_Page :: struct {
    file_name: string,
}
AngelBlock_Pages :: []AngelBlock_Page;

AngelBlock_TextureChannel :: distinct u8;
AngelBlock_Char :: struct #packed {
    id:         u32, 
    x:          u16, /* left position of the character in the texture */
    y:          u16, /* top position of the character in the texture */
    width:      u16, /* width of the character in the texture */
    height:     u16, /* height of the character in the texture */
    x_offset:   f32, /* how much the curr position should be offsetted when copying the image from texture to the screen */
    y_offset:   f32, /* how much the curr position should be offsetted when copying the image from texture to the screen */
    x_advance:  f32, /* how much the curr postiion should be advanced after drawing the character */
    page:       AngelBlock_PageID, /* texture page where the character is found */
    channel:    AngelBlock_TextureChannel, /* texture channel where the character is found (1 = blue, 2 = green, 4 = red, 8 = alpha, 15 = all channels) */
}
AngelBlock_Chars :: []AngelBlock_Char;

/**
 *  This block is only in the file if there are any kerning pairs with amount differing from 0.
 */
AngelBlock_Kerning :: struct #packed {
    first:  u32, /* first character ID */
    second: u32, /* second character ID */
    amount: i16, /* how much the x position should be adjusted when drawing the 2nd character immedeatly following the first */
}
AngelBlock_Kernings :: []AngelBlock_Kerning;

AngelFNT_File :: struct {
    info:     AngelBlock_Info,
    common:   AngelBlock_Common,
    pages:    AngelBlock_Pages,
    chars:    AngelBlock_Chars,
    kernings: AngelBlock_Kernings,
}

angel_read :: proc(fname: string) -> (file: AngelFNT_File, ok: bool) {
    data := os.read_entire_file_from_filename(fname) or_return;
    defer delete(data);

    word: string;
    char_index: uint = 0;
    for offset: uint = 0; offset < len(data); {
        word, offset = read_word(data, offset);
        switch word {
            case "info":
                offset = angel_read_info(&file.info, data, offset) or_return;

            case "common":
                offset = angel_read_common(&file.common, data, offset) or_return;
                assert(file.common.pages > 0, "At least one page has to be present! (hint: are you missing pages=* key in `common`?)");
                file.pages = make(AngelBlock_Pages, file.common.pages);

            case "page":
                offset = angel_read_page(file.pages, data, offset) or_return;

            case "chars":
                word, offset = read_word(data, offset);
                count := extract_intvalue(word, "count");
                file.chars = make(AngelBlock_Chars, count);
            case "char":
                assert(file.chars != nil, "We do not support adaptive reordering, `chars` has to be before the first `char`");
                offset = angel_read_char(file.chars[:], char_index, data, offset) or_return;
                char_index += 1;

            case "kernings":
                word, offset = read_word(data, offset);
                count := extract_intvalue(word, "count");
                file.kernings = make(AngelBlock_Kernings, count);
            case "kerning": 
                offset = angel_read_kerning(file.kernings, data, offset) or_return;
        }
    }
    
    return file, true;
}

angel_delete :: proc(file: ^AngelFNT_File) {
    assert(file != nil);
    if len(file^.info.font_name) > 0 do delete(file^.info.font_name);
    if len(file^.info.char_set) > 0 do delete(file^.info.char_set);
    if len(file^.kernings) > 0 do delete(file^.kernings);
    if len(file^.pages) > 0 do delete(file^.pages);
    if len(file^.chars) > 0 do delete(file^.chars);
}

@(private="file")
extract_base :: #force_inline proc(word: string) -> int {
    i := 0;
    for i < len(word) && word[i] != '=' {
        i += 1;
    }
    return i;
}

@(private="file")
extract_base_checked :: #force_inline proc(word: string, key: string) -> int {
    i := extract_base(word);
    fmt.assertf(word[:i] == key, "Expected key: \'%s\', but got: \'%s\'", key, word[:i]);
    return i;
}

@(private="file")
extract_floatvalue :: #force_inline proc(word: string, key: string) -> f32 {
    i := extract_base_checked(word, key);
    j := i + 1;

    is_digit :: proc(c: byte) -> bool {
        return (c >= '0' && c <= '9') || c == '.';
    }

    for ; j < len(word) && is_digit(word[j]); j += 1 {}

    //fmt.printf("Reading: \'%f\' as floatvalue\n", strconv.atof(word[i+1:j]));
    return cast(f32)strconv.atof(string(word[i+1:j]));
}

@(private="file")
extract_intvalue :: #force_inline proc(word: string, key: string) -> int {
    i := extract_base_checked(word, key);
    j := i + 1;
    is_float := false;

    is_digit :: proc(c: byte) -> bool {
        return c >= '0' && c <= '9';
    }

    for ; j < len(word) && is_digit(word[j]); j += 1 {}

    //fmt.printf("Reading: \'%d\' as intvalue\n", strconv.atoi(word[i+1:j]));
    return strconv.atoi(string(word[i+1:j]));
}

@(private="file")
extract_intvalues :: #force_inline proc(word: string, key: string, $N: int, values: []int) {
    //fmt.printf("From word: \'%s\'\n", word)
    j := extract_base_checked(word, key) + 1;

    is_digit :: proc(c: byte) -> bool {
        return c >= '0' && c <= '9';
    }

    for i := 0; i < N; i += 1 {
        k := j;
        for ; k < len(word) && is_digit(word[k]); k += 1 {}
        values[i] = strconv.atoi(string(word[j:k]));
        //fmt.printf("\tReading: \'%d\' as intvalue(s) from: \'%s\'\n", values[i], word[j:k]);
        j = k + 1;
    }
}

@(private="file")
extract_strvalue :: #force_inline proc(word: string, key: string) -> string {
    i := extract_base_checked(word, key) + 1;
    fmt.assertf(word[i] == '\"', "Expected \" but received: %c", word[i]);

    j := i + 1;
    for ; j < len(word) && word[j] != '\"'; j += 1 {}

    //fmt.printf("Reading: \'%s\' as strvalue\n", word[i+1:j]);
    return word[i+1:j];
}

@(private="file")
read_word :: proc(data: []byte, offset: uint) -> (string, uint) {
    assert(offset < len(data));

    expect_end_with_quote := false;
    for i := offset; i < len(data); i += 1 {
        if data[i] == '\"' {
            if expect_end_with_quote {
                assert(bytes.is_space(cast(rune)data[i+1]));
                return string(data[offset:i+1]), i+2;
            }
            expect_end_with_quote = true;
        } else if !expect_end_with_quote && bytes.is_space(cast(rune)data[i]) {
            return string(data[offset:i]), i+1;
        }
    }

    return string(data[offset:]), len(data);
}

@(private="file")
read_words :: proc(data: []byte, offset: uint) -> ([dynamic]string, uint) {
    offset := offset;
    m := make([dynamic]string);
    end := offset;
    for ; end < len(data) && data[end] != '\n'; end += 1 {}

    expect_end_with_quote := false;
    i := offset;
    for ; i < end; i += 1 {
        if data[i] == '\"' {
            if expect_end_with_quote {
                fmt.assertf(bytes.is_space(cast(rune)data[i+1]), "Expected whitespace but received: \'%c\'", data[i+1]);
                append(&m, string(data[offset:i+1]));
                offset = i + 2;
                i += 2;
                expect_end_with_quote = false;
                continue;
            }
            expect_end_with_quote = true;
        } else if !expect_end_with_quote && bytes.is_space(cast(rune)data[i]) {
            append(&m, string(data[offset:i]));
            offset = i + 1;
            i += 1;
        }
    }
    if offset < end { 
        append(&m, string(data[offset:end]));
    }

    return m, end+1;
}

@(private="file")
angel_read_info :: proc(info: ^AngelBlock_Info, data: []byte, offset: uint) -> (new_offset: uint, ok: bool) {
    words: [dynamic]string;
    words, new_offset = read_words(data, offset);
    defer delete(words);

    for word in words {
        switch word[:extract_base(word)] {
            case "face":
                info^.font_name = strings.clone(extract_strvalue(word, "face"));
            case "size":
                info^.font_size = cast(i16)extract_intvalue(word, "size");
            case "bold":
                if extract_intvalue(word, "bold") == 1 {
                    info.info_bits |= {.Bold};
                }
            case "smooth":
                if extract_intvalue(word, "smooth") == 1 {
                    info.info_bits |= {.Smooth};
                }
            case "italic":
                if extract_intvalue(word, "italic") == 1 {
                    info.info_bits |= {.Italic};
                }
            case "unicode":
                if extract_intvalue(word, "unicode") == 1 {
                    info.info_bits |= {.Unicode};
                }
            case "charset":
                info.char_set = strings.clone(extract_strvalue(word, "charset"));
            case "padding":
                padding := [4]int{};
                extract_intvalues(word, "padding", 4, padding[:]);
                info^.padding.up    = cast(u8)padding[0];
                info^.padding.right = cast(u8)padding[1];
                info^.padding.down  = cast(u8)padding[2];
                info^.padding.left  = cast(u8)padding[3];
            case "spacing":
                spacing := [2]int{};
                extract_intvalues(word, "spacing", 2, spacing[:]);
                info^.spacing.horizontal = cast(u8)spacing[0];
                info^.spacing.vertical   = cast(u8)spacing[1];
            case:
                fmt.assertf(false, "Unsupported key: \'%s\'; when parsing info block!", word[:extract_base(word)]);
        }
    }

    return new_offset, true;
}

@(private="file")
angel_read_common :: proc(common: ^AngelBlock_Common, data: []byte, offset: uint) -> (new_offset: uint, ok: bool) {
    words: [dynamic]string;
    words, new_offset = read_words(data, offset);
    defer delete(words);

    for word in words {
        switch word[:extract_base(word)] {
            case "lineHeight":
                common^.line_height = extract_floatvalue(word, "lineHeight");
            case "base":
                common^.base = extract_floatvalue(word, "base");
            case "scaleW":
                common^.scale_width = extract_floatvalue(word, "scaleW");
            case "scaleH":
                common^.scale_height = extract_floatvalue(word, "scaleH");
            case "pages":
                common^.pages = cast(u16)extract_intvalue(word, "pages");
            case "packed":
                if extract_intvalue(word, "packed") != 0 {
                    common^.common_bits |= {.Packed};
                }
            case "alphaChnl":
                common^.alpha = cast(AngelBlock_ColorChannel)extract_intvalue(word, "alphaChnl");
            case "redChnl":
                common^.rgb.r = cast(AngelBlock_ColorChannel)extract_intvalue(word, "redChnl");
            case "greenChnl":
                common^.rgb.g = cast(AngelBlock_ColorChannel)extract_intvalue(word, "greenChnl");
            case "blueChnl":
                common^.rgb.b = cast(AngelBlock_ColorChannel)extract_intvalue(word, "blueChnl");
            case "ascent": // bmp fonts not supported
            case "descent": // bmp fonts not supported
            case:
                fmt.assertf(false, "Unsupported key: \'%s\'; when parsing `common`!", word[:extract_base(word)]);
        }
    }

    return new_offset, true;
}

@(private="file")
angel_read_page :: proc(pages: AngelBlock_Pages, data: []byte, offset: uint) -> (new_offset: uint, ok: bool) {
    words: [dynamic]string;
    words, new_offset = read_words(data, offset);
    defer delete(words);

    pages_index := -1;
    for word in words {
        switch word[:extract_base(word)] {
            case "id":
                pages_index = extract_intvalue(word, "id");
                fmt.assertf(pages_index < len(pages), "Expected: %d pages but reading at least %d!", len(pages), pages_index+1);
            case "file":
                assert(pages_index != -1, "Fuzzy reads not supported! `id` of a page must come before `file`!");
                pages[pages_index].file_name = strings.clone(extract_strvalue(word, "file"));
            case:
                fmt.assertf(false, "Unsupported key: \'%s\'; when parsing `page`!", word[:extract_base(word)]);
        }
    }

    return new_offset, true;
}

@(private="file")
angel_read_char :: proc(chars: AngelBlock_Chars, char_index: uint, data: []byte, offset: uint) -> (new_offset: uint, ok: bool) {
    words: [dynamic]string;
    words, new_offset = read_words(data, offset);
    defer delete(words);

    for word in words {
        switch word[:extract_base(word)] {
            case "id":
                chars[char_index].id = cast(u32)extract_intvalue(word, "id");
            case "x":
                chars[char_index].x = cast(u16)extract_intvalue(word, "x");
            case "y":
                chars[char_index].y = cast(u16)extract_intvalue(word, "y");
            case "width":
                chars[char_index].width = cast(u16)extract_intvalue(word, "width");
            case "height":
                chars[char_index].height = cast(u16)extract_intvalue(word, "height");
            case "xoffset":
                chars[char_index].x_offset = extract_floatvalue(word, "xoffset");
            case "yoffset":
                chars[char_index].y_offset = extract_floatvalue(word, "yoffset");
            case "xadvance":
                chars[char_index].x_advance = extract_floatvalue(word, "xadvance");
            case "page":
                chars[char_index].page = cast(AngelBlock_PageID)extract_intvalue(word, "page");
            case "chnl":
                chars[char_index].channel = cast(AngelBlock_TextureChannel)extract_intvalue(word, "chnl");
            case:
                fmt.assertf(false, "Unsupported key: \'%s\'; when parsing `char` with attr: %s!", word[:extract_base(word)], word);
        }
    }

    return new_offset, true;
}

@(private="file")
angel_read_kerning :: proc(kernings: AngelBlock_Kernings, data: []byte, offset: uint) -> (new_offset: uint, ok: bool) {
    assert(false, "TODO: kernings not supported!");
    return 0, false;
}