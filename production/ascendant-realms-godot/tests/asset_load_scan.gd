extends SceneTree

const ROOT := "res://"
const EXTENSIONS := ["glb", "tres", "tscn", "png", "jpg", "jpeg", "webp", "mp3", "ttf", "gdshader"]

var records: Array = []
var failures: Array = []

func _init() -> void:
	_scan(ROOT)
	var loaded_count := 0
	for item in records:
		if item.loaded:
			loaded_count += 1
	var output := {
		"schema": "v0430-godot-asset-load-scan-v1",
		"generated_at": Time.get_datetime_string_from_system(true),
		"attempted": records.size(),
		"loaded": loaded_count,
		"failed": failures.size(),
		"failures": failures,
		"records": records
	}
	var file := FileAccess.open("user://v0430-asset-load-scan.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(output, "  "))
	print(JSON.stringify(output))
	quit()

func _scan(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var name := dir.get_next()
		if name.is_empty():
			break
		if name.begins_with(".") or name == "user":
			continue
		var full := dir_path.path_join(name)
		if dir.current_is_dir():
			_scan(full)
		elif name.get_extension().to_lower() in EXTENSIONS:
			var resource = ResourceLoader.load(full, "", ResourceLoader.CACHE_MODE_IGNORE)
			var loaded := resource != null
			records.append({"path": full, "loaded": loaded, "type": resource.get_class() if resource else "null"})
			if not loaded:
				failures.append(full)
	dir.list_dir_end()
