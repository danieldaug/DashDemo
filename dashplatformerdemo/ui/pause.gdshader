shader_type canvas_item;

uniform sampler2D noise_texture : source_color;
uniform float distortion_strength : hint_range(0.0, 50.0) = 10.0;
uniform float blur_strength : hint_range(0.0, 5.0) = 1.0;
uniform vec2 viewport_size;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Get UV
    vec2 uv = SCREEN_UV;

    // Sample distortion from noise texture
    vec2 noise = texture(noise_texture, UV).rg - 0.5;
    uv += noise * distortion_strength / viewport_size;

    // Calculate blur offset based on blur_strength
    vec2 blur_offset = blur_strength / viewport_size;

    // Fake blur: sample neighboring pixels scaled by blur_strength
    vec4 col = texture(SCREEN_TEXTURE, uv) * 0.36;
    col += texture(SCREEN_TEXTURE, uv + vec2(blur_offset.x, 0.0)) * 0.16;
    col += texture(SCREEN_TEXTURE, uv - vec2(blur_offset.x, 0.0)) * 0.16;
    col += texture(SCREEN_TEXTURE, uv + vec2(0.0, blur_offset.y)) * 0.16;
    col += texture(SCREEN_TEXTURE, uv - vec2(0.0, blur_offset.y)) * 0.16;

    // Output final color
    COLOR = col;
}
