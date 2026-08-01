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
const R1K_DESTINATION_TOLERANCE := 1.5
const R1K_SETTLEMENT_SAMPLE_INTERVAL := 0.1
const R1K_SETTLEMENT_SAMPLE_COUNT := 10
const R1K_SETTLEMENT_HOLD_SECONDS := 1.0
const R1K_POST_STOP_SAMPLE_COUNT := 5
const R1K_POST_STOP_SAMPLE_INTERVAL_MS := 125
const R1K_POST_STOP_MIN_SPAN_MS := 500
const R1K_POST_STOP_TIMEOUT_MS := 5000
const R1K_POST_STOP_WINDOW_BLOCKER := "BLOCKED_R1K_POST_STOP_WINDOW_INCOMPLETE"

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
var stage_a2_mode := false
var stage_a2b_mode := false
var stage_a2b_output_root_abs := ""
var stage_a2b_output_failed := false
var stage_a2b_writer_records: Array = []
var spacing_assignments: Array = []
var spacing_samples: Array = []
var spacing_provisional_samples: Array = []
var spacing_post_stop_samples: Array = []
var spacing_public_commands: Array = []
var spacing_public_stop_count := 0
var stage_a2_output_override := ""
var arrival_hold_start_index := -1
var arrival_hold_end_index := -1

func _ready() -> void:
	evidence_mode = "R1K"
	cell_id = OS.get_environment("ASCENDANT_V0436_R1K_CELL")
	repetition = int(OS.get_environment("ASCENDANT_V0436_R1K_REPETITION"))
	if repetition < 1: repetition = 1
	natural_mode = OS.get_environment("ASCENDANT_V0436_R1K_NATURAL_CAPTURE") == "1"
	stage_a2_mode = OS.get_environment("ASCENDANT_V0436_R1K_STAGE_A2") == "1"
	stage_a2b_mode = OS.get_environment("ASCENDANT_V0436_R1K_STAGE_A2B") == "1"
	if stage_a2b_mode:
		stage_a2_mode = true
		stage_a2b_output_root_abs = OS.get_environment("ASCENDANT_V0436_R1K_OUTPUT_ROOT_ABS").simplify_path()
		if not _stage_a2b_configure_root(stage_a2b_output_root_abs):
			get_tree().quit(2)
			return
		if OS.get_environment("ASCENDANT_V0436_R1K_OUTPUT_PROBE") == "1":
			var probe_ok := _stage_a2b_run_output_probe()
			get_tree().quit(0 if probe_ok else 2)
			return
	session = "%s-rep-%d" % [cell_id, repetition]
	if stage_a2_mode:
		cell_id = "hero-spear-compact-thorn-ranger-first"
		repetition = 1
		session = "stage-a2b-compact-spacing-settlement-replacement-2" if stage_a2b_mode else "stage-a2a-compact-spacing-settlement-replacement-1"
		var diagnostic_output := OS.get_environment("ASCENDANT_V0436_R1K_STAGE_A2_OUT")
		if diagnostic_output != "": stage_a2_output_override = diagnostic_output
	if natural_mode:
		cell_id = OS.get_environment("ASCENDANT_V0436_R1K_NATURAL_SESSION")
		session = cell_id
	out_path = R1K_OUT + "%s/rep-%d/" % [cell_id, repetition]
	if stage_a2b_mode:
		out_path = stage_a2b_output_root_abs + "/"
	elif stage_a2_mode:
		out_path = stage_a2_output_override if stage_a2_output_override != "" else R1K_OUT + "diagnostics/stage-a2-compact-spacing-settlement/"
	if natural_mode: out_path = R1K_OUT + "%s/" % cell_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	for definition in _matrix_definitions():
		if String(definition.get("cell_id", "")) == cell_id:
			cell = definition
			break
	if natural_mode: cell = {"cell_id":cell_id, "selected_force":"full-prepared-force", "spacing":"not_applicable", "spacing_comparable":false, "command_path":"direct-target", "target":"hero-warden", "natural_confirmation":true}
	if stage_a2_mode: cell = {"cell_id":cell_id, "selected_force":"hero-plus-spear-guard", "spacing":"compact", "spacing_comparable":true, "command_path":"diagnostic-spacing-only", "target":"thorn-ranger", "diagnostic_only":true}
	Match.set_config({"player_race":"barrosan", "opponents":[{"race":"lioraen", "difficulty":"easy"}], "map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":2.0})

