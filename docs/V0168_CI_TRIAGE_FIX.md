# v0.16.8 Hosted Smoke Triage Fix

Date: 2026-05-22

## Failure

Command:

```text
npm run test:e2e:release:hosted:smoke
```

Result before fix:

```text
FAIL: 1 failed, 13 passed.
Failed test: post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards @extended-smoke
```

Failure shape:

- The test launched Cinderfen Crossing successfully.
- The battle HUD objectives were visible.
- The active battle scene existed and continued advancing.
- The transient `battle-status` text had already changed from the launch/map summary to `AI: EXPAND - Time 0:12`.
- The stale assertion expected the brief status-line substring `Cinderfen Crossing`.

## Classification

Hosted timing issue / transient status-line assertion.

This was not a v0.16.7 combat runtime regression. The failure occurred in a Chapter 2 smoke path unrelated to melee contact, enemy building aggro, retreat suppression, or attack hover tolerance.

## Fix

Changed only `tests/e2e/smoke.spec.ts`.

Removed the two transient status-line expectations immediately after `launchCinderfenCrossing(page)`:

- `battle-status` contains `Cinderfen Crossing`
- `battle-status` contains `Normal`

Coverage was preserved because the same test already reads deterministic `BattleScene` state immediately afterward and asserts:

- `mapName: "Cinderfen Crossing"`
- `campaignNodeId: "cinderfen_crossing"`
- `mode: "campaign_node"`
- `rewardTableId: "cinderfen_causeway_rewards"`
- `difficulty: "normal"`
- Cinderfen Crossing objective ids, capture sites, neutral camps, modifiers, resources, and reward persistence

No force clicks were added. No DOM fallback for canvas/world clicks was added. No runtime gameplay code changed.

## Verification

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --reporter=line
PASS: 1 test in 27.7s.

npm run test:e2e:release:hosted:smoke
PASS: 14 tests in 2.9m.
```

## Rerun Requirement

Because this checkpoint includes a test-harness fix and control-lab evidence updates, GitHub Actions should rerun after push. Since v0.16.7 runtime behaviour changed and the manual release matrix has not been dispatched remotely for `169bb21d...`, a user with Actions write access should run the normal enabled workflow-dispatch release matrix after the v0.16.8 push.
