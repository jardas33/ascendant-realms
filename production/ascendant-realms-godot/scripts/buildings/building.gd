class_name Building
extends StaticBody3D
## Data-driven building: construction stages, production queue, research,
## population, defensive towers, drop-off, damage states and destruction.

signal died(building)
signal production_updated

var def := {}
var building_id := ""
var team := 0
var commander = null
var world = null

var max_hp := 1000.0
var hp := 1000.0
var armor_class := "fortified"
var base_armor := 0.0
var footprint := 4.0
## Presentation-only height envelope. GameData.footprint remains authoritative
## for placement, collision checks, rally range, and all gameplay queries.
const PRESENTATION_HEIGHT_MULTIPLIER := 1.15
const PRESENTATION_HEIGHT_MIN := 3.2
const PRESENTATION_HEIGHT_MAX := 12.0

var is_built := false
var is_dead := false
var build_progress := 0.0     # 0..1
var build_time := 30.0

# production
var queue: Array = []          # array of {id, kind:"unit"|"tech", time_left, total}
var rally_point := Vector3.ZERO
var _has_rally := false
var _last_queue_frame := -1

# tower
var _tower_cd := 0.0

# aura
var _aura_timer := 0.0

var model_root: Node3D
var selection_ring: MeshInstance3D
var _mesh_instances: Array = []
var _construct_mat: StandardMaterial3D
var _construction_stage_root: Node3D
var _construction_stage_meshes: Array = []
var _selection_visual_extents := Vector2(2.0, 2.0)
var _selection_indicator_extents := Vector2(2.2, 2.2)

func _ready() -> void:
	add_to_group("buildings")
	collision_layer = 4
	collision_mask = 0

func configure(p_def: Dictionary, p_team: int, p_commander, p_world, prebuilt: bool = false) -> void:
	def = p_def
	building_id = p_def.get("id", "")
	team = p_team
	commander = p_commander
	world = p_world
	max_hp = float(p_def.get("hp", 1000))
	armor_class = p_def.get("armor_class", "fortified")
	base_armor = float(p_def.get("armor", 0))
	footprint = float(p_def.get("footprint", 4.0))
	build_time = float(p_def.get("build_time", 30.0))
	if commander:
		build_time *= commander.build_speed_mult()
	rally_point = global_position + Vector3(0, 0, footprint + 3.0)
	_build_model()
	_build_construction_stage_visual()
	_build_selection_ring()
	if prebuilt:
		is_built = true
		build_progress = 1.0
		hp = max_hp
		_set_construction_visual(1.0)
	else:
		is_built = false
		build_progress = 0.0
		hp = max_hp * 0.15
		_set_construction_visual(0.0)

func _build_model() -> void:
	model_root = Node3D.new()
	model_root.name = "MeshRoot"
	add_child(model_root)
	var path: String = def.get("model", "")
	if path != "" and ResourceLoader.exists(path):
		var load_start := Time.get_ticks_usec()
		var m = load(path).instantiate()
		var recorder = get_node_or_null("/root/HP4M20Startup")
		if recorder and OS.get_environment("ASCENDANT_HP4_M20_DIAGNOSTICS") == "1":
			recorder.record_resource_load(path, "building._build_model", load_start, Time.get_ticks_usec(), "load_instantiate")
		model_root.add_child(m)
		# scale building to a sensible footprint-based size
		var target_h: float = _presentation_height()
		ModelUtils.scale_to_height(m, target_h)
		ModelUtils.ground_model(m)
		ModelUtils.add_per_part_convex_collision(m, 4)
		for mi in m.find_children("*", "MeshInstance3D"):
			_mesh_instances.append(mi)
	else:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		var presentation_height := _presentation_height()
		bm.size = Vector3(footprint * 1.2, presentation_height, footprint * 1.2)
		mi.mesh = bm
		mi.position.y = presentation_height * 0.5
		var mat := StandardMaterial3D.new()
		mat.albedo_color = commander.color.lerp(Color(0.5,0.5,0.5), 0.5) if commander else Color.GRAY
		mi.material_override = mat
		model_root.add_child(mi)
		_mesh_instances.append(mi)
	_add_selection_pick_shape()


