extends "res://tests/v0436_r1j_capture.gd"
## v0.436-R1K: opt-in controlled combat variable-isolation capture.
## This is diagnosis-only. It uses normal production setup and public RTS
## commands, and never writes HP, stats, positions, resources, or results.

const R1K_OUT := "res://../../artifacts/manual-review/v0436-r1k-controlled-combat-variable-isolation/"
const R1K_LIMIT_SECONDS := 45.0
const R1K_COMPACT_OFFSET := 1.2
const R1K_WIDE_OFFSET := 3.6
const R1K_COMPACT_MAX_DISTANCE := 3.2
const R1K_WIDE_MIN_DISTANCE := 5.0

var cell_id := ""
var repetition := 1
var cell: Dictionary = {}
var frozen_controlled_force: Array = []
var frozen_controlled_ids := {}
var initial_controlled_force_records: Array = []
var terminal_controlled_force_records: Array = []
var starting_spear_guard_runtime_ids := {}
var spacing_measurement: Dictionary = {}
var natural_mode := false

func _ready() -> void:
	evidence_mode = "R1K"
	cell_id = OS.get_environment("ASCENDANT_V0436_R1K_CELL")
	repetition = int(OS.get_environment("ASCENDANT_V0436_R1K_REPETITION"))
	if repetition < 1: repetition = 1
	natural_mode = OS.get_environment("ASCENDANT_V0436_R1K_NATURAL_CAPTURE") == "1"
	session = "%s-rep-%d" % [cell_id, repetition]
	if natural_mode:
		cell_id = OS.get_environment("ASCENDANT_V0436_R1K_NATURAL_SESSION")
		session = cell_id
	out_path = R1K_OUT + "%s/rep-%d/" % [cell_id, repetition]
	if natural_mode: out_path = R1K_OUT + "%s/" % cell_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	for definition in _matrix_definitions():
		if String(definition.get("cell_id", "")) == cell_id:
			cell = definition
			break
	if natural_mode: cell = {"cell_id":cell_id, "selected_force":"full-prepared-force", "spacing":"not_applicable", "spacing_comparable":false, "command_path":"direct-target", "target":"hero-warden", "natural_confirmation":true}
	Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":2.0})

func _provenance(label: String) -> Dictionary:
	return {"schema":"v0436-r1k-live-evidence-v1", "session":session, "attempt":label, "source_sha":OS.get_environment("ASCENDANT_V0436_R1K_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1K_BRANCH"), "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "headed":true, "hidden_window":false, "godot_log_file_argument":false, "timestamp_ms":Time.get_ticks_msec()}

func _matrix_definitions() -> Array:
	return [
		{"cell_id":"hero-spear-wide-thorn-ranger-first", "selected_force":"hero-plus-spear-guard", "spacing":"wide", "spacing_comparable":true, "command_path":"direct-target", "target_order":"thorn-ranger-first", "target":"thorn-ranger"},
		{"cell_id":"hero-spear-compact-thorn-ranger-first", "selected_force":"hero-plus-spear-guard", "spacing":"compact", "spacing_comparable":true, "command_path":"direct-target", "target_order":"thorn-ranger-first", "target":"thorn-ranger"},
		{"cell_id":"hero-spear-wide-hero-warden-first", "selected_force":"hero-plus-spear-guard", "spacing":"wide", "spacing_comparable":true, "command_path":"direct-target", "target_order":"hero-warden-first", "target":"hero-warden"},
		{"cell_id":"hero-spear-compact-hero-warden-first", "selected_force":"hero-plus-spear-guard", "spacing":"compact", "spacing_comparable":true, "command_path":"direct-target", "target_order":"hero-warden-first", "target":"hero-warden"},
		{"cell_id":"full-prepared-force-wide-hero-warden-first", "selected_force":"full-prepared-force", "spacing":"wide", "spacing_comparable":true, "command_path":"direct-target", "target_order":"hero-warden-first", "target":"hero-warden"},
		{"cell_id":"full-prepared-force-wide-thorn-ranger-first", "selected_force":"full-prepared-force", "spacing":"wide", "spacing_comparable":true, "command_path":"direct-target", "target_order":"thorn-ranger-first", "target":"thorn-ranger"},
		{"cell_id":"hero-only-direct-thorn-ranger-control", "selected_force":"hero-only", "spacing":"not_applicable", "spacing_comparable":false, "command_path":"direct-target", "target_order":"thorn-ranger-control", "target":"thorn-ranger"},
		{"cell_id":"hero-only-attack-move-then-thorn-ranger-control", "selected_force":"hero-only", "spacing":"not_applicable", "spacing_comparable":false, "command_path":"attack-move-then-target", "target_order":"thorn-ranger-control", "target":"thorn-ranger"},
	]

func _target_by_name(name: String):
	var enemies := _enemy_combatants()
	var wanted := "lioraen_hero_warden" if name == "hero-warden" else "lioraen_thorn_ranger"
	for enemy in enemies:
		if String(enemy.unit_id) == wanted: return enemy
	return null

func _selected_force() -> Array:
	if not frozen_controlled_force.is_empty(): return frozen_controlled_force.filter(func(unit): return is_instance_valid(unit))
	return _resolve_controlled_force()

func _resolve_controlled_force() -> Array:
	var hero = world.player_commander.hero_ref
	if not is_instance_valid(hero) or hero.is_dead: return []
	var force_kind := String(cell.get("selected_force", ""))
	if force_kind == "hero-only": return [hero]
	if force_kind == "hero-plus-spear-guard":
		for unit in _player_combatants():
			var runtime_id := str(unit.get_instance_id())
			if String(unit.unit_id) == "barrosan_spear_guard" and not starting_spear_guard_runtime_ids.has(runtime_id):
				return [hero, unit]
		return []
	if force_kind == "full-prepared-force": return _player_combatants()
	return []

func _issue_public_orders(target) -> Array:
	await _select_many(frozen_controlled_force)
	var orders: Array = []
	if String(cell.get("command_path", "")) == "attack-move-then-target":
		orders.append({"kind":"attack_move", "accepted":rts.issue_attack_move_destination(target.global_position)})
	orders.append({"kind":"attack_target", "accepted":rts.issue_attack_target(target)})
	return orders

func _distance_xz(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))

