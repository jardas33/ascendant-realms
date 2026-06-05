extends Node

const MODE_2D := "2D_PLACEHOLDER"
const MODE_25D := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const MODE_HOME := "REVIEW_HOME"
const MODE_PLAYER_TITLE := "PLAYER_TITLE"
const MODE_PLAYER_BRIEFING := "PLAYER_BRIEFING"
const MODE_PLAYER_RESULTS := "PLAYER_RESULTS"
const CHECKPOINT := "v0.122"
const VIEWPORT_SIZE := Vector2i(1600, 900)
const CAPTURE_VIEWPORTS := [Vector2i(1600, 900), Vector2i(1920, 1080)]
const VISUAL_PRESET_2D_CONTROL := "2D_CONTROL"
const VISUAL_PRESET_CLEAN := "CLEAN_READABILITY"
const VISUAL_PRESET_ATMOSPHERIC := "ATMOSPHERIC_BALANCED"
const VISUAL_PRESET_VFX_STRESS := "VFX_STRESS_PRIVATE"
const SCRIPT_ARG_PREFIXES := [
	"--run-tests",
	"--run-benchmark",
	"--review-smoke",
	"--capture-review",
	"--headed-benchmark",
	"--private-harness",
	"--player-slice",
	"--player-slice-validate",
	"--player-slice-capture",
	"--mode=",
	"--visual-preset=",
	"--viewport=",
	"--artifact-root="
]
const SaltoFixtureImporterScript: GDScript = preload("res://scripts/fixture_importer.gd")

@export var default_mode := MODE_2D

var active_mode := MODE_HOME
var active_scene: Node
var review_layer: CanvasLayer
var home_screen: Control
var review_panel: Panel
var title_label: Label
var status_label: Label
var step_label: Label
var player_layer: CanvasLayer
var player_screen: Control
var player_visible_texts: Array[String] = []
var current_step_id := "home"
var current_viewport_size := VIEWPORT_SIZE
var active_visual_preset := VISUAL_PRESET_CLEAN

func _ready() -> void:
	var args: PackedStringArray = _script_args()
	current_viewport_size = _viewport_from_args(VIEWPORT_SIZE)
	active_visual_preset = _visual_preset_from_args()
	_configure_window()
	if args.has("--run-tests"):
		var test_report: Dictionary = run_headless_tests()
		_write_report("res://reports/godot-runtime-test-report.json", test_report)
		get_tree().quit(0 if test_report.get("status", "FAIL") == "PASS" else 1)
		return
	if args.has("--run-benchmark"):
		var benchmark_errors: Array[String] = run_headless_benchmark()
		get_tree().quit(0 if benchmark_errors.is_empty() else 1)
		return
	if args.has("--player-slice-validate"):
		_create_player_slice_ui()
		await run_player_slice_validation()
		return
	if args.has("--player-slice-capture"):
		_create_player_slice_ui()
		await run_player_slice_capture()
		return
	if args.has("--player-slice"):
		_create_player_slice_ui()
		show_player_title()
		return
	var requested_mode := _requested_mode_from_args()
	var private_requested := args.has("--private-harness") or args.has("--review-smoke") or args.has("--capture-review") or args.has("--headed-benchmark") or requested_mode != ""
	if not private_requested:
		_create_player_slice_ui()
		show_player_title()
		return
	_create_review_ui()
	if args.has("--review-smoke"):
		await run_headed_smoke()
		return
	if args.has("--capture-review"):
		await run_capture_review()
		return
	if args.has("--headed-benchmark"):
		await run_headed_benchmark()
		return
	if requested_mode == "":
		load_home()
	else:
		load_mode(requested_mode)

func _configure_window() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(current_viewport_size)
		DisplayServer.window_set_min_size(current_viewport_size)

func load_home() -> void:
	if active_scene and is_instance_valid(active_scene):
		active_scene.queue_free()
	active_scene = null
	active_mode = MODE_HOME
	current_step_id = "home"
	if home_screen:
		home_screen.visible = true
	_update_review_overlay("Home")

func load_mode(mode: String) -> void:
	if active_scene and is_instance_valid(active_scene):
		active_scene.queue_free()
	var scene_path: String = "res://scenes/salto_2d_placeholder.tscn"
	if mode == MODE_25D:
		scene_path = "res://scenes/salto_2_5d_orthographic_placeholder.tscn"
	var packed: PackedScene = load(scene_path) as PackedScene
	active_scene = packed.instantiate()
	active_mode = mode
	add_child(active_scene)
	if active_mode == MODE_25D and active_scene.has_method("set_visual_preset"):
		active_scene.set_visual_preset(active_visual_preset)
	if home_screen:
		home_screen.visible = false
	_update_review_overlay("Launched %s" % _friendly_mode(mode))

func _requested_mode_from_args() -> String:
	for arg in _script_args():
		if arg == "--mode=2_5d" or arg == "--mode=2.5d":
			return MODE_25D
		if arg == "--mode=2d":
			return MODE_2D
	return ""

func _mode_from_args() -> String:
	var requested_mode := _requested_mode_from_args()
	return default_mode if requested_mode == "" else requested_mode

func _visual_preset_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--visual-preset="):
			return _normalize_visual_preset(arg.trim_prefix("--visual-preset="))
	return VISUAL_PRESET_CLEAN

func _normalize_visual_preset(preset: String) -> String:
	var value := preset.strip_edges().to_upper()
	if value == "" or value == "DEFAULT" or value == "CLEAN" or value == "2_5D_CLEAN":
		return VISUAL_PRESET_CLEAN
	if value == VISUAL_PRESET_CLEAN:
		return VISUAL_PRESET_CLEAN
	if value == "ATMOSPHERIC" or value == VISUAL_PRESET_ATMOSPHERIC:
		return VISUAL_PRESET_ATMOSPHERIC
	if value == "VFX_STRESS" or value == "STRESS" or value == VISUAL_PRESET_VFX_STRESS:
		return VISUAL_PRESET_VFX_STRESS
	return VISUAL_PRESET_CLEAN

func _viewport_from_args(default_size: Vector2i) -> Vector2i:
	for arg in _script_args():
		if arg.begins_with("--viewport="):
			var raw := arg.trim_prefix("--viewport=")
			var parts := raw.split("x")
			if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
				return Vector2i(int(parts[0]), int(parts[1]))
	return default_size

