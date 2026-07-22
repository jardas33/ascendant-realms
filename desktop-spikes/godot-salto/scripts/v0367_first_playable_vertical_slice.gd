extends Node3D

## v0.367 genuinely playable, bounded Barrosan RTS slice.
## This scene owns only the opt-in match: two workers, one mine, one build,
## one recruitable unit, two raiders, and explicit victory/defeat/restart.

const CHECKPOINT := "v0.367"
const BASE_HEAD := "1ff18feff10451f2d8535910acaf9737e2e4524e"
const HOUSE_SOURCE := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const BARN_SOURCE := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const HOUSE_A_PATH := "V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite"
const HOUSE_B_PATH := "V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber"
const BARN_C_PATH := "V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth"
const WORKER_TEXTURE := "res://assets/v0310/barrosan_worker_v0147_source.png"
const MILITIA_TEXTURE := "res://assets/v0310/barrosan_militia_v0154_source.png"
const BUILD_COST := 100
const MILITIA_COST := 50
const WORKER_CAPACITY := 25
const INITIAL_GOLD := 50
const MINE_STARTING_GOLD := 350
const MAIN_POSITION := Vector3(-5.0, 0.0, -3.2)
const MINE_POSITION := Vector3(-9.0, 0.0, 2.8)
const ENEMY_POSITIONS := [Vector3(8.0, 0.0, 4.6), Vector3(9.4, 0.0, 5.5)]
const BUILD_ZONE := Vector3(0.1, 0.0, -2.3)

enum Mode { MENU, PLAYING, RESULT }

var mode := Mode.MENU
var world: Node3D
var camera: Camera3D
var camera_focus := Vector3(0.0, 0.0, 0.0)
var camera_zoom := 18.0
var main_building: Node3D
var mine_node: Node3D
var barracks_node: Node3D
var construction_proxy: Node3D
var build_ghost: MeshInstance3D
var river_node: MeshInstance3D
var launcher_ui: Control
var hud_ui: Control
var result_ui: Control
var gold_label: Label
var objective_label: Label
var selection_label: Label
var selection_health_label: Label
var selection_status_label: Label
var toast_label: Label
var debug_label: Label
var command_panel: VBoxContainer
var build_button: Button
var recruit_button: Button
var cancel_button: Button
var result_title: Label
var result_detail: Label
var selected: Array[Dictionary] = []
var entities: Array[Dictionary] = []
var workers: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var militia_units: Array[Dictionary] = []
var barracks_entity: Dictionary = {}
var gold := INITIAL_GOLD
var mine_gold := MINE_STARTING_GOLD
var main_hp := 400.0
var main_max_hp := 400.0
var barracks_progress := 0.0
var barracks_ready := false
var training_progress := -1.0
var build_mode := false
var construction_position := BUILD_ZONE
var debug_mode := false
var smoke_mode := false
var capture_mode := false
var capture_root := "artifacts/runtime/v0367"
var capture_files: Array[String] = []
var status_message := "Select a Worker to begin."
var match_elapsed := 0.0
var last_result_victory := false

func _ready() -> void:
	_smoke_or_capture_flags()
	_build_environment()
	_build_map()
	_build_camera()
	_build_launcher_ui()
	if capture_mode:
		_start_match()
		_run_capture.call_deferred()
	elif smoke_mode:
		_start_match()
		_run_smoke.call_deferred()

func _smoke_or_capture_flags() -> void:
	for arg in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var value := str(arg)
		if value == "--v0367-smoke": smoke_mode = true
		if value == "--v0367-capture": capture_mode = true
		if value.begins_with("--artifact-root="): capture_root = value.trim_prefix("--artifact-root=")
	if capture_mode:
		smoke_mode = true

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#8a9b88")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#c4c8b5")
	environment.ambient_light_energy = 0.75
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_environment := WorldEnvironment.new()
	world_environment.name = "V0367_Barrosan_Readable_Environment"
	world_environment.environment = environment
	add_child(world_environment)
	var key := DirectionalLight3D.new()
	key.name = "V0367_Soft_Directional_Key"
	key.rotation_degrees = Vector3(-52.0, -32.0, 0.0)
	key.light_color = Color("#f0dfbd")
	key.light_energy = 1.25
	key.shadow_enabled = true
	add_child(key)
	var fill := DirectionalLight3D.new()
	fill.name = "V0367_Cool_Ambient_Fill"
	fill.rotation_degrees = Vector3(-25.0, 145.0, 0.0)
	fill.light_color = Color("#9bb7b0")
	fill.light_energy = 0.35
	fill.shadow_enabled = false
	add_child(fill)

func _build_map() -> void:
	world = Node3D.new()
	world.name = "V0367_Playable_Barrosan_Match"
	add_child(world)
	_add_box("Terrain", Vector3(26.0, 0.25, 18.0), Vector3(0.0, -0.18, 0.0), Color("#60765d"), world)
	_add_box("SouthRoad", Vector3(24.0, 0.08, 1.3), Vector3(0.0, 0.04, -2.4), Color("#80684f"), world)
	_add_box("EastRoad", Vector3(1.25, 0.08, 14.0), Vector3(5.6, 0.04, 1.5), Color("#80684f"), world)
	river_node = _add_box("RecessedStream", Vector3(2.5, 0.12, 18.0), Vector3(3.0, -0.34, 0.0), Color("#2e5960"), world)
	_add_box("RiverBankWest", Vector3(0.55, 0.12, 18.0), Vector3(1.65, -0.03, 0.0), Color("#8b795e"), world)
	_add_box("RiverBankEast", Vector3(0.55, 0.12, 18.0), Vector3(4.35, -0.03, 0.0), Color("#8b795e"), world)
	_add_box("BridgeDeck", Vector3(4.0, 0.24, 2.0), Vector3(3.0, 0.18, -2.4), Color("#6a5645"), world)
	_add_box("BridgeRailWest", Vector3(4.0, 0.42, 0.12), Vector3(3.0, 0.47, -3.22), Color("#403a35"), world)
	_add_box("BridgeRailEast", Vector3(4.0, 0.42, 0.12), Vector3(3.0, 0.47, -1.58), Color("#403a35"), world)
	_add_environment_dressing()
	_spawn_main_building()
	_spawn_mine()
	_spawn_workers()
	_spawn_enemy_camp()

