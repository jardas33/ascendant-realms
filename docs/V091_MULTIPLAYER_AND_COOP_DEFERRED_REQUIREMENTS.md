# v0.91 Multiplayer And Co-op Deferred Requirements

Status: deferred requirements only. This document does not implement multiplayer, networking, PvP, co-op, matchmaking, accounts, or engine changes.

## Purpose

Future online scope matters to engine choice, save architecture, and simulation boundaries. It should not be built during the browser prototype or initial desktop transition planning. This document records what the eventual architecture must consider so premature decisions do not block the long-term roadmap.

## Current Boundary

- No multiplayer runtime exists.
- No co-op runtime exists.
- No account system exists.
- No authoritative server model exists.
- No matchmaking or lobby exists.
- No network replay or sync model exists.

That is intentional. Single-player control, readability, pathing, save safety, content pipeline, and vertical-slice proof are higher priority.

## Deferred Online Modes

| Mode | Future promise | Why deferred |
| --- | --- | --- |
| Online PvP | Competitive RTS/RPG skirmish or structured match mode. | Requires deterministic or authoritative simulation, anti-cheat posture, matchmaking, balance rules, and robust pathing at scale. |
| Online co-op Expeditions | Shared PvE missions, possibly campaign-adjacent. | Requires shared progression rules, save ownership, disconnect handling, role clarity, and reward safety. |
| Spectator/replay | Watch or review battles. | Depends on deterministic event recording and stable simulation boundaries. |
| Modded/custom games | Community content and variants. | Depends on content validation, sandboxing, and stable data formats. |

## Engine Decision Implications

Future engine evaluation should ask:

- Can the engine support deterministic lockstep if needed?
- If not, can it support authoritative server simulation cleanly?
- Can unit commands, pathing, ability casts, Retinue/reinforcement, and Lume events be represented as deterministic inputs?
- Can replays be recorded from command/event streams?
- Can UI and simulation be separated enough to test headlessly?
- Can content IDs remain stable across client and server builds?
- Can build tooling produce compatible client/server artifacts if required?
- Does licensing or platform policy affect online distribution?

## Future Architecture Requirements

Simulation:

- explicit command model,
- deterministic or server-authoritative tick policy,
- seeded random policy,
- reconcileable pathing and combat outcomes,
- clear separation between presentation and state.

Networking:

- lobby/match setup,
- identity/account boundary,
- reconnect/disconnect handling,
- latency and pause policy,
- cheat/resync detection,
- version compatibility.

Progression:

- co-op reward ownership,
- anti-farm safeguards,
- save conflict resolution,
- Retinue/relic/skill progression sync,
- campaign host/client authority.

Testing:

- multi-client automation,
- deterministic replay validation,
- packet-loss/latency tests,
- disconnect/resume tests,
- save/reward duplication tests.

Operations:

- build deployment,
- telemetry,
- crash/log capture,
- patch compatibility,
- moderation/reporting posture if public online play exists.

## What Not To Build Now

- No network transport.
- No lobby UI.
- No account/profile server.
- No PvP balance layer.
- No co-op campaign save model.
- No rollback/lockstep implementation.
- No server process.
- No engine choice based solely on future online promise.

## Minimum Prerequisite Before Reopening

Online scope should reopen only after:

1. A single-player desktop benchmark proves pathing, input, combat, UI, and performance.
2. A desktop vertical slice is playable and packageable.
3. Save/content translation has a tested shape.
4. The simulation/state boundary is explicit enough to reason about networking.
5. Emmanuel approves a narrow online experiment goal.

## Practical Current Value

The browser prototype still helps future multiplayer by strengthening:

- command semantics,
- deterministic simulator habits,
- content IDs,
- save/reward safety,
- campaign/replay rules,
- UI readability,
- tactical pressure pacing.

Those values should be protected even while online implementation stays deferred.
