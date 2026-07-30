class_name MapDefs
## Battlefield library for Ascendant Realms. Every map shares the same world
## bounds (±MAP_SIZE) so navigation, camera and minimap stay consistent, but
## each varies its layout, player count, resource economy, objectives and a
## visual THEME (biome colour grade + water) so the 24 battlefields feel and
## play distinctly. Assembled from compact specs by parameterised generators.

const MAP_SIZE := 140.0   # half-extent; world spans -140..140

const LUME := "res://assets/environment/structures/lume_spire_ruin.glb"
const RUIN := "res://assets/environment/structures/lume_spire_ruin.glb"
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
		{"id":"hollowspan","name":"Hollowspan Crossing","theme":"highland","layout":"corners","spread":100,"rich":1.0,"cap":"triple","bridge":true},
		{"id":"ashen_vale","name":"Ashen Vale","theme":"ashen","layout":"corners","spread":96,"rich":0.9,"cap":"triple"},
		{"id":"emberfall_rift","name":"Emberfall Rift","theme":"volcanic","layout":"edges","spread":110,"rich":1.0,"cap":"triple"},
		{"id":"frostmere_basin","name":"Frostmere Basin","theme":"snow","layout":"corners","spread":102,"rich":1.0,"cap":"triple","bridge":true},
		{"id":"dune_bastion","name":"Dune Sea Bastion","theme":"desert","layout":"edges","spread":114,"rich":0.9,"cap":"single"},
		{"id":"verdant_hollows","name":"Verdant Hollows","theme":"verdant","layout":"corners","spread":84,"rich":1.1,"cap":"triple"},
		{"id":"autumn_reach","name":"Autumn Reach","theme":"autumn","layout":"corners","spread":106,"rich":1.0,"cap":"triple"},
		{"id":"mirefen","name":"Mirefen Swamp","theme":"wetland","layout":"edges","spread":100,"rich":1.0,"cap":"triple","bridge":true},
		{"id":"kaelmoor","name":"Kaelmoor Badlands","theme":"badlands","layout":"corners","spread":118,"rich":0.9,"cap":"triple"},
		{"id":"sunspire_delta","name":"Sunspire Delta","theme":"tropical","layout":"corners","spread":96,"rich":1.1,"cap":"triple","bridge":true},
		{"id":"highland_gauntlet","name":"Highland Gauntlet","theme":"highland","layout":"edges","spread":112,"rich":1.0,"cap":"single"},
		{"id":"glacier_pass","name":"Glacier Pass","theme":"snow","layout":"edges","spread":112,"rich":0.9,"cap":"triple"},
		{"id":"scorched_expanse","name":"Scorched Expanse","theme":"volcanic","layout":"corners","spread":116,"rich":0.9,"cap":"single"},
		{"id":"bloomvale","name":"Bloomvale Meadows","theme":"verdant","layout":"corners","spread":108,"rich":1.5,"cap":"triple"},
		{"id":"ruins_of_vael","name":"Ruins of Vael","theme":"ashen","layout":"corners","spread":100,"rich":1.0,"cap":"quad"},
		{"id":"redsand_canyon","name":"Redsand Canyon","theme":"desert","layout":"corners","spread":100,"rich":1.0,"cap":"triple"},
		{"id":"thornwild","name":"Thornwild Basin","theme":"autumn","layout":"corners","spread":88,"rich":1.0,"cap":"triple"},
		{"id":"duskwater","name":"Duskwater Shore","theme":"wetland","layout":"corners","spread":100,"rich":1.0,"cap":"triple","bridge":true},
		{"id":"cinderpeak","name":"Cinderpeak","theme":"volcanic","layout":"corners","spread":80,"rich":1.0,"cap":"single"},
		{"id":"iron_tundra","name":"Iron Tundra","theme":"snow","layout":"corners","spread":118,"rich":0.9,"cap":"triple"},
		{"id":"goldreach","name":"Goldreach Plateau","theme":"highland","layout":"corners","spread":104,"rich":1.5,"cap":"quad"},
		{"id":"blightmarsh","name":"Blightmarsh","theme":"wetland","layout":"edges","spread":104,"rich":0.6,"cap":"single"},
		{"id":"emerald_isles","name":"Emerald Isles","theme":"tropical","layout":"corners","spread":116,"rich":1.0,"cap":"triple","bridge":true},
		{"id":"crucible","name":"Warlord's Crucible","theme":"badlands","layout":"corners","spread":96,"rich":1.1,"cap":"quad"},
	]

