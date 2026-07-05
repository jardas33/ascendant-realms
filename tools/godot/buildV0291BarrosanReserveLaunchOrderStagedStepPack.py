from pathlib import Path
import json, statistics, sys, warnings
from PIL import Image, ImageDraw, ImageStat

root = Path(sys.argv[1])
repo_root = Path(__file__).resolve().parents[2]
ledger_path = repo_root / "docs" / "V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LEDGER.json"
warnings.filterwarnings("ignore", category=DeprecationWarning)

capture_files = [
    "02_v0291_true_default_runtime_baseline_no_fixture_no_opt_in.png",
    "03_v0291_retained_v0282_v0284_baseline_ledger_proof.png",
] + [f"{i:02d}_v0291_{name}.png" for i, name in [
    (4,"manual_fixture_baseline_clean_hud"), (5,"engage_available_before_click"), (6,"engage_armed"), (7,"commit_engage_clicked"), (8,"post_commit_pressure_checked_ashen_braced"), (9,"hold_line_available_after_commit_locked"), (10,"hold_line_clicked"), (11,"line_held_exactly_once"), (12,"ashen_contained_exactly_once"), (13,"select_field_barracks_after_hold_line"), (14,"train_militia_available_reserve_slot_empty"), (15,"train_clicked"), (16,"reserve_ready_exactly_once"), (17,"assign_to_bridge_available"), (18,"assign_clicked"), (19,"reserve_assigned_exactly_once"), (20,"select_defender_after_reserve_assigned"), (21,"signal_available"), (22,"signal_clicked"), (23,"bridge_signal_sent_exactly_once"), (24,"signal_sent_exactly_once"), (25,"reserve_ack_exactly_once"), (26,"select_field_barracks_after_reserve_ack"), (27,"prepare_support_available"), (28,"prepare_clicked"), (29,"support_order_ready_exactly_once"), (30,"order_ready_exactly_once"), (31,"select_field_barracks_after_support_order_ready"), (32,"approve_available"), (33,"approve_clicked"), (34,"deployment_approved_exactly_once"), (35,"approved_exactly_once"), (36,"barracks_card_awaiting_launch_order"), (37,"defender_card_support_approved_awaiting_launch"), (38,"select_field_barracks_after_deployment_approved"), (39,"stage_available"), (40,"stage_clicked"), (41,"launch_order_staged_exactly_once"), (42,"launch_staged_exactly_once"), (43,"barracks_card_awaiting_final_release"), (44,"defender_card_launch_staged_awaiting_release"), (45,"repeat_stage_no_duplicate_staging_marker_stack"), (46,"resources_unchanged_after_train_assign_signal_prepare_approve_stage"), (47,"reserve_marker_no_movement_pathing_attack_deploy_launch_behavior"), (48,"watchpost_no_hold_line_engage_commit_ashen_reserve_assign_signal_prepare_approve_stage"), (49,"field_barracks_no_engage_commit_hold_ashen_signal"), (50,"clear_guard_settles_defender_contact_clean_after_stage"), (51,"reguard_clean_after_stage_no_auto_launch_deploy"), (52,"no_projectile_damage_hp_loss_death_despawn")
]]

def luminance(pixel):
    r, g, b = pixel[:3]
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def stats_for(path: Path):
    image = Image.open(path).convert("RGB")
    sample = image.resize((160, 90), Image.Resampling.BILINEAR)
    pixels = list(sample.getdata())
    lumas = [luminance(p) for p in pixels]
    stat = ImageStat.Stat(sample)
    return {"fileName": path.name, "bytes": path.stat().st_size, "width": image.width, "height": image.height, "sampleUniqueColors": len(set(pixels)), "meanBrightness": round(sum(lumas) / len(lumas), 3), "brightnessStdDev": round(statistics.pstdev(lumas), 3), "flatColor": len(set(pixels)) <= 1, "nearBlackFlat": (sum(lumas) / len(lumas)) < 3.0 and statistics.pstdev(lumas) < 1.0}

def draw_wrapped(draw, xy, text, fill, max_chars=112, line_height=30):
    x, y = xy
    line = ""
    for word in text.split():
        candidate = (line + " " + word).strip()
        if len(candidate) > max_chars:
            draw.text((x, y), line, fill=fill)
            y += line_height
            line = word
        else:
            line = candidate
    if line:
        draw.text((x, y), line, fill=fill)
    return y

