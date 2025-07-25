package ui;

import "base:runtime"

import "core:image"

Error :: enum byte {
    None = 0,
    Shader_Compile,
    Shader_Program_Link,
    Angel_Read,
    Window_Creation,
}

General_Error :: union #shared_nil {
    Error,
    runtime.Allocator_Error,
    image.Error,
}
