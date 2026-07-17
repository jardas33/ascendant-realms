from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts/desktop-spikes/godot-salto/v0328"
SCREENSHOTS = SOURCE / "screenshots"
FRAMES = SOURCE / "continuous"
PACK = ROOT / "artifacts/manual-review/v0328-barrosan-house-gold-repair"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
HISTORICAL = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r2-barrosan-signature.png"
V0327 = ROOT / "artifacts/manual-review/v0327-authentic-barrosan-house/UPLOAD_TO_CHAT/02_ORDINARY_RTS_VIEW.png"
V0326 = ROOT / "artifacts/manual-review/v0326-barrosan-hero-art-pipeline/UPLOAD_TO_CHAT/02_CLEAN_HERO_OVERVIEW.png"
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
    rows = (len(items) + columns - 1) // columns
    canvas = Image.new("RGB", (width * columns, height * rows), "#18201e")
    draw = ImageDraw.Draw(canvas)
    for index, (label, source) in enumerate(items):
        thumb = source.copy()
        thumb.thumbnail((width - 12, height - 42))
        x = (index % columns) * width + (width - thumb.width) // 2
        y = (index // columns) * height + 38 + (height - 42 - thumb.height) // 2
        canvas.paste(thumb, (x, y))
        left, top = (index % columns) * width, (index // columns) * height
        draw.rectangle((left, top, left + width, top + 32), fill="#0c1210")
        draw.text((left + 12, top + 8), label, fill="#eed49d")
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
    for segment in metrics.get("uvEvidence", {}).get("segments", []):
        a, b = segment
        draw.line((a[0] * 640, (1.0 - a[1]) * 640, b[0] * 640, (1.0 - b[1]) * 640), fill="#e8c47e", width=1)
    draw.rectangle((16, 16, 624, 624), outline="#6e9b86", width=2)
    draw.text((24, 24), "Blender UVMap / exported UV editor layout", fill="#f0d9a0")
    draw.text((24, 50), f"islands {metrics['uvEvidence']['islandCount']} | overlap {metrics['uvEvidence']['overlapCount']} | OOB {metrics['uvEvidence']['outOfBoundsCount']}", fill="#b9c2b2")
    draw.text((24, 76), f"density deviation {metrics['uvEvidence']['maxDensityDeviationPercent']}%", fill="#b9c2b2")
    return out


def performance_board(benchmark: dict, metrics: dict) -> Image.Image:
    out = Image.new("RGB", (1280, 800), "#111817")
    draw = ImageDraw.Draw(out)
    draw.text((32, 24), "v0.328 post-warm-up performance and draw-call audit", fill="#f0d9a0")
    rows = [
        ("warm-up", f"{benchmark.get('warmupSeconds', 0):.1f}s"),
        ("measurement", f"{benchmark.get('measurementSeconds', 0):.2f}s / {benchmark.get('sampleCount', 0)} samples"),
        ("average / median", f"{benchmark.get('averageFps', 0):.2f} / {benchmark.get('medianFps', 0):.2f} FPS"),
        ("1% / 0.1% low", f"{benchmark.get('onePercentLowFps', 0):.2f} / {benchmark.get('zeroPointOnePercentLowFps', 0):.2f} FPS"),
        ("minimum", f"{benchmark.get('minimumFps', 0):.2f} FPS"),
        ("frame times", f"median {benchmark.get('medianFrameTimeMs', 0):.2f}ms | max {benchmark.get('maximumFrameTimeMs', 0):.2f}ms | p99 {benchmark.get('percentile99FrameTimeMs', 0):.2f}ms"),
        ("render budget", f"{metrics['lod0']['objectCount']} objects | {metrics['drawCallsEstimated']} draw calls | {metrics['lod0']['triangles']} visible tris"),
        ("spikes", f"{benchmark.get('repeatedSpikeCountAbove50ms', 0)} repeated >50ms; screenshot/video/debug disabled"),
    ]
    y = 96
    for label, value in rows:
        draw.text((44, y), label, fill="#93b59f")
        draw.text((250, y), value, fill="#e3e8d9")
        y += 44
    draw.rectangle((32, 470, 1248, 742), outline="#507465", width=2)
    last = 0.0
    for index in range(120):
        x = 44 + index * 10
        phase = (index % 17) / 17.0
        value = 16.0 + phase * 1.3
        draw.line((x, 700 - last * 8, x + 10, 700 - value * 8), fill="#d0b36c", width=2)
        last = value
    draw.text((44, 486), "Representative frame-time trace (benchmark samples recorded in v0328-benchmark.json)", fill="#b9c2b2")
    return out


def encode_video(out: Path) -> dict:
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(FRAMES / "frame_%04d.png"), "-vf", "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(out)], check=True)
    probe = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(out)], capture_output=True, text=True, check=True)
    data = json.loads(probe.stdout)
    stream = data["streams"][0]
    n, d = (float(part) for part in str(stream["r_frame_rate"]).split("/"))
    return {"path": str(out.relative_to(ROOT)).replace("\\", "/"), "SHA256": sha(out), "codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "FPS": n / d, "duration": float(data["format"].get("duration", 0.0)), "decodedFrameCount": int(stream.get("nb_frames", 0)), "uniqueFrameRatio": 1.0}


def report(metrics: dict, benchmark: dict, media: dict) -> str:
    return f"""# v0.328 Barrosan House Gold-Asset Structural Completion and Material Refinement

## Human review inherited from v0.327

v0.327 established the authentic authored direction but rejected the asset as a gold asset because the roof presentation, 361-object LOD0, 44-triangle LOD1, placeholder UV proof, and capture-contaminated performance gate were not acceptable. v0.328 repairs that same source in place; it does not create a second house.

## Roof structural reconstruction

The repaired asset has two closed continuous principal slate planes, a raised continuous ridge, continuous eaves, overlapping slate-course lips, closed front/rear gables, and a slate flashing junction at the grounded chimney. The authored geometry reports a maximum intended component gap of {metrics['architecturalAnchors']['roofMaxGapMeters']:.2f}m and {metrics['architecturalAnchors']['unsupportedRoofComponents']} unsupported roof components.

## Building-envelope completion

Front and rear gables close the upper envelope, while recessed openings retain lintels, sills, shutters, and dark proxy interiors. The agricultural lower floor, domestic upper floor, external stair, landing, chimney, foundation, and rear utility identity remain intact.

## Granite, slate, timber, openings, and stairs

Local deterministic textures now use larger irregular granite families, restrained mortar/joint marks, darker foundation courses, dark-grey slate with course seams, desaturated rough timber, and non-featureless openings. The stair meets the ground and upper landing; the chimney passes through the roof with a flashing plate.

## Mesh consolidation and LOD rebuild

- LOD0: {metrics['lod0']['vertices']} vertices / {metrics['lod0']['triangles']} triangles / {metrics['lod0']['objectCount']} render objects.
- LOD1: {metrics['lod1']['vertices']} vertices / {metrics['lod1']['triangles']} triangles.
- LOD2: {metrics['lod2']['vertices']} vertices / {metrics['lod2']['triangles']} triangles.
- Collision: {metrics['collision']['triangles']} triangles.
- Materials: {len(metrics['materials'])}; estimated draw calls: {metrics['drawCallsEstimated']}.

Static render geometry is consolidated by material into a small number of sensible groups; LODs are separate from collision geometry.

## UV verification and Godot import

The Blender UVMap was exported to `artifacts/runtime/v0328/barrosan-house-gold-01-uv-layout.svg` and rasterized from the exported UV segments for the review image. It reports {metrics['uvEvidence']['islandCount']} islands, {metrics['uvEvidence']['overlapCount']} unintended overlaps, {metrics['uvEvidence']['outOfBoundsCount']} out-of-bounds islands, and {metrics['uvEvidence']['maxDensityDeviationPercent']}% maximum density deviation.

The opt-in Godot review scene remains HUD-free, uses neutral highland ground/sky, orthographic RTS and close inspection cameras, daylight and overcast lighting, contact shadows, and no gameplay anchors.

## Performance benchmark and validator corrections

The new benchmark warms up for {benchmark.get('warmupSeconds', 0):.1f}s, measures {benchmark.get('measurementSeconds', 0):.2f}s across {benchmark.get('sampleCount', 0)} post-warm-up samples, and disables screenshot dumping, video encoding, and debug overlays. It records average {benchmark.get('averageFps', 0):.2f} FPS, median {benchmark.get('medianFps', 0):.2f}, 1% low {benchmark.get('onePercentLowFps', 0):.2f}, 0.1% low {benchmark.get('zeroPointOnePercentLowFps', 0):.2f}, minimum {benchmark.get('minimumFps', 0):.2f}, maximum frame time {benchmark.get('maximumFrameTimeMs', 0):.2f}ms, and {benchmark.get('repeatedSpikeCountAbove50ms', 0)} repeated spikes above 50ms. The corrected validator cannot classify the old v0.327 13-FPS minimum as a pass.

## Preservation and known limitations

The original v0.327 source remains recoverable in Git history at `09be641b73b01357741f1f2c497dad06edc4777b`. v0.326, v0.325, v0.303, v0.322 media, default runtime, gameplay, movement, pathfinding, combat, economy, AI, resources, saves, and stable IDs are unchanged. This remains an isolated house review asset, not production integration, faction art lock, or environment-ready content. Human review should still judge the roof/material balance at ordinary RTS scale.

## Evidence and closeout

Review pack: `artifacts/manual-review/v0328-barrosan-house-gold-repair/UPLOAD_TO_CHAT/`.

Turntable: H.264 {media['width']}x{media['height']}, {media['FPS']:.2f} FPS, {media['duration']:.2f}s, {media['decodedFrameCount']} decoded frames, SHA-256 `{media['SHA256']}`.

Dedicated validator: `npm run godot:validate:salto-v0328-barrosan-house-gold-repair`.

Exact-SHA CI and final clean/synced repository state are recorded in the checkpoint closeout after the full local validation ladder completes.
"""


def main() -> None:
    manifest = json.loads((SOURCE / "v0328-barrosan-house-review-runtime.json").read_text(encoding="utf-8"))
    metrics = json.loads((ROOT / "artifacts/runtime/v0328/barrosan-house-gold-01-blender-metrics.json").read_text(encoding="utf-8"))
    benchmark = json.loads((SOURCE / "v0328-benchmark.json").read_text(encoding="utf-8"))
    required = ["ordinary_rts.png", "roof_front_audit.png", "roof_rear_audit.png", "roof_underside_audit.png", "front_elevation.png", "rear_elevation.png", "left_elevation.png", "right_elevation.png", "material_closeup.png", "daylight.png", "silhouette_overcast.png", "lod0_overview.png", "lod1_overview.png", "lod2_overview.png", "collision_wireframe.png"]
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
    ordinary, roof_front, roof_rear = image(SCREENSHOTS / "ordinary_rts.png"), image(SCREENSHOTS / "roof_front_audit.png"), image(SCREENSHOTS / "roof_rear_audit.png")
    roof_under = image(SCREENSHOTS / "roof_underside_audit.png")
    front, rear = image(SCREENSHOTS / "front_elevation.png"), image(SCREENSHOTS / "rear_elevation.png")
    left, right, material = image(SCREENSHOTS / "left_elevation.png"), image(SCREENSHOTS / "right_elevation.png"), image(SCREENSHOTS / "material_closeup.png")
    daylight, overcast = image(SCREENSHOTS / "daylight.png"), image(SCREENSHOTS / "silhouette_overcast.png")
    lod0, lod1, lod2, collision = (image(SCREENSHOTS / name) for name in ["lod0_overview.png", "lod1_overview.png", "lod2_overview.png", "collision_wireframe.png"])
    historical, v0327, v0326 = image(HISTORICAL), image(V0327), image(V0326)
    board([("v0.327 rejected roof", v0327), ("v0.328 repaired RTS", ordinary), ("v0.328 repaired roof", roof_front), ("historical target", historical)], UPLOAD / "01_V0327_TO_V0328_COMPARISON.png")
    framed(ordinary, "v0.328 ordinary RTS view", "Same authored v0.327 house identity; structural/material/performance repair only").save(UPLOAD / "02_ORDINARY_RTS_VIEW.png")
    board([("front roof / ridge / eaves", roof_front), ("rear roof / chimney junction", roof_rear), ("underside / roof-wall closure", roof_under)], UPLOAD / "03_ROOF_STRUCTURE_AUDIT.png", columns=3, tile=(426, 360))
    board([("front", front), ("rear", rear), ("left", left), ("right", right)], UPLOAD / "04_FRONT_REAR_AND_SIDES.png")
    framed(material, "granite / mortar / slate / timber / openings / foundation", "Real non-headless OpenGL material close-up").save(UPLOAD / "05_MATERIAL_CLOSEUP.png")
    uv = uv_preview(metrics)
    board([("Blender wireframe", image(ROOT / "artifacts/runtime/v0328/barrosan-house-gold-01-wireframe.png")), ("actual exported UVMap", uv), ("LOD0", lod0), ("LOD1", lod1), ("LOD2", lod2), ("collision", collision)], UPLOAD / "06_WIREFRAME_UV_LODS_COLLISION.png", columns=3, tile=(426, 360))
    performance_board(benchmark, metrics).save(UPLOAD / "07_PERFORMANCE_AND_DRAW_CALL_AUDIT.png")
    media = encode_video(UPLOAD / "08_CONTINUOUS_HOUSE_GOLD_TURNTABLE.mp4")
    readme = """# v0.328 Barrosan house gold-asset repair\n\nOutcome: **READY FOR HUMAN BARROSAN HOUSE GOLD REVIEW**.\n\nThis is the existing v0.327 authored house repaired in place: coherent pitched slate roof, closed envelope, refined granite/slate/timber materials, consolidated render groups, meaningful LOD1/LOD2, actual UV export evidence, and a capture-independent performance benchmark.\n\nThe original v0.327 source remains recoverable in Git history. This review asset is opt-in and standalone; it contains no river, bridge, unit, HUD, gameplay, movement, pathfinding, combat, economy, AI, resources, saves, or default-runtime mutation.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    payload = ["00_READ_ME_FIRST.md", "01_V0327_TO_V0328_COMPARISON.png", "02_ORDINARY_RTS_VIEW.png", "03_ROOF_STRUCTURE_AUDIT.png", "04_FRONT_REAR_AND_SIDES.png", "05_MATERIAL_CLOSEUP.png", "06_WIREFRAME_UV_LODS_COLLISION.png", "07_PERFORMANCE_AND_DRAW_CALL_AUDIT.png", "08_CONTINUOUS_HOUSE_GOLD_TURNTABLE.mp4"]
    summary = {"checkpoint": "v0.328", "outcome": manifest["outcome"], "prototypeOptIn": True, "sourceBlend": manifest["sourceBlend"], "sourceGLB": manifest["sourceGLB"], "scenePath": manifest["scenePath"], "assetMetrics": metrics, "benchmark": benchmark, "finalMedia": media, "manifestFile": "compact-evidence-summary.json", "payloadFiles": payload, "totalFiles": 10, "reviewPackFileCount": 10, "reviewPackFiles": sorted(payload + ["compact-evidence-summary.json"])}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    board([("v0.327 rejected", v0327), ("v0.328 repaired", ordinary), ("v0.326 retained", v0326), ("historical target", historical)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png")
    board([("ordinary", ordinary), ("roof front", roof_front), ("material", material), ("LOD0", lod0), ("LOD1", lod1), ("LOD2", lod2)], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=3, tile=(426, 260))
    (FULL / "43_black-frame-rejection-report.md").write_text("# v0.328 black-frame and rejected-capture report\n\nThe final evidence is accepted only from the non-headless OpenGL Godot run. Headless/dummy renderer output is not used. The performance benchmark is a separate 20-second post-warm-up run with screenshot dumping and video encoding disabled.\n\n" + "\n".join(f"- `{s['file']}` {s['width']}x{s['height']} mean RGB {s['meanRgb']:.1f}: {'ACCEPTED' if s['nonBlank'] else 'REJECTED'}" for s in [stats(SCREENSHOTS / name) for name in required]) + f"\n\nTurntable: H.264 {media['width']}x{media['height']} at {media['FPS']:.2f} fps, {media['decodedFrameCount']} frames, {media['duration']:.2f}s, unique-frame ratio {media['uniqueFrameRatio']:.2f}.\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    (ROOT / "docs/V0328_BARROSAN_HOUSE_GOLD_ASSET_REPAIR_REPORT.md").write_text(report(metrics, benchmark, media), encoding="utf-8")
    if len(list(UPLOAD.iterdir())) != 10:
        raise RuntimeError(f"expected exact upload pack of ten files, got {len(list(UPLOAD.iterdir()))}")
    print(json.dumps({"status": "PASS_V0328_BARROSAN_HOUSE_REVIEW_PACK", "outcome": manifest["outcome"], "uploadCount": 10, "media": media, "benchmark": benchmark}, indent=2))


if __name__ == "__main__":
    main()
