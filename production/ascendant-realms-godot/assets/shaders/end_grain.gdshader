shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
// Cut ends of felled logs. The painted texture's rings were orange, so the
// stacks read as plastic; its brightness now picks between a dark ring and
// pale fresh wood. Reads only UV, so joined stacks stay correct.

uniform sampler2D grain_tex : source_color, filter_linear_mipmap;
uniform vec3 ring_color : source_color = vec3(0.42, 0.29, 0.17);
uniform vec3 wood_color : source_color = vec3(0.72, 0.58, 0.39);

void fragment() {
	vec3 t = texture(grain_tex, UV).rgb;
	// The texture is read as linear; back to its painted brightness, where
	// the rings sit near 0.28 and the wood between them near 0.40.
	float l = pow(max(dot(t, vec3(0.30, 0.59, 0.11)), 0.0), 1.0 / 2.2);
	ALBEDO = mix(ring_color, wood_color, smoothstep(0.24, 0.40, l));
	ROUGHNESS = 0.9;
	SPECULAR = 0.2;
}
