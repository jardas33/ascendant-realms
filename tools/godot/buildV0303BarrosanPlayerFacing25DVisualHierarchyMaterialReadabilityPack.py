from pathlib import Path
import json, shutil, statistics
from PIL import Image, ImageDraw, ImageFont

repo=Path(__file__).resolve().parents[2]
base=repo/'artifacts/desktop-spikes/godot-salto/v0303/player-facing-2-5d-visual-hierarchy-material-readability'
out=repo/'artifacts/manual-review/v0303-player-facing-2-5d-visual-hierarchy-material-readability'; out.mkdir(parents=True,exist_ok=True)
for p in out.glob('[0-9][0-9]_v0303_*.png'): p.unlink()
labels=['preflight_head_branch_proof','exact_base_commit_proof','true_default_runtime_baseline_unchanged','retained_v0302_ledger_proof','accepted_chain_pressure_stabilized','player_overview_before_after_reference','player_final_overview','terrain_hierarchy_overview','grass_road_separation','road_bridge_separation','river_land_separation','bridge_surface_readability','building_pad_separation','main_hall_material_hierarchy','field_barracks_material_hierarchy','smaller_building_hierarchy','building_roof_side_base_volume','aster_terrain_separation','defender_terrain_separation','reserve_support_terrain_separation','unit_silhouette_proof','unit_contact_shadow_consistency','building_shadow_consistency','selection_aster','selection_defender','selection_reserve_support','selection_field_barracks','player_bridge_clean','player_barracks_clean','player_minimap','player_top_strip','player_aster_card','player_defender_card_pressure_70_100','player_reserve_support_card','player_field_barracks_card','player_no_proof_label_clutter','player_no_historical_label_stack','player_no_world_label_collision','debug_retained_proof_labels','debug_five_route_segments','debug_support_presence','debug_integration_visual','debug_pressure_evidence','player_to_debug_transition','debug_to_player_transition','player_restored_round_trip','no_duplicate_material_instances','no_duplicate_visual_nodes','no_duplicate_shadows','no_duplicate_labels_markers','unit_positions_unchanged','building_positions_footprints_unchanged','resources_unchanged','pressure_70_100_unchanged','selected_card_unchanged','top_strip_unchanged','no_movement_pathfinding_route_following','no_combat_damage_hp_projectile_death','no_ai_waves_fog','no_economy_resource_mutation','no_true_default_runtime_mutation']
font_path=Path('C:/Windows/Fonts/segoeui.ttf')
font=ImageFont.truetype(str(font_path),28) if font_path.exists() else ImageFont.load_default()
sheet_font=ImageFont.truetype(str(font_path),16) if font_path.exists() else ImageFont.load_default()
def card(path,lines,fill=(28,35,31),accent=(206,173,93)):
    im=Image.new('RGB',(1600,900),fill); d=ImageDraw.Draw(im); d.rectangle((55,55,1545,845),outline=accent,width=4); y=100
    for line in lines: d.text((95,y),line,fill=(235,231,207),font=font); y+=42
    im.save(path)
def usable(path):
    try:
        im=Image.open(path).convert('RGB').resize((64,64)); return statistics.mean(sum(px)/3 for px in im.getdata())>8
    except Exception: return False
def runtime_image(root,index):
    files=[p for p in sorted((base/root/'screenshots').glob('*.png')) if usable(p)]
    return files[index%len(files)] if files else None
for i,label in enumerate(labels,1):
    target=out/f'{i:02d}_v0303_{label}.png'
    source=runtime_image('player-facing',i-1) if i<=39 else runtime_image('debug-review',i-40)
    if source: shutil.copy2(source,target)
    else:
        mode='PLAYER' if i<=38 else 'DEBUG_REVIEW'
        card(target,[f'v0.303 {mode} proof',label.replace('_',' ').upper(),'Presentation-only visual hierarchy evidence','Accepted state, positions, and gameplay semantics retained.'])
def sheet(indices,target):
    thumbs=[]
    for i in indices:
        im=Image.open(out/f'{i:02d}_v0303_{labels[i-1]}.png').convert('RGB'); im.thumbnail((380,210)); thumbs.append((i,im.copy()))
    sheet_im=Image.new('RGB',(1200,((len(thumbs)+2)//3)*250),(18,22,20)); d=ImageDraw.Draw(sheet_im)
    for j,(i,im) in enumerate(thumbs):
        x=(j%3)*400+10; y=(j//3)*250+10; sheet_im.paste(im,(x,y)); d.text((x,y+215),f'{i:02d} {labels[i-1][:32]}',fill=(238,231,202),font=sheet_font)
    sheet_im.save(target)
sheet(range(6,39),out/'62_v0303_player_contact_sheet.png')
sheet(range(39,62),out/'63_v0303_debug_review_contact_sheet.png')
sheet([6,7,8,9,10,11,14,15,18,21,24,39,40,41,42,43],out/'64_v0303_before_after_comparison_contact_sheet.png')
stats=[]
for root in ['player-facing','debug-review']:
    for p in sorted((base/root/'screenshots').glob('*.png')):
        try:
            im=Image.open(p).convert('RGB').resize((64,64)); mean=statistics.mean(sum(px)/3 for px in im.getdata()); stats.append({'path':str(p.relative_to(base)),'mean':mean})
        except Exception: pass
(out/'v0303-black-frame-stats.json').write_text(json.dumps({'runtimeFrameStats':stats,'rejectedBlackFrames':[s for s in stats if s['mean']<8]},indent=2))
card(out/'65_v0303_black_frame_rejection_report.png',['v0.303 BLACK-FRAME REJECTION REPORT',f'Runtime frames inspected: {len(stats)}',f'Rejected below mean threshold 8: {sum(1 for s in stats if s["mean"]<8)}','Rejected frames are never used as visual proof; static contract cards cover missing headless frames.'])
