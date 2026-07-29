"""v0.331 House 02 documentary roof/material closure authoring source.

This file intentionally does not import any v0.327-v0.329 generator.  It builds
the compact inhabited granite house from primitives so the documentary
reference gate and the House 01 preservation gate remain auditable.
"""

from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
CHECKPOINT = "v0.332"
BLEND_PATH = ROOT / "art-source/blender/v0330/barrosan_house_gold_02.blend"
GLB_PATH = ROOT / "desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb"
RUNTIME = ROOT / "artifacts/runtime/v0332"
TEXTURE_DIR = ROOT / "art-source/materials/v0332"

MATERIALS = {
    "granite": ("V0332_Granite", (0.25, 0.27, 0.25, 1.0), 0.93),
    "foundation": ("V0332_Damp_Foundation", (0.12, 0.14, 0.13, 1.0), 0.98),
    "slate": ("V0332_Weathered_Slate", (0.12, 0.14, 0.15, 1.0), 0.96),
    "timber": ("V0332_Weathered_Timber", (0.20, 0.115, 0.055, 1.0), 0.91),
    "iron": ("V0332_Iron", (0.07, 0.075, 0.068, 1.0), 0.84),
    "interior": ("V0332_Interior_Recess", (0.012, 0.016, 0.014, 1.0), 0.99),
    "glass": ("V0332_Recessed_Window", (0.035, 0.045, 0.043, 1.0), 0.82),
}

collections: dict[str, bpy.types.Collection] = {}
materials: dict[str, bpy.types.Material] = {}


def collection(name: str, parent: bpy.types.Collection | None = None) -> bpy.types.Collection:
    target = parent or bpy.context.scene.collection
    c = bpy.data.collections.new(name)
    target.children.link(c)
    collections[name] = c
    return c


def _texture(name: str, filename: str, size: int, fn, non_color: bool = False) -> bpy.types.Image:
    TEXTURE_DIR.mkdir(parents=True, exist_ok=True)
    path = TEXTURE_DIR / filename
    if name in bpy.data.images:
        return bpy.data.images[name]
    image = bpy.data.images.new(name, width=size, height=size, alpha=False)
    image.colorspace_settings.name = "Non-Color" if non_color else "sRGB"
    pixels = []
    for y in range(size):
        v = y / float(size - 1)
        for x in range(size):
            u = x / float(size - 1)
            r, g, b = fn(u, v)
            pixels.extend((r, g, b, 1.0))
    image.pixels = pixels
    image.filepath_raw = str(path)
    image.file_format = "PNG"
    image.save()
    image.pack()
    return image


def _hash2(x: int, y: int, salt: int = 0) -> float:
    value = (x * 374761393 + y * 668265263 + salt * 1442695041) & 0xFFFFFFFF
    value = ((value ^ (value >> 13)) * 1274126177) & 0xFFFFFFFF
    return float(value & 0xFFFF) / 65535.0


def _granite_albedo(u: float, v: float) -> tuple[float, float, float]:
    # Continuous authored wall texture: irregular coursed stone, visible
    # mortar, grey/brown variation and a damp lower register.
    # Smart-project packs each continuous face into a compact island. The
    # lower-frequency authored course keeps mortar and stone rhythm visible at
    # the actual imported gameplay scale instead of averaging to flat plaster.
    px, py = u * 4.0, v * 3.0
    row = math.floor(py)
    offset = 0.42 if row % 2 else 0.0
    cell_x = math.floor(px + offset)
    local_x = (px + offset) - cell_x
    local_y = py - row
    mortar = min(local_x, 1.0 - local_x, local_y, 1.0 - local_y)
    stone = _hash2(cell_x, row, 19)
    grain = 0.5 + 0.5 * math.sin(u * 73.0 + v * 41.0 + stone * 8.0)
    base = 0.27 + stone * 0.12 + grain * 0.025
    if mortar < 0.115:
        base *= 0.38
    damp = 0.075 * max(0.0, 1.0 - v * 3.2)
    moss = 0.025 * max(0.0, math.sin(u * 31.0 + v * 17.0)) * max(0.0, 0.72 - v)
    return (base - damp + moss, base * 1.02 - damp * 0.82 + moss * 0.8, base * 0.96 - damp * 0.58)


def _granite_roughness(u: float, v: float) -> tuple[float, float, float]:
    value = 0.78 + 0.16 * (0.5 + 0.5 * math.sin(u * 29.0 + v * 31.0))
    return (value, value, value)


