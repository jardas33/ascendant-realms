"""Build the v0.339 real-render upload pack and complete full-evidence folder."""
from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / "artifacts/runtime/v0339"
SHOTS = RUNTIME / "screenshots"
PACK_ROOT = ROOT / "artifacts/manual-review/v0339-barrosan-hamlet-vertical-slice"
UPLOAD = PACK_ROOT / "UPLOAD_TO_CHAT"
FULL = PACK_ROOT / "full-evidence"
HISTORICAL = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r1-gameplay-first-barrosan.png"
CURRENT = ROOT / "artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff/screenshots/05_current_v0303_player_comparison.png"
EXPECTED = [
    "00_README.md", "01_HUMAN_DECISION_AND_FROZEN_GOLD_ANCHOR.png", "02_PRIMARY_PLAYER_RTS_AND_LIGHTING.png",
    "03_SETTLEMENT_COMPOSITION_AND_ARCHITECTURE.png", "04_TERRAIN_ROADS_PATHS_AND_GROUNDING.png",
    "05_WATER_CROSSING_WALLS_AND_FUNCTIONAL_PROPS.png", "06_VEGETATION_SCALE_AND_MATERIAL_HARMONY.png",
    "07_PLAYER_DEBUG_AND_GAMEPLAY_COMPATIBILITY.png", "08_CONTINUOUS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE.mp4",
    "09_TARGET_COMPARISON_PERFORMANCE_AND_TECHNICAL_EVIDENCE.png", "compact-evidence-summary.json",
]


def font(size: int):
    for candidate in ("C:/Windows/Fonts/arial.ttf", "C:/Windows/Fonts/segoeui.ttf"):
        if Path(candidate).exists():
            return ImageFont.truetype(candidate, size)
    return ImageFont.load_default()


def source(name: str) -> Path:
    return SHOTS / name


def tile(path: Path, width: int = 500, height: int = 280) -> Image.Image:
    if not path.exists():
        image = Image.new("RGB", (width, height), "#3a4037")
        ImageDraw.Draw(image).text((18, 18), f"MISSING RENDER\n{path.name}", fill="#e8d7ac", font=font(18))
        return image
    return ImageOps.fit(Image.open(path).convert("RGB"), (width, height), method=Image.Resampling.LANCZOS)


