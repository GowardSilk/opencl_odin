package ka;

import "core:mem"
import "core:fmt"

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator;
		mem.tracking_allocator_init(&track, context.allocator);
		allocator := context.allocator;
		context.allocator = mem.tracking_allocator(&track);
	}

	cl_context, merr := compile();
	assert(merr == .None);
	delete_cl_context(&cl_context);

	when ODIN_DEBUG {
		if len(track.allocation_map) <= 0 do fmt.println("\x1b[32mNo leaks\x1b[0m");
		else {
			for _, leak in track.allocation_map {
				fmt.printf("%v leaked %m\n", leak.location, leak.size)
			}
		}

		mem.tracking_allocator_destroy(&track);
		context.allocator = allocator;
	}
}
