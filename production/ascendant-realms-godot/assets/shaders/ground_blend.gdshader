shader_type spatial;
render_mode cull_back, diffuse_burley, specular_disabled;
// GLES3 / web (GL Compatibility) safe: self-contained, no #include, no screen/
// depth texture reads. Blends grass / meadow / dry-earth / rock across a flat
// ground plane using cheap procedural value-noise, and burns worn dirt roads
// between the marked path segments so the battlefield reads as living terrain
// instead of one uniform lawn.

uniform sampler2D tex_grass : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_meadow : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_dirt : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_rock : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_snow : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D tex_volcanic : source_color, filter_linear_mipmap, repeat_enable;

uniform float tile_grass = 0.14;
uniform float tile_dirt = 0.10;
uniform float tile_rock = 0.09;
uniform float tile_snow = 0.016;
uniform float tile_volcanic = 0.032;
uniform float volcanic_surface = 0.0;
// Plan 372: 1 on a hill wearing the ground material. Its relief bends the
// hill's own normal instead of a flat one, so the hill keeps its shading.
uniform float mesh_normals = 0.0;
// Sand and bare earth (desert, badlands): the grass layers are replaced by
// this colour, broken by broad dune swells, wind ripples (sand_ripple) and
// the grain of the dirt texture. 0 keeps the grass.
uniform float sand_surface = 0.0;
uniform vec3 sand_color : source_color = vec3(0.60, 0.58, 0.56);
uniform float sand_ripple = 1.0;
// Bog (wetland): sodden dark earth in broad patches, with standing pools of
// still water at their hearts that catch the sky. Kept off the roads and
// away from the starting seats. 0 none.
uniform float bog_surface = 0.0;
// Ashen maps: wind-laid drifts of pale ash and charred burn scars.
uniform float ash_surface = 0.0;

// R19 tactical readability grade.  These controls deliberately change only
// the material presentation of the existing flat ground mesh; the playable
// plane, navmesh, paths, and object positions remain untouched.
uniform vec3 ground_base : source_color = vec3(0.34, 0.42, 0.28);
uniform vec3 road_base : source_color = vec3(0.48, 0.38, 0.25);
uniform vec3 road_edge_color : source_color = vec3(0.22, 0.25, 0.18);
uniform float surface_detail = 0.34;
uniform float surface_macro = 0.14;
uniform float road_detail = 0.42;
uniform float road_edge_strength = 0.16;
uniform float surface_saturation = 0.9;
uniform vec3 snow_shadow_color : source_color = vec3(0.62, 0.69, 0.80);
uniform vec3 snow_highlight_color : source_color = vec3(0.90, 0.95, 1.0);
uniform float snow_underlay_strength = 0.24;
uniform float snow_variation_strength = 0.78;

// Path segments in world XZ: xy = start, zw = end. Up to 8 roads.
uniform vec4 paths[8];
uniform int path_count = 0;
uniform float path_width = 6.5;
uniform float path_feather = 5.0;
// Plan 399: packed, trodden earth round each building (x, z, radius, strength).
uniform vec4 pads[64];
uniform int pad_count = 0;

// biome grade
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float dirt_bias = 0.0;
uniform float rock_bias = 0.0;
uniform float snow_amt = 0.0;

// Painterly terrain: large colour fields (lush, sun-dried, mossy), texture
// anti-tiling, and lit relief. Relief only bends the shading normal; the
// playable plane, navmesh and every object height stay exactly flat.
uniform vec3 field_lush : source_color = vec3(0.26, 0.36, 0.16);
uniform vec3 field_dry : source_color = vec3(0.52, 0.48, 0.26);
uniform vec3 field_moss : source_color = vec3(0.18, 0.25, 0.14);
uniform float field_strength = 0.0;
uniform float cloud_shadow_strength = 0.2;
uniform float relief_strength = 0.0;
uniform float relief_scale = 0.018;
// Half the width of the battlefield in metres (0 = not given). The ground
// beyond it is drawn darker and greyer: it looked as walkable as the field,
// and an army sent there stopped at a line nobody could see.
uniform float field_half = 0.0;
// The seats (x, z). Round each the ground keeps its light even past the
// edge: on maps whose seats stand at the edge, the cottages behind a keep
// are beyond it, and the shade ran through the player's own village.
uniform vec2 field_seats[6];
uniform int field_seat_count = 0;
// Faction ground: scorched ash yards around Vorthak holdfasts. xy = centre,
// z = radius, w = strength. Blended in the ground itself so the edge is a
// noisy burn fade, not a pasted decal.
uniform vec4 scorch_zones[4];
uniform int scorch_count = 0;
// River ford: x = centre z, y = half width, z = strength. Paints wet banks
// and a pebbled bed under the shallow crossing water.
uniform vec3 ford = vec3(0.0, 0.0, 0.0);

varying vec3 world_pos;

// --- cheap value noise ------------------------------------------------------
// Integer hash of a lattice point. The old fract(p * 123.34) hash lost
// precision on the GPU, so neighbouring cells disagreed about their shared
// corners and the noise showed hard square seams across the ground.
float hash21(vec2 p) {
	uvec2 q = uvec2(ivec2(floor(p)) + ivec2(65536));
	uint h = (q.x * 1597334677u) ^ (q.y * 3812015801u);
	h = (h ^ (h >> 16u)) * 2246822519u;
	h ^= h >> 13u;
	h *= 3266489917u;
	h ^= h >> 16u;
	return float(h) * (1.0 / 4294967295.0);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		v += amp * vnoise(p);
		p *= 2.03;
		amp *= 0.5;
	}
	return v;
}

