package playground;

import "core:fmt"
import "core:thread"

thread_worker_proc :: proc(t: ^thread.Thread) {
	fmt.eprintln("Halooo");
}

main :: proc() {
	t1 := thread.create(thread_worker_proc);
	t2 := thread.create(thread_worker_proc);

	thread.start(t1);
	thread.start(t2);

	thread.join_multiple(t1, t2);

	thread.destroy(t1);
	thread.destroy(t2);
}