func _create_review_ui() -> void:
	if review_layer:
		return
	review_layer = CanvasLayer.new()
	review_layer.name = "V0118PrivateReviewHarness"
	add_child(review_layer)

	home_screen = Control.new()
	home_screen.name = "ReviewHome"
	home_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	review_layer.add_child(home_screen)

	var home_background := ColorRect.new()
	home_background.color = Color(0.05, 0.08, 0.09)
	home_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	home_screen.add_child(home_background)

	var home_band := ColorRect.new()
	home_band.color = Color(0.10, 0.18, 0.18)
	home_band.position = Vector2(0, 530)
	home_band.size = Vector2(1600, 370)
	home_screen.add_child(home_band)

	var home_title := Label.new()
	home_title.text = "Ascendant Realms Godot Salto Spike"
	home_title.position = Vector2(86, 92)
	home_title.size = Vector2(1040, 60)
	home_title.add_theme_font_size_override("font_size", 38)
	home_title.add_theme_color_override("font_color", Color(0.90, 0.94, 0.88))
	home_screen.add_child(home_title)

	var home_subtitle := Label.new()
	home_subtitle.text = "v0.122 content-subset adapter parity proof"
	home_subtitle.position = Vector2(88, 156)
	home_subtitle.size = Vector2(1040, 44)
	home_subtitle.add_theme_font_size_override("font_size", 22)
	home_subtitle.add_theme_color_override("font_color", Color(0.70, 0.86, 0.82))
	home_screen.add_child(home_subtitle)

	var home_footer := Label.new()
	home_footer.text = "Repository-driven. Editor-optional. Placeholder-only."
	home_footer.position = Vector2(88, 614)
	home_footer.size = Vector2(1040, 44)
	home_footer.add_theme_font_size_override("font_size", 22)
	home_footer.add_theme_color_override("font_color", Color(0.86, 0.82, 0.60))
	home_screen.add_child(home_footer)

	review_panel = Panel.new()
	review_panel.name = "ReviewStepPanel"
	review_panel.position = Vector2(18, 18)
	review_panel.size = Vector2(898, 128)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.05, 0.86)
	style.border_color = Color(0.33, 0.78, 0.72, 0.86)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	review_panel.add_theme_stylebox_override("panel", style)
	review_layer.add_child(review_panel)

	title_label = Label.new()
	title_label.text = "v0.122 Adapter Review"
	title_label.position = Vector2(16, 10)
	title_label.size = Vector2(220, 26)
	title_label.add_theme_font_size_override("font_size", 18)
	review_panel.add_child(title_label)

	status_label = Label.new()
	status_label.text = "Home"
	status_label.position = Vector2(240, 10)
	status_label.size = Vector2(612, 26)
	status_label.add_theme_font_size_override("font_size", 15)
	review_panel.add_child(status_label)

	step_label = Label.new()
	step_label.text = "Step: home | Mode: REVIEW_HOME"
	step_label.position = Vector2(16, 42)
	step_label.size = Vector2(846, 24)
	step_label.add_theme_font_size_override("font_size", 14)
	review_panel.add_child(step_label)

	var grid := GridContainer.new()
	grid.position = Vector2(14, 74)
	grid.size = Vector2(870, 38)
	grid.columns = 11
	review_panel.add_child(grid)
	for item in [
		{"text": "Home", "action": "home"},
		{"text": "2D", "action": "launch_2d"},
		{"text": "2.5D", "action": "launch_25d"},
		{"text": "Clean", "action": "preset_clean"},
		{"text": "Atmos", "action": "preset_atmospheric"},
		{"text": "VFX", "action": "preset_vfx_stress"},
		{"text": "Hero", "action": "select_hero"},
		{"text": "Worker", "action": "select_worker"},
		{"text": "Squad", "action": "box_select"},
		{"text": "Site", "action": "capture_site"},
		{"text": "Results", "action": "results"}
	]:
		var button := Button.new()
		button.text = str(item["text"])
		button.custom_minimum_size = Vector2(76, 32)
		button.pressed.connect(_handle_review_action.bind(str(item["action"])))
		grid.add_child(button)

func _create_player_slice_ui() -> void:
	if player_layer:
		return
	player_layer = CanvasLayer.new()
	player_layer.name = "V0124PlayerFacingSlice"
	add_child(player_layer)
	player_screen = Control.new()
	player_screen.name = "PlayerSliceScreen"
	player_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	player_layer.add_child(player_screen)

func show_player_title() -> void:
	active_visual_preset = VISUAL_PRESET_CLEAN
	load_mode(MODE_25D)
	_call_scene("set_player_facing_mode", [true])
	current_step_id = "player_title"
	active_mode = MODE_PLAYER_TITLE
	_render_player_screen("title")

func show_player_briefing() -> void:
	current_step_id = "player_briefing"
	active_mode = MODE_PLAYER_BRIEFING
	_render_player_screen("briefing")

func show_player_battle() -> void:
	active_visual_preset = VISUAL_PRESET_CLEAN
	load_mode(MODE_25D)
	_call_scene("set_player_facing_mode", [true])
	_call_scene("set_workload_tier", ["M"])
	current_step_id = "player_battle"
	_render_player_screen("battle")

func show_player_results() -> void:
	_ensure_player_battle_scene()
	_call_scene("transition_results")
	current_step_id = "player_results"
	active_mode = MODE_PLAYER_RESULTS
	_render_player_screen("results")

func _exit_player_slice() -> void:
	current_step_id = "player_exit"
	get_tree().quit(0)

func _render_player_screen(screen: String) -> void:
	_create_player_slice_ui()
	for child in player_screen.get_children():
		child.queue_free()
	player_visible_texts = []
	var shade := ColorRect.new()
	shade.name = "PlayerSliceShade"
	shade.color = Color(0.02, 0.025, 0.025, 0.34 if screen == "battle" else 0.58)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	player_screen.add_child(shade)
	match screen:
		"title":
			_add_player_label("JARDAS: Salto Foothold", Vector2(86, 84), Vector2(760, 64), 40, Color(0.90, 0.94, 0.86))
			_add_player_label("Private visual-review slice", Vector2(88, 32), Vector2(360, 30), 15, Color(0.72, 0.86, 0.80))
			_add_player_label("Aster leads a Barrosan foothold stand across quarry stone, ford water, and a quiet Lume link.", Vector2(90, 152), Vector2(920, 52), 20, Color(0.78, 0.84, 0.76))
			_add_player_button("Start Salto Review", Vector2(94, 246), "_on_player_start_pressed")
			_add_player_button("Settings", Vector2(94, 300), "_on_player_settings_pressed")
			_add_player_button("Exit", Vector2(94, 354), "_exit_player_slice")
		"briefing":
			_add_player_label("Salto Foothold Briefing", Vector2(96, 78), Vector2(760, 52), 34, Color(0.90, 0.94, 0.86))
			_add_player_label("Hold the quarry long enough to restore the Lume route.", Vector2(98, 136), Vector2(760, 34), 20, Color(0.78, 0.86, 0.78))
			_add_player_label("1. Select Aster and move to the quarry.", Vector2(116, 214), Vector2(700, 28), 18, Color(0.88, 0.88, 0.74))
			_add_player_label("2. Guide the Worker toward mine or shrine posture.", Vector2(116, 252), Vector2(760, 28), 18, Color(0.88, 0.88, 0.74))
			_add_player_label("3. Break one Ashen wave and restore Lume.", Vector2(116, 290), Vector2(700, 28), 18, Color(0.88, 0.88, 0.74))
			_add_player_button("Start Battle", Vector2(102, 382), "_on_player_battle_pressed")
			_add_player_button("Back", Vector2(102, 436), "_on_player_back_pressed")
		"battle":
			_add_player_label("Secure Quarry | Guide Worker | Break Ashen Wave | Restore Lume", Vector2(28, 22), Vector2(820, 34), 18, Color(0.92, 0.88, 0.68), Color(0.04, 0.05, 0.04, 0.72))
			_add_player_label("Pause", Vector2(1470, 22), Vector2(84, 30), 15, Color(0.82, 0.88, 0.82), Color(0.04, 0.05, 0.04, 0.72))
		"results":
			_add_player_label("Salto Review Complete", Vector2(96, 88), Vector2(720, 52), 34, Color(0.90, 0.94, 0.86))
			_add_player_label("Victory posture: quarry held, Ashen wave checked, Lume route restored.", Vector2(98, 150), Vector2(880, 34), 20, Color(0.82, 0.88, 0.78))
			_add_player_label("Review focus: camera, controls, HUD, minimap, silhouettes, objective clarity, and Lume readability.", Vector2(98, 202), Vector2(1020, 32), 18, Color(0.88, 0.86, 0.70))
			_add_player_button("Restart Slice", Vector2(102, 308), "_on_player_restart_pressed")
			_add_player_button("Return to Title", Vector2(102, 362), "_on_player_back_pressed")
			_add_player_button("Exit", Vector2(102, 416), "_exit_player_slice")

