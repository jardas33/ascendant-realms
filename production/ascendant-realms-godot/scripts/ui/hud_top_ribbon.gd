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

const HUD_SKIN := preload("res://scripts/ui/hud_forged_skin.gd")
static var _grain: ImageTexture = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	# Plan 425: the whole band, its group ornament (a gem between two engraved
	# lines) and the rivets along its rim are one lit forged surface.
	var x1 := size.x
	var cap := 22.0
	var pts := PackedVector2Array([Vector2(0, -30), Vector2(x1, -30), Vector2(x1, 4), Vector2(x1 - cap, band_height), Vector2(0, band_height)])
	var studs := [Vector4(x1 - cap * 0.62, band_height * 0.5 + 4.0, 6.5, HUD_SKIN.GEM)]
	var lines := []
	for x in ornaments:
		studs.append(Vector4(x, band_height * 0.5 - 2.0, 6.5, HUD_SKIN.GEM))
		lines.append(Vector4(x - 6.0, 8.0, x - 6.0, band_height - 14.0))
		lines.append(Vector4(x + 6.0, 8.0, x + 6.0, band_height - 14.0))
	HUD_SKIN.paint(self, pts, studs, Rect2(), {"rim": 8.0, "inlay": 0.0, "lines": lines, "plate_top": 0.0, "plate_bottom": band_height})


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


## A hanging band: flush with the top of rect, a raised bronze rim along the
## bottom and, where asked, an angled end cap with a gem boss. Plan 425: drawn
## as lit forged metal by hud_forged.gdshader. The outline starts above the
## screen edge so only the lower rim shows. A button gets a backing child
## instead, so its own text is not passed through the metal shader.
static func draw_band(ci: CanvasItem, rect: Rect2, left_cap: bool, right_cap: bool, cap: float = 22.0) -> void:
	var x0 := rect.position.x
	var y0 := rect.position.y
	var x1 := rect.end.x
	var y1 := rect.end.y
	var above := y0 - 30.0
	var pts := PackedVector2Array([Vector2(x0, above), Vector2(x1, above)])
	if right_cap:
		pts.append(Vector2(x1, y0 + 4.0))
		pts.append(Vector2(x1 - cap, y1))
	else:
		pts.append(Vector2(x1, y1))
	if left_cap:
		pts.append(Vector2(x0 + cap, y1))
		pts.append(Vector2(x0, y0 + 4.0))
	else:
		pts.append(Vector2(x0, y1))
	var studs := []
	var gem_r := clampf(cap * 0.30, 4.5, 7.0)
	if left_cap:
		studs.append(Vector4(x0 + cap * 0.62, (y0 + y1) * 0.5 + 4.0, gem_r, HUD_SKIN.GEM))
	if right_cap:
		studs.append(Vector4(x1 - cap * 0.62, (y0 + y1) * 0.5 + 4.0, gem_r, HUD_SKIN.GEM))
	var opts := {"rim": 8.0, "inlay": 0.0, "shadow": 12.0, "plate_top": y0, "plate_bottom": y1}
	if ci is BaseButton:
		var backing := ci.get_node_or_null("ForgedBacking")
		if backing == null:
			backing = HUD_SKIN.Backing.new()
			backing.name = "ForgedBacking"
			ci.add_child.call_deferred(backing)
		backing.set_shape(pts, studs, opts)
		return
	HUD_SKIN.paint(ci, pts, studs, Rect2(), opts)


static func _finial(ci: CanvasItem, c: Vector2) -> void:
	var gem := PackedVector2Array([c + Vector2(0, -7), c + Vector2(5, 0), c + Vector2(0, 7), c + Vector2(-5, 0)])
	ci.draw_colored_polygon(gem, Color(0.36, 0.08, 0.05, 1.0))
	ci.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -7), c + Vector2(5, 0), c + Vector2(0, -1), c + Vector2(-5, 0)]), Color(0.78, 0.22, 0.12, 0.85))
	var rim := PackedVector2Array(gem)
	rim.append(gem[0])
	ci.draw_polyline(rim, Color(0.92, 0.72, 0.40, 1.0), 1.4, true)
	ci.draw_circle(c + Vector2(-1.2, -2.5), 1.0, Color(1, 0.9, 0.8, 0.8))


## An engraved divider between two readings.
static func draw_divider(ci: CanvasItem, x: float, band_h: float) -> void:
	ci.draw_line(Vector2(x - 0.8, 12), Vector2(x - 0.8, band_h - 15), Color(0, 0, 0, 0.62), 1.6, true)
	ci.draw_line(Vector2(x + 0.9, 12), Vector2(x + 0.9, band_h - 15), Color(0.85, 0.68, 0.42, 0.16), 1.0, true)


## The heavier ornament between the economy and the army readings.
static func draw_group_ornament(ci: CanvasItem, x: float, band_h: float) -> void:
	for dx in [-5.0, 5.0]:
		ci.draw_line(Vector2(x + dx, 7), Vector2(x + dx, band_h - 12), Color(0, 0, 0, 0.6), 1.6, true)
		ci.draw_line(Vector2(x + dx + 1.4, 7), Vector2(x + dx + 1.4, band_h - 12), Color(0.85, 0.66, 0.38, 0.30), 1.0, true)
	_finial(ci, Vector2(x, band_h * 0.5 - 1.0))
