extends Node2D
## Plan 432: Codex's painted HUD frame (bronze, iron, bronze) laid along a
## forged panel's outline, with painted gem corners where the outline turns a
## convex corner. hud_forged_skin.paint() adds one under each panel it paints,
## so every forged panel wears the same painted metal. A Node2D, so containers
## never move it, and it has no material, so the panel's shader skips it.

const RAIL_PATH := "res://assets/ui/hud_kit/rail.png"
const FRAME_PATH := "res://assets/ui/hud_kit/frame.png"
static var _rail: Texture2D = null
static var _frame: Texture2D = null
const RAIL_BAND := 33.0     # rail.png rows that hold the rail
const CORNER_SRC := 80.0    # corner piece size in frame.png
const CORNER_REACH := 46.0  # longest chamfer still treated as one corner

## Plan 469: the garnets in the painted corners take the player's people's
## colour (violet for the Vorthak, green for the Lioraen ...). -1 keeps the
## painted red. The recoloured corners are one small atlas built once.
static var gem_hue := -1.0
static var _corner_atlas: Texture2D = null
static var _corner_atlas_hue := -2.0

static func set_people_color(race: String, col: Color) -> void:
	var hue := -1.0
	if race != "barrosan" and col.s >= 0.25:
		hue = col.h
	gem_hue = hue


static func _tinted_corners(frame: Texture2D) -> Texture2D:
	if _corner_atlas != null and is_equal_approx(_corner_atlas_hue, gem_hue):
		return _corner_atlas
	var src := frame.get_image()
	if src == null:
		return null
	if src.is_compressed():
		src.decompress()
	src.convert(Image.FORMAT_RGBA8)
	var fw := src.get_width()
	var fh := src.get_height()
	var c := int(CORNER_SRC)
	var atlas := Image.create(c * 2, c * 2, false, Image.FORMAT_RGBA8)
	var origins := [Vector2i(0, 0), Vector2i(fw - c, 0), Vector2i(fw - c, fh - c), Vector2i(0, fh - c)]
	var dests := [Vector2i(0, 0), Vector2i(c, 0), Vector2i(c, c), Vector2i(0, c)]
	for k in 4:
		atlas.blit_rect(src, Rect2i(origins[k], Vector2i(c, c)), dests[k])
	for y in c * 2:
		for x in c * 2:
			var p := atlas.get_pixel(x, y)
			if p.a > 0.05 and p.s > 0.45 and p.v > 0.18 and (p.h < 0.045 or p.h > 0.93):
				atlas.set_pixel(x, y, Color.from_hsv(gem_hue, minf(1.0, p.s * 0.9), minf(1.0, p.v * 1.08), p.a))
	atlas.generate_mipmaps()
	_corner_atlas = ImageTexture.create_from_image(atlas)
	_corner_atlas_hue = gem_hue
	return _corner_atlas


var outline := PackedVector2Array()
var thickness := 12.0
var tint := Color.WHITE
var corners := []  # [Vector2 square corner, int quadrant 0 tl, 1 tr, 2 br, 3 bl]


func _init() -> void:
	texture_repeat = CanvasItem.TEXTURE_REPEAT_MIRROR
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


func set_outline(points: PackedVector2Array, rail_thickness: float, color := Color.WHITE) -> void:
	if points == outline and is_equal_approx(rail_thickness, thickness) and color == tint:
		return
	outline = points
	thickness = rail_thickness
	tint = color
	corners = find_corners(points)
	queue_redraw()


func corner_size() -> float:
	var box := Rect2(outline[0], Vector2.ZERO) if outline.size() > 0 else Rect2()
	for p in outline:
		box = box.expand(p)
	return minf(CORNER_SRC * thickness / RAIL_BAND, minf(box.size.x, box.size.y) * 0.42)


## Convex square corners and short chamfers between an axis-aligned pair of
## edges, as the square corner they cut and which way the inside lies.
static func find_corners(pts: PackedVector2Array) -> Array:
	var out := []
	var n := pts.size()
	if n < 3:
		return out
	for i in n:
		var a := pts[(i - 1 + n) % n]
		var b := pts[i]
		var c := pts[(i + 1) % n]
		var d := pts[(i + 2) % n]
		var corner = null
		var reach := 6.0
		if _axis(b - a) and _axis(c - b) and not _same_axis(b - a, c - b):
			corner = b
		elif not _axis(c - b) and b.distance_to(c) <= CORNER_REACH and _axis(b - a) and _axis(d - c) and not _same_axis(b - a, d - c):
			corner = (Vector2(c.x, b.y) if absf((b - a).y) < 0.5 else Vector2(b.x, c.y))
			reach = b.distance_to(c) * 0.75 + 3.0
		if corner == null:
			continue
		var q := _quadrant(pts, corner, reach)
		if q >= 0:
			out.append([corner, q])
	return out


