shader_type canvas_item;

uniform bool BLUR = true;
uniform bool CRT  = true;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D crt_texture: hint_default_black, repeat_enable, filter_linear_mipmap;
uniform vec2 crt_blur = vec2(5.0, 3.0);
uniform vec2 crt_resolution = vec2(320.0,240.0);
uniform float crt_curve = 0.02;

void fragment(){
	
	vec2 crt_curve_shift = (1.0 - sin(UV.yx * PI)) * crt_curve;
	vec2 crt_curve_scale = 1.0 + crt_curve_shift * 2.0;
	vec2 screen_uv = SCREEN_UV * crt_curve_scale - crt_curve_shift;
	vec2 uv = UV * crt_curve_scale - crt_curve_shift;
	
	vec3 color = texture(screen_texture, screen_uv).rgb;
	
	if (BLUR) {
		vec2 offset1 = SCREEN_PIXEL_SIZE * crt_blur;
		vec2 offset2 = offset1 * vec2(1.0, -1.0);
		color *= 4.0;
		color += texture(screen_texture, screen_uv + offset1).rgb;
		color += texture(screen_texture, screen_uv - offset1).rgb;
		color += texture(screen_texture, screen_uv + offset2).rgb;
		color += texture(screen_texture, screen_uv - offset2).rgb;
		color /= 8.0;
	}
	
	if (CRT) {
		vec3 crt_color = texture(crt_texture, uv * crt_resolution).rgb + 0.4;
		color *= crt_color;
	}
	
	if (0. <= screen_uv.x && screen_uv.x <= 1. && 0. <= screen_uv.y && screen_uv.y <= 1.) {
		COLOR = vec4(color, 1.0);
	} else {
		COLOR = vec4(0.,0.,0.,1.);
	}
}
