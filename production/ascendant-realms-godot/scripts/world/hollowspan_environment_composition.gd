extends Node3D
## Hollowspan-only presentation composition for Visual Convergence R1 Slice 3.
## This node owns authored secondary scenery placement only; it has no gameplay,
## collision, navigation, resource, or map-topology authority.

const ASSET_ROOT := "res://assets/environment/visual_convergence/"
const BARROSAN_SETTLEMENT_ROOT := ASSET_ROOT + "barrosan_settlement/"

const BARROSAN_SETTLEMENT_ASSETS := {
	"muster_gate": BARROSAN_SETTLEMENT_ROOT + "barrosan_muster_gate_lod1.glb",
	"open_gate_doors": BARROSAN_SETTLEMENT_ROOT + "barrosan_open_gate_doors_lod1.glb",
	"palisade_wall": BARROSAN_SETTLEMENT_ROOT + "barrosan_palisade_wall_4m_lod1.glb",
	"palisade_corner": BARROSAN_SETTLEMENT_ROOT + "barrosan_palisade_corner_lod1.glb",
	"guard_tower": BARROSAN_SETTLEMENT_ROOT + "barrosan_guard_tower_lod1.glb",
	"training_pavilion": BARROSAN_SETTLEMENT_ROOT + "barrosan_training_pavilion_lod1.glb",
	"covered_supply_wagon": BARROSAN_SETTLEMENT_ROOT + "barrosan_covered_supply_wagon_lod1.glb",
	"campaign_tent": BARROSAN_SETTLEMENT_ROOT + "barrosan_campaign_tent_lod1.glb",
	"supply_awning": BARROSAN_SETTLEMENT_ROOT + "barrosan_supply_awning_lod1.glb",
	"clan_waystone": BARROSAN_SETTLEMENT_ROOT + "barrosan_clan_waystone_lod1.glb",
	"muster_rack": BARROSAN_SETTLEMENT_ROOT + "barrosan_muster_rack_lod1.glb",
	"clan_standard": BARROSAN_SETTLEMENT_ROOT + "barrosan_clan_standard_lod1.glb",
	"watch_brazier": BARROSAN_SETTLEMENT_ROOT + "barrosan_watch_brazier_lod1.glb",
}

# The source assembly is authored in a Blender Z-up plane. These placements
# are the first-wave subset translated to Godot's X/Z ground plane. The
# half-turn is deliberately kept out of gameplay code: it points the open
# defensive face toward Hollowspan's map interior while preserving the kit's
# authored spacing and asymmetry.
const BARROSAN_SETTLEMENT_PLACEMENTS := [
	{"asset": "muster_gate", "position": Vector3(0.0, 0.0, -5.0), "yaw": 0.0},
	{"asset": "open_gate_doors", "position": Vector3(0.0, 0.0, -5.0), "yaw": 0.0},
	{"asset": "palisade_wall", "position": Vector3(-5.0, 0.0, -5.0), "yaw": 0.0},
	{"asset": "palisade_wall", "position": Vector3(5.0, 0.0, -5.0), "yaw": 0.0},
	{"asset": "palisade_corner", "position": Vector3(-9.0, 0.0, -5.0), "yaw": 0.0},
	{"asset": "palisade_corner", "position": Vector3(9.0, 0.0, -5.0), "yaw": PI * 0.5},
	{"asset": "palisade_wall", "position": Vector3(-9.0, 0.0, -1.0), "yaw": PI * 0.5},
	{"asset": "palisade_wall", "position": Vector3(9.0, 0.0, -1.0), "yaw": PI * 0.5},
	{"asset": "guard_tower", "position": Vector3(4.7, 0.0, -2.4), "yaw": 0.0},
	{"asset": "training_pavilion", "position": Vector3(-4.1, 0.0, 4.0), "yaw": 0.0},
	{"asset": "campaign_tent", "position": Vector3(4.4, 0.0, 5.5), "yaw": -0.07},
	{"asset": "supply_awning", "position": Vector3(-4.0, 0.0, -0.5), "yaw": 0.0},
	{"asset": "covered_supply_wagon", "position": Vector3(0.25, 0.0, 1.55), "yaw": -0.10},
	{"asset": "clan_waystone", "position": Vector3(0.0, 0.0, 8.5), "yaw": 0.0},
	{"asset": "muster_rack", "position": Vector3(-3.4, 0.0, 1.65), "yaw": 0.0},
	{"asset": "clan_standard", "position": Vector3(-2.1, 0.0, -3.8), "yaw": 0.0},
	{"asset": "watch_brazier", "position": Vector3(2.0, 0.0, -3.75), "yaw": 0.0},
	{"asset": "watch_brazier", "position": Vector3(-1.85, 0.0, -3.7), "yaw": 0.0},
]

const BARROSAN_SETTLEMENT_ANCHOR_OFFSET := Vector3(8.0, 0.0, 8.0)
const BARROSAN_SETTLEMENT_ASSEMBLY_YAW := PI

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
	_build_barrosan_settlement(layer, origin + BARROSAN_SETTLEMENT_ANCHOR_OFFSET)


func _place_asset(parent: Node3D, asset_key: String, position: Vector3, yaw: float) -> void:
	var path: String = ASSET_PATHS.get(asset_key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var packed := load(path)
	if not packed or not packed is PackedScene:
		return
	var instance: Node = packed.instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return
	parent.add_child(instance)
	instance.position = position
	instance.rotation.y = yaw
	ModelUtils.scale_to_height(instance, float(ASSET_SCALE.get(asset_key, 2.0)))
	ModelUtils.ground_model(instance)
	_set_presentation_only(instance)


func _build_barrosan_settlement(parent: Node3D, anchor: Vector3) -> void:
	var settlement_layer := Node3D.new()
	settlement_layer.name = "AstraBarrosanSettlementFirstWave"
	parent.add_child(settlement_layer)
	for spec in BARROSAN_SETTLEMENT_PLACEMENTS:
		var asset_key := String(spec["asset"])
		var path: String = BARROSAN_SETTLEMENT_ASSETS.get(asset_key, "")
		if path.is_empty() or not ResourceLoader.exists(path):
			continue
		var packed := load(path)
		if not packed or not packed is PackedScene:
			continue
		var instance: Node = packed.instantiate()
		if not instance is Node3D:
			instance.queue_free()
			continue
		settlement_layer.add_child(instance)
		var source_position: Vector3 = spec["position"]
		instance.position = anchor + Vector3(-source_position.x, source_position.y, -source_position.z)
		instance.rotation.y = float(spec["yaw"]) + BARROSAN_SETTLEMENT_ASSEMBLY_YAW
		ModelUtils.ground_model(instance)
		# LOD1 is the deliberate fixed RTS-scale choice for this first wave. The
		# imported GLBs carry the authored materials and have no gameplay body.
		_set_presentation_only(instance, true)


func _set_presentation_only(root: Node, cast_shadows: bool = false) -> void:
	for child in root.find_children("*", "CollisionObject3D"):
		child.queue_free()
	for mesh in root.find_children("*", "GeometryInstance3D"):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
