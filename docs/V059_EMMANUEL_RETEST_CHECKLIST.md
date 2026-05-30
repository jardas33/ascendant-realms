# v0.59 Emmanuel Retest Checklist - Army Roles, Veterancy, And Tactical Feedback

## Build

- Use the final clean package named `ascendant-realms-private-playtest-<commit>`.
- Confirm `PLAYTEST_BUILD_INFO.md` names v0.57-v0.59.
- Confirm working tree dirty says `no` in build info.

## Route

1. Start an Act 1 battle with the hero, Militia, Ranger, and Acolyte available.
   - Expected: existing campaign briefing, objectives, control-group, Patrol, skill, relic, and replay copy still appears normally.
2. Select a Militia.
   - Expected: selected panel says `Frontline / Melee`, shows frontline/melee/holds-ground tags, and shows rank/XP/kills/bonus/veterancy state.
3. Select a Ranger and Acolyte.
   - Expected: Ranger reads as ranged/focus-fire/fragile; Acolyte reads as aether/support/special damage.
4. Select a Worker.
   - Expected: Worker reads as utility/site support and still prioritizes build, repair, and resource-site assignment.
5. Put a Worker on a construction task, move away, then resume.
   - Expected: order summary distinguishes moving to build, building, and construction paused.
6. Select multiple combat units, assign Ctrl+1, clear selection, then press 1.
   - Expected: group recall works and the group role summary remains readable.
7. Start Patrol with combat units and then cancel with a move/attack/Stop/behavior command.
   - Expected: Patrol starts and cancels as in v0.56; role/veterancy copy remains visible.
8. Finish a battle after one or more units earned rank progress.
   - Expected: Results mention notable veterans and clearly state normal trained-unit veterancy is battle-only.

## Report Back

Please note:

- Any unit whose role tag feels misleading.
- Any veteran/rank copy that looks permanent when it should read battle-only.
- Any control-group or Patrol regression involving ranked units.
- Any Worker build/repair/site assignment regression.
- Any Results screen that becomes cluttered or hides relic/skill/objective information.

## Not Under Review

- New unit roster systems.
- Permanent army management.
- Enemy veterancy.
- New maps/factions/art.
- Balance tuning outside obvious bugs.
