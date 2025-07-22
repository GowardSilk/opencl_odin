package playground;

import "core:os"
import "core:io"
import "core:mem"
import "core:fmt"
import "core:sync"
import "core:time"
import "core:thread"

Error :: enum {
    None = 0,
    Video_Load_Fail,
}

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
    lock:   sync.Mutex,
    ready_for_request: bool,
}

Engine :: struct {
    allocator: mem.Allocator,
    meta: Meta_Data,

    backing: [^]byte, /**< data buffers will slice this in half */
    data:    [2]Engine_Buffer,
    front:   ^Engine_Buffer,
    back:    ^Engine_Buffer,
    back_being_processed: sync.Cond,
    back_being_processed_lock: sync.Mutex,

    stream: io.Reader,
    eof: bool,

    worker: ^thread.Thread,
}

load_video :: proc(fname: string, allocator := context.allocator) -> (engine: ^Engine, err: Error) {
    merr: mem.Allocator_Error;
    engine, merr = mem.new(Engine, allocator);
    assert(engine != nil && merr == .None);

    /* allocator */
    engine.allocator = allocator;

    /* stream to read the MJPEG data from */
    handle, oerr := os.open(fname);
    if oerr != nil {
        fmt.eprintfln("%v", oerr);
        return {}, .Video_Load_Fail;
    }

    mjpeg_reader: ^MJPEG_Reader;
    mjpeg_reader, merr = mem.new(MJPEG_Reader, allocator);
    assert(merr == .None);

    mjpeg_reader.handle = handle;

    // 8KB buffer for reading should be fine ?
    BUFFER_SIZE :: 16 * 1024;
    mjpeg_reader.buf, merr = mem.make([^]byte, BUFFER_SIZE, allocator);
    assert(merr == .None);
    mjpeg_reader.buf_cap = BUFFER_SIZE;
    mjpeg_reader.buf_len, oerr = os.read_ptr(handle, mjpeg_reader.buf, mjpeg_reader.buf_cap);

    engine.stream = mjpeg_reader_to_iostream(mjpeg_reader);

    /* metadata */
    load_metadata(engine) or_return;

    /* engine buffers */
    engine.backing, merr = mem.make_multi_pointer(
        [^]byte, buffer_size(engine) * 2, allocator
    );
    if merr != .None {
        fmt.eprintfln("Failed to allocate the double buffer; Reason: %v", merr);
        return {}, .Video_Load_Fail;
    }
    engine.data[0].buffer = engine.backing;
    engine.data[1].buffer = mem.ptr_offset(engine.backing, buffer_size(engine));
    engine.front = &engine.data[0];
    engine.back  = &engine.data[1];

    /* detached thread worker for fluid decoding */
    engine.worker = thread.create(decode_image);
    assert(engine.worker != nil);
    engine.worker.data = engine;
    thread.start(engine.worker);

    return engine, nil;
}

unload_video :: proc(engine: ^Engine) {
    thread.terminate(engine^.worker, 0);

    io.destroy(engine^.stream);

    // wait if there is any worker thread work still in progress
    sync.lock(&engine^.back.lock);
    // front buffer cannot be used
    // NOTE(GowardSilk): the deferred_in for request_frame is buggy in a sense if we have request_frame followed by unload_video...
    // that would case the engine.front.lock be unlocked AFTER unload_video, so it has to be explicit...
    assert(sync.try_lock(&engine^.front.lock), "Front buffer's (aka requested Frame's) lifetime has not ended and it is still locked; we cannot unload the frame's backing buffer if the resource is still \"in-use\"");
    mem.free(engine^.backing, engine^.allocator);
    //sync.unlock(&engine^.front.lock);
    sync.unlock(&engine^.back.lock);

    mem.free(engine, engine^.allocator);
}

load_metadata :: proc(engine: ^Engine) -> (err: Error) {
    engine^.meta.bytes_per_pixel = 4;

    when ODIN_DEBUG do assert(engine^.stream.procedure != nil);
    marker, ioerr := get_marker(engine^.stream);
    assert(ioerr == .None);
    for ; marker != SOF0; {
        marker, ioerr = get_marker(engine^.stream);
        assert(ioerr == .None);
    }

    sof0_header: SOF0_Chunk_Header;
    _, ioerr = io.read_ptr(engine^.stream, &sof0_header, size_of(sof0_header));
    assert(ioerr == .None);
    io.seek(engine^.stream, 0, .Start);

    engine^.meta.width  = jpeg_padded_size(sof0_header.width);
    engine^.meta.height = jpeg_padded_size(sof0_header.height);

    return nil;
}

