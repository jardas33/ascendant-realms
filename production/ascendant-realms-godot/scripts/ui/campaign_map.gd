extends Control
## Campaign Map: the Saga of the Seventy-Seventh Ascension (CampaignDefs).
## Five Acts, each a page of battles along a main road with optional side
## roads. Clicking a battle opens its chronicle briefing; "March to war"
## starts it. The jars of Wine of the Dead and the Rabagão Wall choice are
## shown in the header.
const CampaignDefs := preload("res://scripts/game/campaign_defs.gd")
const EndlessDefs := preload("res://scripts/game/endless_defs.gd")

const FONT := "res://assets/fonts/cinzel.ttf"
const BG   := "res://assets/textures/backgrounds/main_menu_bg.png"
const THEME_PATH := "res://assets/ui/theme.tres"
const REGION_BUTTON_SCRIPT := preload("res://scripts/ui/campaign_region_button.gd")
const PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")

const NODE_SIZE := Vector2(200, 96)
const DIFF_COLORS := {
	"Easy":   Color(0.4, 0.85, 0.45),
	"Normal": Color(0.7, 0.85, 0.3),
	"Hard":   Color(0.95, 0.6, 0.2),
	"Brutal": Color(0.95, 0.25, 0.2),
}

var _canvas: Control
var _desc_label: Label
var _act := 0
var _act_layer: Control
var _act_title: Label
var _act_subtitle: Label
var _act_buttons: Array = []
var _positions := {}          # chapter id -> Vector2 centre
var _next_id := "1-1"
var _briefing: Control
var _mood: ColorRect
## Each Act tints the realm map: ember for the raid, drowned teal, grave
## blue-grey, Dominion bronze, and the violet of the Ascension.
const ACT_MOODS := [Color(0.55, 0.25, 0.05, 0.16), Color(0.05, 0.35, 0.40, 0.16), Color(0.25, 0.30, 0.45, 0.20), Color(0.55, 0.42, 0.12, 0.16), Color(0.40, 0.12, 0.55, 0.20)]

# --------------------------------------------------------------------------
func _ready() -> void:
	_next_id = _find_next_chapter()
	var next := CampaignDefs.find(_next_id)
	_act = int(next.get("act", 0))
	_build()

func _title_font() -> Font:
	if ResourceLoader.exists(FONT):
		return load(FONT)
	return ThemeDB.fallback_font

func _hero_race() -> String:
	var h: Dictionary = ProfileManager.hero()
	if h.is_empty():
		return "barrosan"
	return str(h.get("race", "barrosan"))

## The first unlocked, uncleared main-road chapter (else the first side road).
func _find_next_chapter() -> String:
	var s := ProfileManager.saga()
	var fallback := ""
	for c in CampaignDefs.all():
		var id := String(c["id"])
		if not ProfileManager.chapter_available(id) or id in s["cleared"]:
			continue
		if not bool(c.get("side", false)):
			return id
		if fallback == "":
			fallback = id
	return fallback if fallback != "" else "5-7"

func _label(text: String, size: int, col: Color, title_font := false) -> Label:
	var l := Label.new()
	l.text = text
	# Story text reads in the plain body face; Cinzel small caps is for titles.
	l.add_theme_font_override("font", _title_font() if title_font else ThemeDB.fallback_font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 4 if title_font else 2)
	return l

