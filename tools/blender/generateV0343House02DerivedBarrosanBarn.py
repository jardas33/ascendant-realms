"""v0.343 House 02-derived Barrosan barn visual-preflight source.

This script opens the accepted repository-authored House 02 source, saves a
working duplicate, and builds the barn from copied House 02 material and roof
construction grammar.  It deliberately does not read the rejected v0.341 or
v0.342 visible assets.
"""
from __future__ import annotations

import hashlib
import json
import math
import shutil
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
FROZEN = ROOT / "art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend"
SOURCE = ROOT / "art-source/blender/v0343"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0343"
OUT_BLEND = SOURCE / "house02_derived_barrosan_barn_visual_preflight.blend"
OUT_GLB = ASSETS / "house02_derived_barrosan_barn_visual_preflight.glb"
LINEAGE = SOURCE / "v0343-source-lineage.json"

FROZEN_BLEND_SHA = "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6"
FROZEN_GLB_SHA = "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89"
HOUSE02_ROOF_MESH = None


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def clear_visible_source_objects() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    # Keep the copied House 02 mesh datablocks available so the accepted roof
    # system can be duplicated after the visible source objects are removed.
    for collection in (bpy.data.curves, bpy.data.cameras, bpy.data.lights):
        for item in list(collection):
            if item.users == 0:
                collection.remove(item)


def copied_material(source_name: str, name: str):
    source = bpy.data.materials.get(source_name)
    if source is None:
        raise RuntimeError(f"House 02 material missing: {source_name}")
    material = source.copy()
    material.name = name
    material["v0343_house02_derived"] = True
    material["source_house02_material"] = source_name
    return material


def box(name: str, center, dimensions, material, bevel: float = 0.0, rotation_x: float = 0.0):
    bpy.ops.mesh.primitive_cube_add(location=center, rotation=(rotation_x, 0.0, 0.0))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    if bevel:
        modifier = obj.modifiers.new("subtle_masonry_edge", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
        modifier.limit_method = "ANGLE"
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(False)
    obj["v0343_source_grammar"] = "duplicated House 02 material and construction vocabulary"
    obj["no_gameplay"] = True
    return obj


def triangular_gable(name: str, y: float, material):
    x = 3.8
    z = 5.28
    ridge = 6.62
    depth = 0.32
    vertices = [(-x, y - depth / 2, z), (x, y - depth / 2, z), (0, y - depth / 2, ridge),
                (-x, y + depth / 2, z), (x, y + depth / 2, z), (0, y + depth / 2, ridge)]
    faces = [(0, 1, 2), (5, 4, 3), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)]
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(material)
    uv_layer = mesh.uv_layers.new(name="House02GraniteUV")
    for loop in mesh.loops:
        vertex = mesh.vertices[loop.vertex_index].co
        uv_layer.data[loop.index].uv = ((vertex.x / (x * 2.0)) + 0.5, (vertex.z - z) / (ridge - z))
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj["v0343_role"] = "resolved granite gable"
    return obj


def roof_course(name: str, side: int, row: int, slate):
    slope = math.atan2(1.38, 2.86)
    y = side * (0.18 + row * 0.285)
    z = 6.62 - row * 0.138
    # A shallow overlapping strip follows one of two principal slopes.
    obj = box(name, (0.0, y, z), (7.82, 0.66, 0.11), slate, 0.018, -side * slope)
    obj["v0343_roof_course"] = row + 1
    obj["v0343_principal_slope"] = side
    return obj


def door_set(prefix: str, x: float, z: float, width: float, height: float, y: float, timber, iron, granite, dark):
    box(prefix + "_Recess", (x, y, z), (width, 0.10, height), dark, 0.01)
    leaf_width = width / 2.0 - 0.045
    for leaf, offset in (("Left", -width / 4.0), ("Right", width / 4.0)):
        box(prefix + "_" + leaf + "_TimberLeaf", (x + offset, y - 0.075, z), (leaf_width, 0.10, height - 0.08), timber, 0.018)
        for plank in range(4):
            px = x + offset - leaf_width / 2.0 + (plank + 0.5) * leaf_width / 4.0
            box(prefix + "_" + leaf + "_Board_%02d" % plank, (px, y - 0.135, z), (0.045, 0.035, height - 0.18), timber, 0.008)
        box(prefix + "_" + leaf + "_IronStrap", (x + offset, y - 0.16, z), (leaf_width * 0.82, 0.025, 0.055), iron, 0.004, math.radians(25 if leaf == "Left" else -25))
    box(prefix + "_Granite_Lintel", (x, y - 0.015, z + height / 2.0 + 0.14), (width + 0.34, 0.34, 0.28), granite, 0.045)
    box(prefix + "_Granite_Threshold", (x, y - 0.08, z - height / 2.0 - 0.10), (width + 0.30, 0.42, 0.18), granite, 0.035)
    box(prefix + "_Granite_LeftJamb", (x - width / 2.0 - 0.11, y - 0.01, z), (0.24, 0.32, height + 0.22), granite, 0.035)
    box(prefix + "_Granite_RightJamb", (x + width / 2.0 + 0.11, y - 0.01, z), (0.24, 0.32, height + 0.22), granite, 0.035)


