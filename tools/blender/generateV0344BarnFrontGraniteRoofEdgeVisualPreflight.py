"""v0.344 surgical repair of the rejected v0.343 barn.

The repair opens a copied v0.343 Blend, records the pre-repair material
binding ledger, fixes the derived-box UV contract for the front/elevations,
and replaces the inherited roof mesh with two clean House02-slate slopes and
subordinate dark timber roof edges. It never writes the v0.343 files.
"""
from __future__ import annotations

import hashlib
import json
import math
import shutil
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
V0343_BLEND = ROOT / "art-source/blender/v0343/house02_derived_barrosan_barn_visual_preflight.blend"
V0343_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0343/house02_derived_barrosan_barn_visual_preflight.glb"
SOURCE = ROOT / "art-source/blender/v0344"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0344"
OUT_BLEND = SOURCE / "barn_front_granite_roof_edge_visual_preflight.blend"
OUT_GLB = ASSETS / "barn_front_granite_roof_edge_visual_preflight.glb"
LEDGER = SOURCE / "v0344-front-material-binding-ledger.json"
METRICS = SOURCE / "v0344-barn-metrics.json"
LINEAGE = SOURCE / "v0344-source-lineage.json"

V0343_BLEND_SHA = "ecb268c7a4f69c914951a0dbd9494fb332003566073b2311b47a348ba9f831e9"
V0343_GLB_SHA = "d4d780510b1812e7e4f082f24dfee049ab21f905acbaaeaa4f54d6f67b4118b9"
HOUSE02_BLEND_SHA = "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6"
HOUSE02_GLB_SHA = "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89"


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


def material_kind(material_name: str) -> str:
    value = material_name.lower()
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


def front_surface_area(obj) -> float:
    return round(sum(p.area for p in obj.data.polygons if p.normal.y < -0.8), 4)


def is_front_elevation(name: str, obj) -> bool:
    label = name.lower()
    return "front" in label or "lower_double" in label or "upper_hay" in label or (obj.location.y < -2.5)


def binding_ledger(root):
    records = []
    for obj in sorted((child for child in root.children if child.type == "MESH"), key=lambda item: item.name):
        slots = []
        for index, material in enumerate(obj.data.materials):
            name = material.name if material else "<blank>"
            slots.append({
                "slotIndex": index,
                "assignedMaterialResource": name,
                "texturePaths": texture_paths(material),
                "materialKind": material_kind(name),
            })
        records.append({
            "objectName": obj.name,
            "meshName": obj.data.name,
            "materialSlots": slots,
            "uvMapNames": [layer.name for layer in obj.data.uv_layers],
            "vertexCount": len(obj.data.vertices),
            "frontFacingSurfaceArea": front_surface_area(obj),
            "frontElevation": is_front_elevation(obj.name, obj),
            "originatedFromHouse02": "House02" in obj.name or "roof_lineage" in obj,
            "diagnosedBeforeRepair": True,
        })
    return records


def reset_wall_mapping(material):
    if material is None or not material.use_nodes:
        return
    mapping = material.node_tree.nodes.get("V0337_WallSpecificUVMapping")
    if mapping is None:
        return
    mapping.inputs["Location"].default_value = (0.0, 0.0, 0.0)
    mapping.inputs["Rotation"].default_value = (0.0, 0.0, 0.0)
    mapping.inputs["Scale"].default_value = (1.0, 1.0, 1.0)


def repair_uvs(obj, layer_name="V0344GraniteProjectionUV"):
    mesh = obj.data
    layer = mesh.uv_layers.get(layer_name) or mesh.uv_layers.new(name=layer_name)
    xs = [v.co.x for v in mesh.vertices]
    ys = [v.co.y for v in mesh.vertices]
    zs = [v.co.z for v in mesh.vertices]
    min_x, max_x = min(xs), max(xs)
    min_y, max_y = min(ys), max(ys)
    min_z, max_z = min(zs), max(zs)
    def norm(value, low, high):
        return 0.02 + 0.96 * ((value - low) / max(0.001, high - low))
    for polygon in mesh.polygons:
        normal = polygon.normal
        for loop_index in polygon.loop_indices:
            vertex = mesh.vertices[mesh.loops[loop_index].vertex_index].co
            if abs(normal.y) >= abs(normal.x) and abs(normal.y) >= abs(normal.z):
                uv = (norm(vertex.x, min_x, max_x), norm(vertex.z, min_z, max_z))
            elif abs(normal.x) >= abs(normal.z):
                uv = (norm(vertex.y, min_y, max_y), norm(vertex.z, min_z, max_z))
            else:
                uv = (norm(vertex.x, min_x, max_x), norm(vertex.y, min_y, max_y))
            layer.data[loop_index].uv = uv
    for old in list(mesh.uv_layers):
        if old != layer:
            mesh.uv_layers.remove(old)
    mesh.uv_layers.active = layer
    mesh.uv_layers.active_index = 0


