"""Build a presentation-only Lioraen moonbell clump for Godot.

Run: blender -b -t 2 --python generateLioraenMoonbell.py -- output.glb source.blend
The world scales this mesh and removes collisions; no gameplay surface is used.
"""

import math
import random
import sys

import bpy
from mathutils import Vector


output_glb, output_blend = sys.argv[sys.argv.index("--") + 1 :]
random.seed(73028)
bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, emission=None, strength=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = 0.88
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = strength
    return mat


materials = [
    material("Moonbell fern deep", (0.040, 0.100, 0.068)),
    material("Moonbell fern lifted", (0.068, 0.155, 0.105)),
    material("Moonbell olive stems", (0.100, 0.165, 0.102)),
    material("Moonbell lapis petals", (0.115, 0.230, 0.415)),
    material("Moonbell lilac petals", (0.245, 0.205, 0.385)),
    material("Moonbell amber nectar", (0.65, 0.455, 0.155), (0.27, 0.19, 0.045), 0.12),
]
verts = []
faces = []
face_mats = []


def piece(points, polygons, mat_index):
    offset = len(verts)
    verts.extend(points)
    for polygon in polygons:
        faces.append(tuple(offset + v for v in polygon))
        face_mats.append(mat_index)


def tube(points, radii, mat_index, sides=5):
    points = [Vector(p) for p in points]
    local = []
    for index, point in enumerate(points):
        tangent = (points[min(index + 1, len(points) - 1)] - points[max(index - 1, 0)]).normalized()
        axis = tangent.cross(Vector((0, 0, 1)))
        if axis.length < 0.01:
            axis = tangent.cross(Vector((0, 1, 0)))
        axis.normalize()
        other = tangent.cross(axis).normalized()
        for side in range(sides):
            angle = math.tau * side / sides
            local.append(point + radii[index] * (axis * math.cos(angle) + other * math.sin(angle)))
    polys = []
    for ring in range(len(points) - 1):
        for side in range(sides):
            a = ring * sides + side
            b = ring * sides + (side + 1) % sides
            polys.append((a, b, b + sides, a + sides))
    piece(local, polys, mat_index)


def frond(angle, reach, lifted, color_index):
    direction = Vector((math.cos(angle), math.sin(angle), 0))
    side = Vector((-direction.y, direction.x, 0))
    root = Vector((0.0, 0.0, 0.075)) + side * random.uniform(-0.08, 0.08)
    spine = []
    for t in (0.0, 0.29, 0.59, 0.81, 1.0):
        spine.append(root + direction * reach * t + Vector((0, 0, lifted * math.sin(math.pi * t) + 0.03 * t)))
    local = []
    for index, point in enumerate(spine):
        width = (0.015, 0.083, 0.118, 0.080, 0.004)[index] * (reach / 0.60)
        local.extend((point - side * width, point + Vector((0, 0, 0.035)), point + side * width))
    polys = []
    for i in range(len(spine) - 1):
        a = i * 3
        b = (i + 1) * 3
        polys.extend(((a, a + 1, b + 1, b), (a + 1, a + 2, b + 2, b + 1)))
    piece(local, polys, color_index)
    tube([root, spine[2], spine[-1]], [0.018, 0.011, 0.003], 2, 4)


for index in range(9):
    angle = math.tau * index / 9 + random.uniform(-0.20, 0.20)
    frond(angle, random.uniform(0.46, 0.70), random.uniform(0.08, 0.21), index % 2)


def blossom(center, radius, palette_index, turn):
    center = Vector(center)
    petal_verts = []
    petal_polys = []
    for i in range(5):
        angle = turn + math.tau * i / 5
        direction = Vector((math.cos(angle), math.sin(angle), 0))
        side = Vector((-direction.y, direction.x, 0))
        irregular = 0.90 + random.uniform(-0.07, 0.10)
        start = len(petal_verts)
        petal_verts.extend((
            center + direction * radius * 0.10 + Vector((0, 0, 0.035)),
            center + direction * radius * 0.53 - side * radius * 0.34 + Vector((0, 0, 0.008)),
            center + direction * radius * 0.90 * irregular - side * radius * 0.31 - Vector((0, 0, 0.075)),
            center + direction * radius * 1.08 * irregular - Vector((0, 0, 0.10)),
            center + direction * radius * 0.90 * irregular + side * radius * 0.31 - Vector((0, 0, 0.075)),
            center + direction * radius * 0.53 + side * radius * 0.34 + Vector((0, 0, 0.008)),
        ))
        petal_polys.extend(((start, start + 1, start + 2, start + 3),
                            (start, start + 3, start + 4, start + 5)))
    piece(petal_verts, petal_polys, palette_index)
    # A few tiny warm stamens retain a magical focal point without the old
    # full-white emission, which made every plant a glowing UI-like symbol.
    for i in range(3):
        angle = turn + math.tau * i / 3
        p = center + Vector((math.cos(angle), math.sin(angle), 0)) * radius * 0.13
        tube([p, p + Vector((0, 0, 0.07))], [0.014, 0.007], 5, 4)


stalks = [
    ((-0.26, 0.12, 0.84), 0.20, 3),
    ((0.29, -0.06, 0.69), 0.18, 4),
    ((0.13, 0.28, 1.01), 0.21, 3),
]
for index, (top, radius, palette_index) in enumerate(stalks):
    top = Vector(top)
    tube([(0.0, 0.0, 0.07), (top.x * 0.39, top.y * 0.37, top.z * 0.42),
          (top.x * 0.84, top.y * 0.82, top.z * 0.86), top],
         [0.022, 0.019, 0.013, 0.009], 2)
    blossom(top, radius, palette_index, 0.19 + index * 0.63)


mesh = bpy.data.meshes.new("Moonbell flowering fern mesh")
mesh.from_pydata(verts, [], faces)
mesh.validate(verbose=True)
mesh.update()
for mat in materials:
    mesh.materials.append(mat)
for polygon, material_index in zip(mesh.polygons, face_mats):
    polygon.material_index = material_index
obj = bpy.data.objects.new("Lioraen moonbell flowering fern", mesh)
bpy.context.collection.objects.link(obj)
scene = bpy.context.scene
scene.unit_settings.system = "METRIC"
bpy.ops.wm.save_as_mainfile(filepath=output_blend)
bpy.ops.export_scene.gltf(filepath=output_glb, export_format="GLB", export_yup=True)
print("BLOOM_R2", output_glb, "VERTICES", len(verts), "FACES", len(faces), "OBJECTS", len(bpy.data.objects))
