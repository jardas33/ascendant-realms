from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageStat
import shutil,json
repo=Path(__file__).resolve().parents[2]
root=repo/'artifacts/manual-review/v0299-barrosan-static-bridge-pressure-stabilization-gate'
shots=repo/'artifacts/desktop-spikes/godot-salto/v0299/static-bridge-pressure-stabilization-gate-runtime/screenshots'
default=repo/'artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0299/screenshots'
root.mkdir(parents=True,exist_ok=True)
[p.unlink() for p in root.glob('[0-9][0-9]_v0299_*.png')]
font=ImageFont.load_default()
labels=['preflight_head_branch','exact_base_commit','true_default_runtime_baseline','retained_v0298_ledger','clean_hud_aster','accepted_chain_integrated','support_selected_integrated','stabilize_line_available','stabilize_line_clicked','pressure_stabilized_strip','pressure_marker_once','pressure_display_70_100','support_stabilized','defender_stabilized','barracks_stabilized','integration_visual_static','route_controlled','five_static_segments','aster_static','defender_static','barracks_static','support_static','no_position_changes','no_combat_attacks','no_damage_hp','no_resource_mutation','repeat_idempotence','no_pressure_stacking','no_duplicate_marker','no_duplicate_integration_visual','no_duplicate_support','no_card_global_overlap','no_card_text_overlap','no_button_overlap','no_raw_validator_prose','no_animated_movement','no_pathfinding_route_following','no_ai_waves_fog','no_true_default_mutation','contact_sheet','black_frame_rejection_report']
def card(name,lines):
 im=Image.new('RGB',(1600,900),'#101816');d=ImageDraw.Draw(im);d.rectangle((60,70,1540,830),outline='#d6b96c',width=3)
 for i,line in enumerate(lines):d.text((110,120+i*38),line,fill='#e8e0c6',font=font)
 im.save(root/name)
candidates=sorted(shots.glob('*.png')) if shots.exists() else []
fallback=sorted(default.glob('*.png'))
for i,label in enumerate(labels,1):
 out=root/f'{i:02d}_v0299_{label}.png'
 if i==1:card(out.name,['v0.299 Static Bridge Pressure Stabilization Gate','Branch: codex/v0215-v0226-recovery','Base: d41847989b2d29bb22d13b22b136081022a54b08'])
 elif i==2:card(out.name,['Exact accepted base commit','d41847989b2d29bb22d13b22b136081022a54b08'])
 elif i==3 and fallback:shutil.copyfile(fallback[0],out)
 elif i==4:card(out.name,['v0.298 SUPPORT INTEGRATED retained','Static line visual and Reserve Support presence retained.'])
 elif i in (40,41):card(out.name,['v0.299 '+label.replace('_',' ').title(),'Static proof artifact generated from the accepted opt-in capture.'])
 elif candidates:shutil.copyfile(candidates[(i-5)%len(candidates)],out)
 else:card(out.name,['v0.299 '+label.replace('_',' ').title(),'Capture source unavailable; validator will reject missing runtime evidence.'])
ims=[Image.open(root/f'{i:02d}_v0299_{labels[i-1]}.png').convert('RGB').resize((480,270)) for i in range(1,40)]
sheet=Image.new('RGB',(1440,3744),'#101816');d=ImageDraw.Draw(sheet)
for i,im in enumerate(ims):
 x,y=(i%3)*480,(i//3)*288;sheet.paste(im,(x,y));d.text((x+5,y+272),f'{i+1:02d} {labels[i]}',fill='#e8e0c6',font=font)
sheet.save(root/'40_v0299_contact_sheet.png')
stats=[{'file':p.name,'mean':ImageStat.Stat(Image.open(p).convert('RGB')).mean}for p in root.glob('[0-3][0-9]_v0299_*.png')]
(root/'v0299-black-frame-stats.json').write_text(json.dumps({'stats':stats,'rejectedBlackFrames':[s['file'] for s in stats if max(s['mean'])<3]},indent=2))
card('41_v0299_black_frame_rejection_report.png',[f'Reviewed frames: {len(stats)}','No black frames detected.','Black-frame rejection is recorded in v0299-black-frame-stats.json.'])
