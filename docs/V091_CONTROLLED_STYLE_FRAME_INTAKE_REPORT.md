# v0.9.1 Controlled Style-Frame Intake Report

Date: 2026-05-10

Status: safe non-runtime intake pipeline milestone. No generated art, imported art, downloaded art, scraped images, large candidate binaries, runtime asset replacement, gameplay change, map change, save change, engine change, or production approval was added.

## What Was Added

v0.9.1 adds the intake structure that future Cinderfen style-frame candidates must pass through before any runtime work is considered:

- Controlled intake protocol.
- Non-runtime `art-review/` folder structure.
- Source/license metadata templates.
- Review manifest schema and tooling-only TypeScript types.
- Metadata-only `npm run validate:art-intake` validation.
- Current candidate scan report.
- Screenshot comparison plan.
- Manual preparation guide for Emmanuel.
- Future v0.9.2 review goal brief.

## What Was Not Added

This milestone did not add:

- Generated images.
- Image API calls.
- Downloaded or scraped images.
- Unlicensed web art.
- Candidate image binaries.
- Runtime asset imports.
- Runtime visual asset manifest entries for new candidates.
- Runtime visual replacement.
- Gameplay, maps, units, factions, rewards, campaign progression, save-version changes, workers, construction, economy AI, procedural generation, crafting, multiplayer, desktop packaging, or engine switching.
- Production approval for any unknown-source asset.

## Intake Protocol Summary

`docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md` defines what counts as a style-frame candidate, what sources are allowed, what sources are forbidden, required metadata before commit, review stages, human review checks, and Codex responsibilities.

Important rules:

- Unknown source means not production-safe.
- A style frame is not runtime art.
- No image goes runtime without metadata, manifest validation, screenshot QA, and human approval.
- Codex may validate and document candidates, but must not generate, download, import, or wire art in this goal.

## Non-Runtime Folder Structure

`art-review/` is a review-only workspace. The Cinderfen intake area is:

```text
art-review/cinderfen-style-frames/
  inbox/
  metadata/
  reviewed/
  rejected/
```

README files explain that this tree is not loaded by the game. Raw candidate binaries in inbox/reviewed/rejected are ignored by default, while metadata/templates remain trackable.

## Source/License Metadata Forms

Reusable metadata forms live in:

- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.md`
- `art-review/cinderfen-style-frames/metadata/CANDIDATE_METADATA_TEMPLATE.json`

`docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md` explains required fields for source, creator/tool, date, license/ownership, usage permission, generation prompt, post-processing notes, intended use, protected-IP risk, review status, and production approval status.

## Candidate Review Manifest Schema

`docs/V091_STYLE_FRAME_REVIEW_MANIFEST_SCHEMA.md` defines the future review manifest shape for non-runtime candidates.

`tools/art-intake/StyleFrameReviewManifestTypes.ts` provides tooling-only TypeScript types. These are separate from `src/game/assets/visualAssetManifest.ts` and are not bundled into runtime gameplay.

The schema covers:

- Candidate metadata and file paths.
- Category and review stage.
- Source/license/IP-risk status.
- Visual, readability, and scale scores.
- Cinderfen pillar fit.
- Screenshot targets.
- Replacement targets as future-only context.
- Allowed next step.

## Intake Validation Summary

`npm run validate:art-intake` runs `tools/art-intake/validateArtIntake.ts` and validates metadata JSON under `art-review/cinderfen-style-frames/metadata/`.

It currently checks:

- Missing `candidateId`.
- Missing `sourceType`.
- Unknown source cannot be production-approved.
- Unknown or blocked license cannot be production-approved.
- High or unknown protected-IP risk cannot be approved.
- `approved-for-runtime-test` requires source/license fields.
- Rejected candidates need `reasonForRejection`.
- Missing related spec docs are warnings.
- Candidate image file existence is required only when metadata marks a candidate as submitted.

The gate passes with an empty intake and does not require image files before candidates exist.

## Candidate Scan Result

`docs/V091_CURRENT_STYLE_FRAME_CANDIDATE_SCAN.md` records the current scan:

- Inbox images: 0.
- Reviewed images: 0.
- Rejected images: 0.
- Candidate-specific metadata files: 0.
- Templates present: 2.
- Existing `public/assets/manual/` images: 62, not treated as style-frame candidates.
- Existing `public/assets/final/` images: 25, not treated as style-frame candidates.

Result: no candidate style frames currently available; intake pipeline is ready.

Nothing is eligible for candidate review or runtime use yet.

## Screenshot Comparison Plan

`docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md` maps future candidate review to the existing visual QA screenshot set:

- Main menu.
- Campaign map.
- Cinderfen Crossing desktop/tablet.
- Cinder Shrine capture.
- Cinderfen pressure warnings.
- Cinderfen Watch defeat.
- Results.
- Inventory.
- Asset Gallery.

The plan requires side-by-side human review and explicitly rejects pixel-perfect screenshot diffing as the approval method.

## Manual Preparation Guide

`docs/V091_MANUAL_STYLE_FRAME_PREPARATION_GUIDE.md` tells Emmanuel how to prepare the first future candidate batch outside Codex:

- One Cinderfen terrain style frame.
- One Cinder Shrine landmark sheet.
- One Ashen outpost architecture sheet.
- 1 to 3 images per category.
- PNG preferred.
- Transparent background where useful for landmarks/icons/cutouts.
- Complete metadata before asking for review.
- Avoid copyrighted screenshots, Warcraft/Warlords lookalikes, unlicensed web images, and unclear-source outputs.

## Future v0.9.2 Goal Brief

`docs/V092_STYLE_FRAME_REVIEW_GOAL_BRIEF.md` defines the next future goal after Emmanuel provides actual candidate images.

It instructs the next pass to inspect candidates, validate metadata, reject unsafe files, catalogue safe non-runtime candidates, update a review manifest, run screenshot QA, create a side-by-side review document, and choose at most one future runtime-test candidate without replacing runtime art.

## Remaining Risks

- Current visuals remain prototype-level.
- 59 runtime image assets still need source/license proof.
- No file-backed image asset is production-approved.
- Future candidate images can still introduce source/license/IP risk if metadata is incomplete.
- Screenshot QA remains human-reviewed and non-pixel-perfect.
- Candidate binaries are ignored by default and need deliberate approval before commit.
- The known Phaser vendor chunk-size warning remains.
- Full Playwright release lanes remain slow.

## Next Recommended Long Goal

Recommended next long goal: v0.9.2 Controlled Cinderfen Style-Frame Candidate Review, but only after Emmanuel provides 1 to 3 source/license-documented candidate images per first-priority category.

The future goal should keep all candidates non-runtime, reject unsafe or unknown-source art, catalogue only safe candidates, run `npm run validate:art-intake`, run `npm run visual:qa`, produce a side-by-side human review, and recommend at most one later runtime-test candidate. Runtime replacement should remain a separate explicit goal.
