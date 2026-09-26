shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
// Selection marker drawn on a ground quad: a soft glowing ring, four
// bracket arcs that turn slowly around it, and a faint inner wash. UV is the
// quad's 0..1 square. Presentation only.

uniform vec4 ring_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform float energy = 1.6;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float r = length(p);
	float a = atan(p.y, p.x) + TIME * 0.6;
	float ring = exp(-pow((r - 0.72) / 0.035, 2.0));
	float glow = exp(-pow((r - 0.72) / 0.12, 2.0)) * 0.35;
	// Four brackets outside the ring, each a quarter-arc with a gap.
	float seg = fract(a / (PI * 0.5));
	float bracket = smoothstep(0.08, 0.12, seg) * (1.0 - smoothstep(0.38, 0.42, seg));
	bracket *= exp(-pow((r - 0.88) / 0.03, 2.0));
	float wash = (1.0 - smoothstep(0.0, 0.72, r)) * 0.08;
	float v = ring + glow + bracket * 0.9 + wash;
	ALBEDO = ring_color.rgb * energy * v;
	ALPHA = clamp(v, 0.0, 1.0);
}
