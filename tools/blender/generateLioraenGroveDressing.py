"""Author Lioraen grove dressing: moonstone menhirs and lume-bloom clusters.

Run: blender -b --factory-startup --python make_lioraen_grove.py -- <rock_texture.png> <out_dir>
Writes:
  lioraen_moonstone.glb   a tall, softly curved standing stone wrapped in
                          moss with a thin band of pale green-gold glyph light.
  lioraen_lume_bloom.glb  a clump of broad leaves with glowing bell flowers
                          and a ring of low luminous caps.
Living nature and mobility (Lioraen Concord); restrained glow, no neon.
"""
import math
import os
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector, noise

argv = sys.argv[sys.argv.index("--") + 1:]
TEXTURE, OUT_DIR = argv[0], argv[1]


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def mat(name, color, rough=0.85, emit=None, strength=0.0, image=None, tint=None):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    b = nt.nodes["Principled BSDF"]
    b.inputs["Roughness"].default_value = rough
    if image is not None:
        tex = nt.nodes.new("ShaderNodeTexImage")
        tex.image = image
        mix = nt.nodes.new("ShaderNodeMix")
        mix.data_type = "RGBA"
        mix.blend_type = "MULTIPLY"
        mix.inputs["Factor"].default_value = 1.0
        mix.inputs["B"].default_value = (*tint, 1.0)
        nt.links.new(tex.outputs["Color"], mix.inputs["A"])
        nt.links.new(mix.outputs["Result"], b.inputs["Base Color"])
    else:
        b.inputs["Base Color"].default_value = (*color, 1.0)
    if emit:
        b.inputs["Emission Color"].default_value = (*emit, 1.0)
        b.inputs["Emission Strength"].default_value = strength
    return m


def export(obj, mesh, bm, uv, name):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    for p in mesh.polygons:
        p.use_smooth = True
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    if uv:
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.cube_project(cube_size=uv)
        bpy.ops.object.mode_set(mode="OBJECT")
    print("GROVE", name, "tris", sum(len(p.vertices) - 2 for p in mesh.polygons))
    bpy.ops.export_scene.gltf(filepath=os.path.join(OUT_DIR, name), export_format="GLB", export_yup=True,
                              export_apply=True, export_image_format="JPEG", export_jpeg_quality=88)


# ------------------------------------------------------------ moonstone
reset()
random.seed(31)
img = bpy.data.images.load(TEXTURE)
STONE = mat("Lioraen Moonstone", None, 0.8, image=img, tint=(0.78, 0.80, 0.84))
MOSS = mat("Lioraen Moss", (0.10, 0.20, 0.06), 1.0)
GLYPH = mat("Lioraen Glyph Light", (0.55, 0.85, 0.55), 0.4, emit=(0.62, 1.0, 0.55), strength=2.2)
mesh = bpy.data.meshes.new("Moonstone")
obj = bpy.data.objects.new("Moonstone", mesh)
bpy.context.scene.collection.objects.link(obj)
for m in (STONE, MOSS, GLYPH):
    mesh.materials.append(m)
bm = bmesh.new()
rings, seg = 14, 10
verts = []
for r in range(rings + 1):
    t = r / rings
    z = t * 2.6
    width = 0.42 * (1.0 - 0.45 * t ** 1.6) * (1.0 + 0.08 * math.sin(t * 5.0))
    depth = width * 0.62
    lean = 0.18 * t * t
    ring = []
    for i in range(seg):
        a = i / seg * math.tau
        p = Vector((math.cos(a) * width, math.sin(a) * depth, z))
        p += p.normalized() * noise.noise(p * 2.2) * 0.05
        p.x += lean
        ring.append(bm.verts.new(p))
    verts.append(ring)
