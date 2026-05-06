# v0.3.1 Polish Plan

Date: 2026-05-05

## Purpose

v0.3.1 is a polish-only phase for the frozen `Prototype v0.3` / `Cinderfen Route Baseline`. It exists to improve readability, confidence, and release hygiene around the current route without adding gameplay content or changing balance.

## Baseline Status

The v0.3 Cinderfen Route Baseline is frozen. Final automated verification is green:

```text
npm test
PASS: 38 test files, 268 tests.

npm run build
PASS: TypeScript compile and Vite production build; known large-chunk warning only.

npm run test:e2e -- --reporter=line
PASS: 52 Playwright tests.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle node/profile summaries.

git diff --check
PASS: no whitespace errors.

Production preview smoke
PASS: main menu, Prototype v0.3 copy, New Campaign, Continue Campaign, Skirmish Setup, Campaign Map, and 0 browser console errors.
```

The v0.3.1 kickoff re-ran the full frozen-baseline gate before this plan was created. The branch was clean and synced with `origin/main` before the docs-only plan edits began.

## In Scope

- UX readability polish for the existing v0.3 route surfaces.
- Mobile density checks for campaign map panels, choice cards, Results, and route-complete copy.
- Cinderfen route copy clarity for Overlook, Waystation, Crossing, Watch, Aftermath, and route-complete guidance.
- Route completion clarity after Cinderfen Aftermath, including "route secured" and "more content later" messaging.
- Performance and build-size investigation for the known Vite large-chunk warning.
- E2e runtime improvement investigation, especially slow `deep-flow.spec.ts` and `layout.spec.ts` coverage.
- Small bug fixes only when they preserve existing gameplay, balance, route order, selectors, and save format.

## Out Of Scope

- No new gameplay content.
- No new maps.
- No new units.
- No new factions.
- No workers.
- No enemy construction or rebuilding.
- No diplomacy or alliance simulation.
- No procedural generation.
- No crafting, durability, affix rerolling, or broad loot expansion.
- No balance changes unless a genuine blocking bug is found and documented.
- No broad retinue, trophy, rival, city-builder, or army-management systems.

## Recommended Work Order

1. Run a human/browser readability pass on the existing route from Ashen Outpost through Cinderfen Aftermath.
2. Check mobile density on campaign-map route cards, choice/service panels, Results, and route-complete copy.
3. Polish copy only where it reduces confusion around current Cinderfen systems.
4. Investigate the Vite chunk warning and document options before implementing any bundle split.
5. Investigate e2e runtime bottlenecks and prefer test organization improvements that keep coverage meaningful.
6. Re-run `npm test`, `npm run build`, and targeted e2e checks after any polish edit; run the full gate before another release/checkpoint.

## Success Criteria

- The frozen v0.3 route remains behaviorally unchanged.
- Cinderfen route completion is clearer to a human player.
- Mobile and dense-panel readability risks are either improved or documented.
- Build-size and e2e-runtime risks have clear follow-up options.
- Automated verification remains green.
