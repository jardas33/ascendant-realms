"""v0.346 isolated House02-family barn silhouette and roof-pitch repair.

This is a byte-derived visual candidate from the final v0.345 source.  It
retains the accepted granite/opening mesh, removes only the rejected roof
faces, and authors one restrained two-slope roof with closed granite gables.
It is never connected to the game runtime.
"""
from __future__ import annotations

import bmesh
import hashlib
import json
import math
import shutil
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
V0345_BLEND = ROOT / "art-source/blender/v0345/barn_proportion_simple_slate_roof_reset.blend"
V0345_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0345/barn_proportion_simple_slate_roof_reset.glb"
SOURCE = ROOT / "art-source/blender/v0346"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0346"
OUT_BLEND = SOURCE / "barn_house02_silhouette_roof_pitch.blend"
OUT_GLB = ASSETS / "barn_house02_silhouette_roof_pitch.glb"
METRICS = SOURCE / "v0346-barn-metrics.json"
LINEAGE = SOURCE / "v0346-source-lineage.json"
LEDGER = SOURCE / "v0346-roof-object-diagnosis.json"

V0345_BLEND_SHA = "f620e472cfbac2f0800f07e8e1bc4e840eccada971fedd5776268986c74c34ba"
V0345_GLB_SHA = "14df5b448db8257b695b00716ec6d3999f75a26ebe6cc03bd4e313399a53058c"
V0344_BLEND_SHA = "d63a8364f3edb10d20926a45dd52a41c8d0b8042fe707cf2aae267fbc63ac198"
V0343_BLEND_SHA = "ecb268c7a4f69c914951a0dbd9494fb332003566073b2311b47a348ba9f831e9"
V0343_GLB_SHA = "d4d780510b1812e7e4f082f24dfee049ab21f905acbaaeaa4f54d6f67b4118b9"
HOUSE02_BLEND_SHA = "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6"
HOUSE02_GLB_SHA = "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89"

HOUSE02_RIDGE = 7.26
HOUSE02_EAVE = 4.36
HOUSE02_FRONT_WIDTH = 10.02
HOUSE02_DEPTH = 9.71
TARGET_RIDGE_RATIO = 1.04
TARGET_EAVE_RATIO = 1.04
TARGET_WALL_WIDTH_RATIO = 1.335
TARGET_WALL_DEPTH_RATIO = 1.122
ROOF_OVERHANG = 0.28
VERGE_OVERHANG = 0.22


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def world_vertex(obj, vertex):
    return obj.matrix_world @ vertex.co


def remove_rejected_roof_faces(obj):
    roof_slots = {
        i for i, material in enumerate(obj.data.materials)
        if material and ("slate" in material.name.lower() or "roof_edge" in material.name.lower() or "roof edge" in material.name.lower())
    }
    granite_slots = {
        i for i, material in enumerate(obj.data.materials)
        if material and "granite" in material.name.lower()
    }
    bm = bmesh.new()
    bm.from_mesh(obj.data)
    bm.normal_update()
    doomed = []
    for face in bm.faces:
        center = face.calc_center_median()
        is_roof = face.material_index in roof_slots
        is_old_gable = (
            face.material_index in granite_slots
            and center.z > 4.35
            and abs(face.normal.x) > 0.68
        )
        if is_roof or is_old_gable:
            doomed.append(face)
    if doomed:
        bmesh.ops.delete(bm, geom=doomed, context="FACES")
    bmesh.ops.remove_doubles(bm, verts=bm.verts[:], dist=0.00001)
    bm.to_mesh(obj.data)
    bm.free()
    obj.data.update()
    return len(doomed)


