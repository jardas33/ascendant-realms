extends Node3D

## v0.314 opt-in H3 micro-pilot. Presentation only: authoritative runtime
## state selects frames, while proxy roots remain owned by the workload runtime.

const DIRECTIONS := ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
const FAMILY_FOR_DIRECTION := {"south": 0, "south-east": 0, "east": 1, "north-east": 1, "north": 2, "north-west": 2, "west": 3, "south-west": 3}
const MIRROR_DIRECTIONS := {"north-east": true, "north-west": true, "south-west": true}
const WORKER_ATLAS := "res://assets/v0314/h3/worker_directional_animation_atlas.png"
const MILITIA_ATLAS := "res://assets/v0314/h3/militia_directional_animation_atlas.png"
const CELL_SIZE := 128
const WORKER_MAX_FRAMES := 16
const MILITIA_MAX_FRAMES := 10
const FRAME_DURATION := 0.115

var host_scene: Node
var presentation_root: Node3D
var atlas_textures: Dictionary = {}
var frame_textures: Dictionary = {}
var proxy_nodes: Dictionary = {}
var unit_animation: Dictionary = {}
var sync_count := 0
var animation_clock := 0.0
var animation_elapsed_time := 0.0
var presentation_scale := 1.0
var last_authoritative_snapshot: Dictionary = {}

func _ready() -> void:
	set_process(true)

func configure(owner_scene: Node, parent: Node3D) -> void:
	host_scene = owner_scene
	presentation_root = parent
	_load_atlases()
	sync_authoritative_units()

func _process(delta: float) -> void:
	if not visible or host_scene == null:
		return
	animation_clock += delta
	animation_elapsed_time += delta
	if animation_clock < FRAME_DURATION:
		return
	animation_clock = fmod(animation_clock, FRAME_DURATION)
	for id in unit_animation:
		var state: Dictionary = unit_animation[id]
		var count := int(state.get("frameCount", 1))
		if count <= 1:
			continue
		state["phase"] = (int(state.get("phase", 0)) + 1) % count
		unit_animation[id] = state
		_apply_frame(id, state)

func set_presentation_enabled(enabled: bool) -> void:
	visible = enabled
	for id in proxy_nodes:
		var proxy := proxy_nodes[id] as Node3D
		if proxy != null and is_instance_valid(proxy):
			proxy.visible = enabled and bool(proxy.get_meta("authoritative_visible", false))

func set_presentation_scale(scale_value: float) -> void:
	presentation_scale = clampf(scale_value, 0.70, 1.0)
	sync_authoritative_units()

func set_proof_phase(phase_value: int) -> void:
	# Capture-only seam: freezes the adapter phase so scale candidates share
	# the same authored frame without touching authoritative runtime state.
	for id in unit_animation:
		var state: Dictionary = unit_animation[id]
		state["phase"] = posmod(phase_value, max(1, int(state.get("frameCount", 1))))
		unit_animation[id] = state
		_apply_frame(id, state)

func sync_authoritative_units() -> Dictionary:
	if host_scene == null or presentation_root == null or not is_instance_valid(presentation_root):
		return {"active": false, "reason": "adapter not configured"}
	var workload = host_scene.get("runtime")
	if workload == null:
		return {"active": false, "reason": "authoritative workload runtime unavailable"}
	var seen: Dictionary = {}
	for unit in workload.units:
		var role := str(unit.get("role", ""))
		var fixture := str(unit.get("fixtureId", ""))
		var is_worker := role == "Worker"
		var is_militia := str(unit.get("team", "")) == "friendly" and fixture == "militia"
		if not is_worker and not is_militia:
			continue
		var id := str(unit.get("id", ""))
		if id == "":
			continue
		seen[id] = true
		var display_role := "Worker" if is_worker else "Militia"
		var proxy := _ensure_proxy(id, display_role)
		var runtime_position: Vector2 = unit.get("position", Vector2.ZERO)
		var world_position: Vector3 = host_scene.call("_to_world", runtime_position, 0.0)
		proxy.position = world_position
		var alive := bool(unit.get("alive", false)) and not bool(unit.get("reviewHidden", false))
		proxy.visible = alive
		proxy.set_meta("authoritative_visible", alive)
		proxy.set_meta("authoritative_position", runtime_position)
		var direction := str(unit.get("facing", "south-east"))
		if not DIRECTIONS.has(direction):
			direction = "south-east"
		var state_name := _animation_state(display_role, unit)
		var frame_count := _frame_count(display_role, state_name)
		var state: Dictionary = unit_animation.get(id, {})
		if str(state.get("state", "")) != state_name or str(state.get("direction", "")) != direction:
			state = {"role": display_role, "state": state_name, "direction": direction, "phase": 0, "frameCount": frame_count}
		unit_animation[id] = state
		proxy.set_meta("animation_state", state_name)
		proxy.set_meta("world_facing_direction", direction)
		proxy.set_meta("animation_method", "M3_AUTHORED_MULTI_FRAME_ATLAS")
		proxy.set_meta("source_card_lineage", "v0.147 Worker / v0.155 Militia")
		_apply_frame(id, state)
		var selected: bool = workload.selected_ids.has(id)
		var ring := proxy.get_node_or_null("H3SelectionRing") as MeshInstance3D
		if ring:
			ring.visible = alive and selected
			ring.scale = Vector3.ONE * (1.04 if selected else 1.0)
		var shadow := proxy.get_node_or_null("H3ContactShadow") as MeshInstance3D
		if shadow:
			shadow.visible = alive
		var fallback := presentation_root.get_node_or_null(id) as MeshInstance3D
		if fallback:
			fallback.visible = false
	for id in proxy_nodes:
		if not seen.has(id):
			(proxy_nodes[id] as Node3D).visible = false
	sync_count += 1
	last_authoritative_snapshot = {
		"unitCount": seen.size(), "unitIds": seen.keys(), "syncCount": sync_count,
		"stateSource": "runtime.units", "positionSource": "runtime.units.position",
		"facingSource": "runtime.units.facing", "animationLibraryPresent": true,
		"method": "M3_AUTHORED_MULTI_FRAME_ATLAS", "gameplayProxy": false,
	}
	return last_authoritative_snapshot.duplicate(true)

