# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### [Extending parsing 1/2]

#### Changed
- added protection against different compilers; now we only support `clang` (`main.py`)
- added parsing of enums, anonymous pointers, and other typedef "exceptions" (`parsegen.py`)

### [Creating basic example directory]

#### Changed
- moved `main.odin` into `examples/basic/main.odin`
- moved `test_program.cl` into `examples/basic/test_program.cl`

### [Adding basic example]

#### Added
- `test_program.cl`; CL program for vector scaling (loaded by `main.odin`)

#### Changed
- Updated `main.odin` for exemplary opencl vector scale program

### [Adding macro support (partial)]

#### Changed
- Updated `parsegen.py` to support:
  - basic macros (`#define <name> <value>`)
  - removal of numerical suffixes (basic case works; does not work for complex cases like casting involvement or more robust arithmetic expression)
  - cast change from C-style cast to Odin `cast` operator

#### Fixed
- Fixing basic types not being displayed with `^` appropriate pointer type when not a `void*` (e.g. `cl_platform_id` instead of `^cl_platform_id` but `rawptr` when `void*`)

### [Parsegen output formatting]

#### Changed
- Added `--suppress-warnings` in `main.py` for disabling warning messages
- Updated `parsegen.py` to support better formatting in the output file such that the parsed data is ordered by files from which they came

### [Message logging]

#### Added
- Added new files to the project:
  - `CL/log.py`
  - `CL/parse_types.py`

#### Changed
- Added `--verbose` in `main.py` for setting DEBUG message logging
- Updated `parsegen.py` to support logging from `log.py`

### [First usable parser output (cl_platform.h, cl.h, cl_version.h)]

#### Added
- Parsing support for OpenCL headers (`cl_platform.h`).
- Initial implementation of parsing functions, including support for functions as parameters.
- Added new files to the project:
  - `CL/d3d10.h`
  - `CL/defs.odin.c`
  - `opencl`

#### Changed
- Updated `main.odin` to support parsing integration of the generated opencl library.
- Enhanced `main.py` and `parsegen.py`:
  - Improved parsing logic for header files.
  - Added support for structured type extraction and preprocessing.

#### Fixed
- Removed redundant and compiler-specific conditions to improve cross-platform compatibility.

### Initial Commits
- Project initialized with base structure.
- Added README with project overview.
- Began parsing basic headers (`cl_platform.h`).
