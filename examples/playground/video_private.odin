//#+private
package playground;

import "base:builtin"

import "core:io"
import "core:os"
import "core:fmt"
import "core:mem"
import "core:math"
import "core:time"
import "core:simd"

buffer_size :: #force_inline proc(using engine: ^Engine) -> int {
    return meta.width * meta.height * meta.bytes_per_pixel;
}

jpeg_padded_size :: #force_inline proc(size: u16be) -> int {
    if size % 8 == 0 do return cast(int)size;
    return cast(int)(size + 8 - (size % 8));
}

get_marker :: #force_inline proc(stream: io.Reader) -> (bytes: [2]byte, ioerr: io.Error) {
    b := io.read_byte(stream) or_return;
    for b != 0xFF {
        b, ioerr = io.read_byte(stream);
        assert(ioerr == .None);
    }
    for b == 0xFF {
        b, ioerr = io.read_byte(stream);
        assert(ioerr == .None);
    }

    return [2]byte { 0xFF, b }, .None;
}

MJPEG_Reader :: struct {
    handle: os.Handle,
    buf: [^]byte,
    buf_len: int,   /**< nof valid bytes read (actively present) inside `buf' */
    buf_cap: int,   /**< capacity of the `buf' (this remains constant from initialization) */
    pos: int,       /**< index of curr read byte inside `buf' */
    seek_pos: i64,  /**< pos from the beginning of the file */
}

mjpeg_reader_proc :: proc(stream_data: rawptr, mode: io.Stream_Mode, p: []byte, offset: i64, whence: io.Seek_From) -> (n: i64, err: io.Error) {
    reader := cast(^MJPEG_Reader)stream_data;
    assert(reader != nil);

    refill_buffer :: #force_inline proc(reader: ^MJPEG_Reader, bytes_read := 0) -> (n: i64, err: io.Error) {
        bytes_read := bytes_read;
        read_err: os.Error;
        reader.buf_len, read_err = os.read_ptr(reader.handle, reader.buf, reader.buf_cap);
        reader.pos = 0;
        // reader.seek_pos += cast(i64)reader.buf_len;
        bytes_read += reader.buf_len;
        when ODIN_DEBUG do fmt.eprintfln("After refill: \x1b[32m%v\x1b[0m", reader);
        if read_err != nil {
            // NOTE(GowardSilk): We may read less than len(reader.buf) if we hit EOF, which is irrelevant for us
            if bytes_read != 0 && read_err.(io.Error) == .EOF do return cast(i64)bytes_read, .None;
            return 0, read_err.(io.Error);
        }
        return cast(i64)bytes_read, .None;
    }

    switch mode {
        case .Flush:    return 0, .Empty;
        case .Read_At:  return 0, .Empty;
        case .Write_At: return 0, .Empty;
        case .Write:    return 0, .Empty;

        case .Size:
            size, oserr := os.seek(reader.handle, 0, os.SEEK_END);
            if oserr != nil do return 0, .Unknown;

            _, oserr = os.seek(reader.handle, reader.seek_pos, os.SEEK_SET);
            if oserr != nil do return 0, .Unknown;
            return size, .None;

        case .Close:
            if os.close(reader.handle) != nil do return 0, .Unknown;
            return 0, .None;

        case .Read:
            bytes_to_read := len(p);
            bytes_read    := 0;

            if reader.buf_len == 0 do return 0, .EOF;

            if bytes_to_read + reader.pos >= reader.buf_len {
                // copy the rest of the buffered file
                residual := reader.buf_len - reader.pos;
                mem.copy(raw_data(p), &reader.buf[reader.pos], residual);
                bytes_to_read -= residual;
                bytes_read += residual;
                reader.pos = reader.buf_len;

                // read directly into 'p' what has not been buffered
                nofbytes: int;
                buf_len := reader.buf_len; // need to store the actual buf_len, reader.buf_len can be changed inside refill_buffer
                defer {
                    reader.seek_pos += cast(i64)(buf_len + nofbytes);
                }
                if bytes_to_read > 0 {
                    read_err: os.Error;
                    nofbytes, read_err = os.read_ptr(reader.handle, &p[residual], bytes_to_read);
                    bytes_read += nofbytes;
                    if read_err != nil {
                        #partial switch v in read_err {
                            case io.Error:
                                if v == .EOF && nofbytes > 0 do return cast(i64)bytes_read, .None;
                                return cast(i64)bytes_read, read_err.(io.Error);
                            case:
                                return cast(i64)bytes_read, .Unknown;
                        }
                    }
                }

                // populate buffer with next data
                refill_buffer(reader, bytes_read) or_return;
            } else {
                mem.copy(raw_data(p), &reader.buf[reader.pos], bytes_to_read);
                reader.pos += bytes_to_read;
                bytes_read = bytes_to_read;
            }

            return cast(i64)bytes_read, .None;

        case .Seek:
            switch whence {
                case .Start:
                    when ODIN_DEBUG do fmt.eprintfln("[Seek Start] with offet: %v.\nData: %v", offset, reader);
                    if offset < reader.seek_pos || offset > reader.seek_pos + cast(i64)reader.buf_len {
                        err: os.Error;
                        reader.seek_pos, err = os.seek(reader.handle, offset, os.SEEK_SET);
                        assert(err == nil);
                        when ODIN_DEBUG do fmt.eprintfln("\tSeeking new beginning\n\tData: %v", reader);

                        refill_buffer(reader) or_return;
                        when ODIN_DEBUG do fmt.eprintfln("\tRead new data\n\tData: %v\n=----------=", reader);

                        return reader.seek_pos, .None;
                    } else {
                        // no need to read new data, move inside the buffer instead
                        reader.pos = cast(int)(offset - reader.seek_pos);
                        when ODIN_DEBUG do fmt.eprintfln("\tno need to read new data, move inside the buffer instead\n\tData: %v", reader);
                        return offset, .None;
                    }

                case .Current:
                    when ODIN_DEBUG do fmt.eprintfln("[Seek Current] with offet: %v.\nData: %v", offset, reader);
                    if offset > cast(i64)(reader.buf_len - reader.pos) || offset + cast(i64)reader.pos < 0 {
                        err: os.Error;
                        reader.seek_pos, err = os.seek(reader.handle, offset, os.SEEK_CUR);
                        assert(err == nil);
                        when ODIN_DEBUG do fmt.eprintfln("\tSeeking new beginning\n\tData: %v", reader);

                        refill_buffer(reader) or_return;
                        when ODIN_DEBUG do fmt.eprintfln("\tRead new data\n\tData: %v\n=----------=", reader);

                        return reader.seek_pos, .None;
                    } else {
                        // no need to read new data, move inside the buffer instead
                        reader.pos += cast(int)offset;
                        when ODIN_DEBUG do fmt.eprintfln("\tno need to read new data, move inside the buffer instead\n\tData: %v", reader);
                        return reader.seek_pos + cast(i64)reader.pos, .None;
                    }

                case .End:
                    unreachable();
            }

        case .Destroy:
            mjpeg_reader_proc(reader, .Close, nil, 0, .Current);
            mem.free(reader.buf);
            mem.free(reader);
            return 0, .None;

        case .Query:
            return cast(i64)io.Stream_Mode_Set{.Destroy, .Seek, .Read, .Close, .Size}, .None;
    }

    unreachable();
}

