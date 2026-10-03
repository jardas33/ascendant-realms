extends "res://scripts/ui/campaign_map.gd"
## The Saga Map: the campaign as an illuminated codex spread (art direction
## B). The left leaf is the Act's land, inked like an old chart, with the
## road of chapter seals; the right leaf is a codex page that reads the
## chosen chapter and marches to it. Saga rules, briefings text, the Endless
## Road and the Chronicle stay in campaign_map.gd and CampaignDefs.

const PAGE_WIDTH := 470.0
const SEAL_R := 30.0
const ROMAN := ["I", "II", "III", "IV", "V"]

var _map_rect := Rect2()
var _page: Control
var _page_body: VBoxContainer
var _page_actions: HBoxContainer
var _selected := ""
var _hover := ""
var _act_strip: Control
var _ink: Array = []          # seeded map ornaments for the current Act


func _ready() -> void:
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	RqKit.people = _hero_race() if _hero_race() in RqKit.PEOPLES else "barrosan"
	super._ready()


func _build() -> void:
	var night := ColorRect.new()
	night.color = CodexKit.NIGHT
	night.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	night.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(night)
	_mood = ColorRect.new()
	_mood.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mood.visible = false
	add_child(_mood)

	# Header: the saga's name, the hero, the jars.
	var header := VBoxContainer.new()
	header.position = Vector2(44, 22)
	header.add_theme_constant_override("separation", 0)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)
	header.add_child(CodexKit.illuminated("The Seventy-Seventh Ascension", 38, CodexKit.GILT_HI))
	var s := ProfileManager.saga()
	var h: Dictionary = ProfileManager.hero()
	var who := "No hero yet: forge one from the main menu" if h.is_empty() else "%s of the %s  ·  level %d" % [String(h.get("name", "Hero")), String(GameData.get_race(_hero_race()).get("name", _hero_race())), int(h.get("level", 1))]
	var choice := ""
	if String(s["choice"]) == "break":
		choice = "  ·  the Wall is broken"
	elif String(s["choice"]) == "seize":
		choice = "  ·  the Wall is yours"
	header.add_child(CodexKit.label("%s  ·  Wine of the Dead %d of %d jars%s" % [who, s["jars"].size(), CampaignDefs.JARS_TOTAL, choice], 21, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC))

	# The five Acts as wax seals on a gilt rule.
	_act_strip = Control.new()
	_act_strip.name = "ActSeals"
	_act_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_act_strip.draw.connect(_draw_act_strip)
	add_child(_act_strip)
	var group := ButtonGroup.new()
	for a in CampaignDefs.ACTS.size():
		var b := Button.new()
		b.name = "Act%d" % (a + 1)
		b.toggle_mode = true
		b.button_group = group
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(56, 56)
		b.size = Vector2(56, 56)
		b.disabled = not _act_reached(a)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not b.disabled else Control.CURSOR_ARROW
		b.tooltip_text = String(CampaignDefs.ACTS[a]["title"]) if not b.disabled else "This Act is still sealed."
		for st in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
			b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
		var cap_a: int = a
		b.draw.connect(func(): _draw_act_seal(b, cap_a))
		b.mouse_entered.connect(b.queue_redraw)
		b.mouse_exited.connect(b.queue_redraw)
		b.toggled.connect(func(_on): b.queue_redraw())
		b.pressed.connect(func():
			Sfx.play("page")
			_selected = ""
			_show_act(cap_a))
		_act_strip.add_child(b)
		_act_buttons.append(b)
	_act_title = CodexKit.label("", 30, CodexKit.TEXT, CodexKit.FONT_DISPLAY)
	_act_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_act_strip.add_child(_act_title)
	_act_subtitle = CodexKit.label("", 19, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
	_act_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_act_strip.add_child(_act_subtitle)

	# The land, then the road, then the seals.
	_canvas = Control.new()
	_canvas.name = "SagaLand"
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_path)
	add_child(_canvas)
	_act_layer = Control.new()
	_act_layer.name = "ChapterSeals"
	_act_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_act_layer)

	# The codex page.
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
	column.add_theme_constant_override("separation", 14)
	margin.add_child(column)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_page_body = VBoxContainer.new()
	_page_body.name = "PageBody"
	_page_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_body.add_theme_constant_override("separation", 12)
	scroll.add_child(_page_body)
	_page_actions = HBoxContainer.new()
	_page_actions.add_theme_constant_override("separation", 12)
	column.add_child(_page_actions)

	# The foot of the map: leave, reread, or take the Endless Road.
	var foot := HBoxContainer.new()
	foot.name = "MapFoot"
	foot.add_theme_constant_override("separation", 12)
	add_child(foot)
	foot.add_child(_codex_button("Back", _on_back_pressed))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foot.add_child(spacer)
	var none_won: bool = ProfileManager.saga()["cleared"].is_empty()
	var chronicle := _codex_button("Chronicle", _open_chronicle)
	chronicle.disabled = none_won
	chronicle.tooltip_text = "Win a chapter to begin the Chronicle." if none_won else "Reread the story of every chapter you have won."
	foot.add_child(chronicle)
	var endless := _codex_button("Endless Road", func(): _open_endless())
	endless.disabled = none_won
	endless.tooltip_text = "Win your first chapter to open the Endless Road." if none_won else "Stage after stage, deeper each time, with records to beat."
	foot.add_child(endless)
	_foot = foot

	resized.connect(_layout_saga)
	_layout_saga()
	_show_act(_act)
	if Match.has_meta("fresh_seal"):
		var fresh := String(Match.get_meta("fresh_seal"))
		Match.remove_meta("fresh_seal")
		_stamp_seal.call_deferred(fresh)
	if Match.has_meta("open_endless"):
		Match.remove_meta("open_endless")
		call_deferred("_open_endless")
		return
	var saga_state := ProfileManager.saga()
	if not saga_state.has("seen_acts"):
		saga_state["seen_acts"] = []
	if not (_act in saga_state["seen_acts"]) and OS.get_environment("ASCENDANT_UI_SKIP_ACT_CARD") != "1":
		saga_state["seen_acts"].append(_act)
		_show_act_card(_act)
	saga_state["auto_brief"] = false
	ProfileManager.save_game()


