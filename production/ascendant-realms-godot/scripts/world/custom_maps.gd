extends RefCounted
## Player-made battlefields from the Map Editor (plan 478).
##
## Each map is one JSON file in user://maps/. The file holds plain numbers
## (points as [x, z]) so it can be shared and read by hand. `to_authored`
## turns it into the same dictionary a hand-built map in MapDefs returns, so
## the world, the minimap, the AI and the skirmish preview treat a custom
## map exactly like the built-in authored ones.

const DIR := "user://maps"
const FORMAT := 1
const ID_PREFIX := "custom_"
const SIZES := [140.0, 180.0, 220.0]
const SIZE_NAMES := ["Small (280 m)", "Medium (360 m)", "Large (440 m)"]
const THEMES := ["highland", "verdant", "autumn", "snow", "wetland", "ashen", "volcanic", "desert", "badlands", "tropical"]
const KINDS := ["gold", "stone", "timber", "food"]
const SITE_MODELS := {
	"lume": "res://assets/environment/structures/lume_spire_ruin.glb",
	"ruin": "composed:ruin_chapel",
	"watch": "composed:highland_watch",
}
const SITE_BENEFITS := {"lume": "income", "ruin": "heal", "watch": "vision"}

static var _cache: Array = []
static var _cache_ready := false


## A blank map: two camps facing each other across the middle.
static func new_doc(name: String = "New Battlefield") -> Dictionary:
	return {
		"format": FORMAT,
		"id": "",
		"name": name,
		"theme": "highland",
		"size": 220.0,
		"starts": [{"x": -150.0, "z": -150.0, "g": 1}, {"x": 150.0, "z": 150.0, "g": 1}],
		"sites": [{"x": 0.0, "z": 0.0, "type": "lume", "name": "The Lume", "g": 2}],
		"veins": [],
		"deposits": [],
		"woods": [],
		"hills": [],
		"lakes": [],
		"ridges": [],
		"rivers": [],
		"roads": [],
		"showcase": [],
	}


## The file id for a name: lower case, letters and digits joined by "_".
static func id_for_name(name: String) -> String:
	var out := ""
	for ch in name.to_lower():
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			out += ch
		elif not out.ends_with("_"):
			out += "_"
	out = out.strip_edges().trim_prefix("_").trim_suffix("_")
	if out.is_empty():
		out = "battlefield"
	return ID_PREFIX + out.left(40)


static func path_for(id: String) -> String:
	return "%s/%s.json" % [DIR, id]


static func invalidate() -> void:
	_cache_ready = false
	_cache = []


## Every saved map as a MapDefs spec: {"id", "name", "theme", "authored":
## "custom", "data": the authored dictionary}. Read once and kept until a map
## is saved or deleted.
static func specs() -> Array:
	if _cache_ready:
		return _cache
	_cache_ready = true
	_cache = []
	var dir := DirAccess.open(DIR)
	if dir == null:
		return _cache
	var names: Array = []
	for f in dir.get_files():
		if f.ends_with(".json"):
			names.append(f)
	names.sort()
	for f in names:
		var doc := load_doc(DIR + "/" + f)
		if doc.is_empty():
			continue
		_cache.append({"id": String(doc["id"]), "name": String(doc.get("name", doc["id"])),
			"theme": String(doc.get("theme", "highland")), "authored": "custom",
			"players": (doc.get("starts", []) as Array).size(), "custom": true,
			"data": to_authored(doc)})
	return _cache


static func list_docs() -> Array:
	var out: Array = []
	for s in specs():
		out.append({"id": s["id"], "name": s["name"]})
	return out


static func load_doc(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return {}
	var doc: Dictionary = parsed
	if not doc.has("id"):
		doc["id"] = path.get_file().get_basename()
	if not String(doc["id"]).begins_with(ID_PREFIX):
		doc["id"] = ID_PREFIX + String(doc["id"])
	for key in ["starts", "sites", "veins", "deposits", "woods", "hills", "lakes", "ridges", "rivers", "roads", "showcase"]:
		if not (doc.get(key) is Array):
			doc[key] = []
	var size := float(doc.get("size", 220.0))
	doc["size"] = clampf(size, 120.0, 240.0)
	if not String(doc.get("theme", "")) in THEMES:
		doc["theme"] = "highland"
	return doc


## Saves `doc` under its name's id; returns the id ("" on failure).
static func save_doc(doc: Dictionary) -> String:
	DirAccess.make_dir_recursive_absolute(DIR)
	var id := String(doc.get("id", ""))
	if id.is_empty():
		id = id_for_name(String(doc.get("name", "")))
	doc["id"] = id
	doc["format"] = FORMAT
	var f := FileAccess.open(path_for(id), FileAccess.WRITE)
	if f == null:
		return ""
	f.store_string(JSON.stringify(doc, "\t"))
	f.close()
	invalidate()
	return id


static func delete_doc(id: String) -> void:
	if FileAccess.file_exists(path_for(id)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path_for(id)))
	invalidate()


