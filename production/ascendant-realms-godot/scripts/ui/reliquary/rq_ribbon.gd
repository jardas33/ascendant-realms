extends Control
## The top ribbon: a forged band hung from the top edge, with the Age
## medallion at its centre and the plaque that names the Age beneath it.
## The medallion's Lume ring thickens as the Age advances.

var _band := Rect2()
var _medal_center := Vector2.ZERO
var _medal_radius := 0.0
var _plaque := Rect2()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED


func configure(band: Rect2, medal_center: Vector2, medal_radius: float, plaque: Rect2) -> void:
	_band = band
	_medal_center = medal_center
	_medal_radius = medal_radius
	_plaque = plaque
	queue_redraw()


func _circle(c: Vector2, r: float, steps: int = 64) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in steps:
		var a := TAU * float(i) / steps
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	return pts


func _draw() -> void:
	if _band.size.x <= 0.0:
		return
	var slant := _band.size.y * 0.9
	var b := _band
	var outer := PackedVector2Array([
		Vector2(b.position.x, b.position.y - 4.0), Vector2(b.end.x, b.position.y - 4.0),
		Vector2(b.end.x - slant, b.end.y), Vector2(b.position.x + slant, b.end.y)])
	var inner := RqKit.draw_plate(self, outer, 2.0)
	RqKit.draw_seam(self, Vector2(b.position.x + slant + 10.0, b.end.y - 3.0), Vector2(_medal_center.x - _medal_radius - 8.0, b.end.y - 3.0))
	RqKit.draw_seam(self, Vector2(_medal_center.x + _medal_radius + 8.0, b.end.y - 3.0), Vector2(b.end.x - slant - 10.0, b.end.y - 3.0))
	RqKit.draw_rivet(self, Vector2(b.position.x + slant, b.end.y), 3.0)
	RqKit.draw_rivet(self, Vector2(b.end.x - slant, b.end.y), 3.0)
	if _medal_radius <= 0.0:
		return
	# Plaque first so the medallion sits over its top edge.
	if _plaque.size.x > 0.0:
		var plaque := RqKit.chamfer(_plaque, 10, 10, 10, 10)
		var pin := RqKit.draw_plate(self, plaque, 1.5)
		draw_colored_polygon(pin, Color(0.03, 0.028, 0.025, 0.92))
	var c := _medal_center
	var r := _medal_radius
	draw_circle(c + Vector2(0, 6), r + 2.0, Color(0, 0, 0, 0.5))
	var ring := _circle(c, r)
	var seat := RqKit.draw_edge(self, ring, 5.0)
	draw_colored_polygon(seat, Color("0c0b09"))
	var lume: Color = RqKit.mat("lume")
	var strength := RqKit.lume_strength()
	var glow_r := r - 9.0
	draw_arc(c, glow_r, 0.0, TAU, 72, Color(lume.r, lume.g, lume.b, 0.12 * strength), 7.0, true)
	draw_arc(c, glow_r, 0.0, TAU, 72, Color(lume.r, lume.g, lume.b, 0.55 * strength), 1.6 + RqKit.age * 0.5, true)
	# Three Age notches on the ring; lit up to the current Age.
	for i in 3:
		var a := -PI * 0.5 + (float(i) - 1.0) * 0.42
		var at := c + Vector2(cos(a), sin(a)) * (r - 2.5)
		var lit := i < RqKit.age
		draw_circle(at, 3.4, Color(0, 0, 0, 0.7))
		draw_circle(at, 2.4, RqKit.mat("lume_hi") if lit else RqKit.mat("edge_lo"))
