# v0.208 Implementation Report

## Changes

- Added `--salto-ui-shell-comparator` as an isolated Godot capture path.
- Implemented deterministic comparator HUD states for overview, Aster, Worker, Barracks, production tabs, Ashen alert, minimap, and tooltip coverage.
- Added Windows capture and validation wrappers:
  - `godot:capture:salto-ui-shell-comparator`
  - `godot:validate:salto-ui-shell-comparator`
- Added review-pack generation and boundary validation.

## Evidence Paths

- Runtime artifacts: `artifacts/desktop-spikes/godot-salto/v0208/`
- Manual review pack: `artifacts/manual-review/v0208-ui-shell-comparator/`

## Validation Executed

Executed locally before checkpoint:

```powershell
npm run godot:capture:salto-ui-shell-comparator
npm run godot:validate:salto-ui-shell-comparator
npm run validate:runtime-art-slots
node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0208/cleanup-dry-run
npm run godot:test
npm run validate:content
npm run validate:art-intake
npm run build
git diff --check
npm test
```

## Boundary Notes

This checkpoint intentionally stops before v0.209. No opt-in player-facing launcher exists yet for the new HUD shell.

The final visual pack repaired the initial tooltip/body-text collision before validation.
