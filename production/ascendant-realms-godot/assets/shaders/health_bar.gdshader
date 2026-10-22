shader_type spatial;
// Plan 408: one framed, camera-facing health bar per unit. Values are per
// instance, so every unit shares a single material.
render_mode unshaded, cull_disabled, depth_test_disabled, shadows_disabled, blend_mix;

instance uniform float ratio = 1.0;
instance uniform vec4 fill_color : source_color = vec4(0.3, 0.82, 0.38, 1.0);
instance uniform vec4 back_tint : source_color = vec4(0.03, 0.04, 0.04, 0.9);

const float ASPECT = 6.5;

void vertex() {
	// Billboard that keeps the node's scale.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		INV_VIEW_MATRIX[0] * length(MODEL_MATRIX[0].xyz),
		INV_VIEW_MATRIX[1] * length(MODEL_MATRIX[1].xyz),
		INV_VIEW_MATRIX[2] * length(MODEL_MATRIX[2].xyz),
		MODEL_MATRIX[3]);
}

void fragment() {
	vec2 p = UV;
	float bx = 0.016;
	float by = bx * ASPECT;
	vec2 q = (p - vec2(bx, by)) / (vec2(1.0) - 2.0 * vec2(bx, by));
	bool inside = q.x >= 0.0 && q.x <= 1.0 && q.y >= 0.0 && q.y <= 1.0;
	vec3 col;
	float a = 0.96;
	if (!inside) {
		// Bronze rim, lit from above.
		col = mix(vec3(0.62, 0.48, 0.26), vec3(0.24, 0.17, 0.09), p.y);
	} else if (q.x <= ratio) {
		col = fill_color.rgb * (1.18 - 0.5 * q.y);
		col += vec3(0.16) * (1.0 - smoothstep(0.0, 0.28, q.y));
		// Bright leading edge.
		col = mix(col, vec3(1.0, 0.97, 0.88), 0.45 * (1.0 - smoothstep(0.0, 0.012, ratio - q.x)) * step(q.x, 0.999));
		// Quarter ticks.
		float t = abs(fract(q.x * 4.0 + 0.5) - 0.5) / 4.0;
		col *= mix(0.55, 1.0, smoothstep(0.002, 0.005, t));
	} else {
		col = back_tint.rgb * (1.25 - 0.5 * q.y);
		a = back_tint.a;
	}
	// Thin dark line just inside the rim.
	float edge = min(min(q.x, 1.0 - q.x) * ASPECT, min(q.y, 1.0 - q.y));
	if (inside) col *= mix(0.45, 1.0, smoothstep(0.0, 0.09, edge));
	ALBEDO = col;
	ALPHA = a;
}
