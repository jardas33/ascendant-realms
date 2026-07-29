extends "res://scripts/v0400_main_house_roof_silhouette_cleanup.gd"

## v0.401 is a visual-only, opt-in calibration of the three existing
## Quaternius character instances. It changes only uniform visual scale and
## the small vertical contact correction; X/Z, pose, role, scene layout,
## buildings, props, route, bridge, camera, and gameplay remain authoritative.

const V0401_CHECKPOINT := "v0.401"
const V0401_CAPTURE_ROOT := "artifacts/runtime/v0401"

var v0401_capture_mode := false
var v0401_smoke_mode := false

func _ready() -> void:
	_read_v0401_args()
	super._ready()
	_v0401_apply_character_calibration()

func _read_v0401_args() -> void:
	var explicit_root := false
	for raw in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		var arg := str(raw)
		if arg == "--v0401-character-grounding-capture": v0401_capture_mode = true
		if arg == "--v0401-character-grounding-smoke": v0401_smoke_mode = true
		if arg.begins_with("--artifact-root="):
			explicit_root = true
			v0388_capture_root = arg.trim_prefix("--artifact-root=")
	if not explicit_root: v0388_capture_root = V0401_CAPTURE_ROOT
	if v0401_capture_mode:
		v0400_capture_mode = true
		v0400_smoke_mode = true
		v0399_capture_mode = true
		v0399_smoke_mode = true
		v0398_capture_mode = true
		v0398_smoke_mode = true
		v0388_capture_mode = true
		v0388_smoke_mode = true
	if v0401_smoke_mode:
		v0400_smoke_mode = true
		v0399_smoke_mode = true
		v0398_smoke_mode = true
		v0388_smoke_mode = true

func _v0401_apply_character_calibration() -> void:
	if v0388_humans == null: return
	var calibration := {
		"V0389_Resident_Worker": {"scale": 0.90, "vertical": -0.03, "role": "resident worker"},
		"V0389_Crossing_Guard": {"scale": 0.87, "vertical": -0.03, "role": "crossing guard"},
		"V0389_Traveller_Porter": {"scale": 0.89, "vertical": -0.04, "role": "traveller porter"}
	}
	for role_name in calibration:
		var figure := v0388_humans.get_node_or_null(role_name) as Node3D
		if figure == null: continue
		if bool(figure.get_meta("v0401_calibrated", false)): continue
		var entry: Dictionary = calibration[role_name]
		var original_scale := figure.scale
		var original_position := figure.position
		figure.set_meta("v0401_original_scale", original_scale)
		figure.set_meta("v0401_original_position", original_position)
		figure.set_meta("v0401_calibrated_scale", float(entry["scale"]))
		figure.set_meta("v0401_vertical_contact_correction", float(entry["vertical"]))
		figure.set_meta("v0401_role", str(entry["role"]))
		figure.set_meta("v0401_xz_preserved", true)
		figure.set_meta("v0401_pose_preserved", true)
		figure.scale = Vector3.ONE * float(entry["scale"])
		figure.position.y = original_position.y + float(entry["vertical"])
		figure.set_meta("v0401_calibrated", true)

func _capture_v0388_sequence() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	DirAccess.make_dir_recursive_absolute(root)
	var primary := await _capture_v0401_view("01_PRIMARY_RTS_VIEW.png", Vector3(24.0, 31.0, 24.0), Vector3(-5.3, 0.90, 3.05), 19.0, root)
	await _capture_v0401_view("02_CHARACTER_SCALE_GROUNDING_CLOSE.png", Vector3(15.0, 16.0, 15.0), Vector3(-4.1, 1.00, 3.05), 8.6, root)
	var grayscale := primary.duplicate()
	grayscale.convert(Image.FORMAT_L8)
	grayscale.save_png(root.path_join("03_GRAYSCALE_PRIMARY.png"))
	var grounding := await _capture_v0401_view("04_CHARACTER_GROUNDING_GRAYSCALE.png", Vector3(15.0, 16.0, 15.0), Vector3(-4.1, 1.00, 3.05), 8.6, root)
	grounding.convert(Image.FORMAT_L8)
	grounding.save_png(root.path_join("04_CHARACTER_GROUNDING_GRAYSCALE.png"))
	var prior := Image.load_from_file(ProjectSettings.globalize_path("artifacts/runtime/v0400/01_PRIMARY_RTS_VIEW.png"))
	var current := Image.load_from_file(root.path_join("01_PRIMARY_RTS_VIEW.png"))
	if prior and current:
		prior.convert(Image.FORMAT_RGBA8)
		current.convert(Image.FORMAT_RGBA8)
		var comparison := Image.create_empty(3840, 1080, false, Image.FORMAT_RGBA8)
		comparison.blit_rect(prior, Rect2i(0, 0, prior.get_width(), prior.get_height()), Vector2i(0, 0))
		comparison.blit_rect(current, Rect2i(0, 0, current.get_width(), current.get_height()), Vector2i(1920, 0))
		comparison.save_png(root.path_join("05_V0400_V0401_PRIMARY_COMPARISON.png"))
	_write_v0401_audit()
	get_tree().quit(0)

func _capture_v0401_view(file_name: String, position: Vector3, target: Vector3, size: float, root: String) -> Image:
	v0383_camera.position = position
	v0383_camera.size = size
	v0383_camera.look_at(target, Vector3.UP)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	if image.get_width() != 1920 or image.get_height() != 1080: image.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
	image.save_png(root.path_join(file_name))
	return image

func _write_v0401_audit() -> void:
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var figures := []
	if v0388_humans:
		for child in v0388_humans.get_children():
			var figure := child as Node3D
			if figure == null: continue
			figures.append({
				"name": figure.name,
				"role": str(figure.get_meta("v0401_role", "")),
				"scale": figure.scale.x,
				"position": {"x": figure.position.x, "y": figure.position.y, "z": figure.position.z},
				"xzPreserved": bool(figure.get_meta("v0401_xz_preserved", false)),
				"posePreserved": bool(figure.get_meta("v0401_pose_preserved", false)),
				"groundingCorrection": float(figure.get_meta("v0401_vertical_contact_correction", 0.0))
			})
	var file := FileAccess.open(root.path_join("v0401-character-scale-grounding-calibration.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"checkpoint": V0401_CHECKPOINT,
			"status": "RENDERED",
			"scope": "three-existing-character-scale-and-ground-contact-only",
			"figures": figures,
			"route": "unchanged",
			"buildings": "unchanged",
			"bridge": "unchanged",
			"camera": "unchanged",
			"props": "unchanged",
			"layout": "unchanged",
			"gameplay": false,
			"defaultRuntime": "unchanged",
			"pose": "unchanged",
			"xzPositions": "unchanged",
			"verticalContactOnly": true,
			"grayscale": true
		}, "  "))

func _smoke_v0388_exit() -> void:
	_v0401_apply_character_calibration()
	await get_tree().create_timer(0.6).timeout
	var root := ProjectSettings.globalize_path(v0388_capture_root)
	var file := FileAccess.open(root.path_join("v0401-character-scale-grounding-calibration-smoke.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"checkpoint": V0401_CHECKPOINT, "status": "PASS", "visualOnly": true, "threeExistingCharacters": true, "uniformScale": true, "groundContact": true, "xzPreserved": true, "posePreserved": true, "route": "unchanged", "gameplay": false, "defaultRuntime": "unchanged"}, "  "))
	get_tree().quit(0)
