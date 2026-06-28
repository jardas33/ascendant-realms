from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 145), "v0.259 PREFLIGHT - UI STATE INVARIANT HARDENING", fill="#e8d99d")
draw.text((140, 225), "Base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 275), "d28ccebc34eb0b72d6e6e6809c687598a11cc8ae", fill="#ffffff")
draw.text((140, 365), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 415), "27996039214 - completed / success", fill="#9fe2a3")
draw.text((140, 510), "Scope:", fill="#9ecfc5")
draw.text((140, 560), "Opt-in single-source lifecycle UI resolver for objective, center instruction, panel, button, target, and overlay.", fill="#ffffff")
draw.text((140, 650), "No mechanics, costs, HP, timing, Blender, GLB, wave, economy, or default-runtime changes.", fill="#d7c98f")
preflight.save(root / "01_v0259_preflight_head_ci_resolution.png")

paths = sorted(p for p in root.glob("[0-2][0-9]_*.png") if p.name != "30_v0259_contact_sheet.png")
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
sheet.save(root / "30_v0259_contact_sheet.png")
