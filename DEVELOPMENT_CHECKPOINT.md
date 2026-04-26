# Development Checkpoint

Updated: 2026-04-26 16:34 -04:00

## Current Health

The project is safe to checkpoint from automated verification. Unit tests pass, the production build passes, and the Playwright browser suite passes after stabilizing the headless test harness.

No gameplay feature work was added during this checkpoint. The only post-verification stabilization edits were:

- Playwright Chromium now launches with SwiftShader/ANGLE flags to avoid a headless WebGL framebuffer startup failure.
- The deep first-battle e2e flow advances the existing BattleScene simulation after issuing the Crown Shrine move command, avoiding wall-clock timing flake while preserving the same tested RTS path.

## Git And Remote Status

Branch:

```text
main
```

Remote:

```text
origin https://github.com/jardas33/ascendant-realms.git
```

Commit hash before creating this safety checkpoint:

```text
e39d6cc44e81e845b15f0b54b44ea7c53cb5239f
```

Branch relationship before committing:

```text
origin/main...HEAD = 0 behind / 0 ahead
working tree dirty with the current prototype checkpoint changes
```

After this file is committed, the final checkpoint commit hash should be read with:

```bash
git rev-parse HEAD
```

## Test Status

Command:

```bash
npm test
```

Result:

```text
PASS
23 test files passed
111 tests passed
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
Main JS bundle is approximately 1.79 MB minified / 423 KB gzip.
```

## Browser E2E Status

Command:

```bash
npm run test:e2e -- --reporter=line
```

Result:

```text
PASS
25 Playwright tests passed
```

Notes:

- An initial e2e attempt failed at boot with Phaser WebGL `Framebuffer Unsupported` in headless Chromium. The Playwright project now forces SwiftShader/ANGLE for deterministic local headless rendering.
- A later e2e attempt exposed a timing flake in the first-battle capture step. The test now advances BattleScene simulation after the player-like move command, matching the existing deterministic construction/training helpers.
- Final e2e run passed all 25 tests.

Covered browser flows:

- Main menu, credits/info, reset, and Asset Gallery.
- Settings screen persistence for audio/accessibility options.
- New Campaign and HeroCreationScene.
- Campaign map locked/available node behavior.
- Campaign event choices, reputation, resources, modifiers, and Marcher Camp services.
- Inventory equip/unequip and skill spending.
- ResultsScene victory/defeat, Equip Now, defeat tips, retry/campaign actions.
- Skirmish map launches for First Claim, Broken Ford, and Ashen Outpost.
- Battle HUD minimap movement, fog toggle, building placement cancel, and Command Hall actions.
- First-battle RTS loop: hero selection, Crown Shrine capture, Barracks placement/construction, Militia queue/training, rally point, and campaign victory rewards.
- Live BattleScene victory/defeat objective resolution into Results.
- Responsive layout reachability across desktop, tablet, and mobile viewports.

## Asset Refresh Status

`npm run assets:refresh` was not run because no asset registry, manual source-art, generated sprite, or manifest input files changed during this checkpoint.

Run `npm run assets:refresh` before the next checkpoint if any of these change:

- `tools/manual-asset-pipeline/*`
- `public/assets/manual/*`
- generated battle sprites
- asset manifests

## Remaining Known Risks

- Full battle victory through normal human input remains manual QA; automated tests cover accelerated and objective-resolution paths.
- Balance remains prototype-level and needs human Easy/Normal playthroughs.
- Vite large bundle warning remains.
- `BattleScene`, `CampaignMapScene`, `HeroProgressionScene`, `SaveSystem`, and `HeroProgressionRules` remain the highest-risk files for future edits.
- Music is not implemented; `musicVolume` is reserved.
- `screenShakeEnabled` is saved but no active screen-shake system currently exists to gate.
- Fog is grid-based and not blocker-aware.
- Enemy AI is still paced/simple and does not construct, retreat, or adapt composition.

## Local And Remote Sync

At the time this checkpoint file was written, local and remote were synced at the previous commit, with the current verified changes still uncommitted.

Expected final state after the checkpoint commit and push:

```text
working tree clean
main synced with origin/main
```

If push fails, run:

```bash
git push origin main
```

## Next Recommended Task

After this safety checkpoint is committed and pushed, do one manual browser QA pass through the handoff checklist with special attention to:

- Settings persistence and audio mute behavior.
- Human-paced Border Village battle.
- Equip Now persistence after a real victory.
- Marcher Camp purchases/services.
- Ashen Outpost launch and special objective display.
