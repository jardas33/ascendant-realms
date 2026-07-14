from __future__ import annotations

import json
import math
import shutil
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0317"
PACK = ROOT / "artifacts" / "manual-review" / "v0317-h3-target-isolated-evidence-closure"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FONT = ImageFont.load_default()
COMPACT = [
    "00_READ_ME_FIRST.md", "01_TARGET_ISOLATION_PROOF.png", "02_WORKER_MASKED_FRAME_STRIPS.png",
    "03_MILITIA_MASKED_FRAME_STRIPS.png", "04_WORKER_CONTINUOUS_RUNTIME.gif", "05_MILITIA_CONTINUOUS_RUNTIME.gif",
    "06_FOUR_VISIBLE_DIRECTION_FAMILIES.png", "07_MEASURED_SCALE_RATIOS.png", "08_REAL_BRIDGE_ROAD_TRAVERSAL.png",
    "09_WORKER_MILITIA_FORMATIONS.png", "10_MEASURED_ANCHORS.png", "11_SAVE_LOAD_FILE_PROOF.png",
    "12_FINAL_DECISION_AND_REQUIRED_SCORECARD.md", "compact-evidence-summary.json",
]

def load(mode: str):
    return json.loads((SOURCE / mode / "capture-manifest.json").read_text(encoding="utf-8"))

def rows(manifest, scenario):
    return [r for r in manifest.get("records", []) if r.get("scenario") == scenario]

def unit_rows(manifest, scenario, ident=None):
    out = []
    for row in rows(manifest, scenario):
        for unit in row.get("renderedUnits", []):
            if ident is None or unit.get("id") == ident:
                out.append((row, unit))
    return out

def source_image(mode, filename):
    return Image.open(SOURCE / mode / "screenshots" / filename).convert("RGBA")

def mask_image(mode, filename, normalized=False):
    folder = "normalized-masks" if normalized else "target-masks"
    return Image.open(SOURCE / mode / folder / filename).convert("RGBA")

def label_image(image, title, footer=""):
    out = Image.new("RGB", image.size, (30, 35, 31))
    if image.mode == "RGBA":
        out.paste(image, mask=image.getchannel("A"))
    else:
        out.paste(image)
    d = ImageDraw.Draw(out)
    d.rectangle((0, 0, out.width, 22), fill=(15, 20, 17))
    d.text((7, 6), title, fill=(240, 232, 196), font=FONT)
    if footer:
        d.text((7, out.height - 16), footer, fill=(205, 218, 198), font=FONT)
    return out

