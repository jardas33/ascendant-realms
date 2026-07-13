extends Node3D

## v0.311 H3 runtime adapter. It consumes authoritative workload state and
## never owns positions, selection, destinations, or gameplay semantics.

const DIRECTIONS := ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"]
const WORKER_SOURCE := "res://assets/v0310/barrosan_worker_v0147_source.png"
const MILITIA_SOURCE := "res://assets/v0310/barrosan_militia_v0154_source.png"

var host_scene: Node
var presentation_root: Node3D
var source_textures: Dictionary = {}
var derived_textures: Dictionary = {}
var derived_materials: Dictionary = {}
var proxy_nodes: Dictionary = {}
var sync_count := 0
var last_authoritative_snapshot: Dictionary = {}
var presentation_scale := 1.0

func set_presentation_enabled(enabled: bool) -> void:
	visible = enabled
	for id in proxy_nodes:
		var proxy := proxy_nodes[id] as Node3D
		if proxy != null and is_instance_valid(proxy):
			proxy.visible = enabled

func configure(owner_scene: Node, parent: Node3D) -> void:
	host_scene = owner_scene
	presentation_root = parent
	_load_sources()
	sync_authoritative_units()

func _load_sources() -> void:
	source_textures["Worker"] = load(WORKER_SOURCE) as Texture2D
	source_textures["Militia"] = load(MILITIA_SOURCE) as Texture2D

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
		var proxy := _ensure_proxy(id, "Worker" if is_worker else "Militia")
		var runtime_position: Vector2 = unit.get("position", Vector2.ZERO)
		var world_position: Vector3 = host_scene.call("_to_world", runtime_position, 0.0)
		var facing_index := _facing_index(unit)
		proxy.position = world_position
		proxy.visible = bool(unit.get("alive", false)) and not bool(unit.get("reviewHidden", false))
		proxy.set_meta("authoritative_position", runtime_position)
		proxy.set_meta("world_facing_direction", DIRECTIONS[facing_index])
		proxy.set_meta("directional_source", "authored_3_4_plus_in_memory_mirror")
		proxy.set_meta("source_pose_count", 1)
		var selected: bool = workload.selected_ids.has(id)
		var sprite := proxy.get_node_or_null("H3Billboard") as MeshInstance3D
		if sprite:
			sprite.material_override = _material_for("Worker" if is_worker else "Militia", facing_index)
			sprite.scale = Vector3.ONE * presentation_scale * (1.04 if selected else 1.0)
		var ring := proxy.get_node_or_null("H3SelectionRing") as MeshInstance3D
		if ring:
			ring.visible = proxy.visible and selected
		var shadow := proxy.get_node_or_null("H3ContactShadow") as MeshInstance3D
		if shadow:
			shadow.visible = proxy.visible
		var fallback := presentation_root.get_node_or_null(id) as MeshInstance3D
		if fallback:
			fallback.visible = false
	for id in proxy_nodes:
		if not seen.has(id):
			(proxy_nodes[id] as Node3D).visible = false
	sync_count += 1
	last_authoritative_snapshot = {
		"unitCount": seen.size(),
		"unitIds": seen.keys(),
		"syncCount": sync_count,
		"stateSource": "runtime.units",
		"selectionSource": "runtime.selected_ids",
		"movementSource": "runtime.position/destination",
		"directionalSource": "one_authored_3_4_pose_plus_explicit_mirrors",
		"animationLibraryPresent": false,
		"gameplayProxy": false,
	}
	return last_authoritative_snapshot.duplicate(true)

func status() -> Dictionary:
	return {
		"enabled": visible,
		"adapter": "v0.311 H3 hybrid billboard runtime pilot",
		"roles": ["Worker", "Militia"],
		"authoritativeState": true,
		"separateSimulation": false,
		"sourcePoseCountPerRole": 1,
		"derivedDirections": 8,
		"animationLibraryPresent": false,
		"proxyCount": proxy_nodes.size(),
		"syncCount": sync_count,
		"lastSnapshot": last_authoritative_snapshot.duplicate(true),
		"rollbackAvailable": true,
		"presentationScale": presentation_scale,
	}

func set_presentation_scale(scale_value: float) -> void:
	presentation_scale = clampf(scale_value, 0.70, 1.0)
	sync_authoritative_units()

func _ensure_proxy(id: String, role: String) -> Node3D:
	if proxy_nodes.has(id) and is_instance_valid(proxy_nodes[id]):
		return proxy_nodes[id] as Node3D
	var root := Node3D.new()
	root.name = "v0311_h3_%s" % id
	root.set_meta("runtime_presentation_adapter", "v0.311_h3")
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
	sprite.name = "H3Billboard"
	var quad := QuadMesh.new()
	quad.size = Vector2(0.72 if role == "Worker" else 0.66, 1.42 if role == "Worker" else 1.28)
	sprite.mesh = quad
	sprite.position = Vector3(0.0, quad.size.y * 0.5 + 0.045, 0.0)
	sprite.material_override = _material_for(role, 3)
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

func _facing_index(unit: Dictionary) -> int:
	var position: Vector2 = unit.get("position", Vector2.ZERO)
	var destination: Vector2 = unit.get("destination", position)
	var delta := destination - position
	if delta.length_squared() < 0.001:
		return 3
	var angle := atan2(delta.y, delta.x)
	return posmod(int(round((angle + PI * 0.5) / (PI * 0.25))), DIRECTIONS.size())

func _material_for(role: String, direction_index: int) -> StandardMaterial3D:
	var key := "%s_%d" % [role, direction_index]
	if derived_materials.has(key):
		return derived_materials[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_texture = _texture_for(role, direction_index)
	material.albedo_color = Color(1, 1, 1, 1)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	derived_materials[key] = material
	return material

func _texture_for(role: String, direction_index: int) -> Texture2D:
	var key := "%s_%d" % [role, direction_index]
	if derived_textures.has(key):
		return derived_textures[key] as Texture2D
	var source := source_textures.get(role) as Texture2D
	if source == null:
		return null
	if direction_index == 0:
		return source
	var image := source.get_image()
	if image == null:
		return source
	if direction_index in [2, 3, 4]:
		image.flip_x()
	var texture := ImageTexture.create_from_image(image)
	derived_textures[key] = texture
	return texture

func _flat_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
