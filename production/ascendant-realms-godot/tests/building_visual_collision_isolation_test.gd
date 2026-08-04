extends Node

const TARGETS := ["barrosan_clanhold", "barrosan_war_hall", "barrosan_clan_croft"]
const BuildingScript = preload("res://scripts/buildings/building.gd")
const ModelUtilsScript = preload("res://scripts/utils/model_utils.gd")

func _ready() -> void:
	var defs_script = load("res://scripts/game/building_defs.gd")
	if defs_script == null:
		_fail("building_defs.gd did not load")
		return
	var defs: Dictionary = defs_script.get_all()
	var root := Node3D.new()
	add_child(root)
	var records: Array[Dictionary] = []
	for index in TARGETS.size():
		var id: String = TARGETS[index]
		if not defs.has(id):
			_fail("missing canonical building %s" % id)
			return
		var building = BuildingScript.new()
		building.position = Vector3(float(index * 16 - 16), 0.0, 0.0)
		root.add_child(building)
		await get_tree().process_frame
		building.configure(defs[id], 0, null, null, true)
		await get_tree().process_frame
		var record := _inspect(building)
		if not _assert_record(id, building, record):
			return
		await get_tree().physics_frame
		if not _assert_physics_ray(building, record, id):
			return
		records.append(record)
		building.model_root.position.y = 0.35
		await get_tree().process_frame
		var moved := _inspect(building)
		if abs(float(moved["visual_min_y"]) - float(record["visual_min_y"]) - 0.35) > 0.001:
			_fail("construction root did not move visual presentation for %s" % id)
			return
		if abs(float(moved["collision_min_y"]) - float(record["collision_min_y"]) - 0.35) > 0.001:
			_fail("construction root did not move collision presentation for %s" % id)
			return
		building.model_root.position.y = 0.0
		await get_tree().process_frame
		var collision_before: AABB = moved["collision_aabb"]
		var visual_before: AABB = moved["visual_aabb"]
		building.visual_root.scale = Vector3.ONE * 1.2
		ModelUtilsScript.ground_model(building.visual_root)
		await get_tree().process_frame
		var decoupled := _inspect(building)
		if abs(float(visual_before.size.x) - float(decoupled["visual_aabb"].size.x)) < 0.01:
			_fail("VisualRoot test scale did not change visual AABB for %s" % id)
			return
		if abs(float(collision_before.size.x) - float(decoupled["collision_aabb"].size.x)) > 0.001 or abs(float(collision_before.size.y) - float(decoupled["collision_aabb"].size.y)) > 0.001 or abs(float(collision_before.size.z) - float(decoupled["collision_aabb"].size.z)) > 0.001:
			_fail("VisualRoot test scale changed collision AABB for %s" % id)
			return
		building.visual_root.scale = Vector3.ONE
		await get_tree().process_frame
		building.queue_free()
	root.queue_free()
	print("G1C-A2-A2 PASS visual/collision ownership isolated for %s" % ", ".join(TARGETS))
	get_tree().quit(0)

func _inspect(building) -> Dictionary:
	var visual_aabb := AABB()
	var collision_aabb := AABB()
	var first_visual := true
	var first_collision := true
	var mesh_count := 0
	var body_count := 0
	var shape_count := 0
	for child in ModelUtilsScript.get_mesh_instances(building.visual_root):
		var mi := child as MeshInstance3D
		if not mi or not mi.mesh:
			continue
		mesh_count += 1
		var aabb := mi.get_aabb()
		var transformed := mi.global_transform * aabb
		if first_visual:
			visual_aabb = transformed
			first_visual = false
		else:
			visual_aabb = visual_aabb.merge(transformed)
	for body in building.collision_root.get_children():
		var sb := body as StaticBody3D
		if not sb:
			continue
		body_count += 1
		for shape_node in sb.get_children():
			var shape := shape_node as CollisionShape3D
			if not shape or not shape.shape:
				continue
			shape_count += 1
			if not shape.shape is ConvexPolygonShape3D:
				continue
			var points: PackedVector3Array = shape.shape.points
			if points.is_empty():
				continue
			var transformed := AABB(shape.global_transform * points[0], Vector3.ZERO)
			for point in points:
				transformed = transformed.expand(shape.global_transform * point)
			if first_collision:
				collision_aabb = transformed
				first_collision = false
			else:
				collision_aabb = collision_aabb.merge(transformed)
	var visual_min_y := visual_aabb.position.y
	var collision_min_y := collision_aabb.position.y
	return {"visual_aabb": visual_aabb, "collision_aabb": collision_aabb, "visual_min_y": visual_min_y, "collision_min_y": collision_min_y, "mesh_count": mesh_count, "body_count": body_count, "shape_count": shape_count}

func _assert_record(id: String, building, record: Dictionary) -> bool:
	if not building is StaticBody3D:
		_fail("Building is not StaticBody3D for %s" % id)
		return false
	if building.model_root == null or building.model_root.name != "MeshRoot":
		_fail("MeshRoot missing for %s" % id)
		return false
	if building.visual_root == null or building.collision_root == null:
		_fail("visual/collision roots missing for %s" % id)
		return false
	if int(record["mesh_count"]) < 1 or int(record["body_count"]) < 1 or int(record["shape_count"]) < 1:
		_fail("missing visual mesh or generated collision for %s mesh=%d bodies=%d shapes=%d" % [id, int(record["mesh_count"]), int(record["body_count"]), int(record["shape_count"])])
		return false
	if abs(float(building.footprint) - float(building.def.get("footprint", -1.0))) > 0.001:
		_fail("footprint changed for %s" % id)
		return false
	for body in building.collision_root.get_children():
		var sb := body as StaticBody3D
		if sb.collision_layer != 4 or sb.collision_mask != 0:
			_fail("collision layer/mask changed for %s" % id)
			return false
	for node in ModelUtilsScript.get_mesh_instances(building.visual_root):
		for child in node.get_children():
			if child is StaticBody3D:
				_fail("collision body remains beneath visible mesh for %s" % id)
				return false
	return true

func _assert_physics_ray(building, record: Dictionary, id: String) -> bool:
	var collision_aabb: AABB = record["collision_aabb"]
	var center := collision_aabb.get_center()
	var query := PhysicsRayQueryParameters3D.create(center + Vector3.UP * 20.0, center - Vector3.UP * 20.0, 4)
	var hit: Dictionary = get_viewport().get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		_fail("physics ray missed generated collider for %s" % id)
		return false
	var cursor: Node = hit["collider"] as Node
	while cursor:
		if cursor == building:
			return true
		cursor = cursor.get_parent()
	_fail("physics ray ancestry did not resolve Building for %s" % id)
	return false

func _fail(message: String) -> void:
	push_error("G1C-A2-A2 FAIL " + message)
	get_tree().quit(1)