var _foot: HBoxContainer


func _codex_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.set_script(load("res://scripts/ui/codex/codex_button.gd"))
	b.text = text
	b.custom_minimum_size = Vector2(180, 48)
	b.pressed.connect(cb)
	return b


func _layout_saga() -> void:
	if not is_instance_valid(_page):
		return
	var vp := size if size.x > 10.0 else get_viewport_rect().size
	var page_w := clampf(vp.x * 0.25, 420.0, PAGE_WIDTH)
	_page.position = Vector2(vp.x - page_w - 24.0, 24.0)
	_page.size = Vector2(page_w, vp.y - 48.0)
	var left := 32.0
	var right := _page.position.x - 24.0
	_act_strip.position = Vector2(left, 124.0)
	_act_strip.size = Vector2(right - left, 150.0)
	var n := _act_buttons.size()
	var step := 92.0
	var start := _act_strip.size.x * 0.5 - step * (n - 1) * 0.5
	for i in n:
		var b: Button = _act_buttons[i]
		b.position = Vector2(start + i * step - 28.0, 6.0)
	_act_title.position = Vector2(0, 66)
	_act_title.size = Vector2(_act_strip.size.x, 40)
	_act_subtitle.position = Vector2(0, 104)
	_act_subtitle.size = Vector2(_act_strip.size.x, 28)
	_map_rect = Rect2(Vector2(left, 288.0), Vector2(right - left, vp.y - 288.0 - 96.0))
	_canvas.position = Vector2.ZERO
	_canvas.size = vp
	_act_layer.position = Vector2.ZERO
	_act_layer.size = vp
	_foot.position = Vector2(left, vp.y - 72.0)
	_foot.size = Vector2(right - left, 48.0)
	_page.queue_redraw()
	_act_strip.queue_redraw()


# --- Acts ---------------------------------------------------------------------
func _draw_act_strip() -> void:
	var w := _act_strip.size.x
	var y := 34.0
	var n := _act_buttons.size()
	var step := 92.0
	var start := w * 0.5 - step * (n - 1) * 0.5
	CodexKit.draw_rule(_act_strip, Vector2(start - 160.0, y), Vector2(start - 40.0, y), false)
	CodexKit.draw_rule(_act_strip, Vector2(start + step * (n - 1) + 40.0, y), Vector2(start + step * (n - 1) + 160.0, y), false)
	for i in n - 1:
		var a := Vector2(start + i * step + 30.0, y)
		var b := Vector2(start + (i + 1) * step - 30.0, y)
		var reached := _act_reached(i + 1)
		_act_strip.draw_line(a, b, Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.6 if reached else 0.18), 1.2, true)
	CodexKit.draw_rule(_act_strip, Vector2(w * 0.5 - 220.0, 141.0), Vector2(w * 0.5 + 220.0, 141.0))


