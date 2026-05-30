# v0.83 Visual QA Report

## Purpose

v0.83 visual QA checks that the campaign map rescue is visible at common desktop playtest sizes and that the private Aether Well Lume demo is clearly labeled as a no-save playtest path.

## Required Captures

- Campaign Map at 1920x1080.
- Campaign Map at 1366x768.
- Locked Aether Well selected at 1920x1080.
- Support tab layout at 1366x768.
- Private playtest launch tools at 1920x1080.
- Private Lume demo HUD at 1920x1080.
- Private Lume demo with Linked Ward active at 1920x1080.
- Private Lume demo HUD at 1366x768.

## Acceptance Notes

- The map should be visible immediately on campaign entry.
- Node cards should not visibly overlap.
- The selected-node panel should show a concise summary and primary action.
- Support content should be reachable through tabs instead of pushing the map below the fold.
- The private demo should clearly say rewards and campaign progress are disabled.

## Verification

`npm run visual:qa` passed with 6 Playwright tests, 26 screenshots, 0 browser console errors, and 0 screenshot retries.

The v0.83 screenshot group wrote these eight additional captures under `visual-qa/latest`:

- `v083-campaign-map-1920.png`
- `v083-campaign-map-1366.png`
- `v083-aether-well-locked-1920.png`
- `v083-stronghold-tab-1366.png`
- `v083-private-playtest-tools-1920.png`
- `v083-private-lume-hud-1920.png`
- `v083-private-lume-active-1920.png`
- `v083-private-lume-hud-1366.png`
