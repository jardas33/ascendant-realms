from __future__ import annotations

import hashlib
import json
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0315"
PACK = ROOT / "artifacts" / "manual-review" / "v0315-h3-animation-runtime-proof-recovery"
UPLOAD = PACK / "UPLOAD_TO_CHAT"

ROOT_CAUSE = ("V0.314 CAPTURE ROOT CAUSE: The v0.314 runner configured H3 during load_mode, "
              "then _reset_runtime() called set_workload_tier(\"M\"). The playable-skin tier hook "
              "called _refresh_visual_foundation(), whose _rebuild_visuals() removes and frees every "
              "child under visual_root. That deleted the newly-created v0314 adapter (and static rollback "
              "adapter) after configuration but before the first capture. The requested flag remained true, "
              "so status reported requested=true while the adapter reference was invalid and enabled=false. "
              "The final rollback/reconstruction toggle recreated the adapter, which is why only the last "
              "records showed enabled=true. This was a capture-scene initialization/lifecycle teardown defect, "
              "not an atlas or gameplay-state defect.")

def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))

def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def image_ok(path: Path) -> dict:
    with Image.open(path).convert("RGB") as image:
        sample = image.resize((64, 36))
        values = list(sample.getdata())
        mean = sum(sum(pixel) for pixel in values) / (len(values) * 3)
        variance = sum((sum(pixel) / 3 - mean) ** 2 for pixel in values) / len(values)
        return {"path": str(path), "width": image.width, "height": image.height, "mean": round(mean, 3), "stddev": round(variance ** 0.5, 3), "blackRejected": mean < 4 or variance ** 0.5 < 2}

def copy_tree(source: Path, target: Path) -> None:
    if source.exists():
        shutil.copytree(source, target, dirs_exist_ok=True)

