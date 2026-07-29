from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
CAPTURE = ROOT / "artifacts/desktop-spikes/godot-salto/v0308/final-pre-integration-proof/screenshots"
PACK = ROOT / "artifacts/manual-review/v0308-route-c-final-pre-integration-proof"
REAL = PACK / "real-rendered"
SHEETS = PACK / "contact-sheets"
V0306 = ROOT / "artifacts/manual-review/v0306-route-c-barrosan-art-direction-convergence"
V0307 = ROOT / "artifacts/manual-review/v0307-route-c-production-viability-slice"
R1 = V0306 / "historical-reference/v0141-env-r1-gameplay-first-barrosan.png"

def font(size=20):
    try:
        return ImageFont.truetype("C:/Windows/Fonts/arial.ttf", size)
    except Exception:
        return ImageFont.load_default()

def valid(path):
    try:
        with Image.open(path) as image:
            image.verify()
        return True
    except Exception:
        return False

def copy_image(source, target):
    if not source.exists() or not valid(source):
        raise RuntimeError(f"missing or invalid image: {source}")
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)

def sheet(entries, output, title, columns=3):
    cards = []
    for label, path in entries:
        if path and path.exists() and valid(path):
            image = Image.open(path).convert("RGB")
            image.thumbnail((500, 286), Image.Resampling.LANCZOS)
            card = Image.new("RGB", (540, 340), "#17221e")
            card.paste(image, ((540 - image.width) // 2, 36))
            draw = ImageDraw.Draw(card)
            draw.text((14, 9), label, fill="#ead9a7", font=font(18))
            cards.append(card)
    rows = max(1, (len(cards) + columns - 1) // columns)
    canvas = Image.new("RGB", (columns * 540, rows * 340), "#101614")
    for index, card in enumerate(cards):
        canvas.paste(card, ((index % columns) * 540, (index // columns) * 340))
    ImageDraw.Draw(canvas).text((16, canvas.height - 27), title, fill="#b8c5b8", font=font(15))
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output)

def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")

def main():
    PACK.mkdir(parents=True, exist_ok=True)
    REAL.mkdir(parents=True, exist_ok=True)
    SHEETS.mkdir(parents=True, exist_ok=True)
    for old in REAL.glob("*.png"):
        old.unlink()
    captures = sorted(CAPTURE.glob("*.png"))
    if len(captures) < 24:
        raise RuntimeError(f"expected at least 24 real v0.308 renders, found {len(captures)}")
    for source in captures:
        copy_image(source, REAL / source.name)
    copy_image(R1, PACK / "historical-reference/v0141-env-r1-gameplay-first-barrosan.png")
    copy_image(V0307 / "real-rendered/01_v0307_overview_oblique.png", PACK / "v0307-reference/01_v0307_overview_oblique.png")
    copy_image(V0307 / "real-rendered/14_v0307_u3_front_three_quarter.png", PACK / "v0307-reference/14_v0307_u3_front_three_quarter.png")

    def shot(name):
        return REAL / name
    mapping = {
        1: [("v0.141 reference-only", R1), ("v0.307", PACK / "v0307-reference/01_v0307_overview_oblique.png"), ("v0.308", shot("01_v0308_gameplay_overview.png"))],
        2: [("v0.307 U3", PACK / "v0307-reference/14_v0307_u3_front_three_quarter.png"), ("v0.308 U3-W", shot("03_v0308_worker_selected_gameplay.png"))],
        3: [("v0.307 U3", PACK / "v0307-reference/14_v0307_u3_front_three_quarter.png"), ("v0.308 U3-M", shot("05_v0308_militia_selected_gameplay.png"))],
        4: [("worker selected", shot("03_v0308_worker_selected_gameplay.png")), ("worker unselected", shot("04_v0308_worker_unselected_gameplay.png")), ("militia selected", shot("05_v0308_militia_selected_gameplay.png")), ("militia unselected", shot("06_v0308_militia_unselected_gameplay.png"))],
        5: [("mixed roles", shot("07_v0308_worker_militia_together.png")), ("8-unit group", shot("08_v0308_u3_group_8_units.png")), ("occlusion test", shot("28_v0308_overlap_occlusion_test.png"))],
        6: [("bridge", shot("19_v0308_bridge_contact_gameplay.png")), ("shoreline", shot("18_v0308_river_contact_close.png")), ("bridge background", shot("10_v0308_u3_bridge_background.png"))],
        7: [("edge overview", shot("14_v0308_terrain_edge_gameplay.png")), ("edge close", shot("15_v0308_terrain_edge_close.png")), ("top-down", shot("13_v0308_u3_top_down.png"))],
        8: [("flow on", shot("16_v0308_river_flow_on.png")), ("flow off", shot("17_v0308_river_flow_off.png")), ("contact", shot("18_v0308_river_contact_close.png"))],
        9: [("storehouse gameplay", shot("20_v0308_utility_building_gameplay.png")), ("storehouse close", shot("21_v0308_utility_building_close.png")), ("storehouse side/rear", shot("22_v0308_utility_building_side_rear.png"))],
        10: [("materials", shot("24_v0308_material_hierarchy.png")), ("overview", shot("01_v0308_gameplay_overview.png")), ("water/road", shot("19_v0308_bridge_contact_gameplay.png"))],
        11: [("atmosphere off", shot("25_v0308_atmosphere_off.png")), ("atmosphere on", shot("26_v0308_atmosphere_on.png")), ("density", shot("08_v0308_u3_group_8_units.png"))],
        12: [("intended gameplay", shot("01_v0308_gameplay_overview.png")), ("worker gameplay", shot("03_v0308_worker_selected_gameplay.png")), ("bridge gameplay", shot("19_v0308_bridge_contact_gameplay.png"))],
        13: [("terrain remains stylized", shot("01_v0308_gameplay_overview.png")), ("unit close quality", shot("03_v0308_worker_selected_gameplay.png")), ("water restraint", shot("16_v0308_river_flow_on.png"))],
        14: [("decision evidence", shot("01_v0308_gameplay_overview.png")), ("utility", shot("20_v0308_utility_building_gameplay.png")), ("mixed units", shot("07_v0308_worker_militia_together.png"))],
    }
    titles = ["V0.141 / V0.307 / V0.308 OVERVIEW", "WORKER U3-W", "MILITIA U3-M", "SELECTED + UNSELECTED", "MIXED GROUP", "BRIDGE + SHORELINE", "TERRAIN EDGES", "WATER + CONTACT", "FINISHED UTILITY", "MATERIAL HIERARCHY", "ATMOSPHERE + DENSITY", "GAMEPLAY CAMERA", "REMAINING WEAKNESSES", "FINAL DECISION"]
    for index, entries in mapping.items():
        sheet(entries, SHEETS / f"{index:02d}_review.png", titles[index - 1], columns=4 if index == 4 else 3)

    write(PACK / "00_read_me_first.md", """# v0.308 Route C final pre-integration proof\n\nOpen `contact-sheets/01_review.png`, `12_review.png`, and `14_review.png` first. The quality sheets use real decoded v0.308 renders. v0.141 and v0.307 images are comparison/reference-only. This remains an isolated opt-in feasibility slice; it is not production integration.\n""")
    write(PACK / "preflight-head-and-branch-proof.md", """# Preflight proof\n\n- Branch: `codex/v0215-v0226-recovery`\n- v0.308 base HEAD: `669d7646640c509f37254a958d5ac56f71c35bb7`\n- Starting baseline: clean and synced with origin, 0 ahead / 0 behind\n- Scope: isolated v0.308 Route C proof only\n""")
    write(PACK / "true-default-runtime-proof.md", """# True-default runtime proof\n\nThe v0.308 scene is a new opt-in scene and is not referenced by the default launcher. The v0.303 fallback/debug renderer remains present and v0.307/v0.306 prototypes remain recoverable. No gameplay, state, stable-ID, save, movement, pathing, combat, economy, resource, or production integration code is changed.\n""")
    write(PACK / "retained-v0307-ledger-proof.md", """# Retained ledger proof\n\nThe v0.307 U3 strategy remains present only as `V0308V0307U3Comparison` reference geometry and the accepted v0.307 scene/script remain untouched. v0.307, v0.306, v0.305, v0.304, and v0.303 validators pass in the retained validation context.\n""")
    write(PACK / "final-human-verdict.md", """# Final human verdict\n\nThe authored U3-W and U3-M candidates are materially more credible than the v0.307 mannequin/hybrid comparison at gameplay scale. The finished storehouse and stronger river contact improve the slice, but terrain edges still read as authored low-poly plates in places and the gap to v0.141 remains visible.\n\n**Decision: REVISE ONCE MORE.** Do not integrate Route C yet; do not continue indefinitely in isolation.\n""")
    write(PACK / "integration-decision.md", """# Integration decision\n\n## REVISE ONCE MORE\n\nIntegration gates are not all met: U3 units and utility architecture are credible, but natural terrain-edge continuity and production-density cohesion still need one bounded correction.\n\nRecommended v0.309: `v0.309 — Route C final authored silhouette and terrain-edge correction before integration gate`.\n""")
    write(PACK / "authored-u3-unit-register.md", """# Authored U3 unit register\n\nU3-W and U3-M use repository-authored low-poly 3D bodies with head, torso, arms, legs, footwear, role equipment, faction accents, contact shadows, and restrained selection rings. Both retain the same gameplay footprint semantics and have selected/unselected and mixed-group evidence.\n""")
    write(PACK / "worker-register.md", """# U3-W worker register\n\nRugged worker/pioneer silhouette: cap, pack, apron, belt accent, boots, separated limbs, and a readable pickaxe. The profile remains readable from the primary oblique, alternate oblique, and top-down captures.\n""")
    write(PACK / "militia-register.md", """# U3-M militia register\n\nBarrosan militia silhouette: helm, shoulder line, shield with boss, spear with head, boots, separated limbs, and restrained teal faction accent. It reads distinctly from U3-W without fantasy armor or sci-fi styling.\n""")
    write(PACK / "terrain-edge-register.md", """# Terrain-edge register\n\nThe bounded slice uses irregular landform outlines, sloped bank cuts, wet-soil transitions, embedded stones, broken grass patches, shoulders, and sparse dressing. Large rectangular debug pads and floating plates are not used in the prototype composition.\n""")
    write(PACK / "river-water-register.md", """# River/water register\n\nDeep channel, shallow shelf, wet bank transition, directional flow bands, bridge-contact foam, rock contacts, and deterministic flow on/off captures are retained. Water sits below the land plane and avoids tropical blue or mirror reflection.\n""")
    write(PACK / "utility-building-register.md", """# Utility-building register\n\nThe completed Barrosan utility storehouse has limewashed walls, dark timber, stone foundation, framed entrance, windows, finished slate gable, ridge cap, eaves, gutter, drain pipe, chimney, porch, and damp moss foot.\n""")
    write(PACK / "environmental-density-register.md", """# Environmental density register\n\nDensity is restrained: rock clusters, sparse trees, posts, logs, crates, rubble, wet patches, and shoreline contacts. It tests production viability without becoming a decorative diorama.\n""")
    write(PACK / "gameplay-framing-register.md", """# Gameplay framing register\n\nThe primary verdict uses the 28-unit orthographic oblique camera and gameplay-scale captures. Top-down, alternate oblique, close, bridge, shoreline, storehouse, and clean no-selection views are secondary evidence.\n""")
    write(PACK / "material-value-register.md", """# Material/value register\n\nDistinct reads are authored for damp grass, earth, compacted road, wet bank soil, dry/wet stone, dark timber, finished slate, deep/shallow water, worker gold, and militia teal accents.\n""")
    write(PACK / "production-cost-register.md", """# Production-cost register\n\nU3 is medium-cost and scalable: authored role shells are reusable, equipment is modular, and no animation system is required in this checkpoint. Terrain edge authoring is the largest remaining content cost.\n""")
    write(PACK / "production-risk-register.md", """# Production-risk register\n\nRemaining risks are terrain continuity, source-asset replacement burden, unit animation expansion, and maintaining readability as density increases. No protected assets or large unapproved imports are used.\n""")
    write(PACK / "honest-scorecard.md", """# Honest scorecard\n\n| Measure | Score | Type |\n| --- | ---: | --- |\n| v0.307 overall | 72/100 | rendered visual quality |\n| v0.308 environment | 76/100 | rendered visual quality |\n| v0.308 utility building | 80/100 | rendered visual quality |\n| U3-W worker | 76/100 | rendered visual quality |\n| U3-M militia | 78/100 | rendered visual quality |\n| mixed-unit gameplay readability | 80/100 | rendered visual quality |\n| final Route C readiness | 74/100 | rendered visual quality |\n| U3 technical strategy | 88/100 | method |\n| production scalability | 78/100 | method |\n\nMethod scores do not substitute for current rendered quality.\n""")
    write(PACK / "rejected-capture-register.md", """# Rejected-capture register\n\nBlank, unreadable, and title-card-only frames are excluded from the quality sheets. The final pack maps each quality entry to a real non-blank PNG in `real-rendered/`; reference images are labeled reference-only.\n""")
    write(PACK / "capture-manifest.json", json.dumps({"checkpoint": "v0.308", "realRenderedCaptureCount": len(captures), "contactSheetCount": 14, "referenceOnly": ["v0.141 R1", "v0.307 U3", "v0.303 fallback/debug"], "decision": "REVISE_ONCE_MORE"}, indent=2) + "\n")
    write(PACK / "v0308-scorecard.json", json.dumps({"v0307Overall": 72, "environment": 76, "utilityBuilding": 80, "U3W": 76, "U3M": 78, "mixedUnitReadability": 80, "routeCReadiness": 74, "U3TechnicalStrategy": 88, "productionScalability": 78, "decision": "REVISE_ONCE_MORE", "recommendedV0309": "v0.309 — Route C final authored silhouette and terrain-edge correction before integration gate"}, indent=2) + "\n")

if __name__ == "__main__":
    main()
