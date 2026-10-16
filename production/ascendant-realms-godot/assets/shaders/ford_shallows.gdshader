shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_back, diffuse_burley, specular_schlick_ggx, shadows_disabled;
// The shallows of a ford: a bed of pebbles and gravel seen through a hand's
// depth of clear water, with sunlight rippling over it. The strip fades out
// along the river and at the banks through the vertex alpha. (It was one
// flat pale colour, which read as a band of fog across the river.)

uniform vec3 water_tint : source_color = vec3(0.22, 0.46, 0.46);
uniform vec3 bed_light : source_color = vec3(0.62, 0.58, 0.47);
uniform vec3 bed_dark : source_color = vec3(0.38, 0.37, 0.32);
uniform float pebble_scale = 2.6;
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

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash2(i).x, hash2(i + vec2(1.0, 0.0)).x, f.x), mix(hash2(i + vec2(0.0, 1.0)).x, hash2(i + vec2(1.0, 1.0)).x, f.x), f.y);
}

// Plan 314: the pebbles were a metre and a quarter across, evenly spaced
// with dark joints, and the ford read as a paved road under glass. Now it
// is a river bed: fist-sized cobbles of mixed stone, sand drifts between
// them, a few larger stones, and finer light rippling over it all.
void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 w = world.xz;
	vec3 cob = pebbles(w * pebble_scale);
	vec3 grit = pebbles(w * pebble_scale * 2.7 + 7.0);
	vec3 rock = pebbles(w * pebble_scale * 0.32 + 19.0);
	// Each cobble its own stone: grey, buff or dark, rounded and set in a
	// thin shadow where it meets its neighbours.
	vec3 hue = mix(bed_dark, bed_light, cob.y);
	hue *= mix(vec3(1.0), vec3(1.06, 0.98, 0.88), step(0.7, fract(cob.y * 5.3)));
	vec3 stone = hue * mix(1.1, 0.74, smoothstep(0.05, 0.6, cob.x));
	stone *= mix(0.62, 1.0, smoothstep(0.0, 0.1, cob.z));
	vec3 gravel = mix(bed_dark, bed_light, grit.y) * mix(1.02, 0.84, smoothstep(0.0, 0.6, grit.x));
	vec3 sand = mix(bed_dark, bed_light, 0.72) * (0.9 + 0.14 * vnoise(w * 6.0));
	// Sand settles in drifts; cobbles stand out of it.
	float drift = smoothstep(0.5, 0.7, vnoise(w * 0.45) * 0.7 + vnoise(w * 1.3 + 4.0) * 0.3);
	vec3 bed = mix(stone, gravel, step(0.62, fract(cob.y * 7.0)) * 0.7);
	bed = mix(bed, sand, drift * smoothstep(0.32, 0.6, cob.x) * 0.85);
	// Now and then a bigger stone, darker and wet on top.
	float big = step(0.86, fract(rock.y * 3.7)) * (1.0 - smoothstep(0.28, 0.4, rock.x));
	bed = mix(bed, mix(bed_dark, bed_light, rock.y * 0.6) * mix(1.05, 0.7, smoothstep(0.0, 0.38, rock.x)), big);
	// Light through the moving surface: thin bright bands that drift.
	float t = TIME * 0.9;
	vec2 c = w * 1.8;
	float ripple = sin(c.x * 1.7 + t + sin(c.y * 1.3 - t * 0.7) * 1.4) * sin(c.y * 1.9 - t * 0.8 + sin(c.x * 1.1 + t * 0.5) * 1.6);
	float caustic = pow(clamp(ripple * 0.5 + 0.5, 0.0, 1.0), 8.0);
	vec3 seen = mix(bed, bed * water_tint * 2.1, 0.55) + vec3(0.85, 0.95, 0.9) * caustic * 0.07;
	ALBEDO = seen;
	ROUGHNESS = 0.18;
	SPECULAR = 0.55;
	ALPHA = COLOR.a * opacity;
}