func _add_environment_dressing() -> void:
	for position in [Vector3(-11.0, 0.0, -6.2), Vector3(-8.5, 0.0, -5.8), Vector3(10.5, 0.0, -4.8), Vector3(11.4, 0.0, 1.0), Vector3(-11.2, 0.0, 6.0)]:
		var tree := Node3D.new()
		tree.name = "Barrosan_Pine"
		tree.position = position
		world.add_child(tree)
		var trunk := MeshInstance3D.new()
		var trunk_mesh := CylinderMesh.new(); trunk_mesh.top_radius = 0.10; trunk_mesh.bottom_radius = 0.16; trunk_mesh.height = 1.1; trunk_mesh.material = _material(Color("#4a3b30"), 0.98)
		trunk.mesh = trunk_mesh; trunk.position.y = 0.55; tree.add_child(trunk)
		var crown := MeshInstance3D.new()
		var crown_mesh := PrismMesh.new(); crown_mesh.size = Vector3(1.0, 1.9, 1.0); crown_mesh.material = _material(Color("#344f3d"), 0.98)
		crown.mesh = crown_mesh; crown.position.y = 1.65; tree.add_child(crown)
	for position in [Vector3(-1.5, 0.0, -6.3), Vector3(7.3, 0.0, -6.0), Vector3(-10.5, 0.0, 0.1), Vector3(10.8, 0.0, 6.3)]:
		var rock := MeshInstance3D.new(); var mesh := SphereMesh.new(); mesh.radius = 0.45; mesh.height = 0.65; mesh.material = _material(Color("#777c70"), 0.98); rock.mesh = mesh; rock.position = position + Vector3(0.0, 0.25, 0.0); world.add_child(rock)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "V0367_Playable_Orthographic_Camera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = camera_zoom
	camera.current = true
	add_child(camera)
	_update_camera()

func _update_camera() -> void:
	if camera == null: return
	camera.position = camera_focus + Vector3(0.0, 16.0, 16.0)
	camera.look_at(camera_focus, Vector3.UP)
	camera.size = camera_zoom

func _spawn_main_building() -> void:
	main_building = _spawn_clean_asset(HOUSE_SOURCE, MAIN_POSITION, Vector3(0.34, 0.34, 0.34), "HOUSE_A", "HOUSE_B")
	if main_building == null:
		main_building = _fallback_building("MainBuilding", MAIN_POSITION, Color("#7b8790"), Color("#4b5360"))
	main_building.name = "MainBuilding_House02_CleanFork"
	main_building.set_meta("entity_id", "main_building")

func _spawn_clean_asset(source_path: String, position: Vector3, scale_value: Vector3, target_a: String, target_b: String) -> Node3D:
	var packed := load(source_path) as PackedScene
	if packed == null: return null
	var instance := packed.instantiate() as Node3D
	if instance == null: return null
	instance.position = position
	instance.scale = scale_value
	_hide_non_lod(instance)
	if target_a != "":
		var mesh_a := _find_named(instance, "V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite") as MeshInstance3D
		if mesh_a == null: mesh_a = _find_named(instance, "LOD0_Granite") as MeshInstance3D
		if mesh_a != null and mesh_a.mesh is ArrayMesh:
			mesh_a.mesh = _derive_mesh(mesh_a.mesh as ArrayMesh, target_a).mesh
	if target_b != "":
		var mesh_b := _find_named(instance, "V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber") as MeshInstance3D
		if mesh_b == null: mesh_b = _find_named(instance, "LOD0_Weathered_Timber") as MeshInstance3D
		if mesh_b != null and mesh_b.mesh is ArrayMesh:
			mesh_b.mesh = _derive_mesh(mesh_b.mesh as ArrayMesh, target_b).mesh
	world.add_child(instance)
	return instance

func _spawn_barracks(position: Vector3) -> Node3D:
	var instance := _spawn_clean_asset(BARN_SOURCE, position, Vector3(0.30, 0.30, 0.30), "", "")
	if instance == null: instance = _fallback_building("FieldBarracks", position, Color("#766454"), Color("#3b3430"))
	var mesh_c := _find_named(instance, "V0347_Barn_Rendered_Geometry_Truth") as MeshInstance3D
	if mesh_c != null and mesh_c.mesh is ArrayMesh:
		mesh_c.mesh = _derive_mesh(mesh_c.mesh as ArrayMesh, "BARN_C").mesh
	instance.name = "FieldBarracks_Barn_CleanFork"
	return instance

func _hide_non_lod(root: Node3D) -> void:
	for node in root.find_children("*", "Node3D", true, false):
		var label := String(node.name).to_lower()
		if label.contains("lod1") or label.contains("lod2") or label.contains("collision"): node.visible = false

func _find_named(root: Node, target: String) -> Node:
	if root.name == target: return root
	for child in root.get_children():
		var found := _find_named(child, target)
		if found != null: return found
	return null

func _fallback_building(label: String, position: Vector3, wall_color: Color, roof_color: Color) -> Node3D:
	var root := Node3D.new(); root.name = label; root.position = position; world.add_child(root)
	_add_box("Foundation", Vector3(3.0, 0.22, 2.4), Vector3(0.0, 0.12, 0.0), Color("#565850"), root)
	_add_box("Walls", Vector3(2.7, 1.7, 2.1), Vector3(0.0, 1.0, 0.0), wall_color, root)
	_add_box("Roof", Vector3(3.1, 0.35, 2.5), Vector3(0.0, 2.05, 0.0), roof_color, root)
	return root

func _spawn_mine() -> void:
	mine_node = Node3D.new(); mine_node.name = "GoldMine_300Plus"; mine_node.position = MINE_POSITION; world.add_child(mine_node)
	for offset in [Vector3(-0.7, 0.25, 0.0), Vector3(0.0, 0.38, 0.2), Vector3(0.65, 0.22, -0.15), Vector3(0.1, 0.18, -0.55)]:
		var ore := MeshInstance3D.new(); var mesh := SphereMesh.new(); mesh.radius = 0.48; mesh.height = 0.72; mesh.material = _material(Color("#c39442"), 0.72); ore.mesh = mesh; ore.position = offset; mine_node.add_child(ore)
	var label := _world_label("GOLD MINE", Color("#f1d279")); label.position = Vector3(0.0, 1.25, 0.0); mine_node.add_child(label)

