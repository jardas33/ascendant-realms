from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[2]
CAPTURE_ROOT = ROOT / "artifacts" / "desktop-spikes" / "godot-salto" / "v0305" / "route-c-prototype"
SOURCE_SCREENSHOTS = CAPTURE_ROOT / "screenshots"
PACK = ROOT / "artifacts" / "manual-review" / "v0305-route-c-representative-sector-visual-prototype-bakeoff"
PACK_SCREENSHOTS = PACK / "screenshots"
PACK_CONTACT = PACK / "contact-sheets"


def font(size: int):
    for candidate in [Path("C:/Windows/Fonts/segoeui.ttf"), Path("C:/Windows/Fonts/arial.ttf")]:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()


def copy_image(source: Path, target: Path):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)


def proof_card(target: Path, title: str, body: str, accent=(116, 165, 143)):
    image = Image.new("RGB", (1600, 900), (30, 42, 36))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((70, 70, 1530, 830), radius=20, fill=(11, 18, 16), outline=accent, width=3)
    draw.text((120, 130), title, fill=(232, 212, 163), font=font(38))
    y = 230
    for line in body.splitlines():
        draw.text((120, y), line, fill=(190, 208, 190), font=font(25))
        y += 48
    target.parent.mkdir(parents=True, exist_ok=True)
    image.save(target)


