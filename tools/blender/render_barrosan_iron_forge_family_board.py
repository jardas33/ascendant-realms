import bpy
import math
import os
from mathutils import Matrix, Vector


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PROJECT = os.path.join(ROOT, "production", "ascendant-realms-godot")
ASSETS = os.path.join(PROJECT, "assets", "environment", "buildings")
EVIDENCE = r"D:\CodexData\evidence\barrosan-iron-forge-original-b01-r1-20260925"
SOURCE_DIR = os.path.join(ROOT, "art-source", "blender", "barrosan_iron_forge_b01_r1")
OUTPUTS = [
    ("A01", "Clanhold", os.path.join(ASSETS, "barrosan_civic_keep_a01.glb"), 9.66, 24.0),
    ("A02", "War Hall", os.path.join(ASSETS, "barrosan_war_hall_a02.glb"), 5.75, 0.0),
    ("A03", "Clan Croft", os.path.join(ASSETS, "barrosan_clan_croft.glb"), 4.14, 0.0),
    ("B01", "Iron Forge", os.path.join(SOURCE_DIR, "barrosan_iron_forge_b01_r1.glb"), 4.60, 0.0),
]

os.makedirs(EVIDENCE, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)


def image_material(name, color, roughness=0.96):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1.0)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    return material


def bounds(objects):
    points = []
    for obj in objects:
        for vert in obj.data.vertices:
            points.append(obj.matrix_world @ vert.co)
    low = Vector((min(p.x for p in points), min(p.y for p in points), min(p.z for p in points)))
    high = Vector((max(p.x for p in points), max(p.y for p in points), max(p.z for p in points)))
    return low, high


def normalize_import(path, target_height, yaw_degrees):
    before = set(bpy.context.scene.objects)
    bpy.ops.import_scene.gltf(filepath=path)
    imported = [obj for obj in bpy.context.scene.objects if obj not in before]
    meshes = [obj for obj in imported if obj.type == "MESH"]
    if not meshes:
        raise RuntimeError("No mesh objects imported from " + path)
    # Flatten GLB node transforms into the temporary mesh copies, then apply one
    # common scale/yaw/grounding transform without changing the shipped files.
    for obj in meshes:
        world = obj.matrix_world.copy()
        obj.data = obj.data.copy()
        obj.parent = None
        obj.data.transform(world)
        obj.matrix_world = Matrix.Identity(4)
    low, high = bounds(meshes)
    current_height = high.z - low.z
    if current_height <= 0:
        raise RuntimeError("Invalid source height for " + path)
    factor = target_height / current_height
    anchor = Vector(((low.x + high.x) * 0.5, (low.y + high.y) * 0.5, low.z))
    rotate = Matrix.Rotation(math.radians(yaw_degrees), 4, "Z")
    transform = rotate @ Matrix.Scale(factor, 4) @ Matrix.Translation(-anchor)
    for obj in meshes:
        obj.data.transform(transform)
        obj.name = "Comparison_" + obj.name
    for obj in imported:
        if obj.type != "MESH" and obj.name in bpy.data.objects:
            bpy.data.objects.remove(obj, do_unlink=True)
    return meshes, {"source_height_m": round(current_height, 4), "presentation_height_m": target_height, "yaw_degrees": yaw_degrees}


def stage_and_camera():
    scene = bpy.context.scene
    ground = image_material("Board_Evidence_Ground", (0.12, 0.135, 0.118))
    bpy.ops.mesh.primitive_plane_add(size=120.0, location=(0.0, 0.0, -0.04))
    bpy.context.object.name = "Evidence_Only_Ground"
    bpy.context.object.data.materials.append(ground)
    world = bpy.data.worlds.new("Board_Soft_Sky")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.17, 0.20, 0.22, 1.0)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.40
    scene.world = world
    lights = (
        ("Board_Warm_Key", (5, 9, 14), 2350, (1.0, 0.80, 0.62), 9.0),
        ("Board_Cool_Fill", (-8, 7, 9), 1250, (0.65, 0.77, 1.0), 8.0),
        ("Board_Rim", (3, -8, 11), 1650, (1.0, 0.60, 0.36), 7.0),
    )
    for name, location, energy, color, size in lights:
        data = bpy.data.lights.new(name, "AREA")
        data.energy = energy
        data.color = color
        data.shape = "DISK"
        data.size = size
        light = bpy.data.objects.new(name, data)
        scene.collection.objects.link(light)
        light.location = location
        light.rotation_euler = (Vector((0, 0, 1.8)) - light.location).to_track_quat("-Z", "Y").to_euler()
    data = bpy.data.cameras.new("RTS_Zoom40_Camera")
    camera = bpy.data.objects.new("RTS_Zoom40_Camera", data)
    scene.collection.objects.link(camera)
    data.type = "PERSP"
    data.sensor_fit = "VERTICAL"
    data.sensor_height = 24.0
    data.lens = 12.0 / math.tan(math.radians(55.0 / 2.0))
    target = Vector((0.0, 0.0, 0.0))
    pitch = math.radians(55.0)
    zoom = 40.0
    camera.location = target + Vector((0.0, zoom * math.cos(pitch), zoom * math.sin(pitch)))
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = camera
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


records = []
for code, label, path, presentation_height, yaw in OUTPUTS:
    for obj in list(bpy.context.scene.objects):
        bpy.data.objects.remove(obj, do_unlink=True)
    bpy.context.view_layer.update()
    meshes, normalization = normalize_import(path, presentation_height, yaw)
    stage_and_camera()
    outfile = os.path.join(EVIDENCE, "%s_%s_zoom40.png" % (code, label.lower().replace(" ", "_")))
    bpy.context.scene.render.filepath = outfile
    bpy.ops.render.render(write_still=True)
    records.append({"code": code, "label": label, "source": os.path.relpath(path, ROOT).replace("\\", "/"), "capture": os.path.basename(outfile), **normalization})
    print("B01_FAMILY_FRAME=" + str(records[-1]))

with open(os.path.join(EVIDENCE, "b01_family_frames.json"), "w", encoding="utf-8") as stream:
    import json
    json.dump({"camera_zoom": 40, "camera_pitch_degrees": 55, "camera_yaw_degrees": 0, "vertical_fov_degrees": 55, "resolution": [1920, 1080], "frames": records}, stream, indent=2)
