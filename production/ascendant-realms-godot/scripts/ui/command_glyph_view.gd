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
const LIORAEN_FIELD_ORDERS_ATLAS := "res://assets/ui/command_emblems/lioraen_r1/field_orders_atlas.png"
const VORTHAK_FIELD_ORDERS_ATLAS := "res://assets/ui/command_emblems/vorthak_r1/field_orders_atlas.png"
const LIORAEN_RALLY_EMBLEM := "res://assets/ui/command_emblems/lioraen_r1/rallying_cry.png"
const VORTHAK_RALLY_EMBLEM := "res://assets/ui/command_emblems/vorthak_r1/rallying_cry.png"
const FIELD_ORDER_QUADRANTS := {
	"attack": Vector2i(0, 0),
	"stop": Vector2i(1, 0),
	"hold": Vector2i(0, 1),
	"patrol": Vector2i(1, 1),
}

static var _emblem_cache: Dictionary = {}

## Which drawn emblem a research wears, read from what it does: every research
## row and queue slot showed the same four-rayed ring, so Weapons, Armor and
## Sharpened Tools could not be told apart at a glance.
static func research_kind(tech_id: String, tdef: Dictionary) -> String:
	if EMBLEMS.has(tech_id):
		return tech_id
	if tech_id.ends_with("_cap"):
		return "r_crown"
	var keys: Array = []
	for e in tdef.get("effects", []):
		keys.append_array((e as Dictionary).keys())
	keys.append_array((tdef.get("flags", {}) as Dictionary).keys())
	if tdef.has("stat"):
		keys.append(String(tdef["stat"]))
	var joined := " ".join(PackedStringArray(keys.map(func(k): return String(k)))) + " " + tech_id
	if "brazier" in tech_id:
		return "r_flame"
	if "gather" in joined or "carry" in joined:
		return "r_pick"
	if "building_hp" in joined or "walls" in joined or "tower" in joined:
		return "r_wall"
	if "armor" in joined:
		return "r_shield"
	if "range" in joined:
		return "r_bow"
	if "speed" in joined:
		return "r_boot"
	if "dmg" in joined or "weapons" in joined:
		return "r_sword"
	if "hp" in joined or "heal" in joined or "bloom" in joined:
		return "r_heart"
	return "r_flame"

var icon_kind := "command"
var accent := Color.WHITE
var visual_faction := "barrosan"

func configure(kind: String, tint: Color, faction: String = "barrosan") -> void:
	icon_kind = kind
	accent = tint
	visual_faction = faction
	queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if FIELD_ORDER_QUADRANTS.has(icon_kind):
		var atlas_path := FIELD_ORDERS_ATLAS
		match visual_faction:
			"lioraen": atlas_path = LIORAEN_FIELD_ORDERS_ATLAS
			"vorthak": atlas_path = VORTHAK_FIELD_ORDERS_ATLAS
		var atlas: Texture2D = _load_emblem(atlas_path)
		if atlas:
			var half := atlas.get_size() * 0.5
			var quadrant: Vector2i = FIELD_ORDER_QUADRANTS[icon_kind]
			var source := Rect2(Vector2(quadrant) * half + Vector2.ONE, half - Vector2(2, 2))
			draw_texture_rect_region(atlas, Rect2(Vector2.ZERO, size), source)
			return
	if EMBLEMS.has(icon_kind):
		var emblem_path: String = EMBLEMS[icon_kind]
		if icon_kind == "rally":
			match visual_faction:
				"lioraen": emblem_path = LIORAEN_RALLY_EMBLEM
				"vorthak": emblem_path = VORTHAK_RALLY_EMBLEM
		var emblem: Texture2D = _load_emblem(emblem_path)
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
		"r_sword", "r_shield", "r_pick", "r_wall", "r_bow", "r_boot", "r_heart", "r_crown", "r_flame":
			_draw_research(icon_kind)
			return
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


