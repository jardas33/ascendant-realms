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
- The local 3-way release shards remain a better-balanced local split than 2-way shards, but they do not replace the full release lane.
- The known Phaser vendor chunk warning remains expected and non-blocking.
- Full release e2e is intentionally slow and should use a long timeout.
- Production preview smoke should prefer `npm run smoke:preview` after `npm run build`.
- GitHub Actions now has a conservative `.github/workflows/ci.yml` dry-run: fast PR/push confidence runs the smaller `npm run test:e2e:smoke:fast` subset automatically, while full smoke, visual QA, hosted release groups, simulator, and full release remain local/manual release confidence.
- v0.11.6 keeps optional visual QA manual but makes hosted setup navigation more tolerant of transient `net::ERR_ABORTED`, frame-detach, and setup-navigation timeout errors while still requiring visible main-menu controls, and gives the 18-screenshot capture test a 420s budget.
- v0.11.7 splits optional visual QA into 5 smaller tests and adds per-screenshot logging, a 45s screenshot timeout, one screenshot retry, and retry metadata while keeping all 18 targets and console-error failure behavior.
- v0.11.8 keeps the 3-way release matrix intact while hardening hosted release setup navigation and actionability: no e2e `page.reload()` remains, deep-flow seeding uses the shared menu-ready path, `gotoReadyMainMenu` uses commit-stage app-root navigation with 3 attempts and same-URL interruption handling, and a narrow `clickReady` helper covers reported release-path click stalls without force-clicking.
- v0.11.11 keeps local full release, local 2-way shards, and local 3-way shards intact, but runs the manual GitHub release groups against production preview after run #17 showed hosted dev-server release groups still failed across app boot, actionability, and browser-context stability.
- v0.11.12 keeps hosted release coverage intact and hardens interaction determinism after run #19 showed remaining hosted failures in real DOM button clicks, battle-loaded waits, tutorial/layout box measurement, side-panel reachability checks, and canvas movement delivery.
- v0.16.1 keeps the automatic Fast confidence script unchanged but splits settings accessibility coverage into two focused `@ci-fast` tests so settings persistence and runtime battle application get separate browser contexts.
- v0.16.2 keeps the hosted release matrix shape unchanged after run #66, removes duplicated behaviour-mode switching from the older deep-battle HUD test because the dedicated hosted behaviour gauntlet owns that coverage, and gives only the settings runtime accessibility smoke a 90s hosted-safe budget.
- v0.16.3 keeps the same hosted smoke coverage after run #68, but gives only the settings runtime smoke battle `Menu`/`Resume` DOM buttons a short normal-click budget before verified DOM-control fallback so hosted CI does not burn the test timeout on repeated actionability waits.
- v0.16.4 keeps the same hosted deep-battle coverage after run #70, but treats `Moving` and `Repositioning` as valid right-click movement summaries and checks fog/cancel behaviour through durable scene state instead of transient status-line text that pressure messages can intentionally outrank.
- v0.16.5 keeps hosted deep-battle coverage intact after run #72, but splits the older broad minimap/fog/move/build/cancel HUD scenario into a movement/fog/move test and a focused Command Hall building placement/cancel test so each has its own hosted browser context and timeout budget.
- v0.16.6 keeps hosted first-campaign coverage intact after run #75, but lets the first-campaign training assertion fall back to the existing scene-backed training command helper if visible command clicks never expose a queue, and accepts newly trained Militia that have already reached the rally point.
- v0.16.7 changes runtime combat/control behaviour narrowly after Emmanuel's manual retest: melee visible-contact tolerance, local melee building contact, move-away suppression preservation, and conservative attack-hover hit tolerance. Rerun GitHub Actions CI Release Matrix Dry Run after push.
- v0.16.8 adds post-combat-fix verification docs, control-lab coverage for the v0.16.7 manual issues, and a public-repo safety audit. The v0.16.7 push run #78 only executed automatic Fast confidence, so manual CI Release Matrix Dry Run remains required for the enabled release lanes.
- v0.16.9 expands deterministic manual-retest proxy coverage to 18 control scenarios, adds first external tester docs, and keeps worker construction/design and visual-readability work docs-only. Push run #79 for v0.16.8 was Fast confidence only, then workflow-dispatch run #80 on the same `ad4eee0` commit passed Fast confidence, Release simulator, and the enabled hosted release matrix groups: deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke. Optional visual QA and full release e2e were skipped remotely.
- v0.16.10 freezes the current post-combat-fix candidate for Emmanuel retest or a 2-5 tester batch, adds backlog triage and public-safety docs, and expands the private package tester kit with release-candidate notes, Emmanuel retest checklist, short tester message, short feedback form, and route assignments. Push run #83 for `83f146e` passed Fast confidence only; no exact-final workflow-dispatch matrix was found for `83f146e`.
- v0.16.11 adds exact-final CI/release notes, ready-to-copy GitHub issue templates, tester launch packet index, and a no-code freeze note. Push run #84 for `7cc6eff` passed Fast confidence only; no exact-final workflow-dispatch matrix was found for `7cc6eff`. Run #80 on `ad4eee0` remains the enabled release-matrix evidence for the post-v0.16.7 runtime stack.
- v0.16.12 changes runtime combat/control narrowly after Emmanuel's `ec0608a` Tutorial retest: stationary visible-contact melee reacquisition, post-target-death Hold Ground contact rules, immediate melee contact over distant explicit targets, and top/head hover tolerance. Rerun GitHub Actions CI Release Matrix Dry Run after push.
- v0.16.13 follows the failed `bd26de3` package retest and widens only the local melee visible-contact boundary from the 57px Stone Imp cutoff to cover the 64px browser/manual proxy case. Rerun GitHub Actions CI Release Matrix Dry Run after push.
- v0.17 starts the post-combat-control polish/design line: Tutorial objective panel drag/Hide/Reset is session-only, Tutorial enemy escalation uses existing Story pacing only in Tutorial launches, and worker economy remains design-only. No worker construction, save migration, runtime art/assets, or global balance rewrite is included.
- v0.17.1 is a narrow Tutorial polish follow-up after Emmanuel's 171ba86 retest: whole safe-panel drag, existing-floating-text incoming `HIT -N` player damage feedback, and slower Tutorial-only enemy income/training/attack pacing. No worker construction, global AI/balance, save, art, unit/building/map/faction, or combat-control rewrite is included. Rerun GitHub Actions after push because runtime Tutorial behaviour changed.
- v0.17.2 is a narrow Tutorial polish follow-up after Emmanuel's a990f11 retest: Stone Imp hits against Aster now show compact incoming `-N` damage, incoming direct damage no longer includes `HIT`, and Tutorial-only enemy training/income/attack pacing is eased further. No worker construction, global AI/balance, save, art, unit/building/map/faction, or combat-control rewrite is included. Rerun GitHub Actions after push because runtime Tutorial behaviour changed.
- v0.17.3 is a narrow Tutorial/combat UI follow-up after Emmanuel's e448d18 retest: small melee units share the visible-contact floor for troop/Stone Imp/Wild Hound adjacency, explicit attack-target path failures suppress the no-path floating warning, selected side panel Hide/Show is session-only, and command buttons show explicit `Cost: ...` text. No worker construction, global AI/balance, save, art, unit/building/map/faction, or economy rewrite is included. Rerun GitHub Actions after push because runtime combat/UI behaviour changed.
- v0.17.4 is a narrow production-spawn/movement follow-up after Emmanuel's 532007d retest: trained units resolve spawn points against pathfinding/building-footprint clearance, and move-ordered units recover from blocked building start cells. No worker construction, global AI/balance, save, art, unit/building/map/faction, economy rewrite, or Tutorial pacing change is included. Rerun GitHub Actions after push because runtime movement/production behaviour changed.
- v0.17.5 fixes near-base invisible blockers by making exact world-point walkability use padded building rectangles inside coarse static cells and by allowing exact walkable endpoints. The final v0.17.5 handoff package was clean, and the GitHub Actions release matrix was green before v0.18 started.
- v0.18 adds the first Worker construction foundation only: Command Hall trains Worker, Worker builds Barracks, assigned Worker proximity gates construction progress, incomplete Barracks cannot produce, and completed Barracks keeps existing production. Command Hall no longer exposes direct Barracks/Mystic Lodge/Watchtower construction commands; Tutorial keeps its step count but routes the Barracks objective through Worker construction. No harvesting, repair, enemy construction AI, multiple-worker acceleration, save migration, new factions/maps, Patrol, formations, or runtime art/assets are included. Rerun GitHub Actions after push because runtime construction/production behavior changed.
- v0.18.2 expands Worker construction to the existing player building set only: Barracks, Mystic Lodge, and Watchtower. Command Hall remains Worker-training only, incomplete Watchtowers cannot attack, Tutorial keeps the Worker Barracks route, and no harvesting, repair, enemy construction AI, save migration, new factions/maps, Patrol, formations, runtime art/assets, or global economy rebalance are included. Rerun GitHub Actions after push because runtime construction options changed.
- v0.18.3 fixes Worker construction move-away/pause/resume and compact building-cluster pathing only. Explicit player move/attack orders pause construction intent, construction resumes only when the assigned Worker returns to range or construction intent is reissued, exact blocker interiors remain solid, and exact open edge points stay reachable. Rerun GitHub Actions after push because runtime construction/pathing changed.
- v0.18.3 baseline accepted after GitHub Actions CI Release Matrix Dry Run #26365296115 passed on `main` / `ce43d0e`: Fast confidence, Release simulator, and all six hosted release-matrix groups succeeded. Treat `ascendant-realms-private-playtest-ce43d0e` as the current Worker construction foundation baseline.

