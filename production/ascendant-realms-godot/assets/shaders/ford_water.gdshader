shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, shadows_disabled;
// Shallow river ford. The strip runs along X; UV.y crosses the river. The
// banks fade out along a noisy edge so the water meets the painted wet
// riverbed softly, the centre is a little deeper and darker, and slow
// ripples catch the sun. No screen or depth reads.

uniform vec3 deep_tint : source_color = vec3(0.07, 0.24, 0.30);
uniform vec3 shallow_tint : source_color = vec3(0.22, 0.44, 0.44);
uniform vec3 foam_tint : source_color = vec3(0.82, 0.86, 0.80);
uniform float flow_speed = 0.35;
// Width of a river strip in metres. When set, the current runs along the
// strip (UV.x is the distance along it in widths) instead of along world X:
// a river running north to south had its streaks laid across it, and they
// read as the dashed lane markings of a road.
uniform float strip_width = 0.0;
// Where the water starts to thin toward its bank (0 centre .. 1 bank). A
// tarn keeps open water nearly to its shore; it used to fade from 0.62, so
// most of a lake showed the dark mud of its bed and read as a bog.
uniform float bank_fade = 0.62;
// Plan 347: rivers and tarns on snow maps are frozen. 1 draws ice: pale rime
// along the shore, darker clear ice over the channel, white fracture lines
// and wind-blown snow, and nothing moves. (Frostmere's "frozen river" was
// open teal water.)
uniform float frozen = 0.0;
// Plan 418: the crossing ford's shore bayed in and out only about a metre,
// so the water met the grass along a ruler line. shore_swing scales the
// shore wobble; plane_scale says how much wider than the water the plane is
// laid, so a far-reaching bay still fades out before the plane's edge.
uniform float shore_swing = 1.0;
uniform float plane_scale = 1.0;

