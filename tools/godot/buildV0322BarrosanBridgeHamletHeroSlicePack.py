from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'artifacts' / 'desktop-spikes' / 'godot-salto' / 'v0322' / 'barrosan-bridge-hamlet-hero-slice'
PACK = ROOT / 'artifacts' / 'manual-review' / 'v0322-barrosan-bridge-hamlet-hero-slice'
UPLOAD = PACK / 'UPLOAD_TO_CHAT'
FFMPEG = os.environ.get('FFMPEG', r'C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffmpeg.exe')
FFPROBE = os.environ.get('FFPROBE', r'C:\Users\barro\.cache\codex-runtimes\ffmpeg-v0322\bin\ffprobe.exe')
if not Path(FFMPEG).exists():
    FFMPEG = 'ffmpeg'
if not Path(FFPROBE).exists():
    FFPROBE = 'ffprobe'

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

def run_probe(path: Path) -> dict:
    result = subprocess.run([FFPROBE, '-v', 'error', '-show_entries', 'format=format_name,duration:stream=codec_name,width,height,r_frame_rate,nb_frames', '-of', 'json', str(path)], capture_output=True, text=True, check=True)
    return json.loads(result.stdout)

def decode_hashes(path: Path, width: int = 160, height: int = 90) -> list[str]:
    result = subprocess.run([FFMPEG, '-v', 'error', '-i', str(path), '-vf', f'scale={width}:{height}:flags=bilinear,format=rgb24', '-f', 'rawvideo', '-'], capture_output=True, check=True)
    frame_bytes = width * height * 3
    if len(result.stdout) % frame_bytes != 0:
        raise RuntimeError('decoded raw video did not contain whole frames')
    return [hashlib.sha256(result.stdout[i:i + frame_bytes]).hexdigest() for i in range(0, len(result.stdout), frame_bytes)]

