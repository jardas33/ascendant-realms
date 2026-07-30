extends SceneTree

func _source(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	assert(f != null, "source readable: " + path)
	return f.get_as_text()

func _init() -> void:
	var world := _source("res://scripts/world/game_world.gd")
	var unit := _source("res://scripts/units/unit.gd")
	var capture := _source("res://tests/v0436_capture.gd")
	assert(world.contains("func is_navigation_ready()") and world.contains("map_get_iteration_id") and world.contains("map_get_regions"), "explicit navigation readiness contract missing")
	assert(world.contains("func navigation_target_snapshot") and world.contains("map_get_closest_point"), "active-map target projection contract missing")
	assert(world.find("_build_flat_navmesh(nav") < world.find("nav_region.navigation_mesh = nav"), "navigation polygons must exist before region assignment")
	assert(unit.contains("_navigation_target_pending") and unit.contains("navigation_target_deferred"), "initial command deferral missing")
	assert(unit.contains("NAVIGATION_REPATH_INTERVAL") and unit.contains("NAVIGATION_RETRY_BUDGET"), "bounded navigation retry policy missing")
	assert(unit.contains("navigation_terminal_failure") and unit.contains("command_preserved_during_retry"), "structured terminal failure/command preservation missing")
	assert(unit.contains("next_path_point_outside_playable_bounds") and not unit.contains("implausible_next_path_jump"), "fixed long-waypoint rejection must remain removed")
	assert(capture.contains("v0436-navigation-runtime-probe.json"), "runtime navigation probe capture missing")
	print("v0.436-R1 navigation readiness, projection, stable lifecycle, command preservation, and long-waypoint source tests passed")
	quit(0)