# ---------------------------------------------------------------------------
# Assembly
# ---------------------------------------------------------------------------
static func _assemble(s: Dictionary) -> Dictionary:
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
	}
	var th := theme(s["theme"])
	m["water"] = th.get("water", {"enabled": false})
	if s.get("bridge", false) and m["water"].get("enabled", false):
		m["bridge"] = {"pos": Vector3(0, 0, 52), "model": BRIDGE}
	return m

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
		out.remove_at(4)
		out.remove_at(0)
	return out

static func _contested(rich: float) -> Array:
	var out := [
		{"kind": "gold", "pos": Vector3(-26, 0, -16)},
		{"kind": "gold", "pos": Vector3(26, 0, 16)},
		{"kind": "stone", "pos": Vector3(0, 0, -34)},
		{"kind": "timber", "pos": Vector3(-20, 0, 30)},
		{"kind": "timber", "pos": Vector3(20, 0, -30)},
		{"kind": "food", "pos": Vector3(0, 0, 30)},
	]
	if rich >= 1.4:
		out.append({"kind": "gold", "pos": Vector3(-46, 0, 8)})
		out.append({"kind": "gold", "pos": Vector3(46, 0, -8)})
	elif rich <= 0.7:
		return [out[0], out[1], out[2]]
	return out

static func _captures(style: String) -> Array:
	var lume := {"name": "Lume Spire", "benefit": "income", "pos": Vector3.ZERO, "model": LUME}
	match style:
		"single":
			return [lume]
		"quad":
			return [lume,
				{"name": "North Watch", "benefit": "vision", "pos": Vector3(0, 0, -48), "model": GOLD_MINE},
				{"name": "South Chapel", "benefit": "heal", "pos": Vector3(0, 0, 48), "model": RUIN},
				{"name": "West Vein", "benefit": "income", "pos": Vector3(-52, 0, 4), "model": GOLD_MINE}]
		_:  # triple
			return [lume,
				{"name": "Highland Watch", "benefit": "vision", "pos": Vector3(-42, 0, 40), "model": GOLD_MINE},
				{"name": "Ruin Chapel", "benefit": "heal", "pos": Vector3(42, 0, -40), "model": RUIN}]

