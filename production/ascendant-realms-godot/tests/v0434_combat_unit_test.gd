extends SceneTree

const GameDataScript := preload("res://scripts/game/game_data.gd")

func _source(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "source must be readable: " + path)
	return file.get_as_text()

func _init() -> void:
	var unit := _source("res://scripts/units/unit.gd")
	var projectile := _source("res://scripts/units/projectile.gd")
	var world := _source("res://scripts/world/game_world.gd")
	var controller := _source("res://scripts/world/rts_controller.gd")
	assert(unit.contains("func _can_attack_target(tgt)"), "public attack target validation missing")
	assert(unit.contains("tgt == self") and unit.contains("int(tgt.team) == team") and unit.contains("tgt.is_dead"), "friendly/self/dead rejection missing")
	assert(unit.contains("var _attack_move_ordered := false") and unit.contains("_attack_move_destination"), "attack-move state missing")
	assert(unit.contains("distance_to(tgt.global_position) <= _engage_range() + 0.15"), "delayed melee range recheck missing")
	assert(unit.contains("_last_damage_source_team") and unit.contains("_last_damage_type"), "damage source audit state missing")
	assert(unit.contains("func _build_health_bar()") and unit.contains("CombatHealthBar"), "reusable health presentation missing")
	assert(projectile.contains("source_team") and projectile.contains("source_unit_id") and projectile.contains("projectile_kind"), "projectile source provenance missing")
	assert(world.contains("source_payload") and world.contains("combat_kill_events") and world.contains("source_team == player_team"), "world attribution and kill credit missing")
	assert(controller.contains("func issue_attack_target(target)") and controller.contains("func issue_attack_move_destination(destination: Vector3)") and controller.contains("func issue_stop()"), "public RTS combat commands missing")
	var data = GameDataScript.new()
	data._ready()
	assert(is_equal_approx(data.compute_damage(16.0, "pierce", "light", 0.0), 20.8), "damage table must remain authoritative")
	assert(data.compute_damage(0.0, "pierce", "light", 0.0) >= 1.0, "damage must remain bounded positive")
	print("v0.434 focused combat targeting, attack-move, projectile provenance, health presentation and damage tests passed")
	quit(0)
