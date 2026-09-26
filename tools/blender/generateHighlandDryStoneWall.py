"""Author a highland dry-stone wall module for Ascendant Realms.

Run: blender -b --factory-startup --python make_dry_stone_wall.py -- <rock_texture.png> <out.glb>
Builds ~9 m of irregular stacked stones in three courses with cap stones,
base rubble and turf tufts, three tinted stone materials sharing the
project's highland rock texture. Y-up GLB, origin at the wall's base centre.
"""
import math
import random
import sys

import bmesh
import bpy
from mathutils import Vector, noise

argv = sys.argv[sys.argv.index("--") + 1:]
TEXTURE, OUT = argv[0], argv[1]
random.seed(7)

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

img = bpy.data.images.load(TEXTURE)


def make_material(name, tint, rough=0.9):
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
    bsdf.inputs["Metallic"].default_value = 0.0
    return mat


# glTF exports a multiplied texture as texture * baseColorFactor.
stone_mats = [
    make_material("Highland Granite Cool", (0.62, 0.64, 0.66)),
    make_material("Highland Granite Warm", (0.70, 0.64, 0.56)),
    make_material("Highland Granite Lichen", (0.56, 0.62, 0.50)),
]
turf_mat = bpy.data.materials.new("Highland Turf")
turf_mat.use_nodes = True
turf_bsdf = turf_mat.node_tree.nodes["Principled BSDF"]
turf_bsdf.inputs["Base Color"].default_value = (0.16, 0.22, 0.08, 1.0)
turf_bsdf.inputs["Roughness"].default_value = 1.0


def rock(bm, center, size, seed, detail=2):
    """Irregular, slightly flattened boulder: an icosphere pushed by noise."""
    geom = bmesh.ops.create_icosphere(bm, subdivisions=detail, radius=1.0)
    off = Vector((seed * 3.1, seed * 1.7, seed * 2.3))
    for v in geom["verts"]:
        d = v.co.normalized()
        # Square the pebble off a little so stones stack like dressed rubble.
        sq = Vector((math.copysign(abs(d.x) ** 0.6, d.x), math.copysign(abs(d.y) ** 0.6, d.y), math.copysign(abs(d.z) ** 0.6, d.z)))
        co = d.lerp(sq, 0.55)
        co += d * noise.noise(d * 1.8 + off) * 0.16
        v.co = Vector((co.x * size.x, co.y * size.y, co.z * size.z)) + center
    return geom["verts"]


def build_object(name, fill):
    mesh = bpy.data.meshes.new(name)
    obj = bpy.data.objects.new(name, mesh)
    scene.collection.objects.link(obj)
    bm = bmesh.new()
    fill(bm, obj)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    for poly in mesh.polygons:
        poly.use_smooth = False
    return obj


LENGTH = 9.0
COURSES = [(0.0, 0.46, 0.62), (0.40, 0.40, 0.54), (0.76, 0.34, 0.46)]  # z base, height, depth


def fill_stones(bm, obj):
    for mat in stone_mats:
        obj.data.materials.append(mat)
    idx = 0
    for course, (z, h, depth) in enumerate(COURSES):
        x = -LENGTH / 2 + random.uniform(0.0, 0.3)
        taper = 1.0 - course * 0.08
        while x < LENGTH / 2 - 0.2:
            w = random.uniform(0.45, 0.85) * (1.0 - course * 0.1)
            size = Vector((w * 0.5, depth * 0.5 * taper * random.uniform(0.9, 1.1), h * 0.5 * random.uniform(0.85, 1.1)))
            center = Vector((x + w * 0.5, random.uniform(-0.04, 0.04), z + size.z))
            before = len(bm.faces)
            rock(bm, center, size, idx)
            bm.faces.ensure_lookup_table()
            mat_index = random.choices([0, 1, 2], weights=[5, 3, 2 if course == 2 else 1])[0]
            for f in bm.faces[before:]:
                f.material_index = mat_index
            x += w * random.uniform(0.86, 0.96)
            idx += 1
    # Cap stones laid on edge along the top, the classic highland finish.
    x = -LENGTH / 2 + 0.1
    while x < LENGTH / 2 - 0.15:
        w = random.uniform(0.18, 0.28)
        size = Vector((w * 0.5, 0.22, 0.2 * random.uniform(0.9, 1.2)))
        center = Vector((x + w * 0.5, 0.0, 1.12 + size.z * 0.8))
        before = len(bm.faces)
        rock(bm, center, size, idx, 1)
        bm.faces.ensure_lookup_table()
        for f in bm.faces[before:]:
            f.material_index = random.choice([0, 0, 2])
        x += w * 0.92
        idx += 1
    # Fallen rubble at the foot of the wall.
    for i in range(14):
        side = random.choice([-1, 1])
        s = random.uniform(0.08, 0.2)
        center = Vector((random.uniform(-LENGTH / 2, LENGTH / 2), side * random.uniform(0.38, 0.7), s * 0.6))
        before = len(bm.faces)
        rock(bm, center, Vector((s, s * 0.9, s * 0.7)), 400 + i, 1)
        bm.faces.ensure_lookup_table()
        for f in bm.faces[before:]:
            f.material_index = random.choice([0, 1])


def fill_turf(bm, obj):
    obj.data.materials.append(turf_mat)
    for i in range(34):
        side = random.choice([-1, 1])
        base = Vector((random.uniform(-LENGTH / 2, LENGTH / 2), side * random.uniform(0.3, 0.55), 0.0))
        for blade in range(5):
            ang = random.uniform(0, math.tau)
            lean = Vector((math.cos(ang), math.sin(ang), 0.0)) * random.uniform(0.04, 0.12)
            hgt = random.uniform(0.16, 0.34)
            a = base + Vector((math.cos(ang + 1.6), math.sin(ang + 1.6), 0)) * 0.035
            b = base - Vector((math.cos(ang + 1.6), math.sin(ang + 1.6), 0)) * 0.035
            tip = base + lean + Vector((0, 0, hgt))
            verts = [bm.verts.new(a), bm.verts.new(b), bm.verts.new(tip)]
            bm.faces.new(verts)


stones = build_object("DryStoneWall", fill_stones)
turf = build_object("DryStoneWallTurf", fill_turf)

# Box-project UVs so the rock texture wraps each stone at ~1 tile per metre.
for obj in (stones,):
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.cube_project(cube_size=1.4)
    bpy.ops.object.mode_set(mode="OBJECT")
    obj.select_set(False)

tris = sum(len(p.vertices) - 2 for o in (stones, turf) for p in o.data.polygons)
print("DRY_STONE_WALL_TRIS", tris)

bpy.ops.export_scene.gltf(
    filepath=OUT,
    export_format="GLB",
    export_yup=True,
    export_apply=True,
    export_image_format="JPEG",
    export_jpeg_quality=88,
)
print("DRY_STONE_WALL_WRITTEN", OUT)
