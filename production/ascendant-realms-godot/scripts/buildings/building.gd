class_name Building
extends StaticBody3D
## Data-driven building: construction stages, production queue, research,
## population, defensive towers, drop-off, damage states and destruction.

signal died(building)
signal production_updated
signal construction_completed(building)

var def := {}
var building_id := ""
var team := 0
var commander = null
var world = null

var max_hp := 1000.0
var hp := 1000.0
var armor_class := "fortified"
var base_armor := 0.0
var footprint := 4.0
## Presentation-only height envelope. GameData.footprint remains authoritative
## for placement, collision checks, rally range, and all gameplay queries.
const PRESENTATION_HEIGHT_MULTIPLIER := 1.15
const PRESENTATION_HEIGHT_MIN := 3.2
const PRESENTATION_HEIGHT_MAX := 12.0
## Task604-R1: A01-only presentation lift. GameData.footprint remains the
## gameplay authority; this only gives the authored Clanhold more screen-space
## hierarchy at the normal RTS camera distance.
const TASK604_A01_R1_SCALE := 1.20
const TASK604_A01_R1_YAW_DEGREES := 24.0
## Task606: A02's isolation pad is review staging, not gameplay architecture.
## Strip only the explicitly documented pad leaves before the existing model
## scale/ground/collision flow; the hall, yard wall, gate, training props, and
## other authored architecture remain intact.
const TASK606_A02_MODEL_PATH := "res://assets/environment/buildings/barrosan_war_hall_a02.glb"
const BARROSAN_IRON_FORGE_B01_MODEL_PATH := "res://assets/environment/buildings/barrosan_iron_forge_b01_r2.glb"
## Slice 7: the Forge and Watchtower share generic one-surface source meshes.
## These authored resources preserve their source textures while giving the
## Barrosan production variants a consistent roughness/material response. The
## cache is shared by model path so instances do not duplicate materials.
const SLICE7_IRON_FORGE_MODEL_PATH := "res://assets/environment/buildings/barrosan_iron_forge.glb"
const SLICE7_WATCHTOWER_MODEL_PATH := "res://assets/environment/buildings/barrosan_watchtower.glb"
const SLICE7_IRON_FORGE_MATERIAL_PATH := "res://assets/materials/barrosan/barrosan_iron_forge_surface.tres"
const SLICE7_WATCHTOWER_MATERIAL_PATH := "res://assets/materials/barrosan/barrosan_watchtower_surface.tres"
const BUILD_COMPLETION_CUE_SCALE := 1.045
const BUILD_COMPLETION_CUE_OUT_DURATION := 0.12
const BUILD_COMPLETION_CUE_RETURN_DURATION := 0.28
const RALLY_MARKER_COLOR := Color(1.0, 0.78, 0.30)
const RALLY_MARKER_RING_INNER_RADIUS := 0.62
const RALLY_MARKER_RING_OUTER_RADIUS := 0.78
const SPAWN_UNIT_CLEARANCE := 1.1

# P1 Task603: footprint-aware hover intent, kept separate from owner-only
# selection treatment and never used for placement, collision, or commands.
const TASK603_HOVER_RING_WIDTH := 0.055
const TASK603_HOVER_RING_ALPHA := 0.82

func _debug_review_presentation() -> bool:
	return OS.get_environment("ASCENDANT_GOLDEN_BATTLE_DEBUG_REVIEW") == "1" or OS.get_environment("ASCENDANT_HP4_M20_DIAGNOSTICS") == "1"

var is_built := false
var is_dead := false
var build_progress := 0.0     # 0..1
var build_time := 30.0

# production
var queue: Array = []          # array of {id, kind:"unit"|"tech", time_left, total}
var rally_point := Vector3.ZERO
var _has_rally := false
var _last_queue_frame := -1

# tower
var _tower_cd := 0.0

# aura
var _aura_timer := 0.0
# Vein outposts (docs/claude/RESOURCE_DESIGN.md).
var garrison: Array = []
var outpost_level := 1
var _outpost_timer := 0.0
var _outpost_pay_timer := 0.0
# Per worker per second at level 1. It was 0.5, written down as "about a
# walking worker's pace", but a worker walking between a deposit and the hall
# brings in about 2.3 a second: a base moved onto its veins earned a fifth of
# what its opening did, and every match starved from minute five. At 1.0 a
# first outpost earns 3 a second and four fully expanded ones 42, a little
# more than the fifteen workers of the opening (about 34).
const OUTPOST_RATE := 1.0
const OUTPOST_MAX_LEVEL := 3

var model_root: Node3D
var selection_ring: MeshInstance3D
var _hover_ring: MeshInstance3D
var _hovered := false
var _tower_range_ring: MeshInstance3D
var _mesh_instances: Array = []
var _construct_mat: StandardMaterial3D
var _construction_stage_root: Node3D
var _construction_stage_meshes: Array = []
var _construction_status_label: Label3D
var _construction_status_track: MeshInstance3D
var _construction_status_fill: MeshInstance3D
var _damage_status_label: Label3D
var _damage_status_track: MeshInstance3D
var _damage_status_fill: MeshInstance3D
var _completion_cue_tween: Tween
var _rally_marker: Node3D
var _selection_visual_extents := Vector2(2.0, 2.0)
var _selection_indicator_extents := Vector2(2.2, 2.2)
var _player_visibility_visible := true

static var _visual_identity_materials: Dictionary = {}
static var _visual_identity_box_mesh: BoxMesh
static var _visual_identity_cylinder_mesh: CylinderMesh
static var _slice7_barrosan_surface_materials: Dictionary = {}
static var _building_selection_materials: Dictionary = {}
static var _finial_materials: Dictionary = {}

func _ready() -> void:
	add_to_group("buildings")
	tree_exiting.connect(func(): if is_instance_valid(world) and world.has_method("invalidate_entity_snapshots"): world.invalidate_entity_snapshots())
	collision_layer = 4
	collision_mask = 0

func set_player_visibility_visible(is_visible: bool) -> void:
	_player_visibility_visible = is_visible
	visible = is_visible

func configure(p_def: Dictionary, p_team: int, p_commander, p_world, prebuilt: bool = false) -> void:
	def = p_def
	building_id = p_def.get("id", "")
	team = p_team
	commander = p_commander
	world = p_world
	if world and world.has_method("invalidate_entity_snapshots"):
		world.invalidate_entity_snapshots()
	max_hp = float(p_def.get("hp", 1000))
	# Granitborn castro walls: the hillfort people build stone that does not
	# fall (Karak lost twice to minute-nine rushes over 90 matches).
	if commander and String(commander.race) == "karak":
		max_hp *= 1.25
	# Masonry-type research raises every building's health, new ones included.
	if commander and commander.build_flags.has("building_hp"):
		max_hp *= 1.0 + float(commander.build_flags["building_hp"])
	armor_class = p_def.get("armor_class", "fortified")
	base_armor = float(p_def.get("armor", 0))
	footprint = float(p_def.get("footprint", 4.0))
	build_time = float(p_def.get("build_time", 30.0))
	if commander:
		build_time *= commander.build_speed_mult()
	# New soldiers step out on the side that faces the middle of the field.
	# The default used to be due north for every building, which is the front
	# of a south-western base and the back of a north-eastern one: there the
	# soldiers came out behind their hall, against the map's edge. In mirror
	# matches the south-western start won 23 of 28.
	var field_side := Vector3(-global_position.x, 0.0, -global_position.z)
	field_side = field_side.normalized() if field_side.length() > 6.0 else Vector3(0, 0, 1)
	rally_point = global_position + field_side * (footprint + 3.0)
	if world and world.has_method("clear_ground_cover"):
		world.clear_ground_cover(global_position, footprint * 1.2 + 1.0)
	_build_model()
	_build_team_banner()
	_build_visual_convergence_identity_dressing()
	_build_construction_stage_visual()
	_build_damage_status_visual()
	_build_selection_ring()
	_build_hover_ring()
	_build_tower_range_ring()
	_build_rally_marker()
	if prebuilt:
		is_built = true
		build_progress = 1.0
		hp = max_hp
		_set_construction_visual(1.0)
	else:
		is_built = false
		build_progress = 0.0
		hp = max_hp * 0.15
		_set_construction_visual(0.0)
	_update_damage_visual()

## A convex hull wraps each model part whole, so a yard wall or fence became
## a solid block the size of the whole yard (the War Hall's reached 11.7 m
## from its centre against a 5 m footprint). Troops trained inside it could
## never leave, and routes planned around the footprint ran into it. Keep only
## hulls that stay near the footprint; the footprint blocker covers the rest.
func _drop_oversized_part_hulls(m: Node3D) -> void:
	var limit := footprint * 1.25 + 0.5
	for body in m.find_children("*", "StaticBody3D", true, false):
		var extent := 0.0
		for cs in body.find_children("*", "CollisionShape3D", true, false):
			if cs.shape == null:
				continue
			var dbg = cs.shape.get_debug_mesh()
			if dbg == null:
				continue
			# Walk up to this building by hand: the model is built before the
			# building is placed in the tree.
			var local := Transform3D.IDENTITY
			var n: Node = cs
			while n != null and n != self:
				if n is Node3D:
					local = (n as Node3D).transform * local
				n = n.get_parent()
			var a: AABB = local * dbg.get_aabb()
			extent = maxf(extent, maxf(maxf(absf(a.position.x), absf(a.end.x)), maxf(absf(a.position.z), absf(a.end.z))))
		if extent > limit:
			body.get_parent().remove_child(body)
			body.free()

## Match-load prewarm: run the exact model preparation a real building does
## (staging strips, part isolation, scaling) so the collision hull cache holds
## the same parts. The raw-scene prewarm missed them, and the first Clan Croft
## of a match froze the game for about a quarter of a second.
func prewarm_model(p_def: Dictionary) -> void:
	def = p_def
	footprint = float(p_def.get("footprint", 4.0))
	_build_model()

## Several factions still borrow another faction's building models (the
## Careto Host lives in Barrosan houses). Until each has its own, a borrowed
## model takes its owner's palette so a base reads as that faction at a glance.
const FACTION_PALETTES := {
	"frostborn": Color(1.08, 0.86, 0.84),   # Careto red-and-green revel
	"karak": Color(0.86, 0.88, 0.95),       # Granitborn castro stone
	"sunspear": Color(1.1, 0.95, 0.72),     # Aurean bronze and sun
	"grimtusk": Color(0.92, 0.78, 0.7),     # Ironmaw rust and chain
	"sylvan": Color(0.88, 0.94, 1.1),       # Moura silver
	"wyldkin": Color(0.84, 0.92, 0.78),     # Wolfveil moss and moon
	"hollow": Color(0.74, 0.72, 0.82),      # Compaña candle-dark
	"lioraen": Color(0.9, 1.05, 0.88),
	"vorthak": Color(0.9, 0.82, 1.0),
}
static var _palette_materials: Dictionary = {}

func _apply_faction_palette(m: Node, path: String) -> void:
	var race := String(def.get("race", ""))
	if race == "" or path.get_file().begins_with(race) or not FACTION_PALETTES.has(race):
		return
	var tint: Color = FACTION_PALETTES[race]
	for mi in m.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mi as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for i in mesh_instance.mesh.get_surface_count():
			var mat = mesh_instance.get_active_material(i)
			if not (mat is BaseMaterial3D):
				continue
			var key := "%s|%d" % [race, mat.get_instance_id()]
			if not _palette_materials.has(key):
				var tinted := (mat as BaseMaterial3D).duplicate() as BaseMaterial3D
				tinted.albedo_color = Color(tinted.albedo_color.r * tint.r, tinted.albedo_color.g * tint.g, tinted.albedo_color.b * tint.b, tinted.albedo_color.a)
				_palette_materials[key] = tinted
			mesh_instance.set_surface_override_material(i, _palette_materials[key])

## Widest horizontal extent of a model in world metres (the same corner
## walk ModelUtils.measure_height does, on X and Z).
func _world_width(node: Node3D) -> float:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for child in node.find_children("*", "MeshInstance3D"):
		var mi := child as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		var box: AABB = mi.get_aabb()
		for corner_idx in 8:
			var p: Vector3 = mi.to_global(box.get_endpoint(corner_idx))
			lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.z))
			hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.z))
	return maxf(hi.x - lo.x, hi.y - lo.y) if lo.x != INF else 0.0

