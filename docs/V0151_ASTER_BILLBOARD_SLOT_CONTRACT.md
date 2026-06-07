# v0.151 Aster Billboard Slot Contract

Slot ID: `aster_billboard_static_v0151`.

Tracked fallback:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.png`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/aster_billboard_static_v0151_fallback.contract.json`

Ignored local source:

- `artifacts/desktop-spikes/godot-salto/v0151/local-aster-slot/aster_billboard_static_v0151_source.png`
- `artifacts/desktop-spikes/godot-salto/v0151/local-aster-slot/aster_billboard_static_v0151.png`
- `artifacts/desktop-spikes/godot-salto/v0151/local-aster-slot/aster_billboard_static_v0151.metadata.json`

Contract requirements:

- `privateComparatorOnly: true`
- `productionApproval: forbidden`
- `playerSliceIntegration: forbidden`
- `browserIntegration: forbidden`
- `exactlyOneAiImageForV0151: true`
- `noFourthRuntimeArtSlot: true`
- Reference candidates are brief-only and never imported into the comparator.

The comparator loader fails closed on missing metadata, hash mismatch, slot mismatch, or boundary flag mismatch.
