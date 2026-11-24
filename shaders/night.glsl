#version 300 es
// FluorineOS night display shader.
//
// A warm, low-blue-light pass for late coding sessions. Red is lifted slightly,
// green is held, and blue is pulled down so the AMOLED canvas keeps its
// contrast while the blue channel stops driving eye strain. Alpha is untouched,
// so window opacity and rounded corners are unaffected.
//
// The #version directive has to be the first statement in the shader, so it
// sits above this comment block; anything above it makes the ES profile reject
// the file.
//
// Loaded through Hyprland decoration:screen_shader by flr-shader.

precision mediump float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 pix = texture(tex, v_texcoord);

    pix.r = min(1.0, pix.r * 1.08);
    pix.g = pix.g * 0.99;
    pix.b = pix.b * 0.78;

    fragColor = pix;
}
