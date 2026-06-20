"""Author the v0.237 Barrosan material-richness, foliage, and inhabited-detail revision."""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import bpy

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_v0233_salto_modular_kit as base
import generate_v0235_salto_barrosan_architecture as v0235
import generate_v0236_barrosan_production_slice as v0236


CHECKPOINT = "v0.237"
BLEND_PATH = Path("art-source/blender/v0237/salto_barrosan_material_richness.blend")
DEFAULT_OUTPUT = Path("desktop-spikes/godot-salto/assets/v0237/salto_barrosan_material_richness.glb")

NEW_MATERIALS = {
    "MAT_RoofTileLight": (0.52, 0.25, 0.15, 1.0),
    "MAT_RoofTileDark": (0.27, 0.105, 0.07, 1.0),
    "MAT_PlasterRepair": (0.77, 0.64, 0.43, 1.0),
    "MAT_PlasterCrack": (0.22, 0.16, 0.12, 1.0),
    "MAT_StoneChip": (0.72, 0.67, 0.55, 1.0),
    "MAT_ContactDirt": (0.12, 0.095, 0.065, 1.0),
    "MAT_WoodHoney": (0.50, 0.30, 0.15, 1.0),
    "MAT_IronBracket": (0.12, 0.13, 0.12, 1.0),
    "MAT_LeafOlive": (0.25, 0.34, 0.12, 1.0),
    "MAT_LeafSage": (0.36, 0.43, 0.20, 1.0),
    "MAT_LeafDark": (0.13, 0.23, 0.10, 1.0),
    "MAT_GrassDry": (0.48, 0.43, 0.20, 1.0),
    "MAT_Reed": (0.41, 0.39, 0.16, 1.0),
    "MAT_ReedTip": (0.24, 0.15, 0.08, 1.0),
    "MAT_MossLow": (0.20, 0.30, 0.13, 1.0),
    "MAT_LampWarm": (0.95, 0.48, 0.12, 1.0),
}

VEGETATION_MODULES = [
    "prop_bush_round",
    "prop_bush_wind",
    "prop_grass_clump",
    "prop_reeds",
    "prop_tree_young",
    "prop_tree_broad",
    "prop_moss_patch",
]

INHABITED_PROP_MODULES = [
    "prop_plank_stack",
    "prop_small_awning",
    "prop_guard_post",
    "prop_entrance_lamp",
    "prop_ore_cart",
    "prop_mine_workbench",
]


def parse_args() -> argparse.Namespace:
    raw = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    return parser.parse_args(raw)


def configure_scene() -> None:
    v0236.PRODUCTION_PALETTE.update(NEW_MATERIALS)
    v0236.configure_scene()


def add_parented(root: bpy.types.Object, objects) -> None:
    base.parent_children(root, objects)


def ico_sphere(name: str, location, radius: float, mat_name: str, subdivisions: int = 1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=radius, location=location)
    obj = bpy.context.object
    obj.name = name
    base.bevel(obj, min(0.08, radius * 0.08), 1)
    return base.assign(obj, mat_name)


def roof_tile_rhythm(prefix: str, center_x: float, center_y: float, width: float, depth: float, eave_z: float, rise: float):
    pieces = []
    half_depth = (depth + 0.96) / 2
    angle = math.atan2(rise, half_depth)
    for side in (-1, 1):
        for row in range(1, 6):
            ratio = row / 6.0
            y = center_y + side * half_depth * ratio
            z = eave_z + rise * (1.0 - ratio) + 0.13
            material = "MAT_RoofTileLight" if row in (1, 4) else "MAT_RoofTileDark"
            pieces.append(base.box(
                f"{prefix}_TileRhythm_{side}_{row}",
                (center_x, y, z),
                (width + 0.34, 0.10, 0.065),
                material,
                0.018,
                (side * angle, 0, 0),
            ))
    pieces.append(base.box(
        f"{prefix}_RichRidgeStrip",
        (center_x, center_y, eave_z + rise + 0.24),
        (width + 0.65, 0.28, 0.22),
        "MAT_RoofTileDark",
        0.04,
    ))
    return pieces


