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
const PORTRAIT_TEXTURE_FILTER := CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
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
var _posed_model: Node3D

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
	# Plan 392: the build and train cards drew their models at card size with
	# no smoothing, so roofs and beams stood in stair-stepped, shimmering
	# edges. The model is now drawn at twice the size with 8x MSAA and
	# filtered down, which costs little at this size.
	_viewport.msaa_3d = Viewport.MSAA_8X
	_viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	_viewport.scaling_3d_scale = 2.0
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

	# Plan 422: a bronze frame drawn to match the HUD metal, in place of the
	# ornate teal and gold painting; small cards get only a fine dark rim.
	var frame := Control.new()
	frame.name = "PortraitFrame"
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var compact := custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD
	frame.draw.connect(func(): _draw_bronze_frame(frame, compact))
	frame.resized.connect(frame.queue_redraw)
	add_child(frame)

static func _draw_bronze_frame(ci: Control, compact: bool) -> void:
	var r := Rect2(Vector2.ZERO, ci.size)
	if compact:
		_draw_compact_bevel(ci, r)
		return
	# Plan 425: a lit forged bezel (hud_forged.gdshader) with the picture
	# seen through its opening, a soft inner shadow and gem bosses.
	var c := 7.0
	var pts := PackedVector2Array([Vector2(c, 0), Vector2(r.end.x - c, 0), Vector2(r.end.x, c), Vector2(r.end.x, r.end.y - c),
		Vector2(r.end.x - c, r.end.y), Vector2(c, r.end.y), Vector2(0, r.end.y - c), Vector2(0, c)])
	var g := 4.6
	var studs := [Vector4(5, 5, g, 1.0), Vector4(r.end.x - 5, 5, g, 1.0), Vector4(5, r.end.y - 5, g, 1.0), Vector4(r.end.x - 5, r.end.y - 5, g, 1.0)]
	load("res://scripts/ui/hud_forged_skin.gd").paint(ci, pts, studs, r.grow(-8.0), {"rim": 7.0, "groove": 1.2, "inlay": 0.0, "shadow": 4.0})

# Plan 460: small portraits had only a dark hairline, so the paintings
# looked pasted onto the panel. They now sit in a thin bronze bevel with
# clipped corners, a lit top edge and a darker foot for the health bar.
static func _draw_compact_bevel(ci: Control, r: Rect2) -> void:
	var w := r.size.x
	var h := r.size.y
	if w < 8.0 or h < 8.0:
		return
	var foot := minf(h * 0.34, 18.0)
	ci.draw_polygon(PackedVector2Array([Vector2(0, h - foot), Vector2(w, h - foot), Vector2(w, h), Vector2(0, h)]),
		PackedColorArray([Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.55), Color(0, 0, 0, 0.55)]))
	var c := clampf(minf(w, h) * 0.12, 3.0, 7.0)
	var corner := Color(0.045, 0.04, 0.035, 1.0)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(0, 0), Vector2(c + 1.0, 0), Vector2(0, c + 1.0)]), corner)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(w, 0), Vector2(w, c + 1.0), Vector2(w - c - 1.0, 0)]), corner)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(w, h), Vector2(w - c - 1.0, h), Vector2(w, h - c - 1.0)]), corner)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(0, h), Vector2(0, h - c - 1.0), Vector2(c + 1.0, h)]), corner)
	var i := 1.0
	var ring := PackedVector2Array([Vector2(c + i, i), Vector2(w - c - i, i), Vector2(w - i, c + i), Vector2(w - i, h - c - i),
		Vector2(w - c - i, h - i), Vector2(c + i, h - i), Vector2(i, h - c - i), Vector2(i, c + i), Vector2(c + i, i)])
	ci.draw_polyline(ring, Color(0.02, 0.015, 0.01, 0.9), 3.0, true)
	ci.draw_polyline(ring, Color(0.62, 0.47, 0.28, 1.0), 1.4, true)
	var j := 2.6
	ci.draw_polyline(PackedVector2Array([Vector2(j, h - c - j), Vector2(j, c + j), Vector2(c + j, j), Vector2(w - c - j, j)]),
		Color(1.0, 0.86, 0.58, 0.45), 1.0, true)
	ci.draw_polyline(PackedVector2Array([Vector2(w - j, c + j), Vector2(w - j, h - c - j), Vector2(w - c - j, h - j), Vector2(c + j, h - j)]),
		Color(0.0, 0.0, 0.0, 0.5), 1.0, true)

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
	# Plan 461 (Codex construction review): a site still being raised shows its
	# live model, never the painting of the finished hall from its data.
	if entity is Building and not entity.is_built and definition.has("command_art"):
		definition = definition.duplicate()
		definition.erase("command_art")
	_apply_definition(definition, entity is Building, String(entity.unit_id) if entity is Unit else "", _landmark_likeness(entity))