faces = []
for r in range(rings):
    for i in range(seg):
        j = (i + 1) % seg
        f = bm.faces.new((verts[r][i], verts[r][j], verts[r + 1][j], verts[r + 1][i]))
        # moss climbs the base and the weather side; a glyph band at chest height
        if r in (7, 8) and i in (seg // 4 - 1, seg // 4, seg // 4 + 1):
            f.material_index = 2
        elif r < 3 or (r < 6 and i > seg // 2):
            f.material_index = 1
        faces.append(f)
cap = bm.verts.new(Vector((0.18 * 1.0 + 0.0, 0.0, 2.72)))
for i in range(seg):
    bm.faces.new((verts[-1][i], verts[-1][(i + 1) % seg], cap))
bm.faces.new(list(reversed(verts[0])))
# a skirt of moss at the foot
for i in range(8):
    a = i / 8 * math.tau
    g = bmesh.ops.create_icosphere(bm, subdivisions=1, radius=1.0)
    for v in g["verts"]:
        v.co = Vector((v.co.x * 0.28, v.co.y * 0.22, max(v.co.z, 0.0) * 0.1)) + Vector((math.cos(a) * 0.45, math.sin(a) * 0.32, 0.0))
    for f in {f for v in g["verts"] for f in v.link_faces}:
        f.material_index = 1
export(obj, mesh, bm, 1.2, "lioraen_moonstone.glb")

# ------------------------------------------------------------ lume bloom
reset()
random.seed(37)
LEAF = mat("Lioraen Broadleaf", (0.06, 0.16, 0.05), 0.7)
STEM = mat("Lioraen Stem", (0.10, 0.18, 0.06), 0.8)
BELL = mat("Lioraen Lume Bell", (0.85, 0.95, 0.6), 0.5, emit=(0.85, 1.0, 0.55), strength=1.8)
CAP = mat("Lioraen Glowcap", (0.35, 0.75, 0.70), 0.5, emit=(0.35, 0.95, 0.85), strength=1.2)
mesh = bpy.data.meshes.new("LumeBloom")
obj = bpy.data.objects.new("LumeBloom", mesh)
bpy.context.scene.collection.objects.link(obj)
for m in (LEAF, STEM, BELL, CAP):
    mesh.materials.append(m)
bm = bmesh.new()


def leaf(base, length, width, yaw, pitch):
    rot = Matrix.Rotation(yaw, 3, "Z") @ Matrix.Rotation(pitch, 3, "X")
    pts = []
    for k in range(6):
        t = k / 5
        w = width * math.sin(t * math.pi) * (1.0 - 0.3 * t)
        droop = -0.35 * t * t * length
        pts.append((rot @ Vector((-w, t * length, droop)) + base, rot @ Vector((w, t * length, droop)) + base))
    vs = [(bm.verts.new(a), bm.verts.new(b)) for a, b in pts]
    for k in range(5):
        f = bm.faces.new((vs[k][0], vs[k][1], vs[k + 1][1], vs[k + 1][0]))
        f.material_index = 0


def blob(center, size, mi, sub=1):
    g = bmesh.ops.create_icosphere(bm, subdivisions=sub, radius=1.0)
    for v in g["verts"]:
        v.co = Vector((v.co.x * size.x, v.co.y * size.y, v.co.z * size.z)) + center
    for f in {f for v in g["verts"] for f in v.link_faces}:
        f.material_index = mi


for i in range(9):
    yaw = i / 9 * math.tau + random.uniform(-0.2, 0.2)
    leaf(Vector((0, 0, 0.05)), random.uniform(0.55, 0.85), random.uniform(0.16, 0.22), yaw, math.radians(random.uniform(25, 45)))
for i in range(5):
    a = random.uniform(0, math.tau)
    r = random.uniform(0.05, 0.22)
    h = random.uniform(0.55, 0.95)
    top = Vector((math.cos(a) * r, math.sin(a) * r, h))
    stem = bmesh.ops.create_cone(bm, cap_ends=False, segments=5, radius1=0.018, radius2=0.012, depth=h)
    for v in stem["verts"]:
        v.co = v.co + Vector((top.x * (v.co.z / h + 0.5), top.y * (v.co.z / h + 0.5), h * 0.5))
    for f in {f for v in stem["verts"] for f in v.link_faces}:
        f.material_index = 1
    blob(top, Vector((0.07, 0.07, 0.09)), 2)
for i in range(7):
    a = i / 7 * math.tau + random.uniform(-0.3, 0.3)
    r = random.uniform(0.55, 0.8)
    s = random.uniform(0.05, 0.09)
    blob(Vector((math.cos(a) * r, math.sin(a) * r, s * 0.6)), Vector((s, s, s * 0.55)), 3)
export(obj, mesh, bm, None, "lioraen_lume_bloom.glb")
