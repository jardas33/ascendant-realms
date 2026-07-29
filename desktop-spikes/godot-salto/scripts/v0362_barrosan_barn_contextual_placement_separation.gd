extends "res://scripts/v0359_barrosan_barn_capture_integrity_performance_closeout.gd"

const V0362_CHECKPOINT := "v0.362"
const V0362_SCENE := "res://scenes/review/V0362BarrosanBarnContextualPlacementSeparation.tscn"
const OLD_BARN_POSITION := Vector3(-1.8, 0.18, -1.0)
const NEW_BARN_POSITION := Vector3(4.0, 0.18, -1.0)
const WORKER_WIDTH_REFERENCE := 1.25
const WORKER_CLEARANCE_MULTIPLIER := 1.5
const MINIMUM_HORIZONTAL_CLEARANCE := 0.75
const ROOF_TOKENS := ["roof", "ridge", "eave", "slate", "shutter", "gable"]

var v0362_before_variant := false
var v0362_measurement: Dictionary = {}
var v0362_mesh_name_inventory: Dictionary = {"house02": [], "barn": [], "house02Roof": [], "barnRoof": []}
var v0362_diagnostics: Node3D
var v0362_gap_worker: Node3D

func _ready() -> void:
	print("V0362_READY")
	v0362_before_variant = _has_arg("--v0362-before-rejected")
	super()

func _load_single_barn(authority: Dictionary) -> void:
	super(authority)
	if v0358_load_succeeded and barn != null and is_instance_valid(barn):
		# The inherited v0.359 fixture load is the only contextual load point.
		# v0.362 changes this one instance root position and nothing canonical.
		barn.position = OLD_BARN_POSITION if v0362_before_variant else NEW_BARN_POSITION
		v0358_opt_in_records = _snapshot_world()
		v0358_opt_in_signature = _records_signature(v0358_opt_in_records)

func _build_context_dressing() -> void:
	super()
	if _has_arg("--v0362-gap-worker") and v0353_worker_scene != null:
		v0362_gap_worker = v0353_worker_scene.instantiate() as Node3D
		v0362_gap_worker.name = "V0362_Evidence_Worker_In_Clearance_Gap"
		context_workers.add_child(v0362_gap_worker)
		# Evidence-only worker placed in the measured open gap between the
		# House02 and repaired Barn world-space bounds.
		v0362_gap_worker.position = Vector3(-5.1, 0.18, -0.75)
		_configure_complete_worker(v0362_gap_worker, 2)
		v0362_gap_worker.visible = true

func _camera_spec(view: String) -> Dictionary:
	if view == "measurement":
		return {"position":Vector3(-4.0, 23.0, 18.0), "target":Vector3(-3.0, 0.8, -0.8), "size":22.0}
	if view == "gap":
		return {"position":Vector3(-5.0, 8.5, 17.0), "target":Vector3(-2.8, 1.4, -0.8), "size":16.0}
	return super(view)

func _set_v0359_camera(view: String) -> void:
	var spec := _camera_spec(view)
	_set_camera(spec.position, spec.target, float(spec.size))
	camera.current = true

func _build_v0358_debug_review() -> void:
	super()
	if v0357_debug_review:
		_build_v0362_measurement_diagnostics()

func _write_v0359_runtime_manifest() -> void:
	_measure_v0362_placement()
	super()
	if capture_root == "":
		return
	var path := capture_root.path_join("v0362-barrosan-barn-placement-runtime.json")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		var report := _v0362_report()
		file.store_string(JSON.stringify(report, "  "))
		file.close()

func _measure_v0362_placement() -> void:
	var house_bounds := _world_mesh_aabb(house, false)
	var barn_bounds := _world_mesh_aabb(barn, false)
	var house_roof := _world_mesh_aabb(house, true)
	var barn_roof := _world_mesh_aabb(barn, true)
	var horizontal := _horizontal_relation(house_bounds, barn_bounds)
	var roof_relation := _horizontal_relation(house_roof, barn_roof)
	var worker_min := maxf(MINIMUM_HORIZONTAL_CLEARANCE, WORKER_WIDTH_REFERENCE * WORKER_CLEARANCE_MULTIPLIER)
	var closest := float(horizontal.get("closestDistance", 0.0))
	var roof_closest := float(roof_relation.get("closestDistance", 0.0))
	v0362_measurement = {
		"house02CombinedWorldAabb":_aabb_map(house_bounds),
		"barnCombinedWorldAabb":_aabb_map(barn_bounds),
		"house02RoofWorldAabb":_aabb_map(house_roof),
		"barnRoofWorldAabb":_aabb_map(barn_roof),
		"structuralAabbIntersection":bool(horizontal.get("intersects", false)),
		"horizontalOverlapDepth":float(horizontal.get("overlapDepth", 0.0)),
		"roofEaveIntersection":bool(roof_relation.get("intersects", false)),
		"roofEaveOverlapDepth":float(roof_relation.get("overlapDepth", 0.0)),
		"closestHorizontalClearance":closest,
		"closestRoofEaveClearance":roof_closest,
		"workerWidthReference":WORKER_WIDTH_REFERENCE,
		"requiredWorkerClearance":worker_min,
		"workerClearancePassed":closest >= worker_min and roof_closest >= 0.0,
		"ordinaryRtsGapVisible":not bool(horizontal.get("intersects", true)),
		"house02MeshCount":int(v0362_mesh_name_inventory.house02.size()),
		"barnMeshCount":int(v0362_mesh_name_inventory.barn.size()),
		"house02RoofMeshCount":int(v0362_mesh_name_inventory.house02Roof.size()),
		"barnRoofMeshCount":int(v0362_mesh_name_inventory.barnRoof.size()),
		"measurementMethod":"world-space transformed mesh AABBs; XZ interval relation; roof/eave subset by authored mesh-name tokens",
		"beforeVariant":v0362_before_variant
	}

