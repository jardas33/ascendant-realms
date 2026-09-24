extends Control
## Action emblems used by the command deck. The field orders share one painted
## atlas so they remain visually distinct at their small gameplay size.

const EMBLEMS := {
	"barrosan_worker": "res://assets/ui/command_emblems/astra_r1/recruit_highland_worker.png",
	"advance_tier_2": "res://assets/ui/command_emblems/astra_r1/age_of_iron.png",
	"advance_tier_3": "res://assets/ui/command_emblems/astra_r1/age_of_lume.png",
	"rally": "res://assets/ui/command_emblems/astra_r1/rallying_cry.png",
}
const FIELD_ORDERS_ATLAS := "res://assets/ui/command_emblems/astra_r1/field_orders_atlas.png"
const FIELD_ORDER_QUADRANTS := {
	"attack": Vector2i(0, 0),
	"stop": Vector2i(1, 0),
	"hold": Vector2i(0, 1),
	"patrol": Vector2i(1, 1),
}

static var _emblem_cache: Dictionary = {}

var icon_kind := "command"
var accent := Color.WHITE

func configure(kind: String, tint: Color) -> void:
	icon_kind = kind
	accent = tint
	queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if FIELD_ORDER_QUADRANTS.has(icon_kind):
		var atlas: Texture2D = _load_emblem(FIELD_ORDERS_ATLAS)
		if atlas:
			var half := atlas.get_size() * 0.5
			var quadrant: Vector2i = FIELD_ORDER_QUADRANTS[icon_kind]
			var source := Rect2(Vector2(quadrant) * half + Vector2.ONE, half - Vector2(2, 2))
			draw_texture_rect_region(atlas, Rect2(Vector2.ZERO, size), source)
			return
	if EMBLEMS.has(icon_kind):
		var emblem: Texture2D = _load_emblem(EMBLEMS[icon_kind])
		if emblem:
			draw_texture_rect(emblem, Rect2(Vector2.ZERO, size), false)
			return
	var center := size * 0.5
	var dark := Color(0.02, 0.025, 0.035, 0.9)
	var line_width := maxf(2.0, size.x * 0.075)
	match icon_kind:
		"attack":
			draw_line(Vector2(7, size.y - 7), Vector2(size.x - 8, 8), accent, line_width, true)
			draw_line(Vector2(8, 8), Vector2(16, 8), accent, line_width, true)
			draw_line(Vector2(size.x - 8, 8), Vector2(size.x - 8, 16), accent, line_width, true)
			draw_circle(center, size.x * 0.33, Color(accent.r, accent.g, accent.b, 0.12))
		"stop":
			draw_rect(Rect2(8, 8, size.x - 16, size.y - 16), accent, false, line_width)
			draw_rect(Rect2(13, 13, size.x - 26, size.y - 26), Color(accent.r, accent.g, accent.b, 0.14), true)
		"hold":
			draw_circle(Vector2(center.x, 13), 5.5, accent, false, line_width)
			draw_line(Vector2(center.x, 19), Vector2(center.x, size.y - 7), accent, line_width, true)
			draw_line(Vector2(9, size.y - 8), Vector2(size.x - 9, size.y - 8), accent, line_width, true)
		"patrol":
			draw_arc(center, size.x * 0.30, -0.45, 4.9, 20, accent, line_width, true)
			draw_colored_polygon(PackedVector2Array([Vector2(size.x - 8, 8), Vector2(size.x - 9, 18), Vector2(size.x - 18, 12)]), accent)
		"build":
			draw_rect(Rect2(7, 14, size.x - 14, size.y - 10), accent, false, line_width)
			draw_line(Vector2(7, 14), Vector2(center.x, 6), accent, line_width, true)
			draw_line(Vector2(center.x, 6), Vector2(size.x - 7, 14), accent, line_width, true)
			draw_line(Vector2(center.x, 19), Vector2(center.x, size.y - 7), accent, line_width, true)
		"train":
			draw_circle(center, size.x * 0.27, accent, false, line_width)
			draw_line(Vector2(7, size.y - 8), Vector2(size.x - 7, size.y - 8), accent, line_width, true)
			draw_line(Vector2(10, size.y - 13), Vector2(size.x - 10, size.y - 13), accent, line_width, true)
		"research":
			draw_circle(center, size.x * 0.2, accent, false, line_width)
			for angle in [0.0, 1.5708, 3.1416, 4.7124]:
				var ray := Vector2(cos(angle), sin(angle))
				draw_line(center + ray * 9.0, center + ray * 14.0, accent, line_width, true)
		"ability":
			var points := PackedVector2Array([Vector2(center.x, 5), Vector2(size.x - 6, center.y), Vector2(center.x, size.y - 5), Vector2(6, center.y)])
			draw_colored_polygon(points, Color(accent.r, accent.g, accent.b, 0.20))
			draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), accent, line_width, true)
			draw_circle(center, size.x * 0.12, accent)
		_:
			draw_circle(center, size.x * 0.28, Color(accent.r, accent.g, accent.b, 0.16))
			draw_circle(center, size.x * 0.28, accent, false, line_width)
			draw_line(Vector2(8, center.y), Vector2(size.x - 8, center.y), accent, line_width, true)
			draw_line(Vector2(center.x, 8), Vector2(center.x, size.y - 8), accent, line_width, true)
	# A subtle center shadow improves contrast against pale battlefield terrain.
	if dark.a > 0.0:
		draw_circle(center, size.x * 0.07, dark)


func _load_emblem(path: String) -> Texture2D:
	if _emblem_cache.has(path):
		return _emblem_cache[path]
	var texture := load(path) as Texture2D
	if texture:
		_emblem_cache[path] = texture
	return texture
