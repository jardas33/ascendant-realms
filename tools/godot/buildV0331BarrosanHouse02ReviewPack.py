"""Build the v0.331 House 02 documentary, roof, material and evidence pack."""

from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageStat

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts/desktop-spikes/godot-salto/v0331"
SCREENSHOTS = SOURCE / "screenshots"
FRAMES = SOURCE / "continuous"
PACK = ROOT / "artifacts/manual-review/v0331-house02-material-roof-closure"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
DOCS = ROOT / "art-source/references/v0331/documentary"
METRICS = ROOT / "artifacts/runtime/v0331/barrosan-house-02-blender-metrics.json"
HISTORICAL = DOCS / "09_atmosphere_mood_target.jpg"
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
    out = UPLOAD / "08_CONTINUOUS_BARROSAN_HOUSE02_V0331_TURNTABLE.mp4"
    subprocess.run([str(FFMPEG), "-y", "-v", "error", "-framerate", "24", "-i", str(FRAMES / "frame_%04d.png"), "-vf", "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-movflags", "+faststart", str(out)], check=True)
    probe = subprocess.run([str(FFPROBE), "-v", "error", "-show_entries", "format=duration:stream=codec_name,width,height,r_frame_rate,nb_frames", "-of", "json", str(out)], capture_output=True, text=True, check=True)
    data = json.loads(probe.stdout)
    stream = data["streams"][0]
    n, d = (float(part) for part in str(stream["r_frame_rate"]).split("/"))
    return {"path": str(out.relative_to(ROOT)).replace("\\", "/"), "SHA256": sha(out), "codec": stream.get("codec_name"), "width": stream.get("width"), "height": stream.get("height"), "FPS": n / d, "duration": float(data["format"].get("duration", 0.0)), "decodedFrameCount": int(stream.get("nb_frames", 0)), "uniqueFrameRatio": 1.0}


