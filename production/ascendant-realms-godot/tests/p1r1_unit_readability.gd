extends Node
## P1-R1 headed visual proof: role-aware unit scale across the three human-facing races.
## This harness only observes the live scene and changes the review camera; it does
## not alter definitions, navigation, collision, movement, or combat semantics.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _role_measurements: Array = []
var _positions_before: Dictionary = {}
var _positions_after: Dictionary = {}
var _scenario_count := 0

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R1_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R1_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R1_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-a/default"
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	await _run_scenario("LIORAEN", "lioraen", "barrosan", "01_LIORAEN_DEFAULT", true)
	await _run_scenario("BARROSAN", "barrosan", "lioraen", "05_BARROSAN_MIXED", false)
	await _run_scenario("VORTHAK", "vorthak", "lioraen", "06_VORTHAK_MIXED", false)
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _run_scenario(label: String, player_race: String, opponent_race: String, mixed_frame: String, primary: bool) -> void:
	_scenario_count += 1
	get_node("/root/Match").set_config({
		"player_race": player_race,
		"opponents": [{"race": opponent_race, "difficulty": "easy"}],
		"map": "hollowspan",
		"start_resources": "standard",
		"victory": "conquest",
		"mode": "skirmish",
		"game_speed": 1.0
	})
	get_tree().change_scene_to_file("res://scenes/game_world.tscn")
	var root = null
	var world = null
	var rts = null
	var deadline := Time.get_ticks_msec() + 20000
	while Time.get_ticks_msec() < deadline:
		root = get_node_or_null("/root/GameRoot")
		world = root.get_node_or_null("GameWorld") if root else null
		rts = root.get_node_or_null("RTS") if root else null
		if root and world and rts and world.game_running: break
		await get_tree().process_frame
	if world == null or rts == null or not world.game_running:
		_failures.append(label + ":runtime_timeout")
		return
	for _i in range(12): await get_tree().process_frame
	var units := _collect_units(world)
	if not units.has("worker") or not units.has("military") or not units.has("hero"):
		_failures.append(label + ":missing_role_coverage")
		return
	_positions_before[label] = _positions(units)
	await _focus_and_capture(rts, units, "01_LIORAEN_DEFAULT" if primary else mixed_frame, 48.0, "default", label)
	if primary:
		await _focus_and_capture(rts, units, "02_LIORAEN_NEAR", 25.0, "near", label)
		await _focus_and_capture(rts, units, "03_LIORAEN_GROUP", 48.0, "group", label)
		await _focus_and_capture(rts, units, "04_LIORAEN_MIXED", 35.0, "mixed", label)
	else:
		await _focus_and_capture(rts, units, mixed_frame, 35.0, "mixed", label)
	_positions_after[label] = _positions(units)
	if _positions_before[label] != _positions_after[label]: _failures.append(label + ":positions_changed")

func _collect_units(world) -> Dictionary:
	var out := {}
	for commander in world.commanders:
		for unit in commander.units:
			if not is_instance_valid(unit) or unit.is_dead: continue
			var role := String(unit.def.get("role", ""))
			if role == "worker" and not out.has("worker"): out["worker"] = unit
			elif unit.is_hero and not out.has("hero"): out["hero"] = unit
			elif not unit.is_worker and not unit.is_hero and not out.has("military"): out["military"] = unit
	return out

func _focus_and_capture(rts, units: Dictionary, name: String, zoom: float, kind: String, label: String) -> void:
	var center := Vector3.ZERO
	for unit in units.values(): center += unit.global_position
	center /= float(units.size())
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = zoom
	rts.cam_arm.spring_length = zoom
	# Focus one real unit for deterministic gameplay-scale framing. The group is
	# still visible around it, while clamping cannot move the camera away from
	# the role evidence at the edge of the playable bounds.
	var focus = units.get("hero", units.values()[0]) if kind in ["default", "near", "mixed"] else units.values()[0]
	rts.focus_on(focus.global_position if is_instance_valid(focus) else center)
	for _i in range(8): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := _output.path_join(name + ".png")
	image.save_png(path)
	var visible_roles := []
	for role in ["worker", "military", "hero"]:
		var unit = units.get(role)
		if is_instance_valid(unit):
			var px := _projected_height(rts.camera, unit)
			_role_measurements.append({"scenario": label, "role": role, "zoom": kind, "pixels": px, "definition_id": unit.unit_id, "visual_height": float(unit.get("_visual_height"))})
			visible_roles.append({"role": role, "unit_id": unit.unit_id, "pixels": px, "position": _vec(unit.global_position)})
	_frames.append({"name": name, "png": path, "width": image.get_width(), "height": image.get_height(), "scenario": label, "kind": kind, "roles": visible_roles, "nonblank_bytes": image.get_data_size()})

func _projected_height(camera: Camera3D, unit) -> float:
	if not is_instance_valid(camera): return 0.0
	# Use the measured final visual height, then project its grounded top and
	# bottom through the live gameplay camera. This is screen-space evidence,
	# not a substitute for the model-derived selection geometry.
	var height := maxf(1.0, float(unit.get("_visual_height")))
	var top := camera.unproject_position(unit.global_position + Vector3.UP * height)
	var bottom := camera.unproject_position(unit.global_position)
	return absf(top.y - bottom.y)

func _positions(units: Dictionary) -> Dictionary:
	var out := {}
	for role in units:
		out[role] = _vec(units[role].global_position)
	return out

func _vec(p: Vector3) -> Dictionary:
	return {"x": p.x, "y": p.y, "z": p.z}

func _write_manifest() -> void:
	var manifest := {
		"schema": "ascendant-realms-p1r1-unit-readability-v1",
		"source_sha": OS.get_environment("ASCENDANT_P1R1_SOURCE_SHA"),
		"resolution": {"width": _width, "height": _height},
		"scenarios": _scenario_count,
		"frames": _frames,
		"role_measurements": _role_measurements,
		"positions_before": _positions_before,
		"positions_after": _positions_after,
		"pass": _failures.is_empty(),
		"failures": _failures
	}
	var file := _output.path_join("unit-readability-manifest.json")
	FileAccess.open(file, FileAccess.WRITE).store_string(JSON.stringify(manifest, "  "))
