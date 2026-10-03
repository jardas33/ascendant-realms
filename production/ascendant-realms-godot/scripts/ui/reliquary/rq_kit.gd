extends RefCounted
class_name RqKit
## Reliquary UI kit: the single source of design tokens and the material
## painters every Reliquary control draws with. Art direction lives in
## docs/claude/UI_ART_PILLARS_R1.md; nothing in a screen script should invent
## a colour, size or edge treatment that is not named here.
##
## The interface is an Ascension relic. Its matter (iron, timber, basalt) and
## its edge metal change with the player's people; the Lume in its seams grows
## with the Age. Layout never changes between peoples or Ages.

# --- shared ink -------------------------------------------------------------
const TEXT := Color("ede3cf")
const TEXT_BRIGHT := Color("f6e8c4")
const TEXT_MUTED := Color("a79c88")
const TEXT_DIM := Color("7d7466")
const TEXT_GILT := Color("f1dfae")
const POSITIVE := Color("93b07a")
const NEGATIVE := Color("ff7a6a")
const MANA := Color("8fb8ff")
const HP_TOP := Color("b6e07a")
const HP_BOTTOM := Color("3b6a1e")
const MP_TOP := Color("9cc7ff")
const MP_BOTTOM := Color("294f93")
const WELL := Color("0d0b09")
const SHADOW := Color(0.0, 0.0, 0.0, 0.62)

# --- type scale (1080p reference) --------------------------------------------
const SIZE_NAME := 31
const SIZE_TITLE := 21
const SIZE_VALUE := 23
const SIZE_BODY := 16
const SIZE_SMALL := 15
const SIZE_CAPTION := 13

const FONT_DISPLAY := "res://assets/fonts/cinzel-latin-600-normal.woff2"
const FONT_DISPLAY_BOLD := "res://assets/fonts/cinzel-latin-700-normal.woff2"
const FONT_BODY := "res://assets/fonts/alegreya-sans-latin-400-normal.woff2"
const FONT_BODY_MEDIUM := "res://assets/fonts/alegreya-sans-latin-500-normal.woff2"
const FONT_BODY_BOLD := "res://assets/fonts/alegreya-sans-latin-700-normal.woff2"
const GLYPH_DIR := "res://assets/ui/kit/glyphs/"

# --- people's materials -------------------------------------------------------
# hi/mid/lo: chassis matter top to bottom. edge_*: the worked metal on joints.
# lume: the light in the seams. accent: the people's enamel.
const PEOPLES := {
	"barrosan": {
		"hi": Color("2b2d2f"), "mid": Color("1b1d1f"), "lo": Color("101113"),
		"edge_lo": Color("5a3f1a"), "edge_mid": Color("c99a4e"), "edge_hi": Color("f4dc9a"),
		"lume": Color("ffb547"), "lume_hi": Color("ffe2a0"), "accent": Color("8f2a22"),
		"cut": 30.0,
	},
	"lioraen": {
		"hi": Color("2a2a22"), "mid": Color("1b1c16"), "lo": Color("10110d"),
		"edge_lo": Color("2f4a3c"), "edge_mid": Color("6f9c7e"), "edge_hi": Color("cfe6c4"),
		"lume": Color("6fe3c2"), "lume_hi": Color("d4fff0"), "accent": Color("9c8a3a"),
		"cut": 22.0,
	},
	"vorthak": {
		"hi": Color("26232a"), "mid": Color("17151a"), "lo": Color("0d0c10"),
		"edge_lo": Color("2c2a30"), "edge_mid": Color("77737f"), "edge_hi": Color("d4d0dc"),
		"lume": Color("b07bff"), "lume_hi": Color("e6d4ff"), "accent": Color("9a1f24"),
		"cut": 34.0,
	},
}

# Every spell's glyph. Spells that share a gesture share a glyph; anything
# unlisted falls back to the Lume mark rather than a stray picture.
const ABILITY_GLYPHS := {
	"rally": "rally", "slam": "slam", "charge": "charge", "bolt": "bolt", "heal": "heal",
	"root": "root", "avatar": "avatar",
	"sig_bull": "bull", "sig_spring": "spring", "sig_ashglass": "shards", "sig_chains": "chains",
	"sig_moura": "moura", "sig_stoneskin": "ward", "sig_sunfire": "lance", "sig_pack": "paw",
	"sig_candles": "candle", "sig_entrudo": "mask",
	"bar_levy": "levy", "bar_horn": "horn", "lio_thorns": "thorns", "lio_bloom": "bloom",
	"vor_chains": "chains", "vor_nova": "nova", "grim_quake": "slam", "grim_rage": "fury",
	"syl_gold": "gold", "syl_mirror": "mirror", "kar_avalanche": "avalanche", "kar_bastion": "ward",
	"sun_rain": "spears", "sun_testudo": "hold", "wyl_leap": "moura", "wyl_frenzy": "paw",
	"hol_curse": "candle", "hol_drain": "drain", "fro_breath": "frost", "fro_masks": "mask",
}
const ORDER_GLYPHS := {"attack move": "attack", "stop": "stop", "hold": "hold", "patrol": "patrol"}
const AGE_TITLES := {1: "Founding", 2: "Iron", 3: "Lume"}

