from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#111711")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 145), "v0.257 PREFLIGHT - REBUILD UX HARDENING", fill="#e8d99d")
draw.text((140, 225), "Base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 275), "3de91a5332022151b71ab3e3aa3d27270e1433f8", fill="#ffffff")
draw.text((140, 365), "Final v0.256 exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 415), "27988630651 - completed / success", fill="#9fe2a3")
draw.text((140, 510), "Scope:", fill="#9ecfc5")
draw.text((140, 560), "Opt-in HUD wording only. Mechanics remain identical to v0.256.", fill="#ffffff")
draw.text((140, 650), "Destroyed -> select Worker -> explicit Rebuild. Repair remains HP 1-199.", fill="#d7c98f")
preflight.save(root / "01_v0257_preflight_head_ci_resolution.png")

paths = sorted(p for p in root.glob("[0-2][0-9]_*.png") if p.name != "29_v0257_contact_sheet.png")
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
sheet.save(root / "29_v0257_contact_sheet.png")
