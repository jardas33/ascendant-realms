extends RefCounted
class_name CodexKit
## Codex UI kit (art direction B, "War Codex"): the illuminated-manuscript
## style for the screens you read between battles: the star chart, the
## campaign map, the Chronicle. Same rules as RqKit: every colour, face and
## painter used by those screens is named here and nowhere else.
##
## Night vellum for skies and maps, oxblood leather for pages, gilt ink for
## rules and frames, vermilion for the first letter and for the one thing
## that needs the reader now. Glyphs are shared with the battle HUD.

# --- ink -----------------------------------------------------------------------
const NIGHT := Color("07080e")
const NIGHT_HI := Color("161a2e")
const LEATHER_HI := Color("35241a")
const LEATHER_MID := Color("25180f")
const LEATHER_LO := Color("160e09")
const GILT := Color("d9b25c")
const GILT_HI := Color("f6dc94")
const GILT_LO := Color("7a5a26")
const VERMILION := Color("d24a33")
const TEXT := Color("efe2c4")
const TEXT_MUTED := Color("b8a687")
const TEXT_DIM := Color("7f705b")
const POSITIVE := Color("9cc47e")
const STAR_COLD := Color("6c7894")

# Illuminators' pigments, one per path of the star chart. The people's own
# path takes its Lume colour from RqKit.
const PATH_PIGMENTS := {
	"combat": Color("e0603f"), "defense": Color("5b8ade"), "mobility": Color("e0ab4f"),
	"active": Color("ae82ec"), "magic": Color("63bdf0"), "command": Color("e0839f"),
	"economy": Color("62c792"),
}
const PATH_NAMES := {
	"combat": "Blade", "defense": "Aegis", "mobility": "Wind", "active": "Voice",
	"magic": "Lume", "command": "Banner", "economy": "Hearth", "race": "Blood",
}
const PATH_GLYPHS := {
	"combat": "attack", "defense": "ward", "mobility": "charge", "active": "horn",
	"magic": "lume", "command": "rally", "economy": "gold", "race": "moura",
}

# Glyph for a passive star, by the first thing it changes.
const EFFECT_GLYPHS := {
	"dmg": "attack", "attack_speed": "fury", "hp": "heal", "armor": "ward", "speed": "charge",
	"vision": "mask", "range": "lance", "mana": "lume", "mana_regen": "spring",
	"aura_dmg": "spears", "aura_armor": "ward", "aura_range": "horn", "heal_power": "heal",
	"gather_bonus": "worker", "lifesteal": "drain", "bounty": "gold", "start_gold": "gold",
	"regen": "bloom", "build_speed": "stone", "train_speed": "levy", "execute": "slam",
	"cleave": "shards", "unstoppable": "bull", "last_stand": "hold", "fortify_boost": "stone",
	"bloom_boost": "bloom", "aura_siege": "army",
}

# --- type ----------------------------------------------------------------------
const FONT_DISPLAY := "res://assets/fonts/cinzel-latin-600-normal.woff2"
const FONT_DISPLAY_BOLD := "res://assets/fonts/cinzel-latin-700-normal.woff2"
const FONT_SERIF := "res://assets/fonts/cormorant-garamond-latin-600-normal.woff2"
const FONT_SERIF_ITALIC := "res://assets/fonts/cormorant-garamond-latin-500-italic.woff2"
const FONT_SERIF_ITALIC_BOLD := "res://assets/fonts/cormorant-garamond-latin-600-italic.woff2"
const FONT_BODY := "res://assets/fonts/alegreya-sans-latin-400-normal.woff2"
const FONT_BODY_BOLD := "res://assets/fonts/alegreya-sans-latin-700-normal.woff2"


static func font(path: String) -> Font:
	return RqKit.font(path)


static func glyph(name: String) -> Texture2D:
	return RqKit.glyph(name)


static func pigment(path: String) -> Color:
	if path == "race":
		return RqKit.mat("lume")
	return PATH_PIGMENTS.get(path, GILT)


static func star_glyph(node: Dictionary) -> String:
	var effect: Dictionary = node.get("effect", {})
	if effect.has("ability"):
		var ability = effect["ability"]
		return RqKit.ability_glyph(String(ability.get("id", "")) if ability is Dictionary else str(ability))
	for group in ["stat", "flag"]:
		var d: Dictionary = effect.get(group, {})
		for key in d.keys():
			if EFFECT_GLYPHS.has(key):
				return EFFECT_GLYPHS[key]
	return PATH_GLYPHS.get(String(node.get("branch", "")), "lume")


static func label(text: String, size: int, color: Color, face_path: String = FONT_BODY) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font(face_path))
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	l.add_theme_constant_override("shadow_offset_y", 1)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## A title whose first letter is a larger vermilion capital, as in a codex.
static func illuminated(text: String, size: int, color: Color = TEXT) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_theme_font_override("normal_font", font(FONT_DISPLAY))
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_color_override("default_color", color)
	set_illuminated(r, text, size)
	return r


static func set_illuminated(r: RichTextLabel, text: String, size: int) -> void:
	if text.is_empty():
		r.text = ""
		return
	r.text = "[font_size=%d][color=#%s]%s[/color][/font_size]%s" % [int(size * 1.38), VERMILION.to_html(false), text.substr(0, 1), text.substr(1)]


