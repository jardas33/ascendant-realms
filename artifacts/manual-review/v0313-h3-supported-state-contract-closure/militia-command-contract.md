# Militia command contract

| Surface | Observed contract | Result |
|---|---|---|
| visible Hold | `_on_live_ui_shell_move_pressed` | present, but aliases Move |
| authoritative method reached | `issue_move_order` | reached |
| distinct Hold handler | none | not present |
| state before | idle/selected or stopped | recorded in hold-command-audit.json |
| state after | move_ordered/travelling or destination/stopped | recorded in hold-command-audit.json |
| save/load | `capture_save_state` / `restore_capture_save_state` | real opt-in capture proof |
| H3/fallback | `set_v0311_h3_runtime_pilot_enabled` | presentation-only rollback |

The generic Hold label is a HUD contract limitation, not a new H3 gameplay state.
