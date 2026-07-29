extends "res://scripts/v0331_barrosan_house_02_review.gd"

# v0.332 keeps the accepted v0.331 capture implementation but gives the truth
# pass its own opt-in scene, manifest, artifact root and benchmark record.
# No gameplay scene or state system is referenced here.

func _artifact_root_from_args() -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--artifact-root="):
			return argument.trim_prefix("--artifact-root=")
	return OS.get_environment("V0332_ARTIFACT_ROOT")


func _measure_benchmark() -> void:
	await super._measure_benchmark()
	var source := capture_root.path_join("v0331-benchmark.json")
	var target := capture_root.path_join("v0332-benchmark.json")
	if FileAccess.file_exists(source):
		DirAccess.copy_absolute(source, target)


func _write_manifest_v331() -> void:
	var file := FileAccess.open(capture_root.path_join("v0332-house02-visual-truth-runtime.json"), FileAccess.WRITE)
	if file != null:
		var manifest := {"schemaVersion": 3, "checkpoint": "v0.332", "status": "REJECTED_V0332_HOUSE02_VISUAL_TRUTH" if errors.is_empty() else "FAIL_V0332_HOUSE02_VISUAL_TRUTH", "outcome": "REJECTED INTERNALLY - GRANITE, SLATE, ROOF OR EVIDENCE TRUTH GATE FAILED", "prototypeOptIn": true, "sourceBlend": "art-source/blender/v0330/barrosan_house_gold_02.blend", "sourceGLB": GLB, "sourceGLBHash": OS.get_environment("V0332_GLB_SHA"), "scenePath": "res://scenes/review/V0332BarrosanHouse02VisualTruth.tscn", "documentaryPath": "Path A - exterior-stair archetype", "documentaryRegister": "art-source/references/v0331/documentary/README.md", "moodTargetSeparated": true, "noGameplay": true, "noMovement": true, "noPathfinding": true, "noCombat": true, "noEconomy": true, "noResources": true, "house01Imported": false, "trueWireframeCapture": true, "isolatedCollisionCapture": true, "actualOrthographicCamera": true, "humanReviewRequired": true, "captures": captures, "errors": errors}
		file.store_string(JSON.stringify(manifest, "  "))
