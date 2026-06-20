from pathlib import Path
import sys
from PIL import Image, ImageDraw

root = Path(sys.argv[1])
paths = [root / name for name in [
    "01_v0240_review_lane_baseline.png",
    "02_v0241_runtime_skin_overview.png",
    "03_v0241_default_runtime_unchanged_proof.png",
    "04_v0241_selected_building_runtime_indicator.png",
    "05_v0241_unselected_buildings_clean_view.png",
    "06_v0241_runtime_role_mapping_proof.png",
    "07_v0241_valid_build_preview.png",
    "08_v0241_blocked_build_preview.png",
    "09_v0241_units_near_buildings_scale.png",
]]
thumbs = []
for path in paths:
    image = Image.open(path).convert("RGB")
    image.thumbnail((600, 338), Image.Resampling.LANCZOS)
    tile = Image.new("RGB", (620, 380), "#182018")
    tile.paste(image, ((620 - image.width) // 2, 28))
    ImageDraw.Draw(tile).text((12, 8), path.stem, fill="#ead99b")
    thumbs.append(tile)
sheet = Image.new("RGB", (1860, 1140), "#101510")
for index, tile in enumerate(thumbs):
    sheet.paste(tile, ((index % 3) * 620, (index // 3) * 380))
sheet.save(root / "10_v0241_before_after_contact_sheet.png")
