# v0.10 Tutorial v2 Onboarding Report

Date: 2026-05-11

## Purpose

v0.10 refines the playable Tutorial / Proving Grounds experience so a first-time player gets clearer guidance through the current RTS/RPG loop. The pass improves copy, hint clarity, overlay hierarchy, completion framing, test-lane documentation, visual QA review, and Emmanuel's manual playtest checklist without expanding gameplay or touching the save format.

This remains a prototype onboarding pass. It does not make the tutorial a campaign requirement, does not grant rewards, and does not persist completion.

## What Changed

- Added a Tutorial v2 audit: `docs/V10_TUTORIAL_V2_AUDIT.md`.
- Added a pacing and scope plan: `docs/V10_TUTORIAL_V2_PACING_PLAN.md`.
- Refined tutorial step titles, instructions, hints, and final copy in `src/game/data/tutorials.ts`.
- Added copy notes: `docs/V10_TUTORIAL_COPY_REFINEMENT_NOTES.md`.
- Added a small overlay hierarchy pass in `src/game/ui/hudPanels/TutorialPanel.ts` and `src/game/styles/battle-feedback.css`.
- Added overlay notes: `docs/V10_TUTORIAL_OVERLAY_REFINEMENT_NOTES.md`.
- Clarified completion and no-reward/no-save messaging in the battle and main-menu handoff.
- Added completion notes: `docs/V10_TUTORIAL_COMPLETION_CLARITY_NOTES.md`.
- Added an e2e lane review: `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`.
- Added a visual QA review: `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`.
- Added Emmanuel's manual checklist: `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`.

## What Did Not Change

- No maps were added.
- No units, factions, workers, construction AI, economy AI, diplomacy, crafting, procedural generation, multiplayer, desktop packaging, generated art, imported art, runtime art replacement, or graphics overhaul were added.
- No campaign rewards, tutorial rewards, campaign progression, save fields, save-version bump, or tutorial completion persistence were added.
- The tutorial still launches the existing `first_claim` map through the current battle systems.
- The tutorial still uses the existing `proving_grounds_basics` metadata and the same twelve-step shell.
- Existing selectors and test ids were preserved.

## Copy Improvements

The copy pass made each step more direct:

- The opening step now tells the player that this is a quick no-reward practice run.
- Camera, selection, and movement steps use concrete action language.
- Capture-site and resource steps now explain why control points matter.
- Building, training, and rally steps explain how production connects to map pressure.
- The hero ability step names the current ability and frames it as a support tool.
- The enemy-pressure step asks the player to group up and hold instead of implying a new pressure system.
- The finish step clearly says that no XP, items, resources, or campaign progress were granted.

## Layout Improvements

The overlay refinement was intentionally small:

- Next and Complete now use a clearer primary button style.
- Exit Tutorial now uses a quieter secondary button style while staying reachable.
- The tutorial panel background is slightly stronger for readability.
- Hint text has better contrast.

The pass did not move the HUD, rebuild the overlay system, add animation, or alter command-panel placement.

## Completion Clarity

Completion now reinforces three ideas:

- Training is complete.
- No rewards or save changes were granted.
- New Campaign is the saved-run next step when the player is ready.

This keeps the tutorial useful without turning it into a progression source.

## E2E Lane Decision

The tutorial remains in smoke for v0.10. The full Tutorial / Proving Grounds completion path is still valuable because it protects launch, step completion, no-save/no-reward behavior, and return-to-menu behavior in one player-facing flow.

`docs/V10_TUTORIAL_E2E_LANE_REVIEW.md` records the decision. No coverage was removed or moved.

## Visual QA Result

`npm run visual:qa` passed during Phase 7 after the copy and overlay changes. It captured the existing 18 indexed screenshots and reported zero recorded browser console errors.

The tutorial desktop and mobile screenshots remained usable after the overlay hierarchy pass. Mobile remains readable but dense because battle HUD, command panel, and tutorial panel all share a small viewport; that is a future scoped UI-layout issue, not a v0.10 blocker.

## Manual Checklist

`docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md` gives Emmanuel a human-paced checklist for a normal Tutorial / Proving Grounds run. It asks for 1-5 ratings on first-30-seconds clarity, movement, capture sites, building/training, rally point, hero ability, enemy pressure, overlay readability, completion satisfaction, and overall fun.

The checklist also asks for the step where confusion happened, screenshots when useful, whether the tutorial felt too long, and whether no-reward completion felt acceptable.

## Remaining Risks

- The tutorial remains twelve steps long and still needs real human-paced play.
- Mobile tutorial launch is width-safe but visually dense.
- Smoke keeps the full tutorial path for now; watch runtime if future tutorial work adds more e2e cost.
- No-reward completion is clearer, but only Emmanuel's manual playtest can confirm whether it feels satisfying enough.
- Current visuals remain prototype-level until a later source/license-safe art review provides approved candidates.

## Verification Summary

Phase gates before this report:

- `npm test`: PASS, 46 files / 351 tests.
- `npm run build`: PASS with the known Phaser vendor chunk-size warning.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS.
- `npm run test:e2e:smoke`: PASS during tutorial source/UI phases.
- `npm run test:e2e:layout`: PASS during the overlay/layout phase.
- `npm run test:e2e:release`: PASS during the e2e lane review phase.
- `npm run visual:qa`: PASS during the overlay and visual-review phases.
- `git diff --check`: PASS during completed phases.

Phase 9 report gate after release-doc updates:

- `npm test`: PASS, 46 files / 351 tests.
- `npm run build`: PASS with the known Phaser vendor chunk-size warning.
- Build output: `assets/index-DY-3qp2P.js` 477.04 kB / 127.86 kB gzip, `assets/vendor-phaser-B61OQUcB.js` 1,481.79 kB / 339.86 kB gzip, `assets/index-BiGdwuWI.css` 44.51 kB / 9.16 kB gzip.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS, checked 1 candidate metadata JSON file and 0 review manifest JSON files.
- `npm run test:e2e:smoke`: PASS, 12 Playwright tests in about 4.7m.
- `npm run visual:qa`: PASS, 1 capture test in about 3.0m.
- `npm run playtest:sim`: PASS, 255 simulated runs across 85 campaign battle nodes.
- `git diff --check`: PASS.

## Next Recommended Long Goal

If Emmanuel can play the tutorial, the next player-facing step should be a short v0.10.1 human-feedback polish pass based on `docs/V10_MANUAL_TUTORIAL_V2_PLAYTEST_CHECKLIST.md`.

If visual candidates are provided instead, return to the prepared v0.9.2 Controlled Cinderfen Style-Frame Candidate Review. Keep that review non-runtime unless a later goal explicitly scopes one tiny runtime-test replacement with source/license proof, metadata validation, screenshot QA, and rollback.
