class_name GranitbornBuildingPresentation
extends Node3D
## R59 review-only source set. Stable building IDs and rules stay in BuildingDefs.
## Effects follow the real building lifecycle; this is not a late visual swap.

const HOLD := "res://assets/environment/buildings/codex_r56/castro_hold.glb"
const HOUSE := "res://assets/environment/buildings/codex_r57/roundhouse.glb"
const FORGE := "res://assets/environment/buildings/codex_r58/forge.glb"
var _particles: Array[GPUParticles3D] = []
var _active := false

static func owns_model(path: String) -> bool:
	return path in [HOLD, HOUSE, FORGE]

static func make_forge_effects(model: Node3D) -> GranitbornBuildingPresentation:
	var hearths := model.find_children("R58_HearthOutlet*", "Node3D", true, false)
	var chimneys := model.find_children("R58_ChimneyOutlet*", "Node3D", true, false)
	if hearths.size() != 1 or chimneys.size() != 1:
		push_error("Castro Forge requires one hearth and one chimney anchor")
		return null
	var effects := GranitbornBuildingPresentation.new()
	effects.name = "CastroForgeEffects"
	model.add_child(effects)
	var factory := BrazierFire.new()
	factory.flame_scale = 1.0
	var flame := factory._make_flame()
	factory.free()
	flame.name = "ForgeHearthFlame"
	flame.emitting = false
	effects.add_child(flame)
	flame.position = effects.to_local((hearths[0] as Node3D).global_position)
	var smoke := ChimneySmoke.new()
	smoke.name = "ForgeChimneySmoke"
	smoke.emitting = false
	effects.add_child(smoke)
	smoke.position = effects.to_local((chimneys[0] as Node3D).global_position)
	smoke.scale = Vector3.ONE * 0.63
	effects._particles.assign([flame, smoke])
	effects.visible = false
	return effects

func set_active(active: bool) -> void:
	if _active == active:
		return
	_active = active
	visible = active
	for particle in _particles:
		if is_instance_valid(particle):
			particle.emitting = active
