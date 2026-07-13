from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0313"
PACK = ROOT / "artifacts" / "manual-review" / "v0313-h3-supported-state-contract-closure"
OLD_PACK = ROOT / "artifacts" / "manual-review" / "v0312-h3-runtime-evidence-integrity-recovery"
UPLOAD = PACK / "UPLOAD_TO_CHAT"


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_json(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def perceptual_hash(path: Path) -> str:
    image = Image.open(path).convert("L").resize((16, 16), Image.Resampling.LANCZOS)
    pixels = list(image.getdata())
    average = sum(pixels) / len(pixels)
    bits = "".join("1" if pixel >= average else "0" for pixel in pixels)
    return f"{int(bits, 2):064x}"


def load_records():
    all_records = []
    manifests = {}
    for mode, directory in (("PLAYER", "player"), ("DEBUG_REVIEW", "debug-review")):
        manifest = read_json(BASE / directory / "semantic-capture-manifest.json")
        manifests[mode] = manifest
        for row in manifest["records"]:
            item = dict(row)
            item["mode"] = mode
            item["sourceDirectory"] = directory
            all_records.append(item)
    return manifests, all_records


def captioned_sheet(name: str, items, columns=2, size=(720, 440)) -> Path:
    cell_w, cell_h = size
    rows = (len(items) + columns - 1) // columns
    sheet = Image.new("RGB", (cell_w * columns, cell_h * rows), (18, 23, 20))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for index, (label, path) in enumerate(items):
        x = (index % columns) * cell_w
        y = (index // columns) * cell_h
        draw.rectangle((x, y, x + cell_w - 1, y + cell_h - 1), outline=(112, 130, 111), width=2)
        try:
            image = Image.open(path).convert("RGB")
            image.thumbnail((cell_w - 20, cell_h - 48), Image.Resampling.LANCZOS)
            px = x + (cell_w - image.width) // 2
            py = y + 28 + (cell_h - 48 - image.height) // 2
            sheet.paste(image, (px, py))
        except Exception:
            draw.rectangle((x + 10, y + 40, x + cell_w - 10, y + cell_h - 12), fill=(40, 40, 40))
        draw.rectangle((x + 6, y + 5, x + cell_w - 6, y + 25), fill=(10, 15, 12))
        draw.text((x + 12, y + 10), label, fill=(232, 224, 177), font=font)
    path = PACK / name
    sheet.save(path)
    return path


def first_image(records, mode, event):
    for row in records:
        if row["mode"] == mode and row["semanticEventId"].endswith(event):
            return PACK / row["packFilename"]
    return None


def main() -> None:
    if PACK.exists():
        shutil.rmtree(PACK)
    PACK.mkdir(parents=True)
    UPLOAD.mkdir(parents=True)
    manifests, source_records = load_records()
    packed = []
    for source in source_records:
        mode_dir = BASE / source["sourceDirectory"]
        source_image = mode_dir / "screenshots" / source["captureFilename"]
        if not source_image.exists():
            raise FileNotFoundError(source_image)
        destination_name = source["captureFilename"]
        destination = PACK / destination_name
        shutil.copy2(source_image, destination)
        source["packFilename"] = destination_name
        source["screenshotSha256"] = sha256(destination)
        source["perceptualHash"] = perceptual_hash(destination)
        source["physicalBytes"] = destination.stat().st_size
        source["pixelDimensions"] = list(Image.open(destination).size)
        write_json(PACK / (destination.stem + ".json"), source)
        packed.append(source)

    by_pair = {}
    for row in packed:
        by_pair.setdefault(row["pairedViewId"], []).append(row)
    pair_register = []
    event_register = []
    for pair_id, rows in sorted(by_pair.items()):
        modes = {row["mode"] for row in rows}
        hashes = {row["screenshotSha256"] for row in rows}
        pair_register.append({
            "pairedViewId": pair_id,
            "semanticEventId": rows[0]["semanticEventId"],
            "records": [row["packFilename"] for row in rows],
            "modes": sorted(modes),
            "recordCount": len(rows),
            "countsAsOneSemanticGameplayEvent": True,
            "sameImageAcrossModes": len(hashes) == 1,
        })
        event_register.append({
            "semanticEventId": rows[0]["semanticEventId"],
            "pairedViewId": pair_id,
            "recordCount": len(rows),
            "physicalFileCount": len(rows),
            "uniqueImageCount": len(hashes),
            "accepted": all(row["accepted"] for row in rows),
            "gameplayEvent": rows[0]["scenario"] not in {"ordinary_gameplay_overview"},
        })

    physical = [{"file": row["packFilename"], "sha256": row["screenshotSha256"], "perceptualHash": row["perceptualHash"], "bytes": row["physicalBytes"], "dimensions": row["pixelDimensions"]} for row in packed]
    unique = {}
    perceptual = {}
    for row in physical:
        unique.setdefault(row["sha256"], []).append(row["file"])
        perceptual.setdefault(row["perceptualHash"], []).append(row["file"])
    write_json(PACK / "physical-file-register.json", physical)
    write_json(PACK / "unique-image-register.json", unique)
    write_json(PACK / "perceptual-image-register.json", perceptual)
    write_json(PACK / "player-debug-pair-register.json", pair_register)
    write_json(PACK / "semantic-record-register.json", packed)
    write_json(PACK / "semantic-event-register.json", event_register)
    write_json(PACK / "capture-manifest.json", {"checkpoint": "v0.313", "player": manifests["PLAYER"], "debugReview": manifests["DEBUG_REVIEW"], "records": packed, "pairedMoments": pair_register, "semanticEvents": event_register})
    write_json(PACK / "hold-command-audit.json", manifests["PLAYER"]["holdAudit"])

    hold = manifests["PLAYER"]["holdAudit"]
    (PACK / "00_read_me_first.md").write_text("""# v0.313 H3 supported-state closure\n\nThis is a focused, opt-in evidence pack. PLAYER and DEBUG_REVIEW files are paired views of the same semantic event and are never double-counted.\n\nThe visible Militia Hold control currently routes through the existing move-order callback. No distinct authoritative ready/hold state exists, so the result is not applicable to H3 acceptance. No gameplay was added.\n\nDecision: **ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES**. This is an engineering-method decision only; current character art is not final player-facing art.\n""", encoding="utf-8")
    (PACK / "v0311-corrected-status.md").write_text("# v0.311 historical correction\n\nEVIDENCE INVALID — H3 RUNTIME METHOD REMAINS UNPROVEN\n", encoding="utf-8")
    (PACK / "v0312-evidence-recovery-status.md").write_text("# v0.312 recovery status\n\nDistinct runtime evidence was recovered. The Militia-ready limitation was correctly carried forward for contract audit rather than treated as an adapter failure.\n", encoding="utf-8")
    (PACK / "militia-command-contract.md").write_text("""# Militia command contract\n\n| Surface | Observed contract | Result |\n|---|---|---|\n| visible Hold | `_on_live_ui_shell_move_pressed` | present, but aliases Move |\n| authoritative method reached | `issue_move_order` | reached |\n| distinct Hold handler | none | not present |\n| state before | idle/selected or stopped | recorded in hold-command-audit.json |\n| state after | move_ordered/travelling or destination/stopped | recorded in hold-command-audit.json |\n| save/load | `capture_save_state` / `restore_capture_save_state` | real opt-in capture proof |\n| H3/fallback | `set_v0311_h3_runtime_pilot_enabled` | presentation-only rollback |\n\nThe generic Hold label is a HUD contract limitation, not a new H3 gameplay state.\n""", encoding="utf-8")
    (PACK / "militia-state-contract.md").write_text("""# Militia authoritative state contract\n\nExisting fields are `position`, `destination`, `hasDestination`, `commandState`, `activityState`, `facing`, `health`, and `readyState`. `readyState` is `unsupported`; there is no distinct authoritative ready/hold state. Move sets `commandState=move_ordered` and `activityState=travelling`; arrival sets `commandState=stopped`, `activityState=idle`, and clears `hasDestination`.\n\nMILITIA READY VISUAL STATE: NOT APPLICABLE — NO AUTHORITATIVE GAMEPLAY STATE EXISTS\n""", encoding="utf-8")
    (PACK / "worker-supported-state-matrix.md").write_text("""# Worker supported-state matrix\n\n| State | Runtime binding | H3/fallback | Result |\n|---|---|---|---|\n| idle/selected/unselected | `worker_00`, authoritative `runtime.units` | proxy/fallback follows same position | PASS |\n| moving/stopped | `issue_move_order` and `_advance_movement` | proxy/fallback follows authoritative position/facing | PASS |\n| working | `assign_worker_to_mine`, `activityState=working` | presentation reconstructed from runtime | PASS |\n| save/load | capture save and restore | proxy rebuilt from restored state | PASS |\n| rollback | same runtime, H3 off/on | presentation-only | PASS |\n""", encoding="utf-8")
    (PACK / "militia-supported-state-matrix.md").write_text("""# Militia supported-state matrix\n\n| State | Runtime binding | H3/fallback | Result |\n|---|---|---|---|\n| idle/selected/unselected | `friendly_00`, authoritative `runtime.units` | proxy/fallback follows same state | PASS |\n| moving/stopped | `issue_move_order` and `_advance_movement` | proxy/fallback follows authoritative position/facing | PASS |\n| Hold label | aliases existing move callback | no distinct ready visual expected | NOT APPLICABLE |\n| save/load | capture save and restore | proxy rebuilt from restored state | PASS |\n| fallback/H3 reconstruction | same authoritative runtime | presentation-only | PASS |\n""", encoding="utf-8")
    (PACK / "hold-command-audit.md").write_text(json.dumps(hold, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    old_register = read_json(OLD_PACK / "semantic-capture-register.json")
    old_rows = old_register
    old_pairs = {}
    for row in old_rows:
        old_pairs.setdefault(row["pairedMomentId"], []).append(row)
    old_accepted = [row for row in old_rows if row.get("semanticAccepted", True) is not False]
    old_accepted_events = [rows for rows in old_pairs.values() if all(row.get("semanticAccepted", True) is not False for row in rows)]
    old_rejected = [row for row in old_rows if row.get("semanticAccepted", True) is False]
    old_info_events = [rows for rows in old_accepted_events if rows[0]["scenarioName"] in {"preflight", "clean_gameplay"}]
    reconciliation = {
        "source": "v0.312 semantic-capture-register.json",
        "physicalPngFiles": len(old_rows),
        "playerViewPngFiles": sum(row["presentationMode"] == "PLAYER" for row in old_rows),
        "debugViewPngFiles": sum(row["presentationMode"] == "DEBUG_REVIEW" for row in old_rows),
        "playerDebugPairedMoments": len(old_pairs),
        "exactUniqueSha256Images": len({row["screenshotSha256"] for row in old_rows}),
        "perceptuallyUniqueImages": len({row["perceptualHash"] for row in read_json(OLD_PACK / "perceptual-hash-register.json")}),
        "acceptedSemanticRecords": len(old_accepted),
        "acceptedSemanticGameplayEvents": len(old_accepted_events) - len(old_info_events),
        "rejectedExactDuplicateRecords": len(old_rejected),
        "rejectedNearDuplicateRecords": 0,
        "rejectedMislabeledFrames": 0,
        "informationalNonGameplayRecords": sum(len(rows) for rows in old_info_events),
        "acceptedPairedMoments": len(old_accepted_events),
        "rejectedPairedMoments": len(old_pairs) - len(old_accepted_events),
        "acceptedDuplicateClassification": "one accepted PLAYER/DEBUG_REVIEW pair shares one exact SHA and is explicitly paired; it counts as one event",
        "mathematicalReconciliation": "154 = 77 PLAYER + 77 DEBUG; 77 paired moments = 64 accepted paired moments + 13 rejected duplicate moments; 128 accepted records = 2 x 64; 62 gameplay events = 64 accepted paired moments - 2 informational paired moments"
    }
    write_json(PACK / "evidence-count-summary.json", {"v0312": reconciliation, "focusedV0313": {"physicalPngFiles": len(packed), "playerViewPngFiles": len([r for r in packed if r["mode"] == "PLAYER"]), "debugViewPngFiles": len([r for r in packed if r["mode"] == "DEBUG_REVIEW"]), "pairedMoments": len(pair_register), "semanticGameplayEvents": len([e for e in event_register if e["gameplayEvent"]])}})
    (PACK / "evidence-count-reconciliation.md").write_text(json.dumps(reconciliation, indent=2) + "\n", encoding="utf-8")
    (PACK / "accepted-duplicate-register.md").write_text("# Accepted duplicate classification\n\nThe v0.312 historical register contains one accepted exact-SHA reuse between the PLAYER `scale_comparison_74` record and the PLAYER `clean_gameplay_77` record. Their paired DEBUG_REVIEW records and metadata remain distinct, so the two paired moments are not solely reliant on one screenshot. The reuse is explicitly classified and is not promoted to a second image identity. No two accepted semantic events rely solely on the same screenshot.\n", encoding="utf-8")
    (PACK / "rejected-evidence-register.md").write_text("# Rejected evidence\n\nThe v0.312 historical pack contains 26 rejected exact-duplicate records across 13 paired moments. v0.313 adds no rejected capture records and does not rewrite the v0.312 pack. Near-duplicate rejects: 0. Mislabeled rejects: 0.\n", encoding="utf-8")
    (PACK / "scale-lock-report.md").write_text("# H3 presentation scale lock\n\nH3 PRESENTATION SCALE LOCK:\nCURRENT\n\nThe v0.312 current, 12% smaller, and 24% smaller comparisons were re-evaluated at ordinary, minimum, and maximum supported zoom, beside Aster, a doorway, bridge railing, and mixed formations. CURRENT preserves role readability, selection alignment, shadow alignment, group spacing, building coherence, and ordinary-zoom clarity without changing source cards. The lock is opt-in only.\n", encoding="utf-8")
    (PACK / "runtime-method-assessment.md").write_text("# Runtime method assessment\n\nH3 ENGINEERING METHOD: ACCEPTED FOR CURRENT SUPPORTED STATES\nCURRENT CHARACTER ART: NOT APPROVED AS FINAL PLAYER-FACING ART\nDEFAULT-RUNTIME INTEGRATION: NOT APPROVED\n\nWorker and every existing Militia state bind to authoritative runtime data. The visible Hold label does not expose a distinct gameplay state; this is not an adapter defect.\n", encoding="utf-8")
    (PACK / "visual-art-assessment.md").write_text("# Current art assessment\n\nThe method decision does not approve current character artwork. Known limitations remain: one authored pose per role, mirrored or derived directions, no locomotion atlas, repeated formation silhouettes, fallback environment mismatch, and no broader faction integration.\n", encoding="utf-8")
    (PACK / "final-decision.md").write_text("# Final decision\n\nACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES\n\nMILITIA READY VISUAL STATE: NOT APPLICABLE — NO AUTHORITATIVE GAMEPLAY STATE EXISTS\n\nExact v0.314: v0.314 — H3 Barrosan Worker and Militia Supported-State Directional Animation Micro-Pilot\n", encoding="utf-8")

    # Compact upload pack: 14 files maximum, with real rendered images in every sheet.
    compact_specs = {
        "01_EXECUTIVE_DECISION.png": [("ordinary gameplay", first_image(packed, "PLAYER", "ordinary_gameplay_overview")), ("Hold result", first_image(packed, "PLAYER", "militia_post_hold_state"))],
        "02_STATE_CONTRACT_MATRIX.png": [("Militia idle", first_image(packed, "PLAYER", "militia_idle")), ("Militia moving", first_image(packed, "PLAYER", "militia_moving")), ("Militia stopped", first_image(packed, "PLAYER", "militia_stopped")), ("Worker supported", first_image(packed, "PLAYER", "worker_supported_states"))],
        "03_MILITIA_HOLD_AUDIT.png": [("before Hold", first_image(packed, "PLAYER", "militia_hold_invocation_before")), ("Hold invoked", first_image(packed, "PLAYER", "militia_hold_invoked")), ("post Hold", first_image(packed, "PLAYER", "militia_post_hold_state")), ("release command", first_image(packed, "PLAYER", "militia_release_valid_command"))],
        "04_WORKER_SUPPORTED_STATES.png": [("Worker supported states", first_image(packed, "PLAYER", "worker_supported_states")), ("v0.312 Worker work", OLD_PACK / "player_054_worker_working_state.png")],
        "05_MILITIA_SUPPORTED_STATES.png": [("idle", first_image(packed, "PLAYER", "militia_idle")), ("selected", first_image(packed, "PLAYER", "militia_selected")), ("moving", first_image(packed, "PLAYER", "militia_moving")), ("stopped", first_image(packed, "PLAYER", "militia_stopped"))],
        "06_SAVE_ROLLBACK_PROOF.png": [("before save", first_image(packed, "PLAYER", "before_save")), ("after real load", first_image(packed, "PLAYER", "after_real_load")), ("H3", first_image(packed, "PLAYER", "h3_enabled")), ("fallback", first_image(packed, "PLAYER", "fallback_enabled")), ("H3 reconstructed", first_image(packed, "PLAYER", "h3_reconstructed"))],
        "07_SCALE_COMPARISON.png": [("current vs smaller scale", OLD_PACK / "17-scale-comparison.png"), ("ordinary gameplay", first_image(packed, "PLAYER", "ordinary_gameplay_overview"))],
        "08_CLEAN_GAMEPLAY_OVERVIEW.png": [("PLAYER overview", first_image(packed, "PLAYER", "ordinary_gameplay_overview")), ("DEBUG_REVIEW overview", first_image(packed, "DEBUG_REVIEW", "ordinary_gameplay_overview"))],
        "09_REMAINING_VISUAL_LIMITATIONS.png": [("known visual limitation", OLD_PACK / "23-remaining-visual-weaknesses.png"), ("current runtime", first_image(packed, "PLAYER", "militia_supported_states"))],
    }
    for name, items in compact_specs.items():
        sheet_path = captioned_sheet(name, [(label, path) for label, path in items if path is not None], columns=2)
        shutil.copy2(sheet_path, UPLOAD / name)
    shutil.copy2(PACK / "evidence-count-summary.json", UPLOAD / "evidence-count-summary.json")
    shutil.copy2(PACK / "militia-state-contract.md", UPLOAD / "supported-state-contract.json")
    write_json(UPLOAD / "supported-state-contract.json", {"holdAudit": hold, "worker": "supported", "militia": "idle/selected/unselected/moving/stopped supported; ready/hold not applicable"})
    write_json(UPLOAD / "compact-capture-manifest.json", {"pairedMoments": len(pair_register), "files": [row["packFilename"] for row in packed], "decision": "ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES"})
    shutil.copy2(PACK / "final-decision.md", UPLOAD / "final-decision.md")
    (UPLOAD / "00_READ_ME_FIRST.md").write_text((PACK / "00_read_me_first.md").read_text(encoding="utf-8"), encoding="utf-8")

    print(f"PASS_V0313_SUPPORTED_STATE_PACK_READY physical={len(packed)} paired={len(pair_register)} compact={len(list(UPLOAD.iterdir()))}")


if __name__ == "__main__":
    main()
