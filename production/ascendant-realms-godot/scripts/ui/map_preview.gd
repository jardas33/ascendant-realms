extends Control
class_name MapPreview
## Tactical parchment preview of a battlefield drawn from MapDefs data:
## ground, water, roads, resource sites, shrines and start positions.
## Presentation-only; it reads the map definition and changes nothing.

const KIND_COLORS := {
	"gold": Color(0.95, 0.76, 0.28),
	"stone": Color(0.72, 0.74, 0.76),
	"timber": Color(0.45, 0.62, 0.30),
	"food": Color(0.86, 0.52, 0.34),
}
const THEME_GROUND := {
	"highland": Color(0.30, 0.36, 0.22),
	"verdant": Color(0.26, 0.40, 0.20),
	"ashen": Color(0.30, 0.28, 0.26),
	"volcanic": Color(0.32, 0.20, 0.16),
	"snow": Color(0.62, 0.66, 0.70),
	"desert": Color(0.62, 0.50, 0.32),
	"autumn": Color(0.46, 0.32, 0.18),
	"wetland": Color(0.22, 0.32, 0.26),
}

var map_data := {}
var player_color := Color(0.95, 0.80, 0.40)
var opponent_colors: Array = [Color(0.85, 0.28, 0.24)]
var mystery := false


func show_map(data: Dictionary, p_color: Color, opp_colors: Array) -> void:
	map_data = data
	player_color = p_color
	opponent_colors = opp_colors
	mystery = data.is_empty()
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	var origin := (size - Vector2(side, side)) * 0.5
	var rect := Rect2(origin, Vector2(side, side))
	var frame := Color(0.78, 0.62, 0.34)
	if mystery:
		draw_rect(rect, Color(0.10, 0.09, 0.08))
		var font := get_theme_default_font()
		var text := "?"
		var fs := int(side * 0.4)
		var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
		draw_string(font, rect.get_center() + Vector2(-tw.x * 0.5, fs * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.78, 0.62, 0.34, 0.8))
		draw_rect(rect, frame, false, 2.0)
		return
	var half := float(map_data.get("size", 140.0))
	var to_px := func(p: Vector3) -> Vector2:
		return origin + Vector2((p.x + half) / (half * 2.0), (p.z + half) / (half * 2.0)) * side
	var ground: Color = THEME_GROUND.get(str(map_data.get("theme", "highland")), Color(0.3, 0.34, 0.24))
	draw_rect(rect, ground)
	# Soft vignette toward the edges so the field reads as a parchment survey.
	for i in 6:
		var inset := side * 0.02 * i
		draw_rect(Rect2(rect.position + Vector2(inset, inset), rect.size - Vector2(inset, inset) * 2.0), Color(0, 0, 0, 0.05), false, side * 0.02)
	var overview: Dictionary = map_data.get("overview", {})
	if map_data.get("water", {}).get("enabled", false) and not overview.is_empty():
		var wz := float(overview.get("water_center_z", 52.0))
		var ww := float(overview.get("water_width", 22.0))
		var water := Color(0.16, 0.34, 0.44)
		if str(overview.get("water_axis", "")) == "crossing":
			var a: Vector2 = to_px.call(Vector3(-half, 0, wz - ww * 0.5))
			var b: Vector2 = to_px.call(Vector3(half, 0, wz + ww * 0.5))
			draw_rect(Rect2(a, b - a), water)
			if map_data.has("bridge"):
				var bp: Vector2 = to_px.call(map_data["bridge"]["pos"])
				draw_rect(Rect2(bp - Vector2(side * 0.025, (b.y - a.y) * 0.6), Vector2(side * 0.05, (b.y - a.y) * 1.2)), Color(0.46, 0.34, 0.22))
		else:
			draw_circle(to_px.call(Vector3(0, 0, wz)), ww / (half * 2.0) * side * 1.4, water)
	for road in overview.get("roads", []):
		var pts := PackedVector2Array()
		for p in road:
			pts.append(to_px.call(p))
		draw_polyline(pts, Color(0.62, 0.50, 0.34, 0.85), maxf(2.0, side * 0.012), true)
	for r in map_data.get("resources", []):
		var c: Color = KIND_COLORS.get(str(r.get("kind", "")), Color.WHITE)
		draw_circle(to_px.call(r["pos"]), maxf(2.5, side * 0.011), c)
	for cp in map_data.get("capture_points", []):
		var p: Vector2 = to_px.call(cp["pos"])
		var s := side * 0.022
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)]), Color(0.70, 0.56, 0.95))
	var starts: Array = map_data.get("start_positions", [])
	for i in starts.size():
		var col: Color = player_color if i == 0 else (opponent_colors[i - 1] if i - 1 < opponent_colors.size() else Color(0.35, 0.33, 0.30))
		_draw_banner(to_px.call(starts[i]), side * 0.045, col, i == 0)
	draw_rect(rect, frame, false, 2.0)
	draw_rect(Rect2(rect.position + Vector2(5, 5), rect.size - Vector2(10, 10)), Color(frame, 0.35), false, 1.0)


func _draw_banner(p: Vector2, s: float, col: Color, is_player: bool) -> void:
	# A heater-shield marker; the player's is ringed in gold.
	var pts := PackedVector2Array([p + Vector2(-s, -s), p + Vector2(s, -s), p + Vector2(s, s * 0.2), p + Vector2(0, s * 1.2), p + Vector2(-s, s * 0.2)])
	draw_colored_polygon(pts, Color(0.05, 0.05, 0.05, 0.6))
	var inner := PackedVector2Array()
	for q in pts:
		inner.append(p + (q - p) * 0.78)
	draw_colored_polygon(inner, col)
	pts.append(pts[0])
	draw_polyline(pts, Color(1.0, 0.86, 0.50) if is_player else Color(0.12, 0.1, 0.08), 2.0 if is_player else 1.0, true)
