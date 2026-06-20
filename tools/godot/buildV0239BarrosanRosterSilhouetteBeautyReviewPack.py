"""Build the v0.238 versus v0.239 roster contact sheet."""

from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])


def fit(path: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image.thumbnail(size, Image.Resampling.LANCZOS)
    return image


baseline = fit(root / "01_v0238_roster_baseline.png", (930, 520))
overview = fit(root / "02_v0239_roster_overview.png", (930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.238 roster breadth vs v0.239 differentiated inhabited settlement", fill=(235, 223, 181))
sheet.paste(baseline, (20, 54))
sheet.paste(overview, (970, 54))
draw.text((28, 590), "V0.238 SIMILAR CLOSED BUILDING BODIES", fill=(210, 212, 195))
draw.text((978, 590), "V0.239 DISTINCT FOOTPRINTS, YARDS, HEIGHTS + RICHNESS", fill=(112, 216, 196))
sheet.save(root / "11_before_after_contact_sheet.png")
