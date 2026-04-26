# Development Checkpoint

Updated: 2026-04-26 13:01 -04:00

## Current Health

The project is safe to checkpoint from an automated verification standpoint: tests pass, production build passes, and the local dev URL responds. Full click-through browser QA is still blocked because Browser Use cannot attach to an active Codex browser pane, so the manual checklist remains guided rather than fully executed by automation.

## Latest Commit

```text
18af42d9520b689ae958f49b41ba9c21346f8e9b
```

Branch status:

```text
main...origin/main [ahead 2]
```

This hash is the commit before the checkpoint commit. After committing this file and the current worktree, use `git rev-parse HEAD` for the checkpoint commit hash.

## Test Status

Command:

```bash
npm test
```

Result:

```text
PASS
21 test files passed
89 tests passed
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
Main JS bundle is approximately 1.7 MB minified / 400 KB gzip.
```

## Asset Refresh Status

`npm run assets:refresh` was not run because `git status --short` showed no asset registry, public asset, generated sprite, or manifest input files requiring refresh in this pass.

Run `npm run assets:refresh` before the next checkpoint if any of these change:

- `tools/manual-asset-pipeline/*`
- `public/assets/manual/*`
- generated battle sprites
- asset manifests

## Smoke Test Status

Local HTTP boot check:

```text
PASS
http://127.0.0.1:5173/ returned 200 OK
```

Browser Use / in-app browser smoke:

```text
BLOCKED
The Browser Use runtime could not attach to an active Codex browser pane.
```

Because Browser Use could not attach, the full manual smoke path was not completed by automation in this pass. Use the checklist in `LLM_GAME_HANDOFF.md` for guided manual QA, with special focus on campaign start, First Claim battle launch, construction/training/rally flow, fog/minimap, Results rewards, event choices, Skirmish Setup, Broken Ford, Ashen Outpost, inventory, and reset save.

Known failed or blocked checklist items:

- Items 1-2: local HTTP boot passed, but visual browser confirmation was blocked by Browser Use.
- Items 3-53: not executed by Browser Use in this pass because the in-app browser bridge was unavailable.
- No gameplay failure was observed by automated tests or build.

## Current Git Status

Modified files:

```text
BALANCE.md
CONTENT_GUIDE.md
DESIGN.md
DEVELOPMENT_CHECKPOINT.md
LLM_GAME_HANDOFF.md
README.md
ROADMAP.md
TECHNICAL_AUDIT.md
src/game/ai/EnemyAIController.ts
src/game/battle/BattleLaunchRequest.test.ts
src/game/battle/BattleLaunchRequest.ts
src/game/battle/BattleRuntime.test.ts
src/game/battle/BattleRuntime.ts
src/game/core/CampaignRules.test.ts
src/game/core/CampaignRules.ts
src/game/core/GameTypes.ts
src/game/core/SaveSystem.test.ts
src/game/core/SaveSystem.ts
src/game/data/battlePacing.ts
src/game/data/buildings.ts
src/game/data/campaignNodes.ts
src/game/data/contentIndex.ts
src/game/data/contentValidation.test.ts
src/game/data/contentValidation.ts
src/game/data/factions.ts
src/game/data/heroClasses.ts
src/game/data/heroes.ts
src/game/data/maps.ts
src/game/data/rewards.ts
src/game/data/units.ts
src/game/data/upgrades.ts
src/game/entities/BaseEntity.ts
src/game/entities/Building.ts
src/game/entities/Hero.ts
src/game/entities/Unit.ts
src/game/save/SaveTypes.ts
src/game/scenes/BattleScene.ts
src/game/scenes/CampaignMapScene.ts
src/game/scenes/HeroCreationScene.ts
src/game/scenes/HeroProgressionScene.ts
src/game/scenes/ResultsScene.ts
src/game/scenes/SkirmishSetupScene.ts
src/game/styles/ui.css
src/game/systems/CombatSystem.ts
src/game/systems/InputSystem.ts
src/game/systems/MovementSystem.ts
src/game/systems/TrainingSystem.ts
src/game/ui/HUD.ts
src/game/ui/MinimapView.ts
```

Untracked files:

```text
src/game/core/FirstExperienceGuidance.test.ts
src/game/core/FirstExperienceGuidance.ts
src/game/core/ResultsFlow.test.ts
src/game/core/ResultsFlow.ts
src/game/data/aiPersonalities.test.ts
src/game/data/aiPersonalities.ts
src/game/data/campaignModifiers.test.ts
src/game/data/campaignModifiers.ts
src/game/systems/FogOfWarSystem.test.ts
src/game/systems/FogOfWarSystem.ts
src/game/systems/PathfindingGrid.test.ts
src/game/systems/PathfindingGrid.ts
src/game/systems/RallyPointSystem.test.ts
src/game/systems/RallyPointSystem.ts
src/game/systems/StatusEffectSystem.test.ts
src/game/systems/StatusEffectSystem.ts
```

## What Worked

- Automated tests pass across battle runtime, launch requests, campaign rules, save normalization, rewards/equipment, AI personalities, campaign modifiers, pathfinding, fog, rally points, status effects, upgrades, placement, minimap, and content validation.
- Production build passes.
- Local dev URL is reachable.
- Current handoff is refreshed with current systems, risks, git status, manual QA, Ashen Outpost, and next priorities.
- Campaign event choices are documented as current behavior.
- Campaign resource bank and choice claims are documented as saved state.

## What Failed Or Could Not Be Completed

- Browser Use could not attach to the in-app browser pane, so no screenshot-based or click-through smoke test was completed.
- `rg --files` previously failed with Windows access denied, so PowerShell enumeration was used for codebase/status inspection.
- Full manual QA remains guided rather than executed through the browser bridge.

## Files Becoming Too Large Or Risky

Most important size/risk hotspots:

- `src/game/styles/ui.css`: 1556 lines.
- `tools/manual-asset-pipeline/assetRegistry.ts`: 1343 lines.
- `src/game/scenes/BattleScene.ts`: 1285 lines.
- `src/game/data/contentValidation.ts`: 929 lines.
- `src/game/data/maps.ts`: 592 lines.
- `src/game/scenes/ResultsScene.ts`: 557 lines.
- `src/game/core/GameTypes.ts`: 542 lines.
- `src/game/scenes/CampaignMapScene.ts`: 485 lines.
- `src/game/scenes/HeroProgressionScene.ts`: 441 lines.
- `src/game/core/HeroProgressionRules.ts`: 420 lines.
- `src/game/ui/HUD.ts`: 366 lines.

## What Should Be Committed Next

This checkpoint pass should commit the current feature set together:

```text
Checkpoint core campaign RTS prototype
```

Include all modified and untracked files listed above. Do not split or discard any of the current uncommitted files unless the user explicitly requests a different commit strategy.

## Next Manual QA Priority

Run the checklist from `LLM_GAME_HANDOFF.md`, with special focus on:

1. New Campaign -> hero creation -> campaign map.
2. Border Village battle launch.
3. Construction, training queue, upgrades, rally points.
4. Fog and minimap correctness.
5. Victory/defeat Results flow.
6. Equip Now persistence.
7. Campaign node completion and reward claiming.
8. Chapel of the Marches and Refugee Caravan choices.
9. Skirmish Setup, Broken Ford launch, and Ashen Outpost launch.
10. Reset Save and Continue Campaign.
