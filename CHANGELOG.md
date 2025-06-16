# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### [UI cleanup]

#### Changed
- added `everything of UI matter` into separate submodule of `video` -> `ui`

### [Object rendering on overflow]

#### Changed
- `ui.odin` fixing objects not being rendered on a separate line when overflowing the screen; this has the unfortunate disatvantage (as of this commit) that we need to specify the img size beforehand; which is not technically a big problem since we can either move the Image loading into ui and then just accept the img object inside the ui_batch or just leave it as is since we will always know the sizes

### [Proper deletion out of Batch renderer]

#### Changed
- `ui_batch.odin` "batched" all Window non-shareable data into Batch_Renderer_PerWindow_Memory, that way we can eliminate a lot of local VAOs inits. In addition we now support SPIR-V which is directly loaded via `#load` as constant so we do not have to load and recompile shaders for each pipeline/window. With this in place, the deletion itself came as consequence of this design.
- `ui.odin` fixed OpenGL context not being set for a window that was marked for deletion (closure); that caused us to accidently delete the correct VAOs but at incorrect moment (aka wrong selected context)

### [Multiple screens fix]

#### Changed
- `ui_batch.odin` to support multiple screens, we had to additinally define multiple VAOs (per window), for that reason we added `batch_renderer_clone` function which copies the state and rebuilds shaders (not very effective but also marginally slow in the end)
- `image.odin` has to contain "core:image/png" which will automatically register PNG loader ?
- `ui.odin` to support active window indexing passes into batch renderer

### [Image rendering]

#### Added
- `*.png` test files

##### Changed
- `ui_batch.odin` now supports image rendering (font atlas is not done yet properly, seems that the offsetting is a bit... off); images are not batched nor indexed, though font atlas is for the convenience since we may render a lot of the same data over and over again (same characters)
- `ui.odin` fixing additional windows not being destroyed; for some reason OpenGL is complaining about data not being shared across windows (needs fixing!!)

#### Added
- `error.odin` for unified error handling (better than just `bool` returns)
- `img_*.glsl` separate shaders for image rendering

#### Changed
- `main.odin` to adhere `ui_*.odin` defs; also changed the idea behind image rendering by actively changing the file path of which image should be actually rendered (the inherent problem in this strategy is apparent in the fact if we are going to massively change the image buffer's data; I suggest we should create an Image View of some sort which will allow custom operations - defined in `image.odin` to be performed on the GPU data; CPU upload of this data could be one of them, if we plan on doing CPU-to-GPU comparisons)
- `ui.odin` adding per frame resetting of Batch renderer; eliminating illicit code of ui_draw_image
- `ui_fnt.odin` removing useless error returns
- `ui_fnt_test.odin` adding tracking allocator to the unit tests (TODO: THIS IS YET TO BE TESTED PROPERLY)
- `ui_batch.odin` attempting to add image rendering (and consequently font rendering); rendering textures cannot be batched (to some extent they can be, though not very friendly nor efficient), so we just try to defined a quad and OpenGL texture ID along with dirty bit flag which is being reset every frame and consequently (on the descending frame) is erased altogether if not "touched" (aka registered) again. This way we can internally manage image lifetimes (this deletions happens per frame, not per window, viz. batch_renderer_reset) without the pain of actually managing it externally.

#### Added
- `ui_batch.odin` now contains batch renderer (moved from `ui.odin`)
- `ui_fnt.odin` contains Angel font specification structures along with basic text reader
- `ui_fnt_test.odin` contains basic unit tests for Angel font reading

### [Angel font reading]

#### Added
- `ui_batch.odin` now contains batch renderer (moved from `ui.odin`)
- `ui_fnt.odin` contains Angel font specification structures along with basic text reader
- `ui_fnt_test.odin` contains basic unit tests for Angel font reading

#### Changed
- `ui.odin` removed batch renderer references to `ui_batch.odin`

### [Basic outline of image rendering]

#### Changed
- `image.odin` to support (or rather "alias" at this point) image loading; will be much proliferative in the future when we will have image manipulation functions
- `ui.odin` outlining basic image rendering; todo: maybe some fix for batching? we could use PBO and then waitsync on actual render

### [Fixing rendering]

#### Changed
- `ui.odin` fixing rendering bugs; now we can see the "Button"(s)!!
- `main.odin` adding proper check for window register

### [Extending batch rendering (pckg video)]

#### Added
- `pix.glsl` and `vert.glsl` as basic shaders; will do more when the full rendering is going to work

#### Changed
- `ui.odin` ... filling `Batch_Renderer` data, layout out basic structure for per-window batches (Missing Vertex Attributes initialization as well as some coloring for ui; also Text is not done at all)

### [Started creating new example (pckg video)]
#### Added
- `main.odin`
- `image.odin` .... <<future:>> should  contain image loading facilities that will be displayed in the ui (Draw_Image ?)
- `ui.odin` .... basic setup (much inspired by imgui); what is left to do is the batched rendering itself
- `video.odin` .... <<future:>> should contain video loading facilities that will be displayed in the ui (Draw_Video ?)

### [Formatting changes]

#### Added
- `fmt.py` for unified way to construct certain Odin statements/typedefs
- also supports `cl_` prefix deletion (and its derivations) in the following way:
  - `cl`XyZy -> XyZy (functions, though this may be subject to change with @(link_name="") if we decide to change the casing to something else)
  - `CL`X_Y_Z -> X_Y_Z (macros)
  - `cl`TyT -> Ty_T (types; todo: types need fixing, e.g. ID gets transformed into I_D... not very convenient)

#### Changed
- `main.py` adding `--only-essential` which compiles only necessary cl_*.h headers for minimal build
- `parsegen.py` adding support for Oding type construction from `fmt.py`; also fixed `try_apply_function_type` for unified parsing for typedef(s) as well as extern function(s)
  - also fixed unintentional double reads of data when parsing function on `extern` without re-applying the correct cursor
- `parse_types.py` to support `fmt` as well

### [Restructuring d3d parsing]

#### Changed
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
