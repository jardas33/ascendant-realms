extends Node3D
## A vein between the bases (docs/claude/RESOURCE_DESIGN.md): gold, granite,
## old-growth timber or a terraced farm. A worker raises an outpost on it;
## workers sent inside the outpost draw from it in safety. When the outpost
## falls the vein is free again. A vein is rich but not bottomless.

var kind := "gold"
var amount := 4000
var outpost = null          # the Building standing on it, if any
var rich_until := 0.0       # match time a Lume flare (double output) lasts until
var _ring: MeshInstance3D
var _ring_mat: StandardMaterial3D

const KIND_COLORS := {"gold": Color(1.0, 0.78, 0.3), "stone": Color(0.75, 0.78, 0.82), "timber": Color(0.55, 0.85, 0.4), "food": Color(0.98, 0.86, 0.45)}
const MODELS := {
	"timber": "res://assets/props/misc/resource_timber_stack.glb",
	"stone": "res://assets/props/misc/resource_stone_quarry_chunk.glb",
	"gold": "res://assets/props/misc/resource_gold_vein.glb",
	"food": "res://assets/props/misc/resource_harvest_grain.glb",
}
const NAMES := {"gold": "Gold vein", "stone": "Granite quarry", "timber": "Old-growth grove", "food": "Terraced farm"}

func configure(p_kind: String, p_amount: int) -> void:
	kind = p_kind
	amount = p_amount
	add_to_group("veins")
	var path := String(MODELS.get(kind, ""))
	if path != "" and ResourceLoader.exists(path):
		var m = load(path).instantiate()
		add_child(m)
		ModelUtils.scale_to_height(m, 2.4 if kind != "food" else 1.8)
		ModelUtils.ground_model(m)
		m.position += Vector3(3.2, 0, 0)
	# A slowly turning rune ring marks an unclaimed vein in its resource's colour.
	_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 3.45
	torus.outer_radius = 3.6
	torus.rings = 32
	torus.ring_segments = 4
	_ring.mesh = torus
	_ring_mat = StandardMaterial3D.new()
	_ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_ring_mat.albedo_color = Color(KIND_COLORS.get(kind, Color.WHITE), 0.35)
	_ring.material_override = _ring_mat
	_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_ring.position.y = 0.08
	add_child(_ring)

func display_name() -> String:
	return String(NAMES.get(kind, "Vein"))

func is_free() -> bool:
	return not is_instance_valid(outpost) or outpost.is_dead

func _process(delta: float) -> void:
	if is_instance_valid(_ring):
		_ring.rotation.y += delta * 0.25
		var flaring := false
		var w = get_parent()
		if w and w.get("match_time") != null:
			flaring = float(w.get("match_time")) < rich_until
		_ring.visible = (is_free() or flaring) and amount > 0
		_ring_mat.albedo_color = Color(1.0, 0.85, 0.35, 0.9) if flaring else Color(KIND_COLORS.get(kind, Color.WHITE), 0.35)

## Take up to `want` from the vein (it runs dry eventually).
func draw(want: int) -> int:
	var got := mini(want, amount)
	amount -= got
	return got
