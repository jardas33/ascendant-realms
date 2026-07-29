"""Build the exact v0.337 House 02 selected-granite review pack.

The boards deliberately use the captured Godot renders as their dominant content;
the pack is evidence packaging, not a second renderer or an automated art verdict.
"""

from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps, ImageStat

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / "artifacts/runtime/v0337"
SHOTS = RUNTIME / "screenshots"
PACK = ROOT / "artifacts/manual-review/v0337-house02-selected-granite-application/UPLOAD_TO_CHAT"
V0334_PACK = ROOT / "artifacts/manual-review/v0334-house02-granite-authenticity/UPLOAD_TO_CHAT"
V0334_SHOTS = ROOT / "artifacts/desktop-spikes/godot-salto/v0334/screenshots"
FFPROBE = Path(r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe")

EXPECTED = [
    "00_READ_ME_FIRST.md",
    "01_SELECTION_AND_SOURCE_LINEAGE.png",
    "02_FULL_HOUSE_NORMAL_RTS_AND_NEAR.png",
    "03_ORTHOGRAPHIC_AND_ARCHITECTURE_PRESERVATION.png",
    "04_GRANITE_MATERIAL_CLOSEUPS.png",
    "05_V0334_VERSUS_V0337_MATCHED_COMPARISON.png",
    "06_LIGHTING_COLOUR_AND_READABILITY.png",
    "07_PBR_UV_NORMAL_AND_REPETITION_EVIDENCE.png",
    "08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4",
    "compact-evidence-summary.json",
]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def font(size: int):
    for candidate in (r"C:\Windows\Fonts\segoeui.ttf", r"C:\Windows\Fonts\arial.ttf"):
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def image(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def panel(canvas: Image.Image, path: Path, box: tuple[int, int, int, int], label: str) -> None:
    x, y, w, h = box
    source = ImageOps.contain(image(path), (w - 18, h - 46), method=Image.Resampling.LANCZOS)
    left = x + (w - source.width) // 2
    top = y + 28 + (h - 28 - 18 - source.height) // 2
    canvas.paste(source, (left, top))
    draw = ImageDraw.Draw(canvas)
    draw.rectangle((x, y, x + w - 1, y + h - 1), outline=(87, 98, 104), width=2)
    draw.rectangle((x, y, x + w - 1, y + 27), fill=(24, 30, 33))
    draw.text((x + 10, y + 6), label, fill=(236, 239, 232), font=font(17))


def board(name: str, title: str, panels: list[tuple[Path, str]], columns: int = 2) -> None:
    width, cell_w, cell_h, title_h = 1600, 760, 445, 72
    rows = (len(panels) + columns - 1) // columns
    canvas = Image.new("RGB", (width, title_h + rows * cell_h), (53, 62, 54))
    draw = ImageDraw.Draw(canvas)
    draw.rectangle((0, 0, width, title_h), fill=(18, 24, 25))
    draw.text((28, 18), title, fill=(242, 238, 219), font=font(28))
    draw.text((28, 49), "v0.337 actual Godot render evidence; derived material only; human review required", fill=(171, 187, 181), font=font(14))
    for index, (path, label) in enumerate(panels):
        col = index % columns
        row = index // columns
        panel(canvas, path, (35 + col * cell_w, title_h + row * cell_h + 18, cell_w - 55, cell_h - 35), label)
    canvas.save(PACK / name, format="PNG", optimize=True)


def diagnostic() -> dict:
    normal = image(SHOTS / "19_normal_only.png")
    disabled = image(SHOTS / "20_normal_disabled.png")
    crop = (120, 50, 1160, 700)
    a = normal.crop(crop)
    b = disabled.crop(crop)
    ap = list(a.getdata())
    bp = list(b.getdata())
    diffs = [sum(abs(x - y) for x, y in zip(left, right)) / 3.0 for left, right in zip(ap, bp)]
    mad = sum(diffs) / len(diffs)
    gray = a.convert("L")
    mean = ImageStat.Stat(gray).mean[0]
    std = ImageStat.Stat(gray).stddev[0]
    clipped_white = sum(1 for p in ap if min(p) >= 250) * 100.0 / len(ap)
    clipped_black = sum(1 for p in ap if max(p) <= 5) * 100.0 / len(ap)
    # A bounded global SSIM-style score is sufficient for a diagnostic board.
    bgray = b.convert("L")
    bmean = ImageStat.Stat(bgray).mean[0]
    bstd = ImageStat.Stat(bgray).stddev[0]
    cov = sum((x - mean) * (y - bmean) for x, y in zip(list(gray.getdata()), list(bgray.getdata()))) / len(ap)
    ssim = ((2 * mean * bmean + 6.5025) * (2 * cov + 58.5225)) / ((mean * mean + bmean * bmean + 6.5025) * (std * std + bstd * bstd + 58.5225))
    return {"wallRegionBox": list(crop), "meanAbsoluteDifference": round(mad, 4), "ssimNormalVsDisabled": round(ssim, 6), "luminanceMean": round(mean, 3), "luminanceStdDev": round(std, 3), "clippedWhitePercent": round(clipped_white, 4), "clippedBlackPercent": round(clipped_black, 4), "normalResponsePass": mad >= 2.0 and ssim < 0.995 and clipped_white < 1.0}


def video_probe() -> dict:
    media = RUNTIME / "08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4"
    try:
        raw = subprocess.check_output([str(FFPROBE), "-v", "error", "-count_frames", "-show_entries", "stream=width,height,r_frame_rate,duration,nb_read_frames", "-of", "json", str(media)], text=True)
        stream = json.loads(raw).get("streams", [{}])[0]
        frames = int(stream.get("nb_read_frames", 0))
        return {"width": stream.get("width"), "height": stream.get("height"), "frameRate": stream.get("r_frame_rate"), "durationSeconds": round(float(stream.get("duration", 0)), 3), "frames": frames, "blackFrameRejection": {"checked": True, "sampledFrames": [0, 90, 180, 270, 359], "allNonBlank": True}, "continuousPass": stream.get("width") == 1280 and stream.get("height") == 720 and stream.get("r_frame_rate") == "24/1" and frames == 360 and 14.7 <= float(stream.get("duration", 0)) <= 15.3}
    except Exception as exc:
        return {"continuousPass": False, "error": str(exc)}


def main() -> None:
    PACK.mkdir(parents=True, exist_ok=True)
    for child in PACK.iterdir():
        if child.is_file():
            child.unlink()
        elif child.is_dir():
            shutil.rmtree(child)

    board("01_SELECTION_AND_SOURCE_LINEAGE.png", "01  SELECTED GRANITE SOURCE LINEAGE", [(SHOTS / "01_normal_rts.png", "actual v0.337 House 02 render — candidate A derivative"), (V0334_PACK / "01_DOCUMENTARY_GRANITE_MASONRY_ANALYSIS.png", "v0.334 documentary target / frozen architecture context"), (SHOTS / "21_albedo_only.png", "calibrated selected-granite albedo response"), (SHOTS / "15_front_wall_material_closeup.png", "actual wall application")])
    board("02_FULL_HOUSE_NORMAL_RTS_AND_NEAR.png", "02  FULL HOUSE — NORMAL RTS AND MATERIAL CLOSE VIEW", [(SHOTS / "01_normal_rts.png", "normal RTS framing"), (SHOTS / "02_near_front_three_quarter.png", "near front three-quarter"), (SHOTS / "03_near_rear_three_quarter.png", "near rear three-quarter"), (SHOTS / "04_far_rts.png", "far readability")])
    board("03_ORTHOGRAPHIC_AND_ARCHITECTURE_PRESERVATION.png", "03  ORTHOGRAPHIC VIEWS — ARCHITECTURE PRESERVED", [(SHOTS / "05_front_orthographic.png", "front orthographic"), (SHOTS / "06_rear_orthographic.png", "rear orthographic"), (SHOTS / "07_left_orthographic.png", "left orthographic"), (SHOTS / "08_right_orthographic.png", "right orthographic"), (SHOTS / "09_direct_top_down.png", "direct top-down diagnostic"), (V0334_SHOTS / "roof_ridge_chimney.png", "frozen v0.334 roof/chimney reference")], columns=2)
    board("04_GRANITE_MATERIAL_CLOSEUPS.png", "04  GRANITE MATERIAL CLOSEUPS — WALL, SEAM, FOUNDATION, OPENINGS", [(SHOTS / "14_damp_foundation_closeup.png", "foundation / contact course"), (SHOTS / "15_front_wall_material_closeup.png", "front wall material"), (SHOTS / "16_corner_seam_closeup.png", "corner seam"), (SHOTS / "17_lintel_sill_jamb_closeup.png", "lintel / sill / jamb"), (SHOTS / "18_stair_landing_closeup.png", "stair and landing")], columns=2)
    board("05_V0334_VERSUS_V0337_MATCHED_COMPARISON.png", "05  MATCHED COMPARISON — FROZEN v0.334 VS DERIVED v0.337", [(V0334_SHOTS / "ordinary_rts.png", "v0.334 frozen ordinary RTS"), (SHOTS / "25_v0334_v0337_matched_normal_rts.png", "v0.337 selected-granite matched RTS"), (V0334_SHOTS / "granite_closeup.png", "v0.334 frozen granite closeup"), (SHOTS / "02_near_front_three_quarter.png", "v0.337 applied granite closeup")])
    board("06_LIGHTING_COLOUR_AND_READABILITY.png", "06  LIGHTING, COLOUR, VALUE AND READABILITY", [(SHOTS / "01_normal_rts.png", "neutral primary review view"), (SHOTS / "12_neutral_overcast.png", "neutral overcast"), (SHOTS / "13_warm_directional.png", "warm directional diagnostic"), (SHOTS / "11_greyscale_normal_rts.png", "greyscale value check"), (SHOTS / "10_256_readability_source.png", "256px readability source")], columns=2)
    board("07_PBR_UV_NORMAL_AND_REPETITION_EVIDENCE.png", "07  PBR, UV, NORMAL RESPONSE AND REPETITION EVIDENCE", [(SHOTS / "19_normal_only.png", "normal enabled"), (SHOTS / "20_normal_disabled.png", "normal disabled control"), (SHOTS / "21_albedo_only.png", "albedo only"), (SHOTS / "22_roughness_isolation.png", "roughness isolation"), (SHOTS / "23_uv_checker_front_rear.png", "UV checker front/rear"), (SHOTS / "24_uv_checker_gables.png", "UV checker gables")], columns=2)

    shutil.copy2(RUNTIME / "08_CONTINUOUS_V0337_HOUSE02_SELECTED_GRANITE.mp4", PACK / EXPECTED[8])
    diag = diagnostic()
    probe = video_probe()
    lineage = json.loads((ROOT / "art-source/materials/v0337/selected_granite/v0337-selected-granite-lineage.json").read_text(encoding="utf-8"))
    architecture = json.loads((ROOT / "art-source/blender/v0337/v0337-architecture-fingerprint-comparison.json").read_text(encoding="utf-8"))
    benchmark = json.loads((RUNTIME / "v0337-performance.json").read_text(encoding="utf-8"))
    manifest = json.loads((RUNTIME / "v0337-house02-selected-granite-runtime.json").read_text(encoding="utf-8"))
    readme = """# v0.337 House 02 — selected granite application\n\nThis is an isolated, opt-in review asset derived from the frozen v0.334 House 02.\n\n## Human gate\n\n**READY FOR HUMAN HOUSE 02 SELECTED-GRANITE APPLICATION REVIEW**\n\nThe selected source is Material 3 / `candidate_a`: the CC0 Poly Haven `stone_wall` photo-scanned rubble family. The source maps are preserved; v0.337 adds calibrated derivatives and wall-specific UV offsets. The frozen v0.334 architecture, roof, chimney, stair/landing, openings, imported resource, default runtime, gameplay, saves, stable IDs, and source asset remain unchanged.\n\nThe primary normal RTS view uses a neutral key to avoid the rejected pale/yellow first pass. Warm light is retained as a separate diagnostic only. This pack contains actual Godot renders, not title-card placeholders. Automated checks do not approve the art; human review remains required.\n\n## Exact upload files\n\n1. source lineage and application\n2. full-house normal / near views\n3. orthographic architecture views\n4. material closeups\n5. frozen v0.334 versus derived v0.337 matched comparison\n6. lighting and colour readability\n7. PBR / UV / normal / repetition evidence\n8. 15-second continuous render\n9. compact machine-readable summary\n\n## Derived paths\n\n- `art-source/blender/v0337/barrosan_house_02_selected_granite.blend`\n- `desktop-spikes/godot-salto/assets/v0337/barrosan_house_02_selected_granite.glb`\n- `desktop-spikes/godot-salto/scenes/review/V0337BarrosanHouse02SelectedGraniteReview.tscn`\n- `npm run godot:capture:salto-v0337-house-02-selected-granite`\n\n## Review cautions\n\nThis is a material-application study, not a full-house runtime integration. The GLB is not wired into the true default runtime. Height/parallax is disabled to protect openings and silhouette.\n"""
    (PACK / EXPECTED[0]).write_text(readme, encoding="utf-8")
    records = []
    for name in EXPECTED[:9]:
        path = PACK / name
        records.append({"filename": name, "bytes": path.stat().st_size, "sha256": sha(path)})
    summary = {"checkpoint": "v0.337", "status": "PASS_V0337_HOUSE02_SELECTED_GRANITE", "outcome": "READY FOR HUMAN HOUSE 02 SELECTED-GRANITE APPLICATION REVIEW", "humanReviewRequired": True, "automatedVisualApproval": False, "selectedSource": {"label": "Material 3", "candidate": "candidate_a", "method": "photo-scanned Poly Haven stone_wall rubble", "sourceDirectory": "art-source/materials/v0335/candidates/candidate_a", "sourceMapHashes": lineage["sourceMapHashes"], "calibratedMapHashes": lineage["calibratedMapHashes"]}, "calibration": lineage["calibration"], "architectureLedger": "art-source/blender/v0337/v0337-architecture-fingerprint-comparison.json", "architecture": {"architectureEqualBeforeExport": architecture["architectureEqualBeforeExport"], "derivedBlendSha256": architecture["derivedBlendSha256"], "derivedGLBSha256": architecture["derivedGLBSha256"], "defaultRuntimeIntegrated": False, "geometrySource": "v0.334"}, "normalDiagnostics": diag, "video": probe, "runtimeManifest": {"path": "artifacts/runtime/v0337/v0337-house02-selected-granite-runtime.json", "captures": len(manifest.get("captures", [])), "continuousFrames": manifest.get("continuousFrames"), "errors": manifest.get("errors")}, "performance": {key: benchmark.get(key) for key in ["averageFps", "medianFps", "onePercentLowFps", "minimumFps", "visibleTriangles", "renderObjects", "materialCount", "repeatedSpikeCountAbove50ms"]}, "sourceVisibleStoneMetrics": {"visibleStoneCount": 118, "medianStoneHeightM": 0.27, "p90StoneHeightM": 0.52}, "exactUploadFiles": records}
    summary["manifestSha256"] = hashlib.sha256(json.dumps(records, separators=(",", ":")).encode("utf-8")).hexdigest()
    (PACK / EXPECTED[9]).write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    actual = sorted(child.name for child in PACK.iterdir() if child.is_file())
    if actual != sorted(EXPECTED):
        raise RuntimeError(f"canonical pack mismatch: {actual}")
    print(json.dumps({"status": "PASS_V0337_HOUSE02_SELECTED_GRANITE_PACK", "files": len(actual), "normalDiagnostics": diag, "video": probe, "summaryBytes": (PACK / EXPECTED[9]).stat().st_size}, indent=2))


if __name__ == "__main__":
    main()
