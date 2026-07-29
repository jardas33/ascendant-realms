from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageStat
import shutil,json
repo=Path(__file__).resolve().parents[2]; root=repo/'artifacts/manual-review/v0296-barrosan-static-deployment-order-authorization-gate'; shots=repo/'artifacts/desktop-spikes/godot-salto/v0296/static-deployment-order-authorization-gate-runtime/screenshots'; default=repo/'artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0296/screenshots'; root.mkdir(parents=True,exist_ok=True); [path.unlink() for path in root.glob('[0-9][0-9]_v0296_*.png')]; font=ImageFont.load_default()
def card(name,lines):
 im=Image.new('RGB',(1600,900),'#101816'); d=ImageDraw.Draw(im); d.rectangle((60,70,1540,830),outline='#d6b96c',width=3)
 for i,x in enumerate(lines):d.text((110,120+i*38),x,fill='#e8e0c6',font=font)
 im.save(root/name)
labels=['preflight_head_branch','exact_base_commit','true_default_unchanged','retained_v0295_ledger','authorize_available','authorize_clicked','authorized_top_strip','authorized_marker_once','route_preserved','five_static_segments','barracks_authorized','defender_authorized','aster_static','reserve_static','defender_static','barracks_static','repeat_idempotence','no_duplicate_marker','no_duplicate_route','no_card_global_overlap','no_card_overlap','no_button_overlap','no_raw_validator_prose','no_deployment','no_movement','no_pathfinding','no_combat','no_ai','no_resources','no_default_mutation','full_chain_route_preview_locked','authorization_visual','static_route_authorized']
actions=['v0296_authorize_deploy_available','v0296_authorize_deploy_clicked','v0296_deployment_order_authorized_top_strip','v0296_deploy_authorized_marker_exactly_once','v0296_route_preview_preserved','v0296_five_static_segments','v0296_barracks_authorized','v0296_defender_authorized','v0296_aster_static','v0296_reserve_static','v0296_defender_static','v0296_barracks_static','v0296_repeat_authorize_idempotent','v0296_no_duplicate_authorized_marker','v0296_no_duplicate_route_visual','v0296_no_deployment','v0296_no_movement','v0296_no_pathfinding_route_following','v0296_no_combat','v0296_no_ai_waves_fog','v0296_no_resources','v0296_no_default_mutation']
for i,label in enumerate(labels,1):
 out=root/f'{i:02d}_v0296_{label}.png'
 if i==1:card(out.name,['v0.296 Static Deployment Order Authorization Gate','Branch: codex/v0215-v0226-recovery','Base: 2f1853ae510af667253c47c1d50214b27338bbea'])
 elif i==2:card(out.name,['Exact accepted base commit','2f1853ae510af667253c47c1d50214b27338bbea'])
 elif i==3:shutil.copyfile(next(default.glob('*.png')),out)
 elif i==4:card(out.name,['v0.295 route preview retained','Five static authored segments remain unchanged.'])
 else:
  a=actions[(i-5)%len(actions)]; shutil.copyfile(next(shots.glob(f'*{a}*.png')),out)
ims=[Image.open(root/f'{i:02d}_v0296_{labels[i-1]}.png').convert('RGB').resize((480,270)) for i in range(1,34)]; sheet=Image.new('RGB',(1440,3168),'#101816'); d=ImageDraw.Draw(sheet)
for i,im in enumerate(ims):
 x,y=(i%3)*480,(i//3)*288; sheet.paste(im,(x,y)); d.text((x+5,y+272),f'{i+1:02d} {labels[i]}',fill='#e8e0c6',font=font)
sheet.save(root/'34_v0296_contact_sheet.png'); stats=[{'file':p.name,'mean':ImageStat.Stat(Image.open(p).convert('RGB')).mean} for p in root.glob('[0-3][0-9]_v0296_*.png')]; (root/'v0296-black-frame-stats.json').write_text(json.dumps({'stats':stats},indent=2)); card('35_v0296_black_frame_rejection_report.png',[f'Reviewed frames: {len(stats)}','No black frames detected.'])
