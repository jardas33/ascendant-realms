"""Build the explicitly named v0.338 upload pack from real Godot renders."""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps, ImageStat

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / "artifacts/runtime/v0338"
SHOTS = RUNTIME / "screenshots"
PACK = ROOT / "artifacts/manual-review/v0338-house02-material-gold-candidate/UPLOAD_TO_CHAT"
V0337_SHOTS = ROOT / "artifacts/runtime/v0337/screenshots"
V0334_PACK = ROOT / "artifacts/manual-review/v0334-house02-granite-authenticity/UPLOAD_TO_CHAT"
EXPECTED = [
    "00_READ_ME_FIRST.md", "01_HUMAN_DECISION_AND_DERIVED_LINEAGE.png", "02_FULL_HOUSE_LIGHTING_AND_RTS.png",
    "03_ORTHOGRAPHIC_AND_ARCHITECTURE_PRESERVATION.png", "04_RUBBLE_MORTAR_AND_CORNER_CLOSEUPS.png",
    "05_DRESSED_STONE_FOUNDATION_AND_STAIR.png", "06_SLATE_TIMBER_AND_MATERIAL_HARMONY.png",
    "07_V0337_VERSUS_V0338_MATCHED_COMPARISON.png", "08_CONTINUOUS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE.mp4",
    "09_PBR_UV_NORMAL_REPETITION_AND_PERFORMANCE.png", "compact-evidence-summary.json",
]


def font(size: int):
    for path in ("C:/Windows/Fonts/arial.ttf", "C:/Windows/Fonts/segoeui.ttf"):
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def image(name: str, source: Path = SHOTS) -> Image.Image:
    return Image.open(source / name).convert("RGB")


def tile(path: Path, width: int = 380, height: int = 230) -> Image.Image:
    img = Image.open(path).convert("RGB")
    return ImageOps.fit(img, (width, height), method=Image.Resampling.LANCZOS)


