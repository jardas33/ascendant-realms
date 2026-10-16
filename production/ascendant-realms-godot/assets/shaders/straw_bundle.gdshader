shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Bound straw for the grain sheaves: fine stalks running up each bundle,
// some lighter and some darker, with a little sheen. Worked out in world
// metres, stalks running up the world's y (the sheaves stand), so the patch
// can be joined into one mesh. (The sheaves were smooth yellow domes.)

uniform vec3 straw_color : source_color = vec3(0.78, 0.60, 0.26);

varying vec3 wpos;
varying vec3 wnrm;

vec2 hash2(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash2(i).x;
	float b = hash2(i + vec2(1.0, 0.0)).x;
	float c = hash2(i + vec2(0.0, 1.0)).x;
	float d = hash2(i + vec2(1.0, 1.0)).x;
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	// Stalks: a field that changes quickly across the ground plane and slowly
	// upward, so on the sides of a standing bundle it draws upright streaks
	// whatever way the surface faces. Measured from the deposit's own origin.
	vec3 q = wpos - NODE_POSITION_WORLD;
	float s1 = vnoise(vec2(q.x * 38.0 + q.z * 11.0, q.y * 1.6));
	float s2 = vnoise(vec2(q.z * 38.0 - q.x * 13.0, q.y * 1.6 + 7.0));
	float stalk = s1 * 0.6 + s2 * 0.4;
	float shade = vnoise(vec2(q.x * 9.0 + q.z * 7.0, q.y * 0.8 + 3.0));
	vec3 col = straw_color * mix(0.70, 1.12, smoothstep(0.2, 0.8, stalk)) * mix(0.88, 1.08, shade);
	// Tops of the bundle are drier and paler.
	col = mix(col, col * vec3(1.12, 1.08, 0.95), smoothstep(0.5, 1.0, wnrm.y) * 0.5);
	ALBEDO = col;
	ROUGHNESS = mix(0.55, 0.85, shade);
	SPECULAR = 0.4;
}
