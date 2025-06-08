# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added
- Parsing support for OpenCL headers (`cl_platform.h`).
- Initial implementation of parsing functions, including support for functions as parameters.
- Added new files to the project:
  - `CL/d3d10.h`
  - `CL/defs.odin.c`
  - `opencl`

### Changed
- Updated `main.odin` to support parsing integration of the generated opencl library.
- Enhanced `main.py` and `parsegen.py`:
  - Improved parsing logic for header files.
  - Added support for structured type extraction and preprocessing.

### Fixed
- Removed redundant and compiler-specific conditions to improve cross-platform compatibility.

### Initial Commits
- Project initialized with base structure.
- Added README with project overview.
- Began parsing basic headers (`cl_platform.h`).
