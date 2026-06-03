# v0.112 Battle-Loop Scheduler Map

This map documents recurring battle-loop work only. It does not approve gameplay, balance, save, art, engine, or desktop-port changes.

| Subsystem | Owner | Cadence | Cost | Dirty state | Visibility | Posture | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Runtime clock/status | src/game/scenes/BattleScene.ts | every active frame | fixed | yes | none | gameplay-critical | v0.110 phase rows include simulationClock as a measured phase. |
| Camera | src/game/systems/CameraSystem.ts | every active frame | variable | yes | viewport | gameplay-critical | v0.110 camera isolation row. |
| Abilities | src/game/systems/AbilitySystem.ts | every active frame | variable | no | selected hero/enemy heroes | gameplay-critical | Phase profiler separates abilities. |
| Movement/pathing | src/game/systems/MovementSystem.ts | every active frame when movement or separation can matter | mixed | yes | unit move targets and collision | gameplay-critical | v0.110 Tier M showed movement/pathing as non-trivial incremental work. |
| Combat/projectiles | src/game/systems/CombatSystem.ts | every active frame | variable | no | hostile range/projectiles | gameplay-critical | v0.110 phase rows separate combat/projectiles. |
| Status effects | src/game/systems/StatusEffectSystem.ts | every active frame | mixed | yes | active statuses | gameplay-critical | v0.110 Tier M top phase frequently reported status effects. |
| Economy/production | src/game/systems/BuildingSystem.ts | every active frame | mixed | no | buildings/sites/resources | gameplay-critical | v0.110 density rows report economy/production cost. |
| Lume simulation | src/game/battle/LumeNetworkDirector.ts | every active frame when a Lume network exists | variable | yes | Lume eligible battle | gameplay-critical | v0.110 Lume rows isolate simulation/presentation. |
| Lume presentation | src/game/scenes/BattleScene.ts | every frame but signature-gated | variable | yes | visibility mode and link state | presentation-only | v0.110 Lume hidden/auto/always rows. |
| Fog simulation | src/game/systems/FogOfWarSystem.ts | 0.12 second cadence | mixed | yes | fog enabled | gameplay-critical | v0.110 fog rows and v0.111 clean-profile comparison. |
| Fog presentation | src/game/scenes/BattleScene.ts | after fog simulation or force | variable | yes | fog enabled and render signature | presentation-only | v0.110 fog presentation isolation row. |
| HUD DOM | src/game/ui/HUD.ts | 0.1 second cadence or forced interaction | mixed | yes | HUD visibility/state | presentation-only | v0.110 HUD DOM top signal in static rows. |
| Minimap snapshot | src/game/battle/BattleSceneSnapshots.ts | HUD refresh cadence | mixed | yes | fog/camera/pings/entities | presentation-only | v0.110 minimap paused/reduced rows. |
| Notifications | src/game/scenes/BattleScene.ts | event driven plus status timer | variable | yes | status priority/timers | presentation-only | v0.109/v0.110 notification isolation. |
| Profiler counters | src/game/scenes/BattleScene.ts | only when private phase profiler is on | fixed | yes | private diagnostics | private-diagnostic | v0.110 profiler capability report. |
| End conditions | src/game/scenes/BattleScene.ts | every active simulation frame | fixed | no | runtime battle outcome | gameplay-critical | Phase profiler separates end conditions. |

## Safe Optimizations

- Runtime clock/status: Keep existing timer tick; avoid extra diagnostic work when paused.
- Camera: Private diagnostics can pause for measurement only.
- Abilities: No v0.112 runtime rewrite.
- Movement/pathing: Skip grid creation on idle non-overlap frames; keep buff updates.
- Combat/projectiles: Build attacker list with loops preserving order.
- Status effects: Return a shared empty tick result for no-op carriers.
- Economy/production: Audit-only for v0.112.
- Lume simulation: Keep render cache separate from state.
- Lume presentation: Keep existing graphics cache/signature.
- Fog simulation: Loop source construction; keep source snapshot copy inside FogOfWarSystem.
- Fog presentation: Skip redraw when signature unchanged.
- HUD DOM: Avoid unchanged DOM patches; keep local-panel wakeups.
- Minimap snapshot: Loop marker construction; retain marker order and visibility rules.
- Notifications: Keep existing suppression diagnostics private-only.
- Profiler counters: Check enabled before creating count snapshot.
- End conditions: Audit-only for v0.112.

## Unsafe Optimizations

- Runtime clock/status: Skipping runtime.tick or status timers.
- Camera: Reducing camera tick cadence.
- Abilities: Skipping cooldown updates.
- Movement/pathing: Changing path outputs, repath cooldowns, or separation results.
- Combat/projectiles: Changing target priority, cooldowns, projectile timing, or damage.
- Status effects: Changing tick interval, duration, or damage.
- Economy/production: Changing income, training, upgrades, or repairs.
- Lume simulation: Changing benefit value, activation, rewards-disabled, or tutorial exclusion.
- Lume presentation: Removing selected/activated/severed visual states.
- Fog simulation: Changing reveal radius, cell state, or cadence.
- Fog presentation: Skipping entity visibility when cells or entity visibility can change.
- HUD DOM: Suppressing command availability or status changes.
- Minimap snapshot: Changing fog visibility, marker order, or camera math.
- Notifications: Changing dedupe priority or gameplay warnings.
- Profiler counters: Collecting profiler counters in public/default runtime.
- End conditions: Changing victory/defeat conditions.
