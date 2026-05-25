shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;

uniform float cell_size = 1.0;
uniform float line_width_world = 0.03;
uniform vec4 grid_color = vec4(0.0, 0.0, 0, 0.6);

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float line_width = clamp(line_width_world / cell_size, 0.0001, 0.49);

	vec2 grid_position = world_position.xz / cell_size;
	vec2 grid_fraction = fract(grid_position);

	bool is_x_line = grid_fraction.x < line_width || grid_fraction.x > 1.0 - line_width;
	bool is_z_line = grid_fraction.y < line_width || grid_fraction.y > 1.0 - line_width;

	if (is_x_line || is_z_line) {
		ALBEDO = grid_color.rgb;
		ALPHA = grid_color.a;
	} else {
		ALPHA = 0.0;
	}
}


//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
