# Development Checkpoint

Updated: 2026-05-03 14:31 -04:00

## Checkpoint Scope

This checkpoint records the verified Chapter 2 Cinderfen event battle and balance slice. It preserves the current dirty work as a pushed checkpoint commit without adding new gameplay during the checkpoint pass.

Included in this checkpoint:

- `cinderfen_overlook` is a playable Chapter 2 event gate after `ashen_outpost`.
- `cinderfen_crossing` launches the authored `Cinderfen Causeway` map after the event gate is completed.
- Cinderfen Causeway includes the Cinder Shrine first-capture Aether surge.
- The compact Malrec trophy consequence is visible through the existing rival/trophy state.
- Chapter 2 event, battle, reward, persistence, simulator, e2e, telemetry, balance, and documentation changes from the current slice are preserved.
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
37 test files passed
233 tests passed
Latest duration: 12.56s
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
Latest output: assets/index-BuswvSTS.js, 1,899.96 kB minified / 453.40 kB gzip.
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
51 Playwright tests passed
Total duration: 21.8m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Coverage includes the Chapter 2 browser flow that resolves Cinderfen Overlook, wins Cinderfen Crossing, verifies rewards persist once, and verifies the Malrec trophy consequence.

### Playtest Simulation

Command:

```bash
npm run playtest:sim
```

Result:

```text
PASS
Simulated 216 runs across 72 campaign battle nodes.
Regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json.
Chapter 1 telemetry remains stable.
Cinderfen Crossing remains structurally reasonable.
```

## Git And Branch Status

Checkpoint commit message:

```text
Checkpoint Chapter 2 Cinderfen event battle and balance slice
```

Checkpoint commit hash:

```text
6543f212431e18a5cbe916f9984797313513fe57
```

Branch:

```text
main tracking origin/main
```

Branch sync status:

```text
Before the checkpoint commit, `git fetch origin main` completed and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
Checkpoint commit `6543f212431e18a5cbe916f9984797313513fe57` was pushed successfully to `origin/main`.
The checkpoint metadata follow-up was pushed successfully. Final `git status -sb` reported `## main...origin/main`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
```

## Remaining Known Risks

- Human playtesting is still needed for Cinderfen Crossing with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army profiles can still clear Cinderfen quickly, so reward pacing should be watched before adding more Chapter 2 payouts.
- The Cinder Shrine is intentionally modest, but human players may overvalue or miss the first-capture Aether surge without a live readability pass.
- Event choice copy is covered by tests, but mobile UI density should still be spot-checked in the browser.
- Rival impact is intentionally compact and trophy-gated; broader returning-rival arcs remain future work.
- Vite still reports the known large Phaser bundle warning.
- Full Playwright e2e remains slow at roughly 22 minutes.

## Recommended Next Milestone

Human-play the Cinderfen vertical slice, then add only one compact Chapter 2 follow-up at a time. Good candidates are a small rival-return consequence, a small Cinderfen-specific tactical refinement, or a second lightweight event node. Avoid workers, enemy construction, new factions, diplomacy, procedural generation, crafting, and broad army-management systems.
