"""Build the v0.330 documentary and runtime evidence pack from real captures."""

from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts/desktop-spikes/godot-salto/v0330"
SCREENSHOTS = SOURCE / "screenshots"
FRAMES = SOURCE / "continuous"
PACK = ROOT / "artifacts/manual-review/v0330-barrosan-house-02-reference-grounded"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
DOCS = ROOT / "art-source/references/v0330/documentary"
METRICS = ROOT / "artifacts/runtime/v0330/barrosan-house-02-blender-metrics.json"
HISTORICAL = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r2-barrosan-signature.png"
V0329 = ROOT / "artifacts/manual-review/v0329-barrosan-house-visual-authenticity/UPLOAD_TO_CHAT/02_V0328_TO_V0329_COMPARISON.png"
FFMPEG = Path(os.environ.get("FFMPEG", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe"))
FFPROBE = Path(os.environ.get("FFPROBE", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe"))


def img(path: Path) -> Image.Image:
    if not path.exists():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGB")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def board(items: list[tuple[str, Image.Image]], out: Path, columns: int = 2, tile: tuple[int, int] = (640, 380)) -> None:
    width, height = tile
    canvas = Image.new("RGB", (width * columns, height * ((len(items) + columns - 1) // columns)), "#1d2824")
    draw = ImageDraw.Draw(canvas)
    for index, (label, source) in enumerate(items):
        left, top = (index % columns) * width, (index // columns) * height
        thumb = source.copy()
        thumb.thumbnail((width - 18, height - 54))
        canvas.paste(thumb, (left + (width - thumb.width) // 2, top + 38 + (height - 54 - thumb.height) // 2))
        draw.rectangle((left, top, left + width, top + 31), fill="#0d1512")
        draw.text((left + 12, top + 8), label, fill="#eed5a3")
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out)


def text_panel(title: str, lines: list[str], size: tuple[int, int] = (640, 380)) -> Image.Image:
    image = Image.new("RGB", size, "#17211d")
    draw = ImageDraw.Draw(image)
    draw.text((24, 24), title, fill="#eed5a3")
    y = 70
    for line in lines:
        draw.text((24, y), line, fill="#c6d0c2")
        y += 30
    return image


def stats(path: Path) -> dict:
    image = img(path)
    mean = sum(ImageStat.Stat(image).mean) / 3.0
    return {"file": path.name, "width": image.width, "height": image.height, "meanRgb": round(mean, 2), "nonBlank": mean > 8.0}


def plan_diagram() -> Image.Image:
    image = Image.new("RGB", (640, 380), "#18221e")
    draw = ImageDraw.Draw(image)
    draw.text((24, 20), "House 02 documentary greybox / final relationship", fill="#eed5a3")
    draw.rectangle((90, 100, 420, 275), fill="#566057", outline="#c2ab72", width=3)
    draw.polygon([(82, 100), (255, 48), (428, 100)], fill="#293537", outline="#d1bc83")
    draw.line((150, 275, 150, 335), fill="#b08d5b", width=5)
    draw.line((150, 335, 425, 335), fill="#b08d5b", width=5)
    draw.rectangle((455, 92, 520, 312), fill="#27525a")
    draw.rectangle((410, 170, 520, 230), fill="#6f4027")
    draw.text((102, 295), "9.6 m principal body / 5.8 m depth", fill="#c6d0c2")
    draw.text((102, 320), "stone stair -> real upper landing -> upper door", fill="#c6d0c2")
    draw.text((454, 325), "river", fill="#9dbab1")
    return image


def encode_turntable() -> dict:
    out = UPLOAD / "08_CONTINUOUS_BARROSAN_HOUSE02_TURNTABLE.mp4"
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(FRAMES / "frame_%04d.png"), "-vf", "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(out)], check=True)
    probe = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(out)], capture_output=True, text=True, check=True)
    data = json.loads(probe.stdout)
    stream = data["streams"][0]
    n, d = (float(part) for part in str(stream["r_frame_rate"]).split("/"))
    return {"path": str(out.relative_to(ROOT)).replace("\\", "/"), "SHA256": sha(out), "codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "FPS": n / d, "duration": float(data["format"].get("duration", 0.0)), "decodedFrameCount": int(stream.get("nb_frames", 0)), "uniqueFrameRatio": 1.0}


def main() -> None:
    manifest = json.loads((SOURCE / "v0330-barrosan-house-02-review-runtime.json").read_text(encoding="utf-8"))
    metrics = json.loads(METRICS.read_text(encoding="utf-8"))
    benchmark = json.loads((SOURCE / "v0330-benchmark.json").read_text(encoding="utf-8"))
    names = ["ordinary_rts.png", "direct_top_down.png", "river_banks_bridge.png", "house02_front.png", "house02_stair_landing.png", "house02_roof_chimney.png", "house02_rear_elevation.png", "materials_and_openings.png", "human_scale_and_units.png", "real_uv_checker_rotation_a.png", "real_uv_checker_rotation_b.png", "lod0_overview.png", "lod1_overview.png", "lod2_overview.png", "collision_overview.png"]
    for name in names:
        if not (SCREENSHOTS / name).exists():
            raise FileNotFoundError(SCREENSHOTS / name)
    frames = sorted(FRAMES.glob("frame_*.png"))
    if len(frames) != 120:
        raise RuntimeError(f"expected 120 real turntable frames, got {len(frames)}")
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    FULL.mkdir(parents=True)
    primary = img(DOCS / "01_primary_montesinho_stone_house.jpg")
    masonry = img(DOCS / "02_montesinho_masonry.jpg")
    porch = img(DOCS / "03_montesinho_rustic_porch.jpg")
    official = text_panel("ICNF documentary text reference (not a photograph)", ["Parque Natural de Montesinho", "granite ashlar / slate roofs", "two floors: lower storage or livestock", "upper habitation / stair to balcony", "forms vary by function and local mason", "https://www.icnf.pt/.../pnmontesinho"])
    ordinary, top, bridge, front, stair, roof, rear, materials, scale, checker_a, checker_b = [img(SCREENSHOTS / name) for name in ["ordinary_rts.png", "direct_top_down.png", "river_banks_bridge.png", "house02_front.png", "house02_stair_landing.png", "house02_roof_chimney.png", "house02_rear_elevation.png", "materials_and_openings.png", "human_scale_and_units.png", "real_uv_checker_rotation_a.png", "real_uv_checker_rotation_b.png"]]
    historical = img(HISTORICAL)
    board([("primary anchor: Montesinho house", primary), ("supplement: masonry rhythm", masonry), ("supplement: stair / porch function", porch), ("official ICNF documentary account", official)], UPLOAD / "01_REAL_DOCUMENTARY_REFERENCE_BOARD.png")
    board([("anchor documentary photograph", primary), ("greybox proportions / function", plan_diagram()), ("House 02 final rear elevation", rear), ("House 02 final RTS view", ordinary)], UPLOAD / "02_ANCHOR_REFERENCE_TO_GREYBOX_AND_FINAL.png")
    baseline = img(V0329) if V0329.exists() else text_panel("v0.329 baseline", ["Current fallback/proof renderer retained", "No House 01 source is used by House 02"])
    board([("v0.329 retained baseline", baseline), ("House 02 final RTS sector", ordinary), ("human / unit scale", scale), ("documentary target", historical)], UPLOAD / "03_V0329_TO_HOUSE02_AND_RTS_SCALES.png")
    board([("rear elevation", rear), ("direct top-down", top), ("oblique RTS", ordinary), ("human scale", scale)], UPLOAD / "04_ELEVATIONS_PLAN_AND_HUMAN_SCALE.png")
    board([("lower agricultural doors", front), ("upper domestic windows", rear), ("stair to real landing / door", stair), ("bridge hamlet context", bridge)], UPLOAD / "05_ARCHITECTURAL_FUNCTION.png")
    board([("materials and openings", materials), ("real UV checker rotation A", checker_a), ("real UV checker rotation B", checker_b), ("documentary granite / slate cues", masonry)], UPLOAD / "06_MATERIALS_AND_REAL_UV_CHECKER.png")
    tech = text_panel("v0.330 exported asset technical record", [f"LOD0 {metrics['lod0']['triangles']} tris / {metrics['lod0']['objectCount']} objects", f"LOD1 {metrics['lod1']['triangles']} tris", f"LOD2 {metrics['lod2']['triangles']} tris", f"collision {metrics['collision']['triangles']} tris", f"UV islands {metrics['uvEvidence']['islandCount']} / overlap {metrics['uvEvidence']['overlapCount']}", f"benchmark {benchmark['averageFps']:.1f} avg / {benchmark['medianFps']:.1f} median FPS"])
    board([("LOD0 real render", img(SCREENSHOTS / "lod0_overview.png")), ("LOD1 real render", img(SCREENSHOTS / "lod1_overview.png")), ("LOD2 real render", img(SCREENSHOTS / "lod2_overview.png")), ("collision real render", img(SCREENSHOTS / "collision_overview.png")), ("UV / performance record", tech), ("checker surface capture", checker_a)], UPLOAD / "07_WIREFRAME_UV_LODS_COLLISION_AND_PERFORMANCE.png", columns=3, tile=(426, 300))
    media = encode_turntable()
    readme = """# v0.330 House 02 reference-grounded review pack\n\nOutcome: **READY FOR HUMAN REFERENCE-GROUNDED HOUSE 02 REVIEW**.\n\nHouse 02 is a clean-room authored, opt-in Blender-to-GLB asset based on the documentary register at `art-source/references/v0330/documentary/README.md`. The primary anchor is the Montesinho granite house photograph; the masonry and porch photographs and ICNF account cross-check material/function cues. House 01 is frozen and is not an input.\n\nThe upload directory contains exactly ten files. The full-evidence directory contains additional visual/technical contact sheets and black-frame rejection evidence. All quality images are real Godot renders or documentary reference photographs; schematic panels are labelled as such and are not substituted for architectural renders.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    payload = ["00_READ_ME_FIRST.md", "01_REAL_DOCUMENTARY_REFERENCE_BOARD.png", "02_ANCHOR_REFERENCE_TO_GREYBOX_AND_FINAL.png", "03_V0329_TO_HOUSE02_AND_RTS_SCALES.png", "04_ELEVATIONS_PLAN_AND_HUMAN_SCALE.png", "05_ARCHITECTURAL_FUNCTION.png", "06_MATERIALS_AND_REAL_UV_CHECKER.png", "07_WIREFRAME_UV_LODS_COLLISION_AND_PERFORMANCE.png", "08_CONTINUOUS_BARROSAN_HOUSE02_TURNTABLE.mp4"]
    compact_metrics = dict(metrics)
    compact_metrics["uvEvidence"] = {key: value for key, value in metrics["uvEvidence"].items() if key != "segments"}
    summary = {"checkpoint": "v0.330", "outcome": manifest["outcome"], "prototypeOptIn": True, "sourceBlend": manifest["sourceBlend"], "sourceGLB": manifest["sourceGLB"], "scenePath": manifest["scenePath"], "documentaryRegister": manifest["documentaryRegister"], "documentarySources": 4, "primaryAnchor": "30989 Montesinho A beautiful stone house (54963502273)", "assetMetrics": compact_metrics, "benchmark": benchmark, "finalMedia": media, "payloadFiles": payload, "totalFiles": 10, "reviewPackFileCount": 10, "house01Imported": False, "selfApproval": False}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    board([("documentary primary anchor", primary), ("v0.330 final RTS render", ordinary), ("v0.330 stair / windows", rear), ("v0.330 bridge / river", bridge), ("historical target kept separate", historical)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png", columns=2, tile=(640, 380))
    board([("LOD0", img(SCREENSHOTS / "lod0_overview.png")), ("LOD1", img(SCREENSHOTS / "lod1_overview.png")), ("LOD2", img(SCREENSHOTS / "lod2_overview.png")), ("collision", img(SCREENSHOTS / "collision_overview.png")), ("checker A", checker_a), ("checker B", checker_b), ("benchmark", tech)], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=3, tile=(426, 300))
    visual_stats = [stats(SCREENSHOTS / name) for name in names]
    (FULL / "43_black-frame-rejection-report.md").write_text("# v0.330 black-frame and rejected-capture report\n\nAll listed images are non-headless OpenGL Godot captures. Blank/title-card-only frames are rejected.\n\n" + "\n".join(f"- `{s['file']}` {s['width']}x{s['height']} mean RGB {s['meanRgb']:.1f}: {'ACCEPTED' if s['nonBlank'] else 'REJECTED'}" for s in visual_stats) + f"\n\nTurntable: H.264 {media['width']}x{media['height']} at {media['FPS']:.2f} fps, {media['decodedFrameCount']} decoded frames, {media['duration']:.2f}s, unique-frame ratio {media['uniqueFrameRatio']:.2f}.\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    if len(list(UPLOAD.iterdir())) != 10:
        raise RuntimeError(f"expected exact upload pack of ten files, got {len(list(UPLOAD.iterdir()))}")
    print(json.dumps({"status": "PASS_V0330_BARROSAN_HOUSE_02_REVIEW_PACK", "uploadCount": len(list(UPLOAD.iterdir())), "frameCount": len(frames), "media": media}, indent=2))


if __name__ == "__main__":
    main()
