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

varying vec3 wpos;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
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
	float across = abs(UV.y - 0.5) * 2.0;            // 0 centre .. 1 bank
	float wobble = (fbm(vec2(wpos.x * 0.045, 7.0)) - 0.5) * 0.7 + (fbm(vec2(wpos.x * 0.21, 3.0)) - 0.5) * 0.18;
	float edge = across + wobble;
	float body = 1.0 - smoothstep(0.62, 0.98, edge);   // soft, irregular banks
	float depth = 1.0 - smoothstep(0.0, 0.85, edge);
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	vec2 flow = rot * vec2(wpos.x * 0.16 - TIME * flow_speed, wpos.z * 0.42);
	float ripple = fbm(flow) * 0.6 + fbm(flow * 2.3 + 11.0) * 0.4;
	vec3 col = mix(shallow_tint, deep_tint, depth * 0.85);
	// Foam where the current breaks along the banks and around shallow riffles.
	float foam = smoothstep(0.72, 0.9, ripple) * (0.35 + 0.65 * smoothstep(0.45, 0.8, edge));
	col = mix(col, foam_tint, foam * 0.55);
	ALBEDO = col;
	ALPHA = body * mix(0.78, 0.96, depth);
	ROUGHNESS = 0.12;
	SPECULAR = 0.6;
	// Ripple normal from the flow noise.
	float e = 0.4;
	float hx = fbm(flow + vec2(e, 0.0));
	float hz = fbm(flow + vec2(0.0, e));
	vec3 n = normalize(vec3((ripple - hx) * 0.55, 1.0, (ripple - hz) * 0.55));
	NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
}
