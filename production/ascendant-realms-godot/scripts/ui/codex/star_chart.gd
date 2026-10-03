extends Control
## The Star Chart: the hero's skill constellation, drawn as an illuminated
## sky chart (art direction B). Eight paths fan out from the hero's crest;
## each power is a star; keystones sit on the two gilt Ascension rings.
## SkillDefs and ProfileManager stay the authorities; this file only lays
## the stars out, draws them and routes clicks.

const SECTORS := ["combat", "defense", "mobility", "active", "magic", "command", "economy", "race"]
const PATH_HINTS := {
	"combat": "attack and fury", "defense": "health and armour", "mobility": "speed and sight",
	"active": "spells you cast", "magic": "mana and Lume", "command": "auras for your army",
	"economy": "workers and gold", "race": "your people's gift",
}
const R0 := 240.0           # radius of the first ring of stars
const RING_STEP := 70.0     # distance between rings
const LATERAL := 96.0       # arc distance between stars on one ring
const PAGE_WIDTH := 452.0
const STAR_R := 15.0
const KEYSTONE_R := 24.0
const SPELL_R := 18.0
const LABEL_ZOOM := 0.86    # below this only notable stars keep their names

var _nodes: Array = []
var _layout := {}           # id -> Vector2 in chart space
var _depth := {}            # id -> ring index
var _children := {}         # id -> Array of child ids
var _max_depth := 0
var _selected_id := ""
var _hover_id := ""
var _zoom := 0.7
var _pan := Vector2.ZERO
var _fly: Tween
var _t := 0.0
var _bursts: Array = []
var _seal_pulse := -1.0
var _sky: Array = []
var _last_click_ms := 0
var _last_click_id := ""
var _fitted := false
var _label_rects: Array[Rect2] = []

var _view: Control
var _page: Control
var _page_body: VBoxContainer
var _title: RichTextLabel
var _subtitle: Label
var _claim: Button
var _status: Label
var _crest: TextureRect
var _veil: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	RqKit.people = _race() if _race() in RqKit.PEOPLES else "barrosan"
	_load_nodes()
	_layout_chart()
	_build()
	ProfileManager.profile_changed.connect(_on_profile_changed)
	resized.connect(_on_resized)
	_seed_sky()
	call_deferred("_fit_view", false)
	_show_page()


# --- data ---------------------------------------------------------------------
func _hero() -> Dictionary:
	return ProfileManager.hero()


func _race() -> String:
	return String(_hero().get("race", ""))


func _load_nodes() -> void:
	_nodes.clear()
	for n in SkillDefs.get_tree():
		var race := String(n.get("race", ""))
		if race != "" and race != _race():
			continue
		_nodes.append(n)


func _find(id: String) -> Dictionary:
	for n in _nodes:
		if String(n.get("id", "")) == id:
			return n
	return {}


func _owned(id: String) -> bool:
	return id in _hero().get("skills", [])


func _points() -> int:
	return int(_hero().get("skill_points", 0))


func _state(n: Dictionary) -> String:
	var id := String(n.get("id", ""))
	if _owned(id):
		return "UNLOCKED"
	for req in n.get("req", []):
		if not _owned(String(req)):
			return "LOCKED"
	return "PURCHASABLE" if _points() >= int(n.get("cost", 1)) else "OPEN"


# --- layout -------------------------------------------------------------------
## Rings come from the longest chain of prerequisites, so a star never sits on
## a line it does not belong to. Stars on one ring spread sideways, ordered by
## where their parents sit, so links rarely cross.
func _layout_chart() -> void:
	_layout.clear()
	_depth.clear()
	_children.clear()
	_max_depth = 0
	for n in _nodes:
		_children[String(n["id"])] = []
	for n in _nodes:
		for req in n.get("req", []):
			if _children.has(String(req)):
				_children[String(req)].append(String(n["id"]))
	for n in _nodes:
		_depth_of(String(n["id"]))
	for sector in SECTORS.size():
		var path: String = SECTORS[sector]
		var centre := -PI * 0.5 + TAU * sector / SECTORS.size()
		var lateral := {}   # id -> lateral offset in px
		var by_ring := {}
		for n in _nodes:
			if String(n.get("branch", "")) != path:
				continue
			var d := int(_depth[String(n["id"])])
			if not by_ring.has(d):
				by_ring[d] = []
			by_ring[d].append(n)
		var rings := by_ring.keys()
		rings.sort()
		for d in rings:
			var ring: Array = by_ring[d]
			var keyed := []
			for n in ring:
				var reqs: Array = n.get("req", [])
				var bary := 0.0
				var count := 0
				for req in reqs:
					if lateral.has(String(req)):
						bary += float(lateral[String(req)])
						count += 1
				var pos: Vector2 = n.get("pos", Vector2.ZERO)
				var key := (bary / count) if count > 0 else (pos.x - floorf(pos.x)) * 100.0 + pos.x * 10.0
				keyed.append([key + pos.y * 0.01 + (pos.x - floorf(pos.x)) * 2.0, n])
			keyed.sort_custom(func(a, b): return a[0] < b[0])
			var span := (keyed.size() - 1) * LATERAL
			for i in keyed.size():
				var n: Dictionary = keyed[i][1]
				var off := -span * 0.5 + i * LATERAL
				var id := String(n["id"])
				lateral[id] = off
				var r: float = R0 + int(d) * RING_STEP
				var a: float = centre + off / r
				_layout[id] = Vector2(cos(a), sin(a)) * r