func status() -> Dictionary:
	return {
		"enabled": visible,
		"adapter": "v0.314 H3 directional animation micro-pilot",
		"roles": ["Worker", "Militia"],
		"authoritativeState": true,
		"separateSimulation": false,
		"animationMethod": "M3_AUTHORED_MULTI_FRAME_ATLAS",
		"animationLibraryPresent": true,
		"workerStates": {"idle": 4, "locomotion": 6, "work": 6},
		"militiaStates": {"idle": 4, "locomotion": 6, "ready": 0},
		"directionFamilies": 4,
		"directions": DIRECTIONS,
		"proxyCount": proxy_nodes.size(),
		"syncCount": sync_count,
		"lastSnapshot": last_authoritative_snapshot.duplicate(true),
		"rollbackAvailable": true,
		"presentationScale": presentation_scale,
		"rootMotion": false,
		"workerAnimationControllerActive": _active_role_count("Worker") > 0,
		"militiaAnimationControllerActive": _active_role_count("Militia") > 0,
		"stableUnitIds": proxy_nodes.keys(),
		"animationElapsedTime": animation_elapsed_time,
	}

func runtime_unit_snapshot(id: String) -> Dictionary:
	var state: Dictionary = unit_animation.get(id, {})
	var proxy := proxy_nodes.get(id) as Node3D
	if state.is_empty() or proxy == null or not is_instance_valid(proxy):
		return {"id": id, "present": false}
	var role := str(state.get("role", ""))
	var direction := str(state.get("direction", "south-east"))
	var phase := int(state.get("phase", 0))
	var frame_count := int(state.get("frameCount", 1))
	var sprite := proxy.get_node_or_null("H3AnimatedBillboard") as MeshInstance3D
	var fallback := presentation_root.get_node_or_null(id) as Node3D if presentation_root != null else null
	var atlas := MILITIA_ATLAS if role == "Militia" else WORKER_ATLAS
	var family := int(FAMILY_FOR_DIRECTION.get(direction, 0))
	var offset := int({"idle": 0, "locomotion": 4, "work": 10}.get(str(state.get("state", "idle")), 0))
	var frame_index := family * (WORKER_MAX_FRAMES if role == "Worker" else MILITIA_MAX_FRAMES) + offset + phase
	var atlas_texture := atlas_textures.get(role) as Texture2D
	var atlas_size := Vector2i(atlas_texture.get_width(), atlas_texture.get_height()) if atlas_texture != null else Vector2i(0, 0)
	var cell_x := frame_index % 8
	var cell_y := frame_index / 8
	var uv_min := Vector2(float(cell_x * CELL_SIZE) / float(max(1, atlas_size.x)), float(cell_y * CELL_SIZE) / float(max(1, atlas_size.y)))
	var uv_max := Vector2(float((cell_x + 1) * CELL_SIZE) / float(max(1, atlas_size.x)), float((cell_y + 1) * CELL_SIZE) / float(max(1, atlas_size.y)))
	var visual_children := 0
	var visible_visual_children := 0
	for child in proxy.get_children():
		if child is GeometryInstance3D and child.name != "H3ContactShadow" and child.name != "H3SelectionRing":
			visual_children += 1
			if child.visible:
				visible_visual_children += 1
	var material := sprite.material_override as StandardMaterial3D if sprite != null else null
	return {
		"id": id,
		"present": true,
		"role": role,
		"state": str(state.get("state", "idle")),
		"direction": direction,
		"directionFamily": family,
		"atlasIdentifier": atlas,
		"atlasCell": {"x": frame_index % 8, "y": frame_index / 8, "w": CELL_SIZE, "h": CELL_SIZE},
		"atlasDimensions": {"w": atlas_size.x, "h": atlas_size.y},
		"cellPixelRect": {"x": cell_x * CELL_SIZE, "y": cell_y * CELL_SIZE, "w": CELL_SIZE, "h": CELL_SIZE},
		"uvMin": {"x": uv_min.x, "y": uv_min.y},
		"uvMax": {"x": uv_max.x, "y": uv_max.y},
		"activeUvCoverage": (uv_max.x - uv_min.x) * (uv_max.y - uv_min.y),
		"visualChildCount": visual_children,
		"visibleVisualChildCount": visible_visual_children,
		"materialInstanceId": material.get_instance_id() if material != null else 0,
		"shaderName": "StandardMaterial3D_UV_CELL" if material != null else "",
		"regionEnabled": false,
		"hframes": 0,
		"vframes": 0,
		"frameIndex": frame_index,
		"framePhase": phase,
		"frameCount": frame_count,
		"frameDurationSeconds": FRAME_DURATION,
		"cycleDurationSeconds": float(frame_count) * FRAME_DURATION,
		"animationElapsedTime": animation_elapsed_time,
		"presentationScale": presentation_scale,
		"proxyVisible": proxy.visible,
		"spriteVisible": sprite != null and sprite.visible,
		"spriteScale": sprite.scale if sprite != null else Vector3.ZERO,
		"fallbackVisible": fallback != null and fallback.visible,
		"visibleAnimationClosure": bool(proxy.get_meta("visible_animation_closure", false)),
		"rootMotion": false,
		"authoritativePosition": proxy.get_meta("authoritative_position", Vector2.ZERO),
		"groundAnchor": {"x": 0.0, "y": 0.025},
	}

