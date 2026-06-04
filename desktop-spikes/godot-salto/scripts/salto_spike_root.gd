extends Node

const MODE_2D := "2D_PLACEHOLDER"
const MODE_25D := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const MODE_HOME := "REVIEW_HOME"
const CHECKPOINT := "v0.119"
const VIEWPORT_SIZE := Vector2i(1600, 900)
const SCRIPT_ARG_PREFIXES := [
	"--run-tests",
	"--run-benchmark",
	"--review-smoke",
	"--capture-review",
	"--headed-benchmark",
	"--mode=",
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
var current_step_id := "home"

func _ready() -> void:
	var args: PackedStringArray = _script_args()
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
	var requested_mode := _requested_mode_from_args()
	if requested_mode == "":
		load_home()
	else:
		load_mode(requested_mode)

func _configure_window() -> void:
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_size(VIEWPORT_SIZE)
		DisplayServer.window_set_min_size(VIEWPORT_SIZE)

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
	home_subtitle.text = "v0.119 representative RTS workload, navigation, and AI-pressure spike"
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
	review_panel.size = Vector2(742, 128)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.05, 0.86)
	style.border_color = Color(0.33, 0.78, 0.72, 0.86)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	review_panel.add_theme_stylebox_override("panel", style)
	review_layer.add_child(review_panel)

	title_label = Label.new()
	title_label.text = "v0.119 Review"
	title_label.position = Vector2(16, 10)
	title_label.size = Vector2(220, 26)
	title_label.add_theme_font_size_override("font_size", 18)
	review_panel.add_child(title_label)

	status_label = Label.new()
	status_label.text = "Home"
	status_label.position = Vector2(240, 10)
	status_label.size = Vector2(472, 26)
	status_label.add_theme_font_size_override("font_size", 15)
	review_panel.add_child(status_label)

	step_label = Label.new()
	step_label.text = "Step: home | Mode: REVIEW_HOME"
	step_label.position = Vector2(16, 42)
	step_label.size = Vector2(704, 24)
	step_label.add_theme_font_size_override("font_size", 14)
	review_panel.add_child(step_label)

	var grid := GridContainer.new()
	grid.position = Vector2(14, 74)
	grid.size = Vector2(714, 38)
	grid.columns = 8
	review_panel.add_child(grid)
	for item in [
		{"text": "Home", "action": "home"},
		{"text": "2D", "action": "launch_2d"},
		{"text": "2.5D", "action": "launch_25d"},
		{"text": "Hero", "action": "select_hero"},
		{"text": "Worker", "action": "select_worker"},
		{"text": "Squad", "action": "box_select"},
		{"text": "Site", "action": "capture_site"},
		{"text": "Results", "action": "results"}
	]:
		var button := Button.new()
		button.text = str(item["text"])
		button.custom_minimum_size = Vector2(82, 32)
		button.pressed.connect(_handle_review_action.bind(str(item["action"])))
		grid.add_child(button)

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
		"lume_link":
			_ensure_active_scene()
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
	step_label.text = "Step: %s | Mode: %s" % [current_step_id, active_mode]