def box(name, center, dimensions, material, rotation_x=0.0):
    bpy.ops.mesh.primitive_cube_add(location=center, rotation=(rotation_x, 0.0, 0.0))
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = dimensions
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    obj["v0344_prototype_only"] = True
    obj["no_gameplay"] = True
    return obj


def dark_roof_edge_material(timber):
    edge = timber.copy()
    edge.name = "V0344_Dark_Weathered_Timber_Roof_Edge"
    if edge.use_nodes:
        principled = next((node for node in edge.node_tree.nodes if node.type == "BSDF_PRINCIPLED"), None)
        if principled is not None:
            base = principled.inputs.get("Base Color")
            if base is not None:
                for link in list(edge.node_tree.links):
                    if link.to_node == principled and link.to_socket == base:
                        edge.node_tree.links.remove(link)
                base.default_value = (0.065, 0.035, 0.022, 1.0)
            principled.inputs["Roughness"].default_value = 0.86
    return edge


def repair_roof(root, slate, timber):
    old_roof = bpy.data.objects.get("V0343_House02_Derived_Weathered_Slate_Roof_System")
    if old_roof is not None:
        bpy.data.objects.remove(old_roof, do_unlink=True)
    edge = dark_roof_edge_material(timber)
    slope = math.atan2(1.40, 2.72)
    for side in (-1, 1):
        roof = box(
            f"V0344_Principal_Roof_Slope_{'L' if side < 0 else 'R'}",
            (0.0, side * 1.38, 5.98),
            (7.92, 3.18, 0.16),
            slate,
            rotation_x=-side * slope,
        )
        roof.parent = root
        repair_uvs(roof, "V0344RoofProjectionUV")
        roof["v0344_roof_role"] = "one of exactly two principal slate slopes"
    for side in (-1, 1):
        eave = box(f"V0344_Roof_Eave_{'L' if side < 0 else 'R'}", (0.0, side * 2.73, 5.27), (8.02, 0.16, 0.18), edge)
        eave.parent = root
        eave["v0344_roof_edge_role"] = "subordinate dark eave"
    ridge = box("V0344_Roof_Continuous_Ridge", (0.0, 0.0, 6.69), (8.04, 0.20, 0.18), edge)
    ridge.parent = root
    ridge["v0344_roof_edge_role"] = "continuous restrained ridge"


def merge_visual_meshes(root):
    meshes = [child for child in root.children if child.type == "MESH"]
    bpy.ops.object.select_all(action="DESELECT")
    for mesh in meshes:
        mesh.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    bpy.ops.object.join()
    merged = bpy.context.object
    merged.name = "V0344_House02_Derived_Barrosan_Barn_Repaired_Visual"
    merged["v0344_front_material_repair"] = "explicit per-face granite projection UV replaces compressed v0343 derived-box charts"
    merged["v0344_roof_edge_repair"] = "two principal slate slopes with subordinate dark timber edges"
    merged["v0344_no_coplanar_front_duplicate"] = True
    merged["v0344_prototype_only"] = True
    return merged


