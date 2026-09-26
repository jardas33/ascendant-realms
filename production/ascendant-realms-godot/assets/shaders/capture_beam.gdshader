shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
// Soft column of light over a capture site: bright at the base, fading
// upward, soft at the sides (by view angle), with slow rising shimmer.

uniform vec4 beam_color : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float strength = 0.6;

void fragment() {
	float up = UV.y;                             // 0 top .. 1 bottom on CylinderMesh
	float height_fade = smoothstep(0.0, 0.85, up);
	float side = pow(clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0), 2.0);
	float shimmer = 0.75 + 0.25 * sin(up * 30.0 + TIME * 3.0);
	float v = height_fade * side * shimmer * strength;
	ALBEDO = beam_color.rgb * v;
	ALPHA = v;
}
