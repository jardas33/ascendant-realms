# Cinderfen Route Readiness Gate

Date: 2026-05-04

Scope: automated readiness gate for the v0.3 Cinderfen route baseline candidate. This gate uses unit tests, view-model/text assertions, Playwright e2e flows, deterministic simulator telemetry, and existing reports. It intentionally does not require manual playtesting.

No gameplay, balance, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, or crafting were added for this gate. The only coverage change made for this gate is a pure-rule reward assertion that Cinderfen Watch repeat clears follow the same tiny/no-item policy already covered for Cinderfen Crossing.

## Gate Verdict

**Pass: safe to freeze under the automated route-readiness gate.**

The Cinderfen route is safe to freeze for automated readiness and controlled polish. There are no blocked areas and no automated risky findings. The remaining concerns are watch items: Fast Army clear efficiency, Greedy Economy timeouts, Retinue plus Training Yard II strength, Cinder Shrine readability, and event/town choice density. Those watch items do not require balance changes from the current automated evidence.

This verdict is not a human feel signoff. It is the requested automated gate only.

## Classification Rules

- `safe`: automated evidence directly covers the behavior and no current failures or structural telemetry warnings are present.
- `watch`: automated evidence is passing, but telemetry spread, visual readability, density, or strategy skew should stay visible during polish.
- `risky`: automation is passing only indirectly, coverage is thin for a critical behavior, or telemetry suggests likely economy/balance trouble.
- `blocked`: required coverage or verification is failing, or a critical route behavior is missing.

## 1. Route Progression

Classification: **safe**

| Requirement | Status | Evidence |
| --- | --- | --- |
| Ashen Outpost unlocks Cinderfen Overlook | Safe | `CampaignRules.test.ts` gates Chapter 2 behind Ashen Outpost; `CampaignMapViewModel.test.ts` shows Chapter 2 unlocked after Ashen; `smoke.spec.ts` confirms post-Ashen campaign state. |
| Overlook unlocks Waystation and Crossing | Safe | `CampaignRules.test.ts` applies Overlook choices and asserts `cinderfen_waystation` plus `cinderfen_crossing`; `smoke.spec.ts` verifies the same in browser flow. |
| Crossing unlocks Watch | Safe | `CampaignRules.test.ts` completes Crossing and asserts Watch availability; `smoke.spec.ts` verifies the campaign return state. |
| Watch unlocks Aftermath | Safe | `CampaignRules.test.ts` completes Watch and asserts Aftermath availability; `smoke.spec.ts` verifies Aftermath availability after Watch results. |
| Completed nodes do not duplicate rewards | Safe | Generic node reward duplicate prevention exists in `CampaignRules.test.ts`; Cinderfen event/town duplicates are covered in pure rules and e2e; completed Cinderfen battles cannot be restarted from the campaign UI in e2e. |
| Chapter 1 remains stable | Safe | Telemetry reports Ashen Outpost beatable, no `too_easy`, no `too_hard`, and no Stronghold warnings. The v0.3 reward audit touched no Chapter 1 reward values. |

Gate read: route topology is covered by pure rules, content validation, view-model rendering, and browser flows. No missing critical coverage found.

## 2. Event Clarity

Classification: **safe**

| Area | Status | Evidence |
| --- | --- | --- |
| Overlook choices show costs/rewards/reputation/modifiers | Safe | `CampaignMapViewModel.test.ts` renders Overlook choice text; `smoke.spec.ts` asserts costs, rewards, disabled Malrec trophy condition, completion copy, and saved result for `Aid the Marsh Refugees`. |
| Waystation services show costs/effects/repeat behavior | Safe | `CampaignMapViewModel.test.ts` renders service effect copy and repeatable/one-time labels; `CampaignRules.test.ts` covers resource spending, insufficient resources, repeatable Shrine Attunement, one-time Refugee Scouts, and modifier consumption; `smoke.spec.ts` asserts service copy and Shrine Attunement spending. |
| Aftermath choices show costs/rewards/reputation/completion behavior | Safe | `CampaignMapViewModel.test.ts` renders Aftermath costs/rewards/reputation/completion; `CampaignRules.test.ts` covers Secure Watch Road, Study Ashen Marks, insufficient resources, Malrec trophy gating, and duplicate prevention; `smoke.spec.ts` resolves Aid the Fenfolk and verifies saved cost/reward/reputation. |

