extends "res://scripts/salto_spike_scene_3d.gd"

const V0240_MAPPING_PATH := "res://data/v0240_barrosan_playable_art_mapping.json"
const V0239_KIT_PATH := "res://assets/v0239/salto_barrosan_roster_silhouette_beauty.glb"
const BuildPlacementValidationAdapterScript = preload("res://scripts/adapters/build_placement_validation_adapter.gd")
const EXPECTED_ROLES := [
	"main_base", "house", "farm", "lumber", "blacksmith",
	"barracks", "mine", "watchtower", "market",
]
const LIVE_FIXTURE_ROLES := {
	"command_hall": "main_base",
	"barracks": "barracks",
	"west_stone_cut": "mine",
}
const INERT_ROLE_POSITIONS := {
	"house": Vector3(-4.45, 0.20, 2.78),
	"farm": Vector3(-2.55, 0.20, 3.34),
	"lumber": Vector3(-0.35, 0.20, 3.20),
	"blacksmith": Vector3(2.08, 0.20, 2.64),
	"watchtower": Vector3(4.42, 0.20, -2.62),
	"market": Vector3(3.10, 0.20, 0.18),
}
const ROLE_SCALE_FACTORS := {
	"main_base": 0.102,
	"barracks": 0.094,
	"mine": 0.090,
	"house": 0.074,
	"farm": 0.078,
	"lumber": 0.080,
	"blacksmith": 0.082,
	"watchtower": 0.094,
	"market": 0.080,
}
const LIVE_ROLE_IDS := {
	"main_base": "command_hall",
	"barracks": "barracks",
	"mine": "mine_landmark",
}

var barrosan_runtime_skin_enabled := false
var barrosan_runtime_checkpoint := "v0.243"
var barrosan_runtime_debug_labels := false
var barrosan_runtime_review_mode := "clean"
var barrosan_source_kit: Node3D
var barrosan_mapping: Dictionary = {}
var barrosan_role_entries: Dictionary = {}
var barrosan_runtime_structures: Dictionary = {}
var barrosan_selected_role_id := ""
var barrosan_runtime_errors: Array[String] = []
var barrosan_build_validation_adapter = BuildPlacementValidationAdapterScript.new()
var barrosan_valid_placement: Dictionary = {}
var barrosan_blocked_placement: Dictionary = {}
var barrosan_pathing_probe: Dictionary = {}
var barrosan_playtest: Dictionary = {}


func configure_barrosan_playable_runtime_skin(options: Dictionary) -> void:
	barrosan_runtime_skin_enabled = bool(options.get("enabled", false))
	barrosan_runtime_checkpoint = str(options.get("checkpoint", "v0.243"))
	barrosan_runtime_debug_labels = bool(options.get("debugLabels", false))
	if not barrosan_runtime_skin_enabled:
		return
	_load_barrosan_runtime_assets()
	_upgrade_inert_roles_to_runtime_shells()
	barrosan_build_validation_adapter.load_authority()
	_evaluate_barrosan_build_previews()
	if barrosan_runtime_checkpoint == "v0.244":
		_reset_barrosan_playtest_status()
	_refresh_visual_foundation()
	_add_barrosan_minimap_role_markers()


func set_workload_tier(tier: String) -> bool:
	var result := super.set_workload_tier(tier)
	if result and barrosan_runtime_skin_enabled:
		_upgrade_inert_roles_to_runtime_shells()
		_evaluate_barrosan_build_previews()
		_refresh_visual_foundation()
		_add_barrosan_minimap_role_markers()
	return result


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
	barrosan_source_kit.name = "V0242RetainedBarrosanRuntimeLibrary"
	barrosan_source_kit.visible = false
	add_child(barrosan_source_kit)


