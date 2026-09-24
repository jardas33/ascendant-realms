extends PanelContainer
## A small hanging instrument for one live resource or force value. The dark
## field fades into the world instead of joining a full-width top HUD slab.

var accent := Color(0.88, 0.68, 0.35)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 32.0 or size.y < 32.0:
		return
	var w := size.x
	var h := size.y
	var metal := Color(0.025, 0.033, 0.036)
	var silhouette := PackedVector2Array([
		Vector2(7, 0), Vector2(w - 13, 0), Vector2(w, 12),
		Vector2(w, h - 9), Vector2(w - 9, h), Vector2(0, h),
		Vector2(0, 7)])
	draw_polygon(silhouette, PackedColorArray([
		Color(metal.r, metal.g, metal.b, 0.98),
		Color(metal.r, metal.g, metal.b, 0.97),
		Color(metal.r, metal.g, metal.b, 0.94),
		Color(metal.r, metal.g, metal.b, 0.90),
		Color(metal.r, metal.g, metal.b, 0.91),
		Color(metal.r, metal.g, metal.b, 0.94),
		Color(metal.r, metal.g, metal.b, 0.96)]))
	var rim := PackedVector2Array(silhouette)
	rim.append(silhouette[0])
	draw_polyline(rim, Color(accent.r, accent.g, accent.b, 0.62), 1.1, true)
	var lip := PackedVector2Array([
		Vector2(7, 0), Vector2(w - 13, 0), Vector2(w - 3, 10),
		Vector2(w - 16, 8), Vector2(2, 8)])
	draw_colored_polygon(lip, Color(0.25, 0.22, 0.16, 0.41))
	draw_line(Vector2(11, 2), Vector2(w - 19, 2), Color(1.0, 0.82, 0.47, 0.67), 1.1, true)
	draw_line(Vector2(2, 10), Vector2(2, h - 9), Color(accent.r, accent.g, accent.b, 0.52), 1.2, true)
	draw_line(Vector2(9, h - 3), Vector2(w - 11, h - 3), Color(0.79, 0.59, 0.29, 0.50), 1.2, true)
	draw_line(Vector2(10, h - 6), Vector2(w - 12, h - 6), Color(0.0, 0.0, 0.0, 0.56), 1.0, true)
	# A small forged connector at each instrument edge carries the visual
	# rhythm across the resource and army rows without masking the values.
	for corner in [Vector2(5, 6), Vector2(w - 8, 6)]:
		var boss := PackedVector2Array([
			corner + Vector2(0, -4), corner + Vector2(4, 0),
			corner + Vector2(0, 4), corner + Vector2(-4, 0)])
		draw_colored_polygon(boss, Color(0.37, 0.29, 0.18, 0.99))
		boss.append(boss[0])
		draw_polyline(boss, Color(0.95, 0.72, 0.38, 0.88), 1.0, true)
		draw_circle(corner, 1.1, Color(0.039, 0.075, 0.09))
