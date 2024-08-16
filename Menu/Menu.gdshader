shader_type canvas_item;

uniform vec2 motion = vec2(0.0);
uniform float scale = 1.0;
uniform mat2 transform = mat2(1);

void vertex(){
	UV = (VERTEX * transform + TIME * motion) * TEXTURE_PIXEL_SIZE * (1.0/scale);
}