# Release Checklist

Use this checklist for the v0.3 Cinderfen route baseline candidate and future prototype checkpoints. Run commands from the project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

For day-to-day command selection before the final freeze gate, see `docs/DEVELOPER_COMMAND_GUIDE.md`. The release checklist remains the stricter checkpoint/freeze reference.

## Gate Selection

Use the focused gate that matches the changed surface during routine work, then run the final freeze gate before a release handoff.

| Change type | Minimum gate | Additional focused gate |
| --- | --- | --- |
| Routine iteration | `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `git diff --check` | Add `npm run test:e2e:smoke` for source/tooling changes. |
| Docs-only change | `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `git diff --check` | None unless docs describe a changed executable workflow. |
| Tutorial/UI change | Routine gate plus `npm run test:e2e:smoke` | Add `npm run test:e2e:layout` and `npm run visual:qa` for overlay/layout/screenshot-relevant changes. |
| Visual-intake change | Routine gate, especially `npm run validate:art-intake` | Add `npm run visual:qa` only when screenshot comparison docs or candidate-review evidence changes. |
| Content/data change | Routine gate plus `npm run test:e2e:smoke` and `npm run playtest:sim` | Add `npm run test:e2e:deep` or full release for campaign, battle, save, reward, or pressure risk. |
| Final freeze gate | Every required check below, all release lanes/shards, visual QA, simulator, preview smoke, and `git diff --check` | Push only after the repo is clean and synced or document the manual push command. |

Known current realities:

- `npm run validate:art-intake` is part of the routine gate and must remain safe with an empty intake.
- `npm run visual:qa` is useful, optional, human-reviewed, and non-pixel-perfect.
- The 3-way release shards are the better-balanced CI split, but they do not replace the full release lane.
- The known Phaser vendor chunk warning remains expected and non-blocking.
- Full release e2e is intentionally slow and should use a long timeout.
- Production preview smoke should prefer `npm run smoke:preview` after `npm run build`.
- GitHub Actions now has a conservative `.github/workflows/ci.yml` dry-run: fast PR/push confidence runs automatically, while visual QA, 3-way release shards, simulator, and full release remain manual `workflow_dispatch` options.

## Required Automated Checks

1. Unit and pure-rule tests:

```bash
npm test
```

Expected current prototype result:

```text
PASS: 46 test files, 351 tests
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

For future non-runtime Cinderfen style-frame intake metadata, also run:

```bash
npm run validate:art-intake
```

Expected current intake result:

```text
PASS: Art intake validation passed.
```

This gate validates JSON source/license metadata and any future review-manifest JSON under `art-review/cinderfen-style-frames/metadata/`. It is intentionally metadata-only, passes with an empty intake, does not require image files unless metadata marks a candidate as submitted, and does not make any candidate safe for runtime use by itself.

3. Production build:

```bash
npm run build
```

Expected current prototype result:

```text
PASS: TypeScript compile and Vite production build
Current output shape after the v0.4 Phaser vendor split:
- app JS chunk: assets/index-DY-3qp2P.js, 477.04 kB / gzip 127.86 kB
- Phaser vendor chunk: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB
- CSS chunk: assets/index-BiGdwuWI.css, 44.51 kB / gzip 9.16 kB
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

This lane runs `tests/e2e/smoke.spec.ts` and is the frequent-iteration browser check. It keeps main menu, Tutorial / Proving Grounds no-reward completion and exit, Settings, New Campaign, campaign launch, Cinderfen reward/save/duplicate-prevention, skirmish, difficulty, and inventory smoke coverage visible. The v0.10 tutorial e2e lane review keeps full tutorial completion in smoke while the lane remains inside the 6-7 minute watch band; move it deeper only if smoke repeatedly grows beyond that band. v0.10 did not add smoke tests or change lane counts.

v0.11.3 gives only `settings screen persists accessibility options` a 60s per-test budget after GitHub Actions evidence showed this combined settings-persistence plus in-battle runtime-application check can exceed the global 35s Playwright timeout on hosted runners. The test remains in smoke and keeps its real persistence/runtime assertions. If `campaign Border Village launches a battle scene` fails immediately after a settings timeout, first treat it as possible browser/context cascade; if it fails again after settings passes, investigate it independently.

v0.11.4 stabilizes seeded smoke setup by waiting for a ready main menu before localStorage mutation and navigating back to `/` after writing seeded saves instead of relying on `page.reload()`. `skirmish difficulty selection changes fog and starting pressure` now has a scoped 60s budget because it launches two seeded battles back-to-back and GitHub Actions evidence showed the seed/reload path could exceed the global timeout. The test remains in smoke and keeps its fog/pressure assertions.