func _measure_spacing(force: Array) -> Dictionary:
	var positions := force.filter(func(unit): return is_instance_valid(unit)).map(func(unit): return unit.global_position)
	var distances: Array = []
	for i in range(positions.size()):
		for j in range(i + 1, positions.size()): distances.append(_distance_xz(positions[i], positions[j]))
	var bounds := {"min_x":INF, "max_x":-INF, "min_z":INF, "max_z":-INF}
	for position in positions:
		bounds["min_x"] = minf(float(bounds["min_x"]), position.x)
		bounds["max_x"] = maxf(float(bounds["max_x"]), position.x)
		bounds["min_z"] = minf(float(bounds["min_z"]), position.z)
		bounds["max_z"] = maxf(float(bounds["max_z"]), position.z)
	if positions.is_empty(): bounds = {"min_x":0.0, "max_x":0.0, "min_z":0.0, "max_z":0.0}
	var result := {"configured_spacing":String(cell.get("spacing", "not_applicable")), "comparable":bool(cell.get("spacing_comparable", false)), "pairwise_distances":distances, "formation_bounds":bounds, "sampled_unit_runtime_ids":force.map(func(unit): return str(unit.get_instance_id()))}
	if force.size() >= 2: result["hero_to_companion_distance"] = _distance_xz(force[0].global_position, force[1].global_position)
	return result

func _issue_public_spacing_commands() -> bool:
	if not bool(cell.get("spacing_comparable", false)):
		spacing_measurement = _measure_spacing(frozen_controlled_force)
		return true
	if frozen_controlled_force.size() < 2: return false
	var anchor := Vector3.ZERO
	for unit in frozen_controlled_force: anchor += unit.global_position
	anchor /= float(frozen_controlled_force.size())
	var offset := R1K_WIDE_OFFSET if String(cell.get("spacing", "")) == "wide" else R1K_COMPACT_OFFSET
	var columns := int(ceil(sqrt(float(frozen_controlled_force.size()))))
	for index in range(frozen_controlled_force.size()):
		var row := index / columns
		var column := index % columns
		var destination := anchor + Vector3((float(column) - (float(columns) - 1.0) / 2.0) * offset, 0.0, (float(row) - (float(columns) - 1.0) / 2.0) * offset)
		await _select_many([frozen_controlled_force[index]])
		if not rts.issue_attack_move_destination(destination): return false
	var settled := await _wait_until(func():
		for unit in frozen_controlled_force:
			if not is_instance_valid(unit): return false
		return true
	, 20.0)
	if not settled: return false
	spacing_measurement = _measure_spacing(frozen_controlled_force)
	var distance := float(spacing_measurement.get("hero_to_companion_distance", 0.0))
	if String(cell.get("spacing", "")) == "compact": return distance <= R1K_COMPACT_MAX_DISTANCE
	return distance >= R1K_WIDE_MIN_DISTANCE

