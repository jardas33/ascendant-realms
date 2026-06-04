extends Node2D

const MODE := "2D_PLACEHOLDER"

var selected_ids: Array[String] = []
var last_order := "none"
var paused := false
var results_ready := false
var entities := [
	{"id": "hero_aster", "fixtureId": "free_marches", "role": "hero", "position": Vector2(340, 280), "color": Color(0.36, 0.68, 0.86)},
	{"id": "worker", "fixtureId": "worker", "role": "Worker", "position": Vector2(270, 360), "color": Color(0.72, 0.62, 0.38)},
	{"id": "militia", "fixtureId": "militia", "role": "Militia", "position": Vector2(410, 370), "color": Color(0.42, 0.76, 0.46)},
	{"id": "ranger", "fixtureId": "ranger", "role": "Ranger", "position": Vector2(480, 315), "color": Color(0.48, 0.8, 0.64)},
	{"id": "ashen_raider", "fixtureId": "raider", "role": "Ashen enemy", "position": Vector2(850, 320), "color": Color(0.9, 0.28, 0.18)}
]
var structures := [
	{"id": "command_hall", "position": Vector2(205, 215), "size": Vector2(112, 72), "color": Color(0.48, 0.45, 0.38)},
	{"id": "barracks", "position": Vector2(330, 170), "size": Vector2(86, 56), "color": Color(0.4, 0.36, 0.3)}
]
var sites := [
	{"id": "west_stone_cut", "role": "mine", "position": Vector2(650, 460), "state": "neutral"},
	{"id": "ford_toll", "role": "shrine", "position": Vector2(720, 210), "state": "neutral"}
]

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.12, 0.17, 0.14))
	draw_rect(Rect2(Vector2(0, 520), Vector2(1280, 220)), Color(0.11, 0.13, 0.17))
	draw_line(Vector2(0, 420), Vector2(1280, 190), Color(0.36, 0.31, 0.22), 26.0)
	draw_line(Vector2(610, 0), Vector2(760, 720), Color(0.12, 0.28, 0.34), 44.0)
	draw_circle(Vector2(720, 210), 48, Color(0.12, 0.42, 0.46, 0.45))
	draw_circle(Vector2(650, 460), 54, Color(0.42, 0.39, 0.31, 0.8))
	draw_line(Vector2(650, 460), Vector2(720, 210), Color(0.2, 0.84, 0.84, 0.75), 5.0)
	draw_circle(Vector2(650, 460), 14, Color(0.2, 0.84, 0.84))
	draw_circle(Vector2(720, 210), 14, Color(0.2, 0.84, 0.84))
	draw_rect(Rect2(Vector2(940, 86), Vector2(185, 118)), Color(0.06, 0.08, 0.07, 0.48))
	for structure in structures:
		draw_rect(Rect2(structure.position, structure.size), structure.color)
		draw_rect(Rect2(structure.position, structure.size), Color(0.14, 0.1, 0.08), false, 2.0)
	for entity in entities:
		var pos: Vector2 = entity.position
		draw_circle(pos, 19 if entity.role == "hero" else 14, entity.color)
		if selected_ids.has(entity.id):
			draw_circle(pos, 24, Color(1.0, 0.92, 0.45), false, 3.0)
	for site in sites:
		draw_circle(site.position, 34, Color(0.88, 0.78, 0.32, 0.22))
		draw_circle(site.position, 34, Color(0.88, 0.78, 0.32), false, 2.0)
	draw_rect(Rect2(Vector2(1020, 560), Vector2(160, 90)), Color(0.05, 0.06, 0.06, 0.75))
	draw_rect(Rect2(Vector2(1028, 568), Vector2(144, 74)), Color(0.18, 0.26, 0.22, 0.9), false, 2.0)

func select_entity(id: String) -> bool:
	for entity in entities:
		if entity.id == id or entity.fixtureId == id:
			selected_ids = [entity.id]
			queue_redraw()
			return true
	return false

func box_select_squad() -> Array[String]:
	selected_ids = ["hero_aster", "worker", "militia", "ranger"]
	queue_redraw()
	return selected_ids

func issue_move_order(target: Vector2 = Vector2(600, 360)) -> bool:
	last_order = "move:%s,%s" % [target.x, target.y]
	return selected_ids.size() > 0

func issue_attack_order(target_id: String = "ashen_raider") -> bool:
	last_order = "attack:%s" % target_id
	return selected_ids.size() > 0

func change_site_state(site_id: String = "west_stone_cut", state: String = "friendly") -> bool:
	for site in sites:
		if site.id == site_id:
			site.state = state
			return true
	return false

func trigger_hero_ability() -> bool:
	last_order = "hero-ability-placeholder:rally_banner"
	return selected_ids.has("hero_aster")

func toggle_pause() -> bool:
	paused = not paused
	return paused

func transition_results() -> bool:
	results_ready = true
	return results_ready

func get_spike_status() -> Dictionary:
	return {
		"mode": MODE,
		"ready": true,
		"entityCount": entities.size(),
		"structureCount": structures.size(),
		"siteCount": sites.size(),
		"selectedIds": selected_ids,
		"lastOrder": last_order,
		"lumeLinkRendered": true,
		"fogPlaceholderRendered": true,
		"minimapPlaceholderRendered": true,
		"paused": paused,
		"resultsReady": results_ready
	}
