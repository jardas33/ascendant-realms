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
uniform float relief_strength = 0.0;
uniform float relief_scale = 0.018;

varying vec3 world_pos;

// --- cheap value noise ------------------------------------------------------
float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
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

void fragment() {
	vec2 wxz = world_pos.xz;

	// two grass variants blended by a big soft noise = meadow patches
	// Use a broad sample and blend it into a calm biome base.  The former
	// high-frequency full-strength samples made the wide playable field read
	// as visual noise and reduced unit/ground separation at normal zoom.
	// Anti-tiling: each layer blends a second, rotated and rescaled sample,
	// selected by low-frequency noise, so the flower tile never repeats in
	// a visible grid across the battlefield.
	float tile_mix = smoothstep(0.3, 0.7, fbm(wxz * 0.021 + 7.0));
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	vec3 ground;
	if (volcanic_surface > 0.5) {
		vec3 basalt_a = texture(tex_volcanic, mirrored_uv(wxz * tile_volcanic)).rgb;
		vec3 basalt_b = texture(tex_volcanic, mirrored_uv(rot * wxz * tile_volcanic * 0.73 + 0.37)).rgb;
		ground = mix(basalt_a, basalt_b, 0.10 + 0.12 * tile_mix);
	} else {
		vec3 grass_a = mix(texture(tex_grass, wxz * tile_grass * 0.42).rgb,
			texture(tex_grass, rot * wxz * tile_grass * 0.29 + 0.37).rgb, tile_mix);
		vec3 grass_b = mix(texture(tex_meadow, wxz * tile_grass * 0.35).rgb,
			texture(tex_meadow, rot * wxz * tile_grass * 0.23 + 0.61).rgb, 1.0 - tile_mix);
		float meadow_m = smoothstep(0.35, 0.65, fbm(wxz * 0.012));
		ground = mix(grass_a, grass_b, meadow_m);
	}
	ground = mix(ground_base, ground, clamp(surface_detail, 0.0, 1.0));

	// dry-earth clearings (dirt_bias pushes toward a sandy/parched biome)
	vec3 dirt = volcanic_surface > 0.5
		? texture(tex_volcanic, mirrored_uv(wxz * tile_volcanic * 0.62 + 0.23)).rgb * vec3(1.28, 1.04, 0.86)
		: texture(tex_dirt, wxz * tile_dirt * 0.55).rgb;
	float dirt_m = clamp(smoothstep(0.66, 0.82, fbm(wxz * 0.017 + 60.0)) + dirt_bias, 0.0, 1.0);
	ground = mix(ground, dirt, dirt_m * 0.85);

	// scattered rocky ground where a second noise field peaks (rock_bias -> stony biome)
	vec3 rock = volcanic_surface > 0.5
		? texture(tex_volcanic, mirrored_uv(rot * wxz * tile_volcanic * 1.09 + 0.61)).rgb * vec3(0.89, 0.94, 1.02)
		: texture(tex_rock, wxz * tile_rock * 0.52).rgb;
	float rock_m = clamp(smoothstep(0.62, 0.80, fbm(wxz * 0.02 + 21.0)) + rock_bias, 0.0, 1.0);
	ground = mix(ground, rock, rock_m);

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
	// A low-contrast worn edge makes routes legible without creating a
	// gameplay-zone outline or a floating strip.
	float road_edge = smoothstep(path_width + 0.3, path_width + 2.8, pd) * (1.0 - smoothstep(path_width + 2.8, path_width + 4.0, pd));
	ground = mix(ground, road_edge_color, clamp(road_edge * road_edge_strength, 0.0, 1.0));

	// Painterly colour fields: broad swathes of lush, sun-dried and mossy
	// turf, multiplied through the texture so detail survives.
	float f1 = fbm(wxz * 0.0065 + 3.0);
	float f2 = fbm(wxz * 0.011 + 17.0);
	vec3 field = mix(field_lush, field_dry, smoothstep(0.45, 0.75, f1));
	field = mix(field, field_moss, smoothstep(0.55, 0.8, f2) * 0.8);
	float grass_share = (1.0 - dirt_m * 0.85) * (1.0 - rock_m) * (1.0 - clamp(road, 0.0, 1.0));
	vec3 field_tone = ground * (field / max(dot(field_lush, vec3(0.333)), 0.05)) * 0.92;
	ground = mix(ground, field_tone, clamp(field_strength * grass_share, 0.0, 1.0));

	// gentle macro shading for depth
	float macro = (1.0 - surface_macro) + surface_macro * fbm(wxz * 0.006 + 5.0);
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
		vec2 snow_uv = 1.0 - abs(fract(wxz * tile_snow) * 2.0 - 1.0);
		vec2 snow_uv_detail = 1.0 - abs(fract(wxz * tile_snow * 1.37 + vec2(0.31, 0.57)) * 2.0 - 1.0);
		vec3 snow_albedo = mix(texture(tex_snow, snow_uv).rgb, texture(tex_snow, snow_uv_detail).rgb, 0.36);
		snow_surface = mix(snow_surface, snow_albedo, 0.87);
		snow_surface = mix(snow_surface, ground, clamp(snow_underlay_strength, 0.0, 0.7));
		ground = mix(ground, snow_surface, clamp(snow_mask * (1.0 - 0.48 * road), 0.0, 1.0));
	}

	ALBEDO = ground;
	if (relief_strength > 0.0) {
		// Rolling-ground relief from a low-frequency height field, fading out on
		// roads so worn tracks read as flat, trodden ground.
		float e = 0.5;
		float hc = swell(wxz * relief_scale * 6.0);
		float hx = swell((wxz + vec2(e, 0.0)) * relief_scale * 6.0);
		float hz = swell((wxz + vec2(0.0, e)) * relief_scale * 6.0);
		float k = relief_strength * (1.0 - 0.7 * clamp(road, 0.0, 1.0)) * 2.2;
		vec3 n_world = normalize(vec3(-(hx - hc) * k, 1.0, -(hz - hc) * k));
		NORMAL = normalize((VIEW_MATRIX * vec4(n_world, 0.0)).xyz);
		// Cavity darkening in the hollows of the relief.
		ALBEDO *= mix(0.88, 1.03, smoothstep(-0.6, 0.6, hc));
	}
	ROUGHNESS = mix(1.0, 0.7, clamp(snow_amt, 0.0, 1.0));
	SPECULAR = 0.02;
}
