extends "res://scripts/ui/hud_action_button.gd"
## Reliquary action surface. One script paints every interactive tile so state
## reads the same everywhere: light means ready, a dark sweep means recovering,
## a cold tint means a missing resource. Tier B: no frames inside frames.

## Ability tiles read their cooldown from the caster each frame.
var caster = null
var ability_id := ""
var cooldown_total := 0.0
var mana_cost := 0
var glyph_name := ""
var hotkey := ""
var caption := ""
var cost_text := ""

const TILE := 88.0
const CAPTION_H := 22.0


func _ready() -> void:
	super._ready()
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	if command_kind == "ABILITY":
		set_process(true)


func _process(delta: float) -> void:
	if command_kind == "ABILITY":
		queue_redraw()
		if _glint >= 0.0:
			_glint += delta * 2.6
			if _glint > 1.2:
				_glint = -1.0
		return
	super._process(delta)


func _remaining() -> float:
	if caster == null or not is_instance_valid(caster) or ability_id.is_empty():
		return 0.0
	if not ("ability_cd" in caster):
		return 0.0
	return float(caster.ability_cd.get(ability_id, 0.0))


func _mana_short() -> bool:
	if caster == null or not is_instance_valid(caster) or not ("mana" in caster):
		return false
	return caster.mana < mana_cost


func _draw() -> void:
	if size.x < 24.0 or size.y < 24.0:
		return
	if is_menu:
		_draw_menu()
	elif command_kind == "ABILITY":
		_draw_ability()
	elif command_kind == "ORDER":
		_draw_order()
	else:
		_draw_card()


func _lit() -> bool:
	return (is_hovered() or has_focus()) and not disabled


func _draw_menu() -> void:
	var outer := RqKit.chamfer(Rect2(Vector2.ZERO, size), 9, 0, 9, 0)
	var inner := RqKit.draw_edge(self, outer, 2.0)
	draw_colored_polygon(inner, Color("16171a"))
	var g := RqKit.glyph("menu")
	if g:
		var px := 26.0
		draw_texture_rect(g, Rect2((size - Vector2(px, px)) * 0.5, Vector2(px, px)), false, RqKit.TEXT if not _lit() else RqKit.TEXT_BRIGHT)


