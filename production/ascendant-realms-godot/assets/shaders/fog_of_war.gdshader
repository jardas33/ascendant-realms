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

float fh(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)) + ivec2(65536));
	uint h = (q.x * 1597334677u) ^ (q.y * 3812015801u);
	h = (h ^ (h >> 16u)) * 2246822519u;
	h ^= h >> 13u;
	return float(h) * (1.0 / 4294967295.0);
}

float fn(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(fh(i), fh(i + vec2(1, 0)), f.x), mix(fh(i + vec2(0, 1)), fh(i + vec2(1, 1)), f.x), f.y);
}

// Slow, domain-warped cloud field that drifts across the shroud.
float cloud(vec2 p, float t) {
	vec2 w = vec2(fn(p * 0.5 + vec2(t * 0.03, 0.0)), fn(p * 0.5 + vec2(5.2, t * 0.025)));
	vec2 q = p + (w - 0.5) * 2.4 + vec2(t * 0.08, t * 0.03);
	return fn(q) * 0.55 + fn(q * 2.1 + 3.7) * 0.3 + fn(q * 4.3 + 9.1) * 0.15;
}

void fragment() {
	vec2 grid_uv = (world_xz - grid_origin) / grid_size;
	vec2 texel = blur_texels / vec2(textureSize(visibility_states, 0));
	float state = state_at(grid_uv) * 0.4
		+ (state_at(grid_uv + vec2(texel.x, 0.0)) + state_at(grid_uv - vec2(texel.x, 0.0))
		+ state_at(grid_uv + vec2(0.0, texel.y)) + state_at(grid_uv - vec2(0.0, texel.y))) * 0.15;
	// Drifting cloud texture and wispy, slowly moving borders instead of a flat
	// tinted sheet. The visibility grid stays authoritative: the noise only
	// feathers the edge by a fraction of a cell.
	float c = cloud(world_xz * 0.045, TIME);
	state += (c - 0.5) * 0.16;
	float to_explored = smoothstep(0.0, 0.5, state);
	float to_visible = smoothstep(0.5, 1.0, state);
	vec4 deep = unexplored_color;
	deep.rgb = mix(deep.rgb, deep.rgb + vec3(0.07, 0.08, 0.10), smoothstep(0.45, 0.85, c));
	deep.a = clamp(deep.a * (0.86 + 0.28 * c), 0.0, 0.97);
	vec4 seen = explored_color;
	seen.a *= 0.8 + 0.4 * c;
	vec4 fog = mix(deep, seen, to_explored);
	fog.a *= 1.0 - to_visible;
	ALBEDO = fog.rgb;
	ALPHA = fog.a;
}