# --------------------------------------------------------------------------
func _build() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(BG):
		bg.texture = load(BG)
	add_child(bg)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.07, 0.6)
	add_child(scrim)
	_mood = ColorRect.new()
	_mood.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_mood.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mood)

	var title := _label("The Seventy-Seventh Ascension", 38, Color(0.97, 0.92, 0.68), true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 10.0
	title.offset_bottom = 60.0
	add_child(title)

	# Hero, jars and choice.
	var s := ProfileManager.saga()
	var h: Dictionary = ProfileManager.hero()
	var hero_line := "No Jardas yet. Forge one from the main menu." if h.is_empty() else "%s, Jardas of the %s  ·  Level %d" % [str(h.get("name", "Hero")), str(GameData.get_race(_hero_race()).get("name", _hero_race())), int(h.get("level", 1))]
	var jars := "Wine of the Dead: %d / %d jars" % [s["jars"].size(), CampaignDefs.JARS_TOTAL]
	var choice := ""
	if String(s["choice"]) == "break":
		choice = "  ·  The Wall is broken"
	elif String(s["choice"]) == "seize":
		choice = "  ·  The Wall is yours"
	var banner := _label("%s  ·  %s%s" % [hero_line, jars, choice], 16, Color(0.85, 0.78, 0.5), true)
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	banner.offset_top = 60.0
	banner.offset_bottom = 86.0
	add_child(banner)

	# Act tabs.
	var tabs := HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 10)
	tabs.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	tabs.offset_top = 92.0
	tabs.offset_bottom = 132.0
	add_child(tabs)
	for a in CampaignDefs.ACTS.size():
		var b := Button.new()
		b.text = ["I", "II", "III", "IV", "V"][a]
		b.custom_minimum_size = Vector2(64, 38)
		b.focus_mode = Control.FOCUS_NONE
		if ResourceLoader.exists(THEME_PATH):
			b.theme = load(THEME_PATH)
		b.add_theme_font_override("font", _title_font())
		b.add_theme_font_size_override("font_size", 18)
		b.disabled = not _act_reached(a)
		b.tooltip_text = String(CampaignDefs.ACTS[a]["title"]) if _act_reached(a) else "Sealed"
		b.pressed.connect(func(): _show_act(a))
		tabs.add_child(b)
		_act_buttons.append(b)

	_act_title = _label("", 26, Color(0.98, 0.84, 0.46), true)
	_act_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_act_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_act_title.offset_top = 136.0
	_act_title.offset_bottom = 172.0
	add_child(_act_title)
	_act_subtitle = _label("", 16, Color(0.82, 0.78, 0.68))
	_act_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_act_subtitle.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_act_subtitle.offset_top = 170.0
	_act_subtitle.offset_bottom = 196.0
	add_child(_act_subtitle)

	_canvas = Control.new()
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_canvas.draw.connect(_draw_path)
	add_child(_canvas)
	_act_layer = Control.new()
	_act_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_act_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_act_layer)

	var desc_panel := Panel.new()
	desc_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	desc_panel.offset_top = -168.0
	desc_panel.offset_bottom = -72.0
	desc_panel.offset_left = 180.0
	desc_panel.offset_right = -180.0
	var story_style := StyleBoxFlat.new()
	story_style.bg_color = Color(0.027, 0.035, 0.048, 0.92)
	story_style.border_color = Color(0.70, 0.57, 0.35, 0.66)
	story_style.border_width_top = 2
	story_style.border_width_bottom = 1
	story_style.set_content_margin_all(12)
	desc_panel.add_theme_stylebox_override("panel", story_style)
	add_child(desc_panel)
	_desc_label = Label.new()
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_override("font", ThemeDB.fallback_font)
	_desc_label.add_theme_font_size_override("font_size", 18)
	_desc_label.add_theme_color_override("font_color", Color(0.88, 0.86, 0.78))
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_desc_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_desc_label.offset_left = 12.0
	_desc_label.offset_right = -12.0
	desc_panel.add_child(_desc_label)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(190, 50)
	back.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		back.theme = load(THEME_PATH)
	back.add_theme_font_override("font", _title_font())
	back.add_theme_font_size_override("font_size", 20)
	back.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	back.offset_left = 36.0
	back.offset_top = -66.0
	back.offset_bottom = -16.0
	back.offset_right = 226.0
	back.pressed.connect(_on_back_pressed)
	add_child(back)

	# The Chronicle: every cleared chapter's story, to reread in order.
	var chronicle := Button.new()
	chronicle.text = "Chronicle"
	chronicle.custom_minimum_size = Vector2(190, 50)
	chronicle.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		chronicle.theme = load(THEME_PATH)
	chronicle.add_theme_font_override("font", _title_font())
	chronicle.add_theme_font_size_override("font_size", 20)
	chronicle.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	chronicle.offset_left = -226.0
	chronicle.offset_right = -36.0
	chronicle.offset_top = -66.0
	chronicle.offset_bottom = -16.0
	chronicle.disabled = ProfileManager.saga()["cleared"].is_empty()
	chronicle.pressed.connect(_open_chronicle)
	add_child(chronicle)

	# The Endless Road opens once the first chapter is won.
	var endless := Button.new()
	endless.text = "Endless Road"
	endless.custom_minimum_size = Vector2(210, 50)
	endless.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		endless.theme = load(THEME_PATH)
	endless.add_theme_font_override("font", _title_font())
	endless.add_theme_font_size_override("font_size", 20)
	endless.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	endless.offset_left = -456.0
	endless.offset_right = -246.0
	endless.offset_top = -66.0
	endless.offset_bottom = -16.0
	endless.disabled = ProfileManager.saga()["cleared"].is_empty()
	endless.pressed.connect(_open_endless)
	add_child(endless)

	_show_act(_act)
	# Arriving from the main menu's Endless Road button.
	if Match.has_meta("open_endless"):
		Match.remove_meta("open_endless")
		call_deferred("_open_endless")
		return
	# A new Act is announced once, the first time the map shows it; after a
	# victory the next chronicle opens by itself.
	var saga_state := ProfileManager.saga()
	if not saga_state.has("seen_acts"):
		saga_state["seen_acts"] = []
	var fresh_act: bool = not (_act in saga_state["seen_acts"])
	if fresh_act:
		saga_state["seen_acts"].append(_act)
		_show_act_card(_act)
	elif bool(saga_state.get("auto_brief", false)) and ProfileManager.chapter_available(_next_id):
		_open_briefing(_next_id)
	saga_state["auto_brief"] = false
	ProfileManager.save_game()

