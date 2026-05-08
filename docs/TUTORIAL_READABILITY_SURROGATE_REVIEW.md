# Tutorial Readability Surrogate Review

Date: 2026-05-08

Status: automated surrogate review for the first playable Tutorial / Proving Grounds shell.

## Scope

This review checks the current no-reward Tutorial / Proving Grounds shell from a readability and layout perspective. It does not add content, maps, units, factions, rewards, campaign progression, save fields, or tutorial persistence.

The playable shell is intentionally small:

- Main-menu entry launches the tutorial directly.
- Battle mode reuses the existing `first_claim` map, existing Aster hero data, existing player units/buildings, existing `rally_banner`, and existing Raider pressure.
- The overlay drives twelve linear steps and returns to the main menu on completion.
- Completion is non-persistent and grants no XP, items, campaign resources, campaign node completion, retinue state, rival state, or trophies.

## Automated Coverage Added

Phase 11 adds a responsive Playwright layout guard in `tests/e2e/layout.spec.ts`:

- Desktop: 1366 x 768.
- Tablet short: 820 x 620.
- Mobile tall: 390 x 844.
- Mobile short: 360 x 640.

For each viewport the test:

- Opens a fresh main menu.
- Verifies the Tutorial entry is reachable.
- Launches Tutorial / Proving Grounds.
- Verifies the first overlay objective, instruction, progress, Next Objective button, and Exit Tutorial button are visible and reachable.
- Checks the overlay and battle command panel stay inside the viewport width.
- Checks the UI root has no horizontal overflow.

This is not a full tutorial completion test; the full twelve-step completion and no-save/no-XP checks remain in the smoke lane.

## Review Findings

### Main Menu Tutorial Entry

The main-menu Tutorial button is clear and short. It appears beside the existing primary flows rather than inside campaign progression, which avoids implying that the tutorial is a campaign chapter or unlock.

Risk: the button label is terse. The first playable shell relies on the broader README/docs and the in-battle overlay to explain that Proving Grounds is no-reward training.

Recommendation: keep the button label short for now. If a future pass adds a menu sublabel, it should stay compact and should not crowd the existing main-menu actions.

### Tutorial Overlay Density

The overlay shows one objective title, one instruction sentence, one optional hint, one condition label, progress text, and controls. That is the right amount for a first playable shell and avoids turning the tutorial into a modal reading sequence.

Risk: on the 360 x 640 mobile-short viewport the overlay intentionally becomes narrow and scrollable. This preserves viewport safety but can make long instructions feel dense.

Recommendation: keep each future step to one short instruction and one short hint. Do not add paragraphs, lore, or multi-branch text inside the overlay.

### Step Text Length

Most current step instructions are single action sentences. The longest texts are the safe-pressure and finish steps, which are still acceptable because they explain unusual shell behavior: hook-assisted pressure and no reward persistence.

Risk: the tutorial has twelve steps, which is long for first contact if a player is already familiar with RTS controls.

Recommendation: keep Skip / Exit visible, and consider a later optional "Basics only" cut after human playtesting. Do not split this into a larger quest system yet.

### Hint Usefulness

Hints are practical and tied to existing inputs: H, Space, right-click movement, Esc placement cancel, rally behavior, mana/cooldown, and no-reward persistence.

Risk: a few hints explain systems that the player may not have reached yet, such as battle resources resetting after battle.

Recommendation: keep the current hints, but prefer input/action hints over system disclaimers in future copy edits.

### Desktop, Tablet, and Mobile Layout

The new layout guard passed on desktop, tablet-short, mobile-tall, and mobile-short. The overlay stays within viewport width, and the battle command panel remains width-safe.

Risk: the overlay is deliberately positioned near the top-center, while battle HUD panels also occupy the top and side regions. It currently fits, but future HUD additions could crowd it.

Recommendation: any future tutorial overlay changes should rerun `npm run test:e2e:layout -- --grep "tutorial entry"` before the full layout lane.

### Skip / Exit Clarity

Exit Tutorial is always visible in the overlay and returns to the main menu without saving. Full smoke coverage verifies that exit does not create a save.

Risk: the top HUD Menu button and overlay Exit Tutorial both return to the menu. This is acceptable, but tests should keep using the explicit `tutorial-exit` test id for clarity.

Recommendation: keep Exit Tutorial visible and stable. Do not hide it behind a menu or modal until tutorial persistence exists.

### Battle HUD Interference

The overlay is pointer-light: the panel does not block core canvas controls, while its buttons remain clickable. The new layout guard also checks the side command panel remains inside viewport width after tutorial launch.

Risk: the overlay can still visually compete with objectives/status text on smaller screens.

Recommendation: do not add extra tutorial panels or banners in the first shell. Keep one overlay only.

### No-Reward Behavior

The finish step explicitly says no rewards or campaign progress were granted. The save audit and smoke tests verify no localStorage save, hero XP, or runtime XP is created during the tutorial completion path.

Risk: because completion returns directly to the main menu rather than a Results screen, some players may miss the no-reward message if they click quickly.

Recommendation: keep the final step copy as-is for the shell. If human playtesting shows confusion, add a compact non-modal completion toast before returning to menu, still with no save/write path.

### Completion Copy

The final copy is clear and intentionally plain: "Training complete. Return to the main menu; no rewards or campaign progress were granted."

Risk: it is functional rather than celebratory.

Recommendation: future polish can make the line warmer, but must keep the no-reward/no-progress policy explicit.

### Tutorial Length

Twelve steps cover the requested onboarding loop: camera, selection, movement, capture, resources, building, training, rally, hero ability, pressure, and completion.

Risk: this is a lot for a first tutorial, especially if human play requires waiting for capture income, construction, and training timers.

Recommendation: keep the automated completion path stable, then human-play the tutorial before adding any new beats. If it feels long, shorten copy or make some steps optional; do not add more tutorial content first.

## Follow-Up Watch Items

- Human-review mobile-short readability with real touch/mouse input.
- Human-check whether the finish step needs a slightly clearer success state before returning to menu.
- Watch smoke runtime: the full tutorial completion path remains useful in smoke for now, but should move to deep/release if the smoke lane grows materially beyond the current 6-7 minute range.
- Keep tutorial metadata validation strict before adding any second tutorial or persisted completion flag.
- Do not add rewards, campaign state, new maps, new units, new factions, or save-version changes to solve readability issues.

## Verification

Phase 11 focused precheck:

```text
npm run test:e2e:layout -- --grep "tutorial entry"
PASS: 4 Playwright tests in 48.0s.
```

Full Phase 11 gate should run:

```text
npm test
npm run build
npm run validate:content
npm run test:e2e:smoke
npm run test:e2e:layout
git diff --check
```