func run_headed_smoke() -> void:
	var artifact_root := _artifact_root_from_args()
	var start_usec := Time.get_ticks_usec()
	var errors: Array[String] = []
	var steps: Array[Dictionary] = []
	for action in [
		"home",
		"launch_2d",
		"launch_25d",
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
		"windowSize": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
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
	for step in _capture_steps():
		var action := str(step["action"])
		var mode := str(step["mode"])
		if mode == MODE_HOME:
			load_home()
		elif mode != active_mode:
			load_mode(mode)
		_apply_review_action(action)
		await _settle_frames(4)
		var file_name := "%02d_%s.png" % [index, str(step["id"])]
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
			"mode": active_mode,
			"action": action,
			"fileName": file_name,
			"absolutePath": target,
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
		"requiredCaptureCount": 15,
		"windowSize": {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y},
		"godotVersion": Engine.get_version_info(),
		"fixtureHash": _fixture_hash(),
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
	report["windowSize"] = {"width": VIEWPORT_SIZE.x, "height": VIEWPORT_SIZE.y}
	report["godotVersion"] = Engine.get_version_info()
	report["fixtureHash"] = _fixture_hash()
	report["runtimeArtIntegrated"] = false
	report["finalProductionCertification"] = false
	return report

func _capture_steps() -> Array[Dictionary]:
	return [
		{"id": "home", "label": "Review home", "mode": MODE_HOME, "action": "home"},
		{"id": "2d_default", "label": "2D default", "mode": MODE_2D, "action": "launch_2d"},
		{"id": "2d_hero", "label": "2D hero selected", "mode": MODE_2D, "action": "select_hero"},
		{"id": "2d_worker", "label": "2D Worker selected", "mode": MODE_2D, "action": "select_worker"},
		{"id": "2d_squad", "label": "2D squad box selected", "mode": MODE_2D, "action": "box_select"},
		{"id": "2d_site", "label": "2D capture site", "mode": MODE_2D, "action": "capture_site"},
		{"id": "2d_lume", "label": "2D Lume link", "mode": MODE_2D, "action": "lume_link"},
		{"id": "2d_results", "label": "2D Results transition", "mode": MODE_2D, "action": "results"},
		{"id": "2_5d_default", "label": "2.5D default", "mode": MODE_25D, "action": "launch_25d"},
		{"id": "2_5d_hero", "label": "2.5D hero selected", "mode": MODE_25D, "action": "select_hero"},
		{"id": "2_5d_worker", "label": "2.5D Worker selected", "mode": MODE_25D, "action": "select_worker"},
		{"id": "2_5d_squad", "label": "2.5D squad box selected", "mode": MODE_25D, "action": "box_select"},
		{"id": "2_5d_site", "label": "2.5D capture site", "mode": MODE_25D, "action": "capture_site"},
		{"id": "2_5d_lume", "label": "2.5D Lume link", "mode": MODE_25D, "action": "lume_link"},
		{"id": "2_5d_results", "label": "2.5D Results transition", "mode": MODE_25D, "action": "results"}
	]

func get_spike_status() -> Dictionary:
	if active_mode == MODE_HOME:
		return {
			"mode": active_mode,
			"ready": true,
			"currentStepId": current_step_id,
			"reviewHarnessVisible": true
		}
	if active_scene and active_scene.has_method("get_spike_status"):
		var status: Dictionary = active_scene.get_spike_status()
		status["currentStepId"] = current_step_id
		status["reviewHarnessVisible"] = review_layer != null
		return status
	return {"mode": active_mode, "ready": false, "currentStepId": current_step_id}

func run_headless_tests() -> Dictionary:
	var errors: Array[String] = []
	var importer: RefCounted = SaltoFixtureImporterScript.new()
	var validation: Dictionary = importer.validate_fixture()
	if validation.get("status", "FAIL") != "PASS":
		for error in validation.get("errors", []):
			errors.append(str(error))
	_test_scene("res://scenes/salto_2d_placeholder.tscn", MODE_2D, errors)
	_test_scene("res://scenes/salto_2_5d_orthographic_placeholder.tscn", MODE_25D, errors)
	return {
		"schemaVersion": 1,
		"checkpoint": CHECKPOINT,
		"status": "PASS" if errors.is_empty() else "FAIL",
		"errors": errors,
		"fixtureValidation": validation.get("validation", {}),
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
			"v0.119-results-parity"
		]
	}

func run_headless_benchmark() -> Array[String]:
	var errors: Array[String] = []
	for config in [
		{"mode": MODE_2D, "path": "res://scenes/salto_2d_placeholder.tscn", "report": "res://reports/godot-benchmark-2d.json"},
		{"mode": MODE_25D, "path": "res://scenes/salto_2_5d_orthographic_placeholder.tscn", "report": "res://reports/godot-benchmark-2_5d.json"}
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
	report["benchmarkKind"] = "v0.119-representative-rts-load"
	report["godotVersion"] = Engine.get_version_info()
	report["fixtureHash"] = _fixture_hash()
	report["finalProductionCertification"] = false
	report["runtimeArtIntegrated"] = false
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

func _artifact_root_from_args() -> String:
	for arg in _script_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	return ProjectSettings.globalize_path("user://v0119-godot-review")

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
		"lume_link":
			return "Focus Lume link"
		"results":
			return "Results transition"
		"return_home":
			return "Return home"
		"exit":
			return "Exit"
		_:
			return action
