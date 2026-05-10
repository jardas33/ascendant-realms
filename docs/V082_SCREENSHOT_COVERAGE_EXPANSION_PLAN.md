# v0.8.2 Screenshot Coverage Expansion Plan

Date: 2026-05-10  
Status: Phase 5 planning document. Phase 6 may extend the optional `npm run visual:qa` harness from this plan.

## Purpose

v0.8.1 proved that Ascendant Realms can capture repeatable visual review screenshots without committing screenshot binaries or creating brittle pixel-perfect tests. The first harness captured core menu, tutorial, campaign, skirmish, and Cinderfen battle views. This phase plans the next coverage step before editing the harness.

The goal is broader review evidence, not visual approval. Captures should make future art, UI, scale, and source/license review more concrete while preserving the current rule: screenshots are ignored review artifacts and should not fail because pixels differ.

## Non-Goals

- No new art assets.
- No generated art.
- No downloaded, external, or unlicensed images.
- No gameplay, map, unit, faction, reward, save, campaign progression, pressure behavior, or balance changes.
- No full UI redesign.
- No renderer overhaul.
- No pixel-perfect screenshot assertions.
- No committed screenshot binaries.

## Current v0.8.1 Baseline

Current `npm run visual:qa` captures 10 screenshots:

1. Main menu desktop.
2. Main menu tablet.
3. Main menu mobile.
4. Tutorial desktop.
5. Campaign map desktop.
6. Skirmish setup desktop.
7. Cinderfen Crossing launch desktop.
8. Cinderfen Crossing shrine captured desktop.
9. Cinderfen Watch launch desktop.
10. Cinderfen Watch pressure warning desktop.

Known gaps from `docs/V081_SCREENSHOT_QA_REVIEW.md`:

- Results screen.
- Defeat screen and defeat tips.
- Hero Inventory.
- Asset Gallery.
- Mobile/tablet battle HUD.
- Tutorial mobile overlay.
- Campaign route-complete state.
- Wider pressure-warning coverage.

## Expansion Target Matrix

| Target | Value | Feasibility | Data seeding required | Likely helper needed | Visual QA fit | Brittleness risk | Screenshot name | Viewport |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Results victory screen | Captures rewards, objective summary, retinue/hero progression density, and victory frame assets. | High if existing Chapter 2 victory fast-forward helper can transition to Results. | Seed post-Ashen or post-Crossing campaign and use existing test victory hook. | Existing Chapter 2 helper or small visual-only wrapper around existing victory fast-forward. | Yes. High-value gap. | Medium. Results content can vary by seeded node/reward state, so capture should use stable seeded battle and semantic waits. | `results-victory-desktop.png` | 1440x900 desktop |
| Results defeat screen | Captures defeat frame, retry/campaign return affordances, and defeat tips. | Medium. Feasible if a test defeat hook or direct Results scene data path already exists; otherwise skip for now. | Seed a battle and trigger existing defeat path, or use a stable existing scene transition if available. | Existing defeat/timeout helper if present; avoid inventing new gameplay hooks. | Yes if stable. | Medium-high. Real defeat can be slow; direct scene setup may be too artificial if unsupported. | `results-defeat-desktop.png` | 1440x900 desktop |
| Hero Inventory screen | Captures RPG equipment/stat readability and inventory frame assets. | High. Main-menu Inventory is in the manual QA checklist and likely reachable with existing selectors. | Fresh menu or seeded save with hero data. | Existing shared helper if available; otherwise normal menu click plus hero creation/save seed. | Yes. High-value UI/asset gap. | Low-medium. Empty or low-item inventory is still useful, but reward item state can vary. | `hero-inventory-desktop.png` | 1440x900 desktop |
| Asset Gallery screen | Captures all current runtime/manual visual asset presentation and broken-image risk. | High. Existing menu/manual QA checklist names Asset Gallery. | None beyond main menu. | Simple menu click. | Yes. Critical for manifest/source review. | Low. It should be a static review surface. | `asset-gallery-desktop.png` | 1440x900 desktop |
| Cinderfen Crossing pressure-warning moment | Captures Crossing-specific warning/status competition after Cinder Shrine. | Medium. Shrine capture is already captured; delayed pressure needs a stable pressure tick like Watch. | Seed post-Ashen, launch Crossing, capture `cinder_crossing`, tick pressure runtime if supported. | Existing `centerCaptureSite` plus a Crossing pressure trigger helper. | Yes if stable. | Medium. Timing/status priority can be fragile if warning text changes; wait for data-testid plus substring only. | `cinderfen-crossing-pressure-desktop.png` | 1440x900 desktop |
| Cinderfen Watch pressure-warning moment | Already captured in v0.8.1; retain and maybe add tablet/mobile later. | High. Existing helper triggers it. | Seed post-Crossing and capture `watch_road_toll`. | Existing `triggerWatchPressureWarning`. | Yes. Keep as baseline. | Low-medium. Copy changes require updating substring wait. | `cinderfen-watch-pressure-desktop.png` | 1440x900 desktop |
| Mobile portrait main menu | Already captured in v0.8.1; retain to protect first-screen crop and scroll. | High. Existing harness covers it. | None. | Existing viewport helper. | Yes. Keep as baseline. | Low. | `main-menu-mobile.png` | 390x844 mobile |
| Mobile/tablet battle HUD | Captures density of resources, objectives, minimap, selected panel, and battle status under constrained width. | High for launch-state battle; medium for pressure-state battle. | Seed tutorial or Cinderfen launch. | Existing battle launch helper plus viewport switch. | Yes. Major current gap. | Medium. Mobile battle UI may require scroll/crop review; do not assert exact layout. | `cinderfen-crossing-tablet.png` or `tutorial-mobile.png` | 1024x768 tablet or 390x844 mobile |
| Tutorial mobile overlay | Captures onboarding overlay readability and battle HUD interaction on narrow viewport. | High. Tutorial launch is already stable. | None beyond menu launch. | Existing tutorial launch sequence. | Yes. Important because tutorial overlay could crowd mobile HUD. | Low-medium. Text wrapping can vary but should not be pixel-asserted. | `tutorial-mobile.png` | 390x844 mobile |
| Campaign route-complete state | Captures completed route/campaign-map density after Cinderfen progression. | Medium. Existing seeds may be able to mark Cinderfen Watch/Aftermath complete. | Seed route-complete campaign if helper exists; otherwise document gap. | Existing campaign seed extension if already present. | Yes if cheap. | Medium. Broad save seeding can become opaque; prefer current helpers. | `campaign-route-complete-desktop.png` | 1440x900 desktop |
| Defeat tips screen/state | Captures practical player guidance and defeat-copy density. | Medium. Same feasibility as Results defeat. | Stable defeat/timeout or direct supported Results scene setup. | Existing battle loss helper if present. | Yes if stable. | Medium-high if it needs long combat. | `results-defeat-tips-desktop.png` | 1440x900 desktop |
| Skirmish Setup | Already captured in v0.8.1; retain as a non-campaign menu surface. | High. Existing harness covers it. | None beyond main menu and hero creation. | Existing shared helper. | Yes. Keep as baseline. | Low. | `skirmish-setup-desktop.png` | 1440x900 desktop |

