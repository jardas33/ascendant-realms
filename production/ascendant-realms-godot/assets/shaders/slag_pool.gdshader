shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, shadows_disabled;
// Molten slag in a volcanic tarn: a dark cooling crust broken into plates
// that drift slowly, glowing seams between them, the pool hottest in the
// middle and crusted over toward its rim. UV.y runs from 0.5 at the centre
// to 1.0 at the rim of a tarn, and from 0 to 1 across a river (its banks
// at both ends). Presentation only.

uniform vec3 hot_color : source_color = vec3(1.0, 0.36, 0.05);
uniform vec3 core_color : source_color = vec3(1.0, 0.74, 0.28);
uniform vec3 crust_color : source_color = vec3(0.11, 0.065, 0.05);
uniform float flow = 0.035;
uniform float plate_scale = 0.19;
uniform float glow_strength = 1.15;

// A hash without sine: the usual fract(sin(x) * 43758) magnifies rounding,
// and neighbouring noise cells disagreed at their shared corners (the pool
// showed square blocks).
vec2 hash2(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash2(i).x;
	float b = hash2(i + vec2(1.0, 0.0)).x;
	float c = hash2(i + vec2(0.0, 1.0)).x;
	float d = hash2(i + vec2(1.0, 1.0)).x;
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p = p * 2.03 + vec2(17.0, 9.0);
		a *= 0.5;
	}
	return v;
}

// Distance to the nearest seam between cells (second nearest minus nearest).
float seam_distance(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 o = hash2(i + g);
			o = 0.5 + 0.42 * sin(TIME * 0.12 + 6.2831 * o);
			float d = length(g + o - f);
			if (d < d1) {
				d2 = d1;
				d1 = d;
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return d2 - d1;
}

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 p = world.xz * plate_scale + vec2(TIME * flow, TIME * flow * 0.6);
	p += vec2(fbm(p * 0.7 + 3.0), fbm(p * 0.7 + 11.0)) * 0.8;
	float rim = clamp(abs(UV.y - 0.5) * 2.0, 0.0, 1.0);
	float heat = 1.0 - smoothstep(0.62, 1.0, rim);
	float seam = seam_distance(p);
	float crack = 1.0 - smoothstep(0.03, 0.10 + 0.20 * heat, seam);
	float grain = fbm(p * 1.3 + 5.0);
	float swell = fbm(p * 0.45 + 21.0);
	float pulse = 0.82 + 0.18 * sin(TIME * 1.4 + grain * 9.0);
	// Hot seams everywhere but the rim, and a dull glow through thin crust in
	// the middle of the pool.
	float molten = clamp(crack * (0.25 + 0.75 * heat) + heat * (0.16 + smoothstep(0.40, 0.75, swell) * 0.5), 0.0, 1.0);
	vec3 liquid = mix(hot_color, core_color, smoothstep(0.55, 1.0, crack * heat));
	vec3 crust = crust_color * mix(0.65, 1.45, grain);
	ALBEDO = mix(crust, liquid * 0.8, molten);
	EMISSION = liquid * molten * glow_strength * pulse;
	ROUGHNESS = mix(0.92, 0.45, molten);
	SPECULAR = 0.25;
}
