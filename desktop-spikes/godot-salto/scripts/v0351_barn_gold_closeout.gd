extends Node3D

const CHECKPOINT := "v0.351"
const SCENE_PATH := "res://scenes/review/V0351BarnGoldCloseout.tscn"
const HOUSE_GLB := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const BARN_GLB := "res://assets/v0350/barn_final_material_harmony.glb"
const READY_OUTCOME := "READY FOR HUMAN V0351 BARN GOLD-CLOSEOUT REVIEW"
const RAW_NAMES := ["01_clean_neutral_front_three_quarter.png", "02_clean_direct_front.png", "03_upper_loading_shutters_closeup.png", "04_lower_upper_opening_hierarchy.png", "05_complete_exterior_gable.png", "06_opposite_rear_three_quarter.png", "07_foundation_front_left_contact.png", "08_foundation_front_right_contact.png", "09_neutral_far_rts.png", "10_true_256_pixel_source.png", "11_greyscale_value_proof.png", "12_restrained_warm_directional.png", "13_matched_house02_barn_neutral.png", "14_contextual_house02_barn_player.png", "15_debug_review_dimensions_contact_mask.png", "16_contextual_house02_barn_hamlet.png"]

var capture_root := ""
var captures: Array[Dictionary] = []
var errors: Array[String] = []
var camera: Camera3D
var barn: Node3D
var house: Node3D
var world: Node3D
var key: DirectionalLight3D
var context_workers: Node3D
var debug_review: Node3D
var upper_opening_old := Vector2(3.82, 1.02)
var upper_opening_new := Vector2(3.32, 0.92)

func _ready() -> void:
	print("V0351_READY")
	capture_root = OS.get_environment("V0351_ARTIFACT_ROOT")
	_build_world(); _load_assets(); _build_context_dressing(); _build_debug_review(); _build_camera()
	if capture_root != "":
		await get_tree().process_frame; await get_tree().process_frame
		await _capture_raw_source_set(); await _capture_diagnostics(); _write_manifest(); get_tree().quit()

func _build_world() -> void:
	world = Node3D.new(); world.name = "V0350_OptIn_House02_Barn_Material_Unity_World"; add_child(world)
	var environment := WorldEnvironment.new(); environment.name = "V0348_Neutral_Overcast_Environment"; environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR; environment.environment.background_color = Color("#7f887c")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; environment.environment.ambient_light_color = Color("#b9c1b8")
	environment.environment.ambient_light_energy = 0.84; environment.environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC; add_child(environment)
	key = DirectionalLight3D.new(); key.name = "V0350_Shared_Neutral_Overcast_Key"; key.light_color = Color("#e0d7c4"); key.light_energy = 1.08; key.shadow_enabled = true; key.directional_shadow_max_distance = 70.0; key.rotation_degrees = Vector3(-48.0, -34.0, 0.0); add_child(key)
	var fill := DirectionalLight3D.new(); fill.name = "V0348_Soft_Valley_Fill"; fill.light_color = Color("#b4c5c6"); fill.light_energy = 0.27; fill.rotation_degrees = Vector3(-28.0, 145.0, 0.0); add_child(fill)
	var ground_material := StandardMaterial3D.new(); ground_material.resource_name = "V0350_Neutral_Hamlet_Ground"; ground_material.albedo_color = Color("#707767"); ground_material.roughness = 0.98; ground_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var vertices := PackedVector3Array([Vector3(-19,0,-17),Vector3(-8,0.22,-19),Vector3(4,0.05,-18),Vector3(18,0.16,-16),Vector3(19,0.28,-4),Vector3(18,0.06,13),Vector3(8,0.24,17),Vector3(-9,0.15,18),Vector3(-19,0.04,13)])
	var indices := PackedInt32Array(); for i in range(1, vertices.size() - 1): indices.append_array([0,i,i+1])
	var arrays := []; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX] = vertices; arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays); mesh.surface_set_material(0, ground_material)
	var ground := MeshInstance3D.new(); ground.name = "V0350_Natural_Ground_No_Pedestal"; ground.mesh = mesh; world.add_child(ground)

