extends Control
## Build site card: the three stages of raising a building on one Lume rail,
## the share done, and how many workers are on it. No inner frame; it sits on
## the deck like the rest of the command card.

const STAGES := [["Foundations", 0.0, 0.25], ["Frame", 0.25, 0.70], ["Finishing", 0.70, 1.0]]

var progress := 0.0
var builders := 0
var _pulse := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(true)


func _process(delta: float) -> void:
	_pulse = fmod(_pulse + delta * 1.6, TAU)
	queue_redraw()


func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	queue_redraw()


func set_builders(count: int) -> void:
	builders = maxi(0, count)
	queue_redraw()


func stage_index() -> int:
	for i in STAGES.size():
		if progress < float(STAGES[i][2]):
			return i
	return STAGES.size() - 1


func _draw() -> void:
	if size.x < 160.0 or size.y < 90.0:
		return
	var w := size.x
	var display := RqKit.font(RqKit.FONT_DISPLAY_BOLD)
	var body := RqKit.font(RqKit.FONT_BODY)
	var body_bold := RqKit.font(RqKit.FONT_BODY_BOLD)
	var current := stage_index()
	var lume: Color = RqKit.mat("lume")
	var lume_hi: Color = RqKit.mat("lume_hi")
	var edge_mid: Color = RqKit.mat("edge_mid")
	var edge_hi: Color = RqKit.mat("edge_hi")

	# Headline: the stage being worked, and the share done.
	var stage_name := String(STAGES[current][0])
	draw_string(display, Vector2(2, 26), stage_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, RqKit.TEXT_BRIGHT)
	var pct := "%d%%" % roundi(progress * 100.0)
	var pw := display.get_string_size(pct, HORIZONTAL_ALIGNMENT_LEFT, -1, 26).x
	draw_string_outline(display, Vector2(w - pw - 2, 28), pct, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, 4, Color(0, 0, 0, 0.6))
	draw_string(display, Vector2(w - pw - 2, 28), pct, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, RqKit.TEXT_GILT)

	# Rail: a recessed groove, lit with Lume up to the progress point.
	var x0 := 10.0
	var x1 := w - 10.0
	var y := 52.0
	draw_line(Vector2(x0, y + 1), Vector2(x1, y + 1), Color(0, 0, 0, 0.75), 6.0)
	draw_line(Vector2(x0, y), Vector2(x1, y), RqKit.WELL, 4.0)
	draw_line(Vector2(x0, y - 2.5), Vector2(x1, y - 2.5), Color(edge_mid.r, edge_mid.g, edge_mid.b, 0.35), 1.0)
	var xp := lerpf(x0, x1, progress)
	if xp > x0 + 1.0:
		var glow := 0.75 + 0.25 * sin(_pulse)
		draw_line(Vector2(x0, y), Vector2(xp, y), Color(lume.r, lume.g, lume.b, 0.10 * glow), 12.0)
		draw_line(Vector2(x0, y), Vector2(xp, y), Color(lume.r, lume.g, lume.b, 0.28 * glow), 6.0)
		draw_line(Vector2(x0, y), Vector2(xp, y), lume_hi, 2.0)
		draw_circle(Vector2(xp, y), 3.5, lume_hi)
		draw_circle(Vector2(xp, y), 7.0 + 1.5 * sin(_pulse), Color(lume.r, lume.g, lume.b, 0.18))

	# Stage marks: a diamond at each stage's end, captions centred under each span.
	for i in STAGES.size():
		var s0 := float(STAGES[i][1])
		var s1 := float(STAGES[i][2])
		var mx := lerpf(x0, x1, s1)
		var done := progress >= s1
		var d := 6.0
		var diamond := PackedVector2Array([Vector2(mx, y - d), Vector2(mx + d, y), Vector2(mx, y + d), Vector2(mx - d, y)])
		draw_colored_polygon(diamond, lume_hi if done else RqKit.WELL)
		var rim := PackedVector2Array(diamond)
		rim.append(diamond[0])
		draw_polyline(rim, edge_hi if done else Color(edge_mid.r, edge_mid.g, edge_mid.b, 0.7), 1.2, true)
		var cap := String(STAGES[i][0])
		var face := body_bold if i == current else body
		var colour := RqKit.TEXT_BRIGHT if i == current else (RqKit.TEXT_MUTED if done else RqKit.TEXT_DIM)
		var cw := face.get_string_size(cap, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		var cx := clampf(lerpf(x0, x1, (s0 + s1) * 0.5) - cw * 0.5, 0.0, w - cw)
		draw_string(face, Vector2(cx, y + 26), cap, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, colour)

	# Who is building it, in plain words.
	var crew := "No workers on it. Right-click workers on the site to build." if builders == 0 \
		else ("1 worker building. More hands raise it faster." if builders == 1 \
		else "%d workers building. More hands raise it faster." % builders)
	draw_string(body, Vector2(2, size.y - 6), crew, HORIZONTAL_ALIGNMENT_LEFT, w - 4, 14, RqKit.NEGATIVE.lerp(RqKit.TEXT_MUTED, 0.35) if builders == 0 else RqKit.TEXT_MUTED)
