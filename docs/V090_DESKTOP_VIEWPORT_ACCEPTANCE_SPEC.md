# v0.90 Desktop Viewport Acceptance Spec

Checkpoint: v0.90 UX Visual-Regression Harness and Desktop-Viewport Acceptance Hardening

## Intent

Prevent future UI work from silently regressing into overlapping campaign nodes, off-screen actions, unreadable Results summaries, or cluttered battle HUD states. This is a QA-hardening milestone only: no gameplay, reward, save, balance, ID, or art changes.

## Acceptance Viewports

- `1920x1080`: full desktop presentation.
- `1600x900`: intermediate desktop, catches spacing assumptions hidden by full HD.
- `1366x768`: laptop minimum acceptance target.

## Required Screens

- Main menu.
- Fresh campaign map.
- Selected unlocked mission.
- Selected locked mission.
- Campaign tabs: Map, Stronghold, Hero, Inventory, Intel, Reputation.
- Ordinary battle start.
- Selected units.
- Selected building.
- Contested capture site.
- Lume inactive, active stable, selected/highlighted, hidden, always visible.
- Private-demo Results compact and expanded.
- Normal Victory Results.
- Normal Defeat Results.
- Replay Results.
- Tutorial.

## Campaign Acceptance

- Map tab is visible immediately.
- `border_village` remains the selected fresh-campaign node and displays as Salto Outskirts.
- Locked Aether Well preview remains accessible with a disabled launch action.
- Primary mission action is visible without default page scrolling.
- Campaign node cards do not overlap.
- Route layer remains visible.
- More Details keeps secondary mission prose behind disclosure.
- All six campaign tabs fit horizontally and show their card-based panels without horizontal overflow.

## Battle Acceptance

- HUD resources, hero panel, command panel, and minimap are visible.
- Objective tracker remains visible and collision-free on scenarios that render objective rows; simpler Tutorial/early battle states use battle-status fallback without Lume/private-demo complexity.
- Ordinary battle states do not show private-demo controls.
- Ordinary non-Lume missions do not show Lume visibility controls.
- Selected unit, building, and capture-site panels keep role/status text inside the panel.
- Minimap remains visible across the tested desktop viewports.

## Results Acceptance

- Primary actions are visible above the fold in Victory, Defeat, Replay, and private-demo Results.
- Full battle details remain collapsed by default.
- Private-demo Results keep their no-save compact summary and use `private-demo-full-details`, not the ordinary full-details control.
- Ordinary Results keep the overview, rewards, XP summary, veterans, and next action before expanded telemetry.

## Non-Goals

- No pixel-perfect screenshot approval.
- No image generation or runtime art intake.
- No gameplay, save, reward, balance, campaign progression, or stable-ID changes.
