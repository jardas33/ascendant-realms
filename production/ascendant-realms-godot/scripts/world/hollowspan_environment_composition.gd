extends Node3D
## Hollowspan-only presentation composition for Visual Convergence R2.
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

const BARROSAN_SETTLEMENT_MATERIAL_TINTS := {
	"muster_gate": Color(0.90, 0.86, 0.78),
	"open_gate_doors": Color(0.90, 0.86, 0.78),
	"palisade_wall": Color(0.88, 0.82, 0.72),
	"palisade_corner": Color(0.88, 0.82, 0.72),
	"guard_tower": Color(0.88, 0.82, 0.72),
	"training_pavilion": Color(0.90, 0.84, 0.74),
	"muster_rack": Color(0.88, 0.82, 0.72),
	"clan_standard": Color(0.92, 0.88, 0.80),
	"covered_supply_wagon": Color(0.88, 0.84, 0.76),
	"campaign_tent": Color(0.88, 0.84, 0.76),
	"supply_awning": Color(0.88, 0.84, 0.76),
	"clan_waystone": Color(0.86, 0.86, 0.82),
}

# These authored masses remain presentation-only: GameWorld consumes their
# cached visible bounds for soft route avoidance, while physics/collision and
# navigation-mesh ownership stay unchanged. Small settlement dressing is not
# registered and remains intentionally non-blocking.
const NAVIGATION_BLOCKER_IDS := {
	"wall": "astra_wall",
	"guard_tower": "astra_guard_tower",
	"covered_supply_wagon": "astra_supply_wagon",
}

