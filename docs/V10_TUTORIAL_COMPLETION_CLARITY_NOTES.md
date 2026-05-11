# v0.10 Tutorial Completion Clarity Notes

Date: 2026-05-11

Scope: Tutorial / Proving Grounds completion and no-reward clarity.

This phase improves only the final completion messaging. It does not add XP, items, resources, achievements, campaign progress, localStorage flags, save-version changes, or tutorial persistence.

## What Changed

- The final overlay already says: "Training complete. You practiced the core loop. No rewards: no XP, items, resources, or campaign progress were granted."
- The brief battle status message now says no rewards or save changes were granted.
- The session-only main-menu notice now says practice finished with no XP, items, resources, or campaign progress, that nothing was saved, and that the player can start New Campaign when ready.

## What Did Not Change

- No tutorial save is written.
- No tutorial-completed flag is stored.
- No campaign progress is granted.
- No ResultsScene reward flow is opened.
- No hero XP, items, resources, retinue state, rival state, trophies, reputation, or Stronghold state are granted.
- Exit Tutorial still returns to the menu without showing the completion notice.

## Test Coverage

The smoke tutorial completion path continues to assert:

- localStorage remains empty before and after completion;
- the safe-pressure Raider grants no hero XP and no runtime XP;
- the final overlay still names no rewards and campaign progress;
- the completion notice says Training complete;
- the completion notice says Nothing was saved;
- the completion notice points to Start New Campaign;
- tutorial exit returns to the menu without saving and without the completion notice.

## Remaining Human Review

Human play should still decide whether the ending feels satisfying enough. The current decision is intentionally conservative: make the no-reward ending warmer and clearer, but do not add rewards or persistence to create satisfaction.

