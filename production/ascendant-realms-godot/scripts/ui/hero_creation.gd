extends Control
## Hero Creation — name, race, archetype, appearance, strength/weakness,
## and starting attribute allocation. Forges the persistent hero.

const FONT := "res://assets/fonts/cinzel.ttf"
const BG := "res://assets/textures/backgrounds/main_menu_bg.png"
const FACTION_SIGILS := preload("res://scripts/ui/faction_sigils.gd")

const ARCHETYPES := ["Warrior", "Commander", "Ranger", "Mage", "Summoner"]
## Strengths and weaknesses are real, small trade-offs (HeroProgression).
const TRAIT_DESC := {
	"Mighty": "+8% damage", "Swift": "+0.3 speed", "Arcane": "+30 mana", "Stalwart": "+2 armour",
	"Frail": "-8% health", "Slow": "-0.2 speed", "Impatient": "-15% mana regeneration", "Reckless": "-1 armour",
}
const ARCH_DESC := {
	"Warrior": "Warrior: first into the line. +60 health and +3 damage.",
	"Commander": "Commander: soldiers fight harder near you. +1.5 command aura damage and +3 m aura reach.",
	"Ranger": "Ranger: quick and far-seeing. +8% attack speed, +3 sight and a little more speed.",
	"Mage": "Mage: the Lume answers you first. +40 mana and +10% spell power.",
	"Summoner": "Summoner: keeper of the host. +20 healing power and +1 mana regeneration.",
}
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
var _dais_ring: MeshInstance3D
var _dais_ring_mat: StandardMaterial3D
var _preview_anim: AnimationPlayer
var _preview_title: Label

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
	# The painting breathes: a slow drift in and out, so the page never feels frozen.
	bg.resized.connect(func(): bg.pivot_offset = bg.size * 0.5)
	var drift := bg.create_tween().set_loops()
	drift.tween_property(bg, "scale", Vector2.ONE * 1.04, 30.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(bg, "scale", Vector2.ONE, 30.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
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

	# Left: the forging form on a dark gilt plate, so it reads as a crafted
	# page rather than loose text floating on the painting.
	var form_plate: PanelContainer = load("res://scripts/ui/hero_sheet_plate.gd").new()
	form_plate.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_plate.set("surface_alpha", 0.82)
	form_plate.set("surface_alpha_bottom", 0.9)
	var form_style := StyleBoxFlat.new()
	form_style.bg_color = Color.TRANSPARENT
	form_style.content_margin_left = 28.0
	form_style.content_margin_right = 14.0
	form_style.content_margin_top = 20.0
	form_style.content_margin_bottom = 16.0
	form_plate.add_theme_stylebox_override("panel", form_style)
	columns.add_child(form_plate)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	form_plate.add_child(scroll)

	var main := VBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 18)
	var form_gutter := MarginContainer.new()
	form_gutter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form_gutter.add_theme_constant_override("margin_right", 16)
	scroll.add_child(form_gutter)
	form_gutter.add_child(main)

	# Name
	main.add_child(_section_label("Name"))
	_name_edit = LineEdit.new()
	_name_edit.placeholder_text = "Enter a hero name..."
	_name_edit.custom_minimum_size = Vector2(400, 40)
	_name_edit.add_theme_font_override("font", ThemeDB.fallback_font)
	_name_edit.add_theme_color_override("font_color", Color.WHITE)
	_name_edit.add_theme_font_size_override("font_size", 20)
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
		rb.custom_minimum_size = Vector2(230, 48)
		rb.focus_mode = Control.FOCUS_NONE
		rb.clip_text = false
		rb.text = rd.get("name", rid)
		rb.add_theme_font_override("font", ThemeDB.fallback_font)
		rb.add_theme_color_override("font_color", Color(0.95, 0.9, 0.75))
		rb.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
		rb.add_theme_color_override("font_pressed_color", Color(1.0, 0.91, 0.69))
		rb.add_theme_font_size_override("font_size", 18)
		var selected_style := StyleBoxFlat.new()
		selected_style.bg_color = Color(0.27, 0.21, 0.11, 0.96)
		selected_style.border_color = Color(0.98, 0.78, 0.42)
		selected_style.set_border_width_all(2)
		selected_style.set_corner_radius_all(4)
		rb.add_theme_stylebox_override("pressed", selected_style)
		rb.pressed.connect(_on_race.bind(rid))
		# The faction's sigil on the left of its button.
		var race_col: Color = rd.get("color", Color(0.8, 0.7, 0.5))
		var sig := Control.new()
		sig.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sig.position = Vector2(8, 6)
		sig.size = Vector2(36, 36)
		var sig_race := String(rid)
		sig.draw.connect(func():
			sig.draw_circle(Vector2(18, 18), 16.0, Color(0.04, 0.035, 0.03, 0.9))
			sig.draw_circle(Vector2(18, 18), 14.0, race_col.darkened(0.3))
			sig.draw_arc(Vector2(18, 18), 16.0, 0.0, TAU, 28, Color(0.95, 0.78, 0.42), 1.4, true)
			FACTION_SIGILS.draw(sig, sig_race, Vector2(18, 18), 10.0, Color(0.99, 0.93, 0.75)))
		rb.add_child(sig)
		rb.add_theme_constant_override("h_separation", 0)
		rb.alignment = HORIZONTAL_ALIGNMENT_CENTER
		rb.text = "      " + rb.text
		_race_buttons[rid] = rb
		race_grid.add_child(rb)
	_race_desc = Label.new()
	_race_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_race_desc.custom_minimum_size = Vector2(500, 0)
	_race_desc.add_theme_font_override("font", ThemeDB.fallback_font)
	_race_desc.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82))
	_race_desc.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	_race_desc.add_theme_constant_override("outline_size", 3)
	_race_desc.add_theme_font_size_override("font_size", 19)
	main.add_child(_race_desc)

	# Archetype
	main.add_child(_section_label("Archetype"))
	# Five paths, each a real starting bonus (HeroProgression), picked like
	# the races rather than from a bare dropdown.
	var arch_row := HBoxContainer.new()
	arch_row.add_theme_constant_override("separation", 10)
	main.add_child(arch_row)
	var arch_desc := Label.new()
	arch_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	arch_desc.custom_minimum_size = Vector2(500, 0)
	arch_desc.add_theme_font_override("font", ThemeDB.fallback_font)
	arch_desc.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82))
	arch_desc.add_theme_font_size_override("font_size", 17)
	var arch_group := ButtonGroup.new()
	for i in ARCHETYPES.size():
		var ab := Button.new()
		ab.toggle_mode = true
		ab.button_group = arch_group
		ab.custom_minimum_size = Vector2(170, 44)
		ab.focus_mode = Control.FOCUS_NONE
		ab.text = ARCHETYPES[i]
		ab.add_theme_font_override("font", ThemeDB.fallback_font)
		ab.add_theme_font_size_override("font_size", 18)
		ab.add_theme_color_override("font_pressed_color", Color(1.0, 0.91, 0.69))
		var sel := StyleBoxFlat.new()
		sel.bg_color = Color(0.27, 0.21, 0.11, 0.96)
		sel.border_color = Color(0.98, 0.78, 0.42)
		sel.set_border_width_all(2)
		sel.set_corner_radius_all(4)
		ab.add_theme_stylebox_override("pressed", sel)
		ab.button_pressed = ARCHETYPES[i] == _archetype
		var cap := String(ARCHETYPES[i])
		# A small emblem of the calling: sword, banner, bow, star, skull-candle.
		var em := Control.new()
		em.mouse_filter = Control.MOUSE_FILTER_IGNORE
		em.position = Vector2(8, 8)
		em.size = Vector2(28, 28)
		em.draw.connect(_draw_archetype_emblem.bind(em, cap))
		ab.add_child(em)
		ab.text = "     " + ab.text
		ab.pressed.connect(func():
			_archetype = cap
			arch_desc.text = String(ARCH_DESC.get(cap, ""))
			Sfx.play("select"))
		arch_row.add_child(ab)
	arch_desc.text = String(ARCH_DESC.get(_archetype, ""))
	main.add_child(arch_desc)

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
	_str_option.custom_minimum_size = Vector2(380, 40)
	_str_option.add_theme_font_override("font", ThemeDB.fallback_font)
	_str_option.add_theme_font_size_override("font_size", 19)
	for i in STRENGTHS.size():
		_str_option.add_item("Strength: %s (%s)" % [STRENGTHS[i], TRAIT_DESC.get(STRENGTHS[i], "")], i)
	_str_option.item_selected.connect(func(idx): _strength = STRENGTHS[idx]; Sfx.play("select"))
	sw_row.add_child(_str_option)
	_weak_option = OptionButton.new()
	_weak_option.custom_minimum_size = Vector2(380, 40)
	_weak_option.add_theme_font_override("font", ThemeDB.fallback_font)
	_weak_option.add_theme_font_size_override("font_size", 19)
	for i in WEAKNESSES.size():
		_weak_option.add_item("Weakness: %s (%s)" % [WEAKNESSES[i], TRAIT_DESC.get(WEAKNESSES[i], "")], i)
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
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		attr_grid.add_child(name_lbl)
		var minus := Button.new()
		minus.text = "-"
		minus.clip_text = false
		minus.custom_minimum_size = Vector2(44, 36)
		minus.add_theme_font_size_override("font_size", 24)
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
		val.add_theme_font_size_override("font_size", 21)
		attr_grid.add_child(val)
		var plus := Button.new()
		plus.text = "+"
		plus.clip_text = false
		plus.custom_minimum_size = Vector2(44, 36)
		plus.add_theme_font_size_override("font_size", 24)
		plus.focus_mode = Control.FOCUS_NONE
		plus.add_theme_color_override("font_color", Color.WHITE)
		plus.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
		plus.pressed.connect(_attr_step.bind(a, 1))
		attr_grid.add_child(plus)
		_attr_rows[a] = val

	# Right: Hero preview panel
	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(440, 0)
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(preview_panel)

	var preview_v := VBoxContainer.new()
	preview_v.add_theme_constant_override("separation", 8)
	preview_panel.add_child(preview_v)
	# Clear the frame's top crest so the faction name sits inside the frame.
	var crest_gap := Control.new()
	crest_gap.custom_minimum_size = Vector2(0, 30)
	preview_v.add_child(crest_gap)

	_preview_title = Label.new()
	_preview_title.text = "HERO PREVIEW"
	_preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_title.add_theme_font_override("font", _title_font(20))
	_preview_title.add_theme_font_size_override("font_size", 20)
	_preview_title.add_theme_color_override("font_color", Color(0.9, 0.78, 0.5))
	_preview_title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	_preview_title.add_theme_constant_override("outline_size", 3)
	preview_v.add_child(_preview_title)

	_preview_container = SubViewportContainer.new()
	_preview_container.stretch = true
	_preview_container.custom_minimum_size = Vector2(400, 620)
	_preview_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_v.add_child(_preview_container)

	_preview_viewport = SubViewport.new()
	_preview_viewport.size = Vector2i(400, 620)
	_preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_preview_viewport.transparent_bg = true
	_preview_container.add_child(_preview_viewport)

	# World3D for the viewport
	var world := World3D.new()
	_preview_viewport.world_3d = world

	# Camera — position in front of model, default -Z forward looks at origin
	_preview_cam = Camera3D.new()
	_preview_cam.position = Vector3(0.0, 1.15, 2.6)
	_preview_cam.fov = 60.0
	_preview_viewport.add_child(_preview_cam)
	_preview_cam.look_at(Vector3(0.0, 0.96, 0.0))
	_preview_container.resized.connect(_fit_preview_cam)

	# Environment — ambient + sky color so model is readable
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.08, 0.12)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.58, 0.75)
	env.ambient_light_energy = 0.76
	env_node.environment = env
	_preview_viewport.add_child(env_node)

	# Key directional light
	var key_light := DirectionalLight3D.new()
	key_light.light_color = Color(1.0, 0.95, 0.85)
	key_light.light_energy = 1.35
	key_light.rotation_degrees = Vector3(-40.0, 30.0, 0.0)
	_preview_viewport.add_child(key_light)

	# Fill/back light for depth
	var fill_light := DirectionalLight3D.new()
	fill_light.light_color = Color(0.6, 0.7, 1.0)
	fill_light.light_energy = 0.72
	fill_light.rotation_degrees = Vector3(-20.0, 200.0, 0.0)
	_preview_viewport.add_child(fill_light)

	# Pivot for rotation
	_preview_pivot = Node3D.new()
	_preview_viewport.add_child(_preview_pivot)

	# A stone dais under the hero, ringed with a glowing band of Lume in the
	# faction's colour, and a warm rim light from behind.
	var dais := MeshInstance3D.new()
	var dm := CylinderMesh.new()
	dm.top_radius = 0.56
	dm.bottom_radius = 0.64
	dm.height = 0.16
	dm.radial_segments = 40
	dais.mesh = dm
	var stone := StandardMaterial3D.new()
	stone.albedo_color = Color(0.09, 0.085, 0.08)
	stone.roughness = 0.9
	dais.material_override = stone
	dais.position = Vector3(0, -0.08, 0)
	_preview_viewport.add_child(dais)
	_dais_ring = MeshInstance3D.new()
	var rm := TorusMesh.new()
	rm.inner_radius = 0.57
	rm.outer_radius = 0.61
	rm.rings = 48
	rm.ring_segments = 6
	_dais_ring.mesh = rm
	_dais_ring_mat = StandardMaterial3D.new()
	_dais_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_dais_ring_mat.albedo_color = Color(1.0, 0.8, 0.4)
	_dais_ring.material_override = _dais_ring_mat
	_dais_ring.position = Vector3(0, 0.01, 0)
	_preview_viewport.add_child(_dais_ring)
	var rim := OmniLight3D.new()
	rim.light_color = Color(1.0, 0.8, 0.5)
	rim.light_energy = 1.4
	rim.omni_range = 4.0
	rim.position = Vector3(0, 1.6, -1.2)
	_preview_viewport.add_child(rim)

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
	back.add_theme_font_override("font", ThemeDB.fallback_font)
	back.add_theme_font_size_override("font_size", 20)
	back.add_theme_color_override("font_color", Color.WHITE)
	back.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	back.pressed.connect(func(): Sfx.play("select"); Match.clear_pending_hero_origin(); get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn"))
	footer.add_child(back)
	var forge := Button.new()
	forge.text = "Forge Hero"
	forge.clip_text = false
	forge.custom_minimum_size = Vector2(260, 50)
	forge.focus_mode = Control.FOCUS_NONE
	forge.add_theme_font_override("font", ThemeDB.fallback_font)
	forge.add_theme_font_size_override("font_size", 20)
	forge.add_theme_color_override("font_color", Color(0.98, 0.92, 0.6))
	forge.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	forge.pressed.connect(_on_forge)
	footer.add_child(forge)
	# The one action this page leads to breathes a slow warm light, like
	# Begin Battle and the saga button.
	var breathe := forge.create_tween().set_loops()
	breathe.tween_property(forge, "self_modulate", Color(1.18, 1.08, 0.9), 1.4).set_trans(Tween.TRANS_SINE)
	breathe.tween_property(forge, "self_modulate", Color.WHITE, 1.4).set_trans(Tween.TRANS_SINE)

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

## The frame is tall and narrow on 4:3 and 16:10 screens: the camera steps
## back so the hero's dais stays inside it.
func _fit_preview_cam() -> void:
	if not is_instance_valid(_preview_cam) or not is_instance_valid(_preview_container):
		return
	var base_z := 3.1 if _race_id == "lioraen" else 2.6
	var sz := _preview_container.size
	var aspect := sz.x / maxf(1.0, sz.y)
	_preview_cam.position.z = base_z * maxf(1.0, 0.62 / maxf(0.2, aspect))
	_preview_cam.look_at(Vector3(0.0, 0.96, 0.0))

func _refresh_race() -> void:
	# The dais ring takes the chosen faction's colour.
	if _dais_ring_mat != null:
		_dais_ring_mat.albedo_color = Color(GameData.RACES.get(_race_id, {}).get("color", Color(1.0, 0.8, 0.4))).lightened(0.25)
	for rid in _race_buttons:
		_race_buttons[rid].button_pressed = (rid == _race_id)
	var rd: Dictionary = GameData.RACES.get(_race_id, {})
	# The saga origin of a Jardas of this blood (see the campaign prologue).
	var origins := {
		"barrosan": "Your Jardas: born and raised in Salto, where the Lume first chose them.",
		"lioraen": "Your Jardas: a foundling from the Spring of Seven Mouths, a Moura's child raised in Salto.",
		"vorthak": "Your Jardas: grandchild of drowned Furna; ash-glass burns in their veins when they are angry.",
		"grimtusk": "Your Jardas: born in the Dominion's iron pits, carried to Salto by a smuggler.",
		"sylvan": "Your Jardas: a Moura of the Court who fled eternity to live in Salto.",
		"karak": "Your Jardas: a castro child who would not turn to stone.",
		"sunspear": "Your Jardas: a Dominion surveyor's child, left behind in the valley meant to drown.",
		"wyldkin": "Your Jardas: a seventh child of a seventh child, whom the wolves came for.",
		"hollow": "Your Jardas: born in the procession of the dead, carried out at dawn.",
		"frostborn": "Your Jardas: a foundling of the Larouco, wrapped in a Careto's fringes.",
	}
	var origin := String(origins.get(_race_id, ""))
	# The first battle cry of this people, as your hero will call it.
	var cries: Array = load("res://scripts/game/bark_defs.gd").LINES.get(_race_id, {}).get("start", [])
	var cry := ("\n\nBattle cry: “%s”" % String(cries[0])) if not cries.is_empty() else ""
	_race_desc.text = "%s\n\n%s%s%s" % [rd.get("blurb", ""), str(rd.get("mechanic", "")), ("\n\n" + origin) if origin != "" else "", cry]
	if is_instance_valid(_preview_title):
		_preview_title.text = str(rd.get("name", "Hero Preview")).to_upper()

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
	_preview_anim = null

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
	_play_preview_idle(model, hero_id)
	_fit_preview_cam()

	# Apply variant rotation and tint
	_apply_variant_visuals()

func _play_preview_idle(model: Node3D, hero_id: String) -> void:
	_preview_anim = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if not _preview_anim:
		var lib_path := "res://assets/characters/%s/%s_animations.tres" % [hero_id, hero_id]
		if ResourceLoader.exists(lib_path):
			var library := load(lib_path) as AnimationLibrary
			if library:
				_preview_anim = AnimationPlayer.new()
				model.add_child(_preview_anim)
				_preview_anim.add_animation_library("", library)
	if not _preview_anim:
		return
	ModelUtils.set_animation_loops(_preview_anim)
	for clip in _preview_anim.get_animation_list():
		if "idle" in clip.to_lower():
			_preview_anim.play(clip)
			return

func _apply_variant_visuals() -> void:
	if not is_instance_valid(_preview_pivot):
		return
	# Apply starting rotation offset per variant
	var idx := clampi(_appearance, 0, VARIANT_Y_ROT.size() - 1)
	_preview_pivot.rotation.y = PI + VARIANT_Y_ROT[idx]
	# Apply tint to the SubViewportContainer
	if is_instance_valid(_preview_container):
		var tint: Color = VARIANT_TINTS[idx] if idx < VARIANT_TINTS.size() else Color.WHITE
		_preview_container.modulate = tint

func _process(delta: float) -> void:
	# Rotate preview pivot slowly
	if is_instance_valid(_preview_pivot):
		_preview_pivot.rotation.y += 0.25 * delta

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

func _draw_archetype_emblem(em: Control, cap: String) -> void:
	var c := Vector2(14, 14)
	var g := Color(0.95, 0.8, 0.5)
	if cap == "Warrior":
		em.draw_line(c + Vector2(-8, 8), c + Vector2(8, -8), g, 2.6, true)
		em.draw_line(c + Vector2(-9, 3), c + Vector2(-3, 9), g, 2.2, true)
	elif cap == "Commander":
		em.draw_line(c + Vector2(-7, 10), c + Vector2(-7, -10), g, 2.0, true)
		em.draw_colored_polygon(PackedVector2Array([c + Vector2(-6, -10), c + Vector2(9, -6), c + Vector2(-6, -1)]), g)
	elif cap == "Ranger":
		em.draw_arc(c + Vector2(-4, 0), 10.0, -1.2, 1.2, 12, g, 2.0, true)
		em.draw_line(c + Vector2(-8, 0), c + Vector2(10, 0), g, 1.6, true)
		em.draw_colored_polygon(PackedVector2Array([c + Vector2(10, 0), c + Vector2(5, -3), c + Vector2(5, 3)]), g)
	elif cap == "Mage":
		for q in 8:
			var a := q * TAU / 8.0
			em.draw_line(c, c + Vector2(cos(a), sin(a)) * (10.0 if q % 2 == 0 else 5.0), g, 1.8, true)
	else:
		em.draw_rect(Rect2(c + Vector2(-3, -2), Vector2(6, 11)), g)
		em.draw_colored_polygon(PackedVector2Array([c + Vector2(0, -11), c + Vector2(3, -4), c + Vector2(-3, -4)]), Color(1.0, 0.9, 0.55))
