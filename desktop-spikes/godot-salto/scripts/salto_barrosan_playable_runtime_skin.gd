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
const PORTABLE_CONTENT_PATH := "res://data/generated/content-subset.json"

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
var v0246_militia_definition: Dictionary = {}
var v0251_defended_proof: Dictionary = {}
var v0251_undefended_proof: Dictionary = {}
var v0252_defended_proof: Dictionary = {}
var v0252_missed_window_proof: Dictionary = {}
var v0253_defended_proof: Dictionary = {}
var v0253_repair_proof: Dictionary = {}


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
	if barrosan_runtime_checkpoint == "v0.253" and runtime.selected_ids.has("worker_00"):
		var repair: Dictionary = barrosan_playtest.get("v0253WorkerRepair", {})
		var repair_available := _v0253_repair_command_available()
		hud_hero_label.text = "Selected Worker"
		hud_context_label.text = "Repair order accepted | Repairing Field Barracks | Ready" if bool(repair.get("repairOrderAccepted", false)) and not bool(repair.get("repairComplete", false)) else ("Repair available | Target damaged Field Barracks | Ready" if repair_available else "Repair unavailable | No damaged target")
		hud_objective_strip_label.text = "Repairing Field Barracks" if bool(repair.get("repairStarted", false)) and not bool(repair.get("repairComplete", false)) else ("Field Barracks restored" if bool(repair.get("repairComplete", false)) else "Repair damaged Field Barracks")
		hud_objective_label.text = "HP %s/200 | %s" % [int(_v0251_field_barracks_health()), "Repair complete" if bool(repair.get("repairComplete", false)) else ("Repair progress %s/3" % int(repair.get("repairTickCount", 0)) if bool(repair.get("repairStarted", false)) else "Worker repair available")]
		if hud_work_button != null:
			hud_work_button.text = "Repair" if repair_available else "Repair unavailable"
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


func set_barrosan_runtime_review_mode(mode: String) -> void:
	barrosan_runtime_review_mode = mode
	if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		_ensure_v0246_field_militia_active()
	if barrosan_runtime_checkpoint in ["v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"]:
		_ensure_v0247_ashen_raider_active()
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
			if mode == "clean":
				barrosan_selected_role_id = ""
	_sync_barrosan_runtime_visuals()
	_sync_hud()


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
		"health": V0251_FIELD_BARRACKS_MAX_HP if barrosan_runtime_checkpoint in ["v0.251", "v0.252", "v0.253"] else 650.0,
		"maxHealth": V0251_FIELD_BARRACKS_MAX_HP if barrosan_runtime_checkpoint in ["v0.251", "v0.252", "v0.253"] else 650.0,
		"constructionState": "complete",
		"constructionProgress": 1.0,
		"productionQueue": [],
		"productionEnabled": barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"],
		"productionLimit": "militia-single-slot-single-spawn" if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else "none",
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
		_begin_v0253_worker_repair()
		return
	if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] and barrosan_selected_role_id == V0245_CONSTRUCTED_KEY:
		_queue_v0246_field_militia()
		return
	super._hud_work_pressed()


func _v0253_repair_command_available() -> bool:
	if barrosan_runtime_checkpoint != "v0.253":
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
	if barrosan_runtime_checkpoint != "v0.253":
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
	if (
		_v0245_constructed_count() != 1
		or not bool(production.get("authorityLoaded", false))
		or bool(production.get("spawned", false))
		or not queue.is_empty()
	):
		production["lastRejectReason"] = "single-slot-occupied-or-limit-reached"
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
	timing["damageOccurredDuringWarning"] = _v0251_field_barracks_health() != V0251_FIELD_BARRACKS_MAX_HP
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


func _v0251_set_field_barracks_health(health: float) -> void:
	for index in range(runtime.structures.size()):
		var structure: Dictionary = runtime.structures[index]
		if str(structure.get("id", "")) != V0245_CONSTRUCTED_RUNTIME_ID:
			continue
		structure["health"] = health
		structure["maxHealth"] = V0251_FIELD_BARRACKS_MAX_HP
		structure["alive"] = true
		runtime.structures[index] = structure
		break
	if barrosan_runtime_structures.has(V0245_CONSTRUCTED_KEY):
		var cached: Dictionary = barrosan_runtime_structures[V0245_CONSTRUCTED_KEY]
		cached["health"] = health
		cached["maxHealth"] = V0251_FIELD_BARRACKS_MAX_HP
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
	if barrosan_runtime_checkpoint not in ["v0.251", "v0.252", "v0.253"]:
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
		"authoritativeConstructionBridge": _v0245_construction_status() if barrosan_runtime_checkpoint in ["v0.245", "v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else {},
		"fieldBarracksProductionBridge": _v0246_production_status() if barrosan_runtime_checkpoint in ["v0.246", "v0.247", "v0.248", "v0.249", "v0.250", "v0.251", "v0.252", "v0.253"] else {},
		"firstAshenPressureEncounter": _v0247_pressure_status() if barrosan_runtime_checkpoint in ["v0.247", "v0.248"] else {},
		"ashenPressureReadabilityTiming": _v0248_readability_status() if barrosan_runtime_checkpoint == "v0.248" else {},
		"boundedCombatResolutionBridge": _v0249_combat_status() if barrosan_runtime_checkpoint == "v0.249" else {},
		"explicitAttackOrderBridge": _v0250_attack_order_status() if barrosan_runtime_checkpoint == "v0.250" else {},
		"firstDefenseConsequenceBridge": _v0251_defense_consequence_status() if barrosan_runtime_checkpoint == "v0.251" else {},
		"threatTimingFeedbackBridge": _v0252_threat_timing_status() if barrosan_runtime_checkpoint == "v0.252" else {},
		"firstWorkerRepairBridge": _v0253_worker_repair_status() if barrosan_runtime_checkpoint == "v0.253" else {},
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
