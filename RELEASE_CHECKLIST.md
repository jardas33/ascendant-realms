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
PASS: 45 test files, 334 tests
```

Current v0.8.1 runtime asset crosscheck phase result:

```text
PASS: 45 test files, 339 tests
```

2. Standalone content validation:

```bash
npm run validate:content
```

Expected current prototype result:

```text
PASS: Ascendant Realms content validation passed.
```

This gate runs the content validator without opening the game UI. It should be used before trusting new or edited data for units, buildings, abilities, rewards, campaign nodes, maps, rivals, Stronghold upgrades, campaign modifiers, tutorial metadata, enemy pressure plans, visual asset metadata, and future expansion metadata. The CLI path also checks runtime visual asset file paths without bundling Node filesystem checks into the browser boot path.

3. Production build:

```bash
npm run build
```

Expected current prototype result:

```text
PASS: TypeScript compile and Vite production build
Current output shape after the v0.4 Phaser vendor split:
- app JS chunk: assets/index-CC1M6Mg7.js, 476.83 kB / gzip 127.77 kB
- Phaser vendor chunk: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB
- CSS chunk: assets/index-v9ZLtiOK.css, 44.23 kB / gzip 9.11 kB
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

This lane runs `tests/e2e/smoke.spec.ts` and is the frequent-iteration browser check. It keeps main menu, Tutorial / Proving Grounds no-reward completion and exit, Settings, New Campaign, campaign launch, Cinderfen reward/save/duplicate-prevention, skirmish, difficulty, and inventory smoke coverage visible. The v0.6 tutorial e2e runtime review keeps full tutorial completion in smoke while the lane remains around 5 minutes; move it deeper only if smoke repeatedly grows beyond the 6-7 minute watch band. v0.7.3 pressure playtest does not add smoke tests or change lane counts.

5. Full browser release-gate suite:

```bash
npm run test:e2e:release
```

Expected current prototype result:

```text
PASS: 67 Playwright tests
```

`npm run test:e2e` also remains the full Playwright suite. Use a long timeout. The full suite intentionally runs with one worker for stability. The v0.7 Enemy Strategic Pressure V1 e2e pass adds `tests/e2e/enemy-pressure.spec.ts`, so the current full release gate is 67 tests across 4 spec files while smoke remains 12 tests. Latest v0.7.1 pressure-feel final checkpoint: smoke PASS, 12 tests in 5.3m; focused pressure spec PASS, 2 tests in 43.1s during visibility hardening; release PASS, 67 tests in 32.9m.

6. Optional CI sharded release gate:

```bash
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Both shards must pass to equal the full release gate. Keep `npm run test:e2e:release` as the canonical one-command local release check; the shard scripts are mainly for CI matrix jobs where they can run in parallel. If run sequentially on a local machine, the total runtime may not be better than the full suite and reports are split by shard.

Latest local shard verification after the v0.7.1 final gate, 2026-05-09:

```text
Shard 1: passed, 55 Playwright tests in 28.2m.
Shard 2: passed, 12 Playwright tests in 5.0m.
```

The current 2-shard split is coverage-preserving but uneven because shard 1 includes the deep-flow and layout-heavy side of the suite. Keep this as a CI wall-clock optimization, not a mandatory local workflow.

v0.8 adds optional 3-shard release scripts for CI runs that need a less lopsided split:

```bash
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

All three 3-shard scripts must pass to equal the full release gate. They preserve the canonical one-command release lane and the existing 2-shard scripts. Current list checks split the 67-test suite into 28 deep-flow tests, 27 layout+pressure tests, and 12 smoke tests. They do not change Playwright workers, parallelism, serving mode, or coverage.

Latest v0.8 local 3-shard verification:

```text
Shard 1 of 3: passed, 28 Playwright tests in 12.3m.
Shard 2 of 3: passed, 27 Playwright tests in 14.9m.
Shard 3 of 3: passed, 12 Playwright tests in 5.3m.
```

v0.8 final verification should still run the full release lane and both existing 2-shard scripts before push; the 3-shard scripts are the new additive CI option and should be verified during the v0.8 runtime-improvement phase.

7. Optional focused e2e lanes:

```bash
npm run test:e2e:layout
npm run test:e2e:deep
```

`test:e2e:layout` runs responsive/mobile/readability coverage, including Tutorial / Proving Grounds overlay reachability, the v0.6 overlay width guard, and accessibility-era overlay layout checks across desktop, tablet, and mobile viewports. `test:e2e:deep` runs release-critical deep gameplay and save-flow coverage. Enemy Strategic Pressure V1 coverage lives in the full release suite via `tests/e2e/enemy-pressure.spec.ts`; use `npx playwright test tests/e2e/enemy-pressure.spec.ts --reporter=line` for a focused pressure lane. These focused lanes are available for targeted work; they do not replace the full release gate.

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
No enemy-pressure warnings
75 pressure-enabled Cinderfen runs
63 triggered pressure runs
12 quiet/untriggered pressure runs
149 pressure warnings
147 losses after pressure
0 simulated reinforcement applications
Cinderfen repeat rewards remain tiny XP/resources with no repeat item roll
```

This command regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`.

