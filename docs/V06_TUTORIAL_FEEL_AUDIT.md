# v0.6 Tutorial Feel Audit

Date: 2026-05-08

Status: automated human-feel surrogate audit for the playable Tutorial / Proving Grounds shell. Phase 2 applied copy-only polish based on this audit. This work does not change tutorial logic, rewards, save behavior, campaign progression, maps, units, factions, balance, desktop packaging, or broad systems.

## Scope

This audit reviews the current Tutorial / Proving Grounds shell using repository evidence only:

- Tutorial metadata in `src/game/data/tutorials.ts`.
- Step view-model behavior in `src/game/tutorial/TutorialStepModel.ts`.
- Overlay rendering in `src/game/ui/hudPanels/TutorialPanel.ts`.
- Overlay layout rules in `src/game/styles/battle-feedback.css`.
- Playwright smoke/layout coverage in `tests/e2e/smoke.spec.ts` and `tests/e2e/layout.spec.ts`.
- Save/persistence and no-reward documentation from the tutorial release gate.

No manual playtest was performed. Treat this as a structured risk map for the next small polish passes, not as proof that the tutorial feels good to a human.

## Automated Evidence

Current metadata shape:

| Evidence | Current value |
| --- | ---: |
| Tutorial count | 1 playable tutorial |
| Tutorial ID | `proving_grounds_basics` |
| Map | existing `first_claim` |
| Reward policy | `noReward: true` |
| Step count | 12 |
| Longest instruction | 14 words / 90 characters after Phase 2 copy polish |
| Longest hint | 10 words / 64 characters after Phase 2 copy polish |
| Unit coverage | `TutorialStepModel`, `TutorialPanel`, content validation, launch/runtime no-reward tests |
| Smoke coverage | Full launch, twelve-step completion, no-save/no-XP assertions, and exit path |
| Layout coverage | First objective overlay on desktop, tablet-short, mobile-tall, and mobile-short |

Current step order:

| # | Step | Required action | Instruction words | Hint words |
| ---: | --- | --- | ---: | ---: |
| 1 | Camera Controls | read instructions | 14 | 7 |
| 2 | Select Hero | select hero | 6 | 9 |
| 3 | Move Hero | move hero | 7 | 6 |
| 4 | Capture Crown Shrine | capture site | 13 | 9 |
| 5 | Gather Resources | wait for income | 9 | 8 |
| 6 | Select Command Hall | select building | 8 | 7 |
| 7 | Build Barracks | build structure | 9 | 10 |
| 8 | Train Militia | train unit | 8 | 10 |
| 9 | Set Rally Point | set rally | 9 | 10 |
| 10 | Use Hero Ability | use hero ability | 9 | 7 |
| 11 | Hold Safe Pressure | defeat enemy | 11 | 7 |
| 12 | Finish Training | finish | 13 | 10 |

## Findings

### 1. Tutorial Length

The current tutorial is long enough to teach the requested battle loop but short enough to remain a single onboarding shell. Twelve steps cover the promised concepts without adding campaign systems or new content.

Risk: first-contact players may feel the build/train/rally/ability/pressure chain is more than one sitting if they are still learning RTS input basics. The automated completion path also compresses time through scene hooks, so it does not measure real waiting fatigue.

Recommendation: keep the tutorial at twelve steps for now, but prioritize copy tightening and completion clarity before adding any new beat.

### 2. Number Of Steps

The twelve-step count is explicit in metadata, unit tests, and e2e assertions. That is good for safety because accidental step additions will show up in tests.

Risk: because every major concept has its own step, any future content addition could push the tutorial past a comfortable first-contact length.

Recommendation: treat twelve as the soft maximum for this shell. Future improvements should combine or polish beats, not expand the sequence.

### 3. Step Text Length

Instruction copy is compact after Phase 2. The longest line by character count is the final no-reward statement because it intentionally names XP, items, resources, and campaign progress. Hints are ten words or fewer.

Risk: the mobile-short overlay has a low max height and scrolls. Even short text can feel dense when header, progress, condition, and two buttons are visible at once.

Recommendation: copy is now within a good automated budget. Next readability work should focus on hierarchy and live pacing, not more text.

### 4. Hint Clarity

Most hints are practical input or expectation hints: H, Space, right-click, Esc, rally behavior, mana/cooldown, and non-persistence.

Phase 2 removed test-hook language from the safe-pressure hint and replaced it with player-facing staging guidance.

Recommendation: keep future hints player-facing. Put test-hook notes in docs or tests, not overlay copy.

### 5. Objective Progression Understandability

The flow moves from low-pressure camera/readiness into hero control, then capture/economy, then production, then rally/ability/pressure, then finish. This is a coherent RTS/RPG onboarding order.

