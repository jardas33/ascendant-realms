# v0.65 Battlefield Reinforcement Implementation Report

## Summary

v0.65 adds one safe Call Retinue action for eligible campaign battles. The player can spend Crowns once per battle to call one Ready reserve near the player Command Hall; Tutorial, skirmish, destroyed-base, no-reserve, and already-used cases stay blocked.

## Runtime Changes

- Added pure Retinue reinforcement rules with cost, mode, Command Hall, reserve, and single-use checks.
- Campaign battle launch now carries Ready/Recovering reserve Retinue data separately from selected deployment data.
- Battle HUD Tactics can show `Call Retinue` with cost, ready reserve count, and disabled reason.
- Calling Retinue pays 75 Crowns, spawns one Ready reserve at a safe trained-unit spawn near the Command Hall, selects the unit, pings the minimap, and records battle stats.
- Results can show participating Retinue, reinforcement use, survived/lost units, entering recovery, and returned Ready units.

## Rules Preserved

- Reinforcement is session-only battle support, not a permanent control group or broad army-management layer.
- Only eligible campaign battles can call Retinue.
- Tutorial/no-reward and skirmish routes do not show the reinforcement option.
- Dead Retinue units are removed; Recovering units cannot deploy or reinforce.
- Replay does not advance recovery or duplicate first-clear rewards.

## Verification Notes

- `RetinueReinforcementRules` tests cover eligibility, cost, repeat use, destroyed Command Hall, Tutorial/no-reward, and Recovering reserve blocking.
- Hosted proxy coverage verifies Call Retinue appears, spends Crowns, spawns the reserve unit, locks after one use, and appears in Results with recovery copy.
- Final package verification must include the v0.63-v0.65 docs and clean build info.