@(deferred_in=unlock_frame)
request_frame :: proc(engine: ^Engine) -> Frame {
    if engine^.eof do return { nil };

    sync.lock(&engine^.front.lock);
    if !engine^.front.ready_for_request {
        sync.unlock(&engine^.front.lock);
        // "wait" for worker thread to be done with the backbuffer work
        sync.lock(&engine^.back_being_processed_lock);
        sync.wait(&engine^.back_being_processed, &engine^.back_being_processed_lock);
        sync.lock(&engine^.front.lock);
    }
    assert(engine^.front.ready_for_request, "Internal sync error: inside request_frame, either the frontbuffer should already have been available or waited for if not!");
    engine^.front.ready_for_request = false;
    return Frame { &engine^.front.buffer };
}

unlock_frame :: proc(engine: ^Engine) {
    sync.lock(&engine^.back.lock);
    // this should be the only case in which the thread would stop working:
    // iff backbuffer.ready == frontbuffer.ready == true
    if engine^.back.ready_for_request {
        engine^.back, engine^.front = engine^.front, engine^.back;
        engine^.front.ready_for_request = true;
        engine^.back.ready_for_request  = false;
        assert(thread.is_done(engine^.worker), "Internal sync error: worker thread should not be active when frontbuffer.ready == true == backbuffer.ready!!");
        thread.start(engine^.worker);
    } else {
        // mark the current frontbuffer ready for swap
        engine^.front.ready_for_request = false;
    }
    sync.unlock(&engine^.back.lock);
    sync.unlock(&engine^.front.lock);
}

SOI  :: [2]byte { 0xFF, 0xD8 };
EOI  :: [2]byte { 0xFF, 0xD9 };
APP0 :: [2]byte { 0xFF, 0xE0 };
DQT  :: [2]byte { 0xFF, 0xDB };
SOF0 :: [2]byte { 0xFF, 0xC0 };
DHT  :: [2]byte { 0xFF, 0xC4 };
SOS  :: [2]byte { 0xFF, 0xDA };
COM  :: [2]byte { 0xFF, 0xFE };

APP0_Chunk :: struct {
    length:         u16be,     // Length of segment excluding marker
    identifier:     [5]byte,   // Usually "JFIF\0"
    version_major:  byte,
    version_minor:  byte,
    density_units:  byte,    // 0 = no units, 1 = dpi, 2 = dpcm
    x_density:      u16be,
    y_density:      u16be,
    thumbnail_width:  byte,
    thumbnail_height: byte,
}

DQT_Chunk :: struct {
    table_info: byte, // High nibble: precision (0 = 8-bit, 1 = 16-bit); low nibble: table ID
    /* NOTE(GowardSilk): We will support only 8-bit precisin */
    table_data: [64]byte,
}

SOF0_Chunk_Component :: struct {
    id: byte,
    sampling: byte,
    quant_table_id: byte,
}

SOF0_Chunk_Header :: struct #packed {
    length:     u16be,
    precision:  byte,
    height:     u16be,
    width:      u16be,
    num_components: byte,
}

SOF0_Chunk :: struct {
    /** @brief contains static info (can be read batched) */
    using header: SOF0_Chunk_Header,
    components: [^]SOF0_Chunk_Component,
}

DHT_Chunk_Table_Info :: distinct byte;

DHT_Chunk_Table_Info_High :: enum byte {
    DC = 0 << 4,
    AC = 1 << 4,
}

DHT_Chunk_Table_Info_Low :: byte;

DHT_Chunk :: struct {
    using header: #type struct {
        table_info:   DHT_Chunk_Table_Info, // High nibble = DC/AC; Low nibble = id
        code_lengths: [16]byte,
    },
    symbols: []byte,
}

SOS_Chunk_Component :: struct {
    id: byte, // Component selector
    huff_tables: byte, // High nibble = DC table ID, low nibble = AC table ID
}

SOS_Chunk :: struct {
    length:          u16be,
    components:      []SOS_Chunk_Component,
    spectral_start:  byte,
    spectral_end:    byte,
    approx:          byte,  // High nibble = bit position high; low nibble = bit position low
}

JPEG :: struct {
    app0:  APP0_Chunk,
    dqts:  map[byte]DQT_Chunk,
    sof0:  SOF0_Chunk,
    dhts:  map[DHT_Chunk_Table_Info]DHT_Graph,
    sos:   SOS_Chunk,
    compressed_data: [dynamic]byte,
}

