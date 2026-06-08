# v0.170 Ashen Raider Fifth Opt-In Spec

Status: `PASS_V0170_ASHEN_OPT_IN_VALIDATED`

v0.170 adds exactly one fifth normal-slice opt-in art slot to the Godot Salto player-slice experiment:

- Slot: `ashen_raider_billboard_static_v0156`
- Approach: `HYBRID_ASHEN_RAIDER_V0157_TRIMMED_1024`
- Selected derivative: `artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_trimmed_1024.png`
- SHA-256: `8eb011f56d5cd56cf6ef0a843d2a5899e27aa13e203cc44517ed4a0c55c631c8`

The v0.156 Ashen source remains archived comparison evidence only. The selected v0.157 replacement derivative is the only authorized Ashen source for this player-slice experiment.

## Launcher

- `GODOT_LAUNCH_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_FIVE_SLOT_ART_EXPERIMENT_WINDOWS.bat`
- `npm run godot:launch:salto-five-slot-art-experiment`
- `npm run godot:capture:salto-five-slot-art-experiment`
- `npm run godot:validate:salto-five-slot-art-experiment`
- `npm run godot:review:salto-five-slot-art`

## Runtime Contract

Ashen art is explicit opt-in only through `--ashen-art-opt-in`.

The loader validates:

- slot ID
- derivative kind
- SHA-256
- dimensions
- transparent corners and alpha bounds
- halo edge metadata
- bottom-center foot pivot

If source or metadata is missing, or if the expected SHA mismatches, only Ashen falls back to procedural hostile units. Worker, Barracks, Militia, and Aster remain loaded in the fallback scenarios.

The procedural Ashen body is suppressed only when the validated Ashen source is loaded. No sixth slot is added.

## Presentation Hardening

The five-slot review path also keeps the opening battle composition readable:

- The player-facing battle shell reapplies staging when entering battle, so unrecruited friendly military billboards do not appear before Barracks/Militia progression.
- Review rings now obey each unit's `reviewHidden` state.
- The staged pressure-wave handoff still restores defenders for the four-Ashen combat onset.

## Non-Goals

- No generated images.
- No default art enablement.
- No browser runtime wiring.
- No save or stable-ID changes.
- No mutation of prior launchers.
- No v0.171 work.
