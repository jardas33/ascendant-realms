# v0.2.1 Readability And Balance Report

Date: 2026-05-03

## Scope

This is an automated readability and balance review for the v0.2.1 prototype baseline before Chapter 2 gameplay implementation.

No gameplay, balance values, maps, factions, workers, enemy construction, diplomacy, procedural generation, or crafting were added for this report. The only code change made for this pass is a small unit-test assertion that Chapter 2 scaffold nodes stay excluded from automated playtest simulator scenarios.

## Evidence Sources

- `LLM_GAME_HANDOFF.md`: v0.2.1 checkpoint state, known risks, Chapter 2 scaffold status, latest verification.
- `QA_RUN.md`: automated QA status and remaining manual-only areas.
- `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`: 180 deterministic runs, retinue profiles, rival telemetry, Stronghold profiles, structural verdicts.
- `BALANCE.md`: current v0.2.1 tuning posture for campaign, veterancy, retinue, enemy heroes, rivals, Stronghold, and Ashen Outpost.
- `RIVAL_RETINUE_READABILITY_REPORT.md`: focused rival/retinue/veterancy readability review.
- Unit/view-model coverage in `src/game/campaign`, `src/game/results`, `src/game/core`, `src/game/data`, and `src/game/playtest`.
- Browser-flow coverage in `tests/e2e/deep-flow.spec.ts`, `tests/e2e/layout.spec.ts`, and `tests/e2e/smoke.spec.ts`.

## Executive Verdict

Automated v0.2.1 read: **Safe to proceed to a small Chapter 2 vertical slice, with human-style readability watchpoints.**

Safe areas:

- No structural `too_easy` or `too_hard` nodes in the current simulator output.
- Ashen Outpost remains beatable without retinue and remains a milestone rather than a hard wall.
- Chapter 2 scaffold is visible as locked/upcoming and cannot launch the missing future map.
- Retinue, rival, trophy, HUD/fog, Ashen objective, and responsive layout surfaces all have automated text or browser coverage.

Watch areas:

- Mixed retinue and mixed retinue plus Training Yard II or Quartermaster II sweep Ashen Outpost in deterministic profiles and remain human-review items.
- Rival/retinue satisfaction, visual salience, and combat stress still need human-style review even though text coverage is good.
- HUD hover/scroll and captured-site fog fixes have permanent regression tests, but the original issues were tactile mouse-feel reports.
- Chapter 2 scaffold copy is covered as text, but its "playable vs upcoming" clarity should still be human-reviewed before adding playable Chapter 2 nodes.

Unsafe areas:

- No deterministic unsafe area is currently proven by automated tests, build, e2e, or simulator telemetry.

## 1. Campaign Clarity

| Question | Automated status | Evidence | Risk |
| --- | --- | --- | --- |
| New Campaign flow | Safe | Smoke/deep Playwright flows create heroes, open campaign map, and verify main menu/current version copy. | Low |
| Chapter 1 / Border Marches status | Safe | Campaign view-model tests keep `border_marches` unlocked with 8 current nodes; progress summary excludes placeholders. | Low |
| Chapter 2 scaffold visibility | Safe | Campaign view-model and smoke e2e assert `Chapter 2: The Cinderfen Road` appears as locked/upcoming. | Low |
| Locked Chapter 2 nodes cannot launch missing maps | Safe | Campaign navigation blocks placeholders; node details show "No battle launch"; battle-launch unit test rejects `cinderfen_causeway`; smoke e2e verifies the Start button remains disabled. | Low |
| Playable vs upcoming clarity | Mostly safe | Placeholder copy names future v0.3 content and "Future battle locked"; report recommends human review for first-glance salience. | Medium-low |

Report read: campaign clarity is sufficient for a scaffold. The player can see Chapter 2 exists without entering a broken map path.

## 2. Retinue Clarity