## Plan 527: a standing landmark (the Bonfire, the War Drum, the Loom...) is
## built from pieces round a borrowed base model, which it hides. Its card
## showed that borrowed forge or spire. Show what stands on the map instead.
var _whole_focus := false

func _landmark_likeness(entity) -> Node3D:
	if not (entity is Building) or not entity.is_built or not entity.has_node("LandmarkCentrepiece"):
		return null
	var holder := Node3D.new()
	var base := entity.get_node_or_null("MeshRoot") as Node3D
	if base and base.visible:
		holder.add_child(base.duplicate())
	var piece := entity.get_node("LandmarkCentrepiece").duplicate() as Node3D
	# The first two pieces are the plaza disc and its inlay ring; on a card
	# they only made the landmark small. Frame the landmark itself.
	for k in mini(2, piece.get_child_count()):
		var plaza := piece.get_child(0)
		piece.remove_child(plaza)
		plaza.free()
	holder.add_child(piece)
	for body in holder.find_children("*", "CollisionObject3D", true, false):
		body.get_parent().remove_child(body)
		body.free()
	# Pieces made in code have no owner, and the model helpers only measure owned meshes.
	for n in holder.find_children("*", "", true, false):
		n.owner = holder
	return holder


func _apply_definition(definition: Dictionary, is_building: bool, unit_id: String = "", likeness: Node3D = null) -> void:
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
	_whole_focus = false
	if likeness != null and _active_portrait_path.is_empty():
		model = likeness
		_whole_focus = true
	elif likeness != null:
		likeness.free()
		likeness = null
	if model == null and not path.is_empty() and ResourceLoader.exists(path):
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
		if is_building:
			# Frame the body of the building: a model that is not centred on its
			# origin, or carries a small far-off part, was shown as a corner or
			# as a speck.
			var focus := _building_focus(model, target_height)
			model.position -= Vector3(focus.position.x + focus.size.x * 0.5, 0.0, focus.position.z + focus.size.z * 0.5)
			model_radius = maxf(focus.size.x, focus.size.z) * 0.5
		elif bool(definition.get("is_siege", false)):
			# Framed like a building, on its main body: seven of the eight siege
			# engines measured a far larger radius than their frame and sat in
			# the group grid as a speck.
			var focus := _building_focus(model, target_height)
			model.position -= Vector3(focus.position.x + focus.size.x * 0.5, 0.0, focus.position.z + focus.size.z * 0.5)
			model_radius = minf(maxf(focus.size.x, focus.size.z) * 0.5, target_height * 1.2)
		if not is_building:
			Unit._drop_placeholder_armor(model)
			if Unit._model_faces_backwards(model, path):
				model.rotate_y(PI)
			_posed_model = null if bool(definition.get("is_siege", false)) else model
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
	# Every building, also on the small build cards: those fell through to the
	# waist-up unit camera below and showed a piece of roof or wall.
	if is_building:
		# Broad structures need a three-quarter architectural view. A slender
		# tower occupies only a few pixels with that same camera, so let its live
		# model fill the portrait aperture without cropping the roof or footing.
		var narrow_structure := model_radius < target_height * 0.16
		# A stray far-off mesh in a borrowed model gave a huge radius and left
		# the building a speck in its frame (the Ledger Stone): cap the reach.
		distance = 2.3 if narrow_structure else maxf(3.55, minf(model_radius, target_height * 1.4) * 2.2 + 0.5)
		_camera.position = Vector3(distance * (0.34 if narrow_structure else 0.48), target_height * (1.05 if narrow_structure else 1.48), distance)
		_camera.fov = 50.0 if narrow_structure else 58.0
		_camera.look_at(Vector3(0.0, target_height * 0.48, 0.0), Vector3.UP)
		if not compact_card and not narrow_structure:
			# Plan 525: on the large selection card every building filled only
			# about half its frame, a small model in a dark box. Bring the
			# camera in until the building's bounding sphere just fits.
			var reach := minf(model_radius, target_height * 1.4)
			var sphere := 0.5 * sqrt(4.0 * reach * reach * 2.0 + target_height * target_height)
			var fit := sphere / tan(deg_to_rad(_camera.fov * 0.5)) * 0.92
			var aim_l := Vector3(0.0, target_height * 0.48, 0.0)
			var now := (_camera.position - aim_l).length()
			if now > 0.01:
				_camera.position = aim_l + (_camera.position - aim_l) * clampf(fit / now, 0.62, 1.0)
		elif not compact_card:
			# A slim tower stood at two thirds of the frame height: narrow the lens.
			_camera.fov = 41.0
		if compact_card:
			# The same view from closer: at card size the model must fill the frame.
			var aim := Vector3(0.0, target_height * 0.48, 0.0)
			_camera.position = aim + (_camera.position - aim) * (0.8 if narrow_structure else 0.68)
	elif bool(definition.get("is_siege", false)):
		# The whole engine, on the small group card and the large one alike (the
		# waist-up soldier camera showed a crop of beams on the large card).
		distance = maxf(2.4, model_radius * 1.8 + 0.35) * (1.0 if compact_card else 1.12)
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
## The bounds, in the pivot's space, of the building's largest part and of
## every part whose centre lies near it.
func _building_focus(model: Node3D, target_height: float) -> AABB:
	var boxes: Array = []
	var to_pivot := _pivot.global_transform.affine_inverse()
	for child in model.find_children("*", "MeshInstance3D"):
		var part := child as MeshInstance3D
		if part and part.mesh:
			boxes.append((to_pivot * part.global_transform) * part.mesh.get_aabb())
	if boxes.is_empty():
		return AABB(Vector3(-0.5, 0.0, -0.5), Vector3(1.0, target_height, 1.0))
	var body: AABB = boxes[0]
	if _whole_focus:
		# A landmark is a ring or row of separate pieces: frame them all.
		for box in boxes:
			body = body.merge(box)
		return body
	for box in boxes:
		if box.get_volume() > body.get_volume():
			body = box
	var core := body.get_center()
	for box in boxes:
		var c: Vector3 = box.get_center()
		if Vector2(c.x - core.x, c.z - core.z).length() < target_height * 1.2:
			body = body.merge(box)
	return body

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
	_frame_on_head()
	if is_instance_valid(_viewport) and custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD:
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


