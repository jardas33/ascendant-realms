extends Node
## v0.436-R1D headed-startup evidence hook. Inert unless explicitly opted in.

var active := false
var frame_count := 0

func _ready() -> void:
	active = OS.get_environment("ASCENDANT_V0436_R1D_STARTUP_CAPTURE") == "1"
	if not active:
		set_process(false)
		return
	print("R1D_STARTUP_CAPTURE_ARMED")

func _process(_delta: float) -> void:
	if not active:
		return
	frame_count += 1
	if frame_count >= 60:
		active = false
		set_process(false)
		call_deferred("_capture_frame")

func _capture_frame() -> void:
	await RenderingServer.frame_post_draw
	var viewport := get_viewport()
	var image := viewport.get_texture().get_image()
	var output_path := OS.get_environment("R1D_PRODUCTION_CAPTURE_OUTPUT")
	var audit_path := OS.get_environment("R1D_PRODUCTION_CAPTURE_AUDIT")
	var samples := []
	for point in [Vector2i(1, 1), Vector2i(image.get_width() / 2, image.get_height() / 2), Vector2i(image.get_width() - 2, image.get_height() - 2)]:
		if point.x >= 0 and point.y >= 0 and point.x < image.get_width() and point.y < image.get_height():
			var color := image.get_pixelv(point)
			samples.append({"x": point.x, "y": point.y, "r": color.r, "g": color.g, "b": color.b, "a": color.a})
	var saved := image.save_png(output_path) == OK if not output_path.is_empty() else false
	var scene := get_tree().current_scene
	var audit := {
		"schema": "v0436-r1d-headed-production-frame-v1",
		"status": "FRAME_CAPTURED" if saved else "FRAME_SAVE_FAILED",
		"frame_count": frame_count,
		"scene": scene.scene_file_path if scene else "",
		"viewport": {"width": image.get_width(), "height": image.get_height()},
		"samples": samples,
		"saved": saved,
		"timestamp": Time.get_datetime_string_from_system(true)
	}
	if not audit_path.is_empty():
		var file := FileAccess.open(audit_path, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(audit, "  "))
			file.store_line("")
	print("R1D_PRODUCTION_FRAME ", JSON.stringify(audit))
	if OS.get_environment("R1D_QUIT_AFTER_CAPTURE") == "1":
		get_tree().quit(0)
