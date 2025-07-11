package video;

import "core:os"
import "core:io"
import "core:log"
import "core:mem"
import "core:sync"
import "core:thread"

import stbi "vendor:stb/image"

/** @brief decoded mjpeg frame */
Frame :: struct #no_copy {
    buffer: ^[^]byte,
}

Meta_Data :: struct {
    width:  int,
    height: int,
    /*
     * NOTE(GowardSilk): This should <ALWAYS> be 4 even if the read data won't be.
     * It will be easier for us to parse and also load (e.g. with annoyingly stupid formats in d3d11...).
     * Even if the external (in the file) format will not be 4 bytes, we will pad it.
     */
    bytes_per_pixel: int,
}

Engine_Buffer :: struct {
    buffer: [^]byte,
    lock: sync.Mutex,
}

Engine :: struct {
    allocator: mem.Allocator,
    meta: Meta_Data,

    data:   [2]Engine_Buffer,
    front:  ^Engine_Buffer,
    back:   ^Engine_Buffer,

    stream: io.Reader,

    worker: ^thread.Thread,
}

@(private="file")
buffer_size :: #force_inline proc(using engine: ^Engine) -> int {
    return meta.width * meta.height * meta.bytes_per_pixel;
}

load_video :: proc(fname: string, allocator := context.allocator) -> (engine: Engine, err: Error) {
    /* allocator */
    engine.allocator = allocator;

    /* stream to read the MJPEG data from */
    handle, oerr := os.open(fname);
    if oerr != nil {
        log.errorf("%v", oerr);
        return {}, .Video_Load_Fail;
    }
    engine.stream = os.stream_from_handle(handle);

    /* metadata */
    load_metadata(&engine) or_return;

    /* engine buffers */
    buffer_bytes, merr := make_multi_pointer([^]byte, buffer_size(&engine) * 2);
    if merr != .None {
        log.errorf("Failed to allocate the double buffer; Reason: %v", merr);
        return {}, .Video_Load_Fail;
    }
    engine.data[0].buffer = buffer_bytes;
    engine.data[1].buffer = mem.ptr_offset(buffer_bytes, buffer_size(&engine));
    engine.front = &engine.data[0];
    engine.back  = &engine.data[1];

    /* detached thread worker for fluid decoding */
    engine.worker = thread.create(decode_image);
    assert(engine.worker != nil);

    return engine, nil;
}

@(private="file")
unlock_buffer :: proc(b: ^Engine_Buffer) {
    sync.lock(&b^.lock);
    {
        free(b^.buffer);
        b^.buffer = nil;
    }
    sync.unlock(&b^.lock);
}

unload_video :: proc(engine: ^Engine) {
    thread.terminate(engine^.worker, 0);
    io.close(engine^.stream);
    unlock_buffer(engine^.front);
    unlock_buffer(engine^.back);
}

load_metadata :: proc(engine: ^Engine) -> (err: Error) {
    engine^.meta.bytes_per_pixel = 4;
    return nil;
}

@(deferred_in=unlock_frame)
request_frame :: proc(engine: ^Engine) -> Frame {
    sync.lock(&engine^.front.lock);
    return Frame { &engine^.front.buffer };
}

unlock_frame :: proc(engine: ^Engine) {
    sync.unlock(&engine^.front.lock);
}

SOI  :: [2]byte { 0xFF, 0xD8 };
EOI  :: [2]byte { 0xFF, 0xD9 };
APP0 :: [2]byte { 0xFF, 0xE0 };
DQT  :: [2]byte { 0xFF, 0xDB };
SOF0 :: [2]byte { 0xFF, 0xC0 };
DHT  :: [2]byte { 0xFF, 0xC4 };
SOS  :: [2]byte { 0xFF, 0xDA };

