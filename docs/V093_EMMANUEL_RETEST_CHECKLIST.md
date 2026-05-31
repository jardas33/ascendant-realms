# v0.93 Emmanuel Retest Checklist

Checkpoint: v0.93 Runtime UI Foundation Tokens and Mission-Panel State Reset

## Package

Use the final v0.93 package path reported in the closeout response. The package should be named from the final clean commit, have no `-dirty` suffix, and verify with `npm run verify:playtest-package`.

## Ten-Minute Manual Pass

1. Launch the packaged build.
2. Start a fresh campaign.
3. Confirm Salto Outskirts is selected immediately.
4. Confirm the campaign map is visible without scrolling at desktop size.
5. Select locked Aether Well Ruins and open `More Details`.
6. Scroll the selected mission panel down.
7. Select Salto Outskirts again.
8. Confirm Salto returns to the top, `More Details` is collapsed, and `Start Battle` is visible.
9. Check the Map, Stronghold, Hero, Inventory, Intel, and Reputation tabs for readable card hierarchy.
10. Start a battle and confirm HUD objective/command text is readable.
11. Finish or use a test path to Results and confirm summary/details hierarchy still reads clearly.

## Questions For Emmanuel

- Is campaign body copy readable enough at laptop desktop size?
- Does Salto returning to the top after another mission preview feel correct?
- Are the campaign nodes easier to click without feeling too large?
- Do the HUD and command-panel labels feel clearer?
- Does the token polish improve clarity without making the prototype feel overdesigned?
- What still feels cramped, ugly, or confusing?

## Regression Watch

- Do not accept a build where Salto opens midway down the mission panel after inspecting another mission.
- Do not accept campaign map node overlap.
- Do not accept hidden primary mission actions on the default Map tab.
- Do not accept save/reward/campaign-progression changes from simply selecting mission nodes.
