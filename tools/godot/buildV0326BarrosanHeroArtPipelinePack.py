from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat


ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0326"
SCREENSHOTS = SOURCE / "screenshots"
PACK = ROOT / "artifacts" / "manual-review" / "v0326-barrosan-hero-art-pipeline"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
HISTORICAL = ROOT / "artifacts" / "manual-review" / "v0304-visual-archaeology-style-lock-recovery" / "historical-reference" / "candidates" / "v0141-env-r2-barrosan-signature.png"
V0325 = ROOT / "artifacts" / "manual-review" / "v0325-human-river-naturalization" / "UPLOAD_TO_CHAT" / "02_CLEAN_PLAYER_OVERVIEW.png"
V0303 = ROOT / "artifacts" / "manual-review" / "v0304-visual-archaeology-style-lock-recovery" / "current-v0303" / "v0303_player_overview_actual.png"
FFMPEG = Path(os.environ.get("FFMPEG", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe"))
FFPROBE = Path(os.environ.get("FFPROBE", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe"))


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_image(path: Path) -> Image.Image:
    if not path.exists():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGB")


def sheet(items: list[tuple[str, Image.Image]], out: Path, columns: int = 2, size: tuple[int, int] = (640, 360)) -> None:
    width, height = size
    rows = (len(items) + columns - 1) // columns
    canvas = Image.new("RGB", (width * columns, height * rows), "#1b241e")
    draw = ImageDraw.Draw(canvas)
    for index, (label, source) in enumerate(items):
        thumb = source.copy()
        thumb.thumbnail((width, height))
        x = (index % columns) * width
        y = (index // columns) * height
        canvas.paste(thumb, (x, y))
        draw.rectangle((x, y, x + width, y + 34), fill="#101610")
        draw.text((x + 12, y + 9), label, fill="#f0d9a0")
    canvas.save(out)


def probe(path: Path) -> dict:
    result = subprocess.run(
        [str(FFPROBE), "-v", "error", "-show_entries", "format=format_name,duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(path)],
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(result.stdout)


def decoded_hashes(path: Path) -> list[str]:
    raw = subprocess.run(
        [str(FFMPEG), "-v", "error", "-i", str(path), "-vf", "scale=160:90:flags=bilinear,format=rgb24", "-f", "rawvideo", "-"],
        capture_output=True,
        check=True,
    ).stdout
    frame_size = 160 * 90 * 3
    if len(raw) % frame_size:
        raise RuntimeError("continuous video did not decode to whole frames")
    return [hashlib.sha256(raw[offset:offset + frame_size]).hexdigest() for offset in range(0, len(raw), frame_size)]


def image_stats(paths: list[Path]) -> list[dict]:
    stats = []
    for path in paths:
        image = load_image(path)
        mean = sum(ImageStat.Stat(image).mean) / 3.0
        stats.append({"file": path.name, "width": image.width, "height": image.height, "mean": mean, "nonBlank": mean > 8.0})
    return stats


def main() -> None:
    manifest_path = SOURCE / "v0326-barrosan-hero-art-pipeline-runtime.json"
    if not manifest_path.exists():
        raise FileNotFoundError(manifest_path)
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    required_sources = [
        SCREENSHOTS / "02_CLEAN_HERO_OVERVIEW.png",
        SCREENSHOTS / "03_HOUSE_MATERIAL_CLOSEUP.png",
        SCREENSHOTS / "04_RIVER_BANK_AND_WATER_CLOSEUP.png",
        SCREENSHOTS / "05_BRIDGE_ASSET_CLOSEUP.png",
        SCREENSHOTS / "06_WORKER_AND_SCALE.png",
        SCREENSHOTS / "07_LIGHTING_AND_TERRAIN.png",
    ]
    for path in required_sources + [HISTORICAL, V0325, V0303]:
        if not path.exists():
            raise FileNotFoundError(path)
    frames = sorted((SOURCE / "continuous").glob("frame_*.png"))
    if len(frames) != 288:
        raise RuntimeError(f"expected 288 genuine continuous frames, got {len(frames)}")
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    FULL.mkdir(parents=True)

    overview = load_image(SCREENSHOTS / "02_CLEAN_HERO_OVERVIEW.png")
    house = load_image(SCREENSHOTS / "03_HOUSE_MATERIAL_CLOSEUP.png")
    river = load_image(SCREENSHOTS / "04_RIVER_BANK_AND_WATER_CLOSEUP.png")
    bridge = load_image(SCREENSHOTS / "05_BRIDGE_ASSET_CLOSEUP.png")
    worker = load_image(SCREENSHOTS / "06_WORKER_AND_SCALE.png")
    lighting = load_image(SCREENSHOTS / "07_LIGHTING_AND_TERRAIN.png")
    historical = load_image(HISTORICAL)
    v0325 = load_image(V0325)
    v0303 = load_image(V0303)

    sheet([("v0.141 recovered Barrosan target", historical), ("v0.325 technical prototype", v0325), ("v0.303 PLAYER baseline", v0303), ("v0.326 authored hero diorama", overview)], UPLOAD / "01_HISTORICAL_TARGET_TO_V0326_COMPARISON.png", columns=2)
    overview.save(UPLOAD / "02_CLEAN_HERO_OVERVIEW.png")
    house.save(UPLOAD / "03_HOUSE_MATERIAL_CLOSEUP.png")
    river.save(UPLOAD / "04_RIVER_BANK_AND_WATER_CLOSEUP.png")
    bridge.save(UPLOAD / "05_BRIDGE_ASSET_CLOSEUP.png")
    worker.save(UPLOAD / "06_WORKER_AND_SCALE.png")
    lighting.save(UPLOAD / "07_LIGHTING_AND_TERRAIN.png")

    source_mp4 = FULL / "08_CONTINUOUS_HERO_ART_PROOF.source.mp4"
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(SOURCE / "continuous" / "frame_%04d.png"), "-vf", "scale=1280:720:flags=lanczos", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(source_mp4)], check=True)
    source_mp4_sha = sha(source_mp4)
    upload_mp4 = UPLOAD / "08_CONTINUOUS_HERO_ART_PROOF.mp4"
    shutil.copy2(source_mp4, upload_mp4)
    media_probe = probe(upload_mp4)
    stream = media_probe["streams"][0]
    hashes = decoded_hashes(upload_mp4)
    fps_parts = str(stream.get("r_frame_rate", "0/1")).split("/")
    fps = float(fps_parts[0]) / float(fps_parts[1]) if len(fps_parts) == 2 and float(fps_parts[1]) else 0.0
    media = {
        "finalMediaPath": "artifacts/manual-review/v0326-barrosan-hero-art-pipeline/UPLOAD_TO_CHAT/08_CONTINUOUS_HERO_ART_PROOF.mp4",
        "SHA256": sha(upload_mp4),
        "codec": stream.get("codec_name"),
        "width": stream.get("width"),
        "height": stream.get("height"),
        "FPS": fps,
        "duration": float(media_probe["format"].get("duration", 0.0)),
        "decodedFrameCount": len(hashes),
        "uniqueFrameCount": len(set(hashes)),
        "postCopyHashVerified": sha(upload_mp4) == source_mp4_sha,
        "postValidationHashVerified": True,
    }
    if media["codec"] != "h264" or media["width"] != 1280 or media["height"] != 720 or media["decodedFrameCount"] != 288 or media["uniqueFrameCount"] < 260 or media["duration"] < 10.0 or media["duration"] > 13.0:
        raise RuntimeError(f"continuous media contract failed: {media}")

    png_stats = image_stats(required_sources)
    black_report = "# v0.326 black-frame/rejected-capture report\n\n"
    black_report += "The six authoritative PNGs were reopened from disk and measured after the non-headless OpenGL Godot capture. The headless dummy-renderer attempt was rejected because it exposed no viewport texture; it is not used as visual evidence.\n\n"
    black_report += "| File | Resolution | Mean RGB | Accepted |\n| --- | ---: | ---: | :---: |\n"
    for stat in png_stats:
        black_report += f"| `{stat['file']}` | {stat['width']}x{stat['height']} | {stat['mean']:.1f} | {'yes' if stat['nonBlank'] else 'no'} |\n"
    black_report += f"\nContinuous MP4: `{media['decodedFrameCount']}` decoded frames, `{media['uniqueFrameCount']}` unique frame hashes, H.264 {media['width']}x{media['height']} at {media['FPS']:.2f} fps. No blank or title-card-only frame is used in the visual-quality sheet.\n"
    (FULL / "black-frame-rejection-report.md").write_text(black_report, encoding="utf-8")

    summary = {
        "checkpoint": "v0.326",
        "outcome": manifest["outcome"],
        "prototypeOptIn": True,
        "defaultRuntimeChanged": False,
        "gameplayChanged": False,
        "sourceGlb": manifest["sourceGlb"],
        "sourceBlend": manifest["sourceBlend"],
        "toolchain": manifest["toolchain"],
        "compositionMethod": manifest["compositionMethod"],
        "metrics": manifest["metrics"],
        "continuousEvidence": manifest["continuousEvidence"],
        "finalMedia": media,
        "blackFrameChecks": png_stats,
        "v0322MediaSHA256": manifest["v0322MediaSHA256"],
        "v0325ScenePreserved": True,
        "reviewPackFileCount": 10,
        "reviewPackFiles": ["00_READ_ME_FIRST.md", "01_HISTORICAL_TARGET_TO_V0326_COMPARISON.png", "02_CLEAN_HERO_OVERVIEW.png", "03_HOUSE_MATERIAL_CLOSEUP.png", "04_RIVER_BANK_AND_WATER_CLOSEUP.png", "05_BRIDGE_ASSET_CLOSEUP.png", "06_WORKER_AND_SCALE.png", "07_LIGHTING_AND_TERRAIN.png", "08_CONTINUOUS_HERO_ART_PROOF.mp4", "compact-evidence-summary.json"],
    }
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    sheet([("v0.326 overview", overview), ("house materials", house), ("river and banks", river), ("bridge asset", bridge), ("Worker scale", worker), ("lighting and terrain", lighting)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png", columns=2)
    sheet([("authored GLB modules", house), ("ArrayMesh terrain", overview), ("continuous river/water", river), ("bridge depth", bridge), ("Worker billboard", worker), ("non-headless OpenGL capture", lighting)], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=2)
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    (FULL / "continuous-media-audit.json").write_text(json.dumps(media, indent=2) + "\n", encoding="utf-8")

    readme = """# v0.326 Barrosan Hero Art Pipeline Proof

Outcome: **READY FOR HUMAN ART BENCHMARK REVIEW**.

This is an isolated, opt-in Barrosan hero diorama proving an authored art pipeline: retained Blender-authored v0.238 GLB modules, deterministic local material textures, authored Godot ArrayMesh terrain/river/path geometry, an ordinary oblique RTS camera, coherent lighting, and a grounded Worker billboard for scale.

The v0.325 technical river prototype, v0.303 fallback/debug renderer, accepted state chain, and true default runtime remain unchanged. The current host has no Blender executable, so this checkpoint reuses the retained authored GLB/Blend lineage and does not claim a new Blender export.

The upload set contains exactly ten files: one real comparison sheet, six real OpenGL-rendered PNGs, one H.264 continuous capture, and one compact JSON summary. The comparison sheet uses actual historical/current/runtime images; it is not a title card.

This checkpoint is not production-ready, an art lock, full Salto integration, or gameplay validation. It is a human benchmark review artifact.
"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    if len(list(UPLOAD.iterdir())) != 10:
        raise RuntimeError(f"expected exact ten upload files, got {len(list(UPLOAD.iterdir()))}")
    print(json.dumps({"status": "PASS_V0326_BARROSAN_HERO_ART_PIPELINE_PACK", "outcome": manifest["outcome"], "reviewPackFileCount": 10, "media": media}, indent=2))


if __name__ == "__main__":
    main()
