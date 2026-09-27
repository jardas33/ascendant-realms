"""Build an asymmetric Lioraen waystone for the production Godot GLB slot.

Run: blender -b -t 2 --python generate_moonstone_r2.py -- <output.glb> <source.blend> <slate.png>
The existing world script scales this decorative asset and adds no collider.
"""

import math
import random
import sys

import bpy
from mathutils import Vector


random.seed(73027)
arguments = sys.argv[sys.argv.index("--") + 1 :]
output_glb, output_blend, slate_path = arguments

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)


def material(name, color, emission=None):
    result = bpy.data.materials.new(name)
    result.diffuse_color = (*color, 1.0)
    result.use_nodes = True
    bsdf = result.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = 0.0
    bsdf.inputs["Roughness"].default_value = 0.92
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 0.36
    return result


slate = material("Rain-darkened blue slate texture", (1.0, 1.0, 1.0))
slate_image = bpy.data.images.load(slate_path, check_existing=True)
slate_image.pack()
slate_image.colorspace_settings.name = "sRGB"
image_node = slate.node_tree.nodes.new("ShaderNodeTexImage")
image_node.image = slate_image
slate.node_tree.links.new(image_node.outputs["Color"],
                          slate.node_tree.nodes.get("Principled BSDF").inputs["Base Color"])
stone_faces = [
    slate,
    material("Chipped slate bevel", (0.055, 0.075, 0.07)),
    material("Slate fracture shadow", (0.028, 0.044, 0.044)),
]
moss = material("Velvet moss - shaded olive", (0.075, 0.145, 0.085))
moss_light = material("Moss edge - lichen green", (0.14, 0.21, 0.11))
soil = material("Rooted dark earth", (0.105, 0.085, 0.055))
glyph = material("Carved spring Lume", (0.08, 0.40, 0.38), (0.08, 0.36, 0.32))
groove = material("Rune-cut shadow", (0.035, 0.07, 0.065))


def mesh_object(name, vertices, faces, materials, face_materials=None):
    mesh = bpy.data.meshes.new(name + " mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    for mat in materials:
        mesh.materials.append(mat)
    if face_materials:
        for poly, index in zip(mesh.polygons, face_materials):
            poly.material_index = index
    if name == "Hewn spring waystone":
        uvs = mesh.uv_layers.new(name="Slate surface UV")
        for poly in mesh.polygons:
            for loop_index in poly.loop_indices:
                vertex = mesh.vertices[mesh.loops[loop_index].vertex_index].co
                along = vertex.x if abs(poly.normal.y) > abs(poly.normal.x) else vertex.y
                uvs.data[loop_index].uv = (along * 0.9 + 0.5, vertex.z / 2.75)
    return obj


# Broad cut faces, a chipped shoulder and a slight lean make seven rotations
# read as related ancient stones rather than duplicated pale traffic cones.
outline = [
    (-0.50, -0.27), (-0.20, -0.39), (0.29, -0.35), (0.51, -0.15),
    (0.45, 0.25), (0.15, 0.38), (-0.36, 0.33), (-0.55, 0.05),
]
levels = [
    (0.10, 1.00, 1.00, 0.00, 0.00),
    (0.47, 0.96, 0.95, 0.02, 0.00),
    (1.15, 0.87, 0.88, 0.07, 0.01),
    (1.94, 0.82, 0.78, 0.03, 0.00),
    (2.50, 0.74, 0.69, -0.09, 0.03),
]
vertices = []
for ring_index, (height, width_x, width_y, shift_x, shift_y) in enumerate(levels):
    for i, (x, y) in enumerate(outline):
        chip = (-0.08 if ring_index == 4 and i in (0, 1) else 0.0)
        rise = ([0.0, 0.05, 0.02, 0.0, 0.08, -0.02, 0.02, -0.04][i] if ring_index == 4 else 0.0)
        vertices.append((x * width_x + shift_x + chip, y * width_y + shift_y, height + rise))

faces = []
face_materials = []
for level in range(len(levels) - 1):
    for i in range(len(outline)):
        j = (i + 1) % len(outline)
        faces.append((level * 8 + i, level * 8 + j, (level + 1) * 8 + j, (level + 1) * 8 + i))
        face_materials.append(2 if i in (3, 7) or (level == 2 and i == 5) else (1 if i in (1, 5) else 0))
faces.append(tuple(range(32, 40)))
face_materials.append(1)
mesh_object("Hewn spring waystone", vertices, faces, stone_faces, face_materials)


# A ragged earth-and-moss socket meets the meadow without the old bright
# spherical pedestal. The low skirt never carries gameplay collision.
segments = 12
ground_vertices = [(0.0, 0.0, 0.045)]
for i in range(segments):
    angle = math.tau * i / segments
    radius = 0.72 + random.uniform(-0.11, 0.10)
    ground_vertices.append((math.cos(angle) * radius, math.sin(angle) * radius * 0.70, random.uniform(0.055, 0.13)))
ground_faces = [(0, i + 1, (i + 1) % segments + 1) for i in range(segments)]
mesh_object("Moss grown into meadow", ground_vertices, ground_faces, [soil, moss, moss_light], [1 if i % 4 else 2 for i in range(segments)])


def irregular_rock(name, center, size, mat):
    count = 7
    verts = []
    for z, width in ((0.05, 0.95), (size[2], 0.75)):
        for i in range(count):
            a = math.tau * i / count
            jitter = 0.84 + random.random() * 0.28
            verts.append((center[0] + math.cos(a) * size[0] * width * jitter,
                          center[1] + math.sin(a) * size[1] * width * jitter,
                          z))
    sides = [(i, (i + 1) % count, (i + 1) % count + count, i + count) for i in range(count)]
    sides.append(tuple(range(count, 2 * count)))
    mesh_object(name, verts, sides, [mat])


for i, (x, y, radius) in enumerate(((-0.60, -0.21, 0.19), (0.61, 0.09, 0.15),
                                     (0.08, 0.48, 0.13), (-0.31, 0.38, 0.15))):
    irregular_rock("Half-buried mossy chip %d" % i, (x, y), (radius, radius * 0.75, 0.22),
                   moss if i % 2 else stone_faces[2])


def segment(name, a, b, radius, mat, vertices=6):
    direction = Vector(b) - Vector(a)
    middle = (Vector(a) + Vector(b)) / 2.0
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=direction.length, location=middle)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = direction.to_track_quat("Z", "Y").to_euler()
    obj.data.materials.append(mat)
    return obj


