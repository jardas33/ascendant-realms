# v0.208 UI Shell Comparator Report

## Status

Private comparator implementation passed local capture, boundary, visual review-pack, and shared validation gates.

## Scope

This checkpoint builds the first original fantasy RTS HUD shell as an isolated Godot comparator. It is not wired into the normal player-facing Salto slice and does not change the default launcher.

## Comparator States

- Full overview.
- Aster selected.
- Worker assigned.
- Barracks restoring.
- Barracks restored.
- Build tab.
- Train tab with queued Militia.
- Research tab with disabled prerequisites.
- Ashen alert.
- Minimap and tooltip focus.

## Review Pack

Manual review artifacts are generated at:

`artifacts/manual-review/v0208-ui-shell-comparator/`

Required files:

- `01_full_overview.png`
- `02_aster_selection.png`
- `03_worker_assignment.png`
- `04_barracks_restoring.png`
- `05_barracks_restored.png`
- `06_build_tab.png`
- `07_train_tab.png`
- `08_research_tab.png`
- `09_ashen_alert.png`
- `10_minimap_tooltips.png`
- `11_contact_sheet.png`

The committed source does not include these ignored PNG artifacts; regenerate them with `npm run godot:capture:salto-ui-shell-comparator`.

## Boundary Statement

- Private comparator only.
- No player-facing opt-in launcher yet.
- No generated images.
- No downloaded assets.
- No copied reference assets.
- No runtime art slot added.
- Browser runtime untouched.
- Default launcher unchanged.
- Gameplay, pathing, collision, objectives, AI, economy, saves, stable IDs, and balance untouched.