func _create_terrain() -> void:
	if not barrosan_runtime_skin_enabled:
		super._create_terrain()
		return
	terrain_root = Node3D.new()
	terrain_root.name = "V0242BarrosanRuntimeCohesionFoundation"
	add_child(terrain_root)
	var ground := MeshInstance3D.new()
	ground.name = "V0242BarrosanGround"
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(26.0, 22.0)
	ground.mesh = ground_mesh
	ground.material_override = _material(Color("#59643d"))
	terrain_root.add_child(ground)
	_add_static_box("v0242_north_heath", Vector3(-1.0, 0.035, -4.85), Vector3(17.4, 0.07, 1.10), Color("#687047"))
	_add_static_box("v0242_south_heath", Vector3(-0.2, 0.030, 5.15), Vector3(18.0, 0.06, 1.00), Color("#4f5b39"))
	_add_static_box("v0242_keep_terrace", Vector3(-6.25, 0.075, -2.58), Vector3(3.25, 0.11, 2.35), Color("#6b6d4c"))
	_add_static_box("v0242_economy_terrace", Vector3(-1.10, 0.060, 3.15), Vector3(8.70, 0.09, 2.15), Color("#666b45"))
	_add_static_box("v0242_east_terrace", Vector3(3.40, 0.060, 0.15), Vector3(4.60, 0.09, 6.20), Color("#56613e"))
	_add_static_box("v0242_river", Vector3(0.70, 0.072, 0.0), Vector3(0.88, 0.105, 14.6), Color("#295868"))
	_add_static_box("v0242_west_bank", Vector3(0.08, 0.105, 0.0), Vector3(0.34, 0.10, 14.6), Color("#49543b"))
	_add_static_box("v0242_east_bank", Vector3(1.32, 0.105, 0.0), Vector3(0.34, 0.10, 14.6), Color("#49543b"))
	_add_static_box("v0242_bridge_deck", Vector3(0.70, 0.205, 0.82), Vector3(2.05, 0.16, 0.62), Color("#7a6745"))
	_add_static_box("v0242_bridge_west_landing", Vector3(-0.62, 0.155, 0.82), Vector3(0.75, 0.10, 0.86), Color("#6e694f"))
	_add_static_box("v0242_bridge_east_landing", Vector3(2.02, 0.155, 0.82), Vector3(0.75, 0.10, 0.86), Color("#6e694f"))
	_add_barrosan_road("v0242_main_road_west", Vector3(-3.45, 0.155, 0.82), Vector3(5.35, 0.08, 0.58), 0.0)
	_add_barrosan_road("v0242_main_road_east", Vector3(4.30, 0.155, 0.82), Vector3(4.70, 0.08, 0.58), 0.0)
	_add_barrosan_road("v0242_keep_lane", Vector3(-5.75, 0.155, -0.90), Vector3(0.58, 0.08, 3.25), 0.0)
	_add_barrosan_road("v0242_barracks_lane", Vector3(-4.90, 0.155, -1.10), Vector3(0.52, 0.08, 3.65), -11.0)
	_add_barrosan_road("v0242_economy_lane", Vector3(-1.30, 0.155, 2.52), Vector3(7.15, 0.08, 0.50), 0.0)
	_add_barrosan_road("v0242_market_lane", Vector3(3.15, 0.155, 0.48), Vector3(0.52, 0.08, 3.35), 0.0)
	_add_barrosan_road("v0242_watch_lane", Vector3(4.05, 0.155, -1.25), Vector3(0.48, 0.08, 3.10), -9.0)
	_add_barrosan_road("v0242_mine_lane", Vector3(-0.58, 0.155, 0.10), Vector3(2.45, 0.08, 0.48), 3.0)
	for patch in [
		["v0242_keep_yard", Vector3(-6.05, 0.162, -2.48), Vector3(2.20, 0.025, 1.45), Color(0.38, 0.32, 0.21, 0.72)],
		["v0242_barracks_yard", Vector3(-4.92, 0.162, -3.00), Vector3(1.85, 0.025, 1.32), Color(0.40, 0.31, 0.19, 0.70)],
		["v0242_farm_wear", Vector3(-2.55, 0.162, 3.28), Vector3(1.42, 0.025, 1.10), Color(0.48, 0.39, 0.20, 0.62)],
		["v0242_lumber_wear", Vector3(-0.32, 0.162, 3.15), Vector3(1.65, 0.025, 1.15), Color(0.34, 0.27, 0.16, 0.65)],
		["v0242_forge_soot", Vector3(2.08, 0.162, 2.60), Vector3(1.35, 0.025, 1.10), Color(0.19, 0.18, 0.15, 0.62)],
	]:
		_add_static_box(patch[0], patch[1], patch[2], patch[3], true)
	for glint_z in [-3.8, -1.1, 2.2, 4.2]:
		_add_static_box("v0242_water_glint_%s" % str(glint_z).replace(".", "_"), Vector3(0.72, 0.132, glint_z), Vector3(0.35, 0.012, 0.72), Color(0.34, 0.67, 0.72, 0.30), true)


func _add_barrosan_road(name: String, position: Vector3, scale: Vector3, yaw: float) -> void:
	_add_static_box_rotated(name, position, scale, yaw, Color("#8b774d"))
	_add_static_box_rotated("%s_wear" % name, position + Vector3(0.0, 0.046, 0.0), Vector3(scale.x * 0.78, 0.018, scale.z * 0.54), yaw, Color(0.55, 0.44, 0.26, 0.42), true)


func _rebuild_visuals() -> void:
	barrosan_runtime_structures.clear()
	super._rebuild_visuals()
	if not barrosan_runtime_skin_enabled or not barrosan_runtime_errors.is_empty():
		return
	_sync_barrosan_runtime_visuals()


