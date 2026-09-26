"""Author a granite quarry outcrop for the Ascendant Realms stone resource.

Run: blender -b --factory-startup --python make_stone_quarry.py -- <rock_texture.png> <out.glb>
An angular granite outcrop with three dressed blocks already cut from it,
a wedge of spoil chips and a timber sledge rail, so the node reads as
"stone you can quarry" at RTS zoom. Y-up GLB, origin at the base centre.
"""
import math
import random
import sys

import bmesh
import bpy
from mathutils import Matrix, Vector, noise

argv = sys.argv[sys.argv.index("--") + 1:]
TEXTURE, OUT = argv[0], argv[1]
random.seed(11)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
img = bpy.data.images.load(TEXTURE)


def textured(name, tint, rough=0.88):
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


def flat(name, color, rough=0.9):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    return mat


MATS = [
    textured("Quarry Granite Weathered", (0.70, 0.70, 0.70)),   # 0 outcrop
    textured("Quarry Granite Fresh Cut", (1.0, 0.93, 0.80)),   # 1 dressed blocks
    textured("Quarry Granite Lichen", (0.62, 0.68, 0.52)),      # 2 lichen tops
    flat("Quarry Sledge Oak", (0.24, 0.15, 0.08)),              # 3 timber
]


def boulder(bm, center, size, seed, detail=2, angular=0.8, mat=0, rot=0.0):
    geom = bmesh.ops.create_icosphere(bm, subdivisions=detail, radius=1.0)
    off = Vector((seed * 2.9, seed * 1.3, seed * 4.1))
    rz = Matrix.Rotation(rot, 3, "Z")
    for v in geom["verts"]:
        d = v.co.normalized()
        sq = Vector((math.copysign(abs(d.x) ** 0.45, d.x), math.copysign(abs(d.y) ** 0.45, d.y), math.copysign(abs(d.z) ** 0.45, d.z)))
        co = d.lerp(sq, angular)
        co += d * noise.noise(d * 1.4 + off) * 0.22
        co = Vector((co.x * size.x, co.y * size.y, max(co.z, -0.35) * size.z))
        v.co = rz @ co + center
    faces = {f for v in geom["verts"] for f in v.link_faces}
    for f in faces:
        f.material_index = 2 if (f.normal.z > 0.75 and mat == 0 and random.random() < 0.6) else mat


def block(bm, center, size, rot, mat=1):
    geom = bmesh.ops.create_cube(bm, size=1.0)
    bmesh.ops.bevel(bm, geom=[e for e in bm.edges if e.verts[0] in geom["verts"] and e.verts[1] in geom["verts"]],
                    offset=0.06, segments=1, affect="EDGES")
    rz = Matrix.Rotation(rot, 3, "Z")
    verts = {v for v in bm.verts if v in set(geom["verts"])} | {v for f in bm.faces for v in f.verts if any(x in geom["verts"] for x in f.verts)}
    for v in verts:
        v.co = rz @ Vector((v.co.x * size.x, v.co.y * size.y, v.co.z * size.z)) + center
    for f in {f for v in verts for f in v.link_faces}:
        f.material_index = mat


mesh = bpy.data.meshes.new("StoneQuarry")
obj = bpy.data.objects.new("StoneQuarry", mesh)
scene.collection.objects.link(obj)
for m in MATS:
    mesh.materials.append(m)
bm = bmesh.new()

# Main outcrop: split granite pillars stepping up to a crag, the quarry face.
boulder(bm, Vector((0.0, 0.35, 0.95)), Vector((0.75, 0.7, 1.3)), 1, 2, 0.95, 0, 0.3)
boulder(bm, Vector((-0.85, 0.45, 0.7)), Vector((0.6, 0.65, 0.95)), 2, 2, 0.95, 0, 1.1)
boulder(bm, Vector((0.8, 0.55, 0.62)), Vector((0.55, 0.6, 0.85)), 3, 2, 0.95, 0, 2.0)
boulder(bm, Vector((-1.5, 0.7, 0.4)), Vector((0.5, 0.5, 0.55)), 4, 2, 0.9, 0, 0.7)
boulder(bm, Vector((1.45, 0.8, 0.35)), Vector((0.45, 0.5, 0.5)), 5, 2, 0.9, 0, 2.6)
# Dressed blocks cut and stacked in front of the face.
block(bm, Vector((-0.55, -1.05, 0.24)), Vector((0.62, 0.42, 0.48)), 0.12)
block(bm, Vector((0.35, -1.15, 0.22)), Vector((0.56, 0.40, 0.44)), -0.2)
block(bm, Vector((-0.12, -1.1, 0.66)), Vector((0.5, 0.38, 0.4)), 0.05)
# Spoil chips spread toward the working side.
for i in range(18):
    a = random.uniform(-2.4, -0.7)
    r = random.uniform(0.9, 1.9)
    s = random.uniform(0.07, 0.17)
    boulder(bm, Vector((math.cos(a) * r, math.sin(a) * r, s * 0.5)), Vector((s, s * 0.8, s * 0.6)), 50 + i, 1, 0.6, 1 if i % 3 == 0 else 0, random.uniform(0, 3))
# Timber sledge rails the blocks are dragged out on.
for x in (-0.35, 0.35):
    block(bm, Vector((x, -1.75, 0.06)), Vector((0.09, 0.9, 0.08)), 0.0, 3)

bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
bm.to_mesh(mesh)
bm.free()
for p in mesh.polygons:
    p.use_smooth = False

bpy.context.view_layer.objects.active = obj
obj.select_set(True)
bpy.ops.object.mode_set(mode="EDIT")
bpy.ops.mesh.select_all(action="SELECT")
bpy.ops.uv.cube_project(cube_size=3.5)
bpy.ops.object.mode_set(mode="OBJECT")

print("STONE_QUARRY_TRIS", sum(len(p.vertices) - 2 for p in mesh.polygons))
bpy.ops.export_scene.gltf(filepath=OUT, export_format="GLB", export_yup=True, export_apply=True,
                          export_image_format="JPEG", export_jpeg_quality=88)
print("STONE_QUARRY_WRITTEN", OUT)