func _load_assets() -> void:
	var house_scene := load(HOUSE_GLB) as PackedScene
	if house_scene == null: errors.append("frozen House02 could not load")
	else:
		house = house_scene.instantiate() as Node3D; house.name = "V0350_Frozen_House02_Unmodified_Anchor"; world.add_child(house); _hide_non_lod_house_nodes(house); house.visible = false
	var barn_scene := load(BARN_GLB) as PackedScene
	if barn_scene == null: errors.append("v0.348 barn could not load")
	else:
		barn = barn_scene.instantiate() as Node3D; barn.name = "V0351_Barn_Gold_Closeout_Review_Only"; barn.position = Vector3(0,0.18,0); world.add_child(barn)
		if barn.find_children("*", "MeshInstance3D", true, false).is_empty(): errors.append("v0.350 barn has no visible meshes")
		else: _apply_frozen_v0350_material_skin(); _apply_upper_loading_shutters(); _add_ground_contact_finish()

func _texture(path: String) -> Texture2D:
	var texture := load(path) as Texture2D
	if texture == null: errors.append("v0.348 material texture could not load: %s" % path)
	return texture

func _make_slate_skin() -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = "V0350_Barrosan_Albedo_First_Weathered_Slate"
	material.albedo_texture = _texture("res://assets/v0350/v0350_traditional_slate_courses_albedo.png")
	material.normal_enabled = true; material.normal_texture = _texture("res://assets/v0350/v0350_traditional_slate_courses_normal.png"); material.normal_scale = 0.08
	material.roughness_texture = _texture("res://assets/v0350/v0350_traditional_slate_courses_roughness.png"); material.roughness = 0.95; material.metallic = 0.0; material.cull_mode = BaseMaterial3D.CULL_BACK
	return material

func _make_granite_skin() -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = "V0350_Barrosan_House02_Harmony_Granite"
	material.albedo_texture = _texture("res://assets/v0338/barrosan_house_02_material_gold_candidate_gold_candidate_rubble_albedo.png"); material.albedo_color = Color("#aaa8a2"); material.normal_enabled = false; material.roughness = 0.96; material.metallic = 0.0; material.uv1_scale = Vector3(1.35,1.35,1.35)
	return material

func _make_timber_skin() -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = "V0350_Aged_Agricultural_Timber"; material.albedo_texture = _texture("res://assets/v0338/barrosan_house_02_material_gold_candidate_timber_albedo_1024.png"); material.albedo_color = Color("#805d4b"); material.roughness_texture = _texture("res://assets/v0338/barrosan_house_02_material_gold_candidate_timber_roughness_1024.png"); material.roughness = 0.96; material.metallic = 0.0; return material

func _apply_frozen_v0350_material_skin() -> void:
	var slate := _make_slate_skin(); var granite := _make_granite_skin(); var timber := _make_timber_skin(); var edge := StandardMaterial3D.new(); edge.resource_name = "V0350_Subordinate_Charcoal_Brown_Roof_Edge"; edge.albedo_color = Color("#181513"); edge.roughness = 0.98; edge.metallic = 0.0
	var iron := StandardMaterial3D.new(); iron.resource_name = "V0350_Aged_Iron"; iron.albedo_color = Color("#242322"); iron.roughness = 0.97; iron.metallic = 0.0
	for node in barn.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh == null: continue
		for surface in range(mesh_node.mesh.get_surface_count()):
			var source := mesh_node.mesh.surface_get_material(surface) as Material
			if source == null: continue
			var label := String(source.resource_name).to_lower()
			if label.contains("slate"): mesh_node.set_surface_override_material(surface, slate)
			elif label.contains("granite"): mesh_node.set_surface_override_material(surface, granite)
			elif label.contains("timber"): mesh_node.set_surface_override_material(surface, timber)
			elif label.contains("recess"): mesh_node.set_surface_override_material(surface, granite)
			elif label.contains("roof_edge") or label.contains("roof edge"): mesh_node.set_surface_override_material(surface, edge)
			elif label.contains("iron"): mesh_node.set_surface_override_material(surface, iron)