5. Full browser release-gate suite:

```bash
npm run test:e2e:release
```

Expected current prototype result:

```text
PASS: 67 Playwright tests
```

`npm run test:e2e` also remains the full Playwright suite. Use a long timeout. The full suite intentionally runs with one worker for stability. The v0.7 Enemy Strategic Pressure V1 e2e pass adds `tests/e2e/enemy-pressure.spec.ts`, so the current full release gate is 67 tests across 4 spec files while smoke remains 12 tests. Latest v0.10 lane review checkpoint: smoke PASS, 12 tests in about 4.8m; release PASS, 67 tests in about 28.0m.

6. Optional CI sharded release gate:

```bash
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Both shards must pass to equal the full release gate. Keep `npm run test:e2e:release` as the canonical one-command local release check; the shard scripts are mainly for CI matrix jobs where they can run in parallel. If run sequentially on a local machine, the total runtime may not be better than the full suite and reports are split by shard.

Latest local 2-shard verification after the v0.10 final gate, 2026-05-11:

```text
Shard 1: passed, 55 Playwright tests in about 24.3m.
Shard 2: passed, 12 Playwright tests in about 4.8m.
```

The current 2-shard split is coverage-preserving but uneven because shard 1 includes the deep-flow and layout-heavy side of the suite. Keep this as a CI wall-clock optimization, not a mandatory local workflow.

v0.8 adds optional 3-shard release scripts for CI runs that need a less lopsided split:

```bash
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

All three 3-shard scripts must pass to equal the full release gate. They preserve the canonical one-command release lane and the existing 2-shard scripts. Current list checks split the 67-test suite into 28 deep-flow tests, 27 layout+pressure tests, and 12 smoke tests. They do not change Playwright workers, parallelism, serving mode, or coverage.

Latest v0.10 local 3-shard verification:

```text
Shard 1 of 3: passed, 28 Playwright tests in about 11.5m.
Shard 2 of 3: passed, 27 Playwright tests in about 12.9m.
Shard 3 of 3: passed, 12 Playwright tests in about 4.9m.
```

Final verification should still run the full release lane, both existing 2-shard scripts, and all three 3-shard scripts before push. The 3-shard scripts remain the additive CI option; they do not replace the canonical full release lane.

## GitHub Actions CI Dry Run

v0.11.1 adds `.github/workflows/ci.yml`.

Automatic `pull_request` and `push` to `main` fast confidence runs:

```text
npm ci
npx playwright install --with-deps chromium
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
```

Manual `workflow_dispatch` inputs:

| Input | Runs | Use when |
| --- | --- | --- |
| `run_visual_qa` | `npm run visual:qa` and uploads `visual-qa/latest/` | Human screenshot review is needed. |
| `run_release_matrix` | 3-way release shard matrix plus `npm run playtest:sim` | CI release gate dry-run or pre-freeze confidence. |
| `run_full_release` | `npm run test:e2e:release` | Major freeze or one-command release-lane confirmation in CI. |

The workflow uses Node 22, `npm ci`, Playwright Chromium install, npm cache, no secrets, no paid services, and short-retention artifacts. v0.11.2 could not inspect remote Actions runs from the Codex environment because `gh` is unavailable, the GitHub connector token is expired, and unauthenticated Actions API access returns `404 Not Found`. Use `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md` to collect the first hosted-run URL, `fast-confidence` duration, `smoke:preview` result, manual-job status, and artifact evidence from GitHub UI. Do not weaken local release gates until CI has proven itself on the remote.

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

Latest v0.10 report-gate simulator verification, 2026-05-11:

```text
PASS: 255 simulated runs across 85 campaign battle node/profile summaries.
```

Latest v0.7.3 pressure-playtest interpretation: no balance tuning is applied. Cinderfen Crossing and Cinderfen Watch pressure remain scoped, readable in controlled browser-input review, and warning/telemetry-only for `reinforce_next_wave`, `contest_capture_site`, and `defensive_hold`. Emmanuel's manual checklist remains the missing direct human evidence before any simulator-only reinforcement experiment.

9. Optional visual screenshot QA:

```bash
npm run visual:qa
```

Expected current prototype result:

```text
PASS: 1 Playwright visual QA capture test
18 review screenshots generated under visual-qa/latest/
Browser console errors recorded in the generated index: 0
Generated index summary records screenshot count 18, console error count 0, and desktop/tablet/mobile viewport coverage
```

