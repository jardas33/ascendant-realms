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
SOURCE = ROOT / "tools/character_art/sources/barrosan_clan_levy_astra_r2.blend"
EVIDENCE = Path(r"D:\CodexData\evidence\astra-character-quality-r2")
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


indigo = material("Levy | dyed indigo wool", (0.012, 0.032, 0.071), roughness=0.94)
bronze = material("Levy | aged bronze fittings", (0.26, 0.151, 0.050), 0.38, 0.71)
blue_paint = material("Levy | Sunblade painted timber", (1, 1, 1), 0.02, 0.85)
oak = material("Levy | shield edge oak", (0.075, 0.043, 0.025), 0, 0.87)

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
paint_texture = bpy.data.images.load(str(ROOT / "tools/character_art/textures/clan_levy_sunblade_shield.png"))
paint_texture.name = "ClanLevy_handpainted_sunblade_shield"
paint_texture.pack()
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
    # Tapered, split wool panels have an asymmetric hem and small folds.  The
    # upper edge follows the chest while the lower edge follows the pelvis.
    rows = [
        (1.38, 0.18, 0.10, {"UpperChest": 1.0}),
        (1.30, 0.21, 0.13, {"UpperChest": 0.8, "Chest": 0.2}),
        (1.19, 0.25, 0.18, {"Chest": 0.8, "Spine": 0.2}),
        (1.07, 0.28, 0.23, {"Chest": 0.4, "Spine": 0.6}),
        (0.93, 0.32, 0.29, {"Spine": 0.65, "Hips": 0.35}),
        (0.78, 0.36, 0.35, {"Spine": 0.25, "Hips": 0.75}),
        (0.63, 0.40, 0.40, {"Hips": 1.0}),
        (0.49, 0.43, 0.45, {"Hips": 1.0}),
        (0.477, 0.43, 0.45, {"Hips": 1.0}),
    ]
    count = 13
    verts, weights, faces, mat_ids, uvs = [], [], [], [], []
    for row_index, (z, half_width, y, bone_weights) in enumerate(rows):
        for column in range(count):
            t = column / (count - 1)
            # Outside edge fans out while inside edge opens toward the hem.
            inner = 0.012 + max(0, 1.0 - z / 1.38) * 0.13
            x = side * (inner + (half_width - inner) * t)
            fold = 0.018 * math.sin(t * math.pi * 6 + row_index * 0.32) * min(row_index / 5, 1)
            hem = 0.025 * math.sin(t * math.pi) + 0.012 * t * side if row_index >= len(rows) - 2 else 0
            verts.append((x, y + fold, z - hem))
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
    # The forearm carries a real three-layer curved shield: carved oak back,
    # narrow bronze binding, and a bowed painted face with UV-aligned heraldry.
    cx, cy, cz = 0.71, -0.22, 1.12
    outline = [(-0.265, 0.36), (0.265, 0.36), (0.310, 0.105),
               (0.245, -0.245), (0.0, -0.485), (-0.245, -0.245), (-0.310, 0.105)]
    verts, uvs = [], []
    for depth, scale in [(-0.012, 1.0), (-0.035, 0.87), (0.045, 1.0)]:
        for x, z in outline:
            verts.append((cx + x * scale, cy + depth, cz + z * scale))
            uvs.append((0.5 + x * scale / 0.70, 0.5 + (z * scale + 0.06) / 0.96))
    verts.extend(((cx, cy - 0.078, cz - 0.04), (cx, cy + 0.054, cz - 0.04)))
    uvs.extend(((0.5, 0.52), (0.5, 0.52)))
    faces, materials = [], []
    for i in range(len(outline)):
        following = (i + 1) % len(outline)
        faces.append((i, following, 7 + following, 7 + i))
        materials.append(1)
        faces.append((7 + i, 7 + following, 21))
        materials.append(0)
        faces.append((i, 14 + i, 14 + following, following))
        materials.append(2)
        faces.append((14 + following, 14 + i, 22))
        materials.append(2)
    shield = skinned_mesh("ClanLevy_CurvedSunbladeShield", verts, faces,
                          [blue_paint, bronze, oak], materials,
                          [{"LeftLowerArm": 1.0}] * len(verts), 0, uvs)
    return shield


for direction in (-1, 1):
    cloak_panel(direction)
    shoulder_clasp(direction)
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