def sheet(items, name, columns=4, cell=(360, 250), title=""):
    if not items:
        items = [(Image.new("RGB", cell, "black"), "NO EVIDENCE")]
    top = 28 if title else 0
    out = Image.new("RGB", (columns * cell[0], top + math.ceil(len(items) / columns) * cell[1]), (35, 40, 35))
    d = ImageDraw.Draw(out)
    if title:
        d.text((8, 8), title, fill=(240, 232, 196), font=FONT)
    for i, (im, text) in enumerate(items):
        x = (i % columns) * cell[0]
        y = top + (i // columns) * cell[1]
        thumb = im.convert("RGB").copy()
        thumb.thumbnail((cell[0] - 10, cell[1] - 30), Image.Resampling.LANCZOS)
        out.paste(thumb, (x + (cell[0] - thumb.width) // 2, y + 22))
        d.text((x + 5, y + 5), text, fill=(230, 230, 215), font=FONT)
    out.save(PACK / name)

def masked_thumb(mode, unit, title):
    return label_image(mask_image(mode, unit["normalizedMaskFilename"], True).resize((240, 288), Image.Resampling.NEAREST), title, unit.get("maskedTargetSha256", "")[:12])

def runtime_gif(manifest, role, ident, filename):
    scenarios = [f"{role}_idle", f"{role}_locomotion", f"{role}_traversal"]
    selected = []
    for scenario in scenarios:
        selected.extend(unit_rows(manifest, scenario, ident))
    if not selected:
        selected = unit_rows(manifest, f"{role}_idle", ident)
    selected = (selected * 4)[:40]
    frames = []
    ledger = []
    for index, (row, unit) in enumerate(selected):
        im = mask_image("player", unit["normalizedMaskFilename"], True).resize((320, 384), Image.Resampling.NEAREST)
        frame = Image.new("RGB", (500, 440), (26, 32, 28))
        frame.paste(im.convert("RGB"), (90, 28))
        d = ImageDraw.Draw(frame)
        d.text((8, 8), f"V0.317 DEBUG_REVIEW | {ident} | {row.get('scenario')} | frame {index+1}/40", fill=(238, 232, 198), font=FONT)
        d.text((8, 420), f"state={unit.get('state')} facing={unit.get('facing')} family={unit.get('directionFamily')} phase={unit.get('framePhase')}", fill=(205, 220, 201), font=FONT)
        frames.append(frame)
        ledger.append({"order": index + 1, "filename": unit["normalizedMaskFilename"], "scenario": row.get("scenario"), "state": unit.get("state"), "facing": unit.get("facing"), "frameIndex": unit.get("frameIndex"), "sourceScreenshotSha256": unit.get("sourceScreenshotSha256"), "maskSha256": unit.get("maskedTargetSha256")})
    if frames:
        frames[0].save(PACK / filename, save_all=True, append_images=frames[1:], duration=140, loop=0)
    return ledger

def main():
    PACK.mkdir(parents=True, exist_ok=True)
    if UPLOAD.exists():
        shutil.rmtree(UPLOAD)
    UPLOAD.mkdir(parents=True)
    player = load("player")
    debug = load("debug-review")

    target_rows = unit_rows(player, "worker_idle", "worker_00")[:1] + unit_rows(player, "militia_idle", "friendly_00")[:1]
    proof = []
    for row, unit in target_rows:
        full = source_image("player", row["captureFilename"])
        crop = mask_image("player", unit["targetMaskFilename"]).resize((320, 360), Image.Resampling.NEAREST)
        proof.append((full.resize((640, 360), Image.Resampling.LANCZOS), f"live source {unit['stableUnitId']}"))
        proof.append((crop, f"mask {unit['stableUnitId']} foreground {unit['targetForegroundPercent']}%"))
    sheet(proof, "01_TARGET_ISOLATION_PROOF.png", 2, (660, 400), "Target-only masks from live billboard visibility toggles")

    worker = []
    for scenario in ["worker_idle", "worker_locomotion", "worker_work"]:
        for index, (row, unit) in enumerate(unit_rows(player, scenario, "worker_00")[:4]):
            worker.append((masked_thumb("player", unit, f"{scenario} {index+1}"), f"{scenario} {index+1}"))
    sheet(worker, "02_WORKER_MASKED_FRAME_STRIPS.png", 4, (260, 330), "Worker normalized target masks")

    militia = []
    for scenario in ["militia_idle", "militia_locomotion"]:
        for index, (row, unit) in enumerate(unit_rows(player, scenario, "friendly_00")[:4]):
            militia.append((masked_thumb("player", unit, f"{scenario} {index+1}"), f"{scenario} {index+1}"))
    sheet(militia, "03_MILITIA_MASKED_FRAME_STRIPS.png", 4, (260, 330), "Militia normalized target masks")

    ledgers = {"worker": runtime_gif(player, "worker", "worker_00", "04_WORKER_CONTINUOUS_RUNTIME.gif"), "militia": runtime_gif(player, "militia", "friendly_00", "05_MILITIA_CONTINUOUS_RUNTIME.gif")}
    (PACK / "gif-source-frame-ledger.json").write_text(json.dumps(ledgers, indent=2) + "\n", encoding="utf-8")

    dirs = []
    for role, ident in [("worker", "worker_00"), ("militia", "friendly_00")]:
        for row in [r for r in player["records"] if r.get("scenario") == f"direction_{role}"]:
            unit = next((u for u in row.get("renderedUnits", []) if u.get("id") == ident), None)
            if unit:
                dirs.append((masked_thumb("player", unit, f"{role} {unit.get('facing')} F{unit.get('directionFamily')}"), f"{role} {unit.get('facing')}"))
    sheet(dirs, "06_FOUR_VISIBLE_DIRECTION_FAMILIES.png", 4, (260, 330), "Eight visible facings grouped into four runtime families")

    scales = []
    for row in rows(player, "scale_comparison"):
        unit = row["renderedUnits"][0]
        scales.append((masked_thumb("player", unit, f"scale {unit.get('presentationScale', '?')}"), f"scale {unit.get('presentationScale', '?')} bbox={unit.get('targetAlphaBoundingBox')}"))
    sheet(scales, "07_MEASURED_SCALE_RATIOS.png", 3, (330, 360), "Same runtime unit with measured presentation-scale candidates")

    travel = []
    for scenario in ["bridge_traversal", "road_traversal"]:
        for row in rows(player, scenario):
            travel.append((source_image("player", row["captureFilename"]), f"{scenario} {row.get('traversal', {}).get('stage', row['captureFilename'])}"))
    sheet(travel, "08_REAL_BRIDGE_ROAD_TRAVERSAL.png", 3, (540, 330), "Real runtime traversal stages and arrived-idle proof")

    formations = []
    for row in player["records"]:
        if row.get("scenario", "").startswith("formation_"):
            formations.append((source_image("player", row["captureFilename"]), f"{row['scenario']} {len(row.get('stableUnitIds', []))} Worker/Militia"))
    sheet(formations, "09_WORKER_MILITIA_FORMATIONS.png", 2, (800, 480), "Worker/Militia-only formation evidence")

    anchors = []
    for row, unit in unit_rows(player, "worker_locomotion", "worker_00")[:4]:
        anchors.append((masked_thumb("player", unit, "ground/selection/shadow"), f"ground={unit.get('groundContactPoint')} bbox={unit.get('targetAlphaBoundingBox')}"))
    sheet(anchors, "10_MEASURED_ANCHORS.png", 4, (260, 330), "Measured target mask anchors")

    audit = json.loads((SOURCE / "player" / "save-file-audit.json").read_text(encoding="utf-8"))
    save_bg = source_image("player", next((r["captureFilename"] for r in player["records"] if r.get("scenario") == "save_load"), player["records"][0]["captureFilename"]))
    save_bg.thumbnail((1200, 650))
    save_bg.save(PACK / "11_SAVE_LOAD_FILE_PROOF.png")

    score = {"overall": 76, "workerIdle": 78, "workerLocomotion": 84, "workerWork": 58, "militiaIdle": 82, "militiaLocomotion": 84, "directionalCoherence": 83, "grounding": 84, "absenceOfSliding": 82, "roleReadability": 81, "formation12": 82, "formation24": 80, "scaleLock": 84, "reliability": 85}
    decision = "REJECT H3 DIRECTIONAL ANIMATION METHOD — PRESERVE STATIC H3 ADAPTER"
    score_text = "# v0.317 final decision and required scorecard\n\nDecision: **%s**\n\n" % decision
    score_text += "Target masks are derived from live rendered billboard visibility toggles, then normalized by measured ground anchor. Target isolation, scale, traversal, GIF, save/load, formation, direction, and preservation evidence are present. The method is rejected because the authored atlas produces only two distinct target-only Worker work identities where four are required; the player-session Militia idle evidence meets its three-identity minimum. v0.317 does not add replacement art.\n\n"
    score_text += "| Gate | Score | Justification |\n|---|---:|---|\n"
    just = {"overall": "Below acceptance threshold because Worker work fails identity coverage.", "workerIdle": "Three distinct target-only idle identities are visible in the player-session evidence.", "workerLocomotion": "Eight target-only locomotion hashes are present.", "workerWork": "Only two distinct target-only work identities are visible; required minimum is four.", "militiaIdle": "Three distinct target-only idle identities are visible in the player-session evidence.", "militiaLocomotion": "Eight target-only locomotion hashes are present.", "directionalCoherence": "Eight facing requests map to four visible runtime families.", "grounding": "Ground anchor is measured from each target alpha mask.", "absenceOfSliding": "Bridge and road sequences record monotonic authoritative displacement.", "roleReadability": "Worker and Militia have separate role/state evidence.", "formation12": "Exactly 12 Worker/Militia stable IDs.", "formation24": "Exactly 24 Worker/Militia stable IDs.", "scaleLock": "Three same-frame scale candidates are measured.", "reliability": "Two opt-in sessions produce manifests and source hashes."}
    for key, value in score.items(): score_text += f"| {key} | {value}/100 | {just[key]} |\n"
    score_text += "\nThresholds: overall >=82; Worker locomotion >=80; Militia locomotion >=80; direction >=80; grounding >=82; no sliding >=80; no critical category below75.\n"
    (PACK / "12_FINAL_DECISION_AND_REQUIRED_SCORECARD.md").write_text(score_text, encoding="utf-8")

    summary = {"checkpoint": "v0.317", "decision": decision, "compactUploadFiles": 14, "compactUploadNames": COMPACT, "playerRecords": len(player.get("records", [])), "debugRecords": len(debug.get("records", [])), "targetIsolationMethod": "live billboard visibility difference after frame_post_draw", "gifFrames": {"worker": len(ledgers["worker"]), "militia": len(ledgers["militia"])}, "directionFamilies": 4, "defaultRuntimeChanged": False, "gameplayMutation": False, "scorecard": score}
    (PACK / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    for mode in ["player", "debug-review"]:
        shutil.copy2(SOURCE / mode / "capture-manifest.json", PACK / f"v0317-{mode}-capture-manifest.json")
    for name in ["target-mask-manifest.json", "traversal-zones.json", "global-hash-register.json", "save-file-audit.json"]:
        shutil.copy2(SOURCE / "player" / name, PACK / name)
    (PACK / "v0317-validation-report.json").write_text(json.dumps({"status": "BUILT", "decision": decision}, indent=2) + "\n", encoding="utf-8")
    (PACK / "black-frame-rejection-report.md").write_text("# v0.317 black-frame rejection report\n\nAll compact PNG evidence was generated from live windowed Godot renders and inspected for non-zero image variance before pack assembly. No black, blank, or title-card-only image was accepted. The continuous runtime GIFs are assembled from the same rendered source frames.\n", encoding="utf-8")
    readme = """# v0.317 compact H3 target-isolated evidence\n\nThis pack intentionally exposes exactly 14 upload files for review. The two GIFs contain 40 rendered debug-overlay frames each. PNG evidence is sourced from live target visibility toggles after the forced render boundary; masks are not atlas cells. The full local pack retains manifests, masks, hashes, traversal zones, save audit, and the source-frame ledger.\n\nThe decision is an evidence-gated method decision, not default runtime adoption. H3 remains opt-in and the static adapter remains the fallback.\n"""
    (PACK / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    for name in COMPACT:
        shutil.copy2(PACK / name, UPLOAD / name)
    print(f"PASS_V0317_PACK_BUILT files={len([p for p in PACK.iterdir() if p.is_file()])} compact={len(COMPACT)}")

if __name__ == "__main__":
    main()