func _spawn_workers() -> void:
	workers.append(_create_entity("worker_1", "Worker", "friendly", Vector3(-2.8, 0.0, -1.6), Color("#3e7471")))
	workers.append(_create_entity("worker_2", "Worker", "friendly", Vector3(-1.7, 0.0, -2.0), Color("#b1844b")))

func _spawn_enemy_camp() -> void:
	var camp := Node3D.new(); camp.name = "AshenRaiderCamp"; camp.position = Vector3(8.8, 0.0, 5.2); world.add_child(camp)
	_add_box("CampFire", Vector3(1.0, 0.12, 1.0), Vector3(0.0, 0.06, 0.0), Color("#8a422e"), camp)
	var label := _world_label("ASHEN CAMP", Color("#ef9070")); label.position = Vector3(0.0, 1.6, 0.0); camp.add_child(label)
	for index in range(ENEMY_POSITIONS.size()):
		enemies.append(_create_entity("raider_%d" % (index + 1), "Ashen Raider", "enemy", ENEMY_POSITIONS[index], Color("#8e4539")))

func _create_entity(id: String, role: String, team: String, position: Vector3, accent: Color) -> Dictionary:
	var root := Node3D.new(); root.name = id; root.position = position; root.set_meta("entity_id", id); world.add_child(root)
	var shadow := MeshInstance3D.new(); var shadow_mesh := CylinderMesh.new(); shadow_mesh.top_radius = 0.38; shadow_mesh.bottom_radius = 0.38; shadow_mesh.height = 0.02; shadow_mesh.material = _material(Color(0.05, 0.06, 0.05, 0.30), 0.99); shadow.mesh = shadow_mesh; shadow.position.y = 0.02; shadow.scale = Vector3(1.0, 1.0, 0.65); root.add_child(shadow)
	var body := MeshInstance3D.new(); var body_mesh := CapsuleMesh.new(); body_mesh.radius = 0.24 if role == "Worker" else 0.28; body_mesh.height = 1.15; body_mesh.material = _material(accent, 0.92); body.mesh = body_mesh; body.position.y = 0.68; root.add_child(body)
	var head := MeshInstance3D.new(); var head_mesh := SphereMesh.new(); head_mesh.radius = 0.18; head_mesh.height = 0.36; head_mesh.material = _material(Color("#c7a47c"), 0.98); head.mesh = head_mesh; head.position.y = 1.42; root.add_child(head)
	var sprite := MeshInstance3D.new(); var quad := QuadMesh.new(); quad.size = Vector2(0.72, 1.30); sprite.mesh = quad; sprite.position.y = 0.78
	var sprite_material := StandardMaterial3D.new(); sprite_material.albedo_texture = load(WORKER_TEXTURE if role == "Worker" else MILITIA_TEXTURE) as Texture2D; sprite_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; sprite_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED; sprite_material.cull_mode = BaseMaterial3D.CULL_DISABLED; sprite_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; sprite_material.albedo_color = Color(1.0, 1.0, 1.0, 0.78); sprite.material_override = sprite_material; root.add_child(sprite)
	var ring := MeshInstance3D.new(); var ring_mesh := CylinderMesh.new(); ring_mesh.top_radius = 0.52; ring_mesh.bottom_radius = 0.52; ring_mesh.height = 0.024; ring_mesh.material = _material(Color("#72b6a2") if team == "friendly" else Color("#d06650"), 0.94); ring.mesh = ring_mesh; ring.position.y = 0.05; ring.visible = false; root.add_child(ring)
	var starting_health: float = 260.0 if role == "Militia" else 100.0
	var entity := {"id":id,"role":role,"team":team,"node":root,"ring":ring,"hp":starting_health,"max_hp":starting_health,"state":"Idle","carry":0,"destination":position,"target":null,"gather_active":false,"gather_timer":0.0,"attack_timer":0.0,"alive":true}
	entities.append(entity)
	return entity

func _world_label(text_value: String, color: Color) -> Label3D:
	var label := Label3D.new(); label.text = text_value; label.font_size = 28; label.modulate = color; label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; label.no_depth_test = true; label.outline_size = 6; label.outline_modulate = Color(0.02, 0.03, 0.03, 0.78); return label

func _add_box(label: String, size: Vector3, position: Vector3, color: Color, parent: Node) -> MeshInstance3D:
	var instance := MeshInstance3D.new(); instance.name = label; var mesh := BoxMesh.new(); mesh.size = size; mesh.material = _material(color, 0.94); instance.mesh = mesh; instance.position = position; parent.add_child(instance); return instance

func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.albedo_color = color; material.roughness = roughness; material.metallic = 0.0; return material

func _build_launcher_ui() -> void:
	launcher_ui = Control.new(); launcher_ui.name = "V0367Launcher"; launcher_ui.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(launcher_ui)
	var backdrop := ColorRect.new(); backdrop.color = Color(0.035, 0.055, 0.055, 0.96); backdrop.set_anchors_preset(Control.PRESET_FULL_RECT); launcher_ui.add_child(backdrop)
	var panel := Panel.new(); panel.position = Vector2(230, 150); panel.size = Vector2(1140, 560); panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.09, 0.085, 0.98), Color("#c3a867"))); launcher_ui.add_child(panel)
	var title := Label.new(); title.text = "ASCENDANT REALMS"; title.position = Vector2(56, 56); title.add_theme_font_size_override("font_size", 42); title.add_theme_color_override("font_color", Color("#eddbad")); panel.add_child(title)
	var subtitle := Label.new(); subtitle.text = "BARROSAN — FIRST PLAYABLE VERTICAL SLICE"; subtitle.position = Vector2(60, 116); subtitle.add_theme_font_size_override("font_size", 22); subtitle.add_theme_color_override("font_color", Color("#9fc0ae")); panel.add_child(subtitle)
	var body := Label.new(); body.text = "Gather gold. Build a Field Barracks. Recruit Militia.\nMove across the hamlet and defeat the Ashen Raiders."; body.position = Vector2(62, 190); body.add_theme_font_size_override("font_size", 23); body.add_theme_color_override("font_color", Color("#d8ddd0")); panel.add_child(body)
	var play := Button.new(); play.name = "PlayVerticalSlice"; play.text = "PLAY VERTICAL SLICE"; play.position = Vector2(62, 330); play.size = Vector2(430, 72); play.add_theme_font_size_override("font_size", 24); play.pressed.connect(_start_match); panel.add_child(play)
	var controls := Label.new(); controls.text = "Left click select  •  Right click move / gather / attack  •  F3 debug  •  R restart after result"; controls.position = Vector2(62, 444); controls.add_theme_font_size_override("font_size", 15); controls.add_theme_color_override("font_color", Color("#b5c5b5")); panel.add_child(controls)