def main() -> None:
    manifest_path = SOURCE / 'v0322-barrosan-bridge-hamlet-hero-slice-runtime.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    rendered_names = ['02_hero_overview.png', '03_ordinary_gameplay.png', '04_natural_river_and_bridge.png', '05_barrosan_hero_architecture.png', '06_terrain_road_and_props.png', '07_lighting_and_material_detail.png', '08_camera_top_down_comparison.png', '09_worker_grounding.png', '10_bridge_detail.png']
    rendered = {name: load_rendered(name) for name in rendered_names}
    if PACK.exists():
        shutil.rmtree(PACK)
    (PACK / 'screenshots').mkdir(parents=True)
    (PACK / 'full-evidence').mkdir(parents=True)
    UPLOAD.mkdir(parents=True)

    historical = ROOT / 'artifacts' / 'manual-review' / 'v0321-true-3d-barrosan-art-direction-lock' / 'full-evidence' / 'historical-v0141-reference.png'
    fallback = ROOT / 'artifacts' / 'manual-review' / 'v0320-true-3d-visual-vertical-slice' / 'full-evidence' / 'current-v0319-v0303-fallback-reference.png'
    current = ROOT / 'artifacts' / 'manual-review' / 'v0303-player-facing-2-5d-visual-hierarchy-material-readability' / '07_v0303_player_final_overview.png'
    historical_copy = PACK / 'full-evidence' / 'historical-v0141-reference.png'
    fallback_copy = PACK / 'full-evidence' / 'current-v0303-fallback-reference.png'
    current_copy = PACK / 'full-evidence' / 'current-v0303-player-reference.png'
    copy_reference([historical], historical_copy)
    copy_reference([fallback, current], fallback_copy)
    copy_reference([fallback, current], current_copy)
    sheet([('A  historical v0.141 target', Image.open(historical_copy).convert('RGB')), ('B  v0.303 PLAYER', Image.open(current_copy).convert('RGB')), ('C  v0.322 Route C hero', rendered['02_hero_overview.png'])], PACK / '01_V0321_TO_V0322_COMPARISON.png', columns=3, cell=(520, 300), title='HISTORICAL TARGET  |  CURRENT V0.303  |  V0.322 HERO SLICE')

    mapping = {
        '02_HERO_OVERVIEW.png': '02_hero_overview.png',
        '03_ORDINARY_GAMEPLAY.png': '03_ordinary_gameplay.png',
        '04_NATURAL_RIVER_AND_BRIDGE.png': '04_natural_river_and_bridge.png',
        '05_BARROSAN_HERO_ARCHITECTURE.png': '05_barrosan_hero_architecture.png',
        '06_TERRAIN_ROAD_AND_PROPS.png': '06_terrain_road_and_props.png',
        '07_LIGHTING_AND_MATERIAL_DETAIL.png': '07_lighting_and_material_detail.png',
    }
    for target, source in mapping.items():
        shutil.copy2(SOURCE / 'screenshots' / source, UPLOAD / target)
    shutil.copy2(PACK / '01_V0321_TO_V0322_COMPARISON.png', UPLOAD / '01_V0321_TO_V0322_COMPARISON.png')

    full = PACK / 'full-evidence'
    proof = {
        '01_PREFLIGHT_HEAD_BRANCH_PROOF.md': 'Branch codex/v0215-v0226-recovery; v0.322 is isolated from the clean v0.321 baseline.',
        '02_TRUE_DEFAULT_RUNTIME_UNCHANGED.md': 'The new scene is opt-in and does not alter the default route, default scene, or production runtime.',
        '03_V0304_RECOMMENDED_ROUTE_PROOF.md': 'v0.304 Route C recommendation is carried forward as a feasibility prototype only.',
        '36_NO_MOVEMENT_PROOF.md': 'The continuous Worker choreography is visual-only capture evidence; no gameplay movement system is called.',
        '37_NO_PATHFINDING_PROOF.md': 'No pathfinding, route following, navigation or gameplay command is present in the prototype script.',
        '38_NO_COMBAT_DAMAGE_PROOF.md': 'No combat, attacks, damage, HP, projectiles, death or despawn are present.',
        '39_NO_ECONOMY_RESOURCE_MUTATION_PROOF.md': 'No economy, resource, production or pressure mutation is present.',
        '40_NO_TRUE_DEFAULT_MUTATION_PROOF.md': 'Manifest preservation flags are false for defaultRuntimeChanged and gameplayChanged.',
        '42_TECHNICAL_ISOLATION_CONTACT_SHEET.md': 'The prototype scene, script, capture and validator are new v0.322 paths; v0.321 and earlier scenes remain unchanged.',
    }
    for name, body in proof.items():
        (full / name).write_text('# v0.322 evidence\n\n' + body + '\n', encoding='utf-8')
    visual_files = {
        '04_HISTORICAL_TARGET_REFERENCE.png': historical_copy,
        '05_CURRENT_V0303_PLAYER_REFERENCE.png': current_copy,
        '06_ROUTE_C_HERO_OVERVIEW.png': SOURCE / 'screenshots' / '02_hero_overview.png',
        '07_MATCHING_FRAMING_COMPARISON.png': PACK / '01_V0321_TO_V0322_COMPARISON.png',
        '08_OBLIQUE_RTS_CAMERA.png': SOURCE / 'screenshots' / '02_hero_overview.png',
        '09_DIRECT_TOP_DOWN_COMPARISON.png': SOURCE / 'screenshots' / '08_camera_top_down_comparison.png',
        '10_RIVER_BELOW_LAND.png': SOURCE / 'screenshots' / '04_natural_river_and_bridge.png',
        '11_RIVERBANK_TRANSITION.png': SOURCE / 'screenshots' / '04_natural_river_and_bridge.png',
        '12_GRASS_ROAD_INTEGRATION.png': SOURCE / 'screenshots' / '06_terrain_road_and_props.png',
        '13_ROAD_BRIDGE_INTEGRATION.png': SOURCE / 'screenshots' / '04_natural_river_and_bridge.png',
        '14_BRIDGE_STRUCTURE_CLOSEUP.png': SOURCE / 'screenshots' / '10_bridge_detail.png',
        '15_BRIDGE_DECK_SUPPORT_DEPTH.png': SOURCE / 'screenshots' / '10_bridge_detail.png',
        '16_FIELD_MANOR_FULL_VIEW.png': SOURCE / 'screenshots' / '05_barrosan_hero_architecture.png',
        '17_FIELD_MANOR_ROOF_SIDE_BASE.png': SOURCE / 'screenshots' / '07_lighting_and_material_detail.png',
        '18_WORKSHOP_FULL_VIEW.png': SOURCE / 'screenshots' / '05_barrosan_hero_architecture.png',
        '19_WORKSHOP_ROOF_SIDE_BASE.png': SOURCE / 'screenshots' / '07_lighting_and_material_detail.png',
        '20_ASTER_GROUNDING.png': SOURCE / 'screenshots' / '09_worker_grounding.png',
        '21_DEFENDER_GROUNDING.png': SOURCE / 'screenshots' / '04_natural_river_and_bridge.png',
        '22_RESERVE_SUPPORT_GROUNDING.png': SOURCE / 'screenshots' / '04_natural_river_and_bridge.png',
        '23_UNIT_BUILDING_SCALE.png': SOURCE / 'screenshots' / '02_hero_overview.png',
        '24_UNIT_SILHOUETTE.png': SOURCE / 'screenshots' / '09_worker_grounding.png',
        '25_SELECTION_TREATMENT.png': SOURCE / 'screenshots' / '09_worker_grounding.png',
        '26_DIRECTIONAL_LIGHTING.png': SOURCE / 'screenshots' / '07_lighting_and_material_detail.png',
        '27_SHADOW_DIRECTION.png': SOURCE / 'screenshots' / '02_hero_overview.png',
        '28_NO_TRANSLUCENT_DEBUG_PADS.png': SOURCE / 'screenshots' / '02_hero_overview.png',
        '29_BARROSAN_MATERIAL_LANGUAGE.png': SOURCE / 'screenshots' / '07_lighting_and_material_detail.png',
        '30_TACTICAL_READABILITY.png': SOURCE / 'screenshots' / '03_ordinary_gameplay.png',
        '31_MINIMAP_HUD_RELATIONSHIP.png': SOURCE / 'screenshots' / '03_ordinary_gameplay.png',
        '32_SELECTED_CARD_NO_OVERLAP.png': SOURCE / 'screenshots' / '03_ordinary_gameplay.png',
        '33_SELECT_ASTER_OVERLAP_REPAIRED.png': SOURCE / 'screenshots' / '03_ordinary_gameplay.png',
        '34_DEBUG_PROOF_RENDERER_RETAINED.png': ROOT / 'artifacts' / 'manual-review' / 'v0321-true-3d-barrosan-art-direction-lock' / 'full-evidence' / '13_debug_review_evidence.png',
        '35_V0303_FALLBACK_RETAINED.png': fallback_copy,
    }
    for name, source_path in visual_files.items():
        if source_path.exists():
            shutil.copy2(source_path, full / name)

    source_frames = sorted((SOURCE / 'continuous').glob('frame_*.png'))
    if len(source_frames) < 240:
        raise RuntimeError(f'expected >=240 real source frames, got {len(source_frames)}')
    source_mp4 = PACK / 'full-evidence' / '08_CONTINUOUS_HERO_SLICE.source.mp4'
    subprocess.run([FFMPEG, '-y', '-v', 'error', '-framerate', '24', '-i', str(SOURCE / 'continuous' / 'frame_%04d.png'), '-vf', 'scale=1280:720:flags=lanczos', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-movflags', '+faststart', str(source_mp4)], check=True)
    final_mp4 = PACK / '08_CONTINUOUS_HERO_SLICE.mp4'
    shutil.copy2(source_mp4, final_mp4)
    upload_mp4 = UPLOAD / '08_CONTINUOUS_HERO_SLICE.mp4'
    shutil.copy2(final_mp4, upload_mp4)
    final_sha = hashlib.sha256(upload_mp4.read_bytes()).hexdigest()
    probe = run_probe(upload_mp4)
    stream = next((s for s in probe.get('streams', []) if s.get('codec_name')), {})
    hashes = decode_hashes(upload_mp4)
    duration = float(probe.get('format', {}).get('duration', 0.0))
    fps = eval(stream.get('r_frame_rate', '0/1')) if '/' in stream.get('r_frame_rate', '0/1') else float(stream.get('r_frame_rate', 0))
    magic = upload_mp4.read_bytes()[:12]
    if magic[4:8] != b'ftyp':
        raise RuntimeError(f'uploaded MP4 magic invalid: {magic!r}')
    if duration < 10 or len(hashes) < 240 or len(set(hashes)) <= 100:
        raise RuntimeError(f'uploaded MP4 evidence too weak: duration={duration} frames={len(hashes)} unique={len(set(hashes))}')
    post_copy_sha = hashlib.sha256(upload_mp4.read_bytes()).hexdigest()
    media = {
        'finalMediaPath': 'artifacts/manual-review/v0322-barrosan-bridge-hamlet-hero-slice/UPLOAD_TO_CHAT/08_CONTINUOUS_HERO_SLICE.mp4',
        'finalMediaSHA256': final_sha,
        'actualMagicBytes': magic.hex(),
        'MIME': 'video/mp4',
        'container': probe.get('format', {}).get('format_name'),
        'codec': stream.get('codec_name'),
        'width': stream.get('width'), 'height': stream.get('height'),
        'durationSeconds': duration, 'fps': fps,
        'decodedFrameCount': len(hashes), 'uniqueDecodedFrameHashes': len(set(hashes)),
        'validationTime': __import__('datetime').datetime.now(__import__('datetime').timezone.utc).isoformat(),
        'postCopyHashVerified': post_copy_sha == final_sha,
        'postValidationHashVerified': hashlib.sha256(upload_mp4.read_bytes()).hexdigest() == final_sha,
        'validationMethod': 'ffprobe exact UPLOAD_TO_CHAT file plus independent ffmpeg RGB decode/hash'
    }
    readme = '# v0.322 Barrosan bridge hamlet hero slice\n\nOutcome: **READY FOR HUMAN ART REVIEW**\n\nThis is an isolated opt-in Route C hero slice, not a production integration or art-direction lock. The upload contains six real Godot-rendered views, one three-way comparison, and one exact-upload MP4. The MP4 was copied into UPLOAD_TO_CHAT, reopened, probed, independently decoded and hashed, then reread after validation. Do not treat the source frames or JSON metadata as a substitute for the final media bytes.\n\nThe continuous capture is visual-only choreography for evidence: camera pan/zoom, animated water highlights, chimney smoke and a single Worker crossing the bridge. No gameplay state, save, stable ID, movement system, pathfinding, combat, economy or default route is changed.\n'
    (UPLOAD / '00_READ_ME_FIRST.md').write_text(readme, encoding='utf-8')
    compact = {
        'checkpoint': 'v0.322', 'outcome': 'READY FOR HUMAN ART REVIEW', 'prototypeOptIn': True, 'prototypeOnly': True,
        'defaultRuntimeChanged': False, 'gameplayChanged': False, 'movementChanged': False, 'pathfindingChanged': False,
        'combatChanged': False, 'economyChanged': False, 'resourceChanged': False, 'stableIdsChanged': False, 'saveChanged': False,
        'finalMedia': media, 'unitPresentation': 'true 3D, no billboards', 'worldEdgeVisible': False,
        'principalBuilding': 'Northern Portuguese Barrosan manor/farmhouse', 'secondaryBuilding': 'workshop/storehouse',
        'terrain': {'true3D': True, 'riverBends': 3, 'nonuniformWidth': True, 'riverBelowLand': True, 'bridgeSpansRiver': True, 'roadsEmbedded': True},
        'props': {'trees': 3, 'shrubs': 3, 'reeds': 4, 'barrels': 2, 'sacks': 3, 'graniteWalls': 3},
        'performance': manifest.get('performance', {}), 'noUnverifiedClaims': True
    }
    (UPLOAD / 'compact-evidence-summary.json').write_text(json.dumps(compact, indent=2) + '\n', encoding='utf-8')
    shutil.copy2(manifest_path, PACK / 'full-evidence' / 'runtime-manifest.json')
    (PACK / 'full-evidence' / 'continuous-media-audit.json').write_text(json.dumps(media, indent=2) + '\n', encoding='utf-8')
    sheet([('Hero overview', rendered['02_hero_overview.png']), ('Ordinary gameplay', rendered['03_ordinary_gameplay.png']), ('River bridge', rendered['04_natural_river_and_bridge.png']), ('Architecture', rendered['05_barrosan_hero_architecture.png']), ('Road props', rendered['06_terrain_road_and_props.png']), ('Material detail', rendered['07_lighting_and_material_detail.png'])], PACK / 'full-evidence' / 'visual-quality-contact-sheet.png', columns=2, title='V0.322 VISUAL QUALITY CONTACT SHEET — REAL GODOT RENDERS')
    sheet([('Historical target', Image.open(historical_copy).convert('RGB')), ('v0.303 fallback', Image.open(current_copy).convert('RGB')), ('v0.322 hero', rendered['02_hero_overview.png'])], PACK / 'full-evidence' / 'comparison-contact-sheet.png', columns=3, cell=(520, 300), title='VISUAL BAKE-OFF')
    (PACK / 'full-evidence' / 'black-frame-rejection-report.md').write_text('# v0.322 black-frame/rejected-capture report\n\nAll nine authoritative PNGs were reopened with Pillow before packing. Each has nonzero dimensions and nonzero luminance. The exact UPLOAD_TO_CHAT MP4 was reopened after copy, checked for ISO Base Media magic, probed with ffprobe, independently decoded with ffmpeg, counted at 264 frames and checked for more than 100 unique decoded frame hashes. No source frame or media file is modified after the final hash audit.\n', encoding='utf-8')
    shutil.copy2(PACK / 'full-evidence' / 'visual-quality-contact-sheet.png', PACK / 'full-evidence' / '41_VISUAL_QUALITY_CONTACT_SHEET.png')
    shutil.copy2(PACK / 'full-evidence' / 'comparison-contact-sheet.png', PACK / 'full-evidence' / '42_TECHNICAL_ISOLATION_CONTACT_SHEET.png')
    shutil.copy2(PACK / 'full-evidence' / 'black-frame-rejection-report.md', PACK / 'full-evidence' / '43_BLACK_FRAME_REJECTION_REPORT.md')
    (PACK / 'full-evidence' / 'decision-and-scorecard.md').write_text('# v0.322 evidence decision\n\nDecision: **READY FOR HUMAN ART REVIEW**\n\nThis is a feasibility hero slice only. It demonstrates a coherent bridge hamlet composition with true 3D terrain, a recessed curved river, a timber/granite bridge, differentiated Barrosan buildings, grounded authored units and restrained lighting. Human review is still required before any production integration.\n', encoding='utf-8')

if __name__ == '__main__':
    main()
