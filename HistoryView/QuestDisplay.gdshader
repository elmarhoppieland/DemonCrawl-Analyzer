shader_type canvas_item;

uniform float border_left = 0.02;
uniform float border_top = 0.02;
uniform float border_right = 0.02;
uniform float border_bottom = 0.02;

void fragment() {
	COLOR = texture(TEXTURE, UV.xy);
	
	float original_alpha = COLOR.a;
	
	COLOR.a = 0.0;
	
	if (UV.x < border_left || UV.x > 1.0 - border_right || UV.y < border_bottom || UV.y > 1.0 - border_top) {
		COLOR.a = original_alpha;
	}
}
