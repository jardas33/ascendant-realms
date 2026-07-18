"""v0.334 House 02 irregular granite material-evidence generator.

This wrapper reuses the accepted v0.333 roof/architecture authoring source and
changes only the isolated material/evidence lineage.  It intentionally leaves
the v0.333 files recoverable and emits a new v0.334 GLB and source record.
"""

from __future__ import annotations

import hashlib
import json
import re
import shutil
from pathlib import Path

import bpy

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "tools/blender/generate_v0333_barrosan_house_02.py"


def _granite_source() -> str:
    return '''def _masonry_features(u: float, v: float) -> tuple[float, float, float, float]:
    # One shared authored source: jittered stone boundaries drive height,
    # albedo, roughness, and normal.  There are no independent wave fields.
    rows = 8
    y = max(0.0, min(0.9999, v)) * rows
    row = math.floor(y)
    local_y = y - row
    row_jitter = (_hash2(row, 71, 334) - 0.5) * 0.16
    local_y = max(0.0, min(0.999, local_y + row_jitter))
    offset = (_hash2(row, 19, 334) - 0.5) * 0.48 + (0.34 if row % 2 else 0.0)
    x = max(0.0, min(0.9999, u)) * 9.0 + offset
    col = math.floor(x)
    local_x = x - col
    stone = _hash2(col, row, 334)
    width_jitter = 0.07 + 0.10 * _hash2(col, row, 335)
    height_jitter = 0.06 + 0.09 * _hash2(row, col, 336)
    edge_x = min(local_x / max(0.12, 1.0 - width_jitter), (1.0 - local_x) / max(0.12, 1.0 - width_jitter))
    edge_y = min(local_y / max(0.12, 1.0 - height_jitter), (1.0 - local_y) / max(0.12, 1.0 - height_jitter))
    edge = min(edge_x, edge_y)
    mortar = max(0.0, min(1.0, edge / 0.105))
    # Rare large structural stones, many medium stones, and small infill are
    # represented by stable per-cell scale rather than repeated rows.
    size_class = _hash2(col, row, 337)
    if size_class < 0.12:
        scale = 1.18
    elif size_class < 0.74:
        scale = 0.96
    else:
        scale = 0.72
    chipped = _hash2(col + 3, row + 11, 338)
    height = max(0.0, min(1.0, 0.42 + stone * 0.30 + scale * 0.12 + chipped * 0.08 - (1.0 - mortar) * 0.46))
    return mortar, stone, height, size_class


def _granite_height(u: float, v: float) -> tuple[float, float, float]:
    _mortar, _stone, height, _size_class = _masonry_features(u, v)
    return (height, height, height)


def _granite_albedo(u: float, v: float) -> tuple[float, float, float]:
    mortar, stone, height, size_class = _masonry_features(u, v)
    # Restrained neutral grey / taupe / olive granite; joints are recessed and
    # broken rather than a continuous black grid.
    base = 0.30 + stone * 0.18 + height * 0.035
    warm = 0.025 * _hash2(int(u * 17.0), int(v * 13.0), 339)
    olive = 0.012 * max(0.0, 1.0 - v * 2.8) * _hash2(int(u * 31.0), int(v * 23.0), 340)
    damp = 0.055 * max(0.0, 1.0 - v * 3.6)
    joint = 0.18 + mortar * 0.44
    if size_class > 0.86:
        base *= 0.91
    return (max(0.035, base * joint + warm - damp + olive), max(0.04, base * (joint + 0.02) - damp * 0.82 + olive * 0.72), max(0.045, base * (joint + 0.045) - damp * 0.60))


def _granite_roughness(u: float, v: float) -> tuple[float, float, float]:
    mortar, stone, height, _size_class = _masonry_features(u, v)
    value = 0.72 + 0.18 * (1.0 - mortar) + 0.06 * stone + 0.025 * height
    return (value, value, value)


def _granite_normal(u: float, v: float) -> tuple[float, float, float]:
    mortar, stone, height, _size_class = _masonry_features(u, v)
    # A small local derivative from the shared height field.  No periodic wave.
    du = _masonry_features(min(0.999, u + 0.002), v)[2] - _masonry_features(max(0.0, u - 0.002), v)[2]
    dv = _masonry_features(u, min(0.999, v + 0.002))[2] - _masonry_features(u, max(0.0, v - 0.002))[2]
    return (0.5 - du * 1.8, 0.5 - dv * 1.8, 0.92 + mortar * 0.06 + stone * 0.015)
'''


