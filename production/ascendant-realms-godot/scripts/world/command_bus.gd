extends RefCounted
## Every player order passes through here as plain data: an order type, the
## network ids of the units it moves, and a target (a position or the network
## id of a unit, building or resource). Orders run at once, exactly as before,
## and each is also kept in `history` in its serialisable form with the physics
## tick it was issued on.
##
## This is the seam for online play (docs/claude/MULTIPLAYER_READINESS.md): a
## client sends `serialize(order)` to the host, and the host runs
## `execute(deserialize(data))` in its authoritative simulation. It also makes
## a replay a list of orders.

var world
var history: Array = []
const LOG_LIMIT := 5000

var _next_net_id := 1
var _by_net_id := {}

func _init(p_world) -> void:
	world = p_world

## A stable id for anything an order can name. Assigned on first use.
func net_id(node) -> int:
	if not is_instance_valid(node):
		return 0
	if node.has_meta("net_id"):
		return int(node.get_meta("net_id"))
	var id := _next_net_id
	_next_net_id += 1
	node.set_meta("net_id", id)
	_by_net_id[id] = node
	return id

func resolve(id: int):
	var n = _by_net_id.get(id)
	return n if is_instance_valid(n) else null

## Run an order now and record it. `order` holds live references:
## {"type": String, "units": Array[Unit], "target": Node or null,
##  "pos": Vector3, "positions": Array[Vector3] (per-unit slots), "order_id": String}
## Returns what the order produced: the placed building for "place", the
## queue result for "train" and "research", whether "cast" went off.
func issue(order: Dictionary):
	var data := serialize(order)
	data["tick"] = Engine.get_physics_frames()
	history.append(data)
	if history.size() > LOG_LIMIT:
		history.pop_front()
	return execute(order)

func execute(order: Dictionary):
	var units: Array = order.get("units", [])
	var target = order.get("target")
	var pos: Vector3 = order.get("pos", Vector3.ZERO)
	var slots: Array = order.get("positions", [])
	var order_id := String(order.get("order_id", ""))
	var id := String(order.get("id", ""))
	# Orders given to a building or to the whole side.
	match String(order.get("type", "")):
		"place":
			var b = world.place_building(id, int(order.get("team", world.player_team)), pos)
			if b:
				for w in units:
					if is_instance_valid(w) and not w.is_dead:
						w.command_build(b)
			return b
		"train":
			return target.queue_unit(id) if is_instance_valid(target) else {"ok": false, "reason": "Building lost"}
		"research":
			return target.queue_tech(id) if is_instance_valid(target) else {"ok": false, "reason": "Building lost"}
		"cancel":
			if is_instance_valid(target):
				target.cancel_queue_item(int(order.get("index", 0)))
			return null
		"rally":
			if is_instance_valid(target):
				target.set_rally(pos)
			return null
		"cast":
			for h in units:
				if is_instance_valid(h) and not h.is_dead:
					return h.cast_ability(id, pos)
			return false
	var i := 0
	for u in units:
		if not is_instance_valid(u) or u.is_dead:
			i += 1
			continue
		match String(order.get("type", "")):
			"move": u.command_move(slots[i] if i < slots.size() else pos)
			"attack_move": u.command_move(pos, true, false, order_id)
			"attack":
				var t = slots[i] if i < slots.size() and is_instance_valid(slots[i]) else target
				if is_instance_valid(t):
					u.command_attack(t, order_id)
			"gather":
				if u.is_worker and is_instance_valid(target): u.command_gather(target)
			"build":
				if u.is_worker and is_instance_valid(target): u.command_build(target)
			"repair":
				if u.is_worker and is_instance_valid(target): u.command_repair(target)
			"stop": u.command_stop()
			"hold": u.command_hold()
			"patrol": u.command_patrol(pos)
		i += 1

func serialize(order: Dictionary) -> Dictionary:
	var ids: Array = []
	for u in order.get("units", []):
		ids.append(net_id(u))
	var out := {"type": String(order.get("type", "")), "units": ids}
	if order.has("target") and is_instance_valid(order["target"]):
		out["target"] = net_id(order["target"])
	if order.has("pos"):
		var p: Vector3 = order["pos"]
		out["pos"] = [p.x, p.y, p.z]
	if order.has("positions"):
		var slots: Array = []
		for s in order["positions"]:
			if s is Vector3:
				slots.append([s.x, s.y, s.z])
			else:
				slots.append(net_id(s))
		out["positions"] = slots
	if String(order.get("order_id", "")) != "":
		out["order_id"] = String(order["order_id"])
	for k in ["id", "index", "team"]:
		if order.has(k):
			out[k] = order[k]
	return out

func deserialize(data: Dictionary) -> Dictionary:
	var units: Array = []
	for id in data.get("units", []):
		var u = resolve(int(id))
		if u:
			units.append(u)
	var out := {"type": String(data.get("type", "")), "units": units, "order_id": String(data.get("order_id", ""))}
	if data.has("id"):
		out["id"] = String(data["id"])
	if data.has("index"):
		out["index"] = int(data["index"])
	if data.has("team"):
		out["team"] = int(data["team"])
	if data.has("target"):
		out["target"] = resolve(int(data["target"]))
	if data.has("pos"):
		var p: Array = data["pos"]
		out["pos"] = Vector3(float(p[0]), float(p[1]), float(p[2]))
	if data.has("positions"):
		var slots: Array = []
		for s in data["positions"]:
			if s is Array:
				slots.append(Vector3(float(s[0]), float(s[1]), float(s[2])))
			else:
				slots.append(resolve(int(s)))
		out["positions"] = slots
	return out
