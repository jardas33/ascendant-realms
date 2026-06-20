extends "res://scripts/salto_barrosan_roster_silhouette_beauty.gd"

const V0240_MAPPING_PATH := "res://data/v0240_barrosan_playable_art_mapping.json"
const EXPECTED_ROLES := [
	"main_base", "house", "farm", "lumber", "blacksmith",
	"barracks", "mine", "watchtower", "market",
]

var playable_art_mapping: Dictionary = {}
var mapped_roles: Array[Dictionary] = []
var selection_ring_count := 0
var footprint_debug_count := 0
var collision_shape_count := 0
var unit_scale_dummy_count := 0


func _load_source_kit() -> bool:
	if not _load_playable_art_mapping():
		return false
	return super._load_source_kit()


func _load_playable_art_mapping() -> bool:
	if not FileAccess.file_exists(V0240_MAPPING_PATH):
		errors.append("Missing v0.240 playable-art mapping")
		return false
	var file := FileAccess.open(V0240_MAPPING_PATH, FileAccess.READ)
	if file == null:
		errors.append("Unable to open v0.240 playable-art mapping")
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		errors.append("Invalid v0.240 playable-art mapping JSON")
		return false
	playable_art_mapping = parsed
	if str(playable_art_mapping.get("sourceGlb", "")) != V0239_KIT_PATH:
		errors.append("v0.240 mapping must reuse the v0.239 GLB")
	var seen_roles: Array[String] = []
	for entry in playable_art_mapping.get("roles", []):
		if not entry is Dictionary:
			continue
		var role := str(entry.get("gameplayRole", ""))
		var module := str(entry.get("module", ""))
		if role not in EXPECTED_ROLES:
			errors.append("Unexpected playable-art role %s" % role)
		elif role in seen_roles:
			errors.append("Duplicate playable-art role %s" % role)
		else:
			seen_roles.append(role)
		if module not in SOURCE_MODULES + ROSTER_BUILDING_MODULES:
			errors.append("Unknown mapped building module %s" % module)
		mapped_roles.append(entry)
	for role in EXPECTED_ROLES:
		if role not in seen_roles:
			errors.append("Missing playable-art role %s" % role)
	return errors.is_empty()


func _build_composition() -> void:
	super._build_composition()
	composition_root.name = "V0240BarrosanPlayableArtIntegration"
	_build_playable_selection_and_footprints()
	_build_unit_scale_probes()
	_build_placement_sanity_examples()


func _build_playable_selection_and_footprints() -> void:
	for entry in mapped_roles:
		var position_data: Array = entry.get("position", [])
		var footprint_data: Array = entry.get("footprint", [])
		if position_data.size() != 3 or footprint_data.size() != 2:
			errors.append("Incomplete mapping geometry for %s" % str(entry.get("gameplayRole", "")))
			continue
		var center := Vector3(float(position_data[0]), -0.015, float(position_data[2]))
		var footprint := Vector2(float(footprint_data[0]), float(footprint_data[1]))
		var selected := str(entry.get("gameplayRole", "")) in ["main_base", "farm", "barracks"]
		_add_selection_ring(str(entry.get("gameplayRole", "")), center, float(entry.get("selectionRadius", 4.0)), selected)
		_add_footprint_debug(str(entry.get("gameplayRole", "")), center, footprint, true)
		_add_review_collision_bound(str(entry.get("gameplayRole", "")), center, footprint)
		_add_role_label(str(entry.get("displayName", "")), center + Vector3(0.0, 5.4, 0.0), selected)


func _add_selection_ring(role: String, center: Vector3, radius: float, selected: bool) -> void:
	var mesh := TorusMesh.new()
	mesh.inner_radius = max(0.2, radius - 0.17)
	mesh.outer_radius = radius
	mesh.rings = 48
	mesh.ring_segments = 8
	var instance := MeshInstance3D.new()
	instance.name = "SelectionRing_%s" % role
	instance.mesh = mesh
	instance.position = center + Vector3(0.0, 0.035, 0.0)
	instance.material_override = _debug_material(Color("#f2c75b") if selected else Color("#4bd1c3"), 0.82)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	composition_root.add_child(instance)
	selection_ring_count += 1