func _draw_ability() -> void:
	var tile := Rect2(Vector2((size.x - TILE) * 0.5, 0.0), Vector2(TILE, TILE))
	var remaining := _remaining()
	var cooling := remaining > 0.05
	var short := not cooling and _mana_short()
	var ready := not cooling and not short and not disabled
	var lit := _lit()
	var lift := Vector2(0, -3) if lit else Vector2.ZERO
	tile.position += lift
	var rim := RqKit.chamfer(tile, 10, 10, 0, 0)
	# Rim: brass when ready, dark bronze otherwise.
	var lo: Color = RqKit.mat("edge_lo")
	var md: Color = RqKit.mat("edge_mid")
	var hi: Color = RqKit.mat("edge_hi")
	var rim_top := hi if ready else md.darkened(0.45)
	var rim_bottom := md if ready else lo.darkened(0.2)
	if lit:
		rim_top = hi.lightened(0.25)
		rim_bottom = hi
	var rim_cols := PackedColorArray()
	for p in rim:
		rim_cols.append(rim_top.lerp(rim_bottom, (p.y - tile.position.y) / tile.size.y))
	draw_colored_polygon(RqKit.chamfer(tile.grow(1.0), 11, 11, 0, 0), Color(0, 0, 0, 0.6))
	draw_polygon(rim, rim_cols)
	var well := RqKit.inset_polygon(rim, 2.0)
	draw_colored_polygon(well, RqKit.WELL)
	var center := tile.get_center() + Vector2(0, -1)
	if ready:
		# A low warm bloom behind the glyph, never a flooded disc.
		var lume: Color = RqKit.mat("lume")
		for i in 6:
			var r := 40.0 - i * 5.5
			draw_circle(center, r, Color(lume.r, lume.g, lume.b, 0.028 + i * 0.006))
	var g := RqKit.glyph(glyph_name) if not glyph_name.is_empty() else null
	if g == null:
		g = RqKit.glyph("lume")
	var px := 48.0
	var glyph_color := Color("c9b48a")
	if ready:
		glyph_color = Color("ffe3a6")
	elif short:
		glyph_color = Color("6f7fa0")
	elif cooling:
		glyph_color = Color("8a7d64")
	if g:
		var gr := Rect2(center - Vector2(px, px) * 0.5, Vector2(px, px))
		if ready:
			var glow: Color = RqKit.mat("lume")
			draw_texture_rect(g, gr.grow(2.0), false, Color(glow.r, glow.g, glow.b, 0.35))
		draw_texture_rect(g, gr, false, glyph_color)
	if cooling and cooldown_total > 0.0:
		var frac := clampf(remaining / cooldown_total, 0.0, 1.0)
		_draw_sweep(well, center, frac)
		var secs := str(int(ceil(remaining)))
		var f := RqKit.font(RqKit.FONT_DISPLAY_BOLD)
		var fs := 28
		var tw := f.get_string_size(secs, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		draw_string_outline(f, Vector2(center.x - tw * 0.5, center.y + 10), secs, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Color(0, 0, 0, 0.9))
		draw_string(f, Vector2(center.x - tw * 0.5, center.y + 10), secs, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color.WHITE)
	if not hotkey.is_empty():
		var kf := RqKit.font(RqKit.FONT_DISPLAY_BOLD)
		draw_string_outline(kf, tile.position + Vector2(6, 17), hotkey, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color(0, 0, 0, 0.85))
		draw_string(kf, tile.position + Vector2(6, 17), hotkey, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, RqKit.TEXT_GILT)
	if mana_cost > 0:
		var cf := RqKit.font(RqKit.FONT_BODY_BOLD)
		var ct := str(mana_cost)
		var cw := cf.get_string_size(ct, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		var cp := tile.end - Vector2(cw + 6, 6)
		draw_string_outline(cf, cp, ct, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 4, Color(0, 0, 0, 0.85))
		draw_string(cf, cp, ct, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, RqKit.NEGATIVE if short else RqKit.MANA)
	_draw_glint_in(tile)


func _draw_sweep(well: PackedVector2Array, center: Vector2, frac: float) -> void:
	# Dark fan over the part of the tile still recovering, clockwise from 12.
	if frac <= 0.0:
		return
	var pts := PackedVector2Array([center])
	var steps := 40
	var start := -PI * 0.5 + TAU * (1.0 - frac)
	for i in steps + 1:
		var a := start + TAU * frac * float(i) / steps
		pts.append(center + Vector2(cos(a), sin(a)) * 80.0)
	var clipped := Geometry2D.intersect_polygons(pts, well)
	for poly in clipped:
		draw_colored_polygon(poly, Color(0.015, 0.015, 0.02, 0.72))


func _draw_glint_in(rect: Rect2) -> void:
	if _glint < 0.0 or disabled:
		return
	var x := rect.position.x - 30.0 + (rect.size.x + 60.0) * _glint
	var fade := sin(clampf(_glint, 0.0, 1.0) * PI)
	var band := PackedVector2Array([Vector2(x, rect.position.y), Vector2(x + 14, rect.position.y), Vector2(x - 6, rect.end.y), Vector2(x - 20, rect.end.y)])
	for poly in Geometry2D.intersect_polygons(band, RqKit.chamfer(rect, 10, 10, 0, 0)):
		draw_colored_polygon(poly, Color(1.0, 0.94, 0.78, 0.16 * fade))


func _draw_order() -> void:
	var lit := _lit()
	var active := command_state in ["ACTIVE", "TRAINING"]
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(0, 0, 0, 0.42 if not lit else 0.55))
	var edge: Color = RqKit.mat("edge_hi")
	edge.a = 0.55 if (lit or active) else 0.16
	draw_rect(r.grow(-0.5), edge, false, 1.0)
	if active:
		var lume: Color = RqKit.mat("lume")
		draw_line(Vector2(4, size.y - 1.5), Vector2(size.x - 4, size.y - 1.5), lume, 2.0)
	var g := RqKit.glyph(glyph_name) if not glyph_name.is_empty() else null
	if g:
		var px := minf(26.0, size.y - 12.0)
		var tint := Color("bfb29a")
		if lit or active:
			tint = RqKit.TEXT_BRIGHT
		if disabled:
			tint = Color(0.45, 0.43, 0.4)
		var at := Vector2((size.x - px) * 0.5, (size.y - px) * 0.5)
		if size.x > 90.0:
			# Wide order bars seat the glyph left; the HUD adds the name label.
			at.x = 12.0
		draw_texture_rect(g, Rect2(at, Vector2(px, px)), false, tint)
	if not hotkey.is_empty():
		var kf := RqKit.font(RqKit.FONT_DISPLAY)
		var kw := kf.get_string_size(hotkey, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		draw_string(kf, Vector2(size.x - kw - 4, size.y - 4), hotkey, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, RqKit.TEXT_MUTED)
	if _glint >= 0.0 and not disabled:
		_draw_glint(size.x, size.y)


func _draw_card() -> void:
	# Build, train and research entries: a recessed well with a single worked
	# edge on top. Readiness lives in the copy, not in another frame.
	var lit := _lit()
	var active := command_state in ["ACTIVE", "TRAINING"]
	var enabled := not disabled
	var shape := RqKit.chamfer(Rect2(Vector2.ZERO, size), 8, 0, 0, 0)
	draw_colored_polygon(shape, Color(0.02, 0.02, 0.022, 0.62 if enabled else 0.48))
	var grad := PackedColorArray()
	for p in shape:
		var t := p.y / maxf(1.0, size.y)
		grad.append(Color(1, 1, 1, (0.045 if lit else 0.025) * (1.0 - t)))
	draw_polygon(shape, grad)
	var edge: Color = RqKit.mat("edge_mid")
	edge.a = 0.85 if lit else (0.45 if enabled else 0.18)
	draw_line(Vector2(8, 0.5), Vector2(size.x, 0.5), edge, 1.0)
	draw_line(Vector2(0, 8), Vector2(8, 0), edge, 1.0, true)
	var side: Color = RqKit.mat("edge_hi")
	side.a = 0.25 if lit else 0.08
	draw_rect(Rect2(Vector2.ZERO, size).grow(-0.5), side, false, 1.0)
	if active:
		RqKit.draw_seam(self, Vector2(10, size.y - 2), Vector2(size.x - 10, size.y - 2), 1.0)
	if _glint >= 0.0 and enabled:
		_draw_glint(size.x, size.y)
