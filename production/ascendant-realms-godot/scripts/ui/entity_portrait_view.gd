extends Control
class_name EntityPortraitView
## Small visual-only 3D preview used by the selected-entity card.
## It duplicates the entity's authored model into an isolated SubViewport;
## no gameplay node, selection state, collision, or simulation object is used.

const FRAME_PATH := "res://assets/ui/frame_portrait.png"
const VIEW_SIZE := Vector2i(128, 128)

var _viewport_container: SubViewportContainer
var _viewport: SubViewport
var _pivot: Node3D
var _camera: Camera3D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(112, 112)
	_build_view()

func _build_view() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.055, 0.065, 0.075, 0.98)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	_viewport_container = SubViewportContainer.new()
	_viewport_container.name = "PortraitViewport"
	_viewport_container.stretch = true
	_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_viewport_container)

	_viewport = SubViewport.new()
	_viewport.size = VIEW_SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.transparent_bg = true
	_viewport_container.add_child(_viewport)

	var world := World3D.new()
	_viewport.world_3d = world

	_camera = Camera3D.new()
	_camera.name = "PortraitCamera"
	_viewport.add_child(_camera)

	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.055, 0.065, 0.075, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.62, 0.66, 0.78)
	env.ambient_light_energy = 0.86
	env_node.environment = env
	_viewport.add_child(env_node)

	var key := DirectionalLight3D.new()
	key.light_color = Color(1.0, 0.93, 0.82)
	key.light_energy = 1.15
	key.rotation_degrees = Vector3(-38.0, -32.0, 0.0)
	_viewport.add_child(key)

	var fill := DirectionalLight3D.new()
	fill.light_color = Color(0.55, 0.68, 1.0)
	fill.light_energy = 0.42
	fill.rotation_degrees = Vector3(-20.0, 145.0, 0.0)
	_viewport.add_child(fill)

	_pivot = Node3D.new()
	_pivot.name = "PortraitModel"
	_viewport.add_child(_pivot)

	var frame := TextureRect.new()
	frame.name = "PortraitFrame"
	if ResourceLoader.exists(FRAME_PATH):
		frame.texture = load(FRAME_PATH)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)

func configure_entity(entity) -> void:
	if not is_instance_valid(entity) or not is_instance_valid(_pivot):
		return
	for child in _pivot.get_children():
		child.queue_free()
	var definition: Dictionary = entity.def if "def" in entity and entity.def is Dictionary else {}
	var path := str(definition.get("model", ""))
	var is_building: bool = entity.get_class() == "Building"
	var target_height: float = 2.45 if is_building else 1.95
	var model: Node3D = null
	if not path.is_empty() and ResourceLoader.exists(path):
		var packed = load(path)
		if packed:
			model = packed.instantiate()
	if is_instance_valid(model):
		_pivot.add_child(model)
		ModelUtils.scale_to_height(model, target_height)
		ModelUtils.ground_model(model)
	else:
		# Truthful visual fallback for definitions without an authored model.
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.9, target_height, 0.7)
		mesh.mesh = box
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.32, 0.48, 0.56) if not is_building else Color(0.48, 0.34, 0.22)
		mesh.material_override = mat
		mesh.position.y = target_height * 0.5
		_pivot.add_child(mesh)

	var distance: float = 3.15 if not is_building else 3.75
	_camera.position = Vector3(0.0, target_height * 0.6, distance)
	_camera.look_at(Vector3(0.0, target_height * 0.48, 0.0), Vector3.UP)
	_pivot.rotation_degrees.y = -18.0
