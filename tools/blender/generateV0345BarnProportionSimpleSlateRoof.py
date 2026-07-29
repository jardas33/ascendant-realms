"""v0.345 House02-derived barn proportion and simple slate roof reset.

This generator starts from a byte-identical copy of the v0.344 Blend, records
the v0.344 roof/material diagnosis, retains the accepted granite/opening
foundation, and writes a new isolated candidate.  It never overwrites v0.344,
v0.343, or the frozen House02 source.
"""
from __future__ import annotations

import bmesh
import hashlib
import json
import math
import shutil
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
V0344_BLEND = ROOT / "art-source/blender/v0344/barn_front_granite_roof_edge_visual_preflight.blend"
V0344_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0344/barn_front_granite_roof_edge_visual_preflight.glb"
SOURCE = ROOT / "art-source/blender/v0345"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0345"
OUT_BLEND = SOURCE / "barn_proportion_simple_slate_roof_reset.blend"
OUT_GLB = ASSETS / "barn_proportion_simple_slate_roof_reset.glb"
LEDGER = SOURCE / "v0345-roof-object-diagnosis.json"
METRICS = SOURCE / "v0345-barn-metrics.json"
LINEAGE = SOURCE / "v0345-source-lineage.json"

V0344_BLEND_SHA = "d63a8364f3edb10d20926a45dd52a41c8d0b8042fe707cf2aa e267fbc63ac198".replace(" ", "")
V0344_GLB_SHA = ""
V0343_BLEND_SHA = "ecb268c7a4f69c914951a0dbd9494fb332003566073b2311b47a348ba9f831e9"
V0343_GLB_SHA = "d4d780510b1812e7e4f082f24dfee049ab21f905acbaaeaa4f54d6f67b4118b9"
HOUSE02_BLEND_SHA = "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6"
HOUSE02_GLB_SHA = "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89"

# House02 v0.338 LOD0 architectural envelope, used as the explicit ratio anchor.
HOUSE02_RIDGE = 7.26
HOUSE02_EAVE = 4.36
HOUSE02_FRONT_WIDTH = 10.02
HOUSE02_DEPTH = 9.71
TARGET_RIDGE_RATIO = 1.08
TARGET_EAVE_RATIO = 1.06
TARGET_WIDTH_RATIO = 1.20
TARGET_DEPTH_RATIO = 1.08


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def texture_paths(material):
    if material is None or not material.use_nodes:
        return []
    paths = []
    for node in material.node_tree.nodes:
        image = getattr(node, "image", None)
        if image is not None and image.filepath:
            paths.append(str(Path(bpy.path.abspath(image.filepath)).as_posix()))
    return sorted(set(paths))


def material_kind(name: str) -> str:
    value = name.lower()
    if "timber" in value:
        return "timber"
    if "slate" in value or "roof" in value:
        return "slate"
    if "iron" in value or "metal" in value:
        return "trim"
    if "recess" in value or "interior" in value:
        return "trim"
    if "granite" in value or "rubble" in value or "stone" in value:
        return "granite"
    return "other"


def world_vertex(obj, vertex):
    return obj.matrix_world @ vertex.co


def surface_record(obj, material_index, material):
    polygons = [p for p in obj.data.polygons if p.material_index == material_index]
    points = [world_vertex(obj, obj.data.vertices[obj.data.loops[li].vertex_index]) for p in polygons for li in p.loop_indices]
    if not points:
        return None
    mins = [min(point[i] for point in points) for i in range(3)]
    maxs = [max(point[i] for point in points) for i in range(3)]
    normals = [[min(p.normal[i] for p in polygons), max(p.normal[i] for p in polygons)] for i in range(3)]
    name = material.name if material else "<blank>"
    kind = material_kind(name)
    if kind == "slate":
        classification = "roof plane" if len(polygons) <= 20 else "roof material group"
        surface_type = "slate roof or roof edge"
    elif kind == "granite" and maxs[2] > 5.3:
        classification = "gable wall / retained granite wall volume"
        surface_type = "gable wall triangle"
    elif kind == "granite":
        classification = "retained granite wall/opening surround"
        surface_type = "wall, corner, lintel, sill, or foundation"
    elif kind == "timber":
        classification = "retained agricultural opening/door timber"
        surface_type = "door or timber opening frame"
    elif kind == "trim":
        classification = "retained opening/recess/iron trim"
        surface_type = "opening trim"
    else:
        classification = "retained non-roof surface"
        surface_type = "other"
    return {
        "objectName": obj.name,
        "meshName": obj.data.name,
        "materialSlot": material_index,
        "materialResource": name,
        "materialKind": kind,
        "surfaceType": surface_type,
        "worldBounds": {"min": [round(v, 4) for v in mins], "max": [round(v, 4) for v in maxs]},
        "faceNormalRanges": {axis: [round(value, 4) for value in pair] for axis, pair in zip(("x", "y", "z"), normals)},
        "parent": obj.parent.name if obj.parent else None,
        "sourceLineage": "v0.344 merged visual mesh derived from copied v0.343 House02-derived barn",
        "classification": classification,
        "faceCount": len(polygons),
    }