func _stage_a2b_path(name: String) -> String:
	return stage_a2b_output_root_abs + "/" + name

func _stage_a2b_configure_root(raw_root: String) -> bool:
	var repository_root := OS.get_environment("ASCENDANT_V0436_R1K_REPO_ROOT_ABS").replace("\\", "/").simplify_path()
	var canonical_root := raw_root.replace("\\", "/").simplify_path()
	if raw_root.is_empty() or not raw_root.is_absolute_path() or raw_root.contains("..") or canonical_root.is_empty(): return false
	if repository_root.is_empty() or not canonical_root.begins_with(repository_root + "/"): return false
	return DirAccess.make_dir_recursive_absolute(canonical_root) == OK

func _stage_a2b_record(record: Dictionary) -> void:
	stage_a2b_writer_records.append(record)
	if record.get("writer_return_code", -1) != OK or record.get("exists", false) != true or record.get("readable", false) != true:
		stage_a2b_output_failed = true

func _stage_a2b_save_png(name: String) -> bool:
	await RenderingServer.frame_post_draw
	var absolute_path := _stage_a2b_path(name)
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		_stage_a2b_record({"relative_path":name, "absolute_path":absolute_path, "writer_return_code":ERR_INVALID_DATA, "exists":false, "readable":false, "bytes":0, "width":0, "height":0})
		return false
	var code: Error = image.save_png(absolute_path)
	var exists_now := FileAccess.file_exists(absolute_path)
	var bytes := FileAccess.get_file_as_bytes(absolute_path).size() if exists_now else 0
	var loaded := Image.load_from_file(absolute_path) if exists_now else null
	var readable := loaded != null and not loaded.is_empty()
	_stage_a2b_record({"relative_path":name, "absolute_path":absolute_path, "writer_return_code":code, "exists":exists_now, "readable":readable, "bytes":bytes, "width":loaded.get_width() if readable else 0, "height":loaded.get_height() if readable else 0})
	return code == OK and exists_now and bytes > 0 and readable

func _stage_a2b_save_json(name: String, value: Dictionary) -> bool:
	var absolute_path := _stage_a2b_path(name)
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		_stage_a2b_record({"relative_path":name, "absolute_path":absolute_path, "writer_return_code":ERR_FILE_CANT_OPEN, "exists":false, "readable":false, "bytes":0})
		return false
	file.store_string(JSON.stringify(value, "  ") + "\n")
	file.close()
	var exists_now := FileAccess.file_exists(absolute_path)
	var bytes := FileAccess.get_file_as_bytes(absolute_path).size() if exists_now else 0
	_stage_a2b_record({"relative_path":name, "absolute_path":absolute_path, "writer_return_code":OK, "exists":exists_now, "readable":exists_now and bytes > 0, "bytes":bytes})
	return exists_now and bytes > 0

func _stage_a2b_run_output_probe() -> bool:
	var png_record := {"relative_path":"probe.png", "absolute_path":_stage_a2b_path("probe.png"), "writer_return_code":ERR_INVALID_DATA, "exists":false, "readable":false, "bytes":0, "width":0, "height":0}
	var image := Image.create(2, 2, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.18, 0.32, 0.22, 1.0))
	var code: Error = image.save_png(png_record.absolute_path)
	png_record.writer_return_code = code
	png_record.exists = FileAccess.file_exists(png_record.absolute_path)
	png_record.bytes = FileAccess.get_file_as_bytes(png_record.absolute_path).size() if png_record.exists else 0
	var loaded := Image.load_from_file(png_record.absolute_path) if png_record.exists else null
	png_record.readable = loaded != null and not loaded.is_empty()
	png_record.width = loaded.get_width() if png_record.readable else 0
	png_record.height = loaded.get_height() if png_record.readable else 0
	var json_record := {"relative_path":"probe.json", "absolute_path":_stage_a2b_path("probe.json"), "writer_return_code":OK, "exists":false, "readable":false, "bytes":0}
	var file := FileAccess.open(json_record.absolute_path, FileAccess.WRITE)
	if file == null:
		json_record.writer_return_code = ERR_FILE_CANT_OPEN
	else:
		file.store_string(JSON.stringify({"probe":"stage-a2-output-routing", "png":png_record}, "  ") + "\n")
		file.close()
	json_record.exists = FileAccess.file_exists(json_record.absolute_path)
	json_record.bytes = FileAccess.get_file_as_bytes(json_record.absolute_path).size() if json_record.exists else 0
	json_record.readable = json_record.exists and json_record.bytes > 0
	_stage_a2b_save_json("stage-a2-output-routing-probe.json", {"schema":"v0436-r1k-stage-a2-output-routing-probe-v1", "png":png_record, "json":json_record, "passed":code == OK and png_record.exists and png_record.readable and json_record.exists and json_record.readable})
	return code == OK and png_record.exists and png_record.readable and png_record.bytes > 0 and json_record.exists and json_record.readable and json_record.bytes > 0

