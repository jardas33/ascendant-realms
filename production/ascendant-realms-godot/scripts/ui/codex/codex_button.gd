extends Button
## Codex button: a leather tab with a gilt hairline. "primary" fills it with
## vermilion for the one action the page is asking for.

var primary := false
var _hover := 0.0


func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	add_theme_font_override("font", CodexKit.font(CodexKit.FONT_DISPLAY))
	add_theme_font_size_override("font_size", 17)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		add_theme_color_override(state, Color(0, 0, 0, 0))
	var empty := StyleBoxEmpty.new()
	empty.content_margin_left = 22
	empty.content_margin_right = 22
	empty.content_margin_top = 10
	empty.content_margin_bottom = 10
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state, empty)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)


func _process(delta: float) -> void:
	var target := 1.0 if is_hovered() and not disabled else 0.0
	if not is_equal_approx(_hover, target):
		_hover = move_toward(_hover, target, delta * 8.0)
		queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var shape := RqKit.chamfer(r, 6, 6, 6, 6)
	draw_colored_polygon(RqKit.chamfer(r.grow(2.0), 7, 7, 7, 7), Color(0, 0, 0, 0.45))
	var top := CodexKit.LEATHER_HI
	var bottom := CodexKit.LEATHER_LO
	if primary and not disabled:
		top = CodexKit.VERMILION.darkened(0.1)
		bottom = CodexKit.VERMILION.darkened(0.55)
	top = top.lerp(top.lightened(0.25), _hover)
	var cols := PackedColorArray()
	for p in shape:
		cols.append(top.lerp(bottom, p.y / maxf(1.0, size.y)))
	draw_polygon(shape, cols)
	var edge := CodexKit.GILT if not disabled else CodexKit.GILT_LO
	edge.a = 0.55 + 0.45 * _hover
	var ring := PackedVector2Array(RqKit.inset_polygon(shape, 3.0))
	ring.append(ring[0])
	draw_polyline(ring, edge, 1.0, true)
	if get_draw_mode() == DRAW_PRESSED:
		draw_colored_polygon(shape, Color(0, 0, 0, 0.2))
	# The native caption is drawn under the script's paint, so draw our own.
	var f := get_theme_font("font")
	var fs := get_theme_font_size("font_size")
	var ts := f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var at := Vector2((size.x - ts.x) * 0.5, (size.y + f.get_ascent(fs) - f.get_descent(fs)) * 0.5)
	var col := CodexKit.TEXT if not disabled else CodexKit.TEXT_DIM
	draw_string(f, at + Vector2(0, 1), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0, 0, 0, 0.6))
	draw_string(f, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col.lerp(CodexKit.GILT_HI, _hover * 0.6))
