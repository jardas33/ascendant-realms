class_name ResourceNode
extends StaticBody3D
## A gatherable resource on the map (forest, quarry, gold-lume vein, farm).

signal depleted_once(node: ResourceNode)

var resource_kind := "gold"    # food | timber | stone | gold
var amount := 1000
var max_amount := 1000
var depleted := false
var model_root: Node3D
var footprint := 2.5

func _m21_recorder():
	if OS.get_environment("ASCENDANT_HP4_M21_DIAGNOSTICS") != "1":
		return null
	var recorder = get_node_or_null("/root/HP4M21Startup")
	return recorder if is_instance_valid(recorder) else null

func _m21_mesh_snapshot(root: Node) -> Array:
	var out: Array = []
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if not mi or not mi.mesh:
			continue
		var mesh = mi.mesh
		var aabb := mesh.get_aabb()
		out.append({"node_name":String(mi.name), "mesh_class":String(mesh.get_class()), "mesh_resource_path":String(mesh.resource_path), "surface_count":mesh.get_surface_count(), "aabb_size":{"x":aabb.size.x,"y":aabb.size.y,"z":aabb.size.z}})
	return out

func _m21_record(row: Dictionary) -> void:
	var recorder = _m21_recorder()
	if recorder:
		recorder.record_configure(row)

func configure(kind: String, amt: int, model_path: String, scale_h: float) -> void:
	var m21_total_start := Time.get_ticks_usec()
	var m21_recorder = _m21_recorder()
	var m21_index := int(get_meta("m21_index", -1))
	resource_kind = kind
	amount = amt
	max_amount = amt
	add_to_group("resources")
	collision_layer = 8
	collision_mask = 0
	var m21_tree_start := Time.get_ticks_usec()
	model_root = Node3D.new()
	add_child(model_root)
	var m21_tree_end := Time.get_ticks_usec()
	var m21_model_acquisition_us := 0
	var m21_model_instantiation_us := 0
	var m21_visual_setup_us := 0
	var m21_collision_helper_us := 0
	var m21_collision_attach_us := 0
	var m21_remaining_us := 0
	var m21_meshes: Array = []
	var m21_collision_shapes := 0
	var m21_collision_bodies := 0
	var m21_collision_cache_hits := 0
	var m21_collision_cache_misses := 0
	if model_path != "" and ResourceLoader.exists(model_path):
		var model_load_start := Time.get_ticks_usec()
		var m
		if m21_recorder:
			var packed = load(model_path)
			m21_model_acquisition_us = Time.get_ticks_usec() - model_load_start
			var instantiate_start := Time.get_ticks_usec()
			m = packed.instantiate()
			m21_model_instantiation_us = Time.get_ticks_usec() - instantiate_start
		else:
			m = load(model_path).instantiate()
		model_root.add_child(m)
		var visual_start := Time.get_ticks_usec()
		ModelUtils.scale_to_height(m, scale_h)
		ModelUtils.ground_model(m)
		m21_visual_setup_us = Time.get_ticks_usec() - visual_start
		var collision_start := Time.get_ticks_usec()
		var collision_stats: Dictionary = ModelUtils.add_cached_per_part_convex_collision(m, 8, "resource:" + model_path)
		m21_collision_cache_hits = int(collision_stats.get("cache_hits", 0))
		m21_collision_cache_misses = int(collision_stats.get("cache_misses", 0))
		m21_collision_helper_us = Time.get_ticks_usec() - collision_start
		# Measure the gameplay envelope before presentation-only sizing. The
		# collision bodies are then kept at that authoritative size while the
		# visible resource model is slightly normalized for RTS readability.
		footprint = max(1.5, ModelUtils.measure_radius(m))
		var attach_start := Time.get_ticks_usec()
		for collider in m.find_children("*", "StaticBody3D"):
			if collider is StaticBody3D:
				collider.reparent(model_root, true)
		m21_collision_attach_us = Time.get_ticks_usec() - attach_start
		m.scale *= _presentation_scale_for_kind(kind)
		_apply_p1r14_resource_readability(m)
		_add_p1r14_resource_accent()
		m21_remaining_us = Time.get_ticks_usec() - (collision_start + m21_collision_helper_us + m21_collision_attach_us)
		m21_meshes = _m21_mesh_snapshot(m)
		m21_collision_shapes = m.find_children("*", "CollisionShape3D", true, false).size()
		m21_collision_bodies = m.find_children("*", "StaticBody3D", true, false).size()
	else:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(2, 2, 2)
		mi.mesh = bm
		mi.position.y = 1.0
		model_root.add_child(mi)
		m21_remaining_us = Time.get_ticks_usec() - m21_tree_start
	if m21_recorder:
		_m21_record({"index":m21_index, "resource_kind":kind, "model_path":model_path, "scale_height":scale_h, "configure_total_us":Time.get_ticks_usec() - m21_total_start, "tree_setup_us":m21_tree_end - m21_tree_start, "model_acquisition_us":m21_model_acquisition_us, "model_instantiation_us":m21_model_instantiation_us, "visual_setup_us":m21_visual_setup_us, "collision_helper_us":m21_collision_helper_us, "collision_attach_us":m21_collision_attach_us, "remaining_us":m21_remaining_us, "mesh_identities":m21_meshes, "collision_shape_count":m21_collision_shapes, "collision_body_count":m21_collision_bodies, "collision_layer":collision_layer, "collision_cache_hits":m21_collision_cache_hits, "collision_cache_misses":m21_collision_cache_misses})

