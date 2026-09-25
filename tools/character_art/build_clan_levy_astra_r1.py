"""Rebuild the Clan Levy's in-world silhouette on its production skeleton.

The saved baseline is the exact game GLB at 0052293d.  Existing mesh, bone
names, dimensions, and external Godot animation tracks stay intact.  All new
geometry is skinned to the existing armature and is presentation-only.
"""

import bpy
import math
import random
from pathlib import Path
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "tools/character_art/sources/barrosan_clan_levy_base.glb"
OUTPUT = ROOT / "production/ascendant-realms-godot/assets/characters/barrosan_clan_levy/barrosan_clan_levy.glb"
SOURCE = ROOT / "tools/character_art/sources/barrosan_clan_levy_astra_r1.blend"
EVIDENCE = Path(r"D:\CodexData\evidence\astra-character-quality-r1")
EVIDENCE.mkdir(parents=True, exist_ok=True)

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(BASE))
armature = next(o for o in bpy.data.objects if o.type == "ARMATURE")
base_mesh = next(o for o in bpy.data.objects if o.type == "MESH" and o.parent == armature)
base_mesh.name = "ClanLevy_BaseArmor"
armature.name = "Armature"
# The source GLB also contains a hidden Icosphere helper.  Keep the production
# skinned body and rig; never promote that helper to visible character geometry.
for obj in list(bpy.data.objects):
    if obj.type == "MESH" and obj is not base_mesh:
        bpy.data.objects.remove(obj, do_unlink=True)

# Bring the source soldier's washed-out stone/linen into the same light range
# as the other Barrosan units without replacing its authored material detail.
for node in base_mesh.data.materials[0].node_tree.nodes:
    image = getattr(node, "image", None)
    if image and image.name.startswith("Color_"):
        shaded = image.copy()
        shaded.name = "ClanLevy_worn_armor_albedo"
        pixels = list(shaded.pixels)
        for i in range(0, len(pixels), 4):
            pixels[i] *= 0.77
            pixels[i + 1] *= 0.74
            pixels[i + 2] *= 0.70
        shaded.pixels[:] = pixels
        shaded.pack()
        node.image = shaded


def material(name, color, metallic=0.0, roughness=0.72):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    surface = mat.node_tree.nodes.get("Principled BSDF")
    surface.inputs["Base Color"].default_value = (*color, 1)
    surface.inputs["Metallic"].default_value = metallic
    surface.inputs["Roughness"].default_value = roughness
    return mat


indigo = material("Levy | dyed indigo wool", (0.008, 0.022, 0.050), roughness=0.96)
bronze = material("Levy | worn brass embroidery", (0.34, 0.185, 0.045), 0.42, 0.59)
blue_paint = material("Levy | clan blue shield paint", (0.025, 0.085, 0.19), 0.06, 0.69)