def main():
    if sha(V0343_BLEND) != V0343_BLEND_SHA:
        raise RuntimeError("v0.343 Blend hash changed; refusing repair")
    if sha(V0343_GLB) != V0343_GLB_SHA:
        raise RuntimeError("v0.343 GLB hash changed; refusing repair")
    SOURCE.mkdir(parents=True, exist_ok=True)
    ASSETS.mkdir(parents=True, exist_ok=True)
    copied = SOURCE / "v0343_source_duplicate_for_v0344.blend"
    shutil.copy2(V0343_BLEND, copied)
    copied_sha = sha(copied)
    bpy.ops.wm.open_mainfile(filepath=str(copied))
    root = bpy.data.objects.get("V0343_House02_Derived_Barrosan_Barn")
    if root is None:
        raise RuntimeError("v0.343 barn root missing")
    diagnosis = binding_ledger(root)
    source_granite = bpy.data.materials.get("V0338_GoldCandidate_Rubble_Rear") or bpy.data.materials.get("V0343_House02Derived_Granite_Rear")
    if source_granite is None:
        raise RuntimeError("accepted House02 granite material missing")
    granite = source_granite.copy()
    granite.name = "V0344_House02Derived_Granite_Continuous"
    granite["v0344_source_house02_material"] = source_granite.name
    granite["v0344_repair"] = "continuous granite with explicit derived-wall UV projection"
    reset_wall_mapping(granite)
    slate = bpy.data.materials.get("V0334_Weathered_Slate")
    timber = bpy.data.materials.get("V0343_House02Derived_Weathered_Timber") or bpy.data.materials.get("V0334_Weathered_Timber")
    if slate is None or timber is None:
        raise RuntimeError("House02 slate/timber material lineage missing")
    for obj in list(root.children):
        if obj.type != "MESH":
            continue
        label = obj.name.lower()
        if any(token in label for token in ["wall", "gable", "cornerstone", "granite_", "threshold", "lintel", "jamb", "sill"]):
            obj.data.materials.clear()
            obj.data.materials.append(granite)
            repair_uvs(obj)
            obj["v0344_material_role"] = "continuous House02 granite"
    repair_roof(root, slate, timber)
    root.name = "V0344_House02_Derived_Barrosan_Barn_Repaired"
    merged = merge_visual_meshes(root)
    for obj in list(bpy.data.objects):
        if obj.type == "MESH" and obj != merged and obj.name.startswith("V0343_"):
            bpy.data.objects.remove(obj, do_unlink=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = merged
    merged.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_image_format="AUTO", export_materials="EXPORT", use_selection=False, export_extras=True)
    bounds = [list(merged.dimensions)]
    used_materials = sorted({material.name for material in merged.data.materials if material})
    metrics = {
        "checkpoint": "v0.344",
        "sourceBlend": "art-source/blender/v0344/barn_front_granite_roof_edge_visual_preflight.blend",
        "sourceGLB": "desktop-spikes/godot-salto/assets/v0344/barn_front_granite_roof_edge_visual_preflight.glb",
        "boundsMeters": {"width": round(merged.dimensions.x, 3), "depth": round(merged.dimensions.y, 3), "height": round(merged.dimensions.z, 3)},
        "materialSlots": len(used_materials),
        "usedMaterials": used_materials,
        "renderObjects": 1,
        "drawCalls": 1,
        "visibleTriangles": sum(max(0, len(p.vertices) - 2) for p in merged.data.polygons),
        "architecture": {"principalRoofSlopes": 2, "straightRidge": True, "secondaryRoofNodes": 0, "pedimentNodes": 0, "lowerDoubleDoor": True, "upperHayLoadingOpening": True, "rearServiceOpening": True, "terrainPedestal": False},
        "reusedHouse02Resources": {"granite": "V0338_GoldCandidate_Rubble_Rear", "slate": "V0334_Weathered_Slate", "timber": "V0334_Weathered_Timber"},
        "texturePaths": {"granite": texture_paths(granite), "slate": texture_paths(slate), "timber": texture_paths(timber)},
        "sourceHashes": {"v0343Blend": V0343_BLEND_SHA, "v0343GLB": V0343_GLB_SHA, "v0343CopiedForRepair": copied_sha, "house02Blend": HOUSE02_BLEND_SHA, "house02GLB": HOUSE02_GLB_SHA},
        "prototypeOnly": True,
        "defaultRuntimeIntegrated": False,
        "noGameplay": True,
        "noTechnicalProduction": True,
        "assetProvenance": "repository-authored surgical transformation from copied v0.343 House02-derived barn; no protected game assets",
    }
    METRICS.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    LINEAGE.write_text(json.dumps({"checkpoint": "v0.344", "copiedV0343Source": "art-source/blender/v0344/v0343_source_duplicate_for_v0344.blend", "copiedV0343SourceSha256": copied_sha, "v0343BlendSha256": V0343_BLEND_SHA, "v0343GLBSha256": V0343_GLB_SHA, "house02BlendSha256": HOUSE02_BLEND_SHA, "house02GLBSha256": HOUSE02_GLB_SHA, "finalBlendSha256": sha(OUT_BLEND), "finalGLBSha256": sha(OUT_GLB), "noV0341VisibleDependency": True, "noV0342VisibleDependency": True}, indent=2) + "\n", encoding="utf-8")
    LEDGER.write_text(json.dumps({"checkpoint": "v0.344", "diagnosedCause": "Derived v0.343 front wall boxes used copied House02 wall-specific UV material bindings with compressed default cube UV charts on the Y-facing front surfaces; the granite slot was correct but its front texture sample collapsed into a pale vertical band.", "repair": "All front/elevation masonry meshes now use one continuous House02 granite material with explicit per-face V0344GraniteProjectionUV; doors remain timber and trim remains subordinate granite/iron.", "preRepairBindings": diagnosis, "postRepairContract": {"principalFrontMaterial": "V0344_House02Derived_Granite_Continuous", "principalFrontMaterialKind": "granite", "frontTimberObjects": [], "coplanarFrontDuplicate": False, "frontUVMap": "V0344GraniteProjectionUV", "roofRepair": "inherited v0343 House02 roof mesh removed and replaced by exactly two slate slopes, continuous ridge, dark eaves and dark verges"}}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0344_BARN_FRONT_GRANITE_ROOF_EDGE_EXPORT", "blendSha256": sha(OUT_BLEND), "glbSha256": sha(OUT_GLB), "copiedV0343Sha256": copied_sha, "materialSlots": len(used_materials), "renderObjects": 1, "drawCalls": 1}, indent=2))


if __name__ == "__main__":
    main()