mjpeg_reader_to_iostream :: proc(reader: ^MJPEG_Reader) -> io.Stream {
    s: io.Stream
    s.data = rawptr(reader);
    s.procedure = mjpeg_reader_proc;
    return s;
}

read_app0 :: #force_inline proc(jpeg: ^JPEG, using engine:  ^Engine) {
    l, err := io.read_ptr(stream, &jpeg.app0, size_of(jpeg.app0));
    assert(l == size_of(jpeg.app0) && err == .None, "Failed to read whole APP0 Chunk!");
    // ignore thumbnail, if any
    thumbnail_size := jpeg.app0.thumbnail_width * jpeg.app0.thumbnail_height * 3;
    if thumbnail_size > 0 do io.seek(stream, cast(i64)thumbnail_size, .Current);

    when ODIN_DEBUG {
        fmt.eprintln("APP0:");
        fmt.eprintfln("\tlength: %d", transmute(u16le)jpeg.app0.length);
        fmt.eprintfln("\tidentifier: %d", jpeg.app0.identifier);
        assert(jpeg.app0.identifier == { 'J', 'F', 'I', 'F', 0 });
        fmt.eprintfln("\tversion_major: %d", jpeg.app0.version_major);
        fmt.eprintfln("\tversion_minor: %d", jpeg.app0.version_minor);
        fmt.eprintfln("\tdensity_units: %d", jpeg.app0.density_units);
        fmt.eprintfln("\tx_density: %d", cast(u16le)jpeg.app0.x_density);
        fmt.eprintfln("\ty_density: %d", cast(u16le)jpeg.app0.y_density);
        fmt.eprintfln("\tthumbnail_width: %d", jpeg.app0.thumbnail_width);
        fmt.eprintfln("\tthumbnail_height: %d", jpeg.app0.thumbnail_height);
    }
}

read_dqt :: #force_inline proc(jpeg: ^JPEG, using engine: ^Engine) {
    blength: u16be;
    l, err := io.read_ptr(stream, &blength, size_of(blength));
    assert(l == size_of(blength) && err == .None);
    length := cast(int)blength - size_of(u16be);

    for length > 0 {
        dqt: DQT_Chunk;
        l, err = io.read_ptr(stream, &dqt, size_of(dqt));
        assert(l == size_of(dqt) && err == .None, "Failed to read DQT Chunk!");
        assert((dqt.table_info & 0xF0) == 0, "We support only 8-bit precision DQTs!");
        if jpeg.dqts == nil do jpeg.dqts = mem.make(map[byte]DQT_Chunk, allocator);
        map_insert(&jpeg.dqts, dqt.table_info & 0xF, dqt);
        length -= l;

        when ODIN_DEBUG {
            fmt.eprintfln("DQT[<id: %v>]:", dqt.table_info & 0xF);
            fmt.eprintfln("\ttable_info: %d", dqt.table_info);
            fmt.eprint("\ttable_data: [\n\t\t", );
            for data, index in dqt.table_data {
                fmt.eprintf("%d, ", data);
                if index % 8 == 0 && index != 0 do fmt.eprint("\n\t\t");
            }
            fmt.eprintln("\n\t]");
        }
    }
}

