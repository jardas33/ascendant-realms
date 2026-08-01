# Ascendant Realms: custom main menu
extends Control
## Main menu for Ascendant Realms — the project's entry scene (scenes/main.tscn).
## Full-screen art, wordmark, and the primary navigation buttons.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const WORDMARK := "res://assets/ui/wordmark_title.png"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists("res://assets/ui/theme.tres"):
		theme = load("res://assets/ui/theme.tres") as Theme
	AudioManager.play_music_path(Sfx.music_key("menu"), -8.0, true)
	_build()
	if OS.get_environment("ASCENDANT_V0436_R1K_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_R1J_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_R1H_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_R1G_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_R1F_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_R1_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_R1C_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0436_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0435_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0434_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0433_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0432_CAPTURE") == "1" or OS.get_environment("ASCENDANT_V0431_CAPTURE") == "1":
		call_deferred("_start_v0431_capture_scene")

func _start_v0431_capture_scene() -> void:
	LoadingScreen.preload_and_change_scene("res://scenes/game_world.tscn", 0.1)

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
	scrim.color = Color(0.02, 0.03, 0.05, 0.45)
	add_child(scrim)

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

	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 14)
	col.custom_minimum_size = Vector2(340, 0)
	col.offset_left = -170.0
	col.offset_right = 170.0
	col.offset_top = 40.0
	col.offset_bottom = 360.0
	add_child(col)

	col.add_child(_make_button("Play Campaign", _on_campaign))
	col.add_child(_make_button("Skirmish", _on_skirmish))
	col.add_child(_make_button("Hero", _on_hero))
	col.add_child(_make_button("How to Play", _on_tutorial))
	col.add_child(_make_button("Settings", _on_settings))
	if not OS.has_feature("web"):
		col.add_child(_make_button("Quit", _on_quit))

	var footer := Label.new()
	footer.text = "A fantasy realm-forging strategy saga"
	footer.add_theme_color_override("font_color", Color(0.85, 0.82, 0.72, 0.8))
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	footer.offset_top = -50.0
	footer.offset_bottom = -20.0
	footer.offset_left = -300.0
	footer.offset_right = 300.0
	add_child(footer)

func _make_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(320, 56)
	b.focus_mode = Control.FOCUS_NONE
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", Color(0.96, 0.93, 0.82))
	lbl.add_theme_font_size_override("font_size", 24)
	if ResourceLoader.exists(FONT):
		lbl.add_theme_font_override("font", load(FONT))
	lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(lbl)
	b.pressed.connect(cb)
	return b

func _goto(path: String) -> void:
	Sfx.play("select")
	get_tree().change_scene_to_file(path)

func _on_campaign() -> void:
	if not ProfileManager.has_hero():
		_goto("res://scenes/ui/hero_creation.tscn")
		return
	_goto("res://scenes/ui/campaign_map.tscn")

func _on_skirmish() -> void:
	if not ProfileManager.has_hero():
		_goto("res://scenes/ui/hero_creation.tscn")
		return
	_goto("res://scenes/ui/skirmish_setup.tscn")

func _on_hero() -> void:
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
