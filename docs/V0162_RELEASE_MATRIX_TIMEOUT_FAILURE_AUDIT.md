# v0.16.2 Release Matrix Timeout Failure Audit

Date: 2026-05-20

Scope: diagnose GitHub Actions CI Release Matrix Dry Run #66 after v0.16.1, where Fast confidence was green but release-matrix `deep-battle` and `smoke` were red. This audit is limited to release-matrix smoke/deep-battle timeout triage and does not start v0.17.

## Baseline

- Local branch before edits: `main`, clean and synced with `origin/main`.
- Local HEAD: `3bfe3b20a09cbc67de80954384d3ddad7a61a270`, `Checkpoint v0.16.1 fast-confidence CI smoke stabilization`.
- GitHub UI screenshot from Emmanuel showed commit text as `3fbe3b2`, but local checkout and fetched job logs both identify `3bfe3b20a09cbc67de80954384d3ddad7a61a270`. Treat `3fbe3b2` as a transposed short hash in the UI note.
- `gh` CLI was unavailable locally.
- GitHub connector logs were available for Actions run id `26154299133`, displayed as CI Release Matrix Dry Run #66.

## Remote Evidence

Run #66 status by job:

- `Fast confidence`: green.
- `Release simulator`: green.
- `Release matrix (deep-meta)`: green.
- `Release matrix (deep-campaign-pressure)`: green.
- `Release matrix (layout-core)`: green.
- `Release matrix (layout-cinderfen)`: green.
- `Release matrix (deep-battle)`: red.
- `Release matrix (smoke)`: red.
- `Full release e2e`: not completed in the provided evidence.

Artifacts were not downloadable. The run attempted to upload Playwright artifacts, but GitHub reported that artifact storage quota had been hit, so traces, videos, and error contexts were unavailable even though Playwright printed local artifact paths.

## Deep-Battle Failure

Failed job: `Release matrix (deep-battle)`.

Failed test:

```text
tests/e2e/deep-flow.spec.ts:1706:3
Ascendant Realms deep end-to-end QA › battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle
```

Remote log evidence:

```text
Test timeout of 120000ms exceeded.
Error: deep-flow behaviour mode Guard Area: DOM click fallback failed: locator.evaluateAll: Target page, context or browser has been closed
Stack: tests/e2e/shared-helpers.ts:309 -> clickReady -> tests/e2e/deep-flow.spec.ts:1777
```

Before timeout, the log showed `Hold Ground`, `Press Attack`, and `Guard Area` behaviour-mode button interactions inside the older HUD/minimap/building test. The same job also contains the later dedicated behaviour mode gauntlet, and the log reached that test after the failing HUD test slot in the 12-test group. The job result was 1 failed and 11 passed.

Local reproduction before the fix:

```text
npx playwright test tests/e2e/deep-flow.spec.ts --config=playwright.hosted-release.config.ts --grep "battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions" --retries=1 --trace=on --reporter=line
PASS, 1 test in 1.8m.
```

The local pass still logged behaviour-mode actionability churn before the rest of the HUD/minimap/building path. The full hosted deep-battle lane also passed locally but showed the same precursor:

```text
npm run test:e2e:release:hosted:deep-battle
PASS, 12 tests in 4.5m before the fix.
```

Conclusion: this was not a deterministic runtime regression locally. The failing test had become overloaded for hosted CI by carrying duplicated v0.16 behaviour-mode transitions before continuing through minimap movement, fog toggle, building placement cancel, and command hall actions.

## Smoke Failure

Failed job: `Release matrix (smoke)`.

Failed test:

```text
tests/e2e/smoke.spec.ts:901:3
Ascendant Realms browser smoke flows › settings accessibility options apply in battle @ci-fast
```

Remote log evidence:

```text
Test timeout of 60000ms exceeded.
Error: settings smoke battle resume: DOM click fallback failed: locator.evaluateAll: Target page, context or browser has been closed
Stack: tests/e2e/shared-helpers.ts:309 -> clickReady -> tests/e2e/smoke.spec.ts:981
```

