# v0.3.1 Polish Release Report

Date: 2026-05-06

Final verification updated: 2026-05-06 18:30:40 -04:00

Freeze status: `frozen` as of the `Freeze v0.3.1 polish release` documentation pass.

## Release Identity

Release label: `Prototype v0.3.1`

Release type: polish release for the frozen `Prototype v0.3` / `Cinderfen Route Baseline`.

`v0.3` is the content baseline: the current playable route through Chapter 1, Ashen Outpost, Cinderfen Overlook, optional Cinderfen Waystation, Cinderfen Crossing, Cinderfen Watch, and Cinderfen Aftermath.

`v0.3.1` is the readability, performance-audit, and test-maintenance polish layer on top of that baseline. It does not extend the campaign or add new mechanics.

## What Changed In v0.3.1

- Mobile/readability audit coverage now checks the frozen Cinderfen route across desktop, tablet, mobile portrait, and mobile landscape surfaces.
- Cinderfen copy and hierarchy were tightened for the existing Overlook, Waystation, Crossing, Watch, Aftermath, route-complete, and Results surfaces.
- Route-complete clarity was improved so completing Cinderfen Aftermath communicates that the current route is secured and the playable Chapter 2 slice is complete.
- Cinderfen Overlook, Waystation, and Aftermath density was improved with shorter service/choice copy, clearer one-time/repeat labels, and more scannable choice structure.
- Results copy was improved so first clears, reduced repeat rewards, campaign unlocks, and no-duplicate reward behavior are clearer.
- The known Vite large-chunk warning was audited and documented in `docs/PERFORMANCE_BUNDLE_AUDIT.md`.
- The Playwright runtime was audited in `docs/E2E_RUNTIME_AUDIT.md`, including slow-file causes and safe future improvement paths.
- Shared e2e setup helpers were added for smoke/layout setup where tests are not specifically proving the full hero-creation path.
- Full-flow coverage was preserved: Chapter 2 route assertions remain visible in spec files, and `deep-flow.spec.ts` remains intact for release-critical gameplay paths.

## What Did Not Change

- No new gameplay.
- No balance changes.
- No new maps.
- No new units.
- No new factions.
- No workers.
- No enemy construction or rebuilding.
- No crafting, durability, affix rerolling, or broad loot expansion.
- No procedural campaign or procedural maps.
- No diplomacy or alliance simulation.
- No broad retinue, trophy, rival, city-builder, or army-management systems.

## Verification Status

Final automated verification:

| Check | Status | Notes |
| --- | --- | --- |
| `npm test` | PASS | 38 test files, 270 tests, 7.56s. |
| `npm run build` | PASS | TypeScript compile and Vite production build passed; known Vite large-chunk warning only. |
| Vite build output | PASS with known warning | `assets/index-BlnznQM_.js`, 1,918.65 kB minified / 457.79 kB gzip; `assets/index-CIXXIuKP.css`, 41.86 kB minified / 8.71 kB gzip. |
| `npm run test:e2e -- --reporter=line` | PASS | 59 Playwright tests in 28.6m. Slow files: `tests/e2e/layout.spec.ts` at 12.3m and `tests/e2e/deep-flow.spec.ts` at 11.4m. |
| `npm run playtest:sim` | PASS | 255 deterministic runs across 85 campaign battle node/profile summaries. |
| `git diff --check` | PASS | No whitespace errors. |
| Production preview smoke | PASS | Browser Use smoke at `http://127.0.0.1:4188/`: title `Ascendant Realms`, main menu loaded, `Prototype v0.3` and `Cinderfen Route Baseline` were visible, New Campaign reached Campaign Map, Continue Campaign returned to Campaign Map, Skirmish Setup opened with current maps, browser console errors stayed at 0, and the preview server was stopped after the smoke. |

Known build warning:

```text
(!) Some chunks are larger than 500 kB after minification.
```

This remains accepted for the prototype because the build passes, the main JS gzip size is about 457.79 kB, and the warning is driven mainly by Phaser plus the current eager scene/data import graph.

## Known Risks

- Human readability is not fully replaceable by automation; the current checks verify reachability, text, and overflow, but not subjective scan quality or feel.
- Mobile density still deserves a live browser review, especially on campaign map panels, Overlook choices, Waystation services, Aftermath choices, and Results.
- Cinder Shrine salience remains a watch item: objective and surge copy are covered, but human review should confirm the shrine feels visible and understandable in play.
- Retinue, rival intel, and trophy hierarchy remain dense on the campaign map and should be reviewed without adding new systems.
- Playwright runtime is still long at roughly 29 minutes for the full release-gate suite.
- The Vite large-chunk warning remains known and documented; code splitting or chunking was intentionally not implemented in v0.3.1.
- Simulator results are structural and deterministic; they cannot replace human reads on stress, visual clarity, audio, or route pacing.

## Release Decision

Classification: `frozen`.

Prototype v0.3.1 is frozen as a polish release for the frozen Cinderfen Route Baseline. The required fresh gates pass, the latest full checkpoint gates are green, no gameplay or balance work was added, and the remaining risks are documented watch items rather than blockers.

This release is not a human-feel signoff. It is a safe automated and documentation checkpoint for readability, performance-risk documentation, and e2e maintenance after the v0.3 content baseline.

## Next Recommended Path

After the v0.3.1 freeze, choose one of two paths:

1. Start v0.4 planning only after the frozen Cinderfen route has received a human browser/readability review.
2. Run a safe technical optimization milestone focused on measurement first, such as bundle analyzer reporting or an explicit default-vs-release-gate e2e script split.

Avoid new content until the frozen route has been reviewed in human play. In particular, do not add new maps, units, factions, workers, enemy construction, procedural generation, crafting, diplomacy, or broad systems as a response to this v0.3.1 report.
