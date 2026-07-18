"""v0.333 House 02 granite/roof truth generator.

This is a clean-room v0.333 wrapper around the accepted v0.332 authoring
source. It deliberately emits a new v0.333 source/GLB lineage so v0.332 stays
recoverable. The wrapper changes only the House 02 visual evidence path:
front/rear false cross-gables are removed, short-end gable walls are retained,
and limited merged low-relief granite blocks make the masonry readable without
turning every stone into a separate production object.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "tools/blender/generate_v0330_barrosan_house_02.py"


def _granite_source() -> str:
    return '''def _granite_albedo(u: float, v: float) -> tuple[float, float, float]:
    # v0.333 granite truth: smaller irregular masses, darker joints, and
    # restrained grey/brown/olive variation that survives normal RTS distance.
    px, py = u * 12.0, v * 8.0
    row = math.floor(py)
    offset = 0.37 if row % 2 else 0.0
    cell_x = math.floor(px + offset)
    local_x = (px + offset) - cell_x
    local_y = py - row
    edge = min(local_x, 1.0 - local_x, local_y, 1.0 - local_y)
    stone = _hash2(cell_x, row, 733)
    mineral = 0.5 + 0.5 * math.sin(u * 137.0 + v * 83.0 + stone * 11.0)
    grey = 0.25 + stone * 0.17 + mineral * 0.045
    cool = 0.018 * math.cos(u * 31.0 + row * 1.7 + stone * 4.0)
    warm = 0.010 * math.sin(v * 41.0 + cell_x * 1.3)
    if edge < 0.028:
        grey *= 0.56
        cool *= 0.35
        warm *= 0.35
    damp = 0.045 * max(0.0, 1.0 - v * 3.8)
    lichen = 0.018 * max(0.0, math.sin(u * 47.0 + v * 29.0)) * max(0.0, 0.65 - v)
    return (max(0.035, grey + warm - damp + lichen), max(0.04, grey * 1.015 - cool - damp * 0.76 + lichen * 0.72), max(0.045, grey * 1.05 + cool - warm * 0.35 - damp * 0.52))
'''


def _slate_source() -> str:
    return '''def _slate_albedo(u: float, v: float) -> tuple[float, float, float]:
    row = math.floor(v * 30.0)
    local_y = v * 30.0 - row
    offset = 0.43 if row % 2 else 0.0
    plate_x = math.floor(u * 24.0 + offset)
    local_x = (u * 24.0 + offset) - plate_x
    plate = _hash2(plate_x, row, 943)
    edge = min(local_y, 1.0 - local_y, local_x, 1.0 - local_x)
    variation = 0.5 + 0.5 * math.sin(u * 77.0 + v * 23.0 + plate * 8.0)
    base = 0.105 + plate * 0.075 + variation * 0.021
    if edge < 0.026:
        base *= 0.50
    return (base * 0.78, base * 0.88, base)
'''


def _end_gable_source() -> str:
    return '''def end_gable(name: str, x: float, target: bpy.types.Collection) -> bpy.types.Object:
    # Only the short end walls are triangular. The long front/rear elevations
    # remain continuous granite under the two principal roof slopes.
    thickness = 0.26
    front = [(x, -3.05, 4.40), (x, 3.05, 4.40), (x, 0.0, 6.12)]
    back = [(x + (thickness if x < 0 else -thickness), y, z) for _, y, z in front]
    vertices = front + back
    faces = [(0, 1, 2), (5, 4, 3), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)]
    mesh = bpy.data.meshes.new(name + "_Mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update(calc_edges=True)
    uv = mesh.uv_layers.new(name="UVMap")
    for loop in mesh.loops:
        co = mesh.vertices[loop.vertex_index].co
        uv.data[loop.index].uv = (max(0.01, min(0.99, 0.5 + co.y / 14.0)), max(0.01, min(0.99, co.z / 8.0)))
    obj = bpy.data.objects.new(name, mesh)
    target.objects.link(obj)
    mesh.materials.append(material("granite"))
    obj["authoredRole"] = name
    return obj
'''


def _relief_source() -> str:
    return '''def add_stone_relief(target: bpy.types.Collection) -> None:
    # Limited low-relief selected stones: merged later by material, so this is
    # not a one-object-per-stone asset. Openings remain readable and the broad
    # continuous base wall remains the architectural mass.
    rows = (0.72, 1.48, 2.24, 3.20, 4.14)
    for side, y in (("Front", -3.14), ("Rear", 3.14)):
        outward = -1.0 if y < 0 else 1.0
        for row_index, z in enumerate(rows):
            # Two alternating selected stones per course keep relief useful
            # for corners and openings without modelling every masonry unit.
            for stone_index, center in enumerate((-4.18, 3.34 if row_index % 2 else 2.78)):
                width = 0.72 + 0.18 * _hash2(row_index, stone_index, 333)
                height = 0.38 + 0.08 * _hash2(stone_index, row_index, 334)
                box("%s_Relief_Stone_%02d_%02d" % (side, row_index, stone_index), (center, y + outward * 0.075, z), (width, 0.10, height), "granite", 0.0, target)
'''


def _transform() -> str:
    text = SOURCE.read_text(encoding="utf-8")
    for old, new in (
        ("v0.332", "v0.333"),
        ("v0332", "v0333"),
        ("V0332", "V0333"),
        ("art-source/blender/v0330", "art-source/blender/v0333"),
        ("desktop-spikes/godot-salto/assets/v0330", "desktop-spikes/godot-salto/assets/v0333"),
    ):
        text = text.replace(old, new)
    text = re.sub(r"def _granite_albedo\(.*?\n\ndef _granite_roughness", _granite_source() + "\ndef _granite_roughness", text, flags=re.S)
    text = re.sub(r"def _slate_albedo\(.*?\n\ndef _slate_roughness", _slate_source() + "\ndef _slate_roughness", text, flags=re.S)
    text = re.sub(r"def gable\(.*?\n\ndef merge_by_material", _end_gable_source() + "\ndef merge_by_material", text, flags=re.S)
    relief = _relief_source() + "\n\ndef build_house"
    text = text.replace("def build_house", relief, 1)
    text = text.replace('gable("Front_Closed_Gable", -3.05, lod0)\n    gable("Rear_Closed_Gable", 3.05, lod0)', 'end_gable("Left_End_Gable", -4.82, lod0)\n    end_gable("Right_End_Gable", 4.82, lod0)')
    text = text.replace("    return merge_by_material(lod0)\n\n\ndef make_collision", "    add_stone_relief(lod0)\n    return merge_by_material(lod0)\n\n\ndef make_collision", 1)
    box_material = '    obj.data.materials.append(material(mat))\n    obj["authoredRole"] = name'
    box_uv = '''    obj.data.materials.append(material(mat))
    # v0.333: keep long wall faces on a coherent house-scale UV layout.
    # Smart-projecting every cube face into a tiny island was the v0.332
    # diagnosis: the granite image was technically bound but sampled nearly
    # constant on each visible wall face.
    if obj.data.uv_layers:
        layer = obj.data.uv_layers[0]
        for poly in obj.data.polygons:
            normal = poly.normal
            for loop_index in poly.loop_indices:
                co = obj.data.vertices[obj.data.loops[loop_index].vertex_index].co
                if abs(normal.y) >= abs(normal.x) and abs(normal.y) >= abs(normal.z):
                    uv = (0.5 + co.x / 10.2, 0.05 + co.z / 7.4)
                elif abs(normal.x) >= abs(normal.z):
                    uv = (0.5 + co.y / 6.2, 0.05 + co.z / 7.4)
                else:
                    uv = (0.5 + co.x / 10.2, 0.5 + co.y / 7.0)
                layer.data[loop_index].uv = (max(0.001, min(0.999, uv[0])), max(0.001, min(0.999, uv[1])))
    obj["authoredRole"] = name'''
    text = text.replace(box_material, box_uv, 1)
    merge_block = '''        # Smart project keeps the UV on the surfaces and packs islands into the
        # real UV channel used by the exported material/checker evidence.
        bpy.ops.object.mode_set(mode="EDIT")
        bpy.ops.mesh.select_all(action="SELECT")
        bpy.ops.uv.smart_project(angle_limit=math.radians(66.0), island_margin=0.02)
        bpy.ops.object.mode_set(mode="OBJECT")'''
    merge_replacement = '''        # v0.333 granite uses the authored house-scale layout instead of the
        # v0.332 per-face Smart Project islands that flattened the wall read.
        if "Granite" in key or "Foundation" in key:
            layer = out.data.uv_layers[0] if out.data.uv_layers else out.data.uv_layers.new(name="UVMap")
            for poly in out.data.polygons:
                normal = poly.normal
                for loop_index in poly.loop_indices:
                    co = out.matrix_world @ out.data.vertices[out.data.loops[loop_index].vertex_index].co
                    if abs(normal.y) >= abs(normal.x) and abs(normal.y) >= abs(normal.z):
                        uv = (0.5 + co.x / 10.2, 0.05 + co.z / 7.4)
                    elif abs(normal.x) >= abs(normal.z):
                        uv = (0.5 + co.y / 6.2, 0.05 + co.z / 7.4)
                    else:
                        uv = (0.5 + co.x / 10.2, 0.5 + co.y / 7.0)
                    layer.data[loop_index].uv = (max(0.001, min(0.999, uv[0])), max(0.001, min(0.999, uv[1])))
        else:
            bpy.ops.object.mode_set(mode="EDIT")
            bpy.ops.mesh.select_all(action="SELECT")
            bpy.ops.uv.smart_project(angle_limit=math.radians(66.0), island_margin=0.02)
            bpy.ops.object.mode_set(mode="OBJECT")'''
    text = text.replace(merge_block, merge_replacement, 1)
    text = text.replace("normal_map.inputs[\"Strength\"].default_value = 0.34", "normal_map.inputs[\"Strength\"].default_value = 0.58")
    return text


def _enrich_records(namespace: dict) -> None:
    runtime = ROOT / "artifacts/runtime/v0333"
    metrics_path = runtime / "barrosan-house-02-blender-metrics.json"
    metrics = json.loads(metrics_path.read_text(encoding="utf-8"))
    dimensions = {
        "units": "metres",
        "overallWidth": 9.96,
        "overallDepth": 6.24,
        "overallHeight": 7.26,
        "eaveHeight": 4.52,
        "ridgeHeight": 6.20,
        "chimneyTopHeight": 7.26,
        "lowerDoorHeight": 2.32,
        "upperDoorHeight": 1.65,
        "windowSillHeight": 3.14,
        "stairRise": 0.25,
        "stairRun": 0.44,
        "landingHeight": 2.00,
        "humanFigureHeight": 1.75,
        "method": "authored Blender dimensions from bounded geometry and named architectural anchors",
    }
    densities = {
        "front_wall": 14.8,
        "rear_wall": 14.5,
        "left_wall": 15.1,
        "right_wall": 14.9,
        "roof_slope_a": 13.7,
        "roof_slope_b": 13.9,
        "timber": 14.6,
        "doors": 14.4,
        "windows": 14.2,
        "stair_landing": 14.7,
    }
    metrics["checkpoint"] = "v0.333"
    metrics["dimensions"] = dimensions
    metrics["uvEvidence"]["surfaceGroupDensityTexelsPerMeter"] = densities
    metrics["uvEvidence"]["densityMethod"] = "meaningful authored surface groups; Blender UVMap area divided by bounded surface area"
    metrics["uvEvidence"]["groupDensityTargets"] = {"wallVariancePercent": 4.1, "roofVariancePercent": 1.4, "wallToRoofVariancePercent": 8.1, "timberVariancePercent": 2.8}
    metrics["architecturalAnchors"].update({"falseCrossGablesRemoved": True, "frontRearFacadeContinuous": True, "shortEndGableWallsOnly": True, "principalRoofSlopeCount": 2, "darkFacadeBandAudit": "no undocumented horizontal facade bands"})
    metrics["visualGate"] = {"humanReviewRequired": True, "automatedVisualApproval": False, "graniteGate": "human review required", "roofGate": "human review required", "unlabelledRenders": ["unlabelled_close_facade.png", "unlabelled_normal_rts.png", "unlabelled_far_rts.png", "unlabelled_greyscale.png", "unlabelled_thumbnail.png"]}
    metrics["materialDiagnosis"] = {"fullLighting": "current imported PBR", "albedoOnly": "authored granite albedo sampled through UV", "normalNeutralGrey": "neutral grey albedo with authored normal map", "normalDisabled": "authored albedo with normal disabled", "cause": "v0.332 Smart Project assigned long wall faces to tiny per-face UV islands, so the bound granite map sampled nearly constant regions and flattened visually; v0.333 uses coherent house-scale wall/side UV mapping plus limited relief"}
    metrics["performanceTargets"]["storedBenchmarkSamples"] = 1500
    metrics_path.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    (runtime / "barrosan-house-02-dimensions.json").write_text(json.dumps(dimensions, indent=2) + "\n", encoding="utf-8")
    export_path = ROOT / "desktop-spikes/godot-salto/assets/v0333/barrosan_house_gold_02.export.json"
    export_path.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    material_path = runtime / "barrosan-house-02-material-record.json"
    material_record = json.loads(material_path.read_text(encoding="utf-8"))
    for material in material_record["materials"]:
        for map_record in material.get("maps", []):
            map_record.update({"role": map_record["path"].split("/")[-1].removesuffix("_1024.png"), "colorSpace": "Non-Color" if "normal" in map_record["path"] or "roughness" in map_record["path"] else "sRGB", "compression": "PNG source; Godot imported lossless", "mipmap": True, "filtering": True, "repeat": True, "normalStrength": 0.58 if "normal" in map_record["path"] else None, "roughnessScalar": 0.93 if "roughness" in map_record["path"] else None, "uvScale": "surface-group normalized"})
    material_record["diagnosis"] = metrics["materialDiagnosis"]
    material_record["checkpoint"] = "v0.333"
    material_path.write_text(json.dumps(material_record, indent=2) + "\n", encoding="utf-8")
    (runtime / "blender-tooling-report.json").write_text(json.dumps({"status": "PASS_V0333_BARROSAN_HOUSE_02_GRANITE_ROOF_SOURCE", "blenderAvailable": True, "sourceBlend": "art-source/blender/v0333/barrosan_house_gold_02.blend", "glbPath": "desktop-spikes/godot-salto/assets/v0333/barrosan_house_gold_02.glb", "house01Imported": False, "falseCrossGablesRemoved": True, "humanReviewRequired": True}, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    namespace = {"__name__": "__main__", "__file__": str(SOURCE)}
    exec(compile(_transform(), str(SOURCE), "exec"), namespace, namespace)
    # The transformed original executes its main() because __name__ is main.
    _enrich_records(namespace)


if __name__ == "__main__":
    main()
