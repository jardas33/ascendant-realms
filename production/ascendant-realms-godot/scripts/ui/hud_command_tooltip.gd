extends PanelContainer
## A readable command annotation suspended above the shared action chassis.

const FORGED_TRIM_PATH := "res://assets/ui/hud_instruments/astra_r1/metric_bezel.png"
static var _forged_trim: Texture2D = null

var accent := Color(0.87, 0.68, 0.37)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 42.0:
		return
	if _forged_trim == null and ResourceLoader.exists(FORGED_TRIM_PATH):
		_forged_trim = load(FORGED_TRIM_PATH) as Texture2D
	var w := size.x
	var h := size.y
	var edge := PackedVector2Array([
		Vector2(0, 12), Vector2(12, 0), Vector2(w - 18, 0),
		Vector2(w, 18), Vector2(w, h - 11), Vector2(w - 11, h),
		Vector2(15, h), Vector2(0, h - 15)])
	var shadow := PackedVector2Array()
	for point in edge:
		shadow.append(point + Vector2(0, 5))
	draw_colored_polygon(shadow, Color(0.004, 0.008, 0.011, 0.55))
	draw_polygon(edge, PackedColorArray([
		Color(0.039, 0.053, 0.058, 0.98), Color(0.039, 0.053, 0.058, 0.98),
		Color(0.039, 0.053, 0.058, 0.98), Color(0.031, 0.042, 0.049, 0.98),
		Color(0.024, 0.034, 0.040, 0.99), Color(0.024, 0.034, 0.040, 0.99),
		Color(0.031, 0.042, 0.049, 0.99), Color(0.036, 0.049, 0.054, 0.99)]))
	var outline := PackedVector2Array(edge)
	outline.append(edge[0])
	draw_polyline(outline, Color(accent.r, accent.g, accent.b, 0.54), 1.2, true)
	draw_line(Vector2(16, 3), Vector2(w - 23, 3), Color(accent.r, accent.g, accent.b, 0.79), 1.5, true)
	draw_line(Vector2(3, 17), Vector2(3, h - 19), Color(accent.r, accent.g, accent.b, 0.73), 2.0, true)
	draw_line(Vector2(19, h - 4), Vector2(w - 17, h - 4), Color(0.008, 0.015, 0.019, 0.88), 2.0, true)
	draw_circle(Vector2(w - 23, 9), 2.0, accent.lightened(0.23))
	if _forged_trim:
		var tex := _forged_trim.get_size()
		var corner_w := tex.x * 0.078
		var corner_h := tex.y * 0.17
		var rail_h := tex.y * 0.10
		# Only the upper edge carries worked brass. The open lower sill keeps a
		# floating annotation quieter than the permanent command chassis.
		draw_texture_rect_region(_forged_trim,
			Rect2(18.0, 0.0, w - 39.0, 8.0),
			Rect2(tex.x * 0.10, 0.0, tex.x * 0.32, rail_h))
		draw_texture_rect_region(_forged_trim,
			Rect2(0.0, 0.0, 19.0, 19.0),
			Rect2(0.0, 0.0, corner_w, corner_h))
		draw_texture_rect_region(_forged_trim,
			Rect2(w - 20.0, 0.0, 20.0, 20.0),
			Rect2(tex.x - corner_w, 0.0, corner_w, corner_h))
