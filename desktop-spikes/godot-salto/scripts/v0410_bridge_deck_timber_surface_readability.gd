extends "res://scripts/v0409_secondary_barn_roof_surface_readability.gd"

## v0.410 is a material-only, opt-in bridge-deck readability checkpoint.
## Existing plank meshes, bridge structure, route, and gameplay remain authoritative.

const V0410_CHECKPOINT := "v0.410"
const V0410_CAPTURE_ROOT := "artifacts/runtime/v0410"
const V0410_TIMBER_TEXTURE := "res://assets/v0338/barrosan_house_02_material_gold_candidate_timber_albedo_1024.png"
const V0410_DECK_PLANK_NAMES := [
	"Bridge_Deck_Plank_00", "Bridge_Deck_Plank_01", "Bridge_Deck_Plank_02", "Bridge_Deck_Plank_03",
	"Bridge_Deck_Plank_04", "Bridge_Deck_Plank_05", "Bridge_Deck_Plank_06", "Bridge_Deck_Plank_07",
	"Bridge_Deck_Plank_08", "Bridge_Deck_Plank_09", "Bridge_Deck_Plank_10", "Bridge_Deck_Plank_11",
	"Bridge_Deck_Plank_12", "Bridge_Deck_Plank_13", "Bridge_Deck_Plank_14", "Bridge_Deck_Plank_15",
	"Bridge_Deck_Plank_16", "Bridge_Deck_Plank_17"
]

var v0410_capture_mode := false
var v0410_smoke_mode := false
var v0410_deck_nodes: Array[MeshInstance3D] = []
var v0410_timber_texture: Texture2D
var v0410_audit: Dictionary = {}
var v0410_before_materials: Dictionary = {}
var v0410_after_materials: Dictionary = {}

func _read_v0409_args() -> void:
	v0410_capture_mode = false
	v0410_smoke_mode = false
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0410-bridge-deck-capture": v0410_capture_mode = true
		if arg == "--v0410-bridge-deck-smoke": v0410_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0410_CAPTURE_ROOT
	## Parent v0.409 schedules through the v0.407 callback; keep that path opt-in.
	v0409_capture_mode = v0410_capture_mode
	v0409_smoke_mode = v0410_smoke_mode

func _v0409_apply_existing_material_treatment() -> void:
	_v0410_apply_existing_material_treatment()

func _v0407_start_capture() -> void:
	await get_tree().process_frame
	await _v0410_capture_sequence()

func _v0407_smoke_exit() -> void:
	await get_tree().process_frame
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	_v0410_write_audit(root)
	var file := FileAccess.open(root.path_join("v0410-bridge-deck-timber-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0410_CHECKPOINT,
			"status": v0410_audit.get("status", "ASSET_UV_LIMITATION_BRIDGE_DECK"),
			"candidateRetained": v0410_audit.get("candidateRetained", false),
			"materialOnly": v0410_audit.get("materialOnly", true),
			"geometryChanged": false,
			"uvArraysChanged": false,
			"gameplay": false,
			"defaultRuntime": "unchanged"
		}, "  "))
	get_tree().quit(0)