Risk: Gather Resources depends on understanding that battle resources are temporary. Current copy says this in the hint, but the distinction may still be abstract before the player has seen campaign rewards.

Recommendation: keep the gather step, but phrase it as a battlefield resource lesson first and a no-campaign-bank warning second.

### 6. Concept Order

The current order is sensible:

- Camera and selection come before movement.
- Movement comes before capture.
- Capture and income come before spending.
- Command Hall and Barracks come before training.
- Rally point comes after training.
- Hero ability and pressure come after the player has at least a small force.
- Finish repeats the no-reward policy.

Risk: hero ability after rally is safe, but players may expect ability usage earlier because the hero is introduced first.

Recommendation: keep ability late for now. It is safer to teach ability after basic army staging.

### 7. No-Reward Completion Clarity

The final instruction explicitly says no XP, items, resources, or campaign progress were granted. Smoke coverage verifies no localStorage save is created, no live hero XP is granted from the pressure kill, and no runtime XP appears.

Risk: completion immediately returns to the main menu after the player clicks Complete Tutorial. Players can click through the message before absorbing it.

Recommendation: Phase 4 should consider a clearer transient completion state or warmer final copy while still avoiding save/localStorage writes.

### 8. Exit Tutorial Clarity

The overlay always includes `Exit Tutorial`, and smoke coverage proves it returns to the main menu without saving. The button has a stable `tutorial-exit` test id, which avoids confusion with the top HUD Menu button.

Risk: the label is functional but slightly abrupt. It does not remind players that exit is safe and non-persistent.

Recommendation: consider `Exit to Menu` or a clearer aria label in an accessibility pass, while preserving the visible action's brevity.

### 9. Mobile-Short Readability

The layout lane verifies the first tutorial overlay stays within the viewport and keeps buttons reachable at 360 x 640. The CSS uses a scrollable compact panel on very small widths.

Risk: the mobile-short CSS currently narrows the overlay to `calc(100vw - 160px)`, which protects other HUD space but can make the tutorial text feel cramped. The test proves width safety, not comfort or readability.

Recommendation: Phase 3 should improve small-screen hierarchy/spacing if it can be done without covering the command panel or core controls.

### 10. HUD And Overlay Attention Competition

The overlay is pointer-light, and only its buttons consume pointer input. The layout guard checks the side command panel remains within viewport width after tutorial launch.

Risk: visually, the tutorial overlay competes with battle status, objective, resource, minimap, and command panels. Automated layout tests do not measure attention or stress.

Recommendation: keep one tutorial overlay only. Avoid adding banners, modals, or extra tutorial callouts until human play shows a need.

### 11. First-Contact Length Risk

The tutorial teaches a complete mini-loop, which is valuable for QA and onboarding. It also asks for several RTS actions before completion: capture, construction, training, rally, ability use, and pressure.

Risk: this is likely on the upper edge for a first-contact tutorial. The current e2e path completes quickly because it uses safe hooks for fragile or time-heavy actions.

Recommendation: polish clarity first. If human play still feels long, the safest future change is making the pressure beat clearer or optional, not adding another tutorial branch.

### 12. E2E Confidence

Current e2e coverage is useful:

- Smoke verifies boot, tutorial launch, full twelve-step completion, no-save/no-XP behavior, and exit.
- Layout verifies the first overlay across four viewport sizes.
- Release runs include smoke, layout, and deep-flow coverage.

Risk: the completion path relies heavily on scene hooks for build, training, rally, ability, and pressure. That is acceptable for no-reward safety, but it cannot replace a human-paced UI pass.

Recommendation: keep the full tutorial smoke test for now. Later command-log V1 can make the semantic flow clearer without removing direct assertions.

### 13. What Still Requires Human Play

Human review is still required for:

- Whether the tutorial feels too long.
- Whether the player understands why resources matter.
- Whether capture timing and construction timing feel clear.
- Whether the safe-pressure step feels fair and readable.
- Whether the final no-reward completion feels satisfying enough.
- Whether mobile-short text is genuinely readable, not merely in-bounds.
- Whether the overlay competes too much with the HUD during real input.
- Whether Exit Tutorial is discoverable under stress.

## Recommended Phase 2-4 Focus

1. Tighten player-facing tutorial copy.
2. Remove hook/test wording from player-facing hints.
3. Improve small-screen overlay hierarchy without changing selectors.
4. Make no-reward completion clearer and warmer without saving anything.
5. Preserve the existing no-reward/no-save e2e assertions.

## Verification Plan

This audit is docs-only. Required checks:

```text
npm test
npm run build
npm run validate:content
git diff --check
```
