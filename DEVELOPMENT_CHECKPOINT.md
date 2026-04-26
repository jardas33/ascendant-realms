# Development Checkpoint

Updated: 2026-04-26 13:55 -04:00

## Current Health

The project is safe to checkpoint from automated verification: unit tests pass, production build passes, and the Playwright browser smoke suite passes. The remaining risk is manual gameplay QA, especially full battle win/loss paths, construction timing feel, ResultsScene reward persistence, and campaign choice/town-service flows beyond the smoke coverage.

## Latest Commit Before This Checkpoint

```text
3449c58d6764fc0b63ee06ad0d5555a0577623e1
```

Branch status before committing this checkpoint:

```text
main...origin/main [ahead 3]
```

This file is intended to be included in the next local checkpoint commit. After the commit, run `git rev-parse HEAD` for the exact checkpoint hash; expected branch status is `main...origin/main [ahead 4]` with a clean working tree unless new edits are made.

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

## Browser Smoke Status

Command:

```bash
npm run test:e2e
```

Result:

```text
PASS
5 Playwright smoke tests passed
```

Covered flows:

- Main menu boots.
- New Campaign reaches CampaignMapScene and locked nodes cannot launch.
- Border Village launches a battle scene.
- Skirmish Setup lists First Claim, Broken Ford, and Ashen Outpost; Broken Ford launches.
- Hero Inventory opens without crashing.

Manual full-play smoke remains recommended with the checklist in `LLM_GAME_HANDOFF.md`.

In-app Browser Use attach attempt:

```text
BLOCKED
No active Codex browser pane was available to the Browser Use runtime.
```

This appears to be a tool/session attachment issue rather than an app failure; the Playwright suite above completed successfully against the local app.

## Asset Refresh Status

`npm run assets:refresh` was not run because no asset registry, manual source-art, generated sprite, or manifest input files changed in this checkpoint.

Run `npm run assets:refresh` before the next checkpoint if any of these change:

- `tools/manual-asset-pipeline/*`
- `public/assets/manual/*`
- generated battle sprites
- asset manifests

## Current Worktree Scope

The current checkpoint groups these related stabilization changes:

- Item instance inventory/equipment migration and unique duplicate conversion.
- Reward, ResultsScene, Hero Inventory, campaign reward, and Marcher Camp purchase updates for item instances.
- Save V2 migration discipline and older-save normalization.
- Playwright e2e setup and smoke tests.
- BattleScene helper extraction.
- CSS split into domain files with `ui.css` as import hub.
- Documentation refresh, including `LLM_GAME_HANDOFF.md`.

## Known Risks

- Full battle victory/defeat and reward persistence are still primarily manual QA.
- ResultsScene, CampaignMapScene, HeroProgressionScene, SaveSystem, and HeroProgressionRules are now the highest-risk files for future edits.
- Bundle size warning remains.
- Item affixes, crafting, durability, broad shops, and full equipment art are not implemented.
- Campaign balance needs human Easy/Normal playthroughs.

## What Should Be Committed Next

Commit the entire current worktree together:

```text
Checkpoint item instances and prototype stabilization
```

Do not split, reset, checkout, or discard any current changes unless the user explicitly asks for a different commit strategy.
