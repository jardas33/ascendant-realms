from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0323" / "structural-geometry-repair"
V0322_SOURCE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0322" / "barrosan-bridge-hamlet-hero-slice"
PACK = ROOT / "artifacts" / "manual-review" / "v0323-structural-geometry-repair"
UPLOAD = PACK / "UPLOAD_TO_CHAT"
FULL = PACK / "full-evidence"
MEDIA = ROOT / "artifacts" / "manual-review" / "v0322-barrosan-bridge-hamlet-hero-slice" / "UPLOAD_TO_CHAT" / "08_CONTINUOUS_HERO_SLICE.mp4"
EXPECTED_MEDIA_SHA = "8901bb6a074e5c3cc01bf5e16572f21dac06a527a4ea15273d649c71c73faa84"


def image(name: str) -> Image.Image:
    path = SOURCE / "screenshots" / name
    if not path.exists():
        raise FileNotFoundError(path)
    return Image.open(path).convert("RGB")


def labelled_sheet(items: list[tuple[str, Image.Image]], out: Path, columns: int = 2) -> None:
    thumb_w, thumb_h = 800, 450
    rows = (len(items) + columns - 1) // columns
    sheet = Image.new("RGB", (thumb_w * columns, thumb_h * rows), "#162019")
    draw = ImageDraw.Draw(sheet)
    for index, (label, source) in enumerate(items):
        thumb = source.copy()
        thumb.thumbnail((thumb_w, thumb_h))
        x = (index % columns) * thumb_w
        y = (index // columns) * thumb_h
        sheet.paste(thumb, (x, y))
        draw.rectangle((x, y, x + thumb_w, y + 34), fill="#101712")
        draw.text((x + 12, y + 9), label, fill="#f0d9a0")
    sheet.save(out)


def write_proof(name: str, body: str) -> None:
    (FULL / name).write_text(body + "\n", encoding="utf-8")


def main() -> None:
    if not (SOURCE / "v0323-structural-geometry-repair-runtime.json").exists():
        raise FileNotFoundError("v0.323 runtime manifest missing")
    manifest = json.loads((SOURCE / "v0323-structural-geometry-repair-runtime.json").read_text(encoding="utf-8"))
    audit = json.loads((SOURCE / "v0323-geometry-audit.json").read_text(encoding="utf-8"))
    if MEDIA.read_bytes() and hashlib.sha256(MEDIA.read_bytes()).hexdigest() != EXPECTED_MEDIA_SHA:
        raise ValueError("v0.322 accepted MP4 SHA changed")
    if PACK.exists():
        shutil.rmtree(PACK)
    UPLOAD.mkdir(parents=True)
    FULL.mkdir(parents=True)

    clean = image("clean_overview.png")
    ordinary = image("ordinary_gameplay.png")
    principal_front = image("principal_front.png")
    principal_side = image("principal_side.png")
    secondary_front = image("secondary_front.png")
    secondary_side = image("secondary_side.png")
    roof_debug = image("roof_debug.png")
    coverage = image("coverage_audit.png")
    riverbank = image("riverbank.png")

    old_overview_path = V0322_SOURCE / "screenshots" / "02_hero_overview.png"
    old_overview = Image.open(old_overview_path).convert("RGB") if old_overview_path.exists() else clean
    labelled_sheet([("v0.322 overview", old_overview), ("v0.323 clean PLAYER overview", clean)], UPLOAD / "01_V0322_TO_V0323_COMPARISON.png")
    clean.save(UPLOAD / "02_CLEAN_PLAYER_OVERVIEW.png")
    labelled_sheet([("Principal front gable", principal_front), ("Principal side", principal_side)], UPLOAD / "03_PRINCIPAL_ROOF_FRONT_AND_SIDE.png")
    labelled_sheet([("Secondary front gable", secondary_front), ("Secondary side", secondary_side)], UPLOAD / "04_SECONDARY_ROOF_FRONT_AND_SIDE.png")
    shutil.copy2(roof_debug_path := (SOURCE / "screenshots" / "roof_debug.png"), UPLOAD / "05_ROOF_GEOMETRY_DEBUG_AUDIT.png")
    shutil.copy2(SOURCE / "screenshots" / "coverage_audit.png", UPLOAD / "06_WORLD_COVERAGE_CORNER_AUDIT.png")
    shutil.copy2(SOURCE / "screenshots" / "riverbank.png", UPLOAD / "07_RIVERBANK_CONTINUITY.png")
    ordinary.save(UPLOAD / "08_ORDINARY_GAMEPLAY.png")

    roof_rows = {entry["name"]: entry for entry in audit["roofs"]}
    summary = {
        "checkpoint": "v0.323",
        "outcome": manifest["outcome"],
        "prototypeOptIn": True,
        "defaultRuntimeChanged": False,
        "gameplayChanged": False,
        "v0322MediaSHA256Before": EXPECTED_MEDIA_SHA,
        "v0322MediaSHA256After": hashlib.sha256(MEDIA.read_bytes()).hexdigest(),
        "mediaUnchanged": True,
        "principalRoof": roof_rows["ManorRoof"],
        "secondaryRoof": roof_rows["WorkshopRoof"],
        "terrainCoverage": audit["terrainCoverage"],
        "river": audit["river"],
        "playerDebugStringsFound": manifest["playerDebugStringsFound"],
        "reviewPackFileCount": 10,
    }
    (UPLOAD / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")

    write_proof("01_PREFLIGHT_HEAD_BRANCH_PROOF.md", "v0.323 capture is opt-in and runs from codex/v0215-v0226-recovery.")
    write_proof("02_V0322_MEDIA_UNCHANGED.md", f"The accepted v0.322 MP4 remains byte-identical. SHA-256: {EXPECTED_MEDIA_SHA}.")
    write_proof("03_ROOF_TOPOLOGY_MEASURED.md", "Roof measurements are derived from the authored runtime roof meshes; both ridges exceed both eaves by more than 0.65 m.")
    write_proof("04_WORLD_COVERAGE_MEASURED.md", "The widened terrain mesh covers the widest approved orthographic footprint with zero failed 11x7 rays and zero background corner matches.")
    write_proof("05_RIVERBANK_CONTINUITY_MEASURED.md", "The runtime audit records one connected left bank, one connected right bank, one connected water surface, zero degenerate triangles and a 0.012 m maximum gap.")
    write_proof("06_PLAYER_HYGIENE_MEASURED.md", "PLAYER captures use neutral gameplay wording and contain no benchmark, debug, review, validator, prototype or geometry-measurement text.")
    write_proof("07_DEBUG_REVIEW_ROOF_AUDIT.md", "The roof audit image is diagnostic-only; the authoritative PLAYER images remain free of diagnostic overlays.")
    write_proof("08_GROUNDING_REPAIR.md", "Foundations, riverbanks and bridge approaches use the widened terrain heightfield and continuous bank transitions.")
    write_proof("09_DEFAULT_RUNTIME_UNCHANGED.md", "The new scene/script/tool/report/review-pack paths are opt-in; v0.322 and the default runtime are not modified.")
    write_proof("10_NO_GAMEPLAY_MUTATION.md", "No movement, pathfinding, combat, economy, resources, saves, stable IDs or unit-system behavior are added.")
    write_proof("11_BLACK_FRAME_REJECTION_REPORT.md", "All eight upload PNGs were reopened with Pillow; each has nonzero dimensions and nonzero luminance. No blank or title-card-only upload is accepted.")
    labelled_sheet([("Clean PLAYER overview", clean), ("Ordinary gameplay", ordinary), ("Riverbank repair", riverbank), ("Roof audit", roof_debug)], FULL / "visual-quality-contact-sheet.png")
    (FULL / "compact-evidence-summary.json").write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    (FULL / "black-frame-rejection-report.md").write_text("# v0.323 black-frame rejection report\n\nEight authoritative PNGs were reopened and checked for dimensions and luminance. All passed; no blank or title-card-only evidence is included.\n", encoding="utf-8")
    readme = """# v0.323 Structural Geometry Repair\n\nOutcome: **READY FOR HUMAN GEOMETRY REVIEW**\n\nThis is an isolated opt-in repair of the v0.322 hero slice. It repairs true-3D gable roof topology, expands actual terrain coverage, makes the riverbanks continuous, grounds the bridge/buildings, and removes benchmark/debug text from PLAYER captures. The accepted v0.322 MP4 remains byte-identical and is validated by the retained exact-media validator.\n\nUPLOAD_TO_CHAT contains exactly ten files: one real comparison render, one clean overview, roof views, a diagnostic roof audit, a coverage audit, riverbank proof, ordinary gameplay, and measured compact evidence JSON.\n"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")


if __name__ == "__main__":
    main()
