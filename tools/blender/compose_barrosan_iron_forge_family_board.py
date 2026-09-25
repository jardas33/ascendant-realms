import hashlib
import json
import os
from PIL import Image, ImageDraw, ImageFont


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
EVIDENCE = r"D:\CodexData\evidence\barrosan-iron-forge-original-b01-r1-20260925"
FRAMES = [
    ("A01", "CLANHOLD / CIVIC KEEP", "A01_clanhold_zoom40.png", (208, 171, 91)),
    ("A02", "WAR HALL", "A02_war_hall_zoom40.png", (208, 171, 91)),
    ("A03", "CLAN CROFT", "A03_clan_croft_zoom40.png", (208, 171, 91)),
    ("B01", "IRON FORGE / ORIGINAL CANDIDATE", "B01_iron_forge_zoom40.png", (236, 137, 57)),
]
HEADER_H = 54
GUTTER = 8
CELL_W, CELL_H = 1920, 1080
CELL_TOTAL_H = HEADER_H + CELL_H
CANVAS = Image.new("RGB", (CELL_W * 2 + GUTTER * 3, 54 + CELL_TOTAL_H * 2 + GUTTER * 3), (9, 15, 21))
draw = ImageDraw.Draw(CANVAS)
font_path = r"C:\Windows\Fonts\segoeuib.ttf"
small_path = r"C:\Windows\Fonts\segoeui.ttf"
title_font = ImageFont.truetype(font_path, 22)
label_font = ImageFont.truetype(font_path, 20)
meta_font = ImageFont.truetype(small_path, 15)

draw.rectangle((0, 0, CANVAS.width, 53), fill=(12, 20, 27))
draw.text((GUTTER, 15), "BARROSAN BUILDING FAMILY  /  MATCHED RTS VIEW", font=title_font, fill=(230, 224, 207))
metadata = "PHASE A  |  ZOOM 40  |  PITCH 55°  |  YAW 0°  |  1920×1080 EACH"
draw.text((CANVAS.width - GUTTER - draw.textlength(metadata, font=meta_font), 20), metadata, font=meta_font, fill=(159, 170, 177))

records = []
for index, (code, label, filename, accent) in enumerate(FRAMES):
    column, row = index % 2, index // 2
    x = GUTTER + column * (CELL_W + GUTTER)
    y = 54 + GUTTER + row * (CELL_TOTAL_H + GUTTER)
    draw.rectangle((x, y, x + CELL_W - 1, y + HEADER_H - 1), fill=(19, 29, 37))
    draw.rectangle((x, y, x + 5, y + HEADER_H - 1), fill=accent)
    draw.text((x + 18, y + 15), code, font=label_font, fill=accent)
    draw.text((x + 72, y + 15), label, font=label_font, fill=(226, 225, 215))
    frame_path = os.path.join(EVIDENCE, filename)
    with Image.open(frame_path) as frame:
        rgb = frame.convert("RGB")
        if rgb.size != (CELL_W, CELL_H):
            raise RuntimeError("Unexpected comparison-frame dimensions: " + filename + " " + str(rgb.size))
        CANVAS.paste(rgb, (x, y + HEADER_H))
    digest = hashlib.sha256(open(frame_path, "rb").read()).hexdigest().upper()
    records.append({"code": code, "label": label, "filename": filename, "sha256": digest, "dimensions": [CELL_W, CELL_H]})

board_path = os.path.join(EVIDENCE, "b01_family_comparison_board_zoom40.png")
CANVAS.save(board_path, format="PNG", optimize=True)
manifest = {
    "board": os.path.basename(board_path),
    "sha256": hashlib.sha256(open(board_path, "rb").read()).hexdigest().upper(),
    "dimensions": list(CANVAS.size),
    "camera": {"zoom": 40, "pitch_degrees": 55, "yaw_degrees": 0, "vertical_fov_degrees": 55},
    "frames": records,
}
with open(os.path.join(EVIDENCE, "b01_family_board_manifest.json"), "w", encoding="utf-8") as stream:
    json.dump(manifest, stream, indent=2)
print(json.dumps(manifest, indent=2))
