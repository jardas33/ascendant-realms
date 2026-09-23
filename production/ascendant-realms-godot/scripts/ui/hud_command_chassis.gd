extends Control
## One forged perimeter behind the live portrait, vitals and command controls.
## Its shape is driven by the actual laid-out controls so selection changes and
## compact/full-HD windows keep the same physical join.

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
	var outer := _profile(0.0)
	var shadow := PackedVector2Array()
	for point in outer:
		shadow.append(point + Vector2(0, 6))
	draw_colored_polygon(shadow, Color(0.005, 0.008, 0.012, 0.74))
	draw_colored_polygon(outer, Color(0.16, 0.18, 0.18, 0.99))
	draw_polyline(_closed(outer), Color(0.67, 0.55, 0.38, 0.77), 1.5, true)
	var inset := _profile(5.0)
	draw_colored_polygon(inset, Color(0.025, 0.037, 0.043, 0.985))
	draw_polyline(_closed(inset), Color(0.035, 0.056, 0.063, 0.84), 1.2, true)
	var bottom := maxf(selection_rect.end.y, command_rect.end.y) + 5.0
	# A single broad iron facet seats the portrait into the chassis. It reads as
	# a forged material change, rather than an extra rectangular portrait panel.
	if has_portrait:
		var facet := PackedVector2Array([
			Vector2(selection_rect.position.x + 1.0, portrait_rect.position.y + 27.0),
			Vector2(portrait_rect.end.x + 6.0, selection_rect.position.y + 9.0),
			Vector2(portrait_rect.end.x + 6.0, bottom - 12.0),
			Vector2(selection_rect.position.x + 1.0, bottom - 22.0)])
		draw_colored_polygon(facet, Color(0.13, 0.14, 0.13, 0.21))
		for rivet in [Vector2(selection_rect.position.x + 16.0, bottom - 22.0), Vector2(portrait_rect.end.x - 10.0, bottom - 22.0)]:
			draw_circle(rivet, 3.3, Color(0.32, 0.29, 0.23, 0.84))
			draw_circle(rivet, 1.6, Color(0.025, 0.031, 0.033, 0.95))
	# A dark forged heel ties all three live regions to the bottom edge. Only
	# structural ridges catch brass light; interior content owns no gold boxes.
	var heel_y := minf(size.y - 18.0, selection_rect.end.y - 7.0)
	draw_rect(Rect2(selection_rect.position.x + 2.0, heel_y, command_rect.end.x - selection_rect.position.x - 1.0, 8.0), Color(0.012, 0.020, 0.024, 0.92))
	draw_line(Vector2(selection_rect.position.x + 24.0, heel_y), Vector2(command_rect.end.x - 27.0, heel_y), Color(0.64, 0.46, 0.26, 0.34), 1.2, true)
	var ridge_start := portrait_rect.position.x + 31.0 if has_portrait else selection_rect.position.x + 29.0
	var ridge_end := portrait_rect.end.x - 30.0 if has_portrait else selection_rect.position.x + 95.0
	var ridge_y := portrait_rect.position.y - 8.0 if has_portrait else selection_rect.position.y - 11.0
	draw_line(Vector2(ridge_start, ridge_y + 2.0), Vector2(ridge_end, ridge_y + 2.0), Color(0.91, 0.73, 0.43, 0.73), 2.0, true)
	draw_line(Vector2(command_rect.position.x + 28.0, command_rect.position.y - 7.0), Vector2(command_rect.end.x - 29.0, command_rect.position.y - 7.0), Color(0.81, 0.62, 0.35, 0.49), 1.4, true)
	# The transition is a single hammered joint, not a fourth badge floating in
	# the world. Its warm edge marks where unit identity hands off to commands.
	var joint := Vector2(command_rect.position.x - 13.0, selection_rect.position.y - 24.0)
	draw_colored_polygon(PackedVector2Array([joint + Vector2(-9, 0), joint + Vector2(0, -9), joint + Vector2(9, 0), joint + Vector2(0, 9)]), Color(0.35, 0.29, 0.20, 0.97))
	draw_polyline(PackedVector2Array([joint + Vector2(-9, 0), joint + Vector2(0, -9), joint + Vector2(9, 0), joint + Vector2(0, 9), joint + Vector2(-9, 0)]), Color(0.86, 0.66, 0.34, 0.61), 1.2, true)
