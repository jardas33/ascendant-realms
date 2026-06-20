"""Author the v0.239 Barrosan roster silhouette and settlement-beauty revision."""

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
import generate_v0237_barrosan_material_richness as v0237
import generate_v0238_barrosan_building_roster as v0238


CHECKPOINT = "v0.239"
BLEND_PATH = Path("art-source/blender/v0239/salto_barrosan_roster_silhouette_beauty.blend")
DEFAULT_OUTPUT = Path("desktop-spikes/godot-salto/assets/v0239/salto_barrosan_roster_silhouette_beauty.glb")

REVISED_BUILDINGS = list(v0238.BUILDING_MODULES)
NEW_PROPS = [
    "prop_laundry_bench",
    "prop_grain_cart",
    "prop_timber_a_frame",
    "prop_forge_tool_rack",
    "prop_coal_ore_pile",
    "prop_watchtower_ladder",
]
MATERIAL_CHANGES = {
    "MAT_DomesticCream": (0.89, 0.82, 0.66, 1.0),
    "MAT_GranaryOchre": (0.66, 0.47, 0.24, 1.0),
    "MAT_LumberRaw": (0.43, 0.25, 0.12, 1.0),
    "MAT_ForgeSoot": (0.12, 0.12, 0.11, 1.0),
    "MAT_DefenseRed": (0.48, 0.16, 0.09, 1.0),
    "MAT_MarketCanvas": (0.72, 0.50, 0.22, 1.0),
}


def parse_args() -> argparse.Namespace:
    raw = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    return parser.parse_args(raw)


def configure_scene() -> None:
    v0236.PRODUCTION_PALETTE.update(v0237.NEW_MATERIALS)
    v0236.PRODUCTION_PALETTE.update(v0238.NEW_MATERIALS)
    v0236.PRODUCTION_PALETTE.update(MATERIAL_CHANGES)
    v0236.configure_scene()


def parent(root, objects) -> None:
    base.parent_children(root, objects)


def shell(prefix, center, width, depth, wall_height, wall_mat, roof_mat="MAT_RoofClay", rise=None):
    x, y = center
    objs = [
        base.box(f"{prefix}_Contact", (x, y, -0.08), (width + 1.0, depth + 1.0, 0.28), "MAT_ContactDirt", 0.14),
        base.box(f"{prefix}_Foundation", (x, y, 0.30), (width + 0.55, depth + 0.55, 0.76), "MAT_StoneDark", 0.18),
        base.box(f"{prefix}_Wall", (x, y, 0.88 + wall_height / 2), (width, depth, wall_height), wall_mat, 0.17),
    ]
    eave_z = 0.88 + wall_height + 0.10
    roof_rise = rise if rise is not None else max(1.25, depth * 0.34)
    objs += v0235.pitched_roof(f"{prefix}_Roof", center, width, depth, eave_z, roof_rise, roof_mat)
    objs += v0237.roof_tile_rhythm(f"{prefix}_Roof", x, y, width, depth, eave_z, roof_rise)
    return objs


def delete_tree(name: str) -> None:
    root = bpy.data.objects.get(name)
    if root is None:
        return
    descendants = list(root.children_recursive)
    for obj in reversed(descendants):
        bpy.data.objects.remove(obj, do_unlink=True)
    bpy.data.objects.remove(root, do_unlink=True)


def house_module():
    root = base.parent_module("house_dwelling", (-24, 66, 0))
    x, y = -24, 66
    objs = shell("House", (x, y), 5.4, 4.4, 2.8, "MAT_DomesticCream", rise=1.45)
    objs += [
        *v0238.front_door("House", x, y - 2.35, 2.0, 1.05),
        base.box("House_Porch", (x, y - 2.85, 0.94), (3.5, 1.15, 0.20), "MAT_WoodHoney", 0.05),
        base.box("House_PorchRoof", (x, y - 2.65, 2.95), (3.8, 1.35, 0.16), "MAT_RoofTileDark", 0.04, (math.radians(-10), 0, 0)),
        base.box("House_Bench", (x + 1.65, y - 2.82, 1.15), (1.15, 0.42, 0.35), "MAT_LumberRaw", 0.04),
        base.box("House_LowFence", (x - 3.1, y - 0.2, 0.62), (0.18, 4.8, 1.05), "MAT_WoodWeathered", 0.03),
    ]
    parent(root, objs)


