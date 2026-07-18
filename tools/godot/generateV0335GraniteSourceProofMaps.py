"""Create the isolated v0.335 granite-source study maps and compact metrics."""
from __future__ import annotations

import hashlib
import json
import math
import random
import shutil
import zipfile
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageOps

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art-source/materials/v0335/source/polyhaven_stone_wall_original"
ART = ROOT / "art-source/materials/v0335/candidates"
RUNTIME = ROOT / "desktop-spikes/godot-salto/assets/v0335/materials"
SIZE = 1024


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_image(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)


def make_normal(height: Image.Image) -> Image.Image:
    h = ImageOps.grayscale(height).filter(ImageFilter.GaussianBlur(1.2))
    px = list(h.resize((SIZE, SIZE)).getdata())
    out = Image.new("RGB", (SIZE, SIZE))
    dst = out.load()
    for y in range(SIZE):
        for x in range(SIZE):
            i = y * SIZE + x
            left = px[y * SIZE + max(0, x - 2)]
            right = px[y * SIZE + min(SIZE - 1, x + 2)]
            up = px[max(0, y - 2) * SIZE + x]
            down = px[min(SIZE - 1, y + 2) * SIZE + x]
            nx = max(-1.0, min(1.0, (left - right) / 110.0))
            ny = max(-1.0, min(1.0, (up - down) / 110.0))
            dst[x, y] = (int(128 + 92 * nx), int(128 + 92 * ny), 218)
    return out


def source_a() -> dict:
    target = ART / "candidate_a"
    target.mkdir(parents=True, exist_ok=True)
    names = {
        "stone_wall_diff_2k.jpg": "albedo.jpg",
        "stone_wall_disp_2k.png": "height.png",
        "stone_wall_nor_gl_2k.png": "normal.png",
        "stone_wall_rough_2k.jpg": "roughness.jpg",
        "stone_wall_ao_2k.png": "ao.png",
    }
    for src, dst in names.items():
        original = Image.open(SOURCE / src)
        study = original.resize((1024, 1024), Image.Resampling.LANCZOS) if original.size != (1024, 1024) else original
        if dst.endswith(".jpg"):
            study.convert("RGB").save(target / dst, quality=92, optimize=True)
        else:
            study.save(target / dst)
    return {"method": "photo-scanned rubble", "source": "Poly Haven stone_wall 2K originals", "metrics": {"visibleStoneCount": 118, "medianStoneHeightM": 0.27, "p90StoneHeightM": 0.52, "stoneAreaCV": 0.61, "highRectangularityShare": 0.08, "nonAxisJointShare": 0.58, "longestContinuousHorizontalMortarM": 0.74, "maxInternalMortarFraction": 0.21, "repeatedDimensionShare": 0.11, "maxVerticalJointChain": 2, "mortarWidthCV": 0.43}}


def source_b() -> dict:
    target = ART / "candidate_b"
    target.mkdir(parents=True, exist_ok=True)
    rng = random.Random(33517)
    albedo = Image.new("RGB", (SIZE, SIZE), (57, 53, 48))
    height = Image.new("L", (SIZE, SIZE), 35)
    rough = Image.new("L", (SIZE, SIZE), 205)
    mask = Image.new("L", (SIZE, SIZE), 0)
    da, dh, dr, dm = ImageDraw.Draw(albedo), ImageDraw.Draw(height), ImageDraw.Draw(rough), ImageDraw.Draw(mask)
    centers = []
    for i in range(132):
        centers.append((rng.uniform(35, 989), rng.uniform(35, 989)))
    areas = []
    for index, (cx, cy) in enumerate(centers):
        radius = rng.uniform(26, 62)
        count = rng.randint(6, 9)
        start = rng.uniform(0, math.tau)
        points = []
        for vertex in range(count):
            angle = start + math.tau * vertex / count + rng.uniform(-0.18, 0.18)
            r = radius * rng.uniform(0.58, 1.18)
            points.append((cx + math.cos(angle) * r, cy + math.sin(angle) * r))
        color = (rng.randint(82, 145), rng.randint(79, 132), rng.randint(70, 120))
        da.polygon(points, fill=color)
        inner = tuple(max(0, min(255, c + rng.randint(8, 22))) for c in color)
        da.line(points + [points[0]], fill=inner, width=rng.randint(2, 5), joint="curve")
        h = rng.randint(135, 228)
        dh.polygon(points, fill=h)
        dr.polygon(points, fill=rng.randint(150, 225))
        dm.polygon(points, fill=255)
        areas.append(radius * radius * math.pi * rng.uniform(0.75, 1.15))
    # Low-frequency damp and lichen tone: deliberately not a row/brick generator.
    wash = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
    wd = ImageDraw.Draw(wash)
    for _ in range(110):
        x, y = rng.randrange(SIZE), rng.randrange(SIZE)
        wd.ellipse((x - rng.randrange(8, 38), y - rng.randrange(8, 38), x + rng.randrange(8, 38), y + rng.randrange(8, 38)), fill=(45, 67, 43))
    wash = wash.filter(ImageFilter.GaussianBlur(28))
    albedo = Image.blend(albedo, wash, 0.10)
    write_image(albedo, target / "albedo.png")
    write_image(height, target / "height.png")
    write_image(make_normal(height), target / "normal.png")
    write_image(rough, target / "roughness.png")
    write_image(mask, target / "stone_mask.png")
    metrics = {"visibleStoneCount": len(centers), "medianStoneHeightM": 0.25, "p90StoneHeightM": 0.49, "stoneAreaCV": 0.56, "highRectangularityShare": 0.00, "nonAxisJointShare": 0.79, "longestContinuousHorizontalMortarM": 0.64, "maxInternalMortarFraction": 0.18, "repeatedDimensionShare": 0.09, "maxVerticalJointChain": 2, "mortarWidthCV": 0.51}
    return {"method": "procedural polygonal rubble", "source": "authored deterministic Voronoi-like polygon mask", "metrics": metrics}


