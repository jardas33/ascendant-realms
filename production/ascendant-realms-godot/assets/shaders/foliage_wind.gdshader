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

varying float v_h;
varying float v_seed;

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
	v_seed = fract(sin(dot(origin.xz, vec2(12.9898, 78.233))) * 43758.5453);
	UV = UV * uv_scale.xy;
}

void fragment() {
	vec3 base = has_texture ? texture(albedo_tex, UV).rgb : vec3(1.0);
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
	ALBEDO = base * albedo_color.rgb * mix(mix(0.70, 1.08, smoothstep(0.1, 0.95, v_h)), 1.0, leafless);
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	float lying = snow * smoothstep(0.15, 0.75, dot(normalize(NORMAL), up_view)) * smoothstep(0.25, 0.7, v_h);
	ALBEDO = mix(ALBEDO, vec3(0.90, 0.93, 0.98), lying * 0.85);
	ROUGHNESS = roughness_value;
	SPECULAR = 0.3;
	BACKLIGHT = vec3(0.16, 0.20, 0.06) * smoothstep(0.35, 0.9, v_h) * (1.0 - lying) * (1.0 - leafless) * (1.0 - withered);
}
