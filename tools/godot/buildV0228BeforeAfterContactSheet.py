from pathlib import Path
from PIL import Image, ImageDraw
import sys
root=Path(sys.argv[1]); repo=root.parents[2]
before=repo/"artifacts/manual-review/v0227-battlefield-visual-rescue/01_initial_overview.png"
after=root/"01_initial_overview.png"
canvas=Image.new("RGB",(1920,590),(13,18,14)); draw=ImageDraw.Draw(canvas)
draw.text((24,16),"v0.227 battlefield rescue vs v0.228 authored battlefield foundation",fill=(235,229,190))
for i,(label,path) in enumerate((("BEFORE",before),("AFTER",after))):
    image=Image.open(path).convert("RGB"); image.thumbnail((930,520)); x=20+i*950
    canvas.paste(image,(x,54)); draw.text((x+8,560),label,fill=(220,220,205))
canvas.save(root/"11_before_after_contact_sheet.png")
