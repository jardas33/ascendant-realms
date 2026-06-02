# v0.105 Implementation Report

Status: implemented and verified locally.

## Summary

v0.105 adds a deterministic visual asset registry, ignored candidate-review workspace tooling, strict art-review validation, SVG contact-sheet generation, deterministic report generation, and first-generation review docs.

It does not generate images, import art, touch runtime asset paths, change gameplay, change saves, rename IDs, change runtime title, add desktop work, choose an engine, or start v0.106.

## Added

- `src/game/art/visual-asset-registry.schema.json`
- `src/game/art/visual-asset-registry.json`
- `src/game/art/VisualAssetReviewRegistry.ts`
- `src/game/art/VisualAssetReviewRegistry.test.ts`
- `tools/art-review/shared.ts`
- `tools/art-review/initArtReviewWorkspace.ts`
- `tools/art-review/validateArtReview.ts`
- `tools/art-review/generateArtReviewContactSheet.ts`
- `tools/art-review/generateArtReviewReport.ts`
- `tools/art-review/artReviewTools.test.ts`
- `npm run art:review:init`
- `npm run art:review:validate`
- `npm run art:review:contact-sheet`
- `npm run art:review:report`

## Registry

The registry is seeded from `docs/V088_VERTICAL_SLICE_ASSET_MANIFEST.json`, preserves every v0.88 asset ID, sorts entries by `assetId`, and keeps every entry `not-created`, `not-approved`, and `not-ready-reference-only`.

## Workspace

Ignored workspace roots:

- `artifacts/art-review/candidates/`
- `artifacts/art-review/contact-sheets/`
- `artifacts/art-review/reports/`

The workspace tooling creates templates only under those roots and never writes to `public/assets/` or `src/game/assets/`.

## Validation

The new validation rejects missing v0.88 assets, duplicate asset IDs, missing prompt versions, unclear license terms, missing protected-IP assessments, style-approved runtime posture, and runtime-integrated candidates without future integration proof.

## Verification

```text
npm test -- VisualAssetReviewRegistry artReviewTools - PASS, 2 files / 16 tests.
npm test - PASS, 107 files / 752 tests.
npm run build - PASS with the known Phaser/vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run art:review:validate - PASS, committed registry and schema checked.
git diff --check - PASS.
```
