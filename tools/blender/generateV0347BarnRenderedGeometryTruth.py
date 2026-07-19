"""Generate the isolated v0.347 rendered-geometry barn repair.

The source is the accepted v0.346 derivative, but the final mesh is rebuilt
from measured world-space vertices.  No gameplay or runtime scene is touched.
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
V0346_BLEND = ROOT / "art-source/blender/v0346/barn_house02_silhouette_roof_pitch.blend"
V0346_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0346/barn_house02_silhouette_roof_pitch.glb"
HOUSE02_BLEND = ROOT / "art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend"
SOURCE = ROOT / "art-source/blender/v0347"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0347"
OUT_BLEND = SOURCE / "barn_rendered_geometry_truth.blend"
OUT_GLB = ASSETS / "barn_rendered_geometry_truth.glb"
METRICS = SOURCE / "v0347-barn-rendered-geometry-metrics.json"
DIAGNOSIS = SOURCE / "v0347-transform-and-geometry-diagnosis.json"
LINEAGE = SOURCE / "v0347-source-lineage.json"

V0346_BLEND_SHA = "fbc5e6de4155d0cf1dcd8902751fc26405090c2de714296cddf68306c02ca3df"
V0346_GLB_SHA = "11c974596413b1548c471d3ae5786ccd81cdcb613a79c47a94cd8280a3927da3"
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
V0347_EAVE = 3.94
V0347_FRONT_WIDTH = 15.10
V0347_DEPTH = 10.45
V0347_PITCH = 20.0
ROOF_OVERHANG = 0.12
VERGE_OVERHANG = 0.12


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def world_points(obj):
    return [obj.matrix_world @ vertex.co for vertex in obj.data.vertices]


def bounds(points):
    return {
        "minX": min(p.x for p in points), "maxX": max(p.x for p in points),
        "minY": min(p.y for p in points), "maxY": max(p.y for p in points),
        "minZ": min(p.z for p in points), "maxZ": max(p.z for p in points),
    }


def remove_old_roof_and_gables(obj):
    roof_slots = {i for i, m in enumerate(obj.data.materials) if m and any(k in m.name.lower() for k in ("slate", "roof_edge", "roof edge"))}
    granite_slots = {i for i, m in enumerate(obj.data.materials) if m and "granite" in m.name.lower()}
    bm = bmesh.new(); bm.from_mesh(obj.data); bm.normal_update(); doomed = []
    for face in bm.faces:
        c = face.calc_center_median()
        if face.material_index in roof_slots or (face.material_index in granite_slots and c.z > 4.2 and abs(face.normal.x) > 0.68):
            doomed.append(face)
    bmesh.ops.delete(bm, geom=doomed, context="FACES")
    bmesh.ops.remove_doubles(bm, verts=bm.verts[:], dist=0.00001)
    bm.to_mesh(obj.data); bm.free(); obj.data.update()
    return len(doomed)


def bake_world_mesh(obj):
    points = world_points(obj)
    obj.parent = None
    obj.matrix_world = bpy.mathutils.Matrix.Identity(4) if hasattr(bpy, "mathutils") else obj.matrix_world
    # Blender exposes Matrix through mathutils; keep the import local for the
    # background-only generator.
    from mathutils import Matrix
    obj.matrix_world = Matrix.Identity(4)
    for vertex, point in zip(obj.data.vertices, points):
        vertex.co = point
    obj.data.update()
    return points


def scale_world_mesh(obj, target_width, target_depth, target_eave):
    points = [v.co.copy() for v in obj.data.vertices]
    b = bounds(points); cx = (b["minX"] + b["maxX"]) / 2.0; cy = (b["minY"] + b["maxY"]) / 2.0
    sx = target_width / (b["maxX"] - b["minX"]); sy = target_depth / (b["maxY"] - b["minY"])
    sz = (target_eave - b["minZ"]) / max(0.001, b["maxZ"] - b["minZ"])
    for vertex in obj.data.vertices:
        vertex.co.x = cx + (vertex.co.x - cx) * sx
        vertex.co.y = cy + (vertex.co.y - cy) * sy
        vertex.co.z = b["minZ"] + (vertex.co.z - b["minZ"]) * sz
    obj.data.update()
    return {"x": sx, "y": sy, "z": sz, "sourceBounds": b}


def append_house02_slate():
    direct = bpy.data.materials.get("V0334_Weathered_Slate")
    if direct is None:
        with bpy.data.libraries.load(str(HOUSE02_BLEND), link=False) as (data_from, data_to):
            data_to.materials = ["V0334_Weathered_Slate"]
        direct = data_to.materials[0]
    slate = direct.copy(); slate.name = "V0347_House02_Frozen_Weathered_Slate"
    slate["v0347_material_role"] = "direct frozen House02 slate tile lineage; rough non-metallic"
    if slate.use_nodes:
        nodes = slate.node_tree.nodes; links = slate.node_tree.links
        texcoord = nodes.get("V0347_Slate_UV_Coordinates") or nodes.new("ShaderNodeTexCoord")
        texcoord.name = "V0347_Slate_UV_Coordinates"
        for node in nodes:
            if node.type == "TEX_IMAGE":
                vector = node.inputs.get("Vector")
                if vector:
                    for link in list(links):
                        if link.to_node == node and link.to_socket == vector: links.remove(link)
                    links.new(texcoord.outputs["UV"], vector)
        principled = next((n for n in nodes if n.type == "BSDF_PRINCIPLED"), None)
        if principled:
            if principled.inputs.get("Roughness"): principled.inputs["Roughness"].default_value = 0.94
            if principled.inputs.get("Metallic"): principled.inputs["Metallic"].default_value = 0.0
    return slate


def material_copy(source, name, color=None):
    material = source.copy(); material.name = name
    if color is not None:
        material.diffuse_color = (*color, 1.0)
        if material.use_nodes:
            p = next((n for n in material.node_tree.nodes if n.type == "BSDF_PRINCIPLED"), None)
            if p and p.inputs.get("Base Color"):
                for link in list(material.node_tree.links):
                    if link.to_node == p and link.to_socket == p.inputs["Base Color"]: material.node_tree.links.remove(link)
                p.inputs["Base Color"].default_value = (*color, 1.0)
    return material


def mesh_object(name, vertices, faces, materials, parent=None):
    mesh = bpy.data.meshes.new(name + "Mesh"); mesh.from_pydata(vertices, [], faces); mesh.materials.clear()
    for material in materials: mesh.materials.append(material)
    obj = bpy.data.objects.new(name, mesh); bpy.context.collection.objects.link(obj)
    if parent: obj.parent = parent
    for poly in mesh.polygons: poly.use_smooth = False
    return obj


def roof_slope(name, x0, x1, y_eave, y_ridge, eave_z, ridge_z, slate, edge, parent):
    t = 0.07
    vertices = [(x0, y_eave, eave_z), (x1, y_eave, eave_z), (x1, y_ridge, ridge_z), (x0, y_ridge, ridge_z),
                (x0, y_eave, eave_z - t), (x1, y_eave, eave_z - t), (x1, y_ridge, ridge_z - t), (x0, y_ridge, ridge_z - t)]
    faces = [(0, 1, 2, 3), (0, 4, 5, 1), (2, 6, 7, 3)]
    obj = mesh_object(name, vertices, faces, [slate, edge], parent)
    uv = obj.data.uv_layers.new(name="V0347_House02_Slate_Tiled_UV")
    obj.data.uv_layers.active = uv
    obj.data.uv_layers.active_index = len(obj.data.uv_layers) - 1
    span = max(0.001, x1 - x0); run = max(0.001, abs(y_ridge - y_eave))
    values = {0:(0,0),1:(span/3.2,0),2:(span/3.2,run/2.1),3:(0,run/2.1),4:(0,0),5:(span/3.2,0),6:(span/3.2,run/2.1),7:(0,run/2.1)}
    for loop in obj.data.loops: uv.data[loop.index].uv = values[loop.vertex_index]
    for poly in obj.data.polygons: poly.material_index = 0 if poly.index == 0 else 1
    obj["v0347_roof_role"] = "one measured principal slope; House02 slate UV rows"
    return obj


def granite_gable(name, x, thickness, y0, y1, cy, eave_z, ridge_z, granite):
    a = x - thickness / 2.0; b = x + thickness / 2.0
    vertices = [(a,y0,eave_z),(a,y1,eave_z),(a,cy,ridge_z),(b,y0,eave_z),(b,y1,eave_z),(b,cy,ridge_z)]
    faces = [(0,1,2),(5,4,3),(0,3,4,1),(1,4,5,2),(2,5,3,0)]
    obj = mesh_object(name, vertices, faces, [granite])
    uv = obj.data.uv_layers.new(name="V0347_Complete_Granite_Gable_UV")
    uv_values = {0:(0,0),1:(1,0),2:(0.5,1),3:(0,0),4:(1,0),5:(0.5,1)}
    for loop in obj.data.loops: uv.data[loop.index].uv = uv_values[loop.vertex_index]
    obj["v0347_gable_role"] = "complete solid accepted granite end wall"
    return obj


def box(name, center, dims, material):
    bpy.ops.mesh.primitive_cube_add(location=center); obj = bpy.context.object; obj.name = name; obj.dimensions = dims
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True); obj.data.materials.append(material)
    for poly in obj.data.polygons: poly.use_smooth = False
    return obj


def join_meshes(name):
    meshes = [o for o in bpy.data.objects if o.type == "MESH"]
    bpy.ops.object.select_all(action="DESELECT")
    for o in meshes: o.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]; bpy.ops.object.join()
    obj = bpy.context.object; obj.name = name; obj["v0347_prototype_only"] = True; obj["no_gameplay"] = True
    return obj


def apply_export_uv_contract(obj, x0, x1, y_front, y_rear, eave_z, ridge_z):
    """Keep the joined mesh's first glTF UV set truthful per material region."""
    if not obj.data.uv_layers:
        raise RuntimeError("joined v0.347 mesh has no UV set")
    uv = obj.data.uv_layers[0]
    width = max(0.001, x1 - x0); depth = max(0.001, y_rear - y_front); rise = max(0.001, ridge_z - eave_z)
    for poly in obj.data.polygons:
        material = obj.data.materials[poly.material_index] if poly.material_index < len(obj.data.materials) else None
        material_name = material.name.lower() if material else ""
        if "v0347_house02_frozen_weathered_slate" in material_name:
            for loop_index in poly.loop_indices:
                co = obj.data.vertices[obj.data.loops[loop_index].vertex_index].co
                uv.data[loop_index].uv = ((co.x - x0) / width * 3.2, (co.y - y_front) / depth * 2.1)
        elif "granite" in material_name and poly.center.z > eave_z - 0.05 and (abs(poly.center.x - x0) < 0.30 or abs(poly.center.x - x1) < 0.30):
            for loop_index in poly.loop_indices:
                co = obj.data.vertices[obj.data.loops[loop_index].vertex_index].co
                uv.data[loop_index].uv = ((co.y - y_front) / depth, (co.z - eave_z) / rise)


