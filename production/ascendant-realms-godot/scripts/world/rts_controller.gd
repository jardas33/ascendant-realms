extends Node3D
## RTSController — camera rig + selection + command input for the human player.
## Attach as a child of game_world. Emits selection changes for the HUD.

signal selection_changed(units: Array)
signal build_mode_changed(active: bool, building_id: String)
signal camera_moved

@export var edge_scroll := true

var world = null
var player_team := 0

# camera
var cam_pivot: Node3D
var cam_arm: SpringArm3D
var camera: Camera3D
var _cam_yaw := 0.0
var _zoom := 55.0
const ZOOM_MIN := 25.0
const ZOOM_MAX := 95.0
var cam_speed := 42.0
var zoom_sens := 1.0
var _reduce_shake := false

# selection
var selected: Array = []
var _dragging := false
var _drag_start := Vector2.ZERO
var _drag_now := Vector2.ZERO
var select_box: Panel

# control groups
var _groups := {}          # int -> Array[Unit]

# build placement
var _build_id := ""
var _build_ghost: Node3D = null
var _build_valid := false

# commands
var _last_click_time := 0.0
var _last_clicked = null

func setup(p_world, p_team: int) -> void:
	world = p_world
	player_team = p_team
	_apply_settings()
	_build_camera()
	_build_select_box()
	# center on player base
	if world.commanders.size() > player_team:
		var hqpos := _player_hq_pos()
		cam_pivot.global_position = hqpos

func _apply_settings() -> void:
	var s = ProfileManager.settings()
	edge_scroll = s.get("edge_scroll", true)
	cam_speed = 42.0 * float(s.get("camera_speed", 1.0))
	zoom_sens = float(s.get("zoom_sens", 1.0))
	_reduce_shake = s.get("reduce_shake", false)

func _player_hq_pos() -> Vector3:
	for b in world.commanders[player_team].buildings:
		if is_instance_valid(b) and b.def.get("is_hq", false):
			return b.global_position
	return Vector3.ZERO

func _build_camera() -> void:
	cam_pivot = Node3D.new()
	cam_pivot.name = "CamPivot"
	add_child(cam_pivot)
	cam_arm = SpringArm3D.new()
	cam_arm.name = "CamArm"
	cam_arm.spring_length = _zoom
	cam_arm.rotation_degrees = Vector3(-55, 0, 0)
	cam_arm.collision_mask = 0
	cam_pivot.add_child(cam_arm)
	camera = Camera3D.new()
	camera.name = "RTSCamera"
	camera.fov = 55.0
	camera.far = 500.0
	cam_arm.add_child(camera)
	camera.current = true

func _build_select_box() -> void:
	select_box = Panel.new()
	select_box.name = "SelectBox"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.3, 0.8, 0.4, 0.15)
	sb.border_color = Color(0.4, 0.9, 0.5, 0.9)
	sb.set_border_width_all(2)
	select_box.add_theme_stylebox_override("panel", sb)
	select_box.visible = false
	select_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	layer.add_child(select_box)

# --------------------------------------------------------------------------
func _process(delta: float) -> void:
	_update_camera(delta)
	if _build_id != "":
		_update_build_ghost()
	if _dragging:
		_update_drag_box()

