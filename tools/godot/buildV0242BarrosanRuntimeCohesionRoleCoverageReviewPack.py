from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
paths = sorted(root.glob("[0-1][0-3]_*.png"))
tiles = []
for path in paths:
    image = Image.open(path).convert("RGB")
    image.thumbnail((560, 315), Image.Resampling.LANCZOS)
    tile = Image.new("RGB", (580, 352), "#151b14")
    tile.paste(image, ((580 - image.width) // 2, 27))
    ImageDraw.Draw(tile).text((10, 7), path.stem, fill="#ead99b")
    tiles.append(tile)
sheet = Image.new("RGB", (1740, 1760), "#0e130e")
for index, tile in enumerate(tiles):
    sheet.paste(tile, ((index % 3) * 580, (index // 3) * 352))
sheet.save(root / "14_v0242_before_after_contact_sheet.png")
