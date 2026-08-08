extends Node
## P1-S3 deterministic selection-shell harness.
## Uses the real production physics selection query and only pauses the live match
## while recording selection geometry/captures; it never changes gameplay values.

var _root: Node
var _world: Node
var _rts: Node
var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _proof: Array = []
var _entities: Dictionary = {}
var _fixture_entities: Dictionary = {}
var _fixture_metadata: Dictionary = {}
var _fixture_removed := false
var _before_positions: Dictionary = {}
var _before_physics: Dictionary = {}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1S3_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1S3_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1S3_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1s3-selection-readability/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	get_node("/root/Match").set_config({
		"player_race": "barrosan",
		"opponents": [{"race": "lioraen", "difficulty": "easy"}],
		"map": "hollowspan",
		"start_resources": "standard",
		"victory": "conquest",
		"mode": "skirmish",
		"game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	await get_tree().process_frame
	await _wait_for_runtime()
	if _world == null or _rts == null:
		_write_manifest()
		get_tree().quit(1)
		return
	get_tree().paused = true
	await get_tree().process_frame
	_entities = _find_representative_entities()
	_create_review_fixture_entities()
	# The review fixture is added after the scene is already running. Give Godot
	# one render and one physics tick to register the real Unit collision shape
	# before the production raycast probes run. This is fixture timing only.
	var was_paused := get_tree().paused
	var was_running: bool = _world.game_running
	_world.game_running = false
	get_tree().paused = false
	await get_tree().process_frame
	await get_tree().physics_frame
	_world.game_running = was_running
	get_tree().paused = was_paused
	_record_fixture_physics_probe()
	_before_positions = _entity_positions()
	_before_physics = _physics_snapshot()
	await _run_hitbox_validation()
	if _width == 1920:
		await _capture_visual("01_WORKER_UNSELECTED", _entities.get("worker"), false, 48.0)
		await _capture_visual("02_WORKER_SELECTED", _entities.get("worker"), true, 48.0)
		await _capture_visual("03_MILITARY_SELECTED", _entities.get("military"), true, 48.0)
		await _capture_visual("04_HERO_SELECTED", _entities.get("hero"), true, 48.0)
		await _capture_visual("05_SMALL_BUILDING_SELECTED", _entities.get("small_building"), true, 48.0)
		await _capture_visual("06_HQ_SELECTED", _entities.get("hq"), true, 48.0)
		await _capture_near_pair()
		await _capture_multiselect()
		await _capture_visual("09_HERO_SELECTED_NEAR_ZOOM", _entities.get("hero"), true, 25.0)
		await _capture_visual("10_HQ_SELECTED_FAR_ZOOM", _entities.get("hq"), true, 95.0)
	else:
		await _capture_visual("11_1366_UNIT_SELECTED", _entities.get("military"), true, 48.0)
		await _capture_visual("12_1366_BUILDING_SELECTED", _entities.get("small_building"), true, 48.0)
	_clear_selection()
	_remove_review_fixture_entities()
	await get_tree().process_frame
	if _entity_positions() != _before_positions:
		_failures.append("entity_positions_changed")
	if _physics_snapshot() != _before_physics:
		_failures.append("gameplay_physics_snapshot_changed")
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _wait_for_runtime() -> void:
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		_root = get_node_or_null("/root/GameRoot")
		if _root:
			_rts = _root.get_node_or_null("RTS")
			_world = _root.get_node_or_null("GameWorld")
		if _root and _rts and _world and _world.game_running:
			for _i in range(12): await get_tree().process_frame
			return
		await get_tree().process_frame
	_failures.append("runtime_timeout")

func _find_representative_entities() -> Dictionary:
	var result := {}
	var player_units: Array = []
	var buildings: Array = []
	for commander in _world.commanders:
		if commander.team != 0: continue
		for unit in commander.units:
			if is_instance_valid(unit) and not unit.is_dead: player_units.append(unit)
		for building in commander.buildings:
			if is_instance_valid(building) and not building.is_dead: buildings.append(building)
	for unit in player_units:
		if unit.is_hero:
			result["hero"] = unit
		elif unit.is_worker and not result.has("worker"):
			result["worker"] = unit
		elif not unit.is_worker and not result.has("military"):
			result["military"] = unit
	if not result.has("worker") and player_units.size() > 0: result["worker"] = player_units[0]
	if not result.has("hero") and _world.commanders.size() > 0: result["hero"] = _world.commanders[0].hero_ref
	var hq = null
	var small = null
	for building in buildings:
		if bool(building.def.get("is_hq", false)): hq = building
		elif small == null or building.footprint < small.footprint: small = building
	result["small_building"] = small
	result["hq"] = hq
	if result.get("worker") == null: _failures.append("missing_worker")
	if result.get("hero") == null: _failures.append("missing_hero")
	if result.get("hq") == null: _failures.append("missing_hq")
	return result

func _create_review_fixture_entities() -> void:
	var commander = _world.commanders[0] if _world.commanders.size() > 0 else null
	if commander == null:
		_failures.append("review_fixture_missing_commander")
		return
	var game_data = get_node("/root/GameData")
	var military_def: Dictionary = game_data.get_unit("barrosan_clan_levy").duplicate()
	military_def["id"] = "barrosan_clan_levy"
	# Use the existing production constructor for truthful physics registration,
	# then remove the review-only node from the Commander roster immediately.
	# The fixture remains direct-placement evidence, not production gameplay.
	var military = _world.spawn_unit("barrosan_clan_levy", 0, Vector3(-84.0, 0.0, -100.0))
	if not is_instance_valid(military):
		_failures.append("review_fixture_missing_military")
		return
	commander.units.erase(military)
	military.collision_layer = 2
	military.collision_mask = 0
	_fixture_entities["military"] = military
	_fixture_metadata["military"] = {
		"review_fixture": true,
		"class": "Unit",
		"definition_id": "barrosan_clan_levy",
		"definition_name": military_def.get("name", ""),
		"race": military_def.get("race", ""),
		"role": military_def.get("role", ""),
		"roster_membership_after_create": commander.units.has(military),
		"is_worker": military.is_worker,
		"is_hero": military.is_hero,
		"model": military_def.get("model", ""),
		"configured_height": military_def.get("height", 0.0),
		"collision_shape_count": military.get_children().filter(func(child): return child is CollisionShape3D).size(),
		"world_position": _vec(military.global_position)
	}
	_entities["military"] = military

	var small_def: Dictionary = game_data.get_building("barrosan_clan_croft").duplicate()
	small_def["id"] = "barrosan_clan_croft"
	var small := Building.new()
	_world.add_child(small)
	small.global_position = Vector3(-100.0, 0.0, -82.0)
	small.configure(small_def, 0, commander, _world, true)
	_fixture_entities["small_building"] = small
	_fixture_metadata["small_building"] = {
		"review_fixture": true,
		"class": "Building",
		"definition_id": "barrosan_clan_croft",
		"definition_name": small_def.get("name", ""),
		"race": small_def.get("race", ""),
		"is_hq": small_def.get("is_hq", false),
		"footprint": small_def.get("footprint", 0.0),
		"model": small_def.get("model", ""),
		"world_position": _vec(small.global_position)
	}
	_entities["small_building"] = small

func _remove_review_fixture_entities() -> void:
	for entity in _fixture_entities.values():
		if is_instance_valid(entity): entity.queue_free()
	_fixture_removed = true

func _record_fixture_physics_probe() -> void:
	var military = _fixture_entities.get("military")
	if not is_instance_valid(military): return
	var sphere := SphereShape3D.new()
	sphere.radius = 0.7
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, military.global_position + Vector3.UP * 0.9)
	query.collision_mask = 2
	var hits: Array[Dictionary] = _world.get_world_3d().direct_space_state.intersect_shape(query, 32)
	var labels: Array[String] = []
	for hit in hits:
		var collider = hit.get("collider")
		labels.append(str(collider.get_path()) if is_instance_valid(collider) else "null")
	_fixture_metadata["military"]["physics_shape_probe_hits"] = labels
	_fixture_metadata["military"]["physics_shape_probe_count"] = hits.size()

func _run_hitbox_validation() -> void:
	for key in ["worker", "military", "hero", "small_building", "hq"]:
		var entity = _entities.get(key)
		if not is_instance_valid(entity): continue
		await _focus_for_probe(entity)
		var geometry: Dictionary = entity.get_selection_geometry() if entity.has_method("get_selection_geometry") else {}
		var center: Vector3 = entity.global_position + Vector3.UP * _center_height(entity)
		var center_hit = _rts.raycast_selection_at(_rts.camera.unproject_position(center))
		_record_probe(key, "center", center_hit == entity, center_hit, geometry)
		var near_offset := _near_offset(entity, geometry)
		var near_hit = _rts.raycast_selection_at(_rts.camera.unproject_position(entity.global_position + near_offset + Vector3.UP * _center_height(entity)))
		_record_probe(key, "near_edge", near_hit == entity, near_hit, geometry)
		var outside_offset := _outside_offset(entity, geometry)
		var outside_hit = _rts.raycast_selection_at(_rts.camera.unproject_position(entity.global_position + outside_offset + Vector3.UP * _center_height(entity)))
		_record_probe(key, "outside", outside_hit == null or outside_hit != entity, outside_hit, geometry)
	var pair := _find_near_pair()
	if pair.size() == 2:
		var a = pair[0]
		var b = pair[1]
		await _focus_for_probe(a)
		var ahit = _rts.raycast_selection_at(_rts.camera.unproject_position(a.global_position + Vector3.UP * _center_height(a)))
		var bhit = _rts.raycast_selection_at(_rts.camera.unproject_position(b.global_position + Vector3.UP * _center_height(b)))
		var midpoint: Vector3 = (a.global_position + b.global_position) * 0.5 + Vector3.UP * _center_height(a)
		var gap_hit = _rts.raycast_selection_at(_rts.camera.unproject_position(midpoint))
		var hitbox_pass: bool = ahit == a and bhit == b and gap_hit != a and gap_hit != b
		_proof.append({"entity": "two_unit_ambiguity", "center_a": ahit == a, "center_b": bhit == b, "gap_clear": gap_hit != a and gap_hit != b, "pass": hitbox_pass})
		if not hitbox_pass: _failures.append("two_unit_ambiguity")

func _focus_for_probe(entity) -> void:
	_rts.edge_scroll = false
	_rts._cam_yaw = 0.0
	_rts._zoom = 48.0
	_rts.cam_arm.spring_length = 48.0
	_rts.focus_on(entity.global_position)
	for _i in range(3): await get_tree().process_frame

func _record_probe(key: String, edge: String, probe_pass: bool, hit, geometry: Dictionary) -> void:
	_proof.append({"entity": key, "probe": edge, "pass": probe_pass, "hit": _entity_label(hit), "geometry": geometry})
	if not probe_pass: _failures.append(key + "_" + edge + "_probe")

func _capture_near_pair() -> void:
	var pair := _find_near_pair()
	if pair.size() != 2:
		_failures.append("missing_near_pair")
		return
	_clear_selection()
	_rts._add_to_selection(pair[0])
	await _capture_entity_frame("07_TWO_UNITS_NEARBY_ONE_SELECTED", pair[0], 48.0, [pair[0]])

func _capture_multiselect() -> void:
	var selected: Array = []
	for key in ["worker", "military", "hero"]:
		var entity = _entities.get(key)
		if is_instance_valid(entity): selected.append(entity)
	_clear_selection()
	for entity in selected: _rts._add_to_selection(entity)
	if selected.is_empty():
		_failures.append("missing_multiselect_entities")
		return
	await _capture_entity_frame("08_MULTISELECT_GROUP", selected[0], 48.0, selected)

func _capture_visual(name: String, entity, selected: bool, zoom: float) -> void:
	if not is_instance_valid(entity):
		_failures.append(name + ":missing_entity")
		return
	_clear_selection()
	if selected: _rts._add_to_selection(entity)
	await _capture_entity_frame(name, entity, zoom, [entity] if selected else [])

func _capture_entity_frame(name: String, focus_entity, zoom: float, selected_entities: Array) -> void:
	if not is_instance_valid(focus_entity):
		_failures.append(name + ":missing_focus")
		return
	_rts.edge_scroll = false
	_rts._cam_yaw = 0.0
	_rts._zoom = zoom
	_rts.cam_arm.spring_length = zoom
	_rts.focus_on(focus_entity.global_position)
	for _i in range(8): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var png_path := _output.path_join(name + ".png")
	image.save_png(png_path)
	var geometry = focus_entity.get_selection_geometry() if focus_entity.has_method("get_selection_geometry") else {}
	var fixture_key := _fixture_key(focus_entity)
	_frames.append({
		"name": name,
		"png": png_path,
		"source_sha": OS.get_environment("ASCENDANT_P1S3_SOURCE_SHA"),
		"width": image.get_width(),
		"height": image.get_height(),
		"requested_width": _width,
		"requested_height": _height,
		"entity_definition_id": str(focus_entity.get("unit_id") if focus_entity is Unit else focus_entity.get("building_id")),
		"entity_type": geometry.get("entity_type", "unknown"),
		"review_fixture": fixture_key != "",
		"review_fixture_metadata": _fixture_metadata.get(fixture_key, {}),
		"selected_state": selected_entities.has(focus_entity),
		"selected_count": selected_entities.size(),
		"selection_geometry": geometry,
		"camera_zoom": float(_rts._zoom),
		"camera_position": _vec(_rts.camera.global_position),
		"camera_focus": _vec(_rts.cam_pivot.global_position),
		"timestamp_unix_ms": Time.get_unix_time_from_system() * 1000.0,
		"nonblank_bytes": image.get_data_size()
	})

func _find_near_pair() -> Array:
	var candidates: Array = []
	for commander in _world.commanders:
		if commander.team != 0: continue
		for unit in commander.units:
			if is_instance_valid(unit) and not unit.is_dead and not unit.is_hero: candidates.append(unit)
	var review_military = _fixture_entities.get("military")
	if is_instance_valid(review_military): candidates.append(review_military)
	var best: Array = []
	var best_distance := INF
	for i in range(candidates.size()):
		for j in range(i + 1, candidates.size()):
			var distance: float = candidates[i].global_position.distance_to(candidates[j].global_position)
			if distance < best_distance:
				best_distance = distance
				best = [candidates[i], candidates[j]]
	return best

func _near_offset(entity, geometry: Dictionary) -> Vector3:
	if entity is Building:
		var ext = geometry.get("visual_extents", {"x": 1.0, "z": 1.0})
		return Vector3(float(ext.get("x", 1.0)) * 0.85, 0, 0)
	return Vector3(float(geometry.get("visual_radius", 0.45)) * 0.85, 0, 0)

func _outside_offset(entity, geometry: Dictionary) -> Vector3:
	if entity is Building:
		var ext = geometry.get("visual_extents", {"x": 1.0, "z": 1.0})
		return Vector3(float(ext.get("x", 1.0)) * 1.45, 0, 0)
	return Vector3(float(geometry.get("visual_radius", 0.45)) * 1.45, 0, 0)

func _center_height(entity) -> float:
	if entity is Unit: return maxf(0.8, float(entity.def.get("height", 1.8)) * 0.5)
	return maxf(0.6, float(entity.footprint) * 0.35)

func _clear_selection() -> void:
	if _rts.has_method("_clear_selection"): _rts._clear_selection()

func _entity_label(entity) -> String:
	if not is_instance_valid(entity): return "null"
	if entity is Unit: return "unit:" + str(entity.unit_id)
	if entity is Building: return "building:" + str(entity.building_id)
	return str(entity)

func _entity_positions() -> Dictionary:
	var out := {}
	for commander in _world.commanders:
		for unit in commander.units:
			if is_instance_valid(unit): out["unit_" + str(unit.get_instance_id())] = _vec(unit.global_position)
		for building in commander.buildings:
			if is_instance_valid(building): out["building_" + str(building.get_instance_id())] = _vec(building.global_position)
	return out

func _physics_snapshot() -> Dictionary:
	var out := {}
	for commander in _world.commanders:
		for unit in commander.units:
			if is_instance_valid(unit):
				out["unit_" + str(unit.get_instance_id())] = {"layer": unit.collision_layer, "mask": unit.collision_mask, "nav_radius": unit.agent.radius if is_instance_valid(unit.agent) else -1.0, "speed": unit.move_speed, "attack_range": unit.atk_range}
		for building in commander.buildings:
			if is_instance_valid(building): out["building_" + str(building.get_instance_id())] = {"layer": building.collision_layer, "mask": building.collision_mask}
	return out

func _vec(v: Vector3) -> Dictionary:
	return {"x": snappedf(v.x, 0.001), "y": snappedf(v.y, 0.001), "z": snappedf(v.z, 0.001)}

func _write_manifest() -> void:
	var manifest := {
		"tool": "p1s3SelectionReadability",
		"schema": "ascendant-realms-p1s3-selection-readability-v1",
		"source_sha": OS.get_environment("ASCENDANT_P1S3_SOURCE_SHA"),
		"capture_mode": "non-headless Godot runtime",
		"map": "hollowspan",
		"match": "Barrosan vs Lioraen Easy",
		"review_fixture": true,
		"review_fixture_entities": _fixture_metadata,
		"review_fixture_removed_before_exit": _fixture_removed,
		"resolution": {"width": _width, "height": _height},
		"frames": _frames,
		"hitbox_proof": _proof,
		"before_positions": _before_positions,
		"after_positions": _entity_positions(),
		"before_physics": _before_physics,
		"after_physics": _physics_snapshot(),
		"failures": _failures,
		"oversized_baseline_pair": false,
		"oversized_baseline_reason": "Original recording region was not deterministically reproducible in this isolated harness; no before/after claim made.",
		"pass": _failures.is_empty()
	}
	var file := FileAccess.open(_output.path_join("selection-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest, "  "))
		file.store_line("")
	else:
		_failures.append("manifest_open_failed")

func _fixture_key(entity) -> String:
	for key in _fixture_entities:
		if _fixture_entities[key] == entity: return key
	return ""
