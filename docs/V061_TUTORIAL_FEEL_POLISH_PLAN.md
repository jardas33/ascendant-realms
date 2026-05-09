# v0.6.1 Tutorial Feel Polish Plan

Last updated: 2026-05-09

## Purpose

This plan continues from the final v0.6 onboarding foundation gate. The goal is a small human-feel polish pass for Tutorial / Proving Grounds using existing content only.

This is not a content expansion. It must not add maps, units, factions, rewards, save-version changes, tutorial persistence, campaign progression, workers, enemy construction, diplomacy, procedural generation, crafting, multiplayer, desktop packaging, external generated assets, or broad systems.

## Current Baseline

The final v0.6 gate is clean and synced with origin:

- `npm test`: 42 files / 315 tests.
- `npm run build`: passes with the known Phaser vendor warning.
- `npm run validate:content`: passes.
- `npm run test:e2e:smoke`: 12 tests in about 5 minutes.
- `npm run test:e2e:release`: 65 tests in about 29 minutes.
- `npm run playtest:sim`: 255 runs across 85 campaign battle nodes.
- Production preview smoke passed.

The tutorial is:

- Main-menu launched.
- Existing-content-only on `first_claim`.
- No-reward.
- Non-persistent.
- Twelve linear steps.
- Covered by unit, content-validation, smoke, layout, release, simulator, and preview gates.

## Phase Plan

### Phase 0: Repository Integrity

Confirm the branch is clean and synced, then run the baseline pure gates:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `git diff --check`

No commit is needed if nothing changes.

### Phase 1: Evidence-Based Polish Plan

Create this plan and record the current risks before implementation.

Inputs:

- `LLM_GAME_HANDOFF.md`
- `docs/V06_TUTORIAL_ONBOARDING_REPORT.md`
- `docs/TUTORIAL_READABILITY_SURROGATE_REVIEW.md`
- `docs/V06_TUTORIAL_FEEL_AUDIT.md`
- `src/game/data/tutorials.ts`
- `src/game/ui/hudPanels/TutorialPanel.ts`
- `src/game/styles/battle-feedback.css`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/layout.spec.ts`

### Phase 2: Visible Browser Feel Pass

Run a production or preview browser pass and inspect:

- Main-menu Tutorial entry clarity.
- First objective overlay readability.
- Mobile-ish overlay density.
- Whether the overlay competes with the battle HUD.
- Completion/exit clarity.
- Console errors.

Capture findings in `docs/V061_TUTORIAL_FEEL_REVIEW.md`.

### Phase 3: Small Polish Only If Evidence Supports It

Allowed changes:

- Copy tightening.
- Hint clarification.
- Completion copy warmth while keeping no-reward clarity.
- Small overlay hierarchy/spacing improvements.
- Test assertions that protect the polish.

Not allowed:

- New tutorial steps.
- Removing core concepts.
- Gameplay/balance changes.
- Rewards.
- Persistence.
- Campaign integration.
- New content or broad systems.

### Phase 4: Verification And Handoff

Minimum final gate for source/UI changes:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- `npm run test:e2e:layout`
- `git diff --check`

Run production preview smoke if feasible. If only docs changed, the docs-only gate is enough.

Update:

- `LLM_GAME_HANDOFF.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- Any tutorial report touched by the polish.

Commit and push when green.

## Current Risk Map

| Risk | Current evidence | v0.6.1 stance |
| --- | --- | --- |
| Tutorial may feel long | 12 steps, full completion smoke uses hooks for time-heavy beats | Do not add steps; consider copy/hierarchy only. |
| Mobile-short comfort | Layout tests prove bounds, not human comfort | Review in browser and adjust spacing only if clearly cramped. |
| No-reward completion | Final step and session notice are explicit but plain | Make warmer only if no-reward language stays explicit. |
| Overlay/HUD attention | Overlay is pointer-light and in-bounds | Do not add extra panels; keep one overlay. |
| Command-log V1 | One smoke consumer, green | Do not expand in v0.6.1 unless a concrete failure shows need. |
| Release runtime | Green but slow | Preserve coverage; do not move lanes unless runtime regresses. |

## Phase 2-3 Result

The visible Browser pass is recorded in `docs/V061_TUTORIAL_FEEL_REVIEW.md`.

Evidence supported one small layout-priority polish: on a 360 x 640 viewport, the battle status banner painted over the first tutorial objective overlay. The fix gives `.tutorial-panel` explicit visual priority over transient battle feedback overlays and adds a responsive layout assertion that the tutorial overlay z-index stays above battle status feedback.

No tutorial copy, steps, gameplay behavior, rewards, persistence, campaign state, save version, maps, units, factions, balance, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, desktop packaging, external assets, or broad systems changed.

Focused verification:

```text
npm run test:e2e:layout -- --grep "tutorial entry"
PASS: 4 Playwright tests in 43.2s.
```

Final v0.6.1 verification:

```text
npm test
PASS: 42 test files, 315 tests.

npm run build
PASS: TypeScript compile and Vite production build with the known Phaser vendor warning.

npm run validate:content
PASS.

npm run test:e2e:smoke
PASS: 12 Playwright tests in 4.9m.

npm run test:e2e:layout
PASS: 25 Playwright tests in 12.4m.

Production preview Browser smoke
PASS: http://127.0.0.1:57919/ with Tutorial launch/exit and zero browser warnings/errors.
```

## Success Criteria

v0.6.1 succeeds if it leaves the project:

- Clean and synced after push.
- Still no-reward and non-persistent.
- Still existing-content-only.
- Easier to read or better documented based on visible review.
- Green on required tests.
- Clear about what still needs real human play.

## Stopping Conditions

Stop and report if:

- Tutorial polish would require a new map, unit, faction, reward, save field, or campaign integration.
- The overlay needs a broad redesign rather than small spacing/hierarchy work.
- E2E runtime becomes unstable or grows materially.
- Save/content validation becomes uncertain.
- Any gate repeatedly fails after focused fixes.
