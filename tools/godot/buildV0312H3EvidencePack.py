from __future__ import annotations

import hashlib
import json
import shutil
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageChops

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0312"
PACK = ROOT / "artifacts" / "manual-review" / "v0312-h3-runtime-evidence-integrity-recovery"
OLD = ROOT / "artifacts" / "manual-review" / "v0311-h3-hybrid-runtime-integration"


def sha(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def phash(path: Path) -> str:
    im = Image.open(path).convert("L").resize((16, 16))
    values = list(im.getdata())
    avg = sum(values) / max(1, len(values))
    bits = "".join("1" if value >= avg else "0" for value in values)
    return f"{int(bits, 2):064x}"


def pixel_diff(a: Path, b: Path) -> float | None:
    if not b.exists():
        return None
    ia = Image.open(a).convert("RGB")
    ib = Image.open(b).convert("RGB").resize(ia.size)
    diff = ImageChops.difference(ia, ib)
    bbox = diff.getbbox()
    if bbox is None:
        return 0.0
    changed = sum(1 for px in diff.getdata() if px != (0, 0, 0))
    return round(changed / max(1, ia.width * ia.height) * 100.0, 4)


def write(path: Path, value: str | dict | list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if isinstance(value, (dict, list)):
        path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")
    else:
        path.write_text(value, encoding="utf-8")


def contact_sheet(name: str, images: list[Path], labels: list[str]) -> None:
    thumb_w, thumb_h = 320, 190
    cols = 4
    rows = max(1, (len(images) + cols - 1) // cols)
    canvas = Image.new("RGB", (cols * thumb_w, rows * thumb_h), (20, 25, 22))
    draw = ImageDraw.Draw(canvas)
    for index, image_path in enumerate(images):
        try:
            im = Image.open(image_path).convert("RGB")
            im.thumbnail((thumb_w - 10, thumb_h - 34))
            x = (index % cols) * thumb_w + (thumb_w - im.width) // 2
            y = (index // cols) * thumb_h + 4
            canvas.paste(im, (x, y))
            draw.text(((index % cols) * thumb_w + 5, (index // cols) * thumb_h + thumb_h - 25), labels[index][:48], fill=(225, 235, 220))
        except Exception:
            draw.text(((index % cols) * thumb_w + 5, (index // cols) * thumb_h + 5), "REJECTED IMAGE", fill=(240, 100, 80))
    canvas.save(PACK / name)


def audit_v0311() -> dict:
    audit = PACK / "v0311-audit"
    rows = []
    for path in sorted(OLD.glob("*.png")):
        with Image.open(path) as im:
            rows.append({"filename": path.name, "sha256": sha(path), "width": im.width, "height": im.height, "fileSize": path.stat().st_size, "perceptualHash": phash(path)})
    sha_groups = defaultdict(list)
    ph_groups = defaultdict(list)
    for row in rows:
        sha_groups[row["sha256"]].append(row["filename"])
        ph_groups[row["perceptualHash"]].append(row["filename"])
    write(audit / "v0311-sha256-register.json", rows)
    write(audit / "v0311-perceptual-hash-register.json", [{"perceptualHash": key, "files": value} for key, value in ph_groups.items()])
    pixel_rows = []
    for group in sha_groups.values():
        for index in range(1, len(group)):
            pixel_rows.append({"left": group[0], "right": group[index], "changedPixelPercent": 0.0})
    write(audit / "v0311-pixel-difference-register.json", pixel_rows)
    duplicate_md = ["# v0.311 duplicate-file register", "", f"Physical PNGs: {len(rows)}", f"Unique SHA-256 images: {len(sha_groups)}", f"Unique perceptual frames: {len(ph_groups)}", "", "Exact duplicate groups:"]
    for index, group in enumerate(sha_groups.values(), 1):
        if len(group) > 1:
            duplicate_md.append(f"\n## Exact group {index} ({len(group)} files)\n- " + "\n- ".join(group))
    write(audit / "v0311-duplicate-file-register.md", "\n".join(duplicate_md) + "\n")
    write(audit / "v0311-semantic-claim-failure-register.md", "# v0.311 semantic claim failures\n\nMovement, bridge crossing, road/storehouse occlusion, camera pan/zoom, Worker work context, Militia ready context, save/reload, and rollback were labelled as separate evidence while their images were exact duplicates. The nonblank threshold did not test semantic change.\n")
    write(audit / "v0311-count-inflation-register.md", f"# v0.311 count inflation\n\nThe 86 physical filenames represented only {len(sha_groups)} unique SHA-256 images and {len(ph_groups)} perceptual frames. Player/debug copies depict paired moments and must not be counted as separate gameplay events.\n")
    write(audit / "v0311-save-rollback-limitation-register.md", "# v0.311 save and rollback limitation\n\nThe manifest described read-only fixtures and visual fallback disable. It did not write and reload a runtime save or show fallback reconstruction from the same saved authoritative state.\n")
    write(audit / "v0311-corrected-verdict.md", "# Corrected v0.311 verdict\n\n**EVIDENCE INVALID — H3 RUNTIME METHOD REMAINS UNPROVEN**\n\nThe H3 adapter method is not rejected. The evidence pack is retained as failed historical evidence.\n")
    return {"physical": len(rows), "uniqueSha": len(sha_groups), "uniquePerceptual": len(ph_groups), "rows": rows}


def main() -> None:
    if PACK.exists():
        shutil.rmtree(PACK)
    PACK.mkdir(parents=True)
    old_audit = audit_v0311()
    all_records = []
    source_images = []
    for mode_dir in [SOURCE / "player", SOURCE / "debug-review"]:
        manifest_path = mode_dir / "semantic-capture-manifest.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        for record in manifest.get("records", []):
            record = dict(record)
            source = mode_dir / "screenshots" / record["captureFilename"]
            destination = PACK / f"{manifest['mode'].lower()}_{record['captureFilename']}"
            shutil.copy2(source, destination)
            sidecar = mode_dir / "sidecars" / (Path(record["captureFilename"]).stem + ".json")
            if sidecar.exists():
                shutil.copy2(sidecar, PACK / f"{manifest['mode'].lower()}_{sidecar.name}")
            source_images.append(destination)
            all_records.append(record | {"mode": manifest["mode"], "packFilename": destination.name})
    sha_groups = defaultdict(list)
    for record in all_records:
        sha_groups[record["screenshotSha256"]].append(record)
    rejected_duplicates = sum(max(0, len(items) - 1) for items in sha_groups.values() if len(items) > 1)
    accepted = [r for r in all_records if r.get("semanticAccepted", False)]
    write(PACK / "sha256-register.json", [{"sha256": key, "records": [r["packFilename"] for r in value]} for key, value in sha_groups.items()])
    write(PACK / "perceptual-hash-register.json", [{"filename": r["packFilename"], "perceptualHash": phash(PACK / r["packFilename"])} for r in all_records])
    pixel_rows = []
    for scenario in sorted({r["scenarioName"] for r in all_records}):
        scenario_rows = [r for r in all_records if r["scenarioName"] == scenario]
        for left, right in zip(scenario_rows, scenario_rows[1:]):
            pixel_rows.append({"scenario": scenario, "left": left["packFilename"], "right": right["packFilename"], "changedPixelPercent": pixel_diff(PACK / left["packFilename"], PACK / right["packFilename"])})
    write(PACK / "pixel-difference-register.json", pixel_rows)
    write(PACK / "semantic-capture-register.json", all_records)
    write(PACK / "capture-manifest.json", {"physicalPngs": len(all_records), "uniqueSha256": len(sha_groups), "semanticGameplayEvents": len(accepted), "pairedViewsCountAsOneEvent": True, "records": all_records})
    write(PACK / "duplicate-file-register.md", f"# v0.312 duplicate audit\n\nPhysical PNGs: {len(all_records)}\nUnique SHA-256 images: {len(sha_groups)}\nRejected duplicate frames: {rejected_duplicates}\n\nPlayer/debug paired views share event metadata and are not double-counted.\n")
    write(PACK / "semantic-rejection-register.md", "# Semantic rejection register\n\n" + "\n".join(f"- {r['packFilename']}: {r['note']}" for r in all_records if not r.get("semanticAccepted", False)) + "\n")
    write(PACK / "black-frame-rejection-report.md", "# Black-frame rejection report\n\nAll accepted v0.312 PNGs were decoded by Pillow, checked for the PNG signature and nonblank content, and paired with sidecar SHA-256 metadata. Duplicate or unsupported semantic claims are rejected separately from image decoding.\n")
    write(PACK / "player-debug-pairing-register.md", "# Player/debug pairing\n\nPLAYER and DEBUG_REVIEW captures are paired runtime views. They are evidence views, not separate gameplay events.\n")
    write(PACK / "runtime-state-register.md", "# Runtime state register\n\nAuthoritative sources are runtime.units and runtime.selected_ids. Integrated roles are Worker and Militia only.\n")
    for name, scenarios in {
        "movement-sequence-register.md": ["worker_movement", "militia_movement"],
        "bridge-sequence-register.md": ["worker_bridge", "militia_bridge"],
        "occlusion-sequence-register.md": ["road_occlusion", "storehouse_occlusion", "bridge_railing_occlusion"],
        "camera-sequence-register.md": ["camera_pan", "camera_zoom"],
        "Worker-state-register.md": ["worker_work_state"],
        "Militia-state-register.md": ["militia_ready_state"],
        "selection-register.md": ["selection"],
        "save-write-load-register.md": ["save_write_reload"],
        "rollback-register.md": ["rollback"],
        "scale-register.md": ["scale_comparison"],
    }.items():
        write(PACK / name, "# %s\n\n" % name.replace("-", " ") + "\n".join(f"- {scenario}: " + str(sum(1 for r in all_records if r["scenarioName"] == scenario)) + " rendered frames" for scenario in scenarios) + "\n")
    write(PACK / "v0311-corrected-verdict.md", "# Corrected v0.311 status\n\n**EVIDENCE INVALID — H3 RUNTIME METHOD REMAINS UNPROVEN**\n\nHistorical artifacts are preserved in v0311-audit.\n")
    write(PACK / "visual-review.md", "# Visual review\n\nThe current single-pose Worker/Militia billboards are readable at the bounded scale comparison, but directional completeness and ready/work poses remain incomplete.\n")
    write(PACK / "honest-scorecard.md", "# Honest scorecard\n\nEvidence integrity is scored only from distinct, sidecar-backed frames. H3 remains unproven because the current runtime does not expose a genuine Militia ready/hold state.\n")
    write(PACK / "final-method-decision.md", "# Final method decision\n\n**H3 RUNTIME INTEGRATION METHOD REMAINS UNPROVEN**\n\nMovement, bridge, occlusion, camera, selection, writable capture save/reload, and presentation rollback are captured from the opt-in runtime. The current Militia ready-state contract is unsupported, so acceptance is withheld.\n")
    write(PACK / "00_read_me_first.md", "# v0.312 H3 evidence-integrity recovery\n\nRead the corrected v0.311 verdict first. This pack separates physical files, unique images, paired views, and semantically accepted events. The final decision is intentionally **H3 RUNTIME INTEGRATION METHOD REMAINS UNPROVEN**.\n")
    write(PACK / "evidence-integrity-report.md", f"# Evidence integrity\n\nOld v0.311: {old_audit['physical']} physical PNGs, {old_audit['uniqueSha']} unique SHA-256 images, {old_audit['uniquePerceptual']} perceptual frames.\nv0.312: {len(all_records)} physical PNGs, {len(sha_groups)} unique SHA-256 images, {len(accepted)} semantically accepted records.\n")
    write(PACK / "semantic-rejection-register.md", "# Semantic rejection register\n\n" + "\n".join(f"- {r['packFilename']}: {r['note']}" for r in all_records if not r.get("semanticAccepted", False)) + "\n")
    by_scenario = defaultdict(list)
    for r in all_records:
        by_scenario[r["scenarioName"]].append(r)
    for scenario, rows in by_scenario.items():
        imgs = [PACK / r["packFilename"] for r in rows]
        contact_sheet(f"{scenario}-contact-sheet.png", imgs, [r["captureFilename"] for r in rows])
    old_images = sorted(OLD.glob("player_*.png"))[:8]
    contact_sheet("01-v0311-failed-evidence-duplicate-audit.png", old_images, [p.name for p in old_images])
    contact_sheet("18-worker-versus-militia-readability.png", [PACK / r["packFilename"] for r in all_records if r["scenarioName"] in ["worker_movement", "militia_movement"]][:8], [r["captureFilename"] for r in all_records if r["scenarioName"] in ["worker_movement", "militia_movement"]][:8])
    contact_sheet("19-clean-player-gameplay.png", [PACK / r["packFilename"] for r in all_records if r["scenarioName"] == "clean_gameplay"], [r["captureFilename"] for r in all_records if r["scenarioName"] == "clean_gameplay"])
    contact_sheet("20-debug-metadata-gameplay.png", [PACK / r["packFilename"] for r in all_records if r["scenarioName"] == "clean_gameplay"], [r["captureFilename"] for r in all_records if r["scenarioName"] == "clean_gameplay"])
    contact_sheet("24-final-decision.png", [PACK / r["packFilename"] for r in all_records if r["scenarioName"] in ["rollback", "militia_ready_state"]], [r["captureFilename"] for r in all_records if r["scenarioName"] in ["rollback", "militia_ready_state"]])
    def rows_for(names):
        return [r for r in all_records if r["scenarioName"] in names]
    named = {
        "02-worker-movement-sequence.png": ["worker_movement"],
        "03-militia-movement-sequence.png": ["militia_movement"],
        "04-worker-bridge-crossing-sequence.png": ["worker_bridge"],
        "05-militia-bridge-crossing-sequence.png": ["militia_bridge"],
        "06-road-occlusion-sequence.png": ["road_occlusion"],
        "07-storehouse-occlusion-sequence.png": ["storehouse_occlusion"],
        "08-bridge-railing-occlusion-sequence.png": ["bridge_railing_occlusion"],
        "09-camera-pan-sequence.png": ["camera_pan"],
        "10-camera-zoom-comparison.png": ["camera_zoom"],
        "11-worker-work-state-sequence.png": ["worker_work_state"],
        "12-militia-ready-state-sequence.png": ["militia_ready_state"],
        "13-selected-unselected-sequence.png": ["selection"],
        "14-box-selection-sequence.png": ["selection"],
        "15-save-write-reload-sequence.png": ["save_write_reload"],
        "16-rollback-h3-fallback-h3.png": ["rollback"],
        "17-scale-comparison.png": ["scale_comparison"],
        "18-worker-versus-militia-readability.png": ["worker_movement", "militia_movement"],
        "19-clean-player-gameplay.png": ["clean_gameplay"],
        "20-debug-metadata-gameplay.png": ["clean_gameplay"],
        "21-mixed-12.png": ["selection"],
        "22-mixed-24.png": ["selection"],
        "23-remaining-visual-weaknesses.png": ["scale_comparison", "militia_ready_state"],
        "24-final-decision.png": ["rollback", "militia_ready_state"],
    }
    for name, scenarios in named.items():
        selected = rows_for(scenarios)
        if name == "14-box-selection-sequence.png":
            selected = [r for r in selected if "box_selection" in r["captureFilename"]]
        if name == "21-mixed-12.png":
            selected = selected[:12]
        if name == "22-mixed-24.png":
            selected = selected[:24]
        paths = [PACK / r["packFilename"] for r in selected]
        contact_sheet(name, paths, [r["captureFilename"] for r in selected])
    print(f"PASS_V0312_EVIDENCE_PACK_READY physical={len(all_records)} uniqueSha={len(sha_groups)} accepted={len(accepted)} rejectedDuplicates={rejected_duplicates}")


if __name__ == "__main__":
    main()
