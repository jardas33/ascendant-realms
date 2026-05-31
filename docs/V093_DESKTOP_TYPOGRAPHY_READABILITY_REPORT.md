# v0.93 Desktop Typography Readability Report

Checkpoint: v0.93 Runtime UI Foundation Tokens and Mission-Panel State Reset

## Scope

This pass improves baseline text readability across the existing browser prototype UI without changing game rules or information architecture.

Surfaces touched:

- main menu shell;
- hero creation and character forms;
- campaign map and selected mission panel;
- campaign tab cards;
- Results overview and full-details disclosure;
- battle HUD objective tracker;
- right-side command/selection panel;
- hero inventory/progression copy.

## Changes

- Added fixed typography tokens for headings, body, compact body, captions, and HUD numerics.
- Removed viewport-width font scaling from the updated campaign/inventory/results surfaces.
- Raised campaign selected-mission body and fact rows to readable body/compact-body token sizes.
- Raised key HUD tracker and command-panel labels to tokenized compact/caption sizes.
- Kept node metadata dense but prevented tiny paragraph-style prose.
- Preserved compact RTS layout by improving line-height and token hierarchy rather than adding large new panels.

## Desktop Acceptance

The v0.93 regression targets `1366x768` because it is the most constrained desktop viewport in the current acceptance matrix. Existing v0.90 coverage continues to cover `1600x900` and `1920x1080`.

Readable-body assertions now guard selected mission text, fact rows, and campaign node title text in the Salto reset path.

## Constraints Preserved

- No mobile-like bottom-sheet or oversized card redesign.
- No giant dashboard expansion.
- No final art, generated images, runtime assets, or imported icons.
- No save, reward, campaign progression, stable-ID, or gameplay changes.

## Verification

Verified in:

- `npm run build` - PASS with the known Vite Phaser vendor chunk-size warning.
- `npm run test:e2e:smoke:fast` - PASS, 9 tests.
- `npm run test:e2e:smoke` - PASS, 16 tests.
- `npm run test:e2e:release:hosted:layout-core` - PASS, 26 tests.
- `npm run test:e2e:release:hosted:layout-cinderfen` - PASS, 12 tests.
- `npm run visual:qa` - PASS, 9 tests / 65 screenshots / 0 console errors / 0 retries.

The v0.93 Salto layout regression asserts readable selected-mission copy at `1366x768`, no horizontal overflow, no text clipping in key campaign cards, and no nested-card clutter.
