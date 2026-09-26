shader_type spatial;
render_mode cull_disabled, diffuse_burley;
// Hanging team banner: team-coloured cloth with a gilt border, a gilt
// lozenge emblem and a swallowtail hem, rippling in the wind. UV.y runs from
// the crossbar (0) to the free hem (1). Presentation only.

instance uniform vec4 team_color : source_color = vec4(0.22, 0.42, 0.9, 1.0);
uniform vec4 trim_color : source_color = vec4(0.86, 0.68, 0.32, 1.0);

varying float v_fold;

void vertex() {
	float free = UV.y;
	vec3 origin = MODEL_MATRIX[3].xyz;
	float t = TIME * 2.2 + origin.x * 0.37 + origin.z * 0.23;
	float wave = sin(t + UV.y * 4.2 - UV.x * 1.3) + 0.35 * sin(t * 1.9 + UV.y * 8.0 + UV.x * 2.0);
	VERTEX.z += wave * 0.09 * free;
	VERTEX.x += sin(t * 0.7) * 0.05 * free * free;
	v_fold = wave;
}

void fragment() {
	// Swallowtail hem.
	float tail = UV.y - 0.84;
	if (tail > 0.0 && abs(UV.x - 0.5) < tail * 3.2) {
		discard;
	}
	vec3 col = team_color.rgb;
	float border = step(UV.x, 0.07) + step(0.93, UV.x) + step(UV.y, 0.05);
	float lozenge = abs(UV.x - 0.5) * 1.25 + abs(UV.y - 0.42);
	float emblem = step(lozenge, 0.17) * step(0.12, lozenge) + step(lozenge, 0.06);
	col = mix(col, trim_color.rgb, clamp(border + emblem, 0.0, 1.0));
	col *= 0.82 + 0.18 * v_fold;
	ALBEDO = col;
	ROUGHNESS = 0.85;
	BACKLIGHT = team_color.rgb * 0.35;
}
