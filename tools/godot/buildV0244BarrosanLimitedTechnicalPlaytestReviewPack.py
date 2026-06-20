from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#111711")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 150), "v0.244 PREFLIGHT - REPOSITORY TRUTH", fill="#e8d99d")
draw.text((140, 235), "Resolved base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 285), "832175edc9acd71648b0d986061e45f98f6464dd", fill="#ffffff")
draw.text((140, 380), "v0.243 implementation commit:", fill="#9ecfc5")
draw.text((140, 430), "af4b52914cec260b6517f16021cf502774ea2ddd", fill="#ffffff")
draw.text((140, 525), "Final v0.243 exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 575), "27884622555 - completed / success", fill="#9fe2a3")
draw.text((140, 680), "Meaning: 832175e is the documentation closeout child of af4b529.", fill="#d7c98f")
preflight.save(root / "04_v0244_preflight_head_ci_resolution.png")

paths = [root / f"{index:02d}_{name}" for index, name in []]
paths = sorted(p for p in root.glob("[0-1][0-8]_*.png") if p.name != "19_v0244_before_after_contact_sheet.png")
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
sheet.save(root / "19_v0244_before_after_contact_sheet.png")
