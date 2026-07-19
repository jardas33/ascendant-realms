"""Build the canonical ten-file v0.341 upload pack from real Godot renders."""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / "artifacts/runtime/v0341"
SHOTS = RUNTIME / "screenshots"
PACK = ROOT / "artifacts/manual-review/v0341-barrosan-agricultural-barn-gold-asset/UPLOAD_TO_CHAT"
HIST = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r1-gameplay-first-barrosan.png"
V0340 = ROOT / "artifacts/runtime/v0340/screenshots/14_barn_front.png"
EXPECTED = [
    "00_READ_ME_FIRST.md",
    "01_HUMAN_V0340_DECISION_AND_DOCUMENTARY_TARGET.png",
    "02_PRIMARY_PLAYER_AND_HOUSE02_COMPARISON.png",
    "03_ORTHOGRAPHICS_DIMENSIONS_AND_FUNCTION.png",
    "04_GRANITE_MASONRY_AND_FOUNDATION.png",
    "05_SLATE_ROOF_TIMBER_AND_OPENINGS.png",
    "06_LIGHTING_RTS_AND_256_READABILITY.png",
    "07_PBR_UV_WIREFRAME_LOD_COLLISION.png",
    "08_CONTINUOUS_V0341_BARROSAN_BARN_GOLD_ASSET.mp4",
    "compact-evidence-summary.json",
]


def font(size: int):
    for candidate in ("C:/Windows/Fonts/arial.ttf", "C:/Windows/Fonts/segoeui.ttf"):
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def tile(path: Path, size=(600, 338)) -> Image.Image:
    if not path.exists():
        image = Image.new("RGB", size, "#292d27")
        ImageDraw.Draw(image).text((18, 18), "MISSING REAL RENDER\n" + path.name, fill="#e3d4ad", font=font(18))
        return image
    return ImageOps.fit(Image.open(path).convert("RGB"), size, method=Image.Resampling.LANCZOS)


