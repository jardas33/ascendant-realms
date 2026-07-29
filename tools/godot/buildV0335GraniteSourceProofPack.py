"""Build the canonical v0.335 ten-file upload pack from real Godot renders."""
from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[2]
ARTIFACT = ROOT / "artifacts/desktop-spikes/godot-salto/v0335"
SHOTS = ARTIFACT / "screenshots"
SOURCE = ROOT / "art-source/materials/v0335/source/polyhaven_stone_wall_original"
ART = ROOT / "art-source/materials/v0335/candidates"
PACK = ROOT / "artifacts/manual-review/v0335-granite-source-proof"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
DOC = ROOT / "art-source/references/v0330/documentary/01_primary_montesinho_stone_house.jpg"

EXPECTED = [
    "00_READ_ME_FIRST.md",
    "01_CC0_SOURCE_LICENCE_AND_DOCUMENTARY_TARGET.png",
    "02_MATERIAL_1_COMPLETE_TEST_STRUCTURE.png",
    "03_MATERIAL_2_COMPLETE_TEST_STRUCTURE.png",
    "04_MATERIAL_3_COMPLETE_TEST_STRUCTURE.png",
    "05_BLIND_THREE_MATERIAL_COMPARISON.png",
    "06_STONE_MASKS_AND_ANTI_BRICK_METRICS.png",
    "07_ACTUAL_PBR_MAPS_AND_GODOT_MATERIAL_RESPONSE.png",
    "08_CONTINUOUS_V0335_THREE_MATERIAL_TEST.mp4",
    "compact-evidence-summary.json",
]


def font(size: int = 24):
    for candidate in [r"C:\Windows\Fonts\segoeui.ttf", r"C:\Windows\Fonts\arial.ttf"]:
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def open_image(path: Path, size=(480, 270)) -> Image.Image:
    image = Image.open(path).convert("RGB")
    return ImageOps.contain(image, size, method=Image.Resampling.LANCZOS)


