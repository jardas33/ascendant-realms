extends Control
## Main menu for Ascendant Realms — the project's entry scene.
## Full-screen art, wordmark, and the primary navigation buttons.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const WORDMARK := "res://assets/ui/wordmark_title.png"
const PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")

func _ready() -> void:
	AudioManager.play_music_path(Sfx.music_key("menu"), -8.0, true)
	_build()

func _build() -> void:
	# Background
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists(BG):
		bg.texture = load(BG)
	add_child(bg)
	# Slow drift so the painted realm feels alive rather than a still frame.
	bg.pivot_offset = get_viewport_rect().size * 0.5
	bg.scale = Vector2.ONE * 1.06
	var drift := bg.create_tween().set_loops()
	drift.tween_property(bg, "position", Vector2(-24, -10), 18.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(bg, "position", Vector2(18, 8), 18.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Dark scrim for readability
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.05, 0.38)
	add_child(scrim)
	add_child(_make_vignette())
	add_child(_make_motes())

	# Wordmark near top-center
	var word := TextureRect.new()
	word.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	word.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(WORDMARK):
		word.texture = load(WORDMARK)
	word.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	word.custom_minimum_size = Vector2(720, 220)
	word.offset_left = -360.0
	word.offset_right = 360.0
	word.offset_top = 60.0
	word.offset_bottom = 280.0
	add_child(word)
	word.modulate.a = 0.0
	word.create_tween().tween_property(word, "modulate:a", 1.0, 1.2).set_delay(0.2)

	# Button column
	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 10)
	col.custom_minimum_size = Vector2(340, 0)
	col.offset_left = -170.0
	col.offset_right = 170.0
	col.offset_top = 40.0
	col.offset_bottom = 360.0
	add_child(col)

	var primary := _make_button(_campaign_label(), _on_campaign)
	col.add_child(primary)
	# The saga is the main road: its button breathes a slow warm light.
	primary.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	var breathe := primary.create_tween().set_loops()
	breathe.tween_property(primary, "self_modulate", Color(1.25, 1.12, 0.9), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	breathe.tween_property(primary, "self_modulate", Color(1, 1, 1), 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# The Endless Road, straight from the menu once the first chapter is won.
	if ProfileManager.has_hero() and not ProfileManager.saga()["cleared"].is_empty():
		col.add_child(_make_button("Endless Road  ·  Stage %d" % (ProfileManager.endless_best() + 1), _on_endless))
	col.add_child(_make_button("Skirmish", _on_skirmish))
	col.add_child(_make_button("Hero", _on_hero))
	col.add_child(_make_button("How to Play", _on_tutorial))
	col.add_child(_make_button("Settings", _on_settings))
	if not OS.has_feature("web"):
		col.add_child(_make_button("Quit", _on_quit))

	# A dark gilt plate behind the column so the choices read over any part
	# of the painting.
	var backing: PanelContainer = PLATE_SCRIPT.new()
	backing.set("surface_alpha", 0.55)
	backing.set("surface_alpha_bottom", 0.72)
	var bstyle := StyleBoxFlat.new()
	bstyle.bg_color = Color.TRANSPARENT
	backing.add_theme_stylebox_override("panel", bstyle)
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backing.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(backing)
	move_child(backing, col.get_index())
	var fit_backing := func():
		var r: Rect2 = Rect2(col.position, col.size)
		backing.position = r.position - Vector2(30, 24)
		backing.size = r.size + Vector2(60, 48)
	col.resized.connect(fit_backing)
	fit_backing.call_deferred()
	backing.modulate.a = 0.0
	backing.create_tween().tween_property(backing, "modulate:a", 1.0, 0.6).set_delay(0.45)

	# Your hero, waiting: portrait, level and experience in the corner.
	if ProfileManager.has_hero():
		add_child(_make_hero_card())

	# Buttons rise into place one after another.
	var i := 0
	for b in col.get_children():
		b.modulate.a = 0.0
		var t := b.create_tween().set_parallel(true)
		t.tween_property(b, "modulate:a", 1.0, 0.45).set_delay(0.6 + i * 0.08)
		i += 1

	# Footer note
	var footer := Label.new()
	footer.text = "The Saga of the Seventy-Seventh Ascension"
	footer.add_theme_color_override("font_color", Color(0.88, 0.85, 0.75, 0.9))
	footer.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	footer.add_theme_constant_override("outline_size", 3)
	footer.add_theme_font_size_override("font_size", 18)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	footer.offset_top = -50.0
	footer.offset_bottom = -20.0
	footer.offset_left = -300.0
	footer.offset_right = 300.0
	add_child(footer)

## "Continue the Saga" once the player has won a chapter.
func _campaign_label() -> String:
	var s: Dictionary = ProfileManager.saga()
	if s["cleared"].is_empty():
		return "Begin the Saga"
	# After the Seventy-Seventh Oath the saga is told; the map stays open for
	# heroic replays, side roads and the jars still missing.
	if "5-7" in s["cleared"]:
		return "The Saga Is Told · Revisit"
	var act := 0
	for id in s["unlocked"]:
		act = maxi(act, int(String(id).substr(0, 1)))
	return "Continue the Saga · Act %s" % ["I", "II", "III", "IV", "V"][clampi(act - 1, 0, 4)]

func _make_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 50)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 24)
	b.add_theme_color_override("font_color", Color(0.95, 0.86, 0.64))
	b.add_theme_color_override("font_hover_color", Color(1.0, 0.95, 0.78))
	b.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.0, 0.9))
	b.add_theme_constant_override("outline_size", 4)
	b.pressed.connect(cb)
	# A small lift on hover.
	b.mouse_entered.connect(func():
		b.pivot_offset = b.size * 0.5
		b.create_tween().tween_property(b, "scale", Vector2.ONE * 1.04, 0.12)
		b.set_meta("hot", true)
		b.queue_redraw())
	b.mouse_exited.connect(func():
		b.create_tween().tween_property(b, "scale", Vector2.ONE, 0.12)
		b.set_meta("hot", false)
		b.queue_redraw())
	# Hovered choices are flanked by two small Lume diamonds.
	b.draw.connect(func():
		if not b.has_meta("hot") or not bool(b.get_meta("hot")):
			return
		for side in [-1.0, 1.0]:
			var c := Vector2(b.size.x * 0.5 + float(side) * (b.size.x * 0.5 + 14.0), b.size.y * 0.5)
			var d := 6.0
			b.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -d), c + Vector2(d, 0), c + Vector2(0, d), c + Vector2(-d, 0)]), Color(1.0, 0.84, 0.45, 0.95))
			b.draw_line(c + Vector2(float(side) * -8.0, 0), c + Vector2(float(side) * -30.0, 0), Color(1.0, 0.84, 0.45, 0.6), 1.4, true))
	return b

