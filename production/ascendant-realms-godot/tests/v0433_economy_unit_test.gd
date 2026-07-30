extends SceneTree

const ResourceNodeScript := preload("res://scripts/world/resource_node.gd")

func _init() -> void:
	var node = ResourceNodeScript.new()
	root.add_child(node)
	var depletion_events: Array = []
	node.depleted_once.connect(func(_n): depletion_events.append(true))
	node.configure("stone", 2, "", 1.0)
	assert(node.extract(3) == 2)
	assert(node.amount == 0)
	assert(node.depleted)
	assert(depletion_events.size() == 1)
	assert(node.extract(3) == 0)
	assert(depletion_events.size() == 1)
	print("v0.433 focused ResourceNode depletion tests passed")
	quit(0)