# --- painters --------------------------------------------------------------------
## Oxblood leather page with a double gilt hairline frame and corner lozenges.
static func draw_page(ci: CanvasItem, rect: Rect2, frame_inset: float = 10.0) -> void:
	ci.draw_rect(rect.grow(3.0), Color(0, 0, 0, 0.45))
	var pts := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	var cols := PackedColorArray([LEATHER_HI, LEATHER_HI.lerp(LEATHER_MID, 0.6), LEATHER_LO, LEATHER_MID])
	ci.draw_polygon(pts, cols)
	var g := PackedColorArray()
	var uvs := PackedVector2Array()
	for p in pts:
		g.append(Color(1, 0.9, 0.8, 0.09))
		uvs.append(p / 256.0)
	ci.draw_polygon(pts, g, uvs, RqKit.grain())
	# Edge darkening, like handled leather.
	for i in 6:
		var a := 0.07 - i * 0.01
		ci.draw_rect(rect.grow(-i * 3.0), Color(0, 0, 0, a), false, 3.0)
	var outer := rect.grow(-frame_inset)
	var inner := rect.grow(-frame_inset - 5.0)
	ci.draw_rect(outer, Color(GILT.r, GILT.g, GILT.b, 0.75), false, 1.2)
	ci.draw_rect(inner, Color(GILT.r, GILT.g, GILT.b, 0.35), false, 1.0)
	for c in [outer.position, Vector2(outer.end.x, outer.position.y), outer.end, Vector2(outer.position.x, outer.end.y)]:
		draw_lozenge(ci, c, 6.0, GILT_HI)


static func draw_lozenge(ci: CanvasItem, at: Vector2, r: float, color: Color) -> void:
	ci.draw_colored_polygon(PackedVector2Array([at + Vector2(0, -r), at + Vector2(r, 0), at + Vector2(0, r), at + Vector2(-r, 0)]), color)
	ci.draw_colored_polygon(PackedVector2Array([at + Vector2(0, -r * 0.4), at + Vector2(r * 0.4, 0), at + Vector2(0, r * 0.4), at + Vector2(-r * 0.4, 0)]), LEATHER_LO)


## A gilt rule fading at both ends with a lozenge at its middle.
static func draw_rule(ci: CanvasItem, a: Vector2, b: Vector2, lozenge: bool = true) -> void:
	var steps := 16
	var pts := PackedVector2Array()
	var cols := PackedColorArray()
	for i in steps + 1:
		var t := float(i) / steps
		pts.append(a.lerp(b, t))
		var c := GILT
		c.a = 0.85 * sin(t * PI)
		cols.append(c)
	ci.draw_polyline_colors(pts, cols, 1.2, true)
	if lozenge:
		draw_lozenge(ci, (a + b) * 0.5, 4.5, GILT_HI)


## A vermilion wax seal with a gilt number: the reader's spendable points.
static func draw_seal(ci: CanvasItem, center: Vector2, r: float, text: String, pulse: float = 0.0) -> void:
	var lobes := PackedVector2Array()
	for i in 48:
		var a := TAU * i / 48.0
		var wob := 1.0 + 0.05 * sin(a * 7.0) + 0.03 * sin(a * 13.0 + 1.3)
		lobes.append(center + Vector2(cos(a), sin(a)) * r * wob)
	ci.draw_colored_polygon(lobes, Color(0, 0, 0, 0.5))
	var body := PackedVector2Array()
	for p in lobes:
		body.append(center + (p - center) * 0.97 + Vector2(0, -1.5))
	ci.draw_colored_polygon(body, VERMILION.darkened(0.35))
	ci.draw_circle(center + Vector2(0, -1.5), r * 0.78, VERMILION.darkened(0.15))
	ci.draw_arc(center + Vector2(0, -1.5), r * 0.78, 0, TAU, 48, Color(0, 0, 0, 0.35), 2.0, true)
	ci.draw_arc(center + Vector2(-r * 0.12, -r * 0.18), r * 0.6, PI * 1.05, PI * 1.6, 16, Color(1, 0.8, 0.7, 0.25), 2.0, true)
	if pulse > 0.0:
		ci.draw_arc(center, r * (1.08 + 0.1 * pulse), 0, TAU, 48, Color(GILT_HI.r, GILT_HI.g, GILT_HI.b, 0.5 * (1.0 - pulse)), 2.0, true)
	var f := font(FONT_DISPLAY_BOLD)
	var fs := int(r * 0.95)
	var tw := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var base := center + Vector2(-tw * 0.5, fs * 0.36 - 1.5)
	ci.draw_string(f, base + Vector2(0, 1.5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, 0.5))
	ci.draw_string(f, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, GILT_HI)


## A four-pointed star: the chart's mark for a single power.
static func star_points(center: Vector2, r: float, inner: float = 0.28, points: int = 4, spin: float = 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in points * 2:
		var a := spin - PI * 0.5 + PI * i / points
		var rr := r if i % 2 == 0 else r * inner
		pts.append(center + Vector2(cos(a), sin(a)) * rr)
	return pts
