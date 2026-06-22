from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#111711")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 145), "v0.256 PREFLIGHT - FIRST WORKER REBUILD BRIDGE", fill="#e8d99d")
draw.text((140, 225), "Resolved base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 275), "b3043402cb1219468ed09a8e0c3e1345a59f407e", fill="#ffffff")
draw.text((140, 365), "Final v0.255 exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 415), "27949696015 - completed / success", fill="#9fe2a3")
draw.text((140, 510), "Rule:", fill="#9ecfc5")
draw.text((140, 560), "Repair is HP 1-199. Rebuild is explicit at HP 0 only.", fill="#ffffff")
draw.text((140, 650), "Rebuild costs 90 Crowns / 40 Stone and restores 0 -> 100 HP.", fill="#d7c98f")
preflight.save(root / "02_v0256_preflight_head_ci_resolution.png")

paths = sorted(p for p in root.glob("[0-5][0-9]_*.png") if p.name != "51_v0256_contact_sheet.png")
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
sheet.save(root / "51_v0256_contact_sheet.png")
