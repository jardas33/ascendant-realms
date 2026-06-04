extends Node3D

const MODE := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"
const WorkloadRuntimeScript = preload("res://scripts/salto_spike_workload_runtime.gd")

var runtime = WorkloadRuntimeScript.new()
var visual_root: Node3D
var camera_panned := false
var camera_zoomed := false

func _ready() -> void:
	_create_camera()
	_create_light()
	_create_terrain()
	visual_root = Node3D.new()
	visual_root.name = "RepresentativeWorkloadVisuals"
	add_child(visual_root)
	runtime.set_workload_tier("S")
	_rebuild_visuals()

func set_workload_tier(tier: String) -> bool:
	var result: bool = runtime.set_workload_tier(tier)
	_rebuild_visuals()
	return result

func select_entity(id: String) -> bool:
	var result: bool = runtime.select_entity(id)
	_sync_unit_visuals()
	return result

func box_select_squad() -> Array[String]:
	var result: Array[String] = runtime.box_select_squad()
	_sync_unit_visuals()
	return result

func issue_move_order(target: Vector3 = Vector3.INF) -> bool:
	var target_2d := Vector2.INF
	if target != Vector3.INF:
		target_2d = _from_world(target)
	var result: bool = runtime.issue_move_order(target_2d)
	_set_or_create_marker("move_order_marker", Vector3(0.9, 0.12, 1.4), Vector3(0.28, 0.12, 0.28), Color(0.35, 0.75, 0.96))
	_sync_unit_visuals()
	return result

func issue_attack_order(target_id: String = "") -> bool:
	var result: bool = runtime.issue_attack_order(target_id)
	_set_or_create_marker("attack_order_marker", Vector3(4.2, 0.72, 0.2), Vector3(0.38, 0.08, 0.38), Color(0.95, 0.22, 0.16))
	_sync_unit_visuals()
	return result

func change_site_state(site_id: String = "west_stone_cut", state: String = "friendly") -> bool:
	var result: bool = runtime.change_site_state(site_id, state)
	_sync_site_visuals()
	_sync_lume_visuals()
	return result

func trigger_hero_ability() -> bool:
	return runtime.trigger_hero_ability()

func focus_lume_link() -> bool:
	var result: bool = runtime.focus_lume_link()
	_sync_lume_visuals()
	return result

func pan_camera() -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.position += Vector3(0.8, 0.0, 0.35)
	camera_panned = true
	return true

func zoom_camera() -> bool:
	var camera := get_node_or_null("FixedOrthographicCamera") as Camera3D
	if not camera:
		return false
	camera.size = 11.0
	camera_zoomed = true
	return true

func toggle_pause() -> bool:
	var result: bool = runtime.toggle_pause()
	_set_or_create_marker("pause_marker", Vector3(-5.2, 0.22, -3.1), Vector3(0.72, 0.16, 0.32), Color(0.84, 0.78, 0.44))
	return result

func transition_results() -> bool:
	var result: bool = runtime.transition_results()
	_set_or_create_marker("results_marker", Vector3(-4.4, 0.22, 3.1), Vector3(1.0, 0.16, 0.38), Color(0.70, 0.86, 0.82))
	return result

func run_workload_phase(phase: String) -> Dictionary:
	var report: Dictionary = runtime.run_workload_phase(phase)
	_sync_unit_visuals()
	_sync_site_visuals()
	_sync_lume_visuals()
	return report

func run_benchmark_suite() -> Dictionary:
	return runtime.run_benchmark_suite(MODE)

func get_spike_status() -> Dictionary:
	var status: Dictionary = runtime.get_status(MODE)
	status["fogPlaceholderRendered"] = true
	status["minimapPlaceholderRendered"] = true
	status["lumeLinkRendered"] = runtime.lume_links.size() > 0
	status["lumeFocused"] = runtime.lume_links.any(func(link: Dictionary) -> bool: return bool(link.get("focused", false)))
	status["cameraPanned"] = camera_panned
	status["cameraZoomed"] = camera_zoomed
	status["paused"] = runtime.paused
	return status

func _create_camera() -> void:
	var camera := Camera3D.new()
	camera.name = "FixedOrthographicCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.0
	camera.position = Vector3(0, 10, 10)
	camera.rotation_degrees = Vector3(-55, 0, 0)
	camera.current = true
	add_child(camera)

func _create_light() -> void:
	var light := DirectionalLight3D.new()
	light.name = "SaltoPlaceholderSun"
	light.rotation_degrees = Vector3(-55, -25, 0)
	light.shadow_enabled = true
	add_child(light)

func _create_terrain() -> void:
	var ground := MeshInstance3D.new()
	ground.name = "SaltoTerrainPlaceholder"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(15, 10)
	ground.mesh = mesh
	ground.material_override = _material(Color(0.12, 0.18, 0.14))
	add_child(ground)
	_add_static_box("river_placeholder", Vector3(0.6, 0.04, 0), Vector3(0.26, 0.08, 8.8), Color(0.12, 0.28, 0.34))
	_add_static_box("road_placeholder", Vector3(0, 0.05, 0.9), Vector3(11.0, 0.06, 0.32), Color(0.36, 0.31, 0.22))