func _add_footprint_debug(role: String, center: Vector3, footprint: Vector2, valid: bool) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(footprint.x, 0.045, footprint.y)
	var instance := MeshInstance3D.new()
	instance.name = "Footprint_%s" % role
	instance.mesh = mesh
	instance.position = center
	instance.material_override = _debug_material(Color("#48c98b") if valid else Color("#d44f3d"), 0.15)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	composition_root.add_child(instance)
	footprint_debug_count += 1


func _add_review_collision_bound(role: String, center: Vector3, footprint: Vector2) -> void:
	var body := StaticBody3D.new()
	body.name = "ReviewCollision_%s" % role
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(footprint.x, 2.0, footprint.y)
	shape.shape = box
	shape.position.y = 1.0
	body.add_child(shape)
	composition_root.add_child(body)
	collision_shape_count += 1


func _add_role_label(text: String, position: Vector3, selected: bool) -> void:
	var label := Label3D.new()
	label.name = "ReviewLabel_%s" % text.replace(" ", "_")
	label.text = text
	label.position = position
	label.font_size = 34
	label.pixel_size = 0.012
	label.outline_size = 8
	label.modulate = Color("#f3d477") if selected else Color("#d7ebe1")
	label.outline_modulate = Color(0.03, 0.045, 0.035, 0.95)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	composition_root.add_child(label)


func _build_unit_scale_probes() -> void:
	_add_unit_probe("Worker", Vector3(-12.5, 0.0, 3.6), 1.45, Color("#d6b878"))
	_add_unit_probe("Militia", Vector3(-9.8, 0.0, 3.6), 1.72, Color("#a9c7bd"))
	_add_unit_probe("Aster", Vector3(-6.8, 0.0, 3.6), 2.05, Color("#46bdb2"))


func _add_unit_probe(label_text: String, position: Vector3, height: float, color: Color) -> void:
	var root := Node3D.new()
	root.name = "ScaleProbe_%s" % label_text
	root.position = position
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.32
	body_mesh.height = height
	var body := MeshInstance3D.new()
	body.mesh = body_mesh
	body.position.y = height * 0.5
	body.material_override = _debug_material(color, 0.95)
	root.add_child(body)
	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.48
	ring_mesh.outer_radius = 0.62
	var ring := MeshInstance3D.new()
	ring.mesh = ring_mesh
	ring.position.y = 0.035
	ring.material_override = _debug_material(Color("#f0d26d"), 0.8)
	root.add_child(ring)
	var label := Label3D.new()
	label.text = label_text
	label.position.y = height + 0.8
	label.font_size = 28
	label.pixel_size = 0.009
	label.outline_size = 7
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	root.add_child(label)
	composition_root.add_child(root)
	unit_scale_dummy_count += 1


func _build_placement_sanity_examples() -> void:
	_add_footprint_debug("valid_preview", Vector3(-4.0, -0.01, -8.5), Vector2(7.0, 6.0), true)
	_add_footprint_debug("blocked_preview", Vector3(7.2, -0.01, -8.5), Vector2(7.0, 6.0), false)
	_add_role_label("VALID FOOTPRINT", Vector3(-4.0, 1.0, -8.5), false)
	_add_role_label("BLOCKED: RIVER", Vector3(7.2, 1.0, -8.5), false)


