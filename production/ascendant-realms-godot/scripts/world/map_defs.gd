class_name MapDefs
## Battlefield library for Ascendant Realms. Every map shares the same world
## bounds (±MAP_SIZE) so navigation, camera and minimap stay consistent, but
## each varies its layout, player count, resource economy, objectives and a
## visual THEME (biome colour grade + water) so the 24 battlefields feel and
## play distinctly. Assembled from compact specs by parameterised generators.

const MAP_SIZE := 140.0   # half-extent; world spans -140..140

const LUME := "res://assets/environment/structures/lume_spire_ruin.glb"
# The chapel is composed in CapturePoint (a ring of ruined pillars around an
# altar); it used to reuse the Lume Spire model, so two sites looked identical.
const RUIN := "composed:ruin_chapel"
# Vision sites were the gold-mine model, which read as a resource node.
const WATCH := "composed:highland_watch"
# The Spring of Seven Mouths (saga 1-1): seven stone spouts round a pool.
const SPRING := "composed:seven_mouths"
const GOLD_MINE := "res://assets/environment/rocks/gold_mine_lumevein.glb"
const BRIDGE := "res://assets/environment/structures/highland_crossing_bridge.glb"

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------
static func all() -> Array:
	var out := []
	for s in _specs():
		out.append(_assemble(s))
	return out

static func get_map(id: String) -> Dictionary:
	for s in _specs():
		if s["id"] == id:
			return _assemble(s)
	return _assemble(_specs()[0])

static func list_infos() -> Array:
	var out := []
	for s in _specs():
		out.append({"id": s["id"], "name": s["name"], "theme": s["theme"],
			"players": s.get("players", 4), "desc": _theme_blurb(s["theme"])})
	return out

## Back-compat: original default map.
static func hollowspan() -> Dictionary:
	return get_map("hollowspan")

# ---------------------------------------------------------------------------
# Specs — 24 battlefields
# ---------------------------------------------------------------------------
static func _specs() -> Array:
	return [
		{"id":"hollowspan","name":"Hollowspan Crossing","theme":"highland","layout":"corners","spread":100,"rich":1.0,"cap":"triple","bridge":true,"crags":"gates"},
		{"id":"ashen_vale","name":"Ashen Vale","theme":"ashen","layout":"corners","spread":96,"rich":0.9,"cap":"triple","crags":"walls"},
		{"id":"emberfall_rift","name":"Emberfall Rift","theme":"volcanic","layout":"edges","spread":110,"rich":1.0,"cap":"triple","crags":"corners"},
		{"id":"frostmere_basin","name":"Frostmere Basin","theme":"snow","layout":"corners","spread":102,"rich":1.0,"cap":"triple","bridge":true,"crags":"islands"},
		{"id":"dune_bastion","name":"Dune Sea Bastion","theme":"desert","layout":"edges","spread":114,"rich":0.9,"cap":"single"},
		{"id":"verdant_hollows","name":"Verdant Hollows","theme":"verdant","layout":"corners","spread":84,"rich":1.1,"cap":"triple","crags":"gates"},
		{"id":"autumn_reach","name":"Autumn Reach","theme":"autumn","layout":"corners","spread":106,"rich":1.0,"cap":"triple","crags":"walls"},
		{"id":"mirefen","name":"Mirefen Swamp","theme":"wetland","layout":"edges","spread":100,"rich":1.0,"cap":"triple","bridge":true,"crags":"corners"},
		{"id":"kaelmoor","name":"Kaelmoor Badlands","theme":"badlands","layout":"corners","spread":118,"rich":0.9,"cap":"triple","crags":"islands"},
		{"id":"sunspire_delta","name":"Sunspire Delta","theme":"tropical","layout":"corners","spread":96,"rich":1.1,"cap":"triple","bridge":true,"crags":"gates"},
		{"id":"highland_gauntlet","name":"Highland Gauntlet","theme":"highland","layout":"edges","spread":112,"rich":1.0,"cap":"single","crags":"pillars"},
		{"id":"glacier_pass","name":"Glacier Pass","theme":"snow","layout":"edges","spread":112,"rich":0.9,"cap":"triple","crags":"corners"},
		{"id":"scorched_expanse","name":"Scorched Expanse","theme":"volcanic","layout":"corners","spread":116,"rich":0.9,"cap":"single","crags":"walls"},
		{"id":"bloomvale","name":"Bloomvale Meadows","theme":"verdant","layout":"corners","spread":108,"rich":1.5,"cap":"triple"},
		{"id":"ruins_of_vael","name":"Ruins of Vael","theme":"ashen","layout":"corners","spread":100,"rich":1.0,"cap":"quad","crags":"gates"},
		{"id":"redsand_canyon","name":"Redsand Canyon","theme":"desert","layout":"corners","spread":100,"rich":1.0,"cap":"triple","crags":"walls"},
		{"id":"thornwild","name":"Thornwild Basin","theme":"autumn","layout":"corners","spread":88,"rich":1.0,"cap":"triple","crags":"islands"},
		{"id":"duskwater","name":"Duskwater Shore","theme":"wetland","layout":"corners","spread":100,"rich":1.0,"cap":"triple","bridge":true,"crags":"gates"},
		{"id":"cinderpeak","name":"Cinderpeak","theme":"volcanic","layout":"corners","spread":80,"rich":1.0,"cap":"single","crags":"walls"},
		{"id":"iron_tundra","name":"Iron Tundra","theme":"snow","layout":"corners","spread":118,"rich":0.9,"cap":"triple","crags":"islands"},
		{"id":"goldreach","name":"Goldreach Plateau","theme":"highland","layout":"corners","spread":104,"rich":1.5,"cap":"quad","crags":"gates"},
		{"id":"blightmarsh","name":"Blightmarsh","theme":"wetland","layout":"edges","spread":104,"rich":0.6,"cap":"single","crags":"pillars"},
		{"id":"emerald_isles","name":"Emerald Isles","theme":"tropical","layout":"corners","spread":116,"rich":1.0,"cap":"triple","bridge":true,"crags":"walls"},
		{"id":"crucible","name":"Warlord's Crucible","theme":"badlands","layout":"corners","spread":96,"rich":1.1,"cap":"quad","crags":"islands"},
		# Authored battlefields: laid out by hand, larger than the generated
		# ones, built round the place the saga gives them.
		{"id":"salto_valley","name":"Salto Valley","theme":"highland","authored":"salto"},
	]

