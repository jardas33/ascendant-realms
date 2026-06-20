"""Author the v0.238 Barrosan domestic, economy, support, and defense roster."""

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


CHECKPOINT = "v0.238"
BLEND_PATH = Path("art-source/blender/v0238/salto_barrosan_building_roster.blend")
DEFAULT_OUTPUT = Path("desktop-spikes/godot-salto/assets/v0238/salto_barrosan_building_roster.glb")

BUILDING_MODULES = [
    "house_dwelling",
    "farm_granary",
    "lumber_carpenter_yard",
    "blacksmith_forge",
    "watchtower_defense",
    "market_storehouse",
]

PROP_MODULES = [
    "prop_garden_plot",
    "prop_grain_sacks",
    "prop_hay_bales",
    "prop_saw_bench",
    "prop_anvil",
    "prop_forge_brazier",
    "prop_market_goods",
    "prop_supply_stall",
]

NEW_MATERIALS = {
    "MAT_LimewashDomestic": (0.86, 0.79, 0.62, 1.0),
    "MAT_LimewashEconomy": (0.72, 0.58, 0.36, 1.0),
    "MAT_Straw": (0.68, 0.53, 0.22, 1.0),
    "MAT_GrainSack": (0.58, 0.45, 0.28, 1.0),
    "MAT_ForgeStone": (0.20, 0.20, 0.18, 1.0),
    "MAT_ForgeHot": (0.96, 0.24, 0.055, 1.0),
    "MAT_MarketCream": (0.82, 0.72, 0.50, 1.0),
    "MAT_MarketOchre": (0.70, 0.40, 0.14, 1.0),
    "MAT_DefenseTimber": (0.25, 0.13, 0.07, 1.0),
    "MAT_GardenSoil": (0.27, 0.19, 0.11, 1.0),
}


def parse_args() -> argparse.Namespace:
    raw = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    return parser.parse_args(raw)


def configure_scene() -> None:
    v0236.PRODUCTION_PALETTE.update(v0237.NEW_MATERIALS)
    v0236.PRODUCTION_PALETTE.update(NEW_MATERIALS)
    v0236.configure_scene()


def parent(root, objects):
    base.parent_children(root, objects)


def shell(prefix, center, width, depth, wall_height, wall_mat, roof_mat="MAT_RoofClay"):
    x, y = center
    objs = [
        base.box(f"{prefix}_Contact", (x, y, -0.08), (width + 1.0, depth + 1.0, 0.28), "MAT_ContactDirt", 0.14),
        base.box(f"{prefix}_Foundation", (x, y, 0.28), (width + 0.55, depth + 0.55, 0.72), "MAT_StoneDark", 0.18),
        base.box(f"{prefix}_FoundationCourse", (x, y, 0.76), (width + 0.25, depth + 0.25, 0.30), "MAT_StoneChip", 0.10),
        base.box(f"{prefix}_Wall", (x, y, 0.88 + wall_height / 2), (width, depth, wall_height), wall_mat, 0.17),
    ]
    eave_z = 0.88 + wall_height + 0.10
    rise = max(1.25, depth * 0.34)
    objs += v0235.pitched_roof(f"{prefix}_Roof", center, width, depth, eave_z, rise, roof_mat)
    objs += v0237.roof_tile_rhythm(f"{prefix}_Roof", x, y, width, depth, eave_z, rise)
    return objs


def front_door(prefix, x, front_y, height=2.35, width=1.35):
    return [
        base.box(f"{prefix}_DoorRecess", (x, front_y, 1.65), (width, 0.30, height), "MAT_ContactDark", 0.04),
        base.box(f"{prefix}_DoorHeader", (x, front_y - 0.10, 2.92), (width + 0.65, 0.26, 0.28), "MAT_WoodDark", 0.04),
        base.box(f"{prefix}_Threshold", (x, front_y - 0.34, 0.92), (width + 0.45, 0.68, 0.18), "MAT_StoneChip", 0.04),
    ]


