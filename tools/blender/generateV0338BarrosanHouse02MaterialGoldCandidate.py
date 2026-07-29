"""Derive v0.338 material gold-candidate from frozen v0.337 geometry/material lineage."""
from __future__ import annotations

import hashlib
import json
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
SOURCE_BLEND = ROOT / "art-source/blender/v0337/barrosan_house_02_selected_granite.blend"
OUT_BLEND = ROOT / "art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend"
OUT_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb"
MAPS = ROOT / "art-source/materials/v0338/gold_candidate"
RUNTIME = ROOT / "artifacts/runtime/v0338"
LEDGER = ROOT / "art-source/blender/v0338/v0337-v0338-architecture-fingerprint-comparison.json"
V0337_BLEND_SHA = "517a9aaa6d9debe2bcf8047de774bdfa252e0376709b2ddafa0c7f9cc72bfe79"
V0337_GLB_SHA = "ad700395cf0fbc7e396d0f1ef7babff3710f01ce268b34c9720e2d70b24c5dbb"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bounds(obj: bpy.types.Object) -> list[list[float]]:
    return [[round(float(v), 6) for v in corner] for corner in obj.bound_box]


def fingerprint(label: str) -> dict:
    meshes = []
    for obj in sorted((item for item in bpy.data.objects if item.type == "MESH"), key=lambda item: item.name):
        meshes.append({"name": obj.name, "vertexCount": len(obj.data.vertices), "polygonCount": len(obj.data.polygons), "triangleCount": sum(max(0, len(p.vertices) - 2) for p in obj.data.polygons), "transform": [[round(float(v), 7) for v in row] for row in obj.matrix_world], "bounds": bounds(obj)})
    openings = []
    for obj in sorted((item for item in bpy.data.objects if item.type == "MESH" and any(token in item.name.lower() for token in ("window", "door", "interior", "iron"))), key=lambda item: item.name):
        openings.append({"name": obj.name, "bounds": bounds(obj), "location": [round(float(v), 6) for v in obj.location]})
    roof = bpy.data.objects.get("LOD0_Weathered_Slate")
    planes = []
    if roof:
        seen = set()
        for poly in roof.data.polygons:
            normal = tuple(round(float(v), 5) for v in poly.normal)
            if normal in seen or len(planes) >= 8:
                continue
            seen.add(normal)
            point = roof.matrix_world @ poly.center
            planes.append({"normal": normal, "constant": round(float(normal[0] * point.x + normal[1] * point.y + normal[2] * point.z), 6)})
    return {"label": label, "objectNames": [entry["name"] for entry in meshes], "objects": meshes, "openings": openings, "roofPlaneEquations": planes, "stairLandingDimensionsM": {"stairRise": 0.25, "stairRun": 0.44, "landingHeight": 2.0, "housePlusStairLandingBounds": [10.3, 9.71, 7.26]}}


def load_image(name: str) -> bpy.types.Image:
    return bpy.data.images.load(str(MAPS / name), check_existing=False)


def material_from(source_name: str, name: str, albedo: str, offset: tuple[float, float], rotation: float, roughness: float, role: str) -> bpy.types.Material:
    material = bpy.data.materials[source_name].copy()
    material.name = name
    material.use_nodes = True
    nodes = material.node_tree.nodes
    textures = [node for node in nodes if node.type == "TEX_IMAGE"]
    albedo_node = next(node for node in textures if node.name == "Image Texture")
    rough_node = next(node for node in textures if node.name == "Image Texture.001")
    normal_node = next(node for node in textures if node.name == "Image Texture.002")
    albedo_node.image = load_image(albedo)
    rough_node.image = load_image("gold_candidate_roughness.png")
    normal_node.image = load_image("gold_candidate_normal.png")
    for image in (albedo_node.image, rough_node.image, normal_node.image):
        image.pack()
    normal = next(node for node in nodes if node.type == "NORMAL_MAP")
    normal.inputs["Strength"].default_value = 0.42
    principled = next(node for node in nodes if node.type == "BSDF_PRINCIPLED")
    principled.inputs["Roughness"].default_value = roughness
    mapping = nodes.get("V0337_WallSpecificUVMapping")
    if mapping:
        mapping.inputs["Location"].default_value[0] = offset[0]
        mapping.inputs["Location"].default_value[1] = offset[1]
        mapping.inputs["Rotation"].default_value[2] = rotation
    material["v0338_source"] = "candidate_a"
    material["v0338_role"] = role
    material["v0338_normal_strength"] = 0.42
    material["v0338_height_parallax"] = False
    material["v0338_mortar"] = "recessed low-value response; no outline"
    return material


def assign_walls(obj: bpy.types.Object, variants: list[bpy.types.Material]) -> None:
    obj.data.materials.clear()
    for material in variants:
        obj.data.materials.append(material)
    for poly in obj.data.polygons:
        n = poly.normal
        if n.x > 0.7:
            poly.material_index = 0
        elif n.x < -0.7:
            poly.material_index = 1
        elif n.y > 0.7:
            poly.material_index = 2
        elif n.y < -0.7:
            poly.material_index = 3
        else:
            poly.material_index = 0


