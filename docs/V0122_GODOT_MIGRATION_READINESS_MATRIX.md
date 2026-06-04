# v0.122 Godot Migration Readiness Matrix

Status: implemented as an architecture-readiness classification for the bounded adapter proof.

This matrix classifies the current browser-to-Godot migration posture without choosing Godot finally and without starting a full port.

| Area | Classification | v0.122 Readiness Notes |
| --- | --- | --- |
| Hero | proven adapter-ready | `hero_aster` is represented in the generated fixture and participates in the fixed-seed parity posture. |
| Units | proven adapter-ready | Worker, Militia, Ranger, and bounded Ashen references load through typed adapters. |
| Buildings | proven adapter-ready | Command Hall and Barracks load through the building adapter. |
| Sites | proven adapter-ready | Mine, shrine, and capture-site references load through the site adapter. |
| Lume | proven adapter-ready | Lume endpoint/link evidence is loaded, and `linked_ward` remains exactly `0.92`. |
| Combat | fixture-only | Health, damage posture, target acquisition, and pressure fixture outcomes are bounded checks, not full combat parity. |
| Movement | fixture-only | Movement acceptance is checked against the fixed Tier M fixture, not full browser pathing semantics. |
| AI | conceptually reusable | Enemy-pressure shape is fixture-driven, but full browser AI planning remains outside scope. |
| Pathing | requires rewrite | Godot navigation behavior must be evaluated separately before any production migration. |
| Campaign | intentionally deferred | Campaign map, nodes beyond the selected fixture, consequences, and progression are not ported. |
| Rewards | intentionally deferred | Rewards remain browser-owned and are not mutated by the Godot spike. |
| Saves | fixture-only | v0.102 save fixtures are read-only translation evidence; no save path or migration is created. |
| Retinue | intentionally deferred | Retinue systems are not included in v0.122. |
| Relics | intentionally deferred | Relic inventory, rewards, and persistence are not included in v0.122. |
| Stronghold | intentionally deferred | Stronghold progression and management are not included in v0.122. |
| UI | blocked pending visual review | Placeholder HUD and Results posture exist, but production UI direction is not approved. |
| Art | blocked pending visual review | Procedural placeholders remain evidence only; no art is imported. |
| Audio | intentionally deferred | No engine audio pipeline is evaluated in v0.122. |
| Multiplayer | intentionally deferred | Multiplayer, PvP, and co-op remain out of scope. |

## Summary

The strongest v0.122 signal is that Codex can consume generated content, validate IDs, run typed adapters, and compare bounded fixture outcomes without routine editor work. The weakest areas remain full pathing, AI depth, campaign progression, production UI, runtime art, and any feature requiring an explicit future engine decision.
