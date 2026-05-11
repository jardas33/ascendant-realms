# v0.10 Tutorial Copy Refinement Notes

Date: 2026-05-11

Scope: copy-only Tutorial / Proving Grounds refinement following `docs/V10_TUTORIAL_V2_AUDIT.md` and `docs/V10_TUTORIAL_V2_PACING_PLAN.md`.

This phase changes tutorial titles, instructions, and hints only. It preserves the existing map, step ids, completion signals, launch mode, no-reward policy, no-save policy, tests/selectors, runtime art, units, buildings, ability, and enemy pressure behavior.

## Copy Intent

The new copy makes each step answer three player questions:

- What should I do now?
- Why does this matter?
- What happens next?

The language stays short enough for the existing overlay and avoids adding lore, branch text, extra panels, or tutorial rewards.

## Title Changes

| Step id | Previous title | v0.10 title | Reason |
| --- | --- | --- | --- |
| `camera_controls` | Camera Controls | Find Your Army | More player-centered first step. |
| `select_hero` | Select Hero | Select Aster | Names the actual hero the player sees. |
| `move_hero` | Move Hero | Move Aster | Keeps selection and movement concrete. |
| `gather_crowns` | Gather Resources | Gather Battle Crowns | Distinguishes temporary battle income from campaign rewards. |
| `use_rally_banner` | Use Hero Ability | Cast Rally Banner | Names the actual ability. |
| `hold_safe_pressure` | Hold Safe Pressure | Group Up And Hold | Explains the tactic without implying a hidden system. |
| `finish_training` | Finish Training | Training Complete | Makes the final state clearer. |

Unchanged titles remain direct and understandable: Capture Crown Shrine, Select Command Hall, Build Barracks, Train Militia, and Set Rally Point.

## Instruction And Hint Changes

- Camera copy now tells the player to pan and keep Aster in view.
- Selection copy explains that selected units receive orders.
- Movement copy ties right-click movement to selected friendly units.
- Capture copy connects blue ownership to battle income.
- Resource copy explicitly says Crowns earned here are temporary and not saved rewards.
- Building and training copy clarifies clear-ground placement, Esc retry, queueing, and the unit joining after training.
- Rally copy explains that newly trained units move toward the marker.
- Ability copy says Aster must be selected before pressing 1.
- Pressure copy emphasizes grouping rather than chasing alone.
- Completion copy now says the player practiced the core loop while preserving explicit no XP, items, resources, campaign progress, and no-save messaging.

## Test Updates

Updated copy assertions in:

- `src/game/ui/hudPanels/TutorialPanel.test.ts`
- `src/game/tutorial/TutorialStepModel.test.ts`
- `tests/e2e/smoke.spec.ts`
- `tests/e2e/layout.spec.ts`

Selectors and test ids are unchanged.

## Remaining Work

Phase 4 should inspect overlay hierarchy after the new copy.

Phase 5 should refine the final completion/main-menu notice if the no-reward message can be clearer without adding persistence or rewards.

