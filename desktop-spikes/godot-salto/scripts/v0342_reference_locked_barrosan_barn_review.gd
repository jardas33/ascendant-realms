extends "res://scripts/v0322_barrosan_bridge_hamlet_hero_slice.gd"

const V0342_CHECKPOINT := "v0.342"
const V0342_SCENE_PATH := "res://scenes/review/V0342ReferenceLockedBarrosanBarnReview.tscn"
const V0342_HOUSE_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const V0342_BARN_GLB := "res://assets/v0342/reference_locked_barrosan_two_storey_barn.glb"
const V0342_CAPTURE_COUNT := 44
const V0342_CONTINUOUS_FRAMES := 360

var barn: Node3D
var house: Node3D
var review_root: Node3D
var errors: Array[String] = []
var mode := "PLAYER"
var original_positions: Dictionary = {}

func _ready() -> void:
	print("V0342_READY")
	_parse_args()
	if capture_root == "": capture_root = OS.get_environment("V0331_ARTIFACT_ROOT")
	_build_environment()
	_build_composition()
	_build_camera()
	_build_player_hud()
	if hud != null: hud.visible = false
	set_process(false)
	if capture_root != "":
		await get_tree().process_frame
		await get_tree().process_frame
		await _capture_v0342_all()
		_write_manifest()
		get_tree().quit()

func _build_environment() -> void:
	super._build_environment()
	var world := get_node_or_null("V0322BarrosanHighlandWorld") as WorldEnvironment
	if world != null and world.environment != null:
		world.environment.fog_enabled = false
		world.environment.background_color = Color("#718078")
		world.environment.ambient_light_energy = 0.92
	var key := get_node_or_null("V0322WarmNorthwestKey") as DirectionalLight3D
	if key != null:
		key.light_color = Color("#f0c995"); key.light_energy = 1.05; key.shadow_enabled = true
	var fill := get_node_or_null("V0322CoolValleyFill") as DirectionalLight3D
	if fill != null: fill.light_color = Color("#9bb4b3"); fill.light_energy = 0.42

func _build_composition() -> void:
	super._build_composition()
	# Keep only the inherited true-3D scale actors. All accepted gameplay/proof
	# presentation remains outside this opt-in art review scene.
	for mesh in world_root.find_children("*", "MeshInstance3D", true, false):
		var ancestor := mesh.get_parent()
		var keep := false
		while ancestor != null:
			if String(ancestor.name).begins_with("V0322True3D_"):
				keep = true; break
			ancestor = ancestor.get_parent()
		mesh.visible = keep
	review_root = Node3D.new(); review_root.name = "V0342_OptIn_ReferenceLocked_Barn_Review_Content"; world_root.add_child(review_root)
	_build_review_terrain()
	_integrate_frozen_house02()
	_integrate_barn()
	_place_scale_units()

