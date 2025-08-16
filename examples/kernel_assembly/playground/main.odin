package playground;

import "../emulator"

import "core:fmt"

Emulator_Wrapper :: struct #raw_union {
	null: emulator.Null_CL,
	full: emulator.Full_CL,
}

S :: struct {
	emulator: Emulator_Wrapper,
}

main :: proc() {
	s: S = {
		emulator = {
			full = emulator.init_full(),
		},
	};

	e_base_ptr: ^emulator.Emulator = &s.emulator.full.base;
	fmt.eprintfln("%v", e_base_ptr.kind);
}
