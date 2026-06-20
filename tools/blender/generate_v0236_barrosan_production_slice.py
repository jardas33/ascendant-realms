"""Author the v0.236 Barrosan faction production-direction asset revision."""

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


CHECKPOINT = "v0.236"
BLEND_PATH = Path("art-source/blender/v0236/salto_barrosan_production_slice.blend")
DEFAULT_OUTPUT = Path("desktop-spikes/godot-salto/assets/v0236/salto_barrosan_production_slice.glb")
CHANGED_BUILDING_MODULES = [
    "keep_landmark",
    "barracks_workshop_landmark",
    "mine_lume_landmark",
]
ROLE_PROP_MODULES = [
    "prop_weapon_rack",
    "prop_training_post",
    "prop_tool_cart",
    "prop_crystal_shards",
    "prop_mine_support",
    "prop_civic_banner",
]
NEW_MATERIAL_NAMES = [
    "MAT_PlasterCream",
    "MAT_PlasterOchre",
    "MAT_PlasterShadow",
    "MAT_StoneMoss",
    "MAT_StoneChalk",
    "MAT_RoofSun",
    "MAT_RoofAged",
    "MAT_WoodRed",
    "MAT_WoodWeathered",
    "MAT_IronDark",
    "MAT_BannerRed",
    "MAT_BannerGold",
    "MAT_CrystalDeep",
    "MAT_CrystalPale",
]


PRODUCTION_PALETTE = {
    # Retuned v0.235 material families.
    "MAT_Stone": (0.39, 0.37, 0.32, 1.0),
    "MAT_StoneLight": (0.57, 0.54, 0.47, 1.0),
    "MAT_StoneWarm": (0.47, 0.38, 0.27, 1.0),
    "MAT_StoneDark": (0.12, 0.14, 0.14, 1.0),
    "MAT_RoadDirt": (0.40, 0.29, 0.19, 1.0),
    "MAT_Grass": (0.28, 0.37, 0.20, 1.0),
    "MAT_Earth": (0.31, 0.24, 0.16, 1.0),
    "MAT_Roof": (0.35, 0.16, 0.10, 1.0),
    "MAT_RoofClay": (0.44, 0.19, 0.12, 1.0),
    "MAT_RoofDark": (0.22, 0.11, 0.08, 1.0),
    "MAT_Wood": (0.34, 0.19, 0.10, 1.0),
    "MAT_WoodLight": (0.48, 0.31, 0.18, 1.0),
    "MAT_WoodDark": (0.15, 0.085, 0.052, 1.0),
    "MAT_EaveDark": (0.075, 0.042, 0.028, 1.0),
    "MAT_Water": (0.035, 0.22, 0.28, 1.0),
    "MAT_Crystal": (0.08, 0.76, 0.69, 1.0),
    "MAT_ContactDark": (0.055, 0.047, 0.036, 1.0),
    "MAT_Plaster": (0.70, 0.61, 0.44, 1.0),
    "MAT_PlasterLight": (0.83, 0.75, 0.58, 1.0),
    "MAT_PlasterWarm": (0.66, 0.49, 0.30, 1.0),
    "MAT_Metal": (0.26, 0.29, 0.28, 1.0),
    # New v0.236 art-bible variants.
    "MAT_PlasterCream": (0.88, 0.80, 0.65, 1.0),
    "MAT_PlasterOchre": (0.68, 0.48, 0.27, 1.0),
    "MAT_PlasterShadow": (0.42, 0.31, 0.23, 1.0),
    "MAT_StoneMoss": (0.30, 0.36, 0.25, 1.0),
    "MAT_StoneChalk": (0.68, 0.64, 0.54, 1.0),
    "MAT_RoofSun": (0.49, 0.22, 0.14, 1.0),
    "MAT_RoofAged": (0.34, 0.15, 0.11, 1.0),
    "MAT_WoodRed": (0.40, 0.17, 0.11, 1.0),
    "MAT_WoodWeathered": (0.47, 0.34, 0.23, 1.0),
    "MAT_IronDark": (0.10, 0.12, 0.12, 1.0),
    "MAT_BannerRed": (0.50, 0.08, 0.055, 1.0),
    "MAT_BannerGold": (0.72, 0.48, 0.13, 1.0),
    "MAT_CrystalDeep": (0.02, 0.40, 0.42, 1.0),
    "MAT_CrystalPale": (0.22, 0.72, 0.67, 1.0),
}