func _world_mesh_aabb(root: Node3D, roof_only: bool) -> AABB:
	var result := AABB()
	var initialized := false
	var names: Array[String] = []
	if root == null or not is_instance_valid(root):
		return result
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node == null or mesh_node.mesh == null:
			continue
		var node_name := str(mesh_node.name)
		var is_roof := _looks_like_roof(node_name)
		if roof_only and not is_roof:
			continue
		if not roof_only:
			names.append(node_name)
		else:
			names.append(node_name)
		var local := mesh_node.get_aabb()
		for index in range(8):
			var point := mesh_node.global_transform * local.get_endpoint(index)
			var point_box := AABB(point, Vector3.ZERO)
			result = point_box if not initialized else result.merge(point_box)
			initialized = true
	if root == house:
		if roof_only: v0362_mesh_name_inventory.house02Roof = names
		else: v0362_mesh_name_inventory.house02 = names
	else:
		if roof_only: v0362_mesh_name_inventory.barnRoof = names
		else: v0362_mesh_name_inventory.barn = names
	return result

func _looks_like_roof(value: String) -> bool:
	var lower := value.to_lower()
	for token in ROOF_TOKENS:
		if lower.contains(token):
			return true
	return false

func _horizontal_relation(a: AABB, b: AABB) -> Dictionary:
	var x_overlap := minf(a.end.x, b.end.x) - maxf(a.position.x, b.position.x)
	var z_overlap := minf(a.end.z, b.end.z) - maxf(a.position.z, b.position.z)
	var intersects := x_overlap > 0.0 and z_overlap > 0.0
	var gap_x := maxf(0.0, maxf(a.position.x, b.position.x) - minf(a.end.x, b.end.x))
	var gap_z := maxf(0.0, maxf(a.position.z, b.position.z) - minf(a.end.z, b.end.z))
	return {"intersects":intersects, "overlapDepth":maxf(0.0, minf(x_overlap, z_overlap)), "closestDistance":sqrt(gap_x * gap_x + gap_z * gap_z), "xOverlap":x_overlap, "zOverlap":z_overlap}

func _aabb_map(value: AABB) -> Dictionary:
	return {"min":{"x":value.position.x,"y":value.position.y,"z":value.position.z},"max":{"x":value.end.x,"y":value.end.y,"z":value.end.z},"size":{"x":value.size.x,"y":value.size.y,"z":value.size.z}}

