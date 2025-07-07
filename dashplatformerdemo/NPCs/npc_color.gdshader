shader_type canvas_item;
// Color manipulation parameters
uniform vec4 OLDCOLOR1 : source_color;
uniform vec4 OLDCOLOR2 : source_color;
uniform vec4 OLDCOLOR3 : source_color;
uniform vec4 OLDCOLOR4 : source_color;
uniform vec4 OLDCOLOR5 : source_color;
uniform vec4 OLDCOLOR6 : source_color;
uniform vec4 OLDCOLOR7 : source_color;
uniform vec4 OLDCOLOR8 : source_color;

uniform vec4 NEWCOLOR1 : source_color;
uniform vec4 NEWCOLOR2 : source_color;
uniform vec4 NEWCOLOR3 : source_color;
uniform vec4 NEWCOLOR4 : source_color;
uniform vec4 NEWCOLOR5 : source_color;
uniform vec4 NEWCOLOR6 : source_color;
uniform vec4 NEWCOLOR7 : source_color;
uniform vec4 NEWCOLOR8 : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

// Function to compare and optionally replace color
vec4 replace_color(vec4 color, vec4 old_color, vec4 new_color) {
    if (distance(color, old_color) < 0.01) {
        if (new_color.rgb != vec3(0.0)) {
            return new_color;
        }
    }
    return color;
}

void fragment() {
	// Color manip code
    vec4 cur_color = texture(TEXTURE, UV);

    // Sequential replacements
    cur_color = replace_color(cur_color, OLDCOLOR1, NEWCOLOR1);
    cur_color = replace_color(cur_color, OLDCOLOR2, NEWCOLOR2);
    cur_color = replace_color(cur_color, OLDCOLOR3, NEWCOLOR3);
    cur_color = replace_color(cur_color, OLDCOLOR4, NEWCOLOR4);
    cur_color = replace_color(cur_color, OLDCOLOR5, NEWCOLOR5);
    cur_color = replace_color(cur_color, OLDCOLOR6, NEWCOLOR6);
    cur_color = replace_color(cur_color, OLDCOLOR7, NEWCOLOR7);
    cur_color = replace_color(cur_color, OLDCOLOR8, NEWCOLOR8);

    COLOR = cur_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
