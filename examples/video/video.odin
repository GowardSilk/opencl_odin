package video;

import "base:builtin"

import "core:os"
import "core:io"
import "core:log"
import "core:fmt"
import "core:mem"
import "core:math"
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

@(private="file")
buffer_size :: #force_inline proc(using engine: ^Engine) -> int {
    return meta.width * meta.height * meta.bytes_per_pixel;
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
        log.errorf("%v", oerr);
        return {}, .Video_Load_Fail;
    }
    engine.stream = os.stream_from_handle(handle);

    /* metadata */
    load_metadata(engine) or_return;

    /* engine buffers */
    engine.backing, merr = mem.make_multi_pointer(
        [^]byte, buffer_size(engine) * 2, allocator
    );
    if merr != .None {
        log.errorf("Failed to allocate the double buffer; Reason: %v", merr);
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

    io.close(engine^.stream);

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
    for marker != SOF0 {
        marker, ioerr = get_marker(engine^.stream);
        assert(ioerr == .None);
    }

    sof0_header: SOF0_Chunk_Header;
    io.read_ptr(engine^.stream, &sof0_header, size_of(sof0_header));
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
        //fmt.eprintfln("Front: %v; Back: %v", cast(rawptr)engine^.front, cast(rawptr)engine^.back);
        sync.lock(&engine^.back_being_processed_lock);
        sync.wait(&engine^.back_being_processed, &engine^.back_being_processed_lock);
        sync.lock(&engine^.front.lock);
        //fmt.eprintfln("Front: %v; Back: %v", cast(rawptr)engine^.front, cast(rawptr)engine^.back);
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

@(private="file")
jpeg_padded_size :: #force_inline proc(size: u16be) -> int {
    if size % 8 == 0 do return cast(int)size;
    return cast(int)(size + 8 - (size % 8));
}

@(private="file")
get_marker :: #force_inline proc(stream: io.Reader) -> (bytes: [2]byte, ioerr: io.Error) {
    b := io.read_byte(stream) or_return;
    for b != 0xFF {
        b, ioerr = io.read_byte(stream);
        assert(ioerr == .None);
    }
    for b == 0xFF || b == 0x00 {
        b, ioerr = io.read_byte(stream);
        assert(ioerr == .None);
    }

    return [2]byte { 0xFF, b }, .None;
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
        assert(marker == SOI, "Invalid JPEG frame! Expected SOI!");

        jpeg: JPEG;
        defer delete_jpeg(&jpeg, engine^.allocator);

        when ODIN_DEBUG do fmt.eprintln("=============== [JPEG] ===============");

        marker, ioerr = get_marker(engine.stream);
        for marker != EOI {
            switch marker.y {
                case APP0.y: read_app0(&jpeg, engine);
                case DQT.y:  read_dqt(&jpeg, engine);
                case SOF0.y: read_sof0(&jpeg, engine);
                case DHT.y:  read_dht(&jpeg, engine);
                case SOS.y:  read_sos(&jpeg, engine);

                /* ignoring */
                case 0xE0..=0xEF, COM.y: // ignore other APP(s) and comments
                    length: u16be;
                    l, err := io.read_ptr(engine.stream, &length, size_of(length));
                    assert(l == size_of(length) && err == .None);
                    skip_len := cast(i64)(length - 2);
                    fmt.eprintfln("Ignoring marker 0xFF%02X (skipping %d bytes)", marker.y, skip_len);
                    io.seek(engine.stream, skip_len, .Current);

                case: unreachable();
            }

            marker, ioerr = get_marker(engine.stream);
            assert(ioerr == .None);
        }

        decompress(engine, &jpeg);
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

@(private="file")
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
        fmt.eprintfln("\tversion_major: %d", jpeg.app0.version_major);
        fmt.eprintfln("\tversion_minor: %d", jpeg.app0.version_minor);
        fmt.eprintfln("\tdensity_units: %d", jpeg.app0.density_units);
        fmt.eprintfln("\tx_density: %d", cast(u16le)jpeg.app0.x_density);
        fmt.eprintfln("\ty_density: %d", cast(u16le)jpeg.app0.y_density);
        fmt.eprintfln("\tthumbnail_width: %d", jpeg.app0.thumbnail_width);
        fmt.eprintfln("\tthumbnail_height: %d", jpeg.app0.thumbnail_height);
    }
}

@(private="file")
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

