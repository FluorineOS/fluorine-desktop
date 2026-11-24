#version 300 es
// FluorineOS mono display shader.
//
// A pure grayscale focus mode. Rec. 709 luminance weights keep text legible and
// preserve relative contrast, so the lime accent reads as a light gray rather
// than disappearing. Alpha is untouched.
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

    float luma = dot(pix.rgb, vec3(0.2126, 0.7152, 0.0722));
    fragColor = vec4(vec3(luma), pix.a);
}