func _depth_of(id: String) -> int:
	if _depth.has(id):
		return int(_depth[id])
	_depth[id] = 0
	var n := _find(id)
	var d := 0
	for req in n.get("req", []):
		if _children.has(String(req)):
			d = maxi(d, _depth_of(String(req)) + 1)
	_depth[id] = d
	_max_depth = maxi(_max_depth, d)
	return d


func _outer_radius() -> float:
	return R0 + _max_depth * RING_STEP


func _sector_angle(path: String) -> float:
	return -PI * 0.5 + TAU * SECTORS.find(path) / SECTORS.size()


# --- view transform -----------------------------------------------------------
func _origin() -> Vector2:
	return _view.size * 0.5 + _pan


func _to_screen(p: Vector2) -> Vector2:
	return _origin() + p * _zoom


func _to_chart(s: Vector2) -> Vector2:
	return (s - _origin()) / _zoom


func _star_radius(n: Dictionary) -> float:
	var r := STAR_R
	if n.get("keystone", false):
		r = KEYSTONE_R
	elif n.get("effect", {}).has("ability"):
		r = SPELL_R
	return r * pow(_zoom, 0.55)


func _fit_view(animate: bool) -> void:
	if not is_instance_valid(_view) or _view.size.x < 10.0:
		return
	_fitted = true
	var reach := _outer_radius() + 150.0
	var z := clampf(minf(_view.size.x, _view.size.y - 40.0) / (2.0 * reach), 0.35, 1.0)
	_fly_to(Vector2(0.0, 20.0 / z), z, animate)


func _fly_to(chart_point: Vector2, zoom: float, animate: bool = true) -> void:
	var target_pan := -chart_point * zoom
	if _fly and _fly.is_valid():
		_fly.kill()
	if not animate:
		_zoom = zoom
		_pan = target_pan
		_view.queue_redraw()
		return
	_fly = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_fly.tween_property(self, "_zoom", zoom, 0.55)
	_fly.tween_property(self, "_pan", target_pan, 0.55)


func _fly_to_path(path: String) -> void:
	Sfx.play("select")
	var a := _sector_angle(path)
	var mid := R0 + _max_depth * RING_STEP * 0.55
	_fly_to(Vector2(cos(a), sin(a)) * mid, 1.0)


func _on_resized() -> void:
	_layout_screen()
	if not _fitted:
		_fit_view(false)


# --- screen -------------------------------------------------------------------
func _build() -> void:
	_view = Control.new()
	_view.name = "ChartView"
	_view.clip_contents = true
	_view.mouse_filter = Control.MOUSE_FILTER_STOP
	_view.draw.connect(_draw_chart)
	_view.gui_input.connect(_on_view_input)
	_view.mouse_exited.connect(func():
		_hover_id = ""
		_view.queue_redraw())
	add_child(_view)
	_crest = TextureRect.new()
	_crest.name = "HubCrest"
	_crest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_crest.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var crest_file := String({"barrosan": "res://assets/ui/barrosan_command_crest_i2.png", "lioraen": "res://assets/ui/faction_crests/astra_r1/lioraen.png", "vorthak": "res://assets/ui/faction_crests/astra_r1/vorthak.png"}.get(_race(), ""))
	if not crest_file.is_empty() and ResourceLoader.exists(crest_file):
		_crest.texture = load(crest_file)
	_view.add_child(_crest)
	var veil := Control.new()
	veil.name = "Veil"
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	veil.draw.connect(func(): _draw_edges_fade(veil))
	_view.add_child(veil)
	_veil = veil

	var header := VBoxContainer.new()
	header.name = "Header"
	header.position = Vector2(44, 26)
	header.add_theme_constant_override("separation", 0)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	header.add_child(CodexKit.illuminated("The Star Chart", 40, CodexKit.GILT_HI))
	var who := String(_hero().get("name", "Your hero"))
	var people := _race().capitalize() if not _race().is_empty() else "No people chosen"
	_subtitle = CodexKit.label("%s  ·  %s  ·  level %d" % [who, people, int(_hero().get("level", 1))], 22, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
	header.add_child(_subtitle)

	_status = CodexKit.label("Scroll to zoom  ·  drag to wander  ·  click a star to read it", 18, CodexKit.TEXT_DIM, CodexKit.FONT_SERIF_ITALIC)
	_status.name = "ChartHint"
	add_child(_status)

	_page = Control.new()
	_page.name = "CodexPage"
	_page.mouse_filter = Control.MOUSE_FILTER_STOP
	_page.draw.connect(func(): CodexKit.draw_page(_page, Rect2(Vector2.ZERO, _page.size)))
	add_child(_page)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 30)
	_page.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 0)
	margin.add_child(column)
	_page_body = VBoxContainer.new()
	_page_body.name = "PageBody"
	_page_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_page_body.add_theme_constant_override("separation", 12)
	column.add_child(_page_body)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	column.add_child(actions)
	_claim = Button.new()
	_claim.set_script(load("res://scripts/ui/codex/codex_button.gd"))
	_claim.name = "ClaimButton"
	_claim.primary = true
	_claim.custom_minimum_size = Vector2(0, 52)
	_claim.add_theme_font_size_override("font_size", 19)
	_claim.pressed.connect(_claim_selected)
	actions.add_child(_claim)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	actions.add_child(row)
	var back := Button.new()
	back.set_script(load("res://scripts/ui/codex/codex_button.gd"))
	back.name = "BackToHero"
	back.text = "Back to hero"
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(func(): _goto("res://scenes/ui/hero_sheet.tscn"))
	row.add_child(back)
	var respec := Button.new()
	respec.set_script(load("res://scripts/ui/codex/codex_button.gd"))
	respec.name = "Respec"
	respec.text = "Unlearn all"
	respec.tooltip_text = "Return every claimed star and get all their points back."
	respec.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	respec.pressed.connect(_on_respec)
	row.add_child(respec)
	_layout_screen()


