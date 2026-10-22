extends PanelContainer
## A short-lived dispatch beneath the campaign marker. Its carved edge and
## dark reading field match the permanent instruments without obscuring play.

const HUD_TOP_RIBBON := preload("res://scripts/ui/hud_top_ribbon.gd")

var accent := Color(0.95, 0.83, 0.56)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 30.0:
		return
	var w := size.x
	var h := size.y
	# Plan 420: a slip of the same iron as the top band, tucked under the
	# objective banner: no boxed rim, a bronze hem on top, a soft fade at the
	# right, and the alert's own colour in a gem and a rail at the left.
	var shadow := PackedVector2Array([Vector2(2, 4), Vector2(w, 4), Vector2(w, h + 4), Vector2(2, h + 4)])
	draw_polygon(shadow, PackedColorArray([Color(0, 0, 0, 0.36), Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.36)]))
	var body := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w - 10, h), Vector2(0, h)])
	var top := Color(0.085, 0.080, 0.072, 0.95)
	var low := Color(0.030, 0.033, 0.036, 0.93)
	draw_polygon(body, PackedColorArray([top, top, low, low]))
	draw_texture_rect(HUD_TOP_RIBBON.grain(), Rect2(0, 0, w, h), true, Color(1, 1, 1, 0.05))
	draw_line(Vector2(0, 1.5), Vector2(w - 1, 1.5), Color(0.62, 0.44, 0.22, 1.0), 3.0)
	draw_line(Vector2(0, 3.5), Vector2(w - 2, 3.5), Color(0.98, 0.82, 0.50, 0.45), 1.0)
	draw_line(Vector2(0, h - 1), Vector2(w - 10, h - 1), Color(0.62, 0.44, 0.22, 0.55), 1.0, true)
	draw_rect(Rect2(0, 3, 4, h - 3), Color(accent.r, accent.g, accent.b, 0.85))
	var pip := Vector2(12, h * 0.5)
	draw_colored_polygon(PackedVector2Array([
		pip + Vector2(0, -6), pip + Vector2(4.5, 0),
		pip + Vector2(0, 6), pip + Vector2(-4.5, 0)]),
		Color(accent.r, accent.g, accent.b, 0.95))
	draw_circle(pip + Vector2(-0.8, -1.8), 0.9, Color(1, 0.95, 0.85, 0.85))
