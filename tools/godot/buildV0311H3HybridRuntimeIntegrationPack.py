from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
PACK = ROOT / 'artifacts' / 'manual-review' / 'v0311-h3-hybrid-runtime-integration'

def make_sheet(prefix: str, output: str, columns: int = 4):
    files = sorted(PACK.glob(f'{prefix}_*.png'))
    if not files:
        return
    thumb_w, thumb_h = 320, 180
    rows = (len(files) + columns - 1) // columns
    sheet = Image.new('RGB', (columns * thumb_w, rows * (thumb_h + 22)), '#18221f')
    draw = ImageDraw.Draw(sheet)
    for index, path in enumerate(files):
        image = Image.open(path).convert('RGB')
        image.thumbnail((thumb_w - 8, thumb_h - 8))
        x = (index % columns) * thumb_w + (thumb_w - image.width) // 2
        y = (index // columns) * (thumb_h + 22) + (thumb_h - image.height) // 2
        sheet.paste(image, (x, y))
        draw.text(((index % columns) * thumb_w + 6, (index // columns) * (thumb_h + 22) + thumb_h + 2), path.name[:48], fill='#d8d0ac')
    sheet.save(PACK / output)

make_sheet('player', 'player-contact-sheet.png')
make_sheet('debug', 'debug-contact-sheet.png')

comparison = []
for name in ['player_01_01_v0311_preflight_runtime.png', 'player_41_41_v0311_real_gameplay_overview.png', 'debug_41_41_v0311_real_gameplay_overview.png']:
    path = PACK / name
    if path.exists():
        comparison.append(path)
if comparison:
    thumb_w, thumb_h = 640, 360
    sheet = Image.new('RGB', (thumb_w * len(comparison), thumb_h + 28), '#18221f')
    draw = ImageDraw.Draw(sheet)
    for index, path in enumerate(comparison):
        image = Image.open(path).convert('RGB')
        image.thumbnail((thumb_w - 8, thumb_h - 8))
        sheet.paste(image, (index * thumb_w + (thumb_w - image.width) // 2, (thumb_h - image.height) // 2))
        draw.text((index * thumb_w + 8, thumb_h + 6), path.name, fill='#d8d0ac')
    sheet.save(PACK / 'mode-comparison-contact-sheet.png')
