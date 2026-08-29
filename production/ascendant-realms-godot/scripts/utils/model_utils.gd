class_name ModelUtils

static var _convex_shape_cache: Dictionary = {}

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

## Isolate the documented House A sub-asset from the frozen A03 hero-pair GLB.
## The current game has one Barrosan housing definition and no visual-variant
## system, so House B and the review-only ground leaves must not enter the
## Clan Croft presentation or its generated collision envelope.
static func isolate_a03_house_a(node: Node3D) -> Dictionary:
	var removed_meshes := 0
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		if not mesh:
			continue
		var lower_name := mesh.name.to_lower()
		if not lower_name.begins_with("b_") and lower_name != "grass" and lower_name != "lanedirt":
			continue
		var parent := mesh.get_parent()
		if parent:
			parent.remove_child(mesh)
		mesh.free()
		removed_meshes += 1
	return {"selected_house": "HOUSE_A", "removed_meshes": removed_meshes}

## Recenter only the instantiated House A visual around its owning Building
## origin. A03 is authored as a combined A/B pair, so filtering B geometry does
## not remove House A's source-space offset. Existing generated collision bodies
## are restored to their pre-recenter world transforms so gameplay/collision
## authority remains at the Building origin.
static func recenter_a03_house_a_visual_only(node: Node3D) -> Dictionary:
	var reference := node.get_parent() as Node3D
	if not reference:
		return {"applied": false, "offset": Vector3.ZERO, "bounds": AABB()}
	var combined := AABB()
	var first := true
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		if not mesh or not mesh.mesh:
			continue
		var local_transform := reference.global_transform.inverse() * mesh.global_transform
		var transformed := local_transform * mesh.mesh.get_aabb()
		if first:
			combined = transformed
			first = false
		else:
			combined = combined.merge(transformed)
	if first:
		return {"applied": false, "offset": Vector3.ZERO, "bounds": AABB()}
	var pre_recenter_collision: Array[Dictionary] = []
	for child in node.find_children("*", "StaticBody3D", true, false):
		var body := child as StaticBody3D
		if body:
			pre_recenter_collision.append({"body": body, "transform": body.global_transform})
	var center := combined.position + combined.size * 0.5
	var offset := Vector3(-center.x, 0.0, -center.z)
	# center and position are both expressed in the visual root's parent space.
	# Moving only this imported visual node leaves the Building origin,
	# selection ring, navigation, and gameplay collision authority untouched.
	node.position += offset
	node.force_update_transform()
	var post_combined := AABB()
	var post_first := true
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mesh := child as MeshInstance3D
		if not mesh or not mesh.mesh:
			continue
		var local_transform := reference.global_transform.inverse() * mesh.global_transform
		var transformed := local_transform * mesh.mesh.get_aabb()
		if post_first:
			post_combined = transformed
			post_first = false
		else:
			post_combined = post_combined.merge(transformed)
	var post_center := post_combined.position + post_combined.size * 0.5 if not post_first else Vector3.ZERO
	for entry in pre_recenter_collision:
		var body = entry["body"] as StaticBody3D
		if is_instance_valid(body):
			body.global_transform = entry["transform"]
	return {"applied": true, "offset": offset, "bounds": combined, "pre_center": center, "post_center": post_center, "collision_bodies_preserved": not pre_recenter_collision.is_empty()}

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

## Adds one private collision body per selected mesh part while reusing the
## immutable generated Shape3D for repeated imported meshes. Body and shape
## nodes remain instance-local so collision layers, transforms, and lifecycle
## stay equivalent to add_per_part_convex_collision().
static func add_cached_per_part_convex_collision(node: Node3D, collision_layer: int = 1, cache_namespace: String = "") -> Dictionary:
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
	var cache_hits := 0
	var cache_misses := 0
	for mi in filtered:
		var mesh_key := String(mi.mesh.resource_path)
		var cache_key := "%s|%s|%s" % [cache_namespace, mesh_key, String(mi.name)]
		var cached = _convex_shape_cache.get(cache_key)
		if cached is Dictionary and cached.get("shape") is Shape3D:
			var body := StaticBody3D.new()
			body.name = String(cached.get("body_name", "StaticBody3D"))
			body.transform = cached.get("body_transform", Transform3D.IDENTITY)
			body.collision_layer = collision_layer
			body.collision_mask = 0
			var shape_node := CollisionShape3D.new()
			shape_node.name = String(cached.get("shape_name", "CollisionShape3D"))
			shape_node.shape = cached["shape"]
			shape_node.transform = cached.get("shape_transform", Transform3D.IDENTITY)
			body.add_child(shape_node)
			mi.add_child(body)
			cache_hits += 1
			continue
		cache_misses += 1
		mi.create_convex_collision(true, true)
		var generated_body: StaticBody3D = null
		for child_idx in range(mi.get_child_count() - 1, -1, -1):
			if mi.get_child(child_idx) is StaticBody3D:
				generated_body = mi.get_child(child_idx) as StaticBody3D
				break
		if generated_body:
			generated_body.collision_layer = collision_layer
			generated_body.collision_mask = 0
			var generated_shapes = generated_body.find_children("*", "CollisionShape3D", true, false)
			var generated_shape: CollisionShape3D = generated_shapes[0] if not generated_shapes.is_empty() else null
			if generated_shape and generated_shape.shape:
				_convex_shape_cache[cache_key] = {
					"shape": generated_shape.shape,
					"body_name": generated_body.name,
					"body_transform": generated_body.transform,
					"shape_name": generated_shape.name,
					"shape_transform": generated_shape.transform,
				}
	return {"cache_hits": cache_hits, "cache_misses": cache_misses, "parts": filtered.size()}

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