Latest v0.7.3 pressure-playtest interpretation: no balance tuning is applied. Cinderfen Crossing and Cinderfen Watch pressure remain scoped, readable in controlled browser-input review, and warning/telemetry-only for `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold`. Emmanuel's manual checklist remains the missing direct human evidence before any simulator-only reinforcement experiment.

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

Latest production preview smoke, 2026-05-09:

```text
PASS: http://127.0.0.1:57931/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map after the preview save existed.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
NOTE: pressure-enabled battle launch was covered by targeted release e2e; the production preview smoke did not force a deep Cinderfen save state.
```

After build-output or chunking changes, run a production preview smoke when feasible and confirm the main menu loads, `Prototype v0.3` / `Cinderfen Route Baseline` copy remains visible, key menu routes open without crashing, and browser console errors stay at 0.

## Manual QA Areas Not Fully Automated

- Full human-paced Border Village and Old Stone Road playthroughs on Easy, including first warning, Barracks timing, first trained unit, and first enemy contact.
- Aether Well Ruins and Bandit Hillfort on Normal from a typical early campaign save, including Veyra of the Cinders and Gorak Emberhand scout/readability checks.
- Ashen Outpost with and without Chapel repair, including Captain Malrec readability, Hold the Line ability readability, final approach readability, tower pressure, and objective-panel placement.
- Stronghold Tier I and II purchase feel in a real campaign economy, especially Watch Post II and Quartermaster Stores II.
- v0.7.3 follow-up: Emmanuel's manual Cinderfen Crossing and Cinderfen Watch pressure checklist, especially warning noticeability during actual unit commands, Cinder Shrine salience, Watch Road fairness, Greedy Economy timeout clarity, Fast Army quick-clear feel, and Retinue + Training Yard II power.
- Reputation hooks in normal campaign flow: Common Folk Marcher Camp discounts, Free Marches Stronghold discounts, Old Faith Chapel Aether bonus, and Ashen Covenant Hostile pressure.
- Affixed reward readability in Results and Inventory, including base/affix/total stat copy.
- Retinue and rival readability in normal human-paced play, including whether first-defeat rewards and trophies feel satisfying without becoming mandatory.
- Cinderfen pressure feel in normal human-paced play, including whether pressure warnings are noticed, whether Cinder Shrine and Watch Road responses feel fair, and whether stronger actions should remain warning/telemetry-only.
- Full human-paced Cinderfen route from Ashen Outpost through Overlook, Waystation, Crossing, Watch, and Aftermath, including Cinder Shrine surge/attunement readability and modest reward feel.
- Full human-paced Tutorial / Proving Grounds run, especially twelve-step length, mobile-short overlay readability, building/training/rally timing, and no-reward completion clarity.
- HUD hover/scroll feel and captured-site fog readability under real mouse movement, even though the regression paths now have Playwright coverage.
- Audio behavior with human ears.
- Visual polish across generated/manual UI-kit assets.
- v0.8 visual foundation follow-up: review current Cinderfen battlefield screenshots against `docs/V08_VISUAL_DEBT_AUDIT.md`, `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, `docs/ART_DIRECTION_2026_BIBLE.md`, and `docs/CINDERFEN_VISUAL_REWORK_SPEC.md` before approving any art sprint.
- Existing asset/source hygiene: future visual work should start with an asset manifest and source/license/status/scale metadata instead of importing new binaries directly.
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
- `docs/V08_PERFORMANCE_AUDIT.md`, `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`, and `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md` summarize the v0.8 bundle/performance and e2e runtime work.
- `docs/V08_VISUAL_DEBT_AUDIT.md`, `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`, `docs/V08_PROTOTYPE_VISUAL_READABILITY_DECISION.md`, `docs/ART_DIRECTION_2026_BIBLE.md`, `docs/ASSET_PIPELINE_PLAN.md`, and `docs/CINDERFEN_VISUAL_REWORK_SPEC.md` define the visual foundation without implementing a graphics overhaul.
- `docs/V08_TECH_VISUAL_FOUNDATION_REPORT.md` summarizes the v0.8 technical and visual foundation gate.
- `ROADMAP.md` marks Cinderfen Overlook, Waystation, Crossing, Watch, Aftermath, the first no-reward Tutorial / Proving Grounds shell, the v0.7.3 pressure playtest gate, and the v0.8 technical/visual foundation gate as done, with the next phase set to a v0.8.1 visual asset manifest and screenshot QA gate unless manual pressure or tutorial feedback redirects it.
- `LLM_GAME_HANDOFF.md` marks the current state as the v0.8 technical performance and visual foundation gate on top of the v0.7 pressure foundation and warns future sessions not to add broad systems before their gates are explicit and green.
