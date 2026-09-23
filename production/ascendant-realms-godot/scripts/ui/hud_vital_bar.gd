extends ProgressBar
## A recessed field-instrument gauge. The filled region is value-driven; this
## replaces the flat default ProgressBar without changing any health logic.

var fill_color := Color(0.40, 0.78, 0.42)


func _ready() -> void:
	value_changed.connect(func(_new_value: float): queue_redraw())
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var width := size.x
	var height := size.y
	if width < 12.0 or height < 8.0:
		return
	var rim := PackedVector2Array([
		Vector2(4, 0), Vector2(width - 4, 0), Vector2(width, 4),
		Vector2(width - 4, height), Vector2(4, height), Vector2(0, height - 4), Vector2(0, 4)])
	draw_colored_polygon(rim, Color(0.42, 0.36, 0.27, 0.98))
	draw_rect(Rect2(3, 3, width - 6, height - 6), Color(0.035, 0.042, 0.044, 0.99), true)
	var progress := clampf((value - min_value) / maxf(0.001, max_value - min_value), 0.0, 1.0)
	var fill_width := maxf(0.0, (width - 8.0) * progress)
	if fill_width > 1.0:
		draw_rect(Rect2(4, 4, fill_width, height - 8), fill_color.darkened(0.30), true)
		draw_rect(Rect2(4, 4, fill_width, maxf(2.0, (height - 8.0) * 0.45)), fill_color.lightened(0.13), true)
		draw_line(Vector2(4 + fill_width, 3), Vector2(4 + fill_width, height - 3), fill_color.lightened(0.34), 1.3, true)
	for segment in [0.25, 0.5, 0.75]:
		var tick_x: float = 4.0 + (width - 8.0) * float(segment)
		draw_line(Vector2(tick_x, 4), Vector2(tick_x, height - 4), Color(0.015, 0.025, 0.024, 0.46), 1.0, true)
	draw_line(Vector2(5, 2), Vector2(width - 5, 2), Color(0.94, 0.84, 0.61, 0.31), 1.0, true)
