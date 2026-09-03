extends Control
## Hero Creation — name, race, archetype, appearance, strength/weakness,
## and starting attribute allocation. Forges the persistent hero.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"

const ARCHETYPES := ["Warrior", "Commander", "Ranger", "Mage", "Summoner"]
const STRENGTHS := ["Mighty", "Swift", "Arcane", "Stalwart"]
const WEAKNESSES := ["Frail", "Slow", "Impatient", "Reckless"]
const START_ATTR := 3
const ATTR_POOL := 5

# Variant tints applied via SubViewportContainer.modulate
const VARIANT_TINTS := [
	Color(1.0, 1.0, 1.0, 1.0),        # Variant 1 — no tint
	Color(0.85, 0.95, 1.05, 1.0),     # Variant 2 — cool blue-ish
	Color(1.1, 0.90, 0.75, 1.0),      # Variant 3 — warm amber
]
const VARIANT_Y_ROT := [0.0, 0.6, -0.6]  # starting Y rotation offsets per variant

var _name_edit: LineEdit
var _race_id := "barrosan"
var _race_buttons := {}
var _race_desc: Label
var _archetype := "Warrior"
var _arch_option: OptionButton
var _appearance := 0
var _appear_label: Label
var _strength := "Mighty"
var _weakness := "Frail"
var _str_option: OptionButton
var _weak_option: OptionButton
var _attrs := {}
var _points_left := ATTR_POOL
var _attr_rows := {}
var _points_label: Label

# Hero preview 3D
var _preview_viewport: SubViewport
var _preview_container: SubViewportContainer
var _preview_pivot: Node3D
var _preview_model: Node3D
var _preview_cam: Camera3D

func _ready() -> void:
	for a in ProfileManager.ATTRIBUTES:
		_attrs[a] = START_ATTR
	_build()
	_refresh_race()
	_refresh_attrs()
	# Pick a sensible default race — first key in GameData.RACES
	var keys := GameData.RACES.keys()
	if not keys.is_empty() and not _race_buttons.has(_race_id):
		_race_id = str(keys[0])
	_refresh_race()
	_load_hero_model()