read_sof0 :: #force_inline proc(jpeg: ^JPEG, using engine: ^Engine) {
    l, err := io.read_ptr(stream, &jpeg.sof0.header, size_of(jpeg.sof0.header));
    assert(l == size_of(jpeg.sof0.header) && err == .None, "Failed to read whole SOF0 Chunk header!");
    merr: mem.Allocator_Error;
    jpeg.sof0.components, merr = mem.make_multi_pointer(
        [^]SOF0_Chunk_Component, cast(int)jpeg.sof0.num_components, allocator
    );
    assert(merr == .None);
    for i in 0..<jpeg.sof0.num_components {
        l, err = io.read_ptr(stream, &jpeg.sof0.components[i], size_of(SOF0_Chunk_Component));
        assert(l == size_of(SOF0_Chunk_Component) && err == .None, "Failed to read whole SOF0 Component Chunk!");
        //assert(jpeg.sof0.components[i].sampling == 0x11, "Invalid subsamling value! Expected 0x11 (Note: we support only 4:4:4 subsampling)");
    }
    assert(jpeg.sof0.num_components == 3);

    when ODIN_DEBUG {
        fmt.eprintln("SOF0:");
        fmt.eprintln("\theader:");
        fmt.eprintfln("\t\tlength: %v", jpeg.sof0.length);
        fmt.eprintfln("\t\tprecision: %v", jpeg.sof0.precision);
        fmt.eprintfln("\t\theight: %v", cast(u16le)jpeg.sof0.height);
        fmt.eprintfln("\t\twidth: %v", cast(u16le)jpeg.sof0.width);
        fmt.eprintfln("\t\tnum_components: %v", jpeg.sof0.num_components);
        for i in 0..<jpeg.sof0.num_components {
            component := jpeg.sof0.components[i];
            fmt.eprintfln("\tcomponent [%d]:", component.id);
            fmt.eprintfln("\t\tsampling: %d", component.sampling);
            fmt.eprintfln("\t\tquant_table_id: %d", component.quant_table_id);
        }
    }
}

read_dht :: #force_inline proc(jpeg: ^JPEG, using engine: ^Engine) {
    blength: u16be;
    l, err := io.read_ptr(stream, &blength, size_of(blength));
    assert(l == size_of(blength) && err == .None);
    // NOTE(GowardSilk): I honestly have no idea why this does not have to be transmuted into u16le first, but when it is,
    // the values are complete garbage.... ?!?!?!
    length := cast(int)blength - size_of(u16be)

    for length > 0 {
        dht: DHT_Chunk;
        l, err = io.read_ptr(stream, &dht.header, size_of(dht.header));
        assert(l == size_of(dht.header) && err == .None, "Failed to read whole DHT Chunk Header!");

        symbols_len := 0;
        for cl in dht.code_lengths do symbols_len += cast(int)cl;

        merr: mem.Allocator_Error;
        dht.symbols, merr = mem.make([]byte, symbols_len, allocator);
        assert(merr == .None);
        defer mem.delete(dht.symbols, allocator);
        l, err = io.read_ptr(stream, raw_data(dht.symbols), symbols_len);
        assert(l == symbols_len && err == .None, "Failed to read DHT Chunk's symbol list!");

        dht_graph := make_dht_graph(dht, allocator);
        construct_dht_graph(&dht_graph, dht, allocator);

        if jpeg.dhts == nil do jpeg.dhts = make(map[DHT_Chunk_Table_Info]DHT_Graph, allocator);
        assert(dht.table_info not_in jpeg.dhts);
        map_insert(&jpeg.dhts, dht.table_info, dht_graph);

        length -= size_of(dht.header) + symbols_len;

        when ODIN_DEBUG {
            fmt.eprintfln("DHT[<%v; %v>]:", cast(DHT_Chunk_Table_Info_High)(dht.table_info & 0xF0), cast(DHT_Chunk_Table_Info_Low)dht.table_info);

            node_eprint :: proc(node: ^DHT_Graph_Node) {
                if node == nil do return;

                if node^.symbol != HT_NO_SYMBOL && node^.is_leaf {
                    fmt.eprintfln("\tNode:");
                    fmt.eprintfln("\t\tsymbol: %v", node^.symbol);
                    fmt.eprintfln("\t\tcode: %v/0b%b", node^.code, node^.code);
                }

                node_eprint(node^.left);
                node_eprint(node^.right);
            }

            node_eprint(jpeg.dhts[dht.table_info].root);
        }
    }
}

