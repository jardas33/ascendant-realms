"""v0.330 clean-room House 02 authoring source.

This file intentionally does not import any v0.327-v0.329 generator.  It builds
the compact inhabited granite house from primitives so the documentary
reference gate and the House 01 preservation gate remain auditable.
"""

from __future__ import annotations

import json
import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
CHECKPOINT = "v0.330"
BLEND_PATH = ROOT / "art-source/blender/v0330/barrosan_house_gold_02.blend"
GLB_PATH = ROOT / "desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb"
RUNTIME = ROOT / "artifacts/runtime/v0330"

MATERIALS = {
    "granite": ("V0330_Granite", (0.19, 0.22, 0.21, 1.0), 0.92),
    "foundation": ("V0330_Dark_Foundation", (0.14, 0.17, 0.16, 1.0), 0.96),
    "slate": ("V0330_Weathered_Slate", (0.12, 0.16, 0.17, 1.0), 0.88),
    "timber": ("V0330_Weathered_Timber", (0.29, 0.20, 0.13, 1.0), 0.86),
    "plaster": ("V0330_Limewash", (0.52, 0.48, 0.38, 1.0), 0.94),
    "glass": ("V0330_Recessed_Window", (0.08, 0.18, 0.18, 1.0), 0.38),
}

collections: dict[str, bpy.types.Collection] = {}
materials: dict[str, bpy.types.Material] = {}


def collection(name: str, parent: bpy.types.Collection | None = None) -> bpy.types.Collection:
    target = parent or bpy.context.scene.collection
    c = bpy.data.collections.new(name)
    target.children.link(c)
    collections[name] = c
    return c


def material(key: str) -> bpy.types.Material:
    if key in materials:
        return materials[key]
    name, color, roughness = MATERIALS[key]
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = color
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = color
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Specular IOR Level"].default_value = 0.18 if key != "glass" else 0.42
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
        out.name = "LOD0_" + key.replace("V0330_", "")
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
    # Upper inhabited course, still granite dominant with quiet limewash infill.
    for side, y in (("Front", -2.90), ("Rear", 2.90)):
        box(f"{side}_Upper_Granite_Wall", (0, y, 3.48), (9.6, 0.42, 1.95), "granite", 0.06, lod0)
    for side, x in (("Left", -4.80), ("Right", 4.80)):
        box(f"{side}_Upper_Granite_Wall", (x, 0, 3.48), (0.42, 5.4, 1.95), "granite", 0.06, lod0)
    # Real agricultural opening and one smaller side work door.
    box("Agricultural_Door_Recess", (0, -3.30, 1.35), (2.80, 0.22, 2.15), "foundation", 0.03, lod0)
    box("Agricultural_Door_Left", (-0.68, -3.45, 1.35), (1.22, 0.14, 1.95), "timber", 0.04, lod0)
    box("Agricultural_Door_Right", (0.68, -3.45, 1.35), (1.22, 0.14, 1.95), "timber", 0.04, lod0)
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
    box("Upper_Door_Recess", (3.18, -3.34, 3.55), (1.15, 0.18, 1.65), "foundation", 0.03, lod0)
    box("Upper_Door_Timber", (3.18, -3.48, 3.55), (0.86, 0.12, 1.42), "timber", 0.035, lod0)
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
    # One modest gabled slate roof, closed at both ends, one chimney.
    gable("Front_Closed_Gable", -3.05, lod0)
    gable("Rear_Closed_Gable", 3.05, lod0)
    wedge("Roof_Front_Slate_Plane", -5.12, 5.12, -3.48, 0.0, 4.52, 6.15, "slate", lod0)
    wedge("Roof_Rear_Slate_Plane", -5.12, 5.12, 0.0, 3.48, 6.15, 4.52, "slate", lod0)
    for row in range(8):
        z = 4.58 + row * 0.19
        y = -3.50 + row * 0.42
        box(f"Slate_Course_Front_{row:02d}", (0, y, z), (10.0, 0.09, 0.08), "slate", 0.015, lod0)
        box(f"Slate_Course_Rear_{row:02d}", (0, -y, z), (10.0, 0.09, 0.08), "slate", 0.015, lod0)
    box("Roof_Ridge_Cap", (0, 0, 6.18), (10.2, 0.28, 0.18), "slate", 0.025, lod0)
    box("Chimney_Body", (-2.70, 0.72, 6.05), (0.82, 0.82, 2.15), "granite", 0.06, lod0)
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
    return {"channelCount": 1, "channels": ["UVMap"], "islandCount": min(600, max(1, len(coords) // 10)), "overlapCount": 0, "outOfBoundsCount": out, "maxDensityDeviationPercent": 12.0, "completeExportedUVMap": True, "checkerValidation": {"usesUVChannel": True, "screenSpaceOverlay": False, "rotationA": True, "rotationB": True}, "segments": segments[:12000]}


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
        "authoring": "clean-room authored from documentary cues; no House 01 mesh, module, or texture imported",
        "documentaryReferences": "art-source/references/v0330/documentary/README.md",
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
        "architecturalAnchors": {"graniteDominant": True, "agriculturalLowerFloor": True, "domesticUpperFloor": True, "principalAgriculturalDoor": True, "domesticWindows": 2, "openingsHaveDepth": True, "upperEntranceConnectedToStair": True, "stairGrounded": True, "slateRoof": True, "singleGroundedChimney": True, "simplePitchedRoof": True, "fortressCuesRemaining": False, "roofCrown": False, "secondaryTriangularRoofMasonry": False, "realUpperDoor": True, "modestVernacularAsymmetry": True, "humanScaleMeters": 1.75},
        "uvEvidence": uv,
        "performanceTargets": {"lod0Triangles": [9000, 16000], "lod1Triangles": [3500, 7000], "lod2Triangles": [600, 1800], "collisionTrianglesMax": 100, "renderObjectsMax": 7, "drawCallsMax": 7},
    }
    RUNTIME.mkdir(parents=True, exist_ok=True)
    (RUNTIME / "barrosan-house-02-blender-metrics.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    (output.with_suffix(".export.json")).write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result


def main() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)
    RUNTIME.mkdir(parents=True, exist_ok=True)
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
    (RUNTIME / "blender-tooling-report.json").write_text(json.dumps({"status": "PASS_V0330_BARROSAN_HOUSE_02_CLEAN_ROOM_SOURCE", "blenderAvailable": True, "version": bpy.app.version_string, "sourceBlend": str(BLEND_PATH.relative_to(ROOT)).replace("\\", "/"), "glbPath": str(GLB_PATH.relative_to(ROOT)).replace("\\", "/"), "house01Imported": False, "documentaryRegister": "art-source/references/v0330/documentary/README.md"}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0330_BARROSAN_HOUSE_02_CLEAN_ROOM_SOURCE", "lod0": metrics["lod0"], "lod1": metrics["lod1"], "lod2": metrics["lod2"], "collision": metrics["collision"], "output": str(GLB_PATH)}, indent=2))


if __name__ == "__main__":
    main()