## The authored Barrosan hall, war hall and house are built from 150 to 350
## separate pieces, and every piece is a draw call in every pass (colour,
## depth, each shadow split): one hall cost more than all the other buildings
## on the map together, and a Barrosan base ran to thousands of draw calls.
## Once the model is dressed and its collision hulls exist, the pieces are
## joined into one mesh with a surface for each distinct material. The hulls
## move to the model's root; nothing else about the building changes.
const MERGE_PARTS_OVER := 24
static var _merged_parts_cache := {}

static func _material_signature(mat: Material) -> String:
	if mat is BaseMaterial3D:
		var b := mat as BaseMaterial3D
		return "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s" % [b.get_class(), str(b.albedo_texture), str(b.albedo_color), str(b.roughness), str(b.roughness_texture), str(b.metallic), str(b.metallic_texture), str(b.normal_enabled), str(b.normal_texture), str(b.transparency), str(b.cull_mode), str(b.emission_enabled) + str(b.emission) + str(b.emission_texture), str(b.uv1_scale) + str(b.uv1_offset), str(b.shading_mode) + str(b.vertex_color_use_as_albedo) + str(b.texture_filter), str(b.ao_enabled) + str(b.ao_texture)]
	return "id:%d" % mat.get_instance_id()

static func _transform_up_to(node: Node, ancestor: Node) -> Transform3D:
	var xf := Transform3D.IDENTITY
	var n: Node = node
	while n != null and n != ancestor:
		if n is Node3D:
			xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf

func _merge_static_parts(m: Node3D, path: String) -> void:
	var parts: Array = []
	for child in m.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if mi == null or mi.mesh == null:
			continue
		# Anything skinned or drawn with a shader of its own stays as it is.
		if mi.skeleton != NodePath("") and mi.get_node_or_null(mi.skeleton) is Skeleton3D:
			return
		if mi.material_override != null and not (mi.material_override is BaseMaterial3D):
			return
		for surface in mi.mesh.get_surface_count():
			if not (mi.get_active_material(surface) is BaseMaterial3D):
				return
		parts.append(mi)
	if parts.size() <= MERGE_PARTS_OVER:
		return
	var cache_key := "%s|%s" % [path, String(def.get("race", ""))]
	var merged: Array = _merged_parts_cache.get(cache_key, [])
	if merged.is_empty():
		# One mesh for each shadow setting, one surface for each material.
		var tools := {}
		var materials := {}
		var order: Array = []
		for part in parts:
			var mi := part as MeshInstance3D
			var xform := _transform_up_to(mi, m)
			for surface in mi.mesh.get_surface_count():
				var mat: Material = mi.get_active_material(surface)
				var key := "%d|%s" % [int(mi.cast_shadow), _material_signature(mat)]
				if not tools.has(key):
					var st := SurfaceTool.new()
					st.begin(Mesh.PRIMITIVE_TRIANGLES)
					tools[key] = st
					materials[key] = mat
					order.append(key)
				(tools[key] as SurfaceTool).append_from(mi.mesh, surface, xform)
		var by_shadow := {}
		for key in order:
			var shadow := int(String(key).get_slice("|", 0))
			var mesh: ArrayMesh = by_shadow.get(shadow)
			if mesh == null:
				mesh = ArrayMesh.new()
				by_shadow[shadow] = mesh
			(tools[key] as SurfaceTool).commit(mesh)
			mesh.surface_set_material(mesh.get_surface_count() - 1, materials[key])
		for shadow in by_shadow:
			merged.append([by_shadow[shadow], shadow])
		_merged_parts_cache[cache_key] = merged
	# The collision hulls hang from the parts they were made from.
	for part in parts:
		var mi := part as MeshInstance3D
		for child in mi.get_children():
			if child is StaticBody3D:
				var body := child as StaticBody3D
				var body_xform := _transform_up_to(mi, m) * body.transform
				mi.remove_child(body)
				m.add_child(body)
				body.transform = body_xform
	for part in parts:
		if is_instance_valid(part) and not (part as Node).is_queued_for_deletion():
			var holder: Node = (part as Node).get_parent()
			if holder:
				holder.remove_child(part)
			# Let go of the mesh first: a part freed while it still held a
			# material nobody else uses made the renderer report a null material.
			(part as MeshInstance3D).mesh = null
			(part as Node).free()
	for entry in merged:
		var joined := MeshInstance3D.new()
		joined.name = "JoinedParts"
		joined.mesh = entry[0]
		joined.cast_shadow = int(entry[1]) as GeometryInstance3D.ShadowCastingSetting
		m.add_child(joined)
		# The building looks its model's meshes up with find_children(), which
		# only returns nodes that have an owner.
		joined.owner = m

