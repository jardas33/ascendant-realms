extends "res://scripts/v0425_secondary_barn_eave_edge_value_hierarchy.gd"

## v0.426 restrains only the existing secondary-barn contact-shadow material.
## The v0.399 footprint and all later accepted geometry/material groups remain fixed.

const V0426_CHECKPOINT := "v0.426"
const V0426_CAPTURE_ROOT := "artifacts/runtime/v0426"
const V0426_LIMITATION := "ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_CONTACT_SHADOW"
const V0426_BASELINE := "a98e9abe41de5d8e52097343ab49bf5542133909"
const V0426_BARN_ROOT := "V0399_Barn_Structural_Readability"
const V0426_SHADOW := "V0399_Barn_Contact_Shadow"
const V0426_STONE_BASE := "V0399_Barn_Stone_Base"

var v0426_capture_mode := false
var v0426_smoke_mode := false
var v0426_nodes: Array[MeshInstance3D] = []
var v0426_inventory: Array = []
var v0426_excluded_inventory: Array = []
var v0426_unexpected: Array[String] = []
var v0426_before_materials: Dictionary = {}
var v0426_after_materials: Dictionary = {}
var v0426_before_snapshots: Dictionary = {}
var v0426_after_snapshots: Dictionary = {}
var v0426_original_state: Dictionary = {}
var v0426_final_state: Dictionary = {}
var v0426_audit: Dictionary = {}

