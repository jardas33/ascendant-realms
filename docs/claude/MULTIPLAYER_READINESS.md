# Ascendant Realms: online multiplayer readiness

Emanuel wants players to be able to fight each other and team up online later. This note records what the game already does that helps, what stands in the way, and the approach Claude recommends. Written 2026-09-28.

## Recommended approach: host-authoritative, not lockstep

Two families of RTS networking exist:

- **Lockstep** (every machine runs the same simulation from the same inputs; only commands are sent). This is cheap on bandwidth, but it needs a bit-for-bit deterministic simulation. Godot's physics (move_and_slide), navigation avoidance (RVO, multi-threaded) and floating point across CPUs are not guaranteed deterministic, so lockstep would need a custom fixed-point movement layer. It is a very large rewrite.
- **Host-authoritative** (one machine, the host or a dedicated server, runs the real simulation; clients send commands and receive state). Godot's high-level multiplayer (MultiplayerSpawner, MultiplayerSynchronizer, RPCs) is built for this. It tolerates non-determinism. Bandwidth is higher, but an RTS at a few hundred units is fine at 10 to 20 state updates a second with interpolation, and the game already interpolates movement at a 30 Hz simulation.

**Recommendation:** host-authoritative. Co-op (players on one team against AI) and PvP use the same model; the AI already runs as ordinary nodes that could run on the host only.

## What is already in place

- **30 Hz fixed simulation with physics interpolation.** Clients can render smooth motion from 30 Hz (or slower) state.
- **Commands are already discrete methods on units** (command_move, command_attack, command_gather, command_build, cast_ability). They map naturally onto client-to-host RPCs.
- **A match seed.** `GameWorld.sim_seed_for(salt)` derives all simulation randomness from one seed (config key `seed`, or a hash of map, opponents and race). The AI's decisions use a generator seeded from it, and units stagger their target scans by creation order (`spawn_serial`) instead of random numbers.
- **Seeded content.** Endless Road stages (`endless_defs.gd`) and battle loot (`loot_defs.gd`) are pure functions of their inputs, so every player sees the same stage N and the same loot for the same result. That is good for fairness and leaderboards.
- **Profile data is plain JSON** and could later be mirrored to a server account.

## What stands in the way (to fix when multiplayer work starts)

1. **Everything assumes one local player.** `player_team`, `player_commander`, fog of war (`is_player_visible`), the HUD and the RTS controller all read "the player". Multiplayer needs a per-peer team and per-peer fog.
2. **Profile-driven hero stats.** The local profile builds the player's hero. Online, each peer's hero data must come from that peer (validated by the host), or PvP could be skewed by edited saves.
3. **AI and timers on frame time.** EnemyAI thinks in `_process` and some timers (for example stalled-site cancellation) read the real clock. On a host-authoritative model this is fine (only the host runs them). Under lockstep it would not be.
4. **Scene-tree spawning.** Units and buildings are created with `new()` and `add_child` directly. Networked play would route spawns through a MultiplayerSpawner with network-safe names.
5. **Presentation randomness** (combat effects, building collapse lean, loading tips) is unseeded. That is harmless: it is visual only and never needs to match between machines.

## Suggested first milestone

A two-player LAN co-op skirmish: host plus one client on the same team against the AI, using ENet, a MultiplayerSynchronizer per unit (position, hp, state) and command RPCs. That proves the model before PvP matchmaking or any server work.

## Step taken (plan 23): the command bus

`scripts/world/command_bus.gd` (owned by `GameWorld` as `command_bus`). Every order the player controller gives (move with formation slots, attack with per-unit target pairing, attack-move, gather, build, repair, stop, hold, patrol) now goes through `command_bus.issue(order)`. The bus runs the order at once, exactly as before, and keeps its serialisable form (order type, unit network ids, target network id or position, physics tick) in `command_bus.history`. `serialize()` / `deserialize()` round-trip through JSON with the same units and targets (checked by `D:\ClaudeWork\ar-review\claude_cmdbus.gd`).

Still direct calls, to route next: building placement, training and research from the HUD, rally points, and hero abilities. Network ids are assigned on first use, so the host must be the one assigning them in an online match.
