# v0.7.3 Pressure Review Setup

Status: Phase 2 setup note. This document records how to reach the current Cinderfen pressure battles for v0.7.3 review without adding gameplay, rewards, saves, maps, units, factions, workers, construction, or new pressure behavior.

## 1. Setup Decision

No new helper code is needed for v0.7.3.

Existing Playwright helpers already cover the review entry points:

- `seedPostAshenCampaign(page)` creates a post-Ashen Chapter 2 save with Cinderfen Overlook available.
- `seedPostCinderfenCrossingCampaign(page)` creates a post-Crossing save with Cinderfen Watch available.
- `launchCinderfenCrossing(page)` launches `cinderfen_crossing` through the campaign UI.
- `launchCinderfenWatch(page)` launches `cinderfen_watch` through the campaign UI.
- `captureCinderShrineWithHook(page)` can trigger the Cinder Shrine capture after Crossing is already launched.
- The pressure e2e file can read active pressure plan id, triggered/completed stage ids, warning counts, and reinforcement-applied state.

These helpers are test-only and do not affect production gameplay. They are appropriate for seeded surrogate evidence, but their hook-driven capture and direct runtime reads must not be described as true manual play.

## 2. Launch The App

For production-preview smoke:

```text
npm run build
npm run preview -- --host 127.0.0.1 --port 4173
```

Then open:

```text
http://127.0.0.1:4173/
```

For Playwright-backed review:

```text
npm run test:e2e:smoke
npx playwright test tests/e2e/enemy-pressure.spec.ts --reporter=line
```

For ad hoc local development review:

```text
npm run dev -- --host 127.0.0.1 --port 5173
```

If another server already owns the port, use a fresh port and document it. Do not rely on a stale dev server for evidence.

## 3. Cinderfen Crossing Seed Path

Best controlled setup:

1. Start from `seedPostAshenCampaign(page)`.
2. Continue the campaign.
3. Open `cinderfen_overlook`.
4. Choose a normal Overlook option if the review needs the campaign route context.
5. Launch `cinderfen_crossing` through `launchCinderfenCrossing(page)`.
6. Capture visual evidence after the battle HUD is visible.
7. Trigger Cinder Shrine capture through either:
   - normal player-like movement if feasible in the browser, labeled controlled browser-input evidence, or
   - `captureCinderShrineWithHook(page)`, labeled seeded surrogate evidence.

Expected pressure behavior:

- Active plan id: `causeway_contest_pressure`.
- No pressure warning at battle load.
- Shrine capture should preserve `Cinder Shrine Surge` as objective-priority feedback.
- Delayed pressure warning should read: `Ashen scouts mark the center road. Expect faster pressure after the shrine.`
- `pressureReinforcementApplied` should remain false.

## 4. Cinderfen Watch Seed Path

Best controlled setup:

1. Start from `seedPostCinderfenCrossingCampaign(page)`.
2. Continue the campaign.
3. Launch `cinderfen_watch` through `launchCinderfenWatch(page)`.
4. Capture visual evidence after the battle HUD is visible.
5. Trigger Watch Road capture through either:
   - normal player-like movement if feasible in the browser, labeled controlled browser-input evidence, or
   - the generic `captureSite` hook with `watch_road_toll`, labeled seeded surrogate evidence.

Expected pressure behavior:

- Active plan id: `ashen_watch_captain_pressure`.
- No pressure warning at battle load.
- Watch Road capture should show: `The Watch Captain tightens the road guard. Keep income protected.`
- The delayed raised-road warning should read: `Enemy horns answer your advance. Expect faster pressure on the raised road.`
- Ordinary status messages should not immediately overwrite the active pressure warning.
- `pressureReinforcementApplied` should remain false.

## 5. Retinue And Training Yard II Context

The existing `seedCompletedCinderfenRouteCampaign(page)` helper includes Training Yard I/II and retinue units, but it represents a route-complete state, not a clean pre-Crossing or pre-Watch review state.

For v0.7.3, treat Retinue + Training Yard II primarily as telemetry and manual-checklist evidence unless a specific future helper is justified. Do not add a new seed helper solely to make the saved-progress power profile easier to automate during this goal.

Relevant telemetry profile:

- Stronghold profile id: `retinue_training_yard_path`.
- Current v0.7.2 read: 6 Cinderfen pressure-node runs, 6 wins, 0 defeats, 0 timeouts, 5 pressure-triggered runs, 9 warnings, and 0 losses after pressure.

## 6. Console Notes

For Playwright review, keep console/page errors fatal by attaching the same pattern used in `tests/e2e/enemy-pressure.spec.ts`.

For in-app browser preview review:

- Read browser console error logs after each pass.
- Record zero errors or list any specific error.
- If browser automation loses connection or the user takes over, label the pass incomplete instead of hiding it.

## 7. Evidence Labels

Use these exact labels in review docs:

- `Real-input manual evidence`: a person directly used mouse and keyboard.
- `Controlled browser-input evidence`: browser automation clicked, typed, or pressed at normal-feeling pacing and relied on visible UI state.
- `Seeded surrogate evidence`: Playwright/test hooks created state, captured a site, advanced runtime, or read internals.
- `Simulator evidence`: deterministic telemetry from the playtest simulator.

Do not call a seeded hook pass human play.

## 8. Review Boundaries

Do not use setup work to justify:

- new helper commands unless a later phase proves a real block;
- new gameplay state;
- new pressure actions;
- live reinforcements;
- capture-site contest AI;
- defensive holds;
- new maps, units, factions, rewards, saves, workers, construction, economy, or campaign progression.

The setup is allowed to make review cheaper. It is not allowed to make pressure stronger.
