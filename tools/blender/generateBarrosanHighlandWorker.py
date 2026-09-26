"""Rebuild the Barrosan Highland Worker body on its existing rig.

Run: blender -b --factory-startup --python make_barrosan_worker.py -- <in_worker.glb> <out_worker.glb> [preview.png]

Keeps the imported armature, bone names and all six actions untouched and
replaces only the blocky box body with a modelled highland labourer: wool
tunic with a belted kilt hem, tartan shoulder plaid, leather apron, rolled
sleeves, bearded head under a wool bonnet, trousers and turned-down boots.
Skinning is computed from distance to each part's candidate bone segments,
so the mesh follows the existing Idle/Walk/Gather/Hammer/Carry/Death clips.
"""
import math
import sys

import bmesh
import bpy
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:]
IN_GLB, OUT_GLB = argv[0], argv[1]
PREVIEW = argv[2] if len(argv) > 2 else ""

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=IN_GLB)
arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
old = next(o for o in bpy.data.objects if o.type == "MESH" and o.parent == arm)
body_name = old.name
bpy.data.objects.remove(old, do_unlink=True)

# Reset to rest pose so bone positions are the A-pose the mesh is built in.
arm.data.pose_position = "REST"
BONES = {b.name: (arm.matrix_world @ b.head_local, arm.matrix_world @ b.tail_local) for b in arm.data.bones}


def P(name, t):
    h, tl = BONES[name]
    return h.lerp(tl, t)


# ------------------------------------------------------------- materials
def mat(name, color, rough=0.85, image=None):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Roughness"].default_value = rough
    if image is None:
        bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    else:
        tex = m.node_tree.nodes.new("ShaderNodeTexImage")
        tex.image = image
        tex.interpolation = "Closest"
        m.node_tree.nodes["Principled BSDF"].inputs["Roughness"].default_value = rough
        m.node_tree.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    return m


def tartan_image():
    size = 64
    img = bpy.data.images.new("BarrosanClanTartan", size, size)
    # Muted highland sett: moss green ground, slate blue bands, rust over-check.
    stripes = [(0, 14, (0.30, 0.38, 0.22)), (14, 22, (0.20, 0.27, 0.40)), (22, 24, (0.66, 0.24, 0.10)),
               (24, 38, (0.30, 0.38, 0.22)), (38, 46, (0.20, 0.27, 0.40)), (46, 48, (0.78, 0.72, 0.52)),
               (48, 64, (0.14, 0.18, 0.12))]

    def band(i):
        for a, b, c in stripes:
            if a <= i < b:
                return c
        return stripes[-1][2]

    px = []
    for y in range(size):
        for x in range(size):
            cx, cy = band(x), band(y)
            # twill: alternate warp and weft on a diagonal
            c = cx if (x + y) % 4 < 2 else cy
            px.extend((c[0], c[1], c[2], 1.0))
    img.pixels = px
    img.pack()
    return img


M_TUNIC = mat("Barrosan_Wool_Tunic", (0.085, 0.022, 0.010), 0.95)
M_TROUSER = mat("Barrosan_Wool_Trews", (0.055, 0.050, 0.040), 0.95)
M_PLAID = mat("Barrosan_Clan_Plaid", (1, 1, 1), 0.95, tartan_image())
M_LEATHER = mat("Barrosan_Dark_Leather", (0.060, 0.030, 0.016), 0.7)
M_APRON = mat("Barrosan_Work_Apron", (0.13, 0.075, 0.040), 0.8)
M_SKIN = mat("Barrosan_Weathered_Skin", (0.30, 0.15, 0.085), 0.7)
M_HAIR = mat("Barrosan_Beard", (0.14, 0.055, 0.020), 0.9)
M_BONNET = mat("Barrosan_Wool_Bonnet", (0.030, 0.045, 0.080), 0.95)
M_IRON = mat("Barrosan_Buckle_Iron", (0.20, 0.19, 0.17), 0.5)
MATS = [M_TUNIC, M_TROUSER, M_PLAID, M_LEATHER, M_APRON, M_SKIN, M_HAIR, M_BONNET, M_IRON]
MI = {m.name: i for i, m in enumerate(MATS)}

bm = bmesh.new()
deform = bm.verts.layers.deform.verify()
part_bones = []  # (vert list, candidate bones)


def add_part(verts, faces_mat, bones):
    # Keep indices, not BMVert refs: later bmesh ops can invalidate wrappers.
    bm.verts.index_update()
    part_bones.append(([v.index for v in verts], bones))
    for f, m in faces_mat:
        f.material_index = MI[m.name]


