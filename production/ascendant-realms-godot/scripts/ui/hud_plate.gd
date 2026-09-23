extends PanelContainer
## A shaped piece of the battle HUD, drawn as layered iron and bronze rather
## than a rectangular Control theme. Children remain ordinary accessible UI.


var plate_kind := "selection"
var accent := Color(0.77, 0.58, 0.30)
var embedded := false


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func _plate_points(rect: Rect2, cuts: Vector4) -> PackedVector2Array:
	var x := rect.position.x
	var y := rect.position.y
	var w := rect.size.x
	var h := rect.size.y
	return PackedVector2Array([
		Vector2(x + cuts.x, y), Vector2(x + w - cuts.y, y),
		Vector2(x + w, y + cuts.y), Vector2(x + w, y + h - cuts.z),
		Vector2(x + w - cuts.z, y + h), Vector2(x + cuts.w, y + h),
		Vector2(x, y + h - cuts.w), Vector2(x, y + cuts.x)])


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var result := PackedVector2Array(points)
	result.append(points[0])
	return result


func _draw() -> void:
	if size.x < 40.0 or size.y < 36.0:
		return
	# The selected unit, portrait and deck share the command chassis perimeter.
	# These containers still own layout/input, but no longer paint three boxes.
	if embedded:
		return
	if plate_kind in ["economy", "force", "objective"]:
		var cut := 16.0 if plate_kind != "objective" else 8.0
		var points := PackedVector2Array([
			Vector2(0, 0), Vector2(size.x - cut, 0),
			Vector2(size.x, cut), Vector2(size.x, size.y - 10),
			Vector2(size.x - 11, size.y), Vector2(12, size.y),
			Vector2(0, size.y - 12)])
		var top_opacity := 0.82 if plate_kind != "objective" else 0.72
		var foot_opacity := 0.35 if plate_kind != "objective" else 0.34
		draw_polygon(points, PackedColorArray([
			Color(0.019, 0.030, 0.036, top_opacity),
			Color(0.019, 0.030, 0.036, top_opacity),
			Color(0.019, 0.030, 0.036, top_opacity * 0.83),
			Color(0.019, 0.030, 0.036, foot_opacity),
			Color(0.019, 0.030, 0.036, foot_opacity),
			Color(0.019, 0.030, 0.036, foot_opacity),
			Color(0.019, 0.030, 0.036, foot_opacity * 0.70)]))
		draw_line(Vector2(8, 1), Vector2(size.x - cut - 8, 1), Color(accent.r, accent.g, accent.b, 0.43 if plate_kind != "objective" else 0.26), 1.2, true)
		draw_line(Vector2(1, 13), Vector2(1, size.y - 13), Color(accent.r, accent.g, accent.b, 0.24), 1.0, true)
		return
	var cuts := Vector4(18, 16, 19, 12)
	match plate_kind:
		"minimap": cuts = Vector4(27, 38, 18, 18)
		"selection": cuts = Vector4(31, 12, 32, 10)
		"command": cuts = Vector4(35, 14, 13, 31)
		"economy": cuts = Vector4(15, 25, 11, 8)
		"force": cuts = Vector4(25, 12, 18, 8)
		"age": cuts = Vector4(25, 25, 25, 25)
		"portrait": cuts = Vector4(39, 39, 22, 22)
		"objective": cuts = Vector4(10, 22, 20, 9)
	var major := plate_kind in ["minimap", "selection", "command", "portrait"]
	var edge_alpha := 0.54 if major else 0.35
	if plate_kind == "age":
		edge_alpha = 0.76
	if plate_kind == "objective":
		edge_alpha = 0.29
	var outer := _plate_points(Rect2(Vector2.ZERO, size), cuts)
	var shadow := PackedVector2Array()
	for point in outer:
		shadow.append(point + Vector2(0, 5 if major else 3))
	draw_colored_polygon(shadow, Color(0.005, 0.008, 0.012, 0.60 if major else 0.42))
	draw_colored_polygon(outer, Color(0.19, 0.19, 0.18, 0.98))
	draw_polyline(_closed(outer), Color(0.94, 0.75, 0.43, edge_alpha), 1.3, true)
	var inset := _plate_points(Rect2(Vector2(3, 3), size - Vector2(6, 6)), cuts * 0.83)
	draw_colored_polygon(inset, Color(0.035, 0.046, 0.056, 0.97))
	draw_polyline(_closed(inset), Color(0.08, 0.105, 0.115, 0.78), 1.5, true)
	var inner := _plate_points(Rect2(Vector2(8, 8), size - Vector2(16, 16)), cuts * 0.56)
	draw_colored_polygon(inner, Color(0.049, 0.060, 0.066, 0.92))
	if plate_kind == "age" or plate_kind == "portrait":
		draw_polyline(_closed(inner), Color(accent.r, accent.g, accent.b, 0.20), 0.8, true)
	# Broad bands and fine edge glints suggest forged layers without covering
	# the live information or turning the central battlefield into a frame.
	draw_line(Vector2(cuts.x + 9, 5), Vector2(size.x - cuts.y - 9, 5), Color(1.0, 0.82, 0.52, 0.36 if major else 0.20), 1.0, true)
	draw_line(Vector2(cuts.w + 10, size.y - 5), Vector2(size.x - cuts.z - 10, size.y - 5), Color(0.01, 0.014, 0.019, 0.84), 2.0, true)
	var edge_x := 7.0 if plate_kind != "command" else size.x - 7.0
	if major:
		draw_line(Vector2(edge_x, 34), Vector2(edge_x, size.y - 32), Color(accent.r, accent.g, accent.b, 0.25), 1.1, true)
	if plate_kind in ["minimap", "portrait", "age"]:
		for ornament_x in [cuts.x + 5.0, size.x - cuts.y - 5.0]:
			var center := Vector2(ornament_x, 8)
			draw_colored_polygon(PackedVector2Array([center + Vector2(0, -3), center + Vector2(3, 0), center + Vector2(0, 3), center + Vector2(-3, 0)]), accent.lightened(0.24))
			draw_circle(center, 0.8, Color(0.08, 0.07, 0.06))
	if plate_kind == "minimap":
		var medallion := Vector2(size.x * 0.5, 5)
		draw_line(medallion + Vector2(-24, 0), medallion + Vector2(-8, 0), Color(accent.r, accent.g, accent.b, 0.72), 1.2, true)
		draw_line(medallion + Vector2(8, 0), medallion + Vector2(24, 0), Color(accent.r, accent.g, accent.b, 0.72), 1.2, true)
		draw_colored_polygon(PackedVector2Array([medallion + Vector2(0, -5), medallion + Vector2(6, 0), medallion + Vector2(0, 5), medallion + Vector2(-6, 0)]), accent)
	if plate_kind == "age":
		var crest := Vector2(size.x * 0.5, 11)
		draw_arc(crest, 10.0, PI, TAU, 16, Color(accent.r, accent.g, accent.b, 0.75), 1.2, true)
	if plate_kind == "portrait":
		var crown := PackedVector2Array([
			Vector2(size.x * 0.5 - 28, 1), Vector2(size.x * 0.5, -24),
			Vector2(size.x * 0.5 + 28, 1)])
		draw_colored_polygon(crown, Color(0.20, 0.20, 0.19, 0.99))
		draw_polyline(crown, Color(0.88, 0.71, 0.41, 0.88), 1.5, true)
		draw_colored_polygon(PackedVector2Array([
			Vector2(size.x * 0.5 - 4, -4), Vector2(size.x * 0.5, -12),
			Vector2(size.x * 0.5 + 4, -4), Vector2(size.x * 0.5, 2)]), accent)