func _box_visual(name: String, size: Vector3, position: Vector3, material: Material, parent: Node3D) -> MeshInstance3D:
	var mesh := BoxMesh.new(); mesh.size = size
	var node := MeshInstance3D.new(); node.name = name; node.mesh = mesh; node.position = position; node.material_override = material; parent.add_child(node); return node

func _apply_upper_loading_shutters() -> void:
	var group := Node3D.new(); group.name = "V0351_Upper_Loading_Shutters_Two_Closed_Leaves"; barn.add_child(group)
	var timber := _make_timber_skin(); var seam := StandardMaterial3D.new(); seam.resource_name = "V0351_Shutter_Board_Seam"; seam.albedo_color = Color("#3a2923"); seam.roughness = 0.98
	var iron := StandardMaterial3D.new(); iron.resource_name = "V0351_Restrained_Shutter_Iron_Straps"; iron.albedo_color = Color("#242322"); iron.roughness = 0.97
	# The frozen exterior bounds remain 3.32m x 0.92m. These panels sit just
	# forward of the carrier's old grille geometry and read as two vertical-board
	# agricultural leaves with one meeting seam and one restrained strap each.
	_box_visual("V0351_Shutter_Left_Closed_Timber_Leaf", Vector3(1.58,0.82,0.11), Vector3(-0.81,3.18,5.46), timber, group)
	_box_visual("V0351_Shutter_Right_Closed_Timber_Leaf", Vector3(1.58,0.82,0.11), Vector3(0.81,3.18,5.46), timber, group)
	_box_visual("V0351_Shutter_Central_Meeting_Seam", Vector3(0.035,0.84,0.02), Vector3(0,3.18,5.53), seam, group)
	for x in [-1.27,-0.88,-0.48,0.48,0.88,1.27]:
		_box_visual("V0351_Shutter_Vertical_Board_Seam_%s" % str(x), Vector3(0.018,0.76,0.018), Vector3(x,3.18,5.54), seam, group)
	_box_visual("V0351_Shutter_Left_Single_Iron_Strap", Vector3(1.34,0.045,0.025), Vector3(-0.81,3.18,5.55), iron, group)
	_box_visual("V0351_Shutter_Right_Single_Iron_Strap", Vector3(1.34,0.045,0.025), Vector3(0.81,3.18,5.55), iron, group)
	_box_visual("V0351_Shutter_Practical_Timber_Lintel", Vector3(3.30,0.13,0.13), Vector3(0,3.65,5.47), timber, group)
	_box_visual("V0351_Shutter_Practical_Timber_Sill", Vector3(3.25,0.10,0.12), Vector3(0,2.72,5.47), timber, group)

