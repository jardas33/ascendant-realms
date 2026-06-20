"""Build the v0.238 before/after roster contact sheet."""

from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])


def fit(path: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image.thumbnail(size, Image.Resampling.LANCZOS)
    return image


baseline = fit(root / "01_v0237_baseline_overview.png", (930, 520))
overview = fit(root / "02_v0238_roster_overview.png", (930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.237 landmark settlement vs v0.238 full Barrosan building roster", fill=(235, 223, 181))
sheet.paste(baseline, (20, 54))
sheet.paste(overview, (970, 54))
draw.text((28, 590), "V0.237 THREE LANDMARK ROLES", fill=(210, 212, 195))
draw.text((978, 590), "V0.238 CONNECTED NINE-BUILDING BASE ROSTER", fill=(112, 216, 196))
sheet.save(root / "11_before_after_contact_sheet.png")
