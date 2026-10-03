extends Control
## The Reliquary chassis: one forged deck across the bottom of the screen and
## the minimap housing beside it. Panels that need more height than the deck
## raise a shoulder instead of stacking another frame on top. Purely visual;
## the HUD tells it where things are with configure().

var _deck := Rect2()
var _wings: Array = []
var _dividers: Array = []
var _minimap := Rect2()
var _socket := Rect2()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED


func configure(deck: Rect2, wings: Array, dividers: Array, minimap: Rect2, socket: Rect2 = Rect2()) -> void:
	_deck = deck
	_wings = wings
	_dividers = dividers
	_minimap = minimap
	_socket = socket
	queue_redraw()


func _cut() -> float:
	return float(RqKit.mat("cut"))


func _silhouette() -> PackedVector2Array:
	var cut := _cut()
	var shape := RqKit.chamfer(_deck, cut, cut, 0, 0)
	for w in _wings:
		var wing: Rect2 = w
		if wing.position.y >= _deck.position.y - 4.0:
			continue
		var raised := Rect2(wing.position.x, wing.position.y, wing.size.x, _deck.end.y - wing.position.y)
		var merged := Geometry2D.merge_polygons(shape, RqKit.chamfer(raised, cut * 0.8, cut * 0.8, 0, 0))
		var best := 0.0
		for poly in merged:
			var area := absf(_area(poly))
			if area > best:
				best = area
				shape = poly
	return shape


static func _area(poly: PackedVector2Array) -> float:
	var a := 0.0
	for i in poly.size():
		var p: Vector2 = poly[i]
		var q: Vector2 = poly[(i + 1) % poly.size()]
		a += p.x * q.y - q.x * p.y
	return a * 0.5


func _draw() -> void:
	if _minimap.size.x > 0.0:
		_draw_minimap_housing()
	if _deck.size.x <= 0.0:
		return
	var outer := _silhouette()
	var inner := RqKit.draw_plate(self, outer, 2.0)
	# A second inset line gives the plate a cast lip without another frame.
	var lip := RqKit.inset_polygon(inner, 5.0)
	RqKit.draw_engraving(self, lip)
	# Lume lives in the top seams only.
	for i in inner.size():
		var a: Vector2 = inner[i]
		var b: Vector2 = inner[(i + 1) % inner.size()]
		if absf(a.y - b.y) < 0.5 and a.y < _deck.end.y - 20.0 and absf(a.x - b.x) > 60.0:
			RqKit.draw_seam(self, a + Vector2(0, 1.5), b + Vector2(0, 1.5))
	for p in outer:
		if p.y < _deck.end.y - 20.0:
			RqKit.draw_rivet(self, p + Vector2(0, 0), 3.0)
	if _socket.size.x > 0.0:
		# A dark collar where the medallion sinks into the deck.
		var collar := RqKit.octagon(_socket.get_center(), _socket.size.x * 0.5 + 6.0)
		var sh := Geometry2D.intersect_polygons(collar, inner)
		for poly in sh:
			draw_colored_polygon(poly, Color(0, 0, 0, 0.45))
	for x in _dividers:
		var fx := float(x)
		var top := _deck.position.y + 18.0
		var bottom := _deck.end.y - 14.0
		draw_line(Vector2(fx, top), Vector2(fx, bottom), Color(0, 0, 0, 0.6), 1.0)
		var lit: Color = RqKit.mat("edge_hi")
		lit.a = 0.10
		draw_line(Vector2(fx + 1, top), Vector2(fx + 1, bottom), lit, 1.0)
		RqKit.draw_rivet(self, Vector2(fx + 0.5, top - 6.0), 2.5)


func _draw_minimap_housing() -> void:
	var cut := _cut()
	var r := _minimap
	var outer := RqKit.chamfer(r, 0, cut, 0, 0)
	var inner := RqKit.draw_plate(self, outer, 2.0)
	RqKit.draw_engraving(self, RqKit.inset_polygon(inner, 5.0))
	RqKit.draw_seam(self, Vector2(r.position.x, r.position.y + 2.0), Vector2(r.end.x - cut, r.position.y + 2.0))
	RqKit.draw_rivet(self, Vector2(r.end.x - cut, r.position.y), 3.0)
	RqKit.draw_rivet(self, Vector2(r.end.x, r.position.y + cut), 3.0)
