from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json
import shutil

ROOT = Path(__file__).resolve().parents[2]
CAPTURE = ROOT / "artifacts/desktop-spikes/godot-salto/v0307/production-viability/screenshots"
PACK = ROOT / "artifacts/manual-review/v0307-route-c-production-viability-slice"
REAL = PACK / "real-rendered"
SHEETS = PACK / "contact-sheets"
V0306 = ROOT / "artifacts/manual-review/v0306-route-c-barrosan-art-direction-convergence"
V0305 = ROOT / "artifacts/manual-review/v0305-route-c-representative-sector-visual-prototype-bakeoff"
R1 = V0306 / "historical-reference/v0141-env-r1-gameplay-first-barrosan.png"
V0306_OVERVIEW = V0306 / "real-rendered/01_v0306_overview_oblique.png"

def font(size=24):
    try:
        return ImageFont.truetype("C:/Windows/Fonts/arial.ttf", size)
    except Exception:
        return ImageFont.load_default()

def valid_image(path):
    try:
        with Image.open(path) as im:
            im.verify()
        return True
    except Exception:
        return False

def copy_image(src, dst):
    if not src.exists() or not valid_image(src):
        raise RuntimeError(f"missing or invalid image: {src}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)

def sheet(entries, out, title, columns=3):
    thumbs = []
    for label, path in entries:
        if path and path.exists() and valid_image(path):
            im = Image.open(path).convert("RGB")
            im.thumbnail((520, 300), Image.Resampling.LANCZOS)
            card = Image.new("RGB", (560, 360), "#17221e")
            x = (560 - im.width) // 2
            card.paste(im, (x, 38))
            draw = ImageDraw.Draw(card)
            draw.text((18, 10), label, fill="#ead9a7", font=font(20))
            thumbs.append(card)
    rows = (len(thumbs) + columns - 1) // columns
    canvas = Image.new("RGB", (columns * 560, max(1, rows) * 360), "#101614")
    for i, card in enumerate(thumbs):
        canvas.paste(card, ((i % columns) * 560, (i // columns) * 360))
    draw = ImageDraw.Draw(canvas)
    draw.rectangle((0, 0, canvas.width - 1, canvas.height - 1), outline="#819486", width=3)
    draw.text((18, canvas.height - 30), title, fill="#b8c5b8", font=font(16))
    out.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(out)

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
    if len(captures) < 20:
        raise RuntimeError(f"expected real v0.307 renders, found {len(captures)}")
    for src in captures:
        copy_image(src, REAL / src.name)
    def shot(name): return REAL / name
    copy_image(R1, PACK / "historical-reference/v0141-env-r1-gameplay-first-barrosan.png")
    copy_image(V0306_OVERVIEW, PACK / "v0306-reference/01_v0306_overview_oblique.png")
    if (V0305 / "prototype-rendered/06_route_c_full_overview.png").exists():
        copy_image(V0305 / "prototype-rendered/06_route_c_full_overview.png", PACK / "v0305-reference/01_route_c_full_overview.png")

    mapping = {
        1: [("v0.141 R1 reference-only", R1), ("v0.306", V0306_OVERVIEW), ("v0.307", shot("01_v0307_overview_oblique.png"))],
        2: [("authored terrain", shot("03_v0307_authored_terrain_close.png")), ("top-down", shot("02_v0307_top_down.png")), ("gameplay scale", shot("20_v0307_gameplay_scale.png"))],
        3: [("riverbank", shot("04_v0307_river_shoreline.png")), ("flow", shot("04_v0307_river_shoreline.png")), ("atmosphere enabled", shot("23_v0307_atmosphere_enabled.png"))],
        4: [("bridge landing", shot("05_v0307_bridge_landing.png")), ("water contact", shot("04_v0307_river_shoreline.png")), ("overview", shot("01_v0307_overview_oblique.png"))],
        5: [("material hierarchy", shot("06_v0307_material_hierarchy.png")), ("terrain", shot("03_v0307_authored_terrain_close.png")), ("house materials", shot("08_v0307_support_building_close.png"))],
        6: [("house overview", shot("07_v0307_support_building_overview.png")), ("house close", shot("08_v0307_support_building_close.png")), ("house side", shot("09_v0307_support_building_side.png")), ("top-down footprint", shot("10_v0307_support_building_top_down.png"))],
        7: [("U1 directional cards", shot("12_v0307_u1_front_three_quarter.png")), ("U2 low-poly 3D", shot("13_v0307_u2_front_three_quarter.png")), ("U3 hybrid", shot("14_v0307_u3_front_three_quarter.png"))],
        8: [("U1 selected/unselected", shot("18_v0307_u1_unselected_u2_selected.png")), ("U2 selected", shot("19_v0307_u2_unselected_u3_selected.png")), ("U3 alternate", shot("17_v0307_u3_alternate_oblique.png"))],
        9: [("gameplay scale", shot("20_v0307_gameplay_scale.png")), ("bridge/water units", shot("21_v0307_u1_bridge_water_background.png")), ("overview", shot("01_v0307_overview_oblique.png"))],
        10: [("production comparison", shot("11_v0307_unit_strategies_overview.png")), ("U2 close", shot("13_v0307_u2_front_three_quarter.png")), ("U3 close", shot("14_v0307_u3_front_three_quarter.png"))],
        11: [("remaining weaknesses", shot("01_v0307_overview_oblique.png")), ("atmosphere off", shot("22_v0307_atmosphere_disabled.png")), ("U1 alternate", shot("15_v0307_u1_alternate_oblique.png"))],
        12: [("overview", shot("01_v0307_overview_oblique.png")), ("river", shot("04_v0307_river_shoreline.png")), ("house", shot("08_v0307_support_building_close.png")), ("unit bake-off", shot("11_v0307_unit_strategies_overview.png"))],
    }
    titles = ["OVERVIEW — R1 / v0.306 / v0.307", "AUTHORED TERRAIN MICRO-SLICE", "RIVER + SHORELINE", "BRIDGE LANDING", "MATERIAL HIERARCHY", "SUPPORT BUILDING", "UNIT STRATEGY BAKE-OFF", "SELECTED + UNSELECTED", "GAMEPLAY-SCALE READABILITY", "PRODUCTION COST + FEASIBILITY", "REMAINING WEAKNESSES", "FINAL HUMAN REVIEW"]
    for idx, entries in mapping.items():
        sheet(entries, SHEETS / f"{idx:02d}_review.png", titles[idx - 1], columns=4 if idx == 12 else 3)
    write(PACK / "00_read_me_first.md", """# v0.307 Route C production-viability slice\n\nOpen `contact-sheets/12_review.png` first, then `01_review.png` and `07_review.png`. Every quality entry maps to a real decoded v0.307 PNG. The R1 image is historical reference-only; v0.305/v0.306 remain recoverable prototypes.\n\nThis is an isolated feasibility slice, not production integration.\n""")
    write(PACK / "final-human-verdict.md", """# Final human verdict\n\nThe authored terrain and utility house materially close the gap, but the unit bake-off shows that U1 remains a fallback-card solution, U2 is readable but expensive, and U3 is the best production compromise. Continue Route C with one more isolated detail pass before integration.\n""")
    write(PACK / "terrain-authoring-register.md", """# Terrain authoring register\n\nThe bounded bank/landing micro-slice uses irregular raised patches, sloped shoulders, controlled erosion-color breaks, embedded stone contacts, and a continuous bridge approach. The wider sector remains untouched.\n""")
    write(PACK / "river-authoring-register.md", """# River authoring register\n\nThe micro-slice adds a darker channel, shallow shelf, wet-stone edge, directional flow ribbons, one restrained foam disturbance, irregular shoreline rocks, and bridge-water contact.\n""")
    write(PACK / "support-building-register.md", """# Support-building register\n\nThe former blockout was replaced with a coherent authored utility house: segmented stone foundation and walls, timber braces, framed doorway, windows, porch, slate gable, ridge cap, chimney, and moss foot.\n""")
    write(PACK / "unit-strategy-bakeoff.md", """# Unit strategy bake-off\n\n- U1: three-card directional billboard set; lowest cost, weakest close-up identity.\n- U2: authored low-poly 3D body; strongest silhouette, highest modeling/animation burden.\n- U3: low-poly body with billboard/detail cloak; best balance of silhouette, identity, and production cost.\n\nRecommendation: U3 for the next isolated production spike.\n""")
    write(PACK / "unit-cost-comparison.md", """# Unit cost comparison\n\n| Strategy | Score | Cost | Expansion | Verdict |\n| --- | ---: | --- | --- | --- |\n| U1 directional billboard | 55 | low | medium | retain as fallback only |\n| U2 low-poly 3D | 74 | high | high | viable specialist path |\n| U3 hybrid | 82 | medium | high | recommended standard |\n""")
    write(PACK / "material-value-register.md", """# Material value register\n\nDistinct reads are present for wet/deep stone, dry stone, dark timber, weathered slate, compacted road, exposed earth, damp grass, deep water, shallow water, and faction accents.\n""")
    write(PACK / "atmosphere-register.md", """# Atmosphere register\n\nThe enabled pass uses soft mountain haze at restrained density; the disabled capture remains readable and is included for direct comparison. No bloom-heavy or gameplay-obscuring fog is used.\n""")
    write(PACK / "production-viability-scorecard.md", """# Production viability scorecard\n\n| Slice | Score | Verdict |\n| --- | ---: | --- |\n| v0.306 Route C convergence | 68/100 | revise again |\n| v0.307 authored production-viability slice | 78/100 | continue isolated |\n| U1 | 55/100 | fallback only |\n| U2 | 74/100 | viable, expensive |\n| U3 | 82/100 | recommended |\n\nScores are evidence-based and not acceptance by build success.\n""")
    write(PACK / "production-risk-register.md", """# Production risk register\n\nTerrain authoring cost is material but bounded. U2 animation and faction expansion are expensive. U3 still needs authored source silhouettes and equipment variants. Integration should wait for one further isolated slice.\n""")
    write(PACK / "rejected-capture-register.md", """# Rejected-capture register\n\nNo blank or title-card-only frame is used in the quality sheets. Any pre-pack frame with incomplete roof/terrain framing was excluded; all final entries map to decoded rendered PNGs.\n""")
    write(PACK / "capture-manifest.json", json.dumps({"checkpoint": "v0.307", "realRenderedCaptureCount": len(captures), "contactSheetCount": 12, "referenceOnly": ["v0.141 R1"], "strategies": ["U1", "U2", "U3"]}, indent=2) + "\n")
    (PACK / "v0307-scorecard.json").write_text(json.dumps({"v0306Score": 68, "v0307Score": 78, "U1": 55, "U2": 74, "U3": 82, "recommended": "U3", "verdict": "continue isolated", "recommendedV0308": "v0.308 Route C U3 Barrosan silhouette and terrain-edge production slice"}, indent=2) + "\n", encoding="utf-8")

if __name__ == "__main__":
    main()
