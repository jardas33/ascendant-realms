shader_type spatial;
render_mode cull_disabled, diffuse_burley;
// A building under construction: everything above the work line (cut_y, set
// per mesh instance) is not built yet and is discarded, in the shadow pass
// too. Just below the line the fresh courses read as raw timber and mortar,
// and inside faces read as bare timber decking, so the unfinished shell reads
// as walls and floors going up, not a hollow cut-away. Presentation only.

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform bool has_texture = true;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform vec3 uv_scale = vec3(1.0);
uniform vec3 uv_offset = vec3(0.0);
uniform float roughness_value = 0.9;
instance uniform float cut_y = 1000.0;

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	UV = UV * uv_scale.xy + uv_offset.xy;
}

void fragment() {
	float below = cut_y - wpos.y;
	if (below < 0.0) {
		discard;
	}
	vec3 base = (has_texture ? texture(albedo_tex, UV).rgb : vec3(1.0)) * albedo_color.rgb;
	float fresh = 1.0 - smoothstep(0.0, 0.45, below);
	base = mix(base, base * 0.55 + vec3(0.30, 0.22, 0.13), fresh * 0.65);
	// Judge inside faces by the normal, not FRONT_FACING: mirrored building
	// placements flip the winding, which inverted FRONT_FACING everywhere.
	if (dot(NORMAL, VIEW) < 0.0) {
		// Inside faces read as bare timber decking and plaster, a little shaded.
		base = mix(base * 0.6, vec3(0.36, 0.28, 0.19), 0.55);
		NORMAL = -NORMAL;
	}
	ALBEDO = base;
	ROUGHNESS = roughness_value;
	// A faint warm line where the builders are working.
	EMISSION = vec3(1.0, 0.62, 0.28) * (1.0 - smoothstep(0.0, 0.07, below)) * 0.35;
}
