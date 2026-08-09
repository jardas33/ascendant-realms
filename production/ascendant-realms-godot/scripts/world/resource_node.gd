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

func configure(kind: String, amt: int, model_path: String, scale_h: float) -> void:
	resource_kind = kind
	amount = amt
	max_amount = amt
	add_to_group("resources")
	collision_layer = 8
	collision_mask = 0
	model_root = Node3D.new()
	add_child(model_root)
	if model_path != "" and ResourceLoader.exists(model_path):
		var m = load(model_path).instantiate()
		model_root.add_child(m)
		ModelUtils.scale_to_height(m, scale_h)
		ModelUtils.ground_model(m)
		ModelUtils.add_per_part_convex_collision(m, 8)
		# Measure the gameplay envelope before presentation-only sizing. The
		# collision bodies are then kept at that authoritative size while the
		# visible resource model is slightly normalized for RTS readability.
		footprint = max(1.5, ModelUtils.measure_radius(m))
		for collider in m.find_children("*", "StaticBody3D"):
			if collider is StaticBody3D:
				collider.reparent(model_root, true)
		m.scale *= _presentation_scale_for_kind(kind)
		_apply_p1r14_resource_readability(m)
		_add_p1r14_resource_accent()
	else:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(2, 2, 2)
		mi.mesh = bm
		mi.position.y = 1.0
		model_root.add_child(mi)

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
