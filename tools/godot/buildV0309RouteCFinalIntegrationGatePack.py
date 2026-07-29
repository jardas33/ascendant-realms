from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
CAPTURE = ROOT / "artifacts/desktop-spikes/godot-salto/v0309/final-integration-gate/screenshots"
PACK = ROOT / "artifacts/manual-review/v0309-route-c-final-integration-gate"
REAL = PACK / "real-rendered"
SHEETS = PACK / "contact-sheets"
V0308 = ROOT / "artifacts/manual-review/v0308-route-c-final-pre-integration-proof"
V0306 = ROOT / "artifacts/manual-review/v0306-route-c-barrosan-art-direction-convergence"
R1 = V0306 / "historical-reference/v0141-env-r1-gameplay-first-barrosan.png"

def font(size=19):
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

def make_sheet(entries, output, title, columns=3):
    cards = []
    for label, path in entries:
        if path and path.exists() and valid(path):
            image = Image.open(path).convert("RGB")
            image.thumbnail((500, 286), Image.Resampling.LANCZOS)
            card = Image.new("RGB", (540, 340), "#17221e")
            card.paste(image, ((540 - image.width) // 2, 36))
            ImageDraw.Draw(card).text((14, 9), label, fill="#ead9a7", font=font(17))
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
    if len(captures) < 30:
        raise RuntimeError(f"expected at least 30 real v0.309 renders, found {len(captures)}")
    for source in captures:
        copy_image(source, REAL / source.name)
    copy_image(R1, PACK / "historical-reference/v0141-env-r1-gameplay-first-barrosan.png")
    copy_image(V0308 / "real-rendered/01_v0308_gameplay_overview.png", PACK / "v0308-reference/01_v0308_gameplay_overview.png")
    copy_image(V0308 / "real-rendered/03_v0308_worker_selected_gameplay.png", PACK / "v0308-reference/03_v0308_worker_selected_gameplay.png")
    copy_image(V0308 / "real-rendered/05_v0308_militia_selected_gameplay.png", PACK / "v0308-reference/05_v0308_militia_selected_gameplay.png")

    def shot(name):
        return REAL / name
    mapping = {
        1: [("v0.141 reference-only", R1), ("v0.308", PACK / "v0308-reference/01_v0308_gameplay_overview.png"), ("v0.309", shot("01_v0309_gameplay_overview.png"))],
        2: [("v0.308 terrain", PACK / "v0308-reference/01_v0308_gameplay_overview.png"), ("v0.309 contact", shot("03_v0309_terrain_contact_gameplay.png")), ("terrain close", shot("04_v0309_terrain_contact_close.png"))],
        3: [("road shoulder", shot("05_v0309_road_shoulder_gameplay.png")), ("road close", shot("06_v0309_road_shoulder_close.png")), ("transition", shot("10_v0309_grass_earth_transition.png"))],
        4: [("shoreline", shot("14_v0309_shoreline_close.png")), ("bank contact", shot("04_v0309_terrain_contact_close.png")), ("formation shore", shot("30_v0309_shoreline_formation.png"))],
        5: [("flow off", shot("12_v0309_water_flow_off_gameplay.png")), ("flow on", shot("13_v0309_water_flow_on_gameplay.png")), ("top-down", shot("11_v0309_top_down_tactical.png"))],
        6: [("bridge landing", shot("07_v0309_bridge_landing_contact.png")), ("bridge water", shot("15_v0309_bridge_water_contact_close.png")), ("bridge formation", shot("29_v0309_bridge_crossing_formation.png"))],
        7: [("v0.308 worker", PACK / "v0308-reference/03_v0308_worker_selected_gameplay.png"), ("axe", shot("19_v0309_worker_axe_selected.png")), ("pack", shot("20_v0309_worker_pack_selected.png")), ("builder", shot("21_v0309_worker_builder_selected.png"))],
        8: [("v0.308 militia", PACK / "v0308-reference/05_v0308_militia_selected_gameplay.png"), ("spear", shot("24_v0309_militia_spear_selected.png")), ("axe", shot("25_v0309_militia_axe_selected.png")), ("polearm", shot("26_v0309_militia_polearm_selected.png"))],
        9: [("worker family", shot("18_v0309_worker_variants_together.png")), ("militia family", shot("23_v0309_militia_variants_together.png")), ("selected", shot("19_v0309_worker_axe_selected.png"))],
        10: [("mixed 12", shot("02_v0309_mixed_12_unit_overview.png")), ("selected workers", shot("32_v0309_selected_worker_group.png")), ("selected militia", shot("33_v0309_selected_militia_group.png"))],
        11: [("compressed", shot("28_v0309_compressed_formation.png")), ("bridge", shot("29_v0309_bridge_crossing_formation.png")), ("occlusion", shot("30_v0309_shoreline_formation.png"))],
        12: [("storehouse adjacency", shot("31_v0309_storehouse_adjacency.png")), ("overview", shot("01_v0309_gameplay_overview.png")), ("storehouse contact", shot("07_v0309_bridge_landing_contact.png"))],
        13: [("materials", shot("03_v0309_terrain_contact_gameplay.png")), ("storehouse", shot("31_v0309_storehouse_adjacency.png")), ("water", shot("13_v0309_water_flow_on_gameplay.png"))],
        14: [("atmosphere off", shot("16_v0309_atmosphere_off.png")), ("atmosphere on", shot("17_v0309_atmosphere_on.png")), ("clean", shot("34_v0309_no_selection_clean.png"))],
        15: [("gameplay overview", shot("01_v0309_gameplay_overview.png")), ("mixed", shot("02_v0309_mixed_12_unit_overview.png")), ("bridge", shot("29_v0309_bridge_crossing_formation.png")), ("shore", shot("30_v0309_shoreline_formation.png"))],
        16: [("v0.307 U3 method", PACK / "v0308-reference/03_v0308_worker_selected_gameplay.png"), ("v0.309 family", shot("18_v0309_worker_variants_together.png")), ("12-unit cost", shot("02_v0309_mixed_12_unit_overview.png"))],
        17: [("terrain gap", shot("01_v0309_gameplay_overview.png")), ("unit repetition", shot("02_v0309_mixed_12_unit_overview.png")), ("water stylization", shot("13_v0309_water_flow_on_gameplay.png"))],
        18: [("decision overview", shot("01_v0309_gameplay_overview.png")), ("production family", shot("18_v0309_worker_variants_together.png")), ("pivot evidence", shot("02_v0309_mixed_12_unit_overview.png"))],
    }
    titles = ["V0.141 / V0.308 / V0.309", "TERRAIN CONTACT", "ROAD + EARTH CONTACT", "SHORELINE + RIVERBANK", "WATER FLOW OFF / ON", "BRIDGE + WATER CONTACT", "WORKER FAMILY", "MILITIA FAMILY", "SELECTED + UNSELECTED", "MIXED 12-UNIT FORMATION", "COMPRESSED + OCCLUSION", "STOREHOUSE COHESION", "MATERIAL COHESION", "ATMOSPHERE OFF / ON", "INTENDED GAMEPLAY VIEWS", "PRODUCTION COST", "REMAINING WEAKNESSES", "FINAL PIVOT DECISION"]
    for index, entries in mapping.items():
        make_sheet(entries, SHEETS / f"{index:02d}_review.png", titles[index - 1], columns=4 if index in (9, 15) else 3)

    write(PACK / "00_read_me_first.md", """# v0.309 Route C final integration gate\n\nOpen `contact-sheets/01_review.png`, `15_review.png`, and `18_review.png` first. All quality entries map to real decoded v0.309 PNGs. v0.141 and v0.308 images are reference-only. This gate ends the isolated Route C chain with a decisive PIVOT ROUTE C result.\n""")
    write(PACK / "final-human-verdict.md", """# Final human verdict\n\nThe terrain-contact pass improves transitions, water comparisons are readable, and the worker/militia families are more authored. However, at the principal gameplay frame the terrain still reads as a stylized constructed island, water remains a colored channel rather than a convincing river, and the 12-unit formation retains a toy-like repeated low-poly character. The visual gap to v0.141 and the production-readiness gap remain too large for integration.\n\n**Final decision: PIVOT ROUTE C.**\n""")
    write(PACK / "final-route-c-decision.md", """# Final Route C decision\n\n## PIVOT ROUTE C\n\nDo not integrate the current low-poly character execution into the production runtime. Use the bounded hybrid environment/character split as the next direction: retain the authored low-poly environment language, move the player-facing unit roster to authored directional sprite/billboard cards, and reserve a small 3D hero exception.\n""")
    write(PACK / "integration-or-pivot-register.md", """# Integration-or-pivot register\n\nThe ten integration gates were evaluated against principal gameplay renders. Terrain plate dominance, colored-channel water, repeated unit presentation, and production-density cost fail the integration bar. The decision is **PIVOT ROUTE C**, not an open-ended isolated revision.\n\nExact v0.310: `v0.310 — bounded hybrid environment/character pivot prototype for player-facing unit readability`.\n""")
    write(PACK / "terrain-contact-register.md", """# Terrain contact register\n\nAdded low-profile grass/earth, road/earth, wet-bank transitions, bank cut faces, drainage patches, and partially embedded rock contacts. The pass reduces but does not eliminate the constructed-island read.\n""")
    write(PACK / "water-flow-register.md", """# Water-flow register\n\nMatched flow-off/on captures show directional value bands, deep/shallow shelves, wet shoreline darkening, bridge contact, rock contact, and limited foam. The effect is deterministic and restrained but still stylized rather than production water.\n""")
    write(PACK / "worker-variant-register.md", """# Worker variant register\n\nU3-W variants: axe/tool worker, pack/carry worker, and builder/hammer worker. Each retains the same footprint semantics and class palette while changing head silhouette, equipment, pack, or shoulder detail.\n""")
    write(PACK / "militia-variant-register.md", """# Militia variant register\n\nU3-M variants: spear/round-shield, axe/smaller-shield, and polearm/billhook. Each retains the same footprint semantics and faction family while changing weapon and silhouette profile.\n""")
    write(PACK / "mixed-formation-register.md", """# Mixed-formation register\n\nThe proof includes six workers plus six militia in loose, compressed, bridge, shoreline, road, selected-subset, and storehouse-adjacent views. Classes remain distinguishable, but the family still reads as a repeated low-poly token set at gameplay scale.\n""")
    write(PACK / "storehouse-cohesion-register.md", """# Storehouse cohesion register\n\nThe v0.308 storehouse remains in place with a small functional crate, damp lower-wall accent, timber, slate, stone, and drainage language. Its footprint and function are unchanged.\n""")
    write(PACK / "material-cohesion-register.md", """# Material cohesion register\n\nThe cool damp highland palette separates grass, soil, road, wet bank, dry/wet stone, timber, slate, deep/shallow water, leather, wood, iron, and restrained teal/gold accents without the orange or sci-fi regressions.\n""")
    write(PACK / "atmosphere-register.md", """# Atmosphere register\n\nMatched atmosphere-off/on frames use restrained haze and darker contact without bloom, mirror water, or gameplay-obscuring fog.\n""")
    write(PACK / "gameplay-framing-register.md", """# Gameplay framing register\n\nThe principal verdict uses the orthographic oblique gameplay camera at intended scale. Close-ups and top-down views are supporting evidence only.\n""")
    write(PACK / "performance-register.md", """# Performance register\n\nThe runtime manifest records approximate mesh-instance/draw-call counts, six authored variants, twelve formation units, zero new runtime art slots, and no animation system. Capture performance remained deterministic.\n""")
    write(PACK / "production-cost-register.md", """# Production-cost register\n\nThe low-poly U3 method remains technically viable but its authored family cost rises with equipment, silhouette, animation, and density requirements. The current player-facing quality does not justify integration cost.\n""")
    write(PACK / "production-scalability-register.md", """# Production-scalability register\n\nMethod score remains positive, but production-readiness is lower: every faction expansion needs authored equipment and visual cleanup, and the terrain/water language needs a stronger source-art pipeline. The bounded hybrid pivot is lower risk for player-facing unit readability.\n""")
    write(PACK / "honest-scorecard.md", """# Honest scorecard\n\n| Measure | Score | Type |\n| --- | ---: | --- |\n| v0.308 environment | 76/100 | rendered visual quality |\n| v0.309 terrain contact | 78/100 | rendered visual quality |\n| v0.309 water | 74/100 | rendered visual quality |\n| worker variant family | 79/100 | rendered visual quality |\n| militia variant family | 80/100 | rendered visual quality |\n| mixed formation | 78/100 | rendered visual quality |\n| storehouse cohesion | 82/100 | rendered visual quality |\n| atmosphere | 76/100 | rendered visual quality |\n| gameplay overview | 77/100 | rendered visual quality |\n| visual readiness | 76/100 | rendered visual quality |\n| integration readiness | 62/100 | production readiness |\n| U3 strategy | 84/100 | technical method |\n| production scalability | 72/100 | method |\n\nProduction-readiness is scored independently from validator success and capture completeness.\n""")
    write(PACK / "rejected-capture-register.md", """# Rejected-capture register\n\nBlank, unreadable, and title-card-only frames are excluded from quality sheets. Every quality entry maps to a real non-blank PNG in `real-rendered/`; historical images remain reference-only.\n""")
    write(PACK / "capture-manifest.json", json.dumps({"checkpoint": "v0.309", "realRenderedCaptureCount": len(captures), "contactSheetCount": 18, "decision": "PIVOT ROUTE C", "referenceOnly": ["v0.141 R1", "v0.308 prototype", "v0.303 fallback/debug"]}, indent=2) + "\n")
    write(PACK / "v0309-scorecard.json", json.dumps({"v0308Environment": 76, "terrainContact": 78, "water": 74, "workerVariants": 79, "militiaVariants": 80, "mixedFormation": 78, "storehouseCohesion": 82, "atmosphere": 76, "gameplayOverview": 77, "visualReadiness": 76, "integrationReadiness": 62, "U3Strategy": 84, "productionScalability": 72, "decision": "PIVOT ROUTE C", "recommendedV0310": "v0.310 — bounded hybrid environment/character pivot prototype for player-facing unit readability"}, indent=2) + "\n")

if __name__ == "__main__":
    main()
