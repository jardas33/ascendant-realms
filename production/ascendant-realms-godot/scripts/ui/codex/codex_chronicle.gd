extends Control
## The Chronicle as an open codex: the left page lists every chapter of the
## saga (won ones sealed in wax, the rest still unwritten), the right page
## reads the chosen one, its briefing, its opening words and what came after.
## Opened from the campaign map; closing it frees it.

const CampaignDefs := preload("res://scripts/game/campaign_defs.gd")
const ROMAN := ["I", "II", "III", "IV", "V"]

var hero_race := "barrosan"
var _book: Control
var _left: VBoxContainer
var _right: VBoxContainer
var _won: Array[String] = []
var _selected := ""
var _rows := {}
var _prev: Button
var _next: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var s := ProfileManager.saga()
	for a in CampaignDefs.ACTS.size():
		for c in CampaignDefs.chapters_in_act(a):
			if String(c["id"]) in s["cleared"]:
				_won.append(String(c["id"]))
	var dim := ColorRect.new()
	dim.color = Color(CodexKit.NIGHT, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_book = Control.new()
	_book.name = "Book"
	_book.draw.connect(_draw_book)
	add_child(_book)
	_left = _page_column("Contents")
	_right = _page_column("Reading")
	_build_contents()
	_select(_won[-1] if not _won.is_empty() else "")
	resized.connect(_layout)
	_layout()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.3)


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()


func _page_column(n: String) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.name = n
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_book.add_child(scroll)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 8)
	scroll.add_child(col)
	return col


func _layout() -> void:
	var vp := size if size.x > 10.0 else get_viewport_rect().size
	var w := minf(vp.x - 80.0, 1560.0)
	var h := vp.y - 80.0
	_book.position = Vector2((vp.x - w) * 0.5, 40.0)
	_book.size = Vector2(w, h)
	var half := w * 0.5
	var pad := Vector2(56.0, 52.0)
	var lscroll: Control = _left.get_parent()
	lscroll.position = pad
	lscroll.size = Vector2(half - pad.x - 40.0, h - pad.y * 2.0)
	var rscroll: Control = _right.get_parent()
	rscroll.position = Vector2(half + 40.0, pad.y)
	rscroll.size = Vector2(half - pad.x - 40.0, h - pad.y * 2.0 - 70.0)
	var foot: Control = _book.get_node_or_null("Foot")
	if foot:
		foot.position = Vector2(half + 40.0, h - pad.y - 52.0)
		foot.size = Vector2(half - pad.x - 40.0, 52.0)


func _draw_book() -> void:
	var r := Rect2(Vector2.ZERO, _book.size)
	var half := r.size.x * 0.5
	CodexKit.draw_page(_book, Rect2(r.position, Vector2(half, r.size.y)), 14.0)
	CodexKit.draw_page(_book, Rect2(Vector2(half, 0), Vector2(half, r.size.y)), 14.0)
	# The spine: pages curl down into a shadowed gutter.
	for i in 14:
		var t := float(i) / 13.0
		var a := 0.42 * (1.0 - t) * (1.0 - t)
		_book.draw_rect(Rect2(half - 2.0 - i * 3.0, 0, 3.0, r.size.y), Color(0, 0, 0, a))
		_book.draw_rect(Rect2(half - 1.0 + i * 3.0, 0, 3.0, r.size.y), Color(0, 0, 0, a))
	_book.draw_line(Vector2(half, 0), Vector2(half, r.size.y), Color(0, 0, 0, 0.7), 2.0)