# ---------------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------------
static func _assemble(s: Dictionary) -> Dictionary:
	if s.has("authored"):
		return _assemble_authored(s)
	var spread: float = float(s["spread"])
	var starts: Array = _corners(spread) if s["layout"] == "corners" else _edges(spread)
	var res := []
	for c in starts:
		res += _cluster(c, float(s["rich"]))
	res += _contested(float(s["rich"]))
	var m := {
		"id": s["id"],
		"name": s["name"],
		"theme": s["theme"],
		"size": MAP_SIZE,
		"max_players": s.get("players", 4),
		"start_positions": starts,
		"resources": res,
		"capture_points": _captures(s["cap"]),
		"veins": _veins(starts, float(s["rich"])),
	}
	var th := theme(s["theme"])
	m["water"] = th.get("water", {"enabled": false})
	# Presentation-only overview contract consumed by the HUD minimap. Keep it
	# alongside the authoritative map definition so the miniature describes the
	# same starts, crossing, and biome as the world without creating gameplay
	# geometry or a second simulation.
	m["overview"] = {
		"layout": s["layout"],
		"water_axis": "crossing" if s.get("bridge", false) else "north_bay",
		"water_center_z": 52.0 if s.get("bridge", false) else 118.0,
		"water_width": 22.0 if s.get("bridge", false) else 34.0,
		"roads": _overview_roads(starts, s["layout"]),
	}
	if s.get("bridge", false) and m["water"].get("enabled", false):
		m["bridge"] = {"pos": Vector3(0, 0, 52), "model": BRIDGE}
	if m["water"].get("enabled", false):
		m["veins"] = _veins_off_water(m["veins"], m["overview"])
	m["crags"] = _crags(String(s.get("crags", "")), m)
	return m