func _layout_screen() -> void:
	if not is_instance_valid(_page):
		return
	var vp := size
	var page_w := clampf(vp.x * 0.25, 400.0, PAGE_WIDTH)
	_page.position = Vector2(vp.x - page_w - 24.0, 24.0)
	_page.size = Vector2(page_w, vp.y - 48.0)
	_view.position = Vector2.ZERO
	_view.size = Vector2(_page.position.x - 8.0, vp.y)
	_status.position = Vector2(44.0, vp.y - 56.0)
	_page.queue_redraw()
	_view.queue_redraw()
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	if _seal_pulse >= 0.0:
		_seal_pulse += delta * 1.5
		if _seal_pulse > 1.0:
			_seal_pulse = -1.0
	var live: Array = []
	for b in _bursts:
		if _t - float(b["t"]) < 1.2:
			live.append(b)
	_bursts = live
	if is_instance_valid(_view):
		_view.queue_redraw()


func _draw() -> void:
	# Night vellum behind everything; the chart view draws the sky over it.
	draw_rect(Rect2(Vector2.ZERO, size), CodexKit.NIGHT)


# --- sky ----------------------------------------------------------------------
func _seed_sky() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	_sky.clear()
	for i in 520:
		_sky.append([Vector2(rng.randf_range(-1.2, 1.2), rng.randf_range(-1.2, 1.2)), rng.randf_range(0.4, 1.5), rng.randf() * TAU, rng.randf_range(0.15, 0.55)])


func _draw_sky() -> void:
	var v := _view
	var c := _origin()
	# A cold glow pooled around the hero, fading to the night at the edges.
	for i in 14:
		var r := (_outer_radius() + 260.0) * _zoom * (1.0 - i / 14.0)
		v.draw_circle(c, r, Color(CodexKit.NIGHT_HI.r, CodexKit.NIGHT_HI.g, CodexKit.NIGHT_HI.b, 0.07))
	var lume: Color = RqKit.mat("lume")
	for i in 6:
		v.draw_circle(c, (R0 * 0.9 - i * 14.0) * _zoom, Color(lume.r, lume.g, lume.b, 0.018))
	var extent := maxf(v.size.x, v.size.y)
	for s in _sky:
		var p: Vector2 = v.size * 0.5 + _pan * 0.25 + s[0] * extent * 0.62
		if p.x < -4 or p.y < -4 or p.x > v.size.x + 4 or p.y > v.size.y + 4:
			continue
		var tw := 0.6 + 0.4 * sin(_t * 0.7 + float(s[2]))
		v.draw_circle(p, float(s[1]), Color(0.85, 0.88, 1.0, float(s[3]) * tw))


