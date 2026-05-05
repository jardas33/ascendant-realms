# v0.3 Release Candidate Report

Date: 2026-05-05

Final verification updated: 2026-05-05 18:36 -04:00

## Release Identity

Release label: `Prototype v0.3`

Subtitle: `Cinderfen Route Baseline`

Verdict: `release candidate safe` and ready to freeze for the v0.3 prototype baseline, with readability watch items and no automated blockers.

Prototype v0.3 contains the current route-complete Cinderfen vertical slice on top of the v0.2 systems baseline. It adds the compact Chapter 2 route after Ashen Outpost, keeps the v0.2 hero/campaign/RTS systems intact, and documents the route as a baseline candidate for verification, readability, UX, and controlled polish.

Prototype v0.3 explicitly does not contain a full Chapter 2 campaign, broad new systems, new factions, new units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, broad loot expansion, or broad army-management layers.

## Playable Content

Chapter 1 / Border Marches remains the stable campaign spine: Border Village, Old Stone Road, Marcher Camp, Aether Well Ruins, Bandit Hillfort, Chapel of the Marches, Refugee Caravan, and Ashen Outpost. The current v0.3 pass does not change Chapter 1 rewards or balance.

Chapter 2 / Cinderfen is a compact authored route after Ashen Outpost. The current playable slice ends at Cinderfen Aftermath and shows route-complete copy instead of launching missing future content.

Current Cinderfen node order:

1. Cinderfen Overlook
2. Cinderfen Waystation
3. Cinderfen Crossing
4. Cinderfen Watch
5. Cinderfen Aftermath

## Systems Included

- Hero progression with class, origin, XP, levels, skill points, skill trees, and class abilities.
- Inventory, equipment, reward item instances, unique duplicate conversion, and randomized item affixes V1.
- Construction, unit training, battle upgrades, rally points, and Stronghold Development through Tier II.
- Minimap, fog of war, capture-site visibility, pings, and colorblind minimap support.
- Persistent campaign resources: Crowns, Stone, Iron, and Aether.
- Reputation ranks and modest active effects for campaign choices and preparation.
- Enemy heroes, rival persistence, first-defeat rewards, and trophy records.
- Retinue Camp V1 and unit veterancy with small save-backed veteran deployment.
- Chapter 2 Cinder Shrine with battle-local Aether surge and Waystation services for compact Cinderfen preparation.

## Verification Status

Final automated release-candidate verification:

| Check | Status | Notes |
| --- | --- | --- |
| `npm test` | PASS | Final RC run: 38 test files and 268 tests passed in 7.40s. |
| `npm run build` | PASS | Final RC run: TypeScript and Vite production build passed. Output: `assets/index-BRMcmX2c.js`, 1,917.92 kB minified / 457.57 kB gzip. |
| `npm run test:e2e -- --reporter=line` | PASS | Final RC run: 52 Playwright tests passed in 21.9m. Slow files remained `tests/e2e/deep-flow.spec.ts` and `tests/e2e/layout.spec.ts`. |
| `npm run playtest:sim` | PASS | Final RC run: 255 deterministic runs across 85 campaign battle node/profile summaries. The command regenerated telemetry files with no git diff. |
| `git diff --check` | PASS | Final RC run: no whitespace errors. |
| Production preview smoke | PASS | Browser Use smoke at `http://127.0.0.1:4187/`: main menu loaded, `Prototype v0.3` and `Cinderfen Route Baseline` were visible, New Campaign reached Campaign Map, Continue Campaign returned to Campaign Map, Skirmish Setup opened, and browser console errors stayed at 0. Preview server was stopped after the smoke. |
| Vite chunk warning | ACCEPTED | Main Phaser bundle exceeds the default 500 kB warning threshold. The final RC build output is about 1.92 MB minified and 457.57 KB gzip, acceptable for this prototype. |