# ---------------------------------------------------------------------------
# Authored battlefields
# ---------------------------------------------------------------------------
## An authored map gives everything outright: its size, its starts, and every
## deposit, vein, site, ridge, wood and stretch of water. Ridges, woods and
## water all travel in "crags" (a "kind" tells them apart), so everything that
## already keeps clear of a crag (routes, orders, buildings, scenery) keeps
## clear of a wood or a river as well.
static func _assemble_authored(s: Dictionary) -> Dictionary:
	var a: Dictionary = _salto_valley()
	var size: float = float(a["size"])
	var starts: Array = a["starts"]
	var res: Array = []
	for c in starts:
		res += _cluster(c, 1.0)
	res += a["deposits"]
	# Rivers, woods and ridges are drawn with natural outlines and blocked by
	# many small rectangles laid along them.
	var crags: Array = []
	var rivers: Array = []
	var fords: Array = []
	for river in a["rivers"]:
		var samples := _smooth(river["points"], 4.0)
		rivers.append({"samples": samples, "width": float(river["width"])})
		var width: float = float(river["width"])
		for i in range(0, samples.size(), 2):
			var here: Vector2 = samples[i]
			var forded := false
			for ford in river["fords"]:
				if here.distance_to(ford["at"]) < float(ford["half"]):
					forded = true
			if not forded:
				crags.append({"pos": Vector3(here.x, 0.0, here.y), "half": Vector2(width * 0.5, width * 0.5), "kind": "water"})
		for ford in river["fords"]:
			# The way the river runs at the ford, from the samples either side.
			var nearest := 0
			for i in samples.size():
				if samples[i].distance_to(ford["at"]) < samples[nearest].distance_to(ford["at"]):
					nearest = i
			var ahead: Vector2 = samples[mini(nearest + 2, samples.size() - 1)] - samples[maxi(nearest - 2, 0)]
			fords.append({"pos": Vector3(ford["at"].x, 0.0, ford["at"].y), "half": float(ford["half"]), "width": width, "dir": ahead.normalized()})
	var woods: Array = []
	for wood in a["woods"]:
		woods.append(wood)
		crags.append_array(_wood_tiles(wood))
	# A tarn is shaped like a wood and filled with water.
	var lakes: Array = []
	for lake in a.get("lakes", []):
		lakes.append(lake)
		for tile in _wood_tiles(lake):
			tile["kind"] = "water"
			crags.append(tile)
	for ridge in a["ridges"]:
		var thickness: float = float(ridge["thickness"])
		var samples := _smooth(ridge["points"], thickness * 0.8)
		for point in samples:
			crags.append({"pos": Vector3(point.x, 0.0, point.y), "half": Vector2(thickness * 0.5, thickness * 0.5), "kind": "rock"})
	var th := theme(s["theme"])
	var m := {
		"id": s["id"],
		"name": s["name"],
		"theme": s["theme"],
		"size": size,
		"max_players": starts.size(),
		"start_positions": starts,
		"resources": res,
		"capture_points": a["sites"],
		"veins": a["veins"],
		"crags": crags,
		"rivers": rivers,
		"fords": fords,
		"woods": woods,
		"lakes": lakes,
		"roads": a["roads"],
		"authored": true,
	}
	m["water"] = th.get("water", {"enabled": false})
	var k := size / MAP_SIZE
	var overview_roads: Array = []
	for road in a["roads"]:
		overview_roads.append([Vector3(road.x, 0.0, road.y), Vector3(road.z, 0.0, road.w)])
	m["overview"] = {
		"layout": "corners",
		"water_axis": "north_bay",
		"water_center_z": 118.0 * k,
		"water_width": 34.0 * k,
		"roads": overview_roads,
	}
	return m

## A smooth line through `points` (Catmull-Rom), as points about `step` apart.
static func _smooth(points: Array, step: float) -> PackedVector2Array:
	var out: PackedVector2Array = []
	if points.size() < 2:
		return out
	for i in points.size() - 1:
		var p0: Vector2 = points[maxi(i - 1, 0)]
		var p1: Vector2 = points[i]
		var p2: Vector2 = points[i + 1]
		var p3: Vector2 = points[mini(i + 2, points.size() - 1)]
		var pieces := maxi(1, int(ceil(p1.distance_to(p2) / step)))
		for k in pieces:
			var t := float(k) / float(pieces)
			out.append(0.5 * ((2.0 * p1) + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t + (3.0 * p1 - p0 - 3.0 * p2 + p3) * t * t * t))
	out.append(points[points.size() - 1])
	return out

## How far a wood reaches from its middle in direction `angle`, as a share of
## its radii: an uneven edge, the same every time for the same wood.
static func wood_reach(wood: Dictionary, angle: float) -> float:
	var seed := float(wood.get("seed", 0.0))
	return 1.0 + 0.16 * sin(3.0 * angle + seed) + 0.09 * sin(7.0 * angle + seed * 2.3)

static func in_wood(wood: Dictionary, x: float, z: float) -> bool:
	var c: Vector2 = wood["at"]
	var r: Vector2 = wood["radii"]
	var d := Vector2((x - c.x) / r.x, (z - c.y) / r.y)
	return d.length() <= wood_reach(wood, d.angle())

## Rectangles that cover a wood: one for each run of 6 m cells inside it.
static func _wood_tiles(wood: Dictionary) -> Array:
	var out: Array = []
	var c: Vector2 = wood["at"]
	var r: Vector2 = wood["radii"]
	var cell := 6.0
	var reach := 1.3
	var z := c.y - r.y * reach
	while z <= c.y + r.y * reach:
		var run_start := INF
		var x := c.x - r.x * reach
		while x <= c.x + r.x * reach + cell:
			var inside := in_wood(wood, x, z) and x <= c.x + r.x * reach
			if inside and run_start == INF:
				run_start = x
			elif not inside and run_start != INF:
				var run_end := x - cell
				out.append({"pos": Vector3((run_start + run_end) * 0.5, 0.0, z), "half": Vector2((run_end - run_start) * 0.5 + cell * 0.5, cell * 0.5), "kind": "forest"})
				run_start = INF
			x += cell
		z += cell
	return out

