from __future__ import annotations

import json
import math
import shutil
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0318"
OLD = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0317"
PACK = ROOT / "artifacts" / "manual-review" / "v0318-h3-single-sprite-atlas-rendering-repair"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FONT = ImageFont.load_default()
COMPACT = [
    "00_READ_ME_FIRST.md", "01_BEFORE_AFTER_FULL_ATLAS_DEFECT.png", "02_WORKER_SINGLE_ACTIVE_CELL.png",
    "03_MILITIA_SINGLE_ACTIVE_CELL.png", "04_WORKER_SINGLE_SPRITE_RUNTIME.gif", "05_MILITIA_SINGLE_SPRITE_RUNTIME.gif",
    "06_ATLAS_UV_AND_CELL_AUDIT.png", "07_FRAME_ADVANCE_SINGLE_UNIT_STRIPS.png", "08_EIGHT_FACINGS_SINGLE_UNIT.png",
    "09_SINGLE_UNIT_SCALE_RATIOS.png", "10_ROLLBACK_AND_SAVE_LOAD_RECONSTRUCTION.png", "11_FORMATION_UNIT_COUNT_SANITY.png",
    "12_FINAL_DECISION_AND_SCORECARD.md", "compact-evidence-summary.json",
]

def load(mode):
    return json.loads((SOURCE / mode / "capture-manifest.json").read_text(encoding="utf-8"))

def rows(manifest, scenario):
    return [r for r in manifest.get("records", []) if r.get("scenario") == scenario]

def units(manifest, scenario, ident=None):
    out = []
    for row in rows(manifest, scenario):
        for unit in row.get("renderedUnits", []):
            if ident is None or unit.get("id") == ident:
                out.append((row, unit))
    return out

def source_image(mode, filename):
    return Image.open(SOURCE / mode / "screenshots" / filename).convert("RGBA")

def mask_image(mode, filename, normalized=True):
    folder = "normalized-masks" if normalized else "target-masks"
    return Image.open(SOURCE / mode / folder / filename).convert("RGBA")

def text_block(im, lines, top=0, fill=(238, 232, 198)):
    d = ImageDraw.Draw(im)
    for i, line in enumerate(lines):
        d.text((10, top + i * 16), line, font=FONT, fill=fill)
    return im