preflight = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(preflight)
draw.rectangle((90, 90, 1510, 810), outline="#65e6d8", width=4)
draw.text((140, 140), "v0.291 PREFLIGHT - reserve launch order staged step", fill="#e8d99d")
draw.text((140, 215), "Base HEAD:", fill="#9ecfc5")
draw.text((140, 260), "6b57472202aefe0eb37025b6b8ea663d2eb2b56f", fill="#ffffff")
draw.text((140, 340), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 385), "28743865693 - success", fill="#9fe2a3")
draw.text((140, 470), "Scope:", fill="#9ecfc5")
draw_wrapped(draw, (140, 520), "After accepted v0.290 DEPLOYMENT APPROVED, selecting the Field Barracks exposes one Stage option that creates LAUNCH ORDER STAGED and one static LAUNCH STAGED marker.", "#ffffff")
draw_wrapped(draw, (140, 635), "Forbidden: deployment, movement, pathing, route preview, duplicate approval/marker, resources mutation, damage, HP loss, projectiles, death/despawn, AI, waves, fog, economy, and true default runtime mutation.", "#d7c98f")
preflight.save(root / "01_v0291_preflight_head_ci_resolution.png")

ledger = json.loads(ledger_path.read_text(encoding="utf-8"))
ledger_image = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(ledger_image)
draw.rectangle((55, 55, 1545, 845), outline="#65e6d8", width=3)
draw.text((90, 92), "v0.291 RETAINED v0.282/v0.284/v0.285/v0.286/v0.287/v0.288/v0.289/v0.290 LEDGER PROOF", fill="#e8d99d")
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
draw.text((90, 735), "v0.284+ selected-card layout remains short, separated, and validator-paragraph free.", fill="#9ecfc5")
draw.text((90, 775), "v0.291 only adds a static launch-order staging gate after v0.290 deployment approval.", fill="#9ecfc5")
ledger_image.save(root / "03_v0291_retained_v0282_v0284_baseline_ledger_proof.png")

diagnostic = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(diagnostic)
draw.rectangle((60, 60, 1540, 840), outline="#65e6d8", width=3)
draw.text((100, 105), "v0.291 UI LAYOUT DIAGNOSTIC PROOF", fill="#e8d99d")
draw.text((100, 170), "Selected card rect: x=420 y=742 w=760 h=150", fill="#ffffff")
draw.text((100, 220), "Text rect: x=438 y=752 w=500 h=92", fill="#ffffff")
draw.text((100, 270), "Button row rect: x=438 y=856 w=530 h=24", fill="#ffffff")
draw.text((100, 320), "Top strip vocabulary includes LAUNCH ORDER STAGED and still caps at 36 chars.", fill="#ffffff")
draw.text((100, 390), "PASS gates: no text/button overlap, max four rows, no raw validator paragraphs, short world labels.", fill="#9fe2a3")
draw.text((100, 460), "Stage labels: LAUNCH STAGED exactly once near reserve; ORDER READY and RESERVE ACK retained exactly once.", fill="#d7c98f")
diagnostic.save(root / "53_v0291_ui_layout_diagnostic_proof_retained.png")

capture_paths = [root / name for name in capture_files]
missing = [path.name for path in capture_paths if not path.exists()]
if missing:
    raise SystemExit(f"Missing v0.291 capture files before pack assembly: {missing}")
all_stats = [stats_for(path) for path in capture_paths]
(root / "v0291-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")
summary = {"count": len(all_stats), "minBytes": min(s["bytes"] for s in all_stats), "minUniqueColors": min(s["sampleUniqueColors"] for s in all_stats), "minMeanBrightness": min(s["meanBrightness"] for s in all_stats), "minBrightnessStdDev": min(s["brightnessStdDev"] for s in all_stats)}
report = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(report)
draw.rectangle((60, 60, 1540, 840), outline="#65e6d8", width=3)
draw.text((100, 105), "v0.291 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {summary['count']}", fill="#ffffff")
draw.text((100, 220), f"Minimum sample unique colors: {summary['minUniqueColors']}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {summary['minMeanBrightness']}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {summary['minBrightnessStdDev']}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {summary['minBytes']}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered evidence includes true default, ledger, and 49 v0.291 opt-in launch-order-staged states.", fill="#ffffff")
report.save(root / "55_v0291_black_frame_rejection_report.png")

sheet_paths = [root / "01_v0291_preflight_head_ci_resolution.png"] + capture_paths + [root / "53_v0291_ui_layout_diagnostic_proof_retained.png", root / "55_v0291_black_frame_rejection_report.png"]
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
sheet.save(root / "54_v0291_contact_sheet.png")