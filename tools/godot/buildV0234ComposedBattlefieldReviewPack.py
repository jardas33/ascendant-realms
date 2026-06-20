"""Build the v0.234 before/after and composed-scene contact sheets."""

from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])


def fit(path: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image.thumbnail(size, Image.Resampling.LANCZOS)
    return image


baseline = fit(root / "01_v0233R_kit_baseline.png", (930, 520))
overview = fit(root / "02_v0234_composed_overview.png", (930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.233R kit catalogue vs v0.234 composed Blender battlefield", fill=(235, 223, 181))
sheet.paste(baseline, (20, 54))
sheet.paste(overview, (970, 54))
draw.text((28, 590), "V0.233R FLOATING KIT", fill=(210, 212, 195))
draw.text((978, 590), "V0.234 COMPOSED SLICE", fill=(112, 216, 196))
sheet.save(root / "08_before_after_contact_sheet.png")

captures = [
    ("02_v0234_composed_overview.png", "COMPOSED OVERVIEW"),
    ("03_v0234_keep_and_base_focus.png", "KEEP / BASE"),
    ("04_v0234_barracks_workshop_focus.png", "BARRACKS / WORKSHOP"),
    ("05_v0234_mine_lume_focus.png", "MINE / LUME"),
    ("06_v0234_road_bridge_river_focus.png", "ROAD / BRIDGE / RIVER"),
    ("07_v0234_props_grounding_scale_focus.png", "PROPS / GROUNDING / SCALE"),
]
contact = Image.new("RGB", (1920, 1080), (13, 19, 16))
draw = ImageDraw.Draw(contact)
draw.text((32, 20), "v0.234 composed imported-Blender battlefield review", fill=(235, 221, 176))
for index, (name, label) in enumerate(captures):
    col, row = index % 3, index // 3
    x, y = 20 + col * 635, 58 + row * 505
    image = fit(root / name, (620, 480))
    contact.paste(image, (x, y))
    draw.rectangle((x, y + 447, x + 620, y + 480), fill=(8, 13, 10))
    draw.text((x + 12, y + 457), label, fill=(218, 211, 178))
contact.save(root / "09_v0234_composition_contact_sheet.png")
