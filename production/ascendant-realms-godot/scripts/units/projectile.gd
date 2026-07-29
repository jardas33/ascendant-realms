class_name Projectile
extends Node3D
## Simple homing/ballistic projectile. Pooled-free: frees on impact.

var target = null
var target_pos: Vector3
var speed: float = 24.0
var damage: float = 10.0
var dmg_type: String = "pierce"
var team: int = 0
var splash: float = 0.0
var world = null
var kind: String = "arrow"
var _alive_time := 0.0

var _mesh: MeshInstance3D

func setup(from: Vector3, tgt, dmg: float, dtype: String, p_team: int, p_world, p_kind: String, p_splash: float = 0.0) -> void:
	global_position = from
	target = tgt
	damage = dmg
	dmg_type = dtype
	team = p_team
	world = p_world
	kind = p_kind
	splash = p_splash
	if is_instance_valid(tgt):
		target_pos = tgt.global_position + Vector3.UP * 0.8

func _ready() -> void:
	_build_visual()

func _build_visual() -> void:
	_mesh = MeshInstance3D.new()
	var col := Color(0.9, 0.85, 0.5)
	var m: Mesh
	match kind:
		"arrow", "bolt", "thorn":
			var cap := CylinderMesh.new()
			cap.top_radius = 0.04
			cap.bottom_radius = 0.04
			cap.height = 0.7
			m = cap
			col = Color(0.8, 0.7, 0.45) if kind != "thorn" else Color(0.5, 0.8, 0.5)
			_mesh.rotation_degrees.x = 90.0
		"cinder", "void_bolt", "lume_bolt", "rift_shell", "thornpod", "cannon":
			var sp := SphereMesh.new()
			sp.radius = 0.22
			sp.height = 0.44
			m = sp
			match kind:
				"cinder": col = Color(1.0, 0.5, 0.15)
				"void_bolt", "rift_shell": col = Color(0.7, 0.3, 0.9)
				"lume_bolt": col = Color(1.0, 0.85, 0.4)
				"thornpod": col = Color(0.5, 0.75, 0.4)
		_:
			var sp2 := SphereMesh.new()
			sp2.radius = 0.15
			m = sp2
	_mesh.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.emission_enabled = true
	mat.emission = col
	mat.emission_energy_multiplier = 2.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_mesh.material_override = mat
	add_child(_mesh)
	# glow light for magic
	if kind in ["cinder", "void_bolt", "lume_bolt", "rift_shell"]:
		var l := OmniLight3D.new()
		l.light_color = col
		l.light_energy = 2.0
		l.omni_range = 4.0
		add_child(l)

func _physics_process(delta: float) -> void:
	_alive_time += delta
	if _alive_time > 5.0:
		queue_free()
		return
	if is_instance_valid(target) and not target.is_dead:
		target_pos = target.global_position + Vector3.UP * 0.8
	var to := target_pos - global_position
	var dist := to.length()
	var step := speed * delta
	if dist <= step or dist < 0.4:
		_impact()
		return
	global_position += to.normalized() * step
	look_at(target_pos, Vector3.UP)

func _impact() -> void:
	if world and world.has_method("projectile_impact"):
		world.projectile_impact(global_position, target, damage, dmg_type, team, splash, kind)
	queue_free()