@(private="file")
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
        assert(jpeg.sof0.components[i].sampling == 0x11, "Invalid subsamling value! Expected 0x11 (Note: we support only 4:4:4 subsampling)");
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

@(private="file")
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
        construct_dht_graph(dht_graph, dht, allocator);

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

@(private="file")
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
    begin_pos, e := io.seek(stream, 3, .Current);
    fmt.eprintfln("Begin pos: %v", begin_pos);
    assert(e == .None);

    // read SOS compressed data
    marker: [2]byte;
    jpeg.compressed_data, merr = mem.make([dynamic]byte, allocator);
    assert(merr == .None);
    for {
        _, err = io.read(stream, marker[:]);
        if err == .EOF do break;
        // TODO(GowardSilk): This is not particularly good method of parsing the compressed data since
        // SOS does not have to be the last chunk!
        if marker == EOI {
            break;
        }

        append(&jpeg.compressed_data, marker.x, marker.y);
    }

    fmt.eprintfln("Lenof file: %v", io.size(stream));

    fmt.eprintfln("Lenof compressed_data: %v", len(jpeg.compressed_data));

    end_pos: i64;
    end_pos, e = io.seek(stream, -2, .Current);
    fmt.eprintfln("End pos: %v", end_pos);
    assert(e == .None);
    when ODIN_DEBUG do fmt.eprintln("\tCompressed data loaded!");
}

@(private="file")
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

@(private="file")
MAT_ORDER :: [8][8]int {
    {  0,  1,  5,  6, 14, 15, 27, 28 },
    {  2,  4,  7, 13, 16, 26, 29, 42 },
    {  3,  8, 12, 17, 25, 30, 41, 43 },
    {  9, 11, 18, 24, 31, 40, 44, 53 },
    { 10, 19, 23, 32, 39, 45, 52, 54 },
    { 20, 22, 33, 38, 46, 51, 55, 60 },
    { 21, 34, 37, 47, 50, 56, 59, 61 },
    { 35, 36, 48, 49, 57, 58, 62, 63 }
};

HT_NO_SYMBOL :: byte(0);

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

DHT_Graph :: struct {
    root: ^DHT_Graph_Node,
}

make_dht_graph :: #force_inline proc(dht: DHT_Chunk, allocator: mem.Allocator) -> (graph: DHT_Graph) {
    graph.root = make_dht_node(nil, allocator);
    make_dht_left_node(graph.root, allocator);
    make_dht_right_node(graph.root, allocator);
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
    parent^.right = node;
}

delete_dht_node :: mem.free;