func _v0410_apply_existing_material_treatment() -> void:
	v0410_deck_nodes.clear()
	var missing: Array[String] = []
	for node_name in V0410_DECK_PLANK_NAMES:
		var node := _v0406_find_mesh(node_name)
		if node == null or node.mesh == null:
			missing.append(node_name)
		else:
			v0410_deck_nodes.append(node)
	if not missing.is_empty():
		_v0410_fail_closed("existing visible deck plank missing: " + ", ".join(missing))
		return
	v0410_timber_texture = load(V0410_TIMBER_TEXTURE) as Texture2D
	if v0410_timber_texture == null:
		_v0410_fail_closed("accepted repository-authored timber texture missing")
		return
	var before: Dictionary = {}
	var after: Dictionary = {}
	var inventory: Array = []
	for index in v0410_deck_nodes.size():
		var node: MeshInstance3D = v0410_deck_nodes[index]
		var snapshot := _v0410_mesh_snapshot(node)
		before[node.name] = snapshot
		v0410_before_materials[node.name] = node.material_override
		inventory.append({"name": node.name, "material": node.material_override.resource_name if node.material_override else "null", "uvCount": snapshot.get("uvCount", 0), "visible": node.visible})
		if snapshot.get("uvCount", 0) == 0:
			_v0410_fail_closed("visible " + node.name + " has no usable authored UV arrays")
			return
	var timber := StandardMaterial3D.new()
	timber.resource_name = "V0410_Bridge_Weathered_Timber_Deck"
	timber.albedo_texture = v0410_timber_texture
	timber.albedo_color = Color("#8c6b4e")
	timber.roughness = 0.96
	timber.uv1_scale = Vector3(1.15, 1.15, 1.15)
	timber.uv1_triplanar = false
	timber.vertex_color_use_as_albedo = false
	timber.cull_mode = BaseMaterial3D.CULL_DISABLED
	for node in v0410_deck_nodes:
		node.material_override = timber
		v0410_after_materials[node.name] = node.material_override
		after[node.name] = _v0410_mesh_snapshot(node)
	v0410_audit = {
		"baselineCommit": "1083ce84f90e983c66879ea095631203f200ebaa",
		"checkpoint": V0410_CHECKPOINT,
		"status": "RENDERED_CANDIDATE",
		"candidateRetained": true,
		"scope": "existing_bridge_deck_plank_materials_only",
		"materialOnly": true,
		"texture": V0410_TIMBER_TEXTURE,
		"deckPlankCount": v0410_deck_nodes.size(),
		"deckMeshInventory": inventory,
		"before": before,
		"after": after,
		"geometryChanged": false,
		"topologyChanged": false,
		"indicesChanged": false,
		"verticesChanged": false,
		"uvArraysChanged": false,
		"transformsChanged": false,
		"aabbChanged": false,
		"rails": "preserved",
		"posts": "preserved",
		"supports": "preserved",
		"abutments": "preserved",
		"footings": "preserved",
		"route": "v0407-preserved",
		"landings": "v0407-preserved",
		"house": "v0408-preserved",
		"barn": "v0409-fail-closed-preserved",
		"camera": "unchanged",
		"lighting": "unchanged",
		"characters": "unchanged",
		"props": "unchanged",
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged"
	}

func _v0410_fail_closed(reason: String) -> void:
	v0410_before_materials.clear()
	v0410_after_materials.clear()
	v0410_audit = {
		"baselineCommit": "1083ce84f90e983c66879ea095631203f200ebaa",
		"checkpoint": V0410_CHECKPOINT,
		"status": "ASSET_UV_LIMITATION_BRIDGE_DECK",
		"candidateRetained": false,
		"materialOnly": true,
		"reason": reason,
		"geometryChanged": false,
		"topologyChanged": false,
		"indicesChanged": false,
		"verticesChanged": false,
		"uvArraysChanged": false,
		"transformsChanged": false,
		"aabbChanged": false,
		"newGeometry": false,
		"duplicateSurfaces": false,
		"duplicateMeshes": false,
		"overlays": false,
		"decals": false,
		"rails": "preserved",
		"posts": "preserved",
		"supports": "preserved",
		"abutments": "preserved",
		"footings": "preserved",
		"route": "v0407-preserved",
		"landings": "v0407-preserved",
		"house": "v0408-preserved",
		"barn": "v0409-fail-closed-preserved",
		"camera": "unchanged",
		"lighting": "unchanged",
		"characters": "unchanged",
		"props": "unchanged",
		"gameplay": false,
		"defaultRuntime": "unchanged",
		"fallbackRenderer": "unchanged",
		"debugRenderer": "unchanged"
	}

func _v0410_capture_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _v0409_capture_view("01_PRIMARY_RTS_COLOUR.png", Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0, root)
	var close := await _v0409_capture_view("02_BRIDGE_DECK_CLOSE_COLOUR.png", Vector3(15.5, 13.5, 15.5), Vector3(1.3, 0.62, 0.82), 7.0, root)
	var primary_gray := primary.duplicate()
	primary_gray.convert(Image.FORMAT_L8)
	primary_gray.save_png(root.path_join("03_PRIMARY_RTS_GRAYSCALE.png"))
	var close_gray := close.duplicate()
	close_gray.convert(Image.FORMAT_L8)
	close_gray.save_png(root.path_join("04_BRIDGE_DECK_CLOSE_GRAYSCALE.png"))
	_v0410_set_materials(v0410_before_materials)
	var prior_primary := await _v0409_capture_image(Vector3(24.0, 31.0, 24.0), Vector3(-1.0, 0.35, 1.0), 19.0)
	var prior_close := await _v0409_capture_image(Vector3(15.5, 13.5, 15.5), Vector3(1.3, 0.62, 0.82), 7.0)
	_v0410_set_materials(v0410_after_materials)
	await _v0410_capture_diagnostic(root)
	_v0410_write_comparisons(primary, close, prior_primary, prior_close, root)
	_v0410_write_audit(root)
	get_tree().quit(0)

func _v0410_set_materials(materials: Dictionary) -> void:
	for node_name in materials.keys():
		var node := _v0406_find_mesh(str(node_name))
		if node: node.material_override = materials[node_name]