varying vec3 wpos;

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
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * vnoise(p);
		p *= 2.1;
		a *= 0.5;
	}
	return v;
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float plane_across = abs(UV.y - 0.5) * 2.0;
	float across = plane_across * plane_scale;        // 0 centre .. 1 bank
	vec2 rc = strip_width > 0.0 ? vec2(UV.x * strip_width, (UV.y - 0.5) * strip_width) : wpos.xz;
	float wobble = ((fbm(vec2(rc.x * 0.045, 7.0)) - 0.5) * 0.7 + (fbm(vec2(rc.x * 0.21, 3.0)) - 0.5) * 0.18) * shore_swing;
	// Plan 387: ice grows out from the banks in uneven shelves, so a frozen
	// river's edge wanders far more than open water's (it read as a straight
	// painted band), with a jagged rim where the shelf broke.
	if (frozen > 0.5) {
		wobble = wobble * 2.2 + (fbm(rc * 0.35 + 5.0) - 0.5) * 0.28 + (fbm(rc * 1.6 + 9.0) - 0.5) * 0.08;
	}
	float edge = across + wobble;
	float body = 1.0 - smoothstep(bank_fade, 0.98, edge);   // soft, irregular banks
	if (plane_scale > 1.0) {
		body *= 1.0 - smoothstep(0.86, 1.0, plane_across);
	}
	float depth = 1.0 - smoothstep(0.0, 0.85, edge);
	mat2 rot = strip_width > 0.0 ? mat2(vec2(0.98, 0.2), vec2(-0.2, 0.98)) : mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	vec2 flow = rot * vec2(rc.x * 0.16 - TIME * flow_speed, rc.y * 0.42);
	float ripple = fbm(flow) * 0.6 + fbm(flow * 2.3 + 11.0) * 0.4;
	vec3 col = mix(shallow_tint, deep_tint, smoothstep(0.0, 1.0, depth));
	// Current streaks: noise stretched along the flow, drifting downstream.
	float streak = fbm(vec2(rc.x * 0.06 - TIME * flow_speed * 0.9, rc.y * 0.85 + 3.0));
	streak = smoothstep(0.55, 0.78, streak) * (0.4 + 0.6 * depth);
	col = mix(col, shallow_tint * 1.35, streak * 0.35);
	// Foam where the current breaks along the banks and around shallow riffles.
	float foam = smoothstep(0.72, 0.9, ripple) * (0.35 + 0.65 * smoothstep(0.45, 0.8, edge));
	// Plan 315: this line of froth sat at 0.6 of the way to the bank, and
	// the bank wobble carried it out into the stream as white flakes. It
	// now follows the water's edge, where the current meets the shore.
	float shore = bank_fade + (0.98 - bank_fade) * 0.45;
	float bank_line = smoothstep(shore - 0.06, shore, edge) * (1.0 - smoothstep(shore + 0.02, shore + 0.1, edge)) * smoothstep(0.5, 0.68, fbm(flow * 4.1 + 5.0));
	col = mix(col, foam_tint, clamp(foam * 0.45 + bank_line * 0.35, 0.0, 1.0));
	ALBEDO = col;
	// Shallow margins let the wet riverbed show through; the channel is deep.
	ALPHA = body * mix(0.64, 0.95, depth) + bank_line * 0.15 * body;
	ROUGHNESS = 0.06;
	SPECULAR = 0.6;
	// Ripple normal from the flow noise.
	float e = 0.4;
	float hx = fbm(flow + vec2(e, 0.0));
	float hz = fbm(flow + vec2(0.0, e));
	vec3 n = normalize(vec3((ripple - hx) * 0.55, 1.0, (ripple - hz) * 0.55));
	if (frozen > 0.5) {
		vec2 iw = rc;
		// Clear black ice over the deep channel, milky rime toward the shore.
		vec3 clear_ice = vec3(0.13, 0.27, 0.37);
		vec3 rime = vec3(0.76, 0.84, 0.90);
		float milk = smoothstep(0.4, 0.95, edge) * 0.75 + (fbm(iw * 0.18 + 31.0) - 0.35) * 0.4;
		vec3 ice = mix(clear_ice, rime, clamp(milk, 0.0, 1.0));
		// Trapped bubbles and frost blooms.
		float bloom = smoothstep(0.62, 0.8, fbm(iw * 0.9 + 7.0));
		ice = mix(ice, rime * 1.05, bloom * 0.22);
		// Fracture lines: thin white seams where two noises cross a level.
		float c1 = 1.0 - smoothstep(0.0, 0.025, abs(fbm(iw * 0.11 + 3.0) - 0.5));
		float c2 = 1.0 - smoothstep(0.0, 0.018, abs(fbm(iw * 0.33 + 17.0) - 0.5));
		float crack = max(c1, c2 * 0.7);
		ice = mix(ice, vec3(0.90, 0.94, 0.98), crack * 0.75);
		// Snow blown across the ice in long drifts.
		vec2 wind = mat2(vec2(0.86, 0.5), vec2(-0.5, 0.86)) * iw;
		float drift = smoothstep(0.58, 0.8, fbm(vec2(wind.x * 0.07, wind.y * 0.32) + 41.0));
		ice = mix(ice, vec3(0.90, 0.92, 0.96), drift * 0.6);
		// A white frozen lip where the ice meets the bank.
		float lip = smoothstep(bank_fade - 0.05, bank_fade + 0.12, edge);
		ice = mix(ice, vec3(0.88, 0.91, 0.95), lip * 0.7);
		ALBEDO = ice;
		ALPHA = clamp(body * 1.08, 0.0, 1.0);
		ROUGHNESS = mix(0.12, 0.8, max(drift, lip));
		SPECULAR = 0.5;
		float hx2 = fbm(iw * 0.5 + vec2(0.3, 0.0));
		float h0 = fbm(iw * 0.5);
		float hz2 = fbm(iw * 0.5 + vec2(0.0, 0.3));
		n = normalize(vec3((h0 - hx2) * 0.25, 1.0, (h0 - hz2) * 0.25));
	}
	NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
}
