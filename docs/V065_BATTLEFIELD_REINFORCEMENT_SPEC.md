# v0.65 Battlefield Reinforcement Spec

## Goal

Add one safe battle option for calling a Ready reserve unit into an eligible campaign fight.

## Reinforcement Rules

- Campaign battle only.
- Rewards-disabled and Tutorial routes cannot call reinforcements.
- One call per battle.
- At most one Ready reserve Retinue unit can arrive.
- Recovering and already deployed units are not valid reinforcement candidates.
- Player Command Hall must be alive.
- Cost is 75 Crowns from battle resources.
- Spawn happens near the player Command Hall using existing safe trained-unit spawn placement.
- The arriving unit keeps saved rank, XP, kills, and Retinue id.

## Runtime Integration

- The reinforcement unit behaves like a normal Retinue unit after arrival.
- It can be selected, control-grouped, moved with formation offsets, and Patrolled.
- If it dies, it is removed like any other Retinue loss.
- If it survives, it counts as a participating Retinue unit for survivor counters and low-HP recovery.

## UI Scope

- Use the existing battle HUD command tray.
- Show `Call Retinue` with cost and disabled reasons.
- Show one-use/cost/no-reserve/Command-Hall-destroyed states clearly.
- Results summarizes whether reinforcement was used and which unit arrived.

## Deferrals

- No reinforcement menu.
- No multiple waves.
- No purchasable mercenaries.
- No enemy reinforcement mirror system.
- No new art or VFX.
