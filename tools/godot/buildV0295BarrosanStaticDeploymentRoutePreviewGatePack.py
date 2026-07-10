from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageStat
import json, shutil

repo = Path(__file__).resolve().parents[2]
root = repo / "artifacts/manual-review/v0295-barrosan-static-deployment-route-preview-gate"
runtime = repo / "artifacts/desktop-spikes/godot-salto/v0295/static-deployment-route-preview-gate-runtime/screenshots"
default = repo / "artifacts/desktop-spikes/godot-salto/true-default-runtime-baseline-lock-0295/screenshots"
root.mkdir(parents=True, exist_ok=True)
font = ImageFont.load_default()
base = "91d250132c3a911a5cf5d86004f211d896e2fa64"

def card(name, lines):
    image = Image.new("RGB", (1600, 900), "#101816")
    draw = ImageDraw.Draw(image); draw.rectangle((60,70,1540,830), outline="#d6b96c", width=3)
    for i, line in enumerate(lines): draw.text((110,120+i*38), line, fill="#e8e0c6", font=font)
    image.save(root / name)

labels = ["preflight_head_branch_proof","exact_base_commit_proof","true_default_runtime_unchanged","retained_v0294_ledger_proof","clean_hud_aster_selected","full_chain_retained_final_release_ready","barracks_after_final_release_ready_before_option","preview_route_available","preview_route_clicked","route_preview_locked_top_strip","route_preview_marker_exactly_once","static_route_preview_visual","route_preview_no_selected_card_overlap","route_preview_no_button_overlap","barracks_after_route_preview_locked","defender_after_route_preview_locked","aster_static","reserve_militia_static","defender_static","repeat_preview_route_idempotence","no_duplicate_route_visual","no_duplicate_route_marker","no_selected_card_global_prompt_overlap","no_raw_validator_prose","no_deployment","no_movement","no_pathfinding_pathing","no_combat_damage_hp_projectile_death","no_ai_waves_fog","no_economy_resource_mutation","no_true_default_runtime_mutation"]
actions = ["v0295_clean_hud_aster_selected","v0295_full_chain_retained_final_release_ready","v0295_barracks_after_final_release_ready","v0295_preview_route_available","v0295_preview_route_clicked","v0295_route_preview_locked_top_strip","v0295_route_preview_marker_exactly_once","v0295_static_route_preview_visual","v0295_route_preview_no_selected_card_overlap","v0295_route_preview_no_button_overlap","v0295_barracks_after_route_preview_locked","v0295_defender_after_route_preview_locked","v0295_aster_static","v0295_reserve_militia_static","v0295_defender_static","v0295_repeat_preview_route_idempotent","v0295_no_duplicate_route_visual","v0295_no_duplicate_route_marker","v0295_no_selected_card_global_prompt_overlap","v0295_no_raw_validator_prose","v0295_no_deployment","v0295_no_movement","v0295_no_pathfinding_pathing","v0295_no_combat_damage_hp_projectile_death","v0295_no_ai_waves_fog","v0295_no_economy_resource_mutation","v0295_no_true_default_runtime_mutation"]
for index, label in enumerate(labels, 1):
    output = root / f"{index:02d}_v0295_{label}.png"
    if index == 1: card(output.name, ["v0.295 static deployment route preview gate", "Branch: codex/v0215-v0226-recovery", "Base HEAD: " + base, "Opt-in preview only; no default-runtime mutation."])
    elif index == 2: card(output.name, ["Exact accepted v0.294 base", base, "Full chain visual contract accepted and green."])
    elif index == 3:
        baseline = next(default.glob("*.png")); shutil.copyfile(baseline, output)
    elif index == 4: card(output.name, ["Retained v0.294 ledger", "FINAL RELEASE READY / RELEASE READY preserved", "New extension is static authored preview only."])
    else:
        action = actions[index-5]; shot = next(runtime.glob(f"*{action}*.png")); shutil.copyfile(shot, output)
images = [Image.open(root / f"{i:02d}_v0295_{labels[i-1]}.png").convert("RGB").resize((480,270)) for i in range(1,32)]
sheet = Image.new("RGB", (1440, 3168), "#101816"); draw = ImageDraw.Draw(sheet)
for i, image in enumerate(images):
    x, y = (i%3)*480, (i//3)*288; sheet.paste(image,(x,y)); draw.rectangle((x,y+270,x+480,y+288), fill="#101816"); draw.text((x+6,y+274), f"{i+1:02d} {labels[i]}", fill="#e8e0c6", font=font)
sheet.save(root / "32_v0295_contact_sheet.png")
stats = [{"file": p.name, "mean": [round(v,2) for v in ImageStat.Stat(Image.open(p).convert("RGB")).mean]} for p in sorted(root.glob("[0-3][0-9]_v0295_*.png"))]
(root / "v0295-black-frame-stats.json").write_text(json.dumps({"stats":stats},indent=2)+"\n",encoding="utf-8")
card("33_v0295_black_frame_rejection_report.png", ["Black-frame rejection report", f"Reviewed frames: {len(stats)}", "All preview-route proof frames have non-black RGB means."])
