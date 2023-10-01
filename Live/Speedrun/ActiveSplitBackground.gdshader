shader_type canvas_item;

void fragment() {
	// Interpolate colors based on the vertical position
	vec4 color_top = vec4(0.2, 0.45, 0.95, 1.0); // Top color (red)
	vec4 color_bottom = vec4(0.08, 0.2, 1.45, 1.0); // Bottom color (blue)
	COLOR = mix(color_top, color_bottom, UV.y);
}
