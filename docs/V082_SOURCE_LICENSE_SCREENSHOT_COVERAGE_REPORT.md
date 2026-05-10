# v0.8.2 Source/License and Screenshot Coverage Report

Date: 2026-05-10  
Status: release report for the v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion gate.

## 1. What Was Added

v0.8.2 hardens the visual pipeline without adding art or gameplay. It adds:

- Asset source/license review plan.
- Asset source/license audit.
- Conservative manifest metadata refinements with `reviewStatus` and `sourceReviewNotes`.
- Stronger visual asset validation.
- Screenshot coverage expansion plan.
- Expanded optional `npm run visual:qa` capture set.
- Extended screenshot QA review.
- Living visual risk register.
- v0.9 controlled visual sprint brief.

## 2. What Was Not Added

This checkpoint does not add:

- new art assets,
- generated images,
- external/downloaded assets,
- large binaries,
- graphics overhaul,
- UI redesign,
- gameplay content,
- maps,
- units,
- factions,
- rewards,
- save-version changes,
- campaign progression changes,
- pressure action promotion,
- workers,
- enemy construction,
- economy AI,
- desktop packaging,
- engine switching,
- pixel-perfect screenshot tests.

## 3. Source/License Review Plan

Added `docs/V082_ASSET_SOURCE_LICENSE_REVIEW_PLAN.md`.

The plan defines:

- review asset classes,
- review statuses,
- required evidence,
- Codex do/don't rules,
- policy that unknown-source assets are not production-safe,
- policy that reference-only assets cannot become runtime assets,
- policy that final production status requires source/license confidence.

## 4. Source/License Audit

Added `docs/V082_ASSET_SOURCE_LICENSE_AUDIT.md`.

Current manifest read:

- 89 visual asset entries.
- 87 entries use `sourceType: "manual"`.
- 2 entries use `sourceType: "original"`.
- 87 entries have `licenseStatus: "unknown"`.
- 2 entries have `licenseStatus: "owned"`.
- 59 runtime image assets have unknown license.
- All runtime entries have `needsReview: true`.
- No current image asset is marked production-approved.

Important conclusion: the folder name `final` is a runtime priority path, not proof that an asset is legally or visually final.

## 5. Manifest Metadata Refinements

Updated:

- `src/game/assets/VisualAssetManifestTypes.ts`
- `src/game/assets/visualAssetManifest.ts`
- `src/game/data/validation/validateVisualAssets.ts`
- `src/game/data/contentValidation.test.ts`
- `docs/V081_VISUAL_ASSET_MANIFEST_SCHEMA.md`
- `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`
- `CONTENT_GUIDE.md`

New metadata:

- `reviewStatus`
- `sourceReviewNotes`

Current posture:

- current file-backed image assets remain `needs-source-proof`,
- procedural battle terrain is owned/original but still placeholder and production-blocking,
- no image asset is approved for production,
- unknown-source runtime art remains `needsReview: true` and `allowedInProduction: false`.

## 6. Manifest Validation Hardening

Validation now makes unsafe ambiguity harder to miss:

- Runtime assets cannot use `reference-only` or `do-not-ship` review status.
- Final assets must be production-allowed.
- Candidate assets with unknown source/license must remain review-needed.
- Production-allowed assets require owned/licensed rights and known non-reference source.
- Approved-for-production assets require safe source/license metadata.
- Deprecated assets cannot be runtime.
- Critical replacement assets need notes.
- Every manifest entry needs source-review notes.

Validation still allows honest prototype unknowns so the current browser prototype remains runnable.

## 7. Screenshot Coverage Expansion

Added `docs/V082_SCREENSHOT_COVERAGE_EXPANSION_PLAN.md` and extended `tests/visual-qa/visual-qa.spec.ts`.

The optional visual QA lane now captures 18 indexed screenshots:

1. Main menu desktop.
2. Asset Gallery desktop.
3. Main menu tablet.
4. Main menu mobile.
5. Hero Inventory desktop.
6. Tutorial desktop.
7. Tutorial mobile.
8. Campaign map desktop.
9. Campaign route-complete desktop.
10. Skirmish setup desktop.
11. Cinderfen Crossing desktop.
12. Cinderfen Crossing tablet.
13. Cinderfen Shrine captured desktop.
14. Cinderfen Crossing pressure warning desktop.
15. Results victory desktop.
16. Cinderfen Watch desktop.
17. Cinderfen Watch pressure warning desktop.
18. Results defeat desktop.

The lane remains optional, ignored-output, non-pixel-perfect, and review-oriented.

## 8. Extended Screenshot Review

Added `docs/V082_EXTENDED_SCREENSHOT_QA_REVIEW.md`.

Review findings:

- 18 screenshots captured.
- 0 browser console errors recorded.
- Main menu, campaign map, tutorial, battle HUD, Cinderfen pressure, Results, Inventory, and Asset Gallery all launch and render.
- Current visuals are still prototype-level.
- Cinderfen terrain/road/water material identity remains the largest visual debt.
- Capture sites still depend on rings/icons/labels.
- Mobile tutorial/battle HUD density is a real watchpoint.
- Results, Inventory, and Asset Gallery are readable but dense.
- No visual code/CSS/renderer/asset change is justified by the review.

## 9. Visual Risk Register

Added `docs/VISUAL_RISK_REGISTER.md`.

Tracked risks:

- unknown source/license runtime assets,
- placeholder assets mistaken for final,
- style mismatch,
- scale mismatch,
- capture-site ring/icon dependence,
- text-heavy HUD identity,
- mobile battle HUD density,
- minimap readability,
- Cinderfen terrain material ambiguity,
- over-reliance on generated art later,
- IP contamination from references,
- large binary asset bloat,
- future desktop/engine migration asset mismatch,
- screenshot QA becoming ignored or stale.

## 10. v0.9 Visual Sprint Recommendation

Added `docs/V09_CONTROLLED_VISUAL_SPRINT_BRIEF.md`.

Compared options:

- Option A: Cinderfen style-frame sprint.
- Option B: prototype terrain readability pass.
- Option C: unit/building scale normalization pass.
- Option D: UI/HUD visual consistency pass.

Recommendation: Option A first.

The first v0.9 visual step should be a Cinderfen style-frame packet with prompts/specs only:

- terrain material sheet,
- Cinder Shrine/capture-site landmark sheet,
- Ashen outpost architecture sheet.

No generated image or runtime replacement should be part of that first step.

## 11. Remaining Risks

- Current visuals remain prototype-level.
- 59 runtime image assets still have unknown license.
- No current file-backed image asset is production-approved.
- Screenshot QA output can contain older ignored artifacts; generated `index.md` is the source of truth.
- Mobile battle HUD density needs future review.
- Future art replacement still needs source/license confirmation, manifest updates, validation, and before/after screenshot QA.
- Known Phaser vendor chunk warning remains.
- Full release e2e remains slow.

## 12. Next Recommended Long Goal

Recommended next goal: v0.9 Controlled Cinderfen Style-Frame Sprint.

Scope:

- docs/specs/prompts only,
- no generated art committed,
- no runtime asset replacement,
- no graphics overhaul,
- no gameplay expansion,
- original-IP safe direction for Cinderfen terrain, capture sites, and Ashen outpost architecture.

Safer player-facing alternative: Tutorial v2 onboarding refinement.