func _panel_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new(); style.bg_color = background; style.border_color = border; style.set_border_width_all(2); style.set_corner_radius_all(8); return style

func _start_match() -> void:
	if launcher_ui != null: launcher_ui.visible = false
	if result_ui != null: result_ui.queue_free(); result_ui = null
	if hud_ui != null: hud_ui.queue_free(); hud_ui = null
	for child in world.get_children():
		if child != main_building and child != mine_node and child.name in ["Terrain", "SouthRoad", "EastRoad", "RecessedStream", "RiverBankWest", "RiverBankEast", "BridgeDeck", "BridgeRailWest", "BridgeRailEast", "Barrosan_Pine", "CampFire"]: continue
		if is_instance_valid(child) and child != main_building and child != mine_node: child.queue_free()
	entities.clear(); workers.clear(); enemies.clear(); militia_units.clear(); selected.clear()
	construction_proxy = null; build_ghost = null; main_building.visible = true; main_hp = main_max_hp; gold = INITIAL_GOLD; mine_gold = MINE_STARTING_GOLD; barracks_node = null; barracks_entity = {}; barracks_ready = false; barracks_progress = 0.0; training_progress = -1.0; build_mode = false; match_elapsed = 0.0; last_result_victory = false; mode = Mode.PLAYING; status_message = "Select a Worker to begin."
	_spawn_workers(); _spawn_enemy_camp(); _build_hud(); _refresh_hud()

func _build_hud() -> void:
	hud_ui = Control.new(); hud_ui.name = "V0367PlayerHUD"; hud_ui.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(hud_ui)
	var top := Panel.new(); top.position = Vector2(24, 20); top.size = Vector2(820, 96); top.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.055, 0.05, 0.92), Color("#6d9a83"))); hud_ui.add_child(top)
	gold_label = Label.new(); gold_label.position = Vector2(22, 14); gold_label.add_theme_font_size_override("font_size", 24); top.add_child(gold_label)
	objective_label = Label.new(); objective_label.position = Vector2(22, 52); objective_label.add_theme_font_size_override("font_size", 16); objective_label.add_theme_color_override("font_color", Color("#d5d7c2")); top.add_child(objective_label)
	var hint := Label.new(); hint.text = "F3 DEBUG"; hint.position = Vector2(714, 18); hint.add_theme_font_size_override("font_size", 13); hint.add_theme_color_override("font_color", Color("#8ca59b")); top.add_child(hint)
	var selection_panel := Panel.new(); selection_panel.name = "SelectedEntityCard"; selection_panel.position = Vector2(24, 700); selection_panel.size = Vector2(520, 162); selection_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.05, 0.045, 0.94), Color("#987e4d"))); hud_ui.add_child(selection_panel)
	selection_label = Label.new(); selection_label.position = Vector2(18, 14); selection_label.add_theme_font_size_override("font_size", 21); selection_panel.add_child(selection_label)
	selection_health_label = Label.new(); selection_health_label.position = Vector2(18, 48); selection_health_label.add_theme_font_size_override("font_size", 15); selection_panel.add_child(selection_health_label)
	selection_status_label = Label.new(); selection_status_label.position = Vector2(18, 82); selection_status_label.add_theme_font_size_override("font_size", 15); selection_status_label.add_theme_color_override("font_color", Color("#b5c7b8")); selection_panel.add_child(selection_status_label)
	command_panel = VBoxContainer.new(); command_panel.position = Vector2(1110, 700); command_panel.size = Vector2(450, 162); hud_ui.add_child(command_panel)
	build_button = Button.new(); build_button.text = "BUILD FIELD BARRACKS — 100 GOLD"; build_button.custom_minimum_size = Vector2(450, 42); build_button.pressed.connect(_begin_build); command_panel.add_child(build_button)
	recruit_button = Button.new(); recruit_button.text = "RECRUIT MILITIA — 50 GOLD"; recruit_button.custom_minimum_size = Vector2(450, 42); recruit_button.pressed.connect(_recruit_militia); command_panel.add_child(recruit_button)
	cancel_button = Button.new(); cancel_button.text = "CANCEL PLACEMENT"; cancel_button.custom_minimum_size = Vector2(450, 42); cancel_button.pressed.connect(_cancel_build); command_panel.add_child(cancel_button)
	toast_label = Label.new(); toast_label.position = Vector2(580, 786); toast_label.size = Vector2(500, 52); toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; toast_label.add_theme_font_size_override("font_size", 18); toast_label.add_theme_color_override("font_color", Color("#f1d279")); hud_ui.add_child(toast_label)
	debug_label = Label.new(); debug_label.position = Vector2(1200, 22); debug_label.size = Vector2(360, 150); debug_label.add_theme_font_size_override("font_size", 13); debug_label.add_theme_color_override("font_color", Color("#d9b58c")); debug_label.visible = debug_mode; hud_ui.add_child(debug_label)

func _process(delta: float) -> void:
	if mode != Mode.PLAYING: return
	match_elapsed += delta
	_update_workers(delta)
	_update_construction(delta)
	_update_training(delta)
	_update_militia(delta)
	_update_enemies(delta)
	_update_camera_input(delta)
	_refresh_hud()

