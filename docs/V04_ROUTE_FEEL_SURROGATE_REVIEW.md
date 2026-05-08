# v0.4 Route Feel Surrogate Review

Date: 2026-05-08

Scope: automated full-route human-surrogate review for the frozen `Prototype v0.3` / `Cinderfen Route Baseline`.

This pass uses existing telemetry, e2e coverage, view-model assertions, content validation, and release reports. It does not add gameplay, maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, balance changes, or new campaign systems. It is not a human feel signoff.

## Verdict

Classification: `watch, not blocked`.

The current automated evidence supports keeping the Cinderfen route frozen while v0.4 continues technical, UX, and planning work. Route progression, event copy, battle objective copy, reward persistence, duplicate-prevention, mobile overflow, and dense route-state panels are covered by stable tests and reports. The remaining risks are subjective readability and strategy feel: Cinder Shrine salience, Waystation service scan quality, Aftermath density, Fast Army clear speed, and retinue plus Training Yard II strength.

No new automated check was added in this phase. The existing smoke, layout, deep-flow, rule, content-validation, and simulator coverage already covers the requested route-feel surrogate surface without a major gap. Adding another check now would be more likely to duplicate current assertions than to reduce risk.

## Evidence Sources

| Source | What it contributes |
| --- | --- |
| `PLAYTEST_TELEMETRY.md` | 255-run deterministic read across 85 campaign battle nodes, including current Cinderfen Crossing and Cinderfen Watch slices. |
| `tests/e2e/smoke.spec.ts` | Browser route flow from post-Ashen Cinderfen unlock through Overlook, Waystation, Crossing, Watch, Aftermath, reward persistence, and duplicate prevention. |
| `tests/e2e/layout.spec.ts` | Desktop, tablet, mobile portrait, and mobile landscape readability and overflow checks for menu, campaign, Cinderfen battle HUD, and Watch Results. |
| `tests/e2e/deep-flow.spec.ts` | Long-form campaign, Results, retinue, rival, trophy, reward, minimap, and BattleScene coverage. |
| `docs/CINDERFEN_ROUTE_READINESS_GATE.md` | Prior automated route-readiness verdict and risk classification. |
| `docs/V031_MOBILE_READABILITY_AUDIT.md` | Prior no-critical-overflow mobile/readability audit with route-specific viewport coverage. |
| `docs/V031_POLISH_RELEASE_REPORT.md` | Frozen v0.3.1 release framing and known human-review limits. |

## Route Feel Matrix

| Area | Surrogate read | Evidence | Risk |
| --- | --- | --- | --- |
| Route progression clarity | Safe. The path Ashen Outpost -> Overlook -> Waystation/Crossing -> Watch -> Aftermath is covered by rules, view-models, and browser flow. | `smoke.spec.ts`, `CampaignRules.test.ts`, `CampaignMapViewModel.test.ts`, readiness gate. | Low. |
| Overlook choice clarity | Safe with density watch. Costs, rewards, reputation, Malrec trophy requirement, and completion behavior are asserted in browser and view-model tests. | `smoke.spec.ts`, `layout.spec.ts`, readiness gate. | Medium on small screens because choice panels are text-heavy. |
| Waystation service clarity | Safe with density watch. Service costs/effects/repeat/open-node behavior are asserted, including Shrine Attunement spending and modifier copy. | `smoke.spec.ts`, `layout.spec.ts`, `CampaignRules.test.ts`, mobile audit. | Medium because compact service lists can still be skimmed past by humans. |
| Crossing objective clarity | Safe. The HUD and objective panel expose Cinderfen Causeway, Claim the Cinder Shrine, Cinder Shrine Surge, Clear Cinder Guardians, and Destroy Enemy Barracks. | `smoke.spec.ts`, `layout.spec.ts`, content validation. | Low-medium because visual route pressure still needs human play. |
| Cinder Shrine salience | Watch. Copy, metadata, first-capture Aether surge, and visibility are covered, and telemetry shows 26/39 Crossing runs captured it. | `smoke.spec.ts`, `layout.spec.ts`, `ResourceSystem.test.ts`, telemetry. | Medium. Automation proves it exists and pays out, not that it visually reads instantly. |
| Watch objective clarity | Safe. Cinderfen Watchpost launches and exposes Watch Road, Marsh Raider Camp, Watchpost Tower, resources, minimap, and Results. | `smoke.spec.ts`, `layout.spec.ts`, content validation. | Low-medium because fog/tower readability remains a human-review item. |
| Aftermath route-complete clarity | Safe with density watch. Aftermath availability, choice costs/rewards/reputation, route-complete guidance, and duplicate prevention are covered. | `smoke.spec.ts`, `layout.spec.ts`, `FirstExperienceGuidance.test.ts`, mobile audit. | Medium because completed choice text can be dense. |
| Results readability | Safe with mobile watch. Results asserts reward summary, campaign unlock summary, objective summary, reward/equip flows, retinue recruitment, rival rewards, and campaign return. | `smoke.spec.ts`, `layout.spec.ts`, `deep-flow.spec.ts`. | Medium on narrow viewports with many reward panels. |
| Mobile overflow | Safe for covered surfaces. No critical horizontal overflow was found on route campaign, battle HUD, or Results surfaces. | `layout.spec.ts`, mobile audit. | Low for overflow, medium for visual density. |
| Retinue/rival/trophy panel density | Covered but watch. Seeded completed-route layout includes retinue units, rival intel, trophy data, reputation, and Stronghold state. | `layout.spec.ts`, `deep-flow.spec.ts`, mobile audit. | Medium because hierarchy and scan speed are subjective. |
| Fast Army quick-clear risk | Watch, controlled. Fast Army wins most current Cinderfen attempts, but repeat clears now pay tiny XP/resources and no battle item roll. Poor first-wave survival suggests rush fragility rather than safe farming dominance. | Telemetry and reward-economy audit. | Medium. Keep visible, do not tune blindly. |
| Retinue plus Training Yard II strength | Watch, controlled. This is the strongest current Chapter 2 profile at 6/6 Cinderfen wins, but no structural `too_easy` flag is present. | Telemetry, retinue rules coverage, readiness gate. | Medium-high for future tuning, not a current blocker. |

