shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Coarse sackcloth for the grain sacks: a visible weave, darker creases
// where the cloth folds, and dust and grain stains. Worked out in world
// metres on three planes blended by the surface's facing, so the sacks can
// be joined with the rest of their deposit. (They were smooth beige blobs.)

uniform vec3 cloth_color : source_color = vec3(0.62, 0.50, 0.33);
uniform float weave_scale = 30.0;

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

// Over-under threads: alternate cells lift the warp or the weft.
float weave(vec2 p) {
	vec2 c = floor(p);
	vec2 f = fract(p);
	float over = mod(c.x + c.y, 2.0);
	float warp = 1.0 - abs(f.x - 0.5) * 2.0;
	float weft = 1.0 - abs(f.y - 0.5) * 2.0;
	return mix(warp, weft, over);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wnrm = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 bw = pow(abs(wnrm), vec3(4.0));
	bw /= (bw.x + bw.y + bw.z);
	float t = weave(wpos.yz * weave_scale) * bw.x + weave(wpos.xz * weave_scale) * bw.y + weave(wpos.xy * weave_scale) * bw.z;
	vec2 big = wpos.xz + wpos.y * 0.7;
	float stain = smoothstep(0.55, 0.85, vnoise(big * 2.3));
	float crease = smoothstep(0.62, 0.9, vnoise(big * 5.0 + 17.0));
	vec3 col = cloth_color * mix(0.78, 1.04, smoothstep(0.1, 0.9, t));
	col *= mix(1.0, 0.72, crease);
	col = mix(col, col * vec3(0.78, 0.70, 0.58), stain * 0.6);
	// Flour dust, pale towards the top of each sack.
	col = mix(col, vec3(0.80, 0.76, 0.66), smoothstep(0.65, 1.0, wnrm.y) * 0.18);
	ALBEDO = col;
	ROUGHNESS = 1.0;
	SPECULAR = 0.15;
}
