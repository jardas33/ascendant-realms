shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_disabled;
// Instanced ground cover (grass tufts and wildflowers). UV.y runs 0 at the
// root to 1 at the tip; UV.x > 1.5 marks flower-head vertices, which take the
// per-instance colour from INSTANCE_CUSTOM. Blades bend with a travelling
// wind, shade like the ground they grow from (normal pulled up) and shrink
// to nothing wherever the clear mask is set (building footprints, resource
// sites). Presentation only.

uniform vec3 root_color : source_color = vec3(0.16, 0.22, 0.08);
uniform vec3 tip_color : source_color = vec3(0.62, 0.66, 0.30);
uniform vec3 dry_color : source_color = vec3(0.70, 0.60, 0.32);
uniform float wind_strength = 0.12;
uniform float wind_speed = 1.3;
uniform sampler2D clear_mask : filter_linear, repeat_disable;
uniform vec2 mask_origin = vec2(-140.0, -140.0);
uniform vec2 mask_size = vec2(280.0, 280.0);

varying float v_height;
varying float v_head;
varying vec4 v_custom;

void vertex() {
	vec3 origin = MODEL_MATRIX[3].xyz;
	float clear = texture(clear_mask, (origin.xz - mask_origin) / mask_size).r;
	float grow = 1.0 - smoothstep(0.15, 0.6, clear);
	VERTEX *= grow;
	float h = UV.y;
	// Travelling gusts plus a quick flutter; the tip moves, the root stays.
	float phase = dot(origin.xz, vec2(0.21, 0.13));
	float gust = sin(TIME * wind_speed * 0.6 - origin.x * 0.045 - origin.z * 0.03) * 0.5 + 0.5;
	float sway = sin(TIME * wind_speed + phase) * (0.35 + 0.65 * gust) + 0.25 * sin(TIME * wind_speed * 2.7 + phase * 3.1);
	vec3 bend_world = vec3(0.8, 0.0, 0.45) * sway * wind_strength * h * h;
	// Convert the world-space bend into the instance's local space.
	VERTEX += (inverse(mat3(MODEL_MATRIX)) * bend_world) * grow;
	v_height = h;
	v_head = step(1.5, UV.x);
	v_custom = INSTANCE_CUSTOM;
}

void fragment() {
	// INSTANCE_CUSTOM: rgb flower colour (heads) / a = dryness 0..1 (blades).
	vec3 blade = mix(root_color, tip_color, smoothstep(0.0, 1.0, v_height));
	blade = mix(blade, dry_color * mix(0.6, 1.0, v_height), v_custom.a * 0.85);
	vec3 col = mix(blade, v_custom.rgb, v_head);
	ALBEDO = col;
	// Blades light like the ground they sit on, so the field reads as one
	// surface with texture rather than a mass of dark back faces.
	vec3 up_view = (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	NORMAL = normalize(mix(NORMAL, up_view, 0.75));
	ROUGHNESS = 0.9;
	BACKLIGHT = vec3(0.18, 0.2, 0.08) * v_height;
	AO = mix(0.55, 1.0, v_height);
	AO_LIGHT_AFFECT = 0.4;
}
