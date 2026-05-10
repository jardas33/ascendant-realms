# v0.8.1 Visual Asset Manifest And Screenshot QA Report

Date: 2026-05-10  
Scope: visual asset inventory, metadata manifest, manifest validation, runtime asset cross-check, screenshot QA workflow, screenshot review, Cinderfen replacement backlog, and safe future asset prompt/spec templates.

## What Was Added

- Existing asset inventory audit: `docs/V081_EXISTING_ASSET_INVENTORY_AUDIT.md`.
- Typed visual asset manifest schema: `src/game/assets/VisualAssetManifestTypes.ts`.
- Initial 89-entry visual asset manifest: `src/game/assets/visualAssetManifest.ts`.
- Manifest documentation: `docs/V081_VISUAL_ASSET_MANIFEST_SCHEMA.md` and `docs/V081_INITIAL_VISUAL_ASSET_MANIFEST.md`.
- Visual asset metadata validation integrated into `npm run validate:content`.
- Runtime asset usage cross-check for current texture/icon/UI references.
- Optional screenshot QA harness: `npm run visual:qa`.
- Separate visual QA Playwright config: `playwright.visual-qa.config.ts`.
- Visual capture spec: `tests/visual-qa/visual-qa.spec.ts`.
- Ignored screenshot output folder: `/visual-qa/`.
- Screenshot QA plan and review docs.
- Cinderfen visual asset replacement backlog.
- Safe future asset prompt/spec templates.

## What Was Not Added

- No new art assets.
- No generated art.
- No downloaded web images.
- No external assets.
- No large binary assets.
- No graphics overhaul.
- No desktop packaging or engine switch.
- No new maps, units, factions, rewards, save changes, campaign progression, gameplay systems, workers, enemy construction, economy AI, live pressure action promotion, or broad BattleScene rewrite.
- No brittle pixel-perfect screenshot tests.

## Asset Manifest Summary

The visual asset manifest now tracks 89 entries:

- Current runtime assets from the existing asset manifest.
- Important manual-source originals.
- Procedural battle terrain as an explicit visual-debt entry.
- Future prompt/spec reference metadata.

The metadata is intentionally conservative. Most current assets are marked as placeholder, prototype, candidate, or reference material rather than final. Unknown source/license assets stay `needsReview: true` and `allowedInProduction: false`.

Important fields include:

- `currentStatus`
- `sourceType`
- `licenseStatus`
- `usage`
- `usedBy`
- `visualFamily`
- `scaleClass`
- `intendedWorldHeightPx`
- `currentRenderHeightPx`
- `silhouetteReadability`
- `styleConsistency`
- `replacementPriority`
- `allowedInProduction`
- `needsReview`

## Manifest Validation Summary

`npm run validate:content` now validates visual asset metadata in addition to gameplay content. Validation covers:

- Unique asset IDs.
- Valid enum fields.
- Runtime file paths.
- Safe runtime license/status rules.
- Unknown runtime-license review flags.
- Final asset source/license requirements.
- Positive scale metadata values.
- Non-empty runtime `usedBy`.
- Deprecated assets not being runtime assets.

The CLI checks file existence without bundling filesystem checks or visual metadata into the browser boot path.

## Runtime Asset Cross-Check

The runtime cross-check currently covers:

- `BATTLE_TEXTURE_ASSET_IDS`.
- All ability icons.
- UI-kit CSS variable assets.
- Free Marches emblem.
- Main menu, victory, and defeat backgrounds.

Result:

- All current explicit runtime visual asset ids are covered by `src/game/assets/visualAssetManifest.ts`.
- Procedural terrain remains represented by the `procedural_battle_terrain` metadata entry.
- Manual source originals remain manifest-tracked but are not treated as runtime dependencies.

## Screenshot QA Plan

`docs/V081_SCREENSHOT_QA_PLAN.md` defines screenshot QA as a review workflow rather than a pixel regression suite.

The plan defines:

- Core visual targets.
- Output folder and gitignore policy.
- Naming convention.
- Desktop/tablet/mobile viewports.
- Safe automated checks.
- Forbidden pixel-perfect checks.
- Manual review checklist.
- Asset manifest linkage.

## Screenshot Harness

The optional script is:

```bash
npm run visual:qa
```

