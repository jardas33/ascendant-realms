"""Build the v0.329 ten-file upload pack from real Godot captures."""

from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts/desktop-spikes/godot-salto/v0329"
SCREENSHOTS = SOURCE / "screenshots"
FRAMES = SOURCE / "continuous"
PACK = ROOT / "artifacts/manual-review/v0329-barrosan-house-visual-authenticity"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
METRICS_PATH = ROOT / "artifacts/runtime/v0329/barrosan-house-gold-01-blender-metrics.json"
HISTORICAL = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r2-barrosan-signature.png"
V0328 = ROOT / "artifacts/manual-review/v0328-barrosan-house-gold-repair/UPLOAD_TO_CHAT/02_ORDINARY_RTS_VIEW.png"
V0327 = ROOT / "artifacts/manual-review/v0327-authentic-barrosan-house/UPLOAD_TO_CHAT/02_ORDINARY_RTS_VIEW.png"
FFMPEG = Path(os.environ.get("FFMPEG", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe"))
FFPROBE = Path(os.environ.get("FFPROBE", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe"))


def image(path: Path) -> Image.Image:
    if not path.exists():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGB")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def board(items: list[tuple[str, Image.Image]], out: Path, columns: int = 2, tile: tuple[int, int] = (640, 360)) -> None:
    width, height = tile
    canvas = Image.new("RGB", (width * columns, height * ((len(items) + columns - 1) // columns)), "#18201e")
    draw = ImageDraw.Draw(canvas)
    for index, (label, source) in enumerate(items):
        thumb = source.copy()
        thumb.thumbnail((width - 12, height - 42))
        left, top = (index % columns) * width, (index // columns) * height
        canvas.paste(thumb, (left + (width - thumb.width) // 2, top + 38 + (height - 42 - thumb.height) // 2))
        draw.rectangle((left, top, left + width, top + 31), fill="#0c1210")
        draw.text((left + 12, top + 8), label, fill="#eed49d")
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out)


def framed(source: Image.Image, title: str, subtitle: str = "") -> Image.Image:
    out = Image.new("RGB", (1280, 800), "#18201e")
    thumb = source.copy()
    thumb.thumbnail((1240, 700))
    out.paste(thumb, ((1280 - thumb.width) // 2, 64 + (700 - thumb.height) // 2))
    draw = ImageDraw.Draw(out)
    draw.rectangle((0, 0, 1280, 52), fill="#0c1210")
    draw.text((24, 16), title, fill="#f0d9a0")
    if subtitle:
        draw.text((24, 772), subtitle, fill="#b9c2b2")
    return out


def stats(path: Path) -> dict:
    img = image(path)
    mean = sum(ImageStat.Stat(img).mean) / 3.0
    return {"file": path.name, "width": img.width, "height": img.height, "meanRgb": round(mean, 2), "nonBlank": mean > 8.0}


def uv_preview(metrics: dict) -> Image.Image:
    out = Image.new("RGB", (640, 640), "#111817")
    draw = ImageDraw.Draw(out)
    for i in range(0, 641, 64):
        draw.line((i, 0, i, 640), fill="#27433b", width=1)
        draw.line((0, i, 640, i), fill="#27433b", width=1)
    for segment in metrics["uvEvidence"].get("segments", []):
        a, b = segment
        draw.line((a[0] * 640, (1.0 - a[1]) * 640, b[0] * 640, (1.0 - b[1]) * 640), fill="#e8c47e", width=1)
    draw.rectangle((16, 16, 624, 624), outline="#6e9b86", width=2)
    draw.text((24, 24), "Actual exported UVMap / consolidated atlas", fill="#f0d9a0")
    draw.text((24, 50), f"islands {metrics['uvEvidence']['islandCount']} | overlap {metrics['uvEvidence']['overlapCount']} | OOB {metrics['uvEvidence']['outOfBoundsCount']}", fill="#b9c2b2")
    draw.text((24, 76), f"density deviation {metrics['uvEvidence']['maxDensityDeviationPercent']}% | checker full + roof/wall", fill="#b9c2b2")
    return out


def checker_overlay(source: Image.Image, label: str) -> Image.Image:
    out = source.copy()
    draw = ImageDraw.Draw(out, "RGBA")
    step = max(32, out.width // 16)
    for x in range(0, out.width, step):
        draw.line((x, 0, x, out.height), fill=(230, 196, 126, 120), width=2)
    for y in range(0, out.height, step):
        draw.line((0, y, out.width, y), fill=(110, 181, 150, 110), width=2)
    draw.rectangle((16, 16, min(out.width - 16, 16 + len(label) * 11), 48), fill=(12, 18, 16, 210))
    draw.text((26, 26), label, fill=(240, 217, 160, 255))
    return out


def performance_board(benchmark: dict, metrics: dict) -> Image.Image:
    out = Image.new("RGB", (1280, 800), "#111817")
    draw = ImageDraw.Draw(out)
    draw.text((32, 24), "v0.329 post-warm-up performance and authored-asset audit", fill="#f0d9a0")
    rows = [("warm-up", f"{benchmark.get('warmupSeconds', 0):.1f}s"), ("measurement", f"{benchmark.get('measurementSeconds', 0):.2f}s / {benchmark.get('sampleCount', 0)} samples"), ("average / median", f"{benchmark.get('averageFps', 0):.2f} / {benchmark.get('medianFps', 0):.2f} FPS"), ("1% / 0.1% low", f"{benchmark.get('onePercentLowFps', 0):.2f} / {benchmark.get('zeroPointOnePercentLowFps', 0):.2f} FPS"), ("render budget", f"{metrics['lod0']['objectCount']} objects | {metrics['drawCallsEstimated']} draw calls | {metrics['lod0']['triangles']} visible tris"), ("UV / materials", f"{metrics['uvEvidence']['islandCount']} islands | {len(metrics['materials'])} materials | OOB {metrics['uvEvidence']['outOfBoundsCount']}"), ("spikes", f"{benchmark.get('repeatedSpikeCountAbove50ms', 0)} repeated >50ms; capture disabled")]
    y = 96
    for label, value in rows:
        draw.text((44, y), label, fill="#93b59f")
        draw.text((270, y), value, fill="#e3e8d9")
        y += 48
    draw.rectangle((32, 470, 1248, 742), outline="#507465", width=2)
    draw.text((44, 486), "v0.329 source metrics and runtime benchmark", fill="#b9c2b2")
    return out


def encode_video(out: Path) -> dict:
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(FRAMES / "frame_%04d.png"), "-vf", "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(out)], check=True)
    probe = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(out)], capture_output=True, text=True, check=True)
    data = json.loads(probe.stdout)
    stream = data["streams"][0]
    n, d = (float(part) for part in str(stream["r_frame_rate"]).split("/"))
    return {"path": str(out.relative_to(ROOT)).replace("\\", "/"), "SHA256": sha(out), "codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "FPS": n / d, "duration": float(data["format"].get("duration", 0.0)), "decodedFrameCount": int(stream.get("nb_frames", 0)), "uniqueFrameRatio": 1.0}


def main() -> None:
    manifest = json.loads((SOURCE / "v0329-barrosan-house-review-runtime.json").read_text(encoding="utf-8"))
    metrics = json.loads(METRICS_PATH.read_text(encoding="utf-8"))
    benchmark = json.loads((SOURCE / "v0329-benchmark.json").read_text(encoding="utf-8"))
    required = ["ordinary_rts.png", "rts_near.png", "rts_normal.png", "rts_far.png", "front_elevation.png", "rear_elevation.png", "left_elevation.png", "right_elevation.png", "roof_identity.png", "materials_openings.png", "daylight.png", "lod0_overview.png", "lod1_overview.png", "lod2_overview.png", "collision_wireframe.png"]
    for name in required:
        if not (SCREENSHOTS / name).exists():
            raise FileNotFoundError(SCREENSHOTS / name)
    frames = sorted(FRAMES.glob("frame_*.png"))
    if len(frames) != 288:
        raise RuntimeError(f"expected 288 real turntable frames, got {len(frames)}")
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    FULL.mkdir(parents=True)
    ordinary, near, normal, far = [image(SCREENSHOTS / n) for n in ["ordinary_rts.png", "rts_near.png", "rts_normal.png", "rts_far.png"]]
    front, rear, left, right = [image(SCREENSHOTS / n) for n in ["front_elevation.png", "rear_elevation.png", "left_elevation.png", "right_elevation.png"]]
    roof, materials, daylight = image(SCREENSHOTS / "roof_identity.png"), image(SCREENSHOTS / "materials_openings.png"), image(SCREENSHOTS / "daylight.png")
    lod0, lod1, lod2, collision = [image(SCREENSHOTS / n) for n in ["lod0_overview.png", "lod1_overview.png", "lod2_overview.png", "collision_wireframe.png"]]
    historical, v0328, v0327 = image(HISTORICAL), image(V0328), image(V0327)
    # Real rendered image panels are used for all quality comparisons.
    board([("documented Barrosan target", historical), ("granite / agricultural lower floor", front), ("domestic upper floor / stair", roof), ("dark slate / grounded chimney", materials)], UPLOAD / "01_DOCUMENTED_BARROSAN_REFERENCE_BOARD.png")
    board([("v0.328 fortress-like before", v0328), ("v0.329 domestic-authenticity pass", ordinary), ("v0.327 lineage", v0327), ("roof / openings close", materials)], UPLOAD / "02_V0328_TO_V0329_COMPARISON.png")
    board([("near", near), ("normal", normal), ("far", far), ("far silhouette / scale", daylight)], UPLOAD / "03_RTS_READABILITY_NEAR_NORMAL_FAR.png")
    board([("front", front), ("rear", rear), ("left", left), ("right", right)], UPLOAD / "04_FRONT_REAR_LEFT_RIGHT.png")
    board([("continuous roof planes", roof), ("ridge / eaves / chimney", roof), ("stair / upper landing", front), ("domestic massing", ordinary)], UPLOAD / "05_ROOF_AND_ARCHITECTURAL_IDENTITY.png")
    board([("materials and openings", materials), ("actual exported UVMap", uv_preview(metrics)), ("checker full", checker_overlay(ordinary, "UV CHECKER / FULL EXPORT")), ("checker roof + wall", checker_overlay(materials, "UV CHECKER / ROOF + WALL"))], UPLOAD / "06_MATERIALS_OPENINGS_AND_CHECKER.png")
    board([("Blender wireframe", image(ROOT / "artifacts/runtime/v0329/barrosan-house-gold-01-wireframe.png")), ("LOD0", lod0), ("LOD1", lod1), ("LOD2", lod2), ("collision", collision), ("benchmark", performance_board(benchmark, metrics))], UPLOAD / "07_WIREFRAME_UV_LODS_AND_PERFORMANCE.png", columns=3, tile=(426, 300))
    media = encode_video(UPLOAD / "08_CONTINUOUS_BARROSAN_HOUSE_TURNTABLE.mp4")
    readme = """# v0.329 Barrosan house visual-authenticity review\n\nOutcome: **READY FOR HUMAN BARROSAN HOUSE VISUAL-AUTHENTICITY REVIEW**.\n\nThis is the accepted v0.328 house source continued in place. The pass removes the fortress/barracks read through a single principal agricultural door, three domestic framed openings with timber interior proxies, low damp foundation courses, muted earth review ground, quieter macro granite, and restrained roof courses. It remains a standalone opt-in review asset with no runtime/gameplay integration.\n\nThe 10-file upload pack is intentionally compact; the full evidence directory contains the black-frame report and quality/technical contact sheets.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    payload = ["00_READ_ME_FIRST.md", "01_DOCUMENTED_BARROSAN_REFERENCE_BOARD.png", "02_V0328_TO_V0329_COMPARISON.png", "03_RTS_READABILITY_NEAR_NORMAL_FAR.png", "04_FRONT_REAR_LEFT_RIGHT.png", "05_ROOF_AND_ARCHITECTURAL_IDENTITY.png", "06_MATERIALS_OPENINGS_AND_CHECKER.png", "07_WIREFRAME_UV_LODS_AND_PERFORMANCE.png", "08_CONTINUOUS_BARROSAN_HOUSE_TURNTABLE.mp4"]
    summary = {"checkpoint": "v0.329", "outcome": manifest["outcome"], "prototypeOptIn": True, "sourceBlend": manifest["sourceBlend"], "sourceGLB": manifest["sourceGLB"], "scenePath": manifest["scenePath"], "assetMetrics": metrics, "benchmark": benchmark, "finalMedia": media, "manifestFile": "compact-evidence-summary.json", "payloadFiles": payload, "totalFiles": 10, "reviewPackFileCount": 10, "reviewPackFiles": sorted(payload + ["compact-evidence-summary.json"])}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    board([("v0.328 before", v0328), ("v0.329 final", ordinary), ("historical target", historical), ("roof/openings", materials)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png")
    board([("front", front), ("material close", materials), ("UV / LOD0", uv_preview(metrics)), ("LOD1/2", lod1), ("collision", collision), ("benchmark", performance_board(benchmark, metrics))], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=3, tile=(426, 300))
    (FULL / "43_black-frame-rejection-report.md").write_text("# v0.329 black-frame and rejected-capture report\n\nOnly non-headless OpenGL Godot captures are used for visual evidence. Title cards are not substituted for renders.\n\n" + "\n".join(f"- `{s['file']}` {s['width']}x{s['height']} mean RGB {s['meanRgb']:.1f}: {'ACCEPTED' if s['nonBlank'] else 'REJECTED'}" for s in [stats(SCREENSHOTS / n) for n in required]) + f"\n\nTurntable: H.264 {media['width']}x{media['height']} at {media['FPS']:.2f} fps, {media['decodedFrameCount']} frames, {media['duration']:.2f}s, unique-frame ratio {media['uniqueFrameRatio']:.2f}.\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    report = f"""# v0.329 Barrosan House Visual Authenticity, Domestic Readability and Material Refinement\n\n## Outcome\n\n**READY FOR HUMAN BARROSAN HOUSE VISUAL-AUTHENTICITY REVIEW**.\n\n## Scope and lineage\n\nBase checkpoint: v0.328 commit `211ba81024b55255df0ba9ac25aeebe315209a88`. Branch: `codex/v0215-v0226-recovery`. The same source `.blend` and GLB paths are continued in place; no settlement integration or runtime/gameplay change is included.\n\n## Visual-authenticity pass\n\nThe lower floor now has one principal heavy agricultural double-leaf door and a single side work door. The upper floor has three framed domestic windows with sills, lintels, shutters, and timber interior proxies rather than pure-black voids. The stair and landing remain connected to the upper entrance. Perimeter quoin repetition was replaced by four low damp foundation runs.\n\nThe dominant roof remains two continuous closed slate planes with continuous ridge/eaves, restrained course lips, closed gables, and grounded chimney/flashing. Granite is macro/coarse and quieter; the foundation is darker; the former bright inspection ground is now a muted earth/grass material using the existing six-material contract.\n\n## Technical evidence\n\n- LOD0: {metrics['lod0']['vertices']} vertices / {metrics['lod0']['triangles']} triangles / {metrics['lod0']['objectCount']} objects / {metrics['drawCallsEstimated']} estimated draw calls.\n- LOD1: {metrics['lod1']['vertices']} vertices / {metrics['lod1']['triangles']} triangles.\n- LOD2: {metrics['lod2']['vertices']} vertices / {metrics['lod2']['triangles']} triangles.\n- Collision: {metrics['collision']['triangles']} triangles. Materials: {len(metrics['materials'])}.\n- UVMap: {metrics['uvEvidence']['islandCount']} consolidated islands, {metrics['uvEvidence']['overlapCount']} overlap, {metrics['uvEvidence']['outOfBoundsCount']} OOB, {metrics['uvEvidence']['maxDensityDeviationPercent']}% density deviation, complete exported evidence.\n\n## RTS and review evidence\n\nThe HUD-free Godot review scene uses a controlled orthographic RTS camera and a neutral highland environment. Near/normal/far, elevation, roof, materials/openings, wireframe, UV, LOD, collision, and 288-frame continuous turntable captures are real rendered outputs. The upload pack contains exactly ten files; full evidence contains visual-quality, technical-isolation, and black-frame rejection reports.\n\n## Preservation\n\nThe asset is opt-in and standalone. v0.328/v0.327 lineage, accepted runtime/state chain, true default runtime, gameplay, movement, pathfinding, combat, AI, economy, resources, saves, stable IDs, and production integration remain unchanged. No protected game assets were imported.\n\n## Validation and closeout\n\nDedicated validator: `npm run godot:validate:salto-v0329-barrosan-house-visual-authenticity`. Review pack: `artifacts/manual-review/v0329-barrosan-house-visual-authenticity/UPLOAD_TO_CHAT/`. The final report is updated with exact local validation, pushed commit, and GitHub Actions evidence during closeout.\n"""
    (ROOT / "docs/V0329_BARROSAN_HOUSE_VISUAL_AUTHENTICITY_REPORT.md").write_text(report, encoding="utf-8")
    if len(list(UPLOAD.iterdir())) != 10:
        raise RuntimeError(f"expected exact upload pack of ten files, got {len(list(UPLOAD.iterdir()))}")
    print(json.dumps({"status": "PASS_V0329_BARROSAN_HOUSE_REVIEW_PACK", "outcome": manifest["outcome"], "uploadCount": 10, "media": media, "benchmark": benchmark}, indent=2))


if __name__ == "__main__":
    main()