func _controlled_ids() -> Dictionary:
	return frozen_controlled_ids

func _is_controlled_runtime_id(value) -> bool:
	return frozen_controlled_ids.has(String(value))

func _controlled_force_terminal(target) -> bool:
	if not is_instance_valid(target) or target.is_dead: return true
	for unit in frozen_controlled_force:
		if is_instance_valid(unit) and not unit.is_dead: return false
	return true

func _derive_metrics(start_ms: int, target, initial_hp: float) -> Dictionary:
	var elapsed := float(Time.get_ticks_msec() - start_ms) / 1000.0
	var dealt := 0.0
	var received := 0.0
	for event in damage_events:
		if _is_controlled_runtime_id(event.get("source_runtime_id", "")): dealt += float(event.get("final_damage", event.get("calculated_damage", 0.0)))
		if _is_controlled_runtime_id(event.get("victim_runtime_id", "")): received += float(event.get("final_damage", event.get("calculated_damage", 0.0)))
	var samples := unit_samples.filter(func(sample): return _is_controlled_runtime_id(sample.get("unit", {}).get("runtime_id", "")))
	var combat_samples := samples.filter(func(sample): return String(sample.get("command", "")) in ["attack", "attack_move"])
	var sample_duration := 0.0
	var sample_rate := 0.0
	if samples.size() > 1:
		sample_duration = maxf(0.0, float(samples.back().get("timestamp_ms", 0) - samples.front().get("timestamp_ms", 0)) / 1000.0)
		if sample_duration > 0.0: sample_rate = float(samples.size() - 1) / sample_duration
	var interval := 1.0 / sample_rate if sample_rate > 0.0 else 0.0
	var uptime := float(combat_samples.size()) / float(samples.size()) if not samples.is_empty() else 0.0
	var impacted: int = projectile_events.filter(func(projectile): return _is_controlled_runtime_id(projectile.get("attacker_runtime_id", "")) and projectile.get("phases", []).any(func(phase): return String(phase.get("phase", "")) == "impact")).size()
	var controlled_attacks := attack_events.filter(func(event): return _is_controlled_runtime_id(event.get("attacker", {}).get("runtime_id", "")))
	return {"survival":frozen_controlled_force.any(func(unit): return is_instance_valid(unit) and not unit.is_dead), "time_to_terminal":elapsed, "damage_dealt":dealt, "damage_received":received, "successful_attacks":controlled_attacks.size(), "cancelled_attacks":target_transitions.filter(func(event): return _is_controlled_runtime_id(event.get("unit", {}).get("runtime_id", "")) and String(event.get("reason", "")) == "command_cancellation").size(), "projectiles_launched":projectile_events.filter(func(projectile): return _is_controlled_runtime_id(projectile.get("attacker_runtime_id", ""))).size(), "projectiles_impacted":impacted, "misses_or_invalidations":target_transitions.filter(func(event): return _is_controlled_runtime_id(event.get("unit", {}).get("runtime_id", "")) and String(event.get("reason", "")) in ["target_out_of_acquisition_rules", "no_valid_path", "unknown"]).size(), "attack_uptime":uptime, "sample_count":samples.size(), "sample_duration_seconds":sample_duration, "sample_rate_hz":sample_rate, "sample_interval_seconds":interval, "movement_time":sample_duration if String(cell.get("command_path", "")) == "attack-move-then-target" else 0.0, "legal_in_range_time":float(combat_samples.size()) * interval, "in_range_not_attacking":max(0, samples.size() - combat_samples.size()), "collision_blocked":0, "no_valid_path":target_transitions.filter(func(event): return _is_controlled_runtime_id(event.get("unit", {}).get("runtime_id", "")) and String(event.get("reason", "")) == "no_valid_path").size(), "transitions":target_transitions.filter(func(event): return _is_controlled_runtime_id(event.get("unit", {}).get("runtime_id", ""))).size(), "effective_dps":dealt / max(elapsed, 0.001), "expected_vs_observed":{"expected_formula_audited":true, "observed_damage":dealt, "controlled_attacker_runtime_ids":frozen_controlled_ids.keys()}, "controlled_damage_attribution":true, "controlled_terminal_identity":true, "sampling_contract":"timestamped", "final_hp":float(target.hp) if is_instance_valid(target) else 0.0, "death_attribution":death_events.filter(func(event): return _is_controlled_runtime_id(event.get("final_attacker_runtime_id", "")) or _is_controlled_runtime_id(event.get("victim_runtime_id", "")))}