func _build_model() -> void:
	model_root = Node3D.new()
	model_root.name = "MeshRoot"
	add_child(model_root)
	var path: String = def.get("model", "")
	if path != "" and ResourceLoader.exists(path):
		var load_start := Time.get_ticks_usec()
		var m = load(path).instantiate()
		var recorder = get_node_or_null("/root/HP4M20Startup")
		if recorder and OS.get_environment("ASCENDANT_HP4_M20_DIAGNOSTICS") == "1":
			recorder.record_resource_load(path, "building._build_model", load_start, Time.get_ticks_usec(), "load_instantiate")
		model_root.add_child(m)
		_strip_a01_review_staging(m, path)
		_strip_a02_review_staging(m, path)
		if path == TASK606_A02_MODEL_PATH:
			# The authored A02 foundation and wall cast a single hard-edged slab
			# shadow at the default RTS light. Keep the geometry/materials but make
			# this one production building presentation-only for shadowing.
			for geometry in m.find_children("*", "GeometryInstance3D"):
				(geometry as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if path == "res://assets/environment/buildings/barrosan_houses_a03.glb":
			ModelUtils.isolate_a03_house_a(m)
		_normalize_a02_imported_materials(m, path)
		_apply_slice7_barrosan_surface_material(m, path)
		_apply_faction_palette(m, path)
		if _is_a01_model_path(path):
			m.rotation.y = deg_to_rad(TASK604_A01_R1_YAW_DEGREES)
		# scale building to a sensible footprint-based size
		var target_h: float = _presentation_height()
		if _is_a01_model_path(path):
			target_h = minf(PRESENTATION_HEIGHT_MAX, target_h * TASK604_A01_R1_SCALE)
		ModelUtils.scale_to_height(m, target_h)
		# A slim borrowed model (an arch, a shrine, a hut) scaled by height
		# alone filled a fraction of its plot: the other peoples' halls looked
		# like sheds beside the Barrosan ones, and a landmark's plaza dwarfed
		# its own hall. Widen such a model to fill most of its plot, growing
		# at most 70%. Towers stay slim; the authored Barrosan set is left as is.
		if String(def.get("kind", "")) != "tower" and String(def.get("race", "")) != "barrosan":
			var model_width: float = _world_width(m)
			var want_width: float = footprint * 1.55
			if model_width > 0.01 and model_width < want_width:
				m.scale *= minf(want_width / model_width, 1.7)
		ModelUtils.ground_model(m)
		# Same hulls as before, but shapes are generated once per model and
		# reused (and prewarmed at match load by GameWorld).
		ModelUtils.add_cached_per_part_convex_collision(m, 4, path)
		_drop_oversized_part_hulls(m)
		if path == "res://assets/environment/buildings/barrosan_houses_a03.glb":
			ModelUtils.recenter_a03_house_a_visual_only(m)
		_merge_static_parts(m, path)
		for mi in m.find_children("*", "MeshInstance3D"):
			_mesh_instances.append(mi)
	else:
		var mi := MeshInstance3D.new()
		var bm := BoxMesh.new()
		var presentation_height := _presentation_height()
		bm.size = Vector3(footprint * 1.2, presentation_height, footprint * 1.2)
		mi.mesh = bm
		mi.position.y = presentation_height * 0.5
		var mat := StandardMaterial3D.new()
		mat.albedo_color = commander.color.lerp(Color(0.5,0.5,0.5), 0.5) if commander else Color.GRAY
		mi.material_override = mat
		model_root.add_child(mi)
		_mesh_instances.append(mi)
	_add_selection_pick_shape()


static var _banner_material: ShaderMaterial
static var _banner_wood: StandardMaterial3D

func _build_team_banner() -> void:
	# A waving banner in the owner's colour at the front corner of every
	# building, so ownership reads at a glance on any map. Presentation only.
	if _banner_material == null:
		_banner_material = ShaderMaterial.new()
		_banner_material.shader = load("res://assets/shaders/team_banner.gdshader")
		_banner_wood = StandardMaterial3D.new()
		_banner_wood.albedo_color = Color(0.22, 0.15, 0.09)
		_banner_wood.roughness = 0.9
	var root := Node3D.new()
	root.name = "TeamBanner"
	add_child(root)
	var big := bool(def.get("is_hq", false))
	var pole_h := 4.2 if big else 3.3
	root.position = Vector3(footprint * 0.95 + 0.4, 0.0, footprint * 0.95 + 0.4)
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.05
	pole_mesh.bottom_radius = 0.07
	pole_mesh.height = pole_h
	pole_mesh.radial_segments = 8
	pole.mesh = pole_mesh
	pole.material_override = _banner_wood
	pole.position.y = pole_h * 0.5
	root.add_child(pole)
	# Endless Road milestones crown the player's banners: silver from stage
	# 50, gold from 100, Lume-violet from 200. Cosmetic only.
	if world and team == int(world.get("player_team")) and ProfileManager.has_hero():
		var best: int = ProfileManager.endless_best()
		if best >= 50:
			var tint := Color(0.78, 0.8, 0.86) if best < 100 else (Color(1.0, 0.8, 0.3) if best < 200 else Color(0.72, 0.45, 1.0))
			if _finial_materials.get(tint.to_html(), null) == null:
				var fm := StandardMaterial3D.new()
				fm.albedo_color = tint
				fm.metallic = 0.8
				fm.roughness = 0.3
				fm.emission_enabled = true
				fm.emission = tint * 0.6
				_finial_materials[tint.to_html()] = fm
			var finial := MeshInstance3D.new()
			var fmesh := SphereMesh.new()
			fmesh.radius = 0.2
			fmesh.height = 0.4
			finial.mesh = fmesh
			finial.material_override = _finial_materials[tint.to_html()]
			finial.position.y = pole_h + 0.12
			root.add_child(finial)
	var bar := MeshInstance3D.new()
	var bar_mesh := BoxMesh.new()
	bar_mesh.size = Vector3(1.05, 0.06, 0.06)
	bar.mesh = bar_mesh
	bar.material_override = _banner_wood
	bar.position = Vector3(0.5, pole_h - 0.12, 0.0)
	root.add_child(bar)
	var cloth := MeshInstance3D.new()
	var cloth_mesh := PlaneMesh.new()
	cloth_mesh.orientation = PlaneMesh.FACE_Z
	var cloth_h := 1.9 if big else 1.45
	cloth_mesh.size = Vector2(0.9, cloth_h)
	cloth_mesh.subdivide_width = 3
	cloth_mesh.subdivide_depth = 12
	cloth.mesh = cloth_mesh
	cloth.material_override = _banner_material
	cloth.position = Vector3(0.55, pole_h - 0.15 - cloth_h * 0.5, 0.0)
	cloth.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	cloth.set_instance_shader_parameter("team_color", GameData.TEAM_COLORS.get(team, Color(0.8, 0.8, 0.8)))
	root.add_child(cloth)

func _build_visual_convergence_identity_dressing() -> void:
	# Slice 2 is a Hollowspan-only presentation layer. It gives each Barrosan
	# building a restrained functional ground transition and a small identity
	# cluster without replacing the authored source model or touching gameplay
	# collision, footprint, navigation, or buildability.
	if not world or world.map.get("id", "") != "hollowspan":
		return
	if String(def.get("race", "")) != "barrosan":
		return
	if building_id == "barrosan_iron_forge" and String(def.get("model", "")) == BARROSAN_IRON_FORGE_B01_MODEL_PATH:
		return
	var root := Node3D.new()
	root.name = "VisualConvergenceIdentityDressing"
	add_child(root)
	var stone := _visual_identity_material("stone", Color(0.26, 0.27, 0.25), 0.94)
	var timber := _visual_identity_material("timber", Color(0.15, 0.09, 0.055), 0.9)
	var iron := _visual_identity_material("iron", Color(0.32, 0.24, 0.17), 0.76, 0.12)
	var accent := _visual_identity_material("accent", Color(0.42, 0.12, 0.095), 0.92)
	# Do not add a broad opaque floor box here. The prior presentation layer
	# produced repeated dark rectangles beneath every production building at RTS
	# zoom; authored buildings already provide their own grounded contact.

	match building_id:
		"barrosan_clanhold":
			for x in [-footprint * 0.92, footprint * 0.92]:
				for z in [-footprint * 0.92, footprint * 0.92]:
					_add_visual_identity_cylinder(root, 0.16, 0.72, Vector3(x, 0.36, z), stone, "ClanholdFoundationMarker")
		"barrosan_war_hall":
			for point in [Vector3(-footprint * 0.86, 0.42, -footprint * 0.86), Vector3(footprint * 0.86, 0.42, -footprint * 0.86), Vector3(-footprint * 0.86, 0.42, footprint * 0.86), Vector3(footprint * 0.86, 0.42, footprint * 0.86)]:
				_add_visual_identity_cylinder(root, 0.14, 0.84, point, timber, "TrainingPost")
			_add_visual_identity_rail(root, Vector3(-footprint * 0.95, 0.58, -footprint - 0.6), Vector3(footprint * 0.95, 0.58, -footprint - 0.6), timber, "WarHallTrainingRail")
			_add_visual_identity_box(root, Vector3(footprint * 1.4, 0.13, 0.13), Vector3(0, 0.92, -footprint - 0.6), iron, "WarHallWeaponRack")
		"barrosan_clan_croft":
			var span := footprint * 1.1
			for point in [Vector3(-span, 0.34, -span), Vector3(span, 0.34, -span), Vector3(-span, 0.34, span), Vector3(span, 0.34, span)]:
				_add_visual_identity_cylinder(root, 0.12, 0.68, point, timber, "CroftFencePost")
			_add_visual_identity_rail(root, Vector3(-span, 0.46, -span), Vector3(span, 0.46, -span), timber, "CroftFenceRail")
			_add_visual_identity_rail(root, Vector3(span, 0.46, -span), Vector3(span, 0.46, span), timber, "CroftFenceRail")
			_add_visual_identity_cylinder(root, 0.34, 0.72, Vector3(-footprint - 0.55, 0.36, footprint * 0.5), timber, "CroftHayBale")
			_add_visual_identity_cylinder(root, 0.34, 0.72, Vector3(-footprint - 0.55, 0.36, -footprint * 0.5), timber, "CroftHayBale")
		"barrosan_iron_forge":
			_add_visual_identity_box(root, Vector3(1.4, 0.72, 0.55), Vector3(footprint + 0.6, 0.36, -0.55), timber, "ForgeWorkbench")
			_add_visual_identity_box(root, Vector3(0.42, 0.78, 0.42), Vector3(footprint + 0.6, 0.39, 0.52), iron, "ForgeAnvil")
			_add_visual_identity_cylinder(root, 0.28, 0.48, Vector3(-footprint - 0.42, 0.24, -0.50), iron, "ForgeBrazier")
			_add_visual_identity_cylinder(root, 0.28, 0.48, Vector3(-footprint - 0.42, 0.24, 0.50), iron, "ForgeBrazier")
			_add_visual_identity_box(root, Vector3(0.65, 0.9, 0.65), Vector3(footprint + 0.6, 0.45, 1.15), stone, "ForgeStoneStack")
		"barrosan_watchtower":
			for point in [Vector3(-footprint * 0.9, 0.24, -footprint * 0.9), Vector3(footprint * 0.9, 0.24, -footprint * 0.9), Vector3(-footprint * 0.9, 0.24, footprint * 0.9), Vector3(footprint * 0.9, 0.24, footprint * 0.9)]:
				_add_visual_identity_cylinder(root, 0.22, 0.48, point, stone, "WatchtowerFoundationStone")
			_add_visual_identity_cylinder(root, 0.08, 2.0, Vector3(footprint + 0.65, 1.0, 0), timber, "WatchtowerBannerPole")
			_add_visual_identity_box(root, Vector3(0.08, 0.72, 0.46), Vector3(footprint + 0.65, 1.45, 0), accent, "WatchtowerBanner")


func _visual_identity_material(key: String, color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	if _visual_identity_materials.has(key):
		return _visual_identity_materials[key]
	var mat := StandardMaterial3D.new()
	mat.resource_name = "VisualConvergence_%s" % key
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	_visual_identity_materials[key] = mat
	return mat


func _visual_identity_box() -> BoxMesh:
	if is_instance_valid(_visual_identity_box_mesh):
		return _visual_identity_box_mesh
	_visual_identity_box_mesh = BoxMesh.new()
	_visual_identity_box_mesh.size = Vector3.ONE
	_visual_identity_box_mesh.resource_name = "VisualConvergence_UnitBox"
	return _visual_identity_box_mesh


func _visual_identity_cylinder() -> CylinderMesh:
	if is_instance_valid(_visual_identity_cylinder_mesh):
		return _visual_identity_cylinder_mesh
	_visual_identity_cylinder_mesh = CylinderMesh.new()
	_visual_identity_cylinder_mesh.top_radius = 0.5
	_visual_identity_cylinder_mesh.bottom_radius = 0.54
	_visual_identity_cylinder_mesh.height = 1.0
	_visual_identity_cylinder_mesh.radial_segments = 8
	_visual_identity_cylinder_mesh.resource_name = "VisualConvergence_UnitCylinder"
	return _visual_identity_cylinder_mesh


func _add_visual_identity_mesh(parent: Node3D, mesh: Mesh, position: Vector3, mat: Material, node_name: String) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = mesh
	mi.position = position
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


func _add_visual_identity_box(parent: Node3D, size: Vector3, position: Vector3, mat: Material, node_name: String) -> void:
	var mi := _add_visual_identity_mesh(parent, _visual_identity_box(), position, mat, node_name)
	mi.scale = size


func _add_visual_identity_cylinder(parent: Node3D, radius: float, height: float, position: Vector3, mat: Material, node_name: String) -> void:
	var mi := _add_visual_identity_mesh(parent, _visual_identity_cylinder(), position, mat, node_name)
	mi.scale = Vector3(radius * 2.0, height, radius * 2.0)


func _add_visual_identity_rail(parent: Node3D, from: Vector3, to: Vector3, mat: Material, node_name: String) -> void:
	var delta := to - from
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.mesh = _visual_identity_box()
	mi.scale = Vector3(0.14, 0.14, delta.length())
	mi.position = from.lerp(to, 0.5)
	mi.rotation.y = atan2(delta.x, delta.z)
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)


func _normalize_a02_imported_materials(model: Node3D, path: String) -> void:
	# Task606-R1: the accepted A02 GLB carries albedo-only textures, but the
	# colliding loose texture imports can make Godot bind each albedo texture as
	# both albedo and normal. Duplicate only the affected A02 surface material so
	# the source GLB and all other building presentation remain untouched.
	if path != TASK606_A02_MODEL_PATH:
		return
	for child in model.find_children("*", "MeshInstance3D"):
		var mesh := child as MeshInstance3D
		if not mesh or not mesh.mesh:
			continue
		for surface in mesh.mesh.get_surface_count():
			var material := mesh.get_active_material(surface)
			if not material is BaseMaterial3D:
				continue
			var base := material as BaseMaterial3D
			if not base.normal_enabled or base.normal_texture == null or base.normal_texture != base.albedo_texture:
				continue
			var repaired := base.duplicate() as BaseMaterial3D
			repaired.normal_enabled = false
			repaired.normal_texture = null
			mesh.set_surface_override_material(surface, repaired)


func _apply_slice7_barrosan_surface_material(model: Node3D, path: String) -> void:
	# Only the Barrosan variants receive this presentation binding. The same
	# source GLBs are reused by other factions, so identity must not leak across
	# faction definitions. Existing authored A01/A02/A03 material slots remain
	# untouched; Slice 7 closes the generic single-material gap on the Forge and
	# Watchtower without changing geometry, collision, or gameplay semantics.
	if String(def.get("race", "")) != "barrosan":
		return
	var material_path := ""
	if path == SLICE7_IRON_FORGE_MODEL_PATH:
		material_path = SLICE7_IRON_FORGE_MATERIAL_PATH
	elif path == SLICE7_WATCHTOWER_MODEL_PATH:
		material_path = SLICE7_WATCHTOWER_MATERIAL_PATH
	else:
		return
	var surface_material: Material = _slice7_barrosan_surface_materials.get(material_path)
	if not surface_material:
		surface_material = load(material_path) as Material
		if not surface_material:
			return
		_slice7_barrosan_surface_materials[material_path] = surface_material
	for child in model.find_children("*", "MeshInstance3D"):
		var mesh := child as MeshInstance3D
		if not mesh or not mesh.mesh or mesh.mesh.get_surface_count() != 1:
			continue
		mesh.material_override = surface_material


static func _strip_a01_review_staging(model: Node3D, path: String) -> void:
	# A01's yard and fence are review-scene staging geometry, not part of the
	# production main hall. Remove only those named mesh leaves before height,
	# grounding, and standard collision generation so the authored keep remains
	# inside the existing gameplay footprint and interaction contract.
	if path != "res://assets/environment/buildings/barrosan_civic_keep_a01.glb":
		return
	for child in model.find_children("*", "MeshInstance3D"):
		var mesh := child as MeshInstance3D
		if not mesh:
			continue
		var lower_name := mesh.name.to_lower()
		if not ("yard" in lower_name or "fence" in lower_name):
			continue
		var parent := mesh.get_parent()
		if parent:
			parent.remove_child(mesh)
		mesh.free()

static func _strip_a02_review_staging(model: Node3D, path: String) -> void:
	# GROK-ART-A02-R2 documents the grass/isolation pad and packed-yard planes
	# as review convention only. Remove only those exact authored leaves; do not
	# treat legitimate hall, palisade, gate, dummy, rack, banner, or shed meshes
	# as staging merely because they are decorative.
	if path != TASK606_A02_MODEL_PATH:
		return
	for child in model.find_children("*", "MeshInstance3D"):
		var mesh := child as MeshInstance3D
		if not mesh:
			continue
		var lower_name := mesh.name.to_lower()
		if lower_name not in ["yardgrass", "yardpacked", "yardpackedwear"]:
			continue
		var parent := mesh.get_parent()
		if parent:
			parent.remove_child(mesh)
		mesh.free()

func _is_a01_model_path(path: String) -> bool:
	return path == "res://assets/environment/buildings/barrosan_civic_keep_a01.glb"


func _build_construction_stage_visual() -> void:
	# Non-colliding presentation geometry only. Existing gameplay building
	# models remain authoritative; these timber frames make foundation/early
	# construction legible before the model becomes opaque.
	_construction_stage_root = Node3D.new()
	_construction_stage_root.name = "ConstructionStageVisual"
	_construction_stage_root.position.y = 0.04
	add_child(_construction_stage_root)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.34, 0.16, 0.82)
	mat.roughness = 0.92
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	var span := maxf(1.3, footprint * 0.44)
	var post_height := maxf(1.1, _presentation_height() * 0.72)
	for x in [-span, span]:
		for z in [-span, span]:
			var post := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.10
			cm.bottom_radius = 0.14
			cm.height = post_height
			post.mesh = cm
			post.position = Vector3(x, post_height * 0.5, z)
			post.material_override = mat
			post.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			_construction_stage_root.add_child(post)
			_construction_stage_meshes.append(post)
	for z in [-span, span]:
		var beam := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(span * 2.0, 0.16, 0.16)
		beam.mesh = bm
		beam.position = Vector3(0, post_height, z)
		beam.material_override = mat
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		_construction_stage_root.add_child(beam)
		_construction_stage_meshes.append(beam)
	_build_construction_status_visual()