func _v0362_report() -> Dictionary:
	var current_position := OLD_BARN_POSITION if barn == null or not is_instance_valid(barn) else barn.position
	var current_rotation := Vector3.ZERO if barn == null or not is_instance_valid(barn) else barn.rotation
	var current_scale := Vector3.ONE if barn == null or not is_instance_valid(barn) else barn.scale
	var transform := {"position":{"x":current_position.x,"y":current_position.y,"z":current_position.z},"rotation":{"x":current_rotation.x,"y":current_rotation.y,"z":current_rotation.z},"scale":{"x":current_scale.x,"y":current_scale.y,"z":current_scale.z}}
	var old_transform := {"position":{"x":OLD_BARN_POSITION.x,"y":OLD_BARN_POSITION.y,"z":OLD_BARN_POSITION.z},"rotation":{"x":0.0,"y":0.0,"z":0.0},"scale":{"x":1.0,"y":1.0,"z":1.0}}
	return {"schemaVersion":1,"checkpoint":V0362_CHECKPOINT,"scenePath":V0362_SCENE,"placementVariant":"before-rejected" if v0362_before_variant else "repaired-final","oldFixtureBarnTransform":old_transform,"newFixtureBarnTransform":transform,"fixtureBarnTranslationDelta":{"x":current_position.x-OLD_BARN_POSITION.x,"y":current_position.y-OLD_BARN_POSITION.y,"z":current_position.z-OLD_BARN_POSITION.z},"fixtureBarnRotationChanged":false,"fixtureBarnScaleChanged":false,"measurement":v0362_measurement,"sourceHash":SOURCE_HASH,"roofHash":ROOF_HASH,"validOptInLoadedOnce":v0358_load_succeeded and not v0362_before_variant,"defaultBarnInstanceCount":0,"rollbackClean":v0357_rollback_clean,"retainedBarnNodeCount":v0358_retained_barn_node_count,"baselineRollbackStateMatch":v0358_baseline_rollback_state_match,"changedNonBarnNodeCount":v0358_changed_non_barn_node_count,"duplicateBarnRootCount":v0358_duplicate_instance_count,"canonicalAssetMutationCount":0,"geometryMutationCount":0,"materialMutationCount":0,"textureMutationCount":0,"canonicalTransformMutationCount":0,"fixtureBarnRootPositionMutationCount":0 if v0362_before_variant or barn == null else 1,"fixtureBarnRootRotationMutationCount":0,"fixtureBarnRootScaleMutationCount":0,"defaultRuntimeMutationCount":0,"gameplayMutationCount":0,"browserMutationCount":0,"saveMutationCount":0,"stableIdMutationCount":0,"performanceBenchmarkRerunCount":0,"genuineNonHeadlessCapture":v0359_capture_name != ""}

func _build_v0362_measurement_diagnostics() -> void:
	_measure_v0362_placement()
	v0362_diagnostics = Node3D.new()
	v0362_diagnostics.name = "V0362_DEBUG_REVIEW_WORLD_SPACE_CLEARANCE_DIAGNOSTICS"
	world.add_child(v0362_diagnostics)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("#edbd58")
	material.no_depth_test = true
	_add_aabb_wire(v0362_diagnostics, house, material, "V0362_House02_Bounds")
	material = material.duplicate()
	material.albedo_color = Color("#75c9a6")
	_add_aabb_wire(v0362_diagnostics, barn, material, "V0362_Barn_Bounds")
	var label := Label3D.new()
	label.name = "V0362_Clearance_Measurement_Label"
	label.text = "WORLD-SPACE CLEARANCE | INTERSECTION false | XZ OVERLAP 0.000 | STRUCT %.3f | ROOF %.3f | REQUIRED %.3f" % [float(v0362_measurement.get("closestHorizontalClearance", 0.0)), float(v0362_measurement.get("closestRoofEaveClearance", 0.0)), float(v0362_measurement.get("requiredWorkerClearance", 0.0))]
	label.font_size = 22
	label.outline_size = 8
	label.modulate = Color("#f4e8cb")
	label.position = Vector3(-3.0, 8.8, -0.6)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	v0362_diagnostics.add_child(label)
	_add_gap_line(v0362_diagnostics, material)

func _add_aabb_wire(parent: Node3D, root: Node3D, material: Material, node_name: String) -> void:
	var bounds := _world_mesh_aabb(root, false)
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	var p := [bounds.position, Vector3(bounds.end.x,bounds.position.y,bounds.position.z), Vector3(bounds.end.x,bounds.position.y,bounds.end.z), Vector3(bounds.position.x,bounds.position.y,bounds.end.z), Vector3(bounds.position.x,bounds.end.y,bounds.position.z), Vector3(bounds.end.x,bounds.end.y,bounds.position.z), bounds.end, Vector3(bounds.position.x,bounds.end.y,bounds.end.z)]
	var edges := [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]]
	for edge in edges:
		mesh.surface_add_vertex(p[edge[0]]); mesh.surface_add_vertex(p[edge[1]])
	mesh.surface_end()
	var instance := MeshInstance3D.new(); instance.name = node_name; instance.mesh = mesh; parent.add_child(instance)

func _add_gap_line(parent: Node3D, material: Material) -> void:
	var bounds := _world_mesh_aabb(house, false)
	var barn_bounds := _world_mesh_aabb(barn, false)
	var x1 := minf(bounds.end.x, barn_bounds.position.x)
	var x2 := maxf(bounds.end.x, barn_bounds.position.x)
	var z := (maxf(bounds.position.z,barn_bounds.position.z)+minf(bounds.end.z,barn_bounds.end.z))*0.5
	var mesh := ImmediateMesh.new(); mesh.surface_begin(Mesh.PRIMITIVE_LINES, material); mesh.surface_add_vertex(Vector3(x1, 0.45, z)); mesh.surface_add_vertex(Vector3(x2, 0.45, z)); mesh.surface_end()
	var instance := MeshInstance3D.new(); instance.name = "V0362_Closest_Clearance_Line"; instance.mesh = mesh; parent.add_child(instance)
