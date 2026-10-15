shader_type spatial;
// Plan 245: the ground wave of a spell. A thin bright front runs outward
// with a ring of runes just behind it and a soft wash of light trailing
// inside, all thinning out as the wave spends itself. Drawn on a flat quad
// (UV 0..1 across the wave's full reach); `progress` runs 0 to 1.
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;

uniform vec4 tint : source_color = vec4(1.0, 0.85, 0.4, 1.0);
uniform float progress = 0.0;
uniform float seed = 0.0;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	float ang = atan(p.y, p.x);
	float front = mix(0.12, 0.96, 1.0 - pow(1.0 - progress, 2.2));
	float life = pow(1.0 - progress, 1.3);
	// The front: a thin hot line with a softer halo.
	float d = r - front;
	float line = exp(-pow(d / 0.012, 2.0));
	float halo = exp(-pow(d / 0.05, 2.0)) * 0.45;
	// Ripples of the front flicker along its length.
	float flicker = 0.78 + 0.22 * sin(ang * 9.0 + seed + TIME * 5.0) * sin(ang * 4.0 - seed * 1.7 - TIME * 3.0);
	// A ring of runes riding just inside the front: short dashes.
	float rune_r = front - 0.07;
	float dash = step(0.42, fract((ang + seed) * 34.0 / 6.2831853 + TIME * 0.4));
	float runes = exp(-pow((r - rune_r) / 0.01, 2.0)) * dash * 0.75;
	// A wash of light trailing inside the front, strongest just behind it.
	float wash = smoothstep(front - 0.42, front, r) * step(r, front) * 0.3;
	float a = (line * flicker + halo + runes + wash) * life;
	a *= smoothstep(1.0, 0.94, r);
	vec3 c = mix(tint.rgb, vec3(1.0), line * 0.45);
	ALBEDO = c * a;
	ALPHA = clamp(a, 0.0, 1.0);
}
