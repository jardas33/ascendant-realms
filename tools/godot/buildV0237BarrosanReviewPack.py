"""Build the v0.237 before/after review contact sheet."""

from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])


def fit(path: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image.thumbnail(size, Image.Resampling.LANCZOS)
    return image


baseline = fit(root / "01_v0236_baseline_overview.png", (930, 520))
overview = fit(root / "02_v0237_overview.png", (930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.236 production-direction baseline vs v0.237 material richness, foliage, and inhabited detail", fill=(235, 223, 181))
sheet.paste(baseline, (20, 54))
sheet.paste(overview, (970, 54))
draw.text((28, 590), "V0.236 COHERENT LOW-POLY FOUNDATION", fill=(210, 212, 195))
draw.text((978, 590), "V0.237 MATERIAL RHYTHM / VEGETATION / INHABITED CLUSTERS", fill=(112, 216, 196))
sheet.save(root / "10_before_after_contact_sheet.png")
