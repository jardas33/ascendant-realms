extends PanelContainer
## Cut-corner vellum and forged-metal backing for the hero's progression.


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 70.0 or size.y < 50.0:
		return
	var w := size.x
	var h := size.y
	var cut := minf(24.0, h * 0.16)
	var shape := PackedVector2Array([
		Vector2(cut, 0), Vector2(w - cut, 0), Vector2(w, cut),
		Vector2(w, h - cut), Vector2(w - cut, h), Vector2(cut, h),
		Vector2(0, h - cut), Vector2(0, cut)])
	draw_polygon(shape, PackedColorArray([Color(0.018, 0.027, 0.039, 0.87)]))
	var gilt := Color(0.80, 0.66, 0.42, 0.72)
	draw_polyline(PackedVector2Array([Vector2(0, h - cut), Vector2(0, cut), Vector2(cut, 0), Vector2(w - cut, 0)]), gilt, 1.6, true)
	draw_line(Vector2(w - cut, 0), Vector2(w, cut), gilt.darkened(0.18), 1.2, true)
	draw_line(Vector2(cut, h), Vector2(w - cut, h), gilt.darkened(0.35), 1.0, true)
	draw_line(Vector2(33, 9), Vector2(minf(w - 33, 120), 9), Color(0.96, 0.81, 0.49, 0.56), 1.1, true)