def parse_args() -> argparse.Namespace:
    raw = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    return parser.parse_args(raw)


def configure_scene() -> None:
    base.PALETTE.clear()
    base.PALETTE.update(PRODUCTION_PALETTE)
    base.configure_scene()


def add_parented(root: bpy.types.Object, objects) -> None:
    base.parent_children(root, objects)


def stone_course(
    prefix: str,
    start_x: float,
    y: float,
    z: float,
    count: int,
    spacing: float,
    mat_a: str = "MAT_StoneChalk",
    mat_b: str = "MAT_StoneWarm",
):
    blocks = []
    for index in range(count):
        width = 0.72 + (index % 3) * 0.08
        blocks.append(
            base.box(
                f"{prefix}_{index:02d}",
                (start_x + index * spacing, y, z + (index % 2) * 0.035),
                (width, 0.28, 0.34 + (index % 2) * 0.05),
                mat_a if index % 3 else mat_b,
                0.08,
                (0, 0, math.radians((index % 3 - 1) * 2.5)),
            )
        )
    return blocks


def facade_patch(name: str, location, scale, mat_name: str):
    return base.box(name, location, scale, mat_name, 0.035)


def roof_weather_bands(
    prefix: str,
    center_x: float,
    center_y: float,
    width: float,
    depth: float,
    eave_z: float,
    rise: float,
):
    pieces = []
    half_depth = (depth + 0.96) / 2
    angle = math.atan2(rise, half_depth)
    for side in (-1, 1):
        for index, ratio in enumerate((0.28, 0.58, 0.82)):
            y = center_y + side * half_depth * ratio
            z = eave_z + rise * (1.0 - ratio) + 0.10
            pieces.append(
                base.box(
                    f"{prefix}_WeatherBand_{side}_{index}",
                    (center_x, y, z),
                    (width + 0.28, 0.17, 0.09),
                    "MAT_RoofSun" if (index + side) % 2 else "MAT_RoofAged",
                    0.025,
                    (side * angle, 0, 0),
                )
            )
    return pieces


def keep_details(root: bpy.types.Object) -> int:
    details = [
        base.box("Keep_FormalStep_Low", (10, -2.55, 0.55), (5.4, 1.7, 0.36), "MAT_StoneDark", 0.10),
        base.box("Keep_FormalStep_Mid", (10, -2.15, 0.82), (4.6, 1.25, 0.30), "MAT_StoneWarm", 0.08),
        base.box("Keep_FormalStep_High", (10, -1.75, 1.04), (3.8, 0.88, 0.24), "MAT_StoneChalk", 0.06),
        facade_patch("Keep_GateStoneLeft", (8.55, -1.42, 3.1), (0.62, 0.22, 4.6), "MAT_StoneChalk"),
        facade_patch("Keep_GateStoneRight", (11.45, -1.42, 3.1), (0.62, 0.22, 4.6), "MAT_StoneWarm"),
        facade_patch("Keep_GateCrown", (10, -1.43, 5.25), (3.5, 0.24, 0.58), "MAT_StoneChalk"),
        base.box("Keep_CivicBeam", (10, -1.55, 5.75), (6.4, 0.28, 0.28), "MAT_WoodRed", 0.04),
        base.box("Keep_BannerPoleLeft", (7.15, -1.62, 4.3), (0.16, 0.16, 4.3), "MAT_IronDark", 0.03),
        base.box("Keep_BannerLeft", (7.55, -1.64, 4.5), (0.72, 0.10, 1.85), "MAT_BannerRed", 0.03),
        base.box("Keep_BannerGoldLeft", (7.55, -1.70, 4.55), (0.17, 0.08, 1.25), "MAT_BannerGold", 0.02),
        base.box("Keep_BannerPoleRight", (12.85, -1.62, 4.3), (0.16, 0.16, 4.3), "MAT_IronDark", 0.03),
        base.box("Keep_BannerRight", (12.45, -1.64, 4.5), (0.72, 0.10, 1.85), "MAT_BannerRed", 0.03),
        base.box("Keep_BannerGoldRight", (12.45, -1.70, 4.55), (0.17, 0.08, 1.25), "MAT_BannerGold", 0.02),
        facade_patch("Keep_FacadeShadeLeft", (8.35, -1.38, 4.15), (1.45, 0.12, 1.45), "MAT_StoneMoss"),
        facade_patch("Keep_FacadeShadeRight", (11.9, -1.38, 2.35), (1.15, 0.12, 1.05), "MAT_StoneWarm"),
    ]
    details += stone_course("Keep_FrontCourse", 6.65, -1.48, 1.28, 9, 0.82)
    details += roof_weather_bands("Keep_Roof", 10, 2, 7.4, 5.8, 6.05, 2.25)
    for dx, dy, angle in [
        (-4.2, -3.2, 0),
        (4.2, -3.2, 20),
        (-4.2, 3.2, 40),
        (4.2, 3.2, 60),
    ]:
        details.append(
            base.box(
                f"Keep_TowerMoss_{dx}_{dy}",
                (10 + dx, 2 + dy - 1.64, 1.2),
                (1.45, 0.16, 0.72),
                "MAT_StoneMoss",
                0.06,
                (0, 0, math.radians(angle)),
            )
        )
    add_parented(root, details)
    return len(details)