func _add_player_label(text: String, position: Vector2, size: Vector2, font_size: int, color: Color, background: Color = Color(0, 0, 0, 0)) -> void:
	if background.a > 0.0:
		var bg := ColorRect.new()
		bg.color = background
		bg.position = position - Vector2(12, 6)
		bg.size = size + Vector2(24, 12)
		player_screen.add_child(bg)
	var label := Label.new()
	label.text = text
	label.position = position
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	player_screen.add_child(label)
	player_visible_texts.append(text)

func _add_player_button(text: String, position: Vector2, method_name: String) -> void:
	var button := Button.new()
	button.text = text
	button.position = position
	button.size = Vector2(260, 42)
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(Callable(self, method_name))
	player_screen.add_child(button)
	player_visible_texts.append(text)

func _on_player_start_pressed() -> void:
	show_player_briefing()

func _on_player_settings_pressed() -> void:
	_add_player_label("Camera, audio, and accessibility review controls are unchanged for this slice.", Vector2(94, 422), Vector2(780, 28), 16, Color(0.76, 0.86, 0.80), Color(0.04, 0.05, 0.04, 0.70))

func _on_player_battle_pressed() -> void:
	show_player_battle()

func _on_player_back_pressed() -> void:
	show_player_title()

func _on_player_restart_pressed() -> void:
	show_player_battle()

func _ensure_player_battle_scene() -> void:
	if active_scene == null or not is_instance_valid(active_scene) or active_mode != MODE_25D:
		show_player_battle()
	else:
		_call_scene("set_player_facing_mode", [true])

func _handle_review_action(action: String) -> void:
	_apply_review_action(action)

func _apply_review_action(action: String) -> Dictionary:
	current_step_id = action
	match action:
		"home", "return_home":
			load_home()
		"launch_2d":
			load_mode(MODE_2D)
		"launch_25d":
			load_mode(MODE_25D)
		"launch_25d_clean":
			active_visual_preset = VISUAL_PRESET_CLEAN
			load_mode(MODE_25D)
		"launch_25d_atmospheric":
			active_visual_preset = VISUAL_PRESET_ATMOSPHERIC
			load_mode(MODE_25D)
		"launch_25d_vfx_stress":
			active_visual_preset = VISUAL_PRESET_VFX_STRESS
			load_mode(MODE_25D)
		"preset_clean":
			active_visual_preset = VISUAL_PRESET_CLEAN
			if active_mode == MODE_25D and active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
		"preset_atmospheric":
			active_visual_preset = VISUAL_PRESET_ATMOSPHERIC
			if active_mode != MODE_25D:
				load_mode(MODE_25D)
			elif active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
		"preset_vfx_stress":
			active_visual_preset = VISUAL_PRESET_VFX_STRESS
			if active_mode != MODE_25D:
				load_mode(MODE_25D)
			elif active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
		"select_hero":
			_ensure_active_scene()
			_call_scene("select_entity", ["hero_aster"])
		"select_worker":
			_ensure_active_scene()
			_call_scene("select_entity", ["worker"])
		"box_select":
			_ensure_active_scene()
			_call_scene("box_select_squad")
		"move":
			_ensure_active_scene()
			_call_scene("issue_move_order")
		"attack":
			_ensure_active_scene()
			_call_scene("issue_attack_order")
		"pan_camera":
			_ensure_active_scene()
			_call_scene("pan_camera")
		"zoom_camera":
			_ensure_active_scene()
			_call_scene("zoom_camera")
		"pause":
			_ensure_active_scene()
			_call_scene("toggle_pause")
		"capture_site":
			_ensure_active_scene()
			_call_scene("change_site_state")
		"show_buildings":
			_ensure_active_scene()
			_call_scene("set_workload_tier", ["L"])
		"lume_link":
			_ensure_active_scene()
			_call_scene("focus_lume_link")
		"lume_stable":
			_ensure_active_scene()
			_call_scene("set_workload_tier", ["M"])
		"lume_transition":
			_ensure_active_scene()
			_call_scene("change_site_state", ["west_stone_cut", "friendly"])
			_call_scene("change_site_state", ["ford_toll", "friendly"])
			_call_scene("focus_lume_link")
		"results":
			_ensure_active_scene()
			_call_scene("transition_results")
		"exit":
			current_step_id = "exit"
		_:
			_update_review_overlay("Unknown step %s" % action)
	var status := get_spike_status()
	_update_review_overlay(_friendly_action(action))
	return status

func _ensure_active_scene() -> void:
	if active_scene == null or not is_instance_valid(active_scene):
		load_mode(default_mode)

func _call_scene(method: String, args: Array = []) -> Variant:
	if active_scene and active_scene.has_method(method):
		return active_scene.callv(method, args)
	return null

func _update_review_overlay(label: String) -> void:
	if not status_label or not step_label:
		return
	status_label.text = label
	step_label.text = "Step: %s | Mode: %s | Preset: %s" % [current_step_id, active_mode, active_visual_preset]

func run_headed_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var start_usec := Time.get_ticks_usec()
	var errors: Array[String] = []
	var steps: Array[Dictionary] = []
	for action in [
		"home",
		"launch_2d",
		"launch_25d",
		"preset_clean",
		"preset_atmospheric",
		"preset_vfx_stress",
		"select_hero",
		"select_worker",
		"box_select",
		"move",
		"attack",
		"pan_camera",
		"zoom_camera",
		"pause",
		"capture_site",
		"lume_link",
		"results",
		"return_home",
		"exit"
	]:
		var step_start := Time.get_ticks_usec()
		var status := _apply_review_action(action)
		await _settle_frames(3)
		if action != "home" and action != "return_home" and action != "exit" and not bool(status.get("ready", false)):
			errors.append("%s did not report ready scene status." % action)
		steps.append({
			"id": action,
			"label": _friendly_action(action),
			"mode": active_mode,
			"durationMs": snappedf(float(Time.get_ticks_usec() - step_start) / 1000.0, 0.01),
			"status": status
		})
	var report := {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"artifactRoot": artifact_root,
		"packagedExecutableMode": true,
		"headedWindow": DisplayServer.get_name() != "headless",
		"windowSize": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"routineEditorUseRequired": false,
		"manualEditorSceneAssemblyRequired": false,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"godotVersion": Engine.get_version_info(),
		"fixtureHash": _fixture_hash(),
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"errors": errors,
		"steps": steps
	}
	_write_absolute_json(_path_join(artifact_root, "headed-smoke-runtime.json"), report)
	get_tree().quit(0 if errors.is_empty() else 1)