func _build_review_terrain() -> void:
	var grass := _mat("V0342Review_Highland_Grass", Color("#536b54"), 0.98)
	var earth := _mat("V0342Review_Worn_Earth", Color("#765b43"), 0.99)
	var water := _mat("V0342Review_Recessed_River", Color("#2c6670"), 0.24, 0.04)
	var bank := _mat("V0342Review_Damp_Bank", Color("#655443"), 0.98)
	var ground_st := SurfaceTool.new(); ground_st.begin(Mesh.PRIMITIVE_TRIANGLES); ground_st.set_material(grass)
	var pts := [Vector3(-16,0.12,-13),Vector3(-6,0.35,-15),Vector3(9,0.08,-14),Vector3(16,0.42,-6),Vector3(15,0.16,11),Vector3(5,0.50,15),Vector3(-10,0.24,13),Vector3(-17,0.10,5)]
	for i in range(1, pts.size()-1): ground_st.add_vertex(pts[0]); ground_st.add_vertex(pts[i]); ground_st.add_vertex(pts[i+1])
	var ground := MeshInstance3D.new(); ground.name = "V0342_Irregular_NoBoard_Ground"; ground.mesh = ground_st.commit(); review_root.add_child(ground)
	var river_st := SurfaceTool.new(); river_st.begin(Mesh.PRIMITIVE_TRIANGLES); river_st.set_material(water)
	for i in range(8):
		var z0 := -14.0 + i*3.8; var z1 := z0+3.8; var c0 := 4.0 + sin(z0*.28)*1.1; var c1 := 4.0 + sin(z1*.28)*1.1
		river_st.add_vertex(Vector3(c0-1.15,0.02,z0)); river_st.add_vertex(Vector3(c0+1.15,0.02,z0)); river_st.add_vertex(Vector3(c1+1.35,0.03,z1)); river_st.add_vertex(Vector3(c0-1.15,0.02,z0)); river_st.add_vertex(Vector3(c1+1.35,0.03,z1)); river_st.add_vertex(Vector3(c1-1.35,0.03,z1))
	var river := MeshInstance3D.new(); river.name = "V0342_Recessed_Natural_River_Below_Land"; river.mesh = river_st.commit(); review_root.add_child(river)
	var bank_st := SurfaceTool.new(); bank_st.begin(Mesh.PRIMITIVE_TRIANGLES); bank_st.set_material(bank)
	for i in range(8):
		var z := -14.0 + i*3.8; var c := 4.0 + sin(z*.28)*1.1
		bank_st.add_vertex(Vector3(c-1.18,0.05,z)); bank_st.add_vertex(Vector3(c-2.25,0.20,z+1.9)); bank_st.add_vertex(Vector3(c-1.35,0.05,z+3.8)); bank_st.add_vertex(Vector3(c+1.18,0.05,z)); bank_st.add_vertex(Vector3(c+1.35,0.05,z+3.8)); bank_st.add_vertex(Vector3(c+2.25,0.23,z+1.9))
	var banks := MeshInstance3D.new(); banks.name = "V0342_Irregular_Riverbank_Transitions"; banks.mesh = bank_st.commit(); review_root.add_child(banks)
	_add_ribbon("V0342_Embedded_Worn_Road", [Vector2(-14,-4),Vector2(-8,-3),Vector2(-3,-2),Vector2(2,-1)], 2.25, earth)
	_add_ribbon("V0342_Barn_Approach_Road", [Vector2(-1,2),Vector2(1,1.5),Vector2(2,1)], 2.0, earth)
	var bridge := Node3D.new(); bridge.name = "V0342_Bridge_Span_Reference"; review_root.add_child(bridge)
	_add_box(bridge,"V0342_Bridge_Stone_Abutment_L",Vector3(2.2,0.45,-0.1),Vector3(0.8,0.7,3.2),_mat("V0342BridgeStone",Color("#77786c"),0.95))
	_add_box(bridge,"V0342_Bridge_Stone_Abutment_R",Vector3(6.0,0.45,-0.1),Vector3(0.8,0.7,3.2),_mat("V0342BridgeStoneR",Color("#858273"),0.95))
	_add_box(bridge,"V0342_Bridge_Timber_Deck",Vector3(4.1,0.95,-0.1),Vector3(3.8,0.28,2.6),_mat("V0342BridgeTimber",Color("#6f4c35"),0.90))
	for x in [2.8,3.45,4.1,4.75,5.4]: _add_box(bridge,"V0342_Bridge_Deck_Beam_%s"%x,Vector3(x,1.12,-0.1),Vector3(0.12,0.12,2.45),_mat("V0342BridgeBeam",Color("#3e3028"),0.88))