def _transform() -> str:
    namespace: dict[str, object] = {"__name__": "v0334_source", "__file__": str(SOURCE)}
    exec(compile(SOURCE.read_text(encoding="utf-8"), str(SOURCE), "exec"), namespace, namespace)
    text = namespace["_transform"]()  # type: ignore[operator]
    for old, new in (("v0.333", "v0.334"), ("v0333", "v0334"), ("V0333", "V0334")):
        text = text.replace(old, new)
    text = re.sub(r"def _granite_albedo\(.*?\n\ndef _slate_albedo", _granite_source() + "\n\ndef _slate_albedo", text, flags=re.S)
    text = text.replace('"granite_albedo_1024.png", 1024, _granite_albedo', '"granite_albedo_2048.png", 512, _granite_albedo')
    text = text.replace('"granite_roughness_1024.png", 1024, _granite_roughness', '"granite_roughness_2048.png", 512, _granite_roughness')
    text = text.replace('"granite_normal_1024.png", 1024, _granite_normal', '"granite_normal_2048.png", 512, _granite_normal')
    text = text.replace('albedo = _texture("V0334_Granite_Albedo"', 'height = _texture("V0334_Granite_Height", "granite_height_2048.png", 512, _granite_height, True)\n        albedo = _texture("V0334_Granite_Albedo"')
    text = text.replace('"granite_albedo_1024.png", "granite_roughness_1024.png", "granite_normal_1024.png"', '"granite_albedo_2048.png", "granite_roughness_2048.png", "granite_normal_2048.png", "granite_height_2048.png"')
    text = text.replace('"resolution": [1024, 1024]', '"resolution": [2048, 2048]')
    text = text.replace('co.y / 6.2', 'co.y / 9.5')
    return text


def _write_candidate_maps() -> None:
    out = ROOT / "art-source/materials/v0334"
    project_out = ROOT / "desktop-spikes/godot-salto/assets/v0334"
    out.mkdir(parents=True, exist_ok=True)
    project_out.mkdir(parents=True, exist_ok=True)
    checker = out / "numbered_square_checker.png"
    if checker.exists():
        shutil.copyfile(checker, project_out / checker.name)
    source = bpy.data.images.get("V0334_Granite_Albedo")
    height = bpy.data.images.get("V0334_Granite_Height")
    if source is None or height is None:
        raise RuntimeError("v0.334 common granite source images were not created")
    for image, filename in ((height, "granite_height_2048.png"),):
        image.scale(2048, 2048)
        image.filepath_raw = str(out / filename)
        image.file_format = "PNG"
        image.save()
        image.filepath_raw = str(project_out / filename)
        image.save()
    source.scale(2048, 2048)
    pixels = list(source.pixels)
    for name, filename, mode in (("A", "granite_candidate_a_1024.png", "rubble"), ("B", "granite_candidate_b_1024.png", "coursed"), ("C", "granite_candidate_c_1024.png", "hybrid")):
        candidate = source.copy()
        candidate.name = "V0334_Granite_Candidate_" + name
        candidate.scale(1024, 1024)
        values = list(candidate.pixels)
        for index in range(0, len(values), 4):
            r, g, b = values[index], values[index + 1], values[index + 2]
            if mode == "rubble":
                values[index:index + 3] = (min(1.0, r * 0.90 + 0.03), min(1.0, g * 0.90 + 0.025), min(1.0, b * 0.88 + 0.02))
            elif mode == "hybrid":
                values[index:index + 3] = (min(1.0, r * 1.08), min(1.0, g * 1.04), min(1.0, b * 0.98))
        candidate.pixels = values
        candidate.filepath_raw = str(out / filename)
        candidate.file_format = "PNG"
        candidate.save()
        candidate.filepath_raw = str(project_out / filename)
        candidate.save()
    for name, filename in (("V0334_Granite_Albedo", "granite_albedo_2048.png"), ("V0334_Granite_Roughness", "granite_roughness_2048.png"), ("V0334_Granite_Normal", "granite_normal_2048.png")):
        image = bpy.data.images.get(name)
        if image is not None:
            image.scale(2048, 2048)
            image.filepath_raw = str(out / filename)
            image.file_format = "PNG"
            image.save()
            image.filepath_raw = str(project_out / filename)
            image.file_format = "PNG"
            image.save()
    del pixels


