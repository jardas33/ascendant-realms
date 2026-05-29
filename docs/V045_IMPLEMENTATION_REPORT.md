# v0.45 Act 1 Campaign Spine Implementation Report

Date: 2026-05-29

## Scope

v0.45 adds a content-driven Act 1 campaign spine over the existing Chapter 1 graph. It turns the current nodes into a clearer recommended progression from Tutorial / Proving Grounds, Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, Ashen Outpost, and replay/optional-objective cleanup.

## Runtime Changes

- Added `src/game/data/act1CampaignSpine.ts` with seven Act 1 steps.
- Added `CampaignActStepDefinition` metadata for step kind, pacing tier, mechanic focus, build tags, unlock summary, onboarding hint, Results hint, next action, and replay hint.
- Added `CampaignActSpineRules` helpers for recommended next step, node-to-step lookup, Act 1 step labels, locked reasons, and Results guidance.
- Updated campaign node details to show Act 1 role, pacing tier, unlock summary, locked reason, onboarding hint, and next action.
- Updated Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost copy to separate Tutorial / Proving Grounds from the first persistent campaign battle.

## Unlock Rules

No campaign graph rewrite was added. The existing unlock rules remain authoritative:

- Border Village starts available in a new campaign.
- Border Village first-clear unlocks Old Stone Road.
- Old Stone Road opens the existing branch to Aether Well Ruins, Bandit Hillfort, Refugee Caravan, and Marcher Camp.
- Ashen Outpost remains gated by Bandit Hillfort and Chapel of the Marches.
- Completed battle nodes remain replayable through the existing campaign map.
- Locked copy now names missing prerequisites when a node is not ready.

## Save Format

No save-version bump and no new save fields. Act 1 spine state is derived from content metadata plus existing campaign save fields: `completedNodeIds`, `unlockedNodeIds`, `lockedNodeIds`, `nodeRewardsClaimedIds`, and optional objective records.

## Verification

Focused verification completed before full release closeout:

```text
npm test PASS, 74 files / 570 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "first campaign battle path|Ashen Outpost special objectives|Old Stone Road victory" --reporter=line PASS, 3 hosted tests.
```

Final release verification is recorded in `docs/V047_IMPLEMENTATION_REPORT.md`.

## Deferrals

- No new Act 1 maps.
- No cinematic campaign sequence.
- No large quest/journal system.
- No branching story consequence layer.
