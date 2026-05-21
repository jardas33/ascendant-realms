# v0.16.5 Hosted Deep-Battle Command Hall Split Audit

Date: 2026-05-20

Scope: diagnose the remaining GitHub Actions CI Release Matrix Dry Run #72 hosted deep-battle failure after v0.16.4. This audit is limited to release-matrix smoke/deep-battle stabilization. It does not start v0.17 and does not change gameplay, balance, save format, runtime art/assets, behaviour modes, package materials, or release matrix structure.

## Remote Evidence

- Workflow: CI Release Matrix Dry Run #72
- Actions run id: `26198333332`
- Commit: `9c8e694177e6a60e423539eb202393a3a94071b9`, `Checkpoint v0.16.4 hosted deep-battle movement command stabilization`
- Failed job: `Release matrix (deep-battle)`
- Green jobs: Fast confidence, Release simulator, Release matrix smoke, deep-meta, deep-campaign-pressure, layout-core, and layout-cinderfen
- Skipped jobs after failure: Optional visual QA and Full release e2e
- Failed test: `tests/e2e/deep-flow.spec.ts:1707:3`, `battle HUD supports minimap movement, fog toggle, building placement cancel, and command hall actions @hosted-deep-battle`
- Result: 1 failed, 11 passed in the deep-battle shard

Artifact upload failed because GitHub artifact storage quota was hit, so traces/videos/error-context files were not downloadable through the connector. The job logs were available and were enough to identify the failing step.

## Failure Shape

Run #72 no longer failed at the earlier movement-order assertion fixed in v0.16.4. The same broad HUD test reached the later Command Hall building placement section and timed out at the first Barracks build command.

First attempt:

```text
Test timeout of 120000ms exceeded.
Error: deep-flow build Barracks command attempt 1: click failed after 1 attempt(s):
deep-flow build Barracks command attempt 1: expected target to be visible
Locator: locator('button[data-action=\'build\'][data-id=\'barracks\']')
```

Retry #1:

```text
Test timeout of 120000ms exceeded.
Error: deep-flow build Barracks command attempt 1: click failed after 1 attempt(s):
deep-flow build Barracks command attempt 1: expected target to be enabled
Locator: locator('button[data-action=\'build\'][data-id=\'barracks\']')
```

The failing stack was:

```text
tests/e2e/shared-helpers.ts:493 clickReady
tests/e2e/deep-flow.spec.ts:130 clickBattleCommand
tests/e2e/deep-flow.spec.ts:301 clickBattleCommandUntilEffect
tests/e2e/deep-flow.spec.ts:2123
```

## Diagnosis

The root cause is an overloaded hosted deep-battle test, not a gameplay/runtime regression.

The original test covered all of these in one browser context:

- Battle boot and initial selection
- Attack cursor intent and refresh stability
- Empty click safety and target attack order
- Marquee release over HUD and minimap
- Minimap camera movement
- Fog toggle
- Right-click move command
- Command Hall selection
- Barracks placement mode
- Placement cancel

v0.16.2 removed duplicated behaviour-mode switching from this test, and v0.16.4 fixed valid `Moving` / `Repositioning` movement summaries plus transient status-line checks. Run #72 showed the test still reached the late Command Hall section too close to the 120s hosted budget. Playwright then interrupted `clickReady` while it was still trying to verify the Barracks build command.

The dedicated behaviour mode gauntlet continued to run later in the same deep-battle shard and was not the failed test. Command button coverage also passed in later tests, including the hover-stability command test and first campaign build/train path. That points to scenario length and hosted timing pressure in the older broad HUD test, not a broken Barracks command or Command Hall runtime.

## Explicit Answers

Why did smoke pass while deep-battle failed?

Smoke passed in run #72. The remaining red job was only `Release matrix (deep-battle)`, and the failing test was the older hosted deep-battle HUD/minimap/building scenario.

Why did the dedicated behaviour mode gauntlet pass while the older HUD test failed?

The dedicated gauntlet owns behaviour-mode coverage in a separate test with its own browser context and budget. The older HUD test failed later at Command Hall build placement, after movement/fog assertions, because it was still too broad for hosted CI timing.

Was `Target page/context/browser closed` the cause?

Not in run #72. The #72 evidence shows a direct test timeout while `clickReady` waited for the Barracks command button to be visible or enabled. Earlier page/context-closed messages were timeout consequences, not the root cause.

What is the smallest safe fix?

Split only the late Command Hall building placement/cancel assertions into their own hosted deep-battle test. Keep the original movement/fog/minimap/move coverage intact, keep Command Hall build/cancel coverage intact, and leave all runtime behaviour unchanged.

Which assertions remain protected?

- Initial battle selection still selects the hero and player units.
- Attack cursor intent, refresh stability, empty-click safety, and hostile left-click attack order remain asserted.
- Marquee release over HUD and minimap remains asserted.
- Minimap camera movement remains asserted.
- Fog toggle state remains asserted through scene state.
- Right-click move command remains asserted through `Moving` / `Repositioning` order summary.
- Command Hall side panel, Build section, Barracks placement mode, placement ghost offset, Escape cancel state, and placement banner removal remain asserted in the new focused test.
- Behaviour mode switching remains protected by the dedicated hosted behaviour mode gauntlet and unit tests.

## Not Changed

- Runtime gameplay: no
- Gameplay numbers: no
- Save format: no
- Runtime art/assets: no
- Behaviour modes: no
- Package materials: no
- GitHub workflow/release matrix: no
- Force clicks: no
- DOM fallback for canvas/world clicks: no
- Assertion weakening: no