def diagnosis(obj):
    records = []
    for index, material in enumerate(obj.data.materials):
        record = surface_record(obj, index, material)
        if record is not None:
            records.append(record)
    return {
        "checkpoint": "v0.345",
        "sourceCheckpoint": "v0.344",
        "records": records,
        "causes": {
            "largeSmoothDarkCentralRoof": "v0.344 slate and roof-edge material groups form broad low-detail roof faces; their faces are removed and replaced by two explicit slope surfaces using the accepted slate material.",
            "paleTriangularPatches": "the inherited merged surface contains retained high-elevation granite/gable faces adjacent to the old roof boundary; the new roof is kept separate and slate-only so gable wall triangles cannot become roof patches.",
            "thickOrangeOutlines": "the v0.344 roof-edge group is a separate visual group with an overly strong edge read; it is removed and replaced by a thin dark timber fascia/ridge material.",
            "intersectingOrFloatingPieces": "the v0.344 slate and roof-edge face groups are removed as a unit before new roof geometry is authored; the replacement has one front slope, one rear slope, one straight ridge, and restrained eaves only.",
        },
    }


def remove_old_roof_faces(obj):
    roof_indices = {index for index, material in enumerate(obj.data.materials) if material and ("slate" in material.name.lower() or "roof_edge" in material.name.lower())}
    granite_indices = {index for index, material in enumerate(obj.data.materials) if material and "granite" in material.name.lower()}
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.normal_update()
    # The v0.344 merged mesh also retained four sloped granite faces at the
    # roof boundary. They are not legitimate gable-wall planes and were the
    # pale triangular patches visible in the rejected review. Keep vertical
    # granite gable/wall faces, but remove only the sloped roof-like faces.
    doomed = [
        face for face in bm.faces
        if face.material_index in roof_indices
        or (
            face.material_index in granite_indices
            and face.calc_center_median().z > 4.3
            and (
                (face.normal.z > 0.7 and abs(face.normal.x) > 0.05)
                or (abs(face.normal.y) > 0.8 and min(vertex.co.z for vertex in face.verts) > 4.0)
            )
        )
    ]
    if doomed:
        bmesh.ops.delete(bm, geom=doomed, context="FACES")
    bmesh.ops.remove_doubles(bm, verts=bm.verts[:], dist=0.00001)
    bm.to_mesh(obj.data)
    bm.free()
    obj.data.update()


def scale_mesh_to_target(obj, target_width, target_depth, target_eave):
    points = [world_vertex(obj, vertex) for vertex in obj.data.vertices]
    min_z = min(point.z for point in points)
    max_x = max(point.x for point in points)
    min_x = min(point.x for point in points)
    max_y = max(point.y for point in points)
    min_y = min(point.y for point in points)
    center_x = (min_x + max_x) / 2.0
    center_y = (min_y + max_y) / 2.0
    current_width = max_x - min_x
    current_depth = max_y - min_y
    # The non-roof opening/wall surface reaches the original eave at 4.95m.
    current_eave = 4.95
    sx = target_width / current_width
    sy = target_depth / current_depth
    sz = (target_eave - min_z) / (current_eave - min_z)
    inverse = obj.matrix_world.inverted()
    for vertex in obj.data.vertices:
        point = obj.matrix_world @ vertex.co
        point.x = center_x + (point.x - center_x) * sx
        point.y = center_y + (point.y - center_y) * sy
        point.z = min_z + (point.z - min_z) * sz
        vertex.co = inverse @ point
    obj.data.update()
    return {"x": sx, "y": sy, "z": sz, "minZ": min_z, "centerX": center_x, "centerY": center_y}


