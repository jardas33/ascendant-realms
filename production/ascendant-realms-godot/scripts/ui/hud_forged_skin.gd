extends RefCounted
## Plan 425: paints a HUD panel as lit forged metal (hud_forged.gdshader).
## A panel calls paint() from its _draw with its outline; the shader does the
## bevelled bronze rim, groove, hammered iron, rivets, gems and shadow. The
## material belongs to that one CanvasItem, so its children (text, buttons)
## are untouched.

const SHADER := preload("res://assets/shaders/hud_forged.gdshader")
const MAX_PTS := 24
const MAX_STUDS := 24

const RIVET := 0.0
const GEM := 1.0


static func material_for(ci: CanvasItem) -> ShaderMaterial:
	var mat := ci.material as ShaderMaterial
	if mat == null or mat.shader != SHADER:
		mat = ShaderMaterial.new()
		mat.shader = SHADER
		ci.material = mat
	return mat


## points: the outline (local, clockwise or not). studs: Array of Vector4
## (x, y, radius, kind). window: an opening left clear (the minimap).
static func paint(ci: CanvasItem, points: PackedVector2Array, studs: Array = [], window := Rect2(), opts: Dictionary = {}) -> void:
	if points.size() < 3:
		return
	var mat := material_for(ci)
	var pts := PackedVector2Array(points)
	if pts.size() > MAX_PTS:
		pts.resize(MAX_PTS)
	var count := pts.size()
	while pts.size() < MAX_PTS:
		pts.append(Vector2.ZERO)
	var box := Rect2(points[0], Vector2.ZERO)
	for p in points:
		box = box.expand(p)
	var sv := PackedVector4Array()
	for s in studs:
		if sv.size() >= MAX_STUDS:
			break
		sv.append(s)
	var stud_count := sv.size()
	while sv.size() < MAX_STUDS:
		sv.append(Vector4.ZERO)
	mat.set_shader_parameter("point_count", count)
	mat.set_shader_parameter("pts", pts)
	mat.set_shader_parameter("stud_count", stud_count)
	mat.set_shader_parameter("studs", sv)
	var lv := PackedVector4Array()
	for l in opts.get("lines", []):
		if lv.size() >= 16:
			break
		lv.append(l)
	var line_count := lv.size()
	while lv.size() < 16:
		lv.append(Vector4.ZERO)
	mat.set_shader_parameter("line_count", line_count)
	mat.set_shader_parameter("lines", lv)
	mat.set_shader_parameter("window_rect", Vector4(window.position.x, window.position.y, window.size.x, window.size.y))
	mat.set_shader_parameter("plate_top", float(opts.get("plate_top", box.position.y)))
	mat.set_shader_parameter("plate_bottom", float(opts.get("plate_bottom", box.end.y)))
	mat.set_shader_parameter("rim", float(opts.get("rim", 9.0)))
	mat.set_shader_parameter("groove", float(opts.get("groove", 2.5)))
	mat.set_shader_parameter("inlay", float(opts.get("inlay", 9.0)))
	mat.set_shader_parameter("shadow_size", float(opts.get("shadow", 12.0)))
	mat.set_shader_parameter("plate_alpha", float(opts.get("alpha", 0.975)))
	var pad := float(opts.get("shadow", 12.0)) + 2.0
	ci.draw_rect(box.grow(pad), Color.WHITE)


## Rivets evenly spaced along a segment, kept clear of its ends.
static func rivets_along(a: Vector2, b: Vector2, spacing: float, radius: float, margin: float = 18.0) -> Array:
	var out := []
	var length := a.distance_to(b)
	var usable := length - margin * 2.0
	if usable <= 0.0:
		return out
	var n := maxi(1, int(floor(usable / spacing)) + 1)
	var dir := (b - a) / length
	for i in n:
		var t := margin + (usable * (float(i) / float(n - 1)) if n > 1 else usable * 0.5)
		var p := a + dir * t
		out.append(Vector4(p.x, p.y, radius, RIVET))
	return out


## A Control that paints a forged backing behind its parent (for buttons,
## whose own text must not pass through the metal shader).
class Backing extends Control:
	var outline := PackedVector2Array()
	var studs := []
	var window := Rect2()
	var opts := {}

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		show_behind_parent = true

	func set_shape(points: PackedVector2Array, stud_list: Array = [], options: Dictionary = {}) -> void:
		outline = points
		studs = stud_list
		opts = options
		queue_redraw()

	func _draw() -> void:
		load("res://scripts/ui/hud_forged_skin.gd").paint(self, outline, studs, window, opts)
