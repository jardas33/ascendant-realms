extends PanelContainer
## A small hanging instrument for one live resource or force value. The dark
## field fades into the world instead of joining a full-width top HUD slab.

const BEZEL_PATH := "res://assets/ui/hud_instruments/astra_r1/metric_bezel.png"
static var _bezel_texture: Texture2D = null

var accent := Color(0.88, 0.68, 0.35)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	if size.x < 32.0 or size.y < 32.0:
		return
	var w := size.x
	var h := size.y
	if _bezel_texture == null and ResourceLoader.exists(BEZEL_PATH):
		_bezel_texture = load(BEZEL_PATH) as Texture2D
	if _bezel_texture:
		# A full-frame shrink crushes the source's metalwork horizontally and
		# makes the rails shimmer. Keep the authored corner proportions and let
		# the long field/rails absorb the change in instrument width.
		var source := _bezel_texture.get_size()
		var source_corner := Vector2(source.x * 0.071, source.y * 0.185)
		var corner := Vector2(13.0, 13.0)
		var middle_source := source - source_corner * 2.0
		var middle := size - corner * 2.0
		for segment in [
			[Rect2(corner, middle), Rect2(source_corner, middle_source)],
			[Rect2(corner.x, 0, middle.x, corner.y), Rect2(source_corner.x, 0, middle_source.x, source_corner.y)],
			[Rect2(corner.x, h - corner.y, middle.x, corner.y), Rect2(source_corner.x, source.y - source_corner.y, middle_source.x, source_corner.y)],
			[Rect2(0, corner.y, corner.x, middle.y), Rect2(0, source_corner.y, source_corner.x, middle_source.y)],
			[Rect2(w - corner.x, corner.y, corner.x, middle.y), Rect2(source.x - source_corner.x, source_corner.y, source_corner.x, middle_source.y)],
			[Rect2(Vector2.ZERO, corner), Rect2(Vector2.ZERO, source_corner)],
			[Rect2(Vector2(w - corner.x, 0), corner), Rect2(Vector2(source.x - source_corner.x, 0), source_corner)],
			[Rect2(Vector2(0, h - corner.y), corner), Rect2(Vector2(0, source.y - source_corner.y), source_corner)],
			[Rect2(size - corner, corner), Rect2(source - source_corner, source_corner)],
		]:
			draw_texture_rect_region(_bezel_texture, segment[0], segment[1])
		return
	var metal := Color(0.025, 0.033, 0.036)
	var silhouette := PackedVector2Array([
		Vector2(7, 0), Vector2(w - 13, 0), Vector2(w, 12),
		Vector2(w, h - 9), Vector2(w - 9, h), Vector2(0, h),
		Vector2(0, 7)])
	draw_polygon(silhouette, PackedColorArray([
		Color(metal.r, metal.g, metal.b, 0.98),
		Color(metal.r, metal.g, metal.b, 0.97),
		Color(metal.r, metal.g, metal.b, 0.94),
		Color(metal.r, metal.g, metal.b, 0.90),
		Color(metal.r, metal.g, metal.b, 0.91),
		Color(metal.r, metal.g, metal.b, 0.94),
		Color(metal.r, metal.g, metal.b, 0.96)]))
	var rim := PackedVector2Array(silhouette)
	rim.append(silhouette[0])
	draw_polyline(rim, Color(accent.r, accent.g, accent.b, 0.62), 1.1, true)
	var lip := PackedVector2Array([
		Vector2(7, 0), Vector2(w - 13, 0), Vector2(w - 3, 10),
		Vector2(w - 16, 8), Vector2(2, 8)])
	draw_colored_polygon(lip, Color(0.25, 0.22, 0.16, 0.41))
	draw_line(Vector2(11, 2), Vector2(w - 19, 2), Color(1.0, 0.82, 0.47, 0.67), 1.1, true)
	draw_line(Vector2(2, 10), Vector2(2, h - 9), Color(accent.r, accent.g, accent.b, 0.52), 1.2, true)
	draw_line(Vector2(9, h - 3), Vector2(w - 11, h - 3), Color(0.79, 0.59, 0.29, 0.50), 1.2, true)
	draw_line(Vector2(10, h - 6), Vector2(w - 12, h - 6), Color(0.0, 0.0, 0.0, 0.56), 1.0, true)
	# A small forged connector at each instrument edge carries the visual
	# rhythm across the resource and army rows without masking the values.
	for corner in [Vector2(5, 6), Vector2(w - 8, 6)]:
		var boss := PackedVector2Array([
			corner + Vector2(0, -4), corner + Vector2(4, 0),
			corner + Vector2(0, 4), corner + Vector2(-4, 0)])
		draw_colored_polygon(boss, Color(0.37, 0.29, 0.18, 0.99))
		boss.append(boss[0])
		draw_polyline(boss, Color(0.95, 0.72, 0.38, 0.88), 1.0, true)
		draw_circle(corner, 1.1, Color(0.039, 0.075, 0.09))
