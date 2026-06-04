extends Node2D

const MODE := "2D_PLACEHOLDER"
const VIEWPORT_SIZE := Vector2(1600, 900)
const WorkloadRuntimeScript = preload("res://scripts/salto_spike_workload_runtime.gd")

var runtime = WorkloadRuntimeScript.new()
var camera_offset := Vector2.ZERO
var camera_zoom := 1.0

func _ready() -> void:
	runtime.set_workload_tier("S")
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.11, 0.16, 0.14))
	draw_set_transform(camera_offset, 0.0, Vector2(camera_zoom, camera_zoom))
	_draw_terrain()
	_draw_lume()
	_draw_structures()
	_draw_sites()
	_draw_units()
	_draw_command_markers()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_overlay_markers()

func set_workload_tier(tier: String) -> bool:
	var result: bool = runtime.set_workload_tier(tier)
	queue_redraw()
	return result

func select_entity(id: String) -> bool:
	var result: bool = runtime.select_entity(id)
	queue_redraw()
	return result

func box_select_squad() -> Array[String]:
	var result: Array[String] = runtime.box_select_squad()
	queue_redraw()
	return result

func issue_move_order(target: Vector2 = Vector2.INF) -> bool:
	var result: bool = runtime.issue_move_order(target)
	queue_redraw()
	return result

func issue_attack_order(target_id: String = "") -> bool:
	var result: bool = runtime.issue_attack_order(target_id)
	queue_redraw()
	return result

func change_site_state(site_id: String = "west_stone_cut", state: String = "friendly") -> bool:
	var result: bool = runtime.change_site_state(site_id, state)
	queue_redraw()
	return result

func trigger_hero_ability() -> bool:
	var result: bool = runtime.trigger_hero_ability()
	queue_redraw()
	return result

func focus_lume_link() -> bool:
	var result: bool = runtime.focus_lume_link()
	queue_redraw()
	return result

func pan_camera() -> bool:
	camera_offset = Vector2(-72, 34)
	queue_redraw()
	return true

func zoom_camera() -> bool:
	camera_zoom = 1.08
	queue_redraw()
	return true

func toggle_pause() -> bool:
	var result: bool = runtime.toggle_pause()
	queue_redraw()
	return result

func transition_results() -> bool:
	var result: bool = runtime.transition_results()
	queue_redraw()
	return result

func run_workload_phase(phase: String) -> Dictionary:
	var report: Dictionary = runtime.run_workload_phase(phase)
	queue_redraw()
	return report

func run_benchmark_suite() -> Dictionary:
	return runtime.run_benchmark_suite(MODE)

func get_spike_status() -> Dictionary:
	var status: Dictionary = runtime.get_status(MODE)
	status["fogPlaceholderRendered"] = true
	status["minimapPlaceholderRendered"] = true
	status["lumeLinkRendered"] = runtime.lume_links.size() > 0
	status["lumeFocused"] = runtime.lume_links.any(func(link: Dictionary) -> bool: return bool(link.get("focused", false)))
	status["cameraOffset"] = {"x": camera_offset.x, "y": camera_offset.y}
	status["cameraZoom"] = camera_zoom
	status["paused"] = runtime.paused
	return status

func _draw_terrain() -> void:
	draw_rect(Rect2(Vector2(0, 590), Vector2(1600, 310)), Color(0.10, 0.13, 0.17))
	draw_line(Vector2(0, 420), Vector2(1600, 190), Color(0.36, 0.31, 0.22), 26.0)
	draw_line(Vector2(610, 0), Vector2(760, 720), Color(0.12, 0.28, 0.34), 44.0)
	draw_circle(Vector2(720, 210), 54, Color(0.12, 0.42, 0.46, 0.42))
	draw_circle(Vector2(650, 460), 60, Color(0.42, 0.39, 0.31, 0.8))
	draw_rect(Rect2(Vector2(940, 86), Vector2(185, 118)), Color(0.06, 0.08, 0.07, 0.48))

func _draw_lume() -> void:
	for link in runtime.lume_links:
		var from_index := int(link["from"])
		var to_index := int(link["to"])
		if from_index >= runtime.lume_endpoints.size() or to_index >= runtime.lume_endpoints.size():
			continue
		var from_endpoint: Dictionary = runtime.lume_endpoints[from_index]
		var to_endpoint: Dictionary = runtime.lume_endpoints[to_index]
		var color := _lume_color(str(link["state"]), bool(link.get("focused", false)))
		draw_line(from_endpoint["position"], to_endpoint["position"], color, 9.0 if bool(link.get("focused", false)) else 5.0)
	for endpoint in runtime.lume_endpoints:
		draw_circle(endpoint["position"], 18, Color(0.2, 0.84, 0.84))
		draw_circle(endpoint["position"], 24, Color(0.2, 0.84, 0.84, 0.22), false, 2.0)