def barracks_details(root: bpy.types.Object) -> int:
    details = [
        facade_patch("Barracks_PlasterRepairLeft", (25.05, -1.34, 3.05), (1.45, 0.12, 1.35), "MAT_PlasterCream"),
        facade_patch("Barracks_PlasterRepairRight", (29.95, -1.34, 2.15), (1.55, 0.12, 1.15), "MAT_PlasterOchre"),
        facade_patch("Barracks_ShadowCourse", (27.5, -1.35, 1.20), (8.35, 0.13, 0.48), "MAT_PlasterShadow"),
        base.box("Barracks_WindowLeft", (25.0, -1.45, 3.15), (1.15, 0.18, 1.35), "MAT_ContactDark", 0.04),
        base.box("Barracks_ShutterLeftA", (24.28, -1.56, 3.15), (0.25, 0.16, 1.55), "MAT_WoodRed", 0.03),
        base.box("Barracks_ShutterLeftB", (25.72, -1.56, 3.15), (0.25, 0.16, 1.55), "MAT_WoodWeathered", 0.03),
        base.box("Barracks_WindowRight", (30.0, -1.45, 3.15), (1.15, 0.18, 1.35), "MAT_ContactDark", 0.04),
        base.box("Barracks_ShutterRightA", (29.28, -1.56, 3.15), (0.25, 0.16, 1.55), "MAT_WoodWeathered", 0.03),
        base.box("Barracks_ShutterRightB", (30.72, -1.56, 3.15), (0.25, 0.16, 1.55), "MAT_WoodRed", 0.03),
        base.box("Workshop_ToolBoard", (34.0, 0.45, 2.15), (2.7, 0.18, 1.3), "MAT_WoodWeathered", 0.05),
        base.box("Workshop_ToolIronA", (33.3, 0.30, 2.25), (0.12, 0.12, 0.92), "MAT_IronDark", 0.02, (0, 0, math.radians(12))),
        base.box("Workshop_ToolIronB", (34.0, 0.30, 2.30), (0.12, 0.12, 1.02), "MAT_IronDark", 0.02, (0, 0, math.radians(-10))),
        base.box("Workshop_ToolIronC", (34.7, 0.30, 2.20), (0.12, 0.12, 0.82), "MAT_IronDark", 0.02, (0, 0, math.radians(18))),
        base.box("Workshop_ChimneySoot", (35.2, 2.80, 5.7), (0.72, 0.12, 1.5), "MAT_ContactDark", 0.03),
    ]
    details += stone_course("Barracks_FoundationBlock", 23.65, -1.42, 0.92, 11, 0.76)
    details += roof_weather_bands("Barracks_Roof", 27.5, 2, 9.4, 6.0, 5.15, 2.25)
    details += roof_weather_bands("Workshop_Roof", 34.2, 2.7, 4.25, 4.3, 3.62, 1.55)
    add_parented(root, details)
    return len(details)


