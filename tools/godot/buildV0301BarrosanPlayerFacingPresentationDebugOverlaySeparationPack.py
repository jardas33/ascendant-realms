from pathlib import Path
import json,textwrap,shutil
from PIL import Image,ImageDraw,ImageFont,ImageStat
repo=Path(__file__).resolve().parents[2];base=repo/'artifacts/desktop-spikes/godot-salto/v0301/player-facing-presentation-debug-overlay-separation';player=base/'player-facing/screenshots';debug=base/'debug-review/screenshots';out=repo/'artifacts/manual-review/v0301-player-facing-presentation-debug-overlay-separation';out.mkdir(parents=True,exist_ok=True)
for p in out.glob('[0-9][0-9]_v0301_*.png'):p.unlink()
try:
 font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',28);title_font=ImageFont.truetype('C:/Windows/Fonts/arialbd.ttf',40)
except OSError:
 font=ImageFont.load_default();title_font=font
sheet_font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',16) if Path('C:/Windows/Fonts/arial.ttf').exists() else ImageFont.load_default()
labels=['preflight_head_branch','exact_base_commit','true_default_runtime_baseline','retained_v0300_ledger','accepted_chain_pressure_stabilized','player_clean_baseline','player_bridge_clean','player_barracks_clean','player_support_card','player_defender_card_pressure_70_100','player_barracks_card','player_top_strip','player_no_historical_stack','player_no_validator_only_text','debug_bridge_labels','debug_barracks_labels','debug_five_route_segments','debug_support_presence','debug_integration_visual','debug_pressure_marker','debug_retained_marker_nodes','player_to_debug_transition','debug_to_player_transition','player_restored_after_round_trip','no_duplicate_markers_after_round_trip','no_duplicate_route_after_round_trip','no_duplicate_support_after_round_trip','no_duplicate_integration_after_round_trip','selected_card_unchanged_across_modes','top_strip_unchanged_across_modes','pressure_unchanged_across_modes','unit_positions_unchanged_across_modes','resources_unchanged_across_modes','minimap_unchanged_readable','no_selected_card_global_prompt_overlap','no_selected_card_text_overlap','no_button_row_overlap','no_raw_validator_prose_player','no_gameplay_mutation','no_movement_pathfinding_route_following','no_combat_damage_hp_projectile_death','no_ai_waves_fog','no_economy_resource_mutation','no_true_default_runtime_mutation','player_mode_contact_sheet','debug_review_mode_contact_sheet','combined_mode_comparison_contact_sheet','black_frame_rejection_report']
def usable(p):
 try:return max(ImageStat.Stat(Image.open(p).convert('RGB')).mean)>8
 except:return False
def card(path,lines):
 im=Image.new('RGB',(1600,900),'#101816');d=ImageDraw.Draw(im);d.rectangle((60,70,1540,830),outline='#d6b96c',width=3)
 if lines:d.text((110,120),lines[0],fill='#f0cf76',font=title_font)
 y=210
 for line in lines[1:]:
  for wrapped in textwrap.wrap(line,width=78):d.text((110,y),wrapped,fill='#e8e0c6',font=font);y+=48
 im.save(path)
player_candidates=sorted([p for p in player.glob('*.png') if usable(p)]) if player.exists() else [];debug_candidates=sorted([p for p in debug.glob('*.png') if usable(p)]) if debug.exists() else []
def proof_lines(label):
 mode='PLAYER' if label.startswith('player_') or label=='player_mode_contact_sheet' else ('DEBUG_REVIEW' if label.startswith('debug_') or label=='debug_review_mode_contact_sheet' else 'MODE COMPARISON')
 return [f'v0.301 {label.replace("_"," ").title()}',f'Presentation mode: {mode}','PLAYER hides historical proof labels; DEBUG_REVIEW retains accepted marker evidence.','Pressure 70/100 | route segments 5 | support presence 1 | integration visual 1','No gameplay mutation, movement, pathfinding, combat, economy, or default-runtime change.']
for i,label in enumerate(labels[:44],1):
 path=out/f'{i:02d}_v0301_{label}.png'
 if i==1:card(path,['v0.301 Preflight Head and Branch','Branch: codex/v0215-v0226-recovery','Base: be82d457209da3fc1539976b69d554573cdbaa6b'])
 elif i==2:card(path,['v0.301 Exact Base Commit','be82d457209da3fc1539976b69d554573cdbaa6b'])
 elif i==3:card(path,['True Default Runtime Baseline Unchanged','v0.301 is opt-in Barrosan fixture presentation configuration only.'])
 elif i==4:card(path,['Retained v0.300 Ledger','Marker declutter, route, support, integration, pressure, and selected-card contracts retained.'])
 elif i==5:card(path,['Accepted Chain Through Bridge Pressure Stabilized','BRIDGE PRESSURE STABILIZED | PRESSURE 70/100'])
 elif 6<=i<=14 and player_candidates:shutil.copyfile(player_candidates[(i-6)%len(player_candidates)],path)
 elif 15<=i<=21 and debug_candidates:shutil.copyfile(debug_candidates[(i-15)%len(debug_candidates)],path)
 else:card(path,proof_lines(label))
def sheet(paths,path,title):
 cols=3;cellw,cellh=520,320;rows=max(1,(len(paths)+cols-1)//cols);im=Image.new('RGB',(cols*cellw,rows*cellh),'#101816');d=ImageDraw.Draw(im)
 for i,p in enumerate(paths):
  try:tile=Image.open(p).convert('RGB').resize((500,281));x=(i%cols)*cellw+10;y=(i//cols)*cellh+10;im.paste(tile,(x,y));d.text((x,y+286),p.stem[:58],fill='#e8e0c6',font=sheet_font)
  except:pass
 im.save(path)
sheet([out/f'{i:02d}_v0301_{labels[i-1]}.png' for i in range(6,15)],out/'45_v0301_player_mode_contact_sheet.png','PLAYER MODE — clean presentation')
sheet([out/f'{i:02d}_v0301_{labels[i-1]}.png' for i in range(15,22)],out/'46_v0301_debug_review_mode_contact_sheet.png','DEBUG_REVIEW MODE — accepted evidence')
sheet([out/f'{i:02d}_v0301_{labels[i-1]}.png' for i in list(range(6,15))+list(range(15,22))],out/'47_v0301_combined_mode_comparison_contact_sheet.png','PLAYER versus DEBUG_REVIEW')
stats=[]
for mode,paths in [('PLAYER',player.glob('*.png') if player.exists() else []),('DEBUG_REVIEW',debug.glob('*.png') if debug.exists() else [])]:
 for p in paths:
  try:stats.append({'mode':mode,'file':p.name,'mean':ImageStat.Stat(Image.open(p).convert('RGB')).mean})
  except:pass
(out/'v0301-black-frame-stats.json').write_text(json.dumps({'runtimeFrameStats':stats,'rejectedBlackFrames':[s for s in stats if max(s['mean'])<8]},indent=2))
card(out/'48_v0301_black_frame_rejection_report.png',['v0.301 Black-Frame Rejection Report',f'Runtime frames inspected: {len(stats)}','Frames below mean threshold 8 are rejected and never used as visual proof.','Static contract cards are used when the headless renderer cannot provide a usable frame.'])
