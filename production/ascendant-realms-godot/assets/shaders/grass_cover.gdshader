shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_disabled;
// Instanced ground cover (grass tufts and wildflowers). UV.y runs 0 at the
// root to 1 at the tip; UV.x > 1.5 marks flower-head vertices, which take the
// per-instance colour from INSTANCE_CUSTOM. Blades bend with a travelling
// wind, shade like the ground they grow from (normal pulled up) and shrink
// to nothing wherever the clear mask is set (building footprints, resource
// sites). Presentation only.

uniform vec3 root_color : source_color = vec3(0.16, 0.22, 0.08);
uniform vec3 tip_color : source_color = vec3(0.62, 0.66, 0.30);
uniform vec3 dry_color : source_color = vec3(0.70, 0.60, 0.32);
uniform float wind_strength = 0.12;
uniform float wind_speed = 1.3;
uniform sampler2D clear_mask : filter_linear, repeat_disable;
uniform vec2 mask_origin = vec2(-140.0, -140.0);
uniform vec2 mask_size = vec2(280.0, 280.0);

// Integer hash of a lattice point. The old fract(p * 123.34) hash lost
// precision on the GPU, so neighbouring cells disagreed about their shared
// corners and the noise showed hard square seams across the ground.
float hash21(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)) + ivec2(65536));
	uint h = (q.x * 1597334677u) ^ (q.y * 3812015801u);
	h = (h ^ (h >> 16u)) * 2246822519u;
	h ^= h >> 13u;
	h *= 3266489917u;
	h ^= h >> 16u;
	return float(h) * (1.0 / 4294967295.0);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		v += amp * vnoise(p);
		p *= 2.03;
		amp *= 0.5;
	}
	return v;
}

// Broad cloud shadows drifting across the battlefield (shared by the ground
// and grass shaders so both darken together).
float cloud_shadow(vec2 xz, float t) {
	vec2 p = xz * 0.011 + vec2(t * 0.022, t * 0.009);
	float n = fbm(p) * 0.7 + fbm(p * 2.3 + 4.0) * 0.3;
	return smoothstep(0.5, 0.68, n);
}

uniform float cloud_shadow_strength = 0.2;
// Plan 366: 1 on a wetland. The ground shader lays standing pools where its
// bog noise peaks; grass tufts stood on that water. Same noise, no tufts.
uniform float bog_surface = 0.0;
// Plan 369: 1 on an ashen map. Tufts stood on the pale ash drifts the
// ground shader lays and read as dark specks; same drift noise, no tufts.
uniform float ash_surface = 0.0;
varying float v_shade;
varying float v_height;
varying float v_head;
varying float v_eye;
varying vec4 v_custom;
// Plan 414: the same 20 to 40 m lush and sun-dried patches the ground
// shader paints, so tufts and ground change together.
uniform float meadow_mid = 1.0;
varying vec3 v_mid;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float clear = texture(clear_mask, (origin.xz - mask_origin) / mask_size).r;
	float grow = 1.0 - smoothstep(0.15, 0.6, clear);
	// Same bare-dirt and rock fields the ground shader paints (unbiased), so
	// grass thins out over clearings instead of sprinkling across them.
	float dirt_m = smoothstep(0.66, 0.82, fbm(origin.xz * 0.017 + 60.0));
	float rock_m = smoothstep(0.62, 0.80, fbm(origin.xz * 0.02 + 21.0));
	grow *= (1.0 - 0.9 * smoothstep(0.2, 0.7, dirt_m)) * (1.0 - smoothstep(0.15, 0.55, rock_m));
	if (bog_surface > 0.0) {
		vec2 bp = origin.xz * 0.03 + 71.0;
		float patch_m = 0.5 * vnoise(bp) + 0.25 * vnoise(bp * 2.03) + 0.1875;
		grow *= 1.0 - smoothstep(0.635, 0.665, patch_m + (fbm(origin.xz * 0.15 + 3.0) - 0.5) * 0.08) * bog_surface;
	}
	if (ash_surface > 0.0) {
		vec2 wind = vec2(origin.x * 0.7 + origin.z * 0.7, -origin.x * 0.7 + origin.z * 0.7);
		vec2 dp = vec2(wind.x * 0.012, wind.y * 0.045) + 31.0;
		float drift_n = 0.5 * vnoise(dp) + 0.25 * vnoise(dp * 2.03) + 0.1875;
		grow *= 1.0 - smoothstep(0.44, 0.56, drift_n + (fbm(origin.xz * 0.2 + 4.0) - 0.5) * 0.12) * ash_surface;
	}
	// Plan 491: a tuft shrunk below a third of its size read as a lone
	// yellow speck on bare ground; those are now dropped, not shrunk.
	grow *= smoothstep(0.22, 0.45, grow);
	VERTEX *= grow;
	float h = UV.y;
	// Travelling gusts plus a quick flutter; the tip moves, the root stays.
	float phase = dot(origin.xz, vec2(0.21, 0.13));
	float gust = sin(TIME * wind_speed * 0.6 - origin.x * 0.045 - origin.z * 0.03) * 0.5 + 0.5;
	float sway = sin(TIME * wind_speed + phase) * (0.35 + 0.65 * gust) + 0.25 * sin(TIME * wind_speed * 2.7 + phase * 3.1);
	vec3 bend_world = vec3(0.8, 0.0, 0.45) * sway * wind_strength * h * h;
	// Convert the world-space bend into the instance's local space.
	VERTEX += (inverse(mat3(MODEL_MATRIX)) * bend_world) * grow;
	v_height = h;
	v_shade = 1.0 - cloud_shadow_strength * cloud_shadow(origin.xz, TIME);
	v_head = step(1.5, UV.x);
	v_eye = clamp(UV.x - 2.0, 0.0, 1.0) * v_head;
	v_custom = INSTANCE_CUSTOM;
	float mid_f = fbm(origin.xz * 0.045 + 77.0);
	v_mid = mix(vec3(1.0), vec3(0.64, 0.76, 0.6), smoothstep(0.48, 0.62, mid_f) * 0.85 * meadow_mid);
	v_mid *= mix(vec3(1.0), vec3(1.10, 1.04, 0.80), (1.0 - smoothstep(0.34, 0.46, mid_f)) * 0.65 * meadow_mid);
}

void fragment() {
	// INSTANCE_CUSTOM: rgb flower colour (heads) / a = dryness 0..1 (blades).
	vec3 blade = mix(root_color, tip_color, smoothstep(0.0, 1.0, v_height));
	blade = mix(blade, dry_color * mix(0.6, 1.0, v_height), v_custom.a * 0.85);
	// Plan 519: petals pale toward their tips and darken into a golden eye.
	vec3 petal = mix(v_custom.rgb * 1.08, v_custom.rgb * 0.78, smoothstep(0.0, 0.6, v_eye));
	petal = mix(petal, vec3(0.92, 0.70, 0.18), smoothstep(0.62, 0.86, v_eye));
	vec3 col = mix(blade, petal, v_head);
	ALBEDO = col * v_shade * mix(v_mid, vec3(1.0), v_head);
	// Blades light like the ground they sit on, so the field reads as one
	// surface with texture rather than a mass of dark back faces.
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	NORMAL = normalize(mix(NORMAL, up_view, 0.75));
	ROUGHNESS = 0.9;
	BACKLIGHT = vec3(0.18, 0.2, 0.08) * v_height;
	AO = mix(0.55, 1.0, v_height);
	AO_LIGHT_AFFECT = 0.4;
}
