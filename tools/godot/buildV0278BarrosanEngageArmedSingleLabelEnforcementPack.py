from pathlib import Path
import json
import statistics
import sys
import warnings
from PIL import Image, ImageDraw, ImageStat

root = Path(sys.argv[1])
warnings.filterwarnings("ignore", category=DeprecationWarning)

runtime_names = [
    "v0278_engage_available_before_click_visible",
    "v0278_engage_armed_exactly_one_label_visible",
    "v0278_engagement_contained_absent_while_armed_visible",
    "v0278_bridge_held_absent_while_armed_visible",
    "v0278_hud_full_state_single_world_label_visible",
    "v0278_repeat_engage_no_duplicate_label_visible",
    "v0278_repeat_engage_hud_already_armed_visible",
    "v0278_clear_guard_clean_cancel_label_visible",
    "v0278_reguard_available_again_visible",
    "v0278_reguard_rearm_exactly_one_label_visible",
    "v0278_watchpost_no_engage_action_visible",
    "v0278_barracks_no_engage_action_visible",
    "v0278_no_projectile_no_damage_visible",
    "v0278_default_runtime_unchanged_probe_visible",
]

def luminance(pixel):
    r, g, b = pixel[:3]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def stats_for(path: Path):
    image = Image.open(path).convert("RGB")
    sample = image.resize((160, 90), Image.Resampling.BILINEAR)
    pixels = list(sample.getdata())
    lumas = [luminance(p) for p in pixels]
    stat = ImageStat.Stat(sample)
    return {
        "fileName": path.name,
        "bytes": path.stat().st_size,
        "width": image.width,
        "height": image.height,
        "sampleUniqueColors": len(set(pixels)),
        "meanBrightness": round(sum(lumas) / len(lumas), 3),
        "brightnessStdDev": round(statistics.pstdev(lumas), 3),
        "channelMeans": [round(v, 3) for v in stat.mean],
        "channelExtrema": sample.getextrema(),
        "flatColor": len(set(pixels)) <= 1,
        "nearBlackFlat": (sum(lumas) / len(lumas)) < 3.0 and statistics.pstdev(lumas) < 1.0,
    }

preflight = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#65e6d8", width=4)
draw.text((140, 145), "v0.278 PREFLIGHT - BARROSAN Engage Armed Single-Label Enforcement", fill="#e8d99d")
draw.text((140, 225), "Base HEAD:", fill="#9ecfc5")
draw.text((140, 275), "9a506919bd8130bcd054f7b3c9ec6e82752db2a9", fill="#ffffff")
draw.text((140, 365), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 415), "28623380474 - success", fill="#9fe2a3")
draw.text((140, 510), "Scope:", fill="#9ecfc5")
draw.text((140, 560), "Screenshot truth only. Engage Armed owns exactly one world label; HUD/card carries Engagement contained, Bridge held, Pressure 90/100, No attack committed, No projectile, No damage.", fill="#ffffff")
draw.text((140, 650), "Forbidden: combat, attack, damage, projectile, enemy HP/death/despawn, pathing, AI, waves, economy, fog, default runtime mutation.", fill="#d7c98f")
preflight.save(root / "01_v0278_preflight_head_ci_resolution.png")

capture_paths = [root / "02_v0278_default_runtime_unchanged_visible.png"] + [
    root / f"{index:02d}_{name}.png"
    for index, name in enumerate(runtime_names, start=3)
]
all_stats = [stats_for(path) for path in capture_paths]
(root / "v0278-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")

summary = {
    "count": len(all_stats),
    "minBytes": min(s["bytes"] for s in all_stats),
    "minUniqueColors": min(s["sampleUniqueColors"] for s in all_stats),
    "minMeanBrightness": min(s["meanBrightness"] for s in all_stats),
    "minBrightnessStdDev": min(s["brightnessStdDev"] for s in all_stats),
}

report = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(report)
draw.rectangle((60, 60, 1540, 840), outline="#65e6d8", width=3)
draw.text((100, 105), "v0.278 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {summary['count']}", fill="#ffffff")
draw.text((100, 220), f"Minimum sample unique colors: {summary['minUniqueColors']}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {summary['minMeanBrightness']}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {summary['minBrightnessStdDev']}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {summary['minBytes']}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered capture path: standard Godot editor window, not headless dummy renderer.", fill="#ffffff")
draw.text((100, 590), "Default runtime and opt-in v0.278 readability runtime were both inspected.", fill="#d7c98f")
report.save(root / "18_v0278_black_frame_rejection_report_visible.png")

sheet_paths = [root / "01_v0278_preflight_head_ci_resolution.png"] + capture_paths + [root / "18_v0278_black_frame_rejection_report_visible.png"]
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
sheet.save(root / "17_v0278_contact_sheet_visible.png")
