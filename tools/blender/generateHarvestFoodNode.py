"""Author the food resource site: a patch of ripe grain on tilled soil with
bound sheaves, a stook and grain sacks, so food no longer reuses the
timber-pile model.

Run: blender -b --factory-startup --python generateHarvestFoodNode.py -- <out.glb>
Y-up GLB, origin at base centre, about 1.5 m tall (the stook), ~5 m across.
"""
import math
import random
import sys

import bmesh
import bpy
from mathutils import Vector

OUT = sys.argv[sys.argv.index("--") + 1:][0]
rng = random.Random(1187)

bpy.ops.wm.read_factory_settings(use_empty=True)


def mat(name, col, rough=0.9):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*col, 1.0)
    b.inputs["Roughness"].default_value = rough
    return m


SOIL = mat("TilledSoil", (0.17, 0.11, 0.06))
GRAIN = mat("RipeGrain", (0.64, 0.45, 0.15), 0.8)
GRAIN_DARK = mat("GrainShade", (0.50, 0.34, 0.11), 0.85)
TWINE = mat("Twine", (0.36, 0.24, 0.12))
SACK = mat("Sackcloth", (0.62, 0.52, 0.38), 0.95)


def link(obj):
    bpy.context.collection.objects.link(obj)
    return obj


def mesh_obj(name, bm, material):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    me.materials.append(material)
    for p in me.polygons:
        p.use_smooth = True
    return link(bpy.data.objects.new(name, me))


# Tilled soil: an irregular low disc with furrow ridges.
bm = bmesh.new()
rings, segs = 10, 40
verts = []
centre = bm.verts.new((0, 0, 0.04))
for r in range(1, rings + 1):
    row = []
    for s in range(segs):
        a = math.tau * s / segs
        rad = 2.6 * r / rings * (1.0 + 0.1 * math.sin(a * 3 + 1.2) + 0.05 * math.sin(a * 7))
        x, y = math.cos(a) * rad, math.sin(a) * rad
        z = 0.04 * (1 - (r / rings) ** 3) + 0.025 * math.sin(x * 5.5)
        row.append(bm.verts.new((x, y, z)))
    verts.append(row)
for s in range(segs):
    bm.faces.new((centre, verts[0][s], verts[0][(s + 1) % segs]))
for r in range(rings - 1):
    for s in range(segs):
        a, b = verts[r][s], verts[r][(s + 1) % segs]
        c, d = verts[r + 1][(s + 1) % segs], verts[r + 1][s]
        bm.faces.new((a, d, c, b))
mesh_obj("Soil", bm, SOIL)


def grain_tuft(x, y, h):
    # A clump of tapered stalks with fat ear heads.
    bm = bmesh.new()
    for i in range(7):
        a = rng.random() * math.tau
        lean = Vector((math.cos(a), math.sin(a), 0)) * rng.uniform(0.04, 0.12)
        base = Vector((x + rng.uniform(-0.08, 0.08), y + rng.uniform(-0.08, 0.08), 0.03))
        top = base + lean + Vector((0, 0, h * rng.uniform(0.8, 1.05)))
        side = Vector((-math.sin(a), math.cos(a), 0)) * 0.012
        v0 = bm.verts.new(base - side)
        v1 = bm.verts.new(base + side)
        v2 = bm.verts.new(top)
        bm.faces.new((v0, v1, v2))
        # Ear: an elongated diamond around the top.
        ear_c = top - (top - base).normalized() * 0.07
        up = (top - base).normalized() * 0.09
        w = side * 4.0
        e0 = bm.verts.new(ear_c - up)
        e1 = bm.verts.new(ear_c + w)
        e2 = bm.verts.new(ear_c + up * 1.2)
        e3 = bm.verts.new(ear_c - w)
        bm.faces.new((e0, e1, e2, e3))
    return bm


field = bmesh.new()
for i in range(170):
    a = rng.random() * math.tau
    r = math.sqrt(rng.random()) * 2.1
    x, y = math.cos(a) * r, math.sin(a) * r
    if (x - 0.9) ** 2 + (y + 0.5) ** 2 < 0.9:  # leave the stook's clearing
        continue
    tuft = grain_tuft(x, y, rng.uniform(0.55, 0.8))
    me = bpy.data.meshes.new("t")
    tuft.to_mesh(me)
    tuft.free()
    field.from_mesh(me)
    bpy.data.meshes.remove(me)
mesh_obj("GrainField", field, GRAIN)


def sheaf(x, y, h, tilt=(0.0, 0.0), rot=0.0):
    # Waisted bundle: flared butt, tied waist, spreading ear crown.
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=14, radius1=0.2, radius2=0.1, depth=h * 0.45)
    bmesh.ops.translate(bm, verts=bm.verts, vec=(0, 0, h * 0.225))
    top = bmesh.new()
    bmesh.ops.create_cone(top, cap_ends=True, segments=14, radius1=0.1, radius2=0.24, depth=h * 0.55)
    bmesh.ops.translate(top, verts=top.verts, vec=(0, 0, h * 0.45 + h * 0.275))
    for v in top.verts:
        v.co.x += rng.uniform(-0.02, 0.02)
        v.co.y += rng.uniform(-0.02, 0.02)
    me = bpy.data.meshes.new("s")
    top.to_mesh(me)
    top.free()
    bm.from_mesh(me)
    bpy.data.meshes.remove(me)
    o = mesh_obj("Sheaf", bm, GRAIN_DARK if rng.random() < 0.4 else GRAIN)
    band = bmesh.new()
    bmesh.ops.create_cone(band, cap_ends=False, segments=14, radius1=0.112, radius2=0.112, depth=0.06)
    bmesh.ops.translate(band, verts=band.verts, vec=(0, 0, h * 0.45))
    b = mesh_obj("Twine", band, TWINE)
    b.parent = o
    o.location = (x, y, 0)
    o.rotation_euler = (tilt[0], tilt[1], rot)
    return o


# A stook: sheaves leaning together, plus a few loose ones.
for i in range(5):
    a = math.tau * i / 5
    sheaf(0.9 + math.cos(a) * 0.2, -0.5 + math.sin(a) * 0.2, 1.4,
          (-math.sin(a) * 0.28, math.cos(a) * 0.28), a)
sheaf(-1.3, 0.9, 1.1, (0.0, 1.45, 0.0), 0.4)
sheaf(-0.7, 1.5, 1.1, (0.0, 1.5, 0.0), 2.1)
sheaf(1.7, 0.8, 1.2)


def sack(x, y, rot):
    bm = bmesh.new()
    bmesh.ops.create_uvsphere(bm, u_segments=14, v_segments=8, radius=0.3)
    for v in bm.verts:
        v.co.z = v.co.z * 1.25 + 0.3
        v.co *= 1.0 + 0.05 * math.sin(v.co.x * 9)
        if v.co.z > 0.55:
            v.co.x *= 0.55
            v.co.y *= 0.55
    o = mesh_obj("Sack", bm, SACK)
    o.location = (x, y, 0)
    o.rotation_euler = (0, 0, rot)


sack(0.2, 1.2, 0.3)
sack(0.65, 1.35, 1.2)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_yup=True, use_selection=True)
print("wrote", OUT)