APP0_Chunk :: struct {
    length:      u16be,     // Length of segment excluding marker
    identifier:  [5]byte,     // Usually "JFIF\0"
    version_major: byte,
    version_minor: byte,
    density_units: byte,      // 0 = no units, 1 = dpi, 2 = dpcm
    x_density:   u16be,
    y_density:   u16be,
    thumbnail_width:  byte,
    thumbnail_height: byte,
}

DQT_Chunk :: struct {
    table_info: byte,           // High nibble: precision (0 = 8-bit, 1 = 16-bit); low nibble: table ID
    /* NOTE(GowardSilk): We will support only 8-bit precisin */
    table_data: [64]byte,
}

SOF0_Chunk_Component_Id :: enum byte {
    Y  = 1,
    Cb = 2,
    Cr = 3,
}
SOF0_Chunk_Component :: struct {
    id: SOF0_Chunk_Component_Id,
    sampling: byte,
    quant_table_id: byte,
}

SOF0_Chunk :: struct {
    /** @brief contains static info (can be read batched) */
    using header: #type struct {
        length:     u16be,
        precision:  byte,
        height:     u16be,
        width:      u16be,
        num_components: byte,
    },
    components: [^]SOF0_Chunk_Component,
}

DHT_Chunk_Table_Info :: distinct byte;
DHT_Chunk_Table_Info_High :: enum byte {
    DC = 0 << 4,
    AC = 1 << 4,
}
DHT_Chunk_Table_Info_Low :: byte;
get_dht_id :: #force_inline proc(info: DHT_Chunk_Table_Info) -> DHT_Chunk_Table_Info_Low {
    return cast(byte)(info & 0xf);
}
DHT_Chunk :: struct {
    using header: #type struct {
        table_info:   DHT_Chunk_Table_Info, // High nibble = DC/AC; Low nibble = id
        code_lengths: [16]byte,
    },
    symbols: []byte,
}

SOS_Chunk_Component :: struct {
    id: byte,           // Component selector
    huff_tables: byte,  // High nibble = DC table ID, low nibble = AC table ID
}

SOS_Chunk :: struct {
    length:          u16be,
    components:      []SOS_Chunk_Component,
    spectral_start:  byte,
    spectral_end:    byte,
    approx:          byte,        // High nibble = bit position high; low nibble = bit position low
}

JPEG :: struct {
    app0:  APP0_Chunk,
    dqts:  map[byte]DQT_Chunk,
    sof0:  SOF0_Chunk,
    dhts:  map[byte]DHT_Chunk,
    sos:   SOS_Chunk,
}

decode_image :: proc(worker: ^thread.Thread) {
    assert(worker.data != nil);
    engine := cast(^Engine)worker.data;

    sync.lock(&engine^.back.lock);
    {
        get_marker :: #force_inline proc(stream: io.Reader) -> [2]byte {
            b: byte;
            err: io.Error;
            for b == 0xFF {
                b, err = io.read_byte(stream);
            }

            return [2]byte { 0xFF, b };
        }

        // Start of Image
        marker := get_marker(engine.stream);
        assert(marker == SOI, "Invalid JPEG frame! Expected SOI!");

        jpeg: JPEG;
        defer delete_jpeg(&jpeg);

        marker = get_marker(engine.stream);
        for marker != EOI {
            switch marker {
                case APP0: read_app0(&jpeg, engine.stream);
                case DQT:  read_dqt(&jpeg, engine.stream);
                case SOF0: read_sof0(&jpeg, engine.stream);
                case DHT:  read_dht(&jpeg, engine.stream);
                case SOS:  read_sos(&jpeg, engine.stream);
                case:      unreachable();
            }

            marker = get_marker(engine.stream);
        }
    }
    engine^.back, engine^.front = engine^.front, engine^.back;
    sync.unlock(&engine^.front.lock); // former back

    thread.start(worker); // start decoding new image frame
}

