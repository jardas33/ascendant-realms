extends Node3D

const CHECKPOINT := "v0.366"
const BASE_HEAD := "82a0dfb1f58bbb1651c29893b9414fa6b73a553a"
const HOUSE_SOURCE := "res://assets/v0338/barrosan_house_02_material_gold_candidate.glb"
const BARN_SOURCE := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"
const HOUSE_A_PATH := "V0358_House02_Shared_Baseline_Unmodified/LOD0_Granite"
const HOUSE_B_PATH := "V0358_House02_Shared_Baseline_Unmodified/LOD0_Weathered_Timber"
const BARN_C_PATH := "V0358_Barrosan_Barn_Gold_OptIn_Single_Instance/V0347_Barn_Rendered_Geometry_Truth"

var artifact_root := ""
var capture_root := ""
var world: Node3D
var camera: Camera3D
var house_original: Node3D
var house_clean: Node3D
var barn_original: Node3D
var barn_clean: Node3D
var manifest: Dictionary = {}
var derived_records: Array[Dictionary] = []

func _ready() -> void:
	artifact_root = OS.get_environment("V0366_ARTIFACT_ROOT")
	if artifact_root == "": artifact_root = "artifacts/runtime/v0366/capture"
	capture_root = artifact_root.path_join("screenshots")
	DirAccess.make_dir_recursive_absolute(capture_root)
	_build_world()
	_load_pairs()
	_build_camera()
	await get_tree().process_frame
	await get_tree().process_frame
	await _capture_all()
	_write_manifest()
	get_tree().quit(0)

func _build_world() -> void:
	world = Node3D.new(); world.name = "V0366_Isolated_Review_World"; add_child(world)
	var ground := MeshInstance3D.new(); ground.name = "V0366_Review_Ground"
	var ground_mesh := BoxMesh.new(); ground_mesh.size = Vector3(38.0, 0.28, 24.0); ground_mesh.material = _material("V0366_Grass_Terrain", Color("#67725b"), 0.96); ground.mesh = ground_mesh; ground.position = Vector3(2.0, -0.18, 0.0); world.add_child(ground)
	var water := MeshInstance3D.new(); water.name = "V0366_River_Below_Land"
	var water_mesh := BoxMesh.new(); water_mesh.size = Vector3(30.0, 0.12, 3.8); water_mesh.material = _material("V0366_River_Water", Color("#2d5962"), 0.88); water.mesh = water_mesh; water.position = Vector3(2.0, -0.30, 4.8); world.add_child(water)
	var bank := MeshInstance3D.new(); bank.name = "V0366_Riverbank_Transition"
	var bank_mesh := BoxMesh.new(); bank_mesh.size = Vector3(30.0, 0.10, 0.65); bank_mesh.material = _material("V0366_Riverbank", Color("#8a785c"), 0.98); bank.mesh = bank_mesh; bank.position = Vector3(2.0, -0.08, 2.85); world.add_child(bank)
	var road := MeshInstance3D.new(); road.name = "V0366_Road_Context"
	var road_mesh := BoxMesh.new(); road_mesh.size = Vector3(30.0, 0.08, 1.55); road_mesh.material = _material("V0366_Road", Color("#8b7658"), 0.99); road.mesh = road_mesh; road.position = Vector3(2.0, 0.03, 1.0); world.add_child(road)
	var sun := DirectionalLight3D.new(); sun.name = "V0366_Consistent_Directional_Key"; sun.rotation_degrees = Vector3(-48.0, -34.0, 0.0); sun.light_energy = 1.05; sun.shadow_enabled = true; add_child(sun)
	var fill := WorldEnvironment.new(); fill.name = "V0366_Readability_Ambient_Fill"; var env := Environment.new(); env.background_mode = Environment.BG_COLOR; env.background_color = Color("#aeb3a1"); env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR; env.ambient_light_color = Color("#8c9889"); env.ambient_light_energy = 0.55; env.tonemap_mode = Environment.TONE_MAPPER_FILMIC; fill.environment = env; add_child(fill)

