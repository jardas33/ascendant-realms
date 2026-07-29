# v0.367 Ascendant Realms - First Playable Vertical Slice

## Executive result

v0.367 adds the first bounded, genuinely interactive Godot RTS slice behind an explicit opt-in launcher route. The player can select Workers, gather and deposit Gold, place and construct a Field Barracks with a valid/invalid ghost and cancel path, recruit Militia, issue movement and attack orders against two Ashen Raiders, reach Victory or Defeat, and restart the match. The default runtime and accepted proof/debug routes remain unchanged.

## Scope and base

- Base HEAD: `1ff18feff10451f2d8535910acaf9737e2e4524e`
- Branch: `codex/v0215-v0226-recovery`
- Checkpoint: `v0.367`
- Scene: `desktop-spikes/godot-salto/scenes/v0367_first_playable_vertical_slice.tscn`
- Runtime: `desktop-spikes/godot-salto/scripts/v0367_first_playable_vertical_slice.gd`

This is an isolated opt-in vertical slice, not a production-wide conversion and not a replacement for the accepted runtime.

## Player loop

The scene starts in a small launcher with a **PLAY VERTICAL SLICE** route. In the match, two Workers begin near the Main Building and a finite Gold Mine. Right-clicking the mine starts a real gather/carry/deposit loop; Gold changes only when a Worker returns to the Main Building. A selected Worker can open the build placement flow, move a placement ghost, cancel with Escape, reject invalid ground, and spend the build cost only on valid placement. A construction proxy progresses until the clean Field Barracks becomes visible. Selecting the completed Barracks exposes recruitment, which spends Gold and spawns a Militia. The Militia can be moved and commanded to attack the two Raiders; the bounded enemy loop can damage Workers, Militia, or the Main Building. All Raiders defeated produces Victory; Main Building destruction produces Defeat. R or the result action restarts the same match state.

## Controls and launch

```text
npm run godot:play:vertical-slice
```

- Left click: select or confirm placement
- Right click: move, gather, or attack
- Mouse wheel: bounded orthographic zoom
- WASD: camera pan
- Escape: cancel placement
- F3: debug panel toggle
- R: restart after result

Smoke and evidence commands:

```text
npm run godot:smoke:vertical-slice
npm run godot:capture:vertical-slice
npm run godot:validate:vertical-slice
```

## Runtime and art isolation

The new scene owns its match state and does not mutate the accepted state chain, stable IDs, saves, resources outside the slice, or the true default runtime. Its visual map is an oblique orthographic Barrosan/Salto sector with recessed water, bridge, roads, banks, mine, camp, and restrained environmental dressing. The Main Building is loaded from the v0.338 Barrosan House02 gold candidate. Barracks placement uses the clean v0.366 Barn fork path through `res://scenes/gold/barrosan/BarrosanBarnGold.tscn` and the `V0347_Barn_Rendered_Geometry_Truth` component filter. Canonical source scenes remain untouched.

Units use the existing authored Worker and Militia source silhouettes with small grounding geometry and selection rings; no animation system or locomotion overhaul is introduced. The HUD is intentionally narrow: Gold/objective strip, selected-card status, three action buttons, a short status toast, and an F3-only debug panel.

## Evidence

The review pack is:

`artifacts/manual-review/v0367-first-playable-vertical-slice/`

It contains four real gameplay PNGs plus this README. The capture route uses the same interactive scene and commands as the player route, with only accelerated capture pacing. The runtime smoke manifest is written to `artifacts/runtime/v0367/v0367-playable-smoke.json` and proves Gold deposit, Barracks construction, Militia recruitment, combat resolution, Victory, and restart restoration. `UPLOAD_TO_CHAT/` contains exactly the five allowed review files.

## Validation evidence

- `npm run godot:smoke:vertical-slice` - PASS_V0367_FIRST_PLAYABLE_VERTICAL_SLICE_SMOKE
- `npm run godot:capture:vertical-slice` - PASS_V0367_FIRST_PLAYABLE_VERTICAL_SLICE_PACK
- `npm run godot:validate:vertical-slice` - PASS_V0367_FIRST_PLAYABLE_VERTICAL_SLICE
- `npm test` - 122 test files, 887 tests passed
- `npm run build` - production build passed
- `npm run validate:content` - passed
- `npm run validate:art-intake` - passed
- `npm run validate:runtime-art-slots` - passed; 52 slots validated
- `npm run validate:artifact-retention` - PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION
- `npm run godot:all` - passed
- `git diff --check` - passed; only the repository's existing LF/CRLF warning was emitted
- GitHub Actions exact-SHA result is recorded in the final closeout response after push.

The dedicated validator is `tools/godot/saltoV0367FirstPlayableVerticalSliceTool.mjs`. It checks the opt-in launcher route, actual gameplay method ownership, accepted clean asset sources, report/review-pack presence, and the smoke manifest.

## What is not included

1. No production-wide gameplay migration or save integration.
2. No unit animation, pathfinding, formation, or multiplayer systems.
3. No economy beyond the bounded Gold/Mine/Barracks/Militia loop.
4. No full Salto map conversion or broad HUD redesign.
5. No claim of production readiness; this is the first playable vertical slice checkpoint.