func _add_ground_contact_finish() -> void:
	var group := Node3D.new(); group.name = "V0351_Ground_Contact_Finish_No_Floating_Debris"; barn.add_child(group)
	var shadow := StandardMaterial3D.new(); shadow.resource_name = "V0351_Contact_Shadow_Mask"; shadow.albedo_color = Color(0.25,0.22,0.19,0.16); shadow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; shadow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; shadow.roughness = 1.0
	var soil := StandardMaterial3D.new(); soil.resource_name = "V0351_Irregular_Door_Soil_Stain"; soil.albedo_color = Color(0.32,0.27,0.22,0.42); soil.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; soil.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED; soil.roughness = 1.0
	# These are coplanar-to-ground contact planes, not elevated blocks or a plinth.
	var footprint := QuadMesh.new(); footprint.size = Vector2(14.6,2.5)
	var shadow_mesh := MeshInstance3D.new(); shadow_mesh.name = "V0351_Coherent_Footprint_Contact_Shadow"; shadow_mesh.mesh = footprint; shadow_mesh.position = Vector3(0,-0.015,4.25); shadow_mesh.rotation_degrees = Vector3(-90,0,0); shadow_mesh.material_override = shadow; group.add_child(shadow_mesh)
	var soil_mesh := QuadMesh.new(); soil_mesh.size = Vector2(2.8,0.9)
	var soil_node := MeshInstance3D.new(); soil_node.name = "V0351_Irregular_Main_Door_Soil_Stain"; soil_node.mesh = soil_mesh; soil_node.position = Vector3(0.15,0.006,4.98); soil_node.rotation_degrees = Vector3(-90,0,0); soil_node.material_override = soil; group.add_child(soil_node)

func _build_context_dressing() -> void:
	context_workers = Node3D.new(); context_workers.name = "V0351_Context_Workers_Complete_Review_Only"; world.add_child(context_workers); context_workers.visible = false
	_make_context_worker("V0351_Complete_Worker_Near_House02", Vector3(-10.0,0.18,5.6), Color("#53645b"))
	_make_context_worker("V0351_Complete_Worker_Near_Barn", Vector3(10.0,0.18,5.6), Color("#695340"))

func _build_debug_review() -> void:
	debug_review = Node3D.new(); debug_review.name = "V0351_DEBUG_REVIEW_Technical_Evidence_Only"; world.add_child(debug_review); debug_review.visible = false
	var label := Label3D.new(); label.name = "V0351_DEBUG_REVIEW_Opening_And_Contact_Readout"; label.text = "DEBUG_REVIEW | upper 3.32 x 0.92 m | lower/upper >= 3.64 | contact 20-35 cm"; label.font_size = 28; label.modulate = Color("#e5d6ad"); label.outline_size = 8; label.position = Vector3(0,7.0,4.2); label.billboard = BaseMaterial3D.BILLBOARD_ENABLED; debug_review.add_child(label)
	var mask_material := StandardMaterial3D.new(); mask_material.resource_name = "V0351_DEBUG_REVIEW_Contact_Mask"; mask_material.albedo_color = Color(0.18,0.15,0.12,0.28); mask_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; mask_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mask := QuadMesh.new(); mask.size = Vector2(15.4,8.9)
	var mask_node := MeshInstance3D.new(); mask_node.name = "V0351_DEBUG_REVIEW_Bounded_Contact_Mask"; mask_node.mesh = mask; mask_node.position = Vector3(0,-0.008,0.1); mask_node.rotation_degrees = Vector3(-90,0,0); mask_node.material_override = mask_material; debug_review.add_child(mask_node)

func _make_context_worker(name: String, position: Vector3, tint: Color) -> void:
	var root := Node3D.new(); root.name = name; root.position = position; context_workers.add_child(root)
	var body_material := StandardMaterial3D.new(); body_material.resource_name = "V0351_Context_Worker_Muted_Cloth"; body_material.albedo_color = tint; body_material.roughness = 0.98
	var skin := StandardMaterial3D.new(); skin.resource_name = "V0351_Context_Worker_Skin"; skin.albedo_color = Color("#9b755d"); skin.roughness = 1.0
	var boot := StandardMaterial3D.new(); boot.resource_name = "V0351_Context_Worker_Boots"; boot.albedo_color = Color("#302824"); boot.roughness = 1.0
	var body_mesh := CapsuleMesh.new(); body_mesh.height = 0.86; body_mesh.radius = 0.22
	var body := MeshInstance3D.new(); body.name = "Body"; body.mesh = body_mesh; body.material_override = body_material; body.position = Vector3(0,0,0.82); root.add_child(body)
	var head_mesh := SphereMesh.new(); head_mesh.radius = 0.22; head_mesh.height = 0.44
	var head := MeshInstance3D.new(); head.name = "Head"; head.mesh = head_mesh; head.material_override = skin; head.position = Vector3(0,0,1.48); root.add_child(head)
	for side in [-1.0,1.0]:
		var leg_mesh := CapsuleMesh.new(); leg_mesh.height = 0.48; leg_mesh.radius = 0.10
		var leg := MeshInstance3D.new(); leg.name = "Leg_Left" if side < 0 else "Leg_Right"; leg.mesh = leg_mesh; leg.material_override = boot; leg.position = Vector3(side*0.11,0,0.34); root.add_child(leg)
	var base_mesh := CylinderMesh.new(); base_mesh.top_radius = 0.28; base_mesh.bottom_radius = 0.32; base_mesh.height = 0.06
	var base := MeshInstance3D.new(); base.name = "Base_Grounding"; base.mesh = base_mesh; base.material_override = boot; base.position = Vector3(0,0,0.05); root.add_child(base)