## Telemetry Read

Current Cinderfen slice from `PLAYTEST_TELEMETRY.md`:

- Cinderfen Crossing: Safe Beginner 13 wins / 0 defeats / 0 timeouts; Greedy Economy 1 win / 0 defeats / 12 timeouts; Fast Army 12 wins / 0 defeats / 1 timeout.
- Cinderfen Watchpost: Safe Beginner 12 wins / 0 defeats / 0 timeouts; Greedy Economy 3 wins / 0 defeats / 9 timeouts; Fast Army 10 wins / 0 defeats / 2 timeouts.
- Retinue plus Training Yard II: 6 wins / 0 defeats / 0 timeouts across the current Cinderfen pair.
- Cinder Shrine: 26/39 Crossing runs captured the shrine and received the one-time surge; 2 attuned runs raised that first capture to +25 Aether.
- Repeat-clear economy: Crossing 4 XP / 11 resources / no battle item roll; Watchpost 3 XP / 8 resources / no battle item roll.

Interpretation: Safe Beginner stabilizes both current Chapter 2 battles, so the route is not structurally blocked. Greedy Economy timeouts and Fast Army rush wins are strategy-spread watch items. The reward audit keeps Fast Army repeat farming controlled without changing first-clear usefulness.

## Coverage Gap Review

No major automated coverage gap was found for this phase.

Covered:

- Route node unlocks and completion.
- Overlook, Waystation, and Aftermath event/service text.
- Cinderfen battle launch, HUD, map names, objectives, minimap, and Results.
- Cinder Shrine metadata, objective copy, first-capture surge, and Shrine Attunement modifier.
- Watch objective copy and Watch Results readability.
- Reward persistence, duplicate-prevention, first-clear/repeat-clear policy, and campaign bank changes.
- Retinue, rival, trophy, and dense completed-route panel presence.
- Desktop/tablet/mobile portrait/mobile landscape horizontal overflow checks.

Not fully covered by automation:

- Human eye-tracking and scan order on dense campaign panels.
- Whether the Cinder Shrine feels prominent during live pressure.
- Whether Waystation services are understood quickly without reading every line.
- Whether retinue plus Training Yard II feels empowering or mandatory.
- Whether Fast Army clears feel skillful, degenerate, or simply a valid rush route.

## Recommendation

Do not change balance or gameplay from this surrogate review alone.

The next safe action is a human browser/readability pass over the frozen route, or a tiny copy/layout polish pass if the user explicitly asks for readability improvements. Keep future work inside technical stabilization, accessibility/readability, save safety, performance measurement, and planning until a human route-feel pass gives specific findings.

## Verification

Required for this phase:

```text
npm test
npm run build
npm run test:e2e:smoke
npm run test:e2e:layout
npm run playtest:sim
```

Verification completed:

```text
npm test
PASS: 38 test files, 271 tests, 7.10s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-90WGArXv.js, 436.35 kB / gzip 117.34 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.5m.

npm run test:e2e:layout
PASS: 21 Playwright tests in 12.0m.
Slow file: tests/e2e/layout.spec.ts, 11.8m.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.

git diff --check
PASS.
```