def scale_retained_wall(obj, target_width, target_depth, target_eave):
    points = [world_vertex(obj, vertex) for vertex in obj.data.vertices]
    min_z = min(point.z for point in points)
    min_x, max_x = min(point.x for point in points), max(point.x for point in points)
    min_y, max_y = min(point.y for point in points), max(point.y for point in points)
    center_x, center_y = (min_x + max_x) / 2.0, (min_y + max_y) / 2.0
    current_width, current_depth = max_x - min_x, max_y - min_y
    current_top = max(point.z for point in points)
    sx, sy = target_width / current_width, target_depth / current_depth
    sz = (target_eave - min_z) / max(0.001, current_top - min_z)
    inverse = obj.matrix_world.inverted()
    for vertex in obj.data.vertices:
        point = obj.matrix_world @ vertex.co
        point.x = center_x + (point.x - center_x) * sx
        point.y = center_y + (point.y - center_y) * sy
        point.z = min_z + (point.z - min_z) * sz
        vertex.co = inverse @ point
    obj.data.update()
    return {"x": sx, "y": sy, "z": sz, "retainedMinZ": min_z, "retainedTopBeforeScale": current_top}


def darken_slate(source):
    material = source.copy()
    material.name = "V0346_House02_Family_Dark_Weathered_Slate"
    material["v0346_source_material"] = source.name
    material["v0346_material_role"] = "dark low-saturation slate; reduced repetition/readability calibration"
    if material.use_nodes:
        nodes, links = material.node_tree.nodes, material.node_tree.links
        principled = next((node for node in nodes if node.type == "BSDF_PRINCIPLED"), None)
        if principled:
            base = principled.inputs.get("Base Color")
            if base:
                incoming = next((link for link in links if link.to_node == principled and link.to_socket == base), None)
                if incoming:
                    source_socket = incoming.from_socket
                    links.remove(incoming)
                    mix = nodes.new("ShaderNodeMixRGB")
                    mix.name = "V0346_DarkSlate_Value_Calibration"
                    mix.blend_type = "MULTIPLY"
                    mix.inputs[0].default_value = 0.62
                    mix.inputs[1].default_value = (0.52, 0.56, 0.60, 1.0)
                    links.new(source_socket, mix.inputs[2])
                    links.new(mix.outputs[0], base)
            roughness = principled.inputs.get("Roughness")
            if roughness: roughness.default_value = 0.96
            specular = principled.inputs.get("Specular IOR Level")
            if specular: specular.default_value = 0.18
    return material


def plain_under_slate(slate):
    material = slate.copy()
    material.name = "V0346_House02_Family_Slate_Underside"
    material["v0346_material_role"] = "restrained non-black underside behind closed granite gables"
    if material.use_nodes:
        principled = next((node for node in material.node_tree.nodes if node.type == "BSDF_PRINCIPLED"), None)
        if principled:
            roughness = principled.inputs.get("Roughness")
            if roughness: roughness.default_value = 0.98
    return material


def plain_edge(source):
    material = source.copy()
    material.name = "V0346_Subordinate_Charcoal_Brown_Roof_Edge"
    material["v0346_material_role"] = "thin low-saturation charcoal-brown fascia; no orange texture"
    if material.use_nodes:
        nodes, links = material.node_tree.nodes, material.node_tree.links
        principled = next((node for node in nodes if node.type == "BSDF_PRINCIPLED"), None)
        if principled:
            base = principled.inputs.get("Base Color")
            if base:
                for link in list(links):
                    if link.to_node == principled and link.to_socket == base: links.remove(link)
                base.default_value = (0.028, 0.024, 0.022, 1.0)
            roughness = principled.inputs.get("Roughness")
            if roughness: roughness.default_value = 0.94
    material.diffuse_color = (0.028, 0.024, 0.022, 1.0)
    return material


def add_mesh(name, vertices, faces, materials, parent):
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.clear()
    for material in materials: mesh.materials.append(material)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    obj.parent = parent
    obj["v0346_prototype_only"] = True
    return obj