func _draw_act_seal(b: Button, a: int) -> void:
	var c := b.size * 0.5
	var open := not b.disabled
	var current := a == _act
	var hovered := b.is_hovered() and open
	if current:
		CodexKit.draw_seal(b, c, 25.0, ROMAN[a])
		b.draw_arc(c, 31.0, 0, TAU, 48, Color(CodexKit.GILT_HI.r, CodexKit.GILT_HI.g, CodexKit.GILT_HI.b, 0.7), 1.4, true)
	elif open:
		b.draw_circle(c, 21.0, Color(0.06, 0.05, 0.05))
		b.draw_arc(c, 21.0, 0, TAU, 48, CodexKit.GILT if hovered else Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.7), 1.6, true)
		var f := CodexKit.font(CodexKit.FONT_DISPLAY_BOLD)
		var tw := f.get_string_size(ROMAN[a], HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
		b.draw_string(f, c + Vector2(-tw * 0.5, 7), ROMAN[a], HORIZONTAL_ALIGNMENT_LEFT, -1, 20, CodexKit.GILT_HI if hovered else CodexKit.TEXT)
	else:
		b.draw_circle(c, 18.0, Color(0.05, 0.055, 0.07))
		b.draw_arc(c, 18.0, 0, TAU, 40, Color(CodexKit.STAR_COLD.r, CodexKit.STAR_COLD.g, CodexKit.STAR_COLD.b, 0.5), 1.0, true)
		var f2 := CodexKit.font(CodexKit.FONT_DISPLAY)
		var tw2 := f2.get_string_size(ROMAN[a], HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		b.draw_string(f2, c + Vector2(-tw2 * 0.5, 6), ROMAN[a], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, CodexKit.TEXT_DIM)


func _show_act(a: int) -> void:
	_act = a
	if a < _act_buttons.size():
		_act_buttons[a].set_pressed_no_signal(true)
	for b in _act_buttons:
		b.queue_redraw()
	for child in _act_layer.get_children():
		child.queue_free()
	_positions.clear()
	var parts: PackedStringArray = String(CampaignDefs.ACTS[a]["title"]).split(": ")
	_act_title.text = parts[1] if parts.size() > 1 else parts[0]
	_act_subtitle.text = String(CampaignDefs.ACTS[a]["subtitle"]) + _act_progress_text(a).replace("   ·   ", "  ·  ")
	_seed_ink(a)
	# The main road winds left to right across the land; side roads hang
	# above and below the chapter before them; the Choice forks at the end.
	var r := _map_rect
	var chapters := CampaignDefs.chapters_in_act(a)
	var mains: Array = chapters.filter(func(c): return not bool(c.get("side", false)) and not c.has("branch"))
	var forks := chapters.any(func(c): return c.has("branch"))
	var n := mains.size() + (1 if forks else 0)
	var k := 0
	var last_main := Vector2.ZERO
	var side_flip := false
	for c in chapters:
		var id := String(c["id"])
		if c.has("branch"):
			_positions[id] = Vector2(r.position.x + r.size.x * 0.92, r.position.y + r.size.y * (0.26 if String(c["branch"]) == "break" else 0.74))
		elif bool(c.get("side", false)):
			_positions[id] = Vector2(last_main.x + r.size.x * 0.06, r.position.y + r.size.y * (0.16 if side_flip else 0.86))
			side_flip = not side_flip
		else:
			var t := float(k) / float(maxi(1, n - 1))
			var x := r.position.x + r.size.x * (0.07 + 0.86 * t)
			var y := r.position.y + r.size.y * (0.5 + 0.13 * sin(t * PI * 2.2 + 0.6))
			_positions[id] = Vector2(x, y)
			last_main = _positions[id]
			k += 1
	for c in chapters:
		_build_node(c)
	var order := 0
	for child in _act_layer.get_children():
		if child.is_queued_for_deletion():
			continue
		var target_mod: Color = child.modulate
		child.modulate = Color(target_mod, 0.0)
		child.create_tween().tween_property(child, "modulate", target_mod, 0.3).set_delay(order * 0.05)
		order += 1
	_canvas.queue_redraw()
	_act_strip.queue_redraw()
	var next := CampaignDefs.find(_next_id)
	if _selected.is_empty() or int(CampaignDefs.find(_selected).get("act", -1)) != a:
		_selected = _next_id if int(next.get("act", -1)) == a else String(chapters[0]["id"])
	_show_page(_selected)


# --- chapter seals --------------------------------------------------------------
func _build_node(c: Dictionary) -> void:
	var id := String(c["id"])
	var s := ProfileManager.saga()
	var available := ProfileManager.chapter_available(id)
	var cleared: bool = id in s["cleared"]
	var btn := Button.new()
	btn.name = "Chapter_" + id
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.size = Vector2(220, 128)
	btn.position = _positions[id] - Vector2(110, SEAL_R + 8.0)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.set_meta("chapter", id)
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	btn.draw.connect(func(): _draw_chapter(btn, c, available, cleared))
	btn.mouse_entered.connect(func():
		_hover = id
		btn.queue_redraw()
		if available or cleared:
			Sfx.play("select"))
	btn.mouse_exited.connect(func():
		_hover = ""
		btn.queue_redraw())
	btn.pressed.connect(func():
		Sfx.play("page")
		_selected = id
		_show_page(id)
		for other in _act_layer.get_children():
			other.queue_redraw())
	_act_layer.add_child(btn)


func _draw_chapter(btn: Button, c: Dictionary, available: bool, cleared: bool) -> void:
	var id := String(c["id"])
	var s := ProfileManager.saga()
	var centre := Vector2(btn.size.x * 0.5, SEAL_R + 8.0)
	var side := bool(c.get("side", false))
	var r := SEAL_R * (0.8 if side else 1.0)
	var is_next := id == _next_id or (c.has("branch") and String(s["choice"]) == "" and available and not cleared)
	var selected := id == _selected
	var hovered := id == _hover
	var lume: Color = RqKit.mat("lume")
	if is_next and not cleared:
		var pulse := 0.5 + 0.5 * sin(_anim_t * 3.0)
		for i in 4:
			btn.draw_circle(centre, r * (1.2 + 0.25 * (4 - i) + 0.1 * pulse), Color(lume.r, lume.g, lume.b, 0.05))
	if cleared:
		CodexKit.draw_seal(btn, centre, r, id.split("-")[1].replace("S", "") if not side else "✦")
		if id in s.get("heroic", []):
			_draw_laurel(btn, centre, r + 6.0)
	elif available:
		btn.draw_circle(centre, r, Color(0.07, 0.06, 0.05))
		btn.draw_arc(centre, r, 0, TAU, 56, CodexKit.GILT_HI if (hovered or is_next) else CodexKit.GILT, 2.0, true)
		btn.draw_arc(centre, r - 5.0, 0, TAU, 56, Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.35), 1.0, true)
		var g := CodexKit.glyph("objective" if not side else "patrol")
		if g:
			var gs := r * 1.0
			btn.draw_texture_rect(g, Rect2(centre - Vector2(gs, gs) * 0.5, Vector2(gs, gs)), false, CodexKit.GILT_HI)
	else:
		btn.draw_circle(centre, r * 0.82, Color(0.045, 0.05, 0.065))
		btn.draw_arc(centre, r * 0.82, 0, TAU, 40, Color(CodexKit.STAR_COLD.r, CodexKit.STAR_COLD.g, CodexKit.STAR_COLD.b, 0.5), 1.0, true)
		var sh := CodexKit.star_points(centre, r * 0.36, 0.3)
		btn.draw_colored_polygon(sh, Color(CodexKit.STAR_COLD.r, CodexKit.STAR_COLD.g, CodexKit.STAR_COLD.b, 0.6))
	if bool(c.get("jar", false)):
		var jp := centre + Vector2(r * 0.85, -r * 0.85)
		var found: bool = id in s["jars"]
		btn.draw_circle(jp, 9.0, Color(0.05, 0.04, 0.04))
		btn.draw_arc(jp, 9.0, 0, TAU, 20, CodexKit.VERMILION if not found else CodexKit.GILT_HI, 1.4, true)
		btn.draw_colored_polygon(PackedVector2Array([jp + Vector2(-3.5, -4), jp + Vector2(3.5, -4), jp + Vector2(4.5, 4), jp + Vector2(-4.5, 4)]), CodexKit.VERMILION if not found else CodexKit.GILT_HI)
	if selected:
		for k in 16:
			var a0 := _anim_t * 0.5 + TAU * k / 16.0
			btn.draw_arc(centre, r + 9.0, a0, a0 + TAU / 32.0, 6, CodexKit.VERMILION, 2.0, true)
	# Name and state under the seal.
	var title := String(c["title"])
	var f := CodexKit.font(CodexKit.FONT_DISPLAY)
	var fs := 16 if not side else 14
	var col := CodexKit.TEXT if (available or cleared) else CodexKit.TEXT_DIM
	if hovered and (available or cleared):
		col = CodexKit.GILT_HI
	var lines := _wrap(title, f, fs, btn.size.x - 8.0)
	var y := centre.y + r + 22.0
	for line in lines:
		var tw := f.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		btn.draw_string_outline(f, Vector2((btn.size.x - tw) * 0.5, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 6, Color(0.02, 0.02, 0.04, 0.9))
		btn.draw_string(f, Vector2((btn.size.x - tw) * 0.5, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
		y += fs + 3.0
	var state := ""
	var state_col := CodexKit.TEXT_MUTED
	if cleared:
		state = "Heroic laurel" if id in s.get("heroic", []) else "Won"
		state_col = CodexKit.POSITIVE
	elif available:
		state = String(c["difficulty"])
		state_col = Color(DIFF_COLORS.get(state, CodexKit.TEXT_MUTED)).lerp(CodexKit.TEXT, 0.15)
	else:
		state = "Sealed"
		state_col = CodexKit.TEXT_DIM
	if side:
		state = "side road  ·  " + state.to_lower()
	var sf := CodexKit.font(CodexKit.FONT_SERIF_ITALIC_BOLD)
	var sw := sf.get_string_size(state, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	btn.draw_string_outline(sf, Vector2((btn.size.x - sw) * 0.5, y + 1.0), state, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, 5, Color(0.02, 0.02, 0.04, 0.9))
	btn.draw_string(sf, Vector2((btn.size.x - sw) * 0.5, y + 1.0), state, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, state_col)


func _wrap(text: String, f: Font, fs: int, width: float) -> Array:
	var words := text.split(" ")
	var lines: Array = []
	var line := ""
	for w in words:
		var trial := w if line.is_empty() else line + " " + w
		if f.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > width and not line.is_empty():
			lines.append(line)
			line = w
		else:
			line = trial
	if not line.is_empty():
		lines.append(line)
	return lines


func _draw_laurel(ci: CanvasItem, c: Vector2, r: float) -> void:
	for side: float in [-1.0, 1.0]:
		for k in 6:
			var a := PI * 0.5 + side * (0.5 + k * 0.32)
			var p := c + Vector2(cos(a), sin(a)) * r
			var leaf := PackedVector2Array([p + Vector2(0, -4).rotated(a), p + Vector2(3, 0).rotated(a), p + Vector2(0, 4).rotated(a), p + Vector2(-3, 0).rotated(a)])
			ci.draw_colored_polygon(leaf, CodexKit.GILT_HI)


func _seal_point(id: String) -> Vector2:
	return _positions[id]


func _show_desc(_id: String) -> void:
	pass


func _open_briefing(id: String) -> void:
	_selected = id
	var c := CampaignDefs.find(id)
	if int(c.get("act", _act)) != _act:
		_show_act(int(c["act"]))
	else:
		_show_page(id)


func _stamp_seal(id: String) -> void:
	await get_tree().create_timer(0.6).timeout
	for child in _act_layer.get_children():
		if String(child.get_meta("chapter", "")) == id:
			child.pivot_offset = Vector2(child.size.x * 0.5, SEAL_R + 8.0)
			child.scale = Vector2.ONE * 2.0
			child.modulate.a = 0.0
			var tw := child.create_tween().set_parallel(true)
			tw.tween_property(child, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw.tween_property(child, "modulate:a", 1.0, 0.18)
			await tw.finished
			Sfx.play("stamp", -2.0)
			return


# --- the land -------------------------------------------------------------------
func _seed_ink(a: int) -> void:
	# Inked cartography for the Act: ridges, woods and fields, kept clear of
	# the road so the seals always read.
	var rng := RandomNumberGenerator.new()
	rng.seed = 7700 + a * 31
	_ink.clear()
	var r := _map_rect
	for i in 150:
		var p := Vector2(rng.randf_range(r.position.x + 20, r.end.x - 20), rng.randf_range(r.position.y + 10, r.end.y - 10))
		var kind := "ridge" if rng.randf() < 0.45 else ("wood" if rng.randf() < 0.6 else "field")
		_ink.append({"p": p, "kind": kind, "s": rng.randf_range(0.7, 1.4), "seed": rng.randf()})


func _near_road(p: Vector2) -> bool:
	for id in _positions:
		if p.distance_to(_positions[id]) < 120.0:
			return true
	return false


func _draw_path() -> void:
	var cv := _canvas
	var r := _map_rect
	if r.size.x < 10.0:
		return
	var s := ProfileManager.saga()
	var mood: Color = ACT_MOODS[_act]
	# The land: a dark vellum leaf tinted by the Act's mood.
	var leaf := RqKit.chamfer(r, 14, 14, 14, 14)
	cv.draw_colored_polygon(leaf, Color(0.055, 0.06, 0.075))
	cv.draw_colored_polygon(leaf, Color(mood.r, mood.g, mood.b, 0.22))
	var g := PackedColorArray()
	var uvs := PackedVector2Array()
	for p in leaf:
		g.append(Color(1, 0.95, 0.85, 0.05))
		uvs.append(p / 256.0)
	cv.draw_polygon(leaf, g, uvs, RqKit.grain())
	# Meridians and parallels, like a chart.
	var ink := Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.05)
	var x := r.position.x + 60.0
	while x < r.end.x:
		cv.draw_line(Vector2(x, r.position.y + 8), Vector2(x, r.end.y - 8), ink, 1.0)
		x += 120.0
	var yy := r.position.y + 60.0
	while yy < r.end.y:
		cv.draw_line(Vector2(r.position.x + 8, yy), Vector2(r.end.x - 8, yy), ink, 1.0)
		yy += 120.0
	for o in _ink:
		var p: Vector2 = o["p"]
		if _near_road(p):
			continue
		var sc: float = o["s"]
		var col := Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.16)
		match String(o["kind"]):
			"ridge":
				var w := 18.0 * sc
				var h := 12.0 * sc
				cv.draw_polyline(PackedVector2Array([p + Vector2(-w, h * 0.5), p + Vector2(0, -h), p + Vector2(w, h * 0.5)]), col, 1.2, true)
				cv.draw_line(p + Vector2(0, -h), p + Vector2(w * 0.35, h * 0.5), Color(col, 0.08), 1.0, true)
			"wood":
				for k in 3:
					var q := p + Vector2((k - 1) * 8.0 * sc, (k % 2) * 4.0)
					cv.draw_arc(q, 4.5 * sc, PI, TAU, 8, col, 1.1, true)
					cv.draw_line(q, q + Vector2(0, 5 * sc), col, 1.0)
			_:
				for k in 3:
					cv.draw_line(p + Vector2(-12 * sc, k * 4.0), p + Vector2(12 * sc, k * 4.0), Color(col, 0.1), 1.0)
	# A compass rose in the corner.
	_draw_compass(cv, r.position + Vector2(78, r.size.y - 78), 44.0)
	# Frame: a double gilt hairline with lozenges.
	var outline := PackedVector2Array(leaf)
	outline.append(leaf[0])
	cv.draw_polyline(outline, Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.55), 1.2, true)
	var inner := RqKit.inset_polygon(leaf, 6.0)
	var inner_line := PackedVector2Array(inner)
	inner_line.append(inner[0])
	cv.draw_polyline(inner_line, Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.2), 1.0, true)
	# Mist drifting over the land.
	for k in 4:
		var my := r.position.y + r.size.y * (0.2 + 0.2 * k)
		var mx := fmod(_anim_t * (12.0 + k * 4.0) + k * 380.0, r.size.x + 600.0) - 300.0 + r.position.x
		for q in 4:
			var mp := Vector2(mx + q * 100.0, my + sin(_anim_t * 0.3 + k + q) * 10.0)
			if r.grow(-40.0).has_point(mp):
				# Soft-edged puffs: stacked discs, faintest at the rim.
				for ring in 5:
					cv.draw_circle(mp, (70.0 + q * 8.0) * (1.0 - ring * 0.16), Color(0.85, 0.88, 0.92, 0.0045))
	# Roads.
	for c in CampaignDefs.chapters_in_act(_act):
		var from_id := String(c["id"])
		if not _positions.has(from_id):
			continue
		for to in c.get("unlocks", []):
			var to_id := String(to)
			if not _positions.has(to_id):
				continue
			var lit: bool = ProfileManager.chapter_available(to_id) or to_id in s["cleared"]
			_draw_road(_positions[from_id], _positions[to_id], lit, from_id in s["cleared"] and to_id in s["cleared"])
	if _positions.has(_next_id) and int(CampaignDefs.find(_next_id).get("act", -1)) == _act:
		_draw_codex_standard(_positions[_next_id] + Vector2(-SEAL_R - 16.0, SEAL_R * 0.4))


## The hero's standard beside the chapter they march to next: a gilt pole and
## a vermilion swallowtail pennant that ripples.
func _draw_codex_standard(base: Vector2) -> void:
	var cv := _canvas
	var top := base + Vector2(0, -78)
	cv.draw_line(base + Vector2(1, 1), top + Vector2(1, 1), Color(0, 0, 0, 0.5), 3.0, true)
	cv.draw_line(base, top, CodexKit.GILT_LO, 2.5, true)
	cv.draw_line(base + Vector2(-0.6, 0), top + Vector2(-0.6, 0), CodexKit.GILT, 1.0, true)
	CodexKit.draw_lozenge(cv, top + Vector2(0, -4), 5.0, CodexKit.GILT_HI)
	var upper := PackedVector2Array()
	var lower := PackedVector2Array()
	var steps := 12
	for k in steps + 1:
		var t := float(k) / steps
		var wave := sin(_anim_t * 2.6 - t * 4.2) * 4.0 * t
		upper.append(top + Vector2(-2.0 - t * 44.0, 3.0 + wave))
		lower.append(top + Vector2(-2.0 - t * 44.0, 31.0 - t * 4.0 + wave))
	# Swallowtail: the free end is notched.
	var tail_wave := sin(_anim_t * 2.6 - 4.2) * 4.0
	var notch := top + Vector2(-34.0, 16.0 + tail_wave)
	var poly := PackedVector2Array(upper)
	poly.append(notch)
	lower.reverse()
	poly.append_array(lower)
	cv.draw_colored_polygon(poly, CodexKit.VERMILION.darkened(0.2))
	var hi := PackedVector2Array(upper)
	cv.draw_polyline(hi, Color(1, 0.75, 0.6, 0.35), 1.0, true)
	poly.append(poly[0])
	cv.draw_polyline(poly, Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.85), 1.2, true)
	var g := CodexKit.glyph(String({"barrosan": "bull", "lioraen": "lume", "vorthak": "drain"}.get(_hero_race(), "bull")))
	if g:
		var mid := top + Vector2(-16.0, 16.0 + sin(_anim_t * 2.6 - 1.5) * 1.6)
		cv.draw_texture_rect(g, Rect2(mid - Vector2(8, 8), Vector2(16, 16)), false, CodexKit.GILT_HI)
	cv.draw_arc(base, 7.0 + 2.0 * sin(_anim_t * 2.0), 0.0, TAU, 20, Color(CodexKit.GILT_HI.r, CodexKit.GILT_HI.g, CodexKit.GILT_HI.b, 0.45), 1.2, true)


func _draw_compass(cv: CanvasItem, c: Vector2, r: float) -> void:
	var col := Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.35)
	cv.draw_arc(c, r, 0, TAU, 48, col, 1.0, true)
	cv.draw_arc(c, r * 0.72, 0, TAU, 48, Color(col, 0.2), 1.0, true)
	var star := CodexKit.star_points(c, r * 0.95, 0.22)
	var out := PackedVector2Array(star)
	out.append(star[0])
	cv.draw_colored_polygon(star, Color(col, 0.12))
	cv.draw_polyline(out, col, 1.0, true)
	var small := CodexKit.star_points(c, r * 0.6, 0.3, 4, PI * 0.25)
	cv.draw_colored_polygon(small, Color(col, 0.1))
	var f := CodexKit.font(CodexKit.FONT_DISPLAY_BOLD)
	cv.draw_string(f, c + Vector2(-5, -r - 6), "N", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(CodexKit.VERMILION, 0.8))


