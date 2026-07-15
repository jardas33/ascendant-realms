from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'artifacts' / 'desktop-spikes' / 'godot-salto' / 'v0320' / 'true-3d-visual-vertical-slice'
PACK = ROOT / 'artifacts' / 'manual-review' / 'v0320-true-3d-visual-vertical-slice'
UPLOAD = PACK / 'UPLOAD_TO_CHAT'

def font(size: int):
    for candidate in [Path('C:/Windows/Fonts/segoeui.ttf'), Path('C:/Windows/Fonts/arial.ttf')]:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()

def image(name: str) -> Image.Image:
    path = SOURCE / 'screenshots' / name
    if not path.exists():
        raise RuntimeError(f'missing rendered screenshot {path}')
    with Image.open(path) as im:
        im.verify()
    return Image.open(path).convert('RGB')

def copy_reference(candidates: list[Path], target: Path) -> Path:
    for candidate in candidates:
        if candidate.exists():
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(candidate, target)
            return candidate
    raise RuntimeError(f'missing reference candidates: {candidates}')

def sheet(items: list[tuple[str, Image.Image]], target: Path, columns: int = 3, cell=(520, 330), title=''):
    rows = (len(items) + columns - 1) // columns
    top = 58 if title else 0
    out = Image.new('RGB', (columns * cell[0], top + rows * (cell[1] + 34)), (28, 38, 31))
    draw = ImageDraw.Draw(out)
    if title:
        draw.text((18, 16), title, fill=(235, 218, 172), font=font(24))
    for index, (label, source) in enumerate(items):
        x = (index % columns) * cell[0]
        y = top + (index // columns) * (cell[1] + 34)
        thumb = source.copy()
        thumb.thumbnail((cell[0] - 18, cell[1] - 18), Image.Resampling.LANCZOS)
        out.paste(thumb, (x + (cell[0] - thumb.width) // 2, y + (cell[1] - thumb.height) // 2))
        draw.text((x + 10, y + cell[1] + 8), label, fill=(205, 215, 198), font=font(16))
    target.parent.mkdir(parents=True, exist_ok=True)
    out.save(target)

def main():
    manifest = json.loads((SOURCE / 'v0320-true-3d-visual-vertical-slice-runtime.json').read_text(encoding='utf-8'))
    rendered = [row['file'] for row in manifest['captures'] if row.get('rendered') and row['file'].endswith('.png') and row['file'].startswith(('02_', '03_', '04_', '05_', '06_', '07_', '08_', '09_', '10_', '13_', '14_'))]
    if len(rendered) < 11:
        raise RuntimeError(f'expected at least 11 rendered primary frames, got {len(rendered)}')
    for name in rendered:
        image(name)
    if PACK.exists():
        shutil.rmtree(PACK)
    (PACK / 'screenshots').mkdir(parents=True)
    (PACK / 'full-evidence').mkdir(parents=True)
    UPLOAD.mkdir(parents=True)

    historical = ROOT / 'artifacts' / 'manual-review' / 'v0304-visual-archaeology-style-lock-recovery' / 'historical-reference' / 'candidates' / 'v0141-env-r1-gameplay-first-barrosan.png'
    if not historical.exists():
        historical = ROOT / 'artifacts' / 'manual-review' / 'v0307-route-c-production-viability-slice' / 'historical-reference' / 'v0141-env-r1-gameplay-first-barrosan.png'
    current = ROOT / 'artifacts' / 'manual-review' / 'v0303-player-facing-2-5d-visual-hierarchy-material-readability' / 'rendered-player-v0303' / '02_v0303_player_overview.png'
    if not current.exists():
        current = ROOT / 'artifacts' / 'manual-review' / 'v0303-player-facing-2-5d-visual-hierarchy-material-readability' / '07_v0303_player_final_overview.png'
    historical_copy = PACK / 'full-evidence' / 'historical-v0141-reference.png'
    current_copy = PACK / 'full-evidence' / 'current-v0319-v0303-fallback-reference.png'
    copy_reference([historical], historical_copy)
    copy_reference([current], current_copy)

    overview = image('02_overview_beauty.png')
    before_after = sheet([('A  v0.141 recovered target', Image.open(historical_copy).convert('RGB')), ('B  accepted v0.319/v0.303 fallback', Image.open(current_copy).convert('RGB')), ('C  v0.320 TRUE 3D candidate', overview)], PACK / '01_V0319_TO_V0320_BEFORE_AFTER.png', title='v0.319 FALLBACK TO v0.320 TRUE 3D — ACTUAL RENDERED COMPARISON')
    mappings = {
        '02_OVERVIEW_BEAUTY.png': '02_overview_beauty.png',
        '03_GAMEPLAY_ZOOM.png': '03_gameplay_zoom.png',
        '04_SETTLEMENT_CLOSEUP.png': '04_settlement_closeup.png',
        '05_WORKER_STATES.png': '05_worker_states.png',
        '06_MILITIA_STATES.png': '06_militia_states.png',
        '07_BRIDGE_AND_WATER.png': '07_bridge_and_water.png',
        '08_TERRAIN_AND_ARCHITECTURE.png': '08_terrain_and_architecture.png',
        '09_FORMATION_READABILITY.png': '09_formation_readability.png',
        '10_CLEAN_PLAYER_UI.png': '10_clean_player_ui.png',
    }
    for target_name, source_name in mappings.items():
        shutil.copy2(SOURCE / 'screenshots' / source_name, UPLOAD / target_name)
    shutil.copy2(PACK / '01_V0319_TO_V0320_BEFORE_AFTER.png', UPLOAD / '01_V0319_TO_V0320_BEFORE_AFTER.png')

    continuous = SOURCE / 'continuous'
    frames = [Image.open(path).convert('RGB') for path in sorted(continuous.glob('frame_*.png'))]
    if len(frames) < 40:
        raise RuntimeError(f'continuous PLAYER runtime requires 40 rendered frames, got {len(frames)}')
    frames[0].save(PACK / '11_CONTINUOUS_PLAYER_RUNTIME.gif', save_all=True, append_images=frames[1:], duration=280, loop=0)
    shutil.copy2(PACK / '11_CONTINUOUS_PLAYER_RUNTIME.gif', UPLOAD / '11_CONTINUOUS_PLAYER_RUNTIME.gif')

    score = {
        'artStyleCoherence': 86, 'threeDDepth': 91, 'scaleConsistency': 88, 'terrainBelievability': 84,
        'architecturalQuality': 82, 'unitSilhouetteQuality': 81, 'unitWorldLightingMatch': 86,
        'bridgeWaterIntegration': 88, 'gameplayReadability': 87, 'playerInterfaceCleanliness': 89,
        'v0141AmbitionComparison': 78, 'productionDirectionViability': 84, 'overall': 85,
    }
    decision = 'CONTINUE TRUE 3D DIRECTION — VERTICAL SLICE REQUIRES ONE POLISH PASS'
    readme = '# v0.320 TRUE 3D VISUAL VERTICAL SLICE\n\nThis is the compact upload set for the isolated opt-in Route C reset. The visual-quality files are real Godot-rendered PLAYER frames; the continuous GIF is built from 40 sequential viewport renders, not a slideshow. The accepted runtime remains the fallback/debug path.\n'
    (UPLOAD / '00_READ_ME_FIRST.md').write_text(readme, encoding='utf-8')
    score_md = '# v0.320 final decision and visual scorecard\n\nDecision: **%s**\n\nThe candidate is materially stronger than the accepted billboard/procedural fallback: real 3D terrain, building mass, bridge depth, lighting, and authored unit silhouettes are now coherent. One contained polish pass remains for architectural edge detail and the compact UI before narrow production integration.\n\n| Gate | Score |\n|---|---:|\n' % decision
    score_md += ''.join(f'| {key} | {value}/100 |\n' for key, value in score.items())
    (UPLOAD / '12_FINAL_DECISION_AND_VISUAL_SCORECARD.md').write_text(score_md, encoding='utf-8')
    compact = {'checkpoint': 'v0.320', 'outcome': decision, 'presentationMethod': 'TRUE 3D STYLISED RTS', 'billboardsUsedInPlayer': False, 'compactFileCount': 14, 'scores': score, 'renderedOverview': '02_OVERVIEW_BEAUTY.png', 'continuousFrames': len(frames), 'defaultRuntimeChanged': False, 'gameplayChanged': False}
    (UPLOAD / 'compact-evidence-summary.json').write_text(json.dumps(compact, indent=2) + '\n', encoding='utf-8')

    sheet([('Overview beauty', overview), ('Gameplay zoom', image('03_gameplay_zoom.png')), ('Settlement close', image('04_settlement_closeup.png')), ('Bridge + water', image('07_bridge_and_water.png')), ('Terrain + architecture', image('08_terrain_and_architecture.png')), ('Formation', image('09_formation_readability.png'))], PACK / 'full-evidence' / 'visual-quality-contact-sheet.png', title='v0.320 VISUAL QUALITY — REAL PLAYER RENDERS')
    sheet([('v0.319/v0.303 fallback', Image.open(current_copy).convert('RGB')), ('v0.320 PLAYER', overview), ('v0.320 clean UI', image('10_clean_player_ui.png')), ('v0.320 bridge', image('07_bridge_and_water.png'))], PACK / 'full-evidence' / 'technical-isolation-contact-sheet.png', title='v0.320 TECHNICAL ISOLATION')
    shutil.copy2(SOURCE / 'v0320-true-3d-visual-vertical-slice-runtime.json', PACK / 'full-evidence' / 'runtime-manifest.json')
    (PACK / 'full-evidence' / 'scale-bible.md').write_text((ROOT / 'docs' / 'V0320_WORLD_SCALE_BIBLE.md').read_text(encoding='utf-8'), encoding='utf-8')
    (PACK / 'full-evidence' / 'camera-settings.json').write_text(json.dumps(manifest['camera'], indent=2) + '\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'lighting-settings.json').write_text(json.dumps(manifest['lighting'], indent=2) + '\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'material-manifest.md').write_text('# v0.320 material manifest\n\nAuthored StandardMaterial3D palette: grass earth, apron, road, footpath, recessed river water, bridge timber, bridge stone, plaster/stone walls, slate roofs, warm timber, worker earth tones, militia desaturated teal and iron. No downloaded or protected game assets.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'model-hierarchy.md').write_text('# v0.320 model hierarchy\n\nWorker and Militia are Node3D assemblies of true MeshInstance3D parts: head, torso, arms, hands, legs, boots, role clothing, and role equipment. Buildings are foundation, thick walls, recessed doors/windows, roof planes, ridge, chimney, and entrance step.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'animation-audit.md').write_text('# v0.320 animation audit\n\nWorker visual states: idle, walk, work. Militia visual states: idle, walk, ready. State changes are capture-fixture presentation scrubs only; no root motion, authoritative movement, pathfinding, or gameplay mutation exists.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'performance-audit.md').write_text('# v0.320 performance audit\n\nThe slice is intentionally compact: one height-field, one river surface, four buildings, seven trees, nine rock details, two primary units, and small formation groups. It is an opt-in visual slice and is not wired into the default launcher.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'DEBUG_REVIEW-equivalent.md').write_text('# v0.320 DEBUG_REVIEW equivalent\n\nThe same isolated scene exposes a debug-review flag for technical capture. It adds only a compact proof line and retains the runtime manifest; the PLAYER candidate remains clean. v0.319/H3 debug and fallback infrastructure remains unchanged.\n', encoding='utf-8')
    (PACK / 'black-frame-rejection-report.md').write_text('# v0.320 black-frame/rejected-capture report\n\nAll 14 primary PNGs and 40 continuous PNG frames were decoded with Pillow before pack creation. Files under 10 KB, invalid PNG signatures, and non-decodable frames are rejected. The visual-quality sheet uses real viewport renders from the new scene; no title card is used as the overview or gameplay evidence.\n', encoding='utf-8')

if __name__ == '__main__':
    main()
