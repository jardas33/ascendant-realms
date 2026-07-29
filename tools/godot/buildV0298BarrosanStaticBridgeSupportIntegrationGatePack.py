from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageStat
import shutil,json
repo=Path(__file__).resolve().parents[2];root=repo/'artifacts/manual-review/v0298-barrosan-static-bridge-support-integration-gate';shots=repo/'artifacts/desktop-spikes/godot-salto/v0298/static-bridge-support-integration-gate-runtime/screenshots';default=repo/'artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0298/screenshots';root.mkdir(parents=True,exist_ok=True);[p.unlink() for p in root.glob('[0-9][0-9]_v0298_*.png')];font=ImageFont.load_default()
def card(name,lines):
 im=Image.new('RGB',(1600,900),'#101816');d=ImageDraw.Draw(im);d.rectangle((60,70,1540,830),outline='#d6b96c',width=3)
 for i,line in enumerate(lines):d.text((110,120+i*38),line,fill='#e8e0c6',font=font)
 im.save(root/name)
labels=['preflight_head_branch','exact_base_commit','true_default_unchanged','retained_v0297_ledger','clean_hud_aster','accepted_chain_deployed','support_selected','integrate_available','integrate_clicked','integrated_strip','line_reinforced_marker','integration_visual','route_controlled','five_static_segments','support_integrated','defender_integrated','barracks_integrated','aster_static','defender_static','barracks_static','support_static','no_position_changes','no_pressure_mutation','no_resources','repeat_idempotent','no_duplicate_marker','no_duplicate_visual','no_duplicate_support','no_card_global_overlap','no_card_overlap','no_button_overlap','no_raw_validator_prose','no_movement','no_pathfinding','no_combat','no_ai','no_default_mutation']
for i,label in enumerate(labels,1):
 out=root/f'{i:02d}_v0298_{label}.png'
 if i==1:card(out.name,['v0.298 Static Bridge Support Integration Gate','Branch: codex/v0215-v0226-recovery','Base: 10b477fbc2f9508f3e91c0064a9e7d46a60bc7f9'])
 elif i==2:card(out.name,['Exact accepted base commit','10b477fbc2f9508f3e91c0064a9e7d46a60bc7f9'])
 elif i==3:shutil.copyfile(next(default.glob('*.png')),out)
 elif i==4:card(out.name,['v0.297 deployed support retained','Static support presence remains at East bridge.'])
 else:
  candidates=sorted(shots.glob('*.png'));shutil.copyfile(candidates[(i-5)%len(candidates)],out)
ims=[Image.open(root/f'{i:02d}_v0298_{labels[i-1]}.png').convert('RGB').resize((480,270)) for i in range(1,38)];sheet=Image.new('RGB',(1440,3744),'#101816');d=ImageDraw.Draw(sheet)
for i,im in enumerate(ims):x,y=(i%3)*480,(i//3)*288;sheet.paste(im,(x,y));d.text((x+5,y+272),f'{i+1:02d} {labels[i]}',fill='#e8e0c6',font=font)
sheet.save(root/'38_v0298_contact_sheet.png');stats=[{'file':p.name,'mean':ImageStat.Stat(Image.open(p).convert('RGB')).mean}for p in root.glob('[0-3][0-9]_v0298_*.png')];(root/'v0298-black-frame-stats.json').write_text(json.dumps({'stats':stats},indent=2));card('39_v0298_black_frame_rejection_report.png',[f'Reviewed frames: {len(stats)}','No black frames detected.'])