func _add_structure(structure: Dictionary) -> void:
	var fixture := str(structure.get("fixtureId", ""))
	var team := str(structure.get("team", ""))
	if barrosan_runtime_skin_enabled and fixture.begins_with("barrosan_shell_"):
		var shell_role := fixture.trim_prefix("barrosan_shell_")
		var shell_entry: Dictionary = barrosan_role_entries.get(shell_role, {})
		var shell_placed := _place_barrosan_module(shell_role, str(shell_entry.get("module", "")), _to_world(structure.get("position", Vector2.ZERO), 0.20), float(shell_entry.get("yawDegrees", 0.0)), _runtime_module_scale(shell_role))
		if shell_placed != null:
			_register_runtime_structure(shell_role, shell_placed, false, str(structure.get("id", "")), structure)
			return
	if barrosan_runtime_skin_enabled and (team == "friendly" or fixture == "west_stone_cut") and LIVE_FIXTURE_ROLES.has(fixture):
		var role := str(LIVE_FIXTURE_ROLES[fixture])
		var entry: Dictionary = barrosan_role_entries.get(role, {})
		var placed := _place_barrosan_module(role, str(entry.get("module", "")), _to_world(structure.get("position", Vector2.ZERO), 0.20), float(entry.get("yawDegrees", 0.0)), _runtime_module_scale(role))
		if placed != null:
			_register_runtime_structure(role, placed, true, str(structure.get("id", LIVE_ROLE_IDS.get(role, role))), structure)
			return
	super._add_structure(structure)


func _add_capture_site(site: Dictionary) -> void:
	super._add_capture_site(site)


func _upgrade_inert_roles_to_runtime_shells() -> void:
	for role in ["house", "farm", "lumber", "blacksmith", "watchtower", "market"]:
		var runtime_id := "v0243_shell_%s" % role
		if runtime.structures.any(func(structure: Dictionary) -> bool: return str(structure.get("id", "")) == runtime_id):
			continue
		var entry: Dictionary = barrosan_role_entries.get(role, {})
		var footprint := _runtime_footprint(entry) * 90.0
		var runtime_position := _from_world(INERT_ROLE_POSITIONS[role])
		runtime.structures.append({
			"id": runtime_id,
			"fixtureId": "barrosan_shell_%s" % role,
			"roleId": "barrosan_role_%s" % role,
			"team": "friendly",
			"position": runtime_position,
			"size": footprint,
			"rect": Rect2(runtime_position - footprint * 0.5, footprint),
			"entityType": "sim_safe_role_shell",
			"alive": true,
			"health": 500.0,
			"maxHealth": 500.0,
			"constructionState": "shell_complete",
			"constructionProgress": 1.0,
			"productionQueue": [],
			"productionEnabled": false,
			"economyMutationAllowed": false,
			"aiMutationAllowed": false,
			"combatEnabled": false,
			"savePersistenceEnabled": false,
		})


func _register_runtime_structure(role: String, placed: Node3D, live: bool, runtime_id: String, runtime_entity: Dictionary = {}) -> void:
	var entry: Dictionary = barrosan_role_entries.get(role, {})
	var footprint := _runtime_footprint(entry)
	barrosan_runtime_structures[role] = {
		"role": role,
		"runtimeId": runtime_id,
		"stableRoleId": "barrosan_role_%s" % role,
		"displayName": str(entry.get("displayName", role)),
		"module": str(entry.get("module", "")),
		"position": placed.position,
		"footprint": footprint,
		"liveGameplayEntity": live,
		"simSafeShellEntity": not live,
		"selectable": true,
		"health": runtime_entity.get("health", null),
		"maxHealth": runtime_entity.get("maxHealth", null),
		"productionEnabled": bool(runtime_entity.get("productionEnabled", live and role == "barracks")),
		"collisionPathingFootprintActive": not live,
	}
	_add_runtime_footprint(role, placed.position, footprint)
	_add_runtime_role_label(role, str(entry.get("displayName", role)), placed.position, live)


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
	placed.name = "v0242_%s_%s" % [role, module_name]
	placed.visible = true
	placed.position = position
	placed.rotation_degrees.y = yaw_degrees
	placed.scale = Vector3.ONE * scale_value
	visual_root.add_child(placed)
	return placed


func _runtime_module_scale(role: String) -> float:
	var entry: Dictionary = barrosan_role_entries.get(role, {})
	return float(entry.get("scale", 0.76)) * float(ROLE_SCALE_FACTORS.get(role, 0.08))


func _runtime_footprint(entry: Dictionary) -> Vector2:
	var footprint: Array = entry.get("footprint", [])
	if footprint.size() != 2:
		return Vector2(0.9, 0.7)
	return Vector2(float(footprint[0]), float(footprint[1])) * 0.105


