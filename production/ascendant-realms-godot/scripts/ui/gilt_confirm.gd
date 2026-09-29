extends Control
## A confirmation on the gilt plate, in place of the engine's plain grey
## dialog: a dimmed screen, a title, the question, and two forged buttons.
## The action button is tinted red when it cannot be undone.

signal confirmed

const PLATE_SCRIPT := preload("res://scripts/ui/hero_sheet_plate.gd")
const FONT := "res://assets/fonts/cinzel.ttf"


## Adds the dialog to `parent` and returns it; connect to `confirmed`.
static func ask(parent: Node, title: String, question: String, action: String, destructive: bool = false) -> Control:
	var d: Control = load("res://scripts/ui/gilt_confirm.gd").new()
	parent.add_child(d)
	d._build(title, question, action, destructive)
	return d


func _build(title: String, question: String, action: String, destructive: bool) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.01, 0.72)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var plate: PanelContainer = PLATE_SCRIPT.new()
	plate.surface_alpha = 0.97
	plate.surface_alpha_bottom = 0.95
	var pad := StyleBoxEmpty.new()
	pad.content_margin_left = 44.0
	pad.content_margin_right = 44.0
	pad.content_margin_top = 30.0
	pad.content_margin_bottom = 30.0
	plate.add_theme_stylebox_override("panel", pad)
	plate.custom_minimum_size = Vector2(560, 0)
	plate.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	plate.grow_horizontal = Control.GROW_DIRECTION_BOTH
	plate.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(plate)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	plate.add_child(box)
	var font: Font = load(FONT) if ResourceLoader.exists(FONT) else ThemeDB.fallback_font
	var t := Label.new()
	t.text = title.to_upper()
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_override("font", font)
	t.add_theme_font_size_override("font_size", 26)
	t.add_theme_color_override("font_color", Color(1.0, 0.62, 0.5) if destructive else Color(0.98, 0.84, 0.46))
	box.add_child(t)
	var q := Label.new()
	q.text = question
	q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q.custom_minimum_size = Vector2(470, 0)
	q.add_theme_font_override("font", ThemeDB.fallback_font)
	q.add_theme_font_size_override("font_size", 18)
	q.add_theme_color_override("font_color", Color(0.92, 0.89, 0.8))
	box.add_child(q)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.custom_minimum_size = Vector2(180, 48)
	cancel.focus_mode = Control.FOCUS_NONE
	cancel.add_theme_font_size_override("font_size", 18)
	cancel.pressed.connect(func():
		Sfx.play("select")
		queue_free())
	row.add_child(cancel)
	var ok := Button.new()
	ok.text = action
	ok.custom_minimum_size = Vector2(200, 48)
	ok.focus_mode = Control.FOCUS_NONE
	ok.add_theme_font_size_override("font_size", 18)
	ok.add_theme_color_override("font_color", Color(1.0, 0.66, 0.58) if destructive else Color(0.98, 0.92, 0.6))
	if destructive:
		ok.self_modulate = Color(1.15, 0.8, 0.75)
	ok.pressed.connect(func():
		Sfx.play("stamp", -6.0)
		confirmed.emit()
		queue_free())
	row.add_child(ok)
	# A short arrival: the plate settles into place.
	plate.pivot_offset = Vector2(280, 120)
	plate.scale = Vector2.ONE * 1.06
	modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.18)
	tw.tween_property(plate, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	Sfx.play("page", -8.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
