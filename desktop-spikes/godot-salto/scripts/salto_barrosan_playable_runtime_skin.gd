extends "res://scripts/salto_spike_scene_3d.gd"

const V0240_MAPPING_PATH := "res://data/v0240_barrosan_playable_art_mapping.json"
const V0239_KIT_PATH := "res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb"
const EXPECTED_ROLES := [
	"main_base", "house", "farm", "lumber", "blacksmith",
	"barracks", "mine", "watchtower", "market",
]
const LIVE_FIXTURE_ROLES := {
	"command_hall": "main_base",
	"barracks": "barracks",
}
const PLACEHOLDER_POSITIONS := {
	"house": Vector3(2.65, 0.02, 2.55),
	"farm": Vector3(4.15, 0.02, 2.55),
	"lumber": Vector3(5.55, 0.02, 1.35),
	"blacksmith": Vector3(5.35, 0.02, -0.35),
	"watchtower": Vector3(4.70, 0.02, -2.10),
	"market": Vector3(3.10, 0.02, -2.65),
}

var barrosan_runtime_skin_enabled := false
var barrosan_runtime_debug_labels := false
var barrosan_runtime_review_mode := "clean"
var barrosan_source_kit: Node3D
var barrosan_mapping: Dictionary = {}
var barrosan_role_entries: Dictionary = {}
var barrosan_live_instances: Dictionary = {}
var barrosan_placeholder_instances: Dictionary = {}
var barrosan_runtime_errors: Array[String] = []


func configure_barrosan_playable_runtime_skin(options: Dictionary) -> void:
	barrosan_runtime_skin_enabled = bool(options.get("enabled", false))
	barrosan_runtime_debug_labels = bool(options.get("debugLabels", false))
	if not barrosan_runtime_skin_enabled:
		return
	_load_barrosan_runtime_assets()
	_rebuild_visuals()


