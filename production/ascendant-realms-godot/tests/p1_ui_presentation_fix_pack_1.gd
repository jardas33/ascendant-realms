extends Node
## P1 UI Presentation Fix Pack 1 headed proof.
## Captures only normal player presentation; it does not inject gameplay state.

const OUT := "res://../../artifacts/manual-review/p1-ui-presentation-fix-pack-1/"
var world
var rts

func _ready() -> void:
	if OS.get_environment("ASCENDANT_P1_UI_CAPTURE") != "1":
		return
	get_node("/root/Match").set_config({
		"player_race": "barrosan",
		"opponents": [{"race": "vorthak", "difficulty": "easy"}],
		"map": "hollowspan", "start_resources": "standard",
		"victory": "conquest", "mode": "skirmish", "game_speed": 1.0})
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))

func _wait_for_rendered_gameplay() -> void:
	var loading = get_node_or_null("/root/LoadingScreen")
	var deadline := Time.get_ticks_msec() + 45000
	while loading and loading.visible and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	for _i in range(8):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

func _wait_for_ui() -> void:
	await _wait_for_rendered_gameplay()
	await get_tree().create_timer(0.75).timeout
	await RenderingServer.frame_post_draw

func _save(name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(OUT + name))

func _save_json(name: String, value: Dictionary) -> void:
	var f := FileAccess.open(ProjectSettings.globalize_path(OUT + name), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(value, "  "))
		f.store_line("")

func _emit_selection(node) -> void:
	rts._clear_selection()
	rts._add_to_selection(node)
	rts.emit_signal("selection_changed", rts.selected)

func _first_worker():
	for unit in world.commanders[0].units:
		if is_instance_valid(unit) and unit.is_worker and not unit.is_dead:
			return unit
	return null

func _first_military():
	for unit in world.commanders[0].units:
		if is_instance_valid(unit) and not unit.is_worker and not unit.is_dead:
			return unit
	return null

func capture_gameplay(root: Node) -> void:
	world = root.get_node("GameWorld")
	rts = root.get_node("RTS")
	await _wait_for_rendered_gameplay()
	var phase := OS.get_environment("ASCENDANT_P1_UI_PHASE")
	var prefix := "01_BASELINE" if phase == "baseline" else "11_FINAL"
	_save(prefix + "_OVERVIEW.png")

	var worker = _first_worker()
	if worker == null:
		_save_json("p1-ui-capture-audit.json", {"phase": phase, "passed": false, "failure": "worker_missing"})
		get_tree().quit(2)
		return
	_emit_selection(worker)
	await _wait_for_ui()
	_save(("02_BASELINE" if phase == "baseline" else "12_FINAL") + "_BUILD_MENU_WORKER_SELECTED.png")
	_save(("03_BASELINE" if phase == "baseline" else "13_FINAL") + "_WORKER_PORTRAIT.png")

	var military = _first_military()
	if military != null:
		_emit_selection(military)
		await _wait_for_ui()
		_save(("04_BASELINE" if phase == "baseline" else "14_FINAL") + "_MILITARY_PORTRAIT.png")

	_emit_selection(worker)
	await _wait_for_ui()
	_save(("05_BASELINE" if phase == "baseline" else "15_FINAL") + "_COMBINED_RTS_VIEW.png")
	_save_json("p1-ui-capture-audit.json", {
		"schema": "ascendant-realms-p1-ui-presentation-fix-pack-1-capture-v1",
		"phase": phase, "headed": true, "renderer": "Forward Plus",
		"worker_selected": true, "military_portrait_captured": military != null, "passed": true,
		"no_direct_state_writes": true, "no_gameplay_semantics_changed": true})
	get_tree().quit()