read_sos :: #force_inline proc(jpeg: ^JPEG, using engine: ^Engine) {
    l, err := io.read_ptr(stream, &jpeg.sos.length, size_of(jpeg.sos.length));
    assert(l == size_of(jpeg.sos.length) && err == .None, "Failed to read whole SOS Chunk!");

    // read SOS header
    num_components: byte;
    num_components, err = io.read_byte(stream);
    assert(err == .None);
    merr: mem.Allocator_Error;
    jpeg.sos.components, merr = mem.make([]SOS_Chunk_Component, num_components, allocator);
    assert(merr == .None);
    l, err = io.read_ptr(stream, raw_data(jpeg.sos.components), size_of(SOS_Chunk_Component) * cast(int)num_components);
    assert(l == size_of(SOS_Chunk_Component) * cast(int)num_components);

    when ODIN_DEBUG {
        fmt.eprintln("SOS:");
        fmt.eprintfln("\tlength: %v", jpeg.sos.length);
        for component in jpeg.sos.components {
            fmt.eprintfln("\tcomponent[%v]:", component.id);
            fmt.eprintfln("\t\thuff_tables: %d", component.huff_tables);
        }
        fmt.eprintfln("\tspectral_start: %v", jpeg.sos.spectral_start);
        fmt.eprintfln("\tspectral_end: %v", jpeg.sos.spectral_end);
        fmt.eprintfln("\tapprox: %v", jpeg.sos.approx);
    }

    // ignore 3 bytes
    io.seek(stream, 3, .Current);

    jpeg.compressed_data, merr = mem.make([dynamic]byte, allocator);
    assert(merr == .None);

    b: byte;
    for {
        b, err = io.read_byte(stream);
        assert(err == nil);
        append(&jpeg.compressed_data, b);
        if b == 0xFF {
            b, err = io.read_byte(stream);
            assert(err == nil);
            if b == EOI.y {
                io.seek(stream, -2, .Current);
                break;
            }
            if b == 0x00 do continue;
            append(&jpeg.compressed_data, b);
        }
    }
}

ZIGZAG_ORDER := [?][2]int {
    {0,0},
    {0,1}, {1,0},
    {2,0}, {1,1}, {0,2},
    {0,3}, {1,2}, {2,1}, {3,0},
    {4,0}, {3,1}, {2,2}, {1,3}, {0,4},
    {0,5}, {1,4}, {2,3}, {3,2}, {4,1}, {5,0},
    {6,0}, {5,1}, {4,2}, {3,3}, {2,4}, {1,5}, {0,6},
    {0,7}, {1,6}, {2,5}, {3,4}, {4,3}, {5,2}, {6,1}, {7,0},
    {7,1}, {6,2}, {5,3}, {4,4}, {3,5}, {2,6}, {1,7},
    {2,7}, {3,6}, {4,5}, {5,4}, {6,3}, {7,2},
    {7,3}, {6,4}, {5,5}, {4,6}, {3,7},
    {4,7}, {5,6}, {6,5}, {7,4},
    {7,5}, {6,6}, {5,7},
    {6,7}, {7,6},
    {7,7}
};

fast_idct :: proc(block: ^[64]f64) {
    // This is a fast 2D IDCT based on the AAN (Arai, Agui, Nakajima) algorithm.

    C1 :: 0.490392625;
    C2 :: 0.461939752;
    C3 :: 0.415734798;
    C4 :: 0.353553385;
    C5 :: 0.277785122;
    C6 :: 0.191341713;
    C7 :: 0.097545162;

    workspace: [64]f64;

    // Process rows
    for i in 0..<8 {
        p := block[i*8:];
        o := workspace[i*8:];

        a0 := p[0] + p[4];
        a1 := p[0] - p[4];
        a2 := p[2] * C6 - p[6] * C2;
        a3 := p[2] * C2 + p[6] * C6;
        a4 := a0 + a3;
        a5 := a1 + a2;
        a6 := a1 - a2;
        a7 := a0 - a3;

        b0 := p[1] * C1 + p[7] * C7;
        b1 := p[7] * C1 - p[1] * C7;
        b2 := p[3] * C3 + p[5] * C5;
        b3 := p[5] * C3 - p[3] * C5;
        b4 := b0 + b2;
        b5 := b1 + b3;
        b6 := b1 - b3;
        b7 := b0 - b2;

        o[0] = a4 + b4;
        o[1] = a5 + b5;
        o[2] = a6 + b6;
        o[3] = a7 + b7;
        o[4] = a7 - b7;
        o[5] = a6 - b6;
        o[6] = a5 - b5;
        o[7] = a4 - b4;
    }

    // Process columns
    for i in 0..<8 {
        p := workspace[i:];
        o := block[i:];

        a0 := p[0*8] + p[4*8];
        a1 := p[0*8] - p[4*8];
        a2 := p[2*8] * C6 - p[6*8] * C2;
        a3 := p[2*8] * C2 + p[6*8] * C6;
        a4 := a0 + a3;
        a5 := a1 + a2;
        a6 := a1 - a2;
        a7 := a0 - a3;

        b0 := p[1*8] * C1 + p[7*8] * C7;
        b1 := p[7*8] * C1 - p[1*8] * C7;
        b2 := p[3*8] * C3 + p[5*8] * C5;
        b3 := p[5*8] * C3 - p[3*8] * C5;
        b4 := b0 + b2;
        b5 := b1 + b3;
        b6 := b1 - b3;
        b7 := b0 - b2;

        o[0*8] = (a4 + b4);
        o[1*8] = (a5 + b5);
        o[2*8] = (a6 + b6);
        o[3*8] = (a7 + b7);
        o[4*8] = (a7 - b7);
        o[5*8] = (a6 - b6);
        o[6*8] = (a5 - b5);
        o[7*8] = (a4 - b4);
    }
}