func _add_runtime_footprint(role: String, position: Vector3, footprint: Vector2) -> void:
	_add_box("v0242_footprint_%s" % role, position + Vector3(0.0, -0.028, 0.0), Vector3(footprint.x, 0.018, footprint.y), Color(0.24, 0.62, 0.42, 0.08), true)


func _add_runtime_role_label(role: String, display_name: String, position: Vector3, live: bool) -> void:
	var label := Label3D.new()
	label.name = "v0242_role_label_%s" % role
	label.text = "%s\n%s" % [display_name, "LIVE ENTITY" if live else "INERT OPT-IN"]
	label.position = position + Vector3(0.0, 0.70, 0.0)
	label.font_size = 18
	label.pixel_size = 0.006
	label.outline_size = 5
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.visible = barrosan_runtime_debug_labels or barrosan_runtime_review_mode in ["all_roles", "inert_roles"]
	visual_root.add_child(label)


func _select_from_real_click(screen_position: Vector2) -> void:
	var role := _pick_barrosan_structure_from_screen(screen_position)
	if role != "":
		select_barrosan_runtime_role(role)
		return
	super._select_from_real_click(screen_position)


func _pick_barrosan_structure_from_screen(screen_position: Vector2) -> String:
	var best_role := ""
	var best_distance := INF
	for role in barrosan_runtime_structures:
		var structure: Dictionary = barrosan_runtime_structures[role]
		var projected := _world_to_screen(structure.get("position", Vector3.INF))
		if projected == Vector2.INF:
			continue
		var footprint: Vector2 = structure.get("footprint", Vector2.ONE)
		var radius := clampf(maxf(footprint.x, footprint.y) * 36.0, 24.0, 70.0)
		var distance := projected.distance_to(screen_position)
		if distance <= radius and distance < best_distance:
			best_role = str(role)
			best_distance = distance
	return best_role


func select_barrosan_runtime_role(role: String) -> bool:
	if not barrosan_runtime_structures.has(role):
		return false
	runtime.clear_selection()
	real_input_selected_id = ""
	barrosan_selected_role_id = role
	v0133_selected_structure_id = "barracks" if role == "barracks" else "barrosan_role_%s" % role
	v0133_barracks_selected = role == "barracks"
	real_input_hud_card_updated = true
	_record_real_input("barrosan_runtime_structure_selected", {
		"role": role,
		"stableRoleId": "barrosan_role_%s" % role,
		"liveGameplayEntity": bool(barrosan_runtime_structures[role].get("liveGameplayEntity", false)),
	})
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _sync_hud() -> void:
	super._sync_hud()
	if not barrosan_runtime_skin_enabled or barrosan_selected_role_id == "" or not barrosan_runtime_structures.has(barrosan_selected_role_id):
		return
	var structure: Dictionary = barrosan_runtime_structures[barrosan_selected_role_id]
	var display_name := str(structure.get("displayName", barrosan_selected_role_id.capitalize()))
	if hud_hero_label:
		hud_hero_label.text = "%s | %s" % [display_name, "Live gameplay building" if bool(structure.get("liveGameplayEntity", false)) else "Sim-safe role shell"]
	if hud_context_label:
		if bool(structure.get("liveGameplayEntity", false)):
			hud_context_label.text = _barrosan_live_state_text(barrosan_selected_role_id)
		else:
			hud_context_label.text = "Shell / opt-in / 500 HP / no production yet"


func set_barrosan_runtime_review_mode(mode: String) -> void:
	barrosan_runtime_review_mode = mode
	match mode:
		"selected":
			select_barrosan_runtime_role("market")
		"selected_live":
			select_barrosan_runtime_role("barracks")
		"selected_shell":
			select_barrosan_runtime_role("blacksmith")
		"v0244_overview":
			_clear_barrosan_playtest_selection()
		"v0244_select_aster":
			_select_playtest_unit("hero_aster")
		"v0244_road_probe":
			_run_v0244_movement_probe("road_adjacent", "hero_aster", Vector2(520, 700), 240)
		"v0244_bridge_probe":
			_run_v0244_movement_probe("bridge_river", "worker_00", Vector2(760, 560), 280)
		"v0244_select_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0244_select_barracks":
			select_barrosan_runtime_role("barracks")
			_record_v0244_live_role("barracks")
		"v0244_barracks_flow":
			_run_v0244_barracks_restore_train_flow()
		"v0244_select_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0244_select_forge":
			_select_v0244_shell("blacksmith")
		"v0244_select_market":
			_select_v0244_shell("market")
			_select_v0244_shell("watchtower", false)
			select_barrosan_runtime_role("market")
		"v0244_valid_preview":
			_run_v0244_preview_probe(false)
		"v0244_blocked_preview":
			_run_v0244_preview_probe(true)
		"v0244_resource_proof":
			_show_v0244_resource_proof()
		"v0244_minimap":
			_clear_barrosan_playtest_selection()
			barrosan_runtime_review_mode = "all_roles"
		"v0244_clean":
			_clear_barrosan_playtest_selection()
		"inert_roles":
			select_barrosan_runtime_role("blacksmith")
		"live_roles":
			select_barrosan_runtime_role("mine")
		"pathing":
			_run_barrosan_shell_pathing_probe()
		"valid_preview", "blocked_preview", "all_roles":
			barrosan_selected_role_id = ""
			v0133_selected_structure_id = ""
		_:
			if mode == "clean":
				barrosan_selected_role_id = ""
	_sync_barrosan_runtime_visuals()
	_sync_hud()


