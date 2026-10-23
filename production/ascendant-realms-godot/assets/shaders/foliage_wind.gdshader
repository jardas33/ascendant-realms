shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
// Trees: the imported albedo, a height gradient (shaded under the canopy,
// sunlit crown), soft light through the leaves, and wind. The whole tree
// leans with slow gusts that travel across the map; the crown adds a small
// flutter. The root never moves, so trees stay planted. Presentation only.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform bool has_texture = true;
// Trees built in code (the date palms) carry their shading and the colour of
// their dates in the vertex colour.
uniform bool use_vertex_color = false;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec3 uv_scale = vec3(1.0);
uniform float roughness_value = 0.85;
uniform float sway = 0.16;
uniform float flutter = 0.035;
uniform float tree_height = 9.0;
// Plan 401: units the camera should see through leaves (x, y, z, radius),
// written each tenth of a second by the game world.
global uniform sampler2D canopy_points : filter_nearest;
global uniform float canopy_count;
const float CANOPY_BAYER[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
// Snow lying on the crown: 0 none, 1 a field under snow. It settles on
// whatever faces the sky, heaviest toward the top.
uniform float snow = 0.0;
// 1 for a boulder drawn with this shader under snow: no light through
// leaves, no shaded underside, and its moss greyed.
uniform float leafless = 0.0;
// 1 on an autumn field: green leaves turn gold, orange and red, each tree its
// own mix. Only green pixels change, so bark and dead wood keep their colour.
uniform float autumn = 0.0;
// 1 on burned ground (ashen and volcanic fields): the leaves are dead,
// singed to withered_color, and the crowns are thinned to ragged remains.
uniform float withered = 0.0;
uniform vec3 withered_color : source_color = vec3(0.42, 0.36, 0.30);
// Roots and trunk, below the crown, read as bark: the generated tree
// textures carry the leaf green down the trunk, and the foliage tint made
// the roots of the broadleaf trees bright green.
uniform vec3 bark_color : source_color = vec3(0.50, 0.40, 0.31);
uniform float bark_top = 0.34;
// Plan 420: leaf cards cut from a painted spray; 1 discards the cut-outs.
uniform float alpha_cut = 0.0;

varying float v_h;
varying float v_seed;
varying vec3 v_wp;

// Plan 355: value noise for leaf-scale light and shade in the crowns.
float leaf_hash(vec3 p) {
	return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}
float leaf_noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(leaf_hash(i), leaf_hash(i + vec3(1, 0, 0)), f.x), mix(leaf_hash(i + vec3(0, 1, 0)), leaf_hash(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(leaf_hash(i + vec3(0, 0, 1)), leaf_hash(i + vec3(1, 0, 1)), f.x), mix(leaf_hash(i + vec3(0, 1, 1)), leaf_hash(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	vec3 wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float h = clamp((wp.y - origin.y) / tree_height, 0.0, 1.4);
	float gust = sin(TIME * 0.55 - origin.x * 0.035 - origin.z * 0.02) * 0.5 + 0.5;
	float lean = (sin(TIME * 1.1 + origin.x * 0.3 + origin.z * 0.2) * 0.6 + 0.4) * (0.4 + 0.6 * gust);
	vec3 bend = vec3(0.8, 0.0, 0.45) * lean * sway * h * h;
	float leaf = smoothstep(0.35, 0.8, h);
	bend += vec3(sin(TIME * 4.3 + wp.y * 2.1 + wp.x * 1.7), sin(TIME * 3.7 + wp.z * 2.3) * 0.4, cos(TIME * 4.9 + wp.x * 1.9)) * flutter * leaf * (0.5 + 0.5 * gust);
	VERTEX += inverse(mat3(MODEL_MATRIX)) * bend;
	v_h = h;
	v_wp = wp;
	v_seed = fract(sin(dot(origin.xz, vec2(12.9898, 78.233))) * 43758.5453);
	UV = UV * uv_scale.xy;
}

void fragment() {
	vec4 tex_sample = has_texture ? texture(albedo_tex, UV) : vec4(1.0);
	if (alpha_cut > 0.5 && tex_sample.a < 0.45) {
		discard;
	}
	vec3 base = tex_sample.rgb;
	if (use_vertex_color) {
		base *= COLOR.rgb;
	}
	base = mix(base, vec3(dot(base, vec3(0.299, 0.587, 0.114))) * vec3(0.94, 0.96, 1.04), leafless * 0.85);
	if (autumn > 0.0) {
		float green = smoothstep(0.0, 0.06, base.g - max(base.r, base.b) * 0.92);
		float l = dot(base, vec3(0.299, 0.587, 0.114));
		vec3 gold = vec3(1.0, 0.72, 0.22);
		vec3 rust = vec3(0.95, 0.42, 0.14);
		vec3 crimson = vec3(0.78, 0.20, 0.10);
		vec3 turn = v_seed < 0.5 ? mix(gold, rust, v_seed * 2.0) : mix(rust, crimson, (v_seed - 0.5) * 2.0);
		// A few trees still half green.
		turn = mix(turn, vec3(0.62, 0.70, 0.30), step(0.86, v_seed) * 0.6);
		base = mix(base, turn * clamp(l * 2.3, 0.35, 0.9), green * autumn);
	}
	if (withered > 0.0) {
		// (Pine needles are blue-green, so anything greener than it is red.)
		float green = smoothstep(0.0, 0.05, base.g - base.r);
		float holes = sin(UV.x * 31.0 + v_seed * 6.0) * sin(UV.y * 27.0 + v_seed * 4.0) + sin(UV.x * 13.0 - UV.y * 11.0 + v_seed * 9.0) * 0.5;
		if (green > 0.5 && holes > 0.2) {
			discard;
		}
		float l = dot(base, vec3(0.299, 0.587, 0.114));
		vec3 dead = withered_color * mix(0.85, 1.15, v_seed) * clamp(l * 2.4, 0.4, 1.0);
		base = mix(base, dead, green * withered);
	}
	// Plan 355: a wood was one pale green mass, every crown the same smooth
	// tint. Each tree now has its own green (darker or lighter, yellower or
	// bluer), and the leaves catch the light in clumps.
	float leaf_ao = 1.0;
	if (leafless < 0.5 && withered < 0.5 && autumn < 0.5) {
		float leafy = smoothstep(0.0, 0.05, base.g - base.r) * smoothstep(0.3, 0.6, v_h);
		vec3 own = mix(vec3(0.78, 0.86, 0.76), vec3(1.08, 1.06, 0.80), v_seed);
		float clumps = leaf_noise(v_wp * 0.9) * 0.7 + leaf_noise(v_wp * 3.4) * 0.3;
		base = mix(base, base * own * mix(0.88, 1.22, clumps), leafy);
		// The gaps between leaf clusters hold shade: sky light is cut there.
		leaf_ao = mix(1.0, mix(0.35, 1.0, smoothstep(0.25, 0.7, clumps)), leafy);
		// Plan 356: under snow the leaves kept their summer green. Frost
		// greys and darkens them.
		float frost_l = dot(base, vec3(0.299, 0.587, 0.114));
		base = mix(base, mix(base, vec3(frost_l) * vec3(0.86, 0.95, 1.0), 0.7) * 0.8, leafy * snow);
	}
	float bark = (has_texture && !use_vertex_color) ? (1.0 - smoothstep(bark_top * 0.6, bark_top, v_h)) * (1.0 - leafless) : 0.0;
	float bark_l = dot(base, vec3(0.299, 0.587, 0.114));
	base = mix(base, bark_color * clamp(bark_l * 2.2, 0.45, 1.25), bark * 0.85);
	vec3 tint = mix(albedo_color.rgb, vec3(0.94), bark);
	ALBEDO = base * tint * mix(mix(0.70, 1.08, smoothstep(0.1, 0.95, v_h)), 1.0, leafless);
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	// Plan 356: snow lay as flat white sheets with hard edges. It now drifts
	// in patches, thin at the rim and thick in the hollows that face the sky,
	// and it is shaded a little (no snow is paper white in daylight).
	float drift = leaf_noise(v_wp * 1.3) * 0.65 + leaf_noise(v_wp * 4.2) * 0.35;
	float lying = snow * smoothstep(0.3, 0.9, dot(normalize(NORMAL), up_view) + (drift - 0.5) * 0.7) * smoothstep(0.25, 0.7, v_h);
	// (Broad leaf cards face the sky square on: without this they were all
	// fully snowed, one white sheet per crown.)
	lying *= smoothstep(0.18, 0.58, drift);
	ALBEDO = mix(ALBEDO, vec3(0.80, 0.84, 0.91) * mix(0.86, 1.04, drift), lying * 0.8);
	ROUGHNESS = roughness_value;
	SPECULAR = 0.3;
	AO = leaf_ao;
	AO_LIGHT_AFFECT = 0.15;
	BACKLIGHT = vec3(0.16, 0.20, 0.06) * smoothstep(0.35, 0.9, v_h) * (1.0 - lying) * (1.0 - leafless) * (1.0 - withered);
	// Plan 401: a crown between the camera and a unit hid the fighting under
	// it. Leaves on that line of sight now dissolve in a fine dither, so the
	// unit shows and the tree still reads. (Only for the perspective game
	// camera: the sun's shadow pass is orthographic and keeps whole crowns.)
	if (canopy_count > 0.5 && v_h > 0.22 && PROJECTION_MATRIX[3][3] < 0.5) {
		vec3 cam = INV_VIEW_MATRIX[3].xyz;
		vec3 w = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz - cam;
		int n = int(canopy_count);
		float hide = 0.0;
		for (int i = 0; i < 32; i++) {
			if (i >= n) {
				break;
			}
			vec4 p = texelFetch(canopy_points, ivec2(i, 0), 0);
			vec3 d = p.xyz + vec3(0.0, 1.25, 0.0) - cam;
			float len = length(d);
			vec3 dir = d / len;
			float t = dot(w, dir);
			if (t > 0.0 && t < len - 0.8) {
				hide = max(hide, 1.0 - smoothstep(p.w * 0.62, p.w, length(w - dir * t)));
			}
		}
		if (hide > 0.0) {
			ivec2 q = ivec2(FRAGCOORD.xy) % 4;
			if (hide > (CANOPY_BAYER[q.y * 4 + q.x] + 0.5) / 16.0) {
				discard;
			}
		}
	}
}
