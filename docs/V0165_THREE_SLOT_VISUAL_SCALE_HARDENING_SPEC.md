# v0.165 Three-Slot Visual Scale Hardening Spec

Status: `PASS_V0165_THREE_SLOT_VISUAL_HARDENING_HUMAN_REVIEW_READY`

## Scope

v0.165 hardens only the existing player-facing opt-in Salto art posture:

1. Worker billboard, `HYBRID_WORKER_TRIMMED_1024`
2. Barracks material, `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`
3. Militia billboard, `HYBRID_MILITIA_TRIMMED_1024`

The default stabilized launcher remains procedural. The Worker-only and Worker + Barracks launchers remain unchanged. No new image, art slot, Aster import, Ashen import, browser runtime wiring, save change, stable-ID change, or gameplay change is authorized.

## Reproduction Requirement

The human screenshot concern is treated as a report to investigate, not a diagnosis. v0.165 must inspect M0 through M5 in the Windows Godot player-facing app:

- M0: procedural baseline
- M1: Worker only
- M2: Worker + Barracks
- M3: Worker + Barracks + Militia
- M4: M3 with Militia missing-art fallback
- M5: M3 with Militia hash-mismatch fallback

## Proven Defect

Before repair, the selected Worker and Militia PNGs were both square 1024 x 1024 sources, but the runtime quad dimensions were not square:

- Worker runtime quad: `0.55 x 0.74`, aspect `0.7432`
- Militia runtime quad: `0.50 x 0.68`, aspect `0.7353`

This compressed both square billboard textures horizontally and reproduced the "small and narrow" screenshot concern.

## Allowed Repair Applied

The runtime width calculation now derives width from runtime height multiplied by source aspect ratio:

- Worker: `runtimeWorldWidth = runtimeWorldHeight * 1024 / 1024`
- Militia: `runtimeWorldWidth = runtimeWorldHeight * 1024 / 1024`

No source art, metadata file, launcher, slot count, gameplay rule, save path, or browser runtime path is changed.

## Evidence

Primary evidence is generated under `artifacts/desktop-spikes/godot-salto/v0165/`:

- `audit/v0165-billboard-scale-aspect-pivot-audit.json`
- `audit/v0165-duplicate-render-audit.json`
- `audit/v0165-barracks-material-binding-review.json`
- `benchmark/v0165-three-slot-benchmark-report.json`
- `capture/v0165-three-slot-visual-capture-report.json`
- `boundary/v0165-player-slice-three-slot-boundary-scan.json`
- `artifact-hygiene/salto-experimental-artifact-inventory.json`