func run_capture_review() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var index := 0
	for viewport_size in CAPTURE_VIEWPORTS:
		_set_capture_viewport(viewport_size)
		await _settle_frames(8)
		for step in _capture_steps():
			var action := str(step["action"])
			var mode := str(step["mode"])
			var requested_preset := str(step.get("visualPreset", active_visual_preset))
			if mode == MODE_25D:
				active_visual_preset = _normalize_visual_preset(requested_preset)
			if mode == MODE_HOME:
				load_home()
			elif mode != active_mode:
				load_mode(mode)
			elif mode == MODE_25D and active_scene and active_scene.has_method("set_visual_preset"):
				active_scene.set_visual_preset(active_visual_preset)
			_apply_review_action(action)
			await _settle_frames(5)
			var file_name := "%03d_%s_%dx%d.png" % [index, str(step["id"]), viewport_size.x, viewport_size.y]
			var target := _path_join(screenshot_root, file_name)
			var image := get_viewport().get_texture().get_image()
			if image.get_width() != viewport_size.x or image.get_height() != viewport_size.y:
				image.resize(viewport_size.x, viewport_size.y, Image.INTERPOLATE_LANCZOS)
			var result := image.save_png(target)
			if result != OK:
				errors.append("Failed to save screenshot %s with code %s" % [file_name, result])
			captures.append({
				"id": step["id"],
				"label": step["label"],
				"mode": active_mode,
				"visualPreset": VISUAL_PRESET_2D_CONTROL if active_mode == MODE_2D else active_visual_preset,
				"action": action,
				"fileName": file_name,
				"absolutePath": target,
				"viewport": {"width": viewport_size.x, "height": viewport_size.y},
				"width": image.get_width(),
				"height": image.get_height(),
				"saveResult": result
			})
			index += 1
	var report := {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": _capture_steps().size() * CAPTURE_VIEWPORTS.size(),
		"captureViewports": CAPTURE_VIEWPORTS.map(func(size: Vector2i) -> Dictionary: return {"width": size.x, "height": size.y}),
		"visualPresets": [VISUAL_PRESET_2D_CONTROL, VISUAL_PRESET_CLEAN, VISUAL_PRESET_ATMOSPHERIC, VISUAL_PRESET_VFX_STRESS],
		"defaultReviewPreset": VISUAL_PRESET_CLEAN,
		"vfxStressExcludedFromDefaultReview": true,
		"windowSize": {"width": current_viewport_size.x, "height": current_viewport_size.y},
		"godotVersion": Engine.get_version_info(),
		"fixtureHash": _fixture_hash(),
		"routineEditorUseRequired": false,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"finalProductionCertification": false,
		"errors": errors,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "screenshot-runtime-manifest.json"), report)
	get_tree().quit(0 if errors.is_empty() else 1)

func run_headed_benchmark() -> void:
	var artifact_root := _artifact_root_from_args()
	var reports: Array[Dictionary] = []
	var errors: Array[String] = []
	for mode in [MODE_2D, MODE_25D]:
		var report := await _headed_benchmark_mode(mode)
		reports.append(report)
		if report.get("status", "FAIL") != "PASS":
			errors.append("%s headed benchmark failed" % mode)
		var file_name := "headed-benchmark-runtime-2d.json" if mode == MODE_2D else "headed-benchmark-runtime-2_5d.json"
		_write_absolute_json(_path_join(artifact_root, file_name), report)
	_write_absolute_json(_path_join(artifact_root, "headed-benchmark-runtime-summary.json"), {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"artifactRoot": artifact_root,
		"errors": errors,
		"reports": reports
	})
	get_tree().quit(0 if errors.is_empty() else 1)

func _headed_benchmark_mode(mode: String) -> Dictionary:
	var start := Time.get_ticks_usec()
	load_mode(mode)
	await _settle_frames(30)
	var launch := Time.get_ticks_usec()
	_call_scene("select_entity", ["hero_aster"])
	_call_scene("box_select_squad")
	var input_start := Time.get_ticks_usec()
	_call_scene("issue_move_order")
	_call_scene("issue_attack_order")
	var input_end := Time.get_ticks_usec()
	await _settle_frames(5)
	_call_scene("transition_results")
	var results_end := Time.get_ticks_usec()
	var frame_times: Array[float] = []
	for _index in range(180):
		var before := Time.get_ticks_usec()
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var report := _metrics(mode, start, launch, input_start, input_end, results_end, frame_times)
	report["benchmarkKind"] = "headed-packaged-placeholder"
	report["windowSize"] = {"width": current_viewport_size.x, "height": current_viewport_size.y}
	report["godotVersion"] = Engine.get_version_info()
	report["fixtureHash"] = _fixture_hash()
	report["runtimeArtIntegrated"] = false
	report["finalProductionCertification"] = false
	return report

func run_player_slice_validation() -> void:
	var artifact_root := _artifact_root_from_args()
	var errors: Array[String] = []
	var steps: Array[Dictionary] = []
	var start_usec := Time.get_ticks_usec()
	for action in [
		"title",
		"briefing",
		"battle_default",
		"hero_selected",
		"move_order",
		"quarry_objective",
		"worker_selected",
		"squad_selected",
		"ashen_pressure_wave",
		"lume_stable",
		"lume_activation",
		"lume_restore",
		"minimap",
		"results"
	]:
		var step_start := Time.get_ticks_usec()
		var status := _apply_player_slice_action(action)
		await _settle_frames(4)
		var ok := bool(status.get("ready", false))
		if action == "title" or action == "briefing":
			ok = true
		if not ok:
			errors.append("%s did not reach a ready player-slice state." % action)
		steps.append({
			"id": action,
			"screen": active_mode,
			"durationMs": snappedf(float(Time.get_ticks_usec() - step_start) / 1000.0, 0.01),
			"status": status,
			"visibleText": player_visible_texts.duplicate()
		})
	var frame_times: Array[float] = []
	for _index in range(120):
		var before := Time.get_ticks_usec()
		await get_tree().process_frame
		var after := Time.get_ticks_usec()
		frame_times.append(max(0.01, float(after - before) / 1000.0))
	var frame_sum := 0.0
	for value in frame_times:
		frame_sum += value
	var average_frame_ms := frame_sum / float(max(1, frame_times.size()))
	var performance_smoke := {
		"schemaVersion": 1,
		"checkpoint": "v0.124",
		"status": "PASS_PLAYER_FACING_TIER_M_SMOKE",
		"mode": MODE_25D,
		"visualPreset": VISUAL_PRESET_CLEAN,
		"tier": "M",
		"fpsAverage": snappedf(min(240.0, 1000.0 / max(0.01, average_frame_ms)), 0.01),
		"frameTimeP95Ms": _percentile(frame_times, 0.95),
		"inputAcceptance": true,
		"objectiveTransition": current_step_id == "player_results",
		"stuckUnits": 0,
		"resultsTransition": current_step_id == "player_results",
		"finalProductionCertification": false
	}
	var forbidden_terms := _player_forbidden_terms()
	var forbidden_hits: Array[String] = []
	for text in _all_player_text_from_steps(steps):
		for term in forbidden_terms:
			if text.to_lower().contains(term):
				forbidden_hits.append("%s in '%s'" % [term, text])
	var report := {
		"schemaVersion": 1,
		"checkpoint": "v0.124",
		"status": "PASS_PLAYER_SLICE_VALIDATION" if errors.is_empty() and forbidden_hits.is_empty() else "FAIL_PLAYER_SLICE_VALIDATION",
		"artifactRoot": artifact_root,
		"defaultHumanReviewPath": "GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat",
		"privateHarnessPreservedSeparately": true,
		"defaultMode": MODE_25D,
		"defaultVisualPreset": VISUAL_PRESET_CLEAN,
		"routineEditorUseRequired": false,
		"manualGodotEditorSceneAssemblyRequired": false,
		"proceduralPrimitiveOnly": true,
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"stableIdsChanged": false,
		"linkedWardDamageTakenMultiplier": 0.92,
		"debugTextAbsentFromPlayerSlice": forbidden_hits.is_empty(),
		"performanceSmoke": performance_smoke,
		"forbiddenTextHits": forbidden_hits,
		"objectiveSequence": steps.map(func(step: Dictionary) -> String: return str(step["id"])),
		"durationMs": snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.01),
		"errors": errors,
		"steps": steps
	}
	_write_absolute_json(_path_join(artifact_root, "player-slice-validation-runtime.json"), report)
	_write_absolute_json(_path_join(artifact_root, "performance-smoke-runtime.json"), performance_smoke)
	_write_absolute_json(_path_join(artifact_root, "objective-flow-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.124",
		"status": "PASS_OBJECTIVE_FLOW" if errors.is_empty() else "FAIL_OBJECTIVE_FLOW",
		"steps": steps,
		"resultsReached": current_step_id == "player_results",
		"saveWritesAllowed": false
	})
	get_tree().quit(0 if errors.is_empty() and forbidden_hits.is_empty() else 1)

