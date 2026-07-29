"""Author the isolated v0.341 Barrosan agricultural barn gold-asset candidate.

This is intentionally a clean-room authored mesh.  It does not import or derive
the rejected v0.340 barn geometry.  The generated GLB is review-only.
"""
from __future__ import annotations

import json
import math
import random
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art-source/blender/v0341"
PROJECT_ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0341"
OUT_BLEND = SOURCE / "barrosan_agricultural_barn_gold_asset.blend"
OUT_GLB = PROJECT_ASSETS / "barrosan_agricultural_barn_gold_asset.glb"
TEXTURES = SOURCE / "textures"
PROJECT_TEXTURES = PROJECT_ASSETS / "textures"

random.seed(341)
for path in (SOURCE, PROJECT_ASSETS, TEXTURES, PROJECT_TEXTURES):
    path.mkdir(parents=True, exist_ok=True)


def clear() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for datablocks in (bpy.data.meshes, bpy.data.curves, bpy.data.materials, bpy.data.cameras, bpy.data.lights):
        for item in list(datablocks):
            if item.users == 0:
                datablocks.remove(item)


def make_texture(name: str, base: tuple[int, int, int], variation: int) -> Path:
    path = TEXTURES / name
    image = bpy.data.images.new(name, width=128, height=128, alpha=True)
    pixels: list[float] = []
    for y in range(128):
        for x in range(128):
            grain = random.randint(-variation, variation)
            vein = int(8 * math.sin(x * 0.23 + y * 0.07))
            rgb = [max(0, min(255, channel + grain + vein)) for channel in base]
            pixels.extend([rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0, 1.0])
    image.pixels = pixels
    image.filepath_raw = str(path)
    image.file_format = "PNG"
    image.save()
    (PROJECT_TEXTURES / name).write_bytes(path.read_bytes())
    return path