func _rebuild_visuals() -> void:
	if visual_root == null:
		return
	for child in visual_root.get_children():
		child.queue_free()
	for structure in runtime.structures:
		_add_box(str(structure["id"]), _to_world(structure["position"], 0.34), _structure_scale(structure), _structure_color(structure))
	for site in runtime.sites:
		_add_box(str(site["id"]), _to_world(site["position"], 0.13), Vector3(0.56, 0.12, 0.56), _site_color(site))
	for link in runtime.lume_links:
		var from_endpoint: Dictionary = runtime.lume_endpoints[int(link["from"])]
		var to_endpoint: Dictionary = runtime.lume_endpoints[int(link["to"])]
		var midpoint: Vector2 = (from_endpoint["position"] + to_endpoint["position"]) / 2.0
		var length: float = from_endpoint["position"].distance_to(to_endpoint["position"]) / 90.0
		_add_box(str(link["id"]), _to_world(midpoint, 0.18), Vector3(0.08, 0.08, max(0.24, length)), _lume_color(link))
	for endpoint in runtime.lume_endpoints:
		_add_unit(str(endpoint["id"]), _to_world(endpoint["position"], 0.22), Color(0.2, 0.84, 0.84), 0.13)
	for unit in runtime.units:
		_add_unit(str(unit["id"]), _to_world(unit["position"], 0.28), _unit_color(unit), _unit_radius(unit))
	_sync_unit_visuals()

func _sync_unit_visuals() -> void:
	if visual_root == null:
		return
	for unit in runtime.units:
		var node := visual_root.get_node_or_null(str(unit["id"])) as MeshInstance3D
		if node == null:
			continue
		node.position = _to_world(unit["position"], 0.28)
		node.scale = Vector3.ONE * (1.28 if runtime.selected_ids.has(str(unit["id"])) else 1.0)
		node.visible = bool(unit["alive"])

func _sync_site_visuals() -> void:
	if visual_root == null:
		return
	for site in runtime.sites:
		var node := visual_root.get_node_or_null(str(site["id"])) as MeshInstance3D
		if node:
			node.material_override = _material(_site_color(site))

func _sync_lume_visuals() -> void:
	if visual_root == null:
		return
	for link in runtime.lume_links:
		var node := visual_root.get_node_or_null(str(link["id"])) as MeshInstance3D
		if node:
			node.material_override = _material(_lume_color(link))
			node.scale = Vector3.ONE * (1.35 if bool(link.get("focused", false)) else 1.0)

func _add_unit(name: String, position: Vector3, color: Color, radius: float) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color)
	visual_root.add_child(mesh_instance)

func _add_box(name: String, position: Vector3, scale: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color)
	visual_root.add_child(mesh_instance)

func _add_static_box(name: String, position: Vector3, scale: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color)
	add_child(mesh_instance)

func _set_or_create_marker(name: String, position: Vector3, scale: Vector3, color: Color) -> void:
	if visual_root == null:
		return
	var marker := visual_root.get_node_or_null(name) as MeshInstance3D
	if marker == null:
		_add_box(name, position, scale, color)
	else:
		marker.position = position
		var mesh := marker.mesh as BoxMesh
		if mesh:
			mesh.size = scale
		marker.material_override = _material(color)

func _to_world(position: Vector2, y: float = 0.25) -> Vector3:
	return Vector3((position.x - 800.0) / 90.0, y, (position.y - 450.0) / 90.0)

func _from_world(position: Vector3) -> Vector2:
	return Vector2(position.x * 90.0 + 800.0, position.z * 90.0 + 450.0)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	return material

func _unit_color(unit: Dictionary) -> Color:
	if str(unit["team"]) == "enemy":
		return Color(0.9, 0.28, 0.18)
	if str(unit["role"]) == "hero":
		return Color(0.36, 0.68, 0.86)
	if str(unit["role"]) == "Worker":
		return Color(0.72, 0.62, 0.38)
	if str(unit["fixtureId"]) == "ranger":
		return Color(0.48, 0.8, 0.64)
	return Color(0.42, 0.76, 0.46)

func _unit_radius(unit: Dictionary) -> float:
	if str(unit["role"]) == "hero":
		return 0.24
	if str(unit["role"]) == "Worker":
		return 0.14
	return 0.17

func _structure_color(structure: Dictionary) -> Color:
	var team := str(structure["team"])
	if team == "enemy":
		return Color(0.42, 0.12, 0.10)
	if team == "neutral":
		return Color(0.42, 0.39, 0.31)
	return Color(0.45, 0.4, 0.34)

func _structure_scale(structure: Dictionary) -> Vector3:
	var size: Vector2 = structure["size"]
	return Vector3(max(0.25, size.x / 90.0), 0.38, max(0.25, size.y / 90.0))

func _site_color(site: Dictionary) -> Color:
	var owner := str(site["owner"])
	if owner == "friendly":
		return Color(0.30, 0.78, 0.46)
	if owner == "enemy":
		return Color(0.90, 0.22, 0.16)
	if owner == "contested":
		return Color(0.95, 0.62, 0.20)
	return Color(0.88, 0.78, 0.32)

func _lume_color(link: Dictionary) -> Color:
	var state := str(link["state"])
	if state == "severed":
		return Color(0.95, 0.24, 0.20)
	if state == "candidate":
		return Color(0.35, 0.52, 0.58)
	if state == "restored":
		return Color(0.72, 0.96, 0.82)
	return Color(0.2, 0.84, 0.84)
