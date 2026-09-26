shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
// Capture zone on a ground quad covering the real 7.5 m capture radius: a
// rune circle of dashes, an inner ring, and a progress arc that fills
// clockwise in the contesting team's colour. Presentation only.

uniform vec4 owner_color : source_color = vec4(0.85, 0.85, 0.85, 1.0);
uniform vec4 contest_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float progress = 0.0;
uniform float owned = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float r = length(p);
	float a = atan(p.x, -p.y);                 // 0 at north, clockwise
	float a01 = fract(a / TAU + 1.0);
	// Outer rune circle: dashes that drift slowly.
	float dash = step(0.45, fract(a01 * 36.0 - TIME * 0.05));
	float outer = exp(-pow((r - 0.93) / 0.02, 2.0)) * dash;
	float inner = exp(-pow((r - 0.5) / 0.015, 2.0)) * 0.7;
	float wash = (1.0 - smoothstep(0.2, 0.95, r)) * mix(0.05, 0.14, owned);
	vec3 base = owner_color.rgb;
	float v = outer + inner + wash;
	// Progress arc between the two rings.
	float arc_band = smoothstep(0.66, 0.7, r) * (1.0 - smoothstep(0.8, 0.84, r));
	float arc = arc_band * step(a01, progress) * (1.0 - owned);
	vec3 col = mix(base, contest_color.rgb, arc);
	v = max(v, arc * 0.85);
	float pulse = 0.85 + 0.15 * sin(TIME * 2.0);
	ALBEDO = col * (1.2 + 0.6 * owned) * pulse;
	ALPHA = clamp(v, 0.0, 0.9);
}