def granary_module():
    root = base.parent_module("farm_granary", (-10, 66, 0))
    x, y = -10, 66
    objs = [
        base.box("Granary_Contact", (x, y, -0.08), (10.0, 7.4, 0.28), "MAT_ContactDirt", 0.14),
        base.box("Granary_Platform", (x, y, 0.65), (9.2, 6.6, 1.15), "MAT_StoneWarm", 0.15),
        base.box("Granary_RaisedBody", (x, y, 3.15), (8.2, 5.7, 3.9), "MAT_GranaryOchre", 0.16),
        *v0235.pitched_roof("Granary_Roof", (x, y), 8.8, 6.3, 5.2, 2.65, "MAT_RoofAged"),
        *v0237.roof_tile_rhythm("Granary_Roof", x, y, 8.8, 6.3, 5.2, 2.65),
        base.box("Granary_LoadingDeck", (x, y - 4.0, 1.15), (6.2, 2.0, 0.35), "MAT_WoodHoney", 0.06),
        base.box("Granary_BroadDoor", (x, y - 2.95, 2.65), (2.9, 0.26, 3.05), "MAT_ContactDark", 0.04),
        base.box("Granary_LoftVent", (x, y - 2.98, 4.55), (2.0, 0.20, 0.85), "MAT_WoodDark", 0.03),
        base.box("Granary_Ramp", (x + 3.3, y - 4.2, 0.62), (2.0, 3.2, 0.25), "MAT_WoodWeathered", 0.04, (math.radians(-8), 0, 0)),
    ]
    parent(root, objs)


def lumber_module():
    root = base.parent_module("lumber_carpenter_yard", (6, 66, 0))
    x, y = 6, 66
    objs = shell("Lumber", (x - 2.6, y), 4.2, 4.5, 2.7, "MAT_LimewashEconomy", "MAT_RoofDark", 1.35)
    objs += [
        *v0238.front_door("Lumber", x - 2.6, y - 2.38, 1.9, 1.0),
        base.box("Lumber_YardCanopy", (x + 2.4, y, 3.25), (6.4, 5.8, 0.20), "MAT_RoofTileDark", 0.04, (0, math.radians(-9), 0)),
        base.box("Lumber_CanopyBeam", (x + 2.4, y, 3.55), (6.6, 0.28, 0.32), "MAT_LumberRaw", 0.04),
    ]
    for index, (dx, dy) in enumerate([(-0.4, -2.35), (5.2, -2.35), (-0.4, 2.35), (5.2, 2.35)]):
        objs.append(base.box(f"Lumber_OpenPost_{index}", (x + dx, y + dy, 1.65), (0.30, 0.30, 3.3), "MAT_LumberRaw", 0.04))
    parent(root, objs)


def forge_module():
    root = base.parent_module("blacksmith_forge", (22, 66, 0))
    x, y = 22, 66
    objs = shell("Forge", (x, y), 6.8, 6.2, 3.3, "MAT_ForgeStone", "MAT_RoofDark", 1.55)
    objs += [
        *v0238.front_door("Forge", x - 2.0, y - 3.25, 2.25, 1.25),
        base.box("Forge_HeavyButtressA", (x - 3.7, y, 1.45), (1.1, 6.6, 2.5), "MAT_StoneDark", 0.12),
        base.box("Forge_HeavyButtressB", (x + 3.7, y, 1.45), (1.1, 6.6, 2.5), "MAT_StoneDark", 0.12),
        base.box("Forge_MassiveChimney", (x + 2.0, y + 1.2, 5.4), (1.75, 1.75, 7.0), "MAT_ForgeSoot", 0.15),
        base.box("Forge_ChimneyCrown", (x + 2.0, y + 1.2, 9.0), (2.15, 2.15, 0.38), "MAT_StoneWarm", 0.07),
        base.box("Forge_Mouth", (x + 1.25, y - 3.2, 1.75), (2.2, 0.35, 1.8), "MAT_ForgeSoot", 0.05),
        base.box("Forge_Heat", (x + 1.25, y - 3.42, 1.65), (1.25, 0.16, 0.72), "MAT_ForgeHot", 0.03),
    ]
    parent(root, objs)