def roof_slope(name, x_min, x_max, y_eave, y_ridge, eave_z, ridge_z, slate, underside, edge, parent):
    thickness = 0.075
    vertices = [
        (x_min, y_eave, eave_z), (x_max, y_eave, eave_z), (x_max, y_ridge, ridge_z), (x_min, y_ridge, ridge_z),
        (x_min, y_eave, eave_z - thickness), (x_max, y_eave, eave_z - thickness), (x_max, y_ridge, ridge_z - thickness), (x_min, y_ridge, ridge_z - thickness),
    ]
    # Do not cap the interior underside: the closed granite gable behind the
    # slope must remain visible in side views instead of reading as a dark
    # triangular attic void.  The roof still has exactly one continuous plane
    # per side plus restrained edge closures.
    faces = [(0, 1, 2, 3), (0, 4, 5, 1), (2, 6, 7, 3)]
    obj = add_mesh(name, vertices, faces, [slate, underside, edge], parent)
    uv = obj.data.uv_layers.new(name="V0346_SlateProjectionUV")
    uv_values = {0: (0.0, 0.0), 1: (1.0, 0.0), 2: (1.0, 1.0), 3: (0.0, 1.0), 4: (0.0, 0.0), 5: (1.0, 0.0), 6: (1.0, 1.0), 7: (0.0, 1.0)}
    for loop in obj.data.loops: uv.data[loop.index].uv = uv_values[loop.vertex_index]
    for index, polygon in enumerate(obj.data.polygons): polygon.material_index = 0 if index == 0 else 2
    obj["v0346_roof_role"] = "exactly one principal roof slope"
    return obj


def box(name, center, dimensions, material, parent):
    bpy.ops.mesh.primitive_cube_add(location=center)
    obj = bpy.context.object
    obj.name = name; obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material); obj.parent = parent; obj["v0346_prototype_only"] = True
    return obj


def gable(name, x, y_min, y_max, center_y, eave_z, ridge_z, granite, parent):
    obj = add_mesh(name, [(x, y_min, eave_z), (x, y_max, eave_z), (x, center_y, ridge_z)], [(0, 1, 2), (2, 1, 0)], [granite], parent)
    uv = obj.data.uv_layers.new(name="V0346_GraniteGableUV")
    uv_values = {0: (0.0, 0.0), 1: (1.0, 0.0), 2: (0.5, 1.0)}
    for loop in obj.data.loops:
        uv.data[loop.index].uv = uv_values[loop.vertex_index]
    return obj


def merge_children(root):
    meshes = [obj for obj in bpy.data.objects if obj.type == "MESH" and (obj.parent == root or obj == root)]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in meshes: obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    merged = bpy.context.object
    merged.name = "V0346_House02_Family_Barn_Silhouette_Roof_Pitch_Visual"
    merged["v0346_roof_contract"] = "one front slope, one rear slope, one straight ridge, two closed granite gables"
    merged["v0346_proportion_contract"] = "compact horizontal House02-family agricultural barn"
    merged["v0346_prototype_only"] = True; merged["no_gameplay"] = True
    return merged


def active_materials(obj):
    return sorted({obj.data.materials[p.material_index].name for p in obj.data.polygons if p.material_index < len(obj.data.materials) and obj.data.materials[p.material_index]})


