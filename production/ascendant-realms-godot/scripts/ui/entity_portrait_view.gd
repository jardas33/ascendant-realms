extends Control
class_name EntityPortraitView
## Visual-only portrait for selected entities and command cards. It shows
## authored UI artwork when supplied, otherwise duplicates the entity's model
## into an isolated SubViewport without gameplay state or collision.

const FRAME_PATH := "res://assets/ui/frame_portrait.png"
const VIEW_SIZE := Vector2i(128, 128)
const PORTRAIT_MIN_SIZE := 46.0
const PORTRAIT_MAX_SIZE := 180.0
const PORTRAIT_COMPACT_THRESHOLD := 96.0
const PORTRAIT_FRAME_INSET := 5.0
const PORTRAIT_ARTWORK_INSET := 8.0
const PORTRAIT_MODEL_INSET := 10.0
const PORTRAIT_COMPACT_MODEL_INSET := 4.0
const PORTRAIT_TEXTURE_FILTER := CanvasItem.TEXTURE_FILTER_LINEAR
const LIORAEN_UNIT_PORTRAITS := {
	"Seedkeeper": "res://assets/ui/portraits/lioraen/astra_r1/seedkeeper.png",
	"Grove Warden": "res://assets/ui/portraits/lioraen/astra_r1/grove_warden.png",
	"Thornrunner": "res://assets/ui/portraits/lioraen/astra_r1/thornrunner.png",
}
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
	var model_inset := PORTRAIT_COMPACT_MODEL_INSET if custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD else PORTRAIT_MODEL_INSET
	_viewport_container.offset_left = model_inset
	_viewport_container.offset_top = model_inset
	_viewport_container.offset_right = -model_inset
	_viewport_container.offset_bottom = -model_inset
	_viewport_container.clip_contents = true
	_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_viewport_container)

	_viewport = SubViewport.new()
	_viewport.size = VIEW_SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD else SubViewport.UPDATE_ALWAYS
	_viewport.transparent_bg = true
	_viewport_container.add_child(_viewport)

	_artwork = TextureRect.new()
	_artwork.name = "PortraitArtwork"
	_artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	# The artwork owns the safe content area. Preserve the authored aspect ratio
	# and show the full source image; the frame is decoration, never a crop mask.
	_artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_artwork.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Small train/build choices need the complete authored silhouette to fill
	# their aperture. A second inset inside the clipped thumbnail made detailed
	# structures read as dark specks once the HUD scaled to a compact window.
	var artwork_inset := 0.0 if custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD else PORTRAIT_ARTWORK_INSET
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
	frame.modulate.a = 0.22 if custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD else 1.0
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
	if custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD:
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
		if not is_building:
			_pose_and_tint_unit(model, path, definition)
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
	var compact_card := custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD
	_compact_building_fill.visible = is_building or (compact_card and _active_portrait_path.is_empty())
	_compact_building_fill.light_energy = (2.4 if not is_building else 1.4) if compact_card else 1.0
	var distance: float = 2.35 if compact_card and not is_building else (2.75 if compact_card else 2.65)
	if is_building and not compact_card:
		# Broad structures need a three-quarter architectural view. A slender
		# tower occupies only a few pixels with that same camera, so let its live
		# model fill the portrait aperture without cropping the roof or footing.
		var narrow_structure := model_radius < target_height * 0.16
		# A stray far-off mesh in a borrowed model gave a huge radius and left
		# the building a speck in its frame (the Ledger Stone): cap the reach.
		distance = 2.3 if narrow_structure else maxf(3.55, minf(model_radius, target_height * 0.8) * 2.55 + 0.5)
		_camera.position = Vector3(distance * (0.34 if narrow_structure else 0.48), target_height * (1.05 if narrow_structure else 1.48), distance)
		_camera.fov = 50.0 if narrow_structure else 58.0
		_camera.look_at(Vector3(0.0, target_height * 0.48, 0.0), Vector3.UP)
	elif compact_card and bool(definition.get("is_siege", false)):
		distance = maxf(3.1, model_radius * 2.4 + 0.45)
		_camera.position = Vector3(distance * 0.3, target_height * 0.8, distance)
		_camera.fov = 58.0
		_camera.look_at(Vector3(0.0, target_height * 0.38, 0.0), Vector3.UP)
	else:
		# Waist-up, like the painted portraits: a full body in a 54 px card
		# was a few pixels of figure in a dark frame.
		_camera.position = Vector3(0.0, target_height * 0.74, 1.55 if compact_card else 1.75)
		_camera.fov = 50.0
		_camera.look_at(Vector3(0.0, target_height * 0.68, 0.0), Vector3.UP)
	# Character models face -Z (Godot's model front) and the camera sits on
	# +Z, so a unit showed its back: turn units to face the viewer.
	_pivot.rotation_degrees.y = -18.0 if (is_building or bool(definition.get("is_siege", false))) else 162.0


