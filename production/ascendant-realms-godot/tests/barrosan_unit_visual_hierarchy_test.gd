extends SceneTree

const TARGETS := {
	"barrosan_worker": {"visual_scale": 0.90, "height": 1.8, "model": "res://assets/characters/barrosan_highlander_worker/barrosan_highlander_worker.glb"},
	"barrosan_spear_guard": {"visual_scale": 1.0, "height": 1.85, "model": "res://assets/characters/barrosan_spear_guard/barrosan_spear_guard.glb"},
	"barrosan_hero_thane": {"visual_scale": 1.13, "height": 2.0, "model": "res://assets/characters/barrosan_hero_thane/barrosan_hero_thane.glb"},
}

func _initialize() -> void:
	var defs_script = load("res://scripts/game/unit_defs.gd")
	if defs_script == null:
		_fail("unit_defs.gd did not load")
		return
	var defs: Dictionary = defs_script.get_all()
	for id in TARGETS:
		if not defs.has(id):
			_fail("missing canonical target: %s" % id)
			return
		var def: Dictionary = defs[id]
		var expected: Dictionary = TARGETS[id]
		if not is_equal_approx(float(def.get("visual_scale", -1.0)), float(expected["visual_scale"])):
			_fail("unexpected visual scale for %s" % id)
			return
		if not is_equal_approx(float(def.get("height", -1.0)), float(expected["height"])):
			_fail("gameplay height changed for %s" % id)
			return
		if str(def.get("model", "")) != str(expected["model"]):
			_fail("canonical model changed for %s" % id)
			return
		if not ResourceLoader.exists(str(expected["model"])):
			_fail("canonical model missing for %s" % id)
			return
	print("G1C-A1 PASS canonical Barrosan visual hierarchy definitions and model paths")
	quit(0)

func _fail(message: String) -> void:
	push_error("G1C-A1 FAIL " + message)
	quit(1)