func _update_camera(delta: float) -> void:
	var dir := Vector3.ZERO
	if Input.is_action_pressed("cam_up"): dir.z -= 1
	if Input.is_action_pressed("cam_down"): dir.z += 1
	if Input.is_action_pressed("cam_left"): dir.x -= 1
	if Input.is_action_pressed("cam_right"): dir.x += 1
	# edge scroll
	if edge_scroll and not _dragging:
		var mp := get_viewport().get_mouse_position()
		var vs := get_viewport().get_visible_rect().size
		var m := 12.0
		if mp.x < m: dir.x -= 1
		elif mp.x > vs.x - m: dir.x += 1
		if mp.y < m: dir.z -= 1
		elif mp.y > vs.y - m: dir.z += 1
	if dir != Vector3.ZERO:
		dir = dir.normalized().rotated(Vector3.UP, _cam_yaw)
		cam_pivot.global_position += dir * cam_speed * delta
		var lim := MapDefs.MAP_SIZE
		cam_pivot.global_position.x = clamp(cam_pivot.global_position.x, -lim, lim)
		cam_pivot.global_position.z = clamp(cam_pivot.global_position.z, -lim, lim)
		emit_signal("camera_moved")
	# rotate
	if Input.is_action_pressed("cam_rot_l"):
		_cam_yaw += 1.5 * delta
	if Input.is_action_pressed("cam_rot_r"):
		_cam_yaw -= 1.5 * delta
	cam_pivot.rotation.y = _cam_yaw
	# smooth zoom
	cam_arm.spring_length = lerp(cam_arm.spring_length, _zoom, 0.2)

func focus_on(pos: Vector3) -> void:
	cam_pivot.global_position = Vector3(pos.x, 0, pos.z)

# --------------------------------------------------------------------------
# Input
# --------------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if world == null or not world.game_running:
		return
	if event is InputEventMouseButton:
		_handle_mouse_button(event)
	elif event is InputEventMouseMotion and _dragging:
		_drag_now = event.position
	elif event is InputEventKey and event.pressed and not event.echo:
		_handle_key(event)

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		_zoom = clamp(_zoom - 5.0 * zoom_sens, ZOOM_MIN, ZOOM_MAX)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_zoom = clamp(_zoom + 5.0 * zoom_sens, ZOOM_MIN, ZOOM_MAX)
	elif event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _build_id != "":
				_try_place_building()
			else:
				_dragging = true
				_drag_start = event.position
				_drag_now = event.position
		else:
			if _dragging:
				_dragging = false
				_finish_drag_selection(event.shift_pressed)
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if _build_id != "":
			cancel_build_mode()
		else:
			_issue_context_command(event.shift_pressed)

func _handle_key(event: InputEventKey) -> void:
	var kc := event.keycode
	if event.ctrl_pressed and kc >= KEY_1 and kc <= KEY_5:
		_assign_group(kc - KEY_1 + 1)
		return
	if Input.is_action_just_pressed("cmd_attack"): _begin_attack_move()
	elif Input.is_action_just_pressed("cmd_stop"): _cmd_stop()
	elif Input.is_action_just_pressed("cmd_hold"): _cmd_hold()
	elif Input.is_action_just_pressed("cmd_patrol"): _cmd_patrol_prompt()
	elif Input.is_action_just_pressed("cmd_guard"): pass
	elif Input.is_action_just_pressed("idle_worker"): _select_idle_worker()
	elif Input.is_action_just_pressed("cycle_hero"): _cycle_hero()
	elif Input.is_action_just_pressed("select_army"): _select_army()
	elif kc >= KEY_1 and kc <= KEY_5:
		_recall_group(kc - KEY_1 + 1)
	# ability hotkeys
	elif Input.is_action_just_pressed("ability_1"): _queue_ability("rally")
	elif Input.is_action_just_pressed("ability_2"): _queue_ability("slam")
	elif Input.is_action_just_pressed("ability_3"): _queue_ability("charge")
	elif Input.is_action_just_pressed("ability_4"): _queue_ability("bolt")

# --------------------------------------------------------------------------
# Selection
# --------------------------------------------------------------------------
func _update_drag_box() -> void:
	var tl := Vector2(min(_drag_start.x, _drag_now.x), min(_drag_start.y, _drag_now.y))
	var size := (_drag_now - _drag_start).abs()
	select_box.position = tl
	select_box.size = size
	select_box.visible = size.length() > 6.0