## A rendered unit portrait stood in its bind pose (arms straight out) and in
## its lender's colours. Put it in its idle stance and its people's palette.
func _pose_and_tint_unit(model: Node3D, path: String, definition: Dictionary) -> void:
	var race := str(definition.get("race", ""))
	var tint: Color = Unit.PEOPLE_PALETTES.get(race, Color.WHITE) if not path.get_file().begins_with(race) else Color.WHITE
	if tint != Color.WHITE:
		for child in model.find_children("*", "MeshInstance3D", true, false):
			var mi := child as MeshInstance3D
			if mi == null or mi.mesh == null:
				continue
			for surface in mi.mesh.get_surface_count():
				var source := mi.get_active_material(surface)
				if source is BaseMaterial3D:
					var mat := (source as BaseMaterial3D).duplicate() as BaseMaterial3D
					mat.albedo_color = Color(mat.albedo_color.r * tint.r, mat.albedo_color.g * tint.g, mat.albedo_color.b * tint.b, mat.albedo_color.a)
					mi.set_surface_override_material(surface, mat)
	var file := path.get_file().get_basename()
	var lib_path := "res://assets/characters/%s/%s_animations.tres" % [file, file]
	var player: AnimationPlayer = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player == null and ResourceLoader.exists(lib_path):
		player = AnimationPlayer.new()
		model.add_child(player)
		player.add_animation_library("", load(lib_path))
	if player == null:
		return
	var idle := ""
	for anim_name in player.get_animation_list():
		if "idle" in String(anim_name).to_lower():
			idle = String(anim_name)
			break
	if idle == "":
		return
	# Same skeleton-name repair as Unit: libraries address %GeneralSkeleton.
	var first: Animation = player.get_animation(idle)
	if first.get_track_count() > 0 and String(first.track_get_path(0)).begins_with("%GeneralSkeleton") and model.get_node_or_null("%GeneralSkeleton") == null:
		var skeletons: Array = model.find_children("*", "Skeleton3D", true, false)
		if skeletons.size() == 1:
			skeletons[0].name = "GeneralSkeleton"
			skeletons[0].owner = model
			skeletons[0].unique_name_in_owner = true
	player.play(idle)
	player.advance(0.35)
	player.pause()
	_redraw_once_posed()


## A compact card renders its viewport once, and that one frame was taken
## before the skeleton had applied the idle pose. Render it again once the
## pose is in.
func _redraw_once_posed() -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(_viewport) and custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _portrait_path_for_definition(definition: Dictionary, is_building: bool, unit_id: String = "") -> String:
	if is_building:
		# Worker build choices and finished selections may supply identity art.
		# Unfinished selected sites omit it to show the live construction stage.
		return String(definition.get("command_art", ""))
	var portrait_path := String(definition.get("portrait", ""))
	if portrait_path.is_empty() and not unit_id.is_empty():
		portrait_path = String(GameData.get_unit(unit_id).get("portrait", ""))
	if portrait_path.is_empty() and String(definition.get("race", "")) == "lioraen":
		# Keep this visual treatment in the HUD lane. The same definition reaches
		# selected-unit portraits and compact training cards without data edits.
		portrait_path = String(LIORAEN_UNIT_PORTRAITS.get(String(definition.get("name", "")), ""))
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
