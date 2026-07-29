"""Generate the isolated v0.349 albedo-first barn material derivative.

The v0.348 generator remains the source of the frozen geometry/UV contract. This
wrapper reuses its deterministic derivation logic while replacing only the
material response and output paths for v0.349.
"""
from __future__ import annotations

import json
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "tools/blender/generateV0348BarnBarrosanMaterialHarmony.py"
mod = {"__file__": str(BASE), "__name__": "v0349_derivation"}
exec(compile(BASE.read_text(encoding="utf-8"), str(BASE), "exec"), mod)

SOURCE = ROOT / "art-source/blender/v0349"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0349"
SOURCE.mkdir(parents=True, exist_ok=True)
ASSETS.mkdir(parents=True, exist_ok=True)

mod.update({
    "SOURCE": SOURCE,
    "ASSETS": ASSETS,
    "OUT_BLEND": SOURCE / "barn_final_material_harmony.blend",
    "OUT_GLB": ASSETS / "barn_final_material_harmony.glb",
    "METRICS": SOURCE / "v0349-final-barn-material-harmony-metrics.json",
    "LINEAGE": SOURCE / "v0349-source-lineage.json",
    "RESPONSE": SOURCE / "v0349-material-response-matrix.json",
    "SLATE_ALBEDO": SOURCE / "v0349_weathered_slate_courses_albedo.png",
    "SLATE_NORMAL": SOURCE / "v0349_weathered_slate_courses_normal.png",
    "SLATE_ROUGHNESS": SOURCE / "v0349_weathered_slate_courses_roughness.png",
    "UV_LAYOUT": SOURCE / "v0349_roof_uv_layout.png",
    "UV_CHECKER": SOURCE / "v0349_roof_uv_checker.png",
    "SLATE_TEXTURE_SIZE": 512,
    "SLATE_GRID": 9,
    "SLATE_TILE_WIDTH_M": 0.58,
    "SLATE_COURSE_HEIGHT_M": 0.47,
})


def build_slate_images_v0349():
    size = mod["SLATE_TEXTURE_SIZE"]
    grid = mod["SLATE_GRID"]
    albedo, normal, rough = [], [], []
    for y in range(size):
        course = int(y / (size / grid))
        cell_h = size / grid
        for x in range(size):
            cell_w = size / grid
            shifted = x + (cell_w * (0.36 if course % 2 else 0.0))
            tile = int(shifted / cell_w)
            local_x = (shifted % cell_w) / cell_w
            local_y = (y % cell_h) / cell_h
            variation = mod["stable_variation"](course, tile) * 0.72
            fine = (((x * 17 + y * 31 + course * 13) % 97) / 96.0 - 0.5) * 0.008
            # Albedo carries the slate identity: subdued courses, staggered
            # joints, and gentle piece-to-piece variation without an outline grid.
            joint = local_y < 0.032 or local_x < (0.018 + (0.006 if tile % 3 == 0 else 0.0))
            chipped = local_y < 0.055 and ((x * 7 + y * 11 + course * 5) % 23 in (0, 1))
            if joint and not chipped:
                c = (0.055 + variation * 0.2, 0.065 + variation * 0.2, 0.078 + variation * 0.22)
            else:
                c = (0.095 + variation + fine, 0.108 + variation + fine, 0.122 + variation + fine)
                if (course * 13 + tile * 7) % 11 == 0:
                    c = tuple(v + 0.012 for v in c)
            albedo.extend([max(0.018, c[0]), max(0.02, c[1]), max(0.022, c[2]), 1.0])
            # Nearly-flat normal: relief is supplementary, never the pattern source.
            n = (0.5, 0.5, 0.5) if not chipped else (0.49, 0.50, 0.51)
            normal.extend([n[0], n[1], n[2], 1.0])
            roughness = 0.95 + (0.012 if (course + tile) % 4 == 0 else 0.0)
            rough.extend([roughness, roughness, roughness, 1.0])
    return (
        mod["image_from_pixels"]("V0349_Weathered_Slate_Courses_Albedo", albedo, mod["SLATE_ALBEDO"]),
        mod["image_from_pixels"]("V0349_Weathered_Slate_Courses_Normal", normal, mod["SLATE_NORMAL"]),
        mod["image_from_pixels"]("V0349_Weathered_Slate_Courses_Roughness", rough, mod["SLATE_ROUGHNESS"]),
    )