decode_image :: proc(worker: ^thread.Thread) {
    assert(worker.data != nil);
    engine := cast(^Engine)worker.data;
    assert(!engine^.back.ready_for_request, "Internal sync error: decode_image should be called iff the backbuffer has outdated data.");

    sync.lock(&engine^.back.lock);
    {
        sync.lock(&engine^.back_being_processed_lock);
        defer {
            sync.signal(&engine^.back_being_processed);
            sync.unlock(&engine^.back_being_processed_lock);
        }

        // Start of Image
        marker, ioerr := get_marker(engine.stream);
        if ioerr == .EOF {
            engine.eof = true;
            sync.unlock(&engine^.back.lock);
            return;
        }
        mjpeg := cast(^MJPEG_Reader)engine.stream.data;
        assert(marker == SOI, "Invalid JPEG frame! Expected SOI!");

        jpeg: JPEG;
        defer delete_jpeg(&jpeg, engine^.allocator);

        marker, ioerr = get_marker(engine.stream);

        read_bench :: proc(p: #type proc(_: ^JPEG, _: ^Engine), p_name: string, jpeg: ^JPEG, engine: ^Engine) {
            diff: time.Duration
            {
                time.SCOPED_TICK_DURATION(&diff)
                p(jpeg, engine);
            }
            fmt.eprintfln("\"%s\" took %v", p_name, diff);
        }

        stopwatch: time.Stopwatch;
        time.stopwatch_start(&stopwatch);
        for marker != EOI {
            switch marker.y {
                //case APP0.y: read_app0(&jpeg, engine);
                //case DQT.y:  read_dqt(&jpeg, engine);
                //case SOF0.y: read_sof0(&jpeg, engine);
                //case DHT.y:  read_dht(&jpeg, engine);
                //case SOS.y:  read_sos(&jpeg, engine);
                case APP0.y: read_bench(read_app0, "read_app0", &jpeg, engine);
                case DQT.y:  read_bench(read_dqt, "read_dqt", &jpeg, engine);
                case SOF0.y: read_bench(read_sof0, "read_sof0", &jpeg, engine);
                case DHT.y:  read_bench(read_dht, "read_dht", &jpeg, engine);
                case SOS.y:  read_bench(read_sos, "read_sos", &jpeg, engine);

                /* ignoring */
                case 0xE0..=0xEF, COM.y: // ignore other APP(s) and comments
                    length: u16be;
                    l, err := io.read_ptr(engine.stream, &length, size_of(length));
                    assert(l == size_of(length) && err == .None);
                    skip_len := cast(i64)(length - 2);
                    when ODIN_DEBUG do fmt.eprintfln("Ignoring marker 0xFF%02X (skipping %d bytes)", marker.y, skip_len);
                    io.seek(engine.stream, skip_len, .Current);

                case: unreachable();
            }

            marker, ioerr = get_marker(engine.stream);
            assert(ioerr == .None);
        }
        time.stopwatch_stop(&stopwatch);
        fmt.eprintfln("Reading took: %v", stopwatch._accumulation);

        time.stopwatch_reset(&stopwatch);

        time.stopwatch_start(&stopwatch);
        decompress(engine, &jpeg);
        time.stopwatch_stop(&stopwatch);
        fmt.eprintfln("Decompression took: %v", stopwatch._accumulation);
    }
    sync.lock(&engine^.front.lock);
    if engine^.front.ready_for_request {
        // buffer has not been request yet
        // therefore we cannot perform swap
        // NOTE(GowardSilk): That swap will happen in request_frame conditionally
        sync.unlock(&engine^.front.lock);
        engine^.back.ready_for_request = true;
        sync.unlock(&engine^.back.lock);
        return;
    }
    engine^.back, engine^.front = engine^.front, engine^.back;
    engine^.front.ready_for_request = true;
    engine^.back.ready_for_request  = false;
    // unlock the mutexes in their correct order
    sync.unlock(&engine^.back.lock) // former front
    sync.unlock(&engine^.front.lock); // former back

    decode_image(worker); // start decoding new image frame
}

delete_jpeg :: proc(jpeg: ^JPEG, allocator: mem.Allocator) {
    if jpeg^.dqts != nil do mem.delete(jpeg^.dqts);
    if jpeg^.sof0.components != nil do mem.free(jpeg^.sof0.components, allocator);
    if jpeg^.dhts != nil {
        for _, dht in jpeg^.dhts do delete_dht_graph(dht, allocator);
        mem.delete(jpeg^.dhts);
    }
    if jpeg^.sos.components != nil do mem.delete(jpeg^.sos.components, allocator);
    if jpeg^.compressed_data != nil do mem.delete(jpeg^.compressed_data);
}
