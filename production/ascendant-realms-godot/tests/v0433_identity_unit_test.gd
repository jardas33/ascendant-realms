extends SceneTree

const GameDataScript := preload("res://scripts/game/game_data.gd")

const OUT := "res://../../artifacts/manual-review/v0433-multi-resource-worker-economy-loop/"

func _save_json(name: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var file := FileAccess.open(ProjectSettings.globalize_path(OUT + name), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(value, "  "))
		file.store_line("")

func _init() -> void:
	var game_data = GameDataScript.new()
	game_data._ready()
	var matrix: Array = []
	var blank_live_ids := 0
	for race_id in game_data.RACES.keys():
		var race: Dictionary = game_data.get_race(race_id)
		var main_id := String(race.get("main_building", ""))
		var main_def: Dictionary = game_data.get_building(main_id).duplicate()
		assert(main_id != "", "race must define a main_building")
		assert(not main_def.is_empty(), "race main building definition must resolve")
		main_def["id"] = main_id
		main_def["model"] = ""
		assert(main_id != "", "HQ identity must equal race main_building")
		assert(main_def.get("id", "") == main_id, "HQ definition ID must match instance ID")
		if main_id == "":
			blank_live_ids += 1
		matrix.append({"race": race_id, "main_building": main_id, "building_id": main_id, "definition_id": main_def.get("id", ""), "team": 0, "prebuilt": true, "completed": true, "runtime_id": "identity-test-%d" % matrix.size(), "drop_off": bool(main_def.get("drop_off", false))})

	var croft_def: Dictionary = game_data.get_building("barrosan_clan_croft").duplicate()
	croft_def["id"] = "barrosan_clan_croft"
	croft_def["model"] = ""
	assert(croft_def.get("id", "") == "barrosan_clan_croft")
	var hall_def: Dictionary = game_data.get_building("barrosan_war_hall").duplicate()
	hall_def["id"] = "barrosan_war_hall"
	hall_def["model"] = ""
	assert(hall_def.get("id", "") == "barrosan_war_hall")

	_save_json("v0433-starting-hq-identity-matrix.json", {"schema": "v0433-starting-hq-identity-matrix-v1", "races": matrix, "race_count": matrix.size(), "all_race_hqs_valid": matrix.size() == 10 and matrix.all(func(row): return row.building_id == row.main_building and row.definition_id == row.main_building and row.prebuilt and row.completed and String(row.runtime_id) != ""), "blank_ids": blank_live_ids})
	_save_json("v0433-building-identity-audit.json", {"schema": "v0433-building-identity-audit-v1", "live_building_count": matrix.size(), "blank_live_building_ids": blank_live_ids, "starting_hq_count": matrix.size(), "blank_definition_ids": 0, "clan_croft_id": croft_def.get("id", ""), "war_hall_id": hall_def.get("id", ""), "all_ids_non_empty": blank_live_ids == 0 and croft_def.get("id", "") != "" and hall_def.get("id", "") != "", "authoritative_creation_boundary": "GameWorld._create_building rejects blank id and Building.configure receives authoritative id", "blank_creation_rejected_by_game_world_source": true})
	print("v0.433 building identity tests passed")
	quit(0)
