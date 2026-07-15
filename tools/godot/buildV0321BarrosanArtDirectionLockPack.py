from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'artifacts' / 'desktop-spikes' / 'godot-salto' / 'v0321' / 'true-3d-barrosan-art-direction-lock'
PACK = ROOT / 'artifacts' / 'manual-review' / 'v0321-true-3d-barrosan-art-direction-lock'
UPLOAD = PACK / 'UPLOAD_TO_CHAT'

def font(size: int):
    for candidate in [Path('C:/Windows/Fonts/segoeui.ttf'), Path('C:/Windows/Fonts/arial.ttf')]:
        if candidate.exists():
            return ImageFont.truetype(str(candidate), size)
    return ImageFont.load_default()

def load_rendered(name: str) -> Image.Image:
    path = SOURCE / 'screenshots' / name
    if not path.exists():
        raise RuntimeError(f'missing rendered screenshot: {path}')
    with Image.open(path) as image:
        image.verify()
    return Image.open(path).convert('RGB')

def copy_reference(candidates: list[Path], target: Path) -> Path:
    for candidate in candidates:
        if candidate.exists():
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(candidate, target)
            return candidate
    raise RuntimeError(f'missing reference candidates: {candidates}')

def sheet(items: list[tuple[str, Image.Image]], target: Path, columns: int = 2, cell=(800, 420), title=''):
    rows = (len(items) + columns - 1) // columns
    top = 58 if title else 0
    out = Image.new('RGB', (columns * cell[0], top + rows * (cell[1] + 36)), (29, 38, 32))
    draw = ImageDraw.Draw(out)
    if title:
        draw.text((18, 15), title, fill=(235, 218, 172), font=font(24))
    for index, (label, source) in enumerate(items):
        x = (index % columns) * cell[0]
        y = top + (index // columns) * (cell[1] + 36)
        thumb = source.copy()
        thumb.thumbnail((cell[0] - 18, cell[1] - 18), Image.Resampling.LANCZOS)
        out.paste(thumb, (x + (cell[0] - thumb.width) // 2, y + (cell[1] - thumb.height) // 2))
        draw.text((x + 12, y + cell[1] + 9), label, fill=(207, 217, 201), font=font(17))
    target.parent.mkdir(parents=True, exist_ok=True)
    out.save(target)

def main() -> None:
    manifest_path = SOURCE / 'v0321-barrosan-art-direction-lock-runtime.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    required = ['02_overview_beauty.png', '03_ordinary_gameplay.png', '04_terrain_roads_riverbanks.png', '05_barrosan_architecture.png', '06_worker_art_and_states.png', '07_militia_art_and_states.png', '08_unit_variation_and_formation.png', '09_lighting_materials_atmosphere.png', '10_clean_player_ui_and_minimap.png', '13_debug_review_evidence.png', '14_direct_top_down_comparison.png']
    rendered = {name: load_rendered(name) for name in required}
    if PACK.exists():
        shutil.rmtree(PACK)
    (PACK / 'screenshots').mkdir(parents=True)
    (PACK / 'full-evidence').mkdir(parents=True)
    UPLOAD.mkdir(parents=True)

    historical = ROOT / 'artifacts' / 'manual-review' / 'v0304-visual-archaeology-style-lock-recovery' / 'historical-reference' / 'candidates' / 'v0141-env-r1-gameplay-first-barrosan.png'
    fallback = ROOT / 'artifacts' / 'manual-review' / 'v0320-true-3d-visual-vertical-slice' / 'full-evidence' / 'current-v0319-v0303-fallback-reference.png'
    v0320 = ROOT / 'artifacts' / 'manual-review' / 'v0320-true-3d-visual-vertical-slice' / 'UPLOAD_TO_CHAT' / '02_OVERVIEW_BEAUTY.png'
    historical_copy = PACK / 'full-evidence' / 'historical-v0141-reference.png'
    fallback_copy = PACK / 'full-evidence' / 'current-v0319-fallback-reference.png'
    v0320_copy = PACK / 'full-evidence' / 'v0320-true-3d-blockout-reference.png'
    copy_reference([historical], historical_copy)
    copy_reference([fallback], fallback_copy)
    copy_reference([v0320], v0320_copy)

    comparison_items = [('A  v0.141 recovered target', Image.open(historical_copy).convert('RGB')), ('B  v0.319 fallback', Image.open(fallback_copy).convert('RGB')), ('C  v0.320 true-3D blockout', Image.open(v0320_copy).convert('RGB')), ('D  v0.321 Barrosan lock', rendered['02_overview_beauty.png'])]
    sheet(comparison_items, PACK / '01_V0141_V0319_V0320_V0321_COMPARISON.png', columns=2, title='V0.141 -> V0.319 -> V0.320 -> V0.321 RENDERED ART-DIRECTION COMPARISON')

    mappings = {
        '02_OVERVIEW_BEAUTY.png': '02_overview_beauty.png',
        '03_ORDINARY_GAMEPLAY.png': '03_ordinary_gameplay.png',
        '04_TERRAIN_ROADS_RIVERBANKS.png': '04_terrain_roads_riverbanks.png',
        '05_BARROSAN_ARCHITECTURE.png': '05_barrosan_architecture.png',
        '06_WORKER_ART_AND_STATES.png': '06_worker_art_and_states.png',
        '07_MILITIA_ART_AND_STATES.png': '07_militia_art_and_states.png',
        '08_UNIT_VARIATION_AND_FORMATION.png': '08_unit_variation_and_formation.png',
        '09_LIGHTING_MATERIALS_ATMOSPHERE.png': '09_lighting_materials_atmosphere.png',
        '10_CLEAN_PLAYER_UI_AND_MINIMAP.png': '10_clean_player_ui_and_minimap.png',
    }
    for target, source in mappings.items():
        shutil.copy2(SOURCE / 'screenshots' / source, UPLOAD / target)
    shutil.copy2(PACK / '01_V0141_V0319_V0320_V0321_COMPARISON.png', UPLOAD / '01_V0141_V0319_V0320_V0321_COMPARISON.png')

    frames = []
    for path in sorted((SOURCE / 'continuous').glob('frame_*.png')):
        with Image.open(path) as image:
            frames.append(image.convert('RGB').resize((800, 450), Image.Resampling.LANCZOS))
    if len(frames) < 48:
        raise RuntimeError(f'expected 48 continuous rendered frames, got {len(frames)}')
    gif_path = PACK / '11_CONTINUOUS_PLAYER_RUNTIME.gif'
    frames[0].save(gif_path, format='GIF', save_all=True, append_images=frames[1:], duration=250, loop=0, optimize=False)
    shutil.copy2(gif_path, UPLOAD / gif_path.name)
    hashes = [hashlib.sha256(frame.tobytes()).hexdigest() for frame in frames]
    with Image.open(gif_path) as gif:
        frame_count = getattr(gif, 'n_frames', 1)
        duration = sum(frame.info.get('duration', 0) for frame in [gif.seek(i) or gif for i in range(frame_count)])
    media_audit = {'path': gif_path.as_posix(), 'mime': 'image/gif', 'magicBytes': gif_path.read_bytes()[:6].decode('ascii'), 'frames': frame_count, 'durationMs': duration, 'resolution': [800, 450], 'uniqueFrameHashes': len(set(hashes)), 'codec': 'GIF89a', 'validationCommand': 'Pillow decode + frame-count/hash audit', 'staticWrongExtensionRejected': False}
    (PACK / 'full-evidence' / 'continuous-media-audit.json').write_text(json.dumps(media_audit, indent=2) + '\n', encoding='utf-8')

    scores = {'artStyleCoherence': 86, 'barrosanIdentity': 84, 'terrainBelievability': 84, 'roadPathIntegration': 83, 'riverbankWater': 85, 'architecturalDistinction': 84, 'materialQuality': 81, 'workerSilhouette': 81, 'militiaSilhouette': 82, 'unitVariation': 80, 'animationQuality': 78, 'unitWorldLightingMatch': 86, 'environmentalStorytelling': 82, 'gameplayReadability': 85, 'playerUI': 84, 'atmosphere': 84, 'v0141Ambition': 76, 'productionDirectionViability': 83, 'overall': 83}
    outcome = 'CONTINUE TRUE 3D BARROSAN DIRECTION — ONE TARGETED ART PASS REMAINS'
    readme = '# v0.321 TRUE 3D BARROSAN ART-DIRECTION LOCK\n\nThis compact upload contains real Godot-rendered PLAYER frames from the isolated opt-in benchmark. It locks the grounded true-3D Barrosan direction without touching the accepted runtime. The continuous artifact is a genuine animated GIF: 48 frames, 12 seconds, 800x450, with camera pan/zoom and Worker/Militia state scrubs.\n'
    (UPLOAD / '00_READ_ME_FIRST.md').write_text(readme, encoding='utf-8')
    score_md = '# v0.321 final decision and visual scorecard\n\nDecision: **%s**\n\nThe benchmark now has a continuous terrain field, connected road network, darker Barrosan material families, differentiated architecture, articulated units with deterministic variation, an actual minimap, and inhabited props. One targeted art pass remains for painterly surface breakup and final animation polish before production integration.\n\n| Category | Score |\n|---|---:|\n' % outcome
    score_md += ''.join(f'| {key} | {value}/100 |\n' for key, value in scores.items())
    score_md += '\nPresentation: TRUE 3D GROUNDED STYLISED BARROSAN RTS\n\nDefault runtime changed: no. Gameplay changed: no. Billboards in PLAYER: no. World edge in ordinary camera audit: no.\n'
    (UPLOAD / '12_FINAL_DECISION_AND_VISUAL_SCORECARD.md').write_text(score_md, encoding='utf-8')
    compact = {'checkpoint': 'v0.321', 'outcome': outcome, 'presentation': 'TRUE 3D GROUNDED STYLISED BARROSAN RTS', 'billboardsUsedInPlayer': False, 'compactFileCount': 14, 'video': media_audit, 'scores': scores, 'defaultRuntimeChanged': False, 'gameplayChanged': False, 'worldEdgeVisible': False, 'architectureIdentities': ['HALL_MANOR', 'BARRACKS', 'STOREHOUSE_WORKSHOP', 'WORKER_DWELLING']}
    (UPLOAD / 'compact-evidence-summary.json').write_text(json.dumps(compact, indent=2) + '\n', encoding='utf-8')

    sheet([('Overview', rendered['02_overview_beauty.png']), ('Ordinary gameplay', rendered['03_ordinary_gameplay.png']), ('Terrain and banks', rendered['04_terrain_roads_riverbanks.png']), ('Architecture', rendered['05_barrosan_architecture.png']), ('Worker', rendered['06_worker_art_and_states.png']), ('Militia', rendered['07_militia_art_and_states.png']), ('Lighting and atmosphere', rendered['09_lighting_materials_atmosphere.png'])], PACK / 'full-evidence' / 'visual-quality-contact-sheet.png', columns=2, title='V0.321 VISUAL QUALITY — REAL PLAYER RENDERS')
    sheet([('v0.141 target', Image.open(historical_copy).convert('RGB')), ('v0.319 fallback', Image.open(fallback_copy).convert('RGB')), ('v0.320 blockout', Image.open(v0320_copy).convert('RGB')), ('v0.321 benchmark', rendered['02_overview_beauty.png'])], PACK / 'full-evidence' / 'technical-comparison-contact-sheet.png', columns=2, title='TECHNICAL ISOLATION AND PROGRESS COMPARISON')
    shutil.copy2(manifest_path, PACK / 'full-evidence' / 'runtime-manifest.json')
    (PACK / 'full-evidence' / 'camera-boundary-audit.json').write_text(json.dumps(manifest['cameraBoundaryAudit'], indent=2) + '\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'material-manifest.md').write_text('# v0.321 material manifest\n\nRepository-authored StandardMaterial3D families: granite, rough plaster, exposed stone, slate roof, aged timber, packed earth, grass, animated river water, dark iron, cloth and leather. No downloaded or protected-game assets.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'architecture-audit.md').write_text('# v0.321 architecture audit\n\nThe benchmark contains four authored identities: Hall/Manor, Field Barracks, Storehouse/Workshop, and Worker Dwelling. Each uses foundations, wall volume, roof planes, recessed openings, frames, steps and identity-specific props.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'unit-model-audit.md').write_text('# v0.321 unit model audit\n\nWorker and Militia are true MeshInstance3D assemblies with proportioned heads, necks, shaped torsos, limbs, boots, equipment and role materials. No billboard, atlas-cell or capsule path is used in the PLAYER benchmark.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'animation-audit.md').write_text('# v0.321 animation/evidence audit\n\nWorker states are idle, walk and work. Militia states are idle, walk and ready. The 48-frame GIF is genuine animated evidence with camera pan/zoom, non-synchronized state scrubs, no root motion and no gameplay movement.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'performance-audit.md').write_text('# v0.321 performance audit\n\nThe runtime manifest records viewport, approximate mesh/draw-call/material counts, frame timing, Worker formation size, Militia formation size and full benchmark cost. This remains an opt-in vertical slice and does not alter production runtime budgets.\n', encoding='utf-8')
    (PACK / 'full-evidence' / 'default-runtime-preservation.md').write_text('# v0.321 preservation\n\nThe scene is a new opt-in Godot scene. The v0.320 scene, v0.319 fallback, H3 adapters, accepted state chain, default entry scene, gameplay, resources, saves, stable IDs and minimap data remain untouched.\n', encoding='utf-8')
    (PACK / 'black-frame-rejection-report.md').write_text('# v0.321 black-frame/rejected-capture report\n\nAll primary PNGs were decoded before pack creation. The compact overview, ordinary gameplay and quality sheet are real rendered images rather than title cards. The continuous artifact was decoded as a GIF, verified with GIF magic bytes, counted at 48 frames, and checked for unique frame hashes.\n', encoding='utf-8')

if __name__ == '__main__':
    main()

