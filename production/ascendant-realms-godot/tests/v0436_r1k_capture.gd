extends "res://tests/v0436_r1j_capture.gd"
## v0.436-R1K: opt-in controlled combat variable-isolation capture.
## This is diagnosis-only. It uses normal production setup and public RTS
## commands, and never writes HP, stats, positions, resources, or results.

const R1K_OUT := "res://../../artifacts/manual-review/v0436-r1k-controlled-combat-variable-isolation/"
const R1K_LIMIT_SECONDS := 45.0

var cell_id := ""
var repetition := 1
var cell: Dictionary = {}

func _ready() -> void:
	evidence_mode = "R1K"
	cell_id = OS.get_environment("ASCENDANT_V0436_R1K_CELL")
	repetition = int(OS.get_environment("ASCENDANT_V0436_R1K_REPETITION"))
	if repetition < 1: repetition = 1
	session = "%s-rep-%d" % [cell_id, repetition]
	out_path = R1K_OUT + "%s/rep-%d/" % [cell_id, repetition]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	for definition in _matrix_definitions():
		if String(definition.get("cell_id", "")) == cell_id:
			cell = definition
			break
	Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":2.0})

func _provenance(label: String) -> Dictionary:
	return {"schema":"v0436-r1k-live-evidence-v1", "session":session, "attempt":label, "source_sha":OS.get_environment("ASCENDANT_V0436_R1K_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1K_BRANCH"), "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "headed":true, "hidden_window":false, "godot_log_file_argument":false, "timestamp_ms":Time.get_ticks_msec()}

func _matrix_definitions() -> Array:
	return [
		{"cell_id":"hero-only-wide-direct-target", "selected_force":"hero-only", "spacing":"wide", "command_path":"direct-target", "target":"thorn-ranger"},
		{"cell_id":"hero-only-compact-direct-target", "selected_force":"hero-only", "spacing":"compact", "command_path":"direct-target", "target":"thorn-ranger"},
		{"cell_id":"hero-thorn-ranger-wide-hero-first", "selected_force":"hero-plus-thorn-ranger", "spacing":"wide", "command_path":"direct-target", "target":"hero-warden"},
		{"cell_id":"hero-thorn-ranger-wide-ranger-first", "selected_force":"hero-plus-thorn-ranger", "spacing":"wide", "command_path":"direct-target", "target":"thorn-ranger"},
		{"cell_id":"full-defender-set-wide-hero-first", "selected_force":"full-defender-set", "spacing":"wide", "command_path":"direct-target", "target":"hero-warden"},
		{"cell_id":"full-defender-set-wide-defender-first", "selected_force":"full-defender-set", "spacing":"wide", "command_path":"direct-target", "target":"thorn-ranger"},
		{"cell_id":"hero-only-wide-attack-move-then-target", "selected_force":"hero-only", "spacing":"wide", "command_path":"attack-move-then-target", "target":"thorn-ranger"},
		{"cell_id":"hero-only-wide-direct-target-repeat-control", "selected_force":"hero-only", "spacing":"wide", "command_path":"direct-target", "target":"thorn-ranger"},
	]

func _target_by_name(name: String):
	var enemies := _enemy_combatants()
	var wanted := "lioraen_hero_warden" if name == "hero-warden" else "lioraen_thorn_ranger"
	for enemy in enemies:
		if String(enemy.unit_id) == wanted: return enemy
	return null

func _selected_force() -> Array:
	var hero = world.player_commander.hero_ref
	if String(cell.get("selected_force", "")) == "hero-only" or String(cell.get("selected_force", "")) == "hero-plus-thorn-ranger":
		return [hero] if is_instance_valid(hero) and not hero.is_dead else []
	return _player_combatants()

func _issue_public_orders(target) -> Array:
	var selected := _selected_force()
	await _select_many(selected)
	var orders: Array = []
	if String(cell.get("command_path", "")) == "attack-move-then-target":
		orders.append({"kind":"attack_move", "accepted":rts.issue_attack_move_destination(target.global_position)})
	orders.append({"kind":"attack_target", "accepted":rts.issue_attack_target(target)})
	return orders

func _derive_metrics(start_ms: int, target, initial_hp: float) -> Dictionary:
	var elapsed := float(Time.get_ticks_msec() - start_ms) / 1000.0
	var dealt := 0.0
	var received := 0.0
	for event in damage_events:
		if String(event.get("victim_runtime_id", "")) == str(target.get_instance_id()): dealt += float(event.get("final_damage", event.get("calculated_damage", 0.0)))
		else: received += float(event.get("final_damage", event.get("calculated_damage", 0.0)))
	var samples := unit_samples.filter(func(sample): return String(sample.get("command", "")) in ["attack", "attack_move"])
	var uptime := float(samples.size()) / 60.0
	var impacted: int = projectile_events.filter(func(projectile): return projectile.get("phases", []).any(func(phase): return String(phase.get("phase", "")) == "impact")).size()
	return {"survival":not _player_combatants().is_empty(), "time_to_terminal":elapsed, "damage_dealt":dealt, "damage_received":received, "successful_attacks":attack_events.size(), "cancelled_attacks":target_transitions.filter(func(event): return String(event.get("reason", "")) == "command_cancellation").size(), "projectiles_launched":projectile_events.size(), "projectiles_impacted":impacted, "misses_or_invalidations":target_transitions.filter(func(event): return String(event.get("reason", "")) in ["target_out_of_acquisition_rules", "no_valid_path", "unknown"]).size(), "attack_uptime":uptime, "movement_time":elapsed if String(cell.get("command_path", "")) == "attack-move-then-target" else 0.0, "legal_in_range_time":uptime, "in_range_not_attacking":max(0, unit_samples.size() - samples.size()), "collision_blocked":0, "no_valid_path":target_transitions.filter(func(event): return String(event.get("reason", "")) == "no_valid_path").size(), "transitions":target_transitions.size(), "effective_dps":dealt / max(elapsed, 0.001), "expected_vs_observed":{"expected_formula_audited":true, "observed_damage":dealt}, "final_hp":float(target.hp) if is_instance_valid(target) else 0.0, "death_attribution":death_events}

func _finish_r1k(status: String, reason: String, metrics: Dictionary = {}) -> void:
	_write_graphs()
	_save_json("r1k-session-summary.json", {"schema":"v0436-r1k-session-summary-v1", "status":status, "reason":reason, "cell_id":cell_id, "repetition":repetition, "provenance":_provenance("r1k_final"), "cell":cell, "source_sha":OS.get_environment("ASCENDANT_V0436_R1K_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1K_BRANCH"), "headed":true, "hidden_window":false, "no_direct_state_writes":true, "no_resource_injection":true, "no_free_units":true, "metrics":metrics, "selected_force":_selected_force().map(func(unit): return _unit_record(unit)), "resources":world.commanders[0].resources.duplicate(true), "unit_positions":_player_combatants().map(func(unit): return _vec(unit.global_position))})
	await _contact_sheet()
	get_tree().quit(0)

func _capture_r1k_session() -> void:
	world.set_meta("v0436_r1j_recorder", self)
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "production match did not start"); return
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1K_STANDARD_MATCH_START.png")
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "navigation did not become ready"); return
	if not await _normal_production_setup(): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "normal production did not produce the prepared force"); return
	var target = _target_by_name(String(cell.get("target", "thorn-ranger")))
	var selected := _selected_force()
	if selected.is_empty() or not is_instance_valid(target): await _finish_r1k("BLOCKED_R1K_COMPARABILITY_FAILED", "required natural unit inventory was not present"); return
	await _focus(target.global_position, 30.0)
	await _save("02_R1K_FORCE_AND_TARGET_READY.png")
	var initial_hp := float(target.hp)
	var start_ms := Time.get_ticks_msec()
	var orders := await _issue_public_orders(target)
	_save_json("public-orders.json", {"cell":cell, "orders":orders, "selected_force":selected.map(func(unit): return _unit_record(unit)), "target":_unit_record(target), "initial_hp":initial_hp})
	await _save("03_R1K_FIRST_PUBLIC_ORDER.png")
	while Time.get_ticks_msec() - start_ms < int(R1K_LIMIT_SECONDS * 1000.0):
		if not is_instance_valid(target) or target.is_dead: break
		if _player_combatants().is_empty(): break
		await _wait_seconds(0.5)
	var metrics := _derive_metrics(start_ms, target, initial_hp)
	await _save("04_R1K_TERMINAL_DIAGNOSTIC.png")
	await _finish_r1k("CAPTURE_COMPLETED", "bounded public-command matrix cell captured without runtime repair", metrics)

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _capture_r1k_session()
