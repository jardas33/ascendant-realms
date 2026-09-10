@tool
extends EditorScenePostImport

## Presentation-only import normalization for the owned Hollowspan bridge.
## Keep the authored texture and normal detail, but establish a bounded cool
## slate factor so the structure cannot enter the normal RTS view as a pale
## untextured rectangle.

func _post_import(scene: Node) -> Object:
	for child in scene.find_children("*", "MeshInstance3D"):
		var mesh := child as MeshInstance3D
		if not mesh or not mesh.mesh:
			continue
		for surface in mesh.mesh.get_surface_count():
			var source := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
			if not source:
				continue
			var material := source.duplicate() as StandardMaterial3D
			material.albedo_color = Color(0.48, 0.52, 0.56, 1.0)
			material.metallic = minf(material.metallic, 0.08)
			material.roughness = maxf(material.roughness, 0.86)
			mesh.set_surface_override_material(surface, material)
	return scene