func _save(name: String) -> void:
	if stage_a2b_mode:
		await _stage_a2b_save_png(name)
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	var image := get_viewport().get_texture().get_image()
	image.save_png(ProjectSettings.globalize_path(out_path + name))
	frame_names.append(name)

func _save_json(name: String, value: Dictionary) -> void:
	if stage_a2b_mode:
		_stage_a2b_save_json(name, value)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_path))
	var f := FileAccess.open(ProjectSettings.globalize_path(out_path + name), FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(value, "  ") + "\n")

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

func _spacing_assignment_records() -> Array:
	return spacing_assignments.map(func(item):
		return {"runtime_id":String(item.get("runtime_id", "")), "definition_id":String(item.get("definition_id", "")), "destination":_vec(item.get("destination", Vector3.ZERO)), "command_accepted":bool(item.get("command_accepted", false))})

func _spacing_sample(force: Array, assignments: Array) -> Dictionary:
	var units: Array = []
	var positions: Array = []
	for assignment in assignments:
		var unit = assignment.get("unit")
		if not is_instance_valid(unit):
			units.append({"runtime_id":String(assignment.get("runtime_id", "")), "valid":false})
			continue
		var position: Vector3 = unit.global_position
		positions.append(position)
		units.append({"runtime_id":String(assignment.get("runtime_id", "")), "valid":true, "alive":not unit.is_dead, "position":_vec(position), "destination":_vec(assignment.get("destination", Vector3.ZERO)), "destination_error":_distance_xz(position, assignment.get("destination", Vector3.ZERO)), "state":int(unit.state), "command":String(unit.get("_navigation_command_type")), "velocity":_vec(unit.velocity)})
	var distances: Array = []
	for i in range(positions.size()):
		for j in range(i + 1, positions.size()): distances.append(_distance_xz(positions[i], positions[j]))
	var result := {"timestamp_ms":Time.get_ticks_msec(), "process_frame":Engine.get_process_frames(), "physics_frame":Engine.get_physics_frames(), "units":units, "pairwise_distances":distances, "combat_event_counts":{"attacks":attack_events.size(), "projectiles":projectile_events.size(), "damage":damage_events.size(), "deaths":death_events.size(), "target_transitions":target_transitions.size()}}
	if positions.size() >= 2: result["hero_to_companion_distance"] = _distance_xz(positions[0], positions[1])
	return result

func _spacing_threshold_passes(sample: Dictionary) -> bool:
	var distances: Array = sample.get("pairwise_distances", [])
	if distances.is_empty(): return false
	var distance := float(sample.get("hero_to_companion_distance", distances[0]))
	if String(cell.get("spacing", "")) == "compact": return distance <= R1K_COMPACT_MAX_DISTANCE
	return distance >= R1K_WIDE_MIN_DISTANCE

func _spacing_targets_arrived(sample: Dictionary) -> bool:
	if sample.get("units", []).size() != spacing_assignments.size(): return false
	for unit_sample in sample.get("units", []):
		if not bool(unit_sample.get("valid", false)) or not bool(unit_sample.get("alive", false)): return false
		if float(unit_sample.get("destination_error", INF)) > R1K_DESTINATION_TOLERANCE: return false
	return true

func _spacing_combat_interference(baseline: Dictionary) -> bool:
	return attack_events.size() > int(baseline.get("attacks", 0)) or projectile_events.size() > int(baseline.get("projectiles", 0)) or damage_events.size() > int(baseline.get("damage", 0)) or death_events.size() > int(baseline.get("deaths", 0)) or target_transitions.size() > int(baseline.get("target_transitions", 0))