def watchtower_module():
    root = base.parent_module("watchtower_defense", (36, 66, 0))
    x, y = 36, 66
    objs = [
        base.box("Watchtower_Contact", (x, y, -0.08), (7.2, 7.2, 0.28), "MAT_ContactDirt", 0.14),
        base.box("Watchtower_Foundation", (x, y, 0.42), (6.4, 6.4, 0.95), "MAT_StoneDark", 0.18),
        base.box("Watchtower_Shaft", (x, y, 3.6), (3.8, 3.8, 5.7), "MAT_StoneWarm", 0.15),
        base.box("Watchtower_BracedLookout", (x, y, 7.3), (6.4, 6.4, 1.65), "MAT_DefenseTimber", 0.10),
        base.box("Watchtower_Deck", (x, y, 8.25), (7.4, 7.4, 0.36), "MAT_WoodWeathered", 0.07),
        base.box("Watchtower_FiringFront", (x, y - 3.25, 7.35), (3.7, 0.22, 0.72), "MAT_ContactDark", 0.03),
        base.box("Watchtower_Banner", (x + 3.7, y - 1.4, 7.25), (0.18, 2.0, 2.5), "MAT_DefenseRed", 0.02),
    ]
    for index, (dx, dy, rz) in enumerate([(-2.6, -2.6, -35), (2.6, -2.6, 35), (-2.6, 2.6, 35), (2.6, 2.6, -35)]):
        objs.append(base.box(f"Watchtower_Brace_{index}", (x + dx * 0.55, y + dy * 0.55, 6.2), (0.28, 0.28, 4.5), "MAT_DefenseTimber", 0.03, (0, math.radians(rz), 0)))
    objs += v0235.pitched_roof("Watchtower_Roof", (x, y), 6.0, 6.0, 8.7, 2.0, "MAT_RoofDark")
    objs += v0237.roof_tile_rhythm("Watchtower_Roof", x, y, 6.0, 6.0, 8.7, 2.0)
    parent(root, objs)


def market_module():
    root = base.parent_module("market_storehouse", (50, 66, 0))
    x, y = 50, 66
    objs = shell("Market", (x + 2.2, y), 5.0, 5.4, 3.0, "MAT_MarketCream", rise=1.65)
    objs += [
        *v0238.front_door("Market", x + 2.2, y - 2.85, 2.1, 1.15),
        base.box("Market_OpenHallFloor", (x - 2.4, y - 0.2, 0.85), (5.4, 6.0, 0.28), "MAT_StoneWarm", 0.06),
        base.box("Market_LongCounter", (x - 2.4, y - 2.3, 1.28), (5.2, 0.9, 0.9), "MAT_WoodHoney", 0.06),
        base.box("Market_BroadAwning", (x - 2.4, y - 1.0, 3.55), (6.2, 4.4, 0.18), "MAT_MarketCanvas", 0.04, (math.radians(-9), 0, 0)),
        base.box("Market_ClothValance", (x - 2.4, y - 3.0, 3.1), (6.2, 0.18, 0.72), "MAT_BannerRed", 0.02),
    ]
    for index, dx in enumerate((-4.7, -0.1)):
        objs.append(base.box(f"Market_AwningPost_{index}", (x + dx, y - 2.3, 1.8), (0.24, 0.24, 3.6), "MAT_WoodDark", 0.03))
    parent(root, objs)


def new_prop_modules():
    roots = []
    specs = [
        ("prop_laundry_bench", -20, ["bench", "line"]),
        ("prop_grain_cart", -10, ["cart"]),
        ("prop_timber_a_frame", 0, ["frame"]),
        ("prop_forge_tool_rack", 10, ["rack"]),
        ("prop_coal_ore_pile", 20, ["pile"]),
        ("prop_watchtower_ladder", 30, ["ladder"]),
    ]
    for name, x, _ in specs:
        root = base.parent_module(name, (x, 88, 0))
        objs = []
        if name == "prop_laundry_bench":
            objs = [
                base.box("Laundry_Bench", (x, 88, 0.65), (2.6, 0.7, 0.35), "MAT_WoodHoney", 0.04),
                base.box("Laundry_PostA", (x - 1.4, 88, 1.5), (0.18, 0.18, 3.0), "MAT_WoodDark", 0.03),
                base.box("Laundry_PostB", (x + 1.4, 88, 1.5), (0.18, 0.18, 3.0), "MAT_WoodDark", 0.03),
                base.box("Laundry_Cloth", (x, 88, 2.15), (1.9, 0.10, 0.75), "MAT_DomesticCream", 0.02),
            ]
        elif name == "prop_grain_cart":
            objs = [
                base.box("GrainCart_Bed", (x, 88, 0.85), (3.2, 1.8, 0.55), "MAT_LumberRaw", 0.06),
                base.cylinder("GrainCart_WheelA", (x - 1.1, 87.05, 0.65), 0.75, 0.25, "MAT_WoodDark", 12),
                base.cylinder("GrainCart_WheelB", (x - 1.1, 88.95, 0.65), 0.75, 0.25, "MAT_WoodDark", 12),
                base.box("GrainCart_Sacks", (x + 0.3, 88, 1.35), (1.8, 1.35, 0.65), "MAT_GrainSack", 0.14),
            ]
        elif name == "prop_timber_a_frame":
            objs = [
                base.box("TimberFrame_Left", (x - 0.8, 88, 1.7), (0.28, 0.28, 3.7), "MAT_LumberRaw", 0.03, (0, math.radians(-22), 0)),
                base.box("TimberFrame_Right", (x + 0.8, 88, 1.7), (0.28, 0.28, 3.7), "MAT_LumberRaw", 0.03, (0, math.radians(22), 0)),
                base.box("TimberFrame_Beam", (x, 88, 3.25), (3.0, 0.32, 0.32), "MAT_LumberRaw", 0.03),
            ]
        elif name == "prop_forge_tool_rack":
            objs = [
                base.box("ToolRack_PostA", (x - 1.2, 88, 1.4), (0.20, 0.20, 2.8), "MAT_WoodDark", 0.03),
                base.box("ToolRack_PostB", (x + 1.2, 88, 1.4), (0.20, 0.20, 2.8), "MAT_WoodDark", 0.03),
                base.box("ToolRack_Rail", (x, 88, 2.1), (2.7, 0.20, 0.24), "MAT_LumberRaw", 0.03),
                base.box("ToolRack_Tongs", (x - 0.55, 87.85, 1.2), (0.12, 0.12, 1.8), "MAT_IronBracket", 0.02),
                base.box("ToolRack_Hammer", (x + 0.55, 87.85, 1.3), (0.12, 0.12, 1.6), "MAT_IronBracket", 0.02),
            ]
        elif name == "prop_coal_ore_pile":
            for index, (dx, dy, scale) in enumerate([(-0.8, 0, 0.9), (0, 0.2, 1.1), (0.9, -0.1, 0.75), (0.2, -0.6, 0.65)]):
                objs.append(v0237.ico_sphere(f"CoalPile_{index}", (x + dx, 88 + dy, 0.45 * scale), 0.75 * scale, "MAT_ForgeSoot", 1))
        else:
            for index in range(2):
                objs.append(base.box(f"Ladder_Rail_{index}", (x - 0.65 + index * 1.3, 88, 2.2), (0.18, 0.18, 4.4), "MAT_LumberRaw", 0.02))
            for index in range(6):
                objs.append(base.box(f"Ladder_Rung_{index}", (x, 88, 0.45 + index * 0.72), (1.5, 0.18, 0.16), "MAT_LumberRaw", 0.02))
        parent(root, objs)
        roots.append(root)
    return roots