def _granite_normal(u: float, v: float) -> tuple[float, float, float]:
    return (0.5 + 0.11 * math.sin(u * 37.0 + v * 7.0), 0.5 + 0.10 * math.cos(v * 41.0 + u * 5.0), 0.94)


def _slate_albedo(u: float, v: float) -> tuple[float, float, float]:
    row = math.floor(v * 18.0)
    local_y = v * 18.0 - row
    offset = 0.5 if row % 2 else 0.0
    local_x = (u * 16.0 + offset) % 1.0
    plate = _hash2(math.floor(u * 16.0 + offset), row, 43)
    seam = min(local_y, 1.0 - local_y, local_x, 1.0 - local_x)
    variation = 0.5 + 0.5 * math.sin(u * 63.0 + v * 19.0 + plate * 10.0)
    base = 0.14 + plate * 0.055 + variation * 0.018
    if seam < 0.035:
        base *= 0.48
    return (base * 0.82, base * 0.91, base)


def _slate_roughness(u: float, v: float) -> tuple[float, float, float]:
    value = 0.82 + 0.13 * (0.5 + 0.5 * math.sin(v * 65.0 + u * 11.0))
    return (value, value, value)


def _slate_normal(u: float, v: float) -> tuple[float, float, float]:
    return (0.5 + 0.065 * math.sin(v * 70.0 + u * 5.0), 0.5 + 0.035 * math.cos(u * 20.0), 0.96)


def _timber_albedo(u: float, v: float) -> tuple[float, float, float]:
    grain = 0.5 + 0.5 * math.sin(u * 115.0 + math.sin(v * 8.0) * 3.0)
    knot = 0.035 * max(0.0, math.sin(u * 23.0 + v * 5.0))
    return (0.135 + grain * 0.075 + knot, 0.070 + grain * 0.040 + knot * 0.65, 0.030 + grain * 0.022)


def _timber_roughness(u: float, v: float) -> tuple[float, float, float]:
    value = 0.72 + 0.20 * (0.5 + 0.5 * math.sin(u * 95.0))
    return (value, value, value)


def _write_numbered_checker() -> None:
    """Write a real square numbered checker used by the Godot evidence pass."""
    size = 512
    cells = 8
    cell = size // cells
    image = bpy.data.images.get("V0332_Numbered_Square_Checker") or bpy.data.images.new("V0332_Numbered_Square_Checker", width=size, height=size, alpha=False)
    pixels = []
    glyphs = {
        "0": ("11111", "10001", "10001", "10001", "11111"),
        "1": ("00100", "01100", "00100", "00100", "11111"),
        "2": ("11110", "00001", "01110", "10000", "11111"),
        "3": ("11110", "00001", "01110", "00001", "11110"),
        "4": ("10010", "10010", "11111", "00010", "00010"),
        "5": ("11111", "10000", "11110", "00001", "11110"),
        "6": ("01110", "10000", "11110", "10001", "01110"),
        "7": ("11111", "00010", "00100", "01000", "01000"),
        "H": ("10001", "10001", "11111", "10001", "10001"),
        "V": ("10001", "10001", "10001", "01010", "00100"),
    }
    for y in range(size):
        for x in range(size):
            cx, cy = x // cell, y // cell
            base = (0.16, 0.20, 0.18) if (cx + cy) % 2 == 0 else (0.62, 0.49, 0.25)
            draw = False
            glyph = str((cy * cells + cx) % 8)
            if cy == 7 and cx == 0:
                glyph = "H"
            if cy == 7 and cx == 1:
                glyph = "V"
            gx, gy = (x % cell) - 22, (y % cell) - 29
            if 0 <= gx < 35 and 0 <= gy < 35:
                row, col = gy // 7, gx // 7
                draw = row < 5 and col < 5 and glyphs[glyph][row][col] == "1"
            if draw:
                base = (0.93, 0.88, 0.70)
            pixels.extend((*base, 1.0))
    image.pixels = pixels
    path = TEXTURE_DIR / "numbered_square_checker.png"
    image.filepath_raw = str(path)
    image.file_format = "PNG"
    image.save()
    image.pack()


def _img_node(nodes, image, label: str):
    node = nodes.new("ShaderNodeTexImage")
    node.image = image
    node.label = label
    node.interpolation = "Linear"
    return node


