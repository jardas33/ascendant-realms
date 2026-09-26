extends PanelContainer
## A short-lived dispatch beneath the campaign marker. Its carved edge and
## dark reading field match the permanent instruments without obscuring play.

var accent := Color(0.95, 0.83, 0.56)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 30.0:
		return
	var w := size.x
	var h := size.y
	var surface := PackedVector2Array([
		Vector2(0, 0), Vector2(w - 9, 0), Vector2(w, 9),
		Vector2(w, h - 9), Vector2(w - 9, h), Vector2(11, h), Vector2(0, h - 11)])
	var shadow := PackedVector2Array()
	for point in surface:
		shadow.append(point + Vector2(0, 3))
	draw_colored_polygon(shadow, Color(0.006, 0.010, 0.012, 0.48))
	draw_polygon(surface, PackedColorArray([
		Color(0.027, 0.038, 0.041, 0.97), Color(0.027, 0.038, 0.041, 0.96),
		Color(0.023, 0.033, 0.036, 0.95), Color(0.018, 0.027, 0.030, 0.90),
		Color(0.018, 0.027, 0.030, 0.90), Color(0.019, 0.029, 0.032, 0.92),
		Color(0.023, 0.034, 0.037, 0.95)]))
	var rim := PackedVector2Array(surface)
	rim.append(surface[0])
	draw_polyline(rim, Color(accent.r, accent.g, accent.b, 0.54), 1.0, true)
	draw_line(Vector2(10, 2), Vector2(w - 15, 2), Color(accent.r, accent.g, accent.b, 0.90), 1.4, true)
	draw_line(Vector2(10, h - 2), Vector2(w - 16, h - 2), Color(accent.r, accent.g, accent.b, 0.40), 1.0, true)
	draw_line(Vector2(3, 12), Vector2(3, h - 12), Color(accent.r, accent.g, accent.b, 0.88), 2.0, true)
	draw_line(Vector2(6, 12), Vector2(6, h - 12), Color(accent.r, accent.g, accent.b, 0.18), 1.0, true)
	draw_line(Vector2(w - 3, 12), Vector2(w - 3, h - 11), Color(accent.r, accent.g, accent.b, 0.50), 1.0, true)
	# The dispatch pip is a small carved signal, not a competing action icon.
	var pip := Vector2(12, minf(22.0, h * 0.5))
	draw_colored_polygon(PackedVector2Array([
		pip + Vector2(0, -5), pip + Vector2(5, 0),
		pip + Vector2(0, 5), pip + Vector2(-5, 0)]),
		Color(accent.r, accent.g, accent.b, 0.87))
	draw_circle(pip, 1.2, Color(0.08, 0.08, 0.07, 0.90))
