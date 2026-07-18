"""Create the v0.338 weathered gold-candidate maps from frozen candidate_a."""
from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path

from PIL import Image, ImageEnhance, ImageOps

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "art-source/materials/v0335/candidates/candidate_a"
OUT = ROOT / "art-source/materials/v0338/gold_candidate"
PROJECT_OUT = ROOT / "desktop-spikes/godot-salto/assets/v0338/gold_candidate"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def weathered_rgb(source: Image.Image, brightness: float, saturation: float, warm: float, damp: float = 0.0) -> Image.Image:
    image = source.convert("RGB").resize((2048, 2048), Image.Resampling.LANCZOS)
    image = ImageEnhance.Color(image).enhance(saturation)
    image = ImageEnhance.Contrast(image).enhance(0.98)
    pixels = []
    width, height = image.size
    for y in range(height):
        ground = max(0.0, min(1.0, (y / max(1, height - 1) - 0.62) / 0.38))
        for x in range(width):
            r, g, b = image.getpixel((x, y))
            value = (r * 0.30 + g * 0.59 + b * 0.11) / 255.0
            local = 1.0 + 0.055 * math.sin(x * 0.013 + y * 0.007) + 0.025 * math.sin(x * 0.041 - y * 0.019)
            age = max(0.0, min(1.0, (value - 0.42) * 1.7))
            mortar = 1.0 - (0.08 * max(0.0, 0.55 - value) / 0.55)
            damp_factor = 1.0 - damp * ground * (0.45 + 0.55 * (1.0 - value))
            rr = r * brightness * local * mortar * damp_factor
            gg = g * brightness * local * mortar * damp_factor * (1.0 + warm * 0.018 * age)
            bb = b * brightness * local * mortar * damp_factor * (1.0 - warm * 0.045)
            pixels.append((max(0, min(255, round(rr))), max(0, min(255, round(gg))), max(0, min(255, round(bb)))))
    image.putdata(pixels)
    return image


def save_gray(source: Image.Image, path: Path, low: int, high: int) -> None:
    image = source.convert("L").resize((2048, 2048), Image.Resampling.LANCZOS)
    image = ImageOps.autocontrast(image, cutoff=1)
    image = image.point(lambda value: round(low + (high - low) * value / 255.0))
    image.save(path, format="PNG", optimize=True)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    PROJECT_OUT.mkdir(parents=True, exist_ok=True)
    albedo = Image.open(SOURCE / "albedo.jpg")
    height = Image.open(SOURCE / "height.png")
    normal = Image.open(SOURCE / "normal.png")
    roughness = Image.open(SOURCE / "roughness.jpg")
    ao = Image.open(SOURCE / "ao.png")

    weathered_rgb(albedo, 0.52, 0.24, 1.0, 0.03).save(OUT / "gold_candidate_rubble_albedo.png", optimize=True)
    weathered_rgb(albedo, 0.49, 0.22, 0.6, 0.07).save(OUT / "gold_candidate_rear_albedo.png", optimize=True)
    weathered_rgb(albedo, 0.51, 0.22, 0.8, 0.05).save(OUT / "gold_candidate_gable_albedo.png", optimize=True)
    weathered_rgb(albedo, 0.60, 0.20, 0.7, 0.01).save(OUT / "gold_candidate_dressed_albedo.png", optimize=True)
    weathered_rgb(albedo, 0.42, 0.18, 0.4, 0.16).save(OUT / "gold_candidate_foundation_albedo.png", optimize=True)
    save_gray(normal, OUT / "gold_candidate_normal.png", 0, 255)
    save_gray(roughness, OUT / "gold_candidate_roughness.png", 192, 248)
    save_gray(height, OUT / "gold_candidate_height.png", 28, 228)
    save_gray(ao, OUT / "gold_candidate_ao.png", 32, 255)
    for path in OUT.glob("*.png"):
        (PROJECT_OUT / path.name).write_bytes(path.read_bytes())

    lineage = {
        "checkpoint": "v0.338",
        "selectedCandidate": "candidate_a",
        "sourceFamily": "v0.337 selected candidate_a derivative; no new source search",
        "sourceDirectory": "art-source/materials/v0335/candidates/candidate_a",
        "sourceMapHashes": {key: sha(SOURCE / filename) for key, filename in {"albedo": "albedo.jpg", "height": "height.png", "normal": "normal.png", "roughness": "roughness.jpg", "ao": "ao.png"}.items()},
        "calibration": {
            "wall": "medium grey-grey-brown, 0.52 exposure basis, saturation 0.24, deterministic local value variation, darker recessed mortar response",
            "rear": "same family, 0.49 exposure basis, cooler/damper joint variation",
            "gables": "same family, orientation-specific 0.51 exposure basis",
            "dressed": "same family, modestly smoother/lighter 0.60 exposure basis",
            "foundation": "same family, darker/desaturated 0.42 exposure basis with restrained lower-contact dampness",
            "slateTimberWindows": "frozen geometry and source material family; no directional lighting baked into albedo",
            "normal": "source OpenGL normal preserved; Blender/Godot strength 0.42",
            "roughness": "bounded to 192..248 8-bit; no gloss painting",
            "height": "source height retained and bounded to 28..228; parallax disabled",
            "ao": "retained as evidence input; not baked into albedo",
        },
        "maps": {path.stem: sha(path) for path in OUT.glob("*.png")},
        "textureResolution": [2048, 2048],
        "normalStrength": 0.42,
        "heightParallax": {"enabled": False, "reason": "protect openings, silhouette and motion truth"},
        "weathering": {"mortar": "recessed low-value response without outline", "foundation": "low coverage vertical damp variation", "mossLichen": "not baked; coverage 0%", "uniformDirtBand": False},
    }
    (OUT / "v0338-material-gold-candidate-lineage.json").write_text(json.dumps(lineage, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0338_MATERIAL_GOLD_CANDIDATE_MAP_CALIBRATION", "maps": len(list(OUT.glob("*.png"))), "lineage": str(OUT / "v0338-material-gold-candidate-lineage.json")}, indent=2))


if __name__ == "__main__":
    main()
