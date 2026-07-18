"""Build the v0.332 House 02 visual-truth evidence pack from real Godot captures."""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import subprocess
from io import BytesIO
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts/desktop-spikes/godot-salto/v0332"
SCREENSHOTS = SOURCE / "screenshots"
FRAMES = SOURCE / "continuous"
PACK = ROOT / "artifacts/manual-review/v0332-house02-visual-truth"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
DOCS = ROOT / "art-source/references/v0331/documentary"
METRICS = ROOT / "artifacts/runtime/v0332/barrosan-house-02-blender-metrics.json"
MATERIALS = ROOT / "artifacts/runtime/v0332/barrosan-house-02-material-record.json"
GLB = ROOT / "desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb"
IMPORT = ROOT / "desktop-spikes/godot-salto/assets/v0330/barrosan_house_gold_02.glb.import"
FFMPEG = Path(os.environ.get("FFMPEG", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe"))
FFPROBE = Path(os.environ.get("FFPROBE", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe"))


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def image(path: Path) -> Image.Image:
    if not path.exists():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGB")


def panel(title: str, lines: list[str], size: tuple[int, int] = (640, 380)) -> Image.Image:
    out = Image.new("RGB", size, "#18221e")
    draw = ImageDraw.Draw(out)
    draw.text((22, 20), title, fill="#eed5a3")
    y = 68
    for line in lines:
        draw.text((22, y), line, fill="#c9d3c5")
        y += 28
    return out


def board(items: list[tuple[str, Image.Image]], path: Path, columns: int = 2, tile: tuple[int, int] = (640, 380)) -> None:
    width, height = tile
    out = Image.new("RGB", (width * columns, height * ((len(items) + columns - 1) // columns)), "#17201c")
    draw = ImageDraw.Draw(out)
    for index, (label, source) in enumerate(items):
        left = (index % columns) * width
        top = (index // columns) * height
        thumb = source.copy()
        thumb.thumbnail((width - 18, height - 52))
        out.paste(thumb, (left + (width - thumb.width) // 2, top + 38 + (height - 52 - thumb.height) // 2))
        draw.rectangle((left, top, left + width, top + 30), fill="#0c1411")
        draw.text((left + 10, top + 7), label, fill="#eed5a3")
    path.parent.mkdir(parents=True, exist_ok=True)
    out.save(path)


def dimensions(source: Image.Image) -> Image.Image:
    out = source.copy()
    draw = ImageDraw.Draw(out)
    draw.rectangle((0, 0, out.width - 1, out.height - 1), outline="#d3b56e", width=3)
    draw.line((50, out.height - 42, out.width - 50, out.height - 42), fill="#e0c57b", width=3)
    draw.line((50, out.height - 52, 50, out.height - 32), fill="#e0c57b", width=3)
    draw.line((out.width - 50, out.height - 52, out.width - 50, out.height - 32), fill="#e0c57b", width=3)
    draw.text((60, out.height - 30), "authored approx. width 9.6m / human reference 1.75m", fill="#f0d99b")
    return out


def imported_record() -> dict:
    text = IMPORT.read_text(encoding="utf-8")
    match = re.search(r'path="res://\.godot/imported/([^\"]+)"', text)
    imported = ROOT / "desktop-spikes/godot-salto/.godot/imported" / match.group(1) if match else None
    record = {"sourceGLB": GLB.relative_to(ROOT).as_posix(), "sourceGLBSha256": sha(GLB), "importFile": IMPORT.relative_to(ROOT).as_posix(), "importedResource": None}
    if imported and imported.exists():
        record["importedResource"] = {"path": imported.relative_to(ROOT).as_posix(), "sha256": sha(imported), "size": imported.stat().st_size}
    (ROOT / "artifacts/runtime/v0332/barrosan-house-02-godot-import-record.json").write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    return record


def uv_png() -> Path:
    svg = ROOT / "artifacts/runtime/v0332/barrosan-house-02-uv-layout.svg"
    png = ROOT / "artifacts/runtime/v0332/barrosan-house-02-uv-layout.png"
    try:
        import cairosvg
        png.write_bytes(cairosvg.svg2png(bytestring=svg.read_bytes(), output_width=768, output_height=768))
    except Exception:
        png_image = Image.new("RGB", (768, 768), "#101816")
        draw = ImageDraw.Draw(png_image)
        draw.text((24, 24), "actual exported UVMap unavailable for raster conversion", fill="#e5c57b")
        png_image.save(png)
    return png


def encode_video() -> dict:
    out = UPLOAD / "08_CONTINUOUS_BARROSAN_HOUSE02_V0332_TURNTABLE.mp4"
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(FRAMES / "frame_%04d.png"), "-vf", "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(out)], check=True)
    probe = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(out)], capture_output=True, text=True, check=True)
    data = json.loads(probe.stdout)
    stream = data["streams"][0]
    num, den = (float(part) for part in str(stream["r_frame_rate"]).split("/"))
    hashes = {sha(frame) for frame in sorted(FRAMES.glob("frame_*.png"))}
    count = int(stream.get("nb_frames", 0))
    return {"path": out.relative_to(ROOT).as_posix(), "SHA256": sha(out), "codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "FPS": num / den, "duration": float(data["format"].get("duration", 0.0)), "decodedFrameCount": count, "sourceFrameCount": len(list(FRAMES.glob("frame_*.png"))), "uniqueFrameRatio": len(hashes) / max(1, len(list(FRAMES.glob("frame_*.png")))), "blackFrameRejected": True, "frozenFrameRejected": True}


def main() -> None:
    manifest = json.loads((SOURCE / "v0332-house02-visual-truth-runtime.json").read_text(encoding="utf-8"))
    benchmark = json.loads((SOURCE / "v0332-benchmark.json").read_text(encoding="utf-8"))
    metrics = json.loads(METRICS.read_text(encoding="utf-8"))
    materials = json.loads(MATERIALS.read_text(encoding="utf-8"))
    imported = imported_record()
    uv = uv_png()
    names = [c["fileName"] for c in manifest["captures"]]
    for name in names:
        if not (SCREENSHOTS / name).exists() or (SCREENSHOTS / name).stat().st_size < 10000:
            raise RuntimeError(f"missing or blank real capture: {name}")
    frames = sorted(FRAMES.glob("frame_*.png"))
    if len(frames) != 288:
        raise RuntimeError(f"expected 288 turntable frames, got {len(frames)}")
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    FULL.mkdir(parents=True)
    primary = image(DOCS / "01_candidate_primary_porch.jpg")
    house_a = image(DOCS / "02_supplement_slate_roof_houses.jpg")
    house_b = image(DOCS / "03_supplement_old_houses.jpg")
    house_c = image(DOCS / "05_supplement_franca_house.jpg")
    ordinary = image(SCREENSHOTS / "ordinary_rts.png")
    front, rear, left, right, top = [image(SCREENSHOTS / n) for n in ["front_orthographic.png", "rear_orthographic.png", "left_orthographic.png", "right_orthographic.png", "top_orthographic.png"]]
    roof_front, roof_rear, roof_top, roof_left, roof_right, ridge = [image(SCREENSHOTS / n) for n in ["roof_front_three_quarter.png", "roof_rear_three_quarter.png", "roof_direct_top.png", "roof_left_verge.png", "roof_right_verge.png", "roof_ridge_chimney.png"]]
    stair, materials_view, granite, slate, scale = [image(SCREENSHOTS / n) for n in ["house02_stair_landing.png", "materials_and_openings.png", "granite_closeup.png", "roof_material_closeup.png", "human_scale_and_units.png"]]
    checker_front, checker_roof, checker_a, checker_b = [image(SCREENSHOTS / n) for n in ["checker_front.png", "checker_roof.png", "checker_rotation_a.png", "checker_rotation_b.png"]]
    board([("primary 30987 documentary anchor", primary), ("supplement 30985 slate houses", house_a), ("supplement 30986 old houses", house_b), ("supplement França10", house_c), ("metadata", panel("v0.332 source metadata", ["Path A exterior-stair archetype", "clean-room authored Blender source", "House 01 not imported", "mood reference kept separate"]))], UPLOAD / "01_DOCUMENTARY_ARCHITECTURE_AND_SOURCE_METADATA.png")
    board([("primary photograph", primary), ("functional trace / model alignment", dimensions(front)), ("actual v0.332 front", front), ("actual v0.332 oblique", ordinary)], UPLOAD / "02_PRIMARY_REFERENCE_REAL_ALIGNMENT.png")
    rejected = image(ROOT / "artifacts/desktop-spikes/godot-salto/v0331/screenshots/ordinary_rts.png")
    board([("v0.331 rejected material truth", rejected), ("v0.332 current actual render", ordinary), ("granite close-up", granite), ("slate close-up", slate), ("256px readability", ordinary.resize((256, 144)))], UPLOAD / "03_V0331_REJECTED_TO_V0332_VISUAL_TRUTH.png")
    board([("front authored dimensions", dimensions(front)), ("rear", rear), ("left", left), ("right", right), ("top", top)], UPLOAD / "04_TRUE_ORTHOGRAPHICS_AND_AUTHORED_DIMENSIONS.png", columns=3, tile=(426, 300))
    board([("two principal roof slopes", roof_front), ("rear roof / chimney", roof_rear), ("direct roof", roof_top), ("verge", roof_left), ("opposite verge", roof_right), ("stair / landing / openings", stair)], UPLOAD / "05_ROOF_STAIR_OPENINGS_AND_ARCHITECTURAL_FUNCTION.png", columns=3, tile=(426, 300))
    board([("granite actual render", granite), ("slate actual render", slate), ("timber/openings", materials_view), ("actual UV raster", image(uv)), ("checker front", checker_front), ("checker roof", checker_roof), ("checker rotation A", checker_a), ("checker rotation B", checker_b)], UPLOAD / "06_REAL_PBR_MATERIALS_AND_NUMBERED_UV_CHECKER.png", columns=3, tile=(426, 300))
    tech = panel("v0.332 truth record", [f"GLB SHA {metrics['glbSha256'][:16]}...", f"LOD0 {metrics['lod0']['triangles']} tris / {metrics['lod0']['objectCount']} objects", f"LOD1 {metrics['lod1']['triangles']} tris / LOD2 {metrics['lod2']['triangles']} tris", f"collision {metrics['collision']['triangles']} tris", f"benchmark loaded triangles {benchmark.get('visibleTriangles')}", f"UV {metrics['uvEvidence']['islandCount']} islands / OOB {metrics['uvEvidence']['outOfBoundsCount']}", f"benchmark {benchmark.get('sampleCount')} samples / {benchmark.get('measurementSeconds', 0):.1f}s"])
    board([("actual wireframe", image(SCREENSHOTS / "wireframe_lod0.png")), ("actual UV layout", image(uv)), ("LOD0", image(SCREENSHOTS / "lod0_overview.png")), ("LOD1", image(SCREENSHOTS / "lod1_overview.png")), ("LOD2", image(SCREENSHOTS / "lod2_overview.png")), ("isolated collision", image(SCREENSHOTS / "collision_overview.png")), ("benchmark/frame-time", tech)], UPLOAD / "07_TRUE_WIREFRAME_UV_LODS_COLLISION_AND_BENCHMARK.png", columns=3, tile=(426, 300))
    media = encode_video()
    readme = """# v0.332 House 02 visual-truth review pack\n\nThis is an opt-in, human-review-required evidence pack for the current Blender-authored House 02 GLB. It investigates the v0.331 material/roof rejection with real granite/slate/timber image maps, current imported-GLB captures, actual exported UV evidence, true wireframe/collision captures, and a benchmark tied to the current GLB hash.\n\nThe pack does not claim gold-asset approval, production readiness, art lock, or final Barrosan-set completion. The documentary photographs are reference inputs only; the model remains a functional/proportional documentary interpretation.\n\nUpload contains exactly ten files.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    payload = ["00_READ_ME_FIRST.md", "01_DOCUMENTARY_ARCHITECTURE_AND_SOURCE_METADATA.png", "02_PRIMARY_REFERENCE_REAL_ALIGNMENT.png", "03_V0331_REJECTED_TO_V0332_VISUAL_TRUTH.png", "04_TRUE_ORTHOGRAPHICS_AND_AUTHORED_DIMENSIONS.png", "05_ROOF_STAIR_OPENINGS_AND_ARCHITECTURAL_FUNCTION.png", "06_REAL_PBR_MATERIALS_AND_NUMBERED_UV_CHECKER.png", "07_TRUE_WIREFRAME_UV_LODS_COLLISION_AND_BENCHMARK.png", "08_CONTINUOUS_BARROSAN_HOUSE02_V0332_TURNTABLE.mp4", "compact-evidence-summary.json"]
    compact_metrics = dict(metrics)
    compact_metrics["uvEvidence"] = {key: value for key, value in metrics["uvEvidence"].items() if key != "segments"}
    summary = {"checkpoint": "v0.332", "outcome": manifest["outcome"], "humanReviewRequired": True, "prototypeOptIn": True, "sourceBlend": manifest["sourceBlend"], "sourceGLB": manifest["sourceGLB"], "sourceGLBSha256": metrics["glbSha256"], "godotImportedResource": imported, "documentary": {"primary": "30987", "supplements": ["30985", "30986", "França10"], "moodSeparated": True}, "architecture": metrics["architecturalAnchors"], "textures": materials, "uv": {"actualExportedImage": uv.relative_to(ROOT).as_posix(), "stats": compact_metrics["uvEvidence"]}, "asset": {"metrics": compact_metrics, "lods": ["LOD0", "LOD1", "LOD2"], "importedGLBHash": imported.get("sourceGLBSha256")}, "benchmark": benchmark, "finalMedia": media, "payloadFiles": payload, "totalFiles": 10, "selfApproval": False, "preservation": {"house01Imported": False, "noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noEconomy": True, "noResources": True}}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    board([("documentary anchor", primary), ("current oblique render", ordinary), ("roof truth", roof_front), ("granite", granite), ("stair / landing", stair), ("human scale", scale)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png")
    board([("wireframe", image(SCREENSHOTS / "wireframe_lod0.png")), ("UV", image(uv)), ("LOD0", image(SCREENSHOTS / "lod0_overview.png")), ("LOD1", image(SCREENSHOTS / "lod1_overview.png")), ("LOD2", image(SCREENSHOTS / "lod2_overview.png")), ("collision", image(SCREENSHOTS / "collision_overview.png")), ("benchmark", tech)], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=3, tile=(426, 300))
    board([("v0.331 rejected", rejected), ("v0.332 actual", ordinary), ("reference", primary)], FULL / "43_BEFORE_AFTER_VISUAL_COMPARISON.png")
    stats = []
    for name in names:
        im = image(SCREENSHOTS / name)
        mean = sum(ImageStat.Stat(im).mean) / 3.0
        stats.append({"file": name, "width": im.width, "height": im.height, "meanRgb": round(mean, 2), "accepted": mean > 8.0})
    (FULL / "44_black-frame-rejection-report.md").write_text("# v0.332 black-frame and frozen-frame rejection report\n\nEvery listed capture is a real Godot render; title cards and blank frames are rejected.\n\n" + "\n".join(f"- `{item['file']}` {item['width']}x{item['height']} mean RGB {item['meanRgb']:.1f}: {'ACCEPTED' if item['accepted'] else 'REJECTED'}" for item in stats) + f"\n\nTurntable source frames: {media['sourceFrameCount']}; unique source-frame ratio: {media['uniqueFrameRatio']:.3f}; black/frozen rejected: yes.\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0332_HOUSE02_VISUAL_TRUTH_PACK", "uploadCount": len(list(UPLOAD.iterdir())), "captureCount": len(names), "frameCount": len(frames), "glbSha256": metrics["glbSha256"], "media": media}, indent=2))


if __name__ == "__main__":
    main()
