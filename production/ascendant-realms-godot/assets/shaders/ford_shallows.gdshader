shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, diffuse_burley, specular_schlick_ggx, shadows_disabled;
// The shallows of a ford: a bed of pebbles and gravel seen through a hand's
// depth of clear water, with sunlight rippling over it. The strip fades out
// along the river and at the banks through the vertex alpha. (It was one
// flat pale colour, which read as a band of fog across the river.)

uniform vec3 water_tint : source_color = vec3(0.22, 0.46, 0.46);
uniform vec3 bed_light : source_color = vec3(0.62, 0.58, 0.47);
uniform vec3 bed_dark : source_color = vec3(0.38, 0.37, 0.32);
uniform float pebble_scale = 0.8;
uniform float opacity = 0.82;

vec2 hash2(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.xx + p3.yz) * p3.zy);
}

// Nearest-cell distance, the cell's own random value, and the gap to the
// next cell (small along the cracks between pebbles).
vec3 pebbles(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	float id = 0.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 h = hash2(i + g);
			float d = length(g + 0.15 + 0.7 * h - f);
			if (d < d1) {
				d2 = d1;
				d1 = d;
				id = h.y;
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return vec3(d1, id, d2 - d1);
}

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 w = world.xz;
	vec3 big = pebbles(w * pebble_scale);
	vec3 small = pebbles(w * pebble_scale * 3.1 + 7.0);
	// Each pebble its own shade between dark and light stone, rounded (lit
	// in its middle) and set apart by a darker crack.
	vec3 stone = mix(bed_dark, bed_light, big.y);
	stone *= mix(1.08, 0.78, smoothstep(0.1, 0.62, big.x));
	stone *= mix(0.72, 1.0, smoothstep(0.0, 0.08, big.z));
	vec3 gravel = mix(bed_dark, bed_light, small.y) * mix(1.0, 0.82, smoothstep(0.0, 0.6, small.x));
	vec3 bed = mix(gravel, stone, step(0.45, fract(big.y * 7.0)) * 0.85 + 0.15);
	// Light through the moving surface: thin bright bands that drift.
	float t = TIME * 0.9;
	float ripple = sin(w.x * 1.7 + t + sin(w.y * 1.3 - t * 0.7) * 1.4) * sin(w.y * 1.9 - t * 0.8 + sin(w.x * 1.1 + t * 0.5) * 1.6);
	float caustic = pow(clamp(ripple * 0.5 + 0.5, 0.0, 1.0), 6.0);
	vec3 seen = mix(bed, bed * water_tint * 2.1, 0.62) + vec3(0.85, 0.95, 0.9) * caustic * 0.28;
	ALBEDO = seen;
	ROUGHNESS = 0.18;
	SPECULAR = 0.55;
	ALPHA = COLOR.a * opacity;
}