Gate read: text coverage is strong and uses stable view-model/DOM assertions rather than brittle screenshots. Mobile density remains a polish watch, not a blocker for the automated gate.

## 3. Battle Clarity

Classification: **watch**

| Requirement | Status | Evidence |
| --- | --- | --- |
| Crossing map/objectives/minimap/resources load correctly | Safe | `smoke.spec.ts` launches Cinderfen Causeway, checks battle HUD, resources, minimap, map name, and objective text. `contentValidation.test.ts` validates map metadata, capture sites, neutral camps, objectives, and reward table wiring. |
| Cinder Shrine objective and Aether surge are visible | Safe | `contentValidation.test.ts` validates Cinder Shrine metadata and +20 Aether first-capture bonus; `ResourceSystem.test.ts` validates first-capture behavior; `smoke.spec.ts` asserts objective/status copy. |
| Shrine Attunement modifies first capture correctly | Safe | `CampaignRules.test.ts`, `campaignModifiers.test.ts`, `ScriptedBattlePlaytest.test.ts`, and `smoke.spec.ts` cover Shrine Attunement setup and +25 Aether first capture. |
| Watch map/objectives/minimap/resources load correctly | Safe | `smoke.spec.ts` launches Cinderfen Watchpost, checks battle HUD/resources/minimap/map name/objectives, and `contentValidation.test.ts` validates Watchpost map/objective/reward metadata. |
| Results screen shows correct rewards and objective summary | Safe | `smoke.spec.ts` asserts Crossing and Watch Results reward text, campaign reward blocks, objective summaries, save persistence, and return-to-campaign state. |

Gate read: battle correctness is automated. Classification remains `watch` because the request forbids manual playtesting and the current gate avoids brittle visual assertions; Cinder Shrine salience and Watchpost fog/tower readability remain UX watch items.

## 4. Reward Integrity

Classification: **safe**

| Requirement | Status | Evidence |
| --- | --- | --- |
| First clears grant intended rewards | Safe | `CampaignRules.test.ts`, `HeroProgressionRules.test.ts`, `contentValidation.test.ts`, and `smoke.spec.ts` cover Crossing and Watch first-clear battle/node rewards. |
| Repeat clears grant tiny rewards only | Safe | `HeroProgressionRules.test.ts` now covers both Cinderfen Causeway and Cinderfen Watchpost repeat rewards: Crossing 4 XP / 11 resources, Watch 3 XP / 8 resources. |
| Repeat clears grant no weighted item roll | Safe | `HeroProgressionRules.test.ts` asserts no repeat item for both Cinderfen reward tables. |
| Event rewards do not duplicate | Safe | `CampaignRules.test.ts`, `SaveSystem.test.ts`, and `smoke.spec.ts` cover Overlook, Waystation one-time service, Aftermath, and Malrec trophy duplicate prevention. |
| Waystation services spend resources correctly | Safe | `CampaignRules.test.ts` covers Marsh Guides, Ash Filters insufficient-resource lock, Refugee Scouts one-time spending, and repeated Shrine Attunement spending; `smoke.spec.ts` verifies Shrine Attunement spending in browser flow. |

Gate read: reward integrity is safe. No balance changes are indicated by automation.

## 5. Balance And Telemetry

Classification: **watch**

Latest deterministic telemetry: 255 runs across 85 campaign battle node/profile summaries.

