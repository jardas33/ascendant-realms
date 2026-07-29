shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Self-contained stylized toon water. GLES3 / web (GL Compatibility) safe:
// no #include, no preprocessor directives, no screen/depth texture reads, and
// opaque (no transparency) so it never vanishes under the web renderer. Sells
// "water" through animated procedural ripples, drifting foam bands, a fresnel
// rim and a crisp specular glint.

uniform vec3 deep_color : source_color = vec3(0.05, 0.22, 0.34);
uniform vec3 shallow_color : source_color = vec3(0.16, 0.48, 0.58);
uniform vec3 foam_color : source_color = vec3(0.86, 0.95, 1.0);
uniform float ripple_scale = 0.035;
uniform float wave_speed = 0.06;
uniform float wave_height = 0.45;
uniform float emission_strength = 0.12;  // raise for lava/glowing liquids

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
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 3; i++) {
		v += amp * vnoise(p);
		p = p * 2.02 + 7.0;
		amp *= 0.5;
	}
	return v;
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * wave_speed;
	float w = fbm(wpos.xz * ripple_scale + vec2(t, t * 0.6));
	float w2 = fbm(wpos.xz * ripple_scale * 2.1 - vec2(t * 0.8, t));
	VERTEX.y += (w + w2 - 1.0) * wave_height;
}

void fragment() {
	vec2 uv = wpos.xz;
	float t = TIME * wave_speed;
	float ripple = fbm(uv * ripple_scale * 1.6 + vec2(t, -t * 0.5));
	float ripple2 = fbm(uv * ripple_scale * 4.0 - vec2(t * 1.3, t));

	vec3 col = mix(deep_color, shallow_color, clamp(ripple * 1.2, 0.0, 1.0));

	// fresnel rim brightening at grazing angles
	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 3.0);
	col = mix(col, shallow_color * 1.35, fres * 0.55);

	// drifting foam crests
	float foam = smoothstep(0.72, 0.95, ripple * ripple2 * 2.2);
	col = mix(col, foam_color, foam * 0.5);

	ALBEDO = col;
	ROUGHNESS = 0.06 + 0.10 * ripple;
	METALLIC = 0.0;
	SPECULAR = 0.6;
	EMISSION = mix(deep_color, shallow_color, ripple) * emission_strength + shallow_color * fres * 0.12;
}