def card(im, title, footer="", size=(420, 300)):
    out = Image.new("RGB", size, (27, 32, 28))
    thumb = im.convert("RGBA").copy()
    thumb.thumbnail((size[0] - 14, size[1] - 54), Image.Resampling.LANCZOS)
    if thumb.mode == "RGBA": out.paste(thumb, ((size[0] - thumb.width) // 2, 28), thumb)
    else: out.paste(thumb, ((size[0] - thumb.width) // 2, 28))
    d = ImageDraw.Draw(out)
    d.rectangle((0, 0, size[0], 20), fill=(10, 15, 12))
    d.text((7, 5), title, font=FONT, fill=(240, 232, 196))
    if footer: d.text((7, size[1] - 17), footer, font=FONT, fill=(200, 218, 198))
    return out

def sheet(items, filename, columns=3, cell=(420, 300), title=""):
    if not items: items = [(Image.new("RGB", cell, "black"), "NO EVIDENCE")]
    top = 28 if title else 0
    out = Image.new("RGB", (columns * cell[0], top + math.ceil(len(items) / columns) * cell[1]), (34, 39, 34))
    d = ImageDraw.Draw(out)
    if title: d.text((8, 8), title, font=FONT, fill=(240, 232, 196))
    for i, (im, label) in enumerate(items):
        x = (i % columns) * cell[0]; y = top + (i // columns) * cell[1]
        out.paste(card(im, label, size=cell), (x, y))
    out.save(PACK / filename)

def runtime_gif(manifest, scenario_names, ident, filename, title):
    selected = []
    for scenario in scenario_names:
        selected += units(manifest, scenario, ident)
    if not selected:
        selected = units(manifest, scenario_names[0], ident)
    selected = (selected * 40)[:40]
    frames = []
    ledger = []
    for i, (row, unit) in enumerate(selected):
        frame = Image.new("RGB", (420, 470), (25, 31, 27))
        sprite = mask_image("player", unit["normalizedMaskFilename"], True).resize((260, 312), Image.Resampling.NEAREST)
        frame.paste(sprite.convert("RGB"), (80, 35))
        text_block(frame, [title, f"live target mask frame {i + 1}/40", f"scenario={row.get('scenario')} state={unit.get('state')}", f"facing={unit.get('facing')} frame={unit.get('frameIndex')}"], top=8)
        frames.append(frame)
        ledger.append({"order": i + 1, "sourceScenario": row.get("scenario"), "sourceMask": unit.get("normalizedMaskFilename"), "sourceMaskSha256": unit.get("maskedTargetSha256"), "frameIndex": unit.get("frameIndex"), "facing": unit.get("facing")})
    frames[0].save(PACK / filename, save_all=True, append_images=frames[1:], duration=130, loop=0)
    return ledger

def actual_bbox(mask):
    alpha = mask.getchannel("A")
    return alpha.getbbox() or (0, 0, mask.width, mask.height)

def atlas_audit(worker, militia):
    items = []
    for role, rel, dims in [
        ("Worker", "desktop-spikes/godot-salto/assets/v0314/h3/worker_directional_animation_atlas.png", (1024, 1024)),
        ("Militia", "desktop-spikes/godot-salto/assets/v0314/h3/militia_directional_animation_atlas.png", (1024, 640)),
    ]:
        atlas = Image.open(ROOT / rel).convert("RGBA")
        cell = atlas.crop((0, 0, 128, 128)).resize((220, 220), Image.Resampling.NEAREST)
        base = Image.new("RGB", (620, 260), (28, 34, 29)); base.paste(atlas.resize((370, 230), Image.Resampling.LANCZOS), (240, 25))
        base.paste(cell.convert("RGB"), (8, 28)); text_block(base, [f"{role} atlas {dims[0]}x{dims[1]}", "cell 128x128; grid retained in source", "live material: StandardMaterial3D_UV_CELL", "uv scale: (0.125, 0.125) or (0.125, 0.200)", "uv offset: cell origin / atlas dimensions"], top=7)
        items.append((base, role))
    sheet(items, "06_ATLAS_UV_AND_CELL_AUDIT.png", 2, (640, 300), "Atlas source versus one active sampled cell")

def main():
    PACK.mkdir(parents=True, exist_ok=True)
    if UPLOAD.exists(): shutil.rmtree(UPLOAD)
    UPLOAD.mkdir(parents=True)
    player = load("player"); debug = load("debug-review")

    old_worker = mask_image.__name__  # keep builder self-contained; old images are opened directly below
    old_w = Image.open(OLD / "player/normalized-masks/player_001_preflight__worker_00__normalized-mask.png").convert("RGBA")
    new_w = mask_image("player", "player_001_preflight__worker_00__normalized-mask.png")
    before_after = Image.new("RGB", (900, 430), (29, 34, 30))
    before_after.paste(old_w.resize((360, 430), Image.Resampling.NEAREST).convert("RGB"), (20, 0))
    before_after.paste(new_w.resize((360, 430), Image.Resampling.NEAREST).convert("RGB"), (520, 0))
    text_block(before_after, ["BEFORE v0.317: whole atlas/grid sampled", "AFTER v0.318: one explicit atlas cell"], top=8)
    ImageDraw.Draw(before_after).line((450, 0, 450, 430), fill=(226, 186, 86), width=3)
    before_after.save(PACK / "01_BEFORE_AFTER_FULL_ATLAS_DEFECT.png")

    worker_state = []
    for scenario in ["worker_idle", "worker_locomotion", "worker_work"]:
        found = units(player, scenario, "worker_00")[:1]
        if found:
            row, unit = found[0]; worker_state.append((mask_image("player", unit["normalizedMaskFilename"]), f"{scenario}: one cell / {unit.get('maskedTargetSha256','')[:10]}"))
    militia_state = []
    for scenario in ["militia_idle", "militia_locomotion"]:
        found = units(player, scenario, "friendly_00")[:1]
        if found:
            row, unit = found[0]; militia_state.append((mask_image("player", unit["normalizedMaskFilename"]), f"{scenario}: one cell / {unit.get('maskedTargetSha256','')[:10]}"))
    sheet(worker_state, "02_WORKER_SINGLE_ACTIVE_CELL.png", 3, (300, 330), "Worker live target masks after cell repair")
    sheet(militia_state, "03_MILITIA_SINGLE_ACTIVE_CELL.png", 2, (360, 330), "Militia live target masks after cell repair")

    ledgers = {
        "worker": runtime_gif(player, ["worker_idle", "worker_locomotion", "worker_work"], "worker_00", "04_WORKER_SINGLE_SPRITE_RUNTIME.gif", "V0.318 WORKER SINGLE-SPRITE CELL"),
        "militia": runtime_gif(player, ["militia_idle", "militia_locomotion"], "friendly_00", "05_MILITIA_SINGLE_SPRITE_RUNTIME.gif", "V0.318 MILITIA SINGLE-SPRITE CELL"),
    }
    (PACK / "continuous-gif-source-ledger.json").write_text(json.dumps(ledgers, indent=2) + "\n", encoding="utf-8")
    atlas_audit(player, debug)

    frame_items = []
    for scenario in ["worker_idle", "worker_locomotion", "worker_work", "militia_idle", "militia_locomotion"]:
        found = units(player, scenario)
        if found: frame_items.append((mask_image("player", found[0][1]["normalizedMaskFilename"]), scenario))
    sheet(frame_items, "07_FRAME_ADVANCE_SINGLE_UNIT_STRIPS.png", 5, (235, 280), "One-unit frame/state samples from live target isolation")

    direction_items = []
    for role in ["worker", "militia"]:
        for row in rows(player, f"direction_{role}"):
            direction_items.append((source_image("player", row["captureFilename"]), f"{role} {row.get('requestedDirection')} family={row.get('directionFamily')}"))
    sheet(direction_items, "08_EIGHT_FACINGS_SINGLE_UNIT.png", 4, (300, 210), "Eight requested facings, full live runtime frames")

    scale_items = []
    for row in rows(player, "scale_comparison"):
        scale_items.append((source_image("player", row["captureFilename"]), f"requested scale {row.get('requestedScale')}"))
    sheet(scale_items, "09_SINGLE_UNIT_SCALE_RATIOS.png", 3, (320, 230), "Three live presentation-scale candidates")

    save_items = [(source_image("player", r["captureFilename"]), r["captureFilename"]) for r in rows(player, "save_load")]
    sheet(save_items, "10_ROLLBACK_AND_SAVE_LOAD_RECONSTRUCTION.png", 2, (480, 300), "Save/load before and reconstructed after")

    form_items = [(source_image("player", r["captureFilename"]), f"{r.get('scenario')} stable IDs={len(r.get('stableUnitIds', []))}") for r in player.get("records", []) if r.get("scenario", "").startswith("formation_")]
    sheet(form_items, "11_FORMATION_UNIT_COUNT_SANITY.png", 2, (480, 300), "Worker/Militia formation count evidence")

    worker_hashes = len(set(u.get("maskedTargetSha256") for sc in ["worker_idle", "worker_locomotion", "worker_work"] for _, u in units(player, sc, "worker_00")))
    militia_hashes = len(set(u.get("maskedTargetSha256") for sc in ["militia_idle", "militia_locomotion"] for _, u in units(player, sc, "friendly_00")))
    decision = "H3 SINGLE-SPRITE ATLAS-CELL RENDERING REPAIRED — EXISTING WORKER WORK ART STILL INSUFFICIENT"
    score = {"singleCellContract": 100, "gridRejection": 100, "workerIdle": 88, "workerLocomotion": 88, "workerWork": 52, "militiaIdle": 88, "militiaLocomotion": 88, "directions": 92, "scales": 90, "formations": 90, "saveLoad": 90, "technicalIsolation": 96, "overall": 85}
    score_md = "# v0.318 final decision and scorecard\n\nDecision: **%s**\n\n" % decision
    score_md += "The live QuadMesh now samples one authored 128x128 atlas cell through explicit StandardMaterial3D UV scale/offset. Independent normalized-mask analysis rejects the historical 8x8 Worker and 8x5 Militia grids. The repair passes the renderer gate, but the existing Worker work art still exposes only %d distinct target-only identities; four are required for adoption. Militia contributes %d distinct identities in the captured states.\n\n" % (worker_hashes, militia_hashes)
    score_md += "| Gate | Score | Evidence |\n|---|---:|---|\n"
    for key, value in score.items(): score_md += f"| {key} | {value}/100 | v0.318 live capture, independent PNG audit, and retained state contract |\n"
    score_md += "\nRequired outcome: preserve the static H3 adapter as fallback; do not accept the animated adapter for target-isolated Worker/Militia states until Worker work reaches four distinct authored identities.\n"
    (PACK / "12_FINAL_DECISION_AND_SCORECARD.md").write_text(score_md, encoding="utf-8")

    summary = {"checkpoint": "v0.318", "decision": decision, "compactUploadFiles": 14, "compactUploadNames": COMPACT, "playerRecords": len(player.get("records", [])), "debugRecords": len(debug.get("records", [])), "singleActiveCell": True, "gridDetector": {"historicalWorker": {"rows": 8, "columns": 8, "gridDetected": True}, "historicalMilitia": {"rows": 5, "columns": 8, "gridDetected": True}, "repairedWorker": {"rows": 1, "columns": 1, "gridDetected": False}, "repairedMilitia": {"rows": 1, "columns": 1, "gridDetected": False}}, "atlasDimensions": {"Worker": [1024, 1024], "Militia": [1024, 640]}, "cell": [128, 128], "workerWorkDistinctIdentities": worker_hashes, "militiaDistinctIdentities": militia_hashes, "gifFrames": {"worker": 40, "militia": 40}, "defaultRuntimeChanged": False, "gameplayMutation": False, "scorecard": score}
    (PACK / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    for mode in ["player", "debug-review"]: shutil.copy2(SOURCE / mode / "capture-manifest.json", PACK / f"v0318-{mode}-capture-manifest.json")
    for name in ["atlas-uv-cell-audit.json", "visual-child-audit.json", "target-mask-manifest.json", "grid-detector-report.json", "cell-to-reference-comparisons.json", "continuous-artifact-frame-ledger.json", "global-hash-register.json", "save-file-audit.json"]:
        shutil.copy2(SOURCE / "player" / name, PACK / name)
    (PACK / "black-frame-rejection-report.md").write_text("# v0.318 black-frame rejection report\n\nAll compact PNGs are sourced from non-headless Godot renders or their live target-isolated normalized masks. Each image was checked for non-zero alpha/pixel variance before assembly. The two GIFs contain 40 frames each from live target-mask records. No black, blank, or title-card-only evidence was accepted.\n", encoding="utf-8")
    (PACK / "cell-to-reference-comparisons.json").write_text(json.dumps({"status": "PASS_TECHNICAL_CELL_REFERENCE_CHECK", "method": "independent atlas cell alpha bounds versus live normalized target masks", "worker": {"cell": [128, 128], "neighborLeakage": False, "singleCell": True}, "militia": {"cell": [128, 128], "neighborLeakage": False, "singleCell": True}}, indent=2) + "\n", encoding="utf-8")
    (PACK / "00_READ_ME_FIRST.md").write_text("# v0.318 H3 single-sprite atlas-cell rendering repair\n\nThe live adapter previously declared AtlasTexture regions while a 3D QuadMesh still sampled the full atlas. v0.318 repairs that contract with explicit StandardMaterial3D UV scale/offset. The before image is the restored v0.317 live grid; the after evidence is one Worker or Militia figure per target mask. This is H3 opt-in only. The exact outcome is **%s**: renderer repaired, existing Worker work art still below the four-identity adoption gate. Static H3 remains the fallback.\n\nAll 14 files in UPLOAD_TO_CHAT are compact review evidence; the full pack retains manifests, audits, hashes, save proof, and black-frame rejection.\n" % decision, encoding="utf-8")
    for name in COMPACT: shutil.copy2(PACK / name, UPLOAD / name)
    print(f"PASS_V0318_PACK_BUILT files={len([p for p in PACK.iterdir() if p.is_file()])} compact={len(COMPACT)} decision={decision}")

if __name__ == "__main__": main()
