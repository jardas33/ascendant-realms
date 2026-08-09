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