func _presentation_scale_for_kind(kind: String) -> float:
	match kind:
		"gold": return 0.88
		"stone": return 0.92
		"timber", "food": return 0.90
		_: return 1.0

func _apply_p1r14_resource_readability(n: Node) -> void:
	# Keep the authored resource mesh and gameplay footprint intact; only lift
	# value/roughness so interactive resources separate from noisy ground.
	if n is MeshInstance3D:
		if n.material_override is StandardMaterial3D:
			var override_copy := (n.material_override as StandardMaterial3D).duplicate()
			override_copy.albedo_color = override_copy.albedo_color.lightened(0.12)
			override_copy.roughness = maxf(override_copy.roughness, 0.76)
			n.material_override = override_copy
		for surface in n.get_surface_override_material_count():
			var surface_mat: Material = n.get_surface_override_material(surface)
			if surface_mat is StandardMaterial3D:
				var surface_copy := (surface_mat as StandardMaterial3D).duplicate()
				surface_copy.albedo_color = surface_copy.albedo_color.lightened(0.12)
				surface_copy.roughness = maxf(surface_copy.roughness, 0.76)
				n.set_surface_override_material(surface, surface_copy)
	for child in n.get_children():
		_apply_p1r14_resource_readability(child)

func _add_p1r14_resource_accent() -> void:
	# A restrained, non-colliding base accent makes resources readable without
	# becoming a gameplay zone or replacing their authored silhouette.
	var accent := MeshInstance3D.new()
	accent.name = "ResourceReadabilityAccent"
	var ring := TorusMesh.new()
	ring.inner_radius = maxf(0.48, footprint * 0.28)
	ring.outer_radius = ring.inner_radius + 0.045
	ring.rings = 12
	ring.ring_segments = 6
	accent.mesh = ring
	accent.position.y = 0.035
	accent.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = _p1r14_resource_color()
	accent.material_override = mat
	model_root.add_child(accent)

func _p1r14_resource_color() -> Color:
	match resource_kind:
		"gold": return Color(0.95, 0.70, 0.24, 0.86)
		"stone": return Color(0.70, 0.78, 0.78, 0.74)
		"timber": return Color(0.82, 0.54, 0.25, 0.78)
		"food": return Color(0.42, 0.78, 0.40, 0.72)
		_: return Color(0.72, 0.72, 0.72, 0.70)

func extract(per_tick: int) -> int:
	if depleted or per_tick <= 0:
		return 0
	var got: int = min(max(0, per_tick), max(0, amount))
	amount -= got
	if amount <= 0:
		amount = 0
		depleted = true
		emit_signal("depleted_once", self)
		_deplete_visual()
	return got

func _deplete_visual() -> void:
	var t := create_tween()
	t.tween_property(model_root, "scale", model_root.scale * 0.1, 0.8)
	t.tween_callback(queue_free)
