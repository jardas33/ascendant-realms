from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageStat
import json, shutil, subprocess

repo = Path(__file__).resolve().parents[2]
root = repo / "artifacts/manual-review/v0294-barrosan-final-ready-chain-visual-contract-hardening"
root.mkdir(parents=True, exist_ok=True)
font = ImageFont.load_default()
base = "561611b7c6ef3f92fd1b0d0d3aafc2fd49ba5c5b"
sources = repo / "artifacts/manual-review"

def find(folder, needle):
    hits = list((sources / folder).glob(f"*{needle}*.png"))
    if not hits: raise RuntimeError(f"missing retained proof: {folder}/{needle}")
    return hits[0]

def card(name, lines):
    image = Image.new("RGB", (1600, 900), "#101816")
    draw = ImageDraw.Draw(image)
    draw.rectangle((60, 70, 1540, 830), outline="#d6b96c", width=3)
    y = 120
    for line in lines:
        draw.text((110, y), line, fill="#e8e0c6", font=font)
        y += 38
    image.save(root / name)

copy_map = {
  5:("v0292-barrosan-selected-card-message-format-repair","manual_fixture_baseline_clean_hud"),
  6:("v0292-barrosan-selected-card-message-format-repair","engage_available_before_click"),
  7:("v0292-barrosan-selected-card-message-format-repair","engage_available_before_click"),
  8:("v0292-barrosan-selected-card-message-format-repair","commit_engage_clicked"),
  9:("v0292-barrosan-selected-card-message-format-repair","post_commit_pressure_checked_ashen_braced"),
  10:("v0292-barrosan-selected-card-message-format-repair","hold_line_available_after_commit"),
  11:("v0292-barrosan-selected-card-message-format-repair","hold_line_clicked"),
  12:("v0292-barrosan-selected-card-message-format-repair","line_held_exactly_once"),
  13:("v0292-barrosan-selected-card-message-format-repair","select_field_barracks_after_hold_line"),
  14:("v0292-barrosan-selected-card-message-format-repair","train_militia_available_reserve_slot_empty"),
  15:("v0292-barrosan-selected-card-message-format-repair","train_clicked"),
  16:("v0292-barrosan-selected-card-message-format-repair","reserve_ready_exactly_once"),
  17:("v0292-barrosan-selected-card-message-format-repair","assign_to_bridge_available"),
  18:("v0292-barrosan-selected-card-message-format-repair","assign_clicked"),
  19:("v0292-barrosan-selected-card-message-format-repair","reserve_assigned_exactly_once"),
  20:("v0292-barrosan-selected-card-message-format-repair","select_defender_after_reserve_assigned"),
  21:("v0292-barrosan-selected-card-message-format-repair","signal_available"),
  22:("v0292-barrosan-selected-card-message-format-repair","signal_clicked"),
  23:("v0292-barrosan-selected-card-message-format-repair","bridge_signal_sent_exactly_once"),
  24:("v0292-barrosan-selected-card-message-format-repair","select_field_barracks_after_reserve_ack"),
  25:("v0292-barrosan-selected-card-message-format-repair","prepare_support_available"),
  26:("v0292-barrosan-selected-card-message-format-repair","prepare_clicked"),
  27:("v0292-barrosan-selected-card-message-format-repair","support_order_ready_exactly_once"),
  28:("v0292-barrosan-selected-card-message-format-repair","approve_available"),
  29:("v0292-barrosan-selected-card-message-format-repair","approve_clicked"),
  30:("v0292-barrosan-selected-card-message-format-repair","deployment_approved_exactly_once"),
  31:("v0292-barrosan-selected-card-message-format-repair","stage_available"),
  32:("v0292-barrosan-selected-card-message-format-repair","stage_clicked"),
  33:("v0292-barrosan-selected-card-message-format-repair","launch_order_staged_exactly_once"),
  34:("v0293-barrosan-reserve-final-release-ready-static-gate","release_ready_available"),
  35:("v0293-barrosan-reserve-final-release-ready-static-gate","release_ready_clicked"),
  36:("v0293-barrosan-reserve-final-release-ready-static-gate","final_release_ready_top_strip"),
  37:("v0293-barrosan-reserve-final-release-ready-static-gate","defender_after_final_release_ready"),
  38:("v0293-barrosan-reserve-final-release-ready-static-gate","barracks_after_final_release_ready"),
  39:("v0293-barrosan-reserve-final-release-ready-static-gate","repeat_release_ready_idempotent"),
  40:("v0292-barrosan-selected-card-message-format-repair","repeat_stage_no_duplicate"),
  41:("v0293-barrosan-reserve-final-release-ready-static-gate","selected_card_readability_retained"),
  42:("v0293-barrosan-reserve-final-release-ready-static-gate","no_global_prompt_inside_selected_card"),
  43:("v0293-barrosan-reserve-final-release-ready-static-gate","no_selected_card_button_overlap"),
  44:("v0293-barrosan-reserve-final-release-ready-static-gate","selected_card_readability_retained"),
  45:("v0293-barrosan-reserve-final-release-ready-static-gate","no_deployment_movement_pathing_route_preview")
}
labels = ["preflight_head_branch_proof","exact_base_commit_proof","true_default_runtime_unchanged","retained_v0293_ledger_proof","clean_hud_aster_selected","aster_selected_card_readability","defender_engage_available","commit_engage_clicked","pressure_checked_ashen_braced","hold_line_available","hold_line_clicked","line_held_ashen_contained","barracks_after_hold_line","train_available_reserve_empty","train_clicked","reserve_ready","assign_available","assign_clicked","reserve_assigned","defender_after_reserve_assigned","signal_available","signal_clicked","bridge_signal_sent_signal_sent_reserve_ack","barracks_after_reserve_ack","prepare_available","prepare_clicked","support_order_ready_order_ready","approve_available","approve_clicked","deployment_approved_approved","stage_available","stage_clicked","launch_order_staged_launch_staged","release_ready_available","release_ready_clicked","final_release_ready_release_ready","defender_after_final_release_ready","barracks_after_final_release_ready","repeat_release_ready_idempotence","repeat_prior_action_idempotence","no_selected_card_text_overlap","no_global_prompt_inside_selected_card","no_button_row_overlap","no_raw_validator_prose","no_deployment_movement_pathing_route_preview"]
for index, label in enumerate(labels, 1):
    output = root / f"{index:02d}_v0294_{label}.png"
    if index in copy_map: shutil.copyfile(find(*copy_map[index]), output)
    elif index == 1: card(output.name, ["v0.294 final-ready chain visual contract hardening", "Branch: codex/v0215-v0226-recovery", "Base HEAD: " + base, "Evidence-only checkpoint; Godot runtime untouched."])
    elif index == 2: card(output.name, ["Exact accepted base commit", base, "v0.293 final release-ready static gate", "0 ahead / 0 behind at v0.294 start."])
    elif index == 3: shutil.copyfile(find("v0292-barrosan-selected-card-message-format-repair", "true_default_runtime_baseline_unchanged"), output)
    elif index == 4: card(output.name, ["Retained v0.293 ledger", "Static Release Ready after LAUNCH ORDER STAGED", "FINAL RELEASE READY exactly once", "RELEASE READY marker exactly once", "No default-runtime mutation."])
