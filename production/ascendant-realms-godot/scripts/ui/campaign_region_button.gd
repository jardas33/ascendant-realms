extends Button
## A campaign waypoint is a stamped route marker, rather than a disabled form
## control. The button retains its ordinary focus/pressed behavior for play.

var route_open := false
var route_cleared := false
var _hovered := false


func configure(open: bool, cleared: bool) -> void:
	route_open = open
	route_cleared = cleared
	queue_redraw()


func _ready() -> void:
	mouse_entered.connect(func():
		_hovered = true
		queue_redraw())
	mouse_exited.connect(func():
		_hovered = false
		queue_redraw())
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 60.0 or size.y < 40.0:
		return
	var w := size.x
	var h := size.y
	var shape := PackedVector2Array([
		Vector2(18, 0), Vector2(w - 16, 0), Vector2(w, 16),
		Vector2(w, h - 14), Vector2(w - 14, h), Vector2(0, h),
		Vector2(0, 18), Vector2(18, 0)])
	var shadow := PackedVector2Array()
	for point in shape:
		shadow.append(point + Vector2(0, 5))
	draw_colored_polygon(shadow, Color(0.01, 0.015, 0.022, 0.54))
	var top := Color(0.034, 0.044, 0.055, 0.96) if route_open else Color(0.037, 0.046, 0.057, 0.92)
	var bottom := Color(0.026, 0.034, 0.043, 0.91) if route_open else Color(0.030, 0.039, 0.050, 0.84)
	draw_polygon(shape, PackedColorArray([top, top, top, bottom, bottom, bottom, top, top]))
	var edge := Color(0.91, 0.72, 0.36, 0.85) if route_open else Color(0.46, 0.54, 0.59, 0.70)
	if route_cleared:
		edge = Color(0.47, 0.78, 0.57, 0.86)
	if _hovered and route_open:
		edge = edge.lightened(0.22)
	draw_polyline(shape, edge, 1.5, true)
	draw_line(Vector2(22, 4), Vector2(w - 24, 4), Color(edge.r, edge.g, edge.b, 0.44), 1.0, true)
	draw_line(Vector2(5, 27), Vector2(5, h - 17), Color(edge.r, edge.g, edge.b, 0.44), 1.4, true)
	var seal := Vector2(12, 14)
	draw_colored_polygon(PackedVector2Array([
		seal + Vector2(0, -4), seal + Vector2(4, 0),
		seal + Vector2(0, 4), seal + Vector2(-4, 0)]), edge)