func _draw_structures() -> void:
	for structure in runtime.structures:
		var rect: Rect2 = structure["rect"]
		var team := str(structure["team"])
		var color := Color(0.48, 0.45, 0.38) if team == "friendly" else Color(0.42, 0.12, 0.10)
		if team == "neutral":
			color = Color(0.42, 0.39, 0.31)
		draw_rect(rect, color)
		draw_rect(rect, Color(0.10, 0.08, 0.07), false, 2.0)

func _draw_sites() -> void:
	for site in runtime.sites:
		var owner := str(site["owner"])
		var fill := Color(0.88, 0.78, 0.32, 0.22)
		var stroke := Color(0.88, 0.78, 0.32)
		if owner == "friendly":
			fill = Color(0.30, 0.78, 0.46, 0.30)
			stroke = Color(0.42, 0.92, 0.58)
		elif owner == "enemy":
			fill = Color(0.90, 0.22, 0.16, 0.25)
			stroke = Color(0.95, 0.28, 0.18)
		elif owner == "contested":
			fill = Color(0.84, 0.58, 0.16, 0.30)
			stroke = Color(0.95, 0.62, 0.20)
		draw_circle(site["position"], float(site["radius"]) * 0.72, fill)
		draw_circle(site["position"], float(site["radius"]) * 0.72, stroke, false, 2.0)

func _draw_units() -> void:
	for unit in runtime.units:
		var position: Vector2 = unit["position"]
		var color := _unit_color(unit)
		var radius := 20.0 if str(unit["role"]) == "hero" else 12.0
		if str(unit["role"]) == "Worker":
			radius = 10.0
		if not bool(unit["alive"]):
			draw_circle(position, radius, Color(0.08, 0.08, 0.08, 0.45))
			continue
		draw_circle(position, radius, color)
		var health_ratio: float = float(unit["health"]) / max(1.0, float(unit["maxHealth"]))
		draw_rect(Rect2(position + Vector2(-14, -24), Vector2(28 * health_ratio, 3)), Color(0.36, 0.92, 0.48))
		if runtime.selected_ids.has(str(unit["id"])):
			draw_circle(position, radius + 7, Color(1.0, 0.92, 0.45), false, 3.0)

func _draw_command_markers() -> void:
	if runtime.last_order.begins_with("move"):
		var target: Vector2 = runtime.get_tier_config()["movementTarget"]
		draw_circle(target, 32, Color(0.35, 0.75, 0.96, 0.20))
		draw_circle(target, 32, Color(0.35, 0.75, 0.96), false, 3.0)
	if runtime.last_order.begins_with("attack"):
		for unit in runtime.units:
			if str(unit["team"]) == "enemy" and bool(unit["alive"]):
				draw_circle(unit["position"], 20, Color(0.95, 0.22, 0.16), false, 3.0)
				break

func _draw_overlay_markers() -> void:
	draw_rect(Rect2(Vector2(1020, 560), Vector2(160, 90)), Color(0.05, 0.06, 0.06, 0.75))
	draw_rect(Rect2(Vector2(1028, 568), Vector2(144, 74)), Color(0.18, 0.26, 0.22, 0.9), false, 2.0)
	if runtime.paused:
		draw_rect(Rect2(Vector2(1260, 24), Vector2(170, 44)), Color(0.04, 0.05, 0.05, 0.72))
	if runtime.results_ready:
		draw_rect(Rect2(Vector2(1240, 78), Vector2(250, 58)), Color(0.10, 0.14, 0.16, 0.82))

func _unit_color(unit: Dictionary) -> Color:
	if str(unit["team"]) == "enemy":
		return Color(0.9, 0.28, 0.18)
	if str(unit["role"]) == "hero":
		return Color(0.36, 0.68, 0.86)
	if str(unit["role"]) == "Worker":
		return Color(0.72, 0.62, 0.38)
	if str(unit["fixtureId"]) == "ranger":
		return Color(0.48, 0.8, 0.64)
	return Color(0.42, 0.76, 0.46)

func _lume_color(state: String, focused: bool) -> Color:
	if state == "severed":
		return Color(0.95, 0.24, 0.20, 0.85)
	if state == "candidate":
		return Color(0.35, 0.52, 0.58, 0.70)
	if state == "restored":
		return Color(0.72, 0.96, 0.82, 0.95)
	return Color(0.2, 0.84, 0.84, 0.95 if focused else 0.75)