func _sync_unit_visuals() -> void:
	super._sync_unit_visuals()
	_sync_barrosan_runtime_visuals()


func _sync_barrosan_runtime_visuals() -> void:
	if visual_root == null or not barrosan_runtime_skin_enabled:
		return
	for role in barrosan_runtime_structures:
		var label := visual_root.get_node_or_null("v0242_role_label_%s" % role) as Label3D
		if label != null:
			label.visible = barrosan_runtime_debug_labels or barrosan_runtime_review_mode in ["all_roles", "inert_roles"]
		var structure: Dictionary = barrosan_runtime_structures[role]
		var position: Vector3 = structure.get("position", Vector3.ZERO)
		var footprint: Vector2 = structure.get("footprint", Vector2.ONE)
		_set_or_create_disc_marker("v0242_selected_%s" % role, position + Vector3(0.0, 0.015, 0.0), maxf(0.46, maxf(footprint.x, footprint.y) * 0.55), Color(0.96, 0.78, 0.24, 0.62))
		var marker := visual_root.get_node_or_null("v0242_selected_%s" % role)
		if marker != null:
			marker.visible = barrosan_selected_role_id == role
		var footprint_node := visual_root.get_node_or_null("v0242_footprint_%s" % role)
		if footprint_node != null:
			footprint_node.visible = barrosan_runtime_review_mode in ["all_roles", "footprints", "valid_preview", "blocked_preview"]
	var valid_world: Vector3 = barrosan_build_validation_adapter.source_to_runtime_world(_placement_point(barrosan_valid_placement))
	var blocked_world: Vector3 = barrosan_build_validation_adapter.source_to_runtime_world(_placement_point(barrosan_blocked_placement))
	_set_or_create_marker("v0242_valid_placement_preview", valid_world, Vector3(0.92, 0.045, 0.72), Color(0.20, 0.82, 0.46, 0.44))
	_set_or_create_marker("v0242_blocked_placement_preview", blocked_world, Vector3(0.92, 0.045, 0.72), Color(0.90, 0.22, 0.16, 0.46))
	var valid_preview := visual_root.get_node_or_null("v0242_valid_placement_preview")
	var blocked_preview := visual_root.get_node_or_null("v0242_blocked_placement_preview")
	if valid_preview != null:
		valid_preview.visible = barrosan_runtime_review_mode == "valid_preview"
	if blocked_preview != null:
		blocked_preview.visible = barrosan_runtime_review_mode == "blocked_preview"
	_sync_validation_reason_label(valid_world, blocked_world)
	_sync_v0244_resource_label()
	_sync_scale_probes()


func _evaluate_barrosan_build_previews() -> void:
	barrosan_valid_placement = barrosan_build_validation_adapter.evaluate(Vector2(520, 1450), "barracks", runtime.resources)
	barrosan_blocked_placement = barrosan_build_validation_adapter.evaluate(Vector2(1280, 800), "barracks", runtime.resources)


func _sync_validation_reason_label(valid_world: Vector3, blocked_world: Vector3) -> void:
	var label := visual_root.get_node_or_null("v0243_validation_reason") as Label3D
	if label == null:
		label = Label3D.new()
		label.name = "v0243_validation_reason"
		label.font_size = 20
		label.pixel_size = 0.006
		label.outline_size = 6
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		visual_root.add_child(label)
	var blocked := barrosan_runtime_review_mode == "blocked_preview"
	label.position = (blocked_world if blocked else valid_world) + Vector3(0.0, 0.62, 0.0)
	label.text = str((barrosan_blocked_placement if blocked else barrosan_valid_placement).get("reasonText", ""))
	label.modulate = Color("#ffaaa0") if blocked else Color("#a8efad")
	label.visible = barrosan_runtime_review_mode in ["valid_preview", "blocked_preview"]


