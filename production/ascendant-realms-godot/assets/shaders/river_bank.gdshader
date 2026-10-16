shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, diffuse_burley, specular_schlick_ggx, shadows_disabled;
// The wet ground along a river or a tarn. It was one flat dark colour fading
// out in a straight line, which on snow read as a tarmac road with a stream
// down the middle. Now the fade is ragged, the mud is broken by pebbles and
// silt, and on snow maps the mud is frosted, with patches of snow on it.

uniform vec3 mud : source_color = vec3(0.20, 0.19, 0.14);
uniform vec3 silt : source_color = vec3(0.34, 0.31, 0.24);
uniform float snow = 0.0;

varying vec3 wpos;

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
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 w = wpos.xz;
	float a = COLOR.a;
	// A ragged edge: the fade is pushed in and out by two noises.
	float rag = vnoise(w * 0.35) * 0.65 + vnoise(w * 1.4 + 5.0) * 0.35;
	float body = smoothstep(0.0, 1.0, a + (rag - 0.5) * 0.45);
	// Mud with lighter silt and scattered pebbles.
	float s = vnoise(w * 0.8 + 11.0);
	vec3 col = mix(mud, silt, smoothstep(0.45, 0.8, s) * 0.6);
	float peb = step(0.78, vnoise(w * 7.0)) * step(0.4, vnoise(w * 2.1 + 3.0));
	col = mix(col, silt * 1.25, peb * 0.6);
	// Frost and drifts over the outer, drier bank.
	vec2 r = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * w;
	float drift = vnoise(r * 0.45 + 17.0) * 0.6 + vnoise(r * 1.7 + 3.0) * 0.4;
	float frost = snow * (0.28 + 0.4 * smoothstep(0.5, 0.85, drift));
	col = mix(col, vec3(0.80, 0.84, 0.90), frost);
	ALBEDO = col;
	ROUGHNESS = mix(0.55, 0.95, frost);
	SPECULAR = 0.3;
	ALPHA = body;
}
