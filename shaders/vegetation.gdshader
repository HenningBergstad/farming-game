shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo_texture : source_color, filter_nearest;
uniform vec3 color_tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float alpha_scissor_thershold : hint_range(0.0, 1.0) = 0.5;
uniform vec3 backlight_color : source_color = vec3(0.2, 0.5, 0.1);
uniform float backlight_strength: hint_range(0.0, 1.0) = 0.4;
uniform vec2 wind_direction = vec2(1.0, 0.0);
uniform float wind_strength : hint_range(0.0, 1.0) = 0.2;
uniform float sway_speed : hint_range(0.1, 5.0) = 1.0;

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float height_factor = max(world_pos.y, 0.0) * (max(world_pos.y, 0.0) / 2.0);
    float sway = sin(TIME * sway_speed + world_pos.x * 0.5 + world_pos.z * 0.5);
    
    vec3 world_displacement = vec3(
        wind_direction.x * sway * height_factor * (wind_strength / 5.0),
        0.0,
        wind_direction.y * sway * height_factor * (wind_strength / 5.0)
    );
    
    VERTEX += (inverse(MODEL_MATRIX) * vec4(world_displacement, 0.0)).xyz;
}


void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb * color_tint;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_thershold;
	BACKLIGHT = backlight_color * backlight_strength;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
