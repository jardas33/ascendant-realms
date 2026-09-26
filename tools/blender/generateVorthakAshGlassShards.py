"""Author a Vorthak ash-glass (obsidian) shard cluster.

Run: blender -b --factory-startup --python make_obsidian_shards.py -- <out.glb>
Tall faceted glass prisms leaning out of a rubble base: glossy black with a
faint violet inner glow along the fracture edges, the "volatile ash-glass"
the Vorthak Cabal mines and venerates. Y-up GLB, origin at the base centre.
"""
import math
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector, noise

OUT = sys.argv[sys.argv.index("--") + 1:][0]
random.seed(23)
bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name, color, rough, metal=0.0, emit=None, strength=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*color, 1.0)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emit:
        b.inputs["Emission Color"].default_value = (*emit, 1.0)
        b.inputs["Emission Strength"].default_value = strength
    return m


GLASS = material("Vorthak Ash Glass", (0.02, 0.015, 0.03), 0.12, 0.0, (0.42, 0.12, 0.75), 0.08)
CORE = material("Vorthak Rift Core", (0.20, 0.06, 0.38), 0.3, 0.0, (0.62, 0.22, 1.0), 1.1)
RUBBLE = material("Vorthak Ash Rubble", (0.07, 0.065, 0.07), 0.95)

mesh = bpy.data.meshes.new("AshGlassShards")
obj = bpy.data.objects.new("AshGlassShards", mesh)
bpy.context.scene.collection.objects.link(obj)
for m in (GLASS, CORE, RUBBLE):
    mesh.materials.append(m)
bm = bmesh.new()


def shard(base, height, radius, lean, yaw, sides=5):
    ring = []
    tilt = Matrix.Rotation(yaw, 3, "Z") @ Matrix.Rotation(lean, 3, "X")
    for i in range(sides):
        a = i / sides * math.tau + random.uniform(-0.2, 0.2)
        r = radius * random.uniform(0.75, 1.1)
        ring.append(bm.verts.new(base + tilt @ Vector((math.cos(a) * r, math.sin(a) * r, 0.0))))
    shoulder = [bm.verts.new(base + tilt @ Vector((v.co.x - base.x, v.co.y - base.y, 0)) * 0.7 + tilt @ Vector((0, 0, height * 0.78))) for v in ring]
    tip = bm.verts.new(base + tilt @ Vector((random.uniform(-0.05, 0.05), random.uniform(-0.05, 0.05), height)))
    faces = []
    for i in range(sides):
        j = (i + 1) % sides
        faces.append(bm.faces.new((ring[i], ring[j], shoulder[j], shoulder[i])))
        faces.append(bm.faces.new((shoulder[i], shoulder[j], tip)))
    faces.append(bm.faces.new(list(reversed(ring))))
    for k, f in enumerate(faces):
        f.material_index = 1 if (k % 7 == 3) else 0  # a few glowing fracture facets


def rubble(center, size, seed):
    g = bmesh.ops.create_icosphere(bm, subdivisions=1, radius=1.0)
    off = Vector((seed * 1.7, seed * 2.3, seed * 0.9))
    for v in g["verts"]:
        d = v.co.normalized()
        d += d * noise.noise(d * 2.0 + off) * 0.3
        v.co = Vector((d.x * size.x, d.y * size.y, max(d.z, -0.2) * size.z)) + center
    for f in {f for v in g["verts"] for f in v.link_faces}:
        f.material_index = 2


shard(Vector((0, 0, -0.1)), 2.6, 0.32, 0.08, 0.0, 6)
for i in range(6):
    a = i / 6 * math.tau + random.uniform(-0.3, 0.3)
    r = random.uniform(0.45, 0.9)
    shard(Vector((math.cos(a) * r, math.sin(a) * r, -0.08)), random.uniform(0.8, 1.9), random.uniform(0.12, 0.22),
          random.uniform(0.25, 0.6), a + math.pi / 2 + random.uniform(-0.3, 0.3))
for i in range(10):
    a = random.uniform(0, math.tau)
    r = random.uniform(0.5, 1.3)
    s = random.uniform(0.12, 0.3)
    rubble(Vector((math.cos(a) * r, math.sin(a) * r, 0.02)), Vector((s, s * 0.9, s * 0.6)), i)

bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bm.to_mesh(mesh)
bm.free()
for p in mesh.polygons:
    p.use_smooth = False
print("SHARDS_TRIS", sum(len(p.vertices) - 2 for p in mesh.polygons))
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_yup=True, export_apply=True)
print("SHARDS_WRITTEN", OUT)
