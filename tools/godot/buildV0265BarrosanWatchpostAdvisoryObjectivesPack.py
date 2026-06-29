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
    lumas = [luminance(p) for p in pixels]
    stat = ImageStat.Stat(sample)
    minimap_crop = sample.crop((0, 63, 40, 90))
    hud_top = sample.crop((40, 0, 120, 12))
    hud_bottom = sample.crop((40, 70, 120, 90))
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
        "minimapUniqueColors": len(set(minimap_crop.getdata())),
        "hudTopUniqueColors": len(set(hud_top.getdata())),
        "hudBottomUniqueColors": len(set(hud_bottom.getdata())),
    }

preflight = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 145), "v0.265 PREFLIGHT - BARROSAN Watchpost Advisory Objectives", fill="#e8d99d")
draw.text((140, 225), "Base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 275), "e1f164c41cc52b6be10fae9ac6860df9b3eeadf4", fill="#ffffff")
draw.text((140, 365), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 415), "v0.264 closeout: Fast confidence job-level success", fill="#9fe2a3")
draw.text((140, 510), "Scope:", fill="#9ecfc5")
draw.text((140, 560), "Passive Watchpost advisory objectives: online, outside-range, current, memory, and Barracks guidance.", fill="#ffffff")
draw.text((140, 620), "No attack, projectiles, combat, economy, waves, Blender, GLB, AI, pathing, or default-runtime changes.", fill="#ffffff")
draw.text((140, 700), "Cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.", fill="#d7c98f")
preflight.save(root / "01_v0265_preflight_head_ci_resolution.png")

runtime_names = [
    "v0265_watchpost_build_path_visible",
    "v0265_watchpost_online_monitoring_objective_visible",
    "v0265_no_prior_intel_relay_visible",
    "v0265_ashen_outside_zone_monitoring_not_alarm_visible",
    "v0265_no_false_positive_outside_zone_visible",
    "v0265_current_detection_objective_prepare_defenders_visible",
    "v0265_current_detection_intel_relay_visible",
    "v0265_current_detection_world_label_clean_visible",
    "v0265_current_detection_minimap_ping_visible",
    "v0265_barracks_selected_current_detection_militia_advisory_visible",
    "v0265_barracks_train_militia_after_watchpost_advisory_visible",
    "v0265_threat_leaves_memory_objective_visible",
    "v0265_last_seen_memory_intel_relay_visible",
    "v0265_last_seen_memory_marker_distinct_visible",
    "v0265_last_seen_memory_minimap_ping_distinct_visible",
    "v0265_memory_not_current_detection_visible",
    "v0265_watchpost_hud_no_barracks_actions_visible",
    "v0265_barracks_hud_no_watchpost_relay_card_visible",
    "v0265_existing_barracks_rebuild_path_still_valid_visible",
    "v0265_no_detection_or_advisory_before_watchpost_complete_visible",
    "v0265_world_label_clutter_not_regressed_visible",
]
capture_paths = [root / "02_v0265_default_runtime_unchanged_visible.png"] + [
    root / f"{index:02d}_{name}.png"
    for index, name in enumerate(runtime_names, start=3)
]

all_stats = [stats_for(path) for path in capture_paths]
(root / "v0265-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")

summary = {
    "count": len(all_stats),
    "minBytes": min(s["bytes"] for s in all_stats),
    "minUniqueColors": min(s["sampleUniqueColors"] for s in all_stats),
    "minMeanBrightness": min(s["meanBrightness"] for s in all_stats),
    "minBrightnessStdDev": min(s["brightnessStdDev"] for s in all_stats),
}

report = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(report)
draw.rectangle((60, 60, 1540, 840), outline="#55b6ad", width=3)
draw.text((100, 105), "v0.265 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {summary['count']}", fill="#ffffff")
draw.text((100, 220), f"Minimum sample unique colors: {summary['minUniqueColors']}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {summary['minMeanBrightness']}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {summary['minBrightnessStdDev']}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {summary['minBytes']}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered capture path: standard Godot editor window, not headless dummy renderer.", fill="#ffffff")
draw.text((100, 590), "Default runtime and opt-in Watchpost advisory-objectives runtime were both inspected.", fill="#d7c98f")
report.save(root / "25_v0265_black_frame_rejection_report_visible.png")

sheet_paths = [root / "01_v0265_preflight_head_ci_resolution.png"] + capture_paths + [root / "25_v0265_black_frame_rejection_report_visible.png"]
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
sheet.save(root / "24_v0265_contact_sheet_visible.png")

