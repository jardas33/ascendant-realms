extends PanelContainer
## A fading, cut-metal dossier backing for the skirmish briefing. The content
## remains regular Labels, while the silhouette avoids a large menu rectangle.


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 80.0:
		return
	var w := size.x
	var h := size.y
	var shape := PackedVector2Array([
		Vector2(0, 0), Vector2(w - 25, 0), Vector2(w, 25),
		Vector2(w, h - 32), Vector2(w - 32, h), Vector2(0, h)])
	draw_polygon(shape, PackedColorArray([
		Color(0.018, 0.027, 0.038, 0.81),
		Color(0.018, 0.027, 0.038, 0.81),
		Color(0.018, 0.027, 0.038, 0.69),
		Color(0.018, 0.027, 0.038, 0.35),
		Color(0.018, 0.027, 0.038, 0.22),
		Color(0.018, 0.027, 0.038, 0.42)]))
	draw_line(Vector2(0, 0), Vector2(w - 25, 0), Color(0.83, 0.68, 0.40, 0.58), 1.5, true)
	draw_line(Vector2(0, 0), Vector2(0, h - 26), Color(0.83, 0.68, 0.40, 0.72), 2.3, true)
	draw_line(Vector2(0, h - 26), Vector2(22, h), Color(0.83, 0.68, 0.40, 0.30), 1.1, true)