# Lume strength by Age: the same relic slowly wakes.
const AGE_LUME := {1: 0.45, 2: 0.75, 3: 1.0}

static var _fonts := {}
static var _grain: ImageTexture = null
static var _glyphs := {}
static var people := "barrosan"
static var age := 1


static func mat(key: String) -> Variant:
	var table: Dictionary = PEOPLES.get(people, PEOPLES["barrosan"])
	return table.get(key, PEOPLES["barrosan"][key])


static func ability_glyph(id: String) -> String:
	return String(ABILITY_GLYPHS.get(id, "lume"))


static func lume_strength() -> float:
	return float(AGE_LUME.get(clampi(age, 1, 3), 0.45))


static func font(path: String) -> Font:
	if _fonts.has(path):
		return _fonts[path]
	var f: Font = load(path) if ResourceLoader.exists(path) else ThemeDB.fallback_font
	_fonts[path] = f
	return f


static func display() -> Font:
	return font(FONT_DISPLAY)


static func body() -> Font:
	return font(FONT_BODY)


static func body_medium() -> Font:
	return font(FONT_BODY_MEDIUM)


static func glyph(name: String) -> Texture2D:
	if _glyphs.has(name):
		return _glyphs[name]
	var path := GLYPH_DIR + name + ".svg"
	var tex: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_glyphs[name] = tex
	return tex


