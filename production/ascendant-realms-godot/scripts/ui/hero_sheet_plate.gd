extends PanelContainer
## Cut-corner vellum and forged-metal backing for the menu panels.
## A closed gilt frame on all eight edges (lit from the top-left, so the
## bottom and right edges sit a shade darker), a faint inner hairline, small
## gilt studs at the four cut corners and a crest on the top edge. Everything is
## drawn from `size`, so the frame stays crisp at any window shape.

var surface_alpha := 0.87
var surface_alpha_bottom := 0.87


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 70.0 or size.y < 50.0:
		return
	var w := size.x
	var h := size.y
	var cut := minf(24.0, minf(w, h) * 0.16)
	var shape := PackedVector2Array([
		Vector2(cut, 0), Vector2(w - cut, 0), Vector2(w, cut),
		Vector2(w, h - cut), Vector2(w - cut, h), Vector2(cut, h),
		Vector2(0, h - cut), Vector2(0, cut)])
	var top_ink := Color(0.018, 0.027, 0.039, surface_alpha)
	var bottom_ink := Color(0.018, 0.027, 0.039, surface_alpha_bottom)
	draw_polygon(shape, PackedColorArray([
		top_ink, top_ink, top_ink, bottom_ink,
		bottom_ink, bottom_ink, bottom_ink, top_ink]))
	var gilt := Color(0.80, 0.66, 0.42, 0.72)
	var shade := gilt.darkened(0.3)
	# Lit edges: left, top-left bevel, top, top-right bevel.
	draw_polyline(PackedVector2Array([Vector2(0, h - cut), Vector2(0, cut), Vector2(cut, 0), Vector2(w - cut, 0), Vector2(w, cut)]), gilt, 1.6, true)
	# Shaded edges: right, bottom-right bevel, bottom, bottom-left bevel.
	draw_polyline(PackedVector2Array([Vector2(w, cut), Vector2(w, h - cut), Vector2(w - cut, h), Vector2(cut, h), Vector2(0, h - cut)]), shade, 1.4, true)
	# Inner hairline, inset, for a double-ruled plate.
	var i := 5.0
	var ic := maxf(4.0, cut - 2.0)
	var inner := PackedVector2Array([
		Vector2(ic + i, i), Vector2(w - ic - i, i), Vector2(w - i, ic + i),
		Vector2(w - i, h - ic - i), Vector2(w - ic - i, h - i), Vector2(ic + i, h - i),
		Vector2(i, h - ic - i), Vector2(i, ic + i), Vector2(ic + i, i)])
	draw_polyline(inner, Color(gilt, 0.16), 1.0, true)
	# Gilt studs where the corners are cut.
	for c in [Vector2(cut * 0.5, cut * 0.5), Vector2(w - cut * 0.5, cut * 0.5), Vector2(w - cut * 0.5, h - cut * 0.5), Vector2(cut * 0.5, h - cut * 0.5)]:
		var s := 2.6
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -s), c + Vector2(s, 0), c + Vector2(0, s), c + Vector2(-s, 0)]), Color(0.96, 0.81, 0.49, 0.7))
	# Crest on the top edge: a gilt diamond flanked by short rules, so the
	# plate reads as finished metalwork rather than a bare box.
	var mid := w * 0.5
	var reach := minf(64.0, w * 0.18)
	var bright := Color(0.96, 0.81, 0.49, 0.85)
	for dir in [-1.0, 1.0]:
		draw_line(Vector2(mid + dir * 9.0, 0), Vector2(mid + dir * reach, 0), Color(0.96, 0.81, 0.49, 0.9), 2.2, true)
		draw_circle(Vector2(mid + dir * (reach + 3.0), 0), 1.6, Color(bright, 0.7))
	var d := 6.0
	draw_colored_polygon(PackedVector2Array([Vector2(mid, -d), Vector2(mid + d, 0), Vector2(mid, d), Vector2(mid - d, 0)]), Color(0.10, 0.08, 0.05, 0.95))
	draw_polyline(PackedVector2Array([Vector2(mid, -d), Vector2(mid + d, 0), Vector2(mid, d), Vector2(mid - d, 0), Vector2(mid, -d)]), bright, 1.4, true)
	draw_circle(Vector2(mid, 0), 1.8, bright)
