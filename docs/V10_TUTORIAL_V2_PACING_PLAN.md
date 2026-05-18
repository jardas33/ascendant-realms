# v0.10 Tutorial v2 Pacing Plan

Date: 2026-05-11

Scope: implementation plan for Tutorial / Proving Grounds onboarding refinement after `docs/V10_TUTORIAL_V2_AUDIT.md`.

This plan intentionally keeps v0.10 inside tutorial copy, hint clarity, overlay hierarchy, completion clarity, test documentation, and review documentation. It does not add maps, units, factions, rewards, save persistence, campaign progression, workers, construction AI, economy AI, crafting, diplomacy, procedural generation, desktop packaging, generated art, runtime art replacement, or broad gameplay systems.

## Pacing Decision

Keep Tutorial / Proving Grounds as a twelve-step linear path for v0.10.

The audit found the tutorial is long but coherent. The safest refinement is to shorten and clarify the language while preserving the current step IDs, completion signals, test hooks, no-reward runtime, and no-save policy.

## Step Plan

| Step | v0.10 Decision | Planned Change |
| --- | --- | --- |
| Camera Controls | Keep unchanged structurally | Shorten and frame the "why": keep Aster in view before orders. |
| Select Hero | Keep unchanged structurally | Clarify that selecting Aster reveals command/ability context. |
| Move Hero | Keep unchanged structurally | Clarify selected-unit right-click movement and use "near the road." |
| Capture Crown Shrine | Keep unchanged structurally | Explain that blue ownership starts battle income. |
| Gather Resources | Keep unchanged structurally | Explain Crowns as spendable only during this battle. |
| Select Command Hall | Keep unchanged structurally | Keep short; mention construction commands. |
| Build Barracks | Keep unchanged structurally | Clarify place-on-clear-ground and Esc retry. |
| Train Militia | Keep unchanged structurally | Clarify waiting for queue completion. |
| Set Rally Point | Keep unchanged structurally | Emphasize future trained units gather there. |
| Use Hero Ability | Keep unchanged structurally | Clarify Aster must be selected before pressing 1. |
| Hold Safe Pressure | Keep unchanged structurally | Soften pressure copy and emphasize grouping rather than rushing. |
| Finish Training | Keep unchanged structurally | Make completion warmer while preserving no XP, items, resources, campaign progress, and no-save clarity. |

## What Remains Unchanged

- Tutorial id `proving_grounds_basics`.
- Existing `first_claim` map.
- Existing hero, units, buildings, ability, capture site, enemy unit, and battle systems.
- Twelve-step order.
- Tutorial step ids.
- Tutorial completion signals.
- `noReward: true`.
- No tutorial persistence or tutorial-completed save flag.
- No campaign node completion or campaign reward.
- No runtime art or asset changes.
- Full tutorial completion smoke coverage for now.

## Shorter Copy Targets

The following steps need shorter, more action-oriented copy:

- `camera_controls`: reduce menu-like phrasing.
- `move_hero`: make the selected-unit/right-click relationship explicit.
- `gather_crowns`: define battle resources in one sentence.
- `train_militia`: avoid queue jargon where possible.
- `hold_safe_pressure`: reduce tension and state the tactic.
- `finish_training`: keep the policy clear but make the success moment feel complete.

## Hint Clarity Targets

The following hints should become clearer without becoming longer:

- Camera: `H` selects Aster; `Space` recenters after movement.
- Capture: hold the ring until it turns green.
- Building: `Esc` cancels placement if the ground is blocked.
- Training: the new Militia appears after the queue finishes.
- Rally: new units move to the marker after training.
- Ability: `1` casts the first hero ability only when Aster is selected.
- Pressure: group hero and troops; avoid chasing alone.
- Finish: exit to menu or start New Campaign when ready, with nothing saved.

## Split/Merge Decision

No step should be split in v0.10.

No step should be merged in v0.10.

Reason: the current sequence has one verb per step, and existing tests use those signals to prove no-save/no-reward behavior across the whole onboarding loop. Merging building/training/rally would reduce step count but would also make the densest section less readable for new players.

## Optional-Step Decision

No step should become optional in v0.10.

Reason: optional branching would add state and test complexity. It also risks implying tutorial persistence or skipping important no-reward proof. If future human play says the tutorial is too long, a later goal can design a "Basics only" route with explicit save-compatibility and test planning.

## Completion Policy

Tutorial completion must stay non-persistent.

Allowed v0.10 improvement: copy may say the training run is complete, that the player can start New Campaign when ready, and that no XP, items, resources, campaign progress, or save was granted.

Forbidden v0.10 changes:

- XP.
- Items.
- Resources.
- Achievements.
- Campaign progress.
- LocalStorage completion flag.
- Save-version bump.

## Overlay Hierarchy Plan

Phase 4 may make a small layout/hierarchy improvement if visual QA supports it:

- keep one overlay only;
- preserve current test ids;
- keep Exit Tutorial reachable;
- preserve overlay priority above battle-status feedback;
- avoid any full HUD redesign;
- avoid new animation or new art.

Likely safe improvements are minor spacing, title/instruction/hint hierarchy, button grouping, or mobile max-height adjustments.

## E2E Lane Decision

Keep full tutorial completion in smoke for v0.10 unless Phase 6 finds a concrete runtime problem.

Reason: the smoke test currently protects Tutorial launch, full step progression, no-save behavior, no-XP behavior, no campaign progress, no completion save, and exit behavior. Removing that path during copy/layout refinement would reduce confidence at exactly the wrong moment.

Phase 6 should still document lane placement and watch runtime. If smoke grows materially beyond the existing 6-7 minute watch band in a future release, keep Tutorial launch/exit in smoke and move full completion to release/deep.

## Implementation Boundaries

Allowed:

- tutorial copy;
- hints;
- overlay hierarchy;
- step labels;
- completion copy;
- focused tests for changed copy/layout;
- documentation.

Not allowed:

- new maps;
- new units;
- new factions;
- rewards;
- persistence;
- campaign integration;
- new systems;
- runtime art changes;
- full UI redesign.

## Verification Plan

Copy-only implementation should run:

- `npm test`;
- `npm run build`;
- `npm run validate:content`;
- `npm run validate:art-intake`;
- `npm run test:e2e:smoke`;
- `git diff --check`.

Overlay/layout implementation should additionally run:

- `npm run test:e2e:layout`;
- `npm run visual:qa`.
