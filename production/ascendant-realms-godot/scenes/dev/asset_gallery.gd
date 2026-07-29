extends Control

## Opt-in developer gallery. It is not referenced by the production main scene.
@export var category_filter := "all"

func _ready() -> void:
	var label := Label.new()
	label.text = "ASCENDANT REALMS — OPT-IN ASSET GALLERY\nCategory: %s\nUse only from the editor/developer scene picker." % category_filter
	label.position = Vector2(48, 48)
	label.add_theme_font_size_override("font_size", 28)
	add_child(label)
