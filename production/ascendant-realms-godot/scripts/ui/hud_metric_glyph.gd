extends Control
## Small status marks for people, labor, and military readiness. Drawn as
## vectors so they stay crisp in both compact and full-resolution HUD layouts.

var glyph_kind := "population"
var accent := Color(0.92, 0.74, 0.43)


func configure(kind: String, tint: Color) -> void:
	glyph_kind = kind
	accent = tint
	queue_redraw()


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var span := minf(size.x, size.y)
	if span < 12.0:
		return
	var origin := (size - Vector2(span, span)) * 0.5
	var scale_factor := span / 24.0
	var center := origin + Vector2(12, 12) * scale_factor
	var ink := Color(0.018, 0.028, 0.035, 0.82)
	var bright := accent.lightened(0.25)
	draw_circle(center, 10.5 * scale_factor, Color(accent.r, accent.g, accent.b, 0.11))
	draw_arc(center, 10.0 * scale_factor, 0.0, TAU, 24, Color(accent.r, accent.g, accent.b, 0.48), maxf(0.8, scale_factor), true)
	match glyph_kind:
		"opponent":
			var mark := PackedVector2Array([
				origin + Vector2(12, 4) * scale_factor,
				origin + Vector2(20, 12) * scale_factor,
				origin + Vector2(12, 20) * scale_factor,
				origin + Vector2(4, 12) * scale_factor])
			draw_colored_polygon(mark, accent)
			draw_line(origin + Vector2(12, 8) * scale_factor, origin + Vector2(12, 14) * scale_factor, ink, 2.0 * scale_factor, true)
			draw_circle(origin + Vector2(12, 17) * scale_factor, 1.2 * scale_factor, ink)
		"population":
			for mark in [Vector2(7.0, 9.0), Vector2(12.0, 7.0), Vector2(17.0, 9.0)]:
				draw_circle(origin + mark * scale_factor, 1.65 * scale_factor, ink)
				draw_circle(origin + mark * scale_factor, 1.35 * scale_factor, bright)
			draw_arc(origin + Vector2(12, 19) * scale_factor, 6.5 * scale_factor, PI * 1.12, PI * 1.88, 13, bright, 1.7 * scale_factor, true)
			draw_line(origin + Vector2(4, 18) * scale_factor, origin + Vector2(8, 15) * scale_factor, accent, 1.2 * scale_factor, true)
			draw_line(origin + Vector2(16, 15) * scale_factor, origin + Vector2(20, 18) * scale_factor, accent, 1.2 * scale_factor, true)
		"worker":
			draw_line(origin + Vector2(8, 20) * scale_factor, origin + Vector2(15, 5) * scale_factor, ink, 3.8 * scale_factor, true)
			draw_line(origin + Vector2(8, 20) * scale_factor, origin + Vector2(15, 5) * scale_factor, bright, 1.9 * scale_factor, true)
			var head := PackedVector2Array([
				origin + Vector2(5, 8) * scale_factor,
				origin + Vector2(15, 5) * scale_factor,
				origin + Vector2(21, 8) * scale_factor,
				origin + Vector2(18, 10) * scale_factor,
				origin + Vector2(14, 8) * scale_factor,
				origin + Vector2(7, 11) * scale_factor])
			draw_colored_polygon(head, bright)
			var collar := origin + Vector2(9, 17) * scale_factor
			draw_line(collar + Vector2(-2, -1) * scale_factor, collar + Vector2(2, 1) * scale_factor, accent.darkened(0.25), 1.3 * scale_factor, true)
		"army":
			for direction in [-1.0, 1.0]:
				var foot := origin + Vector2(12 + direction * 7, 19) * scale_factor
				var tip := origin + Vector2(12 - direction * 6, 5) * scale_factor
				draw_line(foot, tip, ink, 3.5 * scale_factor, true)
				draw_line(foot, tip, bright, 1.55 * scale_factor, true)
				draw_line(foot + Vector2(-2.4, -2.6) * scale_factor, foot + Vector2(2.4, -2.6) * scale_factor, accent, 1.6 * scale_factor, true)
				draw_circle(foot, 1.35 * scale_factor, accent)