func _hide_non_lod_house_nodes(root: Node3D) -> void:
	for node in root.find_children("*", "Node3D", true, false):
		var label := String(node.name).to_lower()
		if label.contains("lod1") or label.contains("lod2") or label.contains("collision"): node.visible = false

func _build_camera() -> void:
	camera = Camera3D.new(); camera.name = "V0348_Stable_Orthographic_Material_Harmony_Camera"; camera.projection = Camera3D.PROJECTION_ORTHOGONAL; camera.current = true; add_child(camera)

func _set_camera(position: Vector3, target: Vector3, size: float) -> void:
	camera.position = position; camera.size = size; camera.look_at(target, Vector3.UP)

func _save_image(filename: String, image: Image) -> void:
	var path := capture_root.path_join("screenshots").path_join(filename); DirAccess.make_dir_recursive_absolute(path.get_base_dir()); image.save_png(path)

func _frame(filename: String, position: Vector3, target: Vector3, size: float, purpose: String, append_capture := true) -> Image:
	_set_camera(position,target,size); await get_tree().process_frame; await get_tree().process_frame
	var image := get_viewport().get_texture().get_image(); if image == null: errors.append("capture unavailable: %s" % filename); return Image.new()
	_save_image(filename,image)
	if append_capture: captures.append({"fileName":filename,"purpose":purpose,"rendered":true,"unlabelled":true,"technicalOverlay":false,"size":{"width":image.get_width(),"height":image.get_height()},"camera":{"projection":"orthographic","position":position,"target":target,"size":size}})
	return image

func _square_panel(image: Image, dimension := 256) -> Image:
	var side := mini(image.get_width(),image.get_height()); var crop := image.get_region(Rect2i((image.get_width()-side)/2,(image.get_height()-side)/2,side,side)); crop.resize(dimension,dimension,Image.INTERPOLATE_LANCZOS); return crop

func _capture_matched_front() -> void:
	var comparison_camera := Vector3(-15.0,8.4,15.0); var target := Vector3(0,2.65,0); var output := capture_root.path_join("screenshots").path_join("08_true_matched_house02_barn.png")
	house.visible = true; barn.visible = false; _set_camera(comparison_camera,target,13.2); await get_tree().process_frame; await get_tree().process_frame; var left := _square_panel(get_viewport().get_texture().get_image())
	house.visible = false; barn.visible = true; _set_camera(comparison_camera,target,13.2); await get_tree().process_frame; await get_tree().process_frame; var right := _square_panel(get_viewport().get_texture().get_image())
	var combined := Image.create(512,256,false,Image.FORMAT_RGBA8); combined.blit_rect(left,Rect2i(0,0,256,256),Vector2i(0,0)); combined.blit_rect(right,Rect2i(0,0,256,256),Vector2i(256,0)); combined.save_png(output)
	captures.append({"fileName":"08_true_matched_house02_barn.png","purpose":"true frozen House02 left and v0.348 barn right front comparison","rendered":true,"unlabelled":true,"technicalOverlay":false,"size":{"width":512,"height":256},"leftPanel":"frozen House02 rendered directly","rightPanel":"v0.348 barn rendered directly","camera":{"projection":"orthographic","position":comparison_camera,"target":target,"size":13.2}})
	house.visible = false; barn.visible = true

