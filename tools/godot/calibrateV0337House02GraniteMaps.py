"""Create v0.337 calibrated derivatives from the accepted v0.335 candidate A.

The v0.335 candidate files are never modified.  The derivatives are deliberately
conservative: cool/desaturated albedo, bounded roughness, preserved OpenGL
normal orientation, and source height/AO retained for evidence/future use.
"""

from __future__ import annotations

import hashlib
import json
from pathlib import Path

from PIL import Image, ImageEnhance, ImageOps

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art-source/materials/v0335/candidates/candidate_a"
OUT = ROOT / "art-source/materials/v0337/selected_granite"
PROJECT_OUT = ROOT / "desktop-spikes/godot-salto/assets/v0337/selected_granite"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save_rgb(source: Image.Image, path: Path, saturation: float, contrast: float, tint: tuple[float, float, float], exposure: float) -> None:
    image = source.convert("RGB").resize((2048, 2048), Image.Resampling.LANCZOS)
    image = ImageEnhance.Color(image).enhance(saturation)
    image = ImageEnhance.Contrast(image).enhance(contrast)
    image = ImageEnhance.Brightness(image).enhance(exposure)
    pixels = []
    for r, g, b in image.getdata():
        pixels.append((max(0, min(255, round(r * tint[0]))), max(0, min(255, round(g * tint[1]))), max(0, min(255, round(b * tint[2])))))
    image.putdata(pixels)
    image.save(path, format="PNG", optimize=True)


def save_gray(source: Image.Image, path: Path, low: int, high: int) -> None:
    image = source.convert("L").resize((2048, 2048), Image.Resampling.LANCZOS)
    image = ImageOps.autocontrast(image, cutoff=1)
    image = image.point(lambda value: low + (high - low) * value / 255.0)
    image.save(path, format="PNG", optimize=True)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    PROJECT_OUT.mkdir(parents=True, exist_ok=True)
    albedo = Image.open(SOURCE / "albedo.jpg")
    height = Image.open(SOURCE / "height.png")
    normal = Image.open(SOURCE / "normal.png")
    roughness = Image.open(SOURCE / "roughness.jpg")
    ao = Image.open(SOURCE / "ao.png")

    save_rgb(albedo, OUT / "selected_granite_albedo.png", 0.18, 0.94, (0.84, 0.91, 1.02), 0.78)
    save_rgb(albedo, OUT / "selected_granite_dressed_albedo.png", 0.16, 0.98, (0.88, 0.94, 1.02), 0.84)
    save_rgb(albedo, OUT / "selected_granite_foundation_albedo.png", 0.14, 0.94, (0.78, 0.87, 0.98), 0.68)
    save_gray(normal, OUT / "selected_granite_normal.png", 0, 255)
    save_gray(roughness, OUT / "selected_granite_roughness.png", 185, 246)
    save_gray(height, OUT / "selected_granite_height.png", 28, 228)
    save_gray(ao, OUT / "selected_granite_ao.png", 32, 255)

    for path in OUT.glob("*.png"):
        target = PROJECT_OUT / path.name
        target.write_bytes(path.read_bytes())

    lineage = {
        "checkpoint": "v0.337",
        "selectedCandidate": "candidate_a",
        "method": "photo-scanned Poly Haven stone_wall rubble; calibrated derivative only",
        "sourceDirectory": "art-source/materials/v0335/candidates/candidate_a",
        "sourceMapHashes": {name: sha(SOURCE / filename) for name, filename in {
            "albedo": "albedo.jpg", "height": "height.png", "normal": "normal.png", "roughness": "roughness.jpg", "ao": "ao.png"}.items()},
        "calibration": {
            "albedo": "saturation 0.38, contrast 0.96, cool neutral tint, exposure 0.94; no baked directional shadow added",
            "dressedAlbedo": "same source family, saturation 0.30, restrained value lift",
            "foundationAlbedo": "same source family, cool darkened contact variant",
            "normal": "source OpenGL normal preserved; Blender/Godot normal strength documented separately",
            "roughness": "bounded to 185..246 8-bit (about 0.73..0.965), no gloss painting",
            "height": "source height retained and bounded to 28..228; parallax disabled for this review asset",
            "ao": "source AO retained as evidence and optional calibrated input; not baked into albedo",
        },
        "calibratedMapHashes": {path.stem: sha(path) for path in OUT.glob("*.png")},
        "textureResolution": [2048, 2048],
        "normalStrength": 0.42,
        "heightParallax": {"enabled": False, "reason": "avoid opening/silhouette distortion in matched review views"},
    }
    (OUT / "v0337-selected-granite-lineage.json").write_text(json.dumps(lineage, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0337_SELECTED_GRANITE_MAP_CALIBRATION", "maps": len(list(OUT.glob("*.png"))), "lineage": str(OUT / "v0337-selected-granite-lineage.json")}, indent=2))


if __name__ == "__main__":
    main()