def timber_front(prefix, x, front_y, width, zs=(1.55, 3.15)):
    objs = []
    for dx in (-width * 0.38, 0, width * 0.38):
        objs.append(base.box(f"{prefix}_Pier_{dx}", (x + dx, front_y, 2.35), (0.24, 0.24, 3.1), "MAT_WoodWeathered", 0.035))
    for index, z in enumerate(zs):
        objs.append(base.box(f"{prefix}_Rail_{index}", (x, front_y, z), (width + 0.15, 0.25, 0.24), "MAT_WoodRed", 0.035))
    return objs


def house_module():
    root = base.parent_module("house_dwelling", (-24, 66, 0))
    x, y = -24, 66
    objs = shell("House", (x, y), 6.0, 5.0, 3.4, "MAT_LimewashDomestic")
    objs += front_door("House", x, y - 2.65, 2.15, 1.15)
    objs += timber_front("House", x, y - 2.57, 5.5, (1.45, 3.15))
    objs += [
        base.box("House_PorchDeck", (x, y - 3.25, 0.95), (4.2, 1.45, 0.22), "MAT_WoodHoney", 0.06),
        base.box("House_PorchRoof", (x, y - 3.05, 3.28), (4.5, 1.65, 0.18), "MAT_RoofTileDark", 0.05, (math.radians(-9), 0, 0)),
        base.box("House_WindowLeft", (x - 1.8, y - 2.58, 2.05), (0.85, 0.16, 1.05), "MAT_MarketCream", 0.04),
        base.box("House_WindowRight", (x + 1.8, y - 2.58, 2.05), (0.85, 0.16, 1.05), "MAT_MarketCream", 0.04),
    ]
    parent(root, objs)
    return root


def farm_module():
    root = base.parent_module("farm_granary", (-10, 66, 0))
    x, y = -10, 66
    objs = shell("Granary", (x, y), 8.4, 6.2, 4.4, "MAT_LimewashEconomy")
    objs += front_door("Granary", x, y - 3.25, 3.0, 2.25)
    objs += timber_front("Granary", x, y - 3.17, 7.8, (1.6, 3.5))
    objs += [
        base.box("Granary_RaisedFloor", (x, y, 1.15), (8.7, 6.5, 0.28), "MAT_WoodDark", 0.08),
        base.box("Granary_LoftVent", (x, y - 3.22, 4.35), (1.65, 0.18, 1.15), "MAT_ContactDark", 0.04),
        base.box("Granary_HayLeanTo", (x + 5.0, y + 0.5, 2.25), (2.3, 4.6, 0.20), "MAT_Straw", 0.06, (0, math.radians(10), 0)),
    ]
    parent(root, objs)
    return root


def lumber_module():
    root = base.parent_module("lumber_carpenter_yard", (6, 66, 0))
    x, y = 6, 66
    objs = shell("Lumber", (x, y), 7.0, 5.4, 3.2, "MAT_LimewashEconomy", "MAT_RoofDark")
    objs += front_door("Lumber", x - 1.1, y - 2.85, 2.1, 1.25)
    objs += timber_front("Lumber", x, y - 2.77, 6.5, (1.4, 2.95))
    objs += [
        base.box("Lumber_OpenBay", (x + 2.0, y - 2.78, 2.05), (2.0, 0.24, 2.4), "MAT_ContactDark", 0.04),
        base.box("Lumber_Canopy", (x + 5.0, y + 0.2, 3.0), (4.2, 4.8, 0.18), "MAT_RoofTileDark", 0.05, (0, math.radians(-8), 0)),
        base.box("Lumber_CanopyPostA", (x + 3.3, y - 1.5, 1.5), (0.22, 0.22, 3.0), "MAT_DefenseTimber", 0.03),
        base.box("Lumber_CanopyPostB", (x + 3.3, y + 1.6, 1.5), (0.22, 0.22, 3.0), "MAT_DefenseTimber", 0.03),
        base.box("Lumber_CanopyPostC", (x + 6.6, y - 1.5, 1.5), (0.22, 0.22, 3.0), "MAT_DefenseTimber", 0.03),
        base.box("Lumber_CanopyPostD", (x + 6.6, y + 1.6, 1.5), (0.22, 0.22, 3.0), "MAT_DefenseTimber", 0.03),
    ]
    parent(root, objs)
    return root


