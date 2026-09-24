extends Button
## Forged action tile with a cut silhouette and live hover/disabled states.

var accent := Color(0.82, 0.64, 0.36)
var command_kind := "ORDER"
var command_state := "READY"
var is_menu := false


func _ready() -> void:
	resized.connect(queue_redraw)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	queue_redraw()


func set_command_state(value: String) -> void:
	if command_state != value:
		command_state = value
		queue_redraw()


func _draw() -> void:
	if size.x < 32.0 or size.y < 24.0:
		return
	var w := size.x
	var h := size.y
	var lit := (is_hovered() or has_focus()) and not disabled
	var active := command_state in ["ACTIVE", "TRAINING"]
	var enabled := not disabled
	var metal := accent if enabled else accent.lerp(Color(0.33, 0.37, 0.38), 0.68)
	if is_menu:
		var menu_shape := PackedVector2Array([
			Vector2(9, 0), Vector2(w - 8, 0), Vector2(w, 8),
			Vector2(w, h - 8), Vector2(w - 8, h),
			Vector2(8, h), Vector2(0, h - 8), Vector2(0, 9)])
		draw_colored_polygon(menu_shape, Color(0.04, 0.052, 0.058, 0.96))
		var outline := PackedVector2Array(menu_shape)
		outline.append(menu_shape[0])
		draw_polyline(outline, Color(metal.r, metal.g, metal.b, 0.72 if lit else 0.43), 1.2, true)
		return
	if command_kind == "ORDER":
		# The order rack supplies the perimeter. These controls read as engraved
		# slots with a distinct active edge, not four stacked mini panels.
		var order_shape := PackedVector2Array([
			Vector2(0, 5), Vector2(5, 0), Vector2(w - 9, 0),
			Vector2(w, 9), Vector2(w, h - 5), Vector2(w - 5, h),
			Vector2(5, h), Vector2(0, h - 5)])
		var order_base := Color(0.078, 0.086, 0.084, 0.87) if enabled else Color(0.048, 0.053, 0.052, 0.64)
		draw_colored_polygon(order_shape, order_base)
		draw_polygon(PackedVector2Array([
			Vector2(1, 5), Vector2(54, 1), Vector2(54, h - 1), Vector2(1, h - 5)]), PackedColorArray([
			Color(metal.r, metal.g, metal.b, 0.13),
			Color(metal.r, metal.g, metal.b, 0.06),
			Color(metal.r, metal.g, metal.b, 0.025),
			Color(metal.r, metal.g, metal.b, 0.08)]))
		draw_line(Vector2(55, 5), Vector2(55, h - 5), Color(metal.r, metal.g, metal.b, 0.20), 1.0, true)
		var slot_rim := PackedVector2Array(order_shape)
		slot_rim.append(order_shape[0])
		draw_polyline(slot_rim, Color(metal.r, metal.g, metal.b, 0.32 if enabled else 0.13), 1.0, true)
		draw_line(Vector2(7, 1), Vector2(w - 13, 1), Color(metal.r, metal.g, metal.b, 0.27 if enabled else 0.10), 1.0, true)
		draw_line(Vector2(8, h - 1), Vector2(w - 8, h - 1), Color(metal.r, metal.g, metal.b, 0.20), 1.0, true)
		if lit or active:
			var lit_outline := PackedVector2Array(order_shape)
			lit_outline.append(order_shape[0])
			draw_polyline(lit_outline, Color(metal.r, metal.g, metal.b, 0.65 if lit else 0.50), 1.2, true)
		draw_line(Vector2(1, 7), Vector2(1, h - 7), Color(metal.r, metal.g, metal.b, 0.95 if lit or active else 0.34), 2.5, true)
		return
	if command_kind in ["BUILD", "TRAIN", "RESEARCH"]:
		# Give the authored structure and technology art a lit recess instead of
		# letting it disappear against the dark command deck. Cost and readiness
		# remain on the same live controls, with disabled state still legible.
		var row_shape := PackedVector2Array([
			Vector2(0, 8), Vector2(8, 0), Vector2(w - 12, 0),
			Vector2(w, 12), Vector2(w, h - 7), Vector2(w - 7, h),
			Vector2(6, h), Vector2(0, h - 6)])
		var tint := Color(0.070, 0.092, 0.086, 0.95)
		if command_kind == "RESEARCH":
			tint = Color(0.062, 0.083, 0.096, 0.95)
		elif command_kind == "TRAIN":
			tint = Color(0.087, 0.082, 0.073, 0.95)
		if not enabled:
			tint = tint.darkened(0.16)
			tint.a = 0.83
		draw_colored_polygon(row_shape, tint)
		var art_edge := 79.0 if command_kind == "BUILD" else 61.0
		var bay_light := Color(metal.r, metal.g, metal.b, 0.24 if enabled else 0.12)
		draw_polygon(PackedVector2Array([
			Vector2(5, 7), Vector2(art_edge, 4),
			Vector2(art_edge, h - 7), Vector2(5, h - 7)]), PackedColorArray([
			bay_light, Color(metal.r, metal.g, metal.b, 0.12 if enabled else 0.05),
			Color(0.016, 0.026, 0.029, 0.08), Color(metal.r, metal.g, metal.b, 0.08 if enabled else 0.03)]))
		draw_line(Vector2(art_edge, 8), Vector2(art_edge, h - 9), Color(metal.r, metal.g, metal.b, 0.29 if enabled else 0.12), 1.0, true)
		draw_polygon(PackedVector2Array([
			Vector2(6, 1), Vector2(w - 13, 1), Vector2(w - 7, 7), Vector2(5, 7)]), PackedColorArray([
			Color(metal.r, metal.g, metal.b, 0.23),
			Color(metal.r, metal.g, metal.b, 0.17),
			Color(metal.r, metal.g, metal.b, 0.04),
			Color(metal.r, metal.g, metal.b, 0.07)]))
		draw_colored_polygon(PackedVector2Array([
			Vector2(0, 8), Vector2(4, 4), Vector2(4, h - 5), Vector2(0, h - 8)]),
			Color(metal.r, metal.g, metal.b, 0.72 if lit else (0.50 if enabled else 0.20)))
		draw_line(Vector2(8, h - 1), Vector2(w - 8, h - 1), Color(metal.r, metal.g, metal.b, 0.31 if enabled else 0.12), 1.2, true)
		draw_line(Vector2(w - 12, 1), Vector2(w - 1, 12), Color(metal.r, metal.g, metal.b, 0.35 if enabled else 0.12), 1.0, true)
		var row_outline := PackedVector2Array(row_shape)
		row_outline.append(row_shape[0])
		draw_polyline(row_outline, Color(metal.r, metal.g, metal.b, 0.30 if enabled else 0.15), 1.0, true)
		if lit or active:
			draw_polyline(row_outline, Color(metal.r, metal.g, metal.b, 0.67), 1.2, true)
		return
	# A faceted silhouette and raised rail turn flat rows into tactile controls.
	var cut := 9.0 if command_kind == "ABILITY" else 6.0
	var silhouette := PackedVector2Array([
		Vector2(0, cut), Vector2(cut, 0), Vector2(w - 13, 0),
		Vector2(w, 13), Vector2(w, h - cut), Vector2(w - cut, h),
		Vector2(6, h), Vector2(0, h - 6)])
	var base := Color(0.055, 0.068, 0.073, 0.91) if enabled else Color(0.045, 0.051, 0.054, 0.72)
	match command_kind:
		"ABILITY": base = Color(0.083, 0.095, 0.103, 0.97) if enabled else Color(0.053, 0.061, 0.07, 0.78)
		"BUILD": base = Color(0.06, 0.085, 0.082, 0.91) if enabled else Color(0.047, 0.061, 0.06, 0.76)
		"RESEARCH": base = Color(0.055, 0.077, 0.095, 0.94) if enabled else Color(0.046, 0.057, 0.066, 0.76)
	draw_colored_polygon(silhouette, base)
	draw_colored_polygon(PackedVector2Array([
		Vector2(cut, 0), Vector2(w - 13, 0), Vector2(w - 6, 7), Vector2(6, 7)]),
		Color(metal.r, metal.g, metal.b, 0.17 if lit else (0.105 if enabled else 0.045)))
	draw_colored_polygon(PackedVector2Array([
		Vector2(6, h - 6), Vector2(w - 6, h - 6), Vector2(w - cut, h), Vector2(6, h)]),
		Color(0.0, 0.0, 0.0, 0.18))
	if lit or active:
		draw_colored_polygon(PackedVector2Array([
			Vector2(3, 10), Vector2(45, 7), Vector2(67, h - 6), Vector2(4, h - 5)]),
			Color(metal.r, metal.g, metal.b, 0.08 if lit else 0.045))
	var rim := PackedVector2Array(silhouette)
	rim.append(silhouette[0])
	draw_polyline(rim, Color(metal.r, metal.g, metal.b, 0.66 if lit else (0.34 if enabled else 0.18)), 1.0, true)
	draw_line(Vector2(2, 10), Vector2(2, h - 9), Color(metal.r, metal.g, metal.b, 0.95 if lit or active else (0.67 if enabled else 0.25)), 2.4, true)
	draw_line(Vector2(cut + 2, 1), Vector2(w - 16, 1), Color(metal.r, metal.g, metal.b, 0.58 if lit else (0.27 if enabled else 0.10)), 1.0, true)
	draw_line(Vector2(10, h - 2), Vector2(w - 10, h - 2), Color(metal.r, metal.g, metal.b, 0.38 if lit else 0.18), 1.0, true)
	draw_line(Vector2(w - 13, 1), Vector2(w - 1, 13), Color(metal.r, metal.g, metal.b, 0.56 if lit else 0.28), 1.0, true)
	if active:
		draw_line(Vector2(12, h - 2), Vector2(w * 0.52, h - 2), Color(metal.r, metal.g, metal.b, 0.82), 2.0, true)