func _finish_drag_selection(additive: bool) -> void:
	select_box.visible = false
	var drag_dist := (_drag_now - _drag_start).length()
	if drag_dist < 8.0:
		_single_click_select(additive)
		return
	# box select all player units in rectangle
	var rect := Rect2(Vector2(min(_drag_start.x, _drag_now.x), min(_drag_start.y, _drag_now.y)),
		(_drag_now - _drag_start).abs())
	if not additive:
		_clear_selection()
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead or u.team != player_team:
			continue
		var sp: Vector2 = camera.unproject_position(u.global_position + Vector3.UP)
		if rect.has_point(sp) and not camera.is_position_behind(u.global_position):
			_add_to_selection(u)
	# prefer non-workers when box contains both
	_prune_workers_if_mixed()
	emit_signal("selection_changed", selected)

func _single_click_select(additive: bool) -> void:
	var hit = _raycast_object()
	var now := Time.get_ticks_msec() / 1000.0
	if hit and (hit is Unit) and hit.team == player_team:
		# double-click: select all same type on screen
		if _last_clicked == hit and now - _last_click_time < 0.35:
			_select_same_type_on_screen(hit)
		else:
			if not additive:
				_clear_selection()
			if hit in selected:
				_remove_from_selection(hit)
			else:
				_add_to_selection(hit)
			Sfx.play("select", -10.0)
		_last_clicked = hit
		_last_click_time = now
	elif hit and (hit is Building) and hit.team == player_team:
		if not additive:
			_clear_selection()
		_add_to_selection(hit)
		Sfx.play("select", -10.0)
	else:
		if not additive:
			_clear_selection()
	emit_signal("selection_changed", selected)

func _select_same_type_on_screen(proto) -> void:
	_clear_selection()
	var vs := get_viewport().get_visible_rect().size
	var screen := Rect2(Vector2.ZERO, vs)
	for u in world.all_units():
		if not is_instance_valid(u) or u.is_dead or u.team != player_team:
			continue
		if u.unit_id == proto.unit_id:
			var sp: Vector2 = camera.unproject_position(u.global_position)
			if screen.has_point(sp):
				_add_to_selection(u)

func _prune_workers_if_mixed() -> void:
	var has_combat := false
	for u in selected:
		if is_instance_valid(u) and (u is Unit) and not u.is_worker:
			has_combat = true
			break
	if has_combat:
		var filtered := []
		for u in selected:
			if (u is Unit) and u.is_worker:
				u.set_selected(false)
			else:
				filtered.append(u)
		selected = filtered

func _add_to_selection(u) -> void:
	if u in selected:
		return
	selected.append(u)
	u.set_selected(true)

func _remove_from_selection(u) -> void:
	selected.erase(u)
	if is_instance_valid(u):
		u.set_selected(false)

func _clear_selection() -> void:
	for u in selected:
		if is_instance_valid(u):
			u.set_selected(false)
	selected.clear()

func _clean_selection() -> void:
	var valid := []
	for u in selected:
		if is_instance_valid(u) and not (("is_dead" in u) and u.is_dead):
			valid.append(u)
	selected = valid

# --------------------------------------------------------------------------
# Commands
# --------------------------------------------------------------------------
func _issue_context_command(queue: bool) -> void:
	_clean_selection()
	if selected.is_empty():
		return
	var hit = _raycast_object()
	var ground = _raycast_ground()
	# selected building -> set rally
	if selected.size() == 1 and (selected[0] is Building):
		if ground != null:
			selected[0].set_rally(ground)
			world.spawn_ring_fx(ground, world.player_commander.color, 1.5)
		return
	var units := _selected_units()
	if hit and ("team" in hit):
		if hit.team != player_team:
			# attack enemy through the same public path used by deterministic capture.
			issue_attack_target(hit)
			return
		elif (hit is ResourceNode):
			pass
	if hit and (hit is ResourceNode):
		for u in units:
			if u.is_worker:
				u.command_gather(hit)
		return
	if hit and (hit is Building) and hit.team == player_team and not hit.is_built:
		for u in units:
			if u.is_worker:
				u.command_build(hit)
		return
	if ground != null:
		_formation_move(units, ground)
		world.spawn_ring_fx(ground, world.player_commander.color, 1.0)

