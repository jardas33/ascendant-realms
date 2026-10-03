extends ProgressBar
## Reliquary vital gauge: a cut well with a lit fill and fine tenth marks.
## Value handling is the stock ProgressBar; only the painting changes.

## "hp" or "mp" picks the fill pair from RqKit; anything else uses fill_color.
var kind := "hp"
var fill_color := Color(0.40, 0.78, 0.42)


func _ready() -> void:
	value_changed.connect(func(_v: float): queue_redraw())
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w < 12.0 or h < 4.0:
		return
	var top := fill_color.lightened(0.25)
	var bottom := fill_color.darkened(0.45)
	if kind == "hp":
		top = RqKit.HP_TOP
		bottom = RqKit.HP_BOTTOM
	elif kind == "mp":
		top = RqKit.MP_TOP
		bottom = RqKit.MP_BOTTOM
	var rim: Color = RqKit.mat("edge_lo")
	draw_rect(Rect2(Vector2(0, 1), size), Color(0, 0, 0, 0.55))
	draw_rect(Rect2(Vector2.ZERO, size), rim.darkened(0.25))
	var well := Rect2(1, 1, w - 2, h - 2)
	draw_rect(well, Color(0.02, 0.02, 0.022, 0.96))
	var t := clampf((value - min_value) / maxf(0.001, max_value - min_value), 0.0, 1.0)
	var fw := well.size.x * t
	if fw > 0.5:
		var fill := Rect2(well.position, Vector2(fw, well.size.y))
		draw_polygon(PackedVector2Array([fill.position, Vector2(fill.end.x, fill.position.y), fill.end, Vector2(fill.position.x, fill.end.y)]),
			PackedColorArray([top, top, bottom, bottom]))
		draw_line(fill.position + Vector2(0, 0.5), Vector2(fill.end.x, fill.position.y + 0.5), Color(1, 1, 1, 0.35), 1.0)
		draw_line(Vector2(fill.end.x - 0.5, fill.position.y), Vector2(fill.end.x - 0.5, fill.end.y), top.lightened(0.5), 1.0)
	for i in range(1, 10):
		var x := well.position.x + well.size.x * float(i) / 10.0
		draw_line(Vector2(x, well.position.y + 1), Vector2(x, well.end.y - 1), Color(0, 0, 0, 0.42 if i % 5 else 0.6), 1.0)
