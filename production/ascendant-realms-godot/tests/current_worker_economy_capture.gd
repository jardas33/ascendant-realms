extends Node
## Current bounded public Worker gathering/economy proof surface.

const OUT := "res://../../artifacts/current-worker-economy-capture/"
var root_node: Node
var world: Node
var rts: Node
var worker: Node
var resource_node: Node
var phase_file: FileAccess
var bank_before: Dictionary

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	phase_file = FileAccess.open(ProjectSettings.globalize_path(OUT + "phases.jsonl"), FileAccess.WRITE)
	_phase("DRIVER_ENTRY", {"task": "754", "renderer": "Forward Plus"})
	if OS.get_environment("ASCENDANT_CURRENT_WORKER_ECONOMY_CAPTURE") != "1":
		_finish("capture_flag_not_enabled", 0)
		return
	_phase("ARTIFACT_ROOT_READY", {"artifact_root": ProjectSettings.globalize_path(OUT)})
	get_node("/root/Match").set_config({"player_race":"barrosan", "opponents":[{"race":"vorthak","difficulty":"normal"}], "map":"hollowspan", "start_resources":"standard", "victory":"conquest", "mode":"skirmish", "game_speed":1.0})

func _phase(name: String, fields: Dictionary = {}) -> void:
	if phase_file == null: return
	var row := {"phase": name, "timestamp": Time.get_datetime_string_from_system(true)}
	row.merge(fields)
	phase_file.store_line(JSON.stringify(row)); phase_file.flush()

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

func capture_gameplay(p_root: Node) -> void:
	root_node = p_root; world = root_node.get_node_or_null("GameWorld"); rts = root_node.get_node_or_null("RTS")
	_phase("PUBLIC_BOOTSTRAP", {"root":"/root/GameRoot"})
	if world == null or rts == null:
		await _finish("game_root_or_gameworld_missing", 10); return
	_phase("GAMEWORLD", {"commanders": world.commanders.size()})
	for u in world.commanders[0].units:
		if is_instance_valid(u) and u.is_worker: worker = u; break
	if worker == null: await _finish("worker_not_found", 11); return
	_phase("WORKER_FOUND", {"worker_id": str(worker.unit_id)})
	rts._clear_selection(); rts._add_to_selection(worker); rts.emit_signal("selection_changed", rts.selected)
	_phase("WORKER_SELECTED", {"worker_id": str(worker.unit_id)}); await _capture("01_WORKER_SELECTED")
	resource_node = world.find_nearest_resource(worker.global_position, "timber")
	if resource_node == null: await _finish("resource_not_found", 12); return
	bank_before = world.commanders[0].resources.duplicate(true)
	worker.command_gather(resource_node)
	_phase("GATHER_ORDER_ISSUED", {"kind": resource_node.resource_kind, "node_id": str(resource_node.get_instance_id()), "worker_state": str(worker.state)})
	await _capture("02_GATHER_ORDER_ISSUED"); await _wait(8.0)
	var snap: Dictionary = worker.get_economy_snapshot()
	_phase("GATHER_OBSERVED", {"snapshot": snap}); await _capture("03_GATHER_OBSERVED")
	await _wait(8.0)
	snap = worker.get_economy_snapshot()
	_phase("ECONOMY_PROGRESS", {"snapshot": snap, "bank": world.commanders[0].resources})
	await _capture("04_ECONOMY_PROGRESS")
	var tx: Array = world.resource_transactions
	var extraction: Array = world.resource_extractions
	_phase("LEDGER_OBSERVED", {"transactions": tx.size(), "extractions": extraction.size(), "bank_before": bank_before, "bank_after": world.commanders[0].resources})
	await _capture("05_FINAL")
	await _finish("qualified_worker_economy_route", 0)
