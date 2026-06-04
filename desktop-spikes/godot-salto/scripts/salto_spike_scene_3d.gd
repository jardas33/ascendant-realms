extends Node3D

const MODE := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"

var selected_ids: Array[String] = []
var last_order := "none"
var paused := false
var results_ready := false
var lume_focused := false
var site_friendly := false
var camera_panned := false
var camera_zoomed := false
var entities := ["hero_aster", "worker", "militia", "ranger", "ashen_raider"]
var structures := ["command_hall", "barracks"]
var sites := ["west_stone_cut", "ford_toll"]

func _ready() -> void:
	_create_camera()
	_create_light()
	_create_terrain()
	_create_structures()
	_create_entities()
	_create_lume_link()

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
	mesh.size = Vector2(14, 9)
	ground.mesh = mesh
	ground.material_override = _material(Color(0.12, 0.18, 0.14))
	add_child(ground)

func _create_structures() -> void:
	_add_box("command_hall", Vector3(-4, 0.45, -1.8), Vector3(1.4, 0.9, 0.9), Color(0.45, 0.4, 0.34))
	_add_box("barracks", Vector3(-2.4, 0.35, -2.6), Vector3(1.0, 0.7, 0.7), Color(0.38, 0.34, 0.29))
	_add_box("west_stone_cut_mine", Vector3(1.9, 0.25, 2.1), Vector3(0.9, 0.5, 0.8), Color(0.42, 0.39, 0.31))
	_add_box("ford_toll_shrine", Vector3(3.0, 0.4, -2.0), Vector3(0.55, 0.8, 0.55), Color(0.16, 0.45, 0.48))

func _create_entities() -> void:
	_add_unit("hero_aster", Vector3(-1.4, 0.3, 0), Color(0.36, 0.68, 0.86), 0.35)
	_add_unit("worker", Vector3(-2.2, 0.25, 0.9), Color(0.72, 0.62, 0.38), 0.25)
	_add_unit("militia", Vector3(-0.6, 0.25, 1.0), Color(0.42, 0.76, 0.46), 0.27)
	_add_unit("ranger", Vector3(0.1, 0.25, 0.35), Color(0.48, 0.8, 0.64), 0.25)
	_add_unit("ashen_raider", Vector3(4.2, 0.28, 0.2), Color(0.9, 0.28, 0.18), 0.3)

func _create_lume_link() -> void:
	_add_box("lume_link_placeholder", Vector3(2.45, 0.12, 0.0), Vector3(0.12, 0.12, 4.2), Color(0.2, 0.84, 0.84))

func _add_unit(name: String, position: Vector3, color: Color, radius: float) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color)
	add_child(mesh_instance)

func _add_box(name: String, position: Vector3, scale: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = name
	var mesh := BoxMesh.new()
	mesh.size = scale
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = _material(color)
	add_child(mesh_instance)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.72
	return material

func select_entity(id: String) -> bool:
	if entities.has(id) or id == "hero":
		selected_ids = ["hero_aster" if id == "hero" else id]
		_update_selection_markers()
		return true
	return false

func box_select_squad() -> Array[String]:
	selected_ids = ["hero_aster", "worker", "militia", "ranger"]
	_update_selection_markers()
	return selected_ids

func issue_move_order(_target: Vector3 = Vector3.ZERO) -> bool:
	last_order = "move"
	_set_or_create_marker("move_order_marker", Vector3(0.9, 0.12, 1.4), Vector3(0.28, 0.12, 0.28), Color(0.35, 0.75, 0.96))
	return selected_ids.size() > 0

func issue_attack_order(target_id: String = "ashen_raider") -> bool:
	last_order = "attack:%s" % target_id
	_set_or_create_marker("attack_order_marker", Vector3(4.2, 0.72, 0.2), Vector3(0.38, 0.08, 0.38), Color(0.95, 0.22, 0.16))
	return selected_ids.size() > 0

func change_site_state(site_id: String = "west_stone_cut", _state: String = "friendly") -> bool:
	if not sites.has(site_id):
		return false
	site_friendly = true
	var mine := get_node_or_null("west_stone_cut_mine") as MeshInstance3D
	if mine:
		mine.material_override = _material(Color(0.30, 0.78, 0.46))
	return true

func trigger_hero_ability() -> bool:
	last_order = "hero-ability-placeholder:rally_banner"
	return selected_ids.has("hero_aster")

func focus_lume_link() -> bool:
	lume_focused = true
	last_order = "lume-link-focus"
	var lume := get_node_or_null("lume_link_placeholder") as MeshInstance3D
	if lume:
		lume.scale = Vector3(1.7, 1.7, 1.7)
		lume.material_override = _material(Color(0.37, 0.96, 0.96))
	return true

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
	paused = not paused
	_set_or_create_marker("pause_marker", Vector3(-5.2, 0.22, -3.1), Vector3(0.72, 0.16, 0.32), Color(0.84, 0.78, 0.44))
	return paused

func transition_results() -> bool:
	results_ready = true
	_set_or_create_marker("results_marker", Vector3(-4.4, 0.22, 3.1), Vector3(1.0, 0.16, 0.38), Color(0.70, 0.86, 0.82))
	return results_ready

func _update_selection_markers() -> void:
	for id in entities:
		var unit := get_node_or_null(id) as Node3D
		if unit:
			unit.scale = Vector3(1.24, 1.24, 1.24) if selected_ids.has(id) else Vector3.ONE

func _set_or_create_marker(name: String, position: Vector3, scale: Vector3, color: Color) -> void:
	var marker := get_node_or_null(name) as MeshInstance3D
	if marker == null:
		_add_box(name, position, scale, color)
	else:
		marker.position = position
		var mesh := marker.mesh as BoxMesh
		if mesh:
			mesh.size = scale
		marker.material_override = _material(color)

func get_spike_status() -> Dictionary:
	return {
		"mode": MODE,
		"ready": true,
		"entityCount": entities.size(),
		"structureCount": structures.size(),
		"siteCount": sites.size(),
		"selectedIds": selected_ids,
		"lastOrder": last_order,
		"lumeLinkRendered": true,
		"lumeFocused": lume_focused,
		"siteFriendly": site_friendly,
		"fogPlaceholderRendered": true,
		"minimapPlaceholderRendered": true,
		"cameraPanned": camera_panned,
		"cameraZoomed": camera_zoomed,
		"paused": paused,
		"resultsReady": results_ready
	}
