from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#111711")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 150), "v0.249 PREFLIGHT - REPOSITORY TRUTH", fill="#e8d99d")
draw.text((140, 235), "Resolved base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 285), "cca1b455cbda9df2873e972d9ba4528f6271a7b7", fill="#ffffff")
draw.text((140, 380), "v0.248 implementation / documentation closeout:", fill="#9ecfc5")
draw.text((140, 430), "6c5cfa196e31229b3c976254212114dcbeeef473 / cca1b455...", fill="#ffffff")
draw.text((140, 525), "Final v0.248 exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 575), "27909037181 - completed / success", fill="#9fe2a3")
draw.text((140, 680), "Scope: one Militia versus one scripted Raider; deterministic contact combat only.", fill="#d7c98f")
preflight.save(root / "02_v0249_preflight_head_ci_resolution.png")

paths = sorted(p for p in root.glob("[0-3][0-9]_*.png") if p.name != "39_v0249_before_after_contact_sheet.png")
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
sheet.save(root / "39_v0249_before_after_contact_sheet.png")
