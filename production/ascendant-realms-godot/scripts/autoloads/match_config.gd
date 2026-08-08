extends Node
## Match — carries the chosen match settings from menu into game_world,
## and the result back out. Set before scene change; read in game_world._ready.

var config := {}
var last_result := {}

func clear_result() -> void:
	last_result = {}

func default_config() -> Dictionary:
	return {
		"player_race": "barrosan",
		"opponents": [{"race": "vorthak", "difficulty": "normal"}],
		"map": "hollowspan",
		"start_resources": "standard",   # standard | quick | rich
		"victory": "conquest",           # conquest | domination
		"mode": "skirmish",              # skirmish | campaign | tutorial
		"campaign_node": 0,
		"game_speed": 1.0,
	}

func set_config(cfg: Dictionary) -> void:
	config = cfg

func get_config() -> Dictionary:
	if config.is_empty():
		return default_config()
	return config

func get_identity_snapshot() -> Dictionary:
	var cfg := get_config()
	var opponents: Array = []
	for opponent in cfg.get("opponents", []):
		opponents.append({"race": str(opponent.get("race", "")), "difficulty": str(opponent.get("difficulty", "normal"))})
	return {
		"player_race": str(cfg.get("player_race", "barrosan")),
		"opponents": opponents,
		"map": str(cfg.get("map", "hollowspan")),
		"start_resources": str(cfg.get("start_resources", "standard")),
		"victory": str(cfg.get("victory", "conquest")),
		"mode": str(cfg.get("mode", "skirmish")),
		"game_speed": float(cfg.get("game_speed", 1.0)),
	}

func starting_bank(kind: String) -> Dictionary:
	match kind:
		"quick":
			return {"food": 300, "timber": 400, "stone": 250, "gold": 250}
		"rich":
			return {"food": 800, "timber": 900, "stone": 600, "gold": 600}
		_:
			return {"food": 200, "timber": 300, "stone": 180, "gold": 180}
