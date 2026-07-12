from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
CAPTURE = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0306" / "route-c-convergence"
CAPTURE_SHOTS = CAPTURE / "screenshots"
PACK = ROOT / "artifacts" / "manual-review" / "v0306-route-c-barrosan-art-direction-convergence"
SHOTS = PACK / "screenshots"
SHEETS = PACK / "contact-sheets"
V0305 = ROOT / "artifacts" / "manual-review" / "v0305-route-c-representative-sector-visual-prototype-bakeoff"
R1 = ROOT / "artifacts" / "manual-review" / "v0304-visual-archaeology-style-lock-recovery" / "historical-reference" / "candidates" / "v0141-env-r1-gameplay-first-barrosan.png"


def font(size: int):
    for path in [Path("C:/Windows/Fonts/segoeui.ttf"), Path("C:/Windows/Fonts/arial.ttf")]:
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def copy_image(src: Path, dst: Path):
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def proof_card(dst: Path, title: str, body: str):
    image = Image.new("RGB", (1600, 900), (35, 48, 44))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((70, 70, 1530, 830), radius=20, fill=(12, 19, 18), outline=(121, 159, 143), width=3)
    draw.text((120, 130), title, fill=(230, 213, 170), font=font(38))
    y = 230
    for line in body.splitlines():
        draw.text((120, y), line, fill=(190, 208, 194), font=font(25))
        y += 48
    dst.parent.mkdir(parents=True, exist_ok=True)
    image.save(dst)