## A book of the saga so far: each cleared chapter's briefing and the
## chronicle of its victory, act by act, in road order.
## The Endless Road: the next stage's battle, with no last stage.
func _open_endless(chosen_depth: int = -1) -> void:
	Sfx.play("select")
	# Any stage reached can be replayed (for loot and bounties); first clears
	# still pay the milestones only once.
	var depth := ProfileManager.endless_best() + 1 if chosen_depth < 1 else clampi(chosen_depth, 1, ProfileManager.endless_best() + 1)
	var st := EndlessDefs.stage(depth, _hero_race())
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var plate: PanelContainer = PLATE_SCRIPT.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.TRANSPARENT
	ps.content_margin_left = 52.0
	ps.content_margin_right = 52.0
	ps.content_margin_top = 30.0
	ps.content_margin_bottom = 30.0
	plate.add_theme_stylebox_override("panel", ps)
	plate.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.grow_vertical = Control.GROW_DIRECTION_BOTH
	plate.custom_minimum_size = Vector2(760, 0)
	layer.add_child(plate)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	plate.add_child(box)
	var head := _label("THE ENDLESS ROAD  ·  STAGE %d" % depth, 16, Color(0.75, 0.68, 0.52), true)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(head)
	var t := _label(String(st["title"]), 34, Color(0.98, 0.84, 0.46), true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var body := _label(String(st["festival"]) if String(st.get("festival", "")) != "" else "The saga ends, but the Lume does not. Every Ascension leaves roads that never close, and something always waits on them. Each stage is harder than the last, and pays more.", 17, Color(0.92, 0.89, 0.80))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(656, 0)
	box.add_child(body)
	var foes: Array = []
	for o in st["opponents"]:
		foes.append("%s (%s)" % [GameData.get_race(String(o["race"])).get("name", o["race"]), String(o["difficulty"]).capitalize()])
	var extra := "   ·   Enemy Lume swollen: +%d%% income" % int(float(st["might"]) * 100.0 / 3.0) if float(st["might"]) > 0.0 else ""
	var twist_lines: Array = []
	for tw_id in st.get("twists", []):
		twist_lines.append(String(EndlessDefs.TWIST_TEXT.get(tw_id, tw_id)))
	if depth % 5 == 0 and depth % 10 != 0:
		twist_lines.append("Champion stage: a giant guards the enemy stronghold (pays like three Elites)")
	if not twist_lines.is_empty():
		var tw := _label("Twists: " + "  ·  ".join(twist_lines), 15, Color(0.95, 0.62, 0.42))
		tw.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(tw)
	var meta := _label("Enemies: %s%s\nExperience: x%.2f   ·   Deepest stage won: %d" % [", ".join(foes), extra, float(st["xp_mult"]), ProfileManager.endless_best()], 15, Color(0.85, 0.72, 0.45))
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(meta)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var picks: Array = [["Back", func(): layer.queue_free()]]
	if depth > 1:
		picks.append(["< Stage %d" % (depth - 1), func(): layer.queue_free(); _open_endless(depth - 1)])
	if depth <= ProfileManager.endless_best():
		picks.append(["Stage %d >" % (depth + 1), func(): layer.queue_free(); _open_endless(depth + 1)])
	picks.append(["March On", func(): _launch_endless(st)])
	for spec in picks:
		var b := Button.new()
		b.text = String(spec[0])
		b.custom_minimum_size = Vector2(220, 54)
		b.focus_mode = Control.FOCUS_NONE
		if ResourceLoader.exists(THEME_PATH):
			b.theme = load(THEME_PATH)
		b.add_theme_font_override("font", _title_font())
		b.add_theme_font_size_override("font_size", 20)
		b.pressed.connect(spec[1])
		row.add_child(b)

func _launch_endless(st: Dictionary) -> void:
	Sfx.play("select")
	var cfg: Dictionary = Match.default_config()
	cfg["player_race"] = _hero_race()
	cfg["opponents"] = st["opponents"].duplicate(true)
	cfg["mode"] = "endless"
	cfg["victory"] = "conquest"
	cfg["map"] = String(st["map"])
	cfg["endless_depth"] = int(st["depth"])
	cfg["endless_title"] = String(st["title"])
	cfg["endless_might"] = float(st["might"])
	cfg["endless_xp_mult"] = float(st["xp_mult"])
	cfg["twists"] = st.get("twists", []).duplicate()
	cfg["mood"] = String(st.get("mood", ""))
	Match.set_config(cfg)
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 1.5)

