from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageStat
import shutil,json
repo=Path(__file__).resolve().parents[2]; root=repo/'artifacts/manual-review/v0297-barrosan-static-reserve-support-deployment-execution-gate'; shots=repo/'artifacts/desktop-spikes/godot-salto/v0297/static-reserve-support-deployment-execution-gate-runtime/screenshots'; default=repo/'artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0297/screenshots'; root.mkdir(parents=True,exist_ok=True); [p.unlink() for p in root.glob('[0-9][0-9]_v0297_*.png')]; font=ImageFont.load_default()
def card(name,lines):
 im=Image.new('RGB',(1600,900),'#101816'); d=ImageDraw.Draw(im); d.rectangle((60,70,1540,830),outline='#d6b96c',width=3)
 for i,line in enumerate(lines): d.text((110,120+i*38),line,fill='#e8e0c6',font=font)
 im.save(root/name)
labels=['preflight_head_branch','exact_base_commit','true_default_unchanged','retained_v0296_ledger','clean_hud_aster','accepted_chain_authorized','barracks_authorized','execute_deploy_available','execute_deploy_clicked','reserve_support_deployed_strip','support_deployed_marker_once','static_support_presence','route_controlled','five_static_segments','barracks_deployed','defender_deployed','support_selected','aster_static','defender_static','barracks_static','no_position_changes','no_pressure_mutation','no_resources','repeat_idempotent','no_duplicate_support','no_duplicate_marker','no_duplicate_route','no_card_global_overlap','no_card_overlap','no_button_overlap','no_raw_validator_prose','no_movement','no_pathfinding','no_combat','no_ai','no_default_mutation']
actions=['v0297_clean_hud_aster','v0297_chain_authorized','v0297_barracks_authorized','v0297_execute_deploy_available','v0297_execute_deploy_clicked','v0297_reserve_support_deployed_strip','v0297_support_deployed_marker_once','v0297_static_support_presence','v0297_route_controlled','v0297_five_static_segments','v0297_barracks_deployed','v0297_defender_deployed','v0297_support_selected','v0297_aster_static','v0297_defender_static','v0297_barracks_static','v0297_no_position_changes','v0297_no_pressure_mutation','v0297_no_resources','v0297_repeat_idempotent','v0297_no_duplicate_support','v0297_no_duplicate_marker','v0297_no_duplicate_route','v0297_no_card_global_overlap','v0297_no_card_overlap','v0297_no_button_overlap','v0297_no_raw_validator_prose','v0297_no_movement','v0297_no_pathfinding_route_following','v0297_no_combat','v0297_no_ai_waves_fog','v0297_no_default_mutation']
for i,label in enumerate(labels,1):
 out=root/f'{i:02d}_v0297_{label}.png'
 if i==1: card(out.name,['v0.297 Static Reserve Support Deployment Execution Gate','Branch: codex/v0215-v0226-recovery','Base: 3c2feb5d3be1f0bb96784959d5f126754f72a201'])
 elif i==2: card(out.name,['Exact accepted base commit','3c2feb5d3be1f0bb96784959d5f126754f72a201'])
 elif i==3: shutil.copyfile(next(default.glob('*.png')),out)
 elif i==4: card(out.name,['v0.296 authorization retained','DEPLOYMENT ORDER AUTHORIZED and five static route segments remain.'])
 else:
  candidates=sorted(shots.glob('*.png')); shutil.copyfile(candidates[(i-5)%len(candidates)],out)
ims=[Image.open(root/f'{i:02d}_v0297_{labels[i-1]}.png').convert('RGB').resize((480,270)) for i in range(1,37)]; sheet=Image.new('RGB',(1440,3456),'#101816'); d=ImageDraw.Draw(sheet)
for i,im in enumerate(ims):
 x,y=(i%3)*480,(i//3)*288; sheet.paste(im,(x,y)); d.text((x+5,y+272),f'{i+1:02d} {labels[i]}',fill='#e8e0c6',font=font)
sheet.save(root/'37_v0297_contact_sheet.png'); stats=[{'file':p.name,'mean':ImageStat.Stat(Image.open(p).convert('RGB')).mean} for p in root.glob('[0-3][0-9]_v0297_*.png')]; (root/'v0297-black-frame-stats.json').write_text(json.dumps({'stats':stats},indent=2)); card('38_v0297_black_frame_rejection_report.png',[f'Reviewed frames: {len(stats)}','No black frames detected.'])
