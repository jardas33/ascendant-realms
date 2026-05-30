# v0.83 Emmanuel Retest Checklist

## Campaign Map

- Start a fresh campaign.
- Confirm the map is visible immediately.
- Confirm Border Village is selected by default and has its primary action in the selected-node panel.
- Confirm locked nodes are still selectable for preview.
- Confirm node cards do not overlap at 1920x1080.
- Confirm node cards do not overlap at 1366x768.
- Confirm Stronghold, Hero, Inventory, Intel, and Reputation tabs open without losing the campaign save.

## Private Aether Well Lume Demo

- From a fresh campaign, click `Launch Aether Well Lume Demo`.
- Confirm the battle loads on Broken Ford.
- Confirm the HUD shows a Private Playtest Demo warning.
- Confirm the HUD shows the Lume Network row.
- Capture West Stone Cut and Ford Toll.
- Confirm Linked Ward becomes active.
- Finish the battle.
- Confirm Results shows Private Playtest Demo and no-save/no-reward copy.

## Save Safety

- Return to Campaign Map after the demo.
- Confirm Aether Well Ruins is not marked completed from the private demo.
- Confirm hero XP, relics, Retinue, reputation, and campaign rewards did not change from the demo.
- Confirm normal campaign battles still use normal first-clear/replay reward rules.

## Regression Spot Checks

- Tutorial / Proving Grounds remains no-save/no-reward and does not show private campaign tools.
- Border Village can still launch normally.
- Aether Well Ruins remains locked until prerequisites are completed in the normal campaign path.
- The packaged build starts through `start-playtest-server.mjs`.