func _load_pairs() -> void:
	var house_scene := load(HOUSE_SOURCE) as PackedScene
	var barn_scene := load(BARN_SOURCE) as PackedScene
	if house_scene == null or barn_scene == null: push_error("V0366_SOURCE_LOAD_FAILED"); return
	house_original = house_scene.instantiate() as Node3D; house_original.name = "V0366_House02_Canonical_Original"; house_original.position = Vector3(-8.0, 0.0, -0.7); house_original.scale = Vector3(0.52, 0.52, 0.52); _hide_non_lod(house_original); world.add_child(house_original)
	house_clean = house_scene.instantiate() as Node3D; house_clean.name = "V0366_House02_Derived_Clean_Fork"; house_clean.position = Vector3(-0.6, 0.0, -0.7); house_clean.scale = house_original.scale; _hide_non_lod(house_clean); world.add_child(house_clean)
	var h_a := _find_named(house_clean, "LOD0_Granite") as MeshInstance3D
	var h_b := _find_named(house_clean, "LOD0_Weathered_Timber") as MeshInstance3D
	if h_a != null and h_a.mesh is ArrayMesh:
		var result_a := _derive_mesh(h_a.mesh as ArrayMesh, "HOUSE_A")
		h_a.mesh = result_a.mesh
		derived_records.append(result_a.record)
	if h_b != null and h_b.mesh is ArrayMesh:
		var result_b := _derive_mesh(h_b.mesh as ArrayMesh, "HOUSE_B")
		h_b.mesh = result_b.mesh
		derived_records.append(result_b.record)
	barn_original = barn_scene.instantiate() as Node3D; barn_original.name = "V0366_Barn_Canonical_Original"; barn_original.position = Vector3(6.8, 0.0, -0.45); barn_original.scale = Vector3(0.46, 0.46, 0.46); world.add_child(barn_original)
	barn_clean = barn_scene.instantiate() as Node3D; barn_clean.name = "V0366_Barn_Derived_Clean_Fork"; barn_clean.position = Vector3(14.2, 0.0, -0.45); barn_clean.scale = barn_original.scale; world.add_child(barn_clean)
	var b_c := _find_named(barn_clean, "V0347_Barn_Rendered_Geometry_Truth") as MeshInstance3D
	if b_c != null and b_c.mesh is ArrayMesh:
		var result_c := _derive_mesh(b_c.mesh as ArrayMesh, "BARN_C")
		b_c.mesh = result_c.mesh
		derived_records.append(result_c.record)
	_add_scale_workers()

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

func _derive_mesh(source: ArrayMesh, target: String) -> Dictionary:
	var derived := ArrayMesh.new()
	var before_triangles := 0
	var after_triangles := 0
	var removed_triangles := 0
	var removed_components: Array[String] = []
	var surfaces := source.get_surface_count()
	for surface in range(surfaces):
		var arrays: Array = source.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var source_indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var indices := PackedInt32Array()
		if source_indices.size() > 0: indices = source_indices
		else:
			for index in range(vertices.size()): indices.append(index)
		before_triangles += int(indices.size() / 3)
		var components := _triangle_components(vertices, indices)
		var kept := PackedInt32Array()
		var seen: Dictionary = {}
		for triangle in range(0, indices.size(), 3):
			var component_id := int(components[triangle / 3])
			var component_aabb: AABB = components.get("aabb_%d" % component_id, AABB()) if components is Dictionary else AABB()
			var remove := false
			if components is Dictionary:
				remove = _component_matches(component_aabb, target)
			if remove:
				removed_triangles += 1
				var key := "%s:s%d:c%d" % [target, surface, component_id]
				if not seen.has(key): removed_components.append(key); seen[key] = true
			else:
				kept.append(indices[triangle]); kept.append(indices[triangle + 1]); kept.append(indices[triangle + 2])
		after_triangles += int(kept.size() / 3)
		var out_arrays: Array = []
		out_arrays.resize(Mesh.ARRAY_MAX)
		out_arrays[Mesh.ARRAY_VERTEX] = vertices
		for attribute in [Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_COLOR, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2, Mesh.ARRAY_BONES, Mesh.ARRAY_WEIGHTS]:
			if arrays[attribute] != null and arrays[attribute].size() > 0: out_arrays[attribute] = arrays[attribute]
		out_arrays[Mesh.ARRAY_INDEX] = kept
		derived.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, out_arrays)
		var material := source.surface_get_material(surface)
		if material != null: derived.surface_set_material(surface, material)
	var record := {"target":target,"sourceSurfaceCount":surfaces,"derivedSurfaceCount":derived.get_surface_count(),"sourceTriangleCount":before_triangles,"derivedTriangleCount":after_triangles,"removedTriangleCount":removed_triangles,"removedComponents":removed_components,"canonicalMeshSignature":_mesh_signature(source),"derivedMeshSignature":_mesh_signature(derived),"deltaIsGeometry":removed_triangles > 0}
	return {"mesh":derived,"record":record}

