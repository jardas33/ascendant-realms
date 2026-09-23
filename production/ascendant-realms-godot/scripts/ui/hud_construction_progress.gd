extends Control
## Blueprint scaffold and segmented build rail for a selected unfinished site.

var progress := 0.0
var accent := Color(0.44, 0.87, 0.69)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	if size.x < 180.0 or size.y < 85.0:
		return
	var w := size.x
	var h := size.y
	var edge := Color(accent.r, accent.g, accent.b, 0.48)
	var plate := PackedVector2Array([
		Vector2(0, 8), Vector2(8, 0), Vector2(w - 14, 0),
		Vector2(w, 14), Vector2(w, h - 7), Vector2(w - 7, h),
		Vector2(7, h), Vector2(0, h - 7)])
	draw_colored_polygon(plate, Color(0.043, 0.073, 0.078, 0.96))
	var rim := PackedVector2Array(plate)
	rim.append(plate[0])
	draw_polyline(rim, edge, 1.0, true)
	draw_line(Vector2(2, 12), Vector2(2, h - 11), accent, 2.0, true)
	draw_line(Vector2(10, 1), Vector2(w - 16, 1), Color(accent.r, accent.g, accent.b, 0.33), 1.0, true)
	# An unfinished structure reads as a plan being assembled, not a generic bar.
	var plan_rect := Rect2(12, 10, 86, 74)
	draw_rect(plan_rect, Color(0.08, 0.15, 0.15, 0.54), true)
	draw_rect(plan_rect, Color(accent.r, accent.g, accent.b, 0.26), false, 1.0)
	for i in 4:
		var gy := 24.0 + i * 15.0
		draw_line(Vector2(17, gy), Vector2(93, gy), Color(accent.r, accent.g, accent.b, 0.10), 1.0, true)
	for i in 4:
		var gx := 24.0 + i * 18.0
		draw_line(Vector2(gx, 14), Vector2(gx, 81), Color(accent.r, accent.g, accent.b, 0.09), 1.0, true)
	var foundation := PackedVector2Array([Vector2(27, 73), Vector2(81, 73), Vector2(76, 79), Vector2(32, 79)])
	draw_colored_polygon(foundation, Color(accent.r, accent.g, accent.b, 0.26))
	var built_height := 43.0 * progress
	for i in 4:
		var level_y := 70.0 - i * 11.0
		var line_alpha := 0.88 if progress >= float(i + 1) / 4.0 else 0.22
		draw_line(Vector2(34, level_y), Vector2(73, level_y), Color(accent.r, accent.g, accent.b, line_alpha), 2.0, true)
	draw_line(Vector2(33, 70), Vector2(33, 27), Color(accent.r, accent.g, accent.b, 0.22), 1.0, true)
	draw_line(Vector2(74, 70), Vector2(74, 27), Color(accent.r, accent.g, accent.b, 0.22), 1.0, true)
	if built_height > 0.0:
		draw_line(Vector2(33, 70), Vector2(33, 70 - built_height), accent, 2.0, true)
		draw_line(Vector2(74, 70), Vector2(74, 70 - built_height), accent, 2.0, true)
	draw_line(Vector2(28, 29), Vector2(79, 29), Color(accent.r, accent.g, accent.b, 0.46), 1.0, true)
	draw_line(Vector2(22, 47), Vector2(87, 47), Color(accent.r, accent.g, accent.b, 0.29), 1.0, true)
	# Discrete illuminated cells make progress legible even at small HUD scale.
	var rail_left := 112.0
	var rail_right := w - 14.0
	var gap := 3.0
	var count := 12
	var cell_width := (rail_right - rail_left - gap * float(count - 1)) / float(count)
	for i in count:
		var x := rail_left + i * (cell_width + gap)
		var filled := progress >= float(i + 1) / float(count)
		var cell := Rect2(x, h - 16, cell_width, 6)
		draw_rect(cell, Color(accent.r, accent.g, accent.b, 0.86) if filled else Color(accent.r, accent.g, accent.b, 0.14), true)
		draw_rect(cell, Color(accent.r, accent.g, accent.b, 0.20), false, 1.0)
	draw_line(Vector2(112, h - 4), Vector2(w - 12, h - 4), Color(accent.r, accent.g, accent.b, 0.33), 1.0, true)
