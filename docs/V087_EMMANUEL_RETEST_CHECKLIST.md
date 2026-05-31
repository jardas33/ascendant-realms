# v0.87 Emmanuel Retest Checklist

## Build

- Launch the v0.87 package.
- Confirm the package opens without save migration, setup prompt, or new asset download.
- Start from a fresh campaign profile if possible.

## Campaign Map

- Open the Campaign Map tab at 1920x1080 and 1366x768.
- Confirm the map is visible immediately and the page does not need default scrolling in the Map tab.
- Confirm Border Village is selected on a fresh campaign.
- Confirm Aether Well Ruins can be previewed while locked and shows a readable lock reason.
- Confirm nodes do not overlap and chapter lanes/routes make the Act 1 path easier to follow.
- Confirm completed, selected, available, locked, future, and replayable states are visually distinct.

## Mission Panel

- Select Border Village, Aether Well Ruins, and a completed mission.
- Confirm the default mission panel shows title, type, state, short description, objective, reward preview, pacing, lock reason when needed, and primary action.
- Open `More Details` and confirm build hints, doctrine/modifier/rival/replay details, and longer reward/context copy are still available.

## Campaign Tabs

- Visit Map, Stronghold, Hero, Inventory, Intel, and Reputation.
- Confirm each tab uses smaller cards or details blocks instead of one long dashboard.
- Confirm existing actions still work, including hero/inventory/retinue/tactical-plan surfaces where available.

## Results

- Complete a normal victory and confirm victory, mission name, time, primary objective, rewards, hero XP, veteran summary, and return action are visible before telemetry details.
- Open `Show Full Battle Details` and confirm extended stats are still available.
- Trigger a normal defeat and confirm retry/prep actions are visible without scrolling.
- Replay a completed mission and confirm replay-safe copy and replay action remain clear.
- Run the private Lume demo and confirm the private-demo Results rescue remains intact.

## Regression Checks

- Tutorial remains no-save/no-reward.
- Rewards, hero XP, relic choice/equip, Retinue summaries, replay rules, and optional objective credit behave as before.
- Worker build/repair/site assignment, control groups, Patrol, battlefield events, tactical plans, and Act 1 route remain functional.
