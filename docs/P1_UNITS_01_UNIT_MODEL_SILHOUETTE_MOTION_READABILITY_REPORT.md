# P1 UNITS-01 — Unit Model, Silhouette and Motion Readability

## Scope

This is one bounded Godot-only player-facing unit presentation pass. It improves
the readability of the existing imported unit models at normal RTS scale. It
does not replace assets, add gameplay, or alter movement, navigation, combat,
economy, saves, stable IDs, or authoritative positions.

Base: `ed26c2fadd152f453a91d2114e065667a2d77cc3`
Branch: `codex/p1-units-01`
Worktree: `D:\CodexData\worktrees\ascendant-realms-p1-units-01`

## Current audit

The exact-base P1-R1 baseline captured real imported Lioraen, Barrosan, and
Vorthak units at 1920x1080 and 1366x768. Close views showed genuine authored
models and existing directional shadows. At strategic distance, however,
ownership was weak because the models remained mostly brown/neutral against the
meadow, and feet lacked a consistent local grounding cue. The important defect
was presentation contrast, not missing runtime assets.

## What changed

- Increased the existing per-instance team-color blend for worker, military, and
  hero models. Every material remains duplicated per unit; imported source
  materials are never mutated.
- Added a small, low-profile oval contact shadow beneath PLAYER units. It is
  unshaded, non-selectable, casts no shadow, and is not an ownership marker or
  gameplay zone.
- Kept the debug/review TeamPip path unchanged; the new contact shadow is
  PLAYER-only.
- Added deterministic capture/validation commands that reuse the established
  live-game P1-R1 harness and record exact source SHA, baseline root, dual
  resolutions, and unchanged-position measurements.

## Preserved

- Existing imported models, role height emphasis, animation mapping, facing,
  walk-speed presentation timing, selection rings, health bars, and combat
  feedback.
- Movement speed, navigation, pathing, attack timing, damage, death, economy,
  resources, fog, camera behavior, saves, stable IDs, and true default runtime.
- DEBUG_REVIEW ownership evidence and all minimap/UI changes from prior lanes.

## Commands and evidence

- Capture: `npm run godot:capture:p1-units-01`
- Validate: `npm run godot:test:p1-units-01`
- Baseline: `D:\CodexData\evidence\ascendant-realms-p1-units-01\baseline-p1r1`
- After: `D:\CodexData\evidence\ascendant-realms-p1-units-01`
- Review manifest: `p1-units-01-capture-manifest.json`

Certified runtime is Godot 4.6.3 stable at
`D:\CodexData\tools\godot-4.6.3-stable\Godot_v4.6.3-stable_win64.exe`.

The after capture is accepted only when the existing harness reports real
frames, all role measurements pass, positions-before equal positions-after,
capture SHA equals the current HEAD, and the temporary capture autoload is
absent after execution.