func _load_barrosan_runtime_assets() -> void:
	barrosan_runtime_errors.clear()
	barrosan_role_entries.clear()
	if not FileAccess.file_exists(V0240_MAPPING_PATH):
		barrosan_runtime_errors.append("Missing v0.240 playable-art mapping")
		return
	var mapping_file := FileAccess.open(V0240_MAPPING_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(mapping_file.get_as_text()) if mapping_file != null else null
	if not parsed is Dictionary:
		barrosan_runtime_errors.append("Invalid v0.240 playable-art mapping")
		return
	barrosan_mapping = parsed
	if str(barrosan_mapping.get("sourceGlb", "")) != V0239_KIT_PATH:
		barrosan_runtime_errors.append("Mapping does not reference the retained v0.239 GLB")
	for entry in barrosan_mapping.get("roles", []):
		if entry is Dictionary:
			barrosan_role_entries[str(entry.get("gameplayRole", ""))] = entry
	for role in EXPECTED_ROLES:
		if not barrosan_role_entries.has(role):
			barrosan_runtime_errors.append("Missing mapped role %s" % role)
	if barrosan_source_kit != null and is_instance_valid(barrosan_source_kit):
		barrosan_source_kit.queue_free()
	var packed := load(V0239_KIT_PATH) as PackedScene
	if packed == null:
		barrosan_runtime_errors.append("Unable to load retained v0.239 GLB")
		return
	barrosan_source_kit = packed.instantiate() as Node3D
	if barrosan_source_kit == null:
		barrosan_runtime_errors.append("Unable to instantiate retained v0.239 GLB")
		return
	barrosan_source_kit.name = "V0241RetainedBarrosanRuntimeLibrary"
	barrosan_source_kit.visible = false
	add_child(barrosan_source_kit)


func _rebuild_visuals() -> void:
	barrosan_live_instances.clear()
	barrosan_placeholder_instances.clear()
	super._rebuild_visuals()
	if not barrosan_runtime_skin_enabled or not barrosan_runtime_errors.is_empty():
		return
	_add_missing_role_placeholders()
	_sync_barrosan_runtime_review_visuals()


func _add_structure(structure: Dictionary) -> void:
	var fixture := str(structure.get("fixtureId", ""))
	var team := str(structure.get("team", ""))
	if barrosan_runtime_skin_enabled and team == "friendly" and LIVE_FIXTURE_ROLES.has(fixture):
		var role := str(LIVE_FIXTURE_ROLES[fixture])
		var entry: Dictionary = barrosan_role_entries.get(role, {})
		var placed := _place_barrosan_module(
			role,
			str(entry.get("module", "")),
			_to_world(structure.get("position", Vector2.ZERO), 0.02),
			float(entry.get("yawDegrees", 0.0)),
			_runtime_module_scale(role)
		)
		if placed != null:
			barrosan_live_instances[role] = placed
			_add_runtime_footprint(role, placed.position, _runtime_footprint(entry), false)
			return
	super._add_structure(structure)


func _add_capture_site(site: Dictionary) -> void:
	super._add_capture_site(site)
	var site_id := str(site.get("id", ""))
	if not barrosan_runtime_skin_enabled or (site_id != "west_stone_cut" and not site_id.ends_with("west_stone_cut")):
		return
	var entry: Dictionary = barrosan_role_entries.get("mine", {})
	var placed := _place_barrosan_module(
		"mine",
		str(entry.get("module", "")),
		_to_world(site.get("position", Vector2.ZERO), 0.02),
		float(entry.get("yawDegrees", 0.0)),
		_runtime_module_scale("mine")
	)
	if placed != null:
		barrosan_live_instances["mine"] = placed
		_add_runtime_footprint("mine", placed.position, _runtime_footprint(entry), false)


func _place_barrosan_module(role: String, module_name: String, position: Vector3, yaw_degrees: float, scale_value: float) -> Node3D:
	if barrosan_source_kit == null or not is_instance_valid(barrosan_source_kit):
		return null
	var source := barrosan_source_kit.find_child(module_name, true, false) as Node3D
	if source == null:
		barrosan_runtime_errors.append("Missing retained module %s for %s" % [module_name, role])
		return null
	var placed := source.duplicate(Node.DUPLICATE_USE_INSTANTIATION) as Node3D
	if placed == null:
		barrosan_runtime_errors.append("Unable to duplicate retained module %s" % module_name)
		return null
	placed.name = "v0241_%s_%s" % [role, module_name]
	placed.visible = true
	placed.position = position
	placed.rotation_degrees.y = yaw_degrees
	placed.scale = Vector3.ONE * scale_value
	visual_root.add_child(placed)
	return placed


func _add_missing_role_placeholders() -> void:
	for role in ["house", "farm", "lumber", "blacksmith", "watchtower", "market"]:
		var entry: Dictionary = barrosan_role_entries.get(role, {})
		var placed := _place_barrosan_module(
			role,
			str(entry.get("module", "")),
			PLACEHOLDER_POSITIONS[role],
			float(entry.get("yawDegrees", 0.0)),
			_runtime_module_scale(role)
		)
		if placed == null:
			continue
		barrosan_placeholder_instances[role] = placed
		_add_runtime_footprint(role, placed.position, _runtime_footprint(entry), true)
		_add_runtime_role_label(role, str(entry.get("displayName", role)), placed.position)


func _runtime_module_scale(role: String) -> float:
	var entry: Dictionary = barrosan_role_entries.get(role, {})
	var mapped_scale := float(entry.get("scale", 0.76))
	return mapped_scale * (0.055 if role in ["main_base", "barracks", "mine"] else 0.045)


func _runtime_footprint(entry: Dictionary) -> Vector2:
	var footprint: Array = entry.get("footprint", [])
	if footprint.size() != 2:
		return Vector2(0.8, 0.7)
	return Vector2(float(footprint[0]), float(footprint[1])) * 0.11


func _add_runtime_footprint(role: String, position: Vector3, footprint: Vector2, placeholder: bool) -> void:
	var marker_name := "v0241_footprint_%s" % role
	_add_box(
		marker_name,
		position + Vector3(0.0, -0.015, 0.0),
		Vector3(footprint.x, 0.022, footprint.y),
		Color(0.20, 0.72, 0.48, 0.10 if placeholder else 0.07),
		true
	)


func _add_runtime_role_label(role: String, display_name: String, position: Vector3) -> void:
	var label := Label3D.new()
	label.name = "v0241_role_label_%s" % role
	label.text = "%s\nREVIEW PLACEHOLDER" % display_name
	label.position = position + Vector3(0.0, 0.56, 0.0)
	label.font_size = 18
	label.pixel_size = 0.006
	label.outline_size = 5
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.visible = barrosan_runtime_debug_labels or barrosan_runtime_review_mode == "mapping"
	visual_root.add_child(label)


func set_barrosan_runtime_review_mode(mode: String) -> void:
	barrosan_runtime_review_mode = mode
	if mode == "selected":
		v0133_barracks_selected = true
	_sync_barrosan_runtime_review_visuals()


func _sync_unit_visuals() -> void:
	super._sync_unit_visuals()
	_sync_barrosan_runtime_review_visuals()


func _sync_barrosan_runtime_review_visuals() -> void:
	if visual_root == null or not barrosan_runtime_skin_enabled:
		return
	for role in ["house", "farm", "lumber", "blacksmith", "watchtower", "market"]:
		var label := visual_root.get_node_or_null("v0241_role_label_%s" % role) as Label3D
		if label != null:
			label.visible = barrosan_runtime_debug_labels or barrosan_runtime_review_mode == "mapping"
	var barracks_position := _structure_world_position("barracks", Vector3(-4.8, 0.12, -3.58))
	_set_or_create_disc_marker("v0241_selected_building_indicator", barracks_position, 0.78, Color(0.96, 0.78, 0.24, 0.78))
	var selected_marker := visual_root.get_node_or_null("v0241_selected_building_indicator")
	if selected_marker != null:
		selected_marker.visible = v0133_barracks_selected or barrosan_runtime_review_mode == "selected"
	_set_or_create_marker("v0241_valid_placement_preview", Vector3(1.55, 0.11, 2.15), Vector3(0.82, 0.045, 0.68), Color(0.20, 0.82, 0.46, 0.46))
	_set_or_create_marker("v0241_blocked_placement_preview", Vector3(0.65, 0.11, 0.20), Vector3(0.82, 0.045, 0.68), Color(0.90, 0.22, 0.16, 0.48))
	var valid_preview := visual_root.get_node_or_null("v0241_valid_placement_preview")
	var blocked_preview := visual_root.get_node_or_null("v0241_blocked_placement_preview")
	if valid_preview != null:
		valid_preview.visible = barrosan_runtime_review_mode == "valid_preview"
	if blocked_preview != null:
		blocked_preview.visible = barrosan_runtime_review_mode == "blocked_preview"


func get_spike_status() -> Dictionary:
	var status := super.get_spike_status()
	status["barrosanPlayableRuntimeSkin"] = {
		"enabled": barrosan_runtime_skin_enabled,
		"scenePath": "res://scenes/salto_barrosan_playable_runtime_skin.tscn",
		"mappingPath": V0240_MAPPING_PATH,
		"sourceGlb": V0239_KIT_PATH,
		"defaultRuntimeChanged": false,
		"gameplaySystemsChanged": false,
		"liveMappedRoles": barrosan_live_instances.keys(),
		"reviewPlaceholderRoles": barrosan_placeholder_instances.keys(),
		"debugLabelsVisible": barrosan_runtime_debug_labels or barrosan_runtime_review_mode == "mapping",
		"reviewMode": barrosan_runtime_review_mode,
		"errors": barrosan_runtime_errors.duplicate(),
	}
	return status
