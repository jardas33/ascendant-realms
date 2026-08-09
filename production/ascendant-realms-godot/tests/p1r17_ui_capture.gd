extends Node
## P1-R17 headed proof: existing menu information architecture with shared UI theme.

var _output := ""
var _width := 1920
var _height := 1080
var _frames: Array = []
var _failures: Array = []
var _scenes := {
	"SKIRMISH_SETUP": "res://scenes/ui/skirmish_setup.tscn",
	"HERO_PROFILE": "res://scenes/ui/hero_sheet.tscn",
	"SETTINGS": "res://scenes/ui/settings.tscn",
}

func _ready() -> void:
	call_deferred("_begin")

func _begin() -> void:
	_output = OS.get_environment("ASCENDANT_P1R17_OUTPUT")
	_width = maxi(1, int(OS.get_environment("ASCENDANT_P1R17_WIDTH")))
	_height = maxi(1, int(OS.get_environment("ASCENDANT_P1R17_HEIGHT")))
	DirAccess.make_dir_recursive_absolute(_output)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_width, _height))
	for label in _scenes:
		get_tree().change_scene_to_file(_scenes[label])
		var deadline := Time.get_ticks_msec() + 20000
		while Time.get_ticks_msec() < deadline and get_tree().current_scene == null:
			await get_tree().process_frame
		for _i in 14: await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image := get_viewport().get_texture().get_image()
		if image == null or image.is_empty():
			_failures.append(label + ":empty_frame")
			continue
		var sampled := {}
		for sx in range(0, image.get_width(), maxi(1, image.get_width() / 12)):
			for sy in range(0, image.get_height(), maxi(1, image.get_height() / 8)):
				var c := image.get_pixel(sx, sy)
				sampled["%d,%d,%d" % [int(c.r * 12.0), int(c.g * 12.0), int(c.b * 12.0)]] = true
		if sampled.size() < 8: _failures.append(label + ":blank_or_low_variance_frame")
		var path := _output.path_join("%s_%dx%d.png" % [label, _width, _height])
		image.save_png(path)
		_frames.append({"name":label, "png":path, "width":image.get_width(), "height":image.get_height()})
	_write_manifest()
	get_tree().quit(0 if _failures.is_empty() else 1)

func _write_manifest() -> void:
	var file := FileAccess.open(_output.path_join("ui-manifest.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"schema":"ascendant-realms-p1r17-ui-v1", "source_sha":OS.get_environment("ASCENDANT_P1R17_SOURCE_SHA"), "resolution":{"width":_width,"height":_height}, "frames":_frames, "failures":_failures, "pass":_failures.is_empty()}, "  "))
		file.store_line("")
