# v0.3.1 Mobile And Readability Audit

Date: 2026-05-05

Scope: automated mobile/readability audit for the frozen `Prototype v0.3` / `Cinderfen Route Baseline`.

This audit uses Playwright route-state seeding, stable DOM/test-id assertions, text checks, layout-box checks, and horizontal-overflow detection. It intentionally does not use manual playtesting or screenshot pixel matching. No gameplay, balance, maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, or new content were added.

## Audit Verdict

Verdict: `watch, not blocked`.

The automated audit rules out critical horizontal overflow on the covered v0.3 route surfaces and confirms required Cinderfen text, route-complete copy, and important buttons are reachable across the requested core viewports. The route is safe to keep frozen while v0.3.1 continues as readability polish.

The remaining risks are density and hierarchy, not broken state: Cinderfen campaign panels are information-heavy on tablet/mobile, Aftermath choices are dense after completion, and the e2e layout suite is slower after adding route-specific viewport checks.

## Viewports

| Viewport | Size | Coverage |
| --- | ---: | --- |
| Desktop | 1366 x 768 | Main menu, campaign route surfaces, Crossing HUD, Watch HUD, command panel, minimap, Watch results. |
| Tablet | 820 x 620 | Main menu, campaign route surfaces, route-complete copy, choice/service panels. |
| Mobile portrait | 390 x 844 | Main menu, campaign route surfaces, Crossing HUD, Watch HUD, command panel, minimap, Watch results. |
| Mobile landscape | 844 x 390 | Main menu, campaign route surfaces, Crossing HUD, Watch HUD, command panel, minimap. |

## Automated Coverage Added

Added a test-only completed-route save helper in `tests/e2e/chapter2-helpers.ts`:

- Seeds the frozen v0.3 Cinderfen route as complete.
- Includes the completed Cinderfen node chain through Aftermath.
- Includes route-complete state, Malrec trophy data, rival intel, retinue units, Training Yard II, reputation, and campaign resources so the campaign map is audited under dense but valid route-state data.

Added route-readability Playwright assertions in `tests/e2e/layout.spec.ts`:

- `v0.3 Cinderfen menu and campaign readability fit desktop/tablet/mobile portrait/mobile landscape`
- `Cinderfen battle HUD and Watch results readability fit desktop/mobile portrait/mobile landscape`

The checks cover:

- No horizontal overflow on core menu, campaign, battle HUD, and Results surfaces.
- Required v0.3 main menu text: `Prototype v0.3` and `Cinderfen Route Baseline`.
- Main menu New Campaign, Continue Campaign, and Skirmish buttons reachable.
- Campaign chapter cards and node cards readable.
- Border Marches and Cinderfen Road sections visible.
- Cinderfen route-complete copy visible after seeded Aftermath completion.
- Overlook choices show costs, rewards, reputation, modifiers, and Malrec trophy option when seeded.
- Waystation service copy shows costs, Shrine Attunement effect, and repeat/open-node behavior.
- Crossing HUD shows objectives, Cinder Shrine copy, resources, minimap, and reachable command panel.
- Watch HUD shows watch-road/watchpost objectives, resources, minimap, and reachable command panel.
- Watch Results on mobile portrait shows reward summary, campaign unlock summary, objective summary, and reachable Campaign Map action.
- Aftermath completed state shows route-complete result and disabled already-chosen copy without duplicate reward confusion.

## Screen Audit

| Area | Automated Status | Risk | Notes |
| --- | --- | --- | --- |
| Main menu | Safe | safe | `Prototype v0.3`, `Cinderfen Route Baseline`, New Campaign, Continue Campaign, and Skirmish are visible/reachable with no horizontal overflow. |
| Campaign map | Covered | watch | Chapter cards, Cinderfen nodes, route-complete copy, reputation, Stronghold, retinue, rival intel, and trophies fit horizontally. Density remains a human-readability watch item. |
| Cinderfen Overlook | Covered | watch | Choices expose costs/rewards/reputation/modifiers. Malrec trophy choice is readable and reachable when seeded. Copy density remains high on small screens. |
| Cinderfen Waystation | Covered | watch | Services expose costs/effects; Shrine Attunement explains its modifier and keeps the node open. Service panel remains dense on mobile. |
| Cinderfen Crossing battle HUD | Covered | watch | Map/HUD loads with Cinder Shrine objective, Cinder Shrine Surge text, minimap, resources, and command panel. Shrine salience still deserves human review later. |
| Cinderfen Watch battle HUD | Covered | watch | Watch Road, Marsh Raider Camp, Watchpost Tower objectives, minimap, resources, and command panel are present/reachable. |
| Cinderfen Aftermath | Covered | watch | Completed route state shows disabled `Already chosen` copy, costs/rewards/reputation text, and route-complete guidance. Choice density remains the main risk. |
| Results scene | Covered | watch | Mobile portrait Watch Results shows battle reward summary, campaign reward/unlock summary, objective summary, and reachable Campaign Map action. Route completion itself remains campaign-map/event copy, not a battle Results scene. |

## Overflow Findings

No critical horizontal overflow was found by the added automated checks.

The audit checks all visible descendants under `#ui-root` for left/right viewport overflow on core Cinderfen surfaces. It also checks important buttons and major panels with layout-box assertions after DOM scrolling. This rules out the main mobile failure class this pass was created to detect.

## Known Watch Items

- Campaign map density: route cards plus Stronghold, retinue, rival intel, trophies, and reputation are horizontally safe but visually busy.
- Cinder Shrine readability: objective and surge text are automated, but visual salience should still get human/browser review later.
- Waystation service clarity: text is present, but the service list is compact and easy to skim past on mobile.
- Aftermath density: choices are complete and safe, but the completed-node disabled states produce a lot of text in one panel.
- E2E runtime: route-specific viewport tests add useful coverage but make `layout.spec.ts` slower. Future v0.3.1 work should look for safe runtime improvements without dropping meaningful coverage.

## Verification

Targeted coverage added in this audit:

```text
npm run test:e2e -- --reporter=line -g "v0.3 Cinderfen menu|Cinderfen battle HUD"
PASS: 7 Playwright tests in 8.0m.
```

Required full verification for this task:

```text
npm test
PASS: 38 test files, 268 tests, 19.40s on the final post-doc rerun.

npm run build
PASS: TypeScript compile and Vite production build. Known large-chunk warning only.
Latest output: assets/index-BRMcmX2c.js, 1,917.92 kB minified / 457.57 kB gzip.

npm run test:e2e -- --reporter=line
PASS: 59 Playwright tests, 30.4m.
Slow files: tests/e2e/layout.spec.ts at 12.8m and tests/e2e/deep-flow.spec.ts at 12.2m.

git diff --check
PASS: no whitespace errors.
```

## Decision

Classification: `watch, not blocked`.

The frozen v0.3 route remains suitable for v0.3.1 polish. Automated readability checks now cover the key route screens and detect no critical mobile overflow. Do not add new gameplay or broad systems in response to this report; the next useful work is controlled readability polish, human/browser review when desired, and e2e runtime investigation.
