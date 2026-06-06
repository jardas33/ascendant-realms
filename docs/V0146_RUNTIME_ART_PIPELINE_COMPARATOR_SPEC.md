# v0.146 Runtime-Art Pipeline Comparator Spec

Status: private Godot comparator spike only.

v0.146 compares three runtime-art pipeline postures inside an isolated Godot harness. It does not import generated reference images, does not generate artwork, does not modify the normal Salto player-facing slice, does not choose the final engine, and does not begin a full port.

## Encoded HUD Review Decision

H3, `v0145-hud-h3-modern-balanced-pc-rts`, is approved as the primary combined Salto HUD reference direction. Retain modern PC RTS/RPG balance, disciplined hierarchy, open central battlefield view, compact resources, objective and secondary-hint placement, selected-unit and squad context, concise command posture, progress clarity, useful minimap, restrained alerts, and readable negative space.

H2, `v0145-hud-h2-barrosan-material-restraint`, is retained as the approved material-language companion. Borrow restrained timber, dark iron, leather, bronze, carved-granite, rugged foothold identity, sparing warm accents, clean framing, and practical Barrosan character without visual mud or excessive panel weight.

H1, `v0145-hud-h1-gameplay-first-tactical-clarity`, is retained only as a limited tactical-information companion. Borrow clear tactical state strip, operational readability, chronology, minimap orientation, and compact alerts; avoid oversized bottom-band density, command crowding, battlefield occlusion, and permanent HUD tiles for every microloop state.

## Comparator Path

Private comparator files:

- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.gd`
- `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/runtime_art_pipeline_comparator.tscn`
- `tools/godot/runtimeArtComparatorTool.mjs`
- `tools/godot/runGodotRuntimeArtComparatorValidation.ps1`
- `tools/godot/runGodotRuntimeArtComparatorBenchmarkWindows.ps1`
- `tools/godot/captureGodotRuntimeArtComparatorWindows.ps1`
- `GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat`

The existing Godot root recognizes `--runtime-art-comparator` only as a private dispatch flag. The no-argument default still opens the player-facing Salto slice, and `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` is not replaced.

## Approaches

`ORTHO_3D_MESH`: orthographic high-three-quarter camera, procedural 3D terrain/structures/units, simple built-in materials, simulated idle/move/combat animation cost, selection discs, and lightweight VFX placeholders.

`BILLBOARD_2D_ATLAS`: orthographic high-three-quarter camera, camera-facing 2D billboard units, diagnostic runtime-generated atlas only, frame-cycling cost proxy, procedural ground/structure stand-ins, selection discs, and lightweight VFX placeholders.

`HYBRID_3D_WORLD_BILLBOARD_UNITS`: procedural 3D environment and structures, diagnostic billboard units, orthographic high-three-quarter camera, selection discs, lightweight VFX placeholders, and compact HUD/minimap diagnostic overlay.

## Workload Tiers

The comparator reuses the v0.119 representative S/M/L semantics:

| Tier | Units | Structures | Sites | Lume posture | Pressure |
| --- | ---: | ---: | ---: | --- | --- |
| S | 14 | 4 | 1 | 2 endpoints, 1 link | none beyond representative commands |
| M | 43 | 4 | 3 | 2 endpoints, 1 link | one bounded pressure beat |
| L | 105 | 6 | 5 | 3 endpoints, 2 links | sustained bounded pressure |

Every approach uses equivalent entity counts, movement beats, selection rings, camera pan/zoom exercise, animation-update proxy, VFX placeholder count, and Results-ready posture. Screenshots are visual evidence only; headed benchmark rows are required for performance claims.

## Commands

```bash
npm run godot:runtime-art-comparator:validate
npm run godot:runtime-art-comparator:benchmark:headed
npm run godot:runtime-art-comparator:capture
```

One-click Windows wrapper:

```bat
GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat
```

## Non-Goals

- No generated reference image import.
- No downloaded model, texture, sprite, atlas, or production asset.
- No browser runtime mutation.
- No normal Salto player-facing slice mutation.
- No runtime manifest, fixture manifest, art-slot registry, save, stable-ID, package inclusion, or production asset path mutation.
- No final engine selection, full port, Unity/Unreal/Electron work, multiplayer, campaign, economy, broad content, or v0.147 work.
