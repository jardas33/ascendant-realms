"""Build the v0.239 art baseline versus v0.240 playable integration contact sheet."""

from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])


def fit(path: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image.thumbnail(size, Image.Resampling.LANCZOS)
    return image


baseline = fit(root / "01_v0239_art_baseline_overview.png", (930, 520))
overview = fit(root / "02_v0240_playable_art_overview.png", (930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.239 authored roster vs v0.240 opt-in playable presentation integration", fill=(235, 223, 181))
sheet.paste(baseline, (20, 54))
sheet.paste(overview, (970, 54))
draw.text((28, 590), "V0.239 ART BASELINE", fill=(210, 212, 195))
draw.text((978, 590), "V0.240 ROLE MAPPING + SELECTION + FOOTPRINTS + UNIT SCALE", fill=(112, 216, 196))
sheet.save(root / "10_v0240_before_after_contact_sheet.png")
