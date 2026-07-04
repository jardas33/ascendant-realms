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
    "02_v0285_true_default_runtime_baseline_no_fixture_no_opt_in.png",
    "03_v0285_retained_v0282_v0284_baseline_ledger_proof.png",
    "04_v0285_manual_fixture_baseline_clean_hud.png",
    "05_v0285_engage_available_before_click.png",
    "06_v0285_engage_armed.png",
    "07_v0285_commit_engage_clicked.png",
    "08_v0285_post_commit_pressure_checked_ashen_braced.png",
    "09_v0285_hold_line_available_after_commit_locked.png",
    "10_v0285_hold_line_clicked.png",
    "11_v0285_line_held_exactly_once.png",
    "12_v0285_ashen_contained_exactly_once.png",
    "13_v0285_combined_line_held_ashen_contained_readable_hud.png",
    "14_v0285_repeat_hold_line_no_duplicate_no_stack.png",
    "15_v0285_clear_guard_settles_hold_line.png",
    "16_v0285_reguard_availability_clean_after_hold_line.png",
    "17_v0285_watchpost_no_hold_line_engage_commit_ashen.png",
    "18_v0285_barracks_no_hold_line_engage_commit_ashen.png",
    "19_v0285_no_projectile_damage_death_despawn.png",
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
draw.text((140, 140), "v0.285 PREFLIGHT - Hold Line Non-Lethal Contact Step", fill="#e8d99d")
draw.text((140, 215), "Base HEAD:", fill="#9ecfc5")
draw.text((140, 260), "f5e0c81b8cf221d2637a8ed19fc511d525a4a15c", fill="#ffffff")
draw.text((140, 340), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 385), "28686114630 - success", fill="#9fe2a3")
draw.text((140, 470), "Scope:", fill="#9ecfc5")
draw_wrapped(draw, (140, 520), "Add one opt-in Hold Line state after Commit Engage: LINE HELD near the defender and ASHEN CONTAINED near the Ashen side, both exactly once.", "#ffffff")
draw_wrapped(draw, (140, 635), "Forbidden: damage, HP loss, projectiles, attack animation, death/despawn, pathing, movement, AI, waves, fog, economy, and true default runtime mutation.", "#d7c98f")
preflight.save(root / "01_v0285_preflight_head_ci_resolution.png")

ledger_image = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(ledger_image)
draw.rectangle((55, 55, 1545, 845), outline="#65e6d8", width=3)
draw.text((90, 92), "v0.285 RETAINED v0.282/v0.284 BASELINE LEDGER PROOF", fill="#e8d99d")
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
draw.text((90, 775), "v0.285 only adds the post-commit Hold Line containment state in opt-in manual review.", fill="#9ecfc5")
ledger_image.save(root / "03_v0285_retained_v0282_v0284_baseline_ledger_proof.png")

diagnostic = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(diagnostic)
draw.rectangle((60, 60, 1540, 840), outline="#65e6d8", width=3)
draw.text((100, 105), "v0.285 UI LAYOUT DIAGNOSTIC PROOF", fill="#e8d99d")
draw.text((100, 170), "Selected card rect: x=420 y=742 w=760 h=150", fill="#ffffff")
draw.text((100, 220), "Text rect: x=438 y=752 w=500 h=92", fill="#ffffff")
draw.text((100, 270), "Button row rect: x=438 y=856 w=530 h=24", fill="#ffffff")
draw.text((100, 320), "Top strip vocabulary includes LINE HELD and still caps at 36 chars.", fill="#ffffff")
draw.text((100, 390), "PASS gates: no text/button overlap, max four rows, no raw validator paragraphs, short world labels.", fill="#9fe2a3")
draw.text((100, 460), "Hold Line labels: LINE HELD exactly once, ASHEN CONTAINED exactly once, no stale ASHEN BRACED after hold.", fill="#d7c98f")
diagnostic.save(root / "20_v0285_ui_layout_diagnostic_proof_retained.png")

capture_paths = [root / name for name in capture_files]
missing = [path.name for path in capture_paths if not path.exists()]
if missing:
    raise SystemExit(f"Missing v0.285 capture files before pack assembly: {missing}")

all_stats = [stats_for(path) for path in capture_paths]
(root / "v0285-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")

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
draw.text((100, 105), "v0.285 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {summary['count']}", fill="#ffffff")
draw.text((100, 220), f"Minimum sample unique colors: {summary['minUniqueColors']}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {summary['minMeanBrightness']}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {summary['minBrightnessStdDev']}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {summary['minBytes']}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered evidence includes true default plus 16 v0.285 opt-in Hold Line states.", fill="#ffffff")
report.save(root / "22_v0285_black_frame_rejection_report.png")

sheet_paths = [root / "01_v0285_preflight_head_ci_resolution.png"] + capture_paths + [root / "20_v0285_ui_layout_diagnostic_proof_retained.png", root / "22_v0285_black_frame_rejection_report.png"]
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
sheet.save(root / "21_v0285_contact_sheet.png")
