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
		# A saga chapter's return to an earlier field (the same ground in another
		# season, or with the enemy seated elsewhere) is not offered again as a
		# battlefield of its own in skirmish or on the Endless Road.
		if bool(s.get("saga", false)):
			continue
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
		{"id":"rabagao_gorge","name":"Rabagao Gorge","theme":"autumn","authored":"gorge"},
		{"id":"salto_lower_quarter","name":"Salto, the Lower Quarter","theme":"highland","authored":"quarter"},
		{"id":"garrano_pass","name":"Garrano Pass","theme":"highland","authored":"pass"},
		{"id":"ashfen_mire","name":"Ashfen Mire","theme":"wetland","authored":"mire"},
		{"id":"tourem_crossing","name":"Tourem Crossing","theme":"highland","authored":"tourem"},
		{"id":"malrecs_pyre","name":"Malrec's Pyre","theme":"volcanic","authored":"pyre"},
		{"id":"seven_fountains","name":"Grove of Seven Fountains","theme":"verdant","authored":"grove"},
		{"id":"bread_fountain","name":"The Bread Fountain","theme":"verdant","authored":"fountain"},
		{"id":"furna_reservoir","name":"Furna Below the Water","theme":"wetland","authored":"furna"},
		{"id":"envoys_field","name":"The Envoy's Field","theme":"highland","authored":"envoy"},
		{"id":"boticas","name":"Boticas","theme":"ashen","authored":"boticas"},
		{"id":"larouco_road","name":"The Larouco Road","theme":"snow","authored":"larouco"},
		{"id":"castro_carvalhelhos","name":"The Castro of Carvalhelhos","theme":"snow","authored":"castro"},
		{"id":"candle_road","name":"The Candle Road","theme":"wetland","authored":"candle"},
		{"id":"leonors_cross","name":"Leonor's Cross","theme":"ashen","authored":"cross"},
		{"id":"four_peaks","name":"The Four Peaks of the Larouco","theme":"snow","authored":"peaks"},
		{"id":"geira_road","name":"The Geira Road","theme":"highland","authored":"geira"},
		{"id":"ironmaw_mines","name":"The Lume-Iron Mines","theme":"volcanic","authored":"mines"},
		{"id":"plains_of_bronze","name":"The Plains Before the Wall","theme":"desert","authored":"plains"},
		{"id":"glass_heart","name":"The Glass Heart","theme":"volcanic","authored":"heart"},
		{"id":"regents_canyon","name":"The Regent's Canyons","theme":"badlands","authored":"canyon"},
		{"id":"rabagao_wall","name":"The Rabagao Wall","theme":"highland","authored":"wall"},
		# Act five returns to four places the saga has been, changed.
		{"id":"burning_geira","name":"The Burning Geira","theme":"volcanic","authored":"geira","saga":true},
		{"id":"last_spring","name":"The Last Spring","theme":"autumn","authored":"grove","saga":true},
		{"id":"furna_in_ashes","name":"Furna in Ashes","theme":"ashen","authored":"furna","saga":true},
		{"id":"salto_ascendant","name":"Salto, the Ascension","theme":"ashen","authored":"salto","saga":true},
		{"id":"montalto","name":"Montalto","theme":"highland","authored":"montalto"},
		# The side roads.
		{"id":"fojo","name":"The Wolf-Trap Walls","theme":"highland","authored":"fojo"},
		{"id":"fojo_in_winter","name":"The Fojo in Winter","theme":"snow","authored":"fojo","saga":true},
		{"id":"junias","name":"The Monastery of the Junias","theme":"verdant","authored":"junias"},
		{"id":"castro_lesenho","name":"The Castro of Lesenho","theme":"highland","authored":"castro","saga":true},
		{"id":"covelo","name":"Covelo","theme":"autumn","authored":"quarter","saga":true},
		{"id":"witches_saddle","name":"The Witches' Saddle","theme":"ashen","authored":"peaks","saga":true},
		# The hold-outs: the same ground with the enemy seated near.
		{"id":"montalto_witches_night","name":"Montalto, the Night of the Witches","theme":"ashen","authored":"montalto","saga":true},
		{"id":"pilgrims_bridge","name":"The Pilgrims' Bridge","theme":"verdant","authored":"junias","seats":[0,3,2,1],"saga":true},
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
	match String(s["authored"]):
		"gorge": a = _rabagao_gorge()
		"quarter": a = _salto_lower_quarter()
		"pass": a = _garrano_pass()
		"mire": a = _ashfen_mire()
		"tourem": a = _tourem_crossing()
		"pyre": a = _malrecs_pyre()
		"grove": a = _seven_fountains()
		"fountain": a = _bread_fountain()
		"furna": a = _furna_reservoir()
		"envoy": a = _envoys_field()
		"boticas": a = _boticas()
		"larouco": a = _larouco_road()
		"castro": a = _castro_carvalhelhos()
		"candle": a = _candle_road()
		"cross": a = _leonors_cross()
		"peaks": a = _four_peaks()
		"geira": a = _geira_road()
		"mines": a = _ironmaw_mines()
		"plains": a = _plains_of_bronze()
		"heart": a = _glass_heart()
		"canyon": a = _regents_canyon()
		"wall": a = _rabagao_wall()
		"montalto": a = _montalto()
		"fojo": a = _fojo()
		"junias": a = _junias()
	var size: float = float(a["size"])
	var starts: Array = a["starts"]
	# A hold-out chapter wants its enemies near: a spec may seat the players in
	# another order (seat 0 is the player, the opponents follow).
	if s.has("seats"):
		var seated: Array = []
		for seat in s["seats"]:
			seated.append(starts[int(seat)])
		starts = seated
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
	# Beside a bridge the river is deep again. The shallows of the ford a
	# bridge stands on used to stay open either side of its rails: a strip a
	# few metres wide that the planner took for a way across and no unit
	# could walk, so soldiers wedged themselves into it.
	var bridges_turned: bool = bool(a.get("bridges_turned", false))
	for bridge_pos in a.get("bridges", []):
		for ford in fords:
			if Vector2(bridge_pos.x, bridge_pos.z).distance_to(Vector2(ford["pos"].x, ford["pos"].z)) > 6.0:
				continue
			var strip: float = float(ford["half"]) - 6.35 + 2.0
			if strip <= 0.0:
				continue
			for side in [-1.0, 1.0]:
				var along: float = (6.35 + strip * 0.5) * side
				var across: float = float(ford["width"]) * 0.5
				crags.append({
					"pos": bridge_pos + (Vector3(0.0, 0.0, along) if bridges_turned else Vector3(along, 0.0, 0.0)),
					"half": Vector2(across, strip * 0.5) if bridges_turned else Vector2(strip * 0.5, across),
					"kind": "water"})
	var woods: Array = []
	for wood in a["woods"]:
		woods.append(wood)
		crags.append_array(_wood_tiles(wood))
	# A hill is shaped like a wood too: high ground nobody can climb.
	var hills: Array = []
	for hill in a.get("hills", []):
		hills.append(hill)
		for tile in _wood_tiles(hill):
			tile["kind"] = "hill"
			crags.append(tile)
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
		"hills": hills,
		"bridges": a.get("bridges", []),
		"bridges_turned": a.get("bridges_turned", false),
		"ruins": a.get("ruins", []),
		"farmsteads": a.get("farmsteads", []),
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
		# A knoll between the road and the river on either side of the shallows.
		"hills": [
			{"at": Vector2(-66, -18), "radii": Vector2(17, 10), "height": 9.0, "seed": 2.2},
			{"at": Vector2(66, 18), "radii": Vector2(17, 10), "height": 9.0, "seed": 2.2 + PI},
		],
		# A bridge over each of the two outer fords (the river runs east to
		# west there, so the deck lies north to south). The centre stays a ford.
		"bridges": [Vector3(-150, 0, 34), Vector3(150, 0, -34)],
		# What is left of an old castro in the open country, and its twin.
		"ruins": [{"at": Vector2(48, -68), "radius": 9.0, "seed": 3}, {"at": Vector2(-48, 68), "radius": 9.0, "seed": 4}],
		# Farmsteads outside the walls: a croft, a field wall, a woodpile.
		# One by the spring and one beyond the east gate, and their twins.
		"farmsteads": [
			{"at": Vector2(-92, -28), "yaw": 0.4}, {"at": Vector2(92, 28), "yaw": 0.4 + PI},
			{"at": Vector2(-60, -166), "yaw": -0.9}, {"at": Vector2(60, 166), "yaw": -0.9 + PI},
		],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Salto, the Lower Quarter (saga 1-2, "The Burning Oven"). 380 m across: a