construct_dht_graph :: proc(graph: DHT_Graph, dht: DHT_Chunk, allocator: mem.Allocator) {
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

query_in_dht_graph :: proc(graph: DHT_Graph, code: i16, code_len: byte) -> (symbol: DHT_Graph_Node_Symbol, eob: bool) {
    current := graph.root;

    for index: byte = 0; current != nil && index < code_len; index += 1 {
        if (code >> (code_len - index - 1) & 0x01) == 0 do current = current^.left;
        else if (code >> (code_len - index - 1) & 0x01) == 1 do current = current^.right;
        else do unreachable();

        if current != nil && current^.is_leaf {
            // EOB ([E]nd [O]f [B]lock is when 0 is present in the match from huffman table)
            if current^.symbol == HT_NO_SYMBOL do return HT_NO_SYMBOL, true;
            return current^.symbol, false;
        }

    }

    return HT_NO_SYMBOL, false;
}

RLE_Data :: struct {
    data: [dynamic]int,
}

@(private="file")
construct_pixel_bytes :: proc(jpeg: ^JPEG, rle: [3]RLE_Data) -> [64 * 4]byte {
    yuv_pixels: [3][64]int;
    zzorder: [64]int;

    zzindex_to_matindex :: #force_inline proc(zzindex: int) -> [2]int {
        return ZIGZAG_ORDER[zzindex];
    }

    @(static)
    dc_diff: [3]int;

    for rle_id in 0..<3 {
        curr_rle := rle[rle_id];
        zzskip_pos := -1;

        for i := 0; i <= len(curr_rle.data) - 2; i += 2 {
            nof_zeroes := curr_rle.data[i];
            suc_symbol := curr_rle.data[i + 1]; // number succeeding 0s

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
            zzorder[i] *= cast(int)qt.table_data[i];

            yuv_pos := zzindex_to_matindex(i);
            yuv_pixels[rle_id][yuv_pos.y * 8 + yuv_pos.x] = zzorder[i];
        }
    }

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

                        y := cast(f64)y;
                        x := cast(f64)x;
                        sum += Cu * Cv * cast(f64)yuv_pixels[i][u * 8 + v] * math.cos_f64((2 * x + 1) * cast(f64)u * math.PI / 16.0) *
                                        math.cos_f64((2 * y + 1) * cast(f64)v * math.PI / 16.0);
                    }
                }

                icdt[i][y * 8 + x] = sum;
            }
        }
    }

    // Level shift

    for i in 0..<3 {
        for y in 0..<8 {
            for x in 0..<8 {
                yuv_pixels[i][y * 8 + x] = cast(int)math.round(icdt[i][y * 8 + x]) + 128;
            }
        }
    }

    // YCbCr to RGB(A)

    out: [64 * 4]byte;
    for y in 0..<8 {
        for x in 0..<8 {
            Y  := cast(f64)yuv_pixels[0][y * 8 + x];
            Cb := cast(f64)yuv_pixels[1][y * 8 + x];
            Cr := cast(f64)yuv_pixels[2][y * 8 + x];

            R := cast(int)math.floor(Y + 1.402 * (1.0 * Cr - 128.0));
            G := cast(int)math.floor(Y - 0.344136 * (1.0 * Cb - 128.0) - 0.714136 * (1.0 * Cr - 128.0));
            B := cast(int)math.floor(Y + 1.772 * (1.0 * Cb - 128.0));

            R = math.max(0, math.min(R, 255));
            G = math.max(0, math.min(G, 255));
            B = math.max(0, math.min(B, 255));

            out[y * 8 + x * 4 + 0] = cast(byte)R;
            out[y * 8 + x * 4 + 1] = cast(byte)G;
            out[y * 8 + x * 4 + 2] = cast(byte)B;
            out[y * 8 + x * 4 + 3] = 255;
        }
    }

    return out;
}

Bit_Stream :: struct {
    buffer: []byte,
    index:  uint, /**< index of the current byte taken, if offset==8, the next byte will be loaded and this index incremented */
    offset: byte, /**< nof bits pushed from buffer[index] into curr */
    len:    byte, /**< nof bits pushed into curr - valid in range <0; size_of(u16)*8> */
    curr:   i16,
}

init_bitstream :: #force_inline proc(backing: []byte, init_bit_pos: uint) -> (bs: Bit_Stream) {
    bs.buffer = backing;
    bs.index  = init_bit_pos / 8;
    bs.offset = cast(byte)(init_bit_pos % 8);
    _ = bitstream_next(&bs);
    return bs;
}

_bitstream_next_helper :: #force_inline proc(using bs: ^Bit_Stream) -> i16 {
    return cast(i16)(((buffer[index] << offset) & ~byte(0x7F)) >> 7);
}

bitstream_next :: proc(using bs: ^Bit_Stream) -> i16 {
    next_bit := _bitstream_next_helper(bs);
    curr = curr << 1 | next_bit;
    bitstream_incr(bs);
    return curr;
}

bitstream_incr :: proc(using bs: ^Bit_Stream) {
    offset += 1;
    if offset >= 8 {
        index += 1;
        offset = 0;
        fmt.assertf(index < builtin.len(buffer), "Current code: %v/0b%b", curr, curr);
    }
    len += 1;
    len %= 16;
}