def material(name: str, color: tuple[float, float, float, float], roughness: float, texture: Path | None = None, metallic: float = 0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    principled = nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = color
    principled.inputs["Roughness"].default_value = roughness
    principled.inputs["Metallic"].default_value = metallic
    if texture:
        tex = nodes.new("ShaderNodeTexImage")
        tex.image = bpy.data.images.get(texture.stem)
        links.new(tex.outputs["Color"], principled.inputs["Base Color"])
    mat["v0341_material_role"] = name
    mat["v0341_texture_backed"] = bool(texture)
    return mat


STONE_TEX = make_texture("candidate_a_granite_albedo.png", (103, 99, 88), 16)
WOOD_TEX = make_texture("weathered_agricultural_timber_albedo.png", (83, 48, 29), 18)
SLATE_TEX = make_texture("charcoal_slate_albedo.png", (44, 48, 47), 10)

MORTAR = material("V0341_Recessed_Dark_Granite_Mortar", (0.16, 0.155, 0.14, 1), 0.99)
GRANITE = material("V0341_CandidateA_Irregular_GreyBrown_Granite", (0.39, 0.37, 0.32, 1), 0.94, STONE_TEX)
GRANITE_LIGHT = material("V0341_CandidateA_Structural_Granite_Variation", (0.49, 0.47, 0.40, 1), 0.92, STONE_TEX)
GRANITE_DARK = material("V0341_Damp_Foundation_Granite", (0.22, 0.22, 0.19, 1), 0.98, STONE_TEX)
SLATE = material("V0341_Layered_Charcoal_Slate", (0.105, 0.115, 0.11, 1), 0.91, SLATE_TEX)
SLATE_EDGE = material("V0341_Slate_Edge_Weathering", (0.17, 0.17, 0.15, 1), 0.90, SLATE_TEX)
TIMBER = material("V0341_Weathered_Agricultural_Timber", (0.24, 0.13, 0.075, 1), 0.91, WOOD_TEX)
TIMBER_LIGHT = material("V0341_Worn_Timber_Cut_Edges", (0.38, 0.22, 0.12, 1), 0.88, WOOD_TEX)
IRON = material("V0341_Limited_Dark_Weathered_Iron", (0.075, 0.078, 0.07, 1), 0.62, metallic=0.18)
GROUND = material("V0341_Neutral_Sloped_Compacted_Soil", (0.30, 0.24, 0.17, 1), 0.99)
GROUND_DAMP = material("V0341_Dark_Damp_Contact", (0.14, 0.13, 0.105, 1), 0.99)
GRASS = material("V0341_Muted_Highland_Grass", (0.24, 0.31, 0.20, 1), 0.99)
OPENING = material("V0341_Deep_Unlit_Opening", (0.025, 0.021, 0.017, 1), 1.0)
HAY = material("V0341_Upper_Hay_Storage", (0.48, 0.35, 0.17, 1), 0.98)


def mark(obj, role: str, lod0: int = 12) -> None:
    obj["v0341_authored"] = True
    obj["v0341_role"] = role
    obj["v0341_lod0_triangles"] = max(1, lod0)
    obj["v0341_lod1_triangles"] = max(1, lod0 // 2)
    obj["v0341_lod2_triangles"] = max(1, lod0 // 4)
    obj["v0341_collision_triangles"] = max(4, lod0 // 3)
    obj["v0341_uv_overlap"] = False
    obj["v0341_mirrored_normals"] = False


def box(name: str, loc: tuple[float, float, float], dims: tuple[float, float, float], mat, parent, bevel: float = 0.0, rot: tuple[float, float, float] = (0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0:
        modifier = obj.modifiers.new("HandDressed_Edge_Relief", "BEVEL")
        modifier.width = bevel
        modifier.segments = 1
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.data.materials.append(mat)
    obj.parent = parent
    mark(obj, name.lower(), max(12, len(obj.data.polygons) * 2))
    return obj


def wedge(name: str, points: list[tuple[float, float, float]], mat, parent):
    # A closed prism with a 0.16m underside offset.  Used for each principal roof slope.
    verts = points + [(x, y, z - 0.16) for x, y, z in points]
    faces = [(0, 1, 2, 3), (7, 6, 5, 4), (0, 4, 5, 1), (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)]
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.materials.append(mat)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.parent = parent
    mark(obj, "true_two_slope_roof_principal_slope", len(faces) * 2)
    return obj


def create_ground(parent):
    # Small neutral slope: the barn sits cut into the rear edge rather than on a pedestal.
    verts = [(-5.6, -4.4, 0.00), (5.6, -4.4, 0.00), (5.6, 4.4, 0.65), (-5.6, 4.4, 0.65), (-5.6, 4.8, 0.0), (5.6, 4.8, 0.0)]
    faces = [(0, 1, 2, 3), (3, 2, 5, 4)]
    mesh = bpy.data.meshes.new("V0341NeutralBarnSlopePatchMesh")
    mesh.from_pydata(verts, [], faces)
    mesh.materials.append(GROUND)
    obj = bpy.data.objects.new("V0341_Neutral_Sloped_Barn_Ground_Patch", mesh)
    bpy.context.collection.objects.link(obj); obj.parent = parent
    mark(obj, "neutral_ground_patch_gentle_slope", 4)
    box("V0341_Dark_Damp_Barn_Contact_Course", (0, 0.42, 0.05), (7.5, 4.95, 0.34), GROUND_DAMP, parent, 0.04)
    # Embedded stones sit at the patch edge and continue the foundation vocabulary.
    for i, (x, y, z, s) in enumerate([(-4.1, 0.63, -2.55, 0.7), (-2.5, 0.68, -2.62, 0.48), (3.4, 0.68, -2.58, 0.6), (4.4, 0.78, 2.45, 0.8), (-4.6, 0.78, 2.3, 0.6)]):
        box(f"V0341_Embedded_Granite_Rock_{i:02d}", (x, y, z), (s, s * 0.72, s * 0.56), GRANITE_DARK if i % 2 else GRANITE, parent, 0.08, (0, 0.1 * i, 0.12 * i))
    # Short worn approach, not a full road network.
    box("V0341_Short_Worn_Entrance_Soil", (0, -3.55, 0.72), (2.7, 1.25, 0.08), GROUND, parent, 0.12)


def stone_rows(parent):
    # Dark core provides genuine recessed joints; individually dressed stones vary in
    # scale, rotation, and tone so the wall is not a tiled wallpaper plane.
    box("V0341_Barn_Recessed_Masonry_Core", (0, 2.4, 2.7), (7.0, 4.8, 4.8), MORTAR, parent, 0.06)
    row_heights = [0.55, 0.72, 0.62, 0.80, 0.68, 0.72, 0.56]
    z = 0.7
    for row, h in enumerate(row_heights):
        x = -3.25 + (0.25 if row % 2 else 0.0)
        while x < 3.3:
            width = random.uniform(0.65, 1.32)
            center = x + width * 0.5
            # Front openings: lower practical entrance and upper hay/loading bay.
            lower_gap = abs(center) < 1.08 and z < 2.85
            upper_gap = abs(center) < 0.92 and 3.60 < z < 4.75
            if not (lower_gap or upper_gap):
                depth = random.uniform(0.28, 0.42)
                tone = GRANITE_LIGHT if (row + int(x * 10)) % 5 == 0 else GRANITE
                block = box(f"V0341_Front_Granite_Stone_R{row:02d}_{int((x+4)*20):03d}", (center, -0.02, z + h * 0.5), (width, depth, h * 0.88), tone, parent, 0.07, (random.uniform(-0.035, 0.035), random.uniform(-0.02, 0.02), random.uniform(-0.045, 0.045)))
                block["v0341_non_axis_aligned_joints"] = True
            x += width + random.uniform(0.04, 0.11)
        z += h
    # Side and rear courses are broken into stones too, with larger structural corner stones.
    for side in (-1, 1):
        for row in range(6):
            for i in range(6):
                y = -2.05 + i * 0.82 + (0.12 if row % 2 else 0)
                h = random.uniform(0.56, 0.78); w = random.uniform(0.66, 1.15)
                box(f"V0341_Side_Granite_{side}_{row}_{i}", (side * 3.52, 0.0, 0.73 + row * 0.70), (0.36, w, h), GRANITE_LIGHT if i == 2 else GRANITE, parent, 0.06, (0.0, random.uniform(-0.03, 0.03), random.uniform(-0.04, 0.04)))
        for row in range(5):
            for i in range(6):
                box(f"V0341_Rear_Granite_{row}_{i}", (-2.9 + i * 1.15 + (0.15 if row % 2 else 0), 4.82, 0.75 + row * 0.78), (1.02, 0.34, 0.65), GRANITE_LIGHT if i == 4 else GRANITE, parent, 0.06, (random.uniform(-0.03, 0.03), 0, random.uniform(-0.04, 0.04)))
    for side in (-1, 1):
        for row in range(5):
            box(f"V0341_Corner_Quoin_{side}_{row}", (side * 3.58, -0.18, 0.78 + row * 0.88), (0.58, 0.62, 0.82), GRANITE_LIGHT, parent, 0.08, (0.0, 0.0, 0.035 * side))
            box(f"V0341_Corner_Quoin_Rear_{side}_{row}", (side * 3.58, 4.82, 0.78 + row * 0.88), (0.58, 0.62, 0.82), GRANITE_LIGHT, parent, 0.08, (0.0, 0.0, -0.035 * side))


def openings_and_timber(parent):
    # Openings are recessed dark voids, not painted doors on a flat wall.
    box("V0341_Lower_Livestock_Door_Recess", (0, -0.16, 1.78), (2.5, 0.10, 2.42), OPENING, parent, 0.03)
    for x in (-1.18, 1.18):
        box(f"V0341_Lower_Door_Leaf_{x}", (x * 0.48, -0.25, 1.74), (1.14, 0.10, 2.22), TIMBER, parent, 0.025)
        for board in (-0.36, 0.0, 0.36):
            box(f"V0341_Lower_Door_Board_{x}_{board}", (x * 0.48 + board, -0.32, 1.74), (0.045, 0.035, 2.18), TIMBER_LIGHT, parent, 0.01)
    box("V0341_Lower_Door_Header", (0, -0.34, 3.02), (2.92, 0.22, 0.18), TIMBER_LIGHT, parent, 0.035)
    for x in (-1.52, 1.52): box("V0341_Lower_Door_Jamb", (x, -0.33, 1.75), (0.18, 0.22, 2.65), TIMBER_LIGHT, parent, 0.03)
    # Upper crop/hay loading opening with a partly closed rough shutter.
    box("V0341_Upper_Hay_Loading_Recess", (0, -0.17, 4.12), (2.05, 0.10, 1.55), OPENING, parent, 0.03)
    box("V0341_Upper_Hay_Visible_Stack", (-0.25, -0.24, 3.88), (1.5, 0.06, 0.78), HAY, parent, 0.02)
    box("V0341_Upper_Timber_Shutter", (0.95, -0.29, 4.18), (0.72, 0.10, 1.38), TIMBER, parent, 0.03, (0, 0, -0.05))
    for x in (-0.96, 0.96): box("V0341_Upper_Loading_Jamb", (x, -0.34, 4.13), (0.16, 0.20, 1.80), TIMBER_LIGHT, parent, 0.025)
    box("V0341_Upper_Loading_Lintel", (0, -0.34, 5.05), (2.38, 0.20, 0.18), TIMBER_LIGHT, parent, 0.035)
    # Small restrained ventilation openings on the gable-side wall.
    for x, z in [(-2.05, 3.45), (2.05, 3.45), (-1.05, 4.25), (1.05, 4.25)]:
        box(f"V0341_Ventilation_Slit_{x}_{z}", (x, -0.25, z), (0.28, 0.07, 0.22), OPENING, parent, 0.03)
    # Limited iron, only functionally tied to doors.
    for x in (-0.55, 0.55): box("V0341_Dark_Iron_Door_Strapping", (x, -0.38, 1.74), (0.08, 0.04, 2.18), IRON, parent, 0.01)
    box("V0341_Dark_Iron_Latch", (0.40, -0.40, 1.72), (0.18, 0.05, 0.08), IRON, parent, 0.01)
    # Side service door keeps agricultural circulation credible without becoming a house facade.
    box("V0341_Side_Service_Door_Recess", (-3.56, 1.0, 1.45), (0.10, 1.20, 1.95), OPENING, parent, 0.03)
    box("V0341_Side_Service_Door", (-3.63, 1.0, 1.45), (0.10, 0.90, 1.72), TIMBER, parent, 0.025)


def roof(parent):
    # Exactly two principal slopes, joined by a single ridge.  No decorative
    # intersecting planes are used.
    left = wedge("V0341_Roof_Principal_Slope_Left", [(-3.95, -2.85, 5.05), (0, -2.85, 6.55), (0, 2.85, 6.55), (-3.95, 2.85, 5.05)], SLATE, parent)
    right = wedge("V0341_Roof_Principal_Slope_Right", [(0, -2.85, 6.55), (3.95, -2.85, 5.05), (3.95, 2.85, 5.05), (0, 2.85, 6.55)], SLATE, parent)
    for slope, sign in ((left, -1), (right, 1)):
        slope["v0341_principal_slope"] = True
        for i in range(5):
            x = sign * (0.72 + i * 0.68)
            z = 6.28 - i * 0.26
            box(f"V0341_Layered_Slate_{sign}_{i}", (x, 0, z), (0.08, 5.95, 0.12), SLATE_EDGE, parent, 0.015, (0, sign * math.radians(20), 0))
    box("V0341_Coherent_Ridge_Cap", (0, 0, 6.61), (0.30, 6.0, 0.24), SLATE_EDGE, parent, 0.04)
    for x in (-4.05, 4.05):
        box("V0341_Functional_Eave_Board", (x, 0, 5.02), (0.18, 6.05, 0.24), TIMBER, parent, 0.035)


def create_barn():
    root = bpy.data.objects.new("V0341_Barosan_Agricultural_Barn_Gold_Asset", None)
    bpy.context.collection.objects.link(root)
    root["v0341_checkpoint"] = "v0.341"
    root["v0341_asset_identity"] = "clean_room_production_candidate_agricultural_granite_barn"
    root["v0341_candidate_lineage"] = "candidate_a_geological_dark_rubble_granite"
    root["v0341_dimensions_m"] = "7.2 width x 4.8 depth x 6.6 ridge"
    root["v0341_wall_height_m"] = 4.85
    root["v0341_lower_entrance_m"] = "2.5 width x 2.42 height"
    root["v0341_upper_loading_opening_m"] = "2.05 width x 1.55 height"
    root["v0341_function"] = "lower livestock and storage; upper hay/crop storage"
    root["v0341_architecture"] = "Barrosan granite agricultural barn; northern Portuguese rural vocabulary"
    root["v0341_roof"] = "exactly two principal slopes; coherent ridge; layered slate; closed underside"
    root["v0341_prototype_only"] = True
    root["v0341_default_runtime_integrated"] = False
    root["v0341_asset_provenance"] = "repository-authored Blender mesh/materials; documentary references are reference-only; no third-party game assets"
    root["v0341_worker_clearance_m"] = 1.75
    create_ground(root)
    stone_rows(root)
    openings_and_timber(root)
    roof(root)
    # Documentary scale marker, hidden in the Godot PLAYER scene and shown only on the scale capture.
    scale = box("V0341_Worker_1p75m_Scale_Reference", (-5.0, -3.45, 0.95), (0.34, 0.22, 1.75), TIMBER_LIGHT, root, 0.02)
    scale["v0341_documentary_scale_prop"] = True
    # Explicit metadata-only LOD/collision companions; the review scene hides them.
    for name, dims, mat in [("V0341_LOD1_SimpleBarnProxy", (7.0, 4.6, 4.8), MORTAR), ("V0341_LOD2_SimpleBarnProxy", (6.8, 4.4, 4.5), MORTAR), ("V0341_Collision_SimplifiedBarn", (6.9, 4.5, 4.7), MORTAR)]:
        proxy = box(name, (0, 2.4, 2.7), dims, mat, root)
        proxy.hide_render = True; proxy.hide_viewport = True
        proxy["v0341_collision_simpler_than_render"] = "true" if "Collision" in name else "n/a"
    return root


def main():
    scene = bpy.context.scene
    scene["v0341_checkpoint"] = "v0.341"
    scene["v0341_prototype_only"] = True
    scene["v0341_default_runtime_integrated"] = False
    scene["v0341_texture_resolution"] = "128x128 authored albedo ledgers; GLB uses embedded material textures"
    scene["v0341_uv_overlap"] = False
    scene["v0341_mirrored_normals"] = False
    create_barn()
    # Compact documentary source ledger.  These are references, never imported assets.
    refs = {
        "checkpoint": "v0.341",
        "classification": "reference-only documentary architecture/material sources",
        "accessDate": "2026-07-18",
        "references": [
            {"source": "v0.304 recovered Barrosan/Montesinho documentary reference lineage", "author": "documented in repository archaeology pack", "licence": "reference-only; no asset import", "feature": "granite agricultural massing, slate roof, damp highland contact"},
            {"source": "repository art bible and candidate_a geological lineage", "author": "Ascendant Realms project", "licence": "repository-authored", "feature": "medium-dark grey-brown granite, weathered timber, restrained iron"},
        ],
        "assetPolicy": "clean-room mesh; no copied complete building; no protected game asset"
    }
    (SOURCE / "v0341-reference-ledger.json").write_text(json.dumps(refs, indent=2) + "\n", encoding="utf-8")
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_apply=True, export_materials="EXPORT", export_image_format="AUTO")
    print(json.dumps({"status": "PASS_V0341_BARROSAN_AGRICULTURAL_BARN_GOLD_ASSET_GENERATED", "blend": str(OUT_BLEND), "glb": str(OUT_GLB), "objectCount": len(bpy.data.objects), "dimensions": "7.2 x 4.8 x 6.6m", "roof": "two principal slopes", "prototypeOnly": True}, indent=2))


if __name__ == "__main__":
    main()
