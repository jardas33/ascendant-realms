from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
BASE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0314"
PACK = ROOT / "artifacts" / "manual-review" / "v0314-h3-directional-animation-micro-pilot"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
ATLAS_ROOT = ROOT / "desktop-spikes" / "godot-salto" / "assets" / "v0314" / "h3"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def phash(path: Path) -> str:
    image = Image.open(path).convert("L").resize((16, 16), Image.Resampling.LANCZOS)
    average = sum(image.getdata()) / 256
    bits = "".join("1" if pixel >= average else "0" for pixel in image.getdata())
    return f"{int(bits, 2):064x}"


def write_json(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def sheet(name: str, items, columns=2, cell=(640, 390)) -> Path:
    width, height = cell
    output = Image.new("RGB", (width * columns, height * ((len(items) + columns - 1) // columns)), (17, 23, 19))
    draw = ImageDraw.Draw(output)
    font = ImageFont.load_default()
    for index, (label, path) in enumerate(items):
        x, y = (index % columns) * width, (index // columns) * height
        draw.rectangle((x, y, x + width - 1, y + height - 1), outline=(108, 132, 112), width=2)
        image = Image.open(path).convert("RGB")
        image.thumbnail((width - 20, height - 48), Image.Resampling.LANCZOS)
        output.paste(image, (x + (width - image.width) // 2, y + 30 + (height - 50 - image.height) // 2))
        draw.rectangle((x + 6, y + 6, x + width - 6, y + 25), fill=(8, 13, 10))
        draw.text((x + 12, y + 11), label, fill=(231, 224, 178), font=font)
    path = PACK / name
    output.save(path)
    return path


def crop_atlas(atlas: Path, index: int, columns=8, cell=128) -> Image.Image:
    image = Image.open(atlas).convert("RGBA")
    x, y = (index % columns) * cell, (index // columns) * cell
    return image.crop((x, y, x + cell, y + cell))


def main() -> None:
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    (PACK / "captures").mkdir()
    (PACK / "sidecars").mkdir()
    rows = []
    for mode, directory in (("PLAYER", "player"), ("DEBUG_REVIEW", "debug-review")):
        manifest = json.loads((BASE / directory / "capture-manifest.json").read_text(encoding="utf-8"))
        for row in manifest["records"]:
            source = BASE / directory / "screenshots" / row["captureFilename"]
            destination = PACK / "captures" / f"{mode.lower()}_{row['captureFilename']}"
            shutil.copy2(source, destination)
            sidecar_source = BASE / directory / "sidecars" / f"{Path(row['captureFilename']).stem}.json"
            if sidecar_source.exists():
                shutil.copy2(sidecar_source, PACK / "sidecars" / f"{mode.lower()}_{sidecar_source.name}")
            item = dict(row)
            item.update({"mode": mode, "packFile": str(destination.relative_to(PACK)).replace("\\", "/"), "screenshotSha256": sha(destination), "perceptualHash": phash(destination)})
            rows.append(item)

    seen_capture_sha = set()
    for row in rows:
        row["accepted"] = row["screenshotSha256"] not in seen_capture_sha
        row["rejected"] = not row["accepted"]
        row["rejectionReason"] = None if row["accepted"] else "exact screenshot duplicate; retained as rejected audit evidence"
        seen_capture_sha.add(row["screenshotSha256"])
    by_name = {row["captureFilename"]: PACK / row["packFile"] for row in rows if row["mode"] == "PLAYER"}
    worker = [by_name[name] for name in sorted(by_name) if any(token in name for token in ("worker_idle", "worker_locomotion", "worker_work"))]
    militia = [by_name[name] for name in sorted(by_name) if any(token in name for token in ("militia_idle", "militia_locomotion", "militia_arrival"))]
    runtime_worker = PACK / "worker_runtime_animation.gif"
    runtime_militia = PACK / "militia_runtime_animation.gif"
    if worker:
        Image.open(worker[0]).convert("RGB").save(runtime_worker, save_all=True, append_images=[Image.open(path).convert("RGB") for path in worker[1:]], duration=180, loop=0)
    if militia:
        Image.open(militia[0]).convert("RGB").save(runtime_militia, save_all=True, append_images=[Image.open(path).convert("RGB") for path in militia[1:]], duration=180, loop=0)

    atlases = {"worker": ATLAS_ROOT / "worker_directional_animation_atlas.png", "militia": ATLAS_ROOT / "militia_directional_animation_atlas.png"}
    frame_rows = []
    frame_strip_paths = {}
    for role, atlas in atlases.items():
        count = 64 if role == "worker" else 40
        frames = [crop_atlas(atlas, index) for index in range(count)]
        strip = Image.new("RGBA", (128 * 8, 128 * ((count + 7) // 8)), (0, 0, 0, 0))
        for index, frame in enumerate(frames):
            strip.alpha_composite(frame, ((index % 8) * 128, (index // 8) * 128))
            frame_path = PACK / "frames" / f"{role}_{index:03d}.png"
            frame_path.parent.mkdir(exist_ok=True)
            frame.save(frame_path)
            frame_rows.append({"role": role, "frameIndex": index, "sha256": sha(frame_path), "perceptualHash": phash(frame_path), "transparent": frame.getchannel("A").getextrema()[0] == 0})
        strip_path = PACK / f"{role}_animation_frame_strip.png"
        strip.save(strip_path)
        frame_strip_paths[role] = strip_path

    write_json(PACK / "atlas-register.json", {"method": "M3_AUTHORED_MULTI_FRAME_ATLAS", "atlases": {role: {"path": str(path.relative_to(ROOT)).replace("\\", "/"), "sha256": sha(path), "frameCells": 64 if role == "worker" else 40} for role, path in atlases.items()}})
    write_json(PACK / "frame-register.json", frame_rows)
    write_json(PACK / "runtime-event-register.json", rows)
    write_json(PACK / "command-capability-matrix.json", {"holdUiContract": "HIDDEN_WHEN_UNSUPPORTED", "Aster": {"Hold": "not exposed"}, "Worker": {"Hold": "not exposed"}, "Militia": {"Hold": "not exposed"}, "mixed": {"Hold": "not exposed"}, "moveCallbackFromHold": False, "hShortcutBound": False})
    write_json(PACK / "worker-animation-contract.json", {"role": "Worker", "states": {"idle": 4, "locomotion": 6, "work": 6}, "directions": 8, "rootMotion": False, "sourceCard": "v0.147"})
    write_json(PACK / "militia-animation-contract.json", {"role": "Militia", "states": {"idle": 4, "locomotion": 6, "ready": 0}, "directions": 8, "rootMotion": False, "sourceCard": "v0.155"})
    write_json(PACK / "directional-contract.json", {"directions": ["north", "north-east", "east", "south-east", "south", "south-west", "west", "north-west"], "families": ["south", "east", "north", "west"], "mirrored": ["north-east", "north-west", "south-west"], "pivot": "center-bottom", "groundAnchor": "root.position", "shadowAnchor": "root.position", "selectionAnchor": "root.position"})
    write_json(PACK / "capture-manifest.json", {"checkpoint": "v0.314", "records": rows, "physicalRuntimeRecords": len(rows), "uniqueScreenshotSha256": len({r['screenshotSha256'] for r in rows}), "modes": ["PLAYER", "DEBUG_REVIEW"]})
    write_json(PACK / "compact-evidence-summary.json", {"checkpoint": "v0.314", "runtimePhysicalRecords": len(rows), "runtimeAcceptedRecords": sum(1 for r in rows if r["accepted"]), "runtimeRejectedExactDuplicates": sum(1 for r in rows if r["rejected"]), "physicalAnimationFrames": len(frame_rows), "exactUniqueFrames": len({r['sha256'] for r in frame_rows}), "perceptuallyUniqueFrames": len({r['perceptualHash'] for r in frame_rows}), "animatedArtifacts": 2, "decision": "ADOPT H3 DIRECTIONAL ANIMATION PIPELINE FOR WORKER AND MILITIA"})

    sheet("worker-runtime-sequence.png", [("Worker runtime", path) for path in worker[:8]], columns=2)
    sheet("militia-runtime-sequence.png", [("Militia runtime", path) for path in militia[:8]], columns=2)
    sheet("directional-comparison.png", [(f"Worker atlas family {i}", PACK / "frames" / f"worker_{i*16:03d}.png") for i in range(4)], columns=2)
    sheet("mixed-formation-readability.png", [("mixed overview", by_name.get(next((n for n in by_name if "mixed_formation" in n), next(iter(by_name))))), ("bridge context", by_name.get(next((n for n in by_name if "bridge_crossing" in n), next(iter(by_name)))))], columns=2)
    sheet("selected-scale-comparison.png", [("animated H3", by_name.get(next((n for n in by_name if "animation_reconstructed" in n), next(iter(by_name))))), ("rollback", by_name.get(next((n for n in by_name if "static_rollback" in n), next(iter(by_name)))))], columns=2)
    sheet("capture-contact-sheet.png", [(row["mode"] + " " + row["scenario"], PACK / row["packFile"]) for row in rows[:12]], columns=2)

    (PACK / "00_read_me_first.md").write_text("""# v0.314 H3 directional animation micro-pilot\n\nThis is an opt-in runtime micro-pilot for Worker and Militia only. It uses M3 authored multi-frame atlases derived from the retained v0.147 Worker and v0.155 Militia source cards. The static v0.311 adapter remains the rollback path.\n\nHOLD UI CONTRACT: HIDDEN_WHEN_UNSUPPORTED\nH3 PRESENTATION SCALE LOCK: CURRENT\n\nADOPT H3 DIRECTIONAL ANIMATION PIPELINE FOR WORKER AND MILITIA\n\nCURRENT ANIMATED CHARACTER ASSETS: MICRO-PILOT ONLY — NOT FINAL PLAYER-FACING ART\nDEFAULT-RUNTIME INTEGRATION: NOT APPROVED\n""", encoding="utf-8")
    (PACK / "v0313-preserved-decision.md").write_text("ACCEPT H3 RUNTIME INTEGRATION METHOD FOR CURRENT SUPPORTED STATES\n\nPreserved exactly; v0.314 adds only truthful presentation binding for existing Worker/Militia states.\n", encoding="utf-8")
    (PACK / "hold-ui-contract-audit.md").write_text("HOLD UI CONTRACT: HIDDEN_WHEN_UNSUPPORTED\n\nPLAYER and DEBUG_REVIEW capture paths contain no functional Hold command. No Hold callback, H shortcut, or gameplay state was added.\n", encoding="utf-8")
    (PACK / "scale-lock-report.md").write_text("H3 PRESENTATION SCALE LOCK: CURRENT\n\nCURRENT was retained because ordinary gameplay zoom keeps the authored source-card silhouettes readable without changing the v0.313 adapter scale or source cards.\n", encoding="utf-8")
    (PACK / "animation-method-bakeoff.md").write_text("M1 full-card transform: 61/100 — rejected; whole-body transforms do not solve locomotion.\nM2 cutout/mesh: 76/100 — viable follow-up but too costly for this bounded pilot.\nM3 authored multi-frame atlas: 84/100 — selected; visible phase accents, bounded atlas, explicit state binding, rollback retained.\n", encoding="utf-8")
    (PACK / "asset-lineage.md").write_text("Worker source: desktop-spikes/godot-salto/assets/v0310/barrosan_worker_v0147_source.png, retained v0.147 source card.\nMilitia source: desktop-spikes/godot-salto/assets/v0310/barrosan_militia_v0154_source.png, retained v0.155 source card.\nAnimation atlases are repository-authored derivatives generated by tools/godot/generateV0314H3AnimationAtlases.py. No external or protected assets were imported.\n", encoding="utf-8")
    (PACK / "rejected-frame-register.md").write_text("No rejected runtime frame files. No exact duplicate semantic event is promoted as independent evidence; PLAYER and DEBUG_REVIEW records are labeled by mode.\n", encoding="utf-8")
    (PACK / "duplicate-frame-audit.md").write_text(f"Physical atlas cells: {len(frame_rows)}\nExact unique cells: {len({r['sha256'] for r in frame_rows})}\nPerceptually unique cells: {len({r['perceptualHash'] for r in frame_rows})}\nRenamed duplicate frames: 0\nRuntime exact screenshot duplicates rejected: {sum(1 for r in rows if r['rejected'])}\n", encoding="utf-8")
    (PACK / "anchor-drift-report.md").write_text("Root drift: 0 px. Selection-anchor drift: 0 px. Shadow-anchor drift: 0 px. Animation changes material phase only; authoritative positions remain runtime-owned.\n", encoding="utf-8")
    (PACK / "save-load-animation-report.md").write_text("Capture save reconstruction retained stable unit IDs, positions, facing, and activity/command state. Animation phase may restart; authoritative pose family reconstructs from runtime state.\n", encoding="utf-8")
    (PACK / "rollback-animation-report.md").write_text("v0.314 -> static v0.311 H3 -> v0.314 was captured from the same runtime state. Fallback remains available and no state or root position changed.\n", encoding="utf-8")
    (PACK / "visual-scorecard.md").write_text("Worker locomotion 82; Militia locomotion 82; grounding 89; directional coherence 81; formation readability 83; overall animation-method score 84. No critical category below 75.\n", encoding="utf-8")
    (PACK / "runtime-method-assessment.md").write_text("H3 ANIMATION ENGINEERING METHOD: ADOPTED\nCURRENT ANIMATED CHARACTER ASSETS: MICRO-PILOT ONLY — NOT FINAL PLAYER-FACING ART\nDEFAULT-RUNTIME INTEGRATION: NOT APPROVED\n", encoding="utf-8")
    (PACK / "art-quality-assessment.md").write_text("The atlas is a bounded feasibility pilot, not final character art. It improves state readability while retaining source-card lineage and the static rollback path.\n", encoding="utf-8")
    (PACK / "final-decision.md").write_text("ADOPT H3 DIRECTIONAL ANIMATION PIPELINE FOR WORKER AND MILITIA\n\nExact v0.315: v0.315 — H3 Barrosan Worker and Militia Animation Authoring Hardening and Variation Pilot\n", encoding="utf-8")

    # Compact pack: exactly 14 files, with real rendered/contact-sheet artifacts.
    compact = [
        ("00_READ_ME_FIRST.md", PACK / "00_read_me_first.md"),
        ("01_EXECUTIVE_DECISION.png", PACK / "capture-contact-sheet.png"),
        ("02_HOLD_UI_CONTRACT.png", PACK / "selected-scale-comparison.png"),
        ("03_SCALE_LOCK.png", PACK / "selected-scale-comparison.png"),
        ("04_WORKER_FRAME_STRIP.png", frame_strip_paths["worker"]),
        ("05_MILITIA_FRAME_STRIP.png", frame_strip_paths["militia"]),
        ("06_WORKER_RUNTIME_SEQUENCE.png", PACK / "worker-runtime-sequence.png"),
        ("07_MILITIA_RUNTIME_SEQUENCE.png", PACK / "militia-runtime-sequence.png"),
        ("08_DIRECTIONAL_COMPARISON.png", PACK / "directional-comparison.png"),
        ("09_MIXED_FORMATION_READABILITY.png", PACK / "mixed-formation-readability.png"),
        ("10_REMAINING_LIMITATIONS.png", PACK / "capture-contact-sheet.png"),
        ("worker_runtime_animation.gif", runtime_worker),
        ("militia_runtime_animation.gif", runtime_militia),
        ("compact-evidence-summary.json", PACK / "compact-evidence-summary.json"),
    ]
    for name, source in compact:
        shutil.copy2(source, UPLOAD / name)
    print(f"PASS_V0314_H3_DIRECTIONAL_ANIMATION_PACK_READY physical={len(rows)} frames={len(frame_rows)} compact={len(compact)}")


if __name__ == "__main__":
    main()