func _title_font(size: int) -> Font:
	return load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font

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
	scrim.color = Color(0.02, 0.03, 0.05, 0.7)
	add_child(scrim)

	var title := Label.new()
	title.text = "Forge Your Hero"
	title.add_theme_font_override("font", _title_font(40))
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.96, 0.9, 0.7))
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	title.add_theme_constant_override("outline_size", 4)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 24.0
	title.offset_bottom = 80.0
	add_child(title)

	# Two-column layout: left = form scroll, right = hero preview
	var columns := HBoxContainer.new()
	columns.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	columns.offset_top = 96.0
	columns.offset_bottom = -80.0
	columns.offset_left = 40.0
	columns.offset_right = -40.0
	columns.add_theme_constant_override("separation", 20)
	add_child(columns)

	# Left: scrollable form
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(scroll)

	var main := VBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 18)
	scroll.add_child(main)

	# Name
	main.add_child(_section_label("Name"))
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Enter a hero name..."
	_name_edit.custom_minimum_size = Vector2(400, 40)
	_name_edit.add_theme_color_override("font_color", Color.WHITE)
	_name_edit.add_theme_font_size_override("font_size", 18)
	main.add_child(_name_edit)

	# Race — GridContainer so 10 races wrap neatly
	main.add_child(_section_label("Race"))
	var race_grid := GridContainer.new()
	race_grid.columns = 5
	race_grid.add_theme_constant_override("h_separation", 10)
	race_grid.add_theme_constant_override("v_separation", 10)
	main.add_child(race_grid)
	for rid in GameData.RACES:
		var rd: Dictionary = GameData.RACES[rid]
		var rb := Button.new()
		rb.toggle_mode = true
		rb.custom_minimum_size = Vector2(200, 48)
		rb.focus_mode = Control.FOCUS_NONE
		rb.clip_text = false
		rb.text = rd.get("name", rid)
		rb.add_theme_color_override("font_color", Color(0.95, 0.9, 0.75))
		rb.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
		rb.add_theme_font_size_override("font_size", 16)
		rb.pressed.connect(_on_race.bind(rid))
		_race_buttons[rid] = rb
		race_grid.add_child(rb)
	_race_desc = Label.new()
	_race_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_race_desc.custom_minimum_size = Vector2(500, 0)
	_race_desc.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82))
	_race_desc.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	_race_desc.add_theme_constant_override("outline_size", 3)
	_race_desc.add_theme_font_size_override("font_size", 16)
	main.add_child(_race_desc)

	# Archetype
	main.add_child(_section_label("Archetype"))
	_arch_option = OptionButton.new()
	_arch_option.custom_minimum_size = Vector2(280, 40)
	for i in ARCHETYPES.size():
		_arch_option.add_item(ARCHETYPES[i], i)
	_arch_option.item_selected.connect(func(idx): _archetype = ARCHETYPES[idx]; Sfx.play("select"))
	main.add_child(_arch_option)

	# Appearance
	main.add_child(_section_label("Appearance"))
	var app_row := HBoxContainer.new()
	app_row.add_theme_constant_override("separation", 10)
	main.add_child(app_row)
	var app_prev := Button.new()
	app_prev.text = "<"
	app_prev.clip_text = false
	app_prev.custom_minimum_size = Vector2(48, 44)
	app_prev.focus_mode = Control.FOCUS_NONE
	app_prev.add_theme_color_override("font_color", Color.WHITE)
	app_prev.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	app_prev.pressed.connect(_appear_step.bind(-1))
	app_row.add_child(app_prev)
	_appear_label = Label.new()
	_appear_label.custom_minimum_size = Vector2(160, 44)
	_appear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_appear_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_appear_label.add_theme_color_override("font_color", Color.WHITE)
	_appear_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	_appear_label.add_theme_constant_override("outline_size", 3)
	_appear_label.add_theme_font_size_override("font_size", 17)
	app_row.add_child(_appear_label)
	var app_next := Button.new()
	app_next.text = ">"
	app_next.clip_text = false
	app_next.custom_minimum_size = Vector2(48, 44)
	app_next.focus_mode = Control.FOCUS_NONE
	app_next.add_theme_color_override("font_color", Color.WHITE)
	app_next.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	app_next.pressed.connect(_appear_step.bind(1))
	app_row.add_child(app_next)
	_update_appear()

	# Strength / Weakness
	main.add_child(_section_label("Strength & Weakness"))
	var sw_row := HBoxContainer.new()
	sw_row.add_theme_constant_override("separation", 20)
	main.add_child(sw_row)
	_str_option = OptionButton.new()
	_str_option.custom_minimum_size = Vector2(220, 40)
	for i in STRENGTHS.size():
		_str_option.add_item("Strength: " + STRENGTHS[i], i)
	_str_option.item_selected.connect(func(idx): _strength = STRENGTHS[idx]; Sfx.play("select"))
	sw_row.add_child(_str_option)
	_weak_option = OptionButton.new()
	_weak_option.custom_minimum_size = Vector2(220, 40)
	for i in WEAKNESSES.size():
		_weak_option.add_item("Weakness: " + WEAKNESSES[i], i)
	_weak_option.item_selected.connect(func(idx): _weakness = WEAKNESSES[idx]; Sfx.play("select"))
	sw_row.add_child(_weak_option)

	# Attributes
	main.add_child(_section_label("Attributes"))
	_points_label = Label.new()
	_points_label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	_points_label.add_theme_font_size_override("font_size", 17)
	main.add_child(_points_label)
	var attr_grid := GridContainer.new()
	attr_grid.columns = 4
	attr_grid.add_theme_constant_override("h_separation", 10)
	attr_grid.add_theme_constant_override("v_separation", 8)
	main.add_child(attr_grid)
	for a in ProfileManager.ATTRIBUTES:
		var name_lbl := Label.new()
		name_lbl.text = a.capitalize()
		name_lbl.custom_minimum_size = Vector2(140, 36)
		name_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
		name_lbl.add_theme_font_size_override("font_size", 17)
		attr_grid.add_child(name_lbl)
		var minus := Button.new()
		minus.text = "-"
		minus.clip_text = false
		minus.custom_minimum_size = Vector2(44, 36)
		minus.focus_mode = Control.FOCUS_NONE
		minus.add_theme_color_override("font_color", Color.WHITE)
		minus.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
		minus.pressed.connect(_attr_step.bind(a, -1))
		attr_grid.add_child(minus)
		var val := Label.new()
		val.custom_minimum_size = Vector2(50, 36)
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		val.add_theme_color_override("font_color", Color.WHITE)
		val.add_theme_font_size_override("font_size", 17)
		attr_grid.add_child(val)
		var plus := Button.new()
		plus.text = "+"
		plus.clip_text = false
		plus.custom_minimum_size = Vector2(44, 36)
		plus.focus_mode = Control.FOCUS_NONE
		plus.add_theme_color_override("font_color", Color.WHITE)
		plus.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
		plus.pressed.connect(_attr_step.bind(a, 1))
		attr_grid.add_child(plus)
		_attr_rows[a] = val

	# Right: Hero preview panel
	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(320, 0)
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(preview_panel)

	var preview_v := VBoxContainer.new()
	preview_v.add_theme_constant_override("separation", 8)
	preview_panel.add_child(preview_v)

	var preview_title := Label.new()
	preview_title.text = "Hero Preview"
	preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_title.add_theme_font_override("font", _title_font(20))
	preview_title.add_theme_font_size_override("font_size", 20)
	preview_title.add_theme_color_override("font_color", Color(0.9, 0.78, 0.5))
	preview_title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	preview_title.add_theme_constant_override("outline_size", 3)
	preview_v.add_child(preview_title)

	_preview_container = SubViewportContainer.new()
	_preview_container.stretch = true
	_preview_container.custom_minimum_size = Vector2(300, 380)
	_preview_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_v.add_child(_preview_container)

	_preview_viewport = SubViewport.new()
	_preview_viewport.size = Vector2i(300, 380)
	_preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_preview_viewport.transparent_bg = true
	_preview_container.add_child(_preview_viewport)

	# World3D for the viewport
	var world := World3D.new()
	_preview_viewport.world_3d = world

	# Camera — position in front of model, default -Z forward looks at origin
	_preview_cam = Camera3D.new()
	_preview_cam.position = Vector3(0.0, 1.1, 2.8)
	# Tilt slightly downward (~4 deg) so model center (y≈0.9) is in frame
	_preview_cam.rotation_degrees = Vector3(-4.0, 0.0, 0.0)
	_preview_viewport.add_child(_preview_cam)

	# Environment — ambient + sky color so model is readable
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.08, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.58, 0.75)
	env.ambient_light_energy = 0.6
	env_node.environment = env
	_preview_viewport.add_child(env_node)

	# Key directional light
	var key_light := DirectionalLight3D.new()
	key_light.light_color = Color(1.0, 0.95, 0.85)
	key_light.light_energy = 1.2
	key_light.rotation_degrees = Vector3(-40.0, 30.0, 0.0)
	_preview_viewport.add_child(key_light)

	# Fill/back light for depth
	var fill_light := DirectionalLight3D.new()
	fill_light.light_color = Color(0.6, 0.7, 1.0)
	fill_light.light_energy = 0.4
	fill_light.rotation_degrees = Vector3(-20.0, 200.0, 0.0)
	_preview_viewport.add_child(fill_light)

	# Pivot for rotation
	_preview_pivot = Node3D.new()
	_preview_viewport.add_child(_preview_pivot)

	# Footer buttons
	var footer := HBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -70.0
	footer.offset_bottom = -16.0
	footer.offset_left = 40.0
	footer.offset_right = -40.0
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 30)
	add_child(footer)
	var back := Button.new()
	back.text = "Back"
	back.clip_text = false
	back.custom_minimum_size = Vector2(200, 50)
	back.focus_mode = Control.FOCUS_NONE
	back.add_theme_color_override("font_color", Color.WHITE)
	back.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	back.pressed.connect(func(): Sfx.play("select"); Match.clear_pending_hero_origin(); get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
	footer.add_child(back)
	var forge := Button.new()
	forge.text = "Forge Hero"
	forge.clip_text = false
	forge.custom_minimum_size = Vector2(260, 50)
	forge.focus_mode = Control.FOCUS_NONE
	forge.add_theme_color_override("font_color", Color(0.98, 0.92, 0.6))
	forge.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	forge.pressed.connect(_on_forge)
	footer.add_child(forge)

func _section_label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _title_font(24))
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color(0.9, 0.78, 0.5))
	l.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	l.add_theme_constant_override("outline_size", 4)
	return l

