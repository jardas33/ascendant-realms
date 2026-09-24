extends Control
class_name EntityPortraitView
## Small visual-only 3D preview used by the selected-entity card.
## It duplicates the entity's authored model into an isolated SubViewport;
## no gameplay node, selection state, collision, or simulation object is used.

const FRAME_PATH := "res://assets/ui/frame_portrait.png"
const VIEW_SIZE := Vector2i(128, 128)
const PORTRAIT_MIN_SIZE := 46.0
const PORTRAIT_MAX_SIZE := 180.0
const PORTRAIT_FRAME_INSET := 5.0
const PORTRAIT_ARTWORK_INSET := 8.0
const PORTRAIT_MODEL_INSET := 10.0
const PORTRAIT_COMPACT_MODEL_INSET := 4.0
const PORTRAIT_TEXTURE_FILTER := CanvasItem.TEXTURE_FILTER_LINEAR
static var _portrait_texture_cache: Dictionary = {}

var _viewport_container: SubViewportContainer
var _viewport: SubViewport
var _pivot: Node3D
var _camera: Camera3D
var _compact_building_fill: OmniLight3D
var _artwork: TextureRect
var _active_portrait_path := ""
var _pending_entity = null
var _pending_definition: Dictionary = {}
var _pending_definition_is_building := true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Respect the host module's authored size. The previous unconditional 116px
	# minimum expanded compact HUD cards after _ready() and caused the frame to
	# crowd the face at narrow resolutions.
	var requested_size := maxf(custom_minimum_size.x, custom_minimum_size.y)
	var resolved_size := clampf(requested_size if requested_size > 0.0 else PORTRAIT_MIN_SIZE, PORTRAIT_MIN_SIZE, PORTRAIT_MAX_SIZE)
	custom_minimum_size = Vector2(resolved_size, resolved_size)
	clip_contents = true
	_build_view()
	if is_instance_valid(_pending_entity):
		_apply_entity(_pending_entity)
	elif not _pending_definition.is_empty():
		_apply_definition(_pending_definition, _pending_definition_is_building)

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
	# The frame is decorative, so the live model needs its own clipped aperture.
	# Without this inset, wide roofs render over the lower frame ornament.
	var model_inset := PORTRAIT_COMPACT_MODEL_INSET if custom_minimum_size.x < 80.0 else PORTRAIT_MODEL_INSET
	_viewport_container.offset_left = model_inset
	_viewport_container.offset_top = model_inset
	_viewport_container.offset_right = -model_inset
	_viewport_container.offset_bottom = -model_inset
	_viewport_container.clip_contents = true
	_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_viewport_container)

	_viewport = SubViewport.new()
	_viewport.size = VIEW_SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if custom_minimum_size.x < 80.0 else SubViewport.UPDATE_ALWAYS
	_viewport.transparent_bg = true
	_viewport_container.add_child(_viewport)

	_artwork = TextureRect.new()
	_artwork.name = "PortraitArtwork"
	_artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# The artwork owns the safe content area. Preserve the authored aspect ratio
	# and show the full source image; the frame is decoration, never a crop mask.
	_artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_artwork.set_anchors_preset(Control.PRESET_FULL_RECT)
	var artwork_inset := 4.0 if custom_minimum_size.x < 80.0 else PORTRAIT_ARTWORK_INSET
	_artwork.offset_left = artwork_inset
	_artwork.offset_top = artwork_inset
	_artwork.offset_right = -artwork_inset
	_artwork.offset_bottom = -artwork_inset
	_artwork.texture_filter = PORTRAIT_TEXTURE_FILTER
	_artwork.clip_contents = true
	_artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_artwork.visible = false
	add_child(_artwork)

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
	env.ambient_light_energy = 1.05
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
	# Small building previews need a front-facing bounce light. Their dark
	# authored timber otherwise disappears at command-card thumbnail size.
	_compact_building_fill = OmniLight3D.new()
	_compact_building_fill.name = "CompactBuildingFill"
	_compact_building_fill.position = Vector3(-1.5, 2.6, 2.7)
	_compact_building_fill.light_color = Color(1.0, 0.88, 0.73)
	_compact_building_fill.light_energy = 1.4
	_compact_building_fill.omni_range = 7.0
	_compact_building_fill.visible = false
	_viewport.add_child(_compact_building_fill)

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
	frame.texture_filter = PORTRAIT_TEXTURE_FILTER
	# Tiny build choices need the model silhouette more than a second ornate
	# square. Keep the full portrait frame for the large selected-unit view.
	frame.modulate.a = 0.22 if custom_minimum_size.x < 80.0 else 1.0
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)

func configure_entity(entity) -> void:
	if not is_instance_valid(entity):
		return
	_pending_entity = entity
	if not is_instance_valid(_pivot):
		return
	_apply_entity(entity)