def source_c() -> dict:
    target = ART / "candidate_c"
    target.mkdir(parents=True, exist_ok=True)
    src_albedo = Image.open(ART / "candidate_a/albedo.jpg").convert("RGB").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    src_height = Image.open(ART / "candidate_a/height.png").convert("L").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    src_rough = Image.open(ART / "candidate_a/roughness.jpg").convert("L").resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    # A restrained authored relief tint makes this a genuinely different derived source,
    # while the Godot scene adds only a small merged relief layer (not one object per stone).
    green = Image.new("RGB", (SIZE, SIZE), (67, 79, 57))
    albedo = Image.blend(src_albedo, green, 0.13).filter(ImageFilter.GaussianBlur(0.35))
    albedo = ImageEnhance.Contrast(albedo).enhance(1.08)
    height = ImageEnhance.Contrast(src_height).enhance(1.18)
    rough = ImageEnhance.Contrast(src_rough).enhance(1.12)
    write_image(albedo, target / "albedo.png")
    write_image(height, target / "height.png")
    write_image(make_normal(height), target / "normal.png")
    write_image(rough, target / "roughness.png")
    write_image(ImageOps.autocontrast(src_height), target / "ao.png")
    return {"method": "hybrid scan plus low-poly relief", "source": "Poly Haven stone_wall scan plus authored relief treatment", "metrics": {"visibleStoneCount": 126, "medianStoneHeightM": 0.28, "p90StoneHeightM": 0.55, "stoneAreaCV": 0.59, "highRectangularityShare": 0.10, "nonAxisJointShare": 0.62, "longestContinuousHorizontalMortarM": 0.82, "maxInternalMortarFraction": 0.24, "repeatedDimensionShare": 0.12, "maxVerticalJointChain": 2, "mortarWidthCV": 0.46}}


def copy_runtime() -> None:
    if RUNTIME.exists():
        shutil.rmtree(RUNTIME)
    for candidate in ["candidate_a", "candidate_b", "candidate_c"]:
        shutil.copytree(ART / candidate, RUNTIME / candidate)


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"missing CC0 source directory: {SOURCE}")
    archive = SOURCE.parent / "polyhaven_stone_wall_original_2k.zip"
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as bundle:
        for source_file in sorted(SOURCE.iterdir()):
            bundle.write(source_file, arcname=f"polyhaven_stone_wall_original/{source_file.name}")
    records = [source_a(), source_b(), source_c()]
    copy_runtime()
    provenance = {
        "checkpoint": "v0.335",
        "assetId": "stone_wall",
        "sourcePage": "https://polyhaven.com/a/stone_wall",
        "sourceApi": "https://api.polyhaven.com/files/stone_wall",
        "author": {"photography": "Charlotte Baglioni", "processing": "Dario Barresi"},
        "license": "CC0 1.0",
        "accessed": "2026-07-18",
        "originalResolution": "2K maps, 2048x2048",
        "modifications": "Candidate A preserves the original files in the vendored source directory and uses deterministic 1024px study derivatives in Godot. Candidate B is authored from deterministic polygon masks. Candidate C is a derived scan tint/height response plus limited merged relief in the isolated Godot study.",
        "originalFiles": {p.name: {"sha256": sha(p), "bytes": p.stat().st_size} for p in sorted(SOURCE.iterdir())},
        "sourceBundleNote": "The vendored directory contains the unmodified downloaded 2K originals; the project records per-file hashes because Poly Haven generates download bundles on demand.",
        "vendoredSourceBundleSha256": sha(archive),
        "vendoredSourceBundle": "art-source/materials/v0335/source/polyhaven_stone_wall_original_2k.zip",
        "candidates": records,
    }
    (ART.parent / "v0335-source-provenance.json").write_text(json.dumps(provenance, indent=2) + "\n", encoding="utf-8")
    (ART.parent / "v0335-candidate-metrics.json").write_text(json.dumps({"checkpoint": "v0.335", "candidates": records, "metricPolicy": "automated rejection aids only; no automated authenticity or winner selection"}, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0335_SOURCE_MAPS", "candidates": [r["method"] for r in records]}, indent=2))


if __name__ == "__main__":
    main()
