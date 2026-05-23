# v0.16.12 Emmanuel ec0608a Retest Intake

Date: 2026-05-23

## Session

- Session: `PT-20260521-EMMANUEL-EC0608A-SOLO-01`
- Package tested: `ascendant-realms-private-playtest-ec0608a`
- Build: `ec0608a`
- Browser: Brave
- OS: Windows
- Route: Tutorial
- Result: MIXED

## Passed

- Guard Area default works.
- Hold Ground can be selected.
- Retreat near multiple enemies seems improved.
- Attack cursor appears more easily than before.
- Empty terrain near enemy does not show attack intent.
- Left-click enemy attack works.
- Drag-select over HUD/minimap works.
- Minimap click plus `H` does not leave stale side panel.
- Tutorial defeat Results works.

## Failed

- Core adjacent melee bug remains.
- In Tutorial, hero in Hold Ground stood next to two Stone Imps.
- First attempt: hero and both imps stood next to each other with nobody attacking.
- After moving hero, one imp and hero engaged.
- After first imp died, second imp and hero stood adjacent and idle.
- After moving hero again, they engaged.
- This proves stationary adjacent/contact reacquisition still fails after first target dies or when no one is actively attacking.

## Unclear

- Ranged enemies attack Command Hall correctly.
- Melee enemies near Command Hall are hard to verify visually.
- Some melee enemies may be too far from the building footprint.
- Some melee enemies may be attacking but feedback is unclear.

## Minor

- Attack cursor is better, but top/head area of enemies and buildings still misses hover intent.
- Tutorial objective box sometimes obstructs view.
- Future QoL should make the tutorial objective box draggable or less obstructive, but only if safe.

## v0.16.12 Scope Decision

Fix the remaining stationary adjacent/contact melee idle bug narrowly. Do not start v0.17. Do not implement worker construction, add content, rebalance numbers, change saves, add runtime art/assets, or rewrite broad AI/pathing.