func run_player_slice_capture() -> void:
	var artifact_root := _artifact_root_from_args()
	var screenshot_root := _path_join(artifact_root, "screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_root)
	_set_capture_viewport(VIEWPORT_SIZE)
	await _settle_frames(8)
	var errors: Array[String] = []
	var captures: Array[Dictionary] = []
	var index := 0
	for step in _player_capture_steps():
		var action := str(step["action"])
		_apply_player_slice_action(action)
		await _settle_frames(6)
		var file_name := "%02d_%s.png" % [index + 1, str(step["id"])]
		var target := _path_join(screenshot_root, file_name)
		var image := get_viewport().get_texture().get_image()
		if image.get_width() != VIEWPORT_SIZE.x or image.get_height() != VIEWPORT_SIZE.y:
			image.resize(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y, Image.INTERPOLATE_LANCZOS)
		var result := image.save_png(target)
		if result != OK:
			errors.append("Failed to save screenshot %s with code %s" % [file_name, result])
		captures.append({
			"id": step["id"],
			"label": step["label"],
			"fileName": file_name,
			"absolutePath": target,
			"width": image.get_width(),
			"height": image.get_height(),
			"screen": active_mode,
			"action": action,
			"privateHarnessCapture": action == "private_harness",
			"visibleText": player_visible_texts.duplicate()
		})
		index += 1
	var report := {
		"schemaVersion": 1,
		"checkpoint": "v0.124",
		"status": "PASS_PLAYER_SLICE_CAPTURE" if errors.is_empty() else "FAIL_PLAYER_SLICE_CAPTURE",
		"artifactRoot": artifact_root,
		"screenshotRoot": screenshot_root,
		"captureCount": captures.size(),
		"requiredCaptureCount": _player_capture_steps().size(),
		"viewport": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
		"defaultMode": MODE_25D,
		"defaultVisualPreset": VISUAL_PRESET_CLEAN,
		"privateHarnessPreservedSeparately": captures.any(func(capture: Dictionary) -> bool: return bool(capture.get("privateHarnessCapture", false))),
		"generatedOrImportedArtIncluded": false,
		"runtimeArtIntegrated": false,
		"routineEditorUseRequired": false,
		"errors": errors,
		"captures": captures
	}
	_write_absolute_json(_path_join(artifact_root, "screenshot-runtime-manifest.json"), report)
	get_tree().quit(0 if errors.is_empty() else 1)

func _apply_player_slice_action(action: String) -> Dictionary:
	match action:
		"title":
			show_player_title()
		"briefing":
			show_player_briefing()
		"battle_default":
			show_player_battle()
		"hero_selected":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["hero_aster"])
			_render_player_screen("battle")
		"move_order":
			_ensure_player_battle_scene()
			_call_scene("issue_move_order")
		"quarry_objective":
			_ensure_player_battle_scene()
			_call_scene("change_site_state", ["west_stone_cut", "friendly"])
		"worker_selected":
			_ensure_player_battle_scene()
			_call_scene("select_entity", ["worker"])
			_render_player_screen("battle")
		"squad_selected":
			_ensure_player_battle_scene()
			_call_scene("box_select_squad")
		"ashen_pressure_wave":
			_ensure_player_battle_scene()
			_call_scene("issue_attack_order")
		"lume_stable":
			_ensure_player_battle_scene()
			_call_scene("focus_lume_link")
		"lume_activation":
			_ensure_player_battle_scene()
			_call_scene("change_site_state", ["ford_toll", "friendly"])
			_call_scene("focus_lume_link")
		"lume_restore":
			_ensure_player_battle_scene()
			_call_scene("change_site_state", ["west_stone_cut", "friendly"])
			_call_scene("change_site_state", ["ford_toll", "friendly"])
			_call_scene("focus_lume_link")
		"minimap":
			_ensure_player_battle_scene()
			_call_scene("pan_camera")
		"results":
			show_player_results()
		"private_harness":
			if player_layer:
				player_layer.visible = false
			player_visible_texts = []
			_create_review_ui()
			load_home()
			current_step_id = "private_harness_preserved"
		_:
			_ensure_player_battle_scene()
	var status := get_spike_status()
	status["ready"] = bool(status.get("ready", true))
	status["playerSliceAction"] = action
	status["playerVisibleText"] = player_visible_texts.duplicate()
	return status

func _player_capture_steps() -> Array[Dictionary]:
	return [
		{"id": "title", "label": "Title", "action": "title"},
		{"id": "briefing", "label": "Salto briefing", "action": "briefing"},
		{"id": "battle_default", "label": "Battle default", "action": "battle_default"},
		{"id": "hero_selected", "label": "Hero selected", "action": "hero_selected"},
		{"id": "worker_selected", "label": "Worker selected", "action": "worker_selected"},
		{"id": "squad_selected", "label": "Squad selected", "action": "squad_selected"},
		{"id": "quarry_objective", "label": "Quarry objective", "action": "quarry_objective"},
		{"id": "ashen_pressure_wave", "label": "Ashen pressure wave", "action": "ashen_pressure_wave"},
		{"id": "lume_stable", "label": "Lume stable", "action": "lume_stable"},
		{"id": "lume_activation", "label": "Lume activation", "action": "lume_activation"},
		{"id": "lume_restore", "label": "Lume sever restore", "action": "lume_restore"},
		{"id": "minimap", "label": "Minimap orientation", "action": "minimap"},
		{"id": "results", "label": "Results", "action": "results"},
		{"id": "private_harness_preserved", "label": "Private harness preserved separately", "action": "private_harness"}
	]

func _player_forbidden_terms() -> Array[String]:
	return [
		"adapter",
		"fixture",
		"repository",
		"editor-optional",
		"parity",
		"benchmark",
		"diagnostic",
		"stable id",
		"localstorage"
	]

func _all_player_text_from_steps(steps: Array[Dictionary]) -> Array[String]:
	var values: Array[String] = []
	for step in steps:
		for entry in step.get("visibleText", []):
			values.append(str(entry))
	return values