## A feature and its twin on the far side of the centre (a half turn), so the
## two seats that face each other across the map have the same ground.
static func _twin_points(points: Array) -> Array:
	var out: Array = []
	for p in points:
		out.append(Vector2(-p.x, -p.y))
	return out

static func _pair_point(out: Array, kind: String, x: float, z: float) -> void:
	out.append({"kind": kind, "pos": Vector3(x, 0.0, z)})
	out.append({"kind": kind, "pos": Vector3(-x, 0.0, -z)})

## Salto Valley (saga 1-1, "The Spring of Seven Mouths"). 440 m across, two
## and a half times the ground of a generated map. The river runs through it
## in a long S and can be forded in three places: the Hollowspan shallows at
## the centre, where the Lume Spire stands, and a ford toward either end.
## Salto lies in the south-west behind the Wolf-Trap ridge, with a gate to the
## north and one to the east; the raiders' camp in the north-east mirrors it
## below the pass. The other two starts sit in open country beside the woods.
static func _salto_valley() -> Dictionary:
	var rivers: Array = [{
		"points": [Vector2(-232, 44), Vector2(-150, 34), Vector2(-96, 36), Vector2(-60, 15), Vector2(-22, 3), Vector2(0, 0),
			Vector2(22, -3), Vector2(60, -15), Vector2(96, -36), Vector2(150, -34), Vector2(232, -44)],
		"width": 15.0,
		"fords": [{"at": Vector2(-150, 34), "half": 11.0}, {"at": Vector2(0, 0), "half": 17.0}, {"at": Vector2(150, -34), "half": 11.0}],
	}]
	var ridges: Array = []
	for line in [
		# The Wolf-Trap ridge north of Salto, in two lengths with a gate between.
		[Vector2(-222, -100), Vector2(-190, -93), Vector2(-153, -99)],
		[Vector2(-129, -98), Vector2(-108, -92), Vector2(-87, -100)],
		# The spur east of the village.
		[Vector2(-99, -190), Vector2(-102, -160), Vector2(-95, -131)],
		# A bluff that narrows the way to the shallows.
		[Vector2(-56, -30), Vector2(-40, -24), Vector2(-26, -31)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 1.0
	for wood in [[-60, -72, 30, 22], [0, -150, 26, 32], [-122, 92, 26, 18], [100, -172, 15, 24]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.7
	# A tarn below the western ford, and its twin.
	var lakes: Array = [
		{"at": Vector2(-183, -22), "radii": Vector2(11, 8), "seed": 0.6},
		{"at": Vector2(183, 22), "radii": Vector2(11, 8), "seed": 0.6 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -141, -70)
	_pair_point(veins, "food", -70, -120)
	_pair_point(veins, "stone", -190, -50)
	_pair_point(veins, "timber", -40, -190)
	_pair_point(veins, "gold", -160, 80)
	_pair_point(veins, "food", -70, 150)
	_pair_point(veins, "stone", -200, 100)
	_pair_point(veins, "timber", -60, 100)
	_pair_point(veins, "gold", -24, 40)
	var deposits: Array = []
	_pair_point(deposits, "gold", -30, 60)
	_pair_point(deposits, "stone", -110, -10)
	_pair_point(deposits, "timber", -185, 5)
	_pair_point(deposits, "food", -20, -90)
	var sites: Array = [
		{"name": "Hollowspan Spire", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "Spring of Seven Mouths", "benefit": "heal", "pos": Vector3(-120, 0, -40), "model": SPRING},
		{"name": "Chapel of the Pass", "benefit": "heal", "pos": Vector3(120, 0, 40), "model": RUIN},
		{"name": "Larouco Watch", "benefit": "vision", "pos": Vector3(-50, 0, 120), "model": WATCH},
		{"name": "Salto Watch", "benefit": "vision", "pos": Vector3(50, 0, -120), "model": WATCH},
	]
	# Worn roads (at most eight): each walled start to its gate, the gates to
	# the fords and to the shallows, the fords on to the open-country starts.
	var roads: Array = [
		Vector4(-160, -150, -141, -90), Vector4(-141, -90, -150, 34), Vector4(-150, 34, -160, 150), Vector4(-141, -90, 0, 0),
		Vector4(160, 150, 141, 90), Vector4(141, 90, 150, -34), Vector4(150, -34, 160, -150), Vector4(141, 90, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(160, 0, -150), Vector3(-160, 0, 150)],
		"rivers": rivers, "ridges": ridges, "woods": woods, "lakes": lakes,
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

# ---------------------------------------------------------------------------
# Crags: impassable rock ridges that give a battlefield lanes, gates and flanks
# ---------------------------------------------------------------------------
## Each style is an ordered list of groups: [fold, Vector4(x, z, half_x, half_z)].
## Fold 2 adds the twin on the far side of the centre; fold 4 adds the mirrors
## and the x/z swap as well. A group is used only if every copy keeps clear of
## the starts, resources, veins, objectives, water and the map edge, so a
## layout can never wall in an economy, and both sides of the field match.
const CRAG_STYLES := {
	"gates": [[2, Vector4(-38, -38, 7, 7)], [4, Vector4(0, -66, 14, 4)], [4, Vector4(0, -102, 4, 12)]],
	"walls": [[4, Vector4(0, -60, 16, 4)], [4, Vector4(0, -96, 4, 14)], [2, Vector4(-34, -34, 5, 5)]],
	"islands": [[2, Vector4(-40, -40, 6, 6)], [2, Vector4(-58, -18, 5, 8)], [2, Vector4(-18, -58, 8, 5)], [4, Vector4(0, -84, 10, 5)]],
	"corners": [[4, Vector4(62, -62, 8, 8)], [2, Vector4(-38, -38, 6, 6)], [4, Vector4(92, -92, 10, 10)]],
	"pillars": [[4, Vector4(60, -60, 6, 6)], [4, Vector4(84, -84, 6, 6)], [2, Vector4(-36, -36, 5, 5)]],
}

static func _crags(style: String, m: Dictionary) -> Array:
	var out: Array = []
	for group in CRAG_STYLES.get(style, []):
		var copies := _crag_copies(group[1], int(group[0]))
		if _crags_clear(copies, m):
			out.append_array(copies)
	return out

static func _crag_copies(r: Vector4, fold: int) -> Array:
	var all: Array = [r, Vector4(-r.x, -r.y, r.z, r.w)]
	if fold >= 4:
		all.append_array([Vector4(-r.x, r.y, r.z, r.w), Vector4(r.x, -r.y, r.z, r.w),
			Vector4(r.y, r.x, r.w, r.z), Vector4(-r.y, -r.x, r.w, r.z),
			Vector4(-r.y, r.x, r.w, r.z), Vector4(r.y, -r.x, r.w, r.z)])
	var out: Array = []
	var seen := {}
	for c in all:
		var key := "%d,%d,%d,%d" % [roundi(c.x), roundi(c.y), roundi(c.z), roundi(c.w)]
		if seen.has(key):
			continue
		seen[key] = true
		out.append({"pos": Vector3(c.x, 0.0, c.y), "half": Vector2(c.z, c.w)})
	return out

static func _crags_clear(copies: Array, m: Dictionary) -> bool:
	var keep: Array = []   # [position, clear distance]
	for p in m.get("start_positions", []):
		keep.append([p, 46.0])
	for r in m.get("resources", []):
		keep.append([r["pos"], 9.0])
	for v in m.get("veins", []):
		keep.append([v["pos"], 12.0])
	for c in m.get("capture_points", []):
		keep.append([c["pos"], 15.0])
	var water: bool = bool(m.get("water", {}).get("enabled", false))
	var ov: Dictionary = m.get("overview", {})
	for c in copies:
		var p: Vector3 = c["pos"]
		var h: Vector2 = c["half"]
		if absf(p.x) + h.x > MAP_SIZE - 14.0 or absf(p.z) + h.y > MAP_SIZE - 14.0:
			return false
		if water:
			if m.has("bridge"):
				if absf(p.z - float(ov.get("water_center_z", 52.0))) < h.y + 15.0:
					return false
			elif p.z + h.y > float(ov.get("water_center_z", 118.0)) - float(ov.get("water_width", 34.0)) * 0.5 - 6.0:
				return false
		for k in keep:
			var q: Vector3 = k[0]
			var dx := maxf(absf(q.x - p.x) - h.x, 0.0)
			var dz := maxf(absf(q.z - p.z) - h.y, 0.0)
			if Vector2(dx, dz).length() < float(k[1]):
				return false
	return true

## Keep veins on dry ground: a vein in the river or the bay could never hold
## an outpost. Crossing rivers push them to the nearer bank; the bay pushes
## them south onto the shore.
static func _veins_off_water(veins: Array, ov: Dictionary) -> Array:
	var wz := float(ov.get("water_center_z", 52.0))
	var ww := float(ov.get("water_width", 22.0))
	for v in veins:
		var p: Vector3 = v["pos"]
		if str(ov.get("water_axis", "")) == "crossing":
			var edge := ww * 0.5 + 9.0
			if absf(p.z - wz) < edge:
				p.z = wz - edge if p.z < wz else wz + edge
		else:
			# The bay is the northern shore strip beyond wz - ww/2.
			p.z = minf(p.z, wz - ww * 0.5 - 9.0)
		v["pos"] = p
	return veins

static func _overview_roads(starts: Array, layout: String) -> Array:
	# Presentation-only polylines derived from the same starts used by the
	# terrain shader. They add readable bends to the miniature without adding
	# gameplay geometry or changing navigation.
	var roads: Array = []
	for start in starts:
		var planar := Vector2(start.x, start.z)
		var side := Vector2(-planar.y, planar.x).normalized()
		var bend := Vector3(side.x * 11.0, 0.0, side.y * 11.0)
		roads.append([start, start.lerp(Vector3.ZERO, 0.52) + bend, Vector3.ZERO])
	if layout == "corners":
		roads.append([Vector3(-30, 0, -20), Vector3.ZERO, Vector3(30, 0, 20)])
	else:
		roads.append([Vector3(-30, 0, 0), Vector3.ZERO, Vector3(30, 0, 0)])
	return roads

static func _corners(sp: float) -> Array:
	return [Vector3(-sp, 0, -sp), Vector3(sp, 0, sp), Vector3(sp, 0, -sp), Vector3(-sp, 0, sp)]

static func _edges(sp: float) -> Array:
	return [Vector3(0, 0, -sp), Vector3(0, 0, sp), Vector3(-sp, 0, 0), Vector3(sp, 0, 0)]

static func _cluster(c: Vector3, rich: float) -> Array:
	var toward := Vector3.ZERO - c
	toward.y = 0.0
	toward = toward.normalized()
	var side := Vector3(-toward.z, 0, toward.x)
	var out := [
		# Every starting cluster exposes a nearby food node so the four-resource
		# economy is playable from any real worker start, not only at the
		# contested centre of the map.
		{"kind": "food", "pos": c + toward * 3.0 - side * 15.0},
		{"kind": "gold", "pos": c + toward * 13.0 + side * 7.0},
		{"kind": "gold", "pos": c + toward * 13.0 - side * 7.0},
		{"kind": "stone", "pos": c + toward * 3.0 + side * 15.0},
		{"kind": "timber", "pos": c - toward * 2.0 + side * 11.0},
		{"kind": "timber", "pos": c - toward * 2.0 - side * 11.0},
	]
	if rich >= 1.4:
		out.append({"kind": "gold", "pos": c + toward * 22.0})
		out.append({"kind": "stone", "pos": c - side * 15.0})
	elif rich <= 0.7:
		# Preserve the minimum food spawn from the standard cluster contract;
		# scarcity removes one timber node, not the only food source.
		out.remove_at(4)
	return out

## Veins between the bases (docs/claude/RESOURCE_DESIGN.md): each start gets a
## gold vein and a terraced farm about halfway to the centre, and a granite
## quarry and a grove further out on its flanks. Rich maps add two central veins.
static func _veins(starts: Array, rich: float) -> Array:
	var out := []
	for c in starts:
		var toward: Vector3 = (Vector3.ZERO - c)
		toward.y = 0.0
		var dist := toward.length()
		toward = toward.normalized()
		var side := Vector3(-toward.z, 0, toward.x)
		out.append({"kind": "gold", "pos": c + toward * dist * 0.42 + side * 20.0})
		out.append({"kind": "food", "pos": c + toward * dist * 0.42 - side * 20.0})
		out.append({"kind": "stone", "pos": c + toward * dist * 0.3 + side * 36.0})
		out.append({"kind": "timber", "pos": c + toward * dist * 0.3 - side * 36.0})
	if rich >= 1.4:
		out.append({"kind": "gold", "pos": Vector3(14, 0, -40)})
		out.append({"kind": "gold", "pos": Vector3(-14, 0, 40)})
	return out

static func _contested(rich: float) -> Array:
	# Every contested node has a twin on the far side of the centre, so no
	# seat has the middle's stone or food nearer than its rival. (There was
	# one stone node, to the north, and one food node, to the south: the
	# southern seats had the food that every soldier costs on their doorstep.)
	var out := [
		{"kind": "gold", "pos": Vector3(-26, 0, -16)},
		{"kind": "gold", "pos": Vector3(26, 0, 16)},
		{"kind": "stone", "pos": Vector3(0, 0, -34)},
		{"kind": "timber", "pos": Vector3(-20, 0, 30)},
		{"kind": "timber", "pos": Vector3(20, 0, -30)},
		{"kind": "food", "pos": Vector3(-34, 0, 0)},
		{"kind": "stone", "pos": Vector3(0, 0, 34)},
		{"kind": "food", "pos": Vector3(34, 0, 0)},
	]
	if rich >= 1.4:
		out.append({"kind": "gold", "pos": Vector3(-46, 0, 8)})
		out.append({"kind": "gold", "pos": Vector3(46, 0, -8)})
	elif rich <= 0.7:
		return [out[0], out[1], out[2], out[6]]
	return out

static func _captures(style: String) -> Array:
	var lume := {"name": "Lume Spire", "benefit": "income", "pos": Vector3.ZERO, "model": LUME}
	match style:
		"single":
			return [lume]
		"quad":
			return [lume,
				{"name": "North Watch", "benefit": "vision", "pos": Vector3(0, 0, -48), "model": WATCH},
				{"name": "South Chapel", "benefit": "heal", "pos": Vector3(0, 0, 48), "model": RUIN},
				{"name": "West Vein", "benefit": "income", "pos": Vector3(-52, 0, 4), "model": GOLD_MINE}]
		_:  # triple
			return [lume,
				{"name": "Highland Watch", "benefit": "vision", "pos": Vector3(-42, 0, 40), "model": WATCH},
				{"name": "Ruin Chapel", "benefit": "heal", "pos": Vector3(42, 0, -40), "model": RUIN}]

# ---------------------------------------------------------------------------
# Themes — biome colour grade + atmosphere + water, all from existing textures
# ---------------------------------------------------------------------------
static func theme(name: String) -> Dictionary:
	var T := {
		"highland": {
			"ground_tint": Color(1.0, 1.0, 1.0), "dirt_bias": 0.0, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.72, 0.72, 0.70),
			# Golden-hour highland grade: warm low sun against a cool sky fill, a
			# warm aerial haze for depth, and contact shadows to ground the kit.
			"fog_color": Color(0.80, 0.76, 0.68), "fog_density": 0.0011,
			"fog_aerial_perspective": 0.45, "fog_sun_scatter": 0.18,
			"sun_color": Color(1.0, 0.89, 0.74), "sun_energy": 1.4, "ambient_energy": 0.46,
			"sun_pitch": -38.0, "sun_yaw": 34.0,
			"ambient_color": Color(0.46, 0.54, 0.66), "ambient_sky_contribution": 0.55,
			"ssao": true, "glow": true,
			"grade_contrast": 1.08, "grade_saturation": 0.98, "grade_brightness": 1.0,
			"decor_density": 1.0,
			"water": {"enabled": true, "deep": Color(0.05, 0.22, 0.34), "shallow": Color(0.16, 0.48, 0.58), "foam": Color(0.86, 0.95, 1.0)},
		},
		"verdant": {
			"ground_tint": Color(0.82, 1.05, 0.78), "dirt_bias": -0.05, "rock_bias": -0.05, "snow": 0.0,
			"rock_tint": Color(0.58, 0.66, 0.5),
			"fog_color": Color(0.66, 0.8, 0.62), "fog_density": 0.00099,
			"sun_color": Color(1.0, 0.98, 0.86), "sun_energy": 1.2, "ambient_energy": 0.65,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -40.0,
			"grade_contrast": 1.07, "grade_saturation": 0.86, "grade_brightness": 1.0,
			"decor_density": 1.35,
			"water": {"enabled": true, "deep": Color(0.06, 0.3, 0.32), "shallow": Color(0.2, 0.55, 0.5), "foam": Color(0.9, 0.98, 0.95)},
		},
		"autumn": {
			"ground_tint": Color(1.18, 0.92, 0.58), "dirt_bias": 0.15, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.7, 0.6, 0.48),
			"fog_color": Color(0.85, 0.72, 0.5), "fog_density": 0.00099,
			"sun_color": Color(1.0, 0.88, 0.66), "sun_energy": 1.15, "ambient_energy": 0.6,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -38.0,
			"grade_contrast": 1.08, "grade_saturation": 0.9, "grade_brightness": 1.0,
			"decor_density": 1.15,
			"water": {"enabled": true, "deep": Color(0.1, 0.22, 0.28), "shallow": Color(0.24, 0.44, 0.46), "foam": Color(0.92, 0.9, 0.8)},
		},
		"desert": {
			"ground_tint": Color(1.28, 1.06, 0.7), "dirt_bias": 0.5, "rock_bias": 0.12, "snow": 0.0,
			"rock_tint": Color(0.85, 0.68, 0.45),
			"fog_color": Color(0.92, 0.84, 0.62), "fog_density": 0.00066,
			"sun_color": Color(1.0, 0.95, 0.78), "sun_energy": 1.35, "ambient_energy": 0.7,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -44.0,
			"grade_contrast": 1.07, "grade_saturation": 0.96, "grade_brightness": 1.0,
			"decor_density": 0.4,
			"water": {"enabled": false},
		},
		"badlands": {
			"ground_tint": Color(1.12, 0.86, 0.66), "dirt_bias": 0.32, "rock_bias": 0.35, "snow": 0.0,
			"rock_tint": Color(0.78, 0.55, 0.42),
			"fog_color": Color(0.82, 0.7, 0.56), "fog_density": 0.00088,
			"sun_color": Color(1.0, 0.9, 0.74), "sun_energy": 1.2, "ambient_energy": 0.6,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -40.0,
			"grade_contrast": 1.08, "grade_saturation": 0.98, "grade_brightness": 1.0,
			"decor_density": 0.5,
			"water": {"enabled": false},
		},
		"volcanic": {
			# Presentation-only contrast grade: retain volcanic warmth while
			# separating terrain, structures, units, and resource silhouettes.
			"ground_tint": Color(1.25, 1.23, 1.24), "dirt_bias": 0.08, "rock_bias": 0.28, "snow": 0.0,
			"rock_tint": Color(0.38, 0.34, 0.34),
			"fog_color": Color(0.44, 0.34, 0.34), "fog_density": 0.00094,
			"sun_color": Color(1.0, 0.78, 0.66), "sun_energy": 1.05, "ambient_energy": 0.55,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -46.0,
			"grade_contrast": 1.1, "grade_saturation": 1, "grade_brightness": 1.0,
			"decor_density": 0.4,
			"water": {"enabled": true, "lava": true, "deep": Color(0.5, 0.12, 0.03), "shallow": Color(1.0, 0.5, 0.12), "foam": Color(1.0, 0.85, 0.4)},
		},
		"snow": {
			"ground_tint": Color(0.9, 0.95, 1.05), "dirt_bias": -0.05, "rock_bias": 0.1, "snow": 0.86,
			"rock_tint": Color(0.7, 0.74, 0.8),
			"fog_color": Color(0.79, 0.85, 0.93), "fog_density": 0.00080,
			"sun_color": Color(0.9, 0.94, 1.0), "sun_energy": 1.02, "ambient_energy": 0.58,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -36.0,
			"grade_contrast": 1.06, "grade_saturation": 0.95, "grade_brightness": 1.0,
			"decor_density": 0.6,
			"water": {"enabled": true, "deep": Color(0.12, 0.3, 0.4), "shallow": Color(0.4, 0.62, 0.72), "foam": Color(0.95, 0.98, 1.0)},
		},
		"wetland": {
			"ground_tint": Color(0.82, 0.92, 0.74), "dirt_bias": 0.22, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.55, 0.6, 0.48),
			"fog_color": Color(0.62, 0.72, 0.6), "fog_density": 0.00143,
			"sun_color": Color(0.94, 0.96, 0.82), "sun_energy": 1.05, "ambient_energy": 0.6,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -40.0,
			"grade_contrast": 1.08, "grade_saturation": 0.98, "grade_brightness": 1.0,
			"decor_density": 1.2,
			"water": {"enabled": true, "deep": Color(0.1, 0.2, 0.14), "shallow": Color(0.22, 0.36, 0.24), "foam": Color(0.7, 0.78, 0.6)},
		},
		"tropical": {
			"ground_tint": Color(0.9, 1.05, 0.82), "dirt_bias": 0.0, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.6, 0.64, 0.52),
			"fog_color": Color(0.7, 0.85, 0.85), "fog_density": 0.00077,
			"sun_color": Color(1.0, 0.98, 0.9), "sun_energy": 1.25, "ambient_energy": 0.7,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -42.0,
			"grade_contrast": 1.07, "grade_saturation": 0.92, "grade_brightness": 1.0,
			"decor_density": 1.3,
			"water": {"enabled": true, "deep": Color(0.05, 0.42, 0.5), "shallow": Color(0.16, 0.72, 0.72), "foam": Color(0.9, 1.0, 1.0)},
		},
		"ashen": {
			"ground_tint": Color(0.84, 0.84, 0.88), "dirt_bias": 0.2, "rock_bias": 0.22, "snow": 0.0,
			"rock_tint": Color(0.55, 0.55, 0.58),
			"fog_color": Color(0.55, 0.56, 0.61), "fog_density": 0.00074,
			"sun_color": Color(0.88, 0.86, 0.86), "sun_energy": 0.96, "ambient_energy": 0.48,
			"fog_aerial_perspective": 0.35, "ssao": true, "glow": true, "sun_pitch": -44.0,
			"grade_contrast": 1.08, "grade_saturation": 0.95, "grade_brightness": 1.0,
			"decor_density": 0.7,
			"water": {"enabled": false},
		},
	}
	return T.get(name, T["highland"])

static func _theme_blurb(t: String) -> String:
	match t:
		"highland": return "Misty green highlands"
		"verdant": return "Lush sacred groves"
		"autumn": return "Golden autumn woods"
		"desert": return "Scorching dune sea"
		"badlands": return "Cracked red badlands"
		"volcanic": return "Molten volcanic rift"
		"snow": return "Frozen snowfields"
		"wetland": return "Foggy marsh & water"
		"tropical": return "Turquoise island shores"
		"ashen": return "Grey ruined wastes"
	return ""