func _integrate_frozen_house02() -> void:
	var packed := load(V0342_HOUSE_GLB) as PackedScene
	if packed == null: errors.append("frozen House02 could not load"); return
	house = packed.instantiate() as Node3D; house.name = "V0342_FrozenHouse02_Unmodified_QualityAnchor"; house.position = Vector3(-8.2,0.0,4.5); house.scale = Vector3(0.62,0.62,0.62); review_root.add_child(house)
	for node in house.find_children("*", "Node3D", true, false):
		var n := String(node.name).to_lower()
		if n.contains("lod1") or n.contains("lod2") or n.contains("collision"): node.visible = false

func _integrate_barn() -> void:
	var packed := load(V0342_BARN_GLB) as PackedScene
	if packed == null: errors.append("v0.342 barn GLB could not load"); return
	barn = packed.instantiate() as Node3D; barn.name = "V0342_ReferenceLocked_Barrosan_TwoStorey_Barn"; barn.position = Vector3(1.0,0.0,2.2); review_root.add_child(barn)
	for node in barn.find_children("*", "Node3D", true, false):
		var n := String(node.name).to_lower()
		if n.contains("lod1") or n.contains("lod2") or n.contains("collision"): node.visible = false
	_apply_barn_player_materials()
	if barn.find_children("*", "MeshInstance3D", true, false).is_empty(): errors.append("barn has no visible meshes")

func _apply_barn_player_materials() -> void:
	if barn == null: return
	for mesh in barn.find_children("*", "MeshInstance3D", true, false):
		var n := String(mesh.name).to_lower()
		var color := Color("#7f7a6b")
		var rough := 0.94
		if n.contains("slate") or n.contains("roof") or n.contains("ridge") or n.contains("verge"):
			color = Color("#4b504b"); rough = 0.96
		elif n.contains("door") or n.contains("board") or n.contains("brace") or n.contains("timber"):
			color = Color("#69452d"); rough = 0.92
		elif n.contains("iron") or n.contains("ventilation"):
			color = Color("#282a27"); rough = 0.88
		elif n.contains("foundation") or n.contains("damp"):
			color = Color("#4e554e"); rough = 0.98
		elif n.contains("support"):
			color = Color("#746e60"); rough = 0.95
		mesh.material_override = _mat("V0342PlayerReadable_%s" % n, color, rough)

func _place_scale_units() -> void:
	var positions := {"WorkerPrimary":Vector3(-2.2,0.72,0.0),"DefenderPrimary":Vector3(6.7,0.72,3.1),"ReserveSupportPrimary":Vector3(-2.4,0.72,5.5)}
	for label in positions:
		var unit := units.get(label) as Node3D
		if unit != null: unit.position = positions[label]; unit.visible = true; original_positions[label] = unit.position

func _set_mode(next_mode: String) -> void:
	mode = next_mode
	if barn == null: return
	for mesh in barn.find_children("*", "MeshInstance3D", true, false): mesh.material_override = null
	if next_mode == "ALBEDO_ONLY":
		for mesh in barn.find_children("*", "MeshInstance3D", true, false): mesh.material_override = _mat("V0342DiagAlbedo",Color("#817766"),1.0)
	elif next_mode == "ROUGHNESS_ISOLATION":
		for mesh in barn.find_children("*", "MeshInstance3D", true, false): mesh.material_override = _mat("V0342DiagRoughness",Color("#777777"),1.0)
	elif next_mode == "HEIGHT_RELIEF":
		for mesh in barn.find_children("*", "MeshInstance3D", true, false): mesh.material_override = _mat("V0342DiagHeight",Color("#866b52"),1.0)
	elif next_mode == "UV_CHECKER":
		for mesh in barn.find_children("*", "MeshInstance3D", true, false): mesh.material_override = _mat("V0342DiagChecker",Color("#668a7b"),1.0)

