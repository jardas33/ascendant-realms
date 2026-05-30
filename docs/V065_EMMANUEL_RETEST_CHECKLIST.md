# v0.65 Emmanuel Retest Checklist

Use a clean package named `ascendant-realms-private-playtest-<commit>` with no `-dirty` suffix.

## Retinue Recovery

- Start with at least one deployed Retinue unit in an eligible campaign battle.
- Let the unit survive at very low HP and finish the mission.
- Confirm Results shows the unit entering recovery.
- Return to the Campaign Map and confirm the unit shows `Recovering` and cannot deploy.
- Complete one eligible first-clear campaign progression step and confirm the unit returns Ready.

## Reserves

- Confirm Retinue Camp shows roster count, selected deployment count, Ready reserves, and Recovering count.
- Confirm Ready units can move between Deploy and Reserve.
- Confirm Recovering units show a blocked reason and cannot deploy.
- Confirm launching with zero selected Retinue units remains valid.

## Call Retinue

- Start an eligible campaign battle with at least one Ready reserve and enough Crowns.
- Confirm the HUD shows `Call Retinue`, cost, and Ready reserve count.
- Use it once and confirm one reserve arrives near the Command Hall.
- Confirm Crowns are spent and the button becomes unavailable for the rest of the battle.
- Confirm it is unavailable with no Ready reserve, insufficient Crowns, or a destroyed Command Hall.

## Results

- Confirm Results lists surviving Retinue, lost Retinue, entering recovery, returned Ready, and reinforcement use when applicable.
- Confirm the copy stays short and readable.
- Confirm dead Retinue units are gone from the Campaign Map roster afterward.

## Protected Routes And Regressions

- Tutorial / Proving Grounds should not mutate Retinue, show recovery noise, or offer Call Retinue.
- Replay should not instantly recover units or duplicate one-time Retinue/reward state.
- Control groups, Patrol, formation-aware movement, Worker build/repair/site assignment, hero skills, relics, campaign rewards, and Act 1 telemetry should remain stable.