func issue_attack_target(target) -> bool:
	_clean_selection()
	if not is_instance_valid(target) or not ("team" in target) or int(target.team) == player_team:
		return false
	var issued := false
	for u in _selected_units():
		if u.has_method("command_attack"):
			u.command_attack(target)
			issued = u.state == Unit.State.ATTACKING or issued
	if issued and world:
		world.spawn_ring_fx(target.global_position, Color(0.9, 0.3, 0.3), 1.2)
	return issued

func _formation_move(units: Array, target: Vector3) -> void:
	if units.size() <= 1:
		if units.size() == 1:
			units[0].command_move(target)
		return
	# grid formation around target
	var cols := int(ceil(sqrt(units.size())))
	var spacing := 2.4
	var i := 0
	for u in units:
		var row := i / cols
		var col := i % cols
		var offset := Vector3((col - cols/2.0) * spacing, 0, (row - cols/2.0) * spacing)
		u.command_move(target + offset)
		i += 1

func _begin_attack_move() -> void:
	var ground = _raycast_ground()
	if ground != null:
		issue_attack_move_destination(ground)
		world.spawn_ring_fx(ground, Color(0.9,0.4,0.3), 1.2)

func issue_attack_move_destination(destination: Vector3) -> bool:
	var issued := false
	for u in _selected_units():
		u.command_move(destination, true)
		issued = true
	return issued

func _cmd_stop() -> void:
	issue_stop()

func issue_stop() -> bool:
	var issued := false
	for u in _selected_units():
		u.command_stop()
		issued = true
	return issued

func _cmd_hold() -> void:
	for u in _selected_units():
		u.command_hold()

func _cmd_patrol_prompt() -> void:
	var ground = _raycast_ground()
	if ground != null:
		for u in _selected_units():
			u.command_patrol(ground)

func _selected_units() -> Array:
	var out := []
	for u in selected:
		if is_instance_valid(u) and (u is Unit) and not u.is_dead:
			out.append(u)
	return out

# --------------------------------------------------------------------------
# Abilities
# --------------------------------------------------------------------------
func _queue_ability(id: String) -> void:
	var hero = _selected_hero()
	if not hero:
		hero = world.player_commander.hero_ref
	if not is_instance_valid(hero) or hero.is_dead:
		return
	if not hero.abilities.has(id):
		return
	var ground = _raycast_ground()
	var target_pos = ground if ground != null else hero.global_position
	# some abilities target enemy pos under cursor
	var hit = _raycast_object()
	if hit and ("global_position" in hit):
		target_pos = hit.global_position
	hero.cast_ability(id, target_pos)

func _selected_hero():
	for u in selected:
		if is_instance_valid(u) and (u is Unit) and u.is_hero:
			return u
	return null

# --------------------------------------------------------------------------
# Control groups & quick selects
# --------------------------------------------------------------------------
func _assign_group(n: int) -> void:
	var g := []
	for u in _selected_units():
		g.append(u)
	_groups[n] = g

func _recall_group(n: int) -> void:
	if not _groups.has(n):
		return
	_clear_selection()
	for u in _groups[n]:
		if is_instance_valid(u) and not u.is_dead:
			_add_to_selection(u)
	emit_signal("selection_changed", selected)
	# center camera on group
	if not selected.is_empty():
		focus_on(selected[0].global_position)

func _select_idle_worker() -> void:
	for u in world.commanders[player_team].units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state == u.State.IDLE:
			_clear_selection()
			_add_to_selection(u)
			focus_on(u.global_position)
			emit_signal("selection_changed", selected)
			return

func _cycle_hero() -> void:
	var hero = world.commanders[player_team].hero_ref
	if is_instance_valid(hero) and not hero.is_dead:
		_clear_selection()
		_add_to_selection(hero)
		focus_on(hero.global_position)
		emit_signal("selection_changed", selected)

func _select_army() -> void:
	_clear_selection()
	for u in world.commanders[player_team].units:
		if is_instance_valid(u) and not u.is_dead and not u.is_worker:
			_add_to_selection(u)
	emit_signal("selection_changed", selected)