## Required Automated Checks

1. Unit and pure-rule tests:

```bash
npm test
```

Expected current prototype result:

```text
PASS: 46 test files, 351 tests
```

Current v0.15 checkpoint result:

```text
PASS: 55 test files, 393 tests
```

Current v0.16.2 checkpoint result:

```text
PASS: 56 test files, 406 tests
```

Current v0.16.7 checkpoint result:

```text
PASS: 57 test files, 414 tests
```

Current v0.16.8 checkpoint result:

```text
PASS: 57 test files, 414 tests
```

Current v0.16.9 checkpoint result:

```text
PASS: 57 test files, 415 tests
```

Current v0.16.12 checkpoint result:

```text
PASS: 57 test files, 421 tests
```

Current v0.17 checkpoint result:

```text
PASS: 57 test files, 422 tests
```

Current v0.17.1 checkpoint result:

```text
PASS: 58 test files, 425 tests
```

Current v0.17.4 checkpoint result:

```text
PASS: 60 test files, 431 tests
```

Current v0.18 checkpoint result:

```text
PASS: 61 test files, 440 tests
```

Current v0.18.2 checkpoint result:

```text
PASS: 61 test files, 442 tests
```

Current v0.18.3 checkpoint result:

```text
PASS: 61 test files, 450 tests
```