## village fight. The communal oven stands in the square at the centre with
## six crofts round it and streets between them. Terraced ridges fence each
## walled start off from the fields, with one gate toward the square; woods
## and a knoll break up the rest. No river: the quarter is fought house to
## house, and whoever holds the oven is fed by it.
static func _salto_lower_quarter() -> Dictionary:
	var ridges: Array = []
	for line in [
		[Vector2(-118, -58), Vector2(-92, -66), Vector2(-70, -58)],
		[Vector2(-58, -118), Vector2(-66, -92), Vector2(-58, -72)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 2.0
	for wood in [[-150, 10, 16, 24], [10, -150, 24, 16], [-40, 92, 18, 14], [92, -36, 14, 18]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.1
	var hills: Array = [
		{"at": Vector2(-22, -96), "radii": Vector2(15, 10), "height": 8.0, "seed": 1.7},
		{"at": Vector2(22, 96), "radii": Vector2(15, 10), "height": 8.0, "seed": 1.7 + PI},
	]
	# The square: six crofts on a ring round the oven, doors to the middle.
	var farmsteads: Array = []
	for k in 6:
		var angle := deg_to_rad(30.0 + 60.0 * float(k))
		farmsteads.append({"at": Vector2(cos(angle), sin(angle)) * 34.0, "yaw": atan2(-cos(angle), -sin(angle))})
	# Outlying crofts on the lanes out to the fields.
	for croft in [[6, -84, 0.0], [-84, 4, 1.57]]:
		farmsteads.append({"at": Vector2(croft[0], croft[1]), "yaw": croft[2]})
		farmsteads.append({"at": Vector2(-croft[0], -croft[1]), "yaw": croft[2] + PI})
	var veins: Array = []
	_pair_point(veins, "gold", -120, -22)
	_pair_point(veins, "food", -30, -128)
	_pair_point(veins, "stone", -172, -70)
	_pair_point(veins, "timber", -100, -164)
	_pair_point(veins, "gold", -122, 66)
	_pair_point(veins, "food", -64, 152)
	_pair_point(veins, "stone", -172, 74)
	_pair_point(veins, "timber", -100, 104)
	_pair_point(veins, "gold", -62, -12)
	var deposits: Array = []
	_pair_point(deposits, "gold", -68, 12)
	_pair_point(deposits, "stone", -14, 66)
	_pair_point(deposits, "timber", -178, -38)
	_pair_point(deposits, "food", -52, -40)
	var sites: Array = [
		{"name": "The Communal Oven", "benefit": "income", "pos": Vector3.ZERO, "model": "res://assets/environment/buildings/barrosan_iron_forge_b01_r2.glb"},
		{"name": "Chapel of the Lower Quarter", "benefit": "heal", "pos": Vector3(-96, 0, -20), "model": RUIN},
		{"name": "The Threshing Floor", "benefit": "heal", "pos": Vector3(96, 0, 20), "model": RUIN},
		{"name": "North Field Watch", "benefit": "vision", "pos": Vector3(-54, 0, 128), "model": WATCH},
		{"name": "South Field Watch", "benefit": "vision", "pos": Vector3(54, 0, -128), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-140, -130, -64, -65), Vector4(-64, -65, 0, 0), Vector4(140, 130, 64, 65), Vector4(64, 65, 0, 0),
		Vector4(-140, 130, 0, 0), Vector4(140, -130, 0, 0),
	]
	return {
		"size": 190.0,
		"starts": [Vector3(-140, 0, -130), Vector3(140, 0, 130), Vector3(-140, 0, 130), Vector3(140, 0, -130)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [], "ruins": [], "farmsteads": farmsteads,
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Garrano Pass (saga 1-3, "Garrano Run"). 440 m across. A mountain wall
## runs east to west through the middle of the high pasture and there are
## three ways through it: the pass at the centre, between two tall shoulders,
## and a narrower gap far out on either wing. Whoever holds the pass holds
## the short road; the gaps are the long way round for a raid.
static func _garrano_pass() -> Dictionary:
	var ridges: Array = []
	for line in [
		# The wall, from the western rim to the west gap, then on to the pass.
		[Vector2(-226, 6), Vector2(-200, -2), Vector2(-174, 2)],
		[Vector2(-138, 4), Vector2(-100, -6), Vector2(-62, 2), Vector2(-50, 0)],
		# A second line behind it so the wall has depth.
		[Vector2(-128, 16), Vector2(-96, 8), Vector2(-66, 14)],
		# A spur that shelters each walled start from the pasture.
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
	]:
		ridges.append({"points": line, "thickness": 12.0})
		ridges.append({"points": _twin_points(line), "thickness": 12.0})
	# The shoulders of the pass.
	var hills: Array = [
		{"at": Vector2(-36, 0), "radii": Vector2(20, 15), "height": 17.0, "seed": 3.1},
		{"at": Vector2(36, 0), "radii": Vector2(20, 15), "height": 17.0, "seed": 3.1 + PI},
		{"at": Vector2(-150, 104), "radii": Vector2(16, 12), "height": 9.0, "seed": 0.6},
		{"at": Vector2(150, -104), "radii": Vector2(16, 12), "height": 9.0, "seed": 0.6 + PI},
	]
	var woods: Array = []
	var wood_seed := 3.4
	for wood in [[-104, -94, 22, 16], [-40, -196, 18, 12], [-92, 84, 20, 16], [-204, 42, 12, 18]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 0.9
	# Tarns on the high pasture where the garranos water.
	var lakes: Array = [
		{"at": Vector2(-70, -48), "radii": Vector2(16, 11), "seed": 2.6},
		{"at": Vector2(70, 48), "radii": Vector2(16, 11), "seed": 2.6 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -52, 30)
	var deposits: Array = []
	_pair_point(deposits, "gold", -56, -24)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -96, -30)
	_pair_point(deposits, "food", -180, 30)
	var sites: Array = [
		{"name": "The Garrano Pass", "benefit": "income", "pos": Vector3.ZERO, "model": WATCH},
		{"name": "Shepherds' Fold", "benefit": "heal", "pos": Vector3(-104, 0, -58), "model": RUIN},
		{"name": "Drovers' Rest", "benefit": "heal", "pos": Vector3(104, 0, 58), "model": RUIN},
		{"name": "West Gap Watch", "benefit": "vision", "pos": Vector3(-156, 0, 30), "model": WATCH},
		{"name": "East Gap Watch", "benefit": "vision", "pos": Vector3(156, 0, -30), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -70, -76), Vector4(-70, -76, 0, 0), Vector4(160, 150, 70, 76), Vector4(70, 76, 0, 0),
		Vector4(160, -150, 156, -30), Vector4(156, -30, 156, 30), Vector4(-160, 150, -156, 30), Vector4(-156, 30, -156, -30),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": lakes, "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-18, -62), "radius": 8.0, "seed": 11}, {"at": Vector2(18, 62), "radius": 8.0, "seed": 12}],
		"farmsteads": [{"at": Vector2(-132, -38), "yaw": 0.6}, {"at": Vector2(132, 38), "yaw": 0.6 + PI}],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Ashfen Mire (saga 1-4). 440 m across. A bog of black pools with firm
## ground winding between them. Four pools ring the ash-glass harvest at the
## centre, leaving four causeways in; further out the pools are larger and
## the ways between them wider. Nothing here is a wall, and nothing is a
## straight line either.
static func _ashfen_mire() -> Dictionary:
	var lakes: Array = []
	var pool_seed := 0.7
	for pool in [
		# The ring round the harvest.
		[-36, -30, 18, 14], [-36, 30, 18, 14],
		# The wider bog.
		[-110, -20, 26, 16], [-190, 20, 18, 24], [-60, -190, 22, 12], [-108, 98, 24, 18],
		[-20, -110, 18, 12], [-40, 100, 16, 20],
	]:
		lakes.append({"at": Vector2(pool[0], pool[1]), "radii": Vector2(pool[2], pool[3]), "seed": pool_seed})
		lakes.append({"at": Vector2(-pool[0], -pool[1]), "radii": Vector2(pool[2], pool[3]), "seed": pool_seed + PI})
		pool_seed += 0.8
	var ridges: Array = []
	for line in [
		# A spur of firm rock that shelters each walled start.
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	# Alder carr on the drier ground.
	var woods: Array = []
	var wood_seed := 4.2
	for wood in [[-100, 56, 20, 16], [-10, -170, 14, 18], [-208, 174, 12, 12]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.2
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -74, 24)
	var deposits: Array = []
	_pair_point(deposits, "gold", -72, -24)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -142, 12)
	_pair_point(deposits, "food", -176, -58)
	var sites: Array = [
		{"name": "The Ash-Glass Harvest", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "Peat Cutters' Huts", "benefit": "heal", "pos": Vector3(-108, 0, -68), "model": RUIN},
		{"name": "The Drowned Shrine", "benefit": "heal", "pos": Vector3(108, 0, 68), "model": RUIN},
		{"name": "North Reed Watch", "benefit": "vision", "pos": Vector3(-80, 0, 150), "model": WATCH},
		{"name": "South Reed Watch", "benefit": "vision", "pos": Vector3(80, 0, -150), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -90, -70), Vector4(-90, -70, -62, 0), Vector4(-62, 0, 0, 0),
		Vector4(160, 150, 90, 70), Vector4(90, 70, 62, 0), Vector4(62, 0, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": lakes, "hills": [],
		"bridges": [],
		"ruins": [{"at": Vector2(-150, 34), "radius": 8.0, "seed": 21}, {"at": Vector2(150, -34), "radius": 8.0, "seed": 22}],
		"farmsteads": [{"at": Vector2(-126, -62), "yaw": 0.8}, {"at": Vector2(126, 62), "yaw": 0.8 + PI}],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Tourem Crossing (saga 1-5). 440 m across. The border river runs west to
## east through the middle of the map and the smugglers' village of Tourem
## straddles it at the one bridge. Two starts lie on the south bank and two
## on the north. Far out on each wing the river can be waded; the bridge is
## the short road and the village is what is fought over.
static func _tourem_crossing() -> Dictionary:
	var rivers: Array = [{
		"points": [Vector2(-232, -60), Vector2(-150, -50), Vector2(-90, -24), Vector2(-40, -4), Vector2(0, 0),
			Vector2(40, 4), Vector2(90, 24), Vector2(150, 50), Vector2(232, 60)],
		"width": 15.0,
		"fords": [{"at": Vector2(-150, -50), "half": 11.0}, {"at": Vector2(0, 0), "half": 13.0}, {"at": Vector2(150, 50), "half": 11.0}],
	}]
	var ridges: Array = []
	for line in [
		# A spur that shelters each walled start from the river road.
		[Vector2(-116, -104), Vector2(-146, -96), Vector2(-176, -104)],
		[Vector2(-116, 104), Vector2(-146, 98), Vector2(-176, 106)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 5.3
	for wood in [[-204, 50, 14, 20], [-30, -124, 22, 16], [-10, 182, 16, 14], [-206, -168, 12, 12]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.4
	var hills: Array = [
		{"at": Vector2(-112, 56), "radii": Vector2(15, 11), "height": 9.0, "seed": 1.3},
		{"at": Vector2(112, -56), "radii": Vector2(15, 11), "height": 9.0, "seed": 1.3 + PI},
	]
	# Tourem: crofts on both banks by the bridge.
	var farmsteads: Array = []
	for croft in [[-36, 44, 2.4], [-74, 26, 1.9], [-12, 74, 3.0], [30, 30, 3.6]]:
		farmsteads.append({"at": Vector2(croft[0], croft[1]), "yaw": croft[2]})
		farmsteads.append({"at": Vector2(-croft[0], -croft[1]), "yaw": croft[2] + PI})
	var veins: Array = []
	_pair_point(veins, "gold", -96, -152)
	_pair_point(veins, "food", -204, -122)
	_pair_point(veins, "stone", -130, -204)
	_pair_point(veins, "timber", -62, -196)
	_pair_point(veins, "gold", -96, 152)
	_pair_point(veins, "food", -204, 122)
	_pair_point(veins, "stone", -130, 204)
	_pair_point(veins, "timber", -62, 196)
	_pair_point(veins, "gold", -150, 10)
	var deposits: Array = []
	_pair_point(deposits, "gold", -44, -72)
	_pair_point(deposits, "stone", -60, 120)
	_pair_point(deposits, "timber", -178, 20)
	_pair_point(deposits, "food", -70, 80)
	var sites: Array = [
		{"name": "Tourem Market", "benefit": "income", "pos": Vector3(-62, 0, 62), "model": LUME},
		{"name": "The Smugglers' Yard", "benefit": "income", "pos": Vector3(62, 0, -62), "model": LUME},
		{"name": "West Ford Watch", "benefit": "vision", "pos": Vector3(-150, 0, -20), "model": WATCH},
		{"name": "East Ford Watch", "benefit": "vision", "pos": Vector3(150, 0, 20), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -60, -80), Vector4(-60, -80, 0, -30), Vector4(0, -30, 0, 30), Vector4(0, 30, 60, 80), Vector4(60, 80, 160, 150),
		Vector4(-160, 150, -150, 30), Vector4(-150, 30, -150, -50), Vector4(160, -150, 150, -30), Vector4(150, -30, 150, 50),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": rivers, "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [Vector3(0, 0, 0)],
		"ruins": [{"at": Vector2(-196, -24), "radius": 8.0, "seed": 31}, {"at": Vector2(196, 24), "radius": 8.0, "seed": 32}],
		"farmsteads": farmsteads,
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Malrec's Pyre (saga 1-6, the end of act one). 440 m across. The Emberfall
## rift runs corner to corner between two long rock walls, with the pyre at
## its centre and the ash-glass forges either side of it. The two facing
## starts look straight down the rift at each other. Each wall has two gaps,
## so the camp can be entered from the flanks, and cinder cones stand out on
## the open ground beyond the walls.
static func _malrecs_pyre() -> Dictionary:
	var ridges: Array = []
	for line in [
		# The north-west wall of the rift, in three lengths with two gaps.
		[Vector2(-119, -48), Vector2(-97, -21), Vector2(-68, -1)],
		[Vector2(-46, 20), Vector2(-13, 43), Vector2(12, 75)],
		[Vector2(34, 95), Vector2(44, 107), Vector2(56, 116)],
	]:
		ridges.append({"points": line, "thickness": 12.0})
		ridges.append({"points": _twin_points(line), "thickness": 12.0})
	# Cinder cones on the open ground beyond the walls.
	var hills: Array = [
		{"at": Vector2(-75, 80), "radii": Vector2(20, 15), "height": 14.0, "seed": 4.4},
		{"at": Vector2(75, -80), "radii": Vector2(20, 15), "height": 14.0, "seed": 4.4 + PI},
		{"at": Vector2(-18, -127), "radii": Vector2(16, 12), "height": 9.0, "seed": 2.9},
		{"at": Vector2(18, 127), "radii": Vector2(16, 12), "height": 9.0, "seed": 2.9 + PI},
	]
	var woods: Array = []
	var wood_seed := 6.1
	for wood in [[-196, 26, 14, 18], [-20, 178, 16, 12]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.6
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -39, -9)
	var deposits: Array = []
	_pair_point(deposits, "gold", -60, -22)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -122, 2)
	_pair_point(deposits, "food", -170, -6)
	var sites: Array = [
		{"name": "Malrec's Pyre", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Thrall Pens", "benefit": "heal", "pos": Vector3(-108, 0, -68), "model": RUIN},
		{"name": "The Slag Heaps", "benefit": "heal", "pos": Vector3(108, 0, 68), "model": RUIN},
		{"name": "North Rim Watch", "benefit": "vision", "pos": Vector3(-40, 0, 130), "model": WATCH},
		{"name": "South Rim Watch", "benefit": "vision", "pos": Vector3(40, 0, -130), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -87, -82), Vector4(-87, -82, 0, 0), Vector4(160, 150, 87, 82), Vector4(87, 82, 0, 0),
		Vector4(-160, 150, -120, 40), Vector4(-120, 40, -57, 8), Vector4(160, -150, 120, -40), Vector4(120, -40, 57, -8),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		# The ash-glass forges, in ruins of an older castro.
		"ruins": [{"at": Vector2(-42, -58), "radius": 8.0, "seed": 41}, {"at": Vector2(42, 58), "radius": 8.0, "seed": 42}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Grove of Seven Fountains (saga 2-2). 440 m across. Old forest in
## broad belts with glades and rides between them. Six fountain pools stand
## in a ring round the seventh at the heart of the grove, and the ways in
## pass between the pools. The forest hides the flanks: there is always
## another ride round.
static func _seven_fountains() -> Dictionary:
	var lakes: Array = []
	for k in 3:
		var angle := deg_to_rad(30.0 + 60.0 * float(k))
		var at := Vector2(cos(angle), sin(angle)) * 50.0
		lakes.append({"at": at, "radii": Vector2(10, 8), "seed": 1.0 + float(k)})
		lakes.append({"at": -at, "radii": Vector2(10, 8), "seed": 1.0 + float(k) + PI})
	var woods: Array = []
	var wood_seed := 7.7
	for wood in [[-90, -20, 34, 22], [-24, -112, 22, 22], [-104, 96, 26, 22], [-204, 30, 12, 26], [-70, 60, 18, 14], [-60, -190, 20, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.1
	var ridges: Array = []
	for line in [
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var hills: Array = [
		{"at": Vector2(-150, 40), "radii": Vector2(14, 10), "height": 8.0, "seed": 5.2},
		{"at": Vector2(150, -40), "radii": Vector2(14, 10), "height": 8.0, "seed": 5.2 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -80, 34)
	var deposits: Array = []
	_pair_point(deposits, "gold", -48, -70)
	_pair_point(deposits, "stone", -56, 160)
	_pair_point(deposits, "timber", -142, -4)
	_pair_point(deposits, "food", -176, -10)
	var sites: Array = [
		{"name": "The Seventh Fountain", "benefit": "income", "pos": Vector3.ZERO, "model": SPRING},
		{"name": "The Mouras' Table", "benefit": "heal", "pos": Vector3(-108, 0, -68), "model": RUIN},
		{"name": "The Bread Stone", "benefit": "heal", "pos": Vector3(108, 0, 68), "model": RUIN},
		{"name": "North Ride Watch", "benefit": "vision", "pos": Vector3(-40, 0, 130), "model": WATCH},
		{"name": "South Ride Watch", "benefit": "vision", "pos": Vector3(40, 0, -130), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -60, -72), Vector4(-60, -72, -25, -43), Vector4(-25, -43, 0, 0),
		Vector4(160, 150, 60, 72), Vector4(60, 72, 25, 43), Vector4(25, 43, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": lakes, "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-176, -62), "radius": 8.0, "seed": 51}, {"at": Vector2(176, 62), "radius": 8.0, "seed": 52}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Bread Fountain (saga 2-3, "Where the Bread Was Left"). 440 m across.
## The fountain stands on an island: its water runs out in a ring before it
## finds the valley, and the island can be reached by four fords, one facing
## each start. The Dominion's stoneworks stand on the terraces outside the
## ring, and two crofts of the women who leave the bread lie on each side.
static func _bread_fountain() -> Dictionary:
	# The ring stream: sixteen points round the island, closed on itself.
	var ring: Array = []
	for k in 17:
		var angle := PI * 0.25 + TAU * float(k) / 16.0
		ring.append(Vector2(cos(angle), sin(angle)) * (60.0 + 5.0 * cos(angle * 4.0)))
	var fords: Array = []
	for k in 4:
		var angle := deg_to_rad(45.0 + 90.0 * float(k))
		fords.append({"at": Vector2(cos(angle), sin(angle)) * 55.0, "half": 12.0})
	var rivers: Array = [{"points": ring, "width": 12.0, "fords": fords}]
	var ridges: Array = []
	for line in [
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
		# The stoneworks terraces.
		[Vector2(-150, 20), Vector2(-140, 44), Vector2(-124, 60)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 8.8
	for wood in [[-30, -114, 22, 18], [-192, 40, 12, 16], [-70, 100, 18, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.3
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -98, 20)
	var deposits: Array = []
	_pair_point(deposits, "gold", -78, -52)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -126, -6)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Bread Fountain", "benefit": "income", "pos": Vector3.ZERO, "model": SPRING},
		{"name": "The Mason's Yard", "benefit": "heal", "pos": Vector3(-108, 0, -68), "model": RUIN},
		{"name": "The Washing Stones", "benefit": "heal", "pos": Vector3(108, 0, 68), "model": RUIN},
		{"name": "North Terrace Watch", "benefit": "vision", "pos": Vector3(-40, 0, 132), "model": WATCH},
		{"name": "South Terrace Watch", "benefit": "vision", "pos": Vector3(40, 0, -132), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -39, -39), Vector4(-39, -39, 0, 0), Vector4(160, 150, 39, 39), Vector4(39, 39, 0, 0),
		Vector4(-160, 150, -39, 39), Vector4(-39, 39, 0, 0), Vector4(160, -150, 39, -39), Vector4(39, -39, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": rivers, "ridges": ridges, "woods": woods, "lakes": [], "hills": [],
		"bridges": [],
		"ruins": [],
		"farmsteads": [
			{"at": Vector2(-106, -20), "yaw": 1.2}, {"at": Vector2(106, 20), "yaw": 1.2 + PI},
			{"at": Vector2(10, -94), "yaw": 0.2}, {"at": Vector2(-10, 94), "yaw": 0.2 + PI},
		],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Furna Below the Water (saga 2-4). 440 m across. The reservoir has fallen
## and what is left of it lies in two broad sheets with the old village
## street dry between them: a causeway through the middle of the map with
## the bell tower of Furna standing in it, and the roofs of four crofts by
## its two mouths. Everything else must go the long way round the water.
static func _furna_reservoir() -> Dictionary:
	var lakes: Array = [
		{"at": Vector2(-76, 0), "radii": Vector2(52, 54), "seed": 3.3},
		{"at": Vector2(76, 0), "radii": Vector2(52, 54), "seed": 3.3 + PI},
	]
	var ridges: Array = []
	for line in [
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 9.9
	for wood in [[-170, 36, 14, 18], [-30, -122, 20, 14], [-90, 110, 22, 16]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.5
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -74, 80)
	var deposits: Array = []
	_pair_point(deposits, "gold", -84, -80)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -152, -12)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Bell Tower of Furna", "benefit": "income", "pos": Vector3.ZERO, "model": WATCH},
		{"name": "Furna Churchyard", "benefit": "heal", "pos": Vector3(-112, 0, -66), "model": RUIN},
		{"name": "The Mourners' Camp", "benefit": "heal", "pos": Vector3(112, 0, 66), "model": RUIN},
		{"name": "North Shore Watch", "benefit": "vision", "pos": Vector3(-40, 0, 132), "model": WATCH},
		{"name": "South Shore Watch", "benefit": "vision", "pos": Vector3(40, 0, -132), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -30, -94), Vector4(-30, -94, 0, -52), Vector4(0, -52, 0, 52), Vector4(0, 52, 30, 94), Vector4(30, 94, 160, 150),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": lakes, "hills": [],
		"bridges": [],
		"ruins": [{"at": Vector2(-144, -38), "radius": 8.0, "seed": 61}, {"at": Vector2(144, 38), "radius": 8.0, "seed": 62}],
		"farmsteads": [
			{"at": Vector2(-32, -72), "yaw": 0.5}, {"at": Vector2(32, 72), "yaw": 0.5 + PI},
			{"at": Vector2(-32, 72), "yaw": 2.6}, {"at": Vector2(32, -72), "yaw": 2.6 + PI},
		],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Envoy's Field (saga 2-5). 440 m across. Four old hill forts, one in
## each corner: every start stands inside a ring of rampart with three
## gates, to the two neighbours and to the field. Between them lies open
## parley ground with the envoy's pavilion at the centre. A fort is easy to
## hold and hard to leave: whoever comes out first is seen coming.
static func _envoys_field() -> Dictionary:
	var ridges: Array = []
	# The rampart round the start at (-160, -150), as arcs between the gates
	# (angles in degrees from east, the field lying to the north-east).
	var fort := Vector2(-160, -150)
	for arc in [[-72.0, -12.0], [12.0, 31.0], [55.0, 78.0], [102.0, 142.0]]:
		var line: Array = []
		for step in 4:
			var angle := deg_to_rad(lerpf(arc[0], arc[1], float(step) / 3.0))
			line.append(fort + Vector2(cos(angle), sin(angle)) * 72.0)
		# The same rampart round the start to the north, mirrored.
		var mirrored: Array = []
		for point in line:
			mirrored.append(Vector2(point.x, -point.y))
		for wall in [line, mirrored]:
			ridges.append({"points": wall, "thickness": 9.0})
			ridges.append({"points": _twin_points(wall), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 10.4
	for wood in [[-20, -86, 20, 14], [-90, 56, 18, 16]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.7
	var hills: Array = [
		{"at": Vector2(-30, 96), "radii": Vector2(14, 10), "height": 8.0, "seed": 6.6},
		{"at": Vector2(30, -96), "radii": Vector2(14, 10), "height": 8.0, "seed": 6.6 + PI},
	]
	var lakes: Array = [
		{"at": Vector2(-152, 0), "radii": Vector2(14, 9), "seed": 2.2},
		{"at": Vector2(152, 0), "radii": Vector2(14, 9), "seed": 2.2 + PI},
	]
	var veins: Array = []
	for sign in [-1.0, 1.0]:
		_pair_point(veins, "gold", -150, 62 * sign)
		_pair_point(veins, "food", -62, 150 * sign)
		_pair_point(veins, "stone", -196, 40 * sign)
		_pair_point(veins, "timber", -130, 200 * sign)
	_pair_point(veins, "gold", -52, 26)
	var deposits: Array = []
	_pair_point(deposits, "gold", -60, -20)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -120, 0)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Envoy's Pavilion", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Ledger Stone", "benefit": "heal", "pos": Vector3(-104, 0, -62), "model": RUIN},
		{"name": "The Legion's Well", "benefit": "heal", "pos": Vector3(104, 0, 62), "model": RUIN},
		{"name": "North Field Post", "benefit": "vision", "pos": Vector3(-40, 0, 132), "model": WATCH},
		{"name": "South Field Post", "benefit": "vision", "pos": Vector3(40, 0, -132), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -107, -101), Vector4(-107, -101, 0, 0), Vector4(160, 150, 107, 101), Vector4(107, 101, 0, 0),
		Vector4(-160, 150, -107, 101), Vector4(-107, 101, 0, 0), Vector4(160, -150, 107, -101), Vector4(107, -101, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": lakes, "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-40, -64), "radius": 7.0, "seed": 71}, {"at": Vector2(40, 64), "radius": 7.0, "seed": 72}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Boticas (saga 3-1, "Boticas Cellars"). 440 m across. A dead town on old
## granite: one street running west to east with four houses on each side,
## the Wine of the Dead buried under the middle of it, and broken cellars at
## both ends of the street and behind the houses. Granite outcrops close
## the town to north, south, east and west, so every way in is a corner.
static func _boticas() -> Dictionary:
	var ridges: Array = []
	for line in [
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
		# The outcrops round the town.
		[Vector2(-132, -30), Vector2(-124, -4), Vector2(-132, 22)],
		[Vector2(-40, -98), Vector2(-10, -106), Vector2(20, -98)],
	]:
		ridges.append({"points": line, "thickness": 10.0})
		ridges.append({"points": _twin_points(line), "thickness": 10.0})
	var woods: Array = []
	var wood_seed := 11.5
	for wood in [[-172, 42, 14, 18], [-70, 112, 18, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.9
	# The street: houses facing each other across it.
	var farmsteads: Array = []
	for house_x in [-62, -31, 31, 62]:
		farmsteads.append({"at": Vector2(house_x, 24), "yaw": PI})
		farmsteads.append({"at": Vector2(-house_x, -24), "yaw": 0.0})
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "stone", -92, -48)
	var deposits: Array = []
	_pair_point(deposits, "gold", -58, -62)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -154, -2)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Wine of the Dead", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Elders' Cellar", "benefit": "heal", "pos": Vector3(-108, 0, -70), "model": RUIN},
		{"name": "The Sexton's Cellar", "benefit": "heal", "pos": Vector3(108, 0, 70), "model": RUIN},
		{"name": "North Outcrop Watch", "benefit": "vision", "pos": Vector3(-40, 0, 134), "model": WATCH},
		{"name": "South Outcrop Watch", "benefit": "vision", "pos": Vector3(40, 0, -134), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -92, -60), Vector4(-92, -60, -84, 0), Vector4(-84, 0, 84, 0),
		Vector4(160, 150, 92, 60), Vector4(92, 60, 84, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": [],
		"bridges": [],
		"ruins": [
			{"at": Vector2(-98, 4), "radius": 9.0, "seed": 81}, {"at": Vector2(98, -4), "radius": 9.0, "seed": 82},
			{"at": Vector2(4, -64), "radius": 8.0, "seed": 83}, {"at": Vector2(-4, 64), "radius": 8.0, "seed": 84},
		],
		"farmsteads": farmsteads,
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Larouco Road (saga 3-2, "The Eldest Mask"). 440 m across, under snow.
## The only road to the castro climbs in a switchback between two mountain
## walls that cross the whole map. Each wall has one gate wide enough for an
## army and one postern far off at its other end, and the gates are at
## opposite ends, so the road runs the length of the shelf between the
## walls. The Caretos hold that shelf.
static func _larouco_road() -> Dictionary:
	var ridges: Array = []
	for line in [
		# The southern wall: rim to postern, postern to gate, gate to rim.
		[Vector2(-226, -36), Vector2(-192, -42), Vector2(-164, -38)],
		[Vector2(-136, -42), Vector2(-80, -36), Vector2(-10, -44), Vector2(56, -38)],
		[Vector2(100, -42), Vector2(160, -36), Vector2(226, -44)],
		# A spur that shelters the walled start.
		[Vector2(-120, -100), Vector2(-150, -92), Vector2(-178, -102)],
	]:
		ridges.append({"points": line, "thickness": 12.0})
		ridges.append({"points": _twin_points(line), "thickness": 12.0})
	var woods: Array = []
	var wood_seed := 12.6
	for wood in [[-30, -112, 22, 16], [-100, 98, 18, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 2.1
	var hills: Array = [
		{"at": Vector2(150, -94), "radii": Vector2(16, 12), "height": 10.0, "seed": 7.3},
		{"at": Vector2(-150, 94), "radii": Vector2(16, 12), "height": 10.0, "seed": 7.3 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -112, -74)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -200, -72)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 72)
	_pair_point(veins, "gold", -40, 10)
	var deposits: Array = []
	_pair_point(deposits, "gold", -62, -18)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -120, 0)
	_pair_point(deposits, "food", -196, 4)
	var sites: Array = [
		{"name": "The Eldest Mask", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Bell Ringers' Fire", "benefit": "heal", "pos": Vector3(-60, 0, -86), "model": RUIN},
		{"name": "The Castro Road Shrine", "benefit": "heal", "pos": Vector3(60, 0, 86), "model": RUIN},
		{"name": "South Gate Watch", "benefit": "vision", "pos": Vector3(122, 0, -68), "model": WATCH},
		{"name": "North Gate Watch", "benefit": "vision", "pos": Vector3(-122, 0, 68), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -40, -128), Vector4(-40, -128, 62, -76), Vector4(62, -76, 78, -40), Vector4(78, -40, 44, 0), Vector4(44, 0, 0, 0),
		Vector4(160, 150, 40, 128), Vector4(40, 128, -62, 76), Vector4(-62, 76, -78, 40), Vector4(-78, 40, -44, 0), Vector4(-44, 0, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-150, 6), "radius": 8.0, "seed": 91}, {"at": Vector2(150, -6), "radius": 8.0, "seed": 92}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Castro of Carvalhelhos (saga 3-3, "The Castro Ledger"). 440 m across,
## under snow. The Granitborn's hill fort fills the middle of the map: two
## rings of stone, the outer with gates at the four corners and the inner
## with gates at the four sides, so nobody walks straight in. The ledger of
## the dead stands at the centre; the ground between the rings holds gold.
static func _castro_carvalhelhos() -> Dictionary:
	var ridges: Array = []
	# Each ring is four arcs with a gate between each pair.
	for ring in [[80.0, 57.0, 123.0], [40.0, 22.0, 68.0]]:
		for quarter in 4:
			var line: Array = []
			for step in 6:
				var angle := deg_to_rad(lerpf(ring[1], ring[2], float(step) / 5.0) + 90.0 * float(quarter))
				line.append(Vector2(cos(angle), sin(angle)) * float(ring[0]))
			ridges.append({"points": line, "thickness": 8.0})
	for line in [
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 13.7
	for wood in [[-30, -120, 20, 14], [-104, 98, 18, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 2.3
	var hills: Array = [
		{"at": Vector2(150, -94), "radii": Vector2(16, 12), "height": 10.0, "seed": 8.1},
		{"at": Vector2(-150, 94), "radii": Vector2(16, 12), "height": 10.0, "seed": 8.1 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -56, 22)
	var deposits: Array = []
	_pair_point(deposits, "gold", -22, -56)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -124, 0)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Ledger of the Dead", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Stone Sleepers", "benefit": "heal", "pos": Vector3(-108, 0, -68), "model": RUIN},
		{"name": "The Chiselled Names", "benefit": "heal", "pos": Vector3(108, 0, 68), "model": RUIN},
		{"name": "North Rampart Watch", "benefit": "vision", "pos": Vector3(-40, 0, 134), "model": WATCH},
		{"name": "South Rampart Watch", "benefit": "vision", "pos": Vector3(40, 0, -134), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -57, -57), Vector4(-57, -57, -42, 0), Vector4(-42, 0, 0, 0),
		Vector4(160, 150, 57, 57), Vector4(57, 57, 42, 0), Vector4(42, 0, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-150, 6), "radius": 8.0, "seed": 95}, {"at": Vector2(150, -6), "radius": 8.0, "seed": 96}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Candle Road (saga 3-4). 440 m across. Two long meres lie across the
## marsh, one south of the middle and one north, and the road of the dead
## crosses each on a narrow causeway where the mere is broken in two. The
## causeways are the short way and take a column a few abreast; an army
## goes round the ends of the water.
static func _candle_road() -> Dictionary:
	var lakes: Array = []
	var mere_seed := 5.5
	for mere in [
		# The southern mere, in two lengths with the causeway between.
		[-94, -46, 38, 13], [12, -46, 38, 13],
		# Smaller water out in the marsh.
		[-172, 22, 14, 18], [-62, 122, 16, 12],
	]:
		lakes.append({"at": Vector2(mere[0], mere[1]), "radii": Vector2(mere[2], mere[3]), "seed": mere_seed})
		lakes.append({"at": Vector2(-mere[0], -mere[1]), "radii": Vector2(mere[2], mere[3]), "seed": mere_seed + PI})
		mere_seed += 0.9
	var ridges: Array = []
	for line in [
		[Vector2(-120, -98), Vector2(-150, -90), Vector2(-178, -100)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 14.8
	for wood in [[-30, -122, 20, 14], [-106, 98, 18, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 2.5
	var veins: Array = []
	_pair_point(veins, "gold", -152, -66)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -74, 12)
	var deposits: Array = []
	_pair_point(deposits, "gold", -70, -16)
	_pair_point(deposits, "stone", -34, 152)
	_pair_point(deposits, "timber", -124, 0)
	_pair_point(deposits, "food", -200, -6)
	var sites: Array = [
		{"name": "The Head of the Procession", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The First Candle", "benefit": "heal", "pos": Vector3(-106, 0, -78), "model": RUIN},
		{"name": "The Last Candle", "benefit": "heal", "pos": Vector3(106, 0, 78), "model": RUIN},
		{"name": "North Mere Watch", "benefit": "vision", "pos": Vector3(-24, 0, 110), "model": WATCH},
		{"name": "South Mere Watch", "benefit": "vision", "pos": Vector3(24, 0, -110), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -41, -84), Vector4(-41, -84, -41, -18), Vector4(-41, -18, 0, 0),
		Vector4(160, 150, 41, 84), Vector4(41, 84, 41, 18), Vector4(41, 18, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": lakes, "hills": [],
		"bridges": [],
		# Wayside shrines by the causeway mouths.
		"ruins": [{"at": Vector2(-16, -82), "radius": 7.0, "seed": 101}, {"at": Vector2(16, 82), "radius": 7.0, "seed": 102}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Leonor's Cross (saga 3-5, "The Cross-Bearer"). 440 m across. A grey
## massif stands in the middle of the map and nothing crosses it. The road
## of the dead runs in a ring round its foot through a field of broken
## tombs, with the cross on the south side and the drowned pasture on the
## north: two prizes, out of sight of each other.
static func _leonors_cross() -> Dictionary:
	var hills: Array = [{"at": Vector2(0, 0), "radii": Vector2(48, 34), "height": 17.0, "seed": 9.4}]
	var ridges: Array = []
	for line in [
		[Vector2(-120, -98), Vector2(-150, -90), Vector2(-178, -100)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 15.9
	for wood in [[-30, -126, 20, 14], [-106, 98, 18, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 2.7
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -84, 8)
	var deposits: Array = []
	_pair_point(deposits, "gold", -72, -72)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -128, 0)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Cross of the Procession", "benefit": "income", "pos": Vector3(0, 0, -62), "model": LUME},
		{"name": "The Drowned Pasture", "benefit": "income", "pos": Vector3(0, 0, 62), "model": LUME},
		{"name": "The Sexton's Lantern", "benefit": "heal", "pos": Vector3(-108, 0, -68), "model": RUIN},
		{"name": "The Mourners' Bench", "benefit": "heal", "pos": Vector3(108, 0, 68), "model": RUIN},
		{"name": "North Tomb Watch", "benefit": "vision", "pos": Vector3(-40, 0, 134), "model": WATCH},
		{"name": "South Tomb Watch", "benefit": "vision", "pos": Vector3(40, 0, -134), "model": WATCH},
	]
	var roads: Array = [
		Vector4(0, -62, 68, -36), Vector4(68, -36, 68, 36), Vector4(68, 36, 0, 62),
		Vector4(0, 62, -68, 36), Vector4(-68, 36, -68, -36), Vector4(-68, -36, 0, -62),
		Vector4(-160, -150, -68, -36), Vector4(160, 150, 68, 36),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		# The tomb field.
		"ruins": [
			{"at": Vector2(-92, -34), "radius": 8.0, "seed": 111}, {"at": Vector2(92, 34), "radius": 8.0, "seed": 112},
			{"at": Vector2(-92, 46), "radius": 8.0, "seed": 113}, {"at": Vector2(92, -46), "radius": 8.0, "seed": 114},
			{"at": Vector2(-40, -92), "radius": 7.0, "seed": 115}, {"at": Vector2(40, 92), "radius": 7.0, "seed": 116},
		],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Four Peaks of the Larouco (saga 3-6, "Chase Out the Winter"). 440 m
## across, under snow. Four peaks stand round a high saddle where the winter
## is burned; the only ways onto the saddle are the four passes between
## them, one facing each start. Three armies meet there.
static func _four_peaks() -> Dictionary:
	var hills: Array = [
		{"at": Vector2(-72, 0), "radii": Vector2(30, 24), "height": 18.0, "seed": 1.9},
		{"at": Vector2(72, 0), "radii": Vector2(30, 24), "height": 18.0, "seed": 1.9 + PI},
		{"at": Vector2(0, -66), "radii": Vector2(30, 22), "height": 16.0, "seed": 4.8},
		{"at": Vector2(0, 66), "radii": Vector2(30, 22), "height": 16.0, "seed": 4.8 + PI},
	]
	var ridges: Array = []
	for line in [
		[Vector2(-120, -98), Vector2(-150, -90), Vector2(-178, -100)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 16.3
	for wood in [[-30, -128, 20, 14], [-106, 98, 18, 14]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 2.9
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -62, 56)
	var deposits: Array = []
	_pair_point(deposits, "gold", -98, -48)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -134, 6)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Burning of Winter", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Bell Ringers' Camp", "benefit": "heal", "pos": Vector3(-108, 0, -72), "model": RUIN},
		{"name": "The Mother's Halt", "benefit": "heal", "pos": Vector3(108, 0, 72), "model": RUIN},
		{"name": "North Peak Watch", "benefit": "vision", "pos": Vector3(-44, 0, 134), "model": WATCH},
		{"name": "South Peak Watch", "benefit": "vision", "pos": Vector3(44, 0, -134), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -44, -42), Vector4(-44, -42, 0, 0), Vector4(160, 150, 44, 42), Vector4(44, 42, 0, 0),
		Vector4(-160, 150, -44, 42), Vector4(-44, 42, 0, 0), Vector4(160, -150, 44, -42), Vector4(44, -42, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-150, 8), "radius": 8.0, "seed": 121}, {"at": Vector2(150, -8), "radius": 8.0, "seed": 122}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Geira Road (saga 4-1). 440 m across. The old road runs dead straight
## from the north rim to the south, over two rivers by two bridges, past
## milestones older than the Dominion. The rivers cut the map into three
## bands: two starts in the south band, two in the north, and the gold of
## the southern veins in the band between. Each river can also be waded far
## out on either wing.
static func _geira_road() -> Dictionary:
	var south: Array = [Vector2(-232, -64), Vector2(-150, -72), Vector2(-80, -66), Vector2(-30, -70), Vector2(0, -70),
		Vector2(30, -70), Vector2(80, -74), Vector2(150, -68), Vector2(232, -76)]
	var north: Array = []
	for index in range(south.size() - 1, -1, -1):
		north.append(-south[index])
	var rivers: Array = [
		{"points": south, "width": 14.0, "fords": [{"at": Vector2(-150, -72), "half": 11.0}, {"at": Vector2(0, -70), "half": 13.0}, {"at": Vector2(150, -68), "half": 11.0}]},
		{"points": north, "width": 14.0, "fords": [{"at": Vector2(150, 72), "half": 11.0}, {"at": Vector2(0, 70), "half": 13.0}, {"at": Vector2(-150, 68), "half": 11.0}]},
	]
	var woods: Array = []
	var wood_seed := 17.2
	for wood in [[-204, -30, 12, 16], [-60, 26, 16, 12], [-40, -132, 18, 12], [-206, -176, 10, 10], [206, -176, 10, 10]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.3
	var hills: Array = [
		{"at": Vector2(-162, 24), "radii": Vector2(14, 10), "height": 8.0, "seed": 2.4},
		{"at": Vector2(162, -24), "radii": Vector2(14, 10), "height": 8.0, "seed": 2.4 + PI},
	]
	var veins: Array = []
	for side in [-1.0, 1.0]:
		_pair_point(veins, "gold", 110 * side, -118)
		_pair_point(veins, "food", 62 * side, -152)
		_pair_point(veins, "stone", 204 * side, -112)
		_pair_point(veins, "timber", 130 * side, -202)
	# The southern veins: the band between the rivers is rich in gold.
	_pair_point(veins, "gold", -60, -20)
	_pair_point(veins, "gold", -122, 20)
	var deposits: Array = []
	_pair_point(deposits, "gold", -92, 12)
	_pair_point(deposits, "stone", -40, 162)
	_pair_point(deposits, "timber", -184, 0)
	_pair_point(deposits, "food", -24, -40)
	var sites: Array = [
		{"name": "The Golden Milestone", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Muleteers' Well", "benefit": "heal", "pos": Vector3(-100, 0, -26), "model": RUIN},
		{"name": "The Legionaries' Well", "benefit": "heal", "pos": Vector3(100, 0, 26), "model": RUIN},
		{"name": "West Ford Stone", "benefit": "vision", "pos": Vector3(-152, 0, -102), "model": WATCH},
		{"name": "East Ford Stone", "benefit": "vision", "pos": Vector3(152, 0, 102), "model": WATCH},
	]
	var roads: Array = [
		Vector4(0, -212, 0, -70), Vector4(0, -70, 0, 70), Vector4(0, 70, 0, 212),
		Vector4(-160, -150, 0, -128), Vector4(160, -150, 0, -128), Vector4(160, 150, 0, 128), Vector4(-160, 150, 0, 128),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": rivers, "ridges": [], "woods": woods, "lakes": [], "hills": hills,
		"bridges": [Vector3(0, 0, -70), Vector3(0, 0, 70)],
		# Milestones beside the road.
		"ruins": [
			{"at": Vector2(12, -108), "radius": 5.0, "seed": 131}, {"at": Vector2(-12, 108), "radius": 5.0, "seed": 132},
			{"at": Vector2(12, -34), "radius": 5.0, "seed": 133}, {"at": Vector2(-12, 34), "radius": 5.0, "seed": 134},
		],
		"farmsteads": [
			{"at": Vector2(-38, -104), "yaw": 1.2}, {"at": Vector2(38, 104), "yaw": 1.2 + PI},
			{"at": Vector2(38, -104), "yaw": -1.2}, {"at": Vector2(-38, 104), "yaw": -1.2 + PI},
		],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Lume-Iron Mines (saga 4-2, "Ironmaw Rising"). 440 m across, on
## volcanic ground. The workings are cut into nine chambers by four rock
## walls, two running east to west and two north to south, and every wall
## between two chambers has one wide gate in the middle of it. A start in each
## corner chamber; the seam in the centre chamber, between two slag pits.
## Three armies cannot all hold the same gate.
static func _ironmaw_mines() -> Dictionary:
	var ridges: Array = []
	for line in [
		# The southern cross wall, with a gate into each chamber it bounds.
		[Vector2(-226, -50), Vector2(-192, -52), Vector2(-159, -50)],
		[Vector2(-117, -50), Vector2(-70, -48), Vector2(-21, -50)],
		[Vector2(21, -50), Vector2(70, -52), Vector2(117, -50)],
		[Vector2(159, -50), Vector2(192, -48), Vector2(226, -50)],
		# The western long wall.
		[Vector2(-56, -226), Vector2(-58, -190), Vector2(-56, -156)],
		[Vector2(-56, -114), Vector2(-54, -68), Vector2(-56, -21)],
		[Vector2(-56, 21), Vector2(-58, 68), Vector2(-56, 114)],
		[Vector2(-56, 156), Vector2(-54, 190), Vector2(-56, 226)],
	]:
		ridges.append({"points": line, "thickness": 10.0})
		ridges.append({"points": _twin_points(line), "thickness": 10.0})
	# Slag pits.
	var lakes: Array = [
		{"at": Vector2(-28, 26), "radii": Vector2(10, 8), "seed": 6.2}, {"at": Vector2(28, -26), "radii": Vector2(10, 8), "seed": 6.2 + PI},
		{"at": Vector2(30, -172), "radii": Vector2(16, 10), "seed": 7.4}, {"at": Vector2(-30, 172), "radii": Vector2(16, 10), "seed": 7.4 + PI},
		{"at": Vector2(-178, 30), "radii": Vector2(12, 10), "seed": 8.6}, {"at": Vector2(178, -30), "radii": Vector2(12, 10), "seed": 8.6 + PI},
	]
	var veins: Array = []
	for sign in [-1.0, 1.0]:
		_pair_point(veins, "gold", -98, 82 * sign)
		_pair_point(veins, "food", -92, 192 * sign)
		_pair_point(veins, "stone", -200, 92 * sign)
		_pair_point(veins, "timber", -198, 198 * sign)
	_pair_point(veins, "gold", -150, -16)
	var deposits: Array = []
	_pair_point(deposits, "gold", -100, 18)
	_pair_point(deposits, "stone", -22, -128)
	_pair_point(deposits, "timber", -198, -22)
	_pair_point(deposits, "food", 22, -150)
	var sites: Array = [
		{"name": "The Lume-Iron Seam", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Slave Pens", "benefit": "heal", "pos": Vector3(0, 0, -98), "model": RUIN},
		{"name": "Brasa's Forge", "benefit": "heal", "pos": Vector3(0, 0, 98), "model": RUIN},
		{"name": "West Gallery Watch", "benefit": "vision", "pos": Vector3(-96, 0, -16), "model": WATCH},
		{"name": "East Gallery Watch", "benefit": "vision", "pos": Vector3(96, 0, 16), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -56, -135), Vector4(-56, -135, 0, -100), Vector4(0, -100, 0, 0),
		Vector4(160, 150, 56, 135), Vector4(56, 135, 0, 100), Vector4(0, 100, 0, 0),
		Vector4(-160, 150, -138, 50), Vector4(-138, 50, -56, 0), Vector4(-56, 0, 0, 0),
		Vector4(160, -150, 138, -50), Vector4(138, -50, 56, 0), Vector4(56, 0, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": [], "lakes": lakes, "hills": [],
		"bridges": [],
		"ruins": [{"at": Vector2(-30, -78), "radius": 7.0, "seed": 141}, {"at": Vector2(30, 78), "radius": 7.0, "seed": 142}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Plains Before the Wall (saga 4-3, "The Bronze Legions"). 440 m across,
## desert. Open ground with low dunes and nothing to hide behind: the briefing
## says there is no clever way through, and there is none. The four starts
## stand at the four sides, not the corners, so the two the chapter uses face
## each other straight across the plain.
static func _plains_of_bronze() -> Dictionary:
	var hills: Array = []
	var dune_seed := 3.0
	for dune in [[-112, -46, 18, 10, 6.0], [-30, -72, 16, 10, 5.0], [-70, 112, 16, 12, 6.0], [150, -150, 20, 14, 8.0]]:
		hills.append({"at": Vector2(dune[0], dune[1]), "radii": Vector2(dune[2], dune[3]), "height": dune[4], "seed": dune_seed})
		hills.append({"at": Vector2(-dune[0], -dune[1]), "radii": Vector2(dune[2], dune[3]), "height": dune[4], "seed": dune_seed + PI})
		dune_seed += 1.4
	var veins: Array = []
	# Home veins for the west start, and the same turned a quarter for the south one.
	for home in [["gold", -140, -84], ["food", -140, 84], ["stone", -206, -80], ["timber", -206, 80]]:
		_pair_point(veins, home[0], home[1], home[2])
		_pair_point(veins, home[0], -home[2], home[1])
	_pair_point(veins, "gold", -60, -10)
	var deposits: Array = []
	_pair_point(deposits, "gold", -96, -96)
	_pair_point(deposits, "stone", -96, 96)
	_pair_point(deposits, "timber", -110, 24)
	_pair_point(deposits, "food", -24, -112)
	var sites: Array = [
		{"name": "The Standard of the Legions", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Surgeons' Tents", "benefit": "heal", "pos": Vector3(-62, 0, -44), "model": RUIN},
		{"name": "The Water Carts", "benefit": "heal", "pos": Vector3(62, 0, 44), "model": RUIN},
		{"name": "North Picket", "benefit": "vision", "pos": Vector3(-44, 0, 62), "model": WATCH},
		{"name": "South Picket", "benefit": "vision", "pos": Vector3(44, 0, -62), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-170, 0, 0, 0), Vector4(170, 0, 0, 0), Vector4(0, -170, 0, 0), Vector4(0, 170, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-170, 0, 0), Vector3(170, 0, 0), Vector3(0, 0, 170), Vector3(0, 0, -170)],
		"rivers": [], "ridges": [], "woods": [], "lakes": [], "hills": hills,
		"bridges": [],
		"ruins": [],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Glass Heart (saga 4-4, "Malrec's Last Offer"). 440 m across, volcanic.
## Two walls of ash-glass coil round the heart, each three quarters of a
## turn, one starting in the west and one in the east. The only ways in are
## the two mouths where a coil begins, and from a mouth the way runs a
## quarter turn between the coils before it opens on the heart.
static func _glass_heart() -> Dictionary:
	var ridges: Array = []
	for start_angle in [180.0, 0.0]:
		var line: Array = []
		for step in 19:
			var turned := 270.0 * float(step) / 18.0
			var angle := deg_to_rad(start_angle + turned)
			line.append(Vector2(cos(angle), sin(angle)) * (110.0 - 64.0 * turned / 270.0))
		ridges.append({"points": line, "thickness": 9.0})
	var lakes: Array = [
		{"at": Vector2(0, -152), "radii": Vector2(18, 12), "seed": 2.7}, {"at": Vector2(0, 152), "radii": Vector2(18, 12), "seed": 2.7 + PI},
	]
	var hills: Array = [
		{"at": Vector2(-150, 98), "radii": Vector2(14, 10), "height": 9.0, "seed": 5.9},
		{"at": Vector2(150, -98), "radii": Vector2(14, 10), "height": 9.0, "seed": 5.9 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -152)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -64, -45)
	var deposits: Array = []
	_pair_point(deposits, "gold", -18, -24)
	_pair_point(deposits, "stone", -44, 152)
	_pair_point(deposits, "timber", -112, -122)
	_pair_point(deposits, "food", -184, 40)
	var sites: Array = [
		{"name": "Malrec's Glass Heart", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Thralls' Fire", "benefit": "heal", "pos": Vector3(-112, 0, -72), "model": RUIN},
		{"name": "The Unmasked", "benefit": "heal", "pos": Vector3(112, 0, 72), "model": RUIN},
		{"name": "West Mouth Watch", "benefit": "vision", "pos": Vector3(-140, 0, 20), "model": WATCH},
		{"name": "East Mouth Watch", "benefit": "vision", "pos": Vector3(140, 0, -20), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -150, -24), Vector4(-150, -24, -88, 0), Vector4(-88, 0, -64, -45), Vector4(-64, -45, -24, -58), Vector4(-24, -58, 0, 0),
		Vector4(160, 150, 150, 24), Vector4(150, 24, 88, 0), Vector4(88, 0, 64, 45), Vector4(64, 45, 24, 58), Vector4(24, 58, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": [], "lakes": lakes, "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-176, -90), "radius": 7.0, "seed": 151}, {"at": Vector2(176, 90), "radius": 7.0, "seed": 152}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Regent's Canyons (saga 4-5, "The Sun Regent"). 440 m across, badlands.
## Six mesas stand in two rows of three. Between the rows runs the broad
## canyon where the Regent waits; between the mesas of a row run two narrow
## ones. Round the outside lies the open rim. A column in a narrow canyon
## can be met head on by very few.
static func _regents_canyon() -> Dictionary:
	var hills: Array = []
	var mesa_seed := 1.1
	for mesa in [[-96, -52], [-96, 52], [0, -52]]:
		hills.append({"at": Vector2(mesa[0], mesa[1]), "radii": Vector2(32, 27), "height": 15.0, "seed": mesa_seed})
		hills.append({"at": Vector2(-mesa[0], -mesa[1]), "radii": Vector2(32, 27), "height": 15.0, "seed": mesa_seed + PI})
		mesa_seed += 1.9
	var woods: Array = []
	var wood_seed := 18.4
	for wood in [[-30, -142, 16, 12], [-202, 60, 12, 16]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.5
	var veins: Array = []
	_pair_point(veins, "gold", -150, -66)
	_pair_point(veins, "food", -66, -156)
	_pair_point(veins, "stone", -198, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -164, 74)
	_pair_point(veins, "gold", -150, 4)
	var deposits: Array = []
	_pair_point(deposits, "gold", -30, -104)
	_pair_point(deposits, "stone", -44, 152)
	_pair_point(deposits, "timber", -160, 34)
	_pair_point(deposits, "food", -198, 6)
	var sites: Array = [
		{"name": "The Regent's Pavilion", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Legion Surgeons", "benefit": "heal", "pos": Vector3(-124, 0, -104), "model": RUIN},
		{"name": "The Mouras' Pool", "benefit": "heal", "pos": Vector3(124, 0, 104), "model": RUIN},
		{"name": "North Rim Post", "benefit": "vision", "pos": Vector3(-40, 0, 122), "model": WATCH},
		{"name": "South Rim Post", "benefit": "vision", "pos": Vector3(40, 0, -122), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -150, -30), Vector4(-150, -30, -132, 0), Vector4(-132, 0, 0, 0),
		Vector4(160, 150, 150, 30), Vector4(150, 30, 132, 0), Vector4(132, 0, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": [], "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-180, -96), "radius": 7.0, "seed": 161}, {"at": Vector2(180, 96), "radius": 7.0, "seed": 162}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Rabagao Wall (saga 4-6, both roads). 440 m across. Not a fair field,
## and not meant as one: the Wall crosses the whole map from west to east
## with three sluice gates in it, the reservoir lies behind it to the north
## in two sheets, and the lowland towns lie before it to the south. The
## Dominion and its ally hold the north; the attacker comes up from the
## lowlands and must take a gate.
static func _rabagao_wall() -> Dictionary:
	var ridges: Array = []
	for line in [
		[Vector2(-226, 22), Vector2(-182, 18), Vector2(-141, 20)],
		[Vector2(-99, 20), Vector2(-60, 23), Vector2(-21, 20)],
		[Vector2(21, 20), Vector2(60, 17), Vector2(99, 20)],
		[Vector2(141, 20), Vector2(182, 22), Vector2(226, 18)],
	]:
		ridges.append({"points": line, "thickness": 16.0})
	var lakes: Array = [
		{"at": Vector2(-64, 98), "radii": Vector2(40, 30), "seed": 4.1},
		{"at": Vector2(64, 98), "radii": Vector2(40, 30), "seed": 5.3},
	]
	var woods: Array = [
		{"at": Vector2(-204, -60), "radii": Vector2(12, 16), "seed": 19.1},
		{"at": Vector2(204, -60), "radii": Vector2(12, 16), "seed": 20.2},
		{"at": Vector2(0, 190), "radii": Vector2(18, 12), "seed": 21.3},
	]
	var veins: Array = []
	for side in [-1.0, 1.0]:
		# The lowland starts.
		veins.append({"kind": "gold", "pos": Vector3(110 * side, 0.0, -118)})
		veins.append({"kind": "food", "pos": Vector3(62 * side, 0.0, -154)})
		veins.append({"kind": "stone", "pos": Vector3(204 * side, 0.0, -112)})
		veins.append({"kind": "timber", "pos": Vector3(130 * side, 0.0, -202)})
		# The starts behind the Wall.
		veins.append({"kind": "gold", "pos": Vector3(146 * side, 0.0, 92)})
		veins.append({"kind": "food", "pos": Vector3(64 * side, 0.0, 160)})
		veins.append({"kind": "stone", "pos": Vector3(204 * side, 0.0, 112)})
		veins.append({"kind": "timber", "pos": Vector3(130 * side, 0.0, 202)})
		# Before and behind the outer gates.
		veins.append({"kind": "gold", "pos": Vector3(64 * side, 0.0, -14)})
	var deposits: Array = []
	for side in [-1.0, 1.0]:
		deposits.append({"kind": "gold", "pos": Vector3(92 * side, 0.0, -84)})
		deposits.append({"kind": "stone", "pos": Vector3(30 * side, 0.0, -156)})
		deposits.append({"kind": "timber", "pos": Vector3(200 * side, 0.0, -24)})
		deposits.append({"kind": "food", "pos": Vector3(170 * side, 0.0, 56)})
	var sites: Array = [
		{"name": "The Great Sluice", "benefit": "income", "pos": Vector3(0, 0, -16), "model": LUME},
		{"name": "The Lowland Chapel", "benefit": "heal", "pos": Vector3(-156, 0, -58), "model": RUIN},
		{"name": "The Wall Garrison", "benefit": "heal", "pos": Vector3(120, 0, 52), "model": RUIN},
		{"name": "Reservoir Watch", "benefit": "vision", "pos": Vector3(0, 0, 146), "model": WATCH},
		{"name": "Lowland Watch", "benefit": "vision", "pos": Vector3(0, 0, -128), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -120, -40), Vector4(-120, -40, -120, 48), Vector4(-120, 48, -160, 150),
		Vector4(160, -150, 120, -40), Vector4(120, -40, 120, 48), Vector4(120, 48, 160, 150),
		Vector4(0, -128, 0, -16), Vector4(0, -16, 0, 146),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": lakes, "hills": [],
		"bridges": [],
		"ruins": [],
		# The lowland towns the flood would take.
		"farmsteads": [
			{"at": Vector2(-62, -62), "yaw": 0.6}, {"at": Vector2(62, -62), "yaw": -0.6},
			{"at": Vector2(-24, -98), "yaw": 1.4}, {"at": Vector2(26, -92), "yaw": -1.2},
			{"at": Vector2(-112, -34), "yaw": 2.2}, {"at": Vector2(150, -16), "yaw": -2.0},
		],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Montalto (saga 5-2, "Montalto Besieged"). 500 m across, the largest
## field in the saga, so that a siege has time to gather. One against
## three, and built for it: the old keep stands near the middle inside a ring
## of rampart with three gates, and the three besieging armies camp round it
## a third of a turn apart, one before each gate. Each camp is nearer the
## keep than it is to either of the others. The keep's own veins lie outside
## its walls, so holding the keep is not enough to feed it.
static func _montalto() -> Dictionary:
	var keep := Vector2(0, -20)
	var ridges: Array = []
	for arc in [[104.0, 197.0, 10], [225.0, 315.0, 10], [343.0, 436.0, 10]]:
		var line: Array = []
		for step in int(arc[2]) + 1:
			var angle := deg_to_rad(lerpf(arc[0], arc[1], float(step) / float(arc[2])))
			line.append(keep + Vector2(cos(angle), sin(angle)) * 70.0)
		ridges.append({"points": line, "thickness": 9.0})
	var woods: Array = [
		{"at": Vector2(-170, 120), "radii": Vector2(18, 14), "seed": 22.4}, {"at": Vector2(170, 120), "radii": Vector2(18, 14), "seed": 23.5},
		{"at": Vector2(0, -216), "radii": Vector2(18, 10), "seed": 24.6},
	]
	var hills: Array = [
		{"at": Vector2(-216, 60), "radii": Vector2(14, 10), "height": 8.0, "seed": 3.7},
		{"at": Vector2(216, 60), "radii": Vector2(14, 10), "height": 8.0, "seed": 4.9},
	]
	var veins: Array = []
	for side in [-1.0, 1.0]:
		# The keep's veins, outside its walls.
		veins.append({"kind": "gold" if side < 0.0 else "food", "pos": Vector3(90 * side, 0.0, 30)})
		veins.append({"kind": "stone" if side < 0.0 else "timber", "pos": Vector3(50 * side, 0.0, -120)})
		# The northern camp.
		veins.append({"kind": "gold" if side < 0.0 else "food", "pos": Vector3(60 * side, 0.0, 162)})
		veins.append({"kind": "stone" if side < 0.0 else "timber", "pos": Vector3(110 * side, 0.0, 225)})
		# The south-western camp and the south-eastern one.
		veins.append({"kind": "gold", "pos": Vector3(190 * side, 0.0, -82)})
		veins.append({"kind": "food", "pos": Vector3(135 * side, 0.0, -220)})
		veins.append({"kind": "stone", "pos": Vector3(236 * side, 0.0, -60)})
		veins.append({"kind": "timber", "pos": Vector3(170 * side, 0.0, -220)})
		# Between the camps.
		veins.append({"kind": "gold", "pos": Vector3(140 * side, 0.0, 70)})
	var deposits: Array = []
	for side in [-1.0, 1.0]:
		deposits.append({"kind": "gold", "pos": Vector3(160 * side, 0.0, 10)})
		deposits.append({"kind": "stone", "pos": Vector3(30 * side, 0.0, -190)})
		deposits.append({"kind": "timber", "pos": Vector3(170 * side, 0.0, 170)})
		deposits.append({"kind": "food", "pos": Vector3(110 * side, 0.0, 115)})
	var sites: Array = [
		{"name": "The Field Before the North Gate", "benefit": "income", "pos": Vector3(0, 0, 74), "model": LUME},
		{"name": "West Sally Port", "benefit": "heal", "pos": Vector3(-82, 0, -72), "model": RUIN},
		{"name": "East Sally Port", "benefit": "heal", "pos": Vector3(82, 0, -72), "model": RUIN},
		{"name": "The South Postern Watch", "benefit": "vision", "pos": Vector3(0, 0, -142), "model": WATCH},
	]
	var roads: Array = [
		Vector4(0, -20, 0, 50), Vector4(0, 50, 0, 225),
		Vector4(0, -20, -60, -56), Vector4(-60, -56, -200, -170),
		Vector4(0, -20, 60, -56), Vector4(60, -56, 200, -170),
	]
	return {
		"size": 250.0,
		"starts": [Vector3(0, 0, -20), Vector3(0, 0, 225), Vector3(-200, 0, -170), Vector3(200, 0, -170)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-125, -25), "radius": 7.0, "seed": 171}, {"at": Vector2(125, -25), "radius": 7.0, "seed": 172}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Wolf-Trap Walls (side roads 1-S1 and, in winter, 3-S1). 440 m across.
## A fojo is a stone funnel for driving wolves into a pit. This is two of
## them mouth to mouth, an hourglass lying corner to corner: each facing
## start looks into a mouth 120 m wide that narrows to the pit at the
## centre. At the waist there is a narrow door on either side, which is the
## short way in for anyone coming from the other two corners.
static func _fojo() -> Dictionary:
	var ridges: Array = []
	for line in [
		[Vector2(-121.6, -33.9), Vector2(-70.0, -14.8), Vector2(-21.9, 2.1)],
		[Vector2(-33.9, -121.6), Vector2(-14.8, -70.0), Vector2(2.1, -21.9)],
	]:
		ridges.append({"points": line, "thickness": 10.0})
		ridges.append({"points": _twin_points(line), "thickness": 10.0})
	for line in [
		[Vector2(-120, -98), Vector2(-150, -90), Vector2(-178, -100)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 26.1
	for wood in [[-150, 30, 22, 18], [-62, -196, 18, 12], [-70, 96, 20, 22]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.3
	var hills: Array = [
		{"at": Vector2(-118, 104), "radii": Vector2(18, 13), "height": 10.0, "seed": 0.9},
		{"at": Vector2(118, -104), "radii": Vector2(18, 13), "height": 10.0, "seed": 0.9 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -52, 30)
	var deposits: Array = []
	_pair_point(deposits, "gold", -64, -52)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -120, 6)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Pit of the Fojo", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "The Drovers' Fire", "benefit": "heal", "pos": Vector3(-108, 0, -70), "model": RUIN},
		{"name": "The Wolves' Stone", "benefit": "heal", "pos": Vector3(108, 0, 70), "model": RUIN},
		{"name": "North Wall Watch", "benefit": "vision", "pos": Vector3(-40, 0, 130), "model": WATCH},
		{"name": "South Wall Watch", "benefit": "vision", "pos": Vector3(40, 0, -130), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -78, -78), Vector4(-78, -78, 0, 0), Vector4(160, 150, 78, 78), Vector4(78, 78, 0, 0),
		Vector4(-160, 150, -14, 14), Vector4(-14, 14, 0, 0), Vector4(160, -150, 14, -14), Vector4(14, -14, 0, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": [], "ridges": ridges, "woods": woods, "lakes": [], "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-160, -20), "radius": 7.0, "seed": 181}, {"at": Vector2(160, 20), "radius": 7.0, "seed": 182}],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## The Monastery of the Junias (side road 4-S2). 440 m across. A stream runs
## north to south down a valley, bridged at the monastery and fordable far
## up and far down. For 120 m either side of the bridge the valley is shut
## in by rock on both flanks, so the ruins can only be come at along the
## water, from the north end or the south. Cloister on the west bank,
## archive on the east.
static func _junias() -> Dictionary:
	var rivers: Array = [{
		"points": [Vector2(12, -234), Vector2(-4, -172), Vector2(8, -120), Vector2(-3, -40), Vector2(0, 0),
			Vector2(3, 40), Vector2(-8, 120), Vector2(4, 172), Vector2(-12, 234)],
		"width": 12.0,
		"fords": [{"at": Vector2(-4, -172), "half": 11.0}, {"at": Vector2(0, 0), "half": 12.0}, {"at": Vector2(4, 172), "half": 11.0}],
	}]
	var ridges: Array = []
	for line in [
		[Vector2(-100, -62), Vector2(-106, 0), Vector2(-100, 62)],
		[Vector2(-120, -98), Vector2(-150, -90), Vector2(-178, -100)],
	]:
		ridges.append({"points": line, "thickness": 10.0})
		ridges.append({"points": _twin_points(line), "thickness": 10.0})
	var woods: Array = []
	var wood_seed := 27.2
	for wood in [[-198, 66, 10, 14], [-62, -198, 16, 12], [-72, 112, 20, 16]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.6
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -70, -42)
	var deposits: Array = []
	_pair_point(deposits, "gold", -78, 12)
	_pair_point(deposits, "stone", -40, 150)
	_pair_point(deposits, "timber", -132, 0)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Cloister", "benefit": "income", "pos": Vector3(-34, 0, 8), "model": LUME},
		{"name": "The Archive of the Surveyors", "benefit": "income", "pos": Vector3(34, 0, -8), "model": LUME},
		{"name": "The Pilgrims' Spring", "benefit": "heal", "pos": Vector3(-60, 0, -112), "model": RUIN},
		{"name": "The Millers' Weir", "benefit": "heal", "pos": Vector3(60, 0, 112), "model": RUIN},
		{"name": "West Ridge Watch", "benefit": "vision", "pos": Vector3(-132, 0, 30), "model": WATCH},
		{"name": "East Ridge Watch", "benefit": "vision", "pos": Vector3(132, 0, -30), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -40, -112), Vector4(-40, -112, -24, -40), Vector4(-24, -40, -24, 0), Vector4(-24, 0, 24, 0),
		Vector4(160, 150, 40, 112), Vector4(40, 112, 24, 40), Vector4(24, 40, 24, 0),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": rivers, "ridges": ridges, "woods": woods, "lakes": [], "hills": [],
		"bridges": [Vector3(0, 0, 0)],
		"bridges_turned": true,
		# What stands of the monastery.
		"ruins": [
			{"at": Vector2(-52, 30), "radius": 8.0, "seed": 191}, {"at": Vector2(52, -30), "radius": 8.0, "seed": 192},
			{"at": Vector2(-56, -14), "radius": 7.0, "seed": 193}, {"at": Vector2(56, 14), "radius": 7.0, "seed": 194},
			{"at": Vector2(-30, 44), "radius": 6.0, "seed": 195}, {"at": Vector2(30, -44), "radius": 6.0, "seed": 196},
		],
		"farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}

## Rabagao Gorge (saga 2-1, "The Dam at Salto"). 440 m across. The river
## runs north to south through a gorge down the middle of the map, between
## rock walls, and the Dominion's half-built dam stands across it at the
## centre: two wings of stone with the works between them, the only crossing
## for a long way either side. Above the dam the water has begun to pool;
## below it lies the old plunge pool. A ford far to the north and one far to
## the south turn the flanks. Each pair of facing starts has the same ground.
static func _rabagao_gorge() -> Dictionary:
	var rivers: Array = [{
		"points": [Vector2(12, -234), Vector2(-4, -172), Vector2(8, -120), Vector2(-3, -40), Vector2(0, 0),
			Vector2(3, 40), Vector2(-8, 120), Vector2(4, 172), Vector2(-12, 234)],
		"width": 14.0,
		"fords": [{"at": Vector2(-4, -172), "half": 11.0}, {"at": Vector2(0, 0), "half": 17.0}, {"at": Vector2(4, 172), "half": 11.0}],
	}]
	var ridges: Array = []
	for line in [
		# The gorge walls below the dam, either side of the river.
		[Vector2(-30, -128), Vector2(-24, -90), Vector2(-27, -52)],
		[Vector2(30, -134), Vector2(36, -96), Vector2(27, -60)],
		# The dam: two wings of stone reaching in from the gorge sides.
		[Vector2(-62, -3), Vector2(-40, 2), Vector2(-17, 0)],
		# A spur that shelters each walled start from the open plateau.
		[Vector2(-120, -96), Vector2(-150, -88), Vector2(-178, -98)],
		[Vector2(-96, -200), Vector2(-92, -170), Vector2(-100, -140)],
	]:
		ridges.append({"points": line, "thickness": 9.0})
		ridges.append({"points": _twin_points(line), "thickness": 9.0})
	var woods: Array = []
	var wood_seed := 0.4
	for wood in [[-92, -40, 24, 18], [-150, 30, 26, 20], [-62, -196, 18, 14], [-70, 96, 22, 26]]:
		woods.append({"at": Vector2(wood[0], wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed})
		woods.append({"at": Vector2(-wood[0], -wood[1]), "radii": Vector2(wood[2], wood[3]), "seed": wood_seed + PI})
		wood_seed += 1.3
	# The water pooling above the dam, and the plunge pool below it.
	var lakes: Array = [
		{"at": Vector2(2, 62), "radii": Vector2(22, 30), "seed": 1.1},
		{"at": Vector2(-2, -62), "radii": Vector2(22, 30), "seed": 1.1 + PI},
	]
	var hills: Array = [
		{"at": Vector2(-118, 104), "radii": Vector2(18, 13), "height": 10.0, "seed": 0.9},
		{"at": Vector2(118, -104), "radii": Vector2(18, 13), "height": 10.0, "seed": 0.9 + PI},
	]
	var veins: Array = []
	_pair_point(veins, "gold", -150, -62)
	_pair_point(veins, "food", -62, -150)
	_pair_point(veins, "stone", -196, -40)
	_pair_point(veins, "timber", -130, -200)
	_pair_point(veins, "gold", -110, 150)
	_pair_point(veins, "food", -200, 100)
	_pair_point(veins, "stone", -60, 196)
	_pair_point(veins, "timber", -160, 70)
	_pair_point(veins, "gold", -52, 26)
	var deposits: Array = []
	_pair_point(deposits, "gold", -60, -20)
	_pair_point(deposits, "stone", -66, 162)
	_pair_point(deposits, "timber", -120, 0)
	_pair_point(deposits, "food", -196, 6)
	var sites: Array = [
		{"name": "The Dam Works", "benefit": "income", "pos": Vector3.ZERO, "model": LUME},
		{"name": "Church of Salto", "benefit": "heal", "pos": Vector3(-152, 0, -36), "model": RUIN},
		{"name": "Surveyors' Camp", "benefit": "heal", "pos": Vector3(152, 0, 36), "model": RUIN},
		{"name": "North Lookout", "benefit": "vision", "pos": Vector3(-34, 0, 148), "model": WATCH},
		{"name": "South Lookout", "benefit": "vision", "pos": Vector3(34, 0, -148), "model": WATCH},
	]
	var roads: Array = [
		Vector4(-160, -150, -100, -112), Vector4(-100, -112, -70, -16), Vector4(-70, -16, 0, 0), Vector4(-100, -112, -4, -172),
		Vector4(160, 150, 100, 112), Vector4(100, 112, 70, 16), Vector4(70, 16, 0, 0), Vector4(100, 112, 4, 172),
	]
	return {
		"size": 220.0,
		"starts": [Vector3(-160, 0, -150), Vector3(160, 0, 150), Vector3(-160, 0, 150), Vector3(160, 0, -150)],
		"rivers": rivers, "ridges": ridges, "woods": woods, "lakes": lakes, "hills": hills,
		"bridges": [],
		"ruins": [{"at": Vector2(-130, -18), "radius": 8.0, "seed": 7}, {"at": Vector2(130, 18), "radius": 8.0, "seed": 8}],
		"farmsteads": [{"at": Vector2(-126, -62), "yaw": 0.8}, {"at": Vector2(126, 62), "yaw": 0.8 + PI}],
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