func _update_workers(delta: float) -> void:
	for worker in workers:
		if not worker.alive: continue
		if worker.state == "Moving" or worker.state == "Returning" or worker.state == "Constructing":
			if _move_entity(worker, worker.destination, 4.2 if smoke_mode else 2.45, delta):
				if worker.state == "Moving" and worker.gather_active: worker.state = "Gathering"; worker.gather_timer = 0.0
				elif worker.state == "Returning": _deposit_worker(worker)
				elif worker.state == "Constructing": status_message = "Constructing the Field Barracks."
		elif worker.state == "Gathering":
			worker.gather_timer += delta
			if worker.gather_timer >= (0.45 if smoke_mode else 1.7):
				worker.gather_timer = 0.0
				var amount: int = mini(WORKER_CAPACITY - int(worker.carry), mine_gold)
				worker.carry = int(worker.carry) + amount; mine_gold -= amount; worker.state = "Returning"; worker.destination = MAIN_POSITION + Vector3(1.0, 0.0, 0.6); status_message = "Worker carrying %d Gold home." % amount
				if amount <= 0: worker.gather_active = false; worker.state = "Idle"; status_message = "The Gold Mine is depleted."

func _deposit_worker(worker: Dictionary) -> void:
	if worker.carry <= 0: worker.state = "Idle"; return
	gold += int(worker.carry); worker.carry = 0; status_message = "Gold deposited at the Main Building."
	if worker.gather_active and mine_gold > 0: worker.state = "Moving"; worker.destination = MINE_POSITION
	else: worker.state = "Idle"

func _update_construction(delta: float) -> void:
	if barracks_node == null or barracks_ready: return
	var builder: Dictionary = barracks_entity.get("builder", {})
	if builder.is_empty() or not builder.alive: return
	if builder.node.position.distance_to(construction_position) > 0.35:
		builder.state = "Constructing"; builder.destination = construction_position; return
	builder.state = "Constructing"
	barracks_progress += delta * (0.42 if smoke_mode else 0.14)
	var proxy_scale := maxf(0.15, barracks_progress)
	if construction_proxy != null: construction_proxy.scale.y = proxy_scale
	status_message = "Constructing Field Barracks — %d%%" % int(minf(100.0, barracks_progress * 100.0))
	if barracks_progress >= 1.0:
		barracks_ready = true; barracks_entity.state = "Operational"; barracks_node.visible = true; if construction_proxy != null: construction_proxy.queue_free(); construction_proxy = null
		builder.state = "Idle"; status_message = "Field Barracks complete. Select it to recruit Militia."

func _update_training(delta: float) -> void:
	if training_progress < 0.0: return
	training_progress += delta * (2.0 if smoke_mode else 0.20)
	status_message = "Training Militia — %d%%" % int(minf(100.0, training_progress * 100.0))
	if training_progress >= 1.0:
		training_progress = -1.0
		var rally := construction_position + Vector3(2.0, 0.0, 0.0)
		var unit := _create_entity("militia_%d" % (militia_units.size() + 1), "Militia", "friendly", rally, Color("#3e7f73")); militia_units.append(unit); status_message = "Militia ready at the Field Barracks."

func _update_militia(delta: float) -> void:
	for unit in militia_units:
		if not unit.alive: continue
		if unit.state == "Moving" or unit.state == "Attacking":
			var target: Dictionary = unit.target if unit.target is Dictionary else {}
			if unit.state == "Attacking" and not target.is_empty() and target.alive:
				if unit.node.position.distance_to(target.node.position) <= 1.65:
					unit.attack_timer -= delta
					if unit.attack_timer <= 0.0: unit.attack_timer = 1.0 if not smoke_mode else 0.25; target.hp -= 18.0; status_message = "Militia attacking Ashen Raider."
				else: _move_entity(unit, target.node.position, 3.3 if smoke_mode else 2.1, delta)
			else: _move_entity(unit, unit.destination, 3.3 if smoke_mode else 2.1, delta)
			if target.is_empty() or not target.alive: unit.state = "Idle"; unit.target = null
	_check_deaths()

func _update_enemies(delta: float) -> void:
	for enemy in enemies:
		if not enemy.alive: continue
		var target: Dictionary = enemy.target if enemy.target is Dictionary else {}
		if target.is_empty() or not target.alive or enemy.node.position.distance_to(target.node.position) > 7.0:
			target = _nearest_player_target(enemy.node.position)
			enemy.target = target
		if target.is_empty(): continue
		if enemy.node.position.distance_to(target.node.position) <= 1.65:
			enemy.attack_timer -= delta
			if enemy.attack_timer <= 0.0:
				enemy.attack_timer = 1.1 if not smoke_mode else 0.28
				if target.get("id", "") == "main_building": main_hp -= 10.0
				else: target.hp -= 10.0
				status_message = "Ashen Raiders are striking %s." % target.role
		else: _move_entity(enemy, target.node.position, 1.5 if smoke_mode else 0.82, delta)
	_check_deaths()
	if main_hp <= 0.0 and mode == Mode.PLAYING: _end_match(false)

func _nearest_player_target(position: Vector3) -> Dictionary:
	var nearest := {}; var best := 999.0
	for candidate in workers + militia_units:
		if not candidate.alive: continue
		var distance := position.distance_to(candidate.node.position)
		if distance < best and distance <= 6.5: best = distance; nearest = candidate
	if nearest.is_empty() and position.distance_to(MAIN_POSITION) <= 8.0: nearest = {"id":"main_building","role":"Main Building","alive":true,"hp":main_hp,"node":main_building}
	return nearest

func _check_deaths() -> void:
	for candidate in workers + militia_units + enemies:
		if candidate.alive and candidate.hp <= 0.0:
			candidate.alive = false; candidate.state = "Dead"; candidate.node.visible = false; selected.erase(candidate); status_message = "%s defeated." % candidate.role
	if mode == Mode.PLAYING and not enemies.any(func(item): return item.alive): _end_match(true)

func _move_entity(entity: Dictionary, destination: Vector3, speed: float, delta: float) -> bool:
	var node: Node3D = entity.node
	var target := Vector3(destination.x, node.position.y, destination.z)
	var distance := node.position.distance_to(target)
	if distance <= 0.12: node.position = target; return true
	node.position += node.position.direction_to(target) * minf(speed * delta, distance)
	return false