## Head and shoulders, like the painted portraits. The fixed waist-up camera
## assumed every body stood 1.95 m tall in its bounds, but most models' bounds
## are larger than the figure (arms out, capes, weapons), so a unit stood
## small and whole in a dark frame. With the idle pose in, the camera is aimed
## at the skeleton's head instead. Models without a Head bone keep the fixed
## camera.
func _frame_on_head() -> void:
	if not is_instance_valid(_posed_model) or not is_instance_valid(_camera):
		return
	var skeleton: Skeleton3D = null
	for candidate in _posed_model.find_children("*", "Skeleton3D", true, false):
		skeleton = candidate
		break
	if skeleton == null:
		return
	var head := skeleton.find_bone("Head")
	if head < 0:
		return
	var head_at: Vector3 = skeleton.global_transform * skeleton.get_bone_global_pose(head).origin
	var feet_y := _pivot.global_position.y
	var tall := head_at.y - feet_y
	# A head bone far below the top of the body (the Bowcrusha's sits at half
	# its height) is no face to frame: keep the fixed camera.
	var top := 0.0
	var width := 0.0
	for mi in _posed_model.find_children("*", "MeshInstance3D", true, false):
		var box: AABB = (mi as MeshInstance3D).global_transform * (mi as MeshInstance3D).get_aabb()
		top = maxf(top, box.end.y)
		width = maxf(width, box.size.x)
	if tall < 0.4 or tall < (top - feet_y) * 0.7:
		return
	var compact := custom_minimum_size.x < PORTRAIT_COMPACT_THRESHOLD
	# Frame from just above the head down to the chest (the belt, large):
	# span is half the height shown.
	var span := tall * (0.24 if compact else 0.32)
	# Hulking bodies (the Ironmaw Grunt and Ogre: half again as wide as they
	# are tall, every other model about square) hunch their faces in front of
	# huge shoulders; a head-and-chest crop showed an ear and a pauldron.
	# Widen to the whole upper body.
	var bulk := width / maxf(top - feet_y, 0.01)
	if bulk > 1.25:
		span *= minf(bulk * bulk, 2.4)
	var aim := head_at - Vector3(0.0, span * 0.22, 0.0)
	var distance := span / tan(deg_to_rad(_camera.fov * 0.5))
	_camera.global_position = Vector3(head_at.x, aim.y + span * 0.1, head_at.z + distance)
	_camera.look_at(aim, Vector3.UP)


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