func _active_role_count(role: String) -> int:
	var count := 0
	for state in unit_animation.values():
		if str(state.get("role", "")) == role:
			count += 1
	return count

func _load_atlases() -> void:
	atlas_textures["Worker"] = load(WORKER_ATLAS) as Texture2D
	atlas_textures["Militia"] = load(MILITIA_ATLAS) as Texture2D

func _ensure_proxy(id: String, role: String) -> Node3D:
	if proxy_nodes.has(id) and is_instance_valid(proxy_nodes[id]):
		return proxy_nodes[id] as Node3D
	var root := Node3D.new()
	root.name = "v0314_h3_%s" % id
	root.set_meta("runtime_presentation_adapter", "v0.314_h3_directional_animation")
	root.set_meta("authoritative_unit_id", id)
	presentation_root.add_child(root)
	var shadow := MeshInstance3D.new()
	shadow.name = "H3ContactShadow"
	var shadow_mesh := CylinderMesh.new()
	shadow_mesh.top_radius = 0.14 if role == "Worker" else 0.16
	shadow_mesh.bottom_radius = shadow_mesh.top_radius
	shadow_mesh.height = 0.018
	shadow.mesh = shadow_mesh
	shadow.position = Vector3(0.0, 0.025, 0.0)
	shadow.scale = Vector3(1.0, 1.0, 0.62)
	shadow.material_override = _flat_material(Color(0.06, 0.07, 0.06, 0.24))
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(shadow)
	var sprite := MeshInstance3D.new()
	sprite.name = "H3AnimatedBillboard"
	var quad := QuadMesh.new()
	quad.size = Vector2(0.72 if role == "Worker" else 0.66, 1.42 if role == "Worker" else 1.28)
	sprite.mesh = quad
	sprite.position = Vector3(0.0, quad.size.y * 0.5 + 0.045, 0.0)
	sprite.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(sprite)
	var ring := MeshInstance3D.new()
	ring.name = "H3SelectionRing"
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.28 if role == "Worker" else 0.25
	ring_mesh.bottom_radius = ring_mesh.top_radius
	ring_mesh.height = 0.025
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.055, 0.0)
	ring.material_override = _flat_material(Color("#d4b268" if role == "Worker" else "#6fb79e"))
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(ring)
	proxy_nodes[id] = root
	return root

func _animation_state(role: String, unit: Dictionary) -> String:
	if role == "Worker" and str(unit.get("activityState", "idle")) == "working":
		return "work"
	if str(unit.get("activityState", "idle")) == "travelling" or str(unit.get("commandState", "idle")) == "move_ordered":
		return "locomotion"
	return "idle"