func _read_v0409_args() -> void:
	super._read_v0409_args()
	v0426_capture_mode = false
	v0426_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0426-secondary-barn-contact-shadow-capture":
			v0426_capture_mode = true
		if arg == "--v0426-secondary-barn-contact-shadow-smoke":
			v0426_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root:
		v0388_capture_root = V0426_CAPTURE_ROOT
	v0425_capture_mode = false
	v0425_smoke_mode = false
	v0424_capture_mode = false
	v0424_smoke_mode = false
	v0409_capture_mode = v0426_capture_mode
	v0409_smoke_mode = v0426_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	super._v0409_apply_existing_material_treatment()
	_v0426_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0426_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0426_write_audit(root)
	var file := FileAccess.open(root.path_join("v0426-secondary-barn-contact-shadow-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0426_CHECKPOINT, "status": v0426_audit.get("status", V0426_LIMITATION), "candidateRetained": v0426_audit.get("candidateRetained", false), "materialOnly": true, "geometryChanged": false, "footprintChanged": false, "lightingChanged": false, "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)

func _v0426_apply_existing_material_treatment() -> void:
	v0426_nodes.clear()
	v0426_inventory.clear()
	v0426_excluded_inventory.clear()
	v0426_unexpected.clear()
	v0426_before_materials.clear()
	v0426_after_materials.clear()
	v0426_before_snapshots.clear()
	v0426_after_snapshots.clear()
	v0426_original_state.clear()
	v0426_final_state.clear()
	var barn := v0383_world.find_child(V0426_BARN_ROOT, true, false) as Node3D if v0383_world else null
	if barn == null:
		_v0426_fail_closed("accepted secondary-barn root missing")
		return
	var found_shadow := false
	for candidate in barn.find_children("*", "MeshInstance3D", true, false):
		var node := candidate as MeshInstance3D
		var key := str(node.name)
		var material_name := _v0414_material_name(node.material_override)
		var mesh_name := str(node.mesh.resource_name) if node.mesh else ""
		var value := (key + " " + material_name + " " + mesh_name).to_lower()
		var entry := {"name": key, "visible": node.visible, "material": material_name, "mesh": mesh_name, "uvCount": _v0414_uv_count(node), "parent": str(node.get_parent().name) if node.get_parent() else "", "castShadow": node.get("cast_shadow")}
		v0426_inventory.append(entry)
		if key == V0426_SHADOW:
			found_shadow = true
			if node.visible and node.mesh != null:
				v0426_nodes.append(node)
			else:
				_v0426_fail_closed("expected contact-shadow node is hidden or has no mesh")
				return
		elif key == V0426_STONE_BASE:
			v0426_excluded_inventory.append(entry)
		else:
			var possible_shadow := value.contains("shadow") or value.contains("contact") or value.contains("ground") or value.contains("bedding") or value.contains("ellipse")
			if possible_shadow and node.visible and node.mesh != null:
				v0426_unexpected.append(key)
			v0426_excluded_inventory.append(entry)
	if not found_shadow or v0426_nodes.size() != 1 or not v0426_unexpected.is_empty():
		_v0426_fail_closed("contact-shadow inventory mismatch; expected exactly one visible addressable shadow surface")
		return
	var node := v0426_nodes[0]
	var original := node.material_override as StandardMaterial3D
	if original == null:
		_v0426_fail_closed("contact-shadow material is not a StandardMaterial3D")
		return
	var original_texture = original.get("albedo_texture")
	if original_texture != null:
		_v0426_fail_closed("contact-shadow albedo texture would require an out-of-scope texture edit")
		return
	var transparency_value = original.get("transparency")
	if transparency_value == null or int(transparency_value) == 0:
		_v0426_fail_closed("original contact-shadow material does not expose a transparent material path")
		return
	var before_hashes := _v0414_house_hashes(barn)
	var mesh_count := _v0406_mesh_node_count()
	v0426_before_materials[node.name] = node.material_override
	v0426_before_snapshots[node.name] = _v0410_mesh_snapshot(node)
	v0426_original_state[node.name] = _v0426_material_state(original, node)
	var original_albedo: Color = original.get("albedo_color")
	var candidate_alpha := minf(original_albedo.a, 0.16)
	var candidate := _v0426_copy_material(original, "V0426_Secondary_Barn_Contact_Shadow")
	candidate.albedo_color = Color(0.188, 0.173, 0.157, candidate_alpha)
	candidate.roughness = 1.0
	candidate.specular = 0.0
	candidate.vertex_color_use_as_albedo = false
	node.material_override = candidate
	v0426_after_materials[node.name] = candidate
	v0426_after_snapshots[node.name] = _v0410_mesh_snapshot(node)
	v0426_final_state[node.name] = _v0426_material_state(candidate, node)
	var after_hashes := _v0414_house_hashes(barn)
	v0426_audit = {"baselineCommit": V0426_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0426_CHECKPOINT, "status": "RENDERED_CANDIDATE", "candidateRetained": true, "scope": "existing_visible_secondary_barn_contact_shadow_material_only", "affectedNodeCount": v0426_nodes.size(), "affectedNodeNames": v0426_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0426_inventory.filter(func(item): return str(item.name) == V0426_SHADOW), "functionalClassification": {V0426_SHADOW: "BARN_CONTACT_SHADOW"}, "excludedAdjacentInventory": v0426_excluded_inventory, "expectedInventory": [V0426_SHADOW], "unexpectedVisibleContactShadowNames": v0426_unexpected, "excludedStoneBaseInventory": [V0426_STONE_BASE], "originalMaterialState": v0426_original_state, "finalMaterialState": v0426_final_state, "originalMaterials": _v0414_material_inventory(v0426_before_materials), "finalMaterials": _v0414_material_inventory(v0426_after_materials), "finalMaterialParameters": ["contact shadow albedo RGB=#302c28 alpha=" + str(candidate_alpha) + " roughness=1.00 specular=0.00; original transparent render-state copied"], "originalSnapshots": v0426_before_snapshots, "finalSnapshots": v0426_after_snapshots, "uvCountEveryAffectedMesh": {node.name: _v0414_uv_count(node)}, "worldHashesBefore": before_hashes, "worldHashesAfter": after_hashes, "meshInstanceCountBefore": mesh_count, "meshInstanceCountAfter": _v0406_mesh_node_count(), "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "uvArraysChanged": false, "transformsChanged": false, "aabbChanged": false, "footprintChanged": false, "terrainChanged": false, "lightingChanged": false, "shadowSettingsChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "captureOnlyContextIsolation": "barn descendants only for close and diagnostic; visibility restored before comparisons, audit and exit", "v0425Eaves": "preserved", "v0424Ridge": "preserved", "v0423SideBeams": "preserved", "v0422FrontStructure": "preserved", "v0421EntranceFrame": "preserved", "v0420StoneBase": "preserved", "v0419Gable": "preserved", "v0418Openings": "preserved", "v0417WallBody": "preserved", "terrain": "preserved", "route": "preserved", "bridge": "preserved", "landings": "preserved", "mainHouse": "preserved", "characters": "preserved", "props": "preserved", "camera": "unchanged", "lighting": "unchanged", "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}

func _v0426_material_state(material: StandardMaterial3D, node: MeshInstance3D) -> Dictionary:
	var state := {}
	for key in ["albedo_color", "transparency", "blend_mode", "depth_draw_mode", "shading_mode", "roughness", "metallic", "specular", "vertex_color_use_as_albedo", "cull_mode", "render_priority", "albedo_texture"]:
		state[key] = material.get(key)
	state["cast_shadow"] = node.get("cast_shadow")
	state["visible"] = node.visible
	state["meshType"] = str(node.mesh.get_class()) if node.mesh else ""
	state["surfaceCount"] = node.mesh.get_surface_count() if node.mesh else 0
	state["transform"] = str(node.transform)
	state["aabb"] = str(node.get_aabb())
	return state

func _v0426_copy_material(original: StandardMaterial3D, name: String) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	for key in ["transparency", "blend_mode", "depth_draw_mode", "shading_mode", "cull_mode", "render_priority", "vertex_color_use_as_albedo"]:
		var value = original.get(key)
		if value != null:
			material.set(key, value)
	return material

func _v0426_set_materials(materials: Dictionary) -> void:
	for key in materials.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = materials[key]

func _v0426_restore_before_materials() -> void:
	super._v0425_restore_before_materials()
	_v0426_set_materials(v0426_before_materials)

func _v0426_restore_after_materials() -> void:
	super._v0425_restore_after_materials()
	_v0426_set_materials(v0426_after_materials)

func _v0426_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close_visibility := _v0423_isolate_barn_close_context()
	var close := await _v0409_capture_view("02_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_COLOUR.png", Vector3(-4.30, 4.35, 4.70), Vector3(-10.20, 1.40, 4.95), 2.80, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_SECONDARY_BARN_CONTACT_SHADOW_CLOSE_GRAYSCALE.png"))
	_v0423_restore_barn_close_context(close_visibility)
	_v0426_restore_before_materials()
	var baseline_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var baseline_close := await _v0409_capture_image(Vector3(-4.30, 4.35, 4.70), Vector3(-10.20, 1.40, 4.95), 2.80)
	_v0426_restore_after_materials()
	await _v0426_capture_diagnostic(root)
	_v0426_write_comparisons(primary, close, baseline_primary, baseline_close, root)
	_v0426_write_audit(root)
	get_tree().quit(0)

func _v0426_capture_diagnostic(root: String) -> void:
	var visibility := _v0423_isolate_barn_close_context()
	var original: Dictionary = {}
	var shadow_material := _v0426_material("V0426_Diagnostic_Contact_Shadow", Color("#d2b24b"), 1.0, 0.0)
	var base_material := _v0426_material("V0426_Diagnostic_Excluded_Base", Color("#456b78"), 1.0, 0.0)
	for material in [shadow_material, base_material]:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for key in [V0426_SHADOW, V0426_STONE_BASE]:
		var node := v0383_world.find_child(key, true, false) as MeshInstance3D
		if node:
			original[node.name] = node.material_override
			node.material_override = shadow_material if key == V0426_SHADOW else base_material
	var layer := CanvasLayer.new()
	var panel := ColorRect.new()
	panel.color = Color(0.03, 0.025, 0.02, 0.92)
	panel.position = Vector2(12.0, 12.0)
	panel.size = Vector2(1620.0, 180.0)
	var label := Label.new()
	label.position = Vector2(10.0, 8.0)
	label.add_theme_font_size_override("font_size", 18)
	label.text = "v0.426 TEMPORARY BARN CONTACT-SHADOW NODE ID\nCONTACT SHADOW: " + V0426_SHADOW + "\nSTONE BASE EXCLUDED: " + V0426_STONE_BASE + "\nFOOTPRINT / TERRAIN / LIGHTING: PRESERVED\nSHADOW SETTINGS: PRESERVED FROM ORIGINAL MATERIAL"
	panel.add_child(label)
	layer.add_child(panel)
	add_child(layer)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)
	if image.get_width() != 1920 or image.get_height() != 1080:
		image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	layer.free()
	for key in original.keys():
		var node := v0383_world.find_child(str(key), true, false) as MeshInstance3D
		if node:
			node.material_override = original[key]
	_v0423_restore_barn_close_context(visibility)
	image.save_png(root.path_join("05_TEMPORARY_BARN_CONTACT_SHADOW_NODE_ID.png"))

func _v0426_material(name: String, colour: Color, roughness: float, specular_value: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name
	material.albedo_color = colour
	material.roughness = roughness
	material.specular = specular_value
	material.vertex_color_use_as_albedo = false
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _v0426_write_comparisons(primary: Image, close: Image, baseline_primary: Image, baseline_close: Image, root: String) -> void:
	if baseline_primary and baseline_primary.get_width() == 1920:
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_primary.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		wide.blit_rect(baseline_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0425_V0426_WIDE_COMPARISON.png"))
	if baseline_close and baseline_close.get_width() == 1920:
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		baseline_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		near.blit_rect(baseline_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0425_V0426_CONTACT_SHADOW_CLOSE_COMPARISON.png"))

func _v0426_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0426-preservation-audit.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(v0426_audit, "  "))

func _v0426_fail_closed(reason: String) -> void:
	v0426_audit = {"baselineCommit": V0426_BASELINE, "branch": "codex/v0215-v0226-recovery", "checkpoint": V0426_CHECKPOINT, "status": V0426_LIMITATION, "candidateRetained": false, "reason": reason, "affectedNodeCount": v0426_nodes.size(), "affectedNodeNames": v0426_nodes.map(func(n): return str(n.name)), "affectedNodeInventory": v0426_inventory, "expectedInventory": [V0426_SHADOW], "unexpectedVisibleContactShadowNames": v0426_unexpected, "excludedStoneBaseInventory": [V0426_STONE_BASE], "materialOnly": true, "geometryChanged": false, "topologyChanged": false, "indicesChanged": false, "verticesChanged": false, "surfacesChanged": false, "transformsChanged": false, "aabbChanged": false, "footprintChanged": false, "terrainChanged": false, "lightingChanged": false, "shadowSettingsChanged": false, "overlays": false, "decals": false, "duplicateMeshes": false, "newMeshInstances": 0, "gameplay": false, "stateBehavior": "unchanged", "defaultRuntime": "unchanged", "fallbackRenderer": "unchanged", "debugRenderer": "unchanged"}
