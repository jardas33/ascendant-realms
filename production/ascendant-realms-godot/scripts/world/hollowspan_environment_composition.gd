extends Node3D
## Hollowspan-only presentation composition for Visual Convergence R1 Slice 3.
## This node owns authored secondary scenery placement only; it has no gameplay,
## collision, navigation, resource, or map-topology authority.

const ASSET_ROOT := "res://assets/environment/visual_convergence/"

const ASSET_SCALE := {
	"wall": 4.2,
	"fence": 3.6,
	"cairn": 2.1,
	"logs": 2.4,
	"marker": 2.7,
	"shelter": 3.0,
	"brush": 2.0,
}

const ASSET_PATHS := {
	"wall": ASSET_ROOT + "highland_dry_stone_wall_module.glb",
	"fence": ASSET_ROOT + "weathered_fence_module.glb",
	"cairn": ASSET_ROOT + "small_stone_cairn.glb",
	"logs": ASSET_ROOT + "fallen_timber_cluster.glb",
	"marker": ASSET_ROOT + "barrosan_boundary_marker.glb",
	"shelter": ASSET_ROOT + "rough_supply_shelter.glb",
	"brush": ASSET_ROOT + "highland_brush_cluster.glb",
}

const PLACEMENTS := [
	# Band B: settlement transition from the Barrosan base into the routes.
	{"asset": "wall", "offset": Vector3(30.0, 0.0, 8.0), "yaw": -0.18},
	{"asset": "fence", "offset": Vector3(21.0, 0.0, -8.0), "yaw": 0.2},
	{"asset": "shelter", "offset": Vector3(35.0, 0.0, -11.0), "yaw": -0.25},
	{"asset": "brush", "offset": Vector3(27.0, 0.0, 18.0), "yaw": 0.15},
	# Band C: strategic corridor landmarks and an intentionally clear centre.
	{"asset": "cairn", "world": Vector3(-34.0, 0.0, -24.0), "yaw": 0.0},
	{"asset": "logs", "world": Vector3(-42.0, 0.0, 24.0), "yaw": 0.55},
	{"asset": "wall", "world": Vector3(38.0, 0.0, 34.0), "yaw": -0.35},
	{"asset": "marker", "world": Vector3(44.0, 0.0, -34.0), "yaw": 0.0},
	# Band D: readable outer framing, deliberately outside the central routes.
	{"asset": "brush", "world": Vector3(-76.0, 0.0, -44.0), "yaw": 0.3},
	{"asset": "brush", "world": Vector3(76.0, 0.0, 44.0), "yaw": -0.25},
	{"asset": "logs", "world": Vector3(72.0, 0.0, -62.0), "yaw": -0.5},
	{"asset": "fence", "world": Vector3(-70.0, 0.0, 66.0), "yaw": 0.4},
]

func build(parent: Node3D, origin: Vector3, map_data: Dictionary) -> void:
	if map_data.get("id", "") != "hollowspan":
		return
	var layer := Node3D.new()
	layer.name = "HollowspanEnvironmentComposition"
	parent.add_child(layer)
	for spec in PLACEMENTS:
		var position: Vector3 = spec.get("world", origin + spec.get("offset", Vector3.ZERO))
		_place_asset(layer, String(spec["asset"]), position, float(spec.get("yaw", 0.0)))


func _place_asset(parent: Node3D, asset_key: String, position: Vector3, yaw: float) -> void:
	var path: String = ASSET_PATHS.get(asset_key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var packed := load(path)
	if not packed or not packed is PackedScene:
		return
	var instance := packed.instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return
	parent.add_child(instance)
	instance.position = position
	instance.rotation.y = yaw
	ModelUtils.scale_to_height(instance, float(ASSET_SCALE.get(asset_key, 2.0)))
	ModelUtils.ground_model(instance)
	_set_presentation_only(instance)


func _set_presentation_only(root: Node) -> void:
	for child in root.find_children("*", "CollisionObject3D"):
		child.queue_free()
	for mesh in root.find_children("*", "GeometryInstance3D"):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