static func _axis(v: Vector2) -> bool:
	return v.length() > 0.5 and (absf(v.x) < 0.5 or absf(v.y) < 0.5)


static func _same_axis(u: Vector2, v: Vector2) -> bool:
	return (absf(u.x) < 0.5) == (absf(v.x) < 0.5)


## Which quadrant from the corner lies inside the outline (only one may).
static func _quadrant(pts: PackedVector2Array, corner: Vector2, reach: float) -> int:
	var probes := [Vector2(reach, reach), Vector2(-reach, reach), Vector2(-reach, -reach), Vector2(reach, -reach)]
	var found := -1
	for q in 4:
		if Geometry2D.is_point_in_polygon(corner + probes[q], pts):
			if found >= 0:
				return -1
			found = q
	return found


func _draw() -> void:
	var n := outline.size()
	if n < 3 or thickness <= 0.0:
		return
	# Loaded on first use, so a checkout that has not imported the kit yet
	# still runs (the shader rim shows alone).
	if _rail == null and ResourceLoader.exists(RAIL_PATH):
		_rail = load(RAIL_PATH)
	if _frame == null and ResourceLoader.exists(FRAME_PATH):
		_frame = load(FRAME_PATH)
	if _rail == null or _frame == null:
		return
	var inner := PackedVector2Array()
	inner.resize(n)
	for i in n:
		var prev := outline[(i - 1 + n) % n]
		var cur := outline[i]
		var nxt := outline[(i + 1) % n]
		var n0 := _inward(prev, cur)
		var n1 := _inward(cur, nxt)
		var miter := (n0 + n1).normalized()
		var denom := maxf(0.35, miter.dot(n1))
		inner[i] = cur + miter * (thickness / denom)
	var repeat_len := _rail.get_width() * thickness / RAIL_BAND
	var run := 0.0
	for i in n:
		var a := outline[i]
		var b := outline[(i + 1) % n]
		var length := a.distance_to(b)
		if length < 0.5:
			continue
		var dir := (b - a) / length
		var qa := inner[i]
		var qb := inner[(i + 1) % n]
		var uv := PackedVector2Array([
			Vector2(run / repeat_len, 0.0),
			Vector2((run + length) / repeat_len, 0.0),
			Vector2((run + (qb - a).dot(dir)) / repeat_len, 1.0),
			Vector2((run + (qa - a).dot(dir)) / repeat_len, 1.0)])
		draw_primitive(PackedVector2Array([a, b, qb, qa]), PackedColorArray([tint, tint, tint, tint]), uv, _rail)
		run += length
	var size := corner_size()
	var fw := float(_frame.get_width())
	var fh := float(_frame.get_height())
	var src_rects := [Rect2(0, 0, CORNER_SRC, CORNER_SRC), Rect2(fw - CORNER_SRC, 0, CORNER_SRC, CORNER_SRC),
		Rect2(fw - CORNER_SRC, fh - CORNER_SRC, CORNER_SRC, CORNER_SRC), Rect2(0, fh - CORNER_SRC, CORNER_SRC, CORNER_SRC)]
	var offsets := [Vector2(0, 0), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, -1)]
	var corner_tex: Texture2D = _frame
	if gem_hue >= 0.0:
		var atlas := _tinted_corners(_frame)
		if atlas != null:
			corner_tex = atlas
			src_rects = [Rect2(0, 0, CORNER_SRC, CORNER_SRC), Rect2(CORNER_SRC, 0, CORNER_SRC, CORNER_SRC),
				Rect2(CORNER_SRC, CORNER_SRC, CORNER_SRC, CORNER_SRC), Rect2(0, CORNER_SRC, CORNER_SRC, CORNER_SRC)]
	# The frame art keeps a few pixels of air round its outside rail.
	var air := 5.0 * size / CORNER_SRC
	var nudges := [Vector2(-air, -air), Vector2(air, -air), Vector2(air, air), Vector2(-air, air)]
	for c in corners:
		var q: int = c[1]
		var pos: Vector2 = c[0] + offsets[q] * size + nudges[q]
		draw_texture_rect_region(corner_tex, Rect2(pos, Vector2(size, size)), src_rects[q], tint)


func _inward(a: Vector2, b: Vector2) -> Vector2:
	var d := (b - a).normalized()
	var nrm := Vector2(-d.y, d.x)
	var mid := (a + b) * 0.5
	if Geometry2D.is_point_in_polygon(mid + nrm * 2.0, outline):
		return nrm
	return -nrm
