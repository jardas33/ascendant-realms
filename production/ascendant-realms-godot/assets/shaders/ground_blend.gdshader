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

uniform float tile_grass = 0.14;
uniform float tile_dirt = 0.10;
uniform float tile_rock = 0.09;

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

// distance from point p to segment a-b (all in XZ)
float seg_dist(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float t = clamp(dot(p - a, ab) / max(dot(ab, ab), 0.0001), 0.0, 1.0);
	return length(p - (a + ab * t));
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 wxz = world_pos.xz;

	// two grass variants blended by a big soft noise = meadow patches
	vec3 grass_a = texture(tex_grass, wxz * tile_grass).rgb;
	vec3 grass_b = texture(tex_meadow, wxz * tile_grass * 0.83).rgb;
	float meadow_m = smoothstep(0.35, 0.65, fbm(wxz * 0.012));
	vec3 ground = mix(grass_a, grass_b, meadow_m);

	// dry-earth clearings (dirt_bias pushes toward a sandy/parched biome)
	vec3 dirt = texture(tex_dirt, wxz * tile_dirt).rgb;
	float dirt_m = clamp(smoothstep(0.66, 0.82, fbm(wxz * 0.017 + 60.0)) + dirt_bias, 0.0, 1.0);
	ground = mix(ground, dirt, dirt_m * 0.85);

	// scattered rocky ground where a second noise field peaks (rock_bias -> stony biome)
	vec3 rock = texture(tex_rock, wxz * tile_rock).rgb;
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
	vec3 road_col = texture(tex_dirt, wxz * tile_dirt * 1.15).rgb * 0.92;
	ground = mix(ground, road_col, clamp(road, 0.0, 1.0));

	// gentle macro shading for depth
	float macro = 0.82 + 0.18 * fbm(wxz * 0.006 + 5.0);
	ground *= macro * tint;

	// snow blanket for frozen biomes, broken up by noise so it isn't flat white
	float snow_mask = snow_amt * (0.75 + 0.25 * fbm(wxz * 0.03 + 12.0));
	ground = mix(ground, vec3(0.9, 0.93, 0.98), clamp(snow_mask, 0.0, 1.0));

	ALBEDO = ground;
	ROUGHNESS = mix(1.0, 0.7, clamp(snow_amt, 0.0, 1.0));
	SPECULAR = 0.02;
}