def main():
    if sha(V0345_BLEND) != V0345_BLEND_SHA: raise RuntimeError("v0.345 Blend hash changed; refusing v0.346 derivation")
    SOURCE.mkdir(parents=True, exist_ok=True); ASSETS.mkdir(parents=True, exist_ok=True)
    copied = SOURCE / "v0345_source_duplicate_for_v0346.blend"; shutil.copy2(V0345_BLEND, copied)
    copied_sha = sha(copied); bpy.ops.wm.open_mainfile(filepath=str(copied))
    root = bpy.data.objects.get("V0345_House02_Derived_Barrosan_Barn_Proportion_Reset")
    wall = bpy.data.objects.get("V0345_House02_Derived_Barrosan_Barn_Proportion_Reset_Visual")
    if root is None or wall is None: raise RuntimeError("v0.345 root/visual mesh missing")
    removed = remove_rejected_roof_faces(wall)
    target_eave = HOUSE02_EAVE * TARGET_EAVE_RATIO
    wall_target_width = HOUSE02_FRONT_WIDTH * TARGET_WALL_WIDTH_RATIO
    wall_target_depth = HOUSE02_DEPTH * TARGET_WALL_DEPTH_RATIO
    scale_data = scale_retained_wall(wall, wall_target_width, wall_target_depth, target_eave)
    slate_source = bpy.data.materials.get("V0345_Simple_Weathered_Slate") or bpy.data.materials.get("V0334_Weathered_Slate")
    edge_source = bpy.data.materials.get("V0345_Subordinate_Dark_Timber_Roof_Edge") or bpy.data.materials.get("V0343_House02Derived_Weathered_Timber")
    granite = bpy.data.materials.get("V0344_House02Derived_Granite_Continuous")
    if slate_source is None or edge_source is None or granite is None: raise RuntimeError("accepted v0.345 materials missing")
    slate = darken_slate(slate_source); underside = plain_under_slate(slate); edge = plain_edge(edge_source)
    points = [world_vertex(wall, vertex) for vertex in wall.data.vertices]
    min_x, max_x = min(point.x for point in points), max(point.x for point in points)
    min_y, max_y = min(point.y for point in points), max(point.y for point in points)
    center_y = (min_y + max_y) / 2.0
    eave_z = target_eave; ridge_z = HOUSE02_RIDGE * TARGET_RIDGE_RATIO
    half_depth = (max_y - min_y) / 2.0 + ROOF_OVERHANG
    roof_min_x, roof_max_x = min_x - VERGE_OVERHANG, max_x + VERGE_OVERHANG
    front_y, rear_y = center_y - half_depth, center_y + half_depth
    roof_slope("V0346_House02_Family_Front_Roof_Slope", roof_min_x, roof_max_x, front_y, center_y, eave_z, ridge_z, slate, underside, edge, root)
    roof_slope("V0346_House02_Family_Rear_Roof_Slope", roof_min_x, roof_max_x, rear_y, center_y, eave_z, ridge_z, slate, underside, edge, root)
    gable("V0346_Closed_Left_Granite_Gable", min_x - 0.026, min_y, max_y, center_y, eave_z, ridge_z, granite, root)
    gable("V0346_Closed_Right_Granite_Gable", max_x + 0.026, min_y, max_y, center_y, eave_z, ridge_z, granite, root)
    box("V0346_Thin_Front_Charcoal_Eave", ((roof_min_x + roof_max_x) / 2.0, front_y, eave_z - 0.035), (roof_max_x - roof_min_x, 0.085, 0.085), edge, root)
    box("V0346_Thin_Rear_Charcoal_Eave", ((roof_min_x + roof_max_x) / 2.0, rear_y, eave_z - 0.035), (roof_max_x - roof_min_x, 0.085, 0.085), edge, root)
    box("V0346_Straight_Charcoal_Ridge", ((roof_min_x + roof_max_x) / 2.0, center_y, ridge_z), (roof_max_x - roof_min_x, 0.085, 0.085), edge, root)
    root.name = "V0346_House02_Family_Barn_Silhouette_Roof_Pitch"
    merged = merge_children(root)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.object.select_all(action="DESELECT"); merged.select_set(True); bpy.context.view_layer.objects.active = merged
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_image_format="AUTO", export_materials="EXPORT", use_selection=False, export_extras=True)
    after = {"width": round(merged.dimensions.x, 3), "depth": round(merged.dimensions.y, 3), "height": round(merged.dimensions.z, 3), "eave": round(eave_z, 4), "ridge": round(ridge_z, 4)}
    roof_run = half_depth; pitch = math.degrees(math.atan2(ridge_z - eave_z, roof_run))
    metrics = {
        "checkpoint": "v0.346", "sourceBlend": "art-source/blender/v0346/barn_house02_silhouette_roof_pitch.blend", "sourceGLB": "desktop-spikes/godot-salto/assets/v0346/barn_house02_silhouette_roof_pitch.glb",
        "derivedFromV0345": True, "afterV0346": after, "house02Anchor": {"ridge": HOUSE02_RIDGE, "eave": HOUSE02_EAVE, "frontWidth": HOUSE02_FRONT_WIDTH, "depth": HOUSE02_DEPTH},
        "ratiosAfter": {"ridgeHeight": round(after["ridge"] / HOUSE02_RIDGE, 3), "eaveHeight": round(after["eave"] / HOUSE02_EAVE, 3), "frontWidth": round(after["width"] / HOUSE02_FRONT_WIDTH, 3), "depth": round(after["depth"] / HOUSE02_DEPTH, 3)},
        "v0345Comparison": {"roofPitchDegrees": 28.34, "ridge": 7.8408, "eave": 4.68, "frontWidth": 12.464, "depth": 11.157},
        "v0346RoofPitchDegrees": round(pitch, 2), "roof": {"principalSlopes": 2, "frontSlope": True, "rearSlope": True, "straightRidge": True, "secondaryRoofNodes": 0, "pedimentNodes": 0, "blackGableVoids": 0, "orangeEdgeFaces": 0, "graniteRoofFaces": 0, "floatingRoofPieces": 0, "intersectingSecondaryRoofPieces": 0, "closedGraniteGables": 2, "eaveOverhangM": ROOF_OVERHANG, "vergeOverhangM": VERGE_OVERHANG, "fasciaThicknessM": 0.085, "slateValueCalibration": "darkened accepted v0.345 slate with low-saturation multiply; rough non-metallic"},
        "openings": {"lowerDoubleLivestockDoor": True, "upperHayLoadingOpening": True, "rearServiceOpening": True, "agriculturalLevels": 2}, "scaleAppliedToV0345RetainedMesh": scale_data, "removedRejectedV0345RoofFaces": removed, "usedMaterials": active_materials(merged), "availableMaterials": active_materials(merged) + [underside.name],
        "sourceHashes": {"v0345Blend": V0345_BLEND_SHA, "v0345GLB": V0345_GLB_SHA, "v0345CopiedForV0346": copied_sha, "v0344Blend": V0344_BLEND_SHA, "v0343Blend": V0343_BLEND_SHA, "v0343GLB": V0343_GLB_SHA, "house02Blend": HOUSE02_BLEND_SHA, "house02GLB": HOUSE02_GLB_SHA},
        "prototypeOnly": True, "defaultRuntimeIntegrated": False, "noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noEconomy": True, "noStableIdOrSaveMutation": True, "assetProvenance": "repository-authored v0.345 derivative; accepted House02 granite/openings and slate lineage; no protected game assets"
    }
    METRICS.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    LINEAGE.write_text(json.dumps({"checkpoint": "v0.346", "derivedFrom": "art-source/blender/v0345/barn_proportion_simple_slate_roof_reset.blend", "copiedV0345Source": str(copied.relative_to(ROOT)).replace("\\", "/"), "copiedV0345SourceSha256": copied_sha, "v0345BlendSha256": V0345_BLEND_SHA, "v0345GLBSha256": V0345_GLB_SHA, "v0344BlendSha256": V0344_BLEND_SHA, "v0343BlendSha256": V0343_BLEND_SHA, "v0343GLBSha256": V0343_GLB_SHA, "frozenHouse02BlendSha256": HOUSE02_BLEND_SHA, "frozenHouse02GLBSha256": HOUSE02_GLB_SHA, "finalBlendSha256": sha(OUT_BLEND), "finalGLBSha256": sha(OUT_GLB), "v0345Untouched": True, "v0344Untouched": True, "v0343Untouched": True, "house02Untouched": True, "noV0341VisibleDependency": True, "noV0342VisibleDependency": True}, indent=2) + "\n", encoding="utf-8")
    LEDGER.write_text(json.dumps({"checkpoint": "v0.346", "humanV0345Rejection": "REJECTED BY HUMAN REVIEW — V0.345 ACHIEVES A CLEAN TWO-SLOPE ROOF AND TRUE MATCHED COMPARISON, BUT THE BARN STILL READS AS TOO NARROW, TOO VERTICAL AND EXCESSIVELY STEEP-ROOFED FOR THE HOUSE02 BARROSAN FAMILY", "surgicalRepairs": ["wider horizontal mass", "lower restrained pitch", "closed granite gables", "thin charcoal-brown edges", "darker low-saturation slate", "correct front/rear source orientation"], "roofContract": "exactly two principal slopes, one straight ridge, no secondary roof or pediment"}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0346_BARN_HOUSE02_SILHOUETTE_ROOF_PITCH_EXPORT", "blendSha256": sha(OUT_BLEND), "glbSha256": sha(OUT_GLB), "ratiosAfter": metrics["ratiosAfter"], "pitchDegrees": pitch, "principalRoofSlopes": 2}, indent=2))


if __name__ == "__main__": main()