// Two-octave fbm for the broad, low-frequency fields (tile blend, meadow
// patches, colour fields, macro shading, cloud shadows): their upper octaves
// were sub-texel detail at these scales and cost most of the ground's GPU time.
float fbm2(vec2 p) {
	return 0.5 * vnoise(p) + 0.25 * vnoise(p * 2.03) + 0.1875;
}

// Broad cloud shadows drifting across the battlefield (shared by the ground
// and grass shaders so both darken together).
float cloud_shadow(vec2 xz, float t) {
	vec2 p = xz * 0.011 + vec2(t * 0.022, t * 0.009);
	float n = fbm2(p) * 0.7 + fbm2(p * 2.3 + 4.0) * 0.3;
	return smoothstep(0.5, 0.68, n);
}

// Cellular crack pattern: distance to the nearest cell border (0 on a crack).
vec2 cell_point(vec2 i) {
	return vec2(hash21(i), hash21(i + vec2(17.0, 31.0)));
}

float crack_dist(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	float d2 = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			float d = length(g + cell_point(i + g) - f);
			if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
		}
	}
	return d2 - d1;
}

// The cell whose point lies nearest p (the plate p lies on).
vec2 crack_cell(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float d1 = 8.0;
	vec2 best = i;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			float d = length(g + cell_point(i + g) - f);
			if (d < d1) { d1 = d; best = i + g; }
		}
	}
	return best;
}

// Mirror an authored tile at each edge so no source-image seam appears on
// large volcanic fields; the second rotated sample hides the reflection.
vec2 mirrored_uv(vec2 uv) {
	return 1.0 - abs(fract(uv) * 2.0 - 1.0);
}

// distance from point p to segment a-b (all in XZ)
float seg_dist(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 0.0001), 0.0, 1.0);
	return length(p - (a + ab * t));
}

