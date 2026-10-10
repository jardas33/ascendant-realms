extends Control
## The Endless Road as a codex folio: the stage's name and story, the enemy
## shields, its twists as a rubricated list, the milestones ahead drawn as a
## marching road, and the hero's records. Rules and data stay in EndlessDefs
## and campaign_map.gd; this only presents one stage.

const EndlessDefs := preload("res://scripts/game/endless_defs.gd")

var host: Control            # the campaign map: shields, launching, reopening
var depth := 1
var weekly := false
var st: Dictionary = {}
var _folio: Control
var _col: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(CodexKit.NIGHT, 0.88)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	_folio = Control.new()
	_folio.name = "Folio"
	_folio.draw.connect(func(): CodexKit.draw_page(_folio, Rect2(Vector2.ZERO, _folio.size), 14.0))
	add_child(_folio)
	_col = VBoxContainer.new()
	_col.add_theme_constant_override("separation", 10)
	_folio.add_child(_col)
	_build()
	resized.connect(_layout)
	_layout()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.25)


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel"):
		queue_free()
		get_viewport().set_input_as_handled()


func _layout() -> void:
	var vp := size if size.x > 10.0 else get_viewport_rect().size
	var w := minf(960.0, vp.x - 80.0)
	_col.position = Vector2(56, 44)
	_col.size = Vector2(w - 112.0, 0)
	_col.reset_size()
	var h := minf(_col.get_combined_minimum_size().y + 88.0, vp.y - 60.0)
	_folio.size = Vector2(w, h)
	_folio.position = (vp - _folio.size) * 0.5
	_col.size = Vector2(w - 112.0, h - 88.0)


func _build() -> void:
	var kicker := "The Endless Road  ·  stage %d" % depth
	if weekly:
		var days_left := 7 - int(fmod(Time.get_unix_time_from_system(), 604800.0) / 86400.0)
		kicker = "Road of the Week  ·  a new road in %d day%s" % [days_left, "" if days_left == 1 else "s"]
	_col.add_child(_centered(CodexKit.label(kicker, 20, CodexKit.TEXT_MUTED, CodexKit.FONT_SERIF_ITALIC)))
	var title := CodexKit.illuminated(String(st["title"]), 40, CodexKit.GILT_HI)
	title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_col.add_child(title)
	var story := String(st["festival"]) if String(st.get("festival", "")) != "" else "The saga ends, but the Lume does not. Every Ascension leaves roads that never close, and something always waits on them. Each stage is harder than the last, and pays more."
	_col.add_child(_para(story, 20, CodexKit.TEXT, CodexKit.FONT_BODY, true))
	_col.add_child(_rule())
	_col.add_child(_matchup())
	# Twists, mutations, the Tyrant: the rubric of this stage.
	var rubric: Array = []
	for tw_id in st.get("twists", []):
		rubric.append(String(EndlessDefs.TWIST_TEXT.get(tw_id, tw_id)))
	var muts: Dictionary = st.get("mutations", {})
	for mk in muts:
		rubric.append("%s (x%d)" % [String(EndlessDefs.MUTATIONS.get(mk, mk)), int(muts[mk])])
	var road_boss: Dictionary = EndlessDefs.boss(depth)
	if not road_boss.is_empty():
		rubric.append("Road Tyrant: %s. %s" % [String(road_boss["name"]), String(road_boss["text"])])
	elif depth % 5 == 0 and depth % 10 != 0:
		rubric.append("Champion stage: a giant guards the enemy stronghold and pays like three Elites.")
	if float(st["might"]) > 0.0:
		rubric.append("Enemy Lume swollen: +%d%% income." % int(float(st["might"]) * 100.0 / 3.0))
	if not rubric.is_empty():
		_col.add_child(_heading("ON THIS ROAD"))
		for line in rubric:
			_col.add_child(_bullet(String(line), CodexKit.VERMILION.lightened(0.15)))
	var seen: Array = []
	var foe_lines: Array = []
	for o in st["opponents"]:
		var r := String(o["race"])
		if seen.has(r):
			continue
		seen.append(r)
		var mech := String(GameData.get_race(r).get("mechanic", ""))
		if mech != "":
			foe_lines.append("%s. %s" % [GameData.get_race(r).get("name", r), mech])
	if not foe_lines.is_empty():
		_col.add_child(_heading("KNOW YOUR FOE"))
		for line in foe_lines:
			_col.add_child(_bullet(String(line), CodexKit.GILT))
	if not weekly:
		_col.add_child(_heading("THE ROAD AHEAD"))
		_col.add_child(_track())
	_col.add_child(_records())
	_col.add_child(_actions())


