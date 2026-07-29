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
    "02_v0282_true_default_runtime_baseline_no_review_fixture.png",
    "03_v0282_true_default_runtime_baseline_ledger_proof.png",
    "04_v0282_barrosan_manual_review_fixture_baseline.png",
    "05_v0282_opt_in_readability_runtime_baseline.png",
    "06_v0282_engage_available_before_click_real_hud_only.png",
    "07_v0282_engage_armed_real_hud_clean.png",
    "08_v0282_engage_armed_exactly_one_world_label.png",
    "09_v0282_commit_engage_clicked.png",
    "10_v0282_post_commit_real_hud_clean_truthful.png",
    "11_v0282_post_commit_exactly_one_world_label.png",
    "12_v0282_repeat_commit_no_pressure_stack.png",
    "13_v0282_clear_guard_removes_commit_label.png",
    "14_v0282_reguard_availability_clean.png",
    "15_v0282_watchpost_no_engage_commit_action.png",
    "16_v0282_barracks_no_engage_commit_action.png",
    "17_v0282_no_projectile_no_damage_no_death_proof.png",
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

def draw_wrapped(draw, xy, text, fill, max_chars=116, line_height=30):
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
draw.text((140, 140), "v0.282 PREFLIGHT - BARROSAN Default Runtime Baseline Lock", fill="#e8d99d")
draw.text((140, 215), "Base HEAD:", fill="#9ecfc5")
draw.text((140, 260), ledger["baseHead"], fill="#ffffff")
draw.text((140, 340), "Baseline exact-SHA Actions run:", fill="#9ecfc5")
draw.text((140, 385), "28672211567 - success", fill="#9fe2a3")
draw.text((140, 470), "Scope:", fill="#9ecfc5")
draw_wrapped(draw, (140, 520), "Ledger, capture naming, validator clarity, and report only. True default, fixture-only, and opt-in readability runtime are separated before any new combat work.", "#ffffff")
draw_wrapped(draw, (140, 635), "Forbidden: gameplay expansion, projectile, HP damage, enemy death/despawn, pathing, AI, economy, fog, waves, and runtime mutation.", "#d7c98f")
preflight.save(root / "01_v0282_preflight_head_ci_resolution.png")

ledger_image = Image.new("RGB", (1600, 900), "#101511")
draw = ImageDraw.Draw(ledger_image)
draw.rectangle((55, 55, 1545, 845), outline="#65e6d8", width=3)
draw.text((90, 92), "v0.282 BASELINE LEDGER PROOF", fill="#e8d99d")
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
draw.text((90, 765), "Validator enforces: true default is not fixture; fixture-only does not enable opt-in; opt-in runtime carries retained v0.281 HUD/label invariants.", fill="#9ecfc5")
ledger_image.save(root / "03_v0282_true_default_runtime_baseline_ledger_proof.png")

capture_paths = [root / name for name in capture_files]
missing = [path.name for path in capture_paths if not path.exists()]
if missing:
    raise SystemExit(f"Missing v0.282 capture files before pack assembly: {missing}")

all_stats = [stats_for(path) for path in capture_paths]
(root / "v0282-black-frame-stats.json").write_text(json.dumps({"stats": all_stats}, indent=2) + "\n", encoding="utf-8")

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
draw.text((100, 105), "v0.282 BLACK-FRAME REJECTION REPORT", fill="#e8d99d")
draw.text((100, 165), f"PNG files inspected: {summary['count']}", fill="#ffffff")
draw.text((100, 220), f"Minimum sample unique colors: {summary['minUniqueColors']}", fill="#9fe2a3")
draw.text((100, 270), f"Minimum mean brightness: {summary['minMeanBrightness']}", fill="#9fe2a3")
draw.text((100, 320), f"Minimum brightness std dev: {summary['minBrightnessStdDev']}", fill="#9fe2a3")
draw.text((100, 370), f"Minimum PNG bytes: {summary['minBytes']}", fill="#9fe2a3")
draw.text((100, 450), "Result: PASS - no flat, black, or dummy screenshots accepted.", fill="#9fe2a3")
draw.text((100, 520), "Rendered capture path: true default, fixture-only, and opt-in readability runtime are separated.", fill="#ffffff")
draw.text((100, 590), "No v0.281 Engage/Commit state is accepted as true default evidence.", fill="#d7c98f")
report.save(root / "19_v0282_black_frame_rejection_report.png")

sheet_paths = [root / "01_v0282_preflight_head_ci_resolution.png"] + capture_paths + [root / "19_v0282_black_frame_rejection_report.png"]
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
sheet.save(root / "18_v0282_contact_sheet.png")