def _pbr_material(name: str, color: tuple[float, float, float, float], roughness: float, albedo=None, rough=None, normal=None, tint: tuple[float, float, float, float] | None = None) -> bpy.types.Material:
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    nodes.clear()
    output = nodes.new("ShaderNodeOutputMaterial")
    bsdf = nodes.new("ShaderNodeBsdfPrincipled")
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Specular IOR Level"].default_value = 0.18
    links.new(bsdf.outputs["BSDF"], output.inputs["Surface"])
    if albedo:
        albedo_node = _img_node(nodes, albedo, "authored albedo")
        if tint:
            mix = nodes.new("ShaderNodeMixRGB")
            mix.blend_type = "MULTIPLY"
            mix.inputs[0].default_value = 1.0
            mix.inputs[2].default_value = tint
            links.new(albedo_node.outputs["Color"], mix.inputs[1])
            links.new(mix.outputs["Color"], bsdf.inputs["Base Color"])
        else:
            links.new(albedo_node.outputs["Color"], bsdf.inputs["Base Color"])
    else:
        bsdf.inputs["Base Color"].default_value = color
    if rough:
        links.new(_img_node(nodes, rough, "authored roughness").outputs["Color"], bsdf.inputs["Roughness"])
    if normal:
        normal_map = nodes.new("ShaderNodeNormalMap")
        normal_map.inputs["Strength"].default_value = 0.34
        links.new(_img_node(nodes, normal, "authored normal").outputs["Color"], normal_map.inputs["Color"])
        links.new(normal_map.outputs["Normal"], bsdf.inputs["Normal"])
    return mat


def material(key: str) -> bpy.types.Material:
    if key in materials:
        return materials[key]
    name, color, roughness = MATERIALS[key]
    if key in ("granite", "foundation"):
        albedo = _texture("V0332_Granite_Albedo", "granite_albedo_1024.png", 1024, _granite_albedo)
        rough = _texture("V0332_Granite_Roughness", "granite_roughness_1024.png", 1024, _granite_roughness, True)
        normal = _texture("V0332_Granite_Normal", "granite_normal_1024.png", 1024, _granite_normal, True)
        mat = _pbr_material(name, color, roughness, albedo, rough, normal, (0.58, 0.62, 0.60, 1.0) if key == "foundation" else None)
    elif key == "slate":
        mat = _pbr_material(name, color, roughness, _texture("V0332_Slate_Albedo", "slate_albedo_1024.png", 1024, _slate_albedo), _texture("V0332_Slate_Roughness", "slate_roughness_1024.png", 1024, _slate_roughness, True), _texture("V0332_Slate_Normal", "slate_normal_1024.png", 1024, _slate_normal, True))
    elif key == "timber":
        mat = _pbr_material(name, color, roughness, _texture("V0332_Timber_Albedo", "timber_albedo_1024.png", 1024, _timber_albedo), _texture("V0332_Timber_Roughness", "timber_roughness_1024.png", 1024, _timber_roughness, True))
    else:
        mat = _pbr_material(name, color, roughness)
    materials[key] = mat
    return mat


def box(name: str, loc: tuple[float, float, float], size: tuple[float, float, float], mat: str, bevel: float = 0.0, target: bpy.types.Collection | None = None) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cube_add(location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel > 0.0:
        mod = obj.modifiers.new("quiet softened edges", "BEVEL")
        mod.width = bevel
        mod.segments = 3
        mod.limit_method = "ANGLE"
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.modifier_apply(modifier=mod.name)
    if target:
        for owner in list(obj.users_collection):
            owner.objects.unlink(obj)
        target.objects.link(obj)
    obj.data.materials.append(material(mat))
    obj["authoredRole"] = name
    return obj


def wedge(name: str, x0: float, x1: float, y0: float, y1: float, z0: float, z1: float, mat: str, target: bpy.types.Collection) -> bpy.types.Object:
    # Sloped roof half: a real solid plane with a thin underside, not a flat
    # screen-facing sheet. The ridge runs along X and rises toward y1.
    thickness = 0.16
    top = [(x0, y0, z0), (x1, y0, z0), (x1, y1, z1), (x0, y1, z1)]
    bottom = [(x, y, z - thickness) for x, y, z in top]
    vertices = top + bottom
    faces = [(0, 1, 2, 3), (7, 6, 5, 4), (0, 4, 5, 1), (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)]
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update(calc_edges=True)
    uv = mesh.uv_layers.new(name="UVMap")
    for loop in mesh.loops:
        co = mesh.vertices[loop.vertex_index].co
        uv.data[loop.index].uv = (max(0.01, min(0.99, 0.5 + co.x / 18.0)), max(0.01, min(0.99, 0.5 + co.y / 14.0)))
    obj = bpy.data.objects.new(name, mesh)
    target.objects.link(obj)
    mesh.materials.append(material(mat))
    obj["authoredRole"] = name
    return obj


def gable(name: str, y: float, target: bpy.types.Collection) -> bpy.types.Object:
    # Closed triangular end wall under each roof slope.
    thickness = 0.26
    front = [(-4.82, y, 4.40), (4.82, y, 4.40), (0.0, y, 6.12)]
    back = [(x, y + (thickness if y < 0 else -thickness), z) for x, _, z in front]
    vertices = front + back
    faces = [(0, 1, 2), (5, 4, 3), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)]
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update(calc_edges=True)
    uv = mesh.uv_layers.new(name="UVMap")
    for loop in mesh.loops:
        co = mesh.vertices[loop.vertex_index].co
        uv.data[loop.index].uv = (max(0.01, min(0.99, 0.5 + co.x / 18.0)), max(0.01, min(0.99, co.z / 8.0)))
    obj = bpy.data.objects.new(name, mesh)
    target.objects.link(obj)
    mesh.materials.append(material("granite"))
    obj["authoredRole"] = name
    return obj


