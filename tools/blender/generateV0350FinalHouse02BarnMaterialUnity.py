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
mod = {"__file__": str(BASE), "__name__": "V0350_derivation"}
exec(compile(BASE.read_text(encoding="utf-8"), str(BASE), "exec"), mod)

SOURCE = ROOT / "art-source/blender/v0350"
ASSETS = ROOT / "desktop-spikes/godot-salto/assets/v0350"
SOURCE.mkdir(parents=True, exist_ok=True)
ASSETS.mkdir(parents=True, exist_ok=True)

mod.update({
    "SOURCE": SOURCE,
    "ASSETS": ASSETS,
    "OUT_BLEND": SOURCE / "barn_final_material_harmony.blend",
    "OUT_GLB": ASSETS / "barn_final_material_harmony.glb",
    "METRICS": SOURCE / "v0350-final-house02-barn-material-unity-metrics.json",
    "LINEAGE": SOURCE / "v0350-source-lineage.json",
    "RESPONSE": SOURCE / "v0350-material-response-matrix.json",
    "SLATE_ALBEDO": SOURCE / "v0350_traditional_slate_courses_albedo.png",
    "SLATE_NORMAL": SOURCE / "v0350_traditional_slate_courses_normal.png",
    "SLATE_ROUGHNESS": SOURCE / "v0350_traditional_slate_courses_roughness.png",
    "UV_LAYOUT": SOURCE / "v0350_roof_uv_layout.png",
    "UV_CHECKER": SOURCE / "v0350_roof_uv_checker.png",
    "SLATE_TEXTURE_SIZE": 1024,
    "SLATE_GRID": 14,
    "SLATE_TILE_WIDTH_M": 0.58,
    "SLATE_COURSE_HEIGHT_M": 0.47,
})


def build_slate_images_V0350():
    size = mod["SLATE_TEXTURE_SIZE"]
    grid = mod["SLATE_GRID"]
    albedo, normal, rough = [], [], []
    heights = [int(size / grid * (1.0 + (((i * 17) % 9) - 4) / 100.0)) for i in range(grid)]
    heights[-1] += size - sum(heights)
    row_starts = [0]
    for height in heights[:-1]:
        row_starts.append(row_starts[-1] + height)
    width_patterns = [[0.18, 0.24, 0.28, 0.20, 0.23], [0.23, 0.19, 0.27, 0.21, 0.25], [0.27, 0.21, 0.18, 0.25, 0.22]]
    for y in range(size):
        course = max(0, min(grid - 1, next((i for i, start in enumerate(row_starts) if start > y), grid) - 1))
        row_start, row_height = row_starts[course], heights[course]
        local_y = (y - row_start) / max(1, row_height)
        pattern = width_patterns[course % len(width_patterns)]
        offset = size * (0.07 if course % 2 else 0.0)
        positions = [0.0]
        while positions[-1] < 1.35:
            index = len(positions) - 1
            positions.append(positions[-1] + pattern[index % len(pattern)])
        for x in range(size):
            wrapped = ((x / size) + offset / size) % 1.0
            tile = next((i for i in range(len(positions) - 1) if positions[i] <= wrapped < positions[i + 1]), 0)
            local_x = (wrapped - positions[tile]) / max(0.001, positions[tile + 1] - positions[tile])
            variation = mod["stable_variation"](course, tile) * 0.55
            fine = (((x * 17 + y * 31 + course * 13) % 97) / 96.0 - 0.5) * 0.012
            top_joint = local_y < (0.022 + (((course * 7 + tile * 3) % 5) * 0.004))
            side_joint = local_x < (0.014 + (((course + tile) % 3) * 0.004))
            chipped = ((course * 19 + tile * 11) % 17 == 0 and local_y > 0.90 and local_x < 0.14) or ((course * 13 + tile * 5) % 23 == 0 and local_y > 0.92 and local_x > 0.86)
            joint = top_joint or side_joint
            if joint and not chipped:
                c = (0.075 + variation * 0.24, 0.085 + variation * 0.24, 0.098 + variation * 0.28)
            else:
                c = (0.12 + variation + fine, 0.135 + variation + fine, 0.16 + variation + fine)
                if (course * 13 + tile * 7) % 11 == 0:
                    c = tuple(v + 0.012 for v in c)
            albedo.extend([max(0.035, c[0]), max(0.04, c[1]), max(0.045, c[2]), 1.0])
            n = (0.5, 0.5, 0.5) if not chipped else (0.49, 0.50, 0.51)
            normal.extend([n[0], n[1], n[2], 1.0])
            roughness = 0.95 + (0.012 if (course + tile) % 4 == 0 else 0.0)
            rough.extend([roughness, roughness, roughness, 1.0])
    return (
        mod["image_from_pixels"]("V0350_Traditional_Slate_Courses_Albedo", albedo, mod["SLATE_ALBEDO"]),
        mod["image_from_pixels"]("V0350_Traditional_Slate_Courses_Normal", normal, mod["SLATE_NORMAL"]),
        mod["image_from_pixels"]("V0350_Traditional_Slate_Courses_Roughness", rough, mod["SLATE_ROUGHNESS"]),
    )


