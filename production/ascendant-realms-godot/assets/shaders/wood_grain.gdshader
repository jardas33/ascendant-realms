shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Hewn timber for the hand-built monument pieces (loom frames, drum
// bodies, scaffolds). Long grain runs along the piece's own axis, with
// darker latewood streaks, a few knots and a worn, lighter edge. Measured
// in the piece's own metres so short and long pieces share one grain.

uniform vec3 wood_color : source_color = vec3(0.45, 0.30, 0.17);
uniform vec3 axis = vec3(0.0, 1.0, 0.0);

varying vec3 opos;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
	opos = VERTEX;
}

void fragment() {
	vec3 a = normalize(axis);
	vec3 p1 = normalize(cross(a, abs(a.y) > 0.9 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0)));
	vec3 p2 = cross(a, p1);
	float along = dot(opos, a);
	float across = dot(opos, p1) * 0.8 + dot(opos, p2) * 0.6;
	// Wavy growth lines, bent a little by slow noise along the piece.
	float warp = vnoise(vec2(along * 0.9, across * 2.0)) * 2.6 + vnoise(vec2(along * 3.0, across * 7.0)) * 0.6;
	float rings = sin((across * 34.0 + warp * 3.0) ) * 0.5 + 0.5;
	float late = smoothstep(0.55, 0.95, rings);
	// A knot now and then.
	vec2 kc = vec2(along * 1.3, across * 3.0);
	float knot = 1.0 - smoothstep(0.0, 0.16, length(fract(kc) - 0.5) - 0.05 * vnoise(kc * 4.0));
	knot *= step(0.82, hash(floor(kc)));
	vec3 col = wood_color * mix(1.08, 0.70, late);
	col *= mix(0.9, 1.06, vnoise(vec2(along * 6.0, across * 40.0)));
	col = mix(col, wood_color * 0.45, knot * 0.8);
	ALBEDO = col;
	ROUGHNESS = mix(0.72, 0.9, late);
	SPECULAR = 0.3;
}
