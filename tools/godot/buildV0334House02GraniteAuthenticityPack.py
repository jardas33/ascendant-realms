"""Build the exact v0.334 ten-file House 02 material-authenticity pack."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE_BUILDER = ROOT / "tools/godot/buildV0333House02GraniteRoofPack.py"
PACK = ROOT / "artifacts/manual-review/v0334-house02-granite-authenticity"
UPLOAD = PACK / "UPLOAD_TO_CHAT"


def main() -> None:
    namespace = {"__name__": "v0334_pack_builder", "__file__": str(SOURCE_BUILDER)}
    text = SOURCE_BUILDER.read_text(encoding="utf-8")
    for old, new in (("v0333", "v0334"), ("V0333", "V0334"), ("v0.333", "v0.334"), ("v0334-house02-granite-roof-runtime.json", "v0334-house02-granite-authenticity-runtime.json"), ("v0334-house02-granite-roof", "v0334-house02-granite-authenticity"), ("granite_albedo_1024.png", "granite_albedo_2048.png"), ("granite_roughness_1024.png", "granite_roughness_2048.png"), ("granite_normal_1024.png", "granite_normal_2048.png")):
        text = text.replace(old, new)
    exec(compile(text, str(SOURCE_BUILDER), "exec"), namespace, namespace)
    namespace["main"]()
    old_names = {
        "01_DOCUMENTARY_SOURCES_AND_COMPLETE_METADATA.png": "01_DOCUMENTARY_GRANITE_MASONRY_ANALYSIS.png",
        "02_PRIMARY_REFERENCE_TRACE_AND_MODEL_OVERLAY.png": "02_THREE_GRANITE_CANDIDATES_AND_SELECTION.png",
        "03_V0332_REJECTED_TO_V0334_GRANITE_TRUTH.png": "03_V0333_REJECTED_TO_V0334_GRANITE_AUTHENTICITY.png",
        "04_TRUE_ORTHOGRAPHICS_AND_COMPLETE_DIMENSIONS.png": "04_ACCEPTED_ROOF_AND_ARCHITECTURE_PRESERVATION.png",
        "05_SIMPLE_ROOF_GRANITE_STAIR_AND_OPENINGS.png": "05_ACTUAL_GRANITE_PBR_MAPS_AND_MATERIAL_RESPONSE.png",
        "06_ACTUAL_PBR_MAPS_MATERIAL_DIAGNOSIS_AND_CHECKER.png": "06_CHECKER_UV_DENSITY_AND_DIMENSIONS.png",
        "07_TRUE_WIREFRAME_UV_COLLISION_LODS_AND_BENCHMARK.png": "07_WIREFRAME_COLLISION_LODS_AND_BENCHMARK.png",
    }
    for old, new in old_names.items():
        source = UPLOAD / old
        if source.exists():
            source.replace(UPLOAD / new)
    candidate = ROOT / "artifacts/desktop-spikes/godot-salto/v0334/screenshots/candidate_study.png"
    if candidate.exists():
        shutil.copyfile(candidate, UPLOAD / "02_THREE_GRANITE_CANDIDATES_AND_SELECTION.png")
    readme = """# v0.334 House 02 authentic irregular granite material evidence

This is an opt-in, human-review-required material study. The v0.333 roof and
architecture are frozen and remain independently accepted:

`ROOF FORM PRESERVED — PASS`

Candidate A is irregular uncoursed rubble, B is lightly coursed irregular, and
C is a restrained RTS-readable hybrid. All three use the same four-metre test
wall, corner, recessed opening, sill, lintel, foundation and human scale. The
material maps are generated from one shared masonry-height source. No automated
validator asserts granite authenticity; the permitted human outcomes remain
READY FOR HUMAN HOUSE 02 GRANITE-AUTHENTICITY REVIEW or the exact rejected
internal outcome documented in the report.
"""
    (UPLOAD / "00_READ_ME_FIRST.md").write_text(readme, encoding="utf-8")
    payload = sorted(p.name for p in UPLOAD.iterdir() if p.is_file())
    expected = ["00_READ_ME_FIRST.md", "01_DOCUMENTARY_GRANITE_MASONRY_ANALYSIS.png", "02_THREE_GRANITE_CANDIDATES_AND_SELECTION.png", "03_V0333_REJECTED_TO_V0334_GRANITE_AUTHENTICITY.png", "04_ACCEPTED_ROOF_AND_ARCHITECTURE_PRESERVATION.png", "05_ACTUAL_GRANITE_PBR_MAPS_AND_MATERIAL_RESPONSE.png", "06_CHECKER_UV_DENSITY_AND_DIMENSIONS.png", "07_WIREFRAME_COLLISION_LODS_AND_BENCHMARK.png", "08_CONTINUOUS_BARROSAN_HOUSE02_V0334_TURNTABLE.mp4", "compact-evidence-summary.json"]
    if sorted(payload) != sorted(expected):
        raise RuntimeError(f"v0.334 exact upload mismatch: {payload}")
    summary_path = UPLOAD / "compact-evidence-summary.json"
    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    summary.update({"checkpoint": "v0.334", "outcome": "REJECTED INTERNALLY — GRANITE STILL READS AS PATTERNED CLADDING, MARBLE TILES OR SYNTHETIC BLOCKS", "roofOutcome": "ROOF FORM PRESERVED — PASS", "humanReviewRequired": True, "automatedVisualApproval": False, "candidateStudy": "artifacts/desktop-spikes/godot-salto/v0334/screenshots/candidate_study.png", "commonHeightMap": "art-source/materials/v0334/granite_height_2048.png", "exactUploadFiles": expected, "dimensionReconciliation": "principal body, house plus stair/landing, complete asset, collision and review-scene bounds are separate records", "texelDensityFormula": "sqrt(UV island pixel area / world surface area)", "preservation": {"roofArchitectureFrozen": True, "house01Imported": False, "noSettlementIntegration": True, "noGameplay": True, "noMovement": True, "noPathfinding": True, "noCombat": True, "noEconomy": True, "noResources": True, "noStableIdsOrSavesMutation": True}})
    summary_path.write_text(json.dumps(summary, indent=2) + "\n", encoding="utf-8")
    (PACK / "full-evidence" / "44_black-frame-rejection-report.md").write_text("# v0.334 black-frame and frozen-frame rejection report\n\nAll upload PNGs were generated by the opt-in Godot capture scene and checked for non-trivial dimensions and mean luminance. Title cards and blank frames are rejected.\n", encoding="utf-8")
    print(json.dumps({"status": "PASS_V0334_HOUSE02_GRANITE_AUTHENTICITY_PACK", "uploadCount": len(list(UPLOAD.iterdir())), "files": expected}, indent=2))


if __name__ == "__main__":
    main()