# --- chart --------------------------------------------------------------------
func _draw_chart() -> void:
	var v := _view
	_draw_sky()
	var c := _origin()
	var outer := _outer_radius()
	var gilt := CodexKit.GILT
	# Rings: hairlines for each step, gilt Ascension rings where keystones sit.
	for d in _max_depth + 1:
		var r := (R0 + d * RING_STEP) * _zoom
		var keyring := _is_keystone_ring(d)
		var col := Color(gilt.r, gilt.g, gilt.b, 0.32 if keyring else 0.06)
		v.draw_arc(c, r, 0, TAU, 160, col, 1.4 if keyring else 1.0, true)
		if keyring:
			for k in 72:
				var a := TAU * k / 72.0
				var tick_len := 6.0 if k % 9 == 0 else 3.0
				v.draw_line(c + Vector2(cos(a), sin(a)) * (r - tick_len), c + Vector2(cos(a), sin(a)) * (r + tick_len), Color(gilt.r, gilt.g, gilt.b, 0.28), 1.0, true)
	# The outer rim, like the limb of an astrolabe.
	var rim := (outer + 46.0) * _zoom
	v.draw_arc(c, rim, 0, TAU, 200, Color(gilt.r, gilt.g, gilt.b, 0.42), 1.5, true)
	v.draw_arc(c, rim + 6.0 * _zoom, 0, TAU, 200, Color(gilt.r, gilt.g, gilt.b, 0.18), 1.0, true)
	# Sector dividers.
	for i in SECTORS.size():
		var a := -PI * 0.5 + TAU * (i + 0.5) / SECTORS.size()
		var dir := Vector2(cos(a), sin(a))
		_dashed(v, c + dir * R0 * 0.62 * _zoom, c + dir * rim, Color(gilt.r, gilt.g, gilt.b, 0.12))
	# Links first, then stars, then names on top.
	for n in _nodes:
		var id := String(n["id"])
		for req in n.get("req", []):
			if _layout.has(String(req)):
				_draw_link(String(req), id)
	_draw_hub(c)
	for n in _nodes:
		_draw_star(n)
	for b in _bursts:
		var k := (_t - float(b["t"])) / 1.2
		var p := _to_screen(b["pos"])
		var col: Color = b["col"]
		for ring in 3:
			var kk := clampf(k - ring * 0.12, 0.0, 1.0)
			v.draw_arc(p, (20.0 + 90.0 * kk) * _zoom, 0, TAU, 48, Color(col.r, col.g, col.b, 0.7 * (1.0 - kk)), 2.0, true)
	_label_rects.clear()
	for path in SECTORS:
		_draw_path_name(path)
	# Names in priority order; a name that would overlap one already placed
	# waits until the reader zooms in.
	var order := _nodes.duplicate()
	order.sort_custom(func(a, b): return _label_rank(a) > _label_rank(b))
	for n in order:
		_draw_star_name(n)
	if is_instance_valid(_veil):
		_veil.queue_redraw()


func _is_keystone_ring(d: int) -> bool:
	for n in _nodes:
		if n.get("keystone", false) and int(_depth[String(n["id"])]) == d and String(n.get("branch", "")) != "race":
			return true
	return false


func _dashed(v: Control, a: Vector2, b: Vector2, col: Color) -> void:
	var seg_len := a.distance_to(b)
	var dir := (b - a) / maxf(seg_len, 0.001)
	var s := 0.0
	while s < seg_len:
		v.draw_line(a + dir * s, a + dir * minf(s + 6.0, seg_len), col, 1.0, true)
		s += 12.0


func _draw_hub(c: Vector2) -> void:
	var v := _view
	var r := 86.0 * _zoom
	var lume: Color = RqKit.mat("lume")
	for i in 5:
		v.draw_circle(c, r + (5 - i) * 7.0 * _zoom, Color(lume.r, lume.g, lume.b, 0.03))
	v.draw_circle(c, r, Color(0.03, 0.035, 0.06, 0.95))
	v.draw_arc(c, r, 0, TAU, 96, CodexKit.GILT, 2.0, true)
	v.draw_arc(c, r - 6.0 * _zoom, 0, TAU, 96, Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.35), 1.0, true)
	if is_instance_valid(_crest) and _crest.texture:
		var cs := r * 1.35
		_crest.position = c - Vector2(cs, cs) * 0.5
		_crest.size = Vector2(cs, cs)
		return
	var crest_path := String({"barrosan": "res://assets/ui/barrosan_command_crest_i2.png", "lioraen": "res://assets/ui/faction_crests/astra_r1/lioraen.png", "vorthak": "res://assets/ui/faction_crests/astra_r1/vorthak.png"}.get(_race(), ""))
	if not crest_path.is_empty() and ResourceLoader.exists(crest_path):
		var tex: Texture2D = load(crest_path)
		var ts := tex.get_size()
		var fit := (r * 1.3) / maxf(ts.x, ts.y)
		var draw_size := ts * fit
		v.draw_texture_rect(tex, Rect2(c - draw_size * 0.5, draw_size), false)
	else:
		var g := CodexKit.glyph("lume")
		if g:
			v.draw_texture_rect(g, Rect2(c - Vector2(r, r) * 0.6, Vector2(r, r) * 1.2), false, CodexKit.GILT_HI)


