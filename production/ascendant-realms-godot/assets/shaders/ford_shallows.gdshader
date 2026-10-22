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
// Plan 347: on snow maps the ford is frozen over: stones seen through clear
// ice under a dusting of snow, with no moving light.
uniform float frozen = 0.0;

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
	// Plan 412: the cells were still one size with dark joints, so the bed
	// read as paving. The cells are now warped so each stone has its own
	// shape, cobbles lie in patches with sand and fine gravel between them,
	// and the joints are soft.
	vec2 warp = vec2(vnoise(w * 0.9 + 3.0), vnoise(w * 0.9 + 11.0)) - 0.5;
	vec2 wp = w + warp * 0.55;
	vec3 cob = pebbles(wp * pebble_scale);
	vec3 small = pebbles(wp * pebble_scale * 1.9 + 41.0);
	vec3 grit = pebbles(w * pebble_scale * 4.2 + 7.0);
	vec3 rock = pebbles(wp * pebble_scale * 0.36 + 19.0);
	float field = vnoise(w * 0.38) * 0.65 + vnoise(w * 1.1 + 4.0) * 0.35;
	float cobbled = smoothstep(0.42, 0.62, field);
	float pebbly = smoothstep(0.3, 0.45, field) * (1.0 - cobbled);
	// Each cobble its own stone: grey, buff or dark, rounded on top.
	vec3 hue = mix(bed_dark, bed_light, cob.y);
	hue *= mix(vec3(1.0), vec3(1.06, 0.98, 0.88), step(0.7, fract(cob.y * 5.3)));
	vec3 stone = hue * mix(1.12, 0.8, smoothstep(0.05, 0.55, cob.x));
	stone *= mix(0.78, 1.0, smoothstep(0.0, 0.12, cob.z));
	vec3 pstone = mix(bed_dark, bed_light, small.y) * mix(1.08, 0.82, smoothstep(0.05, 0.5, small.x));
	pstone *= mix(0.82, 1.0, smoothstep(0.0, 0.1, small.z));
	vec3 sand = mix(bed_dark, bed_light, 0.7) * (0.9 + 0.14 * vnoise(w * 6.0));
	vec3 gravel = mix(sand, mix(bed_dark, bed_light, grit.y), 0.45) * mix(1.04, 0.9, smoothstep(0.0, 0.55, grit.x));
	vec3 bed = mix(sand, gravel, 0.55 + 0.3 * vnoise(w * 2.3 + 8.0));
	// Stones stand in the patches; the gaps between them fill with sand.
	float stone_cov = cobbled * (1.0 - smoothstep(0.42, 0.62, cob.x));
	float peb_cov = pebbly * (1.0 - smoothstep(0.32, 0.5, small.x)) * step(0.35, small.y);
	bed = mix(bed, pstone, peb_cov);
	bed = mix(bed, stone, stone_cov);
	// Now and then a bigger stone, darker and wet on top.
	float big = step(0.84, fract(rock.y * 3.7)) * (1.0 - smoothstep(0.3, 0.42, rock.x));
	bed = mix(bed, mix(bed_dark, bed_light, rock.y * 0.6) * mix(1.08, 0.72, smoothstep(0.0, 0.4, rock.x)), big);
	// Light through the moving surface: thin bright bands that drift.
	float t = TIME * 0.9;
	vec2 c = w * 1.8;
	float ripple = sin(c.x * 1.7 + t + sin(c.y * 1.3 - t * 0.7) * 1.4) * sin(c.y * 1.9 - t * 0.8 + sin(c.x * 1.1 + t * 0.5) * 1.6);
	float caustic = pow(clamp(ripple * 0.5 + 0.5, 0.0, 1.0), 8.0);
	vec3 seen = mix(bed, bed * water_tint * 2.1, 0.55) + vec3(0.85, 0.95, 0.9) * caustic * 0.07;
	if (frozen > 0.5) {
		float dust = smoothstep(0.45, 0.75, vnoise(w * 0.35) * 0.6 + vnoise(w * 1.6 + 9.0) * 0.4);
		seen = mix(bed * vec3(0.78, 0.86, 0.94), vec3(0.70, 0.80, 0.88), 0.45);
		seen = mix(seen, vec3(0.90, 0.92, 0.96), dust * 0.7);
	}
	ALBEDO = seen;
	ROUGHNESS = 0.18;
	SPECULAR = 0.55;
	ALPHA = COLOR.a * opacity;
}