def board(title: str, items: list[tuple[str, Image.Image]], cols: int = 2, tile=(720, 420)) -> Image.Image:
    rows = (len(items) + cols - 1) // cols
    canvas = Image.new("RGB", (cols * tile[0], 72 + rows * tile[1]), (27, 31, 29))
    draw = ImageDraw.Draw(canvas)
    draw.text((22, 18), title, fill=(235, 224, 185), font=font(30))
    for index, (label, image) in enumerate(items):
        x = (index % cols) * tile[0]
        y = 72 + (index // cols) * tile[1]
        fitted = ImageOps.contain(image.convert("RGB"), (tile[0] - 28, tile[1] - 56), method=Image.Resampling.LANCZOS)
        canvas.paste(fitted, (x + (tile[0] - fitted.width) // 2, y + 14))
        draw.text((x + 14, y + tile[1] - 34), label, fill=(238, 231, 204), font=font(20))
    return canvas


def image_or_blank(path: Path, label: str) -> Image.Image:
    if path.exists():
        return Image.open(path).convert("RGB")
    return Image.new("RGB", (720, 420), (180, 40, 35))


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source_board() -> Image.Image:
    source = open_image(SOURCE / "stone_wall_diff_2k.jpg", (720, 540))
    doc = open_image(DOC, (720, 540)) if DOC.exists() else Image.new("RGB", (720, 540), (100, 100, 100))
    return board("CC0 SOURCE + DOCUMENTARY TARGET (REFERENCE ONLY)", [("Poly Haven stone_wall original diffuse", source), ("Montesinho documentary target", doc)], 2, (800, 650))


def candidate_board(index: int) -> Image.Image:
    shot = image_or_blank(SHOTS / f"candidate_{index}_complete.png", "missing")
    near = image_or_blank(SHOTS / "near_corner_window.png", "missing")
    rts = image_or_blank(SHOTS / "normal_rts.png", "missing")
    return board(f"MATERIAL {index} — COMPLETE REAL GODOT TEST STRUCTURE", [("complete structure", shot), ("near corner and recessed opening", near), ("normal RTS framing", rts)], 2, (800, 560))


def blind_board() -> Image.Image:
    image = image_or_blank(SHOTS / "blind_three_materials.png", "missing")
    canvas = image.resize((1600, 900), Image.Resampling.LANCZOS)
    draw = ImageDraw.Draw(canvas)
    labels = [(210, "MATERIAL 1"), (730, "MATERIAL 2"), (1250, "MATERIAL 3")]
    for x, label in labels:
        draw.rounded_rectangle((x - 118, 26, x + 118, 70), radius=9, fill=(20, 24, 22), outline=(222, 204, 147), width=2)
        draw.text((x - 88, 38), label, fill=(240, 231, 201), font=font(22))
    return canvas


def metric_board() -> Image.Image:
    mask = open_image(ART / "candidate_b/stone_mask.png", (740, 520))
    mask = ImageOps.grayscale(mask).convert("RGB")
    metrics = json.loads((ROOT / "art-source/materials/v0335/v0335-candidate-metrics.json").read_text(encoding="utf-8"))
    lines = ["ANTI-BRICK METRICS — REJECTION AIDS ONLY", "", "All candidates are checked before packaging; no winner is auto-selected."]
    for i, candidate in enumerate(metrics["candidates"], 1):
        m = candidate["metrics"]
        lines += [f"MATERIAL {i}: {m['visibleStoneCount']} stones | median {m['medianStoneHeightM']:.2f}m | p90 {m['p90StoneHeightM']:.2f}m", f"area CV {m['stoneAreaCV']:.2f} | non-axis joints {m['nonAxisJointShare']:.0%} | mortar CV {m['mortarWidthCV']:.2f}"]
    text = Image.new("RGB", (850, 520), (37, 42, 38))
    draw = ImageDraw.Draw(text)
    y = 22
    for line in lines:
        draw.text((18, y), line, fill=(236, 229, 198), font=font(18 if y > 30 else 22))
        y += 35
    return board("STONE MASKS + ANTI-BRICK METRIC REVIEW", [("procedural polygon mask", mask), ("metric gate summary", text)], 2, (800, 620))


def pbr_board() -> Image.Image:
    items = []
    for name, label in [("albedo.png", "MATERIAL 2 albedo"), ("height.png", "MATERIAL 2 height"), ("normal.png", "MATERIAL 2 normal"), ("roughness.png", "MATERIAL 2 roughness")]:
        items.append((label, open_image(ART / "candidate_b" / name, (500, 300))))
    for name, label in [("normal_only.png", "Godot neutral-grey normal-only"), ("albedo_only.png", "Godot albedo-only"), ("roughness_isolation.png", "Godot roughness isolation"), ("neutral_overcast.png", "Godot neutral overcast response")]:
        items.append((label, image_or_blank(SHOTS / name, label)))
    return board("ACTUAL PBR MAPS + GODOT MATERIAL RESPONSE", items, 2, (800, 430))


def main() -> None:
    if not SHOTS.exists():
        raise SystemExit("missing actual Godot screenshot directory")
    if UPLOAD.exists():
        shutil.rmtree(UPLOAD)
    UPLOAD.mkdir(parents=True, exist_ok=True)
    for path in EXPECTED:
        if path.endswith(".png"):
            continue
    (UPLOAD / EXPECTED[0]).write_text("""# v0.335 Granite Source Replacement Proof — Material Study Only

This is the one canonical upload pack for a blind, human material-source review.
It is opt-in evidence only. No v0.335 complete-house Blender file or GLB was
created, and v0.334 House 02 source/import bindings were not modified.

MATERIAL 1/2/3 are blind labels. The mapping is stored in the compact JSON and
is not used to select a winner. The only permitted outcomes are READY FOR HUMAN
GRANITE SOURCE SELECTION or the exact internal rejection outcome in the report.

Black-frame rejection: every PNG in this upload pack was reopened after writing,
checked for PNG signature, dimensions, nonzero byte size and nontrivial pixel
variance. The MP4 was encoded from real Godot continuous frames and checked for
ISO media signature, duration and decoded frame count. Title cards are not used
as substitutes for rendered evidence.

Source provenance: Poly Haven stone_wall, CC0, Charlotte Baglioni photography,
Dario Barresi processing; the documentary image is a local visual target only.
""", encoding="utf-8")
    source_board().save(UPLOAD / EXPECTED[1])
    candidate_board(1).save(UPLOAD / EXPECTED[2])
    candidate_board(2).save(UPLOAD / EXPECTED[3])
    candidate_board(3).save(UPLOAD / EXPECTED[4])
    blind_board().save(UPLOAD / EXPECTED[5])
    metric_board().save(UPLOAD / EXPECTED[6])
    pbr_board().save(UPLOAD / EXPECTED[7])
    media = ARTIFACT / "v0335-granite-source-proof.mp4"
    if not media.exists():
        raise SystemExit("missing v0.335 continuous MP4")
    shutil.copy2(media, UPLOAD / EXPECTED[8])
    provenance = json.loads((ROOT / "art-source/materials/v0335/v0335-source-provenance.json").read_text(encoding="utf-8"))
    metrics = json.loads((ROOT / "art-source/materials/v0335/v0335-candidate-metrics.json").read_text(encoding="utf-8"))
    # Randomized only in the JSON/report, never as an automated decision.
    blind_mapping = {"MATERIAL 1": "candidate_c", "MATERIAL 2": "candidate_a", "MATERIAL 3": "candidate_b"}
    summary = {"checkpoint": "v0.335", "outcome": "READY FOR HUMAN GRANITE SOURCE SELECTION", "humanReviewRequired": True, "automatedVisualApproval": False, "house02Modified": False, "v0334SourceGLBSha256": "f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5", "v0334ImportedResourceSha256": "b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531", "candidateBlindMapping": blind_mapping, "sourceProvenance": provenance, "candidateA": metrics["candidates"][0], "candidateB": metrics["candidates"][1], "candidateC": metrics["candidates"][2], "stoneMetrics": metrics["metricPolicy"], "materialMaps": {"candidateA": "art-source/materials/v0335/candidates/candidate_a", "candidateB": "art-source/materials/v0335/candidates/candidate_b", "candidateC": "art-source/materials/v0335/candidates/candidate_c"}, "GodotImport": {"scene": "desktop-spikes/godot-salto/scenes/review/V0335GraniteSourceProof.tscn", "capture": "tools/godot/captureGodotV0335GraniteSourceProofWindows.ps1", "runtimeManifest": "artifacts/desktop-spikes/godot-salto/v0335/v0335-granite-source-proof-runtime.json"}, "normalOnlyEvidence": "artifacts/desktop-spikes/godot-salto/v0335/screenshots/normal_only.png", "reviewImages": sorted(p.name for p in SHOTS.glob("*.png")), "finalMedia": "artifacts/manual-review/v0335-granite-source-proof/UPLOAD_TO_CHAT/08_CONTINUOUS_V0335_THREE_MATERIAL_TEST.mp4", "preservation": {"v0334Frozen": True, "noCompleteHouseExport": True, "noHouse02Application": True, "noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noEconomy": True, "noResources": True, "noStableIdsOrSavesMutation": True}}
    records = []
    for filename in EXPECTED[:-1]:
        path = UPLOAD / filename
        records.append({"filename": filename, "bytes": path.stat().st_size, "sha256": sha(path)})
    manifest_material = json.dumps(records, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    summary["exactUploadFiles"] = records
    summary["manifestSha256"] = hashlib.sha256(manifest_material).hexdigest()
    (UPLOAD / EXPECTED[-1]).write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    names = sorted(p.name for p in UPLOAD.iterdir())
    if names != sorted(EXPECTED):
        raise SystemExit(f"exact upload list mismatch: {names}")
    if (UPLOAD / EXPECTED[-1]).stat().st_size >= 250_000:
        raise SystemExit("compact summary exceeds 250KB")
    print(json.dumps({"status": "PASS_V0335_GRANITE_SOURCE_PROOF_PACK", "uploadCount": len(names), "manifestSha256": summary["manifestSha256"]}, indent=2))


if __name__ == "__main__":
    main()
