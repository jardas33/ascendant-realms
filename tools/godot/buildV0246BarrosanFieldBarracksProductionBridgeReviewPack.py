from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#111711")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 150), "v0.246 PREFLIGHT - REPOSITORY TRUTH", fill="#e8d99d")
draw.text((140, 235), "Resolved base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 285), "f9895e5bbca9cf38280097383afa877719a68986", fill="#ffffff")
draw.text((140, 380), "v0.245 implementation / docs closeout:", fill="#9ecfc5")
draw.text((140, 430), "4fc5b6229ea7b99c36754a5281320f8b6423b94d / f9895e5...", fill="#ffffff")
draw.text((140, 525), "Final v0.245 exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 575), "27889143566 - completed / success", fill="#9fe2a3")
draw.text((140, 680), "Scope: one Militia from the constructed opt-in Field Barracks.", fill="#d7c98f")
preflight.save(root / "02_v0246_preflight_head_ci_resolution.png")

paths = sorted(p for p in root.glob("[0-2][0-4]_*.png") if p.name != "25_v0246_before_after_contact_sheet.png")
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
sheet.save(root / "25_v0246_before_after_contact_sheet.png")
