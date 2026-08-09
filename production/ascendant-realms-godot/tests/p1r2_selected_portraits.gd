extends Node
## P1-R2 headed proof: selected cards show isolated, authored model portraits.
## Selection is the only live state touched; the portrait renders a duplicate
## model in a SubViewport and never participates in simulation or picking.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _positions_before := {}
var _positions_after := {}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R2_OUTPUT")
	_width = int(OS.get_environment("ASCENDANT_P1R2_WIDTH"))
	_height = int(OS.get_environment("ASCENDANT_P1R2_HEIGHT"))
	if _width <= 0: _width = 1920
	if _height <= 0: _height = 1080
	if _output.is_empty(): _output = "D:/CodexData/evidence/ascendant-realms-p1-remediation-a/p1r2/default"
	DirAccess.make_dir_recursive_absolute(_output)
	get_node("/root/Match").set_config({
		"player_race": "lioraen",
		"opponents": [{"race": "barrosan", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard", "victory": "conquest",
		"mode": "skirmish", "game_speed": 1.0
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
		_failures.append("runtime_timeout")
		_write_manifest()
		get_tree().quit(1)
		return
	for _i in 12: await get_tree().process_frame
	var entities := _collect_entities(world)
	for key in ["worker", "military", "hero", "small_building", "hq"]:
		if not entities.has(key):
			_failures.append("missing_" + key)
			continue
		var entity = entities[key]
		_positions_before[key] = _vec(entity.global_position)
		await _select_and_capture(rts, entity, key)
	_positions_after = _positions(entities)
	if JSON.stringify(_positions_before) != JSON.stringify(_positions_after):
		_failures.append("positions_changed")
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _collect_entities(world) -> Dictionary:
	var out := {}
	for u in world.player_commander.units:
		if not is_instance_valid(u) or u.is_dead: continue
		if u.is_hero and not out.has("hero"): out["hero"] = u
		elif u.is_worker and not out.has("worker"): out["worker"] = u
		elif not out.has("military"): out["military"] = u
	var buildings := []
	for b in world.player_commander.buildings:
		if is_instance_valid(b) and not b.is_dead and b.is_built: buildings.append(b)
	if buildings.size() < 2:
		for b in world.all_buildings():
			if is_instance_valid(b) and not b.is_dead and b.is_built and b not in buildings: buildings.append(b)
	for b in buildings:
		var kind := str(b.def.get("kind", ""))
		var name := str(b.def.get("name", ""))
		if not out.has("hq") and (bool(b.def.get("is_hq", false)) or kind == "main" or "Hall" in name): out["hq"] = b
		elif not out.has("small_building"): out["small_building"] = b
	if not out.has("hq") and not buildings.is_empty(): out["hq"] = buildings[0]
	if not out.has("small_building") and buildings.size() > 1: out["small_building"] = buildings[1]
	return out

func _select_and_capture(rts, entity, key: String) -> void:
	rts._clear_selection()
	rts._add_to_selection(entity)
	rts.selection_changed.emit(rts.selected)
	rts.edge_scroll = false
	rts._cam_yaw = 0.0
	rts._zoom = 32.0 if entity.get_class() == "Building" else 36.0
	rts.cam_arm.spring_length = rts._zoom
	rts.focus_on(entity.global_position)
	for _i in 12: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var path := _output.path_join(key + ".png")
	image.save_png(path)
	var probe := _portrait_probe(image)
	_frames.append({"name": key, "png": path, "width": image.get_width(), "height": image.get_height(), "portrait_probe": probe, "entity_id": str(entity.get("unit_id")) if "unit_id" in entity else str(entity.get("building_id"))})
	if probe["lit_pixels"] < 180: _failures.append(key + ":portrait_frame_black_or_empty")

func _portrait_probe(image: Image) -> Dictionary:
	var x0 := maxi(0, int(_width * 0.5 - 225.0))
	var y0 := maxi(0, int(_height - 156.0))
	var x1 := mini(image.get_width(), x0 + 110)
	var y1 := mini(image.get_height(), y0 + 104)
	var lit := 0
	var total := 0
	for y in range(y0, y1):
		for x in range(x0, x1):
			var c := image.get_pixel(x, y)
			if c.r + c.g + c.b > 0.42: lit += 1
			total += 1
	return {"x": x0, "y": y0, "width": x1 - x0, "height": y1 - y0, "lit_pixels": lit, "total_pixels": total}

func _positions(entities: Dictionary) -> Dictionary:
	var out := {}
	for key in entities: out[key] = _vec(entities[key].global_position)
	return out

func _vec(p: Vector3) -> Dictionary:
	return {"x": p.x, "y": p.y, "z": p.z}

func _write_manifest() -> void:
	var manifest := {"schema": "ascendant-realms-p1r2-selected-portraits-v1", "source_sha": OS.get_environment("ASCENDANT_P1R2_SOURCE_SHA"), "resolution": {"width": _width, "height": _height}, "frames": _frames, "positions_before": _positions_before, "positions_after": _positions_after, "pass": _failures.is_empty(), "failures": _failures}
	FileAccess.open(_output.path_join("selected-portraits-manifest.json"), FileAccess.WRITE).store_string(JSON.stringify(manifest, "  "))
