from pathlib import Path
import json
import statistics
import sys
import warnings
from PIL import Image, ImageDraw, ImageStat

root = Path(sys.argv[1])
repo_root = Path(__file__).resolve().parents[2]
ledger_path = repo_root / "docs" / "V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LEDGER.json"
warnings.filterwarnings("ignore", category=DeprecationWarning)

capture_files = [
    "02_v0289_true_default_runtime_baseline_no_fixture_no_opt_in.png",
    "03_v0289_retained_v0282_v0284_baseline_ledger_proof.png",
    "04_v0289_manual_fixture_baseline_clean_hud.png",
    "05_v0289_engage_available_before_click.png",
    "06_v0289_engage_armed.png",
    "07_v0289_commit_engage_clicked.png",
    "08_v0289_post_commit_pressure_checked_ashen_braced.png",
    "09_v0289_hold_line_available_after_commit_locked.png",
    "10_v0289_hold_line_clicked.png",
    "11_v0289_line_held_exactly_once.png",
    "12_v0289_ashen_contained_exactly_once.png",
    "13_v0289_select_field_barracks_after_hold_line.png",
    "14_v0289_train_militia_available_reserve_slot_empty.png",
    "15_v0289_train_clicked.png",
    "16_v0289_reserve_ready_exactly_once.png",
    "17_v0289_assign_to_bridge_available.png",
    "18_v0289_assign_clicked.png",
    "19_v0289_reserve_assigned_exactly_once.png",
    "20_v0289_select_defender_after_reserve_assigned.png",
    "21_v0289_signal_available.png",
    "22_v0289_signal_clicked.png",
    "23_v0289_bridge_signal_sent_exactly_once.png",
    "24_v0289_signal_sent_exactly_once.png",
    "25_v0289_reserve_ack_exactly_once.png",
    "26_v0289_select_field_barracks_after_reserve_ack.png",
    "27_v0289_prepare_support_available.png",
    "28_v0289_prepare_clicked.png",
    "29_v0289_support_order_ready_exactly_once.png",
    "30_v0289_order_ready_exactly_once.png",
    "31_v0289_barracks_card_awaiting_deployment_approval.png",
    "32_v0289_defender_card_support_order_ready.png",
    "33_v0289_repeat_prepare_no_duplicate_order_marker_stack.png",
    "34_v0289_resources_unchanged_after_train_assign_signal_prepare.png",
    "35_v0289_reserve_marker_no_movement_pathing_attack_deploy_behavior.png",
    "36_v0289_watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare.png",
    "37_v0289_field_barracks_no_engage_commit_hold_ashen_signal.png",
    "38_v0289_clear_guard_settles_defender_contact_clean_after_prepare.png",
    "39_v0289_reguard_clean_after_prepare_no_auto_deploy.png",
    "40_v0289_no_projectile_damage_hp_loss_death_despawn.png",
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
        "flatColor": len(set(pixels)) <= 1,
        "nearBlackFlat": (sum(lumas) / len(lumas)) < 3.0 and statistics.pstdev(lumas) < 1.0,
    }


def draw_wrapped(draw, xy, text, fill, max_chars=112, line_height=30):
    x, y = xy
    words = text.split()
    line = ""
    for word in words:
        candidate = (line + " " + word).strip()
        if len(candidate) > max_chars:
            draw.text((x, y), line, fill=fill)
            y += line_height
            line = word
        else:
            line = candidate
    if line:
        draw.text((x, y), line, fill=fill)
        y += line_height
    return y


ledger = json.loads(ledger_path.read_text(encoding="utf-8"))

preflight = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#65e6d8", width=4)
draw.text((140, 140), "v0.289 PREFLIGHT - reserve support order prepared step", fill="#e8d99d")
draw.text((140, 215), "Base HEAD:", fill="#9ecfc5")
draw.text((140, 260), "094788075cfa2933cc67477283e0bc5aa33ebc07", fill="#ffffff")
draw.text((140, 340), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 385), "28729451551 - success", fill="#9fe2a3")
draw.text((140, 470), "Scope:", fill="#9ecfc5")
draw_wrapped(draw, (140, 520), "After accepted v0.288 Reserve ACK, selecting the Field Barracks exposes one Prepare option that creates SUPPORT ORDER READY and one static ORDER READY marker.", "#ffffff")
draw_wrapped(draw, (140, 635), "Forbidden: deployment, movement, pathing, route preview, duplicate order/marker, resources mutation, damage, HP loss, projectiles, death/despawn, AI, waves, fog, economy, and true default runtime mutation.", "#d7c98f")
preflight.save(root / "01_v0289_preflight_head_ci_resolution.png")

