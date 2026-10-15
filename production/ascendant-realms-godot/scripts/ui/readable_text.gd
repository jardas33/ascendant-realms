extends Node
## Keeps small menu and HUD text readable on every screen.
##
## The theme's default font is Cinzel, a thin all-capitals display face. It
## reads well on titles, but below about 18 px its strokes blur and players
## squint at it (Emanuel, 2026-10-15). Every text control that would draw
## Cinzel smaller than TITLE_MIN switches to the plain body font, and no text
## control draws smaller than BODY_MIN as drawn after any zoom or HUD scale.
## Controls are checked once, at the end of the frame they join the
## tree, after their builder has set their sizes.

const TITLE_FONT := "res://assets/fonts/cinzel.ttf"
const TITLE_MIN := 18
const BODY_MIN := 16

var _pending: Array[Control] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().node_added.connect(_on_node_added)
	set_process(false)


func _on_node_added(node: Node) -> void:
	if node is Label or node is Button or node is LineEdit or node is RichTextLabel:
		_pending.append(node)
		set_process(true)


func _process(_delta: float) -> void:
	var batch := _pending
	_pending = []
	set_process(false)
	for c in batch:
		if is_instance_valid(c) and c.is_inside_tree():
			fix(c)


static func fix(c: Control) -> void:
	var font_key := "normal_font" if c is RichTextLabel else "font"
	var size_key := "normal_font_size" if c is RichTextLabel else "font_size"
	var size := c.get_theme_font_size(size_key)
	# Sizes are judged as drawn on the 1080-line canvas: the battle HUD is
	# scaled up (1.2x at 1920), so its 12 px text already draws at 14.4.
	var scale := maxf(0.01, c.get_global_transform_with_canvas().get_scale().y)
	# The battle HUD sizes its own text up for the screen (1.2x at 1920) and
	# packs its panels to those sizes, so it keeps them.
	# A zoomed canvas (the skill tree) places its captions by their own sizes
	# and sizes them for the window itself: only plain screens take the lift.
	var floor_px := BODY_MIN * (_small_window_lift(c) if absf(scale - 1.0) < 0.05 else 1.0)
	if size * scale < floor_px and not _in_battle_hud(c):
		size = ceili(floor_px / scale)
		c.add_theme_font_size_override(size_key, size)
	# The font is judged at the size it was given: a zoomed-out canvas (the
	# skill tree) keeps its named Cinzel stars.
	var font := c.get_theme_font(font_key)
	if size < TITLE_MIN and font != null and font.resource_path == TITLE_FONT:
		c.add_theme_font_override(font_key, ThemeDB.fallback_font)


## The game lays out on a 1920x1080 canvas and shrinks it to smaller windows:
## at 1366x768 a 16 px menu text reached the eye at 11 px. The floor rises
## by the square root of that shrink (1.19x at 1366, 1.1x at 1600), the same
## compromise as the battle HUD panels: about 14 px on a laptop screen.
## Screens with fixed text boxes size them by this too.
static func _small_window_lift(c: Node) -> float:
	var window := c.get_window() if c.is_inside_tree() else null
	if window == null:
		return 1.0
	var canvas := c.get_viewport().get_visible_rect().size
	var win := Vector2(window.size)
	if win.x <= 0.0 or win.y <= 0.0 or canvas.x <= 0.0:
		return 1.0
	var shrink := minf(win.x / canvas.x, win.y / canvas.y)
	return clampf(sqrt(1.0 / maxf(shrink, 0.01)), 1.0, 1.2)


static func _in_battle_hud(c: Node) -> bool:
	var n := c.get_parent()
	while n != null:
		if n.is_in_group("battle_hud"):
			return true
		n = n.get_parent()
	return false
