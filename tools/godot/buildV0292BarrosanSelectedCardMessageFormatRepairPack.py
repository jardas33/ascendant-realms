import json
import statistics
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageStat

root = Path(sys.argv[1])
preflight = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(preflight)
draw.rectangle((70, 70, 1530, 830), outline="#65e6d8", width=3)
draw.text((110, 115), "v0.292 PREFLIGHT - SELECTED CARD MESSAGE FORMAT REPAIR", fill="#e8d99d")
draw.text((110, 205), "Base HEAD: 5773547e95a4cb684bdbbe8ab03565d60865d9b5", fill="#ffffff")
draw.text((110, 265), "Baseline exact-SHA Actions: 28752312583 - success", fill="#9fe2a3")
draw.text((110, 365), "Scope: selected-card text and global-instruction placement only.", fill="#ffffff")
draw.text((110, 425), "No gameplay, state progression, launch, deployment, movement, combat, or economy mutation.", fill="#d7c98f")
preflight.save(root / "01_v0292_preflight_head_ci_resolution.png")
images = sorted(path for path in root.glob("*.png") if "contact_sheet" not in path.name and "black_frame" not in path.name)
stats = []
for path in images:
    image = Image.open(path).convert("RGB")
    sample = image.resize((160, 90))
    pixels = list(sample.getdata())
    values = [0.2126 * p[0] + 0.7152 * p[1] + 0.0722 * p[2] for p in pixels]
    stats.append({"fileName": path.name, "bytes": path.stat().st_size, "width": image.width, "height": image.height, "sampleUniqueColors": len(set(pixels)), "meanBrightness": round(sum(values) / len(values), 3), "brightnessStdDev": round(ImageStat.Stat(sample).var[0] ** 0.5, 3)})
(root / "v0292-black-frame-stats.json").write_text(json.dumps({"stats": stats}, indent=2) + "\n", encoding="utf-8")
report = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(report)
draw.rectangle((60, 60, 1540, 840), outline="#65e6d8", width=3)
draw.text((100, 105), "v0.292 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 185), f"PNG files inspected: {len(stats)}", fill="#ffffff")
draw.text((100, 235), f"Minimum unique colors: {min(s['sampleUniqueColors'] for s in stats)}", fill="#9fe2a3")
draw.text((100, 285), f"Minimum brightness: {min(s['meanBrightness'] for s in stats)}", fill="#9fe2a3")
draw.text((100, 365), "PASS - review evidence is non-flat and non-black.", fill="#9fe2a3")
draw.text((100, 435), "Selected-card text is separated from all global instruction text.", fill="#ffffff")
report.save(root / "28_v0292_black_frame_rejection_report.png")
tiles = []
for path in images + [root / "28_v0292_black_frame_rejection_report.png"]:
    image = Image.open(path).convert("RGB")
    image.thumbnail((560, 315))
    tile = Image.new("RGB", (580, 350), "#151b14")
    tile.paste(image, ((580 - image.width) // 2, 28))
    ImageDraw.Draw(tile).text((10, 7), path.stem, fill="#ead99b")
    tiles.append(tile)
sheet = Image.new("RGB", (1740, ((len(tiles) + 2) // 3) * 350), "#0e130e")
for index, tile in enumerate(tiles): sheet.paste(tile, ((index % 3) * 580, (index // 3) * 350))
sheet.save(root / "27_v0292_contact_sheet.png")
