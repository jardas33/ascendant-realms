# v0.117 Implementation Report

## Summary

v0.117 created the first Godot-first automated desktop benchmark spike and one-click Windows workflow. It uses the v0.116 engine-neutral Salto fixture, generates repository-local Godot inputs, validates stable IDs and read-only save fixture posture, runs both 2D and 2.5D placeholder modes, benchmarks them, exports a Windows executable, packages it, and writes the scorecard.

## Added

- `desktop-spikes/godot-salto/` Godot project.
- `tools/godot/` PowerShell workflow scripts.
- Root `GODOT_*_WINDOWS.bat` wrappers.
- `npm run godot:*` scripts.
- Generated fixture data under `desktop-spikes/godot-salto/data/generated/`.
- v0.117 report docs and Emmanuel one-click guide.
- Focused scaffold tests under `src/game/desktop-spike/`.

## Changed

- `.gitignore` now ignores local Godot tools, generated Godot caches, builds, reports, and ignored desktop-spike artifacts.
- The v0.116 desktop-spike fixture boundary now blocks v0.118 docs instead of blocking authorized v0.117 docs.
- Handoff, roadmap, changelog, development checkpoint, and release checklist now describe the v0.117 outcome.

## Verification Highlights

- Godot detected: yes.
- Godot version: `4.6.3.stable.official.7d41c59c4`.
- Export templates detected: yes.
- Fixture validation: PASS.
- Godot headless tests: PASS.
- 2D benchmark: PASS.
- 2.5D benchmark: PASS.
- Windows export: PASS.
- Windows package: PASS.
- Scorecard approval status: `workflow-spike-complete-not-final-engine-choice`.

Full final verification is recorded in the changelog, development checkpoint, and final Codex report.

## Boundary Confirmation

- Browser prototype preserved.
- No full port started.
- No final Godot selection.
- No generated or imported art.
- No save migration.
- No stable ID rename.
- No gameplay, balance, AI, pathing, reward, map, faction, multiplayer, PvP, or co-op change.
- `linked_ward` remains exactly `0.92`.
- v0.118 not started.