Current v0.16.13 checkpoint result:

```text
PASS: 57 test files, 421 tests
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

4. Browser smoke lanes:

```bash
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
```

Expected current prototype result:

```text
PASS: 8 Playwright tests for smoke:fast
PASS: 14 Playwright tests
```

`npm run test:e2e:smoke:fast` runs the eight `@ci-fast` smoke checks used by automatic GitHub Fast confidence: main menu, hero name input, Tutorial entry/return, Tutorial exit without saving, Settings persistence, Settings runtime accessibility in battle, New Campaign map/locked-node checks, and inventory reachability.

`npm run test:e2e:smoke` runs all 14 tests in `tests/e2e/smoke.spec.ts` and is the full smoke browser check. It keeps main menu, Tutorial / Proving Grounds no-reward completion and exit, Settings, New Campaign, campaign launch, Cinderfen reward/save/duplicate-prevention, skirmish, difficulty, and inventory smoke coverage visible. The v0.10 tutorial e2e lane review keeps full Tutorial completion in smoke while the lane remains inside the local watch band; move completion deeper only if local smoke repeatedly grows beyond that band. v0.10 did not add smoke tests or change lane counts.

v0.11.3 gives only `settings screen persists accessibility options` a 60s per-test budget after GitHub Actions evidence showed this combined settings-persistence plus in-battle runtime-application check can exceed the global 35s Playwright timeout on hosted runners. The test remains in smoke and keeps its real persistence/runtime assertions. If `campaign Border Village launches a battle scene` fails immediately after a settings timeout, first treat it as possible browser/context cascade; if it fails again after settings passes, investigate it independently.

v0.16.1 supersedes the combined settings path shape for Fast confidence: `settings screen persists accessibility options @ci-fast` now covers save/reopen persistence and localStorage/document dataset assertions, while `settings accessibility options apply in battle @ci-fast` covers floating text disabled, fog override, colorblind minimap runtime state and marker colors, and battle pause/resume. v0.16.2 keeps the persistence test at a scoped 60s budget and gives only the runtime battle-application test a scoped 90s budget after GitHub run #66 showed hosted production-preview smoke could exceed 60s around battle resume. v0.16.3 keeps the assertions and timeout but shortens only the settings runtime smoke Menu/Resume normal-click attempts before verified DOM-control fallback, because run #68 showed both DOM fallbacks fired only after hosted CI had already spent the test budget. Inventory remains a separate `@ci-fast` smoke test; if it fails during browser context setup immediately after settings failures, first investigate settings/context pressure before changing inventory behavior.

v0.11.4 stabilizes seeded smoke setup by waiting for a ready main menu before localStorage mutation and navigating back to `/` after writing seeded saves instead of relying on `page.reload()`. `skirmish difficulty selection changes fog and starting pressure` now has a scoped 60s budget because it launches two seeded battles back-to-back and GitHub Actions evidence showed the seed/reload path could exceed the global timeout. The test remains in smoke and keeps its fog/pressure assertions.

v0.11.8 extends the same hosted-safe navigation rule to deep-flow and extended smoke release paths: remaining raw e2e reloads were replaced with app-root navigation plus real main-menu assertions, and reported release-path clicks now use `clickReady` without `force`. Full smoke remains the 12-test coverage lane.

5. Full browser release-gate suite:

```bash
npm run test:e2e:release
```

Expected current prototype result:

```text
PASS: 67 Playwright tests
```

Current v0.16.7 checkpoint result:

```text
PASS: 79 Playwright tests
```

Current v0.15 checkpoint result:

```text
PASS: 75 Playwright tests
```

Current v0.16.4 checkpoint result:

```text
PASS: 77 Playwright tests
```

`npm run test:e2e` also remains the full Playwright suite. Use a long timeout. The full suite intentionally runs with one worker for stability. The v0.16.4 checkpoint full release gate is 77 tests across the release spec set while smoke is 14 tests. The v0.16.4 all-in-one release run took about 40.9 minutes locally on Windows; set command timeouts accordingly.

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

v0.11.12 keeps the explicit hosted release groups against production preview through `playwright.hosted-release.config.ts`, with additional test-only interaction hardening for hosted DOM controls, battle-loaded readiness, layout measurement, side-panel scrolling, and canvas movement:

```bash
npm run test:e2e:release:hosted:deep-meta
npm run test:e2e:release:hosted:deep-battle
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run test:e2e:release:hosted:layout-core
npm run test:e2e:release:hosted:layout-cinderfen
npm run test:e2e:release:hosted:smoke
```

All six hosted groups must pass to equal the same full release suite in GitHub Actions; the v0.16.4 checkpoint hosted group counts are 12 deep-meta, 12 deep-battle, 7 deep-campaign-pressure, 20 layout-core, 12 layout-cinderfen, and 14 smoke tests. They are additive, manual-only CI ergonomics for hosted runners and do not remove or replace the full release lane, the 2-way scripts, or the local 3-way scripts. The hosted groups intentionally avoid `--fully-parallel` and use production preview instead of Vite dev server after GitHub run #17 showed dev-server hosted release groups still produced seed/navigation, actionability, layout, and extended-smoke instability. Hosted helpers keep assertions intact while allowing a verified DOM click fallback only for real enabled DOM controls after normal Playwright click actionability fails. Canvas/world actions still use real pointer input. v0.16.2 keeps behaviour-mode switching coverage in the dedicated hosted behaviour gauntlet instead of duplicating those transitions inside the older minimap/fog/build/cancel/command-hall HUD test. v0.16.4 keeps that older HUD test focused on minimap/fog/build/cancel/command hall behaviour and asserts fog/cancel via scene state when hosted pressure messages can legitimately occupy the status line.

Run `npm run build` before using these hosted scripts locally. The GitHub release matrix jobs already run `npm run build` before the hosted group command.

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
npm run test:e2e:smoke:fast
npm run smoke:preview
```

