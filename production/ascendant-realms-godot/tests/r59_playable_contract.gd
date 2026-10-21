extends SceneTree
## Focused integration fixture, separate from the ordinary game/launcher.
## Real model preparation, generated collision, picking, snow and lifecycle.
## Completion here is direct; ordinary construction/production require live play.

class ContractWorld extends Node3D:
	signal alert(text: String, position: Vector3)
	var map := {"theme": "snow"}
	var player_team := 0
	var game_running := false
	var completed := 0
	var destroyed := 0
	func on_building_completed(_building) -> void: completed += 1
	func on_building_destroyed(_building) -> void: destroyed += 1

var _checks: Array = []
var _failures: Array = []
var _records: Array = []

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, label: String) -> void:
	_checks.append({"label": label, "ok": ok})
	if not ok:
		_failures.append(label)
		push_error("R59 CONTRACT: " + label)

func _run() -> void:
	var game_data := root.get_node("GameData")
	var user_dir := OS.get_user_data_dir().replace("\\", "/")
	check(user_dir.ends_with("/AscendantRealms_Emanuel_Playable_R59") or user_dir.ends_with("/AscendantRealms_Emanuel_Playable_R59_QA"), "private review or separate QA profile")
	var world := ContractWorld.new()
	root.add_child(world)
	var commander = load("res://scripts/game/commander.gd").new()
	commander.race = "karak"
	world.add_child(commander)
	var expected := {
		"karak_hold": [GranitbornBuildingPresentation.HOLD, 7.0, 3000.0, 12, 8.05],
		"karak_longhouse": [GranitbornBuildingPresentation.HOUSE, 3.6, 700.0, 8, 4.14],
		"karak_warforge": [GranitbornBuildingPresentation.FORGE, 5.0, 1225.0, 0, 5.75],
	}
	for id in expected:
		var spec: Array = expected[id]
		var definition: Dictionary = game_data.get_building(id)
		check(String(definition.model) == spec[0], id + " normal definition activates candidate")
		var building = load("res://scripts/buildings/building.gd").new()
		world.add_child(building)
		building.position = Vector3((_records.size() - 1) * 30.0, 0, 0)
		# Disabling the whole CollisionObject removes it from the physics space.
		# Disable callbacks only; real picking/collision must remain registered.
		building.set_process(false)
		building.set_physics_process(false)
		building.configure(definition, 0, commander, world, id != "karak_warforge")
		commander.buildings.append(building)
		check(is_equal_approx(building.footprint, float(spec[1])), id + " unchanged footprint")
		check(is_equal_approx(building.max_hp, float(spec[2])), id + " unchanged Granitborn health")
		check(int(building.def.grants_pop) == int(spec[3]), id + " unchanged population grant")
		var model: Node3D = building.model_root.get_child(0)
		check(absf(ModelUtils.measure_height(model) - float(spec[4])) < 0.015, id + " reviewed scale retained")
		var shapes := model.find_children("*", "CollisionShape3D", true, false)
		check(not shapes.is_empty(), id + " fresh candidate hulls present")
		var radius := 0.0
		for shape in shapes:
			if shape.shape is ConvexPolygonShape3D:
				for point in (shape.shape as ConvexPolygonShape3D).points:
					var p: Vector3 = building.to_local(shape.to_global(point))
					radius = maxf(radius, Vector2(p.x, p.z).length())
		check(radius <= building.footprint + 0.05, id + " new physical hulls stay in gameplay footprint")
		var snow := 0
		for mesh in building._mesh_instances:
			if mesh.material_overlay != null: snow += 1
		check(snow == (4 if id == "karak_warforge" else building._mesh_instances.size()), id + " architectural snow surfaces")
		if id == "karak_longhouse":
			var thatch_found := false
			for mesh in building._mesh_instances:
				var mat = mesh.get_active_material(0)
				if mat is StandardMaterial3D and mat.albedo_texture != null and mat.resource_name.contains("Thatch"):
					thatch_found = true
					check(mat.albedo_texture.get_image().has_mipmaps(), "Roundhouse imported thatch mipmaps")
			check(thatch_found, "Roundhouse authored thatch material")
		var particles := model.find_children("*", "GPUParticles3D", true, false)
		if id == "karak_warforge":
			check(particles.size() == 2, "Forge owns two native particle systems")
			check(model.find_children("*", "Light3D", true, false).is_empty(), "Forge ambient effect adds no point lights")
			check(not building._granitborn_effects.visible and particles.all(func(p): return not p.emitting), "unfinished Forge effects off")
			check(building._mesh_instances.all(func(m): return m.get_active_material(0) is ShaderMaterial), "candidate Forge participates in native construction rise")
			building._complete_build()
			check(building.is_built and building._granitborn_effects.visible and particles.all(func(p): return p.emitting), "native completion starts Forge effects")
			check(building._mesh_instances.all(func(m): return m.get_active_material(0) is StandardMaterial3D), "completion restores candidate materials")
			check(world.completed == 1, "native completion callback retained")
		await physics_frame
		await physics_frame
		var rays := 0
		for x in [-0.55, 0.0, 0.55]:
			var spot: Vector3 = building.global_position + Vector3(x * building.footprint, 0, 0)
			var query := PhysicsRayQueryParameters3D.create(spot + Vector3.UP * 20, spot - Vector3.UP * 2, 4)
			var hit := world.get_world_3d().direct_space_state.intersect_ray(query)
			var entity: Node = hit.get("collider")
			while entity != null and entity != building: entity = entity.get_parent()
			if entity == building: rays += 1
		check(rays == 3, id + " centre and side silhouette rays resolve genuine building")
		_records.append({"id": id, "model": definition.model, "height": ModelUtils.measure_height(model), "hull_shapes": shapes.size(), "physical_radius": radius, "snow_surfaces": snow, "rays": rays})
		if id == "karak_warforge":
			building._destroy()
			check(building.is_dead and not building._granitborn_effects.visible and particles.all(func(p): return not p.emitting), "native destruction stops Forge effects")
			check(world.destroyed == 1, "native destruction callback retained")
	var output := {"checks": _checks, "failures": _failures, "buildings": _records, "user_dir": OS.get_user_data_dir(), "fixture": true}
	var file := FileAccess.open("user://r59_contract.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(output, "  "))
	file.close()
	print("R59_CONTRACT checks=", _checks.size(), " failures=", _failures)
	world.queue_free()
	await process_frame
	quit(0 if _failures.is_empty() else 1)
