# v0.50 Emmanuel Retest Checklist - Act 1 Release Candidate

## Build

- Use the final clean package named `ascendant-realms-private-playtest-<commit>`.
- Confirm `PLAYTEST_BUILD_INFO.md` names v0.48-v0.50.
- Confirm working tree dirty says `no` in build info.

## Route

1. Run Tutorial / Proving Grounds.
   - Expected: practice-only, no persistent reward, no campaign save noise.
2. Start a new campaign and select Border Village.
   - Expected: Border Village starts unlocked and Old Stone Road is locked until Border Village is cleared.
3. Win Border Village.
   - Expected: Results show first-clear reward, XP, replay availability, and Old Stone Road unlock.
4. Select Old Stone Road.
   - Expected: briefing mentions base development, Worker training, production, rewards, and replay status.
5. Win Old Stone Road.
   - Expected: Aether Well Ruins and Bandit Hillfort branch guidance appears; replay copy says one-time rewards remain claimed.
6. Inspect Aether Well Ruins.
   - Expected: resource-control copy mentions site assignment, upgrades, and rebuilding before the center push.
7. Inspect or play Bandit Hillfort.
   - Expected: rival-pressure copy encourages a mixed army and holding after waves before assaulting.
8. Play Ashen Outpost.
   - Expected: champion/relic milestone copy reminds the player to spend skill points, equip gear/relics, stage troops, and choose/equip a relic after victory.
9. Replay a completed battle.
   - Expected: Results and campaign node details say replay reward, already claimed, and optional objective status clearly.

## Report Back

Please note:

- Any point where the next mission or locked reason is unclear.
- Any battle that feels unfair before the first defense is readable.
- Any Worker/building/resource-site/relic/skill reminder that appears too late.
- Any replay result that looks like it granted a duplicate one-time reward.
- Any mismatch between the telemetry read and manual feel.

## Not Under Review

- Final art.
- New maps/factions.
- Shop/crafting.
- Large campaign quest systems.
- Broad AI/pathing behavior.
- Global balance.