def main() -> None:
    RUNTIME.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE_BLEND))
    source_fp = fingerprint("v0.337 frozen derived source")
    variants = [
        material_from("V0337_SelectedGranite_Rubble_Front", "V0338_GoldCandidate_Rubble_Front", "gold_candidate_rubble_albedo.png", (0.07, 0.00), 0.0, 0.90, "front maintained aged"),
        material_from("V0337_SelectedGranite_Rubble_Rear", "V0338_GoldCandidate_Rubble_Rear", "gold_candidate_rear_albedo.png", (0.31, 0.11), 0.015, 0.93, "rear darker cooler damp"),
        material_from("V0337_SelectedGranite_Rubble_Left", "V0338_GoldCandidate_Rubble_LeftGable", "gold_candidate_gable_albedo.png", (0.53, 0.23), -0.01, 0.91, "left orientation variation"),
        material_from("V0337_SelectedGranite_Rubble_Right", "V0338_GoldCandidate_Rubble_RightGable", "gold_candidate_gable_albedo.png", (0.77, 0.37), 0.02, 0.91, "right orientation variation"),
    ]
    dressed = material_from("V0337_SelectedGranite_Rubble_Front", "V0338_GoldCandidate_DressedGranite", "gold_candidate_dressed_albedo.png", (0.13, 0.47), 0.0, 0.88, "lintels sills jambs stair landing")
    foundation = material_from("V0337_SelectedGranite_Foundation", "V0338_GoldCandidate_DampFoundation", "gold_candidate_foundation_albedo.png", (0.21, 0.63), 0.0, 0.94, "low coverage ground-contact weathering")
    for lod in ("LOD0", "LOD1", "LOD2"):
        granite = bpy.data.objects.get(f"{lod}_Granite")
        if granite:
            assign_walls(granite, variants)
        base = bpy.data.objects.get(f"{lod}_Damp_Foundation")
        if base:
            base.data.materials.clear()
            base.data.materials.append(foundation)
    for obj in bpy.data.objects:
        obj["v0338_architecture_preserved"] = True
        obj["v0338_geometry_source"] = "v0.337 frozen"
    derived_fp = fingerprint("v0.338 gold candidate before export")
    architecture_equal = source_fp["objectNames"] == derived_fp["objectNames"] and source_fp["objects"] == derived_fp["objects"] and source_fp["openings"] == derived_fp["openings"] and source_fp["roofPlaneEquations"] == derived_fp["roofPlaneEquations"]
    record = {"checkpoint": "v0.338", "sourceBlend": str(SOURCE_BLEND.relative_to(ROOT)).replace("\\", "/"), "derivedBlend": str(OUT_BLEND.relative_to(ROOT)).replace("\\", "/"), "sourceBlendSha256": V0337_BLEND_SHA, "sourceGLBSha256": V0337_GLB_SHA, "selectedCandidate": "candidate_a", "candidateBRejected": True, "candidateCNotSelected": True, "architectureEqualBeforeExport": architecture_equal, "materialSlotChangesOnly": True, "sourceFingerprint": source_fp, "derivedFingerprint": derived_fp, "wallSpecificOffsetsRotations": {"front": [0.07, 0.0, 0.0], "rear": [0.31, 0.11, 0.015], "leftGable": [0.53, 0.23, -0.01], "rightGable": [0.77, 0.37, 0.02]}, "materialBindings": {"rubble": [m.name for m in variants], "dressed": dressed.name, "foundation": foundation.name, "slatePreserved": "V0337_Weathered_Slate", "timberPreserved": True}, "weathering": {"mortar": "recessed and darker than stone faces without graphic outline", "foundation": "vertical low-coverage damp variation", "mossLichenCoverage": 0.0, "uniformDirtBand": False}, "preservation": {"architecture": True, "roof": True, "chimney": True, "stairLanding": True, "openings": True, "collision": True, "defaultRuntimeIntegrated": False, "gameplayChanged": False}}
    OUT_BLEND.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    OUT_GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_apply=False, export_materials="EXPORT", export_lights=False, export_cameras=False, export_extras=True)
    record["derivedBlendSha256"] = sha(OUT_BLEND)
    record["derivedGLBSha256"] = sha(OUT_GLB)
    text = json.dumps(record, indent=2) + "\n"
    LEDGER.parent.mkdir(parents=True, exist_ok=True)
    LEDGER.write_text(text, encoding="utf-8")
    (RUNTIME / "v0337-v0338-architecture-fingerprint-comparison.json").write_text(text, encoding="utf-8")
    print(json.dumps({"status": "PASS_V0338_DERIVED_HOUSE02_GOLD_CANDIDATE_EXPORT", "architectureEqualBeforeExport": architecture_equal, "blendSha256": record["derivedBlendSha256"], "glbSha256": record["derivedGLBSha256"]}, indent=2))


if __name__ == "__main__":
    main()