The production preview report recorded the large bundle warning as acceptable for this prototype. Future optimization ideas are chunk splitting, lazy-loading optional screens/assets, and reviewing Phaser bundle boundaries, but no optimization work is part of this release-candidate pass.

## Telemetry Summary

- Chapter 1 stability: stable. Chapter 1 rewards, route progression, and Ashen Outpost beatability remain unchanged by the Cinderfen reward-economy and release-candidate work.
- Cinderfen Crossing: structurally reasonable. Latest simulator summary records 39 Crossing runs, 26 wins, 0 defeats, and 13 timeouts.
- Cinderfen Watch: structurally reasonable. Latest simulator summary records 36 Watch runs, 25 wins, 0 defeats, and 11 timeouts.
- Fast Army farming risk: reduced and watch-listed. Fast Army still clears many Cinderfen runs quickly, but repeat clear payouts were reduced to tiny XP/resources and no repeat battle item rolls.
- Greedy Economy timeout rate: watch. Timeouts appear to reflect routing/final-assault pace rather than structural difficulty failure.
- Retinue + Training Yard II strength: watch. Strongest observed Cinderfen support profile was 6 wins / 0 defeats across the Crossing/Watch pair, without an automated too-easy flag.
- Cinder Shrine usage: visible and contained. Crossing has a one-time battle-local +20 Aether surge, with Shrine Attunement raising the next qualifying capture to +25 Aether.
- Repeat rewards: reduced. Crossing repeats now grant 4 XP / 11 resources / no battle item roll; Watch repeats grant 3 XP / 8 resources / no battle item roll.

## Readability And UX Risks

| Area | Risk | Classification | Notes |
| --- | --- | --- | --- |
| Cinderfen route mobile density | Some cards and panels are dense after the Chapter 2 expansion. | watch | Automated layout coverage is present; human mobile readability pass still recommended. |
| Cinder Shrine readability | The first-capture surge and Shrine Attunement need human clarity review. | watch | Automated battle clarity is covered; subjective salience remains a polish target. |
| Waystation service clarity | Services show costs/effects/repeat behavior, but the panel is information-heavy. | watch | Keep copy concise; avoid adding shop systems. |
| Aftermath choice density | Completion copy and choice consequences are readable but compact. | watch | Human scan test recommended before wider playtest. |
| Retinue/rival/trophy readability | Systems are present and covered, but multiple persistent panels compete for attention. | watch | Future polish should improve hierarchy without adding new mechanics. |
| E2e runtime | Full suite is slow, about 21-24 minutes on this machine. | watch | Runtime is acceptable for release gates, but future helper maintenance should avoid increasing brittleness. |

No current readability or UX risk is classified as blocked.

## Release Decision

Classification: `release candidate safe`.

The current v0.3 Cinderfen route is ready to freeze as a prototype release candidate under automated evidence: route progression is covered, first-clear and repeat reward integrity is covered, Cinderfen battle clarity has e2e coverage, simulator telemetry has no structural too-easy or too-hard flags, production preview has no hard browser console errors, and no production-only crash was found.

This is not a full human feel signoff. The route should still receive a human/browser readability pass before broader sharing or a polish tag, especially around mobile density, the Cinder Shrine, Waystation services, Aftermath choices, and retinue/rival/trophy panel hierarchy.

## Next Recommended Work

- Do not add broad systems yet.
- Keep the next work focused on verification, readability, UX hierarchy, copy clarity, and controlled polish on the existing v0.3 route.
- Run a human/browser readability pass when possible, using the current preview build and the existing route from Ashen Outpost through Cinderfen Aftermath.
- If the readability pass finds only minor issues, polish v0.3 in place.
- If the readability pass finds broader but non-blocking presentation issues, plan a small v0.3.1 polish checkpoint.
- Continue to avoid new maps, factions, units, workers, enemy construction, diplomacy, procedural generation, crafting, durability, and broad loot systems until the current route baseline is fully stable.
