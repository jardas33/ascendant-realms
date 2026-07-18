"""Author the isolated v0.339 Barrosan hamlet secondary asset family."""
from __future__ import annotations

import bpy
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT_BLEND = ROOT / "art-source/blender/v0339/barrosan_hamlet_vertical_slice_assets.blend"
OUT_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0339/barrosan_hamlet_vertical_slice_assets.glb"


def mat(name: str, color: tuple[float, float, float, float], roughness: float = 0.88, metallic: float = 0.0):
    material = bpy.data.materials.new(name)
    material.diffuse_color = color
    material.use_nodes = True
    principled = material.node_tree.nodes.get("Principled BSDF")
    principled.inputs["Base Color"].default_value = color
    principled.inputs["Roughness"].default_value = roughness
    principled.inputs["Metallic"].default_value = metallic
    return material


STONE = mat("V0339_Weathered_Granite", (0.34, 0.37, 0.35, 1.0), 0.96)
STONE_LIGHT = mat("V0339_Sunlit_Granite", (0.48, 0.49, 0.43, 1.0), 0.93)
TIMBER = mat("V0339_Weathered_Timber", (0.25, 0.14, 0.085, 1.0), 0.91)
TIMBER_LIGHT = mat("V0339_Cut_Timber", (0.40, 0.24, 0.13, 1.0), 0.87)
SLATE = mat("V0339_Slate_Roof", (0.16, 0.19, 0.18, 1.0), 0.92)
EARTH = mat("V0339_Dry_Earth", (0.40, 0.28, 0.18, 1.0), 0.98)
WATER = mat("V0339_Trough_Water", (0.12, 0.29, 0.29, 1.0), 0.20)
IRON = mat("V0339_Dark_Iron", (0.12, 0.13, 0.12, 1.0), 0.65, 0.15)


