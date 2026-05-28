# v0.40 Mission Reward Structure Spec

Date: 2026-05-28

## Goal

Connect battle victories, campaign node rewards, hero XP, relic rewards, and skill-point reminders into one readable mission reward loop. The player should understand what was earned for a first clear, what is reduced on replay, and which special rewards came from a rival champion.

## Reward Rules

- Tutorial / Proving Grounds remains no-save and no-reward.
- First clear can grant the existing battle reward table, the existing campaign node reward, hero XP, item rewards, campaign resources, rival champion rewards, relic choice eligibility, and level-up skill points.
- Replay uses the existing reduced repeat-clear battle reward table and never duplicates campaign node rewards.
- Unique relics remain one-per-hero inventory entry; duplicate relic handling uses the existing conversion rule.
- Rival champion defeat remains the strongest relic reward eligibility source.
- Results must distinguish first-clear reward, replay reward, campaign node reward, champion reward, relic choice, XP gained, and skill-point availability.

## Duplicate and Farming Safety

- `nodeRewardsClaimedIds` prevents repeated campaign node XP, items, and campaign resources.
- `clearedMapIds` keeps battle reward tables on their reduced repeat-clear path.
- Unique relic reward selection checks owned/equipped relics before granting.
- Optional objective completion credit is first-time only.
- Replays should say "Replay reward" or "Already claimed" rather than implying another full first-clear reward.

## UI Scope

Use existing surfaces:

- campaign node details for preview and claimed state;
- Results battle summary for first-clear/replay state;
- existing relic choice panel for champion relic options;
- existing hero XP/skill-point rows for progression reminders.

No modal, shop, crafting, paper-doll inventory, or new art is included.

## Deferrals

- Per-mission loot table expansion.
- Reward tuning pass across all maps.
- Objective reward currencies beyond completion credit unless a tiny safe bonus is already supported.
- Full mission journal or quest turn-in UI.
