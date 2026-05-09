# v0.7.2 Pressure Browser Review Notes

Date: 2026-05-09

Status: Phase 2 browser-review harness notes. This document prepares review flows only. It does not add gameplay, mechanics, rewards, saves, maps, units, factions, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive hold behavior, or broad systems.

## 1. Existing Helpers Available

The current Playwright suite already has enough test-only support for a repeatable Cinderfen pressure review.

From `tests/e2e/chapter2-helpers.ts`:

- `seedPostAshenCampaign(page)`: writes a post-Ashen Chapter 2 save with Cinderfen Overlook available.
- `seedPostCinderfenCrossingCampaign(page)`: writes a post-Crossing save with Cinderfen Watch available.
- `launchCinderfenCrossing(page)`: launches `cinderfen_crossing` through the campaign UI.
- `launchCinderfenWatch(page)`: launches `cinderfen_watch` through the campaign UI.
- `captureCinderShrineWithHook(page)`: uses the existing test-only battle hook to capture `cinder_crossing`.
- `completeCinderfenVictory(page)`: fast-forwards Crossing victory after launch assertions.
- `completeCinderfenWatchVictory(page)`: fast-forwards Watch victory after launch assertions.

From `tests/e2e/enemy-pressure.spec.ts`:

- `captureSiteWithHook(page, siteId)`: captures a named site through the existing battle hook.
- `readPressureState(page)`: reads active plan id, triggered/completed stage ids, warnings shown, reinforcement-applied state, and status text.
- `advancePressureRuntime(page, seconds)`: advances runtime enough to inspect delayed pressure warnings.
- `showNormalStatusMessage(page, message)`: verifies pressure status priority against ordinary status replacement.

From `tests/e2e/shared-helpers.ts`:

- `seedCampaignSave(page, options)`: can create focused campaign states without replaying all prior content.
- `continueSavedCampaign(page)`: opens the seeded campaign map through visible UI.

No new test-only helper was added in Phase 2 because the existing helpers already cover the review entry points and because adding another command would create maintenance surface before evidence proves it is needed.

## 2. Browser Surface Choice

Two browser surfaces are useful, but they serve different purposes:

- Playwright is the repeatable review harness because it can seed saves and use battle test hooks.
- Browser preview smoke is the visible production sanity surface because it shows the real app without test hooks.

The in-app browser API used for preview smoke does not expose the same `page.evaluate` test-hook surface as the Playwright suite. For seeded Cinderfen pressure review, use Playwright or a Playwright-headed run first; use the in-app browser for preview smoke, screenshots, and human visual sanity when a route is reachable without seeding.

## 3. Cinderfen Crossing Review Flow

Preferred repeatable flow:

1. Seed a post-Ashen campaign state with `seedPostAshenCampaign(page)`.
2. Continue Campaign from the main menu.
3. Complete an Overlook choice if launching through the full route UI, or seed directly to the state where Crossing is available.
4. Launch `cinderfen_crossing` with `launchCinderfenCrossing(page)`.
5. Confirm battle shell:
   - `battle-hud`
   - `battle-resources`
   - `battle-hero-panel`
   - `battle-minimap`
   - `minimap`
6. Confirm launch pressure metadata:
   - mode: `campaign_node`
   - campaign node id: `cinderfen_crossing`
   - map id: `cinderfen_causeway`
   - pressure plan id: `causeway_contest_pressure`
7. Capture the Cinder Shrine through the test hook:
   - site id: `cinder_crossing`
8. Observe status and objective feedback:
   - `Cinder Shrine Surge` should remain readable as objective feedback.
   - pressure should trigger stage `shrine_route_warning`.
   - delayed pressure should show `Ashen scouts mark the center road. Expect faster pressure after the shrine.`
9. Capture screenshots or notes after:
   - battle load
   - Cinder Shrine capture
   - delayed pressure warning
10. Record whether a human could understand:
   - why the enemy responded
   - what changed
   - why holding the route matters

Fast Army lens:

- Use telemetry plus a play-like fast route. Fast Army often wins before Crossing pressure triggers. That should be judged as strategy expression unless the shrine identity feels absent for normal-speed play.

Greedy Economy lens:

- Use telemetry plus status/defeat-tip review. Greedy Economy triggers Crossing pressure in 13/13 runs but mostly times out. The question is whether pressure copy helps explain the need to move sooner.

## 4. Cinderfen Watch Review Flow

Preferred repeatable flow:

1. Seed a post-Crossing campaign state with `seedPostCinderfenCrossingCampaign(page)`.
2. Continue Campaign from the main menu.
3. Launch `cinderfen_watch` with `launchCinderfenWatch(page)`.
4. Confirm battle shell:
   - `battle-hud`
   - `battle-resources`
   - `battle-hero-panel`
   - `battle-minimap`
   - `minimap`
5. Confirm launch pressure metadata:
   - mode: `campaign_node`
   - campaign node id: `cinderfen_watch`
   - map id: `cinderfen_watchpost`
   - pressure plan id: `ashen_watch_captain_pressure`
6. Capture Watch Road Toll through the test hook:
   - site id: `watch_road_toll`
7. Observe immediate pressure warning:
   - `The Watch Captain tightens the road guard. Keep income protected.`
8. Advance pressure runtime for the delayed warning:
   - expected delayed text: `Enemy horns answer your advance. Expect faster pressure on the raised road.`
9. Verify pressure warning remains visible against a normal status replacement attempt.
10. Capture screenshots or notes after:
   - battle load
   - Watch Road capture
   - delayed pressure warning
11. Record whether the warning feels:
   - too early
   - fair as enemy commander response
   - readable before combat focus intensifies
   - practically useful

Retinue + Training Yard II lens:

- Existing seeded helpers include retinue examples in the completed-route save, but not a direct post-Ashen pressure-battle seed with Training Yard II and retinue for active review.
- For v0.7.2, prefer simulator and existing deep-flow retinue evidence unless a dedicated test-only seed becomes necessary.
- Do not add a new helper in Phase 2; decide later only if Phase 6 needs it.

## 5. Notes To Capture During Review

Use this observation template for each battle:

```text
Battle:
Profile lens:
Entry path:
Pressure plan id:
Trigger observed:
First pressure time:
Warnings shown:
Warning text:
Objective/status conflict:
Screenshot/state evidence:
Did a human likely notice it?
Did the warning explain what changed?
Did the warning imply forbidden live behavior?
Did the warning suggest a practical response?
Change decision:
```

## 6. Current Coverage Gaps

Known gaps:

- Current targeted pressure e2e covers Cinderfen Watch, not Cinderfen Crossing.
- Current e2e verifies warning visibility and priority, but not human readability.
- Current simulator proves pressure triggers and outcomes, but not visual salience.
- There is no direct active-battle retinue + Training Yard II seed for pressure review.

None of these gaps requires code in Phase 2. They should guide Phase 3-8 evidence collection and only justify tiny harness/report additions if the review cannot proceed otherwise.

## 7. Phase 2 Decision

Do not add a new helper or broad e2e test in Phase 2.

Reason:

- Existing helpers already seed Crossing and Watch.
- Existing hooks can trigger the relevant pressure stages.
- Existing pressure e2e verifies campaign-only scope, pressure stats, delayed warning visibility, and Tutorial/skirmish no-pressure protection.
- The next useful work is evidence collection and review docs, not more harness code.

If a later phase needs a focused observability improvement, keep it tiny, test-only, and scoped to pressure review.