func _frame_count(role: String, state: String) -> int:
	if role == "Worker":
		return {"idle": 4, "locomotion": 6, "work": 6}.get(state, 4)
	return {"idle": 4, "locomotion": 6}.get(state, 4)

func _apply_frame(id: String, state: Dictionary) -> void:
	var proxy := proxy_nodes.get(id) as Node3D
	if proxy == null or not is_instance_valid(proxy):
		return
	var sprite := proxy.get_node_or_null("H3AnimatedBillboard") as MeshInstance3D
	if sprite == null:
		return
	var role := str(state.get("role", "Worker"))
	var direction := str(state.get("direction", "south-east"))
	var family := int(FAMILY_FOR_DIRECTION.get(direction, 0))
	var phase: int = int(state.get("phase", 0)) % max(1, int(state.get("frameCount", 1)))
	var base: int = 0
	var state_offset: int = int({"idle": 0, "locomotion": 4, "work": 10}.get(str(state.get("state", "idle")), 0))
	var frame_index: int = family * (WORKER_MAX_FRAMES if role == "Worker" else MILITIA_MAX_FRAMES) + base + state_offset + phase

	sprite.material_override = _material_for(role, frame_index)
	var mirror := bool(MIRROR_DIRECTIONS.get(direction, false))
	var closure_requested := _visible_animation_closure_requested()
	if closure_requested:
		var closure_quad := sprite.mesh as QuadMesh
		if closure_quad != null:
			var base_width := 0.72 if role == "Worker" else 0.66
			var base_height := 1.42 if role == "Worker" else 1.28
			closure_quad.size = Vector2(base_width, base_height) * presentation_scale
		sprite.scale = Vector3(-1.0 if mirror else 1.0, 1.0, 1.0)
	else:
		sprite.scale = Vector3((-1.0 if mirror else 1.0) * presentation_scale, presentation_scale, presentation_scale)
	# v0.316 evidence-only motion cue. It is deliberately a tiny visual phase
	# offset on the opt-in billboard; authoritative positions and root motion
	# remain untouched, and older checkpoints do not enable this branch.
	if closure_requested:
		var phase_wave := sin(float(phase) * PI * 0.5)
		sprite.position.y = (sprite.mesh as QuadMesh).size.y * 0.5 + 0.045 + phase_wave * 0.035
		sprite.position.x = phase_wave * 0.010
	else:
		sprite.position.y = (sprite.mesh as QuadMesh).size.y * 0.5 + 0.045
		sprite.position.x = 0.0
	proxy.set_meta("frame_index", frame_index)
	proxy.set_meta("frame_phase", phase)
	proxy.set_meta("visible_animation_closure", closure_requested)

func _visible_animation_closure_requested() -> bool:
	for arg in OS.get_cmdline_args():
		if str(arg) == "--h3-visible-animation-directional-closure" or str(arg) == "--h3-target-isolated-evidence-closure" or str(arg) == "--h3-single-sprite-atlas-rendering-repair" or str(arg) == "--h3-militia-silhouette-integrity":
			return true
	for arg in OS.get_cmdline_user_args():
		if str(arg) == "--h3-visible-animation-directional-closure" or str(arg) == "--h3-target-isolated-evidence-closure" or str(arg) == "--h3-single-sprite-atlas-rendering-repair" or str(arg) == "--h3-militia-silhouette-integrity":
			return true
	return false

func _material_for(role: String, frame_index: int) -> StandardMaterial3D:
	var key := "%s_%d" % [role, frame_index]
	if frame_textures.has(key) and is_instance_valid(frame_textures[key]):
		return frame_textures[key] as StandardMaterial3D
	var atlas := atlas_textures.get(role) as Texture2D
	if atlas == null:
		return null
	var columns := 8
	var cell_index := frame_index
	var region := Rect2((cell_index % columns) * CELL_SIZE, (cell_index / columns) * CELL_SIZE, CELL_SIZE, CELL_SIZE)
	var material := StandardMaterial3D.new()
	# The previous adapter assigned an AtlasTexture to a 3D material, but the
	# live QuadMesh still sampled the complete atlas in the runtime renderer.
	# Bind the source atlas directly and constrain the mesh UVs explicitly to
	# the active cell. This keeps the proof tied to the live billboard while
	# making neighbouring atlas cells impossible to sample.
	var atlas_width := float(max(1, atlas.get_width()))
	var atlas_height := float(max(1, atlas.get_height()))
	material.albedo_texture = atlas
	material.uv1_scale = Vector3(float(CELL_SIZE) / atlas_width, float(CELL_SIZE) / atlas_height, 1.0)
	material.uv1_offset = Vector3(region.position.x / atlas_width, region.position.y / atlas_height, 0.0)
	material.albedo_color = Color.WHITE
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame_textures[key] = material
	return material

func _flat_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