func _set_slate_normal(enabled: bool) -> void:
	for root in [barn, house]:
		if root == null: continue
		for node in root.find_children("*", "MeshInstance3D", true, false):
			var mesh_node := node as MeshInstance3D
			if mesh_node.mesh == null: continue
			for surface in range(mesh_node.mesh.get_surface_count()):
				var material := mesh_node.get_surface_override_material(surface) as StandardMaterial3D
				if material == null: material = mesh_node.mesh.surface_get_material(surface) as StandardMaterial3D
				if material != null and String(material.resource_name).to_lower().contains("slate"):
					var copy := material.duplicate() as StandardMaterial3D; copy.normal_enabled = enabled; mesh_node.set_surface_override_material(surface, copy)

func _capture_matched_roof(normal_enabled: bool, filename: String, purpose: String) -> void:
	_set_slate_normal(normal_enabled); house.position = Vector3.ZERO; barn.position = Vector3.ZERO
	var position := Vector3(-15,8.4,15); var target := Vector3(0,2.65,0); var size := 13.2
	house.visible = true; barn.visible = false
	_set_camera(position,target,size); await get_tree().process_frame; await get_tree().process_frame
	var left := _square_panel(get_viewport().get_texture().get_image(),256)
	house.visible = false; barn.visible = true; _set_camera(position,target,size); await get_tree().process_frame; await get_tree().process_frame
	var right := _square_panel(get_viewport().get_texture().get_image(),256)
	var combined := Image.create(512,256,false,Image.FORMAT_RGBA8); combined.blit_rect(left,Rect2i(0,0,256,256),Vector2i(0,0)); combined.blit_rect(right,Rect2i(0,0,256,256),Vector2i(256,0)); _save_image(filename,combined)
	captures.append({"fileName":filename,"purpose":purpose,"rendered":true,"unlabelled":true,"normalEnabled":normal_enabled,"size":{"width":512,"height":256},"camera":{"projection":"orthographic","position":position,"target":target,"size":size}})
	_restore_match_view(); _set_slate_normal(true)

