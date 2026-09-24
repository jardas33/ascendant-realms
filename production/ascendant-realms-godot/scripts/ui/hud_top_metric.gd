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
	var metal := Color(0.027, 0.038, 0.043)
	var silhouette := PackedVector2Array([
		Vector2(0, 0), Vector2(w - 12, 0), Vector2(w, 12),
		Vector2(w, h - 10), Vector2(w - 10, h), Vector2(0, h)])
	draw_polygon(silhouette, PackedColorArray([
		Color(metal.r, metal.g, metal.b, 0.93),
		Color(metal.r, metal.g, metal.b, 0.91),
		Color(metal.r, metal.g, metal.b, 0.77),
		Color(metal.r, metal.g, metal.b, 0.37),
		Color(metal.r, metal.g, metal.b, 0.04),
		Color(metal.r, metal.g, metal.b, 0.09)]))
	var lip := PackedVector2Array([
		Vector2(0, 0), Vector2(w - 12, 0), Vector2(w - 2, 10),
		Vector2(w - 16, 7), Vector2(0, 7)])
	draw_colored_polygon(lip, Color(0.17, 0.18, 0.17, 0.40))
	draw_line(Vector2(5, 1), Vector2(w - 17, 1), Color(accent.r, accent.g, accent.b, 0.66), 1.2, true)
	draw_line(Vector2(1, 9), Vector2(1, h - 20), Color(accent.r, accent.g, accent.b, 0.42), 1.4, true)
	draw_circle(Vector2(w - 13, 6), 1.8, Color(accent.r, accent.g, accent.b, 0.82))
	draw_line(Vector2(8, h - 12), Vector2(w - 16, h - 12), Color(accent.r, accent.g, accent.b, 0.12), 1.0, true)
