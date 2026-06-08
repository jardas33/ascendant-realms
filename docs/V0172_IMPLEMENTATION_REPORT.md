# v0.172 Implementation Report

Status: `PASS_V0172_IMPLEMENTATION_COMPLETE`

Checkpoint: v0.172 safe cleanup execution, documentation-budget enforcement, and environment-phase decision packet.

## Implemented

- Confirmed v0.171 was current HEAD, pushed, clean, synced, and remote-green before editing.
- Ran fresh cleanup inventory, cleanup dry-run, safe-only cleanup, final retention validation, final inventory, and final cleanup dry-run.
- Executed no archive moves because candidates were not proven unreferenced by all current scripts/docs.
- Created before/after manifests, archive manifest, deleted-safe-only manifest, and rollback instructions under ignored v0.172 artifacts.
- Validated default and opt-in Godot launcher paths through the five-slot posture.
- Created documentation-budget policy and environment-phase scorecard/roadmap.
- Updated standard continuation docs and the Salto experimental artifact index.

## Validation

```text
git log -1 --pretty='%H%n%s'
d8eef17ce263a11950359c1a8655798d465d6763
Checkpoint v0.171 Salto five-slot visual-cohesion QA cleanup packet and character-integration freeze stop

git rev-list --left-right --count 'HEAD...@{u}'
0 0

git status --short --untracked-files=all
clean before edits

npm run godot:audit:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/before-inventory
PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN

npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/before-dry-run
PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN

npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/safe-only --apply-safe-only
PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP

npm run godot:validate:player-slice
PASS_WINDOWS_EXPORT and player-slice validation report

npm run godot:validate:salto-worker-art-experiment
PASS_WINDOWS_EXPORT and worker validation report

npm run godot:validate:salto-worker-barracks-art-experiment
PASS_V0162_WORKER_BARRACKS_ART_OPT_IN_AUTOMATION_READY

npm run godot:validate:salto-worker-barracks-militia-art-experiment
PASS_V0164_WORKER_BARRACKS_MILITIA_ART_OPT_IN_AUTOMATION_READY

npm run godot:validate:salto-worker-barracks-militia-aster-art-experiment
PASS_V0168_WORKER_BARRACKS_MILITIA_ASTER_ART_OPT_IN_AUTOMATION_READY

npm run godot:validate:salto-five-slot-art-experiment
PASS_V0170_WORKER_BARRACKS_MILITIA_ASTER_ASHEN_ART_OPT_IN_AUTOMATION_READY

npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/post-launcher-safe-only --apply-safe-only
PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP

npm run godot:validate:salto-experimental-artifact-retention -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/retention-final
PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION

npm run godot:audit:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/after-inventory
PASS_V0165_EXPERIMENTAL_ARTIFACT_HYGIENE_DRY_RUN

npm run godot:cleanup:salto-experimental-artifacts -- --output-root=artifacts/desktop-spikes/godot-salto/v0172/cleanup/after-dry-run
PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN

npm run validate:runtime-art-slots
PASS, 52 runtime art slots

npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts
PASS, 50 tests

git diff --check
PASS
```

## Boundary

- Images generated: `0`.
- Slots added: `0`.
- Runtime visual changes: none.
- Default art enablement: none.
- Default launcher: procedural.
- Browser runtime: untouched.
- Save/stable-ID/gameplay changes: none.
- Archive moves: `0`.
- Broad deletion: none.
- v0.173: not started.
