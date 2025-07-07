shader_type canvas_item;

uniform float ripple_radius = 0.0;
uniform float ripple_strength = 0.03;
uniform float ripple_thickness = 0.1;
uniform vec2 center_uv = vec2(0.5, 0.5);
uniform float alpha = 0.4; // this controls how much "black" tint is applied
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest_mipmap;
uniform vec4 tint_color: source_color = vec4(0.0, 0.0, 0.0, 1.0); // New uniform for tint color

void fragment() {
    vec2 dir = UV - center_uv;
    float dist = length(dir);

    // Ripple effect mask
    float ripple_edge = smoothstep(ripple_radius - ripple_thickness, ripple_radius, dist);
    float ripple_wave = sin((dist - ripple_radius) * 40.0) * (1.0 - ripple_edge);

    // Offset UV for screen distortion
    vec2 offset = normalize(dir) * ripple_wave * ripple_strength;
    vec4 screen_color = texture(SCREEN_TEXTURE, UV + offset);

    // Apply black tint using alpha amount
    vec4 tint = vec4(tint_color.rgb, alpha);
    screen_color = mix(screen_color, tint, tint.a);

    COLOR = screen_color;
}
