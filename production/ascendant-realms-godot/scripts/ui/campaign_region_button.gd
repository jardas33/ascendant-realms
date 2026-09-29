extends Button
## A campaign waypoint: a round seal medallion stamped with the chapter
## number, hanging over a parchment ribbon that carries the chapter's name.
## Open chapters glow gold and breathe, won chapters wear a green laurel
## (a gold one when won on Heroic), sealed ones are dark iron with a chain.
## Side roads use a smaller violet seal. The button keeps its ordinary
## pressed/hover behaviour for play; the labels are its children.

const SEAL_TOP := 4.0
const SEAL_R := 34.0
const RIBBON_Y := 74.0
const RIBBON_H := 38.0

var route_open := false
var route_cleared := false
var side_road := false
var heroic := false
var has_jar := false
var jar_found := false
var is_next := false
var number := ""
var _hovered := false
var _t := 0.0


func configure(open: bool, cleared: bool) -> void:
	route_open = open
	route_cleared = cleared
	queue_redraw()


func _ready() -> void:
	mouse_entered.connect(func():
		_hovered = true
		queue_redraw())
	mouse_exited.connect(func():
		_hovered = false
		queue_redraw())
	resized.connect(queue_redraw)
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	if (route_open and not route_cleared) or _hovered or is_next:
		queue_redraw()


func _font() -> Font:
	var path := "res://assets/fonts/cinzel.ttf"
	return load(path) if ResourceLoader.exists(path) else ThemeDB.fallback_font


