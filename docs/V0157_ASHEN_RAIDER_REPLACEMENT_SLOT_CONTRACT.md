# v0.157 Ashen Raider Replacement Slot Contract

v0.157 does not create a new runtime-art slot. It tests replacement candidates for the existing private hostile slot:

- Slot ID: `ashen_raider_billboard_static_v0156`
- Replacement source ID: `ashen_raider_billboard_static_v0157_restrained`
- Private comparator command: `--ashen-raider-visual-restraint-replacement`

Required sources:

- Tracked fallback: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.png`
- Archived v0.156 source/cutout: `artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/`
- v0.157 source/cutout/derivatives: `artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/`
- Selected context: v0.148 Worker, v0.150 Barracks, v0.152 Aster, and v0.155 Militia only.

Guardrails:

- `privateComparatorOnly: true`
- `productionApproval: "forbidden"`
- `playerSliceIntegration: "forbidden"`
- `browserIntegration: "forbidden"`
- `sameHostileSlotOnly: true`
- `noSixthRuntimeArtSlot: true`
- `preservesArchivedV0156ComparisonEvidence: true`

The v0.157 candidate may be recommended for human review, but this contract does not approve runtime import, art-slot registry mutation, browser runtime wiring, or final Ashen Raider art selection.
