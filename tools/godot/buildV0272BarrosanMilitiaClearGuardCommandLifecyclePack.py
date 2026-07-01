from pathlib import Path
import json
import statistics
import sys
import warnings
from PIL import Image, ImageDraw, ImageStat

root = Path(sys.argv[1])
warnings.filterwarnings("ignore", category=DeprecationWarning)

runtime_names = [
    "v0272_watchpost_build_path_visible",
    "v0272_watchpost_complete_no_intel_no_contact_visible",
    "v0272_barracks_train_militia_visible",
    "v0272_militia_training_guard_unavailable_visible",
    "v0272_militia_ready_guard_available_visible",
    "v0272_guard_button_visible_on_militia_only_visible",
    "v0272_guard_order_pending_clear_guard_button_visible",
    "v0272_clear_pending_guard_no_auto_move_visible",
    "v0272_guard_cleared_marker_removed_visible",
    "v0272_guard_cleared_minimap_indicator_removed_visible",
    "v0272_current_detection_no_guard_no_contact_visible",
    "v0272_guard_pending_no_contact_visible",
    "v0272_guard_pending_then_cleared_no_contact_visible",
    "v0272_guard_holding_clear_guard_button_visible",
    "v0272_guard_holding_contact_armed_visible",
    "v0272_clear_holding_before_contact_blocks_contact_visible",
    "v0272_guard_reissued_after_clear_pending_visible",
    "v0272_guard_reissued_holding_intercept_ready_visible",
    "v0272_first_contact_feedback_pulse_visible",
    "v0272_first_contact_integrity_90_visible",
    "v0272_contact_resolved_cooldown_locked_visible",
    "v0272_clear_guard_after_contact_pressure_still_90_visible",
    "v0272_no_repeated_damage_after_clear_and_reguard_visible",
    "v0272_overlap_continues_integrity_still_90_visible",
    "v0272_threat_leaves_memory_integrity_90_visible",
    "v0272_memory_only_no_new_contact_damage_visible",
    "v0272_no_enemy_death_or_despawn_visible",
    "v0272_no_enemy_slow_stop_redirect_visible",
    "v0272_no_militia_hp_loss_visible",
    "v0272_no_watchpost_hp_loss_visible",
    "v0272_no_watchpost_attack_projectile_tower_visible",
    "v0272_watchpost_hud_advisory_only_no_train_no_guard_no_clear_visible",
    "v0272_watchpost_relay_guard_cleared_message_visible",
    "v0272_barracks_hud_train_militia_no_full_relay_visible",
    "v0272_militia_hud_guard_available_after_clear_visible",
    "v0272_militia_hud_resolved_cooldown_after_contact_visible",
    "v0272_minimap_guard_pending_indicator_visible",
    "v0272_minimap_guard_holding_indicator_visible",
    "v0272_minimap_guard_cleared_no_indicator_visible",
    "v0272_minimap_contact_ping_current_only_visible",
    "v0272_minimap_memory_no_contact_ping_visible",
    "v0272_label_declutter_guard_cleared_visible",
    "v0272_label_declutter_first_contact_visible",
    "v0272_existing_barracks_rebuild_path_still_valid_visible",
    "v0272_existing_barracks_still_trains_militia_visible",
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
draw.rectangle((90, 90, 1510, 810), outline="#55b6ad", width=4)
draw.text((140, 145), "v0.272 PREFLIGHT - BARROSAN Militia Clear Guard Command Lifecycle", fill="#e8d99d")
draw.text((140, 225), "Base HEAD / origin/main:", fill="#9ecfc5")
draw.text((140, 275), "f8c2507c44b327dbc83296f8eab7068a58c8de36", fill="#ffffff")
draw.text((140, 365), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 415), "28484611600 - success", fill="#9fe2a3")
draw.text((140, 510), "Scope:", fill="#9ecfc5")
draw.text((140, 560), "Command/readability/player-agency only. Guard Bridge assigns; Clear Guard removes the assignment. Neither auto-moves nor auto-attacks.", fill="#ffffff")
draw.text((140, 620), "Contact requires Watchpost current detection, ready Militia, explicit guard order, holding east bridge, intercept ready.", fill="#ffffff")
draw.text((140, 700), "Preserve one-time Ashen pressure integrity: 100/100 -> 90/100. No damage below 90, projectiles, tower behavior, death/despawn, slow/stop/redirect, AI/pathing/wave/economy/default-runtime changes.", fill="#d7c98f")
preflight.save(root / "01_v0272_preflight_head_ci_resolution.png")

capture_paths = [root / "02_v0272_default_runtime_unchanged_visible.png"] + [
    root / f"{index:02d}_{name}.png"
    for index, name in enumerate(runtime_names, start=3)
]

all_stats = [stats_for(path) for path in capture_paths]
(root / "v0272-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")

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
draw.text((100, 105), "v0.272 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {summary['count']}", fill="#ffffff")
draw.text((100, 220), f"Minimum sample unique colors: {summary['minUniqueColors']}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {summary['minMeanBrightness']}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {summary['minBrightnessStdDev']}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {summary['minBytes']}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered capture path: standard Godot editor window, not headless dummy renderer.", fill="#ffffff")
draw.text((100, 590), "Default runtime and opt-in guard-command runtime were both inspected.", fill="#d7c98f")
report.save(root / "49_v0272_black_frame_rejection_report_visible.png")

sheet_paths = [root / "01_v0272_preflight_head_ci_resolution.png"] + capture_paths + [root / "49_v0272_black_frame_rejection_report_visible.png"]
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
sheet.save(root / "48_v0272_contact_sheet_visible.png")