# --------------------------------------------------------------------------
# Build mode
# --------------------------------------------------------------------------
func enter_build_mode(building_id: String) -> void:
	cancel_build_mode()
	_build_id = building_id
	var bdef := GameData.get_building(building_id)
	# ghost
	_build_ghost = Node3D.new()
	add_child(_build_ghost)
	var path: String = bdef.get("model", "")
	if path != "" and ResourceLoader.exists(path):
		var m = load(path).instantiate()
		_build_ghost.add_child(m)
		ModelUtils.scale_to_height(m, float(bdef.get("footprint", 4.0)) * 1.4)
		ModelUtils.ground_model(m)
	var ring := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = float(bdef.get("footprint", 4.0))
	cyl.bottom_radius = float(bdef.get("footprint", 4.0))
	cyl.height = 0.2
	ring.mesh = cyl
	_ghost_mat = StandardMaterial3D.new()
	_ghost_mat.albedo_color = Color(0.3, 0.9, 0.4, 0.4)
	_ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = _ghost_mat
	_build_ghost.add_child(ring)
	emit_signal("build_mode_changed", true, building_id)

var _ghost_mat: StandardMaterial3D

func cancel_build_mode() -> void:
	_build_id = ""
	if is_instance_valid(_build_ghost):
		_build_ghost.queue_free()
	_build_ghost = null
	emit_signal("build_mode_changed", false, "")

func _update_build_ghost() -> void:
	var g = _raycast_ground()
	if g == null or not is_instance_valid(_build_ghost):
		return
	_build_ghost.global_position = g
	_build_valid = _is_build_spot_valid(g)
	if _ghost_mat:
		_ghost_mat.albedo_color = Color(0.3, 0.9, 0.4, 0.4) if _build_valid else Color(0.9, 0.3, 0.3, 0.4)

func _is_build_spot_valid(pos: Vector3) -> bool:
	var bdef := GameData.get_building(_build_id)
	if bdef.is_empty() or not world or not is_instance_valid(world.player_commander):
		return false
	return world.can_place_building(_build_id, player_team, pos, true)

func _try_place_building() -> void:
	var g = _raycast_ground()
	if g == null:
		return
	if not _is_build_spot_valid(g):
		Sfx.play("select", -14.0)
		return
	var bid := _build_id
	var cmd = world.commanders[player_team]
	if not cmd.can_afford(GameData.get_building(bid).get("cost", {})):
		cancel_build_mode()
		return
	var b = world.place_building(bid, player_team, g)
	if b:
		# assign a selected worker (or nearest) to build it
		var worker = _nearest_free_worker(g)
		if worker:
			worker.command_build(b)
		Sfx.play("select", -6.0)
	# stay in build mode if shift held for multiple
	if not Input.is_key_pressed(KEY_SHIFT):
		cancel_build_mode()

func _nearest_free_worker(pos: Vector3):
	# prefer a selected worker
	for u in _selected_units():
		if u.is_worker:
			return u
	var best = null
	var best_d := INF
	for u in world.commanders[player_team].units:
		if is_instance_valid(u) and not u.is_dead and u.is_worker and u.state != u.State.BUILDING:
			var d = pos.distance_squared_to(u.global_position)
			if d < best_d:
				best_d = d
				best = u
	return best

# --------------------------------------------------------------------------
# Raycasts
# --------------------------------------------------------------------------
func _raycast_ground():
	var mp := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mp)
	var dir := camera.project_ray_normal(mp)
	if abs(dir.y) < 0.0001:
		return null
	var t := -from.y / dir.y
	if t < 0:
		return null
	return from + dir * t

func _raycast_object():
	var mp := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mp)
	var to := from + camera.project_ray_normal(mp) * 1000.0
	var space := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(from, to, 2 | 4 | 8)  # units|buildings|resources
	var r := space.intersect_ray(q)
	if r.is_empty():
		return null
	var col = r.collider
	# climb to owner node with team
	var n = col
	while n and not (n is Unit) and not (n is Building) and not (n is ResourceNode):
		n = n.get_parent()
	return n
