# v0.96 Visual QA Report

Status: final local visual QA passed.

## Added Coverage

- Tutorial onboarding presenter at 1920x1080, 1600x900, and 1366x768.
- Tutorial More Help and dismissed/reopen states.
- Campaign Salto first-step recommendation and compact help card.
- Battle HUD help surface.
- Results safety through existing ordinary and Tutorial Results captures.

## Acceptance

- Tutorial shows one primary step by default.
- More Help is collapsed by default and keyboard reachable.
- Dismiss/Reopen remains visible and does not remove player control.
- Focus Objective is a player-initiated camera assist.
- No Lume controls appear in Tutorial.
- No campaign or Results primary action requires scrolling at the target desktop viewports.

## Final Evidence

```text
npm run visual:qa - PASS, 12 tests / 110 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 110 screenshots / 7 contact sheets.
```

v0.96 added eight first-session screenshots:

- `v096-tutorial-first-objective-1920.png`
- `v096-tutorial-first-objective-1600.png`
- `v096-tutorial-first-objective-1366.png`
- `v096-tutorial-more-help-1600.png`
- `v096-tutorial-dismissed-1600.png`
- `v096-campaign-onboarding-1920.png`
- `v096-campaign-onboarding-1366.png`
- `v096-campaign-quick-help-1600.png`

The final review pack was generated at `artifacts/visual-review/latest/` with seven contact sheets.
