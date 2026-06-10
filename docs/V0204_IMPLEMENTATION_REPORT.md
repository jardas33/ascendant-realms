# v0.204 Implementation Report

Status: `PASS_V0204_IMPLEMENTATION_REPORT`

v0.204 implements a reversible, private opt-in Barrosan structure-shell material binding for the isolated Salto shell-v2 Godot review path. It does not create a production runtime-art slot and does not change the default procedural launcher.

## Completed

- Confirmed the v0.203 checkpoint at `02f59e665187604296bffa9a370a406b5b72fc9f` was clean, synced, pushed, and green on GitHub Actions before edits.
- Resolved the selected v0.202 material derivative and metadata from tracked docs, then validated the required SHA-256 `94d4975f9e6f13453103439135da930b74d1d66b56d2b10e43219de408f508ef`.
- Added the isolated `--salto-shell-v2-structure-material` / `--structure-finish-material-opt-in` Godot review path and Windows launch, review, capture, and validate wrappers.
- Applied the material only to scoped shell-v2 Command Hall, mine, and Barracks visual surfaces, preserving terrain, roads, bridge deck, riverbanks, Lume visuals, units, markers, HUD, minimap, and browser runtime.
- Added fail-closed missing-art and hash-mismatch fallbacks to the prior shell-v2 presentation.
- Exported the required manual-review PNG pack under `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0204-structure-shell-material\`.

## Verification

- `npm run godot:structure-finish-material:validate`
- `npm run godot:validate:salto-shell-v2-structure-material`
- `npm run godot:capture:salto-shell-v2-structure-material`
- `npm run validate:runtime-art-slots`
- `npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run build`
- `git diff --check`

## Boundary Result

- No generated images.
- No downloaded assets.
- No browser runtime wiring.
- No default launcher change.
- No gameplay, pathing, collision, objective, AI, economy, save, stable-ID, or balance changes.
- No character billboard slot changes.
- No production runtime-art slot leakage.

## Stop Condition

v0.204 stops for human review after the checkpoint push and CI confirmation. No v0.205 work is started.