## Recommended Phase 6 Scope

Add only the safest coverage that broadens evidence without increasing fragility. Recommended first additions:

1. Asset Gallery desktop.
2. Hero Inventory desktop.
3. Tutorial mobile overlay.
4. One tablet battle HUD view, preferably Cinderfen Crossing launch.
5. Results victory desktop if an existing victory helper can reach it cleanly.
6. Results defeat or defeat tips only if an existing stable helper exists.
7. Cinderfen Crossing pressure warning only if it can reuse the current pressure runtime hook pattern.

Keep the current 10 captures unless they become redundant. The expanded harness should still be one optional Playwright visual QA test or a small set of optional visual QA tests under the existing config.

## Targets To Skip If They Need New Hooks

Skip these in Phase 6 if existing helpers do not already support them:

- Results defeat.
- Defeat tips.
- Campaign route-complete state.
- Pressure warnings that require full human-paced combat.

Skipping is acceptable if the generated index and Phase 7 review document the gap. Do not add new gameplay hooks purely for screenshot convenience.

## Safe Automated Checks

The expanded harness may continue to assert:

- The expected screen root or battle HUD is visible.
- The expected semantic text or data-testid appears.
- Browser console errors are zero.
- Screenshots are written under `visual-qa/latest/`.

The expanded harness must not assert:

- Exact pixels.
- Exact colors.
- Exact sprite positions.
- Exact animation frames.
- Exact fog shapes.
- Exact image dimensions inside panels unless a real layout bug is being tested elsewhere.

## Review Linkage

Phase 7 should link expanded screenshots back to:

- `src/game/assets/visualAssetManifest.ts`
- `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`
- `docs/V082_MANIFEST_METADATA_REFINEMENT.md`
- `docs/V081_SCREENSHOT_QA_REVIEW.md`
- `docs/V08_VISUAL_DEBT_AUDIT.md`
- `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`
- `docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md`
- `docs/CINDERFEN_VISUAL_REWORK_SPEC.md`

## Decision

Proceed to Phase 6 with an optional screenshot QA harness expansion only. The first implementation should prefer stable, already-reachable screens over ambitious seeded states, and it should treat skipped targets as documented coverage gaps rather than failures.

## Phase 6 Implemented Scope

Phase 6 extends the optional `npm run visual:qa` harness with the safest planned targets:

- Asset Gallery desktop.
- Hero Inventory desktop.
- Tutorial mobile overlay.
- Completed Cinderfen route campaign map.
- Cinderfen Crossing tablet battle HUD.
- Cinderfen Crossing pressure warning.
- Cinderfen Crossing victory Results.
- Cinderfen Watch defeat Results and defeat tips.

The harness still writes ignored review artifacts under `visual-qa/latest/`, still avoids pixel comparisons, and still uses existing Playwright-only helpers rather than adding production gameplay hooks.
