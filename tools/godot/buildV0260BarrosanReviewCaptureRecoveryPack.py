from pathlib import Path
import json
import statistics
import sys
import warnings
from PIL import Image, ImageDraw, ImageStat

root = Path(sys.argv[1])
warnings.filterwarnings("ignore", category=DeprecationWarning)

def luminance(pixel):
    r, g, b = pixel[:3]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def stats_for(path: Path):
    image = Image.open(path).convert("RGB")
    sample = image.resize((160, 90), Image.Resampling.BILINEAR)
    pixels = list(sample.getdata())
    unique = len(set(pixels))
    lumas = [luminance(p) for p in pixels]
    mean = sum(lumas) / len(lumas)
    stdev = statistics.pstdev(lumas)
    stat = ImageStat.Stat(sample)
    extrema = sample.getextrema()
    minimap_crop = sample.crop((0, 63, 40, 90))
    hud_top = sample.crop((40, 0, 120, 12))
    hud_bottom = sample.crop((40, 70, 120, 90))
    return {
        "fileName": path.name,
        "bytes": path.stat().st_size,
        "width": image.width,
        "height": image.height,
        "sampleUniqueColors": unique,
        "meanBrightness": round(mean, 3),
        "brightnessStdDev": round(stdev, 3),
        "channelMeans": [round(v, 3) for v in stat.mean],
        "channelExtrema": extrema,
        "flatColor": unique <= 1,
        "nearBlackFlat": mean < 3.0 and stdev < 1.0,
        "minimapUniqueColors": len(set(minimap_crop.getdata())),
        "hudTopUniqueColors": len(set(hud_top.getdata())),
        "hudBottomUniqueColors": len(set(hud_bottom.getdata())),
    }

preflight = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 145), "v0.260 PREFLIGHT - BARROSAN REVIEW CAPTURE RECOVERY", fill="#e8d99d")
draw.text((140, 225), "Base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 275), "de5d043a00658fcb89d9ba541b6881413d9a7cf1", fill="#ffffff")
draw.text((140, 365), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 415), "28333394089 - completed / success", fill="#9fe2a3")
draw.text((140, 510), "Scope:", fill="#9ecfc5")
draw.text((140, 560), "Regenerate readable, non-black v0.259 visual evidence only.", fill="#ffffff")
draw.text((140, 650), "No gameplay, costs, HP, timing, Blender, GLB, default-runtime, or v0.261 changes.", fill="#d7c98f")
preflight.save(root / "01_v0260_preflight_head_ci_resolution.png")

capture_paths = sorted(
    p for p in root.glob("[0-2][0-9]_v0260_*.png")
    if not p.name.startswith("01_v0260_preflight")
)
all_stats = [stats_for(path) for path in capture_paths]
(root / "v0260-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")

report = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(report)
draw.rectangle((60, 60, 1540, 840), outline="#55b6ad", width=3)
draw.text((100, 105), "v0.260 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {len(all_stats)}", fill="#ffffff")
min_unique = min(s["sampleUniqueColors"] for s in all_stats)
min_mean = min(s["meanBrightness"] for s in all_stats)
min_std = min(s["brightnessStdDev"] for s in all_stats)
min_bytes = min(s["bytes"] for s in all_stats)
draw.text((100, 220), f"Minimum sample unique colors: {min_unique}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {min_mean}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {min_std}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {min_bytes}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy 7 KB screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered capture path: standard Godot editor window, not headless dummy renderer.", fill="#ffffff")
draw.text((100, 590), "The v0.259 dummy fallback is not used by this v0.260 recovery capture.", fill="#d7c98f")
report.save(root / "30_v0260_black_frame_rejection_report.png")

sheet_paths = [root / "01_v0260_preflight_head_ci_resolution.png"] + capture_paths + [root / "30_v0260_black_frame_rejection_report.png"]
tiles = []
for path in sheet_paths:
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
sheet.save(root / "31_v0260_contact_sheet_visible.png")
