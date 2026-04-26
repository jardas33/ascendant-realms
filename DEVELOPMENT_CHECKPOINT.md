# Development Checkpoint

Updated: 2026-04-26 19:50 -04:00

## Current Health

The project is safe to checkpoint from automated verification. Unit tests pass, the production build passes, and the Playwright browser suite passes. No new gameplay feature work was added during this checkpoint pass.

This checkpoint preserves the current uncommitted prototype work, including:

- Battle HUD polish and responsive battle UI adjustments.
- Building placement feedback improvements for build commands and placement ghost visibility.
- First-30-minute balance tuning documentation and conservative data changes.
- CampaignMapScene helper extraction.
- HeroProgressionScene helper extraction.
- ResultsScene helper architecture from the prior reduction pass.
- Manual QA run documentation in `QA_RUN.md`.
- Selection indicator polish for unit/building ground markers.

## Git And Remote Status

Branch:

```text
main
```

Remote:

```text
origin https://github.com/jardas33/ascendant-realms.git
```

Current commit hash before creating this safety checkpoint:

```text
ee4e29de30ca1ea969e7deabaaff08d53b24c26f
```

Branch relationship before committing:

```text
origin/main...HEAD = 0 behind / 0 ahead
working tree dirty with 26 changed/untracked paths staged for the safety checkpoint after verification
```

After the checkpoint commit is created and pushed, verify the final checkpoint commit hash with:

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
25 test files passed
117 tests passed
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
Main JS bundle is approximately 1.79 MB minified / 424 KB gzip.
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

Covered browser flows include:

- Main menu, credits/info, reset, and Asset Gallery.
- Settings screen persistence for audio/accessibility options.
- New Campaign and HeroCreationScene.
- Campaign map locked/available node behavior.
- Campaign event choices, reputation, resources, modifiers, and Marcher Camp services.
- Inventory equip/unequip and skill spending.
- ResultsScene victory/defeat, Equip Now, defeat tips, retry/campaign actions.
- Skirmish map launches for First Claim, Broken Ford, and Ashen Outpost.
- Battle HUD minimap movement, fog toggle, building placement cancel, and Command Hall actions.
- Build Barracks placement ghost visibility near the Command Hall.
- First-battle RTS loop: hero selection, Crown Shrine capture, Barracks placement/construction, Militia queue/training, rally point, and campaign victory rewards.
- Live BattleScene victory/defeat objective resolution into Results.
- Responsive layout reachability across desktop, tablet, and mobile viewports.

## Manual QA Status

Artifact:

```text
QA_RUN.md
```

Result:

```text
PASS WITH CAVEATS
No critical failures found in the documented QA run.
```

This checkpoint pass did not add a new manual browser run beyond the automated Playwright suite. The previous documented manual QA caveats still stand:

- Audible audio confirmation still needs human ears.
- Full human-paced victory/defeat and first-wave survival/loss remain balance/feel checks.
- Queue cancel/refund, Mystic Lodge/Acolyte, Watchtower attacks, full upgrade UI matrix, Chapel choices, Ashen Outpost special-objective display, and full minimap ping/color inspection remain follow-up QA items.

## Asset Refresh Status

`npm run assets:refresh` was not run because no asset registry, manual source-art, generated sprite, or manifest input files changed during this checkpoint pass.

Run `npm run assets:refresh` before the next checkpoint if any of these change:

- `tools/manual-asset-pipeline/*`
- `public/assets/manual/*`
- generated battle sprites
- asset manifests

## Remaining Known Risks

- `BattleScene` remains the largest live-scene risk because it still owns system construction/wiring, input callbacks, fog overlay rendering, rally marker graphics, runtime update order, and audio/settings integration.
- Full battle victory through normal human input remains manual QA; automated tests cover accelerated and objective-resolution paths.
- Audible audio behavior still needs human verification.
- Balance remains prototype-level and needs human Easy/Normal playthroughs.
- Vite large bundle warning remains.
- `SaveSystem` migration/normalization remains sensitive because localStorage save compatibility must stay safe.
- Campaign choices and town services are covered by rules/e2e tests, but the UI can still become crowded as content grows.
- Fog is grid-based and not blocker-aware.
- Enemy AI is still paced/simple and does not construct, retreat, or adapt composition.
- Item instances exist, but affixes, crafting, durability, and full item art integration are not implemented.

## Local And Remote Sync

At the time this checkpoint file was written, `main` and `origin/main` were synced at the previous commit, with verified local changes still uncommitted.

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

After this safety checkpoint is committed and pushed, the next high-value engineering task is to safely extract BattleScene system construction and wiring into focused helpers while preserving runtime update order, fog/minimap/audio/settings behavior, and existing tests.