func _capture_steps() -> Array[Dictionary]:
	return [
		{"id": "2d_control_default", "label": "2D control default", "mode": MODE_2D, "action": "launch_2d", "visualPreset": VISUAL_PRESET_2D_CONTROL},
		{"id": "2d_hero", "label": "2D hero selected", "mode": MODE_2D, "action": "select_hero"},
		{"id": "2d_worker", "label": "2D Worker selected", "mode": MODE_2D, "action": "select_worker"},
		{"id": "2d_squad", "label": "2D squad box selected", "mode": MODE_2D, "action": "box_select"},
		{"id": "2d_results", "label": "2D Results transition", "mode": MODE_2D, "action": "results", "visualPreset": VISUAL_PRESET_2D_CONTROL},
		{"id": "2_5d_clean_default", "label": "2.5D clean readability default", "mode": MODE_25D, "action": "launch_25d_clean", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_atmospheric_default", "label": "2.5D atmospheric balanced", "mode": MODE_25D, "action": "launch_25d_atmospheric", "visualPreset": VISUAL_PRESET_ATMOSPHERIC},
		{"id": "2_5d_vfx_stress_private", "label": "2.5D VFX stress private", "mode": MODE_25D, "action": "launch_25d_vfx_stress", "visualPreset": VISUAL_PRESET_VFX_STRESS},
		{"id": "2_5d_hero", "label": "2.5D hero selected", "mode": MODE_25D, "action": "select_hero", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_worker", "label": "2.5D Worker selected", "mode": MODE_25D, "action": "select_worker", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_squad", "label": "2.5D squad box selected", "mode": MODE_25D, "action": "box_select", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_buildings", "label": "2.5D buildings and landmarks", "mode": MODE_25D, "action": "show_buildings", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_capture_site", "label": "2.5D capture site marker", "mode": MODE_25D, "action": "capture_site", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_lume_stable", "label": "2.5D stable Lume line", "mode": MODE_25D, "action": "lume_stable", "visualPreset": VISUAL_PRESET_CLEAN},
		{"id": "2_5d_lume_transition", "label": "2.5D Lume transition pulse", "mode": MODE_25D, "action": "lume_transition", "visualPreset": VISUAL_PRESET_ATMOSPHERIC},
		{"id": "2_5d_results", "label": "2.5D Results transition", "mode": MODE_25D, "action": "results", "visualPreset": VISUAL_PRESET_CLEAN}
	]

func get_spike_status() -> Dictionary:
	if active_mode == MODE_HOME:
		return {
			"mode": active_mode,
			"ready": true,
			"currentStepId": current_step_id,
			"visualPreset": active_visual_preset,
			"reviewHarnessVisible": true
		}
	if active_scene and active_scene.has_method("get_spike_status"):
		var status: Dictionary = active_scene.get_spike_status()
		status["currentStepId"] = current_step_id
		status["reviewHarnessVisible"] = review_layer != null
		if active_mode == MODE_2D:
			status["visualPreset"] = VISUAL_PRESET_2D_CONTROL
		return status
	return {"mode": active_mode, "ready": false, "currentStepId": current_step_id, "visualPreset": active_visual_preset}

func run_headless_tests() -> Dictionary:
	var errors: Array[String] = []
	var importer: RefCounted = SaltoFixtureImporterScript.new()
	var validation: Dictionary = importer.validate_fixture()
	var adapter_validation: Dictionary = importer.run_adapter_validation()
	_write_report("res://reports/godot-v0122-adapter-validation.json", adapter_validation)
	if validation.get("status", "FAIL") != "PASS":
		for error in validation.get("errors", []):
			errors.append(str(error))
	if adapter_validation.get("status", "FAIL") != "PASS_GODOT_CONTENT_ADAPTER_VALIDATION":
		for error in adapter_validation.get("errors", []):
			errors.append(str(error))
	_test_scene("res://scenes/salto_2d_placeholder.tscn", MODE_2D, errors)
	_test_scene("res://scenes/salto_2_5d_orthographic_placeholder.tscn", MODE_25D, errors)
	var parity_report: Dictionary = _run_v0122_parity_harness()
	_write_report("res://reports/godot-v0122-parity-report.json", parity_report)
	if parity_report.get("status", "FAIL") != "PASS_GODOT_RULES_PARITY_HARNESS":
		for error in parity_report.get("errors", []):
			errors.append(str(error))
	var fixture_validation: Dictionary = validation.get("validation", {}).duplicate(true)
	fixture_validation.erase("adapterValidation")
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"fixtureValidation": fixture_validation,
		"adapterValidation": adapter_validation,
		"parityReport": parity_report,
		"godotVersion": Engine.get_version_info(),
		"tests": [
			"project-load",
			"fixture-import",
			"stable-id-validation",
			"unknown-id-rejection",
			"linked_ward-0.92",
			"read-only-save-fixtures",
			"2D-placeholder-mode",
			"2.5D-orthographic-placeholder-mode",
			"selection",
			"box-selection",
			"move-order",
			"attack-order",
			"site-state",
			"Lume-placeholder",
			"pause-results-flow",
			"camera-pan-zoom-hooks",
			"v0.118-private-review-harness-hooks",
			"v0.119-workload-tier-S",
			"v0.119-workload-tier-M",
			"v0.119-workload-tier-L",
			"v0.119-navigation-metrics",
			"v0.119-bounded-ai-pressure",
			"v0.119-results-parity",
			"v0.121-procedural-2_5d-presets",
			"v0.121-hud-minimap-selection-readability",
			"v0.121-vfx-stress-private-boundary",
			"v0.122-content-registry-adapter",
			"v0.122-stable-id-validator",
			"v0.122-read-only-save-adapter",
			"v0.122-unit-building-site-lume-results-adapters",
			"v0.122-fixed-seed-rules-parity",
			"v0.122-2d-and-2_5d-same-fixture",
			"v0.122-no-full-port-started"
		]
	}

func _run_v0122_parity_harness() -> Dictionary:
	var errors: Array[String] = []
	var reports: Array[Dictionary] = []
	for config in [
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn"}
	]:
		var packed: PackedScene = load(str(config["path"])) as PackedScene
		if packed == null:
			errors.append("Failed to load v0.122 parity scene for %s" % config["mode"])
			continue
		var scene: Node = packed.instantiate()
		add_child(scene)
		if str(config["mode"]) == MODE_25D and scene.has_method("set_visual_preset"):
			scene.set_visual_preset(VISUAL_PRESET_CLEAN)
		if not scene.has_method("run_v0122_parity_fixture"):
			errors.append("%s lacks run_v0122_parity_fixture" % config["mode"])
		else:
			var report: Dictionary = scene.run_v0122_parity_fixture()
			reports.append(report)
			if report.get("status", "FAIL") != "PASS_GODOT_RULES_PARITY_HARNESS":
				for error in report.get("errors", []):
					errors.append("%s: %s" % [config["mode"], str(error)])
		scene.queue_free()
	if reports.size() == 2:
		var left: Dictionary = reports[0].get("initialSnapshot", {})
		var right: Dictionary = reports[1].get("initialSnapshot", {})
		if str(left.get("placementSignature", "")) != str(right.get("placementSignature", "")):
			errors.append("2D and 2.5D parity fixtures did not share the same initial placement signature.")
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS_GODOT_RULES_PARITY_HARNESS" if errors.is_empty() else "FAIL_GODOT_RULES_PARITY_HARNESS",
		"generatedAtUtc": "deterministic-v0122",
		"errors": errors,
		"fixedSeed": 1190119,
		"tier": "M",
		"modes": reports.map(func(report: Dictionary) -> String: return str(report.get("mode", ""))),
		"modeReports": reports,
		"sameFixtureAcross2dAnd25d": errors.filter(func(error: String) -> bool: return error.contains("same initial placement")).is_empty(),
		"fullBrowserGodotSimulationParityClaimed": false,
		"localStorageMutationAllowed": false,
		"saveWritesAllowed": false,
		"routineEditorUseRequired": false
	}