func _build_construction_stage_visual() -> void:
	# Non-colliding presentation geometry only. Existing gameplay building
	# models remain authoritative; these timber frames make foundation/early
	# construction legible before the model becomes opaque.
	_construction_stage_root = Node3D.new()
	_construction_stage_root.name = "ConstructionStageVisual"
	_construction_stage_root.position.y = 0.04
	add_child(_construction_stage_root)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.34, 0.16, 0.82)
	mat.roughness = 0.92
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	var span := maxf(1.3, footprint * 0.44)
	var post_height := maxf(1.1, _presentation_height() * 0.72)
	for x in [-span, span]:
		for z in [-span, span]:
			var post := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.10
			cm.bottom_radius = 0.14
			cm.height = post_height
			post.mesh = cm
			post.position = Vector3(x, post_height * 0.5, z)
			post.material_override = mat
			post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			_construction_stage_root.add_child(post)
			_construction_stage_meshes.append(post)
	for z in [-span, span]:
		var beam := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(span * 2.0, 0.16, 0.16)
		beam.mesh = bm
		beam.position = Vector3(0, post_height, z)
		beam.material_override = mat
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		_construction_stage_root.add_child(beam)
		_construction_stage_meshes.append(beam)

func _add_selection_pick_shape() -> void:
	## Selection-only envelope for visible-footprint coverage. Its zero mask
	## keeps it out of physical interactions and navigation.
	var extents := _measure_selection_visual_extents()
	var height := maxf(1.0, footprint * 1.4)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(extents.x * 2.0, height, extents.y * 2.0)
	shape.shape = box
	shape.position.y = height * 0.5
	add_child(shape)

func _presentation_height() -> float:
	return clampf(footprint * PRESENTATION_HEIGHT_MULTIPLIER, PRESENTATION_HEIGHT_MIN, PRESENTATION_HEIGHT_MAX)

func _build_selection_ring() -> void:
	selection_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	_selection_visual_extents = _measure_selection_visual_extents()
	_selection_indicator_extents = Vector2(
		_selection_visual_extents.x * 1.12,
		_selection_visual_extents.y * 1.12)
	torus.inner_radius = 0.88
	torus.outer_radius = 1.0
	selection_ring.mesh = torus
	var mat := StandardMaterial3D.new()
	mat.albedo_color = commander.color if commander else Color.WHITE
	mat.emission_enabled = true
	mat.emission = commander.color if commander else Color.WHITE
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	selection_ring.material_override = mat
	selection_ring.position.y = 0.1
	selection_ring.scale = Vector3(_selection_indicator_extents.x, 1.0, _selection_indicator_extents.y)
	selection_ring.visible = false
	add_child(selection_ring)

func _measure_selection_visual_extents() -> Vector2:
	if not is_instance_valid(model_root):
		return Vector2(footprint * 0.7, footprint * 0.7)
	var combined := AABB()
	var first := true
	for child in model_root.find_children("*", "MeshInstance3D"):
		var mi := child as MeshInstance3D
		if not mi or not mi.mesh:
			continue
		var local_transform := model_root.global_transform.inverse() * mi.global_transform if model_root.is_inside_tree() else mi.transform
		var transformed := local_transform * mi.mesh.get_aabb()
		if first:
			combined = transformed
			first = false
		else:
			combined = combined.merge(transformed)
	if first:
		return Vector2(footprint * 0.7, footprint * 0.7)
	return Vector2(maxf(0.5, combined.size.x * 0.5), maxf(0.5, combined.size.z * 0.5))

func get_selection_geometry() -> Dictionary:
	return {
		"entity_type": "building",
		"visual_extents": {"x": _selection_visual_extents.x, "z": _selection_visual_extents.y},
		"indicator_extents": {"x": _selection_indicator_extents.x, "z": _selection_indicator_extents.y},
		"indicator_y": selection_ring.position.y if is_instance_valid(selection_ring) else 0.0,
		"indicator_scale": {"x": selection_ring.scale.x, "z": selection_ring.scale.z} if is_instance_valid(selection_ring) else {"x": 0.0, "z": 0.0},
		"selected": selection_ring.visible if is_instance_valid(selection_ring) else false,
		"collision_layer": collision_layer,
		"collision_mask": collision_mask,
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z}
	}

func set_selected(sel: bool) -> void:
	if selection_ring:
		selection_ring.visible = sel

func _set_construction_visual(p: float) -> void:
	# Keep the footprint visibly grounded while construction progresses. The old
	# full-footprint sink made unfinished structures disappear into the terrain,
	# which read as a missing building rather than a truthful construction state.
	if model_root:
		model_root.position.y = lerp(-0.15, 0.0, clamp(p, 0.0, 1.0))
	var building_now := p < 1.0
	if is_instance_valid(_construction_stage_root):
		var stage := clampf(p, 0.0, 1.0)
		_construction_stage_root.visible = stage < 0.9
		_construction_stage_root.scale.y = lerpf(0.28, 1.0, clampf(stage / 0.72, 0.0, 1.0))
		for mesh in _construction_stage_meshes:
			if is_instance_valid(mesh):
				mesh.visible = stage < 0.9
	for mi in _mesh_instances:
		if not is_instance_valid(mi):
			continue
		if building_now:
			if not (mi.material_override is StandardMaterial3D) or mi.get_meta("scaffold", false) == false:
				pass
		mi.transparency = clamp(1.0 - p, 0.0, 0.6) if building_now else 0.0

