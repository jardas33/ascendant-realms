class_name ResourceNode
extends StaticBody3D
## A gatherable resource on the map (forest, quarry, gold-lume vein, farm).

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
		footprint = max(1.5, ModelUtils.measure_radius(m))
	else:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(2, 2, 2)
		mi.mesh = bm
		mi.position.y = 1.0
		model_root.add_child(mi)

func extract(per_tick: int) -> int:
	if depleted:
		return 0
	var got: int = min(per_tick, amount)
	amount -= got
	if amount <= 0:
		amount = 0
		depleted = true
		_deplete_visual()
	return got

func _deplete_visual() -> void:
	var t := create_tween()
	t.tween_property(model_root, "scale", model_root.scale * 0.1, 0.8)
	t.tween_callback(queue_free)
