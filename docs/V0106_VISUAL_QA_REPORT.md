# v0.106 Visual QA Report

Status: visual QA and visual review-pack generation passed on 2026-06-02.

## Added Coverage

v0.106 adds 14 screenshots to the deterministic visual QA set, raising the expected matrix from 189 to 203 screenshots.

The new group is `v0106-runtime-art-slot-fallbacks`.

It covers:

- Public posture hides runtime art slot diagnostics.
- Private diagnostics off.
- Private diagnostics on.
- Diagnostics readability at 1366x768, 1600x900, and 1920x1080.
- Main menu fallback.
- Campaign fallback.
- Battlefield terrain/fog/minimap/capture fallback.
- Unit fallback.
- Building fallback.
- Lume fallback.
- HUD fallback.
- Results fallback.
- Private mock routing mode.

## Review Pack

The visual review pack now has an `Art Slot Fallbacks` screen family and focused contact sheet.

Final results:

```text
npm run visual:qa - PASS, 203 screenshots, 0 console errors, 0 retries.
npm run visual:review-pack - PASS, 203 screenshots and 8 contact sheets.
```

## Boundary

These screenshots prove fallback posture and private diagnostics. They are not approval of generated art, final art, or runtime asset replacement.
