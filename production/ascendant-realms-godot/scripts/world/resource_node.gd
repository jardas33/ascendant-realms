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
	# Keep the authored resource mesh and gameplay footprint intact. Apply a
	# per-resource material hierarchy to the existing mesh surfaces so a pale
	# source asset cannot be mistaken for a construction ghost. This is visual
	# only: no collision, amount, or interaction state is changed.
	if n is MeshInstance3D:
		var mesh: Mesh = n.mesh
		if n.material_override is StandardMaterial3D:
			var override_copy := (n.material_override as StandardMaterial3D).duplicate()
			override_copy.albedo_color = _resource_albedo(override_copy.albedo_color)
			override_copy.roughness = maxf(override_copy.roughness, 0.78)
			n.material_override = override_copy
		if mesh:
			for surface in mesh.get_surface_count():
				var source_mat: Material = mesh.surface_get_material(surface)
				var surface_copy := StandardMaterial3D.new()
				if source_mat is StandardMaterial3D:
					surface_copy = (source_mat as StandardMaterial3D).duplicate()
				else:
					surface_copy.albedo_color = Color(0.72, 0.72, 0.70, 1.0)
				surface_copy.albedo_color = _resource_albedo(surface_copy.albedo_color)
				surface_copy.roughness = maxf(surface_copy.roughness, 0.78)
				n.set_surface_override_material(surface, surface_copy)
	for child in n.get_children():
		_apply_p1r14_resource_readability(child)

func _resource_albedo(source: Color) -> Color:
	match resource_kind:
		"stone": return source.lerp(Color(0.30, 0.34, 0.34, 1.0), 0.58)
		"timber": return source.lerp(Color(0.34, 0.18, 0.07, 1.0), 0.20).lightened(0.04)
		"gold": return source.lerp(Color(0.50, 0.31, 0.08, 1.0), 0.18).lightened(0.05)
		"food": return source.lerp(Color(0.48, 0.34, 0.12, 1.0), 0.24).lightened(0.06)
		_: return source.lightened(0.08)

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
	match resource_kind:
		"stone": _add_stone_quarry_dressing()
		"timber": _add_timber_dressing()
		"gold": _add_gold_dressing()
		"food": _add_food_dressing()

func _add_timber_dressing() -> void:
	var dressing := Node3D.new()
	dressing.name = "TimberPileDressing"
	model_root.add_child(dressing)
	for i in 3:
		var log := MeshInstance3D.new()
		log.name = "TimberLog%d" % (i + 1)
		var log_mesh := CylinderMesh.new()
		log_mesh.top_radius = 0.22
		log_mesh.bottom_radius = 0.25
		log_mesh.height = 1.30
		log_mesh.radial_segments = 8
		log.mesh = log_mesh
		log.rotation.z = PI * 0.5
		log.position = Vector3(-0.38 + float(i) * 0.38, 0.24 + float(i % 2) * 0.25, 0.06)
		log.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		var log_mat := StandardMaterial3D.new()
		log_mat.albedo_color = Color(0.34, 0.16, 0.06, 1.0)
		log_mat.roughness = 0.90
		log.material_override = log_mat
		dressing.add_child(log)

func _add_gold_dressing() -> void:
	var dressing := Node3D.new()
	dressing.name = "GoldOreDressing"
	model_root.add_child(dressing)
	var positions := [Vector3(-0.55, 0.20, 0.10), Vector3(0.52, 0.16, 0.22), Vector3(0.05, 0.26, -0.50)]
	for i in positions.size():
		var ore := MeshInstance3D.new()
		ore.name = "GoldOreFragment%d" % (i + 1)
		var ore_mesh := SphereMesh.new()
		ore_mesh.radius = 0.36
		ore_mesh.height = 0.62
		ore_mesh.radial_segments = 6
		ore_mesh.rings = 3
		ore.mesh = ore_mesh
		ore.position = positions[i]
		ore.scale = Vector3(0.75 + float(i) * 0.08, 0.65, 0.85)
		ore.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		var ore_mat := StandardMaterial3D.new()
		ore_mat.albedo_color = [Color(0.54, 0.34, 0.08, 1.0), Color(0.72, 0.46, 0.10, 1.0), Color(0.40, 0.25, 0.07, 1.0)][i]
		ore_mat.roughness = 0.82
		ore.material_override = ore_mat
		dressing.add_child(ore)

