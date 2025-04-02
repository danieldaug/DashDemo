shader_type canvas_item;

uniform vec4 color : source_color;
uniform sampler2D fast_noise : repeat_enable;
uniform sampler2D screen_content : hint_screen_texture;

uniform vec2 speed = vec2(0.03, 0.07);
uniform float wave_strength = 2.0;
uniform float noise_scale = 0.002;   // Controls how much camera movement affects noise
uniform vec2 camera_position = vec2(0.0, 0.0);  // Camera's global position

void fragment() {
    // Offset UV by camera movement to create the parallax effect
    vec2 uv = UV + speed * TIME + (camera_position * noise_scale * vec2(0.5, 1));

    // Apply noise texture
    vec2 noise = texture(fast_noise, uv).rg * vec2(0.15, 0.15);

    // Apply color and noise effects
    COLOR = vec4(color.rgb, 1) + vec4(noise.x, noise.y, 0.25, 1);

    // Apply screen distortion effect
    vec2 distorted_uv = SCREEN_UV + noise * (wave_strength / 100.0);
    COLOR *= texture(screen_content, distorted_uv);
}
