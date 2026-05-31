# v0.92 Implementation Report

Checkpoint: v0.92 Visual Review Pack Generator and Unified Emmanuel Retest Packet

## Summary

v0.92 adds a deterministic visual review-pack generator and a unified Emmanuel retest packet. It converts the existing `visual-qa/latest/` screenshot output plus the v0.90 visual-regression manifest into a static local artifact for fast human review.

## Added

- `src/game/playtest/VisualReviewPack.ts`
- `src/game/playtest/VisualReviewPack.test.ts`
- `tools/generateVisualReviewPack.ts`
- `docs/V092_VISUAL_REVIEW_PACK_SPEC.md`
- `docs/V092_CONTACT_SHEET_INDEX.md`
- `docs/V092_EMMANUEL_UNIFIED_RETEST_PACKET.md`
- `docs/V092_IMPLEMENTATION_REPORT.md`

## Changed

- Added `npm run visual:review-pack`.
- Added `/artifacts/visual-review/` to `.gitignore`.
- Updated roadmap, handoff, checkpoint, changelog, and release checklist for the v0.92 QA tooling boundary.

## Runtime Changed

No runtime gameplay or UI behavior changed. The generator is a local QA artifact tool and does not run in the game.

## Save Format

No save-version bump. No save fields, localStorage keys, stable IDs, serialized IDs, rewards, XP, campaign state, settings, or package metadata changed.

## Visual Review Pack

Generated artifact:

```text
artifacts/visual-review/latest/
```

Current generated contents:

- `index.html`
- `review-manifest.json`
- `README.md`
- 64 copied screenshots under `screenshots/`
- 7 contact sheets under `contact-sheets/`

Contact sheets:

- 1920x1080: 16 screenshots
- 1600x900: 13 screenshots
- 1366x768: 16 screenshots
- Campaign shell: 21 screenshots
- Battle shell: 11 screenshots
- Lume flow: 14 screenshots
- Results flow: 10 screenshots

## Tests

Added generator tests for:

- deterministic output,
- manifest-to-file mapping,
- missing screenshots failing clearly,
- duplicate screenshot IDs failing clearly,
- required screen groups in HTML,
- contact sheet generation,
- target viewport coverage,
- source screenshots remaining unchanged.

## Verification

```text
npx vitest run src/game/playtest/VisualReviewPack.test.ts - PASS, 1 file / 5 tests.
npm test - PASS, 93 files / 683 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run visual:qa - PASS, 9 tests / 64 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS after visual:qa, 64 screenshots / 7 contact sheets.
git diff --check - PASS.
```

Package validation is not required unless package metadata changes. v0.92 does not change package metadata.

Non-pass evidence: the first build attempt caught a TypeScript narrowing issue in the new contact-sheet screen-family filter. The generator type was tightened before final verification, and the final build plus full test suite passed.

## Deferred

- No screenshot auto-approval workflow.
- No image-diff baseline system.
- No new game screenshots beyond the existing visual-QA harness.
- No art generation or imported assets.
- No v0.93.
