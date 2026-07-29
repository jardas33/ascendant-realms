extends "res://scripts/v0352_barn_final_gold_repair.gd"

const OUTPUT_PATH := "res://scenes/gold/barrosan/BarrosanBarnGold.tscn"

func _ready() -> void:
	var source := load(BARN_GLB) as PackedScene
	if source == null:
		push_error("v0.355 could not load frozen barn GLB")
		get_tree().quit(1)
		return
	barn = source.instantiate() as Node3D
	barn.name = "FrozenBarnVisual"
	add_child(barn)
	remove_child(barn)
	_set_owners(barn, barn)
	var packed := PackedScene.new()
	var pack_error := packed.pack(barn)
	if pack_error != OK:
		push_error("v0.355 canonical scene pack failed: %s" % pack_error)
		get_tree().quit(1)
		return
	var save_error := ResourceSaver.save(packed, OUTPUT_PATH)
	if save_error != OK:
		push_error("v0.355 canonical scene save failed: %s" % save_error)
		get_tree().quit(1)
		return
	print("V0355_CANONICAL_SCENE_BAKED")
	get_tree().quit(0)

func _set_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		_set_owners(child, root)