func _build_construction_status_visual() -> void:
	# Keep construction progress readable from the battlefield, not only from the
	# selected-card panel. This is presentation-only and follows build_progress.
	_construction_status_label = Label3D.new()
	_construction_status_label.name = "ConstructionStatus"
	_construction_status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_construction_status_label.no_depth_test = true
	_construction_status_label.font_size = 48
	_construction_status_label.outline_size = 14
	_construction_status_label.pixel_size = 0.008
	_construction_status_label.modulate = Color(1.0, 0.92, 0.58, 1.0)
	_construction_status_label.position = Vector3(0, _presentation_height() + 1.1, 0)
	add_child(_construction_status_label)

	_construction_status_track = MeshInstance3D.new()
	_construction_status_track.name = "ConstructionProgressTrack"
	var track_mesh := BoxMesh.new()
	track_mesh.size = Vector3(maxf(1.8, footprint * 0.85), 0.09, 0.08)
	_construction_status_track.mesh = track_mesh
	var track_mat := StandardMaterial3D.new()
	track_mat.albedo_color = Color(0.08, 0.06, 0.04, 0.88)
	track_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_construction_status_track.material_override = track_mat
	_construction_status_track.position = Vector3(0, _presentation_height() + 0.78, 0)
	_construction_status_track.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_construction_status_track)

	_construction_status_fill = MeshInstance3D.new()
	_construction_status_fill.name = "ConstructionProgressFill"
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(maxf(1.8, footprint * 0.85), 0.11, 0.1)
	_construction_status_fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.95, 0.62, 0.18, 0.98)
	fill_mat.emission_enabled = true
	fill_mat.emission = Color(0.55, 0.22, 0.04)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_construction_status_fill.material_override = fill_mat
	_construction_status_fill.position = Vector3(0, _presentation_height() + 0.78, 0.055)
	_construction_status_fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_construction_status_fill)

func _add_selection_pick_shape() -> void:
	## Shared world-blocking envelope for visible-footprint coverage. Units own
	## the opposing mask; navigation detours are registered by GameWorld.
	var extents := _measure_selection_visual_extents()
	var height := maxf(1.0, footprint * 1.4)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(extents.x * 2.0, height, extents.y * 2.0)
	shape.shape = box
	shape.position.y = height * 0.5
	add_child(shape)

func _presentation_height() -> float:
	return clampf(footprint * PRESENTATION_HEIGHT_MULTIPLIER, PRESENTATION_HEIGHT_MIN, PRESENTATION_HEIGHT_MAX)

func _build_selection_ring() -> void:
	selection_ring = MeshInstance3D.new()
	_selection_visual_extents = _measure_selection_visual_extents()
	_selection_indicator_extents = Vector2(
		_selection_visual_extents.x * 1.12,
		_selection_visual_extents.y * 1.12)
	# Same glowing ring with turning brackets as units (unit-radius quad; the
	# ring sits at 72% of its half-width, so this keeps the old radius of 1).
	var quad := QuadMesh.new()
	quad.orientation = PlaneMesh.FACE_Y
	quad.size = Vector2.ONE * (2.0 / 0.72)
	selection_ring.mesh = quad
	# Buildings occupy much more screen space than units. Keep the team-colour
	# selection cue, but let the architecture remain the visual focus.
	var team_color: Color = commander.color if commander else Color.WHITE
	var material_key := team_color.to_html(false)
	if not _building_selection_materials.has(material_key):
		var selection_material := CombatVfx.selection_ring_material(team_color).duplicate() as ShaderMaterial
		selection_material.set_shader_parameter("energy", 0.56)
		selection_material.set_shader_parameter("ring_width", 0.018)
		selection_material.set_shader_parameter("glow_width", 0.06)
		selection_material.set_shader_parameter("bracket_strength", 0.52)
		selection_material.set_shader_parameter("wash_strength", 0.025)
		_building_selection_materials[material_key] = selection_material
	selection_ring.material_override = _building_selection_materials[material_key]
	selection_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	selection_ring.position.y = 0.1
	selection_ring.scale = Vector3(_selection_indicator_extents.x, 1.0, _selection_indicator_extents.y)
	selection_ring.visible = false
	add_child(selection_ring)

func _task603_player_friendly() -> bool:
	return not is_instance_valid(world) or int(team) == int(world.player_team)

func _task603_hover_color() -> Color:
	return Color(0.48, 0.86, 1.0, TASK603_HOVER_RING_ALPHA) if _task603_player_friendly() else Color(1.0, 0.30, 0.22, TASK603_HOVER_RING_ALPHA)

func _build_hover_ring() -> void:
	_hover_ring = MeshInstance3D.new()
	_hover_ring.name = "HoverIntentRing"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.91
	torus.outer_radius = 0.965
	torus.rings = 32
	torus.ring_segments = 8
	_hover_ring.mesh = torus
	_hover_ring.scale = Vector3(_selection_indicator_extents.x * 1.06, 1.0, _selection_indicator_extents.y * 1.06)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = _task603_hover_color()
	mat.emission_enabled = true
	mat.emission = _task603_hover_color()
	mat.emission_energy_multiplier = 1.15
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_hover_ring.material_override = mat
	_hover_ring.position.y = 0.13
	_hover_ring.visible = false
	_hover_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_hover_ring)

func set_hovered(active: bool) -> void:
	_hovered = active
	if is_instance_valid(_hover_ring):
		_hover_ring.visible = active and is_built and not is_dead and not (is_instance_valid(selection_ring) and selection_ring.visible)

func _build_tower_range_ring() -> void:
	if not def.has("tower_dmg") or not def.has("tower_range"):
		return
	_tower_range_ring = MeshInstance3D.new()
	_tower_range_ring.name = "TowerAttackRange"
	var torus := TorusMesh.new()
	var tower_range := maxf(0.5, float(def.get("tower_range", 18.0)))
	torus.inner_radius = tower_range * 0.985
	torus.outer_radius = tower_range * 1.015
	torus.rings = 64
	torus.ring_segments = 8
	_tower_range_ring.mesh = torus
	var mat := StandardMaterial3D.new()
	var team_color: Color = Color.WHITE
	if commander:
		team_color = commander.color
	mat.albedo_color = Color(team_color.r, team_color.g, team_color.b, 0.30)
	mat.emission_enabled = true
	mat.emission = team_color
	mat.emission_energy_multiplier = 1.25
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_tower_range_ring.material_override = mat
	_tower_range_ring.position.y = 0.08
	_tower_range_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_tower_range_ring.visible = false
	add_child(_tower_range_ring)

func _measure_selection_visual_extents() -> Vector2:
	if not is_instance_valid(model_root):
		return Vector2(footprint * 0.7, footprint * 0.7)
	var combined := AABB()
	var first := true
	for child in model_root.find_children("*", "MeshInstance3D"):
		var mi := child as MeshInstance3D
		if not mi or not mi.mesh:
			continue
		var local_transform := model_root.global_transform.inverse() * mi.global_transform if model_root.is_inside_tree() else mi.transform
		var transformed := local_transform * mi.mesh.get_aabb()
		if first:
			combined = transformed
			first = false
		else:
			combined = combined.merge(transformed)
	if first:
		return Vector2(footprint * 0.7, footprint * 0.7)
	return Vector2(maxf(0.5, combined.size.x * 0.5), maxf(0.5, combined.size.z * 0.5))

func get_selection_geometry() -> Dictionary:
	return {
		"entity_type": "building",
		"visual_extents": {"x": _selection_visual_extents.x, "z": _selection_visual_extents.y},
		"indicator_extents": {"x": _selection_indicator_extents.x, "z": _selection_indicator_extents.y},
		"indicator_y": selection_ring.position.y if is_instance_valid(selection_ring) else 0.0,
		"indicator_scale": {"x": selection_ring.scale.x, "z": selection_ring.scale.z} if is_instance_valid(selection_ring) else {"x": 0.0, "z": 0.0},
		"selected": selection_ring.visible if is_instance_valid(selection_ring) else false,
		"collision_layer": collision_layer,
		"collision_mask": collision_mask,
		"position": {"x": global_position.x, "y": global_position.y, "z": global_position.z}
	}

func set_selected(sel: bool) -> void:
	if selection_ring:
		selection_ring.visible = sel
	set_hovered(_hovered)
	if _tower_range_ring:
		_tower_range_ring.visible = sel and is_built and not is_dead
	_show_fortify_ring(sel)
	_refresh_rally_marker(sel)

## A selected building with a reach shows it on the ground: a Barrosan
## Clanhold's Fortify in gold (22 m, your units inside gain armour) and a
## healing aura such as the Lioraen Groveheart's in green.
var _fortify_ring: MeshInstance3D

func _show_fortify_ring(sel: bool) -> void:
	var reach := 0.0
	var tint := Color(1.0, 0.8, 0.38)
	if commander and String(commander.race) == "barrosan" and bool(def.get("is_hq", false)):
		reach = 22.0
	elif def.has("heal_aura"):
		reach = float(def.get("heal_aura_range", 16.0))
		tint = Color(0.5, 1.0, 0.55)
	elif def.has("landmark"):
		reach = float(def.get("reach", 20.0))
		tint = LANDMARK_TINT.get(String(def["landmark"]), tint)
	if reach <= 0.0:
		return
	if not is_instance_valid(_fortify_ring):
		if not sel:
			return
		_fortify_ring = MeshInstance3D.new()
		_fortify_ring.name = "FortifyReach"
		var torus := TorusMesh.new()
		torus.inner_radius = reach - 0.2
		torus.outer_radius = reach + 0.2
		torus.rings = 96
		torus.ring_segments = 6
		_fortify_ring.mesh = torus
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(tint, 0.55)
		mat.emission_enabled = true
		mat.emission = tint
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_fortify_ring.material_override = mat
		_fortify_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_fortify_ring)
		_fortify_ring.position.y = 0.1
	_fortify_ring.visible = sel and is_built and not is_dead

func _is_rally_capable() -> bool:
	return is_built and not is_dead and not Array(def.get("produces", [])).is_empty()

func _build_rally_marker() -> void:
	_rally_marker = Node3D.new()
	_rally_marker.name = "RallyDestinationMarker"
	_rally_marker.visible = false
	add_child(_rally_marker)

	var ring := MeshInstance3D.new()
	ring.name = "RallyGroundReticle"
	var torus := TorusMesh.new()
	torus.inner_radius = RALLY_MARKER_RING_INNER_RADIUS
	torus.outer_radius = RALLY_MARKER_RING_OUTER_RADIUS
	torus.rings = 24
	torus.ring_segments = 8
	ring.mesh = torus
	ring.position.y = 0.08
	ring.material_override = _rally_marker_material()
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_rally_marker.add_child(ring)

	# A small banner in the owner's colour marks the rally point, and a dashed
	# trail runs to it from the building while the building is selected.
	var pole := MeshInstance3D.new()
	pole.name = "RallyBeaconPost"
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.035
	pole_mesh.bottom_radius = 0.05
	pole_mesh.height = 2.0
	pole.mesh = pole_mesh
	pole.position.y = 1.0
	pole.material_override = _banner_wood
	_rally_marker.add_child(pole)
	var cloth := MeshInstance3D.new()
	cloth.name = "RallyBeaconFlag"
	var cloth_mesh := PlaneMesh.new()
	cloth_mesh.orientation = PlaneMesh.FACE_Z
	cloth_mesh.size = Vector2(0.6, 0.8)
	cloth_mesh.subdivide_width = 2
	cloth_mesh.subdivide_depth = 8
	cloth.mesh = cloth_mesh
	cloth.material_override = _banner_material
	cloth.position = Vector3(0.33, 1.55, 0.0)
	cloth.set_instance_shader_parameter("team_color", GameData.TEAM_COLORS.get(team, Color(0.8, 0.8, 0.8)))
	_rally_marker.add_child(cloth)
	_rally_path = MeshInstance3D.new()
	_rally_path.name = "RallyPath"
	var path_mesh := QuadMesh.new()
	path_mesh.orientation = PlaneMesh.FACE_Y
	path_mesh.size = Vector2(1.0, 0.35)
	_rally_path.mesh = path_mesh
	var path_mat := ShaderMaterial.new()
	path_mat.shader = load("res://assets/shaders/rally_path.gdshader")
	_rally_path.material_override = path_mat
	_rally_path.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_rally_path.visible = false
	add_child(_rally_path)

	_update_rally_marker_position()

func _rally_marker_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = RALLY_MARKER_COLOR
	mat.emission_enabled = true
	mat.emission = RALLY_MARKER_COLOR
	mat.emission_energy_multiplier = 1.15
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat

var _rally_path: MeshInstance3D

