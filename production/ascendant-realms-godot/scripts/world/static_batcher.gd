extends RefCounted

## Merges the static meshes under a dressing layer (hamlet, holdfast, grove,
## settlement props) into one mesh per material and shadow setting, so a base
## full of small props costs a handful of draw calls instead of hundreds.
## The layer and its child nodes stay in the tree (navigation blockers keep
## pointing at them); only the individual MeshInstance3D leaves are replaced.
## Anything animated, skinned, additive or carrying per-instance shader
## parameters is left alone. Presentation only.

## `hidden_too`: the layer may be hidden as a whole for now (a deposit under
## the fog of war); pieces hidden inside the layer are still left alone.
static func batch(layer: Node3D, hidden_too: bool = false) -> int:
	if not is_instance_valid(layer):
		return 0
	var groups := {}
	var group_material := {}
	var group_shadow := {}
	var merged := 0
	for node in layer.find_children("*", "MeshInstance3D", true, false):
		var mi := node as MeshInstance3D
		if not _batchable(mi, layer, hidden_too):
			continue
		var xform := layer.global_transform.affine_inverse() * mi.global_transform
		for surface in mi.mesh.get_surface_count():
			var mat := mi.get_active_material(surface)
			# By what the material looks like, not by which copy it is: every
			# rock of a crag carried its own copy of one material, so a ridge
			# of 38 rocks "merged" into 38 meshes.
			var key := "%d|%s" % [int(mi.cast_shadow), material_signature(mat)]
			if not groups.has(key):
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				groups[key] = st
				group_material[key] = mat
				group_shadow[key] = mi.cast_shadow
			(groups[key] as SurfaceTool).append_from(mi.mesh, surface, xform)
		mi.queue_free()
		merged += 1
	for key in groups:
		var st: SurfaceTool = groups[key]
		var out := MeshInstance3D.new()
		out.name = "StaticBatch"
		out.mesh = st.commit()
		out.material_override = group_material[key]
		out.cast_shadow = group_shadow[key]
		layer.add_child(out)
	return merged


## Two materials with the same signature draw the same and may share a batch.
## Every stored property counts (texture, colour, normal strength, emission
## energy, and whatever else the material has): the first version compared a
## chosen fifteen, and two materials that differed only in normal strength or
## emission energy were joined as one (found by Codex's review).
static var _signature_cache := {}

static func material_signature(mat: Material) -> String:
	if mat == null:
		return "null"
	var id := mat.get_instance_id()
	var cached = _signature_cache.get(id)
	if cached != null and (cached[0] as WeakRef).get_ref() == mat:
		return cached[1]
	var parts: PackedStringArray = [mat.get_class()]
	for prop in mat.get_property_list():
		if int(prop["usage"]) & PROPERTY_USAGE_STORAGE == 0:
			continue
		var prop_name := String(prop["name"])
		if prop_name in ["resource_name", "resource_path", "resource_local_to_scene", "resource_scene_unique_id", "script"]:
			continue
		parts.append("%s=%s" % [prop_name, str(mat.get(prop_name))])
	var signature := "|".join(parts)
	_signature_cache[id] = [weakref(mat), signature]
	return signature


static func _batchable(mi: MeshInstance3D, layer: Node3D, hidden_too: bool = false) -> bool:
	if mi == null or mi.mesh == null:
		return false
	if hidden_too:
		var v: Node = mi
		while v and v != layer:
			if v is Node3D and not (v as Node3D).visible:
				return false
			v = v.get_parent()
	elif not mi.is_visible_in_tree():
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
