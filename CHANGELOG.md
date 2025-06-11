# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

## [Started creating new example (pckg video)]
## Added
- `main.odin`
- `image.odin` .... <<future:>> should  contain image loading facilities that will be displayed in the ui (Draw_Image ?)
- `ui.odin` .... basic setup (much inspired by imgui); what is left to do is the batched rendering itself
- `video.odin` .... <<future:>> should contain video loading facilities that will be displayed in the ui (Draw_Video ?)

## [Formatting changes]

## Added
- `fmt.py` for unified way to construct certain Odin statements/typedefs
- also supports `cl_` prefix deletion (and its derivations) in the following way:
  - `cl`XyZy -> XyZy (functions, though this may be subject to change with @(link_name="") if we decide to change the casing to something else)
  - `CL`X_Y_Z -> X_Y_Z (macros)
  - `cl`TyT -> Ty_T (types; todo: types need fixing, e.g. ID gets transformed into I_D... not very convenient)

### Changed
- `main.py` adding `--only-essential` which compiles only necessary cl_*.h headers for minimal build
- `parsegen.py` adding support for Oding type construction from `fmt.py`; also fixed `try_apply_function_type` for unified parsing for typedef(s) as well as extern function(s)
  - also fixed unintentional double reads of data when parsing function on `extern` without re-applying the correct cursor
- `parse_types.py` to support `fmt` as well

### [Restructuring d3d parsing]

### Changed
- making `--parsegen` option obligatory when needing to parse files (`main.py`)
- fixing parsing (and consequently C-Odin transpilation) of function pointers as struct members (viz. d3d10.h vtables for example) (`parsegen.py`)
- making `d3d10.h` and its related OpenCL headers win32 only in python script (`main.py`/`parsegen.py`)

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