func _update_rally_marker_position() -> void:
	if is_instance_valid(_rally_marker):
		_rally_marker.position = to_local(rally_point)
	if is_instance_valid(_rally_path):
		var from := global_position
		var to := rally_point
		var flat := Vector3(to.x - from.x, 0.0, to.z - from.z)
		var length := flat.length()
		if length > 0.5:
			var start := from + flat.normalized() * minf(footprint, length * 0.5)
			var run := Vector3(to.x - start.x, 0.0, to.z - start.z)
			var mid := start + run * 0.5
			_rally_path.global_position = Vector3(mid.x, 0.07, mid.z)
			_rally_path.global_rotation = Vector3(0.0, atan2(-run.z, run.x), 0.0)
			_rally_path.scale = Vector3(run.length(), 1.0, 1.0)
			(_rally_path.material_override as ShaderMaterial).set_shader_parameter("path_length", run.length())

func _refresh_rally_marker(selected: bool) -> void:
	if not is_instance_valid(_rally_marker):
		return
	_update_rally_marker_position()
	_rally_marker.visible = selected and _has_rally and _is_rally_capable()
	if is_instance_valid(_rally_path):
		_rally_path.visible = _rally_marker.visible

func _set_construction_visual(p: float) -> void:
	# Keep the footprint visibly grounded while construction progresses. The old
	# full-footprint sink made unfinished structures disappear into the terrain,
	# which read as a missing building rather than a truthful construction state.
	if model_root:
		model_root.position.y = lerp(-0.15, 0.0, clamp(p, 0.0, 1.0))
	var building_now := p < 1.0
	if is_instance_valid(_construction_status_label):
		# The selected card and grounded progress track are the player-facing
		# construction read. Keep the literal percentage label for explicit
		# debug/review evidence so normal play is not covered by diagnostics.
		_construction_status_label.visible = building_now and _debug_review_presentation()
		_construction_status_label.text = "BUILDING %d%%" % roundi(clampf(p, 0.0, 1.0) * 100.0)
	if is_instance_valid(_construction_status_track):
		_construction_status_track.visible = building_now
	if is_instance_valid(_construction_status_fill):
		_construction_status_fill.visible = building_now
		_construction_status_fill.scale.x = maxf(0.02, clampf(p, 0.0, 1.0))
	_construction_status_fill.position.x = (maxf(1.8, footprint * 0.85) * (clampf(p, 0.0, 1.0) - 1.0)) * 0.5
	if is_instance_valid(_construction_stage_root):
		var stage := clampf(p, 0.0, 1.0)
		_construction_stage_root.visible = stage < 0.9
		_construction_stage_root.scale.y = lerpf(0.28, 1.0, clampf(stage / 0.72, 0.0, 1.0))
		for mesh in _construction_stage_meshes:
			if is_instance_valid(mesh):
				mesh.visible = stage < 0.9
	_apply_construction_rise(clampf(p, 0.0, 1.0), building_now)

# Unfinished buildings used to fade the whole model to 60% transparency.
# With hundreds of parts that sorted into a flat, see-through slab (the
# War Hall read as a translucent stone box). Now the structure rises: a
# rises behind a clipped work line, fully opaque and inside the timber
# scaffold.
var _rise_levels: Array = []

func _apply_construction_rise(p: float, building_now: bool) -> void:
	# The structure is clipped at a rising work line (construction_rise shader)
	# instead of revealing whole parts, so no flat slab tops or hollow boxes
	# show while it goes up. Original materials come back on completion.
	if not is_instance_valid(model_root):
		return
	if not building_now:
		_restore_construction_materials()
		return
	if _rise_levels.is_empty():
		var lo := INF
		var hi := -INF
		for mi in _mesh_instances:
			if is_instance_valid(mi) and mi.mesh:
				var box: AABB = mi.global_transform * mi.get_aabb()
				lo = minf(lo, box.position.y)
				hi = maxf(hi, box.end.y)
		if lo == INF:
			return
		_rise_levels = [lo, hi]
		_swap_in_construction_materials()
	var cut: float = lerpf(float(_rise_levels[0]) + 0.05, float(_rise_levels[1]) + 0.05, clampf(p, 0.0, 1.0))
	for mi in _mesh_instances:
		if is_instance_valid(mi):
			mi.transparency = 0.0
			mi.set_instance_shader_parameter("cut_y", cut)

static var _construction_material_cache := {}
var _construction_saved_overrides: Array = []

func _swap_in_construction_materials() -> void:
	_construction_saved_overrides.clear()
	for mi in _mesh_instances:
		if not is_instance_valid(mi) or not mi.mesh:
			continue
		var saved: Array = []
		for surface in mi.mesh.get_surface_count():
			saved.append(mi.get_surface_override_material(surface))
			var source: Material = mi.get_active_material(surface)
			if source is StandardMaterial3D:
				mi.set_surface_override_material(surface, _construction_material_for(source as StandardMaterial3D))
		_construction_saved_overrides.append([mi, saved])

func _restore_construction_materials() -> void:
	if _construction_saved_overrides.is_empty():
		return
	for entry in _construction_saved_overrides:
		var mi: MeshInstance3D = entry[0]
		if not is_instance_valid(mi):
			continue
		var saved: Array = entry[1]
		for surface in saved.size():
			mi.set_surface_override_material(surface, saved[surface])
	_construction_saved_overrides.clear()

static func _construction_material_for(source: StandardMaterial3D) -> Material:
	if _construction_material_cache.has(source):
		return _construction_material_cache[source]
	var m := ShaderMaterial.new()
	m.shader = load("res://assets/shaders/construction_rise.gdshader")
	m.set_shader_parameter("albedo_tex", source.albedo_texture)
	m.set_shader_parameter("has_texture", source.albedo_texture != null)
	m.set_shader_parameter("albedo_color", source.albedo_color)
	m.set_shader_parameter("uv_scale", source.uv1_scale)
	m.set_shader_parameter("uv_offset", source.uv1_offset)
	m.set_shader_parameter("roughness_value", maxf(source.roughness, 0.8))
	_construction_material_cache[source] = m
	return m

func _build_damage_status_visual() -> void:
	# Keep completed-building damage readable from the battlefield without a
	# persistent warning wall. Every element follows authoritative hp/max_hp.
	_damage_status_label = Label3D.new()
	_damage_status_label.name = "DamageStatus"
	_damage_status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_damage_status_label.no_depth_test = true
	_damage_status_label.font_size = 48
	_damage_status_label.outline_size = 12
	_damage_status_label.pixel_size = 0.008
	_damage_status_label.modulate = Color(1.0, 0.48, 0.32, 1.0)
	_damage_status_label.position = Vector3(0, _presentation_height() + 1.18, 0)
	_damage_status_label.text = "DAMAGED"
	_damage_status_label.visible = false
	add_child(_damage_status_label)

	var width := maxf(2.0, footprint * 0.72)
	_damage_status_track = MeshInstance3D.new()
	_damage_status_track.name = "DamageStatusTrack"
	var track_mesh := BoxMesh.new()
	track_mesh.size = Vector3(width, 0.10, 0.09)
	_damage_status_track.mesh = track_mesh
	var track_mat := StandardMaterial3D.new()
	track_mat.albedo_color = Color(0.06, 0.025, 0.02, 0.9)
	track_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_damage_status_track.material_override = track_mat
	_damage_status_track.position = Vector3(0, _presentation_height() + 0.82, 0)
	_damage_status_track.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_damage_status_track.visible = false
	add_child(_damage_status_track)

	_damage_status_fill = MeshInstance3D.new()
	_damage_status_fill.name = "DamageStatusFill"
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(width, 0.12, 0.11)
	_damage_status_fill.mesh = fill_mesh
	var fill_mat := StandardMaterial3D.new()
	fill_mat.albedo_color = Color(0.92, 0.16, 0.08, 0.98)
	fill_mat.emission_enabled = true
	fill_mat.emission = Color(0.45, 0.04, 0.015)
	fill_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_damage_status_fill.material_override = fill_mat
	_damage_status_fill.position = Vector3(0, _presentation_height() + 0.82, 0.06)
	_damage_status_fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_damage_status_fill.visible = false
	add_child(_damage_status_fill)

func add_build_progress(delta: float, worker) -> void:
	if is_built or is_dead:
		return
	if not world or not world.game_running:
		return
	if not is_instance_valid(worker) or not worker.is_worker or worker.is_dead or worker.team != team or (worker.has_method("_is_defeated_remnant") and worker._is_defeated_remnant()) or worker.state != worker.State.BUILDING or worker.get("_build_target") != self:
		return
	build_progress += delta / max(0.1, build_time)
	hp = max_hp * (0.15 + 0.85 * build_progress)
	_set_construction_visual(build_progress)
	if build_progress >= 1.0:
		_complete_build()

func add_repair_progress(delta: float, worker) -> void:
	if not is_built or is_dead or hp >= max_hp:
		return
	if not is_instance_valid(worker) or not worker.is_worker or worker.is_dead or worker.team != team or (worker.has_method("_is_defeated_remnant") and worker._is_defeated_remnant()) or (world and not world.game_running):
		return
	# Reuse the established construction HP work rate: the same max HP fraction
	# restored per effective build second, with no new resource economy.
	var repair_amount := max_hp * 0.85 * delta / maxf(0.1, build_time)
	hp = minf(max_hp, hp + maxf(0.0, repair_amount))
	_update_damage_visual()

func _complete_build() -> void:
	is_built = true
	build_progress = 1.0
	hp = max_hp
	_set_construction_visual(1.0)
	if is_instance_valid(selection_ring) and selection_ring.visible:
		set_selected(true)
	_play_build_completion_cue()
	# Only your own finished buildings chime: an enemy's, unseen in the fog,
	# used to ring across the map and give its builders away.
	if world and int(team) == int(world.player_team):
		Sfx.play("build_complete", -4.0)
	if commander:
		commander.recompute_pop()
		if int(def.get("tier_unlock", 0)) > commander.tier:
			commander.tier = int(def["tier_unlock"])
	if world:
		world.on_building_completed(self)
		if team == world.player_team:
			world.emit_signal("alert", "Building ready: %s" % String(def.get("name", building_id)), global_position)
	emit_signal("construction_completed", self)

func _play_build_completion_cue() -> void:
	# The construction stage and progress bar disappear at completion. A short
	# eased pulse on the existing visual root makes that state transition legible
	# without adding gameplay, collision, or persistent VFX state.
	if not is_instance_valid(model_root):
		return
	if is_instance_valid(_completion_cue_tween):
		_completion_cue_tween.kill()
	var base_scale := model_root.scale
	_completion_cue_tween = create_tween()
	_completion_cue_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_completion_cue_tween.tween_property(model_root, "scale", base_scale * BUILD_COMPLETION_CUE_SCALE, BUILD_COMPLETION_CUE_OUT_DURATION)
	_completion_cue_tween.set_ease(Tween.EASE_IN_OUT)
	_completion_cue_tween.tween_property(model_root, "scale", base_scale, BUILD_COMPLETION_CUE_RETURN_DURATION)

# --------------------------------------------------------------------------
# Production
# --------------------------------------------------------------------------
func can_produce(unit_id: String) -> bool:
	return unit_id in def.get("produces", [])

## How many soldiers and upgrades one building can have waiting.
const MAX_QUEUE := 8

func queue_unit(unit_id: String) -> Dictionary:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running):
		return {"ok": false, "reason": "Not ready"}
	if not can_produce(unit_id):
		return {"ok": false, "reason": "This building cannot train that"}
	if Engine.get_process_frames() == _last_queue_frame:
		return {"ok": false, "reason": "Already queued"}
	if queue.size() >= MAX_QUEUE:
		return {"ok": false, "reason": "The queue is full"}
	var udef := GameData.get_unit(unit_id)
	if udef.is_empty():
		return {"ok": false, "reason": "Cannot train this"}
	# tier gate
	if int(udef.get("tier", 1)) > commander.tier:
		return {"ok": false, "reason": "Requires the Age of Iron" if int(udef.get("tier", 1)) == 2 else "Requires the Age of Lume"}
	if not commander.can_afford(udef.get("cost", {})):
		return {"ok": false, "reason": commander.missing_resource_summary(udef.get("cost", {}))}
	if not commander.reserve_pop(udef):
		return {"ok": false, "reason": "Need more housing"}
	if not commander.spend(udef.get("cost", {})):
		commander.release_reserved_pop(udef)
		return {"ok": false, "reason": "Not enough resources"}
	_last_queue_frame = Engine.get_process_frames()
	var t: float = float(udef.get("build_time", 15)) * commander.train_speed_mult()
	queue.append({"id": unit_id, "kind": "unit", "time_left": t, "total": t, "pop_reserved": true})
	emit_signal("production_updated")
	return {"ok": true}