construct_pixel_bytes :: proc(jpeg: ^JPEG, dc_diff: []i32, rle: [3]RLE_Data) -> [64 * 4]byte {
    yuv_pixels: [3][64]i32;

    zzindex_to_matindex :: #force_inline proc(zzindex: int) -> [2]int {
        #no_bounds_check return ZIGZAG_ORDER[zzindex];
    }

    for rle_id in 0..<3 {
        zzorder: [64]i32;
        curr_rle := rle[rle_id];
        zzskip_pos: i32 = -1;

        for i := 0; i <= len(curr_rle.data) - 2; i += 2 {
            nof_zeroes := curr_rle.data[i];
            suc_symbol := curr_rle.data[i + 1]; // number succeeding 0s
            if nof_zeroes == 0 && suc_symbol == 0 do break;

            zzskip_pos += nof_zeroes + 1;
            if zzskip_pos >= 64 do break;

            zzorder[zzskip_pos] = suc_symbol;
        }

        dc_diff[rle_id] += zzorder[0];
        zzorder[0] = dc_diff[rle_id];

        find_qt :: #force_inline proc(jpeg: ^JPEG, id: int) -> byte {
            return jpeg^.sof0.components[id].quant_table_id;
        }
        qt_id := find_qt(jpeg, rle_id);
        qt := jpeg.dqts[qt_id];

        for i in 0..<64 {
            yuv_pos := zzindex_to_matindex(i);
            yuv_pixels[rle_id][yuv_pos.y * 8 + yuv_pos.x] = zzorder[i] * cast(i32)qt.table_data[i];
        }
    }

    // Fast ICDT + Level shift

    //icdt_block: [64]f64;
    //for i in 0..<3 {
    //    for j in 0..<64 do icdt_block[j] = cast(f64)yuv_pixels[i][j];
    //
    //    fast_idct(&icdt_block);
    //
    //    for j in 0..<64 do yuv_pixels[i][j] = cast(int)math.round(icdt_block[j]) + 128;
    //}

    // ICDT coeffs calculation
    
    icdt: [3][64]f64;
    for i in 0..<3 {
        for y in 0..<8 {
            for x in 0..<8 {
                sum: f64;
                for u in 0..<8 {
                    for v in 0..<8 {
                        Cu := u == 0 ? 1.0 / math.sqrt_f64(2.0) : 1.0;
                        Cv := v == 0 ? 1.0 / math.sqrt_f64(2.0) : 1.0;
    
                        y_f64 := cast(f64)y;
                        x_f64 := cast(f64)x;
                        sum += Cu * Cv * cast(f64)yuv_pixels[i][u * 8 + v] * math.cos_f64((2 * x_f64 + 1) * cast(f64)u * math.PI / 16.0) *
                                        math.cos_f64((2 * y_f64 + 1) * cast(f64)v * math.PI / 16.0);
                    }
                }
    
                icdt[i][y * 8 + x] = 0.25 * sum;
            }
        }
    }
    
    // Level shift
    
    for y in 0..<8 {
        for x in 0..<8 {
            yuv_pixels[0][y * 8 + x] = cast(i32)math.round(icdt[0][y * 8 + x]) + 128;
        }
    }

    for i in 1..=2 {
        for y in 0..<8 {
            for x in 0..<8 {
                yuv_pixels[i][y * 8 + x] = cast(i32)math.round(icdt[i][y * 8 + x]);
            }
        }
    }

    // YCbCr to RGB(A)

    out: [64 * 4]byte;

    for y in 0..<8 {
        y_row := simd.from_slice(simd.i32x8, yuv_pixels[0][y * 8 : (y + 1) * 8]);

        cb_row := simd.from_slice(simd.i32x8, yuv_pixels[1][y * 8 : (y + 1) * 8]);
        //cb_row -= 128;

        cr_row := simd.from_slice(simd.i32x8, yuv_pixels[2][y * 8 : (y + 1) * 8]);
        //cr_row -= 128;

        FIXED_BITS      :: 8;
        FIXED_BIT_LANE: simd.u32x8: FIXED_BITS;

        FIXED_R_COEFF   :: 359; // 1.402 * 256
        FIXED_G1_COEFF  :: 88;  // 0.344136 * 256
        FIXED_G2_COEFF  :: 183; // 0.714136 * 256
        FIXED_B_COEFF   :: 453; // 1.772 * 256

        r_row := simd.clamp(y_row + simd.shr(FIXED_R_COEFF * cr_row, FIXED_BIT_LANE), 0, 255);
        g_row := simd.clamp(y_row - simd.shr(FIXED_G1_COEFF * cb_row + FIXED_G2_COEFF * cr_row, FIXED_BIT_LANE), 0, 255);
        b_row := simd.clamp(y_row + simd.shr(FIXED_B_COEFF * cb_row, FIXED_BIT_LANE), 0, 255);

        r_arr := simd.to_array(r_row);
        g_arr := simd.to_array(g_row);
        b_arr := simd.to_array(b_row);

        for x in 0..<8 {
            out[y * 8 * 4 + x * 4 + 0] = cast(byte)r_arr[x];
            out[y * 8 * 4 + x * 4 + 1] = cast(byte)g_arr[x];
            out[y * 8 * 4 + x * 4 + 2] = cast(byte)b_arr[x];
            out[y * 8 * 4 + x * 4 + 3] = 255;
        }
    }

    return out;
}

