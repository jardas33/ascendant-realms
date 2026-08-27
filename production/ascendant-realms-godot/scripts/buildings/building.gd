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
const BUILD_COMPLETION_CUE_SCALE := 1.045
const BUILD_COMPLETION_CUE_OUT_DURATION := 0.12
const BUILD_COMPLETION_CUE_RETURN_DURATION := 0.28
const RALLY_MARKER_COLOR := Color(1.0, 0.78, 0.30)
const RALLY_MARKER_RING_INNER_RADIUS := 0.62
const RALLY_MARKER_RING_OUTER_RADIUS := 0.78
const SPAWN_UNIT_CLEARANCE := 1.1

func _debug_review_presentation() -> bool:
	return OS.get_environment("ASCENDANT_GOLDEN_BATTLE_DEBUG_REVIEW") == "1" or OS.get_environment("ASCENDANT_HP4_M20_DIAGNOSTICS") == "1"

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
var _tower_range_ring: MeshInstance3D
var _mesh_instances: Array = []
var _construct_mat: StandardMaterial3D
var _construction_stage_root: Node3D
var _construction_stage_meshes: Array = []
var _construction_status_label: Label3D
var _construction_status_track: MeshInstance3D
var _construction_status_fill: MeshInstance3D
var _damage_status_label: Label3D
var _damage_status_track: MeshInstance3D
var _damage_status_fill: MeshInstance3D
var _completion_cue_tween: Tween
var _rally_marker: Node3D
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
	_build_damage_status_visual()
	_build_selection_ring()
	_build_tower_range_ring()
	_build_rally_marker()
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
	_update_damage_visual()

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
	_build_construction_status_visual()

func _build_construction_status_visual() -> void:
	# Keep construction progress readable from the battlefield, not only from the
	# selected-card panel. This is presentation-only and follows build_progress.
	_construction_status_label = Label3D.new()
	_construction_status_label.name = "ConstructionStatus"
	_construction_status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_construction_status_label.no_depth_test = true
	_construction_status_label.font_size = 48
	_construction_status_label.outline_size = 14
	_construction_status_label.pixel_size = 0.008
	_construction_status_label.modulate = Color(1.0, 0.92, 0.58, 1.0)
	_construction_status_label.position = Vector3(0, _presentation_height() + 1.1, 0)
	add_child(_construction_status_label)

	_construction_status_track = MeshInstance3D.new()
	_construction_status_track.name = "ConstructionProgressTrack"
	var track_mesh := BoxMesh.new()
	track_mesh.size = Vector3(maxf(1.8, footprint * 0.85), 0.09, 0.08)
	_construction_status_track.mesh = track_mesh
	var track_mat := StandardMaterial3D.new()
	track_mat.albedo_color = Color(0.08, 0.06, 0.04, 0.88)
	track_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_construction_status_track.material_override = track_mat
	_construction_status_track.position = Vector3(0, _presentation_height() + 0.78, 0)
	_construction_status_track.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_construction_status_track)

	_construction_status_fill = MeshInstance3D.new()
	_construction_status_fill.name = "ConstructionProgressFill"
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(maxf(1.8, footprint * 0.85), 0.11, 0.1)
	_construction_status_fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.95, 0.62, 0.18, 0.98)
	fill_mat.emission_enabled = true
	fill_mat.emission = Color(0.55, 0.22, 0.04)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_construction_status_fill.material_override = fill_mat
	_construction_status_fill.position = Vector3(0, _presentation_height() + 0.78, 0.055)
	_construction_status_fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_construction_status_fill)

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

func _build_tower_range_ring() -> void:
	if not def.has("tower_dmg") or not def.has("tower_range"):
		return
	_tower_range_ring = MeshInstance3D.new()
	_tower_range_ring.name = "TowerAttackRange"
	var torus := TorusMesh.new()
	var tower_range := maxf(0.5, float(def.get("tower_range", 18.0)))
	torus.inner_radius = tower_range * 0.985
	torus.outer_radius = tower_range * 1.015
	torus.rings = 64
	torus.ring_segments = 8
	_tower_range_ring.mesh = torus
	var mat := StandardMaterial3D.new()
	var team_color: Color = Color.WHITE
	if commander:
		team_color = commander.color
	mat.albedo_color = Color(team_color.r, team_color.g, team_color.b, 0.30)
	mat.emission_enabled = true
	mat.emission = team_color
	mat.emission_energy_multiplier = 1.25
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_tower_range_ring.material_override = mat
	_tower_range_ring.position.y = 0.08
	_tower_range_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_tower_range_ring.visible = false
	add_child(_tower_range_ring)

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
	if _tower_range_ring:
		_tower_range_ring.visible = sel and is_built and not is_dead
	_refresh_rally_marker(sel)

