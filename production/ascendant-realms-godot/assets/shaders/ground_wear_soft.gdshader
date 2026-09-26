shader_type spatial;
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_burley, shadows_disabled;
// Worn-earth patches and tracks laid on the battlefield. The dirt is sampled
// in world space (no stretching), and the edges fade out along a noisy line
// so a track or yard blends into the grass instead of reading as a
// translucent coloured panel. Ribbons fade across UV.x; radial patches fade
// from their centre.

uniform sampler2D dirt_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(0.62, 0.52, 0.40, 0.6);
uniform bool radial = false;
uniform float world_tile = 0.22;

varying vec3 wpos;

float h21(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)) + ivec2(65536));
	uint h = (q.x * 1597334677u) ^ (q.y * 3812015801u);
	h = (h ^ (h >> 16u)) * 2246822519u;
	h ^= h >> 13u;
	return float(h) * (1.0 / 4294967295.0);
}

float vn(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1, 0)), f.x), mix(h21(i + vec2(0, 1)), h21(i + vec2(1, 1)), f.x), f.y);
}

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float edge = radial ? length(UV - vec2(0.5)) * 2.0 : abs(UV.x - 0.5) * 2.0;
	edge += (vn(wpos.xz * 0.9) - 0.5) * 0.35 + (vn(wpos.xz * 3.1) - 0.5) * 0.12;
	float fade = 1.0 - smoothstep(radial ? 0.4 : 0.45, radial ? 0.85 : 0.95, edge);
	vec3 dirt = texture(dirt_tex, wpos.xz * world_tile).rgb;
	ALBEDO = dirt * tint.rgb * 1.25;
	ALPHA = clamp(fade * tint.a * 1.1, 0.0, 1.0);
	ROUGHNESS = 0.96;
}