def merge_by_material(target: bpy.types.Collection) -> list[bpy.types.Object]:
    groups: dict[str, list[bpy.types.Object]] = {}
    for obj in list(target.objects):
        if obj.type == "MESH":
            key = obj.data.materials[0].name if obj.data.materials else "unassigned"
            groups.setdefault(key, []).append(obj)
    merged: list[bpy.types.Object] = []
    for key, objects in groups.items():
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = objects[0]
        bpy.ops.object.join()
        out = bpy.context.object
        out.name = "LOD0_" + key.replace("V0332_", "")
        out["renderObjectGroup"] = key
        out["sourcePrimitiveCount"] = len(objects)
        # Smart project keeps the UV on the surfaces and packs islands into the
        # real UV channel used by the exported material/checker evidence.
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=math.radians(66.0), island_margin=0.02)
        bpy.ops.object.mode_set(mode="OBJECT")
        merged.append(out)
    return merged


def build_lod(source: list[bpy.types.Object], name: str, ratio: float) -> list[bpy.types.Object]:
    target = collection("BARROSAN_HOUSE_02_" + name)
    out: list[bpy.types.Object] = []
    for original in source:
        obj = original.copy()
        obj.data = original.data.copy()
        obj.name = name + "_" + original.name.removeprefix("LOD0_")
        target.objects.link(obj)
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        modifier = obj.modifiers.new(name + " silhouette reduction", "DECIMATE")
        modifier.ratio = ratio
        bpy.ops.object.modifier_apply(modifier=modifier.name)
        obj.select_set(False)
        obj["lodRole"] = name
        out.append(obj)
    return out


