shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D water_texture : source_color;
uniform float flow_time = 0.0;

void fragment() {
	vec2 uv = UV;
	vec2 flow_uv = uv + vec2(flow_time * 0.012, -flow_time * 0.004);
	vec3 base = texture(water_texture, flow_uv).rgb;
	float shallow = 0.5 + 0.5 * sin((uv.x + uv.y) * 9.0 + flow_time * 0.45);
	ALBEDO = mix(base * vec3(0.62, 0.78, 0.76), base * vec3(0.88, 1.0, 0.94), shallow * 0.22);
	ROUGHNESS = 0.24;
	METALLIC = 0.08;
	SPECULAR = 0.48;
}