def loft(rings, material, bones, cap_top=True, cap_bottom=True, seg=12):
    """rings: list of (center Vector, rx, ry, [tilt]) bottom->top; ellipses in XY."""
    verts_rings = []
    for c, rx, ry in rings:
        ring = []
        for i in range(seg):
            a = i / seg * math.tau
            ring.append(bm.verts.new(c + Vector((math.cos(a) * rx, math.sin(a) * ry, 0.0))))
        verts_rings.append(ring)
    faces = []
    for r0, r1 in zip(verts_rings, verts_rings[1:]):
        for i in range(seg):
            j = (i + 1) % seg
            faces.append(bm.faces.new((r0[i], r0[j], r1[j], r1[i])))
    if cap_bottom:
        faces.append(bm.faces.new(list(reversed(verts_rings[0]))))
    if cap_top:
        faces.append(bm.faces.new(verts_rings[-1]))
    add_part([v for r in verts_rings for v in r], [(f, material) for f in faces], bones)
    return verts_rings


def tube(points, radii, material, bones, seg=10, cap=True):
    """Tube along an arbitrary polyline (limbs)."""
    rings = []
    for k, (p, r) in enumerate(zip(points, radii)):
        d = (points[min(k + 1, len(points) - 1)] - points[max(k - 1, 0)]).normalized()
        up = Vector((0, 1, 0)) if abs(d.y) < 0.9 else Vector((1, 0, 0))
        u = d.cross(up).normalized()
        v = d.cross(u).normalized()
        ring = [bm.verts.new(p + (u * math.cos(i / seg * math.tau) + v * math.sin(i / seg * math.tau)) * r) for i in range(seg)]
        rings.append(ring)
    faces = []
    for r0, r1 in zip(rings, rings[1:]):
        for i in range(seg):
            j = (i + 1) % seg
            faces.append(bm.faces.new((r0[i], r0[j], r1[j], r1[i])))
    if cap:
        faces.append(bm.faces.new(list(reversed(rings[0]))))
        faces.append(bm.faces.new(rings[-1]))
    add_part([v for r in rings for v in r], [(f, material) for f in faces], bones)


def blob(center, size, material, bones, sub=2, squash_below=None):
    g = bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1.0)
    for v in g["verts"]:
        co = Vector((v.co.x * size.x, v.co.y * size.y, v.co.z * size.z))
        if squash_below is not None and co.z < squash_below:
            co.z = squash_below + (co.z - squash_below) * 0.35
        v.co = co + center
    faces = {f for v in g["verts"] for f in v.link_faces}
    add_part(g["verts"], [(f, material) for f in faces], bones)


def box(center, size, material, bones):
    g = bmesh.ops.create_cube(bm, size=1.0)
    for v in g["verts"]:
        v.co = Vector((v.co.x * size.x, v.co.y * size.y, v.co.z * size.z)) + center
    faces = {f for v in g["verts"] for f in v.link_faces}
    add_part(g["verts"], [(f, material) for f in faces], bones)


# ------------------------------------------------------------- body
V = Vector
# Torso: hips to shoulders, broad labourer's chest.
loft([(V((0, 0.0, 0.84)), 0.185, 0.125), (V((0, 0.0, 0.98)), 0.175, 0.12), (V((0, -0.005, 1.18)), 0.195, 0.13),
      (V((0, -0.01, 1.34)), 0.215, 0.14), (V((0, 0.0, 1.46)), 0.20, 0.12), (V((0, 0.0, 1.52)), 0.09, 0.075)],
     M_TUNIC, ["Hips", "Spine", "Chest"], seg=16)
# Belted kilt hem of the tunic flaring over the thighs.
loft([(V((0, 0.0, 0.62)), 0.235, 0.175), (V((0, 0.0, 0.80)), 0.205, 0.145), (V((0, 0.0, 0.95)), 0.185, 0.128)],
     M_TUNIC, ["Hips", "LeftUpperLeg", "RightUpperLeg"], cap_top=False, cap_bottom=False, seg=16)
# Broad leather belt with an iron buckle.
loft([(V((0, 0.0, 0.93)), 0.192, 0.133), (V((0, 0.0, 1.0)), 0.188, 0.13)], M_LEATHER, ["Hips", "Spine"], seg=16)
box(V((0, -0.135, 0.965)), V((0.07, 0.02, 0.055)), M_IRON, ["Hips"])
# Work apron hanging from the belt.
box(V((0, -0.14, 0.78)), V((0.24, 0.02, 0.32)), M_APRON, ["Hips", "LeftUpperLeg", "RightUpperLeg"])
# Tartan plaid: a continuous sash from the left shoulder across the chest to the
# right hip, returning across the back, UV-mapped so the sett reads.
uv_layer = bm.loops.layers.uv.verify()