func queue_tech(tech_id: String) -> Dictionary:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running):
		return {"ok": false, "reason": "Not ready"}
	var t := GameData.get_tech(tech_id)
	if t.is_empty():
		return {"ok": false, "reason": "Unavailable"}
	# The HUD lists only authored research entries, but this method is also an
	# authoritative command boundary for stale/direct callers. Keep ordinary
	# upgrades on their owning research Building and tier advances on the HQ.
	if t.get("kind", "") == "tier":
		if not def.get("is_hq", false) and def.get("kind", "") != "main":
			return {"ok": false, "reason": "Unavailable"}
	elif tech_id not in GameData.research_for(def, String(commander.race) if commander else ""):
		return {"ok": false, "reason": "Unavailable"}
	if not commander.can_research(tech_id):
		return {"ok": false, "reason": "Already researched, under way, or waiting on an earlier upgrade"}
	if not commander.can_afford(t.get("cost", {})):
		return {"ok": false, "reason": commander.missing_resource_summary(t.get("cost", {}))}
	commander.spend(t.get("cost", {}))
	commander.researching[tech_id] = true
	var time := float(t.get("time", 30))
	queue.append({"id": tech_id, "kind": "tech", "time_left": time, "total": time})
	emit_signal("production_updated")
	return {"ok": true}

func cancel_queue_item(index: int) -> void:
	if is_dead or (world and not world.game_running) or (world and team != world.player_team):
		return
	if index < 0 or index >= queue.size():
		return
	var item = queue[index]
	if item["kind"] == "unit":
		var udef := GameData.get_unit(item["id"])
		commander.refund(udef.get("cost", {}), 1.0)
		if item.get("pop_reserved", false):
			commander.release_reserved_pop(udef)
	else:
		commander.refund(GameData.get_tech(item["id"]).get("cost", {}), 1.0)
		commander.researching.erase(item["id"])
	queue.remove_at(index)
	_last_queue_frame = -1
	emit_signal("production_updated")

func _process_production(delta: float) -> void:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running) or queue.is_empty():
		return
	var item = queue[0]
	item["time_left"] -= delta
	if item["time_left"] <= 0.0:
		if item["kind"] == "unit":
			var spawned := _spawn_unit(item["id"])
			var udef := GameData.get_unit(item["id"])
			if item.get("pop_reserved", false):
				commander.release_reserved_pop(udef)
			if not spawned:
				commander.refund(udef.get("cost", {}), 1.0)
			elif world and team == world.player_team:
				var spawned_unit_name := String(udef.get("name", item["id"]))
				world.emit_signal("alert", "Unit ready: %s" % spawned_unit_name, global_position)
		else:
			var completed_tech_id: String = String(item["id"])
			commander.researching.erase(completed_tech_id)
			commander.apply_tech(completed_tech_id)
			if world and team == world.player_team:
				var completed_tech_name := String(GameData.get_tech(completed_tech_id).get("name", completed_tech_id))
				world.emit_signal("alert", "Research complete: %s" % completed_tech_name, global_position)
				# A new Age is announced with the war horn and a column of Lume
				# over the hall; smaller research lands with a seal stamp.
				if String(GameData.get_tech(completed_tech_id).get("kind", "")) == "tier":
					Sfx.play("age_up", -4.0)
					if world.has_method("celebrate_at"):
						world.celebrate_at(global_position, Color(1.0, 0.8, 0.35))
				else:
					Sfx.play("research", -9.0)
		queue.remove_at(0)
		emit_signal("production_updated")
	else:
		emit_signal("production_updated")

func _spawn_unit(unit_id: String) -> bool:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running) or not world:
		return false
	var forward := (rally_point - global_position).normalized()
	if forward.length_squared() < 0.1:
		forward = Vector3(0, 0, 1)
	var candidates: Array[Vector3] = []
	for radius in [footprint + 1.5, footprint + 3.0, footprint + 4.5, footprint + 6.0]:
		for i in range(12):
			var angle := atan2(forward.z, forward.x) + TAU * float(i) / 12.0
			candidates.append(global_position + Vector3(cos(angle), 0, sin(angle)) * radius)
	for candidate in candidates:
		if abs(candidate.x) > MapDefs.MAP_SIZE - 4.0 or abs(candidate.z) > MapDefs.MAP_SIZE - 4.0:
			continue
		var blocked := false
		for b in world.all_buildings():
			if is_instance_valid(b) and not b.is_dead and b != self and candidate.distance_to(b.global_position) < footprint + float(b.def.get("footprint", 4.0)) * 0.75:
				blocked = true
				break
		if blocked:
			continue
		for r in world.get_tree().get_nodes_in_group("resources"):
			if is_instance_valid(r) and candidate.distance_to(r.global_position) < footprint + 1.0:
				blocked = true
				break
		if blocked:
			continue
		# Repeated completions from the same producer begin with the same forward
		# candidate. Reject live Unit occupancy so rapid production advances to the
		# next radial candidate instead of stacking runtime bodies exactly.
		if world.has_method("all_units"):
			for u in world.all_units():
				if is_instance_valid(u) and not u.is_dead and candidate.distance_to(u.global_position) < SPAWN_UNIT_CLEARANCE:
					blocked = true
					break
		if blocked:
			continue
		var u = world.spawn_unit(unit_id, team, candidate)
		if u:
			# The authoritative spawn has succeeded. Start the Unit-local
			# presentation handoff before the existing ready audio and Rally order.
			if u.has_method("play_production_arrival_cue"):
				u.play_production_arrival_cue()
			Sfx.play("ready", -6.0) if commander.is_human else null
			if _has_rally:
				# A worker rallied onto a resource goes to work there, as in
				# every RTS; it used to walk up and stand idle beside it.
				var node = _rally_resource() if u.is_worker else null
				if node != null and u.has_method("command_gather"):
					u.command_gather(node)
				else:
					u.command_move(rally_point)
			return true
	return false

## The live resource node the rally point stands on (within 7 m), if any.
func _rally_resource():
	var best = null
	var best_d := 7.0
	for r in world.get_tree().get_nodes_in_group("resources"):
		if is_instance_valid(r) and not r.depleted:
			var d: float = rally_point.distance_to(r.global_position)
			if d < best_d:
				best_d = d
				best = r
	return best

func set_rally(pos: Vector3) -> void:
	if not _is_rally_capable() or (commander and commander.defeated) or (world and not world.game_running) or (world and team != world.player_team):
		return
	rally_point = world.clamp_to_playable_bounds(pos) if world and world.has_method("clamp_to_playable_bounds") else pos
	_has_rally = true
	_refresh_rally_marker(is_instance_valid(selection_ring) and selection_ring.visible)

# --------------------------------------------------------------------------
# Combat / tower / aura
# --------------------------------------------------------------------------
## Dwellings keep a garden plot: each finished house adds 4 food every 4
## seconds. Food nodes are finite and every unit costs food, so without this
## every match ran out of food around minute eight and stalled.
var _house_food_timer := 0.0

func _house_food_tick(delta: float) -> void:
	_house_food_timer += delta
	if _house_food_timer >= 4.0:
		_house_food_timer -= 4.0
		if commander and commander.has_method("add_resources"):
			commander.add_resources("food", 4)

func _physics_process(delta: float) -> void:
	if is_dead or (commander and commander.defeated):
		return
	if is_built:
		_process_production(delta)
		# Match terminality stops new autonomous gameplay while preserving the
		# existing death/collapse/cleanup lifecycle above this shared branch.
		if world == null or not world.game_running:
			return
		if def.has("tower_dmg"):
			_tower_tick(delta)
		if String(def.get("kind", "")) == "house":
			_house_food_tick(delta)
		if def.has("heal_aura"):
			_aura_tick(delta)
		if def.has("landmark"):
			_landmark_tick(delta)
		if bool(def.get("vein_outpost", false)):
			_outpost_tick(delta)

## Landmark powers (BuildingDefs._add_landmarks), pulsed once a second.
var _landmark_timer := 0.0
var _landmark_clock := 0
var _landmark_cd := 0.0

func _landmark_tick(delta: float) -> void:
	if not is_built or is_dead or not world or not commander or commander.defeated or not world.game_running:
		return
	if not has_node("LandmarkCrown"):
		_add_landmark_crown()
		_add_landmark_centrepiece()
	_landmark_timer += delta
	if _landmark_timer < 1.0:
		return
	_landmark_timer = 0.0
	_landmark_clock += 1
	_landmark_cd = maxf(0.0, _landmark_cd - 1.0)
	var reach := float(def.get("reach", 20.0))
	var here := global_position
	match String(def.get("landmark", "")):
		"oven":
			if _landmark_clock % 20 == 0:
				commander.add_resources("food", 40)
				if team == world.player_team:
					world.spawn_income_popup(here + Vector3.UP * 4.0, 40, "food")
			for u in commander.units:
				if is_instance_valid(u) and not u.is_dead and u.hp < u.max_hp and u.global_position.distance_to(here) <= reach:
					u.hp = minf(u.max_hp, u.hp + 3.0)
		"fountain":
			world.heal_allies_near(here, reach, 5.0, team)
			var h = commander.hero_ref
			if is_instance_valid(h) and not h.is_dead and h.global_position.distance_to(here) <= reach:
				h.mana = minf(h.max_mana, h.mana + 4.0)
		"rift":
			if _landmark_clock % 40 == 0:
				for k in 2:
					var su = world.spawn_unit("vorthak_ash_thrall", team, here + Vector3(4.0 - 8.0 * k, 0.0, 4.0))
					if su:
						world.mark_summoned(su)
						var ref_id: int = su.get_instance_id()
						get_tree().create_timer(60.0, false).timeout.connect(func():
							var ref = instance_from_id(ref_id)
							if is_instance_valid(ref) and not ref.is_dead and is_instance_valid(world):
								world._dismiss_summon(ref))
				if team == world.player_team:
					world.emit_signal("alert", "Two thralls climb out of the Rift Gate.", here)
		"drum":
			for u in commander.units:
				if is_instance_valid(u) and not u.is_dead and not u.is_worker and u.global_position.distance_to(here) <= reach:
					u.apply_spell_buff(1.0, 0.0, 1.2, 1.6)
		"loom":
			if _landmark_clock % 20 == 0:
				commander.add_resources("gold", 30)
				if team == world.player_team:
					world.spawn_income_popup(here + Vector3.UP * 4.0, 30, "gold")
		"stones":
			for u in commander.units:
				if is_instance_valid(u) and not u.is_dead and u.global_position.distance_to(here) <= reach:
					u.apply_spell_buff(1.0, 3.0, 1.0, 1.6)
			for b in commander.buildings:
				if is_instance_valid(b) and not b.is_dead and b.is_built and b.hp < b.max_hp and b.global_position.distance_to(here) <= reach:
					b.hp = minf(b.max_hp, b.hp + b.max_hp * 0.01)
		"sundial":
			if _landmark_clock % 30 == 0:
				var target = world._nearest_enemy_to(here, team, [])
				if target == null:
					for u in world.all_units():
						if is_instance_valid(u) and not u.is_dead and u.team != team and u.global_position.distance_to(here) <= reach:
							target = u
							break
				if target != null and target.global_position.distance_to(here) <= reach:
					world._cast_signature(self, "sig_sunfire", target.global_position, 1, 1.0, {"range": reach, "dmg": 120})
		"howl":
			if _landmark_cd <= 0.0:
				for u in world.all_units():
					if is_instance_valid(u) and not u.is_dead and u.team != team and not u.is_worker and u.global_position.distance_to(here) <= reach:
						_landmark_cd = 30.0
						var wolf: String = world._race_first_melee("wyldkin")
						for k in 2:
							var su = world.spawn_unit(wolf, team, here + Vector3(3.0 - 6.0 * k, 0.0, -3.0))
							if su:
								world.mark_summoned(su)
								su.command_move(u.global_position, true)
								var ref_id: int = su.get_instance_id()
								get_tree().create_timer(30.0, false).timeout.connect(func():
									var ref = instance_from_id(ref_id)
									if is_instance_valid(ref) and not ref.is_dead and is_instance_valid(world):
										world._dismiss_summon(ref))
						break
		"bonfire":
			for u in world.all_units():
				if not is_instance_valid(u) or u.is_dead or u.global_position.distance_to(here) > reach:
					continue
				if u.team != team:
					u.take_damage(8.0, self)
				elif not u.is_worker:
					u.apply_spell_buff(1.2, 0.0, 1.0, 1.6)
	# The landmark's reach glows faintly when your own is selected (see
	# _show_fortify_ring) and its power pulses with a small ring.
	if _landmark_clock % 4 == 0 and team == world.player_team and world.has_method("spawn_ring_fx"):
		world.spawn_ring_fx(here, LANDMARK_TINT.get(String(def.get("landmark", "")), Color(1, 0.85, 0.4)), minf(reach, 8.0))

