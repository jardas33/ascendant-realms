shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled, fog_disabled;
// Capture zone on a ground quad covering the real 7.5 m capture radius: a
// carved rune band (two fine rings with runes between them), an inner ring
// with eight notches, a soft glow round the edge and a progress arc that
// fills the band clockwise in the contesting team's colour. Presentation
// only. (Plan 340: the old ring was a band of plain dashes.)

// Unclaimed shrines glow a soft Lume gold rather than stark white.
uniform vec4 owner_color : source_color = vec4(0.95, 0.78, 0.42, 1.0);
uniform vec4 contest_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float progress = 0.0;
uniform float owned = 0.0;

float line_at(float r, float at, float w) {
	return exp(-pow((r - at) / w, 2.0));
}

float hash(float n) {
	return fract(sin(n * 91.345) * 47453.5453);
}

// One rune in a cell: a stem plus one or two strokes picked by the hash.
float rune(vec2 q, float id) {
	float h1 = hash(id);
	float h2 = hash(id + 7.0);
	float w = 0.10;
	float g = 1.0 - smoothstep(w, w + 0.06, abs(q.x - (h1 - 0.5) * 0.4));
	g *= step(abs(q.y), 0.42);
	float diag = 1.0 - smoothstep(w, w + 0.06, abs(q.y - q.x * (h2 > 0.5 ? 1.0 : -1.0) - (h1 - 0.5) * 0.3));
	diag *= step(abs(q.x), 0.38) * step(abs(q.y), 0.42);
	float bar = (1.0 - smoothstep(w, w + 0.06, abs(q.y - (h2 - 0.5) * 0.5))) * step(abs(q.x), 0.32) * step(0.55, h1);
	return max(g, max(diag, bar));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float r = length(p);
	float a = atan(p.x, -p.y);                 // 0 at north, clockwise
	float a01 = fract(a / TAU + 1.0);
	// The rune band between two fine rings, turning very slowly.
	float band_in = 0.86;
	float band_out = 0.95;
	float rings = line_at(r, band_out, 0.009) + line_at(r, band_in, 0.008) * 0.9;
	float cells = 40.0;
	float turn = fract(a01 - TIME * 0.004);
	float cell = floor(turn * cells);
	vec2 q = vec2(fract(turn * cells) - 0.5, (r - (band_in + band_out) * 0.5) / ((band_out - band_in) * 0.5));
	q.x *= 1.35;
	float runes = rune(q * 1.25, cell) * step(abs(q.y), 0.9) * 0.85;
	// Inner ring with eight diamond notches.
	float inner = line_at(r, 0.52, 0.010) * 0.75;
	float spoke = fract(a01 * 8.0 + 0.5) - 0.5;
	float notch = (1.0 - smoothstep(0.0, 0.035, abs(spoke) + abs(r - 0.52) * 0.8)) * 0.9;
	// Soft light spilling inward from the band and a faint floor wash.
	float glow = smoothstep(0.6, band_in, r) * (1.0 - smoothstep(band_out, 1.0, r)) * 0.16;
	float wash = (1.0 - smoothstep(0.1, 0.9, r)) * mix(0.03, 0.10, owned);
	float v = rings + runes + inner + notch + glow + wash;
	// Progress arc: the band itself fills in the contesting colour.
	float arc_band = smoothstep(band_in - 0.02, band_in, r) * (1.0 - smoothstep(band_out, band_out + 0.02, r));
	float arc = arc_band * step(a01, progress) * (1.0 - owned);
	vec3 col = mix(owner_color.rgb, contest_color.rgb, arc);
	v = max(v, arc * 0.55 + runes * arc);
	float pulse = 0.88 + 0.12 * sin(TIME * 1.6);
	ALBEDO = col * (1.05 + 0.6 * owned) * pulse;
	ALPHA = clamp(v * mix(0.8, 1.0, max(owned, arc)), 0.0, 0.92) * (1.0 - smoothstep(0.985, 1.0, r));
}
