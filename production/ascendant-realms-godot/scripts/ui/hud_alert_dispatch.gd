extends PanelContainer
## A transient field report below the campaign marker. The open bottom edge
## keeps the message connected to the world instead of adding another HUD box.

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
		Vector2(w, h - 3), Vector2(11, h - 3), Vector2(0, h - 14)])
	draw_polygon(surface, PackedColorArray([
		Color(0.024, 0.035, 0.038, 0.90), Color(0.024, 0.035, 0.038, 0.88),
		Color(0.024, 0.035, 0.038, 0.80), Color(0.024, 0.035, 0.038, 0.28),
		Color(0.024, 0.035, 0.038, 0.32), Color(0.024, 0.035, 0.038, 0.73)]))
	draw_line(Vector2(8, 1), Vector2(w - 14, 1), Color(accent.r, accent.g, accent.b, 0.48), 1.0, true)
	draw_line(Vector2(2, 9), Vector2(2, h - 16), Color(accent.r, accent.g, accent.b, 0.80), 2.0, true)
	draw_colored_polygon(PackedVector2Array([
		Vector2(9, 15), Vector2(13, 19), Vector2(9, 23), Vector2(5, 19)]),
		Color(accent.r, accent.g, accent.b, 0.85))
