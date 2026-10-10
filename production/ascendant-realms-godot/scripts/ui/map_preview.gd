extends Control
class_name MapPreview
## Tactical parchment preview of a battlefield drawn from MapDefs data:
## ground, water, roads, resource sites, shrines and start positions.
## Presentation-only; it reads the map definition and changes nothing.

const KIND_COLORS := {
	"gold": Color(0.95, 0.76, 0.28),
	"stone": Color(0.72, 0.74, 0.76),
	"timber": Color(0.45, 0.62, 0.30),
	"food": Color(0.86, 0.52, 0.34),
}
const THEME_GROUND := {
	"highland": Color(0.30, 0.36, 0.22),
	"verdant": Color(0.26, 0.40, 0.20),
	"ashen": Color(0.30, 0.28, 0.26),
	"volcanic": Color(0.32, 0.20, 0.16),
	"snow": Color(0.62, 0.66, 0.70),
	"desert": Color(0.62, 0.50, 0.32),
	"autumn": Color(0.46, 0.32, 0.18),
	"wetland": Color(0.22, 0.32, 0.26),
}

var map_data := {}
var player_color := Color(0.95, 0.80, 0.40)
var opponent_colors: Array = [Color(0.85, 0.28, 0.24)]
var mystery := false


func show_map(data: Dictionary, p_color: Color, opp_colors: Array) -> void:
	map_data = data
	player_color = p_color
	opponent_colors = opp_colors
	mystery = data.is_empty()
	queue_redraw()


