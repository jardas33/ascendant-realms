extends Node
## Deterministic runtime matrix for the Hollowspan player visibility foundation.
## This harness only moves runtime test entities and never writes save data.

const OUT := "D:/CodexData/evidence/player-visibility-state-architecture-r1/runtime-matrix.json"
var game_root
var world
var rts
var cases: Array = []

func capture_gameplay(p_root: Node) -> void:
	game_root = p_root
	await get_tree().process_frame
	await get_tree().process_frame
	var deadline := Time.get_ticks_msec() + 30000
	while (not is_instance_valid(game_root.world) or not game_root.world.game_running) and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	world = game_root.world
	rts = game_root.rts
	if not is_instance_valid(world) or not world.game_running:
		_finish({"passed":false, "reason":"match did not start", "cases":cases})
		return
	await get_tree().create_timer(0.35).timeout
	_run_matrix()

func _record(name: String, passed: bool, detail: String = "") -> void:
	cases.append({"name":name, "passed":passed, "detail":detail})

func _run_matrix() -> void:
	var friendly = world.commanders[0].units[0]
	var hostile = world.commanders[1].units.filter(func(u): return is_instance_valid(u) and not u.is_worker)[0]
	var hostile_building = world.commanders[1].buildings[0]
	var resource = world.get_tree().get_nodes_in_group("resources")[0]
	var far := Vector3(120.0, 0.0, 120.0)
	var near := Vector3(0.0, 0.0, 0.0)
	friendly.global_position = near
	hostile.global_position = far
	hostile_building.global_position = far
	resource.global_position = far
	world._update_player_visibility()
	_record("grid_has_four_unit_cells", is_equal_approx(float(world.visibility_grid_contract().get("cell_size")), 4.0))
	_record("grid_has_expected_columns", int(world.visibility_grid_contract().get("columns", 0)) == 68)
	_record("grid_has_expected_rows", int(world.visibility_grid_contract().get("rows", 0)) == 68)
	_record("initial_far_cell_unexplored", world.player_visibility_state_at(far) == world.VISIBILITY_UNEXPLORED)
	_record("friendly_unit_always_visible", world.is_player_visible(friendly))
	_record("hostile_unit_far_hidden", not world.is_player_visible(hostile))
	_record("hostile_building_far_hidden", not world.is_player_visible(hostile_building))
	_record("resource_far_hidden", not world.is_player_visible(resource))
	_record("hostile_unit_visual_hidden", not hostile.visible)
	_record("hostile_building_visual_hidden", not hostile_building.visible)
	_record("resource_visual_hidden", not resource.visible)
	friendly.global_position = far
	world._update_player_visibility()
	_record("new_cell_currently_visible", world.player_visibility_state_at(far) == world.VISIBILITY_CURRENTLY_VISIBLE)
	_record("hostile_unit_near_visible", world.is_player_visible(hostile))
	_record("hostile_building_near_visible", world.is_player_visible(hostile_building))
	_record("resource_near_visible", world.is_player_visible(resource))
	_record("hostile_unit_visual_restored", hostile.visible)
	_record("hostile_building_visual_restored", hostile_building.visible)
	_record("resource_visual_restored", resource.visible)
	friendly.global_position = near
	world._update_player_visibility()
	_record("previously_seen_cell_explored", world.player_visibility_state_at(far) == world.VISIBILITY_EXPLORED_NOT_VISIBLE)
	_record("seen_enemy_hidden_after_loss", not world.is_player_visible(hostile))
	_record("player_direct_attack_gate", not friendly._can_attack_target(hostile))
	_record("player_resource_command_gate", not world.is_resource_command_valid(resource, friendly))
	_record("ai_query_remains_omniscient", world.find_enemy_in_range(hostile, 1000.0) == friendly)
	_record("rts_hostile_inspection_gate", not rts._is_hostile_inspectable(hostile))
	_record("visibility_update_is_runtime_only", not world.has_meta("visibility_save_state"))
	_finish({"passed":cases.all(func(row): return bool(row.get("passed", false))), "case_count":cases.size(), "cases":cases, "grid":world.visibility_grid_contract()})

func _finish(payload: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute("D:/CodexData/evidence/player-visibility-state-architecture-r1")
	var file := FileAccess.open(OUT, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload, "  "))
		file.store_line("")
	get_tree().quit(0 if bool(payload.get("passed", false)) else 1)
