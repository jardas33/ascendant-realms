# v0.93 Visual QA Report

Checkpoint: v0.93 Runtime UI Foundation Tokens and Mission-Panel State Reset

## Added Visual QA Coverage

The visual-QA campaign desktop matrix now includes:

- `v093-salto-panel-reset-1366.png`

The capture verifies the visible result of:

1. opening the locked Aether Well Ruins preview;
2. expanding and scrolling its details;
3. reselecting Salto Outskirts;
4. confirming Salto returns with `More Details` collapsed and the primary action visible.

## Existing Coverage Preserved

The expanded v0.90 visual matrix still covers:

- main menu at `1920x1080`, `1600x900`, and `1366x768`;
- fresh campaign map;
- selected unlocked mission;
- selected locked mission;
- all campaign tabs;
- battle HUD states;
- Lume states;
- private-demo Results;
- normal Victory/Defeat/Replay Results;
- Tutorial.

## Review Notes

- The new runtime token layer makes panel hierarchy and body copy more consistent, but this remains a foundation pass, not a full visual redesign.
- Lume teal is intentionally sparse.
- Campaign shell still uses placeholder-safe browser prototype styling; final art is still deferred behind the visual intake gate.

## Verification

```text
npm run visual:qa - PASS, 9 tests / 65 screenshots / 0 browser console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 65 screenshots / 7 contact sheets.
```

Visual review-pack artifact:

```text
artifacts/visual-review/latest/
```

Non-pass evidence: the first visual-QA run successfully captured all 65 screenshots with 0 console errors and 0 retries, but the harness still asserted the previous 64-screenshot count. The deterministic expected count was updated to 65, and the rerun passed.
