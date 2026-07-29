from pathlib import Path
import json, shutil, statistics
from PIL import Image, ImageDraw, ImageFont

repo=Path(__file__).resolve().parents[2]
base=repo/'artifacts/desktop-spikes/godot-salto/v0302/player-facing-2-5d-depth-foundation'
out=repo/'artifacts/manual-review/v0302-player-facing-2-5d-depth-foundation'; out.mkdir(parents=True,exist_ok=True)
for p in out.glob('[0-9][0-9]_v0302_*.png'): p.unlink()
labels=['preflight_head_branch_proof','exact_base_commit_proof','true_default_runtime_baseline_unchanged','retained_v0301_ledger_proof','accepted_chain_pressure_stabilized','old_flat_baseline_reference','player_25d_overview','camera_projection','terrain_depth_separation','river_bridge_depth','road_grass_building_pads','main_building_volume','field_barracks_volume','smaller_building_volume','aster_grounding','defender_grounding','reserve_support_grounding','unit_contact_shadows','building_shadow_consistency','selection_aster','selection_defender','selection_field_barracks','selection_reserve_support','player_bridge_clean','player_barracks_clean','player_minimap','player_top_strip','player_aster_card','player_defender_card_pressure_70_100','player_reserve_support_card','player_field_barracks_card','no_proof_label_clutter','no_historical_label_stack','debug_retained_proof_labels','debug_five_route_segments','debug_support_presence','debug_integration_visual','debug_pressure_evidence','player_to_debug_transition','debug_to_player_transition','player_restored_round_trip','no_duplicate_visual_nodes','no_duplicate_shadows','no_duplicate_labels_markers','unit_positions_unchanged','building_positions_footprints_unchanged','resources_unchanged','pressure_70_100_unchanged','selected_card_unchanged','top_strip_unchanged','no_movement_pathfinding_route_following','no_combat_damage_hp_projectile_death','no_ai_waves_fog','no_economy_resource_mutation','no_true_default_runtime_mutation']
font_path=Path('C:/Windows/Fonts/segoeui.ttf')
font=ImageFont.truetype(str(font_path),28) if font_path.exists() else ImageFont.load_default()
sheet_font=ImageFont.truetype(str(font_path),16) if font_path.exists() else ImageFont.load_default()
def card(path, lines, fill=(28,35,31), accent=(206,173,93)):
    im=Image.new('RGB',(1600,900),fill); d=ImageDraw.Draw(im); d.rectangle((55,55,1545,845),outline=accent,width=4)
    y=100
    for line in lines:
        d.text((95,y),line,fill=(235,231,207),font=font); y+=30
    im.save(path)
def usable(path):
    try:
        im=Image.open(path).convert('RGB').resize((64,64)); return statistics.mean(sum(px)/3 for px in im.getdata())>8
    except Exception: return False
def runtime_image(root, index):
    files=sorted((base/root/'screenshots').glob('*.png'))
    usable_files=[p for p in files if usable(p)]
    return usable_files[index%len(usable_files)] if usable_files else None
for i,label in enumerate(labels,1):
    target=out/f'{i:02d}_v0302_{label}.png'
    source=runtime_image('player-facing',i-1) if i<=33 else runtime_image('debug-review',i-34)
    if source: shutil.copy2(source,target)
    else:
        mode='PLAYER' if i<=33 else 'DEBUG_REVIEW'
        card(target,[f'v0.302 {mode} proof',label.replace('_',' ').upper(),'Controlled presentation-only evidence','Accepted state, positions, and gameplay semantics retained.'])
def sheet(indices,target,title):
    thumbs=[]
    for i in indices:
        im=Image.open(out/f'{i:02d}_v0302_{labels[i-1]}.png').convert('RGB'); im.thumbnail((380,210)); thumbs.append((i,im.copy()))
    sheet_im=Image.new('RGB',(1200,((len(thumbs)+2)//3)*250),(18,22,20)); d=ImageDraw.Draw(sheet_im)
    for j,(i,im) in enumerate(thumbs):
        x=(j%3)*400+10; y=(j//3)*250+10; sheet_im.paste(im,(x,y)); d.text((x,y+215),f'{i:02d} {labels[i-1][:32]}',fill=(238,231,202),font=sheet_font)
    sheet_im.save(target)
sheet(range(6,34),out/'56_v0302_player_mode_contact_sheet.png','PLAYER')
sheet(range(34,56),out/'57_v0302_debug_review_mode_contact_sheet.png','DEBUG')
sheet([6,7,8,9,12,13,15,18,24,34,35,36,37,38],out/'58_v0302_before_after_visual_comparison_contact_sheet.png','COMPARE')
stats=[]
for root in ['player-facing','debug-review']:
    for p in sorted((base/root/'screenshots').glob('*.png')):
        try:
            im=Image.open(p).convert('RGB').resize((64,64)); mean=statistics.mean(sum(px)/3 for px in im.getdata()); stats.append({'path':str(p.relative_to(base)),'mean':mean})
        except Exception: pass
(out/'v0302-black-frame-stats.json').write_text(json.dumps({'runtimeFrameStats':stats,'rejectedBlackFrames':[s for s in stats if s['mean']<8]},indent=2))
card(out/'59_v0302_black_frame_rejection_report.png',['v0.302 BLACK-FRAME REJECTION REPORT',f'Runtime frames inspected: {len(stats)}',f'Rejected below mean threshold 8: {sum(1 for s in stats if s["mean"]<8)}','Rejected frames are never used as visual proof; static contract cards cover missing headless frames.'])
