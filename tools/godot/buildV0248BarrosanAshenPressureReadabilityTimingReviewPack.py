from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#111711")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 150), "v0.248 PREFLIGHT - REPOSITORY TRUTH", fill="#e8d99d")
draw.text((140, 235), "Resolved base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 285), "3904510b82cb5f6040fdff13dc0f6b2b83e520ff", fill="#ffffff")
draw.text((140, 380), "v0.247 implementation / documentation closeout:", fill="#9ecfc5")
draw.text((140, 430), "2c502121ec83b476e571d1ef557bf8666fed90de / 3904510b...", fill="#ffffff")
draw.text((140, 525), "Final v0.247 exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 575), "27906676309 - completed / success", fill="#9fe2a3")
draw.text((140, 680), "Scope: opt-in readability and timing hardening; no combat, damage, death or AI.", fill="#d7c98f")
preflight.save(root / "02_v0248_preflight_head_ci_resolution.png")

paths = sorted(p for p in root.glob("[0-3][0-9]_*.png") if p.name != "35_v0248_before_after_contact_sheet.png")
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
sheet.save(root / "35_v0248_before_after_contact_sheet.png")