func _draw() -> void:
	var side := minf(size.x, size.y)
	var origin := (size - Vector2(side, side)) * 0.5
	var rect := Rect2(origin, Vector2(side, side))
	var frame := Color(0.78, 0.62, 0.34)
	if mystery:
		draw_rect(rect, Color(0.10, 0.09, 0.08))
		var font := get_theme_default_font()
		var text := "?"
		var fs := int(side * 0.4)
		var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
		draw_string(font, rect.get_center() + Vector2(-tw.x * 0.5, fs * 0.35), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(0.78, 0.62, 0.34, 0.8))
		draw_rect(rect, frame, false, 2.0)
		return
	var half := float(map_data.get("size", 140.0))
	var to_px := func(p: Vector3) -> Vector2:
		return origin + Vector2((p.x + half) / (half * 2.0), (p.z + half) / (half * 2.0)) * side
	var ground: Color = THEME_GROUND.get(str(map_data.get("theme", "highland")), Color(0.3, 0.34, 0.24))
	draw_rect(rect, ground)
	# Soft vignette toward the edges so the field reads as a parchment survey.
	for i in 6:
		var inset := side * 0.02 * i
		draw_rect(Rect2(rect.position + Vector2(inset, inset), rect.size - Vector2(inset, inset) * 2.0), Color(0, 0, 0, 0.05), false, side * 0.02)
	var overview: Dictionary = map_data.get("overview", {})
	# A hand-built battlefield is drawn from its own terrain: its roads, then
	# hills, woods, water, rock and built walls from the tiles that block the
	# ground, the shallows of each ford, and the bridges. (It has none of the
	# generated maps' roads or edge water, which were drawn here before.)
	var authored := bool(map_data.get("authored", false))
	var theme_name := str(map_data.get("theme", "highland"))
	var tints := {"hill": ground.lightened(0.16), "forest": Color(0.11, 0.24, 0.11), "water": Color(0.16, 0.40, 0.58), "rock": Color(0.33, 0.31, 0.29), "masonry": Color(0.76, 0.74, 0.70)}
	match theme_name:
		"volcanic":
			tints["water"] = Color(0.92, 0.42, 0.10)
			tints["forest"] = Color(0.20, 0.15, 0.12)
			tints["rock"] = Color(0.22, 0.14, 0.12)
			tints["hill"] = Color(0.24, 0.16, 0.14)
		"ashen":
			tints["forest"] = Color(0.21, 0.19, 0.20)
			tints["hill"] = Color(0.22, 0.21, 0.24)
		"snow":
			tints["forest"] = Color(0.26, 0.38, 0.36)
			tints["rock"] = Color(0.40, 0.42, 0.50)
			tints["hill"] = Color(0.95, 0.96, 1.0)
		"desert", "badlands":
			tints["rock"] = Color(0.52, 0.40, 0.28)
			tints["hill"] = Color(0.86, 0.72, 0.50)
			tints["forest"] = Color(0.36, 0.34, 0.18)
	var draw_tiles := func() -> void:
		# Each blocking tile is drawn as a disc a little wider than itself, so
		# a run of tiles reads as one smooth wood, river or wall and not as a
		# staircase of squares. Rock, walls and woods get a dark edge first,
		# which lifts them off the ground. (A river or a wall may run on past
		# the edge of the field: tiles at the frame stay square, clipped.)
		for kind in ["hill", "forest", "water", "rock", "masonry"]:
			for pass_index in 2:
				if pass_index == 0 and kind in ["hill", "water"]:
					continue
				for crag in map_data.get("crags", []):
					if String(crag.get("kind", "rock")) != kind:
						continue
					var tile_pos: Vector3 = crag["pos"]
					var tile_half: Vector2 = crag["half"]
					var centre: Vector2 = to_px.call(tile_pos)
					var radius: float = maxf(tile_half.x, tile_half.y) / (half * 2.0) * side * 1.22
					var tint: Color = tints[kind]
					if pass_index == 0:
						tint = Color(tint.darkened(0.55), 0.9)
						radius += maxf(1.0, side * 0.004)
					if rect.grow(-radius).has_point(centre):
						draw_circle(centre, radius, tint)
					elif pass_index == 1:
						var corner_a: Vector2 = to_px.call(tile_pos - Vector3(tile_half.x, 0, tile_half.y))
						var corner_b: Vector2 = to_px.call(tile_pos + Vector3(tile_half.x, 0, tile_half.y))
						var tile_rect := Rect2(corner_a, corner_b - corner_a).intersection(rect)
						if tile_rect.size.x > 0.0 and tile_rect.size.y > 0.0:
							draw_rect(tile_rect, tint)
	if authored:
		overview = {}
		for road in map_data.get("roads", []):
			draw_line(to_px.call(Vector3(road.x, 0, road.y)), to_px.call(Vector3(road.z, 0, road.w)), Color(0.62, 0.50, 0.34, 0.85), maxf(2.0, side * 0.010), true)
		draw_tiles.call()
		for ford in map_data.get("fords", []):
			var ford_at: Vector2 = to_px.call(ford["pos"])
			var ford_r: float = float(ford["half"]) / (half * 2.0) * side
			draw_circle(ford_at, maxf(2.5, ford_r * 0.8), Color(0.62, 0.72, 0.62) if theme_name != "volcanic" else Color(0.30, 0.20, 0.17))
		var turned := bool(map_data.get("bridges_turned", false))
		for bridge_pos in map_data.get("bridges", []):
			var deck := Vector3(13.0, 0, 4.3) if turned else Vector3(4.3, 0, 13.0)
			var deck_a: Vector2 = to_px.call(bridge_pos - deck)
			var deck_b: Vector2 = to_px.call(bridge_pos + deck)
			draw_rect(Rect2(deck_a, deck_b - deck_a), Color(0.70, 0.68, 0.64))
	if not authored and map_data.get("water", {}).get("enabled", false) and not overview.is_empty():
		var wz := float(overview.get("water_center_z", 52.0))
		var ww := float(overview.get("water_width", 22.0))
		var water := Color(0.16, 0.34, 0.44)
		if str(overview.get("water_axis", "")) == "crossing":
			var a: Vector2 = to_px.call(Vector3(-half, 0, wz - ww * 0.5))
			var b: Vector2 = to_px.call(Vector3(half, 0, wz + ww * 0.5))
			draw_rect(Rect2(a, b - a), water)
			if map_data.has("bridge"):
				var bp: Vector2 = to_px.call(map_data["bridge"]["pos"])
				draw_rect(Rect2(bp - Vector2(side * 0.025, (b.y - a.y) * 0.6), Vector2(side * 0.05, (b.y - a.y) * 1.2)), Color(0.46, 0.34, 0.22))
		else:
			# (Clipped to the frame: on Autumn Reach the bay hung out of the
			# bottom of the map, over the border.)
			var bay_at: Vector2 = to_px.call(Vector3(0, 0, wz))
			var bay_r: float = ww / (half * 2.0) * side * 1.4
			var bay := PackedVector2Array()
			for step in 40:
				bay.append(bay_at + Vector2(cos(TAU * step / 40.0), sin(TAU * step / 40.0)) * bay_r)
			var frame_poly := PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0), rect.end, rect.position + Vector2(0, rect.size.y)])
			for piece in Geometry2D.intersect_polygons(bay, frame_poly):
				draw_colored_polygon(piece, water)
	for road in overview.get("roads", []):
		var pts := PackedVector2Array()
		for p in road:
			pts.append(to_px.call(p))
		draw_polyline(pts, Color(0.62, 0.50, 0.34, 0.85), maxf(2.0, side * 0.012), true)
	# The older maps have rock ridges too (since 2026-10-01), and the preview
	# never showed them: the walls a player would have to march round.
	if not authored:
		draw_tiles.call()
	for r in map_data.get("resources", []):
		var c: Color = KIND_COLORS.get(str(r.get("kind", "")), Color.WHITE)
		draw_circle(to_px.call(r["pos"]), maxf(2.5, side * 0.011), c)
	# Veins: a dark-edged dot in the resource's colour, where outposts can rise.
	for v in map_data.get("veins", []):
		var vp: Vector2 = to_px.call(v["pos"])
		var vc: Color = KIND_COLORS.get(str(v.get("kind", "")), Color.WHITE)
		var vr := maxf(4.0, side * 0.02)
		# A small ringed pip: big rings crowded the preview.
		draw_circle(vp, vr * 0.55, Color(0.02, 0.02, 0.03, 0.8))
		draw_circle(vp, vr * 0.38, vc)
	for cp in map_data.get("capture_points", []):
		var p: Vector2 = to_px.call(cp["pos"])
		var s := side * 0.022
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s), p + Vector2(s, 0), p + Vector2(0, s), p + Vector2(-s, 0)]), Color(0.70, 0.56, 0.95))
	var starts: Array = map_data.get("start_positions", [])
	for i in starts.size():
		var col: Color = player_color if i == 0 else (opponent_colors[i - 1] if i - 1 < opponent_colors.size() else Color(0.35, 0.33, 0.30))
		_draw_banner(to_px.call(starts[i]), side * 0.045, col, i == 0)
	draw_rect(rect, frame, false, 2.0)
	draw_rect(Rect2(rect.position + Vector2(5, 5), rect.size - Vector2(10, 10)), Color(frame, 0.35), false, 1.0)


func _draw_banner(p: Vector2, s: float, col: Color, is_player: bool) -> void:
	# A heater-shield marker; the player's is ringed in gold.
	var pts := PackedVector2Array([p + Vector2(-s, -s), p + Vector2(s, -s), p + Vector2(s, s * 0.2), p + Vector2(0, s * 1.2), p + Vector2(-s, s * 0.2)])
	draw_colored_polygon(pts, Color(0.05, 0.05, 0.05, 0.6))
	var inner := PackedVector2Array()
	for q in pts:
		inner.append(p + (q - p) * 0.78)
	draw_colored_polygon(inner, col)
	pts.append(pts[0])
	draw_polyline(pts, Color(1.0, 0.86, 0.50) if is_player else Color(0.12, 0.1, 0.08), 2.0 if is_player else 1.0, true)