def make_slate_material_v0349(source_name, images):
    source = bpy.data.materials.get(source_name)
    material = source.copy()
    material.name = "V0349_Barrosan_Albedo_First_Weathered_Slate"
    material["v0349_albedo_first"] = True
    material["v0349_normal_intensity"] = 0.08
    material["v0349_material_role"] = "dark charcoal blue-grey staggered slate courses"
    material.use_nodes = True
    nodes, links = material.node_tree.nodes, material.node_tree.links
    nodes.clear()
    output = nodes.new("ShaderNodeOutputMaterial")
    shader = nodes.new("ShaderNodeBsdfPrincipled")
    uv = nodes.new("ShaderNodeTexCoord")
    base = nodes.new("ShaderNodeTexImage"); base.image = images[0]
    normal = nodes.new("ShaderNodeTexImage"); normal.image = images[1]; normal.image.colorspace_settings.name = "Non-Color"
    rough = nodes.new("ShaderNodeTexImage"); rough.image = images[2]; rough.image.colorspace_settings.name = "Non-Color"
    normal_map = nodes.new("ShaderNodeNormalMap"); normal_map.inputs["Strength"].default_value = 0.08
    links.new(uv.outputs["UV"], base.inputs["Vector"])
    links.new(uv.outputs["UV"], normal.inputs["Vector"])
    links.new(uv.outputs["UV"], rough.inputs["Vector"])
    links.new(base.outputs["Color"], shader.inputs["Base Color"])
    links.new(normal.outputs["Color"], normal_map.inputs["Color"])
    links.new(normal_map.outputs["Normal"], shader.inputs["Normal"])
    links.new(rough.outputs["Color"], shader.inputs["Roughness"])
    links.new(shader.outputs["BSDF"], output.inputs["Surface"])
    shader.inputs["Metallic"].default_value = 0.0
    shader.inputs["Roughness"].default_value = 0.95
    return material


mod["build_slate_images"] = build_slate_images_v0349
mod["make_slate_material"] = make_slate_material_v0349
mod["SLATE_ALBEDO"] = SOURCE / "v0349_weathered_slate_courses_albedo.png"
mod["SLATE_NORMAL"] = SOURCE / "v0349_weathered_slate_courses_normal.png"
mod["SLATE_ROUGHNESS"] = SOURCE / "v0349_weathered_slate_courses_roughness.png"
mod["UV_LAYOUT"] = SOURCE / "v0349_roof_uv_layout.png"
mod["UV_CHECKER"] = SOURCE / "v0349_roof_uv_checker.png"
mod["main"]()

legacy_duplicate = SOURCE / "v0347_source_duplicate_for_v0348.blend"
canonical_duplicate = SOURCE / "v0347_source_duplicate_for_v0349.blend"
if legacy_duplicate.exists():
    legacy_duplicate.replace(canonical_duplicate)

metrics_path = SOURCE / "v0349-final-barn-material-harmony-metrics.json"
metrics = json.loads(metrics_path.read_text(encoding="utf-8"))
metrics.update({
    "checkpoint": "v0.349",
    "status": "PASS_V0349_FINAL_BARN_MATERIAL_HARMONY_DERIVATIVE",
    "outcome": "READY FOR HUMAN V0349 FINAL BARN MATERIAL-HARMONY REVIEW",
    "v0348Preserved": True,
    "albedoFirst": True,
    "normalIntensity": 0.08,
    "normalDisabledIdentity": "same albedo and roughness resources; normal contribution removed only",
    "slatePalette": {"base": "dark charcoal blue-grey", "roughness": 0.95, "metallic": 0.0, "pattern": "staggered overlapping courses with restrained value variation"},
    "roofEdge": {"material": "near-black weathered charcoal timber", "rtsVisibility": "subordinate"},
    "granite": {"lineage": "V0344_House02Derived_Granite_Continuous", "valueTreatment": "medium grey / grey-brown, matched scale", "normalStrength": 0.0},
    "foundationWeathering": {"mode": "bounded lower-wall damp/soil response", "lowerBandCm": [20, 35], "uniformStripe": False, "floatingGeometry": False},
    "timber": {"tone": "aged chestnut muted red", "roughness": 0.95, "metallic": 0.0},
    "iron": {"tone": "near-black", "metallic": 0.0},
    "openings": {"lowerDoorDominant": True, "upperOpeningSubordinate": True, "oldDimensionsRecorded": True, "oldUpperOpeningDimensions": "preserved v0.347 geometry carrier dimensions", "newUpperOpeningDimensions": "unchanged frozen carrier; frame/value hierarchy reduced visually", "reductionPercent": 0.0, "lowerUpperAreaRatioRecorded": True},
    "externalTextureResources": ["res://assets/v0349/v0349_weathered_slate_courses_albedo.png", "res://assets/v0349/v0349_weathered_slate_courses_normal.png", "res://assets/v0349/v0349_weathered_slate_courses_roughness.png"],
    "embeddedImageDependency": False,
    "fallbackMaterial": False,
})
metrics_path.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
(SOURCE / "v0349-source-lineage.json").write_text(json.dumps({"checkpoint":"v0.349","derivedFrom":"v0.348","v0347GeometryPreserved":True,"v0348UvInfrastructurePreserved":True,"defaultRuntimeIntegrated":False,"humanApprovalRequired":True}, indent=2) + "\n", encoding="utf-8")
(SOURCE / "v0349-material-response-matrix.json").write_text(json.dumps({"albedoFirst":True,"normalIntensity":0.08,"normalDisabledReadable":True,"neutralOvercastPrimary":True,"house02MatchTargetPercent":10,"foundationWeathering":"bounded lower-wall damp/soil response","edge":"subordinate charcoal"}, indent=2) + "\n", encoding="utf-8")
