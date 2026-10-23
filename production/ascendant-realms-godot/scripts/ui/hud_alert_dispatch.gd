extends PanelContainer
## A short-lived dispatch beneath the campaign marker. Its carved edge and
## dark reading field match the permanent instruments without obscuring play.

const HUD_TOP_RIBBON := preload("res://scripts/ui/hud_top_ribbon.gd")
const HUD_SKIN := preload("res://scripts/ui/hud_forged_skin.gd")

var accent := Color(0.95, 0.83, 0.56)


## Plan 453: what kind of news this is: "harm", "gain", "lume" or "note".
## A small engraved sign at the left says it before the words are read.
var kind := "note"
var _sign: Control = null


func _ready() -> void:
	resized.connect(queue_redraw)
	_sign = Sign.new()
	_sign.dispatch = self
	_sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sign, false, Node.INTERNAL_MODE_FRONT)
	resized.connect(func(): if is_instance_valid(_sign): _sign.queue_redraw())
	queue_redraw()


class Sign extends Control:
	var dispatch = null

	func _draw() -> void:
		if dispatch == null:
			return
		# The container lays the sign over the text area (which starts 44 px
		# in, after the padding); the sign sits in the padding left of it.
		var c := Vector2(-23.0, size.y * 0.5)
		var col: Color = dispatch.accent
		if String(dispatch.kind) == "note" and col.s < 0.25:
			col = Color(0.98, 0.82, 0.50)
		# A dark round socket with a fine rim in the alert's colour.
		# Plan 463: the rim is bronze like the slip it sits in (a white rim on
		# plain notes looked like a system icon); the alert colour is an inner
		# ring and the sign itself.
		draw_circle(c, 14.0, Color(0.02, 0.02, 0.025, 0.92))
		draw_arc(c, 13.6, 0.0, TAU, 36, Color(0, 0, 0, 0.8), 3.2, true)
		draw_arc(c, 13.4, PI * 1.05, PI * 1.95, 18, Color(0.98, 0.82, 0.52, 0.95), 1.6, true)
		draw_arc(c, 13.4, -PI * 0.05, PI * 1.05, 18, Color(0.62, 0.46, 0.26, 0.95), 1.6, true)
		draw_arc(c, 11.0, 0.0, TAU, 32, Color(col, 0.45), 1.0, true)
		match String(dispatch.kind):
			"harm":
				# Crossed blades.
				for sgn in [-1.0, 1.0]:
					var a := c + Vector2(-6.5 * sgn, -6.5)
					var b := c + Vector2(6.5 * sgn, 6.5)
					draw_line(a, b, col, 2.2, true)
					var g := c + Vector2(4.2 * sgn, 4.2)
					draw_line(g + Vector2(-2.6, 2.6) * Vector2(sgn, 1.0), g + Vector2(2.6, -2.6) * Vector2(sgn, 1.0), col.lightened(0.2), 1.6, true)
			"gain":
				# A raised banner tip: an upward chevron over a bar.
				draw_polyline(PackedVector2Array([c + Vector2(-6, 2), c + Vector2(0, -5), c + Vector2(6, 2)]), col, 2.4, true)
				draw_line(c + Vector2(-6, 6), c + Vector2(6, 6), col, 2.0, true)
			"lume":
				var d := PackedVector2Array([c + Vector2(0, -8), c + Vector2(5.5, 0), c + Vector2(0, 8), c + Vector2(-5.5, 0)])
				draw_colored_polygon(d, col)
				draw_line(c + Vector2(0, -8), c + Vector2(0, 8), col.lightened(0.45), 1.0, true)
			_:
				# A four-point star.
				var st := PackedVector2Array()
				for i in 8:
					var r := 7.5 if i % 2 == 0 else 2.6
					var ang := -PI * 0.5 + float(i) * PI / 4.0
					st.append(c + Vector2(cos(ang), sin(ang)) * r)
				draw_colored_polygon(st, col)


func _draw() -> void:
	if size.x < 80.0 or size.y < 30.0:
		return
	var w := size.x
	var h := size.y
	# Plan 429: a slip of forged metal tucked under the objective banner, the
	# alert's own colour carried by the gem at its left.
	var body := PackedVector2Array([Vector2(0, -6), Vector2(w, -6), Vector2(w, h - 8), Vector2(w - 10, h), Vector2(0, h)])
	HUD_SKIN.paint(self, body, [], Rect2(),
		{"rim": 5.0, "groove": 1.5, "inlay": 0.0, "shadow": 8.0, "alpha": 0.95, "gem": accent.darkened(0.15)})
