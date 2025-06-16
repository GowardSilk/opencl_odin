#version 420 core

layout(location = 0) in vec2 uv;
layout(binding = 0) uniform sampler2D u_texture;

layout(location = 0) out vec4 frag_color;

void main() {
    vec4 color = texture(u_texture, uv);
    if (dot(color.rbg, vec3(1.0, 1.0, 1.0)) <= 0.1) {
        discard;
    } else {
        frag_color = color;
    }
}