# --- interaction ----------------------------------------------------------
func _on_race(rid: String) -> void:
	Sfx.play("select")
	_race_id = rid
	_refresh_race()
	_load_hero_model()

func _refresh_race() -> void:
	for rid in _race_buttons:
		_race_buttons[rid].button_pressed = (rid == _race_id)
	var rd: Dictionary = GameData.RACES.get(_race_id, {})
	_race_desc.text = "%s\n\n%s" % [rd.get("blurb", ""), "Mechanic: " + str(rd.get("mechanic", ""))]

func _appear_step(dir: int) -> void:
	Sfx.play("select")
	_appearance = wrapi(_appearance + dir, 0, 3)
	_update_appear()
	_apply_variant_visuals()

func _update_appear() -> void:
	_appear_label.text = "Variant %d" % (_appearance + 1)

func _attr_step(attr: String, dir: int) -> void:
	if dir > 0 and _points_left <= 0:
		return
	if dir < 0 and _attrs[attr] <= START_ATTR:
		return
	_attrs[attr] += dir
	_points_left -= dir
	Sfx.play("select")
	_refresh_attrs()

func _refresh_attrs() -> void:
	_points_label.text = "Points remaining: %d" % _points_left
	for a in _attr_rows:
		_attr_rows[a].text = str(_attrs[a])

