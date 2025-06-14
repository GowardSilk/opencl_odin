#version 330 core

out vec2 uv;

in vec2 in_uv;
layout(location = 0) in vec2 pos;

void main() {
    gl_Position = vec4(pos, 0.0, 1.0);
    uv = in_uv;
}