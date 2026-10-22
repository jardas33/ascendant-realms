shader_type spatial;
render_mode cull_disabled, diffuse_burley;
// Rally flag flying from its pole: team cloth fixed along the pole edge
// (UV.x = 0), rippling harder toward the free swallowtail end, with a gilt
// border and lozenge. Fold normals come from the wave so the cloth catches
// light like fabric instead of reading as a flat card. Presentation only.

instance uniform vec4 team_color : source_color = vec4(0.22, 0.42, 0.9, 1.0);
uniform vec4 trim_color : source_color = vec4(0.86, 0.68, 0.32, 1.0);
uniform float flag_width = 0.78;

varying float v_fold;

float wave_at(float u, float v, float t) {
	return sin(t - u * 6.0 + v * 1.1) * 0.6 + sin(t * 1.7 - u * 10.5 - v * 0.8) * 0.25;
}

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float t = TIME * 3.1 + origin.x * 0.37 + origin.z * 0.23;
	float u = UV.x;
	float amp = 0.11 * (0.25 + 0.75 * u);
	float w = wave_at(u, UV.y, t);
	float e = 0.01;
	float w2 = wave_at(u + e, UV.y, t);
	float amp2 = 0.11 * (0.25 + 0.75 * (u + e));
	VERTEX.z += w * amp * u * 1.6;
	VERTEX.y -= u * u * 0.07;
	float dz = (w2 * amp2 * (u + e) - w * amp * u) * 1.6 / (e * flag_width);
	NORMAL = normalize(vec3(-dz, 0.12 * u, 1.0));
	v_fold = w;
}

void fragment() {
	// Swallowtail at the free end.
	float tail = UV.x - 0.80;
	if (tail > 0.0 && abs(UV.y - 0.5) < tail * 2.4) {
		discard;
	}
	vec3 col = team_color.rgb;
	float border = step(UV.y, 0.08) + step(0.92, UV.y) + step(UV.x, 0.05);
	float lozenge = abs(UV.x - 0.40) + abs(UV.y - 0.5) * 0.8;
	float emblem = step(lozenge, 0.15) * step(0.11, lozenge) + step(lozenge, 0.055);
	col = mix(col, trim_color.rgb, clamp(border + emblem, 0.0, 1.0));
	// Weave and a darker hem so the cloth has body at play zoom.
	col *= 0.92 + 0.08 * sin(UV.y * 180.0) * sin(UV.x * 140.0);
	col *= 0.78 + 0.22 * smoothstep(-0.8, 0.8, v_fold);
	ALBEDO = col;
	ROUGHNESS = 0.82;
	METALLIC = (border + emblem) > 0.5 ? 0.35 : 0.0;
	BACKLIGHT = team_color.rgb * 0.45;
}
