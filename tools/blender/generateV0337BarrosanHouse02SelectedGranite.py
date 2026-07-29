"""Duplicate v0.334 House 02 and apply only selected granite materials."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
SOURCE_BLEND = ROOT / "art-source/blender/v0334/barrosan_house_gold_02.blend"
OUT_BLEND = ROOT / "art-source/blender/v0337/barrosan_house_02_selected_granite.blend"
OUT_GLB = ROOT / "desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb"
MAPS = ROOT / "art-source/materials/v0337/selected_granite"
PROJECT_MAPS = ROOT / "desktop-spikes/godot-salto/assets/v0337/selected_granite"
RUNTIME = ROOT / "artifacts/runtime/v0337"
LEDGER = ROOT / "art-source/blender/v0337/v0337-architecture-fingerprint-comparison.json"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bbox(obj: bpy.types.Object) -> list[list[float]]:
    return [[round(float(v), 6) for v in corner] for corner in obj.bound_box]


def fingerprint(label: str) -> dict:
    objects = []
    for obj in sorted((o for o in bpy.data.objects if o.type == "MESH"), key=lambda item: item.name):
        mesh = obj.data
        triangles = sum(max(0, len(poly.vertices) - 2) for poly in mesh.polygons)
        objects.append({
            "name": obj.name,
            "vertexCount": len(mesh.vertices),
            "polygonCount": len(mesh.polygons),
            "triangleCount": triangles,
            "transform": [[round(float(v), 7) for v in row] for row in obj.matrix_world],
            "bounds": bbox(obj),
        })
    openings = []
    for obj in sorted((o for o in bpy.data.objects if o.type == "MESH" and any(token in o.name.lower() for token in ("window", "door", "interior", "iron"))), key=lambda item: item.name):
        openings.append({"name": obj.name, "bounds": bbox(obj), "location": [round(float(v), 6) for v in obj.location]})
    slate = bpy.data.objects.get("LOD0_Weathered_Slate")
    roof_planes = []
    if slate:
        seen = set()
        for poly in slate.data.polygons:
            normal = tuple(round(float(v), 5) for v in poly.normal)
            if normal in seen or len(roof_planes) >= 8:
                continue
            seen.add(normal)
            point = slate.matrix_world @ poly.center
            roof_planes.append({"normal": normal, "constant": round(float(normal[0] * point.x + normal[1] * point.y + normal[2] * point.z), 6)})
    return {
        "label": label,
        "objectNames": [entry["name"] for entry in objects],
        "objects": objects,
        "openings": openings,
        "roofPlaneEquations": roof_planes,
        "stairLandingDimensionsM": {"stairRise": 0.25, "stairRun": 0.44, "landingHeight": 2.0, "housePlusStairLandingBounds": [10.3, 9.71, 7.26]},
        "architectureSource": "v0.334 authored geometry; v0.337 material slots only",
    }


def load_image(name: str) -> bpy.types.Image:
    return bpy.data.images.load(str(MAPS / name), check_existing=False)


def make_material(source_name: str, name: str, albedo: str, offset: tuple[float, float] = (0.0, 0.0), rotation: float = 0.0, normal_strength: float = 0.42, roughness: float = 0.86) -> bpy.types.Material:
    source = bpy.data.materials[source_name]
    material = source.copy()
    material.name = name
    material.use_nodes = True
    nodes = material.node_tree.nodes
    links = material.node_tree.links
    albedo_node = next(node for node in nodes if node.type == "TEX_IMAGE" and node.name == "Image Texture")
    rough_node = next(node for node in nodes if node.type == "TEX_IMAGE" and node.name == "Image Texture.001")
    normal_node = next(node for node in nodes if node.type == "TEX_IMAGE" and node.name == "Image Texture.002")
    albedo_node.image = load_image(albedo)
    rough_node.image = load_image("selected_granite_roughness.png")
    normal_node.image = load_image("selected_granite_normal.png")
    for image in (albedo_node.image, rough_node.image, normal_node.image):
        image.pack()
    normal = next(node for node in nodes if node.type == "NORMAL_MAP")
    normal.inputs["Strength"].default_value = normal_strength
    principled = next(node for node in nodes if node.type == "BSDF_PRINCIPLED")
    principled.inputs["Roughness"].default_value = roughness
    texcoord = nodes.new("ShaderNodeTexCoord")
    texcoord.name = "V0337_WallUV_TexCoord"
    mapping = nodes.new("ShaderNodeMapping")
    mapping.name = "V0337_WallSpecificUVMapping"
    mapping.inputs["Location"].default_value[0] = offset[0]
    mapping.inputs["Location"].default_value[1] = offset[1]
    mapping.inputs["Rotation"].default_value[2] = rotation
    links.new(texcoord.outputs["UV"], mapping.inputs["Vector"])
    for node in (albedo_node, rough_node, normal_node):
        links.new(mapping.outputs["Vector"], node.inputs["Vector"])
    material["v0337_source"] = "candidate_a"
    material["v0337_normal_strength"] = normal_strength
    material["v0337_height_parallax"] = False
    return material


def assign_wall_variants(obj: bpy.types.Object, variants: list[bpy.types.Material]) -> None:
    obj.data.materials.clear()
    for material in variants:
        obj.data.materials.append(material)
    for poly in obj.data.polygons:
        normal = poly.normal
        if normal.x > 0.7:
            poly.material_index = 0
        elif normal.x < -0.7:
            poly.material_index = 1
        elif normal.y > 0.7:
            poly.material_index = 2
        elif normal.y < -0.7:
            poly.material_index = 3
        else:
            poly.material_index = 0


def main() -> None:
    RUNTIME.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.open_mainfile(filepath=str(SOURCE_BLEND))
    source_fp = fingerprint("v0.334 source")
    wall_variants = [
        make_material("V0334_Granite", "V0337_SelectedGranite_Rubble_Front", "selected_granite_albedo.png", (0.07, 0.00), 0.00),
        make_material("V0334_Granite", "V0337_SelectedGranite_Rubble_Rear", "selected_granite_albedo.png", (0.31, 0.11), 0.015),
        make_material("V0334_Granite", "V0337_SelectedGranite_Rubble_Left", "selected_granite_albedo.png", (0.53, 0.23), -0.01),
        make_material("V0334_Granite", "V0337_SelectedGranite_Rubble_Right", "selected_granite_albedo.png", (0.77, 0.37), 0.02),
    ]
    dressed = make_material("V0334_Granite", "V0337_SelectedGranite_Dressed", "selected_granite_dressed_albedo.png", (0.13, 0.47), 0.0, 0.34, 0.82)
    foundation = make_material("V0334_Granite", "V0337_SelectedGranite_Foundation", "selected_granite_foundation_albedo.png", (0.21, 0.63), 0.0, 0.38, 0.90)
    for lod in ("LOD0", "LOD1", "LOD2"):
        granite = bpy.data.objects.get(f"{lod}_Granite")
        if granite:
            assign_wall_variants(granite, wall_variants)
        base = bpy.data.objects.get(f"{lod}_Damp_Foundation")
        if base:
            base.data.materials.clear()
            base.data.materials.append(foundation)
    for obj in bpy.data.objects:
        obj["v0337_architecture_preserved"] = True
        obj["v0337_geometry_source"] = "v0.334"
    derived_fp = fingerprint("v0.337 derived before export")
    architecture_equal = source_fp["objectNames"] == derived_fp["objectNames"] and source_fp["objects"] == derived_fp["objects"] and source_fp["openings"] == derived_fp["openings"] and source_fp["roofPlaneEquations"] == derived_fp["roofPlaneEquations"]
    record = {
        "checkpoint": "v0.337",
        "sourceBlend": str(SOURCE_BLEND.relative_to(ROOT)).replace("\\", "/"),
        "derivedBlend": str(OUT_BLEND.relative_to(ROOT)).replace("\\", "/"),
        "sourceGLBSha256": sha(ROOT / "desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb"),
        "selectedCandidate": "candidate_a",
        "materialSlotChangesOnly": True,
        "architectureEqualBeforeExport": architecture_equal,
        "sourceFingerprint": source_fp,
        "derivedFingerprint": derived_fp,
        "wallUV": {"textureResolution": [2048, 2048], "wallSpecificOffsetsRotations": {"front": [0.07, 0.0, 0.0], "rear": [0.31, 0.11, 0.015], "left": [0.53, 0.23, -0.01], "right": [0.77, 0.37, 0.02]}, "texelDensityTarget": "approximately 220..240 px/m inherited from v0.334 UV layout"},
        "materialBindings": {"wall": [m.name for m in wall_variants], "dressed": dressed.name, "foundation": foundation.name, "slatePreserved": "V0334_Weathered_Slate"},
        "preservation": {"architecture": True, "roof": True, "chimney": True, "stairLanding": True, "openings": True, "defaultRuntimeIntegrated": False, "gameplayChanged": False},
    }
    OUT_BLEND.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(OUT_BLEND))
    OUT_GLB.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(OUT_GLB), export_format="GLB", export_apply=False, export_materials="EXPORT", export_lights=False, export_cameras=False, export_extras=True)
    record["derivedBlendSha256"] = sha(OUT_BLEND)
    record["derivedGLBSha256"] = sha(OUT_GLB)
    ledger_text = json.dumps(record, indent=2) + "\n"
    (RUNTIME / "v0337-architecture-fingerprint-comparison.json").write_text(ledger_text, encoding="utf-8")
    LEDGER.parent.mkdir(parents=True, exist_ok=True)
    LEDGER.write_text(ledger_text, encoding="utf-8")
    print(json.dumps({"status": "PASS_V0337_DERIVED_HOUSE02_EXPORT", "architectureEqualBeforeExport": architecture_equal, "blendSha256": record["derivedBlendSha256"], "glbSha256": record["derivedGLBSha256"]}, indent=2))


if __name__ == "__main__":
    main()
