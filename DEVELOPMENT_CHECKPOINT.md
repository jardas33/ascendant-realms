# Development Checkpoint

Updated: 2026-05-05 18:36 -04:00

## Final v0.3 Release-Candidate Verification - 2026-05-05 18:36 -04:00

Scope: final automated verification for the v0.3 Cinderfen route release-candidate freeze. No features, gameplay behavior, balance values, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, durability, or broad systems were added. The only changes in this pass are release-candidate documentation updates.

Verification results:

```text
npm test
PASS: 38 test files, 268 tests, 7.40s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.
Output: assets/index-BRMcmX2c.js, 1,917.92 kB minified / 457.57 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 21.9m.
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.
PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json were regenerated with no git diff.

git diff --check
PASS: no whitespace errors.
```

Production preview smoke:

```text
npm run preview -- --host 127.0.0.1 --port 4187
PASS: Browser Use smoke at http://127.0.0.1:4187/
PASS: main menu loaded with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached hero creation and Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the smoke save existed.
PASS: Skirmish Setup opened and listed the current maps.
PASS: browser console errors stayed at 0.
```

The preview server was stopped after the smoke pass. Final freeze decision: v0.3 is ready to freeze as the Cinderfen Route Baseline prototype release candidate, with remaining known risks limited to human readability/feel watch items.

## Checkpoint Scope

This checkpoint records the verified v0.3 Cinderfen route polish-freeze baseline. It preserves the v0.3 baseline docs, readiness/preview reports, route-complete polish, reward-audit/test updates, Chapter 2 e2e helper cleanup, and campaign map presentation helper cleanup without adding gameplay during the checkpoint pass.

Included in this checkpoint:

- `cinderfen_overlook` is a playable Chapter 2 event gate after `ashen_outpost`.
- `cinderfen_waystation` is a compact Chapter 2 town/support node after Cinderfen Overlook.
- `cinderfen_crossing` launches the authored `Cinderfen Causeway` map after the event gate is completed.
- Cinderfen Causeway includes the Cinder Shrine first-capture Aether surge and Shrine Attunement support.
- `cinderfen_watch` launches the compact `Cinderfen Watchpost` map after Cinderfen Crossing victory.
- `cinderfen_aftermath` is a compact non-battle consequence event after Cinderfen Watch.
- The compact Malrec trophy consequence is visible through the existing rival/trophy state.
- Chapter/campaign data is split into focused node and reward modules with compatibility barrels preserved.
- Chapter 2 reward-economy audit changes are preserved: Cinderfen repeat clears pay only tiny XP/resources and no repeat battle item roll while first clears remain useful.
- Chapter 2 Playwright setup cleanup is preserved in `tests/e2e/chapter2-helpers.ts`; smoke specs keep the meaningful reward, copy, persistence, and duplicate-prevention assertions.
- v0.3 baseline/readiness documentation is preserved in `docs/V03_CINDERFEN_ROUTE_BASELINE.md`, `docs/CINDERFEN_ROUTE_READINESS_GATE.md`, and `docs/PRODUCTION_PREVIEW_REPORT.md`.
- Route-complete polish is preserved: completing Cinderfen Aftermath makes the campaign map/return flow clearly communicate that the playable Cinderfen route is secured and the Chapter 2 slice is complete.
- Campaign map presentation cleanup is preserved with focused helpers for chapter cards, node cards, route status, event/town choice summaries, and result copy.
- Chapter 2 event, support, battle, aftermath, reward, persistence, simulator, e2e, telemetry, balance, report, production-preview, and documentation changes from the current route are preserved.
- Chapter 1 remains stable in tests, e2e, and simulator telemetry.

No gameplay behavior was changed during this checkpoint request. The only post-verification edits are this checkpoint record and the corresponding handoff update.

## Verification Results

### Unit Tests

Command:

```bash
npm test
```

Result:

```text
PASS
38 test files passed
268 tests passed
Latest duration: 10.77s
```

### Production Build

Command:

```bash
npm run build
```

Result:

```text
PASS
TypeScript compile passed
Vite production build passed
Latest output: assets/index-CIosN5VC.js, 1,917.97 kB minified / 457.58 kB gzip.
```

Known build warning:

```text
Some chunks are larger than 500 kB after minification.
```

### Browser E2E

Command:

```bash
npm run test:e2e -- --reporter=line
```

Result:

```text
PASS
52 Playwright tests passed
Total duration: 21.4m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Coverage includes Chapter 2 browser flows that resolve Cinderfen Overlook, use Cinderfen Waystation Shrine Attunement, win Cinderfen Crossing, verify Cinder Shrine rewards do not duplicate, win Cinderfen Watch, verify rewards persist once, resolve Cinderfen Aftermath, verify route-complete copy, verify future Chapter 2 nodes remain upcoming/locked, verify Aftermath rewards do not duplicate, and verify the Malrec trophy consequence. The Chapter 2 smoke flows use the extracted helper module.

### Playtest Simulation

Command:

```bash
npm run playtest:sim
```

Result:

```text
PASS
Simulated 255 runs across 85 campaign battle node/profile summaries.
Regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json.
Chapter 1 telemetry remains stable.
Cinderfen Crossing and Cinderfen Watch remain structurally reasonable.
```

### Git Diff Check

Command:

```bash
git diff --check
```

Result:

```text
PASS
No whitespace errors.
```

## Git And Branch Status

Checkpoint commit message:

```text
Checkpoint v0.3 Cinderfen route polish freeze
```

Checkpoint commit hash:

```text
f644bb6dc6b09d529a249321fd70563fa44748e1
```

Branch:

```text
main tracking origin/main
```

Branch sync status:

```text
Before the checkpoint commit, `git status -sb` reported `## main...origin/main` with the expected dirty v0.3 polish-freeze stack.
Before the checkpoint commit, `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
After checkpoint commit `f644bb6dc6b09d529a249321fd70563fa44748e1` and before this metadata update, `git status -sb` reported `## main...origin/main [ahead 1]`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 1`.
After pushing the checkpoint and metadata update, `git status -sb` reported `## main...origin/main`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
```

## Remaining Known Risks

- Human playtesting is still needed for the full Cinderfen route with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army and retinue plus Training Yard II profiles can still clear Cinderfen quickly, so reward pacing should be watched before adding more Chapter 2 payouts even though repeat farming value is now tiny.
- Cinder Shrine and Shrine Attunement are intentionally modest, but human players may overvalue or miss the first-capture Aether surge without a live readability pass.
- Cinderfen Overlook, Waystation, and Aftermath choice/service copy is covered by tests, but mobile UI density should still be spot-checked in the browser.
- The Chapter 2 Playwright helper file should stay a setup/fast-forward helper only; future specs should keep meaningful gameplay assertions in the spec files.
- Campaign map presentation helpers should stay presentation-only; do not move campaign rules, save mutation, or battle launch logic into the view-model helper layer.
- Rival impact is intentionally compact and Malrec-trophy-gated; broader returning-rival arcs remain future work.
- Chapter/campaign content now depends on focused data modules and compatibility barrels staying aligned.
- Vite still reports the known large Phaser bundle warning.
- Full Playwright e2e remains slow at roughly 22 minutes.

## Recommended Next Milestone

Human-verify the v0.3 Cinderfen route freeze candidate end to end: Overlook, Waystation, Crossing, Cinder Shrine surge/attunement, Watch, Aftermath, Results, route-complete campaign-map copy, and return-to-campaign persistence. Add no further Chapter 2 content until the route stays green in human readability and balance review. Avoid workers, enemy construction, new factions, diplomacy, procedural generation, crafting, and broad army-management systems.