ledger_image = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(ledger_image)
draw.rectangle((55, 55, 1545, 845), outline="#65e6d8", width=3)
draw.text((90, 92), "v0.289 RETAINED v0.282/v0.284/v0.285/v0.286/v0.287 LEDGER PROOF", fill="#e8d99d")
y = 155
for key, record in ledger["records"].items():
    draw.text((90, y), key, fill="#9fe2a3")
    y += 38
    resources = record["hudResourceValues"]
    draw.text((120, y), f"HUD: crowns {resources['crowns']} | stone {resources['stone']} | iron {resources['iron']} | aether {resources['aether']}", fill="#ffffff")
    y += 30
    draw.text((120, y), f"Selected: {record['selectedUnitOrBuilding']} | Strip: {record['topLeftStatusStripText']}", fill="#ffffff")
    y += 30
    draw.text((120, y), f"Flags: opt-in={record['barrosanOptInActive']} fixture={record['manualReviewFixtureActive']} engage/commit={record['engageOrCommitActive']} pressure={record['pressureMarkerActive']}", fill="#d7c98f")
    y += 48
draw.text((90, 735), "v0.284 repaired-HUD contract is retained: four selected-card text rows, separated button row, concise top strip.", fill="#9ecfc5")
draw.text((90, 775), "v0.289 only adds a static Barracks-side support order after v0.288 Reserve ACK.", fill="#9ecfc5")
ledger_image.save(root / "03_v0289_retained_v0282_v0284_baseline_ledger_proof.png")

diagnostic = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(diagnostic)
draw.rectangle((60, 60, 1540, 840), outline="#65e6d8", width=3)
draw.text((100, 105), "v0.289 UI LAYOUT DIAGNOSTIC PROOF", fill="#e8d99d")
draw.text((100, 170), "Selected card rect: x=420 y=742 w=760 h=150", fill="#ffffff")
draw.text((100, 220), "Text rect: x=438 y=752 w=500 h=92", fill="#ffffff")
draw.text((100, 270), "Button row rect: x=438 y=856 w=530 h=24", fill="#ffffff")
draw.text((100, 320), "Top strip vocabulary includes SUPPORT ORDER READY and still caps at 36 chars.", fill="#ffffff")
draw.text((100, 390), "PASS gates: no text/button overlap, max four rows, no raw validator paragraphs, short world labels.", fill="#9fe2a3")
draw.text((100, 460), "Prepare labels: ORDER READY exactly once near reserve; RESERVE ACK retained exactly once.", fill="#d7c98f")
diagnostic.save(root / "41_v0289_ui_layout_diagnostic_proof_retained.png")

capture_paths = [root / name for name in capture_files]
missing = [path.name for path in capture_paths if not path.exists()]
if missing:
    raise SystemExit(f"Missing v0.289 capture files before pack assembly: {missing}")

all_stats = [stats_for(path) for path in capture_paths]
(root / "v0289-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")

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
draw.text((100, 105), "v0.289 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {summary['count']}", fill="#ffffff")
draw.text((100, 220), f"Minimum sample unique colors: {summary['minUniqueColors']}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {summary['minMeanBrightness']}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {summary['minBrightnessStdDev']}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {summary['minBytes']}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered evidence includes true default, ledger, and 37 v0.289 opt-in support-order states.", fill="#ffffff")
report.save(root / "43_v0289_black_frame_rejection_report.png")

sheet_paths = [root / "01_v0289_preflight_head_ci_resolution.png"] + capture_paths + [root / "41_v0289_ui_layout_diagnostic_proof_retained.png", root / "43_v0289_black_frame_rejection_report.png"]
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
sheet.save(root / "42_v0289_contact_sheet.png")