def add_corner_stones(granite):
    for x in (-3.77, 3.77):
        for z, width in ((0.82, 0.48), (1.52, 0.42), (2.22, 0.50), (3.10, 0.44), (4.04, 0.48), (4.88, 0.42)):
            box("V0343_CornerStone_%s_%s" % ("L" if x < 0 else "R", str(z).replace(".", "_")), (x, -2.68, z), (width, 0.20, 0.42), granite, 0.025)


def build_barn():
    granite_front = copied_material("V0338_GoldCandidate_Rubble_Front", "V0343_House02Derived_Granite_Front")
    granite_rear = copied_material("V0338_GoldCandidate_Rubble_Rear", "V0343_House02Derived_Granite_Rear")
    granite_gable = copied_material("V0338_GoldCandidate_Rubble_Rear", "V0343_House02Derived_Granite_Gable")
    dressed = copied_material("V0338_GoldCandidate_Rubble_Front", "V0343_House02Derived_Dressed_Granite")
    slate = copied_material("V0334_Weathered_Slate", "V0343_House02Derived_Weathered_Slate")
    timber = copied_material("V0334_Weathered_Timber", "V0343_House02Derived_Weathered_Timber")
    iron = copied_material("V0334_Iron", "V0343_House02Derived_Iron")
    dark = copied_material("V0334_Interior_Recess", "V0343_House02Derived_Recess")

    root = bpy.data.objects.new("V0343_House02_Derived_Barrosan_Barn", None)
    bpy.context.collection.objects.link(root)
    # Compact closed rectangular masonry volume: 7.6 x 5.2 m, 5.2 m walls,
    # 6.62 m ridge.  The visible object is horizontally grounded.
    pieces = [
        ("V0343_Front_Wall_Left", (-2.70, -2.60, 2.86), (2.20, 0.34, 4.82), granite_gable),
        ("V0343_Front_Wall_Right", (2.70, -2.60, 2.86), (2.20, 0.34, 4.82), granite_gable),
        ("V0343_Front_Wall_LowerToUpper", (0.0, -2.60, 3.16), (3.10, 0.34, 0.62), granite_gable),
        ("V0343_Front_Wall_UpperHeader", (0.0, -2.60, 5.08), (3.10, 0.34, 0.34), granite_gable),
        ("V0343_Front_Wall_UpperLeftPier", (-1.30, -2.60, 4.18), (0.50, 0.34, 1.50), granite_gable),
        ("V0343_Front_Wall_UpperRightPier", (1.30, -2.60, 4.18), (0.50, 0.34, 1.50), granite_gable),
        ("V0343_Rear_Wall_Core", (0.0, 2.60, 2.86), (7.60, 0.34, 4.82), granite_rear),
        ("V0343_Left_GableWall", (-3.80, 0.0, 2.86), (0.34, 4.86, 4.82), granite_gable),
        ("V0343_Right_GableWall", (3.80, 0.0, 2.86), (0.34, 4.86, 4.82), granite_gable),
    ]
    for name, center, dims, mat in pieces:
        obj = box(name, center, dims, mat, 0.035)
        obj.parent = root
    for y in (-2.60, 2.60):
        obj = triangular_gable("V0343_%s_Resolved_Granite_Gable" % ("Front" if y < 0 else "Rear"), y, granite_gable)
        obj.parent = root
    door_set("V0343_Lower_Double_Livestock_Storage_Door", 0.0, 1.62, 2.82, 2.32, -2.83, timber, iron, dressed, dark)
    door_set("V0343_Upper_Hay_Loading_Shutters", 0.0, 4.25, 2.04, 1.40, -2.84, timber, iron, dressed, dark)
    door_set("V0343_Rear_Service_Door", -2.10, 1.28, 1.05, 1.76, 2.83, timber, iron, dressed, dark)
    for name in [n for n in bpy.data.objects.keys() if n.startswith("V0343_") and ("Door" in n or "Shutter" in n or "Livestock" in n or "Service" in n)]:
        obj = bpy.data.objects.get(name)
        if obj and obj.parent is None: obj.parent = root
    add_corner_stones(granite_gable)
    for obj in list(bpy.data.objects):
        if obj.name.startswith("V0343_CornerStone") and obj.parent is None: obj.parent = root
    if HOUSE02_ROOF_MESH is not None:
        roof = bpy.data.objects.new("V0343_House02_Derived_Weathered_Slate_Roof_System", HOUSE02_ROOF_MESH.copy())
        bpy.context.collection.objects.link(roof)
        roof.location = (0.0, 0.0, 3.18)
        roof.scale = (0.75, 0.83, 0.48)
        roof.parent = root
        roof["v0343_roof_lineage"] = "duplicated LOD0_Weathered_Slate from House 02 source"
    # A restrained agricultural ventilation opening on the rear, not a pediment.
    box("V0343_Rear_Ventilation_Opening", (1.45, 2.79, 4.05), (0.56, 0.08, 0.22), dark, 0.01).parent = root
    for mesh in root.children:
        mesh["v0343_prototype_only"] = True
        mesh["no_gameplay"] = True
    return root


