extends Control
## One forged perimeter behind the live portrait, vitals and command controls.
## Its shape is driven by the actual laid-out controls so selection changes and
## compact/full-HD windows keep the same physical join.

const HUD_TOP_RIBBON := preload("res://scripts/ui/hud_top_ribbon.gd")
const FORGED_TRIM_PATH := "res://assets/ui/hud_instruments/astra_r1/metric_bezel.png"
static var _forged_trim: Texture2D = null

var selection_rect := Rect2()
var command_rect := Rect2()
var portrait_rect := Rect2()
var has_portrait := false


func configure(selection: Rect2, command: Rect2, portrait: Rect2, portrait_present: bool) -> void:
	selection_rect = selection
	command_rect = command
	portrait_rect = portrait
	has_portrait = portrait_present
	visible = selection.size.x > 0.0 and command.size.x > 0.0
	queue_redraw()


func _profile(inset: float) -> PackedVector2Array:
	var left := selection_rect.position.x - 8.0 + inset
	var right := command_rect.end.x + 5.0 - inset
	var bottom := maxf(selection_rect.end.y, command_rect.end.y) + 5.0 - inset
	var command_left := command_rect.position.x
	var command_top := command_rect.position.y - 9.0 + inset
	var selection_top := selection_rect.position.y - 11.0 + inset
	var crown_top := (portrait_rect.position.y - 8.0 if has_portrait else selection_top) + inset
	var crown_right := (portrait_rect.end.x + 7.0 if has_portrait else left + 110.0) - inset
	return PackedVector2Array([
		Vector2(left + 18.0, crown_top),
		Vector2(crown_right - 27.0, crown_top),
		Vector2(crown_right, crown_top + 27.0),
		Vector2(crown_right, selection_top),
		Vector2(command_left - 39.0, selection_top),
		Vector2(command_left - 13.0, selection_top - 24.0),
		Vector2(command_left - 13.0, command_top + 29.0),
		Vector2(command_left + 20.0, command_top),
		Vector2(right - 22.0, command_top),
		Vector2(right, command_top + 22.0),
		Vector2(right, bottom - 24.0),
		Vector2(right - 24.0, bottom),
		Vector2(left + 21.0, bottom),
		Vector2(left, bottom - 21.0),
		Vector2(left, crown_top + 18.0)])


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array(points)
	result.append(points[0])
	return result


func _draw() -> void:
	if not visible or selection_rect.size.x < 80.0 or command_rect.size.x < 80.0:
		return
	# Plan 421: the same cast iron and bronze as the top band and the minimap
	# housing. One body, a bronze hem round its outside, an engraved seam
	# where the selection hands off to the orders, and no boxed trim inside.
	var outer := _profile(0.0)
	var shadow := PackedVector2Array()
	for point in outer:
		shadow.append(point + Vector2(0, 6))
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.50))
	var top_y := outer[0].y
	var bottom := maxf(selection_rect.end.y, command_rect.end.y) + 5.0
	var colors := PackedColorArray()
	for point in outer:
		var t := clampf((point.y - top_y) / maxf(1.0, bottom - top_y), 0.0, 1.0)
		colors.append(Color(0.105, 0.098, 0.088, 0.985).lerp(Color(0.040, 0.042, 0.046, 0.985), t))
	draw_polygon(outer, colors)
	var box := Rect2(outer[0], Vector2.ZERO)
	for point in outer:
		box = box.expand(point)
	draw_texture_rect(HUD_TOP_RIBBON.grain(), box, true, Color(1, 1, 1, 0.05))
	# Bronze hem: dark bed, bronze bar, gilt inner edge.
	var rim := _closed(outer)
	draw_polyline(rim, Color(0.05, 0.035, 0.02, 0.95), 7.0, true)
	draw_polyline(rim, Color(0.62, 0.44, 0.22, 1.0), 4.2, true)
	draw_polyline(_closed(_profile(4.0)), Color(0.98, 0.82, 0.50, 0.42), 1.0, true)
	# A faint warm light on the selection wing, a cooler one on the orders.
	var seam_x := command_rect.position.x - 13.0
	draw_polygon(PackedVector2Array([
		Vector2(selection_rect.position.x, selection_rect.position.y - 6.0), Vector2(seam_x - 4.0, selection_rect.position.y - 6.0),
		Vector2(seam_x - 4.0, bottom - 8.0), Vector2(selection_rect.position.x, bottom - 8.0)]),
		PackedColorArray([Color(0.40, 0.27, 0.12, 0.16), Color(0.40, 0.27, 0.12, 0.05), Color(0, 0, 0, 0), Color(0, 0, 0, 0)]))
	# The seam between the two wings.
	draw_line(Vector2(seam_x, selection_rect.position.y - 20.0), Vector2(seam_x, bottom - 10.0), Color(0, 0, 0, 0.6), 2.0, true)
	draw_line(Vector2(seam_x + 1.6, selection_rect.position.y - 20.0), Vector2(seam_x + 1.6, bottom - 10.0), Color(0.85, 0.66, 0.38, 0.22), 1.0, true)
	# A channel under the orders header, and one along the foot.
	var header_y := command_rect.position.y + 31.0
	draw_line(Vector2(command_rect.position.x + 14.0, header_y), Vector2(command_rect.end.x - 14.0, header_y), Color(0, 0, 0, 0.5), 1.0, true)
	draw_line(Vector2(command_rect.position.x + 14.0, header_y + 1.2), Vector2(command_rect.end.x - 14.0, header_y + 1.2), Color(0.85, 0.66, 0.38, 0.16), 1.0, true)
	# Gem bosses at the outer corners and on the joint.
	for corner in [outer[0] + Vector2(-2, 9), outer[9] + Vector2(-9, 2), outer[10] + Vector2(-9, -2), outer[13] + Vector2(9, -2)]:
		_boss(corner)
	HUD_TOP_RIBBON._finial(self, Vector2(seam_x, selection_rect.position.y - 22.0))


func _boss(c: Vector2) -> void:
	draw_circle(c, 5.0, Color(0.05, 0.035, 0.02, 1.0))
	draw_circle(c, 3.8, Color(0.70, 0.50, 0.25, 1.0))
	draw_circle(c, 1.9, Color(0.55, 0.12, 0.07, 1.0))
	draw_circle(c + Vector2(-0.6, -0.7), 0.7, Color(1, 0.9, 0.8, 0.85))
