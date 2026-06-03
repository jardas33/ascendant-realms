# v0.115 Implementation Report

v0.115 creates a trusted performance consolidation gate, Emmanuel clean-restart retest packet, Emmanuel performance decision packet, package-doc updates, and verification tests. It performs no runtime optimization and starts no v0.116 work.

## Added

- [V0115_BROWSER_PERFORMANCE_GATE.md](V0115_BROWSER_PERFORMANCE_GATE.md).
- [V0115_CONSOLIDATED_PERFORMANCE_REPORT.md](V0115_CONSOLIDATED_PERFORMANCE_REPORT.md).
- [V0115_EMMANUEL_CLEAN_RESTART_RETEST.md](V0115_EMMANUEL_CLEAN_RESTART_RETEST.md).
- [V0115_EMMANUEL_PERFORMANCE_DECISION_PACKET.md](V0115_EMMANUEL_PERFORMANCE_DECISION_PACKET.md).
- `src/game/playtest/TrustedPerformanceConsolidationGate.ts`.
- `src/game/playtest/TrustedPerformanceConsolidationGate.test.ts`.

## Changed

- Package build metadata now names v0.115 and includes the v0.115 docs.
- Package validation now requires the v0.115 docs.
- Handoff, roadmap, changelog, development checkpoint, release checklist, and package-facing build notes now reference the v0.115 RED gate.

## Scope Guard

No runtime gameplay, combat, balance, AI, pathing, saves, save-version, save fields, localStorage keys, stable IDs, serialized IDs, art, generated/imported image, runtime asset path, public benchmark control, engine posture, desktop work, multiplayer, PvP, co-op, map, faction, content, or v0.116 work changed.

## Gate Outcome

The gate is RED. v0.115 blocks runtime art integration and broad browser visual expansion. The recommended next decision is a reviewed architecture or earlier engine-spike discussion.

## Verification Results

Pre-commit verification completed on 2026-06-03:

```text
npm test - PASS, 119 files / 820 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS.
npm run perf:host-snapshot - PASS, wrote host snapshot under artifacts/performance/host-snapshots/2026-06-03T22-26-46-316Z/.
npm run perf:controls:preview - PASS, refreshed 6 preview control rows.
npm run perf:trusted:clean-profile - PASS, refreshed 4 clean-profile rows.
npm run perf:trusted:preview - PASS, refreshed mode-preview-headless and baseline rows.
npm run perf:phase-profile - PASS, refreshed 3 v0.110 phase rows.
npm run perf:allocation-audit - PASS, refreshed 8 v0.112 allocation/scheduler rows.
npm run perf:spatial-query-profile - PASS, refreshed 14 v0.113 spatial-query rows.
npm run perf:render-lifecycle-audit - PASS, refreshed 15 v0.114 render-lifecycle rows.
npm run perf:trusted:report - PASS, refreshed 21 trusted benchmark rows.
npm run benchmark:battle:smoke - PASS, 1 scenario.
npm run benchmark:battle:representative - PASS, 8 scenarios.
npm run benchmark:battle:stress - PASS, 1 scenario.
npm run benchmark:battle:report - PASS, refreshed 10 benchmark scenarios.
npm run package:playtest - PASS, produced pre-commit dirty package ascendant-realms-private-playtest-df25995-dirty.
npm run verify:playtest-package - PASS, 459 checks on the pre-commit dirty package.
git diff --check - PASS before final verification-document update.
```

Browser gate smoke: PASS in the in-app Browser at `http://127.0.0.1:5260/`. The app loaded with title `Ascendant Realms`, a visible `1085x912` canvas, main menu text, and only the Phaser banner in Browser dev logs.

The historical performance scripts refreshed ignored artifacts and temporarily changed older generated report files; the older generated tracked report churn was restored so the committed v0.115 diff stays inside the authorized consolidation boundary.

Final clean package generation and package verification are repeated after the v0.115 commit so package metadata can name the final commit and report `workingTreeDirty:false`.
