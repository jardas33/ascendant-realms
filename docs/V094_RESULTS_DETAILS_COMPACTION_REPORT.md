# v0.94 Results Details Compaction Report

## Scope

Ordinary Results screens now keep the compact summary intact and place expanded battle data into grouped accordions inside `Show Full Battle Details`.

Private-demo Results remain on their existing v0.85 rescue path.

## Groups

- Battle Metrics And Hero XP
- Veterans And Retinue
- Tactical Context
- Objectives And Rivals
- Hero Stat Sheet

## Data Safety

The compaction is render-only.

- Rewards are not recalculated.
- XP is not recalculated.
- Campaign writes are not changed.
- Save fields are not changed.
- Replay safety copy remains driven by existing Results data.
- Private-demo Results still use the private-demo detail path.

## Acceptance

- Compact Results keeps primary actions above the fold.
- Expanded details are easier to scan.
- Player-relevant data is separated from broader telemetry.
- Existing Results reward/equip/save behavior is preserved.

## Verification Status

Passed inside the final v0.94 matrix:

- `npm test` - Results view-model and flow coverage remained green.
- `npm run test:e2e:smoke:fast` and `npm run test:e2e:smoke` - ordinary Results and private-demo Results flows remained green.
- `npm run test:e2e:release:hosted:deep-battle`, `npm run test:e2e:release:hosted:smoke`, and `npm run test:e2e:release:hosted:deep-campaign-pressure` - hosted Results/reward flows remained green.
- `npm run visual:qa` - compact and expanded ordinary Results screenshots passed with the full 84-screenshot set.

Non-pass evidence resolved: after moving ordinary Results data into accordions, one full-smoke path expected optional objective text immediately after expanding full details. The Objectives And Rivals group now opens by default inside the expanded section, preserving the compact summary while keeping existing detail assertions and tester readability intact.
