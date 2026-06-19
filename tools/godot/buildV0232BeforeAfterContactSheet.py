from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])
before = root / "01_v0231_baseline.png"
after = root / "02_new_visual_spike_overview.png"
canvas = Image.new("RGB", (1920, 620), (12, 17, 14))
draw = ImageDraw.Draw(canvas)
draw.text((24, 16), "v0.231 procedural battlefield comparator vs v0.232 isolated authored-3D production-direction spike", fill=(235, 224, 183))
for index, (label, path) in enumerate((("V0.231 COMPARATOR", before), ("V0.232 DIRECTION SPIKE", after))):
    image = Image.open(path).convert("RGB")
    image.thumbnail((930, 530))
    x = 20 + index * 950
    canvas.paste(image, (x, 54))
    draw.text((x + 8, 590), label, fill=(213, 215, 197))
canvas.save(root / "06_before_after_contact_sheet.png")