func _make_hero_card() -> Control:
	var h: Dictionary = ProfileManager.hero()
	var race: Dictionary = GameData.get_race(str(h.get("race", "")))
	var card: PanelContainer = PLATE_SCRIPT.new()
	card.set("surface_alpha", 0.78)
	card.set("surface_alpha_bottom", 0.86)
	var st := StyleBoxFlat.new()
	st.bg_color = Color.TRANSPARENT
	st.set_content_margin_all(14)
	card.add_theme_stylebox_override("panel", st)
	card.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	card.offset_left = 28.0
	card.offset_top = -170.0
	card.offset_right = 470.0
	card.offset_bottom = -26.0
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	card.add_child(row)
	var hero_def: Dictionary = GameData.get_unit(str(race.get("hero", "")))
	if not hero_def.is_empty() and ResourceLoader.exists(str(hero_def.get("portrait", ""))):
		var portrait := EntityPortraitView.new()
		portrait.custom_minimum_size = Vector2(112, 112)
		portrait.configure_definition(hero_def, false)
		row.add_child(portrait)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 4)
	row.add_child(col)
	var font: Font = load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font
	var name_l := Label.new()
	name_l.text = str(h.get("name", "Hero"))
	name_l.add_theme_font_override("font", font)
	name_l.add_theme_font_size_override("font_size", 26)
	name_l.add_theme_color_override("font_color", Color(0.98, 0.9, 0.66))
	col.add_child(name_l)
	var sub := Label.new()
	sub.text = "%s  ·  %s  ·  Level %d" % [str(race.get("name", "")), str(h.get("archetype", "")).capitalize(), int(h.get("level", 1))]
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", Color(0.84, 0.8, 0.7))
	col.add_child(sub)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	bar.max_value = maxf(1.0, ProfileManager.xp_for_level(int(h.get("level", 1))))
	bar.value = float(h.get("xp", 0.0))
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.93, 0.72, 0.3)
	fill.set_corner_radius_all(3)
	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.05, 0.05, 0.06, 0.9)
	back.border_color = Color(0.6, 0.48, 0.28, 0.8)
	back.set_border_width_all(1)
	back.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	col.add_child(bar)
	var pts := int(h.get("skill_points", 0)) + int(h.get("attr_points", 0))
	var tp: int = ProfileManager.talent_points() if ProfileManager.has_method("talent_points") else 0
	var hint := Label.new()
	hint.text = ("%d points to spend  ·  %d talent picks waiting" % [pts, tp]) if (pts > 0 or tp > 0) else "Ready for battle"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.98, 0.82, 0.42) if (pts > 0 or tp > 0) else Color(0.6, 0.85, 0.62))
	col.add_child(hint)
	# Where the saga goes next: the first open main chapter not yet won.
	var saga := ProfileManager.saga()
	var next_title := ""
	for c in preload("res://scripts/game/campaign_defs.gd").all():
		var cid := String(c["id"])
		if ProfileManager.chapter_available(cid) and not cid in saga["cleared"] and not bool(c.get("side", false)):
			next_title = String(c.get("title", ""))
			break
	if next_title != "":
		var next_l := Label.new()
		next_l.text = "Next in the saga: %s" % next_title
		next_l.add_theme_font_size_override("font_size", 13)
		next_l.add_theme_color_override("font_color", Color(0.86, 0.78, 0.62))
		col.add_child(next_l)
	card.modulate.a = 0.0
	card.create_tween().tween_property(card, "modulate:a", 1.0, 0.7).set_delay(0.9)
	return card