Manual `workflow_dispatch` inputs:

| Input | Runs | Use when |
| --- | --- | --- |
| `run_visual_qa` | `npm run visual:qa` and uploads `visual-qa/latest/` | Human screenshot review is needed. |
| `run_release_matrix` | Explicit hosted release groups plus `npm run playtest:sim` | CI release gate dry-run or pre-freeze confidence on GitHub-hosted runners. |
| `run_full_release` | `npm run test:e2e:release` | Major freeze or one-command release-lane confirmation in CI. |

The workflow uses Node 22, `npm ci`, Playwright Chromium install, npm cache, no secrets, no paid services, and short-retention artifacts. v0.11.2 could not inspect remote Actions runs from the Codex environment because `gh` is unavailable, the GitHub connector token is expired, and unauthenticated Actions API access returns `404 Not Found`. Use `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md` to collect the first hosted-run URL, `fast-confidence` duration, `smoke:preview` result, manual-job status, and artifact evidence from GitHub UI. Do not weaken local release gates until CI has proven itself on the remote.

v0.11.6 remote evidence confirmed automatic Fast confidence was green on commit `1948ce5`, then showed the manual `Optional visual QA` job timing out during setup navigation rather than failing a screenshot or console-error assertion. v0.11.7 remote evidence on commit `caeff57` then showed navigation was no longer the issue, but a hosted `page.screenshot` call hung around the Cinderfen Crossing tablet capture. The visual QA job remains manual and coverage-preserving; rerun it from GitHub UI when human screenshot review is needed and inspect `visual-qa-latest` for `index.md`, 18 screenshots, 5 capture groups, screenshot retry status, and 0 browser console errors.