func _draw_road(from: Vector2, to: Vector2, lit: bool, walked: bool) -> void:
	var cv := _canvas
	var mid := (from + to) * 0.5
	var normal := Vector2(-(to - from).y, (to - from).x).normalized()
	var ctrl := mid + normal * (to - from).length() * 0.1
	var pts := PackedVector2Array()
	for k in 49:
		var t := float(k) / 48.0
		pts.append(from.lerp(ctrl, t).lerp(ctrl.lerp(to, t), t))
	cv.draw_polyline(pts, Color(0, 0, 0, 0.55), 7.0, true)
	if walked:
		cv.draw_polyline(pts, Color(CodexKit.VERMILION.r, CodexKit.VERMILION.g, CodexKit.VERMILION.b, 0.85), 2.4, true)
	elif lit:
		cv.draw_polyline(pts, Color(1.0, 0.8, 0.4, 0.12), 10.0, true)
		var shift := int(_anim_t * 8.0) % 4
		for k in range(shift, 47, 4):
			cv.draw_line(pts[k], pts[mini(k + 2, 48)], CodexKit.GILT_HI, 2.4, true)
	else:
		for k in range(0, 47, 3):
			cv.draw_circle(pts[k], 1.3, Color(CodexKit.STAR_COLD.r, CodexKit.STAR_COLD.g, CodexKit.STAR_COLD.b, 0.5))