construct_rle :: proc(jpeg: ^JPEG, bs: ^Bit_Stream, out_rle: ^[3]RLE_Data) {
    find_ht :: #force_inline proc(jpeg: ^JPEG, selector_id: byte) -> (dc: DHT_Chunk_Table_Info, ac: DHT_Chunk_Table_Info) {
        for sos in jpeg.sos.components {
            if sos.id == selector_id {
                dc = (cast(DHT_Chunk_Table_Info)sos.huff_tables & 0xF0) >> 4;
                ac = (cast(DHT_Chunk_Table_Info)sos.huff_tables & 0x0F) | cast(DHT_Chunk_Table_Info)DHT_Chunk_Table_Info_High.AC;
                return dc, ac;
            }
        }

        unreachable();
    }

    decode_value_from_stream :: #force_inline proc(bs: ^Bit_Stream, nof_bits: uint) -> i32 {
        if nof_bits == 0 do return 0;

        value_bits: i16;
        for _ in 0..<nof_bits {
            bit := bitstream_next(bs);
            value_bits = (value_bits << 1) | bit;
        }

        if (value_bits >> (nof_bits - 1)) == 0 {
            value_bits = ~value_bits & ((1 << nof_bits) - 1);
            return -cast(i32)value_bits;
        }

        return cast(i32)value_bits;
    }

    decode_next_huffman_symbol :: #force_inline proc(bs: ^Bit_Stream, table: DHT_Graph) -> (symbol: byte, is_eob: bool) {
        curr_node := table.root;

        // try fast decode
        fast_code := bitstream_grab_fast_bits(bs);
        fast_symbol, exists := table.fast[fast_code];
        if exists {
            for _ in 0..<fast_symbol.length do bitstream_incr(bs);
            //bs.offset += fast_symbol.length;
            //if bs.offset >= 8 {
            //    #no_bounds_check if bs.buffer[bs.index] == 0xFF && bs.buffer[bs.index + 1] == 0x00 {
            //        bs.index += 2;
            //    } else do bs.index += 1;
            //    bs.offset %= 8;
            //}

            return fast_symbol.symbol, false;
        }

        for {
            bit := bitstream_next(bs);

            if bit == 0 do curr_node = curr_node^.left;
            else if bit == 1 do curr_node = curr_node^.right;
            else do unreachable();

            if curr_node == nil do return HT_NO_SYMBOL, false;
            if curr_node^.is_leaf {
                if curr_node^.symbol == HT_NO_SYMBOL {
                    return HT_NO_SYMBOL, true;
                }
                return curr_node^.symbol, false;
            }
        }

        unreachable();
    }

    for rle_id in 0..<3 {
        curr_rle := &out_rle[rle_id];
        dc_ht_id, ac_ht_id := find_ht(jpeg, jpeg.sof0.components[rle_id].id);

        // Scan DC
        dc_symbol, _ := decode_next_huffman_symbol(bs, jpeg.dhts[dc_ht_id]);
        dc_val_len := cast(uint)(dc_symbol & 0x0F);
        dc_val := decode_value_from_stream(bs, dc_val_len);
        append(&curr_rle.data, 0, dc_val);

        // Scan AC
        nof_codes: i32 = 0;
        for nof_codes < 63 {
            ac_symbol, is_eob := decode_next_huffman_symbol(bs, jpeg.dhts[ac_ht_id]);
            if is_eob {
                append(&curr_rle.data, 0, 0);
                break;
            }

            nof_zeroes := cast(i32)(ac_symbol >> 4);
            ac_val_len := cast(uint)(ac_symbol & 0x0F);

            // EOB
            if nof_zeroes == 0 && ac_val_len == 0 {
                append(&curr_rle.data, 0, 0);
                break;
            }

            ac_val := decode_value_from_stream(bs, ac_val_len);
            append(&curr_rle.data, nof_zeroes, ac_val);
            nof_codes += nof_zeroes + 1;
        }
    }
}

deconstruct_rle :: proc(rle: [3]RLE_Data) {
    for r in rle do mem.delete(r.data);
}