def wall_wear(prefix: str, x: float, y: float, z: float, width: float):
    pieces = [
        base.box(f"{prefix}_ContactDirt", (x, y, 0.78), (width, 0.11, 0.34), "MAT_ContactDirt", 0.025),
        base.box(f"{prefix}_RepairPatchA", (x - width * 0.22, y - 0.01, z), (width * 0.24, 0.08, 1.15), "MAT_PlasterRepair", 0.025),
        base.box(f"{prefix}_RepairPatchB", (x + width * 0.25, y - 0.015, z - 0.55), (width * 0.18, 0.075, 0.70), "MAT_PlasterCream", 0.022),
    ]
    for index in range(4):
        pieces.append(base.box(
            f"{prefix}_Crack_{index}",
            (x - width * 0.32 + index * width * 0.19, y - 0.07, z + 0.45 - index * 0.23),
            (0.055, 0.055, 0.52 + (index % 2) * 0.20),
            "MAT_PlasterCrack",
            0.012,
            (0, 0, math.radians(-18 + index * 11)),
        ))
    return pieces


def foundation_chips(prefix: str, start_x: float, y: float, count: int, spacing: float):
    pieces = []
    for index in range(count):
        pieces.append(base.box(
            f"{prefix}_Chip_{index:02d}",
            (start_x + index * spacing, y, 1.03 + (index % 3) * 0.06),
            (0.28 + (index % 2) * 0.11, 0.12, 0.16 + (index % 3) * 0.05),
            "MAT_StoneChip" if index % 3 else "MAT_StoneMoss",
            0.03,
            (0, 0, math.radians((index % 5 - 2) * 4)),
        ))
    return pieces


def timber_fasteners(prefix: str, xs, y: float, zs):
    pieces = []
    for xi, x in enumerate(xs):
        for zi, z in enumerate(zs):
            pieces.append(base.cylinder(
                f"{prefix}_Peg_{xi}_{zi}",
                (x, y, z),
                0.10,
                0.12,
                "MAT_IronBracket",
                8,
            ))
    return pieces


def enrich_landmarks(roots) -> int:
    count = 0
    for root in roots:
        details = []
        if root.name == "keep_landmark":
            details += roof_tile_rhythm("Keep_Roof", 10, 2, 7.4, 5.8, 6.05, 2.25)
            details += wall_wear("Keep_Front", 10, -1.57, 3.0, 6.6)
            details += foundation_chips("Keep", 6.6, -1.60, 10, 0.76)
            details += timber_fasteners("Keep", [7.15, 10.0, 12.85], -1.74, [2.6, 4.2])
            details += [
                base.box("Keep_ThresholdDark", (10, -2.05, 1.20), (3.0, 0.55, 0.18), "MAT_ContactDirt", 0.04),
                base.box("Keep_ThresholdStone", (10, -2.18, 1.38), (2.55, 0.42, 0.18), "MAT_StoneChip", 0.04),
            ]
        elif root.name == "barracks_workshop_landmark":
            details += roof_tile_rhythm("Barracks_Roof", 27.5, 2, 9.4, 6.0, 5.15, 2.25)
            details += roof_tile_rhythm("Workshop_Roof", 34.2, 2.7, 4.25, 4.3, 3.62, 1.55)
            details += wall_wear("Barracks_Front", 27.5, -1.58, 2.75, 8.2)
            details += foundation_chips("Barracks", 23.7, -1.61, 11, 0.75)
            details += timber_fasteners("Barracks", [24.2, 27.5, 30.8, 34.0], -1.72, [1.8, 3.4])
            details += [
                base.box("Workshop_BeamCapA", (32.55, 0.42, 3.45), (0.42, 0.36, 0.25), "MAT_IronBracket", 0.04),
                base.box("Workshop_BeamCapB", (35.45, 0.42, 3.45), (0.42, 0.36, 0.25), "MAT_IronBracket", 0.04),
            ]
        elif root.name == "mine_lume_landmark":
            details += roof_tile_rhythm("Mine_Roof", 47, 2.4, 8.0, 5.4, 4.60, 1.75)
            details += wall_wear("Mine_Front", 47, -1.58, 2.6, 7.4)
            details += foundation_chips("Mine", 44.0, -1.61, 9, 0.78)
            details += timber_fasteners("Mine", [45.15, 47.0, 48.85, 51.15], -1.72, [1.7, 3.2])
            details += [
                base.box("Mine_PortalGrounding", (47, -1.92, 0.72), (4.8, 1.05, 0.28), "MAT_ContactDirt", 0.08),
                base.box("Mine_PortalStoneLip", (47, -2.10, 0.96), (4.25, 0.72, 0.24), "MAT_StoneChip", 0.06),
            ]
        add_parented(root, details)
        count += len(details)
    return count


