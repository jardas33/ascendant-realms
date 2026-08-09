extends Control
## Main menu for Ascendant Realms — the project's entry scene.
## Full-screen art, wordmark, and the primary navigation buttons.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const WORDMARK := "res://assets/ui/wordmark_title.png"

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

	# Dark scrim for readability
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.05, 0.45)
	add_child(scrim)

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

	# Button column
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

	# Footer note
	var footer := Label.new()
	footer.text = "A fantasy realm-forging strategy saga"
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

func _make_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(320, 56)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 24)
	b.pressed.connect(cb)
	return b

# --- navigation -----------------------------------------------------------
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
