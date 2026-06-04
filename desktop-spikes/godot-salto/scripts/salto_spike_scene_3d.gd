extends Node3D

const MODE := "2_5D_ORTHOGRAPHIC_PLACEHOLDER"

var selected_ids: Array[String] = []
var last_order := "none"
var paused := false
var results_ready := false
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
		return true
	return false

func box_select_squad() -> Array[String]:
	selected_ids = ["hero_aster", "worker", "militia", "ranger"]
	return selected_ids

func issue_move_order(_target: Vector3 = Vector3.ZERO) -> bool:
	last_order = "move"
	return selected_ids.size() > 0

func issue_attack_order(target_id: String = "ashen_raider") -> bool:
	last_order = "attack:%s" % target_id
	return selected_ids.size() > 0

func change_site_state(site_id: String = "west_stone_cut", _state: String = "friendly") -> bool:
	return sites.has(site_id)

func trigger_hero_ability() -> bool:
	last_order = "hero-ability-placeholder:rally_banner"
	return selected_ids.has("hero_aster")

func toggle_pause() -> bool:
	paused = not paused
	return paused

func transition_results() -> bool:
	results_ready = true
	return results_ready

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
		"fogPlaceholderRendered": true,
		"minimapPlaceholderRendered": true,
		"paused": paused,
		"resultsReady": results_ready
	}
