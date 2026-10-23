extends PanelContainer
## A readable command annotation suspended above the shared action chassis.

const HUD_TOP_RIBBON := preload("res://scripts/ui/hud_top_ribbon.gd")
const HUD_SKIN := preload("res://scripts/ui/hud_forged_skin.gd")
const FORGED_TRIM_PATH := "res://assets/ui/hud_instruments/astra_r1/metric_bezel.png"
static var _forged_trim: Texture2D = null

var accent := Color(0.87, 0.68, 0.37)


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 80.0 or size.y < 42.0:
		return
	# Plan 429: forged metal like the HUD it floats over, the command's accent
	# in the gem at its upper left.
	var w := size.x
	var h := size.y
	var edge := PackedVector2Array([
		Vector2(0, 8), Vector2(8, 0), Vector2(w - 8, 0),
		Vector2(w, 8), Vector2(w, h - 8), Vector2(w - 8, h),
		Vector2(8, h), Vector2(0, h - 8)])
	HUD_SKIN.paint(self, edge, [Vector4(7, 7, 4.5, HUD_SKIN.GEM)], Rect2(),
		{"rim": 5.0, "groove": 1.5, "inlay": 0.0, "shadow": 10.0, "alpha": 0.98, "gem": accent.darkened(0.2)})
