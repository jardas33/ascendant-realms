@tool
extends StyleBox
class_name OrnatePanelStyle
## The ornate gilt panel frame (assets/ui/panel_main.png), drawn as a
## multi-slice instead of a plain nine-patch. A nine-patch stretched the gems
## that sit mid-edge (the amber crest top and bottom, the teal gems on the
## sides) into long smears on wide or tall panels. Here the corners and the
## gems are drawn at their painted size, only the plain runs of the band in
## between stretch, and the gems stay centred on each edge at any panel shape.
## Panels smaller than the painted frame draw it proportionally smaller.

@export var texture: Texture2D
@export var margin := 48.0

# Regions in the 480x360 source texture.
const TEX_SIZE := Vector2(480, 360)
const CORNER := Vector2(135, 110)
const BAND := 50.0
const TOP_CREST := Rect2(140, 0, 200, 64)
const BOTTOM_CREST := Rect2(140, 296, 200, 64)
# The crests drawn as the band part plus only the small tip that dips into
# the vellum, so no box of mismatched vellum shows around them.
const TOP_BAND := Rect2(140, 0, 200, 50)
const TOP_TIP := Rect2(208, 50, 64, 14)
const BOTTOM_BAND := Rect2(140, 310, 200, 50)
const BOTTOM_TIP := Rect2(208, 296, 64, 14)
# Runs are sampled right beside the crest and gem edges, so both joins
# (corner to run, run to crest) meet pixels that were neighbours in the art.
const TOP_RUN := Rect2(134, 0, 5, 50)
const TOP_RUN_R := Rect2(341, 0, 5, 50)
const BOTTOM_RUN := Rect2(134, 310, 5, 50)
const BOTTOM_RUN_R := Rect2(341, 310, 5, 50)
const LEFT_GEM := Rect2(0, 115, 64, 130)
const RIGHT_GEM := Rect2(416, 115, 64, 130)
const LEFT_RUN := Rect2(0, 110, 50, 4)
const LEFT_RUN_B := Rect2(0, 246, 50, 4)
const RIGHT_RUN := Rect2(430, 110, 50, 4)
const RIGHT_RUN_B := Rect2(430, 246, 50, 4)
# The painted vellum with no ornament tips in it (the crests reach row 62).
const INTERIOR := Rect2(64, 84, 352, 192)


func _get_minimum_size() -> Vector2:
	return Vector2(margin * 2.0, margin * 2.0)


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	if texture == null:
		return
	var rid := texture.get_rid()
	var w := rect.size.x
	var h := rect.size.y
	var o := rect.position
	# Narrow or short panels draw the whole frame a little smaller rather
	# than squashing the ornaments; only very small ones use the nine-patch.
	var k := minf(1.0, minf(w / (TEX_SIZE.x - 10.0), h / (TEX_SIZE.y - 10.0)))
	if k < 0.4:
		RenderingServer.canvas_item_add_nine_patch(to_canvas_item, rect, Rect2(Vector2.ZERO, TEX_SIZE), rid,
			Vector2(margin, margin), Vector2(margin, margin))
		return
	var blit := func(dst: Rect2, src: Rect2) -> void:
		if dst.size.x > 0.5 and dst.size.y > 0.5:
			RenderingServer.canvas_item_add_texture_rect_region(to_canvas_item, Rect2(o + dst.position, dst.size), rid, src)
	var corner := CORNER * k
	var band := BAND * k
	var crest_w := TOP_BAND.size.x * k
	var gem := LEFT_GEM.size * k
	var inset := 48.0 * k
	# Clean vellum first; the band, corners and crests overlap its edge.
	blit.call(Rect2(inset, inset, w - inset * 2.0, h - inset * 2.0), INTERIOR)
	# Top and bottom: plain runs stretched either side of the centred crest.
	var cx := w * 0.5 - crest_w * 0.5
	blit.call(Rect2(corner.x, 0, cx - corner.x, band), TOP_RUN)
	blit.call(Rect2(cx + crest_w, 0, w - corner.x - cx - crest_w, band), TOP_RUN_R)
	blit.call(Rect2(corner.x, h - band, cx - corner.x, band), BOTTOM_RUN)
	blit.call(Rect2(cx + crest_w, h - band, w - corner.x - cx - crest_w, band), BOTTOM_RUN_R)
	# Left and right: plain runs stretched above and below the centred gem.
	var gy := h * 0.5 - gem.y * 0.5
	blit.call(Rect2(0, corner.y, band, gy - corner.y), LEFT_RUN)
	blit.call(Rect2(0, gy + gem.y, band, h - corner.y - gy - gem.y), LEFT_RUN_B)
	blit.call(Rect2(w - band, corner.y, band, gy - corner.y), RIGHT_RUN)
	blit.call(Rect2(w - band, gy + gem.y, band, h - corner.y - gy - gem.y), RIGHT_RUN_B)
	# Corners at their painted proportions.
	blit.call(Rect2(0, 0, corner.x, corner.y), Rect2(0, 0, CORNER.x, CORNER.y))
	blit.call(Rect2(w - corner.x, 0, corner.x, corner.y), Rect2(TEX_SIZE.x - CORNER.x, 0, CORNER.x, CORNER.y))
	blit.call(Rect2(0, h - corner.y, corner.x, corner.y), Rect2(0, TEX_SIZE.y - CORNER.y, CORNER.x, CORNER.y))
	blit.call(Rect2(w - corner.x, h - corner.y, corner.x, corner.y), Rect2(TEX_SIZE.x - CORNER.x, TEX_SIZE.y - CORNER.y, CORNER.x, CORNER.y))
	# Crests and gems at their painted proportions, centred on each edge.
	blit.call(Rect2(cx, 0, crest_w, TOP_BAND.size.y * k), TOP_BAND)
	blit.call(Rect2(cx + (TOP_TIP.position.x - TOP_BAND.position.x) * k, TOP_TIP.position.y * k, TOP_TIP.size.x * k, TOP_TIP.size.y * k), TOP_TIP)
	blit.call(Rect2(cx, h - BOTTOM_BAND.size.y * k, crest_w, BOTTOM_BAND.size.y * k), BOTTOM_BAND)
	blit.call(Rect2(cx + (BOTTOM_TIP.position.x - BOTTOM_BAND.position.x) * k, h - (TEX_SIZE.y - BOTTOM_TIP.position.y) * k, BOTTOM_TIP.size.x * k, BOTTOM_TIP.size.y * k), BOTTOM_TIP)
	blit.call(Rect2(0, gy, gem.x, gem.y), LEFT_GEM)
	blit.call(Rect2(w - gem.x, gy, gem.x, gem.y), RIGHT_GEM)