// Smooth rolling height: rotated, domain-warped sine swells. Unlike value
// noise its gradient has no cell creases, so lit relief shows no grid.
float swell(vec2 p) {
	vec2 q = p + 0.35 * vec2(sin(p.y * 0.61), sin(p.x * 0.53));
	float h = sin(dot(q, vec2(0.83, 0.56))) * 0.5;
	h += sin(dot(q, vec2(-0.47, 0.88)) * 1.73 + 1.3) * 0.3;
	h += sin(dot(q, vec2(0.21, -0.98)) * 3.11 + 4.1) * 0.2;
	return h;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Plan 385: a warped noise field whose zero line winds like a dry wash.
float wash_field(vec2 wxz) {
	vec2 wq = wxz * 0.012 + (vec2(fbm(wxz * 0.02 + 5.0), fbm(wxz * 0.02 + 11.0)) - 0.5) * 1.3;
	return fbm2(wq + 140.0) * 2.0 - 1.0;
}

void fragment() {
	vec2 wxz = world_pos.xz;

	// two grass variants blended by a big soft noise = meadow patches
	// Use a broad sample and blend it into a calm biome base.  The former
	// high-frequency full-strength samples made the wide playable field read
	// as visual noise and reduced unit/ground separation at normal zoom.
	// Anti-tiling: each layer blends a second, rotated and rescaled sample,
	// selected by low-frequency noise, so the flower tile never repeats in
	// a visible grid across the battlefield.
	float tile_mix = smoothstep(0.3, 0.7, fbm2(wxz * 0.021 + 7.0));
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	// A second turn for the mirrored tiles (volcanic rock, snow). Laid
	// square to the map at a fixed mix, their mirror lines drew a lattice of
	// diamonds across the field; each sample is turned a different way and
	// the mix wanders.
	mat2 turn = mat2(vec2(0.9553, 0.2955), vec2(-0.2955, 0.9553));
	vec3 ground;
	if (volcanic_surface > 0.5) {
		vec3 basalt_a = texture(tex_volcanic, mirrored_uv(turn * wxz * tile_volcanic)).rgb;
		vec3 basalt_b = texture(tex_volcanic, mirrored_uv(rot * wxz * tile_volcanic * 0.73 + 0.37)).rgb;
		ground = mix(basalt_a, basalt_b, mix(0.15, 0.65, tile_mix));
	} else {
		vec3 grass_a = mix(texture(tex_grass, wxz * tile_grass * 0.42).rgb,
			texture(tex_grass, rot * wxz * tile_grass * 0.29 + 0.37).rgb, tile_mix);
		vec3 grass_b = mix(texture(tex_meadow, wxz * tile_grass * 0.35).rgb,
			texture(tex_meadow, rot * wxz * tile_grass * 0.23 + 0.61).rgb, 1.0 - tile_mix);
		float meadow_m = smoothstep(0.35, 0.65, fbm2(wxz * 0.012));
		ground = mix(grass_a, grass_b, meadow_m);
	}
	ground = mix(ground_base, ground, clamp(surface_detail, 0.0, 1.0));
	if (sand_surface > 0.5) {
		// The grass textures under a desert grade still read as an olive
		// lawn with grass in it. Sand country has no turf at all.
		float swell = fbm2(wxz * 0.009 + 9.0);
		float bend = fbm(wxz * 0.035 + 4.0) * 7.0;
		float ripple = sin(dot(wxz, vec2(0.83, 0.55)) * 2.2 + bend) * 0.5 + 0.5;
		ripple = mix(ripple, sin(dot(wxz, vec2(0.6, 0.8)) * 3.1 + bend * 1.3) * 0.5 + 0.5, 0.35);
		float grain = dot(texture(tex_dirt, wxz * tile_dirt * 0.8).rgb, vec3(0.333));
		float lee = smoothstep(0.35, 0.7, fbm2(wxz * 0.021 + 31.0));
		ground = sand_color * mix(0.84, 1.07, swell) * mix(1.0, mix(0.92, 1.05, ripple), clamp(sand_ripple, 0.0, 1.0))
			* mix(0.9, 1.08, smoothstep(0.2, 0.6, grain)) * mix(1.0, 0.93, lee);
		if (sand_ripple > 0.5) {
			// Plan 389: open desert read as one flat mustard sheet. Dunes now
			// have a sunlit and a shaded face, pale crests over warmer hollows,
			// and wind ripples with a sharp crest and a dark lee that come and
			// go in patches instead of covering the field evenly.
			float dh = 5.0;
			float dune_x = fbm2((wxz + vec2(dh, 0.0)) * 0.009 + 9.0) - fbm2((wxz - vec2(dh, 0.0)) * 0.009 + 9.0);
			float dune_z = fbm2((wxz + vec2(0.0, dh)) * 0.009 + 9.0) - fbm2((wxz - vec2(0.0, dh)) * 0.009 + 9.0);
			float face = clamp(dot(vec2(dune_x, dune_z), vec2(-0.6, -0.8)) * 9.0, -1.0, 1.0);
			ground *= 1.0 + face * 0.22;
			ground = mix(ground * vec3(1.06, 0.95, 0.84), ground * vec3(1.02, 1.01, 1.0), smoothstep(0.3, 0.75, swell));
			float phase = fract(dot(wxz, vec2(0.83, 0.55)) * 0.42 + bend * 0.16);
			float saw = smoothstep(0.0, 0.78, phase) * (1.0 - smoothstep(0.78, 1.0, phase));
			float patchy = smoothstep(0.35, 0.65, fbm2(wxz * 0.03 + 17.0)) * (1.0 - lee * 0.6);
			ground *= mix(1.0, mix(0.88, 1.04, saw), patchy);
		}
	}

	// dry-earth clearings (dirt_bias pushes toward a sandy/parched biome)
	vec3 dirt = volcanic_surface > 0.5
		? texture(tex_volcanic, mirrored_uv(wxz * tile_volcanic * 0.62 + 0.23)).rgb * vec3(1.28, 1.04, 0.86)
		: mix(texture(tex_dirt, wxz * tile_dirt * 0.55).rgb, texture(tex_dirt, rot * wxz * tile_dirt * 0.47 + 0.29).rgb, tile_mix);
	float dirt_m = clamp(smoothstep(0.66, 0.82, fbm(wxz * 0.017 + 60.0)) + dirt_bias, 0.0, 1.0);
	ground = mix(ground, dirt, dirt_m * 0.85);

	// scattered rocky ground where a second noise field peaks (rock_bias -> stony biome)
	// (Drawn at about a metre and a half a stone. At half this scale each
	// stone was three metres wide, wider than a soldier is tall, and a rocky
	// patch read as a square paved with giant flags.)
	vec3 rock = volcanic_surface > 0.5
		? texture(tex_volcanic, mirrored_uv(rot * wxz * tile_volcanic * 1.09 + 0.61)).rgb * vec3(0.89, 0.94, 1.02)
		: mix(texture(tex_rock, wxz * tile_rock).rgb, texture(tex_rock, rot * wxz * tile_rock * 0.81 + 0.43).rgb, tile_mix);
	float rock_m = clamp(smoothstep(0.62, 0.80, fbm(wxz * 0.02 + 21.0)) + rock_bias, 0.0, 1.0);
	ground = mix(ground, rock, rock_m);
	// Plan 364: on the badlands (rock_bias high) one flagstone pattern of
	// cracked earth covered the whole field like paving. Broad hard-pan
	// patches now smooth the cracks away, the plates shrink and grow from
	// place to place, and the earth drifts between ochre and rust.
	if (sand_surface > 0.5 && sand_ripple < 0.5) {
		float pan = smoothstep(0.50, 0.70, fbm2(wxz * 0.013 + 44.0));
		vec3 small_plates = mix(texture(tex_rock, rot * wxz * tile_rock * 1.7 + 0.13).rgb, texture(tex_rock, turn * wxz * tile_rock * 2.1 + 0.71).rgb, tile_mix);
		float fine = smoothstep(0.45, 0.7, fbm2(wxz * 0.019 + 63.0)) * (1.0 - pan);
		ground = mix(ground, mix(ground, small_plates, rock_m), fine);
		float gl = dot(ground, vec3(0.333));
		vec3 hardpan = sand_color / max(dot(sand_color, vec3(0.333)), 0.05) * mix(gl, 0.42, 0.55) * mix(0.95, 1.05, fbm(wxz * 0.11 + 8.0));
		ground = mix(ground, hardpan, pan * 0.6);
		// Darker sun-baked and paler dusty stretches give the field depth.
		ground *= mix(0.86, 1.08, smoothstep(0.25, 0.75, fbm2(wxz * 0.021 + 17.0)));
		ground *= mix(vec3(1.07, 0.99, 0.88), vec3(0.93, 0.95, 1.0), smoothstep(0.3, 0.7, fbm2(wxz * 0.0075 + 90.0)));
		// Plan 385: dry washes wind across the field, pale sandy beds between
		// darker cut banks, and gravel lies strewn on the open ground. At play
		// height the field read as one flat sheet of orange.
		float wf = wash_field(wxz);
		// Distance to the wash's centre line in metres, from the field's slope,
		// so beds and banks keep their width where the noise runs flat.
		vec2 slope = vec2(wash_field(wxz + vec2(0.6, 0.0)) - wf, wash_field(wxz + vec2(0.0, 0.6)) - wf) / 0.6;
		float dist = abs(wf) / max(length(slope), 0.002);
		float reach = smoothstep(0.45, 0.68, fbm2(wxz * 0.006 + 71.0));
		float bed_w = mix(0.6, 2.2, fbm(wxz * 0.02 + 23.0));
		float bed = (1.0 - smoothstep(bed_w - 0.5, bed_w + 0.3, dist)) * reach;
		float bank = smoothstep(bed_w - 0.2, bed_w + 0.4, dist) * (1.0 - smoothstep(bed_w + 0.6, bed_w + 2.0, dist)) * reach;
		vec3 wash_sand = sand_color * vec3(1.16, 1.10, 1.02) * mix(0.92, 1.05, vnoise(wxz * 1.7 + 3.0));
		ground = mix(ground, ground * vec3(0.70, 0.64, 0.62), bank * 0.45);
		ground = mix(ground, wash_sand, bed * 0.6);
		float stones = step(0.86, vnoise(wxz * 2.6 + 31.0)) * smoothstep(0.4, 0.7, fbm(wxz * 0.05 + 37.0)) * (1.0 - bed);
		ground = mix(ground, ground * mix(0.55, 1.35, vnoise(wxz * 6.0 + 1.0)), stones * 0.6);
	}

	// worn roads between the path segments
	float pd = 1e9;
	for (int i = 0; i < path_count; i++) {
		pd = min(pd, seg_dist(wxz, paths[i].xy, paths[i].zw));
	}
	// wobble the road edge with noise so it isn't a clean stripe
	float wob = (fbm(wxz * 0.08) - 0.5) * 3.0;
	float road = 1.0 - smoothstep(path_width - path_feather, path_width + wob, pd);
	vec3 road_col = mix(road_base, volcanic_surface > 0.5 ? dirt : texture(tex_dirt, wxz * tile_dirt * 0.62).rgb, clamp(road_detail, 0.0, 1.0));
	ground = mix(ground, road_col, clamp(road, 0.0, 1.0));
	// Plan 351: a road was one soft band of colour, a pale smear across the
	// field. Now it is worn: two wheel ruts that come and go, a lighter crown
	// between them and gravel strewn along it.
	float rm = clamp(road, 0.0, 1.0);
	float rut_wob = (fbm(wxz * 0.21 + 9.0) - 0.5) * 0.6;
	float rut = (1.0 - smoothstep(0.22, 0.6, abs(pd - 1.9 + rut_wob))) * smoothstep(0.3, 0.55, fbm(wxz * 0.07 + 13.0));
	float crown = 1.0 - smoothstep(0.2, 1.4, pd);
	float gravel = step(0.80, vnoise(wxz * 3.3)) * step(0.42, vnoise(wxz * 0.6 + 5.0)) * (1.0 - smoothstep(path_width - 2.5, path_width, pd));
	ground = mix(ground, road_col * 0.64, rut * 0.55 * rm);
	ground = mix(ground, road_col * 1.10, crown * 0.16 * rm);
	ground = mix(ground, road_col * mix(0.68, 1.32, vnoise(wxz * 5.0 + 2.0)), gravel * 0.55 * rm);
	// A low-contrast worn edge makes routes legible without creating a
	// gameplay-zone outline or a floating strip.
	float road_edge = smoothstep(path_width + 0.3, path_width + 2.8, pd) * (1.0 - smoothstep(path_width + 2.8, path_width + 4.0, pd));
	ground = mix(ground, road_edge_color, clamp(road_edge * road_edge_strength, 0.0, 1.0));

	// Plan 399: a building stood straight on clean lawn, as if dropped there.
	// Feet and carts wear the ground round it to packed earth, worn most at
	// the walls, broken into patches of surviving grass towards the edge.
	float pad = 0.0;
	if (pad_count > 0) {
		float pad_wob = (fbm(wxz * 0.12 + 7.0) - 0.5) * 0.36;
		for (int i = 0; i < pad_count; i++) {
			float d = length(wxz - pads[i].xy) / pads[i].z;
			pad = max(pad, (1.0 - smoothstep(0.68, 1.0, d + pad_wob)) * pads[i].w);
		}
		pad *= mix(0.7, 1.0, smoothstep(0.32, 0.68, fbm(wxz * 0.33 + 19.0)));
		vec3 trod = road_col * vec3(0.84, 0.82, 0.80) * mix(0.86, 1.08, vnoise(wxz * 2.2 + 4.0));
		ground = mix(ground, trod, clamp(pad, 0.0, 1.0));
	}

	// Painterly colour fields: broad swathes of lush, sun-dried and mossy
	// turf, multiplied through the texture so detail survives.
	float f1 = fbm2(wxz * 0.0065 + 3.0);
	float f2 = fbm2(wxz * 0.011 + 17.0);
	vec3 field = mix(field_lush, field_dry, smoothstep(0.45, 0.75, f1));
	field = mix(field, field_moss, smoothstep(0.55, 0.8, f2) * 0.8);
	float grass_share = (1.0 - dirt_m * 0.85) * (1.0 - rock_m) * (1.0 - clamp(road, 0.0, 1.0)) * (1.0 - pad);
	vec3 field_tone = ground * (field / max(dot(field_lush, vec3(0.333)), 0.05)) * 0.92;
	ground = mix(ground, field_tone, clamp(field_strength * grass_share, 0.0, 1.0));

	// gentle macro shading for depth
	float macro = (1.0 - surface_macro) + surface_macro * fbm2(wxz * 0.006 + 5.0);
	ground *= macro * tint;
	float luma = dot(ground, vec3(0.299, 0.587, 0.114));
	ground = mix(vec3(luma), ground, clamp(surface_saturation, 0.0, 1.0));

	// Snow keeps its identity while preserving truthful material structure.  The
	// former near-white blanket erased most macro/value separation at the normal
	// RTS camera distance; this grade layers existing ground response underneath
	// a theme-compatible snow range instead of painting fake geography.
	if (snow_amt > 0.001) {
		float snow_macro = fbm(wxz * 0.022 + 12.0);
		float snow_micro = fbm(wxz * 0.085 + 41.0);
		float snow_mask = snow_amt * (0.72 + 0.28 * snow_macro);
		float snow_value = smoothstep(0.20, 0.82, snow_macro);
		vec3 snow_surface = mix(snow_shadow_color, snow_highlight_color, snow_value);
		snow_surface *= mix(0.92, 1.04, snow_micro) * mix(1.0, 0.94, snow_variation_strength * (1.0 - snow_value));
		// Mirrored UVs keep the generated albedo continuous at tile boundaries;
		// broad procedural grade masks the mirrored repeat at gameplay scale.
		vec2 snow_uv = mirrored_uv(turn * wxz * tile_snow);
		vec2 snow_uv_detail = mirrored_uv(rot * wxz * tile_snow * 0.71 + vec2(0.31, 0.57));
		vec3 snow_albedo = mix(texture(tex_snow, snow_uv).rgb, texture(tex_snow, snow_uv_detail).rgb, mix(0.2, 0.8, tile_mix));
		// Broad drifts and scoured ground, a few hundred metres across: deep
		// drifts fill the texture's dark wind-scour marks with smooth snow,
		// while scoured stretches show more of the rock beneath. Without it
		// the one texture laid the same speckle over the whole field.
		float drift = smoothstep(0.36, 0.70, fbm(wxz * 0.0075 + 83.0));
		vec3 smooth_snow = snow_highlight_color * mix(0.92, 1.0, snow_micro);
		snow_albedo = mix(snow_albedo, mix(smooth_snow, snow_albedo, 0.32), drift * 0.75);
		snow_albedo *= mix(0.90, 1.0, drift);
		snow_surface = mix(snow_surface, snow_albedo, 0.87);
		snow_surface = mix(snow_surface, ground, clamp(snow_underlay_strength, 0.0, 0.7));
		ground = mix(ground, snow_surface, clamp(snow_mask * (1.0 - 0.48 * road), 0.0, 1.0));
	}

	if (ford.z > 0.0 && abs(wxz.y - ford.x) < ford.y * 1.7) {
		float edge_wobble = (fbm(vec2(wxz.x * 0.045, 7.0)) - 0.5) * 0.7 * ford.y + (fbm(vec2(wxz.x * 0.21, 3.0)) - 0.5) * 0.18 * ford.y;
		float dz = abs(wxz.y - ford.x) + edge_wobble;
		float bank = 1.0 - smoothstep(ford.y * 0.62, ford.y * 1.25, dz);
		vec3 wet = ground * 0.55 + vec3(0.03, 0.03, 0.02);
		// Wet, darkened bank soil; a soft sandy lip where the water meets it.
		vec3 sand = mix(ground, vec3(0.40, 0.36, 0.28), 0.55) * (0.8 + 0.35 * fbm(wxz * 0.3));
		float lip = smoothstep(ford.y * 0.72, ford.y * 0.9, dz) * (1.0 - smoothstep(ford.y * 0.95, ford.y * 1.2, dz));
		lip *= smoothstep(0.35, 0.65, fbm(wxz * 0.18 + 21.0));
		vec3 bed = mix(wet, sand, lip * 0.6);
		ground = mix(ground, bed, bank * ford.z);
		// Plan 374: under the water the meadow went on, grass and flowers
		// and all, seen through the shallows. The bed is silt and pebbles,
		// darker toward the deep middle.
		float under = 1.0 - smoothstep(ford.y * 0.5, ford.y * 0.72, dz);
		vec3 silt = texture(tex_dirt, rot * wxz * tile_dirt * 0.8 + 0.3).rgb * vec3(0.52, 0.48, 0.38);
		float pebble = smoothstep(0.55, 0.72, fbm(wxz * 1.7 + 5.0)) * (0.5 + 0.5 * smoothstep(0.4, 0.7, fbm(wxz * 0.15 + 30.0))) * (1.0 - smoothstep(ford.y * 0.3, ford.y * 0.55, dz));
		vec3 stones = texture(tex_rock, wxz * tile_rock * 3.0).rgb;
		stones = mix(vec3(dot(stones, vec3(0.299, 0.587, 0.114))), stones, 0.35) * vec3(0.60, 0.60, 0.57);
		vec3 riverbed = mix(silt, stones, pebble * 0.7) * mix(1.0, 0.6, 1.0 - smoothstep(0.0, ford.y * 0.6, dz));
		ground = mix(ground, riverbed, under * ford.z);
	}
	for (int i = 0; i < scorch_count; i++) {
		float d = length(wxz - scorch_zones[i].xy) / max(scorch_zones[i].z, 0.1);
		// The noisy edge never reaches past 1.3 radii: skip the zone's noise
		// and crack work for the rest of the battlefield (it was paid on
		// every pixel of the map).
		if (d > 1.3) {
			continue;
		}
		float edge = d + (fbm(wxz * 0.09 + float(i) * 13.0) - 0.5) * 0.55;
		float zone = (1.0 - smoothstep(0.55, 1.0, edge));
		if (scorch_zones[i].w < 0.0) {
			// Bloom meadow: deeper, saturated green with pale gold-green blossoms.
			float bloom = zone * -scorch_zones[i].w * (1.0 - 0.8 * clamp(snow_amt, 0.0, 1.0)); // a grove thaws snow a little, not into teal
			vec3 lush = ground * vec3(0.78, 1.12, 0.62);
			float petals = smoothstep(0.78, 0.9, fbm(wxz * 1.7 + float(i) * 7.0));
			lush = mix(lush, vec3(0.86, 0.92, 0.58), petals * 0.55);
			ground = mix(ground, lush, clamp(bloom, 0.0, 1.0));
			continue;
		}
		float burn = zone * scorch_zones[i].w;
		float ash_luma = dot(ground, vec3(0.299, 0.587, 0.114));
		vec3 ash = mix(vec3(0.055, 0.05, 0.055), vec3(0.13, 0.115, 0.12), fbm(wxz * 0.35 + 3.0)) * (0.8 + 0.5 * ash_luma);
		// A few ember-warm cinders in the heart of the burn.
		ash += vec3(0.20, 0.06, 0.02) * smoothstep(0.82, 0.95, fbm(wxz * 0.6 + 9.0)) * (1.0 - smoothstep(0.2, 0.6, d));
		// Cracked basalt plates: dark seams, a few of which glow with embers
		// toward the heart of the holdfast.
		float seam = 1.0 - smoothstep(0.0, 0.07, crack_dist(wxz * 0.32 + float(i) * 5.0));
		float fine = 1.0 - smoothstep(0.0, 0.05, crack_dist(wxz * 0.9 + 3.0));
		ash *= 1.0 - 0.55 * seam - 0.25 * fine;
		ash += vec3(0.95, 0.30, 0.06) * seam * smoothstep(0.55, 0.8, fbm(wxz * 0.12 + 40.0 + TIME * 0.05)) * (1.0 - smoothstep(0.1, 0.75, d)) * 1.5;
		// Plates catch a little light at their raised centres.
		ash *= 0.9 + 0.2 * smoothstep(0.1, 0.45, crack_dist(wxz * 0.32 + float(i) * 5.0));
		// Plan 391: every plate was the same smooth grey, so the yard read
		// as clean vinyl tiles. Each plate now has its own shade and a faint
		// warm or cool cast, and the stone grain shows on its face.
		vec2 plate = crack_cell(wxz * 0.32 + float(i) * 5.0);
		float plate_h = hash21(plate + vec2(3.7, 9.1));
		ash *= mix(0.64, 1.34, plate_h * plate_h * (3.0 - 2.0 * plate_h));
		ash *= mix(vec3(1.06, 0.98, 0.93), vec3(0.94, 0.98, 1.05), hash21(plate + vec2(41.0, 7.0)));
		float stone_grain = dot(texture(tex_rock, wxz * tile_rock * 2.6 + plate * 0.37).rgb, vec3(0.333));
		ash *= mix(0.72, 1.26, smoothstep(0.2, 0.7, stone_grain));
		ground = mix(ground, ash, clamp(burn, 0.0, 1.0));
		// Plan 375: on a snowfield the holdfast's basalt pad was bare and dark
		// to its very edge, a cut-out on the snow. Snow lies on its outer
		// plates (the seams stay dark), melting away toward the hot heart.
		if (snow_amt > 0.001) {
			float lying = smoothstep(0.42, 0.9, d + (fbm(wxz * 0.25 + float(i) * 3.0) - 0.5) * 0.45);
			vec3 snow_col = mix(snow_shadow_color, snow_highlight_color, 0.55 + 0.35 * fbm(wxz * 0.8 + 4.0));
			ground = mix(ground, snow_col, clamp(lying * 0.85 * (1.0 - 0.6 * seam) * snow_amt, 0.0, 1.0) * clamp(burn, 0.0, 1.0));
		}
	}
	// Ashen maps (a burned country): the open ground was a bare grey sheet.
	// Pale ash now lies in long wind-combed drifts, and old burn scars leave
	// charred black patches ringed with scorched earth. Roads and the
	// starting seats stay clear.
	if (ash_surface > 0.0) {
		float keep = 1.0 - clamp(road, 0.0, 1.0);
		for (int i = 0; i < field_seat_count; i++) {
			keep *= smoothstep(22.0, 38.0, distance(wxz, field_seats[i]));
		}
		// Drifts are stretched along the prevailing wind (roughly +x+z).
		vec2 wind = vec2(wxz.x * 0.7 + wxz.y * 0.7, -wxz.x * 0.7 + wxz.y * 0.7);
		vec2 dp = vec2(wind.x * 0.012, wind.y * 0.045);
		float drift = smoothstep(0.50, 0.68, fbm2(dp + 31.0) + (fbm(wxz * 0.2 + 4.0) - 0.5) * 0.12);
		float streak = 0.88 + 0.12 * fbm(vec2(wind.x * 0.05, wind.y * 0.6) + 12.0);
		vec3 ash_col = vec3(0.45, 0.43, 0.40) * (0.9 + 0.2 * fbm(wxz * 0.6 + 8.0)) * streak;
		ground = mix(ground, ash_col, drift * keep * 0.5 * ash_surface);
		// Burn scars: charred cores, a scorched brown ring around them.
		float scar_n = fbm2(wxz * 0.022 + 57.0) + (fbm(wxz * 0.14 + 6.0) - 0.5) * 0.1;
		float ring = smoothstep(0.57, 0.63, scar_n) * keep * ash_surface * (1.0 - drift);
		float core = smoothstep(0.63, 0.70, scar_n) * keep * ash_surface * (1.0 - drift);
		ground = mix(ground, ground * vec3(0.62, 0.50, 0.40), ring * 0.8);
		// Charcoal mottled at two scales with only faint cracks: evenly lit
		// plates on a dark grid read as reptile scales over a whole scar.
		float soot = fbm(wxz * 0.35 + 2.0) * 0.6 + fbm(wxz * 1.3 + 9.0) * 0.4;
		float char_crack = 1.0 - smoothstep(0.0, 0.06, crack_dist(wxz * 0.45 + 2.0));
		vec3 char_col = (vec3(0.075, 0.07, 0.065) + vec3(0.07, 0.065, 0.06) * smoothstep(0.35, 0.75, soot)) * (1.0 - 0.35 * char_crack);
		ground = mix(ground, char_col, core * 0.9);
	}
	// Volcanic fields: veins of lava glow through cracks in the basalt in
	// broad bands across the open ground (they used to glow only under a
	// Vorthak holdfast, and the middle of the field was a flat brown sheet).
	// Kept off the roads and away from the starting seats.
	vec3 lava_glow = vec3(0.0);
	if (volcanic_surface > 0.5) {
		float keep = 1.0 - clamp(road, 0.0, 1.0);
		for (int i = 0; i < field_seat_count; i++) {
			keep *= smoothstep(24.0, 40.0, distance(wxz, field_seats[i]));
		}
		// Plan 370: the rest of the field was one flat rust sheet. Black
		// basalt flows and pale ash beds now break it up.
		float basalt = smoothstep(0.54, 0.58, fbm2(wxz * 0.019 + 201.0) + (fbm(wxz * 0.21 + 8.0) - 0.5) * 0.14) * keep;
		float ash_bed = smoothstep(0.60, 0.64, fbm2(wxz * 0.016 + 77.0) + (fbm(wxz * 0.3 + 14.0) - 0.5) * 0.12 - 0.02) * keep * (1.0 - basalt);
		vec3 basalt_col = vec3(0.085, 0.08, 0.09) * (0.7 + 0.6 * fbm(wxz * 0.9 + 33.0)) * (0.85 + 0.3 * smoothstep(0.3, 0.7, fbm(vec2(wxz.x * 0.5, wxz.y * 0.12) + 50.0))) * (1.0 - 0.3 * (1.0 - smoothstep(0.0, 0.05, crack_dist(wxz * 0.38 + 61.0))));
		ground = mix(ground, basalt_col, basalt * 0.9);
		vec3 ash_col = vec3(0.29, 0.29, 0.30) * (0.8 + 0.35 * fbm(wxz * 0.7 + 21.0)) * (0.9 + 0.1 * sin(dot(wxz, vec2(0.9, 0.5)) * 3.0 + fbm(wxz * 0.4) * 6.0));
		ground = mix(ground, mix(ground, ash_col, 0.75), ash_bed);
		float band = smoothstep(0.64, 0.78, fbm2(wxz * 0.011 + 113.0)) * keep;
		if (band > 0.001) {
			// (Plan 370: the seams were straight cell edges of even width,
			// like lines drawn with a ruler. They wander and swell now, and
			// warm the rock beside them.)
			vec2 cp = wxz * 0.13 + 17.0 + (vec2(fbm(wxz * 0.045 + 3.0), fbm(wxz * 0.045 + 9.0)) - 0.5) * 1.4;
			float cd = crack_dist(cp);
			float width = 0.025 + 0.05 * smoothstep(0.35, 0.75, fbm(wxz * 0.07 + 41.0));
			float seam = 1.0 - smoothstep(0.0, width, cd);
			float halo = 1.0 - smoothstep(width, width + 0.2, cd);
			float fine = 1.0 - smoothstep(0.0, 0.035, crack_dist(wxz * 0.55 + 5.0));
			// Plates darken toward the seams; the seams themselves burn.
			ground *= 1.0 - band * (0.35 * seam + 0.15 * fine);
			float heat = band * seam * smoothstep(0.45, 0.7, fbm(wxz * 0.08 + 2.0));
			float pulse = 0.75 + 0.25 * sin(TIME * 0.9 + fbm(wxz * 0.05) * 9.0);
			lava_glow = vec3(0.85, 0.20, 0.03) * heat * pulse;
			float warm = band * halo * smoothstep(0.45, 0.7, fbm(wxz * 0.08 + 2.0));
			lava_glow += vec3(0.30, 0.06, 0.01) * warm * (1.0 - seam) * pulse;
			ground = mix(ground, ground * vec3(0.55, 0.42, 0.38), warm * 0.5);
			ground = mix(ground, vec3(0.22, 0.05, 0.015), clamp(heat, 0.0, 1.0) * 0.8);
		}
	}
	float pool = 0.0;
	if (bog_surface > 0.0) {
		float keep = 1.0 - clamp(road, 0.0, 1.0);
		for (int i = 0; i < field_seat_count; i++) {
			keep *= smoothstep(26.0, 42.0, distance(wxz, field_seats[i]));
		}
		float patch_m = fbm2(wxz * 0.03 + 71.0);
		float soggy = smoothstep(0.52, 0.66, patch_m) * keep * bog_surface;
		pool = smoothstep(0.665, 0.705, patch_m + (fbm(wxz * 0.15 + 3.0) - 0.5) * 0.08) * keep * bog_surface;
		vec3 mud = texture(tex_dirt, wxz * tile_dirt * 0.7).rgb * vec3(0.40, 0.38, 0.28);
		ground = mix(ground, mix(ground * 0.62, mud, 0.5), soggy);
		// The soggy ground is not one flat dark sheet: sedge tussocks stand
		// out of it, beds of yellow-green bog moss spread across it, and small
		// puddles of standing water lie between.
		float tussock = smoothstep(0.56, 0.74, fbm(wxz * 0.9 + 13.0));
		// (Plan 366: the moss beds were flat chartreuse smudges, like spilled
		// paint. Their edges now fray and the moss carries its own grain.)
		float moss = smoothstep(0.6, 0.8, fbm(wxz * 0.22 + 27.0) + (fbm(wxz * 1.3 + 2.0) - 0.5) * 0.14);
		float puddle = smoothstep(0.70, 0.75, fbm(wxz * 0.4 + 51.0)) * (1.0 - tussock);
		vec3 bog_ground = mix(ground, vec3(0.30, 0.34, 0.14) * (0.85 + 0.3 * fbm(wxz * 2.3 + 5.0)), tussock * 0.75);
		vec3 moss_col = vec3(0.33, 0.39, 0.13) * (0.72 + 0.5 * fbm(wxz * 1.9 + 19.0)) * mix(0.85, 1.1, dot(ground, vec3(0.333)) * 2.0);
		bog_ground = mix(bog_ground, moss_col, moss * (1.0 - tussock) * 0.45);
		ground = mix(ground, bog_ground, soggy);
		pool = max(pool, puddle * soggy * 0.85);
		// Peat-dark water with a little weed floating in it.
		vec3 still = vec3(0.045, 0.065, 0.05) + vec3(0.05, 0.07, 0.03) * smoothstep(0.6, 0.85, fbm(wxz * 0.5 + 9.0));
		// Shallow brown margins, darker deeps, and rafts of duckweed: the
		// pools were one flat dark sheet.
		float deep = smoothstep(0.69, 0.76, patch_m);
		still = mix(vec3(0.17, 0.15, 0.08), still, 0.35 + 0.65 * deep);
		still *= mix(1.0, 0.75, deep);
		float weed = smoothstep(0.60, 0.70, fbm(wxz * 0.28 + 77.0)) * smoothstep(0.45, 0.65, fbm(wxz * 1.6 + 3.0));
		// (Plan 366: the rafts were bright flat chartreuse; they are darker,
		// thinner and grained.)
		still = mix(still, vec3(0.20, 0.29, 0.08) * (0.75 + 0.5 * vnoise(wxz * 4.1 + 6.0)), weed * 0.65);
		// Open water mirrors a little of the grey sky, so a pool reads as
		// water and not as a patch of dark paint.
		still = mix(still, vec3(0.24, 0.30, 0.33), 0.2 * (1.0 - weed) * deep);
		ground = mix(ground, still, pool);
	}
	ALBEDO = ground;
	if (relief_strength > 0.0) {
		// Rolling-ground relief from a low-frequency height field, fading out on
		// roads so worn tracks read as flat, trodden ground.
		float e = 0.5;
		float hc = swell(wxz * relief_scale * 6.0);
		float hx = swell((wxz + vec2(e, 0.0)) * relief_scale * 6.0);
		float hz = swell((wxz + vec2(0.0, e)) * relief_scale * 6.0);
		float k = relief_strength * (1.0 - 0.7 * clamp(road, 0.0, 1.0)) * 2.2 * (1.0 - pool);
		vec3 base_n = mesh_normals > 0.5 ? normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz) : vec3(0.0, 1.0, 0.0);
		// (Plan 376: the hill's coarse rings put a lighting crease at its
		// foot, a hard line on the field. The normal eases to level there.)
		base_n = normalize(mix(vec3(0.0, 1.0, 0.0), base_n, smoothstep(-0.05, 2.2, world_pos.y)));
		vec3 n_world = normalize(base_n + vec3(-(hx - hc) * k, 0.0, -(hz - hc) * k));
		NORMAL = normalize((VIEW_MATRIX * vec4(n_world, 0.0)).xyz);
		// Cavity darkening in the hollows of the relief.
		ALBEDO *= mix(0.88, 1.03, smoothstep(-0.6, 0.6, hc));
		// A hill's flanks are a little darker and duller than the field at
		// its foot (packed and weathered), so a sunlit slope does not wash out.
		ALBEDO *= 1.0 - 0.75 * clamp(1.0 - base_n.y, 0.0, 0.4) * mesh_normals;
	}
	if (field_half > 0.0) {
		float past = max(abs(wxz.x), abs(wxz.y)) - field_half + (fbm(wxz * 0.11 + 5.0) - 0.5) * 3.0;
		float beyond = smoothstep(0.0, 8.0, past);
		for (int i = 0; i < field_seat_count; i++) {
			beyond *= smoothstep(40.0, 58.0, distance(wxz, field_seats[i]));
		}
		ALBEDO = mix(ALBEDO, mix(ALBEDO, vec3(dot(ALBEDO, vec3(0.299, 0.587, 0.114))), 0.4) * 0.64, beyond);
	}
	ALBEDO *= 1.0 - cloud_shadow_strength * cloud_shadow(wxz, TIME);
	ROUGHNESS = mix(mix(1.0, 0.7, clamp(snow_amt, 0.0, 1.0)), 0.06, pool);
	SPECULAR = mix(0.02, 0.5, pool);
	EMISSION = lava_glow;
}
