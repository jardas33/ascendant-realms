"""Create B01 R2 from the preserved R1 source, presenting its working face to RTS yaw 0."""

import hashlib
import json
import math
import os
import struct

import bpy
from mathutils import Matrix, Vector


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
R1_DIR = os.path.join(ROOT, "art-source", "blender", "barrosan_iron_forge_b01_r1")
R2_DIR = os.path.join(ROOT, "art-source", "blender", "barrosan_iron_forge_b01_r2")
EVIDENCE_DIR = r"D:\CodexData\evidence\barrosan-iron-forge-original-b01-r2-20260925"
R1_BLEND = os.path.join(R1_DIR, "barrosan_iron_forge_b01_r1.blend")
R1_GLB = os.path.join(R1_DIR, "barrosan_iron_forge_b01_r1.glb")
R2_BLEND = os.path.join(R2_DIR, "barrosan_iron_forge_b01_r2.blend")
R2_GLB = os.path.join(R2_DIR, "barrosan_iron_forge_b01_r2.glb")
PREVIEW40 = os.path.join(EVIDENCE_DIR, "b01_r2_authoring_zoom40.png")
PREVIEW25 = os.path.join(EVIDENCE_DIR, "b01_r2_authoring_zoom25.png")
MANIFEST = os.path.join(R2_DIR, "provenance.json")


def sha256(path):
    digest = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def mesh_bounds(objects):
    points = [obj.matrix_world @ vertex.co for obj in objects for vertex in obj.data.vertices]
    if not points:
        raise RuntimeError("B01 R2 contains no mesh vertices")
    minimum = Vector(tuple(min(point[axis] for point in points) for axis in range(3)))
    maximum = Vector(tuple(max(point[axis] for point in points) for axis in range(3)))
    return minimum, maximum


def glb_document(path):
    with open(path, "rb") as stream:
        magic, version, _length = struct.unpack("<4sII", stream.read(12))
        if magic != b"glTF" or version != 2:
            raise RuntimeError("B01 R2 export is not a valid GLB v2 file")
        chunk_length, chunk_type = struct.unpack("<II", stream.read(8))
        if chunk_type != 0x4E4F534A:
            raise RuntimeError("B01 R2 GLB JSON chunk is missing")
        return json.loads(stream.read(chunk_length).decode("utf-8"))


os.makedirs(R2_DIR, exist_ok=True)
os.makedirs(EVIDENCE_DIR, exist_ok=True)
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.open_mainfile(filepath=R1_BLEND)

asset_objects = sorted(
    [obj for obj in bpy.data.objects if obj.type == "MESH" and obj.name.startswith("B01_")],
    key=lambda obj: obj.name,
)
if len(asset_objects) != 9:
    raise RuntimeError("Expected the nine preserved B01 R1 per-material meshes")

before_min, before_max = mesh_bounds(asset_objects)
pivot = Vector(((before_min.x + before_max.x) * 0.5, (before_min.y + before_max.y) * 0.5, 0.0))
rotate_to_runtime_face = (
    Matrix.Translation(pivot)
    @ Matrix.Rotation(math.pi, 4, "Z")
    @ Matrix.Translation(-pivot)
)
for obj in asset_objects:
    obj.matrix_world = rotate_to_runtime_face @ obj.matrix_world
bpy.context.view_layer.update()

after_min, after_max = mesh_bounds(asset_objects)
before_size = before_max - before_min
after_size = after_max - after_min
if any(abs(before_size[axis] - after_size[axis]) > 0.001 for axis in range(3)):
    raise RuntimeError("R2 yaw change altered the proven B01 visible envelope")
if any(abs(before_min[axis] - after_min[axis]) > 0.001 for axis in range(3)):
    raise RuntimeError("R2 yaw change shifted the proven B01 asset bounds")

bpy.ops.object.select_all(action="DESELECT")
for obj in asset_objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = asset_objects[0]
bpy.ops.wm.save_as_mainfile(filepath=R2_BLEND)
bpy.ops.export_scene.gltf(
    filepath=R2_GLB,
    export_format="GLB",
    use_selection=True,
    export_apply=True,
    export_image_format="AUTO",
    export_image_quality=92,
    export_materials="EXPORT",
    export_cameras=False,
    export_lights=False,
)