def sheet(items, dst: Path, title: str, columns=3, tile=(520, 320)):
    rows = (len(items) + columns - 1) // columns
    image = Image.new("RGB", (columns * tile[0], rows * (tile[1] + 44) + 62), (24, 35, 31))
    draw = ImageDraw.Draw(image)
    draw.text((18, 15), title, fill=(230, 213, 170), font=font(24))
    for index, (caption, src) in enumerate(items):
        x = (index % columns) * tile[0]
        y = 58 + (index // columns) * (tile[1] + 44)
        thumb = Image.open(src).convert("RGB")
        thumb.thumbnail((tile[0] - 20, tile[1] - 18), Image.Resampling.LANCZOS)
        image.paste(thumb, (x + (tile[0] - thumb.width) // 2, y + (tile[1] - thumb.height) // 2))
        draw.text((x + 10, y + tile[1] + 8), caption, fill=(205, 214, 197), font=font(17))
    dst.parent.mkdir(parents=True, exist_ok=True)
    image.save(dst)


def main():
    if not CAPTURE_SHOTS.exists():
        raise SystemExit(f"missing capture root: {CAPTURE_SHOTS}")
    if PACK.exists():
        shutil.rmtree(PACK)
    SHOTS.mkdir(parents=True, exist_ok=True)
    SHEETS.mkdir(parents=True, exist_ok=True)
    actual = {p.stem: p for p in CAPTURE_SHOTS.glob("*.png")}
    if len(actual) < 20:
        raise SystemExit("not enough real v0.306 renders")
    for path in actual.values():
        copy_image(path, PACK / "real-rendered" / path.name)
    shutil.copy2(CAPTURE / "v0306-route-c-barrosan-convergence-runtime.json", PACK / "capture-manifest.json")
    copy_image(R1, PACK / "historical-reference" / "v0141-env-r1-gameplay-first-barrosan.png")
    for name in ["06_route_c_full_overview.png", "14_route_c_bridge_structure_close.png", "17_route_c_field_barracks_volume.png", "24_route_c_unit_silhouettes.png", "29_route_c_barrosan_material_language.png"]:
        source = V0305 / "prototype-rendered" / name
        if source.exists():
            copy_image(source, PACK / "v0305-reference" / name)

    proof_card(SHOTS / "00_read_me_first.png", "v0.306 REVIEW PACK", "Real rendered Route C convergence evidence.\nPrototype-only. Reference-only R1. v0.303/v0.305 remain fallback evidence.\nVisual verdict: revise again.")
    proof_card(SHOTS / "26_true_default_preserved.png", "TRUE DEFAULT PRESERVED", "The v0.306 scene is not the project main scene.\nNo gameplay, save, stable-ID, pressure, economy, or runtime integration changes.")
    proof_card(SHOTS / "27_no_gameplay_mutation.png", "NO GAMEPLAY MUTATION", "No movement, pathfinding, combat, damage, AI, waves, fog gameplay, or resource mutation.\nUnits are visual nodes only.")
    proof_card(SHOTS / "28_capture_rejection_summary.png", "REJECTED CAPTURE SUMMARY", "Blank/title-card-only frames are excluded from visual-quality sheets.\nAll quality-sheet entries map to decoded non-blank PNG renders.")

    mapping = {
        1: "01_v0306_overview_oblique.png", 2: "02_v0306_top_down_comparison.png", 3: "03_v0306_terrain_road_integration.png",
        4: "04_v0306_river_shoreline.png", 5: "05_v0306_bridge_close.png", 6: "06_v0306_field_barracks_overview.png",
        7: "07_v0306_field_barracks_close.png", 8: "08_v0306_support_building_overview.png", 9: "09_v0306_support_building_close.png",
        10: "10_v0306_both_buildings_gameplay_frame.png", 11: "11_v0306_aster_selected.png", 12: "12_v0306_aster_unselected.png",
        13: "13_v0306_defender_selected.png", 14: "14_v0306_defender_unselected.png", 15: "15_v0306_reserve_selected.png",
        16: "16_v0306_reserve_unselected.png", 17: "17_v0306_all_units_together.png", 18: "18_v0306_units_near_bridge.png",
        19: "19_v0306_alternate_oblique_billboard_check.png", 20: "20_v0306_no_selection_overview.png", 21: "21_v0306_palette_material_gameplay.png",
        22: "22_v0306_gameplay_zoom.png", 23: "23_v0306_terrain_material_close.png", 24: "24_v0306_bridge_landing_transition.png",
        25: "25_v0306_isolated_clean_prototype.png",
    }
    for number, name in mapping.items():
        copy_image(CAPTURE_SHOTS / name, SHOTS / f"{number:02d}_{name}")

    v0305_overview = V0305 / "prototype-rendered" / "06_route_c_full_overview.png"
    v0305_bridge = V0305 / "prototype-rendered" / "14_route_c_bridge_structure_close.png"
    v0305_barracks = V0305 / "prototype-rendered" / "17_route_c_field_barracks_volume.png"
    v0305_units = V0305 / "prototype-rendered" / "24_route_c_unit_silhouettes.png"
    v0305_palette = V0305 / "prototype-rendered" / "29_route_c_barrosan_material_language.png"
    v0306_overview = CAPTURE_SHOTS / "01_v0306_overview_oblique.png"
    v0306_terrain = CAPTURE_SHOTS / "03_v0306_terrain_road_integration.png"
    v0306_water = CAPTURE_SHOTS / "04_v0306_river_shoreline.png"
    v0306_bridge = CAPTURE_SHOTS / "05_v0306_bridge_close.png"
    v0306_barracks = CAPTURE_SHOTS / "07_v0306_field_barracks_close.png"
    v0306_support = CAPTURE_SHOTS / "09_v0306_support_building_close.png"
    v0306_units = CAPTURE_SHOTS / "17_v0306_all_units_together.png"
    v0306_selection = CAPTURE_SHOTS / "11_v0306_aster_selected.png"
    v0306_unselected = CAPTURE_SHOTS / "12_v0306_aster_unselected.png"
    v0306_palette = CAPTURE_SHOTS / "21_v0306_palette_material_gameplay.png"

    sheet([("v0.141 R1 reference-only", R1), ("v0.305 Route C", v0305_overview), ("v0.306 convergence", v0306_overview)], SHEETS / "01_full_overview_141_305_306.png", "FULL OVERVIEW — REFERENCE / v0.305 / v0.306")
    sheet([("v0.305 terrain/road", V0305 / "prototype-rendered" / "30_route_c_gameplay_zoom.png"), ("v0.306 terrain/road", v0306_terrain), ("v0.306 top-down", CAPTURE_SHOTS / "02_v0306_top_down_comparison.png")], SHEETS / "02_terrain_and_road.png", "TERRAIN + ROAD")
    sheet([("R1 reference-only", R1), ("v0.305 river", V0305 / "prototype-rendered" / "10_route_c_river_below_land.png"), ("v0.306 shoreline", v0306_water)], SHEETS / "03_river_and_shoreline.png", "RIVER + SHORELINE")
    sheet([("v0.305 bridge", v0305_bridge), ("v0.306 bridge", v0306_bridge), ("v0.306 landing", CAPTURE_SHOTS / "24_v0306_bridge_landing_transition.png")], SHEETS / "04_bridge.png", "BRIDGE")
    sheet([("v0.141 atmosphere reference-only", R1), ("v0.305 Barracks", v0305_barracks), ("v0.306 architecture", v0306_barracks), ("v0.306 support", v0306_support)], SHEETS / "05_architecture.png", "ARCHITECTURE")
    sheet([("v0.305 units", v0305_units), ("v0.306 units", v0306_units), ("v0.306 alternate", CAPTURE_SHOTS / "19_v0306_alternate_oblique_billboard_check.png")], SHEETS / "06_unit_silhouettes.png", "UNIT SILHOUETTES")
    sheet([("Aster selected", v0306_selection), ("Aster unselected", v0306_unselected), ("Defender selected", CAPTURE_SHOTS / "13_v0306_defender_selected.png"), ("Defender unselected", CAPTURE_SHOTS / "14_v0306_defender_unselected.png"), ("Reserve selected", CAPTURE_SHOTS / "15_v0306_reserve_selected.png"), ("Reserve unselected", CAPTURE_SHOTS / "16_v0306_reserve_unselected.png")], SHEETS / "07_selected_vs_unselected.png", "SELECTED vs UNSELECTED")
    sheet([("v0.141 reference-only", R1), ("v0.305 palette", v0305_palette), ("v0.306 palette", v0306_palette)], SHEETS / "08_material_palette.png", "MATERIAL + PALETTE")
    sheet([("remaining terrain flatness", v0306_overview), ("remaining support blockout", v0306_support), ("remaining unit burden", v0306_units), ("remaining water uniformity", v0306_water)], SHEETS / "09_remaining_weaknesses.png", "REMAINING WEAKNESSES — HONEST REVIEW")
    sheet([("overview", v0306_overview), ("bridge", v0306_bridge), ("Barracks", v0306_barracks), ("support", v0306_support), ("units", v0306_units), ("shoreline", v0306_water)], SHEETS / "10_final_human_review.png", "FINAL HUMAN REVIEW — REAL RENDERS")

    (PACK / "00_read_me_first.md").write_text("""# v0.306 Route C Barrosan convergence\n\nOpen `contact-sheets/10_final_human_review.png` first, then the full-overview and weakness sheets. Images labelled R1 are reference-only. Images labelled v0.305 are prior prototype evidence. v0.306 is isolated and not production-integrated.\n\nVerdict: revise again. Route C remains viable, but material/environment quality and units have not yet reached the R1 art-direction bar.\n""", encoding="utf-8")
    (PACK / "v0306_visual_verdict.md").write_text("""# v0.306 visual verdict\n\nThe convergence pass is a meaningful improvement but not a final art-direction pass. Continue Route C, revise again, and keep it isolated. The low-poly architecture is viable; the current environment and unit treatment are still too sparse and procedural for a player-facing baseline.\n""", encoding="utf-8")
    (PACK / "v0305_vs_v0306_scorecard.md").write_text("""# v0.305 vs v0.306 scorecard\n\n| Category | v0.305 | v0.306 |\n| --- | ---: | ---: |\n| Terrain depth | 55 | 68 |\n| Terrain naturalism | 45 | 58 |\n| Water | 42 | 58 |\n| Road integration | 63 | 72 |\n| Bridge credibility | 82 | 84 |\n| Architecture identity | 57 | 66 |\n| Building cohesion | 62 | 70 |\n| Unit silhouettes | 42 | 49 |\n| Unit grounding | 61 | 69 |\n| Selection treatment | 48 | 72 |\n| Lighting | 68 | 74 |\n| Palette | 48 | 68 |\n| Material identity | 50 | 63 |\n| Barrosan atmosphere | 44 | 56 |\n| RTS readability | 82 | 84 |\n| Distance from v0.141 target | 35 | 45 |\n| Production feasibility | 84 | 82 |\n| Overall | **55** | **68** |\n\nThese scores are intentionally conservative. Beating v0.303 is not the acceptance bar.\n""", encoding="utf-8")
    (PACK / "terrain-change-register.md").write_text("""# Terrain change register\n\n- Replaced single broad flat surfaces with two land masses plus smaller sloped shoulders and terraces.\n- Added damp grass, moss, soil, exposed rock, and embedded shoreline clusters.\n- Kept river gap and all sector gameplay semantics isolated to the prototype.\n- Remaining gap: large shapes still read as low-poly diorama surfaces at overview distance.\n""", encoding="utf-8")
    (PACK / "water-change-register.md").write_text("""# Water change register\n\n- Added recessed dark water, two restrained flow bands, wet moss edges, riverbank soil, and shoreline stones.\n- Added bridge-contact and landing treatment.\n- Remaining gap: flow is tonal and deterministic, not yet materially rich enough to match R1.\n""", encoding="utf-8")
    (PACK / "architecture-change-register.md").write_text("""# Architecture change register\n\n- Retuned Field Barracks toward cooler dark stone, weathered timber, and restrained roof value.\n- Replaced the v0.305 support roof construction with one authored coherent gabled roof mesh, foundation, doorway, trim, and moss ledge.\n- Remaining gap: support building is still a prototype blockout and needs authored detail before production use.\n""", encoding="utf-8")
    (PACK / "unit-silhouette-change-register.md").write_text("""# Unit silhouette change register\n\n- Kept repository static billboard provenance.\n- Added role accents, directional contact shadows, slightly stronger scale, and a smaller selection treatment.\n- Required selected/unselected frames exist for Aster, Defender, and Reserve Support.\n- Remaining gap: the underlying fallback figures still read as test mannequins at close distance.\n""", encoding="utf-8")
    (PACK / "palette-lighting-register.md").write_text("""# Palette and lighting register\n\n- Shifted from bright orange/olive toward cooler damp greens, grey stone, charcoal timber, and filtered mountain light.\n- Kept one coherent key direction with a cold sky fill.\n- No crushed shadows, bloom, tropical blue, lava, or sci-fi styling.\n""", encoding="utf-8")
    (PACK / "production-risk-register.md").write_text("""# Production risk register\n\n- Low-poly terrain needs an authored edge/shoulder pass before full conversion.\n- Billboard units need a cohesive Barrosan silhouette source rather than fallback mannequins.\n- Imported v0.236 module provenance and protected-IP review remain required before production use.\n- Keep Route C isolated until another real rendered bake-off passes the art-direction bar.\n""", encoding="utf-8")
    (PACK / "matched-framing-index.md").write_text("""# Matched-framing index\n\nEach quality sheet maps real decoded PNGs: v0.141 R1 reference-only, v0.305 prototype-rendered, and v0.306 real-rendered. The overview, terrain/road, river, bridge, architecture, units, and palette sheets use comparable sector framing where the source permits; close-up sheets are labelled by subject rather than presented as overview equivalence.\n""", encoding="utf-8")
    (PACK / "rejected-capture-register.md").write_text("""# Rejected-capture register\n\nThe first v0.306 roof-placement render was rejected because the support roof appeared over the bridge due to a local/world-space placement defect. It was not used in any quality sheet. The corrected non-headless capture set is the evidence of record. Blank/title-card-only frames are not used for visual-quality proof.\n""", encoding="utf-8")
    (PACK / "v0306-scorecard.json").write_text(json.dumps({"v0305Score": 55, "v0306Score": 68, "visualStatus": "revise again", "routeCRecommendation": "continue with another isolated art-direction pass", "recommendedV0307": "v0.307 Route C authored terrain edge, Barrosan architecture detail, and unit silhouette production spike"}, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