## A landmark wears a turning Lume crystal above it and a glow in its
## people's colour, so it reads as something no other hall is.
func _add_landmark_crown() -> void:
	var tint: Color = LANDMARK_TINT.get(String(def.get("landmark", "")), Color(1, 0.85, 0.4))
	var crown := Node3D.new()
	crown.name = "LandmarkCrown"
	add_child(crown)
	crown.position = Vector3(0.0, footprint * 1.35 + 3.0, 0.0)
	var gem := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(1.0, 1.4, 1.0)
	gem.mesh = prism
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.emission_enabled = true
	mat.emission = tint
	mat.emission_energy_multiplier = 2.2
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = mat
	gem.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	crown.add_child(gem)
	var under := gem.duplicate() as MeshInstance3D
	under.rotation.x = PI
	under.position.y = -1.4
	crown.add_child(under)
	var light := OmniLight3D.new()
	light.light_color = tint
	light.light_energy = 2.0
	light.omni_range = footprint * 2.4
	light.shadow_enabled = false
	crown.add_child(light)
	var spin := crown.create_tween().set_loops()
	spin.tween_property(crown, "rotation:y", TAU, 6.0).from(0.0)
	var bob := gem.create_tween().set_loops()
	bob.tween_property(crown, "position:y", crown.position.y + 0.5, 1.6).set_trans(Tween.TRANS_SINE)
	bob.tween_property(crown, "position:y", crown.position.y, 1.6).set_trans(Tween.TRANS_SINE)

const LANDMARK_TINT := {"oven": Color(1.0, 0.6, 0.3), "fountain": Color(0.45, 1.0, 0.85), "rift": Color(0.7, 0.3, 1.0),
	"drum": Color(1.0, 0.4, 0.25), "loom": Color(1.0, 0.85, 0.35), "stones": Color(0.82, 0.84, 0.9),
	"sundial": Color(1.0, 0.85, 0.3), "howl": Color(0.7, 0.8, 1.0), "bell": Color(0.9, 0.8, 0.55), "bonfire": Color(1.0, 0.45, 0.2)}

func outpost_slots() -> int:
	return 3 + 2 * (outpost_level - 1)

func outpost_output_mult() -> float:
	return 1.0 + 0.25 * float(outpost_level - 1)

func outpost_rate_per_minute() -> float:
	var vein = get_meta("vein") if has_meta("vein") else null
	var rich := 2.0 if is_instance_valid(vein) and world and float(world.get("match_time")) < float(vein.rich_until) else 1.0
	var twist := float(world.get("twist_vein_mult")) if world and world.get("twist_vein_mult") != null else 1.0
	return float(garrison.size()) * OUTPOST_RATE * outpost_output_mult() * rich * twist * 60.0

func outpost_expand_cost() -> Dictionary:
	return {"timber": 120 * outpost_level, "stone": 80 * outpost_level, "gold": 40 * outpost_level}

## Expand the outpost: two more worker slots and a quarter more output per
## level; the top level adds a watch-fire that shoots at raiders.
func expand_outpost() -> Dictionary:
	if outpost_level >= OUTPOST_MAX_LEVEL:
		return {"ok": false, "reason": "Fully expanded"}
	if not is_built:
		return {"ok": false, "reason": "Still being built"}
	var cost := outpost_expand_cost()
	if commander == null or not commander.can_afford(cost):
		return {"ok": false, "reason": "Not enough resources"}
	commander.spend(cost)
	outpost_level += 1
	if outpost_level >= OUTPOST_MAX_LEVEL:
		def = def.duplicate()
		def["tower_dmg"] = 18
		def["tower_range"] = 16.0
		def["tower_cd"] = 1.3
		def["tower_type"] = "pierce"
		def["projectile"] = "bolt"
	max_hp *= 1.3
	hp = minf(max_hp, hp + max_hp * 0.3)
	if world:
		world.emit_signal("alert", "%s expanded to level %d." % [String(def.get("name", "Outpost")), outpost_level], global_position)
	return {"ok": true}

## Workers told to garrison walk up and step inside once close enough.
func _outpost_tick(delta: float) -> void:
	_outpost_timer += delta
	if _outpost_timer >= 0.5:
		_outpost_timer = 0.0
		garrison = garrison.filter(func(w): return is_instance_valid(w) and not w.is_dead)
		if garrison.size() < outpost_slots() and commander:
			for u in commander.units:
				if garrison.size() >= outpost_slots():
					break
				if is_instance_valid(u) and not u.is_dead and u.is_worker and (u.get_meta("garrison_target") if u.has_meta("garrison_target") else null) == self \
						and u.global_position.distance_to(global_position) < footprint + 3.5:
					_take_in(u)
	_outpost_pay_timer += delta
	if _outpost_pay_timer >= 5.0:
		_outpost_pay_timer = 0.0
		var vein = get_meta("vein") if has_meta("vein") else null
		if garrison.is_empty() or not is_instance_valid(vein) or commander == null:
			return
		var want := int(round(outpost_rate_per_minute() / 12.0))
		var got: int = vein.draw(want)
		if got > 0:
			commander.add_resources(String(vein.kind), got)
			if world and world.has_method("spawn_income_popup") and team == int(world.get("player_team")):
				world.spawn_income_popup(global_position + Vector3.UP * (footprint + 2.0), got, String(vein.kind))
		elif world and team == int(world.get("player_team")):
			world.emit_signal("alert", "The %s is exhausted." % vein.display_name().to_lower(), global_position)

func _take_in(u) -> void:
	u.set_meta("garrison_target", null)
	u.set_meta("garrisoned_in", self)
	u.command_stop()
	# Marked as busy the way a builder is, so no order-giver (player helper,
	# AI economy, placement checks) pulls a worker out of the outpost.
	u.state = u.State.BUILDING
	u.visible = false
	u.process_mode = Node.PROCESS_MODE_DISABLED
	u.collision_layer = 0
	garrison.append(u)
	if commander:
		commander.recompute_pop()
	_update_outpost_lamp()

## A lantern glows at a staffed outpost so a working mine reads at a glance.
var _outpost_lamp: OmniLight3D

func _update_outpost_lamp() -> void:
	var staffed := not garrison.is_empty()
	if staffed and not is_instance_valid(_outpost_lamp):
		_outpost_lamp = OmniLight3D.new()
		_outpost_lamp.light_color = Color(1.0, 0.72, 0.4)
		_outpost_lamp.light_energy = 1.6
		_outpost_lamp.omni_range = 7.0
		_outpost_lamp.shadow_enabled = false
		_outpost_lamp.position = Vector3(0, footprint + 0.8, 0)
		add_child(_outpost_lamp)
	if is_instance_valid(_outpost_lamp):
		_outpost_lamp.visible = staffed
		_outpost_lamp.light_energy = 1.2 + 0.25 * float(garrison.size())

## Send every worker inside back out around the outpost.
func release_garrison() -> void:
	var i := 0
	for u in garrison:
		if not is_instance_valid(u) or u.is_dead:
			continue
		u.process_mode = Node.PROCESS_MODE_INHERIT
		u.visible = true
		u.collision_layer = WorldBlockerContract.UNIT_LAYER
		u.remove_meta("garrisoned_in")
		var ang := float(i) * 1.3
		u.global_position = global_position + Vector3(cos(ang), 0, sin(ang)) * (footprint + 1.8)
		u.command_stop()
		i += 1
	garrison.clear()
	if commander:
		commander.recompute_pop()
	_update_outpost_lamp()

func _tower_tick(delta: float) -> void:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running):
		return
	if _tower_cd > 0.0:
		_tower_cd -= delta
		return
	if not world:
		return
	var e = world.find_enemy_near(global_position, float(def.get("tower_range", 18.0)), team)
	if e:
		_tower_cd = float(def.get("tower_cd", 1.2))
		world.spawn_projectile(global_position + Vector3.UP * footprint,
			e, float(def.get("tower_dmg", 20)) * (1.0 + (float(commander.build_flags.get("tower_dmg", 0.0)) if commander else 0.0)), def.get("tower_type", "pierce"),
			team, def.get("projectile", "bolt"), 0.0, self)

func _aura_tick(delta: float) -> void:
	if not is_built or is_dead or (commander and commander.defeated) or (world and not world.game_running):
		return
	_aura_timer += delta
	if _aura_timer < 0.5:
		return
	_aura_timer = 0.0
	if not world:
		return
	var rng := float(def.get("heal_aura_range", 16.0))
	var amt := float(def.get("heal_aura", 5.0)) * 0.5
	if commander and commander.build_flags.get("bloom_boost", false):
		rng *= 1.4
		amt *= 2.0
	world.heal_allies_near(global_position, rng, amt, team)

func cur_armor() -> float:
	return base_armor

func get_hp_ratio() -> float:
	return hp / max_hp if max_hp > 0 else 0.0

## Masonry research finished: standing buildings grow sturdier at once.
func apply_hp_upgrade(mult: float) -> void:
	var ratio := hp / maxf(1.0, max_hp)
	max_hp *= mult
	hp = max_hp * ratio

func take_damage(amount: float, from = null) -> void:
	if is_dead or (world and not world.game_running):
		return
	var source_team := -1
	if from is Dictionary:
		source_team = int(from.get("source_team", -1))
	elif is_instance_valid(from) and "team" in from:
		source_team = int(from.team)
	if source_team == team:
		return
	var hp_before := hp
	var final_damage := maxf(0.0, amount)
	hp = maxf(0.0, hp - final_damage)
	if world:
		world.on_building_damaged(self, from, hp_before, final_damage)
	_update_damage_visual()
	if hp <= 0.0:
		_destroy(from)

var _damage_smoke: Array = []
static var _dark_smoke: ParticleProcessMaterial

static func _dark_smoke_process(base: Material) -> ParticleProcessMaterial:
	# Battle smoke is thick and sooty, not the pale hearth smoke of the hamlet.
	if _dark_smoke == null and base is ParticleProcessMaterial:
		_dark_smoke = (base as ParticleProcessMaterial).duplicate()
		var fade := Gradient.new()
		fade.set_color(0, Color(0.12, 0.10, 0.09, 0.0))
		fade.set_color(1, Color(0.30, 0.29, 0.29, 0.0))
		fade.add_point(0.1, Color(0.10, 0.09, 0.08, 0.8))
		fade.add_point(0.6, Color(0.24, 0.23, 0.23, 0.45))
		var ramp := GradientTexture1D.new()
		ramp.gradient = fade
		_dark_smoke.color_ramp = ramp
		_dark_smoke.initial_velocity_min = 1.4
		_dark_smoke.initial_velocity_max = 2.0
	return _dark_smoke
var _damage_fires: Array = []

## Battle damage you can see from across the map: smoke rises from a
## building below 70% health, and flames break out below 40%. Both go away
## again when it is repaired. Presentation only.
func _update_damage_fires(ratio: float) -> void:
	var top := _presentation_height()
	var want_smoke := 0 if ratio >= 0.7 else (1 if ratio >= 0.4 else 2)
	var want_fire := 0 if ratio >= 0.4 else (1 if ratio >= 0.2 else 2)
	var spots := [Vector3(footprint * 0.35, top * 0.98, -footprint * 0.2), Vector3(-footprint * 0.3, top * 0.9, footprint * 0.3)]
	while _damage_smoke.size() < want_smoke:
		var smoke := ChimneySmoke.new()
		smoke.name = "DamageSmoke"
		add_child(smoke)
		smoke.position = spots[_damage_smoke.size()]
		smoke.scale = Vector3.ONE * 1.6
		smoke.amount = 22
		smoke.process_material = _dark_smoke_process(smoke.process_material)
		_damage_smoke.append(smoke)
	while _damage_smoke.size() > want_smoke:
		var old = _damage_smoke.pop_back()
		if is_instance_valid(old):
			old.queue_free()
	while _damage_fires.size() < want_fire:
		var fire := BrazierFire.new()
		fire.name = "DamageFire"
		fire.flame_scale = 2.2
		fire.light_energy = 2.8
		fire.light_range = 9.0
		add_child(fire)
		fire.position = spots[_damage_fires.size()] + Vector3(0, top * 0.08, 0)
		fire.scale = Vector3.ONE * 2.4
		_damage_fires.append(fire)
	while _damage_fires.size() > want_fire:
		var old = _damage_fires.pop_back()
		if is_instance_valid(old):
			old.queue_free()

