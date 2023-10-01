shader_type canvas_item;

uniform vec4 top_color = vec4(0, 0, 0, 1);
uniform vec4 bottom_color = vec4(0, 0, 0, 1);

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	
	float ratio = SCREEN_UV.y;
	float iratio = 1.0 - SCREEN_UV.y;
	
	float new_r = bottom_color.r * ratio + top_color.r * iratio;
	float new_g = bottom_color.g * ratio + top_color.g * iratio;
	float new_b = bottom_color.b * ratio + top_color.b * iratio;
	
	COLOR = vec4(new_r, new_g, new_b, current_color.a);
}
