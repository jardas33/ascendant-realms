# Development Checkpoint

Updated: 2026-04-26 14:57 -04:00

## Current Health

The project is safe to checkpoint and publish from automated verification. Unit tests pass, the production build passes, and the Playwright browser suite includes smoke/layout coverage plus deeper menu, campaign, shop, inventory, reward, map-launch, battle-HUD, and live BattleScene-to-Results flows.

Remaining risk is full manual live-battle QA through normal player input. The automated browser suite now verifies live BattleScene victory and defeat objective resolution into Results, but it still does not execute a full real-time player build order from first click to final base kill.

## Git And Remote Status

Verified code checkpoint hash before this documentation-only publish checkpoint:

```text
b07f517691f65b2ed9d2f0756a59b0fcc90f6568
```

Branch status before this documentation-only publish checkpoint:

```text
main...origin/main [ahead 7]
```

Configured remote:

```text
origin https://github.com/jardas33/ascendant-realms.git
```

Local and remote sync status at verification time:

```text
NOT SYNCED YET
Local main was 7 commits ahead of origin/main before this checkpoint update.
This pass should commit the checkpoint update and push main to origin.
```

## Test Status

Command:

```bash
npm test
```

Result:

```text
PASS
21 test files passed
105 tests passed
```

## Build Status

Command:

```bash
npm run build
```

Result:

```text
PASS
TypeScript compile passed
Vite production build passed
```

Known build warning:

```text
Some chunks are larger than 500 kB after minification.
Main JS bundle is approximately 1.78 MB minified / 420 KB gzip.
```

## Browser QA Status

Command:

```bash
npm run test:e2e
```

Result:

```text
PASS
23 Playwright smoke/layout/deep-flow tests passed
```

Covered flows:

- Main menu boots.
- Credits / Info opens.
- Asset Gallery opens and returns.
- New Campaign reaches HeroCreationScene, then CampaignMapScene.
- Continue Campaign and Hero Inventory enable/disable correctly around save reset.
- Locked campaign nodes cannot launch.
- Border Village launches a battle scene.
- Campaign event choices update resources, reputation, modifiers, and completed nodes.
- Marcher Camp repeatable services and once-only purchases update the save.
- Inventory equip, unequip, and skill spending persist.
- ResultsScene victory rewards show Equip Now and save equipped reward instances.
- ResultsScene defeat tips and retry/campaign actions render.
- Live Border Village campaign battle victory resolves through BattleScene into Results, completes the node, unlocks Old Stone Road, grants rewards, and saves campaign/hero progress.
- Live Border Village campaign battle defeat resolves through BattleScene into Results without completing the node or granting rewards.
- Skirmish Setup launches First Claim, Broken Ford, and Ashen Outpost with selected difficulty/personality.
- Battle HUD supports minimap click handling, fog toggle, Command Hall action display, building placement start, and placement-cancel feedback.
- Responsive layout remains horizontally contained and bottom actions remain reachable on desktop, tablet-short, mobile-tall, and mobile-short viewports across main menu, hero creation, campaign map, setup, inventory, asset gallery, battle HUD, and results.

In-app Browser Use attach attempt:

```text
BLOCKED
No active Codex browser pane was available to the Browser Use runtime.
```

This appears to be a tool/session attachment issue rather than an app failure; Playwright completed successfully against the local app.

## Asset Refresh Status

`npm run assets:refresh` was not run because no asset registry, manual source-art, generated sprite, or manifest input files changed in this checkpoint.

Run `npm run assets:refresh` before the next checkpoint if any of these change:

- `tools/manual-asset-pipeline/*`
- `public/assets/manual/*`
- generated battle sprites
- asset manifests

## Current Committed Scope

This checkpoint includes the current deep QA stabilization scope and the live battle-resolution follow-up:

- Added `tests/e2e/deep-flow.spec.ts` for deep automated browser QA.
- Added live BattleScene-to-Results victory/defeat coverage for Border Village campaign battles.
- Added battle placement-cancel status feedback in `src/game/scenes/BattleScene.ts`.
- Updated `README.md` browser test coverage notes.
- Updated `LLM_GAME_HANDOFF.md`.
- Updated this checkpoint file.

## Bugs Found And Fixed

- Building placement cancellation with Esc/right-click previously removed the ghost silently. It now shows `Building placement cancelled` in the battle status line.

No other deterministic product bug was reproduced during the automated deep pass. Earlier failures were test harness assumptions about data IDs, strict selectors, synthetic-page scope, and long map-launch timing; those are fixed in the new e2e spec.

## Known Risks

- Full battle victory/defeat from live player input remains manual QA.
- ResultsScene, CampaignMapScene, HeroProgressionScene, SaveSystem, and HeroProgressionRules remain high-risk files for future edits.
- Bundle size warning remains.
- Item affixes, crafting, durability, broad shops, and full equipment art are not implemented.
- Campaign balance still needs human Easy/Normal playthroughs.

## What Should Be Committed Next

This documentation-only checkpoint update should be committed and pushed. After a successful push, expected state is a clean working tree with local `main` synced to `origin/main`.