# --- codex page -----------------------------------------------------------------
func _show_page(id: String) -> void:
	if not is_instance_valid(_page_body):
		return
	for c in _page_body.get_children():
		c.queue_free()
	for c in _page_actions.get_children():
		c.queue_free()
	var c := CampaignDefs.find(id)
	if c.is_empty():
		return
	var s := ProfileManager.saga()
	var available := ProfileManager.chapter_available(id)
	var cleared: bool = id in s["cleared"]
	var act_title := String(CampaignDefs.ACTS[int(c["act"])]["title"])
	var kind := "side road" if bool(c.get("side", false)) else ("the Choice" if c.has("branch") else "chapter " + id.split("-")[1])
	_page_body.add_child(CodexKit.label("%s  ·  %s" % [act_title.split(": ")[0], kind], 19, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC))
	var title := CodexKit.illuminated(String(c["title"]), 32)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size = Vector2(300, 0)
	_page_body.add_child(title)
	# The matchup: your shield against theirs, and the difficulty as pips.
	var foe_ids: Array = []
	for o in c["opponents"]:
		if not foe_ids.has(String(o["race"])):
			foe_ids.append(String(o["race"]))
	var me := _hero_race()
	var steps := {"easy": 1, "normal": 2, "hard": 3, "brutal": 4}
	var pips: int = int(steps.get(String(c["difficulty"]).to_lower(), 2))
	var matchup := Control.new()
	matchup.custom_minimum_size = Vector2(0, 84)
	matchup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	matchup.draw.connect(func():
		var cy := 38.0
		_draw_shield(matchup, Vector2(34.0, cy), 26.0, me)
		var vs_f := CodexKit.font(CodexKit.FONT_SERIF_ITALIC)
		matchup.draw_string(vs_f, Vector2(74.0, cy + 7.0), "against", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, CodexKit.TEXT_MUTED)
		for k in foe_ids.size():
			_draw_shield(matchup, Vector2(178.0 + k * 62.0, cy), 26.0, String(foe_ids[k]))
		for k in 4:
			var pc := Vector2(matchup.size.x - 80.0 + k * 20.0, cy)
			matchup.draw_circle(pc, 6.0, CodexKit.VERMILION if k < pips else Color(0.18, 0.15, 0.13))
			matchup.draw_arc(pc, 6.0, 0, TAU, 16, Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.7), 1.0, true)
		var df := CodexKit.font(CodexKit.FONT_SERIF_ITALIC_BOLD)
		var dt := String(c["difficulty"])
		var dw := df.get_string_size(dt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		matchup.draw_string(df, Vector2(matchup.size.x - 50.0 - dw * 0.5, cy + 32.0), dt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CodexKit.TEXT_MUTED))
	_page_body.add_child(matchup)
	_page_body.add_child(_rule())
	if not available and not cleared:
		var sealed := CodexKit.label("This road is still sealed. Win the chapters before it to open it.", 19, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
		sealed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sealed.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(sealed)
		return
	var body := CodexKit.label(CampaignDefs.briefing_for(id, _hero_race()), 19, CodexKit.TEXT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(300, 0)
	_page_body.add_child(body)
	var foes: Array = []
	for o in c["opponents"]:
		foes.append(String(GameData.get_race(String(o["race"])).get("name", o["race"])))
	var suggested := 1 + int(round(CampaignDefs.index_of(id) * 1.2))
	var hero_level := int(ProfileManager.hero().get("level", 1))
	var facts: Array[String] = []
	facts.append("Hold out for %d minutes." % (int(c.get("survive", 0)) / 60) if int(c.get("survive", 0)) > 0 else "Destroy the enemy's ability to rebuild.")
	facts.append("Suggested hero level %d; yours is %d." % [suggested, hero_level])
	if bool(c.get("jar", false)):
		facts.append("A jar of Wine of the Dead lies here." if not (id in s["jars"]) else "You found this chapter's jar of Wine of the Dead.")
	for line in facts:
		var l := CodexKit.label(line, 18, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC_BOLD)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(l)
	var opening := String(c.get("opening", ""))
	if not opening.is_empty():
		_page_body.add_child(_rule())
		var epi := CodexKit.label("\u201c%s\u201d" % opening, 22, CodexKit.GILT_HI.darkened(0.08), CodexKit.FONT_SERIF_ITALIC)
		epi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		epi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		epi.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(epi)
	if cleared and not String(c.get("victory", "")).is_empty():
		_page_body.add_child(CodexKit.label("FROM THE CHRONICLE", 14, CodexKit.GILT, CodexKit.FONT_DISPLAY))
		var won := CodexKit.label(String(c["victory"]), 18, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
		won.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		won.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(won)
	if c.has("branch") and not cleared:
		var warn := CodexKit.label("This is the Choice. Marching here seals the other road forever.", 18, CodexKit.VERMILION.lightened(0.2), CodexKit.FONT_SERIF_ITALIC_BOLD)
		warn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		warn.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(warn)
	if cleared:
		var heroic := CodexKit.label("Won. A Heroic replay raises every enemy one step and pays half again in experience.", 17, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
		heroic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		heroic.custom_minimum_size = Vector2(300, 0)
		_page_body.add_child(heroic)
	if available:
		var march := _codex_button("March to war" if not cleared else "Fight again", func(): _on_node_pressed(id))
		march.name = "MarchButton"
		march.primary = true
		march.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		march.custom_minimum_size = Vector2(0, 52)
		_page_actions.add_child(march)
	if cleared:
		var replay := _codex_button("Heroic replay", func(): _on_node_pressed(id, true))
		replay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		replay.custom_minimum_size = Vector2(0, 52)
		_page_actions.add_child(replay)


func _rule() -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, 14)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.draw.connect(func(): CodexKit.draw_rule(c, Vector2(0, 7), Vector2(c.size.x, 7)))
	return c


func _process(delta: float) -> void:
	super._process(delta)
	if is_instance_valid(_act_layer):
		for child in _act_layer.get_children():
			child.queue_redraw()


# --- the Chronicle and the Act card --------------------------------------------------
func _open_endless(chosen_depth: int = -1, weekly: bool = false) -> void:
	Sfx.play("select")
	var depth := ProfileManager.endless_best() + 1 if chosen_depth < 1 else clampi(chosen_depth, 1, ProfileManager.endless_best() + 1)
	var st := EndlessDefs.stage(depth, _hero_race())
	if weekly:
		st = EndlessDefs.weekly(_hero_race())
		depth = int(st["depth"])
	var folio: Control = load("res://scripts/ui/codex/codex_endless.gd").new()
	folio.name = "EndlessRoad"
	folio.host = self
	folio.depth = depth
	folio.weekly = weekly
	folio.st = st
	add_child(folio)


func _open_chronicle() -> void:
	Sfx.play("page")
	var book: Control = load("res://scripts/ui/codex/codex_chronicle.gd").new()
	book.name = "Chronicle"
	book.hero_race = _hero_race()
	add_child(book)


## A new Act opens like a chapter page: the Act's wax seal, its name in an
## illuminated capital between gilt rules, and the line that sets its mood.
func _show_act_card(a: int) -> void:
	var layer := Control.new()
	layer.name = "ActCard"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var mood: Color = ACT_MOODS[a]
	var bg := ColorRect.new()
	bg.color = CodexKit.NIGHT
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(bg)
	# The Act's mood as a soft light behind its name.
	var grad := Gradient.new()
	var tint := Color(mood.r, mood.g, mood.b).lightened(0.15)
	grad.set_color(0, Color(tint, 0.42))
	grad.set_color(1, Color(tint, 0.0))
	grad.add_point(0.45, Color(tint, 0.14))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 512
	tex.height = 512
	var glow := TextureRect.new()
	glow.texture = tex
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	glow.offset_left = -760.0
	glow.offset_right = 760.0
	glow.offset_top = -560.0
	glow.offset_bottom = 480.0
	layer.add_child(glow)
	var born := _anim_t
	var seal := Control.new()
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	seal.draw.connect(func():
		var pulse := fmod((_anim_t - born) * 0.6, 1.0)
		CodexKit.draw_seal(seal, seal.size * 0.5 + Vector2(0, -190), 46.0, ROMAN[a], pulse))
	layer.add_child(seal)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.offset_top = 80.0
	box.add_theme_constant_override("separation", 12)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(box)
	var parts: PackedStringArray = String(CampaignDefs.ACTS[a]["title"]).split(": ")
	var kicker := CodexKit.label(parts[0].to_upper(), 20, CodexKit.GILT, CodexKit.FONT_DISPLAY_BOLD)
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var name_line := CodexKit.illuminated(parts[1] if parts.size() > 1 else parts[0], 58, CodexKit.GILT_HI)
	name_line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var rule := Control.new()
	rule.custom_minimum_size = Vector2(560, 22)
	rule.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rule.draw.connect(func(): CodexKit.draw_rule(rule, Vector2(0, 11), Vector2(rule.size.x, 11)))
	var sub := CodexKit.label(String(CampaignDefs.ACTS[a]["subtitle"]), 26, CodexKit.TEXT, CodexKit.FONT_SERIF_ITALIC)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var hint := CodexKit.label("Click to open the map", 17, CodexKit.TEXT_DIM, CodexKit.FONT_SERIF_ITALIC)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var lines: Array[Control] = [kicker, name_line, rule, sub, hint]
	for i in lines.size():
		box.add_child(lines[i])
		lines[i].modulate.a = 0.0
		lines[i].create_tween().tween_property(lines[i], "modulate:a", 1.0, 0.6).set_delay(0.3 + i * 0.3)
	var spin := create_tween().set_loops()
	spin.tween_callback(seal.queue_redraw).set_delay(1.0 / 30.0)
	layer.tree_exiting.connect(spin.kill)
	Sfx.play("horn", -8.0)
	layer.modulate.a = 0.0
	layer.create_tween().tween_property(layer, "modulate:a", 1.0, 0.8)
	layer.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			layer.queue_free())