# ---------------------------------------------------------------------------
# Themes — biome colour grade + atmosphere + water, all from existing textures
# ---------------------------------------------------------------------------
static func theme(name: String) -> Dictionary:
	var T := {
		"highland": {
			"ground_tint": Color(1.0, 1.0, 1.0), "dirt_bias": 0.0, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.72, 0.72, 0.70),
			"fog_color": Color(0.68, 0.72, 0.76), "fog_density": 0.00045,
			"sun_color": Color(0.96, 0.94, 0.88), "sun_energy": 1.0, "ambient_energy": 0.42,
			"decor_density": 1.0,
			"water": {"enabled": true, "deep": Color(0.05, 0.22, 0.34), "shallow": Color(0.16, 0.48, 0.58), "foam": Color(0.86, 0.95, 1.0)},
		},
		"verdant": {
			"ground_tint": Color(0.82, 1.05, 0.78), "dirt_bias": -0.05, "rock_bias": -0.05, "snow": 0.0,
			"rock_tint": Color(0.58, 0.66, 0.5),
			"fog_color": Color(0.66, 0.8, 0.62), "fog_density": 0.0018,
			"sun_color": Color(1.0, 0.98, 0.86), "sun_energy": 1.2, "ambient_energy": 0.65,
			"decor_density": 1.35,
			"water": {"enabled": true, "deep": Color(0.06, 0.3, 0.32), "shallow": Color(0.2, 0.55, 0.5), "foam": Color(0.9, 0.98, 0.95)},
		},
		"autumn": {
			"ground_tint": Color(1.18, 0.92, 0.58), "dirt_bias": 0.15, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.7, 0.6, 0.48),
			"fog_color": Color(0.85, 0.72, 0.5), "fog_density": 0.0018,
			"sun_color": Color(1.0, 0.88, 0.66), "sun_energy": 1.15, "ambient_energy": 0.6,
			"decor_density": 1.15,
			"water": {"enabled": true, "deep": Color(0.1, 0.22, 0.28), "shallow": Color(0.24, 0.44, 0.46), "foam": Color(0.92, 0.9, 0.8)},
		},
		"desert": {
			"ground_tint": Color(1.28, 1.06, 0.7), "dirt_bias": 0.5, "rock_bias": 0.12, "snow": 0.0,
			"rock_tint": Color(0.85, 0.68, 0.45),
			"fog_color": Color(0.92, 0.84, 0.62), "fog_density": 0.0012,
			"sun_color": Color(1.0, 0.95, 0.78), "sun_energy": 1.35, "ambient_energy": 0.7,
			"decor_density": 0.4,
			"water": {"enabled": false},
		},
		"badlands": {
			"ground_tint": Color(1.12, 0.86, 0.66), "dirt_bias": 0.32, "rock_bias": 0.35, "snow": 0.0,
			"rock_tint": Color(0.78, 0.55, 0.42),
			"fog_color": Color(0.82, 0.7, 0.56), "fog_density": 0.0016,
			"sun_color": Color(1.0, 0.9, 0.74), "sun_energy": 1.2, "ambient_energy": 0.6,
			"decor_density": 0.5,
			"water": {"enabled": false},
		},
		"volcanic": {
			"ground_tint": Color(0.78, 0.54, 0.5), "dirt_bias": 0.2, "rock_bias": 0.5, "snow": 0.0,
			"rock_tint": Color(0.42, 0.32, 0.32),
			"fog_color": Color(0.5, 0.3, 0.28), "fog_density": 0.0024,
			"sun_color": Color(1.0, 0.7, 0.55), "sun_energy": 0.95, "ambient_energy": 0.45,
			"decor_density": 0.4,
			"water": {"enabled": true, "lava": true, "deep": Color(0.5, 0.12, 0.03), "shallow": Color(1.0, 0.5, 0.12), "foam": Color(1.0, 0.85, 0.4)},
		},
		"snow": {
			"ground_tint": Color(0.9, 0.95, 1.05), "dirt_bias": -0.05, "rock_bias": 0.1, "snow": 0.62,
			"rock_tint": Color(0.7, 0.74, 0.8),
			"fog_color": Color(0.85, 0.9, 0.96), "fog_density": 0.0024,
			"sun_color": Color(0.9, 0.94, 1.0), "sun_energy": 1.05, "ambient_energy": 0.7,
			"decor_density": 0.6,
			"water": {"enabled": true, "deep": Color(0.12, 0.3, 0.4), "shallow": Color(0.4, 0.62, 0.72), "foam": Color(0.95, 0.98, 1.0)},
		},
		"wetland": {
			"ground_tint": Color(0.82, 0.92, 0.74), "dirt_bias": 0.22, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.55, 0.6, 0.48),
			"fog_color": Color(0.62, 0.72, 0.6), "fog_density": 0.0026,
			"sun_color": Color(0.94, 0.96, 0.82), "sun_energy": 1.05, "ambient_energy": 0.6,
			"decor_density": 1.2,
			"water": {"enabled": true, "deep": Color(0.1, 0.2, 0.14), "shallow": Color(0.22, 0.36, 0.24), "foam": Color(0.7, 0.78, 0.6)},
		},
		"tropical": {
			"ground_tint": Color(0.9, 1.05, 0.82), "dirt_bias": 0.0, "rock_bias": 0.0, "snow": 0.0,
			"rock_tint": Color(0.6, 0.64, 0.52),
			"fog_color": Color(0.7, 0.85, 0.85), "fog_density": 0.0014,
			"sun_color": Color(1.0, 0.98, 0.9), "sun_energy": 1.25, "ambient_energy": 0.7,
			"decor_density": 1.3,
			"water": {"enabled": true, "deep": Color(0.05, 0.42, 0.5), "shallow": Color(0.16, 0.72, 0.72), "foam": Color(0.9, 1.0, 1.0)},
		},
		"ashen": {
			"ground_tint": Color(0.84, 0.84, 0.88), "dirt_bias": 0.2, "rock_bias": 0.22, "snow": 0.0,
			"rock_tint": Color(0.55, 0.55, 0.58),
			"fog_color": Color(0.6, 0.6, 0.64), "fog_density": 0.0022,
			"sun_color": Color(0.88, 0.86, 0.86), "sun_energy": 0.9, "ambient_energy": 0.55,
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
