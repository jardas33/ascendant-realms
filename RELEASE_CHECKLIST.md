# Release Checklist

Use this checklist for the v0.3 Cinderfen route baseline candidate and future prototype checkpoints. Run commands from the project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

## Required Automated Checks

1. Unit and pure-rule tests:

```bash
npm test
```

Expected current prototype result:

```text
PASS: 42 test files, 315 tests
```

2. Standalone content validation:

```bash
npm run validate:content
```

Expected current prototype result:

```text
PASS: Ascendant Realms content validation passed.
```

This gate runs the content validator without opening the game UI. It should be used before trusting new or edited data for units, buildings, abilities, rewards, campaign nodes, maps, rivals, Stronghold upgrades, campaign modifiers, tutorial metadata, and future expansion metadata.

3. Production build:

```bash
npm run build
```

Expected current prototype result:

```text
PASS: TypeScript compile and Vite production build
Current output shape after the v0.4 Phaser vendor split:
- app JS chunk: assets/index-BArZgVc-.js, 459.27 kB / gzip 123.49 kB
- Phaser vendor chunk: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB
- CSS chunk: assets/index-EaFx5BCM.css, 43.77 kB / gzip 9.02 kB
```

Known warning:

```text
Some chunks are larger than 500 kB after minification.
```

This Vite warning is expected for the current Phaser vendor chunk and is not a release blocker unless a later optimization explicitly targets lazy scene/data loading or warning-policy cleanup. The app chunk is below the default 500 kB threshold after the v0.4 vendor split; the warning remains because Phaser itself is still large.

4. Fast default browser smoke lane:

```bash
npm run test:e2e:smoke
```

Expected current prototype result:

```text
PASS: 12 Playwright tests
```

This lane runs `tests/e2e/smoke.spec.ts` and is the frequent-iteration browser check. It keeps main menu, Tutorial / Proving Grounds no-reward completion and exit, Settings, New Campaign, campaign launch, Cinderfen reward/save/duplicate-prevention, skirmish, difficulty, and inventory smoke coverage visible.

5. Full browser release-gate suite:

```bash
npm run test:e2e:release
```

Expected current prototype result:

```text
PASS: 65 Playwright tests
```

`npm run test:e2e` also remains the full Playwright suite. Use a long timeout. The full suite intentionally runs with one worker for stability. It took about 32 minutes on this machine after adding the playable tutorial smoke path; the Phase 11 tutorial layout guard raised the expected full count to 65 tests and should be refreshed in the final full gate.

6. Optional CI sharded release gate:

```bash
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Both shards must pass to equal the full release gate. Keep `npm run test:e2e:release` as the canonical one-command local release check; the shard scripts are mainly for CI matrix jobs where they can run in parallel. If run sequentially on a local machine, the total runtime may not be better than the full suite and reports are split by shard.

Latest local shard verification before the playable tutorial shell, 2026-05-08:

```text
Shard 1: passed, 49 Playwright tests in 23.9m.
Shard 2: passed, 10 Playwright tests in 4.4m.
```

The current 2-shard split is coverage-preserving but uneven because shard 1 includes the deep-flow and layout-heavy side of the suite. Keep this as a CI wall-clock optimization, not a mandatory local workflow. Rerun both shards after tutorial-shell release hardening to refresh the post-tutorial counts.

7. Optional focused e2e lanes:

```bash
npm run test:e2e:layout
npm run test:e2e:deep
```

`test:e2e:layout` runs responsive/mobile/readability coverage, including Tutorial / Proving Grounds overlay reachability across desktop, tablet, and mobile viewports. `test:e2e:deep` runs release-critical deep gameplay and save-flow coverage. These focused lanes are available for targeted work; they do not replace the full release gate.

8. Deterministic playtest simulator:

```bash
npm run playtest:sim
```

Expected current prototype result:

```text
PASS: 255 simulated runs across 85 campaign battle node/profile summaries
No too-easy nodes
No structural too-hard nodes
Ashen Outpost beatable
No Stronghold warnings
Cinderfen repeat rewards remain tiny XP/resources with no repeat item roll
```

This command regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.

## Optional Preview Check

After `npm run build`, run:

```bash
npm run preview
```

Open the local preview URL and confirm:

- Main menu renders `Prototype v0.3` and `Cinderfen Route Baseline`.
- Tutorial / Proving Grounds launches and exits without crashing.
- Browser console has no new hard errors.
- Continue/New Campaign, Skirmish, Hero Inventory, Settings, and Asset Gallery are reachable from an appropriate save state.

Browser Use preview sanity is optional after the automated suite. Use the local preview URL printed by Vite; previous clean preview checks used `127.0.0.1` ports with browser console errors at 0. The current visible product copy is `Prototype v0.3` / `Cinderfen Route Baseline`.

Latest production preview smoke, 2026-05-08:

```text
PASS: http://127.0.0.1:57915/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign returned to Campaign Map after the preview save existed.
PASS: Skirmish Setup opened and listed current maps.
PASS: browser console errors stayed at 0.
```

After build-output or chunking changes, run a production preview smoke when feasible and confirm the main menu loads, `Prototype v0.3` / `Cinderfen Route Baseline` copy remains visible, key menu routes open without crashing, and browser console errors stay at 0.

## Manual QA Areas Not Fully Automated

- Full human-paced Border Village and Old Stone Road playthroughs on Easy, including first warning, Barracks timing, first trained unit, and first enemy contact.
- Aether Well Ruins and Bandit Hillfort on Normal from a typical early campaign save, including Veyra of the Cinders and Gorak Emberhand scout/readability checks.
- Ashen Outpost with and without Chapel repair, including Captain Malrec readability, Hold the Line ability readability, final approach readability, tower pressure, and objective-panel placement.
- Stronghold Tier I and II purchase feel in a real campaign economy, especially Watch Post II and Quartermaster Stores II.
- Reputation hooks in normal campaign flow: Common Folk Marcher Camp discounts, Free Marches Stronghold discounts, Old Faith Chapel Aether bonus, and Ashen Covenant Hostile pressure.
- Affixed reward readability in Results and Inventory, including base/affix/total stat copy.
- Retinue and rival readability in normal human-paced play, including whether first-defeat rewards and trophies feel satisfying without becoming mandatory.
- Full human-paced Cinderfen route from Ashen Outpost through Overlook, Waystation, Crossing, Watch, and Aftermath, including Cinder Shrine surge/attunement readability and modest reward feel.
- Full human-paced Tutorial / Proving Grounds run, especially twelve-step length, mobile-short overlay readability, building/training/rally timing, and no-reward completion clarity.
- HUD hover/scroll feel and captured-site fog readability under real mouse movement, even though the regression paths now have Playwright coverage.
- Audio behavior with human ears.
- Visual polish across generated/manual UI-kit assets.
- Production preview sanity after release packaging.

## Release Notes To Check

- `CHANGELOG.md` describes the current feature baseline.
- `README.md` has current setup, feature summary, known limitations, and verification counts.
- `docs/V03_CINDERFEN_ROUTE_BASELINE.md` records the current route, rewards, simulator/e2e summaries, known risks, forbidden next steps, and recommended next steps.
- `docs/V04_ACCESSIBILITY_READABILITY_PLAN.md` records the v0.4 Settings readability/accessibility pass.
- `docs/SAVE_COMPATIBILITY_AUDIT.md` records current save version 2 behavior and v0.4 compatibility coverage.
- `docs/V04_ROUTE_FEEL_SURROGATE_REVIEW.md` records the automated route-feel surrogate review and remaining human-feel watch items.
- `docs/FULL_GAME_ROADMAP.md`, `docs/SYSTEMS_EXPANSION_RISK_REGISTER.md`, and `docs/V05_SYSTEMS_DESIGN_BRIEF.md` plan future systems without implementing them.
- `docs/V04_POLISH_BACKLOG.md` records safe/medium-risk/high-risk/blocked tiny polish candidates.
- `docs/V05_SAVE_CONTENT_VALIDATION_GATE_REPORT.md` summarizes the v0.5 save, content-validation, determinism, and expansion-readiness gate.
- `docs/TUTORIAL_PLAYABLE_SHELL_REPORT.md`, `docs/TUTORIAL_SAVE_PERSISTENCE_AUDIT.md`, `docs/TUTORIAL_CONTENT_VALIDATION_GATE.md`, and `docs/TUTORIAL_READABILITY_SURROGATE_REVIEW.md` summarize the first playable Tutorial / Proving Grounds shell.
- `ROADMAP.md` marks Cinderfen Overlook, Waystation, Crossing, Watch, Aftermath, and the first no-reward Tutorial / Proving Grounds shell as done, with the next phase set to human-paced tutorial review and small polish.
- `LLM_GAME_HANDOFF.md` marks the current state as the playable tutorial shell on top of the v0.5 safety gate and warns future sessions not to add broad systems before their gates are explicit and green.
