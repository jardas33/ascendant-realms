# Simulator Determinism Gate

Last updated: 2026-05-08

## Purpose

This v0.5 gate defines how much trust to place in the automated playtest simulator before using it for future balance or expansion decisions.

The simulator is valuable because it is fast, structural, and repeatable. It is not a replacement for human playtesting, visual browser QA, or readability review.

## Determinism Status

The current scripted simulator is deterministic for the default suite.

Evidence:

- `runScriptedPlaytestSuite()` always uses the same default scenarios, scripts, and Stronghold profiles unless callers override them.
- Strategy commands are fixed in `PlaytestStrategies.ts`.
- Battle rewards are passed through `completeBattle()` with `deterministicRewards: true`.
- Reward item selection uses deterministic reward table ordering in simulator paths.
- Affix generation uses deterministic affixes when simulator rewards create item instances.
- Playtest hero fixtures use fixed item instance IDs and fixed affix arrays.
- Enemy AI behavior is modeled from data-driven timing/config values, not random choices.
- New Phase 10 tests compare stable summaries across repeated full simulator runs.

Current default suite shape:

```text
7 campaign battle scenarios
3 player scripts
13 Stronghold/retinue/service profiles
255 generated telemetry runs
85 campaign battle node/profile summaries
```

The 255-run count is lower than a full 7 x 3 x 13 matrix because the `waystation_shrine_attunement` profile only applies to Cinderfen Road scenarios where that service can matter.

## Where Random Choices Happen

Simulator path:

- No random choices are used by the default simulator suite.
- Rewards and affixes are forced through deterministic options.
- Entity IDs are not used as simulator assertions.

Production path:

- Weighted battle rewards can use `Math.random` when deterministic options are not passed.
- Item affix count and weighted affix selection can use `Math.random` in live reward generation.
- Item instance IDs currently include `Date.now()` and `Math.random()`.
- `InputSystem` uses `performance.now()` for attack-move and ability hotkey debounce, but the simulator does not use real pointer/keyboard input.

Implication:

- Simulator telemetry is stable enough for structural balance trend checks.
- Production reward identity and live UI timing are not deterministic replay inputs yet.

## Item And Affix Rewards

Simulator item/affix modeling:

- `BattleRuntime.completeBattle()` rolls rewards with `deterministicRewards: true` when called from `PlaytestRunner`.
- `rollBattleRewards()` uses reward table `deterministicItemIds` or weighted pool order in deterministic mode.
- `grantBattleRewards()` receives `deterministicAffixes: true` from simulator battle completion.
- Playtest hero fixtures in `PlaytestTelemetry.ts` use fixed `sim-*` item instance IDs and no random affixes.

Trust level:

- Good for checking whether a reward exists, whether repeat rewards are tiny, whether duplicate conversion paths are reachable in rules/tests, and whether route-level rewards are broadly useful.
- Not enough to judge loot excitement, item fantasy, perceived farming value, or whether affix variance feels satisfying.

## Campaign Modifiers

Campaign modifiers in simulator:

- Stronghold upgrades are purchased from a simulated campaign bank as profiles progress through nodes.
- Stronghold launch modifiers are converted to battle effects through the same data helpers used by launch rules.
- The Cinderfen Waystation Shrine Attunement profile models `shrine_attunement` only where applicable.
- Cinder Shrine surge is represented through first-capture bonus resource additions on `cinder_crossing`.

Trust level:

- Good for structural checks of modifier application, Cinder Shrine Aether surge size, Stronghold/retinue pressure, and route-wide trend changes.
- Not enough for judging whether modifier copy, UI salience, or player comprehension is strong.

## Telemetry That Can Be Trusted

Use simulator telemetry for:

- Expected run count and scenario/profile coverage.
- Whether Ashen Outpost remains beatable by at least one conservative route.
- Whether nodes become structurally too hard or too easy by current analyzer thresholds.
- Whether first-wave timing is broadly fair.
- Whether Barracks timing is too late before pressure.
- Whether Cinderfen Crossing and Cinderfen Watch remain covered.
- Whether Stronghold, retinue, rival, and Shrine Attunement modeling still produces stable schema fields.
- Whether telemetry report generation remains stable.

## Telemetry That Needs Human Review

Do not use simulator telemetry alone for:

- Route feel, stress, fun, or player fatigue.
- Cinder Shrine salience.
- Waystation and Aftermath panel density.
- Fast Army quick-clear feel.
- Whether Retinue plus Training Yard II feels too strong in a human-paced route.
- Readability, mobile density, contrast, audio, animation, or input clarity.
- Whether rewards feel exciting or too farmable.
- Whether UI copy makes tactical priorities obvious.

## Drift Detection

Phase 10 added tests that:

- Keep the default matrix explicit: 7 scenarios, 3 scripts, 13 profiles.
- Keep the generated report identity and schema version explicit.
- Assert expected no structural `too_easy`, no structural `too_hard`, and no Stronghold warnings for the current default suite.
- Assert telemetry records have defined node IDs, map IDs, AI personalities, player scripts, profile IDs, command logs, structural notes, and reward numeric fields.
- Run the full simulator twice and compare a stable deterministic summary.

Future telemetry drift should be treated as meaningful until proven otherwise. If drift is intentional, update the tests, `PLAYTEST_TELEMETRY.md`, `PLAYTEST_TELEMETRY.json`, and the handoff in the same checkpoint.

## Current Watch Items

- Fast Army quick-clear feel remains a human-review item even though the analyzer does not mark structural `too_easy`.
- Retinue plus Training Yard II remains a human-review item because capacity and veteran bonuses can compress the route.
- Cinder Shrine salience remains a readability item, not a determinism item.
- The Playwright release lane is still slower than the simulator and remains necessary because the simulator cannot inspect real UI.

## Future Recommendations

- Keep simulator tests focused on schema, coverage, and deterministic summaries rather than exact prose snapshots.
- Add a targeted telemetry drift fixture only after the command-log V1 plan becomes active.
- Add seeded RNG only when a future system introduces actual random simulator choices.
- Do not tune gameplay solely to satisfy simulator verdicts.
- Do not remove human-review verdicts just because a node is structurally passable.