func _is_rally_capable() -> bool:
	return is_built and not is_dead and not Array(def.get("produces", [])).is_empty()

func _build_rally_marker() -> void:
	_rally_marker = Node3D.new()
	_rally_marker.name = "RallyDestinationMarker"
	_rally_marker.visible = false
	add_child(_rally_marker)

	var ring := MeshInstance3D.new()
	ring.name = "RallyGroundReticle"
	var torus := TorusMesh.new()
	torus.inner_radius = RALLY_MARKER_RING_INNER_RADIUS
	torus.outer_radius = RALLY_MARKER_RING_OUTER_RADIUS
	torus.rings = 24
	torus.ring_segments = 8
	ring.mesh = torus
	ring.position.y = 0.08
	ring.material_override = _rally_marker_material()
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_rally_marker.add_child(ring)

	var post := MeshInstance3D.new()
	post.name = "RallyBeaconPost"
	var post_mesh := CylinderMesh.new()
	post_mesh.top_radius = 0.045
	post_mesh.bottom_radius = 0.07
	post_mesh.height = 0.9
	post.mesh = post_mesh
	post.position.y = 0.52
	post.material_override = _rally_marker_material()
	post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_rally_marker.add_child(post)

	for side in [-1.0, 1.0]:
		var chevron := MeshInstance3D.new()
		chevron.name = "RallyBeaconChevron%s" % ("Left" if side < 0.0 else "Right")
		var chevron_mesh := BoxMesh.new()
		chevron_mesh.size = Vector3(0.10, 0.34, 0.10)
		chevron.mesh = chevron_mesh
		chevron.position = Vector3(side * 0.11, 0.98, 0.0)
		chevron.rotation.z = deg_to_rad(35.0 * side)
		chevron.material_override = _rally_marker_material()
		chevron.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_rally_marker.add_child(chevron)

	_update_rally_marker_position()

func _rally_marker_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = RALLY_MARKER_COLOR
	mat.emission_enabled = true
	mat.emission = RALLY_MARKER_COLOR
	mat.emission_energy_multiplier = 1.15
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat

func _update_rally_marker_position() -> void:
	if is_instance_valid(_rally_marker):
		_rally_marker.position = to_local(rally_point)

func _refresh_rally_marker(selected: bool) -> void:
	if not is_instance_valid(_rally_marker):
		return
	_update_rally_marker_position()
	_rally_marker.visible = selected and _has_rally and _is_rally_capable()

func _set_construction_visual(p: float) -> void:
	# Keep the footprint visibly grounded while construction progresses. The old
	# full-footprint sink made unfinished structures disappear into the terrain,
	# which read as a missing building rather than a truthful construction state.
	if model_root:
		model_root.position.y = lerp(-0.15, 0.0, clamp(p, 0.0, 1.0))
	var building_now := p < 1.0
	if is_instance_valid(_construction_status_label):
		# The selected card and grounded progress track are the player-facing
		# construction read. Keep the literal percentage label for explicit
		# debug/review evidence so normal play is not covered by diagnostics.
		_construction_status_label.visible = building_now and _debug_review_presentation()
		_construction_status_label.text = "BUILDING %d%%" % roundi(clampf(p, 0.0, 1.0) * 100.0)
	if is_instance_valid(_construction_status_track):
		_construction_status_track.visible = building_now
	if is_instance_valid(_construction_status_fill):
		_construction_status_fill.visible = building_now
		_construction_status_fill.scale.x = maxf(0.02, clampf(p, 0.0, 1.0))
	_construction_status_fill.position.x = (maxf(1.8, footprint * 0.85) * (clampf(p, 0.0, 1.0) - 1.0)) * 0.5
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