# --- hero preview ---------------------------------------------------------
func _load_hero_model() -> void:
	if not is_instance_valid(_preview_pivot):
		return
	# Free previous model
	if is_instance_valid(_preview_model):
		_preview_model.queue_free()
		_preview_model = null

	var rd: Dictionary = GameData.RACES.get(_race_id, {})
	var hero_id: String = str(rd.get("hero", ""))
	if hero_id.is_empty():
		return
	var path := "res://assets/characters/%s/%s.glb" % [hero_id, hero_id]
	if not ResourceLoader.exists(path):
		return

	var packed = load(path)
	if not packed:
		return
	var model: Node3D = packed.instantiate()
	if not model:
		return

	_preview_pivot.add_child(model)
	_preview_model = model

	# Normalize: scale to ~1.8m then ground at y=0
	ModelUtils.scale_to_height(model, 1.8)
	ModelUtils.ground_model(model, 0.0)

	# Apply variant rotation and tint
	_apply_variant_visuals()

func _apply_variant_visuals() -> void:
	if not is_instance_valid(_preview_pivot):
		return
	# Apply starting rotation offset per variant
	var idx := clampi(_appearance, 0, VARIANT_Y_ROT.size() - 1)
	_preview_pivot.rotation.y = VARIANT_Y_ROT[idx]
	# Apply tint to the SubViewportContainer
	if is_instance_valid(_preview_container):
		var tint: Color = VARIANT_TINTS[idx] if idx < VARIANT_TINTS.size() else Color.WHITE
		_preview_container.modulate = tint

func _process(delta: float) -> void:
	# Rotate preview pivot slowly
	if is_instance_valid(_preview_pivot):
		_preview_pivot.rotation.y += 0.5 * delta

func _on_forge() -> void:
	var hname := _name_edit.text.strip_edges()
	if hname == "":
		_name_edit.placeholder_text = "A name is required!"
		_name_edit.grab_focus()
		return
	Sfx.play("select")
	ProfileManager.create_hero(hname, _race_id, _archetype, _appearance, _strength, _weakness, _attrs)
	var origin := Match.consume_pending_hero_origin()
	match origin:
		"campaign":
			get_tree().change_scene_to_file("res://scenes/ui/campaign_map.tscn")
		"skirmish":
			get_tree().change_scene_to_file("res://scenes/ui/skirmish_setup.tscn")
		_:
			get_tree().change_scene_to_file("res://scenes/ui/hero_sheet.tscn")
