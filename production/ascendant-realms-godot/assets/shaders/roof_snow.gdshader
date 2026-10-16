shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, diffuse_burley, specular_disabled;
// Snow lying on a building on a field under snow: drawn over the building's
// own materials (a material overlay) on whatever faces the sky, from a
// little above the ground up, in uneven drifts. `cut_y` is the rising work
// line of a building under construction (see construction_rise): no snow
// above it. Presentation only.

instance uniform float cut_y = 100000.0;
uniform vec3 snow_color : source_color = vec3(0.90, 0.93, 0.98);

varying vec3 v_world;
varying vec3 v_up;

float hash21(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)) + ivec2(65536));
	uint h = (q.x * 1597334677u) ^ (q.y * 3812015801u);
	h = (h ^ (h >> 16u)) * 2246822519u;
	h ^= h >> 13u;
	return float(h) * (1.0 / 4294967295.0);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x), mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_up = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	if (v_world.y > cut_y) {
		discard;
	}
	float lying = smoothstep(0.3, 0.75, normalize(v_up).y) * smoothstep(0.7, 1.8, v_world.y);
	float drift = vnoise(v_world.xz * 0.9) * 0.6 + vnoise(v_world.xz * 3.1) * 0.4;
	lying *= smoothstep(0.18, 0.55, drift + 0.25);
	// Deep drifts are white; thin snow is a cold blue-grey and lets the
	// roof's own shingles and ridges show through, so a roof reads as a
	// roof under snow, not a flat white sheet (which it did).
	float depth = smoothstep(0.42, 0.9, drift);
	float grain = vnoise(v_world.xz * 11.0) * 0.5 + vnoise(v_world.xz * 27.0) * 0.5;
	vec3 thin = vec3(0.66, 0.72, 0.82);
	ALBEDO = mix(thin, snow_color * 0.94, depth) * (0.93 + 0.07 * grain);
	// Now and then a crystal catches the light.
	float glint = step(0.985, hash21(floor(v_world.xz * 18.0)));
	EMISSION = vec3(0.35, 0.38, 0.42) * glint * depth;
	ROUGHNESS = 0.8;
	ALPHA = lying * mix(0.38, 0.92, depth);
}