def forge_module():
    root = base.parent_module("blacksmith_forge", (22, 66, 0))
    x, y = 22, 66
    objs = shell("Forge", (x, y), 7.2, 5.8, 3.6, "MAT_PlasterShadow", "MAT_RoofDark")
    objs += front_door("Forge", x - 1.6, y - 3.05, 2.3, 1.35)
    objs += timber_front("Forge", x, y - 2.97, 6.6, (1.45, 3.25))
    objs += [
        base.box("Forge_OpenWorkBay", (x + 1.7, y - 2.98, 2.0), (2.25, 0.24, 2.6), "MAT_ForgeStone", 0.04),
        base.box("Forge_Chimney", (x + 2.2, y + 1.25, 5.1), (1.35, 1.35, 5.8), "MAT_ForgeStone", 0.14),
        base.box("Forge_ChimneyCap", (x + 2.2, y + 1.25, 8.05), (1.65, 1.65, 0.28), "MAT_StoneWarm", 0.06),
        base.box("Forge_Hearth", (x + 1.7, y - 2.68, 1.4), (1.55, 0.55, 1.1), "MAT_ForgeStone", 0.05),
        base.box("Forge_HotCore", (x + 1.7, y - 2.99, 1.5), (0.9, 0.18, 0.48), "MAT_ForgeHot", 0.03),
    ]
    parent(root, objs)
    return root


def watchtower_module():
    root = base.parent_module("watchtower_defense", (36, 66, 0))
    x, y = 36, 66
    objs = [
        base.box("Watchtower_Contact", (x, y, -0.08), (6.8, 6.8, 0.28), "MAT_ContactDirt", 0.14),
        base.box("Watchtower_Foundation", (x, y, 0.35), (6.2, 6.2, 0.85), "MAT_StoneDark", 0.20),
        base.box("Watchtower_StoneShaft", (x, y, 3.0), (4.4, 4.4, 4.8), "MAT_StoneWarm", 0.18),
        base.box("Watchtower_TimberUpper", (x, y, 6.0), (5.4, 5.4, 2.0), "MAT_DefenseTimber", 0.12),
        base.box("Watchtower_LookoutDeck", (x, y, 7.0), (6.6, 6.6, 0.34), "MAT_WoodWeathered", 0.09),
        base.box("Watchtower_FiringGapFront", (x, y - 2.76, 6.15), (2.6, 0.18, 0.70), "MAT_ContactDark", 0.03),
        base.box("Watchtower_Door", (x, y - 2.22, 1.55), (1.15, 0.24, 2.25), "MAT_ContactDark", 0.04),
    ]
    for dx, dy in [(-2.7, -2.7), (2.7, -2.7), (-2.7, 2.7), (2.7, 2.7)]:
        objs.append(base.box(f"Watchtower_RailPost_{dx}_{dy}", (x + dx, y + dy, 7.75), (0.24, 0.24, 1.5), "MAT_DefenseTimber", 0.03))
    objs += v0235.pitched_roof("Watchtower_Roof", (x, y), 5.8, 5.8, 8.2, 1.75, "MAT_RoofDark")
    objs += v0237.roof_tile_rhythm("Watchtower_Roof", x, y, 5.8, 5.8, 8.2, 1.75)
    parent(root, objs)
    return root


