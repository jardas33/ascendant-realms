class_name ModelUtils

## Ground a model so its mesh bottom sits at the given y_offset in world space.
static func ground_model(node: Node3D, y_offset: float = 0.0) -> void:
	var min_y := INF
	for child in node.find_children("*", "MeshInstance3D"):
		var mi = child as MeshInstance3D
		if mi and mi.mesh:
			var aabb = mi.get_aabb()
			for corner_idx in 8:
				var corner = aabb.get_endpoint(corner_idx)
				var world_y = mi.to_global(corner).y
				if world_y < min_y:
					min_y = world_y
	if min_y != INF and abs(min_y) > 0.001:
		node.position.y -= min_y - y_offset

static func measure_height(node: Node3D) -> float:
	var min_y := INF
	var max_y := -INF
	for child in node.find_children("*", "MeshInstance3D"):
		var mi = child as MeshInstance3D
		if mi and mi.mesh:
			for corner_idx in 8:
				var corner = mi.get_aabb().get_endpoint(corner_idx)
				var world_y = mi.to_global(corner).y
				min_y = min(min_y, world_y)
				max_y = max(max_y, world_y)
	return max_y - min_y if min_y != INF else 0.0

static func scale_to_height(node: Node3D, target_meters: float) -> void:
	var current = measure_height(node)
	if current < 0.001:
		return
	var factor = target_meters / current
	node.scale *= factor

static func setup_character_for_movement(node: Node3D, target_height: float = 1.8) -> void:
	scale_to_height(node, target_height)
	ground_model(node)

## Returns the world-space XZ radius of a node's combined mesh AABB.
static func measure_radius(node: Node3D) -> float:
	var aabb := _get_combined_aabb(node)
	return max(aabb.size.x, aabb.size.z) * 0.5

static func add_per_part_convex_collision(node: Node3D, collision_layer: int = 1) -> void:
	var meshes = node.find_children("*", "MeshInstance3D")
	var parts: Array[Dictionary] = []
	for child in meshes:
		var mi = child as MeshInstance3D
		if not mi or not mi.mesh:
			continue
		var aabb = mi.get_aabb()
		var vol = aabb.size.x * aabb.size.y * aabb.size.z
		parts.append({"mesh": mi, "volume": vol})
	parts.sort_custom(func(a, b): return a["volume"] > b["volume"])
	var filtered: Array[MeshInstance3D] = []
	for i in min(parts.size(), 25):
		filtered.append(parts[i]["mesh"])
	for mi in filtered:
		mi.create_convex_collision(true, true)
		for i in range(mi.get_child_count() - 1, -1, -1):
			if mi.get_child(i) is StaticBody3D:
				var sb = mi.get_child(i) as StaticBody3D
				sb.collision_layer = collision_layer
				sb.collision_mask = 0
				break

## Generate the same per-part convex collision policy, but move each generated
## body beneath a caller-owned destination root so visible meshes never own
## their physical descendants. The source mesh transforms and collision policy
## intentionally remain unchanged.
static func add_per_part_convex_collision_to(node: Node3D, destination_root: Node3D, collision_layer: int = 1) -> int:
	if not node or not destination_root:
		return 0
	var meshes = get_mesh_instances(node)
	var parts: Array[Dictionary] = []
	for child in meshes:
		var mi = child as MeshInstance3D
		if not mi or not mi.mesh:
			continue
		var aabb = mi.get_aabb()
		var vol = aabb.size.x * aabb.size.y * aabb.size.z
		parts.append({"mesh": mi, "volume": vol})
	parts.sort_custom(func(a, b): return a["volume"] > b["volume"])
	var filtered: Array[MeshInstance3D] = []
	for i in min(parts.size(), 25):
		filtered.append(parts[i]["mesh"])
	var generated_count := 0
	for mi in filtered:
		var shape = mi.mesh.create_convex_shape(true, true)
		if not shape:
			continue
		var body := StaticBody3D.new()
		body.name = "%s_collision" % mi.name
		body.collision_layer = collision_layer
		body.collision_mask = 0
		var mesh_transform := _transform_to_ancestor(mi, node.get_parent() as Node3D)
		destination_root.add_child(body)
		body.transform = mesh_transform
		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = shape
		body.add_child(collision_shape)
		generated_count += 1
	return generated_count

static func get_mesh_instances(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	_collect_mesh_instances(node, result)
	return result

static func _collect_mesh_instances(node: Node, result: Array[MeshInstance3D]) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			result.append(child as MeshInstance3D)
		_collect_mesh_instances(child, result)

static func _transform_to_ancestor(node: Node3D, ancestor: Node3D) -> Transform3D:
	var result := Transform3D.IDENTITY
	var cursor: Node3D = node
	while cursor and cursor != ancestor:
		result = cursor.transform * result
		cursor = cursor.get_parent() as Node3D
	return result

static func set_animation_loops(anim_player: AnimationPlayer) -> void:
	var oneshot_anims = ["jump", "attack", "slash", "shoot", "hurt", "die", "death",
		"fall", "climb", "dive", "hit", "cast", "throw", "reload", "pick_up", "punch", "spell"]
	for anim_name in anim_player.get_animation_list():
		var anim = anim_player.get_animation(anim_name)
		if not anim:
			continue
		var lower_name = anim_name.to_lower()
		var is_oneshot = false
		for keyword in oneshot_anims:
			if keyword in lower_name:
				is_oneshot = true
				break
		anim.loop_mode = Animation.LOOP_NONE if is_oneshot else Animation.LOOP_LINEAR

static func _get_combined_aabb(node: Node3D) -> AABB:
	var combined := AABB()
	var first := true
	for child in node.find_children("*", "MeshInstance3D"):
		var mesh_instance = child as MeshInstance3D
		if mesh_instance and mesh_instance.mesh:
			var child_aabb = mesh_instance.mesh.get_aabb()
			var child_transform: Transform3D
			if node.is_inside_tree():
				child_transform = node.global_transform.inverse() * mesh_instance.global_transform
			else:
				child_transform = mesh_instance.transform
			var transformed_aabb = child_transform * child_aabb
			if first:
				combined = transformed_aabb
				first = false
			else:
				combined = combined.merge(transformed_aabb)
	return combined
