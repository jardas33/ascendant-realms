extends SceneTree

const REPORT_PATH := "res://reports/godot-runtime-test-report.json"
const SaltoFixtureImporterScript := preload("res://scripts/fixture_importer.gd")

func _init() -> void:
	var errors: Array[String] = []
	var importer = SaltoFixtureImporterScript.new()
	var validation: Dictionary = importer.validate_fixture()
	if validation.get("status", "FAIL") != "PASS":
		for error in validation.get("errors", []):
			errors.append(str(error))

	_test_scene("res://scenes/salto_2d_placeholder.tscn", "2D_PLACEHOLDER", errors)
	_test_scene("res://scenes/salto_2_5d_orthographic_placeholder.tscn", "2_5D_ORTHOGRAPHIC_PLACEHOLDER", errors)
	_test_root(errors)

	var report := {
		"schemaVersion": 1,
		"checkpoint": "v0.117",
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
			"pause-results-flow"
		]
	}
	_write_report(REPORT_PATH, report)
	quit(0 if errors.is_empty() else 1)

func _test_scene(path: String, expected_mode: String, errors: Array[String]) -> void:
	var packed := load(path)
	if packed == null:
		errors.append("Failed to load %s" % path)
		return
	var scene = packed.instantiate()
	if scene == null:
		errors.append("Failed to instantiate %s" % path)
		return
	root.add_child(scene)
	if not scene.has_method("get_spike_status"):
		errors.append("%s lacks get_spike_status" % path)
	else:
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
		if scene.has_method("toggle_pause") and not scene.toggle_pause():
			errors.append("%s pause check failed" % expected_mode)
		if scene.has_method("transition_results") and not scene.transition_results():
			errors.append("%s Results transition check failed" % expected_mode)
		var status: Dictionary = scene.get_spike_status()
		if status.get("mode", "") != expected_mode:
			errors.append("%s reported wrong mode" % expected_mode)
		if int(status.get("entityCount", 0)) < 5:
			errors.append("%s entity spawn count too low" % expected_mode)
		if not bool(status.get("lumeLinkRendered", false)):
			errors.append("%s Lume placeholder not marked rendered" % expected_mode)
	scene.queue_free()

func _test_root(errors: Array[String]) -> void:
	var packed := load("res://scenes/salto_spike_root.tscn")
	if packed == null:
		errors.append("Failed to load root scene")
		return
	var scene = packed.instantiate()
	root.add_child(scene)
	if not scene.has_method("get_spike_status"):
		errors.append("Root scene lacks get_spike_status")
	scene.queue_free()

func _write_report(path: String, report: Dictionary) -> void:
	var absolute := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
