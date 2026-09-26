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
	# Firelight: braziers flank the muster gate and mark the Clanhold threshold,
	# giving the base warm focal points against the golden-hour grade.
	{"asset": "watch_brazier", "position": Vector3(-3.2, 0.0, 12.6), "yaw": 0.0},
	{"asset": "watch_brazier", "position": Vector3(3.2, 0.0, 12.6), "yaw": 0.0},
	{"asset": "watch_brazier", "position": Vector3(5.2, 0.0, 2.8), "yaw": 0.0},
]

const BARROSAN_SETTLEMENT_ANCHOR_OFFSET := Vector3(8.0, 0.0, 8.0)
const BARROSAN_SETTLEMENT_ASSEMBLY_YAW := PI

const ASSET_SCALE := {
	"wall": 1.9,
	"fence": 3.6,
	"cairn": 2.1,
	"logs": 2.4,
	"marker": 2.7,
	"shelter": 3.0,
	"brush": 2.0,
	"charred_wall": 2.3,
	"ash_glass": 3.2,
	"moonstone": 4.8,
	"lume_bloom": 1.1,
}

const ASSET_PATHS := {
	"wall": ASSET_ROOT + "highland_dry_stone_wall_module.glb",
	"fence": ASSET_ROOT + "weathered_fence_module.glb",
	"cairn": ASSET_ROOT + "small_stone_cairn.glb",
	"logs": ASSET_ROOT + "fallen_timber_cluster.glb",
	"marker": ASSET_ROOT + "barrosan_boundary_marker.glb",
	"shelter": ASSET_ROOT + "rough_supply_shelter.glb",
	"brush": ASSET_ROOT + "highland_brush_cluster.glb",
	"charred_wall": ASSET_ROOT + "vorthak_charred_wall.glb",
	"ash_glass": ASSET_ROOT + "vorthak_ash_glass_shards.glb",
	"moonstone": ASSET_ROOT + "lioraen_moonstone.glb",
	"lume_bloom": ASSET_ROOT + "lioraen_lume_bloom.glb",
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

func build(parent: Node3D, origin: Vector3, map_data: Dictionary, start_race: String = "barrosan") -> void:
	if map_data.get("id", "") != "hollowspan":
		return
	var layer := Node3D.new()
	layer.name = "HollowspanEnvironmentComposition"
	parent.add_child(layer)
	# The settlement kit, worn yards and route dressing are Barrosan architecture.
	# Another race starting here keeps only the neutral highland scenery, so a
	# Lioraen Groveheart is never ringed by a Barrosan palisade and gate.
	var barrosan_start := start_race == "barrosan"
	if barrosan_start:
		_build_barrosan_base_ground_slice(layer, origin)
	for spec in PLACEMENTS:
		var position: Vector3 = spec.get("world", origin + spec.get("offset", Vector3.ZERO))
		_place_asset(layer, String(spec["asset"]), position, float(spec.get("yaw", 0.0)))
	if start_race == "lioraen":
		build_lioraen_grove(layer, origin)
	if barrosan_start:
		_build_barrosan_settlement(layer, origin + BARROSAN_SETTLEMENT_ANCHOR_OFFSET)
		_build_barrosan_r2_dressing(layer, origin)
		_build_barrosan_hamlet(layer, origin)


# Faction dressing for a start on any battlefield. Hollowspan's own authored
# layer (build) adds its map-specific scenery on top of this for the player.
func build_faction_start(parent: Node3D, origin: Vector3, race: String) -> void:
	match race:
		"barrosan":
			_build_barrosan_hamlet(parent, origin)
		"lioraen":
			build_lioraen_grove(parent, origin)
		"vorthak":
			build_vorthak_holdfast(parent, origin)


# Lived-in hamlet behind the Barrosan start: cottages with hearth smoke and
# door lanterns, woodpiles, a well-worn lane and garden walls. Placed in the
# start's own frame (toward = map centre) on the side away from the fight and
# clear of the resource cluster; houses register as world blockers so units
# path around them. Presentation only: no ownership, selection or economy.
const HAMLET_HOUSES := [
	# [asset, back, side, yaw offset, height]
	["res://assets/environment/buildings/barrosan_houses_a03.glb", 20.0, -8.0, 0.35, 7.4],
	["res://assets/environment/buildings/barrosan_clan_croft.glb", 18.0, 12.5, -0.5, 6.2],
	["res://assets/environment/buildings/barrosan_clan_croft.glb", 28.0, 3.5, 2.9, 5.8],
]
const HAMLET_DRESSING := [
	# [asset key, back, side, yaw]
	["logs", 18.5, -1.5, 0.9],
	["logs", 27.0, 13.5, 2.1],
	["fence", 29.0, -13.5, 1.25],
	["fence", 17.0, 17.0, -0.35],
	["wall", 36.0, -6.0, 0.15],
	["brush", 30.5, -1.0, 0.0],
	["brush", 22.5, 19.0, 0.5],
	["cairn", 15.0, 8.0, 0.0],
]


func _build_barrosan_hamlet(parent: Node3D, origin: Vector3) -> void:
	var toward := (Vector3.ZERO - origin)
	toward.y = 0.0
	if toward.length_squared() < 0.01:
		return
	toward = toward.normalized()
	var side := Vector3(-toward.z, 0.0, toward.x)
	var facing := atan2(toward.x, toward.z)
	var hamlet := Node3D.new()
	hamlet.name = "BarrosanHamlet"
	parent.add_child(hamlet)
	var lane_mat := _slice_material("BarrosanHamletLane", Color(0.62, 0.50, 0.36, 0.55), SLICE_DIRT_TEXTURE)
	var lane: Array[Vector3] = [
		origin - toward * 9.0 + Vector3(0, 0.02, 0),
		origin - toward * 18.0 + side * 3.0 + Vector3(0, 0.02, 0),
		origin - toward * 26.0 + side * 1.5 + Vector3(0, 0.02, 0),
		origin - toward * 32.0 - side * 2.0 + Vector3(0, 0.02, 0),
	]
	var widths: Array[float] = [2.6, 3.2, 3.0, 2.2]
	_add_ribbon(hamlet, "HamletLane", lane, widths, lane_mat)
	for i in HAMLET_HOUSES.size():
		var spec: Array = HAMLET_HOUSES[i]
		var pos: Vector3 = origin - toward * float(spec[1]) + side * float(spec[2])
		var house := _place_hamlet_house(hamlet, String(spec[0]), pos, facing + float(spec[3]), float(spec[4]), i)
		if house:
			_dress_hamlet_house(house, pos, toward, i)
	for spec in HAMLET_DRESSING:
		var pos: Vector3 = origin - toward * float(spec[1]) + side * float(spec[2])
		_place_asset(hamlet, String(spec[0]), pos, facing + float(spec[3]))
		if String(spec[0]) == "wall":
			# Garden walls are field boundaries here, lower than the route walls.
			var last := hamlet.get_child(hamlet.get_child_count() - 1) as Node3D
			if last:
				ModelUtils.scale_to_height(last, 1.3)
				ModelUtils.ground_model(last)


func _place_hamlet_house(parent: Node3D, path: String, position: Vector3, yaw: float, height: float, index: int) -> Node3D:
	if not ResourceLoader.exists(path):
		return null
	var packed := load(path)
	if not packed is PackedScene:
		return null
	var house: Node3D = packed.instantiate()
	parent.add_child(house)
	# The A03 source carries review-only ground planes; keep just the houses.
	for mesh in house.find_children("*", "MeshInstance3D", true, false):
		var lower := String(mesh.name).to_lower()
		if lower == "grass" or lower == "lanedirt":
			mesh.get_parent().remove_child(mesh)
			mesh.free()
	ModelUtils.scale_to_height(house, height)
	house.position = position
	house.rotation.y = yaw
	ModelUtils.ground_model(house)
	_set_presentation_only(house, true)
	house.add_to_group("navigation_soft_blockers")
	house.set_meta("navigation_blocker_id", "hamlet_house_%d" % index)
	house.set_meta("navigation_blocker_class", "ASTRA_LARGE")
	return house


func _dress_hamlet_house(house: Node3D, position: Vector3, toward: Vector3, index: int) -> void:
	var bounds := AABB()
	var first := true
	for child in house.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if not mi.mesh:
			continue
		var box: AABB = mi.global_transform * mi.mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	if first:
		return
	# Hearth smoke from the roof ridge, offset toward the back of the house.
	var smoke := ChimneySmoke.new()
	smoke.name = "HearthSmoke%d" % index
	var top := bounds.get_center()
	top.y = bounds.end.y - 0.4
	house.get_parent().add_child(smoke)
	smoke.global_position = top - toward * bounds.size.length() * 0.12
	# A door lantern on the side facing the lane and the base.
	var lantern := BrazierFire.new()
	lantern.name = "DoorLantern%d" % index
	lantern.light_range = 5.5
	lantern.light_energy = 1.6
	lantern.flame_scale = 0.45
	house.get_parent().add_child(lantern)
	var front := bounds.get_center() + toward * (maxf(bounds.size.x, bounds.size.z) * 0.5 + 0.6)
	lantern.global_position = Vector3(front.x, 1.9, front.z)


# Lioraen grove dressing for any Lioraen start: a ring of mossy moonstones
# with faint glyph light around the Groveheart, lume-bloom clumps along the
# edges, drifting pollen motes and a flowering meadow painted by the ground
# shader (bloom zone). Living nature, restrained glow. Presentation only.
const LIORAEN_STONES := [[-13.0, 0.0], [-9.0, -10.0], [-9.0, 10.0], [2.0, -14.0], [2.0, 14.0], [12.0, -8.0], [12.0, 8.0]]
const LIORAEN_BLOOMS := [
	[-11.0, -4.5], [-11.5, 5.0], [-4.0, -13.0], [-3.5, 13.5], [7.0, -12.5], [7.5, 12.0], [15.0, 0.0],
	[-16.0, -8.0], [-16.5, 9.0], [5.0, -17.0], [5.5, 17.5], [17.0, -12.0], [17.5, 12.5], [-6.0, -18.0],
]


func build_lioraen_grove(parent: Node3D, origin: Vector3) -> void:
	var toward := Vector3.ZERO - origin
	toward.y = 0.0
	if toward.length_squared() < 0.01:
		return
	toward = toward.normalized()
	var side := Vector3(-toward.z, 0.0, toward.x)
	var grove := Node3D.new()
	grove.name = "LioraenGrove"
	parent.add_child(grove)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5150
	for spec in LIORAEN_STONES:
		var pos: Vector3 = origin - toward * float(spec[0]) + side * float(spec[1])
		# Stones lean gently toward the Groveheart like a waking circle.
		_place_asset(grove, "moonstone", pos, atan2(origin.x - pos.x, origin.z - pos.z) + rng.randf_range(-0.2, 0.2))
	for spec in LIORAEN_BLOOMS:
		var pos: Vector3 = origin - toward * float(spec[0]) + side * float(spec[1])
		_place_asset(grove, "lume_bloom", pos, rng.randf() * TAU, rng.randf_range(1.6, 2.3))
	var motes := GroveMotes.new()
	motes.name = "GroveMotes"
	motes.radius = 17.0
	grove.add_child(motes)
	motes.global_position = origin + Vector3(0, 1.2, 0)
	var glow := OmniLight3D.new()
	glow.name = "GroveheartGlow"
	glow.light_color = Color(0.70, 1.0, 0.62)
	glow.light_energy = 1.4
	glow.omni_range = 14.0
	glow.shadow_enabled = false
	grove.add_child(glow)
	glow.global_position = origin + Vector3(0, 4.0, 0)


# Vorthak holdfast dressing for an enemy start: a scorched ash yard, broken
# rings of charred basalt masonry, ash-glass outcrops and rift-fire braziers,
# per the art direction (charred masonry, blackened iron, ritual forms; no
# generic spikes). Placed in the start's own frame, presentation only.
const VORTHAK_WALLS := [
	# [back, side, yaw]  (back < 0 is toward the map centre)
	[-14.0, -7.0, 0.35], [-15.0, 8.0, -0.35], [-6.0, -15.0, 1.3], [-5.0, 15.5, -1.25],
	[9.0, -14.5, 1.9], [10.0, 13.5, -1.9], [17.0, -2.0, 0.05],
]
const VORTHAK_GLASS := [[-10.5, -12.5, 0.4], [4.0, 18.0, 1.7], [15.0, 9.0, 2.6], [-2.0, -19.0, 0.9], [20.0, -10.0, 3.3]]
const VORTHAK_BRAZIERS := [[-11.0, -3.5], [-11.0, 3.5], [6.0, -9.0], [6.0, 9.0]]


func build_vorthak_holdfast(parent: Node3D, origin: Vector3) -> void:
	var toward := Vector3.ZERO - origin
	toward.y = 0.0
	if toward.length_squared() < 0.01:
		return
	toward = toward.normalized()
	var side := Vector3(-toward.z, 0.0, toward.x)
	var facing := atan2(toward.x, toward.z)
	var hold := Node3D.new()
	hold.name = "VorthakHoldfast"
	parent.add_child(hold)
	var frame := func(back: float, across: float) -> Vector3:
		return origin - toward * back + side * across
	# The scorched ash yard itself is painted by the ground shader (scorch_zones).
	for spec in VORTHAK_WALLS:
		_place_asset(hold, "charred_wall", frame.call(float(spec[0]), float(spec[1])), facing + float(spec[2]))
	for spec in VORTHAK_GLASS:
		_place_asset(hold, "ash_glass", frame.call(float(spec[0]), float(spec[1])), float(spec[2]))
	var brazier_path: String = BARROSAN_SETTLEMENT_ASSETS["watch_brazier"]
	for spec in VORTHAK_BRAZIERS:
		var packed := load(brazier_path)
		if not packed is PackedScene:
			continue
		var brazier: Node3D = packed.instantiate()
		hold.add_child(brazier)
		brazier.position = frame.call(float(spec[0]), float(spec[1]))
		ModelUtils.ground_model(brazier)
		_apply_settlement_material_cohesion(brazier, "clan_waystone")
		_set_presentation_only(brazier, true)
		var fire := BrazierFire.new()
		fire.violet = true
		fire.fire_color = Color(0.62, 0.30, 1.0)
		fire.light_energy = 2.6
		fire.position = Vector3(0.0, 1.36, 0.0)
		brazier.add_child(fire)


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
	if asset_key == "wall":
		# Retain the wall's X/Z route footprint while lowering its parapet so the
		# opening view is not dominated by a block taller than nearby buildings.
		instance.scale.y *= 0.52
	ModelUtils.ground_model(instance)
	if asset_key in ["wall", "cairn"]:
		_finish_stonework(instance)
	_set_presentation_only(instance)
	_mark_navigation_blocker(instance, asset_key)


func _finish_stonework(root: Node3D) -> void:
	# The wall and cairn GLBs share a plain pale slate material with no albedo
	# map. Give the stone a common matte finish from the existing local atlas;
	# the authored geometry, placement and navigation footprint stay intact.
	var stone_atlas := load(SLICE_ROCK_TEXTURE) as Texture2D
	for child in root.find_children("*", "MeshInstance3D"):
		var mesh_instance := child as MeshInstance3D
		if not mesh_instance or not mesh_instance.mesh:
			continue
		for surface in mesh_instance.mesh.get_surface_count():
			var source := mesh_instance.get_active_material(surface)
			if not source is StandardMaterial3D:
				continue
			var finish := source.duplicate() as StandardMaterial3D
			# The regenerated Blender wall and cairn carry their own stone texture;
			# the dark atlas finish on top of it turned them nearly black.
			if finish.albedo_texture == null:
				finish.albedo_color = Color(0.38, 0.36, 0.31)
				finish.albedo_texture = stone_atlas
			finish.roughness = 1.0
			finish.metallic = 0.0
			mesh_instance.set_surface_override_material(surface, finish)


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
		if asset_key == "watch_brazier":
			var fire := BrazierFire.new()
			fire.name = "BrazierFire"
			fire.position = Vector3(0.0, 1.36, 0.0)
			instance.add_child(fire)
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