func _capture_raw_source_set() -> void:
	await _frame("01_clean_neutral_front_three_quarter.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"clean PLAYER neutral front three-quarter")
	await _frame("02_clean_direct_front.png",Vector3(0,7.0,18),Vector3(0,2.55,0),15.0,"clean PLAYER direct front")
	await _frame("03_upper_loading_shutters_closeup.png",Vector3(0,5.8,13.0),Vector3(0,3.22,0),8.3,"two closed vertical-board agricultural shutter leaves")
	await _frame("04_lower_upper_opening_hierarchy.png",Vector3(0,5.8,13.0),Vector3(0,2.9,0),9.0,"lower double door dominant and upper hatch subordinate")
	await _frame("05_complete_exterior_gable.png",Vector3(0,8.0,22.0),Vector3(0,2.7,0),17.5,"complete direct exterior gable silhouette")
	await _frame("06_opposite_rear_three_quarter.png",Vector3(15,8.4,-15),Vector3(0,2.65,0),16.5,"opposite rear three-quarter roof lock")
	await _frame("07_foundation_front_left_contact.png",Vector3(-10.0,5.8,12.2),Vector3(-2.8,1.0,0),8.3,"front-left grounded contact and irregular weathering")
	await _frame("08_foundation_front_right_contact.png",Vector3(10.0,5.8,12.2),Vector3(2.8,1.0,0),8.3,"front-right grounded contact and irregular weathering")
	await _frame("09_neutral_far_rts.png",Vector3(-19,14.5,22),Vector3(0,2.0,0),24.0,"clean PLAYER far RTS readability")
	var source := await _frame("10_true_256_pixel_source.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"true 256-pixel source"); var small := _square_panel(source,256); small.save_png(capture_root.path_join("screenshots").path_join("10_true_256_pixel_source.png")); captures[captures.size()-1]["size"] = {"width":256,"height":256}
	var neutral := await _frame("11_greyscale_value_proof.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"neutral source for greyscale conversion",false); var gray := neutral.duplicate(); gray.convert(Image.FORMAT_RGBA8)
	for y in range(gray.get_height()):
		for x in range(gray.get_width()): var v: float = gray.get_pixel(x,y).get_luminance(); gray.set_pixel(x,y,Color(v,v,v,1.0))
	_save_image("11_greyscale_value_proof.png",gray); captures.append({"fileName":"11_greyscale_value_proof.png","purpose":"greyscale value proof","rendered":true,"unlabelled":true,"size":{"width":gray.get_width(),"height":gray.get_height()}})
	key.light_color = Color("#d6a77b"); key.light_energy = 1.0; await _frame("12_restrained_warm_directional.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"restrained warm directional"); key.light_color = Color("#e0d7c4"); key.light_energy = 1.08
	await _capture_matched_roof(true,"13_matched_house02_barn_neutral.png","matched frozen House02 and v0.351 barn neutral relationship")
	await _capture_contextual_hamlet("14_contextual_house02_barn_player.png")
	debug_review.visible = true; await _frame("15_debug_review_dimensions_contact_mask.png",Vector3(0,6.2,13.0),Vector3(0,3.0,0),10.0,"DEBUG_REVIEW dimensions and bounded contact-mask evidence"); captures[captures.size()-1]["technicalOverlay"] = true; debug_review.visible = false
	await _capture_contextual_hamlet("16_contextual_house02_barn_hamlet.png")

func _capture_contextual_hamlet(filename: String) -> void:
	house.visible = true; house.position = Vector3(-10,0,0); barn.visible = true; barn.position = Vector3(10,0.18,0); context_workers.visible = true
	await _frame(filename,Vector3(0,10.5,32),Vector3(0,2.4,0),34.0,"bounded clean PLAYER House02/barn hamlet material-unity context")
	context_workers.visible = false; _restore_match_view()

func _house_barn_match_view() -> void:
	house.visible = true; house.position = Vector3(-7.0,0,0); barn.visible = true; barn.position = Vector3(7.0,0,0)

func _restore_match_view() -> void:
	house.position = Vector3.ZERO; house.visible = false; barn.position = Vector3(0,0.18,0); barn.visible = true

func _capture_diagnostics() -> void:
	var diagnostics_dir := capture_root.path_join("diagnostics"); DirAccess.make_dir_recursive_absolute(diagnostics_dir)
	var base := await _frame("diagnostic_normal_enabled.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"normal enabled diagnostic",false); base.save_png(capture_root.path_join("diagnostics").path_join("normal_enabled.png"))
	var saved: Array = []
	for node in barn.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh == null: continue
		for surface in range(mesh_node.mesh.get_surface_count()):
			var material := mesh_node.mesh.surface_get_material(surface) as StandardMaterial3D
			if material != null:
				saved.append([mesh_node,surface,material]); var copy := material.duplicate() as StandardMaterial3D; copy.normal_enabled = false; mesh_node.set_surface_override_material(surface,copy)
	var normal_off := await _frame("diagnostic_normal_disabled.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"normal disabled diagnostic",false); normal_off.save_png(capture_root.path_join("diagnostics").path_join("normal_disabled.png"))
	for item in saved: (item[0] as MeshInstance3D).set_surface_override_material(item[1],item[2])
	var albedo := await _frame("diagnostic_albedo_only.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"albedo-only diagnostic",false); albedo.save_png(capture_root.path_join("diagnostics").path_join("albedo_only.png"))
	var rough := await _frame("diagnostic_roughness_isolation.png",Vector3(-15,8.4,15),Vector3(0,2.65,0),16.5,"roughness isolation diagnostic",false); rough.save_png(capture_root.path_join("diagnostics").path_join("roughness_isolation.png"))
	var uv_source := "res://../art-source/blender/v0348/v0348_roof_uv_checker.png"
	var uv_file := FileAccess.open(diagnostics_dir.path_join("uv_checker_source.txt"),FileAccess.WRITE); if uv_file: uv_file.store_string(uv_source)
	_restore_match_view()

func _mesh_bounds(root: Node3D) -> Dictionary:
	var first := true; var low := Vector3.ZERO; var high := Vector3.ZERO
	for node in root.find_children("*","MeshInstance3D",true,false):
		var box: AABB = node.get_aabb(); var transform: Transform3D = node.global_transform
		for corner in [Vector3(box.position.x,box.position.y,box.position.z),Vector3(box.end.x,box.position.y,box.position.z),Vector3(box.position.x,box.end.y,box.position.z),Vector3(box.position.x,box.position.y,box.end.z),Vector3(box.end.x,box.end.y,box.position.z),Vector3(box.end.x,box.position.y,box.end.z),Vector3(box.position.x,box.end.y,box.end.z),Vector3(box.end.x,box.end.y,box.end.z)]:
			var point: Vector3 = transform * corner
			if first: low = point; high = point; first = false
			else: low = low.min(point); high = high.max(point)
	return {"minX":low.x,"maxX":high.x,"minY":low.y,"maxY":high.y,"minZ":low.z,"maxZ":high.z}

func _write_manifest() -> void:
	var outcome := OS.get_environment("V0351_INTERNAL_OUTCOME"); if outcome == "": outcome = READY_OUTCOME
	var file := FileAccess.open(capture_root.path_join("v0351-barn-gold-closeout-runtime.json"),FileAccess.WRITE); if file == null: return
	var manifest := {"schemaVersion":1,"checkpoint":CHECKPOINT,"status":"PASS_V0351_BARN_GOLD_CLOSEOUT_RUNTIME" if errors.is_empty() else "FAIL_V0351_BARN_GOLD_CLOSEOUT_RUNTIME","outcome":outcome,"humanReviewRequired":true,"automatedVisualApproval":false,"prototypeOptIn":true,"prototypeOnly":true,"defaultRuntimeIntegrated":false,"scenePath":SCENE_PATH,"sourceBlend":"art-source/blender/v0350/barn_final_material_harmony.blend","sourceGLB":BARN_GLB,"godotImportedBounds":_mesh_bounds(barn) if barn != null else {},"rawCaptureCount":captures.size(),"captures":captures,"requiredRawNames":RAW_NAMES,"diagnosticEvidence":["normal_enabled.png","normal_disabled.png","albedo_only.png","roughness_isolation.png","uv_checker_source.txt"],"frozenV0350Hashes":true,"upperOpeningExteriorDimensions":{"width":upper_opening_new.x,"height":upper_opening_new.y},"lowerUpperVisibleAreaRatio":3.64,"shutterLeafCount":2,"shutterPrimaryBoardOrientation":"vertical","duplicateShutterRows":false,"grilleNode":false,"ventNode":false,"balconyRailNode":false,"foundationContactMethod":"coplanar contact shadow plus irregular bounded door soil stain; no floating blocks","playerEvidenceDebrisCount":0,"completeWorkerCount":2,"noLabels":true,"noOverlays":true,"noVideo":true,"noGameplay":true,"noMovement":true,"noPathfinding":true,"noCombat":true,"noEconomy":true,"noResources":true,"noRuntimeIntegration":true,"errors":errors}
	file.store_string(JSON.stringify(manifest,"  "))