func add_build_progress(delta: float, worker) -> void:
	if is_built or is_dead:
		return
	build_progress += delta / max(0.1, build_time)
	hp = max_hp * (0.15 + 0.85 * build_progress)
	_set_construction_visual(build_progress)
	if build_progress >= 1.0:
		_complete_build()

func _complete_build() -> void:
	is_built = true
	build_progress = 1.0
	hp = max_hp
	_set_construction_visual(1.0)
	Sfx.play("build_complete", -4.0)
	if commander:
		commander.recompute_pop()
		if int(def.get("tier_unlock", 0)) > commander.tier:
			commander.tier = int(def["tier_unlock"])
	if world:
		world.on_building_completed(self)

# --------------------------------------------------------------------------
# Production
# --------------------------------------------------------------------------
func can_produce(unit_id: String) -> bool:
	return unit_id in def.get("produces", [])

func queue_unit(unit_id: String) -> Dictionary:
	if not is_built or is_dead or (world and not world.game_running):
		return {"ok": false, "reason": "Not ready"}
	if not can_produce(unit_id):
		return {"ok": false, "reason": "Not produced here"}
	if Engine.get_process_frames() == _last_queue_frame:
		return {"ok": false, "reason": "Already queued"}
	var udef := GameData.get_unit(unit_id)
	if udef.is_empty():
		return {"ok": false, "reason": "Unknown"}
	# tier gate
	if int(udef.get("tier", 1)) > commander.tier:
		return {"ok": false, "reason": "Requires higher Age"}
	if not commander.can_afford(udef.get("cost", {})):
		return {"ok": false, "reason": "Need " + commander.missing_resource(udef.get("cost", {}))}
	if not commander.reserve_pop(udef):
		return {"ok": false, "reason": "Need more housing"}
	if not commander.spend(udef.get("cost", {})):
		commander.release_reserved_pop(udef)
		return {"ok": false, "reason": "Cannot pay cost"}
	_last_queue_frame = Engine.get_process_frames()
	var t: float = float(udef.get("build_time", 15)) * commander.train_speed_mult()
	queue.append({"id": unit_id, "kind": "unit", "time_left": t, "total": t, "pop_reserved": true})
	emit_signal("production_updated")
	return {"ok": true}

func queue_tech(tech_id: String) -> Dictionary:
	if not is_built or is_dead or (world and not world.game_running):
		return {"ok": false, "reason": "Not ready"}
	if not commander.can_research(tech_id):
		return {"ok": false, "reason": "Unavailable"}
	var t := GameData.get_tech(tech_id)
	if not commander.can_afford(t.get("cost", {})):
		return {"ok": false, "reason": "Need " + commander.missing_resource(t.get("cost", {}))}
	commander.spend(t.get("cost", {}))
	commander.researching[tech_id] = true
	var time := float(t.get("time", 30))
	queue.append({"id": tech_id, "kind": "tech", "time_left": time, "total": time})
	emit_signal("production_updated")
	return {"ok": true}

func cancel_queue_item(index: int) -> void:
	if index < 0 or index >= queue.size():
		return
	var item = queue[index]
	if item["kind"] == "unit":
		var udef := GameData.get_unit(item["id"])
		commander.refund(udef.get("cost", {}), 1.0)
		if item.get("pop_reserved", false):
			commander.release_reserved_pop(udef)
	else:
		commander.refund(GameData.get_tech(item["id"]).get("cost", {}), 1.0)
		commander.researching.erase(item["id"])
	queue.remove_at(index)
	_last_queue_frame = -1
	emit_signal("production_updated")

func _process_production(delta: float) -> void:
	if is_dead or (world and not world.game_running) or queue.is_empty():
		return
	var item = queue[0]
	item["time_left"] -= delta
	if item["time_left"] <= 0.0:
		if item["kind"] == "unit":
			var spawned := _spawn_unit(item["id"])
			var udef := GameData.get_unit(item["id"])
			if item.get("pop_reserved", false):
				commander.release_reserved_pop(udef)
			if not spawned:
				commander.refund(udef.get("cost", {}), 1.0)
		else:
			commander.researching.erase(item["id"])
			commander.apply_tech(item["id"])
		queue.remove_at(0)
		emit_signal("production_updated")
	else:
		emit_signal("production_updated")