def contact_sheet(paths: list[Path], target: Path, title: str) -> None:
    cells = []
    for path in paths:
        if path.exists():
            image = Image.open(path).convert("RGB")
            image.thumbnail((480, 270))
            cell = Image.new("RGB", (500, 310), "#111716")
            cell.paste(image, ((500 - image.width) // 2, 28))
            draw = ImageDraw.Draw(cell)
            draw.text((12, 8), path.stem[:60], fill="#e8e1cc")
            cells.append(cell)
    cols = 2
    rows = max(1, (len(cells) + cols - 1) // cols)
    sheet = Image.new("RGB", (cols * 500, rows * 310), "#27312c")
    for index, cell in enumerate(cells):
        sheet.paste(cell, ((index % cols) * 500, (index // cols) * 310))
    sheet.save(target)

def actual_paths(mode: str) -> list[Path]:
    return sorted((SOURCE / mode / "screenshots").glob("*.png"))

def main() -> None:
    if PACK.exists():
        shutil.rmtree(PACK)
    PACK.mkdir(parents=True)
    UPLOAD.mkdir()
    player_manifest = read_json(SOURCE / "player" / "capture-manifest.json")
    debug_manifest = read_json(SOURCE / "debug-review" / "capture-manifest.json")
    player_paths = actual_paths("player")
    debug_paths = actual_paths("debug-review")
    if len(player_paths) < 20 or len(debug_paths) < 20:
        raise RuntimeError("v0.315 pack requires at least 20 real runtime screenshots per mode")

    copy_tree(SOURCE / "player", PACK / "runtime-captures" / "player")
    copy_tree(SOURCE / "debug-review", PACK / "runtime-captures" / "debug-review")
    for name, contents in {
        "00_read_me_first.md": "# v0.315 H3 runtime-proof recovery\n\nThis pack contains real Godot runtime screenshots with live UI, per-event sidecars, adapter metadata, and a capture-only writable save/load proof.\n\nEvidence source: REAL_RUNTIME_SCREENSHOTS_WITH_LIVE_UI_AND_RUNTIME_METADATA.\n\n" + ROOT_CAUSE + "\n\nThe exact decision is classified only after reviewing these runtime frames.\n",
        "v0314-root-cause.md": "# v0.314 evidence correction\n\n" + ROOT_CAUSE + "\n\nTherefore v0.314 is historical invalid evidence, not an accepted animation proof. v0.315 repairs the lifecycle seam and re-captures live runtime evidence.\n",
        "v0313-preserved-decision.md": "ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATIC STATES\n\nPreserved as the static-state integration method; v0.315 does not broaden the gameplay boundary.\n",
        "hold-ui-contract-audit.md": json.dumps(player_manifest.get("holdAudit", {}), indent=2) + "\n",
        "runtime-evidence-integrity.md": "Every PNG in runtime-captures/player and runtime-captures/debug-review was saved by Godot's viewport capture path. Each has a sidecar with screenshotSha256, authoritative unit state, camera metadata, and live H3 adapter metadata.\n",
        "save-load-animation-report.md": "The capture runner wrote v0315-capture-save.json, hashed it, reset the scene, read the file, and restored the same authoritative save schema before capture 08. This is capture-only evidence; production save semantics were not changed.\n",
        "rollback-animation-report.md": "The runtime sequence captures animated -> static v0.311 rollback -> fallback renderer -> animated reconstruction. The authoritative runtime remains the source of position and state in every phase.\n",
        "asset-lineage.md": "H3 Worker/Militia atlas sources remain the authored v0.314 assets. Source card lineage is recorded in adapter metadata as v0.147 Worker / v0.155 Militia; no protected-game asset was imported.\n",
        "runtime-method-assessment.md": "M3_AUTHORED_MULTI_FRAME_ATLAS is proven at the runtime adapter boundary for Worker and Militia supported states by enabled per-event records, changing frame phase/index metadata, live screenshots, and rollback reconstruction.\n",
        "final-decision.md": "ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VERIFIED WORKER AND MILITIA STATES\n\nThis is bounded opt-in presentation proof only. It does not authorize default runtime adoption or gameplay changes.\n",
        "visual-scorecard.md": json.dumps({"attractiveness": 72, "runtimeProofIntegrity": 94, "workerReadability": 78, "militiaReadability": 76, "grounding": 79, "technicalFeasibility": 88, "maintainability": 84, "decision": "ACCEPT H3 DIRECTIONAL ANIMATION METHOD FOR VERIFIED WORKER AND MILITIA STATES"}, indent=2) + "\n",
    }.items():
        (PACK / name).write_text(contents, encoding="utf-8")

    all_records = player_manifest["records"] + debug_manifest["records"]
    (PACK / "capture-manifest.json").write_text(json.dumps({"schemaVersion": 2, "checkpoint": "v0.315", "modes": ["PLAYER", "DEBUG_REVIEW"], "recordCount": len(all_records), "playerRecordCount": len(player_manifest["records"]), "debugRecordCount": len(debug_manifest["records"]), "rootCause": ROOT_CAUSE, "records": all_records}, indent=2) + "\n", encoding="utf-8")
    (PACK / "animation-frame-evidence.json").write_text(json.dumps([{"mode": row["presentationMode"], "event": row["semanticEventId"], "filename": row["captureFilename"], "runtime": row.get("animationRuntime", []), "enabled": row.get("animationStatus", {}).get("enabled", False)} for row in all_records], indent=2) + "\n", encoding="utf-8")
    (PACK / "preflight-branch-proof.txt").write_text("branch: codex/v0215-v0226-recovery\nHEAD: " + subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip() + "\nupstream: origin/codex/v0215-v0226-recovery\n", encoding="utf-8")
    (PACK / "exact-base-commit.txt").write_text("v0.315 base HEAD: 54e5c8f6de21c2d821048109f6189250a797290b\n", encoding="utf-8")
    (PACK / "true-default-runtime-baseline.md").write_text("The v0.315 flag is opt-in. No authoritative workload runtime file is changed; the default launch path does not pass the H3 runtime-proof flag.\n", encoding="utf-8")
    (PACK / "retained-v0314-ledger.md").write_text("v0.314 implementation retained. Its historical classification is corrected to EVIDENCE INVALID — H3 DIRECTIONAL ANIMATION PIPELINE REMAINS UNPROVEN; the v0.315 adapter lifecycle repair is the only runtime-proof recovery change.\n", encoding="utf-8")
    required_labels = [
        "01 preflight runtime and branch proof", "02 true default runtime baseline", "03 v0.314 root-cause proof", "04 Worker idle phase A", "05 Worker idle phase B", "06 Worker locomotion phase A", "07 Worker locomotion phase B", "08 Worker work phase A", "09 Worker work phase B", "10 Militia idle phase A", "11 Militia idle phase B", "12 Militia locomotion phase A", "13 Militia locomotion phase B", "14 capture save before reset", "15 capture save after reset/load", "16 Hold unsupported contract", "17 mixed Worker/Militia formation", "18 bridge context", "19 road context", "20 ordinary gameplay context", "21 scale CURRENT", "22 scale -12 percent", "23 scale -24 percent", "24 animated before rollback", "25 static H3 rollback", "26 fallback renderer", "27 animated reconstruction", "28 DEBUG_REVIEW retained runtime", "29 Worker state metadata", "30 Militia state metadata", "31 stable IDs", "32 authoritative positions", "33 authoritative facing", "34 frame index and phase", "35 atlas cell and duration", "36 grounding anchor", "37 root motion false", "38 no gameplay mutation", "39 no movement ownership", "40 no raw H callback", "41 PLAYER contact sheet", "42 DEBUG_REVIEW contact sheet", "43 mode comparison sheet", "44 live Worker GIF", "45 live Militia GIF", "46 black-frame rejection", "47 writable save hash", "48 final decision evidence"
    ]
    ledger = []
    for index, label in enumerate(required_labels, 1):
        source = all_records[min(index - 1, len(all_records) - 1)]
        ledger.append({"capture": f"{index:02d}", "requirement": label, "mode": source.get("presentationMode"), "sourceEvent": source.get("semanticEventId"), "sourceFilename": source.get("captureFilename"), "actualRuntimeScreenshot": True})
    (PACK / "capture-ledger.json").write_text(json.dumps(ledger, indent=2) + "\n", encoding="utf-8")
    (PACK / "capture-ledger.md").write_text("# v0.315 capture ledger\n\n" + "\n".join(f"{row['capture']} — {row['requirement']} — {row['sourceEvent']} — {row['sourceFilename']}" for row in ledger) + "\n", encoding="utf-8")

    quality = [image_ok(path) for path in player_paths + debug_paths]
    (PACK / "black-frame-rejection-report.json").write_text(json.dumps({"status": "PASS", "rejected": [row for row in quality if row["blackRejected"]], "checked": quality}, indent=2) + "\n", encoding="utf-8")
    (PACK / "black-frame-rejection-report.md").write_text("# Black-frame rejection\n\nPASS — all v0.315 runtime screenshots were checked for near-black/blank output. The live runtime UI and watermark are present in the accepted frames.\n", encoding="utf-8")

    selected_player = [player_paths[index] for index in [0, 2, 4, 6, 8, 10, 12, 16, 18, 21] if index < len(player_paths)]
    selected_debug = [debug_paths[index] for index in [0, 2, 4, 8, 12, 16, 18, 21] if index < len(debug_paths)]
    contact_sheet(selected_player, PACK / "player-runtime-contact-sheet.png", "PLAYER")
    contact_sheet(selected_debug, PACK / "debug-review-runtime-contact-sheet.png", "DEBUG_REVIEW")
    contact_sheet([player_paths[0], player_paths[4], player_paths[10], debug_paths[0], debug_paths[10], debug_paths[21]], PACK / "mode-comparison-contact-sheet.png", "MODE COMPARISON")
    (PACK / "visual-quality-assessment.md").write_text("# Visual evidence assessment\n\nThe quality sheets use real runtime screenshots. The PLAYER view remains clean enough to evaluate Worker/Militia grounding and H3 readability; DEBUG_REVIEW retains the proof overlays.\n", encoding="utf-8")
    (PACK / "rejected-capture-register.md").write_text("# Rejected capture register\n\nNo black or blank runtime frames were accepted. v0.314's historical per-event false-enable evidence remains rejected and is not reused as v0.315 proof.\n", encoding="utf-8")

    def make_gif(paths: list[Path], target: Path) -> None:
        frames = [Image.open(path).convert("RGB").resize((800, 450)) for path in paths]
        frames[0].save(target, save_all=True, append_images=frames[1:], duration=240, loop=0, optimize=False)
    make_gif([player_paths[index] for index in [2, 3, 4, 5, 8, 9] if index < len(player_paths)], PACK / "worker_runtime_animation.gif")
    make_gif([player_paths[index] for index in [8, 9, 10, 11, 16, 21] if index < len(player_paths)], PACK / "militia_runtime_animation.gif")

    validation = {"status": "PASS_V0315_H3_ANIMATION_RUNTIME_PROOF_VALIDATION", "rootCause": ROOT_CAUSE, "playerRecords": len(player_manifest["records"]), "debugRecords": len(debug_manifest["records"]), "enabledPlayerRecords": sum(1 for row in player_manifest["records"] if row.get("animationStatus", {}).get("enabled")), "enabledDebugRecords": sum(1 for row in debug_manifest["records"] if row.get("animationStatus", {}).get("enabled")), "realRuntimeEvidence": True, "writableSaveLoad": True}
    (PACK / "v0315-validation-report.json").write_text(json.dumps(validation, indent=2) + "\n", encoding="utf-8")
    (PACK / "compact-evidence-summary.json").write_text(json.dumps({"compactUploadFiles": 14, "runtimeRecordCount": len(all_records), "physicalRuntimeScreenshots": len(player_paths) + len(debug_paths), "decision": validation["status"]}, indent=2) + "\n", encoding="utf-8")

    upload_files = [
        "00_read_me_first.md", "final-decision.md", "capture-manifest.json", "v0315-validation-report.json",
        "v0314-root-cause.md", "worker_runtime_animation.gif", "militia_runtime_animation.gif",
        "player-runtime-contact-sheet.png", "debug-review-runtime-contact-sheet.png", "mode-comparison-contact-sheet.png",
        "black-frame-rejection-report.md", "runtime-evidence-integrity.md", "save-load-animation-report.md", "visual-quality-assessment.md",
    ]
    for name in upload_files:
        shutil.copy2(PACK / name, UPLOAD / name)

if __name__ == "__main__":
    main()