func _begin_build() -> void:
	if selected.is_empty() or not selected.any(func(item): return item.role == "Worker" and item.alive): _toast("Select a Worker before building."); return
	if gold < BUILD_COST: _toast("Not enough Gold to build Field Barracks."); return
	build_mode = true; status_message = "Place the Barracks on open ground. Escape cancels."
	if build_ghost == null:
		build_ghost = _add_box("BarracksPlacementGhost", Vector3(3.4, 0.18, 2.8), BUILD_ZONE + Vector3(0.0, 0.18, 0.0), Color(0.36, 0.68, 0.52, 0.48), world)
		var ghost_material := _material(Color(0.36, 0.68, 0.52, 0.48), 0.92)
		ghost_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		build_ghost.material_override = ghost_material

func _cancel_build() -> void:
	build_mode = false; if build_ghost != null: build_ghost.queue_free(); build_ghost = null; status_message = "Placement cancelled."

func _try_place(point: Vector3) -> void:
	if not _valid_build_position(point): _toast("Invalid placement: keep clear of the river, road, mine, and Main Building."); return
	gold -= BUILD_COST; construction_position = Vector3(point.x, 0.0, point.z); _cancel_build(); barracks_node = _spawn_barracks(construction_position); barracks_node.visible = false; construction_proxy = _add_box("BarracksConstruction", Vector3(3.1, 1.0, 2.6), construction_position + Vector3(0.0, 0.5, 0.0), Color("#87735b"), world); var builder: Dictionary = selected.filter(func(item): return item.role == "Worker" and item.alive)[0]; barracks_entity = {"id":"barracks","role":"Field Barracks","team":"friendly","node":barracks_node,"ring":null,"hp":100.0,"max_hp":100.0,"state":"Constructing","alive":true,"builder":builder,"position":construction_position}; entities.append(barracks_entity); builder.state = "Constructing"; builder.destination = construction_position; status_message = "Barracks placed. Worker construction started."

func _valid_build_position(point: Vector3) -> bool:
	return point.x > -2.0 and point.x < 0.9 and point.z > -6.4 and point.z < -1.0 and point.distance_to(MAIN_POSITION) > 2.4 and absf(point.x - 3.0) > 2.0

func _recruit_militia() -> void:
	if not barracks_ready or selected.is_empty() or not selected.any(func(item): return item.id == "barracks"): _toast("Select the completed Field Barracks."); return
	if training_progress >= 0.0: _toast("A Militia is already training."); return
	if gold < MILITIA_COST: _toast("Not enough Gold to recruit Militia."); return
	gold -= MILITIA_COST; training_progress = 0.0; status_message = "Militia training started."

func _select_entity(entity: Dictionary) -> void:
	selected.clear(); if entity.is_empty() or not entity.alive: _refresh_selection(); return
	selected.append(entity); for candidate in entities: if candidate.has("ring") and is_instance_valid(candidate.ring): candidate.ring.visible = selected.has(candidate)
	_refresh_selection()

func _issue_right_click(point: Vector3) -> void:
	if build_mode: _try_place(point); return
	var enemy := _entity_at(point, "enemy")
	if not enemy.is_empty() and selected.any(func(item): return item.role == "Militia"):
		for unit in selected: if unit.role == "Militia" and unit.alive: unit.state = "Attacking"; unit.target = enemy; unit.destination = enemy.node.position
		status_message = "Militia attack order issued."; return
	if selected.any(func(item): return item.role == "Worker") and point.distance_to(MINE_POSITION) < 1.7:
		for worker in selected: if worker.role == "Worker" and worker.alive: worker.gather_active = true; worker.state = "Moving"; worker.destination = MINE_POSITION
		status_message = "Workers moving to Gold Mine."; return
	for unit in selected:
		if unit.role == "Worker" or unit.role == "Militia": unit.state = "Moving"; unit.destination = point; unit.target = null
	status_message = "Move order issued."

func _entity_at(point: Vector3, team_filter: String = "") -> Dictionary:
	var best := {}; var best_distance := 1.1
	for entity in entities:
		if not entity.alive or (team_filter != "" and entity.team != team_filter): continue
		var distance: float = entity.node.position.distance_to(point)
		if distance < best_distance: best_distance = distance; best = entity
	return best

func _refresh_selection() -> void:
	if hud_ui == null: return
	if selected.is_empty(): selection_label.text = "No selection"; selection_health_label.text = "Select Workers, the Barracks, or Militia."; selection_status_label.text = status_message
	else:
		var entity := selected[0]; selection_label.text = "%s" % entity.role; selection_health_label.text = "Health %d / %d" % [int(entity.hp), int(entity.max_hp)]; selection_status_label.text = "%s%s" % [str(entity.state), ("  |  Carrying %d Gold" % int(entity.carry) if entity.role == "Worker" and entity.carry > 0 else "")]
	build_button.visible = selected.any(func(item): return item.role == "Worker" and item.alive) and not barracks_ready
	recruit_button.visible = barracks_ready and selected.any(func(item): return item.id == "barracks")
	cancel_button.visible = build_mode

func _refresh_hud() -> void:
	if hud_ui == null: return
	gold_label.text = "GOLD  %d  |  Mine remaining %d" % [gold, mine_gold]
	objective_label.text = "OBJECTIVE  Gather 100 Gold → build Field Barracks → recruit Militia → defeat 2 Ashen Raiders"
	toast_label.text = status_message
	_refresh_selection()
	debug_label.visible = debug_mode
	if debug_mode: debug_label.text = "DEBUG REVIEW\nTime %.1fs\nWorkers %d  Militia %d\nMain HP %d\nBuild %.0f%%" % [match_elapsed, workers.size(), militia_units.size(), int(main_hp), barracks_progress * 100.0]
	if build_ghost != null and build_mode:
		var mouse := get_viewport().get_mouse_position(); var point := _screen_to_ground(mouse); build_ghost.position = Vector3(point.x, 0.18, point.z)
		var ghost_material := build_ghost.material_override as StandardMaterial3D
		if ghost_material != null: ghost_material.albedo_color = Color(0.32, 0.76, 0.46, 0.52) if _valid_build_position(point) else Color(0.78, 0.25, 0.18, 0.52)