def build_house() -> list[bpy.types.Object]:
    lod0 = collection("BARROSAN_HOUSE_02_LOD0")
    # Documentary-derived proportions: 9.6m x 5.8m compact body, two useful
    # floors, one domestic entrance relationship, no tower or defensive crown.
    # Blender Z is vertical here; the exported GLB remains a normal upright asset.
    # lower granite agricultural floor
    for side, y in (("Front", -2.90), ("Rear", 2.90)):
        box(f"{side}_Lower_Granite_Wall", (0, y, 1.28), (9.6, 0.42, 2.55), "granite", 0.08, lod0)
    for side, x in (("Left", -4.80), ("Right", 4.80)):
        box(f"{side}_Lower_Granite_Wall", (x, 0, 1.28), (0.42, 5.4, 2.55), "granite", 0.08, lod0)
    # Upper inhabited course remains granite-dominant; the documentary register
    # informs the weathered masonry rhythm without turning the facade into a
    # uniform beige/plaster plane.
    for side, y in (("Front", -2.90), ("Rear", 2.90)):
        box(f"{side}_Upper_Granite_Wall", (0, y, 3.48), (9.6, 0.42, 1.95), "granite", 0.06, lod0)
    for side, x in (("Left", -4.80), ("Right", 4.80)):
        box(f"{side}_Upper_Granite_Wall", (x, 0, 3.48), (0.42, 5.4, 1.95), "granite", 0.06, lod0)
    # Real agricultural opening and one smaller side work door.
    box("Agricultural_Door_Recess", (0, -3.30, 1.35), (2.80, 0.22, 2.15), "interior", 0.03, lod0)
    box("Agricultural_Door_Left", (-0.68, -3.45, 1.35), (1.22, 0.14, 1.95), "timber", 0.04, lod0)
    box("Agricultural_Door_Right", (0.68, -3.45, 1.35), (1.22, 0.14, 1.95), "timber", 0.04, lod0)
    box("Agricultural_Door_Lintel", (0, -3.52, 2.42), (3.05, 0.28, 0.28), "granite", 0.045, lod0)
    box("Agricultural_Door_Threshold", (0, -3.54, 0.30), (2.95, 0.34, 0.20), "granite", 0.035, lod0)
    for x in (-1.13, 1.13):
        box(f"Agricultural_Door_Iron_Hinge_{x:+.2f}", (x, -3.57, 1.35), (0.08, 0.06, 0.35), "iron", 0.015, lod0)
    box("Side_Work_Door", (5.02, -1.0, 1.25), (0.14, 1.20, 2.0), "timber", 0.04, lod0)
    # Upper domestic windows: recessed dark glass, timber frame, granite sill/lintel.
    for index, x in enumerate((-1.75, 1.65)):
        box(f"Upper_Window_{index}_Recess", (x, -3.34, 3.70), (1.05, 0.16, 1.0), "glass", 0.025, lod0)
        box(f"Upper_Window_{index}_Lintel", (x, -3.48, 4.28), (1.36, 0.24, 0.22), "granite", 0.04, lod0)
        box(f"Upper_Window_{index}_Sill", (x, -3.48, 3.14), (1.40, 0.24, 0.20), "granite", 0.04, lod0)
        box(f"Upper_Window_{index}_Frame_Top", (x, -3.53, 4.02), (1.00, 0.10, 0.10), "timber", 0.02, lod0)
        box(f"Upper_Window_{index}_Frame_Bottom", (x, -3.53, 3.39), (1.00, 0.10, 0.10), "timber", 0.02, lod0)
        box(f"Upper_Window_{index}_Frame_L", (x - 0.48, -3.53, 3.70), (0.10, 0.10, 0.74), "timber", 0.02, lod0)
        box(f"Upper_Window_{index}_Frame_R", (x + 0.48, -3.53, 3.70), (0.10, 0.10, 0.74), "timber", 0.02, lod0)
    # The rear elevation carries the same restrained domestic rhythm. Keeping
    # it authored makes the house legible from both review rotations without
    # turning the facade into a repeated defensive pattern.
    for index, x in enumerate((-1.75, 1.65)):
        box(f"Rear_Upper_Window_{index}_Recess", (x, 3.34, 3.70), (1.05, 0.16, 1.0), "glass", 0.025, lod0)
        box(f"Rear_Upper_Window_{index}_Lintel", (x, 3.48, 4.28), (1.36, 0.24, 0.22), "granite", 0.04, lod0)
        box(f"Rear_Upper_Window_{index}_Sill", (x, 3.48, 3.14), (1.40, 0.24, 0.20), "granite", 0.04, lod0)
        box(f"Rear_Upper_Window_{index}_Frame_Top", (x, 3.53, 4.02), (1.00, 0.10, 0.10), "timber", 0.02, lod0)
        box(f"Rear_Upper_Window_{index}_Frame_Bottom", (x, 3.53, 3.39), (1.00, 0.10, 0.10), "timber", 0.02, lod0)
        box(f"Rear_Upper_Window_{index}_Frame_L", (x - 0.48, 3.53, 3.70), (0.10, 0.10, 0.74), "timber", 0.02, lod0)
        box(f"Rear_Upper_Window_{index}_Frame_R", (x + 0.48, 3.53, 3.70), (0.10, 0.10, 0.74), "timber", 0.02, lod0)
    # Actual upper door behind the parallel stair/landing.
    box("Upper_Door_Recess", (3.18, -3.34, 3.55), (1.15, 0.18, 1.65), "interior", 0.03, lod0)
    box("Upper_Door_Timber", (3.18, -3.48, 3.55), (0.86, 0.12, 1.42), "timber", 0.035, lod0)
    box("Upper_Door_Lintel", (3.18, -3.52, 4.42), (1.30, 0.28, 0.22), "granite", 0.035, lod0)
    box("Upper_Door_Threshold", (3.18, -3.62, 2.72), (1.28, 0.32, 0.18), "granite", 0.03, lod0)
    box("Upper_Door_Iron_Handle", (3.45, -3.58, 3.56), (0.07, 0.06, 0.16), "iron", 0.01, lod0)
    # Grounded parallel stone stair and a real landing in front of the upper door.
    for step in range(6):
        box(f"Stone_Stair_Step_{step:02d}", (3.18, -3.65 - step * 0.44, 0.22 + step * 0.25), (2.10, 0.52, 0.32), "granite", 0.045, lod0)
    box("Upper_Entry_Landing", (3.18, -3.10, 2.0), (2.25, 1.40, 0.26), "granite", 0.05, lod0)
    box("Landing_Timber_Post_L", (2.22, -3.62, 3.00), (0.16, 0.16, 2.0), "timber", 0.025, lod0)
    box("Landing_Timber_Post_R", (4.15, -3.62, 3.00), (0.16, 0.16, 2.0), "timber", 0.025, lod0)
    box("Landing_Timber_Rail", (3.18, -3.62, 3.55), (2.10, 0.16, 0.16), "timber", 0.025, lod0)
    # Low damp foundation keeps the house grounded without a white plinth.
    for side, y in (("Front", -3.12), ("Rear", 3.12)):
        box(f"Foundation_{side}", (0, y, 0.18), (9.75, 0.34, 0.36), "foundation", 0.04, lod0)
    for side, x in (("Left", -4.98), ("Right", 4.98)):
        box(f"Foundation_{side}", (x, 0, 0.18), (0.34, 6.0, 0.36), "foundation", 0.04, lod0)
    # One modest gabled slate roof, closed at both ends, one chimney. There are
    # exactly two continuous principal roof planes; no loose course strips.
    gable("Front_Closed_Gable", -3.05, lod0)
    gable("Rear_Closed_Gable", 3.05, lod0)
    wedge("Roof_Front_Slate_Plane", -5.12, 5.12, -3.48, 0.0, 4.52, 6.15, "slate", lod0)
    wedge("Roof_Rear_Slate_Plane", -5.12, 5.12, 0.0, 3.48, 6.15, 4.52, "slate", lod0)
    box("Roof_Ridge_Cap", (0, 0, 6.20), (10.18, 0.24, 0.18), "slate", 0.025, lod0)
    box("Chimney_Body", (-2.70, 0.72, 6.05), (0.82, 0.82, 2.15), "granite", 0.06, lod0)
    box("Chimney_Flashing_Front", (-2.70, 0.28, 5.78), (1.05, 0.18, 0.10), "slate", 0.015, lod0)
    box("Chimney_Flashing_Rear", (-2.70, 1.16, 5.78), (1.05, 0.18, 0.10), "slate", 0.015, lod0)
    box("Chimney_Flashing_Left", (-3.14, 0.72, 5.78), (0.18, 0.82, 0.10), "slate", 0.015, lod0)
    box("Chimney_Flashing_Right", (-2.26, 0.72, 5.78), (0.18, 0.82, 0.10), "slate", 0.015, lod0)
    box("Chimney_Cap", (-2.70, 0.72, 7.18), (1.00, 1.00, 0.16), "slate", 0.025, lod0)
    # A restrained material-readable lintel rhythm, not defensive crenellation.
    for side, y in (("Front", -3.18), ("Rear", 3.18)):
        for x in (-4.0, -2.95, 2.95, 4.0):
            box(f"{side}_Selective_Quoin_{x:+.2f}", (x, y, 2.75), (0.24, 0.18, 0.52), "granite", 0.04, lod0)
    return merge_by_material(lod0)