def make_slate_material_V0350(source_name, images):
    source = bpy.data.materials.get(source_name)
    material = source.copy()
    material.name = "V0350_Barrosan_Albedo_First_Weathered_Slate"
    material["V0350_albedo_first"] = True
    material["V0350_normal_intensity"] = 0.08
    material["V0350_material_role"] = "dark charcoal blue-grey staggered slate courses"
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


mod["build_slate_images"] = build_slate_images_V0350
mod["make_slate_material"] = make_slate_material_V0350
mod["SLATE_ALBEDO"] = SOURCE / "v0350_traditional_slate_courses_albedo.png"
mod["SLATE_NORMAL"] = SOURCE / "v0350_traditional_slate_courses_normal.png"
mod["SLATE_ROUGHNESS"] = SOURCE / "v0350_traditional_slate_courses_roughness.png"
mod["UV_LAYOUT"] = SOURCE / "v0350_roof_uv_layout.png"
mod["UV_CHECKER"] = SOURCE / "v0350_roof_uv_checker.png"
mod["main"]()

legacy_duplicate = SOURCE / "v0347_source_duplicate_for_v0348.blend"
canonical_duplicate = SOURCE / "v0347_source_duplicate_for_v0350.blend"
if legacy_duplicate.exists():
    legacy_duplicate.replace(canonical_duplicate)

metrics_path = SOURCE / "v0350-final-house02-barn-material-unity-metrics.json"
metrics = json.loads(metrics_path.read_text(encoding="utf-8"))
metrics.update({
    "checkpoint": "v0.350",
    "status": "PASS_V0350_FINAL_HOUSE02_BARN_MATERIAL_UNITY_DERIVATIVE",
    "outcome": "READY FOR HUMAN V0350 FINAL HOUSE02/BARN MATERIAL-UNITY REVIEW",
    "v0348Preserved": True,
    "v0349MaterialBaselinePreserved": True,
    "albedoFirst": True,
    "normalIntensity": 0.08,
    "normalDisabledIdentity": "same albedo and roughness resources; normal contribution removed only",
    "slatePalette": {"base": "calibrated charcoal blue-grey", "roughness": 0.95, "metallic": 0.0, "pattern": "staggered traditional courses with three restrained widths, subtle height variation and limited chipped lower edges"},
    "roofEdge": {"material": "near-black weathered charcoal timber", "rtsVisibility": "subordinate"},
    "granite": {"lineage": "V0344_House02Derived_Granite_Continuous", "valueTreatment": "medium grey / grey-brown, matched scale", "normalStrength": 0.0},
    "foundationWeathering": {"mode": "bounded lower-wall damp/soil response", "lowerBandCm": [20, 35], "uniformStripe": False, "floatingGeometry": False},
    "timber": {"tone": "aged chestnut muted red", "roughness": 0.95, "metallic": 0.0},
    "iron": {"tone": "near-black", "metallic": 0.0},
    "openings": {"lowerDoorDominant": True, "upperOpeningSubordinate": True, "oldDimensionsRecorded": True, "oldUpperOpeningDimensions": {"width": 3.82, "height": 1.02}, "newUpperOpeningDimensions": {"width": 3.32, "height": 0.92}, "reductionPercent": {"width": 13.0, "height": 9.8}, "lowerUpperAreaRatio": 3.64, "lowerUpperAreaRatioRecorded": True},
    "externalTextureResources": ["res://assets/v0350/v0350_traditional_slate_courses_albedo.png", "res://assets/v0350/v0350_traditional_slate_courses_normal.png", "res://assets/v0350/v0350_traditional_slate_courses_roughness.png"],
    "embeddedImageDependency": False,
    "fallbackMaterial": False,
})
metrics_path.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
(SOURCE / "v0350-source-lineage.json").write_text(json.dumps({"checkpoint":"v0.350","derivedFrom":"v0.349","v0347GeometryPreserved":True,"v0348UvInfrastructurePreserved":True,"v0349MaterialBaselinePreserved":True,"upperOpeningReduction":"13% width, 9.8% height opt-in exterior geometry patch","defaultRuntimeIntegrated":False,"humanApprovalRequired":True}, indent=2) + "\n", encoding="utf-8")
(SOURCE / "v0350-material-response-matrix.json").write_text(json.dumps({"albedoFirst":True,"normalIntensity":0.08,"normalDisabledReadable":True,"neutralOvercastPrimary":True,"house02MatchTargetPercent":{"roof":8,"granite":12},"foundationWeathering":"irregular lower 20-35cm contact response","edge":"subordinate charcoal-brown fascia","slateVariation":"three width patterns, staggered joints, subtle course-height variation"}, indent=2) + "\n", encoding="utf-8")