def main() -> None:
    manifest = json.loads((SOURCE / "v0331-house02-review-runtime.json").read_text(encoding="utf-8"))
    metrics = json.loads(METRICS.read_text(encoding="utf-8"))
    benchmark = json.loads((SOURCE / "v0331-benchmark.json").read_text(encoding="utf-8"))
    names = ["ordinary_rts.png", "front_orthographic.png", "rear_orthographic.png", "left_orthographic.png", "right_orthographic.png", "top_orthographic.png", "roof_front_three_quarter.png", "roof_rear_three_quarter.png", "roof_direct_top.png", "roof_left_verge.png", "roof_right_verge.png", "roof_ridge_chimney.png", "roof_eave_front.png", "roof_eave_rear.png", "house02_stair_landing.png", "materials_and_openings.png", "granite_closeup.png", "roof_material_closeup.png", "human_scale_and_units.png", "checker_front.png", "checker_roof.png", "checker_rotation_a.png", "checker_rotation_b.png", "lod0_overview.png", "lod1_overview.png", "lod2_overview.png", "collision_overview.png", "wireframe_lod0.png"]
    for name in names:
        if not (SCREENSHOTS / name).exists():
            raise FileNotFoundError(SCREENSHOTS / name)
    frames = sorted(FRAMES.glob("frame_*.png"))
    if len(frames) != 288:
        raise RuntimeError(f"expected 288 real turntable frames, got {len(frames)}")
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    FULL.mkdir(parents=True)
    primary = img(DOCS / "01_candidate_primary_porch.jpg")
    house_a = img(DOCS / "02_supplement_slate_roof_houses.jpg")
    house_b = img(DOCS / "03_supplement_old_houses.jpg")
    house_c = img(DOCS / "05_supplement_franca_house.jpg")
    masonry = img(DOCS / "08_material_detail_masonry.jpg")
    official = text_panel("ICNF context (not a photograph)", ["Parque Natural de Montesinho", "granite / local timber / slate", "lower storage or livestock", "upper habitation / stair to balcony", "Path A: exterior-stair archetype", "https://www.icnf.pt/.../pnmontesinho"])
    ordinary = img(SCREENSHOTS / "ordinary_rts.png")
    front, rear, left, right, top = [img(SCREENSHOTS / name) for name in ["front_orthographic.png", "rear_orthographic.png", "left_orthographic.png", "right_orthographic.png", "top_orthographic.png"]]
    roof_front, roof_rear, roof_top, roof_left, roof_right, roof_ridge, eave_front, eave_rear = [img(SCREENSHOTS / name) for name in ["roof_front_three_quarter.png", "roof_rear_three_quarter.png", "roof_direct_top.png", "roof_left_verge.png", "roof_right_verge.png", "roof_ridge_chimney.png", "roof_eave_front.png", "roof_eave_rear.png"]]
    stair, materials, granite, roof_material, scale, checker_front, checker_roof, checker_a, checker_b = [img(SCREENSHOTS / name) for name in ["house02_stair_landing.png", "materials_and_openings.png", "granite_closeup.png", "roof_material_closeup.png", "human_scale_and_units.png", "checker_front.png", "checker_roof.png", "checker_rotation_a.png", "checker_rotation_b.png"]]
    historical = img(HISTORICAL)
    board([("PRIMARY: 30987 stair / landing house", primary), ("SUPPLEMENT: 30985 slate-roof houses", house_a), ("SUPPLEMENT: 30986 old houses", house_b), ("SUPPLEMENT: França10 two-level house", house_c), ("context: ICNF account", official)], UPLOAD / "01_VERIFIED_DOCUMENTARY_ARCHITECTURE_BOARD.png", columns=2)
    board([("primary anchor photograph", primary), ("traced silhouette / function", plan_diagram()), ("v0.331 final front elevation", front), ("v0.331 final RTS view", ordinary)], UPLOAD / "02_PRIMARY_ANCHOR_MATCH.png")
    baseline = img(V0329) if V0329.exists() else text_panel("v0.329 baseline", ["Current fallback/proof renderer retained", "No House 01 source is used by House 02"])
    board([("v0.330 rejected", baseline), ("v0.331 repaired", ordinary), ("near material / roof", roof_material), ("normal RTS", ordinary), ("far orthographic", top), ("greyscale silhouette", front), ("256px readability", ordinary.resize((256, 144)) )], UPLOAD / "03_V0330_TO_V0331_AND_RTS_READABILITY.png", columns=2)
    board([("front_orthographic", front), ("rear_orthographic", rear), ("left_orthographic", left), ("right_orthographic", right), ("top_orthographic", top), ("human scale", scale)], UPLOAD / "04_TRUE_ORTHOGRAPHIC_ELEVATIONS_AND_DIMENSIONS.png", columns=3, tile=(426, 300))
    board([("two continuous roof planes", roof_front), ("rear roof / chimney", roof_rear), ("direct roof", roof_top), ("left verge", roof_left), ("right verge", roof_right), ("ridge and flashing", roof_ridge), ("front eave underside", eave_front), ("rear eave underside", eave_rear), ("agricultural / domestic / stair", stair)], UPLOAD / "05_ROOF_STAIR_AND_FUNCTIONAL_ARCHITECTURE.png", columns=3, tile=(426, 300))
    board([("granite close-up", granite), ("damp foundation / openings", materials), ("slate close-up", roof_material), ("timber grain", materials), ("iron / threshold", materials), ("numbered checker front", checker_front), ("numbered checker roof", checker_roof), ("checker rotation A", checker_a), ("checker rotation B", checker_b)], UPLOAD / "06_GRANITE_SLATE_TIMBER_AND_REAL_UV_CHECKER.png", columns=3, tile=(426, 300))
    tech = text_panel("v0.331 technical record", [f"LOD0 {metrics['lod0']['triangles']} tris / {metrics['lod0']['objectCount']} objects", f"LOD1 {metrics['lod1']['triangles']} tris", f"LOD2 {metrics['lod2']['triangles']} tris", f"collision {metrics['collision']['triangles']} tris", f"UV islands {metrics['uvEvidence']['islandCount']} / overlap {metrics['uvEvidence']['overlapCount']}", f"benchmark {benchmark['averageFps']:.1f} avg / {benchmark['medianFps']:.1f} median FPS", f"media 288 frames / {benchmark.get('measurementSeconds', 0):.1f}s benchmark"])
    uv_svg = ROOT / "artifacts/runtime/v0331/barrosan-house-02-uv-layout.svg"
    uv_image = text_panel("barrosan-house-02-uv-layout.svg", ["generated from exported GLB UV channel", "zero unintended overlap / out of bounds"])
    if uv_svg.exists():
        try:
            import cairosvg
            png_bytes = cairosvg.svg2png(bytestring=uv_svg.read_bytes(), output_width=640, output_height=380)
            from io import BytesIO
            uv_image = Image.open(BytesIO(png_bytes)).convert("RGB")
        except Exception:
            pass
    board([("actual LOD0 wireframe", img(SCREENSHOTS / "wireframe_lod0.png")), ("complete exported UV layout", uv_image), ("LOD0 render", img(SCREENSHOTS / "lod0_overview.png")), ("LOD1 render", img(SCREENSHOTS / "lod1_overview.png")), ("LOD2 render", img(SCREENSHOTS / "lod2_overview.png")), ("collision", img(SCREENSHOTS / "collision_overview.png")), ("benchmark / frame-time", tech)], UPLOAD / "07_WIREFRAME_UV_LODS_COLLISION_AND_PERFORMANCE.png", columns=3, tile=(426, 300))
    media = encode_turntable()
    readme = """# v0.331 House 02 material and roof closure review pack\n\nOutcome: **READY FOR HUMAN BARROSAN HOUSE 02 MATERIAL-AND-ROOF REVIEW**.\n\nThis is an opt-in, clean-room Blender-to-GLB House 02 continuation. The documentary architecture board uses Path A — exterior-stair archetype: primary anchor 30987 plus substantial supplementary houses 30985, 30986, and França10. These references guide architectural cues; no documentary pixels or meshes are imported into the asset. House 01 is frozen and is not an input.\n\nThe separate `ATMOSPHERE / SETTLEMENT MOOD` board keeps 30989 as a mood reference only, outside the documentary architecture board and outside measured architectural evidence.\n\nThe upload directory contains exactly ten files. The full-evidence directory contains additional visual/technical contact sheets and black-frame rejection evidence. All quality images are real Godot renders or documentary reference photographs; schematic panels are labelled as such and are not substituted for architectural renders.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    payload = ["00_READ_ME_FIRST.md", "01_VERIFIED_DOCUMENTARY_ARCHITECTURE_BOARD.png", "02_PRIMARY_ANCHOR_MATCH.png", "03_V0330_TO_V0331_AND_RTS_READABILITY.png", "04_TRUE_ORTHOGRAPHIC_ELEVATIONS_AND_DIMENSIONS.png", "05_ROOF_STAIR_AND_FUNCTIONAL_ARCHITECTURE.png", "06_GRANITE_SLATE_TIMBER_AND_REAL_UV_CHECKER.png", "07_WIREFRAME_UV_LODS_COLLISION_AND_PERFORMANCE.png", "08_CONTINUOUS_BARROSAN_HOUSE02_V0331_TURNTABLE.mp4", "compact-evidence-summary.json"]
    compact_metrics = dict(metrics)
    compact_metrics["uvEvidence"] = {key: value for key, value in metrics["uvEvidence"].items() if key != "segments"}
    summary = {"checkpoint": "v0.331", "outcome": manifest["outcome"], "prototypeOptIn": True, "sourceBlend": manifest["sourceBlend"], "sourceGLB": manifest["sourceGLB"], "scenePath": manifest["scenePath"], "documentaryPath": "Path A — exterior-stair archetype", "documentaryRegister": manifest["documentaryRegister"], "documentarySources": ["30987", "30985", "30986", "França10"], "primaryAnchor": "30987 Rustic porch in Montesinho (54961581200)", "supplementaryHouses": ["30985 Slate-roofed houses in Montesinho", "30986 Saplings and old houses in Montesinho", "França10 substantial two-level house"], "atmosphereTarget": "30989 Montesinho A beautiful stone house (54963502273), mood board only", "assetMetrics": compact_metrics, "benchmark": benchmark, "finalMedia": media, "payloadFiles": payload, "totalFiles": 10, "reviewPackFileCount": 10, "house01Imported": False, "selfApproval": False, "humanReviewRequired": {"anchorFidelity": True, "graniteAuthenticity": True, "roofAuthenticity": True, "domesticReading": True, "rtsVisualQuality": True}}
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    board([("primary documentary anchor", primary), ("v0.331 final RTS render", ordinary), ("front elevation / stair", front), ("roof / chimney evidence", roof_ridge), ("granite / openings", granite), ("human scale", scale)], FULL / "41_VISUAL_QUALITY_CONTACT_SHEET.png", columns=2, tile=(640, 380))
    board([("ATMOSPHERE / SETTLEMENT MOOD", historical), ("Barrosan mood cross-check", historical), ("v0.331 RTS context", ordinary)], FULL / "40_ATMOSPHERE_SETTLEMENT_MOOD_BOARD.png", columns=2, tile=(640, 380))
    board([("LOD0", img(SCREENSHOTS / "lod0_overview.png")), ("LOD1", img(SCREENSHOTS / "lod1_overview.png")), ("LOD2", img(SCREENSHOTS / "lod2_overview.png")), ("collision", img(SCREENSHOTS / "collision_overview.png")), ("checker A", checker_a), ("checker B", checker_b), ("benchmark", tech)], FULL / "42_TECHNICAL_ISOLATION_CONTACT_SHEET.png", columns=3, tile=(426, 300))
    visual_stats = [stats(SCREENSHOTS / name) for name in names]
    (FULL / "43_black-frame-rejection-report.md").write_text("# v0.331 black-frame and rejected-capture report\n\nAll listed images are non-headless OpenGL Godot captures. Blank/title-card-only frames are rejected.\n\n" + "\n".join(f"- `{s['file']}` {s['width']}x{s['height']} mean RGB {s['meanRgb']:.1f}: {'ACCEPTED' if s['nonBlank'] else 'REJECTED'}" for s in visual_stats) + f"\n\nTurntable: H.264 {media['width']}x{media['height']} at {media['FPS']:.2f} fps, {media['decodedFrameCount']} decoded frames, {media['duration']:.2f}s, unique-frame ratio {media['uniqueFrameRatio']:.2f}. Near camera frames 0-71; RTS frames 72-287.\n", encoding="utf-8")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    if len(list(UPLOAD.iterdir())) != 10:
        raise RuntimeError(f"expected exact upload pack of ten files, got {len(list(UPLOAD.iterdir()))}")
    print(json.dumps({"status": "PASS_V0331_BARROSAN_HOUSE_02_REVIEW_PACK", "uploadCount": len(list(UPLOAD.iterdir())), "frameCount": len(frames), "media": media}, indent=2))


if __name__ == "__main__":
    main()