func _open_chronicle() -> void:
	Sfx.play("select")
	var s := ProfileManager.saga()
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.78)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var plate: PanelContainer = PLATE_SCRIPT.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.TRANSPARENT
	ps.content_margin_left = 52.0
	ps.content_margin_right = 40.0
	ps.content_margin_top = 28.0
	ps.content_margin_bottom = 24.0
	plate.add_theme_stylebox_override("panel", ps)
	plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.offset_left = 180.0
	plate.offset_right = -180.0
	plate.offset_top = 50.0
	plate.offset_bottom = -50.0
	layer.add_child(plate)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	plate.add_child(outer)
	var head := _label("The Chronicle of the Seventy-Seventh Ascension", 30, Color(0.98, 0.84, 0.46), true)
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(head)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var book := VBoxContainer.new()
	book.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	book.add_theme_constant_override("separation", 8)
	scroll.add_child(book)
	for a in CampaignDefs.ACTS.size():
		var done: Array = CampaignDefs.chapters_in_act(a).filter(func(c): return String(c["id"]) in s["cleared"])
		if done.is_empty():
			continue
		var act_head := _label(String(CampaignDefs.ACTS[a]["title"]).to_upper(), 20, Color(0.85, 0.74, 0.5), true)
		act_head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		book.add_child(act_head)
		for c in done:
			var id := String(c["id"])
			var tag := "  ·  side road" if bool(c.get("side", false)) else ""
			if id in s.get("heroic", []):
				tag += "  ·  heroic laurel"
			book.add_child(_label(String(c["title"]) + tag, 22, Color(0.99, 0.86, 0.48), true))
			var brief := _label(CampaignDefs.briefing_for(id, _hero_race()), 16, Color(0.86, 0.84, 0.78))
			brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			brief.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			book.add_child(brief)
			var won := _label(CampaignDefs.victory_text(id, s), 16, Color(0.72, 0.88, 0.70))
			won.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			won.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			book.add_child(won)
			var gap := Control.new()
			gap.custom_minimum_size = Vector2(0, 10)
			book.add_child(gap)
	var close := Button.new()
	close.text = "Close"
	close.custom_minimum_size = Vector2(200, 50)
	close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close.focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(THEME_PATH):
		close.theme = load(THEME_PATH)
	close.add_theme_font_override("font", _title_font())
	close.add_theme_font_size_override("font_size", 20)
	close.pressed.connect(func(): layer.queue_free())
	outer.add_child(close)
	layer.modulate.a = 0.0
	layer.create_tween().tween_property(layer, "modulate:a", 1.0, 0.3)

