# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

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