def market_module():
    root = base.parent_module("market_storehouse", (50, 66, 0))
    x, y = 50, 66
    objs = shell("Market", (x, y), 8.0, 5.6, 3.5, "MAT_MarketCream")
    objs += front_door("Market", x + 2.3, y - 2.95, 2.25, 1.25)
    objs += timber_front("Market", x, y - 2.87, 7.4, (1.45, 3.15))
    objs += [
        base.box("Market_OpenFront", (x - 1.4, y - 2.90, 2.0), (3.7, 0.22, 2.5), "MAT_ContactDark", 0.04),
        base.box("Market_Counter", (x - 1.4, y - 3.35, 1.25), (4.2, 0.80, 0.95), "MAT_WoodHoney", 0.07),
        base.box("Market_Awning", (x - 1.4, y - 3.5, 3.4), (4.8, 2.1, 0.16), "MAT_MarketOchre", 0.05, (math.radians(-10), 0, 0)),
        base.box("Market_ClothStripe", (x - 1.4, y - 4.0, 3.18), (4.8, 0.16, 0.45), "MAT_BannerRed", 0.03),
    ]
    parent(root, objs)
    return root


def prop_modules():
    roots = []

    root = base.parent_module("prop_garden_plot", (-20, 78, 0))
    objs = [base.box("Garden_Soil", (-20, 78, 0.10), (4.4, 2.8, 0.20), "MAT_GardenSoil", 0.10)]
    for row in (-0.75, 0, 0.75):
        objs.append(base.box(f"Garden_Row_{row}", (-20, 78 + row, 0.27), (3.7, 0.20, 0.18), "MAT_LeafOlive", 0.04))
    parent(root, objs); roots.append(root)

    root = base.parent_module("prop_grain_sacks", (-10, 78, 0))
    objs = []
    for index, (dx, dy, z) in enumerate([(-0.7, 0, 0.38), (0, 0, 0.38), (0.7, 0, 0.38), (-0.35, 0.25, 1.0), (0.4, 0.25, 1.0)]):
        objs.append(base.box(f"GrainSack_{index}", (-10 + dx, 78 + dy, z), (0.75, 1.0, 0.65), "MAT_GrainSack", 0.18))
    parent(root, objs); roots.append(root)

    root = base.parent_module("prop_hay_bales", (0, 78, 0))
    objs = [
        base.box("HayBale_A", (-0.75, 78, 0.50), (1.35, 1.0, 1.0), "MAT_Straw", 0.12),
        base.box("HayBale_B", (0.75, 78, 0.50), (1.35, 1.0, 1.0), "MAT_Straw", 0.12),
        base.box("HayBale_C", (0, 78, 1.45), (1.35, 1.0, 0.90), "MAT_Straw", 0.12),
    ]
    parent(root, objs); roots.append(root)

    root = base.parent_module("prop_saw_bench", (10, 78, 0))
    objs = [
        base.box("SawBench_Top", (10, 78, 1.1), (3.5, 1.2, 0.24), "MAT_WoodHoney", 0.05),
        base.box("SawBench_LegA", (8.8, 78, 0.55), (0.22, 0.75, 1.1), "MAT_WoodDark", 0.03),
        base.box("SawBench_LegB", (11.2, 78, 0.55), (0.22, 0.75, 1.1), "MAT_WoodDark", 0.03),
        base.box("SawBench_Blade", (10, 77.7, 1.42), (2.6, 0.10, 0.22), "MAT_IronBracket", 0.02, (0, 0, math.radians(12))),
    ]
    parent(root, objs); roots.append(root)

    root = base.parent_module("prop_anvil", (20, 78, 0))
    objs = [
        base.box("Anvil_Base", (20, 78, 0.45), (1.0, 1.0, 0.9), "MAT_ForgeStone", 0.08),
        base.box("Anvil_Body", (20, 78, 1.05), (1.7, 0.75, 0.45), "MAT_IronBracket", 0.05),
        base.box("Anvil_Horn", (20.9, 78, 1.13), (1.15, 0.40, 0.28), "MAT_IronBracket", 0.03),
    ]
    parent(root, objs); roots.append(root)

    root = base.parent_module("prop_forge_brazier", (30, 78, 0))
    objs = [
        base.box("Brazier_Base", (30, 78, 0.45), (1.4, 1.4, 0.9), "MAT_ForgeStone", 0.10),
        base.box("Brazier_Coals", (30, 78, 0.92), (1.05, 1.05, 0.18), "MAT_ForgeHot", 0.05),
    ]
    parent(root, objs); roots.append(root)

    root = base.parent_module("prop_market_goods", (40, 78, 0))
    objs = [
        base.box("Goods_CrateA", (39.2, 78, 0.55), (1.3, 1.3, 1.1), "MAT_WoodWeathered", 0.08),
        base.box("Goods_CrateB", (40.5, 78, 0.42), (1.0, 1.0, 0.84), "MAT_WoodHoney", 0.08),
        base.cylinder("Goods_Barrel", (41.3, 78, 0.60), 0.52, 1.2, "MAT_WoodRed", 10),
    ]
    parent(root, objs); roots.append(root)

    root = base.parent_module("prop_supply_stall", (50, 78, 0))
    objs = [
        base.box("Stall_Counter", (50, 78, 1.05), (3.2, 1.25, 0.85), "MAT_WoodHoney", 0.07),
        base.box("Stall_PostA", (48.7, 78, 2.0), (0.18, 0.18, 3.4), "MAT_WoodDark", 0.03),
        base.box("Stall_PostB", (51.3, 78, 2.0), (0.18, 0.18, 3.4), "MAT_WoodDark", 0.03),
        base.box("Stall_Awning", (50, 78, 3.35), (3.4, 2.0, 0.16), "MAT_BannerRed", 0.04, (math.radians(7), 0, 0)),
    ]
    parent(root, objs); roots.append(root)
    return roots