static func label(text: String, size: int, color: Color, face: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", face if face else body())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.add_theme_constant_override("shadow_outline_size", 2)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


static func glyph_rect(name: String, px: float, tint: Color) -> TextureRect:
	var r := TextureRect.new()
	r.texture = glyph(name)
	r.custom_minimum_size = Vector2(px, px)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.modulate = tint
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


# --- geometry -----------------------------------------------------------------
## A rectangle with independently chamfered corners (tl, tr, br, bl).
static func chamfer(rect: Rect2, tl: float, tr: float, br: float, bl: float) -> PackedVector2Array:
	var p := rect.position
	var e := rect.end
	var pts := PackedVector2Array()
	pts.append(Vector2(p.x + tl, p.y))
	pts.append(Vector2(e.x - tr, p.y))
	if tr > 0.0:
		pts.append(Vector2(e.x, p.y + tr))
	pts.append(Vector2(e.x, e.y - br))
	if br > 0.0:
		pts.append(Vector2(e.x - br, e.y))
	pts.append(Vector2(p.x + bl, e.y))
	if bl > 0.0:
		pts.append(Vector2(p.x, e.y - bl))
	pts.append(Vector2(p.x, p.y + tl))
	if tl <= 0.0:
		pts.remove_at(pts.size() - 1)
	return pts


static func octagon(center: Vector2, radius: float) -> PackedVector2Array:
	# Flat-topped octagon with 29% corner cuts, matching the portrait medallion.
	var r := radius
	var c := r * 0.42
	return PackedVector2Array([
		center + Vector2(-r + c, -r), center + Vector2(r - c, -r),
		center + Vector2(r, -r + c), center + Vector2(r, r - c),
		center + Vector2(r - c, r), center + Vector2(-r + c, r),
		center + Vector2(-r, r - c), center + Vector2(-r, -r + c)])


static func inset_polygon(points: PackedVector2Array, amount: float) -> PackedVector2Array:
	var out := Geometry2D.offset_polygon(points, -amount, Geometry2D.JOIN_MITER)
	return out[0] if not out.is_empty() else points


# --- material painters -------------------------------------------------------
static func grain() -> ImageTexture:
	if _grain:
		return _grain
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.09
	noise.fractal_octaves = 3
	var mottle := FastNoiseLite.new()
	mottle.noise_type = FastNoiseLite.TYPE_SIMPLEX
	mottle.frequency = 0.012
	mottle.seed = 7
	var img := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	for y in 256:
		for x in 256:
			var fine := noise.get_noise_2d(x, y) * 0.5 + 0.5
			var broad := mottle.get_noise_2d(x, y * 2.0) * 0.5 + 0.5
			var v := clampf(fine * 0.55 + broad * 0.45, 0.0, 1.0)
			img.set_pixel(x, y, Color(v, v * 0.94, v * 0.86, 1.0))
	_grain = ImageTexture.create_from_image(img)
	return _grain


static func _uv(points: PackedVector2Array) -> PackedVector2Array:
	var uvs := PackedVector2Array()
	for p in points:
		uvs.append(p / 256.0)
	return uvs


## Forged chassis matter with a vertical falloff and hammered grain.
## The drawing CanvasItem must have texture_repeat enabled.
static func draw_matter(ci: CanvasItem, points: PackedVector2Array, alpha: float = 1.0) -> void:
	var top := 1e9
	var bottom := -1e9
	for p in points:
		top = minf(top, p.y)
		bottom = maxf(bottom, p.y)
	var span := maxf(1.0, bottom - top)
	var hi: Color = mat("hi")
	var mid: Color = mat("mid")
	var lo: Color = mat("lo")
	var colors := PackedColorArray()
	for p in points:
		var t := (p.y - top) / span
		var c := hi.lerp(mid, clampf(t / 0.38, 0.0, 1.0)) if t < 0.38 else mid.lerp(lo, (t - 0.38) / 0.62)
		c.a = alpha
		colors.append(c)
	ci.draw_polygon(points, colors)
	# Grain multiplies a soft hammered texture into the iron.
	var g := PackedColorArray()
	for p in points:
		g.append(Color(1.0, 1.0, 1.0, 0.07 * alpha))
	ci.draw_polygon(points, g, _uv(points), grain())


## Worked edge metal: a band from the outer silhouette to an inset copy.
## Brightest across the middle, dark at the ends, like a polished bevel.
static func draw_edge(ci: CanvasItem, outer: PackedVector2Array, width: float = 2.0) -> PackedVector2Array:
	var left := 1e9
	var right := -1e9
	for p in outer:
		left = minf(left, p.x)
		right = maxf(right, p.x)
	var span := maxf(1.0, right - left)
	var lo: Color = mat("edge_lo")
	var md: Color = mat("edge_mid")
	var hi: Color = mat("edge_hi")
	var colors := PackedColorArray()
	for p in outer:
		var t := absf((p.x - left) / span - 0.5) * 2.0
		colors.append(hi.lerp(md, clampf(t * 1.6, 0.0, 1.0)).lerp(lo, clampf((t - 0.7) / 0.3, 0.0, 1.0)))
	ci.draw_polygon(outer, colors)
	return inset_polygon(outer, width)


## The Lume seam: a hairline of light that fades at both ends.
static func draw_seam(ci: CanvasItem, a: Vector2, b: Vector2, strength: float = -1.0) -> void:
	var s := lume_strength() if strength < 0.0 else strength
	var lume: Color = mat("lume")
	var lume_hi: Color = mat("lume_hi")
	var steps := 12
	for layer in [[6.0, 0.06], [3.0, 0.18], [1.2, 0.95]]:
		var pts := PackedVector2Array()
		var cols := PackedColorArray()
		for i in steps + 1:
			var t := float(i) / steps
			pts.append(a.lerp(b, t))
			var fade := sin(t * PI)
			var c: Color = (lume.lerp(lume_hi, fade) if layer[0] < 2.0 else lume)
			c.a = float(layer[1]) * fade * s
			cols.append(c)
		ci.draw_polyline_colors(pts, cols, float(layer[0]), true)


static func draw_rivet(ci: CanvasItem, at: Vector2, r: float = 4.5) -> void:
	ci.draw_circle(at + Vector2(0, 1), r, Color(0, 0, 0, 0.7))
	ci.draw_circle(at, r, mat("edge_lo"))
	ci.draw_circle(at - Vector2(r * 0.15, r * 0.2), r * 0.72, mat("edge_mid"))
	ci.draw_circle(at - Vector2(r * 0.3, r * 0.35), r * 0.3, mat("edge_hi"))


static func draw_engraving(ci: CanvasItem, points: PackedVector2Array) -> void:
	# A cut line: dark groove with a faint lit lip beneath it.
	var closed := PackedVector2Array(points)
	closed.append(points[0])
	ci.draw_polyline(closed, Color(0, 0, 0, 0.55), 1.0, true)
	var lip := PackedVector2Array()
	for p in closed:
		lip.append(p + Vector2(0, 1))
	var lit: Color = mat("edge_hi")
	lit.a = 0.08
	ci.draw_polyline(lip, lit, 1.0, true)


## Complete chassis plate: drop shadow, edge metal, matter, engraving.
static func draw_plate(ci: CanvasItem, outer: PackedVector2Array, edge_width: float = 2.0, shadow: bool = true) -> PackedVector2Array:
	if shadow:
		var sh := PackedVector2Array()
		for p in outer:
			sh.append(p + Vector2(0, 6))
		ci.draw_colored_polygon(sh, Color(0, 0, 0, 0.45))
	var inner := draw_edge(ci, outer, edge_width)
	draw_matter(ci, inner)
	return inner