# --- pieces -------------------------------------------------------------------------
func _matchup() -> Control:
	var foes: Array = st["opponents"]
	var m := Control.new()
	m.custom_minimum_size = Vector2(0, 92)
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var me := String(host.call("_hero_race")) if host else "barrosan"
	m.draw.connect(func():
		var n := foes.size()
		var block := 130.0 + n * 92.0
		var x := (m.size.x - block) * 0.5
		var cy := 36.0
		if host:
			host.call("_draw_shield", m, Vector2(x + 30.0, cy), 26.0, me)
		var vs_f := CodexKit.font(CodexKit.FONT_SERIF_ITALIC)
		m.draw_string(vs_f, Vector2(x + 66.0, cy + 7.0), "against", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, CodexKit.TEXT_MUTED)
		var df := CodexKit.font(CodexKit.FONT_SERIF_ITALIC_BOLD)
		for k in n:
			var o: Dictionary = foes[k]
			var p := Vector2(x + 176.0 + k * 92.0, cy)
			if host:
				host.call("_draw_shield", m, p, 26.0, String(o["race"]))
			var d := String(o["difficulty"]).capitalize()
			var dw := df.get_string_size(d, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
			m.draw_string(df, p + Vector2(-dw * 0.5, 50.0), d, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, CodexKit.TEXT_MUTED))
	return m


## The milestones ahead as waypoints on a gilt road, spaced by distance.
func _track() -> Control:
	var best_now := ProfileManager.endless_best()
	var next_tyrant := (depth / 25 + 1) * 25 if depth % 25 != 0 else depth
	var next_fest := (depth / 10 + 1) * 10 if depth % 10 != 0 else depth
	var next_relic := maxi(depth, (best_now / 5 + 1) * 5)
	if next_relic % 5 != 0:
		next_relic = (next_relic / 5 + 1) * 5
	var next_mut := maxi(30, (depth / 30 + 1) * 30)
	var fest_name := String(EndlessDefs.FESTIVALS[(next_fest / 10 - 1) % EndlessDefs.FESTIVALS.size()]["title"])
	var tyrant_name := String(EndlessDefs.boss(next_tyrant).get("name", "?"))
	var marks: Array = [
		[next_relic, "gold", "Relic", ""], [next_fest, "candle", "Festival", fest_name],
		[next_tyrant, "slam", "Road Tyrant", tyrant_name], [next_mut, "mask", "Mutation", ""]]
	marks.sort_custom(func(a, b): return int(a[0]) < int(b[0]))
	var far := float(maxi(next_mut, next_tyrant) - depth + 1)
	var t := Control.new()
	t.custom_minimum_size = Vector2(0, 128)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.draw.connect(func():
		var x0 := 44.0
		var x1 := t.size.x - 50.0
		var y := 40.0
		t.draw_line(Vector2(x0, y), Vector2(x1, y), Color(0, 0, 0, 0.55), 6.0, true)
		var k := 0
		while x0 + k * 14.0 < x1:
			t.draw_line(Vector2(x0 + k * 14.0, y), Vector2(minf(x0 + k * 14.0 + 7.0, x1), y), Color(CodexKit.GILT.r, CodexKit.GILT.g, CodexKit.GILT.b, 0.8), 2.2, true)
			k += 1
		CodexKit.draw_seal(t, Vector2(x0, y), 20.0, str(depth))
		var df := CodexKit.font(CodexKit.FONT_DISPLAY)
		var sf := CodexKit.font(CodexKit.FONT_SERIF_ITALIC)
		# Milestones on the same stage share one waypoint and stack captions.
		var groups := {}
		var order: Array = []
		for m in marks:
			if not groups.has(int(m[0])):
				groups[int(m[0])] = []
				order.append(int(m[0]))
			groups[int(m[0])].append(m)
		for stage in order:
			var fx := x0 + (x1 - x0) * clampf(float(stage - depth) / far, 0.14, 1.0)
			var p := Vector2(fx, y)
			var ms: Array = groups[stage]
			var n := ms.size()
			for j in n:
				var q := p + Vector2((j - (n - 1) * 0.5) * 30.0, 0)
				t.draw_circle(q, 16.0, Color(0.06, 0.045, 0.035))
				t.draw_arc(q, 16.0, 0, TAU, 32, CodexKit.GILT, 1.6, true)
				var g := CodexKit.glyph(String(ms[j][1]))
				if g:
					t.draw_texture_rect(g, Rect2(q - Vector2(10, 10), Vector2(20, 20)), false, CodexKit.GILT_HI)
			var cy := y + 40.0
			var sw := df.get_string_size("STAGE %d" % stage, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
			t.draw_string(df, Vector2(clampf(fx - sw * 0.5, 0.0, t.size.x - sw), cy), "STAGE %d" % stage, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, CodexKit.GILT)
			for m in ms:
				cy += 19.0
				var cap := String(m[2]) if String(m[3]) == "" else "%s: %s" % [String(m[2]), String(m[3])]
				var cw := sf.get_string_size(cap, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
				t.draw_string(sf, Vector2(clampf(fx - cw * 0.5, 0.0, t.size.x - cw), cy), cap, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, CodexKit.TEXT))
	return t


func _records() -> Control:
	var race_now := String(ProfileManager.hero().get("race", "")) if ProfileManager.has_hero() else ""
	var fastest := ProfileManager.endless_fastest(depth)
	var cells: Array = [
		["Experience", "x%.2f" % float(st["xp_mult"])],
		["Deepest won", str(ProfileManager.endless_best())]]
	if race_now != "":
		cells.append(["Best as %s" % String(GameData.get_race(race_now).get("name", race_now)).trim_prefix("The "), str(ProfileManager.endless_best_for(race_now))])
	if weekly:
		var wk := ProfileManager.endless_fastest_key("w%d" % int(st["weekly"]))
		cells.append(["Your best this week", "%d:%02d" % [int(wk) / 60, int(wk) % 60] if wk > 0.0 else "none yet"])
	else:
		cells.append(["Fastest clear", "%d:%02d" % [int(fastest) / 60, int(fastest) % 60] if fastest > 0.0 else "none yet"])
	var box := Control.new()
	box.custom_minimum_size = Vector2(0, 86)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.draw.connect(func():
		CodexKit.draw_rule(box, Vector2(0, 6), Vector2(box.size.x, 6), false)
		var n := cells.size()
		var cw := box.size.x / n
		var vf := CodexKit.font(CodexKit.FONT_DISPLAY_BOLD)
		var lf := CodexKit.font(CodexKit.FONT_SERIF_ITALIC)
		for i in n:
			var cx := cw * (i + 0.5)
			var v := String(cells[i][1])
			var vw := vf.get_string_size(v, HORIZONTAL_ALIGNMENT_LEFT, -1, 26).x
			box.draw_string(vf, Vector2(cx - vw * 0.5, 44), v, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, CodexKit.GILT_HI)
			var l := String(cells[i][0])
			var lw := lf.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x
			box.draw_string(lf, Vector2(cx - lw * 0.5, 68), l, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, CodexKit.TEXT_MUTED)
			if i > 0:
				CodexKit.draw_lozenge(box, Vector2(cw * i, 40), 3.5, CodexKit.GILT)
		CodexKit.draw_rule(box, Vector2(0, box.size.y - 4), Vector2(box.size.x, box.size.y - 4), false))
	return box


func _actions() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(_button("Back", queue_free))
	if weekly:
		row.add_child(_button("The Endless Road", func(): _reopen(-1, false)))
	else:
		var prev := _button("Stage %d" % (depth - 1), func(): _reopen(depth - 1, false))
		prev.disabled = depth <= 1
		row.add_child(prev)
		var nxt := _button("Stage %d" % (depth + 1), func(): _reopen(depth + 1, false))
		nxt.disabled = depth > ProfileManager.endless_best()
		row.add_child(nxt)
		row.add_child(_button("Road of the Week", func(): _reopen(-1, true)))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var march := _button("March on", func(): host.call("_launch_endless", st))
	march.name = "MarchButton"
	march.primary = true
	march.custom_minimum_size = Vector2(200, 52)
	row.add_child(march)
	return row


func _reopen(d: int, w: bool) -> void:
	var h := host
	queue_free()
	h.call("_open_endless", d, w)


func _button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.set_script(load("res://scripts/ui/codex/codex_button.gd"))
	b.text = text
	b.custom_minimum_size = Vector2(0, 52)
	b.pressed.connect(cb)
	return b


func _heading(text: String) -> Control:
	var l := CodexKit.label(text, 15, CodexKit.GILT, CodexKit.FONT_DISPLAY_BOLD)
	var wrap := MarginContainer.new()
	wrap.add_theme_constant_override("margin_top", 6)
	wrap.add_child(l)
	return wrap


func _bullet(text: String, mark: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var dot := Control.new()
	dot.custom_minimum_size = Vector2(12, 24)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.draw.connect(func(): CodexKit.draw_lozenge(dot, Vector2(6, 13), 5.0, mark))
	row.add_child(dot)
	var l := _para(text, 19, CodexKit.TEXT, CodexKit.FONT_BODY, false)
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(l)
	return row


func _para(text: String, fs: int, col: Color, face: String, centred: bool) -> Label:
	var l := CodexKit.label(text, fs, col, face)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(300, 0)
	if centred:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _centered(l: Label) -> Label:
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _rule() -> Control:
	var r := Control.new()
	r.custom_minimum_size = Vector2(0, 22)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.draw.connect(func(): CodexKit.draw_rule(r, Vector2(60, 11), Vector2(r.size.x - 60, 11)))
	return r
