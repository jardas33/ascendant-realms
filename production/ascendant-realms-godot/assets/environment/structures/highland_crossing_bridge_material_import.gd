@tool
extends EditorScenePostImport

## Presentation-only import normalization for the owned Hollowspan bridge.
## Keep the authored texture and normal detail, but use a textured shader
## material so the legacy runtime tint helper cannot flatten the bridge into
## a single brown StandardMaterial3D override.

const BRIDGE_SHADER_CODE := """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap_anisotropic;
uniform vec4 surface_tint : source_color = vec4(0.78, 0.86, 0.96, 1.0);
uniform float surface_roughness = 0.92;
uniform float surface_metallic = 0.04;

void fragment() {
	vec4 base = texture(albedo_texture, UV);
	ALBEDO = base.rgb * surface_tint.rgb;
	ALPHA = base.a * surface_tint.a;
	NORMAL_MAP = texture(normal_texture, UV).rgb;
	ROUGHNESS = surface_roughness;
	METALLIC = surface_metallic;
}
"""

func _post_import(scene: Node) -> Object:
	for child in scene.find_children("*", "MeshInstance3D"):
		var mesh := child as MeshInstance3D
		if not mesh or not mesh.mesh:
			continue
		for surface in mesh.mesh.get_surface_count():
			var source := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
			if not source:
				continue
			var shader := Shader.new()
			shader.code = BRIDGE_SHADER_CODE
			var material := ShaderMaterial.new()
			material.shader = shader
			material.set_shader_parameter("albedo_texture", source.albedo_texture)
			material.set_shader_parameter("normal_texture", source.normal_texture)
			material.set_shader_parameter("surface_tint", Color(0.78, 0.86, 0.96, 1.0))
			material.set_shader_parameter("surface_roughness", 0.92)
			material.set_shader_parameter("surface_metallic", 0.04)
			mesh.set_surface_override_material(surface, material)
	return scene
