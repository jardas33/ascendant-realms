# v0.24 Implementation Report

Date: 2026-05-25

## Scope

v0.24 adds controlled enemy awareness of the v0.22/v0.23 resource-site economy. It keeps the existing capture-ring, movement, combat, and passive site-income model. It does not add classic carry/drop-off harvesting, enemy Worker units, enemy construction AI, new maps, factions, units, runtime art, save migration, Patrol, formations, broad pathing changes, or global rebalance.

## Runtime Changes

- Added a pure enemy resource-site strategy scorer for neutral, friendly, and player-owned resource sites.
- Scoring considers resource type, base income, site level, distance from the enemy base, nearby player threat, nearby enemy support, contested progress, active player Worker assignments, abstract enemy logistics, and whether the site was previously enemy-owned.
- Enemy expansion windows can now send small squads to capture valuable neutral resource sites.
- Enemy retake plans prioritize player-owned sites the enemy previously controlled.
- Enemy site defense can focus high-value enemy-owned sites when player units threaten them, while base defense remains first priority.
- Site attacks and defenses avoid plans where nearby player power heavily outmatches the selected squad.
- All site interaction uses existing unit movement, capture rings, and combat commands. No direct ownership mutation is used by normal enemy AI plans.

## UI And Readability

- Enemy site captures now show a short pressure-priority status message in addition to the existing minimap ping.
- Selected resource sites now surface contested state when capture progress is underway.
- Enemy-owned improved sites can show enemy Level 2 and abstract logistics status without adding new art.

## Tests Added Or Expanded

- Unit coverage for site scoring, neutral-site capture plans, retake plans, outmatched avoidance, valuable-site defense, and state transitions.
- Resource-system regression coverage proving site loss still clears level, player Worker assignments, boost state, and abstract enemy logistics.
- Hosted deep-battle proxy coverage proving the enemy can direct a squad to capture a neutral site through the normal AI/resource-system path.

## Verification Notes

Initial focused verification:

```text
npm test PASS, 66 files / 516 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "enemy resource-site AI" --reporter=line PASS, 1 hosted proxy test.
```

Full checkpoint verification is recorded in `LLM_GAME_HANDOFF.md` and `DEVELOPMENT_CHECKPOINT.md` after the final gate.