@(private="file")
read_app0 :: #force_inline proc(jpeg: ^JPEG, stream: io.Reader) {
    l, err := io.read_ptr(stream, &jpeg.app0, size_of(jpeg.app0));
    assert(l == size_of(jpeg.app0) && err == .None, "Failed to read whole APP0 Chunk!");
    // ignore thumbnail, if any
    thumbnail_size := jpeg.app0.thumbnail_width * jpeg.app0.thumbnail_height * 3;
    if thumbnail_size > 0 do io.seek(stream, cast(i64)thumbnail_size, .Current);
}

@(private="file")
read_dqt :: #force_inline proc(jpeg: ^JPEG, stream: io.Reader) {
    blength, _ := io.read_byte(stream);
    length := cast(int)blength - size_of(u16be);

    for length > 0 {
        dqt: DQT_Chunk;
        l, err := io.read_ptr(stream, &dqt, size_of(dqt));
        assert(l == size_of(dqt) && err == .None, "Failed to read DQT Chunk!");
        if jpeg.dqts == nil do jpeg.dqts = make(map[byte]DQT_Chunk);
        map_insert(&jpeg.dqts, dqt.table_info & 0xF, dqt);
        length -= l;
    }
}

@(private="file")
read_sof0 :: #force_inline proc(jpeg: ^JPEG, stream: io.Reader) {
    l, err := io.read_ptr(stream, &jpeg.sof0.header, size_of(jpeg.sof0.header));
    assert(l == size_of(jpeg.sof0.header) && err == .None, "Failed to read whole SOF0 Chunk header!");
    jpeg.sof0.components = make_multi_pointer([^]SOF0_Chunk_Component, cast(int)jpeg.sof0.num_components);
    for i in 0..<jpeg.sof0.num_components {
        l, err = io.read_ptr(stream, &jpeg.sof0.components[i], size_of(SOF0_Chunk_Component));
        assert(l == size_of(SOF0_Chunk_Component) && err == .None, "Failed to read whole SOF0 Component Chunk!");
    }
}

@(private="file")
read_dht :: #force_inline proc(jpeg: ^JPEG, stream: io.Reader) {
    blength, _ := io.read_byte(stream);
    length := cast(int)blength - size_of(u16be)

    for length > 0 {
        dht: DHT_Chunk;
        l, err := io.read_ptr(stream, &dht.header, size_of(dht.header));
        assert(l == size_of(dht.header) && err == .None, "Failed to read whole DHT Chunk Header!");

        symbols_len := 0;
        for cl in dht.code_lengths do symbols_len += cast(int)cl;

        merr: mem.Allocator_Error;
        dht.symbols, merr = mem.make([]byte, symbols_len);
        assert(merr == .None);
        l, err = io.read_ptr(stream, raw_data(dht.symbols), symbols_len);
        assert(l == symbols_len && err == .None, "Failed to read DHT Chunk's symbol list!");

        if jpeg.dhts == nil do jpeg.dhts = make(map[byte]DHT_Chunk);
        map_insert(&jpeg.dhts, get_dht_id(dht.table_info), dht);

        length -= l + symbols_len;
    }
}

@(private="file")
read_sos :: #force_inline proc(jpeg: ^JPEG, stream: io.Reader) {
    l, err := io.read_ptr(stream, &jpeg.sos.length, size_of(jpeg.sos.length));
    assert(l == size_of(jpeg.sos.length) && err == .None, "Failed to read whole SOS Chunk!");

    num_components: byte;
    num_components, err = io.read_byte(stream);
    assert(err == .None);
    merr: mem.Allocator_Error;
    jpeg.sos.components, merr = mem.make([]SOS_Chunk_Component, num_components);
    assert(merr == .None);
    l, err = io.read_ptr(stream, raw_data(jpeg.sos.components), size_of([]SOS_Chunk_Component) * cast(int)num_components);
    assert(l == size_of(SOS_Chunk_Component) * cast(int)num_components);

    // ignore 3 bytes
    io.seek(stream, 3, .Current);

    assert(false, "TODO: Read the actual compressed data!");
}

delete_jpeg :: proc(jpeg: ^JPEG) {
    assert(false, "TODO");
}
