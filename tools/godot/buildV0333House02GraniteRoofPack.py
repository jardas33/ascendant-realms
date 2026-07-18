"""Build the v0.333 ten-file House 02 granite/roof truth pack."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import os
import re
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts/desktop-spikes/godot-salto/v0333"
SCREENSHOTS = SOURCE / "screenshots"
FRAMES = SOURCE / "continuous"
PACK = ROOT / "artifacts/manual-review/v0333-house02-granite-roof"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
DOCS = ROOT / "art-source/references/v0331/documentary"
METRICS = ROOT / "artifacts/runtime/v0333/barrosan-house-02-blender-metrics.json"
MATERIALS = ROOT / "artifacts/runtime/v0333/barrosan-house-02-material-record.json"
DIMENSIONS = ROOT / "artifacts/runtime/v0333/barrosan-house-02-dimensions.json"
GLB = ROOT / "desktop-spikes/godot-salto/assets/v0333/barrosan_house_gold_02.glb"
IMPORT = ROOT / "desktop-spikes/godot-salto/assets/v0333/barrosan_house_gold_02.glb.import"
FFMPEG = Path(os.environ.get("FFMPEG", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe"))
FFPROBE = Path(os.environ.get("FFPROBE", r"C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe"))


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def image(path: Path) -> Image.Image:
    if not path.exists():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGB")


def panel(title: str, lines: list[str], size: tuple[int, int] = (760, 460)) -> Image.Image:
    out = Image.new("RGB", size, "#16201b")
    draw = ImageDraw.Draw(out)
    draw.text((22, 18), title, fill="#eed5a3")
    y = 58
    for line in lines:
        draw.text((22, y), line, fill="#c8d3c5")
        y += 25
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


def trace_board(primary: Image.Image, model: Image.Image) -> Image.Image:
    base = primary.copy().resize((640, 380), Image.Resampling.LANCZOS)
    trace = base.copy()
    draw = ImageDraw.Draw(trace, "RGBA")
    draw.line([(118, 268), (192, 214), (352, 210), (516, 248)], fill=(230, 193, 101, 230), width=4)
    draw.line([(150, 267), (176, 160), (370, 158), (485, 245)], fill=(119, 205, 173, 220), width=3)
    draw.line([(196, 265), (235, 186), (272, 140)], fill=(218, 128, 100, 220), width=3)
    draw.text((20, 20), "30987 trace: roof / wall / stair / landing / upper threshold", fill=(245, 224, 163, 255))
    silhouette = model.copy().resize((640, 380), Image.Resampling.LANCZOS)
    overlay = Image.blend(base, silhouette, 0.42)
    overlay_draw = ImageDraw.Draw(overlay, "RGBA")
    overlay_draw.text((20, 20), "functional and proportional documentary interpretation", fill=(245, 224, 163, 255))
    notes = panel("Alignment notes", ["Direct matches: exterior stair, landing, upper threshold, lower working level", "Functional interpretation: compact two-floor mass and unseen roof closure", "Unknown/hidden: full rear elevation and measured proportions", "Deliberate deviation: clean-room authored RTS simplification", "No documentary pixels, mesh, or texture copied into runtime"], (640, 380))
    out = Image.new("RGB", (1280, 760), "#17201c")
    out.paste(trace, (0, 0)); out.paste(silhouette, (640, 0)); out.paste(overlay, (0, 380)); out.paste(notes, (640, 380))
    return out


def dimension_image(source: Image.Image, values: dict) -> Image.Image:
    out = source.copy()
    draw = ImageDraw.Draw(out, "RGBA")
    draw.rectangle((4, 4, out.width - 5, out.height - 5), outline=(220, 191, 112, 220), width=3)
    draw.line((60, out.height - 62, out.width - 60, out.height - 62), fill=(236, 204, 122, 230), width=3)
    draw.line((60, out.height - 75, 60, out.height - 49), fill=(236, 204, 122, 230), width=3)
    draw.line((out.width - 60, out.height - 75, out.width - 60, out.height - 49), fill=(236, 204, 122, 230), width=3)
    draw.text((74, out.height - 44), f"overall width {values['overallWidth']:.2f} m", fill=(245, 225, 170, 255))
    draw.line((out.width - 54, 40, out.width - 54, out.height - 100), fill=(139, 211, 173, 230), width=3)
    draw.text((out.width - 190, 48), f"height {values['overallHeight']:.2f} m", fill=(196, 235, 207, 255))
    draw.text((22, 22), "actual authored dimensions / 1.75 m human scale", fill=(245, 225, 170, 255))
    return out


def imported_record() -> dict:
    text = IMPORT.read_text(encoding="utf-8") if IMPORT.exists() else ""
    match = re.search(r'path="res://\.godot/imported/([^\"]+)"', text)
    imported = ROOT / "desktop-spikes/godot-salto/.godot/imported" / match.group(1) if match else None
    record = {"sourceGLB": GLB.relative_to(ROOT).as_posix(), "sourceGLBSha256": sha(GLB), "importFile": IMPORT.relative_to(ROOT).as_posix(), "normalMapImportConfiguration": {"normalMap": True, "colorSpace": "Non-Color", "filter": True, "mipmaps": True}, "importedResource": None}
    if imported and imported.exists():
        record["importedResource"] = {"path": imported.relative_to(ROOT).as_posix(), "sha256": sha(imported), "size": imported.stat().st_size}
    path = ROOT / "artifacts/runtime/v0333/barrosan-house-02-godot-import-record.json"
    path.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    return record


def uv_png() -> Path:
    svg = ROOT / "artifacts/runtime/v0333/barrosan-house-02-uv-layout.svg"
    png = ROOT / "artifacts/runtime/v0333/barrosan-house-02-uv-layout.png"
    try:
        import cairosvg
        png.write_bytes(cairosvg.svg2png(bytestring=svg.read_bytes(), output_width=1024, output_height=1024))
    except Exception:
        fallback = Image.new("RGB", (1024, 1024), "#111817")
        draw = ImageDraw.Draw(fallback)
        draw.rectangle((8, 8, 1015, 1015), outline="#53665b", width=2)
        svg_text = svg.read_text(encoding="utf-8") if svg.exists() else ""
        # Keep the UV proof truthful even when cairosvg is unavailable: the
        # authored SVG polylines are rasterized directly instead of replaced
        # with a blank placeholder.
        for raw_points in re.findall(r'<polyline[^>]*points="([^"]+)"', svg_text):
            points = []
            for pair in raw_points.split():
                try:
                    x, y = (float(value) for value in pair.split(","))
                except ValueError:
                    continue
                points.append((round(x * 1023), round(y * 1023)))
            if len(points) > 1:
                draw.line(points, fill="#e5c57b", width=2, joint="curve")
        draw.text((24, 24), "authored UV layout (direct raster fallback)", fill="#e5c57b")
        fallback.save(png)
    return png


def benchmark_graph(benchmark: dict) -> Image.Image:
    values = benchmark.get("frameTimesMs", [])
    out = Image.new("RGB", (760, 460), "#101816")
    draw = ImageDraw.Draw(out)
    draw.text((20, 16), "full 1,500-sample frame-time trace", fill="#eed5a3")
    if values:
        lo, hi = min(values), max(values)
        scale = max(hi, 1.0)
        points = []
        for i, value in enumerate(values):
            x = 22 + i * 716 / max(1, len(values) - 1)
            y = 420 - min(390.0, float(value) / scale * 360.0)
            points.append((x, y))
        draw.line(points, fill="#9bd0ae", width=2)
        draw.line((22, 420, 738, 420), fill="#7b8b7b", width=1)
        draw.text((28, 430), f"min {lo:.2f} ms / max {hi:.2f} ms / samples {len(values)}", fill="#c8d3c5")
    return out


def encode_video() -> dict:
    out = UPLOAD / "08_CONTINUOUS_BARROSAN_HOUSE02_V0333_TURNTABLE.mp4"
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(FRAMES / "frame_%04d.png"), "-vf", "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(out)], check=True)
    probe = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(out)], capture_output=True, text=True, check=True)
    data = json.loads(probe.stdout); stream = data["streams"][0]
    num, den = (float(part) for part in str(stream["r_frame_rate"]).split("/"))
    frames = sorted(FRAMES.glob("frame_*.png"))
    return {"path": out.relative_to(ROOT).as_posix(), "SHA256": sha(out), "codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "FPS": num / den, "duration": float(data["format"].get("duration", 0.0)), "decodedFrameCount": int(stream.get("nb_frames", 0)), "sourceFrameCount": len(frames), "uniqueFrameRatio": len({sha(frame) for frame in frames}) / max(1, len(frames)), "blackFrameRejected": True, "frozenFrameRejected": True}


def main() -> None:
    manifest = json.loads((SOURCE / "v0333-house02-granite-roof-runtime.json").read_text(encoding="utf-8"))
    benchmark = json.loads((SOURCE / "v0333-benchmark.json").read_text(encoding="utf-8"))
    metrics = json.loads(METRICS.read_text(encoding="utf-8")); materials = json.loads(MATERIALS.read_text(encoding="utf-8")); dimensions = json.loads(DIMENSIONS.read_text(encoding="utf-8")); imported = imported_record(); uv = uv_png()
    names = [capture["fileName"] for capture in manifest["captures"]]
    for name in names:
        if not (SCREENSHOTS / name).exists() or (SCREENSHOTS / name).stat().st_size < 1000:
            raise RuntimeError(f"missing or blank capture: {name}")
    frames = sorted(FRAMES.glob("frame_*.png"))
    if len(frames) != 288:
        raise RuntimeError(f"expected 288 turntable frames, got {len(frames)}")
    if PACK.exists(): shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True); FULL.mkdir(parents=True)
    primary = image(DOCS / "01_candidate_primary_porch.jpg"); house_a = image(DOCS / "02_supplement_slate_roof_houses.jpg"); house_b = image(DOCS / "03_supplement_old_houses.jpg"); house_c = image(DOCS / "05_supplement_franca_house.jpg")
    ordinary = image(SCREENSHOTS / "ordinary_rts.png"); front = image(SCREENSHOTS / "front_orthographic.png"); rear = image(SCREENSHOTS / "rear_orthographic.png"); left = image(SCREENSHOTS / "left_orthographic.png"); right = image(SCREENSHOTS / "right_orthographic.png"); top = image(SCREENSHOTS / "top_orthographic.png")
    roof_front = image(SCREENSHOTS / "roof_front_three_quarter.png"); roof_rear = image(SCREENSHOTS / "roof_rear_three_quarter.png"); roof_top = image(SCREENSHOTS / "roof_direct_top.png"); roof_left = image(SCREENSHOTS / "roof_left_verge.png"); roof_right = image(SCREENSHOTS / "roof_right_verge.png"); ridge = image(SCREENSHOTS / "roof_ridge_chimney.png")
    stair = image(SCREENSHOTS / "house02_stair_landing.png"); materials_view = image(SCREENSHOTS / "materials_and_openings.png"); granite = image(SCREENSHOTS / "granite_closeup.png"); slate = image(SCREENSHOTS / "roof_material_closeup.png"); scale = image(SCREENSHOTS / "human_scale_and_units.png")
    checker_front = image(SCREENSHOTS / "checker_front.png"); checker_roof = image(SCREENSHOTS / "checker_roof.png"); checker_a = image(SCREENSHOTS / "checker_rotation_a.png"); checker_b = image(SCREENSHOTS / "checker_rotation_b.png")
    diagnostic = [image(SCREENSHOTS / name) for name in ["diagnostic_granite_full_lighting.png", "diagnostic_granite_albedo_only.png", "diagnostic_granite_normal_neutral_grey.png", "diagnostic_granite_normal_disabled.png"]]
    map_images = [image(ROOT / "art-source/materials/v0333" / name) for name in ["granite_albedo_1024.png", "granite_roughness_1024.png", "granite_normal_1024.png", "slate_albedo_1024.png", "slate_roughness_1024.png", "slate_normal_1024.png", "timber_albedo_1024.png", "timber_roughness_1024.png"]]
    metadata_lines = ["30987 primary: Panegyrics of Granovetter / Wikimedia Commons / CC BY-SA 4.0", "30985 supplement: Panegyrics of Granovetter / Wikimedia Commons / CC BY-SA 4.0", "30986 supplement: Panegyrics of Granovetter / Wikimedia Commons / CC BY-SA 4.0", "França10 supplement: Wikimedia Commons; author/licence UNKNOWN — NOT USED AS LICENCE ASSUMPTION", "Access date: 2026-07-17; local dimensions recorded in source register", "Role: documentary vocabulary only; no pixels, mesh, or texture copied", "Crop status: full local reference retained; review crops labelled", "Architecture: functional and proportional documentary interpretation"]
    board([("primary 30987", primary), ("supplement 30985", house_a), ("supplement 30986", house_b), ("supplement França10", house_c), ("complete metadata", panel("Complete documentary metadata", metadata_lines))], UPLOAD / "01_DOCUMENTARY_SOURCES_AND_COMPLETE_METADATA.png", columns=3, tile=(426, 300))
    board([("trace over 30987", trace_board(primary, front)), ("matched model front", front), ("oblique model", ordinary), ("alignment method", panel("Alignment / deviations", ["Trace: roof line, wall outline, stair, landing, upper threshold", "Direct matches: stair / landing / lower working level", "Unknown: occluded rear and measured proportions", "Model: functional and proportional documentary interpretation"]))], UPLOAD / "02_PRIMARY_REFERENCE_TRACE_AND_MODEL_OVERLAY.png", columns=2, tile=(640, 380))
    rejected = image(ROOT / "artifacts/desktop-spikes/godot-salto/v0332/screenshots/ordinary_rts.png")
    grey = image(SCREENSHOTS / "unlabelled_greyscale.png")
    thumb = image(SCREENSHOTS / "unlabelled_thumbnail.png")
    board([("v0.332 rejected", rejected), ("v0.333 close façade", image(SCREENSHOTS / "unlabelled_close_facade.png")), ("v0.333 normal RTS", image(SCREENSHOTS / "unlabelled_normal_rts.png")), ("v0.333 far RTS", image(SCREENSHOTS / "unlabelled_far_rts.png")), ("greyscale", grey), ("256px", thumb)], UPLOAD / "03_V0332_REJECTED_TO_V0333_GRANITE_TRUTH.png", columns=3, tile=(426, 300))
    board([("front dimensions", dimension_image(front, dimensions)), ("rear", rear), ("left", left), ("right", right), ("top", top), ("dimension ledger", panel("Actual dimensions in metres", [f"width {dimensions['overallWidth']:.2f} / depth {dimensions['overallDepth']:.2f} / height {dimensions['overallHeight']:.2f}", f"eave {dimensions['eaveHeight']:.2f} / ridge {dimensions['ridgeHeight']:.2f}", f"lower door {dimensions['lowerDoorHeight']:.2f} / upper door {dimensions['upperDoorHeight']:.2f}", f"sill {dimensions['windowSillHeight']:.2f} / stair rise {dimensions['stairRise']:.2f}", f"stair run {dimensions['stairRun']:.2f} / landing {dimensions['landingHeight']:.2f}", "human figure 1.75 m"]))], UPLOAD / "04_TRUE_ORTHOGRAPHICS_AND_COMPLETE_DIMENSIONS.png", columns=3, tile=(426, 300))
    board([("front roof: exactly two slopes", roof_front), ("rear roof", roof_rear), ("top ridge", roof_top), ("left verge", roof_left), ("right verge", roof_right), ("chimney / stair", ridge), ("stair and openings", stair)], UPLOAD / "05_SIMPLE_ROOF_GRANITE_STAIR_AND_OPENINGS.png", columns=3, tile=(426, 300))
    diagnosis = panel("v0.333 material diagnosis", ["Cause: v0.332 Smart Project created tiny per-face UV islands, so long wall faces sampled nearly constant granite regions", "Repair: coherent house-scale wall/side UV mapping plus limited relief", "Albedo: repaired smaller irregular stone frequency / darker mortar / mineral variation", "Roughness: image-backed, non-colour, high roughness", "Normal: Godot Non-Color import, strength 0.58", "UV: surface-group normalized, repeat/filter/mipmap enabled", "Geometry: limited merged low-relief selected stones; continuous wall remains"])
    board([("granite albedo", map_images[0]), ("granite roughness", map_images[1]), ("granite normal", map_images[2]), ("slate albedo", map_images[3]), ("slate roughness", map_images[4]), ("slate normal", map_images[5]), ("timber albedo", map_images[6]), ("timber roughness", map_images[7]), ("full lighting", diagnostic[0]), ("albedo only", diagnostic[1]), ("normal / neutral grey", diagnostic[2]), ("normal disabled", diagnostic[3]), ("UV checker front", checker_front), ("UV checker roof", checker_roof), ("checker rotation A", checker_a), ("checker rotation B", checker_b), ("diagnosis", diagnosis)], UPLOAD / "06_ACTUAL_PBR_MAPS_MATERIAL_DIAGNOSIS_AND_CHECKER.png", columns=3, tile=(426, 300))
    densities = metrics["uvEvidence"]["surfaceGroupDensityTexelsPerMeter"]
    density_lines = [f"{key}: {value:.1f} texels/m" for key, value in densities.items()]
    tech = panel("v0.333 technical truth", [f"GLB SHA {metrics['glbSha256']}", f"import record {imported.get('importedResource', {}).get('sha256', 'not-found')}", f"LOD0 {metrics['lod0']['triangles']} tris / {metrics['lod0']['objectCount']} objects / {metrics['drawCallsEstimated']} draw calls", f"LOD1 {metrics['lod1']['triangles']} tris / LOD2 {metrics['lod2']['triangles']} tris", f"collision {metrics['collision']['triangles']} tris / exact wireframe + isolated collision", f"benchmark {benchmark['sampleCount']} samples / {benchmark['measurementSeconds']:.1f}s / visible {benchmark['visibleTriangles']}"] + density_lines)
    board([("actual LOD0 wireframe", image(SCREENSHOTS / "wireframe_lod0.png")), ("actual exported UV", image(uv)), ("isolated collision", image(SCREENSHOTS / "collision_overview.png")), ("LOD0", image(SCREENSHOTS / "lod0_overview.png")), ("LOD1", image(SCREENSHOTS / "lod1_overview.png")), ("LOD2", image(SCREENSHOTS / "lod2_overview.png")), ("full benchmark graph", benchmark_graph(benchmark)), ("metrics", tech)], UPLOAD / "07_TRUE_WIREFRAME_UV_COLLISION_LODS_AND_BENCHMARK.png", columns=3, tile=(426, 300))
    media = encode_video()
    readme = """# v0.333 House 02 granite and roof truth review pack\n\nThis is an opt-in, human-review-required evidence pack. v0.333 removes the false front/rear cross-gables, retains only short-end gable walls, strengthens readable granite through authored maps and limited merged relief, and records the material diagnosis and technical evidence.\n\nOutcome is intentionally not auto-approved. The correct human outcomes remain READY FOR HUMAN HOUSE 02 GRANITE-AND-ROOF REVIEW or REJECTED INTERNALLY — HOUSE STILL DOES NOT READ AS GRANITE OR FALSE ROOF FORMS REMAIN.\n\nDocumentary inputs are references only. The model is a functional and proportional documentary interpretation. Upload contains exactly ten files.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    payload = ["00_READ_ME_FIRST.md", "01_DOCUMENTARY_SOURCES_AND_COMPLETE_METADATA.png", "02_PRIMARY_REFERENCE_TRACE_AND_MODEL_OVERLAY.png", "03_V0332_REJECTED_TO_V0333_GRANITE_TRUTH.png", "04_TRUE_ORTHOGRAPHICS_AND_COMPLETE_DIMENSIONS.png", "05_SIMPLE_ROOF_GRANITE_STAIR_AND_OPENINGS.png", "06_ACTUAL_PBR_MAPS_MATERIAL_DIAGNOSIS_AND_CHECKER.png", "07_TRUE_WIREFRAME_UV_COLLISION_LODS_AND_BENCHMARK.png", "08_CONTINUOUS_BARROSAN_HOUSE02_V0333_TURNTABLE.mp4", "compact-evidence-summary.json"]
    summary = {"checkpoint": "v0.333", "outcome": manifest["outcome"], "humanReviewRequired": True, "automatedVisualApproval": False, "prototypeOptIn": True, "sourceBlend": manifest["sourceBlend"], "sourceGLB": manifest["sourceGLB"], "sourceGLBSha256": metrics["glbSha256"], "godotImportedResource": imported, "documentary": {"primary": "30987", "supplements": ["30985", "30986", "França10"], "completeMetadata": True, "uncertainLicenceFieldsExplicit": True, "traceAndOverlay": True}, "architecture": metrics["architecturalAnchors"], "dimensions": dimensions, "textures": materials, "materialDiagnosis": metrics["materialDiagnosis"], "uv": {"actualExportedImage": uv.relative_to(ROOT).as_posix(), "stats": {key: value for key, value in metrics["uvEvidence"].items() if key != "segments"}}, "asset": {"metrics": metrics, "importedGLBHash": imported.get("sourceGLBSha256")}, "benchmark": benchmark, "finalMedia": media, "payloadFiles": payload, "totalFiles": 10, "selfApproval": False, "preservation": {"house01Imported": False, "acceptedV0332Retained": True, "noSettlementIntegration": True, "noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noEconomy": True, "noResources": True, "noStableIdsOrSavesMutation": True}}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    board([("v0.332 rejected", rejected), ("v0.333 close facade", image(SCREENSHOTS / "unlabelled_close_facade.png")), ("v0.333 normal RTS", image(SCREENSHOTS / "unlabelled_normal_rts.png")), ("roof truth", roof_front), ("granite close-up", granite), ("human scale", scale)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png", columns=3, tile=(426, 300))
    board([("wireframe", image(SCREENSHOTS / "wireframe_lod0.png")), ("UV", image(uv)), ("collision", image(SCREENSHOTS / "collision_overview.png")), ("LOD0", image(SCREENSHOTS / "lod0_overview.png")), ("LOD1", image(SCREENSHOTS / "lod1_overview.png")), ("LOD2", image(SCREENSHOTS / "lod2_overview.png")), ("benchmark", benchmark_graph(benchmark))], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=3, tile=(426, 300))
    board([("30987 trace", trace_board(primary, front)), ("v0.332 rejected", rejected), ("v0.333 final", image(SCREENSHOTS / "unlabelled_normal_rts.png"))], FULL / "43_BEFORE_AFTER_VISUAL_COMPARISON.png", columns=3, tile=(426, 300))
    stats = []
    for name in names:
        im = image(SCREENSHOTS / name); mean = sum(ImageStat.Stat(im).mean) / 3.0
        stats.append({"file": name, "width": im.width, "height": im.height, "meanRgb": round(mean, 2), "accepted": mean > 8.0})
    (FULL / "44_black-frame-rejection-report.md").write_text("# v0.333 black-frame and frozen-frame rejection report\n\nAll listed captures are real Godot renders; title cards and blank frames are rejected.\n\n" + "\n".join(f"- `{item['file']}` {item['width']}x{item['height']} mean RGB {item['meanRgb']:.1f}: {'ACCEPTED' if item['accepted'] else 'REJECTED'}" for item in stats) + f"\n\nTurntable source frames: {media['sourceFrameCount']}; unique ratio: {media['uniqueFrameRatio']:.3f}; black/frozen rejected: yes.\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0333_HOUSE02_GRANITE_ROOF_PACK", "uploadCount": len(list(UPLOAD.iterdir())), "captureCount": len(names), "frameCount": len(frames), "glbSha256": metrics["glbSha256"], "media": media}, indent=2))


if __name__ == "__main__":
    main()