# The source assembly is authored in a Blender Z-up plane. These placements
# are the first-wave subset translated to Godot's X/Z ground plane. The
# half-turn is deliberately kept out of gameplay code: it points the open
# defensive face toward Hollowspan's map interior while preserving the kit's
# authored spacing and asymmetry.
const BARROSAN_SETTLEMENT_PLACEMENTS := [
	# Defensive threshold: gate first, tower close enough to read as its landmark,
	# with one asymmetric return so it does not become a flat fence line.
	{"asset": "muster_gate", "position": Vector3(0.0, 0.0, 14.0), "yaw": 0.0},
	{"asset": "open_gate_doors", "position": Vector3(0.0, 0.0, 14.0), "yaw": 0.0},
	{"asset": "palisade_wall", "position": Vector3(-5.0, 0.0, 14.0), "yaw": 0.0},
	{"asset": "palisade_wall", "position": Vector3(5.0, 0.0, 14.0), "yaw": 0.0},
	{"asset": "palisade_corner", "position": Vector3(-9.0, 0.0, 14.0), "yaw": 0.0},
	{"asset": "palisade_wall", "position": Vector3(-9.0, 0.0, 9.0), "yaw": PI * 0.5},
	{"asset": "guard_tower", "position": Vector3(-4.0, 0.0, 11.0), "yaw": 0.0},
	# War Hall military district: support pieces sit beside the production building.
	{"asset": "training_pavilion", "position": Vector3(12.0, 0.0, 0.0), "yaw": 0.0},
	{"asset": "muster_rack", "position": Vector3(10.0, 0.0, -3.0), "yaw": 0.0},
	{"asset": "clan_standard", "position": Vector3(14.0, 0.0, -3.5), "yaw": 0.0},
	# Logistics zone: the wagon, tent, awning and waystone are offset from the threshold.
	{"asset": "covered_supply_wagon", "position": Vector3(18.0, 0.0, -6.0), "yaw": -0.10},
	{"asset": "campaign_tent", "position": Vector3(22.0, 0.0, -4.0), "yaw": -0.07},
	{"asset": "supply_awning", "position": Vector3(17.0, 0.0, -1.0), "yaw": 0.0},
	{"asset": "clan_waystone", "position": Vector3(24.0, 0.0, -9.0), "yaw": 0.0},
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

const SLICE_DIRT_TEXTURE := "res://assets/textures/nature/highland_dirt_path.png"
const SLICE_ROCK_TEXTURE := "res://assets/textures/stone/highland_rock.png"

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

# R2 is deliberately a small, local vegetation pass around the already
# promoted Barrosan opening. These placements sit on route shoulders and the
# meadow transition; none occupies a building contact patch, resource
# interaction zone, or the centre of the primary track. They are existing
# project-authored, presentation-only meshes and remain non-blocking.
const R2_PLACEMENTS := [
	# Settlement transition: asymmetrical low clumps outside the working yards.
	{"asset": "brush", "offset": Vector3(-18.0, 0.0, 10.0), "yaw": -0.28, "height": 1.35},
	{"asset": "brush", "offset": Vector3(14.0, 0.0, 22.0), "yaw": 0.42, "height": 1.55},
	{"asset": "cairn", "offset": Vector3(20.0, 0.0, 26.0), "yaw": -0.12, "height": 1.45},
	# Primary route shoulders: alternating clumps keep the travel lane legible.
	{"asset": "brush", "offset": Vector3(-16.0, 0.0, 24.0), "yaw": 0.18, "height": 1.65},
	{"asset": "brush", "offset": Vector3(13.0, 0.0, 29.0), "yaw": -0.36, "height": 1.25},
	{"asset": "cairn", "offset": Vector3(-6.0, 0.0, 34.0), "yaw": 0.30, "height": 1.55},
	{"asset": "brush", "offset": Vector3(35.0, 0.0, 37.0), "yaw": 0.56, "height": 1.45},
	# Meadow breakup: two restrained groupings widen the sense of a lived-in
	# highland approach without blanketing the playable battlefield.
	{"asset": "brush", "offset": Vector3(-18.0, 0.0, 42.0), "yaw": -0.48, "height": 1.55},
	{"asset": "cairn", "offset": Vector3(32.0, 0.0, 46.0), "yaw": 0.08, "height": 1.35},
	{"asset": "brush", "offset": Vector3(48.0, 0.0, 51.0), "yaw": -0.18, "height": 1.30},
]

func build(parent: Node3D, origin: Vector3, map_data: Dictionary) -> void:
	if map_data.get("id", "") != "hollowspan":
		return
	var layer := Node3D.new()
	layer.name = "HollowspanEnvironmentComposition"
	parent.add_child(layer)
	_build_barrosan_base_ground_slice(layer, origin)
	for spec in PLACEMENTS:
		var position: Vector3 = spec.get("world", origin + spec.get("offset", Vector3.ZERO))
		_place_asset(layer, String(spec["asset"]), position, float(spec.get("yaw", 0.0)))
	_build_barrosan_settlement(layer, origin + BARROSAN_SETTLEMENT_ANCHOR_OFFSET)
	_build_barrosan_r2_dressing(layer, origin)


func _build_barrosan_base_ground_slice(parent: Node3D, origin: Vector3) -> void:
	# Presentation-only ground ownership for the first Barrosan slice. These
	# surfaces sit a few millimetres above the playable plane and have no
	# collision, navigation, resource, or building-placement authority.
	var ground := Node3D.new()
	ground.name = "BarrosanBaseGroundSlice"
	parent.add_child(ground)
	var contact_dirt := _slice_material("BarrosanContactDirt", Color(0.58, 0.50, 0.40, 0.42), SLICE_DIRT_TEXTURE)
	var yard_dirt := _slice_material("BarrosanWorkingYard", Color(0.62, 0.51, 0.38, 0.48), SLICE_DIRT_TEXTURE)
	var track_dirt := _slice_material("BarrosanPrimaryTrack", Color(0.68, 0.55, 0.39, 0.62), SLICE_DIRT_TEXTURE)
	var edge_rock := _slice_material("BarrosanEdgeRock", Color("8f9089"), SLICE_ROCK_TEXTURE)

	# Formal Clanhold threshold and a compact military working yard beside it.
	_add_ground_patch(ground, "ClanholdContactGround", origin + Vector3(0.0, 0.0, 0.0), Vector2(7.4, 6.8), 12, contact_dirt)
	_add_ground_patch(ground, "ClanholdThresholdWear", origin + Vector3(2.5, 0.018, 5.8), Vector2(3.8, 2.5), 9, yard_dirt)
	var work_yard := origin + Vector3(-4.0, 0.0, 8.0)
	_add_ground_patch(ground, "WarHallWorkingYard", work_yard + Vector3(0.0, 0.018, 0.0), Vector2(5.8, 4.5), 11, yard_dirt)
	_add_ground_patch(ground, "WarHallContactGround", work_yard + Vector3(0.0, 0.012, 0.0), Vector2(4.9, 3.9), 10, contact_dirt)

	# A readable three-stage connection: settlement threshold -> working yard ->
	# outward battlefield route. The changing widths and slight bends keep it
	# embedded in the land rather than reading as a bright rectangular panel.
	var settlement_track: Array[Vector3] = [
		origin + Vector3(3.0, 0.024, 5.2),
		origin + Vector3(0.5, 0.024, 11.5),
		origin + Vector3(-4.0, 0.024, 16.0),
	]
	_add_ribbon(ground, "SecondarySettlementTrack", settlement_track, [2.9, 2.6, 2.3], track_dirt)
	var outward_track: Array[Vector3] = [
		origin + Vector3(-3.5, 0.027, 15.0),
		origin + Vector3(4.0, 0.027, 24.0),
		origin + Vector3(17.0, 0.027, 32.0),
		origin + Vector3(34.0, 0.027, 39.0),
		origin + Vector3(55.0, 0.027, 47.0),
	]
	_add_ribbon(ground, "PrimaryBattlefieldTrack", outward_track, [3.2, 3.0, 2.8, 2.5, 2.2], track_dirt)

	# A few composed edge groups mark the transition without filling the lane.
	_place_asset(ground, "cairn", origin + Vector3(8.0, 0.0, 20.0), -0.12)
	_place_asset(ground, "cairn", origin + Vector3(-11.0, 0.0, 25.0), 0.22)
	_add_ground_patch(ground, "RouteEdgeStoneScar", origin + Vector3(40.0, 0.016, 42.0), Vector2(1.8, 1.0), 7, edge_rock)


func _build_barrosan_r2_dressing(parent: Node3D, origin: Vector3) -> void:
	var dressing := Node3D.new()
	dressing.name = "BarrosanEnvironmentR2Dressing"
	parent.add_child(dressing)
	for spec in R2_PLACEMENTS:
		var position := origin + Vector3(spec["offset"])
		_place_asset(
			dressing,
			String(spec["asset"]),
			position,
			float(spec.get("yaw", 0.0)),
			float(spec.get("height", -1.0))
		)


func _slice_material(material_name: String, color: Color, texture_path: String = "") -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = material_name
	material.albedo_color = color
	if color.a < 0.99:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.96
	material.metallic = 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
		material.albedo_texture = load(texture_path)
	return material


func _add_ground_patch(parent: Node3D, patch_name: String, center: Vector3, radius: Vector2, points: int, material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in points:
		var next_index := (index + 1) % points
		var angle_a := TAU * float(index) / float(points)
		var angle_b := TAU * float(next_index) / float(points)
		var radius_a := 0.84 + 0.11 * sin(float(index) * 2.7 + 0.8)
		var radius_b := 0.84 + 0.11 * sin(float(next_index) * 2.7 + 0.8)
		var point_a := center + Vector3(cos(angle_a) * radius.x * radius_a, 0.0, sin(angle_a) * radius.y * radius_a)
		var point_b := center + Vector3(cos(angle_b) * radius.x * radius_b, 0.0, sin(angle_b) * radius.y * radius_b)
		var uv_a := Vector2(0.5 + (point_a.x - center.x) / (radius.x * 2.0), 0.5 + (point_a.z - center.z) / (radius.y * 2.0))
		var uv_b := Vector2(0.5 + (point_b.x - center.x) / (radius.x * 2.0), 0.5 + (point_b.z - center.z) / (radius.y * 2.0))
		# Reverse winding so the top face remains visible with a +Y normal.
		surface.set_uv(Vector2(0.5, 0.5)); surface.add_vertex(center)
		surface.set_uv(uv_b); surface.add_vertex(point_b)
		surface.set_uv(uv_a); surface.add_vertex(point_a)
	surface.generate_normals()
	var mesh := surface.commit()
	if mesh == null:
		return
	var instance := MeshInstance3D.new()
	instance.name = patch_name
	instance.mesh = mesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)


func _add_ribbon(parent: Node3D, ribbon_name: String, points: Array[Vector3], widths: Array[float], material: Material) -> void:
	if points.size() < 2 or widths.size() < points.size():
		return
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var distance_along_ribbon := 0.0
	for index in range(points.size() - 1):
		var from: Vector3 = points[index]
		var to: Vector3 = points[index + 1]
		var tangent := to - from
		tangent.y = 0.0
		if tangent.length_squared() < 0.01:
			continue
		var segment_length := tangent.length()
		tangent = tangent.normalized()
		var normal := Vector3(-tangent.z, 0.0, tangent.x)
		var left_from := from + normal * widths[index] * 0.5
		var right_from := from - normal * widths[index] * 0.5
		var left_to := to + normal * widths[index + 1] * 0.5
		var right_to := to - normal * widths[index + 1] * 0.5
		var v_from := distance_along_ribbon * 0.12
		var v_to := (distance_along_ribbon + segment_length) * 0.12
		surface.set_uv(Vector2(0.0, v_from)); surface.add_vertex(left_from)
		surface.set_uv(Vector2(1.0, v_from)); surface.add_vertex(right_from)
		surface.set_uv(Vector2(1.0, v_to)); surface.add_vertex(right_to)
		surface.set_uv(Vector2(0.0, v_from)); surface.add_vertex(left_from)
		surface.set_uv(Vector2(1.0, v_to)); surface.add_vertex(right_to)
		surface.set_uv(Vector2(0.0, v_to)); surface.add_vertex(left_to)
		distance_along_ribbon += segment_length
	surface.generate_normals()
	var mesh := surface.commit()
	if mesh == null:
		return
	var instance := MeshInstance3D.new()
	instance.name = ribbon_name
	instance.mesh = mesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)


