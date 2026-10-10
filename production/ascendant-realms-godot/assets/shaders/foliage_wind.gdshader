shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
// Trees: the imported albedo, a height gradient (shaded under the canopy,
// sunlit crown), soft light through the leaves, and wind. The whole tree
// leans with slow gusts that travel across the map; the crown adds a small
// flutter. The root never moves, so trees stay planted. Presentation only.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform bool has_texture = true;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec3 uv_scale = vec3(1.0);
uniform float roughness_value = 0.85;
uniform float sway = 0.16;
uniform float flutter = 0.035;
uniform float tree_height = 9.0;
// Snow lying on the crown: 0 none, 1 a field under snow. It settles on
// whatever faces the sky, heaviest toward the top.
uniform float snow = 0.0;

varying float v_h;

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
	UV = UV * uv_scale.xy;
}

void fragment() {
	vec3 base = has_texture ? texture(albedo_tex, UV).rgb : vec3(1.0);
	ALBEDO = base * albedo_color.rgb * mix(0.70, 1.08, smoothstep(0.1, 0.95, v_h));
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	float lying = snow * smoothstep(0.15, 0.75, dot(normalize(NORMAL), up_view)) * smoothstep(0.25, 0.7, v_h);
	ALBEDO = mix(ALBEDO, vec3(0.90, 0.93, 0.98), lying * 0.85);
	ROUGHNESS = roughness_value;
	SPECULAR = 0.3;
	BACKLIGHT = vec3(0.16, 0.20, 0.06) * smoothstep(0.35, 0.9, v_h) * (1.0 - lying);
}
