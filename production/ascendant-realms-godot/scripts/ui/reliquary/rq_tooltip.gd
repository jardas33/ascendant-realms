extends PanelContainer
## Reliquary command tooltip: smoked glass with a Lume hairline on top.
## Information surfaces stay quiet; the chassis owns the ornament.

var accent := Color(0.87, 0.68, 0.37)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if r.size.x < 40.0:
		return
	draw_rect(Rect2(r.position + Vector2(0, 6), r.size), Color(0, 0, 0, 0.35))
	draw_rect(r, Color(0.045, 0.04, 0.035, 0.94))
	var grad := PackedColorArray([Color(1, 0.95, 0.85, 0.05), Color(1, 0.95, 0.85, 0.05), Color(1, 1, 1, 0.0), Color(1, 1, 1, 0.0)])
	draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, 0), Vector2(r.end.x, 60), Vector2(0, 60)]), grad)
	var edge: Color = RqKit.mat("edge_mid")
	edge.a = 0.32
	draw_rect(r.grow(-0.5), edge, false, 1.0)
	RqKit.draw_seam(self, Vector2(0, 0.5), Vector2(r.size.x, 0.5), 1.0)
