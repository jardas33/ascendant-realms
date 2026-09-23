extends Button
## Forged action tile with a cut silhouette and live hover/disabled states.

var accent := Color(0.82, 0.64, 0.36)
var is_ability := false
var is_build := false
var is_menu := false


func _ready() -> void:
	resized.connect(queue_redraw)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 32.0 or size.y < 24.0:
		return
	var lit := is_hovered() or has_focus()
	var metal := accent if not disabled else Color(0.38, 0.40, 0.40)
	if is_menu:
		var menu_shape := PackedVector2Array([
			Vector2(9, 0), Vector2(size.x - 8, 0), Vector2(size.x, 8),
			Vector2(size.x, size.y - 8), Vector2(size.x - 8, size.y),
			Vector2(8, size.y), Vector2(0, size.y - 8), Vector2(0, 9)])
		draw_colored_polygon(menu_shape, Color(0.04, 0.052, 0.058, 0.96))
		var outline := PackedVector2Array(menu_shape)
		outline.append(menu_shape[0])
		draw_polyline(outline, Color(metal.r, metal.g, metal.b, 0.72 if lit else 0.43), 1.2, true)
		return
	# The chassis owns the frame. Ordinary orders are open slots: the glyph,
	# label and hotkey do the work, while a quiet rule gives each command a lane.
	if is_ability:
		var field := PackedVector2Array([
			Vector2(0, 0), Vector2(size.x - 11, 0), Vector2(size.x, 11),
			Vector2(size.x, size.y), Vector2(0, size.y)])
		draw_colored_polygon(field, Color(0.12, 0.14, 0.14, 0.89) if not disabled else Color(0.06, 0.07, 0.07, 0.72))
	elif is_build:
		draw_rect(Rect2(0, 0, size.x, size.y), Color(0.055, 0.070, 0.075, 0.40 if not disabled else 0.22), true)
	elif lit:
		draw_rect(Rect2(0, 0, size.x, size.y), Color(metal.r, metal.g, metal.b, 0.11), true)
	if lit:
		draw_rect(Rect2(0, 5, 3, size.y - 11), Color(metal.r, metal.g, metal.b, 0.86), true)
	elif is_ability:
		draw_rect(Rect2(0, 6, 3, size.y - 12), Color(metal.r, metal.g, metal.b, 0.66), true)
	draw_line(Vector2(5, size.y - 1), Vector2(size.x - 5, size.y - 1), Color(metal.r, metal.g, metal.b, 0.31 if is_ability else 0.13), 1.0, true)
	if lit:
		draw_line(Vector2(8, 1), Vector2(size.x - 13, 1), Color(metal.r, metal.g, metal.b, 0.41), 1.0, true)
	if is_ability:
		draw_line(Vector2(size.x - 11, 1), Vector2(size.x - 1, 11), Color(metal.r, metal.g, metal.b, 0.45), 1.2, true)