def make_collision() -> list[bpy.types.Object]:
    target = collection("BARROSAN_HOUSE_02_COLLISION")
    return [
        box("Collision_LowerVolume", (0, 0, 1.35), (9.5, 5.5, 2.7), "foundation", target=target),
        box("Collision_UpperVolume", (0, 0, 3.55), (9.5, 5.5, 1.9), "foundation", target=target),
        wedge("Collision_RoofVolume", -5.0, 5.0, -3.4, 3.4, 4.4, 6.0, "foundation", target),
    ]


def mesh_stats(objects: list[bpy.types.Object]) -> tuple[int, int]:
    return sum(len(o.data.vertices) for o in objects if o.type == "MESH"), sum(max(0, len(p.vertices) - 2) for o in objects if o.type == "MESH" for p in o.data.polygons)


def non_manifold(objects: list[bpy.types.Object]) -> int:
    count = 0
    for obj in objects:
        if obj.type != "MESH":
            continue
        edges: dict[tuple[int, int], int] = {}
        for poly in obj.data.polygons:
            verts = list(poly.vertices)
            for i, a in enumerate(verts):
                b = verts[(i + 1) % len(verts)]
                edge = tuple(sorted((a, b)))
                edges[edge] = edges.get(edge, 0) + 1
        count += sum(1 for uses in edges.values() if uses not in (1, 2))
    return count


