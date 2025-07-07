shader_type canvas_item;
// Blink parameters
uniform bool blinking = false;
uniform vec4 blink_color: source_color;
uniform float blink_intensity = 0;
// Color manipulation parameters
uniform vec4 OLDCOLOR1 : source_color;
uniform vec4 OLDCOLOR2 : source_color;
uniform vec4 OLDCOLOR3 : source_color;
uniform vec4 OLDCOLOR4 : source_color;

uniform vec4 NEWCOLOR1 : source_color;
uniform vec4 NEWCOLOR2 : source_color;
uniform vec4 NEWCOLOR3 : source_color;
uniform vec4 NEWCOLOR4 : source_color;

void fragment() {
    if (blinking) {
        // Blink code
        vec4 color = texture(TEXTURE, UV);
        color = mix(color, blink_color, blink_intensity) * color.a;

        COLOR = color;
    }
    else {
        // Color manip code
        vec4 cur_color = texture(TEXTURE, UV);

        if (distance(cur_color, OLDCOLOR1) < 0.01){
            COLOR = NEWCOLOR1;
        }
        else if (distance(cur_color, OLDCOLOR2) < 0.01){
            COLOR = NEWCOLOR2;
        }
        else if (distance(cur_color, OLDCOLOR3) < 0.01){
            COLOR = NEWCOLOR3;
        }
        else if (distance(cur_color, OLDCOLOR4) < 0.01){
            COLOR = NEWCOLOR4;
        }
        else{
            COLOR = cur_color;
        }
    }
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
