extends Node3D
## GameRoot — the top node of the battle scene (scenes/game_world.tscn).
## Wires GameWorld + RTSController + HUD + EnemyAI + Pause + Debug + Tutorial.

const GameWorldScript := preload("res://scripts/world/game_world.gd")
const RTSControllerScript := preload("res://scripts/world/rts_controller.gd")
const EnemyAIScript := preload("res://scripts/ai/enemy_ai.gd")
const HudScript := preload("res://scripts/ui/hud.gd")
const PauseMenuScript := preload("res://scripts/ui/pause_menu.gd")
const DebugOverlayScript := preload("res://scripts/ui/debug_overlay.gd")
const TutorialScript := preload("res://scripts/ui/tutorial.gd")

var world
var rts
var hud
var pause_menu
var debug_overlay
var tutorial
var ais := []

func _ready() -> void:
	# apply saved audio volumes
	var s = ProfileManager.settings()
	AudioManager.set_bus_volume("Music", float(s.get("music_vol", 0.7)))
	AudioManager.set_bus_volume("SFX", float(s.get("sfx_vol", 0.8)))
	# game speed
	Engine.time_scale = float(Match.get_config().get("game_speed", 1.0))

	# world
	world = GameWorldScript.new()
	world.name = "GameWorld"
	add_child(world)
	world.game_over.connect(_on_game_over)

	# rts controller (needs world ready — world builds commanders in its _ready)
	rts = RTSControllerScript.new()
	rts.name = "RTS"
	add_child(rts)
	rts.setup(world, 0)

	# AI for each non-human commander
	var cfg := Match.get_config()
	var opps: Array = cfg.get("opponents", [])
	for i in range(1, world.commanders.size()):
		var ai = EnemyAIScript.new()
		add_child(ai)
		var diff := "normal"
		if i - 1 < opps.size():
			diff = opps[i - 1].get("difficulty", "normal")
		ai.setup(world, world.commanders[i], diff)
		ais.append(ai)

	# HUD
	var hud_layer := CanvasLayer.new()
	hud_layer.name = "HUDLayer"
	hud_layer.layer = 2
	add_child(hud_layer)
	hud = HudScript.new()
	hud_layer.add_child(hud)
	hud.setup(world, rts)
	hud.pause_requested.connect(_toggle_pause)
	hud.return_to_menu.connect(_return_to_menu)
	hud.replay.connect(_replay)

	# Pause menu
	var pause_layer := CanvasLayer.new()
	pause_layer.name = "PauseLayer"
	pause_layer.layer = 8
	pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_layer)
	pause_menu = PauseMenuScript.new()
	pause_layer.add_child(pause_menu)
	pause_menu.setup()
	pause_menu.resume_requested.connect(_toggle_pause)
	pause_menu.quit_requested.connect(_return_to_menu)

	# Debug overlay
	var dbg_layer := CanvasLayer.new()
	dbg_layer.name = "DebugLayer"
	dbg_layer.layer = 6
	add_child(dbg_layer)
	debug_overlay = DebugOverlayScript.new()
	dbg_layer.add_child(debug_overlay)
	debug_overlay.setup(world, rts)

	# Tutorial (only in tutorial mode)
	if cfg.get("mode", "skirmish") == "tutorial":
		var tut_layer := CanvasLayer.new()
		tut_layer.name = "TutorialLayer"
		tut_layer.layer = 4
		add_child(tut_layer)
		tutorial = TutorialScript.new()
		tut_layer.add_child(tutorial)
		tutorial.setup(world, rts)
	if OS.get_environment("ASCENDANT_V0436_R1_CAPTURE") == "1":
		call_deferred("_start_v0436_r1_capture")
	elif OS.get_environment("ASCENDANT_V0435_CAPTURE") == "1":
		call_deferred("_start_v0435_capture")
	elif OS.get_environment("ASCENDANT_V0436_CAPTURE") == "1":
		call_deferred("_start_v0436_capture")
	elif OS.get_environment("ASCENDANT_V0434_CAPTURE") == "1":
		call_deferred("_start_v0434_capture")
	elif OS.get_environment("ASCENDANT_V0433_CAPTURE") == "1":
		call_deferred("_start_v0433_capture")
	elif OS.get_environment("ASCENDANT_V0432_CAPTURE") == "1":
		call_deferred("_start_v0432_capture")
	elif OS.get_environment("ASCENDANT_V0431_CAPTURE") == "1":
		call_deferred("_start_v0431_capture")

func _start_v0432_capture() -> void:
	var runner = get_node_or_null("/root/V0432Capture")
	if runner and runner.has_method("capture_gameplay"):
		runner.capture_gameplay(self)

func _start_v0433_capture() -> void:
	var runner = get_node_or_null("/root/V0433Capture")
	if runner and runner.has_method("capture_gameplay"):
		runner.capture_gameplay(self)

func _start_v0434_capture() -> void:
	var runner = get_node_or_null("/root/V0434Capture")
	if runner and runner.has_method("capture_gameplay"):
		runner.capture_gameplay(self)

func _start_v0435_capture() -> void:
	var runner = get_node_or_null("/root/V0435Capture")
	if runner and runner.has_method("capture_gameplay"):
		runner.capture_gameplay(self)

func _start_v0436_capture() -> void:
	var runner = get_node_or_null("/root/V0436Capture")
	if runner and runner.has_method("capture_gameplay"):
		runner.capture_gameplay(self)

func _start_v0436_r1_capture() -> void:
	var runner = get_node_or_null("/root/V0436R1Capture")
	if runner and runner.has_method("capture_gameplay"):
		runner.capture_gameplay(self)

func _start_v0431_capture() -> void:
	var runner = get_node_or_null("/root/V0431Capture")
	if runner and runner.has_method("capture_gameplay"):
		runner.capture_gameplay(self)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
	elif event.is_action_pressed("debug_toggle"):
		if debug_overlay:
			debug_overlay.toggle()

func _toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused = paused
	if pause_menu:
		pause_menu.set_shown(paused)

func _on_game_over(victory: bool) -> void:
	# handled visually by HUD; campaign progression here
	var cfg := Match.get_config()
	if victory and cfg.get("mode", "") == "campaign":
		ProfileManager.advance_campaign(int(cfg.get("campaign_node", 0)))

func _return_to_menu() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _replay() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
