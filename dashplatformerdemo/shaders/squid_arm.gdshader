shader_type canvas_item;
render_mode blend_mix;

uniform float fade_start;
uniform float fade_end;
uniform vec2 sprite_global_pos;
uniform float sprite_height_world = 320.0;

void vertex() {
    // Calculate global position of the vertex in world space
    // For 2D, global pos = sprite global pos + vertex offset in local space scaled by global transform
    // Simplify here: pass sprite_global_pos, add UV-based offset in fragment
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Calculate global Y of this fragment
    // Approximate by adding local offset based on UV.y * sprite height
    // But we need sprite height in world units; pass as uniform or compute from size

    // For simplicity, let's assume sprite height in world units is passed as uniform
    // For example:
    // uniform float sprite_height_world;

    // Then:
    float pixel_global_y = sprite_global_pos.y + UV.y * sprite_height_world;

    // Compute fade factor
    float fade_factor = 1.0;
    if (pixel_global_y > fade_start) {
        fade_factor = 1.0 - clamp((pixel_global_y - fade_start) / (fade_end - fade_start), 0.0, 1.0);
    }

    COLOR = vec4(tex_color.rgb, tex_color.a * fade_factor);
}
