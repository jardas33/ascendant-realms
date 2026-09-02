extends Node
## Current bounded public research proof surface.

const OUT := "res://../../artifacts/current-research-capture/"
var phase_file: FileAccess
var world: Node
var clanhold: Node
var cmd: Node
var queued_snapshot: Dictionary

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	phase_file = FileAccess.open(ProjectSettings.globalize_path(OUT + "phases.jsonl"), FileAccess.WRITE)
	_phase("DRIVER_ENTRY", {"task": "759", "renderer": "Forward Plus"})
	if OS.get_environment("ASCENDANT_CURRENT_RESEARCH_CAPTURE") != "1":
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
	_phase("GAME_ROOT", {"root":"/root/GameRoot"})
	_phase("GAMEWORLD", {"commanders": world.commanders.size()})
	cmd = world.commanders[0]
	_phase("RESEARCH_BUILDING_ACQUISITION_STARTED", {"preferred":"barrosan_clanhold"})
	for candidate in cmd.buildings:
		if is_instance_valid(candidate) and not candidate.is_dead and bool(candidate.def.get("is_hq", false)):
			clanhold = candidate
			break
	if clanhold == null: await _finish("research_building_not_found", 11); return
	_phase("RESEARCH_BUILDING_FOUND_OR_CONSTRUCTED", {"building_id":str(clanhold.building_id), "name":"Clanhold", "built":clanhold.is_built})
	var rts := root.get_node_or_null("RTS")
	if rts: rts._clear_selection(); rts._add_to_selection(clanhold); rts.emit_signal("selection_changed", rts.selected)
	_phase("RESEARCH_BUILDING_SELECTED", {"building_id":str(clanhold.building_id)})
	var tech := GameData.get_tech("advance_tier_2")
	var before: Dictionary = cmd.resources.duplicate(true)
	_phase("RESEARCH_AVAILABLE", {"research_id":"advance_tier_2", "name":tech.get("name",""), "available":cmd.can_research("advance_tier_2"), "cost":tech.get("cost",{}), "duration":tech.get("time",0)})
	_phase("STARTING_LEDGER_CAPTURED", {"resources":before, "completed":cmd.completed_tech.has("advance_tier_2"), "active":cmd.researching.has("advance_tier_2")})
	await _capture("01_CLANHOLD_RESEARCH_AVAILABLE")
	_phase("RESEARCH_COMMAND_ISSUED", {"research_id":"advance_tier_2"})
	var result: Dictionary = clanhold.queue_tech("advance_tier_2")
	_phase("RESEARCH_COMMAND_ACCEPTED", {"result":result, "resources_after":cmd.resources, "queue_size":clanhold.queue.size()})
	if not result.get("ok", false): await _finish("research_command_rejected", 12); return
	queued_snapshot = clanhold.queue[0].duplicate(true)
	_phase("RESOURCE_DEBIT_PROVEN", {"before":before, "after":cmd.resources, "delta": {"food":int(cmd.resources.food)-int(before.food), "gold":int(cmd.resources.gold)-int(before.gold)}})
	_phase("RESEARCH_ACTIVE", {"researching":cmd.researching, "queue":clanhold.queue.duplicate(true)})
	await _capture("02_RESEARCH_ACCEPTED")
	await _wait(12.0)
	var progress_1: Dictionary = clanhold.queue[0].duplicate(true) if not clanhold.queue.is_empty() else {}
	_phase("RESEARCH_PROGRESS_OBSERVED", {"progress_1":progress_1, "queue_snapshot":queued_snapshot})
	await _capture("03_RESEARCH_PROGRESS")
	await _wait(32.0)
	_phase("RESEARCH_COMPLETED", {"queue_empty":clanhold.queue.is_empty(), "researching":cmd.researching, "completed":cmd.completed_tech.has("advance_tier_2"), "tier":cmd.tier})
	if not cmd.completed_tech.has("advance_tier_2") or not clanhold.queue.is_empty(): await _finish("research_completion_not_observed", 13); return
	_phase("COMPLETED_STATE_PROVEN", {"completed_tech":cmd.completed_tech, "tier":cmd.tier})
	_phase("POST_RESEARCH_STATE_PROVEN", {"tier":cmd.tier, "research_active":cmd.researching.has("advance_tier_2"), "effect":"Tier 2 unlocked"})
	await _capture("04_RESEARCH_COMPLETED")
	_phase("FINAL_FRAME_WRITTEN", {"frame_path":ProjectSettings.globalize_path(OUT + "04_RESEARCH_COMPLETED.png")})
	await _finish("qualified_research_route", 0)
