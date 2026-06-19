from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])
baseline = root / "01_v0232_baseline.png"


def card(path: Path, title: str, subtitle: str):
    image = Image.new("RGB", (1600, 900), (20, 29, 23))
    draw = ImageDraw.Draw(image)
    draw.rectangle((140, 120, 1460, 780), fill=(8, 13, 10), outline=(192, 148, 65), width=6)
    draw.text((205, 205), "v0.233 BLENDER MODULAR KIT", fill=(230, 215, 170))
    draw.text((205, 285), "BLOCKED_FOR_LOCAL_BLENDER_EXPORT", fill=(230, 165, 79))
    draw.text((205, 390), title, fill=(210, 214, 198))
    draw.text((205, 460), subtitle, fill=(153, 185, 169))
    draw.text((205, 650), "No GLB exists. This image is blocker evidence, not production-art evidence.", fill=(188, 190, 175))
    image.save(path)


cards = [
    ("02_v0233_overview.png", "Overview unavailable", "Expected: imported Blender-authored modular battlefield"),
    ("03_v0233_base_structure_focus.png", "Keep/base focus unavailable", "Expected: pitched roofs, wall layers, foundations and trim"),
    ("04_v0233_barracks_workshop_focus.png", "Barracks/workshop focus unavailable", "Expected: authored timber, plaster, roof overhang and workshop silhouette"),
    ("05_v0233_mine_lume_focus.png", "Mine/Lume focus unavailable", "Expected: authored rock mass, portal framing, rubble and emissive crystal"),
    ("06_v0233_road_bridge_river_focus.png", "Road/bridge/river focus unavailable", "Expected: embedded road, shaped banks, depth-separated water and bridge contact"),
    ("07_v0233_props_and_scale.png", "Props and scale focus unavailable", "Expected: rocks, logs, crates, posts, trees, rubble, barrels and unit dummies"),
]
for name, title, subtitle in cards:
    card(root / name, title, subtitle)

before = Image.open(baseline).convert("RGB")
before.thumbnail((930, 520))
blocked = Image.open(root / "02_v0233_overview.png").convert("RGB")
blocked.thumbnail((930, 520))
sheet = Image.new("RGB", (1920, 620), (11, 16, 13))
draw = ImageDraw.Draw(sheet)
draw.text((24, 16), "v0.232 baseline vs v0.233 blocked Blender export", fill=(235, 223, 181))
sheet.paste(before, (20, 54))
sheet.paste(blocked, (970, 54))
draw.text((28, 590), "V0.232 BASELINE", fill=(210, 212, 195))
draw.text((978, 590), "V0.233: NO VISUAL RESULT", fill=(230, 165, 79))
sheet.save(root / "08_before_after_contact_sheet.png")

kit = Image.new("RGB", (1920, 1080), (15, 21, 17))
draw = ImageDraw.Draw(kit)
draw.text((40, 30), "v0.233 intended authored kit contract — export blocked", fill=(235, 221, 176))
modules = [
    "terrain base + grass/earth variants", "road + intersection + bridge connector",
    "river channel + banks", "bridge", "keep/base", "barracks/workshop",
    "mine/Lume", "rocks + logs + crates + posts", "trees + rubble + barrels", "unit scale dummies",
]
for index, label in enumerate(modules):
    col, row = index % 2, index // 2
    x, y = 45 + col * 945, 105 + row * 178
    draw.rounded_rectangle((x, y, x + 880, y + 140), radius=18, fill=(28, 39, 31), outline=(119, 145, 109), width=3)
    draw.text((x + 28, y + 35), label, fill=(205, 210, 190))
    draw.text((x + 28, y + 82), "NOT EXPORTED — contract and Blender source only", fill=(220, 157, 74))
kit.save(root / "09_asset_kit_contact_sheet.png")
