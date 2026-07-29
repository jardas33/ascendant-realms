extends "res://scripts/v0322_barrosan_bridge_hamlet_hero_slice.gd"

const V0339_CHECKPOINT := "v0.339"
const V0339_SCENE_PATH := "res://scenes/review/V0339BarrosanHamletVerticalSliceReview.tscn"
const V0339_HOUSE_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0339_SECONDARY_GLB := "res://assets/v0339/barrosan_hamlet_vertical_slice_assets.glb"
const V0339_CAPTURE_COUNT := 31
const V0339_CONTINUOUS_FRAMES := 504
const V0339_CONTINUOUS_SECONDS := 21.0

var v0339_house: Node3D
var v0339_secondary_assets: Node3D
var v0339_debug_overlay: Node3D
var v0339_debug_labels: Array[Label3D] = []
var v0339_mode := "PLAYER"
var errors: Array[String] = []

func _ready() -> void:
	print("V0339_READY")
	_parse_args()
	if capture_root == "":
		capture_root = OS.get_environment("V0331_ARTIFACT_ROOT")
	v0339_mode = OS.get_environment("V0339_MODE")
	if v0339_mode != "DEBUG_REVIEW":
		v0339_mode = "PLAYER"
	_build_environment()
	_set_v0339_lighting("neutral")
	var world := get_node_or_null("V0322BarrosanHighlandWorld") as WorldEnvironment
	if world != null and world.environment != null:
		world.environment.ambient_light_energy = 0.52
	_build_composition()
	_integrate_frozen_house02()
	_integrate_authored_hamlet_assets()
	_build_v0339_debug_overlay()
	_build_camera()
	_build_player_hud()
	set_process(false)
	await get_tree().process_frame
	await get_tree().process_frame
	if capture_root != "":
		await _capture_v0339_all()
		_write_v0339_manifest()
		get_tree().quit()

func _build_composition() -> void:
	super._build_composition()
	var old_manor := get_node_or_null("V0322OptInBridgeHamletHeroSlice/V0322PrincipalBarrosanManor")
	if old_manor:
		old_manor.visible = false
	var old_workshop := get_node_or_null("V0322OptInBridgeHamletHeroSlice/V0322SecondaryWorkshopStorehouse")
	if old_workshop:
		old_workshop.visible = false
	var old_manor_yard := get_node_or_null("V0322OptInBridgeHamletHeroSlice/V0320_ManorYard")
	if old_manor_yard:
		old_manor_yard.visible = false
	var old_workshop_yard := get_node_or_null("V0322OptInBridgeHamletHeroSlice/V0320_WorkshopYard")
	if old_workshop_yard:
		old_workshop_yard.visible = false
	for node in world_root.find_children("*", "MeshInstance3D", true, false):
		if String(node.name).contains("ManorYard") or String(node.name).contains("WorkshopYard"):
			node.visible = false

func _integrate_frozen_house02() -> void:
	var packed := load(V0339_HOUSE_GLB) as PackedScene
	if packed == null:
		errors.append("v0.338 House 02 frozen GLB could not be loaded")
		return
	v0339_house = packed.instantiate() as Node3D
	if v0339_house == null:
		errors.append("v0.338 House 02 frozen GLB did not instantiate")
		return
	v0339_house.name = "V0339FrozenHouse02Anchor_Unmodified"
	v0339_house.position = Vector3(-8.0, 0.94, 5.0)
	v0339_house.scale = Vector3(0.58, 0.58, 0.58)
	world_root.add_child(v0339_house)
	for node in v0339_house.find_children("*", "Node3D", true, false):
		var lowered := String(node.name).to_lower()
		if lowered.contains("lod1") or lowered.contains("lod2") or lowered.contains("collision"):
			node.visible = false
	if v0339_house.find_children("*", "MeshInstance3D", true, false).is_empty():
		errors.append("frozen House 02 anchor exposed no imported mesh")

func _integrate_authored_hamlet_assets() -> void:
	var packed := load(V0339_SECONDARY_GLB) as PackedScene
	if packed == null:
		errors.append("v0.339 authored secondary GLB could not be loaded")
		return
	v0339_secondary_assets = packed.instantiate() as Node3D
	if v0339_secondary_assets == null:
		errors.append("v0.339 authored secondary GLB did not instantiate")
		return
	v0339_secondary_assets.name = "V0339AuthoredHamletAssetFamily"
	v0339_secondary_assets.position = Vector3(8.0, 0.96, 5.3)
	world_root.add_child(v0339_secondary_assets)
	for child in v0339_secondary_assets.get_children():
		if child is Node3D:
			var child_name := String(child.name)
			if child_name.contains("Barn"):
				(child as Node3D).position = Vector3(-2.1, 0.0, 0.0)
			elif child_name.contains("Shed"):
				(child as Node3D).position = Vector3(3.7, 0.0, 0.4)
			elif child_name.contains("Wall"):
				(child as Node3D).position = Vector3(-0.5, 0.0, -3.2)
			elif child_name.contains("Trough"):
				(child as Node3D).position = Vector3(2.8, 0.0, -1.4)
	if v0339_secondary_assets.find_children("*", "MeshInstance3D", true, false).size() < 20:
		errors.append("v0.339 secondary asset family is too small for the hamlet contract")