func _place_asset(parent: Node3D, asset_key: String, position: Vector3, yaw: float, height_override: float = -1.0) -> void:
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
	var target_height := height_override if height_override > 0.0 else float(ASSET_SCALE.get(asset_key, 2.0))
	ModelUtils.scale_to_height(instance, target_height)
	ModelUtils.ground_model(instance)
	_set_presentation_only(instance)
	_mark_navigation_blocker(instance, asset_key)


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
		_apply_settlement_material_cohesion(instance, asset_key)
		_set_presentation_only(instance, true)
		_mark_navigation_blocker(instance, asset_key)


func _mark_navigation_blocker(root: Node, asset_key: String) -> void:
	if not NAVIGATION_BLOCKER_IDS.has(asset_key):
		return
	root.add_to_group("navigation_soft_blockers")
	root.set_meta("navigation_blocker_id", String(NAVIGATION_BLOCKER_IDS[asset_key]))
	root.set_meta("navigation_blocker_class", "ASTRA_LOGISTICS" if asset_key == "covered_supply_wagon" else "ASTRA_LARGE")


func _apply_settlement_material_cohesion(root: Node, asset_key: String) -> void:
	# Keep the embedded authored textures, but give the first wave a shared matte
	# value range so canvas, timber, stone, and iron sit together at RTS scale.
	var tint: Color = BARROSAN_SETTLEMENT_MATERIAL_TINTS.get(asset_key, Color.WHITE)
	var mesh_nodes := root.find_children("*", "MeshInstance3D")
	if root is MeshInstance3D:
		mesh_nodes.push_front(root)
	for child in mesh_nodes:
		var mesh_instance: MeshInstance3D = child as MeshInstance3D
		if not mesh_instance or not mesh_instance.mesh:
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var source_material: Material = mesh_instance.get_active_material(surface)
			if not source_material is StandardMaterial3D:
				continue
			var adjusted_material := source_material.duplicate() as StandardMaterial3D
			var source_color := adjusted_material.albedo_color
			adjusted_material.albedo_color = Color(
				source_color.r * tint.r,
				source_color.g * tint.g,
				source_color.b * tint.b,
				source_color.a
			)
			adjusted_material.roughness = maxf(adjusted_material.roughness, 0.82)
			mesh_instance.set_surface_override_material(surface, adjusted_material)


func _set_presentation_only(root: Node, cast_shadows: bool = false) -> void:
	for child in root.find_children("*", "CollisionObject3D"):
		child.queue_free()
	for mesh in root.find_children("*", "GeometryInstance3D"):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