v0.11.8 remote evidence showed the manual 3-way release matrix was the remaining hosted lane: shard 1 failed in deep-flow `seedSave` on raw reload, shard 2 failed in seeded Cinderfen layout setup navigation, and shard 3 stalled on Broken Ford actionability. Rerun the manual `run_release_matrix` workflow input after v0.11.8 and check that retries are logged with context and recover without missing any release tests.

v0.11.9 remote evidence showed the v0.11.8 helper hardening was not enough for GitHub-hosted wall-clock limits: shard 1 and shard 2 hit the 35-minute job timeout, while shard 3 still showed hosted browser/context instability in extended smoke. The manual `run_release_matrix` input now runs six hosted shards named `shard-1-of-6` through `shard-6-of-6` with a 45-minute per-shard timeout, plus the unchanged release simulator. The old hosted 3-way jobs should not appear in new manual release-matrix runs, but the local 3-way scripts remain available.

v0.11.10 remote evidence on run #15 showed the v0.11.9 native 6-way split was still unstable across all hosted shards, with seed setup navigation aborts, right-click movement actionability, layout launch timing, and extended-smoke seeded campaign failures. The manual `run_release_matrix` input now runs explicit hosted groups named `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`, plus the unchanged release simulator. If rerunning the matrix, expect those six group names rather than `shard-1-of-6` through `shard-6-of-6`.