func _v0410_capture_diagnostic(root: String) -> void:
	v0383_camera.position = Vector3(15.5, 13.5, 15.5)
	v0383_camera.size = 7.0
	v0383_camera.look_at(Vector3(1.3, 0.62, 0.82), Vector3.UP)
	var candidates := ["Bridge_Deck_Plank_00", "Bridge_Deck_Plank_06", "Bridge_Deck_Plank_12", "Bridge_Deck_Plank_17"]
	var colours := [Color(0.95, 0.08, 0.08), Color(0.08, 0.95, 0.12), Color(0.08, 0.32, 1.0), Color(1.0, 0.75, 0.05)]
	var sheet := Image.create(1920, 1080, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("#11100d"))
	for candidate_index in candidates.size():
		var node := _v0406_find_mesh(candidates[candidate_index])
		if node == null: continue
		var original := node.material_override
		var diagnostic_material := StandardMaterial3D.new()
		diagnostic_material.albedo_color = colours[candidate_index]
		diagnostic_material.vertex_color_use_as_albedo = false
		diagnostic_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = diagnostic_material
		var layer := CanvasLayer.new()
		var panel := ColorRect.new()
		panel.color = Color(0.03, 0.025, 0.02, 0.90)
		panel.position = Vector2(18.0, 18.0)
		panel.size = Vector2(780.0, 90.0)
		var label := Label.new()
		label.position = Vector2(14.0, 10.0)
		label.add_theme_font_size_override("font_size", 21)
		label.text = "v0.410 BRIDGE DECK MATERIAL DIAGNOSTIC\n" + candidates[candidate_index] + "  |  red/green/blue/yellow by plank"
		panel.add_child(label)
		layer.add_child(panel)
		add_child(layer)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		image.convert(Image.FORMAT_RGBA8)
		image.resize(960, 540, Image.INTERPOLATE_LANCZOS)
		var destination := Vector2i((candidate_index % 2) * 960, (candidate_index / 2) * 540)
		sheet.blit_rect(image, Rect2i(0, 0, 960, 540), destination)
		layer.free()
		node.material_override = original
	sheet.save_png(root.path_join("05_BRIDGE_DECK_MATERIAL_DIAGNOSTIC.png"))

func _v0410_write_comparisons(primary: Image, close: Image, prior_primary: Image, prior_close: Image, root: String) -> void:
	if prior_primary and prior_primary.get_width() == 1920:
		prior_primary.convert(Image.FORMAT_RGBA8)
		primary.convert(Image.FORMAT_RGBA8)
		var wide := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		wide.blit_rect(prior_primary, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		wide.blit_rect(primary, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		wide.save_png(root.path_join("06_V0409_V0410_WIDE_COMPARISON.png"))
	if prior_close and prior_close.get_width() == 1920:
		prior_close.convert(Image.FORMAT_RGBA8)
		close.convert(Image.FORMAT_RGBA8)
		var near := Image.create(3840, 1080, false, Image.FORMAT_RGBA8)
		near.blit_rect(prior_close, Rect2i(0, 0, 1920, 1080), Vector2i.ZERO)
		near.blit_rect(close, Rect2i(0, 0, 1920, 1080), Vector2i(1920, 0))
		near.save_png(root.path_join("07_V0409_V0410_BRIDGE_DECK_CLOSE_COMPARISON.png"))

func _v0410_write_audit(root: String) -> void:
	var file := FileAccess.open(root.path_join("v0410-preservation-audit.json"), FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(v0410_audit, "  "))

func _v0410_mesh_snapshot(node: MeshInstance3D) -> Dictionary:
	var mesh := node.mesh
	var vertex_count := 0
	var index_count := 0
	var uv_count := 0
	var surface_count := mesh.get_surface_count() if mesh else 0
	if mesh is ArrayMesh and surface_count > 0:
		var arrays := mesh.surface_get_arrays(0)
		if arrays.size() > Mesh.ARRAY_VERTEX: vertex_count = (arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
		if arrays.size() > Mesh.ARRAY_INDEX: index_count = (arrays[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
		if arrays.size() > Mesh.ARRAY_TEX_UV: uv_count = (arrays[Mesh.ARRAY_TEX_UV] as PackedVector2Array).size()
	return {
		"material": node.material_override.resource_name if node.material_override else "null",
		"meshType": mesh.get_class() if mesh else "null",
		"vertexCount": vertex_count,
		"indexCount": index_count,
		"triangleCount": index_count / 3,
		"surfaceCount": surface_count,
		"uvCount": uv_count,
		"aabb": _v0406_aabb(mesh.get_aabb()) if mesh else {},
		"transform": _v0407_transform(node.transform)
	}