def torso_r(z):
    prof = [(0.84, 0.185, 0.125), (0.98, 0.175, 0.12), (1.18, 0.195, 0.13), (1.34, 0.215, 0.14), (1.46, 0.20, 0.12)]
    z = max(prof[0][0], min(prof[-1][0], z))
    for (z0, x0, y0), (z1, x1, y1) in zip(prof, prof[1:]):
        if z0 <= z <= z1:
            t = (z - z0) / (z1 - z0)
            return x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    return prof[-1][1], prof[-1][2]


def sash_side(sign):
    n = 12
    left, right = [], []
    for k in range(n + 1):
        t = k / n
        z = 1.47 + (0.93 - 1.47) * t
        x = -0.15 + 0.32 * t
        rx, ry = torso_r(z)
        # sit the band just proud of the elliptical torso surface
        yy = sign * (ry * math.sqrt(max(0.0, 1.0 - min(1.0, (x / (rx + 0.02)) ** 2))) + 0.022)
        d = Vector((0.32, 0.0, -0.54)).normalized()
        nrm = Vector((-d.z, 0.0, d.x))
        c = Vector((x, yy, z))
        left.append(bm.verts.new(c + nrm * 0.065))
        right.append(bm.verts.new(c - nrm * 0.065))
    faces = []
    for k in range(n):
        f = bm.faces.new((left[k], right[k], right[k + 1], left[k + 1]) if sign < 0 else (left[k + 1], right[k + 1], right[k], left[k]))
        for loop in f.loops:
            vi = (left + right).index(loop.vert)
            kk = vi % (n + 1)
            loop[uv_layer].uv = (0.0 if vi <= n else 1.0, kk * 0.35)
        faces.append(f)
    add_part(left + right, [(f, M_PLAID) for f in faces], ["Chest", "Spine", "Hips"])


sash_side(-1.0)
sash_side(1.0)
blob(P("LeftShoulder", 0.55) + V((0, 0, 0.05)), V((0.11, 0.13, 0.07)), M_PLAID, ["LeftShoulder", "Chest"])

# Legs: wool trews into turned-down boots.
for side in ("Left", "Right"):
    hip, knee = BONES[side + "UpperLeg"]
    _, ankle = BONES[side + "LowerLeg"]
    tube([hip + V((0, 0, -0.04)), hip.lerp(knee, 0.5), knee, knee.lerp(ankle, 0.6), ankle + V((0, 0, 0.1))],
         [0.095, 0.085, 0.07, 0.066, 0.062], M_TROUSER, [side + "UpperLeg", side + "LowerLeg"], seg=10)
    toe = BONES[side + "Toes"][1]
    tube([V((ankle.x, 0.02, 0.0)), V((ankle.x, 0.02, 0.23)), V((ankle.x, 0.01, 0.28))], [0.075, 0.072, 0.085],
         M_LEATHER, [side + "LowerLeg", side + "Foot"], seg=10)
    loft([(V((ankle.x, -0.08, 0.0)), 0.07, 0.15), (V((ankle.x, -0.085, 0.07)), 0.065, 0.14),
          (V((ankle.x, -0.03, 0.11)), 0.055, 0.09)], M_LEATHER, [side + "Foot", side + "Toes"], seg=10)

# Arms: rolled wool sleeves over bare forearms, big working hands.
for side in ("Left", "Right"):
    sh = BONES[side + "UpperArm"][0]
    el = BONES[side + "LowerArm"][0]
    wr = BONES[side + "Hand"][0]
    hand_tip = BONES[side + "Hand"][1]
    tube([sh + (sh - el).normalized() * 0.02, sh.lerp(el, 0.5), el + (wr - el) * 0.25],
         [0.08, 0.07, 0.066], M_TUNIC, [side + "Shoulder", side + "UpperArm", side + "LowerArm"], seg=10)
    tube([el + (wr - el) * 0.2, el + (wr - el) * 0.3], [0.072, 0.07], M_TUNIC, [side + "LowerArm"], seg=10)
    tube([el + (wr - el) * 0.28, wr], [0.052, 0.042], M_SKIN, [side + "LowerArm", side + "Hand"], seg=8)
    blob(wr.lerp(hand_tip, 0.32), V((0.045, 0.05, 0.075)), M_SKIN, [side + "Hand"], sub=2)
    tube([wr + V((0, 0, 0.01)), wr + V((0, 0, 0.05))], [0.05, 0.05], M_LEATHER, [side + "Hand", side + "LowerArm"], seg=8)