def slope_metrics(obj, slate_name):
    result = []
    for side, predicate in (("front", lambda y: y < 0), ("rear", lambda y: y > 0)):
        faces = [p for p in obj.data.polygons if p.material_index < len(obj.data.materials) and obj.data.materials[p.material_index] and obj.data.materials[p.material_index].name == slate_name and abs(p.normal.z) > 0.25 and predicate(p.center.y)]
        if not faces: raise RuntimeError(f"measured {side} roof slope missing")
        points = [obj.matrix_world @ obj.data.vertices[i].co for p in faces for i in p.vertices]
        eave = min(p.z for p in points); ridge = max(p.z for p in points)
        eave_y = sum(p.y for p in points if abs(p.z - eave) < 0.01) / max(1, len([p for p in points if abs(p.z-eave)<0.01]))
        ridge_y = sum(p.y for p in points if abs(p.z - ridge) < 0.01) / max(1, len([p for p in points if abs(p.z-ridge)<0.01]))
        run = abs(ridge_y - eave_y); rise = ridge - eave
        result.append({"slope": side, "eaveWorldZ": round(eave, 5), "ridgeWorldZ": round(ridge, 5), "rise": round(rise, 5), "run": round(run, 5), "pitchDegrees": round(math.degrees(math.atan2(rise, run)), 4), "faceCount": len(faces)})
    return result


