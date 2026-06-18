from pathlib import Path
from PIL import Image, ImageDraw
import sys

manual_root = Path(sys.argv[1])
repo_root = manual_root.parents[2]
before_path = repo_root / "artifacts" / "manual-review" / "v0225-reboot-final-qa" / "01_initial.png"
after_path = manual_root / "01_initial_overview.png"
canvas = Image.new("RGB", (1920, 590), (13, 18, 14))
draw = ImageDraw.Draw(canvas)
draw.text((24, 16), "v0.226 technical checkpoint vs v0.227 battlefield visual rescue", fill=(235, 229, 190))
for index, (label, path) in enumerate((("BEFORE", before_path), ("AFTER", after_path))):
    image = Image.open(path).convert("RGB")
    image.thumbnail((930, 520))
    x = 20 + index * 950
    y = 54
    canvas.paste(image, (x, y))
    draw.text((x + 8, 560), label, fill=(220, 220, 205))
canvas.save(manual_root / "10_before_after_contact_sheet.png")