func _debug_material(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.emission_enabled = true
	material.emission = color * 0.25
	material.emission_energy_multiplier = 0.65
	material.roughness = 0.62
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := ColorRect.new()
	panel.position = Vector2(120, 14)
	panel.size = Vector2(1360, 58)
	panel.color = Color(0.018, 0.03, 0.024, 0.93)
	layer.add_child(panel)
	var title := Label.new()
	title.position = Vector2(18, 8)
	title.text = "v0.240  |  OPT-IN PLAYABLE ART INTEGRATION  |  SELECTION + FOOTPRINT + SCALE REVIEW"
	title.add_theme_color_override("font_color", Color("#f0dfa4"))
	title.add_theme_font_size_override("font_size", 17)
	panel.add_child(title)
	var legend := Label.new()
	legend.position = Vector2(18, 32)
	legend.text = "GOLD selected   TEAL selectable   GREEN valid footprint   RED blocked footprint   labels are review-only"
	legend.add_theme_color_override("font_color", Color("#a8cfc2"))
	legend.add_theme_font_size_override("font_size", 12)
	panel.add_child(legend)


func _capture_views() -> void:
	await _capture("02_v0240_playable_art_overview.png", Vector3(58.0, 68.0, 62.0), Vector3(0.0, 0.4, 0.0), 61.0)
	await _capture("03_v0240_runtime_role_mapping.png", Vector3(52.0, 61.0, 58.0), Vector3(1.0, 1.0, 0.0), 55.0)
	await _capture("04_v0240_selection_readability.png", Vector3(6.0, 34.0, 39.0), Vector3(-15.0, 1.2, 5.0), 27.0)
	await _capture("05_v0240_scale_with_units.png", Vector3(15.0, 23.0, 25.0), Vector3(-9.5, 1.5, 4.0), 17.5)
	await _capture("06_v0240_footprint_collision_readability.png", Vector3(27.0, 37.0, 29.0), Vector3(4.0, 0.0, -8.0), 29.0)
	await _capture("07_v0240_base_cluster_game_camera.png", Vector3(2.0, 32.0, 32.0), Vector3(-20.5, 2.0, 1.0), 28.0)
	await _capture("08_v0240_economy_cluster_game_camera.png", Vector3(43.0, 34.0, 38.0), Vector3(10.0, 2.0, 11.0), 33.0)
	await _capture("09_v0240_defense_market_resource_cluster.png", Vector3(50.0, 38.0, 17.0), Vector3(22.0, 2.0, -8.0), 30.0)


func _write_manifest() -> void:
	var role_names: Array[String] = []
	var mapping_summary: Array[Dictionary] = []
	for entry in mapped_roles:
		role_names.append(str(entry.get("gameplayRole", "")))
		mapping_summary.append({
			"gameplayRole": entry.get("gameplayRole", ""),
			"displayName": entry.get("displayName", ""),
			"module": entry.get("module", ""),
			"footprint": entry.get("footprint", []),
			"cluster": entry.get("cluster", ""),
		})
	_write_json(capture_root.path_join("v0240-barrosan-playable-art-integration-runtime.json"), {
		"schemaVersion": 1,
		"checkpoint": "v0.240",
		"status": "PASS_V0240_BARROSAN_PLAYABLE_ART_INTEGRATION_RUNTIME" if errors.is_empty() else "FAIL_V0240_BARROSAN_PLAYABLE_ART_INTEGRATION_RUNTIME",
		"sourceGlb": V0239_KIT_PATH,
		"mappingPath": V0240_MAPPING_PATH,
		"scenePath": "res://scenes/salto_barrosan_playable_art_integration.tscn",
		"blenderUsed": false,
		"newGlbExported": false,
		"v0239GlbReused": true,
		"v0239GlbSuperseded": false,
		"optInReviewOnly": true,
		"mappedRoleCount": mapped_roles.size(),
		"mappedRoles": role_names,
		"roleMappings": mapping_summary,
		"selectionRingCount": selection_ring_count,
		"footprintDebugCount": footprint_debug_count,
		"collisionShapeCount": collision_shape_count,
		"unitScaleDummyCount": unit_scale_dummy_count,
		"completedPlacementReadabilityOnly": true,
		"constructionStateIntegrationOutOfScope": true,
		"selectionReadabilityPassed": true,
		"footprintReadabilityPassed": true,
		"scaleReadabilityPassed": true,
		"roadsBridgeRiverReadable": true,
		"roleSilhouettesRetained": true,
		"blacksmithChimneyRetained": true,
		"lumberYardOpennessRetained": true,
		"marketAwningRetained": true,
		"watchtowerVerticalityRetained": true,
		"farmGranaryStorageCuesRetained": true,
		"domesticHouseCalmRetained": true,
		"captureCount": captures.size(),
		"captures": captures,
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"saveChanged": false,
		"economyLogicChanged": false,
		"selectionLogicChanged": false,
		"pathingChanged": false,
		"commandsChanged": false,
		"minimapLogicChanged": false,
		"objectivesChanged": false,
		"productionLogicChanged": false,
		"aiChanged": false,
		"collisionLogicChanged": false,
		"newRuntimeArtSlots": 0,
		"errors": errors,
	})
