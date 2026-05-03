# Development Checkpoint

Updated: 2026-05-03 19:28 -04:00

## Checkpoint Scope

This checkpoint records the verified Chapter 2 Cinderfen two-battle slice. It preserves the current dirty Chapter 2 work as a checkpoint commit without adding gameplay during the checkpoint pass.

Included in this checkpoint:

- `cinderfen_overlook` is a playable Chapter 2 event gate after `ashen_outpost`.
- `cinderfen_waystation` is a compact Chapter 2 town/support node after Cinderfen Overlook.
- `cinderfen_crossing` launches the authored `Cinderfen Causeway` map after the event gate is completed.
- Cinderfen Causeway includes the Cinder Shrine first-capture Aether surge and Shrine Attunement support.
- `cinderfen_watch` launches the compact `Cinderfen Watchpost` map after Cinderfen Crossing victory.
- The compact Malrec trophy consequence is visible through the existing rival/trophy state.
- Chapter/campaign data is split into focused node and reward modules with compatibility barrels preserved.
- Chapter 2 event, support, battle, reward, persistence, simulator, e2e, telemetry, balance, report, and documentation changes from the current slice are preserved.
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
251 tests passed
Latest duration: 11.94s
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
Latest output: assets/index-DHOLAhSV.js, 1,911.42 kB minified / 455.81 kB gzip.
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
Total duration: 21.5m
Slow files noted by Playwright: tests/e2e/deep-flow.spec.ts and tests/e2e/layout.spec.ts
```

Coverage includes Chapter 2 browser flows that resolve Cinderfen Overlook, use Cinderfen Waystation Shrine Attunement, win Cinderfen Crossing, verify Cinder Shrine rewards do not duplicate, win Cinderfen Watch, verify rewards persist once, and verify the Malrec trophy consequence.

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

## Git And Branch Status

Checkpoint commit message:

```text
Checkpoint Cinderfen two-battle Chapter 2 slice
```

Checkpoint commit hash:

```text
e52636729f05f0b54c2896200aa57ceebc13e6b1
```

Branch:

```text
main tracking origin/main
```

Branch sync status:

```text
Before the checkpoint commit, `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
Checkpoint commit `e52636729f05f0b54c2896200aa57ceebc13e6b1` was pushed successfully to `origin/main` with the checkpoint metadata follow-ups.
Final post-push `git status -sb` reported `## main...origin/main`, and `git rev-list --left-right --count origin/main...HEAD` reported `0 0`.
```

## Remaining Known Risks

- Human playtesting is still needed for Cinderfen Crossing and Cinderfen Watch with no retinue, light retinue, Training Yard II, Quartermaster II, and mixed Chapter 1 upgrade states.
- Fast Army and retinue plus Training Yard II profiles can still clear Cinderfen quickly, so reward pacing should be watched before adding more Chapter 2 payouts.
- Cinder Shrine and Shrine Attunement are intentionally modest, but human players may overvalue or miss the first-capture Aether surge without a live readability pass.
- Cinderfen Overlook and Waystation choice/service copy is covered by tests, but mobile UI density should still be spot-checked in the browser.
- Rival impact is intentionally compact and Malrec-trophy-gated; broader returning-rival arcs remain future work.
- Chapter/campaign content now depends on focused data modules and compatibility barrels staying aligned.
- Vite still reports the known large Phaser bundle warning.
- Full Playwright e2e remains slow at roughly 22 minutes.

## Recommended Next Milestone

Human-verify the current Cinderfen two-battle slice end to end, then add only one compact non-battle Chapter 2 consequence at a time if the slice stays green. Avoid workers, enemy construction, new factions, diplomacy, procedural generation, crafting, and broad army-management systems.