func _draw_link(from_id: String, to_id: String) -> void:
	var v := _view
	var a := _to_screen(_layout[from_id])
	var b := _to_screen(_layout[to_id])
	var from_owned := _owned(from_id)
	var to := _find(to_id)
	var st := _state(to)
	var pig := CodexKit.pigment(String(to.get("branch", "")))
	if from_owned and st == "UNLOCKED":
		v.draw_line(a, b, Color(pig.r, pig.g, pig.b, 0.16), 9.0 * _zoom, true)
		v.draw_line(a, b, Color(pig.r, pig.g, pig.b, 0.5), 3.5 * _zoom, true)
		v.draw_line(a, b, pig.lightened(0.45), 1.4, true)
	elif from_owned and st in ["PURCHASABLE", "OPEN"]:
		# Gilt light running out toward the next star you can take.
		var seg_len := a.distance_to(b)
		var dir := (b - a) / maxf(seg_len, 0.001)
		var off := fmod(_t * 26.0, 14.0)
		var s := off - 14.0
		var col := CodexKit.GILT_HI if st == "PURCHASABLE" else Color(pig.r, pig.g, pig.b, 0.7)
		while s < seg_len:
			var s0 := maxf(s, 0.0)
			var s1 := minf(s + 7.0, seg_len)
			if s1 > s0:
				v.draw_line(a + dir * s0, a + dir * s1, col, 1.6, true)
			s += 14.0
	else:
		v.draw_line(a, b, Color(CodexKit.STAR_COLD.r, CodexKit.STAR_COLD.g, CodexKit.STAR_COLD.b, 0.28), 1.0, true)


func _draw_star(n: Dictionary) -> void:
	var v := _view
	var id := String(n["id"])
	var p := _to_screen(_layout[id])
	var r := _star_radius(n)
	if p.x < -60 or p.y < -60 or p.x > v.size.x + 60 or p.y > v.size.y + 60:
		return
	var st := _state(n)
	var pig := CodexKit.pigment(String(n.get("branch", "")))
	var keystone: bool = n.get("keystone", false)
	var hovered := id == _hover_id
	var selected := id == _selected_id
	paint_star(v, p, r, st, pig, keystone, CodexKit.star_glyph(n), _t, hovered)
	if selected:
		var spin := _t * 0.6
		for k in 12:
			var a0 := spin + TAU * k / 12.0
			v.draw_arc(p, r + 9.0, a0, a0 + TAU / 24.0, 6, CodexKit.VERMILION, 2.0, true)


## Paints one star. Shared with the codex page's large star portrait.
static func paint_star(ci: CanvasItem, p: Vector2, r: float, st: String, pig: Color, keystone: bool, glyph_name: String, t: float, hovered: bool = false) -> void:
	var gilt := CodexKit.GILT
	if keystone:
		var crown := CodexKit.star_points(p, r * 1.75, 0.42, 8, t * 0.05)
		var crown_col := Color(gilt.r, gilt.g, gilt.b, 0.5 if st != "LOCKED" else 0.18)
		ci.draw_colored_polygon(crown, Color(gilt.r, gilt.g, gilt.b, 0.08 if st != "LOCKED" else 0.03))
		var outline := PackedVector2Array(crown)
		outline.append(crown[0])
		ci.draw_polyline(outline, crown_col, 1.0, true)
	if st == "LOCKED":
		var cold := CodexKit.STAR_COLD
		var shape := CodexKit.star_points(p, r * 0.9, 0.3)
		ci.draw_colored_polygon(shape, Color(cold.r, cold.g, cold.b, 0.75 if hovered else 0.5))
		ci.draw_circle(p, r * 0.16, Color(0.9, 0.92, 1.0, 0.6))
		if hovered:
			ci.draw_arc(p, r, 0, TAU, 32, Color(cold.r, cold.g, cold.b, 0.6), 1.0, true)
		return
	var glyph_col := Color.WHITE
	if st == "UNLOCKED":
		for i in 5:
			ci.draw_circle(p, r * (1.0 + 0.3 * (5 - i)), Color(pig.r, pig.g, pig.b, 0.05))
		ci.draw_circle(p, r, pig.darkened(0.45))
		ci.draw_circle(p, r * 0.82, pig.darkened(0.2))
		ci.draw_arc(p, r, 0, TAU, 48, pig.lightened(0.45), 2.0, true)
		glyph_col = Color(1.0, 0.97, 0.9)
	elif st == "PURCHASABLE":
		var pulse := 0.5 + 0.5 * sin(t * 3.2)
		for i in 4:
			ci.draw_circle(p, r * (1.15 + 0.22 * (4 - i) + 0.12 * pulse), Color(1.0, 0.85, 0.45, 0.045 + 0.02 * pulse))
		ci.draw_circle(p, r, Color(0.06, 0.06, 0.09))
		ci.draw_arc(p, r, 0, TAU, 48, CodexKit.GILT_HI, 2.0, true)
		for k in 8:
			var a := t * 0.8 + TAU * k / 8.0
			ci.draw_line(p + Vector2(cos(a), sin(a)) * (r + 4.0), p + Vector2(cos(a), sin(a)) * (r + 8.0), Color(CodexKit.GILT_HI.r, CodexKit.GILT_HI.g, CodexKit.GILT_HI.b, 0.8), 1.4, true)
		glyph_col = CodexKit.GILT_HI
	else:
		ci.draw_circle(p, r, Color(0.05, 0.055, 0.08, 0.95))
		ci.draw_arc(p, r, 0, TAU, 48, Color(pig.r, pig.g, pig.b, 0.75 if hovered else 0.5), 1.4, true)
		glyph_col = Color(pig.r, pig.g, pig.b, 0.85)
	if hovered:
		ci.draw_arc(p, r + 3.0, 0, TAU, 48, Color(1, 1, 1, 0.35), 1.0, true)
	var g := CodexKit.glyph(glyph_name)
	if g:
		var gs := r * 1.12
		ci.draw_texture_rect(g, Rect2(p - Vector2(gs, gs) * 0.5, Vector2(gs, gs)), false, glyph_col)