# --- left page: contents ---------------------------------------------------------
func _build_contents() -> void:
	var s := ProfileManager.saga()
	_left.add_child(CodexKit.illuminated("The Chronicle", 40, CodexKit.GILT_HI))
	var total := 0
	for a in CampaignDefs.ACTS.size():
		total += CampaignDefs.chapters_in_act(a).size()
	_left.add_child(CodexKit.label("of the Seventy-Seventh Ascension  ·  %d of %d chapters written" % [_won.size(), total], 20, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC))
	_left.add_child(_rule())
	for a in CampaignDefs.ACTS.size():
		var chapters := CampaignDefs.chapters_in_act(a)
		var reached := chapters.any(func(c): return String(c["id"]) in s["cleared"] or ProfileManager.chapter_available(String(c["id"])))
		var parts: PackedStringArray = String(CampaignDefs.ACTS[a]["title"]).split(": ")
		var head := HBoxContainer.new()
		head.add_theme_constant_override("separation", 10)
		var act_lbl := CodexKit.label("ACT %s" % ROMAN[a], 15, CodexKit.GILT if reached else CodexKit.TEXT_DIM, CodexKit.FONT_DISPLAY_BOLD)
		head.add_child(act_lbl)
		head.add_child(CodexKit.label(parts[1] if parts.size() > 1 and reached else ("" if reached else "still sealed"), 19, CodexKit.TEXT if reached else CodexKit.TEXT_DIM, CodexKit.FONT_SERIF_ITALIC_BOLD if reached else CodexKit.FONT_SERIF_ITALIC))
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, 6)
		_left.add_child(gap)
		_left.add_child(head)
		if not reached:
			continue
		for c in chapters:
			_left.add_child(_contents_row(c, s))


func _contents_row(c: Dictionary, s: Dictionary) -> Control:
	var id := String(c["id"])
	var won: bool = id in s["cleared"]
	var side := bool(c.get("side", false))
	var row := Button.new()
	row.name = "Row_" + id
	row.flat = true
	row.focus_mode = Control.FOCUS_NONE
	row.custom_minimum_size = Vector2(0, 38)
	row.disabled = not won
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if won else Control.CURSOR_ARROW
	for st in ["normal", "hover", "pressed", "disabled", "focus"]:
		row.add_theme_stylebox_override(st, StyleBoxEmpty.new())
	var title := String(c["title"]) if won else ("Unwritten side road" if side else "Unwritten chapter")
	var heroic: bool = id in s.get("heroic", [])
	row.draw.connect(func():
		var cy := row.size.y * 0.5
		var cx := 34.0 if side else 18.0
		var sel := id == _selected
		if sel:
			var band := Color(CodexKit.VERMILION, 0.14)
			row.draw_rect(Rect2(0, 2, row.size.x, row.size.y - 4), band)
			row.draw_rect(Rect2(0, 2, 3, row.size.y - 4), CodexKit.VERMILION)
		if won:
			CodexKit.draw_seal(row, Vector2(cx, cy + 1.0), 13.0 if not side else 11.0, id.split("-")[1].replace("S", "") if not side else "✦")
		else:
			row.draw_arc(Vector2(cx, cy), 10.0, 0, TAU, 24, Color(CodexKit.TEXT_DIM, 0.6), 1.0, true)
		var f := CodexKit.font(CodexKit.FONT_DISPLAY if won else CodexKit.FONT_SERIF_ITALIC)
		var fs := 17 if won else 18
		var col := CodexKit.TEXT if won else CodexKit.TEXT_DIM
		if won and (row.is_hovered() or sel):
			col = CodexKit.GILT_HI
		row.draw_string(f, Vector2(cx + 24.0, cy + 6.0), title, HORIZONTAL_ALIGNMENT_LEFT, row.size.x - cx - 140.0, fs, col)
		if heroic:
			var hf := CodexKit.font(CodexKit.FONT_SERIF_ITALIC)
			var hw := hf.get_string_size("heroic laurel", HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
			row.draw_string(hf, Vector2(row.size.x - hw - 8.0, cy + 6.0), "heroic laurel", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, CodexKit.GILT))
	row.mouse_entered.connect(row.queue_redraw)
	row.mouse_exited.connect(row.queue_redraw)
	row.pressed.connect(func(): _select(id))
	_rows[id] = row
	return row


# --- right page: the chapter -------------------------------------------------------
func _select(id: String) -> void:
	_selected = id
	for r in _rows.values():
		r.queue_redraw()
	for c in _right.get_children():
		c.queue_free()
	if id.is_empty():
		var none := CodexKit.label("No chapter has been written yet. Win the first battle of the saga and the Chronicle begins.", 21, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)
		none.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		none.custom_minimum_size = Vector2(300, 0)
		_right.add_child(none)
		_build_foot()
		return
	var s := ProfileManager.saga()
	var c := CampaignDefs.find(id)
	var act := int(c["act"])
	var kind := "side road" if bool(c.get("side", false)) else ("the Choice" if c.has("branch") else "chapter " + id.split("-")[1])
	var kicker := "Act %s  ·  %s" % [ROMAN[act], kind]
	if id in s.get("heroic", []):
		kicker += "  ·  won with the heroic laurel"
	_right.add_child(CodexKit.label(kicker, 19, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC))
	var title := CodexKit.illuminated(String(c["title"]), 36, CodexKit.GILT_HI)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.custom_minimum_size = Vector2(300, 0)
	_right.add_child(title)
	_right.add_child(_rule())
	var brief := CodexKit.label(CampaignDefs.briefing_for(id, hero_race), 20, CodexKit.TEXT)
	brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	brief.custom_minimum_size = Vector2(300, 0)
	_right.add_child(brief)
	var opening := String(c.get("opening", ""))
	if not opening.is_empty():
		var epi := CodexKit.label("“%s”" % opening, 23, CodexKit.GILT_HI.darkened(0.08), CodexKit.FONT_SERIF_ITALIC)
		epi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		epi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		epi.custom_minimum_size = Vector2(300, 0)
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, 4)
		_right.add_child(gap)
		_right.add_child(epi)
	_right.add_child(_rule())
	_right.add_child(CodexKit.label("AND AFTER", 15, CodexKit.GILT, CodexKit.FONT_DISPLAY_BOLD))
	var after := CodexKit.label(CampaignDefs.victory_text(id, s), 20, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC_BOLD)
	after.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	after.custom_minimum_size = Vector2(300, 0)
	_right.add_child(after)
	var taunts: Array = c.get("taunts", [])
	if not taunts.is_empty():
		var gap2 := Control.new()
		gap2.custom_minimum_size = Vector2(0, 6)
		_right.add_child(gap2)
		_right.add_child(CodexKit.label("HEARD ON THE FIELD", 15, CodexKit.GILT, CodexKit.FONT_DISPLAY_BOLD))
		for t in taunts:
			var tl := CodexKit.label(String(t), 18, CodexKit.TEXT_DIM.lightened(0.2), CodexKit.FONT_SERIF_ITALIC)
			tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			tl.custom_minimum_size = Vector2(300, 0)
			_right.add_child(tl)
	_build_foot()
	Sfx.play("page")


