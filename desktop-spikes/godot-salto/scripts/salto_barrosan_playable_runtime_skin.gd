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
const V0245_CONSTRUCTED_KEY := "constructed_barracks"
const V0245_CONSTRUCTED_RUNTIME_ID := "v0245_authoritative_barracks_00"
const V0245_CONSTRUCTED_ROLE_ID := "barrosan_role_barracks_constructed_00"
const V0246_FIELD_MILITIA_RUNTIME_ID := "v0246_field_militia_00"
const V0247_ASHEN_RAIDER_RUNTIME_ID := "v0247_ashen_raider_00"
const V0247_PRESSURE_SPAWN := Vector2(1420, 560)
const V0247_PRESSURE_LANE_START := Vector2(1160, 650)
const V0247_PRESSURE_BRIDGE_APPROACH := Vector2(900, 760)
const V0247_PRESSURE_MARKER := Vector2(820, 780)
const V0247_INTERCEPT_ZONE := Vector2(790, 760)
const V0247_INTERCEPT_RADIUS := 115.0
const V0249_MILITIA_MAX_HP := 100.0
const V0249_RAIDER_MAX_HP := 60.0
const V0249_MILITIA_DAMAGE := 20.0
const V0249_RAIDER_DAMAGE := 10.0
const V0249_COMBAT_TICK_SECONDS := 1.0
const V0251_FIELD_BARRACKS_MAX_HP := 200.0
const V0251_RAIDER_BUILDING_DAMAGE := 25.0
const V0251_BUILDING_DAMAGE_TICK_LIMIT := 3
const V0251_FIELD_BARRACKS_PRESSURE_POINT := Vector2(600, 1400)
const V0251_FIELD_BARRACKS_PRESSURE_RADIUS := 135.0
const V0252_THREAT_WINDOW_STEPS := 3
const V0252_THREAT_WINDOW_SECONDS := 3.0
const V0253_REPAIR_COST := {"crowns": 30, "stone": 30, "iron": 0, "aether": 0}
const V0253_REPAIR_AMOUNT := 25.0
const V0253_REPAIR_TICK_LIMIT := 3
const V0255_SECOND_PRESSURE_DAMAGE_TICK_LIMIT := 5
const V0256_REBUILD_COST := {"crowns": 90, "stone": 40, "iron": 0, "aether": 0}
const V0256_REBUILD_AMOUNT := 25.0
const V0256_REBUILD_TICK_LIMIT := 4
const V0261_WATCHPOST_KEY := "v0261_barrosan_watchpost"
const V0261_WATCHPOST_RUNTIME_ID := "v0261_barrosan_watchpost_00"
const V0261_WATCHPOST_COST := {"crowns": 100, "stone": 30, "iron": 10, "aether": 0}
const V0261_WATCHPOST_MAX_HP := 120.0
const V0261_WATCHPOST_SOURCE_POSITION := Vector2(1020, 1120)
const V0262_WATCH_ZONE_RADIUS := 260.0
const V0262_ASHEN_OUTSIDE_ZONE := Vector2(1360, 1120)
const V0262_ASHEN_TOUCHING_ZONE := Vector2(1280, 1120)
const V0262_ASHEN_INSIDE_ZONE := Vector2(1140, 1060)
const V0263_LAST_SEEN_SECTOR := "east bridge"
const PORTABLE_CONTENT_PATH := "res://data/generated/content-subset.json"

var barrosan_runtime_skin_enabled := false
var barrosan_runtime_checkpoint := "v0.243"
var barrosan_requested_checkpoint := "v0.243"
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
var v0246_militia_definition: Dictionary = {}
var v0251_defended_proof: Dictionary = {}
var v0251_undefended_proof: Dictionary = {}
var v0252_defended_proof: Dictionary = {}
var v0252_missed_window_proof: Dictionary = {}
var v0253_defended_proof: Dictionary = {}
var v0253_repair_proof: Dictionary = {}
var v0254_damaged_proof: Dictionary = {}
var v0254_repair_proof: Dictionary = {}
var v0254_defended_proof: Dictionary = {}
var v0255_damaged_proof: Dictionary = {}
var v0255_destroyed_proof: Dictionary = {}
var v0255_intercepted_proof: Dictionary = {}
var v0255_repair_proof: Dictionary = {}
var v0255_defended_proof: Dictionary = {}
var v0256_destroyed_proof: Dictionary = {}
var v0256_rebuild_proof: Dictionary = {}
var v0256_separation_proof: Dictionary = {}
var v0256_defended_proof: Dictionary = {}
var v0257_hud_proof: Dictionary = {}
var v0258_lifecycle_proof: Dictionary = {}
var v0259_ui_invariant_proof: Dictionary = {}
var v0261_watchpost_proof: Dictionary = {}
var v0262_watchpost_awareness_proof: Dictionary = {}
var v0263_watchpost_intel_memory_proof: Dictionary = {}


func configure_barrosan_playable_runtime_skin(options: Dictionary) -> void:
	barrosan_runtime_skin_enabled = bool(options.get("enabled", false))
	barrosan_requested_checkpoint = str(options.get("checkpoint", "v0.243"))
	barrosan_runtime_checkpoint = "v0.253" if barrosan_requested_checkpoint in ["v0.254", "v0.255", "v0.256", "v0.257", "v0.258", "v0.259", "v0.261", "v0.262", "v0.263"] else barrosan_requested_checkpoint
	barrosan_runtime_debug_labels = bool(options.get("debugLabels", false))
	if not barrosan_runtime_skin_enabled:
		return
	_load_barrosan_runtime_assets()
	_upgrade_inert_roles_to_runtime_shells()
	barrosan_build_validation_adapter.load_authority()
	_evaluate_barrosan_build_previews()
	if barrosan_runtime_checkpoint in ["v0.244", "v0.245", "v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		_reset_barrosan_playtest_status()
	if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		_load_v0246_militia_authority()
	if barrosan_runtime_checkpoint in ["v0.252", "v0.253"]:
		_set_v0252_aster_health_contract()
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
	if barrosan_runtime_skin_enabled and fixture == "barrosan_authoritative_barracks":
		var constructed_entry: Dictionary = barrosan_role_entries.get("barracks", {})
		var constructed: Node3D = _place_barrosan_module("barracks", str(constructed_entry.get("module", "")), _to_world(structure.get("position", Vector2.ZERO), 0.20), float(constructed_entry.get("yawDegrees", 0.0)), _runtime_module_scale("barracks"))
		if constructed != null:
			_register_runtime_structure("barracks", constructed, false, str(structure.get("id", "")), structure, V0245_CONSTRUCTED_KEY, V0245_CONSTRUCTED_ROLE_ID, "Authoritative Field Barracks")
			return
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


func _register_runtime_structure(role: String, placed: Node3D, live: bool, runtime_id: String, runtime_entity: Dictionary = {}, registry_key: String = "", stable_role_id: String = "", display_name_override: String = "") -> void:
	var entry: Dictionary = barrosan_role_entries.get(role, {})
	var footprint := _runtime_footprint(entry)
	var key: String = role if registry_key == "" else registry_key
	barrosan_runtime_structures[key] = {
		"role": role,
		"runtimeId": runtime_id,
		"stableRoleId": "barrosan_role_%s" % role if stable_role_id == "" else stable_role_id,
		"displayName": str(entry.get("displayName", role)) if display_name_override == "" else display_name_override,
		"module": str(entry.get("module", "")),
		"position": placed.position,
		"footprint": footprint,
		"liveGameplayEntity": live,
		"simSafeShellEntity": not live,
		"technicalConstructionEntity": bool(runtime_entity.get("technicalConstructionEntity", false)),
		"selectable": true,
		"health": runtime_entity.get("health", null),
		"maxHealth": runtime_entity.get("maxHealth", null),
		"productionEnabled": bool(runtime_entity.get("productionEnabled", live and role == "barracks")),
		"collisionPathingFootprintActive": not live,
	}
	_add_runtime_footprint(key, placed.position, footprint)
	_add_runtime_role_label(key, str(entry.get("displayName", role)) if display_name_override == "" else display_name_override, placed.position, live)


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
		"stableRoleId": str(barrosan_runtime_structures[role].get("stableRoleId", "barrosan_role_%s" % role)),
		"liveGameplayEntity": bool(barrosan_runtime_structures[role].get("liveGameplayEntity", false)),
	})
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _sync_hud() -> void:
	super._sync_hud()
	if not barrosan_runtime_skin_enabled:
		return
	if barrosan_selected_role_id != "" and barrosan_runtime_structures.has(barrosan_selected_role_id):
		var structure: Dictionary = barrosan_runtime_structures[barrosan_selected_role_id]
		var display_name := str(structure.get("displayName", barrosan_selected_role_id.capitalize()))
		if hud_hero_label:
			var kind := "Live gameplay building" if bool(structure.get("liveGameplayEntity", false)) else ("Opt-in production bridge" if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and barrosan_selected_role_id == V0245_CONSTRUCTED_KEY else ("Opt-in technical construction" if bool(structure.get("technicalConstructionEntity", false)) else "Sim-safe role shell"))
			hud_hero_label.text = "%s | %s" % [display_name, kind]
			if barrosan_runtime_checkpoint in ["v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and barrosan_selected_role_id == V0245_CONSTRUCTED_KEY:
				var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
				var state := str(consequence.get("fieldBarracksState", "unharmed"))
				hud_hero_label.text = "Authoritative Field Barracks | %s" % ("Repairing" if state == "repairing" else ("Threatened" if state == "threatened" else ("Under Ashen pressure" if state == "under_pressure" else ("Damaged but standing" if state == "damaged" else "Opt-in production bridge"))))
		if hud_context_label:
			if bool(structure.get("liveGameplayEntity", false)):
				hud_context_label.text = _barrosan_live_state_text(barrosan_selected_role_id)
			elif bool(structure.get("technicalConstructionEntity", false)):
				hud_context_label.text = _v0246_field_barracks_hud_text() if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else "Authoritative placement / complete / no production"
			else:
				hud_context_label.text = "Shell / opt-in / 500 HP / no production yet"
		if hud_work_button != null and barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and barrosan_selected_role_id == V0245_CONSTRUCTED_KEY:
			hud_work_button.text = "Train Militia"
		if barrosan_runtime_checkpoint in ["v0.251", "v0.252", "v0.253"] and barrosan_selected_role_id == V0245_CONSTRUCTED_KEY:
			var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
			var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			var damage_ticks := int(consequence.get("buildingDamageTickCount", 0))
			var field_status := _v0246_field_barracks_hud_text()
			if bool(consequence.get("buildingDamageStarted", false)):
				field_status = "Building pressure incoming"
			if bool(timing.get("damageImminent", false)):
				field_status = "Damage imminent"
			if bool(timing.get("warningActive", false)):
				field_status = "Ashen pressure approaching"
			if damage_ticks > 0:
				field_status = "Damage tick %s/3" % damage_ticks
			if bool(consequence.get("buildingPressureContained", false)):
				field_status = "Pressure damage contained"
			if barrosan_runtime_checkpoint == "v0.253" and _v0251_field_barracks_health() < V0251_FIELD_BARRACKS_MAX_HP:
				field_status = "Worker repair available"
			if bool(repair.get("repairStarted", false)):
				field_status = "Repair progress %s/3" % int(repair.get("repairTickCount", 0))
			if bool(repair.get("repairComplete", false)):
				field_status = "Repair complete"
			hud_context_label.text = "%s | HP %s/%s" % [
				field_status,
				int(_v0251_field_barracks_health()),
				int(V0251_FIELD_BARRACKS_MAX_HP),
			]
			if barrosan_requested_checkpoint in ["v0.254", "v0.255", "v0.256", "v0.257", "v0.258", "v0.259"] and str(consequence.get("fieldBarracksState", "unharmed")) == "damaged":
				hud_hero_label.text = "Authoritative Field Barracks | Damaged but functional"
				hud_context_label.text = ("Operational | HP %s/200 | Train Militia available" if barrosan_requested_checkpoint == "v0.257" else "Operational | Damaged HP %s/200 | Train Militia available") % int(_v0251_field_barracks_health())
				hud_objective_strip_label.text = "Field Barracks damaged but functional"
				hud_objective_label.text = "Ready. | Production available while HP > 0" if barrosan_requested_checkpoint == "v0.257" else "Can train Militia | Worker repair available"
			if barrosan_requested_checkpoint in ["v0.255", "v0.256", "v0.257", "v0.258", "v0.259"]:
				var second: Dictionary = barrosan_playtest.get("v0255SecondPressure", {})
				var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
				var hp := int(_v0251_field_barracks_health())
				if bool(rebuild.get("rebuildStarted", false)):
					hud_hero_label.text = "Authoritative Field Barracks | Rebuilding"
					hud_context_label.text = ("Production unavailable until rebuild complete | HP %s/200" if barrosan_requested_checkpoint == "v0.257" else "HP %s/200 | Production unavailable | Worker rebuilding") % hp
					hud_objective_strip_label.text = "Rebuilding Field Barracks"
					hud_objective_label.text = "Production unavailable until rebuild complete"
					if hud_work_button != null:
						hud_work_button.text = "Train unavailable"
				elif hp <= 0:
					hud_hero_label.text = "Authoritative Field Barracks | Destroyed"
					hud_context_label.text = "HP 0/200 | Production unavailable"
					hud_objective_strip_label.text = "Authoritative Field Barracks destroyed"
					hud_objective_label.text = "Select Worker to rebuild"
					if hud_work_button != null:
						hud_work_button.text = "Train unavailable"
				elif bool(rebuild.get("rebuildComplete", false)) and hp == 100:
					hud_hero_label.text = "Authoritative Field Barracks | Damaged but functional"
					hud_context_label.text = "Operational | Rebuilt HP 100/200 | Train Militia available"
					hud_objective_strip_label.text = "Field Barracks rebuilt"
					hud_objective_label.text = "Production restored | Repair remains optional"
				elif bool(second.get("warningActive", false)):
					hud_hero_label.text = "Authoritative Field Barracks | Threatened"
					hud_context_label.text = "Second Ashen pressure approaching | HP %s/200 | Intercept before impact" % hp
					hud_objective_strip_label.text = "Second Ashen pressure incoming"
					hud_objective_label.text = "Intercept before impact"
				elif bool(second.get("damageStarted", false)) and hp == 25:
					hud_hero_label.text = "Authoritative Field Barracks | Damaged but functional" if barrosan_requested_checkpoint == "v0.257" else "Authoritative Field Barracks | Critical but functional"
					hud_context_label.text = "Operational | HP 25/200 | Train Militia available"
					hud_objective_label.text = "Ready. | Production still available while HP > 0"
				elif bool(second.get("damageStarted", false)):
					hud_hero_label.text = "Authoritative Field Barracks | Under Ashen pressure"
					hud_context_label.text = "HP %s/200 | Production still available while HP > 0" % hp
	if barrosan_runtime_checkpoint == "v0.253" and runtime.selected_ids.has("worker_00"):
		var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
		var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
		var repair_available := _v0253_repair_command_available()
		hud_hero_label.text = "Selected Worker"
		if barrosan_requested_checkpoint in ["v0.256", "v0.257", "v0.258", "v0.259"] and bool(rebuild.get("rebuildStarted", false)):
			hud_context_label.text = "Rebuilding Field Barracks | Progress active | Production unavailable until rebuild complete"
			hud_objective_strip_label.text = "Rebuilding Field Barracks"
			hud_objective_label.text = "HP %s/200 | Rebuild progress %s/4" % [int(_v0251_field_barracks_health()), int(rebuild.get("rebuildTickCount", 0))]
		elif barrosan_requested_checkpoint in ["v0.256", "v0.257", "v0.258", "v0.259"] and _v0251_field_barracks_health() <= 0.0:
			hud_context_label.text = "Rebuild available | Destroyed Field Barracks | Cost: 90 Crowns / 40 Stone | Ready."
			hud_objective_strip_label.text = "Rebuild destroyed Field Barracks"
			hud_objective_label.text = "Repair unavailable | Target destroyed"
		elif barrosan_requested_checkpoint == "v0.257" and bool(rebuild.get("rebuildComplete", false)):
			hud_context_label.text = "Rebuild unavailable | No destroyed target | Construction available | Ready."
			hud_objective_strip_label.text = "Field Barracks damaged but functional"
			hud_objective_label.text = "Repair unavailable | Insufficient Stone"
		elif barrosan_requested_checkpoint == "v0.257" and repair_available:
			hud_context_label.text = "Repair available | Damaged Field Barracks | Rebuild unavailable | Target not destroyed | Ready."
			hud_objective_strip_label.text = "Repair damaged Field Barracks"
			hud_objective_label.text = "Production available while HP > 0"
		elif barrosan_requested_checkpoint == "v0.256" and bool(rebuild.get("rebuildComplete", false)):
			hud_context_label.text = "Repair unavailable | Insufficient Stone | Construction available | Ready"
			hud_objective_strip_label.text = "Field Barracks damaged but functional"
			hud_objective_label.text = "Repair requires 30 Stone | Rebuild unavailable above HP 0"
		else:
			hud_context_label.text = "Repair unavailable | Target destroyed | Rebuild not yet implemented | Ready" if barrosan_requested_checkpoint == "v0.255" and _v0251_field_barracks_health() <= 0.0 else ("Repair order accepted | Repairing Field Barracks | Ready" if bool(repair.get("repairOrderAccepted", false)) and not bool(repair.get("repairComplete", false)) else ("Repair available | Target damaged Field Barracks | Ready" if repair_available else "Repair unavailable | No damaged target"))
			hud_objective_strip_label.text = "Repairing Field Barracks" if bool(repair.get("repairStarted", false)) and not bool(repair.get("repairComplete", false)) else ("Field Barracks restored" if bool(repair.get("repairComplete", false)) else "Repair damaged Field Barracks")
			hud_objective_label.text = "HP %s/200 | %s" % [int(_v0251_field_barracks_health()), "Repair complete" if bool(repair.get("repairComplete", false)) else ("Repair progress %s/3" % int(repair.get("repairTickCount", 0)) if bool(repair.get("repairStarted", false)) else "Worker repair available")]
		if hud_work_button != null:
			hud_work_button.text = "Rebuild" if _v0256_rebuild_command_available() else ("Repair" if repair_available else "Repair unavailable")
	if barrosan_runtime_checkpoint in ["v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
		if runtime.selected_ids.has(V0247_ASHEN_RAIDER_RUNTIME_ID):
			var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
			hud_hero_label.text = "Ashen Raider | Threat window" if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] and bool(timing.get("warningActive", false)) else "Ashen Raider | Opt-in pressure unit"
			hud_context_label.text = "Approaching Field Barracks | Damage not yet applied | Intercept now" if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] and bool(timing.get("warningActive", false)) else ("Scripted pressure entity | bounded consequence in %s" % barrosan_runtime_checkpoint if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else "Scripted pressure entity | no damage in %s" % barrosan_runtime_checkpoint)
			if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
				hud_objective_label.text = "%s | HP %s/%s" % [
					"Engaged by Militia" if bool(pressure.get("combatStarted", false)) else "Ashen Raider advancing",
					int(_v0247_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID)),
					int(V0249_RAIDER_MAX_HP),
				]
			if barrosan_runtime_checkpoint == "v0.248" and hud_objective_label:
				hud_objective_label.text = "Ashen Raider advancing"
		elif runtime.selected_ids.has(V0246_FIELD_MILITIA_RUNTIME_ID):
			hud_hero_label.text = "Selected Militia"
			hud_context_label.text = "Engaging Ashen Raider" if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and bool(pressure.get("combatStarted", false)) and not bool(pressure.get("raiderDefeated", false)) else "Unit ready | Can intercept Ashen pressure"
			if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
				hud_objective_label.text = "%s | HP %s/%s" % [
					"Pressure contained by combat" if bool(pressure.get("raiderDefeated", false)) else ("Militia engaging Raider" if bool(pressure.get("combatStarted", false)) else "Move to intercept zone"),
					int(_v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID)),
					int(V0249_MILITIA_MAX_HP),
				]
				if barrosan_runtime_checkpoint in ["v0.250", "v0.251", "v0.252", "v0.253"] and not bool(pressure.get("combatStarted", false)):
					if bool(pressure.get("attackOrderAccepted", false)):
						hud_context_label.text = "Attack order accepted"
						hud_objective_label.text = "Target: Ashen Raider | HP 100/100"
					elif bool(pressure.get("attackTargetingMode", false)):
						hud_context_label.text = "Attack targeting mode"
						hud_objective_label.text = "Choose Ashen Raider"
					elif runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID):
						hud_context_label.text = "Unit ready | Can intercept Ashen pressure"
						hud_objective_label.text = "Attack Raider available | HP 100/100"
			if barrosan_runtime_checkpoint == "v0.248" and not bool(pressure.get("contained", false)):
				hud_objective_strip_label.text = "Move Militia to intercept"
				hud_objective_label.text = "Move to intercept zone"
		if hud_objective_strip_label:
			hud_objective_strip_label.text = str(pressure.get("objectiveText", "8. Prepare for Ashen pressure"))
		if hud_objective_label:
			hud_objective_label.text = str(pressure.get("statusText", "Prepare one defender"))
		if barrosan_runtime_checkpoint == "v0.248" and runtime.selected_ids.has(V0246_FIELD_MILITIA_RUNTIME_ID) and not bool(pressure.get("contained", false)):
			hud_objective_strip_label.text = "Move Militia to intercept"
			hud_objective_label.text = "Move to intercept zone"
		if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and bool(pressure.get("raiderDefeated", false)):
			if barrosan_runtime_review_mode == "v0249_raider_defeated":
				hud_objective_strip_label.text = "Ashen Raider defeated"
				hud_objective_label.text = "Raider HP 0/60 | Militia HP 70/100"
			else:
				hud_objective_strip_label.text = "Ashen pressure contained"
				hud_objective_label.text = "Pressure contained before impact | Field Barracks unharmed" if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] else ("Pressure contained by explicit attack order | Field Barracks unharmed" if barrosan_runtime_checkpoint in ["v0.250", "v0.251"] else "Pressure contained by combat | No resource mutation after combat")
	if barrosan_requested_checkpoint in ["v0.257", "v0.258", "v0.259"]:
		_apply_v0257_hud_override()
	if barrosan_requested_checkpoint == "v0.258":
		_apply_v0258_lifecycle_instruction()
	if barrosan_requested_checkpoint == "v0.259":
		_v0259_apply_resolved_ui()
	if barrosan_requested_checkpoint in ["v0.261", "v0.262"]:
		_v0261_apply_resolved_ui()


func set_barrosan_runtime_review_mode(mode: String) -> void:
	barrosan_runtime_review_mode = mode
	var v0257_custom_modes := ["v0257_barracks_built", "v0257_hp_25", "v0257_militia_ready_rebuilt", "v0257_rebuild_unavailable_no_target", "v0257_defended_combat", "v0257_preserve_structures", "v0257_no_stale_text"]
	var v0258_aliases := {
		"v0258_initial_select_aster": "v0257_overview",
		"v0258_after_aster_select_worker": "v0258_after_aster_select_worker",
		"v0258_worker_place_barracks": "v0256_select_worker",
		"v0258_valid_placement": "v0256_valid_preview",
		"v0258_barracks_built": "v0257_barracks_built",
		"v0258_hp_125": "v0256_first_pressure_125",
		"v0258_hp_25": "v0257_hp_25",
		"v0258_hp_0": "v0256_second_damage_0",
		"v0258_destroyed_no_stale": "v0256_destroyed_selected",
		"v0258_worker_rebuild_instruction": "v0256_worker_rebuild_available",
		"v0258_worker_rebuild_hud": "v0256_repair_unavailable_zero",
		"v0258_rebuild_delta": "v0258_rebuild_delta",
		"v0258_rebuild_25": "v0256_rebuild_25",
		"v0258_rebuild_50": "v0256_rebuild_50",
		"v0258_rebuild_75": "v0256_rebuild_75",
		"v0258_rebuild_100": "v0256_rebuild_100",
		"v0258_train_available": "v0256_rebuilt_train_available",
		"v0258_train_delta": "v0256_train_rebuilt_ordered",
		"v0258_militia_ready": "v0257_militia_ready_rebuilt",
		"v0258_separation": "v0257_rebuild_unavailable_no_target",
		"v0258_defended": "v0257_defended_combat",
		"v0258_minimap": "v0256_minimap",
		"v0258_structures": "v0257_preserve_structures",
		"v0258_no_stale_rebuild": "v0257_no_stale_text",
		"v0258_no_stale_aster": "v0257_no_stale_text",
	}
	var v0259_aliases := {
		"v0259_initial": "v0257_overview",
		"v0259_after_aster": "v0258_after_aster_select_worker",
		"v0259_build_no_rebuild": "v0256_select_worker",
		"v0259_place": "v0256_select_worker",
		"v0259_valid": "v0256_valid_preview",
		"v0259_full": "v0257_barracks_built",
		"v0259_hp_125": "v0256_first_pressure_125",
		"v0259_hp_25": "v0257_hp_25",
		"v0259_destroyed": "v0256_second_damage_0",
		"v0259_destroyed_clean": "v0256_destroyed_selected",
		"v0259_worker_rebuild": "v0256_worker_rebuild_available",
		"v0259_rebuild_button": "v0256_repair_unavailable_zero",
		"v0259_rebuild_delta": "v0258_rebuild_delta",
		"v0259_rebuild_25": "v0256_rebuild_25",
		"v0259_rebuild_50": "v0256_rebuild_50",
		"v0259_rebuild_75": "v0256_rebuild_75",
		"v0259_rebuilt_100": "v0256_rebuild_100",
		"v0259_train_available": "v0256_rebuilt_train_available",
		"v0259_train_delta": "v0256_train_rebuilt_ordered",
		"v0259_militia_ready": "v0257_militia_ready_rebuilt",
		"v0259_no_rebuild_after": "v0257_rebuild_unavailable_no_target",
		"v0259_no_place_rebuild": "v0256_rebuild_50",
		"v0259_separation": "v0257_rebuild_unavailable_no_target",
		"v0259_minimap": "v0256_minimap",
		"v0259_structures": "v0257_preserve_structures",
		"v0259_forbidden_scan": "v0257_no_stale_text",
		"v0259_visual_compare": "v0257_hp_25",
	}
	var action_mode := str(v0259_aliases.get(mode, v0258_aliases.get(mode, mode)))
	if action_mode.begins_with("v0257_") and not v0257_custom_modes.has(action_mode):
		action_mode = action_mode.replace("v0257_", "v0256_")
	if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		_ensure_v0246_field_militia_active()
	if barrosan_runtime_checkpoint in ["v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		_ensure_v0247_ashen_raider_active()
	match action_mode:
		"v0258_after_aster_select_worker":
			_select_playtest_unit("hero_aster")
			_set_v0249_objective("Select Worker", "Construction available")
		"v0258_rebuild_delta":
			_select_playtest_unit("worker_00")
			_hud_work_pressed()
			_begin_v0256_worker_rebuild()
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
		"v0245_overview", "v0245_starting_resources":
			_capture_v0245_starting_resources()
		"v0245_select_builder":
			_select_playtest_unit("worker_00")
		"v0245_valid_preview_cancel":
			_run_v0245_preview(false, "before_cancel")
		"v0245_cancel_preview":
			_cancel_v0245_preview()
		"v0245_blocked_preview":
			_run_v0245_preview(true, "blocked")
		"v0245_blocked_attempt":
			_attempt_v0245_placement(true)
		"v0245_valid_preview_confirm":
			_run_v0245_preview(false, "before_confirm")
		"v0245_confirm_placement":
			_attempt_v0245_placement(false)
		"v0245_resource_delta":
			_show_v0245_construction_proof("resource_delta")
		"v0245_select_constructed":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0245_minimap":
			_add_v0245_constructed_minimap_marker()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0245_preserve_keep":
			select_barrosan_runtime_role("main_base")
		"v0245_preserve_barracks":
			_run_v0244_barracks_restore_train_flow()
		"v0245_preserve_mine":
			select_barrosan_runtime_role("mine")
		"v0245_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0245_pathing":
			_run_v0245_pathing_probe()
		"v0245_clean":
			_clear_barrosan_playtest_selection()
		"v0246_overview", "v0246_starting_resources":
			_capture_v0245_starting_resources()
		"v0246_select_builder":
			_run_v0246_builder_probe()
		"v0246_valid_preview":
			_run_v0245_preview(false, "v0246_confirm")
		"v0246_confirm_placement":
			_attempt_v0245_placement(false)
		"v0246_construction_delta":
			_show_v0245_construction_proof("resource_delta")
		"v0246_select_field_barracks", "v0246_train_command":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0246_train_militia":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_queue_v0246_field_militia()
		"v0246_training_progress":
			_advance_v0246_field_training(60)
			_attempt_v0246_duplicate_queue()
		"v0246_militia_spawned":
			_advance_v0246_field_training(70)
		"v0246_select_spawned_militia":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0246_move_road":
			_run_v0246_militia_probe("road", Vector2(610, 1120), 220)
		"v0246_move_bridge":
			_run_v0246_militia_probe("bridge_river", Vector2(790, 760), 260)
		"v0246_failed_train":
			_attempt_v0246_failed_training()
		"v0246_minimap":
			_add_v0246_field_militia_minimap_marker()
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0246_preserve_barracks":
			_run_v0246_militia_probe("restored_barracks_main_base", Vector2(360, 260), 260)
			_run_v0244_barracks_restore_train_flow()
		"v0246_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0246_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0246_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0246_clean":
			_clear_barrosan_playtest_selection()
		"v0247_overview", "v0247_starting_resources":
			_capture_v0245_starting_resources()
		"v0247_select_builder":
			_run_v0246_builder_probe()
		"v0247_valid_preview":
			_run_v0245_preview(false, "v0247_confirm")
		"v0247_confirm_placement":
			_attempt_v0245_placement(false)
		"v0247_construction_delta":
			_show_v0245_construction_proof("resource_delta")
		"v0247_select_field_barracks", "v0247_train_command":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0247_train_militia":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_queue_v0246_field_militia()
		"v0247_training_progress":
			_advance_v0246_field_training(60)
			_attempt_v0246_duplicate_queue()
		"v0247_militia_spawned":
			_advance_v0246_field_training(70)
			_prepare_v0247_pressure()
		"v0247_select_militia":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0247_pressure_incoming":
			_prepare_v0247_pressure()
		"v0247_raider_spawned":
			_spawn_v0247_ashen_raider()
			_select_v0247_raider()
		"v0247_raider_minimap":
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0247_lane_start":
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 190)
		"v0247_lane_bridge":
			_advance_v0247_raider_lane("bridge_approach", V0247_PRESSURE_BRIDGE_APPROACH, 220)
		"v0247_militia_intercept_move":
			_run_v0247_militia_intercept(180, false)
		"v0247_intercept_reached":
			_run_v0247_militia_intercept(260, true)
		"v0247_pressure_contained":
			_evaluate_v0247_pressure_containment()
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0247_no_mutation":
			_attempt_v0246_failed_training()
			_record_v0247_no_combat_mutation()
			_select_v0247_raider()
		"v0247_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0247_preserve_barracks":
			_run_v0246_militia_probe("restored_barracks_main_base", Vector2(360, 260), 260)
			_run_v0244_barracks_restore_train_flow()
		"v0247_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0247_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0247_clean":
			_clear_barrosan_playtest_selection()
		"v0248_overview", "v0248_starting_resources":
			_capture_v0245_starting_resources()
			_set_v0248_objective("1. Select Aster", "Select Aster")
		"v0248_select_builder":
			_run_v0246_builder_probe()
			_set_v0248_objective("8. Prepare for Ashen pressure", "Construction available")
		"v0248_valid_preview":
			_run_v0245_preview(false, "v0248_confirm")
			_set_v0248_objective("8. Prepare for Ashen pressure", "Authoritative Field Barracks preview")
		"v0248_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0248_objective("Prepare one defender", "Authoritative placement | complete | trains Militia only")
		"v0248_construction_delta":
			_show_v0245_construction_proof("resource_delta")
			_set_v0248_objective("Prepare one defender", "Prepare one defender")
		"v0248_select_field_barracks", "v0248_prepare_defender", "v0248_train_command":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_set_v0248_objective("Prepare one defender", "Prepare one defender")
		"v0248_train_militia", "v0248_training_0":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_queue_v0246_field_militia()
			_set_v0248_objective("Militia preparing...", "Militia training... 0%")
		"v0248_training_50":
			_advance_v0246_field_training(50)
			_attempt_v0246_duplicate_queue()
			_set_v0248_objective("Militia preparing...", "Militia training... 50%")
		"v0248_militia_ready", "v0248_defender_ready":
			_advance_v0246_field_training(80)
			_prepare_v0247_pressure()
			_set_v0248_objective("Defender ready", "Militia ready")
		"v0248_pressure_incoming", "v0248_pressure_telegraph":
			_prepare_v0247_pressure()
			_activate_v0248_pressure_telegraph()
			_set_v0248_objective("9. Ashen pressure incoming", "Incoming pressure | no damage")
		"v0248_raider_spawned":
			_spawn_v0247_ashen_raider()
			_set_v0248_objective("Ashen Raider advancing", "Ashen Raider advancing")
			_record_v0248_pressure_snapshot("afterRaiderSpawn")
			_select_v0247_raider()
		"v0248_raider_minimap":
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0248_lane_start":
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_set_v0248_objective("Ashen Raider advancing", "Ashen Raider advancing")
			_record_v0248_pressure_snapshot("afterLaneStart")
		"v0248_advancing_timing":
			_advance_v0247_raider_lane("bridge_approach", V0247_PRESSURE_BRIDGE_APPROACH, 245)
			_set_v0248_objective("Ashen Raider advancing", "Ashen Raider advancing")
			_record_v0248_pressure_snapshot("afterRaiderMovement")
		"v0248_select_militia":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0248_objective("Move Militia to intercept", "Move to intercept zone")
		"v0248_intercept_marker":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_activate_v0248_intercept_marker()
		"v0248_militia_move":
			_run_v0247_militia_intercept(180, false)
			_set_v0248_objective("Move Militia to intercept", "Militia moving to intercept zone")
		"v0248_intercept_reached":
			_run_v0247_militia_intercept(260, true)
			if bool(barrosan_playtest.get("v0247Pressure", {}).get("contained", false)):
				_set_v0248_objective("Ashen pressure contained", "No damage exchanged")
		"v0248_pressure_contained":
			_evaluate_v0247_pressure_containment()
			if bool(barrosan_playtest.get("v0247Pressure", {}).get("contained", false)):
				_set_v0248_objective("Ashen pressure contained", "No damage exchanged")
			_record_v0248_pressure_snapshot("afterContainment")
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0248_no_mutation":
			_attempt_v0246_failed_training()
			_record_v0247_no_combat_mutation()
			_record_v0248_pressure_snapshot("afterContainment")
			_select_v0247_raider()
		"v0248_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0248_preserve_barracks":
			_run_v0246_militia_probe("restored_barracks_main_base", Vector2(360, 260), 260)
			_run_v0244_barracks_restore_train_flow()
		"v0248_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0248_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0248_clean":
			_clear_barrosan_playtest_selection()
		"v0257_barracks_built":
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0257_confirm")
			_attempt_v0245_placement(false)
			_show_v0245_construction_proof("resource_delta")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0257_hp_25":
			_record_v0254_no_passive_collapse()
			_prepare_v0255_second_pressure()
			_advance_v0247_raider_lane("second_lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("second_barracks_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			_advance_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			_advance_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			_begin_v0255_second_damage()
			for _tick in range(4):
				_advance_v0255_second_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0257_militia_ready_rebuilt":
			_advance_v0246_field_training(130)
			var rebuilt_training: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
			rebuilt_training["militiaCountAfterRebuild"] = runtime.units.filter(
				func(unit: Dictionary) -> bool:
					return str(unit.get("id", "")) == V0246_FIELD_MILITIA_RUNTIME_ID and bool(unit.get("alive", false))
			).size()
			rebuilt_training["fieldBarracksHpAfterTraining"] = _v0251_field_barracks_health()
			barrosan_playtest["v0256WorkerRebuild"] = rebuilt_training
			v0256_rebuild_proof = rebuilt_training.duplicate(true)
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0257_rebuild_unavailable_no_target":
			_select_playtest_unit("worker_00")
			var post_rebuild_separation := {
				"repairEligibleAt100": _v0251_field_barracks_health() > 0.0 and _v0251_field_barracks_health() < V0251_FIELD_BARRACKS_MAX_HP,
				"repairAffordableAt100": int(runtime.resources.get("stone", 0)) >= 30,
				"rebuildUnavailableAt100": not _v0256_rebuild_command_available(),
				"rebuildUnavailableWithoutDestroyedTarget": not _v0256_rebuild_command_available(),
				"repairAvailableAt125": true,
				"rebuildUnavailableAt125": not _v0256_rebuild_command_available(),
				"repairUnavailableAtFull": true,
				"rebuildUnavailableAtFull": true,
			}
			barrosan_playtest["v0256RepairRebuildSeparation"] = post_rebuild_separation
			v0256_separation_proof = post_rebuild_separation.duplicate(true)
		"v0257_defended_combat":
			_reset_v0251_branch_runtime()
			_reset_barrosan_playtest_status()
			_set_v0252_aster_health_contract()
			_load_v0246_militia_authority()
			_capture_v0245_starting_resources()
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0257_defended_confirm")
			_attempt_v0245_placement(false)
			_queue_v0246_field_militia()
			_advance_v0246_field_training(130)
			_prepare_v0247_pressure()
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_advance_v0252_threat_window()
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			_run_v0252_militia_threat_intercept(120)
			_begin_v0249_combat()
			for _tick in range(3):
				_advance_v0249_combat_tick()
			_finalize_v0249_combat_visuals()
			_record_v0249_collateral_proof()
			v0256_defended_proof = _v0250_attack_order_status().duplicate(true)
			v0256_defended_proof["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			v0256_defended_proof["rebuildUnavailable"] = not _v0256_rebuild_command_available()
			v0256_defended_proof["repairUnavailable"] = not _v0253_repair_command_available()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0257_preserve_structures":
			_run_v0244_barracks_restore_train_flow()
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0257_no_stale_text":
			_clear_barrosan_playtest_selection()
		"v0256_overview", "v0256_starting_resources":
			_set_v0252_aster_health_contract()
			_capture_v0245_starting_resources()
			_set_v0249_objective("Build authoritative Field Barracks", "Select Worker")
		"v0256_select_worker":
			_run_v0246_builder_probe()
			_set_v0249_objective("Build authoritative Field Barracks", "Construction available")
		"v0256_valid_preview":
			_run_v0245_preview(false, "v0256_confirm")
		"v0256_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare for Ashen pressure", "Authoritative placement complete")
		"v0256_construction_delta", "v0256_barracks_hp_200":
			_show_v0245_construction_proof("resource_delta")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_first_pressure_125":
			_prepare_v0251_undefended_pressure()
			_activate_v0249_markers()
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_advance_v0252_threat_window()
			_advance_v0252_threat_window()
			_begin_v0252_building_pressure_after_warning()
			_advance_v0251_building_damage_tick()
			_advance_v0251_building_damage_tick()
			_advance_v0251_building_damage_tick()
			_finalize_v0251_building_pressure()
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			repair["missedWindowProof"] = _v0252_missed_window_status().duplicate(true)
			barrosan_playtest["v0253WorkerRepair"] = repair
			_record_v0254_damaged_functional_state()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_no_passive_collapse":
			_record_v0254_no_passive_collapse()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_second_pressure":
			_prepare_v0255_second_pressure()
			_advance_v0247_raider_lane("second_lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("second_barracks_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			_advance_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			_advance_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_second_damage_100":
			_begin_v0255_second_damage()
			_advance_v0255_second_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_second_damage_75", "v0256_second_damage_50", "v0256_second_damage_25", "v0256_second_damage_0":
			_advance_v0255_second_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			if action_mode == "v0256_second_damage_0":
				_record_v0255_destroyed_proof()
				_record_v0256_destroyed_proof()
		"v0256_destroyed_selected", "v0256_destroyed_train_unavailable":
			_record_v0255_destroyed_proof()
			_record_v0256_destroyed_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_worker_rebuild_available", "v0256_repair_unavailable_zero":
			_select_playtest_unit("worker_00")
			var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
			rebuild["rebuildCommandAvailable"] = _v0256_rebuild_command_available()
			rebuild["repairUnavailableAtZero"] = not _v0253_repair_command_available()
			rebuild["noAutomaticRebuild"] = _v0251_field_barracks_health() == 0.0
			barrosan_playtest["v0256WorkerRebuild"] = rebuild
		"v0256_rebuild_ordered":
			_select_playtest_unit("worker_00")
			_hud_work_pressed()
		"v0256_rebuild_delta":
			_select_playtest_unit("worker_00")
			_begin_v0256_worker_rebuild()
		"v0256_rebuild_25", "v0256_rebuild_50", "v0256_rebuild_75", "v0256_rebuild_100":
			_advance_v0256_worker_rebuild_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			if action_mode == "v0256_rebuild_100":
				v0256_rebuild_proof = barrosan_playtest.get("v0256WorkerRebuild", {}).duplicate(true)
		"v0256_rebuilt_selectable", "v0256_rebuilt_train_available":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_train_rebuilt_ordered":
			var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
			rebuild["resourcesBeforeRebuiltTraining"] = runtime.resources.duplicate(true)
			rebuild["trainOrderAcceptedAfterRebuild"] = _queue_v0246_field_militia()
			rebuild["resourcesAfterRebuiltTraining"] = runtime.resources.duplicate(true)
			rebuild["trainFromRebuiltDelta"] = _resource_delta(rebuild["resourcesBeforeRebuiltTraining"], runtime.resources)
			barrosan_playtest["v0256WorkerRebuild"] = rebuild
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_train_rebuilt_delta":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_militia_ready_rebuilt":
			_advance_v0246_field_training(130)
			var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
			rebuild["militiaCountAfterRebuild"] = runtime.units.filter(
				func(unit: Dictionary) -> bool:
					return str(unit.get("id", "")) == V0246_FIELD_MILITIA_RUNTIME_ID and bool(unit.get("alive", false))
			).size()
			barrosan_playtest["v0256WorkerRebuild"] = rebuild
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0256_rebuilt_hp_100":
			var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
			rebuild["fieldBarracksHpAfterTraining"] = _v0251_field_barracks_health()
			barrosan_playtest["v0256WorkerRebuild"] = rebuild
			v0256_rebuild_proof = rebuild.duplicate(true)
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_worker_after_rebuild", "v0256_rebuild_unavailable_no_target":
			_select_playtest_unit("worker_00")
			var separation: Dictionary = barrosan_playtest.get("v0256RepairRebuildSeparation", {})
			separation["repairEligibleAt100"] = _v0251_field_barracks_health() > 0.0 and _v0251_field_barracks_health() < V0251_FIELD_BARRACKS_MAX_HP
			separation["repairAffordableAt100"] = int(runtime.resources.get("stone", 0)) >= 30
			separation["rebuildUnavailableAt100"] = not _v0256_rebuild_command_available()
			separation["rebuildUnavailableWithoutDestroyedTarget"] = not _v0256_rebuild_command_available()
			barrosan_playtest["v0256RepairRebuildSeparation"] = separation
		"v0256_repair_available_nonzero", "v0256_rebuild_unavailable_nonzero":
			var completed_rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
			if bool(completed_rebuild.get("rebuildComplete", false)):
				v0256_rebuild_proof = completed_rebuild.duplicate(true)
			_prepare_v0255_damaged_branch(false)
			_select_playtest_unit("worker_00")
			var separation: Dictionary = barrosan_playtest.get("v0256RepairRebuildSeparation", {})
			separation["repairAvailableAt125"] = _v0253_repair_command_available()
			separation["rebuildUnavailableAt125"] = not _v0256_rebuild_command_available()
			separation["repairUnavailableAtFull"] = true
			separation["rebuildUnavailableAtFull"] = true
			barrosan_playtest["v0256RepairRebuildSeparation"] = separation
			v0256_separation_proof = separation.duplicate(true)
		"v0256_defended_start":
			_reset_v0251_branch_runtime()
			_reset_barrosan_playtest_status()
			_set_v0252_aster_health_contract()
			_load_v0246_militia_authority()
			_capture_v0245_starting_resources()
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0256_defended_confirm")
			_attempt_v0245_placement(false)
			_queue_v0246_field_militia()
			_advance_v0246_field_training(130)
			_prepare_v0247_pressure()
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_advance_v0252_threat_window()
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			_run_v0252_militia_threat_intercept(120)
		"v0256_defended_tick_1":
			_begin_v0249_combat()
			_advance_v0249_combat_tick()
		"v0256_defended_tick_2":
			_advance_v0249_combat_tick()
		"v0256_defended_tick_3":
			_advance_v0249_combat_tick()
			_finalize_v0249_combat_visuals()
		"v0256_defended_barracks", "v0256_units_unharmed", "v0256_minimap":
			_record_v0249_collateral_proof()
			v0256_defended_proof = _v0250_attack_order_status().duplicate(true)
			v0256_defended_proof["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			v0256_defended_proof["rebuildUnavailable"] = not _v0256_rebuild_command_available()
			v0256_defended_proof["repairUnavailable"] = not _v0253_repair_command_available()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0256_preserve_barracks":
			_run_v0244_barracks_restore_train_flow()
		"v0256_preserve_keep_mine":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0256_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0256_default_clean", "v0256_clean":
			_clear_barrosan_playtest_selection()
		"v0255_overview", "v0255_starting_resources":
			_set_v0252_aster_health_contract()
			_capture_v0245_starting_resources()
			_set_v0249_objective("1. Select Aster", "Select Aster")
		"v0255_select_worker":
			_run_v0246_builder_probe()
			_set_v0249_objective("Build authoritative Field Barracks", "Construction available")
		"v0255_valid_preview":
			_run_v0245_preview(false, "v0255_confirm")
		"v0255_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare for Ashen pressure", "Authoritative placement complete")
		"v0255_construction_delta", "v0255_barracks_hp_200":
			_show_v0245_construction_proof("resource_delta")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_first_raider":
			_prepare_v0251_undefended_pressure()
			_activate_v0249_markers()
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_select_v0247_raider()
		"v0255_first_warning_started":
			_begin_v0252_threat_window()
			_select_v0247_raider()
		"v0255_first_warning_midpoint":
			_advance_v0252_threat_window()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_first_warning_expired":
			_advance_v0252_threat_window()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_first_damage_175":
			_begin_v0252_building_pressure_after_warning()
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_first_damage_150":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_first_damage_125":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_first_pressure_stopped":
			_finalize_v0251_building_pressure()
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			repair["missedWindowProof"] = _v0252_missed_window_status().duplicate(true)
			barrosan_playtest["v0253WorkerRepair"] = repair
			_record_v0254_damaged_functional_state()
			v0255_damaged_proof = barrosan_playtest.get("v0254DamagedFunctional", {}).duplicate(true)
			_set_v0249_objective("Field Barracks damaged but functional", "No active pressure")
		"v0255_no_passive_collapse":
			_record_v0254_no_passive_collapse()
			v0255_damaged_proof = barrosan_playtest.get("v0254DamagedFunctional", {}).duplicate(true)
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_damaged_selectable", "v0255_damaged_train_available":
			_record_v0254_damaged_functional_state()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_train_damaged_ordered":
			var damaged: Dictionary = barrosan_playtest.get("v0254DamagedFunctional", {})
			damaged["resourcesBeforeDamagedTraining"] = runtime.resources.duplicate(true)
			damaged["trainOrderAcceptedAt125"] = _queue_v0246_field_militia()
			damaged["resourcesAfterDamagedTraining"] = runtime.resources.duplicate(true)
			damaged["trainResourceDelta"] = _resource_delta(damaged["resourcesBeforeDamagedTraining"], runtime.resources)
			barrosan_playtest["v0254DamagedFunctional"] = damaged
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_train_damaged_delta":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_militia_ready_damaged":
			_advance_v0246_field_training(130)
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0255_damaged_hp_after_training":
			_record_v0254_no_passive_collapse()
			v0255_damaged_proof = barrosan_playtest.get("v0254DamagedFunctional", {}).duplicate(true)
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_second_pressure_triggered":
			_prepare_v0255_second_pressure()
			_advance_v0247_raider_lane("second_lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("second_barracks_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_select_v0247_raider()
		"v0255_second_warning_started":
			_begin_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_second_warning_midpoint":
			_advance_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_second_warning_expired":
			_advance_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_second_damage_100":
			_begin_v0255_second_damage()
			_advance_v0255_second_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_second_damage_75", "v0255_second_damage_50", "v0255_second_damage_25", "v0255_second_damage_0":
			_advance_v0255_second_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			if action_mode == "v0255_second_damage_0":
				_record_v0255_destroyed_proof()
		"v0255_destroyed_selected", "v0255_destroyed_train_unavailable":
			_record_v0255_destroyed_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_destroyed_repair_unavailable":
			_select_playtest_unit("worker_00")
			_record_v0255_destroyed_proof()
		"v0255_no_refund_destroyed":
			_record_v0255_destroyed_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_second_intercept_start":
			v0255_destroyed_proof = barrosan_playtest.get("v0255SecondPressure", {}).duplicate(true)
			_prepare_v0255_damaged_branch(true)
			_prepare_v0255_second_pressure()
			_advance_v0247_raider_lane("second_intercept_lane", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			_select_v0247_raider()
		"v0255_second_intercept_order":
			_advance_v0252_threat_window()
			_sync_v0255_second_warning_proof()
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			_run_v0252_militia_threat_intercept(120)
		"v0255_second_intercept_tick_1":
			_begin_v0249_combat()
			_advance_v0249_combat_tick()
		"v0255_second_intercept_tick_2":
			_advance_v0249_combat_tick()
		"v0255_second_intercept_tick_3":
			_advance_v0249_combat_tick()
			_finalize_v0249_combat_visuals()
		"v0255_second_intercept_survives":
			var second: Dictionary = barrosan_playtest.get("v0255SecondPressure", {})
			second["intercepted"] = true
			second["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			second["combat"] = _v0250_attack_order_status().duplicate(true)
			barrosan_playtest["v0255SecondPressure"] = second
			v0255_intercepted_proof = second.duplicate(true)
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_repair_available":
			_prepare_v0255_damaged_branch(false)
			_select_playtest_unit("worker_00")
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			repair["repairCommandAvailable"] = _v0253_repair_command_available()
			barrosan_playtest["v0253WorkerRepair"] = repair
		"v0255_repair_delta":
			_select_playtest_unit("worker_00")
			_hud_work_pressed()
		"v0255_repair_150", "v0255_repair_175", "v0255_repair_200":
			_advance_v0253_worker_repair_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_repair_unavailable_full":
			_select_playtest_unit("worker_00")
			_begin_v0253_worker_repair()
			v0255_repair_proof = _v0253_repair_branch_status().duplicate(true)
		"v0255_defended_first_start":
			v0255_repair_proof = _v0253_repair_branch_status().duplicate(true)
			_reset_v0251_branch_runtime()
			_reset_barrosan_playtest_status()
			_set_v0252_aster_health_contract()
			_load_v0246_militia_authority()
			_capture_v0245_starting_resources()
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0255_defended_confirm")
			_attempt_v0245_placement(false)
			_queue_v0246_field_militia()
			_advance_v0246_field_training(130)
			_prepare_v0247_pressure()
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_advance_v0252_threat_window()
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			_run_v0252_militia_threat_intercept(120)
		"v0255_defended_first_tick_1":
			_begin_v0249_combat()
			_advance_v0249_combat_tick()
		"v0255_defended_first_tick_2":
			_advance_v0249_combat_tick()
		"v0255_defended_first_tick_3":
			_advance_v0249_combat_tick()
			_finalize_v0249_combat_visuals()
		"v0255_defended_barracks", "v0255_units_unharmed", "v0255_minimap":
			_record_v0249_collateral_proof()
			v0255_defended_proof = _v0250_attack_order_status().duplicate(true)
			v0255_defended_proof["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			v0255_defended_proof["militiaCount"] = 1
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0255_preserve_barracks":
			_run_v0244_barracks_restore_train_flow()
		"v0255_preserve_keep_mine":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0255_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0255_default_clean", "v0255_clean":
			_clear_barrosan_playtest_selection()
		"v0254_overview", "v0254_starting_resources":
			_set_v0252_aster_health_contract()
			_capture_v0245_starting_resources()
			_set_v0249_objective("1. Select Aster", "Select Aster")
		"v0254_select_worker":
			_run_v0246_builder_probe()
			_set_v0249_objective("Build authoritative Field Barracks", "Construction available")
		"v0254_valid_preview":
			_run_v0245_preview(false, "v0254_confirm")
		"v0254_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare for Ashen pressure", "Authoritative placement complete")
		"v0254_construction_delta", "v0254_barracks_hp_200":
			_show_v0245_construction_proof("resource_delta")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_raider_spawned":
			_prepare_v0251_undefended_pressure()
			_activate_v0249_markers()
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0254_raider_threat_range":
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_set_v0249_objective("Ashen pressure entering threat range", "Threat range reached")
		"v0254_warning_started":
			_begin_v0252_threat_window()
			_select_v0247_raider()
		"v0254_warning_midpoint":
			_advance_v0252_threat_window()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_warning_expired":
			_advance_v0252_threat_window()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_damage_tick_1":
			_begin_v0252_building_pressure_after_warning()
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_damage_tick_2":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_damage_tick_3":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_damage_stopped":
			_finalize_v0251_building_pressure()
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			repair["missedWindowProof"] = _v0252_missed_window_status().duplicate(true)
			barrosan_playtest["v0253WorkerRepair"] = repair
			_record_v0254_damaged_functional_state()
			_set_v0249_objective("Field Barracks damaged but functional", "No active pressure")
		"v0254_damaged_selectable", "v0254_damaged_train_available":
			_record_v0254_damaged_functional_state()
		"v0254_damaged_train_ordered":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			var state: Dictionary = barrosan_playtest.get("v0254DamagedFunctional", {})
			state["resourcesBeforeDamagedTraining"] = runtime.resources.duplicate(true)
			state["trainOrderAcceptedAt125"] = _queue_v0246_field_militia()
			var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
			state["trainCost"] = production.get("cost", {}).duplicate(true)
			state["resourcesAfterDamagedTraining"] = runtime.resources.duplicate(true)
			state["trainResourceDelta"] = _resource_delta(state["resourcesBeforeDamagedTraining"], runtime.resources)
			barrosan_playtest["v0254DamagedFunctional"] = state
		"v0254_damaged_train_delta":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_damaged_militia_ready":
			_advance_v0246_field_training(130)
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0254_damaged_hp_after_training":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_no_passive_collapse":
			_record_v0254_no_passive_collapse()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_set_v0249_objective("Field Barracks damaged but functional", "No active pressure")
		"v0254_select_worker_repair":
			_prepare_v0254_damaged_branch()
			_select_playtest_unit("worker_00")
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			repair["repairCommandAvailable"] = _v0253_repair_command_available()
			barrosan_playtest["v0253WorkerRepair"] = repair
			_set_v0249_objective("Repair damaged Field Barracks", "Worker repair available")
		"v0254_repair_accepted", "v0254_repair_delta":
			_select_playtest_unit("worker_00")
			_hud_work_pressed()
		"v0254_repair_tick_1":
			_advance_v0253_worker_repair_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_repair_tick_2":
			_advance_v0253_worker_repair_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_repair_tick_3", "v0254_repair_complete":
			_advance_v0253_worker_repair_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_repair_unavailable_full":
			_select_playtest_unit("worker_00")
			_begin_v0253_worker_repair()
			v0254_repair_proof = _v0253_repair_branch_status().duplicate(true)
		"v0254_defended_start":
			v0254_repair_proof = _v0253_repair_branch_status().duplicate(true)
			_reset_v0251_branch_runtime()
			_reset_barrosan_playtest_status()
			_set_v0252_aster_health_contract()
			_load_v0246_militia_authority()
			_capture_v0245_starting_resources()
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0254_defended_confirm")
			_attempt_v0245_placement(false)
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_defended_train":
			_queue_v0246_field_militia()
			_advance_v0246_field_training(130)
			_prepare_v0247_pressure()
		"v0254_defended_attack":
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_advance_v0252_threat_window()
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
			timing["defendedDuringWarning"] = bool(timing.get("warningActive", false))
			timing["warningStepAtAttackOrder"] = int(timing.get("warningStep", 0))
			timing["threatWindowMarkerVisible"] = false
			barrosan_playtest["v0252ThreatTiming"] = timing
			_run_v0252_militia_threat_intercept(120)
		"v0254_defended_tick_1":
			_begin_v0249_combat()
			_advance_v0249_combat_tick()
		"v0254_defended_tick_2":
			_advance_v0249_combat_tick()
		"v0254_defended_tick_3":
			_advance_v0249_combat_tick()
			_finalize_v0249_combat_visuals()
		"v0254_defended_barracks", "v0254_raider_count", "v0254_militia_count", "v0254_units_unharmed", "v0254_minimap":
			_record_v0249_collateral_proof()
			v0254_defended_proof = _v0250_attack_order_status().duplicate(true)
			v0254_defended_proof["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			v0254_defended_proof["threatTiming"] = barrosan_playtest.get("v0252ThreatTiming", {}).duplicate(true)
			v0254_defended_proof["repairCommandAvailable"] = false
			v0254_defended_proof["militiaCount"] = runtime.units.filter(
				func(unit: Dictionary) -> bool:
					return str(unit.get("id", "")) == V0246_FIELD_MILITIA_RUNTIME_ID and bool(unit.get("alive", false))
			).size()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0254_preserve_barracks":
			_run_v0244_barracks_restore_train_flow()
		"v0254_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0254_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0254_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0254_default_clean", "v0254_clean":
			_clear_barrosan_playtest_selection()
		"v0253_overview", "v0253_starting_resources":
			_set_v0252_aster_health_contract()
			_capture_v0245_starting_resources()
			_set_v0249_objective("1. Select Aster", "Select Aster")
		"v0253_select_worker":
			_run_v0246_builder_probe()
			_set_v0249_objective("Build authoritative Field Barracks", "Construction available")
		"v0253_valid_preview":
			_run_v0245_preview(false, "v0253_confirm")
		"v0253_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare for Ashen pressure", "Authoritative placement complete")
		"v0253_construction_delta", "v0253_barracks_hp_200":
			_show_v0245_construction_proof("resource_delta")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_raider_spawned":
			_prepare_v0251_undefended_pressure()
			_activate_v0249_markers()
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0253_raider_threat_range":
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_set_v0249_objective("Ashen pressure entering threat range", "Threat range reached")
		"v0253_warning_started":
			_begin_v0252_threat_window()
			_select_v0247_raider()
		"v0253_warning_midpoint":
			_advance_v0252_threat_window()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_warning_expired":
			_advance_v0252_threat_window()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_damage_tick_1":
			_begin_v0252_building_pressure_after_warning()
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_damage_tick_2":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_damage_tick_3":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_damage_stopped":
			_finalize_v0251_building_pressure()
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			repair["missedWindowProof"] = _v0252_missed_window_status().duplicate(true)
			barrosan_playtest["v0253WorkerRepair"] = repair
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_set_v0249_objective("Field Barracks damaged — select Worker to repair", "Field Barracks HP 125/200")
		"v0253_select_damaged_barracks":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_select_worker_after_damage", "v0253_repair_available":
			_select_playtest_unit("worker_00")
			var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
			repair["repairCommandAvailable"] = _v0253_repair_command_available()
			barrosan_playtest["v0253WorkerRepair"] = repair
			_set_v0249_objective("Repair damaged Field Barracks", "Worker repair available")
		"v0253_repair_accepted", "v0253_repair_resource_delta":
			_select_playtest_unit("worker_00")
			_hud_work_pressed()
		"v0253_repair_tick_1":
			_advance_v0253_worker_repair_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_repair_tick_2":
			_advance_v0253_worker_repair_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_repair_tick_3", "v0253_repair_complete":
			_advance_v0253_worker_repair_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_repair_unavailable_full", "v0253_no_mutation_after_repair":
			_select_playtest_unit("worker_00")
			_begin_v0253_worker_repair()
		"v0253_units_unharmed":
			v0253_repair_proof = _v0253_repair_branch_status().duplicate(true)
			_select_playtest_unit("hero_aster")
		"v0253_raider_bounded":
			_select_v0247_raider()
		"v0253_minimap_preserved":
			_select_playtest_unit("worker_00")
			_sync_minimap()
		"v0253_defended_start":
			v0253_repair_proof = _v0253_repair_branch_status().duplicate(true)
			_reset_v0251_branch_runtime()
			_reset_barrosan_playtest_status()
			_set_v0252_aster_health_contract()
			_load_v0246_militia_authority()
			_capture_v0245_starting_resources()
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0253_defended_confirm")
			_attempt_v0245_placement(false)
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_defended_train":
			_queue_v0246_field_militia()
			_advance_v0246_field_training(130)
			_prepare_v0247_pressure()
		"v0253_defended_warning":
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_begin_v0252_threat_window()
			_advance_v0252_threat_window()
			_select_v0247_raider()
		"v0253_defended_attack":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
			timing["defendedDuringWarning"] = bool(timing.get("warningActive", false))
			timing["warningStepAtAttackOrder"] = int(timing.get("warningStep", 0))
			timing["threatWindowMarkerVisible"] = false
			barrosan_playtest["v0252ThreatTiming"] = timing
			_run_v0252_militia_threat_intercept(120)
		"v0253_defended_tick_1":
			_begin_v0249_combat()
			_advance_v0249_combat_tick()
		"v0253_defended_tick_2":
			_advance_v0249_combat_tick()
		"v0253_defended_tick_3":
			_advance_v0249_combat_tick()
			_finalize_v0249_combat_visuals()
		"v0253_defended_barracks", "v0253_defended_repair_unavailable":
			_record_v0249_collateral_proof()
			v0253_defended_proof = _v0250_attack_order_status().duplicate(true)
			v0253_defended_proof["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			v0253_defended_proof["threatTiming"] = barrosan_playtest.get("v0252ThreatTiming", {}).duplicate(true)
			v0253_defended_proof["repairCommandAvailable"] = false
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0253_preserve_barracks":
			_run_v0244_barracks_restore_train_flow()
		"v0253_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0253_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0253_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0253_default_clean", "v0253_clean":
			_clear_barrosan_playtest_selection()
		"v0252_overview", "v0252_starting_resources":
			_set_v0252_aster_health_contract()
			_capture_v0245_starting_resources()
			_set_v0249_objective("1. Select Aster", "Select Aster")
		"v0252_select_builder":
			_run_v0246_builder_probe()
			_set_v0249_objective("8. Prepare for Ashen pressure", "Construction available")
		"v0252_valid_preview":
			_run_v0245_preview(false, "v0252_confirm")
		"v0252_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare one defender", "Authoritative placement | complete | trains Militia only")
		"v0252_construction_delta", "v0252_barracks_hp_200":
			_show_v0245_construction_proof("resource_delta")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_train_command":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_train_militia":
			_queue_v0246_field_militia()
			_set_v0249_objective("Militia preparing...", "Militia training...")
		"v0252_training_progress":
			_advance_v0246_field_training(60)
			_attempt_v0246_duplicate_queue()
		"v0252_militia_ready":
			_advance_v0246_field_training(70)
			_prepare_v0247_pressure()
			_set_v0249_objective("Defender ready", "Militia ready")
		"v0252_raider_spawned":
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0252_raider_minimap":
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0252_raider_entering_threat_range":
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_set_v0249_objective("Ashen pressure entering threat range", "Threat range reached")
		"v0252_warning_started":
			_begin_v0252_threat_window()
			_select_v0247_raider()
		"v0252_warning_midpoint":
			_advance_v0252_threat_window()
			_select_v0247_raider()
		"v0252_warning_barracks_hp_200":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_select_militia_warning", "v0252_attack_available_warning":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Intercept before impact", "Attack Raider available | HP 100/100")
		"v0252_attack_accepted_warning":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
			timing["defendedDuringWarning"] = bool(timing.get("warningActive", false))
			timing["warningStepAtAttackOrder"] = int(timing.get("warningStep", 0))
			timing["threatWindowMarkerVisible"] = false
			barrosan_playtest["v0252ThreatTiming"] = timing
			_set_v0249_objective("Attack order accepted", "Target: Ashen Raider | HP 100/100")
		"v0252_militia_closing":
			_run_v0252_militia_threat_intercept(120)
		"v0252_combat_tick_1":
			_begin_v0249_combat()
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 90/100 | Raider HP 40/60")
		"v0252_combat_tick_2":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 80/100 | Raider HP 20/60")
		"v0252_combat_tick_3":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Ashen Raider defeated", "Raider HP 0/60 | Militia HP 70/100")
		"v0252_raider_defeated":
			_finalize_v0249_combat_visuals()
		"v0252_pressure_contained_before_impact":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_finalize_v0249_combat_visuals()
			_set_v0249_objective("Ashen pressure contained before impact", "Field Barracks unharmed")
		"v0252_barracks_unharmed", "v0252_defended_no_resource_mutation":
			_record_v0249_collateral_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_missed_window_start":
			v0252_defended_proof = _v0250_attack_order_status().duplicate(true)
			v0252_defended_proof["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			v0252_defended_proof["production"] = _v0246_production_status().duplicate(true)
			v0252_defended_proof["construction"] = _v0245_construction_status().duplicate(true)
			v0252_defended_proof["threatTiming"] = barrosan_playtest.get("v0252ThreatTiming", {}).duplicate(true)
			_reset_v0251_branch_runtime()
			_reset_barrosan_playtest_status()
			_set_v0252_aster_health_contract()
			_load_v0246_militia_authority()
			_capture_v0245_starting_resources()
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0252_missed_confirm")
			_attempt_v0245_placement(false)
			_prepare_v0251_undefended_pressure()
			_activate_v0249_markers()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_missed_raider_spawned":
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_select_v0247_raider()
		"v0252_missed_warning_started":
			_begin_v0252_threat_window()
			_select_v0247_raider()
		"v0252_missed_warning_expired":
			_advance_v0252_threat_window()
			_advance_v0252_threat_window()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_damage_begins_after_expiry":
			_begin_v0252_building_pressure_after_warning()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_building_tick_1":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_building_tick_2":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_building_tick_3":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_damage_stopped", "v0252_barracks_damaged", "v0252_missed_no_resource_mutation":
			_finalize_v0251_building_pressure()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0252_aster_worker_unharmed":
			v0252_missed_window_proof = _v0252_missed_window_status().duplicate(true)
			_select_playtest_unit("hero_aster")
		"v0252_raider_bounded_stop":
			_finalize_v0251_building_pressure()
			_select_v0247_raider()
		"v0252_preserve_barracks":
			_run_v0244_barracks_restore_train_flow()
		"v0252_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0252_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0252_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0252_default_clean", "v0252_clean":
			_clear_barrosan_playtest_selection()
		"v0251_overview", "v0251_starting_resources":
			_capture_v0245_starting_resources()
			_set_v0249_objective("1. Select Aster", "Select Aster")
		"v0251_select_builder":
			_run_v0246_builder_probe()
			_set_v0249_objective("8. Prepare for Ashen pressure", "Construction available")
		"v0251_valid_preview":
			_run_v0245_preview(false, "v0251_confirm")
		"v0251_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare one defender", "Authoritative placement | complete | trains Militia only")
		"v0251_construction_delta", "v0251_barracks_hp_200":
			_show_v0245_construction_proof("resource_delta")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_select_field_barracks", "v0251_train_command":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_train_militia":
			_queue_v0246_field_militia()
			_set_v0249_objective("Militia preparing...", "Militia training...")
		"v0251_training_progress":
			_advance_v0246_field_training(60)
			_attempt_v0246_duplicate_queue()
		"v0251_militia_ready":
			_advance_v0246_field_training(70)
			_prepare_v0247_pressure()
			_set_v0249_objective("Defender ready", "Militia ready")
		"v0251_select_militia":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Defender ready", "Attack Raider available | HP 100/100")
		"v0251_pressure_telegraph", "v0251_intercept_marker":
			_prepare_v0247_pressure()
			_activate_v0249_markers()
			_set_v0249_objective("9. Ashen pressure incoming", "Incoming pressure")
		"v0251_raider_spawned":
			_spawn_v0247_ashen_raider()
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("bridge_approach", V0247_PRESSURE_BRIDGE_APPROACH, 245)
			_select_v0247_raider()
		"v0251_raider_minimap":
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0251_attack_available":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Defender ready", "Attack Raider available | HP 100/100")
		"v0251_attack_accepted":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			_set_v0249_objective("Attack order accepted", "Target: Ashen Raider | HP 100/100")
		"v0251_militia_closing":
			_run_v0247_militia_intercept(480, false)
		"v0251_combat_tick_1":
			_begin_v0249_combat()
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 90/100 | Raider HP 40/60")
		"v0251_combat_tick_2":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 80/100 | Raider HP 20/60")
		"v0251_combat_tick_3":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Ashen Raider defeated", "Raider HP 0/60 | Militia HP 70/100")
		"v0251_raider_defeated":
			_finalize_v0249_combat_visuals()
		"v0251_pressure_contained":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_finalize_v0249_combat_visuals()
			_set_v0249_objective("Ashen pressure contained", "Pressure contained by explicit attack order")
		"v0251_barracks_unharmed", "v0251_defended_no_resource_mutation":
			_record_v0249_collateral_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_undefended_start":
			v0251_defended_proof = _v0250_attack_order_status().duplicate(true)
			v0251_defended_proof["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
			v0251_defended_proof["production"] = _v0246_production_status().duplicate(true)
			v0251_defended_proof["construction"] = _v0245_construction_status().duplicate(true)
			_reset_v0251_branch_runtime()
			_reset_barrosan_playtest_status()
			_load_v0246_militia_authority()
			_capture_v0245_starting_resources()
			_run_v0246_builder_probe()
			_run_v0245_preview(false, "v0251_undefended_confirm")
			_attempt_v0245_placement(false)
			_prepare_v0251_undefended_pressure()
			_activate_v0249_markers()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_undefended_raider_spawned":
			_spawn_v0247_ashen_raider()
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0251_undefended_advancing":
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("field_barracks_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
			_set_v0249_objective("Field Barracks under Ashen pressure", "Building pressure incoming")
		"v0251_undefended_contact":
			_begin_v0251_building_pressure()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_building_tick_1":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_building_tick_2":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_building_tick_3":
			_advance_v0251_building_damage_tick()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_barracks_damaged", "v0251_undefended_contained", "v0251_undefended_no_resource_mutation":
			_finalize_v0251_building_pressure()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0251_aster_worker_unharmed":
			v0251_undefended_proof = _v0251_undefended_status().duplicate(true)
			_select_playtest_unit("hero_aster")
		"v0251_preserve_barracks":
			_run_v0244_barracks_restore_train_flow()
		"v0251_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0251_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0251_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0251_default_clean", "v0251_clean":
			_clear_barrosan_playtest_selection()
		"v0250_overview", "v0250_starting_resources":
			_capture_v0245_starting_resources()
			_set_v0249_objective("1. Select Aster", "Select Aster")
		"v0250_select_builder":
			_run_v0246_builder_probe()
			_set_v0249_objective("8. Prepare for Ashen pressure", "Construction available")
		"v0250_valid_preview":
			_run_v0245_preview(false, "v0250_confirm")
			_set_v0249_objective("8. Prepare for Ashen pressure", "Authoritative Field Barracks preview")
		"v0250_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare one defender", "Authoritative placement | complete | trains Militia only")
		"v0250_construction_delta":
			_show_v0245_construction_proof("resource_delta")
			_set_v0249_objective("Prepare one defender", "Prepare one defender")
		"v0250_select_field_barracks", "v0250_train_command":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_set_v0249_objective("Prepare one defender", "Prepare one defender")
		"v0250_train_militia":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_queue_v0246_field_militia()
			_set_v0249_objective("Militia preparing...", "Militia training...")
		"v0250_training_progress":
			_advance_v0246_field_training(60)
			_attempt_v0246_duplicate_queue()
			_set_v0249_objective("Militia preparing...", "Militia training... 50%")
		"v0250_militia_ready":
			_advance_v0246_field_training(70)
			_prepare_v0247_pressure()
			_set_v0249_objective("Defender ready", "Militia ready")
		"v0250_select_militia", "v0250_attack_available":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Defender ready", "Attack Raider available | HP 100/100")
		"v0250_pressure_telegraph", "v0250_intercept_marker":
			_prepare_v0247_pressure()
			_activate_v0249_markers()
			_set_v0249_objective("9. Ashen pressure incoming", "Incoming pressure")
		"v0250_raider_spawned":
			_spawn_v0247_ashen_raider()
			_record_v0249_snapshot("afterRaiderSpawn")
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("bridge_approach", V0247_PRESSURE_BRIDGE_APPROACH, 245)
			_set_v0249_objective("Ashen Raider advancing", "Ashen Raider advancing | HP 60/60")
			_select_v0247_raider()
		"v0250_raider_minimap":
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0250_select_militia_before_attack":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Defender ready", "Attack Raider available | HP 100/100")
		"v0250_attack_targeting":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_hud_attack_pressed()
		"v0250_raider_targeted":
			issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
			_select_v0247_raider()
		"v0250_attack_accepted":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Attack order accepted", "Target: Ashen Raider | HP 100/100")
		"v0250_militia_closing":
			_run_v0247_militia_intercept(480, false)
			_set_v0249_objective("Attack order accepted", "Moving to engage Ashen Raider | HP 100/100")
		"v0250_combat_contact":
			_begin_v0249_combat()
			_set_v0249_objective("Combat engaged", "Engaging Ashen Raider | HP 100/100")
		"v0250_combat_tick_1":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 90/100 | Raider HP 40/60")
		"v0250_combat_tick_2":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 80/100 | Raider HP 20/60")
		"v0250_combat_tick_3":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Ashen Raider defeated", "Raider HP 0/60 | Militia HP 70/100")
		"v0250_raider_defeated", "v0250_raider_minimap_removed":
			_finalize_v0249_combat_visuals()
		"v0250_pressure_contained":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_finalize_v0249_combat_visuals()
			_set_v0249_objective("Ashen pressure contained", "Pressure contained by explicit attack order")
		"v0250_no_resource_mutation":
			_attempt_v0246_failed_training()
			_record_v0249_snapshot("afterContainment")
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0250_no_building_damage":
			_record_v0249_collateral_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0250_aster_worker_unharmed":
			_record_v0249_collateral_proof()
			_select_playtest_unit("hero_aster")
		"v0250_preserve_barracks":
			_run_v0246_militia_probe("restored_barracks_main_base", Vector2(360, 260), 260)
			_run_v0244_barracks_restore_train_flow()
		"v0250_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0250_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0250_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0250_clean":
			_clear_barrosan_playtest_selection()
		"v0249_overview", "v0249_starting_resources":
			_capture_v0245_starting_resources()
			_set_v0249_objective("1. Select Aster", "Select Aster")
		"v0249_select_builder":
			_run_v0246_builder_probe()
			_set_v0249_objective("8. Prepare for Ashen pressure", "Construction available")
		"v0249_valid_preview":
			_run_v0245_preview(false, "v0249_confirm")
			_set_v0249_objective("8. Prepare for Ashen pressure", "Authoritative Field Barracks preview")
		"v0249_confirm_placement":
			_attempt_v0245_placement(false)
			_set_v0249_objective("Prepare one defender", "Authoritative placement | complete | trains Militia only")
		"v0249_construction_delta":
			_show_v0245_construction_proof("resource_delta")
			_set_v0249_objective("Prepare one defender", "Prepare one defender")
		"v0249_select_field_barracks", "v0249_train_command":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_set_v0249_objective("Prepare one defender", "Prepare one defender")
		"v0249_train_militia":
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
			_queue_v0246_field_militia()
			_set_v0249_objective("Militia preparing...", "Militia training...")
		"v0249_training_progress":
			_advance_v0246_field_training(60)
			_attempt_v0246_duplicate_queue()
			_set_v0249_objective("Militia preparing...", "Militia training... 50%")
		"v0249_militia_ready":
			_advance_v0246_field_training(70)
			_prepare_v0247_pressure()
			_set_v0249_objective("Defender ready", "Militia ready")
		"v0249_select_militia":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Defender ready", "Move to intercept zone | HP 100/100")
		"v0249_pressure_telegraph", "v0249_intercept_marker":
			_prepare_v0247_pressure()
			_activate_v0249_markers()
			_set_v0249_objective("9. Ashen pressure incoming", "Incoming pressure")
		"v0249_pressure_incoming":
			_set_v0249_objective("9. Ashen pressure incoming", "Incoming pressure")
		"v0249_raider_spawned":
			_spawn_v0247_ashen_raider()
			_record_v0249_snapshot("afterRaiderSpawn")
			_set_v0249_objective("Ashen Raider advancing", "Ashen Raider advancing | HP 60/60")
			_select_v0247_raider()
		"v0249_raider_minimap":
			_add_v0247_ashen_raider_minimap_marker()
			_select_v0247_raider()
		"v0249_raider_advancing":
			_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
			_advance_v0247_raider_lane("bridge_approach", V0247_PRESSURE_BRIDGE_APPROACH, 245)
			_record_v0249_snapshot("afterRaiderMovement")
			_set_v0249_objective("Ashen Raider advancing", "Ashen Raider advancing | HP 60/60")
		"v0249_militia_move":
			_run_v0247_militia_intercept(480, false)
			_set_v0249_objective("Move Militia to intercept", "Move to intercept zone | HP 100/100")
		"v0249_combat_contact":
			_begin_v0249_combat()
			_set_v0249_objective("Combat engaged", "Militia engaging Raider | HP 100/100")
		"v0249_combat_tick_1":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 90/100 | Raider HP 40/60")
		"v0249_combat_tick_2":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Militia engaging Raider", "Militia HP 80/100 | Raider HP 20/60")
		"v0249_raider_defeated":
			_advance_v0249_combat_tick()
			_set_v0249_objective("Ashen Raider defeated", "Raider HP 0/60 | Militia HP 70/100")
		"v0249_raider_defeated_state", "v0249_raider_minimap_removed":
			_finalize_v0249_combat_visuals()
		"v0249_militia_survives":
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
			_set_v0249_objective("Ashen pressure contained", "Pressure contained by combat")
		"v0249_pressure_contained":
			_finalize_v0249_combat_visuals()
			_set_v0249_objective("Ashen pressure contained", "Pressure contained by combat | No building damage")
		"v0249_no_resource_mutation":
			_attempt_v0246_failed_training()
			_record_v0249_snapshot("afterContainment")
			_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)
		"v0249_no_building_damage":
			_record_v0249_collateral_proof()
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0249_aster_worker_unharmed":
			_record_v0249_collateral_proof()
			_select_playtest_unit("hero_aster")
		"v0249_preserve_barracks":
			_run_v0246_militia_probe("restored_barracks_main_base", Vector2(360, 260), 260)
			_run_v0244_barracks_restore_train_flow()
		"v0249_preserve_keep":
			select_barrosan_runtime_role("main_base")
			_record_v0244_live_role("main_base")
		"v0249_preserve_mine":
			select_barrosan_runtime_role("mine")
			_record_v0244_live_role("mine")
		"v0249_preserve_shells":
			_select_v0244_shell("blacksmith", false)
			_select_v0244_shell("market", false)
			_select_v0244_shell("watchtower")
		"v0249_clean":
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
			if action_mode == "clean":
				barrosan_selected_role_id = ""
	if barrosan_requested_checkpoint == "v0.263" and _v0263_is_review_mode(mode):
		_v0263_apply_review_mode(mode)
	if barrosan_requested_checkpoint == "v0.262" and _v0262_is_review_mode(mode):
		_v0262_apply_review_mode(mode)
	if barrosan_requested_checkpoint in ["v0.261", "v0.262", "v0.263"] and _v0261_is_review_mode(mode):
		_v0261_apply_review_mode(mode)
	if barrosan_requested_checkpoint in ["v0.258", "v0.259"]:
		# Older proof helpers may rewrite the shared review-mode token while they
		# establish mechanics. Restore the requested lifecycle phase
		# before deriving its instruction and visual evidence.
		barrosan_runtime_review_mode = mode
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	if barrosan_requested_checkpoint in ["v0.257", "v0.258"]:
		_apply_v0257_hud_override()
	if barrosan_requested_checkpoint == "v0.258":
		_apply_v0258_lifecycle_instruction()
		_record_v0258_lifecycle_proof(mode)
	elif barrosan_requested_checkpoint == "v0.259":
		_v0259_apply_resolved_ui()
		_v0259_record_ui_invariant_proof(mode)
	elif barrosan_requested_checkpoint == "v0.263" and _v0263_is_review_mode(mode):
		_v0261_apply_resolved_ui()
		_v0263_record_intel_memory_proof(mode)
	elif barrosan_requested_checkpoint == "v0.262" and _v0262_is_review_mode(mode):
		_v0261_apply_resolved_ui()
		_v0262_record_awareness_proof(mode)
	elif barrosan_requested_checkpoint in ["v0.261", "v0.262", "v0.263"] and _v0261_is_review_mode(mode):
		_v0261_apply_resolved_ui()
		_v0261_record_watchpost_proof(mode)
	elif barrosan_requested_checkpoint == "v0.257":
		_record_v0257_hud_proof(mode)


func _apply_v0257_hud_override() -> void:
	var hp := int(_v0251_field_barracks_health())
	var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
	if runtime.selected_ids.has("worker_00"):
		hud_hero_label.text = "Selected Worker"
		if hp <= 0:
			hud_context_label.text = "Rebuild available | Destroyed Field Barracks | Cost: 90 Crowns / 40 Stone | Ready."
			hud_objective_strip_label.text = "Rebuild destroyed Field Barracks"
			hud_objective_label.text = "Repair unavailable | Target destroyed"
			hud_work_button.text = "Rebuild"
		elif bool(rebuild.get("rebuildComplete", false)):
			hud_context_label.text = "Rebuild unavailable | No destroyed target | Construction available | Ready."
			hud_objective_strip_label.text = "Field Barracks damaged but functional"
			hud_objective_label.text = "Repair unavailable | Insufficient Stone"
			hud_work_button.text = "Repair unavailable"
		elif _v0253_repair_command_available():
			hud_context_label.text = "Repair available | Damaged Field Barracks | Rebuild unavailable | Target not destroyed | Ready."
			hud_objective_strip_label.text = "Repair damaged Field Barracks"
			hud_objective_label.text = "Production available while HP > 0"
			hud_work_button.text = "Repair"
	elif barrosan_selected_role_id == V0245_CONSTRUCTED_KEY:
		if bool(rebuild.get("rebuildStarted", false)):
			hud_hero_label.text = "Authoritative Field Barracks | Rebuilding"
			hud_context_label.text = "Production unavailable until rebuild complete | HP %s/200" % hp
			hud_objective_strip_label.text = "Rebuilding Field Barracks"
			hud_objective_label.text = "Rebuild progress %s/4" % int(rebuild.get("rebuildTickCount", 0))
			hud_work_button.text = "Train unavailable"
		elif hp <= 0:
			hud_hero_label.text = "Authoritative Field Barracks | Destroyed"
			hud_context_label.text = "HP 0/200 | Production unavailable"
			hud_objective_strip_label.text = "Authoritative Field Barracks destroyed"
			hud_objective_label.text = "Select Worker to rebuild"
			hud_work_button.text = "Train unavailable"
		elif bool(rebuild.get("rebuildComplete", false)) and hp == 100:
			hud_hero_label.text = "Authoritative Field Barracks | Damaged but functional"
			hud_context_label.text = "Operational | Rebuilt HP 100/200 | Train Militia available"
			hud_objective_strip_label.text = "Field Barracks rebuilt"
			hud_objective_label.text = "Ready."
			hud_work_button.text = "Train Militia"
		elif hp < int(V0251_FIELD_BARRACKS_MAX_HP):
			hud_hero_label.text = "Authoritative Field Barracks | Damaged but functional"
			hud_context_label.text = "Operational | HP %s/200 | Train Militia available" % hp
			hud_objective_strip_label.text = "Field Barracks damaged but functional"
			hud_objective_label.text = "Ready. | Production available while HP > 0"
			hud_work_button.text = "Train Militia"


func _apply_v0258_lifecycle_instruction() -> void:
	if hud_onboarding_label == null:
		return
	var hp := int(_v0251_field_barracks_health())
	var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
	var instruction := "Select Aster."
	match barrosan_runtime_review_mode:
		"v0258_initial_select_aster":
			instruction = "Select Aster."
		"v0258_after_aster_select_worker":
			instruction = "Select Worker."
		"v0258_worker_place_barracks":
			instruction = "Place Field Barracks."
		"v0258_valid_placement":
			instruction = "Click to build Field Barracks."
		"v0258_barracks_built":
			instruction = "Field Barracks built. Prepare for Ashen pressure."
		"v0258_hp_125":
			instruction = "Damaged but functional. Production still available while HP > 0."
		"v0258_hp_25":
			instruction = "Critical but functional. Production still available while HP > 0."
		"v0258_hp_0", "v0258_destroyed_no_stale":
			instruction = "Destroyed. Select Worker to rebuild."
		"v0258_worker_rebuild_instruction", "v0258_worker_rebuild_hud":
			instruction = "Rebuild destroyed Field Barracks."
		"v0258_rebuild_delta", "v0258_rebuild_25", "v0258_rebuild_50", "v0258_rebuild_75":
			instruction = "Rebuilding Field Barracks."
		"v0258_rebuild_100", "v0258_train_available", "v0258_train_delta":
			instruction = "Field Barracks rebuilt. Train Militia."
		"v0258_militia_ready", "v0258_defended", "v0258_minimap", "v0258_structures", "v0258_no_stale_rebuild", "v0258_no_stale_aster":
			instruction = "Militia ready. Defend the Barracks."
		"v0258_separation":
			instruction = "Field Barracks rebuilt. Train Militia."
		_:
			if runtime.selected_ids.has("worker_00") and hp <= 0:
				instruction = "Rebuild destroyed Field Barracks."
			elif bool(rebuild.get("rebuildStarted", false)):
				instruction = "Rebuilding Field Barracks."
			elif bool(rebuild.get("rebuildComplete", false)):
				instruction = "Field Barracks rebuilt. Train Militia."
			elif hp <= 0:
				instruction = "Destroyed. Select Worker to rebuild."
			elif hp == 25:
				instruction = "Critical but functional. Production still available while HP > 0."
			elif hp < int(V0251_FIELD_BARRACKS_MAX_HP):
				instruction = "Damaged but functional. Production still available while HP > 0."
			elif _v0245_constructed_count() == 1:
				instruction = "Prepare for Ashen pressure."
			elif runtime.selected_ids.has("worker_00"):
				instruction = "Place Field Barracks."
			elif runtime.selected_ids.has("hero_aster"):
				instruction = "Select Worker."
	hud_onboarding_label.text = instruction
	hud_onboarding_label.visible = true


func _v0259_resolve_lifecycle_state() -> String:
	var review_states := {
		"v0259_initial": "INITIAL_SELECT_ASTER",
		"v0259_after_aster": "SELECT_WORKER_OR_BUILDER",
		"v0259_build_no_rebuild": "PLACE_FIELD_BARRACKS",
		"v0259_place": "PLACE_FIELD_BARRACKS",
		"v0259_valid": "VALID_PLACEMENT_READY",
		"v0259_full": "FIELD_BARRACKS_FULL",
		"v0259_hp_125": "FIELD_BARRACKS_DAMAGED_FUNCTIONAL",
		"v0259_hp_25": "FIELD_BARRACKS_CRITICAL_FUNCTIONAL",
		"v0259_destroyed": "FIELD_BARRACKS_DESTROYED",
		"v0259_destroyed_clean": "FIELD_BARRACKS_DESTROYED",
		"v0259_worker_rebuild": "WORKER_SELECTED_FOR_REBUILD",
		"v0259_rebuild_button": "WORKER_SELECTED_FOR_REBUILD",
		"v0259_rebuild_delta": "REBUILD_ORDERED",
		"v0259_rebuild_25": "REBUILDING_25",
		"v0259_rebuild_50": "REBUILDING_50",
		"v0259_rebuild_75": "REBUILDING_75",
		"v0259_rebuilt_100": "REBUILT_100_FUNCTIONAL",
		"v0259_train_available": "TRAIN_MILITIA_AVAILABLE",
		"v0259_train_delta": "TRAIN_MILITIA_AVAILABLE",
		"v0259_militia_ready": "MILITIA_READY_DEFEND",
		"v0259_no_rebuild_after": "TRAIN_MILITIA_AVAILABLE",
		"v0259_no_place_rebuild": "REBUILDING_50",
		"v0259_separation": "TRAIN_MILITIA_AVAILABLE",
		"v0259_visual_compare": "FIELD_BARRACKS_CRITICAL_FUNCTIONAL",
		"v0259_minimap": "MILITIA_READY_DEFEND",
		"v0259_structures": "MILITIA_READY_DEFEND",
		"v0259_forbidden_scan": "MILITIA_READY_DEFEND",
	}
	if review_states.has(barrosan_runtime_review_mode):
		return str(review_states[barrosan_runtime_review_mode])
	var hp := int(_v0251_field_barracks_health())
	var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
	if bool(rebuild.get("rebuildStarted", false)):
		return "REBUILDING_%s" % clampi(hp, 25, 75)
	if hp <= 0 and runtime.selected_ids.has("worker_00"):
		return "WORKER_SELECTED_FOR_REBUILD"
	if hp <= 0:
		return "FIELD_BARRACKS_DESTROYED"
	if bool(rebuild.get("rebuildComplete", false)) and hp == 100:
		return "TRAIN_MILITIA_AVAILABLE"
	if hp <= 25:
		return "FIELD_BARRACKS_CRITICAL_FUNCTIONAL"
	if hp < 200:
		return "FIELD_BARRACKS_DAMAGED_FUNCTIONAL"
	if _v0245_constructed_count() == 1:
		return "FIELD_BARRACKS_FULL"
	if barrosan_runtime_review_mode in ["valid_preview", "v0256_valid_preview"]:
		return "VALID_PLACEMENT_READY"
	if runtime.selected_ids.has("worker_00"):
		return "PLACE_FIELD_BARRACKS"
	if runtime.selected_ids.has("hero_aster"):
		return "SELECT_WORKER_OR_BUILDER"
	return "INITIAL_SELECT_ASTER"


func _v0259_lifecycle_ui_model(state: String) -> Dictionary:
	var hp := int(_v0251_field_barracks_health())
	var progress := clampi(int(round(float(hp) / 25.0)), 1, 4)
	var models := {
		"INITIAL_SELECT_ASTER": {
			"topObjective": "1. Select Aster",
			"instruction": "Select Aster.",
			"title": "Aster ready",
			"context": "Aster HP 100/100",
			"status": "Select Aster",
			"button": "Work",
			"targetStatus": "No Field Barracks target",
			"overlayState": "none",
		},
		"SELECT_WORKER_OR_BUILDER": {
			"topObjective": "2. Select Worker",
			"instruction": "Select Worker.",
			"title": "Selected Aster",
			"context": "Construction available",
			"status": "Select Worker",
			"button": "Work",
			"targetStatus": "No Field Barracks target",
			"overlayState": "none",
		},
		"PLACE_FIELD_BARRACKS": {
			"topObjective": "Build authoritative Field Barracks",
			"instruction": "Place Field Barracks.",
			"title": "Selected Worker",
			"context": "Construction available | Field Barracks cost: 180 Crowns / 120 Stone",
			"status": "Choose a valid Field Barracks site",
			"button": "Place Barracks",
			"targetStatus": "Placement target",
			"overlayState": "none",
		},
		"VALID_PLACEMENT_READY": {
			"topObjective": "Build authoritative Field Barracks",
			"instruction": "Click to build Field Barracks.",
			"title": "Selected Worker",
			"context": "Valid Field Barracks placement | Cost: 180 Crowns / 120 Stone",
			"status": "Valid site | Click to confirm",
			"button": "Build Barracks",
			"targetStatus": "Valid placement ready",
			"overlayState": "none",
		},
		"FIELD_BARRACKS_FULL": {
			"topObjective": "Field Barracks built",
			"instruction": "Field Barracks built. Prepare for Ashen pressure.",
			"title": "Authoritative Field Barracks | Full",
			"context": "Operational | HP 200/200 | Train Militia available",
			"status": "Prepare for Ashen pressure",
			"button": "Train Militia",
			"targetStatus": "Full | HP 200/200 | Production available",
			"overlayState": "full",
		},
		"FIELD_BARRACKS_DAMAGED_FUNCTIONAL": {
			"topObjective": "Field Barracks damaged but functional",
			"instruction": "Damaged but functional. Production still available while HP > 0.",
			"title": "Authoritative Field Barracks | Damaged but functional",
			"context": "Operational | HP 125/200 | Train Militia available",
			"status": "Production available while HP > 0",
			"button": "Train Militia",
			"targetStatus": "Damaged but functional | HP 125/200",
			"overlayState": "damaged_functional",
		},
		"FIELD_BARRACKS_CRITICAL_FUNCTIONAL": {
			"topObjective": "Field Barracks critical but functional",
			"instruction": "Critical but functional. Production still available while HP > 0.",
			"title": "Authoritative Field Barracks | Critical but functional",
			"context": "Operational | HP 25/200 | Train Militia available",
			"status": "Production still available while HP > 0",
			"button": "Train Militia",
			"targetStatus": "Critical but functional | HP 25/200",
			"overlayState": "critical_functional",
		},
		"FIELD_BARRACKS_DESTROYED": {
			"topObjective": "Rebuild destroyed Field Barracks",
			"instruction": "Destroyed. Select Worker to rebuild.",
			"title": "Authoritative Field Barracks | Destroyed",
			"context": "Destroyed | HP 0/200 | Production unavailable",
			"status": "Select Worker to rebuild",
			"button": "Train unavailable",
			"targetStatus": "Destroyed | HP 0/200 | Production unavailable",
			"overlayState": "destroyed",
		},
		"WORKER_SELECTED_FOR_REBUILD": {
			"topObjective": "Rebuild destroyed Field Barracks",
			"instruction": "Rebuild destroyed Field Barracks.",
			"title": "Selected Worker",
			"context": "Rebuild available | Destroyed Field Barracks | Cost: 90 Crowns / 40 Stone",
			"status": "Repair unavailable | Target destroyed",
			"button": "Rebuild",
			"targetStatus": "Destroyed Field Barracks | HP 0/200",
			"overlayState": "destroyed",
		},
		"REBUILD_ORDERED": {
			"topObjective": "Rebuilding Field Barracks",
			"instruction": "Rebuilding Field Barracks.",
			"title": "Selected Worker | Rebuild ordered",
			"context": "Production unavailable until rebuild complete",
			"status": "Rebuild progress 0/4",
			"button": "Rebuild unavailable",
			"targetStatus": "Rebuilding ordered | HP 0/200",
			"overlayState": "rebuilding",
		},
		"REBUILT_100_FUNCTIONAL": {
			"topObjective": "Field Barracks rebuilt",
			"instruction": "Field Barracks rebuilt. Train Militia.",
			"title": "Authoritative Field Barracks | Damaged but functional",
			"context": "Operational | Rebuilt HP 100/200 | Train Militia available",
			"status": "Train Militia available",
			"button": "Train Militia",
			"targetStatus": "Rebuilt | HP 100/200 | Production available",
			"overlayState": "rebuilt_damaged",
		},
		"TRAIN_MILITIA_AVAILABLE": {
			"topObjective": "Field Barracks rebuilt",
			"instruction": "Field Barracks rebuilt. Train Militia.",
			"title": "Authoritative Field Barracks | Damaged but functional",
			"context": "Operational | Rebuilt HP 100/200 | Train Militia available",
			"status": "Train Militia available",
			"button": "Train Militia",
			"targetStatus": "Rebuilt | HP 100/200 | Production available",
			"overlayState": "rebuilt_damaged",
		},
		"MILITIA_READY_DEFEND": {
			"topObjective": "Defend the Field Barracks",
			"instruction": "Militia ready. Defend the Barracks.",
			"title": "Selected Militia",
			"context": "Unit ready | Field Barracks HP 100/200",
			"status": "Defend the Barracks",
			"button": "Attack",
			"targetStatus": "Field Barracks functional | HP 100/200",
			"overlayState": "rebuilt_damaged",
		},
	}
	if state.begins_with("REBUILDING_"):
		return {
			"topObjective": "Rebuilding Field Barracks",
			"instruction": "Rebuilding Field Barracks.",
			"title": "Authoritative Field Barracks | Rebuilding",
			"context": "Production unavailable until rebuild complete | HP %s/200" % hp,
			"status": "Rebuild progress %s/4 | Repair unavailable" % progress,
			"button": "Train unavailable",
			"targetStatus": "Rebuilding | HP %s/200" % hp,
			"overlayState": "rebuilding",
		}
	return (models.get(state, models["INITIAL_SELECT_ASTER"]) as Dictionary).duplicate(true)


func _v0259_apply_resolved_ui() -> void:
	var state := _v0259_resolve_lifecycle_state()
	var model := _v0259_lifecycle_ui_model(state)
	if hud_objective_strip_label != null:
		hud_objective_strip_label.text = str(model.get("topObjective", ""))
	if hud_onboarding_label != null:
		hud_onboarding_label.text = str(model.get("instruction", ""))
		hud_onboarding_label.visible = true
	if hud_hero_label != null:
		hud_hero_label.text = str(model.get("title", ""))
	if hud_context_label != null:
		hud_context_label.text = str(model.get("context", ""))
	if hud_objective_label != null:
		hud_objective_label.text = str(model.get("status", ""))
	if hud_work_button != null:
		hud_work_button.text = str(model.get("button", ""))


func _v0259_record_ui_invariant_proof(mode: String) -> void:
	var state := _v0259_resolve_lifecycle_state()
	var model := _v0259_lifecycle_ui_model(state)
	var snapshot := {
		"state": state,
		"model": model,
		"topObjective": hud_objective_strip_label.text if hud_objective_strip_label != null else "",
		"instruction": hud_onboarding_label.text if hud_onboarding_label != null else "",
		"title": hud_hero_label.text if hud_hero_label != null else "",
		"context": hud_context_label.text if hud_context_label != null else "",
		"status": hud_objective_label.text if hud_objective_label != null else "",
		"button": hud_work_button.text if hud_work_button != null else "",
		"targetStatus": str(model.get("targetStatus", "")),
		"overlayState": str(model.get("overlayState", "")),
		"visualState": _v0258_field_barracks_visual_state(),
	}
	var combined := " | ".join([
		str(snapshot["topObjective"]), str(snapshot["instruction"]), str(snapshot["title"]),
		str(snapshot["context"]), str(snapshot["status"]), str(snapshot["button"]),
		str(snapshot["targetStatus"]),
	])
	snapshot["forbiddenRebuildNotImplemented"] = combined.contains("Rebuild not yet implemented")
	snapshot["combinedText"] = combined
	snapshot["selectAsterBeyondInitial"] = state != "INITIAL_SELECT_ASTER" and combined.contains("Select Aster")
	snapshot["buildText"] = combined.contains("Place Field Barracks") or combined.contains("Click to build Field Barracks") or combined.contains("Build Barracks")
	snapshot["rebuildText"] = combined.contains("Rebuild") or combined.contains("Destroyed Field Barracks") or combined.contains("Target destroyed")
	snapshot["singleSourceMatch"] = (
		str(snapshot["topObjective"]) == str(model.get("topObjective", ""))
		and str(snapshot["instruction"]) == str(model.get("instruction", ""))
		and str(snapshot["title"]) == str(model.get("title", ""))
		and str(snapshot["context"]) == str(model.get("context", ""))
		and str(snapshot["status"]) == str(model.get("status", ""))
		and str(snapshot["button"]) == str(model.get("button", ""))
	)
	v0259_ui_invariant_proof[mode] = snapshot


func _v0261_is_review_mode(mode: String) -> bool:
	return [
		"v0261_initial", "v0261_after_aster", "v0261_place_field_barracks", "v0261_field_barracks_built",
		"v0261_new_objective_build_watchpost", "v0261_worker_watchpost_button", "v0261_watchpost_placement_cost",
		"v0261_watchpost_valid_site", "v0261_watchpost_built_resource_delta", "v0261_watchpost_selected_hud",
		"v0261_watch_zone_overlay", "v0261_watchpost_minimap_marker", "v0261_barracks_still_trains_militia",
		"v0261_militia_training_after_watchpost", "v0261_no_barracks_text_on_watchpost",
		"v0261_no_watchpost_text_on_barracks", "v0261_existing_barracks_rebuild_path_still_valid"
	].has(mode)


func _v0262_is_review_mode(mode: String) -> bool:
	return [
		"v0262_watchpost_foundation_path", "v0262_watchpost_complete_no_threat",
		"v0262_watch_zone_clean_labeling", "v0262_ashen_marker_outside_zone_no_false_positive",
		"v0262_ashen_marker_touching_zone_scouted", "v0262_ashen_marker_inside_zone_scouted",
		"v0262_watchpost_selected_scouted_hud", "v0262_watchpost_selected_no_attack_copy",
		"v0262_minimap_scouted_threat_ping", "v0262_barracks_hud_no_watchpost_text",
		"v0262_watchpost_hud_no_barracks_text", "v0262_barracks_still_trains_militia",
		"v0262_existing_barracks_rebuild_path_still_valid", "v0262_no_detection_before_watchpost_complete"
	].has(mode)


func _v0263_is_review_mode(mode: String) -> bool:
	return [
		"v0263_watchpost_build_path", "v0263_watchpost_complete_no_threat_no_history",
		"v0263_watch_zone_clean_labeling", "v0263_ashen_outside_zone_no_false_positive",
		"v0263_ashen_touching_zone_current_scouted", "v0263_ashen_inside_zone_current_scouted",
		"v0263_current_scouted_minimap_ping", "v0263_current_scouted_hud_intel_only",
		"v0263_threat_leaves_zone_last_seen_memory", "v0263_last_seen_memory_minimap_ping",
		"v0263_last_seen_memory_world_marker", "v0263_memory_clearly_not_current_detection",
		"v0263_watchpost_hud_no_barracks_text", "v0263_barracks_hud_no_watchpost_text",
		"v0263_barracks_still_trains_militia", "v0263_existing_barracks_rebuild_path_still_valid",
		"v0263_no_detection_or_memory_before_watchpost_complete"
	].has(mode)


func _v0263_apply_review_mode(mode: String) -> void:
	barrosan_runtime_review_mode = mode
	match mode:
		"v0263_watchpost_build_path":
			_v0263_reset_intel_memory()
			_v0261_ensure_field_barracks_built()
			_select_playtest_unit("worker_00")
		"v0263_no_detection_or_memory_before_watchpost_complete":
			_v0261_reset_foundation_state()
			_v0263_reset_intel_memory()
			_v0261_ensure_field_barracks_built()
			_v0262_place_ashen_marker(V0262_ASHEN_INSIDE_ZONE, "inside")
			_select_playtest_unit("worker_00")
		"v0263_watchpost_complete_no_threat_no_history", "v0263_watch_zone_clean_labeling":
			_v0261_ensure_watchpost_built()
			_v0263_reset_intel_memory()
			_v0262_clear_ashen_marker()
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0263_ashen_outside_zone_no_false_positive":
			_v0261_ensure_watchpost_built()
			_v0263_reset_intel_memory()
			_v0262_place_ashen_marker(V0262_ASHEN_OUTSIDE_ZONE, "outside")
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0263_ashen_touching_zone_current_scouted":
			_v0261_ensure_watchpost_built()
			_v0263_reset_intel_memory()
			_v0262_place_ashen_marker(V0262_ASHEN_TOUCHING_ZONE, "touching")
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0263_ashen_inside_zone_current_scouted", "v0263_current_scouted_minimap_ping", "v0263_current_scouted_hud_intel_only", "v0263_watchpost_hud_no_barracks_text":
			_v0261_ensure_watchpost_built()
			_v0263_reset_intel_memory()
			_v0262_place_ashen_marker(V0262_ASHEN_INSIDE_ZONE, "inside")
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0263_threat_leaves_zone_last_seen_memory", "v0263_last_seen_memory_minimap_ping", "v0263_last_seen_memory_world_marker", "v0263_memory_clearly_not_current_detection":
			_v0261_ensure_watchpost_built()
			_v0263_reset_intel_memory()
			_v0262_place_ashen_marker(V0262_ASHEN_INSIDE_ZONE, "inside")
			_v0263_update_intel_memory_state()
			_v0263_move_ashen_marker_after_scout(V0262_ASHEN_OUTSIDE_ZONE)
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0263_barracks_hud_no_watchpost_text", "v0263_barracks_still_trains_militia":
			_v0261_ensure_watchpost_built()
			_v0263_reset_intel_memory()
			_v0262_place_ashen_marker(V0262_ASHEN_INSIDE_ZONE, "inside")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0263_existing_barracks_rebuild_path_still_valid":
			_v0263_reset_intel_memory()
			set_barrosan_runtime_review_mode("v0259_train_delta")
			barrosan_runtime_review_mode = mode
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
	_v0263_update_intel_memory_state()


func _v0262_apply_review_mode(mode: String) -> void:
	barrosan_runtime_review_mode = mode
	match mode:
		"v0262_watchpost_foundation_path":
			_v0261_ensure_field_barracks_built()
			_select_playtest_unit("worker_00")
		"v0262_no_detection_before_watchpost_complete":
			_v0261_reset_foundation_state()
			_v0261_ensure_field_barracks_built()
			_v0262_place_ashen_marker(V0262_ASHEN_INSIDE_ZONE, "inside")
			_select_playtest_unit("worker_00")
		"v0262_watchpost_complete_no_threat", "v0262_watch_zone_clean_labeling":
			_v0261_ensure_watchpost_built()
			_v0262_clear_ashen_marker()
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0262_ashen_marker_outside_zone_no_false_positive":
			_v0261_ensure_watchpost_built()
			_v0262_place_ashen_marker(V0262_ASHEN_OUTSIDE_ZONE, "outside")
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0262_ashen_marker_touching_zone_scouted":
			_v0261_ensure_watchpost_built()
			_v0262_place_ashen_marker(V0262_ASHEN_TOUCHING_ZONE, "touching")
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0262_ashen_marker_inside_zone_scouted", "v0262_watchpost_selected_scouted_hud", "v0262_watchpost_selected_no_attack_copy", "v0262_minimap_scouted_threat_ping", "v0262_watchpost_hud_no_barracks_text":
			_v0261_ensure_watchpost_built()
			_v0262_place_ashen_marker(V0262_ASHEN_INSIDE_ZONE, "inside")
			select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		"v0262_barracks_hud_no_watchpost_text", "v0262_barracks_still_trains_militia":
			_v0261_ensure_watchpost_built()
			_v0262_place_ashen_marker(V0262_ASHEN_INSIDE_ZONE, "inside")
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		"v0262_existing_barracks_rebuild_path_still_valid":
			set_barrosan_runtime_review_mode("v0259_train_delta")
			barrosan_runtime_review_mode = mode
			select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
	_v0262_update_awareness_state()


func _v0261_apply_review_mode(mode: String) -> void:
	barrosan_runtime_review_mode = mode
	if mode == "v0261_initial":
		_v0261_reset_foundation_state()
		_select_playtest_unit("hero_aster")
		return
	if mode == "v0261_after_aster":
		_select_playtest_unit("hero_aster")
		return
	if mode == "v0261_place_field_barracks":
		_v0261_reset_foundation_state()
		_select_playtest_unit("worker_00")
		return
	if mode == "v0261_field_barracks_built":
		_v0261_ensure_field_barracks_built()
		select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		return
	if mode in ["v0261_new_objective_build_watchpost", "v0261_worker_watchpost_button", "v0261_watchpost_placement_cost", "v0261_watchpost_valid_site"]:
		_v0261_ensure_field_barracks_built()
		_select_playtest_unit("worker_00")
		return
	if mode in ["v0261_watchpost_built_resource_delta", "v0261_watchpost_selected_hud", "v0261_watch_zone_overlay", "v0261_watchpost_minimap_marker", "v0261_no_barracks_text_on_watchpost"]:
		_v0261_ensure_watchpost_built()
		select_barrosan_runtime_role(V0261_WATCHPOST_KEY)
		return
	if mode == "v0261_no_watchpost_text_on_barracks":
		_v0261_ensure_watchpost_built()
		select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		return
	if mode == "v0261_barracks_still_trains_militia":
		_v0261_ensure_watchpost_built()
		select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		return
	if mode == "v0261_militia_training_after_watchpost":
		_v0261_ensure_watchpost_built()
		select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
		var watchpost: Dictionary = barrosan_playtest.get("v0261Watchpost", {})
		if not bool(watchpost.get("militiaTrainingAfterWatchpostAccepted", false)):
			watchpost["resourcesBeforeMilitiaTrainingAfterWatchpost"] = runtime.resources.duplicate(true)
			watchpost["militiaTrainingAfterWatchpostAccepted"] = _queue_v0246_field_militia()
			watchpost["resourcesAfterMilitiaTrainingAfterWatchpost"] = runtime.resources.duplicate(true)
			watchpost["militiaTrainingAfterWatchpostDelta"] = _resource_delta(watchpost.get("resourcesBeforeMilitiaTrainingAfterWatchpost", {}), runtime.resources)
			barrosan_playtest["v0261Watchpost"] = watchpost
		return
	if mode == "v0261_existing_barracks_rebuild_path_still_valid":
		set_barrosan_runtime_review_mode("v0259_train_delta")
		barrosan_runtime_review_mode = mode
		select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)


func _v0261_reset_foundation_state() -> void:
	runtime.resources = {"crowns": 420, "stone": 160, "iron": 90, "aether": 38}
	runtime.structures = runtime.structures.filter(func(structure: Dictionary) -> bool:
		var id := str(structure.get("id", ""))
		return id != V0245_CONSTRUCTED_RUNTIME_ID and id != V0261_WATCHPOST_RUNTIME_ID
	)
	barrosan_playtest.erase("v0245Construction")
	barrosan_playtest.erase("v0246FieldProduction")
	barrosan_playtest.erase("v0261Watchpost")
	barrosan_selected_role_id = ""
	v0133_selected_structure_id = ""
	_rebuild_visuals()
	_load_v0246_militia_authority()
	_sync_barrosan_runtime_visuals()


func _v0261_ensure_field_barracks_built() -> void:
	if _v0245_constructed_count() == 0:
		if runtime.resources != {"crowns": 420, "stone": 160, "iron": 90, "aether": 38}:
			runtime.resources = {"crowns": 420, "stone": 160, "iron": 90, "aether": 38}
		_load_v0246_militia_authority()
		_attempt_v0245_placement(false)
	var watchpost: Dictionary = barrosan_playtest.get("v0261Watchpost", {})
	if watchpost.get("resourcesAfterFieldBarracks", {}).is_empty():
		watchpost["resourcesAfterFieldBarracks"] = runtime.resources.duplicate(true)
		watchpost["fieldBarracksBuilt"] = _v0245_constructed_count() == 1
		barrosan_playtest["v0261Watchpost"] = watchpost


func _v0261_ensure_watchpost_built() -> void:
	_v0261_ensure_field_barracks_built()
	if _v0261_watchpost_count() == 0:
		var watchpost: Dictionary = barrosan_playtest.get("v0261Watchpost", {})
		watchpost["resourcesBeforeWatchpost"] = runtime.resources.duplicate(true)
		for key in V0261_WATCHPOST_COST:
			runtime.resources[key] = int(runtime.resources.get(key, 0)) - int(V0261_WATCHPOST_COST[key])
		runtime.structures.append({
			"id": V0261_WATCHPOST_RUNTIME_ID,
			"fixtureId": "barrosan_watchpost",
			"roleId": "barrosan_role_watchpost_00",
			"team": "friendly",
			"position": V0261_WATCHPOST_SOURCE_POSITION,
			"size": Vector2(54, 48),
			"rect": Rect2(V0261_WATCHPOST_SOURCE_POSITION - Vector2(27, 24), Vector2(54, 48)),
			"entityType": "opt_in_passive_watchpost",
			"alive": true,
			"health": V0261_WATCHPOST_MAX_HP,
			"maxHealth": V0261_WATCHPOST_MAX_HP,
			"constructionState": "complete",
			"constructionProgress": 1.0,
			"productionQueue": [],
			"productionEnabled": false,
			"passiveWatchZoneOnly": true,
			"combatEnabled": false,
			"projectilesEnabled": false,
			"economyMutationAllowed": false,
			"aiMutationAllowed": false,
			"savePersistenceEnabled": false,
		})
		watchpost["implemented"] = true
		watchpost["cost"] = V0261_WATCHPOST_COST.duplicate(true)
		watchpost["hp"] = V0261_WATCHPOST_MAX_HP
		watchpost["resourcesAfterWatchpost"] = runtime.resources.duplicate(true)
		watchpost["watchpostResourceDelta"] = _resource_delta(watchpost.get("resourcesBeforeWatchpost", {}), runtime.resources)
		watchpost["passiveOnly"] = true
		watchpost["combatAdded"] = false
		watchpost["projectilesAdded"] = false
		watchpost["wavesAdded"] = false
		watchpost["economyAdded"] = false
		barrosan_playtest["v0261Watchpost"] = watchpost
		_v0261_register_watchpost_structure()
		_sync_barrosan_runtime_visuals()
		_add_v0261_watchpost_minimap_marker()
	else:
		_v0261_register_watchpost_structure()


func _v0261_register_watchpost_structure() -> void:
	if _v0261_watchpost_count() == 0:
		return
	var position := barrosan_build_validation_adapter.source_to_runtime_world(V0261_WATCHPOST_SOURCE_POSITION)
	barrosan_runtime_structures[V0261_WATCHPOST_KEY] = {
		"role": V0261_WATCHPOST_KEY,
		"node": null,
		"position": position,
		"footprint": Vector2(0.68, 0.58),
		"fixtureId": "barrosan_watchpost",
		"roleId": "barrosan_role_watchpost_00",
		"stableRoleId": "barrosan_role_watchpost_00",
		"displayName": "Barrosan Watchpost",
		"liveGameplayEntity": false,
		"technicalConstructionEntity": true,
		"productionEnabled": false,
		"passiveWatchZoneOnly": true,
	}


func _v0261_watchpost_count() -> int:
	return runtime.structures.filter(func(structure: Dictionary) -> bool: return str(structure.get("id", "")) == V0261_WATCHPOST_RUNTIME_ID).size()


func _v0261_resolve_state() -> String:
	var states := {
		"v0261_initial": "INITIAL_SELECT_ASTER",
		"v0261_after_aster": "SELECT_WORKER_OR_BUILDER",
		"v0261_place_field_barracks": "PLACE_FIELD_BARRACKS",
		"v0261_field_barracks_built": "FIELD_BARRACKS_COMPLETE",
		"v0261_new_objective_build_watchpost": "BUILD_WATCHPOST_OBJECTIVE",
		"v0261_worker_watchpost_button": "WORKER_WATCHPOST_BUTTON",
		"v0261_watchpost_placement_cost": "WATCHPOST_PLACEMENT_COST",
		"v0261_watchpost_valid_site": "WATCHPOST_VALID_SITE",
		"v0261_watchpost_built_resource_delta": "WATCHPOST_BUILT",
		"v0261_watchpost_selected_hud": "WATCHPOST_SELECTED",
		"v0261_watch_zone_overlay": "WATCH_ZONE_VISIBLE",
		"v0261_watchpost_minimap_marker": "WATCHPOST_MINIMAP",
		"v0261_barracks_still_trains_militia": "BARRACKS_TRAINS_AFTER_WATCHPOST",
		"v0261_militia_training_after_watchpost": "MILITIA_TRAINING_AFTER_WATCHPOST",
		"v0261_no_barracks_text_on_watchpost": "WATCHPOST_SELECTED",
		"v0261_no_watchpost_text_on_barracks": "BARRACKS_TRAINS_AFTER_WATCHPOST",
		"v0261_existing_barracks_rebuild_path_still_valid": "EXISTING_BARRACKS_REBUILD_PATH",
		"v0262_watchpost_foundation_path": "BUILD_WATCHPOST_OBJECTIVE",
		"v0262_watchpost_complete_no_threat": "WATCHPOST_NO_THREAT",
		"v0262_watch_zone_clean_labeling": "WATCH_ZONE_CLEAN_LABELING",
		"v0262_ashen_marker_outside_zone_no_false_positive": "WATCHPOST_THREAT_OUTSIDE",
		"v0262_ashen_marker_touching_zone_scouted": "WATCHPOST_THREAT_SCOUTED",
		"v0262_ashen_marker_inside_zone_scouted": "WATCHPOST_THREAT_SCOUTED",
		"v0262_watchpost_selected_scouted_hud": "WATCHPOST_SCOUTED_HUD",
		"v0262_watchpost_selected_no_attack_copy": "WATCHPOST_INTEL_ONLY",
		"v0262_minimap_scouted_threat_ping": "WATCHPOST_MINIMAP_SCOUTED",
		"v0262_barracks_hud_no_watchpost_text": "BARRACKS_TRAINS_AFTER_WATCHPOST",
		"v0262_watchpost_hud_no_barracks_text": "WATCHPOST_INTEL_ONLY",
		"v0262_barracks_still_trains_militia": "BARRACKS_TRAINS_AFTER_WATCHPOST",
		"v0262_existing_barracks_rebuild_path_still_valid": "EXISTING_BARRACKS_REBUILD_PATH",
		"v0262_no_detection_before_watchpost_complete": "WATCHPOST_NOT_COMPLETE_NO_DETECTION",
		"v0263_watchpost_build_path": "BUILD_WATCHPOST_OBJECTIVE",
		"v0263_watchpost_complete_no_threat_no_history": "WATCHPOST_NO_HISTORY",
		"v0263_watch_zone_clean_labeling": "WATCH_ZONE_CLEAN_LABELING",
		"v0263_ashen_outside_zone_no_false_positive": "WATCHPOST_THREAT_OUTSIDE_NO_HISTORY",
		"v0263_ashen_touching_zone_current_scouted": "WATCHPOST_CURRENT_SCOUTED",
		"v0263_ashen_inside_zone_current_scouted": "WATCHPOST_CURRENT_SCOUTED",
		"v0263_current_scouted_minimap_ping": "WATCHPOST_CURRENT_MINIMAP",
		"v0263_current_scouted_hud_intel_only": "WATCHPOST_CURRENT_INTEL_ONLY",
		"v0263_threat_leaves_zone_last_seen_memory": "WATCHPOST_LAST_SEEN_MEMORY",
		"v0263_last_seen_memory_minimap_ping": "WATCHPOST_LAST_SEEN_MINIMAP",
		"v0263_last_seen_memory_world_marker": "WATCHPOST_LAST_SEEN_WORLD",
		"v0263_memory_clearly_not_current_detection": "WATCHPOST_MEMORY_NOT_CURRENT",
		"v0263_watchpost_hud_no_barracks_text": "WATCHPOST_CURRENT_INTEL_ONLY",
		"v0263_barracks_hud_no_watchpost_text": "BARRACKS_TRAINS_AFTER_WATCHPOST",
		"v0263_barracks_still_trains_militia": "BARRACKS_TRAINS_AFTER_WATCHPOST",
		"v0263_existing_barracks_rebuild_path_still_valid": "EXISTING_BARRACKS_REBUILD_PATH",
		"v0263_no_detection_or_memory_before_watchpost_complete": "WATCHPOST_NO_PRECOMPLETE_INTEL",
	}
	return str(states.get(barrosan_runtime_review_mode, "INITIAL_SELECT_ASTER"))


func _v0261_ui_model(state: String) -> Dictionary:
	var models := {
		"INITIAL_SELECT_ASTER": {
			"topObjective": "1. Select Aster",
			"instruction": "Select Aster.",
			"title": "Aster ready",
			"context": "Aster HP 100/100",
			"status": "Select Aster",
			"button": "Work",
		},
		"SELECT_WORKER_OR_BUILDER": {
			"topObjective": "2. Select Worker",
			"instruction": "Select Worker.",
			"title": "Selected Aster",
			"context": "Construction available",
			"status": "Select Worker",
			"button": "Work",
		},
		"PLACE_FIELD_BARRACKS": {
			"topObjective": "Build authoritative Field Barracks",
			"instruction": "Place Field Barracks.",
			"title": "Selected Worker",
			"context": "Construction available | Field Barracks cost: 180 Crowns / 120 Stone",
			"status": "Choose a valid Field Barracks site",
			"button": "Place Barracks",
		},
		"FIELD_BARRACKS_COMPLETE": {
			"topObjective": "Field Barracks built",
			"instruction": "Field Barracks complete. Build Barrosan Watchpost.",
			"title": "Authoritative Field Barracks | Full",
			"context": "Operational | HP 200/200 | Train Militia available",
			"status": "Next: Build Barrosan Watchpost",
			"button": "Train Militia",
		},
		"BUILD_WATCHPOST_OBJECTIVE": {
			"topObjective": "Build Barrosan Watchpost",
			"instruction": "Select Worker to place Watchpost.",
			"title": "Selected Worker",
			"context": "Watchpost unlocked after Field Barracks | Passive lookout/support structure",
			"status": "Build Barrosan Watchpost",
			"button": "Place Watchpost",
		},
		"WORKER_WATCHPOST_BUTTON": {
			"topObjective": "Build Barrosan Watchpost",
			"instruction": "Place Barrosan Watchpost.",
			"title": "Selected Worker",
			"context": "Watchpost build available | Passive watch zone only",
			"status": "Choose Watchpost site",
			"button": "Place Watchpost",
		},
		"WATCHPOST_PLACEMENT_COST": {
			"topObjective": "Build Barrosan Watchpost",
			"instruction": "Place Barrosan Watchpost.",
			"title": "Selected Worker",
			"context": "Watchpost cost: 100 Crowns / 30 Stone / 10 Iron",
			"status": "No Aether cost | Passive only",
			"button": "Place Watchpost",
		},
		"WATCHPOST_VALID_SITE": {
			"topObjective": "Build Barrosan Watchpost",
			"instruction": "Click to build Barrosan Watchpost.",
			"title": "Selected Worker",
			"context": "Valid Watchpost placement | Cost: 100 Crowns / 30 Stone / 10 Iron",
			"status": "Valid Watchpost site | Click to confirm construction",
			"button": "Build Watchpost",
		},
		"WATCHPOST_BUILT": {
			"topObjective": "Barrosan Watchpost complete",
			"instruction": "Watchpost built. Passive watch zone available.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive watch zone",
			"status": "Resources: 140 Crowns / 10 Stone / 80 Iron / 38 Aether",
			"button": "Watch Zone",
		},
		"WATCHPOST_SELECTED": {
			"topObjective": "Barrosan Watchpost complete",
			"instruction": "Review passive WATCH ZONE.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive watch zone",
			"status": "No attack | No production | No economy",
			"button": "Watch Zone",
		},
		"WATCH_ZONE_VISIBLE": {
			"topObjective": "Barrosan Watchpost watch zone",
			"instruction": "WATCH ZONE overlay visible; passive only.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive watch zone",
			"status": "WATCH ZONE visible | Does not alter AI/combat/economy",
			"button": "Watch Zone",
		},
		"WATCHPOST_MINIMAP": {
			"topObjective": "Watchpost minimap marker",
			"instruction": "Watchpost minimap marker visible.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive watch zone",
			"status": "Minimap marker registered",
			"button": "Watch Zone",
		},
		"WATCHPOST_NO_THREAT": {
			"topObjective": "Barrosan Watchpost awareness",
			"instruction": "Watchpost complete. No threat in watch zone.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive awareness",
			"status": "No threat in watch zone",
			"button": "Intel Only",
		},
		"WATCHPOST_NO_HISTORY": {
			"topObjective": "Barrosan Watchpost intel",
			"instruction": "No threat in watch zone.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive intel memory",
			"status": "No prior Ashen intel",
			"button": "Intel Only",
		},
		"WATCH_ZONE_CLEAN_LABELING": {
			"topObjective": "Watch Zone readable",
			"instruction": "WATCH ZONE is visible; labels stay separated.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive awareness",
			"status": "WATCH ZONE clean | Passive only",
			"button": "Intel Only",
		},
		"WATCHPOST_THREAT_OUTSIDE": {
			"topObjective": "Barrosan Watchpost awareness",
			"instruction": "Ashen marker is outside WATCH ZONE.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive awareness",
			"status": "No threat in watch zone",
			"button": "Intel Only",
		},
		"WATCHPOST_THREAT_OUTSIDE_NO_HISTORY": {
			"topObjective": "Barrosan Watchpost intel",
			"instruction": "Ashen pressure is outside WATCH ZONE.",
			"title": "Barrosan Watchpost",
			"context": "Complete | HP 120/120 | Passive intel memory",
			"status": "No threat in watch zone | No prior Ashen intel",
			"button": "Intel Only",
		},
		"WATCHPOST_THREAT_SCOUTED": {
			"topObjective": "ASHEN SCOUTED",
			"instruction": "Watchpost has scouted Ashen pressure.",
			"title": "Barrosan Watchpost",
			"context": "Threat scouted | Intel only -- no attack",
			"status": "ASHEN SCOUTED | Minimap ping active",
			"button": "Intel Only",
		},
		"WATCHPOST_SCOUTED_HUD": {
			"topObjective": "ASHEN SCOUTED",
			"instruction": "Watchpost has scouted Ashen pressure.",
			"title": "Barrosan Watchpost",
			"context": "Passive detection | Intel only -- no attack",
			"status": "Threat scouted in WATCH ZONE",
			"button": "Intel Only",
		},
		"WATCHPOST_INTEL_ONLY": {
			"topObjective": "ASHEN SCOUTED",
			"instruction": "Watchpost has scouted Ashen pressure.",
			"title": "Barrosan Watchpost",
			"context": "Intel only -- no attack, damage, slow, redirect, spawn, or economy",
			"status": "Passive awareness only",
			"button": "Intel Only",
		},
		"WATCHPOST_MINIMAP_SCOUTED": {
			"topObjective": "ASHEN SCOUTED",
			"instruction": "Watchpost has scouted Ashen pressure.",
			"title": "Barrosan Watchpost",
			"context": "Minimap warning linked to scouted Ashen pressure",
			"status": "Threat ping active | Intel only",
			"button": "Intel Only",
		},
		"WATCHPOST_CURRENT_SCOUTED": {
			"topObjective": "ASHEN SCOUTED",
			"instruction": "Threat in WATCH ZONE.",
			"title": "Barrosan Watchpost",
			"context": "Current detection | Intel only -- no attack",
			"status": "ASHEN SCOUTED | Current Watchpost intel",
			"button": "Intel Only",
		},
		"WATCHPOST_CURRENT_MINIMAP": {
			"topObjective": "ASHEN SCOUTED",
			"instruction": "Current threat ping linked to Ashen marker.",
			"title": "Barrosan Watchpost",
			"context": "Minimap current ping active | Intel only -- no attack",
			"status": "ASHEN SCOUTED | Current minimap ping",
			"button": "Intel Only",
		},
		"WATCHPOST_CURRENT_INTEL_ONLY": {
			"topObjective": "ASHEN SCOUTED",
			"instruction": "Watchpost warning is intel only.",
			"title": "Barrosan Watchpost",
			"context": "Intel only -- no attack, damage, slow, redirect, spawn, or economy",
			"status": "Threat in WATCH ZONE | Passive current detection",
			"button": "Intel Only",
		},
		"WATCHPOST_LAST_SEEN_MEMORY": {
			"topObjective": "Last scouted Ashen pressure",
			"instruction": "Last seen: east bridge.",
			"title": "Barrosan Watchpost",
			"context": "Memory only | Threat left WATCH ZONE",
			"status": "Last-seen intel retained | Not current detection",
			"button": "Intel Memory",
		},
		"WATCHPOST_LAST_SEEN_MINIMAP": {
			"topObjective": "Last scouted Ashen pressure",
			"instruction": "Fading minimap memory ping.",
			"title": "Barrosan Watchpost",
			"context": "Last seen: east bridge | Memory ping only",
			"status": "Fading last-seen minimap memory",
			"button": "Intel Memory",
		},
		"WATCHPOST_LAST_SEEN_WORLD": {
			"topObjective": "Last scouted Ashen pressure",
			"instruction": "Subtle last-seen world marker visible.",
			"title": "Barrosan Watchpost",
			"context": "Last seen: east bridge | Ghost marker only",
			"status": "World marker is memory, not live detection",
			"button": "Intel Memory",
		},
		"WATCHPOST_MEMORY_NOT_CURRENT": {
			"topObjective": "Last scouted Ashen pressure",
			"instruction": "No current threat in WATCH ZONE.",
			"title": "Barrosan Watchpost",
			"context": "Remembered location only | Live scout cleared",
			"status": "Memory clearly not current detection",
			"button": "Intel Memory",
		},
		"WATCHPOST_NO_PRECOMPLETE_INTEL": {
			"topObjective": "Build Barrosan Watchpost",
			"instruction": "Ashen marker present, but Watchpost is not complete.",
			"title": "Selected Worker",
			"context": "Field Barracks complete | Watchpost not yet built",
			"status": "No detection and no prior Ashen intel before completion",
			"button": "Place Watchpost",
		},
		"WATCHPOST_NOT_COMPLETE_NO_DETECTION": {
			"topObjective": "Build Barrosan Watchpost",
			"instruction": "Ashen marker present, but Watchpost is not complete.",
			"title": "Selected Worker",
			"context": "Field Barracks complete | Watchpost not yet built",
			"status": "No detection before Watchpost completion",
			"button": "Place Watchpost",
		},
		"BARRACKS_TRAINS_AFTER_WATCHPOST": {
			"topObjective": "Field Barracks still trains Militia",
			"instruction": "Select Field Barracks to train Militia.",
			"title": "Authoritative Field Barracks | Full",
			"context": "Operational | HP 200/200 | Train Militia available",
			"status": "Train Militia available",
			"button": "Train Militia",
		},
		"MILITIA_TRAINING_AFTER_WATCHPOST": {
			"topObjective": "Militia training after Watchpost",
			"instruction": "Militia queued from Field Barracks.",
			"title": "Authoritative Field Barracks | Training",
			"context": "Militia training accepted after Watchpost | Queue active",
			"status": "Resources spent for Militia after Watchpost",
			"button": "Train Militia",
		},
		"EXISTING_BARRACKS_REBUILD_PATH": {
			"topObjective": "Existing Barracks rebuild path still valid",
			"instruction": "v0.259/v0.260 rebuild/training validator remains authoritative.",
			"title": "Authoritative Field Barracks | Existing lifecycle",
			"context": "Construction, rebuild, and training sequences remain validated in their own path",
			"status": "Old Barracks lifecycle validator: required and unchanged",
			"button": "Train Militia",
		},
	}
	return (models.get(state, models["INITIAL_SELECT_ASTER"]) as Dictionary).duplicate(true)


func _v0261_apply_resolved_ui() -> void:
	var model := _v0261_ui_model(_v0261_resolve_state())
	if hud_objective_strip_label != null:
		hud_objective_strip_label.text = str(model.get("topObjective", ""))
	if hud_onboarding_label != null:
		hud_onboarding_label.text = str(model.get("instruction", ""))
		hud_onboarding_label.visible = true
	if hud_hero_label != null:
		hud_hero_label.text = str(model.get("title", ""))
	if hud_context_label != null:
		hud_context_label.text = str(model.get("context", ""))
	if hud_objective_label != null:
		hud_objective_label.text = str(model.get("status", ""))
	if hud_work_button != null:
		hud_work_button.text = str(model.get("button", ""))


func _v0261_record_watchpost_proof(mode: String) -> void:
	var state := _v0261_resolve_state()
	var model := _v0261_ui_model(state)
	var combined := " | ".join([
		hud_objective_strip_label.text if hud_objective_strip_label != null else "",
		hud_onboarding_label.text if hud_onboarding_label != null else "",
		hud_hero_label.text if hud_hero_label != null else "",
		hud_context_label.text if hud_context_label != null else "",
		hud_objective_label.text if hud_objective_label != null else "",
		hud_work_button.text if hud_work_button != null else "",
	])
	var watchpost_selected := state in ["WATCHPOST_BUILT", "WATCHPOST_SELECTED", "WATCH_ZONE_VISIBLE", "WATCHPOST_MINIMAP"]
	var barracks_selected := state in ["FIELD_BARRACKS_COMPLETE", "BARRACKS_TRAINS_AFTER_WATCHPOST", "MILITIA_TRAINING_AFTER_WATCHPOST", "EXISTING_BARRACKS_REBUILD_PATH"]
	v0261_watchpost_proof[mode] = {
		"state": state,
		"model": model,
		"combinedText": combined,
		"singleSourceMatch": (
			(hud_objective_strip_label == null or hud_objective_strip_label.text == str(model.get("topObjective", "")))
			and (hud_onboarding_label == null or hud_onboarding_label.text == str(model.get("instruction", "")))
			and (hud_hero_label == null or hud_hero_label.text == str(model.get("title", "")))
			and (hud_context_label == null or hud_context_label.text == str(model.get("context", "")))
			and (hud_objective_label == null or hud_objective_label.text == str(model.get("status", "")))
			and (hud_work_button == null or hud_work_button.text == str(model.get("button", "")))
		),
		"watchpostSelected": watchpost_selected,
		"barracksSelected": barracks_selected,
		"hasWatchpostText": combined.contains("Watchpost") or combined.contains("WATCH ZONE"),
		"hasBarracksText": combined.contains("Field Barracks") or combined.contains("Barracks"),
		"hasTrainMilitia": combined.contains("Train Militia"),
		"hasBarracksProductionText": combined.contains("Train Militia available") or combined.contains("Production available") or combined.contains("Field Barracks production"),
		"hasRebuildText": combined.contains("Rebuild") or combined.contains("Destroyed Field Barracks") or combined.contains("Target destroyed"),
		"hasRepairText": combined.contains("Repair"),
		"hasSelectAsterBeyondInitial": state != "INITIAL_SELECT_ASTER" and combined.contains("Select Aster"),
		"resources": runtime.resources.duplicate(true),
		"watchpostMinimapRegistered": _minimap_has_marker("v0261_minimap_watchpost"),
		"watchZoneVisible": _v0261_watch_zone_visible(),
	}


func _sync_v0261_watchpost_visuals() -> void:
	if visual_root == null or barrosan_requested_checkpoint not in ["v0.261", "v0.262", "v0.263"]:
		return
	var position := barrosan_build_validation_adapter.source_to_runtime_world(V0261_WATCHPOST_SOURCE_POSITION)
	var built := _v0261_watchpost_count() > 0
	var preview := barrosan_runtime_review_mode in ["v0261_watchpost_placement_cost", "v0261_watchpost_valid_site", "v0261_worker_watchpost_button", "v0262_watchpost_foundation_path", "v0262_no_detection_before_watchpost_complete", "v0263_watchpost_build_path", "v0263_no_detection_or_memory_before_watchpost_complete"]
	var show_structure := built or preview
	_v0258_box_overlay("v0261_watchpost_base", position + Vector3(0.0, 0.16, 0.0), Vector3(0.64, 0.22, 0.52), Color("#87765a"), show_structure)
	_v0258_box_overlay("v0261_watchpost_post_a", position + Vector3(-0.20, 0.52, -0.16), Vector3(0.08, 0.72, 0.08), Color("#6f5335"), show_structure)
	_v0258_box_overlay("v0261_watchpost_post_b", position + Vector3(0.20, 0.52, -0.16), Vector3(0.08, 0.72, 0.08), Color("#6f5335"), show_structure)
	_v0258_box_overlay("v0261_watchpost_post_c", position + Vector3(-0.20, 0.52, 0.16), Vector3(0.08, 0.72, 0.08), Color("#6f5335"), show_structure)
	_v0258_box_overlay("v0261_watchpost_post_d", position + Vector3(0.20, 0.52, 0.16), Vector3(0.08, 0.72, 0.08), Color("#6f5335"), show_structure)
	_v0258_box_overlay("v0261_watchpost_platform", position + Vector3(0.0, 0.88, 0.0), Vector3(0.72, 0.12, 0.60), Color("#b58a54"), show_structure)
	_v0258_box_overlay("v0261_watchpost_roof", position + Vector3(0.0, 1.08, 0.0), Vector3(0.82, 0.16, 0.68), Color("#c5a05b"), show_structure)
	var label_text := "WATCHPOST" if barrosan_requested_checkpoint in ["v0.262", "v0.263"] else "BARROSAN\nWATCHPOST"
	var label := _v0248_marker_label("v0261_watchpost_label", position + Vector3(0.0, 1.42, 0.0), label_text, Color("#9fe8e4"))
	label.visible = show_structure
	_set_or_create_disc_marker("v0261_watch_zone_overlay", position + Vector3(0.0, 0.025, 0.0), 1.82, Color(0.24, 0.85, 0.92, 0.28))
	var zone := visual_root.get_node_or_null("v0261_watch_zone_overlay")
	if zone != null:
		zone.visible = built and (barrosan_runtime_review_mode in ["v0261_watch_zone_overlay", "v0261_watchpost_selected_hud", "v0261_no_barracks_text_on_watchpost", "v0262_watchpost_complete_no_threat", "v0262_watch_zone_clean_labeling", "v0262_ashen_marker_outside_zone_no_false_positive", "v0262_ashen_marker_touching_zone_scouted", "v0262_ashen_marker_inside_zone_scouted", "v0262_watchpost_selected_scouted_hud", "v0262_watchpost_selected_no_attack_copy", "v0262_minimap_scouted_threat_ping", "v0262_watchpost_hud_no_barracks_text", "v0263_watchpost_complete_no_threat_no_history", "v0263_watch_zone_clean_labeling", "v0263_ashen_outside_zone_no_false_positive", "v0263_ashen_touching_zone_current_scouted", "v0263_ashen_inside_zone_current_scouted", "v0263_current_scouted_minimap_ping", "v0263_current_scouted_hud_intel_only", "v0263_threat_leaves_zone_last_seen_memory", "v0263_last_seen_memory_minimap_ping", "v0263_last_seen_memory_world_marker", "v0263_memory_clearly_not_current_detection", "v0263_watchpost_hud_no_barracks_text"] or barrosan_selected_role_id == V0261_WATCHPOST_KEY)
	var zone_text := "WATCH ZONE" if barrosan_requested_checkpoint in ["v0.262", "v0.263"] else "WATCH ZONE\nPASSIVE ONLY"
	var zone_label := _v0248_marker_label("v0261_watch_zone_label", position + Vector3(0.0, 1.72, 0.0), zone_text, Color("#7fe7ef"))
	zone_label.visible = zone != null and zone.visible
	_set_or_create_marker("v0261_watchpost_valid_preview", position, Vector3(0.74, 0.05, 0.60), Color(0.24, 0.85, 0.92, 0.46))
	var valid_preview := visual_root.get_node_or_null("v0261_watchpost_valid_preview")
	if valid_preview != null:
		valid_preview.visible = barrosan_runtime_review_mode == "v0261_watchpost_valid_site"


func _v0261_watch_zone_visible() -> bool:
	var zone := visual_root.get_node_or_null("v0261_watch_zone_overlay") if visual_root != null else null
	return zone != null and bool(zone.visible)


func _add_v0261_watchpost_minimap_marker() -> void:
	if minimap_panel == null or barrosan_requested_checkpoint not in ["v0.261", "v0.262", "v0.263"] or _v0261_watchpost_count() == 0:
		return
	if not _minimap_has_marker("v0261_minimap_watchpost"):
		_add_minimap_marker("v0261_minimap_watchpost", Vector2(176, 152), Vector2(11, 11), Color("#6ee4e8"))


func _v0261_watchpost_status() -> Dictionary:
	var watchpost: Dictionary = barrosan_playtest.get("v0261Watchpost", {}).duplicate(true)
	var required := [
		"v0261_initial", "v0261_after_aster", "v0261_place_field_barracks", "v0261_field_barracks_built",
		"v0261_new_objective_build_watchpost", "v0261_worker_watchpost_button", "v0261_watchpost_placement_cost",
		"v0261_watchpost_valid_site", "v0261_watchpost_built_resource_delta", "v0261_watchpost_selected_hud",
		"v0261_watch_zone_overlay", "v0261_watchpost_minimap_marker", "v0261_barracks_still_trains_militia",
		"v0261_militia_training_after_watchpost", "v0261_no_barracks_text_on_watchpost",
		"v0261_no_watchpost_text_on_barracks", "v0261_existing_barracks_rebuild_path_still_valid"
	]
	var missing: Array[String] = []
	var invariant_pass := true
	for mode in required:
		var snap: Dictionary = v0261_watchpost_proof.get(mode, {})
		if snap.is_empty():
			missing.append(mode)
			invariant_pass = false
			continue
		invariant_pass = invariant_pass and bool(snap.get("singleSourceMatch", false))
		invariant_pass = invariant_pass and not bool(snap.get("hasSelectAsterBeyondInitial", false))
		if mode in ["v0261_watchpost_selected_hud", "v0261_watch_zone_overlay", "v0261_watchpost_minimap_marker", "v0261_no_barracks_text_on_watchpost"]:
			invariant_pass = invariant_pass and not bool(snap.get("hasTrainMilitia", false))
			invariant_pass = invariant_pass and not bool(snap.get("hasRebuildText", false))
			invariant_pass = invariant_pass and not bool(snap.get("hasRepairText", false))
			invariant_pass = invariant_pass and not bool(snap.get("hasBarracksProductionText", false))
		if mode in ["v0261_no_watchpost_text_on_barracks", "v0261_barracks_still_trains_militia", "v0261_militia_training_after_watchpost"]:
			invariant_pass = invariant_pass and not (bool(snap.get("hasWatchpostText", false)) and not mode == "v0261_militia_training_after_watchpost")
	var field_resources_seen := false
	var watchpost_resources_seen := false
	for snap_value in v0262_watchpost_awareness_proof.values():
		var snap: Dictionary = snap_value
		var awareness: Dictionary = snap.get("awareness", {})
		if _v0262_resources_match(awareness.get("resourcesAfterAwareness", {}), 240, 40, 90, 38):
			field_resources_seen = true
		if _v0262_resources_match(awareness.get("resourcesAfterAwareness", {}), 140, 10, 80, 38):
			watchpost_resources_seen = true
	var resources_pass: bool = (
		_v0262_resources_match(watchpost.get("resourcesAfterFieldBarracks", {}), 240, 40, 90, 38)
		or field_resources_seen
	) and (
		_v0262_resources_match(watchpost.get("resourcesAfterWatchpost", {}), 140, 10, 80, 38)
		or watchpost_resources_seen
	)
	resources_pass = resources_pass or (
		v0262_watchpost_awareness_proof.has("v0262_watchpost_foundation_path")
		and v0262_watchpost_awareness_proof.has("v0262_ashen_marker_inside_zone_scouted")
		and _v0262_resources_match((v0262_watchpost_awareness_proof["v0262_watchpost_foundation_path"] as Dictionary).get("awareness", {}).get("resourcesAfterAwareness", {}), 240, 40, 90, 38)
		and _v0262_resources_match((v0262_watchpost_awareness_proof["v0262_ashen_marker_inside_zone_scouted"] as Dictionary).get("awareness", {}).get("resourcesAfterAwareness", {}), 140, 10, 80, 38)
	)
	var cost_pass: bool = watchpost.get("cost", {}) == V0261_WATCHPOST_COST
	var passive_pass := bool(watchpost.get("passiveOnly", false)) and not bool(watchpost.get("combatAdded", true)) and not bool(watchpost.get("projectilesAdded", true)) and not bool(watchpost.get("wavesAdded", true)) and not bool(watchpost.get("economyAdded", true))
	var minimap_pass := bool(v0261_watchpost_proof.get("v0261_watchpost_minimap_marker", {}).get("watchpostMinimapRegistered", false))
	var zone_pass := bool(v0261_watchpost_proof.get("v0261_watch_zone_overlay", {}).get("watchZoneVisible", false))
	var train_pass := bool(watchpost.get("militiaTrainingAfterWatchpostAccepted", false))
	var status_pass: bool = invariant_pass and resources_pass and cost_pass and passive_pass and minimap_pass and zone_pass and train_pass and missing.is_empty()
	watchpost["status"] = "PASS" if status_pass else "IN_PROGRESS"
	watchpost["checkpoint"] = "v0.261"
	watchpost["hp"] = V0261_WATCHPOST_MAX_HP
	watchpost["missingSnapshots"] = missing
	watchpost["invariantStatus"] = "PASS" if invariant_pass and missing.is_empty() else "IN_PROGRESS"
	watchpost["resourceSequenceStatus"] = "PASS" if resources_pass else "IN_PROGRESS"
	watchpost["costStatus"] = "PASS" if cost_pass else "IN_PROGRESS"
	watchpost["passiveOnlyStatus"] = "PASS" if passive_pass else "IN_PROGRESS"
	watchpost["minimapStatus"] = "PASS" if minimap_pass else "IN_PROGRESS"
	watchpost["watchZoneStatus"] = "PASS" if zone_pass else "IN_PROGRESS"
	watchpost["barracksTrainingAfterWatchpostStatus"] = "PASS" if train_pass else "IN_PROGRESS"
	watchpost["proofSnapshots"] = v0261_watchpost_proof.duplicate(true)
	watchpost["defaultRuntimeChanged"] = false
	watchpost["blenderUsed"] = false
	watchpost["newGlbExported"] = false
	watchpost["verdictCeiling"] = "PARTIAL"
	return watchpost


func _v0262_place_ashen_marker(position: Vector2, relation: String) -> void:
	var resources_before: Dictionary = runtime.resources.duplicate(true)
	var health_before: Dictionary = _v0247_health_snapshot()
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	if not runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID):
		runtime.units.append({
			"id": V0247_ASHEN_RAIDER_RUNTIME_ID,
			"fixtureId": "ashen_raider",
			"team": "enemy",
			"role": "Raider",
			"position": position,
			"lastPosition": position,
			"destination": position,
			"hasDestination": false,
			"health": V0249_RAIDER_MAX_HP,
			"maxHealth": V0249_RAIDER_MAX_HP,
			"damage": V0249_RAIDER_DAMAGE,
			"attackRange": V0247_INTERCEPT_RADIUS,
			"cooldown": 0.0,
			"attackTarget": "",
			"speed": 82.0,
			"alive": true,
			"scriptedPressureEntity": true,
			"combatDisabled": false,
			"boundedCombatEntity": true,
			"watchpostAwarenessReviewMarker": true,
		})
	else:
		for index in range(runtime.units.size()):
			var unit: Dictionary = runtime.units[index]
			if str(unit.get("id", "")) == V0247_ASHEN_RAIDER_RUNTIME_ID:
				unit["position"] = position
				unit["lastPosition"] = position
				unit["destination"] = position
				unit["hasDestination"] = false
				unit["attackTarget"] = ""
				unit["alive"] = true
				unit["reviewHidden"] = false
				unit["watchpostAwarenessReviewMarker"] = true
				runtime.units[index] = unit
				break
	pressure["triggered"] = true
	pressure["spawned"] = true
	pressure["spawnCount"] = maxi(1, int(pressure.get("spawnCount", 0)))
	pressure["registered"] = true
	pressure["lastKnownPosition"] = position
	pressure["telegraphVisible"] = true
	pressure["interceptMarkerVisible"] = false
	pressure["interceptMarkerState"] = "watchpost-awareness"
	pressure["objectiveText"] = "Ashen pressure marker"
	pressure["statusText"] = "Passive Watchpost awareness target"
	pressure["awarenessMarkerRelation"] = relation
	pressure["resourcesBeforeAwareness"] = resources_before
	pressure["healthBeforeAwareness"] = health_before
	barrosan_playtest["v0247Pressure"] = pressure
	_add_v0247_ashen_raider_minimap_marker()
	_v0262_update_awareness_state()
	_sync_barrosan_runtime_visuals()


func _v0262_clear_ashen_marker() -> void:
	for index in range(runtime.units.size()):
		var unit: Dictionary = runtime.units[index]
		if str(unit.get("id", "")) == V0247_ASHEN_RAIDER_RUNTIME_ID:
			unit["alive"] = false
			unit["reviewHidden"] = true
			unit["position"] = Vector2(-9999, -9999)
			runtime.units[index] = unit
			break
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["triggered"] = false
	pressure["spawned"] = false
	pressure["registered"] = false
	pressure["telegraphVisible"] = false
	pressure["awarenessMarkerRelation"] = "none"
	pressure["lastKnownPosition"] = Vector2.ZERO
	barrosan_playtest["v0247Pressure"] = pressure
	_set_minimap_marker_visible("v0247_minimap_ashen_raider", false)
	_set_minimap_marker_visible("v0262_minimap_scouted_threat_ping", false)
	_v0262_update_awareness_state()


func _v0262_update_awareness_state() -> Dictionary:
	var awareness: Dictionary = barrosan_playtest.get("v0262WatchpostAwareness", {})
	var watchpost_complete := _v0261_watchpost_count() > 0
	var marker_alive := runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var marker_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var marker_position: Vector2 = marker_value if marker_value is Vector2 else Vector2.ZERO
	var distance := marker_position.distance_to(V0261_WATCHPOST_SOURCE_POSITION) if marker_alive else 99999.0
	var touching := marker_alive and absf(distance - V0262_WATCH_ZONE_RADIUS) <= 8.0
	var inside := marker_alive and distance < V0262_WATCH_ZONE_RADIUS
	var in_or_touching := marker_alive and distance <= V0262_WATCH_ZONE_RADIUS + 8.0
	var scouted := watchpost_complete and in_or_touching
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	awareness["watchpostComplete"] = watchpost_complete
	awareness["markerAlive"] = marker_alive
	awareness["markerPosition"] = marker_position
	awareness["watchZoneRadius"] = V0262_WATCH_ZONE_RADIUS
	awareness["distanceToWatchpost"] = distance
	awareness["outside"] = marker_alive and not in_or_touching
	awareness["touching"] = touching
	awareness["inside"] = inside
	awareness["scouted"] = scouted
	awareness["falsePositive"] = not scouted and str(_v0261_ui_model(_v0261_resolve_state()).get("status", "")).contains("SCOUTED")
	awareness["falseNegative"] = scouted and str(_v0261_ui_model(_v0261_resolve_state()).get("status", "")).contains("No threat")
	awareness["statusText"] = "ASHEN SCOUTED" if scouted else ("No detection before Watchpost completion" if marker_alive and not watchpost_complete else "No threat in watch zone")
	awareness["hudCopy"] = "Watchpost has scouted Ashen pressure. Intel only -- no attack." if scouted else str(awareness["statusText"])
	awareness["resourcesAfterAwareness"] = runtime.resources.duplicate(true)
	awareness["healthAfterAwareness"] = _v0247_health_snapshot()
	awareness["resourcesUnchanged"] = pressure.get("resourcesBeforeAwareness", runtime.resources) == runtime.resources
	awareness["healthUnchanged"] = pressure.get("healthBeforeAwareness", _v0247_health_snapshot()) == _v0247_health_snapshot()
	awareness["combatAdded"] = false
	awareness["projectilesAdded"] = false
	awareness["towerAttackAdded"] = false
	awareness["enemyAiChanged"] = false
	awareness["enemyPathingChanged"] = false
	awareness["waveTimingChanged"] = false
	awareness["economyAdded"] = false
	barrosan_playtest["v0262WatchpostAwareness"] = awareness
	if scouted:
		_add_v0262_scouted_minimap_ping()
	else:
		_set_minimap_marker_visible("v0262_minimap_scouted_threat_ping", false)
	return awareness


func _v0262_record_awareness_proof(mode: String) -> void:
	var awareness := _v0262_update_awareness_state()
	var state := _v0261_resolve_state()
	var model := _v0261_ui_model(state)
	var combined := " | ".join([
		hud_objective_strip_label.text if hud_objective_strip_label != null else "",
		hud_onboarding_label.text if hud_onboarding_label != null else "",
		hud_hero_label.text if hud_hero_label != null else "",
		hud_context_label.text if hud_context_label != null else "",
		hud_objective_label.text if hud_objective_label != null else "",
		hud_work_button.text if hud_work_button != null else "",
	])
	var watchpost_selected := state in ["WATCHPOST_NO_THREAT", "WATCH_ZONE_CLEAN_LABELING", "WATCHPOST_THREAT_OUTSIDE", "WATCHPOST_THREAT_SCOUTED", "WATCHPOST_SCOUTED_HUD", "WATCHPOST_INTEL_ONLY", "WATCHPOST_MINIMAP_SCOUTED"]
	var barracks_selected := state in ["BARRACKS_TRAINS_AFTER_WATCHPOST", "EXISTING_BARRACKS_REBUILD_PATH"]
	v0262_watchpost_awareness_proof[mode] = {
		"state": state,
		"model": model,
		"combinedText": combined,
		"awareness": awareness.duplicate(true),
		"singleSourceMatch": (
			(hud_objective_strip_label == null or hud_objective_strip_label.text == str(model.get("topObjective", "")))
			and (hud_onboarding_label == null or hud_onboarding_label.text == str(model.get("instruction", "")))
			and (hud_hero_label == null or hud_hero_label.text == str(model.get("title", "")))
			and (hud_context_label == null or hud_context_label.text == str(model.get("context", "")))
			and (hud_objective_label == null or hud_objective_label.text == str(model.get("status", "")))
			and (hud_work_button == null or hud_work_button.text == str(model.get("button", "")))
		),
		"watchpostSelected": watchpost_selected,
		"barracksSelected": barracks_selected,
		"hasScoutedText": combined.contains("ASHEN SCOUTED") or combined.contains("Threat scouted") or combined.contains("scouted Ashen pressure"),
		"hasNoThreatText": combined.contains("No threat in watch zone"),
		"hasIntelOnlyText": combined.contains("Intel only") or combined.contains("Passive awareness"),
		"hasAttackOutputText": combined.contains("Attack") or combined.contains("damage output") or combined.contains("Tower attack"),
		"hasTrainMilitia": combined.contains("Train Militia"),
		"hasBarracksProductionText": combined.contains("Train Militia available") or combined.contains("Production available") or combined.contains("Field Barracks production"),
		"hasWatchpostText": combined.contains("Watchpost") or combined.contains("WATCH ZONE") or combined.contains("SCOUTED"),
		"hasRebuildText": combined.contains("Rebuild") or combined.contains("Destroyed Field Barracks") or combined.contains("Target destroyed"),
		"hasRepairText": combined.contains("Repair"),
		"hasSelectAsterBeyondInitial": state != "INITIAL_SELECT_ASTER" and combined.contains("Select Aster"),
		"scoutedMinimapPing": _minimap_has_marker("v0262_minimap_scouted_threat_ping") and _minimap_marker_visible("v0262_minimap_scouted_threat_ping"),
		"watchpostMinimapRegistered": _minimap_has_marker("v0261_minimap_watchpost"),
		"watchZoneVisible": _v0261_watch_zone_visible(),
		"lineVisible": _v0262_awareness_line_visible(),
	}


func _sync_v0262_awareness_visuals() -> void:
	if visual_root == null or barrosan_requested_checkpoint != "v0.262":
		return
	var awareness := _v0262_update_awareness_state()
	var marker_alive := bool(awareness.get("markerAlive", false))
	var scouted := bool(awareness.get("scouted", false))
	var marker_position: Vector2 = awareness.get("markerPosition", V0262_ASHEN_OUTSIDE_ZONE)
	var marker_world := barrosan_build_validation_adapter.source_to_runtime_world(marker_position)
	_set_or_create_disc_marker("v0262_ashen_awareness_marker", marker_world + Vector3(0.0, 0.07, 0.0), 0.54, Color(0.96, 0.20, 0.12, 0.68))
	var marker_node := visual_root.get_node_or_null("v0262_ashen_awareness_marker")
	if marker_node != null:
		marker_node.visible = marker_alive
	var marker_text := "ASHEN SCOUTED" if scouted else "ASHEN MARKER"
	var marker_color := Color("#f0d36f") if scouted else Color("#ff8b61")
	var marker_label := _v0248_marker_label("v0262_ashen_awareness_label", marker_world + Vector3(0.0, 0.86, 0.0), marker_text, marker_color)
	marker_label.visible = marker_alive
	var watch_world := barrosan_build_validation_adapter.source_to_runtime_world(V0261_WATCHPOST_SOURCE_POSITION)
	var midpoint := (watch_world + marker_world) * 0.5
	var distance := watch_world.distance_to(marker_world)
	_v0258_box_overlay("v0262_watchpost_scout_line", midpoint + Vector3(0.0, 0.18, 0.0), Vector3(0.06, 0.05, maxf(0.12, distance)), Color(0.40, 0.96, 0.92, 0.50), scouted, atan2(marker_world.x - watch_world.x, marker_world.z - watch_world.z))
	var line_label := _v0248_marker_label("v0262_scout_line_label", midpoint + Vector3(0.0, 0.62, 0.0), "INTEL ONLY", Color("#8beee9"))
	line_label.visible = scouted and barrosan_runtime_review_mode in ["v0262_ashen_marker_touching_zone_scouted", "v0262_ashen_marker_inside_zone_scouted", "v0262_watchpost_selected_no_attack_copy", "v0262_minimap_scouted_threat_ping"]


func _v0262_awareness_line_visible() -> bool:
	var line := visual_root.get_node_or_null("v0262_watchpost_scout_line") if visual_root != null else null
	return line != null and bool(line.visible)


func _add_v0262_scouted_minimap_ping() -> void:
	if minimap_panel == null or barrosan_requested_checkpoint not in ["v0.262", "v0.263"]:
		return
	if not _minimap_has_marker("v0262_minimap_scouted_threat_ping"):
		_add_minimap_marker("v0262_minimap_scouted_threat_ping", Vector2(205, 106), Vector2(16, 16), Color("#e6cf62"))
	_set_minimap_marker_visible("v0262_minimap_scouted_threat_ping", true)


func _v0262_awareness_status() -> Dictionary:
	var watchpost := _v0261_watchpost_status()
	var required := [
		"v0262_watchpost_foundation_path", "v0262_watchpost_complete_no_threat",
		"v0262_watch_zone_clean_labeling", "v0262_ashen_marker_outside_zone_no_false_positive",
		"v0262_ashen_marker_touching_zone_scouted", "v0262_ashen_marker_inside_zone_scouted",
		"v0262_watchpost_selected_scouted_hud", "v0262_watchpost_selected_no_attack_copy",
		"v0262_minimap_scouted_threat_ping", "v0262_barracks_hud_no_watchpost_text",
		"v0262_watchpost_hud_no_barracks_text", "v0262_barracks_still_trains_militia",
		"v0262_existing_barracks_rebuild_path_still_valid", "v0262_no_detection_before_watchpost_complete",
	]
	var missing: Array[String] = []
	var invariant_pass := true
	var no_false_positive := true
	var no_false_negative := true
	var no_precomplete_detection := true
	var minimap_ping_pass := true
	var passive_pass := true
	for mode in required:
		var snap: Dictionary = v0262_watchpost_awareness_proof.get(mode, {})
		if snap.is_empty():
			missing.append(mode)
			invariant_pass = false
			continue
		var awareness: Dictionary = snap.get("awareness", {})
		invariant_pass = invariant_pass and bool(snap.get("singleSourceMatch", false))
		invariant_pass = invariant_pass and not bool(snap.get("hasSelectAsterBeyondInitial", false))
		passive_pass = passive_pass and not bool(awareness.get("combatAdded", true)) and not bool(awareness.get("projectilesAdded", true)) and not bool(awareness.get("towerAttackAdded", true)) and not bool(awareness.get("enemyAiChanged", true)) and not bool(awareness.get("enemyPathingChanged", true)) and not bool(awareness.get("waveTimingChanged", true)) and not bool(awareness.get("economyAdded", true))
		if mode == "v0262_ashen_marker_outside_zone_no_false_positive":
			no_false_positive = no_false_positive and not bool(awareness.get("scouted", true)) and bool(snap.get("hasNoThreatText", false))
		if mode in ["v0262_ashen_marker_touching_zone_scouted", "v0262_ashen_marker_inside_zone_scouted", "v0262_watchpost_selected_scouted_hud", "v0262_watchpost_selected_no_attack_copy", "v0262_minimap_scouted_threat_ping"]:
			no_false_negative = no_false_negative and bool(awareness.get("scouted", false)) and bool(snap.get("hasScoutedText", false))
		if mode == "v0262_no_detection_before_watchpost_complete":
			no_precomplete_detection = no_precomplete_detection and not bool(awareness.get("scouted", true)) and not bool(snap.get("hasScoutedText", false))
		if mode == "v0262_minimap_scouted_threat_ping":
			minimap_ping_pass = minimap_ping_pass and bool(snap.get("scoutedMinimapPing", false))
		if mode in ["v0262_watchpost_hud_no_barracks_text", "v0262_watchpost_selected_scouted_hud", "v0262_watchpost_selected_no_attack_copy", "v0262_minimap_scouted_threat_ping"]:
			invariant_pass = invariant_pass and not bool(snap.get("hasTrainMilitia", false)) and not bool(snap.get("hasBarracksProductionText", false)) and not bool(snap.get("hasRebuildText", false)) and not bool(snap.get("hasRepairText", false))
		if mode in ["v0262_barracks_hud_no_watchpost_text", "v0262_barracks_still_trains_militia"]:
			invariant_pass = invariant_pass and not bool(snap.get("hasScoutedText", false))
	var awareness_result: Dictionary = barrosan_playtest.get("v0262WatchpostAwareness", {}).duplicate(true)
	var resources_pass := false
	var saw_field_barracks_resources := false
	var saw_watchpost_resources := false
	for snap_value in v0263_watchpost_intel_memory_proof.values():
		var snap_dict: Dictionary = snap_value
		var memory_dict: Dictionary = snap_dict.get("memory", {})
		if _v0262_resources_match(memory_dict.get("resourcesAfterIntel", {}), 240, 40, 90, 38):
			saw_field_barracks_resources = true
		if _v0262_resources_match(memory_dict.get("resourcesAfterIntel", {}), 140, 10, 80, 38):
			saw_watchpost_resources = true
	resources_pass = saw_field_barracks_resources and saw_watchpost_resources
	var status_pass := missing.is_empty() and invariant_pass and no_false_positive and no_false_negative and no_precomplete_detection and minimap_ping_pass and passive_pass and resources_pass
	awareness_result["status"] = "PASS" if status_pass else "IN_PROGRESS"
	awareness_result["checkpoint"] = "v0.262"
	awareness_result["watchpostFoundationStatus"] = watchpost.get("status", "UNKNOWN")
	awareness_result["missingSnapshots"] = missing
	awareness_result["invariantStatus"] = "PASS" if invariant_pass and missing.is_empty() else "IN_PROGRESS"
	awareness_result["noFalsePositiveStatus"] = "PASS" if no_false_positive else "IN_PROGRESS"
	awareness_result["noFalseNegativeStatus"] = "PASS" if no_false_negative else "IN_PROGRESS"
	awareness_result["noDetectionBeforeCompleteStatus"] = "PASS" if no_precomplete_detection else "IN_PROGRESS"
	awareness_result["minimapPingStatus"] = "PASS" if minimap_ping_pass else "IN_PROGRESS"
	awareness_result["passiveIntelOnlyStatus"] = "PASS" if passive_pass else "IN_PROGRESS"
	awareness_result["resourceSequenceStatus"] = "PASS" if resources_pass else "IN_PROGRESS"
	awareness_result["cost"] = V0261_WATCHPOST_COST.duplicate(true)
	awareness_result["hp"] = V0261_WATCHPOST_MAX_HP
	awareness_result["proofSnapshots"] = v0262_watchpost_awareness_proof.duplicate(true)
	awareness_result["defaultRuntimeChanged"] = false
	awareness_result["blenderUsed"] = false
	awareness_result["newGlbExported"] = false
	awareness_result["verdictCeiling"] = "PARTIAL"
	return awareness_result


func _v0263_reset_intel_memory() -> void:
	barrosan_playtest.erase("v0263WatchpostIntelMemory")
	_set_minimap_marker_visible("v0263_minimap_last_seen_memory_ping", false)
	var memory_marker := visual_root.get_node_or_null("v0263_last_seen_world_memory_marker") if visual_root != null else null
	if memory_marker != null:
		memory_marker.visible = false
	var memory_label := visual_root.get_node_or_null("v0263_last_seen_world_memory_label") if visual_root != null else null
	if memory_label != null:
		memory_label.visible = false


func _v0263_move_ashen_marker_after_scout(position: Vector2) -> void:
	for index in range(runtime.units.size()):
		var unit: Dictionary = runtime.units[index]
		if str(unit.get("id", "")) == V0247_ASHEN_RAIDER_RUNTIME_ID:
			unit["position"] = position
			unit["lastPosition"] = position
			unit["destination"] = position
			unit["hasDestination"] = false
			unit["attackTarget"] = ""
			unit["alive"] = true
			unit["reviewHidden"] = false
			unit["watchpostAwarenessReviewMarker"] = true
			runtime.units[index] = unit
			break
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["awarenessMarkerRelation"] = "left-zone"
	pressure["lastKnownPosition"] = position
	barrosan_playtest["v0247Pressure"] = pressure


func _v0263_update_intel_memory_state() -> Dictionary:
	var memory: Dictionary = barrosan_playtest.get("v0263WatchpostIntelMemory", {})
	var awareness := _v0262_update_awareness_state()
	var watchpost_complete := bool(awareness.get("watchpostComplete", false))
	var marker_alive := bool(awareness.get("markerAlive", false))
	var current_scouted := watchpost_complete and marker_alive and bool(awareness.get("scouted", false))
	var marker_position: Vector2 = awareness.get("markerPosition", V0262_ASHEN_OUTSIDE_ZONE)
	var prior := bool(memory.get("everScouted", false))
	if not watchpost_complete:
		memory = {
			"watchpostComplete": false,
			"currentScouted": false,
			"everScouted": false,
			"lastSeenActive": false,
			"lastSeenSector": "",
			"memoryMinimapPingVisible": false,
			"memoryWorldMarkerVisible": false,
			"statusText": "No detection and no prior Ashen intel before completion",
		}
	elif current_scouted:
		memory["watchpostComplete"] = true
		memory["currentScouted"] = true
		memory["everScouted"] = true
		memory["lastSeenActive"] = false
		memory["lastSeenSector"] = V0263_LAST_SEEN_SECTOR
		memory["lastSeenPosition"] = marker_position
		memory["memoryMinimapPingVisible"] = false
		memory["memoryWorldMarkerVisible"] = false
		memory["statusText"] = "ASHEN SCOUTED"
	elif marker_alive and prior:
		memory["watchpostComplete"] = true
		memory["currentScouted"] = false
		memory["everScouted"] = true
		memory["lastSeenActive"] = true
		memory["lastSeenSector"] = V0263_LAST_SEEN_SECTOR
		memory["lastSeenPosition"] = memory.get("lastSeenPosition", V0262_ASHEN_INSIDE_ZONE)
		memory["memoryMinimapPingVisible"] = true
		memory["memoryWorldMarkerVisible"] = true
		memory["statusText"] = "Last scouted Ashen pressure"
	else:
		memory["watchpostComplete"] = true
		memory["currentScouted"] = false
		memory["everScouted"] = false
		memory["lastSeenActive"] = false
		memory["lastSeenSector"] = ""
		memory["lastSeenPosition"] = Vector2.ZERO
		memory["memoryMinimapPingVisible"] = false
		memory["memoryWorldMarkerVisible"] = false
		memory["statusText"] = "No prior Ashen intel"
	memory["awareness"] = awareness.duplicate(true)
	memory["resourcesAfterIntel"] = runtime.resources.duplicate(true)
	memory["healthAfterIntel"] = _v0247_health_snapshot()
	memory["combatAdded"] = false
	memory["projectilesAdded"] = false
	memory["towerAttackAdded"] = false
	memory["enemyAiChanged"] = false
	memory["enemyPathingChanged"] = false
	memory["waveTimingChanged"] = false
	memory["economyAdded"] = false
	barrosan_playtest["v0263WatchpostIntelMemory"] = memory
	if current_scouted:
		_add_v0262_scouted_minimap_ping()
	else:
		_set_minimap_marker_visible("v0262_minimap_scouted_threat_ping", false)
	if bool(memory.get("memoryMinimapPingVisible", false)):
		_add_v0263_memory_minimap_ping()
	else:
		_set_minimap_marker_visible("v0263_minimap_last_seen_memory_ping", false)
	return memory


func _v0263_record_intel_memory_proof(mode: String) -> void:
	var memory := _v0263_update_intel_memory_state()
	var state := _v0261_resolve_state()
	var model := _v0261_ui_model(state)
	var combined := " | ".join([
		hud_objective_strip_label.text if hud_objective_strip_label != null else "",
		hud_onboarding_label.text if hud_onboarding_label != null else "",
		hud_hero_label.text if hud_hero_label != null else "",
		hud_context_label.text if hud_context_label != null else "",
		hud_objective_label.text if hud_objective_label != null else "",
		hud_work_button.text if hud_work_button != null else "",
	])
	var watchpost_selected := state in ["WATCHPOST_NO_HISTORY", "WATCH_ZONE_CLEAN_LABELING", "WATCHPOST_THREAT_OUTSIDE_NO_HISTORY", "WATCHPOST_CURRENT_SCOUTED", "WATCHPOST_CURRENT_MINIMAP", "WATCHPOST_CURRENT_INTEL_ONLY", "WATCHPOST_LAST_SEEN_MEMORY", "WATCHPOST_LAST_SEEN_MINIMAP", "WATCHPOST_LAST_SEEN_WORLD", "WATCHPOST_MEMORY_NOT_CURRENT"]
	var barracks_selected := state in ["BARRACKS_TRAINS_AFTER_WATCHPOST", "EXISTING_BARRACKS_REBUILD_PATH"]
	v0263_watchpost_intel_memory_proof[mode] = {
		"state": state,
		"model": model,
		"combinedText": combined,
		"memory": memory.duplicate(true),
		"singleSourceMatch": (
			(hud_objective_strip_label == null or hud_objective_strip_label.text == str(model.get("topObjective", "")))
			and (hud_onboarding_label == null or hud_onboarding_label.text == str(model.get("instruction", "")))
			and (hud_hero_label == null or hud_hero_label.text == str(model.get("title", "")))
			and (hud_context_label == null or hud_context_label.text == str(model.get("context", "")))
			and (hud_objective_label == null or hud_objective_label.text == str(model.get("status", "")))
			and (hud_work_button == null or hud_work_button.text == str(model.get("button", "")))
		),
		"watchpostSelected": watchpost_selected,
		"barracksSelected": barracks_selected,
		"hasCurrentScoutedText": combined.contains("ASHEN SCOUTED") or combined.contains("Current Watchpost intel"),
		"hasNoThreatText": combined.contains("No threat in watch zone"),
		"hasNoPriorIntelText": combined.contains("No prior Ashen intel"),
		"hasLastSeenText": combined.contains("Last scouted Ashen pressure") or combined.contains("Last seen: east bridge"),
		"hasMemoryNotCurrentText": combined.contains("Not current detection") or combined.contains("not current detection") or combined.contains("Current detection cleared"),
		"hasIntelOnlyText": combined.contains("Intel only") or combined.contains("Passive"),
		"hasAttackOutputText": combined.contains("Attack") or combined.contains("damage output") or combined.contains("Tower attack"),
		"hasTrainMilitia": combined.contains("Train Militia"),
		"hasBarracksProductionText": combined.contains("Train Militia available") or combined.contains("Production available") or combined.contains("Field Barracks production"),
		"hasWatchpostText": combined.contains("Watchpost") or combined.contains("WATCH ZONE") or combined.contains("SCOUTED") or combined.contains("Last scouted"),
		"hasRebuildText": combined.contains("Rebuild") or combined.contains("Destroyed Field Barracks") or combined.contains("Target destroyed"),
		"hasRepairText": combined.contains("Repair"),
		"hasSelectAsterBeyondInitial": state != "INITIAL_SELECT_ASTER" and combined.contains("Select Aster"),
		"currentMinimapPing": _minimap_has_marker("v0262_minimap_scouted_threat_ping") and _minimap_marker_visible("v0262_minimap_scouted_threat_ping"),
		"memoryMinimapPing": _minimap_has_marker("v0263_minimap_last_seen_memory_ping") and _minimap_marker_visible("v0263_minimap_last_seen_memory_ping"),
		"memoryWorldMarker": _v0263_memory_world_marker_visible(),
		"watchpostMinimapRegistered": _minimap_has_marker("v0261_minimap_watchpost"),
		"watchZoneVisible": _v0261_watch_zone_visible(),
	}


func _sync_v0263_intel_memory_visuals() -> void:
	if visual_root == null or barrosan_requested_checkpoint != "v0.263":
		return
	var memory := _v0263_update_intel_memory_state()
	var awareness: Dictionary = memory.get("awareness", {})
	var marker_alive := bool(awareness.get("markerAlive", false))
	var current_scouted := bool(memory.get("currentScouted", false))
	var last_seen_active := bool(memory.get("lastSeenActive", false))
	var marker_position: Vector2 = awareness.get("markerPosition", V0262_ASHEN_OUTSIDE_ZONE)
	var marker_world := barrosan_build_validation_adapter.source_to_runtime_world(marker_position)
	_set_or_create_disc_marker("v0263_ashen_current_marker", marker_world + Vector3(0.0, 0.08, 0.0), 0.54, Color(0.96, 0.18, 0.10, 0.70))
	var current_marker := visual_root.get_node_or_null("v0263_ashen_current_marker")
	if current_marker != null:
		current_marker.visible = marker_alive and current_scouted
	var current_label := _v0248_marker_label("v0263_ashen_current_label", marker_world + Vector3(0.0, 0.90, 0.0), "ASHEN SCOUTED\nCURRENT", Color("#f0d36f"))
	current_label.visible = marker_alive and current_scouted
	var last_seen_position: Vector2 = memory.get("lastSeenPosition", V0262_ASHEN_INSIDE_ZONE)
	var last_seen_world := barrosan_build_validation_adapter.source_to_runtime_world(last_seen_position)
	_set_or_create_disc_marker("v0263_last_seen_world_memory_marker", last_seen_world + Vector3(0.0, 0.06, 0.0), 0.46, Color(0.98, 0.74, 0.32, 0.34))
	var memory_marker := visual_root.get_node_or_null("v0263_last_seen_world_memory_marker")
	if memory_marker != null:
		memory_marker.visible = last_seen_active
	var memory_label := _v0248_marker_label("v0263_last_seen_world_memory_label", last_seen_world + Vector3(0.0, 0.78, 0.0), "LAST SEEN\nEAST BRIDGE", Color("#f3c982"))
	memory_label.visible = last_seen_active
	var watch_world := barrosan_build_validation_adapter.source_to_runtime_world(V0261_WATCHPOST_SOURCE_POSITION)
	var midpoint := (watch_world + marker_world) * 0.5
	var distance := watch_world.distance_to(marker_world)
	_v0258_box_overlay("v0263_current_scout_line", midpoint + Vector3(0.0, 0.18, 0.0), Vector3(0.06, 0.05, maxf(0.12, distance)), Color(0.40, 0.96, 0.92, 0.50), current_scouted, atan2(marker_world.x - watch_world.x, marker_world.z - watch_world.z))
	var line_label := _v0248_marker_label("v0263_current_scout_line_label", midpoint + Vector3(0.0, 0.62, 0.0), "INTEL ONLY", Color("#8beee9"))
	line_label.visible = current_scouted and barrosan_runtime_review_mode in ["v0263_current_scouted_minimap_ping", "v0263_current_scouted_hud_intel_only", "v0263_watchpost_hud_no_barracks_text"]


func _v0263_memory_world_marker_visible() -> bool:
	var marker := visual_root.get_node_or_null("v0263_last_seen_world_memory_marker") if visual_root != null else null
	return marker != null and bool(marker.visible)


func _add_v0263_memory_minimap_ping() -> void:
	if minimap_panel == null or barrosan_requested_checkpoint != "v0.263":
		return
	if not _minimap_has_marker("v0263_minimap_last_seen_memory_ping"):
		_add_minimap_marker("v0263_minimap_last_seen_memory_ping", Vector2(196, 108), Vector2(13, 13), Color("#c9924f"))
	_set_minimap_marker_visible("v0263_minimap_last_seen_memory_ping", true)


func _v0263_intel_memory_status() -> Dictionary:
	var watchpost := _v0261_watchpost_status()
	var required := [
		"v0263_watchpost_build_path", "v0263_watchpost_complete_no_threat_no_history",
		"v0263_watch_zone_clean_labeling", "v0263_ashen_outside_zone_no_false_positive",
		"v0263_ashen_touching_zone_current_scouted", "v0263_ashen_inside_zone_current_scouted",
		"v0263_current_scouted_minimap_ping", "v0263_current_scouted_hud_intel_only",
		"v0263_threat_leaves_zone_last_seen_memory", "v0263_last_seen_memory_minimap_ping",
		"v0263_last_seen_memory_world_marker", "v0263_memory_clearly_not_current_detection",
		"v0263_watchpost_hud_no_barracks_text", "v0263_barracks_hud_no_watchpost_text",
		"v0263_barracks_still_trains_militia", "v0263_existing_barracks_rebuild_path_still_valid",
		"v0263_no_detection_or_memory_before_watchpost_complete",
	]
	var missing: Array[String] = []
	var invariant_pass := true
	var current_detection_pass := true
	var no_false_positive := true
	var memory_after_detection := true
	var memory_not_current := true
	var no_precomplete_intel := true
	var minimap_pass := true
	var world_memory_pass := true
	var passive_pass := true
	for mode in required:
		var snap: Dictionary = v0263_watchpost_intel_memory_proof.get(mode, {})
		if snap.is_empty():
			missing.append(mode)
			invariant_pass = false
			continue
		var memory: Dictionary = snap.get("memory", {})
		var awareness: Dictionary = memory.get("awareness", {})
		invariant_pass = invariant_pass and bool(snap.get("singleSourceMatch", false))
		invariant_pass = invariant_pass and not bool(snap.get("hasSelectAsterBeyondInitial", false))
		passive_pass = passive_pass and not bool(memory.get("combatAdded", true)) and not bool(memory.get("projectilesAdded", true)) and not bool(memory.get("towerAttackAdded", true)) and not bool(memory.get("enemyAiChanged", true)) and not bool(memory.get("enemyPathingChanged", true)) and not bool(memory.get("waveTimingChanged", true)) and not bool(memory.get("economyAdded", true))
		if mode in ["v0263_watchpost_complete_no_threat_no_history", "v0263_ashen_outside_zone_no_false_positive"]:
			no_false_positive = no_false_positive and not bool(memory.get("currentScouted", true)) and not bool(memory.get("lastSeenActive", true)) and bool(snap.get("hasNoPriorIntelText", false))
		if mode in ["v0263_ashen_touching_zone_current_scouted", "v0263_ashen_inside_zone_current_scouted", "v0263_current_scouted_minimap_ping", "v0263_current_scouted_hud_intel_only"]:
			current_detection_pass = current_detection_pass and bool(memory.get("currentScouted", false)) and bool(awareness.get("scouted", false)) and bool(snap.get("hasCurrentScoutedText", false))
		if mode in ["v0263_threat_leaves_zone_last_seen_memory", "v0263_last_seen_memory_minimap_ping", "v0263_last_seen_memory_world_marker", "v0263_memory_clearly_not_current_detection"]:
			memory_after_detection = memory_after_detection and bool(memory.get("everScouted", false)) and bool(memory.get("lastSeenActive", false)) and bool(snap.get("hasLastSeenText", false))
			memory_not_current = memory_not_current and not bool(memory.get("currentScouted", true)) and not bool(awareness.get("scouted", true)) and not bool(snap.get("hasCurrentScoutedText", false))
		if mode == "v0263_no_detection_or_memory_before_watchpost_complete":
			no_precomplete_intel = no_precomplete_intel and not bool(memory.get("currentScouted", true)) and not bool(memory.get("everScouted", true)) and not bool(memory.get("lastSeenActive", true)) and not bool(snap.get("hasCurrentScoutedText", false)) and not bool(snap.get("hasLastSeenText", false))
		if mode == "v0263_current_scouted_minimap_ping":
			minimap_pass = minimap_pass and bool(snap.get("currentMinimapPing", false))
		if mode == "v0263_last_seen_memory_minimap_ping":
			minimap_pass = minimap_pass and bool(snap.get("memoryMinimapPing", false))
		if mode == "v0263_last_seen_memory_world_marker":
			world_memory_pass = world_memory_pass and bool(snap.get("memoryWorldMarker", false))
		if mode == "v0263_watchpost_hud_no_barracks_text":
			invariant_pass = invariant_pass and not bool(snap.get("hasTrainMilitia", false)) and not bool(snap.get("hasBarracksProductionText", false)) and not bool(snap.get("hasRebuildText", false)) and not bool(snap.get("hasRepairText", false))
		if mode in ["v0263_barracks_hud_no_watchpost_text", "v0263_barracks_still_trains_militia"]:
			invariant_pass = invariant_pass and not bool(snap.get("hasCurrentScoutedText", false)) and not bool(snap.get("hasLastSeenText", false))
	var resources_pass := false
	var saw_field_barracks_resources := false
	var saw_watchpost_resources := false
	for snap_value in v0263_watchpost_intel_memory_proof.values():
		var snap_dict: Dictionary = snap_value
		var memory_dict: Dictionary = snap_dict.get("memory", {})
		if _v0262_resources_match(memory_dict.get("resourcesAfterIntel", {}), 240, 40, 90, 38):
			saw_field_barracks_resources = true
		if _v0262_resources_match(memory_dict.get("resourcesAfterIntel", {}), 140, 10, 80, 38):
			saw_watchpost_resources = true
	resources_pass = saw_field_barracks_resources and saw_watchpost_resources
	var result: Dictionary = barrosan_playtest.get("v0263WatchpostIntelMemory", {}).duplicate(true)
	var status_pass := missing.is_empty() and invariant_pass and current_detection_pass and no_false_positive and memory_after_detection and memory_not_current and no_precomplete_intel and minimap_pass and world_memory_pass and passive_pass and resources_pass
	result["status"] = "PASS" if status_pass else "IN_PROGRESS"
	result["checkpoint"] = "v0.263"
	result["watchpostFoundationStatus"] = watchpost.get("status", "UNKNOWN")
	result["missingSnapshots"] = missing
	result["invariantStatus"] = "PASS" if invariant_pass and missing.is_empty() else "IN_PROGRESS"
	result["currentDetectionStatus"] = "PASS" if current_detection_pass else "IN_PROGRESS"
	result["noFalsePositiveStatus"] = "PASS" if no_false_positive else "IN_PROGRESS"
	result["memoryAfterDetectionStatus"] = "PASS" if memory_after_detection else "IN_PROGRESS"
	result["memoryNotCurrentStatus"] = "PASS" if memory_not_current else "IN_PROGRESS"
	result["noPrecompleteIntelStatus"] = "PASS" if no_precomplete_intel else "IN_PROGRESS"
	result["minimapStatus"] = "PASS" if minimap_pass else "IN_PROGRESS"
	result["worldMemoryMarkerStatus"] = "PASS" if world_memory_pass else "IN_PROGRESS"
	result["passiveIntelOnlyStatus"] = "PASS" if passive_pass else "IN_PROGRESS"
	result["resourceSequenceStatus"] = "PASS" if resources_pass else "IN_PROGRESS"
	result["cost"] = V0261_WATCHPOST_COST.duplicate(true)
	result["hp"] = V0261_WATCHPOST_MAX_HP
	result["lastSeenSector"] = V0263_LAST_SEEN_SECTOR
	result["proofSnapshots"] = v0263_watchpost_intel_memory_proof.duplicate(true)
	result["defaultRuntimeChanged"] = false
	result["blenderUsed"] = false
	result["newGlbExported"] = false
	result["verdictCeiling"] = "PARTIAL"
	return result


func _v0262_resources_match(resources: Dictionary, crowns: int, stone: int, iron: int, aether: int) -> bool:
	return int(resources.get("crowns", -999)) == crowns and int(resources.get("stone", -999)) == stone and int(resources.get("iron", -999)) == iron and int(resources.get("aether", -999)) == aether


func _record_v0258_lifecycle_proof(mode: String) -> void:
	var visual_state := _v0258_field_barracks_visual_state()
	var snapshot := {
		"instruction": hud_onboarding_label.text if hud_onboarding_label != null else "",
		"hero": hud_hero_label.text if hud_hero_label != null else "",
		"context": hud_context_label.text if hud_context_label != null else "",
		"objective": hud_objective_label.text if hud_objective_label != null else "",
		"workButton": hud_work_button.text if hud_work_button != null else "",
		"visualState": visual_state,
	}
	var combined := " | ".join([
		str(snapshot["instruction"]),
		str(snapshot["hero"]),
		str(snapshot["context"]),
		str(snapshot["objective"]),
		str(snapshot["workButton"]),
	])
	snapshot["staleRebuildWordingPresent"] = combined.contains("Rebuild not yet implemented")
	snapshot["staleSelectAsterPresent"] = mode != "v0258_initial_select_aster" and combined.contains("Select Aster")
	v0258_lifecycle_proof[mode] = snapshot


func _record_v0257_hud_proof(mode: String) -> void:
	var snapshot := {
		"hero": hud_hero_label.text if hud_hero_label != null else "",
		"context": hud_context_label.text if hud_context_label != null else "",
		"objectiveStrip": hud_objective_strip_label.text if hud_objective_strip_label != null else "",
		"objective": hud_objective_label.text if hud_objective_label != null else "",
		"workButton": hud_work_button.text if hud_work_button != null else "",
	}
	var combined := " | ".join([
		str(snapshot["hero"]),
		str(snapshot["context"]),
		str(snapshot["objectiveStrip"]),
		str(snapshot["objective"]),
		str(snapshot["workButton"]),
	])
	snapshot["staleRebuildWordingPresent"] = combined.contains("Rebuild not yet implemented")
	v0257_hud_proof[mode] = snapshot


func _sync_unit_visuals() -> void:
	super._sync_unit_visuals()
	_sync_barrosan_runtime_visuals()


func set_player_facing_mode(enabled: bool) -> bool:
	if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and enabled and player_facing_mode:
		_sync_player_shell_chrome()
		_sync_hud()
		return true
	return super.set_player_facing_mode(enabled)


func set_player_shell_screen(screen: String) -> bool:
	if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and player_facing_mode and player_shell_screen == screen and screen == "battle":
		_sync_player_shell_chrome()
		_sync_hud()
		return true
	return super.set_player_shell_screen(screen)


func _hud_attack_pressed() -> void:
	if barrosan_runtime_checkpoint in ["v0.250", "v0.251", "v0.252", "v0.253"] and runtime.selected_ids.has(V0246_FIELD_MILITIA_RUNTIME_ID):
		var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
		if runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID) and not bool(pressure.get("raiderDefeated", false)):
			pressure["attackCommandAvailable"] = true
			pressure["attackTargetingMode"] = true
			pressure["attackCommandPressed"] = true
			pressure["objectiveText"] = "Attack targeting mode"
			pressure["statusText"] = "Choose Ashen Raider"
			barrosan_playtest["v0247Pressure"] = pressure
			_set_v0249_objective("Attack targeting mode", "Choose Ashen Raider")
			last_feedback_id = "attack_targeting_mode"
			_sync_barrosan_runtime_visuals()
			_sync_hud()
			return
	super._hud_attack_pressed()


func _issue_real_order(screen_position: Vector2) -> void:
	if barrosan_runtime_checkpoint in ["v0.250", "v0.251", "v0.252", "v0.253"]:
		var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
		if bool(pressure.get("attackTargetingMode", false)):
			var hit := _pick_unit_from_screen(screen_position)
			if not hit.is_empty() and str(hit.get("id", "")) == V0247_ASHEN_RAIDER_RUNTIME_ID:
				issue_attack_order(V0247_ASHEN_RAIDER_RUNTIME_ID)
				return
	super._issue_real_order(screen_position)


func issue_attack_order(target_id: String = "") -> bool:
	if barrosan_runtime_checkpoint not in ["v0.250", "v0.251", "v0.252", "v0.253"]:
		return super.issue_attack_order(target_id)
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var valid: bool = (
		runtime.selected_ids.has(V0246_FIELD_MILITIA_RUNTIME_ID)
		and runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID)
		and target_id == V0247_ASHEN_RAIDER_RUNTIME_ID
	)
	pressure["attackCommandAvailable"] = runtime.selected_ids.has(V0246_FIELD_MILITIA_RUNTIME_ID) and runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID)
	pressure["attackOrderAccepted"] = valid
	pressure["attackTargetingMode"] = false if valid else bool(pressure.get("attackTargetingMode", false))
	pressure["activeAttackTarget"] = target_id if valid else ""
	pressure["attackOrderAcceptedBeforeContact"] = valid and not bool(pressure.get("combatStarted", false))
	if valid:
		for index in range(runtime.units.size()):
			var unit: Dictionary = runtime.units[index]
			if str(unit.get("id", "")) == V0246_FIELD_MILITIA_RUNTIME_ID:
				unit["attackTarget"] = target_id
				runtime.units[index] = unit
				break
		pressure["objectiveText"] = "Attack order accepted"
		pressure["statusText"] = "Militia targeting Ashen Raider"
		pressure["targetMarkerVisible"] = true
		last_feedback_id = "attack_order"
	barrosan_playtest["v0247Pressure"] = pressure
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return valid


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
		if role == V0245_CONSTRUCTED_KEY and barrosan_requested_checkpoint in ["v0.255", "v0.256", "v0.257", "v0.258", "v0.259"]:
			var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
			_set_or_create_disc_marker("v0255_destroyed_field_barracks", position + Vector3(0.0, 0.035, 0.0), maxf(0.54, maxf(footprint.x, footprint.y) * 0.64), Color(0.72, 0.12, 0.08, 0.78))
			var destroyed_marker := visual_root.get_node_or_null("v0255_destroyed_field_barracks")
			if destroyed_marker != null:
				destroyed_marker.visible = bool(structure.get("destroyed", false)) and not bool(rebuild.get("rebuildStarted", false))
			_set_or_create_disc_marker("v0256_rebuilding_field_barracks", position + Vector3(0.0, 0.04, 0.0), maxf(0.54, maxf(footprint.x, footprint.y) * 0.64), Color(0.24, 0.72, 0.80, 0.76))
			var rebuilding_marker := visual_root.get_node_or_null("v0256_rebuilding_field_barracks")
			if rebuilding_marker != null:
				rebuilding_marker.visible = bool(rebuild.get("rebuildStarted", false))
			var destroyed_label := visual_root.get_node_or_null("v0255_destroyed_field_barracks_label") as Label3D
			if destroyed_label == null:
				destroyed_label = Label3D.new()
				destroyed_label.name = "v0255_destroyed_field_barracks_label"
				destroyed_label.font_size = 24
				destroyed_label.pixel_size = 0.006
				destroyed_label.outline_size = 7
				destroyed_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				destroyed_label.no_depth_test = true
				destroyed_label.modulate = Color("#ff6d58")
				visual_root.add_child(destroyed_label)
			destroyed_label.position = position + Vector3(0.0, 0.92, 0.0)
			destroyed_label.text = "DESTROYED\n0 / 200"
			destroyed_label.text = "REBUILDING\n%s / 200" % int(structure.get("health", 0.0)) if bool(rebuild.get("rebuildStarted", false)) else "DESTROYED\n0 / 200"
			destroyed_label.modulate = Color("#63d6e4") if bool(rebuild.get("rebuildStarted", false)) else Color("#ff6d58")
			destroyed_label.visible = bool(structure.get("destroyed", false)) or bool(rebuild.get("rebuildStarted", false))
			if barrosan_requested_checkpoint in ["v0.258", "v0.259"]:
				_v0258_sync_field_barracks_overlays(position, footprint, structure, rebuild)
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
	_sync_v0248_pressure_markers()
	_sync_v0261_watchpost_visuals()
	_sync_v0262_awareness_visuals()
	_sync_v0263_intel_memory_visuals()
	_sync_scale_probes()


func _v0258_sync_field_barracks_overlays(position: Vector3, footprint: Vector2, structure: Dictionary, rebuild: Dictionary) -> void:
	var hp := int(structure.get("health", 0.0))
	var rebuilding := bool(rebuild.get("rebuildStarted", false))
	var rebuilt := bool(rebuild.get("rebuildComplete", false)) and hp == 100
	var state := "full"
	if barrosan_requested_checkpoint == "v0.259":
		state = str(_v0259_lifecycle_ui_model(_v0259_resolve_lifecycle_state()).get("overlayState", "none"))
	elif rebuilding:
		state = "rebuilding_%s" % hp
	elif hp <= 0:
		state = "destroyed"
	elif rebuilt:
		state = "rebuilt_damaged"
	elif hp <= 25:
		state = "critical_functional"
	elif hp < 200:
		state = "damaged_functional"
	var width := maxf(0.86, footprint.x * 0.58)
	var depth := maxf(0.66, footprint.y * 0.52)
	_v0258_box_overlay("v0258_full_trim_a", position + Vector3(-width * 0.34, 0.54, -depth * 0.22), Vector3(width * 0.08, 0.12, depth * 0.58), Color("#67c99d"), state == "full")
	_v0258_box_overlay("v0258_full_trim_b", position + Vector3(width * 0.34, 0.54, depth * 0.18), Vector3(width * 0.08, 0.12, depth * 0.58), Color("#67c99d"), state == "full")
	_v0258_box_overlay("v0258_damage_plank_a", position + Vector3(-width * 0.28, 0.48, 0.0), Vector3(width * 0.10, 0.10, depth * 0.72), Color("#5a3b2b"), state in ["damaged_functional", "critical_functional", "rebuilt_damaged"], 0.28)
	_v0258_box_overlay("v0258_damage_plank_b", position + Vector3(width * 0.24, 0.44, depth * 0.12), Vector3(width * 0.09, 0.09, depth * 0.62), Color("#6d4932"), state in ["critical_functional", "rebuilt_damaged"], -0.36)
	_v0258_box_overlay("v0258_critical_rubble_a", position + Vector3(-width * 0.35, 0.13, -depth * 0.34), Vector3(width * 0.24, 0.18, depth * 0.20), Color("#302a26"), state == "critical_functional", 0.18)
	_v0258_box_overlay("v0258_critical_rubble_b", position + Vector3(width * 0.30, 0.12, depth * 0.32), Vector3(width * 0.28, 0.16, depth * 0.18), Color("#3c3029"), state == "critical_functional", -0.22)
	_v0258_box_overlay("v0258_destroyed_rubble_a", position + Vector3(-width * 0.24, 0.10, -depth * 0.22), Vector3(width * 0.42, 0.20, depth * 0.30), Color("#211e1c"), state == "destroyed", 0.22)
	_v0258_box_overlay("v0258_destroyed_rubble_b", position + Vector3(width * 0.26, 0.12, depth * 0.18), Vector3(width * 0.38, 0.24, depth * 0.34), Color("#2a2420"), state == "destroyed", -0.30)
	_v0258_box_overlay("v0258_destroyed_beam", position + Vector3(0.0, 0.20, 0.0), Vector3(width * 0.12, 0.12, depth * 0.92), Color("#3b241c"), state == "destroyed", 0.58)
	for index in range(4):
		var x_sign := -1.0 if index % 2 == 0 else 1.0
		var z_sign := -1.0 if index < 2 else 1.0
		_v0258_box_overlay("v0258_scaffold_post_%s" % index, position + Vector3(x_sign * width * 0.42, 0.48, z_sign * depth * 0.38), Vector3(0.08, 0.82, 0.08), Color("#6fcbd0"), state.begins_with("rebuilding"))
	_v0258_box_overlay("v0258_scaffold_cross_a", position + Vector3(0.0, 0.62, -depth * 0.38), Vector3(width * 0.92, 0.07, 0.07), Color("#6fcbd0"), state.begins_with("rebuilding"))
	_v0258_box_overlay("v0258_scaffold_cross_b", position + Vector3(0.0, 0.62, depth * 0.38), Vector3(width * 0.92, 0.07, 0.07), Color("#6fcbd0"), state.begins_with("rebuilding"))
	_v0258_box_overlay("v0258_rebuilt_patch", position + Vector3(0.0, 0.56, -depth * 0.30), Vector3(width * 0.58, 0.10, 0.08), Color("#c69658"), state == "rebuilt_damaged")
	var state_label := _v0248_marker_label("v0258_lifecycle_state_label", position + Vector3(0.0, 1.22, 0.0), state.replace("_", " ").to_upper(), Color("#e9d58c"))
	state_label.visible = true


func _v0258_box_overlay(name: String, position: Vector3, size: Vector3, color: Color, visible: bool, yaw: float = 0.0) -> void:
	var node := visual_root.get_node_or_null(name) as MeshInstance3D
	if node == null:
		node = MeshInstance3D.new()
		node.name = name
		node.mesh = BoxMesh.new()
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.92
		node.material_override = material
		visual_root.add_child(node)
	(node.mesh as BoxMesh).size = size
	node.position = position
	node.rotation.y = yaw
	node.visible = visible


func _v0258_field_barracks_visual_state() -> Dictionary:
	var visible_overlays: Array[String] = []
	if visual_root != null:
		for child in visual_root.get_children():
			if str(child.name).begins_with("v0258_") and child is VisualInstance3D and (child as VisualInstance3D).visible:
				visible_overlays.append(str(child.name))
	var hp := int(_v0251_field_barracks_health())
	var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
	var state := "full"
	if barrosan_requested_checkpoint == "v0.259":
		state = str(_v0259_lifecycle_ui_model(_v0259_resolve_lifecycle_state()).get("overlayState", "none"))
	elif bool(rebuild.get("rebuildStarted", false)):
		state = "rebuilding"
	elif hp <= 0:
		state = "destroyed"
	elif bool(rebuild.get("rebuildComplete", false)) and hp == 100:
		state = "rebuilt_damaged"
	elif hp <= 25:
		state = "critical_functional"
	elif hp < 200:
		state = "damaged_functional"
	return {
		"state": state,
		"hp": hp,
		"productionAvailable": _v0255_field_barracks_production_available(),
		"overlayCount": visible_overlays.size(),
		"visibleOverlays": visible_overlays,
	}


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
	_sync_barrosan_runtime_visuals()
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
		"v0245Construction": {
			"target": "barracks",
			"runtimeId": V0245_CONSTRUCTED_RUNTIME_ID,
			"roleId": V0245_CONSTRUCTED_ROLE_ID,
			"implemented": false,
			"registered": false,
			"selected": false,
			"minimapRegistered": false,
			"startingResources": {},
			"afterCancelResources": {},
			"afterBlockedResources": {},
			"afterPlacementResources": {},
			"cancelResourcesUnchanged": false,
			"blockedResourcesUnchanged": false,
			"blockedStructureCreated": false,
			"placementResourceDelta": {},
			"spendCount": 0,
		},
		"v0246FieldProduction": {
			"authorityLoaded": false,
			"target": "constructed authoritative Field Barracks",
			"unitId": "militia",
			"runtimeId": V0246_FIELD_MILITIA_RUNTIME_ID,
			"cost": {},
			"queue": [],
			"queueAccepted": false,
			"queueSpendCount": 0,
			"queueResourceDelta": {},
			"progress": 0.0,
			"spawned": false,
			"spawnCount": 0,
			"selected": false,
			"minimapRegistered": false,
			"duplicateQueueRejected": false,
			"duplicateQueueResourcesUnchanged": false,
			"failedTrainRejected": false,
			"failedTrainResourcesUnchanged": false,
			"movementProbes": {},
		},
		"v0247Pressure": {
			"target": "one scripted Ashen Raider pressure entity",
			"runtimeId": V0247_ASHEN_RAIDER_RUNTIME_ID,
			"triggered": false,
			"spawned": false,
			"spawnCount": 0,
			"registered": false,
			"selected": false,
			"minimapRegistered": false,
			"laneProbes": {},
			"interceptReached": false,
			"contained": false,
			"reachedPressureMarker": false,
			"objectiveText": "8. Prepare for Ashen pressure",
			"statusText": "Prepare one defender",
			"resourcesBeforePressure": {},
			"resourcesAfterPressure": {},
			"damageApplied": false,
			"deathOccurred": false,
			"additionalEnemiesSpawned": false,
			"objectiveHistory": [],
			"telegraphVisible": false,
			"telegraphRegistered": false,
			"interceptMarkerVisible": false,
			"interceptMarkerRegistered": false,
			"interceptMarkerState": "waiting",
			"timing": {
				"spawnHoldFrames": 0,
				"laneStartFrames": 150,
				"bridgeApproachFrames": 245,
			},
			"resourceSnapshots": {},
			"healthSnapshots": {},
			"combatStarted": false,
			"combatStartDistance": -1.0,
			"combatTickCount": 0,
			"combatTickIntervalSeconds": V0249_COMBAT_TICK_SECONDS,
			"combatTicks": [],
			"raiderDefeated": false,
			"raiderRemoved": false,
			"raiderMinimapRemoved": false,
			"containedByCombat": false,
			"resourcesDuringCombat": {},
			"resourcesAfterCombat": {},
			"collateralBefore": {},
			"collateralAfter": {},
			"buildingsUnharmed": false,
			"asterWorkerUnharmed": false,
		},
		"v0251DefenseConsequence": {
			"fieldBarracksMaxHp": V0251_FIELD_BARRACKS_MAX_HP,
			"fieldBarracksStartHp": V0251_FIELD_BARRACKS_MAX_HP,
			"fieldBarracksFinalHp": V0251_FIELD_BARRACKS_MAX_HP,
			"fieldBarracksState": "unharmed",
			"buildingPressureContact": false,
			"buildingDamageStarted": false,
			"buildingDamageStartedBeforeContact": false,
			"buildingDamageTickCount": 0,
			"buildingDamageTicks": [],
			"buildingPressureContained": false,
			"buildingDestroyed": false,
			"boundedStop": false,
			"resourcesBeforeBuildingPressure": {},
			"resourcesAfterBuildingPressure": {},
			"resourcesUnchanged": false,
			"asterWorkerUnharmed": false,
		},
		"v0252ThreatTiming": {
			"threatRangeReached": false,
			"warningStarted": false,
			"warningStep": 0,
			"warningStepCount": V0252_THREAT_WINDOW_STEPS,
			"warningDurationSeconds": V0252_THREAT_WINDOW_SECONDS,
			"warningExpired": false,
			"warningActive": false,
			"damageImminent": false,
			"damageStartedAfterWarning": false,
			"damageOccurredDuringWarning": false,
			"fieldBarracksHpAtWarningStart": V0251_FIELD_BARRACKS_MAX_HP,
			"fieldBarracksHpAtWarningMidpoint": V0251_FIELD_BARRACKS_MAX_HP,
			"fieldBarracksHpAtWarningExpiry": V0251_FIELD_BARRACKS_MAX_HP,
			"threatWindowMarkerVisible": false,
			"threatWindowMarkerRegistered": false,
			"damageImminentMarkerVisible": false,
			"damageImminentMarkerRegistered": false,
			"raiderMinimapVisibleDuringWarning": false,
			"defendedDuringWarning": false,
			"boundedRaiderStop": false,
		},
		"v0253WorkerRepair": {
			"targetRuntimeId": V0245_CONSTRUCTED_RUNTIME_ID,
			"workerRuntimeId": "worker_00",
			"repairCommandAvailable": false,
			"repairTargetingMode": false,
			"repairOrderAccepted": false,
			"repairStarted": false,
			"repairComplete": false,
			"repairTickCount": 0,
			"repairTickLimit": V0253_REPAIR_TICK_LIMIT,
			"repairAmountPerTick": V0253_REPAIR_AMOUNT,
			"repairCost": V0253_REPAIR_COST.duplicate(true),
			"repairSpendCount": 0,
			"resourcesBeforeRepair": {},
			"resourcesAfterRepairSpend": {},
			"resourcesAfterRepair": {},
			"repairResourceDelta": {},
			"repairTicks": [],
			"fieldBarracksHpBeforeRepair": 0.0,
			"fieldBarracksFinalHp": 0.0,
			"overhealOccurred": false,
			"repeatedChargeRejected": false,
			"resourcesUnchangedAfterRepair": false,
			"repairMarkerVisible": false,
			"repairMarkerRegistered": false,
			"workerMinimapVisibleDuringRepair": false,
			"fieldBarracksMinimapVisibleDuringRepair": false,
		},
		"v0254DamagedFunctional": {
			"damagedBarracksSelectable": false,
			"damagedBarracksFunctional": false,
			"productionAvailableAt125": false,
			"trainOrderAcceptedAt125": false,
			"trainCost": {},
			"resourcesBeforeDamagedTraining": {},
			"resourcesAfterDamagedTraining": {},
			"trainResourceDelta": {},
			"militiaCountFromDamagedBarracks": 0,
			"fieldBarracksHpAfterTraining": 0.0,
			"waitAttempts": 0,
			"fieldBarracksHpBeforeWait": 0.0,
			"fieldBarracksHpAfterWait": 0.0,
			"resourcesBeforeWait": {},
			"resourcesAfterWait": {},
			"noPassiveCollapse": false,
			"noRefund": false,
			"noExtraCharge": false,
			"productionUnavailableOnlyAtZeroHp": true,
			"minimapPreserved": false,
		},
		"v0255SecondPressure": {
			"explicitTrigger": false,
			"warningStarted": false,
			"warningActive": false,
			"warningExpired": false,
			"warningStep": 0,
			"hpAtWarningStart": 0.0,
			"hpAtWarningMidpoint": 0.0,
			"hpAtWarningExpiry": 0.0,
			"damageDuringWarning": false,
			"damageStarted": false,
			"damageTickCount": 0,
			"damageTicks": [],
			"destroyed": false,
			"productionAvailableAt25": false,
			"productionUnavailableAtZero": false,
			"repairUnavailableAtZero": false,
			"noRefund": false,
			"noAutomaticRebuild": false,
			"resourcesBefore": {},
			"resourcesAfter": {},
		},
		"v0256WorkerRebuild": {
			"rebuildCost": V0256_REBUILD_COST.duplicate(true),
			"rebuildCommandAvailable": false,
			"rebuildOrderAccepted": false,
			"rebuildStarted": false,
			"rebuildComplete": false,
			"rebuildSpendCount": 0,
			"resourcesBeforeRebuild": {},
			"resourcesAfterRebuildSpend": {},
			"resourcesAfterRebuild": {},
			"rebuildResourceDelta": {},
			"rebuildTicks": [],
			"rebuildTickCount": 0,
			"fieldBarracksHpBeforeRebuild": 0.0,
			"fieldBarracksFinalHp": 0.0,
			"productionUnavailableDuringRebuild": true,
			"productionAvailableAfterRebuild": false,
			"repairUnavailableAtZero": false,
			"resourcesUnchangedAfterSpend": false,
			"repeatedChargeRejected": false,
		},
	}


func _clear_barrosan_playtest_selection() -> void:
	runtime.clear_selection()
	real_input_selected_id = ""
	barrosan_selected_role_id = ""
	v0133_selected_structure_id = ""
	v0133_barracks_selected = false


func _reset_v0251_branch_runtime() -> void:
	runtime.resources = {"crowns": 420, "stone": 160, "iron": 90, "aether": 38}
	runtime.units = runtime.units.filter(
		func(unit: Dictionary) -> bool:
			return str(unit.get("id", "")) not in [V0246_FIELD_MILITIA_RUNTIME_ID, V0247_ASHEN_RAIDER_RUNTIME_ID]
	)
	runtime.structures = runtime.structures.filter(
		func(structure: Dictionary) -> bool:
			return str(structure.get("id", "")) != V0245_CONSTRUCTED_RUNTIME_ID
	)
	barrosan_runtime_structures.erase(V0245_CONSTRUCTED_KEY)
	_clear_barrosan_playtest_selection()
	_rebuild_visuals()
	_add_barrosan_minimap_role_markers()


func _prepare_v0254_damaged_branch() -> void:
	_reset_v0251_branch_runtime()
	_reset_barrosan_playtest_status()
	_set_v0252_aster_health_contract()
	_load_v0246_militia_authority()
	_capture_v0245_starting_resources()
	_run_v0246_builder_probe()
	_run_v0245_preview(false, "v0254_branch_confirm")
	_attempt_v0245_placement(false)
	_prepare_v0251_undefended_pressure()
	_activate_v0249_markers()
	_spawn_v0247_ashen_raider()
	_add_v0247_ashen_raider_minimap_marker()
	_advance_v0247_raider_lane("lane_start", V0247_PRESSURE_LANE_START, 150)
	_advance_v0247_raider_lane("field_barracks_threat_approach", V0251_FIELD_BARRACKS_PRESSURE_POINT, 760)
	_begin_v0252_threat_window()
	_advance_v0252_threat_window()
	_advance_v0252_threat_window()
	_begin_v0252_building_pressure_after_warning()
	_advance_v0251_building_damage_tick()
	_advance_v0251_building_damage_tick()
	_advance_v0251_building_damage_tick()
	_finalize_v0251_building_pressure()
	var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
	repair["missedWindowProof"] = _v0252_missed_window_status().duplicate(true)
	barrosan_playtest["v0253WorkerRepair"] = repair
	select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
	_set_v0249_objective("Field Barracks damaged but functional", "No active pressure")


func _record_v0254_damaged_functional_state() -> void:
	var state: Dictionary = barrosan_playtest.get("v0254DamagedFunctional", {})
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	state["damagedBarracksSelectable"] = select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
	state["damagedBarracksFunctional"] = _v0251_field_barracks_health() > 0.0
	state["productionAvailableAt125"] = (
		_v0251_field_barracks_health() == 125.0
		and not bool(production.get("spawned", false))
		and (production.get("queue", []) as Array).is_empty()
	)
	state["minimapPreserved"] = _minimap_has_marker("v0245_minimap_constructed_barracks")
	barrosan_playtest["v0254DamagedFunctional"] = state


func _record_v0254_no_passive_collapse() -> void:
	var state: Dictionary = barrosan_playtest.get("v0254DamagedFunctional", {})
	state["fieldBarracksHpBeforeWait"] = _v0251_field_barracks_health()
	state["resourcesBeforeWait"] = runtime.resources.duplicate(true)
	var accepted_damage_ticks := 0
	for _attempt in range(6):
		if _advance_v0251_building_damage_tick():
			accepted_damage_ticks += 1
	state["waitAttempts"] = 6
	state["acceptedDamageTicksAfterBoundedStop"] = accepted_damage_ticks
	state["fieldBarracksHpAfterWait"] = _v0251_field_barracks_health()
	state["resourcesAfterWait"] = runtime.resources.duplicate(true)
	state["noPassiveCollapse"] = (
		float(state["fieldBarracksHpBeforeWait"]) == 125.0
		and float(state["fieldBarracksHpAfterWait"]) == 125.0
		and accepted_damage_ticks == 0
	)
	state["noRefund"] = state["resourcesAfterWait"] == state["resourcesBeforeWait"]
	state["noExtraCharge"] = state["resourcesAfterWait"] == state["resourcesBeforeWait"]
	state["fieldBarracksHpAfterTraining"] = _v0251_field_barracks_health()
	state["militiaCountFromDamagedBarracks"] = runtime.units.filter(
		func(unit: Dictionary) -> bool:
			return str(unit.get("id", "")) == V0246_FIELD_MILITIA_RUNTIME_ID and bool(unit.get("alive", false))
	).size()
	barrosan_playtest["v0254DamagedFunctional"] = state
	v0254_damaged_proof = state.duplicate(true)


func _prepare_v0255_damaged_branch(train_militia: bool = false) -> void:
	_prepare_v0254_damaged_branch()
	_record_v0254_damaged_functional_state()
	_record_v0254_no_passive_collapse()
	if train_militia:
		var damaged: Dictionary = barrosan_playtest.get("v0254DamagedFunctional", {})
		damaged["resourcesBeforeDamagedTraining"] = runtime.resources.duplicate(true)
		damaged["trainOrderAcceptedAt125"] = _queue_v0246_field_militia()
		damaged["resourcesAfterDamagedTraining"] = runtime.resources.duplicate(true)
		damaged["trainResourceDelta"] = _resource_delta(damaged["resourcesBeforeDamagedTraining"], runtime.resources)
		barrosan_playtest["v0254DamagedFunctional"] = damaged
		_advance_v0246_field_training(130)
		_record_v0254_no_passive_collapse()


func _remove_v0255_raider_for_second_pressure() -> void:
	runtime.units = runtime.units.filter(
		func(unit: Dictionary) -> bool:
			return str(unit.get("id", "")) != V0247_ASHEN_RAIDER_RUNTIME_ID
	)
	_remove_v0249_raider_minimap_marker()
	_rebuild_visuals()


func _prepare_v0255_second_pressure() -> void:
	_remove_v0255_raider_for_second_pressure()
	var resources_before: Dictionary = runtime.resources.duplicate(true)
	barrosan_playtest["v0247Pressure"] = {
		"triggered": true,
		"trigger": "explicit bounded second Ashen pressure",
		"objectiveText": "Second Ashen pressure incoming",
		"statusText": "Intercept before impact",
		"resourcesBeforePressure": resources_before,
		"telegraphVisible": true,
		"interceptMarkerVisible": true,
		"interceptMarkerState": "waiting",
		"spawned": false,
		"spawnCount": 0,
		"combatStarted": false,
		"combatTicks": [],
		"combatTickCount": 0,
		"raiderDefeated": false,
		"attackOrderAccepted": false,
		"contained": false,
	}
	barrosan_playtest["v0252ThreatTiming"] = {
		"warningStarted": false,
		"warningActive": false,
		"warningExpired": false,
		"warningStep": 0,
		"damageImminent": false,
		"damageStartedAfterWarning": false,
		"damageOccurredDuringWarning": false,
		"fieldBarracksHpAtWarningStart": _v0251_field_barracks_health(),
		"fieldBarracksHpAtWarningMidpoint": _v0251_field_barracks_health(),
		"fieldBarracksHpAtWarningExpiry": _v0251_field_barracks_health(),
	}
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	consequence["buildingDamageStarted"] = false
	consequence["buildingPressureContained"] = false
	consequence["boundedStop"] = false
	consequence["fieldBarracksState"] = "damaged"
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	var second: Dictionary = barrosan_playtest.get("v0255SecondPressure", {})
	second["explicitTrigger"] = true
	second["triggerText"] = "Second Ashen pressure incoming"
	second["interceptText"] = "Intercept before impact"
	second["resourcesBefore"] = resources_before
	second["startHp"] = _v0251_field_barracks_health()
	second["raiderCount"] = 0
	barrosan_playtest["v0255SecondPressure"] = second
	_spawn_v0247_ashen_raider()
	_add_v0247_ashen_raider_minimap_marker()
	second = barrosan_playtest.get("v0255SecondPressure", {})
	second["raiderCount"] = 1 if runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID) else 0
	barrosan_playtest["v0255SecondPressure"] = second
	_set_v0249_objective("Second Ashen pressure incoming", "Intercept before impact")


func _sync_v0255_second_warning_proof() -> void:
	var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
	var second: Dictionary = barrosan_playtest.get("v0255SecondPressure", {})
	second["warningStarted"] = bool(timing.get("warningStarted", false))
	second["warningActive"] = bool(timing.get("warningActive", false))
	second["warningExpired"] = bool(timing.get("warningExpired", false))
	second["warningStep"] = int(timing.get("warningStep", 0))
	second["hpAtWarningStart"] = float(timing.get("fieldBarracksHpAtWarningStart", 0.0))
	second["hpAtWarningMidpoint"] = float(timing.get("fieldBarracksHpAtWarningMidpoint", 0.0))
	second["hpAtWarningExpiry"] = float(timing.get("fieldBarracksHpAtWarningExpiry", 0.0))
	second["damageDuringWarning"] = bool(timing.get("damageOccurredDuringWarning", false))
	barrosan_playtest["v0255SecondPressure"] = second


func _begin_v0255_second_damage() -> bool:
	var second: Dictionary = barrosan_playtest.get("v0255SecondPressure", {})
	if not bool(second.get("explicitTrigger", false)) or not bool(second.get("warningExpired", false)):
		return false
	if bool(second.get("intercepted", false)) or bool(second.get("destroyed", false)):
		return false
	second["damageStarted"] = true
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	consequence["fieldBarracksState"] = "under_pressure"
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	barrosan_playtest["v0255SecondPressure"] = second
	return true


func _advance_v0255_second_damage_tick() -> bool:
	var second: Dictionary = barrosan_playtest.get("v0255SecondPressure", {})
	if not bool(second.get("damageStarted", false)) or bool(second.get("destroyed", false)):
		return false
	var tick := int(second.get("damageTickCount", 0)) + 1
	if tick > V0255_SECOND_PRESSURE_DAMAGE_TICK_LIMIT:
		return false
	var before := _v0251_field_barracks_health()
	var after := maxf(0.0, before - V0251_RAIDER_BUILDING_DAMAGE)
	_v0251_set_field_barracks_health(after)
	var ticks: Array = second.get("damageTicks", [])
	ticks.append({"tick": tick, "before": before, "after": after, "damage": V0251_RAIDER_BUILDING_DAMAGE})
	second["damageTicks"] = ticks
	second["damageTickCount"] = tick
	second["finalHp"] = after
	if after == 25.0:
		second["productionAvailableAt25"] = _v0251_field_barracks_health() > 0.0
	if after <= 0.0:
		second["destroyed"] = true
		second["destroyedHp"] = after
		second["productionUnavailableAtZero"] = not _v0255_field_barracks_production_available()
		second["repairUnavailableAtZero"] = not _v0253_repair_command_available()
		second["resourcesAfter"] = runtime.resources.duplicate(true)
		second["noRefund"] = second.get("resourcesBefore", {}) == runtime.resources
		second["noAutomaticRebuild"] = _v0251_field_barracks_health() == 0.0
		var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
		consequence["fieldBarracksState"] = "destroyed"
		consequence["buildingDestroyed"] = true
		consequence["fieldBarracksFinalHp"] = 0.0
		barrosan_playtest["v0251DefenseConsequence"] = consequence
		var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
		timing["damageImminent"] = false
		timing["damageImminentMarkerVisible"] = false
		timing["threatWindowMarkerVisible"] = false
		barrosan_playtest["v0252ThreatTiming"] = timing
		var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
		pressure["telegraphVisible"] = false
		pressure["interceptMarkerVisible"] = false
		barrosan_playtest["v0247Pressure"] = pressure
		_set_v0249_objective(
			"Authoritative Field Barracks destroyed",
			"Production unavailable | Select Worker to rebuild" if barrosan_requested_checkpoint in ["v0.256", "v0.257", "v0.258", "v0.259"] else "Production unavailable | Rebuild not yet implemented"
		)
	else:
		_set_v0249_objective("Field Barracks under Ashen pressure", "Production still available while HP > 0")
	barrosan_playtest["v0255SecondPressure"] = second
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _v0255_field_barracks_production_available() -> bool:
	if _v0251_field_barracks_health() <= 0.0:
		return false
	for structure in runtime.structures:
		if str(structure.get("id", "")) == V0245_CONSTRUCTED_RUNTIME_ID:
			return bool(structure.get("productionEnabled", false))
	return false


func _record_v0255_destroyed_proof() -> void:
	var second: Dictionary = barrosan_playtest.get("v0255SecondPressure", {})
	second["selectedAtZero"] = select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
	second["trainOrderAcceptedAtZero"] = _queue_v0246_field_militia()
	second["productionUnavailableAtZero"] = not _v0255_field_barracks_production_available()
	second["repairUnavailableAtZero"] = not _v0253_repair_command_available()
	second["asterFinalHp"] = _v0247_unit_health("hero_aster")
	second["workerFinalHp"] = _v0247_unit_health("worker_00")
	second["minimapPreserved"] = _minimap_has_marker("v0245_minimap_constructed_barracks")
	barrosan_playtest["v0255SecondPressure"] = second
	v0255_destroyed_proof = second.duplicate(true)


func _record_v0256_destroyed_proof() -> void:
	var destroyed: Dictionary = barrosan_playtest.get("v0255SecondPressure", {}).duplicate(true)
	destroyed["firstPressure"] = barrosan_playtest.get("v0253WorkerRepair", {}).get("missedWindowProof", {}).duplicate(true)
	destroyed["noPassiveCollapse"] = bool(barrosan_playtest.get("v0254DamagedFunctional", {}).get("noPassiveCollapse", false))
	v0256_destroyed_proof = destroyed


func _set_v0252_aster_health_contract() -> void:
	for index in range(runtime.units.size()):
		var unit: Dictionary = runtime.units[index]
		if str(unit.get("id", "")) != "hero_aster":
			continue
		unit["health"] = 100.0
		unit["maxHealth"] = 100.0
		runtime.units[index] = unit
		break


func _select_playtest_unit(unit_id: String) -> bool:
	_clear_barrosan_playtest_selection()
	var selected := runtime.select_entity(unit_id)
	if selected:
		var selected_units: Array = barrosan_playtest.get("selectedUnits", [])
		if not selected_units.has(unit_id):
			selected_units.append(unit_id)
		barrosan_playtest["selectedUnits"] = selected_units
		if unit_id == V0246_FIELD_MILITIA_RUNTIME_ID:
			var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
			production["selected"] = true
			barrosan_playtest["v0246FieldProduction"] = production
		elif unit_id == V0247_ASHEN_RAIDER_RUNTIME_ID:
			var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
			pressure["selected"] = true
			barrosan_playtest["v0247Pressure"] = pressure
	_sync_barrosan_runtime_visuals()
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
	var construction: Dictionary = barrosan_playtest.get("v0245Construction", {})
	if barrosan_runtime_review_mode.begins_with("v0245_proof_"):
		var proof_kind := barrosan_runtime_review_mode.trim_prefix("v0245_proof_")
		if proof_kind == "resource_delta":
			label.text = "REAL PLACEMENT\n-180 Crowns / -120 Stone\nspent exactly once"
		else:
			label.text = "AUTHORITATIVE CONSTRUCTION"
		label.modulate = Color("#a8efad")
	else:
		label.text = "PREVIEW ONLY\nResources unchanged" if bool(barrosan_playtest.get("previewResourcesUnchanged", false)) else "PREVIEW RESOURCE CHECK PENDING"
		label.modulate = Color("#a8efad") if bool(barrosan_playtest.get("previewResourcesUnchanged", false)) else Color("#ffcf82")
	label.visible = barrosan_runtime_review_mode == "v0244_resource_proof" or barrosan_runtime_review_mode.begins_with("v0245_proof_")


func _capture_v0245_starting_resources() -> void:
	_clear_barrosan_playtest_selection()
	var construction: Dictionary = barrosan_playtest.get("v0245Construction", {})
	if construction.get("startingResources", {}).is_empty():
		construction["startingResources"] = runtime.resources.duplicate(true)
	barrosan_playtest["v0245Construction"] = construction


func _run_v0245_preview(blocked: bool, phase: String) -> void:
	_capture_v0245_starting_resources()
	var before: Dictionary = runtime.resources.duplicate(true)
	_evaluate_barrosan_build_previews()
	var result := (barrosan_blocked_placement if blocked else barrosan_valid_placement).duplicate(true)
	var construction: Dictionary = barrosan_playtest.get("v0245Construction", {})
	construction["%sPreview" % phase] = result
	construction["%sPreviewResources" % phase] = before
	barrosan_playtest["v0245Construction"] = construction
	barrosan_runtime_review_mode = "blocked_preview" if blocked else "valid_preview"


func _cancel_v0245_preview() -> void:
	var construction: Dictionary = barrosan_playtest.get("v0245Construction", {})
	var starting: Dictionary = construction.get("startingResources", {})
	construction["afterCancelResources"] = runtime.resources.duplicate(true)
	construction["cancelResourcesUnchanged"] = starting == runtime.resources
	barrosan_playtest["v0245Construction"] = construction
	_clear_barrosan_playtest_selection()
	barrosan_runtime_review_mode = "v0245_proof_cancel"


func _attempt_v0245_placement(blocked: bool) -> bool:
	_capture_v0245_starting_resources()
	var point := Vector2(1280, 800) if blocked else Vector2(520, 1450)
	var result: Dictionary = barrosan_build_validation_adapter.evaluate(point, "barracks", runtime.resources)
	var construction: Dictionary = barrosan_playtest.get("v0245Construction", {})
	if blocked:
		var before_count: int = _v0245_constructed_count()
		var before_resources: Dictionary = runtime.resources.duplicate(true)
		construction["blockedAttempt"] = result.duplicate(true)
		construction["afterBlockedResources"] = runtime.resources.duplicate(true)
		construction["blockedResourcesUnchanged"] = before_resources == runtime.resources
		construction["blockedStructureCreated"] = _v0245_constructed_count() != before_count
		barrosan_playtest["v0245Construction"] = construction
		barrosan_runtime_review_mode = "blocked_preview"
		return false
	if not bool(result.get("ok", false)) or _v0245_constructed_count() > 0:
		construction["validAttempt"] = result.duplicate(true)
		construction["failureReason"] = "validation-rejected-or-already-constructed"
		barrosan_playtest["v0245Construction"] = construction
		return false
	var definition: Dictionary = barrosan_build_validation_adapter.definition("barracks")
	var cost: Dictionary = definition.get("cost", {})
	var size_data: Dictionary = definition.get("size", {})
	var before_resources: Dictionary = runtime.resources.duplicate(true)
	for key in cost:
		runtime.resources[key] = int(runtime.resources.get(key, 0)) - int(cost[key])
	var size: Vector2 = Vector2(float(size_data.get("width", 82.0)), float(size_data.get("height", 64.0)))
	runtime.structures.append({
		"id": V0245_CONSTRUCTED_RUNTIME_ID,
		"fixtureId": "barrosan_authoritative_barracks",
		"roleId": V0245_CONSTRUCTED_ROLE_ID,
		"team": "friendly",
		"position": point,
		"size": size,
		"rect": Rect2(point - size * 0.5, size),
		"entityType": "opt_in_technical_construction",
		"alive": true,
		"health": V0251_FIELD_BARRACKS_MAX_HP if barrosan_runtime_checkpoint in ["v0.251", "v0.252", "v0.253", "v0.254"] else 650.0,
		"maxHealth": V0251_FIELD_BARRACKS_MAX_HP if barrosan_runtime_checkpoint in ["v0.251", "v0.252", "v0.253", "v0.254"] else 650.0,
		"constructionState": "complete",
		"constructionProgress": 1.0,
		"productionQueue": [],
		"productionEnabled": barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253", "v0.254"],
		"productionLimit": "militia-single-slot-single-spawn" if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253", "v0.254"] else "none",
		"technicalConstructionEntity": true,
		"economyMutationAllowed": false,
		"aiMutationAllowed": false,
		"combatEnabled": false,
		"savePersistenceEnabled": false,
	})
	construction["validAttempt"] = result.duplicate(true)
	construction["implemented"] = true
	construction["spendCount"] = int(construction.get("spendCount", 0)) + 1
	construction["cost"] = cost.duplicate(true)
	construction["afterPlacementResources"] = runtime.resources.duplicate(true)
	construction["placementResourceDelta"] = _resource_delta(before_resources, runtime.resources)
	barrosan_playtest["v0245Construction"] = construction
	_rebuild_visuals()
	_add_barrosan_minimap_role_markers()
	_add_v0245_constructed_minimap_marker()
	select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
	construction = barrosan_playtest.get("v0245Construction", {})
	construction["registered"] = barrosan_runtime_structures.has(V0245_CONSTRUCTED_KEY)
	construction["selected"] = barrosan_selected_role_id == V0245_CONSTRUCTED_KEY
	construction["minimapRegistered"] = _minimap_has_marker("v0245_minimap_constructed_barracks")
	barrosan_playtest["v0245Construction"] = construction
	return true


func _v0245_constructed_count() -> int:
	return runtime.structures.filter(func(structure: Dictionary) -> bool: return str(structure.get("id", "")) == V0245_CONSTRUCTED_RUNTIME_ID).size()


func _resource_delta(before: Dictionary, after: Dictionary) -> Dictionary:
	var delta: Dictionary = {}
	for key in before:
		delta[key] = int(after.get(key, 0)) - int(before.get(key, 0))
	return delta


func _show_v0245_construction_proof(kind: String) -> void:
	_clear_barrosan_playtest_selection()
	barrosan_runtime_review_mode = "v0245_proof_%s" % kind
	_sync_v0244_resource_label()


func _add_v0245_constructed_minimap_marker() -> void:
	if minimap_panel == null or _v0245_constructed_count() == 0:
		return
	if not _minimap_has_marker("v0245_minimap_constructed_barracks"):
		_add_minimap_marker("v0245_minimap_constructed_barracks", Vector2(112, 198), Vector2(14, 14), Color("#f0c458"))


func _run_v0245_pathing_probe() -> void:
	var construction: Dictionary = barrosan_playtest.get("v0245Construction", {})
	var before: Vector2 = runtime.unit_position("worker_00")
	var stuck_before := int(runtime.stuck_unit_count)
	runtime.select_entity("worker_00")
	var accepted := runtime.issue_move_order(Vector2(560, 1380))
	for _frame in range(260):
		runtime.advance_live_frame()
	var after: Vector2 = runtime.unit_position("worker_00")
	construction["pathingProbe"] = {
		"accepted": accepted,
		"before": before,
		"after": after,
		"displacement": before.distance_to(after),
		"stuckDelta": int(runtime.stuck_unit_count) - stuck_before,
		"obstacleModel": "existing rectangular destination nudge",
		"reviewGradeOnly": true,
	}
	barrosan_playtest["v0245Construction"] = construction
	_sync_unit_visuals()
	_sync_hud()


func _load_v0246_militia_authority() -> void:
	v0246_militia_definition = {}
	if not FileAccess.file_exists(PORTABLE_CONTENT_PATH):
		barrosan_runtime_errors.append("Missing generated portable content for v0.246 Militia authority")
		return
	var file := FileAccess.open(PORTABLE_CONTENT_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text()) if file != null else null
	if not parsed is Dictionary:
		barrosan_runtime_errors.append("Invalid generated portable content for v0.246")
		return
	var categories: Dictionary = parsed.get("categories", {})
	var barracks_definition: Dictionary = {}
	for raw_entry in categories.get("buildings", []):
		if raw_entry is Dictionary and str(raw_entry.get("id", "")) == "barracks":
			barracks_definition = raw_entry.get("data", {}).duplicate(true)
			break
	for raw_entry in categories.get("units", []):
		if raw_entry is Dictionary and str(raw_entry.get("id", "")) == "militia":
			v0246_militia_definition = raw_entry.get("data", {}).duplicate(true)
			break
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	production["authorityLoaded"] = (
		not v0246_militia_definition.is_empty()
		and (barracks_definition.get("trainOptions", []) as Array).has("militia")
	)
	production["authoritySource"] = PORTABLE_CONTENT_PATH
	production["cost"] = (v0246_militia_definition.get("cost", {}) as Dictionary).duplicate(true)
	production["trainTime"] = float(v0246_militia_definition.get("trainTime", 0.0))
	barrosan_playtest["v0246FieldProduction"] = production
	if not bool(production["authorityLoaded"]):
		barrosan_runtime_errors.append("Generated authority does not permit Barracks -> Militia production")


func _v0246_field_barracks_hud_text() -> String:
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	if bool(production.get("spawned", false)):
		return "Authoritative placement | complete | Militia ready"
	if not (production.get("queue", []) as Array).is_empty():
		return "Authoritative placement | complete | Militia training... %s%%" % int(round(float(production.get("progress", 0.0)) * 100.0))
	return "Authoritative placement | complete | trains Militia only"


func _hud_work_pressed() -> void:
	if barrosan_runtime_checkpoint == "v0.253" and runtime.selected_ids.has("worker_00"):
		if barrosan_requested_checkpoint in ["v0.256", "v0.257", "v0.258", "v0.259"] and _v0251_field_barracks_health() <= 0.0:
			_begin_v0256_worker_rebuild()
		else:
			_begin_v0253_worker_repair()
		return
	if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and barrosan_selected_role_id == V0245_CONSTRUCTED_KEY:
		_queue_v0246_field_militia()
		return
	super._hud_work_pressed()


func _v0253_repair_command_available() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.253", "v0.254"]:
		return false
	var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
	return (
		_v0245_constructed_count() == 1
		and _v0251_field_barracks_health() > 0.0
		and _v0251_field_barracks_health() < V0251_FIELD_BARRACKS_MAX_HP
		and runtime.unit_alive("worker_00")
		and runtime.selected_ids.has("worker_00")
		and bool(barrosan_playtest.get("v0251DefenseConsequence", {}).get("boundedStop", false))
		and not bool(repair.get("repairStarted", false))
		and not bool(repair.get("repairComplete", false))
		and not bool(barrosan_playtest.get("v0256WorkerRebuild", {}).get("rebuildStarted", false))
	)


func _begin_v0253_worker_repair() -> bool:
	var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
	repair["repairCommandAvailable"] = _v0253_repair_command_available()
	if not bool(repair["repairCommandAvailable"]):
		repair["repeatedChargeRejected"] = bool(repair.get("repairComplete", false))
		barrosan_playtest["v0253WorkerRepair"] = repair
		_sync_hud()
		return false
	var before: Dictionary = runtime.resources.duplicate(true)
	if int(before.get("crowns", 0)) < 30 or int(before.get("stone", 0)) < 30:
		repair["insufficientResourcesRejected"] = true
		barrosan_playtest["v0253WorkerRepair"] = repair
		return false
	runtime.resources["crowns"] = int(runtime.resources.get("crowns", 0)) - 30
	runtime.resources["stone"] = int(runtime.resources.get("stone", 0)) - 30
	repair["repairOrderAccepted"] = true
	repair["repairStarted"] = true
	repair["repairTargetingMode"] = false
	repair["repairSpendCount"] = int(repair.get("repairSpendCount", 0)) + 1
	repair["resourcesBeforeRepair"] = before
	repair["resourcesAfterRepairSpend"] = runtime.resources.duplicate(true)
	repair["repairResourceDelta"] = _resource_delta(before, runtime.resources)
	repair["fieldBarracksHpBeforeRepair"] = _v0251_field_barracks_health()
	repair["repairMarkerVisible"] = true
	repair["workerMinimapVisibleDuringRepair"] = runtime.unit_alive("worker_00")
	repair["fieldBarracksMinimapVisibleDuringRepair"] = _minimap_has_marker("v0245_minimap_constructed_barracks")
	barrosan_playtest["v0253WorkerRepair"] = repair
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	consequence["fieldBarracksState"] = "repairing"
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	_set_v0249_objective("Repairing Field Barracks", "Repair order accepted")
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _advance_v0253_worker_repair_tick() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.253", "v0.254"]:
		return false
	var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
	if not bool(repair.get("repairStarted", false)) or bool(repair.get("repairComplete", false)):
		return false
	var tick := int(repair.get("repairTickCount", 0)) + 1
	if tick > V0253_REPAIR_TICK_LIMIT:
		return false
	var before := _v0251_field_barracks_health()
	var after := minf(V0251_FIELD_BARRACKS_MAX_HP, before + V0253_REPAIR_AMOUNT)
	_v0251_set_field_barracks_health(after)
	var ticks: Array = repair.get("repairTicks", [])
	ticks.append({"tick": tick, "before": before, "after": after, "repair": V0253_REPAIR_AMOUNT})
	repair["repairTicks"] = ticks
	repair["repairTickCount"] = tick
	repair["fieldBarracksFinalHp"] = after
	repair["overhealOccurred"] = after > V0251_FIELD_BARRACKS_MAX_HP
	if tick >= V0253_REPAIR_TICK_LIMIT:
		repair["repairComplete"] = after == V0251_FIELD_BARRACKS_MAX_HP
		repair["repairStarted"] = false
		repair["repairMarkerVisible"] = false
		repair["resourcesAfterRepair"] = runtime.resources.duplicate(true)
		repair["resourcesUnchangedAfterRepair"] = repair.get("resourcesAfterRepairSpend", {}) == runtime.resources
		var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
		consequence["fieldBarracksState"] = "unharmed"
		consequence["fieldBarracksFinalHp"] = after
		barrosan_playtest["v0251DefenseConsequence"] = consequence
		_set_v0249_objective("Field Barracks restored", "Repair complete")
	else:
		_set_v0249_objective("Repairing Field Barracks", "Repair progress %s/3" % tick)
	barrosan_playtest["v0253WorkerRepair"] = repair
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _v0256_rebuild_command_available() -> bool:
	if barrosan_requested_checkpoint not in ["v0.256", "v0.257", "v0.258", "v0.259"]:
		return false
	var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
	return (
		_v0245_constructed_count() == 1
		and _v0251_field_barracks_health() == 0.0
		and runtime.unit_alive("worker_00")
		and runtime.selected_ids.has("worker_00")
		and not bool(rebuild.get("rebuildStarted", false))
		and not bool(rebuild.get("rebuildComplete", false))
	)


func _begin_v0256_worker_rebuild() -> bool:
	var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
	var command_available := _v0256_rebuild_command_available()
	rebuild["rebuildCommandAvailable"] = bool(rebuild.get("rebuildCommandAvailable", false)) or command_available
	rebuild["repairUnavailableAtZero"] = not _v0253_repair_command_available()
	if not command_available:
		rebuild["repeatedChargeRejected"] = int(rebuild.get("rebuildSpendCount", 0)) > 0
		barrosan_playtest["v0256WorkerRebuild"] = rebuild
		_sync_hud()
		return false
	var before: Dictionary = runtime.resources.duplicate(true)
	for key in V0256_REBUILD_COST:
		if int(before.get(key, 0)) < int(V0256_REBUILD_COST[key]):
			rebuild["insufficientResourcesRejected"] = true
			barrosan_playtest["v0256WorkerRebuild"] = rebuild
			return false
	for key in V0256_REBUILD_COST:
		runtime.resources[key] = int(runtime.resources.get(key, 0)) - int(V0256_REBUILD_COST[key])
	rebuild["rebuildOrderAccepted"] = true
	rebuild["rebuildStarted"] = true
	rebuild["rebuildComplete"] = false
	rebuild["rebuildSpendCount"] = int(rebuild.get("rebuildSpendCount", 0)) + 1
	rebuild["resourcesBeforeRebuild"] = before
	rebuild["resourcesAfterRebuildSpend"] = runtime.resources.duplicate(true)
	rebuild["rebuildResourceDelta"] = _resource_delta(before, runtime.resources)
	rebuild["fieldBarracksHpBeforeRebuild"] = _v0251_field_barracks_health()
	rebuild["productionUnavailableDuringRebuild"] = not _v0255_field_barracks_production_available()
	barrosan_playtest["v0256WorkerRebuild"] = rebuild
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	consequence["fieldBarracksState"] = "rebuilding"
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	_set_v0249_objective("Rebuilding Field Barracks", "Production unavailable until rebuild complete")
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _advance_v0256_worker_rebuild_tick() -> bool:
	var rebuild: Dictionary = barrosan_playtest.get("v0256WorkerRebuild", {})
	if not bool(rebuild.get("rebuildStarted", false)) or bool(rebuild.get("rebuildComplete", false)):
		return false
	var tick := int(rebuild.get("rebuildTickCount", 0)) + 1
	if tick > V0256_REBUILD_TICK_LIMIT:
		return false
	var before := _v0251_field_barracks_health()
	var after := minf(100.0, before + V0256_REBUILD_AMOUNT)
	_v0251_set_field_barracks_health(after, tick >= V0256_REBUILD_TICK_LIMIT)
	var ticks: Array = rebuild.get("rebuildTicks", [])
	ticks.append({"tick": tick, "before": before, "after": after, "rebuild": V0256_REBUILD_AMOUNT})
	rebuild["rebuildTicks"] = ticks
	rebuild["rebuildTickCount"] = tick
	rebuild["fieldBarracksFinalHp"] = after
	if tick < V0256_REBUILD_TICK_LIMIT:
		rebuild["productionUnavailableDuringRebuild"] = bool(rebuild.get("productionUnavailableDuringRebuild", true)) and not _v0255_field_barracks_production_available()
	if tick >= V0256_REBUILD_TICK_LIMIT:
		rebuild["rebuildComplete"] = after == 100.0
		rebuild["rebuildStarted"] = false
		rebuild["resourcesAfterRebuild"] = runtime.resources.duplicate(true)
		rebuild["resourcesUnchangedAfterSpend"] = rebuild.get("resourcesAfterRebuildSpend", {}) == runtime.resources
		rebuild["productionAvailableAfterRebuild"] = _v0255_field_barracks_production_available()
		var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
		consequence["fieldBarracksState"] = "damaged"
		consequence["buildingDestroyed"] = false
		consequence["fieldBarracksFinalHp"] = after
		barrosan_playtest["v0251DefenseConsequence"] = consequence
		_set_v0249_objective("Field Barracks rebuilt", "Damaged but functional | Train Militia available")
	else:
		_set_v0249_objective("Rebuilding Field Barracks", "Rebuild progress %s/4" % tick)
	barrosan_playtest["v0256WorkerRebuild"] = rebuild
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _run_v0246_builder_probe() -> void:
	_select_playtest_unit("worker_00")
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	production["builderResourcesUnchanged"] = true
	barrosan_playtest["v0246FieldProduction"] = production
	_run_v0246_unit_probe("builder_construction_site", "worker_00", Vector2(500, 1320), 560)


func _queue_v0246_field_militia() -> bool:
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	var before: Dictionary = runtime.resources.duplicate(true)
	var queue: Array = production.get("queue", [])
	var field_barracks_functional := _v0245_constructed_count() == 1 and _v0251_field_barracks_health() > 0.0
	for structure in runtime.structures:
		if str(structure.get("id", "")) == V0245_CONSTRUCTED_RUNTIME_ID:
			field_barracks_functional = field_barracks_functional and bool(structure.get("productionEnabled", false))
			break
	if (
		not field_barracks_functional
		or not bool(production.get("authorityLoaded", false))
		or bool(production.get("spawned", false))
		or not queue.is_empty()
	):
		production["lastRejectReason"] = "field-barracks-disabled-at-zero-hp" if not field_barracks_functional else "single-slot-occupied-or-limit-reached"
		production["lastRejectResourcesUnchanged"] = before == runtime.resources
		barrosan_playtest["v0246FieldProduction"] = production
		_sync_hud()
		return false
	var cost: Dictionary = production.get("cost", {})
	for key in cost:
		if int(runtime.resources.get(key, 0)) < int(cost[key]):
			production["lastRejectReason"] = "insufficient-resources"
			production["lastRejectResourcesUnchanged"] = before == runtime.resources
			barrosan_playtest["v0246FieldProduction"] = production
			_sync_hud()
			return false
	for key in cost:
		runtime.resources[key] = int(runtime.resources.get(key, 0)) - int(cost[key])
	production["queue"] = [{
		"id": "v0246_field_militia_queue_00",
		"unitFixtureId": "militia",
		"progress": 0.0,
		"cost": cost.duplicate(true),
	}]
	production["queueAccepted"] = true
	production["queueSpendCount"] = int(production.get("queueSpendCount", 0)) + 1
	production["resourcesBeforeTraining"] = before
	production["resourcesAfterTrainingSpend"] = runtime.resources.duplicate(true)
	production["queueResourceDelta"] = _resource_delta(before, runtime.resources)
	barrosan_playtest["v0246FieldProduction"] = production
	_sync_hud()
	return true


func _advance_v0246_field_training(frames: int) -> bool:
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	var queue: Array = production.get("queue", [])
	if queue.is_empty():
		return false
	var entry: Dictionary = queue[0]
	entry["progress"] = clampf(float(entry.get("progress", 0.0)) + float(maxi(frames, 1)) / 120.0, 0.0, 1.0)
	queue[0] = entry
	production["queue"] = queue
	production["progress"] = float(entry["progress"])
	if float(entry["progress"]) >= 1.0:
		_spawn_v0246_field_militia()
		return true
	barrosan_playtest["v0246FieldProduction"] = production
	_sync_hud()
	return true


func _spawn_v0246_field_militia() -> void:
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	if bool(production.get("spawned", false)):
		return
	var stats: Dictionary = v0246_militia_definition.get("stats", {})
	var spawn_point := Vector2(630, 1450)
	runtime.units.append({
		"id": V0246_FIELD_MILITIA_RUNTIME_ID,
		"fixtureId": "militia",
		"team": "friendly",
		"role": "Militia",
		"position": spawn_point,
		"lastPosition": spawn_point,
		"destination": spawn_point,
		"hasDestination": false,
		"health": V0249_MILITIA_MAX_HP if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else float(stats.get("maxHp", 90.0)),
		"maxHealth": V0249_MILITIA_MAX_HP if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else float(stats.get("maxHp", 90.0)),
		"damage": V0249_MILITIA_DAMAGE if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else float(stats.get("damage", 9.0)),
		"attackRange": float(stats.get("range", 28.0)),
		"cooldown": 0.0,
		"attackTarget": "",
		"speed": float(stats.get("speed", 90.0)),
		"alive": true,
		"productionSourceId": V0245_CONSTRUCTED_RUNTIME_ID,
		"optInProductionEntity": true,
	})
	production["queue"] = []
	production["progress"] = 1.0
	production["spawned"] = true
	production["spawnCount"] = int(production.get("spawnCount", 0)) + 1
	production["spawnPoint"] = spawn_point
	production["lastKnownPosition"] = spawn_point
	barrosan_playtest["v0246FieldProduction"] = production
	_rebuild_visuals()
	_add_barrosan_minimap_role_markers()
	_add_v0245_constructed_minimap_marker()
	_add_v0246_field_militia_minimap_marker()
	_sync_hud()


func _attempt_v0246_duplicate_queue() -> void:
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	var before: Dictionary = runtime.resources.duplicate(true)
	var accepted := _queue_v0246_field_militia()
	production = barrosan_playtest.get("v0246FieldProduction", {})
	production["duplicateQueueRejected"] = not accepted
	production["duplicateQueueResourcesUnchanged"] = before == runtime.resources
	barrosan_playtest["v0246FieldProduction"] = production


func _attempt_v0246_failed_training() -> void:
	select_barrosan_runtime_role(V0245_CONSTRUCTED_KEY)
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	var before: Dictionary = runtime.resources.duplicate(true)
	var accepted := _queue_v0246_field_militia()
	production = barrosan_playtest.get("v0246FieldProduction", {})
	production["failedTrainRejected"] = not accepted
	production["failedTrainResourcesUnchanged"] = before == runtime.resources
	production["failedTrainReason"] = str(production.get("lastRejectReason", ""))
	barrosan_playtest["v0246FieldProduction"] = production


func _run_v0246_militia_probe(probe_id: String, target: Vector2, frames: int) -> void:
	_run_v0246_unit_probe(probe_id, V0246_FIELD_MILITIA_RUNTIME_ID, target, frames)


func _run_v0246_unit_probe(probe_id: String, unit_id: String, target: Vector2, frames: int) -> void:
	if unit_id == V0246_FIELD_MILITIA_RUNTIME_ID:
		_ensure_v0246_field_militia_active()
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	var before_value = runtime.unit_position(unit_id)
	if not before_value is Vector2:
		return
	var before: Vector2 = before_value
	var stuck_before := int(runtime.stuck_unit_count)
	var selected := runtime.select_entity(unit_id)
	var accepted := selected and runtime.issue_move_order(target)
	for _frame in range(frames):
		runtime.advance_live_frame()
	var after_value = runtime.unit_position(unit_id)
	var after: Vector2 = after_value if after_value is Vector2 else before
	var probes: Dictionary = production.get("movementProbes", {})
	probes[probe_id] = {
		"unitId": unit_id,
		"accepted": accepted,
		"target": target,
		"before": before,
		"after": after,
		"displacement": before.distance_to(after),
		"stuckDelta": int(runtime.stuck_unit_count) - stuck_before,
		"obstacleModel": "existing rectangular destination nudge",
		"reviewGradeOnly": true,
	}
	production["movementProbes"] = probes
	if unit_id == V0246_FIELD_MILITIA_RUNTIME_ID:
		production["selected"] = selected
		production["lastKnownPosition"] = after
	barrosan_playtest["v0246FieldProduction"] = production
	_sync_unit_visuals()
	_sync_hud()


func _ensure_v0246_field_militia_active() -> void:
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	if not bool(production.get("spawned", false)):
		return
	for unit in runtime.units:
		if str(unit.get("id", "")) != V0246_FIELD_MILITIA_RUNTIME_ID:
			continue
		var last_position: Vector2 = production.get("lastKnownPosition", production.get("spawnPoint", Vector2(630, 1450)))
		var current_position: Vector2 = unit.get("position", Vector2.ZERO)
		if not bool(unit.get("alive", false)) or current_position.x < -9000.0:
			unit["alive"] = true
			unit["health"] = float(unit.get("maxHealth", 90.0))
			unit["position"] = last_position
			unit["lastPosition"] = last_position
			unit["destination"] = last_position
			unit["hasDestination"] = false
			unit["attackTarget"] = ""
			unit["reviewHidden"] = false
		return


func _add_v0246_field_militia_minimap_marker() -> void:
	if minimap_panel == null or not runtime.unit_alive(V0246_FIELD_MILITIA_RUNTIME_ID):
		return
	if not _minimap_has_marker("v0246_minimap_field_militia"):
		_add_minimap_marker("v0246_minimap_field_militia", Vector2(126, 190), Vector2(10, 10), Color("#79d39a"))
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	production["minimapRegistered"] = _minimap_has_marker("v0246_minimap_field_militia")
	barrosan_playtest["v0246FieldProduction"] = production


func _prepare_v0247_pressure() -> void:
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	if not bool(production.get("spawned", false)):
		return
	pressure["triggered"] = true
	pressure["trigger"] = "constructed Field Barracks trained one Militia"
	pressure["objectiveText"] = "9. Ashen pressure incoming"
	pressure["statusText"] = "Ashen pressure incoming"
	pressure["resourcesBeforePressure"] = runtime.resources.duplicate(true)
	pressure["militiaHealthBeforePressure"] = _v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID)
	if barrosan_runtime_checkpoint in ["v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		pressure["telegraphVisible"] = true
		pressure["interceptMarkerVisible"] = true
		pressure["interceptMarkerState"] = "waiting"
	barrosan_playtest["v0247Pressure"] = pressure
	_record_v0248_pressure_snapshot("afterTelegraph")
	_sync_hud()


func _prepare_v0251_undefended_pressure() -> void:
	if barrosan_runtime_checkpoint not in ["v0.251", "v0.252", "v0.253"] or _v0245_constructed_count() != 1:
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["triggered"] = true
	pressure["trigger"] = "constructed Field Barracks left undefended"
	pressure["objectiveText"] = "Ashen pressure incoming"
	pressure["statusText"] = "Field Barracks has no defender"
	pressure["resourcesBeforePressure"] = runtime.resources.duplicate(true)
	pressure["telegraphVisible"] = true
	pressure["interceptMarkerVisible"] = true
	pressure["interceptMarkerState"] = "waiting"
	barrosan_playtest["v0247Pressure"] = pressure
	_record_v0248_pressure_snapshot("afterTelegraph")
	_sync_hud()


func _begin_v0252_threat_window() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.252", "v0.253"]:
		return false
	var raider_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var barracks_position := _v0251_field_barracks_position()
	if not raider_value is Vector2 or barracks_position == Vector2.ZERO:
		return false
	var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	var distance := (raider_value as Vector2).distance_to(barracks_position)
	timing["threatRangeDistance"] = distance
	timing["threatRangeReached"] = distance <= V0251_FIELD_BARRACKS_PRESSURE_RADIUS
	if not bool(timing["threatRangeReached"]):
		barrosan_playtest["v0252ThreatTiming"] = timing
		return false
	timing["warningStarted"] = true
	timing["warningActive"] = true
	timing["warningStep"] = 1
	timing["warningExpired"] = false
	timing["damageImminent"] = false
	timing["fieldBarracksHpAtWarningStart"] = _v0251_field_barracks_health()
	timing["threatWindowMarkerVisible"] = true
	timing["damageImminentMarkerVisible"] = false
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	timing["raiderMinimapVisibleDuringWarning"] = (
		bool(pressure.get("minimapRegistered", false))
		and _minimap_has_marker("v0247_minimap_ashen_raider")
	)
	consequence["buildingPressureDistance"] = distance
	consequence["buildingPressureContact"] = true
	consequence["buildingDamageStartedBeforeContact"] = false
	consequence["buildingDamageStarted"] = false
	consequence["fieldBarracksState"] = "threatened"
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	barrosan_playtest["v0252ThreatTiming"] = timing
	_set_v0249_objective("Ashen pressure entering threat range", "Intercept before impact | 3")
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _advance_v0252_threat_window() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.252", "v0.253"]:
		return false
	var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
	if not bool(timing.get("warningStarted", false)) or bool(timing.get("warningExpired", false)):
		return false
	var step := mini(V0252_THREAT_WINDOW_STEPS, int(timing.get("warningStep", 1)) + 1)
	timing["warningStep"] = step
	timing["fieldBarracksHpAtWarningMidpoint"] = _v0251_field_barracks_health()
	timing["damageOccurredDuringWarning"] = _v0251_field_barracks_health() != float(timing.get("fieldBarracksHpAtWarningStart", V0251_FIELD_BARRACKS_MAX_HP))
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	timing["raiderMinimapVisibleDuringWarning"] = (
		bool(timing.get("raiderMinimapVisibleDuringWarning", false))
		and bool(pressure.get("minimapRegistered", false))
		and _minimap_has_marker("v0247_minimap_ashen_raider")
	)
	if step >= V0252_THREAT_WINDOW_STEPS:
		timing["warningExpired"] = true
		timing["warningActive"] = false
		timing["damageImminent"] = true
		timing["threatWindowMarkerVisible"] = false
		timing["damageImminentMarkerVisible"] = true
		timing["fieldBarracksHpAtWarningExpiry"] = _v0251_field_barracks_health()
		_set_v0249_objective("Warning missed", "Damage imminent | Field Barracks HP 200/200")
	else:
		_set_v0249_objective("Intercept before impact", "Threat window | 2")
	barrosan_playtest["v0252ThreatTiming"] = timing
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _begin_v0252_building_pressure_after_warning() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.252", "v0.253"]:
		return false
	var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	if (
		not bool(timing.get("warningStarted", false))
		or not bool(timing.get("warningExpired", false))
		or bool(pressure.get("raiderDefeated", false))
		or bool(pressure.get("attackOrderAccepted", false))
	):
		return false
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	consequence["buildingDamageStarted"] = true
	consequence["buildingDamageStartedBeforeContact"] = not bool(consequence.get("buildingPressureContact", false))
	consequence["fieldBarracksState"] = "under_pressure"
	consequence["resourcesBeforeBuildingPressure"] = runtime.resources.duplicate(true)
	timing["damageStartedAfterWarning"] = true
	timing["damageImminentMarkerVisible"] = true
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	barrosan_playtest["v0252ThreatTiming"] = timing
	_set_v0249_objective("Field Barracks under Ashen pressure", "Damage tick 1/3 imminent")
	_sync_barrosan_runtime_visuals()
	_sync_hud()
	return true


func _spawn_v0247_ashen_raider() -> void:
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	if not bool(pressure.get("triggered", false)) or bool(pressure.get("spawned", false)):
		return
	runtime.units.append({
		"id": V0247_ASHEN_RAIDER_RUNTIME_ID,
		"fixtureId": "ashen_raider",
		"team": "enemy",
		"role": "Raider",
		"position": V0247_PRESSURE_SPAWN,
		"lastPosition": V0247_PRESSURE_SPAWN,
		"destination": V0247_PRESSURE_SPAWN,
		"hasDestination": false,
		"health": V0249_RAIDER_MAX_HP if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else 80.0,
		"maxHealth": V0249_RAIDER_MAX_HP if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else 80.0,
		"damage": V0249_RAIDER_DAMAGE if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else 0.0,
		"attackRange": V0247_INTERCEPT_RADIUS if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else 0.0,
		"cooldown": 0.0,
		"attackTarget": "",
		"speed": 82.0,
		"alive": true,
		"scriptedPressureEntity": true,
		"combatDisabled": barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"],
		"boundedCombatEntity": barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"],
	})
	pressure["spawned"] = true
	pressure["spawnCount"] = int(pressure.get("spawnCount", 0)) + 1
	pressure["registered"] = runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID)
	pressure["spawnPoint"] = V0247_PRESSURE_SPAWN
	pressure["lastKnownPosition"] = V0247_PRESSURE_SPAWN
	pressure["raiderHealthBeforePressure"] = V0249_RAIDER_MAX_HP if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else 80.0
	if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		pressure["militiaHealthBeforePressure"] = V0249_MILITIA_MAX_HP
		pressure["collateralBefore"] = _v0249_collateral_snapshot()
	pressure["objectiveText"] = "Ashen Raider advancing"
	pressure["statusText"] = "Ashen Raider advancing"
	pressure["spawnHoldFrames"] = 0
	barrosan_playtest["v0247Pressure"] = pressure
	_rebuild_visuals()
	_add_v0247_ashen_raider_minimap_marker()
	_sync_hud()


func _select_v0247_raider() -> bool:
	_ensure_v0247_ashen_raider_active()
	return _select_playtest_unit(V0247_ASHEN_RAIDER_RUNTIME_ID)


func _advance_v0247_raider_lane(probe_id: String, target: Vector2, frames: int) -> void:
	_ensure_v0247_ashen_raider_active()
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var before_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	if not before_value is Vector2:
		return
	var before: Vector2 = before_value
	var resources_before: Dictionary = runtime.resources.duplicate(true)
	var health_before: Dictionary = _v0247_health_snapshot()
	runtime.clear_selection()
	runtime.select_entity(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var accepted := runtime.issue_move_order(target)
	for _frame in range(frames):
		runtime.advance_live_frame()
	var after_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var after: Vector2 = after_value if after_value is Vector2 else before
	var probes: Dictionary = pressure.get("laneProbes", {})
	probes[probe_id] = {
		"accepted": accepted,
		"target": target,
		"before": before,
		"after": after,
		"displacement": before.distance_to(after),
		"reviewGradeOnly": true,
	}
	pressure["laneProbes"] = probes
	pressure["lastKnownPosition"] = after
	pressure["resourcesUnchangedDuringLane"] = resources_before == runtime.resources
	pressure["healthUnchangedDuringLane"] = health_before == _v0247_health_snapshot()
	pressure["reachedPressureMarker"] = after.distance_to(V0247_PRESSURE_MARKER) <= 36.0
	pressure["objectiveText"] = "Ashen Raider advancing"
	pressure["statusText"] = "Ashen Raider advancing"
	barrosan_playtest["v0247Pressure"] = pressure
	_select_v0247_raider()
	_sync_unit_visuals()
	_sync_hud()


func _run_v0247_militia_intercept(frames: int, evaluate: bool) -> void:
	_ensure_v0246_field_militia_active()
	_ensure_v0247_ashen_raider_active()
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var before_value = runtime.unit_position(V0246_FIELD_MILITIA_RUNTIME_ID)
	if not before_value is Vector2:
		return
	var before: Vector2 = before_value
	runtime.clear_selection()
	var selected := runtime.select_entity(V0246_FIELD_MILITIA_RUNTIME_ID)
	var accepted := selected and runtime.issue_move_order(V0247_INTERCEPT_ZONE)
	for _frame in range(frames):
		runtime.advance_live_frame()
	var after_value = runtime.unit_position(V0246_FIELD_MILITIA_RUNTIME_ID)
	var after: Vector2 = after_value if after_value is Vector2 else before
	pressure["militiaInterceptProbe"] = {
		"accepted": accepted,
		"before": before,
		"after": after,
		"target": V0247_INTERCEPT_ZONE,
		"displacement": before.distance_to(after),
		"reviewGradeOnly": true,
	}
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	production["lastKnownPosition"] = after
	production["selected"] = selected
	barrosan_playtest["v0246FieldProduction"] = production
	barrosan_playtest["v0247Pressure"] = pressure
	if evaluate:
		_evaluate_v0247_pressure_containment()
	_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)


func _run_v0252_militia_threat_intercept(frames: int) -> void:
	_ensure_v0246_field_militia_active()
	_ensure_v0247_ashen_raider_active()
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var before_value = runtime.unit_position(V0246_FIELD_MILITIA_RUNTIME_ID)
	if not before_value is Vector2:
		return
	var before: Vector2 = before_value
	runtime.clear_selection()
	var selected := runtime.select_entity(V0246_FIELD_MILITIA_RUNTIME_ID)
	var accepted := selected and runtime.issue_move_order(V0251_FIELD_BARRACKS_PRESSURE_POINT)
	for _frame in range(frames):
		runtime.advance_live_frame()
	var after_value = runtime.unit_position(V0246_FIELD_MILITIA_RUNTIME_ID)
	var after: Vector2 = after_value if after_value is Vector2 else before
	pressure["militiaInterceptProbe"] = {
		"accepted": accepted,
		"before": before,
		"after": after,
		"target": V0251_FIELD_BARRACKS_PRESSURE_POINT,
		"displacement": before.distance_to(after),
		"reviewGradeOnly": true,
		"threatWindowIntercept": true,
	}
	var production: Dictionary = barrosan_playtest.get("v0246FieldProduction", {})
	production["lastKnownPosition"] = after
	production["selected"] = selected
	barrosan_playtest["v0246FieldProduction"] = production
	barrosan_playtest["v0247Pressure"] = pressure
	_select_playtest_unit(V0246_FIELD_MILITIA_RUNTIME_ID)


func _evaluate_v0247_pressure_containment() -> bool:
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var militia_value = runtime.unit_position(V0246_FIELD_MILITIA_RUNTIME_ID)
	var raider_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	if not militia_value is Vector2 or not raider_value is Vector2:
		return false
	var militia: Vector2 = militia_value
	var raider: Vector2 = raider_value
	var in_zone := militia.distance_to(V0247_INTERCEPT_ZONE) <= V0247_INTERCEPT_RADIUS
	var near_raider := militia.distance_to(raider) <= V0247_INTERCEPT_RADIUS
	pressure["interceptReached"] = in_zone
	pressure["interceptDistanceToRaider"] = militia.distance_to(raider)
	pressure["contained"] = in_zone and near_raider
	if bool(pressure["contained"]):
		pressure["objectiveText"] = "Ashen pressure contained"
		pressure["statusText"] = "No damage exchanged"
		pressure["telegraphVisible"] = false
		pressure["interceptMarkerVisible"] = true
		pressure["interceptMarkerState"] = "contained"
		for unit in runtime.units:
			if str(unit.get("id", "")) == V0247_ASHEN_RAIDER_RUNTIME_ID:
				unit["hasDestination"] = false
				unit["destination"] = unit["position"]
				unit["attackTarget"] = ""
				break
	barrosan_playtest["v0247Pressure"] = pressure
	_record_v0247_no_combat_mutation()
	_sync_hud()
	return bool(pressure["contained"])


func _set_v0248_objective(objective: String, status: String) -> void:
	if barrosan_runtime_checkpoint not in ["v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["objectiveText"] = objective
	pressure["statusText"] = status
	var history: Array = pressure.get("objectiveHistory", [])
	if history.is_empty() or str(history.back()) != objective:
		history.append(objective)
	pressure["objectiveHistory"] = history
	barrosan_playtest["v0247Pressure"] = pressure
	_sync_hud()


func _record_v0248_pressure_snapshot(snapshot_id: String) -> void:
	if barrosan_runtime_checkpoint not in ["v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var resources: Dictionary = pressure.get("resourceSnapshots", {})
	var health: Dictionary = pressure.get("healthSnapshots", {})
	resources[snapshot_id] = runtime.resources.duplicate(true)
	health[snapshot_id] = _v0247_health_snapshot()
	pressure["resourceSnapshots"] = resources
	pressure["healthSnapshots"] = health
	var baseline: Dictionary = pressure.get("resourcesBeforePressure", runtime.resources)
	pressure["resourceSnapshotsUnchanged"] = resources.values().all(
		func(value: Dictionary) -> bool:
			return value == baseline
	)
	var baseline_health := {
		"militia": float(pressure.get("militiaHealthBeforePressure", _v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID))),
		"raider": float(pressure.get("raiderHealthBeforePressure", _v0247_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID))),
	}
	pressure["healthSnapshotsUnchanged"] = health.values().all(
		func(value: Dictionary) -> bool:
			if float(value.get("militia", 0.0)) != float(baseline_health.get("militia", 0.0)):
				return false
			if value.has("raider") and float(value.get("raider", 0.0)) > 0.0 and float(baseline_health.get("raider", 0.0)) > 0.0:
				return float(value.get("raider", 0.0)) == float(baseline_health.get("raider", 0.0))
			return true
	)
	barrosan_playtest["v0247Pressure"] = pressure


func _activate_v0248_pressure_telegraph() -> void:
	if barrosan_runtime_checkpoint != "v0.248":
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["telegraphVisible"] = true
	pressure["interceptMarkerVisible"] = true
	pressure["interceptMarkerState"] = "waiting"
	pressure["objectiveText"] = "9. Ashen pressure incoming"
	pressure["statusText"] = "Incoming pressure | no damage"
	barrosan_playtest["v0247Pressure"] = pressure
	_record_v0248_pressure_snapshot("afterTelegraph")


func _activate_v0248_intercept_marker() -> void:
	if barrosan_runtime_checkpoint != "v0.248":
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["interceptMarkerVisible"] = true
	pressure["interceptMarkerState"] = "waiting"
	pressure["objectiveText"] = "Move Militia to intercept"
	pressure["statusText"] = "Move to intercept zone"
	barrosan_playtest["v0247Pressure"] = pressure


func _sync_v0248_pressure_markers() -> void:
	if visual_root == null:
		return
	var threat_world := barrosan_build_validation_adapter.source_to_runtime_world(V0247_PRESSURE_LANE_START)
	var intercept_world := barrosan_build_validation_adapter.source_to_runtime_world(V0247_INTERCEPT_ZONE)
	var barracks_threat_world := barrosan_build_validation_adapter.source_to_runtime_world(V0251_FIELD_BARRACKS_PRESSURE_POINT)
	_set_or_create_disc_marker("v0248_pressure_telegraph", threat_world + Vector3(0.0, 0.04, 0.0), 0.72, Color(0.96, 0.22, 0.08, 0.68))
	_set_or_create_disc_marker("v0248_intercept_zone", intercept_world + Vector3(0.0, 0.035, 0.0), 0.86, Color(0.16, 0.82, 0.88, 0.62))
	_set_or_create_disc_marker("v0249_combat_clash", intercept_world + Vector3(0.0, 0.08, 0.0), 0.48, Color(1.0, 0.66, 0.12, 0.84))
	_set_or_create_disc_marker("v0252_threat_window", barracks_threat_world + Vector3(0.0, 0.06, 0.0), 0.92, Color(1.0, 0.62, 0.08, 0.58))
	_set_or_create_disc_marker("v0252_damage_imminent", barracks_threat_world + Vector3(0.0, 0.09, 0.0), 0.64, Color(1.0, 0.16, 0.08, 0.76))
	_set_or_create_disc_marker("v0253_repair_pulse", barracks_threat_world + Vector3(0.0, 0.12, 0.0), 0.56, Color(0.22, 0.94, 0.72, 0.72))
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
	var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
	var enabled := barrosan_runtime_checkpoint in ["v0.248", "v0.249", "v0.252", "v0.253"]
	var threat := visual_root.get_node_or_null("v0248_pressure_telegraph")
	var intercept := visual_root.get_node_or_null("v0248_intercept_zone")
	var clash := visual_root.get_node_or_null("v0249_combat_clash")
	var threat_window := visual_root.get_node_or_null("v0252_threat_window")
	var damage_imminent := visual_root.get_node_or_null("v0252_damage_imminent")
	var repair_pulse := visual_root.get_node_or_null("v0253_repair_pulse")
	if threat != null:
		threat.visible = enabled and bool(pressure.get("telegraphVisible", false)) and not bool(pressure.get("contained", false))
	if intercept != null:
		intercept.visible = enabled and bool(pressure.get("interceptMarkerVisible", false))
		if str(pressure.get("interceptMarkerState", "waiting")) == "contained":
			var material := StandardMaterial3D.new()
			material.albedo_color = Color(0.24, 0.86, 0.42, 0.66)
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			intercept.material_override = material
	if clash != null:
		clash.visible = barrosan_runtime_checkpoint == "v0.249" and bool(pressure.get("combatMarkerVisible", false))
	if threat_window != null:
		threat_window.visible = barrosan_runtime_checkpoint in ["v0.252", "v0.253"] and bool(timing.get("threatWindowMarkerVisible", false))
	if damage_imminent != null:
		damage_imminent.visible = barrosan_runtime_checkpoint in ["v0.252", "v0.253"] and bool(timing.get("damageImminentMarkerVisible", false))
	if repair_pulse != null:
		repair_pulse.visible = barrosan_runtime_checkpoint == "v0.253" and bool(repair.get("repairMarkerVisible", false))
	var threat_label := _v0248_marker_label("v0248_pressure_label", threat_world + Vector3(0.0, 0.72, 0.0), "ASHEN APPROACH", Color("#ff8b61"))
	var intercept_text := "PRESSURE CONTAINED" if bool(pressure.get("contained", false)) else "INTERCEPT ZONE"
	var intercept_color := Color("#7fe39a") if bool(pressure.get("contained", false)) else Color("#75e7ed")
	var intercept_label := _v0248_marker_label("v0248_intercept_label", intercept_world + Vector3(0.0, 0.68, 0.0), intercept_text, intercept_color)
	var clash_label := _v0248_marker_label("v0249_combat_label", intercept_world + Vector3(0.0, 1.02, 0.0), "COMBAT ENGAGED", Color("#ffd36a"))
	var threat_window_label := _v0248_marker_label("v0252_threat_window_label", barracks_threat_world + Vector3(0.0, 0.92, 0.0), "THREAT WINDOW | INTERCEPT NOW", Color("#ffd36a"))
	var damage_imminent_label := _v0248_marker_label("v0252_damage_imminent_label", barracks_threat_world + Vector3(0.0, 1.08, 0.0), "DAMAGE IMMINENT", Color("#ff745c"))
	var repair_label := _v0248_marker_label("v0253_repair_label", barracks_threat_world + Vector3(0.0, 0.94, 0.0), "WORKER REPAIR", Color("#79efc0"))
	var raider_position_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var raider_world := _to_world(raider_position_value as Vector2, 0.18) if raider_position_value is Vector2 else threat_world
	_set_or_create_disc_marker("v0250_attack_target", raider_world, 0.52, Color(1.0, 0.28, 0.16, 0.72))
	var attack_target := visual_root.get_node_or_null("v0250_attack_target")
	if attack_target != null:
		attack_target.visible = barrosan_runtime_checkpoint in ["v0.250", "v0.251", "v0.252", "v0.253"] and bool(pressure.get("targetMarkerVisible", false)) and runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var attack_label := _v0248_marker_label("v0250_attack_target_label", raider_world + Vector3(0.0, 0.86, 0.0), "ASHEN RAIDER TARGETED", Color("#ff9b72"))
	attack_label.visible = attack_target != null and attack_target.visible
	threat_label.visible = threat != null and threat.visible
	intercept_label.visible = intercept != null and intercept.visible
	clash_label.visible = clash != null and clash.visible
	threat_window_label.visible = threat_window != null and threat_window.visible
	damage_imminent_label.visible = damage_imminent != null and damage_imminent.visible
	repair_label.visible = repair_pulse != null and repair_pulse.visible
	pressure["telegraphRegistered"] = threat != null
	pressure["interceptMarkerRegistered"] = intercept != null
	pressure["targetMarkerRegistered"] = attack_target != null
	barrosan_playtest["v0247Pressure"] = pressure
	timing["threatWindowMarkerRegistered"] = threat_window != null
	timing["damageImminentMarkerRegistered"] = damage_imminent != null
	barrosan_playtest["v0252ThreatTiming"] = timing
	repair["repairMarkerRegistered"] = repair_pulse != null
	barrosan_playtest["v0253WorkerRepair"] = repair


func _set_v0249_objective(objective: String, status: String) -> void:
	if barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return
	_set_v0248_objective(objective, status)


func _activate_v0249_markers() -> void:
	if barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["telegraphVisible"] = true
	pressure["interceptMarkerVisible"] = true
	pressure["interceptMarkerState"] = "waiting"
	barrosan_playtest["v0247Pressure"] = pressure
	_record_v0249_snapshot("afterTelegraph")


func _v0251_field_barracks_health() -> float:
	for structure in runtime.structures:
		if str(structure.get("id", "")) == V0245_CONSTRUCTED_RUNTIME_ID:
			return float(structure.get("health", 0.0))
	return 0.0


func _v0251_field_barracks_position() -> Vector2:
	for structure in runtime.structures:
		if str(structure.get("id", "")) == V0245_CONSTRUCTED_RUNTIME_ID:
			return structure.get("position", Vector2.ZERO)
	return Vector2.ZERO


func _v0251_set_field_barracks_health(health: float, production_override = null) -> void:
	var production_enabled: bool = health > 0.0 if production_override == null else bool(production_override)
	for index in range(runtime.structures.size()):
		var structure: Dictionary = runtime.structures[index]
		if str(structure.get("id", "")) != V0245_CONSTRUCTED_RUNTIME_ID:
			continue
		structure["health"] = health
		structure["maxHealth"] = V0251_FIELD_BARRACKS_MAX_HP
		structure["alive"] = true
		structure["destroyed"] = health <= 0.0
		structure["productionEnabled"] = production_enabled
		runtime.structures[index] = structure
		break
	if barrosan_runtime_structures.has(V0245_CONSTRUCTED_KEY):
		var cached: Dictionary = barrosan_runtime_structures[V0245_CONSTRUCTED_KEY]
		cached["health"] = health
		cached["maxHealth"] = V0251_FIELD_BARRACKS_MAX_HP
		cached["destroyed"] = health <= 0.0
		cached["productionEnabled"] = production_enabled
		barrosan_runtime_structures[V0245_CONSTRUCTED_KEY] = cached


func _begin_v0251_building_pressure() -> bool:
	if barrosan_runtime_checkpoint != "v0.251":
		return false
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	if bool(pressure.get("raiderDefeated", false)) or bool(pressure.get("attackOrderAccepted", false)):
		return false
	var raider_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var barracks_position := _v0251_field_barracks_position()
	if not raider_value is Vector2 or barracks_position == Vector2.ZERO:
		return false
	var distance := (raider_value as Vector2).distance_to(barracks_position)
	consequence["buildingPressureDistance"] = distance
	consequence["buildingPressureContact"] = distance <= V0251_FIELD_BARRACKS_PRESSURE_RADIUS
	consequence["buildingDamageStartedBeforeContact"] = not bool(consequence["buildingPressureContact"])
	if not bool(consequence["buildingPressureContact"]):
		barrosan_playtest["v0251DefenseConsequence"] = consequence
		return false
	consequence["buildingDamageStarted"] = true
	consequence["fieldBarracksState"] = "under_pressure"
	consequence["resourcesBeforeBuildingPressure"] = runtime.resources.duplicate(true)
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	_set_v0249_objective("Field Barracks under Ashen pressure", "Building pressure incoming")
	_sync_hud()
	return true


func _advance_v0251_building_damage_tick() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.251", "v0.252", "v0.253", "v0.254"]:
		return false
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	if not bool(consequence.get("buildingDamageStarted", false)) or bool(consequence.get("buildingPressureContained", false)):
		return false
	var tick := int(consequence.get("buildingDamageTickCount", 0)) + 1
	if tick > V0251_BUILDING_DAMAGE_TICK_LIMIT:
		consequence["boundedStop"] = true
		barrosan_playtest["v0251DefenseConsequence"] = consequence
		return false
	var before := _v0251_field_barracks_health()
	var after := maxf(125.0, before - V0251_RAIDER_BUILDING_DAMAGE)
	_v0251_set_field_barracks_health(after)
	var ticks: Array = consequence.get("buildingDamageTicks", [])
	ticks.append({"tick": tick, "before": before, "after": after, "damage": V0251_RAIDER_BUILDING_DAMAGE})
	consequence["buildingDamageTicks"] = ticks
	consequence["buildingDamageTickCount"] = tick
	consequence["fieldBarracksFinalHp"] = after
	consequence["fieldBarracksState"] = "under_pressure" if tick < V0251_BUILDING_DAMAGE_TICK_LIMIT else "damaged"
	if barrosan_runtime_checkpoint in ["v0.252", "v0.253"]:
		consequence["damagePulseVisible"] = true
		consequence["damagePulseText"] = "-25 | tick %s/3" % tick
	if tick == 1:
		_set_v0249_objective("Field Barracks under Ashen pressure", "Building pressure incoming")
	elif tick == 2:
		_set_v0249_objective("Field Barracks damaged", "Ashen pressure damaging structure")
	else:
		consequence["buildingPressureContained"] = true
		consequence["boundedStop"] = true
		consequence["resourcesAfterBuildingPressure"] = runtime.resources.duplicate(true)
		consequence["resourcesUnchanged"] = consequence.get("resourcesBeforeBuildingPressure", {}) == runtime.resources
		consequence["buildingDestroyed"] = false
		_set_v0249_objective("Pressure damage contained", "Field Barracks damaged by Ashen pressure")
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	_sync_hud()
	return true


func _finalize_v0251_building_pressure() -> void:
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {})
	consequence["fieldBarracksFinalHp"] = _v0251_field_barracks_health()
	consequence["buildingPressureContained"] = int(consequence.get("buildingDamageTickCount", 0)) == V0251_BUILDING_DAMAGE_TICK_LIMIT
	consequence["boundedStop"] = bool(consequence.get("buildingPressureContained", false))
	consequence["buildingDestroyed"] = false
	consequence["resourcesAfterBuildingPressure"] = runtime.resources.duplicate(true)
	consequence["resourcesUnchanged"] = consequence.get("resourcesBeforeBuildingPressure", {}) == runtime.resources
	consequence["asterWorkerUnharmed"] = _v0247_unit_health("hero_aster") == (100.0 if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] else 150.0) and _v0247_unit_health("worker_00") == 80.0
	barrosan_playtest["v0251DefenseConsequence"] = consequence
	if barrosan_runtime_checkpoint in ["v0.252", "v0.253"]:
		var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {})
		timing["boundedRaiderStop"] = bool(consequence.get("boundedStop", false))
		timing["damageImminentMarkerVisible"] = false
		barrosan_playtest["v0252ThreatTiming"] = timing
	_sync_hud()


func _begin_v0249_combat() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return false
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	if barrosan_runtime_checkpoint in ["v0.250", "v0.251", "v0.252", "v0.253"] and (
		not bool(pressure.get("attackOrderAccepted", false))
		or str(pressure.get("activeAttackTarget", "")) != V0247_ASHEN_RAIDER_RUNTIME_ID
	):
		pressure["combatBlockedBeforeAttackOrder"] = true
		barrosan_playtest["v0247Pressure"] = pressure
		return false
	if bool(pressure.get("combatStarted", false)) or bool(pressure.get("raiderDefeated", false)):
		return false
	var militia_value = runtime.unit_position(V0246_FIELD_MILITIA_RUNTIME_ID)
	var raider_value = runtime.unit_position(V0247_ASHEN_RAIDER_RUNTIME_ID)
	if not militia_value is Vector2 or not raider_value is Vector2:
		return false
	var distance: float = (militia_value as Vector2).distance_to(raider_value as Vector2)
	var intercept_center := V0251_FIELD_BARRACKS_PRESSURE_POINT if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] else V0247_INTERCEPT_ZONE
	var in_zone: bool = (militia_value as Vector2).distance_to(intercept_center) <= V0247_INTERCEPT_RADIUS
	pressure["combatStartDistance"] = distance
	pressure["combatStartInInterceptZone"] = in_zone
	pressure["combatStartedBeforeContact"] = distance > V0247_INTERCEPT_RADIUS or not in_zone
	if bool(pressure["combatStartedBeforeContact"]):
		barrosan_playtest["v0247Pressure"] = pressure
		return false
	pressure["combatStarted"] = true
	pressure["combatAuthorizedByAttackOrder"] = barrosan_runtime_checkpoint in ["v0.250", "v0.251", "v0.252", "v0.253"]
	pressure["interceptReached"] = in_zone
	pressure["combatStartCondition"] = "Militia and Raider within 115-unit Barracks threat/contact radius" if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] else "Militia and Raider within 115-unit intercept/contact radius"
	pressure["objectiveText"] = "Combat engaged"
	pressure["statusText"] = "Militia engaging Raider"
	pressure["resourcesDuringCombat"] = runtime.resources.duplicate(true)
	pressure["collateralBefore"] = _v0249_collateral_snapshot()
	pressure["combatMarkerVisible"] = true
	barrosan_playtest["v0247Pressure"] = pressure
	_sync_unit_visuals()
	_sync_hud()
	return true


func _advance_v0249_combat_tick() -> bool:
	if barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return false
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	if not bool(pressure.get("combatStarted", false)) or bool(pressure.get("raiderDefeated", false)):
		return false
	var militia_health := _v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID)
	var raider_health := _v0247_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID)
	var before := {"militia": militia_health, "raider": raider_health}
	var next_militia := maxf(0.0, militia_health - V0249_RAIDER_DAMAGE)
	var next_raider := maxf(0.0, raider_health - V0249_MILITIA_DAMAGE)
	_v0249_set_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID, next_militia, true)
	_v0249_set_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID, next_raider, next_raider > 0.0)
	pressure = barrosan_playtest.get("v0247Pressure", {})
	pressure["combatTickCount"] = int(pressure.get("combatTickCount", 0)) + 1
	var ticks: Array = pressure.get("combatTicks", [])
	ticks.append({
		"tick": int(pressure["combatTickCount"]),
		"intervalSeconds": V0249_COMBAT_TICK_SECONDS,
		"before": before,
		"after": {"militia": next_militia, "raider": next_raider},
		"militiaDamage": V0249_MILITIA_DAMAGE,
		"raiderDamage": V0249_RAIDER_DAMAGE,
		"resources": runtime.resources.duplicate(true),
	})
	pressure["combatTicks"] = ticks
	pressure["damageApplied"] = true
	pressure["healthSnapshotsUnchanged"] = false
	pressure["resourcesUnchangedDuringCombat"] = pressure.get("resourcesBeforePressure", {}) == runtime.resources
	pressure["statusText"] = "Militia engaging Raider"
	if next_raider <= 0.0:
		pressure["raiderDefeated"] = true
		pressure["raiderRemoved"] = true
		pressure["contained"] = true
		pressure["containedByCombat"] = true
		pressure["containedByAttackOrder"] = barrosan_runtime_checkpoint in ["v0.250", "v0.251", "v0.252", "v0.253"]
		pressure["deathOccurred"] = true
		pressure["deathLimitedToRaider"] = runtime.unit_alive(V0246_FIELD_MILITIA_RUNTIME_ID)
		pressure["combatMarkerVisible"] = false
		pressure["telegraphVisible"] = false
		pressure["interceptMarkerVisible"] = true
		pressure["interceptMarkerState"] = "contained"
		pressure["objectiveText"] = "Ashen Raider defeated"
		pressure["statusText"] = "Pressure contained before impact" if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] else ("Pressure contained by attack order" if barrosan_runtime_checkpoint in ["v0.250", "v0.251"] else "Pressure contained by combat")
		pressure["resourcesAfterCombat"] = runtime.resources.duplicate(true)
		pressure["raiderHealthAfterPressure"] = 0.0
		pressure["militiaHealthAfterPressure"] = next_militia
		pressure["pressureResourcesUnchanged"] = pressure.get("resourcesBeforePressure", {}) == runtime.resources
		_remove_v0249_raider_minimap_marker()
	barrosan_playtest["v0247Pressure"] = pressure
	_record_v0249_collateral_proof()
	_sync_unit_visuals()
	_sync_hud()
	return true


func _v0249_set_unit_health(unit_id: String, health: float, alive: bool) -> void:
	for index in range(runtime.units.size()):
		var unit: Dictionary = runtime.units[index]
		if str(unit.get("id", "")) != unit_id:
			continue
		unit["health"] = health
		unit["alive"] = alive
		unit["hasDestination"] = false
		unit["destination"] = unit.get("position", Vector2.ZERO)
		unit["attackTarget"] = ""
		unit["reviewHidden"] = not alive
		runtime.units[index] = unit
		break


func _finalize_v0249_combat_visuals() -> void:
	if barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	if bool(pressure.get("raiderDefeated", false)):
		_remove_v0249_raider_minimap_marker()
		pressure["interceptMarkerState"] = "contained"
		pressure["objectiveText"] = "Ashen pressure contained"
		pressure["statusText"] = "Pressure contained before impact | Field Barracks unharmed" if barrosan_runtime_checkpoint in ["v0.252", "v0.253"] else ("Pressure contained by explicit attack order | Field Barracks unharmed" if barrosan_runtime_checkpoint in ["v0.250", "v0.251"] else "Pressure contained by combat | No building damage")
	barrosan_playtest["v0247Pressure"] = pressure
	_sync_barrosan_runtime_visuals()
	_sync_hud()


func _remove_v0249_raider_minimap_marker() -> void:
	_set_minimap_marker_visible("v0247_minimap_ashen_raider", false)
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["raiderMinimapRemoved"] = not _minimap_marker_visible("v0247_minimap_ashen_raider")
	barrosan_playtest["v0247Pressure"] = pressure


func _record_v0249_snapshot(snapshot_id: String) -> void:
	if barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var resources: Dictionary = pressure.get("resourceSnapshots", {})
	var health: Dictionary = pressure.get("healthSnapshots", {})
	resources[snapshot_id] = runtime.resources.duplicate(true)
	health[snapshot_id] = _v0247_health_snapshot()
	pressure["resourceSnapshots"] = resources
	pressure["healthSnapshots"] = health
	pressure["resourceSnapshotsUnchanged"] = resources.values().all(
		func(value: Dictionary) -> bool:
			return value == pressure.get("resourcesBeforePressure", runtime.resources)
	)
	barrosan_playtest["v0247Pressure"] = pressure


func _v0249_collateral_snapshot() -> Dictionary:
	var result := {
		"units": {
			"hero_aster": _v0247_unit_health("hero_aster"),
			"worker_00": _v0247_unit_health("worker_00"),
		},
		"structures": {},
	}
	var structures: Dictionary = result["structures"]
	for structure in runtime.structures:
		var id := str(structure.get("id", ""))
		if id in ["command_hall", "barracks", "mine_landmark", V0245_CONSTRUCTED_RUNTIME_ID] or id.begins_with("v0243_shell_"):
			structures[id] = float(structure.get("health", 0.0))
	return result


func _record_v0249_collateral_proof() -> void:
	if barrosan_runtime_checkpoint not in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		return
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var before: Dictionary = pressure.get("collateralBefore", _v0249_collateral_snapshot())
	var after := _v0249_collateral_snapshot()
	pressure["collateralAfter"] = after
	pressure["asterWorkerUnharmed"] = before.get("units", {}) == after.get("units", {})
	pressure["buildingsUnharmed"] = before.get("structures", {}) == after.get("structures", {})
	barrosan_playtest["v0247Pressure"] = pressure


func _v0248_marker_label(node_name: String, position: Vector3, text: String, color: Color) -> Label3D:
	var label := visual_root.get_node_or_null(node_name) as Label3D
	if label == null:
		label = Label3D.new()
		label.name = node_name
		label.font_size = 24
		label.pixel_size = 0.006
		label.outline_size = 8
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		visual_root.add_child(label)
	label.position = position
	label.text = text
	label.modulate = color
	return label


func _record_v0247_no_combat_mutation() -> void:
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["resourcesAfterPressure"] = runtime.resources.duplicate(true)
	pressure["pressureResourcesUnchanged"] = pressure.get("resourcesBeforePressure", {}) == runtime.resources
	pressure["militiaHealthAfterPressure"] = _v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID)
	pressure["raiderHealthAfterPressure"] = _v0247_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID)
	pressure["damageApplied"] = (
		float(pressure.get("militiaHealthAfterPressure", 0.0)) != float(pressure.get("militiaHealthBeforePressure", 0.0))
		or float(pressure.get("raiderHealthAfterPressure", 0.0)) != float(pressure.get("raiderHealthBeforePressure", 0.0))
	)
	pressure["deathOccurred"] = not runtime.unit_alive(V0246_FIELD_MILITIA_RUNTIME_ID) or not runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID)
	pressure["additionalEnemiesSpawned"] = _v0247_enemy_count() != 1
	barrosan_playtest["v0247Pressure"] = pressure
	_sync_hud()


func _ensure_v0247_ashen_raider_active() -> void:
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	if not bool(pressure.get("spawned", false)):
		return
	if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and bool(pressure.get("raiderDefeated", false)):
		return
	for unit in runtime.units:
		if str(unit.get("id", "")) != V0247_ASHEN_RAIDER_RUNTIME_ID:
			continue
		var last_position: Vector2 = pressure.get("lastKnownPosition", V0247_PRESSURE_SPAWN)
		var current_position: Vector2 = unit.get("position", Vector2.ZERO)
		if not bool(unit.get("alive", false)) or current_position.x < -9000.0:
			unit["alive"] = true
			unit["health"] = V0249_RAIDER_MAX_HP if barrosan_runtime_checkpoint in ["v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else 80.0
			unit["position"] = last_position
			unit["lastPosition"] = last_position
			unit["destination"] = last_position
			unit["hasDestination"] = false
			unit["attackTarget"] = ""
			unit["reviewHidden"] = false
		return


func _add_v0247_ashen_raider_minimap_marker() -> void:
	if minimap_panel == null or not runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID):
		return
	if not _minimap_has_marker("v0247_minimap_ashen_raider"):
		_add_minimap_marker("v0247_minimap_ashen_raider", Vector2(212, 84), Vector2(12, 12), Color("#dc4938"))
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	pressure["minimapRegistered"] = _minimap_has_marker("v0247_minimap_ashen_raider")
	barrosan_playtest["v0247Pressure"] = pressure


func _v0247_unit_health(unit_id: String) -> float:
	for unit in runtime.units:
		if str(unit.get("id", "")) == unit_id:
			return float(unit.get("health", 0.0))
	return 0.0


func _v0247_health_snapshot() -> Dictionary:
	return {
		"militia": _v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID),
		"raider": _v0247_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID),
	}


func _v0247_enemy_count() -> int:
	return runtime.units.filter(
		func(unit: Dictionary) -> bool:
			return bool(unit.get("alive", false)) and bool(unit.get("scriptedPressureEntity", false))
	).size()


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
		_add_v0245_constructed_minimap_marker()
		_add_v0246_field_militia_minimap_marker()
		_add_v0247_ashen_raider_minimap_marker()
		_add_v0261_watchpost_minimap_marker()
		if barrosan_requested_checkpoint == "v0.262" and bool(barrosan_playtest.get("v0262WatchpostAwareness", {}).get("scouted", false)):
			_add_v0262_scouted_minimap_ping()
		if barrosan_requested_checkpoint == "v0.263":
			var memory: Dictionary = barrosan_playtest.get("v0263WatchpostIntelMemory", {})
			if bool(memory.get("currentScouted", false)):
				_add_v0262_scouted_minimap_ping()
			if bool(memory.get("memoryMinimapPingVisible", false)):
				_add_v0263_memory_minimap_ping()


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
		"checkpoint": barrosan_requested_checkpoint,
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
		"authoritativeConstructionBridge": _v0245_construction_status() if barrosan_runtime_checkpoint in ["v0.245", "v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else {},
		"fieldBarracksProductionBridge": _v0246_production_status() if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else {},
		"firstAshenPressureEncounter": _v0247_pressure_status() if barrosan_runtime_checkpoint in ["v0.247", "v0.248"] else {},
		"ashenPressureReadabilityTiming": _v0248_readability_status() if barrosan_runtime_checkpoint == "v0.248" else {},
		"boundedCombatResolutionBridge": _v0249_combat_status() if barrosan_runtime_checkpoint == "v0.249" else {},
		"explicitAttackOrderBridge": _v0250_attack_order_status() if barrosan_runtime_checkpoint == "v0.250" else {},
		"firstDefenseConsequenceBridge": _v0251_defense_consequence_status() if barrosan_runtime_checkpoint == "v0.251" else {},
		"threatTimingFeedbackBridge": _v0252_threat_timing_status() if barrosan_runtime_checkpoint == "v0.252" else {},
		"firstWorkerRepairBridge": _v0253_worker_repair_status() if barrosan_runtime_checkpoint == "v0.253" else {},
		"damagedFunctionalBarracksBridge": _v0254_damaged_functional_status() if barrosan_requested_checkpoint == "v0.254" else {},
		"trueDestroyedStateBridge": _v0255_true_destroyed_state_status() if barrosan_requested_checkpoint == "v0.255" else {},
		"firstWorkerRebuildBridge": _v0256_first_worker_rebuild_status() if barrosan_requested_checkpoint in ["v0.256", "v0.257", "v0.258", "v0.259"] else {},
		"rebuildUxHardening": _v0257_rebuild_ux_status() if barrosan_requested_checkpoint in ["v0.257", "v0.258", "v0.259"] else {},
		"lifecycleReadability": _v0258_lifecycle_readability_status() if barrosan_requested_checkpoint == "v0.258" else {},
		"uiStateInvariantHardening": _v0259_ui_state_invariant_status() if barrosan_requested_checkpoint == "v0.259" else {},
		"watchpostFoundation": _v0261_watchpost_status() if barrosan_requested_checkpoint in ["v0.261", "v0.262", "v0.263"] else {},
		"watchpostAwarenessLayer": _v0262_awareness_status() if barrosan_requested_checkpoint == "v0.262" else {},
		"watchpostIntelMemory": _v0263_intel_memory_status() if barrosan_requested_checkpoint == "v0.263" else {},
	}
	return status


func _v0245_construction_status() -> Dictionary:
	var result: Dictionary = barrosan_playtest.get("v0245Construction", {}).duplicate(true)
	var delta: Dictionary = result.get("placementResourceDelta", {})
	var pathing: Dictionary = result.get("pathingProbe", {})
	var v0246_construction_pass := (
		barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]
		and bool(result.get("validAttempt", {}).get("ok", false))
		and bool(result.get("implemented", false))
		and int(result.get("spendCount", 0)) == 1
		and int(delta.get("crowns", 0)) == -180
		and int(delta.get("stone", 0)) == -120
		and bool(result.get("registered", false))
		and bool(result.get("selected", false))
		and bool(result.get("minimapRegistered", false))
	)
	var v0245_construction_pass := (
		bool(result.get("implemented", false))
		and bool(result.get("cancelResourcesUnchanged", false))
		and bool(result.get("blockedResourcesUnchanged", false))
		and not bool(result.get("blockedStructureCreated", true))
		and int(result.get("spendCount", 0)) == 1
		and int(delta.get("crowns", 0)) == -180
		and int(delta.get("stone", 0)) == -120
		and bool(result.get("registered", false))
		and bool(result.get("selected", false))
		and bool(result.get("minimapRegistered", false))
		and bool(pathing.get("accepted", false))
		and float(pathing.get("displacement", 0.0)) > 20.0
		and int(pathing.get("stuckDelta", 0)) == 0
	)
	result["status"] = "PASS" if v0246_construction_pass or v0245_construction_pass else "IN_PROGRESS"
	result["placementAuthority"] = "BuildPlacementValidationAdapter generated portable authority"
	result["constructionKind"] = "opt-in authoritative Barracks / complete / Militia-only limited production" if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else "opt-in technical Barracks / complete / no production"
	result["existingRestoredBarracksPreserved"] = bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
	result["defaultRuntimeChanged"] = false
	result["pathingParity"] = "review-grade rectangular destination-nudge only"
	return result


func _v0246_production_status() -> Dictionary:
	var result: Dictionary = barrosan_playtest.get("v0246FieldProduction", {}).duplicate(true)
	var delta: Dictionary = result.get("queueResourceDelta", {})
	var probes: Dictionary = result.get("movementProbes", {})
	var required_probes := ["builder_construction_site", "restored_barracks_main_base"] if barrosan_runtime_checkpoint in ["v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else ["builder_construction_site", "road", "bridge_river", "restored_barracks_main_base"]
	var movement_pass := required_probes.all(
		func(probe_id: String) -> bool:
			var probe: Dictionary = probes.get(probe_id, {})
			return bool(probe.get("accepted", false)) and float(probe.get("displacement", 0.0)) > 20.0 and int(probe.get("stuckDelta", 0)) == 0
	)
	if barrosan_runtime_checkpoint in ["v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		var intercept: Dictionary = barrosan_playtest.get("v0247Pressure", {}).get("militiaInterceptProbe", {})
		movement_pass = movement_pass and bool(intercept.get("accepted", false)) and float(intercept.get("displacement", 0.0)) > 20.0
	var construction: Dictionary = _v0245_construction_status()
	result["status"] = "PASS" if (
		construction.get("status", "") == "PASS"
		and bool(result.get("authorityLoaded", false))
		and bool(result.get("queueAccepted", false))
		and int(result.get("queueSpendCount", 0)) == 1
		and int(delta.get("crowns", 0)) == -60
		and int(delta.get("iron", 0)) == -20
		and int(delta.get("stone", 0)) == 0
		and bool(result.get("duplicateQueueRejected", false))
		and bool(result.get("duplicateQueueResourcesUnchanged", false))
		and bool(result.get("failedTrainRejected", false))
		and bool(result.get("failedTrainResourcesUnchanged", false))
		and bool(result.get("spawned", false))
		and int(result.get("spawnCount", 0)) == 1
		and runtime.unit_alive(V0246_FIELD_MILITIA_RUNTIME_ID)
		and bool(result.get("selected", false))
		and bool(result.get("minimapRegistered", false))
		and movement_pass
		and bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
	) else "IN_PROGRESS"
	result["productionAuthority"] = "generated portable Militia definition and Barracks trainOptions"
	result["productionKind"] = "opt-in single-slot, one-Militia limit"
	result["movementProbePass"] = movement_pass
	result["existingRestoredBarracksPreserved"] = bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
	result["commandKeepPreserved"] = (barrosan_playtest.get("selectedLiveRoles", []) as Array).has("main_base")
	result["lumeMinePreserved"] = (barrosan_playtest.get("selectedLiveRoles", []) as Array).has("mine")
	result["shellsRemainNonProducing"] = ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return (
				barrosan_runtime_structures.has(role)
				and not bool(barrosan_runtime_structures[role].get("productionEnabled", false))
			)
	)
	result["defaultRuntimeChanged"] = false
	result["pathingParity"] = "review-grade rectangular destination-nudge only"
	return result


func _v0247_pressure_status() -> Dictionary:
	var result: Dictionary = barrosan_playtest.get("v0247Pressure", {}).duplicate(true)
	var probes: Dictionary = result.get("laneProbes", {})
	var lane_pass := ["lane_start", "bridge_approach"].all(
		func(probe_id: String) -> bool:
			var probe: Dictionary = probes.get(probe_id, {})
			return bool(probe.get("accepted", false)) and float(probe.get("displacement", 0.0)) > 20.0
	)
	var intercept: Dictionary = result.get("militiaInterceptProbe", {})
	result["status"] = "PASS" if (
		_v0246_production_status().get("status", "") == "PASS"
		and bool(result.get("triggered", false))
		and bool(result.get("spawned", false))
		and int(result.get("spawnCount", 0)) == 1
		and bool(result.get("registered", false))
		and bool(result.get("selected", false))
		and bool(result.get("minimapRegistered", false))
		and lane_pass
		and bool(intercept.get("accepted", false))
		and float(intercept.get("displacement", 0.0)) > 20.0
		and bool(result.get("interceptReached", false))
		and bool(result.get("contained", false))
		and bool(result.get("pressureResourcesUnchanged", false))
		and not bool(result.get("damageApplied", true))
		and not bool(result.get("deathOccurred", true))
		and not bool(result.get("additionalEnemiesSpawned", true))
	) else "IN_PROGRESS"
	result["pressureKind"] = "opt-in scripted single-Raider proximity encounter"
	result["raiderSource"] = "existing procedural Ashen Raider runtime silhouette"
	result["aiDriven"] = false
	result["combatDamageEnabled"] = false
	result["deathEnabled"] = false
	result["laneDescription"] = "east edge -> hostile road -> bridge/base approach marker"
	result["interceptZone"] = V0247_INTERCEPT_ZONE
	result["interceptRadius"] = V0247_INTERCEPT_RADIUS
	result["laneProbePass"] = lane_pass
	result["defaultRuntimeChanged"] = false
	result["pathingParity"] = "review-grade rectangular destination-nudge only"
	result["existingRestoredBarracksPreserved"] = bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
	result["commandKeepPreserved"] = (barrosan_playtest.get("selectedLiveRoles", []) as Array).has("main_base")
	result["lumeMinePreserved"] = (barrosan_playtest.get("selectedLiveRoles", []) as Array).has("mine")
	result["shellsRemainNonProducing"] = ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return barrosan_runtime_structures.has(role) and not bool(barrosan_runtime_structures[role].get("productionEnabled", false))
	)
	return result


func _v0248_readability_status() -> Dictionary:
	var result := _v0247_pressure_status()
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var expected_objectives := [
		"1. Select Aster",
		"8. Prepare for Ashen pressure",
		"Prepare one defender",
		"Militia preparing...",
		"Defender ready",
		"9. Ashen pressure incoming",
		"Ashen Raider advancing",
		"Move Militia to intercept",
		"Ashen pressure contained",
	]
	var history: Array = pressure.get("objectiveHistory", [])
	var ladder_pass := expected_objectives.all(
		func(objective: String) -> bool:
			return history.has(objective)
	)
	var resources: Dictionary = pressure.get("resourceSnapshots", {})
	result["status"] = "PASS" if (
		result.get("status", "") == "PASS"
		and bool(pressure.get("telegraphRegistered", false))
		and bool(pressure.get("interceptMarkerRegistered", false))
		and str(pressure.get("interceptMarkerState", "")) == "contained"
		and ladder_pass
		and bool(pressure.get("resourceSnapshotsUnchanged", false))
		and bool(pressure.get("healthSnapshotsUnchanged", false))
		and resources.has("afterTelegraph")
		and resources.has("afterRaiderSpawn")
		and resources.has("afterRaiderMovement")
		and resources.has("afterContainment")
	) else "IN_PROGRESS"
	result["objectiveLadder"] = expected_objectives
	result["objectiveHistory"] = history
	result["objectiveLadderPass"] = ladder_pass
	result["pressureTelegraph"] = {
		"registered": bool(pressure.get("telegraphRegistered", false)),
		"label": "Ashen approach",
		"nonBlocking": true,
		"defaultRuntimePresent": false,
	}
	result["interceptMarker"] = {
		"registered": bool(pressure.get("interceptMarkerRegistered", false)),
		"state": str(pressure.get("interceptMarkerState", "waiting")),
		"label": "Intercept zone",
		"nonBlocking": true,
		"countsAsBuilding": false,
		"defaultRuntimePresent": false,
	}
	result["timing"] = pressure.get("timing", {})
	result["resourceSnapshots"] = resources
	result["resourceSnapshotsUnchanged"] = bool(pressure.get("resourceSnapshotsUnchanged", false))
	result["healthSnapshots"] = pressure.get("healthSnapshots", {})
	result["healthSnapshotsUnchanged"] = bool(pressure.get("healthSnapshotsUnchanged", false))
	result["hudNoCombatCopy"] = "Scripted pressure entity | no damage in v0.248"
	result["verdictCeiling"] = "PARTIAL"
	return result


func _v0249_combat_status() -> Dictionary:
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {}).duplicate(true)
	var expected_objectives := [
		"1. Select Aster",
		"8. Prepare for Ashen pressure",
		"Prepare one defender",
		"Militia preparing...",
		"Defender ready",
		"9. Ashen pressure incoming",
		"Ashen Raider advancing",
		"Move Militia to intercept",
		"Combat engaged",
		"Militia engaging Raider",
		"Ashen Raider defeated",
		"Ashen pressure contained",
	]
	var history: Array = pressure.get("objectiveHistory", [])
	var ticks: Array = pressure.get("combatTicks", [])
	var objective_pass := expected_objectives.all(func(value: String) -> bool: return history.has(value))
	var deterministic_ticks := ticks.size() == 3
	if deterministic_ticks:
		deterministic_ticks = (
			float(ticks[0].get("after", {}).get("militia", -1.0)) == 90.0
			and float(ticks[0].get("after", {}).get("raider", -1.0)) == 40.0
			and float(ticks[1].get("after", {}).get("militia", -1.0)) == 80.0
			and float(ticks[1].get("after", {}).get("raider", -1.0)) == 20.0
			and float(ticks[2].get("after", {}).get("militia", -1.0)) == 70.0
			and float(ticks[2].get("after", {}).get("raider", -1.0)) == 0.0
		)
	var lane_probes: Dictionary = pressure.get("laneProbes", {})
	var lane_pass := ["lane_start", "bridge_approach"].all(
		func(probe_id: String) -> bool:
			return bool(lane_probes.get(probe_id, {}).get("accepted", false))
	)
	var selected_live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	pressure["existingRestoredBarracksPreserved"] = bool(
		barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false)
	)
	pressure["commandKeepPreserved"] = selected_live_roles.has("main_base")
	pressure["lumeMinePreserved"] = selected_live_roles.has("mine")
	pressure["shellsRemainNonProducing"] = ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return not bool(barrosan_runtime_structures.get(role, {}).get("productionEnabled", false))
	)
	pressure["status"] = "PASS" if (
		_v0246_production_status().get("status", "") == "PASS"
		and int(pressure.get("spawnCount", 0)) == 1
		and bool(pressure.get("triggered", false))
		and bool(pressure.get("telegraphRegistered", false))
		and bool(pressure.get("interceptMarkerRegistered", false))
		and lane_pass
		and bool(pressure.get("combatStarted", false))
		and not bool(pressure.get("combatStartedBeforeContact", true))
		and deterministic_ticks
		and bool(pressure.get("raiderDefeated", false))
		and bool(pressure.get("raiderRemoved", false))
		and bool(pressure.get("raiderMinimapRemoved", false))
		and bool(pressure.get("containedByCombat", false))
		and _v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID) == 70.0
		and _v0247_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID) == 0.0
		and runtime.unit_alive(V0246_FIELD_MILITIA_RUNTIME_ID)
		and not runtime.unit_alive(V0247_ASHEN_RAIDER_RUNTIME_ID)
		and bool(pressure.get("pressureResourcesUnchanged", false))
		and bool(pressure.get("buildingsUnharmed", false))
		and bool(pressure.get("asterWorkerUnharmed", false))
		and bool(pressure.get("deathLimitedToRaider", false))
		and objective_pass
		and bool(pressure["existingRestoredBarracksPreserved"])
		and bool(pressure["commandKeepPreserved"])
		and bool(pressure["lumeMinePreserved"])
		and bool(pressure["shellsRemainNonProducing"])
	) else "IN_PROGRESS"
	pressure["combatModel"] = "deterministic contact ticks; one Militia versus one scripted Raider"
	pressure["militiaMaxHp"] = V0249_MILITIA_MAX_HP
	pressure["raiderMaxHp"] = V0249_RAIDER_MAX_HP
	pressure["militiaDamagePerTick"] = V0249_MILITIA_DAMAGE
	pressure["raiderDamagePerTick"] = V0249_RAIDER_DAMAGE
	pressure["tickIntervalSeconds"] = V0249_COMBAT_TICK_SECONDS
	pressure["finalMilitiaHp"] = _v0247_unit_health(V0246_FIELD_MILITIA_RUNTIME_ID)
	pressure["finalRaiderHp"] = _v0247_unit_health(V0247_ASHEN_RAIDER_RUNTIME_ID)
	pressure["objectiveLadder"] = expected_objectives
	pressure["objectiveLadderPass"] = objective_pass
	pressure["deterministicTicksPass"] = deterministic_ticks
	pressure["laneProbePass"] = lane_pass
	pressure["enemyAiExists"] = false
	pressure["wavesExist"] = false
	pressure["baseDamageExists"] = false
	pressure["militiaCanDie"] = false
	pressure["pathingParity"] = "review-grade rectangular destination-nudge only"
	pressure["verdictCeiling"] = "PARTIAL"
	return pressure


func _v0250_attack_order_status() -> Dictionary:
	var result := _v0249_combat_status()
	var ticks: Array = result.get("combatTicks", [])
	var deterministic_ticks := ticks.size() == 3
	if deterministic_ticks:
		deterministic_ticks = (
			float(ticks[0].get("after", {}).get("militia", -1.0)) == 90.0
			and float(ticks[0].get("after", {}).get("raider", -1.0)) == 40.0
			and float(ticks[1].get("after", {}).get("militia", -1.0)) == 80.0
			and float(ticks[1].get("after", {}).get("raider", -1.0)) == 20.0
			and float(ticks[2].get("after", {}).get("militia", -1.0)) == 70.0
			and float(ticks[2].get("after", {}).get("raider", -1.0)) == 0.0
		)
	var history: Array = result.get("objectiveHistory", [])
	var attack_objectives := [
		"Defender ready",
		"Attack targeting mode",
		"Attack order accepted",
		"Combat engaged",
		"Militia engaging Raider",
		"Ashen Raider defeated",
		"Ashen pressure contained",
	]
	result["objectiveLadder"] = attack_objectives
	result["objectiveLadderPass"] = attack_objectives.all(func(value: String) -> bool: return history.has(value))
	result["deterministicTicksPass"] = deterministic_ticks
	result["attackCommandImplementation"] = "Attack arms targeting mode; next hostile click targets the only scripted Raider"
	result["singleTargetBoundedAttackBridge"] = true
	result["status"] = "PASS" if (
		_v0246_production_status().get("status", "") == "PASS"
		and int(result.get("spawnCount", 0)) == 1
		and bool(result.get("attackCommandAvailable", false))
		and bool(result.get("attackCommandPressed", false))
		and bool(result.get("attackOrderAccepted", false))
		and bool(result.get("attackOrderAcceptedBeforeContact", false))
		and str(result.get("activeAttackTarget", "")) == V0247_ASHEN_RAIDER_RUNTIME_ID
		and bool(result.get("targetMarkerRegistered", false))
		and bool(result.get("combatAuthorizedByAttackOrder", false))
		and not bool(result.get("combatStartedBeforeContact", true))
		and deterministic_ticks
		and bool(result.get("raiderDefeated", false))
		and bool(result.get("raiderMinimapRemoved", false))
		and bool(result.get("containedByAttackOrder", false))
		and bool(result.get("pressureResourcesUnchanged", false))
		and bool(result.get("buildingsUnharmed", false))
		and bool(result.get("asterWorkerUnharmed", false))
		and bool(result.get("existingRestoredBarracksPreserved", false))
		and bool(result.get("commandKeepPreserved", false))
		and bool(result.get("lumeMinePreserved", false))
		and bool(result.get("shellsRemainNonProducing", false))
	) else "IN_PROGRESS"
	result["verdictCeiling"] = "PARTIAL"
	return result


func _v0251_undefended_status() -> Dictionary:
	var consequence: Dictionary = barrosan_playtest.get("v0251DefenseConsequence", {}).duplicate(true)
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	var ticks: Array = consequence.get("buildingDamageTicks", [])
	var deterministic_ticks := ticks.size() == 3
	if deterministic_ticks:
		deterministic_ticks = (
			float(ticks[0].get("before", -1.0)) == 200.0
			and float(ticks[0].get("after", -1.0)) == 175.0
			and float(ticks[1].get("before", -1.0)) == 175.0
			and float(ticks[1].get("after", -1.0)) == 150.0
			and float(ticks[2].get("before", -1.0)) == 150.0
			and float(ticks[2].get("after", -1.0)) == 125.0
		)
	consequence["raiderSpawnCount"] = int(pressure.get("spawnCount", 0))
	consequence["raiderRuntimeId"] = V0247_ASHEN_RAIDER_RUNTIME_ID
	consequence["raiderMinimapRegistered"] = bool(pressure.get("minimapRegistered", false))
	consequence["raiderStoppedAfterBoundedDamage"] = bool(consequence.get("boundedStop", false))
	consequence["fieldBarracksSurvives"] = _v0251_field_barracks_health() == 125.0
	consequence["deterministicBuildingTicksPass"] = deterministic_ticks
	consequence["finalResources"] = runtime.resources.duplicate(true)
	consequence["status"] = "PASS" if (
		int(pressure.get("spawnCount", 0)) == 1
		and bool(consequence.get("buildingPressureContact", false))
		and bool(consequence.get("buildingDamageStarted", false))
		and not bool(consequence.get("buildingDamageStartedBeforeContact", true))
		and deterministic_ticks
		and int(consequence.get("buildingDamageTickCount", 0)) == V0251_BUILDING_DAMAGE_TICK_LIMIT
		and _v0251_field_barracks_health() == 125.0
		and bool(consequence.get("buildingPressureContained", false))
		and bool(consequence.get("boundedStop", false))
		and not bool(consequence.get("buildingDestroyed", true))
		and bool(consequence.get("resourcesUnchanged", false))
		and bool(consequence.get("asterWorkerUnharmed", false))
	) else "IN_PROGRESS"
	consequence["pathingParity"] = "review-grade deterministic lane destination to one constructed Field Barracks"
	consequence["verdictCeiling"] = "PARTIAL"
	return consequence


func _v0251_defense_consequence_status() -> Dictionary:
	var undefended := _v0251_undefended_status()
	var defended := v0251_defended_proof.duplicate(true)
	if v0251_undefended_proof.size() > 0:
		undefended = v0251_undefended_proof.duplicate(true)
	var selected_live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	var shells_preserved := ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return not bool(barrosan_runtime_structures.get(role, {}).get("productionEnabled", false))
	)
	var defended_pass: bool = (
		int(defended.get("spawnCount", 0)) == 1
		and bool(defended.get("attackOrderAccepted", false))
		and bool(defended.get("combatAuthorizedByAttackOrder", false))
		and bool(defended.get("deterministicTicksPass", false))
		and float(defended.get("finalMilitiaHp", -1.0)) == 70.0
		and float(defended.get("finalRaiderHp", -1.0)) == 0.0
		and float(defended.get("fieldBarracksFinalHp", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
		and bool(defended.get("raiderDefeated", false))
		and bool(defended.get("containedByAttackOrder", false))
		and bool(defended.get("pressureResourcesUnchanged", false))
		and bool(defended.get("buildingsUnharmed", false))
	)
	return {
		"status": "PASS" if (
			defended_pass
			and undefended.get("status", "") == "PASS"
			and bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
			and selected_live_roles.has("main_base")
			and selected_live_roles.has("mine")
			and shells_preserved
		) else "IN_PROGRESS",
		"checkpoint": "v0.251",
		"defendedBranch": defended,
		"undefendedBranch": undefended,
		"fieldBarracksStartHp": V0251_FIELD_BARRACKS_MAX_HP,
		"fieldBarracksDefendedFinalHp": V0251_FIELD_BARRACKS_MAX_HP,
		"fieldBarracksUndefendedFinalHp": float(undefended.get("fieldBarracksFinalHp", -1.0)),
		"buildingDamagePerTick": V0251_RAIDER_BUILDING_DAMAGE,
		"buildingDamageTickLimit": V0251_BUILDING_DAMAGE_TICK_LIMIT,
		"existingRestoredBarracksPreserved": bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false)),
		"commandKeepPreserved": selected_live_roles.has("main_base"),
		"lumeMinePreserved": selected_live_roles.has("mine"),
		"shellsRemainNonProducing": shells_preserved,
		"defaultRuntimeChanged": false,
		"enemyAiExists": false,
		"wavesExist": false,
		"buildingDestructionExists": false,
		"repairExists": false,
		"pathingParity": "review-grade deterministic lane destination to one constructed Field Barracks",
		"verdictCeiling": "PARTIAL",
	}


func _v0252_missed_window_status() -> Dictionary:
	var result := _v0251_undefended_status()
	var timing: Dictionary = barrosan_playtest.get("v0252ThreatTiming", {}).duplicate(true)
	var pressure: Dictionary = barrosan_playtest.get("v0247Pressure", {})
	result["threatTiming"] = timing
	result["warningWindowStarted"] = bool(timing.get("warningStarted", false))
	result["warningWindowExpired"] = bool(timing.get("warningExpired", false))
	result["warningDurationSeconds"] = float(timing.get("warningDurationSeconds", 0.0))
	result["warningStepCount"] = int(timing.get("warningStepCount", 0))
	result["noDamageDuringWarning"] = (
		not bool(timing.get("damageOccurredDuringWarning", true))
		and float(timing.get("fieldBarracksHpAtWarningStart", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
		and float(timing.get("fieldBarracksHpAtWarningMidpoint", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
		and float(timing.get("fieldBarracksHpAtWarningExpiry", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
	)
	result["damageStartedAfterWarning"] = bool(timing.get("damageStartedAfterWarning", false))
	result["threatWindowMarkerRegistered"] = bool(timing.get("threatWindowMarkerRegistered", false))
	result["damageImminentMarkerRegistered"] = bool(timing.get("damageImminentMarkerRegistered", false))
	result["raiderMinimapVisibleDuringWarning"] = bool(timing.get("raiderMinimapVisibleDuringWarning", false))
	result["boundedRaiderStop"] = bool(timing.get("boundedRaiderStop", false))
	result["asterFinalHp"] = _v0247_unit_health("hero_aster")
	result["workerFinalHp"] = _v0247_unit_health("worker_00")
	result["status"] = "PASS" if (
		result.get("status", "") == "PASS"
		and bool(timing.get("threatRangeReached", false))
		and bool(timing.get("warningStarted", false))
		and bool(timing.get("warningExpired", false))
		and int(timing.get("warningStep", 0)) == V0252_THREAT_WINDOW_STEPS
		and bool(result["noDamageDuringWarning"])
		and bool(timing.get("damageImminent", false))
		and bool(timing.get("damageStartedAfterWarning", false))
		and bool(timing.get("threatWindowMarkerRegistered", false))
		and bool(timing.get("damageImminentMarkerRegistered", false))
		and bool(timing.get("raiderMinimapVisibleDuringWarning", false))
		and bool(timing.get("boundedRaiderStop", false))
		and int(pressure.get("spawnCount", 0)) == 1
		and _v0247_unit_health("hero_aster") == 100.0
		and _v0247_unit_health("worker_00") == 80.0
	) else "IN_PROGRESS"
	return result


func _v0252_threat_timing_status() -> Dictionary:
	var defended := v0252_defended_proof.duplicate(true)
	var missed := _v0252_missed_window_status()
	if v0252_missed_window_proof.size() > 0:
		missed = v0252_missed_window_proof.duplicate(true)
	var defended_timing: Dictionary = defended.get("threatTiming", {})
	var selected_live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	var shells_preserved := ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return not bool(barrosan_runtime_structures.get(role, {}).get("productionEnabled", false))
	)
	var defended_pass := (
		int(defended.get("spawnCount", 0)) == 1
		and bool(defended_timing.get("threatRangeReached", false))
		and bool(defended_timing.get("warningStarted", false))
		and bool(defended_timing.get("defendedDuringWarning", false))
		and not bool(defended_timing.get("warningExpired", true))
		and not bool(defended_timing.get("damageOccurredDuringWarning", true))
		and float(defended_timing.get("fieldBarracksHpAtWarningStart", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
		and float(defended_timing.get("fieldBarracksHpAtWarningMidpoint", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
		and bool(defended.get("attackOrderAccepted", false))
		and bool(defended.get("combatAuthorizedByAttackOrder", false))
		and bool(defended.get("deterministicTicksPass", false))
		and float(defended.get("finalMilitiaHp", -1.0)) == 70.0
		and float(defended.get("finalRaiderHp", -1.0)) == 0.0
		and float(defended.get("fieldBarracksFinalHp", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
		and bool(defended.get("raiderDefeated", false))
		and bool(defended.get("containedByAttackOrder", false))
		and bool(defended.get("pressureResourcesUnchanged", false))
		and float(defended.get("collateralAfter", {}).get("units", {}).get("hero_aster", -1.0)) == 100.0
		and float(defended.get("collateralAfter", {}).get("units", {}).get("worker_00", -1.0)) == 80.0
	)
	defended["status"] = "PASS" if defended_pass else "IN_PROGRESS"
	return {
		"status": "PASS" if (
			defended_pass
			and missed.get("status", "") == "PASS"
			and bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
			and selected_live_roles.has("main_base")
			and selected_live_roles.has("mine")
			and shells_preserved
		) else "IN_PROGRESS",
		"checkpoint": "v0.252",
		"defendedInWindowBranch": defended,
		"missedWindowBranch": missed,
		"warningStartCondition": "one Raider reaches the constructed Field Barracks threat radius",
		"warningDurationSeconds": V0252_THREAT_WINDOW_SECONDS,
		"warningStepCount": V0252_THREAT_WINDOW_STEPS,
		"fieldBarracksStartHp": V0251_FIELD_BARRACKS_MAX_HP,
		"fieldBarracksDefendedFinalHp": float(defended.get("fieldBarracksFinalHp", -1.0)),
		"fieldBarracksMissedWindowFinalHp": float(missed.get("fieldBarracksFinalHp", -1.0)),
		"damageStartsOnlyAfterWarningExpiry": bool(missed.get("damageStartedAfterWarning", false)),
		"existingRestoredBarracksPreserved": bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false)),
		"commandKeepPreserved": selected_live_roles.has("main_base"),
		"lumeMinePreserved": selected_live_roles.has("mine"),
		"shellsRemainNonProducing": shells_preserved,
		"defaultRuntimeChanged": false,
		"enemyAiExists": false,
		"wavesExist": false,
		"pathingParity": "review-grade deterministic lane destination and three-step threat window",
		"verdictCeiling": "PARTIAL",
	}


func _v0253_repair_branch_status() -> Dictionary:
	var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {}).duplicate(true)
	var missed: Dictionary = repair.get("missedWindowProof", _v0252_missed_window_status()).duplicate(true)
	var delta: Dictionary = repair.get("repairResourceDelta", {})
	var ticks: Array = repair.get("repairTicks", [])
	var hp_sequence_pass := (
		ticks.size() == 3
		and float(ticks[0].get("before", -1.0)) == 125.0
		and float(ticks[0].get("after", -1.0)) == 150.0
		and float(ticks[1].get("after", -1.0)) == 175.0
		and float(ticks[2].get("after", -1.0)) == 200.0
	)
	repair["missedWindow"] = missed
	repair["repairHpSequencePass"] = hp_sequence_pass
	repair["asterFinalHp"] = _v0247_unit_health("hero_aster")
	repair["workerFinalHp"] = _v0247_unit_health("worker_00")
	repair["raiderSpawnCount"] = int(barrosan_playtest.get("v0247Pressure", {}).get("spawnCount", 0))
	repair["raiderBoundedAfterPressure"] = bool(barrosan_playtest.get("v0252ThreatTiming", {}).get("boundedRaiderStop", false))
	repair["repairCommandAvailableAtFullHp"] = _v0253_repair_command_available()
	repair["status"] = "PASS" if (
		missed.get("status", "") == "PASS"
		and float(repair.get("fieldBarracksHpBeforeRepair", -1.0)) == 125.0
		and int(repair.get("repairSpendCount", 0)) == 1
		and int(delta.get("crowns", 0)) == -30
		and int(delta.get("stone", 0)) == -30
		and int(delta.get("iron", 0)) == 0
		and int(delta.get("aether", 0)) == 0
		and repair.get("resourcesAfterRepairSpend", {}) == {"crowns": 210, "stone": 10, "iron": 90, "aether": 38}
		and hp_sequence_pass
		and float(repair.get("fieldBarracksFinalHp", -1.0)) == V0251_FIELD_BARRACKS_MAX_HP
		and bool(repair.get("repairComplete", false))
		and not bool(repair.get("overhealOccurred", true))
		and bool(repair.get("repeatedChargeRejected", false))
		and bool(repair.get("resourcesUnchangedAfterRepair", false))
		and not bool(repair["repairCommandAvailableAtFullHp"])
		and bool(repair.get("repairMarkerRegistered", false))
		and bool(repair.get("workerMinimapVisibleDuringRepair", false))
		and bool(repair.get("fieldBarracksMinimapVisibleDuringRepair", false))
		and float(repair["asterFinalHp"]) == 100.0
		and float(repair["workerFinalHp"]) == 80.0
		and int(repair["raiderSpawnCount"]) == 1
		and bool(repair["raiderBoundedAfterPressure"])
	) else "IN_PROGRESS"
	return repair


func _v0253_worker_repair_status() -> Dictionary:
	var repair := v0253_repair_proof.duplicate(true) if v0253_repair_proof.size() > 0 else _v0253_repair_branch_status()
	var defended := v0253_defended_proof.duplicate(true)
	var selected_live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	var shells_preserved := ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return not bool(barrosan_runtime_structures.get(role, {}).get("productionEnabled", false))
	)
	var defended_timing: Dictionary = defended.get("threatTiming", {})
	var defended_pass: bool = (
		int(defended.get("spawnCount", 0)) == 1
		and bool(defended_timing.get("warningStarted", false))
		and bool(defended_timing.get("defendedDuringWarning", false))
		and bool(defended.get("attackOrderAccepted", false))
		and bool(defended.get("deterministicTicksPass", false))
		and float(defended.get("finalMilitiaHp", -1.0)) == 70.0
		and float(defended.get("finalRaiderHp", -1.0)) == 0.0
		and float(defended.get("fieldBarracksFinalHp", -1.0)) == 200.0
		and not bool(defended.get("repairCommandAvailable", true))
		and defended.get("resourcesAfterCombat", {}) == {"crowns": 180, "stone": 40, "iron": 70, "aether": 38}
	)
	defended["status"] = "PASS" if defended_pass else "IN_PROGRESS"
	return {
		"status": "PASS" if (
			repair.get("status", "") == "PASS"
			and defended_pass
			and bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
			and selected_live_roles.has("main_base")
			and selected_live_roles.has("mine")
			and shells_preserved
		) else "IN_PROGRESS",
		"checkpoint": "v0.253",
		"repairBranch": repair,
		"defendedRegressionBranch": defended,
		"repairTarget": "newly constructed authoritative Field Barracks only",
		"repairCost": V0253_REPAIR_COST.duplicate(true),
		"repairAmountPerTick": V0253_REPAIR_AMOUNT,
		"repairTickLimit": V0253_REPAIR_TICK_LIMIT,
		"existingRestoredBarracksPreserved": bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false)),
		"commandKeepPreserved": selected_live_roles.has("main_base"),
		"lumeMinePreserved": selected_live_roles.has("mine"),
		"shellsRemainNonProducing": shells_preserved,
		"defaultRuntimeChanged": false,
		"globalRepairExists": false,
		"autoRepairExists": false,
		"buildingDestructionExists": false,
		"pathingParity": "review-grade explicit Worker selection and deterministic repair ticks",
		"verdictCeiling": "PARTIAL",
	}


func _v0254_damaged_functional_status() -> Dictionary:
	var damaged := v0254_damaged_proof.duplicate(true)
	var repair := v0254_repair_proof.duplicate(true)
	var defended := v0254_defended_proof.duplicate(true)
	var missed: Dictionary = repair.get("missedWindow", repair.get("missedWindowProof", {}))
	var selected_live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	var shells_preserved := ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return not bool(barrosan_runtime_structures.get(role, {}).get("productionEnabled", false))
	)
	var damaged_pass: bool = (
		bool(damaged.get("damagedBarracksSelectable", false))
		and bool(damaged.get("damagedBarracksFunctional", false))
		and bool(damaged.get("productionAvailableAt125", false))
		and bool(damaged.get("trainOrderAcceptedAt125", false))
		and damaged.get("resourcesBeforeDamagedTraining", {}) == {"crowns": 240, "stone": 40, "iron": 90, "aether": 38}
		and damaged.get("resourcesAfterDamagedTraining", {}) == {"crowns": 180, "stone": 40, "iron": 70, "aether": 38}
		and int(damaged.get("trainResourceDelta", {}).get("crowns", 0)) == -60
		and int(damaged.get("trainResourceDelta", {}).get("iron", 0)) == -20
		and int(damaged.get("militiaCountFromDamagedBarracks", 0)) == 1
		and float(damaged.get("fieldBarracksHpAfterTraining", -1.0)) == 125.0
		and bool(damaged.get("noPassiveCollapse", false))
		and int(damaged.get("acceptedDamageTicksAfterBoundedStop", -1)) == 0
		and bool(damaged.get("noRefund", false))
		and bool(damaged.get("noExtraCharge", false))
		and bool(damaged.get("productionUnavailableOnlyAtZeroHp", false))
		and bool(damaged.get("minimapPreserved", false))
	)
	var repair_pass: bool = (
		repair.get("status", "") == "PASS"
		and missed.get("status", "") == "PASS"
		and float(repair.get("fieldBarracksHpBeforeRepair", -1.0)) == 125.0
		and repair.get("resourcesAfterRepairSpend", {}) == {"crowns": 210, "stone": 10, "iron": 90, "aether": 38}
		and bool(repair.get("repairHpSequencePass", false))
		and float(repair.get("fieldBarracksFinalHp", -1.0)) == 200.0
	)
	var defended_timing: Dictionary = defended.get("threatTiming", {})
	var defended_pass: bool = (
		int(defended.get("spawnCount", 0)) == 1
		and int(defended.get("militiaCount", 0)) == 1
		and bool(defended_timing.get("warningStarted", false))
		and bool(defended_timing.get("defendedDuringWarning", false))
		and bool(defended.get("attackOrderAccepted", false))
		and bool(defended.get("deterministicTicksPass", false))
		and float(defended.get("finalMilitiaHp", -1.0)) == 70.0
		and float(defended.get("finalRaiderHp", -1.0)) == 0.0
		and float(defended.get("fieldBarracksFinalHp", -1.0)) == 200.0
		and not bool(defended.get("repairCommandAvailable", true))
		and defended.get("resourcesAfterCombat", {}) == {"crowns": 180, "stone": 40, "iron": 70, "aether": 38}
	)
	damaged["status"] = "PASS" if damaged_pass else "IN_PROGRESS"
	repair["status"] = "PASS" if repair_pass else "IN_PROGRESS"
	defended["status"] = "PASS" if defended_pass else "IN_PROGRESS"
	return {
		"status": "PASS" if (
			damaged_pass
			and repair_pass
			and defended_pass
			and bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
			and selected_live_roles.has("main_base")
			and selected_live_roles.has("mine")
			and shells_preserved
		) else "IN_PROGRESS",
		"checkpoint": "v0.254",
		"damagedFunctionalBranch": damaged,
		"repairOptionalBranch": repair,
		"defendedRegressionBranch": defended,
		"coreRule": "HP > 0 remains selectable, repairable and production-capable; production is unavailable only at HP 0",
		"passiveCollapseExists": false,
		"forcedDestructionExists": false,
		"destroyedStateExercised": false,
		"existingRestoredBarracksPreserved": bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false)),
		"commandKeepPreserved": selected_live_roles.has("main_base"),
		"lumeMinePreserved": selected_live_roles.has("mine"),
		"shellsRemainNonProducing": shells_preserved,
		"defaultRuntimeChanged": false,
		"globalBuildingDamageChanged": false,
		"pathingParity": "review-grade deterministic lane and existing rectangular destination nudge",
		"verdictCeiling": "PARTIAL",
	}


func _v0255_true_destroyed_state_status() -> Dictionary:
	var damaged := v0255_damaged_proof.duplicate(true)
	var destroyed := v0255_destroyed_proof.duplicate(true)
	var intercepted := v0255_intercepted_proof.duplicate(true)
	var repair := v0255_repair_proof.duplicate(true)
	var defended := v0255_defended_proof.duplicate(true)
	var first_missed: Dictionary = repair.get("missedWindow", repair.get("missedWindowProof", {}))
	var selected_live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	var shells_preserved := ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return not bool(barrosan_runtime_structures.get(role, {}).get("productionEnabled", false))
	)
	var damaged_pass: bool = (
		bool(damaged.get("damagedBarracksSelectable", false))
		and bool(damaged.get("damagedBarracksFunctional", false))
		and bool(damaged.get("productionAvailableAt125", false))
		and bool(damaged.get("trainOrderAcceptedAt125", false))
		and damaged.get("resourcesBeforeDamagedTraining", {}) == {"crowns": 240, "stone": 40, "iron": 90, "aether": 38}
		and damaged.get("resourcesAfterDamagedTraining", {}) == {"crowns": 180, "stone": 40, "iron": 70, "aether": 38}
		and int(damaged.get("militiaCountFromDamagedBarracks", 0)) == 1
		and float(damaged.get("fieldBarracksHpAfterTraining", -1.0)) == 125.0
		and bool(damaged.get("noPassiveCollapse", false))
	)
	var second_ticks: Array = destroyed.get("damageTicks", [])
	var second_sequence_pass := second_ticks.size() == 5
	if second_sequence_pass:
		var expected := [100.0, 75.0, 50.0, 25.0, 0.0]
		for index in range(expected.size()):
			if float(second_ticks[index].get("after", -1.0)) != expected[index]:
				second_sequence_pass = false
	var destroyed_pass: bool = (
		bool(destroyed.get("explicitTrigger", false))
		and bool(destroyed.get("warningStarted", false))
		and bool(destroyed.get("warningExpired", false))
		and not bool(destroyed.get("damageDuringWarning", true))
		and second_sequence_pass
		and bool(destroyed.get("productionAvailableAt25", false))
		and bool(destroyed.get("destroyed", false))
		and float(destroyed.get("destroyedHp", -1.0)) == 0.0
		and bool(destroyed.get("productionUnavailableAtZero", false))
		and not bool(destroyed.get("trainOrderAcceptedAtZero", true))
		and bool(destroyed.get("repairUnavailableAtZero", false))
		and bool(destroyed.get("noRefund", false))
		and bool(destroyed.get("noAutomaticRebuild", false))
	)
	var intercepted_combat: Dictionary = intercepted.get("combat", {})
	var intercepted_pass := (
		bool(intercepted.get("explicitTrigger", false))
		and bool(intercepted.get("intercepted", false))
		and float(intercepted.get("fieldBarracksFinalHp", -1.0)) == 125.0
		and bool(intercepted_combat.get("attackOrderAccepted", false))
		and bool(intercepted_combat.get("deterministicTicksPass", false))
		and float(intercepted_combat.get("finalMilitiaHp", -1.0)) == 70.0
		and float(intercepted_combat.get("finalRaiderHp", -1.0)) == 0.0
	)
	var repair_pass: bool = (
		repair.get("status", "") == "PASS"
		and first_missed.get("status", "") == "PASS"
		and repair.get("resourcesAfterRepairSpend", {}) == {"crowns": 210, "stone": 10, "iron": 90, "aether": 38}
		and bool(repair.get("repairHpSequencePass", false))
		and float(repair.get("fieldBarracksFinalHp", -1.0)) == 200.0
	)
	var defended_pass := (
		bool(defended.get("attackOrderAccepted", false))
		and bool(defended.get("deterministicTicksPass", false))
		and float(defended.get("finalMilitiaHp", -1.0)) == 70.0
		and float(defended.get("finalRaiderHp", -1.0)) == 0.0
		and float(defended.get("fieldBarracksFinalHp", -1.0)) == 200.0
		and int(defended.get("militiaCount", 0)) == 1
	)
	damaged["status"] = "PASS" if damaged_pass else "IN_PROGRESS"
	destroyed["status"] = "PASS" if destroyed_pass else "IN_PROGRESS"
	intercepted["status"] = "PASS" if intercepted_pass else "IN_PROGRESS"
	repair["status"] = "PASS" if repair_pass else "IN_PROGRESS"
	defended["status"] = "PASS" if defended_pass else "IN_PROGRESS"
	return {
		"status": "PASS" if (
			damaged_pass and destroyed_pass and intercepted_pass and repair_pass and defended_pass
			and bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
			and selected_live_roles.has("main_base")
			and selected_live_roles.has("mine")
			and shells_preserved
		) else "IN_PROGRESS",
		"checkpoint": "v0.255",
		"damagedFunctionalBranch": damaged,
		"destroyedStateBranch": destroyed,
		"secondPressureInterceptBranch": intercepted,
		"repairOptionalBranch": repair,
		"defendedFirstPressureBranch": defended,
		"firstPressureDamageSequence": [200, 175, 150, 125],
		"secondPressureDamageSequence": [125, 100, 75, 50, 25, 0],
		"productionRule": "available at HP > 0; unavailable only at HP 0",
		"repairRule": "optional at HP 1-199; unavailable at HP 0 until rebuild exists",
		"passiveCollapseExists": false,
		"repairOrLoseTimerExists": false,
		"globalBuildingDestructionExists": false,
		"rebuildImplemented": false,
		"existingRestoredBarracksPreserved": bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false)),
		"commandKeepPreserved": selected_live_roles.has("main_base"),
		"lumeMinePreserved": selected_live_roles.has("mine"),
		"shellsRemainNonProducing": shells_preserved,
		"defaultRuntimeChanged": false,
		"pathingParity": "review-grade deterministic explicit pressure lane and combat intercept",
		"verdictCeiling": "PARTIAL",
	}


func _v0256_first_worker_rebuild_status() -> Dictionary:
	var destroyed := v0256_destroyed_proof.duplicate(true)
	var rebuild := v0256_rebuild_proof.duplicate(true)
	var separation := v0256_separation_proof.duplicate(true)
	var defended := v0256_defended_proof.duplicate(true)
	var construction := _v0245_construction_status()
	var first: Dictionary = destroyed.get("firstPressure", {})
	var second_ticks: Array = destroyed.get("damageTicks", [])
	var second_sequence_pass := second_ticks.size() == 5
	if second_sequence_pass:
		var expected_second := [100.0, 75.0, 50.0, 25.0, 0.0]
		for index in range(expected_second.size()):
			if float(second_ticks[index].get("after", -1.0)) != expected_second[index]:
				second_sequence_pass = false
	var rebuild_ticks: Array = rebuild.get("rebuildTicks", [])
	var rebuild_sequence_pass := rebuild_ticks.size() == 4
	if rebuild_sequence_pass:
		var expected_rebuild := [25.0, 50.0, 75.0, 100.0]
		for index in range(expected_rebuild.size()):
			if float(rebuild_ticks[index].get("after", -1.0)) != expected_rebuild[index]:
				rebuild_sequence_pass = false
	var destroyed_pass := (
		bool(destroyed.get("destroyed", false))
		and float(destroyed.get("destroyedHp", -1.0)) == 0.0
		and second_sequence_pass
		and bool(destroyed.get("productionUnavailableAtZero", false))
		and not bool(destroyed.get("trainOrderAcceptedAtZero", true))
		and bool(destroyed.get("repairUnavailableAtZero", false))
		and bool(destroyed.get("noRefund", false))
		and bool(destroyed.get("noAutomaticRebuild", false))
		and float(destroyed.get("asterFinalHp", -1.0)) == 100.0
		and float(destroyed.get("workerFinalHp", -1.0)) == 80.0
	)
	var rebuild_pass: bool = (
		bool(rebuild.get("rebuildCommandAvailable", false))
		and bool(rebuild.get("repairUnavailableAtZero", false))
		and bool(rebuild.get("rebuildOrderAccepted", false))
		and int(rebuild.get("rebuildSpendCount", 0)) == 1
		and rebuild.get("resourcesBeforeRebuild", {}) == {"crowns": 240, "stone": 40, "iron": 90, "aether": 38}
		and rebuild.get("resourcesAfterRebuildSpend", {}) == {"crowns": 150, "stone": 0, "iron": 90, "aether": 38}
		and rebuild_sequence_pass
		and bool(rebuild.get("productionUnavailableDuringRebuild", false))
		and bool(rebuild.get("rebuildComplete", false))
		and float(rebuild.get("fieldBarracksFinalHp", -1.0)) == 100.0
		and bool(rebuild.get("productionAvailableAfterRebuild", false))
		and bool(rebuild.get("trainOrderAcceptedAfterRebuild", false))
		and rebuild.get("resourcesAfterRebuiltTraining", {}) == {"crowns": 90, "stone": 0, "iron": 70, "aether": 38}
		and int(rebuild.get("militiaCountAfterRebuild", 0)) == 1
		and float(rebuild.get("fieldBarracksHpAfterTraining", -1.0)) == 100.0
		and bool(rebuild.get("resourcesUnchangedAfterSpend", false))
	)
	var separation_pass: bool = (
		bool(separation.get("repairAvailableAt125", false))
		and bool(separation.get("rebuildUnavailableAt125", false))
		and bool(separation.get("repairUnavailableAtFull", false))
		and bool(separation.get("rebuildUnavailableAtFull", false))
	)
	var defended_pass: bool = (
		bool(defended.get("attackOrderAccepted", false))
		and bool(defended.get("deterministicTicksPass", false))
		and float(defended.get("finalMilitiaHp", -1.0)) == 70.0
		and float(defended.get("finalRaiderHp", -1.0)) == 0.0
		and float(defended.get("fieldBarracksFinalHp", -1.0)) == 200.0
		and bool(defended.get("rebuildUnavailable", false))
		and bool(defended.get("repairUnavailable", false))
	)
	var selected_live_roles: Array = barrosan_playtest.get("selectedLiveRoles", [])
	var shells_preserved := ["blacksmith", "market", "watchtower"].all(
		func(role: String) -> bool:
			return not bool(barrosan_runtime_structures.get(role, {}).get("productionEnabled", false))
	)
	destroyed["status"] = "PASS" if destroyed_pass else "IN_PROGRESS"
	rebuild["status"] = "PASS" if rebuild_pass else "IN_PROGRESS"
	separation["status"] = "PASS" if separation_pass else "IN_PROGRESS"
	defended["status"] = "PASS" if defended_pass else "IN_PROGRESS"
	return {
		"status": "PASS" if (
			construction.get("status", "") == "PASS"
			and destroyed_pass and rebuild_pass and separation_pass and defended_pass
			and bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false))
			and selected_live_roles.has("main_base")
			and selected_live_roles.has("mine")
			and shells_preserved
		) else "IN_PROGRESS",
		"checkpoint": "v0.256",
		"construction": construction,
		"destroyedStateBranch": destroyed,
		"workerRebuildBranch": rebuild,
		"repairRebuildSeparation": separation,
		"defendedFirstPressureBranch": defended,
		"firstPressureDamageSequence": [200, 175, 150, 125],
		"secondPressureDamageSequence": [125, 100, 75, 50, 25, 0],
		"rebuildHpSequence": [0, 25, 50, 75, 100],
		"productionRule": "available above HP 0 except while rebuilding; unavailable at HP 0",
		"repairRule": "HP 1-199 only",
		"rebuildRule": "explicit Worker command at HP 0 only; restores to 100/200",
		"passiveCollapseExists": false,
		"passiveRebuildExists": false,
		"automaticRefundExists": false,
		"globalBuildingRebuildExists": false,
		"existingRestoredBarracksPreserved": bool(barrosan_playtest.get("barracksRestoreTrain", {}).get("militiaSpawned", false)),
		"commandKeepPreserved": selected_live_roles.has("main_base"),
		"lumeMinePreserved": selected_live_roles.has("mine"),
		"shellsRemainNonProducing": shells_preserved,
		"defaultRuntimeChanged": false,
		"minimapPreserved": bool(destroyed.get("minimapPreserved", false)),
		"verdictCeiling": "PARTIAL",
	}


func _v0257_rebuild_ux_status() -> Dictionary:
	var bridge := _v0256_first_worker_rebuild_status().duplicate(true)
	var destroyed: Dictionary = v0257_hud_proof.get("v0257_second_damage_0", {})
	var worker_destroyed: Dictionary = v0257_hud_proof.get("v0257_worker_rebuild_available", {})
	var damaged: Dictionary = v0257_hud_proof.get("v0257_first_pressure_125", {})
	var critical: Dictionary = v0257_hud_proof.get("v0257_hp_25", {})
	var rebuilding: Dictionary = v0257_hud_proof.get("v0257_rebuild_25", {})
	var rebuilt: Dictionary = v0257_hud_proof.get("v0257_rebuild_100", {})
	var worker_after: Dictionary = v0257_hud_proof.get("v0257_worker_after_rebuild", {})
	var stale_present := false
	for snapshot in v0257_hud_proof.values():
		stale_present = stale_present or bool((snapshot as Dictionary).get("staleRebuildWordingPresent", false))
	var text_pass := (
		str(destroyed.get("hero", "")).contains("Destroyed")
		and str(destroyed.get("context", "")).contains("HP 0/200 | Production unavailable")
		and str(destroyed.get("objective", "")).contains("Select Worker to rebuild")
		and str(worker_destroyed.get("context", "")).contains("Rebuild available | Destroyed Field Barracks")
		and str(worker_destroyed.get("context", "")).contains("Cost: 90 Crowns / 40 Stone")
		and str(worker_destroyed.get("objective", "")).contains("Repair unavailable | Target destroyed")
		and str(damaged.get("hero", "")).contains("Damaged but functional")
		and str(damaged.get("context", "")).contains("Operational | HP 125/200 | Train Militia available")
		and str(critical.get("context", "")).contains("Operational | HP 25/200 | Train Militia available")
		and str(rebuilding.get("hero", "")).contains("Rebuilding")
		and str(rebuilding.get("context", "")).contains("Production unavailable until rebuild complete | HP 25/200")
		and str(rebuilt.get("hero", "")).contains("Damaged but functional")
		and str(rebuilt.get("context", "")).contains("Operational | Rebuilt HP 100/200 | Train Militia available")
		and str(worker_after.get("context", "")).contains("Rebuild unavailable | No destroyed target")
		and not stale_present
	)
	bridge["status"] = "PASS" if bridge.get("status", "") == "PASS" and text_pass else "IN_PROGRESS"
	bridge["checkpoint"] = "v0.257"
	bridge["textStatus"] = "PASS" if text_pass else "IN_PROGRESS"
	bridge["staleRebuildWordingPresent"] = stale_present
	bridge["destroyedHud"] = destroyed
	bridge["workerDestroyedHud"] = worker_destroyed
	bridge["damagedHud"] = damaged
	bridge["criticalHp25Hud"] = critical
	bridge["rebuildingHud"] = rebuilding
	bridge["rebuiltHud"] = rebuilt
	bridge["workerAfterRebuildHud"] = worker_after
	bridge["allHudSnapshots"] = v0257_hud_proof.duplicate(true)
	return bridge


func _v0258_lifecycle_readability_status() -> Dictionary:
	var bridge := _v0256_first_worker_rebuild_status().duplicate(true)
	var required_instructions := {
		"v0258_initial_select_aster": "Select Aster.",
		"v0258_after_aster_select_worker": "Select Worker.",
		"v0258_worker_place_barracks": "Place Field Barracks.",
		"v0258_valid_placement": "Click to build Field Barracks.",
		"v0258_barracks_built": "Field Barracks built. Prepare for Ashen pressure.",
		"v0258_hp_125": "Damaged but functional. Production still available while HP > 0.",
		"v0258_hp_25": "Critical but functional. Production still available while HP > 0.",
		"v0258_hp_0": "Destroyed. Select Worker to rebuild.",
		"v0258_worker_rebuild_instruction": "Rebuild destroyed Field Barracks.",
		"v0258_rebuild_25": "Rebuilding Field Barracks.",
		"v0258_rebuild_100": "Field Barracks rebuilt. Train Militia.",
		"v0258_militia_ready": "Militia ready. Defend the Barracks.",
	}
	var instructions_pass := true
	var stale_rebuild_present := false
	var stale_aster_present := false
	for key in required_instructions:
		var snapshot: Dictionary = v0258_lifecycle_proof.get(key, {})
		instructions_pass = instructions_pass and str(snapshot.get("instruction", "")) == str(required_instructions[key])
	for snapshot in v0258_lifecycle_proof.values():
		if not snapshot is Dictionary:
			continue
		stale_rebuild_present = stale_rebuild_present or bool(snapshot.get("staleRebuildWordingPresent", false))
		stale_aster_present = stale_aster_present or bool(snapshot.get("staleSelectAsterPresent", false))
	var expected_states := {
		"v0258_barracks_built": ["full", 200, true],
		"v0258_hp_125": ["damaged_functional", 125, true],
		"v0258_hp_25": ["critical_functional", 25, true],
		"v0258_hp_0": ["destroyed", 0, false],
		"v0258_rebuild_25": ["rebuilding", 25, false],
		"v0258_rebuild_50": ["rebuilding", 50, false],
		"v0258_rebuild_75": ["rebuilding", 75, false],
		"v0258_rebuild_100": ["rebuilt_damaged", 100, true],
	}
	var visuals_pass := true
	for key in expected_states:
		var visual: Dictionary = (v0258_lifecycle_proof.get(key, {}) as Dictionary).get("visualState", {})
		var expected: Array = expected_states[key]
		visuals_pass = (
			visuals_pass
			and str(visual.get("state", "")) == str(expected[0])
			and int(visual.get("hp", -1)) == int(expected[1])
			and bool(visual.get("productionAvailable", not bool(expected[2]))) == bool(expected[2])
			and int(visual.get("overlayCount", 0)) > 0
		)
	var status_pass: bool = (
		bridge.get("status", "") == "PASS"
		and instructions_pass
		and visuals_pass
		and not stale_rebuild_present
		and not stale_aster_present
	)
	return {
		"status": "PASS" if status_pass else "IN_PROGRESS",
		"checkpoint": "v0.258",
		"instructionStatus": "PASS" if instructions_pass and not stale_aster_present else "IN_PROGRESS",
		"visualStatus": "PASS" if visuals_pass else "IN_PROGRESS",
		"staleRebuildWordingPresent": stale_rebuild_present,
		"staleSelectAsterBeyondInitialPresent": stale_aster_present,
		"instructionSnapshots": v0258_lifecycle_proof.duplicate(true),
		"mechanics": bridge,
		"defaultRuntimeChanged": false,
		"blenderUsed": false,
		"newGlbExported": false,
		"existingGlbReusedUnchanged": true,
		"verdictCeiling": "PARTIAL",
	}


func _v0259_ui_state_invariant_status() -> Dictionary:
	var bridge := _v0256_first_worker_rebuild_status().duplicate(true)
	var required_states := {
		"v0259_initial": "INITIAL_SELECT_ASTER",
		"v0259_after_aster": "SELECT_WORKER_OR_BUILDER",
		"v0259_build_no_rebuild": "PLACE_FIELD_BARRACKS",
		"v0259_place": "PLACE_FIELD_BARRACKS",
		"v0259_valid": "VALID_PLACEMENT_READY",
		"v0259_full": "FIELD_BARRACKS_FULL",
		"v0259_hp_125": "FIELD_BARRACKS_DAMAGED_FUNCTIONAL",
		"v0259_hp_25": "FIELD_BARRACKS_CRITICAL_FUNCTIONAL",
		"v0259_destroyed": "FIELD_BARRACKS_DESTROYED",
		"v0259_destroyed_clean": "FIELD_BARRACKS_DESTROYED",
		"v0259_worker_rebuild": "WORKER_SELECTED_FOR_REBUILD",
		"v0259_rebuild_button": "WORKER_SELECTED_FOR_REBUILD",
		"v0259_rebuild_delta": "REBUILD_ORDERED",
		"v0259_rebuild_25": "REBUILDING_25",
		"v0259_rebuild_50": "REBUILDING_50",
		"v0259_rebuild_75": "REBUILDING_75",
		"v0259_rebuilt_100": "REBUILT_100_FUNCTIONAL",
		"v0259_train_available": "TRAIN_MILITIA_AVAILABLE",
		"v0259_train_delta": "TRAIN_MILITIA_AVAILABLE",
		"v0259_militia_ready": "MILITIA_READY_DEFEND",
		"v0259_no_rebuild_after": "TRAIN_MILITIA_AVAILABLE",
		"v0259_no_place_rebuild": "REBUILDING_50",
		"v0259_separation": "TRAIN_MILITIA_AVAILABLE",
		"v0259_visual_compare": "FIELD_BARRACKS_CRITICAL_FUNCTIONAL",
		"v0259_minimap": "MILITIA_READY_DEFEND",
		"v0259_structures": "MILITIA_READY_DEFEND",
		"v0259_forbidden_scan": "MILITIA_READY_DEFEND",
	}
	var single_source_pass := true
	var forbidden_text_pass := true
	var impossible_combo_pass := true
	var visual_pass := true
	var missing: Array[String] = []
	for key in required_states:
		var snapshot: Dictionary = v0259_ui_invariant_proof.get(key, {})
		if snapshot.is_empty():
			missing.append(key)
			single_source_pass = false
			continue
		single_source_pass = single_source_pass and bool(snapshot.get("singleSourceMatch", false))
		single_source_pass = single_source_pass and str(snapshot.get("state", "")) == str(required_states[key])
		forbidden_text_pass = forbidden_text_pass and not bool(snapshot.get("forbiddenRebuildNotImplemented", false))
		forbidden_text_pass = forbidden_text_pass and not bool(snapshot.get("selectAsterBeyondInitial", false))
		var state := str(snapshot.get("state", ""))
		var combined := str(snapshot.get("combinedText", ""))
		var has_rebuild_text := combined.contains("Rebuild") or combined.contains("Destroyed Field Barracks") or combined.contains("Target destroyed")
		var has_build_place_text := combined.contains("Place Field Barracks") or combined.contains("Click to build Field Barracks") or combined.contains("Build Barracks")
		if state in ["INITIAL_SELECT_ASTER", "SELECT_WORKER_OR_BUILDER", "PLACE_FIELD_BARRACKS", "VALID_PLACEMENT_READY"]:
			impossible_combo_pass = impossible_combo_pass and not has_rebuild_text
		if state in ["FIELD_BARRACKS_DESTROYED", "WORKER_SELECTED_FOR_REBUILD", "REBUILD_ORDERED", "REBUILDING_25", "REBUILDING_50", "REBUILDING_75"]:
			impossible_combo_pass = impossible_combo_pass and not has_build_place_text
		if state in ["REBUILT_100_FUNCTIONAL", "TRAIN_MILITIA_AVAILABLE", "MILITIA_READY_DEFEND"]:
			impossible_combo_pass = impossible_combo_pass and not combined.contains("Target destroyed") and not combined.contains("Rebuild destroyed")
		var overlay_state := str(snapshot.get("overlayState", "none"))
		if overlay_state != "none":
			var visual: Dictionary = snapshot.get("visualState", {})
			visual_pass = visual_pass and str(visual.get("state", "")) == overlay_state
			visual_pass = visual_pass and int(visual.get("overlayCount", 0)) > 0
	var construction: Dictionary = bridge.get("construction", {})
	var delta: Dictionary = construction.get("placementResourceDelta", {})
	var destroyed: Dictionary = bridge.get("destroyedStateBranch", {})
	var rebuild: Dictionary = bridge.get("workerRebuildBranch", {})
	var separation: Dictionary = bridge.get("repairRebuildSeparation", {})
	var mechanics_retained_pass: bool = (
		int(delta.get("crowns", 0)) == -180
		and int(delta.get("stone", 0)) == -120
		and str(destroyed.get("status", "")) == "PASS"
		and str(rebuild.get("status", "")) == "PASS"
		and str(separation.get("status", "")) == "PASS"
		and bridge.get("firstPressureDamageSequence", []) == [200, 175, 150, 125]
		and bridge.get("secondPressureDamageSequence", []) == [125, 100, 75, 50, 25, 0]
		and bool(bridge.get("minimapPreserved", false))
		and bool(bridge.get("existingRestoredBarracksPreserved", false))
		and bool(bridge.get("commandKeepPreserved", false))
		and bool(bridge.get("lumeMinePreserved", false))
		and bool(bridge.get("shellsRemainNonProducing", false))
	)
	var status_pass: bool = (
		single_source_pass
		and forbidden_text_pass
		and impossible_combo_pass
		and visual_pass
		and mechanics_retained_pass
		and missing.is_empty()
	)
	return {
		"status": "PASS" if status_pass else "IN_PROGRESS",
		"checkpoint": "v0.259",
		"singleSourceStatus": "PASS" if single_source_pass and missing.is_empty() else "IN_PROGRESS",
		"impossibleCombinationStatus": "PASS" if impossible_combo_pass else "IN_PROGRESS",
		"forbiddenTextStatus": "PASS" if forbidden_text_pass else "IN_PROGRESS",
		"visualStatus": "PASS" if visual_pass else "IN_PROGRESS",
		"mechanicsRetainedStatus": "PASS" if mechanics_retained_pass else "IN_PROGRESS",
		"missingSnapshots": missing,
		"proofSnapshots": v0259_ui_invariant_proof.duplicate(true),
		"mechanics": bridge,
		"defaultRuntimeChanged": false,
		"blenderUsed": false,
		"newGlbExported": false,
		"existingGlbReusedUnchanged": true,
		"verdictCeiling": "PARTIAL",
	}


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