func _label_rank(n: Dictionary) -> int:
	var id := String(n["id"])
	if id == _selected_id:
		return 6
	if id == _hover_id:
		return 5
	match _state(n):
		"PURCHASABLE":
			return 4
		"UNLOCKED":
			return 2 if not n.get("keystone", false) else 3
	return 3 if n.get("keystone", false) else 1


func _draw_edges_fade(v: Control) -> void:
	# Night closes in at the top and bottom so the title and the hint stay legible
	# over the chart when it is zoomed or panned under them. Drawn on a veil
	# above the hub crest, with the points seal on top.
	var night := CodexKit.NIGHT
	var top := PackedVector2Array([Vector2.ZERO, Vector2(v.size.x, 0), Vector2(v.size.x, 170), Vector2(0, 170)])
	v.draw_polygon(top, PackedColorArray([Color(night, 0.92), Color(night, 0.92), Color(night, 0.0), Color(night, 0.0)]))
	var bottom := PackedVector2Array([Vector2(0, v.size.y - 90), Vector2(v.size.x, v.size.y - 90), Vector2(v.size.x, v.size.y), Vector2(0, v.size.y)])
	v.draw_polygon(bottom, PackedColorArray([Color(night, 0.0), Color(night, 0.0), Color(night, 0.9), Color(night, 0.9)]))
	_draw_seal(v)