func _toast(message: String) -> void:
	status_message = message; _refresh_hud()

func _screen_to_ground(screen_position: Vector2) -> Vector3:
	var origin := camera.project_ray_origin(screen_position); var direction := camera.project_ray_normal(screen_position)
	if absf(direction.y) < 0.001: return camera_focus
	var distance := -origin.y / direction.y; return origin + direction * distance

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F3 and mode == Mode.PLAYING: debug_mode = not debug_mode; _refresh_hud(); return
		if event.keycode == KEY_ESCAPE and build_mode: _cancel_build(); return
		if event.keycode == KEY_R and mode == Mode.RESULT: _start_match(); return
	if mode != Mode.PLAYING: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: camera_zoom = maxf(12.0, camera_zoom - 1.0); _update_camera(); return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN: camera_zoom = minf(24.0, camera_zoom + 1.0); _update_camera(); return
		var point := _screen_to_ground(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if build_mode: _try_place(point); return
			var entity := _entity_at(point)
			if not entity.is_empty(): _select_entity(entity)
			else: _select_entity({})
		elif event.button_index == MOUSE_BUTTON_RIGHT: _issue_right_click(point)

func _update_camera_input(delta: float) -> void:
	var direction := Vector3.ZERO
	if Input.is_key_pressed(KEY_A): direction.x -= 1.0
	if Input.is_key_pressed(KEY_D): direction.x += 1.0
	if Input.is_key_pressed(KEY_W): direction.z -= 1.0
	if Input.is_key_pressed(KEY_S): direction.z += 1.0
	if direction != Vector3.ZERO: camera_focus += direction.normalized() * 6.0 * delta; camera_focus.x = clampf(camera_focus.x, -5.5, 5.5); camera_focus.z = clampf(camera_focus.z, -4.0, 4.0); _update_camera()

func _end_match(victory: bool) -> void:
	last_result_victory = victory
	mode = Mode.RESULT
	build_mode = false
	if build_ghost != null:
		build_ghost.queue_free()
		build_ghost = null
	_build_result_ui(victory)
	if hud_ui != null:
		hud_ui.visible = false
	if result_ui != null:
		result_ui.visible = true

func _build_result_ui(victory: bool) -> void:
	result_ui = Control.new(); result_ui.name = "V0367ResultOverlay"; result_ui.set_anchors_preset(Control.PRESET_FULL_RECT); result_ui.visible = true; add_child(result_ui); result_ui.show()
	var shade := ColorRect.new(); shade.color = Color(0.02, 0.03, 0.03, 0.68); shade.set_anchors_preset(Control.PRESET_FULL_RECT); result_ui.add_child(shade)
	var panel := Panel.new(); panel.position = Vector2(430, 245); panel.size = Vector2(740, 390); panel.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.08, 0.07, 0.98), Color("#c3a867" if victory else "#b55b4a"))); result_ui.add_child(panel)
	result_title = Label.new(); result_title.text = "VICTORY" if victory else "DEFEAT"; result_title.position = Vector2(50, 48); result_title.add_theme_font_size_override("font_size", 54); result_title.add_theme_color_override("font_color", Color("#f0d58d") if victory else Color("#ed9276")); panel.add_child(result_title)
	result_detail = Label.new(); result_detail.text = "All Ashen Raiders defeated." if victory else "The Main Building was destroyed."; result_detail.position = Vector2(52, 132); result_detail.add_theme_font_size_override("font_size", 23); result_detail.add_theme_color_override("font_color", Color("#d9dfd1")); panel.add_child(result_detail)
	var restart := Button.new(); restart.text = "RESTART MATCH"; restart.position = Vector2(52, 230); restart.size = Vector2(280, 58); restart.pressed.connect(_start_match); panel.add_child(restart)
	var launcher := Button.new(); launcher.text = "RETURN TO LAUNCHER"; launcher.position = Vector2(370, 230); launcher.size = Vector2(300, 58); launcher.pressed.connect(_return_to_launcher); panel.add_child(launcher)

func _return_to_launcher() -> void:
	if hud_ui != null: hud_ui.queue_free(); hud_ui = null
	if result_ui != null: result_ui.queue_free(); result_ui = null
	launcher_ui.visible = true; mode = Mode.MENU

func _run_smoke() -> void:
	var result := {"checkpoint":CHECKPOINT,"status":"PASS","goldDeposited":false,"barracksBuilt":false,"militiaRecruited":false,"combatResolved":false,"victory":false,"restartRestored":false,"errors":[]}
	for worker in workers: worker.gather_active = true; worker.state = "Moving"; worker.destination = MINE_POSITION
	var deadline := 60.0
	while gold < INITIAL_GOLD + BUILD_COST + MILITIA_COST and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.goldDeposited = gold >= INITIAL_GOLD + BUILD_COST + MILITIA_COST
	if not result.goldDeposited: result.errors.append("workers did not deposit enough Gold")
	_select_entity(workers[0]); _try_place(BUILD_ZONE)
	deadline = 10.0
	while not barracks_ready and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.barracksBuilt = barracks_ready
	_select_entity({"id":"barracks","role":"Field Barracks","alive":true,"hp":100.0,"max_hp":100.0,"state":"Operational","node":barracks_node}); _recruit_militia()
	deadline = 10.0
	while militia_units.is_empty() and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.militiaRecruited = not militia_units.is_empty()
	if result.militiaRecruited:
		for enemy in enemies:
			if not enemy.alive: continue
			militia_units[0].state = "Attacking"; militia_units[0].target = enemy; militia_units[0].destination = enemy.node.position
			deadline = 35.0
			while enemy.alive and mode == Mode.PLAYING and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
		deadline = 35.0
		while mode == Mode.PLAYING and deadline > 0.0: await get_tree().process_frame; deadline -= 1.0 / 60.0
	result.victory = mode == Mode.RESULT and last_result_victory; result.combatResolved = result.victory
	_start_match(); result.restartRestored = gold == INITIAL_GOLD and militia_units.is_empty() and not barracks_ready
	_write_json(capture_root.path_join("v0367-playable-smoke.json"), result)
	get_tree().quit(0 if result.errors.is_empty() and result.victory and result.restartRestored else 1)

