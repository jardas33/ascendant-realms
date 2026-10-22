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
	# Plan 421: a recessed well cut into the chassis iron, rimmed in bronze,
	# no stretched trim texture.
	draw_polygon(edge, PackedColorArray([
		Color(0.030, 0.032, 0.034, 0.97), Color(0.030, 0.032, 0.034, 0.97),
		Color(0.030, 0.032, 0.034, 0.97), Color(0.024, 0.026, 0.028, 0.97),
		Color(0.020, 0.022, 0.024, 0.98), Color(0.020, 0.022, 0.024, 0.98),
		Color(0.020, 0.022, 0.024, 0.98), Color(0.024, 0.026, 0.028, 0.97)]))
	var outline := PackedVector2Array(edge)
	outline.append(edge[0])
	draw_polyline(outline, Color(0, 0, 0, 0.7), 3.0, true)
	draw_polyline(outline, Color(0.62, 0.44, 0.22, 0.75), 1.4, true)
	draw_line(Vector2(15, h - 2), Vector2(w - 15, h - 2), Color(0.98, 0.82, 0.50, 0.22), 1.0, true)
	# One recessed cross-joint defines four controls. The dark cut provides
	# separation while its hairline catches light without becoming four frames.
	draw_line(Vector2(w * 0.5, 11), Vector2(w * 0.5, h - 11), Color(0.008, 0.015, 0.017, 0.83), 3.0, true)
	draw_line(Vector2(w * 0.5 - 1.0, 12), Vector2(w * 0.5 - 1.0, h - 12), Color(accent.r, accent.g, accent.b, 0.25), 1.0, true)
	draw_line(Vector2(11, h * 0.5), Vector2(w - 11, h * 0.5), Color(0.008, 0.015, 0.017, 0.83), 3.0, true)
	draw_line(Vector2(12, h * 0.5 - 1.0), Vector2(w - 12, h * 0.5 - 1.0), Color(accent.r, accent.g, accent.b, 0.23), 1.0, true)
	draw_circle(Vector2(w * 0.5, h * 0.5), 3.1, Color(0.025, 0.029, 0.027, 0.94))
	draw_circle(Vector2(w * 0.5, h * 0.5), 1.4, Color(accent.r, accent.g, accent.b, 0.48))
	for pin in [Vector2(10, 13), Vector2(w - 11, 13), Vector2(11, h - 11), Vector2(w - 11, h - 11)]:
		draw_circle(pin, 2.0, Color(0.73, 0.58, 0.35, 0.46))
		draw_circle(pin, 0.9, Color(0.03, 0.04, 0.04, 0.96))