func _update_damage_visual() -> void:
	var ratio := get_hp_ratio()
	var damaged := is_built and not is_dead and ratio < 0.99
	if is_instance_valid(_damage_status_label):
		_damage_status_label.visible = damaged
	if is_instance_valid(_damage_status_track):
		_damage_status_track.visible = damaged
	if is_instance_valid(_damage_status_fill):
		var width := maxf(2.0, footprint * 0.72)
		_damage_status_fill.visible = damaged
		_damage_status_fill.scale.x = maxf(0.02, ratio)
		_damage_status_fill.position.x = width * (clampf(ratio, 0.0, 1.0) - 1.0) * 0.5
	_update_damage_fires(ratio if is_built and not is_dead else 1.0)
	if ratio < 0.35:
		for mi in _mesh_instances:
			if is_instance_valid(mi):
				mi.set_instance_shader_parameter("dmg", 1.0)
				# tint darker as a simple damage cue
				if mi.material_override == null and mi.mesh:
					pass

func _destroy(from = null) -> void:
	if is_dead:
		return
	if not garrison.is_empty():
		release_garrison()
	# Clear queued production/research while the building is still eligible for
	# cancel_queue_item(). That method intentionally rejects already-dead
	# buildings; setting is_dead first silently left destroyed producers with
	# stale queues and researching flags.
	var is_player_building: bool = world != null and team == world.player_team
	for i in range(queue.size() - 1, -1, -1):
		if is_player_building:
			cancel_queue_item(i)
		else:
			var item: Dictionary = queue[i]
			if item.get("kind", "") == "unit":
				var udef := GameData.get_unit(String(item.get("id", "")))
				if item.get("pop_reserved", false) and commander:
					commander.release_reserved_pop(udef)
			else:
				if commander:
					commander.researching.erase(String(item.get("id", "")))
			queue.remove_at(i)
			_last_queue_frame = -1
			emit_signal("production_updated")
	is_dead = true
	# Retire the existing damage-status presentation at the same logical
	# boundary as destruction. Without this refresh, a dead building can retain
	# a stale live damage bar while its collapse cue is still playing.
	_update_damage_visual()
	set_selected(false)
	collision_layer = 0
	set_meta("v0436_destroyed_once", true)
	if commander:
		commander.recompute_pop()
	emit_signal("died", self)
	# A fall you can see is a fall you can hear; unseen ones stay silent so
	# the sound never gives away a fight in the fog.
	if world and (int(team) == int(world.player_team) or (world.has_method("is_player_visible") and world.is_player_visible(self))):
		Sfx.play("collapse", -5.0)
	if world:
		world.on_building_destroyed(self)
	# Collapse: the structure shudders, lists to one side and sinks into a
	# cloud of dust, leaving a rubble heap and scorched ground behind.
	if world and world.has_method("spawn_collapse_fx"):
		world.spawn_collapse_fx(global_position, footprint)
	var t := create_tween()
	t.set_parallel(true)
	if model_root:
		var lean := Vector3(randf_range(-0.22, 0.22), 0.0, randf_range(-0.22, 0.22))
		t.tween_property(model_root, "rotation", model_root.rotation + lean, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		t.tween_property(model_root, "position:y", model_root.position.y - _presentation_height() * 1.05, 1.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(0.15)
		t.tween_property(model_root, "scale", model_root.scale * Vector3(1.05, 0.75, 1.05), 1.6).set_delay(0.15)
	await t.finished
	queue_free()


## Each landmark gets its own centrepiece so it reads as a monument, not a
## workshop: a flagstone plaza plus a signature piece (stones, dial, drum...).
## Presentation only; no collision.
func _add_landmark_centrepiece() -> void:
	var kind := String(def.get("landmark", ""))
	var tint: Color = LANDMARK_TINT.get(kind, Color(1, 0.85, 0.4))
	var root := Node3D.new()
	root.name = "LandmarkCentrepiece"
	add_child(root)
	var r := footprint
	var stone := Color(0.56, 0.54, 0.50)
	# Plaza: a low flagstone disc with a tinted inlay ring.
	_lm_piece(root, _lm_cyl(r * 1.25, r * 1.25, 0.16), stone.darkened(0.15), Vector3(0, 0.06, 0))
	var inlay := TorusMesh.new()
	inlay.inner_radius = r * 1.17
	inlay.outer_radius = r * 1.2
	inlay.rings = 48
	inlay.ring_segments = 4
	_lm_piece(root, inlay, tint.darkened(0.55), Vector3(0, 0.15, 0), Vector3(1, 0.25, 1))
	var front := Vector3(0, 0, r * 0.95)
	match kind:
		"stones":
			for i in 9:
				var a := TAU * float(i) / 9.0
				var h := 2.6 + 0.8 * float(i % 3)
				var slab := _lm_piece(root, _lm_box(Vector3(0.9, h, 0.45)), stone, Vector3(cos(a) * r * 1.15, h * 0.5, sin(a) * r * 1.15))
				slab.rotation.y = -a + PI * 0.5
				slab.rotation.z = 0.06 * float((i % 3) - 1)
			var lintel := _lm_piece(root, _lm_box(Vector3(2.6, 0.45, 0.5)), stone.darkened(0.1), Vector3(r * 1.15, 3.85, 0.0))
			lintel.rotation.y = PI * 0.5
		"sundial":
			_lm_piece(root, _lm_cyl(2.2, 2.3, 0.3), Color(0.85, 0.68, 0.32), front + Vector3(0, 0.3, 0), Vector3.ONE, 0.6)
			for i in 12:
				var a := TAU * float(i) / 12.0
				_lm_piece(root, _lm_box(Vector3(0.12, 0.08, 0.5)), Color(0.35, 0.22, 0.10), front + Vector3(cos(a) * 1.85, 0.48, sin(a) * 1.85)).rotation.y = -a + PI * 0.5
			var gnomon := _lm_piece(root, _lm_box(Vector3(0.18, 2.6, 1.1)), Color(0.72, 0.52, 0.22), front + Vector3(0, 1.4, -0.3), Vector3.ONE, 0.7)
			gnomon.rotation.x = -0.55
		"bonfire":
			for i in 8:
				var a := TAU * float(i) / 8.0
				var lg := _lm_piece(root, _lm_cyl(0.22, 0.28, 3.8), Color(0.30, 0.19, 0.10), front + Vector3(cos(a) * 0.8, 1.5, sin(a) * 0.8))
				lg.rotation = Vector3(0.0, -a, 0.0)
				lg.rotate(Vector3(sin(a), 0, -cos(a)).normalized(), -0.38)
			var fire := BrazierFire.new()
			fire.flame_scale = 4.2
			fire.light_range = 11.0
			fire.light_energy = 3.0
			fire.position = front + Vector3(0, 1.6, 0)
			root.add_child(fire)
		"drum":
			var drum := _lm_piece(root, _lm_cyl(1.5, 1.5, 1.4), Color(0.45, 0.20, 0.12), front + Vector3(0, 1.0, 0))
			drum.rotation.x = PI * 0.5
			for s in [-1.0, 1.0]:
				_lm_piece(root, _lm_cyl(1.52, 1.52, 0.08), Color(0.86, 0.78, 0.62), front + Vector3(0, 1.0, 0.72 * s)).rotation.x = PI * 0.5
			for s in [-1.0, 1.0]:
				_lm_piece(root, _lm_box(Vector3(0.3, 0.5, 1.6)), Color(0.25, 0.15, 0.08), front + Vector3(1.1 * s, 0.25, 0))
		"bell":
			for s in [-1.0, 1.0]:
				_lm_piece(root, _lm_box(Vector3(0.35, 3.6, 0.35)), Color(0.82, 0.80, 0.72), front + Vector3(1.4 * s, 1.8, 0))
			_lm_piece(root, _lm_box(Vector3(3.3, 0.35, 0.4)), Color(0.82, 0.80, 0.72), front + Vector3(0, 3.6, 0))
			var bell := CylinderMesh.new()
			bell.top_radius = 0.45
			bell.bottom_radius = 1.0
			bell.height = 1.4
			_lm_piece(root, bell, Color(0.45, 0.33, 0.18), front + Vector3(0, 2.7, 0))
		"loom":
			for s in [-1.0, 1.0]:
				_lm_piece(root, _lm_box(Vector3(0.3, 3.2, 0.3)), Color(0.55, 0.40, 0.22), front + Vector3(1.5 * s, 1.6, 0))
			_lm_piece(root, _lm_box(Vector3(3.4, 0.3, 0.3)), Color(0.55, 0.40, 0.22), front + Vector3(0, 3.2, 0))
			_lm_piece(root, _lm_box(Vector3(3.4, 0.3, 0.3)), Color(0.55, 0.40, 0.22), front + Vector3(0, 0.5, 0))
			for i in 9:
				_lm_piece(root, _lm_box(Vector3(0.05, 2.6, 0.05)), Color(1.0, 0.82, 0.3), front + Vector3(-1.2 + 0.3 * float(i), 1.85, 0), Vector3.ONE, 1.5)
		"howl":
			var menhir := _lm_piece(root, _lm_box(Vector3(1.7, 6.0, 1.2)), Color(0.46, 0.48, 0.55), front + Vector3(0, 3.0, 0))
			menhir.rotation = Vector3(0.08, 0.4, -0.06)
			var moon := SphereMesh.new()
			moon.radius = 0.35
			moon.height = 0.7
			_lm_piece(root, moon, Color(0.7, 0.8, 1.0), front + Vector3(0, 6.4, 0), Vector3.ONE * 1.6, 2.0)
		"rift":
			var ring := TorusMesh.new()
			ring.inner_radius = 1.3
			ring.outer_radius = 1.6
			var gate := _lm_piece(root, ring, Color(0.55, 0.25, 0.85), front + Vector3(0, 1.8, 0), Vector3.ONE, 1.8)
			gate.rotation.x = PI * 0.5
			var veil := _lm_piece(root, _lm_cyl(1.3, 1.3, 0.05), Color(0.12, 0.02, 0.2), front + Vector3(0, 1.8, 0), Vector3.ONE, 0.5)
			veil.rotation.x = PI * 0.5
		"fountain":
			_lm_piece(root, _lm_cyl(1.9, 2.0, 0.6), stone, front + Vector3(0, 0.3, 0))
			_lm_piece(root, _lm_cyl(1.6, 1.6, 0.1), Color(0.35, 0.65, 0.85), front + Vector3(0, 0.58, 0), Vector3.ONE, 0.6)
			_lm_piece(root, _lm_cyl(0.25, 0.35, 1.8), stone, front + Vector3(0, 1.2, 0))
		"oven":
			var dome := SphereMesh.new()
			dome.radius = 1.6
			dome.height = 1.8
			dome.is_hemisphere = true
			_lm_piece(root, dome, Color(0.72, 0.50, 0.36), front + Vector3(0, 0.1, 0))
			var glow := BrazierFire.new()
			glow.flame_scale = 0.8
			glow.light_range = 6.0
			glow.position = front + Vector3(0, 0.4, 1.3)
			root.add_child(glow)


func _lm_cyl(top: float, bottom: float, h: float) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = h
	c.radial_segments = 24
	return c


func _lm_box(s: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = s
	return b


func _lm_piece(parent: Node3D, mesh: Mesh, col: Color, pos: Vector3, scl: Vector3 = Vector3.ONE, glow: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.roughness = 0.85
	if glow > 0.0:
		mat.emission_enabled = true
		mat.emission = col
		mat.emission_energy_multiplier = glow
	mi.material_override = mat
	mi.position = pos
	mi.scale = scl
	parent.add_child(mi)
	return mi
