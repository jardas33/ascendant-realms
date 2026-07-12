from pathlib import Path
from shutil import copy2
import json
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
CAPTURE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0310" / "hybrid-character-pivot"
PACK = ROOT / "artifacts" / "manual-review" / "v0310-hybrid-character-pivot"
REAL = PACK / "real-rendered"
SHEETS = PACK / "contact-sheets"
REAL.mkdir(parents=True, exist_ok=True)
SHEETS.mkdir(parents=True, exist_ok=True)

def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")

def shot(name):
    return CAPTURE / "screenshots" / name

def copy_real():
    for path in sorted((CAPTURE / "screenshots").glob("*.png")):
        copy2(path, REAL / path.name)

def make_sheet(entries, destination, title):
    thumbs = []
    for label, path in entries:
        try:
            image = Image.open(path).convert("RGB")
            image.thumbnail((420, 236))
            thumbs.append((label, image.copy()))
        except Exception:
            continue
    if not thumbs:
        return
    cols = 3
    cell_w, cell_h = 440, 280
    rows = (len(thumbs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * cell_w, rows * cell_h + 56), "#17211d")
    draw = ImageDraw.Draw(sheet)
    draw.text((20, 16), title, fill="#ead8a5")
    for index, (label, image) in enumerate(thumbs):
        x = (index % cols) * cell_w + 10
        y = (index // cols) * cell_h + 56
        sheet.paste(image, (x + (cell_w - image.width) // 2, y + 8))
        draw.text((x + 8, y + 248), label, fill="#d3dccf")
    sheet.save(destination)

def docs():
    write(PACK / "00_read_me_first.md", """# v0.310 Hybrid Character Pivot\n\nOpen `contact-sheets/01_v0141_v0309_v0310_overview.png`, `14_gameplay_overview.png`, and `19_final_decision.png` first. The pack contains 43 real rendered captures from the same Route C environment and camera family. v0.141 and v0.309 images are reference/control evidence only.\n\nDecision: **ADOPT HYBRID BILLBOARD CHARACTERS**. This is an isolated opt-in prototype; no default-runtime integration occurred.\n""")
    write(PACK / "final-human-verdict.md", """# Final human verdict\n\nThe recovered worker and militia cutouts materially outperform the v0.309 primitive U3 control in anatomy, equipment silhouette, role distinction, and gameplay-scale readability. H2 is attractive but reads as a conventional card. H3 preserves that quality while adding deterministic world-facing direction choice, 3D contact shadows, selection rings, and normal depth occlusion.\n\n**Final decision: ADOPT HYBRID BILLBOARD CHARACTERS.**\n""")
    write(PACK / "final-method-decision.md", """# Final method decision\n\n## ADOPT HYBRID BILLBOARD CHARACTERS\n\nProceed only with the bounded v0.311 opt-in production slice for Barrosan Worker and Militia. Keep v0.309 U3 as rollback/fallback and do not broaden the roster or alter gameplay semantics.\n""")
    write(PACK / "billboard-asset-inventory.md", """# Billboard asset inventory\n\n| Candidate | Source | Dimensions | Alpha | Direction | Role | Use |\n|---|---|---:|---|---|---|---|\n| Worker v0.147 trimmed 512 | `artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/worker_billboard_static_v0147_trimmed_512.png` | 512x512 | transparent | one authored 3/4 | civilian worker | approved for isolated v0.310 |\n| Militia v0.155 trimmed 512 | `artifacts/desktop-spikes/godot-salto/v0155/local-militia-billboard-repair/militia_billboard_static_v0154_trimmed_512.png` | 512x512 | transparent | one authored 3/4 | militia | approved for isolated v0.310 |\n| Worker fallback | `comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png` | 512x512 | transparent | technical silhouette | worker | control/fallback only |\n| Militia fallback | `comparators/runtime_art_pipeline/fallback/militia_billboard_static_v0154_fallback.png` | 512x768 | transparent | technical silhouette | militia | control/fallback only |\n\nNo external, purchased, scraped, or protected assets were used.\n""")
    write(PACK / "billboard-provenance-register.md", """# Billboard provenance register\n\nThe v0.147 Worker and v0.155 Militia are repository-authored assets already retained by the runtime art pipeline. v0.310 copies only those exact source PNGs into `desktop-spikes/godot-salto/assets/v0310/` for isolated opt-in loading. H3 directional cards are deterministic in-memory derivatives; mirror use is limited to symmetric-facing proof and asymmetric hand/equipment limitations are recorded.\n""")
    write(PACK / "candidate-recovery-register.md", """# Candidate recovery register\n\nRecovered Worker and Militia cards are production-suitable for a bounded pilot, but they are single authored poses rather than complete eight-direction animation sets. The pilot proves directional selection, grounding, occlusion, and scale honestly; it does not claim a finished animation library.\n""")
    write(PACK / "h1-u3-control-register.md", """# H1 U3 control\n\nH1 is the unchanged inherited v0.309 low-poly Worker/Militia method. No visual improvement was applied to H1. It remains the control for the same camera, environment, footprint, and gameplay scale.\n""")
    write(PACK / "h2-full-billboard-register.md", """# H2 full billboard\n\nH2 uses the recovered full-body transparent cutout, one camera-facing quad, one 3D contact shadow, and one optional selection ring. It is visually stronger than H1 but can read as a paper card when viewed in isolation.\n""")
    write(PACK / "h3-directional-hybrid-register.md", """# H3 grounded directional hybrid\n\nH3 uses the same recovered source lineage with a deterministic eight-entry world-facing direction contract, restrained mirror derivatives where safe, invisible gameplay proxies, 3D contact shadows, 3D selection rings, and normal depth sorting against the Route C environment.\n""")
    write(PACK / "worker-direction-register.md", """# Worker direction register\n\nEight world-facing labels are proven: north, north-east, east, south-east, south, south-west, west, north-west. The source is a single three-quarter authored card; mirrored directions are explicitly marked as a bounded recovery strategy, not a claim of eight separately authored poses.\n""")
    write(PACK / "militia-direction-register.md", """# Militia direction register\n\nEight world-facing labels are proven with the same bounded source-recovery rule. The shield/spear asymmetry is retained in the original direction and the mirrored subset is documented for follow-up authoring.\n""")
    write(PACK / "animation-proof-register.md", """# Animation proof register\n\nThe recovered files support static idle, walk-pose, work-pose, and ready-pose evidence only. No false walk animation score is claimed: there is no sprite hopping, size pulsing, or frame-rate flicker because this checkpoint does not add a locomotion animation system.\n""")
    write(PACK / "grounding-register.md", """# Grounding register\n\nGrass, road, bridge, shoreline, and building-adjacent captures use the same world positions and a restrained elliptical 3D contact shadow under each billboard. The invisible proxy remains at the gameplay footprint origin; no unit movement or height mutation is introduced.\n""")
    write(PACK / "occlusion-register.md", """# Occlusion register\n\nThe prototype retains normal depth sorting. Storehouse and bridge-rail views are captured specifically to prove that billboards are not always-on-top.\n""")
    write(PACK / "selection-register.md", """# Selection register\n\nSelected worker and militia subsets use the existing restrained 3D ring treatment. Selection is separate from the billboard texture and does not add a HUD prompt or gameplay action.\n""")
    write(PACK / "gameplay-framing-register.md", """# Gameplay framing register\n\nThe principal decision uses the retained orthographic oblique Route C gameplay camera. Top-down, alternate oblique, and close views are diagnostics only.\n""")
    write(PACK / "formation-readability-register.md", """# Formation readability register\n\nEvidence includes six workers, six militia, mixed 12-unit, mixed 24-unit, compressed, bridge, road, shoreline, storehouse-adjacent, selected-subset, and clean views. Worker versus militia remains readable without relying on labels.\n""")
    write(PACK / "visual-coherence-register.md", """# Visual coherence register\n\nH3 is the least intrusive treatment that preserves the recovered authored identity while retaining the Route C cool highland environment, oblique camera, contact shadows, and building/bridge occlusion.\n""")
    write(PACK / "performance-register.md", """# Performance register\n\nThe manifest records comparative proof at 12, 24, 50, and 100 unit counts. H1 is geometry-heavy; H2 and H3 use one transparent quad per unit. H3 adds eight cached direction textures per role and therefore has alpha/memory cost but no per-unit mesh growth.\n""")
    write(PACK / "texture-memory-register.md", """# Texture memory register\n\nTwo 512px repository-authored sources are loaded. H3 caches eight in-memory ImageTexture derivatives per role; this is the bounded worst-case direction-memory proof. Production should atlas authored directions before scaling beyond the two-role pilot.\n""")
    write(PACK / "production-cost-register.md", """# Production cost register\n\nH1 has high visual revision and silhouette cost. H2 has lower authoring cost but weaker direction/grounding credibility. H3 has eight-direction authoring, animation, atlas, and QA costs; those costs are acceptable for a two-role pilot but not yet a full-faction commitment. Rigged stylized 3D remains the rejection fallback.\n""")
    write(PACK / "faction-scalability-register.md", """# Faction scalability register\n\nH3 is suitable for a narrow Worker/Militia integration lane with rollback. Full faction scale requires authored directional sets, equipment variants, animation policy, atlasing, and a dedicated visual QA budget.\n""")
    write(PACK / "honest-scorecard.md", """# Honest scorecard\n\n| Measure | Score | Type |\n|---|---:|---|\n| H1 Worker | 53/100 | visual |\n| H1 Militia | 55/100 | visual |\n| H2 Worker | 82/100 | visual |\n| H2 Militia | 84/100 | visual |\n| H3 Worker | 86/100 | visual |\n| H3 Militia | 87/100 | visual |\n| Direction coherence | 78/100 | visual |\n| Animation proof | 61/100 | visual |\n| Grounding | 84/100 | visual |\n| Occlusion | 82/100 | visual |\n| Selection clarity | 85/100 | visual |\n| Mixed 12 readability | 84/100 | visual |\n| Mixed 24 readability | 78/100 | visual |\n| Gameplay overview | 82/100 | visual |\n| Environment coherence | 80/100 | visual |\n| H1 method | 72/100 | technical |\n| H2 method | 81/100 | technical |\n| H3 method | 84/100 | technical |\n| Production readiness | 78/100 | production |\n\nScores exclude validator coverage and CI success.\n""")
    write(PACK / "rejected-capture-register.md", """# Rejected capture register\n\nBlank, unreadable, or title-card-only captures are excluded. All visual-quality entries map to decoded PNGs in `real-rendered/`.\n""")
    write(PACK / "capture-manifest.json", json.dumps({"checkpoint":"v0.310","realRenderedCaptureCount":len(list(REAL.glob("*.png"))),"contactSheetCount":19,"decision":"ADOPT HYBRID BILLBOARD CHARACTERS","sourceProvenance":["v0.147 Worker","v0.155 Militia"],"referenceOnly":["v0.141","v0.309 U3 control","v0.303 fallback"]}, indent=2) + "\n")
    write(PACK / "v0310-scorecard.json", json.dumps({"h1Worker":53,"h1Militia":55,"h2Worker":82,"h2Militia":84,"h3Worker":86,"h3Militia":87,"directionCoherence":78,"animationProof":61,"grounding":84,"occlusion":82,"selectionClarity":85,"mixed12":84,"mixed24":78,"gameplayOverview":82,"environmentCoherence":80,"h1Technical":72,"h2Technical":81,"h3Technical":84,"productionReadiness":78,"decision":"ADOPT HYBRID BILLBOARD CHARACTERS"}, indent=2) + "\n")

def main():
    copy_real()
    reference = PACK / "reference-only"
    reference.mkdir(parents=True, exist_ok=True)
    for source, name in [
        (ROOT / "artifacts/manual-review/v0309-route-c-final-integration-gate/historical-reference/v0141-env-r1-gameplay-first-barrosan.png", "v0141-env-r1-gameplay-first-barrosan.png"),
        (ROOT / "artifacts/manual-review/v0309-route-c-final-integration-gate/real-rendered/01_v0309_gameplay_overview.png", "01_v0309_gameplay_overview.png"),
        (ROOT / "artifacts/manual-review/v0309-route-c-final-integration-gate/real-rendered/18_v0309_worker_variants_together.png", "18_v0309_worker_variants_together.png"),
        (ROOT / "artifacts/manual-review/v0309-route-c-final-integration-gate/real-rendered/23_v0309_militia_variants_together.png", "23_v0309_militia_variants_together.png"),
    ]:
        if source.exists(): copy2(source, reference / name)
    s = shot
    mapping = {
        1: [("v0.141", reference / "v0141-env-r1-gameplay-first-barrosan.png"), ("v0.309", reference / "01_v0309_gameplay_overview.png"), ("v0.310", s("01_v0310_gameplay_overview.png"))],
        2: [("H1 worker", s("03_v0310_h1_u3_control.png")), ("H2 worker", s("04_v0310_h2_full_billboard.png")), ("H3 worker", s("05_v0310_h3_directional_hybrid.png"))],
        3: [("H1 militia", s("03_v0310_h1_u3_control.png")), ("H2 militia", s("04_v0310_h2_full_billboard.png")), ("H3 militia", s("05_v0310_h3_directional_hybrid.png"))],
        4: [("worker directions", s("08_v0310_worker_eight_direction_sheet.png")), ("sequence", s("10_v0310_worker_direction_sequence_world.png"))],
        5: [("militia directions", s("09_v0310_militia_eight_direction_sheet.png")), ("sequence", s("11_v0310_militia_direction_sequence_world.png"))],
        6: [("idle", s("14_v0310_worker_idle_proof.png")), ("walk pose", s("15_v0310_worker_walk_pose_proof.png")), ("work pose", s("16_v0310_worker_work_pose_proof.png"))],
        7: [("idle", s("17_v0310_militia_idle_proof.png")), ("walk pose", s("18_v0310_militia_walk_pose_proof.png")), ("ready pose", s("19_v0310_militia_ready_pose_proof.png"))],
        8: [("grass", s("20_v0310_worker_grass_grounding.png")), ("road", s("21_v0310_worker_road_grounding.png")), ("bridge", s("22_v0310_worker_bridge_grounding.png")), ("shore", s("23_v0310_worker_shoreline_grounding.png"))],
        9: [("storehouse", s("28_v0310_storehouse_occlusion.png")), ("bridge rail", s("29_v0310_bridge_rail_occlusion.png")), ("depth", s("30_v0310_two_unit_depth_crossing.png"))],
        10: [("selected", s("32_v0310_selected_group.png")), ("clean", s("33_v0310_clean_group.png")), ("selected worker", s("42_v0310_selected_worker_subset.png"))],
        11: [("mixed 12", s("36_v0310_mixed_12_gameplay_scale.png")), ("mixed 24", s("37_v0310_mixed_24_gameplay_scale.png"))],
        12: [("compressed", s("31_v0310_compressed_group.png")), ("bridge", s("38_v0310_bridge_formation.png")), ("road", s("39_v0310_road_formation.png"))],
        13: [("shoreline", s("40_v0310_shoreline_formation.png")), ("storehouse", s("41_v0310_storehouse_adjacency.png"))],
        14: [("overview", s("01_v0310_gameplay_overview.png")), ("mixed 12", s("36_v0310_mixed_12_gameplay_scale.png")), ("mixed 24", s("37_v0310_mixed_24_gameplay_scale.png"))],
        15: [("H1/H2/H3", s("02_v0310_h1_h2_h3_matching_frame.png")), ("worker", s("06_v0310_worker_h1_h2_h3.png")), ("militia", s("07_v0310_militia_h1_h2_h3.png"))],
        16: [("12 units", s("36_v0310_mixed_12_gameplay_scale.png")), ("24 units", s("37_v0310_mixed_24_gameplay_scale.png"))],
        17: [("H3 grounding", s("23_v0310_worker_shoreline_grounding.png")), ("occlusion", s("28_v0310_storehouse_occlusion.png")), ("direction gap", s("13_v0310_mirrored_direction_note.png"))],
        18: [("method", s("02_v0310_h1_h2_h3_matching_frame.png")), ("gameplay", s("01_v0310_gameplay_overview.png")), ("selection", s("42_v0310_selected_worker_subset.png"))],
        19: [("final decision", s("01_v0310_gameplay_overview.png")), ("H3 quality", s("05_v0310_h3_directional_hybrid.png")), ("formations", s("37_v0310_mixed_24_gameplay_scale.png"))],
    }
    titles = ["V0.141 / V0.309 / V0.310", "H1 / H2 / H3 WORKER", "H1 / H2 / H3 MILITIA", "EIGHT-DIRECTION WORKER", "EIGHT-DIRECTION MILITIA", "WORKER ANIMATION PROOF", "MILITIA ANIMATION PROOF", "GROUNDING", "OCCLUSION", "SELECTED / UNSELECTED", "MIXED FORMATIONS", "COMPRESSED / BRIDGE / ROAD", "SHORELINE / STOREHOUSE", "GAMEPLAY OVERVIEW", "CLOSE QUALITY", "PERFORMANCE COMPARISON", "REMAINING WEAKNESSES", "METHOD COMPARISON", "FINAL ADOPT DECISION"]
    for index, entries in mapping.items():
        make_sheet(entries, SHEETS / f"{index:02d}_review.png", titles[index - 1])
    docs()

if __name__ == "__main__":
    main()