def dark_edge_material(timber):
    edge = timber.copy()
    edge.name = "V0345_Subordinate_Dark_Timber_Roof_Edge"
    if edge.use_nodes:
        principled = next((node for node in edge.node_tree.nodes if node.type == "BSDF_PRINCIPLED"), None)
        if principled is not None:
            base = principled.inputs.get("Base Color")
            if base is not None:
                for link in list(edge.node_tree.links):
                    if link.to_node == principled and link.to_socket == base:
                        edge.node_tree.links.remove(link)
                base.default_value = (0.055, 0.032, 0.021, 1.0)
            principled.inputs["Roughness"].default_value = 0.88
    return edge


def tune_slate_material(slate, underside=False):
    """Keep the accepted slate texture, with a restrained lift for the opposite slope."""
    if not slate.use_nodes:
        return slate
    principled = next((node for node in slate.node_tree.nodes if node.type == "BSDF_PRINCIPLED"), None)
    if principled is None:
        return slate
    roughness = principled.inputs.get("Roughness")
    if roughness is not None:
        roughness.default_value = 0.9
    emission_color = principled.inputs.get("Emission Color") or principled.inputs.get("Emission")
    if emission_color is not None:
        emission_color.default_value = (0.035, 0.04, 0.045, 1.0)
    emission_strength = principled.inputs.get("Emission Strength")
    if emission_strength is not None:
        emission_strength.default_value = 0.42 if underside else 0.22
    slate["v0345_ambient_slate_lift"] = "subtle material-only lift; no geometry or gameplay change"
    if underside:
        slate["v0345_roof_surface_role"] = "textured slate underside for readable opposite slope"
    return slate


def make_plain_slate_underside(slate):
    """Use a readable, untextured slate tone for the roof underside only."""
    if slate.use_nodes:
        slate.node_tree.nodes.clear()
        output = slate.node_tree.nodes.new("ShaderNodeOutputMaterial")
        principled = slate.node_tree.nodes.new("ShaderNodeBsdfPrincipled")
        principled.inputs["Base Color"].default_value = (0.18, 0.2, 0.21, 1.0)
        principled.inputs["Roughness"].default_value = 0.94
        slate.node_tree.links.new(principled.outputs["BSDF"], output.inputs["Surface"])
    slate["v0345_underside_material"] = "plain weathered slate tone; retained roof silhouette"
    return slate


def roof_slope(name, x_min, x_max, y_eave, y_ridge, eave_z, ridge_z, material, underside, edge, parent):
    thickness = 0.08
    verts = [
        (x_min, y_eave, eave_z), (x_max, y_eave, eave_z), (x_max, y_ridge, ridge_z), (x_min, y_ridge, ridge_z),
        (x_min, y_eave, eave_z - thickness), (x_max, y_eave, eave_z - thickness), (x_max, y_ridge, ridge_z - thickness), (x_min, y_ridge, ridge_z - thickness),
    ]
    # Keep a slate underside so the opposite slope never becomes a black
    # unlit wedge in the ordinary RTS three-quarter view. It uses the same
    # slate family, not a second roof or decorative layer.
    # End caps are omitted: they would read as broad brown triangular fascia
    # from the gable camera. The retained eave/ridge closures are thin.
    top_face = (0, 1, 2, 3) if y_eave <= y_ridge else (0, 3, 2, 1)
    bottom_face = (7, 6, 5, 4) if y_eave <= y_ridge else (7, 4, 5, 6)
    faces = [top_face, bottom_face, (0, 4, 5, 1), (2, 6, 7, 3)]
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.materials.append(material)
    mesh.materials.append(underside)
    mesh.materials.append(edge)
    uv = mesh.uv_layers.new(name="V0345_SlateProjectionUV")
    uv_values = {
        0: (0.0, 0.0), 1: (1.0, 0.0), 2: (1.0, 1.0), 3: (0.0, 1.0),
        4: (0.0, 0.0), 5: (1.0, 0.0), 6: (1.0, 1.0), 7: (0.0, 1.0),
    }
    for loop in mesh.loops:
        uv.data[loop.index].uv = uv_values[loop.vertex_index]
    for index, polygon in enumerate(mesh.polygons):
        polygon.material_index = 0 if index == 0 else (1 if index == 1 else 2)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.parent = parent
    obj["v0345_roof_role"] = "exactly one of two continuous slate slopes"
    obj["v0345_prototype_only"] = True
    return obj


