extends PanelContainer
## A short-lived dispatch beneath the campaign marker. Its carved edge and
## dark reading field match the permanent instruments without obscuring play.

const HUD_TOP_RIBBON := preload("res://scripts/ui/hud_top_ribbon.gd")
const HUD_SKIN := preload("res://scripts/ui/hud_forged_skin.gd")

var accent := Color(0.95, 0.83, 0.56)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 30.0:
		return
	var w := size.x
	var h := size.y
	# Plan 429: a slip of forged metal tucked under the objective banner, the
	# alert's own colour carried by the gem at its left.
	var body := PackedVector2Array([Vector2(0, -6), Vector2(w, -6), Vector2(w, h - 8), Vector2(w - 10, h), Vector2(0, h)])
	HUD_SKIN.paint(self, body, [Vector4(12, h * 0.5, 5.5, HUD_SKIN.GEM)], Rect2(),
		{"rim": 5.0, "groove": 1.5, "inlay": 0.0, "shadow": 8.0, "alpha": 0.95, "gem": accent.darkened(0.15)})