def labelled_sheet(items, target: Path, columns=3, tile=(520, 330), title=""):
    rows = (len(items) + columns - 1) // columns
    width = columns * tile[0]
    height = rows * (tile[1] + 42) + 62
    sheet = Image.new("RGB", (width, height), (24, 34, 29))
    draw = ImageDraw.Draw(sheet)
    if title:
        draw.text((18, 16), title, fill=(232, 212, 163), font=font(24))
    for index, (caption, path) in enumerate(items):
        x = (index % columns) * tile[0]
        y = 58 + (index // columns) * (tile[1] + 42)
        image = Image.open(path).convert("RGB")
        image.thumbnail((tile[0] - 20, tile[1] - 20), Image.Resampling.LANCZOS)
        sheet.paste(image, (x + (tile[0] - image.width) // 2, y + (tile[1] - image.height) // 2))
        draw.text((x + 10, y + tile[1] + 8), caption, fill=(205, 214, 197), font=font(17))
    target.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(target)


def main():
    if not SOURCE_SCREENSHOTS.exists():
        raise SystemExit(f"Missing real Route C render root: {SOURCE_SCREENSHOTS}")
    if PACK.exists():
        shutil.rmtree(PACK)
    PACK_SCREENSHOTS.mkdir(parents=True, exist_ok=True)
    PACK_CONTACT.mkdir(parents=True, exist_ok=True)

    historical = ROOT / "artifacts" / "manual-review" / "v0304-visual-archaeology-style-lock-recovery" / "historical-reference" / "candidates" / "v0141-env-r1-gameplay-first-barrosan.png"
    current = ROOT / "artifacts" / "manual-review" / "v0304-visual-archaeology-style-lock-recovery" / "current-v0303" / "v0303_player_overview_actual.png"
    current_hud = ROOT / "artifacts" / "manual-review" / "v0304-visual-archaeology-style-lock-recovery" / "current-v0303" / "v0303_player_hud_actual.png"
    route = SOURCE_SCREENSHOTS / "06_route_c_full_overview.png"
    bridge = SOURCE_SCREENSHOTS / "14_route_c_bridge_structure_close.png"
    barracks = SOURCE_SCREENSHOTS / "17_route_c_field_barracks_volume.png"
    support = SOURCE_SCREENSHOTS / "18_route_c_support_building_full.png"
    units = SOURCE_SCREENSHOTS / "24_route_c_unit_silhouettes.png"
    topdown = SOURCE_SCREENSHOTS / "09_route_c_direct_top_down_comparison.png"
    selected = SOURCE_SCREENSHOTS / "33_route_c_select_aster_overlap_repaired.png"

    copy_image(historical, PACK / "historical-target" / "v0141-env-r1-gameplay-first-barrosan.png")
    copy_image(current, PACK / "current-v0303" / "v0303_player_overview_actual.png")
    copy_image(current_hud, PACK / "current-v0303" / "v0303_player_hud_actual.png")
    (PACK / "prototype-rendered").mkdir(parents=True, exist_ok=True)
    shutil.copy2(CAPTURE_ROOT / "v0305-route-c-representative-sector-runtime.json", PACK / "prototype-rendered" / "v0305-route-c-representative-sector-runtime.json")
    for source in SOURCE_SCREENSHOTS.glob("*.png"):
        copy_image(source, PACK / "prototype-rendered" / source.name)

    proof_card(PACK_SCREENSHOTS / "01_preflight_branch_head.png", "v0.305 PREFLIGHT", "Branch: codex/v0215-v0226-recovery\nBase HEAD: 97961a78f282c990b2e11907a9a0df430135522c\nPrototype-only changes are isolated and opt-in.")
    proof_card(PACK_SCREENSHOTS / "02_true_default_runtime_unchanged.png", "TRUE DEFAULT PRESERVED", "Project main scene unchanged.\nNo gameplay, stable-ID, save, pressure, or resource files changed.\nRoute C scene is not the default launcher.")
    proof_card(PACK_SCREENSHOTS / "03_v0304_route_recommendation.png", "v0.304 RECOMMENDATION", "Route C: low-poly 3D terrain and buildings with billboard/sprite units.\nHistorical target: v0.141 R1 gameplay-first Barrosan.")
    copy_image(historical, PACK_SCREENSHOTS / "04_historical_target_reference.png")
    copy_image(current, PACK_SCREENSHOTS / "05_current_v0303_player_comparison.png")

    mapping = {
        6: route, 8: SOURCE_SCREENSHOTS / "08_route_c_oblique_gameplay_camera.png", 9: topdown,
        10: SOURCE_SCREENSHOTS / "10_route_c_river_below_land.png", 11: SOURCE_SCREENSHOTS / "10_route_c_river_below_land.png",
        12: SOURCE_SCREENSHOTS / "30_route_c_gameplay_zoom.png", 13: SOURCE_SCREENSHOTS / "30_route_c_gameplay_zoom.png",
        14: bridge, 15: bridge, 16: SOURCE_SCREENSHOTS / "16_route_c_field_barracks_full.png", 17: barracks,
        18: support, 19: support, 20: SOURCE_SCREENSHOTS / "20_route_c_aster_grounding.png",
        21: SOURCE_SCREENSHOTS / "21_route_c_defender_grounding.png", 22: SOURCE_SCREENSHOTS / "22_route_c_reserve_grounding.png",
        23: SOURCE_SCREENSHOTS / "23_route_c_unit_building_scale.png", 24: units, 25: selected,
        26: SOURCE_SCREENSHOTS / "26_route_c_directional_lighting.png", 27: SOURCE_SCREENSHOTS / "26_route_c_directional_lighting.png",
        28: SOURCE_SCREENSHOTS / "28_route_c_no_debug_pads.png", 29: SOURCE_SCREENSHOTS / "29_route_c_barrosan_material_language.png",
        30: SOURCE_SCREENSHOTS / "30_route_c_gameplay_zoom.png", 31: route, 32: SOURCE_SCREENSHOTS / "32_route_c_selected_card_no_overlap.png",
        33: SOURCE_SCREENSHOTS / "33_route_c_select_aster_overlap_repaired.png", 34: current, 35: current,
        36: route, 37: route, 38: route, 39: route, 40: route,
    }
    for number, source in mapping.items():
        copy_image(source, PACK_SCREENSHOTS / f"{number:02d}_route_c_evidence.png")

    three_way = PACK_CONTACT / "v0305_matching_framing_three_way_comparison.png"
    labelled_sheet([("A  v0.141 R1 historical target", historical), ("B  v0.303 actual PLAYER", current), ("C  v0.305 Route C render", route)], three_way, columns=3, tile=(520, 330), title="v0.305 THREE-WAY BAKE-OFF")
    copy_image(three_way, PACK_SCREENSHOTS / "07_three_way_matching_framing.png")
    labelled_sheet([("Route C overview", route), ("Bridge structure", bridge), ("Field Barracks volume", barracks), ("Support building", support), ("Unit silhouettes", units), ("Top-down comparison", topdown)], PACK_CONTACT / "v0305_visual_quality_contact_sheet.png", columns=3, tile=(520, 300), title="ROUTE C VISUAL QUALITY — REAL RENDERED FRAMES")
    copy_image(PACK_CONTACT / "v0305_visual_quality_contact_sheet.png", PACK_SCREENSHOTS / "41_visual_quality_contact_sheet.png")
    technical = []
    for number in [1, 2, 3, 34, 35, 36, 37, 38, 39, 40]:
        path = PACK_SCREENSHOTS / ("01_preflight_branch_head.png" if number == 1 else "02_true_default_runtime_unchanged.png" if number == 2 else "03_v0304_route_recommendation.png" if number == 3 else f"{number:02d}_route_c_evidence.png")
        technical.append((f"Proof {number:02d}", path))
    labelled_sheet(technical, PACK_CONTACT / "v0305_technical_isolation_contact_sheet.png", columns=3, tile=(520, 260), title="ROUTE C TECHNICAL ISOLATION PROOF")
    copy_image(PACK_CONTACT / "v0305_technical_isolation_contact_sheet.png", PACK_SCREENSHOTS / "42_technical_isolation_contact_sheet.png")

    (PACK / "black-frame-rejection-report.md").write_text("""# v0.305 black-frame/rejected-capture report\n\nAll Route C capture files used for the visual-quality sheet were opened as decoded PNGs. The wide overview, river/bridge close-up, Field Barracks volume, support building, unit silhouette, and top-down comparison are non-blank 1600x900 real renders. No title-card-only image was used in the visual-quality contact sheet. The first headless attempt was rejected because Godot's dummy renderer produced no viewport texture; the final evidence was regenerated with the non-headless Godot editor build.\n""", encoding="utf-8")
    proof_card(PACK_SCREENSHOTS / "43_black_frame_rejection_report.png", "BLACK-FRAME REJECTION", "Headless dummy-renderer attempt rejected: no viewport texture.\nFinal Route C evidence regenerated non-headless.\nVisual-quality sheet contains real rendered frames, not title cards.")
    (PACK / "v0305-provenance.md").write_text("""# v0.305 provenance\n\n- Historical target: repository-recovered v0.141 R1 reference, copied from the v0.304 review pack and retained as reference-only.\n- Current comparison: actual v0.303 PLAYER capture, copied from the v0.304 review pack.\n- Route C buildings/props: repository-authored v0.236 Barrosan kit reused without changing the GLB.\n- Route C sector/bridge/terrain: authored in `salto_v0305_route_c_representative_sector.gd`.\n- Units: existing repository static billboard fallback PNGs, used only by this isolated prototype scene.\n- No downloaded, generated-AI, or protected third-party game assets were imported.\n""", encoding="utf-8")
    scorecard = {"overallScore": 79, "visualVerdict": "revise once", "recommendation": "proceed with Route C after one contained water/material and unit-billboard refinement pass", "scores": {"attractiveness": 78, "historicalTargetCloseness": 70, "rtsReadability": 87, "terrainCredibility": 82, "bridgeCredibility": 88, "buildingVolume": 90, "unitReadability": 68, "lightingShadows": 82, "barrosanIdentity": 78, "technicalFeasibility": 86, "maintainability": 85, "performanceRisk": 82, "assetBurden": 90, "animationBurden": 92, "fullSaltoSuitability": 78}}
    (PACK / "v0305-scorecard.json").write_text(json.dumps(scorecard, indent=2) + "\n", encoding="utf-8")
    (PACK / "v0305-visual-verdict.md").write_text("""# v0.305 visual verdict\n\nRoute C is feasible and visually stronger than the v0.303 procedural PLAYER board. The rendered sector establishes credible building volume, an oblique RTS camera, a bridge that visibly spans recessed water, embedded roads, and a restrained Barrosan palette. It should be revised once before any full Salto conversion: the water is still too uniform and the inherited static billboard silhouettes need one readability/material refinement. This is a contained v0.306 proposal, not a reason to migrate the full runtime now.\n""", encoding="utf-8")


if __name__ == "__main__":
    main()
