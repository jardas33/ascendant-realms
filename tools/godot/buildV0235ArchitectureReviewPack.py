"""Build the v0.235 architecture correction review contact sheets."""

from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])


def fit(path: Path, size: tuple[int, int]) -> Image.Image:
    image = Image.open(path).convert("RGB")
    image.thumbnail(size, Image.Resampling.LANCZOS)
    return image


baseline = fit(root / "01_v0234_baseline_overview.png", (930, 520))
overview = fit(root / "02_v0235_corrected_overview.png", (930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.234 composed baseline vs v0.235 corrected Barrosan architecture", fill=(235, 223, 181))
sheet.paste(baseline, (20, 54))
sheet.paste(overview, (970, 54))
draw.text((28, 590), "V0.234 BASIC LOW-POLY ARCHITECTURE", fill=(210, 212, 195))
draw.text((978, 590), "V0.235 CORRECTED RIDGES / EAVES / TRIM", fill=(112, 216, 196))
sheet.save(root / "08_before_after_contact_sheet.png")

captures = [
    ("02_v0235_corrected_overview.png", "CORRECTED OVERVIEW"),
    ("03_v0235_roof_geometry_proof.png", "ROOF GEOMETRY PROOF"),
    ("04_v0235_barracks_workshop_roof_focus.png", "BARRACKS / WORKSHOP"),
    ("05_v0235_keep_base_roof_focus.png", "KEEP / BASE"),
    ("06_v0235_mine_lume_focus.png", "MINE / LUME"),
    ("07_v0235_material_trim_grounding_focus.png", "MATERIAL / TRIM / GROUNDING"),
]
contact = Image.new("RGB", (1920, 1080), (13, 19, 16))
draw = ImageDraw.Draw(contact)
draw.text((32, 20), "v0.235 Human/Barrosan architecture correction and beauty review", fill=(235, 221, 176))
for index, (name, label) in enumerate(captures):
    col, row = index % 3, index // 3
    x, y = 20 + col * 635, 58 + row * 505
    image = fit(root / name, (620, 480))
    contact.paste(image, (x, y))
    draw.rectangle((x, y + 447, x + 620, y + 480), fill=(8, 13, 10))
    draw.text((x + 12, y + 457), label, fill=(218, 211, 178))
contact.save(root / "09_v0235_architecture_contact_sheet.png")
