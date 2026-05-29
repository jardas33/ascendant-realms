# v0.53 Emmanuel Retest Checklist - Player UX and Command Readability

## Build

- Use the final clean package named `ascendant-realms-private-playtest-<commit>`.
- Confirm `PLAYTEST_BUILD_INFO.md` names v0.51-v0.53.
- Confirm working tree dirty says `no` in build info.

## Route

1. Run Tutorial / Proving Grounds.
   - Expected: practice-only, no persistent reward, and no extra reward noise.
2. Start a new campaign and enter Border Village.
   - Expected: node briefing and objective copy are still readable.
3. Select a hero or unit and hover an enemy.
   - Expected: the cursor clearly reads as attack intent.
4. Train a Worker and place a Barracks.
   - Expected: incomplete friendly construction reads as build/continue construction intent.
5. Damage a friendly completed building or inspect a damaged one with a Worker selected.
   - Expected: repair command copy and repair cursor intent are clear.
6. Capture a resource site and select a Worker.
   - Expected: assignment command and hover intent clearly read as resource-site assignment.
7. Inspect hero ability buttons after casting Rally Banner or another available ability.
   - Expected: cooldown and Mana reasons are readable and short.
8. Trigger a victory Results screen.
   - Expected: first-clear/replay, rewards, optional objectives, relic/skill reminders, and next-step guidance remain present without feeling noisier than v0.50.
9. Replay a completed battle.
   - Expected: already-claimed and replay-safe reward copy still prevents farming confusion.

## Report Back

Please note:

- Any hover target where the cursor suggests the wrong command.
- Any disabled button where the reason is still unclear.
- Any combat moment where Burn/status/HP information overlaps or is too small.
- Any Results screen where reward/objective copy feels missing or too dense.
- Any regression in Act 1 unlock, replay, relic, skill, or no-reward Tutorial behavior.

## Not Under Review

- Final art or custom cursor sprites.
- New maps/factions.
- Shop/crafting.
- New gameplay systems.
- Large UI redesign.
- Global balance.