v0.11.11 remote evidence on run #17 showed the explicit groups were still failing when hosted against Vite dev server. The hosted group scripts now use `playwright.hosted-release.config.ts`, which starts `npm run preview:hosted` on `127.0.0.1:5173` and adds hosted-only Chromium stability flags. The workflow already uses `npx playwright install --with-deps chromium`; no dependency-install change was needed.

v0.11.12 remote evidence on run #19 showed `deep-meta` passing on production preview while `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke` still failed around hosted interaction determinism: Build Barracks click actionability, `Moving` vs `Guarding`, minimap readiness, tutorial-next layout boxes/click hangs, and side-panel command measurement. Rerun the manual `run_release_matrix` workflow input after v0.11.12 and inspect whether any remaining failure is app boot, battle-loaded readiness, DOM actionability, canvas movement, layout measurement, or browser/page/context closure.

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

For v0.16 RTS control/behaviour diagnostics, also run:

```bash
npm run playtest:controls
npm run playtest:controls:extended
npm run playtest:controls:verify
```

Expected v0.16 result:

```text
PASS: normal control lab writes 18 scenario rows
PASS: extended control lab writes 5 deterministic iterations / 90 scenario rows
PASS: verifier checks unique scenario ids, allowed verdicts, metric availability, Markdown/dashboard consistency, and no invented human-feedback claims
```

These commands regenerate `PLAYTEST_CONTROL_BEHAVIOUR_LAB.md`, `PLAYTEST_CONTROL_BEHAVIOUR_LAB.json`, `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.md`, `PLAYTEST_CONTROL_BEHAVIOUR_EXTENDED.json`, `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.md`, and `PLAYTEST_CONTROL_BEHAVIOUR_DASHBOARD.json`. They are deterministic automated evidence only; they do not replace Emmanuel's manual retest and are not balance proof.

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
PASS: 5 Playwright visual QA capture tests
18 review screenshots generated under visual-qa/latest/
Browser console errors recorded in the generated index: 0
Generated index summary records screenshot count 18, console error count 0, desktop/tablet/mobile viewport coverage, capture groups, and screenshot retry status
```

This v0.8.2 lane is optional and review-oriented. It captures main menu, Asset Gallery, Hero Inventory, Tutorial desktop/mobile, campaign map, route-complete campaign map, Skirmish Setup, Cinderfen Crossing desktop/tablet, Cinder Shrine, Crossing pressure warning, Cinderfen Watch, Watch pressure warning, and victory/defeat Results views. It is not a pixel-perfect visual regression test and it does not replace smoke, layout, release, content validation, or simulator gates. Generated screenshots are intentionally ignored by git.

v0.11.6 keeps all 18 targets and console-error failure behavior intact. The single capture test now has a 420s budget because GitHub-hosted runners showed the prior 240s limit could expire during setup navigation, and the shared app-boot helper retries only transient setup-navigation aborts/timeouts before requiring the real main menu.

v0.11.7 supersedes the single-test visual QA shape: the same 18 captures now run as 5 smaller tests with fresh pages, per-screenshot `START`/`DONE` logs, a 45s screenshot timeout, one retry for screenshot timeout/capture failures, and index retry metadata. If hosted visual QA fails, use the last `[visual-qa] START`, `FAIL`, or `RETRY` line to identify the exact screenshot target before changing the harness again.

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

## Private Playtest Package Check

For private human playtest distribution, build and verify the package after the normal gate:

```bash
npm run package:playtest
npm run verify:playtest-package
```

The package is written under ignored `artifacts/playtest/ascendant-realms-private-playtest-<commit>/`. Send that folder or a manual zip, not the full repo. The verifier checks the built game, tester README, feedback form, route assignment plan, v0.16 control retest materials, v0.16.12 and v0.16.13 retest/fix notes, build metadata, local server helpers, package-safe relative asset URLs, and absence of `node_modules`, `.git`, raw private feedback folders, and obvious secret files.

If the package name ends in `-dirty`, the working tree had uncommitted changes when it was created. Regenerate after the checkpoint commit before sending to outside testers.

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