func _build_damage_status_visual() -> void:
	# Keep completed-building damage readable from the battlefield without a
	# persistent warning wall. Every element follows authoritative hp/max_hp.
	_damage_status_label = Label3D.new()
	_damage_status_label.name = "DamageStatus"
	_damage_status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_damage_status_label.no_depth_test = true
	_damage_status_label.font_size = 48
	_damage_status_label.outline_size = 12
	_damage_status_label.pixel_size = 0.008
	_damage_status_label.modulate = Color(1.0, 0.48, 0.32, 1.0)
	_damage_status_label.position = Vector3(0, _presentation_height() + 1.18, 0)
	_damage_status_label.text = "DAMAGED"
	_damage_status_label.visible = false
	add_child(_damage_status_label)

	var width := maxf(2.0, footprint * 0.72)
	_damage_status_track = MeshInstance3D.new()
	_damage_status_track.name = "DamageStatusTrack"
	var track_mesh := BoxMesh.new()
	track_mesh.size = Vector3(width, 0.10, 0.09)
	_damage_status_track.mesh = track_mesh
	var track_mat := StandardMaterial3D.new()
	track_mat.albedo_color = Color(0.06, 0.025, 0.02, 0.9)
	track_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_damage_status_track.material_override = track_mat
	_damage_status_track.position = Vector3(0, _presentation_height() + 0.82, 0)
	_damage_status_track.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_damage_status_track.visible = false
	add_child(_damage_status_track)

	_damage_status_fill = MeshInstance3D.new()
	_damage_status_fill.name = "DamageStatusFill"
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(width, 0.12, 0.11)
	_damage_status_fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.92, 0.16, 0.08, 0.98)
	fill_mat.emission_enabled = true
	fill_mat.emission = Color(0.45, 0.04, 0.015)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_damage_status_fill.material_override = fill_mat
	_damage_status_fill.position = Vector3(0, _presentation_height() + 0.82, 0.06)
	_damage_status_fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_damage_status_fill.visible = false
	add_child(_damage_status_fill)

func add_build_progress(delta: float, worker) -> void:
	if is_built or is_dead:
		return
	build_progress += delta / max(0.1, build_time)
	hp = max_hp * (0.15 + 0.85 * build_progress)
	_set_construction_visual(build_progress)
	if build_progress >= 1.0:
		_complete_build()

func add_repair_progress(delta: float, worker) -> void:
	if not is_built or is_dead or hp >= max_hp:
		return
	if not is_instance_valid(worker) or not worker.is_worker or worker.is_dead or worker.team != team or (worker.has_method("_is_defeated_remnant") and worker._is_defeated_remnant()) or (world and not world.game_running):
		return
	# Reuse the established construction HP work rate: the same max HP fraction
	# restored per effective build second, with no new resource economy.
	var repair_amount := max_hp * 0.85 * delta / maxf(0.1, build_time)
	hp = minf(max_hp, hp + maxf(0.0, repair_amount))
	_update_damage_visual()

func _complete_build() -> void:
	is_built = true
	build_progress = 1.0
	hp = max_hp
	_set_construction_visual(1.0)
	if is_instance_valid(selection_ring) and selection_ring.visible:
		set_selected(true)
	_play_build_completion_cue()
	Sfx.play("build_complete", -4.0)
	if commander:
		commander.recompute_pop()
		if int(def.get("tier_unlock", 0)) > commander.tier:
			commander.tier = int(def["tier_unlock"])
	if world:
		world.on_building_completed(self)
		if team == world.player_team:
			world.emit_signal("alert", "Building ready: %s" % String(def.get("name", building_id)), global_position)

func _play_build_completion_cue() -> void:
	# The construction stage and progress bar disappear at completion. A short
	# eased pulse on the existing visual root makes that state transition legible
	# without adding gameplay, collision, or persistent VFX state.
	if not is_instance_valid(model_root):
		return
	if is_instance_valid(_completion_cue_tween):
		_completion_cue_tween.kill()
	var base_scale := model_root.scale
	_completion_cue_tween = create_tween()
	_completion_cue_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_completion_cue_tween.tween_property(model_root, "scale", base_scale * BUILD_COMPLETION_CUE_SCALE, BUILD_COMPLETION_CUE_OUT_DURATION)
	_completion_cue_tween.set_ease(Tween.EASE_IN_OUT)
	_completion_cue_tween.tween_property(model_root, "scale", base_scale, BUILD_COMPLETION_CUE_RETURN_DURATION)

# --------------------------------------------------------------------------
# Production
# --------------------------------------------------------------------------
func can_produce(unit_id: String) -> bool:
	return unit_id in def.get("produces", [])

