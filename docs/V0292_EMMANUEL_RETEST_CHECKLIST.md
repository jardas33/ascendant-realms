# v0.29.2 Emmanuel Retest Checklist

Date: 2026-05-27
Package: final clean v0.29.2 package. Confirm `PLAYTEST_BUILD_INFO.md` names the v0.29.2 checkpoint and says the working tree was not dirty.

## Purpose

This retest uses the v0.28-v0.29 hero progression package after the v0.29.2 hosted deep-battle recovery. It is not a new gameplay-feature pass.

## Start Here

Read these first:

- `V029_EMMANUEL_RETEST_CHECKLIST.md`
- `V0291_BLOCKED_REMOTE_CI_STATUS.md`
- `V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md`
- `V0292_HOSTED_DEEP_BATTLE_FAILURE_AUDIT.md`
- `V0292_HOSTED_DEEP_BATTLE_FIX_REPORT.md`
- `V0292_RELEASE_MATRIX_CLOSEOUT.md`

## Retest Focus

- Hero XP still appears from combat participation and first player resource-site captures.
- Hero level, XP progress, stat summary, and ability states remain readable in the HUD.
- Rally Banner and Cleave still show clear cooldown/disabled states and cannot be spammed.
- Victory results still summarize battle XP and level rewards.
- Worker assignment and Level 2 resource-site upgrade behavior still work.
- Enemy site/base/tech pressure still appears during longer battles.
- World right-click move/retreat commands feel normal in battle.
- Minimap movement, fog toggle, marquee selection, and hovered command buttons remain readable.

## Do Not Judge Yet

- Final art or animation polish.
- Inventory/loot complexity.
- Enemy hero progression.
- New factions/maps.
- Classic harvesting, cargo, or drop-off loops.
- Any package where `PLAYTEST_BUILD_INFO.md` says the working tree was dirty.

## Pass / Mixed / Fail Notes

Record:

- package name,
- start method used,
- browser and OS,
- whether hero XP/abilities/results were understandable,
- whether resource-site Worker assignment/upgrades still worked,
- whether enemy pressure felt readable rather than chaotic,
- any world-click, minimap, or hover-control issue with exact steps.