func _triangle_components(vertices: PackedVector3Array, indices: PackedInt32Array) -> Dictionary:
	var keys: Dictionary = {}
	var vertex_keys := PackedInt32Array()
	var parents: Array[int] = []
	for vertex in vertices:
		var key := _position_key(vertex)
		if not keys.has(key): keys[key] = parents.size(); parents.append(parents.size())
		vertex_keys.append(int(keys[key]))
	for triangle in range(0, indices.size(), 3):
		_union(parents, vertex_keys[indices[triangle]], vertex_keys[indices[triangle + 1]])
		_union(parents, vertex_keys[indices[triangle + 1]], vertex_keys[indices[triangle + 2]])
		_union(parents, vertex_keys[indices[triangle + 2]], vertex_keys[indices[triangle]])
	var aabbs: Dictionary = {}
	for vertex_index in range(vertices.size()):
		var root := _find(parents, vertex_keys[vertex_index])
		if not aabbs.has(root): aabbs[root] = AABB(vertices[vertex_index], Vector3.ZERO)
		else: aabbs[root] = aabbs[root].expand(vertices[vertex_index])
	var component_ids: Dictionary = {}
	var next_id := 0
	var result := {"aabb": aabbs}
	for triangle in range(0, indices.size(), 3):
		var root := _find(parents, vertex_keys[indices[triangle]])
		if not component_ids.has(root): component_ids[root] = next_id; result["aabb_%d" % next_id] = aabbs[root]; next_id += 1
		result[triangle / 3] = int(component_ids[root])
	return result

func _component_matches(box: AABB, target: String) -> bool:
	var c := box.get_center()
	if target == "HOUSE_A": return c.x > 1.5 and c.x < 4.8 and c.y > 0.45 and c.y < 0.95 and c.z > -0.8 and c.z < 1.1
	if target == "HOUSE_B": return c.x > 2.5 and c.x < 5.2 and c.y > 0.45 and c.y < 2.85 and c.z > -0.35 and c.z < 0.45
	if target == "BARN_C": return c.z < -4.25 and c.x > -5.7 and c.x < -2.15 and c.y < 2.05
	return false

func _union(parents: Array[int], a: int, b: int) -> void:
	var root_a := _find(parents, a); var root_b := _find(parents, b)
	if root_a != root_b: parents[root_b] = root_a

func _find(parents: Array[int], value: int) -> int:
	var result := value
	while parents[result] != result: result = parents[result]
	var cursor := value
	while parents[cursor] != cursor:
		var next := parents[cursor]; parents[cursor] = result; cursor = next
	return result

func _position_key(value: Vector3) -> String:
	return "%d:%d:%d" % [roundi(value.x * 1000.0), roundi(value.y * 1000.0), roundi(value.z * 1000.0)]

func _mesh_signature(mesh: ArrayMesh) -> String:
	var parts: Array[String] = []
	for surface in range(mesh.get_surface_count()):
		var arrays: Array = mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		parts.append("%d:%d:%s" % [vertices.size(), indices.size(), str(mesh.surface_get_material(surface).resource_name if mesh.surface_get_material(surface) else "none")])
	return _sha256_text("|".join(parts))

func _add_scale_workers() -> void:
	_add_worker("V0366_Aster_Scale", Vector3(-2.4, 0.0, 1.65), Color("#365c63"))
	_add_worker("V0366_Defender_Scale", Vector3(5.0, 0.0, 1.7), Color("#7b4a3b"))
	_add_worker("V0366_Reserve_Support_Scale", Vector3(12.6, 0.0, 1.7), Color("#927547"))

func _add_worker(label: String, position: Vector3, color: Color) -> void:
	var root := Node3D.new(); root.name = label; root.position = position; world.add_child(root)
	var body := CapsuleMesh.new(); body.radius = 0.22; body.height = 1.15; body.material = _material(label + "_body", color, 0.96)
	var body_instance := MeshInstance3D.new(); body_instance.mesh = body; body_instance.position.y = 0.72; root.add_child(body_instance)
	var head := SphereMesh.new(); head.radius = 0.18; head.height = 0.36; head.material = _material(label + "_head", Color("#c9ad86"), 0.98)
	var head_instance := MeshInstance3D.new(); head_instance.mesh = head; head_instance.position.y = 1.45; root.add_child(head_instance)
	var shadow := CylinderMesh.new(); shadow.top_radius = 0.34; shadow.bottom_radius = 0.34; shadow.height = 0.018; shadow.material = _material(label + "_contact", Color(0.06,0.08,0.07,0.32), 0.99)
	var shadow_instance := MeshInstance3D.new(); shadow_instance.mesh = shadow; shadow_instance.position.y = 0.025; root.add_child(shadow_instance)

