shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Bark for felled logs (the timber piles and veins). The logs were smooth
// twelve-sided cylinders in one flat colour, which read as toy pegs, or as
// orange plastic in low sun. Deep furrows now run along each log, broken
// into plates, with a little grey weathering on the ridges.
// Worked out in world metres along `axis` (every log of a stack lies the
// same way), so it holds after the stack is joined into one mesh.

uniform vec3 bark_color : source_color = vec3(0.30, 0.20, 0.12);
uniform vec3 axis = vec3(0.0, 0.0, 1.0);
uniform float furrow_spacing = 0.075;

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
	vec3 a = normalize(axis);
	vec3 p1 = normalize(cross(a, abs(a.y) > 0.9 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0)));
	vec3 p2 = cross(a, p1);
	float along = dot(wpos, a);
	// Round the log: on a face looking along p2 the bark runs across p1, and
	// the other way round, so every face gets furrows across its width.
	float n1 = abs(dot(wnrm, p1));
	float n2 = abs(dot(wnrm, p2));
	float across = (dot(wpos, p1) * n2 + dot(wpos, p2) * n1) / max(n1 + n2, 0.001);
	float warp = vnoise(vec2(along * 1.4, across * 6.0)) * 0.9 + vnoise(vec2(along * 4.0, across * 14.0)) * 0.3;
	float lane = across / furrow_spacing + warp;
	float ridge = abs(sin(lane * 3.14159));
	float furrow = 1.0 - smoothstep(0.08, 0.55, ridge);
	// Plates: the ridges break every hand's length or so.
	float lane_id = floor(lane + 0.5);
	float plate = vnoise(vec2(along * 5.5 + lane_id * 7.3, lane_id * 1.7));
	float brk = smoothstep(0.80, 0.90, plate);
	float dark = max(furrow, brk * 0.85);
	vec3 col = bark_color * mix(1.18, 0.38, dark);
	col *= mix(0.82, 1.08, vnoise(vec2(along * 2.2, across * 9.0)));
	// Weathered grey on the proud ridges.
	float grey = smoothstep(0.55, 0.85, vnoise(vec2(along * 1.1 + 31.0, across * 3.0))) * (1.0 - dark);
	col = mix(col, vec3(dot(col, vec3(0.33)) * 1.25), grey * 0.45);
	ALBEDO = col;
	ROUGHNESS = mix(0.82, 1.0, dark);
	SPECULAR = 0.25;
}
