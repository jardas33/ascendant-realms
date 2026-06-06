# v0.133 Emmanuel Retest Guide

Use this guide to retest the repaired post-mine player-facing flow.

Launcher:

```text
GODOT_LAUNCH_POST_MINE_FLOW_REVIEW_WINDOWS.bat
```

Expected manual path:

1. Click `Start Salto Review`.
2. Click `Start Battle`.
3. Select Aster.
4. Right-click the highlighted West Stone Cut Mine.
5. Wait for conversion and controlled-state feedback.
6. Select the highlighted Worker.
7. Right-click the controlled West Stone Cut Mine.
8. Confirm Worker assignment and production-boost feedback.
9. Follow `Objective 5: Restore the Barracks`.
10. With the Worker selected, right-click the highlighted Barracks frame.
11. Watch construction progress.
12. Select the restored Barracks.
13. Click Train.
14. Watch recruitment progress and Militia spawn.
15. Watch the Ashen-pressure countdown.
16. When the wave launches, confirm the defender squad is selected and the four active Ashen attackers are visibly marked.
17. Click `Attack` or right-click one of the marked Ashen attackers.
18. Confirm enemies move, combat begins, and the wave is defeated by simulation.
19. Click the highlighted Lume link.
20. Confirm Results is reached.

Expected result:

- The flow does not stall at Ashen pressure.
- Box selection does not skip objectives early.
- The top battle banner no longer covers the playfield during combat.
- Objective 8 keeps the defender squad selected even if an empty combat box-select misses the units.
- The visible fight is the bounded four-attacker Ashen wave, not the old reserve formation.
- No debug shortcut, private-harness action, state injection, fixture-only helper, or Godot editor step is needed.

Automated proof command:

```text
npm run godot:validate:post-mine-flow
```