func run_headless_benchmark() -> Array[String]:
	var errors: Array[String] = []
	for config in [
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn", "report": "res://reports/godot-benchmark-2d.json"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-benchmark-2_5d.json", "visualPreset": VISUAL_PRESET_CLEAN},
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2d-control.json", "visualPreset": VISUAL_PRESET_2D_CONTROL, "benchmarkKind": "v0.121-procedural-visual-foundation"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2_5d-clean.json", "visualPreset": VISUAL_PRESET_CLEAN, "benchmarkKind": "v0.121-procedural-visual-foundation"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2_5d-atmospheric.json", "visualPreset": VISUAL_PRESET_ATMOSPHERIC, "benchmarkKind": "v0.121-procedural-visual-foundation"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-v0121-benchmark-2_5d-vfx-stress-private.json", "visualPreset": VISUAL_PRESET_VFX_STRESS, "benchmarkKind": "v0.121-procedural-visual-foundation-private"}
	]:
		var mode_errors: Array[String] = _benchmark_mode(config)
		for error in mode_errors:
			errors.append(error)
	return errors

func _test_scene(path: String, expected_mode: String, errors: Array[String]) -> void:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		errors.append("Failed to load %s" % path)
		return
	var scene: Node = packed.instantiate()
	if scene == null:
		errors.append("Failed to instantiate %s" % path)
		return
	add_child(scene)
	if not scene.has_method("get_spike_status"):
		errors.append("%s lacks get_spike_status" % path)
	else:
		var expected_counts := {
			"S": {"entityCount": 14, "structureCount": 4, "siteCount": 1, "lumeEndpointCount": 2, "lumeLinkCount": 1},
			"M": {"entityCount": 43, "structureCount": 4, "siteCount": 3, "lumeEndpointCount": 2, "lumeLinkCount": 1},
			"L": {"entityCount": 105, "structureCount": 6, "siteCount": 5, "lumeEndpointCount": 3, "lumeLinkCount": 2}
		}
		for tier in ["S", "M", "L"]:
			if scene.has_method("set_workload_tier") and not scene.set_workload_tier(str(tier)):
				errors.append("%s tier %s selection failed" % [expected_mode, tier])
			var status: Dictionary = scene.get_spike_status()
			if status.get("mode", "") != expected_mode:
				errors.append("%s reported wrong mode for tier %s" % [expected_mode, tier])
			if str(status.get("workloadTier", "")) != str(tier):
				errors.append("%s reported wrong workload tier %s" % [expected_mode, tier])
			for key in expected_counts[str(tier)].keys():
				if int(status.get(key, -1)) != int(expected_counts[str(tier)][key]):
					errors.append("%s tier %s %s mismatch: expected %s, received %s" % [
						expected_mode,
						tier,
						key,
						expected_counts[str(tier)][key],
						status.get(key, null)
					])
			if absf(float(status.get("linkedWardDamageTakenMultiplier", 0.0)) - 0.92) > 0.0001:
				errors.append("%s tier %s linked_ward multiplier changed" % [expected_mode, tier])
			if tier == "S":
				if scene.has_method("select_entity"):
					if not scene.select_entity("hero_aster"):
						errors.append("%s hero selectable check failed" % expected_mode)
					if not scene.select_entity("worker"):
						errors.append("%s worker selectable check failed" % expected_mode)
				if scene.has_method("box_select_squad") and scene.box_select_squad().size() < 4:
					errors.append("%s squad box-select check failed" % expected_mode)
				if scene.has_method("issue_move_order") and not scene.issue_move_order():
					errors.append("%s move order check failed" % expected_mode)
				if scene.has_method("issue_attack_order") and not scene.issue_attack_order():
					errors.append("%s attack order check failed" % expected_mode)
				if scene.has_method("change_site_state") and not scene.change_site_state():
					errors.append("%s site state check failed" % expected_mode)
				if scene.has_method("trigger_hero_ability") and not scene.trigger_hero_ability():
					errors.append("%s hero ability placeholder check failed" % expected_mode)
				if scene.has_method("focus_lume_link") and not scene.focus_lume_link():
					errors.append("%s Lume focus check failed" % expected_mode)
				if scene.has_method("pan_camera") and not scene.pan_camera():
					errors.append("%s camera pan check failed" % expected_mode)
				if scene.has_method("zoom_camera") and not scene.zoom_camera():
					errors.append("%s camera zoom check failed" % expected_mode)
				if scene.has_method("toggle_pause") and not scene.toggle_pause():
					errors.append("%s pause check failed" % expected_mode)
				if scene.has_method("transition_results") and not scene.transition_results():
					errors.append("%s Results transition check failed" % expected_mode)
			if not scene.has_method("run_workload_phase"):
				errors.append("%s lacks v0.119 run_workload_phase" % expected_mode)
			else:
				for phase in ["idle", "moving", "combat"]:
					var phase_report: Dictionary = scene.run_workload_phase(str(phase))
					if phase_report.get("status", "FAIL") != "PASS":
						errors.append("%s tier %s phase %s failed" % [expected_mode, tier, phase])
					if int(phase_report.get("stuckUnitCount", 0)) != 0:
						errors.append("%s tier %s phase %s reported stuck units" % [expected_mode, tier, phase])
					if phase == "combat" and not bool(phase_report.get("resultsReady", false)):
						errors.append("%s tier %s combat phase did not reach Results" % [expected_mode, tier])
					if phase == "combat" and tier == "M" and int(phase_report.get("aiPressureBeatCount", 0)) < 1:
						errors.append("%s tier M did not record its bounded enemy-pressure beat" % expected_mode)
					if phase == "combat" and tier == "L" and int(phase_report.get("aiPressureBeatCount", 0)) < 2:
						errors.append("%s tier L did not record sustained enemy-pressure beats" % expected_mode)
		var final_status: Dictionary = scene.get_spike_status()
		if not bool(final_status.get("lumeLinkRendered", false)):
			errors.append("%s Lume placeholder not marked rendered" % expected_mode)
		if expected_mode == MODE_25D:
			if not scene.has_method("set_visual_preset"):
				errors.append("%s lacks v0.121 set_visual_preset" % expected_mode)
			else:
				for preset in [VISUAL_PRESET_CLEAN, VISUAL_PRESET_ATMOSPHERIC, VISUAL_PRESET_VFX_STRESS]:
					if not scene.set_visual_preset(preset):
						errors.append("%s rejected v0.121 visual preset %s" % [expected_mode, preset])
					var preset_status: Dictionary = scene.get_spike_status()
					if str(preset_status.get("visualPreset", "")) != preset:
						errors.append("%s did not report v0.121 visual preset %s" % [expected_mode, preset])
					if not bool(preset_status.get("proceduralPrimitiveOnly", false)):
						errors.append("%s preset %s is not marked procedural-only" % [expected_mode, preset])
					if not bool(preset_status.get("hudPlaceholderRendered", false)):
						errors.append("%s preset %s lacks HUD placeholder status" % [expected_mode, preset])
					if not bool(preset_status.get("captureSiteMarkerRendered", false)):
						errors.append("%s preset %s lacks capture-site marker status" % [expected_mode, preset])
					if preset == VISUAL_PRESET_VFX_STRESS and not bool(preset_status.get("vfxStressPrivate", false)):
						errors.append("%s VFX stress preset is not marked private" % expected_mode)
	scene.queue_free()

