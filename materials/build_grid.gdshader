shader_type spatial;
render_mode unshaded, blend_mix;
uniform float grid_size = 50.0;
uniform float line_thickness = 0.03;


void vertex() {
	// Called for every vertex the material is visible on.
}

	
void fragment() {
	// Called for every pixel the material is visible on.
	vec2 grid_position = UV * grid_size;
	vec2 grid_fraction = fract(grid_position);
	
	bool is_x_line = grid_fraction.x < line_thickness || grid_fraction.x > 1.0 - line_thickness;
	bool is_y_line = grid_fraction.y < line_thickness || grid_fraction.y > 1.0 - line_thickness;
	
	if (is_x_line || is_y_line) {
	ALBEDO = vec3(0.0, 0.8, 1.0);
	ALPHA = 0.4;
	} else {
		ALPHA = 0.0;
	}

}


//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
