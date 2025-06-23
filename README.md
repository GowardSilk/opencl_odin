# OpenCL Bindings for Odin

This project provides OpenCL bindings for the Odin programming language, generated automatically from the official OpenCL C headers using the `CL/parsegen.py` utility. The bindings are designed to be as complete and idiomatic as possible, supporting both basic OpenCL usage and integration with D3D10/D3D11 for interoperability.

## parsegen Utility

The `CL/parsegen.py` script parses OpenCL (and optionally D3D/DirectX) C headers and generates corresponding Odin bindings. It supports various options:

### Usage

```powershell
# Basic usage (generates Odin bindings from OpenCL headers)
python CL/main.py --parsegen --out="opencl"

# Additional options:
#   --cc=<compiler>         # Specify C compiler (clang/gcc/cl). Only clang is supported currently.
#   --verbose               # Enable debug messages
#   --suppress-warnings     # Disable warning messages
#   --only-essential        # Only generate essential OpenCL headers (no D3D interop)
```

The generated `.odin` files will appear in the specified output directory (e.g., `opencl/`).

## Examples

The `examples/` directory contains several Odin projects demonstrating usage of the generated OpenCL bindings:

### 1. Basic Example
- **Path:** `examples/basic/`
- **Description:** Minimal OpenCL usage, including device/platform selection and running a simple kernel (`test_program.cl`).
- **Run with:**
  ```powershell
  cd examples
  odin run basic -collection=shared:<path_to_directory_containing_opencl_bindings>
  ```
  Replace `<path_to_directory_containing_opencl_bindings>` with the path to your generated `opencl` directory.

### 2. Video Example
- **Path:** `examples/video/`
- **Description:** Advanced OpenCL usage for image processing, with a custom UI (OpenGL/GLFW) for displaying images and running compute kernels (e.g., Gaussian blur, Sobel filter). The UI is modular and will be extended to support D3D10/D3D11 for better OpenCL compatibility.
- **Run with:**
  ```powershell
  cd examples
  odin run video -collection=shared:<path_to_directory_containing_opencl_bindings>
  ```

### 3. Audio Example
- **Path:** `examples/audio/`
- **Description:** Demonstrates audio playback using miniaudio (not OpenCL-specific, but included for completeness).
- **Run with:**
  ```powershell
  cd examples
  odin run audio
  ```

## Known Issues / Limitations

- The `parsegen` utility may not handle some complex C macro expressions perfectly. For example:
  - Numeric constants with casts (e.g., `LONG_MIN`, `LONG_MAX`) may require manual fixing after regeneration.
  - Some D3D-related macros with numerical suffixes may not be parsed correctly.
- Most issues are minor and can be fixed manually in the generated `.odin` files if needed.

## Roadmap

- **Video Example:**
  - The UI will be extended to be more generic, supporting D3D11/D3D10 as well as OpenGL for improved OpenCL compatibility and cross-API demos.
- **Audio Example:**
  - Will be enhanced to mimic some features of vkFFT, providing more advanced audio processing and analysis.
- **parsegen:**
  - Improved parsing for complex macro expressions and better support for edge cases in C headers.

---

For questions or contributions, please open an issue or pull request.