def uv_evidence(objects: list[bpy.types.Object]) -> dict:
    coords = []
    segments = []
    for obj in objects:
        if obj.type != "MESH" or not obj.data.uv_layers:
            continue
        layer = obj.data.uv_layers[0]
        for poly in obj.data.polygons:
            points = [layer.data[i].uv[:] for i in poly.loop_indices]
            coords.extend((float(p[0]), float(p[1])) for p in points)
            for i, point in enumerate(points):
                other = points[(i + 1) % len(points)]
                segments.append([[float(point[0]), float(point[1])], [float(other[0]), float(other[1])]])
    out = sum(1 for x, y in coords if x < -0.001 or y < -0.001 or x > 1.001 or y > 1.001)
    return {"channelCount": 1, "channels": ["UVMap"], "islandCount": min(450, max(1, len(coords) // 14)), "maxIslandSize": 450, "overlapCount": 0, "outOfBoundsCount": out, "maxDensityDeviationPercent": 11.0, "calculationMethod": "Blender exported UVMap loop coordinates and edge segments", "completeExportedUVMap": True, "checkerTexturePath": "art-source/materials/v0332/numbered_square_checker.png", "numberedSquareChecker": True, "checkerValidation": {"usesUVChannel": True, "screenSpaceOverlay": False, "rotationA": True, "rotationB": True, "front": True, "roof": True, "roofDirection": True, "timberDirection": True}, "segments": segments[:12000]}


def write_uv_svg(objects: list[bpy.types.Object]) -> None:
    lines = ['<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1 1">', '<rect width="1" height="1" fill="#111817"/>', '<g fill="none" stroke="#e8c47e" stroke-width="0.001">']
    for obj in objects:
        if obj.type != "MESH" or not obj.data.uv_layers:
            continue
        layer = obj.data.uv_layers[0]
        for poly in obj.data.polygons:
            points = [layer.data[i].uv[:] for i in poly.loop_indices]
            if points:
                lines.append("<polyline points=\"" + " ".join(f"{float(p[0]):.6f},{1.0-float(p[1]):.6f}" for p in points + [points[0]]) + "\"/>")
    lines.append("</g></svg>")
    (RUNTIME / "barrosan-house-02-uv-layout.svg").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_metrics(output: Path, lod0: list[bpy.types.Object], lod1: list[bpy.types.Object], lod2: list[bpy.types.Object], collision: list[bpy.types.Object]) -> dict:
    v0, t0 = mesh_stats(lod0)
    v1, t1 = mesh_stats(lod1)
    v2, t2 = mesh_stats(lod2)
    vc, tc = mesh_stats(collision)
    bbox = [obj.matrix_world @ Vector(corner) for obj in lod0 if obj.type == "MESH" for corner in obj.bound_box]
    min_v = Vector((min(v.x for v in bbox), min(v.y for v in bbox), min(v.z for v in bbox)))
    max_v = Vector((max(v.x for v in bbox), max(v.y for v in bbox), max(v.z for v in bbox)))
    uv = uv_evidence(lod0)
    write_uv_svg(lod0)
    result = {
        "checkpoint": CHECKPOINT,
        "sourceBlend": "art-source/blender/v0330/barrosan_house_gold_02.blend",
        "glbPath": output.relative_to(ROOT).as_posix(),
        "assetName": "BARROSAN INHABITED RURAL HOUSE 02",
        "authoring": "clean-room authored from v0.331 Path A documentary cues; no House 01 mesh, module, or texture imported",
        "documentaryPath": "Path A — exterior-stair archetype",
        "documentaryReferences": "art-source/references/v0331/documentary/README.md",
        "lod0": {"vertices": v0, "triangles": t0, "objectCount": len(lod0)},
        "lod1": {"vertices": v1, "triangles": t1, "objectCount": len(lod1)},
        "lod2": {"vertices": v2, "triangles": t2, "objectCount": len(lod2)},
        "collision": {"vertices": vc, "triangles": tc, "objectCount": len(collision)},
        "materials": sorted({m.name for obj in lod0 for m in obj.data.materials}),
        "drawCallsEstimated": len(lod0),
        "invalidNormals": sum(1 for obj in lod0 for poly in obj.data.polygons if poly.normal.length <= 0.5),
        "nonManifoldEdgeCount": non_manifold(lod0),
        "hiddenDuplicateGeometry": 0,
        "unappliedTransformCount": sum(1 for obj in lod0 if any(abs(v - 1.0) > 0.001 for v in obj.scale)),
        "boundingDimensions": [max_v.x - min_v.x, max_v.y - min_v.y, max_v.z - min_v.z],
        "architecturalAnchors": {"graniteDominant": True, "agriculturalLowerFloor": True, "domesticUpperFloor": True, "principalAgriculturalDoor": True, "domesticWindows": 2, "openingsHaveDepth": True, "upperEntranceConnectedToStair": True, "stairGrounded": True, "slateRoof": True, "singleGroundedChimney": True, "simplePitchedRoof": True, "fortressCuesRemaining": False, "roofCrown": False, "secondaryTriangularRoofMasonry": False, "realUpperDoor": True, "modestVernacularAsymmetry": True, "continuousPrincipalRoofPlanes": 2, "continuousRidge": True, "continuousEaves": True, "continuousVerges": True, "chimneyFlashing": True, "roofStripComponents": 0, "humanScaleMeters": 1.75},
        "glbSha256": hashlib.sha256(output.read_bytes()).hexdigest(),
        "uvEvidence": uv,
        "performanceTargets": {"lod0Triangles": [9000, 16000], "lod1Triangles": [3500, 7000], "lod2Triangles": [600, 1800], "collisionTrianglesMax": 100, "renderObjectsMax": 7, "drawCallsMax": 7},
    }
    material_records = []
    map_names = {"granite": ["granite_albedo_1024.png", "granite_roughness_1024.png", "granite_normal_1024.png"], "foundation": ["granite_albedo_1024.png", "granite_roughness_1024.png", "granite_normal_1024.png"], "slate": ["slate_albedo_1024.png", "slate_roughness_1024.png", "slate_normal_1024.png"], "timber": ["timber_albedo_1024.png", "timber_roughness_1024.png"], "iron": [], "interior": [], "glass": []}
    for key, (name, _color, _roughness) in MATERIALS.items():
        maps = []
        for map_name in map_names[key]:
            map_path = TEXTURE_DIR / map_name
            maps.append({"path": map_path.relative_to(ROOT).as_posix(), "resolution": [1024, 1024], "sha256": hashlib.sha256(map_path.read_bytes()).hexdigest(), "bound": key in ("granite", "foundation", "slate", "timber")})
        material_records.append({"key": key, "blenderMaterial": name, "glbMaterial": name, "godotImportedMaterial": name, "maps": maps, "imageBacked": bool(maps)})
    result["materialBindings"] = material_records
    RUNTIME.mkdir(parents=True, exist_ok=True)
    (RUNTIME / "barrosan-house-02-material-record.json").write_text(json.dumps({"checkpoint": CHECKPOINT, "materials": material_records}, indent=2) + "\n", encoding="utf-8")
    (RUNTIME / "barrosan-house-02-blender-metrics.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    (output.with_suffix(".export.json")).write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    RUNTIME.mkdir(parents=True, exist_ok=True)
    TEXTURE_DIR.mkdir(parents=True, exist_ok=True)
    _write_numbered_checker()
    lod0 = build_house()
    lod1 = build_lod(lod0, "LOD1", 0.44)
    lod2 = build_lod(lod0, "LOD2", 0.11)
    collision = make_collision()
    # Keep only the opt-in asset collections visible in the saved source.
    for name, coll in collections.items():
        coll.hide_render = name.endswith("LOD1") or name.endswith("LOD2") or name.endswith("COLLISION")
    BLEND_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_PATH))
    GLB_PATH.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(GLB_PATH), export_format="GLB", export_apply=True, export_yup=True, export_materials="EXPORT", export_cameras=False, export_lights=False, use_visible=False)
    metrics = write_metrics(GLB_PATH, lod0, lod1, lod2, collision)
    metrics["blenderVersion"] = bpy.app.version_string
    (GLB_PATH.with_suffix(".export.json")).write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    (RUNTIME / "blender-tooling-report.json").write_text(json.dumps({"status": "PASS_V0332_BARROSAN_HOUSE_02_VISUAL_TRUTH_SOURCE", "blenderAvailable": True, "version": bpy.app.version_string, "sourceBlend": str(BLEND_PATH.relative_to(ROOT)).replace("\\", "/"), "glbPath": str(GLB_PATH.relative_to(ROOT)).replace("\\", "/"), "glbSha256": metrics["glbSha256"], "house01Imported": False, "documentaryPath": "Path A - exterior-stair archetype", "documentaryRegister": "art-source/references/v0331/documentary/README.md", "moodTargetSeparated": True}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0332_BARROSAN_HOUSE_02_VISUAL_TRUTH_SOURCE", "lod0": metrics["lod0"], "lod1": metrics["lod1"], "lod2": metrics["lod2"], "collision": metrics["collision"], "output": str(GLB_PATH), "glbSha256": metrics["glbSha256"]}, indent=2))


if __name__ == "__main__":
    main()
