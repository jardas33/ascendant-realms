# v0.4 Polish Backlog

Date: 2026-05-08

Scope: tiny no-gameplay polish backlog for the frozen `Prototype v0.3` / `Cinderfen Route Baseline` and v0.4 technical foundation. This document does not implement changes and does not authorize new maps, units, factions, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, monetization, or broad systems.

Risk labels:

- `safe`: docs, copy, test clarity, or isolated verification work with no gameplay behavior change.
- `medium risk`: touches UI hierarchy, selectors, release-gate coverage, save fixtures, or production loading and needs targeted verification.
- `high risk`: could alter gameplay, pacing, save schema, assets, or player-facing flows if handled casually.
- `blocked`: should not begin until earlier gates or human review are complete.

## UI Copy

| Item | Risk | Notes |
| --- | --- | --- |
| Tighten Waystation service labels if human review still finds them skimmable. | safe | Copy-only if existing meanings, costs, and selectors stay unchanged. |
| Clarify Cinderfen Aftermath completed-choice text if it feels dense on mobile. | safe | Keep reward/duplicate-prevention behavior unchanged. |
| Review Cinder Shrine objective wording after live browser play. | safe | Do not change shrine payout, capture behavior, or map placement. |
| Add more route-complete celebration copy. | medium risk | Could affect dense campaign panels and e2e text expectations. |

## E2E Stability

| Item | Risk | Notes |
| --- | --- | --- |
| Keep monitoring deep-flow rally wait after the Phase 5 polling hardening. | safe | No gameplay changes; only revisit if foreground flakes recur. |
| Add clearer failure messages to future Cinderfen helper assertions. | safe | Preserve assertions in specs rather than hiding them inside helpers. |
| Split `deep-flow.spec.ts` into topical files. | medium risk | Structural refactor only; release coverage must stay identical. |
| Increase Playwright workers for release lanes. | high risk | Block on localStorage/Phaser boot isolation proof. |

## Performance

| Item | Risk | Notes |
| --- | --- | --- |
| Re-run `npm run build:analyze` after any meaningful source/content change. | safe | Measurement only. |
| Keep Phaser vendor warning documented rather than hidden. | safe | Current warning is known and isolated to `vendor-phaser`. |
| Prototype lazy Asset Gallery only if proving a scene-loader pattern is explicitly useful. | medium risk | Analyzer shows size win is small. |
| Lazy-load Campaign Map, BattleScene, Results, or core data. | high risk | Blocked until scene/data lifecycle risks are lower and release coverage is expanded. |

## Accessibility

| Item | Risk | Notes |
| --- | --- | --- |
| Human-review Settings copy for UI Scale, reduced motion, fog override, and minimap palette. | safe | Copy-only follow-up from Phase 6. |
| Add a non-blocking help/reference panel for current controls. | medium risk | Must preserve existing keyboard flow and mobile layout. |
| Improve dense campaign panel hierarchy without changing content. | medium risk | Needs layout e2e and human browser review. |
| Add mandatory tutorial pop-ups. | blocked | Wait for a dedicated onboarding design gate. |

## Save Safety

| Item | Risk | Notes |
| --- | --- | --- |
| Add old-save fixture files for V1 and V2 migration tests. | medium risk | Valuable v0.5 gate, but fixtures need careful review. |
| Add a no-op current-save migration test fixture. | safe | Does not require version bump. |
| Document ID namespace rules for future nodes, rewards, items, rivals, and trophies. | safe | Planning only. |
| Bump save version for speculative future fields. | blocked | Only do this for a real schema change. |

## Documentation

| Item | Risk | Notes |
| --- | --- | --- |
| Keep `LLM_GAME_HANDOFF.md` current after every committed phase. | safe | Required continuation hygiene. |
| Cross-link v0.4 docs from `ROADMAP.md` and `RELEASE_CHECKLIST.md` during final handoff. | safe | Final Phase 11 task. |
| Add a short "what not to implement yet" block to future design docs. | safe | Reinforces scope boundaries. |
| Rewrite release docs around a new version label. | medium risk | Wait until the project actually moves beyond the frozen v0.3/v0.3.1 release framing. |

## Telemetry

| Item | Risk | Notes |
| --- | --- | --- |
| Preserve the 255-run simulator profile as the default structural read. | safe | Current telemetry is stable and generated with no tracked diff. |
| Add a separate human-review notes template for Cinderfen live play. | safe | Documentation only. |
| Add a route-feel telemetry summary for Fast Army, Greedy Economy, and retinue-heavy profiles. | safe | Derived reporting only if it reads existing telemetry. |
| Tune Fast Army or Retinue plus Training Yard II from simulator data alone. | blocked | Needs human feel review or a clear bug. |

## Future Content Planning

| Item | Risk | Notes |
| --- | --- | --- |
| Keep the v0.5 save/content-validation gate as the next recommended milestone. | safe | Planning only. |
| Draft original faction identity constraints before any faction implementation. | safe | No roster or mechanics yet. |
| Define a locked chapter shell policy for future chapters. | safe | Prevents missing-map launches. |
| Add new maps, units, workers, enemy construction, diplomacy, procedural maps, crafting, or multiplayer. | blocked | Outside v0.4 polish scope and explicitly postponed. |

## Recommended Next Use

Use this backlog only to choose tiny follow-up work after the full v0.4 verification gate is green. Safe items should still get focused verification. Medium-risk items need a short plan and targeted e2e. High-risk and blocked items should not be implemented inside v0.4 polish.

## Verification

Required for this phase:

```text
npm test
npm run build
```

Verification completed:

```text
npm test
PASS: 38 test files, 271 tests, 7.05s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-90WGArXv.js, 436.35 kB / gzip 117.34 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.
```