def export(output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    BLEND_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH.resolve()))
    bpy.ops.export_scene.gltf(
        filepath=str(output.resolve()), export_format="GLB", export_apply=True,
        export_yup=True, export_materials="EXPORT", export_cameras=False, export_lights=False,
    )
    metadata = {
        "schemaVersion": 1,
        "checkpoint": CHECKPOINT,
        "status": "PASS_V0238_BLENDER_GLTF_EXPORT",
        "blendPath": BLEND_PATH.as_posix(),
        "glbPath": output.resolve().as_posix(),
        "sourceGenerator": "tools/blender/generate_v0238_barrosan_building_roster.py",
        "sourceAssetRevision": "new v0.238 GLB; v0.237 and earlier assets retained unchanged",
        "modules": base.MODULES + v0236.ROLE_PROP_MODULES + v0237.VEGETATION_MODULES + v0237.INHABITED_PROP_MODULES + BUILDING_MODULES + PROP_MODULES,
        "materials": list(v0236.PRODUCTION_PALETTE),
        "newBuildingModules": BUILDING_MODULES,
        "newBuildingModuleCount": len(BUILDING_MODULES),
        "newPropModules": PROP_MODULES,
        "newPropModuleCount": len(PROP_MODULES),
        "newOrChangedMaterialNames": list(NEW_MATERIALS),
        "newOrChangedMaterialCount": len(NEW_MATERIALS),
        "roofGeometryContract": {
            "centralRidgeHighest": True, "slopesDownToBothEaves": True,
            "eaveOverhang": True, "ridgeCaps": True, "fasciaBoards": True,
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
    roots, _ = v0236.enhanced_landmark_modules()
    v0237.enrich_landmarks(roots)
    base.prop_modules()
    v0236.role_prop_modules()
    v0237.vegetation_modules()
    v0237.inhabited_prop_modules()
    house_module(); farm_module(); lumber_module(); forge_module(); watchtower_module(); market_module()
    prop_modules()
    export(Path(args.output))
    print(json.dumps({"checkpoint": CHECKPOINT, "newBuildingModuleCount": 6, "newPropModuleCount": 8, "newOrChangedMaterialCount": 10}))


if __name__ == "__main__":
    main()
