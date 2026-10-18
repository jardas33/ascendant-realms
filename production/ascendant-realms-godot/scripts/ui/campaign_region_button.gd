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
const RIBBON_H := 44.0
## A two-line chapter name gets a taller ribbon instead of a smaller size.
var ribbon_h := RIBBON_H

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
	var iron := Color(0.50, 0.46, 0.40)
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
	var rh := ribbon_h
	var inset := 18.0
	# Sealed chapters hang on a dark iron plaque with light lettering: the old
	# flat grey ribbon read as an unfinished placeholder on the painted map.
	var lit_up := route_open or route_cleared
	var parch_hi := Color(0.86, 0.78, 0.60) if lit_up else Color(0.25, 0.26, 0.30)
	var parch_lo := parch_hi.darkened(0.28) if lit_up else Color(0.11, 0.12, 0.14)
	var tail := 16.0
	# A soft drop shadow lifts the ribbon off the map.
	draw_rect(Rect2(inset - tail + 2.0, ry + 5.0, w - 2.0 * (inset - tail) - 4.0, rh + 6.0), Color(0, 0, 0, 0.28))
	draw_rect(Rect2(inset - 2.0, ry + 2.0, w - 2.0 * inset + 4.0, rh + 3.0), Color(0, 0, 0, 0.30))
	var left_tail := PackedVector2Array([Vector2(inset - tail, ry + 6), Vector2(inset + 6, ry + 6), Vector2(inset + 6, ry + rh + 6), Vector2(inset - tail, ry + rh + 6), Vector2(inset - tail + 8, ry + rh * 0.5 + 6)])
	var right_tail := PackedVector2Array([Vector2(w - inset + tail, ry + 6), Vector2(w - inset - 6, ry + 6), Vector2(w - inset - 6, ry + rh + 6), Vector2(w - inset + tail, ry + rh + 6), Vector2(w - inset + tail - 8, ry + rh * 0.5 + 6)])
	# Sealed plaques hang on tails of dark bronze, matching their frame.
	var tail_tone := parch_lo.darkened(0.2) if lit_up else Color(0.20, 0.16, 0.11)
	draw_colored_polygon(left_tail, tail_tone)
	draw_colored_polygon(right_tail, tail_tone)
	var band := PackedVector2Array([Vector2(inset, ry), Vector2(w - inset, ry), Vector2(w - inset, ry + rh), Vector2(inset, ry + rh)])
	draw_polygon(band, PackedColorArray([parch_hi, parch_hi, parch_lo, parch_lo]))
	var edge := Color(0.35, 0.24, 0.12, 0.9) if lit_up else Color(0.56, 0.59, 0.65, 0.85)
	band.append(band[0])
	draw_polyline(band, edge, 1.4, true)
	draw_line(Vector2(inset + 5, ry + 4), Vector2(w - inset - 5, ry + 4), Color(edge, 0.35), 1.0, true)
	draw_line(Vector2(inset + 5, ry + rh - 4), Vector2(w - inset - 5, ry + rh - 4), Color(edge, 0.35), 1.0, true)
	if not lit_up:
		_draw_iron_plaque(Rect2(inset - 3.0, ry - 2.0, w - 2.0 * inset + 6.0, rh + 4.0))

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
	var ink := Color(0.99, 0.92, 0.72)
	if route_open or route_cleared:
		draw_string(font, c + Vector2(-tw * 0.5, fs * 0.36), label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	else:
		_draw_padlock(c, r)
	# A buried jar lies here: a small clay jar badge.
	if has_jar:
		var jp := c + Vector2(r * 0.9, r * 0.55)
		var jc := Color(0.66, 0.40, 0.24) if not jar_found else Color(0.46, 0.80, 0.56)
		draw_circle(jp, 9.0, Color(0.05, 0.04, 0.03, 0.95))
		draw_colored_polygon(PackedVector2Array([jp + Vector2(-4, -3), jp + Vector2(4, -3), jp + Vector2(5, 4), jp + Vector2(0, 7), jp + Vector2(-5, 4)]), jc)
		draw_rect(Rect2(jp + Vector2(-2.5, -6), Vector2(5, 3)), jc.darkened(0.3))


## Plan 381: a sealed chapter's name plate is forged iron in an old bronze
## frame with cut corners and rivets, drawn over the flat slate band, which
## read as a grey placeholder box on the painted map.
func _draw_iron_plaque(box: Rect2) -> void:
	var cut := 7.0
	var x0 := box.position.x
	var y0 := box.position.y
	var x1 := box.end.x
	var y1 := box.end.y
	var bronze := Color(0.62, 0.50, 0.32)
	var bronze_dk := Color(0.30, 0.23, 0.14)
	# Dark rim, bronze frame, then the iron face with a cool sheen at the top.
	draw_colored_polygon(_cut_box(box, -1.5), Color(0.02, 0.02, 0.025, 0.95))
	var frame: PackedVector2Array = _cut_box(box, 0.0)
	draw_polygon(frame, PackedColorArray([bronze, bronze, bronze, bronze_dk, bronze_dk, bronze_dk, bronze_dk, bronze]))
	var face: PackedVector2Array = _cut_box(box, 3.0)
	var hi := Color(0.24, 0.25, 0.29)
	var lo := Color(0.08, 0.085, 0.10)
	draw_polygon(face, PackedColorArray([hi, hi, hi.lerp(lo, 0.5), lo, lo, lo, lo, hi.lerp(lo, 0.5)]))
	# A thin inner rule in dim bronze, and a lit edge under the top of the frame.
	var rule: PackedVector2Array = _cut_box(box, 6.0)
	rule.append(rule[0])
	draw_polyline(rule, Color(bronze, 0.38), 1.0, true)
	draw_line(Vector2(x0 + cut + 3.0, y0 + 3.6), Vector2(x1 - cut - 3.0, y0 + 3.6), Color(1.0, 1.0, 1.0, 0.10), 1.0, true)
	# Rivets at both ends.
	for p in [Vector2(x0 + 9.0, (y0 + y1) * 0.5), Vector2(x1 - 9.0, (y0 + y1) * 0.5)]:
		draw_circle(p, 3.0, Color(0.02, 0.02, 0.025, 0.9))
		draw_circle(p, 2.2, bronze_dk)
		draw_circle(p + Vector2(-0.6, -0.6), 1.1, bronze.lightened(0.2))


## The plaque's outline with cut corners, inset by ins pixels.
func _cut_box(box: Rect2, ins: float) -> PackedVector2Array:
	var k := 7.0 - ins * 0.4
	var x0 := box.position.x + ins
	var y0 := box.position.y + ins
	var x1 := box.end.x - ins
	var y1 := box.end.y - ins
	return PackedVector2Array([Vector2(x0 + k, y0), Vector2(x1 - k, y0), Vector2(x1, y0 + k), Vector2(x1, y1 - k),
		Vector2(x1 - k, y1), Vector2(x0 + k, y1), Vector2(x0, y1 - k), Vector2(x0, y0 + k)])


func _draw_padlock(c: Vector2, r: float) -> void:
	# Sealed: a forged steel padlock stamped on the iron seal (it replaced a
	# row of small rings that read as a broken line).
	var steel_hi := Color(0.74, 0.77, 0.82)
	var steel_lo := Color(0.30, 0.32, 0.37)
	var dark := Color(0.03, 0.035, 0.045, 0.95)
	var sc := c + Vector2(0.0, -r * 0.10)
	var sr := r * 0.25
	draw_arc(sc, sr, PI, TAU, 18, dark, 6.0, true)
	draw_line(sc + Vector2(-sr, 0.0), sc + Vector2(-sr, r * 0.16), dark, 6.0, true)
	draw_line(sc + Vector2(sr, 0.0), sc + Vector2(sr, r * 0.16), dark, 6.0, true)
	draw_arc(sc, sr, PI, TAU, 18, steel_hi, 3.2, true)
	draw_line(sc + Vector2(-sr, 0.0), sc + Vector2(-sr, r * 0.16), steel_hi, 3.2, true)
	draw_line(sc + Vector2(sr, 0.0), sc + Vector2(sr, r * 0.16), steel_lo.lightened(0.2), 3.2, true)
	var bw := r * 0.86
	var bh := r * 0.62
	var top := c.y + r * 0.02
	var body := PackedVector2Array([Vector2(c.x - bw * 0.5, top), Vector2(c.x + bw * 0.5, top), Vector2(c.x + bw * 0.5, top + bh), Vector2(c.x - bw * 0.5, top + bh)])
	var halo := PackedVector2Array()
	for p in body:
		halo.append(c + (p - c) * 1.0 + (p - Vector2(c.x, top + bh * 0.5)).normalized() * 2.0)
	draw_colored_polygon(halo, dark)
	draw_polygon(body, PackedColorArray([steel_hi, steel_hi, steel_lo, steel_lo]))
	draw_line(Vector2(c.x - bw * 0.5 + 2.0, top + 2.0), Vector2(c.x + bw * 0.5 - 2.0, top + 2.0), Color(1, 1, 1, 0.45), 1.2, true)
	draw_line(Vector2(c.x - bw * 0.5 + 2.0, top + bh * 0.52), Vector2(c.x + bw * 0.5 - 2.0, top + bh * 0.52), Color(0.0, 0.0, 0.0, 0.25), 1.0, true)
	# The keyhole.
	var kc := Vector2(c.x, top + bh * 0.40)
	draw_circle(kc, r * 0.075, dark)
	draw_colored_polygon(PackedVector2Array([kc + Vector2(-r * 0.045, 0.0), kc + Vector2(r * 0.045, 0.0), kc + Vector2(r * 0.07, r * 0.20), kc + Vector2(-r * 0.07, r * 0.20)]), dark)
