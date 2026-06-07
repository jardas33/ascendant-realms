# v0.156 Ashen Raider Billboard Slot Contract

## Slot

`ashen_raider_billboard_static_v0156` is a private comparator slot only.

## Files

- AI source: `artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/ashen_raider_billboard_static_v0156_source.png`
- Deterministic cutout: `artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/ashen_raider_billboard_static_v0156_cutout.png`
- Metadata: `artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/*.metadata.json`
- Tracked fallback: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.png`
- Fallback contract: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/ashen_raider_billboard_static_v0156_fallback.contract.json`

## Invariants

- `exactlyOneAiImageForV0156` must stay true.
- `singleHostilePrivateComparatorRuntimeArtSlotOnly` must stay true.
- `noSixthRuntimeArtSlot` must stay true.
- `privateComparatorOnly` must stay true.
- `productionApproval` must stay `forbidden`.
- `playerSliceIntegration` and `browserIntegration` must stay `forbidden`.
- Selected Worker, Barracks, Aster, and Militia hashes must remain fixed.

The slot is not approved for the normal Salto player slice.
