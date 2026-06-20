"""Author the v0.235 Human/Barrosan architecture correction and beauty pass."""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import bpy

sys.path.insert(0, str(Path(__file__).resolve().parent))
import generate_v0233_salto_modular_kit as base


CHECKPOINT = "v0.235"
BLEND_PATH = Path("art-source/blender/v0235/salto_barrosan_architecture_kit.blend")
DEFAULT_OUTPUT = Path("desktop-spikes/godot-salto/assets/v0235/salto_barrosan_architecture_kit.glb")
CORRECTED_BUILDING_MODULES = [
    "keep_landmark",
    "barracks_workshop_landmark",
    "mine_lume_landmark",
]
CORRECTED_PITCHED_ROOFS = [
    "Keep_Roof",
    "Barracks_Roof",
    "Workshop_Roof",
    "Mine_Roof",
]
CORRECTED_TOWER_CAPS = 4


BEAUTY_PALETTE = {
    "MAT_Stone": (0.40, 0.38, 0.32, 1.0),
    "MAT_StoneLight": (0.53, 0.50, 0.42, 1.0),
    "MAT_StoneWarm": (0.44, 0.35, 0.25, 1.0),
    "MAT_StoneDark": (0.15, 0.16, 0.15, 1.0),
    "MAT_RoadDirt": (0.34, 0.25, 0.16, 1.0),
    "MAT_Grass": (0.22, 0.31, 0.17, 1.0),
    "MAT_Earth": (0.30, 0.23, 0.15, 1.0),
    "MAT_Roof": (0.30, 0.13, 0.08, 1.0),
    "MAT_RoofClay": (0.46, 0.20, 0.11, 1.0),
    "MAT_RoofDark": (0.19, 0.10, 0.075, 1.0),
    "MAT_Wood": (0.27, 0.15, 0.08, 1.0),
    "MAT_WoodLight": (0.39, 0.23, 0.12, 1.0),
    "MAT_WoodDark": (0.13, 0.075, 0.045, 1.0),
    "MAT_EaveDark": (0.09, 0.055, 0.038, 1.0),
    "MAT_Water": (0.05, 0.25, 0.31, 1.0),
    "MAT_Crystal": (0.05, 0.75, 0.67, 1.0),
    "MAT_ContactDark": (0.065, 0.055, 0.042, 1.0),
    "MAT_Plaster": (0.66, 0.57, 0.40, 1.0),
    "MAT_PlasterLight": (0.78, 0.70, 0.52, 1.0),
    "MAT_PlasterWarm": (0.60, 0.46, 0.29, 1.0),
    "MAT_Metal": (0.25, 0.27, 0.25, 1.0),
}


def parse_args() -> argparse.Namespace:
    raw = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    return parser.parse_args(raw)


def configure_scene() -> None:
    base.PALETTE.clear()
    base.PALETTE.update(BEAUTY_PALETTE)
    base.configure_scene()