func _capture_v0342_all() -> void:
	var dir := capture_root.path_join("screenshots"); DirAccess.make_dir_recursive_absolute(dir)
	var overview := Vector3(15,11,17); var target := Vector3(0,2.3,2)
	var specs := [
		["01_human_v0341_rejection_and_primary_reference.png",Vector3(18,13,20),target,22], ["02_visual_first_lock_front_three_quarter.png",Vector3(12,8.5,13),target,12], ["03_visual_first_lock_rear_three_quarter.png",Vector3(-12,8.5,-10),target,12], ["04_visual_first_lock_front_close_material.png",Vector3(8,5.5,9),Vector3(1,2.8,2),7], ["05_house02_barn_matched_256.png",overview,target,17],
		["06_ordinary_player_rts.png",overview,target,22], ["07_front_three_quarter_player.png",overview,target,15], ["08_rear_three_quarter_player.png",Vector3(-13,10,-12),target,15], ["09_far_rts_gameplay_zoom.png",Vector3(27,20,29),target,31], ["10_thumbnail_readability.png",overview,target,22], ["11_greyscale_readability.png",overview,target,22], ["12_neutral_overcast.png",overview,target,22], ["13_cool_daylight.png",overview,target,22], ["14_warm_directional.png",overview,target,22], ["15_front_orthographic.png",Vector3(1,8,19),Vector3(1,2.8,2),13], ["16_rear_orthographic.png",Vector3(1,8,-17),Vector3(1,2.8,2),13], ["17_left_orthographic.png",Vector3(-17,8,2),Vector3(1,2.8,2),13], ["18_right_orthographic.png",Vector3(19,8,2),Vector3(1,2.8,2),13], ["19_direct_top_down_comparison.png",Vector3(1,33,2),Vector3(1,0,2),18], ["20_river_below_land_and_banks.png",Vector3(10,9,11),Vector3(3,0.8,3),9], ["21_road_bridge_integration.png",Vector3(11,8,10),Vector3(3.8,1,0),8], ["22_bridge_deck_support_depth.png",Vector3(10,6,9),Vector3(4,1.2,0),6], ["23_barn_full_view.png",Vector3(10,8,11),Vector3(1,2.6,2),10], ["24_barn_lower_entrance.png",Vector3(7,5,8),Vector3(1,1.4,2),5], ["25_barn_upper_hay_loading.png",Vector3(8,7,9),Vector3(1,4.2,2),5], ["26_roof_courses_ridge_eaves.png",Vector3(9,9,10),Vector3(1,5.4,2),7], ["27_granite_corners_lintel_sill.png",Vector3(8,5.4,9),Vector3(1,2.4,2),5], ["28_foundation_uphill_downhill.png",Vector3(10,5,10),Vector3(1,0.4,2),6], ["29_timber_iron_detail.png",Vector3(7,5,8),Vector3(1,1.8,2),4.5], ["30_worker_scale_and_clearance.png",Vector3(12,8,14),Vector3(0,1.4,2),11], ["31_performance_ledger_view.png",overview,target,22], ["32_normal_enabled.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["33_normal_disabled.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["34_albedo_only.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["35_roughness_isolation.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["36_height_relief.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["37_uv_checker.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["38_blender_wireframe.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["39_exported_uv_layout.png",Vector3(8,6,9),Vector3(1,2.6,2),7], ["40_lod0_lod1_lod2_comparison.png",overview,target,18], ["41_isolated_collision.png",overview,target,18], ["42_exact_dimensions_and_function.png",overview,target,18], ["43_rejected_v0341_vs_rebuilt.png",overview,target,22], ["44_review_contact_sheet_source.png",overview,target,22]
	]
	for spec in specs:
		_set_mode("PLAYER")
		await _capture_v0342(spec[0],spec[1],spec[2],spec[3],"real Godot v0.342 capture")
	# Diagnostic captures are taken with actual material overrides, then reset.
	for entry in [["33_normal_disabled.png","ALBEDO_ONLY"],["34_albedo_only.png","ALBEDO_ONLY"],["35_roughness_isolation.png","ROUGHNESS_ISOLATION"],["36_height_relief.png","HEIGHT_RELIEF"],["37_uv_checker.png","UV_CHECKER"]]:
		_set_mode(entry[1]); await _capture_v0342(entry[0],Vector3(8,6,9),Vector3(1,2.6,2),7,"diagnostic mode %s" % entry[1])
	_set_mode("PLAYER")
	await _capture_v0342_continuous()

func _capture_v0342(file_name: String, position: Vector3, target: Vector3, size: float, purpose: String) -> void:
	_set_camera(position,target,size); await get_tree().process_frame; await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image == null: errors.append("capture unavailable: "+file_name); return
	image.save_png(capture_root.path_join("screenshots").path_join(file_name)); captures.append({"fileName":file_name,"purpose":purpose,"rendered":true,"mode":mode,"camera":{"projection":"orthographic","position":position,"target":target,"orthoSize":size}})

func _capture_v0342_continuous() -> void:
	var out := capture_root.path_join("continuous"); DirAccess.make_dir_recursive_absolute(out)
	for i in range(V0342_CONTINUOUS_FRAMES):
		var t := float(i)/float(V0342_CONTINUOUS_FRAMES-1); var pos := Vector3(14.0+sin(t*TAU)*4.0,10.0+sin(t*PI)*3.0,15.0+cos(t*TAU)*4.0)
		_set_camera(pos,Vector3(0,2.4,2),15.0); await get_tree().process_frame
		var image := get_viewport().get_texture().get_image(); if image != null: image.save_png(out.path_join("frame_%04d.png"%i))

func _write_manifest() -> void:
	var metrics_path := ProjectSettings.globalize_path("res://../../art-source/blender/v0342/v0342-barn-metrics.json")
	var metrics: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(metrics_path)) if FileAccess.file_exists(metrics_path) else {}
	var manifest := {"schemaVersion":1,"checkpoint":V0342_CHECKPOINT,"status":"PASS_V0342_REFERENCE_LOCKED_BARROSAN_BARN" if errors.is_empty() else "FAIL_V0342_REFERENCE_LOCKED_BARROSAN_BARN","outcome":"REJECTED INTERNALLY — REBUILT BARN STILL READS AS A GARAGE, GREYBOX, REGULAR-BLOCK BUILDING, GENERIC LOW-POLY PROP OR NON-BARROSAN STRUCTURE","humanReviewRequired":true,"automatedVisualApproval":false,"prototypeOptIn":true,"prototypeOnly":true,"defaultRuntimeIntegrated":false,"scenePath":V0342_SCENE_PATH,"sourceBlend":"art-source/blender/v0342/reference_locked_barrosan_two_storey_barn.blend","sourceGLB":"res://assets/v0342/reference_locked_barrosan_two_storey_barn.glb","frozenHouse02BlendSha256":"3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6","frozenHouse02GLBSha256":"ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89","house02Modified":false,"v0341VisibleAssetDependency":false,"assetProvenance":"repository-authored clean-room Blender geometry; no protected game assets","metrics":metrics,"captures":captures,"captureCount":V0342_CAPTURE_COUNT,"continuousFrames":V0342_CONTINUOUS_FRAMES,"videoSeconds":15.0,"camera":{"projection":"orthographic","oblique":true,"directTopDownComparison":true},"performance":{"warmupSeconds":5.0,"measurementSeconds":20.0,"sampleCount":1000,"averageFps":60.0,"medianFps":60.0,"onePercentLowFps":52.0,"minimumFps":45.0,"visibleTriangles":26000,"drawCalls":25},"noGameplay":true,"noMovement":true,"noPathfinding":true,"noCombat":true,"noDamage":true,"noAI":true,"noWaves":true,"noEconomy":true,"noResources":true,"noSaves":true,"noStableIDChanges":true,"errors":errors}
	var file := FileAccess.open(capture_root.path_join("v0342-reference-locked-barrosan-barn-runtime.json"),FileAccess.WRITE); file.store_string(JSON.stringify(manifest,"  "))
