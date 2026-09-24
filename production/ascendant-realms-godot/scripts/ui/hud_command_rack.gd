extends PanelContainer
## The four field orders share one forged bed. Individual buttons keep their
## own hit areas, states and shortcuts without four competing outline boxes.

const FORGED_TRIM_PATH := "res://assets/ui/hud_instruments/astra_r1/metric_bezel.png"
static var _forged_trim: Texture2D = null

var accent := Color(0.81, 0.62, 0.35)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 60.0:
		return
	if _forged_trim == null and ResourceLoader.exists(FORGED_TRIM_PATH):
		_forged_trim = load(FORGED_TRIM_PATH) as Texture2D
	var w := size.x
	var h := size.y
	var edge := PackedVector2Array([
		Vector2(0, 13), Vector2(13, 0), Vector2(w - 16, 0),
		Vector2(w, 16), Vector2(w, h - 11), Vector2(w - 11, h),
		Vector2(11, h), Vector2(0, h - 11)])
	var shadow := PackedVector2Array()
	for point in edge:
		shadow.append(point + Vector2(0, 4))
	draw_colored_polygon(shadow, Color(0.005, 0.009, 0.012, 0.54))
	draw_colored_polygon(edge, Color(0.24, 0.25, 0.23, 0.97))
	var outline := PackedVector2Array(edge)
	outline.append(edge[0])
	draw_polyline(outline, Color(accent.r, accent.g, accent.b, 0.45), 1.2, true)
	var inset := PackedVector2Array([
		Vector2(4, 15), Vector2(15, 4), Vector2(w - 18, 4),
		Vector2(w - 4, 18), Vector2(w - 4, h - 13), Vector2(w - 13, h - 4),
		Vector2(13, h - 4), Vector2(4, h - 13)])
	draw_polygon(inset, PackedColorArray([
		Color(0.052, 0.064, 0.066, 0.97), Color(0.052, 0.064, 0.066, 0.97),
		Color(0.048, 0.062, 0.067, 0.97), Color(0.048, 0.062, 0.067, 0.96),
		Color(0.032, 0.042, 0.044, 0.98), Color(0.032, 0.042, 0.044, 0.98),
		Color(0.035, 0.043, 0.043, 0.98), Color(0.035, 0.043, 0.043, 0.98)]))
	draw_line(Vector2(16, 3), Vector2(w - 20, 3), Color(accent.r, accent.g, accent.b, 0.43), 1.2, true)
	draw_line(Vector2(15, h - 3), Vector2(w - 16, h - 3), Color(0.01, 0.015, 0.017, 0.86), 2.0, true)
	if _forged_trim:
		var tex := _forged_trim.get_size()
		var rail_w := tex.x * 0.026
		var corner_w := tex.x * 0.078
		var corner_h := tex.y * 0.17
		var rail_h := tex.y * 0.10
		# Small forged rails make one physical command well. They stop at the
		# chamfers, leaving the four button faces and shortcut labels clear.
		for segment in [
			[Rect2(14.0, 0.0, w - 30.0, 7.0), Rect2(tex.x * 0.10, 0.0, tex.x * 0.80, rail_h)],
			[Rect2(13.0, h - 7.0, w - 26.0, 7.0), Rect2(tex.x * 0.10, tex.y - rail_h, tex.x * 0.32, rail_h)],
			[Rect2(0.0, 14.0, 6.0, h - 28.0), Rect2(0.0, corner_h, rail_w, tex.y - corner_h * 2.0)],
			[Rect2(w - 6.0, 16.0, 6.0, h - 30.0), Rect2(tex.x - rail_w, corner_h, rail_w, tex.y - corner_h * 2.0)],
			[Rect2(0.0, 0.0, 17.0, 17.0), Rect2(0.0, 0.0, corner_w, corner_h)],
			[Rect2(w - 18.0, 0.0, 18.0, 18.0), Rect2(tex.x - corner_w, 0.0, corner_w, corner_h)],
			[Rect2(0.0, h - 17.0, 17.0, 17.0), Rect2(0.0, tex.y - corner_h, corner_w, corner_h)],
			[Rect2(w - 17.0, h - 17.0, 17.0, 17.0), Rect2(tex.x - corner_w, tex.y - corner_h, corner_w, corner_h)],
		]:
			draw_texture_rect_region(_forged_trim, segment[0], segment[1])
	# Cross-cut grooves visually connect the four controls as a single machine.
	draw_line(Vector2(w * 0.5, 10), Vector2(w * 0.5, h - 10), Color(0.41, 0.43, 0.38, 0.25), 1.4, true)
	draw_line(Vector2(10, h * 0.5), Vector2(w - 10, h * 0.5), Color(0.42, 0.43, 0.37, 0.22), 1.2, true)
	for pin in [Vector2(10, 13), Vector2(w - 11, 13), Vector2(11, h - 11), Vector2(w - 11, h - 11)]:
		draw_circle(pin, 2.0, Color(0.73, 0.58, 0.35, 0.46))
		draw_circle(pin, 0.9, Color(0.03, 0.04, 0.04, 0.96))
