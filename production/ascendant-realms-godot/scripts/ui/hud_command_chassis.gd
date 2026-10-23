extends Control
## One forged perimeter behind the live portrait, vitals and command controls.
## Its shape is driven by the actual laid-out controls so selection changes and
## compact/full-HD windows keep the same physical join.

const HUD_TOP_RIBBON := preload("res://scripts/ui/hud_top_ribbon.gd")
const HUD_SKIN := preload("res://scripts/ui/hud_forged_skin.gd")
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
	# Without a portrait crown the selection caption sits right under the
	# top edge, so the painted rail (plan 432) needs a little more air there.
	var selection_top := selection_rect.position.y - (11.0 if has_portrait else 27.0) + inset
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
	# Plan 425: lit forged metal (hud_forged.gdshader) instead of flat fills
	# and drawn lines: a raised bronze rim, a groove, hammered iron, an
	# engraved seam where the selection hands off to the orders, gem bosses
	# at the corners and on the joint, rivets along the foot.
	var outer := _profile(0.0)
	var bottom := maxf(selection_rect.end.y, command_rect.end.y) + 5.0
	var seam_x := command_rect.position.x - 13.0
	var header_y := command_rect.position.y + 31.0
	var studs := [
		Vector4(outer[0].x - 3.0, outer[0].y + 11.0, 7.5, HUD_SKIN.GEM),
		Vector4(outer[9].x - 11.0, outer[9].y + 3.0, 7.5, HUD_SKIN.GEM),
		Vector4(outer[10].x - 11.0, outer[10].y - 3.0, 7.5, HUD_SKIN.GEM),
		Vector4(outer[13].x + 11.0, outer[13].y - 3.0, 7.5, HUD_SKIN.GEM),
		Vector4(seam_x, selection_rect.position.y - 22.0, 9.0, HUD_SKIN.GEM),
	]
	studs.append_array(HUD_SKIN.rivets_along(Vector2(outer[12].x, bottom - 5.5), Vector2(outer[11].x, bottom - 5.5), 150.0, 2.4, 40.0))
	HUD_SKIN.paint(self, outer, studs, Rect2(), {
		"rim": 14.0, "inlay": 0.0,
		"lines": [
			Vector4(seam_x, selection_rect.position.y - 10.0, seam_x, bottom - 16.0),
			Vector4(command_rect.position.x + 14.0, header_y, command_rect.end.x - 14.0, header_y),
		]})