## Research emblems are drawn in unit space (0..1) so they hold at the 31 px
## queue slot and the 44 px command row alike: a dark medallion with an
## accent rim and the symbol in warm metal.
func _draw_research(kind: String) -> void:
	var s := minf(size.x, size.y)
	var o := (size - Vector2(s, s)) * 0.5
	var c := o + Vector2(s, s) * 0.5
	var P := func(x: float, y: float) -> Vector2: return o + Vector2(x, y) * s
	var metal := Color(0.98, 0.86, 0.58)
	var shade := Color(0.55, 0.40, 0.22)
	var w := maxf(1.5, s * 0.07)
	draw_circle(c, s * 0.48, Color(0.05, 0.05, 0.07, 0.92))
	draw_circle(c, s * 0.40, Color(accent.r, accent.g, accent.b, 0.16))
	draw_arc(c, s * 0.46, 0.0, TAU, 32, accent, maxf(1.0, s * 0.045), true)
	match kind:
		"r_sword":
			draw_line(P.call(0.30, 0.70), P.call(0.70, 0.28), metal, w * 1.25, true)
			draw_colored_polygon(PackedVector2Array([P.call(0.66, 0.24), P.call(0.76, 0.24), P.call(0.76, 0.34)]), metal)
			draw_line(P.call(0.24, 0.56), P.call(0.44, 0.76), shade.lightened(0.4), w, true)
			draw_line(P.call(0.30, 0.70), P.call(0.22, 0.78), shade, w * 1.2, true)
		"r_shield":
			var pts := PackedVector2Array([P.call(0.28, 0.26), P.call(0.72, 0.26), P.call(0.70, 0.52), P.call(0.50, 0.78), P.call(0.30, 0.52)])
			draw_colored_polygon(pts, Color(metal, 0.35))
			draw_polyline(pts + PackedVector2Array([pts[0]]), metal, w, true)
			draw_line(P.call(0.50, 0.30), P.call(0.50, 0.70), metal, w * 0.8, true)
		"r_pick":
			draw_line(P.call(0.32, 0.74), P.call(0.62, 0.36), shade.lightened(0.35), w * 1.1, true)
			draw_arc(P.call(0.60, 0.42), s * 0.22, -2.7, -0.2, 12, metal, w * 1.2, true)
		"r_wall":
			for row in 3:
				var y := 0.32 + row * 0.13
				var shift := 0.06 if row % 2 == 1 else 0.0
				for col in 3:
					var x := 0.27 + shift + col * 0.15
					if x + 0.13 > 0.76:
						continue
					draw_rect(Rect2(P.call(x, y), Vector2(0.13, 0.10) * s), metal, false, maxf(1.0, w * 0.6))
			draw_rect(Rect2(P.call(0.27, 0.24), Vector2(0.08, 0.07) * s), metal)
			draw_rect(Rect2(P.call(0.46, 0.24), Vector2(0.08, 0.07) * s), metal)
			draw_rect(Rect2(P.call(0.65, 0.24), Vector2(0.08, 0.07) * s), metal)
		"r_bow":
			draw_arc(P.call(0.38, 0.50), s * 0.26, -1.25, 1.25, 16, metal, w * 1.1, true)
			draw_line(P.call(0.46, 0.26), P.call(0.46, 0.74), Color(metal, 0.7), maxf(1.0, w * 0.45), true)
			draw_line(P.call(0.30, 0.50), P.call(0.76, 0.50), metal, w * 0.8, true)
			draw_colored_polygon(PackedVector2Array([P.call(0.78, 0.50), P.call(0.70, 0.45), P.call(0.70, 0.55)]), metal)
		"r_boot":
			var boot := PackedVector2Array([P.call(0.36, 0.24), P.call(0.52, 0.24), P.call(0.52, 0.56), P.call(0.74, 0.62), P.call(0.74, 0.74), P.call(0.36, 0.74)])
			draw_colored_polygon(boot, Color(metal, 0.4))
			draw_polyline(boot + PackedVector2Array([boot[0]]), metal, w * 0.8, true)
			draw_line(P.call(0.20, 0.40), P.call(0.30, 0.40), Color(metal, 0.7), w * 0.6, true)
			draw_line(P.call(0.16, 0.54), P.call(0.30, 0.54), Color(metal, 0.7), w * 0.6, true)
		"r_heart":
			draw_circle(P.call(0.40, 0.42), s * 0.12, Color(0.92, 0.36, 0.34))
			draw_circle(P.call(0.60, 0.42), s * 0.12, Color(0.92, 0.36, 0.34))
			draw_colored_polygon(PackedVector2Array([P.call(0.29, 0.47), P.call(0.71, 0.47), P.call(0.50, 0.74)]), Color(0.92, 0.36, 0.34))
			draw_circle(P.call(0.40, 0.38), s * 0.04, Color(1, 0.8, 0.75, 0.8))
		"r_crown":
			var crown := PackedVector2Array([P.call(0.26, 0.68), P.call(0.26, 0.36), P.call(0.38, 0.50), P.call(0.50, 0.28), P.call(0.62, 0.50), P.call(0.74, 0.36), P.call(0.74, 0.68)])
			draw_colored_polygon(crown, Color(metal, 0.45))
			draw_polyline(crown + PackedVector2Array([crown[0]]), metal, w * 0.8, true)
			draw_circle(P.call(0.50, 0.28), s * 0.04, metal)
		"r_flame":
			var flame := PackedVector2Array([P.call(0.50, 0.22), P.call(0.64, 0.46), P.call(0.66, 0.62), P.call(0.58, 0.74), P.call(0.42, 0.74), P.call(0.34, 0.62), P.call(0.38, 0.46)])
			draw_colored_polygon(flame, Color(1.0, 0.55, 0.20))
			draw_colored_polygon(PackedVector2Array([P.call(0.50, 0.44), P.call(0.58, 0.60), P.call(0.54, 0.72), P.call(0.46, 0.72), P.call(0.42, 0.60)]), Color(1.0, 0.88, 0.45))


func _load_emblem(path: String) -> Texture2D:
	if _emblem_cache.has(path):
		return _emblem_cache[path]
	var texture := load(path) as Texture2D
	if texture:
		_emblem_cache[path] = texture
	return texture