| Question | Automated status | Evidence | Risk |
| --- | --- | --- | --- |
| Capacity visible | Safe | Retinue panel and Results recruitment assertions cover `0/2`, `1/2`, `2/2`, and Training Yard II `1/3` states. | Low |
| Active units visible | Safe | Campaign Retinue Camp e2e shows active saved unit name, type, rank, XP, kills, and dismiss affordance. | Low |
| Permanent death rule visible | Safe | Retinue Camp and Results text assertions include "Retinue death is permanent in V1". | Low |
| Training Yard II bonus visible | Safe | Retinue Camp shows "Training Yard II" and "+1 capacity active". | Low |
| Deployed retinue identifiable in battle | Safe | Battle status asserts "Retinue deployed"; selected unit panel labels the unit as retinue-deployed with saved rank/XP. | Low |
| Results recruitment readable | Safe | Results e2e covers eligible veteran add button, ineligible recruit reason, full-retinue disabled state, and capacity messaging. | Low |

Report read: retinue readability is automation-covered. Balance still needs human feel review because mixed retinue is strong in Ashen profiles.

## 3. Rival Clarity

| Question | Automated status | Evidence | Risk |
| --- | --- | --- | --- |
| Rival Intel visible | Safe | Campaign map tests and e2e assert known rival state, encounters, outcomes, modifiers, and trophy panel. | Low |
| Commander preview visible on relevant nodes | Safe | Node details assert enemy commander names, titles, abilities, first encounter status, and known-rival status. | Low |
| Results rival outcome readable | Safe | Results view-model and e2e assert defeated, triumphant, humiliated/emboldened, and persistent-state copy. | Low |
| First-defeat reward clearly one-time | Safe | Results and Rival Intel assert "One-time first-defeat reward" and already-claimed duplicate prevention. | Low |
| Trophies visible and not overpromised | Safe | Trophy copy describes save-backed cosmetic records plus small one-time reward notes; no trophy room or upgrade promises. | Low |

Report read: rival clarity is covered by text/view-model/browser flows. Remaining risk is visual weight during live play, especially whether commander warnings are noticeable without becoming noisy.

## 4. HUD/Fog Clarity

| Question | Automated status | Evidence | Risk |
| --- | --- | --- | --- |
| Command buttons stable under hover | Safe | Deep Playwright hover regression tags a Build Barracks button, forces HUD refresh, and verifies the same clickable node remains under the pointer. | Low |
| Side-panel scroll stable | Safe | Deep Playwright sets side-panel scroll, forces HUD refresh, and verifies scroll position is preserved. | Low |
| Captured resource sites visible under fog | Safe | Deep Playwright captures a resource site, moves units away, refreshes fog, and verifies world/minimap visibility does not contradict the new rule. | Low |
| Key controls reachable on desktop/tablet/mobile | Safe | Responsive layout Playwright checks campaign/setup/inventory/gallery and battle HUD/results across desktop, tablet-short, mobile-tall, and mobile-short. | Low |

Report read: the reported HUD/fog regressions are now covered permanently. Human mouse review is still recommended because flicker and scroll snap-back are tactile.

## 5. Ashen Outpost Readability

| Question | Automated status | Evidence | Risk |
| --- | --- | --- | --- |
| Objectives staged clearly | Safe | Ashen objective Results e2e verifies Burned Shrine, Enemy Barracks, and Captain Malrec completed states. | Low |
| Burned Shrine route readable | Mostly safe | Layout e2e verifies Ashen landmarks are scoutable under fog and not hidden under major HUD panels. | Medium-low |
| Captain Malrec objective readable | Safe | Campaign node preview, battle objectives, scout status, Results summary, and objective completion assertions name Captain Malrec. | Low |
| Defeat tips useful | Safe | Deep e2e asserts Ashen defeat tips point to staged objective recovery and prep flow. | Low |

Report read: Ashen Outpost has solid automation around labels, objective state, and landmark visibility. Full-fight route stress and fortress feel remain human-review items.

## 6. Balance Telemetry

