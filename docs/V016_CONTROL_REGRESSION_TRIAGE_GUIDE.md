# v0.16 Control Regression Triage Guide

Date: 2026-05-19
Scope: interpreting v0.15/v0.16 control and behaviour-mode reports

## Interpretation Rules

- One odd movement path is a note only unless it repeats.
- Repeated snap-back after move-away is high priority.
- Idle contact melee is high priority.
- Stale HUD after minimap/HUD interaction is high priority.
- Attack cursor missing on a valid visible enemy is high priority.
- Left-click enemy failing to issue attack is high priority.
- Mode copy unclear is a copy/readability issue unless state is wrong.
- `Press Attack too aggressive` needs repeated evidence before tuning.
- `Hold Ground boring` is design feedback, not a bug.
- Do not make balance changes from one report.

## First Triage Questions

1. Was a controllable player unit or group selected?
2. Which mode was active?
3. Was the command explicit attack, explicit move, or idle behaviour?
4. Was the enemy visible and targetable?
5. Did the unit have a path away from combat?
6. Did the issue repeat after reselecting or pressing `H`?
7. Was this Tutorial, skirmish, or campaign?

## Priority

High:

- Repeated snap-back loop.
- Melee idle while body-overlapping or immediately adjacent to a hostile target.
- Valid enemy hover/click attack intent fails.
- HUD remains stale after minimap/HUD interaction.
- Tutorial win/loss leaves the expected no-save/no-reward Results route.

Medium:

- Mode copy changes slowly but state is correct.
- Retreat path looks awkward while still moving away.
- Mixed group mode copy is confusing.
- Press Attack feels too eager in repeated similar cases.

Low:

- Single unusual pathing wiggle.
- Wording preference with no state mismatch.
- Balance preference from one run.

## Evidence To Ask For

- Build commit and package name.
- Route and scene.
- Mode selected.
- Unit/group selected.
- Enemy type and distance.
- Exact click or key used.
- Screenshot or short video when possible.
- Whether it happened again after retry.

## Automation Mapping

Use automated tests for repeated, reproducible contract failures:

- Combat acquisition or leash issue: unit/system test.
- Attack hover/click or HUD/minimap issue: Playwright test.
- Package content issue: package verifier test.
- Generated report mismatch: control lab validation test.

Use manual retest for readability, feel, and tactical judgment.