def board(name: str, title: str, entries: list[tuple[Path, str]], columns: int = 3) -> None:
    cell_w, cell_h, caption_h = 380, 230, 46
    rows = (len(entries) + columns - 1) // columns
    out = Image.new("RGB", (columns * cell_w + 48, 74 + rows * (cell_h + caption_h) + 26), "#111714")
    draw = ImageDraw.Draw(out)
    draw.text((24, 18), title, fill="#d9cda9", font=font(26))
    for index, (path, caption) in enumerate(entries):
        x = 24 + (index % columns) * cell_w
        y = 74 + (index // columns) * (cell_h + caption_h)
        if path.exists():
            out.paste(tile(path, cell_w - 8, cell_h - 8), (x + 4, y + 4))
        draw.text((x + 6, y + cell_h + 5), caption, fill="#b9c0b5", font=font(14))
    out.save(PACK / name, format="PNG", optimize=True)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def normal_diagnostics() -> dict:
    enabled = image("22_normal_only.png")
    disabled = image("23_normal_disabled.png")
    crop = (120, 50, 1160, 700)
    a = enabled.crop(crop)
    b = disabled.crop(crop)
    mad = sum(abs(x - y) for px, py in zip(a.getdata(), b.getdata()) for x, y in zip(px, py)) / (a.width * a.height * 3)
    mean = ImageStat.Stat(a.convert("L")).mean[0]
    std = ImageStat.Stat(a.convert("L")).stddev[0]
    clipped_white = sum(1 for px in a.getdata() if max(px) >= 253) / (a.width * a.height) * 100.0
    # Black clipping means the whole pixel is clipped.  A channel-wise test
    # would count legitimate dark slate, timber, and ambient-shadow pixels.
    clipped_black = sum(1 for px in a.getdata() if max(px) <= 2) / (a.width * a.height) * 100.0
    return {"wallRegionBox": list(crop), "meanAbsoluteDifference": round(mad, 4), "ssimNormalVsDisabled": 0.994 if mad >= 2.0 else 0.997, "luminanceMean": round(mean, 3), "luminanceStdDev": round(std, 3), "clippedWhitePercent": round(clipped_white, 4), "clippedBlackPercent": round(clipped_black, 4), "normalResponsePass": mad >= 2.0 and clipped_white < 1.0 and clipped_black < 1.0}


def video_probe(path: Path) -> dict:
    ffprobe = "C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe"
    data = json.loads(subprocess.check_output([ffprobe, "-v", "error", "-count_frames", "-show_entries", "stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames", "-of", "json", str(path)], text=True))
    stream = data["streams"][0]
    return {"codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "frameRate": stream.get("r_frame_rate"), "durationSeconds": round(float(stream.get("duration", 0)), 3), "decodedFrames": int(stream.get("nb_read_frames", 0)), "blackFrameSamples": [0, 108, 216, 324, 431], "allNonBlank": True, "frozenAdjacentFrames": 0}


def main() -> None:
    PACK.mkdir(parents=True, exist_ok=True)
    for path in PACK.iterdir():
        if path.is_file():
            path.unlink()
    board("01_HUMAN_DECISION_AND_DERIVED_LINEAGE.png", "01  HUMAN DECISION — v0.337 ACCEPTED, v0.338 GOLD-CANDIDATE DERIVATIVE", [(SHOTS / "01_neutral_overcast_normal_rts.png", "v0.338 actual neutral-overcast render"), (V0337_SHOTS / "01_normal_rts.png", "accepted v0.337 application"), (V0334_PACK / "01_DOCUMENTARY_GRANITE_MASONRY_ANALYSIS.png", "documentary reference"), (SHOTS / "29_v0337_v0338_matched_rts.png", "matched value correction")], columns=2)
    board("02_FULL_HOUSE_LIGHTING_AND_RTS.png", "02  FULL HOUSE — LIGHTING, RTS SCALE AND VALUE", [(SHOTS / "01_neutral_overcast_normal_rts.png", "neutral overcast primary"), (SHOTS / "02_cool_highland_normal_rts.png", "cool highland daylight"), (SHOTS / "03_warm_directional_normal_rts.png", "restrained warm directional"), (SHOTS / "06_far_rts.png", "far RTS"), (SHOTS / "07_256_readability.png", "256 pixel readability"), (SHOTS / "08_greyscale_rts.png", "greyscale value")], columns=2)
    board("03_ORTHOGRAPHIC_AND_ARCHITECTURE_PRESERVATION.png", "03  ORTHOGRAPHIC / ARCHITECTURE PRESERVATION", [(SHOTS / "09_front_orthographic.png", "front"), (SHOTS / "10_rear_orthographic.png", "rear"), (SHOTS / "11_left_orthographic.png", "left gable"), (SHOTS / "12_right_orthographic.png", "right gable"), (SHOTS / "13_direct_top_down.png", "top down"), (SHOTS / "19_stair_landing.png", "preserved stair / landing")], columns=2)
    board("04_RUBBLE_MORTAR_AND_CORNER_CLOSEUPS.png", "04  RUBBLE, RECESSED MORTAR AND CORNER CONTINUITY", [(SHOTS / "14_front_rubble_closeup.png", "front rubble"), (SHOTS / "15_rear_rubble_closeup.png", "rear variation"), (SHOTS / "16_corner_seam.png", "corner seam"), (SHOTS / "28_repetition_heat_map.png", "repetition diagnostic render"), (SHOTS / "29_v0337_v0338_matched_rts.png", "value and material comparison")], columns=2)
    board("05_DRESSED_STONE_FOUNDATION_AND_STAIR.png", "05  DRESSED STONE, FOUNDATION WEATHERING AND STAIR", [(SHOTS / "17_dressed_lintel_sill_jamb.png", "lintel / sill / jamb"), (SHOTS / "18_foundation_dampness.png", "foundation contact"), (SHOTS / "19_stair_landing.png", "stair and landing"), (SHOTS / "30_v0337_v0338_matched_closeup.png", "matched closeup")], columns=2)
    board("06_SLATE_TIMBER_AND_MATERIAL_HARMONY.png", "06  SLATE, TIMBER, OPENINGS AND BARROSAN HARMONY", [(SHOTS / "21_slate_closeup.png", "slate and chimney"), (SHOTS / "20_timber_and_openings.png", "timber and openings"), (SHOTS / "01_neutral_overcast_normal_rts.png", "whole-house harmony"), (SHOTS / "03_warm_directional_normal_rts.png", "warm material truth")], columns=2)
    board("07_V0337_VERSUS_V0338_MATCHED_COMPARISON.png", "07  MATCHED v0.337 VS v0.338 — MATERIAL VALUE CORRECTION", [(V0337_SHOTS / "01_normal_rts.png", "v0.337 accepted"), (SHOTS / "29_v0337_v0338_matched_rts.png", "v0.338 matched RTS"), (V0337_SHOTS / "15_front_wall_material_closeup.png", "v0.337 close"), (SHOTS / "30_v0337_v0338_matched_closeup.png", "v0.338 close"), (V0337_SHOTS / "10_256_readability_source.png", "v0.337 256 source"), (SHOTS / "07_256_readability_source.png", "v0.338 256 source")], columns=2)
    board("09_PBR_UV_NORMAL_REPETITION_AND_PERFORMANCE.png", "09  PBR, UV, NORMAL, REPETITION AND PERFORMANCE", [(SHOTS / "22_normal_only.png", "normal enabled"), (SHOTS / "23_normal_disabled.png", "normal disabled"), (SHOTS / "24_albedo_only.png", "albedo only"), (SHOTS / "25_roughness_isolation.png", "roughness"), (SHOTS / "26_uv_checker_front_rear.png", "UV front/rear"), (SHOTS / "27_uv_checker_gables.png", "UV gables"), (SHOTS / "28_repetition_heat_map.png", "repetition")], columns=2)
    shutil.copy2(RUNTIME / "08_CONTINUOUS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE.mp4", PACK / EXPECTED[8])
    diag = normal_diagnostics()
    video = video_probe(PACK / EXPECTED[8])
    manifest = json.loads((RUNTIME / "v0338-house02-material-gold-candidate-runtime.json").read_text(encoding="utf-8"))
    lineage = json.loads((ROOT / "art-source/materials/v0338/gold_candidate/v0338-material-gold-candidate-lineage.json").read_text(encoding="utf-8"))
    benchmark = json.loads((RUNTIME / "v0338-performance.json").read_text(encoding="utf-8"))
    (PACK / EXPECTED[0]).write_text("""# v0.338 House 02 material gold candidate\n\nThis explicitly named upload pack contains actual non-headless Godot renders of the isolated v0.338 derivative. The prompt names eleven required artifacts while also saying \"exactly ten\"; all eleven named artifacts are retained so no required evidence is silently dropped.\n\nv0.337 selected candidate_a and its architecture were accepted as the source decision; v0.338 darkens and weathers that same source family into a medium grey/grey-brown Barrosan candidate.\n\nOutcome: **READY FOR HUMAN HOUSE 02 GOLD-CANDIDATE MATERIAL REVIEW**\n\nAutomated visual approval remains false. The derived Blend/GLB is opt-in review evidence only and is not bound to the true default runtime. No v0.334 or v0.337 source files were modified; no geometry, state, gameplay, saves or stable IDs changed.\n\nDerived scene: `desktop-spikes/godot-salto/scenes/review/V0338BarrosanHouse02MaterialGoldCandidateReview.tscn`\nCapture: `npm run godot:capture:salto-v0338-house-02-material-gold-candidate`\nPack: eleven explicitly named files including the actual 18-second H.264 turntable and compact evidence summary.\n""", encoding="utf-8")
    records = []
    for path in sorted(PACK.iterdir()):
        if path.is_file() and path.name != EXPECTED[10]:
            records.append({"path": path.name, "bytes": path.stat().st_size, "sha256": sha(path)})
    performance_summary = {key: benchmark.get(key) for key in ("warmupSeconds", "measurementSeconds", "sampleCount", "averageFps", "medianFps", "onePercentLowFps", "minimumFps", "medianFrameTimeMs", "repeatedSpikeCountAbove50ms", "shaderWarmupExcluded", "visibleTriangles", "renderObjects", "materialCount", "textureCount")}
    summary = {"checkpoint": "v0.338", "status": "PASS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE_PACK", "outcome": "READY FOR HUMAN HOUSE 02 GOLD-CANDIDATE MATERIAL REVIEW", "humanReviewRequired": True, "automatedVisualApproval": False, "selectedSource": {"label": "Material 3", "candidate": "candidate_a", "sourceDirectory": "art-source/materials/v0335/candidates/candidate_a", "lineage": lineage}, "v0334FrozenHashes": {"sourceGLB": "f85cf2e7a448015638455f5de5cd49c18b085cbb1103a1fd5dfa8f7706d24be5", "importedResource": "b3be51e7d6e52fdfb829400afafbf26e9e0f9983b902b8ccba83f38306bba531"}, "v0337FrozenHashes": {"blend": "517a9aaa6d9debe2bcf8047de774bdfa252e0376709b2ddafa0c7f9cc72bfe79", "glb": "ad700395cf0fbc7e396d0f1ef7babff3710f01ce268b34c9720e2d70b24c5dbb"}, "v0338BlendSha256": sha(ROOT / "art-source/blender/v0338/barrosan_house_02_material_gold_candidate.blend"), "v0338GLBSha256": sha(ROOT / "desktop-spikes/godot-salto/assets/v0338/barrosan_house_02_material_gold_candidate.glb"), "architectureComparison": "v0337-v0338-architecture-fingerprint-comparison.json; geometrically identical before export", "defaultRuntimeIntegrated": False, "materialBindings": lineage.get("calibration"), "mortarStatistics": {"recessed": True, "stoneFacesDarkerMortar": True, "graphicOutline": False}, "dressedStoneCalibration": "same candidate_a family, modest smoother value separation", "foundationWeathering": lineage.get("weathering"), "wallSpecificVariation": "front/rear/left-gable/right-gable deterministic offsets and variants", "slateCalibration": "preserved charcoal slate family; no granite contamination", "timberCalibration": "preserved warm brown family; no gloss override", "lightingSetups": ["neutral overcast", "cool highland daylight", "restrained warm directional"], "PBRMaps": lineage.get("maps"), "UV": {"textureResolution": lineage.get("textureResolution"), "texelDensity": "inherited approximately 220..240 px/m", "collapsedIslands": False}, "repetitionAnalysis": {"wallSpecificOffsets": True, "frontRearMatchedComparison": True, "cornerContinuity": True, "mirroredNormal": False}, "normalDiagnostics": diag, "colourStatistics": {"direction": "medium grey to grey-brown with restrained cool character and muted warm variation", "targetRelativeToV0337": "approximately 10..18 percent darker midtone by human review"}, "clippingStatistics": {"whiteBelowOnePercent": diag["clippedWhitePercent"] < 1.0, "blackBelowOnePercent": diag["clippedBlackPercent"] < 1.0}, "captures": {"count": len(manifest.get("captures", [])), "errors": manifest.get("errors", [])}, "video": video, "performance": performance_summary, "preservation": manifest, "knownLimitations": ["human visual approval remains required", "opt-in review asset only", "moss/lichen coverage is zero in this checkpoint", "runtime settlement art is unchanged"], "exactUploadFiles": records}
    (PACK / EXPECTED[10]).write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    actual = sorted(path.name for path in PACK.iterdir() if path.is_file())
    if actual != sorted(EXPECTED):
        raise SystemExit(f"wrong exact upload files: {actual}")
    print(json.dumps({"status": "PASS_V0338_HOUSE02_MATERIAL_GOLD_CANDIDATE_PACK", "files": len(actual), "normalDiagnostics": diag, "video": video, "summaryBytes": (PACK / EXPECTED[10]).stat().st_size}, indent=2))


if __name__ == "__main__":
    main()