static func _v2(p) -> Vector2:
	if p is Array and p.size() >= 2:
		return Vector2(float(p[0]), float(p[1]))
	if p is Dictionary:
		return Vector2(float(p.get("x", 0.0)), float(p.get("z", 0.0)))
	return Vector2.ZERO


static func _v3(p) -> Vector3:
	var v := _v2(p)
	return Vector3(v.x, 0.0, v.y)


## The dictionary MapDefs._assemble_authored expects from a hand-built map.
static func to_authored(doc: Dictionary) -> Dictionary:
	var size := float(doc.get("size", 220.0))
	var starts: Array = []
	for p in doc["starts"]:
		starts.append(_v3(p))
	var sites: Array = []
	for s in doc["sites"]:
		var t := String(s.get("type", "lume"))
		if not SITE_MODELS.has(t):
			t = "lume"
		sites.append({"name": String(s.get("name", "Lume Site")), "benefit": SITE_BENEFITS[t],
			"pos": _v3(s), "model": SITE_MODELS[t]})
	var veins: Array = []
	for v in doc["veins"]:
		veins.append({"kind": String(v.get("kind", "gold")), "pos": _v3(v)})
	var deposits: Array = []
	for d in doc["deposits"]:
		deposits.append({"kind": String(d.get("kind", "gold")), "pos": _v3(d)})
	var woods: Array = []
	for w in doc["woods"]:
		woods.append(_blob(w))
	var hills: Array = []
	for h in doc["hills"]:
		var hill := _blob(h)
		hill["height"] = float(h.get("height", 10.0))
		hills.append(hill)
	var lakes: Array = []
	for l in doc["lakes"]:
		lakes.append(_blob(l))
	var ridges: Array = []
	for r in doc["ridges"]:
		var pts := _points(r)
		if pts.size() < 2:
			continue
		var ridge := {"points": pts, "thickness": clampf(float(r.get("thickness", 10.0)), 4.0, 30.0)}
		if String(r.get("style", "")) == "masonry":
			ridge["style"] = "masonry"
			ridge["height"] = float(r.get("height", 6.0))
		ridges.append(ridge)
	var rivers: Array = []
	for r in doc["rivers"]:
		var pts := _points(r)
		if pts.size() < 2:
			continue
		var fords: Array = []
		for f in r.get("fords", []):
			fords.append({"at": _v2(f), "half": clampf(float(f.get("half", 10.0)), 5.0, 30.0)})
		rivers.append({"points": pts, "width": clampf(float(r.get("width", 12.0)), 6.0, 40.0), "fords": fords})
	var roads: Array = []
	for r in doc["roads"]:
		var pts := _points(r)
		for i in pts.size() - 1:
			roads.append(Vector4(pts[i].x, pts[i].y, pts[i + 1].x, pts[i + 1].y))
	var showcase: Array = []
	for s in doc.get("showcase", []):
		showcase.append({"kind": String(s.get("kind", "")), "id": String(s.get("id", "")), "pos": _v3(s),
			"yaw": float(s.get("yaw", 0.0)), "scale": float(s.get("scale", 1.0)), "team": int(s.get("team", 0))})
	return {
		"size": size,
		"starts": starts,
		"showcase": showcase,
		"rivers": rivers, "ridges": ridges, "woods": woods, "lakes": lakes, "hills": hills,
		"bridges": [], "ruins": [], "farmsteads": [],
		"veins": veins, "deposits": deposits, "sites": sites, "roads": roads,
	}


static func _blob(b: Dictionary) -> Dictionary:
	return {"at": _v2(b), "radii": Vector2(clampf(float(b.get("rx", 16.0)), 4.0, 80.0), clampf(float(b.get("rz", 16.0)), 4.0, 80.0)),
		"seed": float(b.get("seed", 1.0))}


static func _points(line: Dictionary) -> Array:
	var out: Array = []
	for p in line.get("points", []):
		out.append(_v2(p))
	return out


## What stops this map from being played, in plain words. Empty when it can.
static func problems(doc: Dictionary) -> Array:
	var out: Array = []
	var starts: Array = doc.get("starts", [])
	if starts.size() < 2:
		out.append("Place at least two camps.")
	if starts.size() > 4:
		out.append("A battlefield holds at most four camps.")
	var size := float(doc.get("size", 220.0))
	var a := to_authored(doc)
	var assembled: Dictionary = MapDefs.assemble_spec({"id": "check", "name": "check", "theme": String(doc.get("theme", "highland")), "authored": "custom", "data": a})
	for i in starts.size():
		var p := _v2(starts[i])
		if absf(p.x) > size - 30.0 or absf(p.y) > size - 30.0:
			out.append("Camp %d is too close to the edge." % (i + 1))
			continue
		for c in assembled.get("crags", []):
			var cp: Vector3 = c["pos"]
			var h: Vector2 = c["half"]
			if absf(cp.x - p.x) < h.x + 16.0 and absf(cp.z - p.y) < h.y + 16.0:
				out.append("Camp %d sits on a wood, hill, river or ridge." % (i + 1))
				break
		for j in range(i + 1, starts.size()):
			if p.distance_to(_v2(starts[j])) < 80.0:
				out.append("Camps %d and %d are too close together." % [i + 1, j + 1])
	return out