def vegetation_modules():
    roots = []

    root = base.parent_module("prop_bush_round", (-20, 42, 0))
    objs = [
        base.cylinder("BushRound_Stem", (-20, 42, 0.55), 0.18, 1.1, "MAT_WoodDark", 8),
        ico_sphere("BushRound_A", (-20.5, 42, 1.05), 0.92, "MAT_LeafOlive", 1),
        ico_sphere("BushRound_B", (-19.6, 42.1, 1.15), 0.82, "MAT_LeafSage", 1),
        ico_sphere("BushRound_C", (-20.0, 41.6, 1.42), 0.78, "MAT_LeafDark", 1),
    ]
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_bush_wind", (-10, 42, 0))
    objs = [base.box("BushWind_Stem", (-10, 42, 0.58), (0.18, 0.18, 1.16), "MAT_WoodDark", 0.04)]
    for index, (x, y, z, sx) in enumerate([
        (-10.5, 42.0, 0.9, 1.25), (-9.7, 42.1, 1.1, 1.05), (-9.0, 42.15, 1.28, 0.85)
    ]):
        leaf = ico_sphere(f"BushWind_{index}", (x, y, z), 0.72, "MAT_LeafSage" if index == 1 else "MAT_LeafOlive", 1)
        leaf.scale.x = sx
        leaf.scale.z = 0.72
        objs.append(leaf)
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_grass_clump", (0, 42, 0))
    objs = []
    for index in range(9):
        angle = math.radians(index * 40)
        radius = 0.28 + (index % 3) * 0.12
        blade = base.box(
            f"GrassBlade_{index}", (math.cos(angle) * radius, 42 + math.sin(angle) * radius, 0.42),
            (0.07, 0.035, 0.82 + (index % 2) * 0.25),
            "MAT_GrassDry" if index % 3 == 0 else "MAT_LeafOlive", 0.015,
            (math.radians((index % 3 - 1) * 8), 0, angle),
        )
        objs.append(blade)
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_reeds", (10, 42, 0))
    objs = []
    for index in range(8):
        x = 9.2 + (index % 4) * 0.52
        y = 41.65 + (index // 4) * 0.55
        height = 1.5 + (index % 3) * 0.28
        objs.append(base.box(f"Reed_Stem_{index}", (x, y, height / 2), (0.055, 0.055, height), "MAT_Reed", 0.012))
        objs.append(base.cylinder(f"Reed_Tip_{index}", (x, y, height + 0.18), 0.10, 0.36, "MAT_ReedTip", 8))
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_tree_young", (20, 42, 0))
    objs = [
        base.cylinder("TreeYoung_Trunk", (20, 42, 1.65), 0.30, 3.3, "MAT_WoodWeathered", 10),
        ico_sphere("TreeYoung_CrownA", (20, 42, 3.4), 1.35, "MAT_LeafOlive", 1),
        ico_sphere("TreeYoung_CrownB", (20.4, 42.1, 4.25), 1.00, "MAT_LeafSage", 1),
    ]
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_tree_broad", (30, 42, 0))
    objs = [
        base.cylinder("TreeBroad_Trunk", (30, 42, 2.0), 0.48, 4.0, "MAT_WoodDark", 10),
        base.box("TreeBroad_BranchA", (29.25, 42, 3.15), (1.65, 0.28, 0.28), "MAT_WoodWeathered", 0.08, (0, 0, math.radians(22))),
        base.box("TreeBroad_BranchB", (30.75, 42, 3.25), (1.65, 0.28, 0.28), "MAT_WoodWeathered", 0.08, (0, 0, math.radians(-22))),
        ico_sphere("TreeBroad_CrownA", (28.9, 42, 4.2), 1.65, "MAT_LeafDark", 1),
        ico_sphere("TreeBroad_CrownB", (30.1, 42, 4.7), 1.85, "MAT_LeafOlive", 1),
        ico_sphere("TreeBroad_CrownC", (31.3, 42, 4.15), 1.55, "MAT_LeafSage", 1),
    ]
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_moss_patch", (40, 42, 0))
    objs = []
    for index, (x, y, sx, sy) in enumerate([
        (39.2, 41.8, 1.1, 0.65), (40.0, 42.1, 1.3, 0.72), (40.9, 41.8, 0.9, 0.55)
    ]):
        patch = ico_sphere(f"MossPatch_{index}", (x, y, 0.14), 0.55, "MAT_MossLow", 1)
        patch.scale = (sx, sy, 0.22)
        objs.append(patch)
    add_parented(root, objs); roots.append(root)
    return roots


def inhabited_prop_modules():
    roots = []

    root = base.parent_module("prop_plank_stack", (-20, 52, 0))
    objs = []
    for index in range(6):
        objs.append(base.box(
            f"PlankStack_{index}", (-20 + (index % 2) * 0.15, 52, 0.18 + index * 0.18),
            (3.3 - (index % 3) * 0.22, 0.48, 0.16), "MAT_WoodHoney" if index % 2 else "MAT_WoodWeathered", 0.03,
            (0, 0, math.radians((index % 3 - 1) * 2)),
        ))
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_small_awning", (-10, 52, 0))
    objs = [
        base.box("Awning_PostA", (-11.2, 52, 1.4), (0.18, 0.18, 2.8), "MAT_WoodDark", 0.03),
        base.box("Awning_PostB", (-8.8, 52, 1.4), (0.18, 0.18, 2.8), "MAT_WoodDark", 0.03),
        base.box("Awning_Beam", (-10, 52, 2.75), (2.8, 0.22, 0.22), "MAT_WoodHoney", 0.04),
        base.box("Awning_Cloth", (-10, 51.75, 2.55), (2.8, 1.65, 0.12), "MAT_BannerRed", 0.04, (math.radians(8), 0, 0)),
    ]
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_guard_post", (0, 52, 0))
    objs = [
        base.box("GuardPost_Base", (0, 52, 0.18), (2.4, 2.1, 0.36), "MAT_StoneWarm", 0.08),
        base.box("GuardPost_PostA", (-0.8, 52, 1.7), (0.20, 0.20, 3.1), "MAT_WoodDark", 0.03),
        base.box("GuardPost_PostB", (0.8, 52, 1.7), (0.20, 0.20, 3.1), "MAT_WoodDark", 0.03),
        base.box("GuardPost_Roof", (0, 52, 3.25), (2.4, 1.7, 0.25), "MAT_RoofTileDark", 0.05),
        base.box("GuardPost_Shield", (0, 51.05, 1.55), (0.9, 0.16, 1.3), "MAT_BannerRed", 0.08),
    ]
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_entrance_lamp", (10, 52, 0))
    objs = [
        base.box("Lamp_Post", (10, 52, 1.15), (0.14, 0.14, 2.3), "MAT_IronBracket", 0.03),
        base.box("Lamp_Arm", (10.35, 52, 2.15), (0.8, 0.12, 0.12), "MAT_IronBracket", 0.03),
        ico_sphere("Lamp_Glow", (10.72, 52, 1.88), 0.30, "MAT_LampWarm", 1),
    ]
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_ore_cart", (20, 52, 0))
    objs = [
        base.box("OreCart_Bed", (20, 52, 0.82), (2.7, 1.55, 0.65), "MAT_WoodDark", 0.06),
        base.cylinder("OreCart_WheelA", (19.2, 51.12, 0.58), 0.62, 0.22, "MAT_IronBracket", 12),
        base.cylinder("OreCart_WheelB", (19.2, 52.88, 0.58), 0.62, 0.22, "MAT_IronBracket", 12),
        ico_sphere("OreCart_OreA", (19.55, 52, 1.3), 0.48, "MAT_StoneDark", 1),
        ico_sphere("OreCart_OreB", (20.35, 52.1, 1.25), 0.42, "MAT_StoneWarm", 1),
    ]
    add_parented(root, objs); roots.append(root)

    root = base.parent_module("prop_mine_workbench", (30, 52, 0))
    objs = [
        base.box("MineBench_Top", (30, 52, 1.25), (3.2, 1.25, 0.22), "MAT_WoodHoney", 0.05),
        base.box("MineBench_LegA", (28.8, 52, 0.62), (0.22, 0.75, 1.25), "MAT_WoodDark", 0.03),
        base.box("MineBench_LegB", (31.2, 52, 0.62), (0.22, 0.75, 1.25), "MAT_WoodDark", 0.03),
        base.box("MineBench_ToolA", (29.5, 52, 1.55), (1.2, 0.10, 0.10), "MAT_IronBracket", 0.02, (0, 0, math.radians(18))),
        base.box("MineBench_ToolB", (30.7, 52, 1.55), (1.0, 0.10, 0.10), "MAT_IronBracket", 0.02, (0, 0, math.radians(-14))),
    ]
    add_parented(root, objs); roots.append(root)
    return roots


def export(output: Path, authored_detail_count: int) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    BLEND_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH.resolve()))
    bpy.ops.export_scene.gltf(
        filepath=str(output.resolve()),
        export_format="GLB",
        export_apply=True,
        export_yup=True,
        export_materials="EXPORT",
        export_cameras=False,
        export_lights=False,
    )
    metadata = {
        "schemaVersion": 1,
        "checkpoint": CHECKPOINT,
        "status": "PASS_V0237_BLENDER_GLTF_EXPORT",
        "blendPath": BLEND_PATH.as_posix(),
        "glbPath": output.as_posix(),
        "sourceGenerator": "tools/blender/generate_v0237_barrosan_material_richness.py",
        "sourceAssetRevision": "new v0.237 GLB; v0.236, v0.235, and v0.233 assets retained unchanged",
        "modules": base.MODULES + v0236.ROLE_PROP_MODULES + VEGETATION_MODULES + INHABITED_PROP_MODULES,
        "materials": list(v0236.PRODUCTION_PALETTE),
        "newOrChangedMaterialNames": list(NEW_MATERIALS),
        "newOrChangedMaterialCount": len(NEW_MATERIALS),
        "vegetationModules": VEGETATION_MODULES,
        "vegetationModuleCount": len(VEGETATION_MODULES),
        "inhabitedPropModules": INHABITED_PROP_MODULES,
        "inhabitedPropModuleCount": len(INHABITED_PROP_MODULES),
        "authoredBuildingDetailObjectCount": authored_detail_count,
        "roofGeometryContract": {
            "centralRidgeHighest": True,
            "slopesDownToBothEaves": True,
            "eaveOverhang": True,
            "ridgeCaps": True,
            "fasciaBoards": True,
            "invertedRoofGeometry": False,
        },
        "downloadedAssets": 0,
        "generatedAiImages": 0,
    }
    output.with_suffix(".export.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()
    configure_scene()
    base.terrain_modules()
    base.road_modules()
    v0236.enhanced_river_bridge_modules()
    roots, inherited_detail_count = v0236.enhanced_landmark_modules()
    new_detail_count = enrich_landmarks(roots)
    base.prop_modules()
    v0236.role_prop_modules()
    vegetation_modules()
    inhabited_prop_modules()
    export(Path(args.output), new_detail_count)
    print(json.dumps({
        "checkpoint": CHECKPOINT,
        "inheritedV0236BuildingDetailObjects": inherited_detail_count,
        "newV0237BuildingDetailObjects": new_detail_count,
        "vegetationModuleCount": len(VEGETATION_MODULES),
        "inhabitedPropModuleCount": len(INHABITED_PROP_MODULES),
    }))


if __name__ == "__main__":
    main()
