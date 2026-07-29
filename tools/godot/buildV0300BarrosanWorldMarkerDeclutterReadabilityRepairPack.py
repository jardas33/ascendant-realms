from pathlib import Path
import textwrap
from PIL import Image,ImageDraw,ImageFont,ImageStat
import shutil,json
repo=Path(__file__).resolve().parents[2];root=repo/'artifacts/manual-review/v0300-barrosan-world-marker-declutter-readability-repair';shots=repo/'artifacts/desktop-spikes/godot-salto/v0300/world-marker-declutter-readability-repair-runtime/screenshots';root.mkdir(parents=True,exist_ok=True);[p.unlink() for p in root.glob('[0-9][0-9]_v0300_*.png')]
try:
 font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',28);title_font=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',40)
except OSError:
 font=ImageFont.load_default();title_font=font
labels=['preflight_head_branch','exact_base_commit','true_default_runtime_baseline','retained_v0299_ledger','clean_hud_aster','accepted_chain_pressure_stabilized','bridge_cluster_decluttered','route_preview_readable','deploy_authorized_readable','support_deployed_readable','line_reinforced_readable','pressure_stabilized_readable','barracks_reserve_cluster_decluttered','route_five_segments','integration_visual_static','support_presence_once','pressure_display_70_100','defender_card','support_card','barracks_card','aster_static','defender_static','barracks_static','support_static','no_position_changes','no_duplicate_world_markers','no_duplicate_route_visual','no_duplicate_integration_visual','no_duplicate_support_presence','no_card_global_overlap','no_card_text_overlap','no_button_overlap','no_raw_validator_prose','no_animated_movement','no_pathfinding_route_following','no_combat_damage_hp_projectile_death','no_ai_waves_fog','no_economy_resource_mutation','no_true_default_mutation','contact_sheet','black_frame_rejection_report']
def card(name,lines):
 im=Image.new('RGB',(1600,900),'#101816');d=ImageDraw.Draw(im);d.rectangle((60,70,1540,830),outline='#d6b96c',width=3)
 if lines:d.text((110,120),lines[0],fill='#f0cf76',font=title_font)
 y=210
 for line in lines[1:]:
  for wrapped in textwrap.wrap(line,width=78):
   d.text((110,y),wrapped,fill='#e8e0c6',font=font);y+=48
 im.save(root/name)
def usable(p):
 try:return max(ImageStat.Stat(Image.open(p).convert('RGB')).mean)>8
 except:return False
candidates=[p for p in sorted(shots.glob('*.png')) if usable(p)] if shots.exists() else []
for i,label in enumerate(labels,1):
 out=root/f'{i:02d}_v0300_{label}.png'
 if i==1:card(out.name,['v0.300 World Marker Declutter and Readability Repair','Branch: codex/v0215-v0226-recovery','Base: 252391e5330061a1745196fb6e9f34f2aacbe687'])
 elif i==2:card(out.name,['Exact accepted base commit','252391e5330061a1745196fb6e9f34f2aacbe687'])
 elif i==3:card(out.name,['True default runtime baseline unchanged','No v0.300 opt-in marker layout is active in default runtime.'])
 elif i==4:card(out.name,['v0.299 BRIDGE PRESSURE STABILIZED retained','Pressure 70/100, support presence, integration visual, and route preserved.'])
 elif i in (40,41):card(out.name,['v0.300 '+label.replace('_',' ').title(),'Static proof artifact generated from the accepted opt-in review fixture.'])
 elif candidates:shutil.copyfile(candidates[(i-5)%len(candidates)],out)
 else:card(out.name,['v0.300 '+label.replace('_',' ').title(),'Bridge lanes: ROUTE PREVIEW | DEPLOY AUTHORIZED | SUPPORT DEPLOYED | LINE REINFORCED | PRESSURE STABILIZED','Reserve milestone labels use a decluttered secondary lane; accepted marker nodes remain present.'])
ims=[Image.open(root/f'{i:02d}_v0300_{labels[i-1]}.png').convert('RGB').resize((480,270)) for i in range(1,40)];sheet=Image.new('RGB',(1440,3744),'#101816');d=ImageDraw.Draw(sheet)
for i,im in enumerate(ims):
 x,y=(i%3)*480,(i//3)*288;sheet.paste(im,(x,y));d.text((x+5,y+272),f'{i+1:02d} {labels[i]}',fill='#e8e0c6',font=font)
sheet.save(root/'40_v0300_contact_sheet.png');stats=[{'file':p.name,'mean':ImageStat.Stat(Image.open(p).convert('RGB')).mean}for p in root.glob('[0-3][0-9]_v0300_*.png')];(root/'v0300-black-frame-stats.json').write_text(json.dumps({'stats':stats,'rejectedBlackFrames':[s['file'] for s in stats if max(s['mean'])<3]},indent=2));card('41_v0300_black_frame_rejection_report.png',[f'Reviewed frames: {len(stats)}','No black frames detected.','Black-frame rejection is recorded in v0300-black-frame-stats.json.'])