func _make_vignette() -> TextureRect:
	var n := 128
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in n:
		for x in n:
			var d := Vector2((x + 0.5) / n - 0.5, (y + 0.5) / n - 0.5).length() * 2.0
			img.set_pixel(x, y, Color(0, 0, 0, clampf((d - 0.55) * 1.3, 0.0, 0.75)))
	var v := TextureRect.new()
	v.texture = ImageTexture.create_from_image(img)
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	v.stretch_mode = TextureRect.STRETCH_SCALE
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return v

func _make_motes() -> GPUParticles2D:
	# Gold lume motes drifting up from the spire at the centre of the realm.
	var p := GPUParticles2D.new()
	p.amount = 60
	p.lifetime = 9.0
	p.preprocess = 9.0
	var vs := get_viewport_rect().size
	p.position = Vector2(vs.x * 0.5, vs.y * 0.62)
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(vs.x * 0.45, vs.y * 0.3, 1)
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 25.0
	pm.gravity = Vector3(4, -6, 0)
	pm.initial_velocity_min = 6.0
	pm.initial_velocity_max = 16.0
	pm.scale_min = 1.5
	pm.scale_max = 4.0
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 0.85, 0.45, 0.0))
	fade.set_color(1, Color(1.0, 0.85, 0.45, 0.0))
	fade.add_point(0.3, Color(1.0, 0.85, 0.45, 0.8))
	var ramp := GradientTexture1D.new()
	ramp.gradient = fade
	pm.color_ramp = ramp
	p.process_material = pm
	var dot := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in 16:
		for x in 16:
			var d := Vector2(x - 7.5, y - 7.5).length() / 8.0
			dot.set_pixel(x, y, Color(1, 1, 1, clampf(1.0 - d, 0.0, 1.0) ** 2))
	p.texture = ImageTexture.create_from_image(dot)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	p.material = mat
	return p

# --- navigation -----------------------------------------------------------
func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)

func _on_campaign() -> void:
	if not ProfileManager.has_hero():
		Match.set_pending_hero_origin("campaign")
		_goto("res://scenes/ui/hero_creation.tscn")
		return
	Match.clear_pending_hero_origin()
	_goto("res://scenes/ui/campaign_map.tscn")

func _on_endless() -> void:
	Match.set_meta("open_endless", true)
	_goto("res://scenes/ui/campaign_map.tscn")

func _on_skirmish() -> void:
	if not ProfileManager.has_hero():
		Match.set_pending_hero_origin("skirmish")
		_goto("res://scenes/ui/hero_creation.tscn")
		return
	Match.clear_pending_hero_origin()
	_goto("res://scenes/ui/skirmish_setup.tscn")

func _on_hero() -> void:
	Match.clear_pending_hero_origin()
	if ProfileManager.has_hero():
		_goto("res://scenes/ui/hero_sheet.tscn")
	else:
		_goto("res://scenes/ui/hero_creation.tscn")

func _on_settings() -> void:
	_goto("res://scenes/ui/settings.tscn")

func _on_tutorial() -> void:
	Sfx.play("select")
	var cfg := Match.default_config()
	cfg["mode"] = "tutorial"
	cfg["player_race"] = "barrosan"
	cfg["opponents"] = [{"race": "vorthak", "difficulty": "easy"}]
	Match.set_config(cfg)
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 1.5)

func _on_quit() -> void:
	Sfx.play("select")
	get_tree().quit()