def mine_details(root: bpy.types.Object) -> int:
    details = [
        facade_patch("Mine_PlasterShadeLeft", (44.3, -0.58, 2.8), (1.4, 0.14, 1.6), "MAT_PlasterShadow"),
        facade_patch("Mine_PlasterRepairRight", (49.7, -0.58, 2.6), (1.25, 0.14, 1.25), "MAT_PlasterOchre"),
        base.box("Mine_PortalInnerFrame", (47, -1.29, 2.15), (3.15, 0.18, 3.25), "MAT_IronDark", 0.05),
        base.box("Mine_PortalCrossBeam", (47, -1.44, 3.76), (4.55, 0.28, 0.38), "MAT_WoodWeathered", 0.05),
        v0235.diagonal_beam("Mine_PortalBraceLeft", (45.15, -1.43, 0.95), (46.25, -1.43, 3.55), 0.23, "MAT_WoodRed"),
        v0235.diagonal_beam("Mine_PortalBraceRight", (47.75, -1.43, 3.55), (48.85, -1.43, 0.95), 0.23, "MAT_WoodWeathered"),
        base.cylinder("Mine_SecondaryPulley", (51.15, 2.72, 3.35), 0.38, 0.24, "MAT_IronDark", 12),
        base.box("Mine_HangingChain", (51.15, 2.70, 2.55), (0.10, 0.10, 1.45), "MAT_IronDark", 0.02),
        base.box("Lume_WellGlowBand", (52.0, -1.45, 1.58), (2.2, 0.16, 0.22), "MAT_CrystalDeep", 0.04),
    ]
    details += stone_course("Mine_PortalStone", 44.05, -1.38, 0.95, 8, 0.84, "MAT_StoneWarm", "MAT_StoneMoss")
    details += roof_weather_bands("Mine_Roof", 47, 2.4, 8.0, 5.4, 4.60, 1.75)
    for index, (x, y, scale) in enumerate([
        (50.7, -0.8, 0.40),
        (51.5, -1.0, 0.28),
        (52.7, -0.9, 0.34),
        (53.3, -0.1, 0.24),
    ]):
        crystal = base.cylinder(
            f"Mine_ExtractedCrystal_{index}",
            (x, y, 0.75 + scale),
            scale,
            1.0 + scale * 2.0,
            "MAT_CrystalPale" if index % 2 else "MAT_CrystalDeep",
            6,
        )
        crystal.rotation_euler[0] = math.radians((index - 1) * 7)
        details.append(crystal)
    add_parented(root, details)
    return len(details)


def enhanced_landmark_modules():
    roots = v0235.landmark_modules()
    detail_count = 0
    for root in roots:
        if root.name == "keep_landmark":
            detail_count += keep_details(root)
        elif root.name == "barracks_workshop_landmark":
            detail_count += barracks_details(root)
        elif root.name == "mine_lume_landmark":
            detail_count += mine_details(root)
    return roots, detail_count


def enhanced_river_bridge_modules():
    roots = v0235.river_bridge_modules()
    bridge = next(root for root in roots if root.name == "bridge_module")
    details = [
        facade_patch("Bridge_MossWest", (-11.55, -2.2, 0.35), (0.75, 1.1, 0.55), "MAT_StoneMoss"),
        facade_patch("Bridge_MossEast", (-2.45, 2.2, 0.32), (0.75, 1.1, 0.52), "MAT_StoneMoss"),
        base.box("Bridge_CivicMarkerWest", (-10.65, -2.15, 2.05), (0.20, 0.20, 1.65), "MAT_BannerRed", 0.03),
        base.box("Bridge_CivicMarkerEast", (-3.35, 2.15, 2.05), (0.20, 0.20, 1.65), "MAT_BannerGold", 0.03),
    ]
    add_parented(bridge, details)
    return roots


