extends RefCounted

## Merges the static meshes under a dressing layer (hamlet, holdfast, grove,
## settlement props) into one mesh per material and shadow setting, so a base
## full of small props costs a handful of draw calls instead of hundreds.
## The layer and its child nodes stay in the tree (navigation blockers keep
## pointing at them); only the individual MeshInstance3D leaves are replaced.
## Anything animated, skinned, additive or carrying per-instance shader
## parameters is left alone. Presentation only.

static func batch(layer: Node3D) -> int:
	if not is_instance_valid(layer):
		return 0
	var groups := {}
	var merged := 0
	for node in layer.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if not _batchable(mi, layer):
			continue
		var xform := layer.global_transform.affine_inverse() * mi.global_transform
		for surface in mi.mesh.get_surface_count():
			var mat := mi.get_active_material(surface)
			var key := [mat, mi.cast_shadow]
			if not groups.has(key):
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				groups[key] = st
			(groups[key] as SurfaceTool).append_from(mi.mesh, surface, xform)
		mi.queue_free()
		merged += 1
	for key in groups:
		var st: SurfaceTool = groups[key]
		var out := MeshInstance3D.new()
		out.name = "StaticBatch"
		out.mesh = st.commit()
		out.material_override = key[0]
		out.cast_shadow = key[1]
		layer.add_child(out)
	return merged


static func _batchable(mi: MeshInstance3D, layer: Node3D) -> bool:
	if mi == null or mi.mesh == null or not mi.is_visible_in_tree():
		return false
	if mi.skeleton != NodePath("") and mi.get_node_or_null(mi.skeleton) is Skeleton3D:
		return false
	if mi.material_overlay != null:
		return false
	for surface in mi.mesh.get_surface_count():
		var mat := mi.get_active_material(surface)
		if mat == null:
			return false
		if mat is BaseMaterial3D and ((mat as BaseMaterial3D).blend_mode != BaseMaterial3D.BLEND_MODE_MIX or (mat as BaseMaterial3D).billboard_mode != BaseMaterial3D.BILLBOARD_DISABLED):
			return false
		if mat is ShaderMaterial:
			return false
	var p: Node = mi.get_parent()
	while p and p != layer:
		if p is AnimationPlayer or p is GPUParticles3D or p.get_script() != null:
			return false
		if p.find_children("*", "AnimationPlayer", false, false).size() > 0:
			return false
		p = p.get_parent()
	return true