decompress :: proc(engine: ^Engine, jpeg: ^JPEG) {
    dst       := engine.back; // assumed to be already locked
    dst_width := engine.meta.width;

    width  := jpeg_padded_size(jpeg^.sof0.width);
    height := jpeg_padded_size(jpeg^.sof0.height);
    assert(width <= engine.meta.width);
    assert(height <= engine.meta.height);

    // retained data across rle and mcu calculations
    bs := init_bitstream(&jpeg.compressed_data);
    dc_diff: [3]i32;

    rle: [3]RLE_Data;
    for &r in rle {
        merr: mem.Allocator_Error;
        r.data, merr = mem.make([dynamic]i32, engine.allocator);
        assert(merr == .None);
    }
    defer deconstruct_rle(rle);

    when ENABLE_BENCH {
        rle_stopwatch, pxbytes_stopwatch, copy_stopwatch: time.Stopwatch;

        for y := 0; y <= height - 8; y += 8 {
            for x := 0; x <= width - 8; x += 8 {
                time.stopwatch_start(&rle_stopwatch);
                construct_rle(jpeg, &bs, &rle);
                time.stopwatch_stop(&rle_stopwatch);
                defer for &r in rle do clear(&r.data);

                time.stopwatch_start(&pxbytes_stopwatch);
                bytes := construct_pixel_bytes(jpeg, dc_diff[:], rle);
                time.stopwatch_stop(&pxbytes_stopwatch);

                mcu_byte_width :: size_of(byte) * 8 * 4; // 4 == engine.meta.bytes_per_pixel
                time.stopwatch_start(&copy_stopwatch);
                for v in 0..<8 {
                    dst_row := &dst.buffer[(y + v) * engine.meta.width * 4 + x * 4];
                    mem.copy(dst_row, &bytes[v * mcu_byte_width], mcu_byte_width);
                }
                time.stopwatch_stop(&copy_stopwatch);
            }
        }

        when ODIN_DEBUG do fmt.eprintfln("RLE avg. time: %vms",      cast(f64)time.stopwatch_duration(rle_stopwatch) / 1e6);
        when ODIN_DEBUG do fmt.eprintfln("PXBYTES avg. time: %vms",  cast(f64)time.stopwatch_duration(pxbytes_stopwatch) / 1e6);
        when ODIN_DEBUG do fmt.eprintfln("COPY avg. time: %vms",     cast(f64)time.stopwatch_duration(copy_stopwatch) / 1e6);
    } else {
        for y := 0; y <= height - 8; y += 8 {
            for x := 0; x <= width - 8; x += 8 {
                construct_rle(jpeg, &bs, &rle);
                defer for &r in rle do clear(&r.data);

                bytes := construct_pixel_bytes(jpeg, dc_diff[:], rle);

                mcu_byte_width :: size_of(byte) * 8 * 4; // 4 == engine.meta.bytes_per_pixel
                for v in 0..<8 {
                    dst_row := &dst.buffer[(y + v) * engine.meta.width * 4 + x * 4];
                    mem.copy(dst_row, &bytes[v * mcu_byte_width], mcu_byte_width);
                }
            }
        }
    }
}

RLE_Data :: struct {
    data: [dynamic]i32,
}

Bit_Stream :: struct {
    buffer: []byte,
    index:  uint, /**< index of the current byte taken, if offset==8, the next byte will be loaded and this index incremented */
    offset: byte, /**< nof bits pushed from buffer[index] into curr */
}

init_bitstream :: #force_inline proc(backing: ^[dynamic]byte) -> (bs: Bit_Stream) {
    append(backing, 0, 0); // pading zero, so we can avoid checking for boundaries when grabbing FAST_BITS
    bs.buffer = backing[:];
    return bs;
}

_bitstream_next_helper :: #force_inline proc(using bs: ^Bit_Stream) -> i16 {
    when ODIN_DEBUG do assert(index < builtin.len(buffer) - 1);
    #no_bounds_check return cast(i16)(((buffer[index] << offset) & ~byte(0x7F)) >> 7);
}

bitstream_next :: #force_inline proc(using bs: ^Bit_Stream) -> i16 {
    next_bit := _bitstream_next_helper(bs);
    bitstream_incr(bs);
    return next_bit;
}

/**
 * @brief grabs FAST_MAP_KEY_NOF_BITS from the stream
 * @note function does not increment the counter by the NOT_BITS, it remains the same
 */
bitstream_grab_fast_bits :: #force_inline proc(using bs: ^Bit_Stream) -> u16 {
    #assert(FAST_MAP_KEY_NOF_BITS >= size_of(buffer[0]))

    next := index + 1;
    //if buffer[index] == 0xFF && buffer[next] == 0x00 do next += 1;
    #no_bounds_check {
        chunk := cast(u16)buffer[index] << 8 | cast(u16)buffer[next];
        return (chunk >> (16 - offset - FAST_MAP_KEY_NOF_BITS)) & ((1 << FAST_MAP_KEY_NOF_BITS) - 1);
    }
}

bitstream_incr :: #force_inline proc(using bs: ^Bit_Stream) {
    offset += 1;
    if offset >= 8 {
        index += 1;
        //if buffer[index] == 0xFF && buffer[index + 1] == 0x00 {
        //    index += 2;
        //} else do index += 1;
        offset = 0;
    }
}