func _add_food_dressing() -> void:
	var dressing := Node3D.new()
	dressing.name = "FoodHayDressing"
	model_root.add_child(dressing)
	var positions := [Vector3(-0.42, 0.20, 0.08), Vector3(0.42, 0.18, 0.18), Vector3(0.04, 0.32, -0.32)]
	for i in positions.size():
		var bale := MeshInstance3D.new()
		bale.name = "HayBale%d" % (i + 1)
		var bale_mesh := CylinderMesh.new()
		bale_mesh.top_radius = 0.34
		bale_mesh.bottom_radius = 0.36
		bale_mesh.height = 0.42
		bale_mesh.radial_segments = 8
		bale.mesh = bale_mesh
		bale.position = positions[i]
		bale.rotation.y = 0.22 * float(i)
		bale.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		var bale_mat := StandardMaterial3D.new()
		bale_mat.albedo_color = [Color(0.62, 0.42, 0.15, 1.0), Color(0.74, 0.52, 0.18, 1.0), Color(0.52, 0.34, 0.11, 1.0)][i]
		bale_mat.roughness = 0.94
		bale.material_override = bale_mat
		dressing.add_child(bale)

func _add_stone_quarry_dressing() -> void:
	# A low, non-colliding quarry apron and three faceted fragments turn the
	# existing authored stone chunk into a grounded deposit. They are strictly
	# presentation children of the resource node and cast no interaction rays.
	var apron := MeshInstance3D.new()
	apron.name = "StoneQuarryApron"
	var apron_mesh := CylinderMesh.new()
	apron_mesh.top_radius = 1.28
	apron_mesh.bottom_radius = 1.48
	apron_mesh.height = 0.10
	apron_mesh.radial_segments = 8
	apron.mesh = apron_mesh
	apron.position.y = 0.05
	apron.scale = Vector3(1.12, 1.0, 0.84)
	apron.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var apron_mat := StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.18, 0.20, 0.20, 0.92)
	apron_mat.roughness = 0.94
	apron.material_override = apron_mat
	model_root.add_child(apron)
	var fragments := Node3D.new()
	fragments.name = "StoneQuarryFragments"
	model_root.add_child(fragments)
	var fragment_positions := [Vector3(-1.00, 0.34, 0.16), Vector3(0.92, 0.28, 0.28), Vector3(0.12, 0.25, -1.02), Vector3(-0.46, 0.20, 0.92), Vector3(0.56, 0.18, 0.78)]
	var fragment_scales := [Vector3(0.58, 0.42, 0.48), Vector3(0.48, 0.36, 0.62), Vector3(0.46, 0.34, 0.44), Vector3(0.34, 0.28, 0.42), Vector3(0.30, 0.24, 0.36)]
	for i in fragment_positions.size():
		var fragment := MeshInstance3D.new()
		fragment.name = "QuarryFragment%d" % (i + 1)
		var fragment_mesh := SphereMesh.new()
		fragment_mesh.radius = 0.55
		fragment_mesh.height = 0.78
		fragment_mesh.radial_segments = 6
		fragment_mesh.rings = 3
		fragment.mesh = fragment_mesh
		fragment.position = fragment_positions[i]
		fragment.scale = fragment_scales[i]
		fragment.rotation.y = 0.35 * float(i)
		fragment.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		var fragment_mat := StandardMaterial3D.new()
		fragment_mat.albedo_color = [Color(0.42, 0.46, 0.45, 1.0), Color(0.28, 0.32, 0.33, 1.0), Color(0.48, 0.50, 0.47, 1.0), Color(0.34, 0.38, 0.38, 1.0), Color(0.39, 0.42, 0.40, 1.0)][i]
		fragment_mat.roughness = 0.92
		fragment.material_override = fragment_mat
		fragments.add_child(fragment)

func _p1r14_resource_color() -> Color:
	match resource_kind:
		"gold": return Color(0.95, 0.70, 0.24, 0.86)
		"stone": return Color(0.28, 0.34, 0.34, 0.62)
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