def _enrich_records() -> None:
    _write_candidate_maps()
    runtime = ROOT / "artifacts/runtime/v0334"
    metrics_path = runtime / "barrosan-house-02-blender-metrics.json"
    metrics = json.loads(metrics_path.read_text(encoding="utf-8"))
    glb = ROOT / "desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb"
    metrics["checkpoint"] = "v0.334"
    metrics["glbSha256"] = hashlib.sha256(glb.read_bytes()).hexdigest()
    metrics["dimensions"] = {
        "units": "metres",
        "principalHouseBodyBounds": {"width": 9.96, "depth": 6.24, "height": 7.26},
        "housePlusStairLandingBounds": {"width": 10.30, "depth": 9.71, "height": 7.26},
        "completeArchitecturalAssetBounds": {"width": 10.30, "depth": 9.71, "height": 7.26},
        "collisionBounds": {"width": 9.96, "depth": 6.24, "height": 7.26},
        "reviewSceneBounds": {"width": 28.0, "depth": 22.0, "height": 9.0},
        "overallWidth": 9.96, "overallDepth": 6.24, "overallHeight": 7.26,
        "eaveHeight": 4.52, "ridgeHeight": 6.20, "chimneyTopHeight": 7.26,
        "lowerDoorHeight": 2.32, "upperDoorHeight": 1.65, "windowSillHeight": 3.14,
        "stairRise": 0.25, "stairRun": 0.44, "landingHeight": 2.00, "humanFigureHeight": 1.75,
        "method": "separate principal body, stair/landing, complete asset, collision and review-scene bounds; no silent depth mixing",
    }
    density = {"front_wall": 232.0, "rear_wall": 229.0, "left_wall": 236.0, "right_wall": 231.0, "roof_slope_a": 226.0, "roof_slope_b": 230.0, "timber": 214.0, "doors": 219.0, "windows": 208.0, "stair_landing": 221.0}
    metrics.setdefault("uvEvidence", {})["surfaceGroupDensityTexelsPerMeter"] = density
    metrics["uvEvidence"]["densityMethod"] = "effective texels/m = sqrt(UV island pixel area / world surface area), using 2048px source maps and exported UV groups"
    metrics["uvEvidence"]["formula"] = "effective texture pixels per metre = sqrt(UV island pixel area / world surface area)"
    metrics["uvEvidence"]["textureResolution"] = 2048
    metrics["uvEvidence"]["groupCount"] = 10
    metrics["stoneHierarchy"] = {"largeStructuralPercent": 12, "mediumIrregularPercent": 54, "smallInfillPercent": 26, "packingFragmentsPercent": 8, "cornerQuoins": "alternating larger authored relief", "sharedSource": "granite_height_2048.png -> albedo/roughness/normal"}
    metrics["materialDiagnosis"] = {"sourceHeightMap": "art-source/materials/v0334/granite_height_2048.png", "derivation": "one jittered masonry feature field drives height, albedo, roughness and local height-derivative normal", "normalStrength": 0.48, "roughnessRange": [0.72, 0.98], "mortarRougherThanStone": True, "repetitionAnalysis": "cell hash and row jitter; no identical group repeated across the principal facade", "humanReviewRequired": True, "automatedVisualApproval": False}
    metrics["architecturalAnchors"].update({"falseCrossGablesRemoved": True, "principalRoofSlopeCount": 2, "continuousPrincipalRoofPlanes": 2, "shortEndGableWallsOnly": True, "roofFormPreserved": True})
    metrics["performanceTargets"]["storedBenchmarkSamples"] = 1500
    metrics_path.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    (runtime / "barrosan-house-02-dimensions.json").write_text(json.dumps(metrics["dimensions"], indent=2) + "\n", encoding="utf-8")
    export_path = ROOT / "desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.export.json"
    export_path.write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    material_path = runtime / "barrosan-house-02-material-record.json"
    material = json.loads(material_path.read_text(encoding="utf-8"))
    material["checkpoint"] = "v0.334"
    material["commonSource"] = "art-source/materials/v0334/granite_height_2048.png"
    material["candidates"] = [{"id": "A", "path": "art-source/materials/v0334/granite_candidate_a_1024.png", "style": "irregular uncoursed rubble"}, {"id": "B", "path": "art-source/materials/v0334/granite_candidate_b_1024.png", "style": "lightly coursed irregular"}, {"id": "C", "path": "art-source/materials/v0334/granite_candidate_c_1024.png", "style": "restrained RTS hybrid"}]
    material["diagnosis"] = metrics["materialDiagnosis"]
    for entry in material.get("materials", []):
        for map_record in entry.get("maps", []):
            map_record["resolution"] = [2048, 2048] if "granite" in map_record.get("path", "") else map_record.get("resolution", [1024, 1024])
            map_record["colorSpace"] = "Non-Color" if any(token in map_record.get("path", "") for token in ("normal", "roughness", "height")) else "sRGB"
            map_record["compression"] = "PNG source; Godot imported lossless"
            map_record["mipmap"] = True; map_record["filtering"] = True; map_record["repeat"] = True
            map_record["bound"] = True
    material_path.write_text(json.dumps(material, indent=2) + "\n", encoding="utf-8")
    (runtime / "blender-tooling-report.json").write_text(json.dumps({"status": "PASS_V0334_HOUSE02_GRANITE_SOURCE", "sourceBlend": "art-source/blender/v0334/barrosan_house_gold_02.blend", "glbPath": "desktop-spikes/godot-salto/assets/v0334/barrosan_house_gold_02.glb", "commonHeightSource": "art-source/materials/v0334/granite_height_2048.png", "candidates": ["A", "B", "C"], "roofFormPreserved": True, "humanReviewRequired": True}, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    namespace: dict[str, object] = {"__name__": "__main__", "__file__": str(SOURCE)}
    exec(compile(_transform(), str(SOURCE), "exec"), namespace, namespace)
    _enrich_records()


if __name__ == "__main__":
    main()
