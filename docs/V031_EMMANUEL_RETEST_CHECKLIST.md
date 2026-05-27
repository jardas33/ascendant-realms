# v0.31 Emmanuel Retest Checklist

Date: 2026-05-27

Use the clean v0.30-v0.31 package whose `PLAYTEST_BUILD_INFO.md` commit matches the final checkpoint commit and whose working-tree dirty status says `no`.

## Primary Route

Start with Ashen Outpost if available from the campaign map.

Retest focus:

- campaign node details show Captain Malrec as the Outpost Commander;
- battle objectives include defeating Captain Malrec;
- scouting or fighting reveals the named commander clearly;
- the commander is targetable and damageable;
- defeating the commander grants readable XP/reward summary credit;
- the results screen shows enemy commander defeated;
- the results screen shows the relic reward preview;
- the relic block clearly says future persistence is pending and it is not saved or added to inventory.

## AI Readability

Watch for:

- the commander defending base or valuable sites under threat;
- the commander not wandering alone into early raids;
- late commander attacks arriving with an escort rather than as a solo suicide run;
- no obvious ability spam;
- no infinite commander respawn.

## Regression Sweep

Also check:

- hero XP and level-up readability;
- Rally Banner and Cleave cooldown/mana copy;
- world move and retreat clicks;
- minimap movement;
- command-button hover stability;
- Worker building, repair, attack, and resource-site assignment;
- resource-site upgrade/Worker slot behavior;
- enemy site capture/retake/raid/defense pressure;
- enemy base fortification and tech escalation;
- results-screen XP and reward summaries.

## Tutorial Protection

Run or sanity-check Tutorial:

- no XP, items, resources, campaign progress, relics, or inventory changes should be saved;
- no relic preview should appear;
- no new commander/relic complexity should make the Tutorial harder.

## What Not To Judge Yet

- final commander portraits/art/VFX;
- persisted relic inventory;
- relic equipment;
- random loot tables;
- full enemy hero roster;
- final balance.
