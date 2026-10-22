extends PanelContainer
## A readable command annotation suspended above the shared action chassis.

const HUD_TOP_RIBBON := preload("res://scripts/ui/hud_top_ribbon.gd")
const FORGED_TRIM_PATH := "res://assets/ui/hud_instruments/astra_r1/metric_bezel.png"
static var _forged_trim: Texture2D = null

var accent := Color(0.87, 0.68, 0.37)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 42.0:
		return
	# Plan 423: the same cast iron and bronze hem as the HUD it floats over.
	var w := size.x
	var h := size.y
	var edge := PackedVector2Array([
		Vector2(0, 8), Vector2(8, 0), Vector2(w - 8, 0),
		Vector2(w, 8), Vector2(w, h - 8), Vector2(w - 8, h),
		Vector2(8, h), Vector2(0, h - 8)])
	var shadow := PackedVector2Array()
	for point in edge:
		shadow.append(point + Vector2(0, 5))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.5))
	var top := Color(0.100, 0.093, 0.084, 0.98)
	var low := Color(0.040, 0.042, 0.046, 0.98)
	draw_polygon(edge, PackedColorArray([top, top, top, top, low, low, low, low]))
	draw_texture_rect(HUD_TOP_RIBBON.grain(), Rect2(0, 0, w, h), true, Color(1, 1, 1, 0.05))
	var rim := PackedVector2Array(edge)
	rim.append(edge[0])
	draw_polyline(rim, Color(0.05, 0.035, 0.02, 0.95), 5.0, true)
	draw_polyline(rim, Color(0.64, 0.46, 0.23, 1.0), 2.6, true)
	draw_line(Vector2(9, 3.5), Vector2(w - 9, 3.5), Color(0.98, 0.82, 0.50, 0.45), 1.0, true)
	draw_rect(Rect2(3, 10, 3, h - 20), Color(accent.r, accent.g, accent.b, 0.85))