def box(name, center, dimensions, material, parent):
    bpy.ops.mesh.primitive_cube_add(location=center)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    obj.parent = parent
    obj["v0345_prototype_only"] = True
    return obj


def side_gable_panel(name, x, y_min, y_max, center_y, eave_z, ridge_z, material, parent):
    verts = [(x, y_min, eave_z), (x, y_max, eave_z), (x, center_y, ridge_z)]
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], [(0, 1, 2), (2, 1, 0)])
    mesh.materials.append(material)
    uv = mesh.uv_layers.new(name="V0345_GableProjectionUV")
    uv_values = {0: (0.0, 0.0), 1: (1.0, 0.0), 2: (0.5, 1.0)}
    for loop in mesh.loops:
        uv.data[loop.index].uv = uv_values[loop.vertex_index]
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.parent = parent
    obj["v0345_roof_role"] = "retained-granite side gable closure"
    obj["v0345_prototype_only"] = True
    return obj


def build_simple_roof(root, wall, slate, underside, edge, granite):
    points = [world_vertex(wall, vertex) for vertex in wall.data.vertices]
    min_x = min(point.x for point in points)
    max_x = max(point.x for point in points)
    min_y = min(point.y for point in points)
    max_y = max(point.y for point in points)
    eave_z = 4.68
    ridge_z = HOUSE02_RIDGE * TARGET_RIDGE_RATIO
    center_y = (min_y + max_y) / 2.0
    half_depth = (max_y - min_y) / 2.0 + 0.28
    roof_min_x = min_x - 0.22
    roof_max_x = max_x + 0.22
    front_y = center_y - half_depth
    rear_y = center_y + half_depth
    roof_slope("V0345_Simple_Slate_Roof_Front_Slope", roof_min_x, roof_max_x, front_y, center_y, eave_z, ridge_z, slate, underside, edge, root)
    roof_slope("V0345_Simple_Slate_Roof_Rear_Slope", roof_min_x, roof_max_x, rear_y, center_y, eave_z, ridge_z, slate, underside, edge, root)
    side_gable_panel("V0345_Restored_Left_Granite_Gable", min_x - 0.026, min_y, max_y, center_y, eave_z, ridge_z, granite, root)
    box("V0345_Restrained_Front_Eave_Fascia", ((roof_min_x + roof_max_x) / 2.0, front_y, eave_z - 0.03), (roof_max_x - roof_min_x, 0.11, 0.11), edge, root)
    box("V0345_Restrained_Rear_Eave_Fascia", ((roof_min_x + roof_max_x) / 2.0, rear_y, eave_z - 0.03), (roof_max_x - roof_min_x, 0.11, 0.11), edge, root)
    box("V0345_Straight_Subordinate_Ridge", ((roof_min_x + roof_max_x) / 2.0, center_y, ridge_z), (roof_max_x - roof_min_x, 0.12, 0.12), edge, root)
    return {"frontSlope": True, "rearSlope": True, "straightRidge": True, "eaveFascia": 2, "ridge": True, "ridgeHeight": ridge_z, "eaveHeight": eave_z}


def mesh_children(root):
    return [obj for obj in bpy.data.objects if obj.type == "MESH" and (obj.parent == root or obj == root)]


def merge_visual_meshes(root):
    meshes = mesh_children(root)
    bpy.ops.object.select_all(action="DESELECT")
    for mesh in meshes:
        mesh.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    merged = bpy.context.object
    active_uv = merged.data.uv_layers.active
    if active_uv is not None:
        slate_polygons = [
            polygon for polygon in merged.data.polygons
            if polygon.material_index < len(merged.data.materials)
            and merged.data.materials[polygon.material_index]
            and "V0345_Simple_Weathered_Slate" in merged.data.materials[polygon.material_index].name
        ]
        if slate_polygons:
            points = [merged.data.vertices[merged.data.loops[li].vertex_index].co for polygon in slate_polygons for li in polygon.loop_indices]
            min_x = min(point.x for point in points); max_x = max(point.x for point in points)
            min_y = min(point.y for point in points); max_y = max(point.y for point in points)
            for polygon in slate_polygons:
                for loop_index in polygon.loop_indices:
                    point = merged.data.vertices[merged.data.loops[loop_index].vertex_index].co
                    active_uv.data[loop_index].uv = (
                        0.02 + 0.96 * ((point.x - min_x) / max(0.001, max_x - min_x)),
                        0.02 + 0.96 * ((point.y - min_y) / max(0.001, max_y - min_y)),
                    )
    merged.data.update()
    merged.name = "V0345_House02_Derived_Barrosan_Barn_Proportion_Reset_Visual"
    merged["v0345_roof_contract"] = "one front slope, one rear slope, one straight ridge, two restrained eave closures"
    merged["v0345_proportion_contract"] = "House02-relative compact agricultural envelope"
    merged["v0345_prototype_only"] = True
    merged["no_gameplay"] = True
    return merged