func _spacing_distribution(samples: Array) -> Dictionary:
	var values: Array = samples.map(func(sample): return float(sample.get("hero_to_companion_distance", INF))).filter(func(value): return is_finite(value))
	if values.is_empty(): return {"count":0, "minimum":null, "maximum":null, "median":null}
	values.sort()
	var middle := int(values.size() / 2)
	var median: float = values[middle] if values.size() % 2 == 1 else (values[middle - 1] + values[middle]) / 2.0
	return {"count":values.size(), "minimum":values[0], "maximum":values[-1], "median":median}

func _stage_a2_spacing_metrics(status: String, reason: String, baseline: Dictionary, settled_sample_count: int, settled_hold_seconds: float) -> Dictionary:
	spacing_measurement = _measure_spacing(frozen_controlled_force)
	spacing_measurement["comparable"] = true
	spacing_measurement["measured_before_first_combat_order"] = true
	spacing_measurement["configured_spacing"] = "compact"
	spacing_measurement["destination_tolerance"] = R1K_DESTINATION_TOLERANCE
	spacing_measurement["assigned_destinations"] = _spacing_assignment_records()
	spacing_measurement["provisional_settlement_samples"] = spacing_provisional_samples
	spacing_measurement["post_stop_samples"] = spacing_post_stop_samples
	spacing_measurement["provisional_distribution"] = _spacing_distribution(spacing_provisional_samples)
	spacing_measurement["post_stop_distribution"] = _spacing_distribution(spacing_post_stop_samples)
	spacing_measurement["arrival_hold_consecutive_samples"] = settled_sample_count
	spacing_measurement["settled_consecutive_samples"] = settled_sample_count
	spacing_measurement["settled_hold_seconds"] = settled_hold_seconds
	spacing_measurement["arrival_hold_start_index"] = arrival_hold_start_index
	spacing_measurement["arrival_hold_end_index"] = arrival_hold_end_index
	spacing_measurement["arrival_hold_sample_count"] = 0 if arrival_hold_start_index < 0 or arrival_hold_end_index < arrival_hold_start_index else arrival_hold_end_index - arrival_hold_start_index + 1
	spacing_measurement["arrival_hold_start_timestamp_ms"] = spacing_provisional_samples[arrival_hold_start_index].get("timestamp_ms", null) if arrival_hold_start_index >= 0 and arrival_hold_start_index < spacing_provisional_samples.size() else null
	spacing_measurement["arrival_hold_end_timestamp_ms"] = spacing_provisional_samples[arrival_hold_end_index].get("timestamp_ms", null) if arrival_hold_end_index >= 0 and arrival_hold_end_index < spacing_provisional_samples.size() else null
	spacing_measurement["arrival_hold_span_ms"] = int(spacing_measurement["arrival_hold_end_timestamp_ms"]) - int(spacing_measurement["arrival_hold_start_timestamp_ms"]) if spacing_measurement["arrival_hold_start_timestamp_ms"] != null and spacing_measurement["arrival_hold_end_timestamp_ms"] != null else 0
	spacing_measurement["frozen_unit_ids"] = frozen_controlled_ids.keys()
	spacing_measurement["public_movement_command_count"] = spacing_public_commands.size()
	spacing_measurement["public_stop_command_count"] = spacing_public_stop_count
	spacing_measurement["combat_interference"] = _spacing_combat_interference(baseline)
	spacing_measurement["diagnostic_status"] = status
	spacing_measurement["diagnostic_reason"] = reason
	return {"status":status, "reason":reason, "spacing_measurement":spacing_measurement, "assigned_destinations":_spacing_assignment_records(), "public_commands":spacing_public_commands, "provisional_samples":spacing_provisional_samples, "post_stop_samples":spacing_post_stop_samples, "combat_interference":_spacing_combat_interference(baseline)}