Current structural telemetry:

| Metric | Result | Read |
| --- | --- | --- |
| Too easy | none | No node/profile currently crosses structural too-easy thresholds. |
| Too hard | none | No node/profile currently crosses structural too-hard thresholds. |
| Ashen Outpost beatable | yes | Safe Beginner can beat Ashen without retinue, so retinue is helpful but not mandatory by structural telemetry. |
| Stronghold warnings | none | Tier I/Tier II profiles do not produce too-expensive, useless, overpowered, too-easy, or structural too-hard warnings. |
| Retinue strength | useful, watch mixed profiles | Single Veteran profiles help; mixed profiles sweep Ashen and are flagged for human review rather than numeric tuning. |
| Rival commander pressure | relevant, not structurally unfair | Veyra/Gorak/Malrec create identity and late pressure without creating structural too-hard or too-easy outcomes. |
| Rival rewards | meaningful, not duplicated | First-defeat rewards/trophies are one-time; repeat prevention is covered outside the first-encounter simulator path. |
| Chapter 2 scaffold | excluded | Simulator scenarios are still the five playable Chapter 1 battle nodes only. A new unit test now asserts placeholder nodes remain excluded. |

Telemetry details:

- Simulator baseline remains 180 deterministic runs across 60 campaign battle node/profile summaries.
- Profiles include no retinue, one Veteran Militia, one Veteran Ranger, mixed retinue, mixed retinue plus Training Yard II, mixed retinue plus Quartermaster II, and Stronghold paths.
- Enemy hero telemetry covers `enemyHeroId`, defeated state, attack-join timing, and rival pressure/loss fields.
- Rival persistence telemetry covers before/outcome/after state, modifiers applied, first-defeat reward, duplicate prevention, and trophy earned.

Balance recommendation:

- Do not change balance from this automated review.
- If human play later says mixed retinue trivializes Ashen, inspect starting body count and retinue capacity before changing Ashen map structure or enemy hero stats.
- If Chapter 2 implementation changes playable node count, simulator scenario coverage must be extended intentionally rather than accidentally picking up placeholder nodes.

## Coverage Added In This Pass

- Added a unit test in `src/game/playtest/ScriptedBattlePlaytest.test.ts` that explicitly confirms `cinderfen_overlook` and `cinderfen_crossing` are placeholder nodes and are excluded from `DEFAULT_PLAYTEST_SCENARIOS`.

No e2e test was added in this pass because existing Playwright coverage already asserts:

- New Campaign reaches the campaign map.
- Chapter 2 card appears as locked.
- Cinderfen Crossing appears as upcoming.
- The placeholder details explain "Future battle locked", "No battle launch", and `Cinderfen Causeway`.
- The Start button remains disabled.
- Retinue, rival, HUD/fog, Ashen objectives, and responsive command reachability have permanent coverage.

## Remaining Manual Or Human-Style Review

- Judge whether Chapter 2 scaffold copy is obvious enough for a first-time player.
- Play Ashen Outpost with no retinue, one Veteran, mixed retinue, Training Yard II, and Quartermaster II to decide whether mixed-retinue sweeps feel satisfying or trivial.
- Mouse-hover and scroll the HUD in a real session despite automated regression coverage.
- Review rival and trophy visual weight in Campaign Map and Results; automation verifies text, not satisfaction.
- Audio remains human-only.

## Final Recommendation

Proceed to Chapter 2 vertical slice implementation only as a compact, data-driven slice. Keep the current constraints intact: no workers, no enemy construction, no full new faction, no diplomacy, no procedural campaign, no crafting, no broad loot complexity, and no broad army-management layer.

## Verification

Commands run for this report:

```text
npm test
PASS: 36 test files, 218 tests

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only

npm run test:e2e -- --reporter=line
PASS: 49 Playwright tests

npm run playtest:sim
PASS: 180 deterministic simulated runs across 60 campaign battle node/profile summaries
```