func _build_foot() -> void:
	var foot: HBoxContainer = _book.get_node_or_null("Foot")
	if foot == null:
		foot = HBoxContainer.new()
		foot.name = "Foot"
		foot.add_theme_constant_override("separation", 12)
		_book.add_child(foot)
		_prev = _button("Earlier", func(): _step(-1))
		_next = _button("Later", func(): _step(1))
		foot.add_child(_prev)
		foot.add_child(_next)
		var spacer := Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		foot.add_child(spacer)
		var close := _button("Close the book", queue_free)
		close.name = "CloseButton"
		close.primary = true
		foot.add_child(close)
		_layout()
	var i := _won.find(_selected)
	_prev.disabled = i <= 0
	_next.disabled = i < 0 or i >= _won.size() - 1
	_prev.queue_redraw()
	_next.queue_redraw()


func _step(d: int) -> void:
	var i := _won.find(_selected) + d
	if i >= 0 and i < _won.size():
		_select(_won[i])


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.set_script(load("res://scripts/ui/codex/codex_button.gd"))
	b.text = text
	b.custom_minimum_size = Vector2(150, 48)
	b.pressed.connect(cb)
	return b


func _rule() -> Control:
	var r := Control.new()
	r.custom_minimum_size = Vector2(0, 22)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.draw.connect(func(): CodexKit.draw_rule(r, Vector2(8, 11), Vector2(r.size.x - 8, 11)))
	return r