def mesh_object(name: str, vertices, faces, mat_name: str) -> bpy.types.Object:
    mesh = bpy.data.meshes.new(f"{name}_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    base.assign(obj, mat_name)
    base.bevel(obj, 0.06, 2)
    return obj


def roof_half(
    name: str,
    center_x: float,
    center_y: float,
    width: float,
    half_depth: float,
    eave_z: float,
    ridge_z: float,
    side: int,
    mat_name: str,
) -> bpy.types.Object:
    x0, x1 = center_x - width / 2, center_x + width / 2
    ridge_y = center_y
    eave_y = center_y + side * half_depth
    thickness = 0.22
    vertices = [
        (x0, ridge_y, ridge_z),
        (x1, ridge_y, ridge_z),
        (x1, eave_y, eave_z),
        (x0, eave_y, eave_z),
        (x0, ridge_y, ridge_z - thickness),
        (x1, ridge_y, ridge_z - thickness),
        (x1, eave_y, eave_z - thickness),
        (x0, eave_y, eave_z - thickness),
    ]
    faces = [
        (0, 1, 2, 3),
        (7, 6, 5, 4),
        (0, 4, 5, 1),
        (1, 5, 6, 2),
        (2, 6, 7, 3),
        (3, 7, 4, 0),
    ]
    return mesh_object(name, vertices, faces, mat_name)


def pitched_roof(
    name: str,
    center,
    width: float,
    depth: float,
    eave_z: float,
    rise: float,
    mat_name: str = "MAT_RoofClay",
):
    center_x, center_y = center
    overhang_x = 0.42
    overhang_y = 0.48
    roof_width = width + overhang_x * 2
    roof_depth = depth + overhang_y * 2
    half_depth = roof_depth / 2
    ridge_z = eave_z + rise
    pieces = [
        roof_half(f"{name}_Plane_North", center_x, center_y, roof_width, half_depth, eave_z, ridge_z, -1, mat_name),
        roof_half(f"{name}_Plane_South", center_x, center_y, roof_width, half_depth, eave_z, ridge_z, 1, mat_name),
        base.box(f"{name}_RidgeCap", (center_x, center_y, ridge_z + 0.05), (roof_width + 0.22, 0.34, 0.34), "MAT_RoofDark", 0.06),
    ]
    for side in (-1, 1):
        pieces.append(base.box(
            f"{name}_EaveFascia_{side}",
            (center_x, center_y + side * half_depth, eave_z - 0.05),
            (roof_width + 0.16, 0.22, 0.34),
            "MAT_EaveDark",
            0.04,
        ))
    slope_length = math.sqrt(half_depth * half_depth + rise * rise)
    slope_angle = math.atan2(rise, half_depth)
    for x_side in (-1, 1):
        x = center_x + x_side * roof_width / 2
        for y_side in (-1, 1):
            pieces.append(base.box(
                f"{name}_GableFascia_{x_side}_{y_side}",
                (x, center_y + y_side * half_depth / 2, eave_z + rise / 2),
                (0.20, slope_length, 0.24),
                "MAT_WoodDark",
                0.035,
                (-y_side * slope_angle, 0, 0),
            ))
    return pieces


def diagonal_beam(name: str, start, end, thickness: float = 0.22, mat_name: str = "MAT_WoodDark"):
    sx, sy, sz = start
    ex, ey, ez = end
    dx, dz = ex - sx, ez - sz
    length = math.sqrt(dx * dx + dz * dz)
    angle = math.atan2(dz, dx)
    return base.box(
        name,
        ((sx + ex) / 2, (sy + ey) / 2, (sz + ez) / 2),
        (length, thickness, thickness),
        mat_name,
        0.04,
        (0, -angle, 0),
    )


def tower_cap(name: str, location, radius: float = 2.0):
    x, y, z = location
    pieces = [base.cylinder(f"{name}_EaveRing", (x, y, z), radius, 0.28, "MAT_EaveDark", 12)]
    bpy.ops.mesh.primitive_cone_add(
        vertices=12,
        radius1=radius * 1.04,
        radius2=0.22,
        depth=1.9,
        location=(x, y, z + 1.0),
    )
    cap = bpy.context.object
    cap.name = f"{name}_HippedCap"
    base.bevel(cap, 0.08, 2)
    base.assign(cap, "MAT_RoofDark")
    pieces.append(cap)
    return pieces


def river_bridge_modules():
    roots = base.river_bridge_modules()
    bridge_root = next(root for root in roots if root.name == "bridge_module")
    additions = [
        base.box("Bridge_StoneAbutmentWest", (-11.0, 0, 0.15), (1.2, 5.4, 2.0), "MAT_StoneWarm", 0.16),
        base.box("Bridge_StoneAbutmentEast", (-3.0, 0, 0.15), (1.2, 5.4, 2.0), "MAT_StoneWarm", 0.16),
    ]
    for side in (-1, 1):
        additions.append(diagonal_beam(
            f"Bridge_Brace_{side}_A",
            (-10.2, side * 2.0, 0.45),
            (-7.7, side * 2.0, 1.6),
            0.20,
            "MAT_WoodDark",
        ))
        additions.append(diagonal_beam(
            f"Bridge_Brace_{side}_B",
            (-6.3, side * 2.0, 1.6),
            (-3.8, side * 2.0, 0.45),
            0.20,
            "MAT_WoodDark",
        ))
    base.parent_children(bridge_root, additions)
    return roots


def landmark_modules():
    roots = []

    root = base.parent_module("keep_landmark", (10, 2, 0))
    objs = [
        base.box("Keep_ContactSkirt", (10, 2, -0.08), (12.8, 9.8, 0.30), "MAT_ContactDark", 0.16),
        base.box("Keep_FoundationLower", (10, 2, 0.25), (12.4, 9.4, 0.70), "MAT_StoneDark", 0.24),
        base.box("Keep_FoundationUpper", (10, 2, 0.72), (11.4, 8.4, 0.34), "MAT_StoneWarm", 0.16),
        base.box("Keep_Hall", (10, 2, 3.35), (7.4, 5.8, 5.2), "MAT_StoneLight", 0.24),
        base.box("Keep_GateRecess", (10, -0.96, 2.45), (2.2, 0.45, 3.4), "MAT_ContactDark", 0.08),
        base.box("Keep_GateHeader", (10, -1.24, 4.2), (3.2, 0.48, 0.48), "MAT_WoodDark", 0.08),
        base.box("Keep_WallTrim", (10, -1.20, 5.15), (7.9, 0.30, 0.28), "MAT_StoneWarm", 0.05),
    ]
    for x in (7.1, 10.0, 12.9):
        objs.append(base.box(f"Keep_TimberPier_{x}", (x, -1.18, 3.45), (0.30, 0.30, 3.5), "MAT_WoodDark", 0.04))
    for dx, dy in [(-4.2, -3.2), (4.2, -3.2), (-4.2, 3.2), (4.2, 3.2)]:
        objs.append(base.cylinder(f"Keep_Tower_{dx}_{dy}", (10 + dx, 2 + dy, 3.7), 1.68, 7.4, "MAT_Stone", 12))
        objs.append(base.cylinder(f"Keep_TowerBand_{dx}_{dy}", (10 + dx, 2 + dy, 5.7), 1.78, 0.30, "MAT_StoneWarm", 12))
        objs += tower_cap(f"Keep_TowerCap_{dx}_{dy}", (10 + dx, 2 + dy, 7.35), 1.95)
    objs += pitched_roof("Keep_Roof", (10, 2), 7.4, 5.8, 6.05, 2.25, "MAT_RoofDark")
    base.parent_children(root, objs)
    roots.append(root)

    root = base.parent_module("barracks_workshop_landmark", (29, 2, 0))
    objs = [
        base.box("Barracks_ContactSkirt", (29, 2, -0.10), (13.8, 9.8, 0.28), "MAT_ContactDark", 0.16),
        base.box("Barracks_Foundation", (29, 2, 0.28), (13.3, 9.2, 0.72), "MAT_StoneDark", 0.22),
        base.box("Barracks_FoundationCourse", (27.5, 2, 0.78), (9.8, 6.5, 0.34), "MAT_StoneWarm", 0.13),
        base.box("Barracks_Wall", (27.5, 2, 2.9), (9.4, 6.0, 4.2), "MAT_PlasterLight", 0.18),
        base.box("Barracks_Door", (27.5, -1.10, 2.05), (1.85, 0.34, 2.8), "MAT_ContactDark", 0.05),
        base.box("Barracks_DoorHeader", (27.5, -1.28, 3.55), (2.6, 0.35, 0.35), "MAT_WoodDark", 0.05),
        base.box("Workshop_FoundationCourse", (34.2, 2.7, 0.62), (4.7, 4.8, 0.42), "MAT_StoneWarm", 0.14),
        base.box("Workshop_Wall", (34.2, 2.7, 2.1), (4.25, 4.3, 2.9), "MAT_PlasterWarm", 0.16),
        base.box("Workshop_Chimney", (35.2, 3.3, 4.65), (0.95, 0.95, 4.2), "MAT_StoneDark", 0.14),
        base.box("Workshop_ChimneyCap", (35.2, 3.3, 6.78), (1.2, 1.2, 0.24), "MAT_StoneWarm", 0.06),
        base.box("Barracks_Awning", (23.7, -1.7, 2.15), (2.8, 2.0, 0.22), "MAT_RoofDark", 0.06, (math.radians(-12), 0, 0)),
    ]
    objs += pitched_roof("Barracks_Roof", (27.5, 2), 9.4, 6.0, 5.15, 2.25, "MAT_RoofClay")
    objs += pitched_roof("Workshop_Roof", (34.2, 2.7), 4.25, 4.3, 3.62, 1.55, "MAT_RoofDark")
    for x in (23.35, 27.5, 31.65):
        objs.append(base.box(f"Barracks_TimberPier_{x}", (x, -1.15, 3.0), (0.32, 0.30, 4.5), "MAT_WoodDark", 0.05))
    objs += [
        base.box("Barracks_TimberRailLow", (27.5, -1.17, 1.55), (9.3, 0.28, 0.26), "MAT_Wood", 0.04),
        base.box("Barracks_TimberRailHigh", (27.5, -1.17, 4.35), (9.3, 0.28, 0.26), "MAT_Wood", 0.04),
        diagonal_beam("Barracks_Brace_Left", (23.5, -1.19, 1.4), (26.0, -1.19, 4.25)),
        diagonal_beam("Barracks_Brace_Right", (29.0, -1.19, 4.25), (31.5, -1.19, 1.4)),
        base.box("Workshop_WorkBench", (34.0, -0.05, 1.15), (3.3, 1.1, 0.55), "MAT_WoodLight", 0.08),
        base.box("Workshop_LogRack", (32.7, 5.1, 1.0), (3.5, 0.7, 1.7), "MAT_WoodDark", 0.08),
    ]
    base.parent_children(root, objs)
    roots.append(root)

    root = base.parent_module("mine_lume_landmark", (47, 2, 0))
    objs = [
        base.box("Mine_ContactSkirt", (47, 2, -0.10), (13.8, 9.8, 0.28), "MAT_ContactDark", 0.16),
        base.box("Mine_Foundation", (47, 2, 0.25), (13.2, 9.2, 0.68), "MAT_StoneDark", 0.23),
        base.box("Mine_FoundationCourse", (47, 2, 0.72), (11.8, 8.0, 0.34), "MAT_StoneWarm", 0.14),
        base.box("Mine_Hall", (47, 2.4, 2.65), (8.0, 5.4, 3.8), "MAT_PlasterWarm", 0.20),
        base.box("Mine_Portal", (47, -0.45, 2.05), (4.2, 0.70, 3.8), "MAT_ContactDark", 0.10),
        base.box("Mine_Header", (47, -0.90, 4.1), (5.2, 0.72, 0.55), "MAT_WoodDark", 0.08),
        base.box("Mine_PostL", (44.9, -0.88, 2.2), (0.55, 0.72, 4.2), "MAT_WoodDark", 0.08),
        base.box("Mine_PostR", (49.1, -0.88, 2.2), (0.55, 0.72, 4.2), "MAT_WoodDark", 0.08),
        base.cylinder("Lume_Well", (52.0, 0.0, 0.88), 1.45, 1.65, "MAT_StoneDark", 12),
        base.cylinder("Lume_WellBand", (52.0, 0.0, 1.55), 1.58, 0.25, "MAT_StoneWarm", 12),
        base.cylinder("Lume_Crystal", (52.0, 0.0, 3.0), 0.70, 3.8, "MAT_Crystal", 6),
        base.box("Extraction_Frame_Left", (51.0, 3.0, 2.4), (0.35, 0.45, 4.4), "MAT_WoodDark", 0.05),
        base.box("Extraction_Frame_Right", (54.0, 3.0, 2.4), (0.35, 0.45, 4.4), "MAT_WoodDark", 0.05),
        base.box("Extraction_Frame_Top", (52.5, 3.0, 4.55), (3.4, 0.45, 0.35), "MAT_WoodDark", 0.05),
        base.cylinder("Extraction_Pulley", (52.5, 2.72, 3.65), 0.55, 0.28, "MAT_Metal", 12),
    ]
    objs += pitched_roof("Mine_Roof", (47, 2.4), 8.0, 5.4, 4.60, 1.75, "MAT_RoofDark")
    for x in (43.35, 47.0, 50.65):
        objs.append(base.box(f"Mine_TimberPier_{x}", (x, -0.35, 2.8), (0.30, 0.30, 3.4), "MAT_WoodDark", 0.05))
    for i, offset in enumerate([(-4.8, 3.4), (-3.0, 4.1), (2.8, 4.0), (4.7, 3.1), (5.0, -2.5)]):
        objs.append(base.box(
            f"Mine_Rubble_{i}",
            (47 + offset[0], 2 + offset[1], 0.65),
            (1.4, 1.1, 1.0),
            "MAT_Stone",
            0.25,
            (0, 0, math.radians(i * 17)),
        ))
    base.parent_children(root, objs)
    roots.append(root)
    return roots


def export(output: Path) -> None:
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
        "status": "PASS_V0235_BLENDER_GLTF_EXPORT",
        "blendPath": BLEND_PATH.as_posix(),
        "glbPath": metadata_glb_path,
        "sourceGenerator": "tools/blender/generate_v0235_salto_barrosan_architecture.py",
        "sourceAssetRevision": "new v0.235 GLB; v0.233R/v0.234 GLB retained unchanged",
        "modules": base.MODULES,
        "materials": list(BEAUTY_PALETTE),
        "correctedBuildingModules": CORRECTED_BUILDING_MODULES,
        "correctedBuildingModuleCount": len(CORRECTED_BUILDING_MODULES),
        "correctedPitchedRoofAssemblies": CORRECTED_PITCHED_ROOFS,
        "correctedPitchedRoofAssemblyCount": len(CORRECTED_PITCHED_ROOFS),
        "correctedTowerCapCount": CORRECTED_TOWER_CAPS,
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
    river_bridge_modules()
    landmark_modules()
    base.prop_modules()
    export(Path(args.output))


if __name__ == "__main__":
    main()
