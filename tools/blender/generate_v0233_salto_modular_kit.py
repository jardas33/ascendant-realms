"""Generate the v0.233 Salto modular fantasy RTS environment kit in Blender.

Run with:
  blender --background --factory-startup --python tools/blender/generate_v0233_salto_modular_kit.py -- \
    --output desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector


MODULES = [
    "terrain_base_tile", "terrain_grass_patch", "terrain_earth_patch",
    "road_straight", "road_intersection", "road_bridge_connector",
    "river_channel_banks", "bridge_module", "keep_landmark",
    "barracks_workshop_landmark", "mine_lume_landmark",
    "prop_rock_cluster", "prop_log_stack", "prop_crate_stack",
    "prop_posts", "prop_tree", "prop_rubble", "prop_barrels",
    "unit_scale_dummies",
]

PALETTE = {
    "MAT_Stone": (0.34, 0.31, 0.25, 1.0),
    "MAT_StoneDark": (0.16, 0.16, 0.14, 1.0),
    "MAT_RoadDirt": (0.43, 0.29, 0.16, 1.0),
    "MAT_Grass": (0.21, 0.29, 0.16, 1.0),
    "MAT_Earth": (0.34, 0.27, 0.17, 1.0),
    "MAT_Roof": (0.22, 0.12, 0.10, 1.0),
    "MAT_Wood": (0.24, 0.14, 0.08, 1.0),
    "MAT_Water": (0.05, 0.25, 0.31, 1.0),
    "MAT_Crystal": (0.05, 0.75, 0.67, 1.0),
    "MAT_ContactDark": (0.08, 0.07, 0.055, 1.0),
    "MAT_Plaster": (0.52, 0.43, 0.28, 1.0),
    "MAT_Metal": (0.25, 0.27, 0.25, 1.0),
}


def parse_args() -> argparse.Namespace:
    raw = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        default="desktop-spikes/godot-salto/assets/v0233/salto_modular_environment_kit.glb",
    )
    return parser.parse_args(raw)


def material(name: str) -> bpy.types.Material:
    found = bpy.data.materials.get(name)
    if found:
        return found
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = PALETTE[name]
    mat.use_nodes = True
    principled = mat.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = PALETTE[name]
    principled.inputs["Roughness"].default_value = 0.78
    if name == "MAT_Water":
        principled.inputs["Roughness"].default_value = 0.18
        principled.inputs["Metallic"].default_value = 0.12
    if name == "MAT_Crystal":
        principled.inputs["Emission Color"].default_value = PALETTE[name]
        principled.inputs["Emission Strength"].default_value = 3.0
        principled.inputs["Roughness"].default_value = 0.22
    return mat


def assign(obj: bpy.types.Object, mat_name: str) -> bpy.types.Object:
    obj.data.materials.append(material(mat_name))
    return obj


def bevel(obj: bpy.types.Object, width: float = 0.12, segments: int = 2) -> None:
    modifier = obj.modifiers.new("AuthoredChamfer", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    modifier.limit_method = "ANGLE"


def box(name: str, location, scale, mat_name: str, bevel_width: float = 0.1, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (scale[0] / 2, scale[1] / 2, scale[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, bevel_width)
    return assign(obj, mat_name)


def cylinder(name: str, location, radius: float, depth: float, mat_name: str, vertices: int = 10):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, min(0.1, radius * 0.15))
    return assign(obj, mat_name)


def parent_module(name: str, location) -> bpy.types.Object:
    root = bpy.data.objects.new(name, None)
    root.empty_display_type = "CUBE"
    root.location = location
    bpy.context.collection.objects.link(root)
    return root


def parent_children(root: bpy.types.Object, objects) -> None:
    for obj in objects:
        obj.parent = root


def pitched_roof(name: str, location, width: float, depth: float, height: float):
    pieces = []
    for side in (-1, 1):
        roof = box(
            f"{name}_{'L' if side < 0 else 'R'}",
            (location[0], location[1] + side * depth * 0.18, location[2]),
            (width, depth * 0.62, 0.34),
            "MAT_Roof",
            0.08,
            (side * math.radians(31), 0, 0),
        )
        pieces.append(roof)
    trim = box(f"{name}_RidgeTrim", (location[0], location[1], location[2] + height * 0.12), (width + 0.25, 0.22, 0.28), "MAT_Wood", 0.05)
    pieces.append(trim)
    return pieces


def terrain_modules():
    roots = []
    root = parent_module("MOD_terrain_base_tile", (-22, -14, 0))
    objs = [
        box("TerrainBase_Beveled", (-22, -14, -0.45), (12, 10, 0.9), "MAT_Earth", 0.3),
        box("TerrainBase_GrassCap", (-22, -14, 0.04), (11.4, 9.4, 0.16), "MAT_Grass", 0.12),
        box("TerrainBase_Contact", (-22, -14, -0.88), (12.3, 10.3, 0.08), "MAT_ContactDark", 0.02),
    ]
    parent_children(root, objs)
    roots.append(root)

    for label, x, mat_name, z in [("grass_patch", -9, "MAT_Grass", 0.08), ("earth_patch", 4, "MAT_Earth", 0.08)]:
        root = parent_module(f"MOD_terrain_{label}", (x, -14, 0))
        objs = [
            box(f"{label}_Base", (x, -14, -0.28), (11, 9, 0.58), "MAT_Earth", 0.28),
            box(f"{label}_Surface", (x, -14, z), (10.3, 8.3, 0.16), mat_name, 0.18),
        ]
        for i in range(5):
            objs.append(box(f"{label}_EdgeStone_{i:02d}", (x - 4 + i * 2, -18.0, 0.15), (0.8, 0.55, 0.45), "MAT_Stone", 0.12, (0, 0, math.radians(i * 9))))
        parent_children(root, objs)
        roots.append(root)
    return roots


def road_modules():
    roots = []
    layouts = [
        ("road_straight", 17, -14, False),
        ("road_intersection", 30, -14, True),
        ("road_bridge_connector", 43, -14, False),
    ]
    for label, x, y, intersection in layouts:
        root = parent_module(f"MOD_{label}", (x, y, 0))
        objs = [
            box(f"{label}_Terrain", (x, y, -0.35), (11, 9, 0.7), "MAT_Grass", 0.24),
            box(f"{label}_RoadBed", (x, y, 0.03), (10.3, 3.4, 0.22), "MAT_Earth", 0.25),
            box(f"{label}_Compacted", (x, y, 0.18), (10.0, 2.45, 0.16), "MAT_RoadDirt", 0.28),
        ]
        if intersection:
            objs += [
                box(f"{label}_CrossBed", (x, y, 0.04), (3.4, 8.3, 0.22), "MAT_Earth", 0.25),
                box(f"{label}_CrossCompacted", (x, y, 0.19), (2.45, 8.0, 0.16), "MAT_RoadDirt", 0.28),
            ]
        for side in (-1, 1):
            for i in range(5):
                objs.append(box(f"{label}_Edge_{side}_{i}", (x - 4 + i * 2, y + side * 1.8, 0.18), (1.15, 0.38, 0.28), "MAT_Earth", 0.1, (0, 0, math.radians((i - 2) * 4))))
        parent_children(root, objs)
        roots.append(root)
    return roots


def river_bridge_modules():
    roots = []
    root = parent_module("MOD_river_channel_banks", (-22, 0, 0))
    objs = [
        box("RiverTerrainLeft", (-26.3, 0, -0.32), (7.4, 11, 0.65), "MAT_Grass", 0.22),
        box("RiverTerrainRight", (-17.7, 0, -0.32), (7.4, 11, 0.65), "MAT_Grass", 0.22),
        box("RiverBed", (-22, 0, -0.68), (4.2, 11, 0.25), "MAT_StoneDark", 0.35),
        box("RiverWater", (-22, 0, -0.48), (3.65, 11, 0.16), "MAT_Water", 0.3),
        box("RiverBankLeft", (-24.25, 0, -0.03), (1.0, 11, 0.7), "MAT_Earth", 0.25),
        box("RiverBankRight", (-19.75, 0, -0.03), (1.0, 11, 0.7), "MAT_Earth", 0.25),
    ]
    parent_children(root, objs)
    roots.append(root)

    root = parent_module("MOD_bridge_module", (-7, 0, 0))
    objs = [
        box("Bridge_LeftBank", (-11.2, 0, -0.3), (3.6, 11, 0.65), "MAT_Grass", 0.22),
        box("Bridge_RightBank", (-2.8, 0, -0.3), (3.6, 11, 0.65), "MAT_Grass", 0.22),
        box("Bridge_Water", (-7, 0, -0.48), (5.2, 11, 0.16), "MAT_Water", 0.3),
        box("Bridge_Deck", (-7, 0, 1.15), (9.2, 4.0, 0.48), "MAT_Wood", 0.12),
        box("Bridge_LeftPier", (-10.0, 0, 0.25), (1.35, 4.8, 2.4), "MAT_Stone", 0.16),
        box("Bridge_RightPier", (-4.0, 0, 0.25), (1.35, 4.8, 2.4), "MAT_Stone", 0.16),
    ]
    for i in range(8):
        objs.append(box(f"Bridge_Plank_{i:02d}", (-10.5 + i, 0, 1.47), (0.74, 4.15, 0.16), "MAT_RoadDirt", 0.05))
    for side in (-1, 1):
        objs.append(box(f"Bridge_Rail_{side}", (-7, side * 1.9, 2.15), (9.4, 0.16, 0.18), "MAT_Wood", 0.04))
        for i in range(6):
            objs.append(box(f"Bridge_Post_{side}_{i}", (-11 + i * 1.6, side * 1.9, 1.85), (0.2, 0.2, 1.45), "MAT_Wood", 0.04))
    parent_children(root, objs)
    roots.append(root)
    return roots


def landmark_modules():
    roots = []

    root = parent_module("MOD_keep_landmark", (10, 2, 0))
    objs = [
        box("Keep_Foundation", (10, 2, 0.35), (12, 9, 0.7), "MAT_StoneDark", 0.28),
        box("Keep_Hall", (10, 2, 3.2), (7.2, 5.7, 5.4), "MAT_Stone", 0.22),
        box("Keep_GateRecess", (10, -0.95, 2.4), (2.1, 0.42, 3.4), "MAT_ContactDark", 0.08),
        box("Keep_GateFrame", (10, -1.18, 4.05), (3.1, 0.5, 0.48), "MAT_Wood", 0.08),
    ]
    for dx, dy in [(-4.2, -3.2), (4.2, -3.2), (-4.2, 3.2), (4.2, 3.2)]:
        objs.append(cylinder(f"Keep_Tower_{dx}_{dy}", (10 + dx, 2 + dy, 3.6), 1.65, 7.2, "MAT_Stone", 10))
        objs.append(cylinder(f"Keep_TowerCrown_{dx}_{dy}", (10 + dx, 2 + dy, 7.25), 1.95, 0.65, "MAT_StoneDark", 10))
    objs += pitched_roof("Keep_Roof", (10, 2, 6.25), 8.5, 6.8, 2.2)
    for i in range(5):
        objs.append(box(f"Keep_Battlement_{i}", (6.8 + i * 1.6, -1.05, 6.35), (0.85, 0.65, 0.7), "MAT_Stone", 0.08))
    parent_children(root, objs)
    roots.append(root)

    root = parent_module("MOD_barracks_workshop_landmark", (29, 2, 0))
    objs = [
        box("Barracks_Foundation", (29, 2, 0.3), (13, 9, 0.6), "MAT_StoneDark", 0.24),
        box("Barracks_Wall", (27.5, 2, 2.65), (9.3, 6.0, 4.3), "MAT_Plaster", 0.18),
        box("Barracks_Door", (27.5, -1.08, 1.85), (1.8, 0.3, 2.8), "MAT_ContactDark", 0.05),
        box("Workshop_Wall", (34.2, 2.7, 1.8), (4.2, 4.3, 2.9), "MAT_Earth", 0.16),
        box("Workshop_Chimney", (35.2, 3.3, 4.4), (0.9, 0.9, 4.0), "MAT_StoneDark", 0.14),
    ]
    objs += pitched_roof("Barracks_Roof", (27.5, 2, 5.0), 10.4, 7.2, 2.2)
    objs += pitched_roof("Workshop_Roof", (34.2, 2.7, 3.45), 4.9, 5.1, 1.5)
    for x in (23.4, 27.5, 31.6):
        objs.append(box(f"Barracks_Timber_{x}", (x, -1.12, 2.7), (0.32, 0.28, 4.6), "MAT_Wood", 0.05))
    parent_children(root, objs)
    roots.append(root)

    root = parent_module("MOD_mine_lume_landmark", (47, 2, 0))
    objs = [
        box("Mine_Foundation", (47, 2, 0.15), (13, 9, 0.5), "MAT_StoneDark", 0.25),
        box("Mine_RockMass", (47, 3.0, 2.0), (11.5, 6.0, 4.0), "MAT_Stone", 0.55),
        box("Mine_Portal", (47, -0.15, 2.0), (4.2, 0.8, 4.0), "MAT_ContactDark", 0.12),
        box("Mine_Header", (47, -0.65, 4.2), (5.2, 0.75, 0.55), "MAT_Wood", 0.08),
        box("Mine_PostL", (44.9, -0.65, 2.25), (0.55, 0.75, 4.4), "MAT_Wood", 0.08),
        box("Mine_PostR", (49.1, -0.65, 2.25), (0.55, 0.75, 4.4), "MAT_Wood", 0.08),
        cylinder("Lume_Well", (52.0, 0.0, 0.85), 1.45, 1.6, "MAT_StoneDark", 12),
        cylinder("Lume_Crystal", (52.0, 0.0, 3.0), 0.7, 3.8, "MAT_Crystal", 6),
    ]
    for i, offset in enumerate([(-4.7, 3.4), (-2.7, 4.3), (2.8, 4.0), (4.7, 3.0)]):
        objs.append(box(f"Mine_Rubble_{i}", (47 + offset[0], 2 + offset[1], 0.65), (1.4, 1.1, 1.0), "MAT_Stone", 0.25, (0, 0, math.radians(i * 17))))
    parent_children(root, objs)
    roots.append(root)
    return roots


def prop_modules():
    roots = []
    specs = [
        ("prop_rock_cluster", -18, 15), ("prop_log_stack", -8, 15),
        ("prop_crate_stack", 2, 15), ("prop_posts", 12, 15),
        ("prop_tree", 22, 15), ("prop_rubble", 32, 15),
        ("prop_barrels", 42, 15), ("unit_scale_dummies", 52, 15),
    ]
    for label, x, y in specs:
        root = parent_module(f"MOD_{label}", (x, y, 0))
        objs = [box(f"{label}_Plinth", (x, y, -0.16), (8, 8, 0.32), "MAT_Grass", 0.2)]
        if label == "prop_rock_cluster":
            for i, loc in enumerate([(-1.4, 0), (0, 0.8), (1.2, -0.5), (0.5, -1.4)]):
                objs.append(box(f"Rock_{i}", (x + loc[0], y + loc[1], 0.55), (1.5, 1.2, 1.1), "MAT_Stone", 0.28, (0, 0, i * 0.31)))
        elif label == "prop_log_stack":
            for row in range(2):
                for i in range(3):
                    obj = cylinder(f"Log_{row}_{i}", (x - 1.6 + i * 1.6, y, 0.55 + row * 0.65), 0.32, 3.2, "MAT_Wood", 10)
                    obj.rotation_euler[1] = math.radians(90)
                    objs.append(obj)
        elif label == "prop_crate_stack":
            objs += [
                box("Crate_A", (x - 0.8, y, 0.7), (1.4, 1.4, 1.4), "MAT_Wood", 0.1),
                box("Crate_B", (x + 0.8, y, 0.7), (1.4, 1.4, 1.4), "MAT_Wood", 0.1),
                box("Crate_C", (x, y, 2.05), (1.4, 1.4, 1.4), "MAT_Wood", 0.1),
            ]
        elif label == "prop_posts":
            for i in range(5):
                objs.append(box(f"Post_{i}", (x - 2 + i, y, 1.1 + (i % 2) * 0.25), (0.26, 0.26, 2.2 + (i % 2) * 0.5), "MAT_Wood", 0.05))
        elif label == "prop_tree":
            objs += [
                cylinder("Tree_Trunk", (x, y, 1.5), 0.38, 3.0, "MAT_Wood", 9),
                cylinder("Tree_CrownLow", (x, y, 4.0), 1.55, 3.4, "MAT_Grass", 8),
                cylinder("Tree_CrownHigh", (x, y, 6.2), 1.0, 2.6, "MAT_Grass", 8),
            ]
        elif label == "prop_rubble":
            for i in range(8):
                angle = i * math.tau / 8
                objs.append(box(f"Rubble_{i}", (x + math.cos(angle) * 1.8, y + math.sin(angle) * 1.2, 0.4), (0.9, 0.7, 0.65), "MAT_Stone", 0.2, (0, 0, angle)))
        elif label == "prop_barrels":
            for i in range(4):
                objs.append(cylinder(f"Barrel_{i}", (x - 1.5 + i, y, 0.75), 0.48, 1.5, "MAT_Wood", 12))
        else:
            for i in range(5):
                objs += [
                    cylinder(f"Dummy_Body_{i}", (x - 2 + i, y, 1.1), 0.28, 1.5, "MAT_Metal", 8),
                    cylinder(f"Dummy_Head_{i}", (x - 2 + i, y, 2.05), 0.24, 0.45, "MAT_Plaster", 10),
                ]
        parent_children(root, objs)
        roots.append(root)
    return roots


def configure_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.unit_settings.system = "METRIC"
    scene.unit_settings.scale_length = 1.0
    scene.world.color = (0.025, 0.035, 0.03)
    for name in PALETTE:
        material(name)


def export(output: Path):
    output.parent.mkdir(parents=True, exist_ok=True)
    blend_path = output.with_suffix(".blend")
    metadata_path = output.with_suffix(".export.json")
    bpy.ops.wm.save_as_mainfile(filepath=str(blend_path.resolve()))
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
        "checkpoint": "v0.233",
        "status": "PASS_BLENDER_GLTF_EXPORT",
        "blendPath": str(blend_path.as_posix()),
        "glbPath": str(output.as_posix()),
        "modules": MODULES,
        "materials": list(PALETTE),
        "authoredBy": "checked-in Blender Python source",
        "downloadedAssets": 0,
        "generatedAiImages": 0,
    }
    metadata_path.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")


def main():
    args = parse_args()
    configure_scene()
    terrain_modules()
    road_modules()
    river_bridge_modules()
    landmark_modules()
    prop_modules()
    export(Path(args.output))


if __name__ == "__main__":
    main()