# Neck and head.
tube([V((0, 0.0, 1.49)), V((0, 0.0, 1.62))], [0.062, 0.058], M_SKIN, ["Neck", "Chest"], seg=10)
head_c = V((0, -0.005, 1.735))
blob(head_c, V((0.098, 0.108, 0.118)), M_SKIN, ["Head"], sub=3)
blob(head_c + V((0, -0.1, -0.005)), V((0.022, 0.03, 0.03)), M_SKIN, ["Head"], sub=1)           # nose
blob(head_c + V((0, -0.055, -0.085)), V((0.085, 0.07, 0.085)), M_HAIR, ["Head"], sub=2)      # beard
blob(head_c + V((0, -0.072, -0.02)), V((0.06, 0.03, 0.022)), M_HAIR, ["Head"], sub=1)        # moustache
blob(head_c + V((0, 0.02, 0.02)), V((0.103, 0.1, 0.1)), M_HAIR, ["Head"], sub=2, squash_below=0.0)  # hair at the back
# Wool bonnet: a soft flat tam with a band and a toorie on top.
loft([(head_c + V((0, 0.0, 0.055)), 0.104, 0.112), (head_c + V((0, 0.0, 0.075)), 0.106, 0.114)], M_LEATHER, ["Head"], seg=14)
blob(head_c + V((0.015, 0.01, 0.11)), V((0.14, 0.15, 0.05)), M_BONNET, ["Head"], sub=2)
blob(head_c + V((0.015, 0.01, 0.165)), V((0.025, 0.025, 0.02)), M_TUNIC, ["Head"], sub=1)

# ------------------------------------------------------------- skin weights
def seg_dist(p, a, b):
    ab = b - a
    t = max(0.0, min(1.0, (p - a).dot(ab) / max(ab.length_squared, 1e-8)))
    return (a + ab * t - p).length


bm.verts.ensure_lookup_table()
bone_index = {name: i for i, name in enumerate(BONES)}
for idx_list, bones in part_bones:
    for vi in idx_list:
        v = bm.verts[vi]
        d = sorted(((seg_dist(v.co, *BONES[b]), b) for b in bones))[:2]
        w = [1.0 / max(dist, 0.015) ** 4 for dist, _ in d]
        s = sum(w)
        for (dist, b), wi in zip(d, w):
            if wi / s > 0.02:
                v[deform][bone_index[b]] = wi / s

mesh = bpy.data.meshes.new(body_name)
bm.normal_update()
bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bm.to_mesh(mesh)
bm.free()
for m in MATS:
    mesh.materials.append(m)
for p in mesh.polygons:
    p.use_smooth = True
body = bpy.data.objects.new(body_name, mesh)
bpy.context.scene.collection.objects.link(body)
for name in BONES:
    body.vertex_groups.new(name=name)
body.parent = arm
mod = body.modifiers.new("Armature", "ARMATURE")
mod.object = arm

print("WORKER_TRIS", sum(len(p.vertices) - 2 for p in mesh.polygons))
arm.data.pose_position = "POSE"

if PREVIEW:
    scene = bpy.context.scene
    cam = bpy.data.objects.new("PreviewCam", bpy.data.cameras.new("PreviewCam"))
    scene.collection.objects.link(cam)
    cam.location = (1.6, -2.6, 1.9)
    cam.rotation_euler = (math.radians(72), 0, math.radians(32))
    scene.camera = cam
    sun = bpy.data.objects.new("Sun", bpy.data.lights.new("Sun", "SUN"))
    sun.data.energy = 3.5
    sun.rotation_euler = (math.radians(50), 0, math.radians(30))
    scene.collection.objects.link(sun)
    scene.world = bpy.data.worlds.new("W")
    scene.world.color = (0.35, 0.38, 0.42)
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = 700
    scene.render.resolution_y = 800
    scene.render.filepath = PREVIEW
    bpy.ops.render.render(write_still=True)
    bpy.data.objects.remove(cam, do_unlink=True)
    bpy.data.objects.remove(sun, do_unlink=True)

bpy.ops.export_scene.gltf(filepath=OUT_GLB, export_format="GLB", export_yup=True, export_animations=True,
                          export_animation_mode="ACTIONS", export_image_format="AUTO", export_skins=True)
print("WORKER_WRITTEN", OUT_GLB)
