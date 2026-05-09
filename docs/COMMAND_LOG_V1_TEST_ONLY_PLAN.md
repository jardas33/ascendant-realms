# Command Log V1 Test-Only Plan

Last updated: 2026-05-08

## Purpose

This plan turns the v0.5 command-log replay feasibility study into a concrete v0.6 implementation slice.

Command Log V1 is test-only. It is not a production replay system, not a save feature, not a multiplayer determinism layer, and not a player-facing command recorder.

## Scope

Allowed:

- A small TypeScript helper under `tests/e2e/`.
- Semantic commands that describe intent instead of raw pointer coordinates.
- Use of existing Playwright operations and existing safe e2e hooks.
- One first adopter test.
- Visible assertions before, during, and after the command log.
- Documentation of what the helper does and does not prove.

Not allowed:

- Production imports from the command-log helper.
- Production replay UI.
- Save fields or save-version changes.
- New maps, units, factions, rewards, tutorial persistence, campaign progression, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, or desktop packaging.
- Replacement of existing e2e assertions with opaque replay-only checks.

## First Target

Chosen target: Tutorial / Proving Grounds completion path.

This supersedes the v0.5 feasibility note's earlier first-campaign-battle recommendation because the playable tutorial now exists and is the safer V1 target:

- It is no-reward by design.
- It starts from a fixed main-menu launch.
- It uses existing `first_claim` content without campaign save state.
- It already has a twelve-step smoke flow with visible assertions.
- It already proves no save pollution and no XP/reward pollution.
- It aligns with the current v0.6 onboarding/testing foundation goal.

The first implementation should refactor exactly one tutorial completion test to use a command-log helper while keeping the important behavior assertions readable in the test file.

## Command Record Shape

Each command should be a small semantic record:

```ts
type SemanticCommand = {
  id: string;
  action: SemanticCommandAction;
  target?: {
    type: "testId" | "text" | "tutorialStep" | "battleEntity" | "semanticLocation";
    id: string;
  };
  expected?: {
    title?: string;
    progress?: string;
    text?: string;
    state?: Record<string, unknown>;
  };
  timeoutMs?: number;
  debugLabel?: string;
};
```

Field policy:

- `id`: stable command identifier for logs and failure messages.
- `action`: semantic action, not a raw click coordinate.
- `target`: the thing the command acts on.
- `expected`: optional state or copy expected after the command.
- `timeoutMs`: per-command timeout only when a command is known to take longer than normal.
- `debugLabel`: human-readable `test.step` label.

The helper should validate that every command has an `id` and `action`; deeper validation can stay small for V1.

## Supported V1 Commands

The command vocabulary should be intentionally narrow:

- `clickTestId`: click an element by `data-testid`.
- `clickText`: click visible text when a test id is not appropriate.
- `waitForStepText`: assert the current tutorial title/progress/copy is visible.
- `selectHero`: drive the existing tutorial-safe hero selection helper.
- `moveHeroToSemanticLocation`: move the hero to the existing tutorial-safe location.
- `captureSite`: use the existing safe capture hook for `crown_shrine`.
- `selectBuilding`: select an existing building such as Command Hall or Barracks.
- `buildBarracks`: place and complete the existing Barracks through the current tutorial smoke helper path.
- `trainMilitia`: train existing Militia through the current tutorial smoke helper path.
- `setRally`: set a Barracks rally point through existing scene behavior.
- `useHeroAbility`: cast the existing Rally Banner ability.
- `defeatEnemy`: resolve the existing small Raider pressure step.
- `assertNoSavePollution`: assert the save key has not been written.

V1 does not need every command to be used immediately. It should define the vocabulary around the tutorial completion path and use only what the first test needs.

## Runner Behavior

The runner should:

- Execute commands sequentially.
- Wrap each command in `test.step` using `debugLabel` or `id`.
- Throw a useful error for unsupported actions.
- Pass the full command record to the executor so the test can keep scenario-specific assertions visible.
- Avoid owning the whole test flow.

The first implementation can use a generic runner plus a tutorial-specific executor. That keeps the command log readable without hiding all gameplay assertions inside a black-box helper.

## Expected First Test Shape

The tutorial smoke should still show the important contract:

- Tutorial launch uses mode `tutorial`, map `first_claim`, source `proving_grounds_basics`, and `rewardsDisabled: true`.
- The save key is absent before progression.
- Each guided step is reached in order.
- The pressure step grants zero hero XP and zero runtime XP.
- The final step says no rewards and campaign progress.
- Completion returns to the main menu.
- The session-only no-reward notice appears.
- The save key remains absent.

Command logs should help organize the middle step sequence, not erase these assertions.

## Non-Goals

- Exact input replay.
- Frame-perfect or tick-perfect replay.
- Deterministic production simulation.
- Production command recording.
- Multiplayer/network replay.
- Save-file embedding.
- Browser-coordinate fixtures.
- A general quest or automation system.
- Replacing manual human playtests.

## Risks

- A semantic helper can hide UI regressions if it relies entirely on scene hooks.
- A too-generic command vocabulary can become harder to read than direct Playwright code.
- Command records can become brittle if they overfit step titles or incidental copy.
- Overuse could turn e2e tests into private-scene mutation tests instead of browser tests.
- If expanded too quickly, command logs could become an unofficial production API.

Mitigation:

- Keep the first command log in one test only.
- Keep launch, overlay, save, XP, final-copy, and return-to-menu assertions visible.
- Prefer stable step ids and test ids over incidental long prose.
- Do not import command-log helpers from production code.
- Review after one implementation before expanding.

## Implementation Phases

1. Add a test-only helper under `tests/e2e/semantic-command-log.ts`.
2. Define the minimal `SemanticCommand` and `SemanticCommandAction` types.
3. Add a generic sequential runner with `test.step` labels and unsupported-action errors.
4. Refactor the tutorial completion smoke's middle sequence into a visible command array.
5. Execute commands through existing Playwright and safe tutorial helper operations.
6. Keep existing no-save/no-XP/no-reward assertions.
7. Run smoke and release gates before committing.
8. Write `docs/COMMAND_LOG_V1_REPORT.md` after implementation, before any expansion.

## Expansion Policy

Do not add a second command-log consumer until the first report answers:

- Did the helper make the tutorial completion path easier to read?
- Did failures become easier to diagnose?
- Did runtime stay acceptable?
- Did the helper preserve meaningful UI assertions?
- Is the vocabulary stable enough for one campaign deep-flow candidate?

Likely next candidate after review: a campaign deep-flow path that already uses deterministic setup and safe hooks. Do not expand into production replay.
