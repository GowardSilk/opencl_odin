package ka;

import "core:mem"
import "core:fmt"

DEFAULT_BLOCK_SIZE :: 65_536; // 64KiB
Compiler_Allocator_Block :: struct {
	data: []byte,
	used: int,
}

Compiler_Allocator :: struct {
	blocks: [dynamic]Compiler_Allocator_Block,
	last:   ^Compiler_Allocator_Block,
	backing: mem.Allocator,
}

compiler_allocator_proc :: proc(allocator_data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, location := #caller_location) -> (m: []u8, err: mem.Allocator_Error) {
	ca := cast(^Compiler_Allocator)allocator_data;

	aligned :: #force_inline proc(x, alignment: int) -> int {
		return (x + (alignment - 1)) & ~(alignment - 1);
	}
	alloc_new_block :: #force_inline proc(ca: ^Compiler_Allocator, size: int) -> mem.Allocator_Error {
		block: Compiler_Allocator_Block;
		block.data = mem.make([]byte, size * 100, ca.backing) or_return;
		append(&ca.blocks, block);
		ca.last = &ca.blocks[len(ca.blocks)-1];
		return .None;
	}

	switch mode {
		case .Alloc:
			when ODIN_DEBUG do assert(ca.last != nil);
			byte_size: int;
			if ca.last.used >= len(ca.last.data) {
				alloc_new_block(ca, size) or_return;
			} else {
				// pad the pos of the last element to the current alignment
				// NOTE(GowardSilk): This is essential since we are not using multiple "buddies"
				// each for the appropriate alignment values (I'm lazy)
				data_used_addr := cast(int)cast(uintptr)&ca.last.data[ca.last.used];
				ca.last.used += aligned(data_used_addr, alignment) - data_used_addr;

				byte_size = aligned(size, alignment);
				// check if allocation does not exceed current buffer size
				if ca.last.used + byte_size >= len(ca.last.data) {
					alloc_new_block(ca, size) or_return;
				}
			}
			m = ca.last.data[ca.last.used:ca.last.used + byte_size];
			ca.last.used += byte_size;
			return m, .None;
		case .Free:
			return nil, .None;
		case .Alloc_Non_Zeroed:
			return compiler_allocator_proc(allocator_data, .Alloc, size, alignment, old_memory, old_size, location);
		case .Free_All:
			for block in ca.blocks {
				mem.delete_slice(block.data, ca.backing);
			}
			mem.delete(ca.blocks);
			return nil, .None;
		case .Query_Features:
			set := cast(^mem.Allocator_Mode_Set)old_memory;
			if set != nil {
				set^ = {.Alloc, .Free_All, .Query_Features};
			}
			return nil, nil;

		case .Query_Info:
			return nil, .Mode_Not_Implemented;
		case .Resize:
			return nil, .Mode_Not_Implemented;
		case .Resize_Non_Zeroed:
			return nil, .Mode_Not_Implemented;
	}
	unreachable();
}

compiler_allocator_init :: proc(allocator: ^Compiler_Allocator, backing: mem.Allocator) -> mem.Allocator_Error {
	allocator.backing = backing;

	block: Compiler_Allocator_Block;
	block.data = mem.make([]byte, DEFAULT_BLOCK_SIZE, backing) or_return;
	append(&allocator.blocks, block);
	allocator.last = &allocator.blocks[0];

	return nil;
}

compiler_allocator_destroy :: #force_inline proc(allocator: ^Compiler_Allocator) {
	compiler_allocator_proc(allocator, .Free_All, 0, 0, nil, 0);
}

compiler_allocator :: proc(allocator: ^Compiler_Allocator) -> mem.Allocator {
	return mem.Allocator {
		compiler_allocator_proc, allocator,
	};
}

