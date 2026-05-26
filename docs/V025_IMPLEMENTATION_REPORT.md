# v0.25 Implementation Report

Date: 2026-05-25

## Scope

v0.25 layers conservative enemy resource-site upgrades, abstract enemy logistics, and readable economy-pressure raids on top of v0.24. It does not globally buff the enemy army, add full enemy Workers, add harvesting/cargo/drop-off rules, rewrite pathing, add Patrol/formations, add new content, change saves, or add runtime art/assets.

## Runtime Changes

- Enemy-owned captured sites can be upgraded to Level 2 through the existing `ResourceSystem.requestSiteUpgrade` path.
- Enemy upgrades spend from the enemy battle resource bank and obey the same ownership, cost, and max-level rules as player upgrades.
- Enemy upgrades are delayed and cooldown-gated so multiple captured sites do not all improve instantly.
- Enemy abstract logistics can add one conservative Worker-slot-style bonus to enemy-owned upgraded sites.
- Abstract logistics are explicitly not simulated Worker units: there is no enemy Worker construction, travel, cargo, harvesting, or drop-off loop.
- Enemy raids can periodically target player-owned resource sites, with higher priority for upgraded or actively Worker-boosted sites.
- Active raids use existing enemy units and movement commands, expire after a short window, and can retreat/regroup when the raid squad becomes heavily outmatched.
- Raid cooldowns prevent every-tick retargeting and keep pressure readable.

## UI And Readability

- Enemy upgrade alerts are short and cooldown-paced.
- Selected player sites can show enemy contesting progress when a raid begins capture pressure.
- Selected enemy sites show abstract logistics in Worker-slot copy only when the site is enemy-owned.
- Player-facing messages reuse existing battle status, minimap pings, and selection panel surfaces.

## Tests Added Or Expanded

- Unit coverage for enemy upgrades, invalid enemy upgrade targets, raid cooldown behavior, player upgraded/Worker-boosted raid targeting, weak-raid regrouping, and abstract logistics income.
- Hosted deep-battle proxy coverage proving an enemy captured site can be upgraded and a player upgraded/Worker-boosted site can be raided/contested.
- Existing v0.22/v0.23 Worker assignment, site upgrade, site loss, construction, repair, and Worker intent regressions remain covered by the full unit and hosted suites.

## Worker-Slot Handling

Enemy Worker slots are abstract in this checkpoint. The runtime records `abstractEnemyWorkerSlots` on enemy-owned sites only, clears them on site loss, and includes them in enemy site income. It intentionally does not create, train, path, display, or persist enemy Worker units.

## Verification Notes

Initial focused verification:

```text
npm test PASS, 66 files / 516 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "enemy resource-site AI" --reporter=line PASS, 1 hosted proxy test.
```

Full checkpoint verification is recorded in `LLM_GAME_HANDOFF.md` and `DEVELOPMENT_CHECKPOINT.md` after the final gate.