func _run_capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capture_root))
	await _capture_image("01_SLICE_START_PLAYER_VIEW.png")
	for worker in workers: worker.gather_active = true; worker.state = "Moving"; worker.destination = MINE_POSITION
	while gold < INITIAL_GOLD + BUILD_COST + MILITIA_COST: await get_tree().process_frame
	_select_entity(workers[0]); _try_place(BUILD_ZONE); await get_tree().process_frame
	await _capture_image("02_ECONOMY_AND_CONSTRUCTION.png")
	while not barracks_ready: await get_tree().process_frame
	_select_entity({"id":"barracks","role":"Field Barracks","alive":true,"hp":100.0,"max_hp":100.0,"state":"Operational","node":barracks_node}); _recruit_militia()
	while militia_units.is_empty(): await get_tree().process_frame
	for enemy in enemies:
		if not enemy.alive: continue
		militia_units[0].state = "Attacking"; militia_units[0].target = enemy; militia_units[0].destination = enemy.node.position
		var combat_guard := 0
		while enemy.alive and mode == Mode.PLAYING and combat_guard < 900: await get_tree().process_frame; combat_guard += 1
	if mode == Mode.PLAYING:
		var enemies_remaining := false
		for enemy in enemies:
			if enemy.alive: enemies_remaining = true
		if not enemies_remaining: _end_match(true)
		else: _end_match(false)
	await get_tree().process_frame; await get_tree().process_frame; await get_tree().process_frame
	while mode == Mode.PLAYING: await get_tree().process_frame
	await _capture_image("03_COMBAT_AND_RESULT.png")
	_start_match(); await get_tree().process_frame; await _capture_image("04_RESTARTED_MATCH_PLAYER_VIEW.png")
	get_tree().quit(0)

func _capture_image(filename: String) -> void:
	await get_tree().process_frame; await get_tree().process_frame
	var image := get_viewport().get_texture().get_image(); var path := capture_root.path_join(filename); image.save_png(ProjectSettings.globalize_path(path)); capture_files.append(path)

func _write_json(path: String, value: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir())); var file := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE); if file != null: file.store_string(JSON.stringify(value, "  ")); file.close()

func _derive_mesh(source: ArrayMesh, target: String) -> Dictionary:
	var derived := ArrayMesh.new(); var before := 0; var after := 0
	for surface in range(source.get_surface_count()):
		var arrays: Array = source.surface_get_arrays(surface); var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]; var source_indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]; var indices := source_indices if source_indices.size() > 0 else PackedInt32Array(range(vertices.size())); before += indices.size() / 3
		var kept := PackedInt32Array(); var components := _triangle_components(vertices, indices)
		for triangle in range(0, indices.size(), 3):
			var component_id := int(components[triangle / 3]); var box: AABB = components.get("aabb_%d" % component_id, AABB());
			if not _component_matches(box, target): kept.append_array(PackedInt32Array([indices[triangle], indices[triangle + 1], indices[triangle + 2]]))
		after += kept.size() / 3; var out: Array = []; out.resize(Mesh.ARRAY_MAX); out[Mesh.ARRAY_VERTEX] = vertices; out[Mesh.ARRAY_INDEX] = kept
		for attribute in [Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_COLOR, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2, Mesh.ARRAY_BONES, Mesh.ARRAY_WEIGHTS]: if arrays[attribute] != null and arrays[attribute].size() > 0: out[attribute] = arrays[attribute]
		derived.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out); var material := source.surface_get_material(surface); if material != null: derived.surface_set_material(surface, material)
	return {"mesh":derived,"before":before,"after":after}

func _component_matches(box: AABB, target: String) -> bool:
	var center := box.get_center()
	if target == "HOUSE_A": return center.x > 1.5 and center.x < 4.8 and center.y > 0.45 and center.y < 0.95 and center.z > -0.8 and center.z < 1.1
	if target == "HOUSE_B": return center.x > 2.5 and center.x < 5.2 and center.y > 0.45 and center.y < 2.85 and center.z > -0.35 and center.z < 0.45
	if target == "BARN_C": return center.z < -4.25 and center.x > -5.7 and center.x < -2.15 and center.y < 2.05
	return false

func _triangle_components(vertices: PackedVector3Array, indices: PackedInt32Array) -> Dictionary:
	var keys: Dictionary = {}; var vertex_keys := PackedInt32Array(); var parents: Array[int] = []
	for vertex in vertices:
		var key := "%d:%d:%d" % [roundi(vertex.x * 1000.0), roundi(vertex.y * 1000.0), roundi(vertex.z * 1000.0)]
		if not keys.has(key): keys[key] = parents.size(); parents.append(parents.size())
		vertex_keys.append(int(keys[key]))
	for triangle in range(0, indices.size(), 3): _union(parents, vertex_keys[indices[triangle]], vertex_keys[indices[triangle + 1]]); _union(parents, vertex_keys[indices[triangle + 1]], vertex_keys[indices[triangle + 2]]); _union(parents, vertex_keys[indices[triangle + 2]], vertex_keys[indices[triangle]])
	var aabbs: Dictionary = {}
	for index in range(vertices.size()): var root := _find(parents, vertex_keys[index]); aabbs[root] = aabbs.get(root, AABB(vertices[index], Vector3.ZERO)).expand(vertices[index])
	var component_ids: Dictionary = {}; var result := {}; var next_id := 0
	for triangle in range(0, indices.size(), 3):
		var root := _find(parents, vertex_keys[indices[triangle]]); if not component_ids.has(root): component_ids[root] = next_id; result["aabb_%d" % next_id] = aabbs[root]; next_id += 1
		result[triangle / 3] = int(component_ids[root])
	return result

func _union(parents: Array[int], a: int, b: int) -> void:
	var root_a := _find(parents, a); var root_b := _find(parents, b); if root_a != root_b: parents[root_b] = root_a

func _find(parents: Array[int], value: int) -> int:
	var result := value
	while parents[result] != result: result = parents[result]
	return result