@(private="file")
construct_rle :: proc(jpeg: ^JPEG, allocator: mem.Allocator) -> [3]RLE_Data {
    rle_s: [3]RLE_Data;
    for &rle in rle_s {
        merr: mem.Allocator_Error;
        rle.data, merr = mem.make([dynamic]int, allocator);
        assert(merr == .None);
    }

    @(static)
    k: uint = 0; // static position of last read from JPEG.compressed_data (IN BITS!!)

    find_ht :: proc(jpeg: ^JPEG, selector_id: byte) -> (dc: DHT_Chunk_Table_Info, ac: DHT_Chunk_Table_Info) {
        for sos in jpeg.sos.components {
            if sos.id == selector_id {
                return cast(DHT_Chunk_Table_Info)sos.huff_tables & 0xF0, cast(DHT_Chunk_Table_Info)sos.huff_tables & 0x0F;
            }
        }

        unreachable();
    }

    for rle_id in 0..<3 {
        curr_rle := &rle_s[rle_id];

        bs := init_bitstream(jpeg^.compressed_data[:], k);
        // scan DC
        // NOTE(GowardSilk): SOF0 components should be three (0=Y, 1=Cb, 2=Cr)
        // and we are mapping these accordingly with sof0 id
        // TODO(GowardSilk): We should perhaps make enum array for these to signify
        // properly their purpose
        dc_ht_id, ac_ht_id := find_ht(jpeg, jpeg.sof0.components[rle_id].id);
        dc_ht  := jpeg.dhts[dc_ht_id];
        for {
            val, eob := query_in_dht_graph(dc_ht, bs.curr, bs.len);
            if eob {
                append(&curr_rle.data, 0, 0);
                break;
            } else if val != HT_NO_SYMBOL {
                nof_zeroes := cast(int)(val >> 4);
                category := cast(uint)(val & 0x0F);

                //Bit_Stream{buffer = [253, 83, 160, 2, 128, 10, 0, 40, 3, 255, 217, 255], index = 0, offset = 7, len = 7, curr = 126}
                //Bit_Stream{buffer = [253, 83, 160, 2, 128, 10, 0, 40, 3, 255, 217, 255], index = 2, offset = 0, len = 0, curr = 339}
                fmt.eprintfln("%v", bs);
                bs.curr = 0;
                for _ in 0..<category do _ = bitstream_next(&bs);
                fmt.eprintfln("%v", bs);
                append(&curr_rle.data, nof_zeroes, cast(int)bs.curr);
                fmt.eprintfln("Nofzeroes: %v; Curr: %v", nof_zeroes, bs.curr);
                fmt.eprintfln("%v", bs);
                break;
            }

            _ = bitstream_next(&bs);
        }

        bs.curr = 0;
        bs.len  = 0;

        // scan AC
        nof_codes := 0;
        ac_ht  := jpeg.dhts[ac_ht_id];
        for nof_codes < 64 {
            val, eob := query_in_dht_graph(ac_ht, bitstream_next(&bs), bs.len);
            if eob {
                append(&curr_rle.data, 0, 0);
                break;
            } else if val != HT_NO_SYMBOL {
                nof_zeroes := cast(int)(val >> 4);
                category := cast(uint)(val & 0x0F);

                bs.curr = 0;
                for _ in 0..<category do _ = bitstream_next(&bs);
                append(&curr_rle.data, nof_zeroes, cast(int)bs.curr);
                bs.len = 0;
                nof_codes += 1;
                continue;
            }
        }

        if len(curr_rle.data) == 2 {
            for datum in curr_rle.data {
                if datum != 0 {
                    pop(&curr_rle.data);
                    pop(&curr_rle.data);
                    break;
                }
            }
        }

        k = bs.index * 8 + cast(uint)bs.offset;
    }

    fmt.eprintfln("RLE: %v", rle_s);
    return rle_s;
}

@(private="file")
deconstruct_rle :: proc(rle: [3]RLE_Data) {
    for r in rle do mem.delete(r.data);
}

@(private="file")
decompress :: proc(engine: ^Engine, jpeg: ^JPEG) {
    dst       := engine.back; // assumed to be already locked
    dst_width := engine.meta.width;

    width  := jpeg_padded_size(jpeg^.sof0.width);
    height := jpeg_padded_size(jpeg^.sof0.height);
    assert(width <= engine.meta.width);
    assert(height <= engine.meta.height);

    mcu_index := 0;
    for y := 0; y < height - 8; y += 8 {
        dst_buffer := &dst.buffer[y * engine.meta.width];
        for x := 0; x < width - 8; x += 8 {
            rle   := construct_rle(jpeg, engine.allocator);
            defer deconstruct_rle(rle);

            bytes := construct_pixel_bytes(jpeg, rle);
            for v in 0..<8 {
                mcu_byte_width :: size_of(byte) * 8 * 4; // 4 == engine.meta.bytes_per_pixel
                mem.copy(dst_buffer, &bytes[v * mcu_byte_width], mcu_byte_width);
                dst_buffer = mem.ptr_offset(dst_buffer, engine.meta.width * 4); // offset the dst_buffer by one row
            }
            dst_buffer = &dst.buffer[y * engine.meta.width * 4 + x * 4];
        }
    }
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
