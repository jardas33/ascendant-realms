# v0.222 Implementation Report

Date: 2026-06-11

## Summary

v0.222 adds a reversible minimal contextual HUD layer to the isolated Godot Salto presentation-reboot review path.

## Code Changes

- Added `--salto-minimal-contextual-hud` and `--salto-minimal-contextual-hud-disabled`.
- Added v0.222 capture, validation and benchmark npm scripts.
- Added Windows wrappers for capture, validation and benchmark.
- Added `tools/godot/saltoMinimalContextualHudTool.mjs` for review-pack generation, occupancy validation, boundary checks and benchmark reporting.
- Added v0.222 HUD rendering inside `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`.
- Updated v0.215 boundary tooling so older presentation-reboot validation recognizes the new v0.222 helper files without permitting browser/default/art leakage.

## Isolation

The minimal contextual HUD is opt-in only. It does not change the default stabilized launcher and does not alter prior launchers.

## Validation Plan

Closeout commands:

```text
PASS: npm run godot:capture:salto-minimal-contextual-hud
PASS: npm run godot:validate:salto-minimal-contextual-hud
PASS: npm run godot:benchmark:salto-minimal-contextual-hud
PASS: npm run godot:validate:salto-composition-lighting-selection
PASS: npm run godot:validate:salto-presentation-reboot
PASS: node scripts/validateSaltoExperimentalArtifactRetention.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0222/artifact-retention-final
PASS: node scripts/cleanupSaltoExperimentalArtifacts.mjs --output-root=artifacts/desktop-spikes/godot-salto/v0222/final-cleanup-dry-run --dry-run
PASS: npm run validate:runtime-art-slots
PASS: npm run validate:content
PASS: npm run validate:art-intake
PASS: npm test
PASS: npm run godot:test
PASS: npm run build
PASS: git diff --check
```

## Continuation Boundary

If v0.222 passes, is committed, pushed, CI-green, clean and synced, the next queued milestone is v0.223 HUD visual language, icons and interaction QA.
