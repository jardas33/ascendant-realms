shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, blend_mix, shadows_disabled;

// One texel per visibility cell. The red channel carries the raw cell state
// byte (0 unexplored, 1 explored, 2 visible); linear filtering plus a small
// tent blur turns the cell grid into a soft fog edge.
uniform sampler2D visibility_states : filter_linear, repeat_disable;
// Plain vec4 (no source_color) so the values match the previous vertex-colour
// overlay exactly.
uniform vec4 unexplored_color = vec4(0.025, 0.035, 0.045, 0.70);
uniform vec4 explored_color = vec4(0.050, 0.065, 0.075, 0.34);
uniform float blur_texels = 0.6;
// The overlay plane extends past the playable grid; fog is looked up by world
// position and clamps to the edge cells, so the shroud continues over the
// scenery instead of ending in a hard rectangle.
uniform vec2 grid_origin = vec2(-136.0, -136.0);
uniform vec2 grid_size = vec2(272.0, 272.0);
varying vec2 world_xz;

void vertex() {
	world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

float state_at(vec2 uv) {
	return texture(visibility_states, clamp(uv, vec2(0.0), vec2(1.0))).r * 127.5; // 0 .. 1, explored at 0.5
}

void fragment() {
	vec2 grid_uv = (world_xz - grid_origin) / grid_size;
	vec2 texel = blur_texels / vec2(textureSize(visibility_states, 0));
	float state = state_at(grid_uv) * 0.4
		+ (state_at(grid_uv + vec2(texel.x, 0.0)) + state_at(grid_uv - vec2(texel.x, 0.0))
		+ state_at(grid_uv + vec2(0.0, texel.y)) + state_at(grid_uv - vec2(0.0, texel.y))) * 0.15;
	float to_explored = smoothstep(0.0, 0.5, state);
	float to_visible = smoothstep(0.5, 1.0, state);
	vec4 fog = mix(unexplored_color, explored_color, to_explored);
	fog.a *= 1.0 - to_visible;
	ALBEDO = fog.rgb;
	ALPHA = fog.a;
}