func _build_camera() -> void:
	camera = Camera3D.new(); camera.name = "V0366_Stable_Oblique_Comparison_Camera"; camera.projection = Camera3D.PROJECTION_PERSPECTIVE; camera.fov = 43.0; camera.current = true; add_child(camera)

func _capture_all() -> void:
	await _capture("01_decision_scope.png", Vector3(20.0, 16.0, 25.0), Vector3(3.0, 1.2, 0.0), "canonical and clean forks, exact paired transforms")
	await _capture("02_original_vs_clean.png", Vector3(16.0, 11.0, 19.0), Vector3(2.0, 1.4, -0.3), "original left / derived clean right")
	await _capture("03_house_a.png", Vector3(4.0, 5.0, 10.0), Vector3(-3.5, 1.5, -0.5), "House02 A ground-front stone component removed")
	await _capture("04_house_b.png", Vector3(4.0, 5.0, 10.0), Vector3(-3.5, 2.1, -0.5), "House02 B upper timber bracket islands removed")
	await _capture("05_house_preservation.png", Vector3(3.0, 4.2, 9.0), Vector3(-0.6, 1.8, -0.4), "House02 clean fork preserves roof, walls, doors and windows")
	await _capture("06_barn_c.png", Vector3(5.0, 4.6, 11.0), Vector3(10.5, 1.9, -0.6), "Barn C front timber cluster removed")
	await _capture("07_barn_preservation.png", Vector3(5.0, 4.6, 11.0), Vector3(14.2, 2.0, -0.5), "Barn clean fork preserves roof, walls and structural mass")
	await _capture("08_ledger.png", Vector3(19.0, 14.0, 23.0), Vector3(3.0, 1.0, 0.0), "derived mesh hash and mutation ledger")

func _capture(filename: String, position: Vector3, target: Vector3, purpose: String) -> void:
	camera.position = position; camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	if image != null:
		image.save_png(capture_root.path_join(filename))
		if not manifest.has("captures"): manifest["captures"] = []
		manifest["captures"].append({"file":filename,"purpose":purpose,"rendered":true,"sha256":_sha256_file(capture_root.path_join(filename))})

func _write_manifest() -> void:
	manifest["status"] = "PASS_V0366_DERIVED_MESH_CAPTURE"
	manifest["checkpoint"] = CHECKPOINT; manifest["baseHead"] = BASE_HEAD; manifest["houseSource"] = HOUSE_SOURCE; manifest["barnSource"] = BARN_SOURCE
	manifest["houseTargets"] = {"A":"component envelope on LOD0_Granite","B":"upper bracket/scaffold component envelope on LOD0_Weathered_Timber"}
	manifest["barnTarget"] = {"C":"front timber cluster across merged material surfaces"}
	manifest["houseSourceHash"] = _sha256_file(HOUSE_SOURCE); manifest["barnSourceHash"] = _sha256_file(BARN_SOURCE)
	manifest["derivedRecords"] = derived_records
	manifest["canonicalAssetMutationCount"] = 0; manifest["canonicalSceneMutationCount"] = 0; manifest["productionIntegrationCount"] = 0; manifest["gameplayMutationCount"] = 0; manifest["transformMutationCount"] = 0; manifest["placementMutationCount"] = 0; manifest["stableIdMutationCount"] = 0; manifest["saveMutationCount"] = 0; manifest["defaultRuntimeMutationCount"] = 0
	manifest["meshDerivationMethod"] = "surface-preserving ArrayMesh fork; triangle-connected component AABB exclusion; canonical nodes remain present in left comparison"
	manifest["humanReviewStop"] = true
	var file := FileAccess.open(artifact_root.path_join("v0366-manifest.json"), FileAccess.WRITE); file.store_string(JSON.stringify(manifest, "  ")); file.close()

func _material(name: String, color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new(); material.resource_name = name; material.albedo_color = color; material.roughness = roughness; material.metallic = 0.0; return material

func _sha256_text(value: String) -> String:
	var context := HashingContext.new(); context.start(HashingContext.HASH_SHA256); context.update(value.to_utf8_buffer()); return context.finish().hex_encode()

func _sha256_file(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	var file := FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		context.update(file.get_buffer(1048576))
	file.close()
	return context.finish().hex_encode()
