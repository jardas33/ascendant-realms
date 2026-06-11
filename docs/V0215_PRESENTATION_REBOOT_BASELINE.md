# v0.215 Presentation Reboot Baseline

Status: PASS

v0.215 creates the first isolated Salto presentation-reboot review path. It preserves the v0.214 full-HUD direction as a comparator and adds a separate opt-in launcher for compact HUD and reduced selection-marker presentation review.

## Scope

- New opt-in launcher: `GODOT_LAUNCH_SALTO_PRESENTATION_REBOOT_EXPERIMENT_WINDOWS.bat`.
- New Godot flag: `--salto-presentation-reboot`.
- New review wrappers:
  - `npm run godot:launch:salto-presentation-reboot`
  - `npm run godot:capture:salto-presentation-reboot`
  - `npm run godot:validate:salto-presentation-reboot`
  - `npm run godot:benchmark:salto-presentation-reboot`
- No generated images.
- No downloaded assets.
- No new runtime art slots.
- No browser runtime wiring.
- No default launcher change.
- No gameplay, pathing, collision, objective, AI, economy, save, stable-ID or balance changes.

## Baseline Decision

The v0.214 full-HUD posture remains available for comparison, but the new reboot path is the active review baseline for presentation declutter. The reboot path keeps battlefield space dominant, moves information into compact contextual surfaces, and reduces the visual weight of selection and target rings.

## Evidence

Manual review pack:

`artifacts/manual-review/v0215-presentation-reboot-declutter/`

Required files produced:

- `01_v0214_rejected_baseline.png`
- `02_reboot_initial.png`
- `03_reboot_context_expanded.png`
- `04_reboot_hostile_alert.png`
- `05_tooltip_docked.png`
- `06_before_after_contact_sheet.png`
- `07_ui_occupancy_measurements.md`

Machine-readable evidence:

- `artifacts/desktop-spikes/godot-salto/v0215/v0215-presentation-reboot-review-pack.json`
- `artifacts/desktop-spikes/godot-salto/v0215/validation/v0215-presentation-reboot-validation.json`
- `artifacts/desktop-spikes/godot-salto/v0215/boundary/v0215-presentation-reboot-boundary.json`
- `artifacts/desktop-spikes/godot-salto/v0215/benchmark/v0215-presentation-reboot-benchmark-summary.md`

## Decision

PASS. v0.215 is a bounded presentation baseline only. Future production-art or terrain work must continue through the queued prompt gates from a clean, pushed, CI-green state.
