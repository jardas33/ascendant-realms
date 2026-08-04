extends Node

const TARGETS := ["barrosan_clanhold", "barrosan_war_hall", "barrosan_clan_croft"]
const EXPECTED_SCALES := {"barrosan_clanhold": 1.18, "barrosan_war_hall": 1.0, "barrosan_clan_croft": 0.90}
const BuildingScript = preload("res://scripts/buildings/building.gd")
const ModelUtilsScript = preload("res://scripts/utils/model_utils.gd")

func _ready() -> void:
	var defs_script = load("res://scripts/game/building_defs.gd")
	if defs_script == null:
		_fail("building_defs.gd did not load")
		return
	var defs: Dictionary = defs_script.get_all()
	for id in TARGETS:
		if not defs.has(id) or not defs[id].has("visual_scale"):
			_fail("missing visual hierarchy definition for %s" % id)
			return
		if abs(float(defs[id]["visual_scale"]) - float(EXPECTED_SCALES[id])) > 0.0001:
			_fail("unexpected visual scale for %s" % id)
			return
	for id in defs:
		if defs[id].has("visual_scale") and id not in TARGETS:
			_fail("visual_scale leaked to non-canonical definition %s" % id)
			return

	var root := Node3D.new()
	add_child(root)
	var records: Array[Dictionary] = []
	for index in TARGETS.size():
		var id: String = TARGETS[index]
		var candidate = await _spawn(root, defs[id], Vector3(float(index * 28 + 14), 0.0, 0.0))
		var baseline_def: Dictionary = defs[id].duplicate(true)
		baseline_def.erase("visual_scale")
		var baseline = await _spawn(root, baseline_def, Vector3(float(index * 28 - 14), 0.0, 0.0))
		await get_tree().process_frame
		var candidate_record := _inspect(candidate)
		var baseline_record := _inspect(baseline)
		if not _assert_record(id, candidate, candidate_record, float(EXPECTED_SCALES[id])):
			return
		if not _assert_baseline_delta(id, candidate_record, baseline_record, float(EXPECTED_SCALES[id])):
			return
		if not _assert_physics_ray(candidate, candidate_record, id):
			return
		var before := candidate_record
		candidate.model_root.position.y = 0.35
		await get_tree().process_frame
		var moved := _inspect(candidate)
		if abs(float(moved["visual_min_y"]) - float(before["visual_min_y"]) - 0.35) > 0.01 or abs(float(moved["collision_min_y"]) - float(before["collision_min_y"]) - 0.35) > 0.01:
			_fail("construction root did not move visual and collision together for %s" % id)
			return
		candidate.model_root.position.y = 0.0
		records.append(candidate_record)
		candidate.queue_free()
		baseline.queue_free()

	root.queue_free()
	print("G1C-A2-A3 PASS visual hierarchy and collision invariance for %s" % ", ".join(TARGETS))
	get_tree().quit(0)

func _spawn(root: Node3D, definition: Dictionary, position: Vector3):
	var building = BuildingScript.new()
	building.position = position
	root.add_child(building)
	await get_tree().process_frame
	building.configure(definition, 0, null, null, true)
	return building

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
		var transformed := mi.global_transform * mi.get_aabb()
		if first_visual:
			visual_aabb = transformed
			first_visual = false
		else:
			visual_aabb = visual_aabb.merge(transformed)
	for body in building.collision_root.get_children():
		var static_body := body as StaticBody3D
		if not static_body:
			continue
		body_count += 1
		for shape_node in static_body.get_children():
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
	return {
		"visual_aabb": visual_aabb,
		"collision_aabb": collision_aabb,
		"visual_min_y": visual_aabb.position.y,
		"collision_min_y": collision_aabb.position.y,
		"mesh_count": mesh_count,
		"body_count": body_count,
		"shape_count": shape_count,
	}