def main() -> None:
    SOURCE.mkdir(parents=True, exist_ok=True)
    ASSETS.mkdir(parents=True, exist_ok=True)
    copied_initial = SOURCE / "house02_source_duplicate_initial.blend"
    shutil.copy2(FROZEN, copied_initial)
    copied_initial_sha = sha(copied_initial)
    bpy.ops.wm.open_mainfile(filepath=str(copied_initial))
    global HOUSE02_ROOF_MESH
    source_roof = bpy.data.objects.get("LOD0_Weathered_Slate")
    if source_roof is None:
        raise RuntimeError("House 02 source roof system is missing")
    HOUSE02_ROOF_MESH = source_roof.data.copy()
    clear_visible_source_objects()
    root = build_barn()
    bpy.context.scene.render.engine = "BLENDER_EEVEE"
    bpy.context.scene.render.resolution_x = 1280
    bpy.context.scene.render.resolution_y = 720
    bpy.context.scene.render.resolution_percentage = 100
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_image_format="AUTO", export_materials="EXPORT", use_selection=False, export_extras=True)
    source_hashes = {str(p.relative_to(ROOT)).replace("\\", "/"): sha(p) for p in (FROZEN, copied_initial, OUT_BLEND, OUT_GLB)}
    metrics = {
        "checkpoint": "v0.343",
        "sourceBlend": "art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend",
        "sourceGLB": "desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb",
        "dimensionsMeters": {"width": 7.6, "depth": 5.2, "wallHeight": 5.28, "ridgeHeight": 6.68, "lowerDoorHeight": 2.32, "upperLoadingHeight": 1.40},
        "materialSlots": 6,
        "visibleRenderObjects": sum(1 for obj in bpy.context.scene.objects if obj.type == "MESH" and obj.visible_get()),
        "drawCalls": sum(1 for obj in bpy.context.scene.objects if obj.type == "MESH" and obj.visible_get()),
        "visibleTriangles": sum(sum(max(0, len(poly.vertices) - 2) for poly in obj.data.polygons) for obj in bpy.context.scene.objects if obj.type == "MESH" and obj.visible_get()),
        "reusedHouse02MaterialResources": ["V0338_GoldCandidate_Rubble_Front", "V0338_GoldCandidate_Rubble_Rear", "V0338_GoldCandidate_Rubble_LeftGable", "V0334_Weathered_Slate", "V0334_Weathered_Timber", "V0334_Iron"],
        "sourceTexturePaths": ["desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_granite_albedo_2048.png", "desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_slate_albedo_1024.png", "desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate_timber_albedo_1024.png"],
        "architecture": {"closedRectangularVolume": True, "principalRoofSlopes": 2, "straightRidge": True, "lowerDoubleDoor": True, "upperHayLoadingOpening": True, "resolvedRear": True, "resolvedBothGables": True, "terrainPedestal": False},
        "sourceLineage": {"frozenHouse02Blend": "art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend", "frozenHouse02BlendSha256": FROZEN_BLEND_SHA, "frozenHouse02GLBSha256": FROZEN_GLB_SHA, "copiedSource": "art-source/blender/v0343/house02_source_duplicate_initial.blend", "copiedSourceInitialSha256": copied_initial_sha, "finalModifiedSha256": sha(OUT_BLEND), "noV0341VisibleDependency": True, "noV0342VisibleDependency": True},
        "prototypeOnly": True, "defaultRuntimeIntegrated": False, "noGameplay": True, "assetProvenance": "repository-authored transformation from duplicated House 02 source; no protected game assets",
    }
    (SOURCE / "v0343-barn-metrics.json").write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    LINEAGE.write_text(json.dumps({"checkpoint": "v0.343", "originalFrozenSource": str(FROZEN.relative_to(ROOT)).replace("\\", "/"), "originalFrozenHash": FROZEN_BLEND_SHA, "copiedSource": "art-source/blender/v0343/house02_source_duplicate_initial.blend", "copiedSourceInitialHash": copied_initial_sha, "finalModifiedSource": str(OUT_BLEND.relative_to(ROOT)).replace("\\", "/"), "finalModifiedHash": sha(OUT_BLEND), "sourceGLB": str(OUT_GLB.relative_to(ROOT)).replace("\\", "/"), "constructionGrammar": ["House 02 granite material response", "House 02 slate roof and eave vocabulary", "House 02 timber/lintel/sill/jamb language"], "visibleDependencies": {"v0341": False, "v0342": False}}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0343_HOUSE02_DERIVED_BARN_EXPORT", "blendSha256": sha(OUT_BLEND), "glbSha256": sha(OUT_GLB), "copiedSourceInitialSha256": copied_initial_sha}, indent=2))


if __name__ == "__main__":
    main()