# An authored woven albedo keeps the cloth from reading as a flat primitive.
# Variation is deliberately low frequency and quiet at RTS scale.
texture = bpy.data.images.new("ClanLevy_indigo_wool_albedo", width=512, height=512, alpha=True)
random.seed(1907)
pixels = []
for row in range(512):
    for col in range(512):
        weave = (0.5 if (row // 2 + col // 2) % 2 == 0 else -0.5) * 0.035
        drape = 0.10 * math.cos(col * 0.042) + 0.06 * math.sin(row * 0.018 + col * 0.021)
        grain = (random.random() - 0.5) * 0.065
        shade = 1.0 + weave + drape + grain
        pixels.extend((0.025 * shade, 0.064 * shade, 0.119 * shade, 1.0))
texture.pixels[:] = pixels
texture.pack()
texture.colorspace_settings.name = "sRGB"
texture_node = indigo.node_tree.nodes.new("ShaderNodeTexImage")
texture_node.image = texture
indigo.node_tree.links.new(texture_node.outputs["Color"], indigo.node_tree.nodes.get("Principled BSDF").inputs["Base Color"])
paint_texture = bpy.data.images.new("ClanLevy_weathered_shield_paint", width=512, height=512, alpha=True)
random.seed(3391)
paint_pixels = []
for row in range(512):
    for col in range(512):
        scratch = 0.80 if (row % 97 in (0, 1) and col % 13 < 4) else 1.0
        mottled = 1.0 + 0.11 * math.sin(row * 0.023 + col * 0.015) + (random.random() - 0.5) * 0.09
        value = mottled * scratch
        paint_pixels.extend((0.055 * value, 0.16 * value, 0.31 * value, 1.0))
paint_texture.pixels[:] = paint_pixels
paint_texture.pack()
paint_texture.colorspace_settings.name = "sRGB"
paint_node = blue_paint.node_tree.nodes.new("ShaderNodeTexImage")
paint_node.image = paint_texture
blue_paint.node_tree.links.new(paint_node.outputs["Color"], blue_paint.node_tree.nodes.get("Principled BSDF").inputs["Base Color"])


def skinned_mesh(name, verts, faces, materials, face_materials, vertex_weights, thickness=0, uvs=None):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    for mat in materials:
        mesh.materials.append(mat)
    for polygon, mat_index in zip(mesh.polygons, face_materials):
        polygon.material_index = mat_index
        polygon.use_smooth = True
    if uvs:
        uv_layer = mesh.uv_layers.new(name="Cloth weave")
        for polygon in mesh.polygons:
            for loop_index in polygon.loop_indices:
                uv_layer.data[loop_index].uv = uvs[mesh.loops[loop_index].vertex_index]
    groups = {}
    for bone in {bone for weights in vertex_weights for bone in weights}:
        groups[bone] = obj.vertex_groups.new(name=bone)
    for vertex_index, weights in enumerate(vertex_weights):
        for bone, weight in weights.items():
            groups[bone].add([vertex_index], weight, "REPLACE")
    modifier = obj.modifiers.new("Follow production skeleton", "ARMATURE")
    modifier.object = armature
    if thickness:
        solid = obj.modifiers.new("Woven thickness", "SOLIDIFY")
        solid.thickness = thickness
        solid.offset = 0
    obj.parent = armature
    return obj


def cloak_panel(side):
    # Two separate tails maintain a readable V-shaped split through walk and
    # attack cycles.  Ring weights shift from UpperChest to Hips.
    rows = [
        (1.37, 0.23, 0.10, {"UpperChest": 1.0}),
        (1.27, 0.27, 0.14, {"UpperChest": 0.76, "Chest": 0.24}),
        (1.11, 0.30, 0.20, {"Chest": 0.78, "Spine": 0.22}),
        (0.90, 0.36, 0.25, {"Spine": 0.45, "Hips": 0.55}),
        (0.67, 0.43, 0.32, {"Hips": 1.0}),
        (0.52, 0.47, 0.37, {"Hips": 1.0}),
        (0.495, 0.47, 0.37, {"Hips": 1.0}),
    ]
    count = 7
    verts, weights, faces, mat_ids, uvs = [], [], [], [], []
    for row_index, (z, half_width, y, bone_weights) in enumerate(rows):
        for column in range(count):
            t = column / (count - 1)
            # Outside edge fans out while inside edge opens toward the hem.
            inner = 0.015 + (1.0 - z / 1.37) * 0.11
            x = side * (inner + (half_width - inner) * t)
            fold = 0.014 * (1 if column % 2 else -1) * min(row_index, 4)
            verts.append((x, y + fold, z - (0.015 if column in (0, count - 1) else 0)))
            weights.append(bone_weights)
            uvs.append((t * 0.5 + (0.0 if side < 0 else 0.5), row_index / (len(rows) - 1)))
    for row in range(len(rows) - 1):
        for column in range(count - 1):
            a = row * count + column
            faces.append((a, a + 1, a + count + 1, a + count))
            mat_ids.append(1 if row == len(rows) - 2 else 0)
    return skinned_mesh(
        "ClanLevy_IndigoSplitCloak_%s" % ("Left" if side < 0 else "Right"),
        verts, faces, [indigo, bronze], mat_ids, weights, 0.012, uvs,
    )


def tabard_panel():
    rows = [
        (0.94, 0.245, 0.115, {"Hips": 1.0}),
        (0.78, 0.278, 0.125, {"Hips": 1.0}),
        (0.60, 0.298, 0.138, {"Hips": 1.0}),
        (0.575, 0.298, 0.138, {"Hips": 1.0}),
    ]
    verts, faces, mat_ids, weights, uvs = [], [], [], [], []
    for row, (z, y, width, bone_weights) in enumerate(rows):
        for col in range(7):
            t = col / 6
            x = -width + 2 * width * t
            hem_point = 0.025 * (1.0 - abs(2 * t - 1)) if row >= 2 else 0.0
            verts.append((x, -y - (0.012 if col == 3 else 0), z - hem_point))
            weights.append(bone_weights)
            uvs.append((t, row / (len(rows) - 1)))
    for row in range(len(rows) - 1):
        for col in range(6):
            a = row * 7 + col
            faces.append((a, a + 1, a + 8, a + 7))
            mat_ids.append(1 if row == len(rows) - 2 or col == 5 else 0)
    return skinned_mesh(
        "ClanLevy_ClanTabard", verts, faces, [indigo, bronze],
        mat_ids, weights, 0.009, uvs,
    )


def shoulder_clasp(side):
    x = side * 0.205
    z = 1.338
    y = -0.022
    vertices = [
        (x - 0.05, y, z), (x, y - 0.012, z + 0.04),
        (x + 0.05, y, z), (x, y - 0.012, z - 0.04),
        (x, y - 0.018, z),
    ]
    faces = [(0, 1, 4), (1, 2, 4), (2, 3, 4), (3, 0, 4)]
    return skinned_mesh("ClanLevy_BrassClasp_%s" % side, vertices, faces, [bronze], [0] * 4, [{"UpperChest": 1.0}] * 5, 0.008)


def clan_shield():
    # A full-size defensive silhouette carries the clan blue toward the camera
    # when the small body is only a few pixels tall.  All shield vertices follow
    # the existing left forearm; its combat/selection dimensions stay unchanged.
    cx, cy, cz = 0.75, -0.20, 1.11
    outline = [(-0.29, 0.42), (0.29, 0.42), (0.35, 0.13),
               (0.28, -0.25), (0.0, -0.56), (-0.28, -0.25), (-0.35, 0.13)]
    verts = []
    for depth, scale in [(0.00, 1.0), (-0.018, 0.88)]:
        for x, z in outline:
            verts.append((cx + x * scale, cy + depth, cz + z * scale))
    verts.append((cx, cy - 0.035, cz - 0.02))
    faces, materials = [], []
    for i in range(len(outline)):
        following = (i + 1) % len(outline)
        faces.append((i, following, 7 + following, 7 + i))
        materials.append(1)
        faces.append((7 + i, 7 + following, 14))
        materials.append(0)
    shield = skinned_mesh("ClanLevy_HeaterShield", verts, faces,
                          [blue_paint, bronze], materials,
                          [{"LeftLowerArm": 1.0}] * len(verts), 0.025,
                          [((x + 0.35) / 0.70, (z + 0.56) / 0.98) for x, _, z in [(v[0]-cx, v[1]-cy, v[2]-cz) for v in verts]])
    # A compact relief chevron, large enough to remain legible in the in-game
    # close view, without relying on an emissive decal or HUD icon.
    emblem = [
        (cx - 0.16, cy - 0.051, cz + 0.19),
        (cx, cy - 0.062, cz + 0.08),
        (cx + 0.16, cy - 0.051, cz + 0.19),
        (cx + 0.16, cy - 0.051, cz + 0.08),
        (cx, cy - 0.065, cz - 0.04),
        (cx - 0.16, cy - 0.051, cz + 0.08),
    ]
    skinned_mesh("ClanLevy_ShieldRelief", emblem,
                 [(0, 1, 4, 5), (1, 2, 3, 4)], [bronze], [0, 0],
                 [{"LeftLowerArm": 1.0}] * len(emblem), 0.01)
    return shield


for direction in (-1, 1):
    cloak_panel(direction)
    shoulder_clasp(direction)
tabard_panel()
clan_shield()

# The saved editable source keeps every authored surface and the imported rig.
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=str(SOURCE))
bpy.ops.object.select_all(action="DESELECT")
for obj in bpy.data.objects:
    if obj.type in {"MESH", "ARMATURE"}:
        obj.select_set(True)
bpy.context.view_layer.objects.active = armature
bpy.ops.export_scene.gltf(
    filepath=str(OUTPUT), export_format="GLB", use_selection=True,
    export_animations=False, export_skins=True, export_materials="EXPORT",
)
print("EXPORTED=" + str(OUTPUT))

# Review under the same neutral lighting and camera as the baseline.
world = bpy.context.scene.world
world.color = (0.16, 0.19, 0.22)
world.use_nodes = True
world.node_tree.nodes.get("Background").inputs[0].default_value = (0.18, 0.22, 0.25, 1)
world.node_tree.nodes.get("Background").inputs[1].default_value = 0.7

def area(name, location, power, size):
    data = bpy.data.lights.new(name, "AREA")
    data.energy = power
    data.shape = "DISK"
    data.size = size
    obj = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(obj)
    obj.location = location
    obj.rotation_euler = (Vector((0, 0, 0.9)) - obj.location).to_track_quat("-Z", "Y").to_euler()

area("Key", (3, -4, 5), 600, 4)
area("Fill", (-3, -1, 3), 260, 5)
area("Rim", (0, 3, 4), 800, 3)
camera_data = bpy.data.cameras.new("Review Camera")
camera = bpy.data.objects.new("Review Camera", camera_data)
bpy.context.collection.objects.link(camera)
bpy.context.scene.camera = camera
camera_data.type = "ORTHO"
camera_data.ortho_scale = 2.6
scene = bpy.context.scene
scene.render.engine = "CYCLES"
scene.cycles.samples = 48
scene.render.resolution_x = 840
scene.render.resolution_y = 960
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.view_settings.view_transform = "AgX"
for name, location in [("front", (2.8, -4.8, 2.5)), ("back", (-2.8, 4.8, 2.5)), ("rts", (3, -4.8, 6.5))]:
    camera.location = location
    camera.rotation_euler = (Vector((0, 0, 0.9)) - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = str(EVIDENCE / ("candidate_" + name + ".png"))
    bpy.ops.render.render(write_still=True)
    print("RENDERED=" + scene.render.filepath)