# Three shallow root seams tie the monolith to the grove rather than forming
# a neat circular plinth.
for i, (start, end) in enumerate((
    ((-0.35, -0.20, 0.12), (-0.78, -0.46, 0.08)),
    ((0.29, 0.17, 0.13), (0.83, 0.42, 0.07)),
    ((0.06, -0.25, 0.12), (0.23, -0.75, 0.07)),
)):
    segment("Root seam %d" % i, start, end, 0.055, soil, 7)


# The central cut has a dark recess and a quiet teal core. It is visible at
# gameplay zoom without turning each stone into a white VFX flare.
rune_points = [(-0.14, 1.55), (0.0, 1.78), (0.14, 1.55), (0.0, 1.31), (-0.14, 1.55)]
rune_edges = list(zip(rune_points[:-1], rune_points[1:]))
rune_edges.extend([((0.0, 1.78), (0.0, 1.98)), ((0.0, 1.31), (0.0, 1.12))])
for side in (-1.0, 1.0):
    for i, (a, b) in enumerate(rune_edges):
        outer_a = (a[0], side * 0.425, a[1])
        outer_b = (b[0], side * 0.425, b[1])
        inner_a = (a[0], side * 0.448, a[1])
        inner_b = (b[0], side * 0.448, b[1])
        segment("Carved rune recess %d %s" % (i, side), outer_a, outer_b, 0.038, groove)
        segment("Lume in cut %d %s" % (i, side), inner_a, inner_b, 0.019, glyph)


# The grove instantiates this marker seven times. Keep it a single imported
# mesh node rather than 33 nodes per marker; material boundaries survive the
# join, while scene-tree and transform costs do not multiply across the ring.
bpy.ops.object.select_all(action="SELECT")
bpy.context.view_layer.objects.active = bpy.data.objects["Hewn spring waystone"]
bpy.ops.object.convert(target="MESH")
bpy.ops.object.join()
bpy.context.object.name = "Lioraen spring waystone"

scene = bpy.context.scene
scene.unit_settings.system = "METRIC"
bpy.ops.wm.save_as_mainfile(filepath=output_blend)
bpy.ops.export_scene.gltf(filepath=output_glb, export_format="GLB", export_yup=True,
                          use_selection=False, export_apply=True)
print("MOONSTONE_R2", output_glb, "OBJECTS", len(bpy.data.objects))
