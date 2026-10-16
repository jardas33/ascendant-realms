shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
// Where a unit fell: a ragged patch of churned, darkened earth with a few
// scattered flecks, fading out through `fade`. Presentation only.
// Plan 316: it was unshaded, so its dark earth drew brighter than the lit
// ground around it on dark maps and every ruin sat on a pale pink stain.
// Now it takes the sun and shade like the ground it lies on.

uniform float fade = 1.0;
uniform float seed = 0.0;

float h(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)) + ivec2(65536));
	uint v = (q.x * 1597334677u) ^ (q.y * 3812015801u);
	v = (v ^ (v >> 16u)) * 2246822519u;
	v ^= v >> 13u;
	return float(v) * (1.0 / 4294967295.0);
}

float n(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h(i), h(i + vec2(1, 0)), f.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), f.x), f.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 o = vec2(seed * 7.3, seed * 3.1);
	float edge = length(p) + (n(p * 3.0 + o) - 0.5) * 0.7 + (n(p * 8.0 + o) - 0.5) * 0.2;
	float patch = 1.0 - smoothstep(0.45, 0.9, edge);
	float flecks = step(0.8, n(p * 14.0 + o * 2.0)) * (1.0 - smoothstep(0.6, 1.0, length(p)));
	vec3 earth = mix(vec3(0.045, 0.038, 0.032), vec3(0.085, 0.05, 0.035), n(p * 5.0 + o) * 0.6);
	ALBEDO = earth;
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
	ALPHA = clamp(patch * 0.8 + flecks * 0.5, 0.0, 0.88) * fade;
}
