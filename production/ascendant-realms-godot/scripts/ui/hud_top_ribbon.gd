extends Control
## Plan 420: the battle screen's top bar is one continuous band of dark iron
## hung from the top edge, with a gilt bronze hem, instead of eight separate
## boxed instruments. The readings sit on it as icon and number; engraved
## dividers and studs keep the rhythm. The objective banner and menu tab use
## the same band (draw_band) so the whole top edge reads as one set.

## X positions (local) where a group ornament sits on the band.
var ornaments := PackedFloat32Array()
## Height of the band itself; the control is taller to hold the drop shadow.
var band_height := 58.0

static var _grain: ImageTexture = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	draw_band(self, Rect2(0, 0, size.x, band_height), false, true)
	for x in ornaments:
		draw_group_ornament(self, x, band_height)


## Faint brushed streaks so the iron is not a flat colour.
static func grain() -> ImageTexture:
	if _grain != null:
		return _grain
	var w := 256
	var h := 64
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 421
	for y in h:
		var row := rng.randf_range(0.35, 0.65)
		var phase := rng.randf() * TAU
		for x in w:
			var streak := row + 0.18 * sin(phase + float(x) / w * TAU * float(1 + (y % 3))) + rng.randf_range(-0.12, 0.12)
			var v := clampf(streak, 0.0, 1.0)
			img.set_pixel(x, y, Color(v, v, v, 1.0))
	_grain = ImageTexture.create_from_image(img)
	return _grain


## A hanging band: flush with the top of rect, a bronze hem along the bottom,
## and, where asked, an angled end cap with a gem finial.
static func draw_band(ci: CanvasItem, rect: Rect2, left_cap: bool, right_cap: bool, cap: float = 22.0) -> void:
	var x0 := rect.position.x
	var y0 := rect.position.y
	var x1 := rect.end.x
	var y1 := rect.end.y
	var bl := x0 + (cap if left_cap else 0.0)
	var br := x1 - (cap if right_cap else 0.0)
	# Soft shadow cast on the battlefield under the hem.
	var shade := 12.0
	ci.draw_polygon(PackedVector2Array([
		Vector2(bl, y1), Vector2(br, y1), Vector2(br - 4, y1 + shade), Vector2(bl + 4, y1 + shade)]),
		PackedColorArray([Color(0, 0, 0, 0.42), Color(0, 0, 0, 0.42), Color(0, 0, 0, 0), Color(0, 0, 0, 0)]))
	var body := PackedVector2Array([Vector2(x0, y0), Vector2(x1, y0), Vector2(br, y1), Vector2(bl, y1)])
	var top := Color(0.105, 0.098, 0.088, 0.97)
	var low := Color(0.036, 0.039, 0.043, 0.97)
	ci.draw_polygon(body, PackedColorArray([top, top, low, low]))
	ci.draw_texture_rect(grain(), Rect2(x0, y0, x1 - x0, y1 - y0), true, Color(1, 1, 1, 0.055))
	# Upper sheen and a recessed channel above the hem.
	ci.draw_line(Vector2(x0, y0 + 1.5), Vector2(x1, y0 + 1.5), Color(0.62, 0.52, 0.36, 0.30), 1.0)
	var chan := y1 - 9.0
	var cl := x0 + (cap * (chan - y0) / (y1 - y0) if left_cap else 0.0)
	var cr := x1 - (cap * (chan - y0) / (y1 - y0) if right_cap else 0.0)
	ci.draw_line(Vector2(cl + 2, chan), Vector2(cr - 2, chan), Color(0, 0, 0, 0.55), 1.0, true)
	ci.draw_line(Vector2(cl + 2, chan + 1.2), Vector2(cr - 2, chan + 1.2), Color(0.85, 0.66, 0.38, 0.16), 1.0, true)
	# The hem: dark bed, bronze bar, gilt highlight, following the caps.
	var hem := PackedVector2Array()
	if left_cap:
		hem.append(Vector2(x0 + 1.0, y0))
	hem.append(Vector2(bl, y1 - 3.0))
	hem.append(Vector2(br, y1 - 3.0))
	if right_cap:
		hem.append(Vector2(x1 - 1.0, y0))
	var lift := PackedVector2Array()
	for p in hem:
		lift.append(p + Vector2(0, -2.0))
	ci.draw_polyline(hem, Color(0.05, 0.035, 0.02, 0.95), 7.0, true)
	ci.draw_polyline(hem, Color(0.62, 0.44, 0.22, 1.0), 4.5, true)
	ci.draw_polyline(lift, Color(0.98, 0.82, 0.50, 0.85), 1.2, true)
	ci.draw_polyline(hem.duplicate(), Color(0.30, 0.19, 0.09, 0.9), 1.0, true)
	if left_cap:
		_finial(ci, Vector2(x0 + cap * 0.5, (y0 + y1) * 0.5 + 4.0))
	if right_cap:
		_finial(ci, Vector2(x1 - cap * 0.5, (y0 + y1) * 0.5 + 4.0))


static func _finial(ci: CanvasItem, c: Vector2) -> void:
	var gem := PackedVector2Array([c + Vector2(0, -7), c + Vector2(5, 0), c + Vector2(0, 7), c + Vector2(-5, 0)])
	ci.draw_colored_polygon(gem, Color(0.36, 0.08, 0.05, 1.0))
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -7), c + Vector2(5, 0), c + Vector2(0, -1), c + Vector2(-5, 0)]), Color(0.78, 0.22, 0.12, 0.85))
	var rim := PackedVector2Array(gem)
	rim.append(gem[0])
	ci.draw_polyline(rim, Color(0.92, 0.72, 0.40, 1.0), 1.4, true)
	ci.draw_circle(c + Vector2(-1.2, -2.5), 1.0, Color(1, 0.9, 0.8, 0.8))


## An engraved divider between two readings, with a stud set in the hem.
static func draw_divider(ci: CanvasItem, x: float, band_h: float) -> void:
	ci.draw_line(Vector2(x - 0.8, 10), Vector2(x - 0.8, band_h - 13), Color(0, 0, 0, 0.62), 1.6, true)
	ci.draw_line(Vector2(x + 0.9, 10), Vector2(x + 0.9, band_h - 13), Color(0.85, 0.68, 0.42, 0.16), 1.0, true)
	var s := Vector2(x, band_h - 3.0)
	ci.draw_circle(s, 3.2, Color(0.10, 0.07, 0.04, 1.0))
	ci.draw_circle(s, 2.3, Color(0.86, 0.66, 0.36, 1.0))
	ci.draw_circle(s + Vector2(-0.6, -0.7), 0.8, Color(1, 0.94, 0.78, 0.9))


## The heavier ornament between the economy and the army readings.
static func draw_group_ornament(ci: CanvasItem, x: float, band_h: float) -> void:
	for dx in [-5.0, 5.0]:
		ci.draw_line(Vector2(x + dx, 7), Vector2(x + dx, band_h - 12), Color(0, 0, 0, 0.6), 1.6, true)
		ci.draw_line(Vector2(x + dx + 1.4, 7), Vector2(x + dx + 1.4, band_h - 12), Color(0.85, 0.66, 0.38, 0.30), 1.0, true)
	_finial(ci, Vector2(x, band_h * 0.5 - 1.0))
