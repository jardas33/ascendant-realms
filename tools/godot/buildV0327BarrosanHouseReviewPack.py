from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts/desktop-spikes/godot-salto/v0327"
SCREENSHOTS = SOURCE / "screenshots"
FRAMES = SOURCE / "continuous"
PACK = ROOT / "artifacts/manual-review/v0327-authentic-barrosan-house"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
HISTORICAL = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/historical-reference/candidates/v0141-env-r2-barrosan-signature.png"
V0326 = ROOT / "artifacts/manual-review/v0326-barrosan-hero-art-pipeline/UPLOAD_TO_CHAT/02_CLEAN_HERO_OVERVIEW.png"
V0303 = ROOT / "artifacts/manual-review/v0304-visual-archaeology-style-lock-recovery/current-v0303/v0303_player_overview_actual.png"
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
        draw.rectangle(((index % columns) * width, (index // columns) * height, (index % columns + 1) * width, (index // columns) * height + 32), fill="#0c1210")
        draw.text(((index % columns) * width + 12, (index // columns) * height + 8), label, fill="#eed49d")
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


def encode_video(out: Path) -> dict:
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(FRAMES / "frame_%04d.png"), "-vf", "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(out)], check=True)
    probe = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(out)], capture_output=True, text=True, check=True)
    data = json.loads(probe.stdout)
    stream = data["streams"][0]
    n, d = (float(part) for part in str(stream["r_frame_rate"]).split("/"))
    return {"path": str(out.relative_to(ROOT)).replace("\\", "/"), "SHA256": sha(out), "codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "FPS": n / d, "duration": float(data["format"].get("duration", 0.0)), "decodedFrameCount": int(stream.get("nb_frames", 0))}


def main() -> None:
    manifest_path = SOURCE / "v0327-barrosan-house-review-runtime.json"
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    required = ["ordinary_rts.png", "front_three_quarter.png", "rear_three_quarter.png", "left_elevation.png", "right_elevation.png", "material_closeup.png", "daylight.png", "silhouette_overcast.png"]
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
    ordinary = image(SCREENSHOTS / "ordinary_rts.png")
    front = image(SCREENSHOTS / "front_three_quarter.png")
    rear = image(SCREENSHOTS / "rear_three_quarter.png")
    left = image(SCREENSHOTS / "left_elevation.png")
    right = image(SCREENSHOTS / "right_elevation.png")
    material = image(SCREENSHOTS / "material_closeup.png")
    daylight = image(SCREENSHOTS / "daylight.png")
    overcast = image(SCREENSHOTS / "silhouette_overcast.png")
    historical, v0326, v0303 = image(HISTORICAL), image(V0326), image(V0303)

    board([("v0.141 recovered target", historical), ("v0.303 PLAYER", v0303), ("v0.326 rejected hero", v0326), ("v0.327 authored house", ordinary)], UPLOAD / "01_REFERENCE_TO_ASSET_COMPARISON.png")
    framed(ordinary, "v0.327 ordinary RTS view", "Standalone authored Barrosan house gold asset; no gameplay or environment integration") .save(UPLOAD / "02_ORDINARY_RTS_VIEW.png")
    board([("front three-quarter", front), ("rear three-quarter", rear)], UPLOAD / "03_FRONT_AND_REAR.png")
    board([("left elevation", left), ("right elevation", right)], UPLOAD / "04_SIDE_ELEVATIONS.png")
    framed(material, "weathered granite, recesses, timber, foundation", "Material close-up from real non-headless OpenGL capture").save(UPLOAD / "05_MATERIAL_CLOSEUP.png")
    wire = image(ROOT / "artifacts/runtime/v0327/barrosan-house-gold-01-wireframe.png")
    metrics = json.loads((ROOT / "artifacts/runtime/v0327/barrosan-house-gold-01-blender-metrics.json").read_text(encoding="utf-8"))
    uv = Image.new("RGB", (640, 360), "#111817")
    draw = ImageDraw.Draw(uv)
    for x in range(32, 640, 64): draw.line((x, 32, x, 328), fill="#5e8073", width=1)
    for y in range(32, 360, 48): draw.line((32, y, 608, y), fill="#5e8073", width=1)
    draw.text((48, 50), "UV / LOD contract", fill="#f0d9a0")
    draw.text((48, 84), f"LOD0 triangles: {metrics['lod0']['triangles']}", fill="#b9c2b2")
    draw.text((48, 110), f"LOD1 triangles: {metrics['lod1']['triangles']}", fill="#b9c2b2")
    draw.text((48, 136), f"Collision triangles: {metrics['collision']['triangles']}", fill="#b9c2b2")
    board([("authored Blender wireframe", wire), ("UV / LOD metrics", uv)], UPLOAD / "06_WIREFRAME_UV_AND_LOD.png")
    board([("directional daylight", daylight), ("overcast silhouette", overcast)], UPLOAD / "07_LIGHTING_AND_SILHOUETTE.png")
    media = encode_video(UPLOAD / "08_CONTINUOUS_HOUSE_TURNTABLE.mp4")
    readme = """# v0.327 authentic Barrosan house gold asset\n\nOutcome: **READY FOR HUMAN BARROSAN HOUSE REVIEW**.\n\nThis upload set contains exactly one newly authored standalone Barrosan rural house gold asset, exported from Blender 5.1.2, imported into Godot, and captured through a real non-headless OpenGL review scene. The asset is not production-ready, an art lock, full faction art, environment integration, or gameplay integration.\n\nThe house is inspired by documented Barroso vernacular cues: local granite masonry, agricultural lower floor, domestic upper floor, recessed openings, slate roof, timber details, and external stone stairs. It is an original authored interpretation; no protected-game assets are used.\n\nNo river, bridge, Worker, combat unit, vegetation pack, gameplay, movement, pathfinding, economy, resource mutation, save mutation, or default-runtime change is included. The review scene follows repository convention at `desktop-spikes/godot-salto/scenes/review/V0327BarrosanHouseReview.tscn`.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    summary = {"checkpoint": "v0.327", "outcome": manifest["outcome"], "prototypeOptIn": True, "sourceBlend": manifest["sourceBlend"], "sourceGLB": manifest["sourceGLB"], "scenePath": manifest["scenePath"], "toolchain": {"blender": "Blender 5.1.2 ec6e62d40fa9", "godot": "Godot 4.6.3 stable", "realOpenGLCapture": True}, "assetMetrics": metrics, "runtimeManifest": manifest, "finalMedia": media, "reviewPackFileCount": 10, "reviewPackFiles": sorted(p.name for p in UPLOAD.iterdir())}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    board([("reference target", historical), ("current v0.303", v0303), ("v0.326 rejected", v0326), ("v0.327 house", ordinary)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png")
    board([("ordinary", ordinary), ("material", material), ("front", front), ("rear", rear), ("left", left), ("right", right)], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=3, tile=(426, 260))
    (FULL / "43_black-frame-rejection-report.md").write_text("# v0.327 black-frame/rejected-capture report\n\nThe headless dummy-renderer attempt was rejected because it exposed no viewport texture. All final PNGs and the turntable were captured from the non-headless OpenGL Godot run.\n\n" + "\n".join(f"- `{s['file']}` {s['width']}x{s['height']} mean RGB {s['meanRgb']:.1f}: {'ACCEPTED' if s['nonBlank'] else 'REJECTED'}" for s in [stats(SCREENSHOTS / name) for name in required]) + f"\n\nTurntable: H.264 {media['width']}x{media['height']} at {media['FPS']:.2f} fps, {media['decodedFrameCount']} frames, {media['duration']:.2f}s.\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    if len(list(UPLOAD.iterdir())) != 10:
        raise RuntimeError(f"expected exact upload pack of ten files, got {len(list(UPLOAD.iterdir()))}")
    print(json.dumps({"status": "PASS_V0327_BARROSAN_HOUSE_REVIEW_PACK", "outcome": manifest["outcome"], "uploadCount": 10, "media": media}, indent=2))


if __name__ == "__main__":
    main()