func _placement_point(result: Dictionary) -> Vector2:
	var point: Dictionary = result.get("point", {})
	return Vector2(float(point.get("x", 0.0)), float(point.get("y", 0.0)))


func _barrosan_live_state_text(role: String) -> String:
	match role:
		"barracks":
			return "Live | %s | train flow preserved" % ("complete" if runtime.barracks_complete else "restoration available")
		"mine":
			return "Live resource site | %s" % ("controlled" if runtime.mine_converted else "neutral")
		_:
			return "Live base entity | complete"


func _run_barrosan_shell_pathing_probe() -> void:
	barrosan_selected_role_id = ""
	v0133_selected_structure_id = ""
	var before = runtime.unit_position("worker_00")
	runtime.select_entity("worker_00")
	var accepted := runtime.issue_move_order(Vector2(520, 700))
	for _frame in range(240):
		runtime.advance_live_frame()
	var after = runtime.unit_position("worker_00")
	barrosan_pathing_probe = {
		"accepted": accepted,
		"before": before,
		"after": after,
		"displacement": before.distance_to(after) if before is Vector2 and after is Vector2 else 0.0,
		"stuckUnitCount": runtime.stuck_unit_count,
		"obstacleModel": "existing rectangular destination nudge",
	}
	_sync_unit_visuals()
	_sync_hud()


func _reset_barrosan_playtest_status() -> void:
	barrosan_playtest = {
		"status": "READY",
		"baseCommit": "832175edc9acd71648b0d986061e45f98f6464dd",
		"baseCiRun": "https://github.com/jardas33/ascendant-realms/actions/runs/27884622555",
		"selectedUnits": [],
		"selectedLiveRoles": [],
		"selectedShellRoles": [],
		"movementProbes": {},
		"barracksRestoreTrain": {
			"supported": true,
			"attempted": false,
			"restored": false,
			"militiaQueued": false,
			"militiaSpawned": false,
		},
		"constructionAttempted": false,
		"constructionStatus": "preview-only-intentionally-skipped",
		"previewResourcesBefore": {},
		"previewResourcesAfter": {},
		"previewResourcesUnchanged": false,
		"validPreview": {},
		"blockedPreview": {},
		"minimapRolesAfterPlaytest": 0,
	}


func _clear_barrosan_playtest_selection() -> void:
	runtime.clear_selection()
	real_input_selected_id = ""
	barrosan_selected_role_id = ""
	v0133_selected_structure_id = ""
	v0133_barracks_selected = false


func _select_playtest_unit(unit_id: String) -> bool:
	_clear_barrosan_playtest_selection()
	var selected := runtime.select_entity(unit_id)
	if selected:
		var selected_units: Array = barrosan_playtest.get("selectedUnits", [])
		if not selected_units.has(unit_id):
			selected_units.append(unit_id)
		barrosan_playtest["selectedUnits"] = selected_units
	_sync_unit_visuals()
	_sync_hud()
	return selected


func _select_v0244_shell(role: String, show_selection: bool = true) -> bool:
	var selected := select_barrosan_runtime_role(role)
	if selected:
		var shell_roles: Array = barrosan_playtest.get("selectedShellRoles", [])
		if not shell_roles.has(role):
			shell_roles.append(role)
		barrosan_playtest["selectedShellRoles"] = shell_roles
	if not show_selection:
		_clear_barrosan_playtest_selection()
	return selected


func _record_v0244_live_role(role: String) -> void:
	var live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	if not live_roles.has(role):
		live_roles.append(role)
	barrosan_playtest["selectedLiveRoles"] = live_roles


func _run_v0244_movement_probe(probe_id: String, unit_id: String, target: Vector2, frames: int) -> void:
	_clear_barrosan_playtest_selection()
	var selected := runtime.select_entity(unit_id)
	var before: Vector2 = runtime.unit_position(unit_id)
	var stuck_before: int = int(runtime.stuck_unit_count)
	var accepted := selected and runtime.issue_move_order(target)
	for _frame in range(frames):
		runtime.advance_live_frame()
	var after: Vector2 = runtime.unit_position(unit_id)
	var displacement: float = before.distance_to(after)
	var probes: Dictionary = barrosan_playtest.get("movementProbes", {})
	probes[probe_id] = {
		"unitId": unit_id,
		"accepted": accepted,
		"target": target,
		"before": before,
		"after": after,
		"displacement": displacement,
		"stuckDelta": runtime.stuck_unit_count - stuck_before,
		"obstacleModel": "existing rectangular destination nudge",
		"reviewGradeOnly": true,
	}
	barrosan_playtest["movementProbes"] = probes
	_sync_unit_visuals()
	_sync_hud()