def role_prop_modules():
    roots = []

    root = base.parent_module("prop_weapon_rack", (-20, 30, 0))
    objs = [
        base.box("WeaponRack_Base", (-20, 30, 0.15), (4.2, 1.2, 0.3), "MAT_ContactDark", 0.08),
        base.box("WeaponRack_Rail", (-20, 30, 1.55), (3.8, 0.35, 0.28), "MAT_WoodWeathered", 0.05),
    ]
    for x in (-21.45, -20.5, -19.5, -18.55):
        objs.append(base.box(f"WeaponRack_Spear_{x}", (x, 30, 1.65), (0.12, 0.12, 2.9), "MAT_WoodRed", 0.02, (0, 0, math.radians((x + 20) * 4))))
        objs.append(base.box(f"WeaponRack_Head_{x}", (x, 30, 3.0), (0.30, 0.16, 0.42), "MAT_IronDark", 0.03, (0, 0, math.radians(45))))
    add_parented(root, objs)
    roots.append(root)

    root = base.parent_module("prop_training_post", (-10, 30, 0))
    objs = [
        base.box("TrainingPost_Base", (-10, 30, 0.18), (2.5, 2.0, 0.36), "MAT_ContactDark", 0.12),
        base.cylinder("TrainingPost_Body", (-10, 30, 1.65), 0.28, 3.0, "MAT_WoodWeathered", 10),
        base.box("TrainingPost_Arms", (-10, 30, 2.05), (2.2, 0.22, 0.22), "MAT_WoodRed", 0.05),
        base.cylinder("TrainingPost_Head", (-10, 30, 3.25), 0.42, 0.70, "MAT_WoodLight", 10),
        base.box("TrainingPost_Shield", (-9.55, 29.70, 1.45), (0.75, 0.18, 1.15), "MAT_BannerRed", 0.08),
    ]
    add_parented(root, objs)
    roots.append(root)

    root = base.parent_module("prop_tool_cart", (0, 30, 0))
    objs = [
        base.box("ToolCart_Bed", (0, 30, 0.85), (3.0, 1.55, 0.45), "MAT_WoodWeathered", 0.08),
        base.box("ToolCart_RimLeft", (0, 29.3, 1.3), (3.1, 0.18, 0.75), "MAT_WoodRed", 0.04),
        base.box("ToolCart_RimRight", (0, 30.7, 1.3), (3.1, 0.18, 0.75), "MAT_WoodRed", 0.04),
        base.cylinder("ToolCart_WheelLeft", (-1.0, 29.15, 0.65), 0.72, 0.22, "MAT_IronDark", 12),
        base.cylinder("ToolCart_WheelRight", (-1.0, 30.85, 0.65), 0.72, 0.22, "MAT_IronDark", 12),
        base.box("ToolCart_Handle", (2.0, 30, 0.85), (2.2, 0.18, 0.18), "MAT_WoodDark", 0.03),
        base.box("ToolCart_Hammer", (0.3, 30, 1.45), (1.5, 0.12, 0.12), "MAT_IronDark", 0.02, (0, 0, math.radians(18))),
    ]
    add_parented(root, objs)
    roots.append(root)

    root = base.parent_module("prop_crystal_shards", (10, 30, 0))
    objs = [base.box("CrystalShard_Contact", (10, 30, 0.10), (3.8, 2.8, 0.20), "MAT_ContactDark", 0.14)]
    for index, (x, y, radius, height) in enumerate([
        (9.1, 29.7, 0.35, 2.1),
        (10.0, 30.2, 0.48, 2.8),
        (10.8, 29.5, 0.28, 1.7),
        (10.7, 30.7, 0.23, 1.25),
    ]):
        crystal = base.cylinder(
            f"CrystalShard_{index}",
            (x, y, height / 2 + 0.15),
            radius,
            height,
            "MAT_CrystalPale" if index == 1 else "MAT_CrystalDeep",
            6,
        )
        crystal.rotation_euler[0] = math.radians((index - 1) * 8)
        objs.append(crystal)
    add_parented(root, objs)
    roots.append(root)

    root = base.parent_module("prop_mine_support", (20, 30, 0))
    objs = [
        base.box("MineSupport_Left", (18.7, 30, 1.65), (0.34, 0.50, 3.3), "MAT_WoodDark", 0.05),
        base.box("MineSupport_Right", (21.3, 30, 1.65), (0.34, 0.50, 3.3), "MAT_WoodDark", 0.05),
        base.box("MineSupport_Top", (20, 30, 3.15), (3.0, 0.50, 0.34), "MAT_WoodWeathered", 0.05),
        v0235.diagonal_beam("MineSupport_BraceLeft", (18.8, 30, 0.4), (19.8, 30, 3.0), 0.20, "MAT_WoodRed"),
        v0235.diagonal_beam("MineSupport_BraceRight", (20.2, 30, 3.0), (21.2, 30, 0.4), 0.20, "MAT_WoodRed"),
        base.cylinder("MineSupport_Pulley", (20, 29.65, 2.35), 0.45, 0.25, "MAT_IronDark", 12),
    ]
    add_parented(root, objs)
    roots.append(root)

    root = base.parent_module("prop_civic_banner", (30, 30, 0))
    objs = [
        base.box("CivicBanner_Base", (30, 30, 0.18), (1.8, 1.8, 0.36), "MAT_StoneWarm", 0.12),
        base.box("CivicBanner_Pole", (30, 30, 2.8), (0.16, 0.16, 5.3), "MAT_IronDark", 0.03),
        base.box("CivicBanner_Cloth", (30.65, 30, 3.55), (1.15, 0.10, 2.35), "MAT_BannerRed", 0.03),
        base.box("CivicBanner_Stripe", (30.65, 29.93, 3.55), (0.22, 0.07, 1.75), "MAT_BannerGold", 0.02),
        base.box("CivicBanner_Finial", (30, 30, 5.65), (0.38, 0.38, 0.38), "MAT_BannerGold", 0.05, (0, 0, math.radians(45))),
    ]
    add_parented(root, objs)
    roots.append(root)
    return roots


