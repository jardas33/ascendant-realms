extends Node
## Current bounded public military-production proof surface.

const OUT := "res://../../artifacts/current-military-production-capture/"
var phase_file: FileAccess
var world: Node
var war_hall: Node
var queued_snapshot: Dictionary
var bank_before: Dictionary
var spawned_before := 0

func _ready() -> void:

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	phase_file = FileAccess.open(ProjectSettings.globalize_path(OUT + "phases.jsonl"), FileAccess.WRITE)
	_phase("DRIVER_ENTRY", {"task": "756", "renderer": "Forward Plus"})
	if OS.get_environment("ASCENDANT_CURRENT_MILITARY_PRODUCTION_CAPTURE") != "1":
		_finish("capture_flag_not_enabled", 0)
		return
	_phase("ARTIFACT_ROOT_READY", {"artifact_root": ProjectSettings.globalize_path(OUT)})
	get_node("/root/Match").set_config({"player_race":"barrosan", "opponents":[{"race":"vorthak", "difficulty":"normal"}], "map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":1.0})

func _phase(name: String, fields: Dictionary = {}) -> void:
	if phase_file == null: return
	var row := {"phase": name, "timestamp": Time.get_datetime_string_from_system(true)}
	row.merge(fields); phase_file.store_line(JSON.stringify(row)); phase_file.flush()

func _capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(OUT + name + ".png"))
	_phase(name, {"frame_path": ProjectSettings.globalize_path(OUT + name + ".png")})

func _finish(reason: String, code: int) -> void:
	_phase("TERMINAL", {"terminal_reason": reason, "intended_exit_code": code})
	if phase_file: phase_file.close()
	get_tree().quit(code)

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func capture_gameplay(root: Node) -> void:
	world = root.get_node_or_null("GameWorld")
	_phase("PUBLIC_BOOTSTRAP", {"root":"/root/GameRoot"})
	if world == null or world.commanders.is_empty(): await _finish("gameworld_missing", 10); return
	_phase("GAMEWORLD", {"commanders": world.commanders.size()})
	var cmd = world.commanders[0]
	var def := GameData.get_building("barrosan_war_hall").duplicate(); def["id"] = "barrosan_war_hall"
	war_hall = world._create_building(def, 0, Vector3(8, 0, 8), true)
	if war_hall == null: await _finish("war_hall_creation_failed", 11); return
	_phase("MILITARY_PRODUCER_READY", {"building_id": str(war_hall.building_id), "name": "War Hall", "built": war_hall.is_built})
	var rts := root.get_node_or_null("RTS")
	if rts: rts._clear_selection(); rts._add_to_selection(war_hall); rts.emit_signal("selection_changed", rts.selected)
	await _capture("01_WAR_HALL_SELECTED")
	bank_before = cmd.resources.duplicate(true); spawned_before = cmd.units.size()
	var result: Dictionary = war_hall.queue_unit("barrosan_clan_levy")
	_phase("CLAN_LEVY_QUEUE_COMMAND", {"result": result, "bank_before": bank_before, "bank_after": cmd.resources, "queue_size": war_hall.queue.size()})
	if not result.get("ok", false): await _finish("queue_command_rejected", 12); return
	queued_snapshot = war_hall.queue[0].duplicate(true)
	await _capture("02_CLAN_LEVY_QUEUED")
	await _wait(7.0)
	_phase("PRODUCTION_PROGRESS", {"queue": war_hall.queue.duplicate(true), "queue_snapshot": queued_snapshot, "bank": cmd.resources})
	await _capture("03_PRODUCTION_PROGRESS")
	await _wait(10.0)
	var spawned: int = cmd.units.size() - spawned_before
	_phase("PRODUCTION_COMPLETION", {"queue_empty": war_hall.queue.is_empty(), "spawned_delta": spawned, "units": cmd.units.size(), "bank_after": cmd.resources})
	if spawned < 1: await _finish("production_completion_not_observed", 13); return
	for u in cmd.units:
		if is_instance_valid(u) and String(u.unit_id) == "barrosan_clan_levy":
			_phase("CLAN_LEVY_SPAWNED", {"unit_id": str(u.unit_id), "position": u.global_position, "hp": u.hp})
			if rts: rts._clear_selection(); rts._add_to_selection(u); rts.emit_signal("selection_changed", rts.selected)
			break
	await _capture("04_CLAN_LEVY_SPAWNED_SELECTED")
	await _finish("qualified_military_production_route", 0)