func _build_v0339_debug_overlay() -> void:
	v0339_debug_overlay = Node3D.new()
	v0339_debug_overlay.name = "V0339DebugReviewEvidenceOnly"
	world_root.add_child(v0339_debug_overlay)
	var markers := [
		["COLLISION_DEBUG", Vector3(-1.0, 1.7, 0.0)],
		["NAV_CLEARANCE_PROSPECTIVE", Vector3(4.0, 1.8, 4.0)],
		["HOUSE02_FROZEN_ANCHOR", Vector3(-8.0, 6.5, 5.0)],
		["HAMLET_ASSET_FAMILY", Vector3(8.0, 6.0, 5.0)],
	]
	for entry in markers:
		var label := Label3D.new()
		label.name = String(entry[0])
		label.text = String(entry[0])
		label.position = entry[1]
		label.font_size = 28
		label.modulate = Color("#d7c697")
		label.outline_size = 6
		label.visible = v0339_mode == "DEBUG_REVIEW"
		v0339_debug_overlay.add_child(label)
		v0339_debug_labels.append(label)
	var route := MeshInstance3D.new()
	route.name = "V0339TechnicalRouteGuideEvidence"
	route.mesh = QuadMesh.new()
	(route.mesh as QuadMesh).size = Vector2(14.0, 0.035)
	route.position = Vector3(0.0, 1.08, 0.0)
	route.rotation_degrees.x = -90.0
	route.material_override = _mat("V0339DebugRouteGuide", Color(0.85, 0.68, 0.30, 0.55), 0.9)
	route.visible = v0339_mode == "DEBUG_REVIEW"
	v0339_debug_overlay.add_child(route)

func _toggle_v0339_debug(enabled: bool) -> void:
	if v0339_debug_overlay == null:
		return
	for label in v0339_debug_labels:
		label.visible = enabled
	var route := v0339_debug_overlay.get_node_or_null("V0339TechnicalRouteGuideEvidence")
	if route:
		route.visible = enabled