HT_NO_SYMBOL :: 0;

DHT_Graph_Node_Code :: struct {
    code: u16,
}

DHT_Graph_Node_Symbol :: byte;

DHT_Graph_Node :: struct {
    is_leaf: bool,

    symbol:  DHT_Graph_Node_Symbol,
    using _: DHT_Graph_Node_Code,

    left:    ^DHT_Graph_Node,
    right:   ^DHT_Graph_Node,
    parent:  ^DHT_Graph_Node, // nil == root
}

FAST_MAP_KEY_NOF_BITS :: 9;

/** @brief maps codes of fixed size (FAST_BITS) directly into the symbol (a little optimization for fast huffman decoding) */
DHT_Graph_Fast_Map_Value :: struct {
    symbol: DHT_Graph_Node_Symbol,
    length: byte,
}
DHT_Graph_Fast_Map :: map[u16]DHT_Graph_Fast_Map_Value;

DHT_Graph :: struct {
    root: ^DHT_Graph_Node,
    fast: DHT_Graph_Fast_Map,
}

make_dht_graph :: #force_inline proc(dht: DHT_Chunk, allocator: mem.Allocator) -> (graph: DHT_Graph) {
    graph.root = make_dht_node(nil, allocator);
    make_dht_left_node(graph.root, allocator);
    make_dht_right_node(graph.root, allocator);
    graph.fast = make(map[u16]DHT_Graph_Fast_Map_Value);
    return graph;
}

delete_dht_graph :: #force_inline proc(graph: DHT_Graph, allocator: mem.Allocator) {
    node := graph.root;
    if node == nil do return;

    delete_path :: proc(node: ^DHT_Graph_Node, allocator: mem.Allocator) {
        if node == nil do return;

        delete_path(node^.left, allocator);
        delete_path(node^.right, allocator);
        delete_dht_node(node, allocator);
    }

    delete_path(node^.left, allocator);
    delete_path(node^.right, allocator);
    delete_dht_node(node, allocator);

    delete(graph.fast);
}

make_dht_node :: #force_inline proc(parent: ^DHT_Graph_Node, allocator: mem.Allocator) -> ^DHT_Graph_Node {
    node, err := mem.new(DHT_Graph_Node, allocator);
    assert(err == .None);
    mem.zero_item(node);

    node^.symbol = HT_NO_SYMBOL;
    node^.parent = parent;
    return node;
}

make_dht_left_node :: #force_inline proc(parent: ^DHT_Graph_Node, allocator: mem.Allocator) {
    node := make_dht_node(parent, allocator);
    node^.code = parent^.code << 1;
    parent^.left = node;
}

make_dht_right_node :: #force_inline proc(parent: ^DHT_Graph_Node, allocator: mem.Allocator) {
    node := make_dht_node(parent, allocator);
    node^.code = parent^.code << 1 | 0x1;
    parent^.right = node
}

delete_dht_node :: mem.free;

construct_dht_graph :: proc(graph: ^DHT_Graph, dht: DHT_Chunk, allocator: mem.Allocator) {
    leftmost := graph.root.left;
    symbols  := dht.symbols;

    get_right_level_node :: proc(node: ^DHT_Graph_Node) -> ^DHT_Graph_Node {
        if node == nil do return nil;

        if node^.parent^.left == node do return node^.parent^.right;

        ptr := node;
        count := 0;
        for ptr^.parent != nil && ptr^.parent^.right == ptr {
            ptr = ptr^.parent;
            count += 1;
        }

        if ptr^.parent == nil do return nil;

        ptr = ptr^.parent.right;
        for count > 0 {
            ptr = ptr^.left;
            count -= 1;
        }

        return ptr;
    }

    for count, index in dht.code_lengths {
        if count > 0 {
            for symbol in symbols[:count] {
                leftmost^.symbol = symbol;
                leftmost^.is_leaf = true;
                if index <= FAST_MAP_KEY_NOF_BITS {
                    code_len := cast(byte)index + 1;
                    bits_to_fill := FAST_MAP_KEY_NOF_BITS - code_len;
                    num_replicas := 1 << bits_to_fill;
                    base := leftmost^.code << bits_to_fill;
                    for i in 0..<num_replicas {
                        map_insert(&graph.fast, base | cast(u16)i, DHT_Graph_Fast_Map_Value{symbol, code_len});
                    }
                }
                leftmost = get_right_level_node(leftmost);
            }
            symbols = symbols[count:];

            make_dht_left_node(leftmost, allocator);
            make_dht_right_node(leftmost, allocator);

            current := get_right_level_node(leftmost);
            leftmost = leftmost^.left;
            for current != nil {
                make_dht_left_node(current, allocator);
                make_dht_right_node(current, allocator);
                current = get_right_level_node(current);
            }
        } else {
            current := leftmost;
            for current != nil {
                make_dht_left_node(current, allocator);
                make_dht_right_node(current, allocator);
                current = get_right_level_node(current);
            }

            leftmost = leftmost^.left;
        }
    }
}
