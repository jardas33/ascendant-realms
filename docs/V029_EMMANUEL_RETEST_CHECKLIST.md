# v0.29 Emmanuel Retest Checklist

Date: 2026-05-26

Package target: clean `ascendant-realms-private-playtest-<v0.28-v0.29 commit>`.

## Hero XP And Leveling

1. Start a normal campaign or skirmish battle.
2. Keep the hero near fighting and capture at least one resource site.
3. Confirm the hero panel shows level, XP, skill points, damage, armor, and unlocked ability count.
4. If the hero levels up, confirm HP/Mana refill and the level in the hero panel updates.

## Active Abilities

1. Select the hero or press `H`.
2. Use Rally Banner with nearby friendly units and confirm it feels like a short support burst.
3. If Cleave is unlocked, use it near enemies and confirm it is a close-range burst, not a screen-clearing spell.
4. Confirm used abilities show cooldown text and cannot be spammed immediately.
5. Confirm low Mana or cooldown state is readable from the ability button.

## Rewards And Results

1. Win a battle after earning some battle XP.
2. Confirm the results screen shows Hero XP, XP gained, before/after progress, level-up status, and skill points gained.
3. Confirm Reward XP remains separate from battle performance XP.
4. Confirm any campaign node XP still appears in the campaign reward block.

## Tutorial Regression

1. Launch Tutorial / Proving Grounds.
2. Confirm the Rally Banner step still teaches ability use without adding extra RPG management.
3. Finish or exit Tutorial and confirm no hero XP, items, resources, or campaign progress are saved.

## Regression Watch

- v0.22/v0.23 Worker construction, repair, attack, resource-site assignment, site upgrades, and site-loss cleanup still work.
- v0.24-v0.27 enemy resource-site pressure, base development, tech escalation, and defensive reserves still work.
- No classic harvesting, visible enemy Workers, cargo, drop-off loop, new maps, new factions, runtime art/assets, inventory overhaul, enemy hero progression, Patrol, formations, or broad pathing rewrite should appear.