def export(output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    BLEND_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH.resolve()))
    bpy.ops.export_scene.gltf(filepath=str(output.resolve()), export_format="GLB", export_apply=True, export_yup=True, export_materials="EXPORT", export_cameras=False, export_lights=False)
    metadata = {
        "schemaVersion": 1, "checkpoint": CHECKPOINT,
        "status": "PASS_V0239_BLENDER_GLTF_EXPORT",
        "blendPath": BLEND_PATH.as_posix(), "glbPath": output.resolve().as_posix(),
        "sourceGenerator": "tools/blender/generate_v0239_barrosan_roster_silhouette_beauty.py",
        "sourceAssetRevision": "new v0.239 GLB; v0.238 and earlier assets retained unchanged",
        "modules": base.MODULES + v0236.ROLE_PROP_MODULES + v0237.VEGETATION_MODULES + v0237.INHABITED_PROP_MODULES + REVISED_BUILDINGS + v0238.PROP_MODULES + NEW_PROPS,
        "materials": list(v0236.PRODUCTION_PALETTE),
        "revisedBuildingModules": REVISED_BUILDINGS, "revisedBuildingModuleCount": len(REVISED_BUILDINGS),
        "addedOrRevisedPropModules": NEW_PROPS, "addedOrRevisedPropModuleCount": len(NEW_PROPS),
        "newOrChangedMaterialNames": list(MATERIAL_CHANGES), "newOrChangedMaterialCount": len(MATERIAL_CHANGES),
        "roofGeometryContract": {"centralRidgeHighest": True, "slopesDownToBothEaves": True, "eaveOverhang": True, "ridgeCaps": True, "fasciaBoards": True, "invertedRoofGeometry": False},
        "downloadedAssets": 0, "generatedAiImages": 0,
    }
    output.with_suffix(".export.json").write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()
    configure_scene()
    base.terrain_modules()
    base.road_modules()
    v0236.enhanced_river_bridge_modules()
    roots, _ = v0236.enhanced_landmark_modules()
    v0237.enrich_landmarks(roots)
    base.prop_modules()
    v0236.role_prop_modules()
    v0237.vegetation_modules()
    v0237.inhabited_prop_modules()
    v0238.prop_modules()
    house_module()
    granary_module()
    lumber_module()
    forge_module()
    watchtower_module()
    market_module()
    new_prop_modules()
    export(Path(args.output))
    print(json.dumps({"checkpoint": CHECKPOINT, "revisedBuildingModuleCount": 6, "addedOrRevisedPropModuleCount": 6, "newOrChangedMaterialCount": 6}))


if __name__ == "__main__":
    main()
