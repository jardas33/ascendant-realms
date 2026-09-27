shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
// Dashed trail from a building to its rally point; dashes drift toward the
// flag. UV.x runs along the path (in metres via path_length).
uniform vec4 path_color : source_color = vec4(1.0, 0.8, 0.35, 1.0);
uniform float path_length = 10.0;

void fragment() {
	float along = UV.x * path_length;
	float dash = step(0.5, fract(along * 0.8 - TIME * 1.2));
	float edge = 1.0 - smoothstep(0.25, 0.5, abs(UV.y - 0.5));
	float ends = smoothstep(0.0, 1.5, along) * smoothstep(0.0, 1.0, path_length - along);
	float v = dash * edge * ends * 0.8;
	ALBEDO = path_color.rgb * v;
	ALPHA = v;
}