func _draw() -> void:
	if size.x < 60.0 or size.y < 40.0:
		return
	var w := size.x
	var c := Vector2(w * 0.5, SEAL_TOP + SEAL_R)
	var r := SEAL_R * (0.8 if side_road else 1.0)
	var pulse := 0.5 + 0.5 * sin(_t * 2.6)
	var gold := Color(0.95, 0.76, 0.36)
	var green := Color(0.46, 0.80, 0.56)
	var iron := Color(0.36, 0.40, 0.46)
	var violet := Color(0.70, 0.56, 0.95)
	var ring := gold if route_open else iron
	if side_road and route_open:
		ring = violet
	if route_cleared:
		ring = gold if heroic else green
	if _hovered and route_open:
		ring = ring.lightened(0.25)

	# Parchment ribbon under the seal, with folded, notched tails.
	var ry := RIBBON_Y
	var rh := RIBBON_H
	var inset := 18.0
	var parch_hi := Color(0.86, 0.78, 0.60) if route_open or route_cleared else Color(0.46, 0.46, 0.48)
	var parch_lo := parch_hi.darkened(0.28)
	var tail := 16.0
	var left_tail := PackedVector2Array([Vector2(inset - tail, ry + 6), Vector2(inset + 6, ry + 6), Vector2(inset + 6, ry + rh + 6), Vector2(inset - tail, ry + rh + 6), Vector2(inset - tail + 8, ry + rh * 0.5 + 6)])
	var right_tail := PackedVector2Array([Vector2(w - inset + tail, ry + 6), Vector2(w - inset - 6, ry + 6), Vector2(w - inset - 6, ry + rh + 6), Vector2(w - inset + tail, ry + rh + 6), Vector2(w - inset + tail - 8, ry + rh * 0.5 + 6)])
	draw_colored_polygon(left_tail, parch_lo.darkened(0.2))
	draw_colored_polygon(right_tail, parch_lo.darkened(0.2))
	var band := PackedVector2Array([Vector2(inset, ry), Vector2(w - inset, ry), Vector2(w - inset, ry + rh), Vector2(inset, ry + rh)])
	draw_polygon(band, PackedColorArray([parch_hi, parch_hi, parch_lo, parch_lo]))
	var edge := Color(0.35, 0.24, 0.12, 0.9) if route_open or route_cleared else Color(0.22, 0.23, 0.26, 0.9)
	band.append(band[0])
	draw_polyline(band, edge, 1.4, true)
	draw_line(Vector2(inset + 5, ry + 4), Vector2(w - inset - 5, ry + 4), Color(edge, 0.35), 1.0, true)
	draw_line(Vector2(inset + 5, ry + rh - 4), Vector2(w - inset - 5, ry + rh - 4), Color(edge, 0.35), 1.0, true)

	# Glow behind an open seal; a stronger, breathing one for the next chapter.
	if route_open and not route_cleared:
		var g := 0.10 + 0.10 * pulse + (0.12 if is_next else 0.0)
		for k in 5:
			draw_circle(c, r * (1.15 + 0.16 * k), Color(ring, g * (1.0 - k / 5.0)))
	# Laurel wreath around a won seal.
	if route_cleared:
		for side in [-1.0, 1.0]:
			for k in 7:
				var a: float = PI * 0.5 + float(side) * (0.35 + k * 0.33)
				var p := c + Vector2(cos(a), sin(a)) * (r + 7.0)
				var dir := Vector2(cos(a + float(side) * 0.9), sin(a + float(side) * 0.9))
				draw_colored_polygon(PackedVector2Array([p - dir * 5.0, p + Vector2(-dir.y, dir.x) * 2.6, p + dir * 5.0, p - Vector2(-dir.y, dir.x) * 2.6]), Color(ring, 0.85))
	# The seal: a scalloped disc of wax or iron with a raised inner ring.
	var body := Color(0.55, 0.12, 0.10) if route_open else Color(0.16, 0.17, 0.20)
	if route_cleared:
		body = Color(0.20, 0.34, 0.24) if not heroic else Color(0.52, 0.38, 0.12)
	if side_road and route_open and not route_cleared:
		body = Color(0.30, 0.18, 0.46)
	var scallop := PackedVector2Array()
	for k in 36:
		var a2 := float(k) / 36.0 * TAU
		var rr := r * (1.0 + 0.06 * (1.0 if k % 2 == 0 else -1.0))
		scallop.append(c + Vector2(cos(a2), sin(a2)) * rr)
	draw_colored_polygon(scallop, body.darkened(0.25))
	for k in 6:
		var f := 1.0 - k / 6.0
		draw_circle(c + Vector2(-r * 0.1, -r * 0.12) * (1.0 - f), r * 0.9 * f, body.lerp(body.lightened(0.35), 1.0 - f))
	draw_arc(c, r * 0.9, 0.0, TAU, 40, Color(ring, 0.95), 2.4, true)
	draw_arc(c, r * 0.7, 0.0, TAU, 40, Color(ring, 0.45), 1.2, true)
	scallop.append(scallop[0])
	draw_polyline(scallop, Color(ring.darkened(0.3), 0.9), 1.2, true)
	# Stamped chapter number.
	var font := _font()
	var fs := 18 if not side_road else 14
	var label := number
	var tw := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var ink := Color(0.99, 0.92, 0.72) if route_open or route_cleared else Color(0.58, 0.62, 0.68)
	draw_string(font, c + Vector2(-tw * 0.5, fs * 0.36), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	# Sealed: a chain across the seal.
	if not route_open and not route_cleared:
		for k in 5:
			var p2 := c + Vector2(-r * 0.9 + k * r * 0.45, r * 0.38 - k * r * 0.19)
			draw_arc(p2, 5.0, 0.0, TAU, 12, Color(0.55, 0.58, 0.63, 0.9), 2.0, true)
	# A buried jar lies here: a small clay jar badge.
	if has_jar:
		var jp := c + Vector2(r * 0.9, r * 0.55)
		var jc := Color(0.66, 0.40, 0.24) if not jar_found else Color(0.46, 0.80, 0.56)
		draw_circle(jp, 9.0, Color(0.05, 0.04, 0.03, 0.95))
		draw_colored_polygon(PackedVector2Array([jp + Vector2(-4, -3), jp + Vector2(4, -3), jp + Vector2(5, 4), jp + Vector2(0, 7), jp + Vector2(-5, 4)]), jc)
		draw_rect(Rect2(jp + Vector2(-2.5, -6), Vector2(5, 3)), jc.darkened(0.3))