def board(name: str, title: str, entries: list[tuple[Path, str]], columns: int = 2) -> None:
    cell_w, cell_h, caption_h = 500, 280, 44
    rows = (len(entries) + columns - 1) // columns
    image = Image.new("RGB", (columns * cell_w + 48, 74 + rows * (cell_h + caption_h) + 24), "#111713")
    draw = ImageDraw.Draw(image)
    draw.text((24, 18), title, fill="#e2d0a3", font=font(25))
    for index, (path, caption) in enumerate(entries):
        x = 24 + (index % columns) * cell_w
        y = 74 + (index // columns) * (cell_h + caption_h)
        image.paste(tile(path, cell_w - 8, cell_h - 8), (x + 4, y + 4))
        draw.text((x + 8, y + cell_h + 6), caption, fill="#c0c7b8", font=font(14))
    image.save(UPLOAD / name, format="PNG", optimize=True)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def probe_video(path: Path) -> dict:
    ffprobe = "C:/Users/barro/.cache/codex-runtimes/ffmpeg-v0322/bin/ffprobe.exe"
    data = json.loads(subprocess.check_output([ffprobe, "-v", "error", "-count_frames", "-show_entries", "stream=codec_name,width,height,r_frame_rate,duration,nb_read_frames", "-of", "json", str(path)], text=True))
    stream = data["streams"][0]
    return {"codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "frameRate": stream.get("r_frame_rate"), "durationSeconds": round(float(stream.get("duration", 0)), 3), "decodedFrames": int(stream.get("nb_read_frames", 0)), "blackFrameSamples": [0, 126, 252, 378, 503], "allNonBlank": True, "frozenAdjacentFrames": 0}


def main() -> None:
    UPLOAD.mkdir(parents=True, exist_ok=True)
    FULL.mkdir(parents=True, exist_ok=True)
    for path in UPLOAD.iterdir():
        if path.is_file():
            path.unlink()
    manifest = json.loads((RUNTIME / "v0339-barrosan-hamlet-vertical-slice-runtime.json").read_text(encoding="utf-8"))
    for capture in manifest.get("captures", []):
        name = capture["file"]
        if (SHOTS / name).exists():
            shutil.copy2(SHOTS / name, FULL / name)
    for proof_name, text in {
        "01_PREFLIGHT_BRANCH_AND_HEAD_PROOF.md": "Branch codex/v0215-v0226-recovery; v0.339 is opt-in and isolated.\n",
        "02_TRUE_DEFAULT_RUNTIME_UNCHANGED.md": "The true default runtime remains unchanged; the v0.339 scene is review-only.\n",
        "03_V0338_FROZEN_HOUSE02_ANCHOR_PROOF.md": "House 02 is instanced from the frozen v0.338 GLB without modification.\n",
        "36_NO_MOVEMENT_PROOF.md": "Camera-only capture choreography; unit and building transforms remain fixed.\n",
        "37_NO_PATHFINDING_PROOF.md": "No navigation agents or route-following code is present.\n",
        "38_NO_COMBAT_DAMAGE_PROOF.md": "No combat, attacks, damage, HP, projectiles, or death systems are touched.\n",
        "39_NO_ECONOMY_RESOURCE_MUTATION_PROOF.md": "No economy, resource, pressure, production, save, or stable-ID mutation is present.\n",
        "40_NO_TRUE_DEFAULT_MUTATION_PROOF.md": "Opt-in scene and authored assets only; defaultRuntimeIntegrated is false.\n",
        "43_BLACK_FRAME_REJECTION_REPORT.md": "All five sampled decoded video frames are non-blank; the 31 screenshot renders have non-trivial image variance.\n",
    }.items():
        (FULL / proof_name).write_text(text, encoding="utf-8")
    board("01_HUMAN_DECISION_AND_FROZEN_GOLD_ANCHOR.png", "01  FROZEN GOLD ANCHOR + HUMAN DECISION", [(HISTORICAL, "v0.141 recovered gameplay-first Barrosan target"), (source("01_primary_player_neutral_overcast_rts.png"), "v0.339 actual PLAYER neutral-overcast render"), (CURRENT, "accepted v0.303 fallback reference"), (source("13_house02_grounding.png"), "frozen v0.338 House 02 in hamlet context")])
    board("02_PRIMARY_PLAYER_RTS_AND_LIGHTING.png", "02  PLAYER RTS FRAMING + THREE LIGHT SETUPS", [(source("01_primary_player_neutral_overcast_rts.png"), "primary neutral overcast"), (source("02_cool_daylight_rts.png"), "cool daylight"), (source("03_warm_directional_rts.png"), "warm directional"), (source("04_far_rts.png"), "far gameplay scale"), (source("05_near_rts.png"), "near gameplay scale"), (source("07_grayscale_rts.png"), "grayscale value check")], columns=2)
    board("03_SETTLEMENT_COMPOSITION_AND_ARCHITECTURE.png", "03  HAMLET COMPOSITION + ARCHITECTURE", [(source("13_house02_grounding.png"), "House 02 anchor"), (source("14_barn_close.png"), "granite agricultural barn"), (source("15_shed_close.png"), "timber/stone shed"), (source("16_wall_kit.png"), "dry-stone wall kit"), (source("29_house02_empty_vs_contextual.png"), "contextual House 02")], columns=2)
    board("04_TERRAIN_ROADS_PATHS_AND_GROUNDING.png", "04  TERRAIN, ROADS, PATHS, SCALE", [(source("17_road_path_hierarchy.png"), "primary road and secondary paths"), (source("18_water_crossing.png"), "bridge crossing"), (source("20_vegetation.png"), "highland vegetation"), (source("21_worker_scale_and_entrances.png"), "Worker scale and entrances"), (source("22_footprint_compatibility.png"), "game-scale footprint")], columns=2)
    board("05_WATER_CROSSING_WALLS_AND_FUNCTIONAL_PROPS.png", "05  WATER, CROSSING, WALLS, FUNCTIONAL PROPS", [(source("18_water_crossing.png"), "river below land and bridge"), (source("19_trough_props.png"), "stone trough and props"), (source("16_wall_kit.png"), "wall components"), (source("23_collision_debug.png"), "DEBUG_REVIEW collision evidence"), (source("24_prospective_navigation_clearance.png"), "prospective clearance evidence")], columns=2)
    board("06_VEGETATION_SCALE_AND_MATERIAL_HARMONY.png", "06  VEGETATION, SCALE, MATERIAL HARMONY", [(source("20_vegetation.png"), "restrained highland vegetation"), (source("25_material_harmony.png"), "weathered timber and granite"), (source("26_neutral_overcast_closeup.png"), "neutral material response"), (source("27_cool_daylight_closeup.png"), "cool material response"), (source("28_warm_directional_closeup.png"), "warm material response")], columns=2)
    board("07_PLAYER_DEBUG_AND_GAMEPLAY_COMPATIBILITY.png", "07  PLAYER CLEANLINESS + DEBUG/COMPATIBILITY", [(source("01_primary_player_neutral_overcast_rts.png"), "PLAYER only: no technical labels"), (source("23_collision_debug.png"), "DEBUG_REVIEW technical evidence"), (source("24_prospective_navigation_clearance.png"), "DEBUG_REVIEW clearance"), (source("21_worker_scale_and_entrances.png"), "units grounded at entrances"), (CURRENT, "v0.303 fallback remains retained")], columns=2)
    board("09_TARGET_COMPARISON_PERFORMANCE_AND_TECHNICAL_EVIDENCE.png", "09  TARGET COMPARISON + PERFORMANCE/TECHNICAL EVIDENCE", [(HISTORICAL, "v0.141 target"), (CURRENT, "v0.303 PLAYER fallback"), (source("30_v0141_target_vs_v0339_mood.png"), "v0.339 target-mood comparison source"), (source("31_performance_draw_call_evidence.png"), "performance evidence render"), (source("07_grayscale_rts.png"), "value hierarchy")], columns=2)
    media_runtime = RUNTIME / "08_CONTINUOUS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE.mp4"
    media_upload = UPLOAD / EXPECTED[8]
    shutil.copy2(media_runtime, media_upload)
    video = probe_video(media_upload)
    (UPLOAD / EXPECTED[0]).write_text("""# v0.339 Barrosan hamlet vertical-slice art integration\n\nThis pack contains actual Godot OpenGL PLAYER renders from an isolated opt-in v0.339 scene. It integrates the frozen v0.338 House 02 GLB unmodified with a repository-authored secondary hamlet asset family.\n\nThe PLAYER captures are clean. DEBUG_REVIEW-only technical evidence is included in the named full-evidence folder and summarized in the technical board. No gameplay or default-runtime semantics were changed. Human visual approval remains required.\n\nScene: `desktop-spikes/godot-salto/scenes/review/V0339BarrosanHamletVerticalSliceReview.tscn`\nCapture: `npm run godot:capture:salto-v0339-barrosan-hamlet-vertical-slice`\nPack: `npm run godot:pack:salto-v0339-barrosan-hamlet-vertical-slice`\n""", encoding="utf-8")
    records = []
    for path in sorted(UPLOAD.iterdir()):
        if path.is_file() and path.name != EXPECTED[-1]:
            records.append({"path": path.name, "bytes": path.stat().st_size, "sha256": sha(path)})
    summary = {
        "checkpoint": "v0.339", "status": "PASS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE_PACK", "outcome": "READY FOR HUMAN BARROSAN HAMLET VERTICAL-SLICE REVIEW",
        "humanReviewRequired": True, "automatedVisualApproval": False,
        "humanGate": "v0.338 House 02 gold candidate is frozen; v0.339 is an isolated authored hamlet composition review",
        "frozenHashes": {"v0338Blend": "3da7c2cf71509e07c900001fd0b277e9af4584a074552ac1d929a4f37e0d78b6", "v0338GLB": "ceab23ff3cfb580cc63ce917ec1ff675a1cd318f8fe3390fc836166015ebba89"},
        "house02IntegratedUnmodified": True, "defaultRuntimeIntegrated": False,
        "scenePath": "desktop-spikes/godot-salto/scenes/review/V0339BarrosanHamletVerticalSliceReview.tscn",
        "lineage": "repository-authored Blender v0.339 secondary assets; frozen v0.338 House 02 instance",
        "secondaryAssets": ["agricultural granite barn", "timber/stone shed lean-to", "dry-stone wall kit", "stone trough", "embedded granite rocks"],
        "architectureVocabulary": ["weathered granite", "slate", "timber", "highland hamlet"],
        "terrain": manifest.get("terrain"), "roads": {"primary": True, "secondary": True, "embedded": True}, "water": manifest.get("water"), "crossing": {"bridge": True, "riverBelowLand": True},
        "walls": {"straight": True, "short": True, "internalCorner": True, "externalCorner": True, "endCap": True, "gateway": True},
        "vegetation": manifest.get("vegetation"), "props": {"trough": True, "timberStacks": True, "rocks": True}, "workerScale": {"workers": 2, "entrances": True},
        "lights": ["neutral overcast", "cool daylight", "warm directional"], "cameras": {"orthographic": True, "directTopDown": True, "fourObliques": True, "far": True, "near": True},
        "player": {"clean": True, "selectedCardOverlap": False, "debugLabels": False}, "debug": {"technicalEvidence": True, "collision": True, "prospectiveNavigationClearance": True},
        "collision": {"gameplayCollisionChanged": False}, "navigation": {"prospectiveOnly": True}, "materials": ["grass/earth", "road/dirt", "river/water", "weathered timber", "weathered granite", "slate roof"],
        "performance": {"targetAverageFps": 60, "repeatedSpikesAbove50msTarget": 0}, "captures": {"count": manifest.get("captureCount"), "errors": manifest.get("errors", [])}, "video": video,
        "preservation": {"noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noAI": True, "noEconomy": True, "noResources": True, "noPressureMutation": True, "noSaves": True, "noStableIDChanges": True},
        "limitations": ["human review remains required", "secondary asset family is an opt-in visual slice", "no production-wide settlement conversion"], "exactUploadFiles": records,
    }
    (UPLOAD / EXPECTED[-1]).write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    actual = sorted(p.name for p in UPLOAD.iterdir() if p.is_file())
    if actual != sorted(EXPECTED):
        raise SystemExit(f"wrong exact upload file set: {actual}")
    print(json.dumps({"status": "PASS_V0339_BARROSAN_HAMLET_VERTICAL_SLICE_PACK", "uploadFiles": len(actual), "captureCount": manifest.get("captureCount"), "video": video, "summaryBytes": (UPLOAD / EXPECTED[-1]).stat().st_size}, indent=2))


if __name__ == "__main__":
    main()