def cube(name: str, location: tuple[float, float, float], scale: tuple[float, float, float], material, bevel: float = 0.0):
    bpy.ops.mesh.primitive_cube_add(location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (scale[0] / 2, scale[1] / 2, scale[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if material:
        obj.data.materials.append(material)
    if bevel > 0:
        modifier = obj.modifiers.new("soft_authored_edges", "BEVEL")
        modifier.width = bevel
        modifier.segments = 2
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=modifier.name)
    return obj


def roof(name: str, location: tuple[float, float, float], angle: float, material=SLATE, width: float = 2.5, length: float = 4.2):
    obj = cube(name, location, (width, length, 0.22), material, 0.04)
    obj.rotation_euler[1] = math.radians(angle)
    obj["v0339_role"] = "roof_plane"
    return obj


def mark(obj, role: str):
    obj["v0339_authored_asset"] = True
    obj["v0339_role"] = role
    return obj


def barn():
    root = bpy.data.objects.new("V0339_Barrosan_Agricultural_Barn", None)
    bpy.context.collection.objects.link(root)
    root["v0339_role"] = "secondary_granite_agricultural_barn"
    parts = [
        cube("Barn_Granite_Foundation", (0, 0, 0.28), (5.4, 4.5, 0.55), STONE, 0.08),
        cube("Barn_Timber_Walls", (0, 0, 1.62), (5.0, 4.1, 2.35), TIMBER, 0.05),
        cube("Barn_Stone_Gable_Front", (0, -2.08, 1.9), (4.9, 0.22, 2.8), STONE_LIGHT, 0.04),
        cube("Barn_Door", (0, -2.22, 1.15), (1.55, 0.16, 1.70), TIMBER_LIGHT, 0.02),
        cube("Barn_Door_Lintel", (0, -2.28, 2.12), (1.9, 0.25, 0.28), STONE, 0.03),
        roof("Barn_Roof_Left", (-1.05, 0, 3.15), -28.0, SLATE, 2.6, 4.7),
        roof("Barn_Roof_Right", (1.05, 0, 3.15), 28.0, SLATE, 2.6, 4.7),
        cube("Barn_Ridge", (0, 0, 4.02), (0.25, 4.9, 0.25), TIMBER_LIGHT, 0.03),
    ]
    for part in parts:
        part.parent = root
        mark(part, "barn_structure")
    for x in (-1.8, 1.8):
        p = cube(f"Barn_Timber_Post_{x}", (x, -2.3, 1.55), (0.24, 0.22, 2.65), TIMBER_LIGHT, 0.02)
        p.parent = root
        mark(p, "barn_timber_frame")
    return root


def shed():
    root = bpy.data.objects.new("V0339_Barrosan_Timber_Stone_Shed", None)
    bpy.context.collection.objects.link(root)
    root["v0339_role"] = "timber_stone_shed_lean_to"
    parts = [
        cube("Shed_Stone_Base", (0, 0, 0.28), (3.3, 2.8, 0.55), STONE, 0.06),
        cube("Shed_Timber_Body", (0, 0, 1.25), (3.0, 2.5, 1.65), TIMBER, 0.05),
        cube("Shed_Stone_Corner", (-1.33, -1.3, 1.2), (0.30, 0.26, 2.0), STONE_LIGHT, 0.03),
        cube("Shed_Door", (0, -1.38, 0.95), (0.82, 0.13, 1.4), TIMBER_LIGHT, 0.02),
        roof("Shed_Roof", (0, 0, 2.30), 8.0, SLATE, 3.25, 2.95),
        cube("Shed_LeanTo", (2.1, 0.25, 0.9), (1.4, 2.1, 1.35), TIMBER, 0.04),
        roof("Shed_LeanTo_Roof", (2.1, 0.25, 1.72), -12.0, SLATE, 1.55, 2.3),
    ]
    for part in parts:
        part.parent = root
        mark(part, "shed_structure")
    return root


def wall_kit():
    root = bpy.data.objects.new("V0339_Dry_Stone_Wall_Kit", None)
    bpy.context.collection.objects.link(root)
    root["v0339_role"] = "dry_stone_wall_kit"
    specs = [
        ("Straight", (-6.0, 0.0, 0.68), (5.8, 0.62, 1.35)),
        ("Short", (-2.2, 2.6, 0.62), (2.2, 0.58, 1.22)),
        ("InternalCorner", (-4.0, 2.6, 0.62), (1.1, 1.1, 1.22)),
        ("ExternalCorner", (-0.3, 2.7, 0.62), (1.1, 1.1, 1.22)),
        ("EndCap", (2.0, 2.7, 0.58), (0.55, 0.72, 1.14)),
        ("GatewayLeft", (3.8, 2.7, 0.7), (0.55, 0.72, 1.4)),
        ("GatewayRight", (5.8, 2.7, 0.7), (0.55, 0.72, 1.4)),
    ]
    for label, pos, size in specs:
        p = cube(f"Wall_{label}", pos, size, STONE_LIGHT if label in ("InternalCorner", "GatewayLeft") else STONE, 0.08)
        p.parent = root
        mark(p, "wall_kit_" + label.lower())
    return root


def trough_and_props():
    root = bpy.data.objects.new("V0339_Trough_And_Hamlet_Props", None)
    bpy.context.collection.objects.link(root)
    trough = cube("Stone_Trough_Basin", (7.0, -1.5, 0.52), (2.8, 1.25, 0.65), STONE_LIGHT, 0.08)
    trough.parent = root
    mark(trough, "stone_trough_washing_structure")
    water = cube("Stone_Trough_Water", (7.0, -1.5, 0.86), (2.1, 0.72, 0.05), WATER, 0.01)
    water.parent = root
    mark(water, "water_surface")
    for index, x in enumerate((5.6, 6.15, 8.25)):
        prop = cube(f"Timber_Stack_{index}", (x, 0.3, 0.38), (1.1, 0.6, 0.55), TIMBER_LIGHT, 0.05)
        prop.parent = root
        mark(prop, "timber_prop")
    for index, (x, y) in enumerate(((5.0, -2.8), (8.7, -2.4), (9.1, -1.0))):
        bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=0.5, location=(x, y, 0.48))
        rock = bpy.context.object
        rock.name = f"Embedded_Granite_Rock_{index}"
        rock.scale = (1.2, 0.8, 0.7)
        rock.data.materials.append(STONE)
        rock.parent = root
        mark(rock, "embedded_granite_rock")
    return root


def main():
    # The wrapper already starts Blender with --factory-startup.  Do not reset
    # here after material creation: Blender invalidates the material RNA
    # handles when a second factory reset removes them.
    for builder in (barn, shed, wall_kit, trough_and_props):
        builder()
    scene = bpy.context.scene
    scene["v0339_checkpoint"] = "v0.339"
    scene["v0339_prototype_only"] = True
    scene["v0339_default_runtime_integrated"] = False
    scene["v0339_asset_provenance"] = "repository-authored Blender geometry; no third-party game assets"
    OUT_BLEND.parent.mkdir(parents=True, exist_ok=True)
    OUT_GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_apply=False, export_materials="EXPORT", export_lights=False, export_cameras=False, export_extras=True)
    print("PASS_V0339_BARROSAN_HAMLET_SECONDARY_ASSET_FAMILY")


if __name__ == "__main__":
    main()
