"""Build the v0.236 Barrosan production-slice review contact sheets."""

from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])


def fit(path: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image.thumbnail(size, Image.Resampling.LANCZOS)
    return image


baseline = fit(root / "01_v0235_baseline_overview.png", (930, 520))
overview = fit(root / "02_v0236_overview.png", (930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.235 architecture baseline vs v0.236 Barrosan production-direction slice", fill=(235, 223, 181))
sheet.paste(baseline, (20, 54))
sheet.paste(overview, (970, 54))
draw.text((28, 590), "V0.235 CORRECT GEOMETRY / PROTOTYPE SURFACES", fill=(210, 212, 195))
draw.text((978, 590), "V0.236 ART BIBLE / ROLE DETAIL / ORGANIC GROUND", fill=(112, 216, 196))
sheet.save(root / "09_before_after_contact_sheet.png")

captures = [
    ("02_v0236_overview.png", "PRODUCTION-DIRECTION OVERVIEW"),
    ("03_v0236_barrosan_shape_language.png", "BARROSAN SHAPE LANGUAGE"),
    ("04_v0236_barracks_workshop_role_detail.png", "BARRACKS / WORKSHOP ROLE"),
    ("05_v0236_keep_base_role_detail.png", "KEEP / BASE ROLE"),
    ("06_v0236_mine_lume_role_detail.png", "MINE / LUME ROLE"),
    ("07_v0236_terrain_road_river_integration.png", "TERRAIN / ROAD / RIVER"),
    ("08_v0236_material_variation_focus.png", "MATERIAL VARIATION"),
]
contact = Image.new("RGB", (1920, 1080), (13, 19, 16))
draw = ImageDraw.Draw(contact)
draw.text((32, 20), "v0.236 Barrosan faction art bible and production-quality slice review", fill=(235, 221, 176))
for index, (name, label) in enumerate(captures):
    col = index % 3
    row = index // 3
    x, y = 20 + col * 635, 58 + row * 335
    image = fit(root / name, (620, 310))
    contact.paste(image, (x, y))
    draw.rectangle((x, y + 280, x + 620, y + 310), fill=(8, 13, 10))
    draw.text((x + 12, y + 289), label, fill=(218, 211, 178))
contact.save(root / "10_v0236_art_bible_summary_contact_sheet.png")
