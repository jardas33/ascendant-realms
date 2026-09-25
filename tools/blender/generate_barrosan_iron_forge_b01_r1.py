import bpy
import bmesh
import hashlib
import json
import math
import os
import struct
from mathutils import Vector


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PROJECT = os.path.join(ROOT, "production", "ascendant-realms-godot")
SOURCE_DIR = os.path.join(ROOT, "art-source", "blender", "barrosan_iron_forge_b01_r1")
EVIDENCE_DIR = r"D:\CodexData\evidence\barrosan-iron-forge-original-b01-r1-20260925"
REFERENCE_GLB = os.path.join(PROJECT, "assets", "environment", "buildings", "barrosan_war_hall_a02.glb")
BLEND_OUT = os.path.join(SOURCE_DIR, "barrosan_iron_forge_b01_r1.blend")
GLB_OUT = os.path.join(SOURCE_DIR, "barrosan_iron_forge_b01_r1.glb")
NORMAL_PREVIEW = os.path.join(EVIDENCE_DIR, "b01_zoom40_authoring_preview.png")
CLOSE_PREVIEW = os.path.join(EVIDENCE_DIR, "b01_zoom25_authoring_preview.png")
MANIFEST_OUT = os.path.join(SOURCE_DIR, "provenance.json")

os.makedirs(SOURCE_DIR, exist_ok=True)
os.makedirs(EVIDENCE_DIR, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def import_reference_materials():
    bpy.ops.import_scene.gltf(filepath=REFERENCE_GLB)
    names = {
        "stone": "BARROSAN_GRANITE",
        "dark_stone": "BARROSAN_DARK_SLATE",
        "limewash": "BARROSAN_LIMEWASH",
        "timber": "BARROSAN_AGED_TIMBER",
        "slate": "BARROSAN_DARK_SLATE",
    }
    result = {}
    for key, wanted in names.items():
        match = next((m for m in bpy.data.materials if m.name.upper() == wanted), None)
        if match is None:
            match = next((m for m in bpy.data.materials if wanted in m.name.upper()), None)
        if match is None:
            raise RuntimeError("Missing approved A02 material: " + wanted)
        result[key] = match
    # Keep the permitted project-owned image materials and remove the A02 model.
    for obj in list(bpy.context.scene.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    return result


MATS = import_reference_materials()
CUSTOM = {}


def principled_material(name, color, roughness=0.78, metallic=0.0, emission=None, strength=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    output = nodes.new("ShaderNodeOutputMaterial")
    shader = nodes.new("ShaderNodeBsdfPrincipled")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission is not None:
        socket = shader.inputs.get("Emission Color") or shader.inputs.get("Emission")
        if socket:
            socket.default_value = (*emission, 1.0)
        strength_socket = shader.inputs.get("Emission Strength")
        if strength_socket:
            strength_socket.default_value = strength
    mat.node_tree.links.new(shader.outputs["BSDF"], output.inputs["Surface"])
    CUSTOM[name] = mat
    return mat


MATS["iron"] = principled_material("B01_Blackened_Iron", (0.055, 0.064, 0.067), 0.42, 0.72)
MATS["ash"] = principled_material("B01_Sooted_Refractory", (0.075, 0.071, 0.061), 0.9, 0.0)
MATS["ember"] = principled_material("B01_Contained_Forge_Ember", (0.92, 0.205, 0.025), 0.52, 0.0, (1.0, 0.095, 0.012), 3.2)
MATS["coal"] = principled_material("B01_Deep_Coal", (0.12, 0.024, 0.008), 0.9, 0.0, (0.24, 0.018, 0.002), 0.35)

PARTS = {key: [] for key in ("stone", "dark_stone", "limewash", "timber", "slate", "iron", "ash", "ember", "coal")}


def add_uvs(mesh, scale):
    layer = mesh.uv_layers.new(name="UVMap")
    for poly in mesh.polygons:
        n = poly.normal
        if abs(n.z) >= max(abs(n.x), abs(n.y)):
            axes = (0, 1)
        elif abs(n.y) >= abs(n.x):
            axes = (0, 2)
        else:
            axes = (1, 2)
        for loop_index in poly.loop_indices:
            co = mesh.vertices[mesh.loops[loop_index].vertex_index].co
            layer.data[loop_index].uv = (co[axes[0]] * scale, co[axes[1]] * scale)


def register(obj, mat_key, uv_scale=0.48):
    mat = MATS[mat_key]
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    if obj.type == "MESH":
        add_uvs(obj.data, uv_scale)
        PARTS[mat_key].append(obj)
    return obj


def box(name, center, dimensions, mat_key, bevel=0.025, uv_scale=0.48, rotation=None):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if rotation is not None:
        obj.rotation_euler = rotation
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    register(obj, mat_key, uv_scale)
    if bevel > 0:
        modifier = obj.modifiers.new("Hand_Worn_Edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    return obj


def beam_between(name, a, b, thickness, mat_key, uv_scale=0.48):
    a, b = Vector(a), Vector(b)
    direction = b - a
    obj = box(name, (a + b) * 0.5, (thickness, direction.length, thickness), mat_key, min(0.025, thickness * 0.12), uv_scale)
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0, 1, 0)).rotation_difference(direction.normalized())
    return obj


def extruded_profile(name, points, axis, low, high, mat_key, uv_scale=0.48):
    """Extrude a convex 2-D profile. axis=y uses (x,z); axis=x uses (y,z)."""
    def point3(pair, depth):
        if axis == "y":
            return (pair[0], depth, pair[1])
        if axis == "x":
            return (depth, pair[0], pair[1])
        return (pair[0], pair[1], depth)

    count = len(points)
    verts = [point3(p, low) for p in points] + [point3(p, high) for p in points]
    faces = [tuple(range(count)), tuple(range(count, count * 2))]
    for i in range(count):
        j = (i + 1) % count
        faces.append((i, j, j + count, i + count))
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(verts, [], faces)
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    register(obj, mat_key, uv_scale)
    return obj


def truncated_square(name, cx, cy, z0, z1, bx, by, tx, ty, mat_key, uv_scale=0.52):
    verts = [
        (cx-bx/2, cy-by/2, z0), (cx+bx/2, cy-by/2, z0),
        (cx+bx/2, cy+by/2, z0), (cx-bx/2, cy+by/2, z0),
        (cx-tx/2, cy-ty/2, z1), (cx+tx/2, cy-ty/2, z1),
        (cx+tx/2, cy+ty/2, z1), (cx-tx/2, cy+ty/2, z1),
    ]
    faces = [(0, 3, 2, 1), (4, 5, 6, 7), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(verts, [], faces)
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    bm.to_mesh(mesh)
    bm.free()
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    register(obj, mat_key, uv_scale)
    return obj


def arch_wedge(name, cx, y_front, spring_z, inner_r, outer_r, angle0, angle1, depth, mat_key="stone"):
    eps = 0.014
    angle0 += eps
    angle1 -= eps
    def p(radius, angle):
        return (cx + radius * math.cos(angle), spring_z + radius * math.sin(angle))
    return extruded_profile(name, [p(outer_r, angle0), p(outer_r, angle1), p(inner_r, angle1), p(inner_r, angle0)], "y", y_front - depth, y_front, mat_key, 0.52)


# Recessed refractory furnace body; the portal is assembled around an actual arched opening.
FX, FY = -1.60, 1.08
body_front, body_back = FY + 1.18, FY - 1.18
base_z, furnace_top = 0.42, 2.76
box("Forge_Footing", (FX, FY, 0.25), (3.02, 2.68, 0.50), "stone", 0.10, 0.46)
# Broad, dark masonry piers and side returns leave the front mouth unobstructed.
box("Furnace_Left_Pier", (FX - 1.12, FY, 1.55), (0.70, 2.28, 2.22), "dark_stone", 0.045, 0.58)
box("Furnace_Right_Pier", (FX + 1.12, FY, 1.55), (0.70, 2.28, 2.22), "dark_stone", 0.045, 0.58)
box("Furnace_Rear_Mass", (FX, body_back + 0.18, 1.54), (1.20, 0.38, 2.20), "dark_stone", 0.035, 0.58)
box("Furnace_Upper_Lintel", (FX, body_front - 0.02, 2.50), (2.90, 0.44, 0.52), "dark_stone", 0.055, 0.56)
box("Furnace_Mouth_Sill", (FX, body_front + 0.08, 0.73), (1.40, 0.48, 0.24), "stone", 0.035, 0.50)
spring_z, inner_r, outer_r = 1.47, 0.74, 0.98
for i in range(9):
    arch_wedge("Furnace_Stone_Voussoir_%02d" % i, FX, body_front + 0.20, spring_z, inner_r, outer_r,
               math.pi * i / 9.0, math.pi * (i + 1) / 9.0, 0.44, "stone")
# The throat sits behind the stone arch; a controlled coal bed is visible through the opening.
mouth_profile = [
    (FX-inner_r, 0.83), (FX+inner_r, 0.83), (FX+inner_r, spring_z),
]
mouth_profile += [(FX + inner_r * math.cos(math.pi * i / 12), spring_z + inner_r * math.sin(math.pi * i / 12)) for i in range(1, 13)]
extruded_profile("Recessed_Black_Furnace_Throat", mouth_profile, "y", body_front + 0.04, body_front + 0.075, "ash", 0.5)
box("Visible_Ember_Bed", (FX, body_front + 0.095, 1.02), (0.94, 0.028, 0.18), "coal", 0.02, 0.5)
box("Forge_Core_Glow", (FX, body_front + 0.115, 1.24), (0.82, 0.025, 0.34), "ember", 0.02, 0.5)
box("Forge_Inner_Glow", (FX, body_front + 0.10, 1.48), (0.40, 0.02, 0.16), "ember", 0.02, 0.5)
# Deep chimney stem and outward-flared hood create the dominant role silhouette.
truncated_square("Sooted_Chimney_Stem", FX, FY - 0.30, 2.60, 3.57, 1.48, 1.48, 1.40, 1.40, "dark_stone", 0.62)
truncated_square("Flared_Furnace_Hood", FX, FY - 0.30, 3.48, 4.37, 1.40, 1.40, 2.12, 1.92, "dark_stone", 0.62)
box("Chimney_Iron_Collar", (FX, FY - 0.30, 3.50), (1.59, 1.59, 0.13), "iron", 0.035, 0.5)
# Four thick rim members leave a square, dark throat at the top of the hood.
hood_top_y = FY - 0.30
box("Hood_Rim_Front", (FX, hood_top_y + 0.78, 4.39), (2.16, 0.25, 0.14), "iron", 0.035, 0.5)
box("Hood_Rim_Back", (FX, hood_top_y - 0.78, 4.39), (2.16, 0.25, 0.14), "iron", 0.035, 0.5)
box("Hood_Rim_Left", (FX - 0.95, hood_top_y, 4.39), (0.25, 1.34, 0.14), "iron", 0.035, 0.5)
box("Hood_Rim_Right", (FX + 0.95, hood_top_y, 4.39), (0.25, 1.34, 0.14), "iron", 0.035, 0.5)
box("Hood_Throat_Shadow", (FX, hood_top_y, 4.325), (1.55, 1.05, 0.015), "ash", 0.0, 0.5)
box("Hood_Throat_Heat", (FX, hood_top_y + 0.10, 4.34), (0.56, 0.05, 0.018), "coal", 0.0, 0.5)

# The broad, low limewashed workshop is the second large mass behind the furnace.
HX, HY = 0.18, -0.32
HOUSE_W, HOUSE_D = 4.70, 3.35
HOUSE_FRONT, HOUSE_BACK = HY + HOUSE_D/2, HY - HOUSE_D/2
box("Workshop_Granite_Foundation", (HX, HY, 0.24), (5.12, 3.72, 0.48), "stone", 0.09, 0.46)
box("Workshop_Limewashed_Body", (HX, HY, 1.54), (HOUSE_W, HOUSE_D, 2.12), "limewash", 0.035, 0.30)
extruded_profile("Workshop_Front_Gable", [(HX-HOUSE_W/2, 2.58), (HX, 3.74), (HX+HOUSE_W/2, 2.58)],
                 "y", HOUSE_FRONT-0.08, HOUSE_FRONT+0.07, "limewash", 0.30)
extruded_profile("Workshop_Rear_Gable", [(HX-HOUSE_W/2, 2.58), (HX, 3.74), (HX+HOUSE_W/2, 2.58)],
                 "y", HOUSE_BACK-0.07, HOUSE_BACK+0.08, "limewash", 0.30)
# Two heavy slate planes, with deep eaves and exposed ridge timber.
roof_y0, roof_y1 = HOUSE_BACK - 0.18, HOUSE_FRONT + 0.18
extruded_profile("Main_Roof_Left_Slate", [(HX-2.58, 2.62), (HX, 3.90), (HX, 3.74), (HX-2.58, 2.47)],
                 "y", roof_y0, roof_y1, "slate", 0.63)
extruded_profile("Main_Roof_Right_Slate", [(HX, 3.90), (HX+2.58, 2.62), (HX+2.58, 2.47), (HX, 3.74)],
                 "y", roof_y0, roof_y1, "slate", 0.63)
box("Roof_Ridge_Timber", (HX, (roof_y0+roof_y1)/2, 3.80), (0.20, roof_y1-roof_y0+0.08, 0.18), "timber", 0.035, 0.52)
for sx in (-1, 1):
    xedge = HX + sx * 2.55
    box("Roof_Eave_Beam_%s" % sx, (xedge, HY, 2.57), (0.18, HOUSE_D+0.48, 0.20), "timber", 0.035, 0.52)
    beam_between("Front_Gable_Rafter_%s" % sx, (HX, HOUSE_FRONT+0.16, 3.78), (xedge, HOUSE_FRONT+0.16, 2.60), 0.16, "timber", 0.52)
    beam_between("Rear_Gable_Rafter_%s" % sx, (HX, HOUSE_BACK-0.16, 3.78), (xedge, HOUSE_BACK-0.16, 2.60), 0.14, "timber", 0.52)
# Front-facing door and one large workshop window remain visible beside the furnace.
door_x = 1.25
box("Workshop_Door_Stone_Threshold", (door_x, HOUSE_FRONT+0.15, 0.55), (1.40, 0.28, 0.18), "stone", 0.025, 0.46)
box("Workshop_Door_Timber", (door_x, HOUSE_FRONT+0.14, 1.40), (1.02, 0.13, 1.58), "timber", 0.035, 0.54)
box("Workshop_Door_Upper_Crossbar", (door_x, HOUSE_FRONT+0.22, 2.16), (1.16, 0.12, 0.12), "iron", 0.02, 0.5)
box("Workshop_Window_Reveal", (2.05, HOUSE_FRONT+0.13, 1.86), (0.62, 0.14, 0.62), "timber", 0.025, 0.5)
box("Workshop_Window_Dark_Glass", (2.05, HOUSE_FRONT+0.22, 1.87), (0.39, 0.035, 0.39), "ash", 0.0, 0.5)
box("Workshop_Window_Center_Mullion", (2.05, HOUSE_FRONT+0.25, 1.87), (0.055, 0.04, 0.42), "timber", 0.008, 0.5)

# Open-front, open-right working bay: the canopy and its anvilstation read at ordinary RTS scale.
bay_x0, bay_x1 = 1.12, 3.48
bay_back, bay_front = 0.74, 3.02
extruded_profile("Open_Bay_Slate_Canopy", [(bay_back, 3.36), (bay_front, 2.78), (bay_front, 2.61), (bay_back, 3.19)],
                 "x", bay_x0-0.10, bay_x1+0.10, "slate", 0.61)
for x in (1.28, 3.30):
    box("Open_Bay_Timber_Post_%0.2f" % x, (x, bay_front-0.08, 1.54), (0.22, 0.23, 2.62), "timber", 0.035, 0.54)
    box("Open_Bay_Stone_Pad_%0.2f" % x, (x, bay_front-0.08, 0.20), (0.43, 0.42, 0.40), "stone", 0.055, 0.48)
box("Open_Bay_Front_Beam", ((bay_x0+bay_x1)/2, bay_front-0.08, 2.83), (bay_x1-bay_x0+0.38, 0.24, 0.20), "timber", 0.035, 0.54)
box("Open_Bay_Wall_Ledger", ((bay_x0+bay_x1)/2, bay_back+0.05, 3.32), (bay_x1-bay_x0+0.20, 0.22, 0.20), "timber", 0.035, 0.54)
box("Anvil_Stump", (2.35, 2.07, 0.75), (0.64, 0.62, 0.86), "timber", 0.055, 0.52)
box("Anvil_Body", (2.35, 2.07, 1.29), (0.78, 0.42, 0.30), "iron", 0.06, 0.5)
beam_between("Anvil_Horn", (2.30, 2.07, 1.32), (1.79, 2.07, 1.39), 0.18, "iron", 0.5)
box("Anvil_Heel", (2.71, 2.07, 1.34), (0.24, 0.44, 0.20), "iron", 0.035, 0.5)
box("Quench_Trough_Wood", (2.98, 1.50, 0.58), (0.70, 0.42, 0.42), "timber", 0.055, 0.5)
box("Quench_Trough_Water", (2.98, 1.50, 0.80), (0.55, 0.27, 0.025), "iron", 0.005, 0.5)


def join_material_parts():
    joined = []
    for key, objects in PARTS.items():
        objects = [obj for obj in objects if obj and obj.name in bpy.data.objects]
        if not objects:
            continue
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.select_set(True)
        active = objects[0]
        bpy.context.view_layer.objects.active = active
        if len(objects) > 1:
            bpy.ops.object.join()
        active.name = "B01_" + key.title().replace("_", "")
        active.data.name = active.name + "_Mesh"
        joined.append(active)
    return joined


ASSET_OBJECTS = join_material_parts()
if not ASSET_OBJECTS or max(o.dimensions.z for o in ASSET_OBJECTS) > 4.75:
    raise RuntimeError("B01 geometry is missing or exceeds the authorized 4.75m visible envelope")

# Asset-only source package; the render stage is added after the source is saved.
bpy.context.scene.render.engine = "BLENDER_EEVEE"
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)

bpy.ops.object.select_all(action="DESELECT")
for obj in ASSET_OBJECTS:
    obj.select_set(True)
bpy.context.view_layer.objects.active = ASSET_OBJECTS[0]
bpy.ops.export_scene.gltf(
    filepath=GLB_OUT,
    export_format="GLB",
    use_selection=True,
    export_apply=True,
    export_image_format="AUTO",
    export_image_quality=92,
    export_materials="EXPORT",
    export_cameras=False,
    export_lights=False,
)


def glb_document(path):
    with open(path, "rb") as stream:
        magic, version, length = struct.unpack("<4sII", stream.read(12))
        if magic != b"glTF" or version != 2:
            raise RuntimeError("Export did not produce a valid GLB v2 file")
        chunk_length, chunk_type = struct.unpack("<II", stream.read(8))
        if chunk_type != 0x4E4F534A:
            raise RuntimeError("GLB JSON chunk missing")
        document = json.loads(stream.read(chunk_length).decode("utf-8"))
    return document


doc = glb_document(GLB_OUT)
images = doc.get("images", [])
if not images or any("uri" in image for image in images):
    raise RuntimeError("B01 GLB must contain packed images with no external URI")
if any("bufferView" not in image for image in images):
    raise RuntimeError("B01 GLB has a non-embedded image reference")
mesh_count = len(doc.get("meshes", []))
if mesh_count > 12:
    raise RuntimeError("B01 exceeded the moderate-mesh-count target")
triangle_count = 0
for mesh in doc.get("meshes", []):
    for primitive in mesh.get("primitives", []):
        accessor = doc["accessors"][primitive["indices"]]
        triangle_count += int(accessor["count"]) // 3

verts_world = []
for obj in ASSET_OBJECTS:
    for vertex in obj.data.vertices:
        verts_world.append(obj.matrix_world @ vertex.co)
bounds_min = [min(v[i] for v in verts_world) for i in range(3)]
bounds_max = [max(v[i] for v in verts_world) for i in range(3)]
used_materials = sorted({material.name for obj in ASSET_OBJECTS for material in obj.data.materials if material})
image_records = [{"name": image.get("name", ""), "mimeType": image.get("mimeType", "embedded"), "bufferView": image.get("bufferView")} for image in images]


def configure_stage():
    ground_mat = principled_material("Evidence_Neutral_Highland_Ground", (0.105, 0.122, 0.102), 0.96)
    bpy.ops.mesh.primitive_plane_add(size=100, location=(0, 0, -0.035))
    ground = bpy.context.object
    ground.name = "Evidence_Only_Ground"
    ground.data.materials.append(ground_mat)
    world = bpy.data.worlds.new("Evidence_Soft_Sky")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.16, 0.19, 0.21, 1.0)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.36
    bpy.context.scene.world = world
    for name, location, power, color, size in (
        ("Warm_Sky_Key", (5, 9, 14), 2300, (1.0, 0.78, 0.56), 9.0),
        ("Cool_Front_Fill", (-8, 7, 8), 1100, (0.60, 0.74, 1.0), 8.0),
        ("Soft_Rim", (3, -8, 10), 1550, (1.0, 0.54, 0.28), 7.0),
    ):
        data = bpy.data.lights.new(name, "AREA")
        data.energy = power
        data.color = color
        data.shape = "DISK"
        data.size = size
        light = bpy.data.objects.new(name, data)
        bpy.context.collection.objects.link(light)
        light.location = location
        light.rotation_euler = (Vector((0, 0, 1.8)) - light.location).to_track_quat("-Z", "Y").to_euler()
    scene = bpy.context.scene
    scene.render.engine = "BLENDER_EEVEE"
    scene.eevee.taa_render_samples = 64
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.render.film_transparent = False
    scene.view_settings.view_transform = "AgX"
    scene.view_settings.look = "AgX - Medium High Contrast"
    camera_data = bpy.data.cameras.new("RTS_Zoom40_Camera")
    camera = bpy.data.objects.new("RTS_Zoom40_Camera", camera_data)
    bpy.context.collection.objects.link(camera)
    camera_data.type = "PERSP"
    camera_data.sensor_fit = "VERTICAL"
    camera_data.sensor_height = 24.0
    camera_data.lens = 12.0 / math.tan(math.radians(55.0 / 2.0))
    scene.camera = camera
    return camera


camera = configure_stage()
scene = bpy.context.scene
for zoom, filepath in ((40.0, NORMAL_PREVIEW), (25.0, CLOSE_PREVIEW)):
    target = Vector((0.0, 0.10, 1.55))
    pitch = math.radians(55.0)
    yaw = math.radians(22.0)
    horizontal = zoom * math.cos(pitch)
    vertical = zoom * math.sin(pitch)
    camera.location = target + Vector((math.sin(yaw) * horizontal, math.cos(yaw) * horizontal, vertical))
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = filepath
    bpy.ops.render.render(write_still=True)

# Save hashes and auditable source lineage after the final artifacts have been emitted.
bpy.ops.wm.save_as_mainfile(filepath=BLEND_OUT)
manifest = {
    "asset_id": "BARROSAN_IRON_FORGE_ORIGINAL_B01_R1",
    "status": "PHASE_A_PRE-FLIGHT_ONLY_NOT_WIRED_TO_GAMEPLAY",
    "geometry_authorship": "Original procedural mesh design authored in Blender Python for this candidate.",
    "material_provenance": {
        "reused_project_owned_source": "production/ascendant-realms-godot/assets/environment/buildings/barrosan_war_hall_a02.glb",
        "source_sha256": sha256(REFERENCE_GLB),
        "reused_materials": ["BARROSAN_AGED_TIMBER", "BARROSAN_DARK_SLATE", "BARROSAN_GRANITE", "BARROSAN_LIMEWASH"],
        "custom_materials": ["B01_Blackened_Iron", "B01_Sooted_Refractory", "B01_Contained_Forge_Ember", "B01_Deep_Coal"],
        "external_textures": False,
    },
    "source_blend": {"path": os.path.relpath(BLEND_OUT, ROOT).replace("\\", "/"), "sha256": sha256(BLEND_OUT)},
    "glb": {"path": os.path.relpath(GLB_OUT, ROOT).replace("\\", "/"), "sha256": sha256(GLB_OUT), "bytes": os.path.getsize(GLB_OUT)},
    "geometry": {
        "mesh_count": mesh_count,
        "triangle_count": triangle_count,
        "material_count": len(used_materials),
        "materials": used_materials,
        "embedded_images": image_records,
        "bounding_box_m": {"min": [round(v, 4) for v in bounds_min], "max": [round(v, 4) for v in bounds_max], "size": [round(bounds_max[i]-bounds_min[i], 4) for i in range(3)]},
    },
    "evidence": [os.path.basename(NORMAL_PREVIEW), os.path.basename(CLOSE_PREVIEW)],
    "validation": {"valid_glb_v2": True, "all_images_embedded": True, "external_image_uris": 0, "phase_b_runtime_fit": "NOT_TESTED"},
}
with open(MANIFEST_OUT, "w", encoding="utf-8") as stream:
    json.dump(manifest, stream, indent=2)
print("B01_PHASE_A_AUTHORING=" + json.dumps(manifest, sort_keys=True))
