extends PanelContainer
## The portrait medallion that breaks out of the deck. An octagon of worked
## metal holds the identity art; its inner ring fills with battlefield
## experience, and a diamond carries the level. Painted art lives only here.

const RIM := 9.0

var ring_progress := 0.0:
	set(v):
		if not is_equal_approx(v, ring_progress):
			ring_progress = v
			queue_redraw()
			if is_instance_valid(_badge):
				_badge.queue_redraw()
var level_text := "":
	set(v):
		if v != level_text:
			level_text = v
			if is_instance_valid(_badge):
				_badge.queue_redraw()
var hostile := false

var _mask: Control
var _badge: Control


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxEmpty.new()
	sb.set_content_margin_all(RIM)
	add_theme_stylebox_override("panel", sb)
	_mask = Control.new()
	_mask.name = "MedallionAperture"
	_mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mask.draw.connect(_draw_mask)
	_mask.resized.connect(_mask.queue_redraw)
	add_child(_mask)
	_badge = Control.new()
	_badge.name = "MedallionBadge"
	_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badge.draw.connect(_draw_badge)
	add_child(_badge)
	resized.connect(queue_redraw)


## Seats a portrait view inside the aperture, filling it edge to edge.
func hold(portrait: Control) -> void:
	_mask.add_child(portrait)
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Call after the portrait is configured: applying an entity resets the art.
func strip_portrait_frame(portrait: Control, cover: bool = true) -> void:
	if not is_instance_valid(portrait):
		return
	# The medallion is the frame; the portrait's own square frame and inset
	# would read as a box inside the octagon.
	var frame := portrait.get_node_or_null("PortraitFrame") as CanvasItem
	if frame:
		frame.visible = false
	var art := portrait.get_node_or_null("PortraitArtwork") as TextureRect
	if art:
		var inset := 0.0 if cover else 14.0
		art.offset_left = inset
		art.offset_top = inset
		art.offset_right = -inset
		art.offset_bottom = -inset
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var view := portrait.get_node_or_null("PortraitViewport") as Control
	if view:
		var model_inset := 0.0 if cover else 12.0
		view.offset_left = model_inset
		view.offset_top = model_inset
		view.offset_right = -model_inset
		view.offset_bottom = -model_inset


func _octagon_in(rect: Rect2) -> PackedVector2Array:
	return RqKit.octagon(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.5)


func _draw_mask() -> void:
	var r := Rect2(Vector2.ZERO, _mask.size)
	_mask.draw_colored_polygon(_octagon_in(r), Color.WHITE)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	if r.size.x < 40.0:
		return
	var c := r.get_center()
	var rad := minf(r.size.x, r.size.y) * 0.5
	var outer := RqKit.octagon(c, rad)
	var sh := PackedVector2Array()
	for p in outer:
		sh.append(p + Vector2(0, 7))
	draw_colored_polygon(sh, Color(0, 0, 0, 0.5))
	# Worked metal band, then a dark seat for the art.
	var inner := RqKit.draw_edge(self, outer, 4.0)
	draw_colored_polygon(inner, Color("0b0a08"))
	var seat := RqKit.inset_polygon(inner, 3.0)
	draw_colored_polygon(seat, RqKit.mat("lo"))
	RqKit.draw_engraving(self, inner)
	if hostile:
		var red := Color(0.85, 0.25, 0.2, 0.9)
		var loop := PackedVector2Array(outer)
		loop.append(outer[0])
		draw_polyline(loop, red, 2.0, true)


func _draw_badge() -> void:
	var r := Rect2(Vector2.ZERO, _badge.size)
	if r.size.x < 30.0:
		return
	var c := r.get_center()
	var rad := minf(r.size.x, r.size.y) * 0.5 + RIM - 3.0
	# Experience ring: a Lume line tracing the octagon clockwise from the top.
	if ring_progress > 0.001:
		var ring := RqKit.octagon(c, rad)
		var pts := _perimeter_from_top(ring, clampf(ring_progress, 0.0, 1.0))
		var lume: Color = RqKit.mat("lume")
		_badge.draw_polyline(pts, Color(lume.r, lume.g, lume.b, 0.28), 6.0, true)
		_badge.draw_polyline(pts, RqKit.mat("lume_hi"), 2.0, true)
	if level_text.is_empty():
		return
	var d := 22.0
	var at := Vector2(c.x, c.y + rad + 1.0)
	var diamond := PackedVector2Array([at + Vector2(0, -d), at + Vector2(d, 0), at + Vector2(0, d), at + Vector2(-d, 0)])
	var sh := PackedVector2Array()
	for p in diamond:
		sh.append(p + Vector2(0, 3))
	_badge.draw_colored_polygon(sh, Color(0, 0, 0, 0.55))
	var inner := RqKit.draw_edge(_badge, diamond, 2.5)
	_badge.draw_colored_polygon(inner, Color("17130d"))
	var f := RqKit.font(RqKit.FONT_DISPLAY_BOLD)
	var fs := 21 if level_text.length() < 3 else 16
	var tw := f.get_string_size(level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	_badge.draw_string(f, Vector2(at.x - tw * 0.5, at.y + fs * 0.36), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, RqKit.TEXT_GILT)


func _perimeter_from_top(poly: PackedVector2Array, frac: float) -> PackedVector2Array:
	# Octagon points start at the top-left of the flat top edge; begin at the
	# top centre so the ring reads like a dial.
	var loop := PackedVector2Array()
	var top_mid := (poly[0] + poly[1]) * 0.5
	loop.append(top_mid)
	for i in range(1, poly.size()):
		loop.append(poly[i])
	loop.append(poly[0])
	loop.append(top_mid)
	var total := 0.0
	for i in loop.size() - 1:
		total += loop[i].distance_to(loop[i + 1])
	var want := total * frac
	var out := PackedVector2Array([loop[0]])
	for i in loop.size() - 1:
		var seg := loop[i].distance_to(loop[i + 1])
		if want <= seg:
			out.append(loop[i].lerp(loop[i + 1], want / maxf(seg, 0.001)))
			break
		want -= seg
		out.append(loop[i + 1])
	return out
