# v0.97 Visual QA Report

Status: passed.

## Added Coverage

v0.97 adds eight deterministic visual-QA screenshots:

- `v097-selected-hero-focus-1920.png`
- `v097-selected-worker-focus-1600.png`
- `v097-selected-squad-focus-1366.png`
- `v097-selected-building-focus-1920.png`
- `v097-enemy-inspection-focus-1366.png`
- `v097-command-markers-1600.png`
- `v097-reduced-motion-invalid-marker-1366.png`
- `v097-command-details-disclosure-1600.png`

## Acceptance

- Hero, Worker, squad, building, and enemy inspection states have distinct focus cards.
- Enemy inspection remains read-only and does not expose player behavior controls.
- Command markers are visible, concise, and not permanent clutter.
- Reduced-motion command feedback remains readable without animated flourish.
- Command-panel secondary text stays behind More Details.
- Existing campaign, Results, Lume, Tutorial, and battle-HUD screenshots still remain in the deterministic review set.

## Final Evidence

```text
npm run visual:qa - PASS, 13 tests / 118 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 118 screenshots / 7 contact sheets.
```

The final visual review pack is generated at `artifacts/visual-review/latest/` and includes the existing desktop viewport matrix plus the new v0.97 selection, command-marker, reduced-motion, and command-disclosure states.
