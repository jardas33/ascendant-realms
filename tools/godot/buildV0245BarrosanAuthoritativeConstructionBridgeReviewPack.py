from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#111711")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 150), "v0.245 PREFLIGHT - REPOSITORY TRUTH", fill="#e8d99d")
draw.text((140, 235), "Resolved base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 285), "e84cb1369c1f1ad7513ddd2c1c8b3f09d6530f84", fill="#ffffff")
draw.text((140, 380), "v0.244 implementation commit:", fill="#9ecfc5")
draw.text((140, 430), "818bd61319f629a628b3671a1d3cc9ea1e20db87", fill="#ffffff")
draw.text((140, 525), "Final v0.244 exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 575), "27887850796 - completed / success", fill="#9fe2a3")
draw.text((140, 680), "Meaning: e84cb13 is the documentation closeout child of 818bd61.", fill="#d7c98f")
preflight.save(root / "02_v0245_preflight_head_ci_resolution.png")

paths = sorted(p for p in root.glob("[0-2][0-1]_*.png") if p.name != "22_v0245_before_after_contact_sheet.png")
tiles = []
for path in paths:
    image = Image.open(path).convert("RGB")
    image.thumbnail((560, 315), Image.Resampling.LANCZOS)
    tile = Image.new("RGB", (580, 352), "#151b14")
    tile.paste(image, ((580 - image.width) // 2, 27))
    ImageDraw.Draw(tile).text((10, 7), path.stem, fill="#ead99b")
    tiles.append(tile)
rows = (len(tiles) + 2) // 3
sheet = Image.new("RGB", (1740, rows * 352), "#0e130e")
for index, tile in enumerate(tiles):
    sheet.paste(tile, ((index % 3) * 580, (index // 3) * 352))
sheet.save(root / "22_v0245_before_after_contact_sheet.png")