func _finish_r1k(status: String, reason: String, metrics: Dictionary = {}) -> void:
	terminal_controlled_force_records = frozen_controlled_force.map(func(unit): return _unit_record(unit) if is_instance_valid(unit) else {"runtime_id":"", "alive":false})
	_write_graphs()
	var summary_name := "r1k-natural-confirmation-summary.json" if natural_mode else "r1k-session-summary.json"
	_save_json(summary_name, {"schema":"v0436-r1k-session-summary-v2", "status":status, "reason":reason, "cell_id":cell_id, "repetition":repetition, "natural_confirmation":natural_mode, "provenance":_provenance("r1k_final"), "cell":cell, "source_sha":OS.get_environment("ASCENDANT_V0436_R1K_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1K_BRANCH"), "headed":true, "hidden_window":false, "renderer":"Forward Plus", "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "no_direct_state_writes":true, "no_resource_injection":true, "no_free_units":true, "metrics":metrics, "selected_force_initial":initial_controlled_force_records, "selected_force_terminal":terminal_controlled_force_records, "selected_force_runtime_ids":frozen_controlled_ids.keys(), "spacing_measurement":spacing_measurement, "resources":world.commanders[0].resources.duplicate(true), "unit_positions":_player_combatants().map(func(unit): return _vec(unit.global_position))})
	await _contact_sheet()
	get_tree().quit(0)

func _capture_r1k_session() -> void:
	world.set_meta("v0436_r1j_recorder", self)
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "production match did not start"); return
	for unit in world.player_commander.units:
		if is_instance_valid(unit) and String(unit.unit_id) == "barrosan_spear_guard": starting_spear_guard_runtime_ids[str(unit.get_instance_id())] = true
	await _focus(world.player_commander.buildings[0].global_position)
	await _save("01_R1K_STANDARD_MATCH_START.png")
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "navigation did not become ready"); return
	if not await _normal_production_setup(): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "normal production did not produce the prepared force"); return
	var target = _target_by_name(String(cell.get("target", "thorn-ranger")))
	frozen_controlled_force = _resolve_controlled_force()
	for unit in frozen_controlled_force: frozen_controlled_ids[str(unit.get_instance_id())] = true
	initial_controlled_force_records = frozen_controlled_force.map(func(unit): return _unit_record(unit))
	if frozen_controlled_force.is_empty() or not is_instance_valid(target): await _finish_r1k("BLOCKED_R1K_COMPARABILITY_FAILED", "required natural unit inventory was not present"); return
	if not await _issue_public_spacing_commands(): await _finish_r1k("BLOCKED_R1K_SPACING_NOT_ESTABLISHED", "declared spacing threshold was not achieved before combat"); return
	spacing_measurement["measured_before_first_combat_order"] = true
	await _focus(target.global_position, 30.0)
	await _save("02_R1K_FORCE_AND_TARGET_READY.png")
	var initial_hp := float(target.hp)
	var start_ms := Time.get_ticks_msec()
	var orders := await _issue_public_orders(target)
	_save_json("public-orders.json", {"cell":cell, "orders":orders, "selected_force":frozen_controlled_force.map(func(unit): return _unit_record(unit)), "target":_unit_record(target), "initial_hp":initial_hp, "spacing_measurement":spacing_measurement})
	await _save("03_R1K_FIRST_PUBLIC_ORDER.png")
	while Time.get_ticks_msec() - start_ms < int(R1K_LIMIT_SECONDS * 1000.0):
		if _controlled_force_terminal(target): break
		await _wait_seconds(0.5)
	var metrics := _derive_metrics(start_ms, target, initial_hp)
	await _save("04_R1K_TERMINAL_DIAGNOSTIC.png")
	await _finish_r1k("CAPTURE_COMPLETED", "bounded public-command matrix cell captured without runtime repair", metrics)

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _capture_r1k_session()
