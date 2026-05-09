# v0.8 Direction Decision Brief

Date: 2026-05-09

Status: Phase 8 planning brief. This document compares four possible v0.8 directions. It does not implement gameplay, rewards, saves, maps, units, factions, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive holds, desktop packaging, engine switching, or external assets.

## 1. Current Evidence

v0.7.3 reviewed Enemy Strategic Pressure V1 through controlled browser input and simulator evidence:

- Cinderfen Crossing: shrine reward feedback and delayed pressure warning are readable in controlled evidence.
- Cinderfen Watch: Watch Road capture, immediate warning, delayed warning, and pressure priority are readable in controlled evidence.
- Strategy profiles: Safe Beginner remains stable, Greedy Economy timeouts remain a closure/readability watchpoint, Fast Army remains acceptable strategy expression, and Retinue + Training Yard II remains a saved-progress power watchpoint.
- Manual play is still missing: Emmanuel has a checklist, but no direct human notes have been returned yet.

## 2. Option A - Simulator-Only Reinforcement Experiment

Scope:

- Test one existing-unit reinforcement concept in the simulator only.
- No live runtime change.
- No new units, maps, factions, workers, construction, economy AI, rewards, saves, or campaign progression changes.

Value:

- Highest relevance to the Enemy Strategic Pressure system.
- Could answer whether `reinforce_next_wave` has enough value to remain on the future roadmap.
- Lets pressure become more measurable without risking live player-facing unfairness.

Risk:

- May tempt live combat behavior before human warning salience is proven.
- Could mask the actual open question, which is whether current warnings are noticed by hand.
- Requires careful documentation so "simulator-only" does not become accidental production behavior.