Before timeout, the remote log showed the settings runtime test had launched battle, clicked the battle menu through fallback, asserted paused state, then spent the remaining test budget around the `battle-resume` click.

Local reproduction before the fix:

```text
npx playwright test tests/e2e/smoke.spec.ts --config=playwright.hosted-release.config.ts --grep "settings accessibility options apply in battle" --retries=1 --trace=on --reporter=line
PASS, 1 test in 39.1s.

npm run test:e2e:release:hosted:smoke
PASS, 14 tests in 2.7m before the fix.
```

Conclusion: the runtime accessibility assertions were valid and passed locally, but the hosted release smoke budget was too tight for the production-preview settings runtime path on GitHub after v0.16.1 split the test. This matches the earlier v0.14.2 settings-smoke pattern: preserve assertions, scope the extra budget to the settings accessibility smoke path, and do not raise global Playwright or matrix timeouts.

## Required Questions

### Why did Fast confidence pass while release smoke failed?

Fast confidence runs `npm run test:e2e:smoke:fast`, which uses the default Playwright config and only the eight `@ci-fast` smoke tests. The red release smoke job runs `npm run test:e2e:release:hosted:smoke`, which uses `playwright.hosted-release.config.ts`, production preview, retained failure artifacts, and the full 14-test smoke file. The same settings runtime test is covered in both, but hosted production preview has less timing margin.

### Why did the dedicated behaviour mode gauntlet apparently pass while the older minimap/HUD test failed?

The older HUD test was doing both jobs: first it switched Hold Ground, Press Attack, and Guard Area, then it continued into minimap movement, fog toggle, building placement cancel, and command hall actions. The dedicated behaviour gauntlet later in the same hosted deep-battle lane owns behaviour-mode switching and behaviour assertions in a fresh test path. The remote timeout happened while the older HUD test was doing duplicated behaviour-mode transitions before reaching the rest of its original surface.

### Is `Target page/context/browser closed` the cause?

No. The logs show Playwright's per-test timeout fired first, then the still-running DOM fallback reported that the target page, context, or browser had been closed. That closure is the consequence of Playwright terminating an over-budget test, not evidence of an independent browser crash.

### What is the smallest safe fix?

- Keep the older deep-battle HUD test focused on its original surface: default behaviour-mode affordance, minimap movement, fog toggle, building placement cancel, and command hall actions.
- Remove the duplicated Hold/Press/Guard switching sequence from that older HUD test, while keeping the dedicated behaviour mode control gauntlet and unit coverage intact.
- Keep the settings runtime smoke test and all accessibility assertions, but give only that test a scoped 90-second budget and make `clickReady` aware of semantic pause/resume success so it can stop once the real follow-up state appears.

### Which assertions remain protected?

- Settings persistence and localStorage assertions remain in `settings screen persists accessibility options @ci-fast`.
- Runtime settings assertions remain in `settings accessibility options apply in battle @ci-fast`: reduced motion dataset, colorblind minimap dataset, colorblind minimap snapshot, minimap marker colors, floating text disabled, fog override disabled, fog inactive, battle pause, and battle resume.
- Minimap movement, fog toggle, building placement cancel, command hall actions, attack hover/click intent, and default behaviour-mode affordances remain in the older deep-battle HUD test.
- Behaviour-mode switching and behaviour outcomes remain protected by `behaviour mode control gauntlet preserves attack, retreat, marquee, and minimap intent @hosted-deep-battle`, unit tests, and controls playtest verification.

## Not Changed

- No runtime gameplay code.
- No gameplay numbers.
- No save format.
- No runtime art/assets.
- No maps, factions, units, Patrol runtime, formations, or broad AI/pathing.
- No workflow/release-matrix restructuring.
- No broad retries.
- No force clicks.
- No DOM fallback for canvas/world clicks.
- No package materials.
- No invented human feedback.
