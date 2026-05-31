# v0.91 Implementation Report

Checkpoint: v0.91 Desktop Full-Game Transition Technical Audit and Vertical-Slice Roadmap

## Summary

v0.91 is a docs-only strategic engineering checkpoint. It audits the current browser prototype for desktop-transition reuse, records engine-decision criteria without choosing an engine, scopes a future installable vertical slice, stages transition experiments, and documents save/content/test reuse plus deferred multiplayer requirements.

The browser prototype remains the active development and testing environment. The long-term product target remains a genuine installable desktop RTS/RPG, not a browser game casually wrapped into an executable.

## Baseline

- Starting checkpoint: `v0.90 UX visual-regression harness and desktop-viewport acceptance hardening`.
- Starting commit/package: `c849ffb`, `ascendant-realms-private-playtest-c849ffb`.
- Starting branch state: clean `main`, synced with `origin/main`.
- Baseline remote status: GitHub Actions run `26721555321` on `c849ffb` completed successfully.

## Added Docs

- `docs/V091_CURRENT_ARCHITECTURE_REUSE_MATRIX.md`
- `docs/V091_DESKTOP_ENGINE_DECISION_CRITERIA.md`
- `docs/V091_DESKTOP_VERTICAL_SLICE_SCOPE.md`
- `docs/V091_STAGED_TRANSITION_EXPERIMENTS.md`
- `docs/V091_SAVE_CONTENT_AND_TEST_REUSE_PLAN.md`
- `docs/V091_MULTIPLAYER_AND_COOP_DEFERRED_REQUIREMENTS.md`
- `docs/V091_EMMANUEL_DESKTOP_TRANSITION_REVIEW_PACKET.md`
- `docs/V091_IMPLEMENTATION_REPORT.md`

## Runtime Changed

No runtime code changed.

No gameplay systems, balance values, campaign progression, rewards, save behavior, stable IDs, art assets, desktop wrapper, engine dependencies, packaging scripts, or multiplayer functionality changed.

## Save Format

No save migration. `CURRENT_SAVE_VERSION` remains unchanged. No save fields, localStorage keys, profile behavior, or serialized IDs changed.

## Architecture Audit

The audit classifies every requested subsystem:

- content data,
- hero progression,
- Race + Class architecture,
- campaign data,
- saves,
- combat,
- pathing,
- AI,
- resource sites,
- Lume Network,
- Retinue,
- HUD,
- campaign shell,
- Results,
- visual pipeline,
- audio,
- input,
- resolution handling,
- accessibility,
- tests,
- deterministic simulator,
- packaging,
- multiplayer future scope.

Key finding: data, pure rules, progression models, Retinue logic, campaign graph, save normalization intent, tests, and deterministic simulator output are the strongest reuse candidates. Phaser scenes, DOM-heavy UI, browser input, pathing scale, audio cues, and package output require future refactor or engine-specific rebuild.

## Engine Decision Criteria

The criteria compare:

- remaining Phaser/browser for prototype work,
- a later desktop packaging experiment,
- Godot evaluation,
- Unity evaluation,
- Unreal evaluation,
- another justified option.

No engine winner is selected. A future decision requires pathing, unit-count, asset-pipeline, UI, save, testing, online-roadmap, build-tooling, performance, licensing, learning-curve, AI-assisted workflow, and TypeScript-reuse evidence.

## Desktop Vertical Slice

The future slice is scoped as:

- Salto-inspired region,
- Barrosan Freeholds,
- Ashen Covenant enemies,
- one hero,
- one Worker,
- two military unit types,
- Command Hall,
- Barracks,
- mine,
- shrine,
- one Lume link,
- one mission,
- campaign shell,
- Results screen,
- settings,
- key rebinding,
- resolution options,
- save handling,
- audio placeholder posture,
- performance target,
- packaging target.

This is not implemented by v0.91.

## Verification

Pre-commit verification evidence:

```text
Required v0.91 docs existence check - PASS, all 8 required docs present.
JSON validation - not applicable; v0.91 adds no JSON files.
npm test - PASS, 92 files / 678 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
git diff --check - PASS.
```

Package validation is not required for v0.91 because this checkpoint does not change package metadata, package scripts, runtime files, build output, or private playtest package content requirements.

## Deferred

- Desktop port.
- Desktop wrapper.
- Final engine selection.
- Engine dependencies.
- Runtime art generation/import.
- Save migration.
- Runtime behavior changes.
- Multiplayer/PvP/co-op implementation.
- v0.92.
