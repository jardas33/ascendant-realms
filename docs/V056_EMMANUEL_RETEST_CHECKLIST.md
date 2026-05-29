# v0.56 Emmanuel Retest Checklist - Control Groups And Patrol

## Build

- Use the final clean package named `ascendant-realms-private-playtest-<commit>`.
- Confirm `PLAYTEST_BUILD_INFO.md` names v0.54-v0.56.
- Confirm working tree dirty says `no` in build info.

## Route

1. Start a normal Act 1 battle with several combat units and the hero.
   - Expected: campaign briefing, objectives, relic/skill reminders, and replay copy still read as they did in v0.53.
2. Select the hero plus two or more friendly combat units.
   - Expected: the selected panel shows a compact control-group hint.
3. Press Ctrl+1.
   - Expected: HUD feedback says the group was assigned and the group summary shows slot 1 with the selected count.
4. Clear selection, then press 1.
   - Expected: the living group members are selected again. Dead or missing units are not reselected.
5. Right-click open terrain with the recalled group.
   - Expected: units move toward nearby separated destinations instead of all stacking exactly on the clicked point when space allows.
6. Press P, then click a patrol destination.
   - Expected: eligible combat units begin Patrolling and the order summary says `Patrolling`.
7. Issue a normal move command, attack command, Stop, or behavior-mode command.
   - Expected: Patrol cancels immediately and the unit summary updates.
8. Select Workers and test build, repair, and resource-site assignment.
   - Expected: Worker commands still work and Workers do not show Patrol as a default combat command.
9. Trigger a hero ability with existing ability hotkeys in a selection that has no recalled control group consuming that number.
   - Expected: ability hotkeys and disabled reasons remain readable.

## Report Back

Please note:

- Any control group that recalls enemies, buildings, or dead units.
- Any case where 1-5 blocks a hero ability when no control group exists.
- Any group move that stacks all units despite open nearby space.
- Any Patrol route that fails to cancel after explicit commands.
- Any Worker build, repair, site assignment, minimap, drag-select, or Act 1 reward regression.

## Not Under Review

- Saved control groups.
- Formation editor.
- Waypoint patrol chains.
- Enemy formation AI.
- New maps/factions/art.
- New balance pass.