func _show_act_card(a: int) -> void:
	var layer := ColorRect.new()
	layer.color = Color(0, 0, 0, 0.82)
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 14)
	layer.add_child(box)
	var parts: PackedStringArray = String(CampaignDefs.ACTS[a]["title"]).split(": ")
	for spec in [[parts[0].to_upper(), 22, Color(0.85, 0.74, 0.5), true], [parts[1] if parts.size() > 1 else parts[0], 54, Color(0.99, 0.86, 0.48), true], [String(CampaignDefs.ACTS[a]["subtitle"]), 20, Color(0.92, 0.88, 0.78), false], ["Click to continue", 14, Color(0.7, 0.66, 0.58), false]]:
		var l := _label(String(spec[0]), int(spec[1]), spec[2], bool(spec[3]))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(l)
	layer.modulate.a = 0.0
	layer.create_tween().tween_property(layer, "modulate:a", 1.0, 0.8)
	layer.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed:
			layer.queue_free())

func _act_reached(a: int) -> bool:
	for c in CampaignDefs.chapters_in_act(a):
		if ProfileManager.chapter_available(String(c["id"])):
			return true
	return false

# --------------------------------------------------------------------------
func _show_act(a: int) -> void:
	_act = a
	if is_instance_valid(_mood):
		_mood.color = ACT_MOODS[a]
	for child in _act_layer.get_children():
		child.queue_free()
	_positions.clear()
	_act_title.text = String(CampaignDefs.ACTS[a]["title"])
	_act_subtitle.text = String(CampaignDefs.ACTS[a]["subtitle"])
	var vp: Vector2 = get_viewport_rect().size
	if vp == Vector2.ZERO:
		vp = Vector2(1280, 720)
	# Main road winds left to right; side roads hang off the chapter before them.
	var chapters := CampaignDefs.chapters_in_act(a)
	var mains: Array = chapters.filter(func(c): return not bool(c.get("side", false)) and not c.has("branch"))
	var n := mains.size() + (1 if chapters.any(func(c): return c.has("branch")) else 0)
	var k := 0
	var last_main := Vector2.ZERO
	var side_flip := false
	for c in chapters:
		var id := String(c["id"])
		if c.has("branch"):
			var bx := vp.x * 0.9
			_positions[id] = Vector2(bx, vp.y * (0.36 if String(c["branch"]) == "break" else 0.66))
		elif bool(c.get("side", false)):
			_positions[id] = Vector2(last_main.x + vp.x * 0.05, vp.y * (0.30 if side_flip else 0.70))
			side_flip = not side_flip
		else:
			var x := vp.x * (0.1 + 0.8 * float(k) / float(maxi(1, n - 1)))
			var y := vp.y * (0.45 if k % 2 == 0 else 0.57)
			_positions[id] = Vector2(x, y)
			last_main = _positions[id]
			k += 1
	for c in chapters:
		_build_node(c)
	_canvas.queue_redraw()
	var next := CampaignDefs.find(_next_id)
	_show_desc(_next_id if int(next.get("act", -1)) == a else String(chapters[0]["id"]))

