package emulator;

import "core:c"
import "core:fmt"
import "core:mem"
import "core:sync"
import "core:thread"

import cl "shared:opencl"

/** @brief designed for Task.user_data to pass essential params down to each thread */
Task_In :: struct {
	args:    []rawptr, /**< wrapper params */
	addr:    #type proc([]rawptr), /**< @(kernel) wrapper proc addr */
	groups:  []Work_Group, /**< used to get proper sync.Barrier into Kernel_Builtin_Context_Payload */
	payload: ^Kernel_Builtin_Context_Payload, /**< common payload, shared among Work_Item(s) */
}
/**
 * @brief stores necessary Emulator and NDRange data for @(kernel_builtin) procs to work properly
 */
Kernel_Builtin_Context_Payload :: struct {
	// readonly
	work_dim:         cl.Uint,
	_context:         ^Context_Null_Impl,
	global_work_size: [^]c.size_t,
	local_work_size:  [^]c.size_t,
	nof_calls:        c.size_t,
	nof_locals:       c.size_t,
	nof_iters:        c.size_t,
	//! readonly

	mutex: ^sync.Mutex,

	// these values are set inside _worker_proc dynamically for each Work_Item
	global_pos: [MAX_DIMS]c.size_t, /**< used for get_global_id(#) */
	local_pos:  [MAX_DIMS]c.size_t, /**< used for get_local_id(#) */
	barrier:    ^sync.Barrier,
}
NDRange :: struct {
	items:  []Work_Item, /**< pool of all threads */
	groups: []Work_Group, /**< partitions of `items' with common memory barrier */
}
Work_Group :: struct {
	barrier: sync.Barrier, /**< fence for all threads in one group (aka 'shared-memory barrier' in OpenCL terms) */
}
Work_Item :: struct {
	thread:       ^thread.Thread,
	sema:          sync.Sema, /**< used to signal work_item to wait/resume operation */
	group_signal: ^sync.Barrier, /**< barrier for non-terminating thread "join" after executing a task */
	task_in:      ^Task_In, /**< input parameter for kernel task */
}

/** @brief general thread task executing @(kernel) wrapper from Task_In */
worker_proc :: proc(t: ^thread.Thread) {
	for {
		wi := cast(^Work_Item)t.data;
		sync.sema_wait(&wi.sema); // wait until flagged to execute

		if wi.task_in == nil do break;

		payload := wi.task_in.payload;
		for i in 0..<payload.nof_iters {
			_worker_proc(t.id, wi.task_in);
		}
		sync.barrier_wait(wi.group_signal);
	}
	fmt.eprintfln("Terminating %v", t.id);
}

_worker_proc :: #force_inline proc(id: int, task_in: ^Task_In) {
	// update payload ids
	payload := task_in.payload;

	payload_context_local: Kernel_Builtin_Context_Payload;
	switch payload.work_dim {
		case 1:
			sync.lock(task_in.payload.mutex);
			payload_context_local = payload^;
			// NOTE(GowardSilk): we are incrementing the global pos for the next thread in line (otherwise we would not be starting from 0)
			payload.global_pos.x += 1;
			sync.unlock(task_in.payload.mutex);

			using payload_context_local;
			// calc local pos
			local_pos.x = global_pos.x % local_work_size[0];
			// pick shared memory barrier
			n := nof_locals * nof_iters;
			barrier = &task_in.groups[global_pos.x / n].barrier;
		case 2:
			sync.lock(task_in.payload.mutex);
			payload_context_local = payload^;
			payload.global_pos.x += 1;
			if payload.global_pos.x >= payload.global_work_size[0] {
				payload.global_pos.x = 0;
				payload.global_pos.y += 1;
			}
			sync.unlock(task_in.payload.mutex);

			using payload_context_local;
			// calc local pos
			local_pos.x = global_pos.x % local_work_size[0];
			local_pos.y = global_pos.y % local_work_size[1];
			// pick shared memory barrier
			global_linear_pos := global_pos.y * global_work_size[0] + global_pos.x;
			barrier = &task_in.groups[global_linear_pos / nof_locals].barrier;
		case 3:
			sync.lock(task_in.payload.mutex);
			payload_context_local = payload^;
			payload.global_pos.x += 1;
			if payload.global_pos.x >= payload.global_work_size[0] {
				payload.global_pos.x = 0;
				payload.global_pos.y += 1;
				if payload.global_pos.y >= payload.global_work_size[1] {
					payload.global_pos.y = 0;
					payload.global_pos.z += 1;
				}
			}
			sync.unlock(task_in.payload.mutex);

			using payload_context_local;
			// calc local pos
			local_pos.x = global_pos.x % local_work_size[0];
			local_pos.y = global_pos.y % local_work_size[1];
			local_pos.z = global_pos.z % local_work_size[2];
			// pick shared memory barrier
			global_linear_pos :=
				global_pos.z * global_work_size[1] +
				global_pos.y * global_work_size[0] +
				global_pos.x;
			barrier = &task_in.groups[global_linear_pos / nof_locals].barrier;

		case: unreachable();
	}

	// upload immutable payload copy
	// to the thread's context
	context.user_ptr = &payload_context_local;

	sync.lock(payload.mutex);
	fmt.eprintfln("id[%v]: %v", id, payload.global_pos.x - 1);
	sync.unlock(payload.mutex);

	task_in.addr(task_in.args);
}

ndrange_init :: proc(max_items: int) -> Maybe(NDRange) {
	ndrange: NDRange;
	merr: mem.Allocator_Error;
	ndrange.items, merr = mem.make([]Work_Item, max_items);
	if merr != .None do return nil;
	ndrange.groups, merr = mem.make([]Work_Group, max_items);
	if merr != .None do return nil;

	for index in 0..<max_items {
		ndrange.items[index].thread = thread.create(worker_proc);
		ndrange.items[index].thread.data = &ndrange.items[index]
		thread.start(ndrange.items[index].thread);
	}

	return ndrange;
}

ndrange_destroy :: proc(ndrange: ^NDRange) {
	if ndrange != nil && ndrange.items != nil {
		for &wi in ndrange.items {
			wi.task_in = nil;
			sync.sema_post(&wi.sema);
			thread.join(wi.thread);
			thread.destroy(wi.thread);
		}
		mem.delete(ndrange.items);

		if ndrange.groups != nil {
			mem.delete(ndrange.groups);
		}
	}
}

ndrange_exec_task :: proc(ndrange: ^NDRange, task_in: ^Task_In) {
	assert(task_in.payload.nof_locals <= cast(uint)ndrange_len(ndrange));
	// this wait should be only temporary: unless we optimize
	// to do syncing out of the EnqueueNDRange function

	task_in.groups = ndrange.groups[:task_in.payload.nof_locals];

	group_barrier: sync.Barrier;
	sync.barrier_init(&group_barrier, cast(int)task_in.payload.nof_locals + 1);

	for i in 0..<task_in.payload.nof_locals {
		wi := &ndrange.items[i];
		wi.task_in = task_in;
		wi.group_signal = &group_barrier;
		wi.thread.data = cast(rawptr)&ndrange.items[i];
		sync.sema_post(&wi.sema); // launch the worker
	}

	sync.barrier_wait(&group_barrier);
}

ndrange_groups :: #force_inline proc(ndrange: ^NDRange) -> []Work_Group {
	return ndrange.groups;
}

/** @return the number of available worker items */
ndrange_len :: #force_inline proc(ndrange: ^NDRange) -> int {
	return len(ndrange.items);
}
