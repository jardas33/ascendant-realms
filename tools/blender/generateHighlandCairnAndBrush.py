"""Author the Hollowspan small stone cairn and highland brush cluster.

Run: blender -b --factory-startup --python make_cairn_and_brush.py -- <rock_texture.png> <out_dir>
Writes small_stone_cairn.glb (stacked, textured field stones on a turf
collar) and highland_brush_cluster.glb (heather and gorse mounds with
flower flecks and a half-buried stone). Y-up GLBs, origin at base centre.
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


def textured(img, name, tint, rough=0.9):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = nt.nodes["Principled BSDF"]
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    mix = nt.nodes.new("ShaderNodeMix")
    mix.data_type = "RGBA"
    mix.blend_type = "MULTIPLY"
    mix.inputs["Factor"].default_value = 1.0
    mix.inputs["B"].default_value = (*tint, 1.0)
    nt.links.new(tex.outputs["Color"], mix.inputs["A"])
    nt.links.new(mix.outputs["Result"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = rough
    return mat


def flat(name, color, rough=0.95):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    return mat


def lump(bm, center, size, seed, detail=2, angular=0.55, mat=0, rot=0.0, amp=0.16, top_mat=None):
    geom = bmesh.ops.create_icosphere(bm, subdivisions=detail, radius=1.0)
    off = Vector((seed * 3.1, seed * 1.7, seed * 2.3))
    rz = Matrix.Rotation(rot, 3, "Z")
    for v in geom["verts"]:
        d = v.co.normalized()
        sq = Vector((math.copysign(abs(d.x) ** 0.6, d.x), math.copysign(abs(d.y) ** 0.6, d.y), math.copysign(abs(d.z) ** 0.6, d.z)))
        co = d.lerp(sq, angular)
        co += d * noise.noise(d * 1.8 + off) * amp
        co = Vector((co.x * size.x, co.y * size.y, max(co.z, -0.3) * size.z))
        v.co = rz @ co + center
    bm.normal_update()
    for f in {f for v in geom["verts"] for f in v.link_faces}:
        f.material_index = top_mat if (top_mat is not None and f.normal.z > 0.6) else mat


def finish(obj, mesh, bm, uv_size, out_name):
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    for p in mesh.polygons:
        p.use_smooth = False
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.cube_project(cube_size=uv_size)
    bpy.ops.object.mode_set(mode="OBJECT")
    out = os.path.join(OUT_DIR, out_name)
    print("ASSET", out_name, "tris", sum(len(p.vertices) - 2 for p in mesh.polygons))
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", export_yup=True, export_apply=True,
                              export_image_format="JPEG", export_jpeg_quality=88)


# ---------------------------------------------------------------- cairn
reset()
random.seed(3)
img = bpy.data.images.load(TEXTURE)
mesh = bpy.data.meshes.new("StoneCairn")
obj = bpy.data.objects.new("StoneCairn", mesh)
bpy.context.scene.collection.objects.link(obj)
for m in (textured(img, "Cairn Granite", (0.66, 0.66, 0.64)),
          textured(img, "Cairn Granite Lichen", (0.58, 0.64, 0.50)),
          flat("Cairn Turf", (0.04, 0.065, 0.02), 1.0)):
    mesh.materials.append(m)
bm = bmesh.new()
z = 0.0
for i, (w, h) in enumerate([(0.62, 0.30), (0.50, 0.27), (0.40, 0.25), (0.30, 0.22), (0.20, 0.2)]):
    c = Vector((random.uniform(-0.05, 0.05), random.uniform(-0.05, 0.05), z + h * 0.5))
    lump(bm, c, Vector((w, w * random.uniform(0.8, 0.95), h * 0.5)), i, 2, 0.6, 0, random.uniform(0, 3), 0.14, 1)
    z += h * 0.82
for i in range(9):
    a = i / 9 * math.tau + random.uniform(-0.2, 0.2)
    r = random.uniform(0.62, 0.85)
    s = random.uniform(0.12, 0.2)
    lump(bm, Vector((math.cos(a) * r, math.sin(a) * r, s * 0.35)), Vector((s, s * 0.85, s * 0.6)), 20 + i, 1, 0.5, 0, a)
finish(obj, mesh, bm, 1.6, "small_stone_cairn.glb")

# ---------------------------------------------------------------- brush
reset()
random.seed(5)
img = bpy.data.images.load(TEXTURE)
mesh = bpy.data.meshes.new("HighlandBrush")
obj = bpy.data.objects.new("HighlandBrush", mesh)
bpy.context.scene.collection.objects.link(obj)
for m in (flat("Heather Deep", (0.030, 0.052, 0.018)),         # 0 foliage shadow side
          flat("Heather Sunlit", (0.062, 0.100, 0.026)),       # 1 foliage tops
          flat("Heather Bloom", (0.20, 0.045, 0.15)),        # 2 heather flowers
          flat("Gorse Bloom", (0.62, 0.36, 0.02)),          # 3 gorse flowers
          textured(img, "Brush Stone", (0.62, 0.62, 0.6))):  # 4 half-buried stone
    mesh.materials.append(m)
bm = bmesh.new()
mounds = [(Vector((0.0, 0.0, 0.25)), Vector((0.75, 0.62, 0.42)), 2),
          (Vector((0.78, 0.25, 0.18)), Vector((0.5, 0.45, 0.3)), 3),
          (Vector((-0.7, 0.3, 0.16)), Vector((0.48, 0.42, 0.28)), 2),
          (Vector((0.2, -0.6, 0.14)), Vector((0.42, 0.36, 0.24)), 3)]
for i, (c, s, bloom) in enumerate(mounds):
    lump(bm, c, s, i, 3, 0.05, 0, random.uniform(0, 3), 0.42, 1)
    # flower flecks scattered over the sunlit crown
    for k in range(10):
        a = random.uniform(0, math.tau)
        r = random.uniform(0.0, 0.75)
        p = c + Vector((math.cos(a) * s.x * r, math.sin(a) * s.y * r, s.z * (0.55 + 0.4 * (1 - r))))
        lump(bm, p, Vector((0.07, 0.07, 0.05)), 40 + i * 10 + k, 1, 0.0, bloom, 0.0, 0.1)
lump(bm, Vector((-0.2, 0.55, 0.08)), Vector((0.36, 0.28, 0.2)), 77, 2, 0.7, 4, 0.8, 0.18)
finish(obj, mesh, bm, 1.6, "highland_brush_cluster.glb")