| Area | Automated Read | Classification | Gate Note |
| --- | --- | --- | --- |
| Crossing win/loss/timeout | 39 runs, 26 wins, 0 defeats, 13 timeouts | Safe | No structural too-easy/too-hard flag. Safe Beginner wins 13/13. |
| Watch win/loss/timeout | 36 runs, 25 wins, 0 defeats, 11 timeouts | Safe | No structural too-easy/too-hard flag. Safe Beginner wins 12/12. |
| Fast Army farming risk | Crossing 12/13 wins, Watch 10/12 wins; poor first-wave survival on fast rushes | Watch | Repeat rewards are tiny and no repeat item roll exists, so this is controlled but should stay visible. |
| Greedy Economy timeout rate | Crossing 1/13 wins with 12 timeouts; Watch 3/12 wins with 9 timeouts | Watch | Scripts survive first wave, so this reads as routing/final-assault pace rather than opening unfairness. |
| Retinue + Training Yard II strength | 6/6 victories across Cinderfen pair | Watch | Strongest profile, but no `too_easy` flag and not a reason to add systems or tune blindly. |
| Cinder Shrine usage | 26/39 Crossing runs captured shrine; 2 attuned +25 surges | Safe | Shrine is visible in simulator and e2e, but its visual salience remains a UX watch. |
| Waystation service impact | Shrine Attunement profile 2 wins / 0 defeats / 1 timeout; other services covered by rule/e2e launch effects | Safe | Service impact is modest and not a payout multiplier. |
| Chapter 1 regression stability | No `too_easy`, no `too_hard`, no Stronghold warnings; Ashen Outpost beatable | Safe | Chapter 1 reward values remain unchanged by the Cinderfen audit/gate. |

Gate read: balance is automated-safe with watch items. No telemetry result justifies balance changes right now.

## 6. UX Risk Classification

| Area | Classification | Reason |
| --- | --- | --- |
| Route progression | Safe | Covered by rules, view-model, content validation, and e2e. |
| Event clarity | Safe | Text/cost/reward/reputation/modifier behavior is covered with stable assertions. |
| Battle clarity | Watch | Correctness is covered; visual salience and fog/tower readability are not manually judged in this gate. |
| Reward integrity | Safe | First/repeat rewards, duplicate guards, and Waystation spending are covered. |
| Balance/telemetry | Watch | No blockers, but Fast Army, Greedy timeouts, and Retinue + Training Yard II remain watch items. |
| Chapter 1 stability | Safe | Telemetry and docs show no Chapter 1 reward or route changes. |
| E2E maintainability | Watch | Chapter 2 helpers are clean, but full e2e remains slow and should not absorb assertions into helpers. |

No area is currently `risky` or `blocked`.

## Missing Critical Coverage

Critical gap found and closed:

- Added Watchpost repeat-reward coverage to `HeroProgressionRules.test.ts` so both current Cinderfen battle reward tables assert first-clear useful rewards and repeat tiny/no-item rewards.

No additional critical coverage gaps were found. The remaining gaps are intentionally UX/feel oriented and outside this automated-only gate.

## Required Verification

Commands for this gate:

```text
npm test
PASS: 37 test files, 259 tests, 7.11s.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only. Latest output: assets/index-MCPD5UO4.js, 1,914.22 kB minified / 456.45 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests in 20.5m.

npm run playtest:sim
PASS: regenerated PLAYTEST_TELEMETRY.md and PLAYTEST_TELEMETRY.json; 255 deterministic runs across 85 campaign battle node/profile summaries.
```

## Freeze Decision

The Cinderfen route is **safe to freeze under automated readiness**. The required verification commands passed, no blockers were found, and the only code change was a coverage-only pure-rule test for Cinderfen Watch repeat rewards.

Freeze conditions:

- Do not add Chapter 2 content during the freeze.
- Do not add broad systems during the freeze.
- Use future work for verification, readability, UX, copy clarity, and controlled polish only.
- Tune values only if a clear bug or fresh telemetry regression appears.