func configure_definition(definition: Dictionary, is_building: bool = true) -> void:
	_pending_definition = definition.duplicate(true)
	_pending_definition_is_building = is_building
	if is_instance_valid(_pivot):
		_apply_definition(_pending_definition, is_building)

func _apply_entity(entity) -> void:
	if not is_instance_valid(entity) or not is_instance_valid(_pivot):
		return
	_pending_entity = null
	_pending_definition = {}
	var definition: Dictionary = entity.def if "def" in entity and entity.def is Dictionary else {}
	_apply_definition(definition, entity is Building, String(entity.unit_id) if entity is Unit else "")


func _apply_definition(definition: Dictionary, is_building: bool, unit_id: String = "") -> void:
	if not is_instance_valid(_pivot):
		return
	if custom_minimum_size.x < 80.0:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_active_portrait_path = ""
	if is_instance_valid(_artwork):
		var portrait_path := _portrait_path_for_definition(definition, is_building, unit_id)
		if not portrait_path.is_empty() and ResourceLoader.exists(portrait_path):
			var texture := _load_portrait_texture(portrait_path)
			if texture:
				_active_portrait_path = portrait_path
				_artwork.texture = texture
				_artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				_artwork.visible = true
				_viewport_container.visible = false
		if _active_portrait_path.is_empty():
			_artwork.texture = null
			_artwork.visible = false
			_viewport_container.visible = true
	for child in _pivot.get_children():
		child.queue_free()
	var path := str(definition.get("model", ""))
	var target_height: float = 2.45 if is_building else 1.95
	var model: Node3D = null
	var model_radius := 0.0
	if not path.is_empty() and ResourceLoader.exists(path):
		var packed = load(path)
		if packed:
			model = packed.instantiate()
	if is_instance_valid(model):
		if path == "res://assets/environment/buildings/barrosan_houses_a03.glb":
			ModelUtils.isolate_a03_house_a(model)
		_pivot.add_child(model)
		ModelUtils.scale_to_height(model, target_height)
		ModelUtils.ground_model(model)
		if path == "res://assets/environment/buildings/barrosan_houses_a03.glb":
			ModelUtils.recenter_a03_house_a_visual_only(model)
		if is_building or bool(definition.get("is_siege", false)):
			model_radius = ModelUtils.measure_radius(model)
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

	# Group cards are intentionally compact.  Keep the authored model readable
	# at that size instead of shrinking it into the portrait frame's dark center.
	# The single-card presentation keeps the established camera distance.
	var compact_card := custom_minimum_size.x < 80.0
	_compact_building_fill.visible = is_building or (compact_card and _active_portrait_path.is_empty())
	_compact_building_fill.light_energy = (2.4 if not is_building else 1.4) if compact_card else 1.0
	var distance: float = 2.35 if compact_card and not is_building else (2.75 if compact_card else 2.65)
	if is_building and not compact_card:
		# Wide structures need a three-quarter architectural view; character
		# framing used to crop the building down to one wall texture.
		distance = maxf(3.55, model_radius * 2.55 + 0.5)
		_camera.position = Vector3(distance * 0.48, target_height * 1.48, distance)
		_camera.fov = 58.0
		_camera.look_at(Vector3(0.0, target_height * 0.48, 0.0), Vector3.UP)
	elif compact_card and bool(definition.get("is_siege", false)):
		distance = maxf(3.1, model_radius * 2.4 + 0.45)
		_camera.position = Vector3(distance * 0.3, target_height * 0.8, distance)
		_camera.fov = 58.0
		_camera.look_at(Vector3(0.0, target_height * 0.38, 0.0), Vector3.UP)
	else:
		_camera.position = Vector3(0.0, target_height * 0.58, distance)
		_camera.fov = 56.0 if compact_card else 62.0
		_camera.look_at(Vector3(0.0, target_height * 0.48, 0.0), Vector3.UP)
	_pivot.rotation_degrees.y = -18.0


func _portrait_path_for_definition(definition: Dictionary, is_building: bool, unit_id: String = "") -> String:
	if is_building:
		# Construction art is presentation-only. Large selected-building portraits
		# still render the live authored model, while compact build choices may
		# show a recognizable illustration of that exact structure.
		return String(definition.get("command_art", "")) if custom_minimum_size.x < 80.0 else ""
	var portrait_path := String(definition.get("portrait", ""))
	if portrait_path.is_empty() and not unit_id.is_empty():
		portrait_path = String(GameData.get_unit(unit_id).get("portrait", ""))
	return portrait_path


func _load_portrait_texture(path: String) -> Texture2D:
	if _portrait_texture_cache.has(path):
		return _portrait_texture_cache[path]
	var texture = load(path)
	if texture is Texture2D:
		_portrait_texture_cache[path] = texture
		return texture
	return null


func get_active_portrait_path() -> String:
	return _active_portrait_path