func queue_unit(unit_id: String) -> Dictionary:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running):
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
		return {"ok": false, "reason": commander.missing_resource_summary(udef.get("cost", {}))}
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
	var t := GameData.get_tech(tech_id)
	if t.is_empty():
		return {"ok": false, "reason": "Unavailable"}
	# The HUD lists only authored research entries, but this method is also an
	# authoritative command boundary for stale/direct callers. Keep ordinary
	# upgrades on their owning research Building and tier advances on the HQ.
	if t.get("kind", "") == "tier":
		if not def.get("is_hq", false) and def.get("kind", "") != "main":
			return {"ok": false, "reason": "Unavailable"}
	elif tech_id not in def.get("research", []):
		return {"ok": false, "reason": "Unavailable"}
	if not commander.can_research(tech_id):
		return {"ok": false, "reason": "Unavailable"}
	if not commander.can_afford(t.get("cost", {})):
		return {"ok": false, "reason": commander.missing_resource_summary(t.get("cost", {}))}
	commander.spend(t.get("cost", {}))
	commander.researching[tech_id] = true
	var time := float(t.get("time", 30))
	queue.append({"id": tech_id, "kind": "tech", "time_left": time, "total": time})
	emit_signal("production_updated")
	return {"ok": true}

func cancel_queue_item(index: int) -> void:
	if is_dead or (world and not world.game_running) or (world and team != world.player_team):
		return
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
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running) or queue.is_empty():
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
			elif world and team == world.player_team:
				var spawned_unit_name := String(udef.get("name", item["id"]))
				world.emit_signal("alert", "Unit ready: %s" % spawned_unit_name, global_position)
		else:
			var completed_tech_id: String = String(item["id"])
			commander.researching.erase(completed_tech_id)
			commander.apply_tech(completed_tech_id)
			if world and team == world.player_team:
				var completed_tech_name := String(GameData.get_tech(completed_tech_id).get("name", completed_tech_id))
				world.emit_signal("alert", "Research complete: %s" % completed_tech_name, global_position)
		queue.remove_at(0)
		emit_signal("production_updated")
	else:
		emit_signal("production_updated")

func _spawn_unit(unit_id: String) -> bool:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running) or not world:
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
		# Repeated completions from the same producer begin with the same forward
		# candidate. Reject live Unit occupancy so rapid production advances to the
		# next radial candidate instead of stacking runtime bodies exactly.
		if world.has_method("all_units"):
			for u in world.all_units():
				if is_instance_valid(u) and not u.is_dead and candidate.distance_to(u.global_position) < SPAWN_UNIT_CLEARANCE:
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
	if not _is_rally_capable() or (commander and commander.defeated) or (world and not world.game_running) or (world and team != world.player_team):
		return
	rally_point = world.clamp_to_playable_bounds(pos) if world and world.has_method("clamp_to_playable_bounds") else pos
	_has_rally = true
	_refresh_rally_marker(is_instance_valid(selection_ring) and selection_ring.visible)

# --------------------------------------------------------------------------
# Combat / tower / aura
# --------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if is_dead or (commander and commander.defeated):
		return
	if is_built:
		_process_production(delta)
		# Match terminality stops new autonomous gameplay while preserving the
		# existing death/collapse/cleanup lifecycle above this shared branch.
		if world == null or not world.game_running:
			return
		if def.has("tower_dmg"):
			_tower_tick(delta)
		if def.has("heal_aura"):
			_aura_tick(delta)

func _tower_tick(delta: float) -> void:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running):
		return
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
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running):
		return
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
	var damaged := is_built and not is_dead and ratio < 0.99
	if is_instance_valid(_damage_status_label):
		_damage_status_label.visible = damaged
	if is_instance_valid(_damage_status_track):
		_damage_status_track.visible = damaged
	if is_instance_valid(_damage_status_fill):
		var width := maxf(2.0, footprint * 0.72)
		_damage_status_fill.visible = damaged
		_damage_status_fill.scale.x = maxf(0.02, ratio)
		_damage_status_fill.position.x = width * (clampf(ratio, 0.0, 1.0) - 1.0) * 0.5
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
	# Retire the existing damage-status presentation at the same logical
	# boundary as destruction. Without this refresh, a dead building can retain
	# a stale live damage bar while its collapse cue is still playing.
	_update_damage_visual()
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