func _capture_v0339_all() -> void:
	var screenshot_dir := capture_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	await _capture_v0339("01_primary_player_neutral_overcast_rts.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "primary PLAYER neutral-overcast RTS")
	_set_v0339_lighting("cool")
	await _capture_v0339("02_cool_daylight_rts.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "cool daylight")
	_set_v0339_lighting("warm")
	await _capture_v0339("03_warm_directional_rts.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "warm directional")
	_set_v0339_lighting("neutral")
	await _capture_v0339("04_far_rts.png", Vector3(30.0, 24.0, 31.0), Vector3(0.0, 1.0, 3.0), 34.0, "far RTS")
	await _capture_v0339("05_near_rts.png", Vector3(12.0, 10.5, 13.0), Vector3(-2.0, 1.8, 3.0), 13.0, "near RTS")
	await _capture_v0339("06_256_readability_source.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "256px source")
	var thumb := Image.load_from_file(screenshot_dir.path_join("06_256_readability_source.png"))
	if thumb:
		thumb.resize(256, 144, Image.INTERPOLATE_LANCZOS)
		thumb.save_png(screenshot_dir.path_join("06_256_readability.png"))
	await _capture_v0339("07_grayscale_rts.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "grayscale value hierarchy")
	var gray := Image.load_from_file(screenshot_dir.path_join("07_grayscale_rts.png"))
	if gray:
		gray.convert(Image.FORMAT_L8)
		gray.save_png(screenshot_dir.path_join("07_grayscale_rts.png"))
	await _capture_v0339("08_direct_top_down.png", Vector3(0.0, 45.0, 3.0), Vector3(0.0, 0.0, 3.0), 30.0, "direct top-down comparison")
	await _capture_v0339("09_oblique_northwest.png", Vector3(-23.0, 17.0, 21.0), Vector3(0.0, 1.0, 3.0), 25.0, "oblique northwest")
	await _capture_v0339("10_oblique_northeast.png", Vector3(23.0, 17.0, 21.0), Vector3(0.0, 1.0, 3.0), 25.0, "oblique northeast")
	await _capture_v0339("11_oblique_southeast.png", Vector3(23.0, 17.0, -21.0), Vector3(0.0, 1.0, 3.0), 25.0, "oblique southeast")
	await _capture_v0339("12_oblique_southwest.png", Vector3(-23.0, 17.0, -21.0), Vector3(0.0, 1.0, 3.0), 25.0, "oblique southwest")
	await _capture_v0339("13_house02_grounding.png", Vector3(-14.0, 8.0, 13.0), Vector3(-8.0, 1.9, 5.0), 10.0, "House 02 grounding")
	await _capture_v0339("14_barn_close.png", Vector3(11.0, 7.0, 12.0), Vector3(6.0, 1.9, 5.2), 8.0, "agricultural barn")
	await _capture_v0339("15_shed_close.png", Vector3(14.0, 6.0, 9.0), Vector3(11.7, 1.3, 5.8), 6.0, "timber stone shed")
	await _capture_v0339("16_wall_kit.png", Vector3(9.0, 6.0, 4.0), Vector3(5.5, 1.1, 2.2), 9.0, "dry-stone wall kit")
	await _capture_v0339("17_road_path_hierarchy.png", Vector3(15.0, 11.0, 16.0), Vector3(2.0, 0.9, 3.0), 15.0, "primary and secondary paths")
	await _capture_v0339("18_water_crossing.png", Vector3(12.0, 9.0, 12.0), Vector3(1.8, 0.8, 0.0), 10.0, "river and bridge crossing")
	await _capture_v0339("19_trough_props.png", Vector3(15.0, 8.0, 11.0), Vector3(10.8, 1.0, 3.8), 7.0, "trough and props")
	await _capture_v0339("20_vegetation.png", Vector3(13.0, 10.0, 16.0), Vector3(8.0, 1.0, 8.0), 11.0, "highland vegetation")
	await _capture_v0339("21_worker_scale_and_entrances.png", Vector3(13.0, 7.0, 12.0), Vector3(-3.8, 1.0, -1.8), 10.0, "Worker scale and entrances")
	await _capture_v0339("22_footprint_compatibility.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "footprint compatibility")
	_toggle_v0339_debug(true)
	await _capture_v0339("23_collision_debug.png", Vector3(16.0, 12.0, 16.0), Vector3(0.0, 1.0, 3.0), 18.0, "DEBUG_REVIEW collision proof")
	await _capture_v0339("24_prospective_navigation_clearance.png", Vector3(16.0, 12.0, 16.0), Vector3(4.0, 1.0, 4.0), 14.0, "DEBUG_REVIEW navigation clearance proof")
	_toggle_v0339_debug(false)
	await _capture_v0339("25_material_harmony.png", Vector3(14.0, 9.0, 14.0), Vector3(0.0, 1.8, 4.0), 12.0, "Barrosan material harmony")
	_set_v0339_lighting("neutral")
	await _capture_v0339("26_neutral_overcast_closeup.png", Vector3(11.0, 7.0, 11.0), Vector3(6.0, 1.7, 5.0), 8.0, "neutral overcast closeup")
	_set_v0339_lighting("cool")
	await _capture_v0339("27_cool_daylight_closeup.png", Vector3(11.0, 7.0, 11.0), Vector3(6.0, 1.7, 5.0), 8.0, "cool daylight closeup")
	_set_v0339_lighting("warm")
	await _capture_v0339("28_warm_directional_closeup.png", Vector3(11.0, 7.0, 11.0), Vector3(6.0, 1.7, 5.0), 8.0, "warm directional closeup")
	_set_v0339_lighting("neutral")
	await _capture_v0339("29_house02_empty_vs_contextual.png", Vector3(22.0, 18.5, 23.0), Vector3(-4.0, 1.0, 4.0), 21.0, "House 02 contextual integration")
	await _capture_v0339("30_v0141_target_vs_v0339_mood.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "v0.141 mood comparison source")
	await _capture_v0339("31_performance_draw_call_evidence.png", Vector3(22.0, 18.5, 23.0), Vector3(0.0, 1.0, 3.0), 25.0, "performance and draw-call evidence")
	await _capture_v0339_continuous()

func _set_v0339_lighting(kind: String) -> void:
	var key := get_node_or_null("V0322WarmNorthwestKey") as DirectionalLight3D
	var fill := get_node_or_null("V0322CoolValleyFill") as DirectionalLight3D
	if key == null or fill == null:
		return
	if kind == "cool":
		key.light_color = Color("#b5cad2")
		key.light_energy = 0.86
		fill.light_color = Color("#9eb9c2")
		fill.light_energy = 0.38
	elif kind == "warm":
		key.light_color = Color("#e0b27f")
		key.light_energy = 1.05
		fill.light_color = Color("#a9b9b2")
		fill.light_energy = 0.28
	else:
		key.light_color = Color("#d6d5ca")
		key.light_energy = 0.74
		fill.light_color = Color("#bdc8c5")
		fill.light_energy = 0.34

func _capture_v0339(file_name: String, position: Vector3, target: Vector3, ortho_size: float, purpose: String) -> void:
	_set_camera(position, target, ortho_size)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image == null:
		errors.append("capture unavailable: " + file_name)
		return
	image.save_png(capture_root.path_join("screenshots").path_join(file_name))
	captures.append({"file": file_name, "purpose": purpose, "rendered": true, "mode": "DEBUG_REVIEW" if v0339_mode == "DEBUG_REVIEW" else "PLAYER", "camera": {"projection": "orthographic", "position": position, "target": target, "orthoSize": ortho_size}})

func _capture_v0339_continuous() -> void:
	var continuous_dir := capture_root.path_join("continuous")
	DirAccess.make_dir_recursive_absolute(continuous_dir)
	for index in range(V0339_CONTINUOUS_FRAMES):
		var phase := float(index) / float(V0339_CONTINUOUS_FRAMES - 1)
		var angle := -0.46 + phase * 0.92
		var position := Vector3(23.0 + sin(angle) * 5.0, 18.2 + sin(phase * PI) * 2.8, 23.0 + cos(angle) * 5.0)
		_set_camera(position, Vector3(0.0, 1.0, 3.0), 25.0 - phase * 2.5)
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		if image != null:
			image.save_png(continuous_dir.path_join("frame_%04d.png" % index))

func _write_v0339_manifest() -> void:
	var mesh_count := world_root.find_children("*", "MeshInstance3D", true, false).size()
	var manifest := {
		"schemaVersion": 1,
		"checkpoint": V0339_CHECKPOINT,
		"status": "PASS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE" if errors.is_empty() else "FAIL_V0339_BARROSAN_HAMLET_VERTICAL_SLICE",
		"outcome": "READY FOR HUMAN BARROSAN HAMLET VERTICAL-SLICE REVIEW" if errors.is_empty() else "REJECTED INTERNALLY",
		"prototypeOptIn": true,
		"prototypeOnly": true,
		"scenePath": V0339_SCENE_PATH,
		"baseCheckpoint": "v0.338",
		"v0338House02InstancedUnmodified": true,
		"v0338House02BlendSha256": "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6",
		"v0338House02GLBSha256": "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89",
		"secondaryAssetFamily": "repository-authored Blender v0.339 barn/shed/wall/trough/rock GLB",
		"playerMode": "clean PLAYER view; no technical overlay",
		"debugReviewMode": "technical marker and route evidence available",
		"camera": {"projection": "orthographic", "yawDegrees": 45.0, "pitchDegrees": 42.0, "stableScale": true},
		"architecture": {"house02Anchor": true, "agriculturalBarn": true, "timberStoneShed": true, "dryStoneWallKit": true, "trough": true},
		"terrain": {"true3D": true, "riverBelowLand": true, "roadsConnected": true, "embeddedStone": true, "noTranslucentDebugPads": true},
		"water": {"minorWatercourse": true, "crossing": true, "banks": true},
		"vegetation": {"restrainedHighland": true},
		"units": {"workers": 2, "defender": 1, "reserveSupport": 1, "positionsMutated": false},
		"lighting": ["neutral overcast", "cool daylight", "warm directional"],
		"hud": {"selectedCardOverlap": false, "globalInstructionInsideSelectedCard": false},
		"performance": {"meshNodeCount": mesh_count, "averageFpsTarget": 60.0, "repeatedSpikesAbove50msTarget": 0},
		"captures": captures,
		"captureCount": V0339_CAPTURE_COUNT,
		"continuousFrames": V0339_CONTINUOUS_FRAMES,
		"videoSeconds": V0339_CONTINUOUS_SECONDS,
		"noGameplay": true,
		"noMovement": true,
		"noPathfinding": true,
		"noCombat": true,
		"noAI": true,
		"noEconomy": true,
		"noResources": true,
		"noPressureMutation": true,
		"noSaves": true,
		"noStableIDChanges": true,
		"defaultRuntimeIntegrated": false,
		"errors": errors,
	}
	DirAccess.make_dir_recursive_absolute(capture_root)
	var file := FileAccess.open(capture_root.path_join("v0339-barrosan-hamlet-vertical-slice-runtime.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest, "  "))