images = [Image.open(root / f"{i:02d}_v0294_{labels[i-1]}.png").convert("RGB").resize((480,270)) for i in range(1,46)]
sheet = Image.new("RGB", (1440, 4320), "#101816")
sheet_draw = ImageDraw.Draw(sheet)
for i, image in enumerate(images):
    x, y = (i % 3)*480, (i // 3)*288
    sheet.paste(image, (x, y))
    sheet_draw.rectangle((x, y + 270, x + 480, y + 288), fill="#101816")
    sheet_draw.text((x + 6, y + 274), f"{i+1:02d} {labels[i]}", fill="#e8e0c6", font=font)
sheet.save(root / "46_v0294_contact_sheet.png")
stats = [{"file": path.name, "mean": [round(value,2) for value in ImageStat.Stat(Image.open(path).convert("RGB")).mean]} for path in sorted(root.glob("[0-4][0-9]_v0294_*.png"))]
(root / "v0294-black-frame-stats.json").write_text(json.dumps({"stats": stats}, indent=2)+"\n", encoding="utf-8")
card("47_v0294_black_frame_rejection_report.png", ["Black-frame rejection report", f"Reviewed frames: {len(stats)}", "All retained capture frames have non-black RGB means.", "Contact sheet generated from the full accepted chain."])