This v0.8.2 lane is optional and review-oriented. It captures main menu, Asset Gallery, Hero Inventory, Tutorial desktop/mobile, campaign map, route-complete campaign map, Skirmish Setup, Cinderfen Crossing desktop/tablet, Cinder Shrine, Crossing pressure warning, Cinderfen Watch, Watch pressure warning, and victory/defeat Results views. It is not a pixel-perfect visual regression test and it does not replace smoke, layout, release, content validation, or simulator gates. Generated screenshots are intentionally ignored by git.

Future Cinderfen visual work should also review `docs/V09_CINDERFEN_SCREENSHOT_ACCEPTANCE_CRITERIA.md` and `docs/V091_STYLE_FRAME_SCREENSHOT_COMPARISON_PLAN.md`. v0.9.1 keeps this lane as human-review evidence: no pixel-perfect diffing, no generated/imported runtime art, and no production approval without source/license metadata plus manifest validation. Tutorial-specific v0.10 observations live in `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`.

10. Whitespace diff check:

```bash
git diff --check
```

Expected current prototype result:

```text
PASS: no whitespace errors
```

## Optional Preview Check

After `npm run build`, prefer the automated preview helper:

```bash
npm run smoke:preview
```

Manual fallback:

```bash
npm run preview
```

Open the local preview URL and confirm:

- Main menu renders `Prototype v0.3` and `Cinderfen Route Baseline`.
- Tutorial / Proving Grounds launches and exits without crashing.
- Browser console has no new hard errors.
- Continue/New Campaign, Skirmish, Hero Inventory, Settings, and Asset Gallery are reachable from an appropriate save state.

Browser Use preview sanity is optional after the automated suite. Use the local preview URL printed by Vite for a manual fallback; previous clean preview checks used `127.0.0.1` ports with browser console errors at 0. The current visible product copy is `Prototype v0.3` / `Cinderfen Route Baseline`.

Latest production preview smoke, 2026-05-11:

```text
PASS: http://127.0.0.1:4173/
PASS: page title was Ascendant Realms.
PASS: main menu was visible with Prototype v0.3 and Cinderfen Route Baseline copy.
PASS: Tutorial / Proving Grounds launched and exited without crashing.
PASS: New Campaign reached Campaign Map.
PASS: Continue Campaign reached Campaign Map.
PASS: Skirmish Setup opened.
PASS: browser console errors stayed at 0.
PASS: helper-owned preview process tree shut down.
NOTE: v0.11 added `npm run smoke:preview` after v0.10 exposed child-process cleanup friction. The final helper starts Vite preview through the local Vite CLI, uses the project Chromium GPU args, captures console errors, and shuts down the process tree it started.
```

After build-output or chunking changes, run a production preview smoke when feasible and confirm the main menu loads, `Prototype v0.3` / `Cinderfen Route Baseline` copy remains visible, key menu routes open without crashing, browser console errors stay at 0, and the preview process exits cleanly.

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
- Full human-paced Tutorial / Proving Grounds run using `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`, especially first-30-seconds clarity, twelve-step length, mobile-short overlay readability, building/training/rally timing, enemy pressure fairness, and no-reward completion satisfaction.
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
- `docs/V091_CONTROLLED_STYLE_FRAME_INTAKE_REPORT.md` summarizes the current non-runtime Cinderfen style-frame intake pipeline, including metadata templates, validation, scan results, screenshot comparison planning, and the future v0.9.2 review brief.
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md` summarizes the current Tutorial v2 onboarding refinement, including copy, overlay, completion, e2e lane, visual QA, and manual playtest checklist results.
- `ROADMAP.md` marks Cinderfen Overlook, Waystation, Crossing, Watch, Aftermath, the first no-reward Tutorial / Proving Grounds shell, the v0.7.3 pressure playtest gate, v0.8 technical/visual foundation gate, v0.8.1 manifest/screenshot gate, v0.8.2 source/license screenshot gate, v0.9 style-frame spec gate, v0.9.1 intake gate, and v0.10 Tutorial v2 refinement as done, with the next recommended player-facing phase set to v0.10.1 only after Emmanuel's manual checklist feedback.
- `LLM_GAME_HANDOFF.md` marks the current state as the v0.10 tutorial onboarding refinement and warns future sessions not to add rewards, persistence, maps, units, factions, broad systems, generated art, imported art, or runtime visual replacement before their gates are explicit and green.