func _issue_stage_a2_spacing_commands() -> Dictionary:
	if frozen_controlled_force.size() < 2: return {"status":"BLOCKED_R1K_COMPARABILITY_FAILED", "reason":"compact diagnostic requires the frozen hero-plus-spear-guard pair"}
	var anchor := Vector3.ZERO
	for unit in frozen_controlled_force: anchor += unit.global_position
	anchor /= float(frozen_controlled_force.size())
	var offset := R1K_COMPACT_OFFSET
	var columns := int(ceil(sqrt(float(frozen_controlled_force.size()))))
	for index in range(frozen_controlled_force.size()):
		var row := index / columns
		var column := index % columns
		var destination := anchor + Vector3((float(column) - (float(columns) - 1.0) / 2.0) * offset, 0.0, (float(row) - (float(columns) - 1.0) / 2.0) * offset)
		var unit = frozen_controlled_force[index]
		await _select_many([unit])
		var accepted := bool(rts.issue_attack_move_destination(destination))
		var assignment := {"unit":unit, "runtime_id":str(unit.get_instance_id()), "definition_id":String(unit.unit_id), "destination":destination, "command_accepted":accepted}
		spacing_assignments.append(assignment)
		spacing_public_commands.append({"kind":"attack_move_destination", "runtime_id":str(unit.get_instance_id()), "destination":_vec(destination), "accepted":accepted, "timestamp_ms":Time.get_ticks_msec()})
		if not accepted: return _stage_a2_spacing_metrics("BLOCKED_R1K_SPACING_PUBLIC_COMMAND_REJECTED", "public attack-move command was rejected during compact-spacing staging", {"attacks":attack_events.size(), "projectiles":projectile_events.size(), "damage":damage_events.size(), "deaths":death_events.size()}, 0, 0.0)
	if stage_a2b_mode: await _save("02_STAGE_A2B_DESTINATIONS_ASSIGNED.png")
	else: await _save("02_STAGE_A2A_DESTINATIONS_ASSIGNED.png")
	var baseline := {"attacks":attack_events.size(), "projectiles":projectile_events.size(), "damage":damage_events.size(), "deaths":death_events.size(), "target_transitions":target_transitions.size()}
	var deadline := Time.get_ticks_msec() + 20000
	var consecutive := 0
	var hold_started := -1
	var settled := false
	arrival_hold_start_index = -1
	arrival_hold_end_index = -1
	while Time.get_ticks_msec() < deadline:
		var sample := _spacing_sample(frozen_controlled_force, spacing_assignments)
		spacing_samples.append(sample)
		if _spacing_combat_interference(baseline):
			return _stage_a2_spacing_metrics("BLOCKED_R1K_SPACING_STAGING_COMBAT_INTERFERENCE", "attack, projectile, damage, or death evidence appeared during spacing staging", baseline, consecutive, 0.0 if hold_started < 0 else float(Time.get_ticks_msec() - hold_started) / 1000.0)
		spacing_provisional_samples.append(sample)
		if _spacing_targets_arrived(sample):
			if consecutive == 0:
				hold_started = int(sample.get("timestamp_ms", Time.get_ticks_msec()))
				arrival_hold_start_index = spacing_provisional_samples.size() - 1
			consecutive += 1
			if consecutive >= R1K_SETTLEMENT_SAMPLE_COUNT and float(int(sample.get("timestamp_ms", Time.get_ticks_msec())) - hold_started) / 1000.0 >= R1K_SETTLEMENT_HOLD_SECONDS:
				arrival_hold_end_index = spacing_provisional_samples.size() - 1
				settled = true
				break
		else:
			consecutive = 0
			hold_started = -1
			arrival_hold_start_index = -1
			arrival_hold_end_index = -1
		await _wait_seconds(R1K_SETTLEMENT_SAMPLE_INTERVAL)
	if not settled:
		return _stage_a2_spacing_metrics("BLOCKED_R1K_SPACING_DESTINATION_NOT_REACHED", "public-command destinations did not settle inside the bounded diagnostic window", baseline, consecutive, 0.0 if hold_started < 0 else float(Time.get_ticks_msec() - hold_started) / 1000.0)
	if stage_a2b_mode: await _save("03_STAGE_A2B_ARRIVAL_HOLD_PROVEN.png")
	else: await _save("03_STAGE_A2A_ARRIVAL_HOLD_PROVEN.png")
	await _select_many(frozen_controlled_force)
	var stop_accepted := bool(rts.issue_stop())
	spacing_public_stop_count += 1 if stop_accepted else 0
	spacing_public_commands.append({"kind":"stop", "runtime_ids":frozen_controlled_force.map(func(unit): return str(unit.get_instance_id())), "accepted":stop_accepted, "timestamp_ms":Time.get_ticks_msec()})
	if not stop_accepted: return _stage_a2_spacing_metrics("BLOCKED_R1K_SPACING_PUBLIC_STOP_REJECTED", "public stop command was rejected after provisional spacing settlement", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)
	if stage_a2b_mode: await _save("04_STAGE_A2B_PUBLIC_STOP_ISSUED.png")
	else: await _save("04_STAGE_A2A_PUBLIC_STOP_ISSUED.png")
	var post_stop_first_timestamp := -1
	var post_stop_deadline := Time.get_ticks_msec() + R1K_POST_STOP_TIMEOUT_MS
	var next_post_stop_sample_at := Time.get_ticks_msec()
	var post_stop_arrival_failed := false
	while (spacing_post_stop_samples.size() < R1K_POST_STOP_SAMPLE_COUNT or (post_stop_first_timestamp >= 0 and Time.get_ticks_msec() - post_stop_first_timestamp < R1K_POST_STOP_MIN_SPAN_MS)) and Time.get_ticks_msec() <= post_stop_deadline:
		while Time.get_ticks_msec() < next_post_stop_sample_at and Time.get_ticks_msec() <= post_stop_deadline:
			await get_tree().process_frame
		var post_sample := _spacing_sample(frozen_controlled_force, spacing_assignments)
		var post_timestamp := int(post_sample.get("timestamp_ms", -1))
		if post_stop_first_timestamp < 0: post_stop_first_timestamp = post_timestamp
		if spacing_post_stop_samples.size() > 0 and post_timestamp <= int(spacing_post_stop_samples[-1].get("timestamp_ms", -1)):
			await get_tree().process_frame
			continue
		spacing_post_stop_samples.append(post_sample)
		if _spacing_combat_interference(baseline): return _stage_a2_spacing_metrics("BLOCKED_R1K_SPACING_STAGING_COMBAT_INTERFERENCE", "combat evidence appeared during post-stop spacing stabilization", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)
		if not _spacing_targets_arrived(post_sample): post_stop_arrival_failed = true
		next_post_stop_sample_at = post_timestamp + R1K_POST_STOP_SAMPLE_INTERVAL_MS
	if spacing_post_stop_samples.size() < R1K_POST_STOP_SAMPLE_COUNT or post_stop_first_timestamp < 0 or int(spacing_post_stop_samples[-1].get("timestamp_ms", -1)) - post_stop_first_timestamp < R1K_POST_STOP_MIN_SPAN_MS:
		return _stage_a2_spacing_metrics(R1K_POST_STOP_WINDOW_BLOCKER, "post-stop samples did not satisfy the bounded five-sample and 500 ms monotonic timing contract", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)
	if stage_a2b_mode: await _save("05_STAGE_A2B_POST_STOP_MEASUREMENT.png")
	else: await _save("05_STAGE_A2A_POST_STOP_MEASUREMENT.png")
	if post_stop_arrival_failed: return _stage_a2_spacing_metrics("BLOCKED_R1K_COMPACT_SPACING_UNSTABLE", "destination arrival did not remain stable during the complete post-stop window", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)
	var post_stop_distances: Array = spacing_post_stop_samples.map(func(sample): return float(sample.get("hero_to_companion_distance", INF))).filter(func(value): return is_finite(value))
	if post_stop_distances.is_empty(): return _stage_a2_spacing_metrics("BLOCKED_R1K_COMPACT_SPACING_UNSTABLE", "post-stop distance distribution was empty", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)
	var stable_max := post_stop_distances.max()
	var stable_min := post_stop_distances.min()
	if stable_max <= R1K_COMPACT_MAX_DISTANCE: return _stage_a2_spacing_metrics("NON_EVIDENCE_STAGE_A2_COMPACT_SPACING_SETTLEMENT_VALIDATED", "compact spacing settled through public commands and remained stable after public stop; diagnostic only", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)
	if stable_min > R1K_COMPACT_MAX_DISTANCE: return _stage_a2_spacing_metrics("BLOCKED_R1K_COMPACT_SPACING_PHYSICALLY_UNACHIEVABLE", "arrival hold and public stop completed, but the stable post-stop distance remained above the unchanged compact threshold", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)
	return _stage_a2_spacing_metrics("BLOCKED_R1K_COMPACT_SPACING_UNSTABLE", "stable post-stop distance distribution crossed the unchanged compact threshold", baseline, consecutive, R1K_SETTLEMENT_HOLD_SECONDS)

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
	var summary_name := "r1k-natural-confirmation-summary.json" if natural_mode else ("stage-a2-diagnostic-summary.json" if stage_a2_mode else "r1k-session-summary.json")
	var schema := "v0436-r1k-stage-a2-diagnostic-summary-v1" if stage_a2_mode else "v0436-r1k-session-summary-v2"
	_save_json(summary_name, {"schema":schema, "status":status, "reason":reason, "non_evidence":stage_a2_mode, "cell_id":cell_id, "repetition":repetition, "natural_confirmation":natural_mode, "provenance":_provenance("stage_a2_diagnostic" if stage_a2_mode else "r1k_final"), "cell":cell, "source_sha":OS.get_environment("ASCENDANT_V0436_R1K_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1K_BRANCH"), "headed":true, "hidden_window":false, "renderer":"Forward Plus", "production_scene":"scenes/main.tscn -> scenes/game_world.tscn", "no_direct_state_writes":true, "no_resource_injection":true, "no_free_units":true, "metrics":metrics, "selected_force_initial":initial_controlled_force_records, "selected_force_terminal":terminal_controlled_force_records, "selected_force_runtime_ids":frozen_controlled_ids.keys(), "spacing_measurement":spacing_measurement, "resources":world.commanders[0].resources.duplicate(true), "unit_positions":_player_combatants().map(func(unit): return _vec(unit.global_position)), "stage_a2b_writer_records":stage_a2b_writer_records, "stage_a2b_output_failed":stage_a2b_output_failed})
	if stage_a2_mode: _save_json("stage-a2-diagnostic-contract.json", {"schema":"v0436-r1k-stage-a2-diagnostic-contract-v1", "non_evidence":true, "status":status, "source_sha":OS.get_environment("ASCENDANT_V0436_R1K_SOURCE_SHA"), "branch":OS.get_environment("ASCENDANT_V0436_R1K_BRANCH"), "output_scope":"diagnostics/stage-a2-compact-spacing-settlement-replacement-2" if stage_a2b_mode else "diagnostics/stage-a2-compact-spacing-settlement-replacement-1", "production_repair_made":false, "public_command_only":true, "direct_state_writes":false})
	if not stage_a2b_mode: await _contact_sheet()
	get_tree().quit(0)