func _build_node(c: Dictionary) -> void:
	var id := String(c["id"])
	var s := ProfileManager.saga()
	var available := ProfileManager.chapter_available(id)
	var cleared: bool = id in s["cleared"]
	var sealed_by_choice: bool = c.has("branch") and String(s["choice"]) != "" and String(s["choice"]) != String(c["branch"])
	var btn: Button = REGION_BUTTON_SCRIPT.new()
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = NODE_SIZE
	btn.size = NODE_SIZE
	btn.position = _positions[id] - NODE_SIZE * 0.5
	btn.configure(available, cleared)
	btn.disabled = not available
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		btn.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	var vb := VBoxContainer.new()
	vb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 8.0
	vb.offset_right = -8.0
	vb.offset_top = 4.0
	vb.offset_bottom = -4.0
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 2)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var kind := "SIDE ROAD  ·  " if bool(c.get("side", false)) else ("THE CHOICE  ·  " if c.has("branch") else "")
	var head := _label(kind + id, 12, Color(0.75, 0.70, 0.58))
	head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(head)
	var name_lbl := _label(String(c["title"]), 17, Color(1.0, 0.87, 0.35) if available else Color(0.72, 0.76, 0.80), true)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(name_lbl)
	var laurel: bool = id in s.get("heroic", [])
	var status := "Sealed by your choice" if sealed_by_choice else (("Heroic laurel" if laurel else "Cleared") if cleared else (String(c["difficulty"]) if available else "Sealed"))
	if bool(c.get("jar", false)):
		status += ("  ·  jar found" if id in s["jars"] else "  ·  a jar lies here") if available or cleared else ""
	var status_lbl := _label(status, 13, Color(0.98, 0.80, 0.36) if laurel else Color(0.5, 0.9, 0.55) if cleared else DIFF_COLORS.get(String(c["difficulty"]), Color(0.8, 0.8, 0.8)) if available else Color(0.62, 0.66, 0.70))
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(status_lbl)
	btn.add_child(vb)
	btn.mouse_entered.connect(_show_desc.bind(id))
	if available:
		btn.pressed.connect(_open_briefing.bind(id))
	else:
		btn.modulate = Color(0.78, 0.78, 0.8, 0.85)
	_act_layer.add_child(btn)
	# Both roads of the Rabagão choice pulse while the choice is still open.
	var choice_open: bool = c.has("branch") and String(s["choice"]) == "" and available and not cleared
	if id == _next_id or choice_open:
		btn.pivot_offset = NODE_SIZE * 0.5
		var pulse := btn.create_tween().set_loops()
		pulse.tween_property(btn, "scale", Vector2.ONE * 1.05, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(btn, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _show_desc(id: String) -> void:
	if not is_instance_valid(_desc_label):
		return
	var c := CampaignDefs.find(id)
	if c.is_empty():
		return
	if not ProfileManager.chapter_available(id) and not (id in ProfileManager.saga()["cleared"]):
		_desc_label.text = "%s\nThis road is still sealed." % String(c["title"])
		return
	var first := String(c["briefing"]).split("\n")[0]
	var hint := "   ·   Click to open the chronicle" if id == _next_id else ""
	_desc_label.text = "%s  [%s]%s\n%s" % [String(c["title"]), String(c["difficulty"]), hint, first]

# --------------------------------------------------------------------------
func _open_briefing(id: String) -> void:
	Sfx.play("select")
	if is_instance_valid(_briefing):
		_briefing.queue_free()
	var c := CampaignDefs.find(id)
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(layer)
	_briefing = layer
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var plate: PanelContainer = PLATE_SCRIPT.new()
	var ps := StyleBoxFlat.new()
	ps.bg_color = Color.TRANSPARENT
	ps.content_margin_left = 52.0
	ps.content_margin_right = 52.0
	ps.content_margin_top = 30.0
	ps.content_margin_bottom = 30.0
	plate.add_theme_stylebox_override("panel", ps)
	plate.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.grow_vertical = Control.GROW_DIRECTION_BOTH
	plate.custom_minimum_size = Vector2(820, 0)
	layer.add_child(plate)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	plate.add_child(box)
	var act_line := _label(String(CampaignDefs.ACTS[int(c["act"])]["title"]).to_upper(), 14, Color(0.75, 0.68, 0.52), true)
	act_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(act_line)
	var t := _label(String(c["title"]), 34, Color(0.98, 0.84, 0.46), true)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(t)
	var rule := ColorRect.new()
	rule.color = Color(0.98, 0.84, 0.46, 0.4)
	rule.custom_minimum_size = Vector2(0, 1)
	box.add_child(rule)
	var body := _label(CampaignDefs.briefing_for(id, _hero_race()), 18, Color(0.92, 0.89, 0.80))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(716, 0)
	box.add_child(body)
	var foes: Array = []
	for o in c["opponents"]:
		foes.append(String(GameData.get_race(String(o["race"])).get("name", o["race"])))
	var suggested := 1 + int(round(CampaignDefs.index_of(id) * 1.2))
	var hero_level := int(ProfileManager.hero().get("level", 1))
	var meta := _label("Enemies: %s   ·   Difficulty: %s   ·   Suggested hero level %d%s%s" % [", ".join(foes), String(c["difficulty"]), suggested, " (yours: %d)" % hero_level, "   ·   A jar of Wine of the Dead lies here" if bool(c.get("jar", false)) else ""] + ("
Objective: hold out for %d minutes." % (int(c.get("survive", 0)) / 60) if int(c.get("survive", 0)) > 0 else "
Objective: destroy the enemy's ability to rebuild."), 15, Color(0.85, 0.72, 0.45))
	meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(meta)
	# The first chapter that fields a faction introduces it.
	var seen := {}
	for earlier in CampaignDefs.CHAPTERS:
		if String(earlier["id"]) == id:
			break
		for o in earlier["opponents"]:
			seen[String(o["race"])] = true
	for o in c["opponents"]:
		var race_id := String(o["race"])
		if seen.has(race_id):
			continue
		seen[race_id] = true
		var rd: Dictionary = GameData.get_race(race_id)
		var blurb := String(rd.get("blurb", "")).split(". ")[0].trim_suffix(".")
		var intro := _label("New enemy: %s. %s." % [rd.get("name", race_id), blurb], 15, Color(0.95, 0.62, 0.42))
		intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(intro)
	if c.has("branch"):
		var warn := _label("This is the choice. Marching here seals the other road forever.", 15, Color(0.95, 0.45, 0.35), true)
		warn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		box.add_child(warn)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var buttons: Array = [["Back", func(): layer.queue_free()], ["March to War", func(): _on_node_pressed(id)]]
	if id in ProfileManager.saga()["cleared"]:
		buttons.append(["Heroic Replay", func(): _on_node_pressed(id, true)])
		var heroic := _label("Cleared. A Heroic Replay raises every enemy one difficulty step and pays half again in experience.", 14, Color(0.80, 0.70, 0.95))
		heroic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(heroic)
	for spec in buttons:
		var b := Button.new()
		b.text = String(spec[0])
		b.custom_minimum_size = Vector2(220, 54)
		b.focus_mode = Control.FOCUS_NONE
		if ResourceLoader.exists(THEME_PATH):
			b.theme = load(THEME_PATH)
		b.add_theme_font_override("font", _title_font())
		b.add_theme_font_size_override("font_size", 20)
		b.pressed.connect(spec[1])
		row.add_child(b)
	plate.modulate.a = 0.0
	plate.create_tween().tween_property(plate, "modulate:a", 1.0, 0.3)

func _on_node_pressed(id: String, heroic: bool = false) -> void:
	Sfx.play("select")
	var c := CampaignDefs.find(id)
	var cfg: Dictionary = Match.default_config()
	cfg["player_race"] = _hero_race()
	cfg["opponents"] = c["opponents"].duplicate(true)
	cfg["campaign_heroic"] = heroic
	if heroic:
		var up := {"easy": "normal", "normal": "hard", "hard": "brutal", "brutal": "brutal"}
		for o in cfg["opponents"]:
			o["difficulty"] = up.get(String(o["difficulty"]), "brutal")
	cfg["mode"] = "campaign"
	cfg["campaign_node"] = CampaignDefs.index_of(id)
	cfg["campaign_chapter"] = id
	cfg["victory"] = "conquest"
	cfg["map"] = String(c.get("map", "hollowspan"))
	Match.set_config(cfg)
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 1.5)

func _on_back_pressed() -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# --------------------------------------------------------------------------
func _draw_path() -> void:
	var s := ProfileManager.saga()
	for c in CampaignDefs.chapters_in_act(_act):
		var from_id := String(c["id"])
		if not _positions.has(from_id):
			continue
		for to in c.get("unlocks", []):
			var to_id := String(to)
			if not _positions.has(to_id):
				continue
			var lit: bool = ProfileManager.chapter_available(to_id) or to_id in s["cleared"]
			_draw_march_route(_positions[from_id], _positions[to_id], lit)

func _draw_march_route(from: Vector2, to: Vector2, lit: bool) -> void:
	# A curved, inked march route: a dark under-stroke, then dashes that glow
	# gold once the leg is open and stay faint slate while it is sealed.
	var mid := (from + to) * 0.5
	var normal := Vector2(-(to - from).y, (to - from).x).normalized()
	var ctrl := mid + normal * (to - from).length() * 0.12
	var pts := PackedVector2Array()
	for k in 33:
		var t := float(k) / 32.0
		pts.append(from.lerp(ctrl, t).lerp(ctrl.lerp(to, t), t))
	_canvas.draw_polyline(pts, Color(0.02, 0.02, 0.03, 0.7), 7.0, true)
	var dash_col := Color(0.98, 0.80, 0.38, 0.95) if lit else Color(0.55, 0.58, 0.64, 0.55)
	if lit:
		_canvas.draw_polyline(pts, Color(0.98, 0.72, 0.30, 0.18), 12.0, true)
	for k in range(0, 32, 2):
		_canvas.draw_line(pts[k], pts[k + 1], dash_col, 3.0, true)
