shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Ploughed earth under a grain patch: ridges and furrows in rows, clods,
// and a scatter of fallen straw. Worked out in world metres, so the patch
// can be joined with the rest of its deposit into one mesh. (It was one flat
// dark-brown plate.)

uniform vec3 soil_color : source_color = vec3(0.30, 0.20, 0.12);
uniform float row_spacing = 0.42;

varying vec3 wpos;

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
}

void fragment() {
	vec2 w = wpos.xz;
	float wob = vnoise(w * vec2(0.6, 0.3)) * 0.35;
	float row = sin((w.y / row_spacing + wob) * 6.28318) * 0.5 + 0.5;
	float ridge = smoothstep(0.35, 0.95, row);
	float clods = vnoise(w * 7.0) * 0.6 + vnoise(w * 19.0) * 0.4;
	vec3 col = soil_color * mix(0.66, 1.10, ridge) * mix(0.82, 1.12, clods);
	// Damp darker earth in patches.
	col *= mix(1.0, 0.78, smoothstep(0.55, 0.8, vnoise(w * 0.9 + 11.0)));
	// Fallen straw: thin pale flecks lying along the rows.
	// Short, few and scattered, each cell holding at most one bit.
	vec2 sp = vec2(w.x * 5.0, w.y * 14.0);
	vec2 cell = floor(sp);
	vec2 h = hash2(cell);
	vec2 f = fract(sp) - (0.25 + 0.5 * h);
	float straw = step(0.94, h.x) * (1.0 - smoothstep(0.10, 0.18, length(f * vec2(1.0, 3.0))));
	col = mix(col, vec3(0.62, 0.50, 0.30), straw * 0.55);
	ALBEDO = col;
	ROUGHNESS = 0.95;
	SPECULAR = 0.2;
}
