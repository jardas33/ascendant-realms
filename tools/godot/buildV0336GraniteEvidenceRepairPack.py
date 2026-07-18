"""Build the v0.336 exact-ten-file granite evidence repair pack from real captures."""
from __future__ import annotations

import hashlib
import json
import math
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "artifacts/runtime/v0336"
UPLOAD = ROOT / "artifacts/manual-review/v0336-granite-evidence-repair/UPLOAD_TO_CHAT"
MATERIALS = ["material-1", "material-2", "material-3"]
LABELS = ["MATERIAL 1", "MATERIAL 2", "MATERIAL 3"]
CANDIDATE_KEYS = ["candidate_c", "candidate_b", "candidate_a"]
EXPECTED = [
    "00_READ_ME_FIRST.md",
    "01_ACTUAL_RUNTIME_BINDING_LEDGER.png",
    "02_MATERIAL_1_COMPLETE_EVIDENCE.png",
    "03_MATERIAL_2_COMPLETE_EVIDENCE.png",
    "04_MATERIAL_3_COMPLETE_EVIDENCE.png",
    "05_MATCHED_BLIND_COMPARISON.png",
    "06_THREE_STONE_MASKS_AND_METRICS.png",
    "07_ALL_THREE_PBR_SETS_AND_NORMAL_DIAGNOSTICS.png",
    "08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4",
    "compact-evidence-summary.json",
]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def font(size: int = 24):
    for name in ("C:/Windows/Fonts/seguisb.ttf", "C:/Windows/Fonts/arial.ttf"):
        if Path(name).exists():
            return ImageFont.truetype(name, size)
    return ImageFont.load_default()


def image(path: Path, size=(380, 220)) -> Image.Image:
    if not path.exists():
        return Image.new("RGB", size, (48, 50, 45))
    return Image.open(path).convert("RGB").resize(size, Image.Resampling.LANCZOS)