Required tests:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run playtest:sim`
- targeted simulator schema/analysis tests
- no required smoke expansion unless report surfaces change in UI

Files likely touched:

- `src/game/playtest/*`
- `src/game/data/enemyPressurePlans.ts` only if simulator-only metadata is needed
- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- `docs/V07_ENEMY_STRATEGIC_PRESSURE_SPEC.md`
- `BALANCE.md`
- `LLM_GAME_HANDOFF.md`

Why now:

- v0.7 through v0.7.3 built and reviewed the pressure foundation.
- Simulator-only work can be safe if the scope is narrow.

Why not now:

- v0.7.3 still lacks direct human manual feedback.
- Current pressure warnings may be enough; stronger mechanics should not be designed around simulator curiosity alone.

Recommended first safe implementation:

- Create a simulator-only profile that marks one tiny existing-unit reinforcement concept for one pressure plan.
- Keep `pressureReinforcementApplied` false in live runtime.
- Report outcomes separately from baseline pressure runs.
- Stop if Cinderfen becomes structurally too hard or if the experiment demands live reinforcement.

## 3. Option B - Chapter 2 Content Continuation

Scope:

- Add one small Chapter 2 event or aftermath extension.
- No new map unless later approved.
- No new units, factions, workers, construction, economy AI, broad loot, rewards expansion, or save-version bump.

Value:

- Gives visible campaign value.
- Moves the Cinderfen route toward a richer chapter experience.
- Could use existing systems and existing content safely if kept small.

Risk:

- Content before pressure/play feel settles may add more review surface.
- New event choices can create reward, reputation, or save edge cases.
- Even small content increases e2e and documentation maintenance.

Required tests:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- campaign rule/view-model tests
- targeted e2e only if a new flow is user-visible

Files likely touched:

- `src/game/data/cinderfenRoadNodes.ts`
- `src/game/core/CampaignRules.ts`
- `src/game/campaign/*`
- `CONTENT_GUIDE.md`
- `ROADMAP.md`
- `CHANGELOG.md`
- `LLM_GAME_HANDOFF.md`

Why now:

- Chapter 2 already has Crossing, Watch, Waystation, and Aftermath foundations.
- A compact event can make the campaign feel less like a prototype loop.

Why not now:

- The pressure system just reached a human-review gate.
- More content may distract from confirming core feel.

Recommended first safe implementation:

- Documentation-only event sketch first, then one small existing-resource event later if approved.
- Avoid new rewards until the reward economy is explicitly reviewed.

## 4. Option C - Technical Performance / E2E Runtime Pass

Scope:

- Investigate the known Phaser vendor chunk warning and slow release lanes.
- Improve test runtime, sharding clarity, or build reporting where safe.
- No gameplay, content, balance, reward, save, map, unit, faction, worker, construction, or economy change.

Value:

- Safest engineering path.
- Reduces friction for future long-running goals.
- Addresses known release risks without depending on missing human play feedback.

Risk:

- Less visible player value.
- Bundle work can become broad if it turns into architectural refactoring.
- E2E cleanup can accidentally weaken coverage if not handled carefully.

Required tests:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- `npm run test:e2e:release`
- `npm run test:e2e:release:shard1`
- `npm run test:e2e:release:shard2`
- `npm run playtest:sim`

Files likely touched:

- `vite.config.ts`
- `playwright.config.ts`
- `package.json`
- `tests/e2e/*`
- `docs/E2E_RUNTIME_AUDIT.md`
- `docs/E2E_CI_SHARDING_PLAN.md`
- `docs/PERFORMANCE_BUNDLE_AUDIT.md`
- `RELEASE_CHECKLIST.md`
- `LLM_GAME_HANDOFF.md`

Why now:

- v0.7.3 is mostly documentation and evidence; the next safe autonomous pass can improve the runway.
- Release lanes are green but slow, and the Phaser vendor warning is known.

Why not now:

- It does not directly make Cinderfen more fun.
- Some bundle fixes may not be worth the risk until the game surface is larger.

Recommended first safe implementation:

- Measure before changing.
- Document current shard/runtime timings.
- If touching build config, keep behavior identical and verify with full release plus preview smoke.
- Do not remove meaningful e2e coverage to make timings look better.

## 5. Option D - Tutorial v2 Onboarding Refinement

Scope:

- Improve first-time player step pacing and clarity.
- Keep Tutorial / Proving Grounds no-reward, non-persistent, and existing-content-only.
- No campaign rewards, save changes, new maps, units, factions, workers, construction, or broad systems.

Value:

- Strong player-facing value.
- Helps future testers understand controls before judging Cinderfen pressure.
- Builds on v0.6 and v0.6.1 without expanding campaign systems.

Risk:

- Could delay campaign-system progress.
- Tutorial work can become scope-hungry if it tries to explain every system.
- Needs browser layout and smoke care to avoid overlay regressions.

Required tests:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- targeted tutorial smoke/layout assertions if copy or layout changes
- no save-version bump

Files likely touched:

- `src/game/data/tutorials.ts`
- `src/game/tutorial/*`
- `src/game/ui/hudPanels/TutorialPanel*`
- `tests/e2e/smoke.spec.ts`
- `docs/V061_TUTORIAL_FEEL_REVIEW.md`
- `README.md`
- `ROADMAP.md`
- `LLM_GAME_HANDOFF.md`

Why now:

- Manual Cinderfen pressure feedback depends on players being comfortable with core controls.
- Better onboarding can improve the quality of human pressure feedback.

Why not now:

- v0.6.1 already did tutorial feel polish.
- More tutorial work may postpone pressure-system learning.

Recommended first safe implementation:

- Run a short human-style tutorial review first.
- Apply only tiny copy, pacing, or overlay clarity changes.
- Keep no rewards and no persistence unchanged.

## 6. Recommendation

Recommended next direction: Option C first, then Option D if player-facing work is preferred.

Reason:

- v0.7.3 still lacks Emmanuel's direct manual pressure ratings.
- Option A should wait until the manual checklist either confirms current pressure feel or identifies a specific problem.
- Option B should wait because adding content before pressure feel settles increases review surface.
- Option C improves the project runway without touching gameplay, while Option D improves player readiness for future pressure feedback.

If Emmanuel returns strong manual evidence that current pressure warnings are clear and fair, the first pressure-specific v0.8 should be Option A as a simulator-only reinforcement experiment. It should not become live reinforcement, capture-site contest AI, defensive hold behavior, workers, construction, economy AI, new maps, new units, new factions, rewards, saves, or campaign progression changes.