func _spawn_unit(unit_id: String) -> bool:
	if not world:
		return false
	var forward := (rally_point - global_position).normalized()
	if forward.length_squared() < 0.1:
		forward = Vector3(0, 0, 1)
	var candidates: Array[Vector3] = []
	for radius in [footprint + 1.5, footprint + 3.0, footprint + 4.5, footprint + 6.0]:
		for i in range(12):
			var angle := atan2(forward.z, forward.x) + TAU * float(i) / 12.0
			candidates.append(global_position + Vector3(cos(angle), 0, sin(angle)) * radius)
	for candidate in candidates:
		if abs(candidate.x) > MapDefs.MAP_SIZE - 4.0 or abs(candidate.z) > MapDefs.MAP_SIZE - 4.0:
			continue
		var blocked := false
		for b in world.all_buildings():
			if is_instance_valid(b) and not b.is_dead and b != self and candidate.distance_to(b.global_position) < footprint + float(b.def.get("footprint", 4.0)) * 0.75:
				blocked = true
				break
		if blocked:
			continue
		for r in world.get_tree().get_nodes_in_group("resources"):
			if is_instance_valid(r) and candidate.distance_to(r.global_position) < footprint + 1.0:
				blocked = true
				break
		if blocked:
			continue
		var u = world.spawn_unit(unit_id, team, candidate)
		if u:
			Sfx.play("ready", -6.0) if commander.is_human else null
			if _has_rally:
				u.command_move(rally_point)
			return true
	return false

func set_rally(pos: Vector3) -> void:
	rally_point = pos
	_has_rally = true

# --------------------------------------------------------------------------
# Combat / tower / aura
# --------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if is_built:
		_process_production(delta)
		if def.has("tower_dmg"):
			_tower_tick(delta)
		if def.has("heal_aura"):
			_aura_tick(delta)

func _tower_tick(delta: float) -> void:
	if _tower_cd > 0.0:
		_tower_cd -= delta
		return
	if not world:
		return
	var e = world.find_enemy_near(global_position, float(def.get("tower_range", 18.0)), team)
	if e:
		_tower_cd = float(def.get("tower_cd", 1.2))
		world.spawn_projectile(global_position + Vector3.UP * footprint,
			e, float(def.get("tower_dmg", 20)), def.get("tower_type", "pierce"),
			team, def.get("projectile", "bolt"), 0.0, null)

func _aura_tick(delta: float) -> void:
	_aura_timer += delta
	if _aura_timer < 0.5:
		return
	_aura_timer = 0.0
	if not world:
		return
	var rng := float(def.get("heal_aura_range", 16.0))
	var amt := float(def.get("heal_aura", 5.0)) * 0.5
	if commander and commander.build_flags.get("bloom_boost", false):
		rng *= 1.4
		amt *= 2.0
	world.heal_allies_near(global_position, rng, amt, team)

func cur_armor() -> float:
	return base_armor

func get_hp_ratio() -> float:
	return hp / max_hp if max_hp > 0 else 0.0

func take_damage(amount: float, from = null) -> void:
	if is_dead or (world and not world.game_running):
		return
	var source_team := -1
	if from is Dictionary:
		source_team = int(from.get("source_team", -1))
	elif is_instance_valid(from) and "team" in from:
		source_team = int(from.team)
	if source_team == team:
		return
	var hp_before := hp
	var final_damage := maxf(0.0, amount)
	hp = maxf(0.0, hp - final_damage)
	if world:
		world.on_building_damaged(self, from, hp_before, final_damage)
	_update_damage_visual()
	if hp <= 0.0:
		_destroy(from)

func _update_damage_visual() -> void:
	var ratio := get_hp_ratio()
	if ratio < 0.35:
		for mi in _mesh_instances:
			if is_instance_valid(mi):
				mi.set_instance_shader_parameter("dmg", 1.0)
				# tint darker as a simple damage cue
				if mi.material_override == null and mi.mesh:
					pass

func _destroy(from = null) -> void:
	if is_dead:
		return
	is_dead = true
	set_selected(false)
	collision_layer = 0
	set_meta("v0436_destroyed_once", true)
	# refund queue
	for i in range(queue.size() - 1, -1, -1):
		cancel_queue_item(i)
	if commander:
		commander.recompute_pop()
	emit_signal("died", self)
	if world:
		world.on_building_destroyed(self)
	# collapse animation
	var t := create_tween()
	t.set_parallel(true)
	if model_root:
		t.tween_property(model_root, "position:y", model_root.position.y - footprint, 1.2)
		t.tween_property(model_root, "scale", model_root.scale * 0.7, 1.2)
	await t.finished
	queue_free()