func _draw_star_name(n: Dictionary) -> void:
	var v := _view
	var id := String(n["id"])
	var st := _state(n)
	var notable: bool = n.get("keystone", false) or st == "PURCHASABLE" or id == _hover_id or id == _selected_id
	if _zoom < LABEL_ZOOM and not notable:
		return
	var p := _to_screen(_layout[id])
	if p.x < -80 or p.y < -40 or p.x > v.size.x + 80 or p.y > v.size.y + 40:
		return
	var r := _star_radius(n)
	var text := String(n.get("name", id))
	var face := CodexKit.font(CodexKit.FONT_BODY_BOLD if st == "PURCHASABLE" or id == _selected_id else CodexKit.FONT_BODY)
	var fs := 15
	var col := CodexKit.TEXT_MUTED
	match st:
		"UNLOCKED":
			col = CodexKit.TEXT
		"PURCHASABLE":
			col = CodexKit.GILT_HI
		"LOCKED":
			col = CodexKit.TEXT_DIM
	if n.get("keystone", false):
		face = CodexKit.font(CodexKit.FONT_DISPLAY)
		fs = 13
	var tw := face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var at := p + Vector2(-tw * 0.5, r + (r * 0.75 if n.get("keystone", false) else 0.0) + 17.0)
	var box := Rect2(at + Vector2(-3, -fs), Vector2(tw + 6, fs + 6))
	for placed in _label_rects:
		if placed.intersects(box):
			return
	_label_rects.append(box)
	v.draw_string_outline(face, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 5, Color(0.02, 0.02, 0.04, 0.85))
	v.draw_string(face, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _draw_path_name(path: String) -> void:
	var v := _view
	var a := _sector_angle(path)
	var dir := Vector2(cos(a), sin(a))
	var p := _origin() + dir * (_outer_radius() + 128.0) * _zoom
	var pig := CodexKit.pigment(path)
	var title := "THE " + String(CodexKit.PATH_NAMES[path]).to_upper()
	var face := CodexKit.font(CodexKit.FONT_DISPLAY_BOLD)
	var fs := 20
	var tw := face.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var owned := 0
	var total := 0
	for n in _nodes:
		if String(n.get("branch", "")) == path:
			total += 1
			if _owned(String(n["id"])):
				owned += 1
	var hint := "%s  ·  %d of %d" % [PATH_HINTS[path], owned, total]
	var hf := CodexKit.font(CodexKit.FONT_SERIF_ITALIC)
	var hw := hf.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
	var g := CodexKit.glyph(CodexKit.PATH_GLYPHS[path])
	var gs := 26.0
	var block_w := gs + 10.0 + tw
	var top := p + Vector2(-block_w * 0.5, -18.0)
	if g:
		v.draw_texture_rect(g, Rect2(top + Vector2(0, -gs * 0.5 + 2.0), Vector2(gs, gs)), false, pig)
	v.draw_string_outline(face, top + Vector2(gs + 10.0, 8.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 6, Color(0.02, 0.02, 0.04, 0.85))
	v.draw_string(face, top + Vector2(gs + 10.0, 8.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, pig.lightened(0.2))
	v.draw_string_outline(hf, p + Vector2(-hw * 0.5, 14.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 5, Color(0.02, 0.02, 0.04, 0.85))
	v.draw_string(hf, p + Vector2(-hw * 0.5, 14.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, CodexKit.TEXT_MUTED)
	var bw := maxf(block_w, hw)
	_label_rects.append(Rect2(p + Vector2(-bw * 0.5, -36.0), Vector2(bw, 56.0)))


func _draw_seal(v: Control) -> void:
	var at := Vector2(v.size.x - 86.0, 86.0)
	CodexKit.draw_seal(v, at, 40.0, str(_points()), _seal_pulse if _seal_pulse >= 0.0 else 0.0)
	var cap := "point to spend" if _points() == 1 else "points to spend"
	var f := CodexKit.font(CodexKit.FONT_SERIF_ITALIC)
	var w := f.get_string_size(cap, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
	v.draw_string(f, at + Vector2(-w * 0.5, 64.0), cap, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CodexKit.TEXT_MUTED)


# --- input --------------------------------------------------------------------
var _dragging := false
var _drag_from := Vector2.ZERO
var _drag_moved := false


func _star_at(screen: Vector2) -> String:
	var best := ""
	var best_d := 1e9
	for n in _nodes:
		var id := String(n["id"])
		var d := _to_screen(_layout[id]).distance_to(screen)
		var reach := _star_radius(n) + 8.0
		if d < reach and d < best_d:
			best = id
			best_d = d
	return best


func _on_view_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN] and mb.pressed:
			var before := _to_chart(mb.position)
			_zoom = clampf(_zoom * (1.12 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.12), 0.35, 1.8)
			_pan += mb.position - _to_screen(before)
			if _fly and _fly.is_valid():
				_fly.kill()
			_view.queue_redraw()
		elif mb.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if mb.pressed:
				_dragging = true
				_drag_from = mb.position
				_drag_moved = false
			else:
				_dragging = false
				if mb.button_index == MOUSE_BUTTON_LEFT and not _drag_moved:
					_click(mb.position)
	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if _dragging:
			if mm.position.distance_to(_drag_from) > 4.0:
				_drag_moved = true
			if _drag_moved:
				_pan += mm.relative
				if _fly and _fly.is_valid():
					_fly.kill()
		var over := _star_at(mm.position)
		if over != _hover_id:
			_hover_id = over
			_view.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if over != "" else Control.CURSOR_ARROW
			_view.tooltip_text = ""
		_view.queue_redraw()


func _click(at: Vector2) -> void:
	var id := _star_at(at)
	if id.is_empty():
		if not _selected_id.is_empty():
			_selected_id = ""
			_show_page()
		return
	var now := Time.get_ticks_msec()
	var double := id == _last_click_id and now - _last_click_ms < 380
	_last_click_ms = now
	_last_click_id = id
	_selected_id = id
	Sfx.play("select")
	_show_page()
	if double and _state(_find(id)) == "PURCHASABLE":
		_claim_selected()


func _claim_selected() -> void:
	var n := _find(_selected_id)
	if n.is_empty() or _state(n) != "PURCHASABLE":
		return
	if ProfileManager.unlock_skill(_selected_id):
		Sfx.play("levelup")
		_bursts.append({"pos": _layout[_selected_id], "t": _t, "col": CodexKit.pigment(String(n.get("branch", "")))})
		_seal_pulse = 0.0


func _on_profile_changed() -> void:
	_subtitle.text = "%s  ·  %s  ·  level %d" % [String(_hero().get("name", "Your hero")), _race().capitalize(), int(_hero().get("level", 1))]
	_show_page()


func _on_respec() -> void:
	Sfx.play("select")
	var dlg: Control = load("res://scripts/ui/gilt_confirm.gd").ask(self, "Unlearn every star", "Every claimed star goes dark and all its points come back to spend again.", "Unlearn all")
	dlg.confirmed.connect(func(): ProfileManager.respec_skills())


func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)


# --- codex page ---------------------------------------------------------------
func _show_page() -> void:
	if not is_instance_valid(_page_body):
		return
	for c in _page_body.get_children():
		c.queue_free()
	var n := _find(_selected_id)
	if n.is_empty():
		_page_overview()
	else:
		_page_star(n)


func _page_overview() -> void:
	var h := _hero()
	_page_body.add_child(CodexKit.label("Your legend so far", 19, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC))
	_page_body.add_child(CodexKit.illuminated(String(h.get("name", "Your hero")), 36))
	_page_body.add_child(_rule())
	var owned := 0
	for n in _nodes:
		if _owned(String(n["id"])):
			owned += 1
	var line := CodexKit.label("Level %d  ·  %d of %d stars claimed" % [int(h.get("level", 1)), owned, _nodes.size()], 19, CodexKit.TEXT)
	_page_body.add_child(line)
	for path in SECTORS:
		_page_body.add_child(_path_row(path))
	var hint := CodexKit.label("Every level brings a skill point. Click a path above to fly to it, or a star to read it; a gold star is yours to claim. The keystones on the two gilt rings are the great turns of a legend.", 18, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(300, 0)
	_page_body.add_child(hint)
	_claim.visible = false


func _path_row(path: String) -> Control:
	var row := HBoxContainer.new()
	row.name = "PathRow_" + path
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.tooltip_text = "Fly to the %s: %s" % [CodexKit.PATH_NAMES[path], PATH_HINTS[path]]
	row.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_fly_to_path(path))
	var pig := CodexKit.pigment(path)
	var g := TextureRect.new()
	g.texture = CodexKit.glyph(CodexKit.PATH_GLYPHS[path])
	g.custom_minimum_size = Vector2(22, 22)
	g.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	g.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	g.modulate = pig
	row.add_child(g)
	var name_label := CodexKit.label(String(CodexKit.PATH_NAMES[path]), 18, CodexKit.TEXT, CodexKit.FONT_DISPLAY)
	name_label.custom_minimum_size = Vector2(96, 0)
	row.add_child(name_label)
	var owned := 0
	var total := 0
	for n in _nodes:
		if String(n.get("branch", "")) == path:
			total += 1
			if _owned(String(n["id"])):
				owned += 1
	var bar := Control.new()
	bar.custom_minimum_size = Vector2(0, 22)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frac := float(owned) / maxf(1.0, float(total))
	bar.draw.connect(func():
		var y := bar.size.y * 0.5
		bar.draw_line(Vector2(0, y), Vector2(bar.size.x, y), Color(0, 0, 0, 0.55), 5.0)
		bar.draw_line(Vector2(0, y), Vector2(bar.size.x, y), Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.2), 1.0)
		if frac > 0.0:
			bar.draw_line(Vector2(0, y), Vector2(bar.size.x * frac, y), pig, 3.0))
	row.add_child(bar)
	row.add_child(CodexKit.label("%d/%d" % [owned, total], 16, CodexKit.TEXT_MUTED))
	return row


func _page_star(n: Dictionary) -> void:
	var st := _state(n)
	var path := String(n.get("branch", ""))
	var pig := CodexKit.pigment(path)
	var effect: Dictionary = n.get("effect", {})
	var kind := "a spell you cast" if effect.has("ability") else "always active"
	if n.get("keystone", false):
		kind = "keystone  ·  " + kind
	var portrait := Control.new()
	portrait.custom_minimum_size = Vector2(0, 118)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var glyph_name := CodexKit.star_glyph(n)
	var keystone: bool = n.get("keystone", false)
	portrait.draw.connect(func():
		var c := Vector2(58, 60)
		paint_star(portrait, c, 34.0 if not keystone else 30.0, st, pig, keystone, glyph_name, _t, false))
	var tick := Timer.new()
	tick.wait_time = 0.05
	tick.autostart = true
	tick.timeout.connect(portrait.queue_redraw)
	portrait.add_child(tick)
	_page_body.add_child(portrait)
	var kicker := CodexKit.label("The %s  ·  %s" % [CodexKit.PATH_NAMES[path], kind], 19, pig.lightened(0.15), CodexKit.FONT_SERIF_ITALIC_BOLD)
	_page_body.add_child(kicker)
	_title = CodexKit.illuminated(String(n.get("name", "")), 34)
	_page_body.add_child(_title)
	_page_body.add_child(_rule())
	var desc := String(n.get("desc", "")).replace("KEYSTONE: ", "")
	var body := CodexKit.label(desc, 20, CodexKit.TEXT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(300, 0)
	_page_body.add_child(body)
	var cost := int(n.get("cost", 1))
	var state_text := {"UNLOCKED": "Claimed. It is part of your hero now.", "PURCHASABLE": "Ready to claim.", "OPEN": "You need %d more point%s." % [cost - _points(), "" if cost - _points() == 1 else "s"], "LOCKED": "Still dark. Claim the stars before it first."}
	var state_col := {"UNLOCKED": CodexKit.POSITIVE, "PURCHASABLE": CodexKit.GILT_HI, "OPEN": CodexKit.TEXT_MUTED, "LOCKED": CodexKit.TEXT_DIM}
	var facts := CodexKit.label("Costs %d point%s" % [cost, "" if cost == 1 else "s"], 18, CodexKit.TEXT_MUTED, CodexKit.FONT_DISPLAY)
	_page_body.add_child(facts)
	_page_body.add_child(CodexKit.label(String(state_text[st]), 19, state_col[st], CodexKit.FONT_SERIF_ITALIC_BOLD))
	var reqs: Array[String] = []
	for req in n.get("req", []):
		reqs.append(String(_find(String(req)).get("name", req)))
	var next: Array[String] = []
	for child in _children.get(String(n["id"]), []):
		next.append(String(_find(String(child)).get("name", child)))
	if not reqs.is_empty():
		var l := CodexKit.label("Comes after  " + "  and  ".join(reqs), 17, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(l)
	if not next.is_empty():
		var l2 := CodexKit.label("Leads to  " + "  ·  ".join(next), 17, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
		l2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l2.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(l2)
	_claim.visible = st == "PURCHASABLE"
	_claim.text = "Claim this star  ·  %d point%s" % [cost, "" if cost == 1 else "s"]


func _rule() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 14)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func(): CodexKit.draw_rule(c, Vector2(0, 7), Vector2(c.size.x, 7)))
	return c
