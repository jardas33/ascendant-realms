extends Node

const KIT_PATH := "res://assets/v0233/salto_modular_environment_kit.glb"

func _ready() -> void:
	if get_tree().current_scene == self:
		call_deferred("start")

func start() -> void:
	var root := _artifact_root_from_args()
	DirAccess.make_dir_recursive_absolute(root)
	var report := {
		"schemaVersion": 1,
		"checkpoint": "v0.233",
		"status": "BLOCKED_FOR_LOCAL_BLENDER_EXPORT",
		"blenderAvailable": false,
		"actualGlbPresent": false,
		"actualGlbImported": false,
		"kitPath": KIT_PATH,
		"contractPath": "res://assets/v0233/salto_modular_environment_kit.contract.json",
		"isolatedScene": "res://scenes/salto_blender_modular_kit_spike.tscn",
		"importerScaffoldMethod": "_import_authored_kit",
		"defaultLauncherChanged": false,
		"browserRuntimeChanged": false,
		"gameplayChanged": false,
		"saveChanged": false,
		"pathingChanged": false,
		"collisionChanged": false,
		"newRuntimeArtSlots": 0,
		"generatedAiImages": 0,
		"downloadedAssets": 0,
		"errors": ["Blender-authored GLB was not produced because Blender CLI is unavailable."]
	}
	var file := FileAccess.open(root.path_join("v0233-blender-modular-kit-runtime.json"), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "  "))
	get_tree().quit(0)

func _import_authored_kit() -> Node:
	# Invoked only after the checked-in Blender export exists.
	var packed := load(KIT_PATH) as PackedScene
	if packed == null:
		return null
	var instance := packed.instantiate()
	instance.name = "V0233BlenderModularEnvironmentKit"
	add_child(instance)
	return instance

func _artifact_root_from_args() -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--artifact-root="):
			return arg.trim_prefix("--artifact-root=")
	return ProjectSettings.globalize_path("user://v0233-blender-modular-kit")