func _run_v0244_barracks_restore_train_flow() -> void:
	var before_resources: Dictionary = runtime.resources.duplicate(true)
	var mine_captured: bool = runtime.mine_converted or capture_mine_site()
	var worker_assigned: bool = runtime.worker_assigned_to_mine or assign_worker_to_mine()
	var build_started: bool = runtime.barracks_build_placed or place_barracks_placeholder()
	var construction_advanced: bool = runtime.barracks_complete or advance_construction(180)
	select_barrosan_runtime_role("barracks")
	_record_v0244_live_role("barracks")
	var queued: bool = runtime.militia_recruit_queued or runtime.militia_spawned or queue_militia_recruit()
	var spawned: bool = runtime.militia_spawned or (queued and complete_recruit_queue(140))
	barrosan_playtest["barracksRestoreTrain"] = {
		"supported": true,
		"attempted": true,
		"mineCaptured": mine_captured,
		"workerAssigned": worker_assigned,
		"buildStarted": build_started,
		"constructionAdvanced": construction_advanced,
		"restored": runtime.barracks_complete,
		"militiaQueued": queued,
		"militiaSpawned": runtime.militia_spawned and spawned,
		"resourcesBefore": before_resources,
		"resourcesAfter": runtime.resources.duplicate(true),
		"resourceChangeLegitimate": queued,
	}
	_run_v0244_movement_probe("live_mine", "worker_00", Vector2(650, 460), 180)
	_run_v0244_movement_probe("barracks_main_base", "recruited_militia_00" if runtime.militia_spawned else "hero_aster", Vector2(360, 260), 220)
	select_barrosan_runtime_role("barracks")
	_sync_hud()


func _run_v0244_preview_probe(blocked: bool) -> void:
	_clear_barrosan_playtest_selection()
	var before: Dictionary = runtime.resources.duplicate(true)
	_evaluate_barrosan_build_previews()
	barrosan_runtime_review_mode = "blocked_preview" if blocked else "valid_preview"
	var result := (barrosan_blocked_placement if blocked else barrosan_valid_placement).duplicate(true)
	var after: Dictionary = runtime.resources.duplicate(true)
	if barrosan_playtest.get("previewResourcesBefore", {}).is_empty():
		barrosan_playtest["previewResourcesBefore"] = before
	barrosan_playtest["previewResourcesAfter"] = after
	barrosan_playtest["previewResourcesUnchanged"] = barrosan_playtest["previewResourcesBefore"] == after
	barrosan_playtest["blockedPreview" if blocked else "validPreview"] = result
	barrosan_playtest["constructionAttempted"] = false
	barrosan_playtest["constructionStatus"] = "preview-only-intentionally-skipped"


func _show_v0244_resource_proof() -> void:
	_clear_barrosan_playtest_selection()
	barrosan_runtime_review_mode = "v0244_resource_proof"
	_sync_v0244_resource_label()


func _sync_v0244_resource_label() -> void:
	if visual_root == null:
		return
	var label := visual_root.get_node_or_null("v0244_resource_proof") as Label3D
	if label == null:
		label = Label3D.new()
		label.name = "v0244_resource_proof"
		label.font_size = 19
		label.pixel_size = 0.006
		label.outline_size = 6
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		visual_root.add_child(label)
	label.position = Vector3(-0.55, 1.05, 2.10)
	label.text = "PREVIEW ONLY\nResources unchanged" if bool(barrosan_playtest.get("previewResourcesUnchanged", false)) else "PREVIEW RESOURCE CHECK PENDING"
	label.modulate = Color("#a8efad") if bool(barrosan_playtest.get("previewResourcesUnchanged", false)) else Color("#ffcf82")
	label.visible = barrosan_runtime_review_mode == "v0244_resource_proof"


func _sync_scale_probes() -> void:
	for probe in ["worker", "militia", "aster"]:
		var node := visual_root.get_node_or_null("v0242_probe_%s" % probe)
		if node != null:
			node.queue_free()
	if barrosan_runtime_review_mode != "units_scale":
		return
	_add_scale_probe("worker", Vector3(-4.22, 0.28, 2.12), 0.18, Color("#d6b878"))
	_add_scale_probe("militia", Vector3(4.05, 0.28, -2.00), 0.22, Color("#8fc2a4"))
	_add_scale_probe("aster", Vector3(-2.05, 0.28, 0.12), 0.26, Color("#46bdb2"))


func _add_scale_probe(id: String, position: Vector3, radius: float, color: Color) -> void:
	_add_cylinder("v0242_probe_%s" % id, position, radius, 0.54, color)