def export(output: Path, authored_detail_count: int) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    BLEND_PATH.parent.mkdir(parents=True, exist_ok=True)
    metadata_path = output.with_suffix(".export.json")
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
    resolved_output = output.resolve()
    try:
        metadata_glb_path = resolved_output.relative_to(Path.cwd().resolve()).as_posix()
    except ValueError:
        metadata_glb_path = resolved_output.as_posix()
    metadata = {
        "schemaVersion": 1,
        "checkpoint": CHECKPOINT,
        "status": "PASS_V0236_BLENDER_GLTF_EXPORT",
        "blendPath": BLEND_PATH.as_posix(),
        "glbPath": metadata_glb_path,
        "sourceGenerator": "tools/blender/generate_v0236_barrosan_production_slice.py",
        "sourceAssetRevision": "new v0.236 GLB; v0.235 and v0.233R assets retained unchanged",
        "modules": base.MODULES + ROLE_PROP_MODULES,
        "materials": list(PRODUCTION_PALETTE),
        "retunedExistingMaterialCount": len(v0235.BEAUTY_PALETTE),
        "newMaterialNames": NEW_MATERIAL_NAMES,
        "newMaterialCount": len(NEW_MATERIAL_NAMES),
        "newOrChangedMaterialCount": len(PRODUCTION_PALETTE),
        "changedBuildingModules": CHANGED_BUILDING_MODULES,
        "changedBuildingModuleCount": len(CHANGED_BUILDING_MODULES),
        "rolePropModules": ROLE_PROP_MODULES,
        "rolePropModuleCount": len(ROLE_PROP_MODULES),
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
    metadata_path.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()
    configure_scene()
    base.terrain_modules()
    base.road_modules()
    enhanced_river_bridge_modules()
    _, authored_detail_count = enhanced_landmark_modules()
    base.prop_modules()
    role_prop_modules()
    export(Path(args.output), authored_detail_count)


if __name__ == "__main__":
    main()
