from pathlib import Path
from PIL import Image, ImageDraw
import sys

root = Path(sys.argv[1])
paths = sorted(root.glob("[0-9][0-9]_*.png"))
thumb_w, thumb_h = 480, 270
cols = 3
rows = (len(paths) + cols - 1) // cols
canvas = Image.new("RGB", (cols * thumb_w, 42 + rows * (thumb_h + 24)), (13, 18, 14))
draw = ImageDraw.Draw(canvas)
draw.text((14, 12), "v0.224 integrated reference-gap review", fill=(235, 229, 190))
for index, path in enumerate(paths):
    image = Image.open(path).convert("RGB")
    image.thumbnail((thumb_w - 12, thumb_h - 12))
    x = (index % cols) * thumb_w + 6
    y = 42 + (index // cols) * (thumb_h + 24) + 6
    canvas.paste(image, (x, y))
    draw.text((x, y + thumb_h - 2), path.stem, fill=(210, 216, 198))
canvas.save(root / "final_contact_sheet.png")