document = glb_document(R2_GLB)
images = document.get("images", [])
if not images or any("uri" in image or "bufferView" not in image for image in images):
    raise RuntimeError("R2 must retain R1's embedded material images without external URIs")
mesh_count = len(document.get("meshes", []))
if mesh_count > 12:
    raise RuntimeError("B01 R2 exceeded the moderate-mesh-count target")
triangle_count = sum(
    int(document["accessors"][primitive["indices"]]["count"]) // 3
    for mesh in document.get("meshes", [])
    for primitive in mesh.get("primitives", [])
)

scene = bpy.context.scene
camera = bpy.data.objects.get("RTS_Zoom40_Camera")
if camera is None:
    raise RuntimeError("Preserved R1 authoring scene is missing its RTS review camera")
scene.camera = camera
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.resolution_percentage = 100
target = Vector((0.0, 0.10, 1.55))
pitch = math.radians(55.0)
authoring_yaw = math.radians(180.0)
for zoom, filepath in ((40.0, PREVIEW40), (25.0, PREVIEW25)):
    horizontal = zoom * math.cos(pitch)
    vertical = zoom * math.sin(pitch)
    camera.location = target + Vector((math.sin(authoring_yaw) * horizontal, math.cos(authoring_yaw) * horizontal, vertical))
    camera.rotation_euler = (target - camera.location).to_track_quat("-Z", "Y").to_euler()
    scene.render.filepath = filepath
    bpy.ops.render.render(write_still=True)

materials = sorted({material.name for obj in asset_objects for material in obj.data.materials if material})
manifest = {
    "asset_id": "BARROSAN_IRON_FORGE_ORIGINAL_B01_R2",
    "status": "R2_VISUAL_REFINEMENT_PENDING_INDEPENDENT_REVIEW",
    "parent_asset_id": "BARROSAN_IRON_FORGE_ORIGINAL_B01_R1",
    "parent_blend_sha256": sha256(R1_BLEND),
    "parent_glb_sha256": sha256(R1_GLB),
    "geometry_authorship": "Preserved R1 authored meshes, yaw-rotated 180 degrees around the ground-footprint bounds center to expose the designed furnace/work bay at canonical runtime yaw 0.",
    "gameplay_or_footprint_changes": False,
    "transform": {"authoring_axis": "Z-up", "yaw_degrees": 180, "pivot": [round(value, 5) for value in pivot]},
    "source_blend": {"path": os.path.relpath(R2_BLEND, ROOT).replace("\\", "/"), "sha256": sha256(R2_BLEND)},
    "glb": {"path": os.path.relpath(R2_GLB, ROOT).replace("\\", "/"), "sha256": sha256(R2_GLB), "bytes": os.path.getsize(R2_GLB)},
    "geometry": {
        "mesh_count": mesh_count,
        "triangle_count": triangle_count,
        "materials": materials,
        "embedded_images": [{"name": image.get("name", ""), "mimeType": image.get("mimeType", "embedded"), "bufferView": image.get("bufferView")} for image in images],
        "before_bounds_min": [round(value, 4) for value in before_min],
        "after_bounds_min": [round(value, 4) for value in after_min],
        "before_bounds_max": [round(value, 4) for value in before_max],
        "after_bounds_max": [round(value, 4) for value in after_max],
        "size_m": [round(value, 4) for value in after_size],
    },
    "evidence": [os.path.basename(PREVIEW40), os.path.basename(PREVIEW25)],
    "validation": {"valid_glb_v2": True, "all_images_embedded": True, "external_image_uris": 0, "runtime_fit": "PENDING_HEADED_R2_RUN"},
}
with open(MANIFEST, "w", encoding="utf-8") as stream:
    json.dump(manifest, stream, indent=2)

print("PASS_BARROSAN_IRON_FORGE_B01_R2_EXPORT")
print(json.dumps(manifest, indent=2))