It runs a dedicated Playwright capture suite outside the normal smoke and release lanes. It writes ignored artifacts to:

```text
visual-qa/latest/
```

Current captures:

- Main menu desktop/tablet/mobile.
- Tutorial launch.
- Campaign map.
- Skirmish setup.
- Cinderfen Crossing launch.
- Cinderfen Shrine captured.
- Cinderfen Watch launch.
- Cinderfen Watch pressure warning.

The script also writes an index at `visual-qa/latest/index.md` and records browser console errors.

## Screenshot Review

`docs/V081_SCREENSHOT_QA_REVIEW.md` documents the first capture review.

Findings:

- Main menu and campaign screens are readable and acceptable for prototype use.
- Tutorial overlay remains readable.
- Cinderfen battle views are tactically readable but visually rough.
- Cinder Shrine and Watch Road are readable mostly through rings, labels, icons, and status text rather than landmark art.
- Roads remain paint-like.
- Water/swamp remains blob-like.
- Unit/building style and scale remain inconsistent.
- HUD is functional and readable but not final.
- Pressure warning visibility is acceptable in the captured Watch screenshot.

Decision:

- No visual code, CSS, renderer, scale, terrain, UI, or asset change is justified by the first screenshot review.
- The visual debt is structural and should be addressed through manifest-backed asset work.

## Cinderfen Visual Replacement Backlog

`docs/CINDERFEN_VISUAL_ASSET_REPLACEMENT_BACKLOG.md` prioritizes future work:

Critical:

- Cinderfen terrain and road style.
- Water and swamp material.
- Cinder Shrine / capture-site landmark.
- Enemy stronghold / Ashen outpost identity.

High:

- Player hero scale and style.
- Militia and Ranger consistency.
- Enemy raider/brute/caster silhouettes.
- Minimap marker pass.

Medium:

- UI frame consistency.
- Health bars and labels.
- Capture-site labels.

Low:

- Decorative props.
- VFX polish.
- Portraits.

No replacements were implemented.

## Asset Prompt / Spec Templates

`docs/ASSET_PROMPT_TEMPLATES.md` provides safe future briefs for:

- Cinderfen terrain style frame.
- Cinderfen road/causeway tile.
- Cinder Shrine/capture-site concept.
- Ashen stronghold concept.
- Player hero concept.
- Militia concept.
- Ranger concept.
- Enemy raider concept.
- UI frame style.
- Resource icons.

Each template includes original-IP requirements, protected-IP avoidance, scale/readability requirements, output expectations, transparent-background guidance where relevant, camera notes, and metadata/license reminders.

No images were generated from these prompts.

## Remaining Risks

- Current visual quality remains prototype-level.
- Terrain and roads still lack material identity.
- Cinder Shrine and Watch Road are still too ring/icon/label-dependent.
- Unit and building source styles remain inconsistent.
- Most asset source/license statuses are still conservative and require review.
- Screenshot QA does not yet capture Results, Inventory, Asset Gallery, defeat tips, or mobile/tablet battle views.
- The visual QA script is optional and review-oriented; it is not a replacement for layout/e2e checks.
- Known Phaser vendor chunk warning remains.
- Full release e2e remains slow.

## Report Gate Verification

- `npm test`: PASS, 45 test files / 339 tests.
- `npm run build`: PASS with the known Phaser vendor large-chunk warning.
- `npm run validate:content`: PASS with visual asset metadata validation.
- `npm run test:e2e:smoke`: PASS, 12 Playwright tests.
- `npm run playtest:sim`: PASS, 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: PASS.

## Next Recommended Long Goal

Recommended: **v0.8.2 Visual Source/License Review and Screenshot Coverage Expansion**.

Safe first scope:

- Review source/license status for the highest-priority manifest entries.
- Add screenshot QA targets for Results, Inventory, Asset Gallery, defeat screen, and one mobile/tablet battle view.
- Keep all screenshots non-pixel-perfect.
- Do not add new art assets yet unless explicitly approved.

Alternative player-facing goal:

- Tutorial v2 onboarding refinement, if direct player experience should take priority over visual pipeline work.

Blocked until later:

- Cinderfen terrain replacement.
- Unit/building art replacement.
- Full UI redesign.
- Desktop graphics implementation.
- Engine switch.
