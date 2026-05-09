# Command Log V1 Report

Last updated: 2026-05-08

## Summary

Command Log V1 is implemented as a tiny test-only semantic helper for one Tutorial / Proving Grounds completion path.

It is useful enough to keep, but it should remain test-only. It does not prove production determinism, does not replace visible e2e assertions, and should not expand until the tutorial path stays stable through at least one more release-style gate.

## What Was Implemented

- Added `tests/e2e/semantic-command-log.ts`.
- Defined `SemanticCommand`, `SemanticCommandAction`, `SemanticCommandTargetType`, and `SemanticCommandExecutor`.
- Added `runSemanticCommandLog()` for sequential command execution.
- The runner validates stable command ids, rejects duplicate ids, wraps each command in `test.step`, and returns a result map keyed by command id.
- Refactored exactly one test: the Tutorial / Proving Grounds full completion smoke path in `tests/e2e/smoke.spec.ts`.
- Updated `docs/COMMAND_LOG_V1_TEST_ONLY_PLAN.md` with the actual implementation result.

## Test Using It

Current first adopter:

- `tests/e2e/smoke.spec.ts`
- Test: `tutorial entry launches a no-reward shell and returns to menu`

The command log drives the middle tutorial progression:

- Advance to each guided step.
- Select hero.
- Move hero.
- Capture Crown Shrine.
- Tick Crown income.
- Select Command Hall.
- Build Barracks.
- Train Militia.
- Set rally point.
- Use Rally Banner.
- Defeat the small Raider pressure.
- Advance to the final no-reward step.
- Assert no save pollution before completion.

The test still keeps the important contract assertions visible:

- Launch mode is `tutorial`.
- Map is `first_claim`.
- Source is `proving_grounds_basics`.
- Rewards are disabled.
- Hero is transient Aster.
- No save exists before progression.
- Barracks build, Militia training, rally, and ability actions return expected results.
- Safe pressure grants zero hero XP and zero runtime XP.
- Final copy says no rewards and campaign progress.
- Completion returns to the main menu.
- The session-only completion notice appears.
- No save exists after completion.

## What It Makes Clearer

- The tutorial's twelve-step flow is now readable as a sequence of semantic actions instead of a long hand-written ladder of direct helper calls.
- Playwright trace/test-step output should have clearer labels for the tutorial path.
- The middle action sequence is easier to scan for missing tutorial beats.
- The helper creates a small foundation for future semantic test logs without adding production replay code.

## What It Does Not Solve

- It does not make Phaser timing deterministic.
- It does not replay raw user input.
- It does not verify every command through real pointer movement.
- It does not replace human playtesting.
- It does not replace layout, smoke, release, simulator, save fixture, or content-validation gates.
- It does not provide production replay, multiplayer lockstep, or command recording.

## Should It Expand?

Recommendation: not immediately.

Keep V1 at one consumer until:

- The tutorial helper stays green through the final v0.6 full gate.
- The command-log report remains accurate after any accessibility/layout changes.
- The smoke lane remains within the current runtime watch band.
- A second candidate has a clear maintenance win.

If expanded later, the best next candidate is the existing deep-flow test:

- `first campaign battle path covers capture, build, train, rally, and victory rewards`

That path already uses deterministic setup and safe hooks, but it includes campaign reward persistence. It should only be refactored after the tutorial command log proves stable.

## Why It Should Remain Test-Only

- Production replay would need explicit seed control for item rewards, affixes, entity ids, future randomized AI, and any future procedural systems.
- Production replay would need a stable simulation tick model that the current browser/Phaser loop does not guarantee.
- Production replay would be save-format and compatibility work, which is outside v0.6.
- Test-only semantic commands provide useful organization without promising player-facing replay correctness.

## Risks

- The helper can hide UI bugs if future commands lean too heavily on scene hooks.
- A large command vocabulary could become harder to read than direct Playwright code.
- The helper could become an unofficial test API if many flows depend on private scene details.
- Step title/copy assertions can become brittle if command records overassert prose.
- Runtime can grow if future command logs add waits or duplicate existing release coverage.

## Guardrails

- Keep production code free of command-log imports.
- Keep command logs semantic, not coordinate-based.
- Keep high-value assertions visible near the test.
- Expand one path at a time.
- Preserve normal e2e assertions and lane coverage.
- Do not add save fields, replay UI, rewards, maps, units, factions, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, desktop packaging, external assets, or broad systems.

## Verification

Phase 7 implementation verification:

```text
npm test
PASS: 42 files / 315 tests.

npm run build
PASS with the known Phaser vendor warning.
App JS: assets/index-BU3yhAtG.js, 459.51 kB / gzip 123.51 kB.
CSS: assets/index-BzEbtAWy.css, 44.19 kB / gzip 9.11 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.

npm run validate:content
PASS.

npx playwright test tests/e2e/smoke.spec.ts -g "tutorial entry launches" --reporter=line
PASS: 1 test in 26.5s.

npm run test:e2e:smoke
PASS: 12 tests in 4.8m.

npm run test:e2e:release
PASS: 65 tests in 28.8m.

git diff --check
PASS.
```

## Next Candidate

Next candidate only after the final v0.6 gate: a campaign deep-flow command log for capture, build, train, rally, and victory rewards. Keep it release/deep-only unless it materially improves smoke reliability.