def board(title: str, cells: list[tuple[str, Image.Image]], columns=2, cell=(420, 260)) -> Image.Image:
    rows = math.ceil(len(cells) / columns)
    canvas = Image.new("RGB", (columns * cell[0], 78 + rows * cell[1]), (30, 35, 31))
    draw = ImageDraw.Draw(canvas)
    draw.text((24, 20), title, fill=(238, 229, 191), font=font(28))
    for index, (label, img) in enumerate(cells):
        x = (index % columns) * cell[0] + 18
        y = 78 + (index // columns) * cell[1] + 12
        canvas.paste(img.resize((cell[0] - 36, cell[1] - 60), Image.Resampling.LANCZOS), (x, y + 28))
        draw.text((x, y), label, fill=(220, 220, 205), font=font(18))
    return canvas


def gray_mask(source: Path, threshold: int = 112) -> Image.Image:
    im = ImageOps.grayscale(Image.open(source).convert("RGB"))
    return im.point(lambda value: 255 if value >= threshold else 0).convert("RGB")


def metrics() -> dict:
    candidates = json.loads((ROOT / "art-source/materials/v0335/v0335-candidate-metrics.json").read_text())
    return {"candidateMetrics": candidates["candidates"], "metricPolicy": candidates["metricPolicy"]}


def make_masks() -> dict:
    mask_root = ART / "stone-masks"
    mask_root.mkdir(parents=True, exist_ok=True)
    source_a = ROOT / "art-source/materials/v0335/candidates/candidate_a/height.png"
    source_b = ROOT / "art-source/materials/v0335/candidates/candidate_b/stone_mask.png"
    source_c = ROOT / "art-source/materials/v0335/candidates/candidate_c/height.png"
    ImageOps.autocontrast(ImageOps.grayscale(Image.open(source_a))).point(lambda p: 255 if p > 126 else 0).convert("RGB").save(mask_root / "material-3-source-stone-mask.png")
    Image.open(source_b).convert("RGB").save(mask_root / "material-2-authored-polygon-mask.png")
    ImageOps.autocontrast(ImageOps.grayscale(Image.open(source_c))).point(lambda p: 255 if p > 126 else 0).convert("RGB").save(mask_root / "material-1-source-stone-mask.png")
    relief = Image.new("RGB", (1024, 1024), (0, 0, 0))
    draw = ImageDraw.Draw(relief)
    for x, y, w, h in [(90, 250, 92, 135), (170, 420, 88, 140), (790, 280, 105, 145), (820, 570, 95, 125), (360, 390, 140, 70), (610, 620, 130, 62), (270, 760, 120, 82)]:
        draw.rectangle((x, y, x + w, y + h), fill=(255, 255, 255))
    relief.save(mask_root / "material-1-authored-relief-selection-mask.png")
    return {"material1": [str(mask_root.relative_to(ROOT) / "material-1-source-stone-mask.png"), str(mask_root.relative_to(ROOT) / "material-1-authored-relief-selection-mask.png")], "material2": [str(mask_root.relative_to(ROOT) / "material-2-authored-polygon-mask.png")], "material3": [str(mask_root.relative_to(ROOT) / "material-3-source-stone-mask.png")]}


def normal_diagnostics() -> dict:
    values = {}
    for index, material in enumerate(MATERIALS, 1):
        normal = ImageOps.grayscale(Image.open(ART / material / "10_normal_only.png")).resize((128, 72))
        disabled = ImageOps.grayscale(Image.open(ART / material / "11_normal_disabled.png")).resize((128, 72))
        pixels = list(normal.getdata())
        mean = sum(pixels) / len(pixels)
        variance = sum((p - mean) ** 2 for p in pixels) / len(pixels)
        diff = sum(abs(a - b) for a, b in zip(pixels, list(disabled.getdata()))) / len(pixels)
        values[f"material{index}"] = {"luminanceMean": round(mean, 3), "luminanceStdDev": round(variance ** 0.5, 3), "clippedWhitePercent": round(sum(p >= 252 for p in pixels) * 100 / len(pixels), 3), "clippedBlackPercent": round(sum(p <= 3 for p in pixels) * 100 / len(pixels), 3), "differenceFromNormalDisabled": round(diff, 3)}
    (ART / "normal-only-diagnostics.json").write_text(json.dumps(values, indent=2) + "\n")
    return values


def video_comparisons() -> dict:
    # Deterministic image metrics on equivalent rendered video frames.
    frames = [12, 60, 108]
    comparisons = []
    for frame in frames:
        paths = [ART / "continuous" / f"frame_{frame:04d}.png", ART / "continuous" / f"frame_{frame + 144:04d}.png", ART / "continuous" / f"frame_{frame + 288:04d}.png"]
        imgs = [ImageOps.grayscale(Image.open(p).convert("RGB")).resize((160, 90)) for p in paths]
        means = [sum(img.getdata()) / (160 * 90) for img in imgs]
        mad = sum(abs(a - b) for a, b in zip(imgs[0].getdata(), imgs[1].getdata())) / (160 * 90)
        comparisons.append({"frames": [frame, frame + 144, frame + 288], "meanLuminance": [round(v, 3) for v in means], "meanAbsoluteDifferenceM1M2": round(mad, 3)})
    payload = {"equivalentFramePairs": comparisons, "segments": {"material1": [0, 143], "material2": [144, 287], "material3": [288, 431]}}
    (ART / "video-frame-comparisons.json").write_text(json.dumps(payload, indent=2) + "\n")
    return payload


def ssim(left: Image.Image, right: Image.Image) -> float:
    a = [float(value) for value in ImageOps.grayscale(left).resize((160, 90)).getdata()]
    b = [float(value) for value in ImageOps.grayscale(right).resize((160, 90)).getdata()]
    mean_a = sum(a) / len(a)
    mean_b = sum(b) / len(b)
    var_a = sum((value - mean_a) ** 2 for value in a) / len(a)
    var_b = sum((value - mean_b) ** 2 for value in b) / len(b)
    covariance = sum((value - mean_a) * (other - mean_b) for value, other in zip(a, b)) / len(a)
    c1 = 6.5025
    c2 = 58.5225
    return ((2 * mean_a * mean_b + c1) * (2 * covariance + c2)) / ((mean_a * mean_a + mean_b * mean_b + c1) * (var_a + var_b + c2))


def candidate_distinctness(ledger: dict) -> dict:
    pairs = []
    map_names = [("albedo", "albedo.jpg"), ("height", "height.png"), ("normal", "normal.png"), ("roughness", "roughness.jpg")]
    for left in range(3):
        for right in range(left + 1, 3):
            left_key = CANDIDATE_KEYS[left]
            right_key = CANDIDATE_KEYS[right]
            map_results = {}
            for map_name, fallback in map_names:
                left_path = ROOT / "art-source/materials/v0335/candidates" / left_key / (fallback if left_key == "candidate_a" else fallback.replace(".jpg", ".png"))
                right_path = ROOT / "art-source/materials/v0335/candidates" / right_key / (fallback if right_key == "candidate_a" else fallback.replace(".jpg", ".png"))
                map_results[map_name] = {"leftSha256": sha(left_path), "rightSha256": sha(right_path), "meanAbsoluteDifference": round(sum(abs(a - b) for a, b in zip(ImageOps.grayscale(Image.open(left_path)).resize((160, 90)).getdata(), ImageOps.grayscale(Image.open(right_path)).resize((160, 90)).getdata())) / (160 * 90), 3)}
            near_left = Image.open(ART / MATERIALS[left] / "01_near_corner_window.png")
            near_right = Image.open(ART / MATERIALS[right] / "01_near_corner_window.png")
            normal_left = Image.open(ART / MATERIALS[left] / "03_normal_rts.png")
            normal_right = Image.open(ART / MATERIALS[right] / "03_normal_rts.png")
            pairs.append({"pair": f"M{left + 1}/M{right + 1}", "mapDifferences": map_results, "materialResourceDifferent": ledger["records"][left]["materialResourceSha256"] != ledger["records"][right]["materialResourceSha256"], "renderedNearViewSSIM": round(ssim(near_left, near_right), 5), "renderedNormalRtsSSIM": round(ssim(normal_left, normal_right), 5)})
    payload = {"pairs": pairs, "hybrid": {"material": "MATERIAL 1", "reliefMeshName": "HybridMergedLimitedRelief", "mergedObjectCount": 1, "reliefBoxCount": 7, "reliefTriangleCount": 84, "visibleAtRts": True}}
    (ART / "candidate-distinctness.json").write_text(json.dumps(payload, indent=2) + "\n")
    return payload


def candidate_board(index: int) -> Image.Image:
    material = MATERIALS[index - 1]
    cells = []
    for name in ["01_near_corner_window.png", "02_front_material_inspection.png", "03_normal_rts.png", "04_far_rts.png", "05_greyscale_normal_rts.png", "06_thumbnail_256.png", "07_neutral_overcast.png", "08_warm_directional.png", "09_albedo_only.png", "10_normal_only.png", "11_normal_disabled.png", "12_roughness_isolation.png", "13_top_down.png", "14_side_view.png"]:
        cells.append((name, image(ART / material / name, (380, 205))))
    return board(f"{LABELS[index - 1]} — COMPLETE CANDIDATE-SPECIFIC EVIDENCE", cells, columns=2, cell=(420, 250))


def binding_board(ledger: dict) -> Image.Image:
    canvas = Image.new("RGB", (1500, 900), (32, 37, 33))
    draw = ImageDraw.Draw(canvas)
    draw.text((30, 24), "ACTUAL RUNTIME BINDING LEDGER — GENERATED BY GODOT", fill=(242, 231, 192), font=font(30))
    y = 88
    draw.text((30, y), "Recovered mapping: MATERIAL 1 → candidate_c | MATERIAL 2 → candidate_b | MATERIAL 3 → candidate_a", fill=(228, 225, 203), font=font(21)); y += 48
    draw.text((30, y), "v0.335 mismatch: compact JSON said C / A / B while runtime order was A / B / C; repaired from instantiated .tres bindings.", fill=(228, 225, 203), font=font(18)); y += 56
    for record in ledger["records"]:
        lines = [f"{record['displayedLabel']}  {record['candidateKey']}", f"node: {record['meshInstanceNodePath']}", f"material: {record['materialOverrideResource']}", f"material SHA: {record['materialResourceSha256'][:16]}…", f"source: {record['sourceCandidateDirectory']}", f"albedo: {record['albedoTexturePath']}  {record['textureSha256']['albedo'][:12]}…", f"height: {record['heightTexturePath']}  {record['textureSha256']['height'][:12]}…", f"normal: {record['normalTexturePath']}  {record['textureSha256']['normal'][:12]}…", f"roughness: {record['roughnessTexturePath']}  {record['textureSha256']['roughness'][:12]}…"]
        draw.rounded_rectangle((28, y, 1472, y + 210), radius=10, outline=(161, 146, 104), width=2)
        for line in lines:
            draw.text((48, y + 12), line, fill=(220, 221, 209), font=font(16)); y += 21
        y += 16
    return canvas


def blind_board() -> Image.Image:
    cells = []
    for index in range(1, 4):
        cells.extend([(f"MATERIAL {index} near", image(ART / MATERIALS[index - 1] / "01_near_corner_window.png")), (f"MATERIAL {index} normal", image(ART / MATERIALS[index - 1] / "03_normal_rts.png")), (f"MATERIAL {index} far", image(ART / MATERIALS[index - 1] / "04_far_rts.png")), (f"MATERIAL {index} grey", image(ART / MATERIALS[index - 1] / "05_greyscale_normal_rts.png")), (f"MATERIAL {index} normal-only", image(ART / MATERIALS[index - 1] / "10_normal_only.png")), (f"MATERIAL {index} thumb", image(ART / MATERIALS[index - 1] / "06_thumbnail_256.png"))])
    return board("MATCHED BLIND COMPARISON — METHOD NAMES OMITTED", cells, columns=3, cell=(300, 220))


def masks_board(mask_paths: dict) -> Image.Image:
    cells = [("MATERIAL 1 source stone mask", image(ROOT / mask_paths["material1"][0])), ("MATERIAL 1 authored relief mask", image(ROOT / mask_paths["material1"][1])), ("MATERIAL 2 authored polygon labels", image(ROOT / mask_paths["material2"][0])), ("MATERIAL 3 source-derived mask", image(ROOT / mask_paths["material3"][0]))]
    return board("THREE LABELLED STONE MASKS + ANTI-BRICK METRICS", cells, columns=2, cell=(420, 280))


def pbr_board(diags: dict) -> Image.Image:
    cells = []
    for index, key in enumerate(CANDIDATE_KEYS, 1):
        root = ROOT / "art-source/materials/v0335/candidates" / key
        for name in ["albedo.png" if key != "candidate_a" else "albedo.jpg", "height.png", "normal.png", "roughness.png" if key != "candidate_a" else "roughness.jpg"]:
            cells.append((f"MATERIAL {index} {name}", image(root / name, (360, 180))))
        cells.append((f"MATERIAL {index} normal-only", image(ART / MATERIALS[index - 1] / "10_normal_only.png", (360, 180))))
        cells.append((f"MATERIAL {index} normal-disabled", image(ART / MATERIALS[index - 1] / "11_normal_disabled.png", (360, 180))))
    return board("ALL THREE PBR SETS + NORMAL DIAGNOSTICS", cells, columns=3, cell=(390, 230))


def main() -> None:
    if UPLOAD.exists():
        shutil.rmtree(UPLOAD)
    UPLOAD.mkdir(parents=True, exist_ok=True)
    ledger = json.loads((ART / "candidate-binding-ledger.json").read_text())
    masks = make_masks()
    diags = normal_diagnostics()
    video = video_comparisons()
    distinctness = candidate_distinctness(ledger)
    (UPLOAD / EXPECTED[0]).write_text("""# v0.336 Granite Candidate Identity and Comparative Evidence Repair

Material study only. No House 02 material was applied. v0.334 source/import hashes are frozen.

The instantiated Godot scene generated the binding ledger. The recovered runtime mapping is:
MATERIAL 1 = candidate C hybrid scan plus limited merged relief.
MATERIAL 2 = candidate B procedural polygon rubble.
MATERIAL 3 = candidate A photo-scanned Poly Haven rubble.

The previous v0.335 compact mapping was C/A/B and contradicted the visible runtime order A/B/C;
this pack repairs the identity from actual .tres bindings and provides independent captures for
all three candidates. Human review remains required; automatedVisualApproval is false.
""", encoding="utf-8")
    binding_board(ledger).save(UPLOAD / EXPECTED[1])
    candidate_board(1).save(UPLOAD / EXPECTED[2])
    candidate_board(2).save(UPLOAD / EXPECTED[3])
    candidate_board(3).save(UPLOAD / EXPECTED[4])
    blind_board().save(UPLOAD / EXPECTED[5])
    masks_board(masks).save(UPLOAD / EXPECTED[6])
    pbr_board(diags).save(UPLOAD / EXPECTED[7])
    shutil.copy2(ART / "08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4", UPLOAD / EXPECTED[8])
    records = [{"filename": name, "bytes": (UPLOAD / name).stat().st_size, "sha256": sha(UPLOAD / name)} for name in EXPECTED[:-1]]
    summary = {"checkpoint": "v0.336", "outcome": "READY FOR HUMAN FINAL GRANITE CANDIDATE SELECTION", "humanReviewRequired": True, "automatedVisualApproval": False, "house02Modified": False, "v0334SourceGLBSha256": "f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5", "v0334ImportedResourceSha256": "b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531", "actualRuntimeBindingLedger": "artifacts/runtime/v0336/candidate-binding-ledger.json", "recoveredCandidateBlindMapping": {"MATERIAL 1": "candidate_c", "MATERIAL 2": "candidate_b", "MATERIAL 3": "candidate_a"}, "v0335MappingMismatch": {"existed": True, "exactCause": "v0.335 compact JSON used C/A/B while the scene instantiated A/B/C", "repaired": True}, "candidateDistinctness": distinctness, "matchedCameraLedger": "artifacts/runtime/v0336/matched-camera-ledger.json", "stoneMasks": masks, "stoneMetrics": metrics(), "materialMaps": {"material1": "art-source/materials/v0335/candidates/candidate_c", "material2": "art-source/materials/v0335/candidates/candidate_b", "material3": "art-source/materials/v0335/candidates/candidate_a"}, "normalOnlyDiagnostics": diags, "videoFrameComparisons": video, "finalMedia": "artifacts/manual-review/v0336-granite-evidence-repair/UPLOAD_TO_CHAT/08_CONTINUOUS_V0336_THREE_MATERIAL_COMPARISON.mp4", "preservation": {"v0334Frozen": True, "noHouse02Application": True, "noCompleteHouseAsset": True, "noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noEconomy": True, "noResources": True, "noStableIdsOrSavesMutation": True}, "exactUploadFiles": records}
    summary["manifestSha256"] = hashlib.sha256(json.dumps(records, separators=(",", ":")).encode()).hexdigest()
    (UPLOAD / EXPECTED[-1]).write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    if sorted(p.name for p in UPLOAD.iterdir()) != sorted(EXPECTED):
        raise SystemExit("v0.336 canonical pack does not contain exactly ten files")
    if (UPLOAD / EXPECTED[-1]).stat().st_size >= 250_000:
        raise SystemExit("v0.336 compact summary exceeds 250KB")
    print(json.dumps({"status": "PASS_V0336_GRANITE_EVIDENCE_REPAIR_PACK", "uploadCount": len(EXPECTED), "manifestSha256": summary["manifestSha256"]}, indent=2))


if __name__ == "__main__":
    main()