func _assert_record(id: String, building, record: Dictionary, expected_scale: float) -> bool:
	if building.model_root == null or building.model_root.name != "MeshRoot":
		_fail("MeshRoot missing for %s" % id)
		return false
	if building.visual_root == null or building.visual_root.name != "VisualRoot" or building.collision_root == null or building.collision_root.name != "CollisionRoot":
		_fail("visual/collision roots missing for %s" % id)
		return false
	if building.scale != Vector3.ONE or building.model_root.scale != Vector3.ONE or building.collision_root.scale != Vector3.ONE:
		_fail("shared hierarchy scale changed for %s" % id)
		return false
	if building.visual_root.scale != Vector3.ONE * expected_scale:
		_fail("VisualRoot scale mismatch for %s" % id)
		return false
	if int(record["mesh_count"]) < 1 or int(record["body_count"]) < 1 or int(record["shape_count"]) < 1:
		_fail("missing visual/collision geometry for %s" % id)
		return false
	if abs(float(record["visual_min_y"])) > 0.01:
		_fail("visual is not grounded for %s" % id)
		return false
	if building.selection_ring == null or building.selection_ring.get_parent() != building:
		_fail("selection ring ownership changed for %s" % id)
		return false
	if abs(float(building.selection_ring.mesh.inner_radius) - building.footprint * 0.9) > 0.001 or abs(float(building.selection_ring.mesh.outer_radius) - building.footprint * 1.05) > 0.001:
		_fail("selection ring geometry changed for %s" % id)
		return false
	for node in ModelUtilsScript.get_mesh_instances(building.visual_root):
		for descendant in node.get_children():
			if descendant is StaticBody3D or descendant is CollisionShape3D:
				_fail("collision remains beneath visual mesh for %s" % id)
				return false
	for body in building.collision_root.get_children():
		if body is StaticBody3D and (body.collision_layer != 4 or body.collision_mask != 0):
			_fail("collision layer/mask changed for %s" % id)
			return false
	return true

func _assert_baseline_delta(id: String, candidate: Dictionary, baseline: Dictionary, expected_scale: float) -> bool:
	var candidate_visual: AABB = candidate["visual_aabb"]
	var baseline_visual: AABB = baseline["visual_aabb"]
	var candidate_collision: AABB = candidate["collision_aabb"]
	var baseline_collision: AABB = baseline["collision_aabb"]
	for axis in 3:
		var c := float(candidate_visual.size[axis])
		var b := float(baseline_visual.size[axis])
		if b <= 0.0 or abs(c / b - expected_scale) > 0.025:
			_fail("visual AABB scale mismatch for %s on axis %d: %f vs %f" % [id, axis, c / max(b, 0.0001), expected_scale])
			return false
	if abs(candidate_collision.size.x - baseline_collision.size.x) > 0.001 or abs(candidate_collision.size.y - baseline_collision.size.y) > 0.001 or abs(candidate_collision.size.z - baseline_collision.size.z) > 0.001:
		_fail("collision AABB changed for %s" % id)
		return false
	if abs(float(candidate["collision_min_y"]) - float(baseline["collision_min_y"])) > 0.001:
		_fail("collision minimum Y changed for %s" % id)
		return false
	if int(candidate["mesh_count"]) != int(baseline["mesh_count"]) or int(candidate["body_count"]) != int(baseline["body_count"]) or int(candidate["shape_count"]) != int(baseline["shape_count"]):
		_fail("geometry counts changed for %s" % id)
		return false
	return true

func _assert_physics_ray(building, record: Dictionary, id: String) -> bool:
	var aabb: AABB = record["collision_aabb"]
	var center := aabb.get_center()
	var query := PhysicsRayQueryParameters3D.create(center + Vector3.UP * 20.0, center - Vector3.UP * 20.0, 4)
	var hit := get_viewport().get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		_fail("physics ray missed collider for %s" % id)
		return false
	var cursor: Node = hit["collider"] as Node
	while cursor:
		if cursor == building:
			return true
		cursor = cursor.get_parent()
	_fail("physics ancestry did not resolve Building for %s" % id)
	return false

func _fail(message: String) -> void:
	push_error("G1C-A2-A3 FAIL " + message)
	get_tree().quit(1)