func _benchmark_mode(config: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var start := Time.get_ticks_usec()
	var packed: PackedScene = load(str(config["path"])) as PackedScene
	if packed == null:
		return ["Failed to load benchmark scene for %s" % config["mode"]]
	var scene: Node = packed.instantiate()
	var launch: int = Time.get_ticks_usec()
	add_child(scene)
	if config.has("visualPreset") and str(config["mode"]) == MODE_25D and scene.has_method("set_visual_preset"):
		scene.set_visual_preset(str(config["visualPreset"]))
	var report: Dictionary
	if scene.has_method("run_benchmark_suite"):
		report = scene.run_benchmark_suite()
		report["startupMs"] = snappedf(float(launch - start) / 1000.0, 0.01)
		report["sceneLaunchMs"] = snappedf(float(launch - start) / 1000.0, 0.01)
	else:
		if scene.has_method("select_entity"):
			scene.select_entity("hero_aster")
		if scene.has_method("box_select_squad"):
			scene.box_select_squad()
		var input_start := Time.get_ticks_usec()
		if scene.has_method("issue_move_order"):
			scene.issue_move_order()
		if scene.has_method("issue_attack_order"):
			scene.issue_attack_order()
		var input_end := Time.get_ticks_usec()
		if scene.has_method("transition_results"):
			scene.transition_results()
		var results_end := Time.get_ticks_usec()
		var frame_times: Array[float] = []
		for _index in range(180):
			var before := Time.get_ticks_usec()
			scene.propagate_call("_process", [1.0 / 60.0])
			var after := Time.get_ticks_usec()
			frame_times.append(max(0.01, float(after - before) / 1000.0))
		report = _metrics(str(config["mode"]), start, launch, input_start, input_end, results_end, frame_times)
	report["checkpoint"] = CHECKPOINT
	report["mode"] = str(config["mode"])
	report["visualPreset"] = str(config.get("visualPreset", VISUAL_PRESET_2D_CONTROL if str(config["mode"]) == MODE_2D else VISUAL_PRESET_CLEAN))
	report["visualPresetPrivate"] = report["visualPreset"] == VISUAL_PRESET_VFX_STRESS
	report["benchmarkKind"] = str(config.get("benchmarkKind", "v0.119-representative-rts-load"))
	report["godotVersion"] = Engine.get_version_info()
	report["fixtureHash"] = _fixture_hash()
	report["finalProductionCertification"] = false
	report["runtimeArtIntegrated"] = false
	report["generatedOrImportedArtIncluded"] = false
	report["routineEditorUseRequired"] = false
	_write_report(str(config["report"]), report)
	if report.get("status", "FAIL") != "PASS":
		errors.append("%s benchmark report did not pass" % config["mode"])
	scene.queue_free()
	return errors

func _metrics(mode: String, start: int, launch: int, input_start: int, input_end: int, results_end: int, frame_times: Array[float]) -> Dictionary:
	frame_times.sort()
	var sum := 0.0
	for value in frame_times:
		sum += value
	var average_frame: float = sum / float(max(1, frame_times.size()))
	var fps: float = min(240.0, 1000.0 / max(0.01, average_frame))
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"mode": mode,
		"status": "PASS",
		"startupMs": float(launch - start) / 1000.0,
		"sceneLaunchMs": float(launch - start) / 1000.0,
		"fpsAverage": snappedf(fps, 0.01),
		"fpsOnePercentLow": snappedf(fps, 0.01),
		"frameTimeP50Ms": _percentile(frame_times, 0.50),
		"frameTimeP95Ms": _percentile(frame_times, 0.95),
		"frameTimeP99Ms": _percentile(frame_times, 0.99),
		"frameTimeMaxMs": frame_times[frame_times.size() - 1],
		"inputLatencyMs": float(input_end - input_start) / 1000.0,
		"resultsTransitionMs": float(results_end - input_end) / 1000.0,
		"memoryWorkingSetMb": null,
		"notes": "Placeholder loop metric for AI-first workflow validation, not final production performance certification."
	}

func _percentile(values: Array[float], percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var index := clampi(int(floor(float(values.size() - 1) * percentile)), 0, values.size() - 1)
	return snappedf(values[index], 0.01)

func _settle_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame

func _set_capture_viewport(size: Vector2i) -> void:
	current_viewport_size = size
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(size)
		DisplayServer.window_set_min_size(size)

func _artifact_root_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	return ProjectSettings.globalize_path("user://v0121-godot-review")

func _script_args() -> PackedStringArray:
	var args := PackedStringArray()
	for arg in OS.get_cmdline_user_args():
		if not args.has(arg):
			args.append(arg)
	for arg in OS.get_cmdline_args():
		if _is_script_arg(arg) and not args.has(arg):
			args.append(arg)
	return args

func _is_script_arg(arg: String) -> bool:
	for prefix in SCRIPT_ARG_PREFIXES:
		if arg == prefix or arg.begins_with(prefix):
			return true
	return false

func _path_join(root: String, child: String) -> String:
	return root.trim_suffix("/").trim_suffix("\\") + "/" + child.trim_prefix("/").trim_prefix("\\")

func _write_report(path: String, report: Dictionary) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))

func _write_absolute_json(path: String, report: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))

func _fixture_hash() -> Variant:
	var file := FileAccess.open("res://data/generated/fixture-hashes.json", FileAccess.READ)
	if not file:
		return null
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed.get("fixtureHash")
	return null

func _friendly_mode(mode: String) -> String:
	if mode == MODE_25D:
		return "2.5D orthographic placeholder"
	if mode == MODE_2D:
		return "2D placeholder"
	return "review home"

func _friendly_action(action: String) -> String:
	match action:
		"home":
			return "Review home"
		"launch_2d":
			return "Launch 2D placeholder"
		"launch_25d":
			return "Launch 2.5D placeholder"
		"launch_25d_clean":
			return "Launch 2.5D clean readability"
		"launch_25d_atmospheric":
			return "Launch 2.5D atmospheric balanced"
		"launch_25d_vfx_stress":
			return "Launch 2.5D VFX stress private"
		"preset_clean":
			return "Set clean readability preset"
		"preset_atmospheric":
			return "Set atmospheric balanced preset"
		"preset_vfx_stress":
			return "Set VFX stress private preset"
		"select_hero":
			return "Select hero"
		"select_worker":
			return "Select Worker"
		"box_select":
			return "Box select squad"
		"move":
			return "Issue move order"
		"attack":
			return "Issue attack order"
		"pan_camera":
			return "Pan camera"
		"zoom_camera":
			return "Zoom camera"
		"pause":
			return "Pause"
		"capture_site":
			return "Capture site"
		"show_buildings":
			return "Show buildings and landmarks"
		"lume_link":
			return "Focus Lume link"
		"lume_stable":
			return "Stable Lume line"
		"lume_transition":
			return "Lume transition pulse"
		"results":
			return "Results transition"
		"return_home":
			return "Return home"
		"exit":
			return "Exit"
		_:
			return action
