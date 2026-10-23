extends ProgressBar
## A recessed field-instrument gauge. The filled region is value-driven; this
## replaces the flat default ProgressBar without changing any health logic.
## Plan 426: the gauge sits in a forged bronze trough (hud_forged.gdshader,
## through a backing child) and can carry its reading inside the bar.

const HUD_SKIN := preload("res://scripts/ui/hud_forged_skin.gd")

var fill_color := Color(0.40, 0.78, 0.42)
## Text drawn centred inside the gauge ("2200 / 2200"); empty for none.
var caption := "":
	set(value):
		if caption != value:
			caption = value
			queue_redraw()

var _backing: Control = null


func _ready() -> void:
	value_changed.connect(func(_new_value: float): queue_redraw())
	resized.connect(_reshape)
	_backing = HUD_SKIN.Backing.new()
	_backing.name = "ForgedTrough"
	add_child(_backing)
	_reshape()


func _reshape() -> void:
	if is_instance_valid(_backing):
		var w := size.x
		var h := size.y
		# Plan 438: a slim gauge (unit cards, 10 px) keeps a thin lip and no
		# painted rail: at 8 px the rail's gem corners drew as broken spikes and
		# the 4 px lip left no room for the fill.
		var lip := _lip()
		var c := 2.0 if lip < 4.0 else 4.0
		var pts := PackedVector2Array([Vector2(c, 0), Vector2(w - c, 0), Vector2(w, c), Vector2(w, h - c),
			Vector2(w - c, h), Vector2(c, h), Vector2(0, h - c), Vector2(0, c)])
		_backing.window = Rect2(lip, lip, w - lip * 2.0, h - lip * 2.0)
		_backing.set_shape(pts, [], {"rim": lip, "groove": 0.0, "inlay": 0.0, "shadow": 3.0 if lip >= 4.0 else 1.5,
			"painted": lip >= 4.0})
	queue_redraw()


func _draw() -> void:
	var width := size.x
	var height := size.y
	if width < 12.0 or height < 6.0:
		return
	var lip := _lip()
	var inner := Rect2(lip, lip, width - lip * 2.0, height - lip * 2.0)
	draw_rect(inner, Color(0.025, 0.028, 0.030, 0.96), true)
	# Plan 463: the empty part of a gauge keeps a dim trace of its colour, so
	# an empty bar (no experience yet) reads as a gauge, not a black slot.
	draw_rect(inner, Color(fill_color.r * 0.22, fill_color.g * 0.22, fill_color.b * 0.22, 0.85), true)
	var progress := clampf((value - min_value) / maxf(0.001, max_value - min_value), 0.0, 1.0)
	var fill_width := maxf(0.0, inner.size.x * progress)
	if fill_width > 1.0:
		var fr := Rect2(inner.position, Vector2(fill_width, inner.size.y))
		var top := fill_color.lightened(0.22)
		var low := fill_color.darkened(0.42)
		draw_polygon(PackedVector2Array([fr.position, Vector2(fr.end.x, fr.position.y), fr.end, Vector2(fr.position.x, fr.end.y)]),
			PackedColorArray([top, top, low, low]))
		draw_rect(Rect2(fr.position + Vector2(0, 1), Vector2(fill_width, maxf(1.0, inner.size.y * 0.28))), Color(1, 1, 1, 0.16), true)
		draw_line(Vector2(fr.end.x, inner.position.y), Vector2(fr.end.x, inner.end.y), fill_color.lightened(0.5), 1.4, true)
	for segment in [0.25, 0.5, 0.75]:
		var tick_x: float = inner.position.x + inner.size.x * float(segment)
		draw_line(Vector2(tick_x, inner.position.y), Vector2(tick_x, inner.end.y), Color(0.0, 0.0, 0.0, 0.40), 1.0, true)
	# Inner shade so the fill sits below the bronze lip.
	draw_rect(Rect2(inner.position, Vector2(inner.size.x, minf(2.0, inner.size.y * 0.3))), Color(0, 0, 0, 0.45), true)
	if not caption.is_empty():
		var font := ThemeDB.fallback_font
		var fs := clampi(int(inner.size.y) + 1, 11, 15)
		var tw := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var pos := Vector2((width - tw) * 0.5, inner.position.y + (inner.size.y + fs * 0.72) * 0.5)
		draw_string_outline(font, pos, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 3, Color(0, 0, 0, 0.85))
		draw_string(font, pos, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.97, 0.95, 0.88))


## Bronze lip width: 4 px on full gauges, 2 px on slim ones.
func _lip() -> float:
	return 2.0 if size.y < 14.0 else 4.0
