shader_type spatial;
// Plan 245: a column of Lume light. Soft at its edges (it was a hard-edged
// tube), brightest along its core, fading out toward the sky, with streaks
// of light climbing it.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 tint : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float strength = 0.0;

void fragment() {
	// Facing the camera: the core of the column. Edge-on: its soft rim.
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float core = pow(facing, 2.2);
	// UV.y runs down the tube; fade toward the top and a little at the foot.
	float up = 1.0 - UV.y;
	float vfade = (1.0 - smoothstep(0.35, 1.0, up)) * smoothstep(0.0, 0.06, up);
	// Streaks climbing the column.
	float streak = 0.65 + 0.35 * sin(UV.x * 6.2831853 * 7.0 + sin(UV.x * 31.0) * 2.0) * sin(UV.y * 22.0 + TIME * 7.0);
	float a = core * vfade * streak * strength;
	vec3 c = mix(tint.rgb, vec3(1.0), core * 0.35);
	ALBEDO = c * a;
	ALPHA = clamp(a, 0.0, 1.0);
}
