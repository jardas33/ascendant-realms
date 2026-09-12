@tool
extends EditorScenePostImport

## Presentation-only import normalization for the Barrosan Clanhold source.
## YardGrass, YardPacked, and Fence* are review-scene staging leaves; the
## production Building owner already treats them as non-authoritative. Remove
## only those named leaves here so every imported use of this owned source
## presents the keep itself. Existing textures, normals, and roughness remain
## intact; the factors below only bring the authored palette into the slate /
## weathered-stone direction.

func _post_import(scene: Node) -> Object:
	for child in scene.find_children("*", "MeshInstance3D"):
		var mesh := child as MeshInstance3D
		if not mesh:
			continue
		var lower_name := mesh.name.to_lower()
		if "yard" in lower_name or "fence" in lower_name:
			var parent := mesh.get_parent()
			if parent:
				parent.remove_child(mesh)
			mesh.free()
			continue
		_normalize_materials(mesh)
	return scene

func _normalize_materials(mesh: MeshInstance3D) -> void:
	if not mesh.mesh:
		return
	for surface in mesh.mesh.get_surface_count():
		var source := mesh.mesh.surface_get_material(surface) as StandardMaterial3D
		if not source:
			continue
		var material := source.duplicate() as StandardMaterial3D
		match material.resource_name:
			"BARROSAN_GRANITE":
				material.albedo_color = Color(0.72, 0.75, 0.76, 1.0)
			"BARROSAN_LIMEWASH":
				material.albedo_color = Color(0.62, 0.64, 0.64, 1.0)
			"BARROSAN_DARK_SLATE":
				material.albedo_color = Color(0.70, 0.74, 0.78, 1.0)
			"BARROSAN_AGED_TIMBER":
				material.albedo_color = Color(0.62, 0.56, 0.50, 1.0)
			_:
				continue
		mesh.set_surface_override_material(surface, material)