func _add_barrosan_minimap_role_markers() -> void:
	if minimap_panel == null:
		return
	var marker_data := {
		"main_base": [Vector2(34, 44), Color("#d5b45d")],
		"barracks": [Vector2(52, 68), Color("#bd8c50")],
		"mine": [Vector2(82, 142), Color("#55c8b5")],
		"house": [Vector2(60, 174), Color("#d8c59c")],
		"farm": [Vector2(86, 184), Color("#c89b4b")],
		"lumber": [Vector2(112, 180), Color("#8c6844")],
		"blacksmith": [Vector2(182, 170), Color("#79463b")],
		"watchtower": [Vector2(216, 72), Color("#ad4f3c")],
		"market": [Vector2(196, 120), Color("#d69a43")],
	}
	for role in marker_data:
		var config: Array = marker_data[role]
		var marker_name := "v0242_minimap_role_%s" % role
		if not _minimap_has_marker(marker_name):
			_add_minimap_marker(marker_name, config[0], Vector2(12, 12), config[1])


func _sync_minimap() -> void:
	super._sync_minimap()
	if barrosan_runtime_skin_enabled:
		_add_barrosan_minimap_role_markers()


func get_spike_status() -> Dictionary:
	var status := super.get_spike_status()
	var addressable_roles: Array[String] = []
	var live_roles: Array[String] = []
	var shell_roles: Array[String] = []
	for role in EXPECTED_ROLES:
		if not barrosan_runtime_structures.has(role):
			continue
		addressable_roles.append(role)
		if bool(barrosan_runtime_structures[role].get("liveGameplayEntity", false)):
			live_roles.append(role)
		else:
			shell_roles.append(role)
	status["barrosanPlayableRuntimeSkin"] = {
		"enabled": barrosan_runtime_skin_enabled,
		"checkpoint": barrosan_runtime_checkpoint,
		"scenePath": "res://scenes/salto_barrosan_playable_runtime_skin.tscn",
		"mappingPath": V0240_MAPPING_PATH,
		"sourceGlb": V0239_KIT_PATH,
		"defaultRuntimeChanged": false,
		"gameplaySystemsChanged": false,
		"terrainVisualOnly": true,
		"terrainCollisionChanged": false,
		"pathingChanged": false,
		"addressableRoles": addressable_roles,
		"liveMappedRoles": live_roles,
		"simSafeShellRoles": shell_roles,
		"selectedRole": barrosan_selected_role_id,
		"selectionIntegrated": addressable_roles.size() == 9,
		"footprintCount": addressable_roles.size(),
		"placementValidation": "read-only-generated-authority-adapter",
		"buildValidationAdapter": barrosan_build_validation_adapter.status(),
		"validPlacementResult": barrosan_valid_placement,
		"blockedPlacementResult": barrosan_blocked_placement,
		"blockedPlacementReason": str(barrosan_blocked_placement.get("reason", "")),
		"shellFootprintsAffectRuntimeObstacleAvoidance": true,
		"pathingProbe": barrosan_pathing_probe,
		"visualRoadsMatchActualPathing": "partial-decorative-mismatch",
		"minimapRoleMarkerCount": addressable_roles.size(),
		"debugLabelsVisible": barrosan_runtime_debug_labels or barrosan_runtime_review_mode in ["all_roles", "inert_roles"],
		"reviewMode": barrosan_runtime_review_mode,
		"errors": barrosan_runtime_errors.duplicate(),
		"limitedTechnicalPlaytest": _v0244_playtest_status(addressable_roles) if barrosan_runtime_checkpoint == "v0.244" else {},
	}
	return status


func _v0244_playtest_status(addressable_roles: Array[String]) -> Dictionary:
	var result := barrosan_playtest.duplicate(true)
	var probes: Dictionary = result.get("movementProbes", {})
	var movement_pass := ["road_adjacent", "bridge_river", "live_mine", "barracks_main_base"].all(
		func(probe_id: String) -> bool:
			var probe: Dictionary = probes.get(probe_id, {})
			return bool(probe.get("accepted", false)) and float(probe.get("displacement", 0.0)) > 20.0 and int(probe.get("stuckDelta", 0)) == 0
	)
	result["status"] = "PASS" if (
		addressable_roles.size() == 9
		and movement_pass
		and bool(result.get("previewResourcesUnchanged", false))
		and bool(result.get("validPreview", {}).get("ok", false))
		and not bool(result.get("blockedPreview", {}).get("ok", true))
		and bool(result.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
	) else "IN_PROGRESS"
	result["movementProbePass"] = movement_pass
	result["pathingParity"] = "review-grade rectangular destination-nudge only"
	result["realConstructionAttempted"] = false
	result["realConstructionStatus"] = "preview-only-intentionally-skipped"
	result["defaultRuntimeChanged"] = false
	result["minimapRolesAfterPlaytest"] = addressable_roles.size()
	result["shellsRemainNonProducing"] = true
	return result