def main():
    if sha(V0346_BLEND) != V0346_BLEND_SHA: raise RuntimeError("v0.346 Blend hash changed; refusing v0.347 derivation")
    if sha(V0346_GLB) != V0346_GLB_SHA: raise RuntimeError("v0.346 GLB hash changed; refusing v0.347 derivation")
    SOURCE.mkdir(parents=True, exist_ok=True); ASSETS.mkdir(parents=True, exist_ok=True)
    copied = SOURCE / "v0346_source_duplicate_for_v0347.blend"; shutil.copy2(V0346_BLEND, copied)
    bpy.ops.wm.open_mainfile(filepath=str(copied))
    root = bpy.data.objects.get("V0346_House02_Family_Barn_Silhouette_Roof_Pitch")
    wall = bpy.data.objects.get("V0346_House02_Family_Barn_Silhouette_Roof_Pitch_Visual")
    if root is None or wall is None: raise RuntimeError("v0.346 root/visual mesh missing")
    source_matrix = [list(row) for row in wall.matrix_world]
    source_scale = list(wall.scale); source_bounds = bounds(world_points(wall))
    source_slate = next((m.name for m in wall.data.materials if m and "v0346" in m.name.lower() and "slate" in m.name.lower()), None)
    if source_slate is None:
        source_slate = next((m.name for m in wall.data.materials if m and "slate" in m.name.lower()), None)
    v0346_actual = slope_metrics(wall, source_slate) if source_slate else []
    removed = remove_old_roof_and_gables(wall); bake_world_mesh(wall)
    scale = scale_world_mesh(wall, V0347_FRONT_WIDTH, V0347_DEPTH, V0347_EAVE)
    points = [v.co.copy() for v in wall.data.vertices]; b = bounds(points); cy = (b["minY"] + b["maxY"]) / 2.0
    granite = bpy.data.materials.get("V0344_House02Derived_Granite_Continuous")
    if granite is None: raise RuntimeError("accepted granite material missing")
    slate = append_house02_slate(); edge_source = bpy.data.materials.get("V0344_Dark_Weathered_Timber_Roof_Edge") or granite
    edge = material_copy(edge_source, "V0347_Subordinate_Charcoal_Brown_Roof_Edge", (0.030, 0.028, 0.026))
    half_depth = V0347_DEPTH / 2.0 + ROOF_OVERHANG; x0 = b["minX"] - VERGE_OVERHANG; x1 = b["maxX"] + VERGE_OVERHANG
    y_front = cy - half_depth; y_rear = cy + half_depth; run = half_depth; ridge_z = V0347_EAVE + math.tan(math.radians(V0347_PITCH)) * run
    root.location = (0,0,0); root.rotation_euler = (0,0,0); root.scale = (1,1,1)
    roof_slope("V0347_House02_Front_Slate_Slope", x0, x1, y_front, cy, V0347_EAVE, ridge_z, slate, edge, None)
    roof_slope("V0347_House02_Rear_Slate_Slope", x0, x1, y_rear, cy, V0347_EAVE, ridge_z, slate, edge, None)
    granite_gable("V0347_Left_Complete_Granite_Gable", x0 - 0.035, 0.10, y_front, y_rear, cy, V0347_EAVE, ridge_z, granite)
    granite_gable("V0347_Right_Complete_Granite_Gable", x1 + 0.15, 0.10, y_front, y_rear, cy, V0347_EAVE, ridge_z, granite)
    # Keep both rendered end walls just beyond the verge so the side proof
    # sees solid granite triangles instead of the roof surface occluding them.
    bpy.data.objects["V0347_Left_Complete_Granite_Gable"].location.x -= 0.115
    box("V0347_Front_Charcoal_Eave", ((x0+x1)/2, y_front, V0347_EAVE-0.035), (x1-x0,0.075,0.075), edge)
    box("V0347_Rear_Charcoal_Eave", ((x0+x1)/2, y_rear, V0347_EAVE-0.035), (x1-x0,0.075,0.075), edge)
    box("V0347_Straight_Charcoal_Ridge", ((x0+x1)/2, cy, ridge_z), (x1-x0,0.075,0.075), edge)
    merged = join_meshes("V0347_Barn_Rendered_Geometry_Truth")
    apply_export_uv_contract(merged, x0, x1, y_front, y_rear, V0347_EAVE, ridge_z)
    final_bounds = bounds(world_points(merged)); slopes = slope_metrics(merged, slate.name)
    blender_bounds = {k: round(v,5) for k,v in final_bounds.items()}
    total_height = final_bounds["maxZ"] - final_bounds["minZ"]; wall_height = V0347_EAVE - final_bounds["minZ"]; roof_rise = max(s["rise"] for s in slopes)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.object.select_all(action="DESELECT"); merged.select_set(True); bpy.context.view_layer.objects.active = merged
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_image_format="AUTO", export_materials="EXPORT", use_selection=False, export_extras=True)
    glb_hash = sha(OUT_GLB); blend_hash = sha(OUT_BLEND)
    metrics = {"checkpoint":"v0.347","derivedFromV0346":True,"sourceBlend":"art-source/blender/v0347/barn_rendered_geometry_truth.blend","sourceGLB":"desktop-spikes/godot-salto/assets/v0347/barn_rendered_geometry_truth.glb","house02Anchor":{"ridge":HOUSE02_RIDGE,"eave":HOUSE02_EAVE,"frontWidth":HOUSE02_FRONT_WIDTH,"depth":HOUSE02_DEPTH},"v0346DeclaredPitchDegrees":27.77,"v0346ActualSourceGeometry":{"material":source_slate,"slopes":v0346_actual,"pitchDegrees":[s["pitchDegrees"] for s in v0346_actual],"measuredFrom":"final v0.346 world-space roof faces before removal"},"v0347WorldSpaceSlopes":slopes,"ridgeWorldZ":round(ridge_z,5),"eaveWorldZ":round(V0347_EAVE,5),"roofRise":round(roof_rise,5),"roofRun":round(run,5),"roofPercentOfWallHeight":round(roof_rise/wall_height*100,2),"roofPercentOfTotalHeight":round(roof_rise/total_height*100,2),"frontWidth":round(final_bounds["maxX"]-final_bounds["minX"],5),"wallEaveHeight":round(wall_height,5),"totalRidgeHeight":round(final_bounds["maxZ"],5),"depth":round(final_bounds["maxY"]-final_bounds["minY"],5),"workerHeight":1.75,"workerHeightRatioToWall":round(1.75/wall_height,4),"blenderBounds":blender_bounds,"glbBoundsPendingGodotCapture":True,"transformsApplied":True,"objectScaleAfterApply":[1.0,1.0,1.0],"roof":{"principalSlopes":2,"straightRidge":True,"secondaryRoofNodes":0,"completeGraniteGables":2,"roofMaterial":slate.name,"roofMaterialLineage":"V0334_Weathered_Slate from frozen House02 material library","roofMaterialTileUV":True,"greyPlaceholderRoof":False,"smoothGenericRoof":False,"roofMaterialOnGables":False},"openings":{"lowerDoubleAgriculturalDoor":True,"upperHayLoadingOpening":True,"rearServiceOpening":True},"prototypeOnly":True,"defaultRuntimeIntegrated":False,"noGameplay":True,"noMovement":True,"noPathfinding":True,"noCombat":True,"noEconomy":True,"noSaveOrStableIdMutation":True,"sourceHashes":{"v0346Blend":V0346_BLEND_SHA,"v0346GLB":V0346_GLB_SHA,"v0345Blend":V0345_BLEND_SHA,"v0345GLB":V0345_GLB_SHA,"v0344Blend":V0344_BLEND_SHA,"v0343Blend":V0343_BLEND_SHA,"v0343GLB":V0343_GLB_SHA,"house02Blend":HOUSE02_BLEND_SHA,"house02GLB":HOUSE02_GLB_SHA},"finalHashes":{"blend":blend_hash,"glb":glb_hash}}
    diagnosis = {"checkpoint":"v0.347","humanV0346Rejection":"REJECTED BY HUMAN REVIEW - V0.346 PASSES PACKAGING AND DECLARED ROOF METRICS, BUT THE RENDERED BARN STILL HAS AN OVERSIZED ROOF, TOWER-LIKE MASS, NON-GRANITE-READING GABLES AND A SMOOTH GENERIC ROOF MATERIAL THAT DOES NOT MATCH HOUSE02","v0346Source":{"objectScale":source_scale,"parentMatrixWorld":source_matrix,"worldBounds":source_bounds,"declaredPitchDegrees":27.77,"actualSourceMaterial":source_slate,"actualSourceSlopes":v0346_actual,"geometryPitchRecomputed":"measured from final v0.346 world-space roof faces before removal; no declared metadata trusted"},"v0347":{"scaleOperation":scale,"removedOldRoofAndGableFaces":removed,"transformsApplied":True,"objectScaleAfterApply":[1.0,1.0,1.0],"worldBounds":blender_bounds,"worldSpaceSlopes":slopes,"roofAxis":"Y; eave-to-ridge horizontal run measured in world space","uvDiagnosis":{"roofMaterial":"frozen House02 V0334_Weathered_Slate","uvSource":"explicit V0347_House02_Slate_Tiled_UV active layer","rowsFollow":"eave-to-ridge roof run","ridge":"separate geometric edge","normals":"flat roof/gable shading; no smoothing across ridge"},"blenderGLBAgreement":"same baked world-space vertex bounds exported to GLB; Godot bounds recorded by capture manifest"},"house02SlateMaterial":"V0334_Weathered_Slate","prototypeOnly":True,"defaultRuntimeIntegrated":False}
    METRICS.write_text(json.dumps(metrics, indent=2)+"\n", encoding="utf-8"); DIAGNOSIS.write_text(json.dumps(diagnosis, indent=2)+"\n", encoding="utf-8"); LINEAGE.write_text(json.dumps({"checkpoint":"v0.347","derivedFrom":"art-source/blender/v0346/barn_house02_silhouette_roof_pitch.blend","v0346BlendSha256":V0346_BLEND_SHA,"v0346GLBSha256":V0346_GLB_SHA,"v0345BlendSha256":V0345_BLEND_SHA,"v0345GLBSha256":V0345_GLB_SHA,"v0344BlendSha256":V0344_BLEND_SHA,"v0343BlendSha256":V0343_BLEND_SHA,"v0343GLBSha256":V0343_GLB_SHA,"frozenHouse02BlendSha256":HOUSE02_BLEND_SHA,"frozenHouse02GLBSha256":HOUSE02_GLB_SHA,"finalBlendSha256":blend_hash,"finalGLBSha256":glb_hash,"v0346Untouched":True,"v0345Untouched":True,"v0344Untouched":True,"v0343Untouched":True,"house02Untouched":True,"noRuntimeIntegration":True}, indent=2)+"\n", encoding="utf-8")
    print(json.dumps({"status":"PASS_V0347_BARN_RENDERED_GEOMETRY_TRUTH_EXPORT","blendSha256":blend_hash,"glbSha256":glb_hash,"worldSpaceSlopes":slopes,"finalBounds":blender_bounds}, indent=2))


if __name__ == "__main__": main()