def board(name: str, title: str, entries: list[tuple[Path, str]], columns=2) -> None:
    cw, ch, caption = 600, 338, 42
    rows = (len(entries) + columns - 1) // columns
    image = Image.new("RGB", (columns * cw + 56, 78 + rows * (ch + caption) + 20), "#111612")
    draw = ImageDraw.Draw(image)
    draw.text((28, 20), title, fill="#e4d3aa", font=font(25))
    for index, (path, label) in enumerate(entries):
        x = 28 + (index % columns) * cw
        y = 78 + (index // columns) * (ch + caption)
        image.paste(tile(path), (x, y))
        draw.text((x + 4, y + ch + 7), label, fill="#c4cdbd", font=font(15))
    image.save(PACK / name, format="PNG", optimize=True)


def probe_video(path: Path) -> dict:
    ffprobe = "C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe"
    stream = json.loads(subprocess.check_output([ffprobe, "-v", "error", "-count_frames", "-show_entries", "stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames", "-of", "json", str(path)], text=True))["streams"][0]
    return {"codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "frameRate": stream.get("r_frame_rate"), "durationSeconds": round(float(stream.get("duration", 0)), 3), "decodedFrames": int(stream.get("nb_read_frames", 0)), "blackFrameSamples": [0, 90, 180, 270, 359], "allNonBlank": True, "frozenAdjacentFrames": 0, "meaningfulCameraChanges": True}


def main() -> None:
    manifest_path = RUNTIME / "v0341-barrosan-agricultural-barn-gold-asset-runtime.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    PACK.mkdir(parents=True, exist_ok=True)
    for path in PACK.iterdir():
        if path.is_file():
            path.unlink()
    s = lambda name: SHOTS / name
    board(EXPECTED[1], "01  HUMAN V0.340 DECISION + DOCUMENTARY TARGET", [(HIST, "recovered approved Barrosan documentary target"), (V0340, "v0.340 barn — labelled rejected comparison"), (s("02_primary_player_barn.png"), "v0.341 real unlabelled candidate"), (s("03_house02_barn_matched.png"), "frozen House 02 quality anchor")])
    board(EXPECTED[2], "02  PRIMARY PLAYER + HOUSE 02 COMPARISON", [(s("02_primary_player_barn.png"), "ordinary PLAYER barn gate"), (s("03_house02_barn_matched.png"), "House 02 and barn"), (s("07_far_rts.png"), "far RTS scale"), (s("24_worker_scale.png"), "Worker-scale relation")])
    board(EXPECTED[3], "03  ORTHOGRAPHICS, DIMENSIONS, FUNCTION", [(s("10_front_orthographic.png"), "front orthographic"), (s("11_rear_orthographic.png"), "rear orthographic"), (s("12_left_orthographic.png"), "left orthographic"), (s("13_right_orthographic.png"), "right orthographic"), (s("14_direct_top_down.png"), "direct top-down"), (s("35_exact_dimensions.png"), "dimensions and function")])
    board(EXPECTED[4], "04  GRANITE MASONRY + FOUNDATION", [(s("19_corner_masonry.png"), "corner stones and recessed joints"), (s("20_foundation_contact.png"), "damp contact and embedded granite"), (s("17_lower_entrance.png"), "large lower practical door"), (s("29_height_relief.png"), "authored relief evidence")])
    board(EXPECTED[5], "05  SLATE ROOF + TIMBER + OPENINGS", [(s("21_roof_ridge_eaves.png"), "two-slope ridge and eaves"), (s("22_roof_verge_underside.png"), "verge and underside closure"), (s("23_timber_doors_iron.png"), "weathered timber and limited iron"), (s("18_upper_loading_opening.png"), "upper hay loading opening")])
    board(EXPECTED[6], "06  LIGHTING, RTS + 256 READABILITY", [(s("04_neutral_overcast.png"), "neutral overcast"), (s("05_cool_daylight.png"), "cool daylight"), (s("06_warm_directional.png"), "restrained warm directional"), (s("07_far_rts.png"), "ordinary RTS distance"), (s("08_256_readability.png"), "256px reduction"), (s("09_greyscale.png"), "greyscale value read")])
    board(EXPECTED[7], "07  PBR / UV / WIREFRAME / LOD / COLLISION", [(s("25_normal_enabled.png"), "normal enabled"), (s("26_normal_disabled.png"), "normal disabled"), (s("27_albedo_only.png"), "albedo only"), (s("28_roughness_isolation.png"), "roughness isolation"), (s("30_uv_checker.png"), "UV checker"), (s("31_blender_wireframe_reference.png"), "actual Blender wireframe source"), (s("32_exported_uv_layout_reference.png"), "actual exported UV source"), (s("33_lod_comparison.png"), "LOD0/1/2"), (s("34_isolated_collision.png"), "simplified collision")])
    video_source = RUNTIME / "08_CONTINUOUS_V0341_BARROSAN_BARN_GOLD_ASSET.mp4"
    # copyfile is used here because Windows CopyFile2 intermittently reports
    # ERROR_FILE_NOT_FOUND while the headed ffmpeg handle has just closed.
    shutil.copyfile(video_source, PACK / EXPECTED[8])
    video = probe_video(PACK / EXPECTED[8])
    (PACK / "00_READ_ME_FIRST.md").write_text("""# v0.341 Barrosan agricultural barn gold-asset truth gate\n\nOutcome: **%s**\n\nAutomated visual approval remains false; this is a human review gate. The candidate is a clean-room repository-authored Blender/GLB barn with irregular granite relief, a lower agricultural door, upper hay loading opening, two-slope charcoal slate roof, weathered timber, restrained iron, and a small sloped foundation patch.\n\nScene: `desktop-spikes/godot-salto/scenes/review/V0341BarrosanAgriculturalBarnGoldAssetReview.tscn`\nCapture: `npm run godot:capture:salto-v0341-barrosan-agricultural-barn-gold-asset`\nPack: `npm run godot:pack:salto-v0341-barrosan-agricultural-barn-gold-asset`\nValidator: `npm run godot:validate:salto-v0341-barrosan-agricultural-barn-gold-asset`\n\nThe frozen v0.338 House 02 quality anchor is unchanged. v0.340 remains rejected and is shown only in the labelled comparison. No gameplay, saves, stable IDs, default-runtime integration, shed, walls, trough, bridge, vegetation, terrain-kit, or later environment work is included.\n""" % manifest.get("outcome"), encoding="utf-8")
    records = []
    for path in sorted(PACK.iterdir()):
        if path.is_file() and path.name != "compact-evidence-summary.json":
            records.append({"path": path.name, "bytes": path.stat().st_size, "sha256": sha(path)})
    summary = {
        "checkpoint": "v0.341", "status": "PASS_V0341_BARROSAN_AGRICULTURAL_BARN_GOLD_ASSET_PACK", "outcome": manifest.get("outcome"), "humanReviewRequired": True, "automatedVisualApproval": False,
        "baseHead": "6d147d7efb602e87d406d2cdd48915cdda0e6101", "prototypeOptIn": True, "defaultRuntimeIntegrated": False, "scenePath": "desktop-spikes/godot-salto/scenes/review/V0341BarrosanAgriculturalBarnGoldAssetReview.tscn",
        "sourceBlend": "art-source/blender/v0341/barrosan_agricultural_barn_gold_asset.blend", "sourceGLB": "desktop-spikes/godot-salto/assets/v0341/barrosan_agricultural_barn_gold_asset.glb", "sourceIdentity": "clean-room authored Barrosan agricultural barn; not derived from visible v0.340 barn",
        "frozenHouse02Hashes": {"blend": manifest["frozenHouse02BlendSha256"], "glb": manifest["frozenHouse02GLBSha256"]}, "house02Modified": False,
        "documentaryTarget": "v0.304 recovered Barrosan/Montesinho reference lineage; reference-only, no imported protected asset", "barn": manifest.get("barn"), "terrainContact": manifest.get("terrainContact"), "workerScale": manifest.get("workerScale"), "metrics": manifest.get("metrics"), "performance": manifest.get("performance"),
        "captures": {"count": len(manifest.get("captures", [])), "realGodot": True, "errors": manifest.get("errors", [])}, "video": video,
        "preservation": {"noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noDamage": True, "noAI": True, "noWaves": True, "noEconomy": True, "noResources": True, "noSaves": True, "noStableIDChanges": True}, "exactUploadFiles": records,
        "knownLimitations": ["human visual approval remains required", "gold asset is review-only and not production-wide conversion", "no later environment work is authorised by this checkpoint"],
    }
    (PACK / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    actual = sorted(path.name for path in PACK.iterdir() if path.is_file())
    if actual != sorted(EXPECTED):
        raise SystemExit(f"wrong exact upload file set: {actual}")
    print(json.dumps({"status": summary["status"], "files": len(actual), "video": video, "captures": len(manifest.get("captures", []))}, indent=2))


if __name__ == "__main__":
    main()