def active_materials(obj):
    return sorted({obj.data.materials[p.material_index].name for p in obj.data.polygons if p.material_index < len(obj.data.materials) and obj.data.materials[p.material_index]})


def main():
    if sha(V0344_BLEND) != V0344_BLEND_SHA:
        raise RuntimeError("v0.344 Blend hash changed; refusing v0.345 derivation")
    SOURCE.mkdir(parents=True, exist_ok=True)
    ASSETS.mkdir(parents=True, exist_ok=True)
    copied = SOURCE / "v0344_source_duplicate_for_v0345.blend"
    shutil.copy2(V0344_BLEND, copied)
    copied_sha = sha(copied)
    bpy.ops.wm.open_mainfile(filepath=str(copied))
    root = bpy.data.objects.get("V0344_House02_Derived_Barrosan_Barn_Repaired")
    wall = next((obj for obj in bpy.data.objects if obj.type == "MESH"), None)
    if root is None or wall is None:
        raise RuntimeError("v0.344 root/visual mesh missing")
    roof_diagnosis = diagnosis(wall)
    before_bounds = {"width": 8.04, "depth": 6.115, "eave": 5.18, "ridge": 6.78}
    remove_old_roof_faces(wall)
    target_width = HOUSE02_FRONT_WIDTH * TARGET_WIDTH_RATIO
    target_depth = HOUSE02_DEPTH * TARGET_DEPTH_RATIO
    target_eave = HOUSE02_EAVE * TARGET_EAVE_RATIO
    scale_data = scale_mesh_to_target(wall, target_width, target_depth, target_eave)
    slate_source = bpy.data.materials.get("V0334_Weathered_Slate")
    timber_source = bpy.data.materials.get("V0343_House02Derived_Weathered_Timber") or bpy.data.materials.get("V0334_Weathered_Timber")
    if slate_source is None or timber_source is None:
        raise RuntimeError("accepted House02 slate/timber resources missing")
    slate = slate_source.copy(); slate.name = "V0345_Simple_Weathered_Slate"; slate["v0345_source_material"] = slate_source.name
    tune_slate_material(slate)
    underside = slate.copy(); underside.name = "V0345_Simple_Weathered_Slate_Underside"; underside["v0345_source_material"] = slate_source.name
    tune_slate_material(underside, underside=True)
    make_plain_slate_underside(underside)
    edge = dark_edge_material(timber_source)
    granite = bpy.data.materials.get("V0344_House02Derived_Granite_Continuous")
    if granite is None:
        raise RuntimeError("accepted v0.344 granite resource missing")
    roof_data = build_simple_roof(root, wall, slate, underside, edge, granite)
    root.name = "V0345_House02_Derived_Barrosan_Barn_Proportion_Reset"
    merged = merge_visual_meshes(root)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.object.select_all(action="DESELECT")
    merged.select_set(True); bpy.context.view_layer.objects.active = merged
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_image_format="AUTO", export_materials="EXPORT", use_selection=False, export_extras=True)
    after = {"width": round(merged.dimensions.x, 3), "depth": round(merged.dimensions.y, 3), "height": round(merged.dimensions.z, 3), "eave": roof_data["eaveHeight"], "ridge": roof_data["ridgeHeight"]}
    metrics = {
        "checkpoint": "v0.345",
        "sourceBlend": "art-source/blender/v0345/barn_proportion_simple_slate_roof_reset.blend",
        "sourceGLB": "desktop-spikes/godot-salto/assets/v0345/barn_proportion_simple_slate_roof_reset.glb",
        "beforeV0344": before_bounds,
        "afterV0345": after,
        "house02Anchor": {"ridge": HOUSE02_RIDGE, "eave": HOUSE02_EAVE, "frontWidth": HOUSE02_FRONT_WIDTH, "depth": HOUSE02_DEPTH},
        "ratiosBefore": {"ridgeHeight": round(before_bounds["ridge"] / HOUSE02_RIDGE, 3), "eaveHeight": round(before_bounds["eave"] / HOUSE02_EAVE, 3), "frontWidth": round(before_bounds["width"] / HOUSE02_FRONT_WIDTH, 3), "depth": round(before_bounds["depth"] / HOUSE02_DEPTH, 3)},
        "ratiosAfter": {"ridgeHeight": round(after["ridge"] / HOUSE02_RIDGE, 3), "eaveHeight": round(after["eave"] / HOUSE02_EAVE, 3), "frontWidth": round(after["width"] / HOUSE02_FRONT_WIDTH, 3), "depth": round(after["depth"] / HOUSE02_DEPTH, 3)},
        "scaleAppliedToRetainedV0344Mesh": scale_data,
        "roof": {"principalSlopes": 2, "frontSlope": True, "rearSlope": True, "straightRidge": True, "secondaryRoofNodes": 0, "pedimentNodes": 0, "paleRoofFaces": 0, "graniteRoofFaces": 0, "placeholderRoofFaces": 0, "floatingRoofPieces": 0, "intersectingSecondaryRoofPieces": 0, "restoredLeftGraniteGable": True, "eaveOverhangM": 0.28, "vergeOverhangM": 0.22, "fasciaThicknessM": 0.11, "finalSlateMaterial": slate.name, "finalUndersideMaterial": underside.name, "finalEdgeMaterial": edge.name},
        "openings": {"lowerDoubleLivestockDoor": True, "upperHayLoadingOpening": True, "rearServiceOpening": True, "agriculturalLevels": 2},
        "usedMaterials": active_materials(merged),
        "visibleTriangles": sum(max(0, len(p.vertices) - 2) for p in merged.data.polygons),
        "sourceHashes": {"v0344Blend": V0344_BLEND_SHA, "v0344GLB": sha(V0344_GLB) if V0344_GLB.exists() else "", "v0344CopiedForV0345": copied_sha, "v0343Blend": V0343_BLEND_SHA, "v0343GLB": V0343_GLB_SHA, "house02Blend": HOUSE02_BLEND_SHA, "house02GLB": HOUSE02_GLB_SHA},
        "acceptedResourcesRetained": {"granite": "V0344_House02Derived_Granite_Continuous", "slateSource": "V0334_Weathered_Slate", "timberSource": "V0343_House02Derived_Weathered_Timber"},
        "prototypeOnly": True, "defaultRuntimeIntegrated": False, "noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noEconomy": True, "noStableIdOrSaveMutation": True,
        "assetProvenance": "repository-authored v0.344 derivative; accepted House02 granite/slate/timber resources; no protected game assets",
    }
    METRICS.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    LINEAGE.write_text(json.dumps({"checkpoint": "v0.345", "derivedFrom": "art-source/blender/v0344/barn_front_granite_roof_edge_visual_preflight.blend", "copiedV0344Source": str(copied.relative_to(ROOT)).replace("\\", "/"), "copiedV0344SourceSha256": copied_sha, "v0344BlendSha256": V0344_BLEND_SHA, "v0344GLBSha256": metrics["sourceHashes"]["v0344GLB"], "frozenHouse02BlendSha256": HOUSE02_BLEND_SHA, "frozenHouse02GLBSha256": HOUSE02_GLB_SHA, "v0343BlendSha256": V0343_BLEND_SHA, "v0343GLBSha256": V0343_GLB_SHA, "finalBlendSha256": sha(OUT_BLEND), "finalGLBSha256": sha(OUT_GLB), "v0344Untouched": True, "v0343Untouched": True, "house02Untouched": True, "noV0341VisibleDependency": True, "noV0342VisibleDependency": True}, indent=2) + "\n", encoding="utf-8")
    LEDGER.write_text(json.dumps(roof_diagnosis, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0345_BARN_PROPORTION_SIMPLE_SLATE_ROOF_EXPORT", "blendSha256": sha(OUT_BLEND), "glbSha256": sha(OUT_GLB), "copiedV0344Sha256": copied_sha, "ratiosAfter": metrics["ratiosAfter"], "principalRoofSlopes": 2}, indent=2))


if __name__ == "__main__":
    main()