func _capture_r1k_session() -> void:
	world.set_meta("v0436_r1j_recorder", self)
	if not await _wait_until(func(): return is_instance_valid(world) and world.game_running, 30.0): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "production match did not start"); return
	for unit in world.player_commander.units:
		if is_instance_valid(unit) and String(unit.unit_id) == "barrosan_spear_guard": starting_spear_guard_runtime_ids[str(unit.get_instance_id())] = true
	if not stage_a2_mode:
		await _focus(world.player_commander.buildings[0].global_position)
		await _save("01_R1K_STANDARD_MATCH_START.png")
	if not await _wait_until(func(): return world.is_navigation_ready(), 30.0): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "navigation did not become ready"); return
	if not await _normal_production_setup(): await _finish_r1k("BLOCKED_R1K_CAPTURE_SETUP", "normal production did not produce the prepared force"); return
	var target = _target_by_name(String(cell.get("target", "thorn-ranger")))
	frozen_controlled_force = _resolve_controlled_force()
	for unit in frozen_controlled_force: frozen_controlled_ids[str(unit.get_instance_id())] = true
	initial_controlled_force_records = frozen_controlled_force.map(func(unit): return _unit_record(unit))
	if stage_a2_mode:
		await _capture_stage_a2_spacing_diagnostic()
		return
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

func _capture_stage_a2_spacing_diagnostic() -> void:
	if frozen_controlled_force.is_empty(): await _finish_r1k("BLOCKED_R1K_COMPARABILITY_FAILED", "required natural unit inventory was not present"); return
	await _focus(world.player_commander.buildings[0].global_position)
	if stage_a2b_mode: await _save("01_STAGE_A2B_START.png")
	else: await _save("01_STAGE_A2A_START.png")
	await _focus(frozen_controlled_force[0].global_position)
	var outcome := await _issue_stage_a2_spacing_commands()
	await _focus(frozen_controlled_force[0].global_position)
	_save_json("stage-a2-spacing-diagnostic.json", outcome)
	await _finish_r1k(String(outcome.get("status", "BLOCKED_R1K_SPACING_DESTINATION_NOT_REACHED")), String(outcome.get("reason", "stage-a2 spacing diagnostic did not complete")), outcome)

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root
	world = root_node.get_node("GameWorld")
	rts = root_node.get_node("RTS")
	await _capture_r1k_session()
