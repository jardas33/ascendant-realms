# v0.97 Emmanuel Retest Checklist

Goal: review whether selection, camera, order feedback, and tactical confirmations feel clearer without judging final art.

Estimated time: 8-10 minutes.

## Launch

1. Open the latest package folder reported in the closeout response.
2. Run `node start-playtest-server.mjs`.
3. Open the local URL shown by the launcher.

## Quick Route

1. Start a campaign or skirmish battle.
2. Select Aster, a Worker, a small squad, a Command Hall, and an enemy.
3. Confirm the side panel clearly says what is selected.
4. Right-click ground with a selected group and look for the brief move marker.
5. Attack an enemy and look for the hostile marker plus concise order copy.
6. Set a Patrol route and confirm the order reads as Patrolling.
7. Select a production building, right-click safe ground, and confirm the rally marker.
8. Try an invalid build placement and confirm the message is short and understandable.
9. Move the camera away, press Space, and confirm the camera focuses the selected unit or hero.
10. Click the minimap and confirm the camera jump is easy to understand.
11. Open a command `More Details` disclosure and confirm the default command card is still compact.
12. Enable reduced motion in Settings, return to battle, and confirm command feedback is still readable.

## Questions

- Is it obvious what is selected?
- Do command markers make orders easier to trust?
- Are invalid-order messages short enough?
- Is Space focus useful and predictable?
- Is enemy inspection clearly separate from issuing commands?
- Does the command panel stay compact enough?
- Is anything still confusing, ugly, or annoying?

## Scope Reminder

v0.97 does not change saves, rewards, combat balance, unit stats, pathing, campaign progression, maps, factions, art assets, or the runtime title.
